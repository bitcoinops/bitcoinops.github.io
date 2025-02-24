---
title: 'Bitcoin Optech Newsletter #340 Recap Podcast'
permalink: /en/podcast/2025/02/11/
reference: /en/newsletters/2025/02/07/
name: 2025-02-11-recap
slug: 2025-02-11-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Matt Morehouse, Johan
Halseth, Pieter Wuille, Sergi Delgado, Bastien Teinturier, Oleksandr Kurbatov,
Antoine Poinsot and Bob McElrath to discuss [Newsletter
#340]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-1-14/394895716-44100-2-05b85e7e5d0d2.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #340 Recap on
Riverside.  Today, we're going to talk about an LDK vulnerability;
zero-knowledge LN channel announcements; research from the 1980s that could
apply to cluster mempool; we have a bunch of updates on Erlay; we're going to
talk about how ephemeral anchors can be used in LN commitment transactions; how
we can emulate an OP_RAND opcode; we have discussion about lowering the minimum
transaction relay feerate; and we also have a monthly segment this week on
changing consensus, that we have news items on updating updates to the consensus
cleanup soft fork, covenant designs for Braidpool, deterministic transaction
selection for block templates, and difficulty adjustments in a directed acyclic
graph-based blockchain.  And then, we have our normal segments on Notable code
and documentation changes and Releases.  I'm Mike, contributor at Optech and
Executive Director at Brink.  Murch.

**Mark Erhardt**: Hi, I'm Murch, I work at Localhost, and yeah, that's it.

**Mike Schmidt**: Matt.

**Matt Morehouse**: Hi, I'm Matt Morehouse, I've been working on the LN with a
particular interest in security.

**Mike Schmidt**: Johan?

**Johan Halseth**: Hi, I'm Johan, I do open-source research and development for
NYDIG.

**Mike Schmidt**: Bastien?

**Bastien Teinturier**: Hi, I'm Bastien and I've been working on the LN with
ACINQ for two years and other specifications.

**Mike Schmidt**: Oleksandr?

**Oleksandr Kurbatov**: Yeah, I'm the lead of cryptography at Distributed Lab.

**Mike Schmidt**: Antoine?

**Antoine Poinsot**: My name is Antoine Poinsot and I work at Chaincode Labs.

**Mike Schmidt**: Bob?

**Bob McElrath**: I'm Bob McElrath, I'm working on Braidpool under a grant from
Spiral.

**Mike Schmidt**: Thank you all for joining us.  I think we may have a couple of
additional special guests later in the show, so stay tuned for that.  We're
going to start with the News section.  We may go slightly out of order as
there's a couple of PRs that some of our special guests would probably do a
better job of explaining than Murch or I.  So, apologize for the deviation
there.

_Channel force closure vulnerability in LDK_

First news item, "Channel force closure vulnerability in LDK".  Matt, thank you
for joining us again this week.  Last week, we had you on to discuss your LDK
invalid claims liquidity griefing disclosure; and this week, we covered your
disclosure titled, "LDK Duplicate HTLC Force Closing Griefing".  So, if folks
are curious about the previous disclosure, obviously that would be #339 and
Podcast #339.  Matt, maybe talk a little bit about what we covered this week,
even though I think you actually disclosed it before the show last week.  So, I
don't know how much you guys jumped into it, but maybe we can jump into it
deeper this time.

**Matt Morehouse**: Yeah, last week we kind of just gave an overview.  But high
level, this vulnerability was fixed in LDK 0.1.1.  And prior to that, an
attacker could open a channel with the victim, route certain payments to
themselves through the victim's other channels, and then force close their
channel with the victim in a specific way, and that would prevent LDK from
failing all those payments upstream.  So then later, when those HTLCs (Hash Time
Locked Contracts) timed out upstream, the upstream nodes would force close all
their channels with the victim.  And this could be done for relatively low cost
and could be a massive griefing attack against big routing nodes.  And I'm happy
to answer any specific questions or to just go into more detail about the
vulnerability and the attack.  What would you guys like?

**Mike Schmidt**: I don't know if anyone has a question, so I think maybe you
can jump into the details and maybe that'll stimulate some discussion.

**Matt Morehouse**: Sure, so the vulnerability deals with a lot of the specifics
of when a channel force closes.  So, we've got to understand a little bit about
what goes on there.  When a force close happens, it means one of the commitment
transactions for that channel was broadcast and confirmed.  And if there was any
HTLCs on that commitment transaction, it's important that your LN node has a
mapping from those HTLCs to any upstream HTLCs that are associated with them.
And the reason for this is your node needs to resolve the upstream HTLCs in the
same way that the downstream HTLCs get resolved.  So, if your downstream
counterparty is able to claim one of those HTLCs onchain using a preimage, your
node needs to be able to extract that preimage from the transaction and use it
to claim the HTLC upstream, or else you end up losing the value of that HTLC.
Likewise, if your node's able to recover the HTLC downstream using a timeout
transaction, your node then needs to fail back the HTLC upstream, or else
eventually that node is going to force close the channel to recover that HTLC.

So, the key here is there has to be this mapping between HTLCs that show up on
the commitment transaction onchain to then the upstream HTLCs that match them.
And there's an additional thing that needs to be considered when a force close
happens, in that if the HTLCs that end up on the commitment transaction onchain
do not perfectly match up with the current set of outstanding HTLCs, your node
needs to be able to handle that.  So, obviously, if the latest commitment
transaction confirms that the HTLC sets should be the same, but if the previous
valid commitment confirms or any revoked commitment confirms, then the HTLCs
could be very different from what you would expect to currently be active.  So,
your node needs to handle that case, it needs to recognize if any HTLCs are
missing from the commitment that it confirmed.  It then needs to fail those back
upstream, or else again, that upstream node is going to eventually force close
the channel to recover that HTLC.

So, this is what LDK does for all the valid commitment transactions.  However,
once a commitment gets revoked, LDK purposely forgets this mapping from HTLCs on
the commitment to upstream HTLCs.  And the reason for that is, there can be an
unlimited number of revoked commitment transactions and they don't want to store
this data forever.  So, instead, what LDK does when a revoked commitment
confirms is they try to match based on the payment hash and the amount of each
HTLC.  And that works most of the time, but the problem is payment hash and
amount are not necessarily unique.  And in fact, it's expected in some cases to
for it to not be unique because, for example, multipart payments, you split up a
payment across many HTLCs, they all have the same payment hash, they could have
the same amount too.  So, the unfortunate thing about the way LDK did this
matching was it could be tricked in a specific way.  An attacker could route
many duplicate HTLCs through upstream channels, and then on their downstream
channel, they could force close it and only have one of those duplicate HTLCs on
that commitment.  And if that commitment would be revoked, there would only be
one downstream HTLC, there'd be many upstream matching HTLCs.

In this particular case, LDK would keep all of those upstream HTLCs active
instead of failing them back immediately, so that one downstream HTLC would keep
all of them, it would match with all of those upstream HTLCs.  And this alone is
not necessarily a problem.  But the big problem comes later when that downstream
HTLC is resolved onchain, which is probably going to be claimed by LDK with the
revocation key.  Once that happens, LDK would only fail back one of the upstream
HTLCs instead of all of them.  And so, all the rest of those upstream HTLCs
would get stuck, and eventually the upstream nodes would force close those
channels with the victim.  Now, since the attacker had to broadcast a revoked
commitment transaction, they would have to forfeit their channel balance in that
downstream channel.  But assuming that they're smart, that channel would have
been minimal to begin with, basically as small as the victim would allow them to
open a channel.  And then they would have pushed 99% of that value to the other
side of the channel before doing this attack.  So, we're talking very, very low
cost on this attack, maybe like a dollar or two potentially.  And then you can
force close all the victims' channels.  Does that all make sense so far?

**Mark Erhardt**: Yeah, that's great.  Now that we have t-bast on, I'm wondering
what he thinks about all this?

**Bastien Teinturier**: Yeah, this is interesting because this bug already
existed, if I remember correctly, in LND a long time ago, and it was already
discovered a very long time ago and fixed, but maybe we did not announce it, or
maybe we did.  I'd have to dig up.  I think it is something I found.  And if we
found it and announced it, and it was still incorrectly implemented in LDK, or
at least not sufficiently tested, then it means we really need to have a DB of
vulnerabilities we found over the years, so that everyone coming in can make
sure that they have test cases for those things.  I think we eventually even
changed the test in the spec for that, but maybe that was missed.  I'll have to
dig it up and verify if that's the case or not.

**Matt Morehouse**: Yeah, if that's the case, that's really unfortunate.  The
interesting thing too about this is, originally LDK didn't have this bug.
Originally they did the conservative thing where when a revoked commitment
confirmed, they would immediately fail back all the outstanding upstream HTLCs.
And so, there was no way for the HTLCs to get stuck, and this is perfectly safe
to do.  I believe LND does this; I would assume Eclair does something similar.
But since you can claim the full value of the downstream channel with the
revocation key, you're not worried about losing out on those upstream HTLCs, you
can just fail them back, and that's the safest thing to do.  And it's very
simple to do.  It was a later change that got introduced, where they tried to
get a little fancy and maybe profit from some of these upstream HTLCs in a very
corner case.  So, that's too bad.

**Mike Schmidt**: Matt, how did you discover this vulnerability?  Is this
something that you were looking at the intricacies of the code and found it that
way, or did you do fuzz testing on this, or how did you uncover it?

**Matt Morehouse**: Yeah, this is a lot like the last vulnerability.  I was just
reviewing the chain module in LDK, so just reading the code carefully, and saw
this behavior and thought, "Well, that matching based on payment hash and amount
doesn't seem super-robust", so then looked into it more and discovered that this
kind of attack could be done.

**Mike Schmidt**: Murch, anything else you think we should cover on this one?
Okay.  Matt, thanks for joining us again this week.  Anything else you'd like to
note on this vulnerability before we move on?

**Matt Morehouse**: Yeah, let's just, I guess, talk about prevention.  So, I
think in this particular case, the conservative thing was done originally, the
safe thing was done, and then a later change eliminated that.  I think it really
points to a problem in not documenting the original reason for the behavior.
And maybe this goes back to what Bastien was saying about maybe the original
author was aware of this bug in other implementations and implemented it in a
certain way because of that, but there was zero documentation of why that
decision was made.  So then, a later contributor came along and was like, "Well,
this doesn't seem very smart.  We could do better in this case".  And they,
what's the proverbial saying, they found a fence, they didn't know what the
purpose was, and they knocked it down.  And I think it would have been much
better if whoever built that fence had just written a sign on it that said,
"This is why I built this fence", and then nobody would have to worry about not
understanding why it was built.

**Mark Erhardt**: I think that's Chesterton's fence.

**Mike Schmidt**: That's right.

**Mark Erhardt**: You're only allowed to remove a fence if you understand why it
was built.

**Bastien Teinturier**: And I think that we should also do a better job at
offering end-to-end kind of spec tests that should at least easily run against
all implementations, or they should be easy to implement in their implementation
because they should be easy to read and translate into code.  There was an
effort doing that a while ago with a framework that Rusty started, but he then
was abandoned.  And there was something called lnprototest, and the goal was to
do exactly that, but I think it's the same; it's on hold and not really used.
But something we can do, and that I started doing for the splicing spec, is at
least showcase examples of protocol runs, the flow of messages that could be
exchanged, especially in tricky edge cases, and the expected outcomes so that
everyone implementing the functionality also implements those tricky edge cases
and verify that that could be hit correctly.  If we had done that for this
specific example, and it was somewhere in the spec where everyone can find it, I
think this would have prevented it.

**Mike Schmidt**: It sounds like there's a couple of different suggestions.
One, having a more robust spec suite of test cases; and then also it's
mentioned, and I think at LND, we talked about this, Murch, a couple of weeks
ago, didn't LND have -- or was it BDK?  I forget -- some sort of a design
documentation, design decisions.  They started documenting why they made this
decision or that decision.  And that would be maybe project-specific, and then
maybe there's this test suite that would more broadly cover certain other
things.  Do you remember that?

**Mark Erhardt**: Yeah, it was BDK with the architectural design documents, ADMs
or something.  No, that doesn't match up.  But anyway, yeah, it was BDK.  And we
also have something similar with the BIPs, where BIPs that specify technical
features tend to have test vectors, and if there's bugs found, we add them to
the test vectors.  I guess that's, of course, what the BOLTs are for Lightning.

Good discussion.  Matt, thanks for joining us.  You're welcome to stay on, or if
you have other things to do, we understand you're free to drop.

**Matt Morehouse**: All right, I'll stay on for now.

_Zero-knowledge gossip for LN channel announcements_

**Mike Schmidt**: Next news item, "Zero-knowledge gossip for LN channel
announcements".  Johan, you posted to Delving about a proposed extension to the
Lightning Gossip v1.75 proposal, the taproot gossip proposal.  Your proposed
extension would have the effect of not revealing which UTXO is the funding
transaction, providing additional privacy.  But I think it's interesting how you
propose to achieve this.  Why don't you get into that a bit?

**Johan Halseth**: Yes, so this research stems from a tool I made earlier this
year, where you could prove that you control some taproot output in the UTXO
set.  And I realized, when I started looking at the proposal for taproot gossip
announcements for Lightning, that it was pretty easy just by adding MuSig2
support to that tool, that you can actually take the channel announcement more
or less as it is, and then do the signature verification in a zero-knowledge VM,
and then post a proof of that signature verification.  And that essentially
gives you a way of proving that some taproot channel announcement is valid
without revealing which output it's referring to.  And this builds on the RISC
Zero project, which is a way of running Rust or C code in a ZK VM and prove the
execution of that, and also utreexo, which I used to prove the actual inclusion
of that final taproot key in the UTXO set.  And by adding this, or by doing this
verification in zero knowledge, then you create a trace of that verification and
you post a proof of that as an extension to that taproot channel announcement,
and obviously revealing the private information from the message.

**Mike Schmidt**: How has reception been to the idea of this extension?

**Johan Halseth**: Well, it has gotten a lot of discussion, so it's been great
to see.  There's obviously something people want in Lightning, a way of not
tying out onchain outputs to channels, but still there's some discussion around
the efficiency if the proving time is too long, as it currently is, and also the
verification time.  And also, this uses some pretty new cryptographic
assumptions and tooling, so there's also a question whether it's too early to
add something like this, if the tool chain is mature enough, or if there are
some other schemes involving, for instance, ring signatures that could achieve
the same thing without building on untested cryptography.

**Mark Erhardt**: I was wondering when I read your news item, it would of course
be possible to use one UTXO to sign for multiple channels.  Is that just
prevented by using actually the channel UTXO and the counterparty only signing
this announcement if the correct UTXO is used, or is there some other mechanism
to prevent using the same UTXO to announce multiple channels?

**Johan Halseth**: Yes, so in the proposal I have, since the taproot output key
is actually an aggregation of two Bitcoin keys, the keys of the of the two
counterparties, you actually do also prove in zero knowledge or you hash those
two keys in zero knowledge, and you output the hash of those keys.  That means
you cannot reuse those same keys for a different proof.  Waxwing did comment
that this feels a bit flaky, since you kind of treat the public keys as private
information in that case, but it's a way of giving a unique fingerprint of that
output without revealing the final MuSig taproot output key.

**Mark Erhardt**: Yeah, that's pretty sweet.  But would that change if you used
the two keys in reverse order, so you could use it twice?

**Johan Halseth**: You could, but that would also give you a... Well, you
couldn't really do that because you also require, in zero-knowledge, that
they're sorted.  So, you will sort it before you do hashing.

**Mark Erhardt**: You thought of everything!  Thank you.

**Mike Schmidt**: Bastien, did you get a chance to look at Johan's post and your
thoughts on it?

**Bastien Teinturier**: I don't have a lot of thoughts on that yet, because it's
great that there's work on this.  The main barrier, in my opinion, is when do we
have a library that we can safely import in everyone's implementation, because
here that would require bringing dependencies and a lot of fancy cryptography
implementations that we probably haven't reviewed all the way to the RISC Zero
thing.  That's quite a lot of work to make sure that we can safely integrate
those.  But on the other hand, this is not on the critical path, meaning an
issue here is not critical, doesn't impact on safety at all.  So, maybe it's
okay, or maybe it's okay to just offer that as a service, that public service
that people can just query, or something like this.  I haven't looked much yet
into it.  I haven't looked much into gossip stuff for a while, but I'll look
more into it in the future.  But I think it's interesting that Johan is working
on it and showing that some progress is being made.

**Johan Halseth**: Yeah, I think one of the interesting things to note here is
that, since you can more or less take the original channel announcement and then
use this tool to convert that to a proof of that channel announcement being
valid, then you can do what Bastien is saying here.  You can kind of give your
announcement to some server or someone and they will create a proof for you, and
then you can start broadcasting this.  Obviously, for those verifying these
channel announcements, they also would need some way of verifying them, and that
means that depending on some code, that might not be mature enough at the
moment.  But luckily also, the verification code is much simpler than the
proving code.  So, it's definitely a consideration we have to make, whether this
toolchain or this code is mature and reviewed enough before we start importing
it.  But worst case, if there's some break, something wrong with the
cryptography there, worst case you get back to the current state of things where
you are able to find the link between the onchain output and the channel.

**Mike Schmidt**: Johan, it sounds like there's been quite a bit of activity on
the Delving thread already.  It sounds like maybe the call to action for the
audience would be, if you're curious about this, jump in and opine on Delving
and maybe provide some feedback there?

**Johan Halseth**: Yeah, definitely give your feedback on whether something like
this is viable.  There's been some discussion on the performance there.  Since I
posted that, I've already been able to get the proving time down significantly,
but it would be cool if people tried out the code and check whether their
hardware is able to produce those proofs, because currently it requires some
quite beefy hardware in order to efficiently make these proofs.  But the most
important thing, at least in my opinion, is that the verification time is small,
since when you create these messages, potentially all nodes on the network will
have to verify them.  So, verification is where we should probably optimize the
most.

**Mark Erhardt**: Cool, thank you for getting into that.  It sounds really
exciting to me that we might have a way now to disintermediate the proof that
the channel is funded versus knowing exactly what UTXO that is.  And especially
if we are moving to taproot channels with MuSig now, channels would most of the
time when they close cleanly, collaboratively, not even look like 2-of-2
transactions obviously.  So, all together, this is really exciting how things
are getting together.  It sounds to me like Bastien had a follow-up to the
previous topic.  Do you want to chime in?

**Bastien Teinturier**: Yes, I was looking at old mail revealing vulnerabilities
close to that.  I could find one from 2021 that was somewhat related to that,
but more regarding batching of HTLC claims.  But I also remember something that
looked more like Matt's, but apparently was never revealed, or maybe we all
patched it and never revealed it.  I'll have to look at if there was private
discussions about this.  I couldn't find any, so maybe it's just my memory that
is bad.  But I'll try to find more details afterwards.

**Mark Erhardt**: Well, so it might sound like Matt did find a completely new
vulnerability that was just similar.  But either way, I guess this is still a
developing story, so we'll report on that later more.

**Mike Schmidt**: Johan, thanks for joining us.  You're welcome to stay on, or
we understand if you have other things to do.  We have additional special guests
who have joined us.  We'll start with Pieter.  Pieter, who are you in Bitcoin?

**Pieter Wuille**: Hi, yeah, I've been working on Bitcoin for a while, on a
number of things.

_Discovery of previous research for finding optimal cluster linearization_

**Mike Schmidt**: Excellent.  Thank you for joining us just in time for the news
item that we wanted to have you on for titled, "Discovery of previous research
for finding optimal cluster linearization".  Pieter, Stefan Richter posted a
reply to your, "How to linearize your cluster", Delving Bitcoin thread with a
bit of computer science archaeology.  What did he and the AIs find?

**Pieter Wuille**: So, to recap, we've been working on this project called
cluster mempool, which is about partitioning the mempool into groups of related
transactions, which we individually keep in the order we would mine them at a
time, so we can reason about them much better for mining eviction, but also
decisions like RBF; all of that comes together if we just know what order they
need to be mined in.  And from that, of course, the obvious question is, if
we're going to simplify the structure and group these transactions into probably
small groups of transactions, can we do better than the existing mining
algorithm, which is ancestor-set-based?  It's a quadratic algorithm we've been
using for deciding the order of transactions; we're now working with much
smaller groups, so can we do better?  And this led to a line of thinking where,
like, a year ago or so, maybe longer by now, I came up with this heuristic
exponential search algorithm that can explore various orders better than
naively, and that all sounded great.  I made a big post on Delving about this,
like, "Okay, here's the algorithm I came up with.  It's still exponential,
unsure, does maybe a polynomial time algorithm for this exist?  No idea".

Fast forward to a couple months ago, where we held the Bitcoin Research Week at
Chaincode, where we invited a number of academics as well as implementers and
other enthusiasts to do sessions on a number of topics.  There was a lot of
interest in this.  We did a couple of sessions on cluster mempool and two of the
people attending, Dongning Guo and Aviv Zohar, pointed out actually, this is a
linear programming problem, which means that the entire subdomain of computer
science about linear programming solving algorithms instantly became applicable
to our problem.  And among other things, this conclusively meant that a
polynomial time algorithm existed, maybe not a very good one, but there exist
polynomial time LP algorithms.  So, okay, that was a breakthrough, started
iterating on that.

After a number of iterations and discussions, we came up with a better
algorithm, started implementing this, and then Stefan Richter posts on Delving
Bitcoin, in a response to my old thread about the old algorithm, he said just,
"I asked DeepSeek-R1 and it told me about a paper which not only describes the
exact problem we're trying to solve, it has basically a cubic algorithm for
solving it from 1989, and even earlier ones that are somewhat less efficient
going back to the 1960s and 1970s".  So, yeah, now we're looking into this, see
what that would entail, how well does that fit in our design, is it practically
actually faster than the previous approach I'd been working on?  My guess is,
yes, it will be.  But these papers, of course, talk about asymptotic
complexities.  So, they say like, "As the number of", in our setting,
"transactions and dependencies goes to infinity, how quickly does the runtime of
this algorithm change?"  And that's good to know, of course, but in practice, we
don't care about an infinite number of transactions.  We care about the number
somewhere between the range of 50 and 100 maybe.

So, we really care about how well does it behave for exactly those sizes of
inputs, and the constant factors may matter there a lot.  Also, there are
considerations like, even though these algorithms are way faster, probably in
the worst case than the worst case of the previous algorithm or algorithms,
they're probably not fast enough to always linearize every cluster optimally, or
at least not add relay time, because we want to make a decision very, very
quickly when a transaction is being relayed, mostly because an individual
transaction can affect many clusters, and so we'd need to re-linearize all of
them.  So, the amount of time we can have guaranteed available for one isn't all
that much, and so probably not enough to linearize everything optimally in an
adversarial setting where someone may intentionally create clusters that are
hard to linearize even.  And so, with that, we'll need to make some trade-offs,
and not every algorithm can be just interrupted at any time.

So, lots of interesting discussion going on.  I really enjoyed the back and
forth between people asking and pointing things out, finding other papers that
potentially improve upon it.  But in the end, it will boil down to trying to
implement it and seeing.

**Mark Erhardt**: So, that was all a little abstract, and we've heard some
rumors about cluster mempool in the past year or so.  My understanding is that
your first approach is actually implemented already, and I think you've merged
to Bitcoin Core?

**Pieter Wuille**: Yes.

**Mark Erhardt**: So, in practice, all of this discovery of ancient papers
solving all your problems, how much will that affect us downstream?

**Pieter Wuille**: So, right now in Bitcoin Core, we're working on getting
cluster mempool merged.  At this point, that will probably not happen for 29.0,
but it may happen for 30.  I think we've got good momentum there going, but that
is all using the first generation of algorithms, so to speak, which are still
exponential.  And so, that is already merged, as Murch said, we're building the
layers on top of that.  There's an intermediary layer dealing with representing
the mempool as a graph, and then there will be the actual changes to the mempool
and policy and validation, and so on, to use it.  But all of that is using the
old algorithms.  And after that, it will basically be a drop-in replacement if
it looks good enough, and I very much expect that it will be.  So, there's no
rush at this point to get all these new discoveries in.  The first iteration
will probably just use the old approach, well, "old" between scare quotes.  But
after that, there are some potential interactions, because the current algorithm
needs some information about transactions pre-computed.  These new algorithms
might not need that, which means we may get rid of some of that pre-computation
and doing so may enable more things.  But as a first approximation, I think we
can just think of it as a drop-in replacement.

**Mark Erhardt**: So, that would make it faster?  That might mean that we can
process bigger clusters at relay time, or we might be able to process bigger
clusters at least at the lazy evaluation time?

**Pieter Wuille**: I don't think so.

**Mark Erhardt**: No?  Okay.  Just drop-in replacement, that's faster?

**Pieter Wuille**: The result will be that probably an even larger fraction of
clusters will be linearized optimally.  But in terms of size of clusters, really
our target is making sure that every cluster can be linearized up to some
ill-defined, acceptable quality level.  And so far, we've thought of that
acceptable quality level as ancestors or the old algorithm, and that is still
way faster than anything these papers do.  And so, given that we want to support
at least groups of up to 50 transactions in order to not break things that work
right now, it will probably mean that these algorithms will never be guaranteed
to be able to find optimal for the sizes we're talking about.  And it's a good
question.  Like, maybe we can get rid of the ancestor sort entirely.  Maybe,
inspired by these algorithms, there's a more approximate one that doesn't
guarantee optimality but results in something better than ancestor sort in less
time than ancestor sort, that would be a great outcome, but really don't know at
this point, I think.

**Mike Schmidt**: Only tangentially related, but there was a PR Review Club on
one of the cluster mempool PRs in the last week.  I think we'll probably be
covering it in the newsletter forthcoming, but I thought that Gloria did a great
set of notes for the writeup that are already available, even if you just want
to take a look at those and not the actual session itself.  I thought, if you're
curious about cluster mempool, that's an interesting place to click deeper.
Obviously, we've covered a bunch of Pieter's Delving posts, which also get into
a lot of the nitty-gritty as well.  So, there's lots of resources around cluster
mempool for folks that are curious.

**Pieter Wuille**: Yeah, absolutely.  And I believe there may be a follow-up
Review Club as well.

_Bitcoin Core #21590_

**Mike Schmidt**: That's fine.  Pieter, thanks for joining on that news item,
but also, we are going to tap you in and go to a Notable code segment diversion
for your wisdom here.  Bitcoin Core 21,590, a PR titled, "Safegcd-based modular
inverses in MuHash3072".  Pieter, what?!

**Pieter Wuille**: Okay, let me explain two words in that title.  MuHash is a
UTXO set hash construction that I came up with a number of years ago, and that
is being used in Bitcoin Core's gettxoutsetinfo RPC command, which computes,
like, you want to compare your UTXO set, this is the same as on another node,
you don't want to compare the entire database.  So, you can run that command on
both and it will internally compute this MuHash thing.  The nice thing about
MuHash is that it can work incrementally, so you don't need to start over from
scratch for every time you compute it.  You can sort of add to it and subtract
to it any time a UTXO is added or removed.  And so, there's a very fast
operation to update it, and then another slightly slower operation to finalize
the MuHash state and get an actual hash out.  And so, I think you can enable an
index that computes this UTXO hash for every block and then just remembers it,
and then you can spit it out for every block rather than needing to compare at
the tip.  This is something that only, like, it would take minutes to compute a
hash from scratch for the entire UTXO set.  But this is instant because it's
just every UTXO update, you just update it.

In that finalization operation, there's a mathematical algorithm that needs to
be determined, namely a modular inverse.  It's two big numbers and you want to
sort of solve ax = b (mod m) some giant number and solve for x.  That modular
inverse is something that's used in a number of things.  Another place that's
used is inside libsecp for signing and verification.  Modular inverses appear
there too, though somewhat smaller ones.  There we use 256-bit ones; in MuHash,
3072.  You will never guess, we need a 3072-bit one.  And so, we had this great
development a number of years ago where when we were implementing a new
algorithm for computing modular inverses in libsecp, contributed by Peter
Dettman initially, we were working on this.  This was a new way of computing
modular inverses in a faster way that came from a recent paper at the time from
2019, I think, by Daniel J Bernstein and Bo-Yin Yang, and we're implementing
that.  And Greg Maxwell was trying to break the code and the test, seeing if the
test coverage was okay.  So, he was semi-automatedly trying to introduce bugs in
the code and see if the tests caught it.

He found one that the test didn't catch, and long story short, it turned out to
be faster.  Rather than not just, it didn't break the code, it was just randomly
stumbled upon, like turned this 1 into a 2, or turned this 'greater than' into a
'greater than or equal', things like that.  He was trying many of those, and
found one that didn't break and was actually faster, and we were even able to
prove that it was faster.  So, that became at the time, and perhaps still, the
world's fastest modular inverse algorithm randomly stumbled upon.  And so, after
implementing that modified algorithm in libsecp, this PR is using the same
improved safegcd-based algorithm for computing the modular inverse in MuHash.
And as a result, the finalization step of computing in MuHash is 100 times
faster.  Now, that isn't all that important because we don't use MuHash for too
many things, but it goes from the order of milliseconds to microseconds.

**Mike Schmidt**: Am I right to understand that Greg Maxwell, was it mutation
testing that he was …

**Pieter Wuille**: Yes.

**Mike Schmidt**: So, he was doing mutation testing and discovered a 100x
improvement somehow?

**Pieter Wuille**: No, no.  It's something like a 20% to 30% speed up for
safegcd.  This is switching the modular inverse algorithm from a naïve way of
doing it to the safegcd one, and that is a 100x improvement.  If we used the
original safegcd, maybe it would have been a 70x speed up already, but this
modified one is even a bit better, something like that.

**Mike Schmidt**: Now when you were explaining MuHash, what came to mind for me
was utreexo.  Is there something similar going on there?

**Pieter Wuille**: They're both utreexo commitment schemes, though they have
very different properties.  In particular, MuHash doesn't support any kind of
inclusion proofs.  So, there is no simple way of proving, "Here is a MuHash hash
for the UTXO set, here is a proof it contains a particular UTXO".  You can of
course do that with any generic proof scheme, but it is not particularly
optimized for that.  The goal is just quickly computing a hash, you can compare
the hash, that's it.  There are applications where this is useful, where you
just want to check, "Do I have the same UTXO set as you do?"  It is not useful
for speeding up validation or bypassing transmitting certain data or things like
utreexo are trying to achieve.

**Mike Schmidt**: Thanks, Pieter.  Well, thanks for walking us through that news
item and that PR.  Yeah, Murch, my notes were totally the same as what Pieter
had for this PR.  So, yeah, good!

**Mark Erhardt**: Yes, I also understood some of these words!

**Mike Schmidt**: All right, Pieter, thanks for joining us.  You're welcome to
stay on if you'd like, or you're free to drop.  We understand you have other
things to do.

**Pieter Wuille**: All right, thank you.

_Erlay update_

**Mark Erhardt**: The next topic is Erlay, though.

**Pieter Wuille**: Oh!

**Mike Schmidt**: That means we have another special guest, who should introduce
himself.  Sergi?

**Sergi Delgado**: It's all about the special guests today, it looks like.  Hey,
guys.  I'm Sergi, I've also been working on this space for a while, definitely
not as long as Pieter, but I'm currently working on something that he, Greg,
Gleb, and some others came up with a few years ago, which is Erlay.  I think
you've covered Erlay before in the Optech, haven't you?

**Mike Schmidt**: Yeah, we have, although it may have been a while, so it might
be worth giving sort of an executive summary of what Erlay is, and then we can
jump into some of the work you've done.

**Sergi Delgado**: Right.  You can hear me well now, right, like before going
through the whole explanation?  Okay, nice.  So, Erlay is a different
transaction relay protocol than the one that we are using currently in Bitcoin
Core.  I mean, to make things simple, the current approach is a more invasive or
more broadcast-based approach, where when you learn about a transaction or
create a new transaction, you try to announce this to all of your peers to make
them aware that something new has been created in the network.  And then, if
they are interested in this transaction, they will request it back, and then at
some point you will send it.  So, basically what you're doing is like, "Hey, I
have this new thing, I don't know if you know about it".  Your peers may be
like, "Hey, actually, I don't know about that, and I would like to know about
it", and then you deliver it.  And the reason why this works in this way is to
prevent just sending a big blob of data if your peers are not interested in it,
right?  So, you first send a small announcement.  If they are interested in
that, then they're request it.

There are some peculiarities here.  Like, the way you exchange this with your
peers depends on whether those peers are outbound or the connection has been
started by you or whether they are inbound or if they are the ones that have
started the connection.  But long story short, the issue with this protocol, the
one that we've had forever, is that it has a lot of redundancy.  So, at the
beginning, it may not be as such, right?  If you are the one who has created the
transaction, the first, let's say, burst of this announcement is basically peers
learning about something new.  But at some point, everyone is going to be kind
of telling everyone else, "Hey, I know about this new thing, do you know about
this thing?"  And after the first n hops, let's say, this information is going
to be redundant for most of the network.  But you don't know who knows about the
transaction, so you have to keep doing this up until the transaction has reached
the whole network.  I mean, this works.  The whole point of this is getting the
transaction to the miners so they can end up including it in a block.  And it
does work, it's just too repetitive, let's say.  It ends up sending this
transaction or sending this announcement way many times than they should.

Many years ago, I think like seven or eight years ago, maybe, I think it's like
around seven years ago, as I was saying, Gleb, Greg, Pieter, I think one or two
more people came up with this protocol named Erlay that was using set
reconciliation in order to reduce this wasteful traffic, let's say, or trying to
come up with a more efficient way of exchanging this information between peers.
And the way this works is, instead of you sending all these announcements being
like, "Hey, hey, hey", and being super-verbose, what you do is you use what's
called set reconciliation to try to find these differences between you and your
peers.  So, in the end, trying to make it easier, you keep some set of data that
you want to extend to your peers, and these are basically the transactions that
you want to communicate.  And then, every fixed interval, what you do is you
exchange kind of a summary of this set with your peers in a way that you can
compute the difference, the semantic difference between those sketches, they are
called.

**Mark Erhardt**: May I jump in very briefly?  I had a long time
misunderstanding for Erlay and I thought it was transaction data that you were
reconciling, but it is the list of things that you would be announcing to your
peers that are being reconciled.  So, every node remembers who they want to tell
about a new transaction, and these lists of announcements, these inventory
messages, they are being reconciled in an efficient way.

**Sergi Delgado**: Exactly.  So, what you are trying to reduce is the amount of
announcements that you send, right?  At the end of the day, within a single
connection, a transaction shouldn't be sent twice.  Once a node sends a
transaction through that connection, you flag that that peer already knows about
it, so you shouldn't be sending the transaction data more than once.  But in
order to know if they know about it or not, you have to announce it, and it's
this announcement that is made super-redundant.  On average, you're going to
learn that transaction from one single connection, and if you have like eight
peers on average, the other seven, you are either going to tell them and they
know, or they are going to tell you and you already know, right?  And this is
the traffic that you want to minimize, the whole redundancy of, "We already know
about this, but we keep telling each other because we don't know who knows".

So, this reconciliation can minimize this announcement data.  And the way it's
done is instead of being super verbose about what you know and what you don't,
you keep these sets of transactions that you want to announce, or you want to
make your peers aware of, and you exchange what's called a sketch.  I like to
think about it as a summary of what you know.  It's like a compressed way of
exchanging this information using shorter IDs instead of txids; you have some
IDs that are shorter than that.  And the cool thing about this is that these
sketches grow on the size of the difference between the things that you know and
the things that your peer know.  So, even if you have 1,000 things to announce,
that sketch may not be too big.  Then what you do is you exchange these sketches
between peers in a way that you can compute a symmetric difference, and then
when you get that, you know what you're missing, and you know what your peer is
missing.  So then, instead of sending an inventory matrix with like 1,000
transactions, you may send only 50, or 10, or 100, it depends on what the
difference is.  But you only send the things that your peer has already
acknowledged that they don't know.  So, it's a more efficient way of solving
this difference between what you know and what your peer knows, and how to
reconcile the difference.  That's why it's called set reconciliation.

**Mark Erhardt**: Okay, I think now we're diving in deep, right, after getting
another overview of how Erlay addresses the problem.

**Sergi Delgado**: Yeah.  And actually, I want to reference one of the things
that you said earlier in the podcast, which is the fence analogy.  When I
started reviewing Erlay a few months ago, back last year, one of the things that
I was trying to realize was, okay, is this worth implementing?  The claims in
the paper were that you could save a decent amount of data by changing from
fanout, which is the current transaction relay approach, to set reconciliation,
and that paper had been out for a while.  Some implementations had been going on
for a while, but it looked like it didn't have that much momentum.  So, I was
trying to understand why, right, and trying to convince myself that the claims,
the theoretical claims or the potential savings actually match what you can do
in implementation, and what was the complexity of all those changes, right?

So, when I started reviewing this, I started having a lot of questions that I
couldn't answer myself.  It was like, okay, "What happens with this and what
happens with that, and why is this selection of parameters being -- why are we
trying to do it in this way and not in that other way?  And should we relay more
transactions doing this or that?"  I had a lot of questions that I couldn't
answer.  And the answer for that was like, well, I mean we need to simulate
these things and realize what works and what not.  And Gleb already did a bunch
of simulations on this and he came to some conclusions.  But some of the code
was not already in, and changing some of those things actually meant that some
of the simulations that may have already been run were outdated or were not
considering new changes in the code.  So, at some point it was like, okay, we
are fixing some of the things, or we were changing some of the approach, but
that's going to imply some changes on the expected results, and I don't know
what those are going to be.  So, long story short, I decided to rerun
simulations, and in order to do that, I ended up building a simulator, because
the one Gleb was using is in Java, and I'm not too familiar with Java anymore.
So, it was like, I don't want to have to maintain a codebase in a language that
I'm not fluent on.

**Mark Erhardt**: Right.  So, you build your own simulation framework.  I think
we've reported on Hyperion, I think, already.  And you basically threw the book
at the previous choices and tried all of the possible combinations, or not all,
but a big bunch of different combinations of parameters.  And maybe very
briefly, what did you find and how does that lead to this news item?

**Sergi Delgado**: Right.  So, yeah, trying to make it brief, there's one thing
I haven't mentioned yet that I think is important, and that was also a
misunderstanding that I had when I started looking at this, which is that even
if we switch to Erlay, we still have kind of a hybrid approach.  Erlay doesn't
work good if you don't do a small amount of fanout, the current approach for
relaying transactions.  So, Erlay is good at reconciling small differences.  So,
you need some amount of burst of the current transaction relay approach so that
the transaction can spread through the network to a certain extent.  And then,
Erlay works really good at solving the small differences that nodes may have.
But if you try to do everything with Erlay, then Erlay happens to be way slower
than fanout is, so you're going to take a long time to propagate this
transaction to the network, and that's something that it's not ideal, right?

**Mark Erhardt**: Right, because first you would have to have the timer trigger
again that you start the reconciliation, and then you would compute the sketch,
give it to the other node, the other node calculates what the differences are.
If there's a lot of differences, you still announce all of these transactions in
full to each other.  Then they say, "Oh, yeah, I don't have those transactions,
get those transactions".  So, basically all of the same steps that happen for
fanout would happen after Erlay again for all of the transactions that are not
missing.  So, if they're not spread, you just add more overhead, and all of the
singular connections that exchanged the transactions before would do so, but
just with more delay.

**Sergi Delgado**: Exactly, exactly.  The thing to have in mind is that fanout
than set reconciliation, as long as the peer that you're trying to announce this
to doesn't know the transaction.  So, that's why you need some way of spreading
the transaction a little bit first, or to reach some extent of the network, so
you can work with set reconciliation later.  And that's basically one of the
things that we were trying.  The big question that we had for months was, what
are the optimal or what are a set of acceptable parameters that we can use to
spread this transaction enough so then set reconciliation works well, but
without having to spend it too much, so you start being redundant?  So, is there
a sweet spot in where you do an initial burst of data, and then you can work
with the rest through reconciliation?

I mean, up to a few weeks ago, we have said no, because the thing is that if you
think about this, the way we would think about it is like, oh yeah, you do a
first burst and then you reconcile.  But this assumes that you know where in the
transaction propagation cycle you are, right, and that's normally something that
nodes don't know.  You receive a transaction and you don't know how long this
transaction has been propagating.  You may have some cues that you may use, but
through some of the simulations that I've posted in Delving, actually some of
the intuition that we had didn't work well.  It was like, oh, maybe if you have
received more announcements of this transaction, then you're later in the
propagation.  But it turns out that due to some of the timers that are in place
to prevent people from knowing what the origin of this transaction is, this is
more complicated than it looks.

**Mark Erhardt**: Right, when you first hear about a transaction, it's always
the first time you hear about the transaction.  So, maybe you get another
announcement within the time right after, but otherwise how would you even know
you're late in the propagation?  It's the first time you hear about this
transaction.

**Sergi Delgado**: Exactly.  And actually, that's something that we tried.
Like, what happens if we hear about that transaction multiple times before we
actually decide to propagate it?  So, we receive the first announcement, then we
have some timers going on for privacy, and then we relay this transaction.  So,
what happens if we receive more INVs or more announcements in between the first
and the moment we decide to propagate?  But that didn't work out.  The intuition
would be like, "Oh, we're going to receive more, and then this tells us where we
are", but actually this didn't end up working.  But starting with you, Murch, a
few weeks ago, some other -- I mean, we were discussing about like --

**Mark Erhardt**: Should I just say it?

**Sergi Delgado**: Yeah, you can say it.

**Mark Erhardt**: Yeah, so Sergi walked us, here at Chaincode, through his
recent work and his results from the simulations, and the question came up, if
we can't use the number of announcements that we've gotten for a transaction yet
in order to determine how much fanout we want to do, what if we use whether we
learned about a transaction via the fanout, aka a direct announcement or versus
reconciliation?  So, the assumption is that the reconciliation is slower, so if
we hear about a transaction via reconciliation, it might be later than if we
hear about it via fanout.  And back to you.

**Sergi Delgado**: Sorry, I was muted.  Exactly.  So, in the end, using the way
you have received this transaction can be used as a proxy for whether you are
early or late in the propagation of the transaction, and that turned out to
work.  So, instead of having an approach that is more linear, that is what we
were doing before, that was targeting a really small fanout rate, because you
don't want to be too verbose here, we ended up implementing an approach that is
less redundant, has a really small fanout rate if you receive this through
reconciliation, because you assume that you're later in the transaction
propagation.  But if you receive it through normal transaction relay, then you
are going to assume that you're early because this is faster, and then you're
going to keep pumping it in this way.

So, long story short, this led to better results than the current approach in
Bitcoin Core has.  I mean, this is not merged code, right?  But we were aiming
for something that had a really small fanout rate, because I mean we wanted to
maximize the bandwidth savings.  So, yeah, long story short, looks like this
works better, so it's a step in the right direction.  We are still trying to
make it even better than this because the bandwidth savings are good.  But we
also realized that Erlay is definitely a trade-off between bandwidth and
latency.  And the latency is increasing a decent amount.  So, yeah, in the end,
I wanted to put out there all the results of the simulations that we've been
running and what the approach is and so on, because we created a working group
for this some time ago, and I feel people within the working group are pretty
informed, but the wider community may not be as much.  And you see sometimes
someone finds a paper from, like, '73 or something, solving an issue of yours.
So, I'm not expecting that to be a case, but I think it's good for people to
know what's going on.

**Mark Erhardt**: Sorry, if I may jump in again a little.  So, the overall
understanding that we take away is we have a better idea of how much we want to
directly announce transactions to peers and how often we want to reconcile, and
we trigger on the difference whether we as a node got a transaction via fanout
or via reconciliation.  If we got it via fanout, which is the direct
announcement, we fan it out to more other people; if we learn about it via
reconciliation, we fan it out to fewer people.  That question just came here in
chat, so that's why I'm picking it up again.  Overall, we will save some
bandwidth that way, but the transaction propagation latency to reach all the
nodes is going to go up a bit.  So, we save bandwidth, but we slow down the
time, or we extend the time until everybody has heard about a transaction.
Yeah, so basically it is about this trade-off, how much bandwidth are we willing
to save, or how much bandwidth do we want to save, and how much time are we
willing to add to the full propagation of a transaction.

**Sergi Delgado**: Exactly.

**Mark Erhardt**: The interesting point for that is, if we increase the number
of peers nodes have with Erlay with this reconciliation approach, the overall
bandwidth that we spend to reconcile with the entire network doesn't increase
that much.  So, we might be able to have a lot more peers and have a bigger
Bitcoin Network, be better connected, be more protected against sybil attacks
and eclipse attacks without spending a lot more bandwidth on them.

**Sergi Delgado**: Right.  That's one of the, I think, less known benefits from
Erlay, that right now I feel there's a limit on how well-connected you could be,
because the bandwidth that you're going to use is going to scale with the number
of connections.  And that's one of the reasons why transaction-related
connections hadn't increased much in the late years, right?  We've had, like,
eight outbound connections for, like, over a decade.  And that's because if you
increase the number of connections, your bandwidth is going to increase
linearly.  But Erlay can actually fix that to make it so the amount of bandwidth
that you have to use is rather constant.  Maybe it does increase, but it
increases like this, the steep of the slope is way smoother than it is if you do
it with the current transaction reconciliation protocol, right?

So, yeah, I feel like my goal would be to make it better, even with the current
number of connections, so I'm trying to find a way of reducing or improving the
bandwidth right now.  But if it comes to that not being the case, I think it
would be a win to be able to maintain what we have, but make it better if we
increase the number of connections, which is something that we are also aiming
for.

**Mike Schmidt**: So, if you've heard about this Erlay thing and you're
listening now about these updates, well, Sergi posted five different posts to
Delving Bitcoin about updates to Erlay.  So, obviously check those out, many of
which are simulation- and data-based and have their own conclusions.  So, check
all that out and refresh yourself, because Erlay is a thing that is actively
being worked on again.  Thank you, Sergi.  And I would also point out that the
Hyperion Network simulation tool that Sergi also came up with, we talked about
that more in depth in Newsletter and Podcast #314.  So, if you're curious about
that piece for something that you may be playing around with, check out that
podcast and newsletter to refresh yourself on that; maybe you can use that for
something.  Sergi, any parting words for the audience?

**Sergi Delgado**: No, just the usual.  If anybody's interested in this and
wants to chat about it, ask some questions, whatever, yeah, don't be shy.  Like,
if you find some useful simulator tool, you are welcome; or, if you see a way of
improving things, make it faster, more efficient, whatever, yeah, I'm happy to
take any of that.  So, definitely reach out.

**Mike Schmidt**: Great, Sergi, thank you for joining us.  You're welcome to
stay on or we understand if you need to drop.

**Sergi Delgado**: Thank you, folks.

_Tradeoffs in LN ephemeral anchor scripts_

**Mike Schmidt**: Next news item, "Tradeoffs in LN ephemeral anchor scripts".
Bastian, you posted to Delving, "Which ephemeral anchor script should Lightning
use?"  You went on to outline four different options for how ephemeral anchors
could be used in Lightning commitment transactions in the future, and then went
on to solicit feedback from the community on which one might be best.  Maybe,
could you remind us quickly why we'd want to move to using ephemeral anchors in
Lightning?  And then, maybe we can get into some of what the community feedback
has been.

**Bastien Teinturier**: Sure, so as most of you potentially know, Bitcoin Core
has been shipping support for TRUC (Topologically Restricted Until Confirmation)
transactions, which is v3 transactions, which is incrementing the version field
of transactions to obtain into a more restrictive set of allowed children, while
the code transaction is unconfirmed, which allows us to more easily CPFP those
transactions without introducing those vectors.  So, the goal of that is just to
make sure that when you have a transaction and you want to make it confirmed and
you are ready to pay the fees for it, you're going to be able to do it.  And
that's very important for Lightning, because one of the basic hypotheses of
Lightning is that you are able to get your transactions confirmed before a
specific deadline, otherwise funds can get stolen.  So, we want to move to that,
because it increases the security of Lightning channels by protecting against
pinning attacks.  It also makes it better from a kind of separation of concerns
point of view, because then the Lightning transactions themselves will pay no
onchain fees at all and will just directly describe how funds are divided
between the channel participants.  It's only when you actually want to close
that you will use a child transaction to pay the onchain fees.

This is a better separation of concern, but at the cost of a slightly increased
weight when you are actually going onchain.  But force closing a channel is
something that should be exceptional anyway, so it's probably okay to make this
trade-off.  And another very interesting thing with the zero-fee commitment
transaction is that there's something that users usually don't notice unless it
goes bad, that right now, since the Lightning channel commitment transactions
have to include onchain fees, but we don't know what the onchain fees will be
when we want to close.  We are constantly reacting to the mempool conditions to
update the fees of that thing with a message that is called update fee.  And
this actually has a lot of interactions with other things that happen in the
channel, like rate conditions with adding HTLCs, and getting below your reserve
requirements.  So, this update-fee message has been a very large source of bugs
for years, and we can get rid of it when we move to zero-fee commitment
transactions.  So, that's another benefit.  Go ahead, Murch.

**Mark Erhardt**: Yeah, also, this has led to some channel closures in the past
when the two nodes used different fee estimation and disagreed, right?

**Bastien Teinturier**: Yes, very good point.  That's also a very interesting
thing that we're going to be able to remove, is that when you have a current
channel with someone and you see in your mempool that the feerate is starting to
spike, you want to make sure that this channel adapts to this feerate because
otherwise, if the channel transactions stay at the low feerate, that means maybe
you're not going to be able to actually close if your peer is malicious.  But if
your peer just takes more time to see that the mempool feerate is increasing or
has a different mempool than you and doesn't see the feerate increasing with the
same rate, then you're just going to disagree on feerate, and maybe one of you
is going to force close, which is actually a protection in case the other node
was malicious.  But most of the time, the other node is just honest and there's
just a discrepancy in when people update their feerates.  So, this creates force
close channels that we can really avoid and should really avoid, and none of
those will be avoided once we move to these zero-fee commitment transactions.

**Mark Erhardt**: I have one more thing.  I think you didn't mention it, or I
missed it, but one of the big things is also, right now we have to estimate the
fee so far in advance that we have to be extremely conservative.  So, the fees
on commitment transactions actually tend to be very conservative and high.  So,
when you close channels and can set the feerate at the time when you close the
channel, even unilaterally, you can pick the feerates more thriftily.  So, right
now, maybe channel closures overpay a lot more than they have to in the future.

**Bastien Teinturier**: Yes, exactly.  The goal is that with this move to v3
transactions, we're going to be able to pay the right fee whenever we want to
force close.  We won't have to overpay it and we'll be able to react more
easily.  And since the separation of concern between onchain fees and channel
funds, this means that when you are staying in Lightning and not closing the
channel, you're going to be able to use more of your channel balance because you
don't have to pre-allocate to onchain fees; it only happens at closing time, so
this means that you have better use of your channel liquidity, which is another
benefit.  And so, we decided -- yeah, go ahead.

**Mark Erhardt**: So, with all of those benefits, why don't we have it
yesterday?

**Bastien Teinturier**: We don't have it yesterday because we need to wait for
the network to make sure that those transactions would actually relay on the
network, because this is fine, we could have just started creating those
transactions, but if every Bitcoin Core node in the network would have just
dropped them, then security is not great because it never gets to the miners and
then malicious nodes can cheat.  So, we were waiting for Bitcoin Core to have
support for this and for enough nodes on the network to have upgraded to a
version of Bitcoin Core that actually use that, which is getting closer and
closer.  So, we decided that now was the time to start writing the specification
for Lightning Channels and starting implementing it, so that when we see that we
think that enough Bitcoin nodes support the relaying requirements, relaying
policies that we need, then we're going to be able to start using that on
mainnet for Lightning channels.

In doing that, we decided that we're going to start with what's going to be
quite a simple update implementation-wise, because it's going to reuse most of
the existing anchor output channels with only minor changes.  And those minor
changes are only that we're going to switch the commitment transaction to being
v3 and pay zero fees; we're going to switch the HTLC transactions to be v3, and
apart from that, nothing else is going to change for them; and for the
commitment transaction, which currently has two anchor outputs, one for you and
one for your peer, we're going to replace that by only one anchor output that
leverages the new ephemeral anchor stuff that was introduced in bitcoind.  It
will be introduced in 29?  Or maybe it's ephemeral dust that's in 29?  I don't
remember.

**Mark Erhardt**: I think pay-to-anchor (P2A) is out, TRUC is out in 28, and
ephemeral dust will be out in 29.

**Bastien Teinturier**: Okay, that's what we're waiting for.  We were waiting
for ephemeral dust to be able to create that output that will be most of the
time just zero sats, and only is there to allow you to CPFP.  And its value will
fluctuate based on a pending trimmed HTLCs which is something I detail in the
Delving post and is not completely trivial.  But the goal is that we're going to
have only one such anchor output, and the question that I was asking in that
post is, what script should we use for that anchor output?  Because that anchor
output, the goal for it is to be able to pay the fees to bring fees for the
commitment transaction and get your package mined.  And the value of that
output, when the channel is not used and has no pending HTLCs, the value of this
output is going to be zero sats.  But when you are sending HTLCs that are quite
low and are low enough that you won't create an output for them in the
commitment transaction, because it would not be economical to claim that output
onchain, the value for those HTLCs while they are pending will be directly
added.  It's currently only just added to mining fees, just disappears from the
output.

But now, we're going to add this amount to this anchor output, which means that
there's something potentially that could be spent; depending on what script we
use, we decide who is going to be able to spend that.  So, the options are,
allow anyone to spend it, which is the new P2A thing, which is really nice
because it's a very small script, it's very cheap to spend, but anyone can spend
it.  So, basically, if we do that, the behavior will be kind of the same as what
we have today, where miners will get the value of that output.  Because when a
miner sees in their mempool a commitment transaction with someone claiming the
anchor output, if the anchor output is large enough that no other inputs had to
be added to be able to CPFP, then miners should just replace it with something
that sends to themselves.  Yes, Murch?

**Mark Erhardt**: Which is fine, because that transaction still confirms.

**Bastien Teinturier**: Yeah, exactly.  It is fine, because this is already the
behavior we have today.  So, it's what we have today, and there's no downside.
If we do that, it means that we are keeping it the closest to what we have
today.  And in most cases, there's nothing to steal in that output, because in
most cases, it's going to be zero sats and only used for you to be able to
create a child transaction that will use your wallet inputs to be able to bring
the fees.  And in that case, there's nothing to steal for anyone.  It's only an
issue if you decide that you let the value of that output rise to a level where
it's higher than the onchain piece that you would want to pay, ideally.  But I
think it's okay, because it's still what we do today.  And the other options
that I am presenting in that post are different options on how we could
restrict.  If we don't want this to be spendable by anyone, what kind of script
could we use to restrict it to potentially only the two-channel participants, or
the two-channel participants but with the ability to delegate the keys to
someone else.  So, this is just a description of options.

We discussed it yesterday night during the LN spec meeting, and people seem to
be leaning towards just using P2A.  And this is simpler, and this way it's
closest to what we currently have.  And maybe we can revisit it later when we
move to a much different commitment transaction layout for PTLCs (Point Time
Locked Contracts).  But for now, we're probably going to go with P2A directly,
unless someone comes with a strong argument against it.

**Mike Schmidt**: Were there any additional options that spawned from this
discussion?  I know there were these four options, and based on the newsletter,
it looks it's the first option that you all are leaning towards.  But was there
a fifth that was a reasonable discussion item?

**Bastien Teinturier**: There wasn't a fifth option, but Greg pointed out that
we could do something different depending on what the amount of that ephemeral
anchor is.  When it's zero, then there's no reason to do something else than
P2A.  But when the amount is non-trivial, then maybe we could use something
different than P2A.  We're currently leaning towards doing the same thing
regardless of the amount and just using P2A all the time.  And I think there was
no other suggestion, because mainly the main decision is whether we want to
restrict who can spend it.  Because if we decide we want to restrict who can
spend it, then we can come up with a list of scripts; but if we decide that we
don't want to restrict it at all, then there's no reason to investigate specific
scripts.  So, that's where we are at currently, and we'll see.  I'll be writing
the specification for the BOLTs to use that, and I expect that we will have more
discussion directly on that specification.  Was that clear enough?

**Mike Schmidt**: Yeah, that's great, thank you.  Murch, did you have any
follow-up questions?  Okay.  So, I guess we'll look forward to probably
discussing a more formal version of this in the future then, huh, Bastien?

**Bastien Teinturier**: Yeah, I hope so.  In two weeks!

**Mike Schmidt**: Yeah.

**Mark Erhardt**: Yeah, as always, enlightening.

_Eclair #2983_

**Mike Schmidt**: Well, thanks for joining for that news item.  We do have two
Eclair PRs that you would probably be the best person, not only on this podcast,
but in the world potentially to describe.  Eclair 2983 titled, "Only sync with
top peers".  What's that all about?

**Bastien Teinturier**: Yeah, so this is something that we should have done a
long time ago, but we just thought it was not that useful.  But actually, we
realized it is.  So, when your node connects to peers, and especially, for
example, if you have a node that has channels with 60 different peers, by
default, if we don't implement anything with all of those 60 peers, you will try
to get announcement, gossip, details of a network, channel announcement, channel
update from all of those peers, and a lot of it will be redundant and will waste
a lot of bandwidth for no good reason.  So, we've had, for a very long time, a
whitelist option where you could specify that you only want to sync with a set
of whitelisted peers that you would decide.  But apparently, most people just
take the default configuration options and run it.  And by default, we don't use
that whitelist because we wouldn't know who to put in that whitelist; it really
depends on who you connect to.

So, a lot of people were just using the default configuration and connecting to
many people, and then seeing this issue of wasting a lot of bandwidth because
they are syncing the same thing with 60 different peers.  And then they would
discover that there's this whitelist feature and change it.  But we decided that
all of the other implementations already had the mechanism that, by default,
limits the number of peers you sync with.  So, we decided it was just the time
to do the same.  So, the thing we're doing is very simple.  It's that you
configure the maximum number of nodes you want to sync gossip with, and by
default, I think it's five or ten that we put in our config.  And whenever you
start, we're going to look at the channel capacity you have with all your peers,
and we're going to just select the top ones and sync with the top ones.

It's only very useful for the initial sync because afterwards, all the other
people you connect to, you're not going to do the initial sync, but you will
still receive new updates, new channel updates, and new channel announcements
from potentially everyone.  So, this should be fine and this should limit the
amount of wasted bandwidth.

**Mike Schmidt**: I'm curious, talk to me about the rationale for choosing the
largest shared channel capacity peers to sync with.  Why is that the heuristic?

**Bastien Teinturier**: Because this kind of means those are potentially your
top peers, the peers you think are most interesting to you, because you
allocated more money towards them or they allocated more money towards you.  So,
you have funds at stake with them, so it's potentially more likely that they're
going to be behaving correctly.  It's not perfect at all, but if you want, you
can also combine it with a whitelist that is still there.  So, if you want to
force syncing with a specific set of peers on top of those, you can.  But by
default, we needed a heuristic, and we figured that this was as good as any and
quite easy to do.

**Mike Schmidt**: That makes sense.  Thank you.  Murch, did you have a
follow-up?

**Mark Erhardt**: I have one.  Would the channel announcements also be
compatible with something like Erlay for set reconciliation?

**Bastien Teinturier**: That's something we started discussing a very long time
ago when the early prototypes for Erlay were implemented on Bitcoin Core.  There
was a lot of research initially on that, issues with the limitations to, I think
it's 64 bits, for the things you put in the sketch and how we could fit useful
data for a channel inside that.  So, I think Rusty and Alex Myers did some
research on that and found clever schemes to shave off some bits here and there
to get to 64-bit bits.  But there were issues.  It was not as obvious as
bitcoind how we would efficiently use that, so I think that nobody really picked
it up.  And it's on the to-do list of most people, but low on that to-do list.
So, this will eventually come, I hope, but probably not very soon.

**Mark Erhardt**: Okay, thanks.

_Eclair #2968_

**Mike Schmidt**: One more Eclair PR here.  This is Eclair #2968, which is
titled, "Send channel_announcement for splice transactions on public channels".
What did you change here, t-bast?

**Bastien Teinturier**: Yeah, so we started working on splicing a very long time
ago, because I think we shipped that splicing on Phoenix with our node almost
two years ago.  But the thing is, the spec was in flux, and especially also, the
spec for not only the announcement part, but for everything, the spec was quite
in flux.  The only two implementations working on that were Eclair and CLN (Core
Lightning).  And we realized that it would take some time before it was really
complete specification-wise and we had cross-compatibility, so that's why we
went ahead and shipped the first version that worked just for Phoenix and
Eclair.  And then, we kept working on the final specified version with the CLN
folks.  And now, we're at a point where this specification is, I think, final;
we have the implementation.  And since we were only using a non-final
implementation, we only allowed it on private channels, we only implemented the
private channels part for wallets in Eclair, and we never bothered implementing
the public part because it just wasn't ready yet at the specification level.

Now, it is ready at the specification level, and we are finalizing a
cross-compatibility test between CLN and Eclair.  So, it was really high time
that we implemented the public channels part in Eclair.  And we've finished this
implementation.  So, we just have a few things around re-establishment after
disconnection, while we have a few details that we need to finalize between CLN
and Eclair.  But apart from that, splicing should become a reality soon.  Rusty
told me that CLN is going to make a release very soon, so it probably won't be
ready for that release, but it's going to be in the one after, in three months.
Most likely in three months, you're going to be able to start doing official
splicing transactions on mainnet between CLN and Eclair.

**Mark Erhardt**: It sounds your cat is very excited about that!

**Bastien Teinturier**: Yes, he is.

**Mike Schmidt**: Excellent.  Bastien, thanks for hanging on with us and also
doing those additional Eclair PRs with us.  We understand if you need to drop,
but thanks for hanging on with us.

**Bastien Teinturier**: Thanks for having me.

_Emulating OP_RAND_

**Mike Schmidt**: Jumping back up to the News section, our next news item is
titled, "Emulating OP_RAND".  Oleksandr, you posted about being able to achieve
randomness within Bitcoin Script.  Maybe to start, from my understanding, maybe
you could speak about how randomness in Bitcoin Script can be used, and then
maybe we can get an overview of your protocol?

**Oleksandr Kurbatov**: Yeah, and that's interesting that directly there is no
way to receive the randomness by Bitcoin Script, because you cannot inspect
randomness, I don't know, from Bitcoin block headers from previous and following
transactions, and stack is limited.  So, you cannot perform some cryptographic
function within a state with receiving some unpredictable result.  Potentially
you could work with signatures, but it will require a lot of opcodes to process
the signature value and receive some randomness from there.  So, yeah, the
solution is, if you cannot receive a randomness directly from the script, you
can emulate that.  And yeah, it's just a simple idea with two-party interactive
protocol, how you can emulate a randomness offchain.  But to construct the
Bitcoin addresses away, just a provable and probabilistic way of address
construction, where only a challenger with particular probability can unlock
bitcoins from this address.

So, first of all, yeah, let me provide you an example.  So, you have two roles.
It's like a challenger and acceptor.  A challenger can generate several scalar
values, and then it selects only one value that will be used for constructing
the final public key.  But the challenger doesn't reveal which value exactly was
used for that.  Then, acceptor can select one of the available commitments and
construct their Bitcoin address in the way where also one of this list of
commitments was used, but without revealing which exactly.  And then, challenger
can send a transaction and reveal original public key that was generated using
this scalar value and their own public key.  And so then, only with a
probability 1 of n, where n is a number of initial generated scalars, acceptor
can reveal original secret and spend bitcoins from this address.  So, yeah, the
logic is quite simple.

Originally I had a discussion with Tadge Dryja probably, I don't know, six
months ago, and he shared this idea of, can we use some cryptographic function
with probabilistic results?  And yeah, after several months, just this idea came
and potentially, yeah.  I don't know how it will be used in real applications,
because the only applications that came that's like, I don't know, casino on
Bitcoin.  But anyway, probably you can use it such primitive for more complex
solutions.

**Mark Erhardt**: So, let me try to see if I completely understood it.  The idea
would be if you have, for example, a one-in-four chance that you want to
express, the one side would generate four options and commit to all four options
publicly by sharing them with the other party, and pick secretly one of those
four for themselves and commit to that as well.  And then, the other party picks
one of the four, and then basically the other party would be able to spend some
funds if they both picked the same.

**Oleksandr Kurbatov**: Exactly.

**Mark Erhardt**: Cool!

**Oleksandr Kurbatov**: There is some additional stuff that needs to be used.
That's zero-knowledge proofs.  So, each party needs to generate zero-knowledge
proofs that all commitments and all public keys and all addresses were
constructed correctly.  But definitely, yeah, we can use zero-conf and Groth16
proving scheme right now, so it shouldn't be quite a complex proof.  So, it's
possible to do that on their clients without consuming a lot of resources.

**Mike Schmidt**: The first thing that comes to mind for me is now, is this just
Satoshi Dice again without a middleman?

**Oleksandr Kurbatov**: Without a middleman, yeah, because it's important that
you should create a totally trustless game model without an ability to cheat on
each state.

**Mark Erhardt**: That is a nifty construction, though.  Thank you for hanging
on so long to share that with us.

**Oleksandr Kurbatov**: You're welcome.

**Mike Schmidt**: Yeah, Oleksandr, we very much appreciate you hanging on.  And
for folks that are curious more about the construction that we just walked
through, there's a Delving Bitcoin discussion about the protocol, and we also,
in the write-up, referenced some previous work that I think you mentioned with
Tadge there.  And so, yeah, check it out and see if you have some use for that
randomness.

**Oleksandr Kurbatov**: Yeah, thank you.

**Mike Schmidt**: Thanks, Oleksandr.  You're welcome to stay on, or you're free
to drop if you have other things you're working on.

_Discussion about lowering the minimum transaction relay feerate_

Last news item, "Discussion about lowering the minimum transaction relay
feerate".  Greg Tonoski posted to Bitcoin-Dev Mailing List about lowering the
default minimum transaction relay feerate.  His email is titled, "Call for
reconfiguration of nodes to relay transactions with feerates below 1 sat/vbyte".
Murch, I saw that you had responded to this thread, so I was hoping that you
could maybe let us know what you think Greg was getting at here and if it's a
good idea.

**Mark Erhardt**: Right, so this has been discussed a few times already.  We
currently use a minimum relay transaction feerate of 1 sat/vB (satoshi per
vbyte).  So, it means that by default, Bitcoin Core nodes, and I think also
other node implementations, only forward and propagate transactions that pay at
least 1 sat/vB that they want to occupy in the blockchain.  And of course, this
limit was introduced more than ten years ago, and back then it was worth a lot
less in equivalent US dollar value, but there's still the same limit of block
space mostly, well, some changes with segwit of course, and we're still
competing all for the same block space, so this limit has not changed in a long
time.

So, there were some follow-up responses to this proposal by Greg, where he first
said that nodes themselves should just go in there and configure a lower relay
fee.  He specifically proposed to reduce it by a factor 1,000, so 1 sat/kvB
(kilo-vbyte) instead of 1 sat/vB, and Sjors replied that he should also consider
changing the incremental relay fee and the block minimum transaction fee on
nodes, or rather Greg suggested that for some reason, he thinks nodes that
miners are running already use a lower block minimum transaction fee, which is
the feerate that determines what transactions get included into the block
template.  I have investigated that claim a few times already because this
discussion was had a few times already.  And my impression is that there are a
few transactions that are below the minimum transaction relay fee that are in
blocks, but they are very sporadic and they appear mostly at the start of the
block, which would indicate that the miner did not actually create a block
template with a lower feerate, but that the miner increased the virtual feerate
of the transaction by calling prioritisetransaction.

So, when a miner, for example, gets an out-of-band payment to include a
transaction, they will call prioritisetransaction, which makes the node consider
a transaction at this new increased feerate that they're setting, and that will
often be a huge value, so the block template will include these transactions
very first in the block.  So, I have not seen any suggestion of a block being
created with a lower block min tx feerate because if that were the case, we
would be looking at a block that has transactions with lots of decreasing
feerates up to the point where it hits the minimum transaction relay feerate,
and then continues below that in the order of the feerates of the transactions,
and includes transactions with even lower feerates.  And I have never seen a
block that.  In my response to Greg, I suggested that unless miners actually
start accepting blocks or building block templates with lower feerates, setting
this value in your own node only opens you up to DoS attacks and doesn't
actually benefit the network in any way.  And as far as I'm aware, not a single
miner so far has considered or set, maybe considered, but has set this value,
because I have never seen a block that includes these transactions.

Now, they could, and arguably they're leaving money on the table if they're
building a block that is not full and there's transactions waiting that are
paying less than the minimum transaction relay fee.  However, we have to
consider that currently the subsidy is 3.125 bitcoin per block and a block that
is filled with transactions that pay 1 sat/vB amounts to 1 million satoshis,
which is one hundredth of a bitcoin and about 0.3% of the block subsidy.  So,
the fees at minimum transaction relay fee are less than 0.3% of the block
subsidy.  So, going in there, changing your block template building, allocating
more memory to track all these transactions that pay minuscule fees, potentially
having more bandwidth consumption, more CPU consumption, potentially having more
transactions in your inbound queues and outbound queues that you relay that
might slow down higher feerate transactions, I don't think it makes sense for
miners right now, at least from an economic standpoint, to invest the work to
look at this problem or to actually go out of their way to accept these
minuscule feerate transactions.

The argument pro would be that it would become cheaper to consolidate the UTXO
set for users, but on the other hand, it also makes it cheaper to fill up
undemanded block space, which could increase the time that it takes to do IBD.
So, I think calling on node users to lower their min transaction relay fee and
also to set their incremental relay fee to zero, which means that any node that
does this is susceptible to seeing the same two transactions cycled ad nauseam,
and just waste bandwidth and CPU to keep validating the same transactions and
wasting the same bandwidth relaying it to its peers, it is strictly detrimental
to the node runners to follow this advice.  I see absolutely no point unless
miners actually start using lower feerates for their block templates, which
there is no evidence of.

**Mike Schmidt**: I have nothing to add on that.  Thanks for summarizing, Murch.

**Mark Erhardt**: Sorry, /rant.

_Updates to cleanup soft fork proposal_

**Mike Schmidt**: Yeah.  Well, that wraps up the News section and some of the
Notable code changes.  We're going to move to our monthly Changing consensus
segment, and we've highlighted four items for this month.  First one titled,
"Updates to cleanup soft fork proposal".  Antoine, you posted an update on the
great consensus cleanup revival to the Bitcoin-Dev mailing list, as well as a
few update posts to the great consensus cleanup revival Delving Bitcoin thread.
What's the latest?  And thank you for holding on.

**Antoine Poinsot**: I guess the latest is the realization that the design space
has been explored in-depth on various fronts, especially on bounding the maximum
validation times for validating a block.  That's really where the design space
is the largest and where I spent most of my time exploring the different
solutions and trade-offs.  I settled on a solution which is favoring to be
conservative with regards to the confiscation surface.  As a reminder, some
features in legacy Bitcoin Scripts can get very heavy to compute, which makes it
so that some users on the Bitcoin Network trying to use pathological
transactions may impact other users not involved in these transactions on the
network, in the way that the blocks that these non-participating users are going
to try to validate are going to take a long time to validate.  And then, it's
going to have nefarious consequences on the incentives of miners, because then
they can start to attack their competition to make them validate block take
longer, which means that they would not be mining on the tip of the blockchain
at this time.

However, to avoid these long validation times, you need to remove some of the
features in, like I said, Bitcoin Script.  So, one of the main concerns is what
if someone somewhere was actually using that feature, and are we going to make
the transactions invalid, are we going to freeze their coins?  Who are we to
freeze their coins?  So, we need to balance the two systemic risks to the
Bitcoin Network of keeping these poor incentives and strong negative
externalities to other users, while trying to minimize the risk of having
someone losing coins.  Significant concerns were raised regarding Matt's
proposal of disabling some of the opcodes in the form of, what if someone had a
pre-signed transaction that used some of these opcodes and was later spent by
another transaction?  I guess the issue here is more philosophical than
practical, because in practice nobody has such a long chain of pre-signed
transactions for using obscure features of legacy Bitcoin Scripts.  But
philosophically, we should try to not disable anything if we can.

So, what I came up with, along with other people, I had a lot of input from a
number of people, but one deserving a special mention is AJ Towns, is to limit
the number of potentially executed signature operations in legacy Bitcoin
Scripts.  And this limit is going to pinpoint exactly the harmful behavior
instead of trying to disable some opcodes.  It's really like you're going to hit
this limit only if you try to do pathological things to harm the network.  And,
well, if you're doing that, too bad, that's exactly what we want to prevent.
So, also, we had discussions along the lines of, how much do we want to reduce
the worst-case block validation time.  Because with this change, I think it was
a 40x decrease in the worst-case block validation time.  But coupling it with
other mitigation, we could reduce it by a further 7x%, which is significant.
But also, it would come at the cost of a larger confiscatory surface.

So, what I settled on at the end is to take the first 40x% and with the minimal
confiscatory surface, I think that's enough.  If, for whatever reason in the
future, we think it's not enough, we can always go forward, but we cannot go
backward, right?  So, that was the first item, and the one with the largest
design space.

The next one that you have on your news is about the time warp fix, and you cut
me if I'm speaking too much, but for the time warp fix, in Bitcoin, we have
restrictions on the timestamps that miners can use in their blocks, but we have
very loose restrictions on these timestamps because we do not assume all clocks
to be synchronized on the network.  People can be off by a few hours, a couple
of hours.  That's fine, and they can still mine on the network.  And being off
is not one person being two hours off of everyone else.  It's some people being
slightly ten minutes off, other people being slightly one hour in advance.  Then
the time warp fix, I won't explain time warp, we did it in a previous Optech
Recap, but the time warp fix is about tightly coupling the timestamp of two
blocks at the, how would you call it, at the bounds of difficulty adjustment
periods.  Like, the last block of an adjustment period, tightening this
timestamp to the first block of the next period.

So, it means that for one block interval out of 2016, we would have very
stricter restrictions on the timestamps.  And there is far-fetched scenarios on
how it could potentially maybe lead to bad outcomes.  I do not believe that they
are very realistic, but also considering them to the full extent, so considering
these downsides, which I do not think carry much weight, I carried the cost of
addressing them, and it does not cost much, almost not at all.  So, yes, Murch?

**Mark Erhardt**: Yeah, maybe let me just jump in very briefly there.  So, the
time warp attack has been published a long time ago and discussed various times.
The main issue there is if someone actually committed to performing it and
acquired the cooperation of at least 50% of the hashrate to do so, they could
eventually, in something like 41 days, reset the difficulty to the minimum
difficulty and just basically blast through the rest of the block subsidy up to
the end of new bitcoin in like something a little over 40 days.  And that would
of course make it impossible for other people to contribute to this blockchain,
it would mine all the rest of the blocks, it would probably be a failure
scenario for Bitcoin.  And of course it's fairly unlikely, but it's fairly easy
to fix as well by simply requiring that the two blocks that are currently
decoupled, due to the off-by-one bug in the difficulty adjustment, to have them
in a specific time relationship.  And that ties into the, well, do you wanna
talk about the Murch-Zawy attack or have you covered that already in your idea?

**Antoine Poinsot**: Well, I can talk to a lot of things, but I will try to keep
it short, only to summarize the various issues.  There is time warp, which Murch
explained.  There are other concerns with time warp, it's not only about
claiming the subsidy, it wrecks the network, possibly cannot converge for a
while, no more timelocks, which means no more Lightning, and completely wrecks
the incentives of miners as well, and it makes it hard to reason about a lot of
things.  Then there is the Murch-Zawy attack, which is essentially the same
thing as the time warp, but the fix is much less concerning.  It's just about
saying the timestamp of the last block in a window needs to be higher than that
of the first block in this window.

**Mark Erhardt**: Yeah, across a difficulty period.  A difficulty period has to
take a positive amount of time.

**Antoine Poinsot**: Yes, and that's supposed to take two weeks, so that seems
fairly reasonable in terms of synchronization.  So, we do not have the same
concerns.  So, Sjors raised these concerns around potentially leading to some
miners creating an invalid block.  As I said, it was fairly far-fetched because
it relied on some assumptions that in the first place, miners were running
broken software.  So, yeah, whatever.  In the end, he suggested that we use two
hours as a grace period for time warp in relation to the two-hour rule for
blocks to be less than in the future.  And computing the worst-case increase in
block rates in both time warp attack with a two-hours grace period, it's not
significantly higher than with a ten-minutes grace period.  So, I made this
change just to err on the safe side.

Then there is -- my computer locked, so what was the next one on your --

**Mike Schmidt**: Duplicate transaction fix.

**Antoine Poinsot**: Yes.  So, duplicate transaction fix, fairly simple.  I
won't re-explain the bug here, but essentially we had multiple ways to fix it,
mandating that coinbase transactions use a specific version, that they use a
specific locktime, variants around the locktime.  And I reached out to some
miners, I'm still speaking with some miners, by the way, with regards to the
time warp fix, the Murch-Zawy fix, and the coinbase duplication fix, in private,
but I reached publicly, reached privately, and basically the feedback from
miners were like, "That's all the same for us.  It does not matter".  Because, I
don't know, maybe using the locktime would have been an issue for them for
whatever reason of ASIC firmware they might be using.  But it turns out, no real
reason to do one or the other, therefore I'm going for the one that offers
slightly more benefits, which is using the block height in the locktime.
Technically it's block height minus 1, but that's the same.

So, it allows applications to be able to query the block height of the coinbase
without having to parse Bitcoin Script, which is notoriously hard.  So, that's
nice, that's a good add-on.  And yeah, that's basically it.

**Mark Erhardt**: A couple of little follow-ups on that one.  So, it would
require that each new block that's found in their coinbase transaction uses a
locktime in the coinbase transaction locked to height minus 1.  So, for block
360, it would be locked to 359, which means it becomes valid at 360 if the
locktime is enforced.  Coinbases do not enforce locktimes, I assume, or would
that change?

**Antoine Poinsot**: They do.

**Mark Erhardt**: Oh, they do?  Oh, yeah, right.  Yeah, the sequence is to max
value, right?

**Antoine Poinsot**: No.  You have the sequence free.  Right now, it's never set
to max value.

**Mark Erhardt**: Well, we can explore that out of band maybe, but either way --

**Antoine Poinsot**: Basically, yes, it's easier to trust in Bitcoin Core
implementation that the locktime check is not conditioned on a transaction not
being coinbased, which means that if a miner is using a random locktime, they
will create invalid blocks.

**Mark Erhardt**: Well, valid blocks with the height minus 1. If they used the
right height, they would create an invalid block, and that's of course why you
use height minus 1 instead of height.

**Antoine Poinsot**: Yeah, you said if they used random ones, but yes.  Okay.

**Mark Erhardt**: I think I have one related topic that I would like to ask you
if you feel like it.  There's been a couple of suggestions this week on the
mailing list.  One is to split up the four fixes into separate soft forks,
because we can have 27, or whatever, soft forks activating at the same time.
And there's also been a new draft proposal that takes one of your proposed fixes
as a separate proposal, even though it's been pretty well covered that you've
been working on this and doing the research to back up your proposal for the
last year.  Do you want to comment on that?

**Antoine Poinsot**: I'm not involved in this other proposal.  I'm not sure the
author himself is involved in actually doing work around this.  Yeah, whatever,
I guess some more support for the idea.  Yeah, so basically we had arguments
with this person on Twitter and other forums.  I don't think that he really
understands the topic at hand.  And it's interesting that he is splitting out
what I would consider to be the least important fix in the whole BIP.  But
whatever, if he wants to create a BIP, everyone should be free to create a BIP.
But it doesn't mean that he deserves attention.

**Mark Erhardt**: Okay.  So, I think the point that I was trying to get at is
that we are, of course, deploying four fixes at the same time, because the
effort to roll out a soft fork is quite significant, to build consensus around a
proposal and to activate it on the network.  So, if we're going to make a few
fixes, it would make more sense to bundle them together rather than to have four
separate implementations of the activations, and for them to be able to
independently activate and potentially have interactions between the fixes that
have funny outcomes if only one of them activates and not the other.  So,
bundling them together into a single soft fork proposal makes more sense to me,
because it will be easier to activate.  All of these seem pretty uncontroversial
to me, so, yeah, I think keeping them together is a better idea.

**Antoine Poinsot**: Yeah, so a few things.  That's also Antoine's comment on
the mailing list.  He replied to my email saying, "Well, technically, we could
deploy them as separate soft fork deployments.  So, let's do it", and I think
it's just a non sequitur.  It's not because we can do something technically that
we should do it.  I think there is significant reasons to just bundle them
together, the first one being, for instance, the 64-byte transaction or the
BIP30 fix.  I am not sure they would actually be worth updating Bitcoin, because
there is a fixed cost to doing a soft fork, a fixed technical cost, because
there is risk and cost; and there's also just social costs to just, "Hey, we are
going to modify the consensus rules of Bitcoin, we are going to change the
contract we all abide by".

So, small fixes might not make it to the fixed cost and bundling all of them
together help to drive to this cost.  And also, I think if we are going to fix
the vulnerabilities of the protocol, we should not leave it half broken, and
only fix some of them.  On the other hand, if there is significant concern with
one of the fixes, then there might be a good reason to drop it out entirely.
But it does not mean, like, either we think it's a bad idea and we do not do it
at all, or if we think that is a good idea, we should do it together and not
leave the protocol in a half-assed state.

**Mike Schmidt**: That makes a lot of sense, Antoine.  Yeah, thanks for
commenting on that, because I had seen some of this discussion as well on the
mailing list and a separate BIP appearing recently as well, but that's good
perspective.  What are the next steps?  What should the audience know or do
around the consensus cleanup efforts?

**Antoine Poinsot**: I'm trying to still reach out to miners, because it's such
an opaque community of industry.  Fortunately, in the last years, we've had a
lot more mining developers engage with the open-source developers community,
which is good, and I could get some feedback there.  But I just want to make
sure there is no position for a stupid reason to just not deploy the soft fork
just because, whatever, we were using these bits in this data structure.  So,
that's one concern.  I think starting to socialize the idea and I'm going to
publish a BIP, yeah.

**Mark Erhardt**: Two weeks, right?

**Antoine Poinsot**: Yeah.  I've had a lot of feedback already, but maybe trying
to get it from a larger circle of developers than the usual protocol developers
involved in these discussions would be nice.  But yeah, next steps, I'm going to
write a BIP, and I'm implementing it right now.

**Mike Schmidt**: Excellent.  Well, thank you again, Antoine, for hanging on
through one of our longer shows, and we appreciate your time and perspective and
also work on this important initiative.  So, thank you in all regards.

**Antoine Poinsot**: Thank you.

_Request for a covenant design supporting Braidpool_

**Mike Schmidt**: All right.  We have now three remaining items in the Changing
consensus segment.  The first one is, "Request for a covenant design supporting
Braidpool".  And Bob, like I mentioned, these next three items that remain, they
actually all have something to do with Braidpool.  So, I think maybe it's a good
idea to remind the audience briefly what Braidpool is and what your goals are
for it, so we can set these remaining items in the proper context.

**Bob McElrath**: Certainly.  So, Braidpool is a decentralized mining pool.  We
are attempting to reboot P2Pool.  P2Pool had a number of flaws, but it was
fundamentally a pretty good idea.  I think it was a merge-mined blockchain
solely for the purpose of producing Bitcoin blocks.  The idea is that the blocks
in this share chain, each of which can be a Bitcoin block, but they miss the
Bitcoin's target, so they are full Bitcoin blocks, full transactions,
everything, but they miss the target.  These are called weak blocks, these are
shares, and then we can build a system which does accounting on those shares and
then pays people.  That's fundamentally the big picture, is to decentralize
mining here.  There's no company here, there's no custody, there's no pool.  You
run your own node, you run a Bitcoin node, and you run a Braidpool node on-site,
which by and large people should be doing anyway.

Bigger picture, there are four distinct functions that a pool provides, one is
minor monitoring; one is payment processing; one is the variance reduction; and
the last one is, I forget what the last one is, but the idea is to pull those
apart and make them all separate functions, right?  So, if you have someone
providing variance mitigation and they're buying your shares, currently pools do
that.  So, Bitmain or Foundry, whoever you're using, is effectively buying your
shares.  And we want to move to effectively a market-based mechanism where we
can have a market for these shares, we can push prices down, make everything
more efficient and have better kind of risk analysis around that, and move to a
more decentralized network, where miners are individually constructing block
templates and push that to the edge so there are more people constructing more
block templates and doing transaction selection.  So, that's kind of the big
picture.

**Mike Schmidt**: Awesome.  Yeah, and it sounds there's been a flurry of
activity recently now.

**Bob McElrath**: Well, yes, basically I got a grant from Spiral to work on this
full-time, that's what happened!  This has been an old idea.  I first presented
the idea of using a direct acyclic graph at Scaling Bitcoin 2015, so ten years
ago now, and it's been a back-burner project for a long, long time.  But that
has also given me a lot of time to think about how to do this right.  I think, I
don't know, there isn't a whole lot of variation about how to do this right, in
my opinion, and there's a lot of shitcoins out there that have done a lot of
things wrong, shall we say, so I'll talk a little about some of this.

_Deterministic transaction selection from a committed mempool_

If you don't mind, I'd to start with the deterministic block template post,
because it overlaps with a couple of the previous discussions, and then move on
to the others.

**Mike Schmidt**: Great.

**Bob McElrath**: So, the idea behind the deterministic block template post is
that these shares in the share chain would carry, let's say, two to five Bitcoin
transactions, okay, and these over time would get added.  So, the block rate for
the share chain -- I call them beads by the way in the braid, just to
distinguish them from blocks in the blockchain, right, they're beads in the
braid, that's the share chain -- you'd have two to five transactions per share,
and these get aggregated over time and become effectively a committed mempool,
right?  Right now, everybody has their own view of the mempool, we don't always
agree.  We heard today about Erlay, as well as Pieter Wuille talking about the
package relay.  This overlaps with both of those, the idea being that when you
construct a block, you have to transmit that entire block and all of its
transactions to everybody so they can validate them.  If instead we have this
committed mempool, I can reconstruct the set of transactions just by looking at
the history of shares.  And because this is a blockchain, everybody has that,
and everybody can independently reconstruct a block.  All I need is any
deterministic algorithm to construct a block, and as long as the network agrees,
given this set of transactions, this is how I construct a block, everybody can
independently compute the block.  And that way, we don't have to actually
communicate it.

So, for us, it means that the share size would be a couple of kB instead of 4
MB.  And that's very important because we're going to be producing these shares
at a rate that's much faster than 1 per second.  And there's fundamental limits
on how fast we can do this, and we need to kind of push down on that.  I want to
bring this to the attention of anybody who might be listening and stuck on for
two whole hours, that this overlaps with the package relay as well as with
Erlay.  Those guys working on Erlay, I think Braidpool would be a great
playground to fool with this.  If you want to try a new transaction relay
mechanism, putting this into Bitcoin Core is risky and difficult.  Braidpool is
green field.  You want to make a new transaction relay in Braidpool?  Please
come, we'd love to try your ideas.

The second thing is that, with respect to package relay and things that, when
you have a share in the share chain that has multiple parents, it's a direct
acyclic graph, so in general you have multiple parents, what we need to do there
is effectively akin to a git merge on the transaction set.  So, each of your
parents has their own mempool, has their own block, and I need to take those two
blocks and merge them.  Now, most of the transactions in there will be the same.
I'm only looking at, like, two to five transactions would be different, and we
need to be able to do that automatically and quickly.  So, I would some feedback
on this idea from those working on transaction set relay as well as Pieter
Wuille's work on package relay and things like that, because we need to be able
to do merges of mempools quickly.  This means a couple of funny things.  One is
that we're going to have to essentially pin the Bitcoin version that we use,
because we're effectively going to leverage Bitcoin's relay policy as well as
its block construction algorithm.  And in the share chain, this is going to
become consensus-critical.  Whether you construct the same block is important,
because if I construct a different block than you and we didn't relay that
block, we now have a fork, right, we disagree on whether this is a valid block.

So, this is what I'm planning to do.  I would like some feedback on this idea,
as well as we need to push on the getblocktemplate API call and make that a
whole lot faster.  And we're looking at modifying a block template by adding a
handful of transactions.  This also addresses a post that I think it was
instagibbs said, he wants to be able to do transaction acceleration type
functionality.  By carrying, let's say, two to five transactions in a share, we
can include those in the block that you construct easily.  That enables
transaction acceleration.  And if those are also valid for P2P relay, they then
go into the commitment pool.  So, that's that idea.  I'll stop there.

**Mark Erhardt**: Yeah, I have a few questions already.  So, one question would
be, how do you deal with two competing beads at the same height having
conflicting transactions?  So, in the DAG (directed acyclic graph), of course,
the next bead would add more transactions and it might reference both of these
as parents, but if they are in conflict, can it only accept one of them?  Does
it pick?  Is there a sort of a concept of a longest chain of beads that is used
to --

**Bob McElrath**: Correct.

**Mark Erhardt**: Okay, sorry.

**Bob McElrath**: Yes, exactly, it has to pick one.  And within the DAG, there
is a highest work path through the DAG, right, and this is a linear path through
the DAG.  So, I published a bunch of algorithms in the last week that compute
what I call cohorts, I can go into that if people like, but also compute the
longest work chain.  And so essentially, whichever of those two has the most
descendant work that built upon it, this is the same as the concept of
confirmation or highest work within Bitcoin.  It's just we're doing it in the
DAG, but the concept's the same.  Whichever one of those has the most work gets
included preferentially.  So, when we do this getmerge, let's say I have two
parents, I preferentially add the parent that has the highest-descendant work.
And then, if there's anything left from the other bead that does not conflict,
I'll add it also.  But yes, there is a concept of highest work, and that is
evaluated using work itself.  If there is a tie, we will use luck, as is done
with Bitcoin anyway.  And luck is just whichever is the smaller hash.

**Mark Erhardt**: Okay, maybe we'll move that out of band.  But in Bitcoin,
lower hash is something that would make selfish mining more effective.  But
maybe here, because beads are so much faster and multiple parents are
acceptable, it's not quite as problematic.  I'll have to think a little more
about it.  The other question that was on my mind was, if you have these beads
that include two to five transactions, what do you do if the beads in total
amount to a bigger block template than you can fit in a single block?

**Bob McElrath**: Well, whatever this algorithm is that deterministically
computes the block template, it has to compute a valid block template, right,
and obviously it has to satisfy the size constraints, vbytes, sighash, sigops,
all the usual stuff, right?  And so, if we just have a set of transactions in
Bitcoin's mempool and we say, "Give us a block", it will give you a valid block.
So, there is a question, should we build our own transaction processing and our
own block construction algorithm?  I don't want to do that, especially not in
the beginning.  In the beginning, we're going to use bitcoind, and if block
template is slow, that means our beads will be slower, but that's okay.  The
algorithm automatically takes into account latency, and so the shares will come
slower, but it will work fine.  And we can then push later on how to make that
faster.

**Mark Erhardt**: Right.  I mean, you actually answered my question already, if
I had been paying better attention.  You said that the beads basically
constitute a committed mempool.  And obviously, you would use that committed
mempool to build your block template.  So, basically what you want is to have
more than one block template worth of transactions in there to get the best
block template, right?

**Bob McElrath**: Yes, basically.  By carrying, let's say, two to five
transactions, the mempool grows over time, and I'm limiting how fast it can
grow.  But we're expecting it to have around 1,000 beads per Bitcoin block, so
that would be a bead time of around half a second or so.  And so then, with two
transactions per share, this would be 2,000 transactions in a block time of
Bitcoin's usual block time.  And so, over time, this grows, yeah.  So, as usual,
we're just going to accumulate the transactions that are in Bitcoin's regular
mempool into this committed mempool, and there shouldn't be that much of a
difference between them, but we're not going to let people dump 1,000
transactions at once, because then you have to propagate 1,000 transactions at
once and now you've got this multi-MB blob you have to propagate to everybody
and validate in much less than a second.  So, the latency considerations around
that make that impractical.  We could do a couple of transactions, but that's
fine, because we have 1,000 shares over which to add more transactions.

**Mark Erhardt**: Right, okay, final question that I already have.  When someone
finds a block, they will build that block based on the bead chain, the Braidpool
they have accumulated up to that point.  How do you prevent them just leaving
out some beads that they don't like, or something, or is that always allowed?
Or due to latency, participants in the Braidpool could have diverging progress
in the bead chain, is that what you call it?

**Bob McElrath**: That's right.  I call it the braid.

**Mark Erhardt**: So, the block templates might still slightly diverge just by
latency, right?

**Bob McElrath**: That's absolutely right.  So, that is automatically taken into
account, and that's in large part the code I published this week.  So,
basically, each bead names parents, right?  And you're supposed to name all
available tips that you're aware of as parents.  Somebody could choose to omit
beads.  And what this does to the DAG is, so this is a long and skinny DAG.
Most of the time it looks kind of like a blockchain, and occasionally we'll get
a diamond graph.  The number of beads per what I call a cohort, which is a unit
of consensus, and this is 2.42, so on average, there's between two to three
shares per, let's call it consensus unit.  So, this is long and skinny, right?
So, if you fail to name some parents, somebody else will come along after you
and name them.  And what this does is it causes your share to be a part of a
larger cohort, right?  Now, we have to put some strict latency bounds on the
size of a cohort.

So, what's really going on here is we're using the presence of diamond graphs
and higher-order structures in the DAG to measure the latency of the network.
So, if you fail to name a parent, that constitutes a measurement that your
latency is high.  What will end up happening is if these cohorts grow very
large, we have to start omitting miners from being paid, because we're now in a
situation where we could be creating Bitcoin orphans, and now we're not
contributing to the profit of the pool.  So, if a cohort grows very large, we're
then going to take the beads in that cohort and sort them by latency and start
cutting people off the bottom.  The limit for that is probably quite large.
It's probably around 20 beads, where on average it would be 2.5, and that
corresponds to a latency of a few seconds.  So, basically, the algorithm will
automatically retarget, automatically measure the latency and use that for
retargeting.

This is the second topic in this list, is that we found, working with Zawy, we
found a way to do this that does not rely on timestamps at all.  Instead, it
uses essentially the propagation latency of how quickly you got your share to
other miners, right?  And using that, we have a way to retarget that is very,
very resistant to manipulation.

**Mark Erhardt**: I recently, at the Bitcoin Research Week, had a conversation
with a researcher that worked on an alternative blockchain design that I keep
being very reminded of.  Are you aware of the paper, Colordag, by Ittay Eyal and
other people?  If not, I'm going to send it to you later.

**Bob McElrath**: I am not familiar with that one.  I know Ittay, I've talked to
him a number of times.  The kind of closest in spirit to this is the DAG KNIGHT
paper by Yonatan Sompolinsky.  I think Ittay might have been co-author of that
as well.  I'm not sure.  But basically, I think that the constraint that you're
looking at the highest work basically fixes all the parameters, right?  Now, the
DAG KNIGHT paper does some things I don't necessarily like, but at the same
time, I think that just requiring that you are using highest work basically
gives you almost no room to manoeuvre.  And I think it's probably true that the
DAG KNIGHT paper is probably formally equivalent to the braid algorithm.  I've
come up with this concept of cohorts, which is a nice way to organize the DAG,
that they don't have.  They've implemented their algorithm in the Kaspa
blockchain and coin, and it's working great for them.  So, there's proof that
the general concept works.  And if I had found some major stumbling block in
doing this, I would directly fall back on the DAG KNIGHT code.  And in fact,
I've talked to them about actually directly using their code.  But I don't, at
this point, see a reason to do that.  I think we've got a very, very interesting
way to do this and a different kind of difficulty retargeting algorithm that
they use.  And so, we're going to try it.  And if we encounter major stumbling
blocks in the future, there are other alternatives here.

**Mark Erhardt**: Cool.  That sounds really interesting.

**Bob McElrath**: Thanks.

**Mike Schmidt**: So, we touched on the deterministic transaction selection,
although maybe, I don't know if you want to elaborate more on the difficulty
adjustment.  And we didn't get into the covenant design, right?

_Fast difficulty adjustment algorithm for a DAG blockchain_

**Bob McElrath**: Yeah, I'll hit that next.  So, the difficulty adjustment, as I
just mentioned, basically relies upon measuring latency, right?  So, it turns
out that you can remove timestamps entirely and essentially measure everything
in units of essentially how many diamond graphs you've got, how many cohorts of
size larger than two you got, and that becomes your time measurement.  And
because this time measurement comes down to how quickly things propagated across
the network, it's independent of timestamps.  We're still going to have
timestamps in there for other reasons, but timestamps have been used for time
warp attacks, for hashrate attacks across lots of blockchains.  What tends to
happen is miners will try to adjust the difficulty very, very low, and then they
dump a bunch of hashrate onto the chain, and they mine a bunch of blocks very
quickly.  This happens on testnet today.  This has been a plague on virtually
every altcoin since the beginning of time.  And I think we found a very, very
clever solution here that gets rid of that problem entirely.

The only thing you can actually do to modify the difficulty is produce blocks,
right?  There is some something you can do here with naming parents.  You could
fail to name parents, but then you just adjust the difficulty upward, right?
You make it more difficult to mine blocks, which is not what you wanted to do.
If you fail to name parents, what you really want to do is adjust the difficulty
downward.  But there's really no way to do that here.

**Mark Erhardt**: You just answered my question.  I was going to ask, what if
you just -- you can omit information and that's, yeah.  So, basically, you want
to name as many parents as possible because that reduces the difficulty, which
makes the bead chain grow faster, which means that there's fewer diamonds, which
means just two blocks found in parallel and both being pointed out as parent by
a succeeding bead, not blocks, beads.

**Bob McElrath**: Correct.

**Mark Erhardt**: Yeah, cool.

**Bob McElrath**: Yeah, so I did an analysis several years ago where I
determined that there is an optimal value for the number of these beads within a
cohort, and it turns out this is 2.42.  You can read all the math using the
Poisson distribution, all this on our GitHub.  But basically, the target here is
having consensus as often as possible.  This concept of a cohort is defined by
having a graph cut where you can sever the DAG in two pieces by cutting several
lines.  This is our notion of consensus.  When everybody sees the same history
and sees the same set of parents, everybody agrees on a state of network, right?
So, that's the kind of analogy to Bitcoin blocks here, is these cohorts, which
are groups of simple blocks.  So, the target here is, how do I have that happen
as often as possible?  So, this minimum n this curve that I have on our GitHub
comes out to be about 2.42 beads per cohort.  That maximizes how often I get
consensus and is a nice unitless time-independent parameter we can use to
target.  So, that's basically what we're going to do.

In the code I published today, Zawy pointed out that, well, I was planning on
doing this by measuring the number of cohorts.  But in order to do that, you
have to introduce a time interval, which you are averaging these things, and
that time interval has other consequences and is another arbitrary parameter.
He pointed out that all you really need to do is have a target for the number of
parents.  And so, if you have one parent or two parents or three parents, you
adjust the difficulty up or down based upon, do you have too many parents or
not.  Turns out this is all you need.  We can hit that target of 2.42 if we
want.  It's not terribly important to hit that target exactly, it would just
have consisted slightly more or slightly less often and it's not really that big
a deal.  We can't push this the other direction.  We can't make the beads come
super-fast, because consensus basically can never happen.

The only way consensus happens here is if there's a quiescent period in the
network where nobody produces a share for a window of time, such that all things
in flight propagate to the next mining node, who creates then the next bead that
ties everything together.  So, if you run the block rate too fast, you always
have something in flight and you never form a cohort, so you never actually
reach consensus.  And this happens exponentially fast as you increase the block
rate.

**Mark Erhardt**: One curveball.  Would there ever be an incentive for you to
mine a bead that is parallel to what you should be using as your parents, like
you add more parents to the next?

**Bob McElrath**: Yeah, so you name what would be a grandparent as a parent, and
then make a bead like that.  Yes, this is described in the DAG KNIGHT paper.
So, they try to identify when that happens, but they call it there's like a red
path and a blue path within that paper.  I don't think this is actually
necessary to do because if you do that, you end up creating a large cohort.  So,
you adjust your own difficulty upwards, you make it more difficult to mind
blocks, and you run the risk that you have a big cohort and you your bead ends
up being determined to have high latency, and you don't get rewarded at all.

**Mark Erhardt**: Sorry, a bigger cohort translated to lower difficulty, so you
would get fewer cohorts, right?

**Bob McElrath**: Other way round.  A bigger cohort causes a difficulty
adjustment to make it more difficult, because you want to get back to having
one, two beads per cohort, so if you have a large cohort, you make it more
difficult to mine.

**Mark Erhardt**: But then, ignoring parents would make it easier?

**Bob McElrath**: Nope, other way around.

**Mark Erhardt**: Okay, I have to think more about this.

**Bob McElrath**: Okay, yeah, ignoring parents causes large cohorts and causes
the difficulty to go up.

**Mark Erhardt**: Oh, because someone else will pick it up as another parent,
and that will --

**Bob McElrath**: Yeah.

**Mark Erhardt**: Okay, sorry, yeah.  All right.  I think this one is a little
more complicated to digest, but that sounds very interesting.  So, that enables
you essentially to have an extremely quick contribution to the bead chain, which
means that the committed mempool is well populated.  I assume that all
participants are incentivized to pick the transactions with the highest feerates
in order to maximize the shared block reward.  And so, you basically get a way
how everybody will first tell everyone else about the highest feerate
transactions they learned about, and you get to collaborate on creating an
actual block together and you have a deterministic way of how the payout works.
How does the payout work?  P2Pool was paying out in the coinbase which got
excessively large; what does Braidpool propose here, or I guess we might have
talked about that already?

**Bob McElrath**: Well, this is this is kind of the next topic here and that
comes back to covenants.  There are a couple ways to do this that I've
discussed.  So, if you read the proposal right now, I propose to use a giant
FROST multisig to custody this, and there are two pieces of this.  One is that
you have to take your previous coinbases and aggregate them into one big
coinbase essentially, one output; and then, there's a descendant transaction
from that that pays everybody.  Now, this is not what P2Pool did.  P2Pool, as
well as Eligius and Ocean, pay people directly in the coinbase, and they use
PPLNS (Pay-Per-Last-N-Shares).  Right now, I think it's likely that we are going
to do that too, pay people in the coinbase and use PPLNS, because it's simple,
it's been done before.  There are known drawbacks to this, namely, you compete
for blockspace against miners.  Miners also get paid on average n times more
often.  So, if n=8 in PPLNS, each miner receives eight outputs when they could
have received one.  So, this is not great.

But on the other hand, the other way to do this is you need to aggregate the
funds from one block to another.  If you do that with a giant FROST signature,
your only way to decide who's a signing member of this giant FROST signature is
with PoW.  This opens the possibility that somebody could enter that signing set
with hashrate, right?  And when the pool is small, let's say it's 0.1%, it's not
hard to add another 0.1% and become 50% of that signing set and steal the entire
output.  So, I would to do this in the long term, I would still to use the FROST
signatures, but it's really only safe if more than 50% of the network is mining
on Braidpool; in which case, the 51% attack is transferred to the share chain
instead of Bitcoin itself.  It's still there, but it's now on the share chain.
And in addition, the PoW secures the custody of funds.

The other post I made to Delving was about using covenants for this.  I would
love to find a way to do this.  I mean, the idea is that there's only one thing
that should happen here, and we know what it is, and can we get it to happen
right without anybody having the possibility to lose funds?  Using a covenant to
pay all the miners is fairly straightforward.  You can make a transaction or a
tree of transactions that pays everybody.  You know the accounting, everybody
knows the accounting, everybody can verify it.  The difficult part is
aggregating coinbases.  I don't know what condition you can put on a previous
coinbase to be able to aggregate it with another coinbase, and then you can have
your tree that pays miners.  And so, I threw this out there to see if anybody
had come up with something.  I'm effectively using the eltoo algorithm here,
where this is an onchain version of eltoo.  This has nothing to do with
ANYPREVOUT or any of the other Lightning Script things, this is all onchain.
But yeah, I would like to have another idea.  But in the absence of one, I'm
just going to go ahead and use PPLNS for now, just to get started, and we can
come back to revisit this decision.

**Mark Erhardt**: Awesome.  Thank you for that update.

**Bob McElrath**: Thank you.

**Mike Schmidt**: So, Bob, it sounds there's a few things if people are curious.
Obviously, there's this flurry of activity that we covered.  People can
double-click on that and get a little bit more information.  It sounds like with
your funding, that there's some energy reinvigorating the project.  So, if
there's other contributors that want to jump on board and try to help this
effort along, they can start participating in the discussions or reach out to
you if they want to contribute.  And then additionally, if there's script people
and covenant people that are looking for more tangible potentially use cases,
they could use this Braidpool payout scheme covenant sort of as an idea for
furthering particular proposals.

**Bob McElrath**: Yeah.  I think this paying out mining is one of the
fundamental things here.  And I've not been terribly impressed by a lot of the
covenant proposals.  I really view that entire sector as kind of, "I have a
hammer, everything looks a nail" type scenario.  Covenants are cool.  I wrote
two academic papers about covenants, okay, to be clear, so I've been around the
block on that.  But what do we do that's really useful?  Making payment trees
and stuff like this, I'm like, "Maybe, but is that worth a fork to do that?  Not
really".  So, yeah, I think this is a really, really valuable use case, and I
hope people pay attention to it and throw some ideas around, because I do like
covenants.  I would like to see covenants in Bitcoin, but I would also to see a
really powerful use case that says, yes, we really need this.

**Mark Erhardt**: Yeah, finding a way how you could basically have an
aggregating shared UTXO where everybody can withdraw the right amount more or
less unilaterally would be amazing.  Sounds like magic right now to me.  But
there's people that have been thinking about this a lot more and just because I
don't have an idea doesn't mean others don't.

**Bob McElrath**: It's fairly straightforward.  If you have a big FROST
signature, there's two pieces.  One is you aggregate the coinbases; and the
second is you make one big transaction that pays everybody.  And then, every
time you produce a block or a share, you have to update that, right?  So, this
is kind of an analog of the adversarial close in Lightning.  You always have
this fully-signed, ready-to-go transaction that can be broadcast, but it's
timelocked, so that you can mine another block.  In the event that the whole
network just shuts down, everybody has this transaction, everybody can
broadcast, everybody gets paid.  And at the end of, let's say, a difficulty
adjustment interval, you automatically settle, you automatically broadcast this
transaction.  I want the window over which we average shares and then pay people
to be matched to the difficulty adjustment window, because within that window,
essentially, the hash price is constant.  And this enables derivatives and a
bunch of other finance stuff that I can go into at a later time.

**Mark Erhardt**: Right.  So, you mentioned with the FROST signature that you
get a 51% attack problem, where if someone contributes too much hashrate, they
can steal the entire pool.  Is there also the opposite problem that if there's
enough participants that are there to just block the others from profiting, they
can spend some hashrate in order to introduce a liveness issue?

**Bob McElrath**: A liveness issue in the FROST signing ceremony?

**Mark Erhardt**: Well, if more than 50% of the hashrate just didn't participate
in the payout, the rest wouldn't earn anything, right?

**Bob McElrath**: Well, so the idea is that you use hashrate to elect members
who are going to participate in this group signature, right, using the FROST
algorithm.  And within the FROST algorithm, you have to run a DKG (distributed
key generation) to generate nonces.  You have to send a bunch of messages back
and forth saying, like, "Here's what I'm signing, here's a partial signature",
and then you have to aggregate those partial signatures.  It's a whole protocol
on its own that is completely separate from what's going on in the braid or in
the share chain.  So, because the only way you can become a member of that set
that signs things is to commit hashrate, that means you can become a majority
member of that signing set just by committing hashrate.  And the nature of the
FROST Protocol is that it's a usual Byzantine algorithm, so you need 3f+1.  So,
you need 67% of the signing people to actually create a signature.  And then
there's questions of, okay, what if there is a liveness issue and somebody
disappears?  This is where the ROAST algorithm comes in.

So, ROAST is a variant of FROST, which basically runs multiple rounds of FROST
at the same time with different members.  And if somebody falls off, hopefully
one of them still succeeds.  And you can always retry this.  This doesn't need
to happen super-fast.  You sign these transactions after the fact, you don't
have to sign them before you produce a block.  So, if we need to take a couple
of rounds to get this signed, it's not that big a deal.

**Mark Erhardt**: Okay, but if too many people dropped off, everybody else would
lose out, it sounds like.

**Bob McElrath**: Yeah, so if too many people dropped off such that you could no
longer sign the payouts, the last valid signed payout becomes active eventually.
And this is a termination condition for the pool.  So, everybody would know that
this happened and your software would start giving alarms saying, "Look, we
failed to sign the last update".  And so, what happens after that is any blocks
mined after that become solo mined.  So, after a timeout, the miner that got
that block takes the full block reward.  And for the ones that happened prior to
the failure, that signed transaction that pays everybody eventually becomes
active and is broadcast.  And at that point, the pool shuts down.  You can keep
solo mining on it, but the pool says, "All right, we're going to refuse to even
try to sign FROST anymore because we can't", and alarm bells could go off.  We
can always spin up more than one of these; we can shut Braidpool down and spin
it up.  So, we can do some pretty interesting things that would be a hard fork
on Bitcoin, because we can just make multiple of them.

**Mark Erhardt**: Right, makes sense.

**Mike Schmidt**: Thanks again, Bob, for joining us and explaining these three
items from the Changing consensus section and representing Braidpool, and of
course for hanging on for two-and-a-half-plust hours now!

**Bob McElrath**: Thank you, guys.

**Mike Schmidt**: You're welcome to hang on longer if you'd like, otherwise we
understand for sure if you need to drop.

**Bob McElrath**: Yeah, anybody who listened that long has to tweet, "Penguin"
to me!

**Mike Schmidt**: Okay.  Thanks, Bob.

**Mark Erhardt**: Yeah, thank you.

**Bob McElrath**: Thank you guys.

**Mark Erhardt**: All right, we have not that much left.  Also, my battery is at
15%, so --

**Mike Schmidt**: We can do this.

**Mark Erhardt**: -- we can do this.

_BDK Wallet 1.1.0_

**Mike Schmidt**: All right, Releases and release candidates.  BDK Wallet 1.1.0.
There's a few changes here.  One we covered previously, BDK defaults to using
transaction v2 by default.  Additionally, BDK Wallet adds support for using
compact block filters when using bitcoind.  And additionally, there is now
support for wallets using testnet4, in addition to various bug fixes and
improvements.

_LND v0.18.5-beta.rc1_

LND v0.18.5-beta.rc1.  This RC includes a fix for a bug with atomic multipath
payment invoices, where LND would not cancel accepted HTLCs on atomic multipath
payment invoices if the whole invoice itself was canceled.  So, that, I think,
is the main component here.  But there's also a performance improvement if
you're using Postgres database in the back end, there's some UX improvements for
custom channels, and other improvements and fixes.

Notable code and documentation changes.  As a reminder, we went a little bit out
of order, so I'm going to skip the ones that we talked about earlier in the
podcast, and that leaves us with two remaining.

_LDK #3556_

LDK #3556, a PR titled, "Fail HTLC backwards before upstream claims onchain".
So, before this PR, LDK would wait to fail an HTLC an additional three blocks,
which I believe in their code is referred to as latency grace period blocks, to
give the onchain claim additional time to confirm.  After this PR, LDK will fail
the HTLC back sooner, eliminating that three-block grace period and decreasing
the risk of having its counterparty force close the inbound channel.

_LND #9456_

And last PR, LND #9456, which deprecates four LND RPC methods, SendToRoute,
SendToRouteSync, SendPayment, and SendPaymentSync.  Those methods will be
removed in the LND 0.20 release, so users of those RPCs should move to v2
versions of those RPCs, and there's three that correspond to those four
previously.  They're SendToRouteV2, SendPaymentV2, TrackPaymentV2, which replace
the functionality of those four.

**Mark Erhardt**: Tiny nit, at least our newsletter says that they are going to
be removed after the next release in 0.21, not 0.20.

**Mike Schmidt**: Okay.  I read those methods will be removed in the LND 0.21
release.  So, I guess that's after 0.20.

**Mark Erhardt**: Right, but you said 0.20.  That's all good.

**Mike Schmidt**: Oh, okay, got it.  Misspoke there.  All right, well, that was
an epic one, Murch.  You had great energy even at the end there, so I appreciate
that.

**Mark Erhardt**: Yeah, I think it was a lot of good content.  Thank you for our
guests to stick around so long.  This is definitely way more time investment
than we usually require for our guests to chime in.

**Mike Schmidt**: This is like a Year-in-Review Recap duration, but there's a
lot of developments in the Bitcoin and Lightning ecosystem.  So, yeah, thank you
to Bob, Antoine, Oleksandr, Bastien, Sergi, Pieter, Johan, Matt, and my co-host,
Murch, for doing the marathon with us.  We'll hear you next week.

**Mark Erhardt**: Yeah, hear you next week.

{% include references.md %}
