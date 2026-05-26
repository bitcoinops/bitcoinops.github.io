---
title: 'Bitcoin Optech Newsletter #380 Recap Podcast'
permalink: /en/podcast/2025/11/18/
reference: /en/newsletters/2025/11/14/
name: 2025-11-18-recap
slug: 2025-11-18-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by TheCharlatan to discuss [Newsletter #380]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-10-18/412728425-44100-2-e3752b27fd573.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #380 Recap.  We
have a short one this week, but a good one.  We're going to talk about an LND
RC, and we have a Bitcoin-kernel-related PR that we're going to get into.  There
is no news this week, so Murch and I are going to be joined by a special guest,
TheCharlatan.  Charlatan, you want to introduce yourself?

**TheCharlatan**: Yeah, hi, I'm working on Bitcoin Core, mostly the Bitcoin
kernel project.

**Mike Schmidt**: Awesome.  We're going to jump into that briefly just after we
go through the one release candidate that we have this week.  As I mentioned,
there's no news items.  And also, this is our week to normally do a Bitcoin Core
PR Review Club in our monthly segment.  And there were no Review Clubs in this
past month.  So, we're going to skip over that, skip over the news, right into
the Releases and release candidates.  Yeah, Murch.

**Mark Erhardt**: Also, a reminder, if you want to host a Bitcoin Core Review
Club, these can be hosted by pretty much anyone that has dived into a PR
sufficiently to talk a little bit about it.  It's a chat meeting.  You can find
more information on bitcoincore.reviews, which is their website.

_LND 0.20.0-beta.rc4_

**Mike Schmidt**: Awesome, good shout out.  LND 0.20.0-beta.rc4.  We've covered,
I think, RC3 previously.  I did reach out to someone from LND to jump on the
show today since we had some bandwidth to talk about it, but we didn't get
anybody.  Maybe we'll get somebody for the official release.  This release has
multiple bug fixes, support for P2TR fallback addresses on BOLT11 invoices, a
bunch of RPC and lncli additions and improvements, and maybe we'll jump into
that deeper in the future.  Anything to add, Murch?  Notable code and
documentation changes.

**Mark Erhardt**: Actually, on second thought, sorry.  I did look into what a
noopAdd HTLC (Hash Time Locked Contract) type could be, because I thought that I
hadn't seen that before.  So, apparently this is an HTLC that goes through the
HTLC update statuses, but doesn't transfer money.  And I don't know why that
would be useful, but presumably taproot assets, maybe?

**Mike Schmidt**: Yeah, well that's something that they're working on, and you'd
have to think, yeah, they're exchanging data, they're not exchanging money.  So,
yeah, maybe something there.

**Mark Erhardt**: I don't know exactly.  But anyway, that's what a noopAdd HTLC
type is.  Sorry.  And back to Notable code and documentation changes, I think.

_Bitcoin Core #30595_

**Mike Schmidt**: Bitcoin Core #30595.  This is a PR titled, "Kernel: Introduce
C header API".  We have TheCharlatan here who's been heading up the kernel
efforts.  We've had TheCharlatan on previous shows, and in the write-up for this
PR, we referenced some of the newsletters where we talked about similar topics
previously.  If you want to get some foundational information, jump into there.
But Charlatan, this is a big one, right?  There's a lot of emojis on this PR, we
don't usually get that with some of the PRs we jump into.  Why are people so
excited?  What does this do?  How does it fit into the kernel project?

**TheCharlatan**: This is a big milestone for the project, so people are excited
for a reason here.  The big thing this enables is it gives a stable interface
for outside projects to interact with Bitcoin Core's validation code.  So, other
projects can now write full node implementations and not implement their own
validation code, but instead reuse the Bitcoin kernel library through the C
header.  And during the development of the C header, there have been a few
projects who've already done so.  So, there's a Rust node that uses Rust
bindings against the C header, which can do IBD (Initial Block Download).
There's some other projects, like an experimental SwiftSync implementation
that's using it.  And one of the utreexo implementations, Floresta, has also
used it to achieve much faster script validation.

**Mike Schmidt**: I think we also had even spoken early on with Abubakar, who
was doing some fee-related analysis, if I recall correctly.  And he was using an
early version of kernel to do some of that, if I recall correctly.  For folks
like me who like these tracking issues, there's actually a tracking issue and
there's a project on GitHub.  This is tracking issue #27587, to plug into that.
What does it mean to have a C header API?  Like, if I wanted to use Python, can
I use this?  Can I use Java and somehow hook into this API?  Maybe talk a little
bit about the architecture there.

**TheCharlatan**: Yeah, C has the nice property that it is a fairly simple
programming language, and it also doesn't change a whole lot.  So, in all
likelihood, if you've written C 20 years ago, it will look pretty much the same
still as C written nowadays.  So, the tooling to integrate C into foreign
programming languages is really mature.  Nearly every programming language out
there has so-called foreign function interfaces, or FFI, binding tools that
allow you to call C functions from their own programming languages.  And for the
kernel specifically, we now have bindings to the C header in Go, Rust, .NET,
Java, Python, and a bunch more that I probably don't even know of yet, because
people have been contributing these out of the blue.  And the C header
specifically just gives us the required stability to define a clear interface
for the library.  So, now, we have a couple of functions that define how you can
use it, and any other implementation or other developer can just program against
that interface and rely on it.

I should note, though, that the interface is still experimental as of now.  So,
it hasn't been part of a Bitcoin Core release yet.  There will likely be
breaking changes to it still and it is un-versioned.  So, if you plan on relying
on it right now, you will probably still experience breaking changes in the
future.  But once it is actually part of a release and we start versioning it,
we plan on making it backwards-compatible and supplying a stable-as-possible
interface.

**Mike Schmidt**: In terms of stability or expecting changes after you get sort
of an official non-experimental version out the door, would it be that people
need certain things from the kernel, or would it be that consensus changes if
there is an activated soft fork?  Or, what would be the scenarios in which it
would change?

**TheCharlatan**: I think we'll see both.  So, we already now have a bunch of
new, open PRs on Bitcoin Core that are expanding the exposed API, because it
doesn't already fit the needs of all its users.  And I think that will continue
over time.  At the same time, if we add, I don't know, some weird future witness
field or something like that, and the structure of either block or transaction
is going to change, there will also be a change in the kernel API to reflect
that and probably some change to it in a backwards-compatible fashion, as long
as it is rolled out as a soft fork.

**Mike Schmidt**: Makes sense.  We have a lot of technical-minded listeners, and
I can imagine them wanting to play with this, since it sounds like there's
bindings for languages that people are more familiar with, higher-level
languages.  What would you say is the best URL or resource for them to read
about the philosophy of kernel or get access to these bindings?  I know
stickies-v has a Python wrapper that's fairly accessible.  Is there a place that
you can point people to, or is it dispersed all around the Internet?

**TheCharlatan**: Yeah, right now it's the tracking issue you mentioned before.
So, that's issue #27587 in the Bitcoin repo.  But we are discussing right now
whether we can either host the documentation or common resources in a single
repository under the Bitcoin Core organization.  And yeah, something we've also
been discussing, if we should have a few let's say blessed foreign language
bindings to the library that are also hosted by Bitcoin Core and are maintained,
just to give developers a consistent experience across different languages.

**Mike Schmidt**: How has feedback been so far?  It seems like people are
interested.  You mentioned Floresta, we talked about a few other projects
already.  It seems like kernel, I wasn't around for LibConsensus,
Bitcoin/Bitcoin consensus library, but it seems like it's getting uptake in the
community, which gives it some momentum and maybe staying power compared to that
previous effort.

**TheCharlatan**: Yeah, I think so too.  So, the initial Bitcoin consensus
efforts, I feel like, yeah, kind of lost momentum over the years to the point
where it took, I think, nearly two years for Bitcoin Core to implement taproot
support for it.  So, it wasn't really possible to validate taproot transactions
through the Bitcoin consensus API for a long time.  And that has also slowed
down progress from it significantly too.  But the uptake so far has been kind of
exciting to see.  So, there's been a few projects who've already integrated it
into their test suites to check if their transaction constructions actually
verify correctly, and if they're building either their layer 2 protocols or
wallets correctly, or if their manuscript compiler actually works.  So, that's
pretty exciting to see.

There's also been some progress on the alternative client side.  So, what
started out as my own little Rust side project thing, just to see if I can get
an alternative full node build, has also gotten some traction the past few
weeks.  So, there's been some other developers interested in it and contributing
to it now.

**Mike Schmidt**: What's the name?

**TheCharlatan**: That's kernel-node on my own GitHub profile.  But the
interesting thing about in my eyes is that these ecosystems that developed
around certain other languages, for example, Rust or Go or .NET, can now use
these to actually test their tools right, and implement their own full nodes
just to exercise all the tooling that they have developed over the past decade,
and I think that's really exciting.

**Mike Schmidt**: Now, just maybe to clarify, probably listeners are familiar
with this already, but just to bat the point home.  We're referring to this as a
project or a sub-project, but this is part of the Bitcoin Core repository
currently, correct?

**TheCharlatan**: Yes.  So, the C header, which defines the interface that
people can now build either their test suites or whatever tooling they need,
again, it's got merged into Bitcoin Core or into the Bitcoin/Bitcoin
repository's master branch two weeks ago now.

**Mark Erhardt**: So, my understanding is that libbitcoinkernel is a standalone
library and with the C interfaces now, it's accessible to a plethora of other
programming languages.  So, what you're saying is we have, or you specifically
and other people that helped, have pulled together all of the consensus-relevant
code and verification and validation, and so forth, into a library that other
people can pull into their project.  They can build around it, they might
hopefully soon build something that works like Electrum, but uses Bitcoin Core's
validation under the hood.  They might build other full nodes around it where
they implement their interfaces, indexes, maybe an address index, maybe
something like a block explorer, and so forth.  And all of these can just use
the same consensus engine that is a standalone library that is being shipped
with Bitcoin Core now.

**TheCharlatan**: Yeah, thanks for summarizing that, Murch.  One thing that I
wanted to mention here, and I don't think that people have been discussing that
yet at all, is that now that, or if in a few years, or even in the next release,
we actually release this interface and we have a versioned interface for it, we
can have alternative implementations that share the same interface.  But if you
want to propose a soft fork or some other change to Bitcoin, you can do so, but
still keep the interface stable and have all the implementations just use it.  I
think that's pretty liberating, because one of the fears was that this would
kind of entrench Bitcoin Core's role as the gatekeeper of the consensus codes.
But I think this might actually have the opposite effect, where people can
experiment pretty freely and everyone can benefit from those experimentations
through the same interface.

**Mark Erhardt**: I hadn't even considered that.  Yeah, that's pretty
interesting.  So, it makes it so that the part of the codebase that you have to
maintain or edit in order to change or make a software proposal would get
narrower and maybe more stable, and you could still plug it into all sorts of
other software that runs on top of it because it has this shared interface.

**TheCharlatan**: Yes.

**Mark Erhardt**: Yeah, cool.  So, where is the project headed from this point
on?  Does Bitcoin Core use libbitcoinkernel under the hood?  What else is left
to do?

**TheCharlatan**: I guess now the real work starts, because the project kind of
needed this one push where we now have something to start off on.  And the
current API that got merged into Core's master branch now is still fairly
limited.  So, what you can do with it is you can validate a block, you can read
block data, and you can validate scripts.  But to build a full-featured node,
you would want a few more features, like just validating single transactions in
case you want to build your own mempool, or you want to add some more hooks to
better program your own data model into it, like for example if you want to
build a utreexo node or a SwiftSync node.  So, there's definitely work that
still needs to be done in order to make the API more feature complete.  But
yeah, going back to your question there about whether Core can actually use the
same interface itself, I think we're really far away from that still because
it's still too clunky.  There will be a lot of code changes and code moves to
realize that.  And I think even if there would be buy-in for such a project,
where Core itself becomes a user of this interface, it would still take a long
time to move that amount of code around and change it to a user of it.  All that
said, the core logic is indeed reused by Bitcoin Core.  And the only thing
that's not reused is this thin wrapper that defines how the API interfaces with
the actual bulk of the logic.

**Mark Erhardt**: Yeah, that was the follow-up that I was about to ask.  Is it
the same code or are we now maintaining two copies of the same consensus code
right now?

**TheCharlatan**: Yeah, it's the same code.

**Mark Erhardt**: Good, that's good.  So, in a way, Bitcoin Core is using the
same code at this time.  Bitcoin Core is not using the interface because it has
direct access and doesn't need the interface in order to access it.  But it's
running literally exactly the same consensus code.

**Mike Schmidt**: I have a question about, you sort of gave us maybe what's
coming with kernel.  I think it would be interesting for folks to understand
what's in kernel or going to be in kernel or not?  And I think one way to ask
that question is, when you build kernel node, what did you need to build?  So,
aka, what wasn't in kernel?  Like, for example, is mempool in there?  Is P2P in
there?  Maybe the big pieces of what you built with kernel node can answer the
question of what is missing in kernel, and demarcate where it ends off.

**TheCharlatan**: Yeah, so in order to implement a full node that can do IBD and
keep up with the chain tip, I had to implement some P2P logic to download the
blocks and then pass them on, or pass the raw data onto the kernel logic.  And
yeah, that's pretty much it in order to get validation going and keeping up with
the current state and serving blocks to the network too.  So, that already takes
care of what the full nodes essentially should be able to do.  The kernel
library does currently contain the logic for the mempool.  But yeah, I'm
hesitant at exposing it through the C API.  I'm more working on an approach
where we end up exposing an interface through the C header that allows an
external programmer to program either their own mempool or create a library,
like libbitcoinkernel, from our existing mempool codes that plugs into that
interface.

**Mike Schmidt**: So, that would allow someone like Libbitcoin, unrelated to
kernel, but the Libbitcoin software to implement that interface for their, "We
totally don't have a mempool setup", is that right?

**TheCharlatan**: Yeah.

**Mike Schmidt**: Okay.  So, in order to get the kernel node that you created,
you needed the ability to find peers on the network, send P2P messages, and then
essentially get blocks from them and pass that to kernel, or get blocks from the
kernel and pass it over the P2P network, essentially.

**TheCharlatan**: Yeah, exactly.

**Mike Schmidt**: Okay, cool.

**TheCharlatan**: So, going beyond that, I think the more interesting users of
the kernel would be full node clients that have alternative data models, so
clients that either don't have a UTXO set or have a different way of storing
their block data.  And for them, I would like to both have a similar approach,
where we expose an interface to plug in their own readers and writers for a
database, or some data model that they bring themselves; and we also expose
lower-level methods that can do block validation against a UTXO set that you can
bring yourself.  So, for example, for a utreexo client, I would expose a
function that can validate a block, given the block and all the outputs that
were spent by that block.

**Mike Schmidt**: Makes sense.  You touched on a couple of what I would maybe
call confusion points or misconceptions that you see the broader community
having about kernel.  Is there anything else that when you see people talking
about kernel, that people are consistently confused about or getting wrong, or
did we sort of hit on those with regards to like soft forks you mentioned?

**TheCharlatan**: I haven't seen that many confused comments, I think.  One
important thing to keep in mind is that you only really get the full, let's say,
Bitcoin call parity and validation logic if you really follow the same path with
just providing the kernel API a block, let the same validation logic happen,
don't interfere with the databases or how we write the blocks to disk or
anything like that.  And if you only use a reduced subset of that logic, then
yeah, you run into potential dangers where you have to be very careful that you
implement your own readers and writers or your own deserializers, and stuff like
that, without introducing consensus failures.  And I don't think that the kernel
library is a silver bullet for these cases, but it can minimize the risk as far
as possible.

**Mike Schmidt**: Murch, anything else you think that we should touch on here?
I'm glad we had a short newsletter to be able to really dig into this one.

**Mark Erhardt**: I think my questions are covered, thank you.

**Mike Schmidt**: Awesome.  So, listeners, check out the tracking issue #27587.
Charlatan, were you on a podcast recently talking about kernel?

**TheCharlatan**: I was, but we ended up mostly talking about policy again.

**Mike Schmidt**: Oh, all podcasts lead there, I guess.  Okay.  All right, well
this will serve as more of a kernel podcast for people then.  Great.  Charlatan,
thanks for joining us and thanks for your work on this important sub-project.

**TheCharlatan**: Yeah, thank you for letting me present the work I'm most
excited about in Bitcoin.

**Mike Schmidt**: Awesome.  Yeah, I hope people listen to this and share this,
not just this podcast, but this work and that it gets even more traction, more
feedback, more testing, more users, and hopefully it can continue to mature.
Thanks again.

**TheCharlatan**: Thanks.

**Mark Erhardt**: Cheers.

_Bitcoin Core #33443_

**Mike Schmidt**: Bitcoin Core #33443.  This is a PR to reduce logging during
block replay.  And I'll maybe set some context here.  Back in Newsletter #378,
Murch and I covered four Bitcoin Core vulnerability disclosures, which were
fixed in Bitcoin Core v30.  Two of those vulnerabilities were disk-filling
attack vulnerabilities that involved excessive log file entries.  And the fix
for both of those were, there was a general rate limiting on log file entries
rule or restriction that was put in place.  Well, that new rate limit was then
being triggered when blocks were being replayed after an incomplete re-indexing
operation, and that's what this PR is dealing with.  Essentially, a bunch of log
messages were spit out after replaying those blocks.  So, there's these
rolling-back and rolling-forward messages that were being put in the log file.
So, this PR reduces those excessive log entries.  Rather than logging once for
each block, Bitcoin Core will now log a single message indicating the range of
blocks that were going to be processed.  And then, every 10,000 blocks there
would be a log message, as opposed to every single block.  I think that has the
advantage of also making the logs a little bit more readable, and then cutting
down on the overhead that we discussed could be problematic.  Murch, anything to
add there?

**Mark Erhardt**: No, that seems like it covers it well.

_Core Lightning #8656_

**Mike Schmidt**: Core Lightning #8653.  This changes Core Lightning (CLN) to
have the newaddr endpoint generate a P2TR address by default.  So, taproot by
default now for new addresses in CLN.  Seems like an easy one.

**Mark Erhardt**: Yeah.  Oh, by the way, taproot has been live for more than
four years as of a few days ago.  So, glad that we finally get to a point where
wallets are using them by default.

_Core Lightning #8671_

**Mike Schmidt**: Yeah.  Adoption takes longer than you think.  Core Lightning
#8671.  This adds an invoice_msat field to the htlc_accepted hook, so that
plugins can override the invoice amount.  The motivation here was that LSPs
(Lightning Service Providers) and their clients can more easily open channels.
So, an LSP takes a fee for opening the channel, for example, and then the client
of that LSP expects that fee to be deducted from the HTLC.  This was possible
previously, but it involved multiple invoices.  So, the first invoice would be
the expected amount, and then a second invoice with the opening fee then added
to the amount.  So, now that's all done in one.  I think specifically Greenlight
was mentioned.  I think they are one of the users of CLN, so it makes sense that
they were the motivation for this.  But I think obviously other LSPs can take
advantage of similar functionality.

**Mark Erhardt**: If I think a little bit about this, I think the issue is
buried here in the sender building the chain of HTLCs.  So, wherever the money
is coming from to go into the channel of the LSP, the LSP and the recipient are
aware that the amount actually is going to be reduced in the last hop, because
part of it is going to be charged by the LSP.  But the sender that sent the
amount originally would not know, and would therefore not put this fee into the
last hop.  So, this is basically, the way I understand it, it's the recipient
telling a higher-amount invoice to the sender than they are expecting to
receive.  So, the sender builds all the hops as expected, so that the final
amount that arrives at the sender matches the invoice.  But then, the receiver
actually isn't expecting to receive the full amount and therefore allows the
last hop to charge the fees and only forward a reduced amount, and accepts that,
even though the invoice was higher.  And so, I first thought this was something
for the LSP, but really it is going to be used by the recipient in order to
allow the LSP to take the fee.

_LDK #4204_

**Mike Schmidt**: Thanks, Murch.  LDK #4204 makes a small improvement to LDK's
splicing feature.  It updates LDK's splice-handling so that a peer can abort a
splice without forcing a channel closure, as long as that abort happens before
the signatures are exchanged.  Before that, similar protections were in place,
but they were a little bit more aggressive.  So, any aborting during the splice
negotiation at all, even before the signatures were exchanged, would cause a
force closure.  So, now that only happens after signatures.  So, you retain that
splice negotiation safety, but also not unnecessarily force closing.

**Mark Erhardt**: That reminds me of one of the PRs from last week, I don't
remember which number it was exactly, but it looks like LDK has been taking a
careful look at the order of events in some of their channel updates and
realizes, "Wait, signatures haven't been exchanged yet, so nobody has committed
to anything right now.  It's just empty talk and it's safe to just drop it on
the floor".  Yeah, there were two LDK PRs last week.  One was fixing another
premature force close that was for async payments; and then there was also a
race condition related to LDK that they fixed up.

_BIPs #2022_

All right, last PR for our BIPs editor, Murch.  This is BIPs #2022 titled,
"BIP3: clarify number assignment".

**Mark Erhardt**: So, BIP3 had already specified, under the segment that walked
readers through the duties of BIP editors, that numbers were being assigned in
the PR.  However, recently there was a little bit of a, well, not
miscommunication, but a number was announced on social media that hadn't been
assigned in the PR.  So, one of the BIP editors felt that it might be good to
put the information that BIPs are assigned numbers in the PR in other spots in
BIP3 too.  So, this is not a change of BIP3, this is literally just a
clarification by inserting the same information in another spot in the document.
And what it specifies is, unless a number has been assigned in the PR by a BIP
editor, a number has not been assigned.  And as usual, please don't assign your
own numbers.  It's just bad manners, you know.  And also, it isn't really
authoritative.  You can start using it, but it's not actually the number.

**Mike Schmidt**: I noticed that the status of BIP3 as I click in is 'proposed'.
What's the next step, Murch, and how do we get there?

**Mark Erhardt**: Yeah, so I've been working on BIP3 for almost 20 months now, I
think.  And the BIP workflow, per BIP2, which is the current BIP process, is
that people write a draft.  When the draft is sufficiently far along, it might
get merged into the repository or published, right?  At that point, it will have
a number.  And then, when all of the planned work is complete, so the authors
have finished making all the changes and responding to initial feedback, that
they feel it's essentially stable and ready for adoption, they advance it or
they request that it be advanced to the 'proposed' status.  And after the
'proposed' status, or by advancing it to the 'proposed' status, the authors are
essentially saying they perceive this to be ready for adoption and put it
forward to the community for adoption.

So, BIP3 was advanced to proposed in April, which is now seven months ago.  And
so, I've been maintaining a PR that makes all of the proposed changes to the
BIPs, when BIP3 were to be activated.  This PR has been rebased a number of
times and additions have been made.  So, what this does is it renames the
statuses to the statuses proposed in BIP3.  It changes the preamble on a number
of BIPs in a few little ways, and all of the other things that BIP3 proposes to
do if it activates.  So, since it had been opened for seven months, and
generally I've been hearing some well-meaning grunts here and there, I requested
I think a week or maybe even two weeks ago by now, that people please comment on
whether they think we should activate BIP3 and replace the old BIP process,
BIP2, with the new BIP process that I propose with BIP3.  It looks like it's
been working to give a four-week timeframe, and ask that people comment and then
evaluate again whether there's rough consensus for starting to use BIP3, because
suddenly there's been an influx of more comments and also a number of more
people saying that they feel it's good and we should use it.

So, yeah, the next step hopefully is that people who are interested in the BIPs
process take a look at BIP3, leave their review comments, raise any concerns
that they still have.  There's currently one open email on the mailing list, or
actually two, that I still have to reply to, which I hope to get to before
Thanksgiving and this week.  And yeah, so there's been a number of very small
changes proposed, mostly text clarification, and in my opinion, a few questions
that are already answered in the document, but that I have to maybe reply to and
explain how they're already answered in the document.  So, my hope is that when
the four weeks are up, early December, we take another look at what people have
said on the mailing list and on this PR.  And so, far, it looks to me like we're
trending towards activating BIP3 in December.  But if you disagree, please leave
me your comments and the concerns that you have so we can address them.

Anyway, I think looking back at the ambitions that I set out with and the
changes that have been made, BIP3 ended up being closer to BIP2 than I expected
in some ways, but there's also a number of nice simplifications as I see it.
And, there's a few answers to things that we hadn't really considered or that
weren't topics in 2016 when BIP2 was written.  So, if you don't have an opinion
yet, but would like to have one, I would suggest that you read BIP3.  And if you
feel that it's very odd and how dare all these new rules get imposed, maybe also
take a look at BIP2, because I think you'll find that the changes between BIP2
and BIP3 are actually much smaller in many of the things that are being
criticized than you'd expect.  So, yeah, long answer.  Does that answer your
question?

**Mike Schmidt**: Yeah, I think so.  And that is it the wrap on the Notable
codes section.  I did have one follow-up question, since TheCharlatan has been
kind enough to stay on through these summaries, and I may have asked this
before, but I forget.  What are we calling this?  Is it kernel?  Is it Bitcoin
kernel?  Is it Bitcoin Core kernel?  Is it libbitcoinkernel?  How do you how do
you refer to it, Charlatan?

**TheCharlatan**: I prefer calling it the Bitcoin kernel.  I think that has the
least ambiguity.

**Mark Erhardt**: Right, I've seen a few people seek a connection to Libbitcoin
incorrectly, which has been confusing to some.  So, Bitcoin kernel, that's it?

**TheCharlatan**: Yes, please.

**Mark Erhardt**: All right.  Let's make it so.

**Mike Schmidt**: Any parting words, Charlatan?

**TheCharlatan**: Yeah, I forgot to shout out the epic review work that went
into this PR.  So, not only did some reviewers implement full language bindings
before the PR was actually merged, but the code that I initially contributed was
re-implemented multiple times by some reviewers, just to showcase different
approaches, pros and cons to the current approach.  And, yeah, I think 455
review comments.  Yeah, a lot of work went into that, and especially Stickies-v
and Daniel Pfeifer deserve a shoutout here.

**Mike Schmidt**: Awesome.  Well, thank you for joining us, Charlatan.  And,
Murch, you good to wrap?

**Mark Erhardt**: Yeah, good to wrap.  Thank you for joining us and thanks for
all the review.  I think that's generally appropriate for all sorts of projects.
I've also gotten a ton of review on BIP3 meanwhile.  So, thank you to our
reviewers and hear you soon.

**Mike Schmidt**: Cheers.

{% include references.md %}
