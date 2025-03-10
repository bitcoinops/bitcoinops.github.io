---
title: 'Bitcoin Optech Newsletter #342 Recap Podcast'
permalink: /en/podcast/2025/02/25/
reference: /en/newsletters/2025/02/21/
name: 2025-02-25-recap
slug: 2025-02-25-recap
type: podcast
layout: podcast-episode
lang: en
---
Dave Harding and Mike Schmidt are joined by Bastien Teinturier and Joost Jager
discuss [Newsletter #342]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-2-3/395880172-44100-2-cfaf13cfa771d.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #342 Recap on
Riverside.  Today we're going to be talking about zero-fee commitments for
mobile wallets, updates on discussion around a quality of service flag for LN,
and we have our monthly Changes to client and service software, highlighting
eight interesting ecosystem software updates this week, and we have our regular
Notable code segment.  I'm Mike Schmidt, Contributor at Optech and Executive
Director at Brink, and this week I'm joined by my co-host Dave Harding.  Dave?

**Dave Harding**: I'm Dave, I'm co-author of Optech Newsletter and the third
edition of Mastering Bitcoin.

**Mike Schmidt**: Bastien?

**Bastien Teinturier**: Hi, I'm Bastien, I've been working on the LN on
specification and implementation.

**Mike Schmidt**: Joost?

**Joost Jager**: Hi guys, I'm Joost, I'm a Lightning Developer and currently
working at Spiral on LDK.

_Allowing mobile wallets to settle channels without extra UTXOs_

**Mike Schmidt**: Excellent, thank you both for joining Dave and I this week.
Starting with the News section, "Allowing mobile wallets to settle channels
without extra UTXOs".  Bastien, you posted to Delving that you were working on a
new channel type for the BOLT spec for zero-fee commitments using v3
transactions, and we covered some of that discussion in newsletter 340 under the
news item, "Trade-offs in LN ephemeral anchor scripts".  And we had you on in
the 340 Recap as well to discuss that.  But in this post, you're noting that
some of the same commitment format can be tweaked for mobile wallets.  Can you
talk a little bit about that?

**Bastien Teinturier**: Yeah.  So, one of the main issues that mobile wallets
have is that we want to make sure that mobile wallets have as small stress
requirements as possible on their LSP, basically.  But usually, mobile wallets
don't have access to whole onchain wallet, they don't keep onchain funds around
to be able to do CPFP, for example, and that kind of stuff, because otherwise it
would be much harder to have a very basic flow where you onboard on LN by
creating a channel and putting all your funds in that channel.  But you would
also have to keep some funds outside of the channel that you are not allowed to
use for payments and are only there for safety, which is really hard to explain
to users and really not elegant at all.  Ideally, we would want to always be
able to use the channel funds.  If you have funds in the channel, use that to be
able to pay the onchain fees, because those are actually bitcoin.  So, ideally,
you would just need to use them to be able to potentially get them back if the
counterparty is trying to cheat.  But we are quite limited by the kind of lack
of flexibility in sighash, covenant-y things to be able to do that.

So, there are cases where, when you publish your commitment transaction because
your counterparty is trying to cheat, it potentially doesn't pay enough fees
today with the current schemes, and in the next schemes where we use zero-fee
commitment transaction, it will definitely not pay enough fees, because it won't
be paying any fees, and fees are supposed to be paid by doing CPFP.  So, what I
started doing in that post is summarizing the actual cases where a mobile wallet
user is at risk, which are different from what happens for a routing node.  The
exposure for mobile wallets is smaller than for LN nodes, which makes it
possible to find good ways of mitigating that.  And basically, the only way an
LSP can steal money from their users is when the user receives an HTLC (Hash
Time Locked Contract), reveals the preimage because they want to accept that
payment, and then the LSP goes silent.  At that point, the only way for the
mobile wallet user to be fully safe would be to broadcast their commitment
transaction, and then broadcast an HTLC success transaction that claims the
funds onchain and reveals the preimage, which they have already revealed to the
LSP.

But the issue is that if we're using the zero-fee commitment proposal, as
detailed in the spec, both the commitment transaction doesn't pay any onchain
fees and the HTLC success transaction doesn't pay any onchain fees at all
either.  So, none of those pay onchain fees, which means that to get them
confirmed, you would need to use another onchain UTXO to be able to pay the
fees.  So, what I'm suggesting here is that in this small variant, the LSP, when
they provide signatures to a user, when they add the HTLC, when they forward the
HTLC to a user, they sign the normal version of the HTLC transaction that
doesn't pay any fee.  But they also sign a variant that pays fees that match the
current feerate for both the HTLC transaction and its parent commitment
transaction.  So, this way, if the mobile wallet user sees that the LSP is
trying to cheat because they are not responding to them revealing the preimage,
they can immediately publish this commitment transaction and the HTLC success
transaction that is paying some fees, and this package of two transactions will
be paying enough fees, should be paying enough fees, to actually get the
transaction confirmed and protect the user from a cheating LSP.

So, there are a lot of small caveats that in order to be sure that you are
perfectly secure, you need to have a somewhat reliable feerate estimation to
judge the feerate of the transaction that you receive from the LSP.  And on the
other side, the LSP should not propose a fee that is too high for the user,
because otherwise user can potentially later steal the fee amount by publishing
revoke commitment, if they got the channel state into a specific state where
they can exploit it.  So, there are small trade-offs here and there but overall,
it's a major improvement compared to what we have today, where mobile wallet
users are basically just relying on the feerate that is currently set on their
commitment transaction, and is usually quite low, and wouldn't allow them to get
the transaction confirmed today.

**Mike Schmidt**: So, there's this additional signature from the LSP,
essentially the LSP's saying, "Hey, I'm not going to cheat".  Well, maybe they
have a reputation already, but they're also providing them this additional
signature so that fees can be paid in the case that maybe they don't cheat, they
just go down, or there's some issue with the LSP, the mobile user can retrieve
those funds.

**Bastien Teinturier**: Yes, exactly.  And also, that's the case where the LSP
does not steal funds from the user, but just griefs them by not letting them
access their funds when they are sending outgoing payments.  And this is the
same, this can be settled by publishing the HTLC transaction that has some
funds.  And the only case that is somewhat not ideal and not really covered is,
when the channel is completely idle, there are no pending payments.  At that
point, the commitment transaction is not paying any fee and we're not changing
anything related to that.  So, if the LSP just disappears entirely without
having the opportunity to close the channels they have with their users, then
the users are left with a channel that they cannot force close on their own.
And in that case, they will need to import that channel into an onchain wallet,
where they would need to be able to pay the fees.

This is doable by having a wallet just do CPFP on that commitment transaction,
and since there are no funds at stake at that point, there's no rush in getting
that transaction confirmed, there's no need to modify the protocol for that.
It's not ideal but hopefully LSPs will never disappear like that without having
the opportunity to publish at least their commitment transactions.  So, since
this is something that should almost never happen, it's okay if we have a not
ideal situation that requires a kind of manual thing to do for the wallet users
to recover their funds, as long as the funds are safe and they have a procedure
to be able to recover the funds.

**Mike Schmidt**: Dave or Joost, do you have any follow-up questions or
comments?

**Joost Jager**: Yeah, Bastien, I was wondering, the zero fees have supposed to
get rid of a lot of complexities.  To what extent is this keeping complexities
on board then?  It's a lighter problem than what's currently the situation in
LN?

**Bastien Teinturier**: Yeah, it is much lighter because all the things I just
described already apply today, on top of the existing complexities of update
fee, because usually what happens today is that all mobile wallet users have a
commitment transaction that is paying 1 sat/byte, which is potentially not
enough.  If your LSP wants to exploit it, they will exploit it at a time where a
1-sat/byte feerate will not get your transaction included.  So, you already have
this issue, but we're just not dealing with it.  So, we'll start to have to deal
with it, because when it becomes zero fee instead of 1 sat/byte, it becomes
never possible to publish it.  But that's actually a complexity that we should
already be handling somehow, and we're just kind of ignoring.

**Joost Jager**: I see.  And do you think there is something to be said for
signing a series of transactions with different feerates, or is that not going
to work?

**Bastien Teinturier**: The thing is, I'm not sure it's helpful.  The only thing
it would do is it would potentially save a bit of fees for the user, because
since the LSP is taking a risk that the user potentially later steals this
amount by using a revoke commitment, if the user cheats, they will use the
highest feerate transaction you have ever signed.  So, why do you need a lower
feerate transaction than only this one?  I think you only need the highest one
that the LSP will decide to sign, which should be a feerate that works now.  And
so, the signing multiple would only make sense if you sign lower feerate
transactions, which we could do, because the user could start with lower feerate
transactions and then go up until they reach the highest one.  But I expect that
most users, at least the default behavior on mobile wallets, since you don't
have a node, you are just broadcasting transactions and just looking at whether
they confirm or not and users are most of the time offline, most mobile wallets
would just directly publish the highest feerate one in order to make sure that
they have a highest likelihood of getting the transaction confirmed.  So, maybe
we can use multiple but I don't really see the point.

**Joost Jager**: Yeah, but isn't that like you're talking about the highest and
the appropriate feerate, but there's a time in between where mempool can look
totally different?  So, to be fully safe, don't you need to pick a really,
really high rate here, and then it might make more sense to also have lower
feerate ones?

**Bastien Teinturier**: But the LSP cannot take the risk of picking a really
high feerate, because that's an amount that the user can potentially steal in
the future.  And the reason we don't have what you're saying about the fact that
it can potentially be later, is that the only time where funds can be stolen is
when the user receives the HTLC with a signature for that transaction with a
higher feerate.  That's exactly when they will reveal the preimage.  Mobile
wallets don't wait before revealing the preimage.  So, if there's an issue, it's
going to happen now, and they're going to broadcast right now, or almost right
now.  So, there's no delay in broadcasting that transaction.  So, that's why
just using the feerate that applies now makes sense.  And it should be hard to
exploit it by using a feerate that seems to apply now, but will not work in five
minutes, and will not work for the next part of the day.  Or at least, it should
not be easy to predict or manipulate for the LSP that they can do that, and do
that at scale for many users, enough users, for it to be a viable business
basically or economically viable.

**Joost Jager**: I see.

**Bastien Teinturier**: T-bast, was there any other feedback in the Delving
thread that you thought would be notable for the audience?  I think we've
summarized all the important points.  We discussed it during yesterday night's
LN implementation meeting and people seem to be on board with that idea, but
we're not ready yet to implement it because first we have to implement the
official BOLT version, and then we will work on that one for mobile wallet.  So,
there's still some time before this actually gets implemented and shipped.  So,
we have time for people to potentially chime in with more improvements or a
different way of achieving that.  But if nobody chimes in and we still think
it's acceptable in, I don't know, maybe six months-plus, then that's probably
going to be what mobile wallets start implementing with the latest version of
commitment formats.

_Continued discussion about an LN quality of service flag_

**Mike Schmidt**: I think we can wrap up that news item.  We have another LN
news item this week, "Continued discussion about an LN quality of service flag".
Joost, way back in Newsletter #239 from February of 2023, we covered your
Lightning-Dev mailing list post about adding this quality of service flag.  And
recently, you posted to Delving to revisit the idea in a post titled, "Highly
Available Lightning Channels Revisited, ROUTE OR OUT?"  Would you mind recapping
the original idea for us?

**Joost Jager**: Yeah.  So, the original idea for us, how it was born is from
this vision where a future LN doesn't have any failures anymore, like where
failures are a very rare thing to happen.  And if that is the case, so if it is
the case that any routing node that you select just works, there's always
liquidity, there's always a success, there's no retries, then it would make it
much easier to apply penalties.  Because today, applying penalties is not an
easy thing.  There's these probabilistic models, all kinds of flavors of that.
It's very hard to validate them because it's difficult to do it on a real
network using A/B test.  And if you make simulations, there's always a
discussion whether the simulation is realistic enough, yes or no.  But if all
those routing nodes are so perfect, then you can keep it much simpler.  Like, if
there is a failure, you just penalize the nodes in such a way that you will not
use that node, let's say, for another month and just move on.  You can afford to
penalize so heavily because there are so many other nodes that still provide
excellent service.

So, this is the basic idea where this comes from.  If this would be the
situation on network today, all this pathfinding code and what LND, for example,
calls 'mission control' and LDK has called 'a scorer', keeping track of node
scores would be much, much simpler.  And the interesting thing here is, when
senders would actually apply those heavy penalties, this would make an impact on
the behavior of routing nodes.  Because currently, routing nodes can still
permit themselves to fill occasionally, because they are not banned for a full
month.  But if it would be much stricter, those routing nodes might be
incentivized to provide a better service.  There is this dynamic between senders
and routing nodes that together shapes the quality of the network as it is
today.  What did I want to say about this?

The problem is only you cannot just switch overnight.  If tomorrow every sender
would just penalize every node for a month that doesn't deliver, then very
quickly you run out of nodes and you cannot make any payments anymore.  And that
is where this flag, this ROUTE OR OUT flag, high-availability flag, comes in.
It allows routing node operators to signal what the quality of service is that
they provide, and then senders can verify whether this level is actually reached
and apply a penalty accordingly.  So, if a node doesn't advertise this flag,
it's not making many promises, it's probably also cheaper, so the penalties
don't need to be as harsh.  Whereas if a node does flag this, they are probably
going to attract a lot more traffic because they are advertised to be reliable.
But then, if they do not deliver, there will be the severe penalty and they will
be out for a while.

**Mike Schmidt**: You mentioned in the future, if we have a near 100% routing
success rate, you can apply this penalty.  And then, it sounds like the quality
of service flag is a way to flag, "Hey, I believe that I'm able to route with
high success, so punish me accordingly if not", so you get the benefits of
people maybe routing through you because you claim that you're able to
successfully route to a high percentage, but then you're penalized then if you
don't.  Do I have that right?

**Joost Jager**: That's correct, yeah.

**Mike Schmidt**: Okay, what's feedback been to the idea?

**Joost Jager**: Yeah, feedback is, as far as I remember, more or less similar
to a few years ago.  People are worried that this would create two classes of
nodes, where senders would just take the easy path and only select the
high-quality nodes.  And this would be a centralizing force on the network
because it's only the bigger nodes that might be able to provide this level of
service.  And I think one counter argument to that would be that senders now
also need to obtain additional information about reliability of nodes because
they cannot all probe the whole network themselves to find the good nodes.  So,
what could happen is senders downloading lists of nodes that have proven to be
reliable and just preferring those while pathfinding.  And you could argue that
this is a worse solution than nodes advertising the signal and senders just
figuring out by themselves which nodes they want to use.

**Mike Schmidt**: Bastien, I didn't see you comment on this thread and I don't
know if you've had time to investigate the idea, but do you have initial
thoughts?

**Bastien Teinturier**: Yeah, I haven't really made my mind entirely about that
yet.  I see advantages and disadvantages on both sides.  The thing is, one of
the things I'm thinking is that if we get to a point where nodes are able to
have that guarantee, that means we don't really actually need the flag, because
if we have enough nodes that are available enough, you would just discover them
on your own, and just through retries, payments would already work well enough
that you don't really need to signal anything.  But it's hard to evaluate how
true that is or not.  And I'm a bit afraid as well of having more explicitly two
types of nodes, like nodes that are professional and the rest of the network
that nobody uses, and the centralizing force behind that.  But it's the same,
it's really hard to evaluate how much of an issue it is.  So, that's why I
haven't really made up my mind on that one.

**Joost Jager**: It's definitely for the transitional periods, but maybe it
would be the case if this flag would exist today, that routing nodes would try
to do a better job improving the overall quality of the network, trying to stick
on that HA batch and just see if they keep up that level of service.

**Bastien Teinturier**: But even without the HA, even without this flag, they
already have an incentive to do a great job because they're only paid if they
attract payment, and they only attract payment if they are reliable enough.  So,
I think there's already some incentive in that direction, maybe not enough, it's
hard to tell.  But I think there's already incentive to make the network
progress towards a more reliable network, but it's just maybe harder to discover
the nodes that are actually unreliable.  But that's why I think things like
Trampoline help, because you are centralizing pathfinding through some nodes but
without revealing too much information to them so that you keep your anonymity,
and those nodes have enough information about which channels are actually
reliable or not, because they are relaying a lot of payments.  But that is also
a centralizing force in a way.

**Joost Jager**: Yeah, that's another way to go about it indeed.  I think one
thing that might be interesting to mention is this idea of just appending HA to
your node alias.  So, in a way this could already happen today without any code
changes.  Node operators could just append something to the alias to signal that
they think they are high availability, even without that properly being defined,
just what they think is high quality.  And if those nodes would start appearing,
then it's probably a matter of time before someone patches their sending nodes
to prefer those and apply that penalty.  I have no idea how to bootstrap this,
whether routing nodes would actually be interested in doing it.  And I also
agree to you, Bastien, that it's very hard to predict what comes from these
initiatives.  It's such a dynamic, organic system where you're interfering with.

But what I do think, also generally speaking about LN, not implementing
something because it might be bad for some reason, to me, that always feels a
little bit difficult.  Because on the other hand, I would say, okay, if it's
bad, let's just do it, because then we can see if we are resilient to this
thing.  In the past, we have, for example, had this discussion about hodl
invoices as well; they would lead to a lot of stuck HTLCs.  In the end, it was
implemented and now it's sort of dealt with.  So, especially because it's still
early stages for LN, to just go for these things and just see what happens, see
it more as a playground than something that is so serious that there's risk in
implementing certain things.  But this is more like a general thought about,
like, what do you want to work on in Lightning?  I'm generally not very
sensitive to not trying to not implement something because it may lead to bad
behavior, because that will probably surface at some point in the future anyway.

**Bastien Teinturier**: I think that it's true about when you consider that it's
potentially leading to bad behavior, it just gets down your priority list
compared to other stuff you have to implement, and that's the main reason why it
doesn't get implemented, is that it just gets more to the bottom of the priority
list.  Because if we had enough time to implement all the things we want to
implement, I think this wouldn't be a good enough reason to not deploy, not try
this stuff.  I think rather that it just becomes less higher priority, and
that's why it just doesn't end up getting implemented.

**Joost Jager**: Agreed.

_LDK #3562_

**Mike Schmidt**: Joost, I know we have a time limit we're approaching here, but
you are actually the author of one of the notable code PRs that we highlighted
this week.  I was hoping that you could summarize it for us before you hopped
off.  It is LDK #3562, which is a PR titled, "Merge probabilistic scores from
external source".

**Joost Jager**: Yeah, so this is sort of orthogonal on to the HA thing, because
with HA you'd say, okay, you do not need external information, you just route
through the HA nodes and penalize hard.  This is going the other way.  It allows
a node to keep track of scores itself locally, but then also from a different
source, for example a node elsewhere on the network that does a lot of probing
that wants to share their score data, to import this and merge this with the
scores that are already present locally.  And the idea would then be to, for
example, periodically update the scores.  So, if this local node or this small
node is not very active, it will still keep a relatively up-to-date view on
what's going on on the network in terms of liquidity.

**Mike Schmidt**: Is this effort part of a bigger set of PRs, or is this just
all encapsulated in one?

**Joost Jager**: Yeah, so this PR is the change in Rust-Lightning to allow for
the merging.  And then, there will be a follow-up PR to expose this
functionality in LDK node.  So, LDK node is like a wrapper around Rust-Lightning
that makes it an actual process that you can run.  And then, within this
process, you can configure this update interval and a URL, and then the scores
will be downloaded from the URL and passed on to the internal scorer.

**Mike Schmidt**: Bastien or Dave, any comments or questions for Joost before he
has to drop?  All right.  Joost, thanks for joining us.  I'm glad we had both
you and Bastien on to go back and forth on some of these LN items.  It's very
valuable for our audience, I think.  Thanks for joining us.

**Joost Jager**: All right, thanks for having me.  Bye, guys.

_Eclair #2967_

**Mike Schmidt**: We're going to jump a little bit more out of order here
because we are fortunate to have t-bast here and also three Eclair PRs.  Eclair
#2967 is a PR titled, "Implement option_simple_close".

_BOLTs #1205_

And this actually references the BOLTs repository, BOLTs #1205, which is
actually later in the newsletter.  But t-bast, maybe you can explain that now,
option_simple_close, and then it sounds like Eclair's implementing that.

**Bastien Teinturier**: Yeah, so this is something we've been working on for a
long time because years ago, we already decided that our protocol for mutual
closing channels sucked.  And it was really bad because ideally, initially, the
way closing a channel worked is that one side says, "Okay, I want to close that
channel", and then offers a feerate.  Then the other side can negotiate that
feerate and you can go back and forth negotiating the feerate.  But since
actually everything is automated, it just ends up being each node starts with a
feerate and they just go slightly more towards the feerate the other guy does,
but just by a very small amount.  So, there was no real negotiation, because all
this is actually just algorithmic.  So, it kind of sucked and the end result was
that only one side really chose the feerate and the actual node paying the
feerate was the channel opener.

Also, this protocol would not work for taproot because for taproot, once we
start using MuSig2 output, we need to exchange nonces every time we want to sign
a transaction that spends the funding output, which applies to closing
transactions as well.  So, we knew we needed to rework that protocol to have
something that worked for taproot, and it was a good opportunity to rework it to
be fair, basically.  So, this new protocol is much simpler in a way, because
both nodes, each participant of a channel says, "I want to close that channel
and I am ready to pay that much fee", and they will be the one paying that much
fee from their balance, and the other guy will just sign that transaction
because they say, "Okay, you want to pay that much fee?  Fine", and the other
guy says, "Okay, and me on my side, I'm ready to pay that much fee, so I will
get another version of a closing transaction where I am the one paying the fee
and I am paying the fees that I decided".

There are still games that can be played, because you could always wait for the
other peer to go first to see how much fees they are ready to pay, and if they
are ready to pay enough fees, then you just don't announce anything and you let
them close the channel.  But that's something we're never going to fix anyway
because there's always this game of if one side wants to close the channel and
it means they need the fund, they are at a kind of disadvantage here, what they
will want to pay in fees, and I don't think we can fundamentally fix that.  So,
it's just gonna be gentlemen's behavior here.  If you see that one of your peers
is always playing bad like that, you're just going to blacklist them unless they
are generating revenue for them.  But if you are closing a channel in the first
place, it's most likely that it's a peer you potentially don't want to have a
relationship with anymore, so it's probably okay.  And this protocol is also
much simpler to implement.  It removes a lot of weird code compared to the
previous one.  So, it's overall quite an improvement.

It took way more time than we thought to get there, mostly because the main
thing that would benefit from it was taproot, and it took a long time for
taproot to be ready.  But now we have finalized it and tested
cross-compatibility between LND and Eclair, so we've been able to merge the BOLT
PR, merge it into Eclair, and I think LND is close to merging it as well.  So, I
hope everyone will implement it soon.  And it also has an interesting aspect for
mobile wallets as well, because the fact that before this, it was always the
channel opener who was paying the closing fees, meant that for mobile wallets,
LSPs always had to take into account the fact that when the channel is closed,
they will be the one paying the fees even if they have almost nothing at stake
or they want to keep the channel alive.  Whereas here, it's potentially either
the mobile wallet user or the LSP who's going to pay the fees, depending on who
actually wants to close more than the other.

It's interesting because in most cases, I think users will just send all their
funds out and they won't have anything else in the channel, and this would
potentially have been an issue if the users were the ones opening the channels.
But now, you don't care, both modes are possible.  Users can either be the one
opening channels, or the LSP can be the one opening channel.  And in both cases,
there's an option where only one side pays the fees for closing the channel,
depending on who has money in it and who actually wants to get those funds back.
So, we'll see how it works in practice once the nodes actually start using it.
And what's interesting is that when you start implementing, you don't have to
touch your channel, it's not like updating a channel feature.  It's something
that only applies at closing, regardless of whether your channel was created
before that protocol was implemented or not.  So, all the nodes who start
upgrading their software to have support for this closing mode will be able to
close existing channels using this protocol.

**Mike Schmidt**: That's nice that it's seamless then.  Is there anything
notable about Eclair's implementation here, since we're covering both the BOLT
change as well as the Eclair change?

**Bastien Teinturier**: Yeah, maybe also one thing that this protocol adds that
we didn't have before is that before, we would do that feerate negotiation, but
then you would have no opportunity to RBF.  The only way to unblock a closing
transaction that was stuck would be to use CPFP, whereas with this protocol, you
can now RBF it, and the Eclair PR supports that.  You can immediately RBF the
closing transaction whenever you want.  But apart from that, it's just really a
plain implementation of the spec, and there was almost nothing to add that is
really specific to us.

_Eclair #2979_

**Mike Schmidt**: Eclair #2979, "Check peer features before attempting wake-up".
Okay, so this is basically more of a refactoring, because we have a feature
where we identify that we are relaying a payment to a Phoenix user and if they
are not connected to us, we are using a mobile notification to try to wake the
device and to have it run in the background to be able to respond and receive
potentially a payment or settle a payment.  And the way we were doing that was
basically relying on hacks and looking into our database for the node IDs that
registered a token for these mobile notifications, which meant we had to do DB
access all the time.  And it's actually more elegant and more efficient to store
the latest for every node that connected to you, with whom you have a channel,
to store the features, so that even if they are not connected, you have still
have a peer object that contains that feature and that is in memory, and you can
check the features of that object to see if they support being woken up if they
are a wallet.

This is also a better modularity separation of concern, where potentially other
mobile wallets that are not Phoenix but support being woken up by various
mechanisms that we could define in the future, like different ways of doing
notifications depending on your OS, on your platform, or something else, we'd be
able to plug into that so that we are able to wake up different kinds of mobile
wallet users.  It's mostly refactoring for us.

**Mike Schmidt**: I know we covered that wake-up feature in the past as well.  I
don't have the newsletter handy, but if you do a search for, "Optech Eclair
wake-up", I think you'll see that.

_Eclair #3002_

Last Eclair PR, #3002, "Secondary mechanism to trigger watches for transactions
from past blocks".

**Bastien Teinturier**: Okay, so this one is interesting because the way Eclair
works is slightly different from the way LND, CLN (Core Lightning) and maybe
LDK, I don't know, work regarding how we watch the blockchain.  For example, at
LND, they implemented btcd, which is an implementation of the Bitcoin Protocol
in Go, and they reuse a lot of libraries from that in LND and they have a whole
onchain wallet in LND that does most of the onchain stuff.  CLN keeps a copy of
the blockchain internally in CLN, where they synchronize the blocks and they
keep a copy and they handle potential small reorgs by themselves.  And we wanted
to do nothing that bitcoind was already doing, so we wanted to only rely on
things that were exposed by bitcoind, RPCs and ZMQ notifications.  So, we do not
store blocks, we do not actively sync blocks when we restart and reconnect to
our bitcoind's instance.  We instead, when we startup and connect, we use the
existing bitcoind APIs to check if our channel outpoints have been spent.  And
then afterwards, we rely on notification from ZMQ to receive new blocks and new
transactions.

The issue with that is that there are cases where if you disconnect from
bitcoind, things happen while you are disconnected and then reconnect.  Some of
these events will not be replayed.  And if one of these events is a channel
being spent, you potentially are going to discover it much later, which means
you will have to browse through the blockchain to see where the transaction was
spent.  The issue with that is that it's quite inefficient.  There is no index
in bitcoind to tell you who spent one of your UTXOs once it's spent, and that's
something we had been advocating for for years.  But adding a new index, we were
never able to get it in bitcoind.  I think there's still an open PR by Fabrice
on our team to add it to bitcoind, that had some traction initially but every
new index that we add adds more code to the bitcoind codebase and adds more
maintenance issues.  So, I understand the fact that it arguably shouldn't be in
bitcoind.

But because of that, that means that when we realize that one of our channels
has been spent, the only way we have to find the spending transaction is to go
through the blockchain block by block until we find it.  And if potentially this
was spent 100 blocks ago because we were offline for a while, then we're going
to load 100 MB of blocks data, even more than that, from bitcoind before we are
able to find it.  And if we do it naively and this happens for many channels,
potentially it's a lot of back and forth and a lot of wasted bandwidth with
bitcoind.  So, what we are now doing instead is that we are keeping some kind of
a rolling queue of the last six blocks in memory, and whenever we see that a
block is received, we ask bitcoind for that block and we keep, maybe not six, I
don't remember if I put ten or six, but we are keeping the last six or ten
blocks we know in memory and regularly getting the last one, so that we scan
them again to make sure that if we missed events from ZMQ, we're going to be
able to see transactions that were potentially spending channels from the block
data that we receive.  And instead of iterating through the blockchain for a
long time, we should be able to catch things almost immediately as soon as we
have a new block, and verify that we are on the right fork by asking bitcoind
for the last six blocks.

**Mike Schmidt**: So, because ZMQ can be flaky, or various other edge cases,
that would cause this potential need to go back 100 or more blocks, depending on
when it occurred.  But instead now, you cache some n blocks, and then you can
scan through those quickly in case there was something missed in ZMQ?

**Bastien Teinturier**: Exactly, and having access to this recent block data is
potentially also useful for other things.  So, we don't know yet if we're going
to use it for other things, but we always figured that not having the latest
block was potentially an issue.  We could, for example, use it to evaluate
whether new announcements that we receive have been confirmed, without having to
go through an RPC call to bitcoind.  So, there are a lot of ways that this can
be useful to get better performance on other parts of the codebase.  So, this
was a change that probably makes sense for more than just this initial feature
we're using it for.

**Mike Schmidt**: Makes a lot of sense.  Thank you for walking us through these
PRs.  Dave, did you have something?

**Dave Harding**: I just wanted to add quickly that over the years, we've been
in Optech for like seven years now, we have covered a lot of PRs where people
have been working around problems with ZMQ.  It's just not a very reliable
communication mechanism.

**Mike Schmidt**: Convenient, but maybe not as reliable as everyone thinks.
T-bast, thank you for joining us again this week for both the news items as well
as these PRs, and thanks for hanging on with us.  You're free to drop or you can
stick around.

**Bastien Teinturier**: Thanks for having me.  Bye bye, see you next time.

_Ark Wallet SDK released_

**Mike Schmidt**: Cheers.  Moving on to our monthly segment on Changes to
services and client software, we have a handful this month.  The first one is,
"Ark Wallet SDK released".  This is a TypeScript library for building wallets.
And the library allows developers to not only build wallets with Bitcoin onchain
functionality, but also the ability to specify an Ark server to be able to send
and receive bitcoins using the Ark protocol.  And this library is put out by the
Ark's lab team.

_Zaprite adds BTCPay Server support_

Zaprite adds BTCPay server support.  Zapwrite is a sort of front-end payment
processing service that allows a merchant to accept Bitcoin, Lightning, or fiat
payments in a single interface, while supporting a variety of backends like
OpenNode, Strike, and with this latest update BTCPay Server.

_Iris Wallet desktop released_

Iris Wallet desktop released.  Iris Wallet is a Python-based desktop wallet that
uses the RLN, which is RGB Lightning Node library, in order to support sending,
receiving, and issuing assets using the RGB client-side validation protocol.

_Sparrow 2.1.0 released_

Sparrow 2.1.0 has been released.  This release, it replaces the previous HWI
implementation with Lark and also adds support for PSBTv2.  As a reminder, Lark
is a Java port of the Python Hardware Wallet Interface, HWI.  We covered that in
a previous Recap as well.

**Dave Harding**: I'm pretty excited to see work on there.  I think the
motivations for that was that Python is hard to use outside of Linux.  And the
Java will give a much more portable library and maybe Craig Raw will take over
Lark and HWI stuff from Ava Chow, which would be great.  So, I'm really excited
to see that.

_Scure-btc-signer 1.6.0 released_

**Mike Schmidt**: Scure-btc-signer 1.6.0 is released.  This release adds support
in the signer's library for v3 transactions, TRUC (Topologically Restricted
Until Confirmation) transactions, as well as pay-to-anchors (P2As).  This
library is actually part of, and I hadn't heard this before, I don't know if you
have, Dave, but the scure, I think I'm pronouncing that correct, suite of
libraries.  And it includes a few different audited and minimal implementations.
So, I think they have audits that have been done on these libraries and I think
they have minimal dependencies.  So, there's things like bech32, base64, base58,
BIP39 mnemonics, BIP32.  And this particular library, this signer library,
supports primitives like transactions, segwit, taproot, PSBT, and multisig.
Have you heard of this suite before, Dave?

