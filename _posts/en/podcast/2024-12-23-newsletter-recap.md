---
title: 'Bitcoin Optech Newsletter #334 Recap Podcast'
permalink: /en/podcast/2024/12/23/
reference: /en/newsletters/2024/12/20/
name: 2024-12-23-recap
slug: 2024-12-23-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Dave Harding, Niklas Gögge,
Gloria Zhao, and Rearden to discuss [Newsletter #334: 2024 Year-in-Review Special]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-11-23/392028022-44100-2-60db8626bac74.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #334, our 2024
Year-in-Review special newsletter review, Optech Recap.  We've done this yearly
recap at the end of the year since 2018 and the way it works is Dave Harding has
gone through each month of newsletters, and for this year has pulled out some of
the most notable Bitcoin and Lightning developments.  And so, we'll go through
those in a month-by-month manner, and that'll make up the bulk of the year in
review today.  But we also have six featured summaries this year.  We have one
on vulnerability disclosures; one on cluster mempool; one on P2P transaction
relay; covenants and script upgrades; we have a list of major releases to
popular infrastructure projects; and then we had a special segment on Bitcoin
Optech and the work that the contributors have done there.  I'm Mike Schmidt,
Optech contributor and Brink Executive Director.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I currently still work at Chaincode Labs, but
not for long.  And yeah, I do Bitcoin stuff there.

**Mike Schmidt**: Dave?

**Dave Harding**: I'm Dave Harding.  I'm co-author of the Optech Newsletter and
the third edition of Mastering Bitcoin.

**Mike Schmidt**: Niklas?

**Niklas Gögge**: Hi, I'm Nicholas, I work on Bitcoin Core, sponsored by Brink,
and I mainly focus on fuzz testing.

**Mike Schmidt**: Gloria.

**Gloria Zhao**: Hi, I'm Gloria, I work on Bitcoin Core sponsored by Brink.  I
mainly work on mempool and P2P stuff.

**Mike Schmidt**: And Brandon/Rearden, how do you like to be known?

**Brandon Black**: Rearden is usually good on Bitcoin things. Hi, I'm Rearden, I
work at Swan currently on the Swan Vault product, and on my side time, I work on
Bitcoin Script upgrades, covenants, things like that.

**Mike Schmidt**: For the majority of the recap today, we're going to try to go
in order.  There's two notable exceptions, which we're going to introduce here
at the beginning.  The special segment on covenant and script upgrades is going
to be first, followed by vulnerability disclosures.  And then we'll jump into
the newsletter starting in January.

_Summary 2024: Covenants and script upgrades_

So, Rearden, I know you have a hard stop not too long from now, so maybe we can
jump into Covenant and script upgrades, which was a special segment that we
wanted to have you on special for the show for.  I don't have any outlines to
tee this up to you.  I don't know how you would frame up what was written and
how you're thinking about covenant and script upgrades currently.

**Brandon Black**: Yeah, I guess we can dive right into it.  It's been a crazy
year with lots of different shifts, I would say, in the community, everything
from the Taproot Wizards and their and their work on CAT, and my work on
LNHANCE, and Rusty's proposal for the great script restoration.  And all of this
is kind of revolving around the general idea that Bitcoin Script is very useful,
but most of what we do with Bitcoin Script today is focused around OP_CHECKSIG,
which many people refer to as, "OP_DO_BITCOIN, because it hashes the
transaction, checks the signature against that hash with a pubkey that's already
provided.  It's the op code that basically controls the flow of Bitcoin
currently.  We have a few things additionally that we use for LN as it is, but
as people are trying to build additional Bitcoin features, whether they be
improvements to the LN or other things, like Ark, or even BitVM, all the other
things that are trying to be built, they're running into the limitations of the
existing scripting system.  So, many people are looking at different angles,
different ways to improve Bitcoin's scripting system to provide just that little
bit more flexibility to build better layered protocols.  And the newsletter is a
great summary of a lot of them.

Getting into kind of the broad strokes of what's changed over the year, I think
the biggest thing is a lot of education has been happening between things that
Rusty has been talking about, or ZmnSCPxj has talked about, or myself, or
Rijndael and the Taproot Wizards.  Lots of education has been going on about
what happens if we add this or that feature to script.  And we've really refined
what it means, for example, to add OP_CAT to script; what features does OP_CAT
concretely add to script?  Versus in the past, we had, as a broader Bitcoin
community, this idea that OP_CAT enables everything if we do that.  Well, it
turns out it does enable quite a few things, but it is also a specific set of
things it enables.  So, that's been, I think, the biggest thing, is education.

Also, we revealed, partially through Floppy's new table on the Bitcoin Wiki,
that there's a lot of education still to be done around what is the difference
between CTV (CHECKTEMPLATEVERIFY) and APO (ANYPREVOUT) if you're enabling
different script upgrades with those things?  How does it help?  What are the
trade-offs between PAIRCOMMIT and CAT?  Why would you use one or the other?
What would you want to support: TXHASH, which is a project that takes longer to
enable; or the script restoration, which is even more to enable.  And so, we're
still working, I think, on figuring out how to educate and communicate about all
these different possibilities for script upgrades.  So, I think that's where we
are.  That's the summary.

**Mike Schmidt**: Rearden, I know you're probably deeper into a lot of these
discussions than at least I am.  I'm curious from your perspective, and maybe
being at some of the events around some of these script discussions and
enhancements, what are the top things that you think people want to build?  I
know people talked about joinpools, vaults, DLCs, eltoo or LN-Symmetry; that's a
list, but is there like a shortlist in your mind that you and maybe others seem
to be coalescing around?

**Brandon Black**: I think the best way to look at a lot of this, especially now
that BitVM is out there, or we've seen Jeremy's most recent paper about using
oracle-based covenants, really the question is more about not what new thing is
going to be built, but about how we reduce the trust in things we could already
build, or how we make more efficient things we could already build.  So, if you
have CTV, just the single covenant that restricts the outputs of the next
transaction, that reduces the trust required to build things like vaults.  It
reduces the number of signatures needed to do DLCs by an order of magnitude, if
I recall correctly, I'm talking to Matt Black.  So, it's really not so much an
enablement as a reduction in trust or a reduction in cost to build many
different things.

**Mike Schmidt**: That makes a lot of sense.  Okay, any follow-up from our other
special guests, questions?  Great, I know that's a huge topic and we just gave
it just a few minutes, but the fact is we have a ton of topics today.  So, I
think we can keep these fairly short.  Rearden, thank you for joining us to walk
us through this first special segment.  You're welcome to hang on until you need
to drop, otherwise we understand if you need to go.

**Brandon Black**: Thank you.

_Summary 2024: Vulnerability disclosures_

**Mike Schmidt**: All right.  So, we'll jump to our second special segment
highlight, which is titled, "Vulnerability disclosures".  Niklas, when Dave was
doing the draft, he mentioned that your name was in there a bunch of times.  So,
I immediately, before even previewing and reviewing the newsletter, invited you
to come on and own some of this.  I know a lot of these were things that you had
some hand in, whether that was discovering it, fixing it, helping disclose it.
I know on the Brink podcast, we had you on to talk about some of this with
Gloria, and we also had Matt Morehouse talking about fuzzing Lightning.  What do
you think, in a few minutes of trying to cover all of this ground, would be most
beneficial for listeners to understand or be aware of?

**Niklas Gögge**: I'm not sure.  I mean, overall, I feel like it's been quite a
big year for vulnerability disclosures.  I mean, I haven't kept track the last
couple of years, but looking at the summary, there's more than two dozen
vulnerabilities and quite a bit of variety too, I think, like four new crash
bugs, consensus bugs, a bunch of Lightning bugs where you can lose or steal
money, coinjoin privacy issues, wallet bugs.  So, yeah, I feel like it's sort of
a hint that we can invest more maybe in securing all the software that we write.
But it's obviously great to see that stuff is being found and fixed.  And a lot
of these bugs were Bitcoin Core bugs, which came sort of out of the effort that
we started to publicize old issues that we had on file, but no one really worked
on disclosing them.  But we did all the old ones now and going forward, we will
be disclosing any issues that are being found.

I think a highlight for me, even though I don't work on Lightning personally, I
think the Lightning bugs are very interesting because crash bugs or logic bugs
lead to money being lost or stolen, which I think that's very interesting.
Yeah.

**Mike Schmidt**: It seems like quite a few of these, at least some of the more
recent bugs, were discovered in some manner of fuzz testing.  Do you want to
talk about just briefly what fuzz testing is and why you think it's such a
fertile ground for finding these bugs, whether it's in alternate Bitcoin node
implementations or Lightning node software or Bitcoin Core itself?

**Niklas Gögge**: Yeah, so fuzz testing is essentially an automated form of
testing, where you bombard your program or parts of your program with, it's not
really random, but you throw a bunch of 'random' data at your program to see how
it behaves.  And a lot of the time, this kind of testing finds all sorts of
weird behavior, probably because it removes the bias that you normally put in
tests that you write normally, like unit tests or integration tests, you know,
you test something specific.  But the fuzz test will sort of execute random
stuff that maybe you didn't think about, so it tends to find a lot of edge
cases.  And you can write smarter fuzz tests, where you employ some kind of
testing oracle.  So, for example, if you have two different implementations of
the same thing, you can throw the same data at both of the implementations and
then compare that the behavior of the implementations is the same.  So, this is
something you can do to find consensus bugs between different Bitcoin
implementations, for example.  So usually, if something isn't fuzz tested and
you start testing it with fuzzing, you will find low-hanging fruit pretty
quickly, which is, yeah, the case for some of these.

**Mark Erhardt**: I kind of want to jump in there a little moment.  You said
'random'.  But really, what's interesting about fuzz testing is when you write
tests for a function, there's usually ranges of input data that are permitted.
And what fuzz testing does, it sort of randomly tries stuff, but whenever it
finds things that lead to execution of different code pieces, it starts to dig
deeper in that direction.  So, it's really a way to very effectively enumerate
all possible ways in which code can be executed.  And that's how it finds all
the edge cases.

**Gloria Zhao**: I like to describe fuzzing as, you get a computer to write the
tests for you.  And it's a lot better at finding the good tests and it scales.
You don't have to spend more time, you just throw more money at computers and
they write them for you.

**Mike Schmidt**: Well, I guess on an optimistic yet pessimistic tone, we look
forward to the fruits of additional fuzz testing that you're putting into
Bitcoin Core, Niklas.  Hopefully, what you find is that there's not too much
there, but we're glad that we have you being proactive on this front.  Go ahead,
Gloria.

**Gloria Zhao**: I just wanted to make sure that we clarify/touch on the --
because Niklas started with, "Oh, there were a lot of disclosures this year".
And I just want to emphasize there were a lot of things that were publicized
this year, but that doesn't mean that they all happened this year.  In fact,
many of them happened more than five years ago, at least for the Bitcoin Core
stuff.  So, I was wondering if Niklas can help share why it's important that we
disclose previous vulnerabilities, and why it's important that we have this
process ongoing and that it's respected for all of the software projects in the
ecosystem, and why it's especially bad if these vulnerability security practices
aren't followed.

**Niklas Gögge**: Yeah, I think primarily it serves the purpose of making the
users aware that there are issues and that they can have serious consequences,
and that they should upgrade their software so that they're not vulnerable to
any of these issues that we find.  And then also, I mean, for a project like
Bitcoin Core, it's open source.  All of the work that we do is essentially open
in the public, and the same should apply to this sort of stuff.  If we fix a
bug, eventually it should be public that we did do this work.  Yeah, I think
that's probably the two main things I can think of right now.

**Dave Harding**: I was talking to my local BitDevs about this, and I had a
couple more reasons, and one of them is, it's a teaching opportunity.  We want
to document this stuff so that people in the future hopefully don't make the
same mistakes.  And the other one is, it's an opportunity for us to thank
developers for work that we didn't realize was important at the time.  A lot of
this stuff happens in the background, it's private, we don't know who's working
on it, they're taking time away from their other stuff.  So, thank you, Niklas.
Murch, you had a vulnerability in this disclosure too, thank you.  And thank
everybody else who worked on this stuff; we're really, really grateful for it.

**Niklas Gögge**: I think to add to that is also, if you find a bunch of
vulnerabilities in your project, usually you can draw some kind of lesson from
that on how to improve your testing as well.  So, for example, for the consensus
box, there are a few ideas that I have where we can improve the testing on the
Bitcoin Core side when it comes to this sort of stuff too, and I hope to make
progress on that in 2025.

**Mark Erhardt**: While we're on this topic, I also wanted to mention, I think
I've been contributing fuzz inputs to the QA assets repository, and in that
time, I think that the fuzz harnesses have gone from about, correct me if I'm
wrong, Niklas, like 60-ish in the past two years to over 200 fuzz harnesses,
that just take some little part of Bitcoin Core and find all the edge cases in
it.  And, yeah, so this being more of a modus operandi for new features directly
to ship with fuzz test, I think really improves our test coverage on new
features.

**Niklas Gögge**: Yeah, I think we've seen that 100%, various contributors have
started to always include fuzz tests with any changes they bring.  So, that's
really great.

**Mike Schmidt**: Niklas, thank you for joining us and walking us through a
summary of the vulnerabilities in 2024.

**Niklas Gögge**: Thanks for having me.

**Mike Schmidt**: We understand that you need to drop, but thanks for joining
us.

**Niklas Gögge**: I might stick around for a bit.

**Mike Schmidt**: All right, great.  Let's jump into January then.  I have a
couple notes on these items that we called out each month, but after I kind of
summarize some of what Dave's summarized, I'm happy to turn the floor open if
you have a question, feel free to jump in or a comment or an elaboration or
correction.

_Fee-dependent timelocks_

So, January, first item we highlighted was fee-dependent timelocks, which was
the idea of a soft fork that would allow timelocks to expire only when feerates
drop below a level specified by the users, otherwise the timelock would
continue.  And this has the potential of addressing concerns around this idea of
forced expiration floods during a massive amount of Lightning channel closures
that could occur.

**Dave Harding**: Yeah, so I think this one and the next item are pretty closely
related.  Like you said, forced expiration floods is a concern today with LN.
But if we get to massive multiparty constructions like channel factories,
payment pools, I think this becomes even more of a concern.  So, this is an
important piece of the scaling puzzle that we had to address, I think.

_Optimized contract protocol exits_

**Mike Schmidt**: Yeah, we did mention the second item here, which was titled,
"Optimized contract protocol exits", which Salvatore posted about in January as
well in a post titled, "Aggregate delegated exit for L2 pools", which was, yes,
this technique for joinpools or channel factories to enable users to coordinate
on a single transaction to exit instead of broadcasting a bunch of separate
ones.

**Mark Erhardt**: This is also very closely related to the entire new opcode,
new feature debate.  A lot of, especially the opcode researchers that are
interested in vaults, what they're thinking about is how they can make smart
contract protocols more reliable and more efficient.  And one of the big parts
is, how do you keep funds under unilateral control, even while you're
participating in a smart contract, so that you can exit and can exit efficiently
and can exit at any feerate?

_LN-Symmetry proof-of-concept implementation_

**Mike Schmidt**: Last item from January was titled, "LN-Symmetry
proof-of-concept implementation.  And this was some work by Greg Sanders, who
shared his proof-of-concept implementation of eltoo, now known as LN-Symmetry.
He used Core Lightning (CLN) to prototype bi-directional payment channels that
don't require penalty transactions.  And then, there was also then a bunch of
wording around some of the policy and mempool work that we'll get to later, that
I think Greg ended up spending a lot of his time on recently, as well as he sees
that it's important to some of the work on eltoo, or sorry, LN-Symmetry.

**Mark Erhardt**: One of the interesting things I just realised about
LN-Symmetry from a proposal that's been out so long, is that I just learned that
due to the layered closure of channels, it can make HTLC (Hash Time Lock
Contract) expiries much longer.  And so, there's a little more trade-offs in
that regard than I had realized.  And I think one of the problems is that due to
the proposal having fairly dispassionate advocates that wrote the BIP and maybe
not spend a ton of time right now advocating for the adoption, I feel like the
trade-offs are maybe understood by the Lightning developers that have looked
into it, but not super-well understood by the broader public.

**Gloria Zhao**: I just wanted to highlight that LN-Symmetry is unique in that,
well, I think some other L2 protocols have this too, where a lot of the mempool
policy things, like TRUC (Topologically Restricted Until Confirmation) and
ephemeral anchors, they're not just efficiencies or making things cheaper,
they're necessary for it to work at all.  Like, with LN-Symmetry, you can't have
fees on the update, is it the update or the settlement transaction?  And you
also can't be putting value into the anchor outputs.  And so, without these
mempool policies, it just doesn't really work as well, or it doesn't work at all
really.  So, they're necessary pieces of the puzzle.  Of course, people usually
think of APO as the linchpin of it or the crux of it, but I think it's worth
pointing out mempool's necessary here.

**Mark Erhardt**: Now that we've said two things that sort of put into question
LN-Symmetry, I do want to break a lance for it.  One of the really awesome
things about LN-Symmetry is that you can extend it to more than two people
easily, because everybody has symmetric states.  So, one of the very exciting
things would be that you could have a three- or five-party channel, and it would
lend itself to make a channel factory on top of it.  So, yeah, there's
trade-offs there, there's some very cool stuff, it also gets rid of the toxic
justice transactions, or old state, I should say, because if, in LN-penalty, you
have an outdated backup and you broadcast that to close your channel, you would
lose all your money in LN-Symmetry; you would simply be overwritten by the newer
state and the other channel partner would take that.  Yeah, anyway, we don't
have no time, right?

**Gloria Zhao**: I just want to say, that wasn't a criticism of LN-Symmetry.  It
was just a general statement not to trivialize the parts of fee management when
you're constructing your L2, because if you have all these amazing things, if
only you could just not put fees on it.  And so, it's actually great to think of
that.  Cool.

**Mark Erhardt**: Yeah, but mine was a downside!

_Replace by feerate_

**Mike Schmidt**: February, first item was this proposal around Replace by
Feerate (RBFr).  I'm going to open the floor to my fellow hosts.  Who wants to
explain what RBFr is?

**Dave Harding**: Am I doing it?  I guess I'm doing it.  It's RBF, but instead
of having a rule that the absolute fee has to be increased, we just purely look
at the feerate being increased.  And this traded off one problem for a different
problem, and it was something that we would have loved to have done years ago,
but we decided to go with having an absolute feerate requirement in order to
prevent certain DoS risks.  And those risks are still there, and we still have
trade-offs, and so it's a little controversial.  That's all I want to say.  But
it looks like Murch has lots of comments.

**Mark Erhardt**: Yeah, the way you just described it, it may have sounded to
people that you only have to increase the absolute fee on the current
replacement rules.  But currently, you do have to increase both the absolute fee
and the feerate.  And one of the issues of only increasing the feerate is that
you can, of course, decrease the absolute fee.  So, for example, it depends on
how many transactions are waiting in the mempool.  If, for example, less than a
full block was waiting and you were able to replace a transaction with just a
higher feerate, you might reduce the overall fees collected by a block template.
This is a little oversimplified.  People had lots of thoughts on RBFr and
especially, they felt that it introduced a new kind of free relay.  Peter Todd,
the author of the proposal, disagrees on that it's a new type of free relay, but
some discussion was had.  He did release a Bitcoin client, a Bitcoin node
software that does RBFr and some other more lenient relay policy that he felt
nodes should have.  And so, it's live on the network.  I'm not sure if it would
be the best for the network if everybody were running it, but it doesn't really
hurt much if there's a couple dozen nodes that do.

**Gloria Zhao**: I'll just throw in a couple sentences, because I spent a lot of
time looking at RBF and what you two have both touched on is that there are two
extremely important non-negotiable design goals for the RBF policy, one of which
is you want the new transaction to be more incentive-compatible to mine; and the
other is that your policy needs to be DoS resistant, so that people cannot abuse
network resources and do lots and lots and lots of replacements.  And these two
things are both extremely important and non-negotiable.  And we have an array of
RBF rules in Core today and ones that we're proposing, none of which can really
be taken in isolation.  They all need to be taken into the greater context in
which one of these two purposes they each serve.  The absolute fee increase,
it's less of an incentive-compatibility question and a lot more of a DoS.  Well,
it does both, but it is more important, I think, for DoS protection, which is
why it's so difficult to get rid of.

But we've spent a lot of time since, I think January 2022, was when I first
wrote my mailing list post about RBF improvements, a lot of time trying to edit
one rule at a time, and you start pulling on these threads and they all kind of
coalesce together and it's very difficult to look at it comprehensively.  But,
and we will get to this later, but a lot of the cluster mempool thinking is
around this exact problem of assessing incentive-compatibility, because what was
pointed out here many times is that our current rule set is not great at the
incentive-compatibility question.  It's pretty good at the DoS one, but maybe we
can cut a better trade-off there.  So, I'll save that for the cluster mempool
section.

_Human-readable payment instructions_

**Mike Schmidt**: Thank you all for that very informed commentary on RBFr.  Next
February item was what became known as BIP353, which is, "Human-readable bitcoin
payment instructions".  This came from a Matt Corallo post and idea.  And to me,
it seems super exciting, like a usability boom to Bitcoin wallet users, since
you can tie an email address-like identifier to both a reusable silent payment
code, for example, for bitcoin payments, or a reusable payment request for
Lightning offers.  So, I think this is pretty cool and I'm looking forward to
writing up all of the interesting Client and services software segments on folks
implementing this in the next year or so.

_Improved ASMap generation_

Next item from February titled, "Improved ASMap generation.  Fabian put together
a tool set, including his own open-source cartograph project, that allowed for
multiple parties to create ASMaps for use in Bitcoin Core.  We can double-click
real quick on ASMaps, but I wanted to point out one interesting thing before
that, which was this is involving a lot of deep internet architecture to be able
to determine what these mapping files might look like.  And I've said this
before, but I'll note it here again, that Fabian went to some of these internet
networking architecture conferences and spoke with experts that explicitly said
that this sort of thing wasn't possible, specifically around the ability for
multiple parties to come up with a similar, if not the exact same, sort of
internet mapping.  So, it's pretty cool to have a bitcoiner sort of proving them
wrong in a way that is also potentially beneficial to Bitcoin.  But does
somebody want to jump in and explain why we would want to have an ASMap, or
ASMap, in Bitcoin Core?

**Mark Erhardt**: Sure.  So, autonomous systems are the entities on the internet
that tell you who's responsible for resolving an IP address.  And the IP
addresses themselves are sort of structured into these blocks that are owned by
ASMaps.  There's some really big ones, like Google or Hetzner or Amazon, and
there's really small ones like, I don't know, Wiz and BlueMatt running their own
ASS.  And so, they shift a lot around, so these ASMaps outdate very quickly, but
you kind of want to have an overview of who is responsible for what ranges of IP
addresses so that you can ensure that your node population, the peers that
you're talking to, are well diversified.  So you, for example, don't want to be
connected to eight peers as your outbound peers that are all in Amazon US-East,
or something, because it would be very easy for someone to try and eclipse
attack you if you voluntarily connected all of your outbound peers to the same
AS and they happen to control that.

It's way harder to control the peers of a node if the outbound peers that the
node itself selects are distributed all over the world in different IP regions
and different service providers, because it would just be much harder for the
attacker to control IP addresses all across the world.  So, in order to do that
automatically in Bitcoin Core, we, I think, ship an ASMap every time we do a
release.  And with this project, it would be possible to update that on the fly
locally, or to even release new ASMaps more frequently by people collaborating
and producing multiple copies of the same ASMap.

**Dave Harding**: I was under the impression that Bitcoin Core doesn't currently
release an ASMap, and this was a step towards it releasing an ASMap.

**Mark Erhardt**: I think you're right.  I think I misspoke, sorry.

**Mike Schmidt**: Yeah, so I guess the breakthrough, if you will, here was the
fact that essentially anybody who wanted to participate in generating an ASMap
file along with other bitcoiners, could essentially time-based coordination and
run the same script.  It's likely that they would generate a similar, if not the
exact same file, so now that file could be used reliably in Bitcoin Core or
other software to make sure that you have a diverse set of connections, and that
that mapping file is also not something that one person generated in a trusted
manner.

**Mark Erhardt**: I think there was a way of importing your own ASMap already.

**Mike Schmidt**: I think that's right.

**Mark Erhardt**: But now, we would be able to produce a shared, reliable map,
at least for the release.  So, it wouldn't be outdated more than half a year or
a year, however long you're running your release.

_LN dual funding_

**Mike Schmidt**: LN dual funding.  We noted in the writeup that dual funding
was added to the LN spec this year.  And as part of a prerequisite for dual
funding, or as part of dual funding, this interactive transaction construction
protocol is now supported as well as a way for two parties to work together to
create a dual-funded channel.

_Trustless betting on future feerates_

Last item from February titled, "Trustless betting on future feerates".  This
was a proposal from ZmnSCPxj, who proposed trustless scripts enabling two
parties to bet on future block feerates.  That's all I have in my notes.  I
don't recall the specific construction of how it worked.  I don't know if
anybody wants to jump in with that, or we can leave that to the audience.  We'll
leave it for the audience.  If you're following along in the newsletter, you'll
see the Vulnerability disclosure segment.  We covered that earlier, so refer
back to that, and we can move to March.

_BINANAs and BIPs_

The first item we highlighted from March was the BINANAs and BIPs, so we'll jump
into that.  There were, we noted, ongoing problems getting BIPs merged, which
led to a few different things happening.  One, the creation of a new BINANA
repository for specifications and other documentations around proposals.  BINANA
stands for Bitcoin Inquisition Numbers And Names Authority, and it's something
that was created by AJ, who runs the Bitcoin Inquisition repository as well.
Also falling out from this frustration around getting BIPs merged led to the
existing BIP editor to request for help, which then led to the beginning of a
process to add new BIP editors, which then eventually led to several Bitcoin
contributors being made BIP editors, including my co-host, Murch, Bryan Bishop,
Jon Atack, Roasbeef, and Ruben Somsen.  Anything to say on that, Murch?

**Mark Erhardt**: It was a terrible idea, takes so much time!

_Enhanced feerate estimation_

**Mike Schmidt**: Thank you for your service.  Also in March, we talked about
enhanced feerate estimation.  Abubakar proposed changing Bitcoin Core's feerate
estimation and involve real-time data from the mempool.  Gloria, I'm not sure, I
put, "Gloria?" here.  I don't recall if you were involved with that or are
familiar with the topic to elaborate.

**Gloria Zhao**: Sure, yeah.  Fee estimation is hard, because you're trying to
predict the future with unpredictable supply of block space and unpredictable
demand for block space.  And I think there's two kinds of problems to
acknowledge here.  One is not having all the information, and that's out of
scope here, but you have to consider that even if you look at your mempool, your
mempool might not be reflective of what fees are available to the miners.  But
what Abubakar is focusing on here is, given the information that we do have,
assuming that it's reliable, of course, we could do a much better job at
predicting feerates.  So mainly, Bitcoin Core doesn't look at mempool
transactions, it only looks at historical block data.  And its method for
looking at historical block data is imperfect.  Sorry, okay, I think I know what
Murch was raising his hand for.  It does look at mempool data, in that it will
look at transactions that come into mempool, and if they confirm later on, it
knows how much time it took between being received as an unconfirmed transaction
and then actually ending up in a block.  Hopefully that was what you were
raising your hand about.

But it doesn't, for example, take a look at mempool and see like, "Okay, I have
5 blocks' worth of 50-sat/vB (satoshi per vbyte) transactions and I can totally
expect that those are going to be mined before this 10-sat/vB transaction that
I'm looking at, for example.  That's just an example.  And so, he did a lot of
research into theoretically, what is a good way to assess transactions in
mempool.  Of course, there are dependencies between transactions, there's CPFP
to worry about.  And also, practically, if we were to utilize these different
fee estimation updates that he's proposing, how would we do?  And so, he's done
a lot of really great work there.  Some of it is kind of doable today, some of
it would be greatly improved by having the cluster mempool, but this has been an
ongoing project for him, and he's been really great about working with all of
the existing mempool proposals and building things that are useful today and in
the future.

**Mark Erhardt**: To zoom out a little bit, one of the big problems that people
previously working on fee estimation and Bitcoin Core were concerned about, what
if what you see in the mempool does not reflect what the miners are actually
doing?  So, for example, miners could broadcast high-feerate transactions and
then ignore them for the block building, so that the mempool would always show
that there's a lot of high-feerate transactions available, but really they're
just distraction.  And the other one would be, of course, if miners receive
out-of-band transactions or out-of-band payments for transactions that are in
the mempool, and therefore the mempool content does not really reflect the
incentives of miners for building their block templates.

So, for the time being, a lot of other feerate estimation just assumes that this
is basically no issue, and they just look at mempool, maybe also look at what
gets confirmed, and then estimate on basis of just, "Where is the transaction
that I'm doing right now going to be inserted in the queue?", and assume that
that is working well.  And that does work well as long as nobody's attacking
those assumptions that I just mentioned.  But if you want a robust feerate
estimation that will even hold during such aberrant behavior, unexpected
behavior, then you have a lot more thinking to do.

**Dave Harding**: I just wanted to highlight this in the newsletter, because I
think it's a really important thing to have as an open-source tool for fee
estimation that you can do yourself on your own node.  It's great that there are
a lot of third-party APIs out there that will help you do fee estimation, but
they're kind of a security vulnerability when you're depending on them,
especially for something really time-sensitive, like LN unilateral closes and
emergency close transactions.  If somebody sets their feerate API, if it's
broken, or if they're hacked, or whatever, they can potentially cause you to
lose significant amounts of money.  And then, everything Murch just said here
about trying to make this resistant to manipulation.  Again, miners have an
incentive to capture as much fee as possible.  And there's just a lot of
problems in protocols that are dependent on fees.  Again, we're having these
emergency transactions.  And if somebody can trick you into paying a higher fee,
you can lose a lot of money that you wouldn't have to lose otherwise.

So, it's really important work, and I'm just sad every time I see somebody
switch away from Bitcoin Core's fee estimation to use something like
mempool.space, because they are losing self-reliance, self-dependency, and
manipulation resistance.  So, anyway, that's why I thought it was important for
the news.

**Mark Erhardt**: I kind of, while we're diving into this topic, wanted to own
up to the Bitcoin Core fee estimation also having a few issues.  So, the Bitcoin
Core fee estimation hasn't really been updated in, I think, nine years or so.
And one of the problems is, by only looking at transactions that the node has
seen in its own mempool, and then using that data to see when they appear in the
blockchain to estimate how long transactions of certain feerates take to get
confirmed, you can only look back, and that leads to Bitcoin Core tending to
overestimate.  The other one is that the confidence rate that Bitcoin Core uses
is extremely high.  So, it's pretty decent at the left flank of a feerate spike.
It follows the feerate increase pretty quickly, but can only do so after the
block is published.  So, while you're waiting for a slow block, it will not
adapt to the mempool increase, and will not correctly assess that to be in the
next block, you have to pay that feerate for the next block.

But what's really detrimental to users is, on the receding of the feerate spike,
Bitcoin Core tends to overestimate, because it looks at the last blocks with the
high feerates and then trying to have a very high confidence to be in a block of
probably a fairly low target, because the default is the second block.  So, if
you don't set a higher block target be in 6, 8 or 12 blocks, Bitcoin Core can
estimate fairly long of higher feerate just to be confident to be in that block.
So, in the past, when a lot of people were using Bitcoin Core feerate
estimation, this turned sort of into a self-fulfilling prophecy, where Bitcoin
Core would estimate high feerates to be necessary to be in the second block from
now.  People would pay those fees; that would make blocks have fairly high
feerates, and in turn cause Bitcoin Core to estimate that you would have to have
high feerates in order to be in that block.  So, what taking mempool content
into account makes better is this receding of the feerate back down.

Another thing that people really should be doing is you don't really usually
have to be in the second block.  If you estimate for the next 12 blocks, or most
of the time your transaction just has to go through in the next half day, or
whatever.  If you choose a block target according to that, you usually should be
paying a lot less and still get into the block, especially in a day and age
where RBF has gotten much easier and you can easily bump your transaction if it
doesn't confirm quickly enough.

**Gloria Zhao**: I just want to add on to that point, Murch, since you were
talking about the fee estimation code being really old and being written a lot
of time, a lot of it before we did RBF as a policy, and if you think of
broadcasting transactions for confirmation like an auction for block space, you
don't just get one bid.  Back then, it was the case that you would just get one
bid, but after RBF, now you can start low, and if you see that you don't get
your block space, you just add a little bit incrementally over time until you
get the result that you want.  And another change that we did merge this year,
I'm not sure, it's very small, so it's probably not in the review, was updating
the default mode.  So, we had a conservative mode in Bitcoin Core that the idea
was, if you're not going to be able to replace it, you use this mode and you use
1 bit; you have to be, what is it, 95% certain or 99% certain that it's going to
be in the block target that you want.  And that was switched off, because we
live in a world now where you can expect to be able to replace your
transactions.

**Mark Erhardt**: That of course changes the UX a little bit, because you now
actually have to come back and look again.  So, if you don't want to do that you
could still use conservative, but really I think most people -- like, maybe it
would be really nice if the wallet eventually were able to fashion three, four
versions of the same transaction and then unilaterally, after some time,
broadcast the later versions with a higher feerate if the transaction hasn't
gotten gone through.  You could very easily implement that by timelocking them
to a later block height and then just making your software broadcast them as
soon as they're valid.  But anyway, that would be nice.  Let's move on.

_More efficient transaction sponsorship_

**Mike Schmidt**: Yeah, good discussion though.  Last item from March was, "More
efficient transaction sponsorship".  And we highlighted Martin Habovštiak's
proposed method to boost an unrelated transaction using the taproot annex.  And
this touched on some of the proposals under the fee-sponsorship umbrella that
we've covered previously, and I think, Dave, you've kind of had some back and
forth with a bunch of these proposals.  Do you want to talk about what we're
trying to do here with fee sponsorship and transaction sponsorship?

**Dave Harding**: Sure.  This idea was originally proposed by Jeremy Rubin a
couple years ago as a fee sponsorship, and Martin independently kind of
recreated it.  And because his idea came out after taproot, he found a
taproot-native way to do it that's a bit more efficient.  Prior to Martin
publishing on that, Jeremy and I had had a talk and found an even more efficient
way to do it.  In theory, our way can do it adding zero bytes to a transaction.
And what fee sponsorship is, it's basically CPFP, except without a relationship
there.  It just allows one transaction to contribute fees to the confirmation of
another transaction as long as they are both included in the same block.
However, in one of these discussions that we linked to, Suhas Daftuar in
particular had some concerns about this, in particular related to reorg safety,
which is a principle that we've long had in Bitcoin development, and just making
sure it worked well with cluster mempool.  AJ Towns says he thinks it does, but
this is something that you have to implement to make sure it actually does and
test it and go through all that review process.

I think it's an interesting principle again for the future when we're looking at
large contract protocols.  We have lots of people who want to get their
transactions confirmed on chain in a very efficient way in chain space, so this
idea could allow potentially one transaction to boost the priority of a bunch of
unrelated transactions.  And again, it's a fee management thing.  It's not
something that's ready to go now, it's something that requires further research.
I hoped to do some of the research myself, I hoped to do that this year, I
didn't, so maybe next year.

**Mark Erhardt**: I think one of the concerns around that is whether or not
everybody should be permitted to attach even indirectly another transaction to
your transaction, because for example, if you don't limit people contributing,
so if multiple transactions could contribute to another transaction, that could
allow you to create a lot of transactions that by replacing the original, just
disappear again.  So, it might cause more free relay surface.  Another is, if
there's only a single transaction permitted to contribute fees to another
transaction, someone could take that slot and then confuse people that are
trying to send a transaction in the first place, by removing it later and
changing the priority, the perceived priority of the original transaction.

There's a lot of surface being introduced by anybody being able to attach
transactions to anything else, and there's a big discussion around all this to
make the trade-offs work out in a way that we get all the behavior we want, but
not the behavior we don't want.

_Consensus cleanup_

**Mike Schmidt**: Moving on to April, we talked about the consensus cleanup and
Antoine Poinsot picking up the torch on the 2019 great consensus cleanup
proposal, that fixes concerns around slow block verification, time warp attacks,
there's a merkle tree vulnerability that could affect light clients and full
nodes.  And then we also mentioned in the writeup, Murch, your Zawy-Murch
variant of the time warp vulnerability that we, I believe, discussed on the
podcast recently.  Does anyone have anything to augment on here?  How does
everybody feel about cleaning up consensus?  Thumbs up?

**Mark Erhardt**: I think that a little more work needs to be done to make the
proposal done well-packaged and complete and well-motivated.  But other than
that, I think it's a fairly uncontroversial soft fork proposal.  And yeah, we'll
probably see more about this in 2025.

_Reforming the BIPs process_

**Mike Schmidt**: Next item was reforming the BIP editors, who we mentioned
earlier, began to see the potential to reform BIP2, which is the BIP that
specifies the process for adding and updating BIPs.  Murch, this seems like a
good one for you.  Is there a tl;dr on what is in the publication draft BIP that
came out in September?

**Mark Erhardt**: Well, the publication draft BIP got a bunch of review.  That
review has since been addressed, and I actually opened a PR to the main BIP
repository.  And so, I would love for some people to read it, to comment on
what's good, what's bad, what needs to be improved.  There's a little bit of
knitting here and there about the exact name of the second ownership role that
has been introduced, and whether or not that's necessary in the first place.
Several contributors to the BIP repository felt that a BIP could be owned by
people other than the original authors, and that has happened a few times in the
past, with authors disappearing from the face of the net, or just people moving
on, working on other stuff while stewards took care of their BIP meanwhile.  And
having a separate role for that was a request that multiple people surfaced in
the process of writing this.  That seems to be one of the main discussion
points.  It's a fairly long BIP, it has most of the things that BIP2 had.
There's a few things that have been taken out that didn't get used much.

Please, I'd love some more feedback.  Other than that, maybe I could get a BIP
number.  I'll have to lobby my co-editors sometime soon, maybe early next year.

_Inbound routing fees_

**Mike Schmidt**: Inbound routing fees.  We talked about LND and their work
around inbound routing fees and introduction for support this year for inbound
routing fees in LND, which allow LND node operators to charge channel-specific
fees for payments received from peers.  And the goal here is to help nodes
manage their liquidity better through additional financial incentives.  From
what we've covered, I don't think there's been too much support in the other
implementations.  Is that right?  Is anybody aware?  Or is it just LND?

**Dave Harding**: None of the other implementations were planning direct support
for it.  Matt with LDK said they were going to support the fee discounts because
he's like, "Hey, free money", but I don't think they were ever planning to fully
support it.

_Weak blocks_

**Mike Schmidt**: Weak blocks is a topic that we covered in the year in review,
motivated by Greg Sanders, and he posted about using weak blocks to improve
compact block relay, and the discussion, and I think we get to it later, about
improving compact block relay was motivated by increasingly divergent
transaction relay and mining policies in the last year.  But maybe we should
talk about what is a weak block.  Does anybody want to explain weak block and
its relation to compact block relay?

**Dave Harding**: Sure.  A weak block is an attempt that a miner made at mining
a block, and they make billions, gazillions of these all the time, that came
close to having enough proof of work (PoW) to be a block, but didn't quite make
it.  So, they're basically equivalent to a share that a miner would send to a
mining pool.  And a weak block would be broadcast over the P2P network, sent to
nodes, and it commits, just like a regular block, to all the transactions that
would have been in that block if it had been a real block.  And this allows
nodes to know that miners are actually working on those transactions.  And if
there are transactions in that block that a node didn't already have, it would
be a convenient time for those to be relayed.  The node could accept those into,
perhaps, a temporary staging pool, not its regular memory mempool, because they
weren't standard or they weren't normal.  But it could hold onto those in case
that miner was later successful at finding a block and those transactions were
included, and this would allow compact block relay to work more efficiently and
would give us a better idea of what miners were working on.  Murch?

**Mark Erhardt**: Yeah, also not only would it allow the node population in
general to learn about the transactions that miners are working on, but it might
actually transfer those non-standard transactions into the mempools of the other
miners.  So, if there's very juicy transactions that some miners are
considering, they would be transferred and become available to other miners, if
they include them in their weak blocks, of course.

**Mike Schmidt**: Now, that would be a downside for a miner broadcasting that,
right?  They're sharing these juicy transactions with other miners, and then
other miners want to pick up and include those in their block, so that's a
downside.  But I guess if I'm a miner, I want to broadcast weak blocks, not in
the analogy of the mining pool and the shares, you eventually get paid in
proportion to your shares, but with the weak block, you're broadcasting because
you want the network to be aware of all the transactions that may be coming from
you, so that if there's sort of two blocks at the same time, that your
transactions are out there and maybe that block becomes the chain tip.

**Mark Erhardt**: Right, it would make your block propagate more quickly.  Of
course, if you're trying to monopolize fees of transactions only you've seen,
you would probably not want to include them in weak blocks, so you would just
not publish your weak block that includes them; or if someone asks you for those
transactions, not hand them over, which shouldn't be too consequential since
it's only a weak block.  But it might be a good way of not dropping all of the
mempool policies that protect nodes in various ways and protect the network
against non-standard flooding attacks or DoS attacks, but to allow the
propagation of non-standard transactions that are actually being considered by
miners.

_Restarting testnet_

**Mike Schmidt**: Restarting testnet3.  Jameson Lopp pointed out that Testnet 3
was having some issues.  He listed a few different things that I pulled out.
One was that testnet bitcoin, the actual tokens, were actively being bought and
sold.  I believe there's some shenanigans with airdrops happening as well with
testnet coins.  There was also this ongoing issue of block flooding because of
the testnet's custom difficulty adjustment algorithm.  I believe some folks were
abusing that for fun and LOLs.  And then, Jameson also noted that mining, on
testnet at least, was not doing a good job of distributing coins to people who
may want to mine some coins and then use those testnet coins to do some test
transactions, because the reward was so small as to be negligible.  And so, we
covered all of those discussions of the issues through Fabian announcing a draft
BIP for a testnet4, and then the BIP being merged and Bitcoin Core having an
implementation of testnet4 by towards the end of the year.  Everybody good?

**Mark Erhardt**: I mean, I'd have lots to say, but I'm not sure.  I'm talking
so much, we're already an hour in and we're only in April.  So, maybe very
quickly, it was very much time to reset testnet and probably we should have done
it a few times already since testnet3 came out, and we're having a little bit of
issues around starting testnet4.  Mining seems to be fairly monopolized and it's
hard to get testnet3 coins and testnet 4 coins now, so maybe we'll have to do it
a few more times until the sort of behavior where people are trying to
monopolize common goods really -- testnet is supposed to be valueless, so it's
easy for everyone to get coins, and people trying to monetize it just really
hurts this common good.  And maybe we'll just have to nuke testnet4 as well and
go for testnet5, and then maybe testnet6, and after that, maybe the picture is
clear.

_Developers arrested_

**Mike Schmidt**: Last item from April was highlighting the arrest of two of the
developers of Samourai Wallet, which were arrested earlier in April because of
the work and some other activities around their coinjoin software
implementation.  I think we also noted in that writeup, and I know we did in
this year in review, that there were also then shortly thereafter some
organizations that essentially did not allow or announce that their software was
not available in the US, due to some of these related legal risks.  Obviously,
this is not a legal or policy podcast, but I think, Dave, you were probably
right to surface this news to the pool of engineers and developers and
businesses potentially working on similar software and maybe having similar
concerns.

_Summary 2024: Cluster mempool_

All right, wrapping up April, we are moving on to another special feature.  This
one is cluster mempool.  There's a lot to talk about here.  I think we have
three very qualified people to talk about this, but I did ping Murch beforehand
and say that I thought he was my guy, at least to walk us through the high
level, and I'm sure that Gloria has some thoughts as well.

**Mark Erhardt**: Yeah, so cluster mempool is a proposal that has been in the
works for a little over a year actively.  And the main idea is basically, when
we try to evaluate transactions and think about how replacements are resolved,
and generally when we're building block templates, we really want to know at
what feerate every single transaction in the mempool would be included in a
block.  And right now, the only way for us to tell that is basically to act as
if we were mining a block until we get to that transaction, and then we know at
what feerate that transaction effectively would be included.  The problem is
that it depends on ancestors, it depends on descendants that might have higher
feerates, but then also it depends on the descendants of ancestors and on the
ancestors of descendants, and so forth.  So, it's really difficult to tell what
the mining score of a transaction ultimately would be.

So, cluster mempool takes a new approach to this, which is basically, what if we
just ordered the whole mempool and remember at what feerate everything would be
mined?  And thinking that to the logical conclusion means that we work
differently with transactions where we previously mostly considered transactions
in the context of their ancestors.  We now consider transactions in the context
of their cluster, which is all the related transactions through parent and child
relationships that an unconfirmed transaction is connected to.  And it turns out
if you just look at transactions in the context of the cluster, you can sort
each cluster into a linear order, and then you can read off the feerate at which
everything will be mined.  That makes it a little quicker to build block
templates, it makes it hopefully much easier to evaluate package replacements in
the context of these clusters, it makes it easier to keep transactions in groups
that get mined together, so-called chunks, because where we previously had to
recalculate each ancestor set for all descendant transactions whenever we picked
something into the block, these chunks stay at the same feerate because they
group together naturally.

Anyway, this proposal has been worked on a lot.  There's a lot of really good
research going into it with simulations of past data, lots of fuzz testing.
There are some new developments that came out of the Bitcoin Research Week
recently, about being able to linearize bigger clusters more efficiently.  So,
this is very much still a research project, even while a bunch of the PRs have
already been merged into Bitcoin Core.  And while there was some hope that it
might already be finished, the new discoveries might push it a little further,
but I am still hopeful that we'll get it next year.

**Mike Schmidt**: Gloria, did you have any thoughts?

**Gloria Zhao**: Sure.  My summary, I'll keep it short, is that today we have
these pretty fast operations for all mempool changes, and we basically choose to
dynamically do a linearization whenever we need to do something like mining or
eviction, and of course there's so many problems with that.  But we'd like to
live in a world where everything's ordered all the time, so we don't have this
dynamic calculation, we can very easily assess incentive compatibility, is this
replacement better?  Is this transaction at the bottom of our mempool, so we
should just kick it out when we're at capacity?  But the thing that we have to
give up is that we need to have cluster limits.  That's kind of fundamentally
pretty much the only thing that we have to give in exchange for all of these
amazing capabilities that we would have with cluster mempool.  And of course, I
alluded to this earlier that we can have a much better RBF policy, along with
other things.  We can linearize packages before we submit them, all these
things, but we have to have a cluster limit.  And we also can't have a carve-out
for that limit.

I'm just reading the newsletter right now.  And so, cluster mempool also meant a
reorganization of how we were tackling all the package relay stuff as well,
where we wanted to have this milestone of being able to get rid of carve-outs.
And that's why we have all the 1p1c (1-parent-1-child) TRUC things that were
pushed in first, and then we have cluster mempool, and then we're doing general
later.  That's all I'm going to add.

_Silent payments_

**Mike Schmidt**: Moving on to May.  First item is around silent payments, which
made a ton of progress in the last year.  We talked about PSBT extensions for
silent payments; we talked about protocol spec for lightweight clients receiving
silent payments; changes to the silent payment spec that was made as a result of
some of these discussions; I think there were a bunch of client and services
highlights in our monthly segment that were wallets that not only were
implementing silent payments, but in some cases were a silent payment wallet
designed to be a silent payment wallet as primary usage.  So, that was pretty
cool.  Any comments on silent payments and progress around that?

_BitVMX_

Next item from May, BitVMX.  This was a post from Sergio Lerner, who was a
co-author on a paper about a new virtual CPU architecture, based in part on the
ideas behind BitVM.  As a result of a lot of this discussion in the last year,
we added a related topic to the Optech site this year titled, "Accountable
Computing Contracts", which, Dave, I believe is a term that you coined.  What
are Accountable Computing Contracts, and how does that fit into BitVM and
BitVMX?

**Dave Harding**: I'm always trying to classify stuff and I'm always making up
random terms.  I'm sure Gloria loves Kindred RBF, which is my idea.  So, these
are a bunch of contract ideas that we have out here, that one party can hold the
other party accountable if they don't do the computing correctly.  So, you can
create a program and have someone run it, and you can base a contract based on
the execution of this arbitrary program.  However, the party who runs it is just
saying, "I ran it and it said, 'Yes, I get all the money, trust me'".  And so,
what accountable computing gives you is a way to verify that, so the other party
can also run the program.  And if they think the first party lied, they can go
through and try to find the point in the execution stack where it diverged from
what was supposed to happen.  And then you can use that to enforce a penalty.

So, BitVM gives you this, BitVMX, stuff like Salvatore Ingala's Elftrace gives
you the same thing that; will be with consensus changes.  And they're all very
interesting and people have been trying to build things on top of them.
Sometimes, they've been trying to build things on top of them that I'm not sure
will work, but some of the stuff is pretty interesting.  So, that's what they
did.  They did another one of these, I think we talked about BitVM in last
year's year in review, and people were just continuing to work on this.  I don't
know, Murch, did you have a comment?  No, okay.

_Anonymous usage tokens_

**Mike Schmidt**: Next item from May titled, "Anonymous usage tokens".  This is
the idea that you could have the ability to prove that you can control
keypath-spend of a UTXO without having to reveal what that UTXO is.  So, one
potential use of that would be in Lightning.  Right now, Lightning uses proof of
ownership of a UTXO to prevent DoS attacks.  And so, you could now say, "Hey, I
do own a UTXO, but I'm not going to tell you what it is", and so you get that
same DoS prevention without the privacy loss that comes along with identifying
your UTXO.  Pretty cool idea.  And there was also a similar proof of concept
later in the year by Johan Halseth, and I believe his was a zero-knowledge proof
(ZKP) version of achieving similar goals.

**Mark Erhardt**: I think something other than that, that might be really useful
is, with Bitcoin being the native currency of the internet, it could serve as a
sort of proof of some cost or person or bitcoiner if you, for example, had a
proof that you hold at least one millibitcoin of bitcoin, or something like
that, it could be used as a requirement for a verification status on social
media.  Or, like, one of the demos that Adam Gibson did was to require this to
sign up to a forum.  One of the problems we've been seeing on some social media
is that these networks are flooded by bots.  And if you require this sort of
overhead or give special privileges to people that perform this overhead, you
could potentially curb this bot traffic.

_LN channel upgrades_

**Mike Schmidt**: LN channel upgrades.  This was the next paragraph that we
highlighted this month, which was a way to upgrade a Lightning channel without
having to go through the rigmarole of closing the channel and then reopening the
same channel between two counterparties.  One example that we give, I believe
from the topics, was the example of channel parties both agreed to upgrade from
legacy channels to taproot-enabled channels; you can upgrade the channel as
opposed to closing and reopening.  We covered work around this topic with the
quiescence protocol that was added to the Lightning spec, which is essentially a
way to pause the channel, is the way I think about it, in order to facilitate
these sort of channel upgrades.

**Dave Harding**: One other example of what could this be used for would be
upgrading LN channels to use TRUC.  That would be, you know, use v3 commitment
transactions, and there's just a lot of cases.  In fact, that was discussed when
I discovered a vulnerability this year.  And one of the things we were talking
about is obviously, if we can get the TRUC, we can completely get rid of this
vulnerability class by having -- and then pay-to-anchors (P2As) and stuff.  But
people have existing channels.  How do they get to there?  Well, we need channel
upgrade things.  And we were talking about in the private disclosure process,
what exactly that looks like for LN.  And now that that's open, that's out in
the open, hopefully people can discuss that and talk about that.  I think it's a
really important feature of LN to be able to upgrade channels without having to
close them down.

_Ecash for pool miners_

**Mike Schmidt**: Ecash for pool miners was the next topic we covered in the
newsletter.  This was motivated by a post from Ethan Tuttle, that suggested that
mining pools could, "Reward miners with ecash tokens proportionate to the number
of shares they mined.  The miners could then immediately sell or transfer the
tokens, or they could wait for the pool to mine a block, at which point the pool
would exchange the tokens for satoshis".  Anybody have any thoughts on that
mechanism?  I think the biggest criticism, point of feedback there, and I forgot
who pointed it out, maybe multiple people, but it's just the reward per block
isn't necessarily something that's very deterministic in a lot of these payout
schemes.  So, it would be what tokens would you give for that particular block,
as a bit of a question mark.

**Mark Erhardt**: Yeah, I think the problem is, I think it was introduced sort
of as a solution how you could pay out immediately.  But really, a lot of mining
pools resolve the payout later when they know when the next block was found by
the mining pool, or other things like that.  So, there's a whole other dimension
to how this isn't really the main problem that they're trying to solve.

_Miniscript specification_

**Mike Schmidt**: Miniscript specification.  Murch, I wanted to pick your brain
on this one.  So, Ava proposed a BIP for miniscript in May and it was merged and
signed BIP379 in July.  I think a lot of listeners may think, "Well, miniscript,
that's been around".  And so, I guess, why May and July for the BIP?  What was
the BIP waiting for?  Was it just a matter of the time to write up a BIP, or
were there actual topics still being debated that it took, "Not this long to get
a BIP"?

**Mark Erhardt**: I think the miniscript language basically had been specified
by there being, I think, three different implementations of it, and then being
cross-compatible, and research going back and forth, and it essentially being
fully described through these three implementations.  What had been missing was
the textual specification, so Ava finally just got around to writing it up
properly and publishing it.  And given that, there's three implementations of it
already that are cross-compatible and well-vetted, even deployed in some cases.
I think that's why it so quickly moved to being merged.

_Utreexo beta_

**Mike Schmidt**: Last item from May was the beta release of utreexod, which is
a full node implementation with support for utreexo.  Utreexo allows a node to
store just a small amount of commitment data to the state of the UTXO set,
instead of storing the entire UTXO set itself, which is a huge space savings.  I
think it's potentially 32 bytes that you're storing instead of gigabytes of
information.  I mean, I'll open the floor for feedback.  What does everyone
think of utreexo?  It seems like it's potentially under discussed for how cool
it seems?  Am I missing something?

**Dave Harding**: Maybe.  I think it's a very exciting research project.  It
does allow minimizing disk space, but you have to ask how many people have 32
bytes but don't have 5 GB or don't have 10 GB at the need to run a more typical
pruned node.  There are cases of that, but a lot of people who want to run a
full node -- and utreexo is still a full node, it still has to download every
block -- the trade-off for less disk space is more bandwidth.  So, how many
people want to make that trade-off just because they don't have 10 GB, which to
me, it seems pretty cheap today.  So, I think it's a very interesting project
and there probably are niche applications where it would be very useful.  A lot
of this research into utreexo might be useful for various types of fraud proofs.
And in that case, it can be extremely useful because you don't want to store any
data for that.  But I think it's a very good research project.  I'm glad Calvin
Kim and several other people are continuing to work on that, and I'm excited to
see what they come up with next year.

_LN payment feasibility and channel depletion_

**Mike Schmidt**: Thanks, Dave.  That enlightened me.  I knew you'd have a good
answer for that.  Moving on to June, "LN payment feasibility and channel
depletion", was the first topic we discussed.  This is around René Pickhardt's
research around estimating the likelihood of a Lightning payment feasibility by
his analysis of possible wealth distributions within channel capacities.  We had
René on to discuss this, and other of his Lightning channel research findings,
in an Optech deep dive podcast, which we started these deep dives this year.  We
did two of them.  This one with René was on channel depletion, and was just a
few weeks ago, so check that out if you're interested.  Dave, did you have
anything you wanted to say about this?  I know we've had you on to talk about it
already and you were on the deep dive as well, so.

**Dave Harding**: Basically, the same remark that I had about Calvin Kim.  I'm
really glad that René is out here researching the fundamental limits of
Lightning, and then figuring out how we can really push Lightning to the edge,
how to figure out how to get the most out of it that we can.  A lot of times,
engineers are focused on the day-to-day problems and I think that's great,
that's wonderful, but knowing what the fundamental limits of your system are,
well, it can help you from banging your head against them in the future, and it
can just help you discover novel and new things.  I was really, really excited.
Some of René's research pointed to channel factories being even more important
than we thought they were.  We knew they were important for certain scalability
constraints, but they also potentially make LN much more able to route payments
for a longer time without problems.  So, excited to see this research.  Glad
René is continuing it.

_Quantum-resistant transaction signing_

**Mike Schmidt**: Quantum-resistant transaction signing.  Hunter Beast wants to
assign v3 segwit addresses to a quantum-resistant signature algorithm.  The
specific algorithm and details is left for a future discussion.  I have not
followed along on this since we covered it earlier in the year to see if there
has been a selection, but at the time, the draft BIP had links to several
potential algorithms and analyzed the different size of the onchain footprint,
using those different quantum-resistant algorithms.

_Summary 2024: P2P transaction relay_

Next segment was a special call-out to P2P transaction relay, and although she's
already contributed a ton to this discussion in this podcast, the motivation for
bringing Gloria on was to talk about this segment and a lot of her personal work
on it.  Obviously, a lot of other contributors, we talked about Greg Sanders and
some of the work he's done, but Gloria, this is a lot of work that you've been
putting in over the years.  How would you distill it down into just a few
minutes for our audience.

**Gloria Zhao**: Yeah, we got a lot done this year, which is really, really
awesome.  I apologize for cutting in so much in the preceding section of this
talk.  I think what we have at the end of 2024, with the release of 28 and
what's in master, is essentially all the features that we want just for a
limited topology, which is pretty exciting, I think.  So, maybe I'll start with
TRUC.  I think what we accomplished in 2022 and a little bit of 2023 is I think
really thoroughly understanding the problem space, which is kind of the start of
BIP431.  We don't really have a good way of assessing incentive compatibility,
we can't look at packages when we're looking at transactions, there are a bunch
of pinning issues with L2 protocols that they can run into, and it's not really
bad, how do we fix that?

TRUC kind of comes from this place of, okay, so we have all this because Satoshi
allowed unconfirmed UTXOs to be spent, and allowed pretty much anything goes.
And we added ancestor-descendant limits and we have ancestor-descendant
dependency tracking in mempool, but it's not very good and it's still really
permissive.  So, what if we lived in a world where Satoshi said, "No spending
unconfirmed outputs", how would we build mempool policy if we wanted to add that
capability for Lightning or for L2s, and we only wanted to, say, do an
ancestor-descendant tracking type thing?  And part of it was like, how do we get
cluster limits without actually doing a cluster-based mempool?  And of course,
luckily, Suhas and Peter ended up going for a cluster-based mempool, but that
topology is 1p1c.  And of course, if transactions were smaller and not allowed
to be very big, then we also wouldn't have the pinning issues.  And that's
basically what the rules of TRUC are.

If we live in this world where you're only allowed to have one parent and one
child, then you can have everything.  You can have the packaged CPFP, you can
have packaged RBF, you can have zero-fee transactions really easily, and what
else?  Yeah.  And so, we did that.  So, TRUC is the topology restriction that
you can opt into to live in this other world.  And if you're a node and you see
v3, which is a TRUC, then you treat it a little bit differently, and you can
feel very confident in your ability to assess the incentive-compatibility of
this transaction, of its replacements, of potential topology breaks.  You can
have a kindred RBF, as Dave likes to call it, or I called it sibling eviction,
which actually I think Greg Sanders coined that term, and which is just a much
more sensible policy.  And let's see, this allows us to not need CPFP carve-out
anymore, which is kind of the only barrier that we really had in order to switch
from this ancestor-descendant-structured mempool to a cluster-based mempool.
So, this is a nice milestone of features that we can then transition to cluster
mempools from.

We also have a lot of Greg's awesome work in anchor outputs.  So, one is a
dedicated keyless output type for anchors.  An anchor output is one that you use
specifically for adding exogenous fees later, use it to CPFP.  And a few of the
problems related for that was that it was key that it would be nice if anybody
could bond the transaction, for example; it'd be nice to only have one; it'd be
nice to not use CPFP carve out; and of course, it would be nice if you didn't
need to put amount into that output.  And we talked about this earlier with
LN-Symmetry specifically having this problem where if you need to shave off a
certain amount of the balance into anchor outputs at every stage, then you just
leak funds as the channel gets older.

So, ephemeral dust is the second part of ephemeral anchors.  It was split this
year, where we essentially allow each transaction to have one dust output,
provided that we can expect it to be spent and that this transaction is not
going to confirm without the child that spends that dust.  And that uses TRUC.
P2A is completely independent from TRUC.  Ephemeral dust is currently a
TRUC-only policy rate.  Oh, and then we also have package relay support.  Sorry,
it's the macOS thing.  We also have limited opportunistic package relay support
for 1p1c transactions.  It doesn't require any protocol changes.  So, we did get
BIP331, ancestor package relay, merged this year, but that's not implemented.
What we have in Bitcoin Core today is this smart, intelligent way of grouping
parents and children together, where the parent is low feerate and the child
bumps it.  It's not a protocol change, and it also doesn't use any additional
bandwidth, compared to what nodes would have done before.  So, it's just kind of
a pure win in my view.  And then we're looking forward to a lot of additional
features and changes next year, the cluster mempool and hopefully more
generalized package relay and more robust package relay as well.

**Mark Erhardt**: I kind of find it interesting, when I hear you talking about
this topic, how our terminology has evolved in the last year about this topic.
I think that, for example, the term exogenous and endogenous fees wasn't really
used before, but it nicely crystallizes these concepts and makes it easier to
talk about certain aspects of package relay, cluster mempool, and so forth, P2A.

**Gloria Zhao**: Yes.

**Mark Erhardt**: And, yeah, so I just find it interesting on how the attention
this topic has been getting in the past year has evolved the understanding in
the community.

**Gloria Zhao**: Yeah, I was actually really pleasantly surprised by how much of
the LN community, including people from all of the implementations, were
reacting really positively to these things.  I know it's not perfect, like 1p1c
is pretty restrictive, but it does do a lot of things that just didn't exist
before.  I know now, as of last week, that there was also vulnerability that
maybe motivated this.  And the attention from Ark and other L2s as well has been
surprising and really positive.

**Mark Erhardt**: Yeah, I was asking around, I gave a talk in the context of the
Bitcoin Research Week about what happened in Bitcoin in 2024, and I asked some
acquaintances about what the most important thing in Lightning had been that
year.  And I heard multiple times that the mempool changes in Bitcoin Core were
the biggest thing that happened in Lightning.

**Mike Schmidt**: Gloria had mentioned a vulnerability.  We had Dave, who was
the researcher who discovered that, on last week in Podcast #333, which is I
believe the vulnerability you're referencing, Gloria.  So, check that out if
you're curious about that.  We talked about the flurry of activity that happened
earlier in the year.  And Gloria walked us through the high level of a lot of
those features.  Gloria, also, we had you and I think Greg on at the same time,
or at least close enough, to go through our guide for wallets employing Bitcoin
Core 28.0 policies.  So, that was a special blogpost that we put out.  If you're
curious more about 1p1c relay, etc, there's text and there's also sample code
bitcoin-cli commands to run, to kind of see how things would work with and
without these features enabled.  So, check that out if you're curious.

One other note, there's a lot of reasons that you might want to have Gloria or
Greg Sanders on your podcast when you're talking about Bitcoin stuff.
Obviously, a lot of the times that Gloria and Greg joined us this year was to
discuss these features being developed and added.  They were both one and two
most attended guests, special guests on our podcast.  So, thank you, Gloria, for
joining us.  And I guess it was almost a couple times a quarter that you joined
us.  So, we appreciate that.

**Gloria Zhao**: Thanks for having me and being willing to hear me yap so much!

_Blinded paths for BOLT11 invoices_

**Mike Schmidt**: That wraps up that special segment.  And we can move on to
July, where we talked about blinded paths for BOLT11 invoices.  Elle Mouton
proposed a BLIP at the time to add blinded path fields to BOLT11 invoices, which
would allow the recipients of a payment to hide their node identity and also
their channel peers.  It's essentially applying the same blinded path originally
from the BOLT12 spec to BOLT11 invoices.  So, it seems like an okay idea.  I
think there was some pushback on maybe the order of operations there, but at
least it's there in one implementation now, I think.

_ChillDKG key generation for threshold signatures_

Next item we talked about was ChillDKG key generation for threshold signatures.
ChillDKG describes how participants, in a setup like a FROST threshold signature
setup, can generate the keys.  So, FROST is a way to have something like a
3-of-5 multisig, but with only a single onchain transaction, so that's pretty
cool.  And ChillDKG is a way to generate the keys that you would use in that
sort of a setup, which leads somewhat to the next item that we covered, which
also included a proposed BIP for creating threshold signatures, which is the
natural sort of follow-on from the ChillDKG key generation.

_BIPs for MuSig and threshold signatures_

Also in this item, we talked about the BIPs that were for MuSig and threshold
signatures.  We talked about the threshold signatures one.  Also around MuSig,
we had BIPs328, 390, and 373 all merged, all around MuSig2 signatures.  So, a
lot of interesting cryptographic updates in July, and we can move on to August.

_Hyperion network simulator_

August's first item was Hyperion network simulator.  Hyperion is a network
simulator that tracks how data propagates through a simulated Bitcoin P2P
Network.  And I could see a variety of uses for this, but the stated motivation
was to compare and contrast relay as it is now, transaction relay, with the
proposed relay that would occur under Erlay's set reconciliation relay approach.

**Dave Harding**: I think it's great to have tools like this and things like
warnet for experimentation, in situations where it's just really hard to analyze
this in your head or just type out some random numbers and hope that they add up
correctly.  And so, I'm really glad people are building tools to help us make
better analyzed changes to the protocol in the future.

_Full RBF_

**Mike Schmidt**: Last item in August was full RBF, and the discussion around
mempoolfullrbf was, in this case, motivated by 0xB10C, who does a lot of
interesting monitoring and logging on the Bitcoin Network.  And he investigated
the recent reliability of compact block reconstruction, in fact not reliability,
but I guess decrease in reliability of compact block reconstruction.  He noted,
"There was a decrease in successful compact block reconstructions for nodes
running Bitcoin Core with its default settings, especially when compared to a
node running with the mempoolfullrbf configuration setting enabled".  And we
note in this year-in-review writeup that the research helped motivate the PR
that enabled mempoolfullrbf by default in Bitcoin Core, which was later merged.

Next item in the year in review was our Covenants and script upgrade special
call-out for the year.  We had Rearden on at the beginning of this discussion.
So, if you're jumping around in the podcast, listener, refer back to that
earlier in the episode.

_Hybrid jamming mitigation tests and tweaks_

That brings us to September, where we talked about a bunch of channel jamming
items.  Specifically, there was an attack-a-thon, I don't remember what the name
of it was, but essentially tried to jam channels.  And it was found that the
jamming attacks were mostly mitigated, with the exception of this sink attack,
which was a way to undermine a node's reputation essentially, by routing around
that node.  And that led to some discussion about HTLC endorsements.  And I
think there was even some implementations by the end of the year for folks
starting to relay those endorsements.  We covered it, if it wasn't last week, it
was the week before.  Murch, I know you have some close proximity to some of
this research.  Do you want to take a crack at summarizing the progress?

**Mark Erhardt**: Sure.  So, jamming attacks basically mean that someone is
making fake payments that they do not intend to go through with in the long run,
either at a high frequency for fast jamming, where they just jam up all the
slots in a channel, which is limited; or slow jamming, by tying up all of the
balance in a channel, or the capacity I should say, by making a very large
transaction or several large transactions that they then just hold and do not
let go through until it times out, briefly before timing it out and cancelling
it.  And the idea is with the HTLC endorsements, that instead of allowing all of
the capacity and all of the HTLC slots to be used by any peer, you reserve half
of each of those only for peers that you have perceived to be good participants
in the past.  So, people would earn a reputation, and a local reputation, not a
network-wide reputation, that you use to assess whether or not you give them
access to this additional channel capacity or slots.

So, the attack-a-thon actually surfaced some issues.  The basic idea works, but
they had to re-architect some parts of it.  And now, I think one of the
interesting things that came out of the attack-a-thon was, previously they
looked at the sender's side to see whether they wanted to endorse an HTLC; and
now it's turned around, they look at the receiver side on whether or not to
endorse an HTLC, and that fixed a bunch of the issues around trying to farm a
reputation.  Yeah, and this is making progress.  There's some basic
implementations basically to measure how well it would work, whether it would
allow people to actually accumulate sufficient reputation in order for the
system to have a benefit, and that's what we're seeing now in the
implementation.  So, the implementations have it, but only for collecting the
research data.

_Shielded CSV_

**Mike Schmidt**: Next item from September was titled, "Shielded CSV", which is
a new client-side validation protocol.  It was proposed in a paper involving a
bunch of folks doing zero-knowledge stuff, Robin Linus, Liam Eagen, Jonas Nick.
And CSV, I think we've covered a lot of work.  I think Taro, or I guess it's
Taproot Assets, has something similar where you can keep track of the history of
a chain of tokens, including tokens that might not be Bitcoin, on the client
side.  And in those examples, you would have to retain all of the token transfer
history in order to know that if you're getting a token, that it originated
legitimately, and you can see the sort of chain of custody.  I think the
difference here is that Shielded CSV uses ZKPs to essentially prune that
history, and you just use the ZKP to trust or verify that that token has right
provenance.

The paper also outlined how you could bridge Bitcoin to a Shielded CSV, I guess,
sidechain using BitVM.  So, it seems quite interesting and an improvement on
some of the other CSV protocols that we've seen over the years.  Any of the
audience members have comments?

**Mark Erhardt**: I think I recently heard a talk, I haven't looked too much
into this, but my understanding is that essentially it would allow for easy
constructions of stuff like ZK-rollups, maybe sidechains, but also just private
chains of smart contracts that are held out of band.  So, this is also, of
course, related to the two other prominent CSV protocols, RGB and Taproot
Assets.  And I mean, we've had more of those before.  Omni essentially is a CSV
protocol.  Yeah, so the interesting thing maybe is Jonas Nick sounded really
excited about it when he gave his talk.  So, I don't know.  There seems to be
something brewing there maybe.

**Mike Schmidt**: I don't have the episode on hand, but we had Jonas Nick on to
talk about this.  So, peruse through the podcast page and look for Jonas Nick to
get his thoughts on the matter.

_LN offline payments_

Last item from September was titled, "LN offline payments".  And this idea is
that you could have tokens that could be transferred to receivers using
something like NFC, or some other simple mechanism, without being online, which
is pretty cool; you can do payments offline.  And this was a proposal by Andy
Schroder, and he outlined that process through generating tokens while you're
online, and then allowing the spender's wallet to authorize the payments through
their online node.  So, pretty cool.  I haven't heard too much more about this,
but it was a cool idea.

**Dave Harding**: Yeah, we heard that a bunch of other LN developers had had
similar ideas before, and that actually Eclair has somewhat of a support for
this.  And I think CLN also might have somewhat of a support for this.  It's
just a clever scheme for allowing LN payments while one party is offline, which
makes sense because there's going to be a lot of context where the vendor is
going to have a good internet connection, but the payer will not.  So, I think
that's a very useful thing to have.

_BOLT12 offers_

**Mike Schmidt**: Moving to October, we celebrate the BOLT12 spec being
officially merged after being proposed five years ago, which is great to see,
and there was a lot of foundational technology that needed to be merged before
that, including more robust onion messaging and also blinded paths.  I know a
lot of folks in the community are excited to see this.  And we've also, in our
Client services section, noted a bunch of implementation wallet softwares that
are implementing BOLT12.  So, great to see that.

_Mining interfaces, block withholding, and share validation cost_

Next item from October was the new mining interface for Bitcoin Core.  We talked
about block withholding and share validation costs all in one.  The mining
interface, maybe, Murch, I don't know if you can speak to that.  Why do we need
a new mining interface for Bitcoin Core?

**Mark Erhardt**: I'm not super-intimately familiar with that, but the main idea
is that people have been working on Stratum v2 and independently, there's been a
very long time effort on pulling apart the processes in Bitcoin Core into
separate binaries that run in conjunction but have separate threads, and
therefore interfaces that they talk to each other through, and therefore you
could not run some of them if you don't need them, or could plug in other things
that also use the interface.  So, this mining interface is sort of a combination
of those two directions, where people really want Stratum v2 support in Bitcoin
Core, because currently you need to run separate mining software to take the
block templates from Bitcoin Core and distribute them to mining hardware.  But
on the other hand, they really don't want the whole mining stack to run in
Bitcoin Core.

So, I think the mining interface is sort of providing a way of plugging this
potentially separate binary, or dedicated process, into the Bitcoin kernel,
which is like the consensus validation engine.  Gloria, do you have a better
description of this?

**Gloria Zhao**: Pretty much what you said.  I think there's a few rigid ways
that the mining interface kind of works today.  One is of course that you can't,
oh, can you?  Maybe only on regtest, or something, where you aren't able to just
select which transactions you want or don't want, and then send it back.  And
then, there's also this pulling interface, where the miner would have to
periodically ask Bitcoin Core, "Hey, is there a new template?  Hey, is there a
new template?" and there's some caching in place within Bitcoin Core to not have
to recalculate everything every time.  But maybe you want something that's more
push.

**Mike Schmidt**: Dave, we noted in this same segment of October here, under the
new mining interface, that there was some concern that independent transaction
selection could cause higher validation costs for mining pools, and that that
higher cost could then lead to invalid share attacks similar to block
withholding attacks.  Can you walk through briefly how all those are connected?

**Dave Harding**: Sure.  If you're a pool and your miners are able to choose
their own transactions, they can choose invalid transactions, they can construct
invalid blocks.  And the way to deal with that is to have the independent miner
send you all the transactions, or at least any transactions that they included
that you wouldn't have included, and then you need to validate those
transactions.  And it's the same cost to validate it as if you'd receive those
transactions over the P2P network, except the pool miner can submit a completely
different set of 4 MB of transactions every time they send you a share.  They
can send you, depending on your pool configuration, hundreds or thousands of
shares a second.  So, it can be very impractical from a pool perspective to be
validating completely independent transaction selection from these things.

So, there's a couple of things pools could do, but one of the things they might
do is just not validate, or they might selectively validate.  And in that case,
a miner could be sending some shares that include valid transactions and some
that don't.  And then, when that miner finds that the pool miner finds a PoW for
an invalid share and sends it to the pool, well, the pool's not going to get
paid because it's an invalid block as well.  This is basically the same as a
pool miner not sending you a share that is also a valid block, which is a block
withholding attack.  It's pretty functionally the same, but it's potentially a
slightly different payout, or a different payout, for the pool miner than the
block holding withholding attack.  And what it is is an attack against the pool.
It's a way for an attacker to get most of the same amount of money as if they
were an honest pool miner, but the pool to not get the amount of money that they
are supposed to get.

There is an old solution, proposed in 2011, to the block withholding attack.
Basically, it's to prevent the pool miner from knowing when they had produced a
PoW for a block.  However, that would require changing the block header, which
not only requires a hard fork for all the nodes, but it requires a hard fork for
every lightweight SPV client.  So, it's a really challenging fork to get across
the network.  Murch?

**Mark Erhardt**: Sorry if I'm double-clicking on that last thing you said, but
if the mining hardware doesn't know whether it found a valid block, wouldn't it
have to submit every single hash it produces?

**Dave Harding**: No, it's kind of a two-level hash, so it knows when it meets
the first level of threshold of PoW, but only the pool will know whether the
pool server, which will have a secret, will know whether it met the second level
that makes it a valid block.

**Mark Erhardt**: Oh, okay, so it knows when it's a valid share but it doesn't
know whether it's a valid block.  That's pretty nifty.

**Dave Harding**: Anyway, I think the final point here is, it's just a point for
further research and consideration.  Anthony Towns, who was the main contributor
to this discussion, was basically saying that maybe Stratum v2 isn't the way to
go.  Maybe the way to go is to have something like what OCEAN Pool is currently
doing, which is they have a bunch of templates that they produce and you can
choose which one you prefer.  So, if you prefer this one over here or this
transaction, that one over that transaction, if you have a particular
transaction and you want to see the template, maybe you can send it to the pool
and say, "Please provide me with a custom template with just this one
transaction, or just these ten transactions", or something.  I can see how it's
a little controversial, but it does avoid this problem with the DoS and invalid
shares.

_Summary 2024: Major releases of popular infrastructure projects_

**Mike Schmidt**: Next item we spoke about, actually in the newsletter, I won't
go through this, but we did a Major releases of popular Bitcoin infrastructure
projects.  We are of course happy for all of these projects and their releases,
but I think it would be quite tedious to go through them in an audio fashion.
So, I would encourage you to bring up the web page for the newsletter and scroll
down to the Major releases of popular infrastructure projects, and celebrate
those releases and dig into them as you see fit.  That brings us to November.

_SuperScalar timeout tree channel factories_

First November item was SuperScalar timeout tree channel factories.  And this is
a proposal from ZmnSCPxj, who proposed a new channel factory, and it's designed
to be implemented by a single vendor without large protocol changes.  Under the
hood, it uses timeout-trees, current LN-penalty channels, and also duplex
micropayment channels.  And after he came up with this idea for a channel
factory, he later proposed a pluggable channel factory tweak to the LN spec, so
that you could be able to plug in your own channel factory to different LN
implementations.  With regards to SuperScalar, we did have ZmnSCPxj on our first
Optech deep dive podcast, where we talked about SuperScalar.  So, if you're
curious about his initial ideas and Dave asking smart questions of ZmnSCPxj,
tune into that.  Anybody have additional thoughts on SuperScalar?

**Mark Erhardt**: I think one thing that's interesting in this context is that
SuperScalar basically is, what could we do under the assumption that we're not
going to get any consensus changes?  So, ZmnSCPxj has been researching a lot of
ideas that would work today, and one of the things that becomes obvious when you
analyze them is they do work, but they have a lot of overhead, they're complex.
So basically, they're surfacing an argument for why some of these feature
upgrades, these new opcodes, could really improve the landscape in regard to the
bigger design constructions.  And yeah, ZmnSCPxj, it feels like he's a little
jaded in regard to the hope of us getting a consensus upgrade.  So, I guess we
really should maybe hone in on one proposal and think about that one.

_Fast and cheap low-value offchain payment resolution_

**Mike Schmidt**: Next item from November titled, "Fast and cheap low-value
offchain payment resolution".  This is a John Law proposal called, "Offchain
Payment Resolution", (OPR).  It is a micropayment protocol and it requires both
participants in the protocol to put funds into a bond that can be destroyed at
any time by either participant, which hopefully the mutual assured destruction
of such a setup would incentivize both parties to play nice with one another.  I
didn't dig much more into that one.  I think I was gone when we covered this
news item, so I don't know if anybody has a comment on it.

**Dave Harding**: I initially did not like this idea at all.  I was rah-rah
trustless protocols, but John talked me around on this one at least a little
bit.  And one of the advantages here is it's just very, very efficient inside
something like a channel factory, because you never need to go onchain on this.
You just destroy the funds, and if you've destroyed all the funds in the
channel, well you just leave a UTXO on the set at worst case if the factory gets
expanded.  But otherwise, it's just very, very efficient inside these
structures.  And he's talking about using it only for low value.  So, you put $5
of your money at risk, you know, Mike puts $5 of his money at risk, and you can
trade up to $5 back and forth per attempt, maybe a little bit less than that, to
keep the incentives pure.  I think it's an interesting idea to explore.  I still
like trustless protocols more.

_Summary 2024: Bitcoin Optech_

**Mike Schmidt**: We didn't have any items from December that we highlighted in
the year in review, but we did have one final feature that is sort of a summary
of all the contributions that Optech contributors have made to Bitcoin Optech.
I'll shoutout a bunch of them now.  The notable piece of this is that I want to
publicly thank Dave Harding, who is the primary author of the newsletter itself,
and the exclusive, I think, basically author of all of these Topics pages, so
thank you to Dave for that.  A lot of the work that I know that I do is
reviewing Dave's stuff and talking about Dave's stuff on this podcast.  But it's
Dave's stuff, so thank you, Dave.  Oh, go ahead, Dave.  Do you want to say
something?  You want to take a bow?

**Dave Harding**: I just wanted to say, you're welcome!

**Mike Schmidt**: So, this is Optech's seventh year.  This year was 51
newsletters, 35 new Topics pages, 120,000 English words about Bitcoin.  This is
roughly a 350-page book.  I think last year was 250 pages.  So, maybe next year,
450 pages, huh, Dave?  I put in a note about the translations this year.  We had
200 translations across four languages, which is pretty cool, because basically
every weekly newsletter was translated, and a lot of these are within minutes of
merging the English version, the translation is up, which is pretty incredible.
If you include some of the legacy newsletters, some of the older newsletters
that are being translated currently into the Chinese language, this is probably
closer to 350 translations this year, which is pretty cool.

We also talked about the podcast.  We had just about 60 hours of audio with
about a half million words that were transcribed.  We had 75 different guests:
Gloria, our ultimate special guest with 10 appearances; we had Greg Sanders on 7
times; and then we had 73 other special guests, which is pretty cool.  Just
glancing at this list, you recognize these names and the work that they've done.
It's really great that they take the time out of their day, sometimes at very
inconvenient hours of their schedule, depending on time zones, to join us to
talk about their work.  It's super-valuable for me and I think it's
super-valuable for the audience, so thank you to all of you for joining us.

Then the last call out here in our Optech section was thanking the Human Rights
Foundation, who proactively reached out to us to want to support the newsletter
and podcasts in any way they could, which resulted in a $20,000 donation to
Optech from Human Rights Foundation.  We use those funds for our day-to-day
expenses, like web hosting, our email newsletter services, podcast
transcriptions, and anything else that can really bring more of this content to
the broader Bitcoin community.  So, thank you to the HRF.

**Mark Erhardt**: I would also like to thank our audience.  I had, at times in
this year, the feeling that this is a lot of time we're spending on this, and
sometimes it felt a little like talking to an empty room.  But when I showed up
at conferences, people told me they listen every week, they find it
super-valuable.  It happened a couple of times that I was just chatting to
someone in a hallway at a conference and someone turned around, "Who are you?  I
know your voice!"  So, I guess those were also people listening to us.  Thank
you for making us feel that it's worth our time.  It's been a pleasure to serve
you as the Bitcoin Optech Recap Team.

**Mike Schmidt**: Well, I think we can wrap up.  Thanks to Niklas, who dropped,
and Rearden, who dropped, for joining us earlier in this recap.  Thank you,
Gloria, for joining us and opining throughout the newsletter and hanging on to
the very end.  And also, Dave, well, thank you once more for joining us today on
the recap and, Murch, my co-host as always.  Happy 2024.  Cheers.

**Mark Erhardt**: Cheers.

{% include references.md %}
