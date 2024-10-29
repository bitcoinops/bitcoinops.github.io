---
title: 'Bitcoin Optech Newsletter #324 Recap Podcast'
permalink: /en/podcast/2024/10/15/
reference: /en/newsletters/2024/10/11/
name: 2024-10-15-recap
slug: 2024-10-15-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Antoine Poinsot to discuss
[Newsletter #324]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-9-21/388468177-44100-2-17b573f3e41c9.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #324 Recap on
Twitter spaces.  Today, we're going to talk about a recently announced Bitcoin
Core set of vulnerabilities before Bitcoin Core 25.0, a btcd consensus bug, an
Optech guide for wallets using Bitcoin Core 28.0 P2P and policy features; we
have a PR Review Club around orphan transactions; and then we have our weekly
segments on Releases and Notable code changes.  I'm Mike Schmidt, contributor at
Optech and Executive Director at Brink, where we fund Bitcoin open-source
developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin stuff.

**Mike Schmidt**: Antoine.

**Antoine Poinsot**: I'm Antoine Poinsot, I work now at Chaincode Labs on
Bitcoin Core development and Bitcoin research.

**Mike Schmidt**: Congratulations on that announcement, Antoine.

**Antoine Poinsot**: Thanks.

_Disclosure of vulnerabilities affecting Bitcoin Core versions before 25.0_

**Mike Schmidt**: If you're following along listening, we have the newsletter
up.  We're going to go in sequential order here, starting with the News section.
First one is titled, "Disclosure of vulnerabilities affecting Bitcoin Core
versions before 25.0".  To maybe put some of this in context, there's been a
series of disclosures in the last couple of months.  We covered in Newsletter
and Podcast #322 Bitcoin Core vulnerabilities before 24.0.1; in Newsletter and
Podcast #314, we covered everything before 22.0; and in #310, we covered Bitcoin
Core vulnerabilities before 0.21.0.  Antoine, you've been involved with the
announcing of some of these historical disclosures over the last few months, so
thanks for joining us on this latest batch affecting versions before 25.0.  In
this set, there were three disclosed.  What order, Antoine, would you like to go
through these?

**Antoine Poinsot**: Sure.  So, last year, at the beginning of the year, there
was a large usage on the network, and it made some issues, some security bugs in
the Bitcoin Core implementation more evident.  So, one of them is with regards
to transaction announcements.  There was a lot of people broadcasting inv
messages to announce transactions on the network.  And it turns out that each
Bitcoin Core node receiving this announcement would not treat them as fast as
they would be received.  So, they would get stalled and they would have been
accumulated on the node.  And then the node would, for privacy reasons, in order
to not -- so, the node's going to relay these announcements, and for privacy
reasons, it sorted these announcements so to not give away the order in which
they were received.  And as they did not get cleared as fast as they were
received, the data structure containing all these announcements grew and grew
and grew, and the sorts took longer and longer and longer to perform.  And so,
we could notice a very high CPU usage on a lot of nodes during this period, and
it would temporarily stall the P2P thread, showing messages between the nodes.

Another one is with regard to block propagation, and this one was triggered by
most likely, as developer 0xB10C's research indicates, some misconfigured or
mis-implemented software from a mining pool not correctly implementing the
protocol.  But it eventually made clear a bug in Bitcoin Core.  And in this bug,
a node would request a block, and so it's with compact blocks.  So, blocks get
announced and a node reconstructs most of the transactions from its mempool, and
then it queries only the transaction listing in its mempool.  And in this case,
when requesting a block, if another peer would send a specific message to the
node trying to reconstruct the block, it would wipe the state of the block
reconstructions, thereby making the node forget about this block.  So, it could
hinder the propagation of blocks.

Finally, and last but not least, there is a remote crash discovered by Niklas
Gögge, which enabled any peer to crash a Bitcoin Core node.  So, reachable nodes
would be more affected because you can directly connect to them, but you could
also crash non-reachable nodes, nodes which connect to you, because, well, they
would connect to you.  And so, yeah, this one is a really high-severity bug
because it's really, "I will knock, knock and crash".  It's basically sending a
couple messages to the node which will make it crash.

And yeah, that's it for this month.

**Mike Schmidt**: For that last vulnerability, what would it take; is there a
monetary cost, or how would someone execute such an attack?

**Antoine Poinsot**: Yeah, that's a good question.  I should have mentioned
that, yes, it does not cost anything to an attacker.  The attacker needs to
perform the attack when a node is trying to reconstruct a compact block, so that
it does not cost anything to the attacker compared, for instance, to another
remote crash that we disclosed the month before, which is about header chains.
We had this crash where someone could craft a very, very long chain of headers
and could crash a node at lethal cost, because you could just reuse the chain
for every single node.  With this crash, you don't even need to crash the chain.
You don't need hashrates, you don't need to invest bitcoins into it, you can
just send a message.

**Mike Schmidt**: Okay, so yeah, and you don't need to be the one to create
these blocks, right?  You could just be relaying the block yourself, and then
when you're relaying to the peer, you send this extra message, which would cause
the node to crash.  Is that right?

**Antoine Poinsot**: That's right.  And you don't even need to be the one being
asked for the reconstruction.  You can just bombard the node asking for it, with
the message that would make it crash until it's in the right state and actually
crash it.

**Mike Schmidt**: And for the DoS vulnerability involving the inv sets, that was
the increased traffic last year, was that around a lot of this inscription,
BRC-20 activity that sort of stress-tested the sort function that ended up being
maybe not that performant and causing these delays; do I have that right?

**Antoine Poinsot**: Yes, exactly.  It happens during this period.  And actually
in reaction to this, some contributors to the Bitcoin Core project started
working on a project called warnet, which is a test network used to reproduce
some stress-testing conditions.  So in the future, we don't need inscription
people anymore to disclose these bugs, we can find them ourselves.

**Mike Schmidt**: Murch, do you want to double-click on any of these a little
bit deeper, or do you think we covered them all?

**Mark Erhardt**: I thought it was really interesting on the CVE-2024-35202, the
remote crash vulnerability, that really the problem was that basically you
initiated the compact block rebuild twice and that was sufficient to make the
node bork.  Yeah, that's just so easy.  So clearly this is a high-severity
issue.  All of these are fixed of course, obviously.  Yeah, and I think it's
kind of funny.  A lot of people are aware of this 7-transactions-per-second
magical number, that for a very long time was thought to be the maximum possible
number of transactions that could be confirmed on the blockchain, and so that we
had this as a magical number in Bitcoin Core as how many transactions we will
relay.  And that essentially limited our outflow of transactions and made all
these announcement queues grow faster, because we were receiving more than 7 per
second, but not sending more than 7 per second, and that caused the mempool to
grow to a point where the search function actually made us slow.

I think it's just really interesting how so many unrelated things can come
together to cause an issue and, well, you won't see it in any of the underlying
functions when you first implement it or anything.  It just really comes to pass
when all of these things are in action in production together.  So, I don't
know.  It's interesting to see how these problems come together.

**Mike Schmidt**: If you're curious, two of the three vulnerabilities that we
just discussed here, we also on our Brink Podcast #6, we had Gloria, Niklas and
0xB10C talk through two out of the three of those, and also one from last month,
so the inventory send queue bug, the crash vulnerability and compact block
relay.  There's some good riffing between those three folks for an hour.  So, if
you're curious about the details, these sort of things are interesting to you,
check out that episode #6 of the Brink podcast.

_CVE-2024-38365 btcd consensus failure_

I think we can move on to the second news item.  The second one is, "Btcd
consensus failure", and there's a CVE attached to this.  Last week, in Podcast
and Newsletter #323, we discussed the sort of pre-disclosure of a btcd
vulnerability, which has since last week been formally disclosed.  So this week,
we can get into some of the details, and fortunately enough we have Antoine on
still, who was one of the original reporters of the bug.  And so, maybe we can
give him a chance to elaborate on the details here.

**Antoine Poinsot**: Yes, so it's a finding from Niklas and I, the same Niklas
that found the crash on Bitcoin Core, that while I was investigating the
consensus cleanup proposal, I looked again into the implementation of the
function in the Bitcoin Script input interpreter, called FindAndDelete.  It's a
notoriously confusing function.  And I just really discovered new subtleties of
its implementation that I hadn't realized the last times I had read the
implementation.  So, yeah, then I got in touch with Niklas, asking him to point
to fuzzer, because Niklas is the fuzzing guy in the Bitcoin Core team, and point
of differential fuzzing between btcd and Bitcoin Core, because there would be
very low probability that it would actually have implemented this right.

Turns out that actually, he couldn't fuzz it for technical reasons,
technicalities.  But then we ended up comparing the two implementations, so one
in Core, from the btcd to the original C++ implementation on the Bitcoin Core
project, which is derived from Satoshi's implementation.  And so, this function
is going to be called when verifying the signature.  So, when a signature is
verified, we are going to reconstruct the hash of the transaction used in the
signature to commit to the transaction.  So, it's called the sighash or the
signature hash.  And this hash commits to the script of the outputs spent by
these transactions.  So for this input, we are taking a signature for the
transaction input, this signature is going to come into a hash and the hash is
going to commit in parts to the transaction, and also to the previous output
script.

For some historical reasons, in legacy scripts, before committing to the script
of the previous output, the scripting interpreter would go through the script
and remove any signature which is exactly equal to the signature being verified.
And I know it's a bit confusing, but yeah, it is just confusing.  And so, if we
go through the whole script and for each data push, it's going to check if this
data push is actually the signature being verified from the idea.  It's
absolutely not necessary, but it was from the idea that the signature could not
sign itself, of course, it makes a hash circle.  And so, that's how it's
implemented in Bitcoin Core.  And btcd actually has a very slightly different
implementation, which is it's going to go through the previous output scripts,
data pushes, and it's going to remove any data push which contains the
signature.  So, it means that you can create a script such as there is a data
push in the script which contains the signature, but not only the signature.
You just push the signature and you add some dummy data at the end or at the
beginning.  In this case, the output script that is going to end up being
committed in the signature hash and in the signature is going to contain this
dummy data, at least for Bitcoin Core, but it's going to be removed for btcd.

Since the output scripts for btcd and the output scripts for Bitcoin Core are
going to differ, the signature hash is going to differ, and therefore the valid
signature for one or the other is going to be invalid for one or the other,
which means that you could create a transaction such as its script would execute
to true for one of the implementations, either Bitcoin Core or btcd, and to
false for the other, making the transaction valid on one of the implementations
and invalid on the other implementation; which in turn, if it's included in a
block, make a block valid on one of the implementations and invalid on the other
one, which is in effect a consensus failure, which is pretty critical, because
obviously it can lead to funds lost, because your node could end up not knowing
about the majority chain because it would reject the chain with -- let's say you
consider the transaction invalid and you are running btcd and an attacker makes
a transaction such as it's valid on Bitcoin Core but invalid on btcd, then your
node is going to reject a valid block.  So, your node is going to reject the
most PoW chain and you're going to end up on a minority chain.  So you're going
to be blind of what happens in the mainchain.  So for instance, if you run
Lightning nodes on top of your Bitcoin nodes, it can cause issues.

But the opposite is even worse.  If the attacker creates a transaction such as
it's valid for btcd but invalid for Bitcoin Core, then if it's included in a
block, your btcd node is going to accept an invalid chain.  So, you could be
scammed by being double-spent, by spending on this minority chain, invalid
chain, or accepting payments in exchange of goods which are not related.  And to
finish on this, it's critical and it was also very simple to exploit, not simple
in finding the bug, but it was at no cost, because it could be exploited using a
standard P2SH transaction which would be relayed through the network.

**Mark Erhardt**: Yeah, I wanted to try to summarize it a little bit.  I'm sorry
for the sound quality.  As you can hear, we're not in our usual recording setup.
So, Antoine went into a lot of the details right now, but I'm just going to try
to give a high-level summary.  So, there was a difference in how btcd and
Bitcoin Core calculated the transaction commitment, so the part that is signed
when you make a Bitcoin transaction, and the difference was in how it treated
data pushes that included the signature.  So, if you had a data push that both
included the signature and some dummy data, one of them would remove the entire
data push, and one of them would only remove the signature.  This leads to you
being able to build a transaction that is either only accepted by btcd or only
accepted by Bitcoin Core, and allows you to split the network.  This was
discovered earlier this year.  It could be exploited with a standard transaction
and is now fixed.

**Mike Schmidt**: This is Bitcoin and clearly someone is going to or has tried
to grief these remaining btcd nodes by doing something like this, maybe not yet.
Are either of you aware of that?  Maybe I should ask 0xB10C, maybe he knows.

**Antoine Poinsot**: Well, as far as I know, nobody tried to exploit it, but
it's trivial and it's even worse than a remote crasher, because for a remote
crasher you need to -- well, because you don't even have a consensus failure in
the first place.  But another aspect of this vulnerability is that it does not
need to connect to each of the nodes that you want to hack, just propagate by
itself through the network, just broadcast once your transaction.  And so it's
very, very easy for an attacker to exploit it, and as far as I know, nobody
exploited it, like nobody exploited Niklas' bugs, despite being a lot of Bitcoin
Core versions affected on the network, because a lot of people don't want to
create a Bitcoin Core node.  So, yeah, it looks like there is maybe less people
in clients, less script keys, let's say, than are anticipated.

**Mike Schmidt**: Well, I guess this would be an opportunity to encourage folks
to run at least that 0.24.2 that had the fix from btcd a few months ago, as well
as anything after Bitcoin Core 25.0 for the fixes we talked about earlier.
Obviously the later the better, because there's likely other bug fixes in
addition to the features in the newer versions of Bitcoin Core.

**Antoine Poinsot**: Yeah, we are going to, in 25.0, since we just released 28
this month, it is now end of life, and we are going to release security
advisories for 25.0 next month.  So, yeah, definitely do upgrade to a maintained
version at least.  And again, I repeat what I tried to share as much as I could.
But when we started this initiative, you are only guaranteed to have all the
security fixes if you run the latest version of Bitcoin Core, because it's very
hard to hide security bug fixes in maintenance versions, you know, 0.1, 0.2
versions, for earlier versions.  Try to run the latest if you can, and if you
can't, if you have trouble upgrading, it would be very good to report it to the
project.

**Mark Erhardt**: Yeah, I also wanted to mention, so we're almost caught up with
the security disclosures and 25.0.  So, the disclosures were affecting versions
before 25.0 up to today, and the disclosures for the 25 branch; so anything
before 26.0 are also still in the pipeline and coming.  Thank you very much,
Antoine.  I think we're going to move on to the guide for wallets.

**Mike Schmidt**: Yeah, that sounds good.  Antoine, thanks for joining us for
these first two News items.  You're free to stay on or if you have other things
to do, we understand.

**Antoine Poinsot**: Thanks for having me.

_Guide for wallets employing Bitcoin Core 28.0_

**Mike Schmidt**: Last News item this week is titled, "Guide for wallets
employing Bitcoin Core 28.0".  We've discussed over the last month or so the new
P2P and mempool policy features in Bitcoin Core 28.0 that was recently released,
to help demystify what those features are, and also how different types of
Bitcoin wallets can use these different P2P and policy features.  Greg Sanders
came up with a guide for wallet developers and we published it as a blogpost on
the Bitcoin Optech website.  The guide covers four features and five use cases
that might use those different features.  The four features are one parent, one
child relay (1P1C); TRUC transactions, 1p1c package RBF, and pay to anchor
(P2A).  So, those are the four different pieces that you can combine in
different ways to facilitate your different use cases, which Greg goes on to
highlight as well.

One use case would be simple bitcoin payments, just your normal vanilla bitcoin
payments, and maybe some fee management around there; coinjoins, the Ark
joinpool protocol; LN, including funding commitment and HTLC (Hash Time Locked
Contract) pre-signed transactions; and a separate call out for the final use
case, which would be within LN, specifically splicing.  So, if you've heard of
this 1p1c, these TRUC transactions, P2As, and you're a developer on a wallet
system or other service provider, take a look at this, because this could be
something that you could utilize in your software.  Murch?

**Mark Erhardt**: Yeah, I think you roughly covered everything that I had to say
here, too.  Just our main goal here is to make people aware that this guide
exists, and if you're interested in getting some information as someone that
will implement these features on a wallet, please take a look.  I think it'll
help you get a good overview.  And, yeah, let us know if there's more to be
discussed here.

**Mike Schmidt**: The guide included some bitcoin-cli-based examples that you
can run through to sort of create different types of transactions and create a
package and see how all of that works on the command line.  There's also a
Replit that is in the works that will announce when that's reviewed and ready,
so you can have a little bit maybe easier way to step through those different
examples and no excuse not to click through some of this.  So, look forward to
that.

_Bitcoin Inquisition 28.0_

Next section from the newsletter, Releases and release candidates.  We have two.
First one, Bitcoin Inquisition 28.0 was released.  As a reminder, Inquisition is
a modified Bitcoin Core implementation designed to be used on the signet test
network, which has CTV (CHECKTEMPLATEVERIFY)d, APO (ANYPREVOUT), and OP_CAT
activated on it for experimental purposes.  And this release of Inquisition just
merely upgrades to Bitcoin Core 28.0 release and applies those same activated
features on that version of Core.  And Murch let me know that I skipped a Review
Club.  Murch, did you want to add anything to Inquisition before we jump back?

**Mark Erhardt**: Well, if you're working on any of those soft forks and you're
looking for a live network to run this on, feel free to install the Inquisition
client on one of your nodes and you'll be able to play around with these soft
forks that have been proposed for a long time.  And, yeah, it would be good to
see a public footprint of people actually trying out stuff.

_Add getorphantxs_

**Mike Schmidt**: Jumping back up to the Bitcoin Core Review Club monthly
segment, this month the PR that was highlighted is titled, "Add getorphantxs".
This is a PR by tdb3 and it adds a new, marked as experimental, RPC named
getorphantxs.  And it simply lists all of a node's orphaned transactions.  So,
as a recap, an orphaned transaction is a Bitcoin transaction whose parent is
unknown to this node.  So the tx, it may be valid, but you can't tell because
you don't have the parent, but the parent may also come in at any moment.  And
these orphan transactions are stored in a data structure called the orphanage,
and you can imagine that this has the potential to be abused.  So, there's
actually a default limit of 100 orphans in the orphanage at one time.  In
addition, there is also a 20-minute timeout.  So, if the orphan is in there for
longer than 20 minutes, it also gets removed.

So, this PR simply lists all of the orphans in that orphanage data structure via
an RPC command.  And there were two examples given in the Review Club writeup
where this might be useful.  It could be useful in Bitcoin Core's functional
tests that checks certain orphan behavior during testing; or potentially, you
could query this RPC and display results in some sort of a dashboard or
visualization tool as well, calculate statistics, if that's something that
you're interested in instrumenting.  Murch?

**Mark Erhardt**: Yeah, so two small additions.  One is, this is a hidden RPC,
so if you're reading the help, it will not pop up there.  This is mostly geared
towards developers that need to look more in detail at orphans.  And why would
developers need to look at orphans right around now?  Well, we have now the new
1p1c propagation, which is not a reliable propagation mechanism, but an
opportunistical mechanism that hopefully works well enough.  And the way that
works, we've discussed this a few times already lately, but I'm just going to
recap.

This is the first way of how to propagate packages in the Bitcoin Network with
Bitcoin Core clients.  You first hand the peer node the child.  The peer node
discovers that it is an orphan for them and that they do not know about the
parent, and will ask back, "Hey, can you give me the parent of this, I don't
have it?"  And then when you hand over the parent, the parent might even be
below the dynamic minimum feerate of the mempool.  But with the child
interpreted as a package, the two are valid and sufficiently attractive to be
included in the mempool; thus, the peer, after having both the parent and child,
and accepting them as a package, has them in their mempool and will again also
forward them to its peers.  And so, this is heavily interesting in the context
of 1p1c.

Oh, and about the RPC.  So, the RPC dumps out the entire orphanage, and if you
are just going for a low verbosity, that might be like 6 kB.  But if you are
dumping the whole transactions and they were all maximum size, it could write up
to 80 MB.  So, that's why it's experimental and hidden and mostly geared towards
people that are doing research and trying to shore up that all of that is
working perfectly.

_BDK 1.0.0-beta.5_

**Mike Schmidt**: Jumping back down to the Releases segment of the newsletter,
we covered Inquisition; next one is BDK.  This is the 1.0.0-beta.5, which we
covered last week in Recap #323 and Newsletter #323.  It includes RBF enabled by
default among other changes.  We had thunderbiscuit on that opined on some of
this last week, so check that out and we'll look forward to the next BDK RC or
maybe full release, we'll see.

_Core Lightning #7494_

Notable code and documentation changes.  This is the part of the show where I
solicit any questions from the audience, so throw something in the thread or
request speaker access.  Core Lightning #7494.  This is a PR titled, "Remember
and update channel_hints across payments".  And this actually builds on and is
closely related to a previous correlating PR that started sharing channel_hints
across payments and plugins.  That PR, the prerequisite PR, noted, "So far, we
were just forgetting all of the inferred information once the payment is done.
However, this information is useful for later payments too, as it allows us to
skip attempts that are unlikely to succeed and essentially continue the
exploration where the previous payments have left off".

The contribution in this PR, therefore, is the time-based relaxation of those
constraints that they've been saving now.  So before, they discarded all of this
information, then they were saving this information, and now there's some
time-based rules around how long and what the durability of that information is.
Oh, go ahead, Murch.

**Mark Erhardt**: Yeah, I'm sorry.  It sounded like you might not get into this,
but now I interrupt.  I was just going to add, so these channel_hints are
basically learnings about paths that were tried.  So, for example, if a channel
didn't have enough capacity -- sorry, not capacity, but the balance was split
such that, yeah, not enough capacity existed in the direction that you wanted to
route through, you would remember not to route through this channel for an
amount this large or larger for the next two hours.  And I think there's sort of
a decay, so you're more likely to try it again the more time has passed.  But
I'm also only gleaning from the overview here.

**Mike Schmidt**: Yeah, I think you got it.  I think there's some sort of linear
decay over two hours.  So, in the example that Murch gave, a channel that maybe
you previously considered unavailable would, over time, over this two-hour
period of time, gradually be restored and become at least available for
consideration.  So, yeah.

_Core Lightning #7539_

Core Lightning #7539.  This adds an RPC command to fetch and return data from
Core Lightning's (CLN's) emergency.recover file.  And this is a file which
contains encrypted data.  And the PR here for pulling this sort of recovery
backup information was, there was an issue on CLN regarding an application
developer or the idea of application developers who wanted to build backup
features for CLN.  So, for example, getting the backup data and creating a
backup in a different location was the example given.  So, this is a simple RPC
command where you can fetch that emergency data.  Murch, it seems like you have
a thought here.  Oh, okay.  I saw a thumbs down.  I thought you didn't like that
feature.

