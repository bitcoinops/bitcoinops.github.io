---
title: 'Bitcoin Optech Newsletter #372 Recap Podcast'
permalink: /en/podcast/2025/09/23/
reference: /en/newsletters/2025/09/19/
name: 2025-09-23-recap
slug: 2025-09-23-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by ZmnSCPxj and Constantine Doumanidis to discuss [Newsletter #372]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-8-23/408017213-44100-2-7f963665feb36.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome to Optech #372 Recap.  Today, we're going to be
talking about LSP-funded redundant overpayments; we have a potential eclipse
attack that cedarctic is going to talk to us about; we have a couple of changes
to Clients and service software, including some zero-knowledge proof of reserves
and a submarine swap tool; and then, we have a couple of Releases that we'll get
into including the RC for Bitcoin Core v30 that Murch is going to run us
through.  This week, Murch and I are joined by two folks, one who is here now,
one who can introduce themselves in a minute.  Cedarctic, you want to introduce
yourself to the group?

**Constantine Doumanidis:** Yeah, sure thing.  Thank you for having me on.  So,
my name is Constantine Doumanidis, I'm a security researcher with the NetΣyn Lab
at Princeton University.  I spent the summer looking into the BGP attack that
Mike alluded to earlier.  Yeah, happy to chat all about it.

_Partitioning and eclipse attacks using BGP interception_

**Mike Schmidt**: Awesome.  Thanks for joining us.  We're going to go a little
bit out of order until we get ZmnSCPxj for the first news item.  So, we'll jump
to the second news item.  Cedarctic, you authored a Delving post titled,
"Eclipsing Bitcoin Nodes with BGP Interception Attacks".  In that post, you
outlined how an attacker could potentially eclipse Bitcoin nodes.  What did you
find?

**Constantine Doumanidis:** Yeah, so this is a particularly insidious attack.
It's quite targeted.  What we found out was that it is quite possible to eclipse
a single Bitcoin node that you target using BGP hijacks.  Previously, so just as
a bit of a quick background to what a BGP hijack does, is that it allows an
attacker to redirect traffic from one source to another destination, usually to
a specific destination, and route it through their own autonomous system,
through their own network, and then either forward it or keep it for themselves
and manipulate the connections this way.  Previously, BGP hijack attacks have
been used to partition Bitcoin, essentially just split the network in two, maybe
have two competing chains and also achieve other attacks, but they were not
really considered for eclipsing a Bitcoin node, because they're a very noisy
attack, it's something that can be observed by network monitors.  However,
recently researchers have figured out that there are ways to kind of make this
attack more stealthy and more targeted.  And these kind of BGP hijacks are known
as interception attacks.  And over the summer, I looked into how you can
potentially use these interception attacks in order to target a specific Bitcoin
node while also remaining stealthy.

What I found was that this can be successfully done for quite a few Bitcoin
nodes.  In particular, if I recall correctly from what I also wrote in the post,
around 42% of the IP prefixes that public-facing Bitcoin nodes currently exist
under are vulnerable to this.  So, regardless of where the attacker is in the
network, the attack can't succeed this way.  And also, even for the rest of
these prefixes, like the other 59%, these are not necessarily safe, because if
an attacker can position themselves favorably in the network, they can also
succeed in performing this attack.  So, essentially, once I as an attacker, for
instance, start this attack, I iteratively slowly go through all Bitcoin node
addresses, hijacking their prefixes, and eventually just settle on the prefixes
of the connections that a node has.  And then, at will, I can intercept all of
this traffic and either cut it or delay it, and kind of manipulate network
traffic that way.

**Mark Erhardt**: Let's briefly take a step back and look at BGP.  So, the
Border Gateway Protocol, you use this protocol to announce that you want to get
traffic for a certain IP address area, like an autonomous system, right?  So,
what does it mean to go over all the nodes and redirect them?  So, you're
basically saying, "Hey, if you have traffic for this IP, route it for me", or am
I understanding that right?

**Constantine Doumanidis**: That is a good question, yes.  So, you're right.
The BGP protocol, what it does is, it's the protocol that routers use to say
that, "Hey, I have this IP address and if anybody sends traffic to that IP
address, send it over to me".  So, let's say that, Murch, you're hosting a node
under Comcast.  Comcast would advertise your IP prefix so that when I want to
contact you, that traffic goes to you.  Now, the issue with BGP is that BGP, on
its inception, was unauthenticated.  So if, let's say, that I started announcing
the prefix for your IP, then other people might send the traffic that was
intended for you, they might send it over to me.  That is the basics of a BGP
hijack.  There have been security measures that have tried to compliment this
and fix these security holes, but these can still be exploited as outlined in
the Delving post.

**Mark Erhardt**: Thanks.  I'm not sure everybody has that background on BGP.
Okay, let's jump back in.  So, this attacker would stealthily redirect traffic
through themselves, and then at a later time, they could start intercepting
traffic for a specific node.  If all the traffic goes through you, basically
independently can decide to eclipse a node by just removing the messages that
you don't want to send.  What are the mitigations that you found?

**Constantine Doumanidis:** So, over the summer we looked into a few mitigations
that are also sketched out in the post.  So, one of them, the first, is to
actually rotate your peers, because as people who are familiar with Bitcoin's
P2P stack might know, is that once a node settles on a set of connections,
there's no reason for these connections to change, unless for some reason a node
goes offline.  What the attacker does in this attack is that they iterate
through these IP prefixes, because they don't essentially know who your peers
are.  So, they have to do this process to figure out who your peers are and then
intercept them.  Once they've intercepted them, they're good to go, you're
essentially eclipsed.  But it's very costly for the attacker to continuously be
doing this operation of going through all prefixes and hijacking them one by
one.  It's a very high-noise operation, which will eventually get them spotted.
So, by rotating your peers, you kind of prevent the attacker from settling on a
set of prefixes and being comfortable that they're capable of eclipsing you.
So, you have to keep them guessing, quite literally, and that's expensive for
them and high risk for them.  So, peer rotation could be an effective
countermeasure.

On the other hand, as also discussed by, I think Fabian brought it up in the
Delving forum, was that by doing this, you are potentially opening yourself up
to the classic eclipse attack, where you might be sampling your node table and
eventually settle on peers that are controlled by the adversary.  So, it's again
a bit of a trade-off.

**Mark Erhardt**: Right.  I would imagine that it would also help to be active
on multiple networks.  So, this attack would probably be in the clearnet on IPv4
or IPv6.  But if you have both IPv4 and IPv6, or maybe even Tor connections
additionally, that should help, right?

**Constantine Doumanidis:** Yes, most definitely.  So, a very good mitigation is
to be active on multiple networks, ideally also have Tor or I2P peers.  That
definitely makes the attack a bit harder.  Also, I think G Maxwell brought this
up, that a very good solution is to also multi-home your node.  So, if you have
two, let's say if you have a Comcast connection and also an AT&T connection, and
you have multiple physical networks that you can access, it's much harder for
the attacker to pin you down on both sides.  So, you always have an unaffected
route to the internet.

**Mark Erhardt**: Sure, common setup to have two internet connections at home!

**Constantine Doumanidis:** Yeah, there's also other countermeasures, for
instance dynamically negotiating port numbers that will make it bit harder for
the attacker to know if they're actually intercepting Bitcoin traffic,
especially if you're using the encrypted v2 transport.  There's also the idea
that you would want to prefer new peers that are under prefixes that are
protected by countermeasures, like ROA or RPKI, which essentially dictate who
can announce these prefixes.  It's not a perfect system, but it definitely does
help your chances of not being eclipsed.  And then, there's also other
countermeasures, like selecting peers that are very close to you physically, as
the attacker will have a harder time in competing with a legitimate route.  And
finally, something that is a bit more abstract maybe, but also complements
perhaps the efforts from the ASMap project, is selecting your peers based off
routing diversity.  So, let's say that you and I, Murch, have a path between our
two Bitcoin nodes, and I also have a very distinct path between myself and
Mike's node.  It's favorable because the attacker will have to consolidate these
two connections onto a common path, which is then more easily spottable.

**Mark Erhardt**: Yeah, that makes sense.  You briefly mentioned v2 transport.
Wouldn't v2 transport generally make it harder for peers to spot who you're
talking to or what you're talking about at least?

**Constantine Doumanidis:** For sure.  Again, plug for the v2 transport, it
should be used by default wherever possible.  V2 transport encrypts the
connection, so it definitely makes it harder to understand what data is being
transmitted.  So, an attacker that intercepts v2 traffic cannot see that traffic
per se, they cannot read in clear text.  However, so long as the attacker can
spot, let's say, the default Bitcoin port, they can kind of guess that this is
Bitcoin traffic.  But again, it does make it much harder on the attacker's end.
This was also brought up by Fabian.  I think it's a good thing to have.

**Mark Erhardt**: And just to be clear, of course, the v2 transport is encrypted
but not authenticated.  So, if the attacker watches the initial connection, they
can man-in-the-middle it.

**Constantine Doumanidis:** Yes, that is true.  I think Greg Maxwell brought up
that when we have countersign, that could also be solved potentially, since
we'll have a silent authentication, if you will, which will be great.

**Mark Erhardt**: Sure, sure.  The magically fabled countersign that we've been
all waiting for seven years or so.  That would be lovely if that picked up speed
again.

**Mike Schmidt**: Maybe just, we probably should have done this earlier, and
maybe you guys did and I missed it, but in terms of the outcome here being
eclipse attack, I think we've sort of thrown that out, but maybe just for
listeners, that's when your Bitcoin note is isolated from honest peers, and
you're really only connected to either one or more malicious peers that could
slow down propagation of blocks to you.  If you're broadcasting transactions,
obviously they could just hold those.  And obviously there's a whole slew.  If
you're than running an LN node on top of that Bitcoin node, there's a whole
other class of things that can happen to you that are bad if you're not
connected to the honest P2P network.

**Mark Erhardt**: Right, so an eclipse attack is basically the special case of a
sybil attack, sybil being a lot of duplicate nodes.  Eclipse means all of your
peers are controlled by a malicious entity, and the malicious entity
specifically can lie to you by omission.  They'll just not send you some of the
information, transactions or blocks, which can force you to either consider a
shorter chain that the attacker feeds you, or just not hear about unconfirmed
transactions or even confirmed transactions if they do not send you the latest
chain tip.

**Mike Schmidt**: Cedarctic, I'm a little bit curious.  You mentioned, I think,
that this work was done through Princeton and some of the research you've been
doing there.  Can you talk a little bit about how formal or informal this sort
of Bitcoin research work is there?

**Constantine Doumanidis**: Yeah, sure.  So, work on Bitcoin in academic circles
like Princeton, and especially with regards to routing attack, is quite active.
Some of the papers that have come out of such research, I've already also linked
on Delving, and I'm also happy to chat about those a bit more.  This work in
particular has been done in collaboration with Chaincode.  I was working with
the amazing people over there over the summer.  And potentially we're looking
into what further steps can be done, both in identifying any potential
vulnerabilities that can be exploited through routing attacks, and any similar
attack vectors on the network level to manipulate Bitcoin, and also looking into
solutions like, for instance, some of the countermeasures that I brought up,
like how do we evaluate them, how do we know that these cannot be gamed further,
and so on.  So, it is a very interesting topic and there's definitely many
people working on it.

**Mike Schmidt**: Thank you for taking the time and joining us today to explain
this research.  You're welcome to stay on.  We have other things we're going to
talk about, but obviously you're free to drop if you have other things you're
working on.

_Zero-knowledge proof of reserve tool_

We're going to move to the Changes to services and client software in deference
to our hopeful second guest, which we'll reference back to the first news item.
But in the meantime, "Zero-knowledge proof of reserve tool".  This is yet
another tool from Abdel from StarkWare, who's been doing a bunch of interesting
stuff recently.  I think last month, we covered a few different things that he
worked on as proof of concept.  This week, we cover zkpoor, which is
Zero-Knowledge Proof Of Outstanding Reserves.  This is a tool that lets users
prove that they hold some quantity of Bitcoin.  That's broadly known as proof of
reserves, "Hey, I have control over this pile of Bitcoin".  But with this tool,
users can actually prove that they can control those bitcoins, some quantity of
bitcoins, without actually revealing the individual bitcoin addresses or
individual UTXOs, which is pretty cool obviously from a privacy perspective.

This tool uses fancy STARK proof cryptography to do the proof of reserves, so
that's pretty interesting stuff there.  I didn't dig into that, that's not my
forte, but there is a live demo website and also set of slides for listeners to
check out if you're interested in pursuing more.

_Alternative submarine swap protocol proof of concept_

And our second and last ecosystem software highlight is, "Alternative submarine
swap protocol for --" it's a proof of concept in this case.  And as a reminder,
submarine swap is this idea of swapping offchain or LN bitcoins for onchain
bitcoins in a sort of atomic way.  They already exist, submarine swaps are out
there.  They use HTLCs (Hash Time Locked Contracts) and they use two
transactions, but this Papa Swap proof of concept actually just uses one
transaction.  So, you can imagine that saves on speed, it's a little bit faster,
saves on fees.  It also uses taproot.  I think maybe some of the other protocols
use just segwit v0, so it could save on fees even more that way.  I would stress
that this is a proof of concept.  So, if you're an engineer kind of person or
someone who likes to tinker, take a look at it.  If you're someone looking to
actively do these swaps in large quantities, this is a proof of concept.  I
think there're still being discussions about it.  So, please proceed as if it is
a proof of concept.  Excellent.

**Mark Erhardt**: So, it sounds like ZmnSCPxj is here now.

**Mike Schmidt**: Great, thanks Murch.  Okay, we're going to jump back up to the
News section.  First, ZmnSCPxj, why don't you introduce yourself and then I'll
introduce this news item and you can take it from there?

**ZmnSCPxj**: Hi, I'm ZmnSCPxj, I'm just some random guy from the internet.
Actually, I am an indie game dev developer who got suckered into buying
bitcoins.  And apparently, thinking about how to exploit game rules maps very
well to thinking about how to exploit protocols.

**Mike Schmidt**: I actually didn't know that you were previously a game
developer, so that's a new piece of information for me.

**ZmnSCPxj**: No, I'm just a wannabe indie game dev.  I haven't even released
anything, man, come on.

_LSP-funded redundant overpayments_

**Mike Schmidt**: Lightning is a big game in itself.  Well, the news item is,
"LSP-funded redundant overpayments", that's what we titled it in the newsletter
this week.  ZmnSCPxj, you posted to Delving.  The post was actually titled,
"MultiChannel and MultiPTLC: Towards a Global High-Availability
Consistent/Partition-Tolerant Database for Bitcoin Payments".  That is very much
a ZmnSCPxj-titled post.  I wrote a little elevator pitch, I wasn't sure if you
were going to be joining us, but why don't you give the high-level one, what is
being achieved here, and then we can get into the how?

**ZmnSCPxj**: Okay, let's say you're an ordinary LN user.  You have an LN wallet
and that LN wallet connects to one LSP.  The LSP goes down.  How are you going
to receive payments?  How are you going to send payments?  So, maybe you can use
a more sophisticated wallet, one that allows you to have multiple channels to
different LSPs.  But now, you have an issue here that your funds are split up
into smaller pieces, which is supposed to be fixed by multipath payments, but
nobody has a decent multipath implementation.  Maybe CLN (Core Lightning), but
it's probably over-engineered and probably doesn't do what you want anyway.  And
that's multiple channels, that's multiple UTXOs that you're keeping in the UTXO
set.  It's not ideal, right?

**Mark Erhardt**: Yeah, my understanding is that when you try to settle payments
through multipath, of course you get many smaller payments, which are easier to
route through all the channels.  But of course, you have way more things that
all need to work, so some of them will fail.  And I think that's where your
stuff comes in, right?

**ZmnSCPxj**: Well, that's one of the things, yes, of course.  So, the insight
here is that basically I was looking into YugabyteDB, which is a
high-availability, consistent-partition-tolerant database.  And then, I realized
that there's a common trend among these high-availability CP databases, which is
basically that all of them tell you, you need to have at least three nodes in
this database.  And that's when I realized that what you actually do with the
current LN Poon-Dryja thing is that you actually have a synchronous replication
scheme, where you are the master of the transaction that is on the other side,
the unilateral closed transaction of your counterparty.  So, you're the master
of that and then you replicate it there.  And then they say, "Okay, I've got it
on my end.  I want you to replicate it on your copy, on your side".  So, that's
a synchronous replication thing.  But the synchronous replication thing, there's
a master, there's a slave.  If one of them goes down, the other can't continue,
and that's also part of the signing thing on the backing channel.  It's a
2-of-2; any changes to the channel need both of them to be live.  And that's
part of the issue of why it's a CP database.  It's
consistent-partition-tolerant, but it's not high availability.

So, that's just one problem in that the thing is, this channel is a local
entity.  It's between you and your counterparty.  Now, how we are able to
leverage this basic, consistent-partition-tolerant database into a global one is
to create HTLCs.  And those HTLCs are basically row-level locks on an amount of
coin.  And they have a condition where you can roll it back, which is basically
failing this payment; or you can commit it, and that commit is conditional on
receiving a preimage from your counterparty.  So, it's already a row-level lock
on some amount of coin.  And then, because we have multiple row-level locks on
different local databases, we are able to then achieve this consistency and
partition-tolerance across the globe, into the global space, not just local CP.
We have global CP, right?

So, that's how I started thinking about it.  And then I realized that again, if
there is, for example, this chain of locks that you are doing, this payment that
is ongoing, and then one of the nodes along the way has to drop, shuts down, it
falls, whatever, then the lock chain has to be kept until it goes back up or
until the timeouts trigger and people have to start unilaterally closing their
channels.  And that's not good for the end user, because if you're sending and
then suddenly one of the nodes along the pack, you happen to have it sent out,
drops, then you have this stop payment that's going to be staying on your
channel for potentially up to two weeks.  And that's again, another availability
issue.  You want your funds to be available on that.

So, those are two related issues that reduce the availability of LN in practice.
That's why we can say that it is a consistent-partition-tolerant database, and
you can even say that it's global in practice because of these HTLC locks, but
it's not high availability.  There are times when you can't pay because your LSP
is down, because there's a vulnerability, there's a CVE somewhere and they have
to shut down and upgrade everything.  Or maybe they just need to upgrade because
there's new tools, like what's new on LN anyway?  Stuff on LN, new stuff, right?

**Mark Erhardt**: Right, so setting up multipath payments, some nodes that are
on the routes could become unavailable…

**ZmnSCPxj**: And that impedes also your ability to recover your funds.

**Mark Erhardt**: Right, and it might get your funds stuck.  So, I think you are
using stuckless payments and you're introducing redundancy somewhere.  Do you
want to tell us about the redundancy?

**ZmnSCPxj**: Okay, so I'm assuming that you know that stuckless is not actually
stuckless.  It just happens to be the name of the protocol, but it's not
stockless.  It does get stuck.  It's just that it's okay to get stuck in
parallel, because in the current scheme we have with HTLCs, if the lock gets
stuck, it's not safe for you to send another payment.  With stuckless, which is
stuckless by name only, it's safe for you, even if one payment is stuck, to send
out multiple parallel payments.  And of course, you can still do that with any
scheme.  But the problem still is that if one of those payments does get stuck,
the money that's in there is still locked up.  So, stuckless is not truly
stuckless.  It's more like parallel stuck is okay now.

**Mark Erhardt**: Right, you can overpay and they can only collect as much as
you were intending to pay them.  But if something is stuck along the way, the
payment goes through, you can even add more attempts to make more funds
available.  You're not stuck in the sense that the payment process can proceed,
but your funds could still be stuck, or not all of them, just a portion
probably.

**ZmnSCPxj**: Yeah.  But basically, the issue still here is that there are still
some funds that get stopped and it's not a good UX, it's not a good user
experience.  Like, okay, maybe you can lie in your user interface and say,
"Yeah, the payment went through", and you just silently hope that this stuck
payment gets returned before the user actually says, "I want to send all of my
funds to my cold storage", and now you're dead because you lied to them and you
didn't admit that you had some funds that were stuck.  And now, they can't send
this out and they're going to have lots of big issues like, "Hey this wallet
says it's, blah blah blah, and it doesn't spend my money, blah blah blah", then
that's a big issue.

Okay, so first, we have this base thing called multichannel, which allows a
single client to have a single construction that connects to multiple LSPs
simultaneously.  And the only drawback here is that the LSPs need to kind of
trust a quorum of the LSPs, right?  So, it's not the user that has to trust the
LSPs, it is the LSPs who have to trust each other.  And the LSPs also don't have
to trust the user.  Well, at least they don't have to trust the user for fund
safety.  The user can still always do channel-jamming and that sort of attack on
those LSPs.  But at least for fund safety, they can just force you to hold but
they can't make you lose money.  So, it can be your channel jammed which forces
you to hold your funds, but it doesn't actually steal your money.

**Mark Erhardt**: So, what do the LSPs trust each other for, because that sounds
like a bigger drawback?

**ZmnSCPxj**: Okay, so the reason why they have to trust each other is because
they are signing using a k-of-n, so that even if some of them are down, the user
can still send out payments on the LSPs that are up, and they can still receive
payments via the LSPs that are still up.  So, that's the reason why we have this
k-of-n reduction of the security of the LSPs.  So, that's the first design I
showed there, was basically a sketch for a Poon-Dryja-based multichannel.  And I
also sent over another link, which reduces the trust a little bit in the sense
that, okay, with the previous proposal, we have this k-of-n that protects the
funds, the liquidity, the inbound liquidity coming from the LSPs to the user.
And now, with this alternate construction, which is based on top of
Decker-Wattenhofer, we can reduce the trust so that the LSPs don't have to trust
the main inbound liquidity, but they do have to trust the funds that were
already sent by the user to them.

So, the hope here is that this is a smaller trust issue, because the individual
payments are smaller in amount and we can time-box those so that periodically we
can clean up those issues, so that the funds are moved to the more secure scheme
where the LSP protects its own money without having to trust the k-of-n of the
other LSPs.  So, that's a smaller trust requirement on the LSPs.

**Mark Erhardt**: It sounds like a construction similar to the channel factories
would make this potentially completely safe if there were multiple virtual
channels between the user and the LSPs.  And then, you could use and update just
any of them while one of the LSPs is down.  Of course, we expect LSPs to
generally have better availability than, say, end user nodes on mobile phones.

**ZmnSCPxj**: Yes, definitely.  So, that's part of the design, is that the
assumption is that the LSPs have high uptime.  However, if they find a
vulnerability in their software, they have to go down because they are putting a
lot of funds in a hot wallet that is permanently online.  So, there will
definitely be times that they have to go down.  So, the user is probably the
opposite, in that most of the time they are offline, and then when they actually
say, "Look, there's a shop that supports Lightning payments.  I should go there
and buy stuff", that they need to be online and they have to do the payment
while they are online.  So, our goal here is that we want to let the LSP to go
down, or at least one of them to go down or less than half of them to go down
simultaneously, so that the user can still send whenever the user needs it; and
also to allow the LSP to go down when they need it to protect their own money.

**Mark Erhardt**: Right.  So, it sounds like you're extending the idea of
stuckless payments, which you said is misnamed, but to make it so that you have
perfect availability for the end user by introducing a shared scheme for the
LSPs to sort of provide service as a conglomerate, or a quorum, rather than
individual LSPs.  Do I get the drift right?

**ZmnSCPxj**: Yes, that is an acceptable summary of the thing.

**Mike Schmidt**: I have an even more pleb, maybe unacceptable summary.  You
mentioned you are or were an aspiring game developer.  I was a web developer in
my past life.  And is it safe to say this is something like a load balancer for
LSPs, where instead of using one LSP that has these concerns that you outlined,
you sort of balance your usage between several LSPs, and that your protocol is
the thing that sort of --

**ZmnSCPxj**: I think it's more apt to say it's like automatic failover rather
than load balancing.

**Mike Schmidt**: Okay, that makes sense.

**ZmnSCPxj**: So, okay, so these are two parts.  Like I said, I identified two
issues that cause low availability, and one is the local database, the channel
itself, which is two party.  And because it's only two party, it can't do
updates if one of them is down.  Because if you do updates, that would then
violate the CP, the consistency requirements.  And as much as possible, we want
to have the consistency really nailed down because this is money, man, come on.
And the other part is that a remote node can go down while you have an HTLC
going out, and that's the second issue, that's the second availability issue.
So, the full solution requires both of these to be solved in practice.  So, the
multichannel that I described is basically solving the local availability issue.
But now we have the global availability issue, and what I'm proposing is that
the LSPs should probe on the behalf of the user.

Okay, so my initial proposal was to use a multi-PTLC (Point Time Locked
Contract).  But actually, in practice, if you look at the custodians currently
running custodial wallets, what they do is that they send a probe payment out
and then they keep sending probe payments on behalf of their users in order to
have a path that they are kind of sure is working.  And while it's true that
there is a TOCTOU there's a time-of-check versus time-of-update issue here, it
can be pretty small in practice, so that if 100 milliseconds ago this path
worked, it's very likely that it will still work now, right?

**Mark Erhardt**: Yeah, and then generally LSPs will be participating in so many
more payments that they will generally have a pretty good latest state of the
network even before probing.  So, they're just backfilling the little specific
path that they might want to use, and are already corroborating that with a lot
of other data they have.

**ZmnSCPxj**: Yes.  So, that's a thing.  What we can actually do is to have the
LSPs send out HTLCs to the destination that the user expects.  And we can do
this even if the user is not a custodial user, actually.  We can just add this
service as an additional request from a non-custodial user to a big LSP node.
It's something that you can actually implement now, as opposed to my multi-PTLC
proposal, which requires not just PTLCs, but also a stuckless payments actual
protocol, and it requires specific things from that stuckless payments protocol.
Like, it requires that there is a nonce that the receiver shows in order to
request the receiver-can-claim scaler and to also be able to give an address or
a location on the network that is different from the actual sender in this case.
So, the multi-PTLC, you can probably say it's a bit over-engineered and a
practical solution is simply to have this HTLC probing be done by the LSPs on
behalf of the user.

If you want, we can still discuss multi-PTLCs.  It's an interesting bit.  For
example, if the LSPs find multiple viable paths to the receiver, you can still
provide a multi-PTLC that also sends along all of those paths, and you just let
the LSPs compete on who gets to the receiver first, and that's something we can
also discuss.  But basically, if you just want something that you can implement
reasonably soon, then what we probably should do is just this allowing the
client to ask the LSP, "Hey, can you probe this receiver for me?"  Like, you can
even do source routing there by just giving them the onion and then they just
try to send it out.  Though obviously, if they are giving them the onion, the
LSP can't get insights on how good the various paths are because they just have
the onion.  But at least that gives privacy to the user, because it doesn't also
reveal to the LSP who the user is paying to.

**Mark Erhardt**: Right, but then there's the general issue of how much an
intermittently-online node knows about the network, right?  So, I think that LDK
had a synchronization mechanism to quickly get a download on some of the latest,
the rapid gossip sync.  I am not sure how other LSP implementations would handle
this. So, I think most LSPs actually route for their clients, and then this
would mean zero privacy reduction compared to that.  Of course, if the LSP
doesn't route for you, asking them to do a probe for you would not help.

**ZmnSCPxj**: Well, you can always give them the onions to probe.  You don't
actually need to give them the actual destination.  It's just that if you give
them onions to probe, they don't really have any insights on which remote nodes,
they can't really give you that insight that, "Hey, that remote node isn't
really good".  Just they don't know that they're going through that remote node
anyway.

**Mark Erhardt**: Right.

**Mike Schmidt**: Well, ZmnSCPxj, I think we covered this pretty well.  It
sounds like there's other things that we could talk about perhaps in the future,
and maybe there'll be further posting on that on Delving.  For folks that are
listening along and interested in this and want to go deeper, check out the
Delving post and the dialogue there.  I'm sure ZmnSCPxj would welcome feedback
to the proposal as well.  Anything else, ZmnSCPxj?

**ZmnSCPxj**: Yeah, that's it.  Anyway, I have to go soon.

**Mike Schmidt**: All right, yeah, you're free to drop, but we'll move on with
the newsletter.  Thank you for your time again.  Cheers.

**ZmnSCPxj**: Okay, bye.

_Bitcoin Core 30.0rc1_

**Mike Schmidt**: Cheers.**  **Moving to the Releases and release candidates
segment, this week it might be a little beefier than previous weeks.  We are
going to do the Bitcoin Core v30.0rc1 deep dive. Master educator, Bitcoin Core
developer, Murch.  Murch, we punted on it last week.  It's time.  What's in this
release?

**Mark Erhardt**: Yeah, there's a bunch of stuff.  So, generally, maybe we'll
talk a sentence or two about process in Bitcoin Core, as I think has been a
topic lately again.  There is not actually a hierarchy in Bitcoin Core where
someone sets goals and assigns tasks or anything like that.  Bitcoin Core is a
loosely-organized group of people that happen to be interested in contributing
to a shared project.  Many people simply work on new things that they find
interesting, other people tend to work more on the things that they find
interesting and important.  So, whatever makes it in before the feature freeze
is in a release.  After the feature freeze, no new features get added to the
release branch.  There's a branch-off and the release gets tested and bug fixes
get added to the release branch, if there's anything found on the features to be
released.  And other than that, whatever is ready to go goes out in a release.
So, it's not like, "We'll ship this feature in the next version", and then
everybody works on it.  No, the people decide what they work on.  So, this is
just for context.

Let's look a little bit at what is in the release.  So, very notably, there are
a few policy changes.  I don't know, I think we've covered most of them pretty
well already.  There is the policy change that prepares for the great consensus
cleanup, which forbids legacy transactions that have more than 2,500 signature
operations, forbids in the sense that we will not admit them to our mempool.
They are still consensus-valid, but the great consensus cleanup is trying to
make them consensus-invalid.  This is an odd construction that wouldn't usually
appear in transactions and is concerning, because you can use it to create
transactions that are very heavy to validate.  I think we've talked plenty about
data carrier size.  But just to recap, if people are not in the loop, the data
carrier size policy by default has been increased to 100,000 bytes, or will be
in the release.  We're on, I think, RC2 now, right?

**Mike Schmidt**: I think that may have been very recently, if it is.

**Mark Erhardt**: Well, RC1 or 2.  So, data carrier size regulates the size of
OP_RETURN outputs that a node will permit in its mempool.  That was previously
limited to 83 bytes and is now limited to 100,000 bytes, which means that the
transaction size is the upper limit for OP_RETURNS.  Do you want me to talk
about why that happened at all?

**Mike Schmidt**: Yeah, give a headline.  We don't need to go too deep if you
don't want to.

**Mark Erhardt**: Well, as many people should be aware, there has been some data
transactions on the Bitcoin Network lately, and specifically the inscription
construction, which puts data in an unexecuted scriptpath.  A leaf script in
taproot allows you to put 400,000 bytes.  So, having 100,000 bytes in an
OP_RETURN is strictly less than that, and it's not attractive to use OP_RETURN
for data, because the inscription data is part of the witness stack and the
witness stack is discounted by segwit by a factor 4, whereas OP_RETURN outputs
are in the output data and output data is not discounted.  So, for every byte
that you are trying to embed into a Bitcoin transaction, putting it into an
OP_RETURN output is 4x more expensive than putting it in the witness stack.
There's a little bit of an overhead with inscriptions, because you have to make
an output first that then gets spent where you reveal the data that you wanted
to embed in the input.  So, it works out that at around, I think 160 bytes,
inscriptions become cheaper for data.

So, it seemed there were some examples found in the wild.  Both there's a
protocol where people are trying to create another colored-coin scheme with
OP_RETURNs and payment data outputs.  And there was famously the Citrea example,
where they wanted to embed more than 80 bytes and they would put the first 80
bytes in an OP_RETURN and then the rest of them in payment outputs.  So, the
observation is putting data in payment outputs is the worst method out of the
three.  And it is preferable, if people were going to put data in outputs, if
they just put it in OP_RETURN.  OP_RETURNs are slightly cheaper than payment
outputs.  Inscriptions are still cheaper for bigger data.  So, it is unlikely
that people who are using inscriptions for data right now will move to
OP_RETURN, but people that would have instead stuffed them into payment outputs,
that live in the UTXO set forever, would be more likely to put them into
OP_RETURN outputs if that were standard, aka accepted into mempools and
propagated among nodes.

So, we had a little bit of a hiccup, I think it's a couple months ago now, when
there was a discussion of whether OP_RETURN outputs that are bigger get accepted
into blocks or not.  And some people created some OP_RETURN outputs and we had,
I think it was 30,000 OP_RETURN outputs in a week that were bigger than the
limit.  So, it seems like there's already miners accepting these and overall,
with people working on schemes that might put more data in payment outputs, it
seems preferable to have a dedicated garbage bin where this stuff can go,
instead of forcing them to use payment outputs simply for the payment outputs to
OP_RETURN data trade-off.

**Mike Schmidt**: Which of course is not an endorsement.  Almost nobody wants
this.  All those sort of caveats, this is just strictly speaking in the
technicals.

**Mark Erhardt**: Yeah, exactly.  I mean, just full disclosure, I've never owned
an inscription, I've never been interested in that.  I just would prefer that
people put stuff in OP_RETURN outputs over payment outputs.  And I also haven't
received any money for this, as some people have suggested.  It's just Bitcoin
transactions are a form of data that is being sent around.  We specifically want
this data to be used for payments, but there are many fields in Bitcoin
transactions that can be used to embed data and we can't control and prevent
this.  So, with recently the last two years, a renewed interest of people
putting data on Bitcoin because Bitcoin is a very successful payment network and
a global network, and so it's more attractive to have their crap on Bitcoin than
on other networks, it seems unlikely that we will be able to fully prevent this.
And if they continue doing it and don't have enough space the way we currently
permit, they may bloat the UTXO set further with unspendable UTXOs.  While we
have a huge UTXO set growth right now, I believe that most of those UTXOs are,
in principle, spendable, whereas writing data to payment outputs is, in
principle, completely unspendable.

Anyway, if there is a very mixed mempool policy on the network, the problem with
that is that it reduces the fairness of mining.  Optimally, we'd like mining to
be as fair as possible.  Just, if something happens on a network, some people
don't include transactions, it is necessary for censorship-resistance that
people can just get some ASICs, start mining at home and include those
transactions.  And we do want transactions to generally be available on the
mempools for anyone to stand up and start mining.  If we instead go and start
restricting who we show transactions to in the beginning, or build out tools to
hand transactions out-of-band to miners that will include them, this is a
slippery slope to the mempool not working for miners as a source of information
and reducing our censorship-resistance.  So, a lot of ink has been spilled on
this in the past few months already, but the decision was basically, we would
expect hopefully OP_RETURN to be preferred over putting data in payment outputs.
We would not really expect OP_RETURN to be preferred over inscriptions.  People
are doing inscriptions already, and it seems unlikely to be able to squash that
without a consensus change.  And consensus changes are pretty slow and
heavy-handed to squash a protocol that spent something along the lines of 30% of
all fees in the last two years, maybe more.

So, yeah, that's where we're at.  I haven't practised this.  I hope I said some
good stuff here!

**Mike Schmidt**: Yeah, that was good.  A little bit more in depth than just an
overview, but probably something that folks are curious about.

**Mark Erhardt**: Well, anyway, so given that data carrier transactions already
propagate on the network and get included and the default has been increased to
100,000, people felt that would be a bit disingenuous to not deprecate this
setting to set it lower.  But that's currently being reviewed, right, Mike?

**Mike Schmidt**: Indeed.  No comment.

**Mark Erhardt**: Okay, anyway.  The second change to OP_RETURN is that instead
of just allowing a single OP_RETURN output, Bitcoin Core 30.0 will allow
multiple data carrier outputs.  The sum of the output scripts is what is limited
by the data carrier size configuration option.  So, if you choose to set data
carrier size to 83 bytes, it will behave very similar to before, in that it
limits the overall output scripts to 83 bytes, but they might be split across
more than one OP_RETURN output.

The other big thing we saw was the sub-1-sat/vB (satoshi per virtual byte)
summer, where suddenly some miners decided to accept transactions below their
previously stable minimum relay transaction feerate of 1 sat/vB.  So, with
thousands, well, with I think lately up to 80% of transactions in blocks being
below 1 sat/vB, Bitcoin Core 30.0, like 29.1, will propagate transactions paying
0.1 sat/vB.  So, this is a 10x reduction in the minimum feerate.  Corresponding,
the incremental relay fee is also reduced by a factor 10, because it doesn't
make sense to allow a first transaction to be sent at 0.1 sat/vB and then to
require the replacement to pay 1 sat/vB; 10x to replace the same amount of data.
So, both of these are lowered together.  Okay, that was the policy section.  I
have six more sections.  Do we have enough time for this, Mike?

**Mike Schmidt**: Yeah, let's do it.

**Mark Erhardt**: To be honest, most of the other sections are probably not
long.  So, let's look at P2P and network changes.  There is an improvement to
the opportunistic 1p1c (one-parent-one-child) package relay.  Previously, we
would literally only accept two transaction packages when they were offered.
Now, if there is other transactions in the cluster of the 1p1c, we also accept
it.  So, for example, if a grandparent transaction is already in the mempool and
now we get offered parent and child, we will be able to accept that into our
mempools.  Same if there's multiple parents and the other parents are already in
our mempool, and now we receive one parent and one child, we will be able to
process these and accept them into our mempool.  You can also, if you have any
questions or comments, jump in.

**Mike Schmidt**: Okay, yeah, I was trying let you do your thing.  But, I have a
few things I made notes on that I want to make sure we cover, but I'm going to
let you do your thing for now.

**Mark Erhardt**: Okay.  Well, just let me know if you have something.  The
orphanage was re-architected.  Previously, the transaction orphanage, where we
keep transactions for which we don't know the parents, was limited to simply 100
transactions.  With the opportunistic 1p1c package relay, we anticipate that the
orphanage will be used more.  So, it was changed to have limits per peer in
order to prevent that we throw away useful data.  We now track every
announcement from our peers of orphan transactions by the entries of the wtxid
and the peer that sent it to us.  So, basically, when multiple peers tell us
about a transaction, we will have multiple entries for that, just remembering
who announced stuff for us.  And if any one peer floods us with stuff, we will
just simply start by removing their announcements, not their transactions.  So,
if other people announced the same transactions to us, they remain in our
orphanage.

This is a drastic improvement over the previous approach where we simply had a
first in, first out orphanage with 100 entries.  So, if someone spammed us, we
would just cycle through it and lose those orphans.  Now we would just cycle
through the spammer's entries.  So, the announcements would get deleted, but if
other people also send us the same announcements, we would keep the
transactions.  So, the overall orphanage has now a limit of 404,000 weight units
per peer, and this can be filled by any peer, but it's limited by the total
number.  And if there's too much stuff, we keep 100 announcements per peer I
think at most.

**Mike Schmidt**: And I'll point listeners as well, if you're curious about the
orphanage discussion, we did cover a few different PRs in the newsletter, which
I'll let you find on your own.  But we also had Gloria on twice for
orphanage-related discussion.  One was in our show, #362 Recap, where there was
a Bitcoin Core PR Review Club on the topic.  And then, the second one was when
Gloria co-hosted with me for #366, and one of the notable PRs was around the
orphanage as well.  So, check into that if you're curious about the orphanage
discussion.

**Mark Erhardt**: Actually, let me correct myself right away.  I don't think
there's a 100-transaction limit per peer.  There's a global limit now that the
total number of entries plus unique transaction inputs is limited, and we allow
anyone to add to the global data.  But then, when we have to remove stuff
because we have too much, I think we start with the peer that has the most
entries.  In conjunction with that, maxorphantx configuration option no longer
works, because we don't really have a simple number of limits for the orphanage.
Okay.  There's also, if people want to follow along on this, there is a draft in
the Bitcoin-Dev wiki on Bitcoin Core and GitHub where you can see all the
release notes in detail before the release.

**Mike Schmidt**: Murch, is there a draft of a testing guide at all for this
release, do you know?

**Mark Erhardt**: I have not seen one yet, but maybe I was just unobservant.

**Mike Schmidt**: Yeah, I haven't seen it either.  But for listeners, I think
we've promoted going through those guides in the past and also testing things on
your own and providing feedback.  It sort of gives a little blueprint for how
you might test certain features, especially some of these ones that Murch is
outlining.  Given that this is a decentralized project, it's quite possible that
no one's picked that up for this particular release, and it's also possible that
Murch and I just aren't aware of it.  So, if we find it, we'll talk about it.

**Mark Erhardt**: I think I saw someone volunteer to do it.  I just haven't
seen.  Maybe there is a testing guide.  I haven't seen the announcement though.
All right.  We've talked a bunch about multiprocess in the past.  The idea is to
be able to run separate parts of the Bitcoin Core binary in, well, separate
processes.  And in conjunction with this, we introduce a new Bitcoin command on
the command line.  Instead of calling bitcoind, you can now also use a synonym,
which is “bitcoin node”.  To start Bitcoin-Qt, you can instead also call
“bitcoin gui”.  And if you want to use bitcoin-cli-named, you can use “bitcoin
rpc” instead.  And I'll talk about the IPC mining interface in conjunction with
this right away.

So, one of the things that goes hand in hand with the multiprocess splitting-up
of the binary is that we now surface an inter-process communication interface,
IPC mining interface.  This is one of the applications of this new Bitcoin
command.  You can start it with the ipcbind=unix.  You can start the node with
that.  And this will make a Unix socket that you can use with Stratum v2 nodes
to request block templates and you can submit mined blocks.  This is in
conjunction with the Stratum v2 support.  So, if you run a regular Bitcoin Core
30.0, you can start it in this mode and then you can have your Stratum v2
software pull for new block templates through this IPC, and if you find a block,
submit it.

**Mike Schmidt**: Nothing to add there.  I think you emphasized that this is
motivated by specifically the Stratum v2 initiative.

**Mark Erhardt**: Yeah, and this is very experimental, just to be clear.  But
the background was this was in the works.  Sjors has been working on this for a
while.  People were requesting that it be in this release, so they could run it
against a regular Bitcoin Core release instead of Sjors' private development
branch.  So, this is I think a solid step forward to rolling out Stratum v2
support eventually.

**Mike Schmidt**: And this is also sort of this idea of multiple binaries.
Multiprocess has been in the works for, like, a decade.  So, while Murch is
rightfully pointing out that this is sort of the first potentially experimental
version of it, it's actually been a long-running project.  So, it's good to even
see it in that state at this point.

**Mark Erhardt**: Right.  There's a change with external signing.  External
signing on Windows has been re-enabled.  So, if you want to use your hardware
signer with Bitcoin Core on Windows, that should work in 30.0.  All right.  I
skip over install changes, I think that's not super-interesting.  I also skip
over indexes.  There is a bug fix or an attack-vector fix for logging.  If you
have a lot of logging, it's limited now and it suppresses excessive logging and
puts in a message of how much logging was skipped.

Talking about RPCs next.  The paytxfee startup option, and settxfee RPC, they
both allowed you to set a standard feerate that you use for all of your
transactions in the very dynamic fee environments we've had in the past few
years.  That was removed now.  If you want to force your feerate to be a
specific feerate for a transaction, please use the fee_rate argument on
fundrawtransaction, sendtoaddress, send, sendall and sendmany.  Yeah,
deprecated; will be removed in the next.  So, it still works in this one.

What else do I have here?  The PSBT bump fee and bump fee.  RPCs now allow
full-RBF replacement.  So, where previously you did have to signal BIP125 in
order to replace a transaction, we now also allow replacement of all
transactions per these RPCs.  And there is a new /rest/api/endpoint,
/rest/spenttxouts/BLOCKHASH that returns spent tx outs from the undo data, so
for every block we have an undo data, if we have to roll back in order to, for
example, reorganize to a better chain tip; and we can read that out to see which
UTXOs were spent.  And you can get all spent txos for a specific block by the
blockhash from this new /rest/api/endpoint.  There is also waitfornewblock,
waitforblock, and waitforblockheight RPCs that have been unhidden.  They were
present previously, but hidden.  These are also interesting in the context of
Stratum v2.  All right.

**Mike Schmidt**: You need a half-time show?

**Mark Erhardt**: Half-time show, yeah!  On build system stuff, maxmempool and
dbcache are now capped for 32-bit systems.  32-bit systems have generally a
limit on how much RAM they can have.  So, maxmempool is now limited to 500 MB
and dbcache is limited to 1 GB.  The NAT-PMP option is enabled by default now.
This is a mechanism, or a feature, that will punch a connection through routers
that permit it.  The UPnP option that previously existed has been removed fully
now after being deprecated before.  There were several security issues with that
before.  NAT-PMP is a self-written, homegrown replacement that is now on by
default in Bitcoin Core 30.0.  So, if you previously had issues getting your
node to listen on the network, maybe it'll work now with this new release.

**Mike Schmidt**: Most routers don't support it out of the box, right?  They
don't default have that setting on, but you can if you turn it on in your
router, then your Bitcoin Core node will, by default, start allowing those
connections.

**Mark Erhardt**: Right, so if your node was previously a listening node and now
it doesn't work, maybe check your router settings.  But also, very possible that
previously it didn't work and now it'll work, because we changed the mechanism
by which we open ports for listening.  Okay, wallet.  There's a lot of changes
in the wallet this time because the legacy wallet has been fully removed now.
This is a five-year project, or so.  We've talked a bunch about descriptors,
output script descriptors, and wallet descriptors, all the same thing.  But the
descriptor wallet was introduced some, I think, five years ago.  And this new
version will be the first version where you cannot create or load the legacy
wallets that were reliant on Berkeley DB.  One thing in this context is Berkeley
DB had been unmaintained for 12 years or something, and it's high time that we
get rid of it.  Descriptors are generally also more powerful in their backup
capability than xpubs.  So, this is just a better wallet throughout.  You cannot
load or create the legacy wallets anymore with Bitcoin Core 30, but you can
migrate them to descriptor wallet format.  Please check out the migratewallet
RPC if you want to do that.  I think it also works in the GUI.

So, because the legacy wallet is removed, there is a bunch of options for the
Bitcoin wallet that have been removed because they were only for the legacy
wallet.  For example, importaddress, importmulti, importprivkey, dumpprivkey,
and so forth, don't work anymore.  Where it is sensible, there are replacements
with importdescriptor, and so forth.  And yes, you can absolutely import a
single private key as a descriptor.

**Mike Schmidt**: I saw that on the internet earlier.

**Mark Erhardt**: Yeah, I saw some people complain that they can't.  So, that's
why I'm saying it.  Yes, you can import private keys.  You just have to use the
descriptor instead.

**Mike Schmidt**: Well, in the migration project more broadly, this is one of
those, I mentioned the ten-year project, this is a five-year project that's
finally wrapping up.  And I know Optech and Murch, you've pointed this out to
people, but make sure that, listeners, you know and that the projects you're
working on know that this is going away.  Now, the wallet is not going away,
right?  It's the legacy wallet that is going away.  There's migration features.
It probably won't be a ton of work, but if you are relying on a certain legacy,
aspects of the legacy wallet, then you should look into putting tooling towards
migrating, so that in the future you can continue to use Bitcoin Core's wallet.
So, for folks who aren't aware, please raise that attention, because I saw some
people that were sort of caught off guard with that.

**Mark Erhardt**: Well, to be fair, it had been deprecated for several versions.
So, the deprecation warning is specifically to make people aware that it is in
the process of being removed.  The big upside is a lot of the very complicated
old wallet code could be removed now.  We have a clean separation of watch-only
wallets and non-watch-only wallets.  Either you have private keys or you don't
in a wallet.  A lot of the handling of where we didn't know whether it was watch
only or we could spend it became a lot simpler.  So, a lot of the wallet code is
much simpler and better now.

**Mike Schmidt**: And Berkeley as a dependency is gone as well.

**Mark Erhardt**: Correct, the Berkeley DB dependency is finally gone.  So,
yeah, I already jumped into this a little bit.  Yeah, includewatchonly has been
removed because wallets are now either watch-only or non-watch-only.  Yeah, and
there-is-watch-only field is also removed because it doesn't make sense anymore.
Additionally, we now support TRUC (Topologically Restricted Until Confirmation)
transactions in the wallet so we can create v3 transactions.  This creating of
transactions will respect the TRUC parameters, so you can't have more than one
unconfirmed parent, you have to be within the limit of the sizes that are
permitted to be a standard transaction, and it will automatically notice if
you're trying to spend v2 inputs for every v3 transaction, which is only allowed
if they're confirmed.  Unconfirmed, it doesn't work.  So, coin selection for
that has been updated.  It'll just behave as the TRUC BIP describes.  And yeah,
the version parameter is now available for a bunch of the transaction creation
RPCs, createrawtransaction, createpsbt, send, sendall and walletcreatefundedpsbt
now have a version parameter that allows you to set v1, v2 or v3.

**Mike Schmidt**: I'll let you catch your breath a second and just interlude.
Murch mentioned, I think last week, "Hey, if it seems like there's more in this
release, part of that is because of the just timing of the releases".  I think
maybe there was something like five months between the previous release and the
release before it, whereas this release and 29 had something like maybe seven
months in between it.  So, there's some things that got bumped into this
release, and obviously there's more time then too that resulted in a bigger
Murch monologue than the normal for the release.

**Mark Erhardt**: Yeah.  On the GUI front, the GUI has been migrated from Qt5 to
Qt6.  There is still ongoing work to revamp the whole look of the wallet.  If
you want to get a preview of what the new GUI for Bitcoin Core should look like
eventually, you can go to bitcoincore.app where they have a very beautiful
preview and demo of the wallet.  The GUI work has been ongoing for a long time
too, so this is, I think, one of the first things that surface from this.  This
is a collaboration between the Bitcoin design community and some front-end
developers working on the GUI update.

This is not in the release notes, we don't usually cover performance in that,
but I want to also point out that v29 to v30, IBD (Initial Block Download) has
been measured to be about 20% faster with v30, and the re-index is about 17%
faster than in v29.

**Mike Schmidt**: Yeah, that was on my list too, because I knew it wasn't on the
release note, so I'm glad you brought it up.  I think it's okay to pat yourself
on the back for these sorts of things.  So, I wish that was in there, but I'm
glad you mentioned it.

**Mark Erhardt**: Right.  Oh, yeah, the last thing I wanted to mention is some
people pointed out that the compatibility section changed.  It used to say that
there was support for Windows 7.  The v30 release does not support Windows 7.  I
think there was a build issue.  Windows 10 has been out for ten years, 11 years
or so.  So, the Windows support has been moved to Windows 10-plus instead of
Windows 7.

**Mike Schmidt**: I don't have the notes up in front of me, but I assume there's
assorted sort of bug fixes in here.  But in terms of vulnerability disclosures,
if there are any that would happen at some point after the release, correct?

**Mark Erhardt**: Right, so we have a four-tier vulnerability reporting scheme
for minor issues.  They get reported, I think, two weeks after a release fix
system, medium- and high-level severity issues.  Right, OK, so there's four
different severities, low, medium, high, and severe, I think.  Or I don't
remember what, very high?  Anyway, the smallest category is revealed two weeks
after it has been fixed in any release; the medium and high are revealed when
the last maintained version goes end of life; and the extreme severity is
handled on a case-by-case basis, depending.  It might be revealed very quickly
to get everyone updated quickly, or it might be revealed later when there's
really very few nodes running the version, and maybe also other related projects
have been informed and had a chance to fix bugs,, because we have a lot of
downstream copycats.

**Mike Schmidt**: Low, medium, high, and critical.  And for folks who want to
see some examples of those, go to bitcoincore.org.  If you go to the development
dropdown, there's a security advisories area.

**Mark Erhardt**: Thank you, yes, that's what I meant.  Critical.  Okay, this
covers the 30.0 release to some degree, I guess.

_BDK Chain 0.23.2_

**Mike Schmidt**: Yeah, great job, Murch.  We do have a second release that
we'll not dive nearly as deep into, but BDK Chain.  So, as a reminder, BDK sort
of re-architected their repository.  So, I believe there's a BDK wallet, there's
a BDK chain, which is sort of the guts of the thing.  This is BDK Chain 0.23.2.
It has improvements for handling transaction conflicts.  It redesigns this
filter iterator API, which actually is a PR later that we'll get to, and I can
jump into that a little bit.  It improves its compact block filtering
essentially for Electrum.  And there's also improvements to reorg management and
also anchors.  So, if you're a BDK Chain user, check out the release.

_Bitcoin Core #33268_

And Murch and, we're right back to you for a Notable code segment.  We're in
Bitcoin Core #33268, how transactions are recognized as part of a user's wallet.

**Mark Erhardt**: Right, so we recently introduced ephemeral anchors and they
specifically are designed to be allowed to have an amount of zero.  The wallet
previously would recognize transactions as belonging to the wallet if any input
spent wallet funds.  And now, with the outputs being allowed to have an amount
of zero, those would not have been discovered.  So, there's a slight change
here.  Transaction outputs that are tracked by the wallet and spent by a
transaction cause this transaction to be tracked by the wallet, which makes
sense.  So, when we create ephemeral anchors and spend them, they make the child
transaction tracked by the wallet.  So, also, if someone else spends your
ephemeral anchor, I think it should be tracked now, which is something you
probably want to see because with transaction siblings are mempool conflicts,
you can only have packages of two transactions.  So, if another child spends the
parent while they're both unconfirmed, the other child will replace the first
child, given that it has more juicy fees.  Yeah, so you would see that in your
wallet if it spends the ephemeral anchor.

_Eclair #3157_

**Mike Schmidt**: Moving to our LN PRs, have Eclair #3157.  This is a PR that is
titled, "Resign next remote commitment on reconnection".  And for this one, I
thought t-bast had a good description, so I'm going to quote the first couple of
sentences of that for summary of what he's talking about here, "We previously
retransmitted our last commit_sig on reconnection if it hadn't been received by
our peer, without changing it.  This can be an issue for taproot channels when
remote nodes don't use deterministic nonce derivation, because their nonce may
be different on reconnection, and our previous commit_sig would thus not be
valid anymore".  So, now they will resign that next remote commit when they
reconnect.  He also notes, "We now re-sign the next commitment on reconnection,
using the latest nonces we receive from channel_reestablish message".

_LND #9975_

LND #9975.  This PR adds support for taproot fallback addresses.  In BOLT11, a
fallback address is an onchain Bitcoin address that the recipient includes as an
alternate way to pay if the payer cannot or does not want to pay via LN.  LND
already supported segwit fallback addresses, but now taproot fallback addresses
are supported with this PR.

_LND #9677_

LND #9677 updates the PendingChannel response message in LND by adding two
pieces of new information to that existing message.  It adds the number of
confirmations required for a new LN channels activation, and it also adds the
block height at which that funding transaction was confirmed.

_LDK #4045_

LDK #4045 is part of LDK's async payments project that we've talked about on and
off.  I thought that there was actually a comment in one of the code files that
did a good job of explaining this, "LDK supports a feature for always-online
nodes, such that these nodes can hold on to an HTLC from an often-offline
channel peer until the often-offline payment recipient sends an onion message
telling the always-online node to release the HTLC.  This is set to true.  Our
node will carry out this feature for channel peers that request it".  And I
think that the write up this week also has something similar, but I thought that
that was an interesting comment direct from the source, literally from the
source code.

_LDK #4049_

LDK #4049 is also part of LDK's async payments project.  This PR is titled,
"Always-online node forward invoice request".  As an always-online LDK node, if
that LDK node receives an invoice request on behalf of an async payment
recipient, this adds support for forwarding that request to the recipient in
case that recipient is online and can actually respond to that request.  So, a
lot of async work in LDK here.  I think we saw some similar work on other
implementations recently.  So, good for often-offline LN transactors.

_BDK #1582_

BDK #1582, this is actually just, well, I don't want to say just, but it's a
refactor PR.  It's part of a larger effort in BDK to support header checkpoints
when using the Electrum backend.  So, without these header checkpoints, BDK has
to re-download block headers in certain situations.  So, this particular PR
adds, from a refactor perspective, adds generic types for a few BDK data types,
which is a step toward that effort to store the whole headers and prevent the
need to redownload block headers.  And in addition to avoiding that
redownloading of those headers, it also enables caching of merkle proofs and
Median Time Past (MTP), which I'm not sure what they will use that for, but
that's probably just my ignorance, Murch.  I don't know if you have anything
that comes top of mind?  No.

_BDK #2000_

BDK #2000 makes changes to BDK's FilterIter API.  This filter iterator scans
Bitcoin blocks and then uses compact block filters looking for transactions
relevant to a particular wallet.  The PR description outlines the issue with
that particular API in the way that it's architected before this PR, which is,
"Previously FilterIter did not detect or handle reorgs between next calls,
meaning that if a reorg occurred, we might process blocks from a stale fork,
potentially resulting in an invalid wallet state.  This PR aims to fix that by
adding logic to explicitly check for and respond to a reorg on every call to
next".  So, I assume there that next is the way that they're iterating and
processing these filter responses.  And so, now it is reorg-friendly, which I
think hearkens back to the release that mentioned that earlier.

_BDK #2028_

Last PR this week, BDK #2028, which adds a last evicted from the mempool
timestamp for a transaction to the TxNode data type.  Previously, that
last_evicted field was on the TxGraph data type, and that field indicates when a
transaction was removed from the mempool, for example, being replaced through
RBF.  So, the field moved data types, which is actually a breaking change.  And
that's noted in the PR as well.  We did cover the TxGraph, adding the
last_evicted timestamp back in Newsletter and Podcast #346, where we got into
more detail around the specifics of that.  But this particular one is just
moving where that field is to a new data type.

**Mark Erhardt**: I have an uninformed question here.  If you evict something
from the mempool, where do you store that last_evicted timestamp field on?  Is
this transactions that are relevant to the wallet attached to it or something?
Because otherwise, dropping stuff from the mempool means, in Bitcoin Core at
least, that we drop it completely.  So, I'm kind of curious, where is that
last_evicted field?

**Mike Schmidt**: Yeah, I'm not sure.  Maybe that's part of why they moved data
structures from the TxGraph to the TxNode.

**Mark Erhardt**: Oh, I see.  I think it's generally just the timestamp when any
transaction was last evicted.  It's not on a specific transaction, maybe.  Does
that make more sense?

**Mike Schmidt**: It could.  Yeah, I would actually probably scan back the
transcript of you and I talking about this in #346 as it probably is similar
now, but I can't answer firsthand with that.

**Mark Erhardt**: Yeah, well, I don't know.  Okay.

**Mike Schmidt**: Well, that's it.  I guess we can wrap up.  Murch, thank you
for taking the time to prepare all of the release notes summary from Bitcoin
Core RC v30, or I guess v30, but this happens to be RC1.  I did check, I did not
see RC2 yet.  And obviously we want to thank our guests, ZmnSCPxj, who had to
drop earlier.  Great of him to join.  Cedarctic, thank you for hanging on.
Great of you to join as well.  Thank you for doing that research and being here
to represent that for us.  And, Murch, thanks for co-hosting.  We'll hear you
next week.

**Mark Erhardt**: Thank you Mike, hear you soon.

**Mike Schmidt**: Cheers.

{% include references.md %}
