---
title: 'Bitcoin Optech Newsletter #251 Recap Podcast'
permalink: /en/podcast/2023/05/18/
reference: /en/newsletters/2023/05/17/
name: 2023-05-18-recap
slug: 2023-05-18-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Gloria Zhao, Carla
Kirk-Cohen, Severin Bühler, and Dan Gould to discuss [Newsletter #251]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/71358196/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-4-31%2F039c7748-fdb4-7174-2202-b7dc63ecb928.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #251 Recap on
Twitter Spaces.  It's Thursday, May 18, and we have a bunch of interesting
guests to represent various news, and we have a special segment also we're
starting this week.  Maybe we can just go through introductions.  Mike Schmidt,
contributor at Optech, and Executive Director at Brink where we fund Bitcoin
open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work on Bitcoin-y things at Chaincode Labs.

**Mike Schmidt**: Gloria?

**Gloria Zhao**: Hi, I'm Gloria, I work on Bitcoin Core, mainly mempool and P2P.
I also work on Bitcoin Core PR Review Club, dedicated to help people learn about
the codebase, and I'm funded by Brink.

**Mike Schmidt**: Carla?

**Carla Kirk-Cohen**: Hi everyone, I'm Carla, I work on Lightning-y things at
Chaincode Labs.

**Mike Schmidt**: You stole Murch's "Bitcoin-y things"!  Sev?

**Severin Bühler**: Yeah, hi, I'm Severin, I work at Synonym on Blocktank, and
also I run LnRouter.

**Mike Schmidt**: Uh-oh, Murch is telling me he can't hear Gloria or Sev.

**Dan Gould**: I'm back.

**Mike Schmidt**: Dan, you're back?

**Dan Gould**: Yeah, I'm Dan Gould, I work on Bitcoin privacy.  I'm focused on
payjoin and the basic interactive transactions.  I like to include dual funding
in that, so this conversation is going to be interesting.

**Mike Schmidt**: Well, we got through intros.  We'll take the newsletter.  If
you're following along at home, I'll post some tweets as well; if you're in the
Spaces, this is Newsletter #251.  We're just going to go through in order.  We
have quite a few news items this week, and we'll just take those sequentially.

_Testing HTLC endorsement_

That first item that we covered in the newsletter is testing HTLC endorsement.
And, Carla, I know you and Clara have been working on some research that we've
had you on to talk about, about potential reputation mechanisms and channel
jamming mitigations.  Do you want to maybe summarize the research you've done,
and then we can get into the proposed specification that you have up now?

**Carla Kirk-Cohen**: Sure, thanks Mike.  So, this work is based off some
research that Clara and Sergi from Chaincode Labs worked on a while ago, and I
know that you've spoken about it here.  But to summarize to folks that may be
new here, the claim that we are making is that to properly address channel
jamming in the LN, we need a two-pronged solution.  The first is upfront fees to
compensate nodes for what we call fast jamming, so the idea of just being able
to stream failed payments through a node incredibly quickly; and then to
complement that, we need a kind of reputation scheme to mitigate slow jamming.

The reason that we claim that we need both of these things is because if we just
have a reputation scheme, there is always going to be some type of threshold, no
matter how good a reputation scoring is, that an attacker can hit just below.
So, if you need some success threshold or some resolution time, an attacker will
always be able to adjust their payment behavior to fall just underneath that
reputation scheme.  And then in the case of upfront fees, we have the tension
between something being expensive enough to deter an attacker, but not too
expensive for an average user.  So, in the case of multiple repeated
transactions, we don't think that any kind of fee scheme would be able to
address that kind of long-hold case.  So we think that we need these two
solutions.

We've been working on the upfront fees thing, which is still in the works, and
this piece of the puzzle is the reputation scheme, which has two components.
The first is what we call Hash Time Locked Contract (HTLC) endorsement, which is
a very easy concept.  It's just when you pass an HTLC on to the next peer, you
say, "Hey, I endorse this HTLC", meaning, "I think it's going to behave well",
or, "I don't endorse this HTLC, I'm not sure how it's going to behave".  And the
second component is a reputation system, which is where you as a node, when you
receive that HTLC and the peer that sends it to you says, "Hey, I endorse it",
you take a look at that peer and say, "Well, this peer endorses this thing, but
do I think this peer has been behaving well?"  That reputation scheme helps you
decide whether you pass it on as endorsed or unendorsed, so that you also have
some feedback into this scheme.

The idea of using both of these things is that we can divide the resources that
we have in the network for payments that we do endorse and we do think will
behave well, and payments that we don't know anything about.  So, when the
network comes under attack, payments that we have from peers that we have a good
history with will be able to use some portion of liquidity and slots so they'll
remain unjammed, and the payments that we're not sure about, potentially the
payments that are attacking us, go into a sort of Wild West bucket of liquidity
and slots, where maybe they'll jam us, maybe they won't, but at least we've
preserved some functionality for the known actors in the network.

**Mike Schmidt**: Carla, is this HTLC endorsement just a binary thing, I do or I
do not endorse it; it's not some sort of a scale, is it?

**Carla Kirk-Cohen**: Yeah, it's just, for what we've proposed, a one or a zero.
I think in LN, along a route, it gets very tricky when you have a value that's
decreasing per hop, because it makes it very easy to see where you are in the
route based on how much that value's decreased.  So for now, it's a one or a
zero in our proposal, but we have also been discussing this idea with a few
other folks.  And there is some interest in a continuous value as well.

**Mike Schmidt**: And the mechanism or the algorithm by which your node would
determine to endorse or not is based on some sort of a reputation score
calculated locally at that node.  Are you, as part of this proposal,
recommending a particular algorithm or just the ability to communicate endorsed
or not for these HTLCs?

**Carla Kirk-Cohen**: So, we are recommending a sort of reputation scoring
algorithm; we're still working on it, it's quite an early stage proposal.  But
the idea we want to capture is that a node needs to have paid you in routing
fees the cost that they can inflict upon you, if they then choose to use their
good reputation with you to jam you.  So, the way that we express this is by
looking at the HTLCs that node has forwarded us and the fees that they paid and
the amount of time that they took to resolve, to kind of make what we call an
effective fee for the HTLC.  So, if it went through quickly and it paid us fees,
we count the fees that you paid us towards this kind of reputation score.  But
if it went through very slowly and maybe you held up our liquidity for a long
period of time, we will penalize you for the long hold.  So an HTLC that
succeeds but maybe takes an hour to succeed would actually still negatively
affect your reputation, because this is sort of unusual, atypical, potentially
malicious behavior.

So, we calculate the effective fees for each HTLC, that's what we call them,
effective fees, because they're kind of adjusted by resolution time, for each
HTLC that a node has forwarded us.  And then we do that over a longer period of
time, and we compare that to our node's routing revenue, just regular fees that
we forwarded in a period of time which is much shorter, with the idea being that
to build good reputation with me, over a long period of time you need to send me
consistently good HTLCs that are paying me fees, so that when I give you good
reputation, if you start to abuse it, you've kind of made up for it, because
you've paid me the routing fees that I was earning anyway.

**Mike Schmidt**: It sounds like one potential way this could be activated or
turned on, if you will, is behind an experimental flag.  It would seem then, if
that's the case, you would be able to run this on some subset of the network and
see how things behave and then adjust the algorithm or the mechanism
accordingly; is that the plan?

**Carla Kirk-Cohen**: Yeah, that's sort of the next step that we're looking at.
I think that we want to look at two different things.  The first is that we've
made a recommendation that endorsed and unendorsed HTLCs, we split channel
liquidity 50:50.  And we want to fact-check our belief that in the steady state
of the network, a node not having good reputation will not affect its ability to
make payments.  So, one piece of information we want to gather is information
about how saturated channels are in regular operation, because if they're 90%
saturated all the time, then nodes being not endorsed is actually a big deal for
regular operation.

Then, the other thing that we'd like to do is just get some nodes who are
mindful about the way they run their nodes, to actually dry-run this reputation
scoring and see what it looks like, just to make sure that our instincts are
correct.  And we can do this in a fairly nice way because LN is pretty flexible.
We have a full range of experimental type-length-values (TLVs), so extensions we
can add to any message, and any value above 65,000 is just totally experimental,
Wild West, do what you like.

So, what we'd like to do is implement this reputation scoring as kind of an
application that you'd run next to your LN node, possibly in Circuit Breaker,
which I think is a project you've spoken about in these Spaces before; and then
also start to experimentally attach this endorsement field in the experimental
range so that we don't have to add it to the spec, there's no harm caused by it,
and start to observe what this would look like.

I think one thing that is difficult about trying to get this data is that these
endorsement fields do change.  So they're parsed along the route and they're
either a one or a zero.  And if someone isn't running this data-gathering thing,
we're just going to have to record that as a zero; if the chain is broken, then
we have no data for that.  So it may be a little bit difficult to gather
information on endorsement, but I think we can still learn a lot about
reputation by just doing some data-gathering in the wild.

**Mike Schmidt**: And I think that the data-gathering could help convince some
participants of how effective this would actually be.  I know Christian Decker
maybe had the question about exactly how many forwarded payments would actually
receive a boost or not from the scheme.  Do you have comments on that question?

**Carla Kirk-Cohen**: Yeah, absolutely.  So I think, I'll not speak for him, but
I think Christian's question is how many nodes will feasibly be able to get good
reputation in this scheme, because it is a scheme that relies on consistently
forwarding payments to your peers to build reputation, and if you go quiet and
you have no activity for a while, you won't have good reputation.  And then if
the network does come under attack, you're jostling with the attacker to get
those scarce slots in the lower Wild West bucket.

So this is something we definitely want to figure out as we experiment with this
reputation scoring, because Clara and I suspect that it won't be a big deal if
nodes do not have high reputation, because if you're a very inactive node on the
network and you're unable to gain high reputation, you're probably not using the
network that much, right?  So in the normal state, we hope that you're
completely unaffected because LN channels aren't saturated; and in the attack
state, maybe it's a bit more difficult for you to make payments in the short
term, but if you're someone who was making one or two payments a month anyway,
this isn't critical.

We can't have a perfect solution for this, but what we can do is gradually
degrade so that the really active nodes in the network are still able to make
payments, and maybe temporarily during attack, the edges suffer a little bit, or
in more competition with an attacker, and then as the reputation mechanism
updates and the attacker is stifled by this lack of endorsement, then the
network returns to regular operation.  But totally agree with Christian's
criticism and lots of open questions that we hope to address with a bit of data.

**Mike Schmidt**: Murch, do you have any follow-up questions?

**Mark Erhardt**: None from me, thanks.

**Mike Schmidt**: Carla, any call to action or anything to wrap up with on this
topic that you'd like folks to know?

**Carla Kirk-Cohen**: Yeah, I guess the call to action is that if you're running
a LN Node and you're interested in contributing, we're going to be putting out,
in the next month or two, an implementation of this scheme.  And if you're
interested in running it on your node and volunteering some anonymized data to
us to help push this forward, that would be great.  Reach out to myself or
Clara.

**Mike Schmidt**: Excellent.  Carla, you're welcome to stay, in fact you may
have some opinions on this zero-conf dual-funding discussion, but if you're busy
or need to drop, feel free to drop.  Thank you for opining on this first item.

**Mark Erhardt**: Thanks, Mike.  Oh, hang on.

**Mike Schmidt**: Dan, you have a question?

**Dan Gould**: Yeah, I'm curious how much can be learned from the banking system
here.  It sounds like if you're extending creditworthiness, like you're sending
credit to someone to forward their payment, it's a cost to you potentially.
Banks have been doing risk assessment for as long as they've been around.  How
much has been learned from them, or could be?

**Carla Kirk-Cohen**: I think what's very different in LN is that when you
receive an HTLC from a node, you don't know that it's from them; whereas banks
have very transparent insight into who is the origin of a transaction.  So, we
have looked at some other networks that have this type of thing, but I think LN
is really unique in that it's onion-routed, so the ability to sabotage one
player transitively is something that we need to account for, and we also have
money built in where other systems don't.  So, I think that we can learn a
little bit from other types of systems like this, but when you go to the bank,
they ask you for your ID, your proof of residence and all of those things, and
that's primarily how they "keep things safe".  So, LN is very different in that
regard.

**Mark Erhardt**: I think that it's also a different resource that is being
negotiated here.  I wouldn't liken an HTLC as a credit, it's more of an
opportunity cost because you're locking up funds and resources that are only
available for some time versus with a credit, of course, you might lose money.
And so, I think it's maybe just too different also in the regard of what we're
negotiating.

_Request for feedback on proposed specifications for LSPs_

**Mike Schmidt**: Next item from the newsletter is request for feedback on
proposed specifications for Lightning Service Providers (LSPs), and I was not
aware that there was a group working on this, but apparently there's an LSPSpec
group and Severin is here to discuss his post about two potential specifications
for interoperability for LSPs and their clients.  So, Sev, do you want to take
it from here?

**Severin Bühler**: Yeah, sure, of course.  I hope everybody can hear me.  So,
we at the LSPSpec group, we are working on a specification that should enable
interoperability between wallets and LSPs.  Basically, the goal is to make LSPs
plug and play, just switch LSPs whenever you want.  Right now, how current
wallets implement it, it's basically custom code that talks to an LSP and you
can't switch an LSP at all; it would take way too much effort from a development
point of view.  And for that, we have created, or we are working on, multiple
specifications in the LSPSpec group.

We have three specifications that are up for review at the moment.  LSPS0 is
basically the base protocol, how communication should work between wallet and
LSP.  It's a JSON-RPC protocol which could be also interesting for other
projects potentially in the future.  Just to give a hint, if somebody wants to
develop something on LN, this is a very cool RPC that lets you talk to your
direct peer, if somebody wants to create a project there.

Then we have LSPS1.  LSPS1 is basically an API where the wallet can purchase a
channel from the LSP directly.  It's basically you create a P2P connection to
the LSP, like a normal LN peer connection like is done day by day, and then you
ask the LSP for a certain size channel, the LSP tells you what's the price for
this channel, and then you pay either via LN or via onchain, and the LSP will
open this specific channel.

Then on the other side, we have LSPS2, which is Just-In-Time (JIT) Channels.
JIT Channels is a technique that when you don't have money on your wallet,
you're basically a new user in the LN, and you want to receive payments, then
you kind of have the problem you need a channel, but also you need to pay the
channel with some funds.  But you as a new user, you don't have any bitcoin, so
this is quite hard.  So what JIT Channels do is, you create an invoice, and as
soon as a payment arrives to the LSP, the LSP will open a zero-conf channel to
the wallet, to the new user, and after it opened the channel it will forward the
payment and it will deduct the fee directly from this first payment.  This is
JIT Channels, very useful for onboarding new users.

Then we have other specifications that are in the pipeline that we are still
working on, and they're not really ready for a final review.  I mean, everybody
is welcome to join our calls, but these are things that we are working on.  This
last one is, we're working on a spec for LSPs that if there is an incoming
payment, the LSP can potentially wake up mobile wallets.  So if you have like a
mobile app, then to receive a payment, you actually need to have the app
running; the LN node needs to be online to receive a payment.  And there, the
last one, we're working on a way for LSPs to actually call the app provider that
then actually can wake up the app if it sees there is an incoming payment.

That is basically it.  I mean, the most important thing is call for review.
LSPS1 and LSPS2 are in a state where everybody should have a look at it.  We
think they're basically complete, they're very mature, but now we're calling
everybody outside of the LSPSpec group that they should have a look.

**Mike Schmidt**: So there's an LSPSpec group and you guys have meetings, it
looks like every other week, to discuss the spec and we covered LSPS1 and LSPS2
in the newsletter this week, but there is also LSPS0 which sort of defines the
mechanism of how you communicate.  And then it sounds like you have two other
spec recommendations that are in the pipe.  So I guess the call to action to
folks would be, if you're involved with LSP to join the Telegram group or join
those calls, and also review these LSPS1 and LSPS2 specs?

**Severin Bühler**: Yes, exactly.  We have calls every two weeks on a Wednesday.
I will tweet out the Telegram group and how to get into the calls after this
Twitter Spaces.  Yeah, call for review are these two specs that are very mature
already.  And yeah, please join us if you're interested.

**Mike Schmidt**: Murch, any follow up questions?  All right.  Thanks for
joining us, Severin.  You're welcome to stay on for the remainder of the
discussion, or you can drop if you have other things you need to work on.

**Severin Bühler**: Thanks for having me.

**Mike Schmidt**: Yeah, absolutely.

_Challenges with zero-conf channels when dual funding_

Next item from the newsletter is challenges with zero-conf channels when dual
funding.  I can kind of give a brief overview of these components, but I'm
curious if Carla also has some insight into here with her LN expertise.  But
essentially, t-bast posted to the Lightning-Dev mailing list some of the
challenges about using zero-conf channels in conjunction with dual funding, the
dual-funding protocol, and the mailing list post got into some specific examples
and considerations; but one of those being doing this not just one time, but
having multiple of these at the same time, it seems like there could be some
issues.

As a reminder to listeners, zero-conf channels are channels that can be used
even before that opening channel transaction is confirmed.  This is combining
then with dual-funded channels, which are channels that are created using
forthcoming dual-funding protocol, which includes channels which have an open
transaction that has inputs from multiple parties.  So, each side is putting in
some funds into the channel, which is nice, but there's some potential issues
there.  Carla, what's your level of familiarity with these considerations?

**Carla Kirk-Cohen**: Unfortunately, not very high.  I think that the complexity
just comes in with the fact that when you open a zero-conf channel which isn't
dual funded, you can be sure that it's not going to be double-spent away.  And
then, when you start your dual funding, you run into all sorts of nasty pinning
attacks, which seem to be everywhere in LN.  And I think the real concern is the
idea that someone could open a dual-funded zero-conf channel to you and then
start to forward payments through your node, through one of your legitimate
channels, and then double-spend away the zero-conf channel so that you've been
drained of funds that won't ever arrive on the other end.

But yeah, as the newsletter says, I don't think there's really a satisfactory
answer here.  Doing zero-conf things is dangerous and it's a difficult problem
to solve.

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: Yeah, I was reading that mailing list thread earlier today and
my impression is that zero-conf channels essentially work by the LN service
operator, or the opener of the channel, assuming that since they control the
original funds, they know that they won't double-spend themselves and therefore,
if they extend the ability to spend the LN channel balance before the channel is
confirmed, they know it will eventually go through because they can make sure
that it will confirm, and thus they can get back their funds.

But once you get the dual fund in there, (a) you get the UTXOs of the other
partner so that they can double-spend, and (b) you also no longer control the
whole balance, so some of the funds would have ended up with you.  So it just
seems fundamentally incompatible to have both zero-conf and dual funding.  And
the main idea or the main takeaway from the three or four mailing list posts was
just, if you want to do turbo channels or zero-conf channels, only open the
channel from one side; and if you want to use dual funding, well, don't use
zero-conf.

**Mike Schmidt**: And the term that t-bast used in his mailing list post was
liquidity griefing.  So when Carla was outlining that, and Murch as well, that's
the term that I saw in there that he used.  Thanks for that overview, Murch.
Anything else you think we should talk about on this topic?  All right.

_Advanced payjoin applications_

Moving on to the next item from the newsletter this week, advanced payjoin
applications.  And this was a post to the Bitcoin-Dev mailing list from Dan,
who's joined us today, about maybe using payjoin for something more than just a
simple send and receive payment.  And we noted a couple of examples of maybe
more advanced transactions that could involve payjoin, but I'll let Dan maybe
walk through what is payjoin at a high level, and then maybe some examples of
more advanced uses of payjoin, and maybe why it's important.

**Dan Gould**: Sure.  Thanks, Mike.  So, payjoin at a high level to me is an
interactive transaction involving two participants, so two people both
contribute inputs to a transaction.  The reason we want this is because all of
Bitcoin surveillance rests on the idea that inputs to a transaction come from a
single party.  So that's even in the whitepaper, Satoshi said, "Common input
ownership assumption"; this assumption is the privacy problem we need to solve.

So payjoin came to be in 2018, framed as a merchant customer protocol where a
merchant runs a server and a customer sends them a proposal to pay them, and
then that proposal can be updated with a transaction containing the merchant's
input.  So that's great, it breaks the common input ownership heuristic and it
increases privacy for everyone on the network.  There's a lot more we can do
with that and I think the main issue with that is it's not necessarily
incentivized.  You have to do all this extra interaction to get the receiver to
run a server and then the sender needs to actually send them an HTTP request and
get a response.

So, I think dual funding is one way to incentivize this kind of transaction,
where both nodes contribute inputs to a LN channel.  It's pretty easy to spot,
it doesn't really give you privacy as is right now when we're using script
multisig channels; but with taproot MuSig channels, I think you'll have the
stenographic advantages of using payjoin where people can see, or where the
transaction is ambiguous to other transactions: it's hard to see; is it a
channel open; is it one person sending money; is it two people contributing
money together?

So, another way that this mailing list post covers to increase adoption is by
either forwarding payments in a payjoin, so instead of just Alice paying Bob,
Bob can pay his vendor at the same time, because Alice proposes an initial
transaction and then Bob replaces the output to that transaction with a
substitute output forwarding that payment along.  Bob can also, if Bob were, for
example, to batch a bunch of payments forward, so if Bob received a large
deposit, he could split that deposit output into multiple forwarding outputs
that go on to pay user withdrawals, for example.  That way the exchange would
never even take an output and they would still -- because of the HTTP
authentication, because the networking uses a secure endpoint, it fixes a bunch
of authentication problems where, if Alice were to forward a payment to Carol
and want to do that, there's no way to know she would -- I should back up.

So this idea of batching transactions or forwarding transactions, Dave Harding
let me know was proposed by Greg Maxwell in 2013 as transaction cut-through, and
Greg suggested that these intermediary transactions, like the one proposed by
Alice to Bob, didn't necessarily need to be posted to the chain if they happen
instantaneously and they could communicate somehow.  So, it turns out the
payjoin protocol from 2018, that's used in BTCPay Server fixes that because you
have the secure endpoints, so Alice can know she's definitely paying Bob and his
requirements are being met, even though he's forwarding payments on to Carol.

There's one other thing that's not mentioned in the mailing list, which is that
even Alice can batch payments, not only to Bob but to further destinations.  But
it's kind of outside of the scope of payjoin, the point is that you can combine
the techniques to have massive fee savings and increase the velocity of Bitcoin,
the throughput of the network, by using this one-round communication protocol,
just very basic interaction.  It improves privacy and scalability of Bitcoin.

**Mike Schmidt**: It sounds like discoverability is important here. You're
trying to discover the intent of maybe if you're sending to somebody, where
their intended spending of those funds might be?  How do you solve the
discoverability problem there and the communication involved with that?

**Dan Gould**: So the question is, if Alice is sending to Bob and Bob wants to
send funds on to Carol, how does Alice know funds get sent on to Carol?

**Mike Schmidt**: That's right, and applying it even broader, because in order
for this to work, you need to have this matchmaking going on.  And it seems like
there needs to be some discoverability there.  But yeah, that's the general
question.

**Dan Gould**: So the beauty of using payjoin for this is payjoin's
discoverability is very simple.  Alice knows she's talking to Bob because Bob
gives her a secure endpoint, so like an HTTP server, and Alice does not need to
discover any of the identities of people that will get forwarded payments.  The
original request, so BIP78 payjoin, is a request response protocol.  So, Alice
would first send a proposed PSBT that pays Bob, and Bob would respond with an
updated version of that, including his inputs and potentially substituted
outputs.

So the discoverability happens when Bob substitutes those outputs.  All of those
payments he wants to forward are included in that proposal, and that is
authenticated using TLS in HBS.  So Alice knows that Bob's payment is getting
satisfied, even if it may contain a number of payments being forwarded to other
parties.  So, the discoverability happens kind of behind the scenes.  Bob states
his preferences without revealing necessarily the intention or the identities
related to the destination; and Alice gets a proposal with an authentication
code, or a signature she authenticates in some way that this actually comes from
Bob, and she knows, "Okay, my payment to Bob is being satisfied because the
proposal comes directly from him". What's up, Murch?

**Mark Erhardt**: Yeah, I was wondering, so if we think about an invoice scheme
where you say, "Hey, I want to be paid to this address", and then the sender
starts by building a PSBT and hands it to the recipient, but then the recipient
changes their request, wouldn't it make more sense to originally already have
the original invoice and code, like the multiple outputs that you want to be
paid to?

**Dan Gould**: It would, but I think constructing that is the difficulty.  The
idea here is you can use the BIP21 unified payment standard that's already
supported by apps like Cash App, so it's all over the place, and you can just
scan and make the proposal to one address output, even if that's going to be
replaced later, because you have the luxury of interactivity.  But yeah, if the
sender could just scan animated QR, for example, that had the proposal PSBT
containing all of the payments to forward, that would be better.

**Mark Erhardt**: The other thing that I wonder is, if the receiver basically
changes their mind on where they want to be paid, doesn't that sort of interfere
with the proof?  Like, the receiver first put out, "Hey, I want to get paid and
once you pay me to this address, I will consider the service that you consume to
be paid for", and then he later changes his mind, so now the sender doesn't have
the invoice that he can match up against with like, I don't know, showing that
they have paid.  Who are the people that are using this scheme and would want to
have shifting outputs in their transactions?

I think it would maybe make more sense to add more outputs, but to maintain the
original output so that the proof chain of like, "Here's an invoice and the
address did get paid, and I can put that in my internal accounting" or whatever,
"or in my wallet".  So, it seems to interfere with previous wallet flows.

**Dan Gould**: I'm not sure what flow exactly it would interfere with, because
the sender still gets a response from Bob at an authenticated endpoint.  It's a
requirement that the proposal PSBT, the updated PSBT, is authenticated by Bob,
so you can't use this with a relay to an unsecured endpoint.  That's what makes
relaying it a little more difficult and why we need serverless payjoin, but I'm
not sure why, if that address changes, a sender would have a problem knowing
that they paid, because they're still getting an authenticated proposal PSBT
from the receiver that they need to sign, and that proposal is authenticated
saying, "This is a good payment", and either that or the original would be
acceptable.

**Mark Erhardt**: Yeah, I must have missed that PSBT sign.  Thanks.

**Mike Schmidt**: Dan, any calls to action or parting words?  I assume that
you're looking for feedback on your mailing list post; maybe there's other
things that you should make people aware of?

**Dan Gould**: Yeah, that'd be great if you have any feedback or updates. I
guess making it known that there's an authentication component is something I
can update.  You can check out payjoin.org if you want to learn more about the
basics of payjoin, and you should ask your wallets if you want to see payjoin to
integrate it.  We're working on bindings in the GitHub repo at
github.com/payjoin/rust-payjoin, and get in contact if your project wants to
integrate payjoin.  We'll be releasing live in BitMask app tonight.  They're
going live on mainnet, so you'll be able to check that out.  Yeah, thanks for
having me, Optech.

_Summaries of Bitcoin Core developers in-person meeting_

**Mike Schmidt**: Thanks, Dan.  Next news item for this week's newsletter is
summaries of Bitcoin Core developers' in-person meeting.  And so, we had a
similar coverage in Optech about six months ago with the last Core developer
meeting, in which there was a bunch of transcriptions for the different sessions
that were held during that meeting, and this is what we're doing again now.  A
few weeks ago there was an in-person Core developer meeting, well attended, good
amount of topics.  We have write-ups here that actually link to the
btctranscripts.com website that outlined a bunch of different topics we linked
to, and then we called out two specific topics for special attention.

The first one is mempool clustering, and luckily we have Gloria on, who could
probably give a better quick summary of mempool clustering than I could.
Gloria, do you want to maybe provide a quick overview of what mempool clustering
is, and folks can read the transcript for more information?

**Gloria Zhao**: Sure, I think it stems from a lot of issues where we're
trying to improve something in mempool, or we have a huge bug in mempool, or a
huge limitation, let's say, and it just fundamentally boils down to how the
mempool is structured and there being no inherent cluster limits.  So I don't
know how much we've gone over clusters in the Spaces?

**Mike Schmidt**: Not much.

**Gloria Zhao**: Okay.  So hopefully, people are familiar with the concept
of unconfirmed parents and children.  So a parent is a transaction you spend
from, a child is a transaction that spends from you, and then you have the
concept of ancestors, which includes your parents, your parents' parents, and so
on and so forth; and descendants, which includes your children, your children's
children, and so on and so forth.  And these two concepts are hopefully somewhat
well understood and very much accounted for within our current mempool data
structure in Bitcoin Core.

However, what is often most pertinent, most relevant to a transaction when
you're, for example, selecting it for inclusion in a block template to mine it,
is much more than just its ancestor set and/or its descendant set.  So, our
mining algorithm includes just this dynamic process of selecting ancestor
subsets and then updating their descendants.  And then, what ends up being
relevant to a transaction is all of its connected transactions or its cluster.
So, that would include things like your parents' children, or your parents'
other child's parents' other child's parents' other child!  None of these things
are in your ancestor set, and I apologize if it's kind of difficult to talk
about this without a diagram.

But essentially, clusters are not really a thing in our Bitcoin Core codebase
yet, and it is getting in the way of being able to do things more intelligently.
And so, what we'd like to do is add cluster-based algorithms or accounting
mechanisms within mempool.  However, this requires a fundamental redesign of how
we track transactions, how we update our mempool in the event of a block, etc.
And so for users, hopefully this redesign doesn't change very much about how you
would think about sending a transaction.  But when we're talking about building
like a DoS-resistant RBF policy, or we're trying to better select transactions
that we might evict from the bottom of our mempool when it gets full, we'll see
much better decisions being made.  So that's kind of the abstract concept;
hopefully that helps.

**Mike Schmidt**: Yeah, that makes sense.  Murch, anything that you would add to
mempool clustering?

**Mark Erhardt**: Yeah, I don't know if some of you might remember the research
article that Clara and I put out last summer where we looked at cluster-based
block building.  One of the things that we get out of cluster mempool is that
currently when we have two parallel CPFP situations, that is one parent with two
children, that each try to CPFP the parent, then our current mempool design
would not be able to, or miners that are building a block template would not
consider that both these children could be working together to bump the parent.

With cluster mempool, because we're now not looking at each transaction in the
context of its ancestry only, we would be able to discover such situations and
it would actually improve a little bit how we build block templates, potentially
collect a little more fees for miners, and make transaction situations in which,
for example, multiple children are bumping the same parent, go through faster as
it would group the transactions together and have them compete for block
inclusion at that group level, instead of as an ancestor set.

So, yeah, I think this is one of the most exciting things that is going on right
now in Bitcoin Core development because it's going to make a bunch of things
much easier downstream, including work on RBF, including block-building faster,
including eviction being less broken.  So, yeah, pretty cool thing.

**Gloria Zhao**: Yeah.  I think that I'm really excited about this because
the eviction being broken has kind of being a bit of a blocker for package
relay, for example.  So, maybe a concrete example of something that's really
broken is, we will select transactions for block templates based on ancestor fee
rate, it's not just strictly its ancestor fee rate, but from there, and we will
evict based on descendant fee rate.  This means that there isn't this
linearization ordering of like if we were to build a block template, this
transaction would be number one to be selected, this transaction would be number
two, etc, and then we'd have an ordering of how good each transaction is, like a
scoring system, for example.  So this would be amazing to have.

We do have a ranking, right; we are able to go through everything in our mempool
and select which would be selected first, which one we decide is kind of the
best transaction to include in block templates.  However, the way that we evict
transaction is not to reverse that ordering and then evict the worst thing to be
selected for block template.  So, we get into these situations where what you
would evict happens to be something that you would also really want to select
for your block template; or, you would have something that would never make your
block template, for example it's not part of an ancestor package that can be one
sat/vbyte.  But you also wouldn't evict it, because its descendant theory looks
really good.

So, you can imagine this kind of DoS, where you're able to add things, for
example via package submission, that would never get mined but would also not
get evicted.  And if you were to trim to size, if your mempool were to get full,
you would evict other things that are actually better to mine than this DoS-y
package.  And so this is kind of really, really bad, and this is the main reason
why I'm very excited about cluster mempool.  Also, I see that Greg is here, if
Greg wants to talk about cluster mempool?

**Mike Schmidt**: I sent him a speaker invite if that's the case.

**Gloria Zhao**: Okay.

**Mark Erhardt**: So, I want to highlight another point about this, which is if
we select by ancestor sets, each package includes the transaction itself and all
of its ancestors.  But for each of the ancestors, we have yet another ancestor
package.  So we're inherently tracking transactions multiple times if they
appear in some ancestor structure.  With the cluster mempool, each transaction
is only part of one chunk of a cluster.  And once we select, we select by
chunks.

So transactions no longer group in multiple different packages, which means
currently when we pick an ancestor set into a block, we have to update all the
other ancestor packages that are affected because transactions are taken out of
it.  When we select chunks from clusters, the whole chunk goes and we can just
put the next chunk from the same cluster into our heap to sort to the top.

So really, what we do is we get rid of a lot of doing the same work over and
over as we select the block template.  So our expectation is that the block
template building will be significantly faster and more incentive compatible.

**Mike Schmidt**: Anything else to add, Gloria?

**Gloria Zhao**: No.  There is an issue open on the Bitcoin Core repo, I can't
remember which number it is, but that's available for anyone who's interested in
learning more.  It's 27677.

**Mike Schmidt**: Yeah, I've linked to that issue, as well as a copy of the
slides that were part of the presentation, in the newsletter as well.  So if
you're curious, jump into that.  And also, jump into any of these other topics
that were transcribed from the meeting, if you're curious.

The other one that we highlighted from the Core developer meetup was project
meta discussion.  And like I mentioned, I think if you're curious, you should
jump into the details of all these transcripts.  But the thing that we noted
from this discussion was a quote, "More project-focused approach for the next
major release after version 25".  Maybe, Gloria, you can comment on that and
maybe elaborate a bit?

**Gloria Zhao**: Yeah, sure. So, Bitcoin Core is extremely short
staffed.  A lot of long-term contributors have been leaving.  We still have
almost 300 pull requests open on the repo and a lot of projects that we deem
really important and/or critical to the longevity of this protocol being able to
stand up and scale over the years.  And so, I think this is probably known that
we've been struggling to make progress on these gigantic projects that require
really in-depth review.

So, as part of this discussion I think, it seemed like there was a sentiment in
the room of, "Why don't we actually try to prioritize these projects?"  And this
has been something nobody, or at least maintainers, didn't really want to do
because of the criticism of people trying to control Bitcoin, which is
ridiculous.  But I think after getting a lot of criticism and hate online, you
kind of just say, "Okay, I'm just going to merge whatever seems ready".  But it
seems like everyone, I think everyone, is really excited and ready to try this
out.

So we did a rough poll of what people think their top three projects they want
to spend review time to be, and then there were three or four ones that seemed
to have really strong support.  So now, we're going to try doing essentially a
weekly stand-up in our IRC meeting.  There are big project tracking issues that
are open on the repo and in our "high priority for review" board to help give
people a sense of (a) what's the thing to review to get this moving, and (b)
what is a reasonable milestone that we can fit into a release cycle to try to
get momentum going.  And I think so far it's been really positive.  Everyone's
motivated and it looks like we will hopefully get a good chunk of BIP324, the
encrypted P2P transport, maybe some package relay, and maybe some kernel done
for 26.

So, yeah, that's what project-based release, I don't know what the word was, the
terms were, but yeah, we're going to try to push for project-specific goals, at
least for this upcoming release, and hopefully it works out.

**Mike Schmidt**: Murch, is there anything that you'd add to that?  I got the
thumbs up.  All right, yeah, Gloria, great insight.  It seems like a fairly
straightforward approach is to take projects that are down the line that seem to
be important and take them across the finish line, and a lot of that is review.
Obviously, there's development to be done as well, but it's just sort of saying,
"Hey, we think this is important, and we're going to spend our time on this for
the next few months".  It seems like a very reasonable approach.

_Waiting for confirmation #1: why do we have a mempool?_

Next section of the newsletter is a new, limited weekly series that we're doing
about transaction relay, mempool inclusion, and mining transaction selection, in
addition to Bitcoin Core policy.  And the first of these entries is why do we
have a mempool?  So, Gloria, not only why do we have a mempool, but why is it
important to highlight these types of discussions in the newsletter for the
coming few weeks?

**Gloria Zhao**: Yeah, this is part of a ten-week series called Getting
Transactions Confirmed.  Given current events, this seemed pretty relevant.
Bitcoin Core at least got a PR about removing standardness rules and various
requests about adding mempool policy to prevent things like inscriptions or
stamps, or we also got a request to create patches for miners to run package
relay, for example.  We also get a lot of questions like, "Why did my
transaction fall out of the mempool?" and, "My wallet now thinks I lost this
money".  We got, "Should I just increase my max mempool, given how full it is
right now; does that help the network?"  "Isn't standardness just devs imposing
censorship?"  "Why does my fee estimator suck so much?" all these kinds of
questions, and the hope is to answer them in the next ten weeks.

For me, at least, it illuminated that there's not a really good understanding of
how transaction relay works and what standardness is.  But also, there's not a
lot of accessible documentation and educational material about it either.  So,
the hope is not really to be condescending and be like, "Hey, you guys didn't
know this, but we devs have decided that we need to have these extra rules".
The hope is to eliminate that kind of thinking, and also encourage people to
think of like, since there's so many applications building on top of Bitcoin
Core and we're transitioning into this multilayer ecosystem, that transaction
relay and mempool is really an interface that we need to collaborate on.

The hope is that after this, people will, especially devs, have a better
understanding of the things that are there that are really important, and also
encourage people to open PRs and ask like, "Hey, this standardness rule got in
the way of my use case, which is actually a really good use case.  How can we
change that in a collaborative way?" because I think I also don't want people to
think that -- so, one person commented like, "Bitcoin Core moves really slowly,
so there's no way we're going to be able to change standardness in order to
accommodate this use case.  So can we just make this patch for a miner to run so
we can submit directly to miners?"  That was really heart-breaking for me, and I
want us to have a good standardness rule that works for the network.

So, that brings me to this first one which is, I've tried to say the network
functions the best when everyone has the same thing in their mempools, and that
sounds very centralizing to some people.  But I wanted to explain, okay, why do
we have a mempool; and what makes our mempool useful?  So that's our first
section.  The first part, I talk a little bit about if you're an individual
node, what are the benefits of having a mempool, which is just a cache of
confirmed transactions.  And the main use is you get to distribute the load of
downloading and validating blocks over the course of while your node is running,
instead of in bursts every ten minutes or so.  So, since you have a mempool,
you'll hear about transactions as they come in.

Oh, Murch just said I said, "Cache of confirmed transactions".  Sorry, "Cache of
unconfirmed transactions".  And there's a bunch of other data structures as
well, such as your UTXO cache, your signature and script validation caches, and
these are all things that you populate when you hear about transactions on the
network before they get confirmed.  And this means that when a block is found,
everybody can essentially use a compact block relay -- read BIP152 if you want
more details --in which you really just need to forward your block header and
some shortids, which is extremely, extremely small compared to the size of the
full block.  And then you're like, "All right, I already have all these
transactions in my mempool, cool; all the UTXOs are already loaded in my cache;
I already did the computationally expensive work to validate the signatures and
the scripts; cool", and I can pass on the block.

So from an individual node standpoint, this is really cool.  You don't have
these huge CPU and network spikes every ten minutes.  I think there's this
anecdote, maybe from a talk by Greg Maxwell a long time ago, where he talked
about they would be on video chats and then every ten minutes or so, everybody's
video quality would go down because a block was just found, and their laptop or
their computer is downloading and validating the block.  So with compact block
relay, you, your computer does not go through this process every ten minutes,
instead just slowly does it over time.  And then at a network wide level, given
the fact that everyone can download and validate blocks so quickly, the network
wide propagation speed is way faster.  And this means that there's fewer stale
blocks, because as soon as someone's found a block, there's less -- if two
blocks are found at around the same time, for example, the race is resolved much
sooner.  This is kind of a theme in mempool and transaction relay.  It's like
you find something that makes sense for an individual node to do, and then
there's this kind of behavior that is networkwide that is also really
beneficial.  So that's kind of the first part of, why do we have a mempool?

The second part is, why not just submit directly to miners?  And I wanted to get
this out as soon as possible in the first section post of the series, because
like I just said, everybody has their own mempool, hopefully everybody has the
same thing, but that's not always true.  And there's attacks where you can send
different versions of transactions that conflict with each other to mempools all
over the network, and this is really frustrating.  I know this is really
frustrating for businesses and users that are trying to use this to send
payments.  And I get this question all the time, which is like, why don't we
just submit things to miners?

So, the first argument, sorry, I just like ranting!  But the first argument is
kind of tacking on to compact block relay that I just talked about.  Whenever
you send things directly to miners and only to miners, there is a 100% chance
that every hop on the network cannot just use vanilla, first compact block
reconstruction and understand that they have all the transactions already and
then move on.  Every single hop on the network has to do an extra round trip to
relay that transaction.  And so you kind of lose the benefit of compact block
relay at any time only a miner knows about a transaction.  And this is
especially the case if, for example, you're going to submit non-standard
transactions to miners.  So that's a very unfortunate consequence of doing so.

But the main reason why, for example, we don't have a Bitcoin that's designed
such that you have these kinds of centralized submission points is, the whole
point here, or one of the biggest values of Bitcoin, is to create this kind of
censorship-resistant/private way of paying, and that is enabled by the P2P
transaction relay network.  So for example, if there were five miners or ten
known miners that everybody submitted their transactions to, it would be way
easier to, for example, have all of these miners log the IP address of the
person who submitted each transaction.  And then to take it a step further, and
for say a government to say, "Okay, ten miners", they only have to go to ten
entities, "you have to be compliant with these rules.  You cannot accept
transactions from IP addresses that come from this country.  We also ban this
list of addresses, so if you see a transaction sending money to this address,
you have to drop it on the floor".  And this undermines basically one of the, I
would say, the use case for Bitcoin, which is to avoid a situation like that.

Furthermore, this decentralized transaction relay network, where everybody kind
of hears about transactions, essentially the best way to send your transaction
is to join the network as an anonymous node and to connect to these anonymous
peers, which may or may not be miners, or they can be connected to miners, and
you send your transactions to them.  And you get to obfuscate you as the
originating node because it goes through all these hops, and it could go to
anyone and it could come from anyone.  And you can also submit over Tor, which
is basically exactly the same idea, where you're hiding your IP address behind a
series of hops of nodes that don't know each other, right.

So, yeah, this is kind of the idea, to hide who mines the transactions and who
sent the transactions.  And, sorry, one last point of the benefit of everyone
being an equal participant in this network is also anyone can then become a
miner.  So if you're unhappy with what's being mined today, let's say miners are
just mining empty blocks or they're not mining your transaction, or whatever,
you can start mining.  Of course, you need the hash rate in order to do it, but
there's no barrier to entry in terms of knowing about what transactions and thus
fees you can include in your blocks.

Harding wrote an example which was, let's say there's only ten miners and you're
a user and you're deciding who to send your transactions to.  Obviously, you're
going to send to the biggest miners because they have the best chance of
confirming your transaction.  And let's say this teeny, little miner with 1% or
0.5% or 0.1% of the hashrate joins the network.  You're like, "Well, I'm not
going to send it to you because there's diminishing returns in adding an extra
step in my broadcast system".  And so this then means that that miner who just
joined the network will also not be able to include very many fees, and that
just changes the dynamic of the accessibility or the entry cost of becoming a
miner.  Whereas today, hopefully, you can just spin up any node on the network
and you'll hear about hopefully 99.99% of transactions that the big miners are
also hearing about.

So essentially, my main point is these philosophical ideologies of what we want
Bitcoin to be are enabled by this P2P network, and that works because each node
has a cache, just a cache of unconfirmed transactions.  It's just a cache and we
don't have to think about it as being really that complicated for now, other
than yeah, it's just a cache of unconfirmed transactions.  And then at the very
end, I'm segueing into, "Well, your cache needs to be hot in order to be
useful".  So, say your mempool fills up, how do you measure what's going to be
the most useful transaction to keep?  And then that kind of leads us into
feerate and fees, which is a concept that is used in a lot of mempool policies.
So, stay tuned for part two, which is going to be our first section about
mempool policy.  Thanks for listening to my rant!

**Mike Schmidt**: Excellent, Gloria.  It's great to get Gloria mempool knowledge
right from the firehose, and thanks for taking the initiative to write not only
this, but the idea for the whole series, and I'm looking forward to having you
on in future discussions to walk through the next write-ups.  Murch, anything to
add?

**Mark Erhardt**: No, I think we covered everything already.

**Mike Schmidt**: Gloria, were you going to say something?

**Gloria Zhao**: I was going to say, this is in collaboration with Murch.  Thank
you, Murch.  He's also going to be writing a few of the sections, just to make
sure that's clear.

**Mike Schmidt**: Gloria, you're welcome to stay on, or if you have important
things to do, feel free to drop as well.  Thanks for joining us.

**Gloria Zhao**: Thank you.

**Mike Schmidt**: Next section from the newsletter this week is releases and
release candidates.

_Libsecp256k1 0.3.2_

The first one we noted here was libsecp 0.3.2, which is a security release.  I
think we covered something similar a few weeks ago, in which a bug or a
potential attack vector is exposed due to optimization of the compiler.  It
looks like GCC version 13 or higher actually makes some optimizations that open
up the possibility of a side-channel attack.  Murch, when we covered this
previously, was it just the pull requests that addressed this, or was this a
different issue when we covered side-channel attacks before?

**Mark Erhardt**: I think it was the same pull request, and now this is the
release that includes it.

**Mike Schmidt**: Got you.  So if you're using libsecp, consider upgrading for
the security release.

_Core Lightning 23.05rc2_

The next release we had this week is Core Lightning 23.05rc2, which is actually
I think the same rc that we covered last week, so I don't think there's too much
to add.  Murch, do you have a thought there?

_Bitcoin Core 23.2rc1_

_Bitcoin Core 24.1rc3_

_Bitcoin Core 25.0rc2_

Then the last three release candidates are all for Bitcoin Core.  So different
release candidates for 23.2, 24.1, and 25.0.  Murch, given we're going kind of
long today, did you want to jump in to these this week or maybe we can do a
deeper dive in the future; it's up to you?

**Mark Erhardt**: I think, let's just say obviously 23.2 and then 24.1 are point
releases that are maintenance releases; we're backporting bug fixes and other
issues, so don't expect any new features there.  And the 25.0 release is the new
release, and I think we should cover it next week because we're already at over
an hour.

**Mike Schmidt**: Notable code and documentation changes.

_Bitcoin Core #26076_

Bitcoin Core #26076, updating RPC methods that show derivation paths to use an h
instead of a single quote.  Murch, why would we do this?

**Mark Erhardt**: So, if you use quotes and strings in various serialization and
input formats, you often have to escape them, and that becomes a little more
complicated, especially if people are not familiar with that, so usually you
need to put a backslash before that.  By using a regular letter, we can avoid
that and it just becomes easier to use.  This breaks, of course, with how it was
done before, so there's a few downsides, like descriptors that use the new
serialization will have a different checksum, and we had to put in some
considerations for when you import private keys.  So for private keys, we used
the same format as we imported it with, so nothing changes there.  But hopefully
in the future, for people interacting with descriptors, it'll get easier.

_Bitcoin Core #27608_

**Mike Schmidt**: Next PR from the newsletter is Bitcoin Core #27608.  Bitcoin
Core will continue trying to download a block from a peer, even if another peer
provided the block.  Murch, I just dug briefly into this, and I don't understand
what the issue is here.  Can you explain the concern about having multiple peers
and downloading blocks from them at the same time?

**Mark Erhardt**: Honestly, I'm not 100% sure.  I could see how it relates to
somebody starting to give you a part of the block but never finishing to give it
to you completely and stalling you out for a while.  And in that case, you would
want to have multiple peers provided to you in parallel so that if somebody is
playing games with you, you are sure to get it quickly either way.  I'm not sure
if this addresses exactly that issue or if there's another issue here, but yeah,
basically we only stop looking for the new block once we have acquired and
stored the old block.  It makes sense in the sense that it should lead to us
more quickly being ready to forward it and continue on with syncing.

_LDK #2286_

**Mike Schmidt**: LDK #2286, allowing creation and signing of PSBTs for outputs
controlled by the local wallet.  So, LDK is PSBT enabled now.  Murch, I know
you're a big PSBT fan, any thoughts on this other than the headline?

**Mark Erhardt**: Good, more people should do it!

_LDK #1794_

**Mike Schmidt**: Next PR is LDK #1794.  It's the beginning of adding support
for dual funding, and so this is not dual funding being rolled out in LDK, but
some of the foundational methods for the interactive funding protocol have been
merged into LDK, so there's some progress there.  Anything else you saw there,
Murch?

**Mark Erhardt**: No, sorry.

_Rust Bitcoin #1844_

**Mike Schmidt**: Next PR that we covered this week was Rust Bitcoin #1844,
making the schema in a BIP21 URI lowercase.  So, my understanding is that the
spec says that the case is insensitive.  There's some advantages for actually
the uppercase URI BITCOIN: being all capitals versus lowercase bitcoin, but it
shows that there's some issues when you're using the uppercase, that some of the
applications are not actually opening up unless it's all lowercase.  So it
sounds like, this PR changes that to be all lowercase then.  Murch, why would
there be an issue; is this just some client libraries not parsing the bitcoin:
string in a case insensitive way, or is there something more going on there?  I
see, Dan, you have your hand up; do you want to say something, Dan?

**Dan Gould**: Yeah, my reading of the issue was it's the Android OS actually
that doesn't recognize URIs that have the uppercase identifier, so like the
bitcoin: part.  And someone did submit a pull request to change that, and I hope
it changes.

**Mike Schmidt**: So it's actually at the operating system level then, not even
the application layer; interesting.  Murch, anything to add there?

**Mark Erhardt**: Well, I can put a little more color on why it's more efficient
to encode capital letters.  So, the capital letters are encoded in the smallest
letter section, sorry, not smallest letter section, but they can be encoded more
compactly in QR codes.  If you only have uppercase letters, you can use, I
think, a subset of ASCII, and your QR code will just have fewer boxes and
generally appear bigger, so it's easier to scan.  And so, one of the reasons why
bech32m addresses, or bech32 in general, is case insensitive is that you could
either do it uppercase, for example for QR codes, or you could do it lowercase
and generally don't have to also keep track of the case when you're, say,
dictating or copying manually.  So, yeah, uppercase everything would have been
the most compact QR code encoding.

_Rust Bitcoin #1837_

**Mike Schmidt**: Next PR to the newsletter is Rust Bitcoin #1837, adding a
function for generating a new private key.  I looked at the issue that spawned
this PR, and it looks like there was just the necessity to provide additional
information, including a source of randomness to the function, whereas now it
looks like that's built in when you request a private key, as opposed to you
having to kind of put that together.  Murch, did you get a chance to jump into
this Rust Bitcoin PR?  All right.

_BOLTs #1075_

The last PR for this week is to the BOLTs repository, BOLTs #1075, updating the
specs so that nodes should no longer disconnect from a peer after receiving a
warning message from it.  I don't know if there's anything notable other than
that headline, Murch, I'm not sure if you dug into the motivation.  I think
we've talked about this a bit in the past, but any color to add there?

**Mark Erhardt**: I think that we're seeing this pull request now, especially
because we've heard a few times about a lot of forced closes in the last few
weeks, which was especially painful at the peak of the feerates, where people
had to pay a lot to force close a channel that they might not even want to force
close.  So, I think it's been going on for a couple of years that the various
implementations were working together to reduce things that cause conflicts and
cause one of the sides to force close, simply because almost never do we
actually want to force close unless it's an absolute must.

So, how I'm reading this pull request is, instead of always disconnecting on
warnings, we now only disconnect on certain warnings where we do want to
explicitly drop the connection.

**Mike Schmidt**: Excellent.  Before I thank our guests for joining, I'll give a
quick opportunity before we wrap up, if anybody has a question or a comment that
we didn't address, feel free to request speaker access.  But we did have a great
line-up of folks today.  So, thank you to Carla for joining, Dan, Gloria,
Severin, and Murch.  Did I get everybody?  All right. And we will see you
all next week for Newsletter #252.  Thanks for your time, cheers.

**Mark Erhardt**: Cheers.

{% include references.md %}
