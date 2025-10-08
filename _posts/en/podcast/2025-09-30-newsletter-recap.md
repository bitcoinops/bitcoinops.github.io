---
title: 'Bitcoin Optech Newsletter #373 Recap Podcast'
permalink: /en/podcast/2025/09/30/
reference: /en/newsletters/2025/09/26/
name: 2025-09-30-recap
slug: 2025-09-30-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Matt Morehouse, Daniela
Brozzoni, and Gustavo Flores Echaiz to discuss [Newsletter #373]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-9-1/408486171-44100-2-4df39d090aa21.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome to Bitcoin Optech Newsletter #373 Recap.  This week,
we're going to talk about an Eclair vulnerability, research into Bitcoin Network
node feerate settings; we have a dozen Stack Exchange, most of them being about
OP_RETURN, and our usual Releases and Notable Code Segments.  Murch and I are
joined this week by Matt Morehouse.  Hey, Matt, say hi.

**Matt Morehouse**: Hey, folks.

**Mike Schmidt**: Daniela.

**Daniela Brozzoni**: Hey, everyone.

**Mike Schmidt**: And Gustavo.

**Gustavo Flores Echaiz**: Hey, everyone, thank you for having me.

_Research into feerate settings_

**Mike Schmidt**: We're going to jump right into the news section.  We'll go a
little bit out of order, based on some scheduling.  We're going to jump to the,
"Research into feerate settings", news item.  Daniela, you posted to Delving
Bitcoin about crawling the Bitcoin Network and querying reachable nodes.  What
were you looking for in your crawl and why?

**Daniela Brozzoni**: Yeah, I was trying to understand what nodes have as a
minrelaytxfee setting.  So, to explain a little bit, that minrelaytxfee is a
configuration option that you can put in your Bitcoin node, and it means that
you won't accept in your mempool and you won't relay any transaction that pays
less than the feerate you specify.  Those transactions will still be valid if
they come into blocks, but if you see one being relayed and that could enter
your mempool, you won't let it enter if it's less than your minimum feerate.
And there's been a lot of discussion lately about lowering this minrelaytxfee.
So, for some time now, it has been 1 sat/vB (satoshi per vbyte), meaning if you
want to create a transaction and you want it to be relayed in the network, you
have to pay at least 1 satoshi for each vbyte of that transaction size.  But
starting from Bitcoin Core 29.1 and Bitcoin Core 30, this minimum is going to be
lower to 0.1 sats/vB.

The reason for that is that recently, we saw a lot of transactions that made it
into blocks through the P2P network that were paying less than 1 sat/vB, which
signals that some nodes have been accepting those in their mempool and relaying
that, and a big enough percentage of the network did that, and so those
transactions were able to reach miners.  So, at this point, it's better for the
rest of the nodes to adjust their configuration settings so that they can
actually see what is getting into blocks, because it's very helpful for a node
to have a mempool that is reflective of what gets into blocks.  So, I was very
curious about what percentage of nodes were accepting these low feerate
transactions.  And so, I crawled the network.  I had a script that connected to
each node that accepted inbound connections and collected what is called a
feefilter message.  That is a P2P message that nodes send to their peers,
basically saying, "Hey, this is the minimum feerate I accept for transactions".

So, I collected those and I did two runs, one on the 10th September and one on
the 15th.  In the first days of September, Bitcoin Core 29.1 was released, which
has this lower feerate.  So, I was able to see actually the number of nodes that
accepted these low feerate transactions.  I saw the percentage of nodes getting
higher over time.  So, on my first run, it was about 2% of nodes; and on the
second one, it was 4%, which to me, I think it's a good empirical proof of the
fact that transaction filters work when a very high percentage of the network
has them and enforces them.  And when even a little bit, like a small percentage
of the network starts relaxing these filters, transactions can get relayed and
get through the network.

**Mark Erhardt**: I have a question, a few different things.  One is, folks may
say, "Oh, cool, there's this feefilter message, and I can query my peers about
essentially their policy", but that is somewhat of a unique message, right?  You
can't say, "Hey, tell me what arbitrary data you're filtering or not", and
there's not an equivalent message for every sort of policy or standardness rule
on the network, right, it just happens to be one for this feerate, right?

**Daniela Brozzoni**: Yes, exactly.  And also, you don't have a way to ask it to
your peers.  You just have to connect and wait for them to send it to you.  So,
what happened to me is that a good percentage of the nodes just didn't send that
message, and maybe we can talk a bit more about that later.  But yeah, you just
have that and you connect and you wait a little bit for nodes to send it to you.

**Mike Schmidt**: Now, you said you did two separate crawls, right?  And what
was the subset feerate percentage for each crawl?

**Daniela Brozzoni**: So, for the first one, it was 2% of the network; and for
the second one, it was 4% of the network.  I also had some data on the versions
that those nodes were running, but I didn't publish it because I was scared I
would hurt the privacy of nodes.  Because, you know, it's one thing if you say,
"Oh, 2,000 nodes do this", but at a certain point, it's just very few nodes.
Yeah, and as far as I remember, the majority of the nodes that had a lower
feerate were running Core 29.1, so the new version that has this lower feerate
as the default.  Okay, yeah, I was going to ask about the different user agents
and inversions that you saw, so that makes sense.  Yeah, I was a little bit
curious about uptake of software in your feerate filter can kind of be a proxy
for that, and also just maybe also pointing out to listeners how slow it is to
change things like policy, even in the default implementation, right?  The
latest version of Bitcoin Core changed that and you saw a jump from 2% to 4%
over a few weeks, and I don't know, have you run it since?  Do you have any
other data?

**Daniela Brozzoni**: No.  I just ran it those two times, and I did one test run
a few days before.  And in that test run, the number of nodes that accepted was
so low.  So, I was actually scared that I was doing something wrong.  So, it
took me a while to just make sure everything was working.  But I have complete
data on, so it's one on the 10th September and one on the 15th, so it's five
days apart.  Yeah.

**Mike Schmidt**: Okay, yeah, that makes sense.  I think, and we'll get to some
of the OP_RETURN discussion and that leaks into spam discussion as well later,
but I think some folks have advocated an aggressive sort of cat-and-mouse game,
right, which would accelerate the release cycle of node software, obviously, to
quickly adapt to that, which is also its whole ball of wax.  We're seeing
Bitcoin Core v30 go through the release process now and you see there's one
second RC, there's maybe going to be a third RC, and so there's friction there
in terms of playing the cat-and-mouse game.  But then, even once the software is
released, you see now, at least anecdotally as a proxy metric, what you've done,
sort of showing how slow that can be.  Anyways, that was a little bit of a
tangent.  And Murch, I know you had questions.

**Mark Erhardt**: Yeah, I wanted to point out first that 29.1, according to
Clark Moody's dashboard, has now 12.5% of listening nodes.  So, yes, it usually
takes a little bit for the adoption to start.  And then, I think there is in the
first month or so a chunk of people that switch over, but then it takes forever
for other people to follow.  About 40% or so of listening notes run outdated
versions that are more than 1.5 years old.  So, there is a decent amount of
adoption of the new version when it comes out, it's just not on the first day
necessarily.  I wanted to jump in on the no feerate filter sent message, because
I think that's interesting.  So, if you configure your node with a min feerate
of zero, would you also not send a feerate filter?  Because I am quite sure I
did a similar test, much more janky than your approach here, just looking at my
node's peers and a bunch of them did relay transactions.  I checked that they
had sent and received data.  And I think that some of them had a feerate set of
zero, and you did not have that row in your table.  So, I'm wondering is a no
feefilter sent maybe sometimes, "I have no minimum feerate"?

**Daniela Brozzoni**: Yeah, so basically, if you set your minrelaytxfee to zero,
you wouldn't send a feefilter message.  I checked the code, and basically we
have this variable where we hold the last value of feefilter that we ever sent,
because if we ever change the feefilter, then we need to resend the message to
everyone.  And we initialize that to zero.  So, if we say, "Oh, no minrelaytxfee
in the code", it's as if we already sent that message and it gets never sent.  I
tried quickly yesterday with the functional framework.  Yeah, and I think that
was so interesting, because on IPv4, it's about 20% of nodes that didn't send a
feefilter.  And I mean, the only explanation that I can think of is the spy
nodes, because I don't know why a normal user would say, "No, I will accept any
transaction, doesn't matter the feerate".  Maybe block explorers, there might be
some entities that want to do that, but 20% is a very high percentage.

So, the reasoning might be, they set it to zero so that they see every possible
transaction, and they decide to spy on clearnet because they can gather way more
information compared to privacy networks, such as Tor and ITP.  Because usually,
if you are, let's say, a surveillance company, what you want to know, you want
to link a transaction to an IP address.  Because then it's relatively easy to
link an IP address to a real person.  In a lot of jurisdictions, your ISP needs
to have your data.  So, yeah, you run it on clearnet for that, because then you
can try to link the actual IP address to the transaction.  And also, because
it's quite timely, as in you don't have all the delays that you might have on
privacy networks that might make it a bit harder to understand where a
transaction comes from.

**Mark Erhardt**: Yeah, there are certainly some spy nodes, but also I think
that some of the light client implementations might just not send a feerate
filter.  I didn't check that, but when I was looking at my node, I had 125
peers, and I believe only 60 of them I identified as Bitcoin Core peers.  And
so, the other 60, 65, a lot of them were BTCWire, which I think is btcd, and
there were some other bitcoinj-based clients.  I would imagine that some of them
might not send a feerate filter.  So, it could be a mix of the three things: spy
nodes; light clients that do not support this network message; and Bitcoin Core
nodes that are set to zero.  I think that actually, yes, there's some monitoring
services like block explorers and mempool visualizers, but there's also, I
think, a few users, because it's been a configuration option forever, that just
set it to zero, because they run a big mempool and they want all transactions
for, I don't know what reason.  But I imagine that setting it to zero would be
more likely than some arbitrary higher number.

**Daniela Brozzoni**: Yeah, that makes a lot of sense.  I didn't think about
light clients, so thank you.  One thing that might be happening on your node but
doesn't happen with my script is that block-relay-only connections don't send a
feefilter.  So, block-relay-only, my script doesn't have them because I'm simply
connecting to everyone.  But the connection that your node makes that are only
used to exchange blocks, those are very useful in the case of someone trying to
partition the network.  So, yeah, when you have block-relay-only peers, then you
wouldn't see a feefilter because you wouldn't exchange one, you're not
exchanging transactions.  So, yeah.

**Mark Erhardt**: Right, I forgot to mention those.  So, we have four
explanations now?

**Daniela Brozzoni**: Yeah.

**Mike Schmidt**: Daniela, talk about this feefilter value that you saw that was
9,170,997.

**Daniela Brozzoni**: Yeah, so that filter value, I spent hours debugging it,
because I was so sure I had a problem in my script somewhere because it made no
sense.  And then I decided to simply post on Delving and find if someone had an
explanation.  And the developer 0xB10C had one.  So, when a node is in initial
block download (IBD), they're trying to catch up and download all the blocks
from the network.  So, what they do is they set the feefilter to a really high
number to basically say to their peers, "Hey, I don't want any transactions.
I'm stuck trying to sync blocks.  I don't care about transactions right now".
And on top of that, what Bitcoin Core does is there's structure to round
feerates.  So, if I set my feerate to a very unlikely, quirky number, the
Bitcoin Core will still round it a little bit to get into buckets, basically, to
prevent some fingerprinting attacks.

So, basically, Bitcoin Core would set the feefilter to a very high number, which
is 10,000 sats/vB, and then the structure that would round the feerate would
round it to that weird number you said, which is about 9,000 sats/vB.  So, yeah,
that's why I saw so many nodes that had that specific number that seemed really,
really specific.  And then, when those nodes get out of IBD, they will send a
new feefilter to their peers saying, "Okay, now I'm caught up, I'm waiting for
new blocks, but I'm also okay with relaying transactions".  And so, they will
lower that feefilter.

**Mike Schmidt**: So, there's not a mechanism to say, "Hey, don't send me
transactions right now", so Bitcoin Core is using the feefilter as a way to
essentially achieve that, which is set the feefilter so high that basically no
transactions are going to come through, because they're busy processing blocks
and don't want to worry about processing transactions right now?

**Daniela Brozzoni**: Exactly.  And from my understanding, the feefilter message
is more of a gentlemen's agreement.  Because if I send a feefilter and I say,
"Don't send me transactions lower than this feerate", and then you don't do it
and you send it anyways, even low feerate transactions, that's not a protocol
violation.  I don't know exactly why.  Maybe it's because in this way, you could
be compatible with all their clients that wouldn't know the message.  I'm not
sure though.  So, yeah, it's more of a, "Please don't do that, but if you do,
I'm not going to punish you as a peer".

**Mark Erhardt**: Yeah, I would imagine that if the counterparty doesn't
understand the feerate filter, they would just behave however they behave and
send you stuff.  Maybe one last addition to the topic.  You mentioned that at
some points, the feefilter message might be sent to increase it.  This happens
of course when the mempool runs full, and we start evicting.  So, when we evict
from the mempool, we increase the feefilter to one incremental relay tx fee more
than what we just evicted.  So, we wouldn't just add back exactly what we kicked
out the moment before.  So, that's basically all that's to be said about that
feerate filter message.

**Daniela Brozzoni**: Oh, I didn't know about that.  Nice.

**Mike Schmidt**: Daniela, anything else that you would call out for the
audience or next steps, or anything like that, or just check out your research
on Delving?  I think, yeah, we pretty much covered everything.  I have to say,
this particular area of the code is one that I haven't explored that much.  So,
there might be a lot of mistakes, or things that I'm learning along the way.
So, definitely, if you have any comment, which might be, "Hey, Daniela, you got
this and that wrong", let me know because I'd love to learn more.

**Mike Schmidt**: Daniela, thanks for taking the time to join us.  Have a good
rest of your day.

**Daniela Brozzoni**: Awesome.  Thank you and chat soon and see you soon.  Bye
bye.

_Eclair vulnerability_

**Mike Schmidt**: The next news item titled, "Eclair vulnerability" and all the
LN implementations shake in their boots as we bring on Matt Morehouse.  Matt,
you posted to Delving Bitcoin a copy of the disclosure that you made on your
blog of a critical vulnerability in older versions of Eclair.  I think it was
0.11 and below.  What did you find and how you find it?

**Matt Morehouse**: Yeah, it's 0.11.0 and below, and basically Eclair would fail
to extract a preimage from an onchain transaction and as a result, they wouldn't
be able to claim the corresponding HTLC (Hash Time Locked Contract) from the
upstream node, and they would end up losing the full value of that HTLC.  So,
this is a risk to losing your funds, and so you definitely want to be upgrading
to the 0.12.0 or newer.  There's also 0.13.0 that came out recently.  And so,
basically the way this vulnerability works is, in LN, payments are routed across
the network with a chain of HTLCs.  And so, this chain will propagate starting
from the sender of the payment, and it will get passed to the next node in the
chain who will set up an HTLC with the next node, and so on, until it gets to
the receiver.  And then, once the receiver has their HTLC set up, then they
reveal the preimage to that HTLC, which unlocks the funds and allows them to be
paid by the node before them.

But then, this preimage propagates backwards to the sending node.  So, each node
in turn will pass the preimage to the node before them to unlock their funds
from the upstream HTLC.  Once this preimage makes its way all the way back to
the sender, then the entire payment is complete and the sender has their proof,
the preimage is their proof that they made the payment.  And normally this all
happens offchain.  So, these nodes are just sending preimages directly to each
other and negotiating updates to their channel state.  But if any channel on
that chain ends up being force closed before the HTLC is resolved, then these
contracts get resolved onchain.  This is why it's very important that every LN
Node is monitoring the blockchain so that they can recognize when these HTLCs
get settled in an onchain transaction, and they can extract the preimage and
claim their upstream funds using it.

This is where Eclair had a big problem, where in certain edge cases, they
wouldn't actually notice or they wouldn't correctly identify these preimages,
and so they could end up losing these HTLCs.  And it's a little subtle, a little
subtle how this vulnerability existed, but kind of the simple way to explain it
is there's multiple states in a LN channel.  You have your local node state,
which is your commitment transaction, that may have a certain number of HTLCs on
it; and then, there's the remote state that may have slightly different HTLCs,
just because you haven't synced your states yet.  So, during the process of
updating the state, there's always this asynchronous aspect to it, where the
local and remote commitments can get a little bit out of sync.  And so, Eclair
would only look at HTLCs that were in its local commitment transaction.  And so,
when they saw anything that looked like a preimage on chain, they would say, "Do
I know an HTLC that this preimage would satisfy?"  And so, they would look at
their local commitment and they'd be like, "No, this preimage doesn't matter to
me", and then they'd ignore it.

But if that preimage was in their channel counterparty's commitment transaction
and not theirs, then that actually was an important preimage that they would
ignore.  And so, an attacker could do this on purpose where they would create a
certain state so that their commitment transaction would have an extra HTLC that
Eclair would not.  And then, they would be able to steal that HTLC whenever they
wanted.  So, that's the vulnerability.  And again, it's important to update to
0.12.0 or newer.

**Mark Erhardt**: So, basically, as the HTLC is built up and sent through the
network, all the commitment transactions get updated.  And as it's being rolled
back, there's this intermediate state where one side has already given up on the
old channel state, but the other one hasn't yet.  And they, at that point,
deleted the HTLCs from their database, but should have kept it until the other
side had also rescinded the old commitment transaction.  Is that basically it?

**Matt Morehouse**: Yeah, that's, that's the general idea.  So, again, it gets a
little subtle, but the attacker would basically tell the Eclair node that, "I
want to fail this HTLC", and then the eclair node would be like, "Sounds good",
and they would delete it from their commitment transaction.  But the attacker
still hadn't revoked its previous commitment, but still the HTLC.  And so then,
they could broadcast that old one that still had the HTLC, and Eclair wouldn't
notice the preimage for it and would end up losing the value of that HTLC.

**Mark Erhardt**: That's a really nice catch.

**Mike Schmidt**: Matt, it sounds like you discovered this in just speaking with
t-bast, who works on Eclair.  You guys were chatting and then this kind of fell
out of it?

**Matt Morehouse**: Yeah, this was very lucky, I guess.  Bastien and I were
talking about the LND excessive failback vulnerability from six months ago, and
I just wanted to make sure that Eclair didn't have a similar vulnerability and
that Eclair was handling it right.  And while we were discussing that, Bastien
basically pointed to this code and said, "This is pretty tricky, but I'm pretty
sure the comment here is correct, so it should be safe.  But if you have time,
please look at it".  So, I looked at it, and after thinking for a few minutes,
I'm like, "This just doesn't look right".  And so, we discussed some more, and
found that it was in fact a true vulnerability.  And I'm very thankful that
Bastien pointed to that code, or else I would have never looked at it.

**Mike Schmidt**: It sounds like some of the reaction on the Eclair side is
appropriate, in that I think you mentioned this in your write-up and I've also
maybe seen it elsewhere, that they're sort of shoring up a lot of their testing
and increasing coverage.  I know that's something that you've advocated for
across implementations previously.

**Matt Morehouse**: Yeah, I've been very happy to hear that they've been taking
this seriously.  I'd like to see all implementations really doing a similar
thing.  So, basically, after they fixed this vulnerability, they added a full
test suite, not just covering this vulnerability, but looking at all the
possible ways they could think of that something weird could happen when you're
handling a forced-close, and trying to make sure the funds are safe in all those
scenarios.  And Bastien also said that they're now also regularly re-auditing
this tricky piece of code.  And I think that's very important because many
vulnerabilities that I've reported in the past and other implementations are in
a similar area of code.  And this is a very important piece of code to get
right.  And so, I really think it's setting a pretty good example that I'd like
all implementations to consider regularly auditing, thoroughly testing, and
especially these very important pieces of code.

**Mike Schmidt**: Well, great find, Matt.  Murch, I don't know if you have any
other questions.  No?  All right.  Well, thanks for joining us, Matt.  Great
work as always.  Always fortunate to not have to worry about the LN
implementation stuff.  You're finding lots of vulnerabilities.  It's a blessing
and a curse that you're joining the show so much.  Obviously, it's great that
you're talking about this work, but it's a little bit unfortunate that these
keep happening.  But hopefully, folks take the route that Eclair's taken here
and are shoring up their testing, and we have you on less and less, Matt.

**Matt Morehouse**: Yeah, that would be great.  I hope I don't have to keep
coming on all the time.

**Mike Schmidt**: All right, thanks for joining us, Matt.  Have a good rest of
your day.

**Matt Morehouse**: Thanks.  See you.

**Mike Schmidt**: We're moving to our monthly segment from the Stack Exchange.
We have a dozen questions this week after, I think, a light week the month or
the month prior.  There's a bunch of questions around OP_RETURN.  A lot of these
were the same person, but I do think they're topics that are actively being
discussed in the community.  So, it might make sense to just do, I'll do a quick
framing of how we got here, and then some of these are going to be
philosophical, and some of these are going to be more in the weeds, but I think
having maybe a big picture for the audience might be helpful.

So, as a reminder, in 2014, OP_RETURN was sort of designated a less abusive
place to put arbitrary data, compared to what people were putting elsewhere.
So, that was designated, "Hey, put your stuff here".  Since Bitcoin has
arbitrary scripting capabilities, that means there's essentially an infinite
number of schemes or ways that people can put arbitrary data into it.  So,
designating this OP_RETURN was sort of a way to say, "Okay, just do it over
here".  Lo and behold, in 2023, one of those other of the infinite schemes that
could be contrived was contrived and rolled out and got popular.  That would be
inscriptions.  And since that scheme used witness data, it was both cheaper and
had higher capacity than OP_RETURN.  So, with inscriptions both available and
popular, the existing 80-byte default limit in Bitcoin Core for OP_RETURN was,
let's say, outdated; but maybe not just outdated, it was actually creating the
exact mal-incentive it set out to, avoid since the limit incentivized then the
use of fake public keys or other more harmful methods for storing data, which
was especially true for the range of data between 80 bytes and 143 bytes.

I think that's right, Murch.  I think you've done research on this.  For larger
than 143-byte sizes, inscriptions is actually cheaper, if your goal is strictly
to get arbitrary data into Bitcoin somehow.  And for the 80- to 143-byte range,
people were just going to use fake public keys as a way to bridge that gap in
that range from the 80 to 143.  So, becoming aware of that mal-incentive through
discussions with protocol working around that OP_RETURN limit, core developers
have now raised the OP_RETURN limit to eliminate that mal-incentive.  And the
following questions jump into the details around that change, including why not
143; why not 160; etc.  So, we'll jump into the first one here.  Murch, anything
else that you think would be background?  Okay.

_Implications of OP_RETURN changes in upcoming Bitcoin Core version 30.0?_

First question, "Implications of OP_RETURN changes in upcoming Bitcoin Core
version 30.0?"  And Pieter Wuille answered this one, first echoed the sentiment
of the person asking the question.  agreeing that, "Bitcoin is money, not a
storing database, and strictly only monetary data should be on the blockchain".
He went on to point out the folly of relying on onchain storage for data,
including examples of him trying to convince others historically not to do such
things.  He then points out that little can be done if people choose to do it,
and miners who are driven by economic incentives choose to include it, saying,
"Data can always be disguised as payments, making attempts to stop or even
discourage a cat-and-mouse game, which at best pushes those who pay for those
use cases to slightly less efficient techniques".  He also points out that,
"Given enough economic demand for data storage, nothing prevents submitting
transactions directly to willing miners".  This would be what people have
referred to as 'out of band'.  And then he goes on to ask, "Philosophically,
would you want a Bitcoin in which some subset of node runners get to decide
which transactions are allowed or not, given that, if effective, the same
mechanism could be used to block 'undesirable' payments, while providing a
censorship-resistant payment system was the very thing that Bitcoin was designed
to enable?"

He then gets into commenting on how filtering these kinds of transactions is
harmful for mining centralization.  He referenced earlier the out-of-band
payment.  So, if the network at large is restrictive to certain types of valid
transactions that both the person wanting to transact and buy blockspace for and
the person selling the blockspace, the miner, if the marketplace, if you will,
or the network where all of these transactions are routed is too restrictive,
then with enough motivation, folks will go out of band.  And that is things like
Slipstream, that came out around the same time as the discussion of putting in,
I think, an additional filter for inscriptions.  Slipstream came out after that.
I think there's a new consortium similarly to do this for potentially
BitVM-based data that they've all agreed that they're going to do this.  So,
there's obviously risk there, in that small miners cannot participate in those
networks, right?  A miner that is number 275th largest miner is not going to be
having these out-of-band payments routed through them.  So, the large miners
benefit and the small miners don't.

So, those were my notes from this first item.  There's more in there.  I thought
he did a great write-up.  I think people should read it.  Murch?

**Mark Erhardt**: I think I want to double-down on why is it harmful for mining
decentralization.  Let's say there's a couple of mining pools, big mining
operations that accept large OP_RETURNs, and some new scheme starts up that
creates a lot of these large OP_RETURN transactions that then compete to get
only in the blockspace of those two miners.  Let's say those two miners have
together 30%.  So, we get sort of a two-tiered queue for getting into blocks,
where these large OP_RETURNs from the scheme are bidding on 30% of the hashrate
on the blockspace of those two miners that include them and see them, and
everybody else doesn't see them.  And that might very quickly, if they outbid
each other and there's huge demand for it, lead to these two mining pools
earning several bitcoins more per block in additional fees that other miners
just don't see.  So, if this state were to persist, or even for a relatively
short time, they would just have more revenue that they can create or convert
into more hashrate, and thus get a bigger share of the hashrate from this
behavior.

So, if these mempool policies are already being ignored by part of the hashrate,
and we see very little resistance to when those transactions are being sent,
this is a likely scenario, or not likely, this is an outcome if that scenario
comes to pass, and that's not great.

**Mike Schmidt**: And, Murch, would you say with the way that the halvings take
place, that as the subsidy is lowered, that transaction selection is going to be
more important in the mining space and so thus having access to
higher-fee-paying transactions, if you're taking a long-term view of Bitcoin, is
something that we would want to minimize now, but especially for in the future?

**Mark Erhardt**: Yes and no.  So, first, no, because right now blockspace is
fairly low demanded.  We see a lot of blocks recently that have feerates that
are below the previous minimum feerate, like <sup>1</sup>/<sub>3</sub>
sat/vbyte.  And at that feerate, the fees are a fraction of a percent of the
total block reward.  And by miners taking this cut in minimum fee recently, for
unfathomable reasons, they essentially staved off this time when the block
reward will consist more of transaction fees rather than just subsidy by another
ten years or so.  So, if and when these lower feerates become the new active
minimum, they will again be a tiny little portion of the overall block reward.
So, yes, over time, obviously the block subsidy will continue halving, and if
the minimum feerate remains stable, eventually full blocks will earn more reward
in fees than in subsidy.  But if miners continue to accept lower feerates, that
might never come to pass.

**Mike Schmidt**: Sure, but if what you were saying previously was that there's
risk to out-of-band payments or some people are saying private mempools, if
there's a risk now to that, isn't the risk only greater when that is a larger
percentage of potential revenues?

**Mark Erhardt**: Yes, sure.  I mean, we saw the first blocks where the
transaction fees were higher than the subsidy in, I believe that was, was that
the first time last year in April?

**Mike Schmidt**: I think so.

**Mark Erhardt**: Yeah.  We saw huge transaction fees around segwit, but they
were on the order of 10 bitcoin and the subsidy was higher then, so yeah.  We've
now seen blocks for the first time where the transaction fees contributed more
to the reward than the subsidy.  And with the subsidy shrinking, if the network
chooses to bid to that level again, obviously as subsidy goes down, fees will
take an even bigger relative proportion of the reward.  But with the minimum
feerate going down, the incremental relay feerate also went down.  So, I think
the burstiness of feerates was also significantly reduced by the recent feerate
cut.  So, I don't know, might be a little further off again.

**Mike Schmidt**: I don't remember if we touch on this later, but I'll bring it
up here.  Murch, I've seen people say, "Hey, Bitcoin Core developers are
uncapping this because they think people are going to use that instead of the
inscription scheme", and I don't think that that's true, right?  I think in some
cases, we mentioned that range of bytes, and maybe there's something a little
bit more, and maybe some protocols require it to be in the output as opposed to
the input or in witness data.  But I don't think the stance of Core developers
is that, "Hey, uncap this, put it here, even though it's more expensive and
there's less capacity", right?  That's not an anticipation.

**Mark Erhardt**: I would say that charitably, that's a misunderstanding, but I
think that it's also been brought up much more often than a misunderstanding
would be.  I think the motivation was very explicitly that for people that want
to put data into outputs, it would be overall preferable if they put it into
OP_RETURN outputs than into payment outputs.  As we discussed already,
inscriptions are cheaper for larger data payloads, and it's somewhere in the
range to 143 or 160 bytes or so where OP_RETURN is cheaper or similarly as
expensive as inscriptions.  And then you save a second transaction, so it might
be attractive around that or even a little higher than that.  It doesn't seem
likely at all to me that people that have already built tooling for inscriptions
and that are happy with the inscription mechanism, would retool in order to use
a more expensive mechanism for putting data payloads.  So, I find that the
expectation that people would use OP_RETURN over inscriptions is completely
misplaced.

_If OP_RETURN relay limits are ineffective, why remove the safeguard instead of keeping it as a default discouragement?_

**Mike Schmidt**: Moving to the second question, which we sort of touched on,
"If OP_RETURN relay limits are ineffective, why remove the safeguard instead of
keeping it as a default discouragement?" and this is what I referred to earlier
as a mal-incentive.  Antoine answered this one.  It's basically pointing out
what we mentioned before, which is right now, if you wanted to put 150 bytes of
arbitrary data and you wanted it to be standard, you could do it in
inscriptions, but some of these layer 2 protocols are putting them in outputs.
And what folks were doing or planning to do is, "Okay, I'll use the 80 bytes in
the OP_RETURN, and then I'll add a fake pubkey or a fake address to encode a
little bit more, and maybe I need one or two more fake addresses to encode that
data", and so it was more wasteful to do that than just bumping the OP_RETURN
limit, so that it's in an unspendable output, as opposed to something that is
maybe spendable.  Is that right, Murch?

**Mark Erhardt**: Sure.  Was there anything else that you wanted to explore?

_What are the worst-case stress scenarios from uncapped OP_RETURNs in Bitcoin Core v30?_

**Mike Schmidt**: No, not on that one.  Next question, "What are the worst-case
stress scenarios from uncapped OP_RETURNs in Bitcoin Core v30?"  I didn't
prepare all of these, but this person is essentially asking about all OP_RETURN
blocks, mempool flooding, propagation considerations, and storage growth, and
then fee market impact, sort of taking what happens in the extreme, what if the
block is all OP_RETURNs?  Although there's some maybe incorrect assumptions in
these questions, like filling an entire 4 MB block with OP_RETURNs, which can't
do because it's only 1 MB, because OP_RETURN's in the output.  But both Pieter
Wuille and Vojtěch answered each of these five hypothetical questions point by
point.  I think probably, if you're curious about this, just jump into the
answers that they both gave.

**Mark Erhardt**: I think those are points that I've been seeing a lot on
various social media, so why don't we just jump into them?  So, OP_RETURNs
cannot amount up to 4 MB, because output data is not witness-discounted.  So, if
you write data to outputs, the old limit, the block size limit applies, and you
can at most write 1 MB of data.  So, 4 MB blocks due to OP_RETURN are literally
not possible, they would be consensus invalid.  If you submit transactions to
the mempool, sending around bigger transactions is at best more efficient.  So,
yes, they'll take more memory in your RAM because they're bigger, but the
overhead of announcing them to peers, the overall additional bandwidth for the
metadata, and so forth, all is less than multiple transactions that are smaller.

**Mike Schmidt**: And this is also Pieter Wuille answering this, who is working
on restructuring some of the mempools, so he's very familiar with that.  And,
Murch, maybe to point out, yes, these OP_RETURNs are bigger and they take up
more RAM in your machine, but at the same time, there's still size limitations
on the mempool, correct?  So, that's not a concern in terms of consuming more
node resources.

**Mark Erhardt**: Right.  So, the block size limit remains in place, or I should
rather say the block weight limit remains in place, and the standardness weight
limit for transactions also remains in place.  So, while the OP_RETURN limit is
no longer smaller than the transaction weight limit, the transaction weight
limit is unchanged, and therefore Bitcoin Core nodes in the default
configuration will not accept transactions bigger than 100 kvB (kilo-vbytes).
So, no, you cannot send full-block-sized OP_RETURN outputs.  That won't work.
We will not accept them, we will reject those.  Of course, miners can still
include them directly, they're consensus valid.  So, the out-of-band thing still
works just like before.

**Mike Schmidt**: Did you want to continue with number three here, "Propagation
asymmetry: could sustained megabyte-heavy blocks widen propagation gaps?"

**Mark Erhardt**: I mean, if a miner accepts a 1 MB OP_RETURN and puts it in a
block, nobody will have seen that on the network, just as before this policy
change.  If miners accept OP_RETURN outputs that are up to 100 kB, they will
have propagated on the open network and hopefully nodes had them before.  So,
the block will propagate very quickly, because the compact block announcement
with the recipe how to recompile the block from the list of transactions will be
tiny and the transactions will be pre-validated, and it will be very quick and
easy to validate that block.

**Mike Schmidt**: And then the next point here from this extreme scenario list
is about storage growth.  I think the person asking the question, as Murch
pointed out, was misunderstood by saying that you could have a 4 MB block of
OP_RETURNs.  And so, actually, a block full of OP_RETURNs would be better in
terms of disk growth, because it would only be1 MB, which I'm pretty sure is
smaller than the average block these days, even with low demand for blockspace.
So, that, I think, is a non-concerning item.

**Mark Erhardt**: Correct.  So, we have about 54,000 blocks per year, and if
they're full of OP_RETURNs, that means we'll have less than 54 GB of blockchain
growth per year.  Currently, we see about 80 GB of blockchain growth per year
with the current mix of transactions on the chain.  So, if it were all full of
OP_RETURNs, the blockchain actually would grow more slowly than it does today.

**Mike Schmidt**: And then the last extreme scenario here is around what they've
titled, "Fee market impact".  But in their elaboration of that, they mentioned
fee estimation being stress tested for non-financial blockspace usage.  I would
guess the answer is yes, we had spam attack essentially for two years starting
in 2023.  Well, fee estimation doesn't make much sense.  Obviously, the fee
market is impacted in terms of these non-financial transactions competing with,
from a feerate perspective, arbitrary data transactions, which can result in
feerate spikes like we've seen the last few years, especially around the epoch.
Anything else to add there, Murch?

**Mark Erhardt**: Well, okay, so obviously, people want data transactions to be
treated differently, but under the assumption that we just look at what we
accept in blocks and the feerate just applies, it's just more demand for
blockspace.  And if people purchase the blockspace for more money, they'll get
into a block.  And so, if there's more demand for blockspace, the feerates will
be higher.  Whether that's payment transactions or data transactions, I think
the mechanisms are basically not different at all, with the slight difference,
of course, that people might be more upset for bidding against a use case they
don't agree with.

_If OP_RETURN needed more room, why was the 80-byte cap removed instead of being raised to 160?_

**Mike Schmidt**: Next question on OP_RETURNs is, "If OP_RETURN needed more
room, why was the 80-byte cap removed instead of being raised to 160 bytes?"
Murch, I think we touched on this earlier, but there is that mal-incentive, at
least strictly from a data perspective, between 80 and whatever, let's call it
160, where it's like, "Okay, there is a bad incentive there".  And I think
people are maybe more amenable to something like that.  Whereas once you get to
161 and above, let alone uncapped, people are a little bit confused about that.
I'll give Ava and Antoine's answers and then maybe you can comment as well.

So, Ava and Antoine gave three reasons for going above the 160 as a default.
One was an aversion to continually setting the cap.  So, for example, if there's
some new zero-knowledge proof, etc, whatever, that is 165 bytes, now we have an
internal civil war every time some new protocol comes out with something that is
seemingly a valid proof that needs a little bit more data.  And not wanting to
have that fight every few years is potentially desirable, which was one point.
The second point was that existing large miners are already bypassing the cap
and allowing things beyond 160.  And so, that gets into Murch's sort of, should
all miners be able to compete, small miners included, with a 200-byte OP_RETURN
transaction, or should that be only something that large miners get?

Then, the last point from Antoine here was pointing out risks of not
anticipating future onchain activity, which also goes back to a point I made
earlier in the show with Daniela, which is policy is slow to change.  So, you
even see with this sub-sat feerate, with 99% of the network having 1 sat/vB
being the minimum, we see this flood of transactions, you see compact blocks
having an issue.  29.1 gets rolled out.  You say adoption is now at 12%, but
it's been a month, right?  So, policy is slow to adapt.  So, I think Antoine's
point is if you're not anticipating future onchain activity, or at least there's
risks of restricting that.  What are your thoughts on these three, Murch?

**Mark Erhardt**: Let me first disagree on the policy adjusts slowly.  I was
actually caught off guard how quickly the minimum feerate changed.  So, clearly
there had been a bunch of nodes on the network for a long time that were
accepting transactions with lower feerates.  But the moment some miners started
accepting transactions with lower feerates, it took only a couple of weeks for
those transactions to propagate relatively well.  Now, we probably had some
manual preferential peering on the network at that point.  I saw some people
discuss lists of nodes that were accepting low feerate transactions and how to
manually connect and make a connected component in the network among those
nodes.  So, with a very low count of preferentially peering nodes, it works very
quickly.

Then also, it was already a configuration option in nodes, so whoever wanted to
participate could simply restart their node with the different configuration and
adopt it.  And with just a few percent points of adoption, this prior 12-year
gentlemen's agreement was broken, and now we have something like 40% of all
transactions below the previous minimum feerate.  So, I think what is extremely
slow to come into play is new restrictive policies.  I don't think that's
actually possible to adopt just a general mempool policy that is more
restrictive than prior policies when there is already an established use case.
It works to introduce one where there's no demand to break it, we've just done
so again.  But I don't think that, for example, introducing a policy that will
restrict behavior that senders and miners are already using on the network, I
don't think that that will work.  They'll just spin up nodes to run with the
policy that supports their use case.

On the other hand, to remove a policy or circumvent it, it apparently only takes
a few percent points of node adoption or some preferential peering.  And so,
soft pushback, it's slow.

**Mike Schmidt**: I think it's fair, but I think it depends on, I guess, how you
define the policy being rolled out.  The fact that a few Libre Relay nodes
preferentially peered and miners accepted it, yes, the transactions got in...

**Mark Erhardt**: Sorry, let me jump in.  Libre Relay did not propagate low
feerate transactions.  Bitcoin Core did not, and Knots did not.  This was
exclusively people that manually set a lower limit.

**Mike Schmidt**: Okay, the point's the same, that some tolerant minority, I
think as Adam Back calls them, can set it.  Yes, the transactions get in.  I
guess the question is, is that what we're saying, is the network has adopted
that policy?  Maybe, if that's a definition, then I would agree with you.  But I
would also say that if there's smaller miners or people doing fee estimation and
they don't have an accurate picture of the mempool because of these, like, did
it really roll out for them?  I don't know.  But yeah, point taken.

**Mark Erhardt**: Right.  So, I think we recently had a demonstration of a
networkwide policy change that I think was very organic, which was the full-RBF
adoption.  Mempoolfullrbf was first pushed back on, it clearly was broken on the
network.  It started happening and then it was adopted by Bitcoin Core.  I think
there was a lot less discussion about it because it had been clearly
demonstrated.  And after participating in this debate for a long while, I would
say that the arguments here for the OP_RETURN scenario I think are solid.  I
don't anticipate that there will be suddenly huge OP_RETURN outputs, because
there's essentially nothing new happening here on the network.  Inscriptions
could already do it.  Whatever people are doing there is not significantly more
interesting to do as OP_RETURNs.  But maybe we're skipping ahead to the
conclusion of this process too quickly, and that was probably a strategic error.

**Mike Schmidt**: Yeah, I've seen something like that brought up, is like, "Why
not do it full-RBF style?"

**Mark Erhardt**: Right.  So, in hindsight, if I could go back and do it again,
probably setting at a lower limit first, and then if that gets circumvented,
increasing it again a couple of times would have been a lot smoother
networkwide.  But I stand by the arguments and the conclusion being correct, and
that being the final outcome.  So, yeah, anyway, a lot of ink has been spilled
over this and I think now that we've already taken all the abuse for it, we
might as well stick to it.

_If arbitrary data is inevitable, does removing OP_RETURN limits shift demand toward more harmful storage methods (like UTXO-inflating addresses)?_

**Mike Schmidt**: Next question from the Stack Exchange, also on OP_RETURN, "If
arbitrary data is inevitable, does removing OP_RETURN limits shift demand toward
more harmful storage methods (like UTXO-inflating addresses)?  Ava points out
that I think that that's just a misconception that the limits being lifted are
going to encourage anything going out.  It's going to actually encourage the
less harmful alternative.

**Mark Erhardt**: This is exactly opposite of what the expectation is.

_If OP_RETURN uncapping doesn’t increase the UTXO set, how does it still contribute to blockchain bloat and centralization pressure?_

**Mike Schmidt**: Yeah, exactly.  Next question, "If OP_RETURN uncapping doesn't
increase the UTXO set, how does it still contribute to blockchain bloat and
centralization pressure?"  And then, the answer from Ava here gets into some of
the how, in a future of increased usage of OP_RETURNs, how does that affect
resource utilization of Bitcoin nodes?  And we sort of touched on that earlier
when Murch went through those five points from the extreme scenario, but
basically less usage, right, Murch?

**Mark Erhardt**: To steelman the concern, I think the most salient point would
be someone comes up with some scheme where data is pushed in an OP_RETURN and it
needs a different output, a payment output to transport some sort of state out
of it, sort of like Runes or, or BRC-20s do, where in BRC-20, it provides the
recipient of a mint; and in Runes, the Runes are attached to other outputs.
They're defined in the OP_RETURN output, but then transported by payment output.
So, to steelman this concern, the biggest concern would be someone does
something where in OP_RETURN, they define some Colored Coin scheme, or whatever,
and then need additional payment outputs to transport the product.  And that
would increase UTXOs' creation.  But OP_RETURN itself is not added to the UTXO
set and makes the blockchain grow slower, and if they're propagated on the
network, reduces centralization pressures.  So, I think that's a zero out of
three.

_How does uncapping OP_RETURN impact long-term fee-market quality and security budget?_

**Mike Schmidt**: "How does uncapping OP_RETURN impact long-term fee-market
quality and security budget?"  Ava answered this one, it was actually a series
of questions that Ava answered about hypothetical OP_RETURN usage and its impact
on future Bitcoin mining revenues.  This is maybe something that I've heard
people talk about as well, which I think is incorrect, that Bitcoin Core
developers, Murch, correct me if I'm wrong, think that, "Hey, this is great, we
want to solve the security budget any way possible, including making Bitcoin a
file storage system, or some such thing".

**Mark Erhardt**: I don't know if you've picked up on it yet, but I couldn't
care less for all of the monkey picture stuff.  But essentially, we're adopting
a neutrality stance where what pays stays.  I think that most Core developers
would consider this spammy behavior to be a nuisance more than an attack or an
actual problem.  So, potentially, if a lot of people start using OP_RETURN for
something, it might increase demand for blockspace temporarily, probably because
every time before when OP_RETURN got a lot more use, it tapered off within
months because it's very expensive.  And I do not perceive this to be a building
block for a long-term strategy to increase blockspace demand.  I think all of
our arguments have been laid out.  I think the argument is merely, it is more
benign than data in payment outputs and it's more expensive than inscriptions.
So, it's just not a big issue and it's probably not going to significantly
affect the blockspace market.  And if it does, it'll create smaller blocks and
potentially a little more competition for blockspace temporarily.

_Assurance blockchain will not suffer from illegal content with 100KB OP_RETURN?_

**Mike Schmidt**: Next question is around, "Assurances that the blockchain will
not suffer from illegal content with 100 KB OP_RETURNs".  And user, jb55,
answered this, providing several examples of potential encoding schemes for data
that isn't contiguous data in 100 kB OP_RETURN concluding, "So, no, in general
you can't really stop these kinds of things in a censorship-resistant
decentralized network".  I would, I guess, add that if this question is assuming
that Bitcoin Core v30 is adding the feature of having the ability to have 100 kB
OP_RETURN, that is incorrect.  Those are obviously already possible.  And so,
the risks that this person is afraid of can happen today.

_What analysis shows OP_RETURN uncapping won’t harm block propagation or orphan risk?_

"What analysis shows OP_RETURN uncapping won’t harm block propagation or orphan
risk?"  Ava also answered this one and pointed out that there's not exactly a
data set or study showing isolating large OP_RETURNs specifically, but there
have been previous analyses of compact blocks and previous analyses of stale
blocks, and there's no reason to expect the behavior to change differently with
including large OP_RETURNs.

All right, that was it for OP_RETURNS.  Murch, do you have anything else to say
about OP_RETURNs before we move on to other topics?

**Mark Erhardt**: I'm going to say something very unpopular, but I cannot wait
for Bitcoin Core 30.0 to come out so we can move on.

_Where does Bitcoin Core keep the XOR obfuscation keys for both block data files and level DB indexes?_

**Mike Schmidt**: "Where does Bitcoin Core keep the XOR obfuscation keys for
both block data files and LevelDB indexes?"  I think we had a similar question
last month, but not quite the same.  Vojtěch pointed where the chainstate key is
located within LevelDB under a specific key, and also the XOR.dat file for the
block data obfuscation.

_How robust is 1p1c transaction relay in bitcoin core 28.0?_

"How robust is 1p1c (one-parent-one-child) transaction relay in Bitcoin Core
28.0?"  And Gloria actually answered this question since I think it was her
reference to non-robustness that spurred the question initially.  She clarified
that the non-robustness that she referred to in the original opportunistic 1p1c
relay PR meant, "Not guaranteed to work, particularly in the presence of
adversaries or when volume is really high so we miss things".

**Mark Erhardt**: I mean, in a way that's maybe a term we could have used more
in the whole evaluation of the statement, "Do filters work?"  Because with a few
percent points of nodes relaying something, it relays non-robustly.  It's not
guaranteed to work, you can't rely on it, you also probably can't rely on it
being included in the next block.  But with just a few percent of the nodes
relaying non-robustly, it works pretty decently if you have a little time to
wait, or if you're willing to connect to a single other node that you know
accepts it, or you just churn through peers for a while until you get a peer
that takes it, or you submit it through an API directly to a miner, it does work
and it gets into a block eventually, non-robustly, and certainly not the next
block guaranteed.  So, in a way, the big distinction is, are you just trying to
get into any block sometime this week, or are you trying to be in the next block
reliably?

So, if you are, for example, designing a protocol, a second-layer protocol,
where you rely on transactions getting confirmed, you would not be able to rely
on this mechanism to guarantee that the CPFP package propagates on a network.
But it works if there's nobody trying to stop it and the stars align right, and
it's also been made more robust since 28.  So, in 28, it was just when we
noticed that a transaction was rejected due to fee and there was a child that
came in that was spending that previously for low feerate rejected transaction,
we would try them as a package.  And in absence of adversity, this would just
work.  But then, we also improved the design for orphanage, and I'm generous
with the 'we'; Gloria did all the heavy lifting here.  The design of the
orphanage was improved to make it more robust, by making the limits apply to
specific peers.  So, if one peer started churning your orphanage, they would
only churn out themselves instead of everyone.  And now, with the ephemeral
anchor design and the TRUC (Topologically Restricted Until Confirmation)
transaction design, there is a solid mechanism that robustly transports
commitment transactions with zero fee and a fee-carrying child.

So, we're now seeing that the LN developers are moving towards adopting this
scheme.  And this, for example, resolves or very specifically resolves a lot of
the issues around channels closing down due to feerate spikes, because when
commitment transactions do not need a channel reserve and do not need to have
fees that are high enough to make it into the mempool, because they can always
be propagated at the time that one of the parties wants to close the channel
unilaterally by attaching fees to the child, this makes LN a lot more robust.

_How can I allow getblocktemplate to include sub 1 sat/vbyte transactions?_

**Mike Schmidt**: Last question from the Stack Exchange, "How can I allow
getblocktemplate to including sub-1 sat/vB transactions?"  The person asking
this question, inersha, also answered their own question.  They had initially
set minrelaytxfee to 0.1 sat/vB, and was wondering, "Hey, why, when I'm trying
to build a block template, aren't I seeing any sub-sat feerates?"  And the
answer was, they needed to also set blockmintxfee in their conf as well, and
then they were able to see that.  Murch, I think that's why, when there was the
PR that we covered previously that lowered the minrelaytxfee, that it also
relayed blockmintxfee, is that right?

**Mark Erhardt**: Yes, that is correct.  So, there's a bunch of different
configuration options that apply to feerates in different contexts.  Very
closely tied together are minrelaytxfee and incrementalrelaytxfee, which both
provide one aspect of the feerate for sending data, "What is the cost of sending
data across the network in the context of replacement or initial transaction?"
And then, there is a separate configuration option for what you want to include
into a block template.  So, if you're a miner that wants to have all the
transactions that are currently being considered by miners, you should probably
have a low minimum feerate.  But if you don't want to include low-feerate
transactions yourself, you could set a higher blockmintxfee to make your block
template not include those.  Or if you want to mine everything that is in your
mempool, or consider anything for your block template, you'd set a very low
blockmintxfee, maybe even lower than the incremental and minrelaytxfee, and then
you would get all of these in your block template as they are in your mempool.

There's also the opposite, to send transactions that use lower feerates, there's
a separate configuration option.  I think it's mintxfee, and that is a wallet
configuration option which is what the minimum feerate is that your wallet will
use to build transactions.

_Bitcoin Core 30.0rc1_

**Mike Schmidt**: Releases and release candidates, we just have one.  Bitcoin
Core v30rc1, which actually RC2 is out now.  FYI, if you're testing on RC1,
check out RC2.  Also this week, we referenced the RC testing guide, which Jan B
put out, which is great if you're looking to test something.  That's at least a
place to start pointing at certain features and how you might test those.
Obviously, you want to deviate from the guide a little bit to test some
different things and test your current setup and how you run things, but it's
nice that we have that testing guide out there.  If you're curious what's in
v30, Murch did a great recap last week covering that and, Murch, you were also
on Pete Rizzo's show, I think, Supply Shock talking about v30 stuff as well.
So, we'll point listeners to those two pieces of content to get more.

Notable code and documentation changes.  So, I'm not sure if folks are aware,
but Gustavo has been authoring this section for, I don't know how long now, at
least six months, maybe longer, and we haven't had him on to talk about his
work.  And so, he authored this and he's going to walk us through these today.
Gustavo, do you want to say anything else about what you've been up to so folks
know who you are?

**Gustavo Flores Echaiz**: Yeah, certainly.  So, actually, it's been since May
that I started, past May, so more than a year now.  But I mean, this is a great
opportunity to learn, as there's always an infinite amount of things to learn
when you dig into these topics.  And it's very humbling.  But yeah, I'm very
happy to do this.  I've been working on the Bitcoin space for a bit, like seven
years now, mostly as a startup founder.  Right now, I have my own startup in
Mexico, called Swapido, which allows you to convert Bitcoin Lightning to pesos
in a bank account, so it's a very easy way to pay for daily expenses as a
bitcoiner in Mexico, but I also write this part of the newsletter.  So, yeah, I
can get started on each topic.

_Bitcoin Core #33333_

So, the first one, Bitcoin Core #33333.  This is about a new startup warning
message that happens when your node setting on dbcache exceeds a cap derived
from your RAM.  So, for example, this is a common setting that people will
configure to speed up their IBD.  But however, there's a point where just
increasing it doesn't have any effect, right.  So, if say you have 3 GB of RAM
but you increase this setting to higher than 3 GB, it will not have an effect
and actually it will have a problem effect, where it can create out-of-memory
errors, heavy swapping, it can even shut down your machine.  So, a new warning
message is added on this PR so that you are warned when it exceeds the advice or
limit that you should have, so for example, for less than 2 GB.  The threshold
is set as 450 MB.  Otherwise, the threshold is 75% of total RAM.

This follows up a change in September '24, a year ago, where the 16-GB limit for
this setting was removed.  So, even if you have a very powerful system, you
should be aware that this dbcache, putting this setting too high can create
out-of-memory errors or heavy swapping.  So, this is good for node runners that
maybe don't understand this feature as much.  Initially, when I started running
a node, I didn't really get it.  I thought you could just increase it to the
max.  So, this is good for those people.  Mike, Murch, any comments on that PR?

**Mark Erhardt**: Yeah, maybe let's just very briefly explain swapping.  So,
when you write to your memory, that is usually data that you are trying to keep
sort of in the short-term memory of your node, so it should be very accessible.
And when you try to write more to your memory than you have, and you have a swap
configured, it will be written to disk instead.  So, writing to disk is, I
think, 10 to 100 times slower reading from disk than reading from memory.  So,
when you do something that is very memory intensive and you keep writing and
reading from the disk, it will slow down your computer to a crawl.  So, you
don't want to exceed your available memory in order to stay faster.  So, even if
you allow a smaller amount of memory, it will be significantly faster than
overshooting and getting into swapping.

_Bitcoin Core #28592_

**Gustavo Flores Echaiz**: Totally, thank you.  Thank you for that.  So, we're
moving on to the next one, Bitcoin Core #28592.  This increases the per-peer
transaction relay rate from 7 to 14 for inbound peers, and 2.5 times higher for
outbound peers, which is 35 transactions per second.  So, this is something that
I had no idea existed.  A Bitcoin Core node has a limit on how many transactions
it relays per second.  It used to be 4 for inbound peers and 2.5 times higher
for outbound peers.  And now, it's been doubled.  I mean, the reason why this
change has been done is due to an increase of presence of smaller transactions
on the network.  This is probably related to just optimization with taproot, but
also probably related to the 1p1c outputs, like new ephemeral anchor outputs, or
different sorts of transactions that just take smaller size so you can just
broadcast more a second.  The reason why the outbound peers' rate is higher, 2.5
times higher than for inbound peers, is because these are peers that you, as a
node, have selectively chosen.  So, you prioritize these peers instead of the
inbound connections that you haven't chosen, and also the quantity of inbound
peers can be way higher than of outbound peers.  So, yeah, maybe Murch or Mike,
you want to add something here?

**Mark Erhardt**: Yeah, so the 7 transaction per second figure comes from a very
old estimate of how many transactions the Bitcoin Network can sustain in total.
This is basically just the then average size of transactions used to divide the
available blockspace.  And being able to forward significantly more transactions
than can fit into blocks would make it easy to have distributed DoS attacks on
the network, where you just create and replace a ton of transactions and then
flood them around the network, just wasting all the bandwidth of nodes.  So, we
don't announce more than basically what can fit into blocks, with a little bit
of a margin, to our peers.  And while we have transactions queued up to be
announced to our peers, if we receive other transactions that have higher
feerates, we will re-sort that and we will first announce the most attractive
transactions to our peers.  So, we sort of have this little bit of back
pressure.  If too much stuff gets announced, we will announce the transactions
that probably will be included first in blocks before other transactions.

For context, there was a problem, I think it was around the halving when there
was a lot of blockspace demand and feerates increased very significantly, where
more transactions were being sent and replaced than we could broadcast with this
limit in place.  And then the queues grew faster than we could flush them, and
that actually caused nodes to slow down, because they had so many transactions
queued up that they kept sorting for what to announce next.  So, this is just
sort of pushing up the back pressure limit in order to always be able to flush
this cash faster than we receive.

_Eclair #3171_

**Gustavo Flores Echaiz**: Makes a lot of sense.  Thanks for the extra context.
Moving on, Eclair #3171 removes PaymentWeightRatios.  So, this was a pathfinding
method that assumes uniformity in channel balances and replaces it with a newly
introduced probabilistic approach, based on past payment attempt history.  So,
this previous method that was used for pathfinding basically assumes that all
channels have the same capacity, they have the same age, they have the same CLTV
(CHECKLOCKTIMEVERIFY).  And you could adjust these settings on your previous
config in Eclair so that you could make, let's say, the channel age more
important than the channel capacity.  So, you could adjust these ratios, but
they would still be uniform across channels.  So, this was a simpler model, it
was probably cheaper to reason about, but it was blind to the real-world
liquidity and outcomes.

So, in Newsletter #371, we covered that this new method was introduced, that
instead of assuming that all channels work similarly or have similar age and
capacity, instead it introduces a new option called use-past-relay-data, that
when set to true, it uses a probabilistic approach based on past payment attempt
history to improve pathfinding.  So, it looks up when you tried to use this
path, did it fail yet or did it succeed, and what amount were you trying to
route?  And it will then take that data from past payment attempts or past
success attempts, and it will use that method to pathfind instead of the
previous one.  And I believe that they've removed now this old method, because
the new one has been way more successful at giving results.  However, this does
not mean that the newly-introduced approach is set on true by default.  This is
maybe something that confused me a bit, because if you're removing the previous
method but you're not setting the new method by default, maybe here I missed the
gap, but from what I understand, they're just moving slowly on this and they're
not setting it to default yet, but probably will at some point.  Any thoughts,
Murch, Mike?

**Mike Schmidt**: I think we've seen similar PRs in other LN implementations
recently in terms of optimizing or changing their algorithms.  So, yeah, seems
like a great change.

**Mark Erhardt**: I think one point, the uniform distribution, I think, was
referring to how the funds in the channel are located.  So, you always know the
total capacity of a channel, but you don't know on what side the balance is.
And what Eclair used to do was that it assumed that they were 50-50 split, so
they would be able to send about 50% of the capacity through a channel.  And I
think that's where the previous uniform ratio was referring to.  So, now, I
think we discussed this a little bit with Bastien last week or two weeks ago.
But when you route a lot of payments through the network, you will notice
whether a payment went through or not.  So, when a payment goes through, you
know that at least this amount of money was available on that side of the
channel; and when it doesn't go through, you learn a new upper bound.  So, this
seems to be connected to that research.

_Eclair #3175_

**Gustavo Flores Echaiz**: That makes total sense, thank you.  Thank you for the
extra context there.  So, follow-up, Eclair #3175.  This one's fairly simple.
Now, BOLT12 offers that have present fields but are empty, these BOLT12 offers
are now rejected because they are unpayable.  And what are these fields?  So,
the fields that are present but empty and are now rejected are offer_chains,
offer_paths, invoice_paths, and invoice_blindedpay.  So, from what I understand,
what offer_chains is, is it just tells you which network this is part of, so if
it's the mainnet network or testnet or signet network.  So, I believe this is a
mandatory field.  However, offer_paths, the next one, I believe this is an
optional field, where the blinded reply path is bundled in the offer instead of
the invoice.  And that would be the next field, which is mandatory
invoice_paths, where the blinded payment paths is bundled in the invoice itself.
And finally, the invoice_blindedpay is the TLV (Type-Length-Value) section that
carries the pay info for those payment paths.  So, the parameters the payer
needs to compute the blinded routes.

So, maybe I'm not sure I understand the difference between the last two.  But
the point here is that Eclair now rejects these offers because they're
unpayable.  When they have fields, even if these fields are present, but they're
just empty, instead, you should just fill these fields.  Any thoughts here?  All
good?

**Mark Erhardt**: I'm not sure.  I haven't dug too deeply into that.  But it
sounds to me that if these fields are optional, they have to not be present,
then the offer is acceptable.  Or if they are present, they have to have data,
but empty, they are no longer acceptable.  So, this would be, for example, the
case when, well, that's just an add-on, I think that's all.

**Gustavo Flores Echaiz**: Right, totally.  I just wasn't sure, because I've
seen some implementations make BOLT12 offers without blinded paths possible, and
others where the blinded path is mandatory.  So, I'm not sure if Eclair,
although theoretically these fields aren't maybe just optional theoretically,
maybe in Eclair themselves in that implementation itself they're mandatory, and
that's maybe where I wasn't sure.

_LDK #4064_

The next one, LDK #4064 dates the signature verification logic to ensure that if
a payee's pubkey is present, the signature is verified against it.  Otherwise,
if the payee's pubkey is not present in the BOLT11 invoice, then it can be
extracted from the signature with either a high-S or low-S signature.  So, this
is similar to something we covered in #371 for Eclair, and it's based on the
proposed BOLTs #1284, the specification update on that PR.  And it basically
just allows you to extract the pubkey from the invoice with either a high-S or
low-S signature.  That is the important point made here and something that was
covered for Eclair two newsletters ago.  Anything to add here, guys?

**Mike Schmidt**: Yeah, I would encourage folks if they're curious to go back to
that podcast where we had t-bast on.  It was Eclair #3163.  I just pulled it up
and I introduced it as a very boring item that we shouldn't waste t-bast's time
with, but actually was quite interesting.  So, we had a discussion with him and
actually Jonas Nick about this exact item.  So, check it out.

_LDK #4067_

**Gustavo Flores Echaiz**: Right, thank you for adding that.  Next one, LDK
#4067.  This one is actually one of the most interesting ones, in my opinion.
Support for spending P2A, ephemeral anchor outputs from zero-fee commitment
transactions. support for that is added.  It ensures that channel peers can
claim their funds back onchain.  So, this actually follows up Newsletter #371,
where LDK's implementation of zero-fee commitment channels was started.  And
this allows, well, #371 covered the implementation of the channels; and now,
this newsletter covers the PR that adds support for spending those P2A outputs
back and to claim them back onchain.  So, very cool to see that we're finally
seeing the implementation of ephemeral anchor on an LN implementation.  And I
imagine this is just the beginning of this implementation.  There will be
follow-up PRs that we'll add on top of this.  Anything to add here, guys?

**Mike Schmidt**: Yeah, this is another one.  Jump back to #371 with t-bast,
where we actually covered the LDK PR.  T-bast actually wrote the spec for that
PR implementation, so he gets into that.  And this PR this week is a follow-up
on that.  So, if you want to hear it straight from the spec author's mouth,
check that out.

_LDK #4046_

**Gustavo Flores Echaiz**: Nice, really cool.  So, the next two, well the next
one, #4046, LDK again, it's related to async payments.  This one enables an
often-offline sender to send async payments.  So, now we're getting to the
sender-side implementation for asynchronous payments.  So, how it works is the
sender sets a flag in the update at HTLC message to indicate to the LSP
(Lightning Service Provider) that the HTLC should be held by him until the
recipient comes back online.  And then, when the recipient comes back online, he
sends a release_held_htlc onion message to the LSP to claim the payment.

So, this follows previous PRs where the server-side logic for receiving async
payments was implemented, and also the client-side logic for receiving was
implemented.  We're now getting to the sender-side logic for that.  And let's
say, when you're in this asynchronous payments flow, the reason why here it
assumes that the node is offline is because first, the sender will request an
invoice from the LSP, and the LSP will request the invoice from the recipient
node.  And if it doesn't get a response, then it will feed the invoice himself
to the sender, and thus the sender then knows that this is the flow where the
recipient is offline.  And that's what this flow is about.  So, a lot of
different nuances in these different flows, considering all options.  But yeah,
I think we're getting to a point near where async payments are coming online on
LDK, but this has been a long development.  We've been covering this for months
already, but it's cool to finally see it coming ahead.  Any thoughts here?

**Mark Erhardt**: Yeah, that's very exciting.  I wanted to follow up from the
previous BOLT12 #3175.  I was incorrect.  Blinded paths are mandatory in BOLT12
offers.  You must provide at least one blinded path.  So, rejecting offers in
which the blinded path field is present but empty is just more strictly
enforcing the spec.

_LDK #4083_

**Gustavo Flores Echaiz**: Makes sense.  Thank you for adding that correction.
So, moving on, LDK #4083.  This is a deprecation of an endpoint called
pay_for_offer_from_human_readable_name.  And the reason why this is removed is
because a duplicate exists called pay_for_offer_from_hrn.  So, almost the same
thing but one with the acronym, the other one in full spelling.  So, the wallets
are encouraged to use a Rust crate called bitcoin-payment-instructions, and this
allows them to parse and resolve old payment instructions, not just BIP353 HRNs.
And once a wallet has resolved the payment instruction to know that this is a
BIP353 HRN, then they're encouraged to use the endpoint that is kept,
pay_for_offer_from_HRN instead of the one that was removed because it was a
duplicate.  So, here just probably this reduces confusion for developers that
are implementing LDK.  And it also just simplifies and just provides a cleaner
interface to developers.

**Mark Erhardt**: I also want to jump in and state here, BIP353, which defines
these human-readable names for LN and also onchain payments that are stored in
DNS, has been recently updated.  It's been moved to proposed.  It's been also, I
think, implemented by at least four different wallets and other software
projects.  So, if you're interested in this, check it out.  There's more test
vectors on it now.  It's proposed it might move to final soon if it gets more
adoption and feels fine.

**Gustavo Flores Echaiz**: Yeah, I just want to add a comment here that I'm very
hopeful for this development, because it seems to me that the LN industry or the
LN users have converged to using custodial wallets with LN addresses, because
they just they look like email addresses and they're static.  But BOLT12 and
BIP353 human-readable names, it basically offers the same user experience but
from a non-custodial endpoint, and from a more private view as well.  So, I
believe Phoenix already has this and a few other wallets, but its adoption is
increasing and I'm hopeful that we'll see a conversion towards this
self-custodial model instead of the previous custodial LN address model.

_LND #10189_

Moving on with LND #10189, here the sweeper system is updated to properly
recognize an error code related to the minimum relay fee not met.  So, the
sweeper system is what LND uses to claim back funds onchain, often on forced
closed transactions, and to broadcast this transaction while there are many
checks that this transaction has to go through.  And for example, if it meets an
error code such as this transaction pays a fee too low under the relay fee,
well, it should increase the fee and retry the transaction until the broadcast
is successful.  But here, there was a failure where the minimum relay fee error
was not recognized, thus the transaction was never retried and it was never
broadcasted.  So, users would find themselves with transactions that were never
broadcasted because of this mismatch on the error recognition.

So, this PR also improves weight estimation by accounting for a possible extra
change output, which is particularly relevant for taproot overlay channels that
are used for taproot assets.  So, this was the initial mistake, right?  The fee
was mistakenly accounted and it was too low, because one change output was not
considered.  And because the fee was too low and because the weight was probably
incorrectly accounted, then it didn't achieve the minimum relay fee required.
And then, that error code was mismatched so the fee wasn't bumped and it wasn't
retried.  So, this PR fixes both the weight estimation by accounting for an
extra change output; and also, if it came to fail again because it didn't meet
the minimum relay fee, well, this PR also fixes so that the error code will be
matched and the transaction will be fee bumped and retried until it is
successfully broadcasted.  This was particularly important then for people that
were using the overlay channels for taproot assets.  Any extra here?  No?  Cool.

_BIPs #1963_

And finally, the last code change we have here, or documentation change, it's on
BIPs #1963.  So, the PR #1963 for BIP157 and BIP158, these are the Bitcoin
improvement proposals that specify compact block filters.  Their status has been
updated from draft to final, because they've been deployed in Bitcoin Core and
other software since at least 2020.

**Mark Erhardt**: Let me jump in briefly.  They're not the compact block
filters, they're client-side block filters.  So, there's two things here that
have similar names.  The compact blocks are the mechanism by which we more
quickly announce blocks across the network on layer 1.  And the client-side
block filters are a way to find out whether there's relevant transactions in a
new block for light clients.  They basically get an inventory of a block, a
table of contents that they can quickly search to find out whether inputs or
outputs relate to whatever is in there.

**Gustavo Flores Echaiz**: Right.  Thank you for making that clear difference.
I guess the confusion here comes from the topic section on Bitcoin Optech, where
one is called 'compact block relay' and the other one's called 'compact block
filters'.  But to avoid that confusion, let's use the client-side block filters
name instead.  I just wanted to add that I worked at Wasabi Wallet for a little
while before it was shut down, and I mean I was always a fan of this technology.
I feel like people often will mischaracterize the need for running a node with
privacy, when instead you could just use a wallet that implements client-side
block filters.  So, well, I mean I'm happy to see that this is now considered a
final BIP, as it has been widely implemented already.  So, yeah, this completes
this section for this week.  Thank you, guys.

**Mark Erhardt**: Sorry, I should correct myself.  I didn't mean to say that
you're wrong.  The titles of BIP157 are Client-Side Block Filters is 157, and
Compact Block Filters for Light Clients is 158.  So, you are correct in the
term, but I like to distinguish them a little.  Or I just wanted to point out
that there's two things that are named very closely, because we've been talking
about both of them in this episode.

**Gustavo Flores Echaiz**: Totally.  Thank you for specifying that.  So, that
completes my part.  Thank you, guys.

**Mike Schmidt**: Gustavo, awesome.  Thank you for joining us and hanging on
through the rest of the newsletter and going through these, and also for
authoring these each week.  So, we appreciate that.  Maybe we'll have you on in
the future to do some more of these with us if you're up for it.

**Gustavo Flores Echaiz**: For sure, I'm up.  Thank you guys.

**Mike Schmidt**: We also want to thank Daniela and Matt for joining us earlier
for the News segment.  And thanks always to my co-host, Murch, for co-hosting
and for you all for listening.  We'll hear you next week.

**Mark Erhardt**: Hear you soon.

{% include references.md %}
