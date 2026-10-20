---
title: 'Bitcoin Optech Newsletter #360 Recap Podcast'
permalink: /en/podcast/2025/07/01/
reference: /en/newsletters/2025/06/27/
name: 2025-07-01-recap
slug: 2025-07-01-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Daniela Brozzoni
and Naiyoma to discuss [Newsletter #360]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-6-1/403141721-44100-2-d842a37a4ade1.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #360 Recap.
Today, we're going to be talking about fingerprinting Bitcoin Core nodes on the
Bitcoin Network; we're going to talk about descriptors and BIP380; we have some
questions from the Stack Exchange about blocking Knots nodes, OP_CAT, compact
blocks and selfish mining.  This week, Murch and I are joined by two guests.
Daniela, do you want to introduce yourself?

**Daniela Brozzoni**: Yeah, hi everyone.  I'm Daniela Brozzoni, I work on
Bitcoin Core full-time.  I have a grant from HRF and OpenSats, and I've been in
the Bitcoin space for a while.  I've worked on many different projects, so you
might have heard of me already.  I'm so happy to be here.  So, yeah, hi
everyone.

_Fingerprinting nodes using `addr` messages_

**Mike Schmidt**: Excellent, thanks for your time.  I know we had Naiyoma on a
minute ago.  I think she dropped.  Maybe when she gets back in, she can
introduce herself, but we'll jump into your related news item here, which is the
first one from the newsletter titled, "Fingerprinting nodes using addr
messages".  Daniela, you posted to Delving Bitcoin about some fingerprinting
research that you and Naiyoma had conducted.  It's been a while since we covered
what fingerprinting of nodes on the network is.  I think Murch has given some
good explanations in the past, but maybe perhaps as a lead-in for the audience,
to give them some context, you can explain that high-level concept of
fingerprinting first, and then we can get into the specific fingerprinting
technique that you used in this research that you published?

**Daniela Brozzoni**: Yes, of course.  So, the main protagonists here are nodes
that are running on multiple networks.  So, for example, if you have a Bitcoin
node and you run it on Clearnet on Tor, that's the kind of network that we're
trying to fingerprint.  And in general, in theory let's say, this node that is
running on Clearnet on Tor for the Bitcoin Network, it appears as two separate
nodes.  The network shouldn't know that it's actually the same one.  They just
see an IP address, an onion address, and they have no clue.  They shouldn't have
a clue that it's actually the same one.  But there's various ways to actually
find out, and one of them is what we're going to actually look into today.  And
so, what we're able to do is we were able to find that some nodes, they seem
different, but in reality, behind those two interfaces, there was just one node.

**Mike Schmidt**: Okay, excellent.  Now how exactly can you figure that out?
Maybe we can get into the technique now.  So, we understand that there's the
ability to use some information to identify that a node is both addresses on the
network, okay, so how can you do something like that?

**Daniela Brozzoni**: Yes, absolutely.  So, our focus was actually to show that
it's possible.  And if you look into it, you won't really find a lot of results
like, "Oh, we fingerprinted thousands of nodes", because we didn't want to lift
everyone's privacy, but we wanted to show that it's possible and relatively
easy.  And this fingerprint attack uses addr messages, which are some messages
that the Bitcoin nodes send in the network.  So, obviously there's a Bitcoin
Network and nodes that connect to that need to know the network addresses of
other nodes so that they can choose better peers if they need to, add some
connections.  And so, the network has a whole way of communicating addresses to
each other.  And one way to do that is through getaddr and addr messages.  So,
getaddr is a message that is used to say, "Hey, peer, please, can you send me
some network addresses?"  And so, for example, when one node initiates a
connection to a peer, they will send them a getaddr message, just so they can
get to know other network addresses in the network.

The response to that getaddr is an addr message, which is what we were mostly
looking into in this research.  And an addr message is composed of usually 1,000
addresses that are paired with a timestamp.  So, if I send you an addr message,
it will contain 1,000 network addresses; for every address, a timestamp.  That
timestamp has various meanings, but it's usually we mean it as a 'last seen'.
So, last time I've heard about that node in the network, last time I've
connected to it, there's various usage, but last seen is a good way to summarize
it, I think.  But when you have the same node that runs on multiple networks and
you start looking into the addr messages, you will notice that they're not
identical, but they're similar because their timestamps are often similar.

So, let's say I'm a node, I'm running on Clearnet and on Tor, and I get asked on
Clearnet and on Tor, I receive a getaddr, so I need to send addresses back.  I
won't send the same exact addr message, but I will, in both cases, reply with
1,000 addresses.  And if one address ends up in both responses, it will have the
same timestamp.  So, what we did is we basically looked at addr responses from
various nodes, and looking at the similarities in address and timestamps, we
were able to say, "Okay, these two nodes, they're probably unrelated.  These two
instead, they're probably the same.  These two, I'm pretty sure they're the
same".

**Mark Erhardt**: So, basically, you look at the response that you get from
another peer when you ask it to give you more addresses of nodes on the network.
And if the timestamps for the last seen for those peers, or the other nodes that
are being parsed, matches across two nodes that are in different networks, very
likely that indicates that it's actually the same node on two networks.  I was
wondering, why do we even want to parse that information?  What does it add?
It's untrusted, right?  They could just parse us whatever they want.  Why not
just parse the addresses in the first place?

**Daniela Brozzoni**: Yes, absolutely.  That's actually something that we have
wondered as well, because one of the solutions we were thinking about is, okay,
can we just remove timestamps?  But before that, let's look into a bit more what
they are, and then, yeah, then maybe we might remove them.  So, every node has
an internal state and it's a structure that it's called addrman; it means
address manager.  And so, the addrman of nodes contains all the addresses and a
timestamp.  Then it's interpreted as a last seen, and it's used by Bitcoin Core
as a sign of how fresh an address is.  So, if the last seen of an address is
five minutes ago, then the address is quite fresh, and so it probably means that
the node is still up and running.  While if I have an address with the timestamp
that is one month ago, then maybe, I already know it's not that fresh.  Maybe
the node is not there anymore.  I don't know really.  So, Bitcoin Core nodes
have this internal state and they use timestamps to make some decisions.

But then there's also timestamps on the P2P network.  So, yeah, when a peer
tells me about all the network addresses they know, they send me some
timestamps, but I don't trust them.  As I said, they're unverified.  If I were a
malicious peer, I could just send anyone addresses with just random numbers,
random timestamps or very old timestamps.  So, Bitcoin Core has some guards in
place, I would say, so that if I receive an address with a timestamp, first of
all I check that the timestamp makes sense, I check that it's not in the future,
that it's not too much in the past.  If it is, I will set it to a random
default.  I think it's about a few days ago.  But yeah, internally timestamps,
although they are used to choose, for example, which addresses evict from the
address manager, they're not used to make life-and-death choices.  They're not
used to decide which peer to connect to, for example.  They're just used to get
an idea of how fresh an address is and they're refreshed in various ways.

So, when I connect to a peer, if the timestamp I have in the addrman is old, I
will just update it.  By old, I think it's older than 20 minutes ago.  Not sure,
I will have to double-check.  So, there's some ways to refresh that.  If I see
an address on the network because the peer is self-announcing their address, I
will refresh their timestamp.  But in general, they're not used to make very
important decisions because they come from an untrusted source, which is our
peers in the P2P network.

**Mark Erhardt**: So, I'm wondering, do we sort by timestamp and select by
timestamp for what we parse to other peers, or do we randomly sample
disregarding the timestamp?

**Daniela Brozzoni**: It's randomly sampled.  There are still some conditions.
I don't remember exactly, but the timestamp can be too old.  So, if it's, I
think it's more than 30 days old, I won't send that to my peers.  Another
important thing that Bitcoin Core has is a cache that is per network.  So,
before Bitcoin Core 0.21, this cache didn't exist.  So, whatever getaddr you
would receive, you would just pick 1,000 addresses from your addrman and reply
with that.  So, an attacker could just spin up a lot of nodes, connect to the
victim, continue asking getaddr with newer nodes, and the victim would just
basically say all the addresses in their addrman.  That was obviously a privacy
leak that by itself, maybe not so bad, but you could mix it with other privacy
leaks and it could be problematic.

So, what Bitcoin Core has right now, it's a cache.  So, every about 24 hours, it
gets refreshed.  And so, 1,000 addresses get decided randomly and they get into
this cache.  And every time the node receives a getaddr request, it will send
that cache as a response.  So, if you connect it to my node, and you would ask a
getaddr ten times today, even from different nodes, etc, you would still receive
exactly the same response, because there's a cache to actually protect, to avoid
leaking too many addresses.  And how addresses get into that cache is we just
pick them randomly and we make sure not to send too old addresses.

**Mike Schmidt**: We have Naiyoma now who's been able to join us.  Naiyoma, do
you want to introduce yourself quickly, and then we can get your thoughts on
this research you put together?

**Naiyoma**: Yeah, sure.  Hi everyone, my name is Naiyoma and I'm also a Bitcoin
Core contributor.  And together with Daniela, we did work on this attack, trying
to recreate it.  Yeah, I think from what I've heard, Daniela has mostly covered
a big bunch of what we are up to.  Yeah, so at the moment, from the surface, we
can say, okay, timestamps don't really play a big role, and yes, we can try and
remove them.  But it's also kind of difficult to determine, okay, does that mean
that then we are not able to tell which addresses are terrible or haven't been
connected to the network for too long?  And what exactly does that mean for the
network?  Because we're also trying to avoid a scenario where a node could be
connected to a lot of peers that are just not in the network anymore.  So, those
are also some of the things that we're thinking about.

**Mark Erhardt**: Yeah, maybe related to that is, so our nodes make eight
regular outbound connections, two-blocks-only connections, and there's the
feeler connection, which exactly goes through the unverified nodes and just
tries to ping, "Does a Bitcoin node respond on this IP", and then to refresh the
timestamps or see whether these addresses are useful.  So, I think we just
sample, randomly give 1,000, and then the peer who receives the getaddr message,
they have to verify that data themselves.  So, from what it sounds like and what
you two have described, I'm very curious whether there's any redeeming qualities
for parsing the timestamps at all.

**Daniela Brozzoni**: One thing that I just remembered that Martin commented is
that timestamps are useful when nodes self-announce.  So, I think once a day,
not sure, but every now and then, nodes just self-announce in the network.  They
say, "This is my address", and they put a timestamp near that address because
they use an addr message.  And in this way, the address of new nodes, it gets
around in the network.  This message is sent.  And for example, let's say I'm
Daniela, I want to self-announce, I derive my network IP and my timestamp, I
send it to all my peers.  Then my peers, some of them will relay this message,
some of them won't.  So, that message will get to my peers' peers.  And in this
way, it will continue just going around in the network.  But of course, we don't
want to flood the network with my address.  So, what nodes do is when they
self-announce, they set the timestamp to the time when they self-announce, so to
right now, and the peers relay the self-announcement only if it's less than ten
minutes older.  So, for ten minutes, my address will just go around in the
network, and after ten minutes, peers will just stop relaying it so that they
don't flood the entire network.

So, in this specific case, timestamps are useful.  So, we can just say, okay,
from now on, the addr message doesn't have the timestamp anymore, because it's
also used in this self-announcement phase.  However, we could maybe think about
substituting them in the addrman.  Instead of having a timestamp, maybe having
some other variables.  Maybe when we're applying to a getaddr, we can think
about having some nice defaults that don't leak that much info about our
networks.

**Mark Erhardt**: Sorry, go ahead.

**Naiyoma**: Yeah.  So, in regards to Martin's comment as well, this was
definitely one of those circumstances where we were thinking, okay, we might use
nLastSuccess, which is a variable, or nLastTry, I think.  So, yeah, that's what
we wanted to test next, like substituting nTime with some of these other
variables and check the performance of our peers in the network.

**Mike Schmidt**: We touched on one of the mitigations that we mentioned in the
newsletter, which was removing the timestamps completely.  And I think we're
sort of getting into maybe other potential mitigations.  One that we mentioned
in the newsletter was to keep the timestamps, but randomize them somewhat so
that this tech isn't as obvious, I guess.  Maybe, Naiyoma, do you want to
comment on that particular mitigation and the other ones you're looking into?

**Naiyoma**: Yeah, so that's the obvious one and that's the first one we thought
about.  So, we are thinking as a node is replying inside the cache response,
then we could randomize within a few days, so not just a few hours because that
wouldn't work, or a few seconds.  So, we choose days range and then randomize.
So, if for dual node at home, let's say it's in IPv4 and Tor, that essentially
means that we are going to randomize for the two different networks.  So, each
cache interface network is going to reply with different peer timestamps that
have been randomized.  So, the chances of us having that overlap of address
timestamps, like being similar, is almost completely eliminated.

**Mark Erhardt**: So, if you randomize them, you're of course losing the
information about how old things are, to some degree.  I mean, it would affect
the newer, very recent addresses more than it would affect the old addresses
because, if it's 25 days or 30 days, that's probably not a huge difference; but
if it's an hour versus three days, that might affect how quickly something is
picked up.  I was wondering now, going back to the self-announcement mechanism,
when you self-announce, you're only sending very few addresses, I think maybe
only your address by itself, and then you want the timestamp to actually be
accurate in order to give a small window in which it is actively relayed to
peers.  But the peers that receive your self-announcement, do they forward the
solitary address as well, or do they pack it into the bigger announcements?

**Daniela Brozzoni**: I have to say, I don't remember.  I should double-check.

**Mark Erhardt**: Sorry, I'm trying to put you on the spot here!

**Naiyoma**: Yeah, I'm also not very sure about that.

**Mark Erhardt**: Okay, sorry, back to randomizing the addresses.  How would
that benefit or be better than just, say, whenever you create a getaddr cache,
you set all the addresses to the date at which you created the cache plus 24
hours, and then until you update your addr cache, that's the timestamp that you
use, so everything is one day old.  And then, after 24 hours, it's almost 48
hours and then you update your cache and everything's 24 hours old again.  Since
we're not relying on it and these big packages don't have that ten-minute window
for self-announcements, do we lose a lot?  Is randomizing really better?

**Daniela Brozzoni**: I'm not sure really.  I think so.  One thing we really
want to do is to gather feedback from other devs.  So, this is actually really
useful.  I think you have a preference and that makes a lot of sense.  I think
randomizing might just be a bit easier, like a smaller change to the code.  But
in both cases, we would really need to study how this would affect the network,
how older nodes might react to this, for example.  So, yeah, I think there's
still a lot of open questions.  The idea of removing timestamps, it's not
something we just came up.  It's something we saw in, I think, an IRC meeting
from 2020, and so Bitcoin developers saying, "Oh, we could just remove
timestamps".  So, yeah, it's definitely something that we need to think about
more and we're looking for input on that.  But they don't seem to provide that
much value.  So, removing them could be definitely an option.

**Mike Schmidt**: It's interesting.  We have a PR later in the newsletter on a
topic we've covered previously, which is also time-related fingerprint leaks and
involving timing on the LN, that we'll get to later.  So, this is not the same,
but time-related fingerprinting for Bitcoin nodes.  So, Murch, anything you'd
like to add?

**Mark Erhardt**: I had one more question actually.  So, let's assume that there
were no fingerprint-y timestamp data on our getaddr messages anymore, and we are
still running a node on Clearnet and Tor.  I assume we have significantly more
than 1,000 nodes.  Wouldn't we still leak that it's the same node just by having
an extraordinary overlap in our random 1,000 nodes that we announce?  Have you
looked into whether, even without timestamp data, nodes would be
fingerprintable; like, having a node that is on both networks versus having two
random nodes on Clearnet and Tor, can you distinguish them without timestamps?

**Naiyoma**: Yeah.  I think if we were to remove the element of okay, now we
don't have timestamps, there are other metadata that we could use that still
exists in other responses.  So, in that way, we can say, okay, we can still come
up with some form of overlap of peers, but we found, okay, so nodes will share a
couple of peers, right?  But remember that the 1,000 is a random set from like
20,000, right?  So, the assumption is you can have your node and I can have my
node and we can share peers.  But even though we can share, like, maybe I'd say
like 40% peers, the chances of these peers also having the same timestamp is
almost always really low.  So, that's why we ended up with, okay, timestamp is a
good way to tell that these peers are coming from the exact same addrman.  But
yeah, there's still a chance that someone can be able to create an overlap using
the other metadata that we get from addrman.

**Mark Erhardt**: Okay, so more research is needed.  This is the lowest hanging
fruit.  It's really easy to tell what nodes are active on both networks with the
timestamp.  Without the timestamp, it might still be possible, but harder.  Do
you have an idea what the next fingerprint would be after timestamps?  "No", is
fine answer here, of course!

**Naiyoma**: There's actually an open issue on GitHub of how you can fingerprint
dual home nodes just using other factors.  So, that's why we're like, it's not
just timestamps, there are other ways that you can achieve this attack, in other
ways.

**Mark Erhardt**: Awesome.  Thank you.

**Daniela Brozzoni**: Yeah, I'm also thinking you can probably fingerprint very
easily a new node if it has a really, really small addrman, because the addr
response will give up to 1,000 addresses, but not more than 23% of the addrman
size.  However, I don't know how weak it is for nodes to fill their addrman.
So, maybe it takes them ten minutes to get to more than 5,000 addresses, I don't
know.  And so, maybe it's a fingerprinting attack, but it might be that you have
a very small window to do that, and so it's not really possible.  Yeah, now I'm
really interested in looking into if we found nodes with less than 1,000
addresses in the addrman to match them up, so thank you!

**Mark Erhardt**: Well, I'm glad to hear that you have some new ideas for
further research.

**Mike Schmidt**: Well, it sounds like there's some open research to be done.
Daniela has solicited also from the audience if this is something that you're
interested in to provide some feedback as well.  Any other parting words for the
audience before we move on?

**Daniela Brozzoni**: I think there's something we haven't discussed, which is
something me and Naiyoma have talked about a lot.  So, I'll let her reply, which
is, "Why bother?"  So, when we change Bitcoin Core, we wanted to have a good
reason for doing that.  So, why is this attack important?  Why should you care?
Why should we even fix it?  Yeah, I'll let Naiyoma reply to this, if that's
okay.

**Naiyoma**: Yeah, sure.  So, I would say first of all, there's a chance that
some people are running dual home nodes, and they don't know that you can think
you're on Tor only, and so you're really private, but there's also a chance that
maybe your node is also on IPv4.  And so, that's also a big issue, at least on
my end.  Daniela, I don't know if you have something to add on to that.

**Daniela Brozzoni**: Yeah, one thing I was thinking about is that if there's
networks that have very few node bridges, so let's say you have a certain
network and 99% of the nodes connected to the network are only connected to that
network, and there's a few nodes that are connected to that network and IPv4 and
Tor, blah, blah, blah.  Then you have very few bridges and you might, with this
attack, be able to identify them and attack them, which might mean try to
partition the network.  It might mean try to just connect to them to see
metadata and see things, data, information, right?  And also, to build on top of
what Naomi just said, I think maybe by itself, I don't consider this to be the
most critical attack.  However, when it's about privacy leaks, you need to
consider that privacy leaks can sum up.  So, maybe just this privacy leak, it's
not that much, but with other privacy leaks, that it might mean that you get a
leak which is way bigger.

**Mark Erhardt**: Yeah.  Let's say, for example, you're running an LN node only
on Tor, but your Bitcoin Core node is identifiable and leaks your IP address.
Now, people know exactly what area of the world you live in and perhaps even
more, can identify even further, like your county or whatever.  Actually, I was
about to ask another question that you already sort of touched on.  Why would
you not just propagate addresses from the network that you're on?  So, on the
Tor network, why don't you just announce other Tor nodes and on the Clearnet,
why don't you -- like, if you only announced nodes on the same network as you're
operating on, that would mean zero overlap.

**Daniela Brozzoni**: Yes, something I don't know.  I guess it might be because
you risk some partitioning attacks, but it's something that I was wondering too,
which is why do we have only one address manager and not separate ones?  I'm
sure there's a reason, but I have some more research to do for sure into the
code.

**Mark Erhardt**: Yeah, I was thinking for a small network like I2P, which has,
I think, only a dozen or several dozen nodes; they need to be announced on other
networks to be found.  But other than that, I was actually wondering whether
that would also be a solution.  Or if the proportion of nodes that you announce
from the same network is significantly higher than the general node population,
that might help.  Anyway, I think we're getting really into the details here.

**Mike Schmidt**: No, that was a great discussion.  Thank you both for your
time, Daniela and Naiyoma.  You're welcome to hang on or you're free to drop if
you have other things you're working on.

**Daniela Brozzoni**: Absolutely.  I will have to drop, but thanks a lot for
having me and we'll chat soon.

**Mike Schmidt**: Cheers.

**Daniela Brozzoni**: Thank you.  Bye.

**Naiyoma**: Thank you as well.  I'll just stay in and listen to the rest of the
podcast.

_Does any software use `H` in descriptors?_

**Mike Schmidt**: Great.  Our second news item this week is titled, "Does any
software use H in descriptors?"  This news item was motivated by Ava Chow, who
posted to the Bitcoin-Dev mailing list, to see if there are any implementations
of descriptors that output descriptors with this capital-H as a hardened
indicator, or permit input of capital-H as a hardened indicator.  Murch, I teed
this one up.  I was hoping you can elaborate more on what exactly is going on
here with this capital-H.

**Mark Erhardt**: Yeah, I think the background was, originally the notation used
a single quotation mark to indicate hardened derivation.  But of course,
descriptors are used as strings on RPCs and in exchange formats.  So, because
single quotation marks are also one of the things that can be used to delimit
strings, that needs to be escaped, and how exactly to escape strings in RPC
commands has been a pain point for some time.  And I think that's where the H
got introduced as an alternative mechanism of denoting the hardened derivation.
Now, I think that maybe the thinking around capital- and lowercase-h was that if
it is encoded as a QR code, all capital letters is slightly more compact.  And
so, being able to do both might have been just an encoding advantage, but
apparently there was some confusion here.  I think it was BIP380, both indicated
that capital-H was allowed, but then had a test vector as an invalid example for
a descriptor with a capital-H.  And then also, Bitcoin Core's implementation
does not accept the capital-H, it only accepts a lowercase-h as a hardened
derivation marker.

_BIPs #1803_

So, actually, I said we should leave it in order, but we do have a change later.
It's really an item that refers to several BIPs repository changes, but one of
them talks exactly about this.  So, apparently a group of researchers found this
discrepancy where BIP380 says that capital-H is allowed, but then in the test
vectors, gave it as an invalid example.  And a change was merged to make that
consistent and move the invalid example to the valid samples instead.  But that
seems to have kicked off this conversation that Ava started, which is, does
anyone actually use this?  Because currently, Bitcoin Core doesn't accept it;
other BIPs were expecting that this is not allowed; and if nobody actually uses
it and no project has implemented it, as in maybe they can read it, but they
wouldn't write it themselves, it would be safe to only use lowercase.  And I
think that's the underlying question here.  Ava wants to know, "Is there any
Bitcoin project that uses capital-H as a hardened derivation marker in their
export format, and if not, maybe can we just settle on only using lowercase?"

So, if you have information on that, if your project implements capital-H as the
export format for hardened derivation, please chime in on the mailing list.

_Is there any way to block Bitcoin Knots nodes as my peers?_

**Mike Schmidt**: Excellent, thanks, Murch.  Moving to our monthly segment on
Stack Exchange questions.  First one, "Is there any way to block Bitcoin Knots
nodes as my peers?"  And I think this person was asking about Bitcoin Knots, but
the answer obviously applies to other node software on the P2P Network.  Vojtěch
responded, he actually provided the RPCs that you could string together to
continuously do something like this, by looking at the user agent and then
essentially blocking that particular node, and then continuing that process in a
looping fashion.  But he goes on to discourage that such approach, and he also
points to a related Bitcoin Core GitHub issue that also has similar
discouragement from a bunch of people.  This was an issue on Bitcoin Core.  It's
#30036, "Possible to ban clients by name?" which was actually from over a year
ago.  Go ahead, Murch.

**Mark Erhardt**: Yeah, so what they're talking about here is the user agent.
User agent is a field in the version handshake, I think, or however.  Well,
anyway, it's something a peer tells you about themselves.  And this user agent
is not very reliable at all.  You're literally just trusting whatever the other
node says it is.  So, I think it is a terrible idea to start shaping your peer
population just based on the user agent.  Well, it might make sense in some
cases where there's spy nodes that exhibit a specific user agent that you don't
want to be connected to.  But given that Knots is now something like 13% of the
listening nodes, it could potentially really disrupt the network connectivity if
all the Knots nodes disconnected Core nodes, and vice versa.  I think that that
would just make the network worse.  And I would push back a little bit on the
motivation or rationale why you would want to disconnect all Knots nodes.

There was another big discussion about a ban list recently on social media,
where someone put together a list of all the nodes that announced that they're
Knots right now, and put together a script to disconnect them all.  I don't
think that that is a useful thing to do and would discourage that.  I understand
that emotions are running high in the whole debate recently, but we really,
really care about our outbound peers, we select our outbound peers, they need to
be fairly decent nodes.  We constantly reassess and then connect to better
outbound peers if we find better ones, and your node is doing that by itself
already.  You don't necessarily need to manually tune that all the time.  And
for the inbounds, we do get a bunch of benefits from the inbounds.  Inbound
connections are essentially equivalent to outbound connections, except in
transaction announcement and a few other P2P behaviors.  I think also during the
sync, we rely more on the outbound peers than the inbound peers.  But you're
basically allowing anyone to be an inbound peer to you.  A lot of those peers
will be light clients and maybe also pruned nodes, or yeah.

So, if you have a bunch of inbound nodes that are Knots, or other
implementations like btcd or libbitcoin or Bcoin, or whatever else is out there,
that doesn't really hurt your node.  It provides a diversity in peers.  So, for
example, if some peer is affected by a consensus failure and not progressing on
the blockchain, which could happen to any implementation, then you still have a
good connectivity by being connected to a diverse set of nodes.  So, yes, you
could just getpeerinfo, grep for the user agent string, and if the string,
"Knots", appears in there, call disconnectnode with that IP.  But I mean, I
don't think it's a good idea or worth your time.

**Mike Schmidt**: Are the protections that are already in Bitcoin Core for
misbehaving peers or if a peer is providing good or bad information to you, is
that enough to handle what I think is the concern from these people, which is
that a Knots node is not going to give me high fee-paying transactions
potentially because they're spam?  I can see how that could be a concern because
you're potentially missing some of the unconfirmed transactions, but does the
current scoring of peers handle things like that?

**Mark Erhardt**: Well, regarding high fee transactions, not specifically yet.
There's been another conversation, which we reported on in last week's Recap,
about specifically filtering for the peers that give you the highest value
transactions, which is more of an early conversation right now.  But generally,
we do of course kick off nodes that give us invalid data.  We also protect nodes
that are very useful to us.  So, the nodes that gave us a block the quickest
recently or that announced new transactions to us tend to be protected from
being evicted when we disconnect something.  Nodes that are less useful are more
likely to be disconnected.  We also protect our nodes across different regions
of the internet, so that we are not connected to all nodes in one data center,
for example.  But yeah, it's pretty robust against all this.

I think a second thing that I heard people be concerned about, "Well, if Knots
nodes download transactions with data in them and then discard them, and then
download the block from me later with these transactions again, then I'm wasting
bandwidth, because I'm sending them more data than they need".  I think that was
one concern.  And then the other that, "They're not going to give me all
transactions that I might be interested in".  But again, if you're a listening
node, your node makes up to 125 connections, and only one of those connections
needs to give you a transaction for you to receive it.  And, well, if you're a
listening node, very clearly you do have some excess bandwidth that you're
willing to share with the network.  Otherwise, you would be running a
non-listening node or a blocks-only node to save bandwidth, or limiting your
-maxuploadtarget or using other strategies.

So, if you're sharing your node to, I don't know, LN nodes and other light
clients to download from you, why not other full nodes, even if they have a
strange mempool policy from your node's perspective?

_What does OP_CAT do with integers?_

**Mike Schmidt**: Next question from the Stack Exchange, "What does OP_CAT do
with integers?"  The person asking this question was reviewing the OP_CAT BIP,
and noted that it stated something along the lines of, "Given the stack
elements, and there's two stack elements, OP_CAT will push those two stack
elements onto the stack".  And the person asking this question said that that
makes sense if those are both byte vectors, but what happens if one or both of
the top elements are integers?  And Pieter Wuille responded that Bitcoin Script
only has one type of stack element, which is byte vectors.  And then, it's on
the operators or the opcodes to interpret those set of bytes in the way that
that particular opcode is meant to be used.  And he also outlines a few unusual
examples of the encoding of integers.  Just might be interesting for people to
dig in and look at that if they're curious.

_Async Block Relaying With Compact Block Relay (BIP152)_

"Async Block Relaying With Compact Block Relay).  And this is from user BCA, and
then some hex, who both asked the question and answered the question.  And this
person provided a figure from the BIP to show how compact block relay works and
then jumps into some of the processes, threads that are spawned and what they're
doing.  And I think what was interesting here was they did some analysis on what
would happen if there were missing transactions, how does that impact block
propagations?  They have a table in their answer here on Stack Exchange showing
if there's 0% missing transactions, what's the orphan rate?  If there's 100%
missing transactions, what's the corresponding propagation time and orphan rate
as well?  I don't know if that table is correct, but I thought it was an
interesting answer.  Did you take a look at that one, Murch?

**Mark Erhardt**: Only very briefly, but I know that there's a bunch of other
work in this context currently.  I know that one Bitcoin Core contributor is
currently looking into finally implementing, so when you announce a compact
block, you're basically just giving the recipe for people to rebuild the block,
right?  You're just saying, "Here's the short ids for all the transactions in
the block in this order".  And then another peer, if they have all of these
transactions in their mempool, they can just recombine the block from their
mempool and validate it immediately, without you actually sending the
transaction data again.  But if there's even just one transaction missing, they
have to make a round trip and ask back from the peer that announced, "Hey, give
me that missing transaction".

So, even when compact blocks was proposed as a BIP, one of the future works that
was proposed was, "Well, what if we just send along the transactions that we
expect for our peer to be missing?"  I remind you that all the nodes remember
what announcements have gone over the wire on every peer connection.  So, for,
every peer, you remember whether either the other side or you have announced a
transaction already.  So, you know exactly which transactions the peer is
probably missing, or even more likely you can just give them the transactions
that you were missing and expect that they will be missing them too; because if
they had announced them to you, you wouldn't have been missing them in the first
place.  So, there is some work on making compact block announcements slightly
better by including missing transactions, which of course especially works for
small transactions.  If you have very large transactions, these packages will
quickly get too big for the standard package size that is allowed in TCP
messages, and then you would get additional round trips anyway.

So, I don't know if this person that was asking and answering this question is
also engaged in the same research right now, but it is reminiscent of a broader
conversation that is going on right now.  So, anyway, the interesting thing is
that if you are missing even only just one transaction, your propagation time
almost doubles; whereas if you miss 10% of your transactions, it's hardly any
longer than missing just one transaction.  I think that that's something that
jumped out from the answer.

**Mike Schmidt**: It sounds like what you outlined there as a work in progress,
sending the transactions along, how does that work if everyone's doing that to
you?  Are you now getting potentially, if you have a few missing transactions,
you'll I guess get more bandwidth, because all your peers, if they happen to see
the compact block before you, they're all going to send those extra five
transactions together to you; is that how that would work?

**Mark Erhardt**: Well, it would if all of our peers were designated compact
block relayers.  So, what we actually do is when a peer gives us blocks quickly,
we designate them and tell them, "Hey, I would like you to be a compact block
relay node for me.  Could you please, in the future, send me them in the
high-bandwidth mode?"  But we only do this, I think, to two or three peers.  So,
yes, if you got a compact block announcement from several peers at the same
time, they might send you those couple of transactions extra more than once, but
generally we already limit the number of peers that we ask to do that for us.
And yeah, so specifically, compact block announcements are, I think, usually
around 2 kB or so with all the short ids.  And TCP packages, I don't know a ton
about this, but some people around me have been talking about this recently.

Apparently TCP packages are highly variable, depending on how you route your
connection between two nodes.  But they tend to be between less than compact
block relays and slightly more than compact block announcements.  And so,
there's only a little bit of room anyway if you want to get it in a single round
trip, how much you can package.  So, if there is a small transaction missing or
something, you might be able to push it through in the same TCP package.  If a
big transaction is missing, you'll get round trips anyway.

**Mike Schmidt**: Okay, Murch, sorry, I have two more questions on this topic.
One, and I think I know the answer, but with differing-sized mempools, it may be
that you think your peer has it and they no longer have it.  I guess you
wouldn't send it then and then they would just request it, you'd fall back to
the normal mechanism; is that right?

**Mark Erhardt**: Well, okay, let's dive very briefly into that scenario.  You
have a peer that has a way smaller mempool than you.  And what they would kick
out of their mempool though is still at the bottom of their mempool.  So,
hopefully, if the miners are building the expected blocks that are feerate
optimized or fee optimized, they would be picking transactions from the top of
the block, and those transactions would most likely not be among the ones that
are being evicted, even if you have a smaller mempool.  It might be, of course,
that over some time, transactions got added, you built up a little bit of a
backlog, and then there's a series of fast blocks, and your peer's mempool is
emptied out or reaches the point where it previously had been evicting, then you
might run into the scenario.  But generally, that's one of the reasons why it's
good for nodes to have similar homogenous mempools, is that they have similar
stuff and then blocks propagate very quickly.

**Mike Schmidt**: Okay, my last follow-up for now on this.  With Knots not
holding in their mempool some of these spam transactions, but you know you sent
that to them, it sounds like they would not benefit as much if there were spam
in the blocks as a non-filtering peer would then, right?  Because you would have
thought, "I'm not going to send this transaction along because I already sent it
to them a little while ago", but little did you know that they were actually
discarding that.  So, they wouldn't benefit as much from this type of this
optimization that it sounds like people are working on.

**Mark Erhardt**: I mean, I think compact blocks just probably doesn't work for
them generally.  Like, they just will always have a round trip if they kick out
spam.  So, they always have round trips to get the missing transactions, and
then need to wait for the block to fully validate before forwarding it.  So,
basically, my suspicion would be that among Knots nodes, blocks propagate about
a factor 2 slower.

**Mike Schmidt**: I won't bother you anymore about compact block relay for a
while.  Thank you.

**Mark Erhardt**: Well, I mean maybe we should have someone on that actually
knows what they're talking about!

**Mike Schmidt**: You shared some insights into work that is being done that we
haven't covered yet, so I'm curious about it.

_Why is attacker revenue in selfish mining disproportional to its hash-power?_

All right, last question from the Stack Exchange, "Why is attacker revenue in
selfish mining disproportional to its hash-power?"  Had a few questions and
discussions about selfish mining recently.  Antoine Poinsot followed up to that
question that I just framed, as well as another older selfish mining question.
And one quote that we put in here for the newsletter, that was somewhat common
between both of those, is Antoine says, "The difficulty adjustment does not take
stale blocks into account, which means that decreasing competing miners'
effective hashrate increases a miner's profits (on a long enough timescale) as
much as increasing his own profit".  We've linked to both of those questions.  I
think there was one last month on selfish mining as well.  We also had on
Antoine, and I believe that was #358.  Yeah, we had him on in #358.  We had a
news item where he came on and talked about selfish mining as well.  So, a lot
of selfish mining discussion.  Murch, anything you'd add there?

**Mark Erhardt**: I think we might want to jump in on why this is the case in
the first place.  So, let's say a 30% miner starts selfish mining.  They will
simply not announce blocks right when they find them.  And let's assume they
lose every race.  So, if someone else finds a block, they just simply withheld
their block and it's lost.  So, basically, this hashrate has disappeared from
the network and if they find a second block, they announce it.  So, this is the
case, of course, in about 9% of the blocks.  So, you basically reduce the 30%
hashrate that was contributing to the network to 9% making actual progress.  So,
in the case that the 9% succeed, which is when they find two blocks in a row,
that's 30% and then 30% again, so they find two blocks before anyone else finds
a block, in that case, they waste all of the hashrate of the rest of the
network.  Because if there's a single block found, they just publish their two
blocks and everybody else was wasting their bandwidth.

So, generally, just the interval in which the blockchain makes progress goes up
and it's actually worse than a zero-sum game, because there's now less block
space to go around for everyone, presumably the feerates are going to go up
because people are competing with their bids on buying less block space, and
then eventually there's a difficulty adjustment.  So, the difficulty adjustment
will be based on how much progress the blockchain has made, well, how long it
took to find the last 2,016 blocks, right?  And so, since the intervals were
bigger in which the blocks actually increased heights, the difficulty will drop.
And now, the miner is reducing the progress other miners are making by orphaning
some of their progress occasionally, and it is taking its own hashrate out of
the total progress.  So, overall, when it resets to the new difficulty, they
have a higher than proportional share of the block rewards, while everybody else
has a lower proportional share, because now it goes back to a zero-sum game that
the whole reward is distributed to the active miners, but the selfish miner is
getting more than 30% of the block rewards.  And the transaction fees are higher
and everybody else is getting slightly less than their relative proportion of
the block rewards and fees.  So, yeah, any miner above 30% should be eyed with
suspicion.

**Mike Schmidt**: We would see such a behavior on the network, right?  You would
see these pairs of blocks coming out, I guess, disproportionately to what it
would be if they weren't selfish mining, right?  So, it would be identifiable.

**Mark Erhardt**: Yeah, it would be very obvious that it's happening.

**Mike Schmidt**: So, you could say bad things about them on the internet if you
wanted to, but I don't remember if we had a takeaway with Antoine about what
could be done other than shaming them.

**Mark Erhardt**: Not much, I think.

_Bitcoin Core 28.2_

**Mike Schmidt**: Okay.  Please don't do that.  Releases and release candidates.
We have Bitcoin Core v28.2, which is a maintenance release.  It contains seven
changes to the build system, two updates to tests, two documentation updates,
and two small refactors.  I didn't see anything that was notable.  Murch, you
might be more familiar and have something.  Sounds like no.  So, take a look at
those bug fixes, see if that's something that you want to incorporate into your
release cycle, at least as part of your rotation if you're using multiple nodes.
Yeah, go ahead.

**Mark Erhardt**: Maybe just to be clear, if you are on 28.1, you would likely
want to upgrade to 28.2 because there's no changes to the RPCs or to the
behaviors or anything unless there was a bug fix.  So, if you're worried about
breaking your integration by upgrading a major version, that generally does not
apply to that degree to minor versions which are just bug fixes.  So, you
usually would want to be on the latest minor version of the release branch that
you're following.  But, well, unless there's something big in there that hasn't
been announced yet, or anything like that, you shouldn't be too worried about
not immediately upgrading either.

_Bitcoin Core #31981_

**Mike Schmidt**: And in most of these by volume are build system changes as
well.  Notable code and documentation changes.  Bitcoin core #31981 adds a
checkBlock method to the inter-process communication, or IPC, mining interface.
IPC, as a reminder, is a way to communicate with Bitcoin Core binaries in a
lower latency/faster way than using the equivalent RPC methods.  And IPC is a
newer way to communicate with Bitcoin Core.  We actually covered the IPC bind
option being added to Bitcoin Core in Newsletter #320, and the IPC wrapper for
the mining interface in Newsletter #323.  This particular PR adds this new
checkBlock method to the mining IPC interface that we covered previously.  And
so, some client application, for example, mining software like Stratum v2 can
now use this checkBlock IPC function to check block validity; whereas
previously, the Stratum v2 or other client software could achieve something
similar with RPC calls, but because RPC is less efficient, you would actually
have to serialize the data into JSON.  It was slower, which obviously for
something like mining, or that requires other performance considerations, is not
ideal.  So, there's now an IPC version to do something similar that you could
cobble together with RPC.

_Eclair #3109_

Eclair #3109.  This prepares Eclair for using attributable failures for
trampoline payments specifically.  Attributable failures are a way to sort of
diagnose a pair of nodes as the cause of a forwarding failure or a delay in
forwarding.  And so, this PR for Eclair allows Eclair, when it's serving as a
trampoline node, to now process this failure attribution data by unwrapping the
attribution data using its shared secrets, and then using the remaining
information as attribution data for the next trampoline node.  But this PR does
not yet relay that attribution data.

_LND #9950_

LND #9950 adds an include_auth_proof flag to various RPC and CLI commands.  And
when that particular flag is set, when calling those RPCs, those RPCs will
include additional fields in the result, specifically the signatures from
channel announcements will be included in various RPCs that have that flag.

_LDK #3868_

LDK #3868 brings LDK in line with the open BOLTs PR for the attribution data
spec.  And the idea here is that timing of payments can be analyzed by
adversaries to negatively impact privacy.  And did we cover this previously?
No, that was the other one.  So, if an LN node just trivially reports everyone's
latency, it makes some sorts of attacks easier to do.  So, they've put these
latency into buckets based on 100 milliseconds.  And this is what was updated in
the LN spec around attributable failures, and now LDK is implementing that
change, it's in the BOLTs spec.  We actually had a very in-depth conversation
with a variety of the folks intimately familiar with this discussion.  We had
the, "Do attributable failures reduce LN privacy?" discussion back in Podcast
#356.  We had Carla Kirk-Cohen on, we had Joost, we had Elias Rohrer, all
talking about whether these delays impact privacy and how the bucketing could
potentially happen.  And now you see some of that going into the BOLT spec, now
you see some of that going into LDK here.

_LDK #3873_

LDK #3873 raises the delay for marking a channel as closed after the funding
output is spent.  Used to be you could do that after 12 blocks.  LDK here has
changed that to 144 blocks to wait, and this allows time for a splice to
propagate the network.  We covered a similar PR last week to Eclair.  And the
difference in the Eclair PR and this LDK PR is that Eclair used 72 blocks and
LDK is using 144 blocks, which is double that.  And actually, in the LN BOLTs
draft around routing gossip that covers this particular value, the current draft
PR says, "Should forget a channel after 72-block delay".  I didn't immediately
see a rationale for why there was this larger 144 value in LDK, so I won't
speculate other than to just note it's double what Eclair's doing, and what the
BOLTs draft has currently.

_Libsecp256k1 #1678_

Secp256k1, this is PR #1678, and it adds an interface library so that secp can
be more easily incorporated into other projects.  And I wanted to quote
something from the PR here.  Person opening this PR says, "Parent projects,
Bitcoin Core in this case, may wish to include secp256k1 in another static
library, for example libbitcoinkernel, so that users are not forced to bring
their own static libsecp256k1.  Unfortunately, CMake, which is the build system,
lacks the machinery to link or combine one static library into another.  To work
around this, secp256k1_objs, like objects, is exposed as an interface library,
which parent projects can link into static libraries".  Murch, if I'm
understanding that correctly, the kernel project is using secp, they don't want
to have a separate binary that they're pointing to, they actually want to have
the source code distributed as part of the kernel.  And in order to do that in
build system land and CMake land, you needed to sort of add this wrapper around
it.  I'll use the word 'wrapper'; they called it an interface library, so that
you can essentially embed secp into the kernel.  Do I have that right?

**Mark Erhardt**: That's what it sounds like.  It might also be relevant for the
project that wraps libbitcoinkernel.  So, if libbitcoinkernel has compiled
libsecp256k1, it would probably also be interesting to be available to the
wrapper, like whatever, maybe somebody finally goes and builds a replacement for
Electrum with libbitcoinkernel and they want to, I don't know, scan for silent
payments using libsecp, then it would be silly to have the same library wrapped,
or included twice rather than just once.  That's what it sounds like, but I'm
speculating.

_BIPs #1803_

**Mike Schmidt**: Last PR this week is to the BIPs repository, #1803.  We talked
about this a little bit earlier.  I don't know if you want to elaborate, Murch,
on clarifying BIP380's descriptor grammar?

**Mark Erhardt**: Yeah, again, the PR that I mentioned earlier, some research
group found that BIP380 had an inconsistency where it explicitly allowed
uppercase-H as a marker for hardened derivation, but then in the test vectors
for invalid examples, it had an example where the uppercase-H was not permitted.
So, this PR moves this test vector to the valid examples.  There are also three
other PRs here that deal with slight amendments to descriptors.  And I think
there was a clarification on what is exactly permitted with the derivation based
on MuSig2 keys.  And, yeah, so if you're implementing key derivation, there's
been a little bit of movement in the BIPs 380 through 390.  You might want to
take a look, but it's edge cases, so generally, hopefully that doesn't impact
your project.

**Mike Schmidt**: That wraps up the newsletter for this week.  We want to thank
Naiyoma and Daniela for joining us, and, Murch, thank you for co-hosting.  And
thank you all for listening.  We'll hear you next week.

**Mark Erhardt**: Hear you next week.

{% include references.md %}
