---
title: 'Bitcoin Optech Newsletter #404 Recap Podcast'
permalink: /en/podcast/2026/05/12/
reference: /en/newsletters/2026/05/08/
name: 2026-05-12-recap
slug: 2026-05-12-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by Daniela Brozzoni, Naiyoma, and Thomas Voegtlin to discuss
[Newsletter #404]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-4-13/424075374-44100-2-9a3b7933ac36a.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #404 Recap.
Today, we're going to be talking about potential solutions to node
fingerprinting.  We talked about the issue of addr message timestamps
previously and there's some potential mitigations to that.  There's also
discussion in our News section about a proposal for public fraud proofs to
improve some of the incentives around just-in-time channels; and then, we
have our weekly segments on Notable code and documentation changes.  And
we'll get to those shortly.  But first, let's introduce our guests.  We
have Daniela.

**Daniela Brozzoni**: Hey, everyone, I'm Daniela.  I work on Bitcoin Core,
especially on the P2P side, and I'm supported by OpenSats and HRF.  I'm
very glad to be here.

**Mike Schmidt**: Naiyoma?

**Naiyoma**: Hi, my name is Naiyoma, I'm also a Bitcoin Core contributor,
and I also work on P2P and also reviewing a bunch of stuff.  I'm also
funded by HRF and OpenSats, and I'm happy to be here.

**Mike Schmidt**: And Thomas?

**Thomas Voegtlin**: Hi, I'm ThomasV, I'm the founder of Electrum Wallet,
so I still work on this project.  It's been around for a very, very long
time.

_Possible solutions to node fingerprinting_

**Mike Schmidt**: Awesome.  Thank you three for joining us today.  We're
going to jump into the News section.  First item titled, "Possible
solutions to node fingerprinting".  And we have both Daniela and Naiyoma
on to talk about this.  Naiyoma, you posted to Delving Bitcoin about
potential solutions to the node fingerprinting issue that we discussed in
Newsletter and Podcast #360, where we had you both on to talk about the
issues.  And I think some of the next steps out of there was researching
potential mitigations to the potential fingerprinting.  Maybe one of you
can just briefly recap what was uncovered in your previous posts and
research, and then we can get into potential mitigations to that
fingerprinting?

**Naiyoma**: Yeah, I think I'll do a quick recap.  So, essentially, what we
discovered earlier on is that it is possible to fingerprint dual-homed
nodes.  And this is because of correlation of addresses and then
strengthening this correlation using timestamps.  So, the idea here is
that a dual-homed node does have the same AddrMan.  So, when an attacker
queries for a GetAddr response on one network, the response does come from
the same AddrMan as the other network.  And then, the correlation is
created and then strengthened using timestamps.  So, that's why we were
mostly looking at timestamps as the solution for this.

**Mike Schmidt**: Okay, Daniela, would you add anything to that?

**Daniela Brozzoni**: Yeah, I think it's good.  I think we can maybe chat a
little bit just to expand about how addresses are shared around the
network.  So, there's two mechanisms of how nodes can learn about each
other's addresses.  One is through GetAddr requests, which is what we're
here talking about today.  So, when a node connects to a new node, the
node that has the connection outbound will send a GetAddr message, which
basically means, "Hey, can you please send some addresses from your
AddrMan?"  And the other node will reply with an Addr message, which will
typically contain 1,000 addresses from the node AddrMan.  And for each one
of these addresses, there will be a timestamp and the services that that
node is recorded.  The timestamp is one of the main characters here.  And
usually, we can interpret it as a last seen.  So, it's this value that we
update in our AddrMan when we see the address in the network, either
through GetAddr requests, or to self-announcement, which is something I'll
explain in a second.  Or we also update it when we close a full outbound
connection.  So, we connect to a node, we stay connected for some time.
When that connection gets closed, we do update its timestamps in our
AddrMan.

The other mechanism that helps with address relay propagation is
self-announcements.  So, about once a day, every node will tell to its
peer, will send an Addr message with its own address and a timestamp, which
is right now.  And the peer will relate to its own peers until the
timestamp is less than ten minutes old.  So, for about ten minutes, there's
this flood of Addr messages so that I can tell all my peers, "Hey, this is
my address.  Tell your friends".  And they tell their friends, and that
goes on for about ten minutes.  So, yeah, just to give a quick recap of
the two ways we have to get the addresses known in the network.

**Mike Schmidt**: And then the issue, like Naomi was explaining, is that if
you're on multiple networks, essentially you have the same sort of set of
addresses and associated timestamps, so an attacker can then maybe see,
"Oh, you happen to be responding similarly, or a node on Tor seems to be
responding similarly to one on clearnet.  Maybe that's the same node"; is
that the idea?

**Daniela Brozzoni**: Yes, exactly.  I think this is not related to our
research, but I think a few years ago, someone also did a paper using the
same timestamps to try and understand the topology of the network, so which
nodes are connected to which other nodes.

**Mike Schmidt**: Does it make sense to get into these different ideas for
solutions/mitigations to make sure that this fingerprinting is less
impactful?  Or do you have some other approach you'd like to get into in
terms of your latest research here?

**Naiyoma**: Yeah, it does make sense to get into these solutions.  And
essentially, what we were thinking about is how do we introduce noise to
the timestamps in a way that we are able to break correlation, but at the
same time, maintaining the usefulness of timestamps in the network.  So,
that's what we were trying to achieve with this.

**Mike Schmidt**: Well, we had five that we had written up, five approaches
in the newsletter.  Do we want to go through those one by one and you can
explain them?

**Naiyoma**: Yeah, sure.  The first one was simple fuzzing.  So, we have a
range of five days, and then we just choose to fuzz normally, so plus or
minus five days.  And the issue that we have with this is, okay, maybe it
might be possible for somebody to be able to average given the range, but
also just the fact that any solution, and we'll see this with the others,
that includes making the timestamps newer creates a cascading effect, in
the sense that if a timestamp was approaching a zombie horizon.  So, in our
AddrMan, we have a 30-day horizon for timestamps.  So, what this means is
if an address is more than 30 days, we'll filter it out when we are
responding to GetAddr.  And then also, when we receive an address and
there's a bucket collision, we deprioritize this old address and then
replace it with a newer one.  So, if we have an old address, and then we
make it new, what this means is then we don't have the opportunity to get
rid of these still address zones.  So, we'll just keep seeing them floating
on the network, which we don't want to flood the network with these old
addresses.

So, that's the issue with any solution, even the ones that we've discussed,
like the second, third, and I think fifth one, is just that we cannot
afford to make all timestamps new.

**Mike Schmidt**: And what about number 2 here, fixed timestamps across
networks?

**Naiyoma**: Yeah.  So, the idea here is if you receive a GetAddr request
from an IPv4 node, ideally you will respond with a mix of addresses.  Some
are IPv4, others are on onion.  So, ideally, what this solution means is
for IPv4, which is the same network as the requester, then send the real
timestamps.  And then the other networks that are different from the
network that is requesting, then we can add noise to that or just give them
like a fixed timestamp.

**Mike Schmidt**: Okay, makes sense.

**Naiyoma**: And then for the third solution, the meaning is making the
addresses mostly older.  So, ideally, this mitigates the whole issue of if
we make old addresses newer, then we have these two addresses being
propagated across the network.  So, if we make them older, it's a little
bit safer, in the sense that they'll just be stuck in our AddrMan, but they
won't be sent out as a GetAddr response.  So, that's probably a much safer
approach than the others.  But still, the issue that I see this having is
then, if an address is newer and then we're making it older, then we are
disadvantaging these addresses in the sense that they would otherwise be
gossiped, but now they're just stuck in someone's AddrMan.  So, safer, but
not entirely good, is how I'd put it.  So, what we are considering is like
a hybrid.  I think the strongest approach would be solution 2 and making
them older.  That way, some timestamps that are from the same network go
out as fresh, and then these other different ones is what we make older.

**Mike Schmidt**: Any feedback on that, Daniela?

**Daniela Brozzoni**: Yeah, I think generally, we have two different
approaches that we could take.  One is some kind of fuzzing, which is
solution 1, 3 and 4, which basically means randomizing a bit the
timestamps.  And the other one is changing them based on the network of the
node requesting the addresses.  The thing about P2P is that the problem is
you often don't really know all the variables, let's say.  So, I don't
exactly know how the nodes in the network behave.  I can read the code, but
from that, I don't exactly know how many GetAddr requests get sent every
day, how many self-announcements in the whole network.  So, I think it's a
bit hard to just look at these solutions and say, "Oh, this is the perfect
one, or this is the perfect one".  And so, what we've been doing for
actually quite some time, since the last newsletter, is just trying to
simulate what these different solutions might do, and sometimes say, "Oh,
this sounds good", and then try to open a PR.  And then someone realizes,
"Oh, wait, no, this wasn't a good idea".

So, yeah, I think I really like the approach of sending different timestamps
based on the network, and I would mix it with some fuzzing, as in maybe you
can send the real timestamp you have in the AddrMan if the network matches
the network the peer is on.  So, as Naiyoma was saying, someone asked me
something on IPv4.  Okay, then I will send the IPv4 addresses with the real
timestamp and the other one, I will do something else to them.  And that
something else, I think I'd like it to be fuzzing.  But yeah, I'm not sure
really, I think there's a lot of trying to simulate what would happen.  And
that's also why we decided to write the post, because we also wanted to
hear from people what they think about these solutions, but also how they
would go and test them mostly.  So, yeah, I think I like the second one,
but there's still some studying that we need to do.

**Mark Erhardt**: I have a question, and that is, all of these solutions
seem to be focused on just the timestamps.  But if I remember correctly
from our last conversation, you additionally have the issue that just which
nodes are returned as a fingerprint, because you will have a subset, an
overlap in the returned messages per network.  I think we cache the
response on each network, so whatever we have selected remains the same.
But even if the timestamps are fuzzed, we would still have a bigger than
average overlap for nodes that respond on the two different networks.  So,
I was wondering whether you had also thought about changing the response
per network so that maybe 90% of the nodes you return on a request --
sorry, so let's say you get a request on Tor, you would respond with 90%
Tor nodes and only 10% across the other networks, giving a little bit of
inroads to someone that is trying to make connections in more than one
network, so that they see some nodes on those other networks.  But to
further reduce the overlap in your responses for the different networks,
have you looked at selection rather than just the timestamps?

**Daniela Brozzoni**: So, it's something I was thinking a little bit about
today following the discussion on Delving.  So, first of all, I think
usually, if one has an AddrMan with a normal size, as in it's been connected
on the network for a while, then the adjustment size will be maybe 50,000
addresses.  And then, for each cache, you just pick 1,000 addresses from
that 50,000.  So, you don't really see a big overlap, I'd say.  But it's
not that much of a problem.  It might be a problem if a node has a smaller
AddrMan, because yeah, at that point, if you only have 2,000 addresses in
your AddrMan, then your GetAddr responses will be very similar.  Also, I
noticed today, while looking at the code, that we actually only save the
addresses for the nodes that we can reach.  So, if I have a node that is
only on clearnet, I will only have clearnet addresses in my AddrMan.  And
my GetAddr response will only be clearnet addresses.  And if I'm only I2P,
then I only have I2P addresses.  So, that by itself, it's already kind of a
suggestion that a node is on one network or two networks or multiple
networks.

So, yeah, I think it's interesting, it's something to consider.  Again, I
was following the Delving thread today, and we already got quite a few
ideas to think about.  I wonder how useful it would be for nodes with,
again, a normal size AddrMan that have been connected on the network for a
while.  But it's something to research, and at least I haven't thought that
much about it.  Do you have anything to add, Naiyoma?

**Naiyoma**: Yeah, I think I remember us having a discussion earlier on
about maybe even having separate AddrMans for dual-homed nodes.  So, that
will obviously be like a much bigger and complex project.  But yeah, that's
something that we discussed.  And also, in regards to filtering on the
sender side, I feel a bit maybe conservative about that, because I usually
feel like as a sender, you want to maximize the number of nodes that you're
sending out, and then giving the receiver the opportunity to filter them out
on their end.  So, if you have like two bridges communicating to each
other, if I get, like, I2P that has really few peers on its end, but it's
also available on IPv4 as the sender and receiver, if then these two I2P
send a request to the sender and then the sender only replies with I2P, I
think then in that way, these minority networks are still disadvantaged.
So, I'm not really a fan of like, let's filter from the sender's side.  So,
I would like that filtering to be on the receiver side and to remain on the
receiver side.  But yeah, that's how I'm thinking about it.

**Mike Schmidt**: As we wrap up this News item, do either of you have any
parting words for the audience, anything that you guys are looking to do
next, anything else that we didn't cover today that you'd like to?

**Naiyoma**: I think just more feedback.  We are already experimenting with
a couple on my fork.  So, yeah, hopefully if we do get to a good
compromise, then an open PR will come out soon.

**Daniela Brozzoni**: Yeah, I think some feedback would be good.  We both
have some experiments on our private repos of trying to simulate the P2P
Network.  There's essentially two approaches.  One is using warnet, and
that pulls up real Bitcoin Core nodes.  But then you're limited, because
likely your computer won't be able to spin up thousands of nodes.  The
other approach is rewriting from scratch a simulation, and so rewriting
part of the P2P mechanism.  So, we're going through that.  I have to say,
at least on my side, it's been quite hard to do, but it's a lot of fun.
So, yeah, I guess feedback.  And I really hope at a certain point we will
have even more follow-ups on our simulations.

**Mike Schmidt**: Great.  Well, thank you both for joining us.  We
understand if you have other things to do, you're welcome to drop.  Cheers.

**Daniela Brozzoni**: No, I'll stay, I want to follow.

_Public fraud proof for just-in-time channels_

**Mike Schmidt**: All right, great, hang around.  Well, we're going to talk
now about public fraud proofs for just-in-time channels.  Thomas, you
posted to Delving Bitcoin about a new proposal/approach for improving the
game theory behind JIT (just-in-time) channels using public fraud proofs.
You opened your post to Delving saying, "I have long been unsatisfied by
the trust model of just-in-time channels".  Perhaps, Thomas, we can start
there.  What are JIT channels and their trust model that you are
unsatisfied with?

**Thomas Voegtlin**: If you want to receive funds on Lightning, then you do
not have any channel, and accessorily, you don't have any Bitcoin, you
cannot open a channel yourself.  So, a few wallets out there, they propose
the option to receive funds through a channel that doesn't exist yet.  And
so, the LSP, the Lightning Service Provider is going to receive the HTLC
(Hash Time Locked Contract) for you.  And when they receive it, they will
open a channel to you.  This is the concept of a JIT channel.  And yes, the
issue is that one has to trust the other.  Either the client has to trust
the server, in the sense that the client has to give the preimage of the
payment first, and then the server will open the channel, but the server
can obviously steal the funds; or the server trusts the client, meaning
that the server opens the channel, so they will also spend money because
they have to pay mining fees, and they have no guarantee that the client
will then send the preimage for the payment.  So, this results in general
in a situation where if you want to have a good user experience, you want
in general your channel to be opened just-in-time with zero confirmation,
and so you just trust the server, but the wallet providers, they don't want
obviously their users to be scammed by random servers.  So, they will only
allow their users to open a channel with themselves.  So, this means that,
for example, if you use the Phoenix wallet, you can only open a channel
with ACINQ.  And this is for this reason, it's because the JIT channel is
not trustless.

So, this has a tendency to create centralization in the LN.  And also,
it's not clear from a regulatory perspective whether a JIT channel provider
is a custodian or not.  So, it's a little bit, I mean, we don't know yet.
I mean, the answer to this question seems to be changing every year or so.
So, we would rather like to delegate that to a community of users in a
decentralized way.  But for that, we need obviously a better game theory,
where neither the client trusts the server nor the server trusts the
client, or at least we need to reduce the trust.

**Mike Schmidt**: Yeah, that was a great explanation of the issue.  And so,
how do we reduce the trust?  On which side do you decide to attack this
problem?

**Thomas Voegtlin**: Yeah, so actually I've tried to solve this for years
by using primitives of the second layer of the LN, and I never could have a
good solution for that.  So, the basic idea is to create a fraud proof, a
proof that the LSP has cheated, has stolen the funds.  So, we are in the
scenario where the client trusts the server, but if the server cheats, the
client can have a proof and they can use this proof to harm their
reputation.  Yeah, so I have been trying to do that for a while, and
recently I realized that if I want the victim to have a proof, we can use
the blockchain because this is a consensus layer.  So, instead of trying
to prove that the victim has given the preimage to the LSP, the victim can
actually write the preimage on the blockchain before a deadline, and then
the fact that this preimage is available on the blockchain is considered as
a proof of sending the preimage to the LSP.

So, with that, we can build a fraud proof that is made of three parts.  I
mean, the first part is a commitment from the LSP that they are going to
fund a transaction, a channel-funding transaction.  They are going to
broadcast this transaction and the txid is known in advance.  And they also
commit to the UTXOs that they are going to use for this transaction.  The
second part of the proof is that Alice has published the preimage on the
blockchain before a certain deadline.  And the third part is that the LSP
has actually done something else with the funds.  They have spent this UTXO
in a different transaction with a different txid.  So, those three elements
constitute the fraud proof.

**Mark Erhardt**: I have a question.  So, the preimage of the HTLC is
considered the proof of payment, right?  And it is also used to resolve all
of the hops along the multi-hop HTLC construction.  So, if the final
recipient publishes the preimage on the blockchain before the payments have
flown between the other hubs, wouldn't that enable all the other hubs to
steal the funds without actually resolving the HTLCs?

**Thomas Voegtlin**: No, it's like if you force close a channel somewhere,
it doesn't allow the previous nodes to steal the funds, because the HTLC
will be resolved on both sides of each node.

**Mark Erhardt**: Okay, maybe I'm missing something.  Please continue.

**Thomas Voegtlin**: Okay.  Yeah, so the flow actually is, so let's say Bob
is the server and Alice is the client.  Alice does not need to go onchain.
She's only going to go onchain if she does not see her channel open quickly
enough.  But the flaw is that actually, so Bob receives an HTLC for Alice
from a third-party, Carol.  And at this point, they start a negotiation of
a JIT channel.  But instead of broadcasting the funding transaction, Bob is
going to show the funding transaction to Alice.  He's also going to show
that he's the owner of the inputs.  And Bob is also going to send a signed
commitment that he's going to spend those UTXOs in this txid before a
certain block height.  And then, Alice has this guarantee now that she can
maybe create a fraud proof if Bob double-spends those UTXOs.  So, Alice
sends the preimage to Bob, and she does this with a classical
update_fulfill_htlc message.  And so, the flow is the normal Lightning flow.
So, at this point, you can already expect that all the HTLCs have resolved
along the path.

But if after a few minutes, Alice does not see her channel broadcasts in the
mempool, or if it is not confirmed, if she finds that it doesn't have a
chance to be combined soon, she should go onchain and publish the preimage
onchain.  So, the criterion is that she has only until a certain block n to
do that.  So, if she feels that the channel is not going to be opened before
this block n, she should go onchain.

**Mike Schmidt**: Okay, so she publishes this onchain, and then what happens
as a result?

**Thomas Voegtlin**: Well, there are three outcomes that are described in
the paper.  The first one is that Bob double-spends, so Bob is actually
cheating.  Well, okay, let's say the number zero is that Bob is actually
opening the channel and everything is fine.  But there are three cases of
fraud.  So, number one would be that Bob double-spends this UTXO in a
different transaction.  So, at this point, Alice has the three parts that
constitute the fraud proof.  Case number two is that Bob does absolutely
nothing with this UTXO.  And so, in this paper, I suggest that this does
not constitute a fraud proof.  There is no deadline for Bob to actually open
the channel because it would make the scheme more complicated.  But earlier,
I mentioned that Bob has to demonstrate that he is the owner of the UTXOs
that are committed.  So, if he doesn't do anything with them, technically
he loses those UTXOs, and he loses more than the amount of the HTLC that he
has stolen.

Then, the third case, it's a bit of an edge case, but it's important, is
that Bob could be trying to cheat by committing the same UTXO with multiple
clients at the same time.  And so, because of that, we need an
infrastructure where clients share between each other the UTXO commitments
created by the LSP, so that they can check that the LSP does not commit to
the same UTXO twice at the same time.  So, the LSP can reuse a UTXO if he
does not receive the preimage after the deadline, the block n, in the
commitment, but he has to wait until this deadline has passed.  So, if a
given LSP creates two commitments that are valid at the same time, then one
of the clients should go onchain and publish the same OP_RETURN in order to
create a fraud proof.  So, the fraud proof in that case is the two
commitments that are incompatible plus the publication of the preimage.

**Mike Schmidt**: What's the mechanism to be sharing this information
between the potential people getting frauded by the LSP?

**Thomas Voegtlin**: Yeah, this is a good question.  So, we need some kind
of memory pool, or some kind of fast medium.  So, I suggest to use Nostr in
the article, because it's a good match and we already support Nostr in
Electrum.  So, I think we could use Nostr for that.  But this is not set in
stone, it could also be a dedicated network for this.  The thing is that
Electrum is a light client, so a few of the considerations in the paper are
for light clients, such as, for example, the fact that the light clients can
check that the UTXO has been spent, but they cannot check that the UTXO is
still unspent.  So, this is also something that was taken into consideration
in the definition of the fraud.

**Mike Schmidt**: So, if you're parsing these things around on Nostr,
there's not necessarily a way to protect against DoS if people just keep
sending you things, or is there?

**Thomas Voegtlin**: No, I don't think so.  I mean, DoS on Nostr is a big
topic.  But I think there are some measures that are being taken right now.
But you have to also consider that this is game theory.  What we want is to
deter the LSP from cheating, so that if they cheat, they should lose more
than they win.  And so, the punishment doesn't need to have 100%, you don't
need to have a full guarantee.  If it works 99% of the time, I think it's
enough to deter the fraud.

**Mike Schmidt**: Makes sense.  What's feedback been on the post, either
online or things that you've gotten offline?

**Thomas Voegtlin**: Oh, I received a lot of feedback from tnull from LDK.
I mean, I asked him to review the paper.  Yeah, he pointed out a mistake,
so I fixed the paper.  But there is also some feedback that he gave me
offline.  I think one of the main interesting points is that this does not
prevent the LSP from closing the channel shortly after they have opened it.
So, there is no guarantee.  I mean, this is an issue in general for LSPs.
There is no guarantee that the LSP will keep the channel open for a long
time.  On top of that, I think he also mentioned that it's a bit heavy,
because there is this Nostr connection and, yeah, there is this need for
clients to share the commitments.

Oh yeah, I forgot to mention also, so the idea of course is that the LSPs
would be entities that have a reputation, but that can be perfectly
anonymous.  So, on top of what I have already described, they need to have
skin in the game.  So, they need to lose something if their reputation is
harmed.  So, I proposed to create a system where an LSP has to sacrifice
some bitcoin in order to enter the game.  And so, if a fraud proof exists
for this LSP, then this sacrifice is lost.  So, the hope is that they would
recover their sacrifice through the fees that they make during legitimate
business, but they would be punished, in a sense, if they misbehave.  And
this sacrifice is important.  So, I mentioned they commit some funds, some
UTXOs that they are going to use to fund the channel.  The clients have to
check not only that they recite the same UTXO, but also that they could
make commitments that exceed the amount that they have sacrificed in order
to establish their reputation.  And this is another case where they could
work away with more money than they invested.  So, the amount that they have
burned should be compared to the amount in the commitment.  And so, that's
the second reason why the clients should also share the commitment.

**Mike Schmidt**: Makes sense.  I think if folks are interested, it sounds
like Thomas is getting feedback and is seeking more feedback.  There's the
Delving post that we linked to in the newsletter, and there's also a paper
on GitHub for folks to review and provide feedback as well.  Thomas,
anything else for the listeners before we move along?

**Thomas Voegtlin**: Yes, so just to conclude, the situation with this
scheme is that the server can be attacked by DoS still.  But I think that
the attacker has to commit more or less as much as the server, because
imagine I send an HTLC to myself through this LSP and I don't want to
reveal the preimage, so I have to dedicate funds in order to carry out this
attack in the HTLC.  And then, the server has to commit some UTXO.
Obviously, the UTXO needs to be larger than the HTLC because of the game
theory, and also because it's going to fund the channel.  But if you commit
a UTXO that is 100 times bigger than the HTLC, then you're going to be
highly susceptible to DoS.  So, it creates a new constraint, because the
server would likely need a range of UTXOs of different size so that they
can always create a channel that is not too large compared to the payment.

**Mike Schmidt**: Murch, any other follow-up questions?  Okay.  Thomas,
thanks for your time, thanks for joining us to explain the idea, and thanks
for your work all these years on Electrum.

**Thomas Voegtlin**: Yeah, thank you for having me.  I'm sorry, I'm going
to leave the podcast.  Bye-bye.

**Mike Schmidt**: Okay, we'll see.  We did not have any releases this week,
and there were none of our monthly segments for this week either, so we
actually are going to jump right to the Notable code and documentation
changes here.  And Gustavo, the author of this segment, is going to walk us
through some Bitcoin Core, BIPs, Eclair, LDK, LND, Rust Bitcoin, and BOLTs
PRs this week.  Hey Gustavo.

_Bitcoin Core #33796_

**Gustavo Flores Echaiz**: Hey Mike.  Thank you for the introduction.  Yes,
so this week we have multiple Notable code and documentation changes items.
We start with two from the Bitcoin Core repository.  The first one, #33796,
is an addition to the libbitcoinkernel C API, which we've been covering
since Newsletter #380.  Here, a new endpoint is added called
btck_check_transaction(), which allows a caller to run context-free
consensus-level checks on a transaction's structure.  So, for example,
making sure that you reject transactions that have empty input or output
lists, or running the context-free consensus-level checks on coinbase
transactions so that the scriptSig is of the accurate length, or other
simple things, such as the output value cannot be outside the valid money
range, the output value cannot be negative, no prevouts (previous outputs)
or inputs that are found in non-coinbase transactions cannot be of a null
amount.  So, things like that can now be done directly in the libbitcoinkernel
C header API through this new endpoint.  So, if you are curious about when
was this C header API introduced, you can check out Newsletter #380.

Also, in Newsletter #400, we covered the btck_check_block_context_free.
So, this one is similar in the sense that they're both context-free checks.
The one covered in Newsletter #400 was about the blocks, and now this one
is about the transactions.  For those that don't know, libbitcoinkernel is
a project to isolate the chainstate or block validation logic from other
parts of Bitcoin Core.  So, you basically just get the consensus and the
validation engine without the wallet of Bitcoin Core or other parts that
are not essential.  And you can build many, many things from this, such as
alternative full-node experiments, external block validation, indexers, and
other types of projects.  So, this is just the latest update on the
libbitkernel project.

_Bitcoin Core #21283_

Next item is Bitcoin Core #21283.  Here, this was a PR that was opened, if
I recall correctly, in 2021.  So, it's been in the works for almost five
years.  And here, there's the implementation of the support for PSBTv2,
also known as BIP370, which this PR ensures to maintain backwards
compatibility with PSBTv0.  But all the endpoints that are related to the
PSBT, such as createpsbt, walletcreatepsbt, converttopsbt and psbtbumpfee
are now defaulting to creating v2 PSBTs.  However, like I said, there's
backwards compatibility, so a user can now specify through an optional
argument, called psbt_version, if he wants to instead create a PSBTv0.
And what are the benefits of PSBTv2 versus PSBTv0?  It's mostly about
modularity.  Now, for example, if you have a collaborative transaction, a
further signer can add additional inputs, additional outputs to the PSBT,
which wasn't something that was possible with PSBTv0.  Now, you have more
modularity, because everything is specified through separate fields, whether
it's the version or other fields, and it just creates a more, not only
cleaner data model, but just better transaction construction workflows,
specifically for multiparty protocols.  Yes, Murch?

**Mark Erhardt**: Yeah, I have some chiming in to do here.  So, the first
question that might be begging for itself is why PSBTv0 and then PSBTv2?
When PSBTv0 came out, a lot of people also started calling it the first
version of PSBTv0.  So, calling the follow-up PSBTv1 was confusing to a
lot of people, and that was why the version was skipped.  The second
question that might be interesting is, why is PSBTv2 more flexible?  The
initial design of PSBT duplicated a lot of the information by having an
entire unsigned transaction in it, and then also fields for a lot of the
input and output information.  So, when an updater of the PSBT wanted to
change something about the transaction, they had to both change the fields
and update the unsigned transaction that was delivered with the PSBT, which
was a source of implementation bugs and very complicated, because it now
also required the handling of deserializing and reserializing the unsigned
transaction and updating both in lockstep.  So, PSBTv2 only contains the
fully decomposed transaction per the fields.  So, it has global fields,
which are, for example, the things that appear in the transaction header,
like the input count, the output count, the locktime, the transaction
version.  And then, it has per-input and per-output fields that allow the
creator, updater, and finalizer of the transactions to only update the
decomposed fields, maybe shift the order of transaction inputs and outputs,
or add inputs and outputs, or just add information to existing inputs and
outputs.

So, this new format has been actually adopted by a few other wallets
already.  Bitcoin Core is now, five years in the making, a little behind on
adoption of PSBTv2.  And more recently, we've also seen a bunch of other
BIPs that make use of PSBTv2, and also extensions of PSBTv2 that have
allowed the creation of silent payment outputs, both on the input and on
the output side.  There is PSBTv2 being used for payjoin.  I think they
also have some way of using the v0 version, but the natural extensibility
and general, more flexible design of PSBTv2 has made it more attractive for
uses like this.  I think I also forgot, MuSig2 constructions are supported
in PSBTv2.  So, if you're looking to start using PSBTs, I think the v2 one
is the way to go, especially if you can wait for Bitcoin Core version 32,
where we will see support for PSBTv2, if that factors into your stack.

**Mike Schmidt**: And Gustavo mentioned that it's been about five years or
so, and I think at the time of this PR being merged, it was the oldest open
PR to Bitcoin Core.  So, I'm not sure why it took so long.  People can
jump into the PR and decipher some of that for themselves, I guess, but
good to have it done, I guess.

**Mark Erhardt**: I think it was just mostly stuck on review.  There was a
lot of interest across the ecosystem, but for some reason this PR didn't
get as much review as necessary.

_BIPs #2150_

**Gustavo Flores Echaiz**: Thank you for chiming in.  That was great
context.  We move forward with the BIPS repository.  We have PR #2150,
which adds BIP451, also called a specification for a Dust UTXO Disposal
Protocol.  So, the goal of this BIP is to define a standard way for wallets
to safely dispose of unwanted dust UTXOs by spending them all to a single
zero-value OP_RETURN output, and the entire input value paid to the miners
as transaction fees.  So, this protocol includes privacy-preserving rules,
so to ensure that you never will use multiple dust UTXOs from different
addresses, so you have per address disposal.  But also, what is really cool
is that it uses SIGHASH_ALL|ANYONECANPAY, which means that anybody that
finds a transaction built with this protocol in their mempool, can add
additional inputs of their own dust UTXOs that all get spent in the same
way to the zero-value OP_RETURN output, and the entire input value is paid
to transaction fees.  So, I thought that was a really cool aspect of this
proposal.  But overall, interesting to see a standard way to dispose of
unwanted UTXOs.

**Mark Erhardt**: Yeah, I've been looking at this or I had looked at this a
few times.  It just got published.  I think it is an interesting proposal.
There were some small improvements still made.  So, for people that have
been following the process of this proposal, originally the authors proposed
that there would be two different variants of outputs, either just a
completely empty OP_RETURN output, or for transactions with native segwit
inputs, more specifically a single native segwit input, to have an
OP_RETURN output that included the three letters, ash, like ashes to ashes,
in order to make the transaction at least 65 bytes.  In the latest updates,
the proposal has now specified that the ash output is used always, which
means that legacy inputs would make slightly bigger transactions.  But
generally, all transactions, whatever inputs they use, are composable into
a batch.

So, the interesting thing here about the sighash type that is being used is
if you use a SIGHASH_ALL, that refers to the outputs that you are committing
to.  So, a SIGHASH_ALL will commit to all of the outputs that are present on
the transaction.  SIGHASH_ALL means that no additional outputs can be added
without invalidating the input's signature.  Also, to be clear, the sighash
output type is specified in the signature of an input.  So, each input picks
its own sighash type.  So, SIGHASH_ALL means the outputs are fixed and
ANYONECANPAY is a modification that refers to which inputs are being
committed to.  ANYONECANPAY means that the input only commits to its own
presence and does not have an opinion on the other inputs or its position in
the list of inputs.  So, this construction, SIGHASH_ALL|ANYONECANPAY, means
that anyone can add more inputs, but nobody can change the outputs.  And
because we all now will use an OP_RETURN with the ash letters in it, it
means that as soon as there's any of these dust disposal transactions
floating around the mempool, any third party can grab them and just squash
them together, so that all of the inputs are on a single transaction and
there's only a single output where all of that is burned to ashes; in this
case specifically, the fees that the miner collects.

The dust limit for outputs is, I think the smallest is 294, except for
crazy stuff like P2A (Pay-to-Anchor).  But older ones are 330.  In an
environment where the minimum feerate is 0.1 sats/vB (satoshis per vbyte),
a P2TR input costs 6 sats.  So, you would be offering 288 more sats for
just the transaction header and that ash output, which means that actually
these dust disposal transactions would have quite significant fees.  And
when they're batched together, the feerate will only go up.  So, hopefully
this means that when people decide that they don't want to rely on their
local wallet settings, where they might have locked certain UTXOs from being
spent, and they got dusted on an address where they don't have any other
UTXOs left, then this is a good option to clean out their wallet and to
prevent them from ever accidentally spending these dust UTXOs with other,
more valuable UTXOs that create a connection, or allow wallet clustering on
their UTXOs.

Note that there's a bit of a game theory to whether you should spend UTXOs
to dust or just use them yourself.  If you still have funds on the address,
you should just include the dust UTXOs in the same transaction and spend
them alone, unless that reduces the feerate and you want to have a high
feerate.  So, with them being so small, it's pretty likely that they
actually contribute to the feerate.  And in that case, you actually want to
make use of them instead of burning them.  If they are on addresses you had
previously used, but no longer have any funds, and you want to permanently
take care of it, I think this is an interesting proposal for you.  I'm
curious to see when the first ash outputs are going to appear on the
network.

_Eclair #3144_

**Gustavo Flores Echaiz**: Really cool.  Thank you for adding that context,
Murch.  We move forward with now the Lightning implementations.  We start
with Eclair.  Eclair has two new additions this week.  The first one,
#3144, updates the simple taproot channels to use the official feature bit.
So, later in this episode, we're going to be talking about the new
additions to the BOLTs repository, and the merging of the simple taproot
channels protocol is one of them.  So, following that merge into the BOLTs
repository, Eclair made sure to update their implementation to use the
official feature bit and enabling them by default.  However, something that
is important to note, from the specification that also applies in the Eclair
implementation, is that there's not yet support for announcing those
channels.  There's just no official specification for the announcement of
these channels.  So, Eclair ensures to enable them by default without yet
adding support for announcing them.  Additional test vectors are added to
align with the specification, but also with LND's implementation that we
covered in Newsletter #401, LND kind of took a step forward and upgraded
their simple taproot channels implementation to production and we covered
that in Newsletter #401.  So, Eclair is now interoperable with LND for this
feature as well as others.

_Eclair #2887_

Okay, the next item in Eclair is #2887, which adds support for the official
splicing protocol that was merged into the BOLTs specification, and that we
covered in Newsletter #398.  So, Eclair had a previous earlier internal
experimental implementation for splicing.  So, now they have upgraded to
the official one while maintaining backwards compatibility with the internal
Eclair one.  So, the differences were mostly around wire compatibility,
Keysend protocol rules, how it handled RBF, how it handled edge cases
around reconnection.  So, it's still the same concept, it's still the same
feature that works through the same splicing lifecycle.  However, the
message types have changed, the feature bit has been upgraded, the Keysend
protocol has become stricter and cleaner.  And for example, another
important one is how signature batching for the commitment transaction is
done.  That's also an internal mechanic that was reworked in this PR.

So, overall, same features, same splicing life cycle, just the internal
mechanics have been upgraded to the official BOLTs specification.

_LDK #4592_

We move forward with LDK item #4592.  So, here, LDK starts checking if a
node has sufficient reserves before opening new zero-fee commitment (0FC)
channels.  So, there was an issue in LDK where when 0FC channels were
introduced, there was no check to ensure that the node had sufficient
reserves in case there could be simultaneous force closes that would require
a node to react to multiple channels being forced closed at the same time.
So, now, LDK makes sure to check that the node has sufficient reserves
before opening new channels of this type by counting them as if they were
anchor channels.  So, the internal logic of LDK made it easier for LDK to
simply count these channels as traditional anchor zero-fee HTLC channels,
which are just the anchor output channels, and the most standard type of
channels in the LN.  So, now, LDK makes sure to count the 0FC channels as
all the other channels to ensure that there's reserves in the nodes wallet
for a potential edge case where there's simultaneous force closes.

_LND #9153_

So, in the next repository, LND #9153, there's a new field added to the
portal message route, called source_pub_key, which allows you to specify
another source node other than yours to construct and deserialize routes
from the perspective of that other node.  So, this is a cool feature that
allows you to calculate routes not from your node to a destination, but from
another node to another destination.  So, I'm not sure exactly what's the
objective here, but just pretty cool to see LND allow for more flexibility
on the construction of routes from the perspective of different nodes.
However, if this feature is not used, it will just default to the local
node.

_Rust Bitcoin #5835_

So, this completes the part on the LN implementations, and now we get to
Rust Bitcoin and the BOLTs repository.  So, a new addition to the Rust
Bitcoin repo, with item #5835, which adds a constructor called
V1MessageHeader that allows a node or a caller to construct network messages
without having to send them over the network.  So, you could previously
construct these messages, but they would be sent automatically.  Now, you
can construct P2P message headers for the Bitcoin Network without having to
send them over the network.  So, just an internal feature of Rust Bitcoin
for developers that were trying to construct these message headers without
having the need to send them directly to the network.

_BOLTs #995_

And finally, we get to the BOLTs repository, which has had quite a bit of
action this week.  The first one, #995, is a new extension BOLT, so not a
modification to the other existing BOLTs, but the introduction of a new
concept, called extension BOLT, which defines the simple taproot channels
protocol.  As I explained earlier with the Eclair modification, this is now
the official merge of this protocol into the BOLTs repository.  So, this
specification defines this new channel type that is obviously taproot-based,
as the name says it, and that uses a P2TR funding output with MuSig2 key
aggregation.  I believe in Newsletter #401, we covered a bit of how these
type of channels work when LND upgraded them to production.  So, this is
now the official merging of this type of channel inside the BOLTs protocol,
and now Eclair has also come in to promote it to the production feature bit.
So, like I said, this also has taproot commitment and HTLC scripts, new TLV
fields for exchanging MuSig2 partial signatures and nonces during channel
opening.  This was an important aspect that in the episode #401, I talked
about a little bit more in detail.

So, like I said, a decision that was taken in merging this protocol in the
official BOLTs repository is that the announcement of these taproot channels
has been excluded from this extension BOLT.  So, we should expect a
follow-up PR to cover how the gossip protocol changes for the announcement
of this specific type of channel.

**Mike Schmidt**: I was looking at the PR description because I was curious
what this idea of extension BOLT was, yeah.  And it seems like if anyone's
read any of the BOLT text, you can see there's all these if statements all
around the place.  It can be a little bit unwieldy.  So, I guess this is
their idea to help mitigate that, is to use a particular BOLT as the base
and then have these extensions which reference it.  And I think by reading
this description, the idea was to avoid the complication of all these if
statements throughout the documentation.

_BOLTs #1228_

**Gustavo Flores Echaiz**: Precisely.  It makes it more readable and
digestible.  So, the next one is BOLTs #1228, which is also another major
news in the BOLTs repository, since this one specifies zero-fee commitment
(0FC) channels, which like I mentioned, they are now part of a few
implementations, such as the LDK one.  So, 0FC channels work through the
addition of first the v3 transaction relay protocol that we've covered
multiple times in this newsletter and the episodes that come with it.  But
it also leverages a P2A output that is capped at 240 sats.  So, instead of
having anchor outputs like in the other previous type of channels, that kind
of had to guess the fee that would be paid when this transaction would be
broadcasted in the network, now the parent commitment transaction basically
pays no direct fees; and when the commitment transaction of this channel is
broadcasted, if it is broadcasted, then its child transaction pays the fee
for this effective zero-fee anchor output, or P2A output, also named
ephemeral anchor.

So, the specification also limits the maximum number of HTLCs to 114,
because TRUC (Topologically Restricted Until Confirmation) transactions
have an inherent transaction-size limit of 10 kB.  So now, the HTLC number
is capped.  Any thoughts here?  No.

_BOLTs #1327_

So, we complete with the BOLTs #1327 item, which as we covered in Newsletter
#400, when LDK updated its internal RBF logic, now the same concept is
applied to the BOLTs repository so that other implementations can follow
the same rule.  Basically, the concept here is to ensure that when a
transaction's feerate is bumped through the RBF protocol, it not only
complies with how the BOLTs repository specs it in BOLT2, I believe, but
also it has full compliance with BIP125 replacement rules.  So, at very low
feerates, now that we have very low feerates on the network since
approximately last year, feerates can be lower than 1 sat/vB, well, there's
this edge case where a transaction would not be compliant with the BIP125
replacement rules.  So, this update to the BOLTs repository ensures that
instead of only applying the 25/24 feerate multiplier rule from the BOLTs
repository, the specification now requires the replacement feerate to
increase by either the larger of two values, the BOLTs 25/24 multiplier, or
an additional 25 sats/kw (satoshis per kilo weight) unit, which is
approximately 0.1 sats/vB.  So this, like I said we covered in Newsletter
#400, was added then to the LDK repository, and is now part of the BOLTs
official specification.  And this is the last item of this section and this
completes the newsletter as well.  Thank you.

**Mike Schmidt**: Awesome.  Thanks, Gustavo.

**Mark Erhardt**: Just about that last item.  I think I might have said
something similar in Newsletter Recap #400, but I'm still confused that
both of these multipliers just look at the feerate.  So, obviously, 25
sats/kw unit are just 0.1 sats/vB.  But for a replacement to go through,
also the absolute fee has to be at least as big or higher.  So, I was
wondering whether the 25/24 is actually on the absolute fee rather than the
feerate, or whether there should be a third rule here that makes sure that
the new transaction has a higher absolute fee.  Either way, I also wanted
to comment on BIP125, being referenced here.

So, we basically don't really enforce BIP125 anymore, at least not all
aspects of it.  Since we introduced the mempoolfullrbf option in Bitcoin
Core a few years ago, any transactions that just outpay the original
transaction will be accepted as replacements by nodes that implement that
policy update.  And the other one is that we now, of course, in v31, use
cluster mempool rules in order to establish whether replacements actually
produce a better feerate diagram, rather than just looking at the rules of
BIP125.  BIP125 is still implemented by some other node implementations,
but there should be probably an update.  Someone should write a new BIP
that clarifies how replacement rules work in Bitcoin, or at least how
Bitcoin Core nodes think about replacements.

**Mike Schmidt**: Call to action for listeners.  We need another BIP
author.  Murch will review your BIP.  Daniela, I see you laughing that
you're signing up.  Good luck!

**Mark Erhardt**: Yeah.  If you laugh too hard, you also have to review it.

**Daniela Brozzoni**: I will review it, but write it?  Maybe, maybe no.
Next time!

**Mike Schmidt**: All right.  Well, Daniela, Naiyoma, thank you for joining
and hanging on with us.  We want to thank Thomas, who was with us earlier,
Gustavo and Murch for co-hosting, and for you all for listening.  We'll
hear you next week.  Cheers.

**Daniela Brozzoni**: Thank you.  Bye.

**Naiyoma**: Bye.  Thank you.

{% include references.md %}
