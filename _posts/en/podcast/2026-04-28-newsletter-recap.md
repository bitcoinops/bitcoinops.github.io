---
title: 'Bitcoin Optech Newsletter #402 Recap Podcast'
permalink: /en/podcast/2026/04/28/
reference: /en/newsletters/2026/04/24/
name: 2026-04-28-recap
slug: 2026-04-28-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Gustavo Flores Echaiz are joined by Toby Sharp to discuss
[Newsletter #402]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-4-1/423291048-44100-2-53a78ba068bd3.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mark Erhardt**: Good morning.  This is the Bitcoin Optech Newsletter
Recap for Newsletter #402.  As you can hear, I'm not Mike Schmidt.
This is Murch.  Today, we're talking about a newsletter that describes
an update to the Hornet Node project; we're talking about onion
messages on the LN and how they might be jammed and what could be done
about it; we are talking about the Bitcoin Stack Exchange regular
section; we have three Release candidates and releases to dive into;
and then a bunch of Notable changes to the software.  We're going to
start out today with Toby Sharp, if you want to introduce yourself.

**Toby Sharp**: Hi, I'm Toby and I'm a professional software developer
who's also working on a personal project called Hornet Node.

_Hornet Node's declarative executable specification of Bitcoin consensus rules_

**Mark Erhardt**: Thanks for joining us.  So, Toby, you wrote to the
mailing list and on Delving about your Hornet Node project.  And one
of the things next to your Hornet Node implementation, that has very
impressive speed in IBD (Initial Block Download) that we've reported
on previously, and we had you on before, you are producing a
specification of the Bitcoin protocol.  And your update now described
that you had created a set of 34 rules that completely describe block
validation, from what I understand.  So, you caveated that with, it
is only the non-script block validation.  I assume that has something
to do with transactions, but maybe you could explain that better to
us.

**Toby Sharp**: Yeah, sure.  So, the background on Hornet Node is
that it's a project whose goal is to produce a formal specification
for Bitcoin consensus rules, something that Bitcoin has not had
previously.  And so, although Hornet Node is capable of doing some of
the client tasks already, it's not really intended to be a competitor
for Bitcoin Core, for example.  The main goal is this specification.
And so, that's quite a big project, which in the end would enable
formal verification of clients meeting that specification.  But right
now, I've just got a milestone along the way, which is these 34
semantic rules.  Now block validation, blocks are broadcast to the
network and then a client node has to decide whether a block it
receives is valid or not.  If it's valid, it gets added to the
blockchain; and if it's not, it gets rejected.  So, it really comes
down to a binary decision on that block as to whether it's valid or
invalid.  And there are many, many different logical steps that are
made to decide that validity.  So, what I've done in Hornet Node is
very carefully reverse-engineered that logic into a set of 34 semantic
rules.  Each rule is separate semantically and declaratively.  And
I've built that into a draft specification that I'm sharing with the
community.

You mentioned about script rules.  So, there are sort of different
levels of rule or different levels of logic that have to be applied.
Some rules are applied to the headers, some rules are applied to the
transactions, some rules are functions of the script language, etc.
And so, these 34 rules have slightly different contexts.  And one of
the rules at the moment is just that basically the script has to be
valid.  Now, that's like a meta category in itself, so it requires in
the future another specification or another set of rules which more
accurately or more fully describe what it means for a script to be
correctly unlocking.  So, the other 33 rules are not script-related.
So, what I meant by this non-script rule is basically that these are
the high-level rules that have to be true, and then there will need to
be like a double-click, a drill-down for the script logic
specifically.

**Mark Erhardt**: Right.  So, basically you just black boxed the whole
script validation, how transactions actually work under the hood and
just say the transactions are valid as a whole rule for itself.  And
then, that might be another 100 rules or so later, hopefully not
more.  So, okay.  We're looking at block validation rules, so that
would include something like the difficulty statement is accurate, the
block commits to the prior block hash, the block is not larger than
the allowed block weight limit, that sort of thing, I assume?

**Toby Sharp**: Exactly.  And so, I've sort of carefully separated
these into one semantic invariant per rule.  And each of those
semantic invariants also has an English specification statement.  For
example, a pre-segwit block must not contain any witness data, or each
transaction must contain at least one input.  And so, now I have both
a declarative specification of those rules in English and also have an
implementation, one pure function per rule that enforces that rule.

**Mark Erhardt**: So, you said that it could be used later to formally
verify whether Bitcoin implementations meet all the rules.  So, would
it make it easier to develop nodes that are fully compatible rule by
rule, bug by bug?  One of the reasons why people have been saying for
the last decade that making a specification for the Bitcoin protocol
would be very difficult is that there might still be unintended
behaviors in how Bitcoin Core parses transactions or blocks, and
finding those might be difficult and might be a place where we would
get a consensus failure as we had, for example, with some other node
implementations a couple of years ago in a small aspect of how native
segwit transactions with, I think it was somewhere around the witness
count or something.

**Toby Sharp**: Well, yes, and there was one with the Berkeley DB
stuff.

**Mark Erhardt**: Oh yeah, 2013, March 2013 bug.  We have a whole BIP
about that, BIP50.

**Toby Sharp**: Right, and I also wrote about it in the Hornet Node
paper.  Basically, the whole thesis of the project is to say, yeah,
this is an issue, but I think the conclusion in the past has been
wrong.  I don't think it's the correct conclusion to say, therefore we
must never change the code and keep one codebase forever.  I don't
think that scales.  I think the more correct conclusion would be,
therefore we have to carefully and systematically document all the
logical changes.  Because it's not magic, it's not unknowable, it's
not intractable, it's just a little bit complex and difficult, and
that's not the same thing at all.  So, it's perfectly possible to
decide what all the logic is that's being executed.  And so, my
approach is that the correct thing is to do that, even though it's
difficult, and specify it clearly and explicitly, rather than leave
any such behaviors lurking as implicit, unknown, undocumented aspects
of consensus.  Because if you don't do that, then you stay permanently
in the structure where consensus-critical code has to never be
changed, refactored, improved, touched; you don't get client
diversity; and you don't know if you've introduced a bug in a future
version.  I just don't think that's scalable for something which
really is trying to be a protocol.

**Mark Erhardt**: Right.  So, basically it allows another level of
testing and cross-checking of consensus code implementations, which
might have some interesting synergies with projects like the Bitcoin
kernel, or also inform other node implementations, like your Hornet
Node, Libbitcoin, btcd, knots, other node implementations.  I saw on
the mailing list that you had a bit of a conversation with Eric
Voskuil.  Could you summarize what you took away from that?

**Toby Sharp**: Yeah, so Eric is the lead developer of Libbitcoin,
which is another consensus library and a node implementation which has
been around for many years, and takes different approach in validation
to Bitcoin Core, both with the UTXOs and also with the structure of
validation, parallelism, and so on.  And Eric pointed out that some of
the work that Hornet Node has done independently is very closely
related to what Libbitcoin's done in the past, which is sort of
separation of the consensus logic into individual rules rather than
just kind of weaved throughout the codebase.  And so, that was very
interesting to learn about.  And also, we've taken the conversation
offline now, so Eric continued to email me kindly and set out some
more of his thoughts about particularly the different dependencies of
different rules.  Like, some rules depend only on the transactions in
that block, some rules depend on previous headers, some rules depend
on previous transactions in the chain.  So, we have an ongoing
conversation about how these different dependency connections have
implications for concurrency and how best to organize this draft
semantic spec in order to really make sure that that concurrency is
easily preserved.

**Mark Erhardt**: Cool.  I'm glad to hear that you've found
collaborators, at least to some degree, who knows.  What is the
long-term plan for your specification?  Are you looking to publish it
as a paper, as a BIP?, I think that that might be a good protocol BIP
eventually, for example, or not protocol, specification BIP, sorry.

**Toby Sharp**: Right.  Yeah, so on the collaboration, it's been very
encouraging.  I haven't had a huge number of responses, but I've had
responses from several key people, which is encouraging, Eric being
one of them, of course.  And I also had a conversation this week with
Sebastian, who's leading the kernel project for Bitcoin Core.  And I
was encouraged to hear that the Hornet work is already proving to be
somewhat of an inspiration for their work on that project, which I
find very encouraging.  So, good interest so far.  It would be nice
to hear more from other developers who either are interested in
Bitcoin consensus or who have experience with Bitcoin consensus,
firstly on whether they think these semantic rules are accurate,
representative, helpful.  One could easily dismiss this as, for
example, "Well, it's just a set of rules.  It's likely just a set of
ideas or rules.  It doesn't really change the code, therefore it's
not really doing anything".  But I think actually it is an important
step towards something bigger.  And it's good to actually know that
there's a set of rules for consensus and what they are.  I don't
think it's been clearly written and articulated in a straightforward
way before, so I think there's some value here.

So, you asked about what would the next step be.  So, I wrote a paper
after some of the work that I'd done on Hornet Node back in September.
I'm not sure whether this latest milestone warrants another paper.  It
might warrant an update essay, but also people don't really read
papers like that.  So, maybe you mentioned a BIP.  Can you talk to me
a little bit about how that might work?  Or what do you think an
interesting step would be for this?

**Mark Erhardt**: Well, I'm thinking that one of the gripes people
have had with the Bitcoin protocol is that it had been de facto
specified by just Bitcoin Core being so broadly adopted.  And
therefore, whatever Bitcoin Core did was the Bitcoin protocol.  But
for other implementations that are trying to interact with Bitcoin
Core, and even for different versions between Bitcoin Core, it would
be very interesting to clearly specify what the intended behavior is,
as you said, to be able to argue or reason about it, to even apply
changes where we can and want to, and just to have a clearly defined
set or framework against which we're arguing.  So, if this project
continues to work out the way it seems to be working, and we'd
eventually get a full set of rules that includes transaction behavior,
and so forth, I could imagine that it becomes the official
specification of the Bitcoin protocol.  Because basically, if it fully
describes the behavior, we would be able to also adapt Bitcoin Core to
a specification.  So, in that case, it should.

I mean, there's a lot of work there if you want to go that way.  And
obviously, I can't speak for anyone else but myself, but that sort of
seems to be the underlying potential direction there.  And in that
case, it would make sense if it were published somewhere where the
Bitcoin community sees it and can co-own it with you.  And the BIPs
repository usually has been something that helps towards that.  But
before you get there, it might be easier to keep it in your own
repository, so you're not dependent on BIP editors, or someone else,
to process your updates to it.

**Toby Sharp**: So, I've made the code open-source now and public, so
that's in my repo on GitHub, and people are welcome to go have a
look.  It's a work in progress, it's not a finished work, but people
are welcome to go and have a look, especially at the consensus
validation or the UTXO engine, if people are interested in that.  And
then, I think I've got at least two more major pieces of work to do
before probably I would be considering writing a BIP.  The first of
those is the script validation rules.  As I mentioned earlier, this is
like a drill-down of one of the rules that just says, "The unlocking
script has to unlock the transaction", whatever that means, okay.  So,
that's like a black box of logic in itself.  And I've started work on
this, but there's a lot to do.  I'm trying to find a similar way of
breaking down the rules into a very manageable set of semantic rules,
but there's a lot of work in that.

The second part that I want to do is I've started work on a
domain-specific language, a pure functional, very mathematical
language, which I'm designing specifically for the Bitcoin consensus
specification.  And the idea here is that ultimately, what is working
at the moment in Hornet as declarative C++ would become a pure
declarative DSL specification.  That would be more exact than the
English and more pure than the C++, and that's sort of the intended
final goal, because then that can interface with theorem provers and
formal analysis as well.  So, in the end, I would expect the whole
specification, including the script logic, to be specified in this
pure DSL.  And that's where I want to get to in the end.  The DSL
could then be interpreted or compiled to produce a runtime binary.

**Mark Erhardt**: Yeah, that sounds cool.  So, one of the things that
this reminds me of is that there has been a lot of discussion in the
past few years about other languages that could be used to define
Bitcoin transaction behavior.  There is, of course, high-level
approaches that compile down to existing script variants, which is
something like miniscript.  But there are also efforts to come up with
entire new languages like Simplicity and AJ's thing, for which the
name eludes me right now.  But I was just wondering, have you looked
at those?  I mean, it's slightly different to define a new language,
but maybe it's also interesting in the sense of Simplicity being a
formally verified script language for Bitcoin transactions.  I was
wondering whether there's any parallels here.

**Toby Sharp**: Yeah, that's a very good question.  I think I need to
engage more with that work and understand more about how the simplicity
stuff works.  How that could fit into a Hornet DSL or whether it could
expand into something that specifies the wider block rules.  So,
that's on my to-do stack right now.  But I'd be very interested in
conversations with anyone who knows more about that or who has
engineering experience or opinions on how that could be done.

**Mark Erhardt**: Yeah, I think we had an update recently, where we
learned that Simplicity had now been deployed on the Liquid Network.
So, it's a production-ready project now.  The project by AJ, which I
think that's, I don't remember, I think it's not on Inquisition yet
either, so it's more theoretical yet.  There have been some other
approaches, so those might be some people that have opinions on this.
AJ, Russell O'Connor, people that have been doing a lot of script and
consensus and Bitcoin Core, the usual suspects, you know.

**Toby Sharp**: Okay, yeah, that'll be some interesting future
conversations to have.  Thanks for the recommendation.

**Mark Erhardt**: Sure.  So, I guess we covered pretty well on your
steps towards a full specification so far.  I think we've had a call
to action.  People, if you're working on similar things or would like
to chat with Toby, I believe his email address is on his website.  And
we've written about his website a few times already.  So, you should
be able to find out if you google, "Hornet Node".  Did you have any
other things to share before you drop?

**Toby Sharp**: If you want to read the English specification rules
that's in draft I've published, that's at hornetnode.org/spec.html.
And yeah, I look forward to receiving any emails from interested
parties.

**Mark Erhardt**: Thank you very much for your time, and I hope you
have a nice day.

**Toby Sharp**: Thank you both.  Have a great day.

_Onion message jamming in the Lightning Network_

**Mark Erhardt**: All right, we're continuing with the second News
item.  This week, we're talking about, "Onion message jamming in the
Lightning Network", when Erick Cestari posted to Delving Bitcoin about
onion messages being another jamming vector similar to HTLCs (Hash
Time Locked Contracts).  And the dynamic here is slightly different in
the sense that when we send HTLCs, obviously we do so to facilitate
payments.  So, (a) they can only go to peers that have channels with
us, (b) they're naturally limited because you'll only send HTLCs when
you want to make payments and they're limited by the channel balances,
and so forth.  With onion messages, we have a slightly different
problem, that they can be sent across any P2P connection in the LN.
So, if you weren't aware, Lightning nodes make peer connections with
many different Lightning nodes, not just the ones that they have
channels with, or at least several others beyond the ones that they
have channels with.  And they can use those connections to send onion
messages.  So, the onion message is encoded similarly to the other
payment messages where it is in layers, like one onion wrapped by
another onion wrapped by another onion.  And they would find a route
through the network and send these onion packages in order to deliver
a message rather than a payment.

So, the problem here is that BOLT4 does not specify a limit on the
message size, and it doesn't clearly indicate how messages should be
limited.  And that would enable, therefore, an attacker to just flood
the network with lots of onion messages.  So, nodes have been
implementing a variety of approaches to mitigate unlimited flooding.
But these in turn cause issues now, because if someone floods their
peers with messages, they might start rate-limiting, or using other
mitigations, and then other legit messages wouldn't be able to make it
through either.  So, this email goes into a review of the current
available mitigation ideas for jamming of onion messages, and it
details five ideas.  So, one is upfront fees.  I'm going to package
that with another one called bandwidth metered payments.  Both of
these only work between nodes that have channels.  So, instead of
being able to send onion messages to any peer, you would only be able
to route them along the channel network, which is a subset of the P2P
connection network.  So, that might cause slightly longer routes, it
would create additional P2P overhead because now you have to bundle
every message with a bunch of payments to each hub along the way.  And
so, either with the upfront fees you would pay along the way as the
onion gets unwrapped, there's a payment to each hop; or with the
bandwidth meter payment, I think you're doing an AMP payment and it
just pays everyone in advance of the message, and the message will
only be forwarded if the payment arrived.

There is the idea to either limit the hops so you could only message
peers up to three hops away, or that the limits are based on how much
channel balances your node has in sort of a proof-of-stake kind of
way.  If you have a lot of money in the LN, you're allowed to send
more messages.  The concerns there are that a small limit of hops
would reduce privacy and make it more visible or easier to guess where
a message came from.  And the making it based on how much channel
balances a node has would of course favor larger nodes.  Alternatively,
there was a sub idea here to make it a proof-of-work (PoW) puzzle that
is exponentially more difficult the more hops it has.  But that seems
odd if we're packaging messages into an onion that is supposed to hide
how many more hops there are, if you then can just read off the
difficulty statement and see how many hops it has under the hood in
order to continue all the way.  But maybe I'm missing something.  I
didn't dive too deeply.  Unfortunately, we were unable to have a guest
on for this topic.  So, I'm just doing my best here to sort of walk
you through what I gleaned off reading here.

The last idea is to have a backpropagation-based rate limiting.  And
the idea there is if you get a lot of messages from a connection that
your limit is hit, you would reply at some point with the drop message
reply, which is indicating that you will only accept half as many
messages from that peer for the time being.  So, when your limit is
hit, you halve your limit.  If you get a drop message signal from a
peer, you would then propagate it back to the last node that sent you
a message.  So, in this proposal from '22, this you wouldn't actually
track for every single message where it came from and then apply the
drop message in that direction, but rather you would remember who sent
you the last message.  And then just if there's a large flood of
messages coming to your node, statistically, you would be likely to
send it to the right direction because if most messages are coming
from one source, then that's probably where the drop message will go.
And then, for that peer that received the message, from there it would
go on to the next peer and along the line of wherever the spammer is,
most likely the drop message would halve the limits.  And this limit
would then be lifted after some time, maybe 30 seconds, if the limit
isn't hit again within those 30 seconds.  If it's hit again, it would
continue to just halve the limits and eventually shut down the spam
source completely.

The issue with this one is, of course, either someone could just send
a false dropped message signal, and then it would propagate through
the network and punish nodes that didn't actually misbehave.  Or
statistically, you are hitting the right one, but you would
occasionally hit the wrong one.  If you got ten messages from one
peer and then one more message from another peer to exceed the
ten-per-second message limit, you might punish that 11th message that
was the only message sent by another peer.

So, the context here is that the email is calling to action.  The
developers that are interested in this topic should please join the
conversation.  The author is concerned that currently, the LN is open
to DoS vector or, well, either this flood attack or it preventing
legit messages being sent by flooding.  So, yeah, this is trying to
start a discussion to explore the ideas further so that there might be
a standard or spec how this could be mitigated in general.  Gustavo,
do you have any comments?

**Gustavo Flores Echaiz**: Yes, certainly.  So, I think it's important
to note that LND is currently in the final works of enabling onion
messages and BOLT12 offers.  And when that occurs, which is very soon,
it will now mean that all four major implementations have fully
implemented onion messages and BOLT12 offers, which means that now is
the perfect time to talk about this, right?  Because it could be that
very soon, this actually becomes more relevant, and where its usage
becomes standardized, it becomes too late to address this issue.  So,
I want to also add that the post on Delving by Erick mentions that LND
hasn't yet implemented the rate limiting.  However, in this
newsletter, we cover that LND has now implemented rate limiting as
well.  So, all four implementations proceed in the same rate-limiting
manner when it comes to onion messages.

I also read the conversation and many seem to think that the
backpropagation-based rate limiting proposal by Bastien from the
Eclair team seems to be the one with the least trade-offs.  I wonder
maybe if that's going to be the route that's going to be taken.  It
seems to also be the one with the least technical lift to implement.
But do you think there's any trade-offs related to that method that
maybe were not properly mentioned here, maybe a privacy trade-off?

**Mark Erhardt**: I don't see how there would be a privacy trade-off
here.  What do you mean?

**Gustavo Flores Echaiz**: So, from what I understand here, you're
able to identify the sender that basically pierced through the rate
limit.  Is that a correct assessment?

**Mark Erhardt**: I briefly looked at Bastien's email from 2022 and
the way he was proposing it was to not track, for every message, the
sender of the message and then to assign the punishment according to
the source of the message that exceeded the limit, but rather that it
would just assign the punishment to the last peer that sent an onion
message to your node.  And so, this could of course lead to the wrong
peer, not the source of the flood, to be punished.  But it would also
just be a temporary limiting of the throughput.  So, when you start
with a limit of ten messages per second for a peer that you have
channels with, or one message per second for a peer that you don't
have a channel with, it would just go to five messages per second for
a channel peer and one message every two seconds for another peer, and
would only last for 30 seconds, at least according to that email.

So, I guess you could sort of see which route is limited further now
by when your message gets dropped, but basically you would have to
flood the network in order to see where channels get limited more.
But then, I'm not sure if you could actually learn something
interesting, because as the sender, you pick the route in the first
place, so you know where it was headed.  So, I'm not sure I follow
your privacy concern.

**Gustavo Flores Echaiz**: No, I think you're right.  So, it's mostly
the trade-off here is the false positive, right?  You could be
punishing the wrong sender.  But there's also a note in the end that
says, "A malicious node could also send fake onion\_message\_drop
signals to artificially halve peers' rate limits and suppress
legitimate forwarding without actual congestion".  So, this is also
possible, right?  I guess these are the two trade-offs of this method.

**Mark Erhardt**: Yeah, I was just thinking about that.  I guess
whenever you receive this drop message signal, you would probably have
some sort of heuristic on your end where you say, "I've only seen a
single onion message in the last ten seconds.  So, clearly I'm a
false positive.  I guess I'm rate limited for the next few seconds,
but I'm not going to propagate this".  Yeah, I'm not sure if that
would actually be easy to exploit.  It seems like a few common-sense
heuristics could at least make it not propagate through the network.

**Gustavo Flores Echaiz**: Makes sense.  I also saw that one of these
solutions was trying to reproduce the same PoW commitment from, yeah,
so it's the one from Bashiri and Khabbazian, the, "Hop Limit +
Proof-of-Stake Based on Channel Balances".  So, if I understand
correctly, here there's, well, there's either setting a hard cap on
the maximum sender of hops, for example, three hops, which would have
a trade-off; but also, there's proposal of having the sender solve a
PoW puzzle.  This is similar to the mitigation that the TOR network
implemented I believe last year or two years ago, when they got in a
very similar situation where they were facing a DDoS attack in the
network, right?  So, is my understanding correct there?

**Mark Erhardt**: I didn't look too deeply into that.  The way I
understood it was that the sender was going to have to solve the
entire PoW and then include a PoW in each level of the onion, each
layer of the onion.  But that would certainly slow down a DoS attack.
That would make it also very difficult for embedded chips, like say
VLS, where you have the Virtual Lightning Signer that is actually
talking to a hardware device, that might not be capable of actually
doing PoW.  So, you might limit some of the existing hardware from
participating in BOLT12, which seems like a downside.  And I must
admit, I haven't looked too much into it, but if you make the PoW
puzzle scale by the number of hops, it would make it harder or easier
to guess how many hops there are.  But if you don't scale it by the
number of hops, you might make it too cheap to still flood the
network.  So, maybe it should be more of a PoW marketplace where you
choose how much PoW you send, and when you have multiple messages
waiting, you only send them in the order of highest PoW at the rate
limit, and if your queue gets too big, you start dropping them.  Or
maybe there are more solutions there.  I haven't deeply thought about
this.  This is just a shot from the hip.

**Gustavo Flores Echaiz**: Thank you, Murch.

**Mark Erhardt**: All right.  I guess we haven't really formally
talked about it, but I assume I'm doing Bitcoin Stack Exchange, right?

**Gustavo Flores Echaiz**: Yeah, I assume that too.

**Mark Erhardt**: Good, great, we're in agreement.  All right.  We
have three questions from Bitcoin Stack Exchange this month.  I'm
afraid it turns out that question and answer platforms are a lot less
popular in the day and age of LLMs that just generate answers.  So,
I think that the people that used to answer them are still around,
there's just a lot fewer questions that are interesting being asked.
So, if that's your sort of jam, do ask some more questions on Bitcoin
Stack Exchange.  And this concludes the rant by a Bitcoin Stack
Exchange moderator.

_Why did BIP342 replace CHECKMULTISIG with a new opcode, instead of just removing FindAndDelete from it?_

So, our first question was, "Why did BIP342 replace CHECKMULTISIG
with a new opcode, instead of just removing FindAndDelete from it?"
So, if you've looked into P2TR deeply, or not so deeply, you might be
aware that in script leaves you're not allowed to use
OP\_CHECKMULTISIG.  It is simply not available in script leaves, at
least in v0 script leaves that use tapscript.  Instead, it was
replaced with OP\_CHECKSIGADD, which allows you to increment a counter
of signatures that were valid.  And the underlying design decision
there is P2TR and schnorr signatures is deliberately designed to
enable batch validation, which means that you can take all of the
signatures across a transaction, or even all of the signatures across
a block, and validate them against all of the corresponding public
keys in one swoop.  And this speeds up the validation of signatures
drastically.  So, in order to be able to do batch validation, you have
to know in advance which signature pairs with which public key.  And
with OP\_CHECKMULTISIG, you do not know that.

With OP\_CHECKMULTISIG, you get a number of 2 signatures, and then you
get 3 public keys, or whatever n and m are, obviously; in this
example, they are 2 and 3.  But then you have to see, "Does the
signature fit the first public key?  Oh, that failed.  Maybe the
first signature fits the second public key, or maybe the two
signatures are for public key 1 and 3, right?"  So, you don't know in
advance which public key and which signatures are paired, and
therefore you cannot use batch validation with OP\_CHECKMULTISIG.
However, with OP\_CHECKSIGADD, we require that either there's a valid
signature or there's an empty dummy element in front of the
OP\_CHECKSIGADD or OP\_CHECKSIG.  And therefore, we can batch validate
because we know which signatures we expect to be valid and what public
key to pair them with.  So, that's why MULTISIG works differently in
tapscript.  Any questions or comments so far?

_Does SIGHASH_ANYPREVOUT commit to the tapleaf hash or the full taproot merkle path?_

I continue with the second question, "Does SIGHASH\_ANYPREVOUT commit
to the tapleaf hash or the full taproot merkle path?"  This question
was looking into the BIP118 covenant proposal SIGHASH\_ANYPREVOUT,
which was the original proposal for re-bindable signatures to enable
LN-Symmetry.  Per the current write-up of BIP118, the
SIGHASH\_ANYPREVOUT sighash code requires that the input commits to
the tapleaf hash, but not the full merkle path.  And there is
currently a discussion ongoing, I haven't looked too deeply into it,
but I assume it is because if the same leaf were to appear twice in a
tree, if there were a signature for one leaf, the transaction could be
malleated to point at the other leaf instead with the same signature,
if someone is aware of the tree having that.

I would also like to point out that BIP118 has been in draft since
2017, and there have been multiple other proposals since then that do
similar things, most lately, the OP\_TEMPLATEHASH re-bindable
signature package that just got assigned a BIP number earlier this
year.  So, it's still under discussion, it's still draft, it's not
proposed or complete and therefore proposed for adoption yet.  But I
guess it's a good question to ask what it actually commits to and to
make it commit to the right things.

_What does the BIP86 tweak guarantee in a MuSig2 Lightning channel, beyond address format?_

For the final question of the Bitcoin Stack Exchange segment, we are
looking at, "What does the BIP86 tweak guarantee in a MuSig2
Lightning channel, beyond address format?"  And there are a few
comments on this question, which I think clarified what the asker
wanted to know.  And it seems to me that the actual question boils
down to MuSig2 actually itself guarantees that every signer, every
participant in the aggregated signature, for their partial signature
must apply the tweak in order to go from the internal public key to
the external public key.  And therefore, MuSig2 itself already
guarantees that there can't be a hidden path.  And yeah, so basically
the tweak is more of a property of -- or I should say BIP86 and MuSig2
are a little unrelated in this regard.  But the interesting takeaway
is that MuSig2 already prevents the rogue key attack, which it was
specifically designed to do, and therefore the concern raised by the
question doesn't apply.

All right.  We're going from here to the Releases and release
candidates section, and I believe Gustavo will take over here.

**Gustavo Flores Echaiz**: Yes, thank you much.  So, now we move
forward with the Release and release candidates.  So, this week we
have two releases that have been long-awaited for the past few weeks.

_Bitcoin Core 31.0_

So, the first one is Bitcoin Core version 31, which is the latest
major version release.  So, if listeners want to learn more about all
the changes that happened here, I would point out to the Newsletter
and the episode #400, where we invited a guest, part of the Bitcoin
Core PR Review Club segment, to go through all the testing guide and
talk about all the major pieces here.  But in general, Bitcoin Core
31 includes the implementation of the cluster mempool redesign, which
has been a proposal and something in the works for years, to change
how the internal mempool of a Bitcoin Core node basically handles all
unconfirmed transactions, specifically in complex scenarios where
there's multiple clusters with dozens of descendants, and it creates a
sort of complex logic.  So, cluster mempool is a redesign to better
order and linearize unconfirmed transactions.

The next important feature of Bitcoin Core 31 that I personally really
like, and that we covered more in detail in Newsletter #388 and its
accompanying episode, was the new -privatebroadcast option, which
creates a short-lived connection to broadcast a transaction either
through a TOR or I2P short-lived connection.  So, basically a node
that includes this -privatebroadcast option when using the
sendrawtransaction RPC, it will open a short-term, short-lived
connection, it will broadcast the transaction to that connection to
protect the privacy of the transaction originator, and then it will
close that connection and come back to its regular identity.  So,
that's another big important feature.

Something else that has been in the work for years and has now been
added into the Bitcoin Core binary is the asmap, or autonomous systems
map, data that is optionally embedded into the binary for eclipse
attack protection.  So, in previous versions, you could always bring
your own data for this.  However, now it can be optionally embedded
into the binary, if you build a binary with it.  And then, there's
also many other changes, such as the increase of the default
-dbcache setting to 1 GB, or 1,024 MiB, on systems with at least --
you've got a correction to make there, Murch?

**Mark Erhardt**: So, yeah, sorry, short x course.  Usually kilo,
mega, giga, and so forth refer to a 1000x increase, right?  Of
course, we're interested in multiples of binary in computer science.
So, in computer science, we actually use 1024, which is 2^10.  And
this has been butchered over decades forever, where, for example, if
you buy hard drives, they will list it in MB and then overstate sort
of the capacity, if you think in the actual 24 multiples.  So, the
proper term, if there's a little 'i' in the center, is to replace the
last two letters of the prefix with B.  So, it's kibibytes (KiB),
mebibytes (MiB), gibibytes (GiB), and so forth.  And that indicates
the 1,024x instead of the 1,000x.

**Gustavo Flores Echaiz**: Right.  MiB, right, that was the correct
name in this instance.  Yeah, so the increase of the default -dbcache
setting is now 1,024 MiB instead of, well, I think it doubled on
systems with at least 4,096 MiB of RAM.  And there's many other
updates, obviously, included in this release, so we invite listeners
to check out the release notes for further details.  Like I said,
there's multiple features, and there's dozens of contributors that are
credited in this release.  Anything to add here, Murch?

**Mark Erhardt**: I believe it was 450 MB before.  So, if you didn't
change any settings on your Bitcoin Core client when you started it,
it would use a -dbcache of 450 MiB.  And so, this refers to the cache
that keeps the UTXOs.  So, when we run a Bitcoin node, whenever we
process a block, we would add all of the newly created transaction
outputs to this cache.  And otherwise, when we process any
transactions, we would load from disk the UTXOs corresponding to
inputs, and put them into our cache.  And then, of course, when they
get spent, we would write that back.  So, the cache is tracking
basically the UTXOs that your node currently needs to process blocks
and transactions.  And during IBD, because nodes do not request
unconfirmed transactions during IBD, because obviously they can't
validate them without being at the chain tip, so the RAM set aside for
mempool data structure is used additionally as -dbcache during that
time.  Any mempool RAM that isn't used by default, that's 300 MB --
MiB, I should be precise, right, especially after correcting you!

So, by default, the mempool data structure is limited to 300 MiB and
when that is not used, such as during IBD, that is used as additional
-dbcache.  So, by default, if you hadn't changed anything so far, you
were probably using 750 MiB as -dbcache during IBD.  Now, you will be
using 1,324.  This is just in light of computers having a lot more RAM
now, especially on non-32-bit systems.  And all this change only
applies to systems where at least 4 GiB of RAM were detected.

_Core Lightning 26.04_

**Gustavo Flores Echaiz**: Thank you, Murch.  Next release is Core
Lightning 26.04, which also follows three RCs and has now shipped.  I
want to add that 26.04.1 was shipped very shortly after we published
this newsletter, with a hotfix release addressing build and protocol
correctness issues found shortly after the v26.04 release.  So, if
you still haven't upgraded to this version, make sure to install the
one with the hotfix.  This release mostly focuses on splicing.  So,
following the merging of the splicing proposal into the BOLTs
repository, Core Lightning (CLN) has now enabled splicing by default.
It adds two new commands, splicein and spliceout, including a
cross-splice mode, that within a spliceout, targets a second splice as
the destination of a spliceout.  So, it's a spliceout for one channel
but splicein for another.  And there's also many other features
included in this release, such as the redesign of the bkpr-report,
which is a sort of database inside that tracks income summaries, and
other improvements and plugins, such as askrene, which are used for
pathfinding, so parallel pathfinding and bug fixes.

So, you can see there on the release note multiple other features
related to this, or you could also listen to the episode #398 and
read the newsletter where we invited Dusty from the CLN team to talk
about all the splicing-related changes now in CLN, but also the
splicing proposal that was merged into the BOLTs repository.

_LND 0.21.0-beta.rc1_

So, the next and the final item in this segment is LND
0.21.0-beta.rc1.  So, one key takeaway from this is the migration of
what is called the payment store database.  It migrates from using its
traditional key-value (KV) format to native SQL.  So, if you have
been using LND with the --db.use-native-sql flag, which means you've
been using SQLite or PostgreSQL backends for your LND node and other
parts of your node, well, just be aware that you should note that this
version migrates the payment store to also native SQL.  However, you
can optionally opt out of that.  And, well, this release has multiple
items related to it that I don't think we're going to go into much
detail here, probably wait until it gets out of RC for that.  But you
can find that into the release notes.  I guess the main new feature is
the basic support for onion message forwarding, which we were talking
about earlier in this episode and which I'll cover as well later in
this episode with an item in the Code changes section.  So, that
completes the Release section and I will continue with the Notable
code and documentation changes section.

_Bitcoin Core #33477_

So, the first item is a very interesting one, called Bitcoin Core
#33477.  This one updates how the RPC command dumptxoutset works.  So,
what is all that?  First, let's give a little background.  So, if you
want to build a historical UTXO set dump so that you can create a
snapshot of your UTXO set for the assumeUTXO protocol, so another
node can use assume UTXO with your snapshot and basically sync to the
chain tip faster, and then validate in the background all the previous
blocks before the snapshot height, well, you use the RPC command
dumptxoutset, which will dump the snapshot and that can then be used
by other nodes.  You could use it with the rollback mode, which what
it does is that it goes at a previous height.  It will roll back your
chain, go to a previous height, and then create the snapshot from a
previous height.  So, if, let's say, you're synced to the block
900,000, but you want to create a snapshot to the block 800,000, you
would invalidate 100,000 blocks, and you would go back to height
800,000, and that's when you would produce the UTXO set dump for an
assumeUTXO snapshot.

So, what this PR does, it changes how that rollback mode works.
Instead of rolling back the main chainstate, invalidating a bunch of
logs, suspending network activity, and then coming back to the chain
tip after producing that snapshot, instead Bitcoin Core will create a
temporary UTXO database, it will rollback that UTXO database to the
requested height and write the snapshot from that temporary database.
So, this enables you to keep being in sync with the network, you
don't have to suspend network activity, and it also removes a risk
related to fork-related interference.  So, in the previous mode, if
you would rollback and something would change at the chain tip, for
example, a reorg would happen, then there would be some fork-related
interference with your rollback.  So, all of that is removed.
However, the temporary disk space is a trade-off, and also the process
becomes slower.  So, there is a little performance trade-off, but in
general it's a big improvement, because you no longer need to suspend
network activity.

Just going to finish here that there's an option called in\_memory
that keeps the temporary UTXO database entirely in RAM memory.  So,
if you have enough RAM memory, you could use that to enable faster
rollbacks.  And also, it's recommended to use no RPC timeout with the
bitcoin-cli, because it can take several minutes.  And I believe the
default for the timeout is about five minutes.  So, if you don't
precise that, then you could timeout before it completes the job.
Yes, Murch?

**Mark Erhardt**: Yeah, doing this sort of stuff was a huge pain in
the neck before, because you actually basically had to suspend using
your node to roll it back to a historic state in order to create the
txoutset.  I remember when we used to make images of nodes in BitGo,
we would stop it at certain heights in order to have a snapshot at a
specific height from which we can recover, and so forth.  So, having
a way where you can just virtually roll it back in memory seems like a
huge step up.

_Bitcoin Core #35006_

**Gustavo Flores Echaiz**: Certainly, definitely one of the biggest
items of this week.  The next one is also from the Bitcoin Core
repository.  It's the PR #35006.  So, here, an option is added to the
bitcoin-cli to program, called -rpcid, which allows you to set a
custom string to your JSON-RPC requests instead of the default
hard-coded value of 1.  So, this allows requests and responses to be
correlated if, let's say, multiple clients are making concurrent calls
and are using the same backend server-side instance.  This identifier
is also included in the debug log.  So, now, I believe that Bitcoin
Core is moving towards an architecture where multiple different
instances could call the same -- yeah, sorry, it's c-l-i, not 'cli'.
It's an old habit!  So, yeah, bitcoin.cli.  So, this new option allows
requests and responses to be correlated when multiple clients use the
same Bitcoin instance, called through different bitcoin-cli programs.

**Mark Erhardt**: Sorry, I just felt that the watchers might be
reacting to me reacting to you, so I wanted to make it clear to you
why I was doing that, but you're aware of it, of course.  Yeah, 'cli'
sounds funny to me.  Usually, the way I've always heard it, it's
c-l-i for Command Line Interface, right?

_BIPs #1895_

**Gustavo Flores Echaiz**: Yeah, it's an old habit from learning it
in French.  So, the next, we did a little change this week.  We moved
forward the items from the BIPS repository, because it's more related
to Bitcoin infrastructure, and we have LN items at the end.  So, the
two items from the BIPs repository this week, the first one, #1895,
publishes BIP361, which is an abstract proposal for post-quantum
migration and legacy signature sunset.  So, when this draft was
merged, when this PR was merged, there was an initial version that has
now changed since then.  The initial version had three phases, and
now the latest one has two phases.  So, I wrote my item not based on
this, on the merged PR, but instead the latest phase or the latest
draft when I wrote this item.  So, in the current draft, there's only
two phases.  First of all, I want to say that this proposal assumes
that a post-quantum signature scheme has been deployed and implemented
in Bitcoin and is also standardized.

So, the first phase means that the nodes or clients would be
prohibited from sending funds to quantum-vulnerable addresses.  So,
all the current signature schemes that currently exist in Bitcoin, if
this proposal was to be implemented, once a separate post-quantum
signature scheme would be standardized and deployed, phase A would
prohibit sending funds to legacy addresses, which are all of today's
addresses, to accelerate the adoption of post-quantum address types.
Yes, Murch?

**Mark Erhardt**: Not just to accelerate the adoption, but also to
prevent more funds becoming long-range attack vulnerable, right?  So,
just a small clarification here.  The concern with quantum, of course,
is that with elliptic curve cryptography, such as ECDSA, and the use
of secp, the private key can be calculated from a public key should a
cryptographically-relevant quantum computer arrive.  And the concern
here is that for every output for which the public key that is used to
authorize the payment is public, attackers with a quantum computer
would have essentially any amount of time to calculate the private key
and then spend the funds.  So, the first step would be to move funds
to output types that are not vulnerable to long-range attacks and/or
to output types that internally can have post-quantum schemes.

So, the way I understand it, this would also potentially apply to
BIP360, which proposes a new output type that has a hash in its
construction that hides the public key in the first instance when it
is only paid to, only reveals it upon spending.  But it could have a
script tree under the hood which could have both legacy spending
leaves and post-quantum spending leaves.  So, let me also say maybe,
when I announced the publication of BIP361 after publishing it,
obviously it's not my BIP also to be clear, a lot of people were
confused between the role of BIP editors and BIP authors.  So, BIP
authors write BIPs; BIP editors read them, review them, and when
ready, publish them, as editors do.  So, this is not my BIP.  This is
a BIP by Jameson Lopp and colleagues.  First clarification.

Second clarification, BIPs are proposals to the Bitcoin ecosystem by
their authors.  So, when a BIP is published, it doesn't mean that it
has broad support among the Bitcoin developer scene or that it is
already adopted or that it is scheduled to be merged into Bitcoin
Core, or anything of that sort.  It is a way of presenting an idea in
a comprehensive fashion in a central place where everybody knows where
to find it, from the authors to the Bitcoin community.  Now, as these
proposals progress over time and get more mature, they become more
co-owned by the Bitcoin community as they get more adopted.  But
especially in the draft stage, they're basically just a more thorough
write-up of a concrete idea that someone wants to discuss with the
ecosystem.  So, everybody that's already all up in arms and predicting
that this is the end of Bitcoin, please understand that this is a
proposal that has been put forth to discussion, not a decided final
thing or anything like that.

So, this one specifically is based on both (a) activating itself, and
then (b) previously a post-quantum signature scheme being available.
So, this would follow perhaps both the introduction of a new opcode
that allows OP\_CHECKSIG with a post-quantum signature scheme.  First,
that signature scheme has to be invented and specified.  Then, an
output, the opcode has to be deployed to script.  Presumably that
would be tapscript if we go via BIP360 with the P2MR outputs.  And
then, this BIP would be deployed.  And after three years after it's
deployed, it would start restricting sending to legacy outputs.  And
then, I think after another two years, it would start restricting
sending from legacy outputs, and require post-quantum-resistant proof
that the owner is making that payment.  And there be dragons there
still.  It's not entirely clear yet how such a post-quantum proof
could be created.  This would, of course, especially not be possible
for lost coins.

One of the most controversial aspects of this would be that people
feel freezing lost coins is unacceptable.  Often people say, "Let
quantum computer developers take it".  And I always wonder why Bitcoin
needs to sponsor quantum computers.  Quantum computers don't do
anything for Bitcoin.  It's not like mining or anything, where we
actually have a benefit from funding miners.  Quantum computers don't
make Bitcoin better.  So, it's not clear to me why we, as Bitcoin,
would need to support quantum computer development with a huge bounty
that is currently about a third of all existing Bitcoins.

**Gustavo Flores Echaiz**: Thank you, Murch, for that extra context.
So, yes, this proposal is particularly very abstract and it has
changed already since it was merged.  So, we expect more changes to
happen and it should be taken with a grain of salt that this is
anything sort of close to being materially final, right?  So, this
remains in draft mode and in a very abstract mode as well.

_BIPs #2142_

The next one is the PR BIPs #2142, which updates the specification of
BIP352, where silent payments are proposed.  So, here, a new test
vector is added for an edge case where basically the running sum of
some input keys hits zero after two inputs, but the final sum over all
inputs is non-zero.  So, a naïve implementation could see how two
input keys hit zero and then assume that this fails, however later see
that the final sum actually ends up in non-zero.  So, this catches
implementations that reject early instead of summing all inputs first.
Yes, Murch?

**Mark Erhardt**: So, this would specifically happen if two keys were
constructed to cancel each other out.  So, basically one is minus the
other.  And I think that this was specifically added to BIP352 because
a couple of silent payments implementations were found to not
correctly check for this.  So, if you have implemented silent
payments, and I think this only applies to a handful of people here,
please do check that your implementation passes these latest test
vectors.  And yeah, I keep being excited that silent payments is
making progress, but I'm very much hoping that it soon -- I think it's
still in draft mode.  It should probably move to complete soon and
then -- oh no, sorry, it is complete.  But probably, it should be
moving to final soon, because there's already multiple projects that
use it in production on mainnet.  And hopefully eventually, that will
also include Bitcoin Core.

_LDK #4555_

**Gustavo Flores Echaiz**: Thank you, Murch.  So, now we pass on to
the final part of this section, where we talk about changes in LN
implementations.  So, the first one is LDK #4555, which fixes how
forwarding nodes enforce max\_cltv\_expiry for blinded payment paths.
So, what was happening here is that a blinded path that had expired
was still getting routed into the first hop and was failing deeper
inside.  Instead, it should have been rejected at the introduction
node.  But instead, it passed and got forwarded into the blinded
segment, only to fail somewhere deeper down.  So, now, LDK makes sure
to compare against the inbound CLTV expiry as intended, instead of
against the hop's outgoing CLTV value, so it knows if a blinded path
has already expired, and it will not just try to reach its end to then
fail later; it will just simply fail and kill the payment at the
introduction node.  So, this is a proper implementation to how to
resolve payments faster and not get caught up into a blinded path that
has already expired only to fail later.

_LND #10713_

So, the next one is related to a topic we discussed at the beginning.
So, LND #10713 adds per-peer and global token-bucket rate limits for
incoming onion messages.  So, as we had described at the beginning,
there's a potential onion message jamming attack in the LN.  First,
if you don't implement rate limits, you could just get spammed by
onion messages.  But then, the rate limits themselves also create a
vulnerability, where an attacker could make you reach your global
token-bucket rate limit and you would be dropping other important
onion messages that are directed to you.  So, anyways, we'll see
where that discussion goes, but this item is about LND implementing
what other implementations have implemented, which are weight limits
for incoming onion messages.  So, if you want to learn more about
LND's recently added onion message support, we covered that in
Newsletter #396 and its accompanying podcast episode.  And also, in
Newsletter #370, we talk about similar methods that LND implemented
for gossip messages.  So, this kind of mirrors the work that was done
and covered in Newsletter #370, but adapts it for onion messages
instead of gossip messages.

_LND #10754_

And the final item of this week is also in the repository of LND, PR
#10754, where it's just a small correction, where LND will not forward
an onion message when the chosen next hop is the same peer that
delivered the onion message.  So, it will of course avoid an immediate
bounce because it's forwarding an onion message that was sent by the
same peer where the destination is.

**Mark Erhardt**: That one's kind of funny to me.  So, why would
anyone ever want to send a message that bounces from Alice to Bob to
Charlie and back to Bob?  But when Bob forwards it to Charlie, Bob
wouldn't even know that he's the next target again, because it's
wrapped in an onion that only Charlie will unpack.  So, the message
would just disappear at Charlie's.  So, I guess that would be maybe
interesting as a way to create such flooding messages, if you want to
hit a specific node.  But yeah, I don't think there's ever a good
reason to actually have a bounce-back where two hops are directly next
to each other.  So, just funny, funny that that was an issue, but
also obvious how you might miss that as an optimization of something
that you can clearly drop.

**Gustavo Flores Echaiz**: Exactly.  Well, that completes this week's
episode.

**Mark Erhardt**: Yeah.  Thank you very much for Toby Sharp to join us
to talk about Hornet Node.  Thank you to Gustavo.  It was a fun
episode.  We will hear you again next week without me.

**Gustavo Flores Echaiz**: Thank you.

{% include references.md %}
