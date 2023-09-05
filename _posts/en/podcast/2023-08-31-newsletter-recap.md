---
title: 'Bitcoin Optech Newsletter #266 Recap Podcast'
permalink: /en/podcast/2023/08/31/
reference: /en/newsletters/2023/08/30/
name: 2023-08-31-recap
slug: 2023-08-31-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Matt Corallo, Brandon Black,
Gregory Sanders, and James O'Beirne to discuss [Newsletter #266]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-7-31/345224025-44100-2-416bc8767a58.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #266 Recap on
Twitter Spaces.  It's Thursday, August 31, and today we'll be talking about the
disclosure of a Lightning Network vulnerability, covenant mashups with TXHASH
and CHECKSIGFROMSTACK, and we'll be covering our monthly highlights of Bitcoin
Stack Exchange Q&A, simple taproot channels, and more, with our special guests
Matt Corallo, Brandon Black, and hopefully Greg Sanders.  So, let's do some
introductions and then we'll jump into it.  I'm Mike Schmidt, contributor at
Bitcoin Optech and also Executive Director at Brink, funding Bitcoin open-source
developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin Core,
Bitcoin Stack Exchange and other Bitcoin projects.

**Mike Schmidt**: Matt?

**Matt Corallo**: Hey, I'm Matt, I work at Spiral on the LDK team.

**Mike Schmidt**: Brandon?

**Brandon Black**: Hi, I'm Brandon and I really like covenants!

**Mike Schmidt**: All right, well I've shared a few tweets in the Space for
folks to follow along.  You can also pull up the newsletter at bitcoinops.org.
First item, actually, Brandon, I think you need to jump off.  So did you want to
talk about covenants first?

**Brandon Black**: That'd be great, yeah.

_Covenant mashup using `TXHASH` and `CSFS`_

**Mike Schmidt**: Okay, well, so we'll go a little bit out of order this week in
the interest of Brandon's schedule.  So we'll actually be talking about Covenant
mashups using OP_TXHASH and OP_CHECKSIGFROMSTACK (CSFS), which is a proposal
that's an alternative to BIP119, which is OP_CHECKTEMPLATEVERIFY (CTV), and
BIP118, SIGHASH-ANYPREVOUT (APO), which provides functionality of both proposals
with no additional overhead.  Brandon, maybe you want to elaborate a bit on
that, and we can talk about some of the origins of this proposal.  I think
Russell O'Connor had proposed something similar in January 2022, and I know you
have some goals of sort of elevating the discussion around covenants.  So, maybe
you can take this wherever you'd like to get started.

**Brandon Black**: Yeah, thank you so much.  I want to just make clear up front,
my proposal is not serious for full inclusion.  Really, the focus that I have is
bringing together the understanding of covenants.  There seems to be a lot of
confusion in the Bitcoin space between what you can do with CTV and what you can
do with APO and where there is and is not overlap.  And as I was studying them
over the recent months, I realized there's a lot of overlap, but also some
specific areas where they can't do each other's jobs well.  And so this proposal
is partially showing those similarities and differences, and that's why I added
the table at the bottom of my gist there that shows what is and is not included
in the different hash methods that APO and CTV use respectively, and then how
that can be included potentially in one proposal that could offer the features
of both.

The other thing that I wanted to mention right up front is that this way of
doing covenants is about as efficient as APO or CTV if everything's in taproot,
but bare CTV using a plain scriptPubKey is much more efficient for that specific
use case.  So, if we find as a community that the many uses of CTV are going to
be frequent and are very valuable, we should just do CTV.  It's much more
efficient for those specific bare CTV use cases.  On the other hand, if the most
important thing we want is LN-symmetry and OP_VAULT, then something like my
proposal offers both of those with very little downside.  Yeah, so that's kind
of the high-level stuff that's worth mentioning.

My specific proposal includes CSFS, which also enables some other things that I
haven't even explored yet.  I think James O'Beirne mentioned that it enables key
delegation, but it also potentially enables templates delegation, where your
script includes a CSFS on a non-specific template, but then you check that with
a CTV, or things like that.  So, there's this delegation aspect you can do with
CSFS that I haven't really fully explored yet.  I should probably talk more
about what exactly I proposed, but I'm going to pause there for a second.

**Mike Schmidt**: I think it's okay to continue, maybe discuss more about what
you're proposing here?

**Mark Erhardt**: Okay, yeah.  So, Russell O'Connor originally proposed a TXHASH
way of doing covenants.  His proposal was more a flags-based approach, where you
would have a bunch of specific chunks of the transaction, and you would have a
flag, "I want to include this.  I don't want to include that", a flag field to
include various pieces of a transaction in a hash that would then get put on the
stack and could be used for later processing.  So, if you made a CTV-like hash
using TXHASH, then you could validate that using OP_EQUALVERIFY, so you put the
TXHASH with the appropriate flags, you put the template hash you want to check
against in OP_EQUALVERIFY, and you can basically get the functionality of CTV
with that.  If you then include CSFS, you can use an TXHASH with flags to make
an APO-like hash to verify that.  So that's kind of the original proposal.

When he proposed that, there started to be kind of a lot of discussion about
exactly what flags there should and should not be.  And if you read through
Jeremy Rubin's BIP119, he had a huge exposition, a really valuable reasoning
behind why each bit of the template is included, or not included in some cases.
And it's hard to capture those details that Jeremy Rubin thoughtfully put into
the CTV BIP in a flags-based TXHASH; and then also, there's just a lot of space
for bike-shedding of what could and could not be included and the quadratic
hashing potentially of certain ways flags could be activated.  For those not
aware, quadratic hashing is where if you have several inputs all using a similar
opcode and they require slightly different hashes of each other, you can end up
potentially hashing many, many megabytes of data in order to validate one
transaction.  Anyway, so yeah, it's hard to get a TXHASH opcode that avoids some
of these pitfalls.

I think at the time, even back in 2021 or 2022, folks proposed a limited version
of TXHASH that was more, "Here's these specific ways to hash the transaction".
And I kind of extended from that and said, "Let's specify some of those specific
ways to hash, make them represent roughly APO and CTV, get pretty close to those
ways of hashing, and then that gives us the functionality we want while avoiding
the pitfalls of quadratic hashing, because we don't have all these specific
selectable fields".  And so that's kind of what I did.

**Mike Schmidt**: Greg Sanders has joined us.  Greg, obviously, you're involved
or familiar with a lot of these covenant discussions and some of the tech around
there.  Do you have questions or comments on what Brandon's proposed/the
awareness of all this covenant chat and comparisons?

