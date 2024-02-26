---
title: 'Bitcoin Optech Newsletter #225 Recap Podcast'
permalink: /en/podcast/2022/11/10/
reference: /en/newsletters/2022/11/09/
name: 2022-11-10-recap
slug: 2022-11-10-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt discuss [Newsletter #225]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-8-1/345362520-44100-2-8332f9709607d.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome to Bitcoin Optech Newsletter #225 Recap.  I'm Mike
Schmidt, contributor to Optech, but also Executive Director at Brink, where
we're funding Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm very sweaty and in El Zonte’s Hope House and trying to
join the Twitter Spaces from a wonky Wi-Fi!

**Mike Schmidt**: Well, we can hear you fine.  There's no intermittent
connectivity.  A little bit of background noise, but I think we can do it.  So,
let's just jump right into the newsletter.  I shared the link to the thread in
the Spaces so everybody can follow along, if you don't already have it up in
front of you, but a couple of news items that are somewhat rehashing different
versions of what we spoke about previously.

_Continued discussion about enabling full-RBF_

The first one is continued discussion about enabling full-RBF, and the update
for this week was a post from Suhas to the mailing list, which also had an
accompanying PR that was opened, that got a lot of attention from the ecosystem.
Essentially, the PR was to revert the mempoolfullrbf option from the latest
release candidate.  A quick recap, the -mempoolfullrbf flag would default to
False, but would allow node operators to set that to True, which would allow
replacements of transactions that would follow the current BIP125 replacement
rules, but it would allow those rules to be applied to transactions that don't
even signal for that particular replacement flag.

So, Suhas makes the case here, or at least starts to attempt a philosophical
discussion about how we should think about implementing policy and specifically,
mempool-related policy, and he makes a few different notes here, and we can kind
of go through these five notes and then a few questions that he asks.  But he
points out that opt-in RBF is already available; that's point number one.  I
don't think there's anything controversial about that.  The second one here is
full RBF doesn't fix anything that isn't broken in other ways.  And I think when
full RBF was originally thought up, there were some multiparty protocol cases
that may have been helped by allowing RBF for non-opt-in transactions, but
there's been some edge cases that were identified in which actually, that
doesn't completely solve the issue.  There are still issues with those
multiparty protocol transactions that full opt-in RBF does not address.  Murch,
do you want to -- I'll pause here and let you comment on that.

**Mark Erhardt**: I think the problem is more that the way it was represented as
a fix for a certain class of issues around multiparty protocols is incomplete
and not as strong as people thought.  So, whenever you are making a transaction
with multiple people, the other participants can sabotage you by just not
participating.  And the class of issue that this was supposed to fix is that the
transaction of one of the participants gets stuck because they send a duplicate
of the transaction, and the original gets stuck in the mempool of the node that
created it, but it doesn't propagate to the network because the duplicate has
been propagated already.  And they first have to figure out that they are stuck,
and then reset it before they can continue.  And really, the big problem with
multiparty protocol is whenever you have participants that don't actually want
to participate, but sabotage you, you'll have a bad time.  So, we can't really
do much about that and to do away with the opt-out for replaceability over that
seems like an insufficient argument to do away with the opt-out.  That's at
least how I understand Suhas' comment.

**Mike Schmidt**: Yeah, that leads into the third bullet from the newsletter of
takeaways from that post, which is if there aren't any other examples of things
that are fixed by enabling full RBF, then it doesn't seem that full RBF solves
any problems; and thus enabling full RBF is really taking away choice then, all
else equal, so that is a point of consideration that he made that I think you're
echoing.

**Mark Erhardt**: Right.  The other side of this argument is, of course, that
when you take away the choice -- sorry, I'm going to step outside for a moment!
So, the other side of the argument is that if we build up companies and continue
to give the impression that people can have somewhat reliable transactions, even
though they're not confirmed yet, we are building incentives for people to be
against certain aspects of protocol development in order to protect their
business use case.  And I think most developers at least, and many members of
the community, agree that this use case should not have strong clout, because
it's inherently a form of giving credit, and we shouldn't protect a business
model that is based on something that the protocol cannot natively provide.
It's sort of a false promise.  And to prop it up and sort of support this false
promise just makes people that are less plugged in than the current local
proponents of opt-in remaining in place, or actually just full RBF not
happening, it sort of encourages even more business cases to be built around it
and to maybe create a lot of problems down the road, when the subsidy tapers off
and we are relying on more fees in general.

So, especially down the road then, we want the mempool to function as a full
replacement so that financial incentives are the main way that guides us how
transactions get replaced, because fees will be the main the main source of
income for miners.

**Mike Schmidt**: The fourth point that we noted in the newsletter was that
allowing for non-replacement doesn't cause any issues for full nodes.  I think
that's fairly straightforward, but do you have a comment on that particular
point?

**Mark Erhardt**: It doesn't hurt anyone.  It actually makes the case easier
where you might want to CPFP an incoming transaction, because the other party
has promised that they will not be trying to replace it.  So, it might make more
sense to build a transaction that is based on that previous transaction, and not
be worried that it gets replaced otherwise again and needing to figure out how
the transaction graph works out in the end.  I think, if we're honest, in the
long run, people will need to engage with the complexities around transaction
replacements, (a) because we simply cannot guarantee that transactions don't get
replaced, and (b) because eventually we'll probably have a high block space
demand again at some point, and then people will want to use it heavily.  And
all the wallets that are ready at that point will have an edge; all the ones
that aren't ready at that point will have a pretty bad time.

**Mike Schmidt**: So, Suhas also provided a sort of example, or an analogy,
given this proposal for v3 transactions.  And supposing that we had these v3
transactions, are folks being logically consistent in, would they be willing to
support disabling v3 transactions with a flag in Bitcoin Core down the road?
And so, he sort of has a comparison to another type of policy that if we
potentially applied a similar thought process, would we feel the same about
that?  Would we encourage the disabling of v3 transactions?  What do you think
about that analogy?

**Mark Erhardt**: I think that the analogy is pretty good in a lot of aspects.
I think that it makes sense to compare the two, because v3 would also be a thing
that the sender opts-in to restrict themselves.  And it would actually help with
a bunch of the -- sorry, the Jehovah Witnesses are at the meeting!  So, v3 is
also a proposed way of restricting yourself as the sender what you can do with
your transaction.  And in that case, it specifically restricts what number of
descendants you can have and what size the descendant transactions have.  And
it's currently still being developed, it's not done at all.  But it's sort of
testing the waters, how people think in general philosophically about it because
in a lot of ways, if we support full RBF right now, taking away the choice of
people opting out of replaceability, then maybe in the future, people will also
support taking away the choice of people having different propagation rules for
v3 transactions.

So, I think it's at least a good prompt for thinking about the situation.  I am
not 100% convinced that it's a perfect analogy, because with v3 transactions as
they're designed right now, it doesn't look like you can, for example, steal
from the recipient.  It makes it easier for multiparty protocols and then it
uses only multiparty protocols to be bumped.  And the original transaction
cannot be replaced in the first place, because it's already signed by two
parties and they would have to get together to replace it anyway, so there would
necessarily be agreement between the participants of the protocol.  And yeah, so
I don't know.  I think it's a good prompt to think about that.  I'm not sure
whether it's a perfect analogy.

**Mike Schmidt**: Is there anything else that you'd like to comment on related
to either Suhas's post or the ensuing discussion on the PR that he had open for
a period of time?

**Mark Erhardt**: I think that there was a bit of brigading, and I don't think
that it really got the conversation forward.  Altogether, I'm still a little on
the fence because I agree about the long-term incentives, but then on the other
hand I also agree that it seems to have been somewhat stable for the last seven
years.  And if it solves an actual problem for people, then why shouldn't nodes
support other nodes in their request to not allow replacing, like a
self-restriction on transactions?  Sure, everybody should be aware that it
cannot guarantee that the sender didn't send something out of the network
directly to the miners, but yeah, so I don't know.  Both sides don't have
completely convincing arguments from myself, and in that case, I would have
preferred to just keep the status quo for a while to see whether the
conversation evolves and we learn how to better think about it.

**Mike Schmidt**: And the option that we're talking about here is still in the
release candidate, and it appears that RC4 and potentially the final release
will still have that option.  I think we note that there's an RC later in the
newsletter, but I guess it'll be interesting to see whether a substantial
portion of the network and/or miners decide to enable that flag or not.

**Mark Erhardt**: Yeah, I think at this point, the Streisand effect has taken
full hold and the discussion is so present that there will be a bunch of people
that run it.  The question is whether a miner will also.

**Mike Schmidt**: Well, by all accounts, this discussion is ongoing.  I don't
know if we'll have anything for next week's newsletter on this topic, but if
there's anything notable, we can cover that next week.

_Block parsing bug affecting multiple software_

I think we can move on to the second news item for this week, which is a bit,
again, of detail around the block parsing bug that most notably was in BTCD that
we talked about a bit last week.  This gives a bit more detail on that and some
of the story around that.  I think one item that may be inaccurate, depending on
how you look at it, is I think we note here and we tout responsible disclosures
and doing so in a somewhat private manner, but I do believe that when AJ
discovered the bug, that there actually was an issue opened the repo, which was
public.  I haven't actually dug through to find that.

**Mark Erhardt**: Yes, that is my understanding as well.

**Mike Schmidt**: Okay.  Well, I believe the community in general is a fan of
responsible disclosure.  Would you say that that was a responsible disclosure if
that was done that way?

**Mark Erhardt**: No, I think that we could do a little bit of correcting of
that passage in the news.

**Mike Schmidt**: Yeah, it did sound like there was acknowledgments that there
were some conversations offline about that particular bug, but it then came to
light that there actually was public discourse in the form of the issue as well.

**Mark Erhardt**: Yeah, I think that the issue was open for a few days before it
was deleted, and anybody that would have seen that would have known about this
issue of LND.  I think that it is pretty childish to contact a miner out of band
in order to break other software in the network.  I think at least it wasn't
done for financial reasons, but it's just not a -- I hope that people don't take
this as an example.

**Mike Schmidt**: So, Optech also posted a topic page, and we're sort of
encouraging folks who do disclose vulnerabilities in a responsible way to sort
of get rewarded by being put on that topic page when it's something that we
cover in the newsletter.  So hopefully, the fame is a bit of an incentive for
folks to do that responsibly.  I would also note that it wasn't just LND, it was
BTCD, and also The Liquid Federation have watchmen and they use not only Liquid
but also the underlying Rust Bitcoin library, so there were issues in things
other than LND, although I think LND seems to get the most press about this
particular issue.

**Mark Erhardt**: Yeah, I believe the Electrum service broke and Electrs also
had an issue, and there might have been a couple more things.

**Mike Schmidt**: Any more thoughts on the block parsing bug?

**Mark Erhardt**: No, I think in a way, it was very similar to the one disclosed
a few weeks earlier already and I would have thought that the discoverer of this
bug would have learned something from a couple of weeks earlier and not done it
this way, but apparently they learned that they get a lot of attention that way
and then just tried to get that attention again.  And I think, well, I guess if
that's how they are, that's on them, but I wish that other people don't take
this as an example.

**Mike Schmidt**: We have the next section of the newsletter, which is Bitcoin
Core PR Review Club, and this is a monthly segment in which the newsletter
highlights one of the PR Review Club meetings that have occurred in the last
month.  So, PR Review Club is a weekly IRC-based chat in which notes are
provided about a specific PR in the week before the meeting, and there's some
notes and explanation and questions to think about regarding that particular PR.
And then during the meeting, folks go through those questions, ask their own
questions, make comments, give feedback on the PR.  And the idea for that group
is to familiarize technically curious folks, like folks that may read the Optech
Newsletter, how to go about reviewing, how to go about thinking about changes to
the software, and also is a good way to introduce yourself to the various
sections of the codebase.

_Relax MIN_STANDARD_TX_NONWITNESS_SIZE to 65 non-witness bytes_

This particular meeting that was highlighted for this month's segment is a topic
that we actually chatted about with instagibbs a few weeks ago on our Recap
Spaces, and there's two related PRs here.  The one covered in the meeting was
changing the standard non-witness size to 65 non-witness bytes.

**Mark Erhardt**: The minimum, yes.

**Mike Schmidt**: And so, the motivation for why there's any standardness rule
around here is that it was discovered that there could be this spoof payment
attack against a Simplified Payment Verification (SPV) client, in which you
could make a transaction that looked like a proof for an SPV client, and that
could cause issues because those proofs are also 64 bytes.  So, if you could
somehow generate another 64 bytes that looked a certain way, you could trick
these SPV clients.  And the fix was put in to make the minimum size 82, based on
I think that was the smallest standard payment transaction at the time.  Is that
right, Murch, that the original fix was 82 for that reason?

**Mark Erhardt**: Yeah, that's what I understand too.

**Mike Schmidt**: Yeah, and that 82 then covered this potential 64-byte size
attack, but it was done in a way that didn't overtly say, "We're putting in this
restriction to prevent this sort of spoof attack".  And so, that's been merged
and been publicly announced in the past, and now we're at the point where there
are potential use cases for something less than 82 bytes.  And I think
instagibbs is working on eltoo and some other interesting things, in which
there's some scenarios that having something less than 82 bytes would be useful
and valid.  So, the PR that we're covering in the Review Club here was going to
set the standardness rule to 65 from 82, and that would enable some of the use
cases that he's working on, as potentially some other things were also not
allowing for those 64-byte transactions.  Anything to comment on there so far,
Murch?

**Mark Erhardt**: Yeah, so the way the attack works is that basically in a
merkle tree, each inner node has 64 bytes because it's a hash.  And if you
manage to make a transaction that has a txid, or sorry, not a txid, the actual
transaction itself has the exact byte sequence, then people would think that
there is a proof that this transaction had been included in a block.  And so
that way, you could especially convince an SPV client, because they would only
look at a single branch in the block instead of the whole transaction set, and
they'd think that this transaction was in.

**Mike Schmidt**: And so now, I guess now that it's publicly known about this
attack, I guess one rationale for lowering it to 65, or just preventing 64, is
that the attack is known the attack is 64, so why are we restricting 65, 66 up
to 82?  That would just be one, I guess, naïve reason to change that.  But like
I mentioned, instagibbs has some particular use cases that you may want to use
something closer to that 65 limit.  And so, that's why that was originally
proposed.  Then, since that Review Club meeting, the PR was actually closed in
favor of PR #26398, which relaxes that policy even further by only disallowing
those 64-byte-sized transactions, so only preventing that 64-byte attack that
Murch just outlined.  And so, the one that we covered in the newsletter is
actually not a merged PR or one that will be merged; there's an open PR that is
even more lax on those rules.

**Mark Erhardt**: Yeah, exactly.  So the idea is about the anchor outputs that
can be spent with an empty input script, and it would be made with a transaction
that is only 60 bytes in total.  Just a sec.  Can you take it for two minutes?

**Mike Schmidt**: Yeah, absolutely.  We talked about this a bit with Greg
Sanders a few weeks back.  I think he had a proposal that piggybacked on the v3
transactions, and I think it involved an output that was quite small, and I
believe it was just OP_TRUE.  And so it would actually be, yes, less than the
original 65 limit that was proposed in this PR, and actually less than the
64-byte attack, so potentially that's one of the motivations around this updated
PR, is that it would allow for that.  I guess you're saying, Murch, that it's a
60-byte transaction that that OP_TRUE anchor output would be that he's been
experimenting with.

There's a few different questions in this PR review club.  The first one is
about the attack, which we've already discussed.  There's some questions about
what it would take to actually execute that attack in terms of resources.  And I
guess the estimate would be that in order to execute the 64-byte spoof attack
that we mentioned, it would cost something like $1 million to execute the
attack.  So, this is not something that would be easily done.

Another question here is, "Why does setting this policy help prevent the
attack?"  And I think we went through that, because it's got to be exactly 64
bytes, so if we make it non-standard to have a 64 byte, then that mitigates the
attack.  But because this is all policy, this doesn't eliminate this attack
entirely, similar to what we just went over with the BTCD and LND bug, which can
only be exploited by the help of a miner mining a non-standard transaction.
Similarly, even with this policy restriction in place of the 64 bytes, you can
still craft a 64-byte transaction, potentially costing that $1 million to take
out the attack, and then go right to a miner and pay them maybe a little bit
extra to mine your non-standard transaction.  So, the attack can still happen,
but you would need a miner to collaborate with you on it.

Let's see if there's any interesting other questions here.  There's some
discussion about optimal sizes and comparing the two different PRs that we
discussed, but I think we've largely exhausted what is the meat of this PR
Review Club.

**Mark Erhardt**: I don't know if you made this point already, so stop me if you
did, but the point around making a 60-byte transaction is interesting.  There
was an idea how to craft the anchor outputs differently, where you essentially
would have an empty output script and then can spend it, anybody can spend it
and use it to bump, and it would have a value of zero and we would require the
next transaction to also include it.  Like, an output like that cannot be added
to a transaction unless it is spent in the same package, and that way we would
have the smallest possible construct of a CPFP transaction, and yeah, that would
use a 60- or a 61-byte transaction, and that's why we want to make 60- or
61-byte transactions legal on the network.

_Rust Bitcoin 0.28.2_

**Mike Schmidt**: Makes sense.  The first release candidate on the newsletter
this week is Rust Bitcoin 0.28.2, and that's a minor release that contains bug
fixes for some issues that may happen with serializing transactions or blocks.
Digging into some of the commits for this release, there are no transactions
currently that would cause issues here, but it's potential that some of the
checking to prevent resource exhaustion in Rust Bitcoin, some of those checks
may result in consensus incompatibility, and so those checks to prevent resource
exhaustion have been changed such that consensus could be maintained, even in
some of these edge case scenarios that haven't come up.  So, this release is a
fix for that.

_Bitcoin Core 24.0 RC3_

We have Bitcoin Core 24.0 RC3.  I think that's been out for a couple of weeks
now.  I think there's actually RC4 on the way.  But looking at the
bitcoincore.org site, it doesn't look like it's quite ready yet.  There's that
great testing guide that we've touted, so if you're curious, go through the
testing guide.  You can do as much or as little as you want, and feedback is
welcome, I'm sure.

**Mark Erhardt**: That's also only a starting point. And of course, we hope that
more people also have additional ideas what they can test.

_Bitcoin Core #26419_

**Mike Schmidt**: The first PR in the newsletter this week is Bitcoin Core
#26419, which is an enhancement to the logging functionality in Bitcoin Core.
Right now, when a transaction is removed from the mempool, there isn't a reason
given in the logs for why that transaction was removed from the mempool.
Obviously, that may be useful to node operators or developers to see in the logs
why that transaction was evicted, and so this PR adds a little bit more detail
to the error message on one reason or the reason that that particular
transaction was removed.  That could be something about, it's in a block,
there's a reorg, there's a conflict, or it was replaced, and so that those
reasons are now provided in the log output.

_Eclair #2404_

Next PR here is Eclair #2404, and that is Eclair allowing Short Channel
IDentifier (SCID) aliases, and zero-conf channels, which it already has allowed,
but if there isn't an anchor output, you weren't able to do those aliases with
zero-conf channels previously.  So, that was causing issues where folks that
weren't using anchor outputs weren't able to use aliases with zero-conf
channels, and this PR changes that so that you don't need an anchor output in
order to have the aliases working with zero-conf channels.  Any feedback, Murch?
You still with us?  All right.

_Eclair #2468_

Well, the next PR is also Eclair; there's quite a few this week for Eclair.  And
this one is around, so in Lightning, the intermittent nodes on the path routing
the HTLC have different rules than the final node, in that they are allowed to
deviate from the payment amount and the expiry in that HTLC, such that if I'm
routing 1,000 sats, for example, I could pass along 1,001 sats; and if I'm an
intermediate node in that path, then the 1,001, even though it's different than
the 1000 from the request, actually will go through if I'm an intermediate node,
but it will not go through if I'm the final hop.  So, that opens up
opportunities to sort of reveal information about the payment path and are you
the last node in the hop, because if you try that 1,001 and you're the final
one, it'll be rejected because it doesn't exactly match, whereas there's leeway
if you are an intermediate node.

**Mark Erhardt**: Yeah, basically this gives us tools to obfuscate where the
forwarder in the route is.  And especially the second last, like the hop before
the recipient, might be able to guess that the next one is the recipient, either
by seeing that now it's exactly a round amount, or the expiry delta drops
precipitously on the last hop.  And now, this PR introduces that you only have
to meet the minimum, but you could restrict yourselves more; you can send
additional money, or you can have a longer expiration than was requested, and
this helps obfuscate that the last hop is forwarding to the recipient.

_Eclair #2469_

**Mike Schmidt**: And so this #2468 that we just spoke about encompasses the
amount.  And then the next PR is the #2469, which addresses the expiry that
Murch just mentioned.  And so, those are sort of both somewhat related to the
same issue.  And both of those are also related to BOLTs #1032, which is covered
as the last one in the newsletter, which is a BOLT around this particular topic
and to mitigate this type of probing.  So, we kind of hit three birds with one
stone there.

**Mark Erhardt**: Super.

_Eclair #2362_

**Mike Schmidt**: Eclair #2362, add support for dont_forward flag for channel
updates, and that references BOLTs #999.  And so, I don't fully understand the
motivation, but when you provide a channel update, you can provide this
dont_forward flag, and then that's not propagated to the wider gossiping.  I
didn't fully understand the use case of what we're trying to prevent being
forwarded on.  Murch, are you familiar with that?

**Mark Erhardt**: I can only guess.  Maybe we can get a correction later from
some people if I'm getting this wrong.  But as far as I understand, each value
of channel can be updated separately, and each time it requires that you do an
update.  And I'm not sure if you can update multiple values, and if you know
that multiple values are changing, you might just want to say, "Hey, there's
more updates coming, so please don't announce this to the broader network yet,
and let's just get all the updates out of the way and then announce once we have
all the updates".

**Mike Schmidt**: That makes sense.  I think when I was trawling through some of
the PRs, some language around that was also in there, so I think you're on the
right track there.

_Eclair #2441_

Another Eclair PR this week is allowing Eclair to receive onion-wrapped error
messages of any size.  So, currently the BOLT states that you should, but you
don't have to, have a 256-byte error limit, but there's nothing preventing you
from having error messages of a larger size other, than if other nodes have
similar restrictions in place.  So it doesn't actually forbid longer error
messages.  There's actually a PR to encourage the use of larger size error
messages up to 1024 bytes.  So, that PR is open now, I believe.  So, Eclair is
not going to be generating larger error messages, but they will receive these
larger error messages in preparation for larger network adoption of these larger
error messages.  And the point of a larger error message would just be the
ability to include more information in those error messages.

**Mark Erhardt**: Yeah, I think we talked a bit about this last week with Joost
and t-bast, when they told us how larger error messages would be able to encode
the source of the error without revealing to the respondent, the person
reporting the error, where in the chain they are.  And so, if you're interested
in that topic, maybe listen to our recap from last week.

**Mike Schmidt**: Yeah, thanks for tying that together.  Yeah, they had some
good insights on that and were actually the authors of those.

_LND #7100_

LND #7100 basically just updates LND to use that new version of BTCD that has
the correction for the error that we discussed earlier in this discussion, so I
don't think there's anything interesting there.

_LDK #1761_

LDK #1761 adds a PaymentID parameter.  So, my understanding is previously, LDK
used a somewhat random ID that wasn't necessarily something that you could reuse
in the future, and so they sort of settled on this payment ID, which I believe
is just the payment hash, such that you could rescind and also abandon, it used
the rescind or abandon methods on that particular payment hash.  And I guess
it's just a more solid ID to use versus what was being used more internally and
ephemerally previously.  Murch, did you get to dive into LDK #1761?

**Mark Erhardt**: I did not, but I have an idea.  So, usually when you make a
Lightning payment, you create an invoice, and the payment has to exactly pay
that invoice and it is unique, it can only be used once.  But you can also do a
zero-amount invoice, or I think you can also encode that in a Lightning address.
But either of those allows the sender to send a freely picked amount to the
recipient.  And in that case, of course, when you retry multiple times, you
might have a try that gets stuck, or you shouldn't accidentally make the payment
multiple times.  But either way, this would allow you to disambiguate whether
this is the same payment process or a repeated payment of the same amount.

**Mike Schmidt**: Exactly.  Thanks, Murch.  We have just a couple more PRs, so
I'll make a quick call for any questions or comments or corrections.  So, feel
free to raise your hand or request speaker access if you have a question or
comment, and we can get to those in a couple minutes.

_LDK #1743_

The next PR here is also LDK.  So, LDK is an event-driven architecture, and this
adds a new event to that architecture, which is a ChannelReady event, and that
gets fired when the channel becomes ready to use.  So, that could be after a
specific number of confirmations, or if you're doing zero-conf based on your
settings, you'll get this ChannelReady event that you can, in your wallet or
whatever you're using LDK for, you can get that notification via that event.
Anything there, Murch?

**Mark Erhardt**: No, I guess not, no.  It's pretty obvious why you would want
to know when your money is ready and deployed, because you might start creating
invoices that make use of the liquidity or make payments.  So, having not only
the first confirmation but a bunch of such makes it easier to automate processes
around using LDK.

_BTCPay Server #4157_

**Mike Schmidt**: There's a BTCPay Server PR that was notable this week, and
it's an opt-in support for a new checkout interface.  So I think the BTCPay team
has been keeping a log of potential usability improvements to the checkout page,
and this PR addresses those usability improvements and hides it currently behind
an opt-in setting, where you can turn on that new interface, and you can check
out the PR link from the newsletter to see some screenshots.  I think there's a
video in there as well.

_BOLTs #1032_

The last PR here was one that we referenced earlier.  So, we talked about Eclair
implementing those changes to accept a greater amount and a longer expiry, to
prevent forwarding nodes by knowing that they're the last node in the hop.  This
is the BOLT equivalent of that to make that change to the spec.  And so, that's
what BOLTs #1032 is, so we discussed that previously.

All right, well, enjoy your trip, Murch.  Have fun down there and thank you all
for joining us and we'll see you next week when we talk about Newsletter #226.

Cheers.

{% include references.md %}