**Dave Harding**: I haven't.  I just clicked through the webpage, it looks like
it's all JS stuff.  I don't like doing cryptography stuff in JS, but if you're
going to use it to have a minimal and audited library, that definitely sounds
like what you want.

_Py-bitcoinkernel alpha_

**Mike Schmidt**: The next two items that we highlighted were both around
libbitcoinkernel.  There is Py-bitcoinkernel, which is an alpha release, and
that's a Python library for interacting with libbitcoinkernel, which is a
library that compartmentalizes all of Bitcoin's core validation logic into a
single library.  And this Python wrapper allows you to call into that.  And I
believe when we had Abubakar on at some point, he was actually using this
Py-bitcoinkernel library to query block data for some of his analysis at some
point.

_Rust-bitcoinkernel library_

And then the second item is Rust-bitcoinkernel, which is a Rust wrapper marked
as experimental.  Also wraps libbitcoinkernel to read block data, validate
transaction outputs, and blocks.  So, two different varieties of interacting
with libbitcoinkernel.

**Dave Harding**: I think this is an exciting development that libbitcoinkernel
has proceeded to this state where people are starting to wrap it and use it and
stuff.  And as a preview for next week, we have somebody who is starting work on
their own node based on, I believe, the Rust-bitcoinkernel library.  So, they
want to do a different set of transaction relay rules or policy changes, but
they want their own node, they want to make sure they're using the
bitcoinkernel, the consensus library.  So, these tools are allowing increased
experimentation.  I think that's fantastic.