**Greg Sanders**: Yeah, I mean, I've been talking to him offline about this.  As
he says, it's kind of a high-level proposal, so a lot of things would change in
the event of people going forward with it.  I think my high-level comment is
just, it's going to be hard to predict what fields and which iterations are kind
of what people actually need and want.  I think the real trick with all these
schemes is being able to pick what's actually useful.  So, I mean I'll see the
floor and let maybe Matt speak up.

**Matt Corallo**: Well, predict what's useful and also be flexible, because part
of the problem with a lot of the covenant stuff is there's a lot of excitement
around various wallet designs, where you have kind of this pseudo-custodial
model.  I know AJ has written about this, I've spoken about this, James O'Beirne
recently wrote about this, these things in the Ark direction, but ideally with
better scalability properties.  And there's a lot of, I think, understanding
that these designs probably need some kind of covenant system to build, but
these designs also aren't fleshed out in full, there's just kind of rough
excitement in the direction and not necessarily specific designs.  And so, that
makes it doubly hard when there's like, "Well, there's some stuff we know we
want to build, and then there's probably some other stuff that we want to build
that we don't know yet".  Yeah, it makes it very hard to predict what kind of
hashes we're going to find!

**Greg Sanders**: Yeah, and even in the non-custodial sense, CoinPool designs
are very not fleshed out yet.  There have been some designs kind of sketched
out, but I think we don't know what a good CoinPool solution would look like, in
many ways.

**Matt Corallo**: Right, exactly.

**Brandon Black**: Yeah, I totally agree.  It's one of the things that's been
challenging in thinking about and writing about this.  There's all of these
ideas floating around about what you can do with covenants, but since they don't
have detailed specs or detailed especially implementations of how they're going
to use a covenant, you ask, "Okay, well what exactly do you need and not need
for what you want to do?"  And the answer is, "I mean, it's like CTV or it's
like APO", but that often doesn't actually answer the question.

**Mike Schmidt**: I'll plug one of the conversations that some of us at Brink
have had with James O'Beirne recently.  We put that out as a video chat, and we
had folks like Christian Decker representing APO, and James talking about some
of his vault work.  So if you're curious about that, go to Brink.dev, and
there'll be a link to a YouTube video there if you want to hear some of that
discussion.  Murch, do you have questions or comments on this topic?

**Mark Erhardt**: No, I don't, but I see James appeared in our Optech Recap, so
maybe he has an idea of what he wants to say about this proposal from Brandon.

**Mike Schmidt**: James, I sent you a speaker invite if you're on mobile and
able to chat with us.

**Greg Sanders**: Might not be on mobile.

**Mike Schmidt**: Perhaps not.

**Greg Sanders**: No ones figured out about how to do voice on web browser,
right?  It's impossible, I think.

**Mike Schmidt**: Not even, yeah, Elon can't even.

**Mark Erhardt**: Yeah, we hear you.

**James O'Beirne**: Oh, wow, that's surprising.  I'm on Linux and a web browser
and you can hear me.  That's amazing.

**Mike Schmidt**: Hey, James.

**James O'Beirne**: Yeah, hey, I didn't expect to be able to make this, but it's
great to be here.  Yeah, I like Brandon's proposal.  I made a few comments in
the Delving Bitcoin Forum.  And I think the rough gist is that I think that the
most expeditious path to getting CTV and APO, in my opinion, is basically just
to use the existing proposals, because while I think Brandon's proposal is very
novel in that it kind of unites the form that both of them take, and he did a
really fantastic job of breaking down their usages in terms of the virtual byte
sizes of the resulting scripts, but I think I can't really get my head around
what the killer use case for CSFS is, and it seems like the big benefit of the
proposal is that it formulates CTV and APO in such a way that their use looks
very similar and is enabled by CSFS.

But I think there are marginal space efficiency losses, at least in the CTV
case.  And I sort of don't have a good intuition, I guess I should say, for why
we want to shoehorn all this into CSFS.

**Brandon Black**: Yeah, I mean to be clear, when you're using my proposal to
emulate CTV, there is no CSFS.  The CSFS is to enable signed delegation to a
hash that is different from a signature hash (sighash).  And I think one of the
reasons for me going in this direction, I think many of you have seen probably,
I originally made a PR against the APO BIP, because APO as it stands has this
slightly weird behavior that APO implies anyone can pay, and that actually
prevents a CTV-like covenant from being enabled by APO.

So, I originally went down that path, and then as I read more into APO, I have
this feeling that, and I hate to use the word "feeling" in a technical
discussion, but there it is, I have this feeling that APO is kind of a shoehorn
itself, because removing the commitment to the specific outpoint being spent was
a big enough change that various folks, when APL was being designed, chose to
use a new key type to enable APO.  Once you go into a new key type, you might as
well explore using a different opcode.  I propose using CSFS as that new opcode,
because it does have kind of a different behavior when we're not committing to
the outpoint of what's being sent.  So, that's kind of how I got to this, as
opposed to using the existing CHECKSIG operations to enable APO.

**James O'Beirne**: Yeah, that's that makes a lot of sense, Brandon.  And can
you talk about maybe why you think having a specific pubkey type for APO is
worth avoiding?

**Brandon Black**: I guess my thought there is, it's not a different key type,
it's a different hash type, and I think that our designs should communicate what
they're doing better than that.

**James O'Beirne**: Yeah, that makes sense to me.  I never really had a good
intuition for why we wanted to be so cautious about tagging APO-enabled pubkeys
in that way, but maybe somebody else.

**Greg Sanders**: If I remember correctly, reading the spec, any undefined
sighash arrangement for taproot results in a sighash fail, like a failure,
right?  So one thing is, you don't really have an upgrade.  I guess even in
legacy, unknown configurations were just kind of ignored, sort of.  So it wasn't
really -- go ahead, Murch.

**Mark Erhardt**: Yeah, I think all sighash flags are defined and all of them do
something, and it has to be that way, otherwise they would be anyonecanspend.

**Greg Sanders**: Yeah.  So I'm just recapping, kind of, there's no upgrade hook
in that direction.  So, if you want to change sighash flag hooks, you need to
find some other way to do it, right?  So, I don't know if it's really that much
of a shoehorn versus a reality of upgrade hooks.

**James O'Beirne**: Oh, okay, yeah, so that's just an incidental property.

**Greg Sanders**: Yeah, I had thought about -- oh, am I losing connection here,
or is it you, James?

**Mark Erhardt**: I think it was James.

**Greg Sanders**: Yeah, I think it's not necessarily obvious unless you actually
think through the upgrade hooks, but it wouldn't be possible to do that, as
Murch said.

**Mark Erhardt**: All right.  Does anything else need to be said about this
topic at the moment?

**James O'Beirne**: Again, great job --

**Mark Erhardt**: Is James speaking or not, because I don't hear him?

