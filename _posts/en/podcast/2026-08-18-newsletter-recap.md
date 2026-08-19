---
title: 'Bitcoin Optech Newsletter #418 Recap Podcast'
permalink: /en/podcast/2026/08/18/
reference: /en/newsletters/2026/08/14/
name: 2026-08-18-recap
slug: 2026-08-18-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Michael Ford (fanquake) and Martin Zumsande to discuss [Newsletter #418]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-7-18/430087601-44100-2-c936a69b67a82.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #418 Recap.
Today we're going to be talking about static Bitcoin Core binaries available
for testing; we also have a discussion about transaction rate-limiting in
Bitcoin core; a proposed contract protocol for mitigating Lightning channel
jamming; and then we'll get into a critical BTCPay Server security release
with some action required for operators.  And then, we have our weekly Notable
code and documentation changes.  This week, Murch, Gustavo, and I are joined
by two guests.  I'll let them introduce themselves.  Mr Michael Ford?

**Michael Ford**: Hi, yeah, I'm Michael Ford or fanquake on GitHub and
Twitter, one of the Bitcoin Core maintainers.  I've been hacking around on
that project for quite some time now.

**Mike Schmidt**: And Martin?

**Martin Zumsande**: Hi, I'm Martin Zumsande.  I recently joined Brink as a
full-time contributor, and I work on Bitcoin Core, mostly on P2P code.  And
yeah, nice to be here.

_Static Bitcoin Core binaries available for testing_

**Mike Schmidt**: Well, thank you both for joining.  For listeners, we're
going to go a little bit out of order in the News section in deference to our
guests.  So, we will start actually with, "Static Bitcoin Core binaries
available for testing", News item.  Fanquake, you announced test builds for
static Bitcoin Core binaries.  And maybe one place to start would be just
conceptually, what is a static binary?  And then we can talk a little bit
about the call to action around folks testing those types of builds.  What is
a static binary?  Why is it valuable?  Why is having a non-static binary
potentially dangerous or problematic?

**Michael Ford**: Sure, so Bitcoin Core today ships, I guess what you could
call sort of semi-static or nearly-static binaries where all of the sort of
nonsystem related dependencies, so I think Boost or libevent or ZeroMQ, when
we compile our release binaries, we sort of bundle all that code into the
binaries.  And then, when a user downloads Bitcoin Core to run on their
system, our binary will reach out to their OS and load a few libraries from
disk.  So, that's glibc, used to be libgcc, maybe a few others.  What I would
like to do, in terms of making our binaries fully static, is that when a user
downloads bitcoind and runs it on their system, the bitcoind doesn't reach out
for anything.  Basically, we would, as part of our release process, bake
everything that we need to run as bitcoind into the binary that the user
downloads.

So, you asked about potential upsides or downsides.  So, obviously, one
downside of reaching out for things on the system at runtime is that if there
was, for example, malicious code in one of these dependencies that you're
reaching for on the system, maybe you could pull that into your binary and bad
things could happen.  If we're reaching for things on the system, we also
don't fully know how bitcoind will behave at runtime, because obviously,
depending on the user's system, their version of glibc is likely different, it
might have different bugs, they might have it configured or compiled in a
different way.  So, having a static binary, where we essentially know all of
the code and all of its behavior ahead of time when we actually build it for a
release, means we can have a much better idea of how these binaries will
behave at runtime.  And essentially, or ideally, they should all behave the
same way on everyone's systems at runtime, if there's no external or runtime
dependencies.

**Mike Schmidt**: Have there actually been issues in the past around this sort
of behavior, or is it just mostly a known thing that there could be this
deviation in behavior, based on versions?

**Michael Ford**: Off the top of my head, I don't think we've had these kind
of issues.  Historically, we've always been bundling dependencies statically
as much as possible, just generally to avoid this kind of problem.  I mean, my
work on this has mostly been just because I think this is sort of the, I
guess, a kind of north star for how we can ship our binaries.  Essentially, we
create one nice little bitcoind blob that is fully self-contained and we ship
that off to people, and it can hopefully run in as many different environments
or on as many different operating systems as possible and as uniformly as
possible.

**Mike Schmidt**: Are there objections to this sort of approach, or is it just
sort of a universally endorsed good?

**Michael Ford**: I mean, so far on the PR that is open, there's been no
definite objections.  I think in general, most people would agree that static
binaries are nice.  Yeah, I mean, there could be some objections.  Obviously,
when you bundle everything statically, okay, your binary gets slightly bigger,
so it might go from 10 or 11 MB to 12 or 13 MB.  In the context of Bitcoin,
when you're downloading hundreds of GB, an extra couple of MB to get going
probably isn't terrible.  One of the pushbacks may be obviously, if we are
bundling everything and, for example, there was a bad bug in something like
glibc that did affect bitcoind, so maybe in some code used to resolve DNS
addresses, or something, historically users would receive that bug fix via
their OS package manager or similar, and they would maybe they get that fix
the day after that bug is announced.  Whereas if we're bundling glibc, then
obviously we actually have to push out a new release with the new bundled
glibc code to fix that.

So, there are some trade-offs here.  Maybe you get slightly bigger binaries;
you're trading off the risk of what if there is a bug in something like glibc
that would affect us, how fast can we fix that or how bad might that be?  But
I think in general, there isn't necessarily a lot of pushback.  Maybe some
pushback from people who are running maybe more customized service setups or
home setups, and this could possibly interfere with their networking
configuration or other things.  But that's also one of the reasons I'm trying
to push for as much testing and exposure as possible for these binaries to try
and figure out where are all these edge cases, what might break?  Yeah.

**Mark Erhardt**: So, generally, I think I would expect a statically-linked
binary to be more portable.  So, how could this break networking code?  I
didn't see the connection there.

**Michael Ford**: So, historically, glibc has always assumed that it can load
code and modules, or I should say modules or plugins from disk at runtime.
And so, if a user was relying on some of that behavior, or as part of their
networking setup, it's possible there could be some breakage here.  But yeah,
we're yet to see anything like that in any of the users or developers who have
tested any of these binaries.  So, I'm hoping that's very unlikely to be the
case, but that's one possibility.

**Mike Schmidt**: Is the idea that this would be one option for download, or
the only option for download if you're downloading the binaries?  And then
maybe also, a vision of what systems could eventually be compatible with
static binaries?  Like, would this be something that could happen on Windows
or macOS, etc?

**Michael Ford**: I mean, so we're obviously doing it for Linux initially.
I'm not sure if it's even possible for us to build fully static macOS or
Windows binaries.  I don't think that's actually doable currently.  But yeah,
we're certainly doing it for Linux.  I think in the ideal scenario, we would
switch to these being sort of the default and sort of only binary to download,
obviously unless there were some major issues or there are enough people
coming out of the woodwork to say that these binaries are going to be
incompatible with whatever their setups are, or however they're running
bitcoind or some other unforeseen problems.  And ideally, these binaries are
going to make it possible to run bitcoind in more places than it is possible
to run it today.  Because currently, we ship a release binary that has a
runtime requirement of glibc 2.31 or later, which means you have to be running
Ubuntu 20 or later, or Fedora version whatever or later; whereas the
statically-built binary with glibc baked in can run, I think I've tested back
to Ubuntu 12.04, or now you could run it on musl-libc-based systems like
Alpine, which ship with musl libc, but you couldn't run our bitcoind on those
previously.  You could run bitcoind in a container with essentially no
operating system, like a scratch container.  I think people have said they've
tested it on NixOS, which you could previously run bitcoind on, but you had to
use like a nix-ld wrapper to sort of make the runtime libraries work properly.
But now, that's also no longer applied.

**Mark Erhardt**: So, trying to sum up some of the different trade-offs here,
it sounds to me that the static binary is an awesome offer for systems that
currently struggle to run it, Linux systems, that is, like containers or other
operating systems that are not directly served through the release usually.
But then the bug-fix thing, especially in our times right now where the LLM
advancement is so rapid that we've seen numerous changes in how security
engineering works lately, it seems to me that it would be best if both were
offered in parallel, static for those that need it, and for operating systems
where you would prefer to get the glibc from the system, to keep it that way.
I know you touched on it previously, but could you elaborate on that again?

**Michael Ford**: Yeah, if there was demand for us still delivering both,
that's obviously something we could do.  Yeah, I mean we could also think
about maybe changing how we produce releases, if it became apparent that there
were so many bugs being found in glibc that we had to ship a new release every
other week.  That's certainly something I guess we could try and think about
and try and combat.  I mean, the amount of code that we do use in glibc is
certainly not enormous.  So, at least if there are bugs there, generally the
likelihood of them affecting us is not super-high.  But yeah, there's nothing
set in stone here and we can certainly offer both binaries in parallel, if
there was a demand for that.

**Mike Schmidt**: What does this mean for reproducible builds?  Is this an
improvement in that department or basically the same?  How should folks think
about that?

**Michael Ford**: I mean, hopefully the same, if not slightly better; the same
in that obviously these builds will still continue to be 100% reproducible.
That's something that is never going to change.  And then, if anything,
they're slightly better in that, I guess, the entire sort of binary or the
entire runtime of the binary is now encapsulated in the reproducible build.
All of the code that we are shipping to the end user that is going to run as
part of bitcoind is now built inside the reproducible build environment, or
produced from that environment, as opposed to previously or currently, we are
producing a bitcoind that goes to the user fully reproducible, which then
reaches out to the system and grabs some library that we haven't reproduced or
haven't built.

**Mike Schmidt**: We have listeners that I suspect would want to help you out
with this.  Hearing fanquake is calling out to the community to test this out,
our audience might be prime testers for something like this.  What's the
process?  They're listening right now.  Where do they go to get these test
binaries?  How should the testing go?  Where do they report their results back
to, positive or negative?

**Michael Ford**: Yeah, we want to hear all the results, positive and
negative.  I posted to the Bitcoin-Dev mailing list I think early last week
and sort of linked to some test binaries that I had uploaded.  Or obviously,
people are also completely free to Guix-build the binaries themselves and
check the hashes against mine and then run and test those binaries.  So, you
can track down the mailing list post, and probably starting there is the best
place.  It links to the PR on GitHub where you can leave feedback.  You can
obviously leave feedback directly on the mailing list as well.  As of a couple
of hours ago, I built a new suite of test binaries and put them up on my
GitHub, and I'll update the mailing list and the PR shortly with links to
those.  But yeah, that's about it.  Obviously, you can email me directly as
well or ping me on Twitter.  I don't really mind how the feedback shows up.

**Mike Schmidt**: And in terms of testing, they build or they grab these
binaries, and is it just run the thing and if it loads in any state and
doesn't crash, that's good; or do you have specific things that should be done
beyond just getting it to run bitcoind one time on signet, or whatever?

**Michael Ford**: Yeah, I guess obviously, don't go and drop these binaries
into production, but putting them into environments that represent production
and your production networking configuration or your production OS, taking the
binaries there, sure, you could run an IBD (Initial Block Download).  But just
running them in any capacity is probably going to be 90-ish% of the work, in
terms of figuring out if the binaries are compatible with that environment,
figuring out if they start up correctly, if DNS queries are working properly.
A lot of what is going to be affected by the static builds is sort of
happening in the first few seconds of bitcoind running and like booting.  So,
if you grab this binary and you throw it into a new container, which is the
same version as your production OS, and you can sort of IBD signet or
something from scratch, that would be a good indication that bitcoind is going
to work there, I think.

**Mike Schmidt**: Murch, Gustavo, Martin, any other questions for fanquake?
All right.  Well, I think we have our call to action for our listeners here.
Fanquake, we appreciate your work on this and joining us today to talk about
it.  If you have other things to do, we understand, you're free to drop.

**Michael Ford**: Awesome.  Thank you for having me.

_Replacing per-peer transaction rate-limiting with global rate limits_

**Mike Schmidt**: Cheers.  Second news item this week titled, "Replacing
per-peer transaction rate-limiting with global rate limits.  Martin, I saw you
were involved with this discussion and the PR that I think we covered back in
Newsletter #416.  But Bitcoin Core just merged a redesign of how nodes sort of
paste their transaction announcements to peers.  Maybe it would be helpful for
you to articulate how that's done currently and how it will be done in the
future?  And then, maybe we'll have some questions for you based on that.

**Martin Zumsande**: Sure.  So, let me first say that I am not the author, I
was just one of the reviewers, and it has also been a while since I've
reviewed this.  So, I'm maybe not into it that much.  But maybe I'll just
begin with a philosophy like, why do we have transaction rate-limiting in the
first place?  In principle, I would say our goal is that each node receives
each transaction that has paid enough fees.  But the important thing is what
happens if we get a bunch of transactions at the same time.  If we would
announce these transactions to all of our peers all at the same time, we would
have a huge surge in traffic, and that is something we don't really want to
do.  So, that is why, and it's been the case for many years, we have some kind
of rate-limiting; but rate-limiting in the sense that we just delay it and
smooth it out over time, but we don't throw away any transactions.  And yeah,
another thing that the rate-limiting helps with, that if a low-priority
transaction, like the low fee, for example, is rate-limited and delayed to
send later, and then it gets replaced by another transaction, then we even
save some traffic, because that transaction has never been announced.

So, yeah, that's why rate-limiting exist in the first place.  And so, far it
was on a per-peer basis.  So, whenever we receive a transaction and accept it
to a mempool, then we would put the transaction into a queue of all of our
peers, and each peer had a separate queue.  And then, whenever this peer has
its turn, then we would process some transaction according to the
rate-limiting and announce the transaction to them.  And by announcing, I just
mean like announce the txid.  We don't send the entire transaction yet.  But
given that all of the transactions are happening for all of them, it's still a
lot of traffic if you sum it up.  Question?

**Mark Erhardt**: Yeah, just very briefly.  So, we would have separate queues
for every peer.  And then, we would walk over the queues and in turns, like
each peer has its own timer.  I don't remember exactly what the timing is, but
you can maybe fill that in.  And then, we sort and send the highest feerate
transactions first, right, just up to the limit?

**Martin Zumsande**: Exactly, yeah.  That's the important thing.  We want to
send the most important transactions first, like the one that are most likely
to get mined.  So, we sort them by feerate.  And that happens for each peer
every time.  And that is what has caused the problems in the past, because
what happened was, like in 2023, there were a huge amount of transactions
coming because of some rune or inscription stuff.  And as a result, we had a
very large queue, like of 100,000 transactions, or something, in some cases,
and we had to sort it for every peer every time, and that was a lot of
sorting.  And it basically resulted in a CPU DoS.  So, most of the nodes
became very slow at the network.  And back in 2023, we fixed this a little bit
ad hoc, I would say, like we would make it adaptive so that if there was a big
backlog, then we would send that peer more transactions.  But we will still do
it on a per-peer basis.  And then, there was another thing that improved it
somewhat.  We would just increase the rate that was merged, I think in 2025,
also by AJ Towns, the author of the current PR.  But it also just changed the
rate and it didn't address the problem at its root.

So, now we come to the PR that got merged now, that I would say really
addressed the problem at its root.  And what it did was it changed it such
that we had only one global queue where all of the transactions go in and not
one queue for each peer.  So, what happens now is when we receive a
transaction, we put it into the global queue basically.  And then, every now
and then, we drain this queue.  And depending on whether the rate limit is
reached or not, then we put some of the transaction into a separate queue for
each peer.  But that separate queue is very small, so sorting it and doing
things with it is very fast.  But the large one where all the backlog is, that
is only one.  Or, if we want to be more specific, there are actually two: one
for inbound; and one for outbound.  But yeah, that's the idea of the change.

**Mark Erhardt**: Right.  So, basically, we keep track of all the things that
we want to announce in one global queue, and we keep only that global queue
sorted.  And then, whenever we want to refill what we announce to peers, we
take the top of the global queue and put it into all of the peer buckets.  And
I think we flushed the entire peer queue each time when we announce to the
peer; is that correct?

**Martin Zumsande**: Yes, we do.  I mean, I think we still check if the peer
still needs it.  Maybe it has sent us the same transaction in the interim, so
we can remove it from the per-peer queue.  And I think we also sort it again,
because maybe we have put things twice in there and then they're not in the
same order.  But this is all very fast because the queue is, by definition,
not large.  But then, whenever the peer gets his turn, then we send all of the
transactions we can and we always empty the queue, and that's how it works
now.

**Mike Schmidt**: What rate of transactions, roughly, would begin to cause an
issue in the old way of doing things?  I think it would be helpful for people
to kind of wrap their mind around what sort of volume actually triggers where
the CPU starts becoming an issue and you can observe it on the network?

**Martin Zumsande**: I would have to look up numbers, but if I remember
correctly, the old rate that was allowed or by which we would drain the queue
was 7 transactions per second.  And I mean, what would happen would that this
rate need to be exceeded for an extended time.  Like, if someone just dumps
100 transactions or something, that's not much happening, because this will
sort itself out quickly.  But if over a period of days or weeks, this rate is
exceeded, then the transactions will just pile up over time.  And then, they
can get to these crazy numbers, like 100,000 that were seen in 2023.

**Mark Erhardt**: Yeah, I think this is 2023 April.  Was that the runes
launch?  Or I think the runes launch on the halving.  And a bunch of the
people that wanted runes wanted to be in the first block in order to claim new
rune names, and stuff like that.  So, we also saw the highest fee block, I
think 13 bitcoin or so in fees.  And there were just thousands of transactions
being added per minute.  And then, that happened for hours or days, and then
because the outflow of the queues was limited, the queues grew much larger.
And eventually, the sorting of each peer queue became so much work that it
wouldn't be done by the time the next peer was supposed to get their message,
and the CPUs just fell behind on weaker machines.

**Martin Zumsande**: Yeah, maybe another thing that is interesting is that
usually, like when both of the peers relay transactions, then both of them
work together and help to drain the queue.  So, whenever my peer has sent me a
transaction, I don't need to send it to them.  But what made it much worse,
like in 2023, was that there were some peers that do not send any transactions
themselves, but only one, ours, like spy nodes or monitoring nodes.  And all
of these would make the problem much worse because they would have the biggest
queue, because in that case, only one side would drain the queue and not both
sides, as in other cases.

**Mike Schmidt**: And maybe just a point of clarification the fact that it was
around the halving and it was some spam scheme, or whatever it was, the
content of the transaction doesn't really matter.  For example, if people just
got really scared and decided to do a bunch of withdrawals from exchanges and
the exchanges weren't doing batching, and they had to send out each withdrawal
separately, you'd get the same sort of concern and behavior around limiting in
CPU on the network, right?

**Martin Zumsande**: Yes.  I think in a way it was good that it happened
organically, because if there had been some kind of attack, then the attacker
could have not stopped or made it worse probably.  But since it happened
naturally in a way, at some point, I guess, the rune craze was getting a
little bit lower, or whatever happened there; I didn't really follow that.
But at least at some point, the spam got a little bit less, and then the whole
problem kind of fixed itself before the actual fix could be rolled out,
because that takes always a couple of months, or weeks at least.

**Mark Erhardt**: Yeah, so I think at first, the limit was increased from 7 to
14 transactions per second that would be relayed.  And then, yeah, we've had a
series of other fixes now, and especially now with the one global queue, the
sorting problem specifically is, of course, no longer a multiplied problem by
peers times transactions, but only linear in the number of transactions,
although it gets repeated.  And yeah, so I think this is now the last piece of
that series of fixes that comprehensively addresses the issue.

**Martin Zumsande**: Yes.  Like, one small detail is that the doubling from 7
to 14 didn't happen initially, it only happened last year.  Initially, we did
the other fixes, then the doubling, and now the final fix basically, well,
hopefully.

**Mark Erhardt**: I think there's also now a dropping transactions.  If you're
getting too much from one peer, you stop accepting submissions from them.  Do
I remember that right?  Do you know about that?

**Martin Zumsande**: I don't think so.  Maybe I forgot something.  But as far
as I know, as long as we accept the transaction and they have enough fee, we
should ...

**Mark Erhardt**: Well, maybe I'm making that up.  Never mind then!

**Mike Schmidt**: And in terms of folks who are running a node, obviously, I
guess the intended behavior is there'd be no change in behavior or anything
that they need to do.  They get a version of Bitcoin Core that has this PR in
it, and they'll just be, I guess, less susceptible to this CPU DoS when
there's high transaction relay on the network, right, nothing else for folks
to actually do?

**Martin Zumsande**: Yes, exactly.  This is all something that happens under
the hood, and the normal user shouldn't notice anything except that, I mean
this year, there was a small dump event, or something, in February, or
something, and some nodes would experience some, not as bad, but some
increased CPU again, and that hopefully would not happen anymore.

**Mike Schmidt**: Well, we did cover this PR previously, it was #416.  This is
AJ Town's PR I believe, who also did the post to Delving Bitcoin with a full
writeup to have a discussion around it.  We appreciate that, Martin, you took
the time to join us today on the show to explain it for folks.  But if
anyone's curious about more of the details, check out the PR itself, as well
as the Delving discussion around it that we linked to from the newsletter this
past week.  Anything else, Martin?

**Martin Zumsande**: No, thank you.  Thank you for having me.

_Conditional message transfer contract to solve jamming_

**Mike Schmidt**: All right, thanks for joining us, we appreciate your time.
Cheers.  Our last News item, which was the first News item chronologically,
"Conditional message transfer contract to solve jamming".  This was a post to
Delving from Antoine Riard, and maybe more of a brainstorm than a proposal,
but he is trying to help mitigate channel jamming on the LN.  It's been a
little bit since we talked about this, Murch, but we did have a flurry of
activity, what was it, a year, year-and-a-half ago, talking about different
channel jamming mitigations, and we talked about this idea of fast jamming and
slow jamming.  So, a Lightning node has resources that are scarce.  There's
obviously the liquidity that you're moving back and forth in these channels,
and there's a scarcity there, and then there's also the scarcity of the actual
HTLC (Hash Time Locked Contract) slots.  And so, when someone is trying to
fast-jam you, they're trying to fill out those scarce HTLC slots; and when
they're slow-jamming you, they're trying to hold on to that scarce liquidity.

We talked about different mitigations on both sides.  On the fast-jamming side
on the HTLC, the proposed defence was some sort of an upfront or unconditional
fee to take up that HTLC slot; whereas slow jamming was a bit harder.  We
talked about different proposals around reputation of the peer who's giving
you the HTLC, HTLC endorsements, there's this notion of accountability, all
intended to help mitigate slow jamming.  So, instead of directly charging for
the amount of time that that HTLC and that liquidity is held, nodes were
trying to identify traffic that has behaved well in the past and maybe give
that traffic better access to those resources.  Yeah, Murch?

**Mark Erhardt**: Yeah, to be clear, I think the concrete way this happens is
that you set aside about half of your forwarding capacity, both in HTLC slots
and in balance, and you only use that for reputable peers, so peers that have
previously behaved well and closed their multi-hop payments quickly.  Those
over time would get reputation with you, and then you would let them allow the
second half of your resources; whereas unknown peers, or anyone really on the
network, can use the first half of your balance and HTLC slots.  So, this
would make sure that the reputable LN participants that you're connected to
would always have access to resources, because they're generally kept aside.

This proposal now by Antoine seems to specifically address slow jamming, or it
attempts to address slow jamming.  Did you want to do it?  I only read a
little bit earlier.

**Mike Schmidt**: Go ahead, you're going, I'm not going to stop you.

**Mark Erhardt**: All right.  So, my understanding is that it tries to keep
track of how long funds were held in a multi-hop payment, or in an HTLC, by
making transaction commitments that record at what block height the channel
partners communicated.  And these updates would then eventually allow one of
the channel peers to close the channel and take a fee, or close the HTLC or
close the channel, I'm not entirely sure; but take fee depending on how long
the HTLC was held.  And the longer it was held, the more fee would be
collected.  And it uses basically the Bitcoin blocks as a universal time to
record when the channel partners communicated, and use that as a measure for
the amount of fees that are due.  So, this would address slow jamming, because
slow jamming, of course, is based on creating an HTLC and holding it for a
long time, thereby denying the affected node's resources.  And if you get more
fees over more time, that would make slow jamming more expensive and thereby
mitigate the problem.  Did you read more about it?

**Mike Schmidt**: No, I think that's a good summary.  He calls this
conditional message transfer contract (CMTC) that will let the two peers, as
Murch said, you can have cryptographically-verifiable states associated with
the different Bitcoin block heights.  And I think that there's some maybe
messaging between the two peers there to sort of sign off a long time that,
"Hey, I don't have it yet.  Okay, now I do have it".  And then, there's sort
of a cooperative case, which would be they both agree that the person held for
this many blocks and therefore the fee should be this.  And then, there's two
failure branches in the conditional contract as well.  I think the two
branches are if either peer doesn't respond, although I would assume within
there is also if they're uncooperative with the contract in some way.

Yes, so an attempt to mitigate slow jamming using hold fees, which we've
talked about before.  I think John Law had some stuff on this, but there was
just never an idea of how to enforce the hold fee.  And maybe to reiterate,
the idea is this is liquidity that's being held, and it's sort of like you
want to have a charge for that, because otherwise your liquidity could be
elsewhere.  You could be splicing it into some other higher-volume channel
where you can make fees, or whatever you might be doing with it.  And so, sort
of like a little bit of an interest rate for holding that and then trying to
use the Bitcoin block height as the timestamp for how long that that was held.
One part, and I think it was Lloyd that brought it up, he was the one who
responded in the Delving thread, and maybe, Murch, you can elaborate on this.

**Mark Erhardt**: I think it was waxwing, actually.

**Mike Schmidt**: Oh, waxwing.  Block time, roughly ten minutes, but LN
activity can be quite a bit faster.  And so, I think what he brought up, at
least in one of his points, was, "Is this granular enough to have it being
basically ten-minute chunks that you're trying to penalize against?"  And I
thought that was a good point.  I don't think there's been a response to that
yet, but Murch, do you have thoughts?

**Mark Erhardt**: I think that's why I meant that it's probably only going
work for slow jamming.  For fast jamming, the upfront fee is pretty simple and
I think still being pursued.  For slow jamming, the problem is that you either
give people access to the resources or not, with the solution that is being
pursued so far.  But you can't really charge more if an HTLC is held longer.
And the strength of this proposal is that you can charge a different price for
an HTLC depending on the duration.  And yeah, I think HTLCs, by default,
usually timeout within a day.  Sometimes the maximum for stuff is, I think,
two weeks.  So, 1 block or 10 blocks or 100 blocks are big enough differences
that you could have tiers of pricing that scale with the blocks.  I think that
could work.  The proposal does strike me as relatively complicated.  I think
the construction is similarly complicated as HTLCs in the first place.  We've
had numerous bug fixes over the years with HTLCs being resolved incorrectly,
and so forth.

I'm not sure if the complexity here is not maybe too high of a cost.  That
would be my bigger concern.  Yeah, and then it seems fairly complicated,
because it has to account for when one of the peers disappears or stops
responding.  And so, you still need this timing information, but then you need
to be able to resolve when a peer gets disconnected.  You have to also handle
when the peer becomes reconnected and was just organically disconnected
briefly, and so forth.  So, I think this is a pretty early-stage idea, and I
haven't seen much interest from other Lightning developers so far.

**Mike Schmidt**: Yeah, I think the call to action here would be obvious then.
This is an early stage idea to mitigate channel jamming, check out the Delving
thread, participate in the discussion if it's something that you're curious
about.  That would be, I think, our call to action here.  I think we can wrap
it up.

_BTCPay Server 2.4.2_

All right.  We can jump to Releases and release candidates.  And the author of
this segment, as well as the Notable code segment, is Gustavo, who's going to
walk us through these segments, starting with this BTCPay Server 2.4.2
security release.  Hey, Gustavo?

**Gustavo Flores Echaiz**: Hey guys, thank you for the intro.  So, this week
we have three releases, all security focused.  The first one, BTCPay Server
v2.4.2, we had briefly discussed it in the last week's episode.  This is a
security release that fixes a critical vulnerability that affects all releases
before this version.  And it specifically is related to nodes that run BTCPay
Server instances that run LND nodes.  When you update to the new version, your
LND node will also update to at least v0.21.1, and your macaroons, which are
your credentials to your LND node, will automatically be rotated.  However,
you can also manually update your macaroon credential files if you want to be
extra careful.  This was reported by Craig Raw after he was vulnerable to this
attack.  So, there are reports of this being exploited and funds being stolen,
which indicates how urgent updating to the new version is.

There's also a few other items included in this release, as discussed in last
week's newsletter, related to how TOTP (time-based one-time password) were
also failing in the Greenfield API.  So, an attacker could bypass this
two-phase system using the Greenfield API, so there's also fixes related to
that.  But the main reason for this security release is the LND issue.  It's
also important to clarify that this doesn't affect any user that was running
any other implementation of Lightning, just LND.  And also, onchain wallets
are also secure, and not exposed to this risk.

_LND v0.21.2-beta_

_LND v0.20.3-beta_

The next releases are both from the LND repository.  You have v0.21.2 and
0.20.3.  Both of these releases are very similar.  The difference between them
is that one is for v21 and the other is for v20.  The one that is for the v21
includes additional fixes of features that didn't exist in v20, such as
related to auxiliary channels, which are also known as Taproot Asset channels,
and also onion message handling that also was added in v21, so it's not
included in the maintenance release of v20.  A lot of these fixes, we've
covered them previously in the newsletter.  For example, one that we're going
to talk about in a second is related to a data race in a cooperative close
state machine flow.  But there's other things, such as onion message decoding,
payment migration, invoice updates, HTLC expiry and resolution.  So, a lot of
small fixes.

Another two we covered last week are also included in this release.  So, one
was about when forwarding a blinded payment, LND was unable to identify a node
through its node ID, it was simply able to identify nodes through their short
channel ID (SCID).  So, that is also part of this maintenance release, if
users are recommended to update to these new versions.  And also, v21, the
maintenance release for v21 doesn't introduce new database migrations, but it
includes important fixes to existing database migration paths.  So, that is
also important for users of LND to be aware.

_Bitcoin Core #35493_

Now, we start with the Notable code and documentation changes section.  Once
again, this week is very heavy with bug fixes.  We start with the Bitcoin Core
repo item #35493.  Here, the background is that the importdescriptors RPC
command was not properly updated when introducing MuSig to descriptors.  So,
in Newsletter #366, we covered how Bitcoin Core was now able to import MuSig
to descriptors and how that was implemented.  However, there was a bug where
Bitcoin Core would treat this MuSig to descriptors similarly to how it would
treat other type of descriptors.  So, for example, it would always be looking
for all corresponding private keys for every public key produced when
expanding the descriptor, which would include the MuSig aggregate key, which
obviously doesn't have a standalone private key since it's the aggregation of
multiple other keys.  However, Bitcoin Core was looking for that inexistent
private key, and returning an error message indicating that there was a
missing private key.  So now, importdescriptors RPC is updated to not return
an error when all private keys are present.  Yes, Murch?

**Mark Erhardt**: Just to be clear, I think it is a warning that is being
returned, not an error.  So, as you said, a MuSig2 public key is an aggregate
public key and doesn't have a private key.  The signature is produced by using
multiple private keys together to create an aggregate signature.  And so now,
the import descriptors RPC correctly recognizes if the private key to that
aggregate public key doesn't exist.  But if all the underlying private keys
that are used to compose the signature are present, it no longer shows the
warning.  But it will show a warning if some of the private keys are there and
not all.  But yeah, it's just a warning; it was a false warning that has been
fixed.

**Gustavo Flores Echaiz**: Thank you for clarifying.

**Mark Erhardt**: Also, did you check, I think that was not released yet,
right?  So, this is not a bug fix in a released piece of software.  I think
this is just in the development branch, to be clear.

_Core Lightning #9150_

**Gustavo Flores Echaiz**: Right.  Thanks for that, I didn't check exactly,
but that makes sense.  Thank you for the clarifications.  So, the next item,
now we jump into the Core Lightning repo, item #9150.  Here, the RPC command
askrene, which we covered first in Newsletter #316, which is a new command
that allows a Core Lighting (CLN) user to basically find minimum cost
pathfinding based on an improved implementation of Pickhardt Payments.  So,
this is really about finding the most efficient path for a payment.  And here,
the update is that when making failed payments, the liquidity information of
askrene would get updated.  So, when later trying to find a path, it would
know that a payment failed through this route and it would update in
consequence.  However, when making successful payments, askrene would not get
updated at all.  So, if the liquidity of a channel was consumed, there was no
way for askrene to know about that.

So, the update here is to introduce something called impressions, which is a
new type of information that records successful payments on askrene to adjust
its liquidity estimates for subsequent attempts.  And the goal here, as marked
in the PR description, is to later introduce an RPC command, called repeatpay,
for repetitive payments, which required having this first.

**Mark Erhardt**: So, for example something that you can learn is if you tried
a channel before and the channel didn't have enough capacity in a direction to
route a payment, you would record that the channel wasn't able to forward the
payment in that direction, and that impression would then, over time, be
discarded.  I think also the same is true for channels where it did work,
where the estimated capacity would then be set to at least the amount, or
increased in the estimate.

I wanted to issue a correction on what I said just earlier about Bitcoin Core
#35493.  Importdescriptors was present in the 31 release.  What I was thinking
of was the import descriptors interface PR that we've been talking about
recently in our office, not the importdescriptors RPC.  Sorry about that.

**Gustavo Flores Echaiz**: Great, thanks for clarifying.  So, that's the main
of CLN.  However, there's also another item, which is that now, when
generating BOLT12 offers denominated in another currency, they now have a
ten-minute expiry by default, because exchange rate fluctuates.  So, you can
lock in your exchange rate for a ten-minute period by default, which is
obviously customizable.

_BIPs #2248_

The next two items are now from the BIPs repository.  So, the first one,
#2248, updates BIP3, which defines all the BIP Editors to remove Luke Dashjr
following discussion on the mailing list.  So maybe, Murch, you want to add
extra context here?

**Mark Erhardt**: Yeah, I proposed that we remove Luke Dashjr from the BIP
Editors.  This follows a period of time in which he has contributed very
little BIP Editor work, and then most recently has announced that he doesn't
want to have anything to do with Bitcoin.  He calls it a different name.  And
I think it doesn't make sense to have a BIP Editor that doesn't want to
contribute to Bitcoin anymore, especially privileges should only be held by
people that use the privileges in order to provide the service that they have
the privileges for.  The principle of least authority is that people who have
privileges that they don't use lose those privileges.  You should only have as
much privileges as you need to do your job.  If you're not doing a job, you
don't need privileges.  So, there had also been a few other things where
people had a mixed bag of strong or less strong feelings about it.  But after
basically five years of not contributing to the BIP Editor work, we removed
the BIP Editor privileges of Luke Dashjr.  And this update just reflects that
change, because it lists the BIP Editors in BIP3.  And since Luke doesn't have
BIP Editor privileges anymore, he was removed from the list.

_BIPs #2225 and #2245_

**Gustavo Flores Echaiz**: Thank you, Murch.  Next one, also from the BIPs
repository, combines two different PRs, #2225 and #2245, both related to
BIP110, and both following its unsuccessful activation attempt and its fork
into a minority proof of work chain.  The status has now been updated to
'closed' since this was unsuccessfully attempted.  Anything you want to add
here, Murch?

**Mark Erhardt**: Yeah, so I think we might have talked about this a while
ago, but someone recently discovered that in February, the RDTS (Reduced Data
Temporary Soft fork) implementation got a change that clarified that they
meant P2A inputs to never have witness data, which is a different
interpretation than the P2A BIP proposed, which suggested that Bitcoin Core
would treat P2A inputs without witness data as standard but didn't forbid
witness data, because obviously an input that spends an output is a correct
input, and inputs with witness data that spend a P2A output are still
consensus-valid.  So, they added this consensus change in the February update
to their RC, or sorry, I think it was actually an activation client, and that
was never documented in BIP110.  So, that had been under discussion for a few
weeks in the BIPs repository, but people couldn't agree on the exact phrasing
of how to record that additional consensus rule.  So, the PR that got merged
just added a line that said that RDTS clients would reject P2A inputs if they
had witness data.

So, anyway, that got merged.  And then, because the BIP110 activation attempt
was unsuccessful and obviously so, with now, I think they found a fifth block
last night, but we're about 1,000 something blocks ahead, and it's pretty
clear that the Bitcoin Network didn't adopt BIP110.  So, it doesn't look like
anyone who's working on Bitcoin is still working on BIP110, and the BIP was
closed.

_Eclair #3346_

**Gustavo Flores Echaiz**: Thank you, Murch, for clarifying.  Now we move to
the Eclair repo.  So, we've got once again bug fixes here.  The first one is
#3346.  This combines about four different adjustments that could have
resulted in bugs.  So, the first one is that Eclair could obtain payment
failure message from a recipient, but could interpret it as if it was a
routing hop in, and then would then interpret the message as being a routing
failure, when in fact it was an issue with the recipient.  So, now Eclair
verifies that the decrypted payment failure corresponds to an intermediate
position before using it as routing information, since either a malformed or a
maliciously crafted failure message from the recipient could have led Eclair
to believe that it was an intermediate position and adjust its routing
information; and even potentially, this could have caused an out-of-bounds
access that could crash a specific component of Eclair, the payment lifecycle
actor.

Also, when trying to RBF or simply when trying to broadcast a nonchain
transaction, if Eclair received the response from Bitcoin Core an error
message that it couldn't classify, that it couldn't properly map and recognize
the error message, it could simply stop retrying to broadcast the transaction.
However, as we know in Lightning, there are time-sensitive transactions.  So
now, Eclair is basically going to retry the broadcast of the onchain
transaction, if it cannot properly map the error message it receives from
Bitcoin Core.  That's the second fix included in this item.  And the third one
is when using CPFP when fee bumping to basically confirm a zero-fee commitment
transaction that was broadcast by a peer, it wasn't properly accounting for
the full package weight, it was simply looking at the parent's weight and not
at the child's transaction, which when doing CPFP, you have to look at both
the parent and the child, both of their weights, to calculate a proper fee.
So, that is now fixed.

Finally, the last fix is that when RBFing, when fee bumping a funding taproot
channel transaction using MuSig2, Eclair would always assume that the latest
RBF attempt was the one that confirmed, and would register the MuSig2 nonce
that was used in that latest attempt, even though a previous attempt might
have confirmed.  So now, Eclair ensures that it will use the nonce associated
with the attempt that actually confirmed when sending channel_ready instead of
always assuming that its latest RBF attempt was the one that got confirmed.

_Eclair #3341_

Next item, still in the Eclair repo, #3341.  This is more of a preparation for
potential features rather than Eclair making a bug fix.  But if it wasn't
properly addressed, it could have become an issue later.  So, in BOLT7, there
are message flags and channel flags, which are specific positions in a gossip
message, are currently undefined.  So, if Eclair received a bit of either
those message flags or channel flags that was set to one, because these are
undefined in BOLT7, it would simply discard that value and encode the bit as
zero when forwarding a channel_update.  However, this would modify the signed
message and invalidate the signature.  It's not a problem because these are
undefined and unused, but if later they would become defined and used for
other features, then Eclair was modifying the signed message and then
validating the signature.  So now, Eclair, when forwarding a channel_update
gossip message, will simply not touch these undefined bits, even if they're
set to values that it doesn't recognize, so it will preserve the unknown flag
values when decoding and recoding the channel_update message.  So, this allows
an Eclair node to relay these updates containing these flags, even if it
doesn't yet understand it.  So, probably doesn't have an immediate effect on
the network, but if someone was to start using these bit positions as defined
features, now Eclair will properly relay the channel updates without touching
the bits that it doesn't recognize, specifically what are called message flags
and channel flags.

**Mike Schmidt**: I don't think that this item was motivated by it, but I
think the last Eclair item that includes those four bug fixes, I think tbast
did a shout out to Rob Hamilton and the Red Team, that are doing a bunch of AI
discovery on Bitcoin repositories and sending out responsible disclosures to
those parties.  So, it looks like some Bitcoin-related infrastructure is
quickly making those fixes and rolling out the changes.  So, shout out to the
Red Team there.

_LND #11019_

**Gustavo Flores Echaiz**: Totally, that's exactly right.  Thank you, Mike.
So, the next two items are from the LND repo.  The first one, #11019, was part
of the maintenance release that we discussed earlier in this episode, and you
can find in the Release section of this newsletter.  So, this is about a data
race, a specific race condition, when following the legacy cooperative-close
flow, where the link goroutine, which tracks the channels HTLC and commitment
state, and the peer goroutine, which processes close messages from a remote
peer, they advance concurrently and they could potentially clash.  This could
have led theoretically to disconnecting from a peer because you processed
incorrectly their message, or you sent an incorrect message, or even
theoretically it could lead to closing a channel or even crashing the node.

So now, instead of the link goroutine, which is what tracks the channel's HTLC
and commitment state, instead of advancing to the flow itself, it will report
to the other goroutine, to the peer's channel manager, to inform it that a
channel has been flushed, that all the pending HTLCs have been drained, which
is a step when making a cooperative close in the cooperative-close flow.  So
now, this one reports to the other instead of having both advance
independently and potentially ending in a race condition.

There's also another fix in this PR, which ensures that what's called the RBF
cooperative-close path, which is something that we've covered before -- you
can see in Newsletter #347 for when LND added it -- it used to not check if a
peer's delivery script was valid when no upfront shutdown script was
negotiated.  So, what does that mean?  When negotiating a channel, BOLT2
defines that a peer can define an upfront shutdown script, basically specify
what his withdrawal address will be when they will close the channel.  So, if
a peer had specified this upfront shutdown script, LND was properly verifying
that the delivery script, where the funds were going to go after the
cooperative close, it matched the upfront shutdown script.  But if no upfront
shutdown script was present, LND was simply not verifying at all the peer's
delivery script, and was not even verifying that it was using an accepted
output type.  So, this was potentially causing failures in LND.  So, this is
now fixed.  LND will simply always now verify the peer's delivery script, even
when no upfront shutdown script was negotiated and was present, to ensure that
it uses the accepted output type for this type of transaction.

_LND #11023_

The next item in the LND repo as well is about basically putting limits to how
much can a channel mailbox grow or also, how many update fee messages are
stored.  So, for example, when one Lightning peer, specifically the funder of
the channel, communicates to his fellow peer to update the fee that will be
used in the commitment channel updates, in the commitment transactions,
because the onchain fees in its onchain node has changed, well before, LND
would keep all update fee messages in storage.  So, for example, if I told my
peer every second to update the fee, my peer would simply keep all of those
messages in storage.  However, BOLT12 defines that this has a replaceable
state model, so he only needs to keep the latest update fee message; an LND
node doesn't have to keep all the update fee messages stored.  So now, LND is
updated to simply only keep the latest message, to prevent redundant
uncommitted fee updates from growing the update log.  Of course, if a newer
fee update arrives before the previous one had been included in the commitment
transaction, LND now replaces the fee value.

There's also a second part to this PR, which is limiting the size of channel
mailboxes, which were previously uncapped.  So now, you have 1,000 queued
messages as one limit, and 4 MiB of serialized data as another limit.  And
also very important, LND could previously simply drop a message and then
process the next one.  But it's important to keep the order of the channel
state messages that you receive.  So now, if LND reaches a limit, it will
simply disconnect the peer instead of dropping the single message.  And then,
it will reconnect to the peer and re-establish the channel, which will trigger
all the messages in the proper order.

_Libsecp256k1 #1904_

The next item is from the libsecp256k1 repo.  We have a PR #1904.  So, this is
a follow-up to something we discussed in Newsletter #396, and which was also
discussed in last week's newsletter, when mentioning the latest release of
libsecp.  So, in PR #1777, as covered in Newsletter #396, libsecp added a new
API endpoint which allowed applications to supply a custom SHA256 compression
function at runtime.  However, the test suite around these compressed
functions was not as extensive.  It was simply about hashing a single 63-byte
message.  So now, the test suite is expanded to cover multiple real situations
where libsecp would use such a function, for example processing multiple
blocks or using the SHA256 state of one block into another block.  So now, the
new test suite uses different message lengths and input alignments and has, of
course, expected values that the external function has to arrive at the same
results.

So, this is also very efficient.  I believe in the PR description, yeah, when
measured locally, this takes 0.05 milliseconds, so this is barely noticeable,
while ensuring that an external provided function actually works in all the
different situations that libsecp would handle it.

_HWI #839_

And finally, we have a fix in HWI, the Hardware Wallet Interface repo, item
#839.  Here, several issues are fixed about PSBT parsing and transaction
reconstruction issues.  So, these were first some test-vector suites that were
present in BIP174 and BIP370 for a long time, but also some updates based on
some test-vector suites that were added in the last few months, or at least in
the last year, I believe.  So, very technical detailed things, such as when
reconstructing a transaction from a PSB2v2, HWI now applies the computed
locktime instead of leaving it at zero when an input omits PSBT_IN_SEQUENCE.
Also, for PSBTv0, HWI will now reject v2-only input and output fields.  So, it
ensures that v2 fields are not present in v0 PSBT.  Also, it strictly parses
the global unsigned transactions using non-witness serialization.  So, yeah, I
don't know if someone wants to add here anything.  Maybe, Murch, you have some
comments because this relates to BIPs?  No?  So, if anybody's curious, they
can look at all the updates.  There's a few other ones, but they're just fixes
to match the HWI implementation to the test-vector suites of both the BIP174
and BIP370, which define PSBTv0 and PSBTv2.  And that's the last item from
this list, and that completes the newsletter.  Thank you.

**Mike Schmidt**: Great.  Thanks, Gustavo, and thanks for co-hosting with
Murch and myself, and we want to thank Martin and fanquake for joining us
earlier, and for you all for listening.  Cheers.

{% include references.md %}