**Mark Erhardt**: Sorry, I just fat-fingered it!  I was trying to give you a
thumbs up to say that I don't have anything to add.

_LDK #3179_

**Mike Schmidt**: Got it!  LDK #3179, this is part of LDK's support of BLIP32,
which specifies the protocol for requesting a DNSSEC proof of DNS text records
for a domain name.  Now, why would you want to do that?  You want to verify the
cryptographic signatures of DNS records using an onion message.  Okay, why would
you want to do that?  Well, this is part of the LDK support for the DNS payment
instructions that specifies DNS-based human readable bitcoin payment
instructions, like sending a payment to bob@xyz.com.  So, if you don't have the
ability to look up a DNS record, you can actually use onion messages to contact
one of your peers that advertises that they provide a DNS resolution service.
So, this BLIP32 specifies the protocol for requesting those proofs so that you
can essentially prove that the information that you're getting from the
bob@xyz.com lookup is accurate.

_LND #8960_

LND #8960, this is part 5 of 5 of LND's project to support custom channels.  The
custom channel in question is an experimental channel type.  It's similar to
what we've discussed when we talked about simple taproot channels, but with
additional feature support for LND's taproot assets protocol.  And I think we've
covered all the parts, but specifically parts 3 and 4 of this project we covered
in Newsletter #322.  So, if you're curious about the plumbing around LND's
taproot asset support, check out those PRs in our discussion of them as well.