**James O'Beirne**: Yeah, I started to speak, sorry.  Yeah, I just want to say
again, great job to Brandon for the novel proposal and spurring this really good
discussion.  I mean, this may be the route that we end up going on.

**Mike Schmidt**: It does seem like there is a lot more discussion to be had,
and it seems also that the Delving Bitcoin website is also becoming a place
where some of these discussions are being had.  James, I know you had some
opinions on the appropriate forums for some of these discussions, and maybe you
want to, for the audience, summarize what is Delving Bitcoin and why that might
be a good place to have these kind of discussions versus Twitter.

**James O'Beirne**: Yeah, so I think you've got two ends of the spectrum right
now.  On one far side, you've got the mailing list, which I think people are a
little skittish about posting to and take very seriously and can be intimidated
about contributing to; and then on the other side, you've got Twitter, which is
like a total free-for-all with a really weird set of properties as a medium that
isn't really searchable.  And I mean, at this point, you can't even get a stream
of people who you follow reliably.  So, I think de facto a lot of discussion
happens on Twitter just because everybody's there.  But I'd like to see
something that both facilitates free and open discussion, but actually supports
long-form technical discussion.

Stack Overflow is kind of close, but this discourse platform that AJ and Ruben
Somsen set up, Delving Bitcoin, seems to really nail it from a kind of medium
standpoint.  So, I've just decided to start posting stuff there because I think
it's a better way of talking about this stuff.

**Matt Corallo**: I mean, this is the classic -- Murch has his hand up, I'll let
him speak first.

**Mark Erhardt**: Yeah, I was just going to say, my problem with the mailing
list is actually exactly opposite of what you described.  I feel that the
quality of the mailing list has become so much more noise that it just, I don't
really read it anymore because it's usually not useful to me.  And I think
that's one of the reasons why a lot of people just don't post there anymore.
And also Stack Exchange is definitely not for discussion, it's just really more
for answering a question.  So yeah, I think that another platform like Delving
Bitcoin is a better fit.  So, Matt?

**Matt Corallo**: Right, I was just going to point out this is kind of the
classic story as old as time, how communities move, right?  First, a new forum
exists.  There's people who are really into it and really deep and smart on a
topic, have spent a lot of time thinking about the topic, use this forum.  After
a while, various other folks join who don't spend as much time thinking about
the topic, have less informed reviews on it.  This creates more noise,
eventually the folks who are really deep on a topic get frustrated, leave.  This
is what happened to Bitcoin Talk, they left to the mailing list, and then the
mailing list is now kind of filled with less informed takes, let's say.  As a
result, a lot of the technical voices who do work full-time on Bitcoin have
stopped posting, which has made the signal-to-noise ratio even worse, as Murch
said.

Now, it seems like someone has created a new forum, which will initially have
great signal-to-noise ratio, and people should use it, and then eventually it
will probably also die.  But this is just kind of how internet communities have
moved from forum to forum forever.

**James O'Beirne**: Yeah, I just think there's little niceties about Delving,
like it'll actually do syntax highlighting and you can throw mermaid.js diagrams
in there and little stuff like that.  But I mean, it's just it's a platform
that's actually suited for long-form discussion, whereas Twitter is basically
just suited for shitposting.  So, I don't know if we can expect --

**Matt Corallo**: I was comparing it more to Bitcoin Talk and then the mailing
list, not Twitter.

**Mark Erhardt**: Yeah, I think that Discourse is just a way more modern and
better forum software than whatever, what is it, BB Forum, or whatever that
Bitcoin Talk is running on, so I think that will also help.  Anyway, let's wrap
that up, but also I need a Delving account!

_Disclosure of past LN vulnerability related to fake funding_

**Mike Schmidt**: The other news item from this week was the disclosure of LN
vulnerability related to fake funding.  And I guess before we jump into that --
oh, Brandon just jumped off.  I was going to thank him for joining, I know he
couldn't stay.  We have a Lightning expert as part of our guest attendees.  So
Matt, do you want to discuss this vulnerability, maybe summarize it?  It seems
fairly straightforward, but maybe you can give us your summary of it.

**Matt Corallo**: Yeah, there's not a hell of a lot to it.  Basically, every
major Lightning implementation, all four of them, didn't do much to limit the
resources.  When someone opens a channel to you, you do have to store a little
bit of information.  There's some discussion about maybe making this
deterministic derivations, but in the obvious implementation, when someone opens
a channel to you, you have to store, "Hey, here's the channel, and here's the
funding outpoint, here's my initial force closing transactions", so if I want to
force close the transaction for whatever reason, even though I don't have any
money in it, I do that.  And so, every major Lightning implementation stores
some data for it, not too much.  So, someone can just connect to you and there
was no rate limiting or no bounding and someone could connect to you, tell you
that they're going to open a million channels to you, and then just not open
them because they don't actually have the Bitcoin for it.  Every major Lightning
implementation would just keep writing more and more crap to its database and
eventually you could make a Lightning implementation get pretty slow as a
result.

So, how it actually ended up resulting on various Lightning implementations was
a little different, depending on the architecture and the database back then,
and which part of the system ended up getting slow first, etc.  But the end
result was the same for all of them, and the attack was the same for all of
them.

**Mike Schmidt**: There was, in the writeup that Matt Morehouse posted, he put a
section on lessons, and he says in that post, "Use watchtowers because they
provide cheap insurance".  He also mentioned multiple processes.  For example,
CLN has separate daemon processes for different pieces, one for peer connections
that became locked under this attack, but the lightningd process continued to
watch the blockchain, which was unaffected.  Matt, do you agree with these
lessons learned, or is it just simply putting in some rate limiting, which it
looks like a lot of the implementations did?

**Matt Corallo**: That's a part of it.  Watchtowers are great.  The watchtowers
that exist don't enforce HTLCs, they only enforce the, let's call it, main
unencumbered balance of a Lightning channel.  So, they do have substantial
drawbacks in terms of how effectively they can get you all of your money back.
There's various other designs for watchtowers.  That's useful for various
attacks we've seen on Lightning.  Multiple processes is great, right up until
someone actually opens enough channel that your whole system starts booming and
killing processes.  That's kind of more of a side effect of which things started
failing first and less a side effect of, this is the general purpose mitigation
for all issues.  Multiple processes is good for other reasons, and I know CLN
and Eclair and LDK all support multiple processes in various forms.

But yeah, I mean at the end of the day, there was already an open issue for this
on LDK, and I think also Eclair, by the time it was reported.  In LDK, we'd
noted this a while back.  It wasn't as big an issue for a lot of the LDK
deployments because either they only accept channels from trusted peers or
they're a mobile phone and only connect to an LSP.  So, it was less of a concern
for us kind of immediately unless we didn't rush to fix it.  And then Matt came
around and pointed out, "Yeah, this is probably worth fixing".  If anyone does
run public nodes or nodes that accept channels from anyone using LDK, this is
kind of a pretty major issue.  So we did, we fixed it pretty quickly after that.

