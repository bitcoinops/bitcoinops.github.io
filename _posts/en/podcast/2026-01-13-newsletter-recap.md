---
title: 'Bitcoin Optech Newsletter #387 Recap Podcast'
permalink: /en/podcast/2026/01/13/
reference: /en/newsletters/2026/01/09/
name: 2026-01-13-recap
slug: 2026-01-13-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
René Pickhardt and Craig Raw to discuss [Newsletter #387]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-0-14/416106221-44100-2-197cda762d308.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Optech Recap #387.  This week we're going
to talk about wallet bugs in Bitcoin Core that we talked a bit about last week;
we have a discussion of Ark as a channel factory for Lightning, in addition to
its payments use case; and then we have a draft BIP for silent payment
descriptors that we're going to talk about.  This week, Murch, Gustavo and I are
joined by Craig Raw.  Craig, you want to introduce yourself briefly?

**Craig Raw**: Sure.  I am the developer of Sparrow Wallet, which is a desktop
Bitcoin wallet, it's been around for a while, and recently been doing a bit of
work into silent payments.

_Bitcoin Core wallet migration bug_

**Mike Schmidt**: Awesome.  We're also going to be speaking with René Pickhardt
in a separate recording that we'll have later in the show.  We're going to jump
into the News items, first one titled, "Bitcoin Core wallet migration bug".  We
touched a little bit on this, although we didn't have as much information as we
do now, last week.  But there's a few entries this week that we're talking
about.  There's the news item that we're talking about; we have the release
candidate, which is now actually released; and then, Gustavo also has a couple
PRs around this.  I don't remember how deep we got, Murch, last week, but there
was a notice on the bitcoincore.org blog talking about the legacy wallet
migration feature in 30.0 and 30.1 having a series of conditions that could
result in wallet data being deleted, not just the wallet being migrated, but
potentially other wallets having that data deleted as well, which if you don't
have backups could result in a loss of funds.  So, I believe that we outlined
the conditions for that particular bug last week.  But as Gustavo gets to in the
notable code segment, there's actually other conditions that are less likely to
happen in natural use, but could also result in wallet data being deleted.
Murch, do you want to talk a little bit more about that?

**Mark Erhardt**: Yeah, last week we mentioned it a little later in the show, so
I wanted to bring it up in the beginning in case people only catch the start of
our recording.  The bug occurs when you migrate a legacy wallet to a descriptor
wallet with the migration tool, and the legacy wallet is fairly old that is
unnamed.  So, we've been requiring that wallets get a name for over five years,
I think, or around five years.  And if you have an unnamed wallet, and then you
migrate it with 30.0 or 30.1, and the migration fails for any reason, the most
likely reason being your node was pruned, you import the wallet and it's not
caught up but you try to migrate it, then it would remove the migration folder
that is being created and unfortunately for the unnamed wallet, that would be
the wallet's directory because it's directly in the main wallet's directory.
So, if you had other wallets in that directory or in subdirectories, all of
those would get removed, including the old wallet.

This has been communicated pretty broadly on social media, on the Bitcoin Core
site.  We've put it out last week already, but I just want to mention it again
in case someone missed it.  Please do not try to migrate your wallet with 30.0
or 30.1.  30.2 came out on Saturday, right?  Yeah, three days ago, and this
fixes the issue.  If you're using the wallet for anything else except for
migrating a legacy wallet that is unnamed, it's safe, there's no issue that we
know of.  Now, while this bug was being fixed, a few other issues were
discovered.  I believe that the same issue could be triggered with the
createfromdump command in the wallet tool.  The wallet tool is a tool that is
shipped with the Bitcoin Core binary, but it's a power user tool.  I think most
people probably don't even know it exists.  If you had specific names in the
createfromdump and then the createfromdump failed, it would do the same thing.

This affects other versions too.  So, well, if you are creating new wallets
before you send money into them, please create backups.  I think that's
generally the status or modus operandi that people use already, but yeah, that's
all I know right now.  It's been fixed in the 30 branch through the 30.2
release.  The fix for the wallet tool has also been backported to 29, or I think
it's being backported to 29 and 28.  Those are not released yet.

**Mike Schmidt**: And Gustavo, you covered the two PRs that address each of the
respective bugs that Murch mentioned in the Notable code segment.  That's
Bitcoin Core #34156 and Bitcoin Core #34215, the first one for the migration and
the second one for the createfromdump.  Maybe we can reiterate that later in the
show, but we'll get to that.  And then obviously, I mentioned the RC for 30.2,
which Murch mentioned has, since authoring and publishing of this written
newsletter, been officially released.

**Mark Erhardt**: Yeah, I think talking about backups, I hope when you have a
legacy wallet that's at least five years old, you have at least one backup
somewhere.  Otherwise, I'm a little scared for you.  Yeah, and then, of course,
if you create a new wallet and it's in the directory, please also create a
backup before starting to use it, because I think that's just generally a good
approach.

**Mike Schmidt**: René Pickhardt, would you like to introduce yourself for the
audience?

**René Pickhardt**: Yeah, thanks first of all for making the time and including
the topic.  I'm René Pickhardt, Lightning Developer and Researcher with
OpenSats, and I have been working quite some time on routing payments in
Lightning.  And then I transferred a little bit more to liquidity management and
trying to see where should we open channels, how often should we open channels,
and how should we manage liquidity in general.  And from this, this blog article
emerged as part of a bigger research work, the Mathematical Theory of Payment
Channel Networks.

_Using Ark as a channel factory_

**Mike Schmidt**: And for those curious, you can go to Optech's podcast listing
page and just search René, and you'll see that he's been on quite a few before
talking about related topics that sort of get referenced, I think, in this
Delving write-up.  But your item was titled, "Using Ark as a channel factory".
René, you posted to Delving Bitcoin a post titled, "Ark as a Channel Factory:
Compressed Liquidity Management for Improved Payment Feasibility".  And I'd like
you to take this any direction you want, but there was one quote in there that I
wanted to maybe put upfront for listeners, and then you can sort of elaborate on
the different pieces, Ark, channel factories, Lightning liquidity, and some of
the constraints there.  But the quote is, "This post challenges the emerging
narrative that Ark should primarily serve as a last-mile payment system
interconnected via Lightning channels.  Instead, it argues that Ark might be
better understood as an infrastructure for Lightning, specifically as a channel
factory enabling efficient reconfiguration of liquidity".  All right, I'll let
you elaborate on that and maybe walk listeners through your thought process
here.

**René Pickhardt**: No, Mike, I have to say that's one of the reasons why I love
reading your newsletter because you're on point of spotting the sentence that is
the narrative of an article.

**Mike Schmidt**: Perfect.

**René Pickhardt**: No, it wasn't discussed before and it's honestly one of the
sentences in this article that is to my heart and that is important for me.  So,
in order to go in there, we have to go a few steps back in order to understand
where I'm coming from.  The problem on the LN is that sometimes payments don't
work as you want them.  You want to pay somebody, let's say a million sats, and
you just don't find a route.  And this can happen because liquidity is just not
available, and the math shows it happens actually quite often.  So, the only way
to resolve a payment that is not feasible is by reassigning liquidity on the LN
via an onchain transaction.  And the problem is, if your rate of infeasible
payments is too high, then with seven transactions per second that the base
layer supports, it's still too many operations where you need to reassign
liquidity, and that is a problem.  So, Lightning for payments has a certain
barrier of throughput that it can reach for mathematical reasons.  And people
have realized these problems with Lightning and they have been frustrated.

Then I think at that time Burak was trying to create a new Lightning wallet and
then he proposed Ark.  And he was very aggressive with his parameters and
everything.  I remember that every five seconds, he wanted to run one of these
Ark rounds so that payments are like real time, and so on.  And I looked at this
already two years ago and I was like, "Hey, you can use this for reassigning
channels.  Like could these vTXOs (virtual UTXOs) in Ark actually be owned not
by one person, but by two persons, so they become a funding transaction of a
payment channel?  And then, you can basically operate on this payment channel,
and when you need to reassign liquidity, you just do it in an Ark round.  So,
what this means is you can reassign a lot of channels in one single onchain
transaction, because it's just a new Ark tree that you're creating.  And I think
this is a really neat idea because Ark as a payment system has its own problems.
The vTXO has an expiry time and when you claim your vTXO early, then the ASP
(Ark Service Provider) still needs to provide the liquidity until the expiry.

So, when you have a really high payment volume, then Ark is going to be very
capital-inefficient for the ASP, which is bad.  Whereas Lightning channels, you
don't change the topology that frequently, like you might have to change it more
frequently in the whole system than onchain Bitcoin.  But for single channels,
it's not so often.  Also, there are nowadays some solutions in Ark where you do
payments that are somewhat trust-based, depending on the model of the vTXO, in
order to get real-time payments.  But those can be double-spent and these yield
custodial issues and regulatory issues and questions.  And for a long time, I
had conversations with people and saying, "Hey, you can look at this as
infrastructure for Lightning, you can use this for reassigning liquidity".  And
yeah, I guess at some point in time, I had the discussion with people too often
that I said, "Well, I'll now make the write-up for Delving", because then I
share it just with everyone and everybody is on the same page.

**Mike Schmidt**: Can you contrast what the companies working on Ark and how
they're portraying what you can do with Ark with what you're proposing, because
I do hear them say things like, "This is not a competitor to Lightning, this
augments Lightning, you can use Lightning within Ark"; are they saying the same
thing, or is it slightly different from what you're thinking with this as a
channel factory?

**René Pickhardt**: Well, I cannot speak specifically for all the companies,
because there are various developers, and everybody says it a little bit
differently.  But what I hear, and I mean this is the thing about this narrative
sentence that I put into the article, is they basically say, look, let's take an
LSP (Lightning Service Provider) like ACINQ, for example.  They run one of the
biggest Lightning nodes, they have a lot of users on their Phoenix wallet, and I
believe it's no secret that it's an issue for them that if a user requests a
channel, they provide some bitcoin on the channel, and then the user may
disappear, the bitcoin is allocated to the channel.  While technically it
belongs to ACINQ, they made an onchain transaction to fund the channel, they
need another onchain transaction potentially even to force close the liquidity,
and all the liquidity is actually not used.  I mean, it's in the channel but
nothing's being routed, no payments take place, because a lot of users are just
trying out once or twice, right?  You always have these long tail distributions.

So, what Ark is saying is like, "Hey, why don't you onboard your users like this
last mile kind of thing, and make payments there and connect your node via the
LN to other Ark wallets, so to speak, or other services.  So, use Lightning as a
settlement layer and routing layer between all those Arks, but the Arks
themselves are for end users because they can manage capital more efficiently".
And I mean, that is true.  However, there are severe problems on the LN that I
described in my research, where I say, "Well, we need multiparty channels
eventually anyway in order to get a better feasibility rating for payments, we
could use Ark for them.  And instead of using Ark directly for payments, where
it's not actually even that good because it has this problem with payment
volume, well, maybe we want to think about it differently".  And I was recently
on a panel with Erik De Smedt from Second, and he actually even wore a t-shirt
where it said, "Channel factory".  So, the Second team, at least publicly,
states that they are convinced of this idea that Ark can work as a channel
factory.

So, I'm not saying we should directly always only go down the way that I
proposed, right?  I mean, the other use case may very well be there.  I'm just
saying, hey, there's another use case, and it's currently somewhat being
overlooked, and we shouldn't ignore it because it's very powerful.

**Mike Schmidt**: Yes, it's not either or; both could be done using the same
protocol.  Yeah, it makes a lot of sense.  Can you touch on, I know you've done
a lot of research around this, but maybe there's something interesting to talk
about with regards to, there's the topology of the LN right now, and then
there's rebalancing liquidity within that existing topology, as well as then
also changing the topology.  Does what you're proposing with channel factories
and Ark allow for both of those, so rebalancing within the existing topology as
well as making a infeasible payment feasible by adding or changing the topology?

**René Pickhardt**: Yeah, so we really have to be clear with the terms that
we're using here.  When we have a payment that is infeasible, there's no
rebalancing that we can do within the LN to make that payment feasible.  That's
just mathematically impossible.  Because what happens is you can check within
the topology which wealth distribution is possible and making a payment is a
change in wealth distribution.  So, what this means is you start with the
current situation of wealth in the LN, you want to make a payment, but if the
new wealth distribution in this topology is just not possible, there's nothing
you can do by slinging around offchain balances.  What you can do is you can
give somebody money to make a payment to you so they empty their channel, you
have the liquidity on your side and now you can make the payment, right?  But
you had an onchain transaction there, right?  These are the swapping services
around Loop or some other swapping services.  Or you can directly open a channel
with somebody who you want to pay or with some service provider that you know
has liquidity to your destination, right?

But all of these things always require an onchain transaction.  So, the
rebalancing itself, that only helps you to make the feasible payments faster to
find.  And this works independent of Ark or independent of my idea, but it
doesn't help you to make payments feasible.  And the problem is those payments
that are infeasible to make them feasible, you cannot do it as often as you
potentially need to if the LN were to scale to like a billion users.  And then,
you need an idea like mine, or you use L2 channels or use some other form of
multiparty channels.  That is the idea.

**Mike Schmidt**: That makes a lot of sense.  One thing that I put in my notes
here that I thought would be interesting to talk about is gossip.  How would
gossip work or not work or need to work in order to support something like this?

**René Pickhardt**: That's the open question.  Currently, the gossip protocol
has this thing that, I mean, when we create a channel, we have two options.  We
can decide not to announce it, which happens for a lot of the end users in, for
example, the Phoenix ACINQ case, or we decide to announce it and then we need
gossip to announce the channel.  But the current gossip protocol demands that we
point to an onchain transaction and say, "Look, this is the short channel ID and
this is the funding transaction".  We need to actually sign from that key the
gossip message.  Well, if you use the vTXOs, then we don't have an onchain UTXO,
which is the funding transaction, but we just have this virtual transaction,
which according to Ark, we hopefully never see onchain, because we don't want
the unilateral exit, we don't want to unroll the entire tree.  So, what this
means is we would need to upgrade the gossip protocol.

This is one of the reasons why I posted this, so to speak, proposal or maybe
rough idea to the mailing list to see, is there demand, are people willing to do
this, because we then have to work out the technical details and to define how
the protocol can actually be extended so that it supports the announcement of a
channel that is based on a vTXO.  I think this is one of the reasons why
companies currently go in the other direction and say, "Hey, you can use it for
last mile because there, you don't have announcements of channels anyway",
because it's just already compatible with Lightning, whereas mine would need
changes to the Lightning protocol.

**Mike Schmidt**: That makes sense.  What's the feedback been on either that
angle or any of your posts so far?

**René Pickhardt**: I mean, I have a lot of discussions not only with the post,
but before, and I think people generally are open to the idea of looking into
how we can extend this, because I think some people understand that two-party
channel Lightning is not scaling infinitely.  I mean, it's a huge improvement
for Bitcoin already, but it has its limitations.  But then, of course, a lot of
people are working on concrete products that have concrete problems right now
that seem in the moment more pressing.  So, yeah, there was nobody jumping off,
"Hey, let's directly go to change gossip".  But I think that's also reasonable
because we would have to work out the details of how we really want to inject
these technologies, and I just started the discussion here.  So, that is
actually one of the things that is on my map for 2026, to see how could these
two integrate to make concrete proposals how to extend gossip and to talk with
people.  So, we're just not there yet.

**Mike Schmidt**: I think when a lot of listeners might hear about this idea and
the problems that it's trying to address, they might think, "Well, hey, there's
been all this work on splicing.  Doesn't splicing do a lot of this?"  Or maybe
comment on splicing in the context of this, because there's been a lot of work
around that and we're finally getting there and celebrating that we're getting
there, and now it's sort of like, "Well, maybe there's this better way to do it
in the future".

**René Pickhardt**: No, again, that's not a competitor at this point.  Quite the
opposite, I would say.  So, big shout out to Dusty, who I think did an amazing
work with splicing and went far beyond of what would be necessary, because he
also thought about the problem of, "Hey, when I do one splice, what happens with
the next splice and the next splice?"  And he invented this entire splicing
scripting language, which I think is a really neat language and can be extended
upon.  The problem with splicing, however, is that currently splicing is one of
these onchain transactions that I was talking about.

So, what are your onchain transactions?  You can open a channel, you can close a
channel, you can make an atomic swap, which means pay somebody and get refunded
in Lightning, or you can splice the channel.  But all of these are onchain
transactions and we only have a limited number of onchain transactions available
for very good reasons.  I mean, we fought very hard to keep it this way.  So,
when you do Lightning over Ark, how I like to call it, because Ark is the
infrastructure for Lightning, well, then you can either spend the vTXO and
create a new UTXO, which would mean close the channel and open a new channel.
But of course, you could use Dusty's splicing language and make the splice on
this Ark channel.  Well, the splice now doesn't hit onchain because it's in this
Ark pool, right?  So, in my mind, there is this reality or this vision where, of
course, all of this could happen in a splicing world with all the technologies
that have already been built, but just within the Ark instead of anchoring every
single transaction to the blockchain.

So, that's why also the title it's 'compressed' liquidity management because you
compress a lot of these onchain transactions into a single Ark round or Ark beat
transaction, how I like to call them.

**Mike Schmidt**: We touched on the gossip consideration and needing to think
about that and that being an open question.  What other areas for research, or
more open questions are there that you think are notable for listeners?

**René Pickhardt**: Yeah, so I think one of the questions still is, I mean,
maybe there are situations where Ark still works very well for payments, because
you really have only one or two payments with a user and you don't really want
to create a Lightning channel, even with an Ark, and allocate the liquidity.
How much liquidity do you have to over-provide?  What are the time-outs?  When
to use what?  Can you actually really do routing over multiparty channels.  So,
I mean one thing is to have this one Ark of end users where you can just change
the size of channels and the liquidity within the channels.  But the other
thing, of course, that multiparty channel systems allow is that you can route
directly from one multiparty channel to another one.  Currently, these Arks are
connected by two-party channels and as pointed out, two-party channels have a
limited ability to scale.  So, of course, you can think about ways of how to
extend the routing protocol.  Again, another severe change to the Lightning
protocol, where people can, of course, say, "Hey, René, this is premature
optimization".  But that is one thing to consider, and where the trade-offs are.

I think for now, these trade-offs are really not clear.  I mean, I hear from
people working in Ark implementations that they do think about the costs that
they have with their Ark transactions and with vTXO management and with
recollecting them.  So, I think there's a lot of optimization problems that need
to be solved in this area and to decide where is the sweet spot of how much
Lightning do you want or how much Ark do you want, if you combine the two.

**Mike Schmidt**: What parting words would you leave listeners with?  I mean,
maybe I'll just inject my own opinion.  I am not deep in Ark nor Lightning, but
it seems like we've talked about these kind of ideas, versions of this in terms
of channel factories, and it seems like what you're proposing here has a lot of
merit and I'm excited about it.  It seems like there is a there there.  What do
we need?  What do you want listeners to do or be aware of, as we wrap up the
chat?

**René Pickhardt**: So, I think what makes sense is to really understand that
these technologies have a huge potential to go hand in hand.  I often see people
of like, "Hey, this is my shiny idea and my baby and I want to use it in this
way", and I mean, it makes sense.  As Lightning developers, we spend really a
lot of time to make this technology work.  And I think for them, it may be hard
to look at Ark and see its potentials, whereas for Ark developers, it's like,
"Hey, this is the new thing and we kind of do everything".  And then, I think
both sides should go to each other and really learn from each other how they can
go together, because the Lightning community has a lot of experience in robust
protocol development.  The Lightning protocol is like really, I would say,
beautiful technology and we shouldn't throw it away just because there's
something new and shiny out there that five years later, another person comes
around and writes down an entire math theory and explains why it has a flaw in
one particular thing, right?  So, I think we should really talk with each other
and see how we can make these technologies to the best interact with each other.

**Mike Schmidt**: We had Murch join us here.  Hey, Murch.

**Mark Erhardt**: Howdy!

**Mike Schmidt**: We had a natural wrap-up, but perhaps you have something that
you'd like to ask René, and maybe we covered it, maybe we didn't?

**Mark Erhardt**: Aren't Ark and Lightning the rare complementary?  So, I just
heard you sort of allude to the worry that Ark sort of replaces Lightning, but
it seems to me that they are good at different things.

**René Pickhardt**: No, I agree.  That's, as we discussed, part of my argument,
that I think Ark is a beautiful infrastructure for Lightning.  The question is
about where are they really complementary.  And I think the current main
narrative of where they are complementary can be improved upon, and this is what
we discussed already, yeah.

**Mark Erhardt**: All right.  Well, sorry, I saw the message a little late that
you were recording.  I was already in transit.

**Mike Schmidt**: Yeah, no problem.  Well, René, thanks for joining us.  I think
the call to action is for people to check out your previous research, but also
check out this Delving post and really give some thought into this,
particularly, I guess, you're encouraging the further collaboration between the
Lightning ecosystem and Lightning devs and protocol work with the burgeoning Ark
ecosystem as more collaborative, as opposed to maybe developing different
payment systems, while also still noting that Ark is also its own payment system
as well.

**René Pickhardt**: Yes, and maybe to emphasize on the point, I don't disagree
with the current narrative.  I'm just saying there may be other potentials that
we haven't explored yet.  That's, I think, it's important to note.

**Mike Schmidt**: All right.  Thanks for your time, René.  Thanks for carving
out your schedule to chat with us.  Cheers.

**René Pickhardt**: Thanks for your work.  Bye-bye.

_Draft BIP for silent payment descriptors_

**Mike Schmidt**: "Draft BIP for silent payment descriptors".  Craig is on to
help us walk us through this.  Craig, you posted to the Bitcoin-Dev mailing list
a draft BIP for defining a new top-level script expression sp() for silent
payments.  I pull out a quote that I saw in your post, "There is a practical
need for a silent payments output descriptor format in order to enable wallet
interoperability and backup/recovery".  You mentioned, Craig, a practical need,
and perhaps we can use your work on Sparrow as an example.  Sparrow supports
descriptor wallets and sending to silent payment addresses.  So, why do you need
a silent payment descriptor?

**Craig Raw**: Great question.  So, Sparrow does not actually support descriptor
wallets, sorry, silent payment descriptor wallets, I should say yet, because I
need the silent payment descriptors first.  But it does in general support the
other already defined descriptor wallets.  So, why would we need this thing
called an output descriptor?  I think it's good to always zoom out first and we
can kind of come back in.  What we have with the wallet is a variety of metadata
which helps us define what the wallet is.  And if we can define that metadata in
a standards-compliant way, we can use that to transfer that metadata around
between one piece of wallet software and another.  And that allows us to, for
example, take a Sparrow wallet and put it into Bitcoin Core and vice versa.  And
that's quite a useful thing to be able to do, because it means that we're not
locked into any kind of walled garden.  You can even do that, for example, with
the Bitkey, which is otherwise quite a walled garden, but you can actually get
the descriptor out and you can put it into Sparrow.  And you can actually see,
as a watch-only wallet, your Bitkey wallet.  So, there's a variety of different
pieces of software out there which allow you to move your descriptor around.

Now, previous to this, we had something called an xpub, which probably most
people are familiar with, and that was typically the way that we did it, but
that proved to have a lot of limitations.  And people started to create other
things called ypubs and zpubs, but it just wasn't really a road that was going
anywhere.  So, the descriptor is the modern way to do it.  And what we have with
BIP32 HD wallets is a variety of different BIPs, BIP380 and 381 all the way up
to 387, which give us a variety of different ways to define an HD wallet.  Now,
when it comes to silent payments, we have an entirely new kind of wallet, we
have a wallet, which is not defined by iterating an index.  So, typically, with
an HD wallet, you start off with index zero, and you create your first address,
and then you go to index one, you create your next address, and so forth.
Silent payments, the addresses are actually defined by some metadata as before,
but then by the inputs of every transaction that actually spend to that silent
payments output.  And that is a very different style.  So, we're not
incrementing an index anymore.  And as a result, we need to have a completely
different way of defining what is this wallet.

So, what we need to do here is create a new silent payments output descriptor,
which contains the metadata data that it requires, that kind of base metadata,
but also gives a hint to the wallet to say, "How do I treat this metadata in
order to recover or to scan for the outputs that I want to create?"  So, that's
kind of the overall need, is to be able to define these wallets in a way which
is standards- compliant.

**Mark Erhardt**: Right.  So, basically for regular wallets, you get a sequence
of addresses that is defined by a main secret and then a derivation path.  And
usually, the last step of the derivation is an index that gets incremented to
generate all the addresses.  In silent payments, as you said, there is no
incrementation because it's always the same keys combined or tweaked with the
keys of the inputs of a transaction that pays to the output.  So, basically the
main secret here is just the two keys of the recipient, and then all the other
meta information derives from the transactions, which is the very cool thing
about silent payments, that allows you to reuse your payment instructions
without actually reusing output scripts on the chain.

You described basically a few more things that should be in the output script
descriptor for silent payments.  I believe there was a birthday in there, and
there was a discussion ongoing about whether or not labels should be in there.
Could you go a little bit into the details of what additional information you
think should be in these descriptors?

**Craig Raw**: Sure.  So, I think you mentioned that there'd be these two keys,
and I think it's a good place to start.  So, the metadata that I've been
referring to basically comes down to keypairs.  So, we have two of these public
private keypairs.  And when we talk about a silent payments address, we are
actually just talking about concatenating the two public keys of these keypairs
together.  And that actually makes the silent payments address, which is the
static address that you can send to over and over again without having address
reuse.  So, taking these two keypairs, and then saying, "Well, how else can we
use them in a way that's kind of easy to understand and easy to work with?"  If
we want to have a watch-only wallet, basically we want to scan for all of the
outputs that have been sent to the silent payments address, what we do is we
take the two keys, I should say.  One is called the scan key, and the other one
is called the spend key, which kind of reflects very much their nature.  So, if
we take the private key of the scan key and the public key of the spend key, we
are then able to take that metadata and construct what the journey was.  In
other words, find all of the outputs, but not be able to spend them.  If we then
take the private key of the scan key and the private key of the spend key, we
are able to create a wallet which is able to spend those outputs, not only find
them, but spend them as well.

So, what I've done in the descriptor is take those keys and define them as
terms.  So, when we have a silent payments address, we take the two public keys,
we put an sp() on the front and we've got this thing which looks like sp1q and a
whole lot of characters that follow.  That's your silent payment address.  What
we then do to create a watch-only wallet is we put spscan on the front, we have
the scan private key, the spend put public key, as I said, and we then have that
as a unit which allows us to then find all of the outputs.  And finally, the
spending wallet, we put spspend on the front, we put the two private keys of
those keypairs together, and then we have a unit which allows us to create a
spending wallet.  So, it all kind of follows through.  We've got three different
ways to be able to combine the keys of these two keypairs.

So, I think that that's an important concept and because it's very similar in
many ways to the spscan, it's very much like an xpub, and the spspend is very
much like an xpriv.  And you can think about it in those ways as you map your
understanding from an HD wallet onto a silent payments wallet.  So, we put that
into an sp(), which says we're looking at a silent payments wallet.  And then,
as you mentioned, we then have two optional additional arguments.  So, again, we
have this sp( then either the spscan or the spspend, depending on what we're
trying to define, what kind of wallets, whether it's a watch-only or spending
metadata that we're trying to send around; and then we have the BIRTHDAY.

Now, usually descriptors don't include a birthday.  So, this is definitely a
proposal which takes us in a different direction than one we've been in before,
and the question is obviously, "Why?"  Now, the reason is that with silent
payments, we have to scan for outputs, and scanning for outputs is a
computationally difficult thing to do.  What we have to do is actually look at
every single taproot output on the chain and determine if it's an output sent to
us.  And the way that we do that is we have to perform many other things, but
the most expensive thing is we have to perform this EC point multiplication,
which is a heavyweight cryptographic operation.  And we have to do that for
every single output on the chain in order to be able to determine whether it's
an output sent to us.  So, for the first time ever, we have this kind of quite
onerous method of being able to find our funds.  And for that reason, primarily,
we've included a birthday in this output descriptor, because otherwise, you will
have to scan from wherever the beginning is, whatever that block height.  Murch?

**Mark Erhardt**: Yeah, I just wanted to double-down a little bit on the
birthday thing, or not double-down, double-click.  Birthdays of wallets make
sense also in the context of other wallets, because of course you cannot have
been paid to a wallet before you created it.  So, I think other wallet backup
formats had already used the same concept in order to make it cheaper for light
wallets to find all their wallet history.  Just remembering at what block height
a wallet was created would enable the light wallet to only scan blocks from that
height on, whether that is using client-side block filtering, or asking the full
node or the server to tell you about it, or whether it's scanning the outputs,
the P2TR outputs, for silent payments to yourself.  Scanning less because you
know it cannot be before a certain block height seems like a reasonable
optimization.  So, in that sense, I think it's not that different, except that
the cost might be more due to having to scan every single P2TR output.

So, previously, the output script descriptor format did not include a birthday
and you're proposing to include it here for the silent payment.  I saw that
there might have been a little pushback on that.

**Craig Raw**: Yeah, I think mainly, as I said, because it hasn't been done
before.  And look, I mean this is still a proposal and we still have to decide
whether it is the right way to go.  What I think we need to hear is from the
various developers who are building silent payment wallets.  I am reasonably
certain that they're all going to be strongly in favor of having a birthday,
because the reality is that if you are a light client and you have to try and
scan all of these outputs, you can imagine how onerous it is.  Just try and
imagine a phone trying to download all of the information, first of all, that it
requires, and there's a number of different ways to do that; but then, to
actually perform all of this computation.  And you soon start to realize that if
you have to go all the way back to say where taproot activated, you're going to
have to do a lot more work than if somebody created a wallet a month ago.  So,
that's, I think, where we're going.

**Mark Erhardt**: Yes, definitely.  Yeah, I think you could probably limit
silent payment payments to the introduction of silent payments as a concept, so
not all the way back to P2TR activating.  But still, yes, scanning multiple
years' worth of data is a lot more work than a month or so.  And then, there's
also, I just want to mention it, it's somewhat unrelated, but there's two ways
how to recover your wallet state.  One is to just look for unspent UTXOs that
are yours, if you're just interested in knowing your balance.  And then, if you
want the full history, you do have to scan all P2TR outputs since the creation
of your wallet.  All right.  So, yeah, sorry, the question is, do you have to
scan multiple years or just the last month, or whenever your wallet was created?
And you think that this might be attractive to many people, especially light
client developers that have been working on silent payments.  I think, yeah, it
hadn't been done before, and I think if I understood correctly, one of the
pushbacks is that the output script descriptor format is only for describing the
output scripts, and where it started is according to the person that specified
the output script descriptors.

But the information when a wallet was born is not necessarily a description of
the scripts.  I think it makes sense, though, if we think of output script
descriptors as a way of describing the whole body of relevant addresses and
wallet context to have a starting point.  And if it's your backup, obviously you
can trust that meta information because you stored it yourself.

**Craig Raw**: Yeah, I think so.  And I think what we need to do as a developer
community is agree on what we want.  It is currently an optional addition, you
don't have to have it.  So, if you really don't like it, you don't have to put
it in.  But as I say, I think the reality of not having it in could make it, on
many different platforms, depending on your approach, depending on the resources
that that particular piece of software has available to it, I think without it,
you could make it practically impossible to ever recover the wallet.  So, you
could argue for the purity of not having a wallet birthday, or you could argue
for the practicality of, "Can the user recover their funds?"  And I'm certainly
in the latter camp.  I kind of always want to be on the user's side when it
comes to this kind of thing.  Well, that's the way that I will lean anyway.  But
again, we must decide as a developer community what we want.

**Mark Erhardt**: Right.  Could we briefly talk about whether or not labels
should also be stored in that descriptor, and maybe what labels are?

**Craig Raw**: Sure.  So, labels are a way of being able to tweak the spend key,
so that you can basically have a variety of different silent payment addresses.
Now remember, the silent payment address is sp() plus the scan public key plus
the spend key.  So, by tweaking that spend key, you can get to a point where you
can have different silent payment addresses.  And it turns out to be relatively
efficient to scan for them in this way.  Now, the big downside to using labels
is that it is trivial to see that all of these addresses are actually linked to
each other.  So, don't think of it as a way of creating different nyms that you
can use online, because immediately you can tell that they're all the same
person.  So, actually, practically there's not a lot of use cases for it in my
personal view.  I'm not saying that they aren't any use cases, and I think one
particularly compelling use case is for an exchange to use it.

So, if you think about when I deposit to an exchange, I only want to have one
verified address.  We know how exchanges like to verify things.  And they can
have a variety of these different addresses, they can scan for them efficiently,
and they don't care that everyone knows it's the same entity.  So, that's, I
think, one area where labels do actually make sense.  Go ahead, Murch.

**Mark Erhardt**: I just wanted to expound on that in the sense that even if the
exchange gives out all of these silent payment addresses that are just differing
on the labels, so the scan key is the same, the private key looks different, so
anyone comparing these sees that they belong to the same owner because the scan
keys are the same, the addresses that are being created are unlinked, because
they are tweaked with the input data and it is an irreversible process.  So, you
cannot see what silent payment address got paid when these outputs are being
created with the inputs.  So, the privacy loss here would be on multiple people
looking at the address that is provided to the users to deposit and people
easily being able to recognize that they all belong to one entity, but not on
the outputs that are being created, which look indistinguishable from any other
type of outputs.

**Craig Raw**: Yes, that is 100% correct.  So, typically, if you wanted to have
a personal address and a business address, this is not an approach you would
necessarily want to use, because anyone could see that it's the same thing, and
that wouldn't ideally be probably something that you would want to do.  So, as I
say, I think there are limited use cases.  Now, if you wanted to use the same
seed and create completely separate silent payment addresses, you could actually
just use a different derivation path to create that keypair, right?  So, you
have the idea of a BIP32 account in order to create the different keypairs.  So,
you could have an account 0, an account 1, and so forth.  And that's a different
approach which would allow you to create silent payment addresses that were
completely separate from each other.

**Mark Erhardt**: Just asking back, would that have any efficiency in scanning
versus just having completely separate silent payment address keypairs?

**Craig Raw**: No, it would not.  There's absolutely no benefit.  The only
benefit is that you can reuse the same seed.  That's the only benefit there.

**Mark Erhardt**: Right.  So, the backup of the main secret might be known, but
you'd probably want to remember which ones you derived.  Maybe you'd use an
index, or something, to easily scan for them, but the cost would then double or,
well, increase linearly with the number of silent payment addresses that you're
watching.

**Craig Raw**: That is correct, yeah.  That's one of the reasons that we need to
make silent payment address scanning as efficient as we can, because the reality
is lots of people are not only going to want different accounts, but just simply
have different seeds as well.  So, I think we're in a world where we cannot rely
on clever tricks to bring scanning costs down.  I think we're going to have to
try and make the scanning cost low in and of itself, otherwise silent payments
as a payments network, if you can think of it that way, will never really become
a mainstream thing.

So, labels are in the silent payments output descriptor at this time, because
you can obviously define them.  And the way that labels works is actually an
integer index and it starts off at 0, but 0 is defined for change.  So,
typically, we think it's changed as a different chain in an HD wallet.  Here, it
is just a different label.  So, we just use a different label, we send to that
label, and we know that that is internal to the wallet, no one is going to
publish that address.  Then, we can start from 1 for the externally-published
silent payment addresses, and we can go as high as we want.  We can just keep
putting that number up.  So, the reason that we had defined it in the silent
payments output descriptor is so we know how far to go and which numbers to look
at.  Otherwise, we just have to -- well, there is no defined method at this
time.  We don't actually know which method to use.

**Mark Erhardt**: Then, I guess this begs a question for me which is, do we want
a birthday per descriptor or a birthday per label?  Because it sounds like if
you increase the label count and add another label, you'd only want to scan --
oh, never mind, we can scan efficiently for labels.  I retract my question.

**Craig Raw**: Sure, that's correct.  Yes, we can scan relatively efficiently
for labels, so it's not too serious there.  Yeah, look, again, I wouldn't say
that personally labels are my favorite thing.  I think it's possible to lose
yourself in a lot of label-related detail.  Again, I think it's up to the
developer community to state whether they want labels in there currently.
They're optional, so you don't have to put them in if you don't want to.  There
has been some pushback to say every additional label that you add, thinking of
it kind of like an HD wallet, that you're going to be issuing a lot of different
silent payment addresses and incrementing this index like you would an HD
wallet.  I don't like that manner of thinking too much.  I think that we should
be getting away from that.  I definitely don't think we should be trying to
introduce a gap limit, and bringing all of the problems of the gap limit into
the silent payments world.  I think we need to make a determined stand to avoid
that.  That would really, for me, be quite a big loss if we did.  So, that's
kind of my thinking broadly on labels.

**Mark Erhardt**: Yeah, increasing the labels like that doesn't make any sense
to me at all.  I think maybe you would want to use labels, as you said, in the
context of a business receiving payments that need to be assigned to different
accounts.  Or if, for example, you're using a silent payment address as a
donation address and you want to know what people are donating for.  So, you
might have different ones, one for your blog, one for your question-and-answer
platform website, one for your GitHub account.  Or if you're really going
overboard, maybe one per blogpost that you write so you know which one got paid.
But certainly not for every single instance where you get paid, because the
whole point of silent payments is that the address is reusable and will not ever
generate the same output scripts again.  So, you do not actually have the
problems that you have with legacy or existing wallet systems, where the address
reuse directly links the funds together across different transactions and
reveals that the same entity was involved in multiple transactions.  That
problem does not exist in that form for silent payments.  That's the whole point
of silent payments.  So, creating new labels for every single payment use case
is totally misunderstanding the concept.

**Craig Raw**: I completely agree, Murch, no objection from me on that.

**Mike Schmidt**: Craig, you mentioned the developer community.  Part of this is
interop.  I know some wallets have already supported receiving to silent payment
addresses.  I think Cake Wallet, I think there's been some others.  What are
they doing now?  And maybe rolling into like, what's the community's feedback on
your proposed BIP?

**Craig Raw**: Right now, there are no silent payments output descriptors
defined in any wallet.  So, these wallets are just kind of showing it in an
interface.  I don't think they have any kind of, well, there's no
standards-compliant way of conveying that wallet metadata around apart from
sending around the seed, which of course we always have.  I think in terms of
the silent payments developer community, everyone's, I think, pretty fixed on
the idea of birthday.  And again, I would really want to emphasize that the
amount of computation required here is at least an order of magnitude more than
we've ever had before.  At least, it's probably more than that, it's a really
substantial amount, and I think it's the main reason we don't have silent
payments today.  I mean, if you think about what silent payments brings us, they
bring us a static payment code, we don't have to keep asking people for an
address over and over again; it effectively eliminates address reuse, which is
one of the major problems identified in the original white paper; and it
eliminates the gap limit.  And if we think about it right now, you can trivially
grief any BTCPay Server instance by just requesting an invoice over and over
again and not paying that invoice.

So, we've got three really major problems on Bitcoin layer 1, all of which are
addressed by a silent payments.  We have this huge downside in that we have this
massive computational burden, which is required by those receiving the funds.
If we can reduce that computational burden to an extent where it becomes
manageable by ideas like having a birthday, then we can maybe bring silent
payments to be a practical alternative to the current HD wallets we have today.
If we fail to do so, then silent payments will just always remain a nice
developer idea that never really became a practical payments network.  And
that's really what I think we need to decide on here.  For me, I think it's
worth breaking a little bit from the past, even if it horrifies some people,
because ultimately, we want this thing to work.  We are practical people, we are
not just here to conjure up ideas for our own benefit.  We want to create usable
products, and that's where I'm coming from, that's my position.  So, yeah, I
don't know if I answered the question there, actually.

**Mike Schmidt**: No, I think that's a good way to maybe wrap up.  It sounds
like how you ended there is also a good call to action for listeners, who may be
developers working on wallet services or products, to review the BIP, provide
feedback to the draft and yourself.  And I guess there's a lot of debate around
this birthday.  It sounds like hopefully you all can figure out a way to keep
that optimization in from a usability perspective for sure.  And yeah, Murch or
Craig, anything before we wrap up this item?

**Mark Erhardt**: Well, there was a big discussion going on the repository.  If
you're interested in weighing in on birthday, no birthday, please check out the
BIPs repository PR to chime in.  There's some details to read there.  I think
the mailing list was also -- I haven't looked actually, but yeah, you know where
to chime in, especially if you're working on a silent payments wallet.  And
other than that, I'm pretty excited people are working on silent payments
because I think it's awesome.

**Craig Raw**: Cool.  I don't really have anything to add other than to say,
please rather go to the PR.  The mailing list is, I think, now getting a bit out
of date, and I don't want to try and have a discussion in two different places
at once.  So, the PR is the right place to go.  And that's the most recent kind
of thoughts are posted there, I think.

**Mike Schmidt**: Excellent.  Craig, thank you for your time, and thanks for
your work on Sparrow.

**Craig Raw**: Excellent, guys.  Thanks for having me on and letting me blabber
on about silent payments.

**Mike Schmidt**: All right, cheers.

**Craig Raw**: Ciao.

_Bitcoin Core 30.2rc1_

**Mike Schmidt**: Moving to our Releases and release candidates segment, we have
Bitcoin Core 30.2rc1 that we've sort of touched on earlier in the News item.
Gustavo is going to get into a couple of the PRs that were in there.  As Murch
mentioned, this is officially released now.  You can go to bitcoincore.org, you
can see the Bitcoin Core 30.2 release.  You can also see the release notes as
well.  I think the big item is obviously the two that we mentioned around wallet
deletion, there's two PRs around that.  There's a few around tests, a few around
the build system.  But I think that those fixes are the most notable.

**Gustavo Flores Echaiz**: Yeah.  So, now just starting to get into the Notable
code and documentation changes section, if that's okay?  Yeah, perfect.

_Bitcoin Core #34156 and Bitcoin Core #34215_

Yes, so as much mentioned.  the first item in this list is Bitcoin Core #34156
and Bitcoin Core #34215.  They're both the fixes in this new release, so it's
important to not use Bitcoin Core 30 or 30.1 and skip directly to Bitcoin Core
30.2.  The first PR is about the fix.

**Mark Erhardt**: Sorry, let me jump in right there.  If you're migrating a
legacy wallet, please don't use 30 or 30.1.  For everything else, it's fine.
Just very specifically, if you're migrating a wallet, please don't go around
saying, "Don't use 30 and 30.1", because for most people it shouldn't be a
problem.  But yeah, people can upgrade if they want and should probably upgrade
when they're ready to do so.

**Gustavo Flores Echaiz**: Thank you, Murch.  Yeah, sorry, I forgot to mention
that.  But yeah, very important to mention that this is specifically about
migrating legacy wallets.  So, well, I'm not going to try to get into too many
details here because we already covered this at the beginning.  But maybe as a
refresher for someone that wasn't listening at the beginning, these two PRs fix
two bugs that are closely related, where when you're trying to migrate,
specifically on the first one, you're trying to migrate a legacy wallet and the
migration fails, if that specific file is unnamed, then the cleanup logic will
accidentally remove all the wallet's directory.  The reason why that happens is
because the cleanup logic wants to remove the newly created descriptor wallet
directory that was created during the migration, but because the migration
failed, it wants to clean up that.  But because that file comes from an unnamed
legacy wallet, it will not create its own subdirectory.  It will live in the
parent directory of wallets, and that directory will be deleted, deleting all
the wallet files.

In the second PR, this is something different.  It comes from the wallet tool,
createfromdump command, where if the wallet name is an empty string, then there
could be an issue where all the wallet's directory could be deleted as well.
So, both fixes ensure that only this issue won't happen.  So, even if the legacy
wallet is unnamed or it has an empty string, then only the newly created wallet
files are removed and not the parent wallet's directory.  Yes, Murch?

**Mark Erhardt**: Sorry, just because the details matter here a little bit.  The
wallet being unnamed is not sufficient for this to bug out and for wallets to be
deleted.  The issue happens when an unnamed wallet is migrated and the migration
fails.  So, there's other circumstances that need to happen in order for that
bug to be triggered.  And just to be clear, this may also affect other wallets,
because if other wallets live in the wallet's directory or in the wallet's
subdirectory, when the migration fails, it would delete for an unnamed wallet
the whole wallet's directory, including subdirectories.  So, the worst-case
scenario basically for me would be, if you just created a new wallet and hadn't
backed that one up yet, and then also migrated a legacy wallet whose migration
fails in that same directory, you might lose the newly created wallet rather
than the backed-up wallet.

So, anyway, don't migrate wallets with 30.0 or 30.1.  Please use 30.2 instead.
And yeah, so far we have no reports of anyone losing funds.  I hope that stays
the way.  That's why we're putting this out so often and in so much detail.
Please be safe.

_Bitcoin Core #34085_

**Gustavo Flores Echaiz**: Thank you, Murch, for that.  Let's move forward with
Bitcoin Core #34085.  So, here, this is a follow up to a PR we covered in the
last newsletter, where the algorithm used for cluster linearization as part of
the cluster mempool project, the algorithm was changed.  So, this comes as a
follow-up of that, where some functions such as FixLinearization() and
PostLinearize are either eliminated or the number of calls to that function are
reduced.  So, FixLinearization() would happen on the previous setup, when there
would be a topological error after running the previous algorithm.  And
FixLinearization() would make sure that the ancestor constraints would be
properly used.  So, however, this new function kind of does that more
effectively when doing the first linearization, which is why FixLinearization()
function as a separate function isn't that useful, and it's now integrated into
the general Linearize() function.

**Mark Erhardt**: So, maybe let's zoom out a little bit.  When you collect a
cluster, you can pick any single transaction in the cluster and then just follow
any child relationship and any parent relationship to find more unconfirmed
transactions.  And then, of those new transactions you find, you follow all the
child and parent relationships and find other unconfirmed transactions.  So, you
might be moving up and down in the graph sideways.  So, just after collecting
the cluster, you just have the list of transactions and they might not actually
be sorted in a topological order.  So, I hope you remember in blocks, when we
confirm transactions, parents have to appear before children.  Otherwise, the
UTXOs we're spending in a child don't exist yet.  So, just collecting everything
that is in the cluster would not necessarily be topologically correct.

Apparently there was a function previously called FixLinearization(), which then
would immediately at least make it topologically valid, even if it's not
optimized yet.  But really we only need the clusters to be linearized when we
interact with the cluster, when we want to know what goes in the next block or
what should be evicted, or is there a replacement happening in that cluster?
So, from my very cursory look into this PR, I understand that the linearization,
basically we do the work only when it is required.  We defer doing the work
upfront after importing or discovering the cluster, we only do it when we need a
linearized cluster and we need the order to be correct, then we run it.  And
that's why we have integrated the FixLinearization() call into Linearize()
directly, so it only happens when we need the linearized cluster.

**Gustavo Flores Echaiz**: That's exactly right.  Thank you, Murch, for that
extra context.  So, I just want to add that, as we mentioned in the last
episode, if you want to learn more about this new algorithm, the spanning-forest
linearization algorithm introduced for the cluster mempool project, you should
listen to the episode #385, which was the year-end episode, where Pieter Wuille,
sipa, was a guest in the episode that explained all the details related to these
changes.

_Bitcoin Core #34197_

We move forward with Bitcoin Core #34197.  So, here, a field that is part of the
response of the getpeerinfo RPC command, the starting height field is removed by
default from the response and becomes deprecated and is scheduled for removal in
v32 of Bitcoin Core.  You can always use a configuration option to retain the
field in the response if you wish to do so.  So, what is this field?  This field
represents what a peer will self-report as his chain tip height, and this comes
from a peer's version message.  However, this is self-reported and is considered
unreliable.  This field was previously useful, but was in the specific PR #20624
which was merged more than five years ago, its use was removed.  So, it's now
considered no longer used in Bitcoin Core's logic and is also not considered a
reliable source.  So, it was decided to be deprecated and removed from the
response.

_Bitcoin Core #33135_

**Mark Erhardt**: Bitcoin Core #33135 adds a warning when you import a
descriptor that has a timelock.

**Gustavo Flores Echaiz**: Basically, there's a warning that is added when you
call the command importdescriptors and you're using a miniscript descriptor that
contains a value that specifies a relative timelock that has no consensus
meaning either in BIP68 (relative timelocks) or BIP112 (OP_CSV,
CHECKSEQUENCEVERIFY).  So, basically, this is a warning that is added to let you
know that the value that you have inserted in this field might not be what you
think it is if it has no consensus meaning.  For example, one of these BIPs says
that only the first 16 bits that are inserted in this value are considered for
the relative timelock.  So, for example, if you enter a value that is higher
than that, such as 65,536, it will have no consensus meaning, so it would be
equal as 1.  It would have no effect, no meaning.  So, this warning just lets
you know that you might get a result that you weren't expecting, and this is
completely fine if you know what you're doing.  So, for example, the LN uses
this field and specifically intends to use non-consensus value to encode extra
data.  But if you were using it outside of those use cases, this warning helps
you know that you might get an unexpected result.  Any extra thoughts?  No?
Perfect.

_LDK #4213_

We move on with LDK #4213.  So, here, defaults are added when constructing
blinded paths.  So, there's two different contexts.  LDK could construct a
blinded path that is for an offers context.  The goal there is to minimize the
byte size because you want to be able to display this in a QR code or an easy
copy-and-pasteable data.  So, the logic there is, how can we reduce the byte
size?  And we do that by reducing the padding and building a compact blinded
path.  So, using the short channel ID to define the target.  However, this
reduces privacy and aims for byte size reduction.  However, if this is not for
an offers context, so there's no logic of displaying this on a QR code, then the
goal is to maximize the privacy and there a non-compact blinded path is used, so
just a regular channel ID, not a short one.  And it also adds an extra four
hops, including the recipients, so it's also harder to de-anonymize.

What would we mean by 'non-offers context'?  We specifically mean onion messages
related to the async payment protocol, or other non-offers onion message types.
So, if it doesn't mean that this is a BOLT11 or you might think that when saying
'non-offers'.  No, this just means other types of onion messages that are not
related to an offers context.  Yes, Murch.

**Mark Erhardt**: Let me try to illustrate this a little more.  Let's assume
that Mike is an LSP that is very well-known in the network and has hundreds of
Lightning channels, and therefore is a good point in the network to use as an
entry point to a blinded path.  Blinded paths are basically multiple hops that
are encoded already by the recipient that described the tail end of the
multi-hop payment, and they are provided by the recipient to the sender.  So,
when the sender crafts their multi-hop payment, usually the sender would know
all of the hops between themselves and the recipient, whereas the recipient only
learns about the most recent hop.  So, we have very good sender privacy by
default in the LN, but low privacy by the recipient.

Blinded paths allows the recipient to get some privacy by saying, "Hey, if you
find the path to Mike, the big LSP, then the rest of the hops are encoded here
already in the onion that I provide.  And from there, it'll find its way to me,
the recipient".  So, that's the idea of the blinded path.  So, for example, if I
had a channel directly with Mike, my blinded path would simply be, once it
reaches Mike, there's another one hop that goes to me.  And Mike, as the LSP,
gets this onion, sees the onion is pretty small, and can guess, "Oh, there's a
payment to Murch".  However, if you just make that onion a little bigger and
pretend that there's two or three more hops after Murch, from Mike to Murch,
then you are padding that blinded path to obfuscate that you're the final
recipient to the entry point of the blinded path.  And that's what we're talking
about here.

So, encoding that additional data with the onion hops in the blinded path takes
a lot of space.  And if you're presenting an offer on a QR code, that would make
it very nitty-gritty, a small detailed QR code that might not scan well.  So,
presumably, that's why the padding is only used when the data is transferred
digitally rather than presented as a QR code.

**Gustavo Flores Echaiz**: Thank you, Murch, for that extra explanation.  That
was very, very simple to understand.

_Eclair #3217_

So, we move forward with Eclair #3217.  So, this one is related to the next one,
LND #10367, but it's more complete.  So, basically what is done here is that
there was an update in the BOLTs proposal related to mitigating channel jamming
attacks.  So, what is a channel jamming attack?  It's a DoS attack where someone
will, on purpose, make your node's liquidity get stuck.  So, if they send a
payment and use you as part of a forwarding or a routing node, they can on
purpose make their HTLC (Hash Time Locked Contract) fail and lock up your
liquidity.  And this is what a channel jamming attack is in general terms.

So, there was a proposal previously called HTLC endorsement that has now been
replaced with now called accountability, or just in general, accountable HTLCs.
So, this Eclair PR #3217, basically what it does is that it implements this
BOLTs #1280 PR that is currently still in a proposed state, but Eclair has taken
a step forward and has actually implemented this.  And basically, the logic
around the change, we can get into more details, but in general, the logic here
is that previously, this was kind of a prediction signal that was trying to
create a reputational system for different nodes.  And it's like, "Okay, this
node wants me to route this payment for him, so I will.  In the past, this has
always worked out, so I endorse this HTLC coming from this peer, and I will let
the next node know that I have endorsed this peer".  However, this didn't really
work out properly because it was considered that this was more a prediction
signal instead of being an enforced responsibility signal.  So, now, this has
shifted towards an accountability system where instead it's, "I will hold you
accountable for this liquidity that you're locking up for this payment.  And if
something fails in this routing, then I can then come back and say, 'I'm going
to hold him accountable for failing this payment and I'm going to treat in the
future this node differently, because it didn't work out in this scenario'".
So, Eclair implements this, it's still in development, it's still in proposal
stage to BOLTs #1280, so it might still change.  And Eclair is often just
updating its implementation as this moves forward.

_LND #10367_

And the next PR, LND #10367, it kind of just renames it without making any
functional changes, probably still waiting for the PR to get in later stages
before making more functional changes.  Yes, Murch?

**Mark Erhardt**: I wanted to add a little bit.  So, there's two different
jamming attacks.  One is fast jamming, one is slow jamming.  Fast jamming is
when you make a lot of small payments quickly and you're trying to jam up the
limited number of HTLC slots on a channel.  So, you can't have more than 483
HTLCs on a channel at a time.  If you use them all up, no payments can be routed
through the channel.  The resolution to that is that every HTLC should cost some
fee in advance, the advance fees mitigate this issue.  The alternative is slow
jamming, where instead of trying to jam up the HTLC slots, you jam up the
liquidity in the channel.  So, instead of making many fast payments on a channel
to consume a lot of the HTLC slots, you instead make very large payments and
take a long time to resolve them.  And if all of the liquidity is locked up in a
channel, you can't make payments due to there not being any liquidity rather
than HTLC slots.

The reputational system that Lightning developers have been developing for a
long time is intended to fix the slow jamming problem, where you basically split
up your resources and you say, "Only half of my liquidity can be used by peers
that are not trusted, don't have good reputation", and the rest of their
reputation is reserved for -- sorry, it's the other way around.  Half of the
liquidity is available to people that don't have high reputation and the rest of
the liquidity is also available to users that have high reputation.  And I
believe they originally tried to move forward with the reputation in the sense
of endorsing.  You would tell your peer, "This is from a good source.  Please
treat it as endorsed", and then you would say, "Well, I trust that peer and they
endorsed it, so I will endorse it too to my peer".  Someone found a bug at a
Hackathon with that, so they turned around the approach to the accountability.

**Gustavo Flores Echaiz**: Exactly, because in the end, even if you trust a peer
that's sending you this payment, this peer cannot ensure that it's going to not
fail.  Instead, what accountability means is that it holds responsible the
downstream peers for their timely resolution of the HTLC.  So, this is in BOLTs
#1280, which is still in proposed state in draft.  However, also for the next
PR, LND #10367, this is also based on a proposal in the BLIPs repository, BLIPs
#67, which is based on BOLTs #1280.  So, LND basically just makes a surface
change where it renames the endorsement signal to accountable, but it's probably
still waiting for BLIPs #67 to be merged before making other functional changes.

_Rust Bitcoin #5450_

Finally, we have Rust Bitcoin #5450 and Rust Bitcoin #5434, which are both
changes to the transaction decoder to add extra validation rules, specifically
to add better protocol rule validation.  So, the first one, #5450, here it's
just a validation added to reject non-coinbase transactions that contain a null
prevout.  So, obviously, a coinbase transaction doesn't have inputs because
these are newly-created bitcoin.  So, it is the only transaction that can have a
null prevout, but other transactions should not.  So, this just adds a safety to
make sure that other transactions will never have a null prevout.

_Rust Bitcoin #5434_

And Rust Bitcoin #5434, this is just a rule that rejects coinbase transactions
that have a scriptSig length outside of the 2<sup>100</sup>-byte range, which is
another consensus rule.  And this completes the whole section of the Notable
code and documentation changes and Newsletter #387.

**Mike Schmidt**: Awesome.  Thanks, Gustavo.  I think we can wrap up.  We want
to thank Craig for joining us and René for joining us in a separate recording,
and Gustavo and Murch for co-hosting, and everyone for listening.  We'll hear
you next week.

**Mark Erhardt**: Hear you soon.  Cheers.

{% include references.md %} {% include linkers/issues.md v=2 issues="" %}
