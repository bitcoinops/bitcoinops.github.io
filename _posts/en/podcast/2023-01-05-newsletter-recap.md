---
title: 'Bitcoin Optech Newsletter #232 Recap Podcast'
permalink: /en/podcast/2023/01/05/
reference: /en/newsletters/2023/01/04/
name: 2023-01-05-recap
slug: 2023-01-05-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Peter Todd to discuss [Newsletter #232]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-6-11/338888678-22050-1-778ffac380061.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Thank you everybody for joining Bitcoin Optech Newsletter #232
Twitter Spaces Recap.  Happy New Year!  We gave you a week off from newsletters,
but we're back at it.  So, I shared a few different tweets in this Space if you
want to follow along with the newsletter from January 4, which was yesterday.
Quick introductions, Mike Schmidt, contributor at Bitcoin Optech, and also the
Executive Director at Brink, where we fund Bitcoin Core developers and other
open-source work in the Bitcoin ecosystem.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs, and I do a bunch of
education initiatives and Optech work and other Bitcoin Core contributions and
things like that.

**Mike Schmidt**: And Stack Exchange maestro!

**Mark Erhardt**: Yeah, it's been a good year for Stack Exchange, but we could
always use more people reading and writing and voting on stuff.

_Bitcoin Knots signing key compromised_

**Mike Schmidt**: All right, let's jump into it.  First item is a somewhat
timely news item that came out just a little bit before the final draft of the
newsletter, which is Bitcoin Knots signing key compromised.  So, the maintainer
of Bitcoin Knots announced that their PGP key was compromised and warned users
not to download Bitcoin Knots, and there's a concern about trust with the PGP
key being compromised.  And this person recommends that if you downloaded it in
the last few months, consider shutting that system down for now.  That signing
only affects Bitcoin Knots and not other implementations.  Maybe one place to
start is, Murch, what is Bitcoin Knots?

**Mark Erhardt**: Bitcoin Knots is an alternative release of the Bitcoin Core
software, I would say, with a patch set that adds a bit of Luke's personal
flavor to the repository.  I believe that it has a few more options for the user
to make it behave differently in the P2P gossip, for example it's been
supporting full-RBF for a long time, since that's been a topic for a long time.
I think there are maybe a few changes to what transactions got propagated early
on in Knots.  I think it was not relaying transactions from Satoshi Dice, for
example.  I think that it has support for TotalBitcoin, if you're into that sort
of thing!

Yeah, so it is a small patch.  I think it also has an index for keeping track of
transactions that does not exist in Bitcoin Core, which is why, for example,
Wasabi was using it for a while.  On the other hand, as also seen in the context
of this event where the PGP key has been compromised, it is a patch that's
maintained by a single contributor mostly.  I'm not sure how many people look at
Knots frequently and look at the code that's getting merged there.  So, yeah,
that's Knots, I guess.

**Mike Schmidt**: So I guess the tangible risk here is that someone who has
access to that PGP key that was used to sign the releases could sign a modified
malicious version of Knots with that PGP key, and someone may then download that
and check the signature, see that it's valid, and then potentially bad things
happen when they run that software, right?

**Mark Erhardt**: Exactly, that was the concern I think.  I don't think that we
have seen indications of that having happened, and it would probably also be
difficult to replicate all the steps of a release, because that probably
involves uploading binaries to a certain place, announcing it.  So, just even
replicating all of the steps would probably alert the maintainer to somebody
else doing this and he would probably warn us.  But yes, with the PGP key
compromised, somebody else could make a signature of the software release and
even people that check whether it has been signed by the proper key would be
foiled potentially.

_Software forks of Bitcoin Core_

**Mike Schmidt**: And speaking of software forks of Bitcoin Core, our next news
item this week is about two different -- yeah, go ahead.

**Mark Erhardt**: Sorry, can I jump in?  One more thing maybe in the context of
PGP keys being compromised, I am personally a big fan of smart cards.  Basically
that is the same thing as hardware wallets for PGP keys and they come in
different flavors.  One that is well known are YubiKeys, so it is possible to
hold your PGP keys on a YubiKey, which means that the signing operation happens
on this hardware device.  And you can configure your YubiKeys that they will
only perform cryptographic operations when you touch them, which means that even
if somebody gets access to your system, they cannot produce signatures because
they cannot physically touch the hardware device.

So, if you are signing a lot of things with your GPG key and do not currently
possess a YubiKey, or different smart card of course, maybe consider that this
is a prompt to think about getting a smart card to manage your GPG key.  Perhaps
also, if you do upgrade to that sort of setup, to generate a new GPG key,
because if your key was on a hot system for a long time, putting that same key
on a smart card is of course less secure than just generating a new one and
starting over.

**Mark Erhardt**: So, Murch, you use a YubiKey?

**Mark Erhardt**: Like a handful of them or so!

**Mike Schmidt**: Okay, cool.  And then do you sign your commits then?  Is that
how you…?

**Mark Erhardt**: I use them to sign my commits, I use them to SSH into systems
where I authenticate with my GPG key.  And, I can only authenticate with this
hardware device or with any of these hardware devices that hold my GPG key, and
they're PIN protected.  The PIN actually, if you put it in three times
incorrectly, it removes access from that slot.  So, they're pretty theft
resistant, even if somebody watches you put in your PIN, unless they really saw
exactly what you did, it's hard to get it right in three tries.  So, yeah, I
mean obviously security is hard to be absolute or anything, but I think it's a
fairly usable device that can improve your security.

**Mike Schmidt**: Cool, I think that was an informative tangent, so thanks for
bringing that up.  We were talking about Bitcoin Knots, which is a software fork
of Bitcoin Core, and there were, in the last month, two other software forks of
Bitcoin Core.  We've talked about Bitcoin Inquisition previously, and we can
jump into that briefly here; and then there's also Peter Todd's full-RBF peering
node, which is a separate sort of patch set on top of Bitcoin Core.  And just
for any confusion, we're not talking about soft forks of the protocol, we're
talking about software forks of the Bitcoin Core codebase to change certain
features or enable certain things; in the case of Bitcoin Inquisition, enabling
SIGHASH_ANYPREVOUT and OP_CTV on signet; and for a full-RBF peering node, Peter
Todd put a patch on top of Bitcoin Core 24.0.1, that's a service bit when it's
communicating with peers over the network.

So those are two examples.  We had Knots as a third example, which is timely
that all these items are in the same newsletter.  Murch, thoughts since we last
talked about Bitcoin Inquisition?

**Mark Erhardt**: Yeah, I just wanted to clarify that it doesn't activate CTV
and SIGHASH_ANYPREVOUT for _the_ signet, but it starts a second signet where
soft fork proposals for the Bitcoin mainnet can be evaluated.  So, signet is
basically a testbed if you want to experiment with other protocol rules, or want
to run your own private network with experimental software, you could use _a_
signet to run it.  And a signet can be started up by anyone, and it's a little
more comfortable than regtest to create an actual network with it.  You
basically can identify it by, I think there's a network ID or so, and then only
nodes that actually want to connect to that specific signet will connect with
it, but you could have a fully-fleshed signet.

So for example, if you have an enterprise setup where you want to give your
customers access to a test network, where they can run their implementations and
test their integration with your system, then you could run your own signet and
maybe have some traffic on that signet, so that the users see what it would look
like on their integrations, and you can run that all through a signet.  So this
is _a_ signet, not _the_ SIGNET.

**Mike Schmidt**: How sure are you of that?

**Mark Erhardt**: Pretty sure.

**Mike Schmidt**: Okay, I was under the impression that this is running on the
default signet.

**Mark Erhardt**: Really?  I would be surprised that it would activate on _the_
signet because that would of course make all the other users of signet be
exposed to the soft fork transactions that they may or may not interact with.
But I might be mistaken, I haven't read too much into it.  It's been a while
since AJ was at our office to explain it.

**Mike Schmidt**: I think your point stands either way, which is, yes, there is
a default signet, but you can also spin up your own.  Murch and I, I guess,
disagree on whether Bitcoin Inquisition is running on the default signet or not.
Any experts here, feel free to raise your hand and holler at us either way.

**Mark Erhardt**: I saw that Peter Todd joined us and invited him to speak.
Because the next point, of course, pertains to his patch set for the full-RBF
peering node, right?

**Mike Schmidt**: Perfect timing, fashionably late.  Peter, I sent you a speaker
invite, when you're ready.  Murch, any comments on Bitcoin Inquisition and the
fact that SIGHASH_ANYPREVOUT and OP_CTV were the proposals added?

**Mark Erhardt**: I think that might be very helpful for these two proposals in
the sense that both of them have not seen a lot of experimentation.  They've had
a very broad theoretic coverage, but people actually playing around more with
them and implementing them and testing them out would maybe give the movements a
little more zest.  So, I'm very happy to see that they're being made more
broadly available.  I know that OP_CTV has had its own signet before, but I
don't think it's had that much use.  So, maybe this new run added will get these
two proposals more attention.

I think I did see also that the author of OP_CTV closed his PR to Bitcoin Core
about that.  So, I'm not sure if that is currently actively pursued any more,
but I personally am a big fan of SIGHASH_ANYPREVOUT and I hope that it gets
merged sometime soon.

**Mike Schmidt**: So, if you're somebody who likes tinkering around with new
technology or you're a company that may benefit from some of this technology, it
may be worth it for you to read this mailing list post, but also try out
Inquisition.  And there's a couple of IRC channels where there's discussion
going on in addition to the mailing list, and it's a way to provide feedback on
Inquisition, and also these proposals, and how it works for you.  So, I think
that's good on Inquisition.  Peter, you have speaker access, and you came in
just in time to talk about full-RBF peering node patch set.  Welcome.  You want
to introduce yourself real quick and then we can jump into what you're working
on?

**Peter Todd**: Sure.  I'll warn you I'm not sure internet access right now
actually works properly, but we'll see what happens.  And yeah, I've done a bit
of Bitcoin Core stuff on and off for a few years now, and I'm also known for the
OpenTimestamps project, and this is nearly year ten of me advocating for
full-RBF, so maybe at some point it'll become true.

But yeah, as for the more recent thing, I mean all I really did is just took
someone else's existing PR that would have been for Bitcoin Core, and then just
made a few minor fixes and other stuff and rebased it for the Bitcoin Core
v24.0.1 release.  And what this code does is it simply advertises a full-RBF
service bit, and then makes sure that you're connected to at least four other
peers also advertising this full-RBF service bit.  So, in the absence of having
a lot of people running full-RBF, it just makes sure that there is one path for
these full-RBF replacements to get to miners.

**Mike Schmidt**: I didn't know that somebody already had a PR to Bitcoin Core
with that.  Who opened that PR originally?

**Peter Todd**: It was Antoine, I think?

**Mark Erhardt**: Yeah, it's Antoine Riard.

**Peter Todd**: Yeah, I believe that's correct.

**Mike Schmidt**: Okay, that's cool.

**Peter Todd**: And you know, for the record, he did all the hard work here.
Figuring out how to go and pull that onto Bitcoin Core is a bit annoying, but I
just went and took that code and then rebased it so people can keep on running
it.

**Mike Schmidt**: And so the service bit is a little piece of data that peers
communicate to each other about what sort of services they support.  And so
you've added this extra service bit to say, "Hey, I'm a full-RBF node and treat
me accordingly", kind of thing, and then you could do preferential peering based
on that?

**Peter Todd**: Yeah, exactly.  And this idea of using service bits for this is
something I recently came up with in maybe 2015 or 2016 or something.  And at
the time, this was just after segwit activated, so I reused the way that segwit
nodes would preferentially peer to each other and make sure that they'd always
connect to each other.  These days, the term preferentially peering and how it's
employed, is I think maybe a little obsolete, but certainly to ensure that
they're peering with other full-RBF nodes.

Why this really matters is because your nodes, at least on outgoing connections,
connect to other nodes randomly, approximately.  They have this sort of
bucketing algorithm where they take all the IP addresses they know about, slice
it up into 16, or I think on IPv6 it's like 32-bit or something prefixes, and
then connects to random nodes by picking these prefixes at random.  And
obviously, if there's not very many other nodes with your transaction relay
policy, the reality is transactions aren't going to get relayed.

In experiments other people have done, as well as there's some mathematics
behind this, effectively needs something like maybe 8% to 20% of nodes running a
particular policy with the randomization for transactions following the policy
to widely distribute around the network.  That's kind of the threshold where
percolation, as it's called, happens.  So, transactions can get from kind of one
node to another with high reliability.

**Mike Schmidt**: So how does the patch work in terms of finding those
additional four peers?  Are you just continuing to open up more than the usual
number of connections until you find those four, or how do you find them?

**Peter Todd**: Well, Bitcoin already has a mechanism where in addition to
opening eight outgoing peers, it also opens another two outgoing peers that are
-blocksonly.  I'm not too familiar on what exactly the logic is behind that, but
my understanding is this is meant to do a better job of getting blocks to relay
reliably.  So, my understanding is that basically, these kinds of mechanisms
were then reused to just add an additional four peers that advertise the
full-RBF bit.

**Mike Schmidt**: Gotcha.

**Mark Erhardt**: Maybe I can jump in here a bit.  So Bitcoin Core nodes
advertise which services they provide on the service bits.  That includes, for
example, "Hey, I have a full archive of all -- Peter, you have some background
noise; while you're not talking, could you mute?  So, for example, it advertises
if you have a full archive of the blocks, and you could potentially help someone
to synchronize with the network.  That is the -- no, I'm missing the name of the
flag.  But there's also one, for example, that pruned nodes advertise, that they
don't have the full set of all blocks, but they will be able to give you the
last, I think it's 144 blocks, so the last day of blocks.

**Peter Todd**: It's 288.

**Mark Erhardt**: Oh, yeah, the last two days.  Okay, thank you.

**Peter Todd**: Yeah, those are NODE_NETWORK and NODE_NETWORK_LIMITED, if I
remember correctly.

**Mark Erhardt**: Yes, correct, thank you, and there's a few other ones like
that.  So, this is the service flag that is being advertised here, and it's on
BIP26; I think that was previously unused.  And, yeah, that's what I wanted
to...

**Mike Schmidt**: Is the service bit in the dispatch the same one that's used in
Bitcoin Knots?

**Peter Todd**: Yes.  I mean, it matches the one I picked all the way back in
like 2015.  And the one slightly curious thing is, so Bitcoin Knots advertises a
bit, but it doesn't have code to do peering with it.

**Mike Schmidt**: Okay, yeah, that makes sense.  So, you will seek out these
preferential peers, but Bitcoin Knots won't; it'll just, I guess, know to relay
such transactions to those peers.

**Peter Todd**: Well, I mean Bitcoin Knots, the way the logic works is simply,
if full-RBF is enabled, it advertises a flag and that's it.  There's no more
code related to that than that.  But it does mean that with nodes running the
peering patch, since you have this big bunch of Bitcoin Knots nodes, I think on
the order of like, you know, 200 to 300 on the network, there are a lot of peers
to connect to.  Of course, this also means that I had to manually run, I think
it was something like eight or maybe four to eight Bitcoin full-RBF peering
nodes before transactions started propagating reliably, because the Bitcoin
Knots nodes weren't quite interconnected enough to make it work, and you'd sort
of get islanding where every single peer would be a Bitcoin Knots node.

**Mark Erhardt**: So, my understanding is that if you have in a network a node
degree of two, on average you will form a fully connected graph.  So, if every
full-RBF node on average has two peers that also understand and propagate
full-RBF transactions, you will end up with a subgraph that will propagate, with
a high likelihood.  Nodes will be part of this subgraph that will propagate
full-RBF transactions.  So, this is why it only takes a very small proportion of
all nodes to support full-RBF, and it will actually become the de facto policy
on the network, especially if they're peering, because they will actively seek
out those other nodes that do full-RBF, it will form this subgraph where the
transactions will propagate.

**Peter Todd**: I think what you said is basically correct, but if I understand
what you said correctly, I think you said you needed a degree of two, and I
think the number's actually a little higher than that.  Because, I've never
tested this in a simulation carefully or anything like that, but I think two is
just enough to form chains that get disconnected; whereas I think three or four
is what it really takes to actually ensure that subgraph.  But certainly four
works and certainly eight works well too.

**Mark Erhardt**: Yeah, sure.  I mean, if you have even more peers, it will
work.  But I believe a mathematician with a background in graphs told me that on
average, a degree of two is sufficient to form a connected graph.

**Peter Todd**: Well, I haven't studied graph theory since high school, so I'll
take his word for it!

_Continued RBF discussion_

**Mike Schmidt**: Well, yes, I guess there's some of the theory behind it.  But
segueing into the next item from the newsletter, Peter, you did some probing to
actually figure out the real data on the network in terms of full-RBF
replacement.  What did you find with that research?

**Peter Todd**: Well, so what I did was very simple, which is I took a standard
Bitcoin Core node and I manually added outgoing connections limits to, say,
10,000 or something, you know, something very big, recompiled it.  And then I
manually added every single Bitcoin Core v24 node on IPv4 that was not
advertising the full-RBF bit and waited for the nodes to connect to as many as
possible.  And I think it connected something like 700 or 600 nodes at once.
And I ran it with full debugging, in particular debugging transaction inventory
announcements, and then I just watched as full-RBF replacements came in and I
just counted how many of my 700-or-something peers, or 800, whatever the number
was, were advertising me those full-RBF replacements.

I have my OpenTimestamps calendars that I run.  They're doing true full-RBF
replacements with significant time delay between transaction one and transaction
two and so on.  So, that gives me a measurement, well, how many of these nodes
in total are actually running mempool full-RBF without running, say, Bitcoin
nonce or the preferential peering patch.  And long story short, when you crunch
the numbers, it looks like the number was roughly 17% at minimum.  And why I say
at minimum is because I could only observe nodes that both had full-RBF enabled,
and also were sufficiently connected to other full-RBF nodes that propagation
works.  So, essentially the true number is even higher than this.

Of course, the other caveat is I was only measuring IPv4 nodes and I could only
measure IPv4 nodes that were listening.  So, potentially the numbers on other
types of nodes running on different ways of connectivity or potentially
non-listing nodes is different, but I think that gives you an indication.  It's
quite a high percentage.  Now, that's not a high percentage of all nodes in
total, because lots of nodes just haven't been upgraded to v24 yet, but
certainly of the people actively upgrading, a lot are turning on full-RBF.

**Mike Schmidt**: I'm looking at the, and I don't know, there's probably a more
authoritative source for this, but the bitnodes.io website, where they show the
map of different nodes.  I'm seeing 24.0 combined with 24.0.1 being about 19% of
the network according to their analysis.

**Peter Todd**: Yeah, I think that number is basically correct.  I got my IP
addresses off the DNS seed I run, which a biproduct of how it works happens to
have a list of all the nodes that it knows about through the Gossip Network, and
I believe not only nodes it knows, but nodes it's actually tested and at least
once or twice has gotten a connection to.  So, there's different ways to count
this, but I think bitnodes is roughly correct, I think my estimate was roughly
correct.  They kind of agreed with each other, so that sounds about right.  And
when you do, say, 17% of 17%, that's well under that sort of 8%-ish threshold to
Core transactions by themselves propagate.  But that number isn't really correct
because after all, nodes have a lot of incoming connections too, and in practice
they often have far more incoming connections than outgoing.  So it's a bit
complex there.

**Mike Schmidt**: Okay, yeah, so about 20% running a 24x variant, and then about
17% of those appear from your research to be doing full-RBF replacements.

**Peter Todd**: Correct.

**Mike Schmidt**: Cool.  Murch, what do you think about this all?

**Mark Erhardt**: I think that if these numbers hold up -- okay, I think that
people that are heavily invested and interested in full-RBF might be the first
ones to upgrade to 24.0 in order to be able to run the flag.  So, I don't think
that it's necessarily indicative for all the people that will be upgrading to
24.0 in the next few months.  But if those numbers held up, we would be very
close to having a subgraph that propagates full-RBF reliability for all the
listening nodes, at least, that propagate full-RBF.  Because of course, the
listening nodes, they tend to have not only those eight outbound connections
plus two -blocksonly connections plus feeler connections, but they will also
make connections to some about 110 other peers.  And if anyone advertises these
transactions to them, they will learn about it.  So, the listening nodes
generally have a lot more connections to hear about full-RBF transactions on the
network.

**Peter Todd**: So, one thing I'll just say in response to that is, the thing is
the way I did my measurements, because I could only measure transactions that
actually propagated, and I wasn't probing nodes actively.  In fact, we already
have a subgraph that propagates full-RBF replacements reliably, it's a fairly
reliable subgraph.  And if you're connected to a lot of nodes at once, you're
pretty much guaranteed to receive these connections.  And I think the nuance
here, of course, is not everyone's going to run the standard eight outgoing
connections.  I mean, I personally am running a node that I just manually
connected to all the v24 nodes I knew about that run full-RBF to make sure
propagation works, and I'm sure other people are doing this too.

Looking at my own nodes that I run, it's easy to see that some IP addresses are
connected to very large numbers of nodes.  And while I haven't investigated
exactly what transactions are propagating and so on, making this subgraph work
actively is fairly easy.  The trickier thing is more getting enough IP addresses
that are running full-RBF that in a non-listening node, they will have a
full-RBF node in their outgoing connections reliably.

**Mark Erhardt**: Yeah, and you're taking all the slots from them!  I mean, I'm
trying to point out that if every one of us that wanted to get this full-RBF
subgraph going connected to hundreds of full-RBF nodes, then those non-listening
nodes would have very few slots to connect to that.

**Mike Schmidt**: The next RBF-related item from the newsletter was, and I'm
glad we had Peter Todd today, reconsideration of First Seen Safe (FSS) RBF.
Daniel Lipshitz posted to the Bitcoin-Dev mailing list about this idea, which is
essentially an idea that, Peter, you had from 2015, it looks like.  Do you want
to give a quick overview of what the FSS idea was, and if there's anything to
add from this recent mailing list post?

**Peter Todd**: Yeah, well, I mean like you said, this dates back to 2015 before
opt-in RBF was proposed and implemented.  And basically, the so-called FSS rule
is just saying, if we want to make unconfirmed transactions reliable, one way we
could go do that is say that transactions can only be replaced if they continue
to pay all of the outputs that they already paid.  And the name, First Seen
Safe, just refers to the policy of the first-seen transaction and first-seen
safe being, well, it's so-called safe because you're still paying whoever you
were paying before.  And you would have to add more inputs essentially to get
more coins to go and bump fees.

But I think the bigger issue is this doesn't address the use cases for full-RBF.
I mean, the number one reason why it got merged was because it helps with
multiparty transactions.  And that use case for multiparty transactions just
does not work with FSS.  So, I think that's really a non-starter.  And
unfortunately, I think when Suhas went to create his PR to get full-RBF removed,
something he wasn't really clear about is that while transaction pinning
degrades the use case of full-RBF for multiparty transactions, it's still a fact
that adding full-RBF makes a tax on multiparty transactions by double-spends far
more expensive than it would be otherwise, because transaction pinning is tax
expensive.

All of the ways of doing transaction pinning involves spending quite a lot more
money than you would without it.  So, especially for things like coinjoin,
full-RBF is a no-brainer.  And this gets back to the whole political thing of,
well, what use cases do we prioritize?  The fact is, multiparty transactions and
unconfirmed transaction acceptance, they conflict, and you can't really have
both perfectly without making other trade-offs, such as privacy.  So, I don't
think Daniel's idea is going to get any traction, and I kind of hope it doesn't.

**Mark Erhardt**: Yeah, I want to double down on that, because I agree with
Peter that a FSS RBF is completely unattractive.  So, the whole point of RBF is
that you can make an efficient replacement of a previous iteration of your
transaction.  So, if you're trying to pay, say, Alice, you would create a new
variant of the transaction that still pays Alice, and then maybe has more fees
but a smaller change output; or you would add a second payment to Alice and also
Bob, and then make a bigger change output because you added another input.  But
it gives you a lot of flexibility in crafting that new transaction without
necessarily always growing the transaction size.

With FSS RBF, if you have say five iterations to bump the fee rates, every
single iteration adds another input and adds another change output.  So after
bumping it five times, you would have a transaction that pays you six change
outputs back to yourself.  It would completely bloat your UTXO pool, and at that
point there is just absolutely no advantage over doing CPFP in the first place.
So, instead of bumping the transaction by replacing it, you bump it by chaining
a second transaction off of it with a CPFP transaction, and you get the same
effect that you create a change output back to yourself, but at least you've
already spent the previous change output, so it doesn't bloat your wallet
completely, and it keeps the transaction ID of the previous transaction the
same.  So, I just don't see, if we got RBF FSS, what is the freaking point of it
in the first place?

**Peter Todd**: So, I'll make one minor correction, that in some ideas of what
FSS could be, you would go and simply make the change output bigger, which
depending on how you influence it would be okay.  Of course, I've also heard
people argue that you can't even do that, you do have to do the really
inefficient way like you described.  But in general I agree, it's just very
inefficient, it doesn't work with RBF use cases.

For the multiparty transaction use case, which I think is definitely the most
important one, why you want this is to completely replace one unwanted
transaction with a different transaction that's completely different, a good
example being for, say, coinjoin, where in case of something like Wasabi
coinjoin, you might have a coinjoin with a couple of hundred participants.  And
currently, if one of them double-spends their input at the right time, and that
double-spend gets to a lot of miners, you'll have one transaction with one
input, potentially one output, holding up a transaction with 500 inputs, 500
outputs.  And FSS just cannot address that use case at all.  And if we don't
have this, we do get this ugly griefing attack.

**Mike Schmidt**: Sorry, go ahead, Murch.

**Mark Erhardt**: No, go on.

**Mike Schmidt**: I was just going to transition to AJ's reply.  He's actually
replied to an earlier thread about the zero-conf apps in immediate danger, and
it's a bit more philosophical about the motivation for different groups to be
doing full-RBF.  I think it would be hard for us to maybe summarize that entire
philosophical post here, but Murch, were there any takeaways from that that you
thought were notable for this discussion?

**Mark Erhardt**: I think that one of the arguments that's a little
underappreciated sometimes in this discussion is, if full-RBF is economically
rational for everyone, why has it been such a stable equilibrium for seven
years?  I think there's a bit of a point to, well, miners have this huge
hardware investment and they are trying to keep the overall Bitcoin users'
happiness high, especially the people that send a lot of transactions, so maybe
in the long term it is actually not interesting to make it easier to
double-spend.  But I find that, well, I don't want to reiterate the whole debate
here.

I find that all sides have interesting points in this and perhaps one
underappreciated thing is that the Bitcoin protocol developers that are pushing
for full-RBF, they have thought a lot about the theoretic construct and the
network propagation rules and the mining incentives; but the people that
actually currently use zero-conf, they have a lot of economic activity on the
network and they have skin in the game.  So, it's just these extremely different
perspectives on it that make it sometimes feel like people are just talking
about completely different topics.

**Peter Todd**: So, I think with regards to economic incentives for miners, I
think you can summarize what's happened in a very simple way, which is to say
that the amount of money you earn by full-RBF hasn't been enough to outweigh the
angry emails you get.  And honestly, I think that really is exactly what it is.
As long as it's disabled by default and the amount of money involved is very
small, miners just aren't going to bother because when you turn it on, you get a
whole bunch of angry emails that are annoying to deal with.  And I can tell you
that of the few miners that have turned it on, they have told me that they've
had angry emails over this and it's annoying!

Now, conversely, I've also been told by some of the people who've turned this
on, and I'll reiterate, these are just very small mining operations.  At least
one of them, they told me their main motivation for doing it was, they said,
"Well, screw John Carvalho.  I mean, this is obviously a good idea, and I'm
quite happy to see him sad about it".  That's the kind of motivation that is at
play with this small amount of money.

Part of why I did my full-RBF bounty was to just provide a bit of psychological
incentive to maybe break that deadlock and get the right attention necessary to
get some miners to go to the effort of turning this flag on.  Because after all,
blocks these days, in terms of fees, they tend to earn on the order of $1,000 to
$2,000 worth of fees per block.  You need a lot of money to make it worthwhile
to go do things when fees alone are that high.  And also, the block subsidy is
another $100,000.  It's just, the full-RBF transactions are another $100 per
block on top of that, and they're not even that.  The economic incentives just
aren't there to actually do anything, even though in theory, yes, they are.

**Mike Schmidt**: Murch, anything else on the news section, RBF or otherwise?

**Mark Erhardt**: Yeah, I just wanted to briefly agree with Peter that
currently, of course, the dynamic is that the subsidy is about two magnitudes
bigger than the transaction fees in total.  So, it'll take some time for
full-RBF to have a lot of impact on the overall revenue of miners.  I think
other than that, we can wrap up the news section.  We've spent quite a bit of
time on this this time, so maybe we'll move a little quicker on the rest.

**Mike Schmidt**: Peter, thanks for joining us.  You're welcome to hang out as
we talk about releases and PR merges, but you're also welcome to jump off if you
want to go back to sleep!

**Peter Todd**: Thank you, I might just do that!  Talk later.

**Mike Schmidt**: Thanks for joining us, cheers.  All right.  Releases and
release candidates, back to the Newsletter #232.

_Eclair 0.8.0_

We have Eclair 0.8.0, which is a major release of that Lightning implementation,
which adds support for zero-conf channels and Short Channel IDentifiers (SCID).
And then we also point to the release notes, which includes a bit more detail
and also adds notes in the release notes that there's experimental support for
dual-funding, which is pretty cool.  Murch, any thoughts on this Eclair release?

**Mark Erhardt**: I have not looked at it much, no.

**Mike Schmidt**: Okay.  Yeah, I thought that the experimental dual-funding was
cool.  I happened to see that before this Twitter Spaces, otherwise I may have
suggested that we note that in the newsletter.

**Mark Erhardt**: I mean, dual-funding has potential to be a big UX improvement
for new channels coming online.  The biggest issue with new channels coming
online now, of course, is that all of the balance sits on one side, so movement
is restricted in only one direction.  And if we get dual-funding to be broadly
adopted across the network, where both parties add some funds to the channel, I
think that the initial channel creation will have a bit of a better UX because
you can immediately send and receive.  So, I'm generally happy to see more
implementations working on that.

_LDK 0.0.113_

**Mike Schmidt**: Next release here is from LDK 0.0.113, and there is a huge
list of API updates in these release notes.  I think we covered a chunk of these
over the last month or so in the newsletter and our discussions here.  Murch, I
don't know if there's anything that stood out to you in that list of API updates
that you wanted to call out.

**Mark Erhardt**: I'm sorry, I have not looked at it.  But I should mention that
this week, we're starting an LDK Topic Week on Bitcoin Stack Exchange.  So, if
you happen to be one of the people that are playing around with LDK and/or using
it to implement support for your existing wallet for the Lightning Network,
please do ask your questions on Stack Exchange with the tag, LDK.

_BDK 0.26.0-rc.2_

**Mike Schmidt**: Next release here was one from the newsletter, which is
0.26.0-rc.2, but I see that as of yesterday, there is a 0.26.0 release out.  And
the summary of this release is improving Fulcrum Electrum server compatibility
and fixing public descriptor template key origin paths.  I've never played with
Fulcrum, I guess it's a fork of Electrum.  Are you familiar with it, Murch?

**Mark Erhardt**: I am not, I'm sorry.

**Mike Schmidt**: Okay.  So I guess if you're using BDK and using this Electrum
server fork, there's some enhancements there.  And then there's also release
notes that aren't in the tag that we link to, but if you go on GitHub to
releases, you'll see the release 0.26.0, and that provides a bunch more list of
fixes, changes, and summary of the release, so check that out.

**Mark Erhardt**: I think it's also interesting they bumped the hardware wallet
integration dependency, so HWI, from the Bitcoin Core repository.  So, I think
they're working on having better hardware wallet support.  There's a trend that
I'm generally excited about, is how many of the implementations are using these
libraries that are coming out to have hardware wallet support.  Similarly to our
first news item about the key of the maintainer for Bitcoin Knots being
compromised, having your hardware wallet manage your keys, this intermediates it
from a hot system.  There are open questions on how secure that is, or how that
changes your, well, your thread models and how to manage your keys and what
backups you need, and things like that, but generally this interoperability of
hardware wallets with different wallet software is a very cool trend this year,
well, last year.  I still have to adjust to 2023!

**Mike Schmidt**: You've got another week of that, then no more condolences for
that!

_Bitcoin Core #26265_

Moving on to the Notable code and documentation changes for this week's
newsletter, Bitcoin Core #26265.  This is relaxing the non-witness serialized
size of transactions from 82 to 65.  We had instagibbs chatting with us on a
previous Optech Recap about this and the motivation for it and the mailing list
post around it.  That PR at that time we discussed, or this PR, was already open
at that time and got buy-in resulting in the mailing list post, our discussion
with him, and now this is officially merged.  Murch, what are your thoughts on
advancing this policy?

**Mark Erhardt**: Yeah, I noticed that the one that merged that just restricted
it, or that allows everything greater than 64, there was also discussion about
allowing everything but 64.  And I briefly talked to one of the reviewers
earlier today, and I think that my takeaway is that in the long term, we can
still consider allowing all transaction sizes, except for 64 bytes, but maybe
it's a good first step to allow 65+, a person, and think a little more about
what it means to allow transaction sizes smaller than 64 bytes.  Anyway, there
was these competing two variants.  I think we've also covered this a lot in the
past few weeks, so let's move on.

**Mike Schmidt**: Okay, we won't call on instagibbs to come up and give a sermon
on that again.

_Bitcoin Core #21576_

Bitcoin Core #21576, allowing wallets using an external signer, like HWI, to fee
bump using RBF in the GUI, and also using the bumpfee RPC.  It looks like
potentially this was either an error or just not possible previously to do fee
bump if you needed to sign externally.  So, this PR changes that and allows you
to externally sign fee-bumping transactions.

**Mark Erhardt**: Yeah, I think one of the problems was how Bitcoin Core wallet
tracks UTXOs that it doesn't have the keys for itself.  It's a bit of a
discovery problem to know that it can sign and how watch-only wallets get
implemented.  So I think it was just a lacking feature, not a bug.

_Bitcoin Core #24865_

**Mike Schmidt**: Next PR is Bitcoin Core #24865, which allows a wallet backup
to be restored on a pruned node as long as that pruned node has all of the
blocks produced after the wallet was created, and the wallet has a timestamp
which this change then coordinates that timestamp with the most recent block
that the pruned node has and makes sure that it has all those blocks.  And I
guess previously, there was just an error if you tried to restore a wallet on a
prune node, whereas with this change you're able to restore as long as you have
the blocks since that timestamp.  Murch might have some familiarity with this.

**Mark Erhardt**: I have not looked at this too deeply, but a Bitcoin wallet
generally remembers when it was created, and that is helpful, especially for
making sure that it found all the funds that it can spend.  If you know at what
timestamp a wallet was created, you generally do not have to look whether you
got paid before that, right?  So it is an efficiency improvement for what
section of the blockchain to search for, for having gotten paid, and I believe
that previously, importing a new wallet to Bitcoin Core would always prompt a
rescan on a pruned node.  So, because you don't have all the old nodes, you
would generally just search the blockchain from scratch and download everything
again.

Or maybe you're right and it was only an error, but downloading the whole
blockchain again is of course a lot of bandwidth and computation.  So, being
able to just search from the blocks that you still have is a big improvement.  I
believe that there's also a related PR that allows Bitcoin Core to make use of
the, what is it, the compact block filters, which gives you basically a content
directory of what is included in a block, or rather a way to look up whether
certain keys are touched in a block.  And that way, you can just get those block
filters from other full nodes and see what blocks you have to acquire to see if
there are relevant transactions in them, instead of doing a full re-sync of the
blockchain.

**Mike Schmidt**: Yeah, I think I saw in the code that there actually was a
statement that if it's a pruned node then you can't do a wallet restore, but I
may have missed that or interpreted that incorrectly.

**Mark Erhardt**: No, if you actually looked at it, you're probably right!
Sorry.

_ Bitcoin Core #23319_

**Mike Schmidt**: Careful, careful!  Next PR is Bitcoin Core #23319, which
updates the getrawtransaction RPC to provide additional information if you set
the verbose parameter.  And quick question for you, Murch, if you took a look at
this, is it the verbose parameter or is it the verbosity parameter, because I
think this PR introduced the verbosity parameter?  But I guess either way,
you're probably scrambling to look in there now.  It provides additional
information about the transaction, including the fee, as well as information
about the outputs from the previous, the prevouts essentially.  So if you need a
little bit more information, this PR adds the parameter for you to get that
additional information via the raw transaction RPC.

**Mark Erhardt**: Oh, that's a good catch.  There's actually now a verbosity and
a verbose parameter apparently, so I'm surprised that got merged.  Yeah.
Anyway, sorry.

**Mike Schmidt**: Well, if only we had more people reviewing this, then maybe we
would have caught it.  You have these Monday morning quarterbacks looking at it
for their Twitter Space and see something, of course.  Any other comments on the
verbosity edition here?  Just a little bit more data in the RPC.

**Mark Erhardt**: Yeah, it seems pretty straightforward.

_Bitcoin Core #26628_

**Mike Schmidt**: Bitcoin Core #26628 begins rejecting RPC requests that have
the same parameter multiple times.  So in the past, we gave an example in the
newsletter, if you had RPC parameter "foo"="bar", and then another parameter
"foo"="baz", that was treated as "foo"="baz" as opposed to "foo"="bar", which
may not be what the person who's calling that RPC intended.  So now, the request
will fail if you provide that same parameter multiple times.  Murch, do you have
some insight into the background of why this was ever the case?  Is that common
in CLIs to take the most recent parameter as opposed to erroring?

**Mark Erhardt**: Yeah, I guess as long as you specify, it's just an assignment,
right?  You're saying, "For the variable x, I want to provide this value", and
there is not strictly a problem there, it's just rather that it has a smell.  If
somebody specified the same variable multiple times, they likely overlooked that
they had specified it already.  And especially if you insert it at the top of a
long list of things, you might have not seen that below there was another, and
then the old value would still get used accidentally.  So erroring out here is a
service for the user in the sense that it basically says, "Hey, I think you
probably made a mistake here.  You probably did not want to specify this twice".
So, yeah, basically the naïve way is to just be like, "Well, he's just telling
me that variable, and I guess he does it twice, and the last one is the relevant
one".  This is a more explicit, probably should take another look here.

**Mike Schmidt**: Thanks for that background, Murch.

_Eclair #2464_

Next PR here is an Eclair PR #2464, adding the ability to trigger an event when
a remote peer becomes ready to process payments.  And we note here in the
newsletter that that's especially useful in the context of async payments.  And
side note, we added async payments to our topics for this week as well, so feel
free to peruse the Topics Index, and there's some references to async payments
from our previous newsletter, as well as a few paragraphs on async payments.
Maybe, Murch, do you want to give a tl;dr on what async payments are?

**Mark Erhardt**: Yeah, so the context here is that especially mobile clients on
the Lightning Network might be offline for a brief period of time.  And of
course, in the Lightning Network, in order to process a payment, you have to be
online and receive it.  So, some Lightning Service Providers (LSPs), especially
ACINQ, who are the maintainers of Eclair, they were pushing for a way for the
LSP to hold on to a multi-hub payment being built up for the period of time that
a mobile client might be offline and not responding.  So, essentially they're
now holding a Hash Time Locked Contract (HTLC) and trying, over a period of
time, to make the mobile client aware of somebody trying to pay them, and don't
immediately fail when the client isn't online at the first instance that they
hear about the request.

So, whatever, you go through a tunnel and your mobile phone comes back online,
and then ACINQ now hears, "Oh, the mobile client is online again", and it will
be able to try to relay that HTLC and build up the final hop of the payment, and
the mobile client can actually pull in the Lightning payment start the cascading
resolution of the multi-hop payment.

_Eclair #2482_

**Mike Schmidt**: Next PR is also an Eclair PR #2482, which enables sending
payments using blinded routes.  I feel like we've defined blinded routes on our
Twitter Space Recaps for the last four or five weeks.  Murch, in the interest of
time, do you want to talk about blinded routes or not?

**Mark Erhardt**: Well, I was going to give a thumb-up for skipping it!

**Mike Schmidt**: Yeah, okay, we can skip it.  Yeah, I figured we can.  There's
also a good summary in the newsletter for this PR, actually, a good general
summary, so take a look at that.  I think we can skip in the interest of time,
and we still have five more PRs to review.

_LND #2208_

There's LND #2208, begins preferring different payment paths, depending on
maximum capacity of a channel relative to the amount being spent.  So, I guess
instead of just jamming it all in one channel, LND will take into account the
capacity of that channel and potentially route portions of that payment through
different paths accordingly.  Murch, is there a name for this sort of technique
of changing routes based on capacity?

**Mark Erhardt**: I think what this is referring to is LND used to optimize the
routes for the least fees, and that might get you into trouble if you're trying
to route through a channel where you would basically take almost all of the
capacity of the channel, which means that very likely, you're not going to be
able to even get through that route, because when is ever the whole capacity on
one side.  Or, to be fair, I think the default is that you can only route HTLCs
up to a quarter of the capacity in the first place.

But for the sake of the argument, if you're trying to route almost all of what
you can send through a channel, the likelihood is a lot higher that there's not
enough balance available to push through.  So, what this does is, instead of
always just looking at the fees and trying to minimize the fees, it looks at,
has this channel a significantly higher capacity than the amount of money that
I'm trying to send through, then it's probably more likely to have enough
balance on the side that I need it on to make my payment.  And that will maybe
increase the fees very slightly, but it will probably reduce the number of
attempts that LND needs to make in order to find a good payment route, so it
should make payments go through faster and more reliable.

I think that this is closely related to the pickup payments, which is this paper
that came out I think last year, maybe two years ago now, that was looking at
pathfinding as a flow problem and was assigning probabilities of how likely
channels are to be able to forward payments and start routes, more in the regard
to whether payments would go through on the route that it picked, rather than
just looking at the fees.  So, I think it's part of the general trend of
improving Lightning routing for, or pathfinding I should say, for reliability
rather than just optimizing for minimal fees.

**Mike Schmidt**: Thanks, Murch, that was great.

_LDK #1738 and #1908_

There's two PRs that we noted here for LDK that are associated, LDK #1738 and
LDK #1908, which are both PRs related to handling offers, which is BOLT12 from
the Lightning spec.  If you actually drill into #1738, it references an ongoing
BOLT12 work, kind of parent PR, if you will, and it looks like LDK has completed
almost all of that checklist.  It looks like there's some BOLT12 test vectors
and some documentation that they need to do to officially consider their BOLT12
offer encoding parent PR completed.  Murch, do you want to hatch out offers or
shall we move on?

**Mark Erhardt**: Didn't we do that like five times in the past two months?!

**Mike Schmidt**: Perhaps.  Okay, we'll move on then.

_Rust Bitcoin #1467_

Rust Bitcoin #1467 adds methods for calculating the size in weight units of a
transaction's inputs and outputs.  Surprising to me that that didn't already
exist, but there's now a function for calculating both of those.

_Rust Bitcoin #1330_

We can move on to Rust Bitcoin #1330, which seems like Rust Bitcoin's always
messing around with locktimes.  It removes the PackedLockTime type and requires
the use of this absolute::LockTime type, which I guess were nearly identical
with the exception of this Ord characteristic, which I believe is used in some
sort of sorting within Rust.  Murch, I don't know if you got a chance to dig
into #1330 and locktime?

**Mark Erhardt**: I looked at it and I think that what Rust Bitcoin here is
doing is, it had some somewhat opinionated ways of using locktimes earlier, and
it's just going back a little more to the standard behavior of how other
packages and wallets are interacting with locktime.  I think we've had a couple
of other PRs that we looked at where they were also adjusting how locktimes were
being used in Rust Bitcoin.  I think it's mostly that, and perhaps related to
downstream changes in LDK and BDK, where people are just using that and
actually, especially Lightning, using a lot of locktime stuff and finding that
the implementation doesn't work for them that well.  It's just cleaning up and
standardizing, I think.  I have not looked too much into it, so my suspicion
might be off target here, though.

**Mike Schmidt**: That certainly makes sense, given the context, because it does
seem like we've seen a lot of these PRs for Rust Bitcoin in the last month or
two, so you may be right.

_BTCPay Server #4411_

Last PR for this week is BTCPay Server #4411.  It upgrades to Core Lightning
22.11, which we've covered previously.  One of the changes here is also how you
can put the hash of an order description inside a BOLT11 invoice; it just
changes the APIs that you use to be able to do that.  I don't have too much
hands-on BTCPay Server experience, but it seems like you could either put a
description in the description field, or you could put a hash of the
description, supposedly.  I suppose that if it was a very long description, you
could put a hash of the description in the invoice and then communicate the
details of that invoice out of band.  Or perhaps there's a privacy reason to do
that, I'm not sure.

**Mark Erhardt**: I imagine as a merchant, you would probably not want to give
your internal.  It's sort of my field in accounting terms, like order by user,
etc, for dates, whatever.  So I think it's more of a, if I put it in the
invoice, I can look it up in my database again.  And if the user pays the
invoice, they're going to, in the HTLC, remind us what they were paying by us
being able to look it up in the database.  Also, not an active user of BTCPay
Server though.

**Mike Schmidt**: Well, that's it for this week.  Murch, anything to remind our
listeners of, events, announcements, otherwise?  LDK Week on Stack Exchange?

**Mark Erhardt**: You know what we forgot?  We forgot to tell people a few
minutes ago that if they had questions or comments, that they should line up for
speaker access.  So, maybe we should do that here still.  Then, Happy New Year,
and yeah, if you're playing around with LDK, we're starting a Topic Week, I said
that already, but I would really love for people to ask their questions about
LDK.  Even if they had that question months ago, they could still ask it.  We
have a commitment by at least one LDK developer to look every day and answer all
the questions about LDK, maybe also cajole his colleagues into helping with
that.  So, yeah, maybe if you were looking to play around with LDK, it's a good
time to start.

**Mike Schmidt**: Great, I don't see any hands up or requests for speaker
access, so thank you all for joining, and we will do this again a week from
today, and have a good week.  See you.

**Mark Erhardt**: Yeah, cheers.  Thanks, Mike.

{% include references.md %}