_Libsecp256k1 #1479_

Libsecp256k1 #1479, which adds a MuSig module that implements MuSig2
multisignatures as specified in BIP327.  This is an identical API and uses much
of the code from Blockstream's libsecp256k1-zkp repository with two changes, the
main change being the removal of support for adaptor signatures.  Murch, did you
have something to add here?

**Mark Erhardt**: Yeah, so this has been in the works for ten months, and it's
really cool that this is now merged and available in libsecp.  I assume that
there's going to be another release of libsecp soon.  And my understanding is
that a bunch of other projects use this library for their cryptography around
bitcoin transactions.  So, maybe this will enable other projects to further
their MuSig2 support soon.  And the additional benefits here is that some of the
work on silent payments in Bitcoin Core had moved to the libsecp library,
because it really made sense for the cryptography parts to be part of the
library, but that had been slow going, among other things because the main
contributors to libsecp had been focused on MuSig2.  So, I hope that the silent
payments crypto work will go a little quicker and will hopefully unblock more
work on silent payments and Bitcoin Core.

_Rust Bitcoin #2945_

**Mike Schmidt**: Rust Bitcoin #2945 adds support for the testnet4 framework in
Rust Bitcoin, and I really tried to find something more interesting to leverage
on, but I didn't.  Murch, did you see anything interesting?

