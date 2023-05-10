---
title: 'Bitcoin Optech Newsletter #248 Recap Podcast'
permalink: /en/podcast/2023/04/27/
reference: /en/newsletters/2023/04/26/
name: 2023-04-27-recap
slug: 2023-04-27-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Will Clark to discuss [Newsletter #248]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/70140804/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-4-10%2F34cbeb2b-b5ed-becd-a368-75dc166704f2.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #248 Recap on
Twitter Spaces.  It's Thursday, April 27.  I'm Mike Schmidt, contributor at
Optech and Executive Director at Brink, where we fund open-source Bitcoin
developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs to improve Bitcoin.

**Mike Schmidt**: Will?

**Will Clark**: And I'm Will Clark, I'm working on Bitcoin Core, especially
targeting old issues and outstanding stuff like that, and looking at things like
this mempool message that we're going to talk about today.

_Proposed removal of BIP35 `mempool` P2P message_

**Mike Schmidt**: Yeah, let's just jump into it.  This is the first news item of
the newsletter and I'll share some tweets in this Spaces here so folks can
follow along in a second.  But the first news item here is proposed removal of
BIP35 mempool P2P message.  Will, perhaps you can give some context on how you
came across this.  Was this one of this issues, or something you were already
triaging; or, did you proactively go out and find it?  And then, maybe we can
talk a little bit about what it actually is and some discussion about the
mailing list about it.

**Will Clark**: Sure, yeah.  No, this was slightly outside of my current remit
of looking at old issues and stuff, but I did come across it as part of that
work and it's currently unused in Bitcoin Core, which is what drew my interest
to it.  I mean, while we have the functionality in there to respond to it, it's
neither being tested, nor is there any way for two Bitcoin Core nodes to use
this functionality even between themselves.  So, yeah, from there that kind of
raised my interest really, but who might be using this and trying to put some
feelers out to see if there are any wallets that are still using systems like
this to get transaction data from the mempool.

**Mike Schmidt**: Some folks who are listening may be surprised, I think when I
originally came across this message I was too, that there was such a way to
query your peer's mempool, and I guess there was some rationale for that, that is
historic and there's some potential usage of this still currently, although you
can't request a mempool from your peer.  Can you give us your understanding of
why this was originally added as a feature, and as a message?

**Will Clark**: Sure, yeah.  I think David Harding replied to my mailing list
post with a very clear and concise rationale for how this was used, or how it
was intended to be used, when both this message and the BIP37 simple payment
verification (SPV) stuff would be used, and the way it would work is you would
connect using BIP37, you would send across the bloom filters showing which
transactions you were interested in, and after doing that you could then use
this mempool message to request also transactions that may be relevant to your
wallet from that node's mempool.

So, it has a pretty good use case and if people do surface and they say, "We're
still using this, we rely on this and we specifically use Bitcoin Core and tell
users of our wallet" or whatever, "to connect to their own node, enable bloom
filters and then we send these mempool messages in to get mempool transactions",
then that would be fair enough.  But whilst I think that is kind of a good
mechanism and I do take David's later point in his email, that he would prefer
to see a better system implemented before we remove this one, or thought about
removing this one, which is something that doesn't currently exist, to be clear
there is no direct replacement for this, at least on the Bitcoin P2P protocol
level, I guess my counterpoint to that would be that again, as far as I can
tell, most of the mobile wallets today that have users who are keen to connect
back to their own nodes are using Electrum protocol.

So, I don't believe that there are many, even mobile wallets, or anybody really,
using this mechanism, despite the fact that it kind of is elegant if you're
using it yourself.

**Mike Schmidt**: So, you mentioned the use case of allowing lightweight clients
to poll for unconfirmed transactions.  The original BIP35 had, as part of the
motivation, and this was from 2012, for context, described a motivation outside
of that, which was network diagnostics and also allowing miners, who recently
rebooted, to query for unconfirmed transactions.  But to that later point, at
the time Bitcoin Core wasn't saving the mempool to persistent storage when you
shut down, so I guess this was a good use case for miners to get back up to
speed quickly, but that's obviously gone away, and then there's obviously some
privacy considerations around network diagnostics.

That leaves us with the use case that Will just outlined, which is this
lightweight client polling use case.  And as you mentioned, probably most people
are not using this, and so I guess that was Dave's point, is that there
potentially are people still using this.  And so, the question then is, do you
get rid of it; and do you get rid of bloom filters and BIP37 along with it.

**Will Clark**: Yeah, well it's a good point, and just to come back to something
you mentioned before that.  In the case of synchronising to bitcoind nodes
directly, they do exist in addition to the mempool being persisted to disk on
shutdown, so you can copy that file over if you really want to sync from
scratch.  But there are also RPCs available; there's one to dump the mempool,
one to load a mempool is currently open as a pull request.  So, that kind of
functionality does exist and I think it also carries some benefits over doing
this using P2P messages, which is if you dump and load the mempool as a file
like this, we can transfer things like any custom fee deltas that have been
passed the end time, you know, the time the transaction's received, therefore we
can expire it from a mempool in a reasonable amount of time, and other helpful
bits of metadata, I guess, which we can't send over the P2P message.

But yeah, in terms of BIP37, I'm not sure that I personally am going to go the
full way with that.  I think at least trying to gauge interest around this
section of it, I feel like it's more likely that even if there are people using
BIP37 at the moment, I'm unsure that there's anybody using this.  I would love
to hear from people if there are.  I don't have a huge personal desire to get
rid of it, but only to help the general Bitcoin codebase stay fresh, full of
maintained code that people are using.  So, if people are using it, then I would
like to know about it.

**Mike Schmidt**: And in your investigation so far, did you determine if there
were other nodes other than Bitcoin Core that were still actively using this
message; it sounds like maybe there was some activity of mempool messages, maybe
you can talk a little bit about that usage?

**Will Clark**: Yeah, sure.  I am actually in the process of monitoring for
these messages on my node and I have somebody else who's also monitoring on
their node too.  We haven't seen many.  I think in a week, there's been about
three of these messages going past, so that is something.  But whether that's
somebody just testing that messages are propagated, or who knows what these
people may be doing with the messages.  So, hopefully more data to follow on
that point.

But regarding other full nodes, I did look at the code bases for libbitcoin,
which does have the message in their protocol, and it appears it's only used
internally for testing as well.  BTCD, I didn't quite get fully into, but they
do have the message present.  Bitcoinj and bcoin also both had this message, so
it seems like at least nobody else has removed it yet.  But again, what sort of
usage it sees is difficult to measure in a nice decentralised system like
Bitcoin that doesn't collect data on its users and stuff like that.

I did try to look at a few mobile wallets, at least a few of the bigger ones,
and again many of these seemed to either be using trusted node setups, which is
not ideal, or Electrum protocol.  In the settings tabs for the couple that I
checked, if you choose to connect back to your own node, it points us to your
Electrum node at home.  Again, it just kind of further backed up my intuition
that this has pretty much no use, but more data to follow.

**Mike Schmidt**: I would be surprised if similar to you collecting this data
about usage of the mempool message on the P2P Network for research purposes, I'm
wondering if there's another Bitcoin developer out there that's actively sending
this obscure message as well for other data-gathering purposes, and perhaps
that's the only usage of it!  But like you said, we can't truly know.  Murch,
thoughts on BIP37 and BIP35 and some of the stuff that Will's outlined?

**Mark Erhardt**: No, I think you have covered it mostly.  Maybe we could get a
little more into why we don't want people to pull what we have in the mempool,
but it's my understanding that Will needs to be somewhere else, so maybe we'll
just wrap it up quickly here.

**Mike Schmidt**: Sure, yeah.  Thanks for joining us, Will.  Any final parting
words?

**Will Clark**: No, thanks for having me, guys.  I would just say, before I do
go, on your privacy question, Murch, of course if you're telling everybody
what's in your mempool in a public way, they can start to identify which
transactions have originated in your mempool before anybody else's, and
therefore we can start to pin down which transactions belong to which IP
addresses perhaps, which is very bad for privacy.  Yeah, I think that's about
it.

Oh, I was going to say, so Bitcoin Core has had this BIP35 mempool message gated
behind special network permissions for that very reason.  We don't want to just
broadcast our mempool on request to any random member of the public.  So again,
another barrier to usage as it stands at the moment.  Somebody must have set up
their Bitcoin Core with bloom filters enabled.  They then need to add a special
whitelisted port to buy into with these special permissions enabled, and then
you can connect your own mobile wallet to it, or something like that.

So, I think even the case where there could be good Samaritan node operators,
who you might think could just turn all the options on and let anybody connect,
I even think that's an unlikely use case as well for us in this case.

**Mike Schmidt**: Well thanks, Will, I know you have other things to do.  Thanks
for joining us and thanks for trying to clean up the Bitcoin Core codebase.

**Will Clark**: Great, thanks very much for having me, guys.

**Mike Schmidt**: Cheers.  I'll take the opportunity, since we did mention the
privacy component here, and being able to determine the origin of a transaction
and its relation to privacy, I'll plug the Optech topics in which we added this
week related to this discussion, the transaction origin privacy topic.  So,
check that out, we have some earlier references to newsletter topics and other
relevant links about transaction origin privacy, including Dandelion discussion
and some other things.

Murch, you sort of talked about why not a mempool message, but what about
thoughts on BIP37; it's sort of been disabled by default already?  It's unclear
on the usage, at least from my understanding.  Is that something that you
personally think should be removed at some point; and is this a good reason to
do so?

**Mark Erhardt**: Yeah, so the big problem with BIP37 is that it basically gives
other participants in the network the licence to make your computer do heavy
computational work, because every peer that requests that you run these BIP37
filters actually makes you run a separate rescan, of whatever blocks were
requested, with that filter that they provide.  So, it's a per-individual-peer
task, and so it's a DoS vector and there is a huge privacy leak in the other
direction, where the peer that requests the BIP37 filter to be run basically
tells you exactly what transactions they were interested in, in the entire
history of the block chain.

So, any node that receives such a request could just run the filter on the whole
block chain and learn exactly what transactions belong to that wallet.  There
might be a few false positives, but it would still be good enough to manage to
basically cluster that wallet completely.  So, I think that we've pretty much
superseded that use with BIP157/158, which is the client-side compact block
filters, where the filter is always the same and you only have to calculate it
once as a node, and then you can serve it to any peer that requests it.  And
they, on their end, query the filter to find whether the block contains
something of interest to them.  So the information, what exactly they're
interested in, does not leak anymore.

It is a little less bandwidth-efficient, but a lot more private and there's no
DoS vector, where the node has to do extraneous computation.

**Mike Schmidt**: So, BIP37's privacy assurances were not strong and it was a
DoS vector for attack and has been superseded.  So, I suppose if this is
something that your project, or that you are using, either the message in some
capacity internally, or BIP37 perhaps, chime in to the mailing list and give you
opinion on your use cases.  This is something that's actively being discussed
currently.

**Mark Erhardt**: The disadvantage of BIP157/158, the compact client-side block
filters, is that you cannot learn about unconfirmed transactions, since you only
get the table of contents of a block.  So, you can only learn or unlearn about
confirmed transactions where the BIP37 filter also worked for unconfirmed.  So
for example, for learning what's still expected to be received, it does not help
at all, and that's a problem for some of the wallet use cases.

**Mike Schmidt**: We have a note from Larry that commented on the Twitter thread
here in response to our discussion, and he mentions, "I think importantly too,
the ratio of compute to network bandwidth is, or can be, very large with BIP37".

**Mark Erhardt**: Yes, but if the node requests a very large range of blocks to
be scanned, then that could be really expensive for the peer that offers the
service.

**Mike Schmidt**: All right.  So, we do a monthly segment pulling out
interesting questions and answers from the Bitcoin Stack Exchange, where there's
actually quite a few experts that opine on, in some cases, seemingly benign
topics with very interesting historical information, and we try to pull out a
few of those each month to discuss.

_How many sigops are in the invalid block 783426?_

The first one we pulled out for this newsletter is, "How many sigops are in the
invalid block 783426?"  I know this made it to the Twittersphere, because there
were essentially some invalid blocks that were mined and if I recall correctly,
I think it was the F2Pool that was creating these invalid blocks.  And so, the
question about how many sigops were in that particularly invalid block was
answered on the Stack Exchange by Vojtěch, and he actually provided a script
that you can use to iterate through all the transactions in a block and count
the sigops.

He noted that there were 80,003 sigops in the block, which actually made that
block invalid, and we linked in the newsletter to the constant, which is 80,000
being the limit; so, it exceeded by 3 sigops making that block invalid and
losing somebody some bitcoins.  Murch, what's a sigop?

**Mark Erhardt**: That's a signature operation, and we generally assign this to
the more computationally intensive parts of transaction validation.  It doesn't
really correspond one-to-one to a signature operation, but there are weights and
we count different types of signature operations more heavily.  In particular,
in this case, what probably happened here for F2Pool is that there has been a
recent surge of bare multisig outputs, and we count each bare multisig output as
80 sigops.  So, you can only have 1,000 bare multisig outputs in a block.  So,
as Vojtěch here writes, this block in particular had over 70,000 sigops from
bare multisig outputs.

People concluded that very likely F2Pool has some sort of custom block-building
implementation and that they correctly accounted for all the transactions that
they included in the block, but missed that their coinbase transaction also
added some sigops, and that's how they overshot by 3 signature operations, which
happened to be a 6.25 bitcoin mistake, or maybe even 6.5 bitcoin, because
there've been a little more fees lately, as some people might have noticed.

**Mike Schmidt**: And if I recall, I think it actually happened more than one
time.  So if that's true, hopefully they've patched that since.  Now, when a
block is built in Bitcoin Core, there is logic to allocate some sigops to the
coinbase transaction already such that when the block is built, this is handled,
and I guess that's why the assumption is that they're not using the block
template from Bitcoin Core?

**Mark Erhardt**: Yeah.  If you build a Bitcoin Core block template, you would
be parsing the coinbase in advance, and that way we can already count it when we
assemble the block.  So presumably, they built the block template without the
coinbase and then had their own mining machines add the coinbase transactions,
which allows them to probably iterate faster with the extra nonce, or something
like that.  I don't know, I honestly am a little out of my depth there; I don't
really know that much about how internally the mining works.  Oh, and I also
wanted to mention, yes, it happened twice; they mined two blocks that were
rejected by the network for exceeding the sigops limit.

_How would an adversary increase the required fee to replace a transaction by up to 500 times?_

**Mike Schmidt**: Next question from the Stack Exchange is, "How would an
adversary increase the required fee to replace a transaction by up to 500
times?"  Michael Folkson was the person who asked this question, and he was
looking at the BIP for ephemeral anchors, which had a little excerpt that
referenced a 500-times increase in the required fees, and he was wondering what
the scenario would be in which that would occur.

Antoine answered and he gave an example of how an attacker could use RBF to
essentially bump, in the example was a 200 vbyte transaction and replacing it
with a 100,000 vbyte transaction, and that would then require, under the RBF
replacement rules, that the feerate would have to be a little bit over 1 million
sats from that original transaction, which is approximately a 500-factor
increase.  Murch, thoughts on that example; and are there other examples of how
you can force somebody to pay 500X?

**Mark Erhardt**: I think I actually want to take another step back from this.
I think that a common misunderstanding of pinning is that people think pinning
makes a transaction worse than it originally was, and that's not the case.  What
pinning does is it makes it harder to reprioritise a transaction.  So, it adds
circumstances to the transaction's proposition for getting mined that make it
harder for the other party to move forward and reprioritise to a higher feerate.

So, what happens here specifically is that adding the child makes the package
that needs to be bumped out of the mempool with the replacement way bigger, a
larger v-size, and since we have to both exceed the feerate of the replaced
transaction as well as the absolute fee making a very large low-feerate child,
attaching that to the to-be-replaced transaction can cause you to need to exceed
a huge amount of size at a higher feerate.  So, you could for example attach a 1
sat/vbyte (sat/vB) huge fee child to a 10 sats/vB transaction, and now the
replacer has to both beat the 10 sats/vB, so needs to go to 11 sats/vB.  But
they also have to beat the transaction's absolute fee.  So, yeah, you can make
it very significantly more expensive.

I think Antoine's example is pretty good here.  And if you are more of a visual
person, and I find this hard to explain in words, just take a look at the Stack
Exchange post.

**Mike Schmidt**: And there's a link in that Stack Exchange post to the Bitcoin
Core hub repository, there's a folder on policy and within that folder, there's
a mempool replacements markdown file, and it outlines the current RBF policy.
So, when you hear Murch saying, "You have to do this, you have to bump it this
much, it has to be this much", these fee bumping policy rules are the thing that
is forcing you to do that to be compliant.

**Mark Erhardt**: Yeah, unfortunately replacement is complicated and not
one-dimensional, and there's been a lot of work and a lot of research on how we
can do better than that, and I hope that maybe in the next year something will
come to fruition.

_Best Practices with Multiple CPFPs & CPFP + RBF?_

**Mike Schmidt**: Well, speaking of complicated fee bumping scenarios, the last
question in the Stack Exchange is on a similar topic, and the question
essentially surrounds the premise that there is a transaction that's in the
mempool and you want to fee bump it and you've attempted to use CPFP to fee
bump; but your CPFP attempt to fee bump did not result in the transaction
confirming in the time that you had hoped for, and so you wanted to take another
attempt at fee bumping.  The question is, "What's the best practice to fee bump
an attempted CPFP?  Should you use CPFP again; should you use RBF again?" and
Suhas gets into a lot of the considerations around that scenario.

I think it would be probably difficult to articulate all of that here, so I
would point you to the newsletter and jumping into the details that Suhas
provided.  But Murch, I don't know if there's anything in that answer that you
wanted to tl;dr for the audience?

**Mark Erhardt**: Basically it boils down to, it depends what exactly you want
to achieve and what your situation is, because if you just want to bump the
original transaction, then you might just bump the parent again and shoot the
old one into the wind.  Then you might want to RBF the original bumping
transaction.  Anyway, it depends very much on what exact scenario you're looking
at and whether, for example, you want to conserve the original parent
transaction, because a lot of services and wallets work with the txid, and if
txids get replaced because the same payment is made with a newer transaction on
RBF, that might confuse some software.

So, you might have reasons why you only want to replace part of it or, yeah,
it's complicated and it's not easy to answer!

**Mike Schmidt**: Hopefully, at some point, there's a better solution.  We can
move onto the releases and release candidates' section of the newsletter.

_LDK 0.0.115_

The first one we noted here was LDK 0.0.115, and this is a full release.  And in
addition to some features and bug fixes that you can drill into the release that
it's for, we noted in the newsletter particularly more support for offers,
BOLT12, and then some security and privacy improvements as well.  And I believe
that offers in LDK is still experimental, so I think you have to use the
particular flag to be able to use that.  Any other thoughts on the LDK release,
Murch?

**Mark Erhardt**: I love the name of the release.

**Mike Schmidt**: Oh, now I've got to click into it again.

**Mark Erhardt**: "Rebroadcast the Bugfixes"!

**Mike Schmidt**: It's good to see people are still having some humour in
Bitcoin.

_LND v0.16.1-beta_

The next release we noted in the newsletter was LND v0.16.1-beta, and we
mentioned that this is a minor release with some bug fixes and improvements.
Murch, did you want to elaborate on that; it sounds like maybe we need to be a
little bit stronger with our wording with this particular release?

**Mark Erhardt**: Yeah.  Somebody contacted me after we released the Optech
Newsletter to let me know that this release does include some important security
fixes, and they wanted to encourage that when this release comes out, people
upgrade to the 0.16.1 version in a timely manner, because there are some
networkwide security issues that are being addressed in this release.

**Mike Schmidt**: There was one piece of this release that we went into more
detail on, and that was the change in the default CLTV delta, being increased
from 40 to 80, and we reference an older newsletter where LND actually had
changed that same delta from I think 144 down to 40, and it's now back up to 80.
Murch, am I correct in understanding that this CLTV delta is essentially a sort
of timeout with the Hash Time Locked Contract (HTLC)?

**Mark Erhardt**: Yeah, I believe so.

_Core Lightning 23.05rc1_

**Mike Schmidt**: The final release that we noted was Core Lightning 23.05rc1,
and I jumped in, I know we don't like to spoil our releases for our
implementations here, but just a couple of notable things and we can get into
more details in a future episode potentially when this is officially released.
But blinded payments are now supported by default with this release, and there
is also some JSON-RPC support for PSBT v2, which seemed interesting.

_LND #7564_

We had four notable code and documentation changes that we covered in the
newsletter this week, the first one being LND #7564, now allows users of a
backend that provides access to the mempool to monitor for unconfirmed
transactions.  And if I recall correctly, the use case that's noted here,
although it may be elaborated on in a future pull request, is being able to look
at a particular UTXO for when a spend occurs related to that UTXO.  So, that's
obviously useful for LN implementations and HTLC work, being able to see that
sooner, instead of waiting for a confirmation.

_LND #6903_

The next PR that we noted was also to LND, #6903, updating the openchannel RPC
with a new fundmax option.  Essentially, reading through the motivation for this
particular pull request, the use case here is that folks that were using LND in
various scenarios wanted to just allocate all of their funds to the channel, and
there wasn't a programmatic or automated way to do that.  So, what folks were
doing is that they were kind of guesstimating what they would need to allocate
to a channel, and then trying, in their own brain, to allocate for any sort of
fee requirements.  That resulted in small change remaining in the wallet, as
opposed to everything being allocated to the channel.

So, this fundmax option when opening a channel will handle all of that for you,
so you don't have to guesstimate on fees and then end up with this small
remaining change, which you really intended to be in your channel.  Murch,
thoughts?

**Mark Erhardt**: That sounds like a great quality-of-life improvement, just for
usability, sort of similar to the sendall PR that we added to Bitcoin Core last
year just to move all of your funds at once.  Just something that probably a lot
of people, or not a lot, but some people have bumped into over the years, and
now there's a function that just covers the use case for good.

_LDK #2198_

**Mike Schmidt**: We have two more PRs, LDK #2198, increasing the amount of time
that LDK waits before sending a gossip message in the event that a channel is
down.  And digging a bit into this pull request, it sounds like LDK waited about
<!-- skip-duplicate-words-test -->a minute previously before determining that that channel was down and labelling
that as down, and other implementations were maybe ten times longer than that.

So, what was happening was, if the connectivity was slow over Tor, for some
reason, and that minute had gone by and that timeout had occurred, LDK was
labelling that channel down.  What was happening then was that the other
implementation wasn't labelling the channel down, and the other node was
actually still up.  So then, it looked like LDK was actually the offender,
because LDK was now getting labelled as down, because it had already labelled
the channel as down itself.  So now, LDK was actually looking bad, when it was
the one just being a little bit more aggressive about that timeout period.

They've changed that for that usability reason, and also there's some spec work
that is being done that could eventually standardise this timeout to be in terms
of blocks instead of in terms of minutes or timestamps.  So, they decided to
make that timeout go to ten minutes, which is close to what would be a one-block
timeout for the future spec when that gets actually settled.

**Mark Erhardt**: Yeah, another concern that maybe was a little unclear here is
that every time you change something about a channel, you need to gossip that
across the whole LN, so that any other LN participants that want to potentially
route through that channel would know that this channel's currently unavailable.
So, if there's just really a short period of time in which a node doesn't
respond, say it's cycling or it's having a connectivity issue, you send one to
disable the channel and then another to enable the channel within a short period
of time that propagates around the whole network.

So, being a little more conservative in notifying the whole network about a
state change seems reasonable.  And the way I interpret that last paragraph on
the opening comment is, I think that there will be a general limit on how often
you are allowed to update the information for a channel, so this will just mean
that you blow your chance to comment on the state of the channel with this
premature notification, and making it longer makes it less spammy, less noisy.

_Bitcoin Inquisition #23_

**Mike Schmidt**: Last PR for this week's newsletter is to the Bitcoin
Inquisition repository, Bitcoin Inquisition #23, adding pseudo support for
ephemeral anchors.  And, as a reminder, Bitcoin Inquisition is sort of a test
bed for potential soft fork or other policy-related changes, and so you can get
a change in there as a way to test that change on signet, but also test that
particular change's interaction with other potential changes.  So, there's a
series of efforts going on there now to add different soft fork proposals,
including OP_VAULT.  And in this case, the ephemeral anchors proposal is
partially implemented in this pull request and there's still other work to be
done.  Murch, did you get a chance to take a look at that?

**Mark Erhardt**: I'm staring at it right now.  So, my understanding is that
they are just trying to get some real-life testing on some of these things that
they've been working on for a few months.  We've had Greg on here a few times to
talk about ephemeral anchors and package relay especially, so it's nice to see
that these changes are being put into a live network to get some feedback
whether everything is going to turn out the way they want to.

**Mike Schmidt**: And the ephemeral anchors proposal does depend on v3
transaction relay, and that is not included with this particular piece, but
there are components of the ephemeral anchors that are testable with this pull
request being merged into Inquisition.  So, it's not the full thing, but there
is some tinkering that can now be done there that wasn't possible before.

**Mark Erhardt**: Yeah, I guess v3 is quite a bit out still because first,
generally a package relay would need to make a little more progress, I think,
before it would be picked up, so I'm not expecting that necessarily to be mature
this year.  But yeah, early testing is never a bad thing.

**Mike Schmidt**: All right, well thank you all for joining us, and we'll see
you next week for #249.  Cheers.

{% include references.md %}
