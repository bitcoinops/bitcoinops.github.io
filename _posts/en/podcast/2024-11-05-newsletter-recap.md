---
title: 'Bitcoin Optech Newsletter #327 Recap Podcast'
permalink: /en/podcast/2024/11/05/
reference: /en/newsletters/2024/11/01/
name: 2024-11-05-recap
slug: 2024-11-05-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Andrew Toth to discuss
[Newsletter #327]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-10-5/389318441-44100-2-353d07311e547.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #327 Recap on
Twitter Spaces.  Today, we're going to talk about the SuperScalar proposal,
there's a draft BIP for Discrete Log Equivalency (DLEQ) proofs, and we also have
our usual segments on Notable code and documentation changes, as well as
Releases.  I'm Mike Schmidt, contributor at Optech and Executive Director at
Brink, funding open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs for the time being.

**Mike Schmidt**: Andrew, back-to-back.

**Andrew Toth**: Hey, thanks for having me again.  I'm Andrew, I do Bitcoin
stuff for Exodus Wallet.

**Mike Schmidt**: Awesome, Andrew, thank you for joining us this week again.  If
you're following along, we're just going to go through the newsletter
sequentially here.  We have two news items.

_Timeout tree channel factories_

First one is titled, "Timeout tree channel factories.  ZmnSCPxj, or Z-man or Z,
posted to the Delving Bitcoin forum in mid-September I believe.  It was a post
titled, "SuperScalar: Laddered Timeout-Tree-Structured Decker-Wattenhofer
factories", and there were a ton of comments on this post and discussion.  It's
quite a complicated proposal.  So, as part of understanding the proposal, which
was somewhat evolving in the post itself, in preparation for inclusion of this
topic in the newsletter, Dave Harding, who's the primary author of the
newsletter thought, at the suggestion from AJ Towns, that instead of doing a
recap, we should do a pre-cap discussion with ZmnSCPxj to do some discovery
about what's in the proposal and a real-time voice discussion, as opposed to
Dave sort of gathering that information offline.

So, we had that chat with ZmnSCPxj last week.  Dave, myself, and ZmnSCPxj jumped
on a discussion, and we released a podcast last week titled, "SuperScalar Deep
Dive Podcast".  So, while Murch and I will try to provide a high-level summary
of SuperScalar here, definitely check out that discussion.  I think probably
Dave and ZmnSCPxj understand it much deeper than we do.  So, the technical
details will be in there.  Murch, you and I, this is the part where we stumble
through explaining what SuperScalar is!  I'll take the first stumble here.

Murch, the way I understand it is that it is a single LSP protocol for channel
factories, so multiple users would pay into a single LSP's channel factory, and
then those users are able to make offline payments, including Lightning
payments.  And then after a period of time, say a month, the users in that
factory need to roll their funds into a new version of that factory or withdraw
them.  That's my tl;dr, and I have some more notes on motivation and things, but
maybe, Murch, I'll pause here to have you jump in.

**Mark Erhardt**: Right.  So, my understanding is that it is a tree construction
and the leaves are regular LN-penalty channels, as we know them and use them in
the LN.  So on that end, it's compatible with the entire LN spec.  And then, the
intermediate nodes in the tree are Decker-Wattenhofer, what is it, duplex
micropayment channels.  And the idea there is they are very similar to
LN-Symmetry in that you can have multiple parties in those.  So, in those
intermediate nodes, all the users of the LSP that have a leaf underneath are
included, and the LSP.  And that allows the LSP to sort of use this channel,
this three-party channel, to rebalance the users that are in the leafs below as
well.  And I assume that this additional connectivity, by having a multiparty
channel, also helps with routing, at least among users of this LSP.

The interesting thing is, the duplex micropayment channels can be built on the
current consensus rules, but they are limited in the number of updates.  So, by
using them only for rebalancing other channels, you can reduce the number of
uses that you need to make frequently.  Sorry, you don't need to use them that
frequently because you are only rebalancing other channels that exist already.
And that way, you can make them last longer, even though they have a limited
count of updates.  And then above that, there is the timeout-tree, and that
usually uses CTV (CHECKTEMPLATEVERIFY), but we don't have CTV, obviously, yet.
So instead, ZmnSCPxj uses a multisig construction, where everybody that's
underneath a node in the tree will have to sign off on those intermediate nodes.
So, those are even bigger multisigs.  And that's roughly most of what I
understood so far.

So, the cool thing is it's a single UTXO, the whole tree construction is a
single UTXO.  But then after a month, I guess they could roll it over into a new
version offchain.  Or, if the LSP becomes incommunicado, the users would be able
to unilaterally withdraw, but then they'd have to publish essentially the whole
tree, which would be a lot of transactions.  But the LSP is the one that loses
the funds here, rather than in Ark where the Ark operator gains the remaining
funds if the users time out.  Here, the users get the rest of the funds if the
LSP times out.  Well, I haven't been able to listen to the podcast yet, so this
is just my rough understanding from Harding's summary and looking over the
Delving post a little bit.

**Mike Schmidt**: Excellent, that was great, Murch.  Thank you for filling a lot
of that in.  ZmnSCPxj, in his post, also outlined some of the motivation here of
what he's trying to achieve with this single LSP solution.  Oh, we have
instagibbs.  Hey, instagibbs.

**Greg Sanders**: Hi, just a little clarification.  It's also a timeout-tree
like in Ark, so it's similar.  They're different in important ways, but they're
both timeout-trees in a sense.  The users should be migrating to a new tree just
by paying themselves essentially over the Lightning Network, if that makes
sense.

**Mike Schmidt**: Yeah, that makes sense.

**Mark Erhardt**: So basically, there's a new tree being set up and they overlap
in their time.  And then, the user in the first tree pays to their own leaf in
the second tree in order to fund that leaf.  But how does that work with the
timeout of the …

**Greg Sanders**: The LSP funds the new tree themselves, so they're fronting the
liquidity.  So basically, they'll set up a bunch of new channels that have all
the funds on the LSP side and then users, clients, send it to themselves, so
rebalancing those channels essentially.

**Mark Erhardt**: So, how does it work that the LSP doesn't forfeit the money in
the old tree?

**Greg Sanders**: Well, all the users should either send their funds over the LN
to a new tree or to a new channel, or pay for pizza, or whatever, right, just
send their funds somewhere; or do the unilateral close before the timeout.  It's
kind of the same thing as Ark, just a different way of -- in Ark, you're doing
these atomic swaps essentially with connecting outputs.  But this is just, these
are kind of somewhat static trees that you're just using to make Lighting
payments.

**Mark Erhardt**: Right, but, okay.  ZmnSCPxj seems to have been very clear on,
the LSP loses the funds if the timeout is hit.

**Greg Sanders**: This might be the newest post.  Which post is this?  Because
he did do a new post that might have flipped it, and I do not understand that
one.

**Mark Erhardt**: Okay, all right.  I don't know, I'm sorry.

**Greg Sanders**: He has a newer proposal which may have inverted this behavior,
and I can't speak to that.

**Mike Schmidt**: Greg, maybe you can help with this next piece that I was going
to outline.  So, part of the motivation -- ZmnSCPxj noted a few constraints.  He
wanted to make sure that the LSP cannot steal funds, that there's no Bitcoin
consensus changes, and also the ability for end users of the LSP to be fairly
regularly offline.  And he noted that given those constraints, Ark and BitVM are
ruled out, because they both have a one-honest-member security assumption in
their non-covenant forms.  Does that make sense?

**Greg Sanders**: I don't have the details.  I don't think that's true for Ark.
I mean, you could talk to Steven Roose about his architecture, but I'm pretty
sure that's non-custodial.  For BitVM, that is true.  The users can be denied
their funds on the way out if there's not a single honest party.  So, I know
that's true for BitVM, at least.

**Mike Schmidt**: Okay, and I think the caveat there is that the one honest
member security assumption in non-covenant form for Ark is valid, unless all
members of the LSP are, I guess, online at the same time, which is this
liveliness multi-signer coordination problem that we mentioned in the
newsletter.

**Greg Sanders**: Yeah, I mostly studied the CTV variant of Ark, so I can't
speak to that.

**Mike Schmidt**: Got it.  Well, if it sounds complicated, try listening to the
podcast from last week and see if that helps or hinders your understanding, for
everyone listening.  And if it doesn't, don't feel so bad, because ZmnSCPxj
himself noted that this protocol is, "Overly complicated at this point, but hey,
I think it works out".  Anything else to add, Murch?

**Mark Erhardt**: That's all I had.

_Draft BIP for DLEQ proofs_

**Mike Schmidt**: Okay, excellent.  Thanks for jumping in, instagibbs.  Next
news item titled, "Draft BIP for DLEQ proofs".  Andrew, we had you on last week
where we discussed your draft BIP for sending silent payments with PSBTs.  And
actually in that discussion, we made some references to the DLEQ BIP, which is
Discrete Log Equivalence BIP, which conveniently is the BIP that we cover this
week.  So, you posted to the Bitcoin-Dev mailing list a draft bit that specifies
a standard way to generate and verify these DLEQ proofs.  But maybe to start,
what is DLEQ, and what is a DLEQ proof?

**Andrew Toth**: Yeah, thanks for having me again.  So, a DLEQ proof, or
Discrete Logarithm Equivalency, as you mentioned, is a way for you to prove that
two points on a curve were both generated by the same secret without ever
revealing that secret.  So, the two points are generated by two different base
points, and the secret is multiplied by those base points to create them.  So,
basically that would be the discrete logarithm of both those points, hence
Discrete Logarithm Equivalency.  And this is useful in a number of contexts, but
for one, ECDH (Elliptic Curve Diffie-Hellman).  So, if two parties come together
with a private and public key pair, the public key is the first point and it's
created by multiplying the secret by the generator point of the curve.  And so,
that would be the first base and the first point.  And then, the second base is
the other party's public key.  And the second point would be the shared secret
that you both generate.  So, with your secret, you multiply the other party's
public key, and you will get the shared secret, which is the second point.

Now, both parties have their own private key and the opposite party's public
key, so they can verify together that the shared secret is the same, is correct.
But say a third party, who has none of the private keys but only sees the two
public keys of both parties and the shared secret, they can't verify that that
shared secret was actually created using one of the private keys of one of those
parties.  So, one of the parties could, with their private key, with the
generator point, with their public key, with the opposite party's public key,
and with the shared secret, so a lot of different points, could create this
proof that they could give to the third party; and with that proof and the two
parties' public keys, could verify that the shared secret was generated with one
party's public key and the other party's private key that gave the proof,
without actually revealing that private key or knowing the secret.

So, why is this useful?  Well, in the context of silent payments, a silent
payment at a base level is really an ECDH between a sender and a receiver.  So,
with a PSBT, not all participants in the PSBT would have access to all the
private keys.  So, the signer, when it generates or computes the address to be
sent to with its private key, other parties can't verify that that address was
actually computed correctly.  So, if the signer is malicious, it could send
funds back to itself; or if it's just malfunctioning, the funds will be burned
because the recipient wouldn't be able to receive them.  So, what we can do with
a PSBT is have the signer generate the ECDH share that is used to create the
address, and then all parties can use that ECDH share to compute the address
themselves and verify that it's correct, and then also provide a DLEQ proof for
that ECDH share.  And then, all the parties can also verify that that ECDH share
was computed correctly for that share and without ever knowing the private keys.
And so, we can be confident that the address the PSBT is sending to is computed
correctly.

So, I initially spec'd out this DLEQ inside the PSBT silent payments BIP.  I was
told early on though that DLEQs are actually pretty useful for a number of
different cryptographic protocols, so it might be useful to spec this out into
its own BIP, and then other protocols could just refer to it instead of having
to spec out their own.  So, that's what motivated me to create this BIP, and
that's where we are today.

**Mike Schmidt**: Murch, I know you had some questions last week when we were on
this topic.  Did Andrew's explanation this week clarify that?

**Mark Erhardt**: Yes, that was excellent.  I think I totally got all of it
already.  So basically, you're just providing an avenue for people to prove that
they correctly participated in a silent payments transaction.  And that is of
course important when there's multiple senders, because you wouldn't be able to
otherwise tell, because you don't have access to private key material of the
receiver or the other senders.  So, yeah, that sounds awesome to me.

**Mike Schmidt**: Andrew, I think you just mentioned it, but I think I missed
it.  What are the other scenarios in which these DLEQs could be used?

**Andrew Toth**: Yeah, so this was the first time I'd heard of DLEQs, but as I
was researching to write up this BIP, there's actually a number of other places
where people have already spec'd out and implemented DLEQ.  So, for instance,
adaptive signatures for DLCs (Discreet Log Contracts) use a DLEQ proof; ecash,
so for verifying that a mint has properly given you funds from a mint, because
it's a blinded signature, you need a DLEQ there as well; as well as PODLEs.  So,
for JoinMarket, Fidelity Bonds use PODLEs, which is Proof Of Discrete
Logarithmic Equivalency, which is essentially just a reversal of DLEQ.  This was
a number of years ago before, I guess, DLEQ became the more popular algorithm.
They also use DLEQs.  And as well, waxwing has a protocol called RIDDLE that is
using DLEQs as well.  So, there's a fair amount of different use cases.

**Mike Schmidt**: It sounds like waxwing also provided some feedback that would
improve this implementation.  You mentioned that PODLE was maybe an older
protocol?  Is that something that other -- is everyone moving to DLEQs, is that
the standard route, or do you think it'll still be fragmented?

**Andrew Toth**: Well, I mentioned that it's older because the algorithm the
acronym is different.  It's really the same math, right, so it hasn't really
aged.  It's like ECDHs from the 1970s, right, so it's still the same math, just
different acronym, but it's essentially the exact same thing.  So, if this DLEQ
is standardized, then Fidelity Bonds could use this BIP as well and say that
they're complying with the BIP.

**Mike Schmidt**: Murch, any other questions or comments?

**Mark Erhardt**: I am out of questions.

**Mike Schmidt**: Andrew, what's the call to action here?  If someone's a
developer or working on silent-payment-related software, what would you like
them to do?

**Andrew Toth**: Yeah, I mean check out the BIP, make sure my math is correct.
I got some great feedback already on ways to make the BIP more flexible, so if
we want to use it for other future uses, I've added some changes there, like to
be able to, for instance, parse in the generator point instead of using the secp
generator point statically.  That lets it be used for other curves.  Waxwing
also suggested adding a message to it, so I'm exploring how that could be used.
But if you're working on silent payments, I would also just start looking at the
silent payments PSBT BIP instead and see if that makes sense to be implemented,
because we can do that first, it's not necessary to have DLEQ with that, so that
would be great to check out as well.

**Mike Schmidt**: Andrew, thanks again for joining us this week.  You're welcome
to stay on, or if you have other things to do, we understand.

**Andrew Toth**: Thanks for having me.

_BTCPay Server 2.0.0_

**Mike Schmidt**: Releases and release candidates, we have BTCPay Server 2.0.0.
We linked to the release notes for this BTCPay release, but there's also a
blogged post titled, "BTCPay Server 2.0: our biggest update yet!"  And in that
blogpost, it outlines the new release.  There's key features, and there's also
some breaking changes.  I'll enumerate some of them here.  Key features: there's
new localization in the UX; there's new sidebar-only navigation; there's a new
onboarding flow for new users and for the POS implementation; they have three
new e-commerce integrations, including Wix, Odoo and BigCommerce; and they now
default to the v2 checkout and removed the legacy checkout; and then there's
some branding enhancements as well.  So, those are the key new features.

But this release also, since it's a 2.0 release, introduces some breaking
changes for existing users.  Some of the breaking changes noted in the blogpost
are mostly around changes to the APIs.  The BTCPay team noted that there were a
bunch of changes to the APIs in order to drop a lot of the technical debt that
they've accumulated over the years since their original releases.  And
particularly notable is, if you're a BTCPay user that relies on either some sort
of custom integration that you've coded or some sort of a plugin, make sure that
those integrations or plugins are compatible with this new 2.0 version.  Murch,
anything to add there?

**Mike Schmidt**: You are covering everything already, but I wanted to stress
something.  If you're updating, read the release notes first.  Check that you're
not updating and breaking your integration or anything.  They wrote that they
have been testing it very carefully, but we've recently just had some
compatibility issues again with infrastructure software, because there was not a
lot of downstream participation in the RC vetting.

**Mike Schmidt**: We know about that, right?

**Mark Erhardt**: Yes.  Do read the release notes and check whether it might
affect you.  If you can, test it on a different testnet or somewhere to see that
it doesn't break anything for you, before you roll it out on your main
installation.  But anyway, just good practices, okay.

**Mike Schmidt**: Notable code and documentation changes if you have a question
for Murch, myself or Andrew or instagibbs about some of the SuperScalar
discussion or DLEQ proofs, now's the time to raise your hand or put a comment in
the chat.

_Bitcoin Core #31130_

First PR, Bitcoin Core #31130, which drops the miniupnp dependency in Bitcoin
Core.  Miniupnp is a C library that supports the universal plug-and-play
networking protocols for devices on a network to establish network services.
So, for Bitcoin Core, that would be something like enabling a node to open a
port on a router to be able to receive incoming Bitcoin P2P connections.  This
miniupnp C library had a history of bugs, including a recent infinite loop
vulnerability that we had discussed in Newsletter and Podcast #314.  But even
before that most recent vulnerability, the miniupnp feature was disabled by
default.  I believe it was 2015.  So, it was still in there, but off by default.

More recently, we covered the merge of Bitcoin Core #30043, and that added
built-in custom support for achieving that same, or similar, functionality as
the miniupnp library, without having to rely on an external library possibly
under-maintained.  So, we covered that #30043 PR in Newsletter and Podcast #323,
and that built-in version, that new implementation, is also disabled by default,
at least so far.  Murch?

**Mark Erhardt**: Yeah, I don't know if you've mentioned it, I might have missed
it, but generally the point of this tool is if you're in a LAN that is
firewalled off from the main internet, this allows you to punch through and
allow people from outside to connect to your node, so you can be a listening
node, even if you are behind a firewall, without manually configuring it.  So,
this is what it's all about and that's pretty cool because it can be a drag to
figure out your firewall, or sometimes you don't even have access, and this
allows a lot more nodes at home to serve blockchain data to other peers on the
network.

_LDK #3007_

**Mike Schmidt**: LDK #3007, this is a PR titled, "Serialize blinded Trampoline
hops".  This PR adds support for encoding blinded paths within a trampoline
payload.  And this is actually one of the first PRs around LDK support for
trampoline routing.  There's a trampoline routing tracking issue for LDK, which
is #2299, if you're curious about their progress along there.  There's, I think,
almost 30 PRs, and there's only a few that are merged, so that's very much in
progress.  Maybe as a bit of background for folks, trampoline routing lets a
spender route a payment to some intermediate Lightning node, and that
intermediate node can then select the rest of the route to the ultimate receiver
of the payment.  That can be something that's useful for light clients that
aren't able to have maybe the whole LN graph.  Maybe they've been offline or
maybe it's just a mobile device with less beefy hardware.  So, by adding blinded
paths to trampoline routing, it actually improves the privacy of the payment,
since the trampoline node will no longer know the ultimate receiver of the
payment, which is a privacy downside if you're using a single trampoline hop
payment.

So previously, you could only achieve similar trampoline privacy if you used
multiple trampoline forwarders, so that none of the forwarders could be sure
that they were the final forwarder.  But by having all those different hops in
hopes of attaining additional privacy, it was more expensive because the paths
were longer.  So, you paid more fees and also potentially less reliable, since
you had more hops along the way that something could go wrong.  So, this PR
helps lay the groundwork for these blinded path trampoline setup.  Murch,
anything to add?

**Mark Erhardt**: Nope, good job.

_BIPs #1676_

**Mike Schmidt**: Great.  BIPs #1676 updates the status of BIP85 to final.  We
covered BIP85 being changed in Newsletter #323, and then after objections from
developers who had already implemented the original BIP85 spec, those changes
were reverted in our Newsletter #324 coverage.  So, since BIP85 has a
designation of widely deployed, it's now marked as a final BIP to prevent
introducing any further breaking changes to the BIP.  Murch, you're our resident
BIP maintainer, maybe you have some more color commentary here?

**Mark Erhardt**: I do not.  Just, yeah, if you are responsible for any BIPs or
if you make heavy use of any BIPs and they are currently in the wrong status,
please feel free to open a PR to update it to the correct status, because some
people might orient their work based on the information in the BIPs repository.

**Mike Schmidt**: All right, I didn't see any requests for speaker access or
comments in the thread, so I think we can wrap up.  Thank you, Andrew, for
joining us yet again this week and talking about some of the news items.
Instagibbs, thanks for chiming in on some of the Ark and SuperScalar stuff,
where we were weaker.  And as always, thank you, Murch, my co-host, and for you
all for listening.  Cheers.

**Mark Erhardt**: Cheers.

{% include references.md %}
