---
title: 'Bitcoin Optech Newsletter #241 Recap Podcast'
permalink: /en/podcast/2023/03/09/
name: 2023-03-09-recap
slug: 2023-03-09-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by James O'Beirne and Greg
Sanders to discuss [Newsletter #241][news241].

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/66481895/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-2-13%2F2e2d3d8d-25d8-c037-24da-5193bdb1c466.mp3" %}

## News

{% include functions/podcast-note.md title="Alternative design for OP_VAULT" url="news241 op_vault" anchor="op_vault" timestamp="0:41" %}
{% include functions/podcast-note.md title="New Optech Podcast" url="news241 podcast" anchor="podcast" timestamp="23:29" %}

## Bitcoin Core PR Review Club

{% include functions/podcast-note.md title="Bitcoin-inquisition: Activation logic for testing consensus changes" url="news241 pr review" anchor="pr-review"
timestamp="24:33" %}

## Releases and release candidates

{% include functions/podcast-note.md title="Core Lightning 23.02"
  url="news241 cln" anchor="cln" timestamp="38:01" %}
{% include functions/podcast-note.md title="LDK v0.0.114"
  url="news241 ldk" anchor="ldk" timestamp="40:00" %}
{% include functions/podcast-note.md title="BTCPay 1.8.2"
  url="news241 btcpay" anchor="btcpay" timestamp="40:52" %}
{% include functions/podcast-note.md title="LND v0.16.0-beta.rc2"
  url="news241 lnd" anchor="lnd" timestamp="41:40" %}

## Notable code and documentation changes

{% include functions/podcast-note.md title="LND #7462"
  url="news241 lnd7462" anchor="lnd7462" timestamp="42:48" %}

## Transcription

**Mike Schmidt**: Welcome everybody, Bitcoin Optech Newsletter #241 Recap on
Twitter Spaces.  We'll go through introductions and announcements real quick and
then we'll jump into the newsletter.  I'm Mike Schmidt, contributor at bitcoin
Optech and also Executive Director at Brink where we're funding Bitcoin
open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin stuff.

**Mike Schmidt**: James?

**James O'Beirne**: Hi, I'm James, Coin HR representative.

**Mike Schmidt**: Greg?

**Greg Sanders**: Hi, I'm Greg instagibbs, Core Lightning engineer.

{:#op_vault}
_Alternative design for OP_VAULT_

**Mike Schmidt**: Well, thank you special guests for joining us.  First and
somewhat long news item is applicable to some thoughts that you guys have been
giving on the mailing list recently.  The topic is titled Alternative Design For
OP_VAULT and this came out of the Bitcoin-Dev mailing list and it was spawned by
a post from Greg Sanders.  And Greg, I think instead of me trying to summarise
what you're getting at here, maybe you can lay the land of maybe a quick summary
of OP_VAULT and then some of the alternative proposals and ideas that you've
come up with?

**Greg Sanders**: Yeah, so OP_VAULT is a targeted soft fork proposal to get
specific functionality that would be good for vaultlike systems, so you have
your coins in a vault and you trigger an unvaulting essentially, where it goes
into kind of a purgatory where in a certain window, these coins can be swept
into a recovery kind of cold storage, or be allowed to go where it was going to
go in the first place.  So, it's an extra step to have coins moved to.  This
allows a better security model for a lot of custom setups.

So, the idealized functionality—that part of it was great and people are loving
it, I think there's been really solid feedback on it.  But on the spec side, I
found it a little difficult to follow what opcodes are doing what and when
things are happening, and I felt it was partly because the functionality was
templated.  So, I basically took a few hours, sat down and tried to split apart
the functionality.

So, there's two opcodes: there's opcode OP_VAULT, and OP_UNVAULT, and I realised
that it's actually doing three things.  So I said, okay, how would I do this in
a little more taprooty way with three opcodes to do the specific things they're
actually doing, or trying to accomplish?  And that ended up in this email where
I basically said, there's a recovery path and there's a trigger path, where you
trigger this action to happen, and then you have the final withdrawal path, and
these are actually the three functionalities we want to capture.

So, I gave them arbitrary names, but I felt there's a pretty decent improvement
on the specification side and then things kind of went from there.  So, AJ
jumped in, Anthony Towns, and started giving his own feedback and whatever, we
can talk about that more later, so I'll just pause for questions, or caller
commentary for James as the proposer.

**Mike Schmidt**: Yeah, James, what's your I guess initial response to what
Greg's outlined?  I don't think there's anything too controversial yet, but
obviously you're the original author, so you may have some nuance to add to his
initial feedback.

**James O'Beirne**: Yeah, I think Greg nailed it.  When I put this proposal
together, I'm not really a script interpreter specialist, I've never written a
spec for a soft fork or the introduction of opcodes, and so I did it in probably
the most intuitive way for me, and I did it outside of a strict taproot context
initially.  So, when we decided to make these opcodes taproot own, there's
probably some kind of conceptual debt that didn't get brought up to speed, but I
think Greg did a really great job of decomposing that.  And really, like he
said, this preserves the sort of end use characteristics of what I had proposed,
it just makes it more native to the mechanisms that taproot gives us, which I
think is great.

To AJ's credit, I think he had tried to articulate something like this to me
privately and he may even have done it in some post in the mailing list.  But I
think by his own admission, he couldn't quite articulate it, and so Greg really
brought it home.  So, yeah, I think it's an improvement.

**Greg Sanders**: Yeah, so AJ said, "Hey, awesome, I tried to do that and I
couldn't quite get it to work, I hope it works", and then he was convinced it
worked, and then he made some helpful tweaks, some basic tweaks on it to clean
up a bit, and then he went a little farther too.  So, with my changes, I kind of
made an opcode that's a lot like tapleaf, what was it; TLUV, right?  Was it
TAPLEAF_UPDATE_VERIFY?

**James O'Beirne**: UPDATE_VERIFY, yeah.

**Greg Sanders**: Right.  So, I essentially made a simple version of that, a
very simple version of that, because once you decompose these things into these
three opcodes, suddenly the actual behaviour becomes clear.  So, one of them is
actually kind of like a TLUV, a simple one; and then the other one is actually,
it looked a lot like CHECKTEMPLATEVERIFY actually.  So this final withdraw
phase, it was similar but not quite the same, so we talked about it and briefly
AJ, James and myself came to the agreement that actually CHECKTEMPLATEVERIFY is
the functionality we're looking for here, so that was kind of another thing that
fell out of it.

Anthony went further with it and said, "What if we could make it more composable
with other functionality as well?" but we will pause here if you want to ask
about CHECKTEMPLATEVERIFY.

**James O'Beirne**: Yeah, so I guess maybe it bears repeating that the initial
proposal, the complexity came from the fact that you can spend OP_VAULT and
OP_UNVAULT outputs in two different ways.  One is the withdrawal flow and the
other is the recovery flow, and Greg's rework of the implementation ensures that
each opcode is only ever spent in one way.  So, when you're writing out the
specification, basically the witness structure that you're providing for each
opcode is going to be consistent across all usages of that opcode.

Then AJ stepped in and basically said, "We can take, I think Greg calls it the
OP_TRIGGER_FORWARD opcode, and we can actually generalise that into something he
calls OP_FORWARD_LEAF_UPDATE", which is actually, not to get too into the weeds,
but it's a special case of OP_TLUV, which he proposed earlier.  So, I guess in
this discussion you've really got three issues at hand.

Number one is Greg's conceptual rework of the implementation, which I think
everybody's onboard with.  I think I'm going to spend some time reworking the
implementation to be more TLUVy, but then you've got the CTV issue, which I
think again we're all three onboard with, in that the withdrawal process in the
vault, basically what you have to do is when you're triggering a withdrawal, you
have to say, "This withdrawal is locked to go to these outputs".  So, you have
to have an opcode that basically advertises, "When this gets spent, it's
definitely going into this set of outputs".  And it turns out that's just
exactly what CTV does, and the version of it I'd implemented actually had txid
malleability issues where you could, for example, change unlock time.  So
anyway, the long story short on that one is that I think we're all three in
agreement that basically it would be great to just have CTV as part of this
proposal.

Then the third issue, where there's a little bit more conceptual divergence
between the three of us is, AJ introduced a sort of more general mechanism
that's OP_FORWARD_LEAF_UPDATE, which we're calling OP_FLU.  That kind of allows
you to build the specific OP_VAULT functionality, but it also allows other stuff
too, and I think we're in the process of figuring out what exactly that other
stuff is and what it buys you, because I'd like to keep this proposal very
targeted to vaults, and I'm hesitant to introduce a wide-open opcode that makes
the proposal a little bit harder to reason about and harder to test.

**Greg Sanders**: Yeah.  So actually, I'll stop, let people ask questions.

**Mike Schmidt**: Yeah, I just wanted to, I guess, recap what's going on at
least in my understanding.  The initial OP_VAULT proposal from James involved a
fairly specific use case, if you will, this vaulting use case, and it used two
different opcodes.  But the way that those opcodes were constructed, they were,
I guess, bigger Lego pieces that had some logic to them that allowed some
branching, I guess; the different ways to use those two different opcodes.
Yeah, go ahead.

**Greg Sanders**: So, there's two things that I didn't love about it.  So, one
is it has a recursive script evaluation step, so when you're doing the initial
triggering for the unvault, basically you're stuffing another program in there
and running that as the authorization step.  So, it would have like a checksig
or a multisig or timelocks, whatever you want in there, but it's a recursive
evaluation.  So, you have the script interpreter, then you're doing another
script interpreter inside.  It's limited to one recursion step but it's not
quite as composable or elegant, in my opinion.

Then the second is just the dual purpose of these opcodes, just to me made it
harder to reason about.  That's it.

**James O'Beirne**: Well, yes, that's all right.  I want pushback on the idea
that it's not as composable because I think in practice, it actually is, because
anything that could have lived as a sibling tapleaf, or whatever, that could
have lived in the recursive script that you're embedding.  But I agree totally
that it's a much cleaner approach to use this step.

**Greg Sanders**: Well I'll push back in the sense of yes, for that step, the
expressivity is probably equal, but for example, I can't think of a really clean
way to do miniscript where I think if it's all one level, the miniscript story
gets a lot simpler.  That's what I'm thinking of from a wallet developer
standpoint.

**James O'Beirne**: Yeah, that may well be.  I hadn't thought through miniscript
at all.  Continue, Mike, yeah.

**Mike Schmidt**: In the process of evaluating these original opcodes, it sounds
like the simplification, if you will, of putting the features into three
individual opcodes has not only decreased some of the complexity, but also
spawned this discussion about more generalised ways of using these smaller Lego
pieces to build non-vaulty things, and that's where CTV, it sounds like, comes
in a bit.  So, it sounds like the scope has changed, maybe expanded a bit on
this proposal, would you say?

**James O'Beirne**: So, yeah, the CTV issue's a little bit orthogonal to all
this stuff, so it's a little bit of a shame that it got rolled in, but we all
simultaneously realised as we were talking about this like, "Oh, yeah, there's
this txid malleability thing with the existing proposal and CTV actually fixes
that".  So, CTV can kind of be separated from taprootification generalisation
discussion, but I want to remind people, I guess, that this gets a little
fraught politically because CTV was always kind of implicitly part of the
proposal.  One of the first discussions that came out of my initial proposal was
Ben Carman saying, "Hey, if you send to one of these OP_UNVAULT outputs with a
zero delay, you basically get CTV", and he's right, and he was excited about
using that for DLC efficiencies.

So, in a sense, CTV has always been a part of the proposal, it's just we all
realised that actually Jeremy put a lot of thought into how to avoid malleation,
and we should just call a spade and actually make use of CTV.

**Greg Sanders**: And, I mean take advantage of all the review cycles, as it
said, a lot more review cycles than whatever opcode I made up on our mailing
list.

**James O'Beirne**: Right.

**Greg Sanders**: Yeah, so I guess the divergence, as James was saying, is more
like how general will this kind of script forwarding part, this trigger part be,
and I think I'll describe two things.  The discussion's still ongoing, but the
two things we've seen that fall out of this is, if you have a more general TLUV
construct, you can have kind of arbitrary script forwards in a natural way to
the withdraw step.  So one thing is, you could add an extra authorization step
on the final withdraw.  Now, I don't know if you'd necessarily want that, but
that's just a side discussion.  And then the second is, yesterday I was sitting
down, I was thinking, what if we want to use these primitives that AJ lined up
to do essentially a time delay for withdraw, so a rate limiting?

So, let's say you want a smart contract vault that only lets 1 bitcoin get
withdrawn a day, how do you build that?  And I actually just rearranged the
pieces and made it work, which is kind of interesting to me.  So basically,
there's this tension between targeting what we believe is an exact kind of
idealized flow that we want to solve, which was James' proposal, versus giving
smaller Lego pieces that might be able to be put together to do maybe
alternative vault designs or other use cases.  So, that's the tension there.

**James O'Beirne**: I think Murch has got his hand up.

**Mark Erhardt**: Yeah, I'm kind of wondering, so with CTV, a large part of the
debate was that it was such a broad set of possibilities that it was really hard
to delimit what you would be able to build with it, and then had some people
worrying.  Now, you guys saying that you want to use CTV basically as the
spending step of the vault makes me think that you're going to inherit a lot of
that debate, and I was wondering how you are thinking about that.

**James O'Beirne**: Do you want to handle this, Greg?

**Greg Sanders**: I could, yeah.  Basically, we already made an opcode that was
like a bad version of CTV, and that was kind of our idealised functionality.
So, I think the pushback here would be that it is exactly the step we needed for
the use case, so it's a composable piece of a whole, yes, but it's exactly what
we need.  So, that's my opinion.

**James O'Beirne**: Yeah, I keep calling this "convergent evolution".  I didn't
set out to design or redesign CTV, it just happened to be exactly what was
needed to make vaults work.  You kind of just can't have vaults unless you can
say ahead of time, "Hey, this pending withdrawal is going to this exact set of
outputs".  So I guess that's all CTV does.

Murch, to your question specifically, you could introduce a very contrived
constraint that says, "Okay, you're only able to use this CTV-like behaviour if
the output that you're spending is an OP_VAULT".  I just think that would be
kind of a shame, because nobody who ever gave CTV the time of day from a
technical standpoint ever came up with any class of probable risk around, you
know, "This usage is going to be dangerous".  I think from the technical side,
the objection was always like, "This doesn't go far enough", or, "This doesn't
nail any one particular use case".

I think when you have CTV plus the now reduced vault overlay, then you really
nail this vaults use case.  And so, I think it becomes a very compelling reason
to introduce CTV as a prerogative.  But yeah, I'll be honest, I really want
vaults because I really think it's an important thing to have in Bitcoin and I'm
very sadly concerned with how CTV might drum up a bunch of --

**Mark Erhardt**: Yeah, to respond to one of the first parts here, being able to
spend any vaulted UTXO with a CTV output would just make people that want to use
CTV vault their stuff before.  So, it just makes it more complicated to do the
same thing.  So from that standpoint, if you do want the full functionality of
CTV, then CTV should just be a first-class citizen.  At least we then waste the
redirection where people create extra transactions just to do exactly the same
thing.

But yeah, well, a lot of water has gone down the river since, but I am just
thinking that it might be a possibility that people hear that their CTV in
your proposal under the hood, and that triggers people just from past
experience.

**James O'Beirne**: Yeah, I think a lot of education, or at least explanation,
is going to be required to basically say, "From the genesis of this proposal,
this functionality was always in there; CTV's just a different name for it".
So, yeah, I'm gearing up to prepare myself for that, and I think that's why it's
important that Greg, AJ and I continue to collaborate on this, because if it's
just a lone effort from me, I'll probably get overwhelmed, and I think the
chance of a functionality like this winding up in Bitcoin won't be as high.

**Greg Sanders**: And personally speaking, I think this template verify thing
would be very enlightening to me to see who's in it to build self-custody things
and who's in it for kind of affinity scamming, to put it harshly.  I think
tribalism is toxic and I was one of those people who said CTV didn't nail any
particular use case, so I was kind of against it.  But as part of a larger
whole, it doesn't make sense, so I really would say it's worse than a shame if
it gets killed because of that.

**James O'Beirne**: Yeah, agree.  And another point there is that AJ has a draft
for a CoinPools proposal, and I think maybe that's part of what's motivating
this OP_FORWARD_LEAF_UPDATE stuff.  But CTV's another part of that too, so I
just think this process of locking validation to a set of outputs seems to be
this fundamental building block that we just need to do interesting things with
Bitcoin.

**Greg Sanders**: Yeah, and AJ noted that.  So, these Core opcodes or Core vault
functionality are doing two things.  So, it's locking output scripts, saying,
"This output must be this", but it's also doing value sweeping.  So, for the
vault use case in general, it's like, move all of this value minus maybe a
refund or the revault amount.  So, AJ really liked this as well and I do too.
It's simple logic, seems to solve a number of use cases.

**Mark Erhardt**: Yeah, and I must admit it sounds good that there's now already
multiple people starting to converge on a proposal.  I think that was maybe
something also that was hard about CTV, was that it seemed to still have
everybody debating on what we actually want, whether it needs something.  And
here, with the focal point being the vault, it sounds that approaching it from
the point we want vaults and this might be a way to do them and then converging
on a solution is maybe a way to start talking about CTV again too.

**James O'Beirne**: Totally, and actually kind of an interesting anecdote for me
is, back in the 2021 TABConf, there was a really great panel between Jeremy and
Andrew Poelstra about covenants and they spent a lot of time more or less
debating the different approaches.  I asked Andrew at one point, and of course
I'm putting words in his mouth a little bit here, so my apologies if I'm
rephrasing this incorrectly, but I said, "So, do you have any sort of safety
concerns with CTV?"  He said, "No, I think it just doesn't go far enough.  And
for bitcoin to succeed, I think it needs recursive vaults, and CTV doesn't get
us to recursive vaults".  That sentiment really stuck with me, and that was
almost the impetus for me to sit down and start thinking about, okay, how can we
do recursive vaults.

**Mark Erhardt**: Yeah, anyway, I think my takeaway is focusing on how your
solution solves a specific problem is solve is going to be a better way of
teaching people about what you're trying to do, I think that will be easier to
communicate.

**James O'Beirne**: Totally, yeah.  So now in my mind, the big debate, the thing
we've got to sit down and figure out is, how granular or how small are the Lego
blocks for this.  Is OP_FLU going to be a part of the story or not, because I
had made a summary post where I took Greg's work and I think we were able to
whittle it down to two opcodes.  OP_VAULT has this TLUVy special case behaviour,
and then OP_VAULT_RECOVER handles the recovery, and then OP_CTV obviously
handles the final withdrawal.

I think AJ's counterproposal, or parallel proposal, is to decompose those into
formulations OP_FORWARD_LEAF_UPDATE and a few others.  And AJ's is able to
accomplish the vault design, but it's also theoretically able to do other stuff,
like Greg talked about, this rate limiting the vault process.  But I'm kind of
curious, I guess what we should figure out now is, number one, is there demand
for this onchain rate limiting thing?  That's a discussion we could have here, I
know Greg definitely has stuff to say there and I've got stuff to say.  And
then, are there other usages of this OP_FLU stuff, because on the one hand, I
really want to support three usages and I love the idea of general opcodes; on
the other, I don't want to endanger delaying vaults for a substantially long
time, because now we're considering these much more powerful, or not much more
powerful, but just more general opcodes?

**Greg Sanders**: Yeah, so to chime in, I agree with all that, it's just a
question of where on this little curve.  So we have the thing that's the most
jettified, the closest to your idealized setup, and then you have steps along
the way that's slightly less jetty, more composable means, like for example, we
could implicitly do OP_CTV, right, and save one witness byte.  But that just
confuses, that makes the spec more difficult, the story a little harder to tell.
And so, there's all these little steps along the way, and then there's just the
far extreme and we have to decide, or James has to decide, or we have to decide
as a community where we want to land on that.

**James O'Beirne**: Yeah, definitely.

**Mark Erhardt**: Well, I think we might not delve too deeply into that
discussion, because I'm not sure how many people have thought about it enough to
have a strong opinion yet.  But from what I gather, we mostly covered the news.
What do you think, Mike?

**Mike Schmidt**: Yeah, I think it's a great discussion.  It does seem like
there's a lot of energy here and it would be nice to figure out a venue, when
the time is right, that this could be discussed further.  Obviously, the mailing
list is the canonical place for that, but I'm wondering if at some point it
would make sense to have AJ on Spaces here with us and chat more about it.
Obviously, there's developer meetings and things like that as well, but it does
feel like there's some good momentum and it would be nice to help move it along
in some capacity as Optech, the entity, as well.

**James O'Beirne**: Yeah, I think we're still in the space of what's technically
possible with reasonable opcodes, I'd say.  Then the second step would be, what
do other people think, and that needs to be a larger group of people.

**Mike Schmidt**: James, Greg or Murch, anything else before we move on with the
newsletter?

**James O'Beirne**: No, thanks for having us, and it's always good to talk about
this.

**Mike Schmidt**: Excellent.  Well, thank you both for putting your time and
attention towards these interesting problems and coming on and discussing them.
James, as an aside, it seems like you've been very intellectually honest and
receptive to feedback throughout your proposal process here, and so I think
that's very admirable, so I just wanted to put that on a personal note that
you're not being defensive about any of these approaches, and taking a lot of
feedback, and I think that's valuable.  So, thank you.

**James O'Beirne**: Of course.

**Mike Schmidt**: You guys are welcome to stay on.  Obviously, there's lots of
work to be done and more discussions to be had on this, so if you need to drop,
it's understandable.  We're going to go through the rest of the newsletter and
if you want to hang on and chime in, feel free to do that as well.

**Mark Erhardt**: One of the following items is Inquisition, which seems
somewhat related to soft fork proposals, so maybe you'll have some thoughts on
that too.

{:#podcast}
New Optech Podcast

**Mike Schmidt**: Yeah, I'm sure we could use some insights.  One quick other
news item before we move onto that Inquisition PR Review Club item is, we did
announce via Twitter last week about these Spaces being bundled up into a
podcast and getting transcriptions, but we also then had a coverage in the
Optech Newsletter this week and a special blog post that formally announces that
as well.  And so, we actually have last week's Twitter Spaces transcribed and
ready to go, we have a good flow with some different vendors doing the audio
editing and the transcription process, and I think it's valuable, as you can see
with discussions like we're having today with Greg and James, to try to get some
of that down so it's in the archives for people to review, whether that's in a
few days or in a few years.  It's valuable to have these experts talk about
their perspectives and capture that.  So, I'm glad we're able to do that and
thank you to James and Greg and the other experts who have lent their time to
this.

**James O'Beirne**: I just want to say thanks for having us.  I think this is a
great venue for, you know, somewhat casual but still kind of in the weeds
topics, so I'm really glad you guys do this on a weekly basis.

{:#pr-review}
_PR Review: Bitcoin-inquisition: Activation logic for testing consensus changes_

**Mike Schmidt**: Awesome.  We have a monthly segment that we do for the
newsletter, which is Bitcoin Core PR Review Club, and for those that aren't
familiar, PR Review Club is a weekly IRC meeting in which some organizers get
together, they prepare notes about a particular pull request, usually to Bitcoin
Core, although I think in this week it's not technically the Bitcoin Core
repository, and then prepare questions and answers and background information
about that pull request, so that folks can join once a week and discuss, answer
questions, hear how other Bitcoin developers are thinking about reviewing
certain PRs, the approach to certain PRs.

It's also a good way, if you're interested in the code base and trying to see
where you might be able to add value, is to jump into those PR Review Club
meetings.  You may be doing P2P one week or, in this case, Bitcoin Inquisition
the next week.  It's a very lurker-friendly way to get familiar with the Bitcoin
Core codebase.  So, take a look at that if you're interested in the technicals.

This month, we covered Bitcoin Inquisition, and this was a PR by AJ Towns, and
there was a change to Bitcoin Inquisition in terms of the activation and
deactivation logic for testing different consensus changes.  So, AJ actually
authored the PR and was the host for this PR Review Club.  Larry was kind enough
to do a writeup for the newsletter this week, and Murch has his hand up.

**Mark Erhardt**: Yeah, maybe we should first talk a little bit about what the
Bitcoin Inquisition proposal, or project, is?

**Mike Schmidt**: Absolutely.

**Mark Erhardt**: So, I think you can think of Bitcoin Inquisition as a staging
ground for soft fork proposals.  The idea is it's a custom signet where you can
easily activate and deactivate soft fork proposals in order to test how they may
be used, or how they play with each other too.  So, the idea is that AJ just
runs a signet and anyone that wants to test a soft fork proposal can code it up
against signet, well, specifically against Inquisition, and then activate it
there very quickly, test it and deactivate it afterwards when they're done
testing so that they can, for example, try a second variant of the same proposal
and see which one performs better, and also give it global access to other
people that want to play around with it.

**Mike Schmidt**: And, Inquisition has a couple of different soft forks already
activated and I think, James, you were working to also get OP_VAULT added.  I
assume with some of these proposal changes, maybe that's on pause right now, is
that right?

**James O'Beirne**: Yeah, so right now I think AJ's got BIP118: ANYPREVOUT,
BIP119: CTV, and I've got a PR up for the version of OP_VAULT that's described
in the BIP.  But obviously, yeah, with the changes that Greg and AJ proposed,
I'm going to go back to the implementation phase of that and do an
implementation and then rework the BIP.  But in the process, yeah, there will be
updates to that Inquisition PR there.

One interesting note is that, yeah, there are some differences with the way that
Inquisition handles deployments, and so when you're implementing stuff for
Inquisition, it's a little bit hairy from a rebase standpoint, because you've
got your PR against Bitcoin Core, and then you've got your PR against
Inquisition, and they have to be maintained in slightly different ways.

**Mike Schmidt**: James, is Inquisition running on the default signet, or a
custom separate signet from the one that's default in Bitcoin Core?

**James O'Beirne**: Yeah, this was confusing to me.  It's actually running on
default signet, and this works obviously because everything proposed for
Inquisition is a soft fork.  So, only Inquisition nodes are aware, or able to
handle the transactions that make use of the soft forks that are activated on
Inquisition.

**Greg Sanders**: Yeah, so you'll need a path from your node to the signet
mining node, because of standardness relay rules.  But once it gets there, to
every other node it looks the same, it looks as before.

**Mark Erhardt**: That's a good clarification, thank you.  So, I'm not sure if
we should just go through the questions one by one, or talk a little more
generally about Inquisition?  I think the main difference with Inquisition is
how soft forks are activated and deactivated: (a) we don't really have a
deactivation mechanism for mainnet soft fork proposals at all; and (b) given
that it's only a testnet, a valueless network specific to, well, stress test
proposal, we can much more loosely activate stuff.  So, what do you think, Mike?

**Mike Schmidt**: Yeah, I think we can maybe touch on this first question a bit,
which I think rolls into some of that, which is, "Why do we want to deploy
consensus changes that aren't merged into Bitcoin Core?  Why not merge them into
Bitcoin Core and then test it on the signet or testnet, or some such thing?"
That's sort of the first question that we highlighted from PR Review Club, which
I think touches on the motivation for Bitcoin Inquisition in general.  Murch, do
you want to take a crack at answering that?

**Mark Erhardt**: Sure.  So, if you merge a soft fork proposal to Bitcoin Core,
that generally means that you're touching consensus code, otherwise it wouldn't
be a soft fork, right?  And that is among the most sensitive things that you can
change about the Bitcoin Core software.  So, if any bugs are introduced, that
might even happen before the soft fork activates.  So, of course you could just
have a branch in which the soft fork lives, but to actually test it and to test
it against especially other parallel proposals, you might want to (a) merge the
code into a codebase together; (b) combine the forks, or branches, that have all
these different soft fork proposals; and (c) you really want to test what it
looks like when it's running, so we can get all of that on a separate network
much more safely than having that in Bitcoin Core.

**Mike Schmidt**: We have this notion of doing things on this Inquisition which
is on the default signet and then the question is, how do you deploy soft forks?
And if there's a bug in one of these soft forks that you're testing, how do you
undo it or update it with the updated soft fork code?  And then, how do you
deactivate it if, for whatever reason, that soft fork isn't something that the
community decides to move forward with?  And there's this new term, this
heretical deployment, and that's what's the crux, or the meat of this PR that
was reviewed at PR Review Club, is implementing this heretical deployment.

Murch, I don't know if we want to get into the details of the state machine, but
do you want to provide just a high-level overview of what that deployment is and
why that's different from what we do now?

**Mark Erhardt**: If we deploy something on the mainnet, we do want everybody,
or at least the vast majority of nodes and hashrate, to be ready to enforce the
new rules.  Especially in the past few years, we have been using hashrate as a
coordination mechanism, where nodes enforce the rules.  And that way, if the
majority of the hashrate enforces the new rules, we get a convergent network
state, where even if there are some miners that still mine by the old rules and
might actually mine a block that is invalid according to the new rules, we will
always end up with a best chain that is composed of blocks that are valid
according to the new rules.

So, on signet, we only have a permissioned set of authors that write blocks.  They
just sign off on the blocks, that's why it's the “sig”-net, and therefore we
already know exactly how much of the hashrate is going to sign off on blocks
then with the signet operators anyway.  So, we can have a much simpler
activation process where they basically just mine a single block that tells all
the Inquisition nodes when to update.  So, instead of having a long process in
which hashrate slowly over time starts signalling readiness, the signet operator
just mines a single block that has the activation flag, and then 432 blocks
later, the proposal activates.  That's about three days, and I guess on signet,
because the blocks are just signed into existence and probably are exactly every
ten minutes, that's exactly three days.

**Mike Schmidt**: Okay, so then you have an activated soft fork on Inquisition.
Now, what considerations are there around, "Oh, this soft fork has a bug, it's
been identified by the author, it's been fixed", how would you go about
remedying that in the Inquisition model?

**Mark Erhardt**: Yeah, here were get this new state in the state machine, which
is to deactivate, or DEACTIVATING.  So, instead of leaving a soft fork in
existence forever, as we want that on mainnet, and maybe even burying it
eventually, we allow for a path to go from ACTIVE to ABANDONED, and the same
process as for activation happens; the signet operator just mines a specific
block with the signal, and then I believe also, 432 blocks afterwards, the
proposal is deactivated and it goes to its final state, ABANDONED.

**Mike Schmidt**: And, in that deactivating state, am I right in understanding
that the point of that, in not just going from ACTIVE to ABANDONED, is to give
folks an opportunity to withdraw their funds from this soft fork before it's
deactivated or ABANDONED?

**Mark Erhardt**: I mean, signet funds of course are worthless, but I think the
stated idea is it gives people a chance to clean up the UTXO set so that there
are no outputs that are encumbered by those rules anymore, so if people are
actually broadly testing some Inquisition proposal, the stuff wouldn't live in
the UTXO set forever.

**Mike Schmidt**: There's a question here about taproot being buried, and I
think it might be an interesting thing to maybe highlight is, why is the taproot
soft fork the one that's being highlighted in Inquisition as one that needs to
be buried?  What about other soft forks that have occurred, Murch?

**Mark Erhardt**: So, let's talk about what burying a soft fork means.
Basically, a soft fork is always the introduction of additional rules that
restrict the set of allowed blocks.  So, for a node that follows the previous
rules, a soft fork will create new blocks that are more restricted, and
therefore will always be valid to old software.  We call that forward
compatibility, and that ensures that we do not split off nodes that are not
upgraded yet, but that they just continue to follow along with the best chain.

When we activate a soft fork, usually they use some form of new transaction
construction or other rules that are generally forward compatible.  So, if there
were very few instances of where those rules were broken before, we can just act
as if the rules were active since the Genesis block and encode those few
exceptions as exceptions in the block parsing.

So for example, for taproot, there were a few test transactions where people
send money to version 1 segwit outputs, and if you hardcode those exceptions, I
think it's six transactions, then you can act as if taproot were active from
Genesis.  That way, we can take out the activation logic and the special logic
that taproot is only supposed to be enforced from a certain height, and make
Bitcoin Core just enforce it from the get-go, with the exception of these six
transactions, where it doesn't apply.

So, in this case with Inquisition, in Inquisition all soft forks have a
time-out, so from the get-go when they're activated, they'll only last for some
duration.  And if taproot were also activated as, well, Inquisition proposal, a
heretical deployment, then it would only last for some short period of time and
it would have to be activated again and again.  I am mostly making this up from
what I've read in the PR Review Club!  But anyway, by burying taproot, we
just can have it part of the regular node behaviour and don't have this
behaviour where it times out.

**Mike Schmidt**: And, is part of the reason that taproot needs to be varied in
Inquisition is the fact that taproot is not buried in Bitcoin Core currently?

**Mark Erhardt**: That's an excellent question.  I'm not 100% sure, I think it's
not yet buried in Bitcoin.

**Mike Schmidt**: Okay, so Inquisition needs to handle that special case.  I
guess my assumption would be, if taproot was buried in Bitcoin Core, we wouldn't
need to be burying it in Inquisition, but further research for the users and
listeners here to determine if we're correct on that.  Murch, go ahead.

**Mark Erhardt**: I think that mostly happens roughly half a year to a year
after a soft fork has been active, or maybe even later, because you want to make
sure that everything went fine, that the node has wholly accepted and moved over
to the new rules.

**Mike Schmidt**: Murch, we can move on to releases and release candidates for
this week.

{:#cln}
_Core Lightning 23.02_

We've covered Core Lightning 23.02 release candidates for some time, including a
few weeks ago where we had some of the Core Lightning team on that gave a little
bit more detail about these different features.  I think it is worth it to call
out a few different of these features in the high level right now, which is
experimental support for peer storage of backup data, which is an interesting
feature, I think something that is valuable to the network; and then also,
experimental support for dual funding and offers.  Murch, what's peer storage
backup data?

**Mark Erhardt**: That's a pretty nifty little trick.  Essentially, you do
something like the static channel backup, and you hand that in encrypted form to
every single channel peer of yours, so anyone that you have a channel with will
offer to store some, I don't know, less than 50 kB of data for you.  And you
encrypt it so every time you reconnect to these peers, they will first hand you
this little backed-up data right after the handshake.  So that way, if you
lose your channel state, when the channels are closed, they go to the predefined
payout addresses, and that's included in the backup that every single peer of
yours has.  And because the peers give you these, whatever, 50 kB every single
time you reconnect to them, you don't really have to ask them for it and make
them aware that you might have lost your channel state, but they just give it to
you automatically and you know who your good peers are that way, and you always
regain access to your static channel backup.

So, this is notably not the full backup of the states of the channel, but it's
more if the channel gets closed and you get paid out, you'll get back your
money.

{:#ldk}
_LDK v0.0.114_

**Mike Schmidt**: The next release that we covered this week was LDK v0.0.114,
and there's a couple of different things that we noted.  One is the
security-related bugs, and if you jump into the release notes there, I think
we've discussed this in previous weeks, but there's a few different security
fixes, one with pending unfunded channels, one is with channel_ready messages
causing issues, and then there's also a division-by-zero issue that's also
resolved.  So, those roll up into the security-related bugs.

Then, there's also support for parsing offers.  Now, LDK does not fully support
offers yet, due to not supporting blinded path at this time, but you can parse
offers with LDK now, so it's getting closer.  Murch, any LDK commentary?

**Mark Erhardt**: No, I think you got it.

{:#btcpay}
_BTCPay 1.8.2_

**Mike Schmidt**: We highlighted the BTCPay 1.8.2 release.  I think we've
discussed previously that BTCPay does pretty quick release cycle, and so really
the bulk of the features that we noted in this release are from the 1.8.0
release, which was actually last week.  So, they've gone through a few different
releases since then, and the features that we highlighted are, custom checkout
forms on BTCPay, some additional branding options, Point of Sale views, and then
there's some address labeling.  And I wasn't able to see, I don't know if you
saw this, Murch, the address labeling, is that compliant with the new address
labeling BIP or not; did you happen to see that?

**Mark Erhardt**: I haven't looked into that, sorry.

**Mike Schmidt**: Okay, I couldn't see that but perhaps they are adopting that
new BIP fairly soon after it was official.

{:#lnd}
_LND v0.16.0-beta.rc2_

The last release we have for this week is LND v0.16.0-beta.rc2.  I didn't pull
out anything notable in this release to discuss.  You're welcome to look at the
release notes about this RC.  Murch, I'm not sure if there's anything that you
saw from this LND RC that was notable for listeners?

**Mark Erhardt**: No, I have not.  But I recently learned that there is movement
on offers for LND, and I think that it might be notable to mention that they're
aiming in spring to add blinded path support, if I understand that correctly.
There seems to be -- well, anyway, they're aiming, they're working on it now!

**Mike Schmidt**: Yes, there is a roadmap on the repository, I think, a visual
representation of the roadmap, but I don't have the link handy to share here in
this Spaces, but if you look you'll be able to find that.  We're jumping into
the Notable Code and Documentation Changes section, of which there's only one,
so I'll use this as an opportunity to solicit any questions or commentary from
the listeners.  Feel free to raise your hand or request speaker access and we
can get to you after we wrap up this LND PR.

{:#lnd7462}
_LND #7462_

LND #7462, allowing the creation of watch-only wallets with remote signing and
the use of stateless init feature.  My understanding is this is actually a bug
fix that you were able to create watch-only wallets with remote signing
previously using the RPC, but the option for this stateless init was not
provided.  So, this PR adds that and I'm not completely sure of the
permissioning system of LND, but I know they use macaroons, and I think the
stateless init feature does not save those macaroons to disc, it sends it back
via the RPC for the client to store that information.  Murch, did you jump into
this LND PR at all?

**Mark Erhardt**: Just roughly to the same level as you.  Yes, it sounds like a
bug fix, and basically the idea is that it allows you to have a hardware wallet,
or separate machine, that signs off Lightning interactions, or that's at least
my take.

**Mike Schmidt**: I thank you all for joining.  Murch, thanks to my co-host,
thanks to James, thanks to Greg for joining us and we'll see you all next week
at 14:00 UTC to discuss Newsletter #242.

**Mark Erhardt**: Yeah, thanks to you too.  See you then.

**Mike Schmidt**: Cheers, bye.

{% include references.md %}
[news241]: /en/newsletters/2023/03/08/
[news241 op_vault]: /en/newsletters/2023/03/08/#alternative-design-for-op-vault
[news241 podcast]: /en/newsletters/2023/03/08/#new-optech-podcast
[news241 pr review]: /en/newsletters/2023/03/08/#bitcoin-core-pr-review-club
[news241 cln]: /en/newsletters/2023/03/08/#core-lightning-23-02
[news241 ldk]: /en/newsletters/2023/03/08/#ldk-v0-0-114
[news241 btcpay]: /en/newsletters/2023/03/08/#btcpay-1-8-2
[news241 lnd]: /en/newsletters/2023/03/08/#lnd-v0-16-0-beta-rc2
[news241 lnd7462]: /en/newsletters/2023/03/08/#lnd-7462
