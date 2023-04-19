---
title: 'Bitcoin Optech Newsletter #245 Recap Podcast'
permalink: /en/podcast/2023/04/06/
reference: /en/newsletters/2023/04/05/
name: 2023-04-06-recap
slug: 2023-04-06-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Sergi Delgado Segura to discuss [Newsletter #245]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/68345636/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-3-10%2F3bdcea63-7ec8-0854-25fe-913e04492aeb.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #245 Recap on
Twitter Spaces.  It's Thursday, April 6, 2023.  We'll do some quick
introductions and jump into the newsletter.  I'm Mike Schmidt, contributor at
Optech and Executive Director at Brink, where we're funding Bitcoin open-source
developers.

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs.  This week, I have
been looking at a BIP draft for transaction terminology.

**Sergi Delgado Segura**: Hi, I'm Sergi, I'm an open-source dev supported by
Spiral at the moment.  This week, I've been featured in the Optech regarding
watchtowers and accumulators and stuff like that.

_Watchtower accountability proofs_

**Mike Schmidt**: Thank you for joining us.  Yeah, it's not every day that we
have a watchtower expert on our podcast, and so thank you for joining.  And
perhaps as we jump into it, you could maybe provide just a quick overview of
what are watchtowers, and then maybe give your thoughts on the state of
watchtowers these days.

**Sergi Delgado Segura**: Sure.  I don't like the word "expert" by watchtower,
by the way, I've never called myself something like that, but yeah, thank you!

So, regarding watchtowers, for someone who is not familiar with the concept, the
idea I think is pretty simple.  So, we all may know we are used to using
Lightning, that when we use Lightning, we need to be either always online
because we have a node and we host the node, and so on, or we are using a
custodial solution where someone else is running the infrastructure for us and
then they are always online so they can receive and send payments when we need
to.

This is quite different from the approach followed by, let's say standard
Bitcoin itself, with no channels, and so on, mainly because you don't need to be
online as long as you don't have to send a transaction.  I mean, you may not
even need a node to receive transactions, as long as whoever wants to pay you
has an address they can pay you to.  But through Lightning, it's not that easy.
The idea is that your node has to be online in order to be able to accept those
payments, meaning that if you are not online, then some nasty stuff may happen.
The idea is that as long as you are not offline most of the time, or as long as
you're not offline for long periods of time, you may be okay, because there are
some mechanisms in place to prevent your counterparty trying to cheat and close
a channel with an old state.

So, the idea is that I would say we open the channel and we perform some
transactions and then at some point, we want to close a channel.  Every single
point between the opening and the close of the channel are valid transactions.
So, if a counterparty's not there to claim what's a valid state or what's a
later state, then the other party can just say, "Hey, this is the later state
and I'm going to close the channel with this".  And as long as no one complains,
that's going to be the truth for the rest of the network, because there's
privacy involved here, so no one else knows what's the latest state.

Then, how watchtowers come into the picture is mainly being an observer of those
channels without actually knowing what's going on, but having enough information
to see if someone is trying to close a channel with an old state.  And if that's
the case, then the idea is that the tower will just react to that action being
performed with proof that was actually not the latest state, and will penalize
the closure, let's say, of the party that tried to close with the old state, by
sending all the money from the channel to the counterparty, which is in
principle the act that it has employed the watchtower to act on their behalf.
So, that's give or take how it goes.

**Mike Schmidt**: Perfect.  And what's the state of watchtowers in the ecosystem
currently in terms of however you want to talk about that, adoption, different
types of software, challenges?

**Sergi Delgado Segura**: So, regarding software, as far as I know there are at
least, or there's been at least four different implementations of watchtowers
that have been dedicated to different projects.  So we have, in order of
appearance, I would say, and as far as I know, the first watchtower to ever be
implemented was done by Bitcoin Lightning Wallet, which is a soft fork that is
no longer maintained or used.  That changed to Simple Bitcoin Wallet, and then I
think now it's called OBW something like that.  I may have interchanged the
order of the towers, and so on, I don't fully remember now.  I think it was
Bitcoin Lightning Wallet, the first one.

They had an implementation, called Olympus, which as far as I know was the first
implementation of watchtowers ever to be deployed in the world.  After that, it
came LND, with the LND watchtower, which followed give or take the same
principle.  The main difference between one and the other was that Olympus was
using some kind of tokens to pay for the storage of the watchtower; whereas, LND
was using a completely altruistic watchtower.  Both of them were designed in a
way that only worked with that implementation, so Olympus worked with Bitcoin
Lightning Wallet and LND worked with LND's, so no interoperability there.

Then there's the Eye of Satoshi, which is the implementation I've been working
on for a while, which tried to put some solution in place for these
interoperability issues.  So, the angle was, "Hey, let's have something that can
work with any kind of node or wallet; no matter what you're using, you can have
a watchtower and connect to it.  Currently, it's only working for C-Lightning,
mainly because we don't have a standard or a common way of doing things, even
though it's give or take the same what we are doing, but there are some
differences and it looks like we haven't agreed on how to properly do things.

Then the last one, which came give or take at the same time as the Eye of
Satoshi is Electrum's.  They have their own implementation of watchtowers in
Python, if I'm not mistaken.  And that's it for what I know.  There may be
something else that I'm not aware of, but that's what I've heard of at least.

**Mike Schmidt**: You mentioned there some incompatibility or differences in
approach to watchtowers between these different pieces of software.  Is there
discussion around a BOLT or a bLIP or some way to standardize that, or is
everyone's paving their own path here?

**Sergi Delgado Segura**: It feels like everyone was paving their own path at
the beginning.  At some point when I started working on this, I tried to gather
the people that were working on watchtowers and tried to write a BOLT for that.
And I did; there's a proposal for BOLT 13, which was supposed to be the
watchtower BOLT.  But apart from Antoine Riard and people from CLN, both Rusty
and Christian, not many more people are fully engaged in the discussion of the
BOLT.

So at some point, I once tried to start implementing it with the ideas I've
picked on from the ones that were already implemented, plus the idea they had to
try to make it a little bit better, and there hasn't been much discussion
regarding the BOLT after that.  Honestly, after seeing all the drama, let's say,
regarding BOLT 12, it drove me off a little bit to try to push this further in
terms of standardization.  It feels like if we want to do it, then that's kind
of a bottom-up thing instead of a top-down approach.  It's not like, "Hey, I
think this should be done in this way, so let's do it"; people need to really
care about this.  And it feels like most of the node implementors, or node
implementations are focused on other stuff they feel is more important or more
relevant, so there hasn't been that much interaction, to be honest.

**Mike Schmidt**: We can start shifting a bit towards your Lightning-Dev mailing
list post here, and maybe before we go into the details, you could provide the
answer to this question which is, if we're seeking accountability to
watchtowers, I'm wondering if you're proposing this as a more proactive solution
because it tends to be common that you need to prove accountability; or if this
is something that is reactive and this is actively going on currently and you're
trying to mitigate some misbehaviour or downtime from watchtowers?  And then,
maybe we can get into some of the details.

**Sergi Delgado Segura**: Well, I think currently there hasn't been that much
use of towers generally, mainly because the main use for towers is for mobile
devices instead of desktops or server nodes, where those may be mostly online or
they may be more beefy in the sense that they may have redundancy in terms of
both power supply or internet provider, and so on and so forth.  And since
there's no implementation that actually works with mobile nodes or mobile
wallets, the main use case, let's say, is not covered, or the use case that
makes more sense is not covered.

So, it's not like I'm trying to mitigate something that's going on, it's more
like I'm trying to design something that may be useful in the case that this
happens.  Because, if you think of a future where people are using towers, how
do you decide what to use?  Are you going to trust blindly in someone who is
providing a service without knowing if they are reliable in any way; or, are you
just going to connect to a friend of yours who may be providing this service and
you trust?  The latter doesn't scale.  It may be a solution for some, but if you
are just trying to offer these as a service for the whole network, there should
be a way of distinguishing between who is actually providing a good service and
who is not.

Imagine that you're trusting or blindly thinking that your watchtower's going to
cover you if something bad happens, then at the end of the day they're not doing
anything, then you may be lowering your security by trusting, which you
shouldn't by the way, but trusting this watchtower to cover your back.  So
that's the main idea.  You shouldn't be trusting any, but in order for them to
be encouraged to behave, then there should be a way of calling them off if
they're not behaving.

**Mike Schmidt**: What is that way?  Maybe we can get into your proposal here a
bit.

**Sergi Delgado Segura**: The way I see it is the way that the Eye of Satoshi
has been implemented since the very beginning.  So, putting in accountability is
not something that is hard to do, you just have to have signed agreement between
the thing that you're sending to a tower.  So, in the Eye of Satoshi, but there
are other ways of doing it, the main idea is that the tower is covering you for
a certain amount of time, let's say, I don't know, 1 million blocks, or
something like that; and then when you register you agree with the tower on them
covering you for that time and they sign a receipt saying, "Hey, I'm going to
cover you from block 1 to block 1,000,001", then every time you send something
to a tower, you can also sign it and the tower returns a signed receipt saying,
"Hey, you have sent this to me and I'm supposed to respond if this happens".

So, the idea is that both the user and the tower have signed receipts of the
agreement of both parts, of the watching of this channel in these specific
states.  And then in the end, if a breach is seen onchain and it belongs to
something that the user knows it has sent to a tower, the user can always go and
say, "There's this breach onchain, I've sent this piece of information to the
tower", you can actually verify that this piece of information belongs to that
breach.  And the tower was supposed to respond because I have the signature
saying, "You have sent this to me", but the tower hasn't responded.  So, if
that's the case, you can always call off the tower and say, "You're not doing
your job so no one should be trusting you in doing so, because you're not".

On the other hand, if the user has sent some data that doesn't make any sense to
<!-- skip-duplicate-words-test --> the tower, the tower could also prove that that data was the one being sent and
that's the reason why they couldn't respond.  Maybe the transaction sent to a
tower had a ridiculously low fee, or it was actually invalid, or whatever the
reason was that they were not able to respond.  So, it's like an insurance for
both sides.  In one place, you have the user that can claim that the watchtower
is misbehaving and no one should use it; and on the other hand, you have the
tower that if they haven't responded for a good reason, they can prove that
that's the case.

The issue with that is obviously if you're going to be exchanging signatures for
every exchange of information you're doing between the user and the tower,
that's going to pile up at some point, especially on the user side.  The tower
side is not that important, to be honest, because you're already storing a lot
of information for the user.  But the user should be as light as possible, and
having to store a signature for every exchange of information may end up being
an issue that we would like to minimize as long as we can, or as much as we can.

**Mike Schmidt**: And so I see that you've spoken with Calvin Kim, I know that
he does some work on Utreexo and there's some work with accumulators there that
helps decrease the amount of storage that's required.  Can you talk a little bit
about that discussion and how you've come to think about accumulators as solving
some of the space concerns?

**Sergi Delgado Segura**: Yeah.  There are two things here that don't work,
let's say, or two issues that arise when you try to follow this approach, in
contrast with just not having accountability at all.  The first is what I was
saying, right; data piles up and then you want to minimize as much as you can
how much it piles up.  The other issue that arises when you try to work with
accountability is data deletion, which is something that may be in the interest
of both parties to allow.  Let's take out accountability for a second and see
how this may work for a normal watchtower.

The first thing to have in mind is that the watchtower doesn't know anything
about channels.  The user is sending encrypted information to a tower, and there
is some mechanism so they decrypt this information when it's needed and they use
that to close channels when it's needed.  There's no need to enter into how this
works, but the idea behind that is that the tower doesn't know what channel or
channels it's looking at.  So, the idea is that when a channel is closed, the
tower doesn't know.

The only way for the tower to know that a channel is closed is by the user
telling the tower, "I've closed this channel", but we don't want that because if
we do, then the tower may be able to link all the data that the user has sent to
a tower and say, "All this encrypted data that I've received actually belongs to
this channel, so now at least I know how many payments were performed in that
channel and the frequency, if I was let's say logging the timestamp of every
single piece of data I had received from the user", and so on and so forth.  We
don't want that.

Neither do we want the tower to know if a channel was closed.  Imagine that it's
a normal channel and it's closed not unilaterally, like both parts of the
channel agreed on closing it.  In principle, no one should know that was a
channel to begin with, and then if we tell the tower, "Hey, we've closed this
channel", then they know.  So, we're trying to minimize the amount of
information we give the tower, in the same way we're trying to minimize the
amount of information we give any other actor in the network that needs not the
two ends of the channel.

So, long story short, we want to be able to tell the tower, "Delete this data
because it's useless.  We've closed the channel, so we are not going to need
this anymore, and then maybe I can use these logs that you provide me in my
subscription, or whatever means I have paid you to look for my data, to host
information for other channels, so I don't have to pay you again for more data
if I can just collate all data and add more data".  Anyway, the idea is that if
you are able to tell that to a tower without disclosing what channel you have
closed, and so on, then you can reuse some of your slot or space in the tower.

That, without accountability, is pretty straightforward.  You just tell a tower,
"Delete this piece of data, that piece of data and the other piece of data", and
the tower does, potentially, and that's it, there's nothing more to be done.
But if the tower is being accountable, then there's an issue with this, because
in order for the tower to delete something, it has to give proof that the user
has requested this data deletion, because otherwise the user can just say, "Hey,
delete this", the tower does and then the user later on shows a receipt saying
that the tower was supposed to look for something and it hasn't.  So now, the
tower has misbehaved but actually, the user requested some data deletion, just
the tower didn't log that.

So the issue with that is that in order to delete some data, you have to store
some data.  I mean, it's mad, in the sense that you can build the storage of a
tower just by saying, "Delete this and delete that", and that may need to be
stored for a really long time.  So, that is something that is not idea.  So, you
have these two things in place: first, data builds up; second, data deletion is
a pain in the neck, so we want to mitigate this.

One of the ways of doing so is actually using accumulators.  If we can have a
structure in where we can prove membership and non-membership of data, then we
can just, instead of storing signed receipts for every single interaction we
have between the user and the tower, then we can just store the signature of all
accumulated data.  And then at some point, if we need to, we can say, "Prove
that this data belongs to the set or that this data doesn't belong to the set",
for instance.

If you want to prove that the tower has misbehaved and some data was supposed to
be there, you say, "You were supposed to respond to this.  Prove that this piece
of data was not in the set".  And if they cannot prove it, it's because it's in
the set, and then it means that they are misbehaving.  Or, the other way around.
<!-- skip-duplicate-words-test -->The tower can always say, "I can prove that that was not part of the set, so you
never sent that data to me.  And since we both signed the head of the
<!-- skip-duplicate-words-test -->accumulator, it means that you agreed that that was not in there at the very
beginning, so you're actually lying".

So, the main idea is that instead of having to change and keep that many
signatures, we may do better just with one accumulator and the signature of the
whole state.  That's why I got in touch with both Salvatore and Calvin, because
they both work in hash-based accumulators, I don't fully remember the name, but
it's hash-based accumulators in where addition is really easy.  I think it's
additive hash-based accumulators, something like that; I don't fully remember
the name.  It felt like that may be a solution for this, not a straightforward
one, because it looks like for both Utreexo and Salvatore's accumulator,
membership is easy to prove, but non-membership is not.  So, yeah, that's one of
the reasons why I ended up sending the mail, because I'm not that familiar with
all this, other people may be.  So, let's have a discussion and see if there's
any construction that makes sense and can be optimized.

**Mike Schmidt**: Murch, I've been monopolizing the questions, do you want to
ask anything?

**Mark Erhardt**: No, you've been doing a great job of asking.  It's very
fascinating how complicated everything gets when you want to make sure that
everybody's doing their job and everybody can prove that they're doing their job
and haven't been cheating.  And all that to just make sure that nobody in a
Lightning channel is cheating.

We actually recorded a podcast episode with Sergi a few weeks ago, a couple of
months ago maybe, on the Chaincode podcast, where we also went into watchtowers
in depth.  So, if you're interested in the topic, you can also listen to that.
I was curious mostly about the node deletion capability.  So, you're saying that
the endlessly growing data that the watchtower and the user both have to store
in order to prove that they gave the job to the watchtower, or that the job was
rescinded by the user to the watchtower, you are kerbing the endless growth of
that by having time limits on how long the watchtower is storing that; and also
having in the signed message a timeout until when it is valid; is that right?

**Sergi Delgado Segura**: Yeah, exactly.  It is that the user has a
subscription, well at least in our approach; it has a subscription which is
bounded and after that ends, then the tower ends up deleting that data.  So, if
the user wants to renew that subscription, then they can just by paying again,
and then the tower will store or keep that information for longer.  But once the
subscription is expired, then there's actually some grace period, and so on,
just in case the user forgets, but at some point, the tower will delete the
data; I mean the time you have to complain about something, if you work with
accumulators.  If you don't work with accumulators, you actually have data that
you can prove for life, let's say.

But if you're working with accumulators, the tower is the one that has to end up
providing the data that they are supposed to be hosting, so at some point if you
try to say, "Hey, you cheated me three years ago", it's like, "Yeah, I don't
have the data anymore, so good luck trying to prove that".  That doesn't happen
if you're not using accumulators, because the client may have all the data
necessary to make this work, but it means that they also have to store way more
data on their end, which we are trying to prevent, or improve.

**Mark Erhardt**: Understood.

**Mike Schmidt**: How has feedback been from the mailing list and elsewhere on
your initial post and discussions you've had, either on the mailing list or
outside of that?

**Sergi Delgado Segura**: So, I got feedback from both Calvin and Salvatore
since the very first day I was looking into this.  I pinged them directly before
sending the email.  I don't think anyone has replied to the mailing list post,
but as I was saying before, not many people are interested in watchtowers at the
development level, so that's usual.  I'm checking the email just in case someone
has replied and I haven't seen, but I don't think so.  It feels like everyone
has a lot on their plates and if you don't ping them directly, or it's something
that is related to their work, you may not get a reply.  But hey, listener, if
you're listening to this and you're interested in watchtowers or accumulators,
yeah, ping me, let's have a chat.

**Mike Schmidt**: Great call to action.  Anything else you'd say before we wrap
up on this news item?

**Sergi Delgado Segura**: No, not really from my end.  I think we've covered
most of what the proposal is about.  If anyone is more intrigued about how it
is, there's a link on both the mailing list mail and the Optech newsletter.
There's a gist about the proposal itself, so it's not that long to read.  I
think you can read it in like ten minutes and understand it pretty
straightforward.  So, yeah, give me a ping, or whatever.

**Mike Schmidt**: Murch, anything before we move on?

**Mark Erhardt**: No, I think that's all.

**Mike Schmidt**: Well, thank you for joining us.  You're welcome to stay on, we
have a bunch of Lightning-related PRs later in the newsletter if you care to
comment on any of those.  But otherwise, if you're busy with other things,
you're free to drop off as well.

**Sergi Delgado Segura**: I'll stay around just in case.

**Mike Schmidt**: Awesome.  Next section of the newsletter is releases and
release candidates.

_LND v0.16.0-beta_

We have a couple that we've covered already: LND v0.16.0-beta, so I think we
were at RC5 last week, now we're at the official beta.  We have promised that we
will have LND folks on to explain this in depth in the future, so we can skip on
from this I think from now.  Obviously, call to anybody who's using LND to try
out the beta and make sure they provide feedback to that team.

_BDK 1.0.0-alpha.0_

The second release is BDK 1.0.0-alpha.0 and we actually had Alekos on
previously, and that episode is published, it's from Newsletter #243, to get a
little bit more detail on that release and the rearchitecting that they've been
doing there.  Murch, any feedback on LND and BDK releases?

**Mark Erhardt**: I think I just want to call to action in the sense that people
that are using these projects downstream to build other projects, please do read
release notes.  We had a little bit of an outcry about a CLN release a couple of
months ago, maybe last month, because there was something being deprecated which
was announced for a year and had been missed.  So I think when release notes
come out, especially for major releases, you do want to go over them and read
them if you depend on them.

_Core Lightning #5967_

**Mike Schmidt**: Our first PR this week is from Core Lightning #5967 adding a
listclosedchannels RPC, and I think the impetus for this RPC was actually
related to information about old peers being discarded.  And as part of
retaining that data about old peers, there is an RPC added as well to be able to
pull closed-channel information, which includes some of that peer-related
information that was previously being discarded.  Murch, Core Lightning #5967
thoughts?

**Mark Erhardt**: It sounds good that you can now see what channels were closed,
especially when they were closed while you weren't staring at your computer and
still want to figure out what happened.

_Eclair #2566_

**Mike Schmidt**: Next PR is Eclair #2566, adding support for accepting offers.
So I think previously, paying offers was supported by Eclair, but now there is
capability to receive offers as well.  And as a reminder, offers are BOLT 12,
and the implementation detail for Eclair here on accepting was there's a plugin
that you need to implement, which handles the creating of the offer and also
handling the invoice requests and payments associated with that.  And Eclair
also notes in the PR, in the documentation, that offers are still experimental
and the details can change, but feel free to play with that in Eclair now.

**Mark Erhardt**: The way I understand this approach here is that they are
putting it into a plugin so that they don't have to update their main program's
logic, but can still already have this external determination of whether
something should be accepted, and that way can start experimenting with them on
the network.  So, it sounds to me that in the last few months especially, the
speed on offers has been picking up and, I don't know, maybe this is the year of
offers.

_LDK #2062_

**Mike Schmidt**: LDK #2062, which implements BOLT #1031, #1032 and #1040, and
we note in the writeup here different newsletter coverage of each of those.  The
idea here is that in Lightning, the final node in a route has stricter
requirements on the Hash Time Locked Contract (HTLC) contents compared to
intermediate nodes along that route, and that can allow for probing, which could
be used to determine whether or not the next node is the destination of the
payment, which is obviously not great from a privacy perspective.  So, a series
of these changes, which allows overpayments, can help mitigate that probing
attack, and that applies in a bunch of different scenarios that we outline here.

Also in the newsletter, we provide the example of Alice wanting to split a 900
sat payment into two parts, but in the case of the multipath payments, maybe the
two routes that she was going to route through require 500 sat minimum amounts;
and with the spec change, she can now send two different 500 sat payments
totalling 1,000 sats instead of that 900 sats, and then that overpayment of 100
sats can allow her to use her preferred route.  Murch, thoughts on this probing
mitigations?

**Mark Erhardt**: I was just wondering how often this would occur in practice,
because I think when the forwarder fumbles an attempt and actually undershoots
-- so the idea is basically if you have multiple routes, or if the sender wants
to attach a few sats extra so that it's not an exact round amount and there
might be plausible deniability for the receiver that they're not the final
destination, but rather another hop.  But I was just wondering, if someone was
actually probing in order to determine whether the next hop is the receiver,
wouldn't the first time they attempt that and they forward an HTLC that is
obviously short, wouldn't that be an obvious tell that they're trying to do this
and we could just ban them?

Anyway, this sounds like more privacy work, more being lenient on the end where
overpaying is fine, we accept tips for a privacy benefit.  So sorry, I'm
rambling.

_LDK #2125_

**Mike Schmidt**: I think we can move on for now.  LDK #2125, adding helper
functions to determine the amount of time until an invoice expires, so a little
helper PR that does three different things.  It will give you the unix timestamp
for duration since the Unix Epoch, and that represents the time at which the
invoice expires; there's another helper function for the time remaining until
the invoice expires; and then there's another helper for duration remaining
until the invoice expires if you give it a certain time, so the delta, the
duration between those differences.  So, it seems good.  Murch, any thoughts?
Thumbs up?

**Mark Erhardt**: Yeah.

_BTCPay Server #4826_

**Mike Schmidt**: Okay, we've got three different BTCPay Server PRs.  The first
one is #4826, allows service hooks to create and retrieve LNURL invoices.  It
was mentioned that this was done to add support for NIP-57 zaps to BTCPay
Server's Lightning address features.  Murch, what's a NIP?

**Mark Erhardt**: I believe that stands for Nostra Improvement Proposal.  So,
nostra is a messaging or short blogging platform that works on the basis of a
federated system of -- well, not even federated; just relay stations that you
can subscribe to and post your nostra messages to.  And then, whoever else is
subscribed to these relay stations will receive the ones that they're interested
in.  It's been quite popular in the past few months, I'm sure people must have
heard about them since.

Anyway, one of the things that's interesting there right now is that people are
trying to implement Lightning payments as a means to encourage and thank for
messages, sort of like a thumbs-up on Reddit, or the Like on Twitter; you would
instead send a few sats, and the term for this is called a zap.  So, there was a
little bit of a kerfuffle on Twitter last week where people noticed that almost
all of these zaps are facilitated by custodial Lightning services and they
wanted more support for non-custodial Bitcoin platforms to offer zaps.  So, I
see BTCPay Server moving quickly to step in here.

**Mike Schmidt**: So, essentially this NIP-57 is a way to standardize those
Lightning zaps on nostr?.

**Mark Erhardt**: I have actually not verified that but if you say so, I believe
you.

**Mike Schmidt**: We'll roll with that!

_BTCPay Server #4782_

Next BTCPay Server PR is #4782, adding proof of payment on the receipt page.
And I think before this change with BTCPay, on the receipt page they would show
the BOLT 11 as the proof of payment, whereas now that's been changed to add the
preimage as an actual verifiable proof of payment on the receipt page now.  Any
comments on that, Murch?

**Mark Erhardt**: Not really; nothing from me.

_BTCPay Server #4799_

**Mike Schmidt**: And then the last BTCPay Server PR is #4799, adding the
ability to export wallet labels for transactions specifically.  We had covered
this in the newsletter as the BIP was proposed and then assigned.  So, this is
actually BIP329 and it standardizes the way that wallets can assign labels to
wallet-related information, so transactions, addresses and other pieces of
wallet data.  And in this example, BTCPay has the export capability specifically
for transaction data, so you can essentially say, "This transaction was for a
payment to this merchant", or whatever sort of notes you might have about a
transaction, and then you're able to export that in that standardized wallet
label format.

Then they also noted that BTCPay may add support for other wallet data, and I
<!-- skip-duplicate-words-test -->believe they mentioned that that would be address information.  So, good to see
adoption there.

**Mark Erhardt**: Yeah, I just like the adoption of this, it will make it much
easier to keep accounting intact because previously, even if you could recover
all of your financial data, or the actual transaction data and UTXOs if you had
a backup of the wallet, you would lose all the context, and context is very
important for the whole accounting and maybe even reporting use cases.

_BOLTs #765_

**Mike Schmidt**: Last PR for this week is to the BOLTs repository, and that's
#765, adding route blinding to the LN spec, yay!  I think that PR was originally
opened over two years ago and we have talked about this a bit, different
implementations, adding different support for route blinding.

The benefits of route blinding, there's a few notable ones: providing sender and
recipient anonymity when you're sending onion messages or receiving onion
messages; and then recipient anonymity for BOLT 12 offers; and then recipient
anonymity when receiving payments; and then allowing the use of unannounced
channels in invoices, without actually revealing those unannounced channels; and
then also, forcing a payment to go through a specific set of intermediaries, if
for some reason you want those intermediaries to witness the payment.

So, those are the benefits, it's nice to see that was merged.  Murch, do you
have thoughts on that?

**Mark Erhardt**: I just wanted to point out that it seems to be exactly the
two-year birthday of that PR!  I think also, there were previous approaches that
did not end up making it.  So, there was something called rendez-vous routing,
and there's also trampoline payments.  I think trampoline payments are in use,
but rendez-vous routing got superseded.  So, the idea is even much older.  I
think it's just that under the name of route blinding, it's been around for at
least two years now.

**Mike Schmidt**: And the author of this PR, in one of the documentation pieces
of this change, actually notes those competing proposals and pros and cons to
those proposals against route blinding.  You mentioned rendez-vous routing, and
I think there's also something called HORNET, that I guess is also contrasted in
the actual route blinding marked-down file that is in this PR.  So, if you care
just jump into that to see some of the differences.  Murch, any announcements or
anything before we wrap up?

**Mark Erhardt**: Nothing from me this week.

**Mike Schmidt**: All right, we kept it to 45 minutes this week.  Thank you to
my co-host, Murch, and thank you to Sergi for joining us and thank you all for
listening.  If anybody has a question real quickly, feel free to request speaker
access.  I think there was a comment here.  No, it looks like it was just an NFT
spam in our Twitter thread.  So, any questions, comments?

**Sergi Delgado Segura**: I just want to say thanks for inviting me by the way,
guys.

**Mike Schmidt**: Yeah, thank you for your insights.  All right, we'll see you
all back here for next week #246.  Cheers.

**Mark Erhardt**: Goodbye.

{% include references.md %}