**Mike Schmidt**: And I do think that there is a kernel node that I don't think
is ready for public display just quite yet, and I don't think that's the one
you're talking about.  But I guess the moral of the story here with these items
and what Dave's alluding to is that there's quite a bit of activity around
kernel, which is great to see.

_BIP32 cbip32 library_

BIP32 cbip32 library.  This is a C library that implements BIP32 using libsecp
and libsodium, which is a C crypto library, so another one of these sort of
minimalist high-performance libraries, this one in the case of BIP32.

_Lightning Loop moves to MuSig2_

Last piece of software that we highlighted this month was Lightning Loop moving
to MuSig2.  Loop is Lightning Lab's non-custodial submarine swap service that
allows users to swap between onchain Bitcoin and the LN.  And the blogpost that
we linked to in the newsletter explains how they replaced their existing
architecture to use taproot and MuSig2 with the effect of reducing transaction
size, lowering fees, and adding privacy to their loop service.

_Bitcoin Core #27432_

Notable code and documentation changes.  We touched on a few of these already,
but there are a few that remain.  Bitcoin Core #27432, which adds a Python
script that converts the compact serialized UTXO set into SQLite database.  So,
this compact serialized UTXO set is a binary format that was created
specifically for assume UTXO, because you need to be able to load the UTXO set
for assumeUTXO.  And that format was designed to be as compact as possible, but
there was demand from users who wanted to get the UTXO set in the form of a CSV
file or a database.  So, developers considered changing the existing
dumptxoutset RPC, but that was determined to be maybe too burdensome on
maintenance for the project.  So instead, there is this separate Python script
that calls dumptxoutset and then converts the output of that into a SQLite
database.

