---
title: 'Bitcoin Optech Newsletter #424 Recap Podcast'
permalink: /en/podcast/2026/09/29/
reference: /en/newsletters/2026/09/25/
name: 2026-09-29-recap
slug: 2026-09-29-recap
type: podcast
layout: podcast-episode
lang: en
---
Gustavo Flores Echaiz and Mike Schmidt are joined by Ahmet Kurt and Jan B to
discuss [Newsletter #424]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-9-1/433105248-44100-2-b5eeb81ea083e.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome, everyone, to Bitcoin Optech Newsletter #424 Recap.
This week, we're going to be talking about PQLN, which is a proposal for
making offchain parts of Lightning Quantum secure; we have Bitcoin Core 32.0
release candidates, we covered RC2 this week and its associated testing guide;
we have a monthly segment on selected Q&A from the Bitcoin Stack Exchange; and
our Notable code and Release segments.  This week, it's Gustavo and I, no
Murch, and we are joined by two special guests.  We have Ahmet Kurt, who will
be joining in a first-for-Optech pre-recorded segment that we'll put in when
this is published and edited as a podcast, and we have Jan B.  Jan B, who are
you?

**Jan B**: Hi, thanks for having me.  I'm janb84, I'm a Bitcoin Core
contributor, among other Bitcoin-related stuff.  My main focus is reviewing
PRs and working on kernel-related stuff.

_Proposal for a post-quantum Lightning Network_

**Mike Schmidt**: Awesome.  Well, thank you for taking the time to join us
today.  We're going to jump into our only News item titled, "Proposal for a
post-quantum Lightning Network".  And as I mentioned, we're trying something
new this week.  Ahmet Kurt couldn't make the live recording, but I thought it
would be interesting to try a recorded segment for us ahead of time, walking
through his proposal in his own words.  So, here's Ahmet.

**Ahmet Kurt**: Hello, everyone.  My name is Ahmet Kurt.  I am an assistant
professor at East Texas A&M University.  I would like to thank Mike for
inviting me to the podcast.  Unfortunately, though, I'm not able to attend it
live tomorrow.  Instead, I'm doing a recording.  The reason is, I am at a
workshop in Washington, DC, and my return flight to Texas is coinciding with
the podcast.  So, Mike suggested that I record it instead and then we go from
there.  So, I'm excited to be here first of all, and I would like to introduce
myself a little bit for people that do not know me.  And then, I'm going to
introduce the PQLN and all that stuff.

So, my Bitcoin journey started around 2017 with me hearing about Bitcoin, the
exchanges, like, you can make money with it, and all that.  But my official
academic journey started in 2019 with my PhD.  My PhD is from Florida
International University, which is in Miami, Florida.  When I first started,
really I wasn't working in Bitcoin or Lightning.  My PhD advisor actually knew
about Lightning surprisingly, and he suggested that I do a small
implementation for covert communication using LN, which I did, and it was
successful.  Then he was like, "Hey, do you want to change your topic to LN
stuff instead?  Do you feel more excited about it?"  I was like, "Yeah, for
sure, I'm more excited about Lightning".  So, that's how it started.  Then, my
PhD took four-and-a-half years, and during this time I did some cool projects.
I'm really proud of most of them, fun stuff like designing and evaluating
these LN applications.  You're actually welcome to look at them on my Google
Scholar.  To find my Google Scholar, probably you can just type my name there,
or you can go to my website, which is ahmet-kurt.github.io, then you can find
all sorts of information there.  So, right after my PhD, I got this assistant
professor job at East Texas A&M, and I am still continuing to do active
LN/Bitcoin/cybersecurity research.

Today's topic is about PQLN, which stands for Post-Quantum security for
Bitcoin LN's offchain surfaces.  So, this particular one exploded on X
basically, which is quite a bit of a shock to me, because I put the paper on
arXiv first, then I posted on Delving Bitcoin about it.  Nothing really
happened, but I guess people picked it up later on.  I actually DMd a couple
people to get some feedback, then it just became actually trending on X.  And
Mike and his team on Bitcoin Optech also featured the work on their
newsletter.  Okay, I think this should be enough introduction and probably, I
should now start talking about PQLN itself.  This idea, making Lightning post
quantum came to our heads around February 2025 with my co-author Abdul.  He's
a post-quantum researcher, you know, very experienced guy.  He's an assistant
professor as well.  He was like, "Why don't we try to make Lightning post
quantum?  Your expertise is in Lightning and my expertise is in post quantum.
Maybe we can join them and do something".  I was like, "Yeah, this sounds
great.  Let's try it".  Well, we tried, but we figured out, oh my God, this is
too much and we might not be able to do this at all.

At first, I felt overwhelmed.  I worked on modifying the Lightning protocol
before, but it wasn't as heavy as this one.  This is particularly like there's
just too many moving components in Lightning that has to be made PQ.  So,
around December 2025, Abdul and I started implementing it using
Rust-Lightning.  We figured Rust Lightning is kind of the most suitable one to
start such an implementation.  Yeah, I think it's pretty modular and there are
some benefits overall using Rust-Lightning, I think.  And around April, I
actually kind of started working on it more heavily, like spending every day
maybe a couple of hours actively working on it.  It took around four months, I
think, the total implementation.  Then, you're going to write the paper,
because I'm an assistant professor, I have to publish papers, that is part of
our job.  We cannot just put the GitHub repo out there and not publish a
paper.  Probably writing the paper took, I think, like one-and-a-half months
or something, which is also not an easy thing to do for a complicated project
like this.  We are targeting journals and conferences for works like this.
They usually have a page limit.  And in this particular work, the venue that
we submitted it to had a page limit of 13.  That's why the paper is 13 pages
by the way, in case you're wondering.  It could have easily been extended to
30 pages, I think, or I don't know, 20 pages at least.  We just cannot do
that.  Unfortunately, I have to follow their page limit.  This is also not
necessarily a cryptography paper.  I know in cryptography papers, people just
publish 30-, 40-page papers and put it on IACR website, I think.  But in our
field in computer science, we usually put it on arXiv and you all probably
know about these things, but I just wanted to kind of go over them regardless.

Yeah, all right.  So, let me actually dive into the technical part a little
bit.  Okay.  So, why make Lightning PQ?  You will ask, "Hey, we cannot make
Bitcoin PQ.  How can you make Lightning PQ without making Bitcoin PQ?"  Yeah,
you're right, but you also need to think about the fact that even if, let's
say, Bitcoin gets its post-quantum upgrade today, Lightning won't necessarily
be fully PQ, right, because Lightning has its P2P messages, gossip, transport,
invoices, offers, payment onions.  These are Lightning's offchain services
which won't necessarily benefit it from Bitcoin's PQ upgrade.  Therefore, we
could make Lightning PQ right now.  Also, another motivation to make Lightning
PQ right now is that people can record Lightning traffic to some extent, maybe
not the whole network itself, but they could record some portion of it with
the hopes to decrypt it later when there's a sufficiently powerful quantum
computer.  These motivations are I think good enough to start working on it as
a prototype.  I have to let you know that the implementation and the approach
might have issues, but we tried our best.  We tried to audit the whole thing
and I believe personally it is a sound and a good implementation overall.
There shouldn't be any big obvious flaws, in my opinion, but there could be,
so you're most welcome to give us feedback on that either on our GitHub
repository or in the Delving-Bitcoin post.  Maybe reviewers will also find
something.  But I will tell regardless about our approach.

It starts with the gossip, okay?  So, we had to distribute the PQ keys.  And
because now the nodes will have their classical node identities plus the PQ
node identities, and the distribution of PQ node identities, we figured could
be happening through gossip.  I think it's a sound approach.  People will know
each other, their PQ node identities over gossip messages.  In gossip, we made
node announcement, and what else is the other one?  Well, there are three
gossip messages.  We made two of them PQ and we left the channel announcement
classical on purpose, because channel announcement has two of its signatures
dependent on the onchain funding keys.  Therefore, making two of them PQ and
leaving the other two non-PQ, or classical, would probably not bring much
benefit, so we leave the channel announcement alone.  Next one is the
transport layer, which is BOLT8.  Basically, this is kind of, I think,
straightforward and probably the easiest one.  I believe this implementation
is correct, because we just add PQ primitives next to the classical ones.  You
are welcome to look at the diagrams also in the paper.  I think they have a
clearer way of showing things instead of me explaining it verbally.

Okay, then we got payment onion, invoices, and offers.  Let me start with
invoices.  So, making invoices PQ, the main issue is the size.  You put a PQ
signature in the invoice, which blows its size up, right, and it almost
exceeds the QR code limit.  But if you use ML-DSA-44 signatures, which are
2,420 bytes, you still make the QR code size limit by leaving only ten
characters to spare.  So, it kind of works.  The BOLT11 can be made PQ; you
can fit a ML-DSA-44 signature in it, though you have to split it, since
there's a size limit in the Lightning implementation, which only allows you to
hold at most up to 639 bytes.  We divided the signature across four tagged
fields to be able to carry it over the network.  If you use Falcon, for
example, Falcon will allow you to decrease the size of the signature
significantly, and the whole invoice will drop to about 1,500 characters.  For
BOLT12, the gossip approach that we had, the gossip pin, which lets other
nodes learn your PQ identity, it doesn't help much here because the node
behind an offer is often unannounced and sits behind a blinded path.  So, the
offer has to carry its own anchor.  We commit afresh the ML-DSA key for each
offer, and then the payer checks the return invoice against exactly that key
before you send any HTLC (Hash Time Locked Contract).  So, that's kind of the
summary of the approach with BOLT 12 offers.

Finally, BOLT 4.  To be honest, this is the hardest part, I think making the
onions PQ.  I spent a good amount of time on this one, because really the
problem is that onion packets are only 1,300 bytes and each payment needs one
ML-KEM ciphertext per hop.  This is per hop.  And one ML-KEM ciphertext is
1,088 bytes.  And if you have two hops, you just blow the limit up, right, so
it's not going to work.  But what we came up with here is that we keep the
onion exactly as it is, and make its per-hop secrets hybrid instead.  For each
hop, the sender encapsulates the hop's ML-KEM key and mixes that secret into
the classical Sphinx secret.  This way, the ciphertext basically, they travel
next to the onion in an updated HTLC message in a fixed list of 20 slots.  So,
this is the approach.  It's an interesting approach.  I would like to hear
feedback on this one.  I do believe this should be correct, but let me know.

By the way, you might ask, "Why don't we just increase the size limits of the
Lightning packages so you don't need to worry about these limits?"  The reason
we are not doing that is because if you do that, the interoperability between
the PQ nodes that are upgraded and the classical ones will not be happening.
They will not be able to talk to each other and not crash, or not quit the
communication.  If we want to have interoperability, we want to have the
Lightning protocol working as it is and find workarounds.  And the reason I
wanted to have interoperability in the implementation was that we could just
drop a PQ node in the network today and it would still be able to talk to all
the unmodified nodes.  But if it sees a PQ node, it can upgrade to PQ both
sides.  Since both sides are supporting PQ they can upgrade.  I think this is
a pretty necessary thing to do instead of modifying the Lightning altogether
and just break the interoperability.  I think this is what we should do at
first, and then maybe the specs will change.  The Lightning community will
adopt the PQ upgrades slowly, and then everyone will maybe start running their
nodes on PQ.  Or it could start as an optional mode, and then become required.
I think this could be worked out, so I would love to hear feedback on this one
as well.

Okay, doing all of this in Rust-Lightning, we added around 11,000 lines of
code over 52 files.  We added like 100 tests in total, 99 or 100.  It covers
lots of different scenarios, adversarial scenarios, functional scenarios.  I
would really love Rust-Lightning developers to look at it.  I am not a
software developer, I am an assistant professor, I'm an academician.  I might
not have written the best code, or I might not have approached it in the best
way possible, but I think this is a good start.  These tests should be
covering most obvious attacks against the changes we did.  So, doing all of
this resulted in some overhead, right, because PQ messages are big and it will
cost us something in return.  The computation, due to the increased sizes and
everything, is really negligible.  I think the most expensive operation, the
ML-DSA signing, adds around only 0.33 milliseconds.  The real overhead is the
gossip bandwidth.  When we did the tests, a fresh PQLN node that's joining the
network downloaded ten times more gossip than a regular node.  This is with
ML-DSA-44, by the way.  If we use Falcon instead, it drops to about four times
more than unmodified nodes, which is not too bad, in my opinion.  Only issue
with Falcon is that it's not NIST standardized yet, right?  ML-DSA and ML-KEM
is NIST standardized in 2024, but not Falcon.  So, maybe to use Falcon, we
need to delay a little bit more to be making sure that it's secure.

I also talked to Matt Corallo today on Twitter.  We just tweeted out a few
tweets.  He was saying one of the other important things is to use secure Rust
crates.  We used fips203, fips204.  I don't know if they are audited, if they
can be used in a production environment.  I don't know.  Experts would
probably be able to tell the answer, but that's what we used in our
implementation.  We did some interoperability tests against an unmodified node
and a PQ node.  We just exercised mainline functionality, such as sending
payments, receiving payments, opening and closing channels, asynchronous
payments.  I think we might have tested even splicing, I'm not sure, but all
of that works, nothing breaks.  They're able to do these operations without
nothing absurd going on between the nodes.  They follow the protocol
completely, which is great.  I want to emphasize, I really spent so much time
making sure it's interoperable.  If I hadn't had that constraint, I think the
implementation would have taken less time overall.

Okay that's all I'm going to say.  I exceeded the ten-minute limit Mike had
given me.  I'm sorry if it's too long.  But the paper is on arXiv, the GitHub
repo is ahmet-kurt/pq-rust-lightning.  You're welcome to go have a look at it,
let us know what you think.  You can open issues, PRs even.  I would really be
happy to look at them.  It kind of is a new thing to me.  I haven't maintained
a GitHub repository before, but it might be a good start with this project.
Again, thanks to Mike and the Bitcoin Optech team for this podcast opportunity
and for the feature on their newsletter.  Hope to see you guys some other
time.  Bye.

**Mike Schmidt**: So, that was Ahmet Kurt on PQLN.  We want to thank him for
recording that segment for us.  We have links to the Delving post, the paper,
and the implementation as well.  Those are all in the newsletter.  That wraps
up our News segment, and we're going to jump to Releases and release
candidates, so a little bit out of order.

_Bitcoin Core 32.0rc2_

We're going to skip the Stack Exchange for the moment and jump to Bitcoin Core
32.0rc2.  Jan, 32.0 is the next major version of Bitcoin Core, and we have RC2
out.  I don't know since we published on Friday if there's anything new there,
but you wrote the testing guide, which is up on the Bitcoin Core Dev Wiki, and
perhaps you can walk us through two components.  I know you've been on the
show talking about this in the past, so maybe you have a way that you'd like
to portray it, but I think we want to have the audience walking away with
maybe both knowledge of what's in 32, as well as maybe some details on the
testing guide and things you have in there, or things you're working on, or
feedback you're looking for in particular.  So, I'll turn it over to you, Jan.

**Jan B**: Yeah, no worries.  So, once every six months, there is a new major
release of the Bitcoin Core software.  And right now, we are on 32 RC2, and
the final release is targeted for October 10th.  Releases are time-based, not
feature-based.  So, every release has not the same amount of new or improved
features.  And this one has a lot of new features or improvements.  Not
everything is in the release notes, that's also good to know, and the notes
cover the most notable changes.  But there are also a lot of bug fixes for
minor issues that don't get their own line.  Before every release, the project
puts out one or more RCs.  Currently, we are on RC2, and that means that after
the first RC, there were some minor issues found, and the project has released
a new RC with some bug fixes.  The RCs are feature-complete, so the community
can test their own setup against it.  For this testing campaign, the project
also writes a testing guide, and that's intentionally incomplete.  And so, why
an RC needs the community?  Bitcoin Core has already an extensive test suite,
so every PR gets tested with unit tests, functional tests, fuzzing, continuous
integration on many platforms for every PR.  On top of that, there's also now
an effort by the Red Team that tests with AI for security issues, etc, but the
project cannot test on every downstream setup.  So, every Lightning node,
block explorer, or wallets app, hardware wallet, mining pool, operating
system, etc, or for instance a Raspberry Pi in someone's closet, every setup
is a little bit different.  We cannot test that for every setup.

So, that's where the community comes in.  You run it in your way, on your
hardware with your software around it, and we need your feedback.  So, we have
built the most feature-complete release, and we really have put some effort in
it to test it really well, and now we want some community feedback if it also
runs on your hardware in your setup in your way.

**Mike Schmidt**: Jan, you mentioned this, but I think we'll just bat the
point home for listeners as well.  Obviously, there's new and different
feature/component settings, etc, that will be in 32.  But even if folks grab
their RC and just use that RC Bitcoin Core in the same way that they have
previously, even if it doesn't necessarily touch any of those features
directly, it could be valuable because it could surface some other bug that
maybe was behind the scenes and not one of the headline features, right, maybe
certain operating system compatibility, etc?

**Jan B**: Certainly.  So, you do not have to use the testing guide.  Just run
it as you would run it.  So, the testing guide is nothing more than a starting
point for experimentation, and it's in no way comprehensive.  But also, the
feedback in the way you run it at home is pretty important.

**Mike Schmidt**: And where should folks put that feedback if they find
something interesting or notable for the team?

**Jan B**: Well, there are two points where you can give feedback.  There is
an issue for the testing guide if you want to give some feedback on things you
miss or you want to get changed or just have feedback, Well, I love the
testing guide, but next time I would like to see this, please.  And there is
also an issue on GitHub for explicit release 32 issues.  Both are linked in
also the testing guide.  So, like I said, it's a starting point for
experimentation and it's in no way comprehensive.  But what we try to do with
the testing guide is walk you through the steps.  And it now covers, like, ten
tests in four groups, some new RPCs, some updated RPCs, some wallet-related
issues, and it also covers the HTTP server rewrite.  Everything runs on
regtest, and that's your own private test chain, so you can mine your own
blocks, and you don't have to download the whole blockchain.  It just runs
instantly and it will take up only a few megabytes of storage on your own
machine.

**Mike Schmidt**: So, what kind of things are in there?  What's in the testing
guide?  And if there's anything interesting that's not in the testing guide,
what can listeners expect in 32?

**Jan B**: So, we cover a lot of stuff that's also in the release notes.  The
most notable are, for instance, there is now a new RPC command,
getopenrpcinfo.  And that's a machine-readable description of every RPC that
Bitcoin Core has.  And you can use that, for instance, in your own downstream
client.  And this will also help in the future, because you can easily diff
between the two outputs, and then you can discover changes in the future more
easily so that you can also change your downstream clients in a more
convenient way.  One other thing that is there is now also a new RPC,
exportwatchonlywallet.  And so, if you have a wallet on Bitcoin Core and you
want to have a way to see your balance but not to be able to make
transactions, so for instance you have an additional wallet on your phone and
you only want to see if you get paid or what's your balance, you can export
with that command the xpub.  And then, you can restore that on your phone.  We
test that in the RC testing guide.  There's also some updated RPCs that we
test, for instance the PSBT is now v2 by default.  And it's good to confirm
that it works, especially if you use PSBTs in a different way in your own
setup.  So, we use it to confirm, sign and finalize the broadcast.  But also,
if you use it in your own setup, please test it.

This release also has a new HTTP server that was rewritten from scratch to
remove libevent.  So, anything that talks to your node over RPC or REST uses
this new feature.  One thing is that it is deliberately rewritten to be more
strict on some RFC rules.  So, if you use your own RPC or REST client, you are
advised to test against it.  There has been a lot of effort to keep it as
compatible as possible, but we wanted to be more strict for the RFC that are
used on the internet for HTTP servers.

**Mike Schmidt**: For listeners, we had Matthew Zipkin on in Podcast #411 to
talk about all the work that went into that replacing of libevent.  If you're
curious for more, it's an interesting story.

**Jan B**: Certainly.  Yes, so those are the main topics of the testing guide.
So, we also do some derivehdkey, addhdkey.  It has to do with the option to
use multisig in the new Bitcoin Core wallet.  If you want to have a deep dive,
you can use the release testing guide as a start, and there is extensive
documentation in the documentation of Bitcoin Core.  And there's also a new
fee estimator; we test that.  And there is also an option to dumptxoutset to a
named pipe.  That's a little bit more advanced feature.  So, you can stream
UTXO set to a file and then use that in a database or something else.

**Mike Schmidt**: I made a few notes.  I think Jan covered most, if not all,
of these, but I did pull out which newsletter we covered them in.  And I think
these are all in 32, but I'll just list them off.  And then, Jan, if there's
anything you want to elaborate on, we can get into that.  But the
exportwatchonlywallet, we discussed in Newsletter and Podcast #413; the
libevent, I mentioned we had Zipkin on for #411; there's the parallel coin
fetching for faster block validation, which was #414; smaller and faster
-txindex, #419; Jan mentioned the mempool-based fee estimator in #420;
migrating the wallet without loading the wallet, I think we actually talked
about that in a Stack Exchange answer in Newsletter #416; and then, there's
the global transaction-relay limits, and the 200 connection default from 416
as well; and then, the last one I noted here, and I think this is in 32, but
the BIP434 peer feature negotiation, that was in Newsletter #410.

**Jan B**: Yes.  For instance, those small -txindexes, that's pretty hard to
test in a RC on regtest.  So, we are interested in the experiences of the
community, but it isn't mentioned in the RC testing guide because for that
feature, you need a bigger data set.  So, you need to copy mainnet data, and
that's outside of the scope.  But we are interested in your experiences, so
please test that.  And, yeah, the parallel fetching, that should help with
syncing.  We're also pretty excited about that and to see what kind of
in-the-field experiences are with that.  But again, too hard to test in a
regtest situation, so those are also not in the RC guide.

**Mike Schmidt**: Well, we link to the RC, we link to the guide.  I think the
only other thing that you mentioned, Jan, that folks may have to crawl around
for would be the draft release notes that we don't have a URL handy in the
newsletter for just yet.

**Jan B**: It's also in the release testing guide.

**Mike Schmidt**: Oh, good, you link to it from there, great.

**Jan B**: Yes.

**Mike Schmidt**: Okay, perfect.  So, check that out. If you don't want to do
the RC testing, you can at least see what's coming in this v32.

**Jan B**: I want to say one thing.  So, we are also interested in if
everything just ran and it worked.  Those mentions are also useful.  And send
your OS and your hardware, please, for that.

**Mike Schmidt**: Excellent.  Jan thanks for joining us, thanks for putting
the testing guide together, and we appreciate your time.

**Jan B**: Thanks for having me.

_What would be a drawback if sum instead of SHA256 of amounts was used in the taproot signature message?_

**Mike Schmidt**: Cheers.  We're going to go back up now to our monthly
Selected QA from the Bitcoin Stack Exchange segment.  First question, "What
would be a drawback if sum instead of SHA256 of amounts was used in the
taproot signature message?"  Maybe a bit of background on this one first.
When you have a hardware signing device that signs a transaction, it doesn't
have the blockchain on it.  It only knows what the computer it's plugged into
is telling it.  So, the fee in a transaction is just inputs minus the outputs.
So, if you are connected to a computer that is compromised, or for whatever
reason lies about how much an input is worth, the device could potentially be
fooled about the fee.  So, this is the whole idea of a fee-overpayment attack.
So, if your input is really worth 10 bitcoin, but a malicious piece of
software on your computer that your hardware signing device is connected to
tells that device that it's worth 1 bitcoin.  Then you approve sending 0.99
BTC to the recipient, thinking the fee is 0.01, when in reality it's 9.01
bitcoin that goes to the miner.  So, that's a little bit of a background on
the fee attack.  Taproot fixed this and it makes every signature actually
commit to the amounts of all of the inputs.  So, if that computer that's
malicious lies about any of the amount, the signature would just be invalid
and that transaction can't be broadcast.

So, maybe back to the question.  Taproot hashes all of the amounts together.
This person asking this question asks, "Why not just commit to that total?"
He notes that there's potentially the same protection against fee theft with
less work.  And the answer here is that committing to the total actually does
still stop that fee attack, since the total in minus the total out is fixed,
but the malicious computer in our example here could actually still shuffle
the amounts between the different inputs around as long as that total stayed
the same.  And so, then you can picture something maybe like a coinjoin where
you put in 1 bitcoin, someone else puts in 0.1 bitcoin, and the outputs pay
you 1 bitcoin, to them 0.1 bitcoin.  Now, this malicious software and computer
lies to your device and says that your input is 0.1 and theirs is 1, so the
total is still 1.1.  So, you're satisfying that total and the fee check
passes, but now the device is going to happily approve a version where you get
0.1 BTC and the other party gets that 1.  So, that's why you want to keep the
actual taproot design that has your device actually committing to your input
being that 1 bitcoin.  So, I was going to say, "Murch," I'm so used to it!
Gustavo, anything you'd add to that?

**Gustavo Flores Echaiz**: No.  I have no idea about how that works.  But
yeah, I think you explained very clearly, so that's interesting.

_Post-BIP110 fork is it necessary to resync from block 0?_

**Mike Schmidt**: Next question from the Stack Exchange, "Post-BIP110 fork is
it necessary to resync from block 0?"  Maybe a little bit about where this
person might be coming from.  They were running Bitcoin Knots with BIP110
enforcement turned on.  And then, when the activation attempt failed back in
August, those nodes started rejecting that first block that didn't signal and
split off into two different chains.  We covered some of this BIP110
discussion in Newsletter #418.  But that chain, as it was, never got past
really a few blocks before stalling out.  There's been a few different forks
of that now that have come into play, but that's not what we're talking about,
just maybe more of a conceptual question using that as an example.  This
person now wants to get back on Bitcoin mainchain by switching to Bitcoin
Core.  But their worry was that they were running a pruned node, which throws
away old blocks, and then a pruned node can't rewind past what was already
previously deleted.  So, they were asking, "Hey, do I have to download the
whole blockchain from scratch now?"  And our co-host, Murch answered this,
"Probably not".  And he notes that probably not, because that split happened
recently, at least in the eyes of his Bitcoin Knots node.  And because the
BIP110 chain, with those rules at the time, barely added any blocks before
that node was last run, then the pruned node will almost certainly have that
last block that both the chains shared, because there would only be a few
blocks, even if the Bitcoin mainchain had thousands of blocks since then.

So, he, Murch, advocated that he thinks you could probably install Bitcoin
Core in place of Knots and it should just reorg back to the mainchain on its
own.  And maybe one fallback he mentioned that I should mention here is that
you could also run reconsiderblock on the first block the Knots node rejected
that wasn't mandatory signaling, and that would tell the node to stop treating
that block as invalid, and then re-evaluate the chain from there.  I don't
think Murch actually did this himself, but I think he's just speaking about
how the mechanisms within Bitcoin Core work to recover from such a situation.
Any feedback, Gustavo?

**Gustavo Flores Echaiz**: It makes total sense.  I think if someone got stuck
in this situation, it isn't as hard to recover because there was not so much
work done in this new chain.  So, no need to start from the beginning.

_Can a Bitcoin node build a partial UTXO set from only the most recent blocks and use it to validate new transactions?_

**Mike Schmidt**: Last question from the Stack Exchange, "Can a Bitcoin node
build a partial UTXO set from only the most recent blocks and use it to
validate new transactions?"  Kind of an odd ask, but I think what the person
asking this question is getting at is that, "Hey, I don't want to go back to
every block since 2019.  That's a lot.  What if I just skip all that old
history and only process the last few months' of blocks", I think is what he
was asking, "and then build a UTXO set out of that and then validate new
transactions against that?"  I think they're hypothesizing that that could be
like a cheap, lightweight node.  But our question answerer, Pieter Wuille, who
answers so many questions on the Stack Exchange, actually did take a crack at
this and explained why it wouldn't work.  And I think probably our listeners
are familiar with why this might not work.  You obviously need to check that
every coin in that transaction that is being spent actually exists and hasn't
been spent yet.  And obviously, with only a partial UTXO set, you could be
spending one that the node doesn't have.  And in that case, that coin could
have been created years ago and it's perfectly valid.  But your hyper-pruned
partial-UTXO-set node doesn't know about that coin even existing at all.  So,
interesting that people are thinking about these kinds of things, but
obviously not possible.

**Gustavo Flores Echaiz**: Right, yeah, I saw the guy was trying to make a
sort of new design.  He said, "I'm working on a lightweight-node design for
improving independent verification of new/unconfirmed Bitcoin transactions
under limited storage".  So, it's a good initiative, but yeah, this definitely
doesn't work because you can never know for sure if you have UTXOs and spent
transaction outputs that date very long ago in the early days of the of the
Bitcoin Network.  So, because of that, you do need to validate the whole
transaction history to build a UTXO set.

**Mike Schmidt**: Yeah, good energy.  Probably put that energy into something
that we've been talking about, did we talk about it last week or the week
before?  Yeah, Utreexo, Floresta gets you sort of that compact representation
of the UTXO set while taking into account all blocks and not just some blocks
like this proposal was getting at.  That's it for the Stack Exchange.  We only
pulled out three this month.  So, we can go back to the Releases and release
candidates segment to pick up where we left off.  Gustavo, I'll let you take
it from here.

**Gustavo Flores Echaiz**: Yes.  So, we already covered the RC of Bitcoin Core
v32.  So, as Jan said at the beginning, there's a testing guide.  Please go
check it out if you're interested in testing this work.  Quite a heavy
release.  We'll have probably a follow-up RC in the next few weeks, and we'll
probably also have more information on this release in the next episodes and
newsletters.

_Core Lightning 26.06.8_

The other two releases that are part of this newsletter, the first one is Core
Lightning 26.06.8.  This is another security release from Core Lightning
(CLN). Once again, the notes are not that self-explanatory.  So, the source
code is however released, unlike the previous version.  But on purpose, a
small number of tests are withheld temporarily to make it more difficult for a
prospective attacker to identify and exploit the underlying vulnerabilities.
In the previous release, it was even more extreme.  It wasn't just the test
suites, it was the source code as a whole.  And by the way, in the Notable
code and documentation changes, I'm going to talk about what was in the
previous release of CLN, because we finally got the source code release.  So,
yeah, so users of CLN are strongly recommended to upgrade to the new version
26.06.8.  Also, important to note, if you had been experimenting with the
development build on master, you cannot downgrade to this release, because the
database schema that you were using on experimental development build was
newer.  So, also be careful if you have run the development build; if you
would like to downgrade to this version, you cannot.  So, worth noting for
operators.

_LDK v0.3-rc2_

The next item in this release section is LDK v0.3-rc2.  So, once again, this
is the second RC of a release we covered in a previous newsletter.  It has
multiple new features, such as RBF fee bumping.  When a splicing transaction
gets stuck and cannot confirm onchain, you can now finally RBF it to increase
its fee and to get it actually to confirm.  It also allows you to add or
remove funds in that splice.  So, for example, you could remove or add
additional funds in that splice.  Also, anchor channels are now negotiated by
default, and applications that use LDK are explicitly required to accept
incoming channels.  The upgrade also invalidates previously issued BOLT11
invoices, because there was a format update in how BOLT11 invoices were
constructed where the payment data was restructured.  So, if you were to
upgrade to this RC, your previous BOLT11 invoices that have not yet expired
would become sort of incompatible with this new version.  So, also worth
looking into that.  And there are multiple API and backward-compatibility
changes.  So, operators should take a look at that as well.  However, this is
still just an RC.  So, don't yet fully consider it as a production release.
It's mostly released for testing purposes.

I also want to note that the LDK repo has moved away from GitHub to a
self-hosted mirror, git.rustbitcoin.org, instead of the GitHub repo.  So, the
PRs, for example, and the consistent work can no longer be found on GitHub.
It is found on that mirror website.  However, you can easily find the mirror
website through the GitHub repo; it's in the 'about' description of that repo.

**Mike Schmidt**: Gustavo, you mentioned it in the previous item, because it
wasn't a RC.  So, obviously, test your RC if you have a setup and provide
feedback to those project maintainers.  But obviously, for full versions that
we're covering of software that's coming out, we've covered it for the last
few months here, there's just the amount of bug fixes that these pieces of
software are going through due to Red Team and other groups.  There's a loop
and there's actually hackers out there attacking software.  So, I encourage
folks to update to the latest version of their software.  In fact, for this
coming week's newsletter, one of the items that I'm doing a summary of is the
disclosure of two DoS vulnerabilities in Lightning software.  So, stay safe
out there, keep updated with the latest versions when you can.

**Gustavo Flores Echaiz**: Thank you, Mike.  And yeah, Lightning is
particularly vulnerable to these types of attacks because of how complex the
protocol works.  We're going to cover the CLN previous vulnerabilities in a
bit, but yeah, particularly Lightning is affected.  So, once there's a
security release, it's strongly recommended to upgrade.  And if you are a
tester, please take a look at the RC and the testing guides.

_Bitcoin Core #34566_

Now we move forward with the Notable code and documentation changes section.
We have one item from Bitcoin Core, two new BIP proposals, and multiple items
from CLN and LND.  So, let's start with the Bitcoin Core item #34566.  This is
a very simple one that follows what I had covered in Newsletter #412.  This is
about adding default multi-signet data directory support in Bitcoin Core,
which means that previously, if you were to use multiple signet networks,
which is not the most common use case of Bitcoin Core, but it's still an
allowed use case, you could previously manually build multiple subdirectory
data directories for your different multiple signet networks.  However, it was
not supported by default or it wouldn't automatically arrange multiple data
directories on your behalf.  You would have to do it manually.  Now, Bitcoin
Core is updated to allow users to have multiple custom signets that share a
base data directory but all have subdirectories that are tagged with their
four-byte network identifier.  And this allows the chain data not to conflict,
as previously you could run into conflict scenarios.

So, now, if you were a user that had already set up multiple signets on your
device, to avoid resynchronizing after upgrading, you should manually rename
your directories to the new format to use the four-byte network identifier in
the subdirectory name, so that you avoid unnecessary resynchronization after
upgrading.  Yes, Mike?

**Mike Schmidt**: Yeah, maybe just a common point of confusion that I see is
that people treat signet as the signet, there is just one signet.  I think
this obviously bats home the point that you can have many signets that you're
operating on.  You can operate your own signet if you choose.  I think the
fact that there is a default one that is easier to use is just sort of a
convenience thing for people.  But I think it's sort of put in people's minds
that there's just one of those.  But you can run your own.  Reminder.

**Gustavo Flores Echaiz**: That's great.  Right, exactly.  Great feedback.
And that's exactly for those types of users who would like to run their own.
This helps set it up easier.  Now the next two items are from the BIPs
repository.

_BIPs #1951_

The first one, #1951, adds BIP138.  So, BIP138 is an idea that has been
previously discussed in its nascent form in Bitcoin Optech, particularly in
Newsletter #351.  In the News section, we discussed and we probably invited to
the episode, standardized backups for wallet descriptors.  Salvatore Ingala
had posted to Delving Bitcoin back in April 2025 about this idea of creating a
standard for backing up wallet descriptors.  The idea is if I'm setting up,
for example, a multisig wallet with other signers, we have a descriptor of our
multisig wallet, or sometimes called just a wallet file, that even if we had
two keys out of three in a 2-of-3 multisig, we would still need the descriptor
or the wallet file in order to recover the funds.  Even if the multisig says
that two keys out of three are sufficient, the third xpub is required to
reconstruct the wallet.  So, the idea here is how can we create a
specification or a standard for creating backups of descriptors and other
non-seed wallet data, for example, BIP388 wallet policies too, that a user
could safely upload, for example, in their computer or their Google Drive
folder, and only him could decrypt that file and nobody else that had access
to that folder could decrypt it?  And this is where BIP138 comes in.

The idea here is that if each different signer has their xpub, what if their
xpub could allow it to decrypt the encrypted wallet descriptor?  So, the
analogy that I would say here is sort of if there's one encrypted safe holding
the descriptor, but beside it there's three small lockers containing the same
key that will decrypt the safe holding the descriptor, and the small lockers
are each specific to each signer.  So, I, as the first signer, I have my xpub.
I can open, for example, the first locker, and that gets me the key to open
the main safe to obtain the descriptor.  So, each signer can access the same
decryption key that will then allow it to decrypt the descriptor.  So, this is
now fully standardized.  And it allows any cosigner to recover a descriptor
from their own seed without needing the other cosigners' keys.  So, I think
this was very interesting.  We'll see how it gets adopted.  And yeah, there's
additional notes in the Bitcoin Optech Newsletter about this, and also you can
check out directly the BIP specification.

_BIPs #2224_

The next item introduces BIP461, so PR #2224.  This is about introducing a
single deterministic ECDSA signing algorithm.  So, the problem that we want to
mitigate here is basically exfiltration, or we want to create
exfiltration-resistant signing.  If you had malicious software that would
choose the nonce value when signing with an ECDSA signing algorithm, if your
malicious software is the one choosing the nonce value, it could technically
leak private key material that only the attacker could decrypt through the
nonce value.  And it would require only two signatures for enough private key
material to be leaked that could allow an attacker to decrypt that private key
material and obtain access to your wallet.  So, in Newsletter #315, we covered
the Dark Skippy attack, which is an improved method for key exfiltration from
a Bitcoin signing device that works in the manner that I just described, where
an attacker leaks private key material through the nonce value.

So, now that we understand the problem, BIP461 comes up with a standard
specification with a single deterministic ECDSA signing algorithm that ensures
that any given private key and message will always produce the same signature,
because it uses RFC 6979, so a specific standard for how to derive the nonces.
And it also applies low-r grinding, which we have this whole section on
Bitcoin Optech that explains what that is, but it's an optimization for
wallets where they keep generating new ECDSA signatures for the same
transaction until they find a signature whose r value is on the lower half of
the range, allowing it to be encoded with one fewer byte than a signature on
the top half of the range.  The point is that BIP461 has a specific standard
for how it derives nonces, it always applies low-r grinding by retrying until
r encodes without a leading zero byte, and also normalizes s to its low form.
So, now, because the output is deterministic, any software that supports
BIP461, that supports this single deterministic ECDSA signing algorithm,
should always have the same result.  If you compare two different signing
softwares or devices and you don't arrive to the same result, but both claim
to support BIP461, then either they have failed at implementing the
specification or potentially there's a potential attack attempt to leak key
material through nonce selection.

So, this allows a user or an operator, a developer, to detect whether this was
properly implemented, and if not, you could be suspicious that there's a
potential attack here to attempt to leak your key material through nonce
selection.  So, an important BIP, I believe, and an interesting background to
how the Dark Skippy attack works.  If you want to know more about it, you can
look at Newsletter #315.

_Core Lightning #9507_

So, the next five items are from the Core Lightning repo, and we finally now
know what were the vulnerabilities that weren't previously disclosed.  So, I'm
going to go through all of them one by one, starting with PR #9507.  So, each
of these items has multiple issues and multiple bug fixes in them.  The first
one mostly comes to feerate bounds and feerate values that could overflow.
So, previously when a peer proposed the splice or when you try to RBF a
dual-funding opening or funding transaction, there was never an upper feerate
bound.  So, your peer could propose an extremely high feerate for a splice or
an RBF attempt on a dual-funding opening, and you would simply accept it.  You
would completely lack upper bounds.  The dual-funded opens lacked both lower
and upper check bounds, while the RBF of a splice or the RBF of a dual-funded
opening lacked simply the upper feerate bound.  Also, if you had stored a
feerate that was a very large value, this could potentially overflow.  It
could basically reset to zero, so you could either pay a very low fee that
simply wouldn't get the transaction to be added into a block, or you could
also trigger an assertion when calling the command listpeerchannels RPC.  But
the problem here is that every plugin calls this RPC command at startup.  So,
if your node would accidentally store a very large value for an RBF feerate
calculation, then you would basically hit a cycle of restarts, because every
time the node would restart, the plugins would call listpeerchannels RPC and
that would hit an assertion failure and crash the node continuously.

So, three bug scenarios here.  The first one, you stored a zero value, you're
not paying enough fees, your transactions are not getting confirmed.  The
other one, you stored a super-high value that hits an assertion failure, and
this simply repeats on all restarts.  And the third bug, which is the one that
I started with first, is when you are missing feerate bounds, so potentially
you're paying excessively high fees when, for example, your peer proposes a
super-high fee.  So, the fixes here are to introduce a new absolute ceiling of
4,000 sat/vB (satoshis per vbyte) on peer proposals and also backend fee
estimates.  And this absolute ceiling always applies.  Even if you use the
command --ignore-fee-limits, this ceiling would still apply.  However, there's
also another ceiling that's introduced that is ten times lower at 400 sat/vB,
that caps RBFs, commitment updates, splices, and your own opens.  So, CLN
differentiates between the fees that come manually from you, caps those at 400
sat/vB.  However, you can override those with the --ignore-fee-limits setting.
But if a fee comes from a peer proposal or from a backend fee estimate, that
is always capped at 4,000 sat/vB.  And also, if you had stored values that
would hit the assertion failures, the overflow bugs, that code is also clean.
So, those out-of-range stored feerates are also repaired on upgrade.

**Mike Schmidt**: Pretty crazy.  Yeah, there's a lot going on there.  But it
sounds like the ceiling should be enough for the foreseeable future, with
4,000 sat/vB, given our current fee climate.  But yeah, good to understand
some of the details of this one, although it sounds like there's more.

**Gustavo Flores Echaiz**: Right.  And I don't know if you remember, but I had
talked about this in a previous newsletter, actually the last newsletter, the
Eclair implementation had similar fixes.  So, it seems that Eclair kind of saw
that CLN dealt with this, so they made the fixes themselves on their repo too.
So, I'm actually observing a lot of similarities between CLN, LND, and Eclair.
They all seem to have similar gaps that could be exploited and are fixing
them, which brings me to the next item.

_Core Lightning #9508_

So, #9508 fixes several splicing and channel-opening issues.  So, once again,
in the last newsletter, we also talked about the splicing issues within
Eclair, which now are apparent within CLN too.  So, there's multiple scenarios
here.  So, the main one was that before CLN received a peer's splice_locked
message, but CLN might have already sent its signatures to the peer, then the
peer could technically broadcast the splicing transaction or the commitment
transaction for a pending splice.  But if CLN had not received the
splice_locked message, it would simply miss these peer broadcasts.  So, now,
even if CLN doesn't receive the technically accurate message from the peer
confirming that the splice has been locked, as soon as CLN sends its
signatures, it should and it will start monitoring the funding output of every
pending splice and recognize that spend if it sees it onchain.  So, now, a
peer can no longer fool CLN into thinking that the splice hasn't been
completed when it has actually been completed, and the peer could technically
broadcast these transactions by himself.  So, that's the first scenario.

The second one is if a peer sends you a tx_abort message during a splice, you
technically have to abort the splice.  However, if CLN has already sent its
signatures once again to the peer and the peer sends a tx_abort message, you
cannot accept that message because you have already sent your signatures, so
the peer could already broadcast the transaction.  So, now, CLN properly
force-closes the channel if the peer sends tx_abort after CLN has sent its
signatures.  And the check previously would fail because CLN would just simply
fail to recognize the splice that had already been signed.  It would look for
another splice and it would just see, like, "Okay, I haven't signed it yet",
but in reality, it was just looking at the wrong splice, and also the flag
indicating that the signature had been sent was not preserved across restarts.
So, if I restarted my node, I would lose the memory that had already sent my
signature to my peer, and the peer could technically make me think that the
splicing was abandoned when actually, I had sent him all my signatures.

**Mike Schmidt**: Crazy!

**Gustavo Flores Echaiz**: Yeah, crazy scenario.

**Mike Schmidt**: And there's a third one!  And it's like, yeah, there's three
in the last one, three in this one.

**Gustavo Flores Echaiz**: There's so many different scenarios in Lightning.
This is why I think Lightning was particularly vulnerable to these latest
rounds of attacks because of all these so many different edge cases,
particularly in the splicing protocol.  You've got so many different steps and
messages, right?  You've first got to go suspend the channel with the
quiescence protocol, and then you've got to start negotiating.  So, all of
those edge cases are kind of getting exploited and now getting fixed.

**Mike Schmidt**: The timing is a little bit poor as well, right?  You know,
when dual-funding; when splicing?  We've been asking for years, and then they
sort of both kind of come out in experimental ways right around when LLMs
start finding edge cases and complex schemes like this.  So, it's unfortunate
timing, I guess, as well.

**Gustavo Flores Echaiz**: Right, exactly.  Finally, the last part of this PR
is that if my peer keeps sending me dual-funding opening requests, I will now
disconnect the peer if I already have three ongoing channel-opening
negotiations with him.  So, this basically puts a threshold on how many
dual-funding opening requests a peer can make to me.

_Core Lightning #9509_

The next item, #9509, this one's actually, I think, probably the most
important one, because there are issues related to onchain channel resolution.
So, the first part is that an attacker could trick CLN into treating a
force-closed as a cooperative close.  So, an attacker could force-close a
channel, but CLN would not react to the force-closing.  Even if the peer had
sent a revoked commitment transaction and CLN was supposed to reply with a
penalty transaction, it would get fooled into thinking it was a cooperative
close and it had no reaction to be given.  And how was that done?  First, the
peer that doesn't commit to an upfront shutdown script -- so, when you open a
channel, you can commit to an upfront shutdown script, which means, "I want to
get paid to this address".  So, you don't have to do that, that's an option.
So, the first requirement for this attack is the peer doesn't commit to an
upfront shutdown script.  The second step is the peer sends a shutdown message
as if it was initiating a cooperative close.  But in the shutdown message, it
tells him, "I want to get paid to an address that was part of a revoked
commitment".  However, the attacker, as soon as it sends the shutdown message
and CLN registers the shutdown script or the output that's getting paid, then
the attacker aborts the cooperative close and broadcasts that commitment.  But
CLN would basically think that because the shutdown message had been sent, the
cooperative close was still ongoing, so it would simply not react to the
broadcast of a revoked commitment with a penalty transaction.

Now, CLN simply does a better job at identifying commitment transactions by
their locktime and their sequence encoding before checking outputs.
Previously, it was simply checking outputs.  And if the outputs match what it
was expecting for a cooperative close, it would simply not react as if it was
a force-close.  Now, it looks at better identifying information to detect what
the commitment transaction is really about, and it immediately notices that
it's a revoked commitment, which is what allows it to reply with a penalty
transaction.  Also, so that is probably the main fund-theft case that we've
explored in these notes.  But for example, other edge cases that are also
present is if I have a commitment transaction or a descendant of a commitment
transaction confirms but gets reorged after, then CLN would stop monitoring
the outputs of the commitment transaction.  So, another transaction that would
spend the commitment transaction would simply fail to be monitored until the
node restarted.  So, now, CLN ensures that if the descendant of a commitment
transaction gets reorged, it would keep on monitoring those outputs for any
new transactions.

Yeah, I think that's the main part of this PR.  There are additional edge
cases that we could also discuss, but they're present in the notes.  And if
listeners want to know more about it, they can jump into that item.

_Core Lightning #9510 and #9511_

The next one is two different PRs put together, #9510 and #9511.  This is
about hardening input parsing and logging.  So, not as critical as previous
ones, where fund theft was even possible.  This is more about potential
crashes or data leaking.  For example, if a node announced a very long DNS
hostname, CLN simply had no limits on it before.  So, we could try to connect
through a proxy to a node that announced a very long DNS hostname, and that
could crash the connectd of CLN and therefore crash CLN.  So, now, CLN simply
rejects DNS addresses from peers in received node announcements that are
invalid.  It will simply ignore invalid DNS node announcement addresses.  But
it will also reject DNS addresses that are not valid hostnames, even if it
comes from its own configuration.  So, now, two protections are added from its
own configuration and from node announcements by network peers.

Also, JSON nesting is now limited to 256 levels.  So, this was also a
potential other crash if JSON information had too many nestings that could
also potentially crash CLN, or request bodies and REST calls that were higher
than 2 MiB; that was also another crash trigger that's also been capped.  And
also, a TLV parsing bug for a BOLT12 offers that could basically let an
attacker create a malformed message that could crash CLN, that is also fixed.
So, multiple crash scenarios in this one.

**Mike Schmidt**: It's crazy how many Lightning bugs, at least recently,
including I think one or both of the ones that I'm summarizing for next week's
newsletter, but other ones that we've covered in the past, is just unbounded
growth of things or not having length-checking on certain things.  It seems
like that's what a lot of what that PR did.  Obviously, it doesn't solve
everything, but it's obviously some low-hanging fruit to put some limitations
on how long certain strings or things can be, and how large a queue can grow.
I think we had the LND gossip that grew infinitely.  So, yeah, it's just good
to see that it's being fixed, but it's crazy how many are around that sort of
genre of bug.

**Gustavo Flores Echaiz**: Yeah, implementing Lightning is hard and all nodes
require so many different entries on communication systems, because in the end
there's simply no shared data like the blockchain in the Bitcoin Network.  So,
nodes in the LN, they have to agree about everything and communicate
everything.  So, that creates so many different entries for these types of
vulnerabilities, from my understanding.

The final part of this PR is that I/O logs, input/output logs, are removed
from getlog, because it could contain authentication tokens that grant
restricted RPC access.  So, also, a logging cleanup to not disclose
unnecessary credentials.

_Core Lightning #9513_

The next item, CLN #9513, this is a simpler one.  This fixes amount validation
when fetching an invoice with xpay for BOLT12 offers.  Basically, previously,
after making an invoice request to a node and fetching an invoice, CLN would
simply not check the amount, it would allow the recipient to request a larger
payment.  Now, the invoice must either match the requested amount or it cannot
exceed the offer amount, so it is now capped by the requested amount or the
offer amount if no amount was requested.  Previously, you could simply get a
node to tell you, "Pay me this invoice," of whichever amount, and if you were
not careful enough, you might just pay a higher amount than the amount you
requested.  Also, onion messages that contained a reply path with no hops are
also now prevented.  Any node could technically send you this and it would
stop your node, because a reply path with no hops simply makes no sense.  So,
now, that is blocked too.

So, yeah, that's the last item of the five CLN items.  So, now we know what
happened better in the past few weeks with the whole security issues in CLN.
But now, like I mentioned earlier, there's an even newer release, so users
should upgrade to that newer release.

_LND #11198_

The next three items come from the LND repo.  The first one is related to AMP.
So, AMP, Atomic Multipath Payments, are the implementation in the LND repo,
not to be confused with multipath payments that are a BOLT standard.  If I'm
not mistaken, I believe MPP is the standardized version between multiple
implementations, while AMP is the implementation of LND itself.  I think LND
has support for both, but AMP is only in LND.  So, the point here is, how AMP
works differently from MPP is that as a receiver, I generate an AMP invoice.
So, it's not like this is just a regular BOLT11 invoice.  In this scenario,
you can also do Keysend AMP.  You don't have to generate an invoice, you could
also do spontaneous payments with AMP.  But in this scenario, I, as a
receiver, generate an AMP invoice.

An AMP invoice can be paid multiple times.  And like MPP, an AMP payment gets
split into multiple parts, into different routes, and arrives to the
recipient.  However, like I said, a generated AMP invoice can be paid multiple
times.  So, here, the problem was if I, as a receiver, I could potentially
cancel the invoice and interfere with all potential payments if one payment
failed.  So, if one part of one payment attempt failed, I would simply cancel
both my AMP invoice, and if other people were trying to pay me at the same
time to that invoice, their payments would also fail.  However, I should only
fail the attempt that failed, not all attempts.  So, now, LND fails the
arriving HTLCs, cancels the previously accepted HTLCs belonging to the failing
set, but the invoice remains payable, so other accepted sets can still be
completed and settled.

_LND #11146_

The next item, LND #11146, this is about the latest in the BOLT12 offers
implementation in LND.  So, we've been covering this over the past few
newsletters.  In Newsletter #422, we covered support for signing and verifying
invoice requests and invoices for BOLT12.  And now, we have validated string
encoders and decoders for offers, invoice requests, and invoices.  So, we're
getting closer.  There's still a ton of work, but we're getting closer.  Now
there's a new function, ValidateInvoiceForPayment, which checks an invoice
against the originating request, but also the node that payer expected to sign
it.  So, it has to match the receiver signature, it cannot just be issued by
any node.  Technically, any node along the blinded path could otherwise return
an invoice signed with its own key, so it's very important to verify that this
was signed by the receiver, the real receiver.

**Mike Schmidt**: I was curious, since we've seen this progression of BOLT12
in PRs, do they have a tracking issue?  I always find those good to put things
in context of what's done and what's coming and what's being worked on and
needs review.  Do you know if they have one for BOLT12 in LND?

**Gustavo Flores Echaiz**: Yes, they do have one.  It's issue #10736.  That's
the issue number that has all the related steps to get to the full BOLT12
implementation.  And I'm looking at it right now.  I'm seeing that the codec
part, so the BOLT12 package for messages and data structures, that is almost
done.  There's simply one left to merge, finalize the codec package.  But
about ten items have already been merged for the basics for the message and
data structures.  And now, the next work, which already has an open PR, is a
receiver side.  However, that's only the first item of the receiver side.  So,
there's still a lot of work to be done, right?  Then, once the codec part, the
message and data structures part, which is almost done, once that is done,
that is milestone A, then there's milestone B: receiver side; milestone C:
sender side; multi-hop is D; pay offer is E, and RPC parity is F.  So, still a
very long way to go, but the first milestone is almost complete.

**Mike Schmidt**: Okay.  Yeah, cool.  I have that up now, I'm taking a look at
it.  Thanks, Gustavo.

_LND #11132_

**Gustavo Flores Echaiz**: Pleasure.  I'm going back to the newsletter now.
And the last item that we have in this newsletter is LND #11132.  Here, this
is a follow-up to something we had discussed in Newsletter #421.  So, the goal
of this new item is to restore BOLT1 compliance by replying to every valid
ping message admitted from peers.  Why does LND need to restore that BOLT1
compliance?  It's because in Newsletter #421, we covered that LND had added
rate limits for inbound ping messages, and also request buckets and reply
buckets for ping messages and pong replies.  So, it was rate-limiting those
messages and it had kind of dropped compliance with BOLT1 that requires LND to
reply to every valid ping message.  So, now that compliance is fully restored.
So, now LND has at the same time the rate limits, but it will also properly
reply to every valid ping message that is admitted by its flood policy.  So,
that's the final item in this newsletter.

**Mike Schmidt**: Awesome.  Thanks, Gustavo.  We also want to thank Jan for
hanging on throughout the remainder of the newsletter and joining us for the
Bitcoin Core 32 RC and testing guide item.  We also want to thank Ahmet for
recording and sending us his thoughts and progress on post-quantum Lightning
work.  And we want to thank you all for listening.  Cheers.

{% include references.md %}