**Mark Erhardt**: I did not, but I mean testnet4, it's a testnet now, right?

_BIPs #1674_

**Mike Schmidt**: And last PR, BIPs #1674, which reverts the changes to the
BIP85 spec that we spoke about and covered last week in Newsletter and Podcast
#323.  There was a little bit of probably justified drama around this.  Murch, I
know you've been running around and traveling.  I don't know how much you got a
chance to catch up on this as the BIPs maintainer.

**Mark Erhardt**: Yeah, I was traveling and then I was sick, unfortunately.  But
so, this story starts a few months ago.  Somebody had mentioned that they tried
to get the reference implementation of BIP85 to work and had trouble getting it
to work.  And then, they implemented their own and wanted to add that to the BIP
and they couldn't get in touch with the BIP author.  So, BIP2, the BIP that
specifies the BIP process, very self-referentially, mentions that if one of the
BIP authors falls off the net, we eventually can nominate someone else as the
new BIP champion.  And so, this contributor wanted to become the new author and
fix up a few unclarities and issues in BIP85.  I mentioned that they should
probably announce this to the mailing list and that I was not familiar enough
with the BIP myself to see whether this was breaking changes, or whatnot.  And
so, they wrote an email to the mailing list.  We also tried to contact the
original author again and we heard nothing back from nobody.