**Dave Harding**: This is another thing I'm kind of excited to see.  For many
years, when I've needed a copy of the UTXO set, you had to modify your copy of
Bitcoin Core to just insert some debug print statements in there, and you would
then read it out of your log files, which wasn't hard, but I mean getting it
straight into a SQLite database would be great.  So, this is a nice thing for
people who are doing data analysis on the UTXO set.

_Bitcoin Core #30529_

Bitcoin Core #30529.  This PR changes behavior of the negated command line
options in Bitcoin Core.  So, there's a series of these.  I won't read them all,
but I'll quote from the PR in that, "Before this change, negating these options
wouldn't fully reset them, and would have confusing and undocumented side
effects.  Now, negating these options just resets them and behaves the same as
not specifying them at all".  I didn't dig into exactly what sort of weird and
undocumented side effects there were, but this seems like a welcome cleanup.

**Dave Harding**: I think one of these, if you negated it, it's an
IP-address-based one, and it would just ban the default IP address, which is
0.0.0.0.  So, if you tried to negate it, it would just ban localhost
connections.  So, there's just a lot of weird stuff used to happen.

**Mike Schmidt**: Yeah, so a bunch of these, I won't list them all, but they all
start with 'no', like nobind, norpcbind, nowhitebind, norpcwallet.  These sorts
of things are what we're referring to when we're saying, 'these negated
options'.