I mean, this is one of those things where it wasn't completely unknown.  I guess
it wasn't necessarily known to LND, or CLN, or at least there weren't any public
issues on it.  They might have known it in some way.  And yeah, I mean I think
this is just kind of Lightning software slowly maturing.  The Lightning space is
still kind of new, there's a lot of code that's been written, and just not as
much time spent on -- it just takes time for code to mature to that level, and
that's done great work fuzzing on CLN and LND, I believe.  The LDK project also
has a bunch of fuzzers for various state machines.  And yeah, just finding these
kinds of issues and various issues that you're going to find with these kinds of
security analysis just takes time.  Similarly, Lightning still really needs
package relay or there's various other attacks you can do against Lightning
nodes.

So, I would just say it's still early in Lightning in terms of the security
models and the security and reliability that Lightning is able to provide today.
We're working on it, a lot of progress is being made, and a lot of credit to
folks like Matt who've done good security review of various Lightning
implementations and found issues and reported them.  But yeah, just takes time.

**Mike Schmidt**: Matt noted in his writeup, "The fact that this DoS vector went
unnoticed since the beginning of the Lightning Network should make everyone a
little scared.  If a newcomer like me could discover this vulnerability in a
couple of months, there are probably many other vulnerabilities in the Lightning
Network waiting to be found and exploited".  Matt, what's your take on that?

**Matt Corallo**: I mean, I think he's largely spot on.  Again, I think that
both LDK, and I need to reread his disclosure email, but I thought he said
Eclair as well, were aware of the issue, had open issues to track it and resolve
it hopefully soon, although it had slipped one milestone on the LDK side.  But
he's absolutely right.  Again, Lightning is still early and there will be these
kinds of issues.  And people who have really large material volumes of money in
their Lightning node should consider who they open a channel with.  That has
been true since the beginning of Lightning and that hasn't changed.  And again,
there are known attacks in mempool and relay policy and stuff that people are
working on fixing, there will be more unknown issues like this, DoS issues.
Watchtowers are a good solution for some of those.

Other things, if your watchtower is running the same code as your main Lightning
node, it's only going to do so much.  We've seen some issues with BTCD that
caused issues for LND-based watchtowers as well.  So yeah, expect more things to
come.  And if you are looking at storing really material volumes of money in
Lightning, you probably need to build something custom and not just run LND or
CLN straight up with no consideration given to multiple data center storage and
multiple data center, different software watchtowers, and all kinds of more
enterprise considerations, that just I think a lot of people running Lightning
today haven't given a hell of a lot of thought to.

**Mike Schmidt**: Murch or Greg, do you guys have any comments on this item?

**Mark Erhardt**: Yeah, you go Greg.

**Greg Sanders**: Everything you said was very reasonable.

**Mark Erhardt**: Yeah, I think that people sometimes get a little frustrated
that Lightning has been around since 2015 and we've had it on mainnet, but it's
really still a process in flight.  It's not done, it's not going to be done in a
while, for a while.  It is usable already, it's useful already, but there is so
much to do, and especially deploying it in a professional manner where it can
really scale to take care as a bonafide payment option for a huge volume
business, that sort of stuff.  I don't think a lot of people have really built
that yet, and if they have, they might have done it in-house and proprietary, so
some of the learnings there are just not completely public yet, or the best
practices have not trickled down to the general population yet.

**Matt Corallo**: Yeah, I think also it's important to recognize that Lightning
-- you're right, and I think a lot of us are frustrated with how far it's come,
but also some of the issues require fairly large rethinks in Bitcoin Core, like
package relay.  That's a huge amount of work, and it's not trivial at all, and
it's taken a while because it's a huge amount of work, not because people
haven't been working on it.  But then I think more generally in Lightning, we've
seen relatively limited amounts of resources being put on, for example, LND.  I
think up until their last fundraise, whatever it was, two years ago or
something, there were very, very few resources on LND, because Lightning Labs
was a startup that had a lot of different projects and had their energy split
across a lot of different things.  I think who builds Phoenix and Eclair,
they're now maintaining two separate Lightning implementations.

I think broadly, to your point, Lightning has done a good job of demonstrating
that you can build this kind of payment channel network and have it work fairly
well and have it provide good payment results in common cases.  But it's
absolutely the case that we still have a lot of work to do to fix a lot of major
issues with it.  And I think that's why you're seeing right now, all the major
Lightning implementations are adding a lot of features all at once, from
splicing and dual funding, which helps make it a little simpler to deal with
some of these kind of LSP-based wallets, like mobile wallets and whatnot, to
BOLT12, which makes the invoice, the QR code static, which is a major UX
problem, fixes a ton of issues around privacy, to just redoing, closing, and
moving towards, once we get package relay, we can remove the fee negotiation in
Lightning, which will resolve a lot of these force closes.

There's major work being done still to take the protocol from, to your point,
what I would call a proof of concept, kind of like, "Look, this works, we can
get it to work", to something that's really much more stable and much more
reliable.  There's still a lot of work to do, but it is a lot of work, and until
not very long ago, there weren't nearly the level of resources that we really
needed for that kind of thing, for that kind of work.

**Mark Erhardt**: Yeah, there's a whole other orthogonal direction with taproot
channels that is also starting to get worked on.

**Matt Corallo**: Yeah, I mean taproot channels aren't immediately fixing any
major issues in Lightning.  LND shipped simple taproot channels in their latest
release that just came out, or maybe the release candidate that just came out,
but it doesn't really add any features for users or solve any major problems for
users as is.  It provides a good base for in the future, we want to be able to
do multisig channels, so having a channel where you have your local side is
actually multiple signers, and I think taproot channels might get us one step
towards it.  Probably actually the taproot channels as they exist today isn't
sufficient, we probably actually need a slightly different design for it.  And
then also, of course, taproot channels allows LND to work on their assets
feature.  But as is, it doesn't solve any major problems with Lightning, I would
say.

**Mike Schmidt**: I think we can wrap up this item.  Next section from the
newsletter is selected Q&A from the Bitcoin Stack Exchange.  So, this is our
monthly segment where we pick some of the top-voted questions and answers since
last month, and we have seven of these Q&As that we're covering this week.

_Is there an economic incentive to switch from P2WPKH to P2TR?_

The first one is a question that was both asked and answered by our host, Murch,
"Is there an economic incentive to switch from P2WPKH to P2TR?  Murch, maybe you
want to frame the question and what your conclusion was here.

