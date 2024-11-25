---
title: 'Bitcoin Optech Newsletter #328 Recap Podcast'
permalink: /en/podcast/2024/11/12/
reference: /en/newsletters/2024/11/08/
name: 2024-11-12-recap
slug: 2024-11-12-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Gregory Sanders discuss [Newsletter #328]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-10-22/390293648-44100-2-a952a0a12ecc8.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mark Erhardt**: Good morning, today is 12 November.  This is the Bitcoin
Optech Newsletter Recap #328.  Today we have one news item, a Bitcoin Core PR
Review Club, and two Releases and, well, both releases actually, and then only
two Notable code changes, both from the LDK.  As you can hear, I'm not Mike.
This is Murch using the Bitcoin Optech account today.  Mike can't be here today,
but I'm happy to report that Greg was able to join me, so the two of us will get
you through the newsletter today.  So yeah, I'm Murch, I work at Chaincode Labs
and, instagibbs?

**Greg Sanders**: Hi, I'm instagibbs, I'm at Spiral.

_Disclosure of a vulnerability affecting Bitcoin Core versions before 25.1_

**Mark Erhardt**: Cool, so for our News item today, we're going to talk about
another disclosure of a vulnerability in Bitcoin Core affecting versions before
25.1.  This is the last round of the catching-up disclosures.  As we reported
previously, in Newsletter #306, there's a new disclosure policy in Bitcoin Core,
where now all of the vulnerabilities are intended to be disclosed two weeks
after the last vulnerable version went end-of-life.  And so, if you're
unfamiliar with the release lifecycle of Bitcoin Core, there's two maintained
versions and then there's one that is in maintenance end.  So it got one more
update, and it's not completely obsolete yet, but it will not get any future
updates probably.  And once it goes out of that maintenance end into
end-of-life, all vulnerabilities up to the 'high' classification are disclosed.
'Critical' ones are an ad hoc process and may be different.  So, we've been
seeing a bunch of these in the last half a year or so, and this one specifically
is talking about a P2P protocol issue.

If you announced a block to a 25.0 or earlier peer and then just left the node
hanging and don't give him the missing transactions from a compact block
announcement or don't give him the block at all, they would wait for up to ten
minutes and basically just trust the first node that announces it to them that
they would eventually come through.  And if the peer that announced the block
doesn't come through, then it just waits for ten minutes and doesn't try to get
the block otherwise.  This was fixed in 25.1 by allowing parallel requests.  So
if other high-bandwidth compact block relay peers announced a block to us, we'd
say, "Hi, I've been waiting a bit for the block from someone else, but fine,
I'll take it from you instead".  And so, instagibbs, do you have some thoughts
on this one?

**Greg Sanders**: Yeah, that's a good recap of the issue.  So basically the
mitigation is, once your node is kind of warmed up and has selected some peers
that are high-bandwidth peers, then it's largely mitigated, especially if you
assume you have -- there's one high-bandwidth peer that will always be outbound,
your node will always pick one outbound as a high-bandwidth peer.  And generally
speaking, those are more under your node's control on choosing who an outbound
is, so that's kind of a protective measure.  This happening, the network
slowdown, was also in conjunction with a bunch of other issues, which basically
if the mempool is pretty quiet, this issue doesn't really happen, because if you
already have all the transactions in your mempool that you need for the block,
then you don't need to do a round trip anyways.  And so, if a second peer
announces a compact block and you can fill out the entire block yourself, then
you just take that block immediately.  So this really happens when the mempool
is busy and there's lots of replacements happening, or maybe out-of-band things
happening as well.

**Mark Erhardt**: So could you clarify, this only happens after a compact block
relay announcement, or generally on block announcements?

**Greg Sanders**: So, the issue is when someone advertises either a header or a
compact block and then doesn't respond, for whatever reason, to your request for
the rest of the block.  The good news is, with a compact block, is if you have
all the transactions in your mempool already, then you don't have to ask for
anything.

**Mark Erhardt**: Right, because basically a compact block announcement is the
recipe how to reconstruct the block from your mempool.  So, the issue where we
saw this actually happen in the wild was, there was a lot of block space demand
and transactions got submitted faster than nodes would relay them, so the relay
queues would grow quickly.  And this is another vulnerability report that was
mentioned earlier this year.  And in that case, you would be more likely to have
a heterogeneous mempool, where you're missing some of the things that would be
in the next block because you haven't heard about everything yet.  It would just
exacerbate the need for round trips, right?

**Greg Sanders**: That's right.

**Mark Erhardt**: Yeah, okay.  Anyway, so 25 obviously came out more than
one-and-a-half years ago, 25.1 probably within a few months of that.  This is
not super critical, it would just make you get the chain tip a little slowly.
But if that is a concern to you, I hope you have upgraded to one of the
maintained versions since.  Going forth, now that we're caught up, Bitcoin Core
will release disclosures two weeks after the release of the version that
obsoletes a branch, and we'll therefore expect vulnerability reports roughly
every half year.  Okay, do you have anything else on this?

**Greg Sanders**: No, we're good.

_Ephemeral Dust_

**Mark Erhardt**: Cool.  We're moving on, and you'll notice soon why I asked
Greg to be my guest today.  We are going to the section, Bitcoin Core PR Review
Club, and the PR that was reviewed here is the Ephemeral Dust PR by Greg.  So,
ephemeral dust is a concept where we usually don't allow outputs with tiny
amounts to be created, but here we are loosening the policy to allow it in one
specific case, which is it's fine to create dust if you immediately spend it.
So, ephemeral dust introduces a loosening of policy rules under specific
circumstances, namely the parent transaction has to have a fee of zero, so there
is no incentive to include the parent transaction by itself, therefore it is
unlikely that the dust output will linger in the UTXO set.  And only if the
parent transaction has a fee rate of zero, you are allowed to create an output
that has an amount that is below the dust amount, because the expectation is, of
course, it can only enter your mempool if it's accompanied by a child that
brings the fees.  So, this PR implements the policy changes in Bitcoin Core.
And we have five questions in this PR Review Club.

So, I already gave away part of one, "Is dust restricted by consensus?  Policy?
Both?"  How do we want to do it?  Do you want to give the replies, or should I
just go through it?  Do you want to jump in?

**Greg Sanders**: I guess I can go through it.  So, just one at a time.

**Mark Erhardt**: Sure.

**Greg Sanders**: Yeah, so dust outputs are a policy-only thing.  They were
implemented pretty early in the network's lifespan, but they're not a consensus
thing.  So, zero-value outputs are valid to enter the UTXO set and valid to
spend.  So, this is just a policy thing.  Miners can already do whatever they
want.  Some miners, from what I understand, already mine dust if you ask them
to.  And so, we're trying to basically loosen policy, but also encourage good
economic behavior.

Dust can be problematic.  Really the only reason we care about dust is that
Bitcoin Core and btcd and other implementations maintain a UTXO set, so a data
structure that keeps track of all the unspent bitcoin that have been created.
And you can imagine that if you're allowed to make zero-value outputs, that
there's a lot of cases where if it enters the UTXO set, there's no reason to
sweep it later.  Maybe there's no way or no reason to.  So, encouraging outputs
to have at least a certain satoshi value means there's some incentive to clean
it up if feerates go down.

**Mark Erhardt**: Right, and in the context here, of course, the UTXO set has
been growing pretty drastically, especially in the last one-and-a-half years.

**Greg Sanders**: That's right, yes.

**Mark Erhardt**: So, I think the dust policy is actually paying off.  At least
we've seen some people clean up their tiny UTXOs now that the feerates have come
down a little more.

**Greg Sanders**: That's right.  Third question, "Why is the term ephemeral
significant?  What are the proposed rules specific to ephemeral dust?"  I think
you already kind of went over this, but ephemeral just means in your mempool
view of the UTXO set, you'll basically be creating no dust.  That's it.  And you
already talked about these rules.

**Mark Erhardt**: Yeah, I think it's really important.  So, we want to maintain
the dust rule, we want to keep people from putting dust into the mempool,
especially now that a lot of people have started having out-of-band reasons for
creating UTXOs with permanence.  And so, we want them to tie up at least a
little funds as a mechanism to prevent UTXO set growth.  But if they are
creating it in these circumstances and it's going to be immediately spent,
there's no way of creating it without spending it, then it might be fine.

**Greg Sanders**: Right.  And so, there are at least two reasons I know of these
days where you want to make something that's zero value or low value.  One is
what we call an anchor output, which means you're basically finding a way to
spend -- you bring the fees for the package in the child transaction itself, so
that fits naturally in that mold.  And the second, if you read up about Ark or
similar constructs, they have a thing called a connector output.  And a
connector output is an output that needs to exist for this kind of fair-trade
thing.  So once this output exists, then the operator can then spend a
pre-signed transaction, because now it exists.  And so, these kind of things
could also, in certain circumstances, fit in this paradigm.  And there's
probably more use cases too, but these are the two I know about that are kind of
the major motivators.

**Mark Erhardt**: Right, cool.  I think we kind of covered already, "Why is it
important to impose a fee restriction?"

**Greg Sanders**: Yeah, you can think about more, I think there's some confusion
on this.  But yeah, it becomes difficult.  If you don't have these tight
restrictions on it, there are plenty of obvious ways where dust gets mined.  And
it's just easier to think about with these simple rule sets that this kind of
invariant is held, that anything your node considers dust, whatever dust level
you have set, is being respected at all times.

**Mark Erhardt**: Cool.  Coming to the last question, "How are 1p1c relay and
TRUC transactions relevant to ephemeral dust?

**Greg Sanders**: Right.  So, this naturally fits in if you have been keeping
track with Bitcoin Core 28.0.  There's 1p1c (one parent, one child) relay as
well as TRUC (Topologically Restricted Until Confirmation), and the TRUC
transaction allows your transactions to be zero-fee, individually speaking.  And
later, cluster mempool will allow this too, but for now this is the case.  And
this fits neatly in this, because if you're using dust as an anchor, or even as
a single parent transaction, single child transaction, kind of connector output
system, that this fits neatly in this new paradigm.  So, if you have a single
bump you want to do, you can spend a zero-value anchor output and bring the fees
in the child.  And this will actually relay on the network today.

**Mark Erhardt**: Right, but it will only relay if the parent, and therefore
also the child, are labeled v3 to make the TRUC transactions rules apply to
these transactions.  Otherwise, we will not permit a transaction with a zero
feerate, right?

**Greg Sanders**: That's right.  Yeah, you can set your node to say, "I don't
need any fees for anything", but then you're trivially DoSsable.  So, the real
solution is, if you want to use it outside of a TRUC circumstance, you're going
to have to wait for cluster mempool to roll out, which has all this stuff fixed
as well.

**Mark Erhardt**: Well, to be determined.  It's still a proposal, right.

**Greg Sanders**: Okay, yeah.

**Mark Erhardt**: Okay, so that was the PR Review Club.  The topic was ephemeral
anchors.  Do you have anything else on this?  I think we're good, right?

**Greg Sanders**: We're good.

_Bitcoin Core 27.2_

**Mark Erhardt**: Cool.  So, we'll move on to Releases and release candidates.
I'm pretty excited about one of those.  So, one is just Bitcoin Core 27.2, which
is a maintenance update for the 27 major branch.  So, this is just a few
backported bug fixes in P2P re-indexing behavior and PSBTs and CI and build
system.  If you're, for some reason, still on the 27 branch, you might want to
upgrade in order to have the latest fixes.  Other than that, we're currently, of
course, past the 28 release, which is the latest major branch, and we're working
on the 29 release for April.

_Libsecp256k1 0.6.0_

The one that I'm more excited about today is Libsecp256k1 0.6.0.  It's a new
release of the crypto library that we use in Bitcoin Core, and I think that's
also used in other Bitcoin projects.  And the awesome thing here is, it releases
the MuSig module, which adds support for BIP327, the MuSig2 BIP.  So, if we've
been waiting for creating transactions with multiple signers that look like
single-sig, the libsecp library is now up to date to serve that, and I know
there's already work on a PR to add MuSig2 support to Bitcoin Core.  I know
there's a bunch of other projects that are a little ahead of Bitcoin Core in
that regard, or are sort of in sync with it.  But yeah, libsecp now supports
MuSig2.  This also means that the people that had been working on MuSig2 support
in libsecp are now freed up to take another good look at the libsecp changes for
silent payments.  So hopefully, that will move along a little faster too.  Greg,
you got something on this?

**Greg Sanders**: No, just it's a long-awaited release.  I know there's at least
a couple projects, like I think Eclair was waiting on this for their Phoenix
wallet and Eclair system.  So, I think people are excited about this.

**Mark Erhardt**: Yeah, I'm very excited.  I'm sure other people are, too.
Okay, cool.  Then we already get to the last section today, Notable code and
documentation changes.  We've got two of these today.  If you have any questions
or comments, ask for speaker access or leave a comment on our tweet, so we can
respond to your questions.

_LDK #3360_

So, the first one is LDK #3360.  This one adds rebroadcasting of channel
announcements every six blocks.  And I dug around a little bit in the PR.  So,
some other unrelated changes apparently obsoleted the previous method that was
causing LDK to rebroadcast channel announcements.  They would always get
reannounced whenever a peer connected to LDK.  But since that wasn't happening
anymore, this is sort of a replacement to make sure that if the first
announcement didn't take, there will be further announcements, and LDK will now
announce channels every six blocks for one week after a public channel is
confirmed.  All right.  I assume you are going to jump in if you have something,
right?

**Greg Sanders**: Yeah.  You did a good job.

_LDK #3207_

**Mark Erhardt**: Finally, we have LDK #3207, and this introduces support for
including invoice requests in the async payments' onion message when paying
static BOLT12 invoices, while you're always online as the sender.  So, I didn't
really know exactly what this was about, so I dug around a little bit and found
out that, of course, you have sufficient information to make the payment once
you receive the BOLT12 static invoice, and that could be served out of band or
for an LSP or in other ways.  But the reason for including an invoice request in
your payment onion, so you are already creating the payment but you can sort of
attach a note to this receiver, or tell them which pubkey your node has in order
to authenticate, or let them know who actually paid them, because that
information would otherwise not necessarily exist.  So this is, I think, part of
the async payment push, where LDK especially is spearheading what to do when you
have a node that is only temporarily online and you want to pay them, so you can
sort of have a payment waiting when they come back online.  Yeah, anyway, that's
all I have on that one.  Do you know more about this?

**Greg Sanders**: Unfortunately, no.

**Mark Erhardt**: Well, I don't see any questions or comments so far.  We have a
pretty short newsletter today.  So, I guess we're already at a wrapping point.
Thank you very much, Greg, for joining me, and I hope to hear you next week
again.  That's all for you.

**Greg Sanders**: Thanks for having me.

**Mark Erhardt**: Thanks, bye.

{% include references.md %}
