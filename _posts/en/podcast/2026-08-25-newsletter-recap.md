---
title: 'Bitcoin Optech Newsletter #419 Recap Podcast'
permalink: /en/podcast/2026/08/25/
reference: /en/newsletters/2026/08/21/
name: 2026-08-25-recap
slug: 2026-08-25-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Bastien Teinturier, Salvatore Ingala, and spacebear to discuss [Newsletter #419]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-7-26/430578166-44100-2-7540e0b71a1d8.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #419 Recap.
This week, we're going to be talking about a reorg vulnerability in LND; we're
going to talk about a draft BIP for a rawtr() output script descriptor; and
then, we have a few items from our monthly Services and client software
segment, that we have Payjoin, we have some Ledger updates, among others; and
we also have no Releases this week, but we do have our weekly Notable code
segment.  This week, Murch, Gustavo and I are joined by some guests.  We'll
have them introduce themselves briefly.  T-bast?

**Bastien Teinturier**: Hi, I'm happy to be here.  I'm CTO at ACINQ, I've been
working on the LN, its specification, and Eclair, one of the implementations,
for many years, and on the Phoenix Lightning Wallet.

**Mike Schmidt**: Salvatore?

**Salvatore Ingala**: Hello, I do Bitcoin stuff at Ledger.

**Mike Schmidt**: Spacebear?

**Spacebear**: Hello, I'm a maintainer of the Payjoin Dev Kit.

_Reorg vulnerability in LND channel closes_

**Mike Schmidt**: Awesome.  Thank you all for taking your time to join us
today and talk about your news and software updates that you've been working
on.  For listeners, we're going to go a little bit out of order for our
guests.  We'll start with the first news item though, which is, "Reorg
vulnerability in LND channel closes".  Bastien, you posted the responsible
disclosure of a vulnerability in LND, fixed back in February in version
0.20.0.  But you work on Eclair.  So, maybe you can explain what you found,
what the impact is, and how you found it as well?

**Bastien Teinturier**: Yeah, and it's interesting because it may be the last
time we do that kind of thing; a vulnerability that was not found by AI.  So,
it feels quite low tech, it's interesting.  So, it was about a year ago when
we were working on splicing, on some splicing stuff related to onchain
confirmations, where we started a discussion about whether we needed to scale
the number of confirmations that we wait for an onchain transaction, based on
the amount in that transaction.  Because initially, many implementations did
that for channels.  When the channel was big, we would wait for more
confirmations than when the channel was small.  But with splicing appearing,
splicing made it more murky, because actually, if you have a small channel
that then you splice to a bigger one or the inverse, an attacker could
actually use the lowest of the two confirmations number that you use to attack
you, basically.  And we were questioning the fact that scaling confirmations
made sense entirely.

At the end of the discussion, I came to the conclusion, and others seem to
agree, that a static value was better.  There was no need to scale for 12 or
13 confirmations with a weird mathematical formula based on the amount.  And
just using six, eight, or ten confirmations was good enough.  And it's a
security parameter that we're explicit about.  If there's a longer reorg than
that, then there may be dragons and you have to make sure that it just doesn't
happen.  Otherwise, it's hard to protect from.  And while I was looking at
that, I was also making some tests around closing.  And right after that
discussion, I was doing an end-to-end cross-compat test between Eclair and LND
for a new type of closing protocol.  And I just ended up in an issue.  It's a
new closing protocol that actually lets you RBF.  And while doing that, I
inadvertently found that LND was forgetting the channel entirely after only
one confirmation.  And I think I just messed up a manual test that I was doing
and it gave me weird results, so I looked into it deeper and then I realized
that, yeah, they were actually forgetting the channel after only one
confirmation.

So, I reached out to Laolu, because I found a to-do in their code where
there's an explicit hard-coded one with a to-do for Laolu to fix that had been
there for years.  And they patched it quietly because at that time, you could
patch things quietly without AI actually figuring out that you were patching a
vulnerability.  So, it took a while before we announced it, because they were
also doing a lot of refactoring in that area.  So, it took a while between the
time I found the vulnerability and it was actually shipped to LND.  So, that's
why we're discussing on it now, something that was actually found, I think a
year ago, around that time.  And yeah, it's interesting because it showed that
this is something that you think you never mess up, that we all know that we
need to wait for absolutely more than one confirmation, that it's completely
unsafe to wait for just one confirmation.  But still, it can just slip in your
codebase and you just forget about it, if you defer to later handling that
correctly.

So, we've had a discussion on Monday at the Lightning Spec meeting to add a
new PR to the spec to make sure that everywhere we talk about onchain
transactions, we make it very explicit that you have to wait for enough
confirmations all the time, regardless of a transaction.  Don't try to be
smart and think, "Okay, that transaction is low value, so maybe I can do
something more smarter; or maybe I can let the node operator configure a
low-confirmation count".  That's just a bad idea, just don't do it.  So,
that's it.

**Mark Erhardt**: Yeah, especially this year when we finally had a two-block
reorg for the first time in almost 10 years or something; no, over 10 years,
12 years.  So, yeah, you need to wait for more than one confirmation.  One
confirmation is not enough because one-block reorgs happen somewhat
frequently; two-block reorgs about once every 20 years maybe.  Who knows?
Yeah, so the way I understood this vulnerability was when a channel gets
closed, LND was just seeing the confirmation and then forgot about the channel
ever existing.  And if that happens on a reorg block, they would be unable to
react to the channel counterparty broadcasting an old state in the reorg
branch, and thereby stealing the entire funds -- or if all the funds were on
one side at some point, they could, without repercussion, steal the entire
funds of the channel.

**Bastien Teinturier**: Yeah, exactly.  And maybe what happened is that this
happened because this codepath is for what we call cooperative closure, where
the two nodes honestly cooperate to create a closing transaction that has no
delays and everything; whereas they could also unilaterally close, which is
the more nasty, faster scenario.  And maybe since this is cooperative close,
not much care was given to it, thinking that this is an honest scenario.  So,
we probably don't need to look into it much, but you can actually turn a
cooperative close into a unilateral close afterwards.  So, there's no path
where you can be completely sure that your peer is honest.  You should never
trust them and always think that they could turn malicious at any point.

**Mike Schmidt**: T-bast, what does it mean to forget a channel?  What are the
mechanics like within Eclair or LND when a channel is forgotten?  Is it like
all records of that are purged from all data stores, or is it stop monitoring
for certain activity onchain or in the mempool?

**Bastien Teinturier**: Yeah, it's only the monitoring part, because I think
everyone keeps a record of every channel, even after it's closed, because it's
useful to remember channels that you had in the past with some people, for
example, just for accounting.  But it means that people stop watching the
chain and stop watching for transactions that would spend the channel
outpoint, thinking that it has already been spent, that it's fine; but
actually, it has not, and it could be spent by something else.  So, you
definitely need to continue watching the channel output.  And I think that the
most conservative behavior is, I think CLN (Core Lightning) is doing something
where even if they've seen six confirmations of a channel spent, they still
watch the output for 100 blocks, just in case something happens to be able to
react.  And Eclair, LDK, and LND just watch for the configured number of
confirmations, which is six in LDK, eight in Eclair.  And in LND, it seems to
be still based on the amount.  But yeah, I'm trying to get them to change that
and just use a static value that is either six, eight, or ten, or configurable
by the node operator, but never less than six.

**Mark Erhardt**: Yeah, 100 seems very conservative.  Six seems very
reasonable as a minimum.

**Bastien Teinturier**: Yeah, I think so too.

**Mike Schmidt**: T-bast, anything else you think folks should know about the
discovery and disclosure of this one, and how Lightning nodes handle these
sorts of things?

**Bastien Teinturier**: No, but on a related note about vulnerabilities as a
whole, just a reminder to everyone that the past four weeks have been
basically, everyone has been busy fixing bugs found by AI.  So, you should be
on the lookout for new releases of your software, and you should try to update
as soon as possible because, yeah, right now is not a good time to stay on an
old version for too long, because it's become really hard to hide fixes or
vulnerabilities.  For example, this one was fixed in February and nobody
discovered it and it didn't seem to be exploited.  But nowadays, if you're not
too dumb and you're an attacker, you would scan every commit made to every
codebase, asking an AI to search for vulnerabilities that were fixed in the
commit.  And even if you hide it, an AI will find it nowadays.  So, you cannot
assume anymore that people are able to covertly fix things in open-source
software.  So, you should upgrade as soon as there is a release that's coming
out.

If you've been looking, all implementations have been making a lot of minor
releases for the past few weeks, and I think this is going to continue for the
next few months.  So, make sure you update whenever it comes out if you want
your funds to be safe.

**Mike Schmidt**: So, maybe a slightly more aggressive updating for users.
I'm curious if there's something you'd like to share on the developer side of
things.  Like, obviously, you're getting these reports and making fixes.  Does
that mean the release cadence in projects will be a little bit quicker, or are
there other behavioral changes on the maintainer side?

**Bastien Teinturier**: Yeah, release cadence is increasing and I think we've
been seeing that for all implementations.  And coordination with the security
disclosure has been really nice so far.  It's really nice that there are a few
teams that are scanning Bitcoin projects using AI and giving funding a lot of
tokens to allow that.  And they're providing very high-quality disclosures and
reports.  So, this is really nice.  I think the process has gone very
smoothly, way smoother than I would have expected when we started seeing AI
finding vulnerabilities.  So, this is really nice.  And as a developer, it
just means whenever you get something, maybe nowadays you've been a bit
swamped by too many reports and it's hard to pass, but it's really important
to make sure that you go through everything, that you answer to people who
disclose the vulnerability, and that you fix everything because, yeah, this is
an exceptional time.  I think this is going to cool down in a few months.
We'll reach a stage where we fixed all the important things and we will be
more careful and we will proactively use AI to make sure that we don't
introduce new vulnerabilities like that.  But the next few months are going to
be quite busy.  But afterwards, it will get better, I'm pretty sure.  So, just
make it through that phase and then we'll be okay.

_Eclair #3352_

**Mike Schmidt**: Good context and potentially a good segue to some of the
Eclair PRs from the newsletter this week.  T-bast, Eclair #3352, which I
believe was the missing channel-reserve checks PR.

**Bastien Teinturier**: Okay, this one was actually found not by AI but by
fuzzing, and it was just found that we were not exactly following the spec.
So, we were a bit more lenient than the spec for some channel-reserve
requirements.  It isn't an issue in practice, because it only happens if
people accept very small channels with large dust limits, weird cases that
other defaults in the implementations reject anyway.  But yeah, Murch, you
have a question?

**Mark Erhardt**: Yeah, could you maybe first say what exactly the issues
were?  You're jumping into details.

**Bastien Teinturier**: Yeah, sure.  So, when you open a channel right now,
there's a concept of channel reserve, where you cannot completely empty your
channel by default.  We make sure that each peer in the channel always still
has something at stake in the channel, which means that they always have an
incentive to publish the latest state.  They always have funds in the channel
basically.  So, it's a way to make sure that they have no incentive of trying
to cheat when they don't have any stake in the latest version of the channel.
And this value is actually configurable.  And in the spec, we make sure that
it cannot be smaller than the dust limit, because the dust limit, contrary to
Bitcoin, is something that you can configure on the channel.  You can set a
higher dust limit than the actual onchain dust limit to make sure that some
small HTLCs (Hash Time Locked Contracts), for example, you could decide that
your dust limit is 2,000 sats, and anything that is below that, you don't want
it to materialize onchain, even though you could potentially spend it onchain
if the feerate was low.  If the feerate is high, you actually can't.  So, you
can decide from the start that you don't want to materialize those, and then
you keep your commitment transactions smaller.  And the combination of using a
large dust limit and a small channel reserve was a way for attackers to
potentially make their output of a commitment transaction disappear and thus
have no stake in a state of a channel.

In practice, since everyone has some same defaults where you don't accept
channels that are smaller than, for example, 100,000 sats, or even higher than
that, and you don't accept dust limits that are too high either, you cannot
run into these edge cases.  But we were allowing some edge cases if the
channel was very small and the counterparty was using a large dust value.  But
that couldn't happen with the default configuration values in Eclair, but it
could happen if you tried to configure your node to accept very small
channels.  But yeah.

**Mark Erhardt**: I have a lot of questions.  So, one of the criticisms with
the channel reserve is that I think it's, by default, 1% of the channel.  So,
often it is actually a very small stake compared to what could be taken by an
attack.  And this sort of ties in the argument whether LN-Symmetry without a
penalty is safe or not.  So, seeing people have more time to debate covenants
now again, given that other debates might be subsiding, are you still excited
about LN-Symmetry?  Is that something that the ACINQ team would be looking
forward to?

**Bastien Teinturier**: Yeah, I think so.  Yeah, I would be I'm excited about
that.  And I honestly don't think the channel reserve is a very good
mechanism, because it hurts UX and it hurts channel usability.  And I think
it's quite a weak disincentive.  You can only play that trick once.  Even if
we didn't use a channel reserve and you had a peer that chose to try to use a
revoked commitment while they didn't have any funds in the channel, and tried
to game that thing, basically as long as you watch the chain, they can't steal
money anyway.  And you can blacklist them and you can say, "I'm never going to
accept or open a channel with that node anymore".  So, I don't think we
really, really need that channel reserve.  I think it was a defense-in-depth
mechanism, but I'm not sure the trade-offs are really worth it anymore now
that we have mature implementations and we can detect that your counterparty
is being malicious and blacklist them.

So, I would be more in favor of going the LN-Symmetry route, where you just
react to whatever your peer puts onchain and there's no need for a channel
reserve for that.  And you just make sure that in case they publish something,
they still pay some onchain fees so they still have a cost.  And most of the
time, they will have been the one opening a channel to you anyway in the first
place, so they will have paid onchain fees at that time as well.  And if they
want to empty the channel, they will have had to send payments through the
channel to you.  So, you will have collected routing fees as well.  So,
there's a cost for the attacker; there's benefits to you because you've earned
some fees as well.  So, I think this can be made good enough so that we don't
need the channel-reserve mechanism anymore.  But that's arguable.  Maybe
others disagree with that.

**Mark Erhardt**: Well, I know one person at least will disagree with that.
But maybe that's a debate we can have another time then.  I have one more
question.  So, we haven't had you on in a while, but late last year the
default feerates dropped quite a bit.  And I was wondering, talking about the
dust limits and so forth, and you were saying at high feerates the dynamics
change, I was wondering how much have Lightning dynamics changed by feerates
dropping?

**Bastien Teinturier**: I'm not sure.  What's nice is that we haven't had to
feel the pain of a high-feerate situation basically.  We've had time to fix a
lot of force-close issues that started appearing when nodes disagreed on
feerates.  So, we are more ready to a high-fee environment than we were a few
years ago.  So, I think we should be more robust if a high-fee environment
arrives today.  The main thing that it has enabled, having a very low feerate,
is that nodes have been very more aggressively reallocating liquidity
frequently, basically.  And activating on your node, we've activated on our
node something that we've spent years debating whether it made sense or not,
or would be just wasting money, basically algorithms and heuristics to
constantly monitor our channels, decide where liquidity is needed and where
liquidity is idle, and proactively close channels or splice channels and open
new channels to proactively have liquidity where it makes sense.  And this is
something that we've activated in March or April, and it's been running really
well on our node.  And what makes it very easy to be economically viable is
that the onchain feerate is really low.  So, it's really easy to earn more
fees by doing that with your routing afterwards than the fees you've paid for
the onchain transactions.

If the onchain fee was maybe even 10 sat/vB (satoshis per vbyte), it would be
already way too much for the frequency at which we move liquidity around.  And
by default, our algorithms stop if the feerate is too high.  But that let us
experiment a lot with that liquidity allocation heuristics, and that was
really nice.  And I think we're not the only implementation that has something
like that.  So, it was really nice to have a low-fee environment for a long
time.  And it's nice if it continues, except for miners and maybe security
eventually, but at least it gave us time to make sure implementations were
robust enough to work well in a high-fee situation, even though some things
are still more annoying or less efficient if the onchain feerate is too high.

**Mark Erhardt**: Yeah, I see that TRUC (Topologically Restricted Until
Confirmation) transactions have rolled out now too, to some implementations at
least.  Thanks for sharing details on what's going on in the background.

**Bastien Teinturier**: Sure, my pleasure.

_Eclair #3351_

**Mike Schmidt**: We have Eclair #3351, which was the PR around on-the-fly
funding fixes.  Yeah, and this one was definitely vulnerabilities found by AI,
but in a feature that nobody uses except us with Phoenix.  On-the-fly funding
is the feature we use when some Phoenix user is going to receive an HTLC but
they don't have enough liquidity.  We have a feature where we on-the-fly
create a new channel or splice the existing channel and negotiate fees with
the Phoenix user before accepting the payment.  And since we also use
zero-conf, we can increase the size of the channel with the zero-conf splice,
and then forward the HTLC through.  And there were a few edge cases in there
where malicious Phoenix users basically could have stolen funds from us.  All
of those are quite nasty edge cases.  You really have to look at the code
deeply and figure out a way of stopping the protocol at some point, and then
restarting and abusing it in some ways.  But there were bugs.  There were
things that we should have caught and we could have caught without AI if we'd
been smarter, basically.  But it's really nice that AI caught them and gave us
an opportunity to fix all of those.

Since it's a feature that only our node uses, it was easy to just patch our
node and then do a commit on master, because then we don't care if an attacker
discovers the issue, it's already been patched on our node.  And there was no
issue on the Phoenix side.  It was only Phoenix that could be malicious and
steal money from our node, and it hasn't been the case, we haven't lost any
funds with that.  But we've still put this feature on master, because a few
years ago, there was a somewhat equivalent protocol that was created years ago
for LSPs (Lightning Service Providers).  I think it was called LSP
Spec-something.  There was an effort to create LSP standards.  And at the
time, we explicitly said that the Lightning protocol was not ready, and the
way they were doing it was not a good long-term idea.  And I think it was
three years ago that we sat down together and I convinced them that it should
have been done differently.  And on-the-fly funding is the protocol that
should be used onwards by all implementations when they want to do on-the-fly
funding with an open LSP spec.

But I think that right now, LDK has been working on an implementation but has
not shipped it yet.  And nobody is actually running Eclair with that feature
on.  So, that's why it felt safe to just publish it on master without trying
to hide it.

_Eclair #3345_

**Mike Schmidt**: All right.  We can move to the last Eclair PR, which is
#3345.  This was around gossip query resource limits.

**Bastien Teinturier**: And I think there have probably been a lot of similar
PRs in all implementations, because gossip is basically the part of Lightning
that nobody loves.  Everybody says, "Yeah, we've done that thing.  It was the
easiest way to get the job done, but it's not elegant, it's not efficient, and
we should rework it entirely and just drop everything we have at some point".
But the nicer way to do it in the future, we've never been able to find the
right set of trade-offs without adding too much complexity.  It's been
progressing recently.  But still, it's going to take time before we can
entirely remove the existing gossip protocol.  But that gossip protocol gives
a lot of opportunities for abuse basically and for DoSing parts of your node,
and every implementation had issues with that.  So, this is basically getting
rid of a lot of those potential DoS vectors that could be abused by attackers.

In Eclair, we have something that I don't think other implementations have, is
that we have a cluster mode where you can actually run Eclair on multiple
machines.  So, there's a backend machine and frontend machines, and you can
elastically increase the number of machines you run in the front.  And all the
gossip is managed at the front, so you are somewhat resistant to DoS, but just
up to a point.  If the attacker still has way more resources than the number
of machines that you are ready to throw at the problem, they can still DoS
you.  And in this PR, we've basically batched a lot of fixes around gossip
that were found by AI.  And we knew we had them for years, and we always
thought, "Yeah, but nobody is going to bother exploiting that.  It cannot be
used to steal funds".  At least most of them cannot, because in Eclair, the
gossip part cannot take up all of your CPU and all of your bandwidth.  You
will still be watching channels and making sure that you react to channels
being closed.  But still, it can prevent you from running your node
efficiently and relaying payments efficiently.  So, it was high time we fixed
all of these.

**Mike Schmidt**: Yeah, we had Gustavo, who covered the LND adding similar
protections a few newsletters ago, and then some, I think it was last year.
And then, we even talked about rate-limiting, relay and Bitcoin Core, I think
it was last week.  So, I guess similar-ish kind of handling on the L1 side.
Yeah, Murch?

**Mark Erhardt**: I was wondering, could you maybe tell us in a few sentences
how the gossip protocol has been evolving in order to improve?

**Bastien Teinturier**: Not much!  That's the issue.  It hasn't been evolving
much.  So, we started with a very dumb, very easy gossip protocol, where
there's an announcement for every channel, and then each side of a channel can
make an update for their fee parameters basically.  When the channel is
created, you announce it with this channel announcement.  It happens only
once.  It can rehappen afterwards if you do a splice, then you can announce
that splice.  But channel announcements are things that don't happen often.
But channel updates are things that can happen often, because you update your
fees if you see that you are not attracting payment enough, or attracting way
too many payments and could earn more money.  And initially, we just started
with a very dumb protocol where on connection, you can tell your peer when you
connect to them, "Please just dump everything, send me everything".  So, this
is the first issue, because if, as the other node, you accept sending all of
your gossip to anyone who connects to you, you use a lot of bandwidth
potentially and people can abuse that.  So, you have to limit how many people
can be asking for the whole gossip from you.  And then, the other mechanism is
that whenever you receive new gossip, you queue everything for 30 seconds; and
every 30 seconds, you send the new gossip you recently received to all of your
peers.  And that part is actually what works well enough and what guarantees
that usually, you don't need to have a full sync at the beginning.

But then, to be more efficient, we added two extensions to gossip that were
called channel queries.  I think both of them were gossip queries and gossip
queries extended.  And those are somewhat slightly more complex messages where
you can say, "Send me the gossip that happened between that block height and
that block height".  But actually, that protocol wasn't very well designed,
and it's really hard to implement, while handling all the edge cases, where an
attacker doesn't behave according to the spec and actually asks you for
redundant things or overlapping ranges, that kind of stuff, and they can make
you waste bandwidth that way.  So, that's the things we've tried to fix.  But
overall, this whole protocol is quite prone to abuse, because there are a lot
of edge cases in the way it was designed.  It helped up to a point.  It helped
us get rid of, "Just dump the whole graph on connection".  We can be a bit
smarter and dump less than the whole graph.  But it's still way too noisy and
wasting way too much bandwidth compared to what we could do if we were really
smart.  But nobody really wanted to tackle that problem, because that was
basically a low-priority issue.  It still works, and as long as everyone is
honest, it doesn't use that much bandwidth.  But it only becomes a problem
when too many people start being malicious and start trying to attack your
node, which is something that we may see happen now.

So, it becomes more important that we fix these things, and potentially move
to a different gossip protocol that makes more sense and is more
DoS-resistant.

**Mark Erhardt**: This was reminding me of some discussions I had with Sergio
about Erlay over the years, and I was just wondering, since there are frequent
gossip updates and the gossip also has to traverse the entire network, but
each peer only wants to tell the other peer if they don't know about it yet,
would there be some sort of potential to use something like Erlay to just
reconcile what you would be announcing to each other instead of sending all
the data?

**Bastien Teinturier**: Yeah, definitely.  And there was some effort, I think
even five years ago, looking at Erlay and figuring out how we could use
sketches like that for our Lightning gossip.  We had early designs, but nobody
actually wanted to spend enough time to ship it.  But very recently, I think
this year, it started, JHB, Jonathan Harvey-Buschel, started working on that
again, and he's made some progress.  He's shared where he was at, so this is
getting revived.  And maybe with the rise of people trying to DoS nodes,
people will prioritize that more.  I think one of the reasons people were
reluctant to touch gossip is that we only wanted to change gossip when we also
had an opportunity to include taproot channels, which we couldn't include
before; and also, to avoid pointing in our gossip at the exact onchain
outpoint for the channel, because this is a huge privacy leak, and we've
always said that we need to fix it at some point.  But the issue is that
nobody wanted to touch that gossip to do only part of the things we wanted to
do.  And everyone said, "Oh, we should take this opportunity to do
everything", but everything was way too much, so we actually never did it.

But I think there's some progress and we are potentially more ready to accept
that we're only going to do part of the thing, like do the sketch-based
reconciliation, without yet removing the link to the onchain outpoint and
maybe doing it in another phase.  So, I don't know.  It really depends on what
other implementations also want to do.  But I think we may actually see this
progress and potentially ship in the next couple of years.  I hope so, because
it's a much nicer way of handling gossip, and it's cool math.  So, it's cool.

**Mike Schmidt**: We covered the Gossip Observer and JHB's work in Newsletter
#396, and we actually had JHB on to talk about that and the equivalent podcast
as well.  So, if listeners are curious as to what t-bast and Murch are talking
about, you can dig into that a little further.  Anything else?  Any other
Eclair things that are interesting since we have you on?  Phoenix?

**Bastien Teinturier**: There's a lot of things happening.  I think, for the
past four weeks, us and all other implementations have mostly been able to
ship a few specification stuff.  For example, the fulfillment payload
mechanism that LDK and Eclair worked on.  That's interesting and that's
something that is shipping and that will be helpful in the future.  But apart
from that, we've mostly done bug fixes and defense-in-depth, and making sure
that we remove technical debt in many places in the codebase.  But yeah, that
fulfillment payload is interesting.  In a nutshell, we had a mechanism when
you send an error.  So, payments in Lightning are onion-encrypted, so it goes
through multiple hubs and every hub has an encryption layer for them.  So,
when you have a sender and you receive a response, anyone in the path could
have potentially modified that response.  And for our messages, what we do is
that the recipient creates an error encrypted for the next node; the next node
re-encrypts for the node before them, and before them, and before them.  And
then, if everyone was honest on the route, the recipient is able to decrypt an
error message that comes from the recipient to figure out if the payment
reached the recipient, and why it failed.  But anyone on the route could
actually modify that and you wouldn't know who modified it, so you cannot 100%
rely on it.

But then, one or two years ago, Joost studied an interesting protocol addition
that's called attribution data, where you also include a ton of HMACs
(Hash-based Message Authentication Codes) basically for many combinations.
And if someone cheats along the route, as the sender, you are able to discover
which pair of nodes is responsible for dropping the error.  So, potentially,
you can decide to just ban these two nodes, and this way you're pretty sure
that you're going to avoid malicious nodes in the future.  And at that point,
we realized that we were sending a message back from the recipient to the
sender only for failures.  But it actually also made sense to do the same
thing for fulfills.  When the payment actually succeeded, it actually makes
sense that atomically, while sending back the preimage to the sender, you can
also include just a blob of data that could be reused by many applications.
For example, one of the applications that wanted to use that was zaps that
would get all the way to the sender.  And we never did that before because we
didn't have a mechanism.  We couldn't rely on it and we had no mechanism to
figure out which pair of nodes was potentially tampering with that data or
dropping it.  But combined with attribution data, it's actually a handy way to
get data back from the recipient when the payment succeeds in a way that is
not 100% reliable, but can be used in potentially many cases, at least in
happy cases, and can improve UX.

**Mark Erhardt**: Right.  So, when the data comes back, you know that it is
authenticated and it must have come from the recipient.  When the data does
not come back, it is sometimes difficult to assign exactly where it failed.
But now, with attributable data, you know that it was a specific hop.  So,
either the node before or after the hop, right?

**Bastien Teinturier**: Exactly.

**Mark Erhardt**: So, you can narrow it down to the pair, but you can't assign
which of the two?

**Bastien Teinturier**: Exactly.  Having that is really interesting because if
we didn't have that at all, people could cheat without being detected.  So,
they potentially had an incentive to continue cheating and they would not get
caught and they would stay in payment paths.  But now that you can narrow it
to two nodes, if everyone starts actively routing around these nodes,
eventually they lose a lot of traffic.  So, it incentivizes everyone to just
be honest.  And if everyone is honest, the feature works perfectly, and you
are able to get data back from the recipient on fulfills.  So, this can be
interesting, and it's a kind of general mechanism where for now, we're just
transmitting a blob of bytes that can be used for anything in the future.  So,
that's the only interesting feature that was shipped in the past month between
implementations.  And the rest, if you look at it, is mostly defense-in-depth,
bug-fixing, DoS-resistance, and hardening all implementations, which is a good
thing to do, because we always say that it's a good thing to just pause, do
less features, and more hardening and making sure that nodes are more reliable
and secure.

**Mike Schmidt**: Yeah, and of course it's not just Lightning implementations.
I saw BTCPay Server posting similarly that the next few releases or so are
going to be focused on cleanup, hardening, security, these sorts of things.
T-bast, thanks for walking us through those PRs and the News item.  We
appreciate your time.

**Bastien Teinturier**: Thanks for having me.

_Ledger Bitcoin app 2.5.0 adds human-readable policy descriptions_

**Mike Schmidt**: Yeah, cheers.  We're going to jump to the Changes to
services and client software segment for our next two guests.  First one,
"Ledger Bitcoin app 2.5.0 adds human-readable policy descriptions".
Salvatore, you're here to represent this item.  Tell us about 2.5.0 and maybe
just quickly, what is the Ledger Bitcoin app?  And then we can get into the
features in here.

**Salvatore Ingala**: Well, yeah.  The Ledger Bitcoin app is the application
that runs on the device.  So, whenever you send a transaction with the Ledger
device, like for each cryptocurrency, there are separate applications.  So, in
the Ledger system, there is a distinction between the OS and the applications.
So, the firmware is not monolithic.  And so, all the features that are
relevant for Bitcoin are implemented in the Ledger Bitcoin app, which is what
I work on.  And yeah, in this release, finally, I had the first version, which
will not be the final version, but it's the first version that I'm comfortable
releasing, which I think also the UX is good enough and it will be a good
improvement, and I can release in a version that gives me some comfort about
some potential risks of implementing this feature.  And we can talk about why
this feature is not trivial to implement.

So basically, for any wallet that is not a single-signature wallet, whether
it's multisignature or something more complicated, like miniscript, all
hardware wallets require an additional step, which you do only once, which is
the registration of this descriptor or wallet policy on the device, which
basically allows to teach the device exactly how that wallet works and how the
addresses for the wallet are generated.  And this is an important step in
terms of security, because that descriptor or that wallet policy describes
exactly what all the addresses of that wallet are.  And so, if you send money
to an address which is not derived by the correct script, or money goes
elsewhere, then you will not be able to spend.  And especially in the case of
miniscript, it's more complex than for multisig, because there could be more
complicated schemes of how you're protecting your funds.  So, you could have
alternative spending paths.  So, you could have, for example, one primary
policy, which is a 2-of-3; but then, you have some recovery path, which is a
1-of-3, but it's only active after six months, something like this.  And you
can make arbitrarily complicated schemes.

We have seen a bunch of wallets and companies that are kind of pioneering
these kind of schemes, like there is Liana, of course, which specializes
exactly in this scheme, where you have a primary spending path and you have a
recovery path.  There is AnchorWatch that is using miniscript to provide a
wallet that, together with the wallet, they provide an insurance service on
the funds.  And there are a few more.  There is Keeper and there is Nunchuk
that are mobile wallets, and probably a few more.  So, I apologize for anybody
I'm not mentioning.  At this point, there are several.  So, all these wallets
provide these innovative features.  But from the point of view of hardware
signing devices, what we care about is that nothing can happen that the user
is not aware of.  So, we have what is called Clear Signing.  So, whenever you
sign something, you know exactly what you're signing.  And in the case of the
registration of multisig or miniscript policies, well, there is another
aspect, which is we want to know exactly that what you're registering is what
the user intended.  Because the registration step is something that you do
only once before you start sending funds to the wallet.  So, if you do it
incorrectly and you send funds to the wrong wallet, you might discover it
later that something went wrong.

So, there are two potential risks here.  One is in common with multisig, and
one is more specific to miniscript.  So, in the registration step, for
something like multisig, the only thing that matters is that you have the full
backup of all the other xpubs that are involved in the multisig.  So, the
cosigners will share with you an xpub, and you will register those are part of
the wallet policy.  So, it's not enough to have enough cosigners to be able to
satisfy the policy, but you also need to make sure that you have a backup of
the policy.  So, you need to have all the xpubs.

**Mark Erhardt**: Maybe let me jump in here briefly to just explain this.  If
you have a multisig that is hash-based, the output script only commits to the
hash of the input script or the underlying spending conditions, and it's not
revealed onchain.  So, if you do not have the backup of the xpub with all the
public keys, even if you have enough signing keys, so let's say we have a
3-of-5 here and you have three of the signing keys, but you don't know the
public keys for the fourth and fifth key, you would be unable to reproduce the
spending script.  And thereby, you would be unable to spend your funds because
you cannot show what the script was under the hood that you would be signing
for, even if you can sign for it.

**Salvatore Ingala**: Yeah, thank you.  And yeah, so with other signing
devices, we are in an adversarial setting where we don't trust even the
software wallet that is setting up the actual registration on the device.
Because here, a potential attack that we've not seen happening in practice,
but of course, with more people using these schemes, we might in the future
see happening, and so we want to think about this in advance, is that malware
could replace even just a single xpub of your wallet.  And so, when you have a
backup of a descriptor, but then one of the xpubs is wrong, because you didn't
check it compared with what you saw on the screen, at a later time when you
try to recover from your backup, the funds are not exactly in the same place
where you thought they were going, and you don't have a backup at all.

**Mark Erhardt**: Right, so basically, on display in your computer with your
companion app, it shows you, "Yes, absolutely, I'm using the wallet that you
have been inputting".  But then, what it sends to the hardware device over
cable would be a modified output script.  For example, you said a 1-of-5
instead of a 3-of-5.  And because the hardware signers have such a limited
interface, you need to verify what the hardware signer received and look at
the display of your hardware signer to verify that what it is registering is
what you intend for the hardware signer to participate in.  Because otherwise,
the companion app, if it is malicious, could make you think that you
registered something else than your hardware signer actually sees.

**Salvatore Ingala**: Yeah, precisely.  And for simple multisig, the only
ambiguity, apart from the threshold of course, 3-of-5 or 4-of-5, the user is
likely to notice if a number changed.  So, the only real ambiguity that is
kind of easy to trick a user is on the xpubs; while for miniscript, when you
register a miniscript wallet policy on the device, it shows two things.
First, it shows the general structure of the spending policy, which is what
are the different spending conditions.  And then, it shows you all the xpubs.
So, the second part is the same as for multisig, while the first part is
specific to more complicated schemes, because you could have many alternative
spending paths.  And so, until now, what was shown on the screen was what
BIP388 calls the descriptor template.  So, probably more people are familiar
with the descriptor.  The descriptor template is just the descriptor template
once you strip all the xpubs out, and that helps to make it a little bit more
readable already.  But still, once you start using more complicated
miniscript, potentially with multiple spending policies, with several recovery
paths, this starts to become bigger, especially on taproot.  And so, this
stream becomes hard to read.  Even for technical people, it's actually not
that easy to read.  And definitely for non-technical people, we can tell them
to compare with their backup.  But if the backup is already wrong, because the
wallet policy means something else which is not what they intended to
register, they might not notice.  So, this is kind of a potentially increased
risk that we don't have with multisig and we want to address.

So, what this new release does is a feature that only works for taproot
miniscript.  There is a number of reasons why it's actually much easier to
solve this problem in practice on taproot.  And so, for a number of patterns
that are common for taproot miniscript policies, it explains all the
alternative spending paths in a clean way.  And so, it will list all of them.
So, there are some screenshots in the post that is linked in the Optech.  It
will list all the alternative spending paths in a human-readable way.  So, it
will tell you, like, one of them is a multisig 2-of-3; if there is a timelock,
it will tell you how many blocks or how long in the future will be, so there
is a clear description.  And so, there is quite some work that people don't
see that doesn't necessarily matter this much for this release of the app.  It
might matter more for a future version of the app, because right now the app
shows both the clear text description and the descriptor template.  So, the
instruction for the user will still be to compare with their backup the
descriptor template.

But one thing that I was worried about is that the moment you start to show
the clear text, people might be more likely to skip the second step.  And for
a future version, it might actually be interesting if we could actually keep
it secure even if they don't check the descriptor template, they only check
the meaning of the policy.  So, this is a challenging problem because one risk
that we didn't mention is that it's not only a problem if malware changes the
policy with something that is a completely different policy, but there could
be a very large number of policies potentially that have exactly the same
meaning; so, the script onchain is completely different, but the actual
meaning is the same.  So, the moment you show the clear tech description of
the policy, what they see on screen is basically the same, or it could be
actually exactly the same.  But there are potentially a very large billions of
scripts that actually are different onchain, but they have the same meaning.

So, some work that was done in the published crate, which is experimental,
it's not production-ready, but was good enough for me to convince myself that
this risk is bounded on the kind of policy that we are showing clear text for,
is that for those policies, I actually can estimate how many descriptor
templates will have exactly the same clear text policy.  And there is a grid
that actually can enumerate all of them.  So, we know that if the user knows
the meaning of the policy, even if they lost the descriptor template, we will
be able to brute force all the possible policies and find which one.  So, this
is not something that the app does or needs to do.  But knowing that the
recovery tool is available, for me, I don't feel comfortable releasing the
feature without having that, let's say.  And so, for a future version that
might potentially make it safe to not show the descriptor template at all, I
decided not to try this approach for now, because you cannot do that without
opt-in from the software wallets, because you want the software wallets to
also show the same thing.

So, I think we can get, let's say, 80% of the UX benefits of the feature in
this version that does not require any change in software wallets, and it
already vastly improves the experience of the users.  Because the nice thing
of the registration in miniscript policies is that you only do it once.  So,
it's actually a very small amount of time in the whole lifetime of your usage
of the wallet.  But it's something that you have to do at the beginning, right
before you start using your wallet.  So, especially for non-technical people,
it can be a scary step.  So, making the UX better and more friendly in this
part, I think it matters a lot and it might convince more people to use these
kind of schemes that are actually much more secure in practice.

**Mark Erhardt**: Yeah.  I was wondering, with UX-focused changes like this,
do you do user testing?  Do you put this in front of some potential Ledger
users and see how they interact with it?

**Salvatore Ingala**: I mean, mostly my user testing was pestering Liana team
and pestering Rob to show the feature and everything.  Yeah, and that's why
also this version of the feature, I'm much more comfortable releasing it,
because it's just a clear improvement in the UX, and we can still change it if
people suggest improvements.  Because it doesn't require coordination with any
other wallets, we can still improve it after we see how people use it, if they
find it comfortable.  Like, if there are things that people find confusing, if
there are some other ways of presenting the same things, like I made quite a
few iterations on how we present these things to the users.  This is one thing
that with byte-coding becomes nice, you can easily rewrite prototype things.
So, I probably had ten different versions that I went over and over changing
things before I decided, "Okay, this is the version".  And so, I'm quite
convinced that the UX is much better and is pretty good.  It's not perfect
probably, we'll see, and there is definitely room for improvement, and we will
definitely improve in the future.

I mentioned already that it does not cover all miniscripts.  That's kind of a
problem that I don't know if it's solvable to cover all miniscripts, but I
think it will cover the vast majority of the miniscripts that people are
already using in practice.  And we can always extend the coverage in the
future with more policies.  So, the reason this problem is actually easier to
solve on taproot is precisely because on taproot, people naturally will tend
to put the alternative spending paths in different leaves, which make the
typical leaf quite small.  So, the typical leaf often, with a few more
exceptions, but typically it's either a single-sig or a multisig or a MuSig
now, or these things with a timelock.  And there is not much more that you
might want to do in a single leaf, generally speaking.

**Mark Erhardt**: Although there are reasons to use an IF statement
occasionally.

**Salvatore Ingala**: Yeah, sure.  But actually, I'm not sure if any of the
miniscripts that would have the IF statement is covered in clear text
actually, because they don't occur a lot in practice.

**Mark Erhardt**: Don't undermine me now, but yeah, I know.  Thanks for
keeping me honest!  It was more meant as a joke.

**Salvatore Ingala**: Yeah, I should check, actually.  I don't remember if any
of them, because there are several fragments that have the OP_IF inside, and I
don't remember if any of them is in any of the patterns that are covered by
the current scheme.  But yeah, I think we covered most of the things that were
to be said.

**Mike Schmidt**: Salvatore, are you familiar with the Cofund multisig wallet?

**Salvatore Ingala**: Not a lot, actually.  I've seen it on Twitter, but I
didn't dig it exactly into the details.

**Mike Schmidt**: We cover it later in the newsletter and just wasn't sure how
much you were aware of that, just since it was a similar-sounding policy-based
taproot architecture.

**Salvatore Ingala**: Yeah, I think for policies there, they mean something
like cosigner policies, which is not the same meaning as wallet policies here,
because wallet policies here are passive, meaning once you define the wallet,
it's done; while that one is for a cosigner, it's online and it checks your
transaction before signing.  That was my understanding.

**Mike Schmidt**: Makes sense.  Salvatore, I guess the call to action, since
this is released, is if folks are using the Bitcoin app to update, and if
there's somebody who tinkers around and wants to create a new wallet, go for
it.  And obviously, new users that would go through that flow will just
probably not be listening to this, but they'll get that benefit?

**Salvatore Ingala**: Yeah, for users, if there are any technical users who
see this, of course any feedback on potential improvements is appreciated.
And for developers especially, well, look it up and try it out and see how it
fits in your wallet because, yeah, potential future versions might need opt-in
from wallets.  So, if you're interested in this kind of development, please do
reach out and let me know.

**Mike Schmidt**: Awesome, Salvatore, thanks for joining us.  We appreciate
your time.  We understand if you have other things to do, you're free to drop.
Cheers.

**Salvatore Ingala**: Always a pleasure.

_Payjoin Dev Kit (rust-payjoin) 1.0.0 released_

**Mike Schmidt**: We're going to jump to the Payjoin item, Payjoin Dev Kit
1.0.0 being released, and we have spacebear here to talk about that a bit.
Spacebear, the Payjoin Dev Kit project, you shipped your first stable 1.0
release.  Congratulations.  You can come here and do your victory lap.  But
maybe before you do that, maybe remind listeners what Payjoin is and how
Payjoin Dev Kit fits into that ecosystem, and then we can get into what's all
in that 1.0 release.

**Spacebear**: Thank you.  Yeah, I'm happy to be here.  So, Payjoin is really
the simplest form of interactive transaction construction between a sender and
a receiver.  If you add a round of interaction, you can build a transaction
together before broadcasting it.  And this basically allows the two parties to
consolidate their transaction intents.  So, for example, as a receiver, I
could consolidate some UTXOs of mine while I receive a payment from a
Payjoin-supporting sender.  Alternatively, I could do something like do some
output substitution to essentially, for example, if I have a Lightning wallet,
I could fund a Lightning channel by substituting the output script.  And then,
I don't need to have two separate transactions, where I first fund my
Lightning wallet onchain and then open a channel in a separate transaction.
So, yeah, that's kind of Payjoin at its base level.  And then, if you
carefully construct that transaction, you can also break the common input
ownership heuristic.  Essentially, all the inputs in that transaction don't
belong to the same owner, which is a very common heuristic used by chain
analysis companies to essentially create these clusters of outputs.  Yeah,
Murch?

**Mark Erhardt**: Yeah, maybe even more general, a Payjoin is a transaction
where the sender and receiver construct a transaction together and they both
contribute inputs.  So, it's sort of a very simple multiuser transaction.

**Spacebear**: Yeah, exactly.  So, that's the fun thing, is the input
contribution is kind of optional.  Like, you could do something as simple as
just substitute the output script, and then you don't even need to contribute
an input.  So, in the case where you want to, for example, do a funding
channel or even do like an Ark funding transaction, you could do that and just
substitute the output script.  And then, in this situation, there's not
actually any new inputs being added to the Payjoin.

**Mark Erhardt**: Oh, that's cool, I hadn't even considered that.  Basically,
you just do the transaction cut-through portion of it.  So, instead of making
another transaction that spends the output that you receive in the first
payment, you immediately make your second payment, but you don't even
contribute an input.

**Spacebear**: Yeah, exactly.  So, yeah, like you call it, it's a transaction
cut-through use case.  It's a pretty cool use case.  But as far as when people
talk about Payjoin, in most cases they're talking about receiver as an input.
It's kind of like the simple Payjoin use case.  So, yeah, because this
transaction construction is interactive, the Payjoin Dev Kit tries to abstract
away a lot of the internal validation and other operations that each party
needs to take.  And one big part of that is the ability to resume sessions or
survive restarts, or your counterparty going offline and then being able to
pick up where you left off.  And also, the ability to tell, "Is the ball in my
court?" if your server went offline, or if it's the counterparty's turn and
you're just waiting.  And with BIP77, this can be implemented without having
to actually run your own server.  So, the server part is delegated and both
sender and receiver don't have that liveness requirement or that online
requirement.

**Mark Erhardt**: Right.  So, this is the third coinjoin proposal that we
track in the BIPs.  BIP79 proposed Bustaay; 78 was the synchronous payjoin;
and 77 is the asynchronous payjoin, where the server is a third party, an
untrusted third party, that is used to facilitate an asynchronous
communication, where the payjoin provider or the recipient doesn't have to run
their own server.  So, for people following along, the numbering is odd here
because it counts down rather than up in a sequence of time.  So, maybe since
the asynchronous part is the cool thing, could you elaborate a little bit on
how 77 works differently than 78?

**Spacebear**: Yeah.  So, 78 was a pretty naïve implementation in that
essentially, the receiver just ran a server themselves, and then there was
some communication between the sender and the receiver that was going through
that server, which is simple enough to implement, especially in a use case
like if I'm running my own BTCPay server instance, I'm already running a
server.  So, it's just adding functionality to that existing server.  But for
mobile wallets or just even a desktop wallet, where you're not necessarily
running a receiver or you're a less technical user, you won't be able to run a
server.  So, BIP 77 delegates that server responsibility and now you have an
untrusted third-party server.  And it essentially just passes messages back
and forth between the sender and the receiver.  It uses two open standards.
The first one is HPKE (Hybrid Public Key Encryption), which essentially
encrypts all the data that goes through the server, so the server can't see
the contents of the message; and the second standard is OHTTP (Oblivious
HTTP), which obfuscates the source and destination of the messages, so the
server can't see who's sending messages.  And it accomplishes that via kind of
like a one-hop tour.  So, there's another relay server that stands between the
directory and the client.

So, one other library that we may maintain with the Payjoin Dev Kit is what we
call the mailroom.  And so, the mailroom is one binary that combines the
directory and the relay.  So, you run that one thing and now you're reachable
as both a relay or a directory.  It has some loopback protection so that if
someone tries to use the same mailroom instance as relay and directory, it
will block that because that defeats the purpose of OHTTP.  So, yeah, the idea
is to have many mailroom instances, and you can just kind of pick and choose
which ones to use as relays and which ones to have as directories.

So, yeah, for the first release, I mean really what the bulk of this release
is, is having a commitment to the core payjoin state machine, meaning that a
session that you started today, if you upgrade the software version, you'll
still be able to replay those sessions in future versions.  And so, a lot of
that work happened over the last 18 months or so.  And we had prior versions
that implemented early versions of this persistence, but a lot of the kind of
edge cases outside of the happy path, that's where the bulk of the work was,
getting graceful error-handling and kind of easy UX where you can resume a
payjoin and no, like, "Oh, maybe I should cancel this payjoin now and
broadcast the fallback transaction".  So, the fallback transaction is just
like a naïve regular Bitcoin transaction where the sender pays you; so, having
these kind of easy-to-use checkpoints for implementers, where you know what
the state of the payjoin is and what you should do with it, even if something
went wrong.

**Mark Erhardt**: Right.  So, maybe tell us a little bit about how the Payjoin
Dev Kit would be used by, I presume, wallet developers?

**Spacebear**: Yeah.  So, currently we have Bull Bitcoin Mobile and Cake
Wallet that are actually using the Payjoin Dev Kit.  And so, the Payjoin Dev
Kit, so we have rust-payjoin, which is the core library, and that's where we
just released the 1.0.  It's actually rust-payjoin.  And then, we have
language bindings for Dart, Python, C#, and JavaScript that are supported now,
and we plan to add more.  But so, both Cake Wallet and Bull Bitcoin Mobile are
using the Dart bindings.  So, if your wallet uses any of these languages plus
Rust, then you can basically grab the payjoin package that's on those
languages' respective package manager sites, and then you can plug that into
your wallet.  So, I feel like the way to do this today is to give your cloud
instance the link to the payjoin library and tell it to go vibe code a draft
implementation.  The nice thing is that because the type state machine is very
strict and it's all validated in Rust, there are very few footguns that are
still actually viable for an implementer, because there are all these checks
that are mandated.  And so, even in a kind of vibe-coding scenario, of course
with review, but all these checks are mandated, so you're not going to, like,
skip a crucial payment amount check or something else like that.

**Mark Erhardt**: So, does it come with an implementer's guide or something,
or is the BIP the implementer's guide?

**Spacebear**: Yeah, right now we have a reference implementation, the
payjoin-cli, which is essentially like a plugin on top of bitcoin-cli.  So, if
you have a bitcoin-cli wallet, you can just install the payjoin-cli tool, and
that gives you additional send-receive commands that support payjoin.  And the
goal with that is to serve as a reference implementation that has all the best
practices and demonstrates those edge case paths, like canceling or
broadcasting a fallback transaction, and all these other things.  Another
thing that we're focused on now is actually writing up case studies on how
other wallets use PDK, like Bull Bitcoin Mobile, and coming soon is more
exchange integrations; so, for always-online servers, how to actually
implement this safely.

**Mark Erhardt**: So, let's say I had a wallet that supports payjoin and I'm
interacting with a recipient that supports payjoin, how would they discover
that they could do a payjoin?

**Spacebear**: So, I mean, assuming the payjoin setting is on, essentially
it's a parameter in the Bitcoin URI.  So, you have your regular Bitcoin URI
with the address and maybe the amount, and there is an additional parameter in
there, that's PJ, with the URL of that server.  So, in BIP77, it's the
directory URL.  And then, it also encodes some additional parameters like the
public key, the receiver public key, and yeah, all the parameters necessary to
do that communication via the directory.

**Mark Erhardt**: Right.  So, when you read the QR code or copy the URI that
the exchange or whoever is providing you, your wallet would parse and see,
"Okay, here's the bog-standard payment that I could make.  And if I want to do
something more complicated, like join into a payjoin, here is the web
directory that I should be contacting through a mailroom, and I should encrypt
my messages to that recipient public key", and then I could start negotiating
a payjoin?

**Spacebear**: Yeah.  And ideally, most of that complexity is abstracted away
with good UI.  So, already, if your wallet doesn't support payjoin, it will
just ignore that parameter.  If your wallet does support payjoin, it should
autodetect it, and then maybe there's some user configuration where you have a
preference for privacy or a preference for consolidating UTXOs.  And there's
all these cool preferences that could be built in as well.

**Mark Erhardt**: I do see a future in which a user looks at, "Hey, I tried to
pay my exchange and what the heck is this transaction?"  But I mean, that's
maybe a good problem to have.

**Spacebear**: Yeah, a big part of it is definitely getting good UX in it, and
that's also where having this persistent state machine helps, because you can
easily replay a session and even go back to a checkpoint.  And so, it's very
easy to get back to previous states and be like, "Okay is actually the amount
that was getting transacted.  These inputs are mine, these outputs are mine".
But at the end of the day, it's a lot of UX and UI work that needs to be
clarified, and we need to have best practices, and all those things.  So,
there's still a lot of work to be done.

**Mike Schmidt**: Spacebear, I'm curious, and you've sort of gone through some
of this with Murch in terms of the value, especially since this is an
interactive protocol, you sort of have this network effect that you're trying
to build up, right?  So, you need more software and service adoption of
payjoin, and then it becomes exponentially more useful.  And for all the good
benefits that people would get out of it, I think that would be a good thing.
You mentioned the bindings, you mentioned maybe doing some case studies to get
more information out there to other potential providers and wallet software to
integrate this.

So, it sounds like you guys are doing a lot of the evangelism that would need
to be done.  I'm curious, to the degree that you've been involved with
outreach to wallets and providers, what's the feedback been on, "Oh, yeah, we
definitely got to get this on the roadmap", or are there specific objections,
or how has that been, or have you been waiting for the stable release to do
that?

**Spacebear**: Yeah, in the last couple of years, were a lot more actively
involved with integration, so going into existing wallets, pulling the code,
forking it, and then writing the payjoin implementation as kind of up for
review.  Now, with AI, it's a little bit easier to not have to introduce
ourselves into the development process, and we can just open an issue like,
"Hey, you guys should try implementing payjoin", and it's a lot easier to just
have those proof of concepts up and running quickly.  So, yeah, like you said,
our role has shifted more into evangelism and more just getting the library
and the documentation and all development resources in a place where it's as
easy as possible for an interested developer to actually go ahead and
implement this.  But until then, yeah, I think the issue we were struggling
with was there was too much demand that we couldn't match.  And now, we're
trying to kind of change the approach a little bit so we actually can have all
the language bindings that would be required.  We have still a few mobile
wallets that are interested that we don't have language bindings for, so we
need to get React Native out, we need to get C#, which are kind of still in a
beta state, Kotlin also, there's a bunch of stuff to do with hardware wallets.
So, there's some work in flight to get no_std for the payjoin library to be
actually runnable on embedded hardware.  So, there's still a lot of work to do
basically to remove these barriers to implementation so that when the demand
is there, it can be met.

**Mike Schmidt**: Great.  Thanks for your work on this, spacebear, and it
sounds like this is a great milestone, and you guys are in the process of now
getting it more out there.  Look forward to more wallets and services
supporting this, and it sounds like you guys are doing good work there as
well.  Anything else for our listeners as we wrap up this item?

**Spacebear**: Yeah, thank you guys for having me on.  I would say just if
you're an implementer out there, just check it out.  Try implementing payjoin
and if for any reason you can't, then open an issue.

**Mike Schmidt**: Great.  Thanks again for your time, spacebear, we appreciate
it.

**Spacebear**: Thank you, guys.

_Draft BIP for `rawtr()` output script descriptor_

**Mike Schmidt**: Cheers.  We're going to jump back up to the news.  We have a
second item that we want to wrap up, which is, "Draft BIP for rawtr() output
script descriptor".  We weren't able to get the author, Jean, on the show
today.  So, Murch, Gustavo, and I will go through this one.  But he posted to
the Bitcoin-Dev mailing list a draft BIP for a potential rawtr() output script
descriptor.  And maybe as a quick primer, the descriptor is essentially this
standard language that a wallet uses to record how an address was built so
that it knows which outputs it owns and then how to spend them.  Don't worry,
Murch, I have a note in here, "I'll pause for Murch"!

**Mark Erhardt**: Okay!  Well, I would say a descriptor is a way of defining
the pattern of a wallet.  So, while you can have descriptors that only express
a single output script, generally they describe a whole set of output scripts,
a range.  So, a very simple descriptor would define, for example, P2WPKH
outputs, output scripts that follow a sequence of derived keys.  And you would
sort of define where the sequence of keys start and then how they plug into
the output script; so, which part of the output script is the variable part
that the key sequence plugs into.  And the really nice thing about descriptors
is, where xpubs only describe the sequence of keys, the descriptor describes
the entire script.  So, if you use a custom script or you want to do
miniscript or you want to do a multisig or you do anything else that isn't
exactly this key derived at that path, where you sort of have the meta
information be not explicitly defined, the descriptor allows you to explicitly
define all that meta information.  So, it is a whole backup of the wallet,
rather than just a backup of a key sequence.

**Mike Schmidt**: So, maybe, Murch, before we talk about rawtr(), we can talk
about tr() descriptor, or taproot descriptor.  So, the proposal here, or the
draft BIP, is for rawtr().  So, for the taproot descriptor currently, I
believe it takes a few different things: an internal key; mix in the script
tree according to, I think, BIP341 tweaking; and then out comes this final
output key, right?  And so, that's existed, that's documented, I believe, has
a BIP and everything.  But rawtr() or raw taproot was shipped in Bitcoin Core
quite a many versions ago.  I think we had 24.0 in the newsletter, so for four
years, but it never had a BIP.  So, other people trying to do that were sort
of maybe guessing or poking around at different other BIPs to say what it
should do.  And then, you had this wallet backup containing the rawtr()
descriptor, which maybe wasn't portable to other software, etc.  And so
that's, I guess, the motivation for rawtr().  I guess maybe we'll pause there.
Does that make sense so far?

**Mark Erhardt**: Right, so as we hopefully have established on this show and
elsewhere, taproot outputs can be spent in two different manners per the
keypath, where you just use the key that is already onchain by the output
script being paid in the output, and then providing a signature.  That's the
keypath spend.  And for the scriptpath spend, you have to reveal, "Oh, wait,
this was a tweaked key.  Here is a branch to a script in the script tree.
This is the script and the leaf script", and satisfy the conditions of the
leaf script.  So, with the scriptpath, you have one or multiple different
leafs in a tree that you can satisfy.  So, to document a wallet pattern that
uses a complex taproot construction, you need all this information.  You need
the script tree description, you need the internal key that was used to create
the tweaked key, the external key.  And so, for anyone that wants full
knowledge of the wallet pattern, they would need a public version, or even the
private key descriptor for the complex version.

But sometimes you might want to share only a description of the keys that go
onchain with someone.  So if, for example, someone were to pay you to a
sequence of keys, you were sharing what would have been an xpub with them so
they can pay you multiple times, you might only want to reveal to them the
external keys, the sequence of external keys, without showing them what's
going on under the hood, without revealing that there is a script tree or what
the spending conditions are, or anything like that.  So, rawtr() allows you to
export a more complex script tree to the boiled-down public version of it and
just reveal the sequence of the external keys.  I think it had been referenced
in a couple of other BIPs before, and Bitcoin Core had implemented it in v24,
as we said, but it hadn't been formally described.  So, what this BIP does is
it sort of fills in a documentation need for a feature that already exists and
formally specifies how rawtr() works.

**Mike Schmidt**: And that is in BIPs #2251, I believe.  And so, that's this
draft BIP that closes that gap with a formal spec.  I think there's also some
test vectors as well.  So, if this is on anyone's radar in terms of wanting to
implement it or having tried to implement it in the past and not figuring out
what spec to reference, listeners should check out that discussion and
participate.  Anything else, Murch?

**Mark Erhardt**: That's all I had.

_Silent payments sender plugin for Electrum_

**Mike Schmidt**: Okay, we're going to continue back to the Changes to service
and client software monthly segment with, "Silent payments sender plugin for
Electrum".  This is a post from Ali Sherief about a plugin released for silent
payments sending, but not receiving, for the Electrum desktop wallet.  This is
for single-signature software wallets specifically.  We've covered a slew of
these earlier in the year of folks integrating different components of silent
payments.  This is the send-only, which is obviously the easier one, because
the receive, as we've talked about with Craig Raw and others, is very
intensive with the scanning.  And so, this is just an easy way to look up that
silent payments identifier and then create a transaction from that wallet to
the recipient's silent payments receive wallet.

_Superscalar implementation announced_

"Superscalar implementation announced".  This was an interesting one.  It was
actually on Delving, I think, and user 8144 with some numbers, but identified
as Cubist_Roy, announced an implementation of Superscalar.  So, we spoke with
ZmnSCPxj’ and we had a Superscalar deep dive, I think that was in 2024, for
this design of a sort of channel factory that he had, which is the idea of
sharing many self-custodial Lightning clients using a single onchain UTXO
without having to do a soft fork.  And so, he came out with that design, and
it's sort of been a little bit quiet on a Superscalar front until this
announcement of an implementation, or the documentation of announcement of an
implementation, by Cubist_Roy here.  Murch, have you had a chance to look at
that one?

**Mark Erhardt**: I have not.

**Mike Schmidt**: Superscalar and ZmnSCPxj ideas are cool, yet sometimes hard
to grok.

**Mark Erhardt**: Yeah, so basically, I think it's sort of trying to do a
channel factory without any consensus changes at the base layer.  That was my
takeaway, I think.  And because it doesn't get new covenants or LN-Symmetry or
APO, or whatever, a lot of it is based on presigned transactions and pretty
complicated scripts, and it was a very long Delving post or so from a few
years ago.  So, interesting that someone went and implemented it.  But I think
I would put it at maybe beyond Lightning complexity to get running.  Although
if there were some coordinator, it might get a little easier.  I haven't
looked too much into it, just purely gut feelings.

**Mike Schmidt**: So, check out the Delving post, it's actually quite a
comprehensive Delving post.  It's not necessarily an announcement of a product
or anything like that, it's just some code.  So, there is a GitHub, there's
explainer docs, there's different plugins, and yeah, there's a few pages of
this person's implementation summary.

_Cofund multisig wallet announced_

Next piece of software, "Cofund multisig wallet announced".  I was referencing
this earlier.  This is a self-custody multisig wallet based on P2TR.  It's got
this idea of multi-vendor key registration, hierarchical multisig.  And I
mentioned earlier policy.  It sounds like this is the policy language, Murch,
to be paired with miniscript.  Do I have that right?

**Mark Erhardt**: Presumably, yes.

**Mike Schmidt**: Cool.  So, we linked to their Twitter announcement thread,
but they also have a website that I don't know if I was aware of at the time
or didn't link to.  So, look, I think it's like, getcofund where they have a
website.  And obviously, listeners of the show will also be curious of their
GitHub repository.  So, jump in there and see what they're up to.

_Lexe adds human-readable addresses and LNURL-withdraw_

I actually don't know how to pronounce this, I've read this several times.
Lexe, do you know, Murch?  "Lexe adds human-readable addresses and LNURL".  We
haven't covered Lexe before, I don't think, so this was a good excuse to.  Oh,
Murch is saying that we did.  Maybe we did.

**Mark Erhardt**: I'm pretty sure we must have covered them.  So, Lexe has
been around for a couple, maybe three years now, I'm not entirely sure.
They're running a self-custodial Lightning wallet, I think based on LND, but
you get a light client because the always-on server part runs into a trusted
execution environment (TEE).  And thereby, well, you trust the TEE and the
software obviously, but you don't trust the third party that runs the
Lightning server for you.  So, it's pretty interesting.  They're based here on
the West Coast.

**Mike Schmidt**: Yeah, that's what I have in my notes as well.  They run each
user's node.  So, if you're using, let's say you have this backend that's in
this TEE, it stays online.  You don't have to worry about running an
always-online node yourself.  And then, I wasn't sure we covered it before,
but the reason I sort of shimmed it in, and I thought we hadn't covered it
before, was this BIP353 human-readable Bitcoin addresses, which also double as
Lightning addresses, and also this LNURL-withdraw feature, which I thought was
pretty cool.  Check out Lexe.

_Bark 0.5.0 released_

"Bark 0.5.0 is released".  We've talked with Steven Roose a few times, from
Second, about Bark and their Ark implementation.  This particular release adds
a couple of capabilities that are notable: being able to restore a wallet's
full offchain balance, including UTXOs, from its mnemonic; Lightning receives
to an external Ark address, which enables non-custodial Lightning-address
servers.  If you're curious about our discussion with Steven, we had him on, I
believe it was in Podcast and referencing Newsletter #410.

_Bitcoin-PIR for private UTXO queries_

Next piece of software, "Bitcoin-PIR for private UTXO queries".  Weikeng Chen
announced Bitcoin-PIR, and PIR stands for Private Information Retrieval.  It's
a PIR system that actually has a choice of four different backends for the
implementation of PIR.  So, I won't go through those because I don't
understand what they are.  But the idea here is that a light client can check
for private information from a server; in this example, for example, the UTXO
set for looking for your own addresses, without revealing to the server which
address you're actually interested in.  So, it's pretty cool.  There's some
wild different types of moon-math techniques to let you essentially query a
database in a way where the database operator cannot tell what you've asked
for, which is pretty cool.  I think I remember BlueMatt talking about these
sorts of systems five or six years ago, about how something like this could be
done.  So, it's cool that we have this implementation, and you can see there's
like a web-based version that you can click around on and query, using each of
these different PIR, I guess, algorithms or backends to query addresses and
pull back coins that are yours without the operator knowing.

_OP_TEMPLATEHASH Ark demonstration_

Next piece of software, "OP_TEMPLATEHASH Ark demonstration".  This again was
Steven Roose.  He's launched a signet demo of Ark, and I believe it's using
that 0.5.0, running against OP_TEMPLATEHASH, which is the taproot-native
CTV-style covenant opcode, and we've been talking about this for a while.  I
think we had instagibbs on discussing the BIP with us in #397.  I think
Bitcoin Inquisition activated OP_TEMPLATEHASH, and I think we covered that in
Newsletter #415.  And now, this is like a real second-layer Ark protocol
demonstrating the prototype of running it, which is good to see.  I think
there's probably feedback on the proposal coming from the proof of concept.
The proof of concept can maybe drum up some interest in this sort of opcode,
and build some sort of interest in actually using the end products that would
be available from these covenants, which I think is important, as some people
push for this sort of activation.  Yeah, Murch?

**Mark Erhardt**: Sorry, I was a little distracted because I was
double-checking myself.  You are correct, we had never mentioned Lexe before.
So, it's time we gave them a shout out!

**Mike Schmidt**: There we go.  Did you get a chance to look at this proof of
concept, the OP_TEMPLATEHASH Ark demo on signet?

**Mark Erhardt**: Very briefly.  I was looking at why it was called
templatehash, and that is the website.  I feel like that is a bit of a name
collision with the opcode, but oh well.  I think it's pretty cool that there
are a bunch of people working on different proofs of concept to make use of
templatehash.  So, I've seen recently a statechain proof of concept that is
based on templatehash, which then makes the statechain be possible to have
infinite replacements without the locktimes counting down.  And there's this
Ark here.  There is, of course, a description of how to do LN-Symmetry with
the re-bindable signatures package, and so on.  So, I think it's cool that
there are some prototypes being developed from different directions here.

**Mike Schmidt**: Well, I think the idea, at least from Antoine and Greg, who
I know are working on the proposal, is that this would sort of be, I don't
want to say strictly, but somewhat scoped towards improving these L2s.  And
so, these layer 2s actually implementing these as proof of concepts, working
out the kinks, maybe proving out some usability challenges, or whatever is
going to come from actually building the thing that people are going to use,
seems like a good idea if that's the scope of a potential soft fork proposal.

**Mark Erhardt**: Yeah, I mean that's exactly what should be happening if
there is interest for a covenant proposal, that people demonstrate that there
is enough interest that they work on prototypes.  Just to be clear, Steven
Roose is the third author on that package of BIPs.  So, yeah, stuff coming
from Greg, from Antoine, and Steven is also probably motivated because they
wrote the BIP.

**Mike Schmidt**: Yeah, that's fair.  Well, hopefully other people can listen
to this, check out the templatehash.com website, check out what the proposed
opcode and bundle of opcodes do, and maybe someone from outside of the author
of the BIP can also do some prototyping.

**Mark Erhardt**: I mean, for example, the statechain proof of concept is not
from one of those three.

**Mike Schmidt**: Good.

**Mark Erhardt**: That's from w0xlt.  But yeah, I think there's also interest
from other people.  I hope there's going to be more interest, but tentatively
there seems to be a little momentum here.

_libshrincs formally verified hash-based signatures_

**Mike Schmidt**: Yeah, excellent.  Last piece of software that we highlighted
in this monthly segment, libshrincs, which is formally verified hash-based
signatures.  I did not ask Jonas Nick or remix7531 to come on, because while
this segment came up and it was convenient to cover it for this because it is
a library, so it fits in this segment, I think it probably also warrants maybe
a coverage in the Changing consensus next month.  And so, maybe we can get
those guys on and talk about that more in depth.  But libshrincs is a C
implementation, it's a post-quantum hash-based signature, machine-checked
security proof written by remix7531.  So, very cool.  We obviously had Jonas
on a few times, but in, I think it was Newsletter #399, talking about SHRIMPS.
I think we've had him on other times talking about SHRINCS.  We had remix7531
on talking about his formal verification work.  And so, this is sort of like a
combination of the two.  You have the actual C implementation, you have some
formal verification in there as well, which is, I think, pretty cool to see
that we've gotten there already with these proposals.

**Mark Erhardt**: Yeah, it sounds like if you know what libsecp is, this is
sort of the post-quantum library that would take the place of libsecp
implementing these post-quantum hash-based signature schemes.  This, of
course, ties into the debate about being worried about quantum computers.
SHRINCS was the first proposal from Jonas Nick and Mikhail Kudinov, I think,
right?  This would be sort of the single-sig variant that is fairly
blockspace-efficient, but wait, no, it doesn't need state and is not that
efficient.  It's pretty big, 3,000 bytes for public keys and 2,000 bytes for
signatures or so, if I remember right.  SHRIMPS was the combination of that
with an expectation that the signer keeps track of state and then can make
smaller signatures, but has to remember that they signed before, or it could
become unsafe, if I recall that correctly.  To toot our own horn a little bit,
members of the Localhost Research team have been working with researchers to
propose PRAWNS, which is a multisig scheme, a threshold signature scheme that
is based on -- we're sticking with the shellfish analogies here.  This is a
paper coming out that we recently announced on our blog.

**Mike Schmidt**: Very cool.  I want to quote from the Delving Post here, "The
main goal of libshrincs was to determine whether machine-checked proofs of
functional correctness and security could be practical for a cryptographic
library of this kind.  Until recently, producing both proofs would have been
prohibitively difficult because of the specialized expertise and engineering
effort required.  The large language models available in 2026 changed that".
So, somewhat echoing what we heard from Keags a few weeks ago, in that the LLM
is actually quite good at this sort of work and some of this checking work.
So, it's interesting that they put this out.  I suspect we'll talk more about
it in the coming weeks.  So, I think it's a bigger topic than just the one
shimmed in here in this monthly segment.

All right, we can move to not Releases, because there are none this week, but
Notable code and documentation changes, authored and summarized here by
Gustavo.  Hi, Gustavo.

_Bitcoin Core #32784_

**Gustavo Flores Echaiz**: Thank you for the intro.  So, this week, we have
five different items from the Bitcoin Core repo.  The first one, #32784, is a
new RPC command called derivehdkey, which allows you to derive an xpub at a
specified derivation path.  You can also optionally derive an xpriv from the
wallet if you specify that option, but the main goal here is to derive an xpub
at a specified derivation path to be used for a multisig wallet, where each
participant provides an xpub.  Yes, Murch?

**Mark Erhardt**: Yeah, so if you have hardened derivation steps in your
derivation, you cannot do these without having the underlying private key,
right?  So, the idea here is if your path that you want to use in a multisig
descriptor has any hardened derivation steps, in order to for you to for you
to participate and have a sequence of keys that tie into the descriptor, you
would need to derive the public key below the hardened derivation step first,
from which the key sequence derives.  And this was possible before by, well,
really understanding the command line very well and how Bitcoin Core worked.
And with this RPC command, you can basically point out which derivation path
you want to use and then derive that public key at the right spot, even if
there are hardened derivation steps along the way.  And as you said, you can
either produce the corresponding xpub or xpriv at that point.  And that
enables you especially to do more complicated miniscripts or multisigs more
easily.

**Gustavo Flores Echaiz**: Exactly.  So, the multisig tutorial in the Bitcoin
Core repo was also updated, part of this PR.  And also, if your wallet has
multiple HD keys, you can also specify which one you want to use by providing,
like, the head xpub that the descriptor uses to identify that wallet.  And the
goal there is simply for Bitcoin Core to know which HD key you want to derive
from.

_Bitcoin Core #35797_

So, the next item, Bitcoin Core #35797.  Here, basically the issue that was
going on is that when processing PSBTv2 with the descriptorprocesspsbt RPC
command, if it didn't have any inputs as it's allowed in PSBTv2, it would
basically run into a bug.  The Bitcoin Core implementation was expecting
PSBTv2 to function as PSBTv0, where PSBTv0 is an unsigned transaction with the
inputs and the outputs.  However, PSBTv2 can optionally have no inputs.  So
now, the code behind that RPC command, specifically the method
UpdatePSBTOutput, it was trying to use the first input, but it would fail
because it had no inputs.  So now, it will build a temporary transaction
containing a dummy input when populating the output metadata of PSBTv2.  So,
instead of changing the code to not force the existence of an input, Bitcoin
Core will simply create a temporary transaction with a dummy input to populate
the PSBTv2 output metadata.  Yes, Murch?

**Mark Erhardt**: Did Gustavo just freeze or is that just on my end?

**Mike Schmidt**: I think he froze.

**Mark Erhardt**: Okay.  So, PSBTv0, if I remember correctly, was basically
based on the assumption that the entire transaction was already put together.
The inputs were just missing the signatures and you were going to parse around
the PSBT to collect those signatures.  However, PSBTv2 was created in order to
make that more flexible, so that updaters to the PSBTv2 would also be able to
provide inputs or change outputs, and so forth, so that the transaction
creation itself would be distributed, not just the signatures.  So, PSBTv2,
which, for example, is used by payjoin that we talked about earlier, and I
think also is used by many multisig setups these days, where previously
different wallets and services had their own formats, it is now getting
adopted as sort of an exchange format for people to collaborate on transaction
creation, PSBTv2 allows you now to have outputs before any inputs exist.  And
there was a bug that caused the software to crash if you were trying to update
the outputs without any inputs on the transaction, which is fixed here now.

_Bitcoin Core #35531_

**Gustavo Flores Echaiz**: Thank you, Murch.  I fixed my connection, so I
shouldn't have a problem with this connection anymore.  So, the next two items
are about performance optimizations inside Bitcoin Core, so quite interesting
changes.  The next one is #35531.  Here, the disk space used by the -txindex
option is considerably reduced. The author's test saw the index shrink from 66
GB to 26, and indexing time fall from 1 hour 50 minutes to 1 hour 19 minutes
in his machine.  And basically, the structure of the data is changed.  Instead
of storing the whole txid and the disk position of the transaction, the txid
as the key and the transaction disposition as the value, the new format
instead uses a five-byte prefix of a salted SipHash of the txid, so the txid
is hashed and some SipHash is also added onto it to basically make it so that
the result cannot be predicted.  And in the key space, it also includes the
block sequence number and the transaction offset, both in a compact six byte
suffix.  So now, the value is empty and basically now Bitcoin Core will start
by finding the block location using the block index, so it doesn't need to
point to the transaction disposition, it can only reference to the block index
and that's how it can find the transaction specifically where in the disk.

**Mark Erhardt**: Right, so Bitcoin Core stores the blockchain in blocks of, I
think, 100 MB.  And whenever you receive block data, it is just shoved into
these block files.  But it remembers where each block starts in these 100-MB
blobs of data.  So, it sounds to me that the -txindex is not storing less
information now, it is just smarter about how to reference where that
information appears and then reading it from the disk directly from the
blockchain data.  And so, the prefix is just an identifier, and the suffix is
where to look for it.  And with the prefix, you have enough information that
there will not be collisions, is my understanding.  So, it gets significantly
smaller, more than half the size less, and faster to index, and I think also
faster to look up things, which is really nice.

**Gustavo Flores Echaiz**: Yes.  So, technically there are collisions.  So, he
tested, he did find like 894,000 two-way collisions, 395 three-way collisions
and one four-way collision, in the sense that there were four transactions
that had a collision.  But however, after scanning the entries, the shared
prefix and finding the block location, it will then verify the full txid to
safely handle the collisions.  And even if this format has more collisions
than the previous one, it's still way more performant.  So, that was a
limitation that was found, but it was accepted as a fair trade-off because of
how it was still way more performant.  If someone updates, like, it's not
forced to update to the new format, you don't have to re-index, but you do
have to if you want to reclaim your space.  However, with the new version, the
new entries will get written in the new format.  However, if you rebuild the
txindex and you downgrade your Bitcoin Core version, you will also need to
rebuild the index when downgrading, because previous Bitcoin Core versions
simply don't understand this format.

**Mark Erhardt**: However, if you have a txindex, you are required to have
default blockchain.  So, this is no downloading, it's just recalculating from
data you have already.

_Bitcoin Core #35889_

**Gustavo Flores Echaiz**: Totally.  Next item, also performance-related,
#35889.  So here, the gettxspendingprevout RPC command, which allows you to
check whether an outpoint was spent, either in a mempool or through a
confirmed transaction, the performance of this RPC is considerably improved so
that the author's benchmarks, for example, in a system with a Ryzen 7 3700X,
this large mempool-only request batches completed 9 times faster and 31 times
faster on a Raspberry Pi 5.  So basically, what is happening here is that
previously, Bitcoin Core, let's say it has a list of outpoints that it wants
to verify whether they were spent first in the mempool and then in confirmed
transactions, it will go through that list and as soon as it finds one that
was spent in a mempool transaction, it will erase it from the middle of the
vector from that list, and all the remaining entries will have to shift
positions.  So, it was just a very costly operation, because every time you
found a match of an outpoint that was spent by a transaction found in the
mempool, you would have to shift all entries.  Basically, the erasement of
that value would just be a very expensive operation.

So now, instead, what it does, once it scans the list and it finds that one
was spent via a transaction in the mempool, it will simply create a new list,
called results, and it will reference the position of that outpoint instead of
removing it from the initial list.  Later on, it will rerun a second scan for
transactions to see if those transactions were spent in confirmed transactions
to the optional txospenderindex, so it can also build a separate worklist for
that lookup, instead of having to shift the entries in the initial list.

_Bitcoin Core #35605_

Next item, Bitcoin Core #35605.  So here, we deprecate a wallet RPC called
removeprunedfunds, which was added alongside importprunedfunds.  So,
importprunedfunds is an RPC command that allows you to add a transaction that
your wallet should know about, but it doesn't know about either because your
node was pruned and it doesn't have that block data.  So, you could manually
add a transaction that your wallet should know about.  And the logic around
adding removeprunedfunds next to it was that I could add that transaction to
my wallet, and then I could also delete that transaction back.  However, the
problem with removeprunedfunds is that it wasn't limited to the transaction
were added via importprunedfunds, it could simply delete any transaction
belonging to my wallet.  And that would just simply fall outside of the wanted
scope of the RPC command and it could also lead to just dangerous behavior.

Also, this command seems to be a maintenance burden, since in Newsletter #391,
we covered a bug when removing transactions via this RPC command, where
removing a transaction marked all of its inputs as spendable again, even if a
wallet contained a conflicting transaction that also spent the same UTXOs.
So, the decision was simply to deprecate the RPC command and to schedule it
for removal in the next release; one, for the dangerous behavior, but also the
second one, because there was simply no known useful purpose for this command,
and then because it was also a maintenance burden.  Yes, Murch?

**Mark Erhardt**: So, this follows the removal of the legacy wallet, because
for the legacy wallet, there were situations where that was a handy way of
fixing a wallet issue.  But now that we don't have the legacy wallet anymore,
there are no known uses for it anymore.  And yeah, enabling your users to
fudge with what transactions our wallet knows about just introduces a big set
of footguns.  So, now that we don't need to have this manual fix anymore, it
is being deprecated.

**Gustavo Flores Echaiz**: Exactly.  So, the next three items, we're going to
skip them because they were all from the Eclair repo and they were discussed
at the beginning of the episode.  Also, I want to say that t-bast mentioned an
interesting feature at the very end of when he was covering these PRs.  I
believe it was about a new feature that was developed in Eclair that is going
to get covered in the next newsletter.  So, it was added to Eclair after the
deployment of this newsletter, which means that it will be in the next one.
So, the next two items after the Eclair ones are from the LND repo.

_LND #8754_

So, the first one, #8754.  Here, an experimental outbound connection mode is
added for the remote signer.  So, the remote signer is a setup where the
private key operations are delegated to a separate signer server.  And in
Newsletter #172, which means about five years ago, we covered that LND had
added the ability for an LND node to delegate private-key operations to a
remote server.  However, that required the remote server to have inbound
connections to accept requests from external servers.  And that created a sort
of security risk, which this item basically addresses by creating an outbound
connection mode, where the new mode changes only how the two connect; and
instead of the signer listening for an inbound connection, it initiates the
connection to the LND node.  So, in Newsletter #326 we covered work that was
required for this to happen, which was about deterministic macaroon
generation, which enabled this new experimental mode.

_LND #11065_

The next item, also from the LND repo, item #11065.  Here, a new experimental
RPC, called XCreateAccount, which when building LND requires a user to enable
this feature, so it's experimental, it's not enabled by default, this allows a
user to create separate accounts from keys that are derived from their LND's
wallet master key.  So now, onchain funds can be segregated in different
accounts.  This doesn't apply for funds in LN channels, but only applies for
onchain funds of this Lightning node.  So, this allows for easier coin
selection, address derivation, and simply scoping funds to specific accounts
and isolating pockets of funds.  I also want to add that if you choose a
selected address type for the account, that is going to be permanent, you
cannot change that after the fact, and it will always default to taproot.

_HWI #842_

The next item and the final one, from the HWI, Hard Wallet Interface, repo
item #842, which curiously is sort of related to what we discussed about the
Ledger update earlier in the episode.  So here, what happens is that a new
command called registerdescriptor is added, which allows HWI to register an
output script descriptor with a hardware signing device before signing
transactions from that wallet.  So, similarly to what we discussed at the
beginning about the Ledger app change, here this command allows a wallet using
HWI to basically register a descriptor with a hardware signing device before
signing the transaction, simply for the user to have visibility via his
hardware wallet device of the descriptors he's going to later be signing on.
Also, BIP388-compatibility is also added, where the descriptor is sort of
converted into something that is more user-friendly to view, by separating the
wallet descriptor template with the key information vector.

So, this also works, from what I saw, with stateful and stateless devices.
So, you could also use it with a stateless device, which doesn't necessarily
keep the descriptor registration, but HWI can basically have that state to
later be recovered by the signing device.  Yes, Murch?

**Mark Erhardt**: Right, so BIP388 is the wallet policies BIP by Salvatore,
who we had on the show earlier.  This is basically a subset of descriptors
that have wallet patterns that can be boiled down to easier descriptions.  It
limits miniscript to a smaller subset that Ledger directly supports, and
others can implement support for too.  So, for wallets that don't have a
registration on the hardware device, so they cannot remember whether they have
committed to an output script descriptor, they provide an attestation.  So,
when you register, they return basically a signature that says, "I have seen
this descriptor before and this was signed off by my user".  And then, when
the companion software communicates with the hardware signer, they will
provide back this attestation, and thereby the device knows that this is
registered by getting the output script descriptor again and the signature by
itself, showing that it had seen it previously.  That way, even a stateless
device can register wallet policies.

**Gustavo Flores Echaiz**: Right.  That makes sense.  Thank you, Murch.  So,
that's the final item, and that completes the newsletter and the episode.
Thank you.

**Mike Schmidt**: Thanks, Gustavo.  Thanks, Murch.  And we also want to thank
our guests this week, Salvatore, t-bast, and spacebear for joining us, and for
you all for listening.  We'll hear you next week.  Cheers.

{% include references.md %}