**Mark Erhardt**: Yeah, I think it's not a big secret that I've been very
excited about Taproot for many years.  And I've seen the argument made in public
a few times that, "Well, taproot is more expensive in the round trip because
input plus output are bigger than on P2WPKH, so there's no economic benefit to
switching to P2TR", and I believe that to be false.  So, I wrote up in long form
a calculation and an overview of how it would get used and why it will end up
being cheaper for the user.

To give you the gist of it, so in the round trip, when you create an output, the
output is usually created by someone sending funds to you and usually the sender
pays for it.  So, while that is just externalizing the cost on the sender,
senders don't seem to have a problem sending to P2WSH at the time, so they
should also be fine sending to P2TR, which costs the same.  And if you're just
looking to minimize your own cost, generally for anything you receive from
someone else, you only pay for the input, and the input is significantly cheaper
than a P2WPKH input.  And if you think about change outputs, unless you
absolutely always create single input transactions with a change output to
yourself, only in that case, P2WPKH wouldn't be cheaper for you.  Otherwise, you
will save money because usually you have more than one input, in average, on
transactions, and if you have then the cheaper inputs from P2TR and a slightly
more expensive output from P2TR, it's still going to be cheaper in total than if
you go with P2WPKH all throughout.

Anyway, I wrote up the whole thing, I made some tables with calculations.  If
people are interested in checking my math or thinking about that, I think there
is a direct economic incentive of like savings of up to 15% if you switch to
P2TR over P2WPKH as a single user.  And then for multisig users, it's just way
better.

_What is the BIP324 encrypted packet structure?_

**Mike Schmidt**: Next question from the Stack Exchange was, "What is the BIP324
encrypted packet structure.  And Pieter Wuille outlines the network packet
structure for version 2 P2P transport as proposed in BIP324.  And so you can
jump into the answer to see the details on that particular structure.  BIP324,
as a reminder, allows Bitcoin nodes to communicate with each other over
encrypted connections.  And actually, the project seems to be making some good
progress on the repository.  What do you think, Murch?

**Mark Erhardt**: Yeah, I think you summed that up right.  I think it might get
ready this release; I'm not 100% sure whether all parts are done.  I think the
part where it actually starts getting or being able to be used with the network
flags and nodes when they see that their peer supports it, actually using the
feature, I think that's the part that is still open.  So, it might also just be
early in the next release cycle, and it would first be an experimental feature
probably anyway.  But yeah, it's getting pretty close to having at least a full
implementation of the feature set.

**Mike Schmidt**: And if you're curious of the exact progress of BIP324 and
what's in and what's still being worked on, we linked to the Bitcoin Core #27634
tracking issue for BIP324 and all the associated PRs there in the answer for
this week, so take a look at that tracking issue if you're curious about all
that goes into this project.

_What is the false positive rate for compact block filters?_

Next question is, "What is the false positive rate for compact block filters?"
And, Murch, you answered this one by referencing BIP158 on compact block
filters, which outlines a false positive rate of 1/784,931.  And I think you and
Harding had gotten together and figured that that was one extra block every
eight weeks if there was a wallet that was monitoring a thousand different
output scripts.  We also talked with Max Hillebrand last week about some of
Wasabi's interesting work being done around compact block filters for their
coinjoin use case.  So, if folks are curious about that, check out the
discussion we had with Max last week, because there was some interesting
discussion that's relevant to this question.  Would you add anything to that,
Murch?  Okay, thumbs up.

_What opcodes are part of the MATT proposal?_

Next question from the Stack Exchange, "What opcodes are part of the MATT
proposal?"  So, the MATT project, which stands for Merkleize All The Things, is
an approach to Bitcoin smart contracts that requires some small changes but
allows very general smart contract constructions.  And the short answer to the
actual question, about which opcodes are involved with MATT, is that currently
it's OP_CTV, OP_CHECKCONTRACTVERIFY, and OP_CAT, and we link to some of those
opcodes in the answer.  But also, if you're curious about the MATT proposal,
Salvatore answered the question and he provided a nice overview of MATT in this
answer as well.  So, he didn't actually just answer, "Hey, there's these three
opcodes", but he kind of gave an overview of MATT, which I think if folks are
interested, they should read his answer.  I was going to ask Brandon what he
thought of MATT, but Brandon needed to drop off, so I guess we'll have to get
his opinion at a separate time.

_Is there a well defined last Bitcoin block?_

Next question from the Stack Exchange, "Is there a well-defined last Bitcoin
block?"  And so, Bitcoin uses an unsigned 32-bit value for timestamps, which
means there is a max value of what that timestamp value could be.  And it turns
out that that timestamp is sometime in February of the year 2106, so there
wouldn't be able to be any new blocks after that time without a hard fork.
Matt, is this the kind of thing that should be considered with The Great
Consensus cleanup or not, because The Great Consensus Cleanup is a soft fork and
could the timestamp limitation be overcome via some innovative soft fork, or is
this truly a hard fork scenario?

**Matt Corallo**: There is an old proposal to work around the timestamp issue
with a soft fork.  It is possible, it's not ideal, probably not worth it.  You
have to slow down time, put the timestamp somewhere else, but then you break
locktimes, so it's not worth it.  It is theoretically possible, but no, there
should be a hard fork for it.  Whether it goes in as a part of some other soft
fork that does a bunch of other stuff or not, doesn't really matter.  But at
some point, someone should write this down, implement it, define it, and then
simply write the code, fork it in, you know, a decade or two before we actually
reach 2109, whatever the year was you said, and then hopefully by the time that
timestamp rolls around, everyone will have upgraded and handles rollover just
fine.

**Mark Erhardt**: Yeah, I think that it would just be -- we have The Great
Consensus Cleanup; I thought it was a hard fork, and I think that it is totally
possible to do that sort of hard fork that is fairly uncontroversial and just
fixes a bunch of protocol issues.  And if you just like put activation out ten
years in the future or so and carry it around in all the implementations over
some time, it should be quite possible to have a homogenous upgrade of the whole
network at a fixed time.  I don't think it's impossible, but somebody would have
to implement it and coordinate it, and for this one in specific, we have 100
years almost.

**Mike Schmidt**: Matt, a philosophical question.  With all the angst around
soft forks lately, including activation, do you think it would make sense to do
something like The Great Consensus Cleanup as a sooner-than-later type
initiative to sort of get a fairly non-controversial soft fork out of the way,
or what are your thoughts on that?

**Matt Corallo**: Yeah, that was one of the original reasons for that proposal,
but it was also prior to taproot.  Between segwit and taproot, there was a
dearth of soft forks for quite a long period of time.  Now, taproot ended up
making faster progress than Great Consensus Cleanup did, and it ended up not
making sense to use it as kind of a testbed for modern soft fork activation.  I
don't think we really learned anything about activation from the taproot
process, it ended up being a bit of a mess, there were a lot of different ideas.
So, I mean it might be worth doing again.  It's not something I'm going to spend
immediate time on, but some of the changes that were proposed there absolutely
do need to happen.

