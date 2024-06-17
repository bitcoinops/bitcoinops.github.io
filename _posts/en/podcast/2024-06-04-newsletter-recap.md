---
title: 'Bitcoin Optech Newsletter #305 Recap Podcast'
permalink: /en/podcast/2024/06/04/
reference: /en/newsletters/2024/05/31/
name: 2024-06-04-recap
slug: 2024-06-04-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Dave Harding are joined by Setor Blagogee, Oghenovo
Usiwoma, Pierre Rochard, and Alex Bosworth to discuss [Newsletter #305]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-5-10/380271884-44100-2-af7f0107c2ef4.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mark Erhardt**: All right, good morning.  This is Optech Recap #305.  As you
can hear, I'm today impersonating Bitcoin Optech instead of Mike.  So, this is
Murch speaking.  I have four guests today and the pleasure of having David as my
co-host today.  So, let's introduce ourselves.  Dave?

**Dave Harding**: Hi, I'm Dave Harding, I'm co-author of the Optech Newsletter
and co-author of the third edition of Mastering Bitcoin.

**Mark Erhardt**: Pierre?

**Pierre Rochard**: Hey, I'm sorry, what was the question?

**Mark Erhardt**: Could you please introduce yourself?

**Pierre Rochard**: Oh, yeah, happy to.  Hey, I'm Pierre Rochard, I'm the Vice
President of Research at Riot Platforms.  We're one of the largest Bitcoin
miners.

**Mark Erhardt**: Thank you.  Alex?

**Alex Bosworth**: Hi, I'm Alex Bosworth, I'm the Head of Lightning Liquidity at
Lightning Labs.  We make open-source software, like LND, which is a very popular
Lightning implementation, and we also make services for Lightning like Lightning
Loop.

**Mark Erhardt**: Super, thank you.  Setor?

**Setor Blagogee**: Hi, I'm Setor Blagogee, software developer and behind the
BlindBit silent payments light client suite.

**Mark Erhardt**: I had a little bit of an interruption in you speaking.  I
don't know.  Maybe if your network isn't stable, you can move a little around in
your apartment.

**Setor Blagogee**: Okay, I'll try to -- still as bad?  Better?

**Mark Erhardt**: Better, yeah, thank you.  Novo?

Okay.  Hi.

**Eunovo9**: I'm Novo, Bitcoin Core Developer, new to the space, slightly new to
the Bitcoin Core development space itself.  But yeah, nice to meet you.

**Mark Erhardt**: Super.  And I'm Murch myself, I work at Chaincode Labs on
Bitcoin stuff.  So let's take it away right away.

_Light client protocol for silent payments_

Our first topic is going to be Light client protocol for silent payments.  So,
the silent payments BIP was just merged the other week, BIP352.  It describes a
protocol for having a new type of static addresses.  And the beautiful thing
with silent payments is it does not require an onchain announcement, it's just
plain.  You send a transaction and the recipient, even though it is a unique
output script every time a payment is made, can find this transaction to be
paying him or her, and just finds it in the blockchain, can spend it.  So,
there's been a lot of buzz actually in the past couple of weeks about it with
new libraries coming out and new websites to describe it.  And my understanding
is that there was an appendix already in the BIP that described some rough ideas
of how light client support could work for silent payments, because in order to
be able to discover the silent payments, you do need to be able to get the tweak
for each transaction, which is calculated from all the pubkeys of the inputs on
the transaction, and tweak that with your own silent payments public key in
order to find whether an output script belongs to you.  So obviously, this tweak
data would not be available to light clients, even though it is available to
full nodes.  So, for full nodes, it's fairly easy to discover their own outputs,
but how would light clients do that?

My understanding is that Setor worked on a draft specification for a protocol to
help light clients to be able to receive silent payments.  So far, so good.  Do
you want to take it from there, Setor?

**Setor Blagogee**: Yeah, sure.  The problem that we face when we only want to
run silent payments on a mobile client is that we don't have all the data
available, and we have some limitations with regards to computation and
bandwidth.  You have to basically scan for every eligible transaction that
exists in a block and this can be very intensive.  And as the BIP already
outlined, you can compute such a tweak, which already combines the input hash
and the public key sum.  This already saves the light client, for example, one
elliptical curve of computation, which is already a lot of work done ahead.

So, the draft specification kind of outlines how we can help light clients to
save on bandwidth and computation, the first step being this tweak index that
provides this tweaked data, the next being crafting filters, special taproot
filters, that actually do only taproot inputs and outputs, or actually we
separate the spent outputs from the inputs.  So, let me start by outlining what
the process would be.  You get all the tweaks, you compute the potential outputs
and match those against the filter, which is already reduced in size.  So, the
idea was here to only use the subset that is relevant to the light client for
silent payments just in order to reduce the necessary computations and the
bandwidth.

After we find a match against the filter, we download the UTXO set, and here we
also only download the necessary information that a client needs in order to
spend the coins.  And that UTXO set is also reduced just to the taproot outputs
so that we don't have to download the entire block.  So, the entire
specification is basically designed to reduce the bandwidth and the computations
needed.  There are some, let's say tweaks that you have to do so that you should
do it as well with regards to how you run such a light clients, which are
outlined as well.  For example, we try to avoid, or in general we try to avoid
public Electrum servers, for example, and use spent filter indexes, as this
would also lead to privacy, for example.  So, all these kinds of tricks are
outlined in the spec.  Maybe that's a rough overview of what I was trying to
achieve with this draft.

**Mark Erhardt**: Okay, let me try to recap a little bit.  So, silent payments
always create P2TR outputs, and therefore we only need to be able to retrieve
P2TR outputs.  But for each P2TR output that has been created since last we
scanned, we need to find the tweaked data for the inputs which is calculated
from input data that is usually not available in the transaction itself in the
first place.  So, you're proposing that there will be an index added so we can
retrieve this tweaked data for transactions.  So, you're saying probably it's
going to work based on height, so you always get a whole block worth of tweaked
data, and who would be serving this to you?

**Setor Blagogee**: Yeah, good question.  Currently, this is based on
implementation of an indexing server.  The spec is currently based on what I've
done with BlindBit, where we have an oracle which does collect all this data,
all the all this condensed UTXO data the filters and the tweaks, and this is
then served to the to the light client.  There's also a client, or a daemon
which is running, and so right now this is separate data.  But the goal is here
of course to include this tweaked data, for example, already with Electrum, so
this data can be easily made available to everybody.  There is also a PR which
is also done for some comparisons of the indexes for consistency checks, which
would then include this in Bitcoin Core as well, and could then be easily served
to basically anything attaching to Bitcoin Core, allowing basically any software
to serve this client very easily with this tweaked data.

**Mark Erhardt**: So basically, the idea is to add a new index so you can easily
look up this relevant data, and one of the promising targets is of course the
Electrum server that already has this sort of light client service relationship,
but I guess if you're only loading whole blocks' worth of tweaked data, that
would make it more private than giving an Electrum server the filter or asking
for specific transactions only.  So, that seems like a privacy improvement for
light clients.  But it's traded off for a higher bandwidth requirement, because
they have to get all the tweaks; and then more computation, because the light
client still has to perform some computation in order to search, right?

**Setor Blagogee**: Yes.  So, there are different implementations out there
actually.  I've seen many, many implementations take the approach that you just
download the tweaked data, so just, yeah, the 32-byte tweaks, and compute the
potential outputs and match those against the filter ,and then download the
entire block.  With BlindBit, it took a bit of a different route.  I then also
download the reduced UTXO set and only focus on that.  The idea here also was to
reduce the bandwidth, but it's still open to discussion which trade-off is
better in this regard, because using the UTXO set obviously makes it clear to
anybody that you are trying to achieve this as a light client, while reducing
bandwidth, I would say right now a significant portion, because you don't have
to download the entire block, which includes everything else which is not a
taproot output.  So, there's this trade-off that has to be made and that's also
why I'm hoping that there will be a bit more participation in the discussion to
see what will be the best approach or the best trade-off that should be taken to
conserve privacy, but not overload clients with too much bandwidth and
computational requirements.

**Mark Erhardt**: Okay, so one of your calls to actions to our listeners would
be, if you're interested in this light client protocol and you have opinions on
the trade-offs between bandwidth and computation in this regard, and especially
privacy where if you request the tweaked data, obviously you're communicating
that you're interested in tweaked data, but maybe that is not that surprising if
you're a light client already.  Anyway, the other variant would be to download
the whole block.  Does anyone else have a question for Setor?

**Dave Harding**: I don't have a question but I have a couple quick comments,
and the first is that I ran some back-of-the-envelope numbers, and if every
transaction in a block was taproot, so they would all have to go into these
block filters that are being served from the server to a client, that would be
about 10% to 15% the size of a block itself.  So, we'd have about 85% to 90%
savings on bandwidth.  So, that's just to give you an idea of the impact of this
in an amazing world where everybody's using taproot transactions, and a lot of
them are probably silent payments.

The other thing is the privacy.  We have different levels of privacy in Bitcoin.
So right now, a lot of light clients are using something like Electrum server
protocol.  And for that, the privacy between the client and the server isn't
very good.  If we were all using the protocol that Setor is proposing here, it
would be similar to light clients using something like BIP157, 158 compact block
filters, so it would be a significant increase.  You still get a little bit more
privacy, at least in an information theoretical perspective, if you use a full
node, because nobody can observe what you're doing on the full node.  The full
node does the same behaviors on the network all the time, regardless of whether
it affects your wallet or not; whereas a BIP157, 158 compact block filter client
makes different requests on the network, depending on how transactions affect
this block.  Still, it's very good privacy improvement here, and it's combined
with all the benefits of silent payment.  So, I think this is just a really
great proposal and I do hope more people are active in the discussion, and I do
think I need to post a couple of things there too.  So, that's from me.  So,
thank you for this proposal, Setor.

**Mark Erhardt**: Yeah, thanks for working on this.  Do you have another call to
action, or if anyone else has a question or comment?

**Setor Blagogee**: From my side, I would just like to reiterate also if you do
work on a light client in general, I'm also very happy to exchange notes as
well.  I guess the light client protocol is a central place where this can be
done.  But also, if we just talk about implementations as well, that would
really help a lot as well.  So, yeah, just always happy to exchange notes, I
guess.  That's the most important thing, and I think we all profit from
communication between each other.

**Mark Erhardt**: Yeah, thank you very much for working on this.  So, we'll move
on to the next topic.  If you want to stick around, that would be awesome.  If
you have something else to do and need to drop, we understand.

**Setor Blagogee**: Okay, I think I might listen on, that would be very happy.

**Mark Erhardt**: Okay, thank you.

**Setor Blagogee**: See you.

_Raw taproot descriptors_

**Mark Erhardt**: All right.  And now, our second news item is Raw taproot
descriptors.  So, Novo has posted to Delving Bitcoin about two new proposed
descriptors.  One deals with raw nodes, the other deals with raw leafs.  My
understanding is that it gives you a way of describing some inner nodes in a
script tree and not revealing the entire output script that you might be
receiving funds to.  Now, my understanding is that there were some examples how
you could, for example, use that as a fallback mechanism, backup mechanism, or
as a way of bequesting your bitcoin to someone by revealing only partial
information to them up front and then some remaining information later.  But
maybe, Novo, you can tell us a little more on what your motivation is and what
problem you're trying to solve here.  Thank you, Murch.

**Oghenovo Usiwoma**: So, I created an implementation that was based on some
previous discussions between sipa and Jeremy Rubin and I think AJ, so a bunch of
other developers on Bitcoin Core.  And what rawnode is trying to do is allow
individuals to specify taproot trees, but incomplete taproot trees.  So
currently, you have to know each tree path, each leaf, each branch, because you
cannot specify partial trees in descriptors, but with rawnode hash, you can skip
certain parts of the tree.  You just take the merkle root and place that in the
rawnode hash and that allows you to specify the entire tree in the descriptor.

So, Jeremy was the first person to suggest that this would be useful to
implement the kind of need-to-know branch.  So, Anthony gave a good example.
You want to inherit your money and then you don't want them to know all of the
spend paths available, but you give a person who's supposed to inherit it his
own spend path.  He can see that he has a certain timelock and the rest of the
branches are hidden.  So, the way you do that is by using the rawnode hash to
hide those branches, so the other person doesn't need to know about it.  So,
this is something that can work in certain cases.  It's not for all
transactions, because hidden spend paths can be dangerous.  But in some cases,
you want to have these need-to-know branches and the other party doesn't need to
know about what other spend paths you have.  Murch, seems like you have a
question.

**Mark Erhardt**: Yeah.  So, how would you discover, from having a partial
script tree, how do you find the output script later that you can spend?  If you
have only this partial tree, it seems like you wouldn't have enough information.
So, how do you tie it back to an output script later?

**Oghenovo Usiwoma**: Okay, so the original owner of the descriptor should have
the entire information, right?  Well, if you are sharing to somebody else who
doesn't need to know certain branches, you can leave their spend path open and
then hide the remaining branches using rawnode hash.  So, then you just replace
them with the merkle roots and then they don't need to be specified in the
descriptor anymore.  But the other party can still use that descriptor to watch
for funds sent to that address and to also spend from it, if your wallet
software has the ability to.  So, it's open for you to use it, your spend path
is still available.  If you are given a descriptor that has a rawnode hash in
it, you have no idea what is hidden in the rawnode hash.  Even if you could, you
can't generate addresses.  You don't have enough information to spend from those
hidden paths, just the ones that are open.

**Mark Erhardt**: Okay.  So basically, if I were to use it, I would make up my
own scriptpath spends.  I would create this inner node in the script tree, and
then I would ask someone else to provide their spending script for the fallback,
let's say my heir or whatever.  And then I combine these two to an output
script, where I have the full output descriptor, so I know what their spending
conditions are, but they don't realize what my spending conditions are.  And I
can share the overall script with the hidden node, so they'll be able to find
the output, but they don't know my spending condition until I use that
scriptpath.  Is that roughly the right understanding?

**Oghenovo Usiwoma**: Yes, you're correct.

**Mark Erhardt**: Cool.  So, how far have you gotten with your proposal, or
what's been the feedback like so far?

**Oghenovo Usiwoma**: So, the feedback is positive, and some people have looked
at the implementation that I have and have asked I open a PR already, and I will
do that very soon.  I'm just also working on other Bitcoin Core stuff, but
that's going to be coming in the next week possibly.

**Mark Erhardt**: Cool, that sounds great.  What else do you need to add, or
what would you like our guests to do?

**Oghenovo Usiwoma**: Yeah, so I think if you are interested in taproot
descriptors and you want to make some comments, the Delvin Bitcoin post is
available and you can just watch out in the next week, a PR will be open for
this too.  Well, I think there might need to be a big draft for this.  All the
descriptors have BIPs attached to them, so I may drop a big draft in the Delvin
Bitcoin post so that we can also start looking at that.  But yeah, there'll be
more stuff coming in.

**Mark Erhardt**: Awesome.  I'll put a good word in with the BIP editors for
you!

**Oghenovo Usiwoma**: That's so cool, thanks.

**Mark Erhardt**: All right.  Anyone else got a question or a comment for Novo?

**Dave Harding**: A quick comment is that I just feel, I think this is something
we absolutely need for cases like the inheritance recovery that AJ described and
that we just described in the conversation.  But I think this is also something
that's going to be challenging for wallets to implement, who might be accepting
descriptors from users who don't understand the trade-offs.  And the idea, the
users might not understand that using rawnode in a descriptor means that
somebody else would probably spend their money, you know.  If you just copy and
paste a descriptor from the internet, because somebody tells you it's a good
idea, this is how you back up your bitcoins, and you fill in the parts of the
descriptor that you know with your own keys and whatnot, but you still have that
rawnode in it, you should always assume somebody else can steal that money.

So, I think this is something that we're going to find some challenges in seeing
actual end user wallets implement, because it is a potential foot gun for people
who don't entirely understand what they're doing.  So, it's something that we
need for power users and for cases like that inheritance backup, but it's also
something that we're going to have to do a lot of thinking about the user
interface around it, the user experience there of making sure people don't
accidentally lose all their money to scammers.

**Mark Erhardt**: Yeah, I think you have a good point there.  Oh, Novo, go
ahead.

**Oghenovo Usiwoma**: Yeah, I was going to say the same thing.  You made a
really good point.  I didn't see who was speaking, so I don't know who said
that, but that was a really good point.  But definitely a good thing to iron out
those issues.  Right now, I'm not part of any specific wallet implementation for
this, just doing the Bitcoin Core stuff, but we definitely need to iron out some
of the issues.  I think joining the discussion on the Delving Bitcoin post, or
maybe on the PR, but the Delving Bitcoin post is probably the better place for
it, so we can drop some, what do I call it; drop some notes for wallet for
wallet maintenance, yeah.  But I think generally in the Bitcoin space, I feel
like most of what we do is for power users.  The average individual doesn't
usually know how to use all this stuff.  I can't make people even know what the
descriptor is, but I understand that it is dangerous for you to just copy a
descriptor and then send funds in it.  Murch?

**Mark Erhardt**: Yeah, I wanted to add a little bit to that thought.  So, yes,
a lot of new wallet features start out as something that power users might be
looking into, but for example with the output script descriptors or wallet
descriptors, there's a very clear case to be made as the topic is explored
further and all the descriptors become available actually, the miniscript
descriptors, the taproot descriptors, and so forth, that people are going to
build really nice UX for end users that don't have to understand in detail how
the wallet works, but it'll just work from the wallet.  For example, with Liana
wallet, they pioneered this a year ago with miniscript already with the decaying
multisig, where it starts out with many keys and a high threshold, and over time
the set of keys may change or the threshold gets smaller, so if you lose some
keys, eventually you'll get access with a smaller set of the keys.  Or the, the
inheritance setup, that's been mentioned a few times.

So, I think we've seen this in this cycle with the taproot proposal.  With
segwit, it was very clear, you would just immediately get a huge block space
reduction by adopting segwit and it rolled out somewhat quickly, but even so it
took five years for 90% of transactions to have segwit inputs.  But with
taproot, we've seen now it took even a few years first for the tooling to
appear.  So, I think with descriptors it'll be similar, where it'll take some
time for people to come up with creative ideas how to build good UX with these
new tools; but ultimately, even though they may start out as power user tools,
they'll be great tools for wallet developers to build good UX for any user.

**Oghenovo Usiwoma**: Yeah, I agree.

**Mark Erhardt**: Super.  Thank you, Novo for working on this and coming to
present about it.  You said that people could comment on your Delving post and
we should hope to see a BIP draft soon-ish.  Is there anything else to add here?

**Oghenovo Usiwoma**: No, not really.  There's another descriptor that I also
added, you remember it's two, but I think we can leave it here.  The second one
is less controversial.  It's just about bringing the ability to have raw, raw
scripts inside your taproot tree.  So, I'm calling it rawleaf, although some
people wanted to just call it raw, but this descriptor takes a version too, and
I think I'm against the idea of overloading the name.  I prefer we just keep it
rawleaf so it's clear that this is for taproot and it has a version attached to
it.  Yeah, but we'll see.

**Mark Erhardt**: Yeah, sorry, I thought we sort of had covered both already.
My understanding is that rawnode is sort of the superset and it can also take a
leaf, but rawleaf specifically only refers to the leaf; and the difference is
that in rawleaf, you can also specify a new version of tapscript.  Is that
right?

**Oghenovo Usiwoma**: Yes, you can.  So, true that rawnode can take the leaf
too, but the idea is to parse all information that you possibly can in the
descriptors, so if you don't want to hide your branches, you don't need to do
that, you can just specify the rawleaf and add your new taproot versions.

**Mark Erhardt**: Okay, super.  Thank you for joining us.  We'll be then moving
on to the next topic.  Same for you, it would be great if you want to stick
around, otherwise if you have other things to do, we understand.  Thank you for
joining us.

**Oghenovo Usiwoma**: Thank you, thank you Murch.

_Should overlapping soft fork proposals be considered mutually exclusive?_

**Mark Erhardt**: All right, cool.  Our last news item this week is, Should
overlapping soft fork proposals be considered mutually exclusive?  So, as
presumably all of our listeners, or at least the regular listeners are aware,
there have been a number of different introspection opcodes proposed, or
covenant opcodes, and they seem to have all sorts of overlaps in what they can
do, the trade-offs are somewhat abstract and at times not super-clear.  So,
Pierre looked into whether all these opcodes that do such similar things should
be activated in parallel, whether we should select a subset of them, and how we
might think about making decisions about that.  Pierre, do you want to take it
from here?

**Pierre Rochard**: Yeah, sure.  So, I've been following along with Bitcoin
development for the better part of a decade now, and I've found that a lot of
the narratives that have emerged don't really make sense to me.  So, on one end
of the narrative, that if we don't have technological innovation in Bitcoin,
that Bitcoin is going to lose market share; and then on the other end, the
narrative of ossification, that if we don't stop technological development, then
Bitcoin will collapse under software risk.  So, I find both of these extremes to
really be lacking in logic and data, and that I'm trying to figure out what the
truth is, so I've been reading a lot of the recent introspection proposals that
you were referring to, and you see these matrices that compare their trade-offs
or features, and there is a lot of overlap.  So, it seems to me that part of the
deadlock is trying to figure out which one's the best.  And when I was thinking
about it, I was like, well, why not just do several and then let the developers
who are building on top determine what's best for their particular use case?
And obviously, I'm aware that there are costs to having more surface area,
having more code, but that it would kind of get past this dog-eat-dog or crab
bucket, "Hey, we have to tear down other proposals in order to promote our
proposal" type thinking.

So, I wanted to open up that conversation in Delving Bitcoin and I got two great
responses to it.  I really liked AJ's response quite a lot.  I spent a couple of
years in product management at Kraken, and one of their principles of product
management is to start with the user in the front end, and then work your way
back to the layer 1 from there.  And I think that was AJ's perspective as well
of, "Hey, let's develop prototypes, front ends, that are using the Inquisition
feature and just testing things out end to end, before committing to having one
or more proposals activate on Bitcoin", and I think that's a really reasonable
perspective.  It does introduce kind of a chicken-and-egg problem of
entrepreneurs not wanting to invest in developing a prototype if they feel like
it's very uncertain or unlikely that ultimately the layer 1 opcode will be
activated, and so perhaps they're experiencing some anxiety there of not wanting
to invest when there's uncertainty.  But I think that it's still on them to
underwrite that risk if they want to develop a new product, and that that new
product requires a new opcode.  So, I thought that was a reasonable response.

I also thought though that there's some proposals, in particular the OP_CAT,
where the lines of code is so small that I'm thinking that it's really just an
immaterial change from that perspective, and the controversies about risk have
really been overblown.  So, yeah, I'll leave it there.  I'm interested in
hearing other people's thoughts, questions, concerns.

**Mark Erhardt**: Yeah, I wanted to pick up on one of the things that you said.
So, on the one hand, yes, it's a risk to invest into a prototype of something
that you're unsure will be able to be launched on mainnet.  But to make just a
proof of concept would probably be such a strong signal, because we've been
having this debate about opcodes for two or three years and there's hardly any
activity at all on signet with people testing any sort of proof of concepts, or
making transactions that use these opcodes that are already active in
Inquisition.  Or maybe this is a little different by now, but that was my latest
understanding.  And so, if someone actually went ahead and built their proof of
concept and launched it on Inquisition or showcased it, that would be such a
strong signal for their favorite proposal that I think they could make a lot of
inroads that way, too.

**Pierre Rochard**: I agree.  And for something like this, they could take a lot
of shortcuts in terms of what the prototype is in terms of, they don't need to
have it be production-ready, in the sense of fully secured and all that, but at
least to give a vision to people of what the value would be of the opcode.  It
seems reasonable in my mind that that would be profitable for them.  But yeah, I
don't know what's stopping them from doing that at this point.

**Mark Erhardt**: Dave, Alex, Novo, you all must have heard a little bit about
the introspection debate.  What's your take on the situation?

**Dave Harding**: Yeah, I think it's really hard for a lot of us who are kind of
libertarian-minded not to say, "Yes, go ahead and activate all this stuff, just
throw it all in and let's see what happens".  I don't think any of us want to
feel like, you know, gatekeepers is the wrong word, but just sitting here and
telling people that their proposal isn't ready, because a lot of these
proposals, from a consensus code perspective, the consensus code has already
been written, it's already been activated on Inquisition, people can already use
it, and we would want to do some more engineering to get it into Bitcoin Core
proper and get it activated on mainnet.  But it's probably not a lot, especially
for those small proposals Pierre has mentioned, like OP_CAT.  But on the other
hand, this is something that we're going to have to live with if we activate it
for the rest of Bitcoin's existence, because once we add new features like this,
and people start making their money dependent on that, we can't take them out,
unless there's an absolute huge security vulnerability.  And at that point,
we're destroying people's money in order to save some other people's money.
It's just not good.  So, it's a tough problem.

The thing that kind of interests me here is that, as Pierre is mentioning, a lot
of these proposals are kind of equivalent to each other, at least from a
functional perspective, not necessarily from a how-you-use-them perspective, but
what you can accomplish is basically the same.  And a lot of those features are
already available on things like the Liquid sidechain, and a lot of the features
are also available on altcoins.  For example, Ethereum, if you want to use
covenants, you can do covenants on Ethereum.  And a lot of times we don't see
people really using these features on Liquid and on Ethereum, for example look
at vaults or whatnot.  There are some vault constructions on Ethereum, but they
aren't highly used.  And it always makes me wonder if these things actually have
market fit, if people would actually use them if they were available on Bitcoin,
because again, you can already do them on other things.

Now, there are differences.  Liquid is not a great long-term store of value
because it's a federated but centralized sidechain.  And Ethereum is also
probably not a great store of value, because they're always changing what
they're doing.  So, maybe there is no demand there for long-term protocols and
stuff.  But I'm just always curious about this stuff.  I want to see, like AJ
said, I want to see people writing the code for these things, but not just, like
AJ said, to see which construction is most comfortable for programmers, but I
also just want to see some evidence that people are actually going to use this,
that it's actually worth the support burden on Bitcoin to maintain this thing in
perpetuity for us to activate it on mainnet.  So, that's where I've been for a
number of years on these covenant things, is just I want to see some evidence of
long-term demand for them.

**Mark Erhardt**: Thank you, that's a lot of important points here.  Alex, you
wanted to say something?

**Alex Bosworth**: Yeah.  I mean, I don't necessarily have any specific thing to
endorse, but just to talk to a couple of the ideas.  Number one, I'm not a huge
believer in the idea that if it's simpler code, that it's actually simpler
overall, like number of lines of code doesn't necessarily translate into the
impacts.  So, I think Christian Decker had a presentation about how he didn't
even realize the ultimate impacts of his own simple proposal.  And that's
something that he kind of took back is like, well actually, even though it's
super, super-simple on the surface, and it was very tightly scoped, it actually
could have huge scope implications.  And we've seen that more generally in
Bitcoin, like we've had inflation problems where we didn't even think we were
touching consensus code, but actually we've just introduced infinite, infinite
supply to Bitcoin.  So, that's just a tough problem of analyzing the scope of
change.

Then, the other thing I think, the idea that we can't take it back, maybe
there's some reason this isn't considered, but there could be a timeout for
protection, right, like a soft fork is protecting a spendable output from being
spent, based on new conditions.  So you could say, "Well, that could have a
timeout".  It could say, "This is only going to protect us for two years, or
something, and then afterwards there's no protection so better get your coins
out".  That might be a way to evaluate whether something's working and then if
it is working, you could extend the extend the protections, like a term limit or
something.  So, I think there's plenty of discussion that's possible, but I
don't have anything to really say specifically on any specific proposal, just
because that's not something I like.  I work with more interactive uses of
Bitcoin, and pretty much this whole concept is dealing with situations where you
can't be interactive.

**Mark Erhardt**: Super, thanks for your thoughts.  I think you have a very good
point about small code change doesn't necessarily mean low complexity.  My
understanding is that, for example, OP_CAT is super-flexible and it could be
used to simulate a lot of the other more powerful introspection opcodes, but
with a lot of onchain data added.  So, it might not be attractive to use on
mainnet, but you could craft all sorts of things just by adding concatenation.
So, yeah, I think the devil's in the detail and on the one hand, I feel like
there's a burden on the proponents of these introspection opcodes to make us
long for the sea so that we all together build the boat; but on the other hand,
I sort of feel very clearly, just with onchain transactions and the current
block space supply and so forth, obviously we won't be able to onboard the
entire world to Bitcoin, if that is even the long-term goal.

But to build other constructs, we will need some of these introspection opcodes
or some other new ideas that we haven't even talked about yet, and so in the
long term, I do agree that we need something like that, but I'm just not
convinced of any single one of them yet.  I haven't heard the story yet that
made me jump and want to build the boat.  All right, Dave?

**Dave Harding**: I just want to quickly mention, Alex was talking about the
idea of automatically expiring soft forks.  So, we did cover that, I just
checked, Newsletter #197.  So, if anybody's interested in that discussion, go
check Newsletter #197 for that idea.

**Mark Erhardt**: Cool.  So, thank you very much.  I think we'll wrap the News
section here unless, Pierre, did you have a call to action or something to wrap
it up?

**Pierre Rochard**: No, I just wanted to thank everyone for sharing their
thoughts, and I agree with Alex that the side effects can be very nuanced, even
with a short amount of code.  So, glad we've got brilliant minds thinking about
this topic.

**Mark Erhardt**: Super, thanks.  And again, as with everyone, if you have other
things to do, we understand if you have to drop.  But if you want to stick
around, you're welcome, and thanks for joining us.  So, we will be wrapping up
the News section.  We will be skipping over Selected Q&A right now so we can go
directly to Releases and release candidates, so we can get Alex to cover his
topic, and then after that we'll do Selected Q&A.

_LND v0.18.0-beta_

So in Releases and release candidates, we've already teased it a few times in
the past weeks, LND v18 has been in the works and we've been saying that we'll
get someone on that can walk us through it.  I took a brief look at the release
notes.  It seems to me that the main themes of this release, and it seems to
have a ton of stuff in it, but the main themes seem to be the new inbound
routing fees, which allows people to take fees, or rather right now it's only
recommended to offer discount on an inbound channel in order to change the
incentives of people using your node as a routing hub.  There's a bunch of
different PRs that work towards support for blinded paths, and I've seen a few
things that seem to deal with onchain feerate and transaction improvements,
probably owed to the last year's tumultuous feerates.  Alex, what else am I
missing?  What is really cool and to be known about LND v18?

**Alex Bosworth**: I'm not sure if you got the database; I was listening for the
database change, so that's not really like a protocol level thing, but LND has
in the past used a database called boltdb, which is a key value store and
there's a migration underway to move to SQlite and PostgreSQL as the main back
end.  So, new nodes that start on v0.18 will use this new system partially.

**Mark Erhardt**: Okay, cool.  That sounds like something that's probably
stretching over multiple releases.  I'm very excited to see that there's a bunch
of blended path work in here.  That seems to be a general theme in Lightning
releases.  We've been talking a bunch about LDK and Core Lightning (CLN) also
making steps towards that.  What are your thoughts on blinded path support?

**Alex Bosworth**: Yeah, I think it's pretty interesting.  So, you're right,
there's a bunch of PRs, so it's a very large-scope project just from end to end
about redefining how payments work overall, and it's not backwards-compatible
really, or it wasn't really designed to be backwards-compatible, so we're kind
of working to make it more backwards-compatible.  So, I think BOLT11 would be
extended to kind of include the blinded paths information.  And if you don't
know what blinded paths are, it's kind of like I want you to pay to me but I
don't want you to really know all about me, so I'm going to encrypt my identity,
I'm going to encrypt the final path to get to me, and then you are going to pay
to the place where you can see.  But then, once you get to that place, then that
place will start to unwrap instructions about how to get to me.  The LND v0.18
would introduce the ability to pay to those, but not to create the receiving
part.  So, the receiving part may be 0.18.1 or maybe in 0.19, I'm not sure, and
also a lot of these features are contributed by external contributors; it's not
like a single development, top-down process.  The same thing goes for the rate
discounts.  That was also an external contributor, so it's just kind of in the
process and will take years.

So, the other thing I think is interesting about blinded paths is, it
potentially allows you to flip the pathfinding script.  So right now, it's a
problem if you want to be paid on Lightning.  So, people pay us on Loop
offchain, and it can be difficult for them to find a path to us.  So, what we
could do is we could say, "If you tell us something about where you are in the
network, then we can do the pathfinding, and all you have to do is pay to some
place that you know, and that could be represented by the encrypted path".  So,
we can kind of take over the pathfinding for somebody.  And that's also kind of
the problem that Loop is already trying to solve for people is like, it's hard
to have people point capital in your direction who also have very liquid capital
pointing in their direction.  And it also is dealing with another problem of
just general problem of liquidity with regards to path encryption, which is we
don't have a way to know the liquidity is going to be present.  So, I can
encrypt my identity, and I can encrypt the identity of one of my peers, but it's
difficult for me to encrypt a lot of path data, because I don't know if those
paths will be liquid, like the liquidity data isn't gossiped.  And even if it
were, it wouldn't be provable, or it will be ephemeral.

So, there's a lot of stuff to work out with regards to liquidity, and it'll be
interesting to see how people play with this feature as it evolves.

**Mark Erhardt**: Right.  Thank you for all that information on blinded paths.
So, it sounds like LND will now be able to pay to them.  You said there's work
being done, so receiving will be able from LND and you bridged it over to how
Loop might use that to do the route.

**Alex Bosworth**: Yeah, only paying...

**Mark Erhardt**: Yeah, right.  Anyway, that's really cool progress.  I'm really
curious about the inbound routing fees.  That sort of breaks with the prior
established premise where when you forward a payment, you take your fees on the
outbound channel.  So, if Alice pays to Bob pays to Carol, Bob would be able to
collect a forwarding fee on the Bob to Carol channel.  So, now inbound routing
fees, from what I understand, allow Bob to make a determination about how much
fees would go to him on the Alice Bob channel.  Obviously, if Alice and Bob are
both in the same channel, usually there are no fees in the first hop at all.
So, first thing maybe, does this allow introducing fees to counterparties paying
each other already?

**Alex Bosworth**: Well, it is still the same concept of outbound fees.  But
what it is, I think it might be named a little bit confusingly, what it really
is is a discount.  So, it's kind of addressing a weird situation that we have
with the fees in the network, where depending on the source of the forward, I
can't charge a different rate.  So, it's like if I'm operating a shop and I'm
selling apples and pears, but people come in and they spend US dollars or
Canadian dollars, I'm not really allowed to set a different price in US dollars
or Canadian dollars, I have to just charge one price.  So, no matter what the
source is, I only can charge that one dollar amount, so whether it's Canadian or
American.  So, that creates a weird incentive problem, where routing nodes are
kind of incentivized to charge the higher of the two, because they wouldn't want
to get lowballed by somebody coming in and paying with the cheaper currency.
So, the inbound fee kind of gives you the ability to say, "If traffic is coming
from here, I'm going to give it a little bit of a cheaper route".

That can be pretty useful for us with Lightning Loop, because a lot of traffic
goes to Lightning Loop as people do Loop Outs, but not as much traffic comes
back, so it leads to a lot of closing of channels and it leads to people needing
to increase the fees, which increases the cost to use Lightning Loop.  So, with
this tool they can say, "If traffic comes back from Lightning Loop specifically,
from the Loop node specifically, I'm going to give it a discount because I don't
want to close that channel, I don't want to have to pay that chain fee, I don't
want to lose that inbound liquidity".  So, it adds expressibility, which
hopefully would allow for a better market, a more efficient market, where people
are more free to choose lower prices.  And it's not like the be all end all of
how the routing fee market could work, but it's kind of a step in the direction
of more expressibility for routing node operators.  And it's
backwards-compatible in the sense that if you don't know about these discounts,
you'll just pay the full price and everything will work as normal.

**Mark Erhardt**: Right, so the problem is of course that you might have a
channel where you always have outflow, so you start charging a higher feerate on
that, but some of your inbound channels have either way high outflow or high
inflow and you want to treat those differently.  So, you can now give a discount
depending on what inbound channel forwarded the payment to you, rather than just
determining it based on the outbound channel.

**Alex Bosworth**: Yeah, exactly.  So, you'd want to set it on your highest;
just practically, if you're operating a routing node, you want to set it on your
highest outbound destination.  And then, it's also useful in the context of just
friends.  So, I want to let a friend pair with my node, or I'm running multiple
nodes and I don't want to pay myself fees, so I can give my friend discounts or
I can give myself discounts so we're just forgetting about fees for this
specific peer.

**Mark Erhardt**: Yeah, cool.  I also saw that there's an update in this release
that makes watchtowers taproot-ready?

**Alex Bosworth**: Yeah.  And so, the watchtower protocol goes back a long ways.
But every time the channel format changes, so there's a new -- the last release
introduced a simplified taproot channels.  So, every time there's a new channel
type, there needs to be a new justice registration with the watchtower.  So,
there's a bunch of watchtower upgrades in v0.18, like watchtowers could
potentially get stuck and problems like that should be resolved.  But yeah, if
you're using the new, it's kind of an experimental, only private, taproot
channel system, then now it will be covered by a new section so you'd be able to
register those justice transactions.

**Mark Erhardt**: Cool, so things are sort of rolling towards simple taproot
channels coming out sometime?

**Alex Bosworth**: Well, the simplified taproot channels are out, it's just kind
of an oversight that it wasn't covered by the watchtower!

**Mark Erhardt**: Oh, gee, okay!

**Alex Bosworth**: Yeah, and watchtowers still have plenty of upgrades, so
watchtowers are kind of just a last resort.  Like, they don't cover Hash Time
Locked Contracts (HTLCs) yet, for example.

**Mark Erhardt**: Right.  I did see that there was a bunch of different changes
to onchain feerates and how transactions are being built.  So, for example, I
saw that there was a new sweeper.maxfeerate added, which allows you to limit the
highest feerate your channel will use to sweep a channel.

**Alex Bosworth**: Yeah, so it's kind of a totally new concept for the sweeper.

**Mark Erhardt**: Cool, super.  Are you looking towards TRUC transactions in
this regard already?

**Alex Bosworth**: I think that's something that is being considered, but this
is really just more basic.  The idea is, I think it's actually going back to the
anchor format just at the base level.  So, anchor channels, the idea is that you
can adjust the fee on them using CPFP.  So, that would be going back to like,
"Oh, can the child always pay for the parent?"  But we had even a more
fundamental problem, just at the implementation level, which is, are we actually
even bumping properly?  So, the old bumper wasn't really always thinking in a
very structured way about how much time it has left to bump, and it wasn't
thinking, "Okay, how much can I aggregate all these transactions that I have to
bump within the timeline within similar timelines?  How can I fold them
together, or maybe I have to split them apart?"  So, if you have a very far-off
deadline, but you have different deadlines for two different transactions, or
two different inputs that need to be swept, maybe at the beginning you can kind
of fold them together and hopefully you get a low feerate.  But then, as the
deadline kicks down, maybe you have to use RBF and restructure how those are
being swept, so that one is being swept at a higher feerate than the other one,
which can separate out and be swept at a lower feerate.

This is kind of a new concept for how the sweeper works, in terms of it's kind
of like a redesign.  So, again, this is probably going to be iterated on in the
maybe v0.18.1 or 0.19.  The ultimate idea is once we have a super-strong
framework for how all these transactions are put together or pulled apart, then
we can say we're going to be a lot more aggressive about chain fee selection,
because maybe we have a deadline that's a week in the future, so we don't need
to be very aggressive about sweeping, or aggregating a specific input that
doesn't need to be swept very quickly with something that does need to be swept
very quickly.  And this is also user-interactable.  You can use it with your own
things that you're trying to fee bump via CPFP.

So, if you have a channel open, what you can do is you can talk to the API, you
can talk to the sweeper engine and you can say, "Hey, I have this channel open,
it's been stuck for a while.  I wanted to confirm I had a new argument".  So,
one new argument is a deadline, so it's like, "I wanted to confirm before this
time".  And another new argument is the max fee that I'm willing to pay that you
mentioned, so that's kind of defined as a budget, like this is what it's worth
to me.  You can also set the starting fee.  Then, it will take all those
instructions and then fold them into this new engine and say, "Okay, this guy, I
can match you with other guys that also have similar deadlines", and if the
deadlines are starting not to match, because it's not going to confirm they're
all folded out.

This code was super-complicated before and hard to reason about, and the new
code is hopefully a lot better.

**Mark Erhardt**: Yeah, that sounds really good, like a lot of improvements and
just how reliably you can manage your channels, and probably sets up LND to be a
smoother sailing experience.

**Alex Bosworth**: One of the main problems that routing node operators is their
force closes are expensive, and that's what the sweeper directly addresses,
which is, "My force closes are too pricey, it's costing me like an insane
amount, so it's making it hard for me to even run a routing node".  And so the
sweeper, maybe not in this release initially, because it hasn't necessarily been
fully optimized in terms of chain cost, but if we use this, hopefully then we
can get to the absolute minimum of how much it's going to cost you to run a
routing node if you have to deal with force closes.

**Mark Erhardt**: Yeah, I've seen also across the different Lightning
implementations that there's been a lot of work to generally reduce the force
closures, make them a little more lenient about this and that mismatch or
feerates.  And yeah, basically the onchain activity of the last year sort of
stress-tested a few assumptions and behaviors there.

**Alex Bosworth**: Yeah, I mean, it's insane to think that there's such a
mismatch between the feerates, between two different time periods.  And if you
open up 1,000 channels in a batch open, it can cost you 5 cents per channel in
the open.  But then, in the close, it could cost you $100 per close, because
chain fees can go up a lot and closing is not batched.  So, you're talking about
$100,000 for 1,000 channels.  That starts to worry people.  So, we can play with
that by changing the timing, changing the closing protocol, that kind of thing.

**Mark Erhardt**: Yeah, sounds great.  I also saw in this context, what was it
now?  Okay, I lost my trail of thought, sorry.  Oh, yeah, testmempoolaccept.  I
saw that before LND will broadcast a transaction to the network, if it has a
btcd or a bitcoin backend, it will run testmempoolaccept against this backend to
see whether its own node would accept the transaction.  So, my understanding was
that, I don't know if this is true for LND, but some Lightning implementations
were just bumping transactions to higher feerates and continue to try to
broadcast them until they went through.  But clearly, that would still not work
when, for example, the parent transaction was below the node's dynamic minimum
feerate.  So, is that related at all?

**Alex Bosworth**: I mean, v0.18 is a huge release.  There's so many things in
it that are small things, because we're in June now and I think the last big
release was in October.  So, there are multiple things in terms of these
feerates.  So, testmempoolaccept is kind of an optimization where, yeah, LND is
trying to stay separate in its concerns of trying to let Bitcoin Core figure out
what should belong in the mempool, and LND doesn't have to do that job.  And LND
also doesn't want to do fee estimation, so it wants whatever backend you have to
do that by itself.  But then, there's that mismatch of LND doesn't know what
fees are going to work.

So previously, the design pattern was, "I'm just going to publish everything I
possibly can to Bitcoin Core and whatever works, works".  And Bitcoin Core has
-- I think that the testmempoolaccept is actually kind of a newer API, in LND is
pretty old, and it was also designed for btcd, and btcd is based on a really old
Bitcoin Core.  So, I think this is kind of an optimization where you just won't
see a bunch of errors in your Bitcoin Core of like, "Oh, somebody tried to
publish a too low-fee transaction".

The other major change though is it's going to look at the fee filters to try to
figure out what are the baseline relayable transaction fees that I can be using,
so that LND can kind of import more state from Bitcoin Core to know about how it
should be setting the transaction fees on its transaction.

**Mark Erhardt**: Yeah, super, thank you.  I saw another thing that, well, maybe
amused me a little unfairly, but I saw that this release drops Litecoin support.
Is it just that the LN on Litecoin isn't really much of a thing?

**Alex Bosworth**: Well, it's probably a lot less now, because LND is not
supporting it.  But to be honest, it wasn't supported before, but it just wasn't
even really noticed.  So, if you had tried to run it before, it just would
break.  I had my own Litecoin node running on LND for a long time, and then at
some point I didn't even notice myself LND stopped working with Litecoin.  And
also, well, there was a data migration, so you couldn't go back and so your node
was non-functional, and that was pretty tricky in terms of recovering funds.
So, I was able to go in and hack it myself.  Some part of it had to do with,
there was a fork on the Litecoin protocol.  So, Litecoin used to kind of mirror
Bitcoin Core protocol, or relay policy and Bitcoin consensus rules and that
actually changed with their Mimblewimble support.  So, I had to kind of hack
blocks around so that it worked.  And their Taproot app also worked differently.
They use a different number, or something; I forget.  I was able to rescue all
my coins, but yeah, the Litecoin support was never really apparent.

The LN overall, it really depends on this network effect.  So, if you don't have
enough people and a liquidity, the network is very useless.  That's kind of the
flipside of growing a network, increasing the utility of the network, is when
you get started, it's very hard to bootstrap because the utility is very low.

**Mark Erhardt**: Yeah, that's rough that the support for Litecoin actually just
sort of fell away and nobody reported it.  But that's also indicative that it
wasn't in that much demand.

**Alex Bosworth**: Yeah, and they also, I mean to be fair, they have faster
blocks, right?  They hit 2.5 minutes or something, and they don't have many
onchain transactions.  So, it's not like they have a lot of costs.  So, the
demand just wasn't really there and it never really got pushed.  I think maybe
somebody else is maintaining maybe a fork of Litecoin with LND.  And LND also
still maintains, so this was actually in the Lightning protocol concept from the
beginning, was that there was going to be multiple chains.  So, when you sync,
you are talking about a different chain.  So, it's possible that it could come
back or that there could be multiple chains still, but it's not a priority and
it doesn't seem to be any demand.

**Mark Erhardt**: Right, yeah.  So, we've talked a bunch about what's in the
release.  I saw that there's a ton of bug fixes as well and so forth.  Would you
say, or do you want to point out some more things that we haven't covered yet?

**Alex Bosworth**: Well, talking about the sweeper in terms of cost is only one
side of it.  The other side of it is that the deadline is very important,
especially when chain fees are going up and down.  You need to make sure that
you get confirmation before a certain time.  And we started to see people
hacking their LND where they just don't want to pay the fees, so they're just
letting deadlines expire, and that's not really within the design parameters of
Lightning.  You have the time period when you're supposed to spend something,
and if it's not spent within that time, then you're no longer protected.  So,
that's something that hopefully will be improved in this latest release.  And
there's a lot of other similar kind of security concepts that are sprinkled all
along the way of the many months that the release has been out.  So, that's
always a good reason to update, even if no feature is jumping out at you.

The inbound fees also, just to talk about the flipside of it, the new
pathfinding, like the existing APIs, will just work with the new inbound fees,
so you won't really have to upgrade anything.  The only thing you might have to
think about is this new data field on channels.  That's something to keep a
watch out for if you care about it.  And then the database is kind of a work in
progress.  So, one thing I saw is as migrations happen, just generally through
releases, there might be regressions in terms of speed and data consumption.
So, it's important to monitor to make sure that everything is within the scope.
Sometimes, a regression is committed to like, okay, we know that it's going to
be slower, or we know that it's going to take up more data.  So, if that's an
issue for you that you notice in testing, you should talk about it, report it,
so that those trade-offs can be thought about.

**Mark Erhardt**: Yeah, all right.  So, if you're starting out with the new
version of LND, especially if you depend on it, carefully read the release
notes, there's a lot of stuff in there.  And be mindful if you see some changes
in how it behaves for you, I'm sure the people at LND would like to know about
it.  Dave, do you have some questions, comments?

**Dave Harding**: No questions, no comments.  Just wanted to say that was an
incredibly comprehensive discussion.  Thank you, Murch, for asking the questions
and Alex for all those amazing responses.

**Alex Bosworth**: Oh, I did leave out the estimateroutefee API.  I saw that
that was in the main announcement.

**Mark Erhardt**: Yeah, go ahead.

**Alex Bosworth**: So, that was an API that uses a test payment instead.  So
previously, this estimateroute API, so estimate an offchain fee for me, it would
use local data only.  So, it would just query the graph to get a fee, and that
was producing very inaccurate results.  And what we saw is that people were
implementing their own test payment systems, and that was causing payment
problems with different types of wallets.  So, some types of wallets have
created channels that don't even exist, but then they exist once the payment
comes in, and it was difficult, we were kind of losing cross-compatibility
between all of these new concepts.  So, there's a new API in there, well, it's
the same API, but it's a new approach where LND internally will make a test
payment for you.  And a test payment is just like a regular payment, except that
the payment hash is randomized, so that it means that the preimage is hopefully
impossible to know.  So, the destination still receives a payment, but they're
not able to take it because they won't know the preimage.  And it's tweaked a
little bit in terms of for private nodes, private channels.  It's just going to
skip over the final destination and consider the last hop reachability, and I'm
not sure if that's going to work with other things, like encrypting the final
destination, but it's very important for a lot of payers.

I mean, myself, for many years, I always do a test payment before I do my real
payment.  It helps you avoid stuck payments, it helps you know what fee you're
going to pay before you pay it, it doesn't take that much time because most of
the time is spent pathfinding to actually find a path that works.  So, I think a
lot of people will find it easier to integrate Lightning now without everybody
having to re-implement this test payment functionality.

**Mark Erhardt**: Yeah, that sounds very useful for Lightning, like routing node
operators especially.  All right.  Thank you so much, Alex, for taking all this
time.  I guess we've comprehensively covered LND's new release now.  We will be
moving on.  Alex, thank you for joining us.  If you want to stick around, please
feel free.  If you have something else to do, obviously we understand.

**Alex Bosworth**: Thanks a bunch.

_Core Lightning 24.05rc2_

**Mark Erhardt**: Cool.  So, there was a second RC in this section.  This is
Core Lightning 24.05rc2.  And I think we'll do what we did with LND, we'll punt
on this and we'll try to get someone on to tell us about the content of the
release when the release comes out.  Again, if you are working on or working
with CLN in your stack, please be sure to check out the release notes or the
open PRs that are merged in this RC, and see if that is going to cause
compatibility issues for you.  Generally, just test and take a look at RCs to
help the teams that are working on these.  After this, we'll skip back up.  If
you're reading along, we'll do the selected Q&A from Bitcoin Stack Exchange, and
I think I'll try to keep it a little short because we're a little longer into
the recap than usual.  All right, here goes.

_What's the smallest possible coinbase transaction / block size?_

Selected Q&A from Bitcoin Stack Exchange.  Antoine Ponceau responded to a
question about, "What's the smallest possible coinbase transaction / block
size?"  And that's pretty easy.  Apparently, the smallest possible block that
you can build today is 145 bytes.  And how does that get put together?  Well, we
know that the block header is 80 bytes; you need 1 byte to communicate how many
transactions are in the block, especially if there's so few; and then you are
able to build a coinbase transaction that has only 64 bytes.  If you want more
details, like what fields and so on, Antoine went into a little more detail, but
maybe check out the question on Stack Exchange.

_Understanding Script's number encoding, CScriptNum_

Going on, the second noteworthy question is, Antoine also responded to a
question about, "Understanding Script's number encoding, CScriptNum".  So, there
is a bunch of opcodes that directly communicate numbers, namely -1, 0, and OP_1
through OP_16 have their own opcodes that directly express a number.  For
everything else, we need to use, I think it's the PUSHDATA opcode, and then
communicate the number in this pushed field.  So, Antoine goes into a bunch of
detail here, how numbers in Script are expressed as byte vectors of up to 4
bytes.  And honestly, when it starts to be little-endian and big-endian, and
then there is two different formats which are used in Bitcoin in transaction
serialization and in Script, so if you're actually interested in the details of
all this, there is a quote of the Python implementation from Bitcoin Core's test
framework there.  So, if you really want to understand it, maybe just look at
those about dozen lines of Python to get a sense of how the numbers in Script
work.  Dave, if -- yeah, cool!

_Is there a way to make a BTC wallet address public but hide how many BTC it contains?_

All right.  Moving on to the third question from Bitcoin stack exchange, "Is
there a way to make a BTC wallet address public but hide how many BTC it
contains?  So, basically this asker is interested in something like confidential
transactions, which as you people probably know, we do not have in Bitcoin.  It
was proposed a long time ago, but then only implemented in Liquid and Monero.
So really, if you communicate a regular Bitcoin address publicly, obviously you
lose the privacy and everybody can look up onchain, or rather in the UTXO set,
how much funds are held by that address.  And, yeah, if you have the whole
chain, also the history of that address.  So, Vojtěch Strnad points out in the
context that with silent payments, now we have a static address format, and I
did this small rant last week already, but really we should have never called
what we previously called Bitcoin addresses, addresses, because address implies
a certain permanence that actually isn't intended.  Each address should only be
used once in Bitcoin.  So really, it may have been better if we had called them
invoice identifiers or Bitcoin invoice addresses.

The silent payment addresses though that we have, we can use as permanent
addresses.  We can share them publicly because if someone pays to them, they
will always create a new, unique output script.  So here, you can share this
address.  People can pay to it and nobody will be able to tell onchain, no third
party that is, whether a silent payment address got paid, how much money it held
or see the transaction history.

_Testing increased feerates in regtest_

All right, moving on to the fourth question, "Testing increased feerates in
regtest".  Ava Chow recommends that if you're trying to test high feerate times,
you should reduce the maxmempool in order to be able to fill it up more quickly,
and then increase data carrier size, which is the configuration option that
refers to the amount of data that can be accepted in an OP_RETURN for standard
transactions on your node.  So, with large OP_RETURN outputs, you can very
easily create big transactions, even though you might only have a single input
and output beyond that.  And then with a small maxmempool, you can provide the
upper limit so that feerates are driven up quickly.  So this is, for example,
useful if you want to experiment how your wallet interacts with high feerate
environments as we've seen them in the last year.

**Dave Harding**: I don't know, I would just add there that it looks like from
Ava Chow's answer that you're still going to have to create a number of
transactions and you're probably going to use a script to do that.  And I think
at that point when you're scripting it, you can probably just create thousands
of transactions almost as easily.  So, I do think this is a good answer.  It
will save you a little bit of time, but you can also just fill up a default size
node's mempool, 300 MB.  The only cost there is it's using more of the memory on
your computer.  So, I don't know, I just think that you can automate this and
you can automate it to do thousands of transactions just as easily.

**Mark Erhardt**: I think it might be a little more complicated to do the setup
for that, because then you start bumping into things like ancestor set limits
and chain limits, so you first have to split up your UTXOs and so forth.  So, if
you use really large OP_RETURNS to artificially increase the size of singular
transactions, you might be able to do it with a lot less setup and not needing
to split a bunch of the outputs before.  But sure, if you know what you're
doing, you can build a script that will first fan out all of your outputs, mine
a few blocks so that they're all confirmed, and then sure, you'll be able to
create a bunch of large transactions, yeah, or not so large transactions.  All
right.

_Why is my P2P_V2 peer connected over a v1 connection?_

Someone asked, "Why is my P2P_V2 peer connected over a v1 connection?"  So,
apparently they saw that they had a node that was advertising readiness for the
new BIP324 P2P v2 transport, but the connection was still v1.  So for example,
if you see a 27.0 node right now, it should be able to do P2P v2, but it might
be connected as a v1 peer.  So, in the response, Pieter Wuille guessed that
probably the announcement of this peer's address information was outdated, and
the asker's node had seen an announcement of the old information of that node,
connected to it with the -- just tried v1 immediately, and therefore didn't
discover that it could have used a v2 connection with that peer.  Any thoughts
on that one, Dave?  All right.  Sorry, go ahead.

**Dave Harding**: Oh, no, I didn't have any thoughts, I was just going to pull
some airtime.  So, go ahead, move on to the next one.

_Does a P2PKH transaction send to the hash of the uncompressed key or the compressed key?_

**Mark Erhardt**: All right, cool.  This is a quick one, too.  So, this person
asked, "Does a P2PKH transaction send to the hash of the uncompressed key or the
compressed key?"  So, I think they're asking about the construction of a P2PKH
output script.  And it turns out that in P2PKH, both compressed and uncompressed
keys are permitted.  However, even though they have the same private key, these
two variants of the public keys that link to the private key will create
distinct addresses.  So, really, if you want to save money obviously, you should
receive two compressed public keys in P2WPKH, and wrapped segwit I think too.
Only compressed keys are permitted by policy.  Uncompressed keys would be
nonstandard, and I don't think anyone implements that because really it would
just be a waste of block space.  And of course, P2TR uses a different key scheme
altogether, which no longer has that concern of uncompressed keys.  Yeah, I
think that one's covered as well.

_What are different ways to broadcast a block to the Bitcoin network?_

Final question from Bitcoin Stack Exchange, "What are different ways to
broadcast a block to the Bitcoin network?"  This was answered again by Pieter
Wuille, and there are basically four ways how blocks are communicated on the
network.  I think the most common one today is probably the BIP130 mechanisms.
After sending a header in order to announce a new block, the peer will ask for
the block's parents or then eventually for the full block.  Before that, there
was the inv/getdata/block mechanism where instead of announcing the header, you
would tell the peer, "I have a new block in my inventory", just with the hash
that identifies the block, but that is just minuscule less data than sending the
whole data immediately.  So, that's why BIP130 proposed to send headers as the
announcement for blocks instead.

Then there's of course compact blocks.  With compact blocks, you negotiate with
a peer that they just give you a recipe for the block instead of announcing the
full block to you, and you reconstruct from your own mempool the content of the
block, based on sort of short IDs of transactions.  There's both a
high-bandwidth and a low-bandwidth mode.  The high-bandwidth mode is used, I
think, for two peers at all times where you just tell them, "Hey, as soon as you
have a block, just send it to me immediately, entirely", and the low bandwidth
block is the one where they announce the inventory.  That's the wrong term in
this context, but they announce that they have a new block; you get the recipe
if you haven't gotten it yet.  Otherwise, you probably have received it from
another peer already.  Did I forget something?  Yeah, go ahead.

**Dave Harding**: I think probably you said the most common way we're using is
BIP130.  But I think we're probably mainly using BIP130 for downloading during
IBD and when resyncing our nodes.  And probably, most peers are using BIP152 now
just in the low-bandwidth mode for most new blocks.  Some miners are still
sending unsolicited block messages, which is the fourth method here.  But yeah,
I think 152 is probably what we're using for most new blocks, but I could be
wrong about that.

**Mark Erhardt**: No, I think you're probably right about that.  I was trying to
read both the Stack Exchange and Optech at the same time, and I may have been
going from memory a little too much.  All right.  It's hard with such a long
newsletter to be prepared for every single item!  Okay, final section, Notable
code and documentation changes.  And here's our usual callout.  If you have any
questions or comments, this is a good time to find the Request Speaker Access
button.  So, unfortunately our guests have dropped off already, but I guess
that's understandable after we're already in for one and a half hours here.  So,
if you do have questions, comments on anything we've discussed in the
newsletter, you can ask for speaker access now.

_Bitcoin Core #29612_

So, we'll jump in here with the Bitcoin Core #29612.  This is a PR.  We've got a
lot of Bitcoin Core today and only one BOLT PR.  So, #29612 updates the
serialization format of the UTXO set dump.  So, there is a dumptxoutset RPC.  I
think it was even hidden until recently.  This is becoming more relevant in the
context of, for example, if you want to use the assumeUTXO PR potentially, I
guess it might also be interesting if you want to read it into a database to do
some extra research on content of the UTXO set.  I'm not entirely sure,
actually, where else the dumptxoutset RPC would be used.  However, there's a
sister RPC, which is the loadtxoutset RPC, and both of these are updated in this
PR.  The format is updated, and the new serialization format reduced the amount
of data that is getting serialized by 17.4% on block 830,000 on which it was
tested.  Dave, do you have more ideas on where dumptxoutset would be used,
except maybe as a database content?

**Dave Harding**: Just like you said, I think it's mainly being used right now
for testing.  It is kind of a nice feature to have.  When I previously needed to
get the UTXO set, I just had to modify Bitcoin Core to add some print statements
and just print it out to the log, and then extract it from the log.  It's a kind
of annoying process.  So, now we have a nice RPC for doing that.  And then, in
the context of assumeUTXO, we might see this getting used, although the ideal I
think is probably to be sharing the UTXO set over the network, checkpoints or
packages of the UTXO set at certain points in the blockchain, so people can get
those when they start up a new node.  They can just automatically download that
from a peer and will import it in a safe way that goes through and does all the
checks that assumeUTXO is already programmed to do.

**Mark Erhardt**: Yeah, given the people that were working on this and their
relation to the assumeUTXO project, I could see that this might be part of how
we construct the UTXO set that gets exchanged when you assumeUTXO.

_Bitcoin Core #27064_

All right, moving on, Bitcoin Core #27064 changed the default data directory on
Windows.  So, originally it was on C:\Users\Username\AppData\Roaming\Bitcoin,
and now it moves to C:\Users\Username\AppData\Local\Bitcoin.  So, instead of
roaming Roaming\Bitcoin, it's now Local\Bitcoin.  This is introduced in a
backwards-compatible manner.  When the old directory is already in use, it will
continue to use the old directory.  It will only use the new directory for fresh
installs.  So, if you have a guide for a Windows installation that makes use of
the data directory path somewhere in the guide, you might want to consider
updating that for the coming release.

_Bitcoin Core #29873_

Bitcoin Core #29873 is related to TRUC transactions, and it introduces a 10 kvB
data weight limit for TRUC transactions.  So, TRUC transactions obviously stands
for Topologically Restricted Until Confirmation transactions.  This is a concept
we've talked about a few times lately, formerly known as v3 transactions, which
is in implementation details.  So, TRUC transactions use v3 on the transactions
header as an opt-in request to be treated differently by nodes.  So, so far, v3
transactions were generally non-standard.  In presumably the coming release,
Bitcoin Core nodes will start treating v3 transactions as standard, but apply
topological restrictions to them until they are confirmed.  So, a TRUC
transaction can only have one parent or child.  If it is the child, it's limited
to 1,000 vbytes; if it is the parent or generally TRUC transactions now with
#29873, it will be limited to 10 kvB.

The thinking here is, if the transaction is smaller, it's harder to do a
rule-free pinning here, and generally fits well with the theme of trying to
create a type of transaction that is harder to pin, for example, to be used with
layer 2 protocols.

**Dave Harding**: Yeah.  As you said, I think we discussed this previously.
Suhas Daftuar had proposed looking at different sizes.  We were thinking about
what's the best size for this because, like you said, larger increases the cost
to overcome a pin, and smaller makes it hard to possibly include enough inputs
if you have a very fragmented wallet in order to pay for your fee bumping.  So,
after some very nice analysis by Suhas, it looks like 10 kB, kvB, whatever
you're calling this, is the right number.  So, I'm happy to see this.

**Mark Erhardt**: Yeah, my understanding is that originally a higher limit was
proposed and then after talking to a bunch of people that are interested in
using TRUC transactions and doing some calculations on how big, for example,
batched payment channel closes would be, people agreed that 10,000 is probably
plenty, even if you have to add some of your own inputs.  As a reminder, inputs
are, for example, with P2TR 57.5 kvB, so you're still in the range of, I think,
14 inputs.  No, even more, more like 140.  Okay, I'm embarrassing myself.  But
anyway, plenty amount of inputs still possible.

_Bitcoin Core #30062_

All right, second last Bitcoin Core PR.  Oh, by the way, we went over 30,000
issues in PRs in Bitcoin Core.  So, this is #30062, and this adds two new fields
to the getrawaddrman RPC.  These two new fields are mapped_as and
source_mapped_as.  So, this ties into work on ASMap.  ASMaps are basically a
routing information lookup piece that got added to Bitcoin Core a while back.
The idea here is, in order to make Bitcoin Core more resilient against sybil and
eclipse attacks, we want to not only know IP addresses of our peers, but which
ISPs may be serving these IP addresses.  And the idea is that if someone is
trying to flood our peers or push out all our organic peers in order to eclipse
us, it will be harder for them to purchase nodes or start bringing online nodes
in a number of different autonomous systems.  And therefore, we treat IP
addresses as preferable to be kept, if they're from different IP regions in the
internet.

So, adding these two new fields to getrawaddrman will help people assess
information about the regions in the internet nodes are from.  And this is, for
example, useful in the context of some monitoring software that looks at these
pieces of data.  Dave, I'm running out of steam a little bit here.  Do you have
more on this?

**Dave Harding**: So, one thing I would add is that these two new fields are
only going to appear if you actually have an ASMap file downloaded.  So, that's
an additional file that you need that's not shipped with Bitcoin Core currently,
but there is a hope and a plan to have that shipped by default with Bitcoin Core
in a future release.  Right now, developers are working on trying to make it a
file that can be reproducibly built by multiple developers right now.  It's a
little bit challenging, but we have a process for that, and so this information
will be available if you have an ASMap file.  And I think it's mainly just
debugging, or if you're curious for information at this point.  But yeah, it'll
allow you to see that the ASMap feature is working.  In the future, you'll be
able to see that you have peers that are from a wide variety of different
autonomous service providers, and not just all from various IPs in the Amazon
Elastic Compute Network.

So, this is this is a good thing.  It's a nice, easy way to improve Bitcoin's
resistance to certain types of attacks that have never actually been performed,
but it's one of those things that we have to theoretically be very concerned
about, because an eclipse attack can be used to feed your node bad information,
and it can cause you to lose money in a variety of ways, especially with some of
these newer contract protocols.  So, this is great.

_Bitcoin Core #26606_

**Mark Erhardt**: Yeah, thanks for filling in the blanks here.  All right, we're
to our last Bitcoin Core PR that we're covering this week.  This is Bitcoin Core
#26606.  As you can sense from this low number, already this has been in the
works for a long time.  This introduces the BerkeleyRODatabase, which is an
implementation of Berkeley Database that is read-only.  So, Berkeley DB (BDB)
has been around for a long, long, long time.  It has been used historically a
lot by open-source projects, and then eventually was bought by Oracle.  And I
guess there were some breaking changes that made us stuck on shipping BDB 4.8.
And I think the newest version that actually is compatible with Bitcoin Core, or
I should say rather with Bitcoin Core's legacy wallets, was BDB 5.3.  So, 4.8
came out in September 2011, which is a little older than all of us liked.  So,
Bitcoin Core wallet has been moving towards a new database.  It uses SQLite for
descriptor-based wallets, and obviously we never want to get rid of being able
to read legacy wallets, so the effort was made to re-implement the reading of
BDBs in order to have long-term support for being able to convert legacy wallets
to modern wallets that use SQLite.

So, this is BerkeleyRODatabase, RO obviously stands for Read Only, and it's been
in the works for, I don't know, years.  It got merged into master branch
recently.  There is a bunch of, well, there's at least one fuzz target for it to
make sure that we really covered all the edge cases, and it will make it easier
to migrate to descriptor wallets in the future, even when we remove BDB
completely from the Bitcoin Core dependencies.

**Dave Harding**: I will be very happy to see BDB go.  It's one of the most
cumbersome steps in setting up a Bitcoin developer environment.  You have to
download it and build it yourself locally.  There are some scripts to do that
for you, but I always do it myself and hate myself for it and it's just this
very old piece of technology that, like Murch said, we have to continue to
support for legacy wallets, but this will make it so much easier.  We'll just
have this little bit of code, and I think this was mainly done by Ava Chow.
This is a very simple, small implementation of it for the read-only aspect,
because we were able to ignore a bunch of features that BDB provides but that
Bitcoin Core wasn't using.  So, it's just a win from every aspect, being able to
get rid of that old code that just wasn't working for us and was requiring
everybody to build wonky stuff.

_BOLTs #1092_

**Mark Erhardt**: Yeah, all right, we're down to our last Notable code and
documentation change.  We're talking about BOLTs #1092.  And so, this PR to the
Lightning spec cleans up the spec to remove some unused and no longer supported
features, which is initial_routing_sync, option_anchor_outputs, and it also
assumes that in all nodes today, var_onion_optin for variable-sized onion
messages, and option_data_loss_protect for nodes to send information about their
latest channel state when they reconnect, and finally option_static_remotekey
are always present.  Honestly, Dave, I don't know much about this one.  Do you
have me covered here?

**Dave Harding**: Yeah.  We talked about this in a lot more detail back when it
was proposed in Newsletter #259.  So, initial_routing_sync was a weird thing.
Option_anchor_outputs was the original implementation of anchor_outputs, which
all nodes offer as a feature today.  However, the initial implementation had a
security bug, which we covered in the previous newsletter.  And so, everybody
today is using the v2 version of that protocol, so they're dropping support for
the initial version of the protocol, which makes the documentation a lot
simpler, because it was two very similar things but that were slightly
different, that both had to be covered in the BOLT documentation.  So, that's
been dropped.

The variable-sized onions, the original protocol had fixed-size onions limiting
you to a maximum of 20 hops, and also making it hard to add auxiliary data to
each hop.  They switched a long time ago to variable-sized onions that allow
each hop to use as much data as it needs, up to a fixed maximum for all the
hops.  So now, you can have more than 20 hops in theory, or you could have fewer
than that and you can have each hop using some extra data, so they can
communicate some extra information from the sender of the payment to each of the
hops.  This can be used for things like trampoline payments and for a whole
bunch of other stuff.  And the option_data_loss_protect and the
option_static_remotekey are just nice features for safety and security.  And I
guess that would be it.

If you want more detail about this, we do go in quite a bit of detail in
Newsletter #259, which is linked from this bullet point, so just go ahead and
click that.

**Mark Erhardt**: Thank you so much, Dave.  All right, I do not see any requests
for speaker access, so we're at the end of our very long newsletter.  Thank you
all for sticking with us.  Thank you so much to our four guests, Novo, Pierre,
Alex and who am I missing?

**Dave Harding**: Setor.

**Mark Erhardt**: Yes, Setor.  So, thank you for joining us and thank you a lot,
Dave, for writing the newsletter and helping talk about it today.  We will hear
you next week, hope you enjoyed it.

{% include references.md %}
