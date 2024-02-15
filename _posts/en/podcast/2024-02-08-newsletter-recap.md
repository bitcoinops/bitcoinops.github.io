---
title: 'Bitcoin Optech Newsletter #288 Recap Podcast'
permalink: /en/podcast/2024/02/08/
reference: /en/newsletters/2024/02/07/
name: 2024-02-08-recap
slug: 2024-02-08-recap
type: podcast
layout: podcast-episode
lang: en
---
Dave Harding and Mike Schmidt are joined by Bastien Teinturier and Eugene Siegel to
discuss [Newsletter #288]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-1-8/5d58b382-fbf4-befa-a95b-a6fb42b4805b.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #288 Recap on
Twitter spaces.  We have two special guests today, t-bast and Eugene, with Dave
as our co-host today, and we're going to be talking about a block stalling bug
in Bitcoin Core, we're going to talk about zero-conf channels with v3
transactions, verifying inputs that use segwit and protocols that could be
vulnerable to txid malleability, an idea for replace by feerate in order to
escape pinning attacks, and an update on the Bitcoin-Dev mailing list, in
addition to our weekly release and notable code updates.  I'm Mike Schmidt, I'm
a contributor at Optech and Executive Director at Brink, where we fund Bitcoin
open-source developers.  Dave, thanks for joining us today.  You want to say hi
to everybody?

**Dave Harding**: Hi, everybody.  I'm Dave, I'm co-author of the Optech
Newsletter and co-author of Mastering Bitcoin, Third Edition.

**Mike Schmidt**: Bastian?

**Bastien Teinturier**: Hey, I'm Bastien, I'm working on the LN and one of its
implementations, Eclair, and one popular wallet, Phoenix.

**Mike Schmidt**: Eugene?

**Eugene Siegel**: Hi, I'm Eugene and I work on LND.

**Mike Schmidt**: Well thanks, Bastien and Eugene, for joining us.  For those
following along, this is Newsletter #288, and we're going to go through in order
here, starting with the news section.  We have a few different news items this
week.

_Public disclosure of a block stalling bug in Bitcoin Core affecting LN_

The first one is titled, Public disclosure of a block stalling bug in Bitcoin
Core affecting LN.  Eugene, this was something that you announced on Delving
Bitcoin, that you discovered this bug.  Why don't you explain the bug and maybe
also a little bit about how you found it.

**Eugene Siegel**: Yeah, so before version 22 of Bitcoin Core, there were two
ways to get notified of a block: compact block relay and headers-first relay,
and I don't think this has changed since then.  But those were the two ways to
get notified of a block.  And Bitcoin Core does implement BIP152, and you choose
three peers for compact block relay, and so it will select a peer for high
bandwidth compact block relay, select a peer if it was the first out of all the
peers to announce a block.  And before version 22, it was possible for an
inbound attacker to take up all three of these slots.  And Core also had this
logic where if you're the first to announce a block via a headers-first relay,
you'll be selected first to serve up the block, and that logic still exists, and
you have a timer of around ten minutes to serve the block.  If you fail to
deliver the block, the next peer in line gets the getdata.

So, at the time, Core had this very predictable order of peer processing, and it
could be exploited because if I connect very rapidly 50 times in a row, let's
say, with no honest connections in between my 50 sequential connections, you
could just not serve the block for that amount of time.  So, that's the stalling
part.  And it effects LN because you need to be aware of blocks to be able to do
onchain settlement.  And if there's a Hash Time Locked Contract (HTLC) routed
across the network and you're part of that route, basically you could be
prevented from, I guess, settling onchain to HTLC, and so you can lose the value
of an HTLC that way.  But yeah, I found this, I was just researching I guess the
Bitcoin Core net processing code, and I just stumbled upon this by chance.

**Mike Schmidt**: Okay, so you weren't running any sort of automated testing or
anything like that on the LN side of things, you were just kind of reviewing the
code out of maybe curiosity and you saw that maybe this sort of attack was
possible, and it was?

**Eugene Siegel**: Yeah, pretty much.

**Mike Schmidt**: Okay, so in this attack scenario, am I right to understand
that the victim would have to be attacked at the P2P level as well as also in
the LN topology, the attacker would also have to have either side of the victim
in terms of routing; is that right?

**Eugene Siegel**: Yeah.  So, I mean the first thing the attacker has to do is
identify the victim's Bitcoin node, and that can be done in a variety of ways.
Maybe they have the same addresses, or maybe you want to do transaction source
identification if you want to get fancy.  But in my example, I had the attacker
be on both sides of the victim, but that you don't actually need that, you only
need the attacker on one side of the victim.  So, you only need the attacker to
have a channel on the outgoing side, and then the attacker can have just any old
channel, any old path to the victim through a different channel.  So, it doesn't
have to be sandwiched in between, like in my example.

**Mike Schmidt**: And on the Bitcoin side of things, am I right to understand
that this vulnerability was present both with headers-first and compact block
relay?  Because you mentioned the compact block relay three slots, and then also
clogging up the slots, headers-first relay.  You gave the example of 50 slots.
Is that either or both, maybe?

**Eugene Siegel**: Right, so the attacker has to control all three compact block
connections because blocks are, I guess, announced unsolicited if you have
high-bandwidth peers.  And if you don't have those three compact block
connections controlled, then a victim gets notified of the block.  So, you have
to stack up all these connections and they're like headers-first relay, those
connections, but then you also control the three compact block connections.

**Mike Schmidt**: We noted in the newsletter two related changes in Bitcoin Core
to prevent this sort of stalling.  The first one was Bitcoin Core #22144 which
as you mentioned, the attack involved the sequential ordering of peers, and if
you are an attacker and you just get in a bunch in a row as a peer, that was
part of the attack.  And so, that PR #22144 randomizes the order that peers
would be serviced in when you're handling that sort of thing.  So, that would
make it harder for the attacker, unless I guess they controlled most of the
slots, then hopefully you at least have one honest peer then that would mitigate
this issue.  And the second PR, #22147, would keep at least one outbound
high-bandwidth compact block filter peer.  And so then, I guess the chances of
you picking the attacker then is drastically reduced versus them flooding your
inbound slots.  Do I have that right?

**Eugene Siegel**: Yeah, exactly.

**Mike Schmidt**: Dave or t-bast, you may have some more details you want to
dive into with Eugene.

**Dave Harding**: Well first of all, thank you, Eugene, for reporting this and
helping it get fixed.  I think we're all very grateful for that.  And thank you
also for publicly disclosing it once it had been fixed.  I think it's very
useful for us all to be able to learn from these past vulnerabilities.  One of
the questions I had was, in your post you discussed some of the ways that LND
could work around this problem, make sure things were safe.  And actually while
you were talking, I looked up an old newsletter of ours where we covered LND PR
#5621, when LND started sending the latest block header as part of its ping
messages.  And we noted that as a type of protection against eclipse attacks.
We have an article on eclipse attacks on our website, the topic section.

I know also, keep asking here, I know Eclair has a number of sources that it
uses to get the latest block headers for eclipse attacks protection, and this is
kind of what this block stalling attack is.  I didn't think of it that way when
I was writing the newsletter, but this is kind of an eclipse attack where,
unlike a regular eclipse attack where you just make sure a node only has its
honest peers, in this case we prevent the node from getting information from its
honest peers if it has any.  And I was just wondering, was that part of the
mitigation on the LND side, or is that something you just thought was good in
general?  And I was also wondering if Bastien had any comments on eclipse attack
protection, building that straight into LN nodes, having them get the latest
block through alternative sources besides their Bitcoin node.  Sorry, I'm a
little rambling there but basically, is that a good thing for LN nodes to do, to
get blocks from their Bitcoin node as well as from other sources like other LN
peers?

**Eugene Siegel**: It was not a mitigation that PR #5621, I think it was just
like a nice-to-have in case we decide to actually act on being behind.  We
haven't really done anything in LND yet with that data, but yeah, I think it's a
good idea to just have it, because eventually we could have logic where if we
detect we're behind, then we can, I don't know, do something like fetch block
from peer -- I think that's the RPC in Bitcoin Core -- do something like that to
get a block if we're behind.

**Mike Schmidt**: T-bast, thoughts on the chain tip?

**Bastien Teinturier**: Yeah, first of all, thanks for working on this, finding
this issue, responsibly disclosing it and waiting for it to be fixed and
deployed before announcing it publicly.  So, I'd like to summarize some best
practices around how LN nodes use Bitcoin nodes.  First of all, you should have
reasonable delays in your CLTV expiry deltas, so that if you are attacked, the
attacker has to be able to sustain the attack for many blocks to make it harder
for them.  So by default, I think all implementations kind of raised their
defaults over the past year or two years, but you should check what the default
for CLTV expiry delta is for your implementation, and maybe you should consider
raising it even more if you want to be safe.

Then, you should really make sure that it is hard to identify the Bitcoin node
that is associated to your LN node, because it is really hard to recover from an
eclipse attack.  We have ways to detect it, we can detect that we are not
receiving blocks; but actually acting on it automatically is quite hard because
you would need, for example, to be able to fall back to a secondary Bitcoin
node, which requires more operational and more hooks that have mostly not been
implemented by anyone right now.  So, the best defense is to make sure that you
cannot be eclipse attacked, because eclipsing someone is quite hard if you are
unable to identify the Bitcoin node.

So first of all, make sure that your Bitcoin node is not operating under the
same IP address as your LN node because you are advertising your LN node to the
world with its IP address.  So, if there's a Bitcoin node that matches exactly
that IP address, then it's really obvious that it is yours.  And it may be an
issue for people using things like Umbrel or RaspiBlitz, so you want to make
sure that this is properly configured.  And yeah, be prepared to have a
potential fallback secondary node that you use in case you detect an eclipse
attack, or suspect that something is going wrong because your node is constantly
warning you that it's not receiving blocks as it should.

But yeah, we have all those warnings in Eclair, but we have no automation for
actually switching to a different Bitcoin node because that also creates a lot
of potential issues.  So, the best defense is to make sure that your Bitcoin
node is well hidden.

**Mike Schmidt**: Dave, question for you.  In the newsletter, we noted the
stalling attack, which took advantage of older versions of Bitcoin Core being
willing to wait up to ten minutes for a peer to deliver the block before
requesting from another peer.  Has that changed since these older versions and
if so, do you recall how?

**Dave Harding**: I don't recall that we're willing to wait.  The thing here is,
if you have an honest compact block high-bandwidth peer, and by default Bitcoin
Core I think currently selects three of those, and maybe in the future we'll add
more slots, but if you have an honest compact block peer as a high-bandwidth
route, the way that works is they send you the block immediately upon them
receiving it.  They receive it, they do a minimal verification on it, and then
they forward it to you.  This way the blocks propagate to the network very fast.
And so, the first part of Eugene's attack there is making sure you don't have
any honest high-bandwidth node compact block peers.  So, I think the answer to
your question is that we don't normally wait ten minutes.  We don't expect to
have to wait ten minutes because we expect one of our compact block peers to
send us that block right away.

Beyond that, if you are still able to prevent Bitcoin Core from having compact
block high-bandwidth peers, the next protection is that we now have outbound
connections, connections that our node creates to peers that it selects.  So,
they're not selected by an outside party, we select them ourselves.  I think we
currently have two of them and they're block-only connections.  And so those
peers, we tell them we don't want them to send us all transactions, we just want
them to send us the latest blocks.  And I don't know if we give them preference,
but I think we do give them preference for sending us blocks.

Then, again, we have the mitigation, so two mitigations we discussed in a
newsletter that were direct responses is to Eugene's report, which is that we
randomize the order in which we selected peers.  So, Eugene said in his attack,
you create say 50 connections very close in time to each other, as if they're
all in a row, and we would just round-robin select between those peers.  Now
we'll select a random peer, so you'd have to control every one of the incoming
slots and also the outbound slots.  So, on a fully connected network node,
that's 125 slots that you'd have to control, plus you'd have to control the
block-only connections.

Then the other one we have is that we choose our outbound peers for
high-bandwidth compact block relay mode more selectively, we try to keep at
least one of the outbound peers, even if it isn't as well performing as some of
our inbound peers.

**Mike Schmidt**: Eugene, thanks for joining us.  You're welcome to stay on
through the rest of the newsletter and comment if you'd like.  Otherwise, if you
have other things to do, you're free to drop.

**Eugene Siegel**: Yeah, thanks for having me.

_Securely opening zero-conf channels with v3 transactions_

**Mike Schmidt**: Cheers.  Next item from the newsletter, titled Securely
opening zero-conf channels with v3 transactions.  This discussion was started by
Matt Corallo, posting to the Delving Bitcoin Forum, but as Matt couldn't make it
with us today, t-bast, perhaps you could help explain the idea here?

**Bastien Teinturier**: Yeah, sure.  So, v3 transactions is a new policy change
that adds more restriction to the cluster of transactions you are able to submit
to the mempool.  And the goal of that change is to make sure that we have, in
the short term, good enough mitigations for pinning attacks.  And it's a quite
effective mitigation for most of the pinning attacks we're aware of.  But one of
the issues is that it limits those packages of unconfirmed transactions to one
parent, one child.  So, this is fine in most cases, but there's one use case
where that is quite limiting, and this is zero-conf with LN channel, especially
when you start using splicing transactions, because when you want to make
zero-conf splices, your channel history is going to be a chain of splice
transactions spending each other.

And if done correctly, you can safely use zero-conf for them.  But you can
safely use zero-conf for them if you're sure that you are able to make them
confirm at some point in case there is a false close with pending HTLC, and you
have to claim that before timeout expires.

The issue here is we were trying to figure out, should we make those splice
transactions v3 or not?  Would it fix something or would it not fix it?  So, the
issue is that if we make those transactions be free, then that means we cannot
create chains of unconfirmed transactions any more, because we would be limited
by one unconfirmed parent, one unconfirmed child.  So, we don't want that
because otherwise it's too limiting for mobile wallets.  So, since we want to
keep those chains of unconfirmed transactions and keep using zero-conf, we
cannot make them be free.  So, if we cannot make them be free and still want to
make sure that we're able to make them confirm at any point in time, that means
each of those transactions need to have some kind of anchor that we can use to
CPFP.

For example, if you have a chain of five unconfirmed transactions, and then
there's a force close with a pending HTLC, you would start at the top with the
first one that doesn't have any unconfirmed parent, you CPFP on that one to make
sure that it confirms, then do the second one, then the third one, then the
fourth one, then eventually your commitment transaction, which is quite annoying
because it's really inefficient.  It means you have to add new outputs to
funding transactions, which adds weight, which means you also lock some funds in
change outputs that are unsafe for a while.  So, this is not great, but
zero-conf is already kind of a trust trade-off.

So, this is a trade-off that people will have to choose for themselves if
they're willing to take that potential security risk or not.  And in the long
run, cluster mempool is hopefully going to help us have better v3 topologies
that would let us use zero-conf safely with this change of transactions, while
being safe from pinning, but that is still a long ways off.  Was that clear
enough?

**Mike Schmidt**: One follow-up question for me, maybe it's clearer for others.
Is it specific to zero-conf and splicing?  If you're just doing a non-splicing
zero-conf channel opening, could you still use v3?

**Bastien Teinturier**: You would have a similar issue, but not exactly the
same.  If you are opening a new channel, then you would have the funding
transaction, the commitment transaction that would be a child of that, and then
your anchor transaction that would yet be another child of that.  So, if you
make the funding transaction v3, that means that while it's unconfirmed, you
could only publish the funding transaction and the commit transaction but you
would not be able to publish the anchor that is supposed to do the CPFP because
of a restriction to one unconfirmed parent and one child.  So, you would still
have to add a change output or an anchor output to the funding transaction to be
able to CPFP it.  So, you have kind of the same issue with funding transactions.

**Mike Schmidt**: Got it, that makes a lot of sense.  Thanks for clarifying.
Dave, what do you think?

**Dave Harding**: Yeah, so I think the thing to think through there is that for
the party who is getting to use the channel in a zero-conf state, especially if
they're a client user who isn't receiving funds, is only sending funds, which is
the only thing that's safe to do in a zero-conf state for a new channel, they're
pretty much safe here.  It's the other user who could have problems.  And it is
kind of an exploitable problem, unless you add these extra outputs to the
funding transactions or the splicing transactions.  And yeah, so it's just kind
of a waste of chain space.

It seemed to me, and I guess this is my question back to Bastien is, it seems to
be from the discussion that LN developers are like, "This is a problem, but
we're probably just going to have to modify our stuff and hope that v3 gets in
and then v3.1, or whatever the next thing is, gets implemented really fast and
you can just drop these extra outputs".  Is that basically where you're leading
to, Bastien, hoping that somebody comes up with a brilliant idea, but expecting
that you're just going to have to put a little extra data onchain for funding
transactions and splicing transactions for a year or two?

**Bastien Teinturier**: Yeah, that's exactly how we think about it.  But on top
of that, while we're also taking, at least for our node, a kind of leap of
faith, where if the mempool is not crazy full, we just do splicing transactions
that don't have -- we still use a feerate that is reasonable for the splicing
transactions.  And we don't put these anchor outputs, which is somewhat taking a
risk, but yeah, we are taking that risk for most transactions because otherwise
the trade-off is that the issue with splicing is that whenever you make a splice
transaction and you have a change output on that, or in that case we would only
make an anchor output, but if you have a change output in a splice transaction,
the issue is that since that splice transaction could be double spent by a
commitment transaction, your change output is unsafe, which means that it's some
of your money, some of the money that belongs to your Bitcoin wallet, that you
cannot use until the splice transaction confirms.

So, we want to make sure that splice transactions confirm quite quickly anyway,
so our goal is to target the feerate.  And since when you are making a splice,
you are really creating it right now, it's not like commitment transactions that
will be published later, you know the current feerate, so you can still choose a
feerate that makes sense so that you are targeting block inclusion in the next
few blocks.  You are using zero-conf to make sure that it can be used right
away, but the goal is that it still confirms quite soon so that you don't have
this issue at all.  So, it is still a risk because the feerate could just keep
rising after you publish that transaction and you may not be included in the
block at all, but it's a risk we are taking now.

**Mike Schmidt**: Yeah, with all the shenanigans in the mempool, yeah, it is a
bit risky.  I saw that there was, I think, one of these BRC-20 mints that
occurred at a specific block height, and the feerate on the previous block was
something like in the 30 satoshis per vbyte (sat/vB) range and the very next
block was something like 500+ sat/vB, because I think the transaction demand was
related to one specific block.  So, these spikes can happen really quickly now
with a lot of what's going on with these other protocols.

**Bastien Teinturier**: Yeah, but it would need to spike and keep spiking for,
in our case, at least 144 blocks, which is our CLTV expiry delta, which happens.
It's true, it does happen.  But the user would also need to coordinate with that
because they would need to prepare the splice transaction beforehand, they would
be paying us fees in that space transaction, and if the attack fails, they are
paying us fees.  So, it's not ideal.  I'd like to have a much better solution
than that.  But in practice, it's kind of okay because we're also quite limiting
the amount that can be in flight at a time on channels.  Our implementation is
the most restrictive in the amount that can be pending in a channel, which
limits the amount we may lose, but it is still dangerous, I agree.

**Mike Schmidt**: It's funny looking at all the work that's going into something
like v3 with just the simple one parent, one child set up.  And now we're
already starting to talk about, "Well, if we can have a more permissive
topology", like Dave said, 3.1 or something like that!  Well, hopefully we get
there.  Dave, anything else on this topic before we move along?

**Dave Harding**: Well just if you want to learn about Greg Sanders as he is
here, if you want to learn his vision for the future of v3 transactions, you
have to wait for next week's newsletter, because he has put a post up on Delving
Bitcoin.  I haven't read it yet but I'm pretty sure it's going to be in next
week's newsletter.

_Requirement to verify inputs use segwit in protocols vulnerable to txid malleability_

**Mike Schmidt**: An Optech teaser!  All right, we look forward to that next
week.  Next news item, Requirement to verify inputs use segwit in protocols
vulnerable to txid malleability.  T-bast, this is one that you started yourself,
this discussion on Delving Bitcoin about txid malleability.  Maybe you can
outline the concern and also maybe its relation to dual funding and splicing in
LN?

**Bastien Teinturier**: Sure.  So, this one is a fun one because I can just
trace back how I came to question this and the reasoning behind it.  So, we
started working on dual-funding a long time ago, like two years ago.  And around
that time, we included whenever you add an input to the transaction, we made it
a requirement that you also provide the whole transaction that you are spending.
I didn't actually remember why we did that.  I remember that the thing that was
widely documented is that it had been added to PSBT as well for witness inputs,
because there was a way to trick hardware wallets into overpaying fees, and this
has now a few blogposts that are detailing that attack.  And I just vaguely
remember that it was something similar, and there are similar reasons why we
included that in dual-funding.

The issue of including that is that we're potentially wasting a lot of bandwidth
transmitting a whole previous transaction all the time, and also that LN
messages are limited to 65 kB, which means that if your previous transaction
exceeds 65 kB once it's serialized, you just cannot use it for dual-funding at
all, and this is something that we've seen in support.  We have users who are
trying to spend coinjoin outputs or outputs that are payouts from a mining pool,
and those just get ignored by Phoenix and by Eclair and by any LN
implementation, because they exceed the 65 kB limit.

So, before we merge, since we are nearing the end of the dual-funding
specification and we should be able to merge it soon, I wanted to see if now
that there's somewhat available -- a lot of people have been working on taproot
as well, if switching to taproot could help us remove that requirement and only
broadcast, only transmit the txout basically.  And at first, when I was
rereading the attack that was for hardware wallets and overpaying fees, it
looked like we could just remove whenever we use a taproot output, we could just
transmit the txout instead of the whole previous transaction.  But actually,
thinking about it a bit more, I couldn't really spell out the exact attack that
we were fixing in the first place, and Matt Morehouse prompted me to look into
it into more details.  So, I started thinking about it more, and actually the
attack is very different from the attack on hardware wallets.

The attack here is that whenever you are building the transaction, you are
telling the other guy, "I'm going to add that input, and I'm going to tell you
that this input is using that kind of script".  But if you don't provide a
previous transaction, they have no way of verifying that type of script.  And
the issue is that whenever they sign their side of a transaction, their
signature is only going to cover their own inputs, not yours.  So, you can lie
about the type of script that you are spending, and the transaction that your
peer will give you will stay valid, even if you replace your input script with
something else.  So, you could tell to your counterparty, "I'm going to use
segwit for that input", but actually, it's only a legacy P2PKH input.  And if
you use a legacy P2PKH input, the issue is that you change the txid of a
transaction, which invalidates the commitment transaction using LN and
completely breaks the security model of LN.  So, you want to make sure that
doesn't happen.

To prevent that, the signature of the transaction hashing algorithm for taproot
has been changed so that whenever you sign your input, you are also signing the
scripts and amounts of all the other inputs of the transaction, even if they are
not yours and they're not the ones that you are spending.  And this has a really
nice benefit, because it means that if the other guy lied to you and they tried
to replace the script, then your signature will not be valid anymore and they
won't be able to broadcast that transaction.  So, switching to taproot protects
you if you add a taproot input to the transaction.  But it doesn't protect you
if the other guy claims that they are adding taproot inputs to the transaction.
And the designers of taproot made that change explicitly for that reason, but it
was not very well documented.  It took me a while to figure out those details.
So, I thought it was worth detailing it in a Delving Bitcoin post for other
people, because that's something that could affect potentially any protocol that
collaboratively builds transactions with inputs from multiple participants.

So, yeah, the bottom line is we cannot remove that requirement from dual-funding
in the short term.  We can only remove it when we are guaranteed that there will
be a taproot input in the resulting transaction, which will be, for example, the
case for splicing transactions on a taproot channel where the main channel
output will always be using taproot, which will protect both participants from
that kind of attack.  So, for now, we're keeping that restriction that the
previous transaction has to be broadcast with the inputs.  And in the future,
once taproot channels are widely deployed and splicing is widely deployed, then
we may be able to relax it.

**Mike Schmidt**: Wow, great explanation, great back story.  There's a lot going
on here.  Dave, do you have questions for t-bast?

**Dave Harding**: First of all, again, thank you for this writeup.  I knew about
the original attack, and another shout-out to Greg Sanders again who's in the
audience, because he discovered that original attack against the segwit v0
inputs.  But yeah, thank you for writing this up because I hadn't actually
thought through it from the perspective of LN.  I don't think I would have
realized this issue existed for -- and it's not just LN, right, because it's any
protocol that accepts inputs from an external source, from somebody else.  And,
yeah, we like to think that segwit fixed malleability, but you're right, you
actually have to have an input of your own in the transaction to be able to use
any of these commitment features.  And then we have Greg's attack against v0 so
you have to have the v1 input, so it's just really interesting to me to read
this read up.

I don't have anything to add, except that it just amazes me how much we have to
think through these things when we're using them, how many turtles, you know,
this turtles all the way down on all of this stuff.

**Mike Schmidt**: Similar to the movie, Beetlejuice, where if you say his name
three times, he appears, I think we've said Greg's name three times, and he has
appeared!  Hey, Greg.

**Greg Sanders**: Hi, just going to point out that I think it was me and Johnson
Lau, jl2012.  We both discovered it simultaneously as far as I know, so just a
shout out to him, wherever he is now.

**Bastien Teinturier**: You could have written it down in more detail so that I
didn't have to rediscover it later!

**Greg Sanders**: Yeah, it was in some random mailing list post I can't even
find anymore.  So, yeah, not great.

**Mike Schmidt**: T-bast, anything that folks should be aware of other than what
we talked about here, or any other takeaways that you'd offer for people?  And I
guess your writeup now serves as the canonical reference for this sort of
discussion moving forward.

**Bastien Teinturier**: Yeah, exactly.  So, I think it's just worth raising it
to the attention of anyone who is using or designing a protocol where you accept
inputs from multiple users.  And usually in those protocols, you need the txid
to be fixed beforehand.  So, make sure that you do understand this attack and
that your protocol correctly protects from it.

_Proposal for replace by feerate to escape pinning_

**Mike Schmidt**: T-bast, thanks for joining us, you're welcome to stay on.
Moving on to the next news item, Proposal for replace by feerate to escape
pinning.  Peter Todd posted to the mailing list about a proposal for transaction
replacement policies that could work even when the currently widely used RBF
policies wouldn't allow it.  He has two variations of his proposal: the first
one, called pure replace by feerate (pure RBFr); and the second one, called
one-shot replace by feerate (one-shot RBFr).  And he also has an experimental
implementation of this RBFr strategy on his Libre Relay branch.  Dave, what is
Peter Todd getting at here?

**Dave Harding**: Well, as background, this is kind of how we would like RBF to
work.  And I think when Peter Todd first proposed RBF back in, I think it was
2012, but it could have been 2013, I think this is just how we all hoped that it
would work, which is that a transaction can be replaced by a different version
of it that pays a higher feerate.  We don't have to pay attention to any other
details of the transaction as long as it pays a higher feerate.  We assume
that's more desirable to miners, because if it paid a higher feerate, miners can
include more of that transaction in a block, higher feerate transactions in the
blocks they create.  Miners get paid more, everybody's happy, and we don't have
any complexity.

But the problem with the idea of RBFr in general, before we get to Peter Todd's
ideas here, is that you can replace a very large transaction with a very small
transaction, then you can replace it again with a very large transaction, and
then replace it again with a very small transaction.  And you keep doing this
over and over again, and you end up wasting a lot of bandwidth of the nodes that
do the relay.  So, if you're able to get every node on the network, and there's
like 50,000 to 70,000 of them out there right now, so for every byte you're able
to send across the network, that's 50,000 bytes that other people are relaying
for you.  Every MB you send is 50 GB, and that's just a lot of data that we
don't want people to waste on other people's nodes.

So, again, if you send a 100,000 byte transaction across the entire network, now
you've used 5 GB of other people's data.  And then, if you then replace that
with a 1,000 byte transaction, a much smaller transaction, you've used a small
amount of additional data.  But then if you replace it again with another
100,000 byte transaction, you've used another 5 GB of everybody's data.  And if
you do that every 10 seconds, and if you do that in parallel for a bunch of
nodes, you can end up wasting many gigabytes, terabytes of data in a matter of
minutes.  And so this is called the free relay problem, and it's the reason that
the version of RBF that we did get, BIP125, has a lot of extra rules on it, like
transactions have to pay an absolute greater fee.  So, if you take a 100,000
byte transaction that pays 1 satoshi per byte and you replace that with a 1,000
byte transaction, you still have to pay at least 100,000 satoshis in fee.  Even
though you've shrunk that transaction, you have to pay at least as much as the
previous version of the transaction in absolute fees.

But the problem with that, again, like I said, this turtles all the way down.
The problem with that is somebody can put a very large transaction in the
mempool if they're in a protocol, if you like, LN, they can put a 100,000 byte
transaction, and now if you're the honest party and you just want to replace
that with a small, let's say, 1,000 byte transaction, you've got to pay to
replace their 100,000 bytes.  So, you've got to pay 100,000 satoshis, even
though you just want to put 1,000 bytes in the mempool.  So, that's called a
pinning attack.  So, the rules that we have today have pinning attacks, and this
is why we're working on things like v3 relay to try to minimize those pinning
attacks.  But Peter Todd has tried to go back to basics in this post and tried
to figure out how we can do RBFr in a way that doesn't cause too much free relay
and eliminates the pinning attacks.  And like Mike said, there's two versions of
this.

The easy one to think about is pure RBFr.  And the only additional rule we have
on this to try to minimize free relay is that the replacement transaction has to
pay significantly higher feerate than the version of the transaction that's
being replaced.  An example Peter Todd gives is twice as much.  So, if you start
off paying 1 satoshi per byte, you have to go to 2 satoshis per byte; if you
replace it again, you've got to go to 4, 8, 16, 32, 64, and so on.  And
hopefully, quite quickly, you get to a point where that's just not sustainable
for an attacker who wants to waste bandwidth.

The second version of it is one-shot RBFr, which tries to minimize the free
relay problem for RBFr even more.  It uses a slightly lower increase, because it
has just 1.25 in fees, so if you start paying 1 satoshi per byte, now you have
to pay 1.25 satoshis per byte, and then you have to pay, whatever, 1.6 satoshis,
and then 1.9 satoshis.  And the other construction is that the replacement has
to go into the top of the mempool, the part of the mempool that we expect is
very likely to get included in the next block if a miner were to mine the next
block as soon as a transaction was received.

So, that's his basic idea.  I think versions of his ideas have been around for a
long time, but Peter has gone through and done some analysis on them.  He's
looked at the costs and he's actually gone and released an implementation, like
Mike said, out there for experimenting with them.  I'm going to take a little
break.  Mike, do you have any questions on the quick summary there?

**Mike Schmidt**: My question would probably lead into where you're going next,
which is, okay, sounds great, what's the problem?

**Dave Harding**: Yeah, that's what I figured.  So, there's a couple of
problems.  The two main problems here are that first, these rules are an
alternative to the existing policy.  So, the idea would be to have to keep the
current policy for software that expects the current policy, and then also have
this alternative path.  When doing that, you have to analyze the interactions
between these two policies.  Mark Erhardt, Murch, did that, and he discovered in
Peter Todd's original proposal a way that you could very cheaply waste a pretty
much infinite amount of node bandwidth at minimal cost to the attacker just by
kind of doing this thing that I described with the simplest idea of RBFr, where
you just keep cycling between a small transaction and a big transaction and you
slightly increase feerates as you go.

The second problem there is that there is still a fundamental problem with free
relay in RBFr.  You can still go from small to large, small to large; even if
you have to increase by 2X each time, it might not be enough to prevent nodes
from wasting a pretty significant amount of bandwidth.  And we do know that
bandwidth is one of the things that can significantly affect how many people are
able to run a relaying full node.  There's people who are running nodes on not
great connections, and they need those nodes if they want to be fully
self-sovereign with their bitcoins.  And if we increase bandwidth requirements
too much, they might not be able to run a node, and they might have to trust
somebody else's node, which is kind of antithetical to the properties we want in
Bitcoin.

So, we have two quotes here from people who did kind of quick reviews on Peter's
ideas.  I don't think they went super in depth, but again, Greg Sanders, this is
kind of a big tribute to him in this newsletter, I guess, and he points out the
reasoning is very hard to do.  Again, you just have to think through these two
different protocols and how they interact and how they can be abused, and it's
just hard to do with the way we do stuff in Bitcoin Core right now with the
mempool, with our ancestor limits and our descendant limits, and whatnot.  And
Greg is hoping that with cluster mempool, we'll have better tools for thinking
through these things.  I personally think Greg could be a little optimistic
there.  I think cluster mempool is a big improvement, but I'm not sure thinking
through things is going to get a lot easier then.  However, we may have a better
way to do stuff like this than RBFr; we may be able to apply the same rules to
transaction replacements that we'll be able to apply to child transactions and
other fee pumping strategies.

Gloria Zhao points out that the part of Peter's proposal that says that the
transaction has to go into the top of the mempool is kind of sketchy to
implement today.  It doesn't work quite the way you think it does.  Bitcoin Core
does sort the mempool and it does have an algorithm for trying to find the most
profitable transactions in the mempool for producing a block.  But there's kind
of ways to abuse that, or to create transactions that are not going to be the
top, by messing around with the way transactions get evicted, and so that's a
little hard.  And I also included a bit of a quote here is the motivation Gloria
has for v3 transactions.  I thought this was just very insightful and anybody
who's really interested should just go read her quote in the newsletter, or
follow through and read the thread and read her full quote.

But yeah, basically, just v3 can make this stuff a lot easier and I got the
impression that, I know Peter has released implementation, but I don't think the
Bitcoin Core  developers right now are super-interested in RBFr.  I think
they're going to continue to focus their attention on v3 and try to get that out
there and then try to get cluster mempool out there, and then we'll have the
tools for analyzing changes to replacement policy to try to minimize more
generally pinning attacks.  Sorry, Mike, that was a bit of a ramble.

**Mike Schmidt**: No, that's great.  It sounds like I guess both Greg and
Gloria, in one way or another, mentioned complexity of the rules and a lot of
different edge cases as general concerns.  And to your point, perhaps they're
not wanting to dive into that complexity now knowing that there's some work
towards cluster mempool being done that would essentially change a lot of that,
and so maybe it's not worth diving into all the nuance to try to figure out a
slightly better way to potentially do this at this time.

**Dave Harding**: Yeah.  I had some private chats with Greg.  He is really,
really opposed to free relay.  The free relay problem is his boogeyman, and I
just think any sort of RBFr proposal that allows a significant amount of free
relay is just going to be something that Greg is going to really look into
deeply and be critical of.  And I think in general, Bitcoin Core developers
don't like free relay, again because this is just an opportunity to waste
people's bandwidth.  And if you're a Bitcoin Core developer, making full nodes
easy to run is your thing, that's what excites you, that's what you're really
working towards.  And things that make it harder to run full nodes, even if they
might simplify second layer protocols a bit, it's just a hard trade-off for
Bitcoin Core developers.  So, I just think that's it, yeah.

**Mike Schmidt**: And if you're curious about the philosophy there, we did, with
Gloria and Murch, a series called Waiting for Confirmation, where maybe even
before a lot of this discussion surfaced, they gave a little bit of insight into
how they're thinking about this and why they're thinking about this in a certain
way, protection of node resources, protection of network resources.  So, I
invite folks to check that out.  That was about mid last year, Waiting for
Confirmation series on the Optech website.  Anything else on RBFr, Dave, before
we move to the mailing list?

**Dave Harding**: No.  I just wanted to quickly thank Peter Todd for thinking
about these things and writing detailed articles and publishing them.  I know in
our summary, we quoted some people who are critical, and maybe I sound critical
on this podcast, but it's really, really good to have people thinking about
these things, discussing the alternatives.  Again, this is something that's an
idea that's been around for a long time, but it is something we need to think
through, because if it is a lot simpler than other things, we should go that
way.  But I think v3 and cluster mempool are what we're going to be working on
in the short term at least.

**Mike Schmidt**: Yeah, and just in full transparency, we've mentioned Peter
Todd quite a few times in the last few months in the newsletter and he hasn't
been able to join us, but I have asked him and he has responded, he just hasn't
been able to make these particular times to give his take on these things.  So,
we are trying to get him on to represent his ideas, of course.

_Bitcoin-Dev mailing list migration update_

Last news item from this week, Bitcoin-Dev mailing list migration update.  The
old Linux-Foundation-hosted Bitcoin-Dev mailing list is now not taking any new
emails.  The archives remain.  And as far as I know, the Linux Foundation has
pledged to keep those archives.  Much of the discussion that perhaps a year ago
we would cover from the mailing list seems to have moved to the Delving Bitcoin
forum, as we see even in this week's newsletter and the related news items, lots
of Delving posts.  But there is an effort, separate from Delving, to move the
mailing list features to a new host.  It looks like groups.io may be a solution
there.

Dave, are we keeping the mailing list around because we've always had one, or is
it actually the best way to continue these conversations?  And maybe given the
fact that a lot of devs are on Delving, does this bifurcating of the discussions
have some negative consequences to developers trying to follow along and
newsletter authors that are trying to put all the discussions in one spot?

**Dave Harding**: Certainly, some people think the mailing list is very useful.
I know Andrew Chow and Peter Todd in particular are big fans of it, and I'm sure
there's a lot of people who just haven't spoken up and are big fans of it.  It
does have advantages over a forum and it also has drawbacks.  I particularly,
I'm really loving Delving.  I'm really grateful to AJ Towns for standing it up
and hosting that.  I'm actually surprised because I thought I was an email
junkie, but I'm really enjoying Delving.  I do think there is a bit of a problem
with fragmenting these discussions across multiple places.  I think you can see
that in our previous topic with Peter Todd and Greg Sanders and Gloria Zhao,
that they're actually replying on two different things.  So, Peter Todd posted
his idea to the mailing list, Murch replied on the mailing list, but then Greg
and Gloria replied to somebody who started the topic about the thing on Delving.

Peter Todd has written an explanation of why he doesn't want to use Delving, he
wants to stay on the milling list.  His reasons are that the milling list makes
it very easy to cryptographically sign his emails using a PGP alternative, and
that it's somewhat removed from centralization.  The mailing list is centralized
in a sense, but the archiving is less centralized.  I'm not quite sure I believe
in that.  But there actually is a Git repository that keeps copies of
everything, as opposed to Delving on a one-hour delay, hosted by James O'Beirne;
thank you, James.  But yeah, so the fragmenting concerns me because I don't want
smart people like Peter and Greg and Gloria to be talking past each other
because they're not using the same forum.  I would love to see them all on the
same forum, the same mailing list, whatever, and replying directly to each
other.

Is this going to actually be a problem?  I don't know.  It was a problem this
week for this newsletter.  I think over time people are going to go to the place
that works best for them, which is going to be the place that most other people
go.  So, I expect discussion to migrate mostly to one of these sources.  Either
it's going to go to Delving or it's going to go to the new mailing list or it's
going to go to some third place, who knows?  But yeah, I don't like the
fragmentation, and hopefully that doesn't last too long.

**Mike Schmidt**: NVK, welcome.  You have thoughts?

**Rodolfo Novak**: Hey guys, I just caught the tail end of this.  Thanks for all
the work you've been doing there, Harding.  But yeah, I do also have strong
opinions, even though I don't participate as much on the mailing list.  I
actually try to avoid like the plague to send any emails there.  I think I sent
it once, but I do follow religiously.  Yeah, thanks for the laugh, Harding!  I
try to stay on my lane and just produce client software, not participate in the
discussion there.  But my main view is this.  I think it's wonderful that James
and crew sort of put this together, but I think it's very misguided.  I think we
should have learned the lessons from Bitcointalk.  I think forums are the wrong
place for these discussions to exist for many of the same reasons that Todd
brought up.

I'd say I'm very against using Delving and making a point and not making any
posts there.  I think that centralizing platforms never ends well.  I know that
the data is backed up and you guys are doing the best that you can, right, under
the circumstances, but I think that you're going to find further issues of this
nature, further fragmentation, further people talking past each other by not
being in the same place, due to those; it's just the nature of forums, right?
And at the end of the day, forums require benevolent dictators, right?

**Mike Schmidt**: Rodolfo, you've cut out, I think.  Are you there?

**Dave Harding**: Maybe he had a network problem.  Just to quickly reply, I
think his concerns are well-founded, they're reasonable.  And he's absolutely
right.  The last thing he said was that forums require a benevolent dictator.
In this case, the benevolent dictator is AJ Towns, Anthony Towns, and this is
somebody who's been part of Bitcoin for a while and has a very long history in
free software development.  I first encountered AJ almost 20 years ago when he
was Debian project leader, the leader of over 1,000 free software developers at
the time.  But he's not perfect, right?  And there's always going to be
questions about censorship, and whatnot.  I think those are going to exist on
the mailing list too; we've had questions about censorship on the mailing list.

But I think again -- it looks like Rodolfo might be back.  But towards his point
of being a benevolent dictator I think he's absolutely right.  I don't know that
that's the end of the world but I think it is a trade-off, and just to summarize
what we're doing here at Bitcoin Optech is that we plan to continue covering
both the forum and the mailing list for the near future.  We'll see how things
play out, but we'll continue using them both as news sources.  So, wherever you
want to post, if you are a developer, or you have a question for developers,
wherever you want to post, you go to that place and you post to it.  If it's
interesting, we'll cover it in Optech.

**Rodolfo Novak**: Yeah, David, I think you kind of hit the nail on the head.  I
won't stretch this too much.  There are multiple sorts of issue vectors when you
have a centralized, especially domain as well.  So, you have the issue with the
taste of the moderators; you have the issue with some countries blocking that
domain, which with email is much harder; you're going to have issues with like
attacks on it; you have the issues with validity of the actual posts, the people
are trusting the servers are running.  Some of these issues are practical, some
of these issues are theoretical.  Anyways, I think you really see it there.  I
just hope that people don't invest too much in there, sort of re-migrate to the
new mailing list, whatever that is.  And maybe the Nostr derangement syndrome is
going to fade, and we can move all this to Nostr, which is absolutely perfect
for this!  But anyways, I appreciate you guys.

**Mike Schmidt**: Thanks for signing in, Rodolfo.  I guess it remains to be seen
if there will be a shilling point similar to what Dave mentioned and everybody
ends up on Delving or back on the mailing list.  This is decentralization,
right?  So, there's good and bad sometimes.  Moving on, Releases and release
candidates.

_LND v0.17.4-beta_

We have one this week, LND v0.17.4-beta.  It contains four bug fixes and an RPC
change to the ListSweeps API.  The four bugs are, one, when a pending channel
opening was pruned from memory, no more channels were able to be created or
accepted.  These are four different PRs that I'm sort of summarizing here.  The
second one fixed an issue that caused a memory leak for users that were running
LND with RPC polling turned on for bitcoind.  The third issue was an issue where
LND would lose syncing to the chain when using a pruned backend, and that was
specifically an issue with the BTC wallet project.  And the last issue was LND
fixed an issue with invalid certificates that could occur in certain scenarios.
So, if you're running LND and running into any of those kinds of issues, check
out their beta release.

Moving on to Notable code and documentation changes.  I'll take an opportunity
to solicit any questions or comments from the audience at this point.  We'll try
to get to them towards the end of the show here.

_Bitcoin Core #29189_

First PR, Bitcoin Core #29189, deprecates libconsensus.  What is libconsensus?
Well, the purpose of libconsensus was to make the verification functionality
that's critical to Bitcoin's consensus available to other applications.
However, this PR notes, "This library has existed for nearly ten years with very
little known uptake or impact.  It has become a maintenance burden.  In several
cases, it dictates our code/library structure, as well as build-system
procedures".  We also noted, or I guess the PR also notes, that use cases could
also be handled in the future by the libbitcoinkernel effort, which is underway.

We haven't talked about libbitcoinkernel too much recently, but libbitcoinkernel
project is a different attempt at extracting Bitcoin Core's consensus engine.
And the kernel part of the name maybe highlights that it's a little bit
different from libconsensus because as opposed to most libraries, the
libbitcoinkernel project is actually stateful.  It's a stateful library that can
spawn its own threads, it can do I/O and a bunch of other things that maybe you
wouldn't expect from a library.  So, Dave, is libbitcoinkernel a replacement for
libconsensus; and if libconsensus wasn't used, why do we need libbitcoinkernel?

**Dave Harding**: Like you just mentioned, it's different than libconsensus, so
it's not a direct replacement.  I think the idea behind libconsensus was, we're
thinking through these consensus bugs.  Like, I see Niklas is one of our
listeners this week.  I think last week's newsletter or two weeks ago, we
described a vulnerability he found in an alternative implementation, btcd, about
the specifics of handling transaction versions.  It's like a low-level detail
and a different implementation didn't implement one of the rules.  The idea
behind the consensus was that a project like btcd could use libconsensus to do
all the consensus enforcement rules.  It would be the same consensus code, the
exact same code that Bitcoin Core uses.  And so, we would avoid most, hopefully
all, but probably more realistically, most of this type of incompatible logic
between different implementations.  And so, we could have more variety of
implementations.

We had the same with consensus being used in Bitcoin Core and btcd, and so
people who wanted btcd features could have those features, but know they were
using the same consensus rules as Bitcoin Core.  And we could have dozens or
hundreds of different node implementations that all use the same exact consensus
code.  Now, a library written in C, it could be the exact same code, it can
still perform differently on different machines, so you'd probably want to go
even lower level than that, if you could, but nobody has ever really worked on
that low of a level.  So, that was the idea behind libconsensus, and
libbitcoinkernel is kind of the same, except Carl Dong, who was the champion of
libbitcoinkernel, he learned from some of the problems of the consensus, and a
different approach to both separating the code from the rest of Bitcoin Core's
code and what was required for that code, trying to keep it as close as possible
to the way Bitcoin Core uses it; whereas libconsensus was trying to turn it into
the easiest to use of libraries.

Going to your other questions there, I think libbitcoinkernel has a nice
advantage of the way it's just doing code separation in Bitcoin Core.  It's
moving the consensus code and the code that's essential for consensus into
separate files and just keeping it very clearly separate from Bitcoin Core.  And
at some point in the future, I think, the goal there is to maybe move that to a
separate repository.  So, we'll have a bitcoinkernel repository that will have
the consensus code, and the code that's necessary for consensus actions, the
things that aren't directly consensus but that we're really heavily dependent on
for consensus, like the way our database works.  And by having that in a
separate repository, anybody who wants to make a consensus change will have to
go to that repository and propose a change, and it won't get lost in the noise
of all the other higher-level stuff that we'll be doing in Bitcoin Core.

So, it's a different approach, and it's different, it's not a direct
replacement, but I do think that it is something that people might want to use
in the future.  And even if nodes like btcd and other implementations never end
up using libbitcoinkernel, it's still going to be useful to the Bitcoin Core
project to have a separation between consensus code and its runtime code, or
whatever you want to call that.  It's just good to have that separation there.
And for anybody who wants to evaluate changes to Bitcoin consensus code, all
they have to watch is one repository which will hopefully be low traffic, and
it'll be just easy to see the changes on consensus, and they can ignore all the
RPC stuff and the wallet stuff and whatever else is going on with the node and
Bitcoin Core.

_Bitcoin Core #28956_

**Mike Schmidt**: Excellent commentary.  Thank you, Dave.  You mentioned Niklas.
This next PR is from Nicholas as well.  So, Niklas, if you want to chime in on
it, you're welcome to join us.  Otherwise, we can do our best to not butcher it.
Bitcoin Core #28956, removing adjusted time from Bitcoin Core and also providing
a warning for users if their computer's clock appears to be out of sync with the
rest of the network.  So, Bitcoin relies on the idea of time for difficulty
adjustments and timelocks.  Adjusted time, when it was present in the code base,
although I guess it's still there, just not relied upon as much, what adjusted
time is, is when a node connected to a peer, that peer's current time was
compared to the local node's current time and the difference was stored
somewhere.  And then network adjusted time was then calculated by sort of
averaging across all the different peers the different offsets to that node's
current time, and then that was used as a time reference within Bitcoin Core.

We covered a few weeks ago, in Newsletter #284, a PR Review Club on this
particular PR, where we dove into some of the questions around that and
potential ramifications of making that change.  And actually last week, in
Newsletter #287 and Podcast #287, we discussed a bunch of Stack Exchange
questions potentially related to this, including why the block timestamp is not
a consensus rule.  I think this is a very interesting topic, but Dave, did we do
a good job of summarizing that there?  Would you add to that?

**Dave Harding**: I think we did good, I hope so.  You know, when I first
started writing documentation for Bitcoin in 2014, I remember people would come
into IRC, it seemed like every week, and they would have just learned about
adjusted time and their comment would be like, "Oh, if you need accurate times
for your node, you should just build a network time protocol client directly
into Bitcoin Core".  And the frustrated developers would sit there and explain
to them that, "No, network time protocol is not well authenticated, and the only
way to authenticate it is to use a trusted source.  And we're not going to build
that into Bitcoin Core, but we have this adjusted time thing".  And it's just
like using random sources to try to figure out the time, and it's just this
really weird thing.  And so, developers have been working for a long time to
just try to minimize adjusted time and get rid of it.  And I'm glad to see it
come, so thank you, Niklas.

_Bitcoin Core #29347_

**Mike Schmidt**: Next PR, Bitcoin Core #29347, which enables BIP324, v2, P2P
encrypted transport by default.  In Bitcoin Core 26.0, that was a release that
contained v2 encrypted transport support, but it was defaulted to off.  I know
I've seen in the Twitter sphere a bunch of people advocating for people to try
that out, slip it on, change the default.  And it looks like now, in the coming
version of Bitcoin Core, that this change will flip that default to true and
roll out a more encrypted P2P network.  Dave, what do you think?  Thumbs up, all
right.

_Core Lightning #6985_

Core Lightning #6985, "Adds options to hsmtool that allow it to return the
private keys for the onchain wallet in a way that allows those keys to be
imported into another wallet".  So currently, Core Lightning (CLN) has a tool to
generate the secret from a mnemonic, but it is not BIP39-compliant, and the
secret is not a seed of a BIP32 wallet, and the HD wallet does not use BIP43.
So, an issue related to this PR states, "The only thing we can export from Core
Lightning to recover our HD wallet from another software are the wallet
descriptors".  And therefore, as a result, people have been potentially using
workarounds to write code by themselves to derive the extended private keys.
But this PR author thinks functionality like this should be built into CLN.  So,
the hsmtool now provides that functionality without any required workarounds.
Dave, did you get a chance to dive deep into this one?

**Dave Harding**: I didn't dive too deep.  One quick correction is that I do
believe that CLN uses BIP32, but what it doesn't do is store the seed, it only
stores the master extended keys.  So, it can't give you the seed.  And a lot of
software that wants to import a wallet from another piece of software wants the
seed and not the master extended keys.  So, that's why it's returning specific
private keys in the hsmtool in this PR, is that that's just the only way you can
use it.  And I think it's just important to note that this can be dangerous, so
make sure you understand what you're doing before you use it.  If you want to
use it, do it, just note that there are risks here because your correlating
funds are being used in channels, and if you import into a naïve wallet that
spends funds at the wrong time, you could lose balances in your channel.

_Core Lightning #6904_

**Mike Schmidt**: Next PR is also to Core Lightning, #6904.  It must be CLN
release season soon because I see four of them this week.  This PR makes some
internal changes to CLN's connection and gossip management code, as well as
adding fields that show when a peer last had a stable connection, as defined by
having a connection for at least a minute.  And that information could be used
to drop peers or remove peers with unstable connections.  I didn't dive any
deeper into this one other than surface level.  Dave, I don't know if you have
anything to add to that.

**Dave Harding**: There's a lot of changes in this PR, but besides this, they're
mostly just features that aren't visible to users.  They're just changes and
improvements to the gossip code that CLN uses, and just improvements to its peer
handling code.  This is the only visible change.  It is kind of a useful one.
It's just telling you when you last had a stable connection to one of your
peers.  And one of the issues that works around is that previously, CLN would
tell you when you last had a connection to your peer, but if it wasn't a stable
connection, if it lasted less than a minute, it would look like you had a good
solid connection, even though your peer kept flaking on you.  It would connect
and send a message and it would error and then drop, and it would connect again,
send a message, error, and drop.  And it would do that over and over again, and
it would look like a stable connection.  It would look like you could route
funds through that channel.  But if you tried to do that, it wouldn't work, and
that could be a big problem in LN because it can cause funds to get stuck.

**Mike Schmidt**: Dave, I think we've lost you now.  And he's back.

**Dave Harding**: … to tell you that you had a stable connection to your peer,
you can probably route funds over that channel.  It's all good.

_Core Lightning #7022_

**Mike Schmidt**: Core Lightning #7022, which removes lnprototest from CLN's
testing infrastructure.  lnprototest, which basically stands for Lightning
Network Protocol Tests, it's a Python library of test helpers designed to make
it easier to test LN implementations against the LN spec.  And in this PR, Rusty
notes, "At this point, it needs a complete rewrite to be useful, and it's just
constraining development".  So, I guess they've removed it for now.  Potentially
there'll be updates to lnprototest in which they add it back in.  It should be
noted, I think, that Rusty was the original author of lnprototest, and it seems
like maybe it's just aged a bit to be useful in their codebase, at least in
their automated testing infrastructure.  Dave, any thoughts?

**Dave Harding**: I mean, this is always the problem with testing tools, is that
when you start trying to do new things, you've got to update your tools and that
can be a constraint on development.  I think CLN is the only LN implementation
that ever seriously used lnprototest.  I think people would run it against other
implementations.  But this is the kind of thing that would be great to have wide
adoption, but it's just work, it's work to do these things.  And I can
completely understand their decision to take it out for now and hopefully
rewrite it in the future to get it to work with the latest protocol.

_Core Lightning #6936_

**Mike Schmidt**: Last Core Lightning PR, #6936.  This PR is titled New
deprecation infrastructure.  And in the PR, they noted that CLN will do four
things: one, it will list deprecations in appropriate docs; it will try to give
at least two versions before removal; it will also allow one version where CLN
issues a warning message if it detects a deprecated feature being used; and
finally, one version where the deprecated feature can be explicitly re-enabled
using flags.  So, why are they doing this?  Dave touched on this in the
newsletter, and I'll quote him, "This avoids an occasional problem where a CLN
feature would be reported as deprecated but continued functioning by default for
a long time after it was planned for removal, possibly leading users to continue
depending on it and making actual removal more difficult".  So, they've
introduced this new deprecation infrastructure to hopefully funnel people out of
certain deprecated features for CLN.  Any comments, Dave?

**Dave Harding**: I thought it was a really clever solution to a common problem.
I'd like to see more software use something like this where you just gate your
features, you put some code around your feature that says, "This is going to be
deprecated in blah, blah version", and that code is automatically applied and
people can still use the feature as long as it's there, but it's really clear
that it's going to stop working, and it stops working automatically at the
indicated version.  I just thought this is really cool, I think more programs
should do this.

_LND #8345_

**Mike Schmidt**: Last PR this week, LND #8345, which adds a mempool acceptance
check before broadcasting a transaction in order to enhance reliability of
transaction broadcasting.  So essentially, LND before it broadcasts anything
will pass to either bitcoind or btcd the transaction to the respective
testmempoolaccept RPCs to make sure that the transaction looks good according to
that node's testmempoolaccept RPC before broadcasting it to the broader network.
Dave?

**Dave Harding**: This is really useful.  One of the problems you have with
Bitcoin and LN is that if you send an invalid transaction to one of your peers,
you know, you have a Bitcoin node and for some reason it relays an invalid
transaction to a peer, maybe there's been a soft fork you didn't know about or
some other reason, that peer learns the content of that transaction and in LN,
some of the contents of a transaction can be security-related information.  It
can be the preimage for an HTLC that controls money.  But if the transaction is
invalid, that preimage could be that transaction's not going to get put in the
blockchain, but the peer still learns that information.  I can't think off the
top of my head of any cases where this could be a serious problem, but it could
be a problem.  Now, if your current node is willing to relay that transaction to
another node, it's going to succeed on the testmempoolaccept, so this is maybe
not the best check here, but I still think it's a useful thing to do to avoid
getting into a situation where there might be some weird case where your node
will unconditionally relay a transaction to another peer that might contain
privileged data.

The other thing that it does, it's a lot simpler, it's not a security issue, but
it's nice, is that you get a better error message from testmempool RPC than you
might get from submitting a transaction directly to the node to be relayed.  So,
it's just a better error message can be surfaced up to the user or used in the
program in a better way.  So, I think this is a good idea.  It costs nothing to
run the testmempool RPC, and later on when we have package relay and things
around that, like v3 transactions, testmempoolaccept in Bitcoin Core already can
consider package limits and whatnot.  So, it'll help you with these multiple
transactions, evaluate, make sure they're correct.  And again, if they are
correct, send an error back to the program before any information has been
relayed over the network.  So, I think it's really useful.

**Mike Schmidt**: And you hope that testmempoolaccept RPCs for each of the
implementations when returning the same for the same transaction, but I guess
that's a different question.  I don't see any requests for speaker access or any
questions, so I think we can wrap up.  Thanks, Eugene and Bastien, for joining
us as special guests this week.  Dave, thanks for co-hosting with me this week,
and next week, Murch is out, and thank you all for listening.

{% include references.md %}