So, after four months, eventually this got merged when it looked ready.  And
then, of course, people noticed that something was happening to BIP85 and
notified us that it actually had been implemented by multiple other projects,
and that it should probably be final and there certainly shouldn't be any
breaking changes to this BIP that had been labeled as draft.  So, the changes
were reverted and now some of the changes are being incorporated in, like, the
non-breaking parts and clarifications, and maybe also the change in champion
because we still haven't heard from the original author.

So, maybe it is good here to mention, the BIP process does assume that
contributors are monitoring the Bitcoin-Developer mailing list.  That is one of
the other things that the BIP process depends on.  Now I know the old mailing
list was shut down and there was a migration, so maybe many people are not on
the new Bitcoin-Developer mailing list yet, but especially if you have a vested
interest in some of the BIPs, I would encourage you to join that mailing list or
subscribe to it, I should say.  And I hope next time if someone posts about a
BIP and how they intend to maybe make some changes to it, that if that BIP is
already implemented by you and you do not want that to happen, or you want to
inform us that it is already more widely implemented and adopted than might be
perceived from the repository itself, that you do speak up there.

Also, maybe generally, there's been a lot of noise on the Bitcoin-Developer
mailing list, but I assume with the BIPs process working a little better again
after pace picked up in the processing of BIPs, that we will get more emails to
the Bitcoin-Developer mailing list pertaining to BIPs again.  So, again, I think
it might be of interest to -- I mean, you don't have to look at it every day and
you certainly don't have to read every single email, but you might want to at
least keep track of the subject lines of the emails.  So, this one was very
clearly labeled as BIP85, so maybe in the future, hopefully, this sort of stuff
gets answers more quickly, and maybe we can also do a better job of updating
existing BIPs that have since been implemented, to more appropriate status than
being set to draft.  So, if you're aware of other BIPs that really should have
been moved along in the workflow, please feel free to open an issue on the BIPs
repository to indicate such.

**Mike Schmidt**: Yeah, really great context and framing of that discussion.
Thanks for that color, Murch.  I don't see any comments or questions, so I think
we can wrap up.  We can thank Antoine for joining us to talk about those News
items.  Thank you all for listening, and thank you to my co-host, Murch.  Hear
you next week.

**Mark Erhardt**: Yeah, thanks.  Yeah, hear you next week.

{% include references.md %}