I mean, it cleaned up some quadratic hashing issues, cleaned up a bunch of stuff
that really does need to happen at some point.  So, it would be good if someone
got around to working on that again, but it turns out most engineers working on
Bitcoin have lots and lots of ideas that they want to work on, and trying to
tell some engineer working on Bitcoin who has 40 of their own ideas to work on
some other idea is not really something that ever works.

_Why are miners setting the locktime in coinbase transactions?_

**Mike Schmidt**: Next question from the Stack Exchange, "Why are miners setting
the locktime in coinbase transactions?"  And this was an answer to a question
that was open for the last two years about someone noticing that miners are
setting coinbase transactions locktime field in order to communicate something,
but it was unclear, at least on the stack exchange question, what that was for.
And recently a mining pool operator explained that they, "Repurpose those 4
bytes to hold the stratum session data for faster reconnect".  Matt, were you
familiar with this usage that some of the mining pools were using those 4 bytes
to put stratum session data in there?

**Matt Corallo**: I was not aware of that, this long, long history of this
problem in Bitcoin where miners are doing creative things and no one outside of
them is even really aware of it.  This has historically been a major issue also
from a language barrier.  When miners were fairly big in China, there was a much
bigger language barrier.  Still a problem, less of a problem than it used to be.
But, yeah.

**Mark Erhardt**: Yeah, I actually stumbled over this question a while back and
posted it on Twitter.  And that's how we found out that F2Pool at least does
this.

_Why doesn't Bitcoin Core use auxiliary randomness when performing Schnorr signatures?_

**Mike Schmidt**: Last question from the Stack Exchange this week is, "Why
doesn't Bitcoin Core use auxiliary randomness when performing Schnorr
signatures?  So, according to the Schnorr signatures BIP, BIP340 recommends
using auxiliary randomness when generating a schnorr signature nonce.  And the
reason for that is for protection against potential side channel attacks.  But
Bitcoin Core's implementation doesn't use auxiliary randomness, and that was the
genesis of this question.  I believe it was Andrew Chow who answered, saying,
"As with any open-source project, if no one cares enough to implement it, it
doesn't get implemented".  He also goes on to say that, "Providing no auxiliary
randomness is still safe as the deterministic nonce-generation algorithm
includes the private key.  This is enough entropy for it to be safe, so there
isn't any need to provide auxiliary randomness, although it would probably be
nice to do so".  Murch, do you have any familiarity with this auxiliary
randomness discussion within Bitcoin Core?

**Mark Erhardt**: No, I've learned about it today.  I didn't even see the Stack
Exchange question.

**Mike Schmidt**: Okay.  Well, if folks are curious, jump into that Stack
Exchange, and there's actually a link to the commit, which is associated with
the lack of randomness.  I guess it's just a vector with a bunch of zeros that's
being used currently.  It sounds like from what Andrew was saying, it's still
safe, but it would be nice to also have that randomness added.

_Core Lightning 23.08_

Next section from the newsletter is Releases and release candidates.  We have
the Core Lightning 23.08 release.  We've talked about it a bit, but I'll
summarize some of the highlights here.  Support for Codex32-formatted backup and
restore; the renepay plugin, which is an experimental plugin for improved
pathfinding; experimental support for splicing; and the ability to pay locally
generated invoices.  And there's a bunch of other features and bug fixes as
well.  You can jump into the release notes to check out the details there.  And
we've also had some discussion of these PRs in our previous newsletters,
including a discussion with Dusty and Lisa about CLN.  So, look for those in the
newsletter and our previous podcast discussions.  Go ahead, Murch.

**Mark Erhardt**: Mandatory mention, they now are defaulting to taproot change
addresses for their onchain transactions.  So, that's pretty cool.

_LND v0.17.0-beta.rc1_

**Mike Schmidt**: Excellent.  Next release was to the LND repository, which we
referenced earlier.  This is the v0.17.0-beta.rc1, and we highlighted one
potential piece for testing, which is the simple taproot channels, which is also
the last PR for this week, which is LND #7904, which covers simple taproot
channels.  Murch, did you want to talk simple taproot channels now or when we
get to that PR later?

**Mark Erhardt**: Let's do it later.

**Mike Schmidt**: Okay, great.  Notable code and documentation changes.  We have
a Bitcoin Core one, we have a bunch of LDK that hopefully Matt can walk us
through, and then that LND Simple taproot channels.

_Bitcoin Core #27460_

So first one, Bitcoin Core #27460, adding a new importmempool RPC.  Murch, what
is the motivation for wanting to import a mempool?

**Mark Erhardt**: Yeah, maybe you run multiple machines to operate a mining
pool, for example.  So, Bitcoin Core only forwards transactions when it first
hears about them.  So, if you just bring online a new node in a mining pool
cluster, it wouldn't really have any transactions in their mempool and it would
only hear about the new announcements.  So, it would perhaps build less
efficient or complete block templates for the time being until it's been online
for a while.  So, with the export feature that we've had for the mempool for a
long time, you could now just export the mempool of a running node and import it
into this machine, for example, to jumpstart it with a full mempool.  I think it
might be useful in some testing.

I think it's most definitely just for power users.  I don't think that a regular
node operator that has an intermittent node, or brings online their node after
it was offline for a bit, would really care about that.  And we do persist the
mempool between shutdowns anyway, so if you're just, I don't know, shutting it
down to upgrade the version and bring it back online, we'll just have missed a
few minutes of the broadcast transactions in between.  So, yeah.

**Mike Schmidt**: Murch, is that use case that you mentioned for mining pools
using this RPC, is that something that they communicated that they would like,
or is that more something that was theoretically thought could be useful for
them, and thus that was the genesis of the PR?

**Mark Erhardt**: I'm afraid that I'm not aware of any communication with miners
there.  I just saw the PR, and there are no linked issues either, so I'm not
sure what motivated Marco to work on this, but yeah.

_LDK #2248_

**Mike Schmidt**: All right, well, we'll begin our LDK PR marathon here.  The
first one is #2248.  Matt, do you want to walk us through these?

**Matt Corallo**: Yeah, so like you mentioned in the description, in Lightning,
in order to sync the gossip in a DoS-resistant way, the DoS protection for
downloading the gossip in Lightning is that every channel announcement points to
an onchain UTXO and says, "Hey, this is my UTXO, and here's a signature proving
that between me and my counterparty, this is actually the 2-of-2, and we control
this output".  So, certainly LDK has had the ability to verify those forever,
but we've never actually had sample code that did it.  There's just some code
and various other repositories that did that verification.

