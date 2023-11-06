---
title: 'Bitcoin Optech Newsletter #275 Recap Podcast'
permalink: /en/podcast/2023/11/02/
reference: /en/newsletters/2023/11/01/
name: 2023-11-02-recap
slug: 2023-11-02-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt discuss [Newsletter #275]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-10-2/353819797-22050-1-dacef6ce7af92.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #275 Recap on
Twitter Spaces.  Today, we're going to be talking about some follow on
discussion about ideas for Bitcoin scripting changes, including some covenants
research and the OP_CAT proposal.  And we also have our regular sections on a
couple of releases and notable code changes.  I'm Mike Schmidt, I'm a
contributor at Optech and also Executive Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin stuff.
Yeah, and I co-host this thing!

_Continued discussion about scripting changes_

**Mike Schmidt**: Well, jumping into the news items, we have one that we've
divided into two separate categories.  The parent discussion is continued
discussion about scripting changes.  And we've broken the discussions out into
covenants research, as well as the OP_CAT proposal.  We talked about both of
these items briefly last week.  We summarized Rusty Russell's sort of
prototyping that he's been doing with a few simple opcodes that he's using to
enforce covenants and do introspection on transactions, and there's been some
continued discussion on that topic.  AJ Towns, from the mailing list, responded
to Rusty's proposal, essentially stating, "I think there's two reasons to think
about this approach".  And he outlines the first one, which I'll summarize as,
"We want to do vault operations specifically"; and the second reason we might
want this approach is, "We want to make Bitcoin more programmable, so that we
can do contracting experiments directly in wallet software without needing to
justify new soft forks for each experiment".

So, what I took away from that, and he gets into some details which we can jump
into, is that if we want to do vaults, we can just do vaults, and if we want to
make Bitcoin more programmable, we can take bigger steps to do that.  And this
approach, Rusty's approach, is maybe something in the middle of the road, which
it doesn't efficiently do vaults specifically, and it also doesn't make Bitcoin
that much more programmable.  So, I guess he's saying both of the reasons to do
this may be non-optimal.  Murch, I'm not sure if that is an appropriate summary
of Town's feedback; what do you think?

**Mark Erhardt**: Well, to be honest, I'm still not really following this whole
introspection debate, but jumping back some roughly ten years ago, it was always
a strong narrative that Bitcoin is programmable money and it would be really,
really cool to be able to just code up smart contracts that enforce things
happening after other things happen.  The biggest issue with that is always what
we call the oracle problem, which is when stuff happens in the real world, we do
not have information about that on the blockchain, and how do we make that link.

So, I still think it would be really interesting to have ways in which we can
make money flow on our network after one of the parties proves that some
conditions have been met.  And we still want this to happen in a way that is
different from other platforms, where everybody has to repeat all the
calculations and gather the information again to run the script directly
programmed into the blockchain, and you basically redo all the work for every
single contract that is coded here.  We'd rather continue to go with a witness
paradigm where people prove that the contract's content has been met without
actually needing to publish the contract.

Beyond that, it still seems that the wizards are bashing their heads in about,
"Is this better; is that better; should we fiddle on this wheel a little bit; or
do we need a little more salt and pepper with that?"  And as long as the people
that are really excited about this topic and want to push that forward cannot
come to an agreement or have a more advanced stage prototype for something, I
don't think that I'm going to have a position on this matter.

**Mike Schmidt**: One thing you mentioned was the oracle problem, and that was
mentioned briefly in the covenants research item that we covered this week.
Both AJ and Rusty were briefly discussing OP_CHECKSIGFROMSTACK, which is an
opcode I think currently on Elements in Liquid, and that would specifically
allow authenticated data from an oracle to be placed on an evaluation stack, so
to tie in the oracle issue that you mentioned into this discussion.  Another
thing that I thought was interesting, that maybe is a little bit less
covenant-y, scripting-triggering for you, was this suggestion, at least Dave
Harding's interpretation of the discussion, "We think that means BIP345 makes
more sense as a template (like P2WPKH) than is designed for one function, as
opposed to a set of opcodes", as they're proposed now, "designed for that one
function, but could also potentially interact with each other in anticipated
ways".  Any thoughts on that, Murch?  I hadn't heard that before; it seems
interesting.

**Mark Erhardt**: That's an interesting thought, especially for the people that
are opposed to OP_CTV or OP_VAULT or OP_UNVAULT, because it would invariably
make a lot of other possible use cases possible that haven't been completely
thought through.  So, if you actually lock down the vaulting scheme to a
specific template and make it sort of an address type, so that it is really
restricted to that single use case but serves that use case comprehensively,
that would completely eliminate the concerns of people that are like, "But
someone will use it for something else".  So, that might be interesting.  I'm
not sure how compatible that is with how James has been developing his proposal.

Given that you would be able to see that somebody is using a vault anyway, but
only once they take the funds out of the vault, that might be acceptable.  If
you have a specific template, that would mean, of course, that you would see
when people stash funds in the vault that it is a vault, which I haven't thought
it through yet, but that might have some privacy implications and some usability
implications.  So, it might be nicer to make it look like anything else, just
from a privacy perspective.

Also replying to your prior comment on the oracle problem, one of the
interesting things about signatures from an oracle is that with FROST or MuSig,
of course, or discreet log contracts (DLCs), you could already just set up a
transaction in a way that one of the spending paths requires information from an
oracle to be signed, and you can just have the signature there in that way.  But
that of course would require you to either have it in the keypath spend or in a
scriptpath, and if it's a scriptpath, you'd have additional input overhead on
the control block.  So, yeah, I guess it's a question of how efficient you want
your smart contracts to be implementable and then exactly what we're supposed to
allow and what we're not allowing.  I think when people start playing around
more with miniscript and explore more what we can actually do already now that
we have miniscript, especially in tapscript, that debate might become more
narrow and informed.  But anyway, I don't know.

**Mike Schmidt**: One other item that I wanted to highlight, some of this
covenants research sub-bullet from the news item, was that as part of AJ's
critiquing of Rusty Russell's approach for combining these simple opcodes to do
some additional scripting work, he notes that that combination of those simple
opcodes is still, "Fairly crippled".  And then he goes on to point out that if
you wanted to do something more of an overhaul, he's got a playground for a
Lisp-style alternative to Bitcoin Script, which I think he's borrowed from the
Chia project.  And if folks are interested in what AJ's been playing around
with, we link off to some of the prototyping that he's done with that.  That is
also from the Newsletter #191, if you want to look that up as well.

**Mark Erhardt**: Yeah, I don't want to discourage anyone to play around with
that if they're interested, and there's a lot of stuff going on.  A few things
have already been merged to Inquisition.  There's of course the long-term
ongoing work on Simplicity, which may or may not eventually become a flavor of
how you can do miniscript maybe.  So, well maybe that's a little conjecture!
Anyway, if you're interested in this and you're trying to build cooler smart
contracts on the blockchain, you should absolutely play around with this and
have an opinion on this; it's just that I don't!

**Mike Schmidt**: Well, it sounds like you do have an opinion on it.  Maybe you
might classify yourself as a Bitcoin Script boomer, and that you think that
things are fairly okay as is.  If there's any audience commentary or questions
on these scripting-related topics, feel free to request speaker access.

**Mark Erhardt**: I feel misrepresented at this moment, (a) I'm not old, (b) I
think that a bunch of the things that we could do to scale more and -- if we
continue to be very defensive about the total size of the blockchain and the
block size, I think we will eventually probably increase the block size, but it
will always be a limited resource.  I think it's also super important that we
make the entire ecosystem aware that it will always be a limited resource and
grow against that limit, in order to tap that ingenuity that comes from
necessity.  But having a more powerful scripting language in the long run and
adding some way of introspect will enable us to do a plethora of new scaling
methods that we can probably not even fathom yet.  And eventually, if we
actually want to onboard billions of people to Bitcoin, we will probably not be
able to do that with 3,000 dumb transactions per block.  So, our transactions
will need to be more expressive.  I just don't really have an opinion on what
exactly the flavor of expressiveness is going to be.

So, I leave that to people that are dedicating themselves to be excited about
that, and I hope that when they are a little more confident in their idea of
prototype, that we can have a discussion about it as an ecosystem.  I don't
know, I do wallet stuff, I don't do Script stuff.

**Mike Schmidt**: We can move to the second sub-bullet of continued discussion
about scripting changes, which is the OP_CAT proposal, that we highlighted with
Ethan and Armin as guests last week, who gave us an overview of that proposed
BIP for the OP_CAT opcode.  So, refer back to their discussion for an overview
there.  It seems like a lot of the discussion since that initial post has been
related to this 520-byte limit on the size of stack elements, potentially
inhibiting the expressiveness of OP_CAT.  And I think there was some discussion
about when that 520-byte limit was even put in place.  I think initially, Ethan
had put in his mailing list post that tapscript enforces that, and Greg Sanders
noted that it's not related to tapscript, but in fact was part of the change
that we talked about last week, in relation to a Stack Exchange question about
disabling a bunch of opcodes back in 2010.  And actually, that same commit was a
commit that put in the 520-byte limit.  And so check that Stack Exchange
question from last week, check that commit.  That's where that 520-byte stack
element size limit was put in place.

So, there's some commentary from the wizards, including AJ pointing out memory
concerns as there were higher limits, and he gave some example numbers there;
Andrew Poelstra also quoting, "In my view, 520 feels limiting provided that we
lack rolling SHA2 opcodes".  So, that's a couple things that I took away.
There's a ton of responses, a lot of them discussing this 520 limit.  Murch, any
thoughts about OP_CAT; or, if any listeners have thoughts about OP_CAT?

**Mark Erhardt**: I do not.

_LDK 0.0.118_

**Mike Schmidt**: Okay.  Moving on in the newsletter, Releases and release
candidates.  Two this week, the first one is LDK 0.0.118, which adds BOLT12
sending and receiving as an alpha feature in LDK, and BOLT12 is the author's
protocol for requesting invoices over LN.  There's also some changes around
feerate prioritization, moving LDK from a somewhat crude low, medium, high
feerate prioritization to use-case-specific priority naming for feerates.  So
for example now, in this release, OnChainSweep is the equivalent of
HighPriority, and there's a bunch of other use-case-specific definitions.
There's actually a conversion table in the release notes listing out the new
priority variants and comparing those to the old priority variants.  There's
also some changes in this release of LDK, which expands the mitigation against
transaction cycling attacks, which we talked about previously, and in addition
to some other API updates and bug fixes.  Murch?

**Mark Erhardt**: Yeah, I also wanted to stress that in the newest LDK release,
the big change is the confirmation target, and I had a comment on confirmation
targets generally.  I've always found the low, medium, high thing a little
strange because it's so ill-defined.  I've been wondering why people don't
generally express confirmation targets in times.  Sure, there's room for blocks,
but blocks aren't actually that interesting unless you're talking next block.
For the most part, people are interested in, "I need this confirmed in the next
hour, I need this confirmed in the next half day, I need this confirmed at the
end of the week", or something like that, which of course could be translated
back to an expected number of blocks.

But what is low, medium, high, and what is a block number?  It just seems much
more reasonable to express confirmation priorities in, "Until when do I want
this to be confirmed?"  So, anyway, people working on fee estimation or wallets,
I'd be curious if you've considered that before, or probably you have, but maybe
people should consider it more!

_Rust Bitcoin 0.31.1_

**Mike Schmidt**: The second release we mentioned was to the Rust Bitcoin
repository, 0.31.1, and that bumps the versions of a bunch of dependencies in
Rust Bitcoin.  It also includes 29 API-related improvements, and there's also a
few error-handling improvements that were included with that as well.
Obviously, see the release notes if you're using Rust Bitcoin to see what's
changed there.  There's also a bunch of variable renamings and moving of
variables.  So, if you're using Rust Bitcoin, you'll want to check that out.

There is a third release that we mentioned, but did not link to.  We had a note
in the newsletter about Bitcoin Core 26.0rc1, and the note was related to a
delay in getting the binaries released, and that delay was related to a change
by Apple, which affected the ability to create reproducible binaries for macOS.
I have a couple of notes that I pulled out of issues and PRs, but Murch, I don't
know if you want to give a summary of this, if you're aware of the details of
the issue?

**Mark Erhardt**: I'm not aware of details of the issue, I just know that this
is something that achow's been looking into because, I don't know, signing
binaries is difficult in the Apple ecosystem.  We have a whole separate process
for that, and every time there's a release, since it's been half a year since
the prior, there's sometimes a learning curve to dig in.

**Mike Schmidt**: Maintainer, Fanquake, noted on the release schedule for 26.0
issue, in the repository yesterday, that version 26.0rc1 was basically dead on
arrival due to an issue with the macOS codesign binary.  This has been fixed and
a number of bug fixes were also backported, and that version 26.0rc2 has now
been tagged.  It seems like the issue is related to Guix code-signing.  There's
a PR, Bitcoin Core #28757, that fixes this.  The title of the PR is, "Guix: Zip
needs to include all files and set time to SOURCE_DATE_EPOCH".  So, it seems
like there was some mismatch in terms of what I guess the Apple codesigning was
expecting relative to some of these files and these times of these dates that
were included with the Guix previously.

**Mark Erhardt**: Also, we talked a little bit in detail about the content of
the upcoming 26 release, so we've done this game before.  But if you use Bitcoin
Core, especially if you use it for a business product, we encourage you to test
the release candidate, obviously if you have it preferably in your
non-production setup.  And one thing that is coming is a testing guide.  We have
a contributor that is looking into writing up a few ideas of how you can put the
new release candidate through the works.  But otherwise, if you're already
interested or have multiple nodes, some of which are sort of staging and testing
setups, then you could throw the release candidate up there and just see if
something unexpected happens; put it through the works of what you do usually
with Bitcoin Core.  So, if you find anything interesting, please let us know.

_Bitcoin Core #28685_

**Mike Schmidt**: Moving on to Notable code and documentation changes, Bitcoin
Core #28685 fixes a bug in the calculation of the hash of a UTXO set.  We spoke
with Fabian last week, who is the author of this bugfix PR, and also helped
discover the original bug.  And he went into detail last week on the bug, some
history around that, and the proposed fix at the time.  So, check that out in
Podcast #274, I think we went into some good detail there.  Murch, I don't know
if there's anything you'd like to add to that.

**Mark Erhardt**: I just would stress again that it is a breaking change, so if
you rely on the hash of the UTXO set as returned by gettxoutsetinfo, then you
should have a look at that.  And if you need more time for it, I think was what
Fabian said, you should reach out and let us know.  But other than that, my
understanding was that nobody depends on this hash, or at least nobody had come
up yet.  So, just be aware there's a breaking change here in this RPC.

_Bitcoin Core #28651_

**Mike Schmidt**: Next PR is Bitcoin Core #28651 and, Murch, this is talking
about miniscript and estimating bytes that will be needed to fulfil witness
structure in a taproot output.  So, I thought that you would be great at
explaining this one.

**Mark Erhardt**: Yeah, so given that many script is essentially used to express
more complicated possibilities of how to spend an output, and you can totally
code up a more complex script tree, where you have many leafscripts that can be
used under different conditions, it is not completely trivial to estimate what
the input size of a miniscript-based output would be.  And the way that we do
that is we just walk the whole script tree and check out for what conditions are
met already and what we can spend, and then estimate the input size and
especially the witness size for that input.  I think it's even more complicated
if you have an external signer, because you might not completely know what the
external signer has access to.

So anyway, darosior, Antoine Poinsot, he put a lot of thought into this and that
got shipped, and there's a small improvement following that.  I think it was
last or second last week that we talked about a mini tapscript.  The follow up
here is that, well, signatures in tapscript, or rather schnorr signatures as
used by Bitcoin, are smaller than ECDSA signatures, and we also have a
difference in the size of pubkeys because we use x-only pubkeys in the context
of tapscript.  So, the estimation for the input sizes was previously just using
the same code as P2WSH, and that was off by a few bytes in these two instances
in particular, and that was fixed in this commit.

_Bitcoin Core #28565_

**Mike Schmidt**: Bitcoin Core #28565, it makes the previously hidden
getaddrmaninfo RPC not hidden anymore.  The RPC was originally hidden as it was
thought it would just be of use to developers, but after some discussion and
since there wasn't any risk of users causing issues for themselves by using it,
it is now being unhidden with this particular PR.  But the underlying PR that
actually provides the getaddrmaninfo is #27511, and that RPC provides summary
counts of the nodes' peer database segmented by network, so IPv4, v6, Tor, I2P,
CJDNS.  It segments the nodes' peer database into those different categories by
network, and it also shows the peer addresses that have been either designated
as new or tried.  Murch, I'll pause there before I continue, to see if you have
anything to add so far.

**Mark Erhardt**: Please continue.

**Mike Schmidt**: Okay, so now that you see these summary counts, why would
something like this be useful; why do you care how many peers in your database
are new or tried?  Well, the reason that data might be useful goes back to a
discussion we actually had with Martin, who is the author of the PR that made
this data available back in Podcast #237.  We talked about a PR Review Club that
got into the details of why you'd want to expose this data.  So, look back at
Newsletter #237 as well as Podcast #237.  And as a summary of the motivation of
why this data might be useful in the future, quoting from the PR Review Club,
"On a longer timeframe, this is also a first preparatory step towards more
active management of outbound connections with respect to networks.  One of the
goals is to always have at least one outbound connection to each reachable
network".  So, in order to facilitate that goal of having one outbound
connection to each reachable network, you needed to have some sort of insight
into the information about peers segmented by those different networks.

**Mark Erhardt**: Didn't we report last week or two weeks ago that this has been
merged now?  I'm pretty sure that's in there now.  So, we actually now in
Bitcoin Core will protect the last connection to a specific network.  So, when
we go through peers that we're replacing, we will never replace our last
connection to one of the -- if you have a node that is connected to multiple
networks, it'll keep open the last connection to each network.  So why, maybe in
a more abstract way, why this is all interesting is, there's been a bunch of
research over the years with various, mostly academics, looking at what could
happen to your node's connectivity, for example, if you are subject to an
internet-level attack or if someone is attacking the endpoints of the Tor
Network.

So, by having the nodes that bridge directly between networks, you can, for
example, defeat an attack that cuts off access to all the endpoints on the Tor
network, the exit nodes.  So basically, when Tor was originally introduced in
Bitcoin Core, I think it used Tor only to route through it to obfuscate the
source of a node connection.  But then, attackers could just poison exit nodes
basically by routing through the Tor Network and sending junk, and then Bitcoin
Core nodes would ban the Tor exit node as the parent source of that junk.  And
by basically just iterating off over all the Tor exit nodes and running one Tor
exit node yourself, you could monopolize all traffic through Tor nodes, and even
since Bitcoin traffic is unencrypted, change it.

So, we actually hosted last week the Bitcoin Research Day here at Chaincode
Labs, and we had three topics in the morning on P2P.  We will have some videos
coming out, I think.  And we had actually three speakers that explored this
topic further.  There was an academic that was looking at it more from the
academic research side and internet-level segmentation attacks, and then there
was a developer that talked about it from what code mitigations are put in place
to defend against these attacks.  And then there was also Ethan Heilman, who
went over a history of the, well, sort of eclipse attack surface through Erebus
and other papers, and over the years, which academic papers and other research
had been done to discover attacks, and what code changes that had been prompted
in Bitcoin, and how to defend against them.

So, if people are interested in that sort of topic, there's going to be a few
videos coming out that look at this, and I especially enjoyed the overview talk,
if you're interested in getting into the topic.

_LND #7828_

**Mike Schmidt**: Excellent.  Thanks, Murch.  Next PR is LND #7828, and this PR
is actually titled Pong Enforcement, which I thought was a pretty cool name for
a PR.  With this change, LND requires that its peers on the LN respond to its LN
protocol ping messages within a reasonable amount of time, otherwise they'll be
disconnected.  The point of pinging nodes periodically and looking for a pong
message back from your peer, according to and quoting from BOLT1 is, "In order
to allow for the existence of long-lived TCP connections, at times it may be
required that both ends keep alive the TCP connection at the application level".
So, that's the original motivation for having something like ping and pong
messages going between nodes.

But benefits of this particular change in this PR is that it reduces the chance
that there would be a dead connection that can't even respond to a ping request.
So, that would obviously stall a payment and potentially trigger an unwanted
channel force closure.  But some other things that we noted in the newsletter
writeup that are benefits of these LN ping-pong messages are, (1) they help
disguise network traffic, since ping messages and pong messages are encrypted
just like payment messages, (2) the usage of periodic ping messages serves to
promote frequent key rotations as specified in BOLT8, although I think the
newsletter says BOLT1, but BOLT1 actually just points to BOLT8 in terms of
specifying the key rotation that goes around that.

A last benefit, particular for LND node implementations is that the block header
at the chain tip is included as an additional check in the ping information, and
that helps ensure that the peer node can verify that they're on the right chain
and not being eclipse attacked.  So, a lot of interesting benefits to just
pinging and ponging on the LN.

_LDK #2660_

Next PR is to LDK, it's #2660, and this PR is part of the effort that we
outlined earlier for the LDK 0.0.118 release, allowing for more flexible feerate
estimates.  So, this PR that we mentioned now is actually in the release that we
talked about earlier that Murch was riffing on the way to express feerates in
terms of high, medium, low versus other more sophisticated methods.  One thing
that I thought was interesting that's non-technical to highlight about this, is
that this PR came from a soft piece of software that's using LDK, so a piece of
upstream software that's using LDK.  And instead of just opening an issue, one
of the developers of that software actually opened this PR, because that's
something that they wanted to see and use, and so they put this into LDK.  So, I
thought that was an interesting note as well.

**Mark Erhardt**: That is called upstreaming it, and that's a good practice.
So, if you are looking at an issue that should be fixed at a higher level, like
at the original of some piece of forked software or in a library that you're
using, if you upstream it, you're benefiting a much larger population of users.
That's not always useful.  If it's really something that only concerns you, you
should fix it downstream in your own software.  But yeah.

**Mike Schmidt**: If you have any questions, we're getting into the last PR
summary here.  If you have any questions, feel free to request speaker access,
and we can get to your question after this summary.

_BOLTs #1086_

Last PR, to the BOLTs repository, #1086.  From the PR, "This proposal suggests
to adopt a common value between all implementations, dubbed max_htlc_cltv".
Originally, the PR had a default value of 4,032 blocks, which is about four
weeks, but the PR actually ended with that being 2,016 blocks, and that was
based on the historical value that all the LN were already using.  So, if you
drill into this PR, you'll actually see that not too much changed in the BOLT.
The BOLT already had wording that was, "If the cltv_expiry is unreasonably far
in the future", so that "unreasonably far" was undefined in the spec.  And this
PR changes that to say, "If the cltv_expiry is more than max_htlc_cltv", so it
provides some defined conditional instead of just saying "unreasonably far".
And then, that variable is defined as 2016 blocks.

Then there's some discussion here on the give and take between having a high
htlc_cltv value, which mitigates certain types of attacks, and then having too
small of a value, which can mitigate against other attacks.  Murch, any thoughts
here?

**Mark Erhardt**: I think not just attacks are affected by this, but there was
also some recent discussion about whether or not you should have and use HODL
invoices.  And HODL invoices basically allow, I think it's the second last hop
to hold a payment for you for a long period of time, and then enables the
endpoint to come online only sporadically to collect any waiting HODL invoices.
And so, for everyone else downstream, that looks of course like a stuck payment.
And there was some discussion of whether or not it is abuse to use HODL
invoices.  I think in that context, I think it was Super Testnet that proposed,
"Well, you could run two nodes and one node has higher fees and longer
expiration times on their channels, and the other node has shorter expiration
times and lower fees, and that way you could make people pay more if they want a
longer expiration time".

But yeah, I just saw that in this context.  Other than that, it sounds pretty
long to have a channel stuck, or sorry, a Hash Time Locked Contract (HTLC) --
that's why it sounds weird -- HTLC stuck for two weeks until you get your money
back.  So, anyway, on the other hand, of course, the recycling attack, the
replacement cycling attack -- I'm not very well prepared today!  We've been
talking a lot about the replacement cycling attack in the past few weeks, and of
course that's also affected by how long you can hold an HTLC.  And longer HTLC
times make you safer against this attack.  So, anyway, there's multidimensional
considerations here for what value you might want to have.

**Mike Schmidt**: I don't see any questions or comments from the audience.  So,
Murch, thanks for joining me as always, and thanks for you all for paying
attention to this newsletter and the discussions of some of the Bitcoin
technicals, and we'll see you next week, Murch.

**Mark Erhardt**: See you next week.

{% include references.md %}
