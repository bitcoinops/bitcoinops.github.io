---
title: 'Bitcoin Optech Newsletter #221 Recap Podcast'
permalink: /en/podcast/2022/10/13/
reference: /en/newsletters/2022/10/12/
name: 2022-10-13-recap
slug: 2022-10-13-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Ruben Somsen and Martin
Zumsande to discuss [Newsletter #221]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-8-13/346905273-44100-2-be49a5045a435.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to the Bitcoin Optech Newsletter #221 Recap
on Twitter Spaces.  We have a couple of special guests this week and we'll do
introductions in a second.  A bunch of us are here at TABConf in Atlanta.  In
effect, all of the speakers here are.  I think it makes sense to do intros and
then I think we're actually going to start with Ruben's segment this week and
skip over John Law's, and do that a bit later due to scheduling.  So,
introductions, Mike Schmidt, contributor to Bitcoin Optech and Executive
Director at Brink, where we fund open-source developers.  Murch?

**Mark Erhardt**: Hi I'm Murch, I work at Chaincode Labs and I'm grumpy because
I haven't had breakfast yet!

**Mike Schmidt**: Ruben?

**Ruben Somsen**: Hi guys, I'm Ruben.  I do a lot of protocol layer 2 stuff for
Bitcoin, and that's also why I'm here on a call to talk about one of my
proposals.

**Mike Schmidt**: Martin?

**Martin Zumsande**: Hi, I'm Martin.  I work at Chaincode.  I'm working on
Bitcoin Core, mostly the P2P protocol, and I'm interested in all things
connected to that.

**Mike Schmidt**: Excellent.  And if you're following along, I shared a bunch of
tweets in this Twitter Space to sort of orient yourself within the newsletter.

_Recommendations for unique address servers_

That being said, we're going to skip the first news item about long timeouts in
LN, and we're going to jump right to recommendations for unique address servers
from Ruben.  So, Ruben, do you want to maybe start with the problem statement
here, and then maybe what's out there now, and then how what you're proposing is
an improvement or contrast with existing solutions?

**Ruben Somsen**: Yeah, so first let me go ahead and say that here at TABConf on
Saturday, I'm going to give a presentation on this very topic.  So, if anyone is
interested in that, I understand that most of our listeners are probably not
going to be here at TABConf, but I assume the presentation's going to go up.
So, a couple of weeks from now or whenever they upload it, be sure to check that
out.  I think the talk is called Silent Payments and Alternatives.  So, the
thing that we're discussing now is in there and a few other proposals.

For now, I think specifically the one that was in the Optech Newsletter and the
thing that I recently posted is called Trustless Address Server.  And it makes
the observation that currently a lot of light clients give their xpub to a
server, or at least they give the addresses that they're interested in to a
server, and then the server sort of fetches that data for them.  And so, users
using light clients are leaking their privacy to at least one party, and then
the hope is that at least onchain, they're not leaking any data.  Given that
that is the case, the observation that I'm making is the current requirements
for receiving a payment, or at least the most common payment flow for receiving
a payment, is that you actually go and you ask.  So, let's say, Mike, if I want
to pay you, I say, "Hey, Mike, can you give me an address, then let me pay you?"
And then later if I want to pay you again, I say, "Hey, can you give me another
address?" and that is sort of the current payment flow.  And it's a payment flow
of interactivity.

The ideal would be that, wouldn't it be nice if I could just know the identity
of Mike and whenever I want to pay him, I just somehow find a way to generate an
address for him and pay him that way.  And so there are a bunch of proposals
that are out there, but this one specifically leans on the fact of what I was
just saying, that a lot of light clients, they require you to already give out
your xpub, so you might as well rely on that server to hand out addresses on
your behalf.  And the model that you could think of that is sort of similar to
this is maybe a BTCPay Server, where with BTCPay Server, you actually run your
own server and that server, people can connect to it and request an address from
that server.  And so here, instead of you running your own server, you could ask
your light client provider to hand out addresses on your behalf.

In this model, there are two issues.  The first issue is, well, what if the
server hands out the wrong address?  So, that's the first part of my proposal,
how do we solve or how do we defend against that?  And specifically, the way to
defend against that is to have some sort of identity where let's say, Mike, if
you want to use this protocol, you would have to have some kind of pubkey that
people know is you, and you give to the server a list of addresses that you want
the server to hand out on your behalf, and you sign all of them.  So then, when
I want to pay you, I contact the server, I say like, "Hey, I want to pay Mike,
can you give me an address?" and the server gives me an address, and that
address contains your signature, and therefore I know that the server didn't
just give me an address that actually belongs to them and they're trying to
steal my money, and I know the payment is actually going to go to you.  So, that
sort of solves the first problem.

Then there's the second problem, and I think, Murch, maybe you can introduce
this problem, because you asked me about it earlier, which is one of the gap
limits.

**Mark Erhardt**: Yeah, I was wondering from an antagonist point of view, if I
just call that address server a few times with your name and say, "Hey, give me
a new address", won't I be able to exhaust all the addresses that you have
deposited there?

**Ruben Somsen**: Yeah, and so it's not just that you can exhaust the addresses,
it's also a problem with the gap limit, right, in the sense that let's say I
deposit, I don't know, 10,000 addresses to the server.  Then, if you request
10,000 addresses and you use none of them, and then maybe only number 10,000 is
being used, somebody actually pays me on address 10,000, and now I lose my
backup and I recover from backup.  What happens is deterministically, I have to
scan all the addresses that I have and I check the first, let's say, 100
addresses, and if I see there are no payments being made on it, I stop scanning
because I can't just keep scanning forever until infinity to see if there might
be a payment on address 1 million or something.  So, there's a gap limit
problem.  And like you're saying, Murch, there is this problem of, well, if I
only submit a limited number of addresses, can't they be exhausted?

So, what you really need here, and this is something that applies both to BTCPay
Server and this Trustless Address Server proposal, is you need some kind of
mechanism to make it costly for someone to actually request an address, because
if they can do it for free, they can just trivially request a bunch of
addresses.  And so, the way we can make it costly is that there are a bunch of
ways, and one sort of jokingly, Murch, earlier you said, "Well, you could just
pay over Lightning and then get an address".  And theoretically that works, but
it sort of sucks to have to rely on needing your wallet to support Lightning in
order to make a payment onchain.  That's a step that adds too much complication.
But theoretically, that could work.

But no, the thing that we can rely on here, and this idea was already on my
initial proposal, but then Dave Harding, he actually replied to it and he
refined the proposal in such a way that now, I think it's actually quite a nice
solution.  And so basically the solution is that first, the server gives you an
address that is not fresh.  So, they give out an address that they might have
given out to someone else before.  And you create a transaction with that
address, but you don't publish it to the Bitcoin Network.  What you do instead
is you give it to the server, and then once the server has this valid
transaction with the payments that they could send to the Bitcoin Network at any
time to actually force you to pay, only then do they give you a fresh address.
And you recreate the transaction now with a fresh address, and that is what gets
published onto the Bitcoin blockchain.  And then, if at any point you halt the
protocol, let's say you halt the protocol after you've received a fresh address,
well then they can just send that old transaction with the address that is not
actually fresh; they can send that to the Bitcoin blockchain.

So, there is this slight problem where you would say like, "Well, it's not ideal
because it's not a fresh address", but then it's not necessarily the case that
that address already appeared onchain.  It might just be that it has been given
to someone else before and they never followed through with it.  And it's also
the case that whoever did that, they still made a payment to you, but they could
have also just reused one of your prior addresses.  So, if they wanted to make a
payment to an address that was not fresh, they could already do so.  So, I would
claim that there's no real privacy loss here.  And it very neatly solves for the
DoS issue by requiring you to make a transaction first, showing that you
actually have outputs, showing that you're actually committed to sending money,
and only then do you receive a fresh address.

**Mike Schmidt**: So, a sort of penalty transaction of sorts.

**Mark Erhardt**: Yeah, they actually commit funds to show that they were
interested in the address in the first place.  So, obviously the funds have to
be available for spending, and you probably don't want to accept an RBF
transaction in that context.  But that actually neatly solves the DoS problem,
yes.

**Ruben Somsen**: Yeah, and even if the transaction was double spent, right,
even that doesn't really matter that much, because you still prove that you had
an output.  And even in double-spending it, there is a cost, right?  So,
regardless of whether or not the transaction actually makes it onchain, you are
already committing to at least some kind of onchain action, regardless of
whether it was this specific transaction or a double spend or RBF, or something
along those lines.

**Mark Erhardt**: I mean, you can still at least attack all users of the system
at the same time with the same funds.  I mean, you could have some smart server
that fixes that too.  But it makes it costly at least to try and scrape all the
addresses.

**Mike Schmidt**: Yeah.  Is there any other requirement around this transaction
in terms of, I guess, feerate or amount or anything like that, that is in the
proposal?

**Ruben Somsen**: No, I think just the fact, like Murch is saying, that you
could sort of make it more and more costly by making more and more restrictions.
But I think just the very fact that you have an onchain output and you're
committed to spending it, I think that is enough of a mitigation.  And if that
is not the case, then I can imagine you can sort of think of more ways of making
this more and more costly.  But I think for now, that should be sufficient.  And
I think it's already quite a strong enough mitigation to hold off most
attackers.  I don't think it's a full guarantee, and a committed attacker that
is willing to spend funds can still try to attack you, but I think in practice,
this is going to be very unlikely with this kind of proposal.

**Mike Schmidt**: Ruben, I'm curious that you've had a few different proposals
like this.  What do you hope to happen with these?  Is this something that you
just throw out the ideas and you're happy for somebody to take and run with it?
Do you try to evangelize the idea with wallet services or anything like that?

**Ruben Somsen**: Right, yeah, so I think the reason I've been thinking about
this is just because I put out another proposal that we talked about before,
called Silent Payments, and that is all in the spectrum of non-interactive
address generation, where you want to pay someone but you don't want to interact
with them.  And so, in thinking about that, there are all these trade-offs that
you can make, and one of these trade-offs is relying on a server, and that is
sort of like this one.  So, it was really just me thinking about, well, in the
case that you are already relying on the server, what would be the ideal setup?
In the case that you're not relying on a server, so in the case that you really
care about your own privacy, you run your own full node, then I think silent
payments is the much better option; because like I said at the beginning, this
protocol sort of works from a premise that is already not ideal, right, the
premise being you're relying on a server and the server knows all your
addresses.  So, there's one party that you leak all your data to and then
everybody else doesn't learn anything.

So, it's already not an ideal setup, but I think it's this sort of practical
in-between thing that we already have a lot of today.  And then, you know, one
of the issues that I have is that, for instance, there's BIP47, which is a BIP
that tries to allow you to pay people in also a non-interactive way, but the way
they achieve that is by going onchain and putting a certain message onchain, a
notification onchain, in order to exchange shared secrets, and they use that for
future payments.  And the silly thing is that a lot of these wallets that have
this protocol, they still require you to reveal all your addresses to their
local server because these are light clients that have this implemented.  So, my
claim is that in that sort of scenario where you're already relying on a server,
you don't need to go onchain and put these messages there.  And then, in the
scenario where you do not want to rely on a server, in that case I think
something like silent payments makes more sense.

**Mike Schmidt**: Murch, any follow-up there?

**Mark Erhardt**: No, I think that explanation makes a lot of sense for me.  I
think the biggest caveat is here, of course, that you need wallets to implement
this sort of protocol, that they would have an interactive conversation with the
server in order to prove that they're committed to making a payment.  So, yeah,
what do you see as the future plan maybe, Ruben?  Is anyone picking up this yet?

**Ruben Somsen**: So, this is very new, so I think as of right now, I think not
a lot of people are aware of these trade-offs yet.  And I think really, before
when I wrote it, before Dave Harding came in and, I would say, sort of made it a
little bit more elegant, personally I was like, well, this is a thing that
people should probably think about, but I wasn't super-excited about it.  And
now I'm a little bit more on the side of, this actually makes sense and people
could implement this.  I think because it's so early and because I haven't
received a lot of feedback on it yet, I don't have a strong opinion on whether
or not this should be implemented.

So, the way I see this is that people should be aware that this is sort of a
possibility now, and then wallet creators, or people that work on wallets, they
can look at this and maybe they get excited and they say like, "Okay, we want to
try this", and then maybe eventually we'll get a wallet to implement it.  And
then we'll see if it takes off, if it's popular, if it works well.  But I also
sort of agree with you that it does require, again, and this is just a general
problem, whenever you create a new protocol, is the implementation hassle worse
of what you get for it in return?  And I will say that I think it's a real
problem today that it's just a hassle to pay someone multiple times, and the
fact that really the practical way in which we are all paying each other in
Bitcoin is by saying, "Hey, what's your address?  Give me a new address" and
then we get paid.  I think that is such a fundamental thing about making
payments in Bitcoin, and it is just not really great.  So, I do think there's a
lot of room for improvement there.

**Mark Erhardt**: Yeah, certainly a room for improvement.  Although, I do feel
that in most cases where we want to make a payment, there is an interaction
between sender and receiver in advance.  Either they are exchanging a good that
you need to pay for, or there's a service being provided.  The donation case is
really a little special in that sense.

**Ruben Somsen**: Yeah, but I think even in that case, this Trustless Address
Server proposal can also function as you running your own address server.  And
even in that case, you want this DoS mitigation that we just talked about.  So,
I think that DoS mitigation of requiring a transaction to a non-fresh address
first, that even applies to something like BTCPay Server.  So, BTCPay Server
could try to implement this, because I think currently, they don't really deal
with the gap limit that well.  And I think, at least, maybe this is outdated,
but the old answer I've seen to the gap limit is that they just said like,
"Well, just scan more addresses, right?" like, set your gap limit higher and
make sure you actually find everything that you received.

I think there are a lot of places where this can be implemented.  As long as you
want to automate handing out the addresses, I think this can be irrelevant.  And
the current model of actually giving out an address and knowing that the person
you're giving out the address to is someone that is actually going to pay you, I
think that is just not a very scalable model.

**Mike Schmidt**: Yeah, that's interesting.  I hadn't thought of the application
of that outside of this proposal.  Yeah, the BTCPay Server example is another
one where you can use this DoS mechanism elsewhere.  So, yeah, good idea.

**Ruben Somsen**: Cool, thank you.

**Mike Schmidt**: All right, Ruben, I know you want to get back to the
conference.  Thank you for jumping on.

**Ruben Somsen**: Thanks for having me.

**Mike Schmidt**: Cheers.

**Ruben Somsen**: Yeah, this was great.  Thanks, guys.

_LN with long timeouts proposal_

**Mike Schmidt**: So, the first item in the newsletter is this this
Watchtower-Free (WF), long LN payment proposal by John Law, which to be quite
frank, I'm not sure I completely understand.  Murch, I know you've dug into it a
bit.  What's your tl;dr version of this proposal?

**Mark Erhardt**: So, I feel similar about it.  The idea is basically that users
that only casually use Bitcoin still want to be able to make payments and then
maybe have them sit for up to three months before they get pulled in by the
receiver.  And the idea here is you wouldn't want to lock up the liquidity for
all the hops for this long, because users would not allow timeouts that long,
but you still want to be sure that nobody can take your money if you're offline
for so long.  So, if I understand it right, there's basically a special
agreement formed between the sender and the receiver that allows the receiver to
come, even after the Hash Time Locked Contract (HTLC) has expired and revealed
the preimage, to retrigger the payment and have it be issued on the LN again.
And there obviously needs to be certain fallback mechanisms in case that either
the sender or receiver don't reappear later and John Law describes them in his
proposal.

My biggest question that remains here is, why?  Because, if you want to make
basically a one-time payment, one payment in three months, I think leveraging an
instant payment network to basically cash a payment for that long, just it's not
immediately obvious to me why you would want to do that.  Especially also for
the fallback mechanism, where the sender, after a while, can publish a trigger
transaction that basically issues a warning to the receiver that they need to
pull in the payment, or they won't be able to after the trigger transaction.  If
you have already fallback mechanisms that rely on onchain transactions, why
wouldn't you just send an onchain transaction to pay the recipient if this is
the time horizon?

**Mike Schmidt**: Yeah, I agree that the use case is a bit murky.  And I think
to your point about the long lockup, I think it was t-bast who replied in this
thread on the Lightning-Dev mailing list, that was bringing up considerations,
more economic considerations around liquidity, locking up liquidity, and the
costs associated with that from a game theory or economic perspective.  So,
that's another thing to think about.

**Mark Erhardt**: Yeah, liquidity on the LN is not free.  And I think one of the
biggest topics that we hear about again and again is liquidity management; is it
worth having casual users as a Lightning Service Provider (LSP); how much money
do you have to charge for liquidity?  There are proposals for renting liquidity
and of course rebalancing services and submarine swaps to up your balances in
your channel.  So, this proposal feels a little far out there as a mechanism,
because who's going to use a payment that's in limbo for up to three months.  I
feel like this proposal could be improved in the motivation section.

**Mike Schmidt**: Well, unfortunately, you and I are representing the idea here,
maybe not fully informed.  I would say that we did ask John Law to join us; he
was unfortunately unable to join us for privacy concerns.  And so, perhaps
there's more discussion on the mailing list that folks can follow along with in
the coming weeks about this idea if you're more curious about it.  Shall we move
on to PR Review Club?

**Mark Erhardt**: Yeah, let's do it.

_Make AddrFetch connections to fixed seeds_

**Mike Schmidt**: Well, great.  We have a special guest, Martin, to join us to
walk through what was his PR that was covered in the Review Club a couple weeks
ago that Larry did a nice write-up of.  Martin, I think it might make sense for
you to introduce the motivation for why this PR exists and then we can kind of
go through some of the questions.

**Martin Zumsande**: Sure.  So, maybe I'll just start off that I'll also be
talking a lot about addresses, but when I do that, I mean very different
addresses.  So, when I talk about addresses, these are not Bitcoin addresses,
but addresses of potential peers of nodes on the Bitcoin Network.  And, yeah, my
PR is about the so-called fixed seeds.  So, when a new node joins the Bitcoin
Network, it doesn't have any seeds it knows about, so it needs some kind of
mechanism to get some, and there are different mechanisms that exist for this.

One of them is the DNS seeds.  These are particular instances run by, for
example, a Bitcoin Core contributor; I think Pieter has one, some others, and
these would have a crawler that looks through the net and sees whether potential
Bitcoin nodes are online.  If they are, then they have a database of these
potential peers, and then they deliver them to new nodes via DNS.  So, these are
the DNS seeds, but we cannot always use them.  Currently, these are restricted
to delivering IPv4 and IPv6 addresses, but some nodes don't want to be on
Clearnet, they want to only use Tor, for example.  In that case, the DNS seeds
cannot help them, they need to get some kind of nodes from somewhere else.

One possibility would be to manually add a node, but not everyone knows one.
So, that is why the so-called fixed seeds exist.  These are also addresses, but
these are like hard-coded.  In each release, we assemble a list of potential
peers that have been online for a while, and we hard-code them in the Bitcoin
Core release, and these are the so-called fixed seeds.  Then, when a new node
cannot use DNS or doesn't want to use DNS or needs Tor addresses, then we would
query the fixed seeds and add them to the address manager.  That was the
previous behavior.  Then, the address manager is not empty anymore, then we can
make outbound connections to them.

What a new node in the network would do is to choose a couple of these fixed
seeds, connect to them, hope they're still online, and then they have found some
initial peers.  And typically, a new node doesn't have the blockchain, so they
would then do IBD, Initial Blockchain Download, with them.  And the problem with
that is that it places quite a burden on these fixed seeds.  Nobody asked them
to be a fixed seed, they were just randomly picked, we don't know who they are.
So, what my PR does is, it attempts to take the burden of having to deliver the
blockchain to so many new peers.  And the way the PR does this is by not having
them as normal outbound peers, but the so-called AddrFetch peers.

AddrFetch peers are connections that are pretty much similar to normal outbound
connections, with one exception.  That is, once we ask the peer for a bunch of
addresses, which always happens during startup, and we get these addresses from
them, these are usually like a big chunk of 1,000 addresses, after that, we
immediately disconnect them, we do not need them anymore after that, because
they have given us other addresses of other peers.  So, what we do then is we
connect to one of the peers that this AddrFetch peer has given us and use them
to do IBD.  And as a result, the burden of delivering blocks for new nodes will
be more evenly distributed over the network, and the fixed seeds would need to
do less of this.

So, this is what my PR basically does.  It changes the type of connection we do
to these fixed seeds to like a one-time address fetch connection and not have
them as a normal outbound peer.

**Mike Schmidt**: Excellent.  So, to quickly maybe summarize at least my
understanding of it, so if I'm firing up a new node, I could manually provide
peers that I'm aware of that I would like to connect to.  If I don't do that, or
I guess even if I do do that, there's also this DNS seed option, but that's not
available, for example, if I'm on Tor or some of these other anonymity
protocols.  The fallback then is this fixed list, and the list has IPv4 as well
as IPv6, as well as I2P peers that I can connect to, but because that list is
fairly small, the chance of me burdening those operators is high.  And so you've
introduced, instead of a full connection, I simply ask those peers for addresses
of other users to spread out that burden across other nodes.  Is that right?

**Martin Zumsande**: Yeah, that's correct.  And mostly, I mean, even if we are
on Tor and we are fine with reaching other peers over Clearnet, then we could
still use the DNS seeds, I think.  But there is also the option, the so-called
only net options, that we will only make connections to other Tor nodes on your
nodes.  So, we would never want to make a connection through a Tor exit node to
a Clearnet peer.  And in that situation, there we really need the fixed seeds
because even asking the DNS seeds which are not on the Tor network, that would
already be a breach of what the user wants.  And yeah, so that's where we really
need the fixed seeds.

**Mike Schmidt**: Yeah, that makes sense.  Where else is AddrFetch used in the
P2P protocol; when else might I be sending such a message?

**Martin Zumsande**: I think it's not used normally if we don't have any special
setups.  It's like an alternative startup option.  So, if you say, "I don't
really trust the DNS seeds and the fixed seeds neither, but I have this peer
that I trust and I want to use it to just patch some addresses", then this is
not new, this has been a long-standing behavior, you can specify them with your
bitcoind startup and say, "I want to make an AddrFetch connection to this peer".
Then you do the same, basically, ask them for more addresses, and then you have
a bunch of addresses and are connected to the network.

**Mike Schmidt**: Great.  One question I had, and I don't know if you find
something interesting for our audience here, but I know that part of this open
PR is some refactoring.  Is there anything that you think is interesting in
there to discuss with this audience, or is that just more technical details that
maybe isn't interesting for this conversation?

**Martin Zumsande**: I think it's more technical.  I mean, there are different
threats in the Bitcoin Core, and there is one threat that runs all the time and
does open new connections.  So, whenever we have not enough outbound connection,
it would open new connections.  And previously, the fixed seed logic was part of
that thread, which didn't really make sense because we only need to query the
fixed seed once in a lifetime basically, and this other thread would run all the
time.  So, part of my PR is moving this logic into a thread that is only used
during startup, in which also the DNS seeds currently the logic for them exists.
What my PR does is just move some code from the open connection threads to this
DNS thread, which has now a more general name.  And yeah, but it's probably not
that interesting for the general audience.

**Mike Schmidt**: That's fair.  I think that was a good overview.  I have one
more question, and then I'll stop monopolizing and let Murch jump in.  I see
that the PR is still open, and there's some discussion on there.  What remains
to be done to get this merged, do you think?

**Martin Zumsande**: Well, there has been a suggestion by stickies-v to do some
more refactoring.  I mean, currently this new thread where the fixed seed logic
will reside in, it's a bit long and there's been some suggestion to split this
up a little bit into different functions, so that it wouldn't change behavior
but it would make the code more easily readable.  So, that's what I want to do
in the next days, and then I think hopefully the PR can be merged.

**Mike Schmidt**: Okay, excellent.  Murch, do you have any questions for Martin
or comments?

**Mark Erhardt**: I think you two have it covered really well already.  Sounds
very useful to me.  I'm expecting that it'll get merged soon.

**Mike Schmidt**: Great.  Well, Martin, you're welcome to stick around for the
remainder of the recap.  Otherwise, I know that there's a lot of things going on
at the conference that you may want to get to.  So, thank you for joining us.

**Martin Zumsande**: Yeah, thanks for having me.  It was fun.

**Mike Schmidt**: Excellent.

**Mark Erhardt**: We're actually almost through as well.  There's not that much
left on this one.

_LND v0.15.2-beta_

**Mike Schmidt**: Yeah, there is this LND fix.  Murch, maybe you want to give a
quick overview of what happened exactly.  There's a lot of chatter about this,
but maybe you can distill it down for the audience.

**Mark Erhardt**: Yeah, I think there was a lot of news about this already.
There was a very large transaction this week.  Somebody was trying out a 998 out
of 999 multisig with a script leaf in taproot, and the script size of that
script leaf, or rather the input script thereof, was very large.  And so, LN
team and LND uses the BTCD code base as both the optional backend to parse the
blockchain, as well as a library internally for LND, to do all the operations on
the Bitcoin protocol data.  And in the block serialization, or rather the block
deserialization, there was an additional limit that the input script should not
be bigger than 11,000 bytes, and otherwise it would fail.  So, with the
introduction of taproot -- or, this limit did exist in v0; segwit outputs or
inputs in v0 were not allowed to be bigger than 10,000 bytes.  But in taproot,
this limit was dropped, and taproot inputs are allowed to be bigger.

So, this caused basically Lightning nodes, or I should say LND nodes, it was
only affecting LND users, they could not receive blocks after this transaction
was published because they wouldn't progress past this block.  It was fixed very
quickly.  There was a new version out in four hours, the v0.15.2-beta.  And
also, as far as I understand, LND nodes were still capable of forwarding
payments.  They did run into issues when they restarted their nodes, and they
could potentially run into issues if they're not upgraded and their counterparty
tries to close a channel, and they would not see those blocks obviously because
they're not parsing the blockchain anymore.  So, if you're running an LND node
and haven't upgraded yet, you should very much consider doing so.

**Mike Schmidt**: Great overview, Murch.  I don't have anything to add on that.
Good summary.

_Bitcoin Core 24.0 RC1_

Another release which we've covered in the last few recaps, and we'll probably
continue to do so, is just the RC1, which there'll be a series of release
candidates for Bitcoin Core 24.0, not 0.24, and the associated testing guide.
We've sort of jumped into that a little bit deeper in some previous recaps, and
I think that the testing guide's a good place for folks to look if they're
curious about the changes, and how to contribute in the form of testing.  So, I
don't think we need to go into that too much.  Murch, any comments on that?

**Mark Erhardt**: I know that RC2 is in the works already because a couple bugs
have been found and fixed, and also fixes are being backported to 23.0.  So, I
think people that are testing can continue to test this RC, of course, but they
should also consider testing the next one that comes out soon.

_LND #6500_

**Mike Schmidt**: Great.  In terms of Notable code changes, we just had one for
this week, which was a relatively minor LND PR, LND #6500, which adds the
ability to encrypt the Tor private key on disk using the wallet's private key.
So, I guess instead of having a Tor private key sitting unencrypted, if you're
in an environment that you're concerned about that private key material sitting
around, LND provides an option for you to encrypt that Tor private key using
your other private key for LND.  So, a little additional security option there.

**Mark Erhardt**: Yeah, pretty much just that, I think.  It's, yeah, a small
change.  I was going to say also, if you have any questions for us, please
request speaker privileges so we can invite you to ask any questions.

**Mike Schmidt**: That's right, I forgot this week.  Thanks, Murch!  Yeah,
anybody who has any questions or comments, feel free to request access, or raise
your hand so we can get to you.  This is the first recap that we've done in a
while in which we actually have 18 minutes of discussion time if we choose to.
We've been going over recently.

**Mark Erhardt**: Although, if there's no speakers coming up here, I think we'll
also jump back to the conference.  So, any questions?  Mike, what do you think
about the conference so far?

**Mike Schmidt**: I unfortunately have had readings and prep for this Twitter
Space, and I have not joined it yet, so I can't opine.  But knowing how it's
gone in years past, it's a well-run conference and there's a lot of good
technical sessions that we're currently missing.  So, eager to jump into that
for the afternoon.

**Mark Erhardt**: Yeah, similar here.  I'm looking forward to being on a couple
of panels and I'm also going to give a talk to break down how transactions work
under the hood and what the witness discount exactly is.  So, if you are around
at the conference, feel free to join my sessions.

**Mike Schmidt**: Yeah, or watch them recorded once they're available online.
It doesn't look like there are any requests for speaker, so I think we can wrap
up.  I want to thank Murch, of course, Martin and Ruben for joining us this
week.  And I guess we can wrap up early.

**Mark Erhardt**: Yeah, thanks and see you in a minute.

**Mike Schmidt**: Cheers.

{% include references.md %}
