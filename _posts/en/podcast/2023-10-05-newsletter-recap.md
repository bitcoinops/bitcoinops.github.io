---
title: 'Bitcoin Optech Newsletter #271 Recap Podcast'
permalink: /en/podcast/2023/10/05/
reference: /en/newsletters/2023/10/04/
name: 2023-10-05-recap
slug: 2023-10-05-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Gijs van Dam and Dave Harding to
discuss [Newsletter #271]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-9-6/350029214-22050-1-721916da60d76.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #271 Recap on
Twitter Spaces.  Today we're going to be discussing remotely controlling
Lightning nodes using a hardware signing device, some privacy-focused Lightning
research involving dynamically splitting Lightning payments, a proposal to
improve Lightning liquidity using something called sidepools, and we'll be
covering the long-awaited LND v0.17.0 release.  We're joined by two special
guests this week.  We have Dave Harding and Gijs van Dam.  I'm Mike Schmidt,
contributor at Optech and Executive Director at Brink, funding Bitcoin
open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin stuff.

**Mike Schmidt**: Dave?

**Dave Harding**: Hi, I'm Dave.  I help with the Optech Newsletter and I am
co-author of the upcoming third edition of Mastering Bitcoin.

**Mike Schmidt**: Dave, I think the people want to know, when do you think it'll
be out?

**Dave Harding**: We're looking at early December, probably at the latest, so it
could be out around Thanksgiving, or the US Thanksgiving at least, but yeah,
early December.  If you want to read it, you can actually read the entire thing
right now online on O'Reilly's website.  It's not the finished edition, but it's
really close right now.  So if you're really eager, go get it right there.

**Mike Schmidt**: Awesome.  Gijs?

**Gijs van Dam**: Yes.  So I'm currently finishing my PhD, and my research is on
Lightning Network and its privacy properties.

**Mike Schmidt**: Excellent.  Well, thank you, Gijs and Dave, for joining us
this week.  We'll go through the newsletter sequentially.  This is #271.

_Secure remote control of LN nodes_

The first news item this week is titled Secure remote control of LN Nodes, and
this is a proposal from t-bast, who proposed a BLIP, which is a Bitcoin
Lightning Improvement Proposal, that specifies how a user could potentially
control their LN node remotely using BOLT8, which is the Encrypted and
Authenticated Transport spec for Lightning, in addition to this BLIP to be able
to control certain aspects of their LN node.  And from the BLIP, he outlines
three different components that would be involved with this sort of control.
One would be the user's LN node running on a remote server; the second component
would be a hardware device, a secure hardware device that would have a trusted
display, so there's a display requirement, and he gave an example of one I think
that he's working on or toying with, which is the Ledger Nano S; and then, the
third component would be a companion app, which is an untrusted application that
would be used to communicate with the hardware device and the LN Node, and sort
of glues those two together.

I think he also outlined a couple of competing ways in which this is done
currently.  One is directly connecting to the node using something like SSH, and
then calling the local RPCs; or, exposing the node's RPCs over the internet and
then having some form of authentication.  Both of these mechanisms that people
use are potentially dangerous if the machine that you're performing those tasks
on is compromised.  And so he's come up with this alternate way of communicating
with LN nodes.  It's essentially a pared down version of some things that we've
talked about previously with the commando plugin for Core Lightning (CLN).
Murch or Dave or Gijs, do you guys have any comments on this?

**Mark Erhardt**: Yeah, I had a question/comment.  So, I think we're all aware
of the VLS project, where people are trying to implement a hardware security
module that has policies that it can enforce locally to decide when it signs or
not.  Would I be right to assume that this would sort of plug into, or provide
rails for, a user that runs a VLS on their end, so you could sort of have this
communication channel open to your VLS use, Paratonnerre, the BLIP that Bastien
proposes to communicate with your LN node, but then run VLS on the other side to
automate some of the signoffs?  Dave, you've read the BLIP probably more
carefully because you wrote up this description.  Do you have an idea how that
would interact?

**Dave Harding**: First of all, I think that's a really good point and that
should probably be raised in the discussion, how it would interact with VLS,
because it is a similar project doing similar things, somewhat.  I really got
the impression that this is for somebody who's going to be using LN somewhat
infrequently, but also for high value.  If you're using LN for low-value
payments, it's okay to have that in a somewhat untrusted environment, like on
your phone or on your desktop computer.  But if you're going to occasionally
make large payments with LN, you might have a separate channel for that.  For
example, if you're going to do payroll from LN, you might be handling tens of
thousands of dollars' worth of bitcoin, and you're going to want each one of
those payments to be specifically authorized by your hardware device.

So, I think maybe it's kind of separate from VLS because VLS is something you
might want to use again for your daily payments and to keep them there.  I think
now you say that, that sounds like it's a good combination.  You might have VLS
run on a channel with high value that allows you to use it for daily payments,
allows you to set a daily payment restriction, and then use your hardware
signing device to authorize large payments, like something like payroll.  So,
yeah, that needs to be brought up in the discussion that these things should be
working together.

**Mike Schmidt**: I was able to see some tweets on this topic, and t-bast
responded to somebody bringing up the VLS topic and had said, "Yes, I know about
VLS.  We actually worked on these issues long before VLS existed", and he links
to a blog post on the topic.  And he says, "But what I'm proposing in this BLIP
is a completely separate project, it really has nothing to do with what VLS
does.  And then he goes on to comment, "Well, maybe what I'm suggesting could
also be implemented inside VLS, but I find it interesting only when you have a
hardware trusted display, which is a different model from the type of hardware
devices that VLS targets".

**Mark Erhardt**: Right.  So I think one of the things that VLS could automate
is, VLS can recognize when you're only forwarding payments and can sign off on
those.  So, if you force your channel to only be signed off on a hardware
device, one of the problems that you would have is that the channel wouldn't be
able to forward anymore, because without you actually monitoring the hardware
device, you wouldn't be there to physically sign off and instruct your hardware
device to accept a Hash Time Locked Contract (HTLC) and forward it.  So, I think
you could potentially have two different authenticated devices, the VLS that,
for example, takes care of the forwarding, and then this other device that has a
display that you would use to authorize larger payments.  But I'm certainly a
few steps further removed from this whole thing than Bastien, I'm sure; or, I
don't know how likely that would be able to work.  So, I don't know.  Thinking
out in the blue here.

**Dave Harding**: I don't think what t-bast is proposing is for the keys to
actually be stored on the hardware signing device.  I think he's suggesting that
the public key on the hardware signing device is put into your LN node as an
authentication method.  So, you sign a message to your LN node telling it what
to do, so some commands on the LN node can be remotely run using a message
signed by your hardware signing device.  So, the node itself could continue to
do forwarding, it could have a policy, and that would be similar to VLS in that
sense, that the node would have a policy that says, "I can forward payments on
my own".  But if the user wants to send a payment, one of the ways they can do
that is by signing a message using the display on their hardware signing device,
and then sending that using a BOLT8 message to the node.  And the node will say,
"Oh, well now I will send a payment authorized by the user".  So, again, you
could still forward payments, is all I'm saying.

**Mark Erhardt**: That's cool.  But then, I don't understand how it would
improve security against hacking.  Because if your software enforces the policy
locally, once someone gains access to your device, they could also just
circumvent other instructions that the software is enforcing, right?  So, if the
key is on your LN node and can forward, and the hardware device is not involved
in all of the forwarding events, the key is still there if the node gets hacked.

**Dave Harding**: So what I think t-bast is envisioning is that you have a
secure piece of hardware, let's say a dedicated computer, for your LN node, and
maybe it's headless.  So, the only way you can access it is by using another
device, and that device that you use to access it might not be secure.  So, I
might have a very secure LN node running on a Raspberry Pi here in my office,
and I also have my desktop and I use my desktop to access all sorts of random
stuff on the internet, so it's more likely to get hacked.  And right now, the
only way I could issue a command to my LN node would be by SSHing into the
headless box running the LN node, or by some other mechanism that's vulnerable
to compromise.  Whereas what t-bast imagines is that I would have a hardware
signing device also in my office, and when I wanted to issue a payment, I would
use that.  I would connect it to the headless LN box and I would sign a message
saying, "Pay Murch $100", or something like that.  And so, again, my desktop
computer would not be involved in this security loop.

**Mark Erhardt**: Right, okay, that makes a lot more sense.  Thanks for
clarifying.

**Mike Schmidt**: We contrasted a bit with VLS, and I think another comparison
is the commando plugin for CLN.  Rusty, from the CLN team, commented on the BLIP
thread and mentioned, "It's like a reduced subset of commando".  And t-bast also
mentions that comparison to commando, in that it has a lot of similarities, but
the part that he finds interesting is having all of BOLT8 inside the hardware
device so that, "Each outgoing and incoming message is displayed on the trusted
hardware display", and it doesn't have the exact same goals as commando;
essentially a pared-down set of commands that involves the spending of some
bitcoin, because that's what really you want to secure as much as possible.  Any
other comments on this news item, team?  All right.

_Payment splitting and switching_

The next news item from the newsletter is payment splitting and switching (PSS).
And Gijs, you posted on the Lightning-Dev mailing list a post titled, Payment
Splitting and Switching and its impact on Balanced Discovery Attacks.  Maybe one
place to start is maybe for the audience, what is a balanced discovery attack?

**Gijs van Dam**: Well, a balanced discovery attack is also known as probing,
but I tend to use the term, balanced discovery attack.  It's a way of
discovering the balance of a channel that you, yourself, or the attacker isn't
part of.  And you do that by sending payments that use a random payment hash.
So, the payment will fail anyway because of the random payment hash that you are
using.  But now, if you use different amounts, then you can discern by error
messages whether it failed because of the payment hash that the receiver doesn't
recognize, or because it failed of a channel on the route to the receiver that
doesn't have enough liquidity to route the payment.  You can use that
information to discern the exact balance of a channel.  And this is something
that I've been doing research on for quite some time already.  And, yes, so it's
a privacy risk for LN in general.

So, I was trying to find a mitigation, and I actually built on an idea of
ZmnSCPxj that he posted years ago already, because the whole idea of a probing
or balanced discovery attack hinges on LN being a source-based routing, right?
So, the sender determines the exact route that the payment will take, and that
makes it possible for him to target a specific channel that he wants to know the
balance of.  And so a while ago, ZmnSCPxj posted the idea of intermediate
payment splitting.  And there was already something like intermediary payment
splitting, called a Link Multipart Payment (Link MPP), where in Link MPP, you
use two parallel channels.  ZmnSCPxj floated the idea, actually his idea, of
using rendezvous routing to find another route to the next hop, to the next
node, an alternative route via one or more intermediary hops.  And then you can
split the payment over those alternative routes that you can find.

I found that way back, I thought that's an interesting idea.  So, I discussed it
with him via email and also with Christian Decker. and I made a plugin that is
actually a proof of concept, nothing more.  Please don't use it for anything!
But it doesn't use rendez-vous routing, obviously.  It's more a combination of
the idea of Link MPP mixed together with Just in Time routing (JIT-routing) from
an AP card.

**Mark Erhardt**: So, just to recap and see that I understood it correctly,
basically when you forward a payment in a multi-hop payment attempt, you know
what the next recipient in the chain of hops is going to be.  So, let's say I'm
Bob.  The payment goes from Alice through me, Bob, to Carol, to Dave.  I know
that Carol is the next recipient along the line, but obviously I cannot know
that the ultimate recipient is Dave.  So, what I do is I only split my
forwarding attempt from Bob to Carol into multiple subparts, and it's sort of
reassembled at Carol's side again, and then Carol has still her onion to unpack
and to forward to Dave; but she, again, doesn't know whether Dave is the
ultimate recipient or there's more recipients after that.  But for every step,
basically, the one forwarder can seek alternative routes and just for that one
hop, try to get the money to the next recipient in a different way.

**Gijs van Dam**: Yes, that's correct.  And what's important to note there is
that Bob is the one splitting up the payment and Carol is the one that
reassembles it.  And Bob uses just the original onion he receives, but he will
commit to an HTLC that carries an amount that's less than the intended amount.
And that's what triggers Carol, if she also supports payment splitting; that's
what triggers Carol to wait for a little while longer to receive the rest of the
amount via an alternative route.  And you could see that happening, like maybe
she needs to wait 30 seconds or 60 seconds.  In other MPP proposals, there's
also a waiting time for reassembling everything.  So, yeah, that's something
that we should decide on at a later point.

**Mark Erhardt**: Right, that's pretty cool, because Carol knows, "Wait, I'm
supposed to send to Dave a larger amount than what I'm receiving here on Bob's
channel right now, I might be getting more money for another route".  And then
Carol will only accept the forwarded payment once she has sufficient funds to
reimburse her for what she promises to Dave.  So, it's easy for her to assess or
to eventually reject that HTLC, because if it doesn't pay her enough to forward,
she would be asked to take a loss and she's not going to do that.

**Gijs van Dam**: Yes, she will not do that, so she will fill the original HTLC
and maybe the other HTLCs that combined weren't enough to reassemble the
complete amount.

**Mark Erhardt**: That's sort of like the idea that was behind MPP, was it
multipart payment, or one of the two, AMP or MPP?

**Gijs van Dam**: Yeah, so on my website, I've made a post of all the different
ideas around MPP, and I think this resembles Link MPP.  So, the incentive for
Carol is economic incentive to wait for the different payment parts.

**Mark Erhardt**: Okay, now pointy question.  Is that a new dust vector how I
can make Carol wait longer and then just never deliver?

**Gijs van Dam**: Yes, I think this would be able -- yeah, I think you could
make Carol wait longer.  Well, see, it depends on how you set up the details of
this proposal.  And I think there are other ways of jamming that might be easier
to achieve.  But yes, I agree with you that it might be a way of making Carol
wait.

**Dave Harding**: I actually don't think that's a new DoS vector.  I think when
Bob forwards the payment to the alternative route, both directly to Carol and
parts of it through an alternative route, Bob's just going to use the same
OP_CHECKLOCKTIMEVERIFY (CLTV) delta on the payment; and the CLTV delta defines
the point in which the HTLC would need to be dropped onchain if there were a
problem.  And I think that as long as the CLTV delta stays the same for all the
payments, there's no fundamental new DoS factor here, we're just back to regular
channel jamming.  So, yeah, I don't think there's anything new there.

**Mark Erhardt**: Okay, thanks.

**Mike Schmidt**: In this example that we've walked through with Alice and Bob
and Carol and Dave, who would need to have this PSS plugin or compatible
software in order to facilitate what we spoke about here?

**Gijs van Dam**: Bob and Carol, in this example.  So, both channel partners
will need to support a PSS.  But they can do so without anybody knowing, and
that's for me, for my research purposes, that was what's interesting about it,
because now the attacker in this scenario, Alice, doesn't know whether they
support PSS.  So, she is unaware of maybe the payment taking a different route
than expected.

**Mark Erhardt**: Yeah, that's really cool because obviously, if a node does not
have sufficient balance on the route that the sender picked, they can locally
correct for that.  So, that might actually help make more payment attempts go
through more quickly, even though you sort of need to first establish another
route, which of course might have its own latency increase.

**Gijs van Dam**: Correct, that's exactly right.  And that's why it resembles a
little bit the proposal of René Pickhardt, JIT-routing, but whereas JIT-routing
requires an alternative payment that does a kind of very fast rebalancing before
you accept to forward the payment, in my proposal the rebalancing and the actual
payment itself are combined into one mix.

**Mark Erhardt**: Right, if I recall correctly, JIT-routing would be, you find
some sort of small cycle that enables you to increase your balance on the
channel that you're trying to route through, by sending a round-trip payment to
yourself through that cycle, and that would enable you to forward.  And you
would, of course, only do that if you earn enough fees to pay for the cycle
payment itself.

**Gijs van Dam**: Yeah, exactly.  And that will be the same here, but the
difference is that it's not a round-trip payment, it doesn't cycle back to you;
you can forego on the last leg of the round trip.  So, in a cycle, you would go
from Bob to some intermediary node to Carol and then back to Bob.  And that last
leg of the journey isn't needed because you just know that Carol will reassemble
the separate parts of the payment.  And that also makes it, from a fee
perspective, probably easier to find something that's worthwhile doing, because
you don't have to pay for the last leg of the round trip.

**Mark Erhardt**: That's great, that's really cool.

**Mike Schmidt**: Gijs, can you speak a little bit to how it could be part of a
mitigation against channel jamming attacks?

**Gijs van Dam**: Yes, so actually, that was my incentive for making this.  And
my research, I like to do research on topics that are possible within LN today
without too much of a change to the protocol.  So, that's why I wanted to prove
that it's possible, and that's why I built this plugin for CLN.  But I can see
it as a mitigation for a balanced discovery attack because without PSS, an
attacker has certainty that his payment will take a certain route, so he can
target a specific channel.  And one thing that in earlier papers we didn't take
into account was parallel channels, so that makes it a little bit different,
because with parallel channels, even without PSS, if two nodes have multiple
channels between them, the forwarding node is free to choose whichever parallel
channel he wants to, because the onion doesn't prescribe which channel, if you
have multiple, you should use.

There's an excellent paper on that by Alex Biryukov, Gleb Naumenko and Sergei
Tikhomirov, if I'm pronouncing that correctly.  And they made a geometrical
model for finding the balance by using the balanced discovery attack, even in
the case of parallel channels.  And what that geometrical model does is, it
represents each dimension of that, or it works with a hypercube, so a
multidimensional cube, where each dimension of the cube represents the capacity
of a channel.  And I used that same model and made a hypercube where each
dimension of that cube is represented by the capacity of a possible route.  So,
it can be a single-hop route or multi-hop route, but each dimension of that
hypercube is represented.  So, that hypercube is the possible result space of
all possible balances before the attacker starts.

Now, by doing a balanced discovery attack, you make that hypercube smaller.  And
you can shrink it to a single point in the case of a single channel, and when
you have multiple parallel channels without PSS, you can shrink it to a
permutation of multiple points.  But now with PSS, that shrinking becomes way
more complex.  I won't go into the details, but the computational complexity
becomes way bigger to just determine what the possible balances are of the
possible routes that you are probing.  That's even considering that you know
which possible routes there are, which is something that you don't know because
you don't know that information because you don't know for sure whether a
payment is split up or not.

**Mark Erhardt**: Right.  So basically, in the paper that you described, I think
I'm familiar, what you do is you basically hold the balance on all channels from
even both sides, and that way you can start excluding other channels that you
know about until you can measure one specific channel, because it's the only
degree of freedom.  And with your proposed PSS, any potential route between Bob
and Carol, even via other hops or multiple other hops, it becomes another
dimension in your hypercube that they also have to freeze in order to measure.

**Gijs van Dam**: Correct.  So, your hypercube becomes way bigger, but also the
information you get from an attack gives you less shrinking power, so to speak.
So, the hypercube becomes smaller by a smaller amount than without PSS.  So, in
the end of a balanced discovery attack, you are left with a result space that is
way bigger than without PSS.

**Mark Erhardt**: Okay, I want to mouth off a little bit here, but my impression
is between this PSS approach, the propensity of multiple implementations to not
update the routable balance exact amounts of what is available, but to round it
down slightly now, and then with the proposed upcoming change of advance fees
and local reputation, I think that balanced discovery attacks are going to be
really hard and expensive in the future.

**Gijs van Dam**: I agree.  So, that's true and that's something I didn't take
into account because it's not part of the protocol right now as far as I'm
aware.

**Mike Schmidt**: One question before we wrap up, maybe slightly off topic, but
I'm always curious about how different researchers come to the Bitcoin and
Lightning ecosystem to want to spend their time doing research here.  Murch and
the folks at Chaincode have a Bitcoin Research Day coming up later in October.
And I'm curious, Gijs, how did you come across Lightning and Bitcoin and become
interested in that from a researcher perspective?

**Gijs van Dam**: It's a bit of a personal story, I guess.  I've been working in
IT for as long as I remember, over 20 years already.  And seven years ago, I
moved to Malaysia, to Kuala Lumpur, and that was because my wife was working
there as a professor at a university there.  And living there, I got the
opportunity to do a PhD, and I never studied some -- I mean, I had a master's,
but not in something related to IT.  So, I thought maybe I can fill in that void
now by doing a PhD.  And I was into Bitcoin already, and I was part of the
Bitcoin meetup scene in Kuala Lumpur.  And I saw a presentation, I think in,
must be at the beginning of 2018, I think, about LN, and that really triggered
me.  And I thought, "I want to do my PhD research on LN".  And privacy and
security is something that's close to my heart, so that was the combination.
So, I found a local university and a professor that wanted to supervise me and
started researching it.

**Mike Schmidt**: Excellent.  So, inspirational Lightning presentation sort of
was the final gateway into wanting to spend time on it?

**Gijs** **van Dam**: Yeah, and it was somebody on a whiteboard trying to
explain HTLCs to an audience of ten or something, and obviously losing the plot
in the beginning of 2018 about how HTLCs actually work.  So, it was like this
interactive fun presentation where we all joined together trying to understand
something like HTLCs.

**Mike Schmidt**: Gijs, thanks for joining us.  The rest of the newsletter is
all Lightning-related stuff if you would like to stick around and comment on
some of this.  Otherwise, if you need to go, we understand.

**Gijs van Dam**: I'll stay, thank you.  Thank you for having me.

_Pooled liquidity for LN_

**Mike Schmidt**: Next news item from the newsletter is pooled liquidity for LN.
And this is a post by ZmnSCPxj, who we've referenced already in this discussion,
who posted to the Lightning-Dev mailing list a suggestion for what he calls
sidepools, which is a technique for groups of LN nodes to pool funds into an
offchain contract that would allow for rebalancing of channels between those
nodes offchain.  Dave, I think you might be the one who understands this topic
the most.  Would you expound on that and is that even a correct summary?

**Dave Harding**: That is a correct summary as far as I know.  I'll get into
ZmnSCPxj research.  He's unfortunately not able here to be with us today, so I'm
going to give it my best shot.  So, in LN, we have this kind of liquidity
problem.  If Alice and Bob have a channel together and they want to forward
payments, they want to make money by forwarding payments for other people, some
of those payments are going to arrive at Alice's node and she's going to forward
them to Bob.  But when she does that, her balance in the channel goes down and
Bob's balance in the channel increases.  And payments can go the other
direction, of course; that would lower Bob's balance and increase Alice's
balance in the channel.

But in almost no channels are the payment flows symmetrical.  In most cases,
most of the money is going to be going in one direction or the other.  And when
that happens, let's say it goes from Alice to Bob, then Alice eventually runs
out of the ability to have funds in the channel to forward additional payments.
So, when that next payment arrives, Alice can't forward.  She doesn't have the
funds to trustlessly commit to giving to Bob, and she has to reject the payment.
And that's bad for the person who sends the payment, it's bad for LN in general,
and it's also bad for Alice and Bob.  They've committed funds to this channel,
they've made a capital investment, and now they can't serve the market.  There's
obviously demand, but they can't serve the market.

ZmnSCPxj, if you look across his research across years, he's really worked on
this problem a lot.  He's spent a significant amount of time, he's written
software for it.  The popular CLBOSS is something he wrote, I think.  It's
currently being maintained by other people, but ZmnSCPxj started that.  He's had
a lot of ideas about this, and this is a new one.  I think he is really keen on
it.  So, again, I'm going to try to do my best job to describe it.

With this problem, what ZmnSCPxj is trying to do is trying to find a minimal fix
to the network.  We don't want to change how the network works right now.  If we
can change the network, that's great, but changing the network is hard.  So,
ZmnSCPxj's idea is for a bunch of forwarding nodes.  So, Alice and Bob and Carol
and Dan and whoever else, who are people who are committed to forwarding funds,
they're all going to get together, and they're going to open what he calls a
sidepool.  It's a multiparty state contract.  It's kind of like LN, but what
ZmnSCPxj imagines is it's only going to be used maybe once or twice a day.  It's
going to have one big operation once or twice a day between these people who are
going to rebalance their funds in this multiparty contract.

So what happens is, Alice is out of funds in her channel with Bob, but Alice and
Bob and Carol are also in a sidepool.  So, Carol agrees to give some funds to
Alice in the sidepool.  Oh, gosh, this is hard to do in my head, sorry!  What we
want is for money in the channel between Alice and Bob to flow back from Bob to
Alice.  So, Carol sends money to Bob to Alice.  Part of that operation occurs in
the sidepool, and part of the operation occurs in the channels between Alice and
Bob, and it ends up equaling this stuff out.  And now Alice has a restored
balance in this channel, more payments can flow through again.

The sidepool, the idea there is to get as many of these forwarding users into it
as possible, because there's more edges for them right there to find
opportunities to move funds around.  It's only going to occur once or twice a
day because the more frequently it occurs, at least according to ZmnSCPxj, the
greater the chance there's going to be some sort of failure that's going to
require dropping the channel onchain.  So, we need to drop channels onchain if
one of the parties becomes unavailable for an extended period of time in order
to keep it trustless.  In a standard channel, that's a risk that you expect.
And in a peer swap, with a whole bunch of people involved, we want to minimize
the risk of that happening, because if you have to drop the channel onchain,
it's a big transaction you have to use or a big set of transactions you have to
use.

One of the challenges here for the sidepool idea is a multiparty state contract,
or something.  Oh, look Murch has a question.  Murch, you go ahead first.

**Mark Erhardt**: Yeah, I was going to follow up.  But one of the parts that I
wanted to follow up with is already relevant.  So, basically it sounds to me
like there is just a reservoir of staged funds.  They're not really in a channel
per se, but rather like just a shared balance that has sort of a single
commitment transaction that pays all of the stagers out at once.  And they use
these staged funds, not like an LN channel, but rather just as a reservoir to
rebalance the other channels that exist between the participants of the
sidepool.  So, sort of like a water reservoir on top of the hill that they only
engage whenever they want to, well, increase the electricity output in a hydro;
okay, this metaphor is going too far!  But like staged funds that are not
liquid, except for once in a day, but they can be used to rebalance channels.

**Dave Harding**: That's correct.  They're only going to be used, in ZmnSCPxj's
idea, once or twice a day.  So, in order to do the rebalancing, there needs to
be an HTLC.  But it could be an HTLC involving multiple parts.  It could be one
big HTLC for the entire channel involving dozens, or potentially even hundreds
of different forwarding nodes.  And as long as everybody comes online and stays
online for this one brief period every day, that HTLC gets resolved offchain and
we only need to put that reserve reservoir channel, using Murch's term, we only
need to use that very rarely; we only need to update it onchain very rarely.
And I think there was something more I was going to say, but I can't remember,
so I don't know if anybody has questions.

**Mark Erhardt**: Yeah, so the obvious related idea seems to be channel
factories, right?  So, if I may take a stab at it, a channel factory is
different in the sense that you explicitly use the larger set of funds to craft
virtual channels that live inside of the channel factory.  So, you get sort of a
similar mechanism, but all of the participants of the channel factory need to be
online more frequently for the subsets, the pairs inside of the channel
factories, to update their virtual channels.

Here instead, the funds are separate a little more, and there is an explicit
timeframe at which they're online once to check in with each other per day, and
they can still use the funds to rebalance channels, but the channels are not
part of the reservoir; they're rather separate, and you just interact with them
to rebalance, and then the reservoir is basically dormant again until next day.
Whereas in the channel factory, basically all participants are expected to be
online 24/7.  Is that roughly your understanding, too?

**Dave Harding**: We have a bunch of channel factory designs right now, and so
there's different ones optimized for different things.  I'm thinking there's the
original design by Decker and Wattenhofer, I think is his name, and then there's
the ideas by John Law, and there's other ideas out there.  And there's also
ideas for who gets involved in these channel factories.  Is it a bunch of
everyday users who are not going to forward payments; are they going to be used
by a bunch of forwarding nodes to create a bunch of edges on the network to make
paths shorter?  There's a lot of variation there in the design of channels and
how channels will be used.  So, I don't want to commit to a blanket statement
that this is very different than that.  But again, for ZmnSCPxj, he's trying to
build something that is very easy to bolt onto the existing network, where
channel factories are really hard to do.  To get right, it's a big engineering
investment to do channel factories.

So, one of the concerns I had with Murch's statement was that everybody in a
channel factory needs to be online all the time, very frequently, and I don't
think that's true in a lot of these channel factory designs.  In a lot of the
designs, we expect them to be used by casual users who are only going to be
online occasionally.  So, the channel factory might be between a Lightning
Service Provider (LSP), one LSP, and 1,000 users.  And those 1,000 users are not
going to be online all the time with the LSP probably.  But that brings us back
to the challenge of the sidepool, which is the multiparty state contract that we
need.  We don't have that mechanism in Bitcoin and LN right now.  We have ideas
for that, but nobody has, to the best of my knowledge, implemented that and
really brought it to a level of deployment.

So, ZmnSCPxj, in a follow-up post to the one we're discussing about, he seems to
have settled on an idea that was originally introduced under the name Duplex
Payment Channels by Christian Decker and Roger Wattenhofer, I think that's his
name.  And that was originally introduced around the same time that the
construct that we use in LN was first introduced, so 2015, I guess.  And it was
introduced before we had segwit and before we even had relative locktimes.  So,
ZmnSCPxj has been going through and updating this construct for modern times,
and what it gives him is a pretty simple way to have many parties involved in a
single payment channel-like construction that can handle HTLCs, but that has a
limited use lifetime.  That's one of the features here of duplex payment
channels, is that they use de-implementing timelocks, so timelocks that get
shorter and shorter and shorter over time, so it has a fixed use lifetime.

ZmnSCPxj sent me some back-of-the-napkin calculations, and I don't recall
exactly what they were, but I think it was about one year of use if they do two
rebalance operations a year with the same parameters.  So, that's a pretty good
onchain size if it's able to all be handled offchain and resolved cooperatively
onchain.  I'm rambling.  I hope you guys have questions.

**Mark Erhardt**: No, you're doing great.  I just have two small comments.  I
think that the channel factory paper came out of Conrad Burchert's master
thesis.  He was working with Christian Decker while Christian was doing his PhD,
and the duplex micropayment channels was the subject of Christian Decker's PhD
with Roger Wattenhofer.  So, yes, you put all that together right, but there was
another person involved.

I saw in one of the emails of ZmnSCPxj, he seemed to suggest that if you only
want to wait up to eight days for a sidepool to be resolved unilaterally, in
case of people not being available, he mentioned something of three months I
think in the second email.  If you could do it for a year, I'm sure that this
would be an attractive proposal, but that would probably go hand-in-hand with a
longer timeout in case of people becoming unavailable.  But even that might be
fine.  I mean, this is just some funds staged and sort of tied up anyway as a
reservoir to rebalance channels.  So, if it's sitting there for a while,
probably it's not funds that people urgently use to make onchain payments in the
first place.

**Mike Schmidt**: Dave, question for you.  How would you contrast coinpools
versus a multiparty state contract?  How should someone think about that?

**Dave Harding**: The way I think of coinpools is as being for onchain payments.
So, you have a bunch of users who share ownership of a UTXO in a trustless way.
And in order to update the balance of a coinpool trustlessly, I don't think they
can do that offchain.  I think they have to do that onchain, but I could be
missing something.  Whereas again, the sidepool construct we're looking for
here, the multiparty state channel, it's about making an onchain commitment.
So, they are sharing a pool, a UTXO, but it's designed specifically for making a
bunch of offchain updates and then eventually settling onchain.  However, they
are related.  It's a very clear relationship between coinpools and channel
factories and these sidepools.  They're all kind of the same thing but with
different objectives, I think.

**Mike Schmidt**: Gijs?

**Mark Erhardt**: I see a comment by Gijs.

**Gijs van Dam**: Yes, I was wondering, Murch, and maybe I'm misunderstanding it
now, but in your explanation just now, you said that you use coins for those
sidepools that you have lying around anywhere, you wouldn't be doing anything
with it anyway, and I'm rephrasing a bit.  But shouldn't also the opportunity
cost of having money in a sidepool be taken into account here?  I mean, you
don't earn any money with it if it's in the sidepool.

**Mark Erhardt**: I think that's a fair point.  I guess there would be an
opportunity cost, of course, for tying up your money in this reservoir, in the
sidepool.  But on the other hand, it would also make your regular channels that
you have already deployed probably earn more fees.  So, there would be some sort
of balance between having tied up your funds, but them being more useful because
they can go rebalance many of your channels instead of just, say, produce
another parallel channel between a peer and you that you already had a channel
with, where it would only be deployed as capital that can serve that route.  The
reservoir funds, they can be deployed daily to rebalance a bunch of other
channels.

So if you had, for example, multiple different channels that are your most
frequently used but they are sort of imbalanced in one direction, you would be
able to refresh them more often, earn more fees there, but tie up funds in the
reservoir.  Yeah, let's wrap up that thread.  I had another idea of what I
wanted to approach after.

**Dave Harding**: I just wanted to note that I accidentally replied to ZmnSCPxj
without cc'ing the mailing list and we had a rather extended conversation about
exactly this.  I was critical of this compared to other rebalancing mechanisms
and other channel designs on the capital efficiency level.  So, I think that's
something that still, to a certain level, needs to be worked out.  However, I
think a really big advantage of this design is that it is completely separate
from the rest of the LN, it doesn't require any changes to LN.  And as LN
becomes more widely used and more widely deployed, it's getting harder and
harder to change.  And so a design like this that can just be deployed
separately from the network, that requires no changes to the network, is
hopefully pretty simple to do, although I'm sure ZmnSCPxj's going to encounter
problems that none of us anticipated.  That's just really great that it's
something that can be used now, and then maybe we can find a more optimal
solution in the long term.

**Mark Erhardt**: Yeah, that brings me also to the final comment that I wanted
to make in this regard.  So, I think that a lot of designs that compete with
this make assumptions, such as ANYPREVOUT becoming available, and us getting the
LN-Symmetry channel update mechanism.  But the nice advantage of the duplex
micropayment channels, by Decker and Wattenhofer, is it just ratchets down the
state.  So, by decrementing the timeout of the channel, you explicitly make an
updated state become valid onchain earlier than prior states of the channel.
So, you lock in which state can be broadcast and confirmed on the network first.
And I assume that it would be much easier to adapt this mechanism to a
multiparty world from a two-player world, as compared to the LN-penalty
mechanism, which explicitly relies on this binary asymmetry, where you need to
be able to know that the other party cheated in order to punish that other party
specifically.  And with the ratchet mechanism, it just ratchets down, and
whoever broadcasts an old state, well they can't before you can broadcast a
newer state.

**Mike Schmidt**: Great discussion everyone.  I think in the interest of time,
we should move on.  We'll move to the Releases and release candidates' section.

_LND v0.17.0-beta_

We have one this week, LND v0.17.0-beta being released.  And I know one of the
things that people are excited about with this release is the support for
taproot channels, specifically simple taproot channels which have a couple
different benefits, privacy benefits, in that channel-open and channel-closing
transactions now can look like regular single-sig Bitcoin transactions using
schnorr signatures and MuSig2, to allow for fee savings from a block space
perspective.  But one thing that they've noted in their blogpost, and something
that's not possible right now, is that right now the LN gossip protocol doesn't
support gossiping about taproot LN channels.  And in Newsletter #261, we covered
the LN Summit Notes topic, where ideas about updated gossip protocols were being
discussed, including a bunch of 1.5, 1.75, I think 2.0 versions of gossip.  And
it looks like the current direction LN developers are taking is this version
1.75 gossip, which would allow for gossiping of these types of taproot channels.

There's a couple other things I'll jump into, but I wanted to give an
opportunity for either Murch or Dave or Gijs to comment on taproot channels
before we note some of these other things.  Thumbs up, okay, great.

**Mark Erhardt**: I mean, we've talked a bunch about this already and I would
like to refer back again.  We had Elle Mouton and Oliver Gugger on the Chaincode
podcast to talk about simple taproot channels a while back.  So, if you really
want to know more about simple taproot channels, that was recorded around LN
Summit.  So, it's a few months old, but I think you'll get more out of listening
to that podcast than what we can cover here.

**Mike Schmidt**: Additionally, with this specific LND release, we spoke with
roasbeef in #268 of our podcast, if you want to hear his thoughts on this
release.  Two other things that I wanted to note that we also noted in the
newsletter is, performance improvements for users of the Neutrino backend, which
is LND's support for BIP157 and 158 compact block filters; and finally, LND made
some improvements to the memory usage of their watchtower client, as well as
some reliability improvements to their watchtower setup as well.

_Eclair #2756_

Moving on to Notable code and documentation changes, we have three.  Actually,
I've noticed now that the entire newsletter is Lightning this week.  So, we have
three Lightning-related PRs that we covered.  The first one is Eclair #2756.
We've covered PRs related to Eclair's splicing functionality over the last many
months, including the release of ACINQ's Phoenix wallet that supported splicing
and got a lot of notoriety in the community, and that was in Newsletter #260.
But we actually spoke with t-bast about Phoenix in podcast #259 and talked about
splicing there.

This PR this week that we covered adds monitoring related to splicing operations
in Eclair.  Eclair has already had monitoring built in.  It uses a monitoring
tool called Kamon, I believe is the pronunciation, and has some cool Grafana
dashboards to display the collected metrics.  And this particular PR adds
monitoring of splicing, including three distinct types of channel splices,
splice-in, splice-out, and splice-cpfp.  Murch, I know you did the writeup for
this item for the newsletter, I have a question.  What is splice-cpfp?

**Mark Erhardt**: Well, so splice-in and splice-out are pretty obvious.  You use
the channel balance to either increase the channel balance on basis of another
input and funding output to make a bigger channel, or a splice-out is you split
off some of the funds to pay someone out of band.  Splice-cpfp is if you reduce
the channel balance in order to bump a previous splice.  So, for example, let's
say Alice and Bob had a channel, Alice paid Carol out of band from the channel
balance, so they did a splice-out, they can continue to immediately use the
channel because obviously the funds are still under the control of the shared
2-of-2 output script.  But now, let's say someone like Binance posted a bunch of
consolidation transactions at 15 times the necessary feerate and her splice-out
isn't going through.  So, now she asks Bob to do a splice-out again, but she
doesn't pay anyone; she just reduces the channel balance in order to bump the
previous splice-out.

So, the third type of splice here is basically, burn some fees to speed up the
prior settlement of the channel operation.  Oh, and they also track the
originator of the splice operation, so there's really six different statistics
here.  So, splice-in and splice-out, either initiated from local or from remote,
and splice-cpfp also initiated from remote or local.

_LDK #2486_

**Mike Schmidt**: Next PR this week is LDK #2486.  It adds the ability for LDK
users to fund multiple channels in a single transaction, which they call batch
funding.  So, you have one transaction and multiple channels.  Looking into the
discussion on this PR, much of the consideration around the PR was related to
ensuring that the channels being opened in the transaction either all open or
all close or fail.  And they've added a bunch of additional state data in LDK's
internals to keep track of these different conditions in an attempt to avoid
certain race conditions that could occur, which obviously would be different
than just a single transaction opening a single channel and being able to keep
track of all that.  So, if you're curious, jump into LDK #2486.  Dave or Murch,
I'm not sure if you have a comment on that?

_LDK #2609_

All right, final PR for this week.  LDK #2609 allows requesting the descriptors
used for receiving payments in past transactions.  When I see the word
"descriptor", I always want to defer to Murch.  So, Murch, do you want to talk
about LDK's descriptor requesting feature?

**Mark Erhardt**: So, I looked at this a little bit, and from what I understand
basically, when you recover LDK, you don't always keep track of your past
transaction outputs.  If they're already spent, LDK might forget them in some
instances, or I guess when you switch from a backup to a new node or whatever,
and this will allow you to basically rediscover the history of your LN node.
You rescan the past transactions and you determine which of the outputs were
spendable by you and get the descriptor from that.  And that's at least what a
cursory glance at the discussion on the PR seemed to indicate.  I'm open to not
having completely understood that one, though.

**Mike Schmidt**: Yeah, I think you're right.  There was an issue on the LDK
repository to be able to regenerate spendable outputs, and the motivation was,
"We require users to store these, but users have occasionally not done so", and
so regenerating them should be pretty doable.  So, I guess you were supposed to,
in theory, have some of this backed up yourself, but if you didn't, now there's
the ability to regenerate that, given the historical transaction data.

**Mark Erhardt**: Yeah, so I had one comment.  You said the whole newsletter was
about Lightning, but we actually had some really exciting news this week in
Bitcoin Core too.  Two of our priority projects got merged this week, so I'm
sure that they are going to be featured in the next newsletter.  I assume they
just missed the editorial deadline this week, so stay tuned for next week!

**Mike Schmidt**: Thanks to Gijs for joining us, Dave Harding, Murch, my co-host
as always, and thank you all for taking the time to listen to us talk about
Lightning technology this week.  Cheers.

**Mark Erhardt**: Hear you soon.

{% include references.md %}