_Bitcoin Core #31384_

Bitcoin Core #31384.  Back in Newsletter #336, we covered a news item that was
titled, "Investigating mining pool behavior before fixing a Bitcoin Core bug".
We had Abubukar on who outlined a bug in Bitcoin Core where, when building a
block template, Bitcoin Core would allocate some space for the block's coinbase
transaction, block header and transaction count, but it accidentally reserved
that space twice, which was unnecessary, and then it reserved space in a block
that could not be used by normal transactions.  We also had Abubakar on in
Podcast #336 and he explained this issue.  So, this PR that we're covering this
week resolves that duplicate coinbase transaction weight reservation issue, and
also then adds a blockreservedweight option to allow users to customize the
reserved weight, which could be useful for miners looking to customize that or
looking for the previous behavior, if they depended on it for some reason.

_Core Lightning #8059_

Core Lightning #8059 is a PR titled, "Xpay: don't MPP if we're told not to".
Dave?

**Dave Harding**: Okay, so xpay is CLN's new pay implementation, so when I send
a payment.  And they discovered that they were accidentally always using
multipath payments.  So, multipath payments are where the payment is split into
multiple parts and potentially set along different routes in order to make it
more reliable.  But the receiving node needs to support that feature.  It needs
to be able to accept the payment coming in in multiple parts.  And to indicate
that, the receiving node, when they create their invoice, they set a flag on it
that says, "I accept MPP".  And it's just a single small flag that it adds.  But
they discovered that they were always supporting multipath payments.  They
wouldn't always necessarily generate a multipath payment, but they often would,
even if the receiving node didn't say to support it.  Now, almost everybody on
the network supports multipath right now.  I honestly have all the
implementations support it.  It's only people running really old software who
wouldn't support it, or maybe people with some special cases where they can't
support it.

