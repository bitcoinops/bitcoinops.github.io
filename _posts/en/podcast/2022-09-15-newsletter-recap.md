---
title: 'Bitcoin Optech Newsletter #217 Recap Podcast'
permalink: /en/podcast/2022/09/15/
reference: /en/newsletters/2022/09/14/
name: 2022-09-15-recap
slug: 2022-09-15-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Larry Ruane to discuss [Newsletter #217]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-8-27/348751916-44100-2-aecf21a0ed581.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Optech Newsletter #217 Recap.  So, quick
introductions.  Mike Schmidt, I'm a contributor at Optech and also Executive
Director of Brink, a not-for-profit funding Bitcoin open-source developers.
Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs.  I do a bunch of
Bitcoin stuff around Optech, Bitcoin Stack Exchange, Bitcoin Core, especially
wallets and coin selection, and I co-host BitDevs New York.

**Mike Schmidt**: Excellent.  Larry, do you want to give folks a bit of
background of how you got into Bitcoin development, what you focus on, what you
were doing beforehand?

**Larry Ruane**: Sure.  Yeah, let's see, I'm working on a grant from Brink
full-time since June, I think it was, this year.  And before that, I was
part-time just one day a week for I think the previous year or so, and I worked
on the Zcash project before that, which is an altcoin.  That's a code fork of
Bitcoin.  And I started there in 2018.  So, I've been kind of around the
cryptocurrency area for about four years, I guess it's been, but really only
focused on Bitcoin for the last year, year-and-a-half.  And before that, I
worked on data storage mainly, so network storage products, commercial products,
not open source.  So, I still have a lot to learn, I'm very new to this, so
don't assume I know anything!

**Mike Schmidt**: Well, thanks for joining us today, Larry.  There were no news
items, newsworthy items for this week's newsletter, but Murch, I'll somewhat put
you on the spot as you had an interesting news-related item, in terms of trends
in outputs over the last month or two.  Do you want to comment on that tweet
about output growths and counts per day over time?

**Mark Erhardt**: I mean, I've been just tracking how the UTXO set composition
and also how the outputs being created and spent have been changing over the
years.  I think my interest there started around the time when segwit activated.
And I've been seeing that P2PKH has been finally really receding hard since last
year in June.  Blockchain.com activated native segwit by default for all of
their wallets, and P2PKH is the legacy format, of course, and it's down to
something like 22% of all inputs and outputs created.  And we're currently still
seeing that this is sort of pretty stable now, that the legacy outputs are still
one-fifth of all outputs being used on the network, but more of the wrapped
segwit outputs are moving towards native segwit, that's what we're seeing.  And
very, very, slowly, P2TR is creeping up.  It almost doubled in the past few
months, but it's still tiny, less than 1% of all UTXOs being created.

**Mike Schmidt**: I just shared in this Twitter Spaces one of your tweets that I
was referencing, in which folks can take a look at those graphs in a bit more
detail to see what you're talking about.  But I thought that was informative and
while not necessarily Optech newsletter worthy, I think it is interesting news.
So, thanks for posting that.

**Mark Erhardt**: Thanks for putting me on the spot!

**Mike Schmidt**: Absolutely!

**Larry Ruane**: Hey, Murch, would you mind just briefly letting us know how do
you acquire these statistics?  What sort of tools do you use, in case other
people wanted to do similar things?

**Mark Erhardt**: So, I'm just totally riffing off of 0xB10C's work here.  This
is transactionfee.info that I'm posting from.  I sometimes also use block
explorers or other statistic websites to get specific numbers.  Blockchair.com,
for example, is extremely useful in this regard because you can sort a lot of
their data by different characteristics.  Yeah, for example, earlier today I
found that they have a number for the total outputs ever created, which I
couldn't find anywhere else.

**Larry Ruane**: Cool, thanks.

**Mike Schmidt**: Well, we can jump into the monthly segment that we showcase on
the newsletter, which this particular week is the Bitcoin Core PR Review Club.
And I thought it would be nice to have Larry in, since he's been the host of
several of these Review Club meetings and a participant.  And at least everyone
that I happen to attend, he seems to be there participating, which is great.
So, Larry, I think it would make sense if you -- we've covered the PR Review
Club a bit in the past, but maybe give folks your take on the PR Review Club,
what it is, and then we can jump into this particular meeting summary of the PR
and questions.

**Larry Ruane**: Okay, sure.  The Optech newsletter, as Mike just mentioned, has
a section for the Review Club once a month, which is on it seems to be the
second Wednesday of every month.  So, that was just this past Wednesday.  And we
have Review Club every week, and there is a link to, let's see if we have a link
somewhere for that.  Yeah, in the Optech newsletter, there's a link to the
Review Club main page, and that has a listing of all the previous Review Clubs
we've done, all the weekly Review Clubs.  And this is totally open to anybody,
there's no sign up or anything like that.  It's an IRC meeting for one hour, and
so it's actually nice because it's not a video call or anything like that, so
it's IRC.  I think people are maybe a little more on the shyer side, like a lot
of us geeks, it's easier to jump in and participate, I think.  So, it might
sound like a bad thing that it's an IRC meeting, but I think it's actually a
good thing.

So, what most people do is they review the PR for that session.  They review it
or study the code and the notes for that session, starting a couple days in
advance, and then do a little bit of preparation.  And then we have the meeting,
and it's open to everybody, and it's very welcoming.  So, people who are new can
ask, there's no such thing as dumb questions.

**Mike Schmidt**: Yeah, I'd like to say that the PR Review Club is a
lurker-friendly way to contribute and learn.

**Mark Erhardt**: I think what's nice about this is, you usually have a host
that's pretty familiar with the code, and then by having a look at it before,
you're familiar enough to follow along the commentary of other people and you
sort of get the feel of many people just familiarizing themselves with the code
and chiming in.  So, it's sort of like getting a tour of a PR and learning about
the thought processes other people have when reviewing or writing the PR.  So,
it's a good way of onboarding onto Bitcoin development more.

_Reduce bandwidth during initial headers sync when a block is found_

**Mike Schmidt**: Now, I'm a bit torn here because we have Larry who summarized
the Review Club meeting, and then we have Murch who's conversed with Suhas,
who's the PR author.  Murch, do you want to do a quick summary of your takeaway
from the PR, and then we can jump into Larry's details, or vice versa?

**Mark Erhardt**: I don't know, Larry, do you want to summarize?

**Larry Ruane**: Yes, I could do that.  So, the particular PR is a performance
improvement.  Bitcoin Core is really interesting in that a lot of instances,
there's behavior on the P2P network that is correct, there's absolutely nothing
that functionally is wrong with what it's doing, but it's not really efficient.
And so, when you have, like say in this case, it's redundant messages that are
being sent over the P2P network, that's okay.  A node that receives a message,
in this case a headers message, or actually like a list of headers, it can deal
with redundant headers, "Okay, I've already seen this header.  I can just ignore
it and discard it".  But it does cause a greater demand for network resources
for that node and for the network in general.  And these are a little tricky to
find because everything's working fine, the node's running, it does sync.

So, this particular PR involves the Initial Block Download (IBD).  And so, these
are a little tricky because everything's working okay, but it's just not as
efficient as it could be.  So, how people even find these things is a little bit
of a mystery, to me at least.  I think you have to do things like turning on
Wireshark or just the logging, the P2P logging, and that's really easy to do.
You could just start the node with -debug=p2p, and you'll get a whole bunch of
stuff in the log and you can pour through that and see things like this, where
we're getting redundant header messages.

So, real briefly, what happens is that when a node starts up, and let's say it
doesn't know anything so it's an IBD and actually, every time a node restarts,
it's always initially in IBD.  Even if you shut it down two minutes ago and it
was completely synced with the tip, you restart the node, it's an IBD initially,
and it will leave that state only when your best chain is close to within 24
hours of the timestamp on the best block that you know about, is within 24 hours
of the current time of your node's idea of the current time, and that block has
the minimum chain work.  There's this concept of a minimum chain work that's
interesting.  It's a hard-coded value in Bitcoin Core, and it differs for each
network, in other words, testnet, signet, mainnet, they all have their own
minimum chain work.

Some people think it's like a checkpoint, but it's really not because that
minimum chain work doesn't say, "Okay, this particular block hash must be in our
best chain".  But instead it just says, "We know it's kind of a social consensus
type of thing.  We know that the best chain has at least this much work and work
never goes down, every block adds to the total work".  So we can say, "Well,
then we know that the best chain has to have at least this minimum amount of
work".  So anyway, when a node is first, let's say it doesn't know anything and
it's just synchronizing with its peers knowing nothing at all, then it chooses a
random peer.  So, at first it connects to a bunch of peers and then it chooses
more or less a random peer that it will get headers from.  And by the way, all
this, this headers-first sync, is covered; there's a great podcast if you're
interested in this area and not familiar with it, the Chaincode podcast, their
very first episode, which was I think in January of 2020, that they had a guest
on, Pieter Wuille, and Pieter, he implemented headers-first download.  So,
that's a really good one to check out if you're interested in this.

But what Bitcoin Core does, it will first request headers from one peer and then
only after all the headers are downloaded to within the current minimum chain
work and then timestamp within one day, then it will start downloading blocks.
So, what this PR is fixing is a problem where, when this process is occurring
and you're just downloading headers from a single peer, one of your other peers,
or usually many of your other peers, they receive a new block, they learn about
a new block and this is way at the tip, like it's happening right now.  And then
it will inventory that, that's the way the peers announce to other peers, "Oh, I
know about this new block" and actually they send a list of block hash; it could
be a list or it could be one block hashes.

So now, the node that's doing the IBD, who is just getting headers from one
single peer, will start actually requesting headers from all these peers in
parallel, and they're redundant too, so that's a lot of extra bandwidth that's
happening during this first phase, where you're just downloading headers.  And
this is all before you start downloading actual blocks.  So, this first phase of
downloading headers, it's fairly quick.  It usually only takes maybe in the
order of ten minutes or so.  But if a new block occurs during that time, then it
was noticed that there's all these redundant getheaders from all the peers.  And
so what this PR does, really briefly in a nutshell, is it will download headers
from one of these peers that inventoried us, that sent us this inventory
message, but only one of them instead of all eight or ten or however many peers
you have.  So now, it will download headers from this one additional peer that's
kind of the inventory, and also we continue with the initial peer that's like
our primary getheaders peer, so the one we picked initially.

So, now we have two, so there's still a bit of redundancy.  But so the thing is,
that actually has a good side to it too, because if the one that you happen to
choose as your initial headers peer is an attacker and is sending you a fake
chain of headers, then it's good to have other peers that you can kind of use as
a second source of truth, or whatever, but we don't need to have all the other
peers.  So, we'll have one more peer.  And the reason we pick a peer that's sent
us this inventory is because, "Okay, this is a peer that's willing to send us an
inventory, and so it's probably a pretty responsive peer, it's probably a fairly
good peer.  So, yeah, we'll use that peer to get more headers".  And our headers
are still way back from 2009, 2010, near the beginning of the chain, or
sometime, and could be a long time ago.

So, yeah, that's basically in a nutshell what this does, is that we don't end up
requesting headers from all of the peers.  And by the way, every time we get
this headers message or the list of headers from a peer, then that triggers us
to do a subsequent getheaders to that same peer.  So, that's why it ends up
being this kind of a multi-threaded, I mean not in the sense of Linux threads,
but conceptually multi-threaded to all the peers.  We do getheaders, and then we
receive the headers, and then we turn around and do another getheaders, and so
we end up getting all these redundant headers.  But now it's reduced to just
having maybe two, we get two copies of each header, which isn't so bad.

**Mark Erhardt**: So, this is an improvement of how we sync just the headers
when we're catching up to the chain tip, and I want to summarize a little bit
what you said.  So, headers sync got introduced in 0.12, I think, so many years
ago, five years ago.  And the idea there was, before that, we would get all the
blocks basically in whatever order they got sent to us from our peers.  We would
request a bunch of them from different peers, and then we would have to wait
because if they arrived out of order, we wouldn't know how they fit together or
whether they're actually a good chain.  And so we sometimes would get stuck on
missing a header before we could continue to add them all together.

By getting just the chain of headers, which already are linked, we sort of have
a map of how everything fits together, and we can much more easily process block
data, or at least keep it in storage in parallel.  And here, the idea was always
when headers sync got implemented, that we first just get all the headers from
one peer.  We call that the sync peer, basically.  And we sort of designate that
one peer, the first node that we ever connect to, "Hey, you're going to tell me
about the best chain".

But I want to get a little more into that point of what if that first peer we
connect to is actually not helpful.  We actually time out.  We give them 15
minutes plus one millisecond for every block we expect to download, which turns
out to be roughly 27 minutes right now.  And if they don't give us the full
header chain by then, we disconnect them and go to another peer.  And this issue
that is fixed in #25720 that Larry described just now is, if a new block gets
announced during the time that we're doing the headers sync, we respond to every
block announcement with getheaders.  And if we're right at the start of it,
we'll download 70 MB of header from eight peers maybe instead of just that
single peer.  And the fix is, the first other node that announces a new block to
us also gets added and we do a getheader from them, but we don't add every
single node that announces a new header to us.  All right, I think that sort of
summarizes up what Larry said.

**Mike Schmidt**: Well, excellent.  Thank you, Murch and Larry, for providing a
high-level overview there.  Larry, I think it might make sense if you pick out a
couple of the questions here that you think are most interesting.  I know you
sort of went through the overview, but are there any of these questions from the
PR Review Club that you think would be, you know, we don't need to ask it, but
maybe ask and answer it yourself?

**Larry Ruane**: Sure, let's see.  The first question is interesting, "Why do
nodes (mostly) receive inv block announcements while they are doing initial
headers sync, even though they indicated preference for headers announcements?"
So, there was an earlier BIP that's already been implemented, #130, where a node
can say -- so, it used to be that block announcements were only by inventory,
the inv message, but now there's also a headers announcement.  Maybe, Murch, do
you know the history of that?  I'm not really familiar with when that change
happened.

**Mark Erhardt**: I think that's related to the introduction of headers sync.
So, before headers sync, a node wouldn't be able to parse the header message or
wouldn't know what to do with that.  And so you basically are still conservative
and assume that the other node might be more than five years old, and you only
give them inventory messages which are known to be to any node.  And then, only
after a node announces a block to yourself with a header message, you know, "Oh,
they do speak header messages, well then I'll give them header messages",
because the headers are only 80 bytes, and they're basically a similar size as
the inventory messages in the first place, so we can provide more information by
giving the full header than just the hash.  I think that's sort of roughly it.

**Larry Ruane**: Right, so then the answer is, you can see in the Optech
Newsletter, "A node will not announce a new block to a peer using a headers
message if the peer has not previously sent a header to which the new header
connects to", so that the peer will know that it will be useful to us.  And
syncing notes don't send, they're still syncing, so they don't try and send
headers to other peers to help them out yet, not until they're fully synced.
So, hope that makes sense.

**Mike Schmidt**: One question that I thought from the Review Club that was
interesting was just the last one here about the alternative approach.  Can you
comment on that, the alternative approach to this PR that's mentioned?

**Larry Ruane**: Okay.

**Mark Erhardt**: I think that was the thing about the timeout.

**Larry Ruane: **Yeah.

**Mark Erhardt**: So, we get a block roughly every ten minutes, right?  That's
the expected interval between blocks.  So, even if the block headers sync only
takes, I don't know, 5 to 15 minutes, it's not that unlikely that somebody will
announce new blocks to us.  And the behavior as it is now after the PR will
still allow for redundant data because we will add a second peer and also ask
it, with getheaders, to give us their whole header chain.  So, we're strictly
still downloading redundant data which we could further minimize.

One idea of how we could do that is we use that timeout that we already have in
which we expect the headers sync to be finished, and if it hasn't happened by
then, only then we get headers from somebody else.  Or we could even just,
during the headers sync, switch over to a different sync peer.  But managing
that is more complicated, and there might be a benefit of getting the header
chain from two nodes, because if one of them is slow or just on a wrong chain or
malicious, then getting the header chain from a second node will just catch us
up more quickly.

**Mike Schmidt**: I think we've covered this Review Club fairly well.  Larry,
any final points on this do you think that we should cover before moving on to
releases and code changes?

**Larry Ruane**: No, I think that's about it, covers it.

**Mike Schmidt**: Okay, great.  Yeah, Larry, I hope you can stick around for
when we go through the Bitcoin Core PRs later as well, and you might have some
input on that.

**Larry Ruane**: Sure.

_LDK 0.0.111_

**Mike Schmidt**: Great.  Well, there is just one release that we noted this
week, which was the LDK 0.0.111 release, and for the folks not familiar, LDK,
Lightning Dev Kit, used to be called, or maybe is still called on the repo,
Rust-Lightning.  And that release adds support for creating, receiving, and
relaying onion messages.  There's been a flurry of these onion message PRs and
releases recently in the Lightning world.  Just briefly, normally Lightning
nodes are routing value, in the form of Hash Time Locked Contracts (HTLCs), but
there's also an opportunity to route messages, and that's what onion messages
does, is it lets you route data as opposed to just HTLC payment information.
And so this is LDK's support for not only relaying those, but also creating and
receiving those.  And there's some additional features in there if you look at
the release notes.

_Bitcoin Core #25614_

All right, jumping into Notable code and doc changes, there's Bitcoin Core
#25614, which builds on another Bitcoin Core PR, which allows the ability to add
in specific trace severity levels to specific categories or areas of the
codebase.  So, if you're a node operator, you'll notice, especially if you have
issues, that there is a log file in which a bunch of different information is
thrown.  And you can change some aspects of what shows up in that node's log
messages.  For example, you could say, "I only want warnings or error messages",
or, "I want everything", "I want informational type messages or trace type
messages".  But there, until recently, wasn't a way to say, "I want more log
detail from this area of the codebase or what the node is doing, and I want less
log level from these other areas".

So, this PR and the series of PRs around it allow you to say, "Hey, I want to
know more information about what's going on with the mempool, but I don't
necessarily want to hear all of the different trace messages that may be
associated with other parts of the codebase, because I'm a developer and I'm
troubleshooting something with the mempool, so I don't need to know about all
the P2P stuff, for example.  And so this gives you more fine-grained control
over those log messages that you're seeing either as a node operator or as a
developer troubleshooting things.  Murch?

**Mark Erhardt**: Yeah, I think it's slightly different.  I think that we
already had categories, so you could turn on more logging for, say, mempool or
for P2P, but we didn't have fine-grained control.  We would either get it all or
none of it, so you could turn it on for certain areas already.  With this new
PR, we're moving towards being able to get more fine-grained severity level in
each area.  So, the general idea of being able to choose more explicitly what
sort of log messaging you're interested in, I think you portrayed accurately,
but it's sort of the other part of it.

**Mike Schmidt**: Yeah, okay, so the focus is on the severity level per category
and not necessarily the categories themselves being new.

**Mark Erhardt**: Yeah, I think the categories were there already.

**Mike Schmidt**: Okay.  Larry, as a somebody who reviews PRs and does some
debugging, testing, troubleshooting, do you welcome this change?  Do you use
this sort of filtering yourself?  Are you excited about this; are you familiar
with this?  Or, how do you do your debugging?

**Larry Ruane**: Yeah, I think this is a really useful change.  I haven't used
it yet, but I'm looking forward to using it.  I do really take advantage of the
logging system a lot, very often.  And by the way, if you just say -debug, that
turns on everything.  And that's what the functional tests do, by the way.  So,
if you run a functional test, one of the Python tests, then you can go and look
in the temp directory that it creates.  If you, say, run a functional test with
a --no-cleanup, because I do this quite a bit, then when the test is finished
running, you can actually go look in the temp directory, which there's an
indication of where exactly that is when you run the test.  Then you can go look
in there, and even if there may be multiple nodes, and within each have their
own subdirectory, their data directory, and then inside of those, there's a
debug.log, which will have a ton of stuff in it that's really useful for
learning exactly what that test did and what happened inside of the bitcoinds
that occurred when you ran that test.

_Bitcoin Core #25768_

**Mike Schmidt**: Thanks, Larry.  The next PR here is Bitcoin Core #25768.  And
while we have a wallet expert on, I'll take the pedestrian summary here first,
which is we've talked about the reasons in previous Spaces that a node or a
wallet would need to rebroadcast its unconfirmed transactions, and it seems that
there was a bug in which the logic that did the transaction rebroadcasting
received those list of transactions in somewhat random order.  And due to that,
you could actually end up with a child transaction that is unconfirmed at the
top of the list with the parent unconfirmed transaction later in the list, and
the logic of that rebroadcasting would be such that it basically did not
rebroadcast that child transaction since it wasn't aware of the parent
transaction with respect to this rebroadcasting logic.  Murch, tear it up.

**Mark Erhardt**: Yeah, no, that's pretty much it.  From what I understand, the
transactions were picked from an unordered map there, and that basically gave
them a random order.  And this meant that when transactions were supposed to get
broadcast, the receiving node might not have received the parent yet.  I think
it's at the receiver's end that the transaction doesn't get added to the mempool
then.  And what this PR does now is it basically thinks about, "Hey, have I sent
all of the parent transactions for this transaction before announcing a child
transaction?" by checking the order of the transactions in which it will
broadcast against the hierarchical pedigree of that transaction.  I think that
it should still get added to the orphan pool if we get a transaction whose
parent we don't know about, and then when we see the parent transaction, we
would put it into our mempool, but I'm not 100% sure about that.

**Mike Schmidt**: It seems like from the body of the comments of this PR, that
this wasn't found via a test, but that a test was added as a result of this bug
being discovered, so that something similar doesn't happen with regards to this
in the future.  It would have been great to have caught that in a test, I guess.

**Mark Erhardt**: I guess it would also sort of go away when we get package
relay, because at that point we would sort of approach transactions who have
relatives in the mempool more comprehensively in the first place.  If we want to
broadcast a child transaction, we would look up its parents and see if all of
those would get added to the mempool by themselves, and if not, broadcast them
as packages.  So, I don't know how big of an issue in the real world this was,
and whether transactions didn't get propagated much, or something like that.  I
think it's more about having an accurate picture of the mempool on all nodes
than transactions not getting to the miners.

**Larry Ruane**: And by the way, this one, #25768, was also covered in a Review
Club, so you can look it up there if you want more information on that too.

**Mike Schmidt**: Oh, excellent.

**Mark Erhardt**: Then you might have more insights than am I correctly
assessing that with the orphan pool and stuff like that, if you were at the
Review Club?

**Larry Ruane**: Yes, you described exactly what my understanding is.

_Bitcoin Core #19602_

**Mike Schmidt**: Great.  Next PR is another Bitcoin Core one, #19602.  It adds
a new RPC call, called migratewallet.  And so RPC, for listeners, is a way that
you can interact with your Bitcoin node and have it do certain things, whether
that's as simple as generate an address for you, or in this case, migrate your
entire wallet from a legacy wallet to a descriptor-based wallet.  So, this has
apparently been in the works for a while, and it's finally merged.  Murch, do
you want to jump into the distinction between legacy wallets and descriptor
wallets, and then why would I want to migrate my legacy wallet into a descriptor
wallet?

**Mark Erhardt**: Sure.  So, RPC stands for Remote Procedure Call and it's
basically our way to interact with the Bitcoin node from the command line
interface (CLI).  And the very first wallets were just a conglomerate of keys.
You would just keep 1,000 keys, or I think even only 100 keys in backlog, and
then you'd have to unlock your wallet every time you create new keys so you
could receive.  But if the pool of unused keys got used up, you wouldn't be able
to receive to new addresses anymore and you'd have to unlock again to generate
more.  And that was also bad for backups, because if you used wallets for a long
time, you would have to create new backups in order to keep track of your new
keys.

So, at some point, those got replaced by Hierarchical Deterministic (HD)
wallets, BIP32, which instead of having each key be independent, it made keys
derived from each other, so you would have one main key and all the other keys
were just descendants of that key.  So, if you had a backup of the first main
key, you could reconstitute all the later keys, and even if you had a very old
wallet backup, you would not lose funds, but only maybe your comments that you
added to certain receives and addresses that you had added otherwise.  And now
with, I think it was 0.21, we introduced descriptors as an experimental feature,
and then in 22.0 we properly added it.  In 23.0, it became the standard with how
we create new wallets.  So, if you install the current Bitcoin Core, you will
have a descriptive wallet already.

The big advantage of descriptive wallets is that other than extended public keys
(xpubs), which is the main thing of the HD wallets, you also store the exact
derivation path.  In an HD wallet, the xpub doesn't necessarily have the
information of what the derivation path was.  And so for recoveries, you'd often
have to try different paths, depending if you don't know what wallet it was
created for, because different wallets all use the same xpub standard, but
different derivation paths.  And with descriptors, you explicitly store things
like, what was the derivation path?  And you can even have more complex scripts.
So for example, people are working on miniscript descriptors where you basically
can make a custom script that gets derived for many subkeys from there on.

So, with migratewallet, this new RPC that gets added, you can turn these very
old legacy wallets and also these xpub wallets into descriptor wallets, and it
will just create descriptors for all the relevant derivation paths and also for
all the single keys that were there present before.

**Larry Ruane**: This one's also the subject of a PR Review Club.

**Mike Schmidt**: Look at that.  You guys have good coverage.  Larry, anything
else to add based on the PR Review Club discussion around this PR?

**Larry Ruane**: Nope, it was a little while ago, not that I can remember.

_Eclair #2406_

**Mike Schmidt**: Okay, no worries, we can move on.  There's a couple of Eclair
PRs in the newsletter.  The first one is #2406, which adds an option for when
you're doing dual funding, to require that the channel open transactions only
include confirmed inputs, and this mitigates a potential attack where this
unconfirmed input could potentially delay a channel opening.  And actually in
the PR, the delay of channel opening was mentioned in our newsletter summary.  I
also saw that in the PR there's, and maybe this is different sides of the same
coin, but the potential for having to pay for the fees of that unconfirmed input
in the channel open transaction as well.  Murch, I was curious as to are those
related concerns, the delaying of the channel opening and also paying for that,
the confirmation of that unconfirmed input?

**Mark Erhardt**: Yes, so you don't want a transaction to stick around forever
before it gets confirmed, especially if you want that channel to open quickly.
And I think that Eclair at some point introduced basically automatic bumping.
If a parent transaction has a lower feerate, you would add more fees to make the
new channel open transaction and the parent as a package have an attractive
feerate to be included in a block.  And now if you do dual funding, both parties
will contribute a UTXO in order to constitute the channel, and you essentially
give the counterparty the option to use this channel opening to bump a really
large, low-fee transaction, and essentially ask you to chip in on bumping their
parent transaction.  So, I guess this feature would say like, "Hey, I'm happy to
open a channel that has balances on both sides, but I don't want to pay for your
transaction bumping".  So, I think that's the context here.

**Mike Schmidt**: Murch, you mentioned that Eclair had this automatic fee
bumping, or has this automatic fee bumping feature.  So, it's automatically
doing a CPFP bump to get that package of transactions confirmed then?

**Mark Erhardt**: That was my suspicion, I don't know for sure.  But the idea is
definitely that.  Actually, I've been working on a similar PR for Bitcoin Core
for a while, which I hope gets done soon.  But the idea is, if you are spending
an unconfirmed input, if you don't think about the pedigree of the UTXO and see
what unconfirmed parent or ancestor transactions in general exist, you might
underestimate the fee rate that you're sending your transaction at, because if
you create a new transaction and let's say you're trying to give it 20
sats/vbyte (sat/vB), but there's a parent transaction that only paid 1 sat/vB.
If you then build the new transaction as though it didn't have any dependencies,
it will be hampered by the parent transaction because the parent has to be
confirmed in order for the child to get included in a block.  And you'd create a
CPFP situation where you weren't actually calculating with the extra cost of
reaching that target fee rate of 20 sats/vB.

So, this is currently, I guess, a bug or a missing feature in Bitcoin Core.  If
you spend unconfirmed inputs, it will not properly assess the feerate to reach
your target feerate, but it'll just give the new transaction the feerate that
you tell it, rather than reaching the effective feerate for the whole package.
And I know that this has been an issue for Lightning Service Providers (LSPs),
and yeah, in that context the PR makes sense to me.

**Mike Schmidt**: Okay, yeah.  In quick acronym definition, CPFP, Child Pays For
Parent, is a way to increase the effective feerate of a group of transactions by
increasing the feerate of the child transaction so that an underpaying parent,
essentially you are bribing the minor to take that lower feerate of the parent
transaction in order to get the higher feerate of that child transaction.

_Eclair #2190_

The next PR here is also another Eclair one, and this has some applicability to
onion data again.  So apparently, the original onion format was fixed in length,
and there is a change to the BOLTs specification for these onion messages to
allow for variable-length onion messages.  Eclair is simply adopting this
variable-length format which was, I guess, added to the spec years ago.  Just
now recently, Core Lightning (CLN), I guess a few months ago, implemented this
and now Eclair is implementing this variable-length format.  I don't know too
much about that spec other than it just seems like this is a more efficient way
to do the onion messages versus having a fixed-length format.  Murch, can you
comment on that?

**Mark Erhardt**: Yeah.  Before that, in the original spec, each onion layer had
a fixed length and it meant that there could be exactly 20 hops in an onion
route, and when you forward it to the next peer, you would always backfill the
data again up to that length so that the next hops cannot tell how many hops
there might be after them, right?  And a while back, they introduced this new
format.  I think it's been a couple years already, Type-Length-Value (TLV),
which allows you to basically have any sort of custom data in the onion by
specifying what type of data it is, how many bytes, and what the value is you
want to write.  And this has been adopted by all the implementations for a
while, but the old original spec was still supported for backwards
compatibility.

Now, since almost all but five nodes on the whole LN have support for the new
TLV format, all the implementations are removing support for the old one;
basically saying, "Okay, we had that and we don't need it anymore.  We're only
using the new TLV format and removing the (Inaudible 46:48).

_Rust Bitcoin #1196_

**Mike Schmidt**: The last PR for this week was a Rust Bitcoin PR, and it's
related to one we covered a few weeks ago, which was at the time adding just a
LockTime type to the library, so that you could interact with absolute
locktimes.  And this PR adds a new type and specifies the old one as absolute
and the new one is relative::LockTime.  Murch, what's with all these locktimes?

**Mark Erhardt**: Man, I don't know.  I think they had a weird approach to how
they treated locktimes at first, and then I think they only supported one of the
two, CLTV (CHECKLOCKTIMEVERIFY), not CSV (CHECKSEQUENCEVERIFY), or vice versa,
and now they're just cleaning up a little bit how they refer to it all and
properly support all of them.  I think that's just like a follow up to the
previous two minor changes in that regard.  I think it's important for people to
know about it that work with this library, but not a huge change.  They're just
adopting more of the feature set.

**Mike Schmidt**: Yes, the data types with respect to Rust Bitcoin is quite
detailed, and folks who are using that need to understand that.  I think the
question is an opportunity to maybe explain, from a high level, the different
locktimes in Bitcoin more generally, BIP65 versus BIP112, for example.

**Mark Erhardt**: Well, okay.  So, CSV allows you to lock a UTXO so it cannot be
spent for a number of blocks after the UTXO has been confirmed, basically
forcing a certain interval between the confirmation of the original UTXO and the
spending thereof again.  CLTV ensures that a transaction cannot be spent until a
certain height, I think, right?  And then, sorry, I'm explaining.  You're
putting me in a bad spot right now, I haven't looked at locktimes in ages!  So,
the regular locktime just in the transaction header allows you to make a
transaction that is only valid starting with a certain height.  And CLTV, I
think, makes it so that a UTXO can only be spent at a specific block height.
So, it's an absolute definition of when a UTXO can be used.  And the third is
CSV, which is a relative height from confirmation to when it can be spent again.
And using these, these are building stones for stuff like the Lightning
contracts and for making timelocked recovery transactions and things like that.
So, there's basically three different ways of using locktimes in Bitcoin right
now.

**Mike Schmidt**: Yeah, that makes sense.  And Rust Bitcoin, I guess, is
implementing the relative version of that here as opposed to the absolute.
Great, thanks, Murch.  Larry, any comments on these PRs, locktime, Eclair,
anything else you think we should talk about?

**Larry Ruane**: No, not for me.

**Mike Schmidt**: Okay.  Great, well thank you, Larry, for joining us this week,
and thanks always to Murch for contributing and being co-host on these Spaces.

{% include references.md %}
