---
title: 'Bitcoin Optech Newsletter #420 Recap Podcast'
permalink: /en/podcast/2026/09/01/
reference: /en/newsletters/2026/08/28/
name: 2026-09-01-recap
slug: 2026-09-01-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Níckolas Goline, Optout, Abubakar Sadiq Ismail, and Moonsettler to discuss [Newsletter #420]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-8-2/431055681-44100-2-306a90d7c8abe.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #420 Recap.
This week, we're going to be talking about the Core Lightning (CLN) security
release action item, and we have News items covering replay protection for
future soft forks; we have the announcement of HWI repo entering maintenance
mode; there's a discussion on block-range filters for light clients.  And
then, we also have Sadiq, who's going to talk about one of our Bitcoin Core
PRs a little bit later, amongst some other Releases and Notable codes segment
items.  This week, Murch, Gustavo, and I are joined by a few different guests.
We'll let them introduce themselves.  Níckolas?

**Níckolas Goline**: Hey, Níckolas, I work at Core Lightning.  I'm the lead
maintainer.  After Rusty left Lightning, I stepped in to take care of the
releases, and whatnot.  I've been working on the Bitcoin industry for 12 years
now, exchanges and open-source projects, and I used to have a C#
implementation of the Lightning Network, called NLightning.  I lost funds and
I joined Core Lightning to keep the work going.

**Mike Schmidt**: Excellent.  Thanks for joining.  Optout?

**Optout**: Yeah, hello, I'm Optout and I'm an aspiring Bitcoin Core
contributor.

**Mike Schmidt**: Excellent, thanks for joining.  And Sadiq?

**Abubakar Sadiq Ismail**: Hi, I am Abubakar Sadiq, I contribute to Bitcoin
Core, supported by 2140 and Btrust.

_Prepare for an upcoming Core Lightning security release_

**Mike Schmidt**: Well, thank you three for joining.  We may have a fourth
guest joining.  We'll have them introduce themselves when it's appropriate,
but let's jump into the newsletter and start with the Action item, "Prepare
for an upcoming Core Lightning security release".  Níckolas has joined us from
Core Lightning.  Obviously, this item came out Friday, and we were sort of
warning, if you will, or having listeners and readers get ready for the
forthcoming release.  But maybe, Níckolas, you can let us know what has
happened since then, and maybe also what happened before then, and maybe what
people should be aware of more broadly.

**Níckolas Goline**: Sure.  I guess everyone is aware of the huge influx of AI
security reports.  Everyone is getting those, we are no exception for those,
and we got a big number of security reports.  And it's been three weeks since
we got the first one, just one critical one, but I would say not a big deal,
because the exploit is very convoluted, it's very hard to achieve.  So, that's
why we took our time, included more advisories on the list.  It was very hard
work for the small team we have to sort through the advisories and duplicate
them, write fixes, check the fixes from each other, review the code, write
tests.  It was very hard work we have done.  And then finally, last week on
Friday morning, we had the release ready.  We opted to do a binary-only
release this time, because releasing the contents, the source code, would help
attackers, at least give them a lead on how to exploit the vulnerabilities.
We included a lot of low vulnerabilities and middle, something like this, as
well as some public PRs we had open that fix some known bugs, to make it
harder for an attacker to pinpoint the changes.  And then, the source will
come in 14 days since the release, so we are talking about next Friday, not
this one, the next one.

To put people at ease, we signed the release, we signed the three, the git
tree, all the contents, including tests, documentation changes, and the
changes itself.  We signed the binaries up front.  So, as soon as we have the
source ready for release, people will be able to just do the reproducible
builds and check that the SHAs match and that we didn't put anything strange
in the release.  It comes at a time that we just had a huge issue of COLDCARD,
and I know people are very wary of running stuff that they cannot read the
code.  But then, it actually is a bigger problem because no one is reading
changes anyways.  So, people are usually running CLN or LND, or other
implementations, from Docker images or from the binaries itself.  Just a few
select people really read the codes and the changelogs, and those people
contacted us as well and asked if there's something they could do.  And the
message is the same for everyone, it's a public message, "Update now".  If you
cannot update, if you're not comfortable updating, if you cannot read the
source right now, just run the node with --offline.  This makes the node not
accept incoming HTLCs (Hash Time Locked Contracts).  It does not accept new
channels, but it keeps an eye on the onchain, what's happening onchain.  So,
you cannot get force closed, or someone publishing a node commitment
transaction and trying to rob your funds.

So, this is what we have.  And this is public as well, but we were running on
the internal swaps and other parts of the company on Blockstream.  We've been
running the same release as everyone else.  Especially, we run the 26.06.6
until Friday afternoon.  So, we didn't get a special treatment for the
company.  We were running the same software as everyone else with 5 or 6
bitcoin in the game.  So, we are really behind what we told on the public
release.  It's not a big deal.  And just something that came in, I guess it
was yesterday morning.  Someone already reverse-engineered the binaries.  So,
if you really want to see the changes, it's out there, it's public, it's open
source.  We cannot release what we have because, like I said, documentation
changes and the tests give away the whole thing.  So, if we try to do
something right now and publish, stripping the tests and the documentation,
the tree wouldn't be the same.  And then, I guess it generates more questions
than it answers.  So, if you're really curious about the changes, it's public.
But yeah, in 14 days, now it's 11 days, everyone will see what we have done.

If I can just add something more, this was a big learn for us as well.  I
guess it's new for open-source projects to do embargo releases like we did.
Bitcoin, BTCPay Server did one just a couple of days before we did ours.  We
already had that in mind, we were going that path.  And when we saw Nicolas
and his team launch a binary only, it just enforced that we should do the
same, thinking about the safety of our users' coins on the network.  And the
big learn is that LLM's AI are very, very ahead of what everyone thought they
would be.  And it took just a couple of hours for someone to just grab the
binaries.  We took all the measures to make it harder, but it took a matter of
hours for them to just reverse-engineer the binaries.  And from the source
code they extracted, they could generate the exact same binaries.  So, it's a
big learn.

**Mark Erhardt**: So, maybe let me jump in here with a couple of questions.
It sounds like you can confirm that the binaries built by, I think it was a
Nirvati or something, I saw a blogpost yesterday, and they said that they
disagreed with the approach.  The embargo seemed like a bad idea to them.  So,
they reverse-engineered the source code from the binary, and with the source
code, they were able to reproduce the build on Fedora.  So, it sounds to me
like you can confirm that they did indeed get the right source code.  Is that
correct?

**Níckolas Goline**: Yes.  And it not me saying that they got the right source
code.  It's the sum saying that the SHA sum is the same.  So, the binary is
the same, so they have the right source code.  There's not much we can do.
And I guess this is the big learn we all got from this.

**Mark Erhardt**: Right, yeah.  I think they said that the binaries had been
built with the debug statements, and that had helped them a lot with putting
it back together.

**Níckolas Goline**: Yeah, I guess helped them, but we could never stop them
doing what they've done.  I guess LLMs are very good right now, and especially
the very expensive ones, it's just a matter of time.  So, the learn here is
that we still have a couple of dozen security advisories to go through, and we
already have fixes for most of them.  Most of them are on the lower end of
vulnerabilities, as it goes.  So, the next security release will be different.
We'll probably be warning people like, "Tomorrow we'll have our security
release.  Please update".  And then, we'll be building the binaries
beforehand, not letting the CI do it because it takes time.  So, we will
release the source and the binaries together, and people will have to update
faster, I guess.  They will have to keep track of what's happening, because
everything is moving very fast right now.

**Mark Erhardt**: Yeah, I think that's the big takeaway for everyone: (a)
embargoes are really difficult with LLMs being able to reconstruct source code
much more easily; and (b) a lot of people seemed confused or alienated by the
approach of the embargoed release because they felt, "Well, isn't the whole
idea of open-source code that I can see what I run?"  So, yeah, I think that
was also the recommendation of the blogger that had done the
reverse-engineering, was to release source code and binary at the same time,
but maybe without a pre-announcement so that people wouldn't know ahead of
time to look; or with pre-announcement so that people know to update.  There
are just no good solutions really in this day and age with LLMs so quickly
catching up on security engineering, and the whole security game changing in a
matter of months.  So, yeah, if you say you have a couple of dozen more
security vulnerabilities, lower-end security issues that will be fixed, it
sounds like you got, well, at least a few dozen reports in the past few
months.  That sounds like a lot of crunch time.

**Níckolas Goline**: Yeah, there was a lot.  I would say we got more than 100
reports.  And from that 100, I would say, like, 60%, 70% was duplicates, so
they were finding the same vulnerabilities.  And most of those were not
vulnerabilities, per se.  It's not coins at risk or a DoS risk.  It was mostly
bugs.  We got some vulnerabilities like, "If they have access to your
database".  And that's like, if they have access to your database, you're
doomed, right?  So, it's just a bug, it's not a vulnerability.  So, it got us
working a lot to go through all of this.  And the team has been very, very
good at it as well.  I could not ask for a better team to work with, because
we went through a lot of code.  LLMs, they have the ability to overestimate
things, and everything is critical.  And every time we got a pack of
vulnerabilities from one of the teams, it was, like, 90% critical.  And then,
it got a lot of effort to go through that, read all the reports, the
reproduction steps, and realize it's just a bug.

**Mark Erhardt**: Yeah.  There's one thing, that a lot of these LLM reports
are incredibly verbose, because they sort of give reproduction steps or
someone that's not familiar with it.  And then, on the other hand, I heard
from Bitcoin Core contributors as well that a lot of the reports were for odd
threat models, sort of like, "You can crash the node when you misuse an RPC".
Well, yeah, but the RPC is only accessible to the node runner, so they're
basically shooting their own node.  They can just call bitcoin-cli stop!

**Níckolas Goline**: That's true!

**Mark Erhardt**: Yeah.  Well, I'm glad that you were able to rule out a lot
of the reports, but I bet that you have been working around the clock.

**Níckolas Goline**: Yes, for the past three weeks.  I guess everyone in the
space, I guess since the COLDCARD hack, it opened a door, like the Pandora
box.  And now, everyone is just dealing with this huge influx of AI-generated
stuff.  We've been getting reports on the security at blockstream.com.  But
there is just clear text that shows that the person that is filling the
reports are not very used to security reports and the whole deal.

**Mark Erhardt**: You mean they don't even encrypt the security vulnerability
reports?

**Níckolas Goline**: No, it's just plain text over Gmail.  So, it's really
bad.  It shows that AI is running with some MITM proxies, and this gives us a
lot of work.  But we cannot ask people to not do that, because some of those
were real and it helps us at the end of the day.  It's just that we have to
upgrade our tooling on our side to be able to move faster to false positives.

**Mark Erhardt**: But people, at least give your LLM a GPG key so it can
encrypt its security reports!

**Níckolas Goline**: Yes, please!

**Mike Schmidt**: Níckolas, I know you've got to run.  Anything that you would
leave listeners with?  It seems like that would be a good place to leave it is
just, everyone's working on this, look out, update your software, etc.

**Níckolas Goline**: Yeah, you should really update for the latest version.
Right now, it's 26.06.7 We have the Docker images out for ARM, ARMv7, ARM64,
AMD64.  We have the binary signed as well if you want to run this yourself.
And keep an eye on the official channels, like X and the node runners'
Discord.  There's a Telegram group as well.  We are posting on the three
separate groups at the same time, so nobody's left out.  And at these crazy
times, you just have to be on the lookout for new releases for all the
software you're running, so keep an eye on that.  And in the following weeks,
we will have a few more security releases.

**Mark Erhardt**: Sorry, could you repeat where you were be announcing?

**Níckolas Goline**: It's the Discord channel for CLN, the Telegram group for
node runners, CLN node runners, and official Blockstream X, or Twitter.

**Mark Erhardt**: Maybe also send an email to the Bitcoin-Developer mailing
list for this sort of thing.

**Níckolas Goline**: Yes, we will.

**Mark Erhardt**: Thanks.

**Mike Schmidt**: Níckolas, we appreciate you joining last minute to talk
about this.  We know you've got a lot of things on your plate, it sounds like,
and we appreciate you coming to speak directly about this.

**Níckolas Goline**: Thank you for the space.  I'm really grateful to be able
to expose our side of the story and why we chose to do what we chose to do.
So, thank you.  See you around.

_Request for comments on using block-range filters_

**Mike Schmidt**: Cheers.  We're going to jump to the News section a little
bit out of order.  We're going to go to the item titled, "Request for comments
on using block-range filters".  And, Optout, this was motivated by a post from
you about light wallets that use compact block filters, being able to download
a small filter for every block, and check locally whether any of their
addresses might be in it, and then only downloading full blocks on a match.
But we want to get into the range aspect.  And I know you did some sort of
studies on what ranges are appropriate, but maybe to start out, what's the
motivation here, and then you can talk about the range filters?

**Optout**: Yeah, sure.  So, as a general background, I'm interested in any
ideas or proposed changes that help the use case when you have a wallet but
you don't have any software running, and you want to get up to speed to see
the situation with your wallet.  And of course, the full way to do it is you
can install and start a Bitcoin Core node and do a full IBD (Initial Block
Download), which is quite resource-intensive.  Although, in the last couple of
releases, there's been quite some improvements to the IBD process.  And in
general, compact block filters is a good way for this use case.  Although, in
my opinion, not too many wallets make use of it, there should be more.

So, with this background, there was a post in Delving about some new filter
encoding.  I think it was fuse filters.  And what caught my eye was that the
author mentioned hierarchical block filters, and that got me thinking how
could that help.  The basic idea is that with the compact block filters, we
have a block filter for every block, which you download first the block
filters for each block, which tells you if the addresses, the output scripts
you are interested in are present in that block or not.  So, the idea with
hierarchical is that we create a filter not for one block but for a range of
consecutive blocks, and you download those first and you have a match, then
you download the individual block filters.  So, a block-range filter for,
let's say, 256 blocks basically includes the same set of scripts which are
included in those 256 block filters, but exactly the same as even those which
were spent within the range, because for history you still need those which
were created and destroyed within the range.  But in general, they contain
less information, because they tell you if an address was used in that block
range, but it doesn't tell you in exactly which block.

So, the cost is that if you have a match, you have to download all the block
filters, which is kind of a duplicate download.  But still, because of the
savings in the block-range filter, the total download size can be less, which
is kind of counterintuitive.  But I decided to explore, and to my surprise, I
found that the savings can be actually quite substantial.  In some cases, the
total download size went below 20% of the original.  And of course, this
depends on the exact parameters, like how many transactions you have, because
that influences how many times you have to go to the second level.  So, I just
did this as a preliminary analysis to see if this idea is worth pursuing.  And
yeah, I think it is, and I have some ideas for continuing because this is just
a basic idea.  And of course, there are a lot of open questions as well still.

**Mark Erhardt**: Right.  So, the compact client side block filters basically
give you a table of contents, or an easy way to check whether output scripts
and UTXOs that you're interested in are present in blocks or being used.  And
you sort of introduce a second level there that groups block ranges of 256
blocks into a single filter, so you can only get that bigger filter for the
range and see, "Oh, if there's nothing in here that interests me, I don't have
to download the 256 individual block filters".  But when you do have a hit,
you obviously have to download all of the 256 individual block filters.  So,
now you download more data than you would have if you had done that in the
first place.  But when you don't even find anything, of course, you save a
lot.  So, especially for wallets or users that don't necessarily transact
every day, maybe just a couple of times a month, or even less often, there's a
huge savings here, because they only download the ranges and then are able to
say, "Oh, I did not have any activity in these about two days".  You were
muted.

**Optout**: Yes, exactly, that's right.

**Mike Schmidt**: Optout, you mentioned fuse filters, and we did have a
discussion about that back in Newsletter #403, just a different approach to
BIP158's internal, I guess, algorithm.  Then we talked about that with
roasbeef and Rearden in the podcast as well.  I think that was an update to
the internals, and not necessarily an idea to extend the range wider as you're
doing there.  But I know you mentioned it, so I wanted to tease that for
listeners who wanted to dig in more to that.

**Mark Erhardt**: I mean, talking a little more about who this is good for, if
you run a high-volume wallet that has transactions every day, you probably are
not going to save with this.  If you have transactions every day, you should
probably just download the compact client side block filters in the first
place, or you have a full copy of the blockchain already because you're
running a high volume, or at least daily active service, and you need to be
aware of what's going on.  But if you're running a light client that you
transact with maybe once or twice a month, this sounds like you could
significantly reduce the bandwidth, because you're actually only interested in
a few blocks per month.  And then, only if your block falls into this range of
256 blocks, you would even download the block filters.  So, yeah, for light
clients, especially ones that run on the mobile network that would be huge
decrease in bandwidth.

**Mike Schmidt**: Optout, what are next steps for you?  Where can listeners
find more or potentially help contribute or learn more?  Like, where are you
going and where should people who are curious be going to find out more?

**Optout**: Well, for listeners, there's not much more I can say than, check
out this Delving post mentioned here.  And I welcome any ideas or suggestions.
I have a few ideas which I plan to try out, also do some measurements on the
actual mainnet data.  And yeah, I have some other ideas.  Like, I just
mentioned one that once you download the filter for the block range, you have
the set of all the scripts within that block range.  So, for the individual
blocks, maybe we could save some bandwidth if we don't encode the actual
scripts, but just their index within the block range, which are somewhat
smaller numbers than the hashes used in the compact block filters.  So, this
could reduce this data duplication which you have to do when you have a match
in the block range.  So, that's something I want to pursue and see how much
saving can be obtained there.  Yeah, so the Delving post and if I have any new
news, then I'll post it there as well.

**Mike Schmidt**: Excellent.  Well, I guess we'll keep an eye out for that.
Maybe we'll have you on the podcast in a future show to go through more.
Murch, did you have a final question?

**Mark Erhardt**: Yeah, I was wondering, so you said you would encode the
height in the result of the block filter.  Is that at the range level or at
the individual block level?

**Optout**: Well, my idea is that you can think of a one-block range, a
one-block filter, which through this encoding it encodes, for example, 4,000
output scripts within that block.  And if you have the filter for the whole
block range, that's something on the order of 256 times 4,000 scripts.  And if
you have that, that's basically you have a number of output scripts and you
can just count them and give them their index first, second, third, and so on.
And then later in the block filters, you can just use these index numbers,
which as I see, they should be, like, on the order of 13 bits, and not, like,
19 bits, which we use in the compact block filter.  So, that could decrease a
little bit the data.  So, this would be a special, a different kind of block
filter, which doesn't include the hash of the actual scripts, but just an
index within the block-range data, which we already downloaded.

**Mark Erhardt**: Right, that would not be forward-compatible.  But basically,
you would be using the range block sequence of output scripts that you have
contained in there as just a reference for the blocks at the block level.  I
was wondering whether maybe the other way around is interesting, that if you
get a result for a hash, that it tells you which blocks to download in the
range instead of, yeah, maybe it could just tell you which blocks are relevant
and then you only download those filters?

**Optout**: Yeah, that's an interesting idea.

**Mark Erhardt**: All right.  Sounds interesting to me, at least.  I hope that
helps with your request for comments.

**Optout**: Yeah, thanks a lot.

**Mike Schmidt**: Optout, we appreciate your time on this project and for
joining us today.  We understand if you have other things to do, you're free
to drop.  Or if you want to hang on, you can.

**Optout**: Yeah, thanks for having me.  I'll hang on.

_Bitcoin Core #34075_

**Mike Schmidt**: We're going to do a quick detour into the Notable code
segment and jump to Bitcoin Core #34075, mempool-based fee estimation, since
we have the PR's author here.  Sadiq, you can frame this up however you would
like, including commenting on Bitcoin Core's historical fee estimator quality.

**Abubakar Sadiq Ismail**: Thanks, Mike.  Yeah, the goal of this PR is to
improve Bitcoin Core fee estimator.  It works, it works really well, but it
does overestimate due to a particular limitation that it has, which is it does
not look at current data, it uses, like, historical data for its feerate
estimation.  So, this PR tried to address that limitation.  Over the last two
years, I started doing research on approaches to estimating feerate and I
studied the previous Bitcoin Core feerate estimator to understand why it was
designed the way it is, and study the state-of-the-art feerate estimators.
So, I made a series of Delving Bitcoin posts with data.  And other
contributors in the community also commented about their own research.  And
then, we converged in an approach to make sure that the feerate estimator is
still a bit conservative, but it does not overestimate when it shouldn't.  So,
Bitcoin Core full node has access to the mempool.  It can easily build block
templates and see the chunk feerates in that block template.

So, what the new approach of estimating feerate in Bitcoin Core does after my
PR is that it takes the minimum of the legacy bitcoind block-policy feerate
estimator, and what is currently being paid in the mempool, so what are the
chunk feerates of the top block template in the mempool?  And then, we select
some percentile feerates, based on some empirical data that we do, and then
just return the minimum.  And this works really well and it reduces
overestimation quite significantly, has a high, like, up to 80% success rate.
And sometimes it does underestimate, because there are scenarios where the
block portion distribution arrivals take a while, and then some congestion
occurs in the mempool, or there is an influx of transactions in the network.
And because it takes the minimum, it cannot reflect due to that.  So, there is
some underestimation due to that.  And the compromise that we did was, it's
safer to fee bump, but once you overestimate, there is basically no way to
come back from that.

So, yeah, I have been running the empirical data, opening up the PR to
reviews, refining it, and we currently have a much version of the PR that is
intended to be released in the next major release of Bitcoin Core.  So, this
is the background.  I did not go in depth into the algorithm and how it works.
There is some preliminary health sanity checks that we do, because you cannot
just naively use the mempool for feerate estimation.  You have to ensure that
your node is well connected and it is not censoring transactions or doing some
nasty things before you use your mempool for feerate estimation.  So, I have
some heuristics that I use to determine whether the mempool is healthy enough
to rely on, so I can go into that.

**Mark Erhardt**: Yeah, I have a couple of questions about that.  So, for
example, if you were throwing away about 45% of all transactions because you
disagree with people putting NFTs into the blockchain, and then you see what
you had in your mempool and what gets included in blocks, would your node
consider itself healthy if you only have about half of all transactions in
blocks?  Or what is the threshold for healthiness?

**Abubakar Sadiq Ismail**: Yes, so I use, like, six blocks' interval, I do not
just take one block.  So, I take the average of six blocks.  And I use a
conservative 75%.  And with that, the majority of the time I have not seen any
scenario where a node that is censoring transactions has achieved 75% success
rate in that six blocks' average.  So, it's like a number that I've picked
based on empirical research.  I have a data branch and I'm gathering data and
I can easily tweak and update that if that is not the case.  But right now,
the threshold is 75%.

**Mark Erhardt**: 75% of the transactions or the block weight?

**Abubakar Sadiq Ismail**: Your mempool has to see 75% of the transactions in
the last six blocks' average.

**Mark Erhardt**: So, for example, if you set -datacarrier to zero, so you
wouldn't propagate any transactions that have an OP_RETURN output, you would
not use mempool feerate estimation anymore?

**Abubakar Sadiq Ismail**: It depends.  If people are using a lot of
OP_RETURNs, then your node is not seeing OP_RETURNs, so your feerate
estimation using mempool will be very inaccurate.  I think even using
block-policy feerate estimator will not be accurate as well.  So, yeah, that's
the advantage of the tracking statistics, to ensure that you are not doing
that.

**Mark Erhardt**: Okay.  So, yeah, you talked a little bit about the mempool
feerate estimation, when it is used and what effect it has.  So, it can only
reduce the estimate.  Basically, if the mempool feerate estimation estimates
lower, the lower estimate is used for the transaction building and for the RPC
that returns a feerate estimate.  Could you go a little more into why you
wouldn't want the mempool feerate estimate to be used to increase?  You
touched on it, but let's dive a little deeper into that.

**Abubakar Sadiq Ismail**: Yeah, so during my first post, I was recommending
using the mempool feerate estimation for as soon as possible feerate estimate,
which is like one and two confirmation targets.  But it has come to my notice
there are some theoretical attacks that are possible.  Like, miners can do
some mempool games to artificially inflate feerate estimate in the network.
Right now, we are not seeing that, and I don't think there is the mining
centralization that warrants that, but it's still theoretically possible.  So,
they can even not publish their high feerate transaction, but they can just
choose to withhold blocks or do something, like some mempool tricks, to just
create influx of transactions in the mempool.  So, you are not really sure
when there is a spike, whether that spike is legitimate from Bitcoin users, or
it is just someone who controls the hashrate trying to manipulate you to pay
in more.  That's why Bitcoin Core, the bitcoind block-policy feerate estimator
uses the mempool transactions that have confirmed in blocks as the data points
for the feerate estimate.

So, yeah, I saw research from I think Kalle Alm, who suggested using the
minimum of the bitcoind block-policy feerate estimate and mempool feerate
estimate recommendation.  So, I started running empirical analysis on that to
see how that works.  And it turns out to be really good and good enough for
use case that Bitcoin users want, which is not overpay when basically the
mempool is empty, which is, right now, the majority of the time.

**Mark Erhardt**: Right.  So, one of the problems that the confirmation-based
feerate estimation had is that the reduction of the feerate would lag behind.
So, you take the transactions that you had seen in your mempool and then later
see confirmed, and you take the time that it took between first seeing them
and then seeing them confirmed to estimate how long it takes for transactions
with those feerates to get a confirmation.  Now, of course, if there were a
lot of high-feerate transactions and then fewer of those get added, the
feerate would start going down.  But since you have this lagging indicator by
having to see them first unconfirmed and later confirmed, you would continue
to overestimate if you're trying to be in the next block, because you would
assume that, "Oh, to be in the next block, we have to pay that feerate that
was previously used, to be in the next block".  So, in the past, especially a
long time ago when people were relying on Bitcoin Core feerate estimates more,
we sometimes would see an artificial floor, a second artificial floor, the
feerates going down and then Bitcoin Core feerate estimation continuing to
self-reinforce high feerates at a higher level for some time, because people
that were trying to use the next block estimate can continue to pay the same
feerate for some time.  And the mempool feerate estimation would now very
effectively pull this down, because it would see that what is waiting in the
mempool right now is much lower than the prior estimates.  So, on that edge of
the feerate diagram, it works very well to pull the estimates down to the
actual mempool content.

One of the games that miners might play is if they have a big cartel, they
could create transactions that have high feerates but not mine them.  So, they
would be sitting in the mempool and people just looking at the mempool would
try to beat the high-feerate transactions sitting in the mempool.  But then,
the mining cartel would not mine them, just leave them in the mempool.  So,
other people would be paying feerates to compete with something that is
actually not competing for blockspace.  And this is prevented by the old
feerate estimation style of Bitcoin Core, where we require confirmations to be
counted for feerate estimation.

**Abubakar Sadiq Ismail**: Well described, basically.  Yeah, this is correct.
Are we improved?  Not improved, but we've switched the default.  It's now not
overestimating to a significant factor.  Previously, it's like you would see
even 10x or 15x overestimation.  But now, it's like much, much lower, but
still this lowers it really down.  And I have a graph in the PR description
where it accurately describes what bitcoind is recommending and what the
mempool is recommending and what the actual block feerates are.  So, you can
vividly see that this just corrects what is being recommended when it is not
actually high.

**Mark Erhardt**: Right.  So, the mempool-based feerate estimate has two
different values that it picks.  One is the median of the next block for the
higher estimate, and then, what is it, the last quartile of the next block by
block weight.  So, if you create a block template, you basically pick what is
the feerate at 50% of the block weight and what is the feerate at 75% of the
block weight of our next block's template.  So, 75% is the conservative, but
that would still mean that most of the time, the mempool feerate estimate is
actually going to get you into the next block, right?

**Abubakar Sadiq Ismail**: Yes.  So, the assumption that we have in full, we
don't really have next block, it's like next one or two blocks basically.  So,
if you are a conservative user, you can use the conservative mode, which will
take the 50th percentile as you mentioned, and it's very unlikely that you get
bumped out.  But yeah, you are right, for the 75th percentile, you may not
confirm in the next block, but most likely you will be in the subsequent one,
because you will be at the top then after the block has confirmed.  So, it
depends on the user's needs.  That's why we have the two options.  But the
default right now is the economical version, which is the 75th percentile.

**Mark Erhardt**: So, if you were worried about your transaction being in the
actual next block, what you might want to do is you polling the mempool
feerate estimate every minute or so, and if it is significantly higher than
the feerate of your transaction previously, you would RBF it again.  And you
would basically just keep bumping your transaction to the 75th percentile of
the next block, which would still be at the low end of the block.  And it
would still likely be a significant reduction over the block-based feerate
estimate when feerates are generally dropping right now.  But this enables you
still to sort of aim for the next block, maybe as an idea for operators.

**Abubakar Sadiq Ismail**: Yeah, also with cluster mempool right now, we also
have an added tool which is getmempoolfeeratediagram.  So, you can actually
visualize the graph of the mempool and see what are the feerate percentiles
from the top block, and determine what is the position of your transaction.
So, yeah, the user experience is going to be nicer, I think, for people that
have Bitcoin nodes.  They can see the position of their transaction.  If they
want to rely on bitcoind estimate smart fee, they can do it and it works.  But
if they want to do smart things, they can do what you suggest, or see the
position and fee bump to the next position.

**Mark Erhardt**: Of course, maybe also in this context, RBFing is a bit of a
privacy leak, because you might add another input and then combine more
transaction graph data into your wallet history.  So, if you're very
privacy-sensitive, you might want to overestimate a little more.  So, you
could use the mempool feerate estimate and then just add a little if you're
both privacy-sensitive and want to be reliably in the next block.

**Mike Schmidt**: Abubakar, you made a few references to your thought process
over time with regards to when it ended up in this PR.  I wanted to call out a
few things.  We had you on in Newsletter and Podcast #295, #283 and #276 to
talk about these kinds of items.  So, if listeners are curious, probably not
all of that discussion is valid, based on what's in the PR today.  In fact,
Abubukar, you noted some differences in your change in approach over time.
But if folks are curious, they can reference back to that.  Also, I thought
that the description in the PR that we're covering here is actually a pretty
good reference as well.  There's a ton of different links.  It's almost like
its own blogpost as well.  So, if you're hearing that this is a Notable code
item, maybe treat it almost more like a News item.  There's a lot to dig in if
you're curious about it.  Yes, Murch?

**Mark Erhardt**: Oh, I have actually one more question.  So, I took a good
look at this PR for the newsletter item.  And I was wondering, if there are
too few transactions waiting for confirmation in the mempool, the estimate
falls back to the minimum feerate, right?  So, if the mempool is actually
empty but healthy, you would want to use the minimum feerate and still expect
to be in the next block, right?  And in the release notes, it said that it
would fall back to the higher of the minimum relay feerate, which is now 0.1
sats/vB (satoshis per vbyte), or the mempool minimum feerate, the higher of
the two.  And I was wondering if the mempool is generally empty or not full,
wouldn't the mempool minimum feerate also be the minimum relay feerate?
Because I think the mempool minimum feerate only rises when the mempool is
full, right?  So, if your mempool, which is by default 300 MB for the data
structure, overflows, the mempool minimum feerate will rise.  So, could you
maybe touch on how it's not always the minimum relay feerate, or what I'm
missing here?

**Abubakar Sadiq Ismail**: Yeah, I think your thought process is correct.  I
don't think it's going to diverge in that case.  I was just trying to be
conservative in case if they do, but I will have to look at the historical
data to see if it ever happens.  But I don't think it's likely that that will
occur.  So, in this case, the minimum relay fee is enough for your transaction
to propagate.  But you also don't want it to propagate and not be in your
mempool.  So, I guess I will add an assumption in the code that they should be
the same, see if any tests will fail, or I will see a crash.

**Mark Erhardt**: Maybe if you configure a very, very, very small limit for
the mempool, you might get into some cases where, let's say, there were very
high feerates for a brief moment and your local mempool feerate went up very
high.  And then, as the demand drops a little bit or drops very rapidly, you
might get into a situation where you have an almost empty mempool, but the
minimum feerate hasn't regenerated fully yet.  So, I guess in that case, it is
good to know that it is the higher of the two minimums, but I think you'd have
to run a very odd configuration and then run into very specific circumstances.
But yeah, anyway, I just noted that it was pointed out as an item, and was
wondering whether there was more here.

**Abubakar Sadiq Ismail**: No, I was just being conservative, I did not.  But
that's a good point.

**Mike Schmidt**: Abubakar, thanks for your work on this over the years.  And
thanks for joining us today among these other appearances that you've made.
And also, thank you for engaging 10 out of 10 nerd-level Murch on this
particular item.  Murch is on fire for this one.  We appreciate your time.
You're free to drop, or you can hang on if you'd like.

**Abubakar Sadiq Ismail**: Yeah, it's my pleasure.  Thanks for having me.

_Discussion on universal opt-in replay protection_

**Mike Schmidt**: Cheers.  We're going to jump back up to the News item.  We
have a fourth guest that has joined us.  Moon, before we introduce the item,
why don't you introduce yourself?  Who are you?

**Moonsettler**: Hello everyone, I'm basically just someone that likes to
opine on Bitcoin consensus rules, I guess.  I try to contribute to the
discussion about Bitcoin security and scaling.  I think that's all about me.
I'm a nym and that's how I like it.

**Mike Schmidt**: Well, thanks for joining us.  We'll jump into your item
titled, "Universal opt-in replay protection".  Maybe you want to help us set
this one up, Moonsettler.  Maybe, what is replay protection?  Why are you
happening to talk about it now?  And then, what is your proposal?

**Moonsettler**: All right.  So, replay protection means if there is a chain
split, then the default is that a transaction that is valid on one chain is
also going to be valid on the other chain.  And replay protection is some
explicit rule that prevents this from happening.  And for example, the Bitcoin
Cash fork included such a replay protection.  But transactions that did not
use it, I believe, were re-playable on both networks.  So, if someone wanted
to, let's say, sell his Bitcoin Cash and he was not careful, then he could
also have sent his bitcoins away to someone else.  This is a major issue.  And
I have seen when the BIP110 fork discussion happened, and we were watching the
whole thing basically play out live, a lot of people advised that nobody
should even attempt to sell one side of the fork, because there is this great
danger that there was no replay protection.  And that can be a deliberate
choice.  Like, anytime someone attempts a fork, they can decide, and
especially if it's a hostile fork, they would probably decide not to add
replay protection.  And people, of course, every time something like this
happens, the discussion comes up who controls the network and who decides, and
stuff like that.  And I always thought that in the end, if you are up against
a minor majority, the only thing you can do is sell your coins on the fork
that you do not want to see, and keep them on the fork that you want to see.
And if enough people do this, then the economic incentives align, and that
fork will have the greater hashrate.

Now, when someone is faced with a situation with no replay protection, then
obviously it becomes apparent that this is not as easy to do, and it's
actually dangerous.  And the whole idea about adding opt-in replay protection
is to empower the users, that when in need, they can safely and securely make
a deliberate decision.  They can express their desire, their beliefs, their
preferences via moving their coins.  And even if only one of the forks, let's
say, even if only one of the forks enforces these rules, the coins can still
be split.  And this might actually be very important if we ever find ourselves
on a minority hash fork.  Let's say a majority miner cartel hash-power share
decides to execute a hostile hard fork, the thing that people keep bringing up
is, let's say, messing with the issuance schedule, like the miners creating
coins for themselves.  This is a very old trope.  And what can the user do on
a network with no replay protection and with the blocks actually coming in
very slow?  Like, people who sat on the BIP110 chain saw that when the
majority of the hashrate is not mining your chain, then you are in a really
tough situation.

So, when all this happened and people were asking the questions, "What do you
do in such a case?" that's when I thought, well, the obvious answer should be
that we empower the users before this happens, right?  So, in case you have to
do this, then you have the tools, you are empowered to express your
preferences.  Now, obviously, there is a question about how to do this,
because pretty sure that any such rule that we would add could be used to
attempt to scam people.  Like, someone could make some P2P exchange, but they
commit to a hash that is not in the longest chain, and that transaction is
basically invalid, and they never pay you; but you sign your end, and that
becomes valid, and stuff like that.  So, it's very important if such a rule is
added that the interfaces people use should warn them of this situation.  Yes?

**Mark Erhardt**: Maybe let's explain a little bit what your idea is first
before we get into how it could be broken.

**Moonsettler**: Yeah, sorry.  So, my idea, I would like to stress that this
was just an example, so I'm not saying this is how it should look like.
Obviously, there are multiple ways to do this technically.  But the idea is
that you can commit to a previous blockhash.  So, that is the gist of the
idea, that if that previous blockhash changes, your transaction is invalid.
This is the thing that I thought that empowers people to make an economic
decision and express their preferences in a safe way.  And normally,
transactions do not commit to previous blockhashes.  And this is normally a
feature, by the way, because the way Bitcoin reaches any sort of finality, or
the way it tries to not solve the Byzantine General Problem, but I like to say
it actually proves that it does not need to solve the Byzantine General
Problem, is we allow reorgs.  That is a basic fact of Bitcoin that we allow
reorgs.  And normally, we want transactions to be includable in any reorg.
But again, a chain split, a fork war, is a very different situation.

**Mark Erhardt**: Right.  For example, now in the situation where BIP110 was
forking off, I think they found eight blocks in the past three weeks.  And
here, they could, for example, commit to the first block after the chain split
that is only present on their own chain, so the first block that was signaling
for BIP110 activation that was not in the best chain for the rest of the
Bitcoin Network.  And that way, if they send a transaction, they want to only
confirm on the BIP110 chain tip; they would be able to force the transaction
to only be valid there by committing to this branch of the blockchain.  And
then, even while Bitcoin had 3,000 blocks more meanwhile, they would not be
able to mine that transaction into their chain.  And that way, you would be
able to split your coins between Bitcoin and the BIP110 chain tip effectively.

**Moonsettler**: Yes.  So, the main issue that people were warning against is
actually, that you are trying to sell your coins on the BIP110 chain, and the
same transaction would be replayed on the longer chain, the heavier chain, the
more work chain, let's call it 'legacy chain' in this case.  But I think the
more interesting question is really when the situation is more dire.  Like, in
a case when we are not the hash majority, this is a much more interesting
case, because at that point it can be a literal life-or-death situation for
what we believe Bitcoin is and how we fight for that, how we express that.
But anyhow, my idea was that we add a commitment to a previous blockhash in
the taproot annex.  This is pretty economic, pretty cheap, and the taproot
signatures already commit to the annex.  So, it would be one use of the
taproot annex, because we have not really figured out what we want to use it
for.  But there are ideas and there are proposals about how to structure it.
And I don't actually insist on it, it just sounded funny in my head, to
<0xFAF0>, Fork Around and Find Out, should be the graphics and then we include
the previous blockhash.  Obviously, you don't have to include the whole hash.
You can include the block height and you can include the partial hash.  There
are all kinds of trade-offs and possible solutions, and I don't have a strong
opinion.  Like, whatever technical committee agrees is fine by me.  I really
just want the users empowered.  I want us to be able to safely express
something like, "I'm selling these coins.  I'm not interested in this network.
Whatever this is, I don't want any of this and I'm selling".

**Mark Erhardt**: I think what Moonsettler is getting at here is one of the
most important points about such a fork situation that was very frequently
misrepresented in the last few months.  The user base can express a preference
for one of the two sides of a fork only by their economic actions.  And the
economic action in this case would be to buy one side and to sell the other
side.  If a large portion of the user base, the economic actors in the
network, express a strong preference, this would devalue one of the fork sides
and force the hashrate to mine the other one for profit.  Otherwise, they
would be mining a chain tip that is less valued but costs the same energy to
produce blocks for, and thereby the user base as a group can express the
preference.  One of the things people pointed out was that even though many
people had offered to make trades for future coins on one or the other side,
there was very little economic demand for one of the sides, and the people
that understood this situation used this as a predictor for which side would
succeed of this fork.  And now, one of the problems was, I blogged about this
a few weeks ago too, that you weren't able to easily split your coins and then
move them separately on the two chain tips.

With Moon Settler's proposal, where you would be optionally able to put a
commit in your annex, you could sign a transaction that can only be used in
one of the two chain tips.  This would allow you to safely move your coins
into a trade or onto an exchange and not send both of your chains.  Otherwise,
when you make a transaction that spends a specific UTXO and it is valid for
both chain tips, because the UTXO still exists on both chain tips, both coins
would move, right?  And so, one thing that I see with this proposal is that
Bitcoin Core and Electrum, and maybe some other wallets, meanwhile use
something that is called anti-fee sniping, which uses a locktime and locks the
transaction to be only valid if included in the next block or later.  So, this
prevents attackers from remining the previous block to collect the fees.  The
idea is if ever the fees of transaction become the dominant part of the block
reward, it might become more attractive if there are very few transactions
waiting, to remine the previous block and take all the juicy waiting
transactions and all the transaction fees from the previous block, instead of
trying to build on the previous block and continue the blockchain.  And to
obfuscate how long transactions have been waiting to be mined, the anti-fee
sniping sometimes sets previous block heights as the locktime.  So, for
example, if you committed to a block that is only two blocks previous, and
your anti-fee sniping says your transaction was created 100 blocks ago, that
would be a little funny.

So, implementing this might have a few edge cases where you have to think
about it a little further.  But as an option, having this universal opt-in
replay protection would make it much easier for the economic actors in the
network to express their preference for different forks if it were adopted.

**Moonsettler**: Yes, thank you.  That was a very good summary of the idea.  I
think the most important thing is really that if people are not empowered to
make such a decision, then we are going to see this whole narrative, I don't
know what to call it, 'perversion', that the miners run the network and they
decide what the rules are and stuff like that all over again.  And again,
future forks can actually be really hostile.  I don't consider BIP110 a
hostile fork attempt, but the no replay protection was certainly a bit hostile
in my evaluation.

**Mark Erhardt**: Actually, I think they finally had an opt-in replay
protection in their fork, so there is some way of signing differently.  And if
you use the new type of signing, it will only be valid for the new BIP110 hard
fork chain tip.  But, well, to be fair, it only started with the hard fork.

**Moonsettler**: Yes.  And the other thing I wanted to add is you can actually
just use the fees.  Like, you can say, "I'm paying these fees", let's say I'm
paying a million sats of fees, and let's say there is not a rule change for
just someone who is trying to execute like a deep reorg, I can say, "I'm
paying this million sats' fees on the currently longest chain, and the one
that is trying to catch up is not getting that, no matter what they do".  So,
I think it empowers the users in multiple ways, but we probably should think
about the adversarial side of this, like it always pay to take into account
how scammers might try to take advantage of the new rule.  And that's all I
wanted to start as a discussion really.  So, it's less of a concrete proposal
that this is how we should do it, and more like we should really, really think
about this, because it would be very empowering to the users if we had
something like this.  And anyone that attempts a hostile fork basically cannot
circumvent such a rule if it exists on our fork or the legacy fork.  So, as
long as one of the chains enforces this rule set, we can safely split the
coins and express our economic preferences.

The other thing I wanted to say is ancestrally splitting the coins is really,
really difficult.  So, there is this lock in.  The miners are unable to move
their UTXO, their newly minted coinbase UTXO, for 100 blocks.  And we have
seen how slowly the BIP110 blocks came and how excruciating it may have been
to the people who were there and tried to figure out how to talk to the
miners, let's say, even with fees or whatever else.  So, that was another
thing that I thought of, that we should really have something like this just
in case.

**Mark Erhardt**: Right.  In this case, there were two interesting aspects.
So, because one chain tip was moving so much faster, one way you could split
your UTXOs was to pay a low-feerate transaction that would get mined on the
Bitcoin side because the feerates were very low, but it would get ignored by
the BIP110 side because the feerates had accumulated by them having eight
blocks in over three weeks.  There were hundreds of blocks of transactions
waiting, and I think feerates went up over 12 sats/vB.  So, you could mine a
low-feerate transaction on one chain tip, and then create a second transaction
with a high feerate that would be eligible to be included in the BIP110 chain
tip eventually, and would be a lot more attractive than the low-feerate
transaction that you had on the Bitcoin side.  So, there were some ways to
work around it, but especially what you usually rely on, which is the miner
outputs that coinbase transactions can only exist on one chain tip, because
obviously the coinbase is different when someone else mines a block.  So, any
transaction that either spends a coinbase output or derives from a spent
coinbase output is inherently unique to that chain tip.  So, there are some
ways to do it, but this universal replay protection that Moonsettler suggests
sounds like a very easy way for users to get in on this.

I would now be curious, Moonsettler, you said that there were maybe some
scenarios or ways in which scammers could use this annex commitment to a
specific blockhash.  Could you maybe touch on some ideas you had how it could
be misused to confuse people?

**Moonsettler**: Okay, before that, so one second.  So, the idea that you can
ancestrally split even just a single UTXO, and then you can involve that in,
like, large coinjoins have been brought up, that if you have one UTXO, so that
you can make it easier for others to participate.  But this usually is highly
interactive and forces people into abandoning their current security setup.
Like, someone has relied on a security setup for years, certain hardware and
software configuration that he uses.  And every time that you need to
coordinate with other people and you need to step out of your comfort zone,
that is a huge deterrent from participating in this.  Like, this is just risk,
risk, risk.  And even relying on feerates is not as concrete as something
enforced by consensus and something as deliberate as picking a block and
saying, "My transaction is only valid on a chain that includes this block".
That's all I wanted to say about this.  I think it's a huge upgrade in
security and it being noninteractive, and that is empowering to people.

So, ways this can turn out to be problematic is two things came into mind.
One is people including performative commitments in every transaction, like
commitments to the segwit of the activation block, or whatever they like.  And
after a while, every UTXO will have some form of commitment, and we are just
getting a UI clutter in trying to track all the ways that transactions
ancestrally commit to block heights.  So, instead of using it when the need
arises and for its intended purpose, people can use it for silly reasons.  And
also, people could, like I mentioned, craft transactions that are either not
going to be valid or they have good reason to assume that it's not going to be
valid in retrospect.  Like, shallow reorgs can be used with these commitments
to maybe scam people out of money.  So, for all these reasons, my belief is
that we should certainly empower people, but we should also provide them with
information.  So, if a UTXO that they receive has ancestral commitments, they
should be able to see this on the regular interfaces that they are using.
Because if they are blind to it, like, if they are using the current
interfaces, they are completely blind to these commitments, these
restrictions, then there might be situations where they lose money.  So, that
is possible.

**Mark Erhardt**: Right.  So, let's say this universal replay protection were
soft-forked in the future and you were running a light client or other
software that isn't upgraded to the soft fork yet, you could be in a situation
that someone offers you a transaction and you do not check the annex, and it's
actually invalid in your chain tip.  And thereby, you don't notice that the
payment they're offering you unconfirmed is not reliable.  It sounds like
things to consider might be that such commitments should have a minimum depth
of maybe six blocks or something, so that you cannot be subject to a shallow
reorg.  We haven't had a six-block reorg in 12 years.  So, a six-block, just
from the top of my head, sounds like a pretty decent minimum.  And the other
one would be that, what was the other one?  I was going to say another thing!
Anyway, if I think of it, I'll let you know.  But it sounds like an
interesting topic.

**Moonsettler**: Sorry, I actually don't like the idea that we have a minimum
height commitment or confirmation minimum, because this goes against user
empowerment in certain situations.  Like, when 90% of the hashrate is mining a
hard fork that we don't want, this can take an excruciating long time.  And
the earlier people can express, even with just fees, their preference.  Like,
let's say people are starting to pay 100 times the fees on one of the forks,
like they are not splitting coins or anything, they are just paying 100 times
the fees for those transactions.  That might be something that they can
immediately start doing.  And so, I don't really like the idea of minimum
commitment, but I do like the idea of empowerment and well-informed choice.
Users have to be able to make a well-informed choice.  That's kind of my take
on this, that I want them to see what they are doing.  And that requires
changes in the nodes aside from these new rules.  So, the new consensus rules
do not help people to see, again, these commitments can exist ancestrally.
So, you might receive a UTXO that has no such commitment, but its ancestor had
such a commitment.  And in that case, you are still exposed to this.  And
probably, my guess is the users are most interested in the shortest of these
commitment ranges.  Like, you are not interested in, let's say, a 1,000-deep
commitment.  You are interested in the commitment that is immediate ancestor
and two blocks away from you.  So, that's my guess.

Again, the more information the users can see, the better.  It might be a
problem that is not specific to bitcoiners, but anyone that tries to make a
P2P exchange with other assets.  And those software not recognizing this rule
might actually allow people to get scammed.  So, we have to consider these
things as well.  And from this perspective, maybe it helps if you require some
minimum commitment amount.  But again, watching that whole BIP110 situation,
at the moment it felt like a bad idea to me.  On the other hand, preventing
commitments too deep, like unreasonably deep, like 1,000, more than 1,000,
10,000-block-deep commitments is probably just basically spam.  Like it's not
practical, it's not for the intended purpose.  So, I was more in the in the
mindset of we should not allow people to make like commitments for no good
reason.  Really, that is basically just spam and cluttering everything.  In
fact, I think the valuable commitments are very close to the current chain
tip.  I think that that is the likely thing.  Or, of course, the most likely
thing if there is a chain split is an immediate block that follows the split,
right?  That's the most likely thing that people would commit to.  And that
might even be a few hundred blocks deep, in case the BIP110 fork, or now maybe
a few thousand.  I did not count how much, but a lot of time has passed and we
are going on.  So, it's a hard thing to say, yeah.

**Mark Erhardt**: Right, but when you want to commit to one side of a fork,
you can also move up the commitment, right?  When you commit to a successor of
a specific block, you also explicitly commit to its ancestors.  So, if, for
example, the limit were that you can't bury it more than 250 blocks, you could
still go to the block that is 200 from the chain tip in the current Bitcoin
chain tip.

**Moonsettler**: Yes.  Sorry, such a rule does not take away from the utility,
but I think people would symbolically want to commit to those two blocks.
Like, that's the instinct that everyone is committing to one block that they
really want for a chain.  And that makes it easier for people to communicate
about things and verify things.

**Mark Erhardt**: Right, because it's the same hash every transaction, yeah.

**Moonsettler**: Yes, I don't think I have much to say if you have questions.

**Mark Erhardt**: Yeah, I remember the other thing that I mentioned.  You were
worried about performative or spam commitments in the annex.  The annex is, of
course, subject to the witness data discount, and thereby a commitment of 34
bytes or even smaller than that would be extremely cheap.  So, maybe such a
commitment should be actually bigger.  And because once such a transaction is
mined, other transactions can build on top of it, it might be fine if such a
commitment were fairly expensive, because it gives a point for people to split
out and spread out such replay protection.  Once any transaction is unique to
one chain tip, you could take an output from that transaction, splinter it in
hundreds of coins, send it to people that, for example, pay for a replay
protection.  And they can then put that into their input set of a transaction
in order to get the replay protection.

**Moonsettler**: Yes, excellent point.  So, if we are trying to keep spamming
this extra chain state annotation, because in my head we would annotate the
chain stain with the closest ancestral commitment of every UTXO; if you want
to decrease the spamminess of this commitment state, then it might be a very
good idea to make the commitments relatively expensive as to not be too
trivial, but still absolutely useful.  And again, it's a feature if it's
recognizable, I believe.  Like if you can recognize the hash of a specific
hash that is meaningful to you and you can recognize it in every UTXO, let's
say, that you receive, I think that's a feature.  So, I like the idea.

**Mike Schmidt**: Moon, thanks for joining us to talk about this today.  We
appreciate you hanging on in the newsletter to be able to opine on this.

**Moonsettler**: Thank you very much.

_HWI repository to enter maintenance mode_

**Mike Schmidt**: Cheers.  We have one more News item this week with no guest,
"HWI repository to enter maintenance mode".  So, this is maybe a quiet end of
an era here, because Ava Chow has announced that the HWI (Hardware Wallet
Interface) repository and tool that lets Bitcoin Core and other software talk
to hardware signing devices, is going to plan to scale back to
maintenance-only work and will eventually be archived.  Murch, I think you may
have some additional insights here.

**Mark Erhardt**: Yeah, basically, while the HWI was developed under the
umbrella of the Bitcoin Core org, it had been essentially a solo developer
project.  And recently, or actually for a couple of years, Ava has been
mentioning that it was one of the projects she was looking for a successor
for, either someone that took over the maintenance of the repository or a
different project taking over this work.  So, one of the reasons why this
never got fully folded into Bitcoin Core was that Python makes it very
difficult to make the project reproducible.  And now, recently, the
Wizardsardine team has been working on BHWI, which is the Bitcoin Hardware
Wallet Interface, which is a project that is open source, but developed by the
Wizardsardine team that also produces the Liana wallet.  And this seems to be
getting close to feature parity.  There are also some other open-source
contributors that work on BHWI.  So, Eva indicated that she would be finishing
the MuSig2 support in HWI, and after that point would enter maintenance mode,
where only small updates would be made to keep the continuous integration
happy.  And otherwise, HWI would not be further developed.

So, hopefully, this helps give BHWI even more support and attention.  And
perhaps because it is written in Rust, it would be easier to make that
reproducible.  And, well, I can't speak for the Bitcoin Core project
obviously, but if it got broadly adopted by the ecosystem, potentially it
would also be released either in tandem or compatible with Bitcoin Core, or
even in Bitcoin Core eventually.  So, yeah, I guess I hope that hardware
wallet, hardware signer developers, and people that are interested in wallet
development and this interface between hardware signers and wallet software,
pay attention and maybe allocate some of their development resources in a way
that helps move forward.

**Mike Schmidt**: So, it sounds like perhaps three different factors.  We
noted, I guess, each of them in the newsletter, which is the lack of
reproducibility; the fact that Ava was basically the sole developer on the
repository; and then, I guess, slightly tangential but related, is the fact
that there is this alternate library that also appears to have some energy
around it in Rust with Wizardsardine.  You mentioned there's some external
contributors as well.  We covered two HWI PRs, I think, last week, and I think
we have two more in the code section this week.  So, the project is still
continuing to make some changes, but I guess listeners should be aware of this
potential end state or maintenance mode for the project.  All right.  That
wraps up Alerts and the News, and we can move to Releases and release
candidates.  Gustavo?

_BTCPay Server 2.4.3_

**Gustavo Flores Echaiz**: Yes, thank you, guys.  So, this week, we have two
releases.  The first one comes from the BTCPay Server repo.  So, this is a
security release 2.4.3, which doesn't share any details on what the fix is or
what the issue was.  It simply says that users that have servers that are
shared by many users are very recommended to update, okay?  So, that is the
only advisory here.  You should all update, but mainly if your server is being
shared with multiple users.

_Eclair 0.14.2_

The next one is the Eclair release v0.14.2.  So, this one has multiple bug
fixes, which we've been discussing in the past two previous newsletters.  For
example, in the Newsletter #419, we covered on-the-fly funding issues.  So,
this is a specific feature that is used by ACINQ's Lightning Service Provider
(LSP).  So, the company behind the development of Eclair uses an LSP for the
Phoenix wallet and offers a service with the on-the-fly funding or
Just-in-Time (JIT) channels.  So, a lot of issues related to that were fixed
and were included in this release.  Also, as we discussed last week, limiting
the resources consumed by the channel announcement, by the gossip protocol, is
also part of this release, and other bug fixes as well.  Additionally, we're
going to cover later, in the next section, some new features that were also
included, such as adding support for fulfillment payload, which is a type of
message for attribution data; we're going to get to that in a second.  And
also, being able to advertise that we are only receiving or forwarding onion
messages from peers with whom we have channels.  That is also now part of the
BOLTs spec, and that is also included in this release.  So, mainly bug fixes,
but two major features too.

Also, one advisory included in this release is that you should no longer run
Eclair and Bitcoin Core on separate machines without a secure tunnel.  So,
users are explicitly advised to either run Bitcoin Core and Eclair on the same
machine, or use a secure tunnel between, if you're running Bitcoin Core on a
remote machine.  So, those are the two releases of this week and now we get to
the Notable code and documentation changes.  The first item, #34075, we
covered it at the beginning of this episode, which is the incorporation of a
mempool-based feerate estimator next to the existing block-policy estimator.
So, at the beginning, I think we kind of did an enough deep dive on that
feature.  But the item is there and the PR description is quite complete.  So,
if you ever had any extra questions, you could find all the details there.

_Bitcoin Core #35730_

The next item, Bitcoin Core #35730, this is about a new config option, called
-rpcmaxconnections, which defaults to 16 and defines the number of clients
that can, at the same time, connect to Bitcoin Core's HTTP server, which by
the way, in Newsletter #411, we covered how the previous HTTP server, which
was dependent on a libevent, one of the last remaining external dependencies
of Bitcoin Core, that was replaced by a new HTTP server that doesn't have any
external dependencies.  So, with that change in mind, the previous
implementation had limitations that couldn't allow it to develop this new
feature that this newsletter covers.  So, this new config option about having
a default max connections of clients that can connect to the HTTP server is
mainly motivated because previously, having no cap on the number of
connections could lead to those connections exhausting the resources of the
machine Bitcoin Core was running on.  And that could cause other unrelated
operations, such as disk operations, to fail.  So, the main motivation is
around capping the resources consumed by external clients that connect to the
HTTP server.

Side effect is also a performance boost, in the sense that if multiple
external clients connect to the HTTP server, the connection requests used to
be processed one by one, and now more than one connection can be processed per
iteration.

_Bitcoin Core #35580_

The next item, #35580, here, there's a bug that is fixed.  When constructing a
block template, Bitcoin Core could incorrectly check for the transaction's
chunk's sigops-adjusted weight, which is not the same as the BIP141-defined
weight.  Instead, it also takes into account the cost of the sigops of the
transaction, and it can determine a higher weight than the actual BIP141
weight.  Yes?

**Mike Schmidt**: I should have called out before, but this is also Abubakar's
PR.  Maybe he also wants to comment on it?

**Abubakar Sadiq Ismail**: I am here.

**Mike Schmidt**: How did Gustavo do so far?

**Abubakar Sadiq Ismail**: He's doing great!  Yeah, this is part of a series
of fixes that I am currently trying to do for the block assembler, where right
now it's impossible to generate a fully-built block template because of some
bugs.  So, in the PR, there is an attached issue that describes three issues
that will prevent creating a full block template in Bitcoin Core.  And this PR
fixes one of them, which is during block assembly, we select chunks from the
mempool and add them to the block template.  And we have an accumulator of the
weight of the selected chunks.  And while we are selecting, we test that a
particular chunk in the mempool will fit into the block template or not.  So,
there is a mistake in that function that performs that check.  But instead of
adding the accumulated weight of the chunk-to-be-added chunk weight, we
accumulate it with the adjusted weight, which may be higher than the chunk
actual weight, because the sigops-adjusted weight is the maximum of the chunk
weight and the sigop cost of the transaction.

So, there is a scenario where you may skip some chunk instead of adding it by
assuming that you will exceed the weight budget while that is false.  So, that
has two issues.  It may make you not fill a block template; it may also make
miners lose fee revenue, because the chunk that you skip has a higher fee than
the subsequent one.  So, this is a minor bug fix to the block assembly that
changes the accumulator to add the actual chunk weight instead of the
sigops-adjusted weight.  So, I plan to incorporate the other fixes, and with
that, we will be able to create a full block template, potentially.

**Mark Erhardt**: Yeah, one of the problems here is that the sigops-adjusted
limit is only enforced at the full block level.  So, when you have a
transaction that has a very high sigop load, you don't have to enforce it at
the transaction level.  So, really what you want is only one dimension by
which the block weight is measured, which we succeeded at comparing with the
witness discount being calculated, so that the weight is backwards- and
forwards-compatible to the size, but not for the sigops.  It's kind of weird
for the sigops, where we enforce it at the block level, but not at the
transaction level.  And then, I think in taproot, we actually enforce it at
the transaction level, rather than just the block level.

_Bitcoin Core #35665, #36025, and #35516_

**Gustavo Flores Echaiz**: Thank you, Abubakar and Murch for that extra
context.  So, moving on to the next item, we have three PRs in one item:
#35665, #36025, and #35516.  So, all of them fix several issues when combining
or joining PSBTs.  So, you can read the item for the exact reason why they
happen, but I think the important point is when do they happen.  So, for
example, the first PR fixes a bug that occurs when you are combining two
different PSBTs, let's say you and a cosigner, but the PSBTs disagree on the
key origin of an xpub in the metadata part of the PSBTv2.  So, for example,
your PSBT says that the fingerprint and the derivation path of the xpub is
different than what your cosigner says.  So, what Bitcoin Core would do here
is that it would simply add both keys, so keep the same xpub, but with
different origins, and that would then create an invalid PSBT that decodepsbt
RPC rejects.  And the reason why it was doing that is because it was grouping
records by key origin, so it was missing that the xpubs were duplicate,
because it was grouping them by key origin rather than grouping them by xpub,
which is the right way to do it.  So, that was the basic bug and the fix.
However, this bug is very theoretical because it's very unlikely this
situation happens.  The xpub has one origin, and you and your cosigner having
two different origins for the same extended public key is just an unlikely
scenario.

The second PR fixes a very similar issue when it comes to tapscript records,
particularly when there's a control block, which is what commits the tapscript
to the transaction.  So, the same thing could happen.  The same tapscript
could point to different control blocks on you and your cosigner's PSBT file,
and the same thing could occur here; both scripts would get duplicated and it
would also trigger an invalid PSBT edge case.  That is also a scenario that is
malformed or inconsistent metadata, not really something you could run into.
But however, the second PR also has another case where the same tapscript has
multiple valid control blocks.  So, you could also run in the same issue, but
this is actually protocol-valid, because imagine you have a tapscript, but
just in different locations.  So, for example, one scriptpath has the same
script as another scriptpath, but it doesn't really resolve to the same
control block because they have a different merkle position.  So, here, once
again, you could get an invalid PSBT because it was processed incorrectly in
this specific edge scenario, which is protocol-valid, but very, very niche.

The last PR is a more real-world example.  When you are combining two PSBTs
with the joinpsbts RPC, for example if you're in a coinjoin or a payjoin
transaction, joinpsbts will shuffle the inputs and the outputs, but instead of
combining both PSBTs, it would construct a separate PSBT file that would drop
some global metadata, specifically the global xpub record and other
proprietary fields.  So, this was more likely to run into, and this is also
solved by instead of creating a new separate PSBT that drops the records,
you're just keeping one of the PSBTs that you're joining and that retains the
metadata records.

_Bitcoin Core #35933 and #34697_

So, the next item, very similar in some ways, is related to MuSig2 PSBT PRs
#35933 and #34697.  So, here, the first one is if you have a hardened public
derivation on a MuSig aggregate key, which doesn't really make sense because a
MuSig aggregate key doesn't have a private corresponding key, then before, the
process would simply abort.  Now, it will detect that it's trying to derive
from an aggregate key with hardened derivation, so it doesn't really make
sense.  So, it will just fail normally instead of aborting the process.  Also,
if Bitcoin Core, when processing a MuSig to PSBT, was trying to match with the
wrong aggregate key and it wouldn't derive properly, it would also abort the
process.  Now, it will simply skip the mismatch key and try to find another
key that actually derives correctly.

The second PR, well, it improves the detection of duplicate keys in
descriptors.  So, for example, if you have the same xpub that you're using for
two separate keys, and a MuSig2 PSBT, but they have different derivations,
you're not exactly duplicating the keys.  But Bitcoin Core could interpret it
as such if one of them was using hardened derivation; it wasn't properly
trying to derive the key with the private key information that it would have.
So, it would just simply run into a situation where it wouldn't be able to
derive from a hardened derivation path and it would just believe that both
keys were the same, and it would hit the scenario where they would be falsely
treated as duplicates.  So now, Bitcoin Core, if possible, uses the private
key information when comparing key expressions, and when one of them or many
of them require hardened derivation.  So, it doesn't falsely treat keys as
duplicates as it was doing before.

_Core Lightning #9374_

Now, we've completed the Bitcoin Core repo and now we're jumping into the LN
implementations.  So, the next item comes from Core Lightning #9374.  This is
a similar bug that we covered in Newsletter #418 on Eclair, where when making
multiple RBF attempts on a dual-funded channel funding transaction, CLN would
expect the last RBF attempt to be the one to confirm, similar to what Eclair
was also doing on its own bug.  However, a previous attempt can always
confirm.  So now, CLN properly records the funding attempt and actually
confirms, instead of assuming that it's going to be the last attempt that
confirms.  And this was specifically occurring when a peer was reconnecting
while CLN was still syncing with the blockchain.  That's when CLN could assume
that it was the latest RBF attempt that confirmed and log the channel to an
unconfirmed funding transaction, instead of actually looking for the one that
actually confirmed, even if it was a previous RBF attempt.

_Eclair #3342_

The next two items are from the Eclair repo.  So, those are the features that
I was mentioning that were part of the latest release.  So, the first one is
Eclair implementing what's called option_onion_message_only_channels, which is
a feature bit that we covered in Newsletter #416, when the BOLTs spec added
this new feature, which basically allows a node to advertise to the network
that it will only accept onion messages that come from channel peers.  As
we've discussed before, there's a lot of difficulty in handling onion messages
and managing resources around onion messages.  So, some nodes simply prefer to
only accept these onion messages from channel peers.  So, now it's part of the
BOLTs spec, and Eclair implements it in this new item in PR #3342.  So, any
Eclair user can now use this option and advertise to their peers that they
either do that; or, on the opposite, they can decide not to implement it and
advertise to the network nodes that they will accept an onion message that is
not necessarily from a peer.

_Eclair #3321_

And then, the next item #3321, this one implements support for the
fulfillment_payload field added to the update_fulfill_htlc message.  So, we
talked also about this in Newsletter #416, because those two items were added
to the BOLTs spec together.  So, in BOLT's #1344, we covered that the
attributable failures protocol was extended to successful payments.  So, when
you make a successful payment, the receiver sends back to the sender a message
that can now include a payload for the attributable failures protocol.  That
is the fulfillment_payload.  However, this payload is defined, but no specific
application or message inside that payload is yet defined.  So, Eclair
implements relaying those payloads and authenticating them as part of the
attribution data, but does not yet originate them or actually implement a
specific application.  And that is the case also for the BOLTs repository.
What's cool about this is that LDK has also implemented this feature way
before it was actually added to the BOLTs repo.  So now, Eclair and LDK nodes
are both compatible on using this new feature, that we should probably expect
more details in the BOLTs repo over specific applications on how to use it
eventually.  But in general, this is just an extension of the attributable
failures protocol to successful payments.

_LND #11008_

The next item, the LND repo now, #11008.  So, here there was another bug in
LND where, if at the same time you were receiving a PSBT from a channel
co-funder and you were verifying that PSBT for a funding opening transaction
of a channel, but meanwhile you were also at the same time canceling a channel
reservation, so not exactly closing a channel but you were going open a
channel and now you're canceling that channel reservation, well if you did
both of those actions at the same time, your LND node single reservation
handler could kind of get stuck and prevent your node from opening or
accepting channels, or even leaving newly-funded channels stuck until you
restarted your node.  Some users even reported spending dozens of hours in
this state, where they were just stuck and unable to open or accept new
channels or process newly-funded channels.  So, the fix is that both of these
operations are no longer depending on each other and they will not block each
other independently.

_HWI #841_

The next two items are from the HWI repo, as we discussed earlier in this
episode, that it's going to enter maintenance mode.  Well, before it does, it
has shipped two new features.  The first one, #841, this is a follow up to
what we covered last week in PR #842, which added the registerdescriptor
command for registering a descriptor on a hardware signing device.  So, once
you as a user, you've registered wallet descriptor policy on your hardware
device, the display address command is extended to match that use case.  So,
for example, you have your hardware signing device, you use a software wallet
that uses HWI to connect to your signing device, you register a descriptor on
the signing device, that was what we covered last week.  And now, your
software wallet can basically instruct with HWI to display an address on your
hardware signing device that matches the descriptor that you registered in
your hardware signing device.  And your hardware signing device will be the
one making sure that the address being derived matches the descriptor policy
when getting struck to a specific address index and receive or change branch.

_HWI #849_

The next item is an update, PR #849, updates the support for COLDCARD devices,
specifically for COLDCARD edge devices, which is an experimental firmware for
COLDCARD devices.  So, the main feature being added here is that
single-signature taproot addresses, HWI can now instruct COLDCARD to display a
single-signature taproot address with the display address command.  So, the
COLDCARD device does have its own address explorer feature, but that is
independent of the software wallet and HWI.  So now, this is about HWI
instructing COLDCARD to display the same address that is being displayed on
the software wallet.  HWI instructs the COLDCARD signing device to also
display it.  There was also a bug with COLDCARD and HWIs, where the PSBTv2
format was always being converted to PSBTV0.  So now, that is fixed So it
preserves the PSBTv2 format instead of converting it unnecessarily.

_Rust Bitcoin #6755_

The last item in this newsletter and in this section is Rust Bitcoin PR #6755.
Here, what was happening is if Rust Bitcoin received, let's say, from a block
that it was verifying, if it included a transaction that was using a
non-standard sighash (signature hash) value, it could map that non-standard
sighash value to a standard sighash type, and that would you lose the original
value.  And then, when comparing the sighash value to the segwit v0 signature
hash, it would basically not be able to verify the signature because the value
had been overridden by a standard value.  So, there was a mismatch in the
transaction, and Rust Bitcoin could consider that this transaction was
invalid, even though it was consensus-valid and was probably already confirmed
and included in a block.  So now, Rust Bitcoin will preserve the original
value, even if it's a non-standard value, instead of overwriting it silently
with a standard value.  However, users can still require standard sighash
types.

There is a function for that, called from_standard, that we covered in
Newsletter #138.  So, a caller could also say, "I want you to override
non-standard values with standard values", or basically just say, "I will only
accept standard values".  So, there remains that feature for callers that want
specifically that behavior.  But unless you specify that, the non-standard
sighash value will no longer get overridden by a standard value, which could
create a transaction verification issue later.  So, that's the final item and
that completes the newsletter.

**Mike Schmidt**: Great, thank you Gustavo.  We also want to thank our guests
for today, Moonsettler, Níckolas, Optout, and Sadiq who's still on with us.
Thank you also, Murch, for co-hosting, and for all of our listeners for
listening.  We'll hear you next week.  Cheers.

{% include references.md %}
