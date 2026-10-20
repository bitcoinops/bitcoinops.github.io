---
title: 'Bitcoin Optech Newsletter #405 Recap Podcast'
permalink: /en/podcast/2026/05/19/
reference: /en/newsletters/2026/05/15/
name: 2026-05-19-recap
slug: 2026-05-19-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Fabian Jahr to discuss
[Newsletter #405]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-4-20/424526209-44100-2-652d4773db35f.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome to Bitcoin Optech Recap #405.  This week, we're
going to talk about a disclosure of a Bitcoin Core security vulnerability;
we also have a News item talking about a draft BIP for sharing the UTXO set
over the Bitcoin P2P network; we have a Core Lightning (CLN) RC; and we
have our weekly Notable code and documentation segment.  This week, it's
just Murch and I, and we are joined by one guest, Fabian.  Fabian, you
want to introduce yourself?

**Fabian Jahr**: Yes.  Hi, I'm Fabian, I work primarily on Bitcoin Core and
some Bitcoin protocol ideas, and yeah, I'm sponsored by Brink.

_BIP proposal for UTXO set sharing over P2P network_

**Mike Schmidt**: Thanks for joining us.  For our listeners, we're going to
just go slightly out of order.  We're going to do Fabian's item first,
which is titled, "BIP proposal for UTXO set sharing over P2P network".
Fabian, you posted to the Bitcoin-Dev mailing list about a draft BIP for
sharing the UTXO set using Bitcoin's P2P networking.  The goal, well maybe
you could talk a little bit about the goal, but the goal would appear to be
to improve the assumeUTXO feature by letting nodes receive the UTXO set
from peers, rather than having to go download torrents or going to maybe
some other websites.  Maybe you could talk a little bit about the status of
assumeUTXO, and how you think that this BIP could make assumeUTXO even
better, and how that relates to end users and the impact?

**Fabian Jahr**: Yeah, sure.  So, first of all, this idea of having a way
to share the UTXO set over P2P was basically part of the initial proposal
for assumeUTXO right from the start.  However, it was kind of deemed to be
a little bit out of scope for the first version of including assumeUTXO in
Bitcoin Core.  And so, that part was deferred.  And then overall, like
sometimes it happens, the assumeUTXO project took quite a long time, and by
the end, much the primary developer, James O'Beirne, left Bitcoin Core and
stopped mostly contributing to it.  So, it actually took quite a bit of
additional time to refactor the code a little bit, iron out some bugs, and
then it was actually made usable on mainnet.  There was a period where it
was only usable on testnet in between.  And since then, the assumeUTXO
feature is out there, it is usable.  It, I think, was not adopted as
quickly or as widely as I personally expected and some other people
expected, I think.  So, my personal go-to project that I think of basically
is these pre-packaged nodes, like an Umbrel, Start9, RaspiBlitz.  For those
to get started quickly, this is something that is very helpful, especially
if you have limits in terms of bandwidth or the hardware that you're working
with.  This allows you to just get started a lot more quickly, which is
typically something that users would like to see.  We always say patience is
a virtue in Bitcoin more or less, but a lot of people are not that patient,
either because they don't want to or because they actually have economic
incentives that cause this.

So, for example, Start9 has it implemented.  Many others have this out as a
feature request and see it as something that they would like to do, but they
just haven't gotten around to do it.  And part of that is the availability
problem.  You need to get this UTXO set dump from somewhere.  If you have a
full node, it's a simple RPC call that allows you to generate this.  On a
more or less modern computer, it takes something like 15 minutes or so to
generate this, and then there's several sources that allow you to download
it from some websites, and there are torrents available to get to it.
However, these are single sources that are somewhat trusted and especially,
if you just download a huge file from just any website where you don't know
who controls it, it could get away at any moment, it's kind of hard to
build on top of that.  And I think that contributed to the fact that this
feature isn't used as widely as it should be.

So, this has been on my extended to-do list for quite a long time, to
explore this and see what the protocol could look like to make it available
to get the UTXO set through the P2P network, like originally it was
envisioned; and this way, make it basically just as easy as have a startup
parameter for Bitcoin Core to get started with assumeUTXO.  That's
basically the outline and how it relates to assumeUTXO.  However, the
proposal itself, while assumeUTXO is the main motivation, it doesn't really
talk about assumeUTXO, so it's a little bit of a weird situation right now,
where I'm mostly facing feedback that is just feedback on the assumeUTXO
itself, and not so much the proposal that I've actually written up.

**Mike Schmidt**: How much data are we talking about?  What is a relatively
recent size of a UTXO snapshot?

**Fabian Jahr**: It's about 10 GB.

**Mike Schmidt**: Okay.  And so, this would involve, well, I guess there's
two approaches.  There's the approach that you outlined, but I think Antoine
Riard suggested maybe building on top of the peer feature negotiation, that
I believe AJ is working on.  So, how do you think about deployment in
either of those scenarios?

**Fabian Jahr**: Yeah, so this is one question which is an interesting
question to me, but it has kind of gone into the background almost because
of all this other conversation on the assumeUTXO.  So, right now, the BIP
includes a signal via service bit, and the nice part of this is that it
allows you to easier discover which nodes on the network actually have this
feature and connect to them, and then you can actually get it to them.  And
the alternative would be to build it on top of a BIP434, where you first
have to connect, and only then you discover that this node actually has this
feature enabled.  So, there's ups and downsides to it.  I think we're a
bit sparse of how we want to use service bits.  So, that's why I can
understand that there's a bit of a pushback on the usage of the service bit
for something that, I guess so far, not that many people are completely
convinced that we need it.  And BIP434 is definitely interesting.  So, I
would say I haven't made a final decision yet, and I'm definitely looking
for more feedback there.

But there's also a bit the question of, like, what's going to be the
availability guarantees of these UTXO sets?  So, for example, with the
assumeUTXO right now, we have these snapshots that we put into the binary,
but also there's the idea of a node could keep always, for example, just
the UTXO set from 1,000 blocks ago, or whatever, and always could have
that, something like that.  And that would be then ideally secured as well,
that this is one of the nodes that can provide this.  And this is something
where definitely, I think BIP434 would be ideal to show this.  If it's been
discovered that this is a node that has snapshots that it's serving, this
way it can then, after connecting, signal that it has these very recent ones
as well.  But I'm kind of proposing right now that this is not something
that I would specify in the current BIP draft, but rather I would put it
into an extension of the BIP.

**Mike Schmidt**: Now, I think we've talked so far about what I think you
intended to talk about on the mailing list, but you mentioned the discussion
has sort of spawned around assumeUTXO more generally.  Maybe we can get
into that.  What have people brought up in terms of assumeUTXO specifically,
as opposed to this particular proposal?

**Fabian Jahr**: Yeah, I think there are two broad categories, I would say.
So, first of all is about the trust model.  That's particularly something
that Eric Voskuil, for example, has brought up on every channel, but
particularly on the mailing list is where we have actually had a
conversation on it.  And his opinion is that assumeUTXO is trusted and
nodes should not use it basically, because whatever you want to do with your
node, it's not safe to basically rely on the trust model that assumeUTXO
has.  And his counterargument is that syncing IBD (Initial Block Download)
doesn't take that long.  I think his perspective is from a perspective of
having better hardware available, having very good bandwidth.  I think that
came out in his arguments.  And of course, Libbitcoin is very much optimized
for this kind of environment, where you have, for example, 32 GB RAM is
kind of the minimum that they assume, and US-level consumer internet
connection.  And so, for this scenario, it's of course then debatable if
you would still need it, if you can do IBD within a couple of hours.

But I think the reality is, and that's my counterargument, is that lots of
people in the world don't really have this availability of that many RAM, of
that internet connectivity.  And they still may want to get started faster,
especially if IBD takes one or two weeks for them on their hardware with the
bandwidth that they have available.  And in these cases, assumeUTXO can
help them a lot and they can get started quicker.  And this is also
something that is highly motivating for if you, for example, want to convert
a shop to run their own node.  And this is why, for example, BTCPay Server
is one of these projects that has even done their own assumeUTXO version.
Basically, they call it Fast Sync and it's been around even before
assumeUTXO, because in order to get a shop converted to run their own node
on a Raspberry Pi or so, you kind of have to give them an experience that is
similar to, I don't know, some block terminal, or whatever that you would
usually use.  It's just not so easy to tell them like, "Okay, you just have
to wait a couple of days and then it's ready, and then you come back to it".
So, this is the one string.

The other string is on the PR itself, so that's more of a Bitcoin-Core-
specific conversation where, this was kind of new to me, but a couple of
people really don't like assumeUTXO as part of the Bitcoin Core project.
They say that it's causing quite a bit of headaches, in terms of the work
that they are doing there.  And there's more of a general sentiment against
assumeUTXO, which then extends to, does this need to be added on top of it
into the repository?

**Mike Schmidt**: Is part of the latter objection related at all to this
proposal for SwiftSync that is being worked on, that could result, in I
guess I'll just say it, Libbitcoin-like IBD, aka just sort of faster and
thus obviating the need for assumeUTXO; or do you think the objections to
assumeUTXO are independent of that work?

**Fabian Jahr**: At least I haven't seen it come up in the conversation at
all so far, so it's not an explicit counterargument definitely.  And then,
I haven't really read up on the latest proposal, but from what I've seen in
terms of like a triplet of BIPs that are being proposed to basically fulfill
the promise of SwiftSync, and part of that proposal is sharing the undo data
over P2P.  And that would be a lot more data to share than would be the
UTXO set to share.  And it's also not something that can be validated if you
want to actually have this speed-up.  So, you have a lot of undo data that
is then sitting there.  You have to send it over the network, but you
haven't validated it.  But you may still use it for rolling back blocks, for
example.  And so, that to me doesn't really strike me as a great trade-off,
but I don't want to judge it.  I think it's still a very interesting idea
and I think there's also potentially ideas to combine it with assumeUTXO if
that were to get enough interest.  But yeah, I think especially the
counterargument, or many of the counterarguments that I've been hearing on
assumeUTXO or the proposal would also apply to this latest version or to
this triplet of the BIPs that I've seen, as far as I understand them.

For example, an argument I've also had a couple of times, although I would
say this is not one of the more forceful ones, is that there is an
additional requirement for downloading data.  So, if you have a problem
with syncing the 800 GB of data overall, then you add 10 GB to it on top.
"How is that an improvement?" was one of the critiques.  And then, this
undo data sharing, I think, would of course make this counterargument even
bigger.

**Mark Erhardt**: With SwiftSync, you still download the entire blockchain,
right?  You just process it more quickly, because you don't actually write
out the UTXO set while you're syncing.  So, actually, if the bandwidth
amount is a blocker for you, SwiftSync will not solve the problem.  But
with assumeUTXO, you would immediately have a usable node, even if it then
takes you weeks to download 800 GB in the background to actually sync
yourself up.  So, I think that you can actually make a stronger case here
that assumeUTXO is more compatible with low bandwidth than SwiftSync, if
you have a limit on how much you can download, rather than the speed.
Yeah, I would say I would characterize it as the SwiftSync still scales
quite a lot with the available bandwidth and with the hardware that you
have, and also, over time, it will necessarily still take longer because
there's more blocks to sync; whereas with assumeUTXO, you have, depending
on what kind of structure you use, but if you, for example, take this more
advanced BIP extension that would be possible, then you would max sync
something like 1,000 blocks or so, or you would sync 1,000 blocks, and then
you are basically ready to start with your assumeUTXO data set load.

**Mark Erhardt**: Right.  So, you would always basically onboard in
constant time, and then your security model would change over time as you
process the blockchain in the background.  Whereas with SwiftSync or
regular IBD, you would have to download and process the entire blockchain
first before you're up.

**Mike Schmidt**: What about this idea that I think I saw from Josie this
morning?  I think he said something like, "Hey, why not just put it in, or
have it downloadable as part of the executable, or download it from the
same place where you get your Bitcoin Core binary?  I think he said
something along those lines.  Do you have thoughts on that, other than it
being a very large download?

**Mark Erhardt**: I think it would be a very different server plan that
we'd need versus serving a 10-MB or 5-MB binary to serving, what is it now?
700, 800 GB of blockchain from a website.  So, maybe the torrent, magnet
but I think that's already available.  Maybe you can correct me on that,
Fabian.  But yeah, serving 800 GB of data from a website is a very
different proposal than just serving the binary.

**Fabian Jahr**: Yeah, torrent downloads are available certainly, and I
think some people use that.  And I'm not sure if many people want to install
the torrent client on the computer that they use as their node.  I think
that's the main issue I have with just saying, "Okay, we only rely on
this", or, "This is the recommended way to do it".  Having some Bitcoin Core
download site where you can get the UTXO set, I think a lot of people would
like that and they would probably accept it.  I'm not sure if Bitcoin Core
wants to do that and wants to carry that responsibility.  I think there's a
certain issue with privacy and with regards to having such a server, and
also servers are hackable.  You never really want to make very transparent
who has these keys.  So, there could also be malware hidden behind these
files.  That is just something where, yeah, the main motivation or one of
the main motivations for me to do this is that I think ideally, we would
not want to have this responsibility rest on one person's shoulders.  And
that's why I think it's not great.

But I think, yeah, if somebody wants to do this on Bitcoin Core, someone on
Bitcoin Core as a project wants to do that, I certainly don't want to
maintain that server.  But if somebody wants to do it, I think people would
like that and it would probably help this adoption.  There's other websites,
centralized websites from people that are more or less anonymous where you
can download them.

**Mark Erhardt**: So, just to clarify, currently as implemented, assumeUTXO
will only accept a UTXO set that commits to a specific hash to the UTXO
set?  So, even if some random party were to serve the UTXO set data, if it
doesn't match byte-for-byte with the expected data, you could at best waste
the downloader's bandwidth; they would not import it?  So, just to clarify
the trust assumptions there around the data that is being consumed.

**Fabian Jahr**: Yes, that's correct.

**Mike Schmidt**: Fabian, as we wrap up this item, maybe you can give the
audience some calls to action.  Obviously, there's the mailing list post,
there's the draft BIP that people could take a look at.  What else would
you encourage people to do, or feedback that you're looking for?

**Fabian Jahr**: Yeah, so the mailing list, the BIP and the Bitcoin Core
PRs are all open and I'm very much looking for feedback.  I think it will
be very much interesting to hear both if people like the idea of adding it,
or don't like the idea of adding it.  I think one question that was raised
where it's hard to actually give a clear answer is usage.  So, I think it
would both be interesting if people speak up that say, "Okay, this is
something that would be helpful, or would have been helpful for me when I
started my node", or, "I actually started my node with assumeUTXO", or, "I
recommend to other users to start a node with assumeUTXO because of these
circumstances that we're living under".  So, that, I think is something
that, because Bitcoin Core doesn't track any usage and the assumeUTXO is
not on the P2P network yet, so we cannot really see nodes offering it or
using it, that's a question that is very hard to answer and where people
have raised doubt about the usage.  And so, that would be interesting to
hear.

Otherwise, we didn't really talk much about the content of the proposal,
but I think it's a comparatively simple BIP.  Honestly, I was a bit
surprised of how simple it was when I wrote it.  That was also part of the
motivation for me to do something where there's new message types being
defined, something that I hadn't done before.  And so, if you want to read
something that is a BIP with new message types, but it's still a quick
read, I think it's like 250 lines, I think that's something that is
interesting to review.  The core PR as well, even if there's quite a lot of
conceptual questions being raised about it right now, it's a very
self-contained piece of code.  So, if you are interested in reviewing
something like that, that's also I think interesting to check out for people
that are interested.

**Mike Schmidt**: Fabian, thanks for joining us.  We appreciate your time.
You're free to drop.

**Fabian Jahr**: Thank you very much.  Cheers.

_Bitcoin Core script interpreter remote crash disclosure_

**Mike Schmidt**: We'll jump back up in the newsletter to the first News
item titled, "Bitcoin Core script interpreter remote crash disclosure".  And
there was a post to the Bitcoin-Dev mailing list by Niklas, announcing the
responsible disclosure of CVE-2024-52911, which is a vulnerability affecting
Bitcoin Core versions 0.14 to 29 and before 29.0, so after 14 and before
29.  Murch and I are going to riff a little bit on this bug.  We don't have
Niklas or Cory who was the one who discovered and disclosed it here, so
we'll try to explain it for you all.  But the bug is essentially when
Bitcoin Core is validating a block, it speeds things up by doing multiple
script checks in parallel using background threads.  And in order to do
that efficiently, it pre-computes some data related to the transaction, and
then shares it across those different threads that it's spawned.  And then,
the vulnerability was that that shared pre-computed data could be cleaned up
and freed from memory before all of those threads, who may be using that
data, had actually finished using it.  And then, the effect is for a
specially crafted block that could cause a background thread to try to read
memory where it thought that that data was, and it had actually already been
released.  And this is known in computer science as a use-after-free bug.

I'll pause there to get some input from Murch, and then there's a few
different things we can talk about based on this.

**Mark Erhardt**: Yeah, so so far, I fully agree.  The important caveats
here for this bug were that it required an invalid block to be constructed.
So, the block would not be accepted by the network.  It required the proof
of work to be valid in order to get to the point where this bug would be
triggered.  So, what made the block invalid, I think, had to be in a very
specific script check.  Then theoretically, because the data would get read
after it was released, you would be able to craft this invalid block, and
then put in that very specific spot that would be read by a script after it
was freed, a remote execution code.  But that, I think, would have had to
pass as valid transactions or at least well-formed transactions before.  So,
the likelihood that that could actually be used in that way was considered
low, but you could definitely crash a node that encountered that, if you
constructed a block specifically to do so.  And you had to spend the proof
of work for a valid block.

**Mike Schmidt**: Yes, so instead of crafting a valid block, you create one
essentially to crash other nodes, would be the point.  And so, I suppose if
I were an attacker and I knew about this and I wanted to do this, I would,
I guess, connect to as many nodes as possible, including maybe well-known
mining related nodes, waste my proof of work on an invalid block such that
I take down a large -- because obviously, those blocks aren't going to
propagate on their own, especially because the nodes are going to crash.
So, I need to have connections to all these people to send them these
blocks, right?  And then, I send out these blocks, a huge percentage of the
network goes down.  Maybe I'm a minor and my competitors go down, and now I
maybe have some time while they're getting their operations back to mine
freely.  Is that sort of the idea?

**Mark Erhardt**: I think because blocks are forwarded before they're
processed complete.  Well, actually the transaction itself would be invalid,
right, so it would probably not be eligible for compact block really.  So,
yes, you would have to probably serve the block directly to all the nodes
you want to crash, because they crash when they process it and wouldn't
forward it directly, because they only forward blocks for which they have
all transactions.  So, yeah, this was classified as a high severity bug.
The disclosure policy of Bitcoin Core is such that they distinguish four
different levels of vulnerabilities.  Low severity is disclosed two weeks
after the first fix is released in a major version, and medium and high are
disclosed two weeks after the last affected version goes end of life.  That
was the case here.  This high-severity vulnerability was disclosed two weeks
after v28 went end of life with the release of 31.  Bitcoin Core always
maintains the last three major versions.  28.x was up for end of life when
31.0 was released.

For critical, the fourth class of vulnerabilities, the process is ad hoc,
they are more severe, and usually require specific handling, either
immediate disclosure for people to update, or later disclosure because they
might affect other networks too.  So, anyway, yeah, that was disclosed
because 28.x is end of life.  And the point of these disclosures is (a)
that people should be aware that software has bugs and we want to dispel
the illusion that software is flawless, that Bitcoin Core is flawless, and
(b) it allows everyone to learn from the bugs and it incentivizes
responsible disclosures by the people that disclose the bugs getting credit
for it.  Did you have more on this?

**Mike Schmidt**: Yeah, I wanted to just maybe articulate the timeline and
weave that into what you've sort of outlined here.  November 2nd, 2024, the
bug is reported privately, I assume on the security mailing list that
anybody can disclose a bug to.  Within a couple of days, there was a fix
opened in a PR, and less than a month later, that PR was merged.  Based on
Bitcoin Core's release cycle, that December merged PR didn't make it into a
released version until Bitcoin Core version 29, which was in April of 2025.
And then, when the last vulnerable version went end of life, that was April
of this year, and then within a couple of weeks, the public disclosure was
made, which was basically a week and change ago.  And so, when I'm looking
at that timeline, it seems like everything was kind of done almost as soon
as it could have been done.  There was a couple of days and then there was
a fix, and then a month later, it merged.  It went into the release that was
upcoming and it was disclosed right after that version went end of life.

So, I see some people talking on social media about how there's some
conspiracy here or they've known about this for 18 months, or whatever the
figures are.  I guess the criticism can't be in the way that this specific
bug was handled, and it would have to go towards, "Hey, the disclosure
policy should change", or, "Bitcoin Core should somehow support more
versions than just the last two".  And that's where I guess criticism could
be directed, although there's of course objections to changing those as
well.  Does it make sense, Murch?

**Mark Erhardt**: Yeah, maybe just on the release schedule, again, people
have been claiming, "Oh, there's faster releases in Bitcoin Core now", or,
"The disclosures are trying to make people update".  I think there is an
element here that is definitely, the public is informed so that they can
use this information to make their decision whether or not to upgrade.  But
the disclosure follows exactly the disclosure policy.  And in case you
haven't noticed, the Bitcoin Core releases are on a fixed schedule.
There's always a major release in April and in October, and they haven't
gotten faster.  The major releases of course contain new features, and then
any minor releases in between only contain bug fixes or backwards for
consensus updates, if any are adopted.  So, the release cycle is fixed.
The disclosure policy is public and has been followed to the dot here.  So,
I also would push back on the conspiracy theories here.

Also, just a small correction.  So, we currently maintain three versions.
So, this is 31, 30, and 29.x, the major branches after 29.x was released
in spring last year, I think April last year.  It's now getting minor
releases still.  28.x, as you said, was released in October 2024, about
one-and-a-half years ago.  So, when this April 31.0 came out, 28.x had
been declared end of life.  And up to that point, it was considered
maintained and was still getting updates with minor releases.

**Mike Schmidt**: And obviously, instead of just two older versions and one
current version, you wanted to support three or four older versions,
obviously there's a lot of work that would go into doing that.  You would
double the amount of work you're doing at least.  And in some cases,
probably it's harder to go back and fix some of these vulnerabilities
without it being more obvious.  Are those the two factors?  There's the
manpower and then there's the difficulty in security vulnerabilities in
terms of backporting them.  Is that the considerations that go into why not
support 10 versions back, like people seem to want?

**Mark Erhardt**: Yeah.  Backports generally mean that you have to make a
fix work in the reality of half a year, a year and one-and-a-half years ago.
So, if the code changed in the area of where the fix is introduced, that
can increase the overhead significantly.  And then, because the patch is
applied to a different state of the codebase, it requires fresh review.
And I think the review burden on the back ports is part of it.  And then
also, if you were to maintain more versions, the window for the disclosures
would probably have to be longer, because the maintained versions should
probably not have disclosed bugs.  So, not only would you have to propagate
back to the undisclosed bugs further, but you would also disclose them more
slowly.  And one of the criticisms is that the disclosure policy is already
giving a lot of time until some of the bugs are disclosed.  In other types
of software, it is common for bugs to be disclosed within 90 days.  But
Bitcoin Core does not do this, because the ecosystem updates much more
slowly to new versions of the nodes.  I think there's maybe barely 20% to
30% of all nodes are on the latest major version at any time, at least of
the Bitcoin Core nodes.  So, if we disclosed much more quickly, we would
basically force users to run the newest version much more quickly, and I
think that is not intended.

**Mike Schmidt**: And of course, there's no auto-update feature, which is
unspoken, but probably known by listeners why that's the case.  Anything
else on this item, Murch?  Okay, we will jump to Releases and release
candidates.

_Core Lightning 26.06rc1_

We just have the one, Core Lightning 26.06rc1.  This week, this is the
first RC for this next major version of CLN.  There are a few key changes
that we outlined.  Obviously, anyone using CLN wants to jump into the
release notes, there's a nice change log that outlines everything.  We did
call out some new RPCs.  One is this graceful RPC, which is a graceful
shutdown for CLN nodes, which allows a bunch of in-flight operations to
complete before stopping.  There is a sendamount RPC.  I think we may get
to it later in the Notable code segment, but the ability to pay an invoice
but lets you specify the total that you want to spend with the routing fees
included, rather than paying an invoice and discovering that the final cost
after routing fees are added on top, which is a little bit different.

They've also, in CLN, started the deprecation cycle for the pay RPCs, and
they're moving to xpay, which has already been around, but they're moving
to default to xpay and slowly deprecating the pay set of payment
invocations.  And then, there is another item that we highlighted, which we
cover later in the newsletter, which is BOLT12 payer-proof RPC support.
And we'll jump into that when we get to that PR.  But obviously, if you're
a CLN user, take a look at this, take a look at the release notes and give
the team feedback before it gets released.

_Bitcoin Core #35209_

Notable code and documentation changes.  We do not have Gustavo with us
this week, so Murch and I are going to sort of jump back and forth.  We
sort of grabbed a handful each, and we'll iterate back and forth on these.
We'll start with Bitcoin Core #35209.

**Mark Erhardt**: Yeah, so this one covers the overt fix for the bug we
just discussed at the beginning, or rather after Fabian's item, the overt
fix of this data being available to be read, or it being possible for the
data to be read after it was freed up.  The covert fix had been that the
early exit that enabled that was prevented and the function always ran to
its end.  The overt fix here is that the data is constructed in the correct
order so that any reads would not be able to access the freed-up data
anymore, because the data is correctly destroyed and detected to be
destroyed after it's freed, and cannot be read anymore.  So, this is
basically the cleanup for the covert fix from 29.0.

**Mike Schmidt**: So, doing it the right way because it's already public
that this vulnerability is out there.  So, you don't need to shim in some,
I guess, less straightforward way of doing it.

**Mark Erhardt**: Yeah.  Basically, the covert fix had been there for this
whole time in order to prevent that the data can be read after it was freed
up.  But now that the bug has been disclosed, they went back and cleaned it
up in the proper way so that the data cannot be read after it's freed up in
the first place.

_BIPs #2116_

For the next one, we have an update to the BIPs repository.  This is BIPs
#2116.  BIP #2116 publishes BIP323, "24 nVersion bits for general purpose
use".  So, as some of you might be familiar, we don't really use the
version field on blocks for the intended purpose very much, only versions
for 0 through 4 are used at all.  And I believe version 4 actually
indicates that some of the bits should be read as signals to be ready to
enforce a new soft fork.  This was defined in BIP9 and an alternative
interpretation was offered by BIP8.  So, recently, we have been seeing that
some miners had started rolling nTime again.  As you might know, the nonce
field in the block header is 32 bits and 32 bits only gives you something
like 4 billion possible iterations on the same block candidate until the
nonce field is used up.  So, in order to continue to use the same block
template, just with different headers, this had been changing bits in the
time field, which then would cause the times to be a little shifted from the
actual time that the miner was processing a block candidate.

The idea behind the BIP323 is an extension of BIP320, where we had already
a proposal to use 16 bits of the version as extra nonce space, where you
could increase the entropy of the block header by just putting random data
in half of the version field.  It expands that to 24 bits now, which then
would give a total of 56 bits of entropy to the block header, which is
equivalent of being able to do 72 petahashes, 72 times 10^15 candidates --
sorry, I should be specific.  So, you make one block template that has all
the transactions, and you especially have a coinbase transaction that pays
you in your block template.  All the rest of the transactions might be the
same as another miner, but your coinbase transaction makes the block
template unique to you.  And now, you need to iterate over block candidates,
which are different in some manner, because as soon as you change at least
one bit in the block, you will get a different result for the hash and may
get a low enough hash to produce a valid block.  So, in order to iterate
over as many as possible block candidates for one block template, so you
don't have to change anything about the transactions in the block, you want
to have a lot of entropy in the block header.  Baked into the block header
is the nonce field, which has 32 bits, or 4 bytes, and that only gives you
4 billion different attempts, which is only like 3 megahashes per second.
And that is obviously not even enough for a laptop.  And with the
additional 24 bits that are now proposed to be usable for extra nonce space
in the version field of the header, you would have a total of 56 bits that
you can flip and flop in every direction.  And that would allow you to do
17, what is that?  Quintillion, quadrillion?  72 quadrillion block
candidates per second.  So, you would only have to update the time stamp on
the block once you've gone through those.  I think the most powerful ASICs
are somewhere around 20 petahashes at this point.  So, at this time
currently, you would no longer need to time-roll at all if this BIP got
adopted.  Okay, now I think I covered it.

**Mike Schmidt**: I have a question.  So, the reason to not roll nTime, or
to avoid it, is obviously not a performance thing, the performance will be
the same regardless.  It's just more that by rolling that, that timestamp
moves in a way that is away from potentially reality and you might get into
trouble there, whereas when you're rolling the version bits, there's not
really any harm in that drifting around.

**Mark Erhardt**: Yeah, not really any harm, it's just weird.  It might
lead to odd effects such as a block being found before its predecessor,
according to the timestamp; or if it were applying to the last or the first
block in a difficulty period, it might slightly shift the difficulty
adjustment for the next difficulty period.  Generally, it would just be
neater if the time matched as closely as possible to the wall clock time.
Yeah, we're very lenient in what we accept in timestamps for blocks.  So,
they can generally be up to one hour in the past and two hours in the
future.  So, it shouldn't really create any issues if you do nTime-rolling,
but having a dedicated space where people expect random numbers would be
cleaner and lead to more expected timestamps.

_BIPs #2141 and BIPs #2155_

All right.  Actually, it's still me.  We have more BIPs work.  Next item
is about the BIPs PRs #2141 and #2155.  Some of you might remember the
BIP322 generic signed message format, which was proposed in 2018, eight
years ago.  So, the old style of message signing had only ever been
properly defined for P2PK and P2PKH outputs.  So, if you wanted to prove,
for example, that you owned a specific output script and wanted to commit to
some message as the owner of some UTXO, you could sign a message with the
previously defined signed message format for legacy outputs, and people
could verify that you actually were the owner of that UTXO.  This has been
considered a useful building block for numerous things, such as, for
example, committing to having funds for, I don't know, Lightning channels,
JoinMarket, or other constructions.  But also, people had been worried about
it being used for KYC or for people demanding to learn what your UTXO pool
might be.  So, either way, it got a little pushback back then when it was
proposed and there was still some unaddressed feedback and a bunch of open
questions.  It lost steam at that point.

This year, someone picked it up back up.  Oliver Gugger took a good new
look at it, fleshed out the proof-of-funds construction that can be used to
show or to prove a UTXO pool or a single UTXO, and also he built out the
signature format and protocol for all types of UTXOs.  So, this is generic.
If you can sign for a transaction, you can also sign a message for the same
UTXOs now.  This update to the BIP has some breaking changes.  First, it
adds a human-readable prefix to the signed message format.  Two, it changes
slightly how the proof-of-funds construction works, if I remember correctly.
And then, it adds PSBT for allowing people to sign messages together.  And
it adds a new reference implementation and a bunch of test vectors.  This
BIP has now also been moved to complete.  As a reminder for BIPs, the BIPs
workflow is that first you have an idea, you propose that maybe to the
mailing list and discuss that with other interested parties.  Then you write
up a draft.  The draft means that you have formalized the idea well enough
that you can completely, comprehensively describe it, and it is published to
facilitate a broad discussion in the ecosystem.  And then, when your planned
work is finished and you feel that the proposal is ready for adoption by the
ecosystem, you may move it to complete in order to propose it for adoption.

So, the authors of this BIP now think that it is ready to be adopted.  So,
people that are interested in signing messages with any types of UTXOs
should maybe take a look.  I know that there are a bunch of other projects
that have been using their own constructions to do so.  It would be great if
the developers of those projects took a look at this BIP and check whether
it satisfies their needs and whether they had any feedback before it gets
too broadly adopted to make it hard to change things about it.

**Mike Schmidt**: Yeah, I know there's been a lot of community interest in
something like this over the years, and people have rolled their own, people
have just not done certain things because this wasn't available, so I think
a good chunk of people will be happy to see this in complete status.

_Core Lightning #9116_

We're going to cover some Lightning PRs now.  Core Lightning #9116.  This
is related to the RC we talked about earlier as experimental BOLT12 payer
proof support, and that is actually something that is in a draft BOLT right
now, it's in BOLT #1295 as a PR.  And maybe some context what this payer
proof support is.  For example, when you have BOLT11 invoices, a payment
preimage by itself can prove that a payment was made, but it doesn't prove
who made that payment.  BOLT12 payer proofs go a little bit further and
allow a payer to cryptographically show that they've specifically are the
ones that authorized payment.  And this is useful for disputes or
subscriptions or audits, or any situation where a merchant or a counterparty
needs to verify, "Yes, this specific party was the one that paid this
specific invoice".  And you can jump into the details, but the payer proof
allows a payer to demonstrate that they were the one to pay it.  There's a
couple of pieces of information.  There's the payment preimage, the node
signature, payer signature.  And so, look at the details there.

But I think the interesting piece is that there are selected invoice fields
that can be omitted for privacy reasons.  So, you have this proof, but
you're not giving up too much privacy-related information.  And so, this PR
is a draft and experimental implementation of that payer proof support.
And so, there's some common functions for creating and validating these
sorts of proofs under the bolt12-cli.  But I will note again that this is
experimental and it may change.  But this is in that RC that we mentioned.

_Core Lightning #9110_

Core Lightning #9110.  This is a fairly substantial PR.  Looking at it, it
had 43 commits, 4,900 lines of code added, and 3,000 removed.  So, this is
a meaningful piece, and you'll see why.  This has to do with the
deprecation that I mentioned in CLN of the older RPCs for payments.  So,
the pay RPC, paystatus, keysend, getroute, renepay, renepaystatus are all
moving to deprecated state.  And there's a phased deprecation.  It looks
like it's starting in this 26.06 that we spoke about, and then removal
scheduled for 27.03.  So, that would be next year in March-ish.  And so,
not only there's the deprecation of those existing RPCs, but then there's
these xpay and xpay-related RPCs that are sort of being, I guess, defaulted
in.  And maybe a question might be, why are they getting rid of pay and
moving to this xpay?  I think xpay, other than being newer and not having a
lot of the legacy below it over the years, it was also written from scratch
to be multipath-native.  It uses that renepay routing, probabilistic routing
that we've talked about previously in other podcasts, although I don't have
those podcasts handy.  Look for where we spoke with René Pickhardt, you can
get some details on that.

Yeah, so you can see they're overhauling how they're handling some of their
core RPCs and defaults and deprecating.  So, that's why there's so many
commits it seems.

_LDK #4598_

Switching to LDK, we have LDK #4598.  This is a bug fix in the component
in LDK that's responsible for sweeping funds back to a user's wallet after
a channel closes.  This could include time-sensitive things like HTLC (Hash
Time Locked Contract) outputs that have deadlines for being claimed.
Previously, the code in LDK used a flag to prevent two sweep attempts from
running at the same time.  But the problem was, if a sweep was canceled in
the middle for whatever reason, rather than completing normally, that flag
actually never got cleared in certain situations, which means with that flag
being stuck, then every subsequent sweep would then quietly do nothing.  So,
the node would just keep queuing these outputs to sweep, but none of them
would actually get processed because that flag was still set.  It would
actually restart, it would reset that flag when the node itself was
restarted.  But as you can see, that could potentially result in issues,
because some of those HTLC outputs with deadlines could expire while the
node was just appearing to function normally, and that can result in fund
loss.  So, fixing this PR ensures that that flag is always cleared,
regardless of what happens during a different sweep.

_LDK #4528_

LDK #4528 makes a change.  This is related to metadata that could be
included in an invoice.  So, some BOLT12 invoices include this optional
metadata fields that the recipient attaches, that they expect to see sort of
echoed back or mirrored back to them when the payment actually arrives.  And
previously, LDK didn't enforce that that payment actually carried the same
metadata that the invoice specified.  And that means that a sender could
silently or maliciously, or whatever, drop or alter that metadata without
the recipient knowing that.  And LDK essentially made a change now that it
verifies that that metadata matches.  And I think there's an opt-out for
compatibility with older senders.

It was noted, I would encourage LDK users to look at this PR.  There's some
notes about compatibility, like when you'd be upgrading and things in
flight, and whatnot.  So, I would encourage users to take a look at that to
make sure that when you upgrade, you sort of know what might be happening
here in terms of a compatibility perspective.

_LND #10612_

LND #10612.  This is an addition to LND in that LND can now find a path
for onion messages through the network, and so it can fully initiate onion
message start to finish.  Whereas previously, LND would only forward onion
messages that it got from other nodes, but it couldn't actually originate
onion messages itself, because it didn't have a way to create a route to
the destination without it being handed to them from some external source.
This is obviously nice for things like BOLT12 offers, which rely on onion
messages, so it's good to see that.  I think the only other note I had on
this one was that, yeah, so the pathfinding that they're using obviously
doesn't use anything related to fees or liquidity like you normally would
use for binding.  It's just about reachability, because you're just routing
these onion messages, not actually value.  Yeah, Murch?

**Mark Erhardt**: Question.  So, graph-based pathfinding, does that refer
here to channel network?  Because I think that onion messages can also be
forwarded to other Lightning node connections, where the two peers don't
necessarily have to have a channel open.  But here it sounds like
graph-based might follow the channel network.  Do you happen to know?

**Mike Schmidt**: I don't think so.  My understanding is that LND will
search the graph for nodes that advertise onion message support and then
construct a route to the destination automatically based on that.  So, it
doesn't appear that it has to be related to having a channel.

**Mark Erhardt**: Right, but then a node would know its own peers, of
course, but hopefully would not know the peers of other nodes.  Maybe the
first hop is just its own peer and then after that, it follows the channel
network.  So, I was just wondering whether you saw information on that.

**Mike Schmidt**: That's a good point.  I only have what I just said.  I am
not sure how then, once you determine that you found this node that supports
onion messages, like how the routing then works based on that.  So, yeah,
not sure.

**Mark Erhardt**: Well, if you have a channel with another node, clearly
you must be talking to them.  So, presumably the channel network does
provide a set of minimum connections that are available.  But yeah.  So, my
interpretation would be it follows the channel network.  Maybe someone can
tell us in the responses to our podcast tweet what the details are here.

_BTCPay Server #7354_

**Mike Schmidt**: Yeah.  Let us know.  BTCPay Server #7354 is a fix for a
security issue where in some cases, certain users could accidentally be
exposed to private wallet key information that they should not have access
to.  I think this was a result of some changes made to BTCPay server's
wallet permissioning system that was recently added.  And there was a gap
in that which users that had permission to sign transactions, but not
permission to view the wallet seed or change certain other settings, could
actually end up seeing the individual address level private keys generated
from the master seed for specific addresses during the signing process.  And
so, the fix here is to change how that hot wallet access is handled
internally.  I think they've done some separation there to make sure that
those permissions stay intact throughout the signing flow.

_BDK #2195_

BDK #2195.  This fixes a bug in BDK, where BDK could fail to sync
transaction history when working with an Electrum server backend, if a
transaction's first output was, for example, an OP_RETURN which is
unspendable and not indexed by Electrum.  This is because BDK was looking
up a transaction's confirmation status using the first output's address, but
OP_RETURN does not have such an address, so Electrum would return nothing.
And then, BDK would treat the transaction as if it didn't exist.  So, the
fix is that now BDK will skip any unindexed outputs and uses the first
output that Electrum would actually track, and then falling back to an input
address if needed.

**Mark Erhardt**: When I read that, I was confused.  Why don't they just
ask for the txid?

**Mike Schmidt**: I'm not sure about the mechanics there.  But for whatever
reason, they're querying based on outputs and they just picked the first
output, which apparently is not great.  As to why they didn't just use the
txid, not sure.

**Mark Erhardt**: I mean, if they know the output, they must know the txid,
because the output's unique identifier is the txid plus the vout position.
And I'm pretty sure that Electrum would index by txid.  So, I'm just
confused by this item, but I haven't looked into it.

**Mike Schmidt**: We're giving our listeners all kinds of homework for us.
So, yell at us in the responses to the Twitter thread here.  And Murch, I
know you're going to take Inquisition and BINANAs.  Maybe I'll spelunk in
this BDK PR comments to see if I can find something in the meantime.

_Bitcoin Inquisition #100_

**Mark Erhardt**: How about you do that?  The last two items are Bitcoin
Inquisition #100.  This one implements BIP446, which is the template hash
proposal, on signet.  So, if you were chomping at the bit to play around
with OP_TEMPLATEHASH on a mainnet-like network, OP_TEMPLATEHASH is now
available on signet, I think.  I don't know if it's activated yet, but it
is implemented.  So, presumably, it would be activated very soon, if not
already.  There's also a bunch of tests that get added to Inquisition.
Inquisition is a project fork of Bitcoin Core that extends the rules for
signet with proposed consensus changes and other proposals so people can
play around with them on a test network; the test network being here the
signet, where blocks are signed into existence by the operators.  So, yeah.

**Mike Schmidt**: I think I saw some people going back and forth on X the
other day, and I think that this was about to be activated.  And the reason
that I saw that is someone was asking for it similarly on Mutinynet, and
Mutinynet, I guess, sort of takes its cue from Inquisition.  And so, there
was a sort of a countdown going on.  So, maybe somebody else can yell at
us about that one, or you can check Inquisition yourself and see.

**Mark Erhardt**: Yeah, I did see also that Mutiny had activated it.
Mutiny is a different signet, and it is different in that I think it has a
shorter block interval, I think half a minute.  And that makes it faster
for developers to test with, but it doesn't try to replicate mainnet as
closely.  All right.  Also, you can run your own signet if you want a test
network.  But of course, if other people are doing the heavy lift on the
consensus changes, that might be easier.  So, you can just grab Inquisition
and change the challenge in the signet and run your own signet with it too.

**Mike Schmidt**: I think this is something that I've seen people miss.
Yeah, you can run your own signet.  There is a sort of, I guess,
standard-ish signet, but you can run your own.  So, don't think because
there is a group running that particular network that all such signet things
are permissioned.  You can have your own version.

_BINANAs #20_

**Mark Erhardt**: Right.  So, finally, BINANAs #20 assigns BIN-2026-0002
for the implementation of OP_CHECKCONTRACTVERIFY (OP_CCV).  So, in the
Inquisition deployments, the deployments are guarded by a public identifier.
These are the BINANA numbers, I think there's always a BINANA number, even
if a BIP has been assigned already.  They're just used in the deployment.
So, it looks like, OP_CCV is also coming to signet pretty soon.  OP_CCV is
an opcode that allows you to specify how the amount of a UTXO has to flow
from that UTXO to other UTXOs by encumbering, for example, a minimum amount
that has to be spent to a specific output script, or by specifying that it
has to go to the same output script again, like a quine.  This is especially
useful in constructions for things like vaults.  And yeah, looks like that
is also coming to Inquisition.  Generally, in the past few weeks, we've been
seeing a lot of discussion about covenants again.  It seems to me that
OP_TEMPLATEHASH and debundle rebindable transactions has been getting some
attention lately as a new attempt to get CTV-like (CHECKTEMPLATEVERIFY-like)
features.

So, if you're excited about covenants, I guess our next consensus change
feature will be pretty laden with information.

**Mike Schmidt**: Just also a quick note that the BIP443 PR to Inquisition
has been open since mid-December, and I know that the author is looking for
feedback there.  So, if you look at the Bitcoin Inquisition GitHub, that
would be PR #102, which is open and getting feedback.  I see Salvatore, I
see AJ and Antoine in here talking.  So, if you are curious about BIP443,
CCV, take a look.  Feedback welcome and wanted from the author.  All right,
Murch, we did it.

**Mark Erhardt**: Yeah, hear you next week.

**Mike Schmidt**: #405's in the bag.  We want to thank Fabian for joining
us.  Murch, thanks for co-hosting and working on the Notable codes segment
with me.  And we'll hear you all next week.  Cheers.

**Mark Erhardt**: Cheers.

{% include references.md %}
