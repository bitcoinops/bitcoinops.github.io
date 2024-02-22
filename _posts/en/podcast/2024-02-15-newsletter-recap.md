---
title: 'Bitcoin Optech Newsletter #289 Recap Podcast'
permalink: /en/podcast/2024/02/15/
reference: /en/newsletters/2024/02/14/
name: 2024-02-15-recap
slug: 2024-02-15-recap
type: podcast
layout: podcast-episode
lang: en
---
Dave Harding and Mike Schmidt are joined by Gregory Sanders and Gloria Zhao to
discuss [Newsletter #289]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-1-15/b8a4bcc1-9a47-9d15-8f25-4353a8b9c3b6.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #289 Recap on
Twitter spaces.  Today, we're going to be talking about ideas for relay
enhancements after cluster mempool, historical analysis of LN commitment
transactions in the context of v3 policy, Bitcoin-Dev mailing list migration, a
yearly celebration of open-source software and contributors, a PR Review Club
around transaction packages, and some notable changes to code from the last
week, including v3 transaction relay support being merged into Bitcoin Core.
I'm Mike Schmidt, I'm a contributor at Optech and also Executive Director at
Brink.  Dave?

**Dave Harding**: I'm Dave Harding, I'm co-author of the Optech Newsletter and
co-author of Mastering Bitcoin 3rd Edition.

**Mike Schmidt**: Greg?

**Greg Sanders**: I'm Greg, or instagibbs, I work at Spiral on Bitcoin stuff.

**Mike Schmidt**: Gloria may be joining us at some point during our discussion.
If so, she can introduce herself when she arrives.  For folks following along,
this is Newsletter #289.  We're going to go through sequentially, starting with
the News section.  We have a few news items this week.

_Ideas for relay enhancements after cluster mempool is deployed_

The first one, titled Ideas for relay enhancements after cluster mempool is
deployed.  Greg, you posted to the Delving Bitcoin Forum, titled V3 and some
possible futures.  You noted in your post a bunch of different things, but we
can start with the tl;dr, " V3 is useful and likely upgradeable to something
more post-cluster mempool world in a backwards compatible way".  You noted a few
things that you wanted to answer in your post, including what policy relaxations
or restrictions we can enact in the future, what other rules can we add to
express the intention of v3, and after cluster mempool, how useful is v3?  I've
sort of teed it up to you, where would you want to take it from here?  Maybe
outline the post and what you're thinking with it.

**Greg Sanders**: Yeah, so I think I'll start with the beginning, my thoughts on
what we learned, the lessons learned during v2 development.  So basically, one
of the big ones is we don't want to offer policies that can't be supported
moving forward.  So, if you're familiar with the CPFP carve out, this is a
policy that was set specifically for LN specification reasons, and it ended up
not being that useful as intended and then also conflicts with future
developments in the mempool.  So, one of these kind of things in my head is,
let's not support something we can't support in the future for whatever reason,
right?  So, let's say in the future, v3 just ended up being completely
incentive-incompatible.  Does this mean we have to remove it in the future?  So,
you have to think about these kinds of things, because if it's not
incentive-compatible in a fundamental way, then people are just going to route
around it and that's not good for the network, for the centralization aspect,
right?

We also kind of saw that during v3 development, we maybe focused a little too
much on one use case, primarily for this or that reasons.  But when we
rhetorically focus too much on one protocol, I think that ends up focusing the
discussion too much on that protocol.  So, specifically for LN development, a
lot of the discussion became about, which is still useful, but most of the
discussion, 90% or something of it became, how would LN use it?  And it's
actually kind of not a -- there's no closed answer to this, right?  We don't
know exactly how they would use it, or what exactly the specification would look
like that would use it.  And maybe that's just too hard to answer now, but we
can answer it in the future with more development.

Also, I already mentioned this before, but longer term, we want these policies
to be more incentive-compatible in an obvious way, right?  So for example, v3,
maybe it turns out the child size is too restrictive or too lax and can we make
updates to this protocol in a backwards-compatible way that's just superior in
general?  Because while pinning is not incentive-compatible, we also can't
overly focus on it as well, because if we're just focusing on pinning, there are
ways of solving that, that don't take into account the mining profitability or
everything else, so this is a balance being made.  Does that make sense?  I can
pause here for a second.

**Mike Schmidt**: Yeah, I think so.  Go ahead.

**Greg Sanders**: Okay.  Yeah, so this post just saying, v3 was actually a
pre-cluster mempool idea.  We didn't have a hope at the time that we'd have a
completely ordered mempool where we can make these kinds of more concrete
judgments on RBF incentive-compatibility.  We couldn't really reason about
topologies in general when it came to incentive-compatibility, and this is one
of the fundamental drivers for cluster mempool.  And so, during kind of this
development of v3, socialization of v3 and all that, cluster mempool came
alongside it and said, "Hey, I think we can do a lot better on more topologies,
at least on the incentive-compatibility part of things".  It wasn't a direct
answer to pinning, but it is to incentive-compatibility.  So, we can make much
better judgments on what transactions should be in the mempool, which ones
should be evicted in RBFs, and so on.

So, looking forward I'd like to say, this v3 policy, can we upgrade in the
future using this cluster mempool, this totally ordered mempool to make better
decisions, perhaps superior decisions to v3 today; and what action would users
have to take to take advantage of this in the future?  So, if someone deployed a
wallet that signals v3 for whatever use case they want, in the future, would
they have to flip bits again; would they have to change or update their
software; or, could we make it in such a way that it just transparently updates
and just becomes better for the ecosystem?  And so, this kind of zooms into the
concrete details here of the post, as concrete as they get, right?  This is all
basically hand-waves at this point.  But with a totally ordered mempool, the one
big concept is we can do a much better evaluation of what's being proposed to
enter the mempool.

So, I introduced this concept that is not new, but it's a concept of top block,
which means, possibly you get a transaction or a set of transactions or a set of
replacements.  You say, do all these v3 transactions, or whatever policy we opt
into, do all these transactions make it into the first one or two blocks, or
something like that, right?  You could say one or two blocks, plus we could
simulate another ten minutes of inflow, something like that.  But essentially
say, would a miner be compelled to enter this into their pool no matter what;
but beyond that, maybe the miners would be okay waiting for someone to make a
higher bid to get into this top block slot.  So basically, instead of focusing
on the kind of child size topology saying, "Oh, this child can only be so big",
instead we say, "This set of transactions or subset of topologies must enter top
block to be entered into the mempool".

It's important that we can't say things like -- I think one caveat here is that
you could say something like, "Oh, maybe to make it really pin resistant, you
want a top block plus 20% or something, right?"  But that's not obviously
incentive-compatible to me.  You're basically saying, "Hey, miner, don't pick up
these extra fees at top block rate, because maybe there'd be an inflow of
transactions that would get re-pinned again, pushed down in the mempool and
re-pinned", say if there's a big BRC-20 issuance right after the transaction is
put in the mempool.  But it's not obviously incentive-compatible to me.  So, I
kind of say it's probably something like, first two blocks or more research
needed for this number, but whatever this policy, I'm going to call that top
block.  Make sense?

**Mike Schmidt**: Yeah.

**Greg Sanders**: Okay.  There's another factor, that it's useful to have
transaction backlog, right?  Maybe miners don't care 100% that your transaction
is not in the top block, but they probably do care that there's a backlog for
miners to pick up fees over time, especially further up the mempool.  Maybe they
don't care so much at the end of the mempool, but there's also just this use
case thing.  So, there's this backlog and this use case of people want to make
transactions, they want to see it in the block explorer, this is what they're
used to.  And also, for the lean times, miners might not want to rely on people
rebroadcasting their transactions that got kicked out, right?  Obviously,
wallets should support this, but maybe they don't, or maybe the wallet's offline
for that period where the mempool clears out, the miners would be incentivized
to keep some around in the backlog.  So, these are competing use cases in some
ways.

So, I give kind of this -- if you scroll down, this is a chartless flowchart.
It kind of gives a high-level view of what kind of relaxations and restrictions
we can do.  So, it's essentially a mixture of, can you add the top block
requirement; and can we also add that in conjunction with something to make it
more useful for these wallet use cases that want to make backlogs, or might not
want to bid for top block all the time?  And so, I'll just zoom in on the one
use configuration I think is pretty interesting.  It's v4(c), which is at the
end, which essentially says, "Let in all topologies, so you no longer have this
child-parent restriction or size restriction, if it's in top block.  But you
also let a small amount into the mempool that's not top block".

So for example, one configuration could be if you're a single transaction in a
cluster and you're under, let's say, 300 virtual bytes (vbytes), you can be let
in at any feerate, or perhaps the sum of the transactions, 300 vbytes, you can
be let into the mempool.  Anything beyond that has to be top-block updates,
essentially, so a CPFP or a replacement that gets the entire cluster into top
block.  So, that's what I think is kind of an interesting point to think about
because it kind of checks a lot of boxes, right?  So, from a use case
perspective, there's the endogenous, exogenous, single transaction RBF case,
like Hash Time Locked Contract (HTLC) pre-signed transactions; these would fit
in here.  They become pin resistant.  Users could make small chains of small
transactions that aren't top block and still get into the mempool, still get
propagated, still make backlogs.  But if you want to make anything large or
complex, then basically it reverts to this requirement to be, aggressive fees to
be broadcasted.

This covers a number of other use cases too, like zero-conf funding transactions
for LN.  If the funding transaction opts into this use case as well as the
commitment transaction, then you could have chains of transactions that are
pin-resistant, which would be nice.  It also allows this kind of backlog concept
to be introduced to it.  I'll pause here.

**Mike Schmidt**: If you don't have the diagram up in front of you, I would
suggest if you're at a computer to pull this up.  It's on the Delving Bitcoin
forum, and it's a visualization of what, I guess, Greg, would you say you threw
this out as an idea of a way to progress along v3?

**Greg Sanders**: Yeah, so these ideas, some were by me, some were more
influenced by other contributors, Suhas, Gloria mostly, talking about kind of
making things …  I mean, the ideal case would be we craft something that's
pin-resistant, incentive-compatible and so useful that everyone updates to it,
right?  And if all users update to it, it's better for the miners if they're
making more money, it's better for privacy if everyone's clustered together, and
also you can start thinking about possible futures of making this not an opt-in
policy.  If somehow we create something that's general enough, then you can
think about switching it to default in the future, right, which is even better
in some ways.  And so, yeah, threading these together and thinking about, in
what order can they be deployed and how iterative can we be versus jumping
around this flowchart?

**Mike Schmidt**: Greg, as a slight tangent, I'd like you to give your take on
what it means to be incentive-compatible.  I've seen some discussion in which
folks seem to think that that is overly catering to miners in a negative way, so
maybe you can help clarify what that means to you and why that maybe isn't just
acquiescing to whatever a miner wants and letting miners have control.

**Greg Sanders**: Well, I think instead of compatibility, at a high level is
saying a relay policy, in the relay policy sense, is that we are matching users'
willingness to pay fees to get those to the miners and get those mined in that
order, if the miners choose to do so, because we believe the miners are greedy,
myopic, they see fees, they'll take it, because if they don't take it, someone
else will.  And mining, especially when the subsidies run out, is driven by
fees, and marginal profits are king.  So, that's a high-level view of it.  So
for example, in my opinion, if people want to make certain types of transactions
and are willing to pay lots of fees for it, we kind of have to think of a way of
supporting it.  So, inscriptions, whatever you think about them, people
obviously are willing to pay for it.  So, simply saying, "Don't do that", isn't
an answer.  But possibly, there's an alternative way we could support similar
functionality that's less harmful, but that's on a case-by-case basis and has to
be debated.

If we do try to obstruct relay of this, then it's incentivized out-of-band
relay, which is obviously worse, because again, then it means people are
essentially calling up miners and handing things to them, and then it makes the
1% miner who would like to compete can't, and that's not good.  We want a lot of
1% miners who are smaller.

**Mike Schmidt**: Dave, we cover later in the newsletter v3 being merged, v3
support anyways, being merged into Bitcoin Core, and Greg sort of taking that
perspective and then looking into the future.  I'm curious what your thoughts
are on his writeup on Delving.

**Dave Harding**: I mean, I really appreciate this outline here.  There's some
stuff in here that I definitely would have guessed at; there's some stuff that I
would not have guessed at.  Just sitting here listening to you and reading the
post, I had a couple questions, Greg.  The first is for what you call v4, are
you thinking this is actually going to set tx version to v4, or is this
something that's just to be applied to any transaction, maybe just v3s, or just
maybe any transaction in the mempool implicitly?  I just wondered if that was an
explicit version number or not.

**Greg Sanders**: Yeah, so no, it's not an explicit version number, it's a
number I made up.  It's more talking about the upgrade path, how you could ...
If we decided, for example, that we wanted to support a transaction that's of
any relayable size and that not to be top block, but anything more expressive to
be top block, you might want to support v3.1.  But that doesn't cover use cases
like today's HTLC pre-signed transactions.  If you can't encumber a single
transaction to be good to mine, then pinning is still pretty trivial with that.
So, you might need something like v4(a), which is what I denote, or v4(b) even.
So, you could theoretically see two deployed version bits, right, v3, v4, and
v4(a) would be v4, I guess.  It would be just another bit in a transaction
somewhere.

I don't personally find it that compelling to shard the policy space so much for
what I consider a little more -- yeah, sharding the policy space makes it harder
to reason about, like, you'd have to think harder about when you're using v3.1
and v4.  So, you're kind of kicking it to the user to decide.  And also going
forward, this is just more leakage, right, different policies running around.  I
don't think they're that different in logic.  So, the good news is, a lot of
logic to be reused, but I think ideally we'd have one really good opt-in policy,
maybe so good it can be default.  And so, I'd rather focus on that as a hope, I
guess, but it's still very early days, of course.  We still have cluster mempool
and more.  Make sense?

**Dave Harding**: That does make sense, it does make sense.  And my other
question here is, does any of this, particularly the v4 ideas, do you see any
impact here on RBF; are we going to continue with the same RBF rules to avoid
pinning; or, just how do you see this influencing and interacting with
post-cluster mempool RBF ideas?

**Greg Sanders**: Yeah, so I would say the remaining pinning for, let's just
start with v4(c) as an example, you'd have, I don't know, up to 189 vbytes of
pinning, basically nothing.  It depends on what number you pick for this
exception rule.  But beyond that, I'd say the more serious pinning would be
like, I call it goldfinger++, which means the adversary or yourself puts that
transaction in the mempool at top block, and then suddenly a bunch of inflow
comes in, and then you're pinned, right?  This can already happen with a
goldfinger attack, which means I don't know how much worse it is in practice.  I
don't know if mempool policy can fix this, but the differential here is that
once the mempool is filled by, let's say the adversary, you're unable to reorder
the transactions in the mempool.  So, let's say everyone has HTLCs timing out 60
blocks.  If there's 120 blocks of transactions in the mempool, it just allows
the adversary to push down, it gets to pick which ones will get mined
essentially; the top 60 blocks' worth, and then pushes down the rest of the 60,
so you can think of it that way.

So, we're not at the point where we can really talk about removing the
incremental relay fee, so BIP125 rule #3.  That's one of the last pinning
vectors and I think it's really early to be talking about replacing that.  I
have spent time, probably too much time, thinking about this and probably need
to spend a lot more time on it.  But maybe with a cluster mempool, we can start
thinking about different policies that may allow some free relay, but bounded.
Maybe if we play games with some numbers, maybe we can get something better, but
I can't say more than that because it's even more hand-wavy.  So basically it's
like, this is the best we're going to do in a DoS-resistant way that gets miners
paid and gets people's transactions mined for now.

**Mike Schmidt**: Greg, right now a lot of this discussion involves yourself,
Gloria, who's just joined us, Suhas, sort of mempool wizards, if you will.  At
what point, putting on our Optech-interfacing-with-users-and-businesses hat,
would it make sense to get any feedback from outside the group and from users,
or layer 2 builders, etc?  Is that just way premature at this point, or are
folks already chiming in, or should they be chiming in; or, what are your
thoughts on that?

**Greg Sanders**: Yeah, I mean people can chime in for sure.  There's people in
the LN-adjacent space who've already given feedback, like this top block idea.
But again, top block is not a new idea.  I was looking at the CPFP carve out
mailing list post that BlueMatt made, and it's literally mentioned in there.  We
didn't have the tools to pursue it as an idea, which is why we didn't see any
further development, but this kind of thing is not exactly new and I think it's
allowing…  One of the biggest drawbacks of v3 is this topology restriction, or
the biggest, right?  It's this topological restriction, which means you can't do
things like, you can't cleanly support zero-conf channel funding, which is like,
"Oh, why do we have to make zero-conf pin-resistant?" but there are reasons for
that.  And if we're thinking really further ahead, do we want to be the police
of your transaction structure; do we want to be policing Ark trees?  If and when
Ark wants to deploy, do we really want to say that you don't get pin-resistance
because you didn't do it in a one-parent, one-child topology?  There are ways of
contorting your topology into the one-parent, one-child kind of easy topology,
but it can often come at a cost of more than 2X in marginal vbytes, and that's
not great.

So, I think getting feedback from people doing, not just LN, but just regular
wallet developers, Ark kind of constructs, Mercury wallet, all those kinds of
constructs would be useful, I think, at a high level, right?  There's no code to
review or anything of this, so this is why it's probably early days of thinking
just about what are people trying to build in general, right, and try to
accommodate that.

**Mike Schmidt**: Gloria's joined us.  Gloria, do you want to say hi, introduce
yourself, and maybe comment on Greg's post about v3 futures?

**Gloria Zhao**: Sure, yeah.  I came up with v3 because essentially we had all
these ideas that we wanted to implement, but it just wasn't possible with
complex topologies and we couldn't even implement the bounds that we needed on
cluster size, for example, because of how mempool is structured today.  So,
yeah, that post is great at exploring, okay, what about after we do implement
those things, then these topology restrictions are not really necessary.  And we
can further adhere to this concept of, we want to give these pre-signed
transactions a way to be in the fast lane.  Any transaction you add to it or
replace it with should remain in the fast lane, and we can expand that to more
types of packages and topologies.  So, yeah, I'm glad we're exploring this and
it's exciting.  It would be good to get some feedback from people who may or may
not be either relying on this or able to build something new because of this.

**Greg Sanders**: Sorry, there's one last challenge here, that in this chart it
says, "No v3 style sibling eviction", where if we expand the topologies to more
general topologies, then we lose the thing called sibling eviction that's more
easier to reason about, and we have to replace it with something.  So, that's
another kind of research project, which I'm not convinced that it's required in
a top-block world, but I can see scenarios where cluster limit pins are
accidentally hit, people are making withdrawals from their Ark tree and then a
bunch of stuff comes in, they don't RBF their own stuff and you want to evict
those for your own.  I could see scenarios where it's useful, so it's just more
of a future research project I'd like to take on in the near future.

_What would have happened if v3 semantics had been applied to anchor outputs a year ago?_

**Mike Schmidt**: The next news item is also related to v3.  It's titled What
would happen if v3 semantics had been applied to anchor outputs a year ago?  So,
in Newsletter #286, we highlighted this idea of imbued v3 logic, which I think
Suhas explains well in the introduction of his post that we covered for this
news item.  He says, "There has been some discussion about taking the v3 policy
proposal, which is an opt-in policy for transaction setting nVersion=3, and
trying to directly apply it to transactions that appear to be LN commitment
transaction spends, based on matching characteristics of such transactions.
This would allow the LN project to adopt v3 without making any explicit changes
to their software.

So as part of that, Suhas looked at all the transactions from 2023 and recorded
which transactions, one, matched the format of an LN commitment transaction and
would have been imbued with this v3 validation rule, and he found 14,124 that
matched that template.  He went on to look then which would have failed to be
accepted into the mempool under these v3 policy rules, and of that 14,000-ish,
856 would have failed, which is about 6%.  He then dug into the failures asking,
"Did the LN commitment transaction template used to match transactions match
more than just LN transaction anchor spends?"  And then, "Why did those
approximately 800 transactions get rejected using the v3 policy rules?"  He
found that 595 failed due to ancestor count limits.  And then finally, he
plotted the child transaction sizes, noting that almost all of the child
transactions were small.

So, that's my summary of his writeup.  He wasn't able to make it today to
explain his findings, but we do have Gloria and instagibbs here, who are fairly
proficient in this topic.  I'll open the floor to either of them to comment on
the findings and potential implications of those findings.

**Greg Sanders**: I'll pass it off to you, Gloria, if you're okay.

**Gloria Zhao**: Yeah, sure.  So, I think it's very promising.  We wanted to try
to get feedback from the LN folks, like would this break your usage, basically?
And there's looking at their code and saying, "Oh, are they doing batching; are
they not doing batching?"  And then there's just running the data and seeing
which transactions would get rejected.  I think it's really good.  Only a very
small percentage would have failed, and it seems quite easy to attribute why
those failures are, like the batched CPFP of multiple commitment transactions
seems to be, like you said, about 500 or something of those transactions.  I
don't know exactly what the kind of threshold is for deciding that this is okay
to deploy.  I think it's very promising though to see this.  So, I don't know,
what do y'all think?

**Greg Sanders**: So, I'll just jump in.  I'm not sure if it was mentioned, but
the motivation of this is that for the cluster mempool project, it can't support
the CPFP carve out.  So basically, the specific template that Suhas is checking
for is for the case where LN would use the CPFP carve out.  So, this is a
commitment transaction that has two anchor outputs specifically, so it's like a
subset of all commitment transactions.  There are a number of cases in which
you'll have only one anchor, or possibly none, depending on the state of the
channel itself.  So basically, this is kind of asking the question, could we get
v3 semantics for LN transactions that use the carve out, such that we at least
don't remove the pin resistance offered by the carve out, while replacing the
carve out itself?

**Mike Schmidt**: Gloria, you mentioned sort of what's the threshold here and it
seems like with 6% failing, 94% would have been successful.  I had the same
question, is that good or not?  Dave, in the writeup, you mentioned, "It was our
impression from the results that LN Wallets might need to make a few small
changes to better conform with v3 semantics before Bitcoin Core could safely
start treating anchor spends as v3 transactions".  Maybe explain your take
there.

**Dave Harding**: Yeah, that is my conclusion.  There's a couple of things that
need to change, which the main one, if you read the write-up, is 2.1% of the
transactions were batched CPFP spends,

like Gloria mentioned, and that's just something LN wallets would need to give
up.  I know LND does this.  I'm not sure any of the other implementations
currently do attempts to batch.  And in the discussion, Bastien suggested that
LN wallets today and in the future should just be, these are sort of
optimizations, they should start out with optimizations, but they should drop
them if their transactions aren't getting confirmed.  And if they just go down
to simpler and simpler transactions, simpler and smaller, then they should
eventually get down to something that would work.

But if you look at these results, with a few small changes, and I really think
they're small, they're just removing some optimizations that people have built
in, we get 100% compliance with this, except for the 1.2% of transactions that
weren't mined, because Suhas' data set, he just looked at every transaction that
entered the mempool.  So, he's got his node instrumented to record every
transaction, and he did that for all of 2023.  So, we don't know exactly what
went wrong with those 1.2% that were never mined.  It could be they just weren't
important to the people or the commitment transaction changed underneath them,
or something like that.  So, we can't say for certain with those.  But for
everything else, we get 100% compliance with just a few small changes to LN
implementation, so I think that's extremely promising, and I think hopefully the
LN developers are on board with this.  Bastian certainly sounded like it.  We
just need to talk to the people from the other implementation, and with those
few small changes, hopefully we're good to go.

**Greg Sanders**: Yeah, for the batching scenario, I think it's interesting that
batch CPU fees are being done with two anchors each.  I think that implies
HTLCs.  I just don't think it's very secure in general anyway, so I hope they're
doing backups already, I guess is my point, doing simpler topologies as
necessary.  The other case that we saw, a number of the cases, is basically two
CPFPs.  So, you have the commitment transaction, a CPFP child, and then a
grandchild, right, so double bump, which is extremely wasteful and we're not
sure why people are doing it.  But that's another thing that would be disallowed
under this rule set.  So, it's something to think about.  But again, we're not
sure who's doing this one.  I've talked to a few developers and we're not sure
why people are doing that.

**Mike Schmidt**: In terms of ideal next steps, we saw that t-bast, as Dave
noted, had replied with some ACINQ/Eclair-specific feedback.  It sounds like
ideally, for the 6%, getting the wallet/LN implementation developers to see this
discussion and chime in on their willingness to make the small tweaks that Dave
mentioned would be an ideal outcome.  Is that right?  And it sounds like,
instagibbs, you're already poking around to see who's doing a few different
things here in that 6%.

**Greg Sanders**: Yeah, I guess one of the big challenges is getting eyeballs of
all the spec people that need to look at it to actually look at it and give
feedback.  People are busy, but this part is a blocking thing for cluster
mempool, so it's pretty important.  So, hopefully we can get eyes on this soon.
Dave, anything else that you think we should note about these two v3 news items?

**Dave Harding**: Just for imbued v3 semantics, we do have a missing piece,
which is sibling replacement.  I think Gloria and Greg and Suhas are working on
that.  But at that point, I think Bitcoin Core side would be ready to go for
this, and it would be just up to making sure all LN wallets have upgraded to a
version that supports -- that doesn't do these optimizations that could prevent
their fee bumps from getting into the mempool, which in an LN setting is very
security important.  So, it's not something where we, on the Bitcoin Core side,
can really force people to upgrade.  We just have to hope everybody upgrades and
is ready to go at some point before this can get deployed.

_Bitcoin-Dev mailing list move_

**Mike Schmidt**: Next news item, titled Bitcoin-Dev mailing list move.  The
Bitcoin-Dev mailing list has, for a long while, been hosted at the Linux
Foundation and they've decided that that's a little bit burdensome for them to
continue to run and they've given several warnings, and finally they've pulled
the plug on their mailing list hosting, including the Bitcoin-Dev mailing list.
So, we covered this week the move from the Linux Foundation to Google Groups for
the Bitcoin-Dev mailing list, and the Linux Foundation will retain old messages
and links, which is nice not to break all of the historical mailing list links,
thank you.  And the new Google mailing list, you can subscribe in two different
ways.  You can send an email to the email that we noted in the newsletter,
posted by Bryan Bishop.  There's an email address in Brian's email where you can
email to subscribe.  There's also a web interface where you can subscribe.

Also, the Google mailing list can be viewed online without a Google account.
And there is also an external backup of the Google mailing list as well.  And in
the migration email by Bryan Bishop, there was an encouraging of users to host
their own public backups of the list as well.  Obviously, as a decentralized
community, we want to decentralize the backups and make sure that everyone has a
copy in case Google is mischievous and we need to access those separately.
Dave, what are your thoughts?

**Dave Harding**: If you liked the old mailing list, subscribe to the new one.
I don't have a lot of thoughts here.  The first post, the first actual
contentful post has been posted to the mailing list.  It's an email from Matt
Corallo about a new proposed kind of name resolution for DNS to Bitcoin
addresses.  Google, I kind of had to fight with Google to try to get that
delivered to where I wanted to be delivered to, but it seems to be working, so
that's my only thought.

_I Love Free Software Day_

**Mike Schmidt**: Last news item this week, I Love Free Software Day.  The Free
Software Foundation and the Free Software Foundation Europe use February 14th as
a day of appreciation for all the people maintaining and contributing to free
software.  The FSFE noted, "This year's edition is themed 'Forge the future with
Free Software', because we want to focus on the critical value of new
generations.  We want to involve youngsters in the celebration, both by thanking
young contributors and by introducing the principles of Free Software to those
who were not aware of it before".  I saw a couple of posts in the last few days
about this.  Gloria, I know you were thinking some, I think it was Vim plugin,
open-source Vim plugin authors, and I saw that Casey Rodarmor also called out
specifically you and your open-source contributions.  I don't know if you have
two cents on the vibes regarding open-source software and this I Love Free
Software Day.

**Gloria Zhao**: Sure, yeah.  I mean, it's really beautiful and yeah Casey wrote
that really, really nice post.  I mean, first of all, it's rare that someone
pays that much attention to the technical details.  So, I really appreciated
that, and there were a few donations that came into that address.  And I felt
guilty because I'm very, very lucky to be fully sponsored by Brink.  And so, in
the spirit of that day, I figured, what's some other free software that I depend
on?  And all these wonderful Vim plugins that make my life way easier, I don't
know, I just wanted to thank them.  So, shout out to Tim Pope and the others who
make my text editor the way it is.

_Add `maxfeerate` and `maxburnamount` args to `submitpackage`_

**Mike Schmidt**: Next section from the newsletter is our monthly segment from
the Bitcoin Core PR Review Club.  Larry, I see you're here this week.  Larry did
the writeup, thank you, Larry.  And this month covered Bitcoin Core #28950,
titled RPC Add maxfeerate and maxburnamount args to submitpackage.  The PR's
author is Greg, who is already with us today.  Greg, thank you for joining us.
Maybe as a quick primer for listeners, what is submitpackage and why do we need
to add these args to submitpackage?

**Greg Sanders**: Well, submitpackage is a way of submitting these
logic-connected transactions that normally have to be submitted together.  So,
the primary use case would be something like a parent transaction that has too
low fee to enter the mempool by a mempool min fee.  So, you can imagine like an
LN commitment transaction as the typical use case where the feerate had been
decided weeks ago by LN node operators or software, and then the min fee has
risen too much so it can't enter the mempool.  So, instead of submitting it one
by one, you can submit that along with the CPFP spend of it and those will get
evaluated altogether in what we call package feerate, such that it will enter
your local mempool, and then with some shorter-term future P2P improvements,
these will get propagated properly and make it to miners, hopefully.

As far as the burn and fee checks, these are just attempting to get feature
parity with the other RPCs that are offered on Bitcoin Core.  So, we have
sendrawtransaction, which has these checks already.  So, what happens sometimes
is people make a transaction using a Rust API or something, and possibly there's
a bug or there's a mismatch in expectations from the user, and suddenly it drops
an output or it has too many inputs and then suddenly the fee is just absurdly
high, like 100 times higher than anything we've ever seen being the going rate
in Bitcoin.  And Bitcoin Core, by default, will soft reject those.  So, if you
send it using RPC using sendrawtransaction, it'll say, "Hey, this is too high.
If you really want to send it, turn off this, you know, send an additional arg
to ignore this value or to uncap it".  And this is just getting feature parity
here within the package scenario for the same exact reason.

**Mike Schmidt**: Now, did what you just explain cover maxfeerate, and if so,
what is maxburnamount in its relation?

**Greg Sanders**: Maxfeerate is just how much, what is the actual feerate of the
individual transactions you're trying to submit, package or individual,
depending on how you want to implement it.  Burnamount is if you're making an
OP_RETURN, so an output that is provably unspendable.  I guess, I haven't seen
this historically, but apparently people have done it where they set the
OP_RETURN to actual satoshi values, so satoshi value is higher than zero, which
means you're burning value, right?  So, you might think there's a second layer
protocol, like some sort of colored coins thing, where you provably burn some
bitcoin and it gives you some other token or something, or just maybe a bug,
right, if you're doing a normal OP_RETURN.  Basically it's just saying, "By
default, reject all burns in OP_RETURNS", so don't burn any satoshis provably.
And then if you want to do it, you have to override it and give a max amount
that you're willing to do.  So, it's pretty straightforward.

**Mike Schmidt**: Excellent.  In terms of submitpackage functionality, where is
that in terms of its availability to end users; how can somebody use that today
or not?

**Greg Sanders**: Yeah, it's exposed now on mainnet under restricted topology.
So, there are some more benign cases where it might be helpful.  For example, if
your local node's min fee is higher than a remote node's, then if you get the
transactions in using the package feerate, it's possible that you'll actually
gossip it to another person.  So, imagine your peered with someone with a
gigabyte-sized mempool instead of 300, they'll tell you, "Hey, tell me about
anything above this feerate".  And then once you get into your own mempool, you
will tell the other peer.  So, it's possible that due to mempool asynchrony or
different configurations, that things like transactions could make it through a
bit more consistently.  But in general, it's not robust to adversarial
scenarios.  So, more work is required for that, both at the P2P layer and just
the mempool layer itself.

**Mike Schmidt**: Gloria, any color commentary on the PR Review Club that we
highlighted this week and/or submitpackage?

**Gloria Zhao**: Not much to add.  I think that covers it.

**Mike Schmidt**: Dave, anything that you think would be valuable to note?

**Dave Harding**: Just to note that I think last week in the recap, we talked
about LND starting to use testmempoolaccept to test their transactions before
broadcasting them.  And if you can write your code to do that, test it with
testmempoolaccept, set your settings there to what you want them to be before
you call something like submitpackage.  But it's really good to have this stuff
in submitpackage to check it directly.  But if you're able to, if you're just
automatically grabbing transactions that you generated from your wallet, before
broadcasting them, before trying to broadcast them, try to give them a test.

**Mike Schmidt**: We didn't have any releases or release candidates this week,
so we can move to Notable code changes.  If you want to ask a question, feel
free to request speaker access or comment on this Twitter Space and we'll try to
get to your question.

_Bitcoin Core #28948_

First PR, Bitcoin Core #28948, adds support for v3 transaction relay.  Gloria,
I'm glad you're still on.

You want to talk about this one?  You want to do a quick victory lap and tell
folks why this is exciting?

**Gloria Zhao**: Yeah, I think we've talked about v3 quite a few times already
in these spaces.  It's the first piece of a very long journey that's going to
get us a lot of great things in the Bitcoin ecosystem, and it's also
independently useful.  I don't know if I have much to add.  I'm very happy of
course, but I think Greg and Suhas are the real heroes here for pushing the
review and running simulations and doing really tight code review and looping in
LN protocol developers.  And like t-bast who has been, from day one,
super-willing to engage and give feedback and talk about what this is like for
the LN users.  So, yeah, I mean I'm really happy, but I want to give all the
credit to Greg and Suhas and the reviewers who helped push this through.  Thank
you, guys.

**Mike Schmidt**: Gloria, do you have any statistics off of the top of your head
to give folks an idea of the level of effort that this required?

**Gloria Zhao**: Sure, I think it was two-and-a-half years ago, well, three
years ago that I started looking at RBF.  I was like, "Wow, there's a lot of
problems with RBF.  People really, really hate rule #3 and #4".  So, there's
that mailing list post from a long time ago, which was I think 2021 or early
2022.  And v3 was, I think, if you look at the commits, I authored some of them
early 2022.  So, there's been three mailing list posts dedicated to this, four
Delving Bitcoin topics.  The original PR had 250 comments on it, which is why I
opened a new PR with a smaller scope of just v3.  And I think when it was
merged, it had, I want to say 335 comments or something.  So, yeah, it's been a
fun journey.

**Mike Schmidt**: Go ahead, Greg.

**Greg Sanders**: Oh, so just one note is that v3, the version, is still
configured non-standard on mainnet while we do some more bikeshedding and
review.  But with the main code in, we can continue to move on and build new
things on top, like sibling eviction, as you mentioned.

**Mike Schmidt**: And that standardness relates to our parenthetical here that
it is not enabled; is that right?

**Greg Sanders**: Yeah, right.  So, you can use it, for example, on testnet; you
can explore this functionality now, because v3 is standard on testnet.  But even
in testnet, you have to adhere to this topological restriction.

**Mike Schmidt**: Well, congratulations, Gloria, congratulations all of the
reviewers.  It's an exciting milestone along the way, as Gloria mentioned.
Thanks for your hard work, Gloria.

_Core Lightning #6785_

Next PR, Core Lightning 6785, titled Anchors not experimental.  And this makes
anchor outputs in the LN commitment transactions the default on the Bitcoin
Network.  Core Lightning (CLN) also supports the Liquid sidechain, which is
based on Elements software.  And for those chains, non-anchor channels are still
used by default.  Rusty noted in the PR, "It needs more work for that and it's
unnecessary at the moment".  Dave, or our special guests, any thoughts?  Great.

_Eclair #2818_

Eclair 2818, titled Abandoned transactions whose ancestors have been double
spent.  T-bast commented in this PR, "Transactions that are directly related to
a double spend, bitcoind is able to automatically detect and free up wallet
inputs that are used in double-spent transactions.  However, when a transaction
becomes invalid because one of its ancestors is double-spent, bitcoind is not
able to detect it and will keep wallet inputs locked forever".  He noted two
cases where this can happen, anchor transactions in the scenario I just
outlined, or if a different version of the commitment transaction confirms; and
also, the second scenario is a splice transaction when a commitment transaction
that is not based on the latest splice is confirmed.  So with this change,
Eclair now detects these scenarios and calls Bitcoin Core's abandontransaction
RPC, which keeps that liquidity available and no longer locked up.  Dave,
Gloria, instagibbs, any thoughts?

**Dave Harding**: You know, I really like that Eclair uses Bitcoin Core's wallet
rather than the other implementations having written their own wallet from
scratch.  But Bitcoin Core wallet does have some interesting behaviors, has got
some things here that maybe other wallets wouldn't have to worry about, but also
maybe they wouldn't be aware of.  So, it's just nice to see them actually
encounter problems.  It's not nice, but … and then figure out what they need to
do to overcome that, but continue working with Bitcoin cores wallet, which I
really feel like is a real underappreciated gem out there.  How much work goes
into Bitcoin Core's wallet to just make sure it handles everything safely,
whereas I think other wallets might not get a lot of review and might not
realize that there are problems out there.  So, I just like that they're
thinking through these things and making tweaks for them and continuing to use
Bitcoin Core wallet.

_Eclair #2816_

**Mike Schmidt**: Eclair #2816.  Dave, I may lean on you slightly on this one.
It adds a configurable threshold on the maximum anchor fee within Eclair.
Previously, this value was 5% of channel value and for large channels, it was
noted that that could be potentially too high if it's a large channel.  Dave,
what are the implications of this and what is Eclair's new default?

**Dave Harding**: Well, like you said, it could be too much.  Like, if you have
a 1 BTC channel, Eclair spending 5% of your value is $2,000 in fees.  I don't
think that that that math's right, but it's something like that.  And that can
be an awful lot in fees, considering even the highest mempools we've seen
recently and the size of an anchor output to fee bump its parent transaction.
So, it uses a new default, which is the maximum feerate suggested by its feerate
estimator.  So, the estimator it uses is Bitcoin Core's estimator.  It gives a
two-block feerate as its top, so the fee to get a transaction confirmed in the
next two blocks.  That's the most Eclair will pay right now, which is, that's
good.  I mean, some people have complaints about Bitcoin Core's feerate
estimator, but their complaints are that its fees might be too high.  So, by
using that as a default, as a max for Eclair, you have a pretty good guarantee
that your transaction is going to get confirmed in the next two blocks, so
that's good, without having to pay potentially thousands of dollars in fees for
a large channel.

Now, Eclair does also have an extra protection here.  It's kind of a scorched
earth policy here, that if you have an HTLC payment, an LN payment that's going
to be expiring soon, Eclair will just aggressively fee bump that up to the HTLC
value.  And this makes sense if your adversary is working with some miners to
censor your transaction, or is using just some trick on the network to try to
prevent your HTLC from confirming, your payment from confirming.  So, you have
the ability to claim this payment, but for some reason it's not getting into a
block.  Eclair's just going to keep increasing that fee up to the amount of it
to make sure your counterparty, who's an adversary in this case, doesn't get to
take your value back.  They would rather the money go to a miner who mines a
transaction than going back to somebody who's trying to steal it from you.

So, that's their other default, if you will.  It's a little confusing, the logic
here, but I think it's a good policy here to do that scorched earth for HTLCs
expiring soon.  Otherwise, there is an incentive for people to work with miners.
So anyway, in general, Eclair now has a more sensible default for the max
feerate it will pay for its anchor output.  If you have large channels in
Eclair, this is definitely something you're going to want to upgrade to using.

_LND #8338_

**Mike Schmidt**: Thanks Dave.  LND #8338 adds support for option_simple_close,
which is a simplified LN closing protocol.  This simplified closing protocol was
proposed by Rusty Russell last July.  We covered that in Newsletter #261, and
it's also currently a PR on the BOLTs repository, that's BOLTs #1096.  So, LND
adds support for that protocol.  I didn't have anything else that I thought was
notable about that PR, but Dave, maybe you do?  All right.

_LDK #2856_

LDK #2856, titled Route blinding: add min_final_cltv_delta to aggregated CLTV
delta.  The PR description noted, "Previously, we were not including the
min_final_cltv_delta in the aggregated BlindedPath and BlindedPay
cltv_expiry_delta.  This requirement was missing from the spec.  It has now been
added in the LN spec", and that's BOLTs #1131, and that was merged two weeks
ago.  So, LDK now includes that for blinded paths.  Anything?  Go ahead, Dave.

**Dave Harding**: So, yeah, so this is in an LN channel.  Usually we give each
hop that forwards a node a bunch of blocks to claim the payment before the
upstream from them is able to claim a refund.  And we usually want that number
to be as big as possible without creating unnecessary problems on the network.
But for the final hop, the person who's actually receiving the payment, we can
make that very low because they're either going to claim the payment offchain
ideally, or they're going to reject it.  They don't really need a delta, they
don't really need a difference in blocks at all.  And so, the LN allows setting
this to a really low value.  I think the recommended value is seven blocks.  And
just because of an accident, it wasn't specified in the specification and it
wasn't obvious.  LDK wasn't giving them any blocks at all, which I don't know if
that actually works or not.  I think that might actually work, but it's just a
little bit weird.  So now, that's just been added back in.  So, the route
blinding people, people receiving the route blinding actually can claim their
payments with a little bit of leeway.

_LDK #2442_

**Mike Schmidt**: LDK #2442, it adds details about pending HTLCs to the
ChannelDetails data structure used within LDK.  This allows users of LDK's APIs
that involve channel details to now have more information.  And the use case
there would be to potentially determine what needs to happen to further the HTLC
along the path to either being accepted or rejected.

_Rust Bitcoin #2451_

Last PR this week, Rust Bitcoin #2451, removes the requirement that an HD
derivation path start with an m character.  This actually came from an issue on
Rust Bitcoin's GitHub, where someone, "Observed it causing some confusion with
students reading BIP32 and then trying to use Rust Bitcoin".  So, m represents
the master private key in BIP32 land.  So, in some situations the m, or master
private key, is not necessary and could actually cause confusion, and did for
some of these students studying BIP32 and using Rust Bitcoin.  Dave, what's an
easy example that you might have at the ready for when m wouldn't be needed?

**Dave Harding**: Well, BIP32 paths are paths.  So, if you think of them, they
can have relative paths, kind of like a file on your file system.  You can think
of that relative to your, well if you're in Unix, your root directory, or you
can think of it relative to where you currently are.  So, it could be two
subfolders down from where you currently are, which could be four subfolders
down from the root directory.  And we can refer to BIP32 relative parts, and we
often do.  It's something that we frequently do in things like descriptors, and
whatnot, in a shared multisig wallet.  You might choose a subaccount, and you
might say, "This is where I'm going to use as my relative starting position".
And then the rest of these elements are describing, you know, one path is for
normal payments, one path is for change, and whatnot.

So, you don't always need to use an absolute path.  So, you don't always need to
start from the master private key.  You sometimes want to start from a subkey
and look at that.  And this just helps.  Josie Baker, like you said, was trying
to teach some people about BIP32 and encountered some problems with the way Rust
Bitcoin requires you always to start the string with an m, even if you were
talking about a relative path.  It's a little hard to get to in Rust Bitcoin.  I
think people were just reading code and being confused and thinking they always
had to use m.

**Mike Schmidt**: Thanks for that color, Dave.  I don't see any questions or
requests for speaker access, so I think we can wrap up.  Thank you to Gloria and
Greg for joining us as special guests.  Thanks, Dave, for co-hosting this week
and last week.  I believe Murch will be back next week, but of course, Dave, if
you want to join us, I think everyone would enjoy that.  But thank you for
co-hosting in his stead and thank you all for listening.  We'll see you next
week.

{% include references.md %}