So, they've updated their code, that they will now only send a multipath payment
for a BOLT11 invoice if it is actually supported, according to the receiving
node.  They also plan to update this for BOLT12 invoices, so when you make a
payment request and you receive an invoice, but they have to wait until the next
release because there's some other interacting features there.

**Mike Schmidt**: So, a bug fix, but not a terrible bug, just due to the
prevalence of support of multipath payments already on the network.  So, it
wouldn't have a huge effect.

**Dave Harding**: Right.  I'm sure that's why it didn't get caught in initial
testing.  Very few people are not going to have this enabled.  And the only
downside is that, if Mike doesn't have multipath available on his node and I was
using an old CLN release, I couldn't pay him.  We wouldn't lose any money or
anything, just anytime I sent a multipath payment to him, it would fail, and I
would be like, "Hey, Mike, I can't pay you, what's going on here?"  And I
believe that's how the issue got found here.  Somebody tried paying somebody, it
always failed, they said, "Hey, I'm having this issue", and now it's been fixed.

_Core Lightning #7985_

**Mike Schmidt**: Makes sense we have two more CLN PRs that Dave's going to help
us out with.  Core Lightning #7985 titled, "Renepay: support for BOLT12".

**Dave Harding**: Yeah, so for BOLT12, you need to support blinded paths.  And
renepay is CLN's plugin for choosing routes.  And blinded paths, the final hops
in those, the sending node doesn't get to see them.  They're already encrypted
by the time the sending node receives them.  So, they just need to have the
plugin to support figuring out the path up to the first hop of those last few
blinded hops, and so they have.  So now, it can support paying BOLT12 invoices,
and that's great.