Now, we added a utility that does that against local Bitcoin Core RPC or REST.
So if you have a REST or endpoint from Bitcoin Core or RPC endpoint on Bitcoin
Core, you can do this.  Of course, you need to increase the RPC command queue in
Bitcoin Core, but basically most applications which do material queries to
Bitcoin Core have to do that.  And in fact, maybe Bitcoin Core should make that
default, I don't know.

_LDK #2337_

**Mike Schmidt**: And then the next one for LDK is #2337, making it easier to
use LDK for building watchtowers.  Maybe talk about that a bit.

**Matt Corallo**: Yeah, I mean this basically just required exposing a little
more details.  We already had logic in LDK where you could have hooked this, but
it would have been a little gross.  Instead, we added some additional details in
a different part of the code that allows you to hook basically after we've
intended to commit to a state update, but before we actually commit to the state
update by sending our peer any messages about the update.  You can now hook the
channel update mechanism to get basically what the counterparty commitment
transaction will look like and then later what the revocation secret for that
is.  And this allows you to integrate with any of the, like I mentioned earlier,
the more standard watchtower models, which allow you to enforce stale main
balances, unencumbered balances, but if there were any in-flight HTLCs at the
time, you won't manage to enforce that.

LDK has always supported running what's basically copies of the main enforcement
logic on distributed machines, or on many machines, which will allow you to
enforce that.  The HTLCs in-flight end up resolving correctly, but that scheme
does require your private keys on this distributed fleet of machines, whereas a
standard launch tower model does not.  So there's trade-offs there, we now
support both, which is great, or more formally support both, I guess, which is
great, but yeah.

**Mike Schmidt**: Matt, I had a note here unrelated to these PRs.  We covered
the release of the LDK node software I think in the last month or so in one of
our other segments, and I wanted to just maybe ask you how has reception to that
software been?  Maybe just provide a quick overview of why you guys released
that.  Again, unrelated to these PRs, but I figured since we have you, maybe you
could plug that.

**Matt Corallo**: Yeah, totally.  We've had a great response to it thus far.
We've had a bunch of people using it to build new wallets that haven't released
yet, or you're playing around with it, or what have you.  So basically, LDK has
always been intending to fill a different niche in the Lightning node space than
LND, CLN, or Eclair really fill by being much more choose your own adventure.
It's a library, it's not a daemon.  If you want to do something much more custom
or integrate with an existing onchain wallet or integrate with an existing chain
sync or be more enterprise and run different pieces in your own database backend
that you have custom doing some weird multidata center sync, whatever it is, LDK
lets you build that.

But building that requires some amount of actually building a thing.  So
historically, this is materially limited.  Developers who still want to use LDK
on mobile or for other reasons, but don't want to go to all the effort to build
all of those integrations themselves, a leaky node is more of a default, more
opinionated, still a library, but a much simpler library.  You just basically
import the library, you call the start method, and now you have a Lightning
node; you call open channel, and now you have a channel, and now you can send
payments, so much less work to do.

There's also ongoing work on the LSP spec side of things.  There's a number of
different teams, no one actually on the LDK team, but a different team at Block,
as well as a number of other teams, Breez and a number of other folks working on
a spec for how LSP communication should work.  And there's ongoing work to add
that logic to LDK by someone from another team at Block, not on the Spiral team,
that will allow for a very easy default, where you integrate this LDK node
library, you call start, and then you point it at an LSP, and now you're kind of
done, you have a Lightning node, and you can just get an invoice, and it all
works with nice LSP integration.  But there's ongoing work to make all of these
things easier to standardize all these things, so that there's just less work
for people who want to create a Lightning wallet for some specific purpose.

We really want to enable more people to create Lightning wallets and Lightning
integrations so that there's a lot more competition in that space, because we
really think more competition is going to lead to much better UX, much more
reliable, just more interesting wallets out there and more interesting
integrations that just don't exist today.

_LDK #2411 and #2412_

**Mike Schmidt**: Jumping back to the PRs, the next two were related to LDK's
support for blinded payments.  And maybe you can talk a little bit about that,
and also sort of separating the code related to blinded payments and onion
messages.

**Matt Corallo**: Yeah.  So, this is one of these kind of major projects across
the Lightning space right now, is eventually BOLT12, and BOLT12 requires several
different pieces.  It's blinded paths as well as onion messages as well as the
new offer and invoice formats.  So, LDK has landed onion messages and we've had
support for blinded paths are the ability to give someone a piece of opaque blob
that says, "Hey, if you want to talk to me or send a payment to me, you have to
first talk to Mark, and then here's some data that if you give Mark, Mark will
know where to relay it to get it to me".

It's very similar to how Tor Onion services work, where there's an introduction
point, the client connecting to the Onion service is going to connect to the
introduction point, but then only the introduction point knows how to get
further onwards to the actual host that's hosting the data.  Blinded paths work
in the exact same way.  Again, as you point out, LDK has had code for blinded
paths for messages, for onion messages, so that you can send messages with
recipient privacy, but we have not had it for payments, which is the same basic
cryptographic primitives, but has additional steps to deal with fees and all
that kind of other good stuff.

So, we're working on adding that to our payment flows.  We have a number of PRs,
as you highlight, some of them have already landed, others hopefully will land
in the next week or two.  And we hope to get blinded payment support as well as
full BOLT12 support in, well, not very long, a month, maybe, but these things
have a tendency to get delayed sometimes.

**Mike Schmidt**: Yeah, we know the open PR from Val, #2413, for route blinding,
which depended on a couple of these PRs that we highlighted this week.  Is there
a reason for the flurry of LDK activity this week?

**Matt Corallo**: I think what you're really seeing is you're seeing a lot of
stuff finish all at once.  There's just been a lot of long-term projects that
have been making slow progress across the project, and then there's a bunch of
stuff that intends to get done all at once.  So, we're trying to land -- a big
thing for the project has been this broad async support theme, where folks want
to have modern async programming with async await in Rust, but also has become
kind of a default way of programming for Python and JavaScript and all kinds of
other languages.  And LDK has had some support for it, but relatively weak
support for it, and we're retooling a lot of our state machine just to make the
storage layer have first-class async support.

So, that stuff's trying to finish up in the next few weeks, but that's been a
six-month project.  BOLT12 has been a six-month project, and a bunch of stuff is
finishing up this month.  So, yeah, we've just seen a lot of stuff kind of fall
over all at the same time, or get finished up all at the same time.  In addition
to, we've had a number of external contributors start working on LDK.  So, the
support for watchtowers that we talked about was actually a summer Bitcoin
intern.  We've had some support for better signing, external signing devices
that's being worked on by some folks at Lightspark, and we had some of this work
for the LSP spec being worked on again by a different division at Block, not
from Spiral, but who is trying to run an LSP.  So we've had a number of
different external contributors start contributing more materially in the last
month or two, which has also led to a number of additional PRs.

