---
title: 'Bitcoin Optech Newsletter #330 Recap Podcast'
permalink: /en/podcast/2024/11/26/
reference: /en/newsletters/2024/11/22/
name: 2024-11-26-recap
slug: 2024-11-26-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by ZmnSCPxj, Vojtěch Strnad,
Moonsettler, Brandon Black, Ethan Heilman, and Dusty Daemon to discuss [Newsletter #330]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-10-26/390527412-44100-2-293cd1da56e55.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #330 Recap on
Twitter Spaces.  Today, we're going to talk about pluggable channel factories,
we're going to talk about an activity report on what's going on on signet, we're
going to talk about updates to the LNHANCE proposal, there's an interesting
paper that's been published about covenants based on grinding rather than
consensus changes, we have four interesting ecosystem software updates, we have
our usual segment on Notable code changes including an interesting splicing PR
that we'll get to.  I'm Mike Schmidt, contributor at Optech and Executive
Director at Brink, funding Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs.

**Mike Schmidt**: Rearden?

**Brandon Black**: Hey, I'm Rearden, I work at Swan on the Swan Vault product,
and I do open-source Bitcoin stuff when I have time.

**Mike Schmidt**: Ethan?

**Ethan Heilman**: Hi, I currently work at Cloudflare, and I do a lot of work
unaffiliated with Cloudflare on Bitcoin.

**Mike Schmidt**: Moon Settler?

**Moonsettler**: Hello, everyone, I'm basically trying to champion the LNHANCE
proposal, so that's kind of my thing.

**Mike Schmidt**: ZmnSCPxj?

**ZmnSCPxj**: Hi, I'm ZmnSCPxj, I'm a randomly generated internet person who
happens to now work at Block as a Lightning subject matter expert.

**Mike Schmidt**: Vojtěch?

**Vojtěch Strnad**: Hey, I'm Vojtěch, I occasionally develop open-source Bitcoin
tools.

**Mike Schmidt**: And I think we'll have Dusty on, hopefully he can join us
later, and we'll hopefully remember to have him introduce himself as well at
that point.  Well, thank you all for joining us.  We're gonna go through the
newsletter sequentially here, starting with the News section.  We have four News
items.

_Pluggable channel factories_

First one titled, "Pluggable channel factories".  ZmnSCPxj, you started your
post on Delving Bitcoin saying, "As proposed in my SuperScalar document, I want
to create an extension supported by common node software for 'pluggable channel
factories'".  Optech covered your SuperScalar proposal in Newsletter #327, and
you, Dave Harding, and I did a deep-dive podcast on SuperScalar a couple of
weeks back as well, so if people want to listen to that or reference back to
that newsletter to get up to date on SuperScalar, please do that.  So,
SuperScalar is a channel factory proposal that uses timeout-trees.  And
ZmnSCPxj, from your post, it looks like you're looking to create an extension
that can be used by Lightning node software that would support not only
SuperScalar channel factories, but other kind of channel factories as well.  Do
I have that right?

**ZmnSCPxj**: Yes, that's the proposal.  So, the thinking here is that we are
not even sure that SuperScalar will work.  So of course, if you're going to hard
code a channel factory protocol into the node software, that turns out to be
less optimal than a future proposal, then that's sort of wasted effort.  That's
going to be a maintenance burden afterwards.  So, the hope here is to have a
minimal set of changes that can be used for a variety of different channel
factory schemes, hopefully as best as we can imagine them, and hopefully it can
be used for SuperScalar.  And if in the future, we figure out a better way of
creating channel factories, then we can also hopefully reuse the same scheme.
So, what we only need to do is basically to plug in a different channel factory
protocol, and then we'll be able to use this new scheme rather than SuperScalar,
or something similar to that.

**Mike Schmidt**: What would be involved in creating an extension?  Like, to
talk about that, is that specific to each implementation?  Is that something
that's standardized?  What needs to go into it?

**ZmnSCPxj**: Okay, so basically you will still need messages between the nodes,
and those messages between the nodes are there to coordinate.  Like, for
example, the plugin of this particular node claims that this will be the next
state of the channel factory.  And if the base node software will send a message
to its counterpart, which checks its own plugin to determine if they agree.  If
they don't agree, then of course there's a problem and probably we need to raise
some alarms or something.  So, we do need some additional messages on the bulk
layer in order for the base node software to coordinate.  So, each
implementation would need to agree on a specification on what those messages
are, but how it communicates to its own plugin will depend exactly on the exact
node software.

**Mike Schmidt**: And what has feedback been so far on this idea from the
different implementations?

**ZmnSCPxj**: There has not been any feedback at all.  So, yeah, in any case,
I'm creating a spec document for this, which I hope to create a PR in the BLIP
repository and maybe get some more detailed feedback for that.

**Mike Schmidt**: Don't you have BlueMatt's ear over there on the LDK team?

**ZmnSCPxj**: Yeah, BlueMatt is there, but he hasn't responded much about it
yet.

**Mike Schmidt**: Okay.  Murch or any other guests, do you have questions about
ZmnSCPxj post?  I see Bob is requesting speaker access.  Hey Bob!

**Bob McElrath**: Hey guys, how's it going?

**Mike Schmidt**: Doing well.

**Mark Erhardt**: Bob, did you have a question about the pluggable channel
factories news item?

**Bob McElrath**: I did not, I just joined in the middle of that conversation,
but looking forward to hearing the rest of the talk.

**Mike Schmidt**: ZmnSCPxj, what would your call to action be for the audience
of potential Lightning users or developers or node contributors?

**ZmnSCPxj**: Yeah, I'd like to have some feedback on this basic concept.  Like,
is this something that is considered useful?  I think it's something that is
useful because we do want to be able to change exactly what the channel factory
will be, because we cannot really be 100% certain that SuperScalar is the be-all
and end-all of all channel factory schemes.  So, I do want to have some feedback
on whether people do actually want to implement something like this.

**Moonsettler**: It sounds good to me, to be honest.  Of course, I'm more in
favor of having consensus changes, but it sounds like that you would be able to
plug in any sort of channel factory using any new process or features to this.
So, it sounds like awesome work.

**ZmnSCPxj**: Yeah, even with consensus changes, you do still need some way to
coordinate the channel level software, you know, the software that handles
channel level state versus the software that integrates with some kind of
multi-party scheme, whether that scheme requires a consensus change or not.

**Mike Schmidt**: ZmnSCPxj, while we have you, maybe quickly, have there been
any updates to SuperScalar and the way you're thinking about it since we last
covered SuperScalar?

**ZmnSCPxj**: No, basically what I'm doing now is focusing on these pluggable
channel factories.  Currently, what LDK is doing is they're focusing on actually
implementing splicing and like I pointed out, the splicing code can probably be
reused or at least much of the flow of splicing can be reused for pluggable
channel factories.  So, I guess what they're trying to do now is implement
splicing first, and then from there we can look at modifying the splicing code
to support pluggable channel factories.

_Signet activity report_

**Mike Schmidt**: ZmnSCPxj, thanks for joining us.  You're welcome to stay on,
or if you have other things to do, we understand.  Next news item from the
newsletter, Signet activity report.  And this news item was spurred by a Delving
post by AJ Towns.  It included a bunch of statistics around the usage of
software proposals that have been activated on the signet test framework for
some time now.  BIP118, which is ANYPREVOUT (APO), and BIP119,
CHECKTEMPLATEVERIFY (CTV), they've both been available for use on signet through
AJ's Bitcoin Inquisition for the last two years, and BIP347, OP_CAT has been
available on signet for the last six months.  So, AJ posted a bunch of example
usages of these different soft forks activated on signet proposals and theorized
to the reason they were used in certain scenarios.  Murch, I think you maybe
dove a little bit deeper into this, and I know, Vojtěch, you built a tool on top
of this as well, so I'll open up to either of you to jump in on this.

**Mark Erhardt**: Yeah, let me take a start here.  So, my understanding is that
APO has been used in about 1,000 transactions on signet.  It looks like there's
a few tests of LN-Symmetry, but most of these uses of APO are more like to
simulate CTV.  CTV itself appears to have been used 16 times before this report.
Someone started since again.  There seem to be 14 more transactions, which I
learned from Vojtěch's inquisition.observer.  And those CTV users seem to be
mostly related to primitive vault tests, and someone also put a RickRoll in
those CTV transactions.  And then I saw that CAT has the most transactions,
that's about 74,000 transactions that use CAT.  Obviously, there's AJ's
proof-of-work faucet.  So, I think every block that he mines at least puts some
money into proof-of-work faucet outputs.  So, a ton of those transactions are
related to that, because someone is collecting these every block.  And then,
there appear to be some STARK verification experiments, and I think something
that looks like maybe the purrfect vault being tested or some other
CAT-checksig- based introspection like vaults or covenants.

Anyway, there's CAT scripts with some 143 opcodes there, so I assume it's
something like a vault or covenant.  Yeah, so that's all I had.  Vojtěch, you
made an explorer.  I assume you looked more at this stuff.

**Vojtěch Strnad**: Well, I didn't really look at what the different use cases
for the different soft forks were.  I just implemented the index for collecting
all the transactions with the different soft forks.  AJ actually posted a patch
for Bitcoin Core that he used to collect these.  It seems unnecessarily
complicated.  So, my tool works with just any signet node.  It doesn't even have
to be an Inquisition node.

**Mark Erhardt**: Okay, cool.  So, you built the tools for someone to look at
this more.  You didn't actually analyze it much yourself.  Did anyone else look
more into this?

**Brandon Black**: I didn't look closely at it, but I did have a comment, which
is just that it is interesting with regtest being very popular these days, you
want to use signet whenever you need to test an actual multiparty interaction,
things like channel closes and things like that.  But for a lot of the testing
that used to go on a signet or testnet, regtest is actually a better platform
because you get reliable, consistent block times, etc.  So, it's interesting to
see what we're learning here with signet tests is where people think they need
to test kind of multiparty interactions with a new opcode, as opposed to where
people are testing new opcodes or even CAT scripts or whatever in general.

**Moonsettler**: Yeah, I'm personally a little bit disappointed that Ark was not
built out on Bitcoin using CTV.  I think it would have been a very interesting
and valuable experience because that's really like a multiuser thing and very
interactive, and there would have been a lot of volume in testing that out on
signet.  We are currently looking to get all the others on signet as soon as we
can, and we are hoping that once we have the Lightning signet implementation,
that we want to demonstrate will be observable to everyone on these signets.  So
right now, all the opcodes are live Mutinynet signet, and we are looking to at
least two more short term.  I'm not sure when the opcodes will be available on
Inquisition, that's a bit harder.  But like I said, we are working on both
finalizing the code, the BIPs, and getting them on signets, and then getting
people to deal with them and experiment with them interactively.

**Mark Erhardt**: Yeah, I have a follow-up question here.  So, a lot of the
theorized use of CTV was either vault or some multiparty transactions where
interactions could be sort of pre-painted into the future.  So, when you test
that on regtest, you just simulate all the parties yourself.  But wouldn't
showing off CTV on signet be a good use case to -- it's very hard to show off
regtest, right?

**Brandon Black**: Yeah, I think the vaults are easy to test on regtest.  The
multiparty stuff, there hasn't been working code for really.  And I mean there's
been Sapio, but only Jeremy knows how to work with Sapio really.  So, yeah, I
think you're absolutely right.  It's just that the code hasn't been in a place
where other people can work with it for those interactive multiparty protocols
with CTV.

**Moonsettler**: Yeah, I think that's another problem that I forgot about, that
people can't really get Sapio working, building, as far as I know.  Last time I
tried, I failed.  And that's probably also what leads to this underutilization
of CTV, because that was kind of the only user interface actually doing CTV
stuff on signet available for a good while.  Of course, that can change and
probably will change in the future.

**Mark Erhardt**: Vojtěch?

**Vojtěch Strnad**: Yes, so I'm glad to hear that people are going to use the
signet for testing the soft forks like CTV, because testing on regtest is nice,
but it doesn't let anyone else see the transactions.  And before I created the
inquisition.observer, trying to see the transactions on signet was also kind of
tedious.  So, I hope this will provide some visibility to people who are testing
this stuff in public.

**Brandon Black**: I think it's great.  It gives motivation to do it in public
too, and people are actually going to see it.

**Mark Erhardt**: All right.  Anyone else on this topic?

**Bob McElrath**: I want to advertise real quickly.  There is one more testnet
that I made.  This is mostly for testing Braidpool.  We need the proof of work
and we also need the difficulty adjustment to be normal.  And we don't want to
have transaction floods when people plug in a money device.  So, I just modified
the proof of work, I added a string to the end of the proof-of-work header,
that's all that it is.  This week, I modified Rust Bitcoin and Rust Bitcoin Core
RPC.  You can find these in the Braidpool repository to interact with cpunet and
check the proof-of-work header properly.  If this is of interest to anybody, I'd
love to see more people using it, if you need retargeting for blocks in a steady
stream or proof of work.

**Mike Schmidt**: Bob, you cut out there for a second, but I think you did
mention it.  It's cpunet is the alternate test network, right?

**Bob McElrath**: Correct, yes.  It is a fork of Bitcoin.  Unfortunately, I
can't really merge this into Bitcoin very easily because of the way Bitcoin is
structured and the way it checks its proof-of-work header.  So, there are forks
in the branch cpunet in the Braidpool repository, if this is of interest to
anybody.

_Update to LNHANCE proposal_

**Mike Schmidt**: I think we can move to our next news item titled, "Update to
LNHANCE proposal".  Moonsettler, you posted a post titled, "OP_PAIRCOMMIT as a
candidate for addition to LNHANCE".  Rearden, since we have you on, maybe you
can give the audience a quick summary of your original LNHANCE proposal, and
then we can have Moonsettler explain OP_PAIRCOMMIT and why it would be a good
idea to add to LNHANCE?

**Brandon Black**: Yeah, for sure.  So, LNHANCE is a proposal I made about a
year ago, I guess, to combine CTV, CHECKSIGFROMSTACK (CSFS), OP_INTERNALKEY, and
CHECKSIGFROMSTACKVERIFY originally.  Yeah, four opcodes, but I put them in a
weird order there.  And the point was to do things that make Lightning better.
So, it supports LN-Symmetry, it supports enhanced Ark.  At the time, we thought
it was needed for Ark, but now we know that there's ClArk out there, so you
don't need something like this for Ark, but it makes Ark work better.  It also
improves the scripts for PTLCs (Point Time Locked Contracts), things like that.
So, it's basically a proposal to make Lightning better, better endpoint
solutions, etc.  And then, of course, along with that, it does all the other
stuff that CTV does that are more speculative.

As we were developing a LN-Symmetry based on LNHANCE, we talked with Greg
Sanders and realized that the way he solved a certain data availability problem
in LN-Symmetry was by abusing or using, depending on your perspective, the annex
on signet.  And because CTV does not commit to the annex, we couldn't use that
same trick to build LN-Symmetry for LNHANCE.  And we then spent the following,
whatever, ten months agonizing over whether LNHANCE should include CAT to solve
that same problem or add the Annex to CTV, or something else.  And then that's
where PAIRCOMMIT comes in, So take it away, Moonsettler.

**Moonsettler**: Yes, so basically the entire idea is nothing new.  Like Rearden
said, we have been working around this over a year, I believe.  A lot of things
have been discussed.  Basically, one could think of the four current opcodes of
the LNHANCE family as one super-opcode that has been decoupled so that the code
is simpler, it's easier to understand and these individual pieces are more
composable for other use cases and more compatible with additional upgrades that
Bitcoin might receive in the future.  For example, like CHECKCONTRACTVERIFY
(CCV) and introspection opcodes.  And basically what happens, or maybe one way
that one could describe the LNHANCE family of opcodes is that we basically took
APO, the functionality that APO provides, and we decoupled the sighash check
from the signature check, that is CTV and CSFS.  And if you have a super-CSFS
that can use a 1-byte public key to interact with the taproot internal key, just
like I believe the APO does, then the APO can also point to the annex for data
availability.  Although this is probably going to be a controversial thing if
anyone wants to proceed with that.  I might return on that later.

But the point is, right now, by relay policy, it's not really workable to use
the annex for these things.  And basically, PAIRCOMMIT allows to commit to
multiple stack elements, to sign multiple stack elements as a package.  And we
use this for the data availability instead of the annex.  So, it's really just a
CSFS that could use a 1-byte public key and could sign multiple stack elements
as a message.  If you take that apart to individual pieces, then you get CSFS,
INTERNALKEY and PAIRCOMMIT.  So, that is really the LNHANCE proposal.  At its
core, it's just CTV plus CSFS.  And it helps a lot with doing covenant pool tree
stuff, like Ark and other similar proposals.  And also, we believe it's the best
possible, most efficient possible implementation of LN-Symmetry that we know of
currently.

**Brandon Black**: Yeah, and I wanted to add about PAIRCOMMIT.  We're talking
about CAT versus PAIRCOMMIT, and I've seen the feedback, "Oh, you should just do
CAT for this rather than PAIRCOMMIT".  And my response to that is that
PAIRCOMMIT is better for this job than CAT.  CAT has this footgun, which is one
of the reasons we were hesitant to use it, which is that if you just use CAT to
commit to two pieces of data and you're like, "Oh, I got two pieces of data, CAT
them together", you could end up in the situations where you accidentally make
your script an ANYONECANSPEND.

The quintessential example of this is you're going to commit to a locktime and a
CTV hash or a locktime and a key, and keys and CTV hashes are either NOPs or
automatic success on the signature check, not OP_SUCCESS, if they are different
length than 32 bytes.  And so, if you shift 1 byte either from the key to the
locktime or from the locktime to the key, depending on exactly what you need to
do to keep the transaction valid, you elide the CTV check or the signature
check.  And so, CAT has that footgun in it, where PAIRCOMMIT takes that away and
says you can safely commit to multiple things with this.  And of course, if you
need to commit to more than two items, you can iteratively apply PAIRCOMMIT.

The other thing that that then leads to is that PAIRCOMMIT can be used for
verifying merkle proofs efficiently, which could be used for other
constructions.  But the central thing is to safely commit to multiple items,
whether with an equality check with a hash lock or with a signature check with
CSFS.

**Moonsettler**: Yes, and I would like to mention that it was, there have been a
lot of candidates for this.  We actually went through a whole bunch of
possibilities that would be super-composable with other things, other
improvements in the future and other features.  But we ended up on doing
PAIRCOMMIT because we actually wanted to be very deliberate and very specific
over the behavior that we want to enable.  And basically, it's the polar
opposite of CAT, even though the source code of PAIRCOMMIT and CAT is like 99%
the same, if you look at it.  They are the polar opposites in the sense that
CAT, as people say, sort of enables everything, and PAIRCOMMIT on the other hand
basically enables nothing new in itself.  So, our hope is it is a very
controversial, very easy-to-review change that adds the specific functionality
that we need for efficient LN-Symmetry channels, mainly, and also very easy to
reason about what it actually enables in the future in combination with other
opcodes.

The other end of the spectrum is CAT, which is super-exciting and cool, but also
potentially a lot more controversial and hard to reason about.

**ZmnSCPxj**: I'd also like to add about CAT.  CAT is the Turing tarpit of
opcodes.  A Turing tarpit is something where everything is possible, but nothing
of consequence is easy.

**Brandon Black**: Very well said, thank you.

**Ethan Heilman**: Could I jump in on that?

**Mike Schmidt**: Jump in.

**Ethan Heilman**: So, I'm one of the authors of the CAT BIP, and I think a lot
of what's been said, I agree with.  CAT lets you do a lot, but when you do many
of those things, it's actually pretty difficult to do those things.  I think
someone called it a paperclip the other day.  But there is one thing that CAT is
really good at, which is concatenating two things on the stack.  So, one of the
perspectives at least I've been thinking about with CAT, is that you could get
CAT now as this prototype way of doing a lot of different things, and then you
get the special purpose opcodes to do them once we've learned about it.  But the
flipside of that is if you don't get CAT now, if you just jump to the special
purpose opcodes to do them, you'll probably want CAT later, not to do any of
these general things, but just to concatenate things on the stack, because
that's a pretty useful tool.  So, I think of CAT as like jack of all trades,
master of one, where the one thing is just concatenating things on the stack,
because that's useful.

**Brandon Black**: Yeah, I agree with every word that Ethan just said.  And
PAIRCOMMIT happens to be specifically very useful for one thing, so it's the
time to propose it now.  That is not saying that PAIRCOMMIT is an alternative to
CAT.  It's, we have a specific use that we want right now, and so that's why it
goes there.  CAT is still good, I would like to see CAT in Bitcoin at some point
in the future.  It's just a different conversation because it has this property
of doing many things.

**Mark Erhardt**: Vojtěch has been raising his hand for a while.  Did you want
to say something on this?

**Vojtěch Strnad**: No, sorry, that must be a mistake.  I don't see a hand next
to my profile picture.

**Mark Erhardt**: Oh, maybe it's a bug in my GUI here.  Moonsettler then, you
were starting to say something.

**Moonsettler**: Yeah.  I think I also agree with everything that is said.  We
are trying to make LNHANCE a non-controversial upgrade that receives a wide
community buy-in.  And therefore, like I said, we have spent a lot of time
iterating over various ways of doing the same thing, and we ended up with
PAIRCOMMIT specifically, because it is in itself completely useless, and it is
perfectly suited for the one thing that we actually need it for right now.  And
in the future, it can also be a useful composable tool, but not a substitute to
CAT generally, of course.  That's not a claim that we would make.  And, yeah,
CAT is awesome.

**Mark Erhardt**: I'll just quickly put on my BIP editor hat here and say,
there's a bunch of these PRs that are open right now, and it would really help
if the other people that are interested in these opcodes actually commented on
them.  Some of these have never gotten any comment except for BIP editors and
the authors.  So, if you could weigh in on the review and say -- well, you have
a different set of glasses viewing those, so maybe please take a look at those.

**Mike Schmidt**: Maybe to piggyback on that, Moonsettler, I saw some activity
in the BINANA repository, which is sort of a repository for specifications.  I
saw OP_PAIRCOMMIT is being iterated on there by yourself.  Is that the home for
the work on the proposal?  Should folks follow along there?

**Moonsettler**: There was a phase where the main work, basically the
finalization of the PAIRCOMMIT, how it actually works, was done there with the
awesome feedback from AJ Towns.  So for a while, you could say that the home of
PAIRCOMMIT was the Inquisition repository and the BINANA repository.  But I
think now that we have finalized it, the main home of these proposals is the
LNHANCE repository.  This is an organization of loosely associated individuals
who try to bring these changes to Bitcoin, And we are nevertheless very much
interested in actually activating these opcodes on the Inquisition signet, but
also looking to add them to other signets.  And right now, the BIPs are also
making headway and making progress on them.  I believe the finalization of CSFS
is happening right at this moment and the other opcodes can pretty much be
considered final.  And CSFS also did not officially be actually removed from it.
So, based on feedbacks from remaining in use and long discussions and long
deliberations, again we decided to remove the CHECKSIGFROMSTACKVERIFY feature
from legacy script, because upgradable opcodes are sort of expensive, there is
not very many of them.

We don't actually see a compelling use case for having CSFS because again, the
most optimal way to use these opcodes is going to be in tapscript.  And we also
see a potential that tapscript might actually be backported to legacy and that
would enable all the OP_SUCCESS upgrades to be backported automatically with
that.  And that basically gives the whole LNHANCE functionality to legacy script
anyhow.  So, that seems like a better use of an upgradable model than just
adding CHECKSIGFROMSTACKVERIFY that has all sorts of various issues in legacy
state.

**Brandon Black**: Yeah, so the summary of that is that LNHANCE went from being
four opcodes when I first proposed it with CTV, CSFS, CHECKSIGFROMSTACKVERIFY,
and INTERNAL, and now it's CTV, CSFS, INTERNALKEY, and PAIRCOMMIT.  So, it went
from four opcodes to four opcodes, but I think it's a better proposal now than
it was.

**Moonsettler**: Didn't you originally propose CSFS as something that would sign
n elements on stack?  So, wasn't there a vector?

**Brandon Black**: I can't remember if I ever actually formally proposed that.
I went around on it.  It was one of the options for solving this data
availability problem, was adding a vector commitment to CSFS itself.  And so,
that was one other way we could have gone with getting the right set of
functionality.  But given that tapscript has more available opcodes to work with
and that PAIRCOMMIT, I think you downplayed how useful it is without the other
opcodes, I think that PAIRCOMMIT being able to generally commit to multiple
things and do that in a way that is safe and consistent and predictable is very
useful even without any of the other LNHANCE opcodes, but it's still very
specific.  It's like, if you want to say, the example I came up with recently
with PAIRCOMMIT, you could do a 1-of-n multisig as a merkle tree instead of as
an OP_CHECKMULTISIG or OR_CHECKSIGADD opcode using PAIRCOMMIT, and have a more
efficient 1-of-n multisig.  That's kind of a silly example perhaps, although
with some of the more advanced miniscript while it's coming out, it could be
used there.

So, long and short, I think PAIRCOMMIT is the better solution than CSFS on a
vector or than VECTORCOMMIT or than CAT to get this specific piece of
commit-to-multiple-things functionality into Bitcoin.

**Mike Schmidt**: Moonsettler, Rearden, what's the call to action for listeners
here?

**Brandon Black**: Please review our BIPs and soon, our code.  We have to rebase
some things and get them up to date, but yeah, please review.

**Moonsettler**: Yes, yes, we really need reviews and engagement, and especially
from Lightning and Core developers, who would be the main users of these
opcodes.  Because I think there's a bit of apathy and a lot of energy to engage
with any proposal that is not actually managed and activated.  But their
feedback will be invaluable I believe, when we are actually trying to garner
support for this proposal to be activated.  There has to be some feedback that,
"Yes, this is useful for us, we would love to use this if it was available",
even if they don't go and spend months and months on actually delivering an end
product on a similar listing that it may never actually get activated and they
wasted all that work.  If they just look at it and give feedback and talk about
it in public, that would help a lot.

_Covenants based on grinding rather than consensus changes_

**Mike Schmidt**: Thank you both for joining us this week.  We have a few more
interesting items if you want to hang on, otherwise if you need to drop we
understand.  Last news item this week is titled, "Covenants based on grinding
rather than consensus changes".  Ethan, you posted to the Bitcoin-Dev mailing
list about ColliderScript and research that you, Poelstra, and two researchers
from StarkWare drafted.  The paper outlines how we can have covenants on Bitcoin
today without any soft forks.  Wait, Ethan, what?

**Ethan Heilman**: So, the main idea here, which has sort of been discussed in
some circles for a long time, is that Bitcoin already has arbitrary computation
that's bound only by the size of transactions.  But this arbitrary computation
has one limitation, which I'll explain in a second.  So, the idea with this
paper was to exploit that ability to be able to do transaction introspection.
So, the arbitrary computation that Bitcoin can do is using the math opcodes in
Bitcoin, which only work on 32-bit values.  So, that means that if you take a
signature and encode it as a series of 32-bit stack elements, you can do all
sorts of transaction introspection.  And people have written implementations
using the math opcodes of, like, SHA256.  I know there's a SHA1 implementation
floating around.  So, you can basically do anything up to 4 million math
opcodes.

The two drawbacks are that, one, using the math opcodes to do arbitrary
computation is very inefficient.  Imagine you want to do an exponentiation.
Well, first you have to do a bunch of OP_ADDs to simulate OP_MUL, because OP_MUL
doesn't exist in Bitcoin, and then you have to do a bunch of those simulated
OP_MULs to do exponentiation.  So, the second drawback is this fact that it only
operates on 32-bit elements.  So, if you want to do something like a covenant,
you care about being able to use a signature that passes CHECKSIGVERIFY, and
that signature is going to be 64 bytes, not 32 bits.  And if you encode it as a
bunch of 32-bit elements, it will fail CHECKSIGVERIFY.  So, basically you need
some way of saying, "Is this 64-byte signature the same value, or is equivalent
to, this set of 32-bit stack elements?"

This ability to show equivalence is why OP_CAT or substring are so important,
because if you could just take the 32-bit elements and concatenate them together
into the 64-byte signature, then you could just do equals and then bridge into
this 32-bit realm in Bitcoin Script.  We call this 32-bit realm, 'Small Script'.
Substring would get you the same thing, because you could take the 64-bit
signature and break into 32-bit chunks, but really we need a bridge there.  So,
the idea with ColliderScript was to build such a bridge by exploiting 160-bit
hash collisions.  So, Bitcoin Script supports SHA1 and RIPEMD, which are hash
functions that have 160-bit outputs.  And 160-bit hash outputs are vulnerable to
collision attacks, because the collision strength of a hash function is
equivalent to half of its bit length.  So, if you can do 2<sup>80</sup> hash
queries on RIPEMD-160, you will, with high probability, create a collision.  And
Bitcoin does, I think, 2<sup>79</sup> hash queries per block.  So, it's like 2
blocks' work to create a collision.

The essential idea is that you have this 32-bit representation of a signature
and a 64-bit representation of a signature and you want to prove that they're
equal.  So, the way that you prove that they're equal, because you can't
directly compare them, is you hash the Big Script, the 64-byte signature, and
compare it to the hash of this value d, and then you also compare the 32-bit
value to the hash of this value d.  And it would be perfect if the value d could
just be equal to the signature, we wouldn't need collisions.  But because the
value d is carefully chosen so that you can evaluate in Small Script and Big
Script, and so for this reason you need to create a collision.  This is what
requires the work, the grinding, to be able to prove this equality.

Currently, the work is 2<sup>86</sup> hash queries, which is roughly the amount
of hash queries that the Bitcoin Mining Network does every 33 hours.  You can't
use Bitcoin ASICs, so if you actually want to do this, you'd have to tape-out
your own ASICs.  We have a number of improvements that can make this a little
bit lower, but there's probably a floor without exploiting the cryptanalytic
weaknesses in these hash functions of how low we can make it.  So, that's the
general idea.  I hope I explained it all right.  I'm happy to answer any more
specific questions.

**Mike Schmidt**: Even with these optimizations that you mentioned, it seems
like the cost would be quite high.  Is there a path to practicality here?  How
could this practically be used?

**Ethan Heilman**: So, it depends how low it needs to be to be practical.  My
personal take is that if it costs in electricity roughly equal to 1 Bitcoin
block, maybe that's practical.  It's really what people use it for.  If they're
only doing it for a single spend, that might not be practical, but if they can
batch a bunch of spends into the same covenant…  I think that this is sort of
the beginning of a bunch of techniques that can be used, but we're still in the
Model-T stage of this.  One reason I wanted to get this paper out was to get
other people interested in this line of research and to build upon it, because I
think there's a lot of room here.  One example of some of the room is that so
far when I've been talking about SHA1, I've been talking about it like it's this
ideal hash function.  But SHA1 is actually super-broken.  People have attacks
that I think are really, really low, that are much lower than the 2<sup>80</sup>
queries that we typically think of.

So, if you could conceivably exploit some of those cryptanalytic weaknesses, you
could potentially make this much more efficient.  I'm not saying that that's
possible, and determining whether that's possible is sort of a big project, one
which I'm not taking on.  But I think that there is a lot of room to use these
techniques, and to improve these techniques.  We actually have a number of
improvements that get it down to about 2<sup>84</sup>, which is a 4X
improvement, that we just haven't published, that we hope to get out at some
point.  But I think there's enormous amount of room here for improvement,
probably without exploiting the cryptanalytic approaches.  You're going to get
capped at about 2<sup>82</sup>, which is like maybe 8 Bitcoin mining blocks.
But I think that this paper should be viewed as the beginning of these
approaches, not the end.

**Mike Schmidt**: Ethan, can you talk a little bit more about the surprise
quantum computer use case?

**Ethan Heilman**: Sure, and there's something that is really important to
understand when discussing this.  So, taproot outputs have two ways of spending.
There is the key spend, which is the spend where you just spend it like it's a
pubkey that you're spending; and then there's the script spend, where you post a
script and prove that that script is included in that taproot output, and then
you execute that script to determine who can spend from it.  And it is
definitely the case that the keyspend would be vulnerable to a quantum computer.
So, a cryptographically relevant quantum computer would be able to take funds in
a taproot output via the keyspend.  So, any attempt to use taproot script spend
outputs or script spend must first have a soft fork that disables keyspend or
otherwise we're -- script spend is totally secure, but then keyspend is broken.

So, one thing that you could use for ColliderScript is you could create a
ColliderScript lamport signature and hide it in a script spend tapleaf,
somewhere in that merkle tree.  And then, if it were to be the case that a
cryptographically relevant quantum computer were to come out, and it were to be
the case that Bitcoin, to protect against this, allowed the ability of turning
off keyspends in taproot outputs, then you could use your quantum secure
signature in the script spend tapleaf to still control your funds without being
vulnerable to quantum computing attacks.

**Mike Schmidt**: Brandon?

**Brandon Black**: Yeah, so two things.  One, Ethan mentioned the idea that some
people have ideas about aggregating a lot of activity into a single spend, in
which case the amount of energy or dollars you need to spend to do a single
covenant goes up, because they can aggregate a bunch of activity into one spend.
At OP_NEXT a couple of weeks ago, the StarkWare folks said that even at the
current costs of doing this, it might be practical.  So, using the techniques
that you were mentioning, it will almost certainly become practical for that
kind of aggregate kind of stamping economic activity into Bitcoin type of
covenant.

Then the other thing that was worth mentioning is that Moonsettler just kind of
blew past mentioning earlier the idea of bringing Tapscript to earlier output
types.  And that would be one potential way to get access to these kind of newer
quantum-resistant type of spend paths, would be to bring them to P2WSH, where
you don't have a hardcoded necessary key spend like you do in tapscript.  I'm
not saying that's the right way to get those things.  We could also introduce a
new version of tapscript or disable keyspend, as Ethan said, but Moonsettler had
mentioned it, so I figured I'd mention it again.

**Mike Schmidt**: Ethan, any parting words for the audience?

**Ethan Heilman**: No, well actually, so I really like this idea of porting
things back to P2SH, or something like that.  I do have a scheme to get lamport
signatures in P2SH using OP_SIZE, but I really should underline that no one
should use my scheme.  I talked about it in the Dev mailing list, but it makes a
lot of assumptions.  You'd probably be more secure against a quantum computer
not using my scheme than using my scheme.  So, I think that if we do port these
things, if we do port tapscript back to P2SH, we'll still want something that --
like, if we're going to go through all the work of that, we should probably have
something like CAT or some sort of dedicated quantum secure signature algorithm
in P2SH to do it, because it would be a shame to go through all the work just to
enable ColliderScripts, when ColliderScripts are incredibly expensive and
something, you know, if we're going to go through all that work, why not just
add something that lets us do lamport signatures in P2SH directly and make it
highly usable.

**Brandon Black**: That was literally what I said to Moonsettler as well when he
first mentioned this idea.  I was like, "We don't need to do this now.  We do
this when we have a practical way to do something quantum-resistant in
tapscript".

**Moonsettler**: Yes, I have a question.  So, this collider scripting, because
the hashing capacity of the Bitcoin Network, as you mentioned, is it actually
feasible with the existing ASICs, or we are talking about our own fleet of
ASICs?

**Ethan Heilman**: So, if I understood your question it's, "Can we use this with
existing ASICs?"  And I don't think you can.  The activity that you're doing on
this is very different than what current ASICs are doing, and it applies to SHA1
and RIPEMD.  It also actually requires storage.  And because we're using some
clever cryptologic techniques, the storage bandwidth isn't a problem, but you do
need something like basically a couple of thousand hard drives plugged into the
ASICs.  So I think, yeah, I think you'd have to tape-out ASICs, and you'd also
have to have the ability of these ASICs to do rights to the storage.

The interesting thing though is the ASICs don't actually have to wait for the
rights to complete, they can just keep running, and the rights are fairly
infrequent.  So, the storage does not prevent the scheme from working, but it
would likely require a very different setup than most current ASICs.  You'd have
to tape something out.

**Moonsettler**: All right, thank you.

**Mike Schmidt**: Bob, did you have a question?

**Bob McElrath**: Yeah, so Ethan, correct me if I'm wrong here.  This is totally
impractical without a network of ASICs similar in size to the Bitcoin Network,
right?  And so, if that's the case, I mean the correct number to think of there
in terms of the cost of this is the CapEx of those ASICs, not their electricity
costs.  Because Bitcoin has a few million ASICs online and the total CapEx of
those things is in the tens of billions of dollars.  And the cost of those is
amortized over a lifetime of 18 months to 2 years roughly.  So, in order to make
one hash collision here, one would need to build a network of ASICs.  In order
to make one script, you'd have to spend on the order of $1 billion to $10
billion just to get the ASICs.  Do I have all that correct?

**Ethan Heilman**: So, I don't know how much the Bitcoin Mining Network costs.
I've heard estimates as low as $500 million, you're always trading off the time
to find a collision to the amount that you build out.  But I do think that
building this out at scale with what the paper currently has, without additional
improvements, would be incredibly expensive; incredibly expensive to get one
ColliderScript output spend per 33 hours.  So, there's two things here.  One is,
because this is likely to improve a lot in the future by at least an order of
magnitude, just based on what we know, we probably shouldn't tape-out ASICs now.
But the second side of that is, if you did tape-out ASICs, and then, like,
OP_CAT or OP_CTV were to show up, the ASICs, you would have spent a lot of money
on something that you probably can't use.

So, I would say that it is probably possible to create a contract on Bitcoin
where you hedge against, like, CAT or CTV to fund your ASICs or something, you
bet on that.  But if it was up to me, I would probably wait a little while
before spending $100 million to $1 billion.

**Bob McElrath**: Yeah, I think CTV is a way better idea, or any of the other
opcodes for that matter.  It's way cheaper!  But one question for you.  I would
have thought that a SHA1-length extension attack would be a far easier way to do
this.  Could you comment on using SHA1 for the same kind of idea?

**Ethan Heilman**: Sure.  So, part of the problem is that length extensions
don't get you collisions, you can just extend a value without knowing what the
prior input was.  So, they tend to be much more useful against authentication
protocols.  There are some very, very effective SHA1 collision attacks that work
on 2 message block sizes.  If we could get those down to 1 message block size,
or 1 message block, which is 512 bytes, we could have a significant speed up
here.  We generally were just kind of curious if, without getting into that
level of detail, that this was even possible, and it is.  But I really look
forward to using some of the more specific details of the hash function.  And
perhaps you have a way to do it with length extension, which if you do, please
write it up, I'd love to see it.

**Bob McElrath**: I don't have a way.  I was asking you because you're the
expert on hash functions!

**Ethan Heilman**: So, as far as I know, there's no way to use length extension
in this setting, but there is a lot to explore here.

**Bob McElrath**: Awesome, thank you.

**Mike Schmidt**: Ethan, thanks for joining us.  That was interesting
conversation.  I'm glad you were here to walk us through that.  You're welcome
to stay on.  Otherwise, we have just a few more things to get through.  But if
you need to drop, we understand.

**Ethan Heilman**: Thanks.

**Mike Schmidt**: Next segment from the newsletter is our monthly segment on
Changes to services and client software.  We picked out four this month.

_Spark layer two protocol announced_

The first one titled, "Spark layer two protocol announced".  Spark is a new
layer 2 that has been developed by the Lightspark team, which is a company that
is working on Lightning services.  Spark uses statechains along with threshold
signing behind the scenes, on the tech side of things, and their website
indicates that they see Spark as a payment-focused layer 2 solution.  And in
terms of features or capabilities, Spark uses native Bitcoin, it's
self-custodial, it's low fee, it interfaces with Lightning, it has a 1-of-n
trust assumption, it supports unconditional unilateral exits, and doesn't
require any Bitcoin consensus changes.  I should note also that Spark is
currently alpha, and there is a form on their website if you're curious and want
to sign up for their beta testing.  But I wanted to query our smart special
guests this week to see if anybody's looked into this a little bit deeper.

**Mark Erhardt**: Well, I looked over it.  Oh, Moonsettler, were you going to
say something?

**Moonsettler**: I just wanted to say that I have one last comment about
LNHANCE, but you can put it to the end.

**Mark Erhardt**: Sorry, how does this tie to LNHANCE?

**Moonsettler**: No, it doesn't.

**Mark Erhardt**: Okay, so on the Spark layer 2 protocol, I looked over it
briefly, I don't think I have a full understanding yet, but I do have a gripe
here.  If you call yourself fully self-custodial and then also say that there's
a 1-of-n honorable, honest party trust assumption, I think we have different
understandings of how grammar works.

**Moonsettler**: Statechain zombies have this special HSM security model, I
believe.

**Mike Schmidt**: Bob, did you have a question or comment?

**Bob McElrath**: Yeah, I just wanted to mention that there's another
implementation of statechains, and that's the Mercury layer statechains.  I
don't know if it's widely known at this point, but the company that wrote the
Mercury layer is shutting down.  It's fully open source, including the server,
including the HSM code.  I wish that those guys would have bought Mercury layer
from those guys, unfortunately they did not.  So, there's a lot of
inconsistencies in their news releases.  They said they're gonna open-source it,
as far as I'm aware they have not.  But everybody should know that there is an
open-source implementation of a statechain that basically accomplishes all the
same things.  It would be awesome to figure out how to integrate this with
Lightning, it looks like these guys have already done it.  But there's another
alternative here that's not proprietary that I wish everybody would look at.
It's fully open source, do whatever you want with it.

**Moonsettler**: Yeah, I think there is a way to integrate the statechains with
Lightning, by the way, especially if we get LN-Symmetry, because then we can do
immortal statechains that do not have a fixed lifespan.  And not only you can do
LN-Symmetry channels, but you can actually stack LN-Symmetry channels and use
the statechain technology developed by Mercury, and basically transfer ownership
of the entire Lightning channel without an onchain transaction.  I think that
would actually be super-interesting.

**Bob McElrath**: I think that is an awesome use case.  I've been arguing for
that for a long time and I'd love to see somebody do it.

**Moonsettler**: And of course, you can pack these to virtual UTXO leaves in any
time-out tree structure as well, if you want.  So, I just want to float it out
that you can really compose these things and come up with very interesting stuff
like that.

**Mike Schmidt**: Interesting.  Thank you, Moonsettler and Bob, for chiming in
on that.  I did not know about the Mercury folks shutting down.

**Bob McElrath**: Yeah, I'm sad, but they wrote some awesome software.

_Unify wallet announced_

**Mike Schmidt**: Unify wallet announced.  Unify is a wallet focused on the
payjoin use case.  Specifically, Unify supports a variant of BIP78, which is the
payjoin BIP, and it actually uses Nostr as the communication protocol to
negotiate the transaction instead of an HTTP endpoint that the receiver would
operate.  So, there's a little bit of difference there in implementation.  This
software is pre-alpha, so proceed accordingly.  Any thoughts from the audience?

**Mark Erhardt**: Well, maybe briefly.  There's also BIP77, and it might be
confusing.  BIP77 is the newer payjoin proposal with the -- they use something
similar where they store the PSBT that is being assembled in a web directory.  I
am missing the proper term right now, but it's very private.  So, that might be
very interesting in this context, too.  I don't know if the author of Unify is
aware of this.  So, BIP78, the original payjoin proposal, requires you to run a
server.  So, if they're using Nostr instead, it might be closer related to
BIP77.

_bitcoinutils.dev launches_

**Mike Schmidt**: Next piece of software we highlighted in the newsletter was
bitcoinutils.dev launching.  And we have bitcoinutils.dev author here, who is
Vojtěch.  Vojtěch, do you want to describe the site and the set of tools that
are provided?

**Vojtěch Strnad**: Yeah, so actually it didn't just launch now.  I've been
incrementally building it for the past year or so.  First, it started with just
a few hash functions, which is a tool I would often just google.  And then I
just got sick of googling these tools and made my own.  Actually, I don't know
if there are any tools online that can do SHA256 and then RIPEMD, which is an
opcode in Bitcoin Script.  So, I also got sick of just calculating SHA256 and
then copying the result into RIPEMD.  And then, I just built out more tools on
the website, for example, ASCII decoding bech32.  And then the real star of the
show, I think, is the script debugger, which I released recently.  And, yeah,
you can just basically run any kind of script.  So, there are actually quite a
few script debuggers online, but most of the ones I tried were broken in very
obvious ways.

**Mike Schmidt**: Yeah, I think it was last month, was it, Vojtěch, that there
was one of these tools that I was going to highlight in this segment, and you
were looking at it saying it's broken.  Well, it makes sense that you have
something that you've built as well and you've played around with a lot of
these.

**Vojtěch Strnad**: Yeah, for example, the tool you're mentioning, it did some
quite weird interpretation of stack items.  For example, if you had a script
with OP_0, it didn't actually push the empty array, which is what it should do.
It pushed literally the number 0 onto the stack, which is impossible because
stack items are not supposed to be numbers.  And then if you hashed it, it would
actually hash the string representation of the number 0.  So, that's just
terribly broken.  I've raised it as an issue in the repository.  I don't know if
they fixed it yet.

**Mike Schmidt**: So, if you're the kind of person that has a list of bookmarks
of interesting Bitcoin sites and services and utilities, you should check out
bitcoinutils.dev and see if that's useful for you to add to your collection.
Anything else, Vojtěch?

**Vojtěch Strnad**: Yeah, and if there's a tool you would like to have and it
doesn't have it yet, just open an issue on GitHub and I will probably implement
it.  It's all open source, so you can even fork it and do some changes yourself.

**Mike Schmidt**: Thanks, Vojtěch.

**Mark Erhardt**: Very cool, thank you.

_Great Restored Script Interpreter available_

**Mike Schmidt**: Last piece of software we highlighted was Great Restored
Script Interpreter available.  And Jonas Nick has been working on Great RSI,
which is currently experimental, but this provides an interpreter for the Great
Script Restoration Proposal soft fork, which is referenced as GSR.  So, GSR is a
proposal from Rusty Russell to enable the opcodes disabled by Satoshi in, I
believe, 2010, including the OP_CAT opcode and also a bunch of other opcodes.
We link to Rusty's BTC++ video where he explains GSR.  And also to plug the
Brink podcast, we spoke with Rusty a couple of months back about his GSR
proposal, so check that out.  This interpreter implementation that we covered in
the newsletter, they noted, or Jonas noted, that it, "Lacks a crucial GSR
feature", which is the varops budget, which is sort of a change.  The sigops
budget to varops is one of the changes in the GSR.  So, that's missing
currently, which is probably why it's a partial experimental implementation.

One thing that I noticed as well, in jumping into the repository, that it's
written in Lean, which I had never heard of before.  But lean is a proof
assistant and functional programming language.  So, I haven't used that before,
I can't comment on it.  Murch, do you know what Lean is?

**Mark Erhardt**: I had never heard of it before either.  But I also saw that he
implemented some experimental Winternitz One Time Signatures (WOTS), and was
especially talking about how GSR could be a path towards post-quantum security.

**Mike Schmidt**: Yeah, this would be an interesting one to keep an eye on.
It's quite rigorous if they're using this proofing and then assistant language
in the interpretation to sort of, I don't know, it's a more rigorous approach to
this soft fork activation if you're putting all this research and proofing
around the proposal.  So, I think it's interesting.  Keep an eye on it, see
where the maturity of that goes.  Notable code and documentation changes.  If
you have questions for any of us who are still on the show, feel free to raise
your hand and request speaker access or leave a comment in the chat, we'll try
to get to that.

_Bitcoin Core #30666_

Bitcoin Core #30666, "Fix m_best_header tracking and BLOCK_FAILED_CHILD
assignment".  Murch?

**Mark Erhardt**: Yeah, so apparently when you call invalidateblock or
reconsiderblock, or if an invalid block is found by your node, sometimes the
header wouldn't be updated in its markings, so it was possible that the header
to an invalid block was still considered to be the best header; or after
reconsiderblock, the reconsider chain tip wasn't marked as m_best_header.  This
is just from a cursory look.  The good thing is we don't really use header for
much.  Apparently, the most prevalent use is to discover how close we are to the
chain tip on a specific header, and in fee estimation.  And it also affects the
responses of some RPCs.  This PR anyway fixes the behavior.  So, when the user
calls invalidateblock or reconsiderblock or when an invalid block is found, the
m_best_header is reconsidered and recalculated, and now it should hopefully
always show the right m_best_header.

_Bitcoin Core #30239_

**Mike Schmidt**: Bitcoin Core #30239, a PR titled, "Ephemeral Dust".  And,
Murch, while I was out, I know you did Newsletter #328, and there was a PR
Review Club on this PR, Ephemeral Dust.  Do you want to take a crack at
summarizing it briefly?

**Mark Erhardt**: Sure, of course.  Yeah, so as you probably heard if you're a
regular follower of this recap, this year had a lot of mempool changes, a lot of
standardness rules changes.  This introduces another change to the standardness
rules.  So far, transactions that have an output with a very small amount below
the dust threshold were always considered non-standard.  And in this PR, Bitcoin
Core's mempool behavior is changed in that it permits a dust output, or it
considers a transaction standard if it has a single output below the dust limit,
as long as it is being spent in the same transaction package, and the
transaction that has the dust output itself has a fee of zero.  So, why would
that be useful?

The idea here is that if you create a tiny amount output, it can serve to chain
off another transaction from it, so for example to create a CPFP or in anchor
transactions.  And if the parent transaction, the transaction with this dust
output, doesn't bring its own fees, there should be no reason for anyone to ever
include it in a block.  So, the worry would be if we create outputs that are not
worth anything, they would just live in the UTXO set forever.  We wouldn't be
able to remove them because they would still be consensus-valid to be spent.
So, any nodes that just forget about these UTXOs would be forked off the
network.  But if they're spent immediately, because the parent transaction
doesn't offer any fees and the output itself is worthless, if we require that a
child transaction, whenever it spends any output of such a zero-fee transaction,
also spends the dust output, we can build more efficient anchor protocols and
CPFP constructions from this.

**Mike Schmidt**: Murch, maybe you can help distinguish, I think you did a good
job of explaining, but folks may be a little bit confused.  We had this thing
called ephemeral anchors, which I think is pay-to-anchor (P2A), and now there's
this other ephemeral thing, ephemeral dust, which interplays with P2A, but
potentially other things as well.  Maybe just distinguishing between ephemeral
anchors and ephemeral dust?

**Mark Erhardt**: Right.  So, we recently introduced a new P2A output type, and
now we're adding ephemeral dust.  And those two together composed the ephemeral
anchors proposal.  They were split up when someone provided the feedback that
really, these two things could be useful separately.  So, P2A is a way of making
an anyone-can-spend output that you attach that is, due to a Small Script, cheap
to spend.  But the problem with that is, of course, that anyone can spend it.
So, some third party might interfere with your expected transaction behavior or
reorg it.  Let's not talk about that at the moment.  So, anyone can interfere
with this output and spend it.  There's also the key variant, where there is a
key on it that is usually shared by all the stakeholders in the transaction, so
they can spend it and create child transactions, but nobody else.

So, the other part of that ephemeral anchors proposal was the notion that this
output could have a tiny amount, and that now got split out into the ephemeral
dust proposal.  So, regardless of whether it's a P2A output, you could have now
a dust output that has a tiny amount, and that could be useful in order to make
the anchor transactions for Lightning channels, or maybe in Ark timeout-trees,
BitVM, or other protocols, where you would like to have the longer cached
transaction with a zero fee itself, and then have a means of providing fees in a
child transaction.  So, yeah, those two concepts got split and that's the main
story here.

**Mike Schmidt**: Thanks, Murch.  The last six PRs this week are all to Core
Lightning (CLN).  Good news is we found Dusty, he's with us.  I thought it would
be interesting to bring him on for the last PR specifically about splicing, but
since he's also been contributing to CLN, he might do a better job of walking us
through some of these PRs than we might have done otherwise.  Dusty, do you want
to introduce yourself to folks?

**Dusty Daemon**: Hey, good morning.  Yeah, I'm Dusty, working on CLN and
splicing stuff in particular.  Good to be here.  I'm super-excited about that
anchor stuff.  It's going to clean up a lot of awkward transactions in
Lightning.

**Mike Schmidt**: Thanks for joining us, Dusty.  I think we can probably just go
through these sequentially, and if you feel comfortable explaining them, please
do, because otherwise I just have the title of the PR in my notes right now.

_Core Lightning #7833_

Core Lightning #7833, "Offers: not just for breakfast anymore!" is the title of
this PR.  Maybe self-explanatory, but Dusty?

**Dusty Daemon**: All right, let me pull this up.

**Mark Erhardt**: Well, maybe I'll jump in intermittently.  Recently, the offers
BOLT12 got merged to the BOLT spec, and we've been reporting on a bunch of
different Lightning implementations now.  Started to work towards it being
active in their mainline client releases.  This looks like it is the CLN release
of offers support.  And, yeah, so I think that makes it now LDK and CLN both
having support, and I think also Phoenix with the ACINQ release.

**Dusty Daemon**: Yeah, I think the big thing with this is taking it out of the
experimental mode, now that it's interoperating with the other implementations.
So, it makes offers officially released and usable on Lightning, which is pretty
exciting.

_Core Lightning #7799_

**Mike Schmidt**: Excellent.  Core Lightning #7799, a PR titled, "Xpay, a
rewritten payment plugin using askrenee and injectpaymentonion".  Are you
familiar with that one, Dusty?

**Dusty Daemon**: I've been hearing about it ancillary.  I mean, basically the
way we've been doing payment routing through Lightning worked in the beginning,
but it's not going to work long run.  And René has this amazing proposal of
redoing the way we do payment routing.  And for those that don't know, payment
routing is basically, in Lightning, to get to make a payment to Joe, you've got
to route it through a bunch of other Lightning nodes, to Alice and other people,
and you have to find the ideal path through the network to get there.  And it
ends up being a quite complex problem and important to do it correctly, because
the better route you find, you're going to get increased payment reliability,
cheaper fees.  And that's a really key feature of lighting, since the whole
point of it is getting payments done.  I haven't been following it very closely,
but from what I've been hearing, it's a huge upgrade into the way that we do
routing.  So, very exciting.

**Mark Erhardt**: Yeah, I think early on, most of the routing approaches were
just trying to optimize for lowest fees, and that made, in some cases, the
routing reliability suffer.  So, various implementations have now upgraded their
approaches to take into account the history of previous payments, and making
sure that they learn from past failures which nodes might not have sufficient
liquidity in the direction that they're trying to use the channel.  And so,
Pickhardt Payments, which is what askrene, I think, is referencing, tries to
model the LN as a min-cost-flow problem and trying to guesstimate which route
would work best on basis of that.

**Mike Schmidt**: We reference it in the Newsletter #316, where we talked about
the askrene plugin and covered that in the Notable code segment.  But we've
covered René Pickhardt's research over the years as well.  So, I think if you
search René Pickhardt's with site:bitcoinops.org, you'll get a lot of
interesting research over the years that he's put out around this.

_Core Lightning #7800_

Next PR, Core Lightning #7800, "New RPC command listaddresses".  Rusty, are you
familiar with this one?  Is it as easy as that, just listaddresses RPC?

**Dusty Daemon**: Well, it looks pretty simple, but diving into it, there's some
fun stuff in here.  Looks like support for various things around P2TR are also
added in.  So, on the simple end, what this is is Lightning still has to have an
onchain wallet for managing your onchain funds, and those get used for opening
channels.  They get used, the funds go there when you close channels.  They're
also important for bumping channel closes and paying off anchors, that kind of
thing.  But it has to have a working wallet, which is his own project.  And
seeing some taproot stuff getting implemented there is pretty exciting for
future stuff.

_Core Lightning #7102_

**Mike Schmidt**: Next PR from CLN is Core Lightning #7102, PR titled,
"Hsmtool.c - Added new method to enable creation of hsm_file from cmd-line
args".  Are you familiar with the hsmtool in CLN, Dusty?

**Dusty Daemon**: I haven't looked at this one.  I've interfaced with lib_hsm.
CLN has this really cool method of the way it's implemented, where all of the
stuff that touches your private keys is like sandboxed into one little daemon.
And it's a pretty simple daemon, it just basically signs everything.  But it's
done that way specifically so that it can be removed from CLN and put somewhere
else.  And this is how we get stuff like Greenlight and the remote signing
stuff, and this looks related to that.  It looks like probably a dev tool to
help people working on that kind of stuff.  So, it's really a good improvement.

_Core Lightning #7604_

**Mike Schmidt**: Next Core Lightning PR, Core Lightning #7604, which adds RPCs
to the bookkeeping plugin, so that you can update or set description on an
event.  It looks like they have one for adding a description to a payment ID and
one for adding a description to an outpoint.  I think the bookkeeping plugin
we've talked about previously, but off the top of my head is sort of like an
accounting plugin for all the different events going on in your CLN node and
noting those.  And it looks like now, you can provide a little bit of
description to those particular events in the form of text.

**Dusty Daemon**: Yeah, it sounds like it.  Bookkeeper is a fun project.  It's
funny that trying to do accounting in Lightning sounds like it'd be simple, like
okay, payments in, payments out.  But Lightning has so many different states
that a payment can be in that it actually becomes really complex to do it.
You're like, "Okay, these are the funds I have now, plus these pending funds
that I may or may not receive, plus these funds I had to use in some kind of
weird force close thing".  So, the bookkeeper plugin is kind of a huge project
that Lisa pulled off to actually get down to the set accurate information on
where all of your funds are and where they're going in Lightning.  And I know
there's been an effort, because it's been so elegant, the results, there's been
an effort to merge it in with just onchain transactions.  So, this would be like
a merchant that accepts Lightning for stuff, but then also accepts onchain
payments.  And if they use bookkeeper, all the Lightning payments, their
accounting is really well handled.  Just adding in onchain tracking to it too
really rounds out the bookkeeper, and this looks related to it.  But there's
also adding descriptions.  So, it seems like a small improvement to a really
awesome project.

_Core Lightning #6980_

**Mike Schmidt**: Last Core Lightning PR this week is #6980.  And as you can see
from the previous five CLN PRs that were all in the high 7000s, this one's been
worked on for quite some time.  So, we are honored to have its author here,
Dusty, to talk us through it.

**Dusty Daemon**: Thanks.

**Mike Schmidt**: Why don't you set this up for us?  Is this splicing final, or
what piece of splicing is this, etc?

**Dusty Daemon**: Oh, man, this is something I'm really excited about.  It's
been a project that I have been working on for a long time.  It's in the 6000s,
as you mentioned, in the PR numbers.  The path where I got to this is
essentially that now that you can do splices in Lightning, it came to the
realization it's just really hard for users to do.  And turns out making a new
script language for it really makes it a lot more approachable for people.  So,
it's kind of like miniscripts, but for Lightning.  And the core idea is having
an ability to describe multiple splices you'd want to do.  And then, instead of
having to do them, have the have the node itself auto solve it, right?  And with
that power, you can also do stuff beyond splicing.  You could open channels and
move funds around onchain, you could even implement a coinjoin using this.  So,
it ended up being quite a useful scripting language in its own right that I'm
going to keep adding on to.

Then, the other thing I want to do to it is you can't do channel closes.  This
is sort of the beginning stages of enabling what splice can really do.  Because
there is a lot of powerful stuff that's possible, particularly around merging
multiple operations, and this scripting language is really the first step in
unlocking a lot of that possibility.  And once we finish this, I get this
rounded out -- this is basically like the beta release of it.  So, now it
actually works, it's the whole language, there's a whole compiler for it,
there's a whole solver, it's kind of like a compiler and linker stage to it.
But once this is working really well and it comes out of beta phase, then I'm
going to be able to build on top of this to do these temporal transactions.  And
this is kind of a complex concept that I haven't really seen anywhere else in
Bitcoin, is the idea of instead of describing an individual transaction, just
having a formalized way to describe the intention of transactions.

This ends up, you need it for lightning for like one specific case, which is if
you're going to close a channel and then move those funds somewhere.  The reason
you need that is because you don't know how long a channel close will take.  It
could be right away, often it is, but then you might have an HTLC (Hash Time
Locked Contract) that's pending for a week, that'll delay a close.  We might
have any number of conditions that delay the situation.  So, you really want to
be able to just close a channel and move it into an existing channel that's
good, right?  So, you have a channel that's doing you no good, you have a really
good channel; moving the funds over to that channel makes all the sense in the
world, but you can't do it without some kind of temporal transaction engine.
And I suspect once we start building that out and ranting that out, it'll be
useful all over Bitcoin.  Just having a formalized structure for delayed
transactions I think is a big deal.

But this release is all the work that I've worked on for a long time to
literally make a script that can do every kind of splice you'd ever want to do,
and there's a lot of different kinds.  So, I'm really excited about it.  I think
that it adds like a really nice usability layer to splicing, and it's finally
merged in.  It's been a long time coming.  This one I've been working on really
hard, so I couldn't be happier to get this PR merged.

**Mike Schmidt**: Very cool.  So, this is sort of like a domain-specific
language or scripting language for describing what the what would occur during a
splice?

**Dusty Daemon**: Exactly, yeah.

**Mike Schmidt**: Okay.  And so, am I writing this as somebody -- like, what
sort of languages is this?  Is this thing like a human-readable DSL, or am I
writing it in some pseudocode?

**Dusty Daemon**: Yeah, it's a human-readable DSL thing.  It's kind of like
miniscripts, that sort of idea.

**Mike Schmidt**: Yeah, okay, very cool.  Does it have a cool name?

**Dusty Daemon**: We're calling it Splice Script, I think that's kind of a fun
name.

**Mike Schmidt**: Splice Script, okay, seems descriptive.

**Mark Erhardt**: So, if you instruct your node to splice multiple things at the
same time, the node translates that into singular splice operations?  Would I be
right to guess that this means it's interoperable with what other node
implementations do with splicing?

**Dusty Daemon**: Yeah.  So, yes.  The interoperating with other nodes in the
splice protocol itself, this is for like, you're handling your own node.  If you
want to do multiple channels, there's this funny problem where you don't
actually know the balance of a channel until you freeze it, because there's
always pending stuff going on.  So, one of the first things you have to do if
you want to do multi-channel splice is you have to freeze all the channels that
you're touching, kind of like a shared mutex, right?  And so, you have to go
through each channel, freeze it, and then you can get the exact balance of
available funds, which is different than the funds that you own, because they
could be locked up in a pending HTLC or something.  And once you have that, then
you can execute the splice across multiple channels that you own.

So, this language wouldn't handle the inter-node stuff.  It's just for your own
node, but it could handle other onchain stuff.

**Mark Erhardt**: Right, but if you run the quiescence protocol on multiple
channels, wouldn't the other nodes respect that?  And if your node then does
whatever you want it to do from your end, it should maybe work?

**Dusty Daemon**: Absolutely, yeah, that's the idea.  You go and quiescence and
it's like a bunch of channels.  And part of the reason it needs to be a
scripting language is because you don't know the exact balance.  So, the script
gives you a token that's like, "Here's the available funds, give me the whole
amount, 1%, some percentage of it", that kind of thing.

**Mark Erhardt**: Okay, cool.  That sounds really useful.

**Mike Schmidt**: Dusty, I know you've been working on not only this, but all
the foundational work and research that went into this for years now.  It must
feel good to be getting these things across the finish line, yeah?

**Dusty Daemon**: Oh, it feels so good.  The other one that I'm excited for,
that we're so close to, but not there yet, is getting interop with splicing
between CLN and Eclair.  It's like inches away.  There's actually another PR in
this release that almost brings it, but it's just not quite there yet.  Couple
of little hanging fruits, but yeah, it feels good.  Years of effort really
starting to come together.

**Mike Schmidt**: Murch, any other follow-up questions or comments?

**Mark Erhardt**: That's it for me.

**Mike Schmidt**: Dusty, thanks for jumping on with us.  Thank you for your work
on splicing and walking us through some of these other CLN PRs as well.

**Dusty Daemon**: Thanks for having me, man.

**Mike Schmidt**: Murch, I don't see any questions or requests for speaker
access.  I think we can wrap up.  We're back to the hour-and-a-half episodes
these days.

**Mark Erhardt**: It seems like it.  Moonsettler is still here.

**Moonsettler**: Hi, yeah, I wanted to say a few words because when we had up
Spark, I forgot to mention a few things, so thank you very much.  I will be
quick.  So, I think it's interesting that decrementing timelocks are now being
looked at in composition with time-out trees.  I think that's super-interesting.
In general, I'm not a big fan of decrementing timelocks, because I don't think
they give us the scalability that we need.  They don't actually save all that
much on the block spaces as they could.  So, I'm more excited about the immortal
statechains and transferable Lightning channels, and these things being
composable.

Another thing I would like to mention, the great advantage, because some people
are still asking the question, "Why not just APO?"  I think that's an
interesting question, and the answer to that is the Lightning state machine, the
internal state transfers, the number of steps the peers have to do to make an
update are greatly reduced and simplified by the peers.  And they are actually
smaller than an onchain footprint and also cheaper to the entire network of
validating nodes than checking signatures, and you don't actually have to check
signatures.  So, decoupling APO into CTV plus CSFS is actually beneficial to the
whole ecosystem, and also just makes for better Lightning implementations that
are much simpler.  Lightning simplicity itself makes things better.  That is why
Lightning developers want it, but actually using CTV, it further simplifies
these things and makes them cheaper, literally for everyone.  So, that's another
thing I would like to add.

One more thing is a lot of people think that for really good vaults that
actually are valuable, you can just use CTV and you have to have something else.
I want to push back on that a very little, because there are actually practical
improvements in the usability and backup schemes of robust Core storage and
inheritance that you can do with CTV alone.  You don't actually need anything
else for that.  And I also wanted to mention that for this reason, again,
decoupling these things is extremely beneficial, I believe.  That's all I wanted
to mention earlier.  Sorry about that.

**Mike Schmidt**: Yeah, no problem.  Thanks for bringing that up.  I would
suspect that Rearden or ZmnSCPxj would have some feedback on that.  I don't have
any comments.  Murch?

**Moonsettler**: And one more shout out to the Mercury guys.  They were awesome
and I will miss them.

**Mark Erhardt**: That's all from me.

**Mike Schmidt**: All right.  Well, thank you all for listening.  We had a bunch
of guests this week.  Thank you to Dusty, Ethan, Rearden, Moonsettler, Vojtěch,
ZmnSCPxj, and for Bob jumping in and having some comments as well.  Thank you,
Murch, for hosting and co-hosting while I was gone and co-hosting today, and
we'll see you all next week.

**Mark Erhardt**: Cheers.

{% include references.md %}