_Core Lightning #7887_

**Mike Schmidt**: Last Core Lightning PR, #7887 titled, "BOLT updates after
24.11".

**Dave Harding**: And this is just increased support in CLN for paying
human-readable names (HRNs), which are an update to BOLT21 URIs that can be
placed in a DNS text field or various places in DNS.  So, I can pay
mike@brink.dev and that payment will actually go through to Mike's node, and I
don't have to remember his Lightning address, which is a long bech32-style
address.  I can just remember his Lightning node address and it's all using DNS
resolution, it's just clever.  I don't believe this is full support in CLN for
it yet, but this is a bunch of updates for that.  If you're interested,
definitely go and check out the details.  I'm thinking they're planning to have
support for that in their next release, so you'll be able to pay.

**Mike Schmidt**: When I took a look at this one and read the writeup and then
clicked into the PR, I was surprised that the PR was titled, "BOLT updates after
24.11", and had dozens, or something like 50 file changes.  But it really was
just all 353, or human-readable address support.

**Dave Harding**: I think the way CLN does their BOLT updates is they have a
script that periodically they run against the BOLT repository and make sure
their internal comments match the text of the actual BOLT, to make sure they
stay in specification.  So, when we do these update PRs in our summary, we go
through and figure out if they made any changes, so a lot of times, just fixing
typos and stuff.  And then, we go through and see what the most significant
changes were in that.  And the ones that I pulled out for our writer who does
the notable merges, Gustavo, to do is these changes related to the
human-readable names, because they look like they actually change some of CLN's
logic related to them.  But again, I don't think CLN currently supports this,
but it sounds like they're getting ready to support it in a future release.
Maybe somebody from CLN will correct us on that, I don't know.

**Mike Schmidt**: That makes a lot of sense, and that explains all the file
changes as well.  Thanks, Dave.

_LDK #3575_

LDK 3575, PR titled, "PeerStorage: add feature and store peer storage in
ChannelManager".  This is actually a breakup of a previous PR attempt to add
peer storage into LDK.  This PR broke it into smaller chunks to make it easier
to review.  But the end effect is that this PR enables nodes to distribute small
blobs of data to their peers, which could be retrieved to resume or force close
the channel if there was any sort of data corruption.

We have one more PR, but we discussed it earlier, which was BOLTs #1205, so
refer back to earlier in the discussion when we had T-bast explain the
option_simple_close, which is feature bits 60 and 61 that we spoke about with
him earlier.  Thank you to Joost and t-bast for joining us this week, and thanks
for Dave for co-hosting, and we'll hear you all next week.

{% include references.md %}