_LDK #2507_

**Mike Schmidt**: Next PR to LDK was #2507, adding a workaround for a
long-standing issue in another implementation that leads to unnecessary channel
force closures.  Dave was diplomatic in his not naming of the implementation!

**Matt Corallo**: Are we allowed to mention the implementation?

**Mike Schmidt**: Yeah, go for it, maybe talk a little bit about that, Matt.

**Matt Corallo**: Yeah, so the other implementation was LND.  LND wrote a good
chunk of their code before there was a Lightning spec, and part of their channel
closure logic, where you try to negotiate the current closing transaction in a
way that doesn't result in doing this force close that locks your money up for
two weeks, was written before there was, in fact, the Lightning spec.  And the
PRs to get it up to actually supporting the Lightning spec, it turns out there
were some issues in the way the Lightning spec was phrased for the co-op closing
stuff.  Another issue, actually, one of those issues we found LDK had an issue
with not too long ago, even between two LDK nodes.

So, Eugene, who was at Lightning Labs at the time, I guess he's still part-time
there, a number of months ago, maybe a year ago now, worked on improving the
BOLT spec.  And then there were some PRs to actually implement the modern co-op
close logic in LND, and those never actually made it over the line.  And so,
this is actually a PR on LDK to work around the LND, those things never making
it over the line, and we just kind of do something vaguely brain dead.  But
basically LND gets mad about a message and we just repeat the message until
morale improves.  And eventually, LND will accept our message.

But yeah, so the state of co-op closing, Lightning is still a little wonky and
the theory negotiation very often fails, even when we don't hit this bug.  So,
we're hoping for rewrite number three or two of the co-op close logic on the
Lightning spec that Rusty opened not very long ago.  I don't think anyone's
implemented it yet, but we're hoping that everyone implements that.  And then
finally co-op close and Lightning will be at least kind of sort of reliable.
But these days, there are many reasons that lead to force closes during co-op
close all the time.

_LDK #2478_

**Mike Schmidt**: Next LDK PR is #2478, and the genesis of this was an issue
that was open that says, "It would be useful to provide the HTLCs that settle
the payment via the payment claimed event, both from a logging and an auditing
standpoint".  Matt, maybe you could talk a little bit about what that means and
why that's useful.

**Matt Corallo**: Yeah, so this is one of the folks I mentioned from Lightspark,
who they've been playing with.  They're running LND for their kind of "main
nodes" that they use for custodial services, but they've been playing with LDK
for some more custom integrations they want to do that's not fully custodial.
And here they wanted a little more details on -- they try to do careful external
accounting of the Lightning node that they don't rely on what's in the Lightning
node, they rely on just pulling data out of it and then doing their own
accounting against it.  And they just wanted a little bit more information when
a payment has been claimed, so when you received a payment.  Oh, is this
forwarding?  Oh, this was payment claiming, so this was when you receive a
payment; a little more information about just which HTLCs, where they came from,
which channels they came in on and kind of that good stuff so that you could see
basically which channels were being used, for how much, and exactly what those
HTLCs looked like, so that they could line them up with those HTLCs when they
were pending.

_LND #7904_

**Mike Schmidt**: Last PR for this week was to LND, LND #7904, adding
experimental support for simple taproot channels.  This is related to the LND
0.17.0-beta.rc1 that we covered earlier.  Murch, you mentioned you recorded a
recent podcast related to this topic.  Do you want to talk about that?

**Mark Erhardt**: Yeah, actually it's been two months now, almost.  It was
around the LN Summit.  We had Elle and Oliver Gugger here in the Chaincode
office and recorded a Chaincode Labs podcast with them.  So, that's really a
comprehensive coverage of the topic of simple taproot channels, if you want to
dive more into the topic.  From what I remember, the general gist is that they
use a funding output that is taproot-based, of course, and that allows them to
look like a single-sig spend on co-operative closes, which slightly reduces the
cost and improves the privacy for co-operative closes.

The other changes are that some of the commitment transaction expressions move
into tapleaves, so script leaves in the script tree of the taproot output.  So,
if you have a unilateral close, you get slightly smaller outputs and you leak a
little less information.  But yeah, there's a bunch of details that had to be
considered.  For the time being, I think they are also sticking to HTLCs, which
makes it easy to forward because you also only really can use Point Time Locked
Contracts (PTLCs) if all hops along a route support PTLCs.  So, that makes sense
to leave that for the future.  Yeah, and I don't know much more about this PR
specifically, maybe Matt knows more.

**Matt Corallo**: Yeah, I mean like you mentioned, it's kind of setting up stuff
for the future.  I guess I don't know a good chunk about the protocol, I haven't
looked at the LND-specific code logic for it.  But it's really setting up the
taproot channel so that in the future, we can do PTLCs, and in the future,
Lightning Labs can do their taproot assets now.  So, this is only currently for
private channels; you need a change to the gossip to be able to make these
channels public and route wired HTLCs for other people.  But it's a nice feature
as is and especially for private channels, it allows it to just look like a
standard P2TR output and not a pay-to-multisig output, a 2-of-2 multisig, which
means that you do get a little better privacy as a Lightning node, as long as
you never force close, as long as you only ever co-op close, which like we
mentioned, is still something that needs a lot of improvement in Lightning.

But it would get you a little better privacy, which is pretty nice by itself.
But that's the only kind of immediate change for this.  In the long term, it
will tee things up to have many more features, though.

**Mark Erhardt**: Right, so if you have a public channel, you would announce it
on the network anyway, and you tell people what the funding output is.  So, you
don't really gain a lot of privacy there against an observer that gets Lightning
gossip.  But for a hidden channel, or unannounced channel, I think is the term
of art now, that gives a little bit of a privacy boost.

**Matt Corallo**: Yeah.

**Mike Schmidt**: Murch, anything to announce before we wrap up?

**Mark Erhardt**: Well, next week is TABConf, so if you're in town, we will have
a Builder Day desk from, well, it's really, achow and I will be talking about
Bitcoin Core stuff, but if you have questions about Stack Exchange or Optech or
whatever, we can also maybe talk about that.  So, maybe see some people there at
TABConf.

**Mike Schmidt**: Well, thanks for you all joining us this week and thanks to
our special guests, Matt Corallo, Brandon Black, Greg Sanders, James O'Beirne,
and always to my co-host, Murch, and we'll see you all next week.  Cheers.

**Mark Erhardt**: Great episode.  See you.

{% include references.md %}
