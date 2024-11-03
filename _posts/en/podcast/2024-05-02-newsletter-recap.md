---
title: 'Bitcoin Optech Newsletter #300 Recap Podcast'
permalink: /en/podcast/2024/05/02/
reference: /en/newsletters/2024/05/01/
name: 2024-05-02-recap
slug: 2024-05-02-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Tadge Dryja to discuss
[Newsletter #300]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-4-2/59701a99-6cd7-209b-ad51-c939e45fb88b.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #300.  Woohoo!
We're going to be talking about the exploding keys proposal that's similar to
OP_CHECKTEMPLATEVERIFY (CTV) today; also, an analysis of the OP_CAT vault
prototype using the Alloy analysis tool; we covered the arrest of Bitcoin
developers as a news item; and coverage of a Bitcoin Core Dev meeting, in
addition to our regular release and PR coverage.  I'm Mike Schmidt, I'm a
contributor at Optech and also Executive Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs, mostly a BIP editor
in the last ten days or so.

**Mike Schmidt**: Thank you for your service.  Tadge?

**Tadge Dryja**: Hi, I'm Tadge Dryja, a Bitcoin researcher, worked on Lightning,
discreet log contracts, utreexo, stuff like that.  Happy to be here.

_CTV-like exploding keys proposal_

**Mike Schmidt**: Excellent.  Thanks for joining us, Tadge.  Your news item is
the first one that we'll jump into here, titled CTV-like exploding keys
proposal.  Tadge, maybe what might be useful for folks, and I'm curious to hear
it as well, would be what's your explanation of CTV, and then maybe we can jump
into exploding keys and how these things are similar.

**Tadge Dryja**: Sure, and I'm sure everyone -- there's so many variants of
OP_CTV, and the general idea though, I'll say, and I hope I don't offend anyone
who's got a different idea of it, but right now when you make a Bitcoin
transaction, you send the two outputs, right?  And generally, we think of it as
sending to a person or entity.  But really, what we're doing is sending to a key
or encumbering it with, "This is the key that can sign to move the coins".  With
OP_CTV, the idea is instead of sending to a specific place, you send to another
transaction.  And it sort of seems like, well, if you're going to send to
another transaction, why not just send to all the outputs of that transaction
and sort of skip this two transactions in a row kind of thing.  But there's a
lot of useful parts where you can send to a transaction as an output, or do it
conditionally, or like one of any of these five transactions, things like that.

So it's CHECKTEMPLATEVERIFY, and the template part is you can pick which aspects
of the transaction, but I think the fundamental idea of it is, instead of
sending to a key, send to another transaction.  And then, there's a lot of
different variants of it, which the exploding keys I think is one.

**Mike Schmidt**: I'm glad I asked that question because I enjoyed the answer,
and I'm sure I've heard someone put it similarly, but I thought that was an
interesting way to put it.  Okay, so what is your interest in CTV and exploding
keys?  You've obviously done a lot of different research in Bitcoin and
Lightning, so why are you here and what is exploding keys?

**Tadge Dryja**: Yeah, so like many things in research, at least for me, you
think you have some amazing idea and then realize, "Oh wait, this is something
that someone's already made, but maybe in a different way".  So for example,
with discreet log contracts, I was like, "Oh, here's this whole new wacky
signature scheme".  And then talking to people at MIT, it's like, "Oh, wait,
this is just a schnorr signature.  Oh, okay.  Well, anyway, it's this new thing
that uses schnorr signatures".  So, with exploding keys as well, it's like, "Oh,
I thought I had something really cool and really powerful".  And then you're
like, "Oh, wait, this is just OP_CTV, but in a slightly different way".  So,
it's still worth publishing, whatever, put it on a website.  But actually, I did
come up with it middle of last year, and so it was like, it felt like it was
maybe something more powerful.

The way I was looking at it was similar to like, what are some people's
proposals?  Like OP_EVICT or coinpools and stuff where, similar to Lightning,
with Lightning you have a channel with two people in it, and those two people
can move their money back and forth and use Hash Time Locked Contracts (HTLCs)
to route between them and stuff like that.  But since the beginning, it's like,
"Well, wait, why are we stuck with just two people?  Why don't we have three
people, four people?  Why don't we have 100 people in this Lightning channel?
And then, that'd be way better, right?"  But it's hard.  The main difficulty is
the punishment mechanism really is restricted to two entities.  But so, there's
other proposals that are like, "Hey, can we have some kind of grouping of people
where they all share one output, but they can sort of leave that output?"  And
OP_CTV is similar to that.  And the idea of exploding keys is, well, can you
have a key that then you can show is actually a composite of many other keys?
And the ideal would be anyone can leave, or anyone can kick anyone else out.
But if they all are still online and cooperating, they can update their internal
balances.

While it doesn't quite do that, why I called it exploding is it's either all or
nothing, right?  You can make a composite key of, let's say there's ten people,
they all put their keys together and all put their bitcoin together, but the
only way that they can leave is to blow the whole thing up and all ten leave at
the same time.  There isn't, at least in exploding keys the way it's proposed
now, there's no easy way to selectively say, "Okay, we have ten people but one
of them seems to be offline, so we want to get rid of them and kick them out,
and they have their balance, and then the remaining nine can have an output and
continue to do multisig".  So, it's an all-or-nothing kind of blow up the key.

**Mike Schmidt**: So, people may be familiar with a sort of unilateral exit, has
been a term, I think, thrown around, and so that's something that's not
possible.  Everybody continues and cooperates or everybody leaves; is that
right?

**Tadge Dryja**: Well, so unilateral exit is possible with this.  It's just, you
don't have a fine-grained unilateral exit, right?  So the idea is, let's say ten
people all get together and one person wants to exit.  That one person can exit,
but in exiting, they sort of blow it up for the other nine.  So, everyone has to
leave at once.  And the way to do it is, and the way it works is that any one of
those ten people can cause the entire group to exit, which is okay, but does
definitely limit scalability.  There's two essential problems with these
groupings.  One is, someone's offline and they're impeding the rest of the group
from continuing; and the other is, "Everyone else is out to get me, and all the
other people are colluding against me to freeze my coins".  And so, both of
these are the opposite kind of problem.  One is, if one person's offline, okay,
we're now stuck.  But if we make it so we can continue even with one person
offline, that then means if all the other nine group together, they can
basically freeze or steal that one person's coins.

So, in exploding keys, it's all or nothing and anyone can blow it up, which
makes it brittle for large groups.  And so, it probably doesn't scale that well
to larger groups.

**Mike Schmidt**: Does that mean when it explodes, does everybody get their own
-- the ten people each get their own output, ten outputs; or, could you have it
be one output and then the nine go into one shared output because they are still
getting along, or whatever?

**Tadge Dryja**: You can't, okay, how do I say this?  Basically, it's all ten
explode at once.  You can do it recursively however, just like with OP_CTV.  So,
if you really think you know who that one person will be, you can set it up
like, "Okay, there's nine people and we're all online.  And then there's this
one person who really doesn't have his act together.  And so, we think that it's
very likely that this one person will get kicked out, and we will all stay".
So, you can construct it that way, and then it's nine can stay grouped together,
one leaves, and then that nine is still a composite that can then explode later.
So, you can set it up that way, but it's not -- and then I guess with stuff like
taproot, you could make a tree of keys that each explode in a different way and
stuff like that, so similar to OP_CTV.

The primitive itself just gives you a transaction, but you can sort of use other
things to combine scripts, like taproot, to have a selection of possible
transactions that it goes to.

**Mike Schmidt**: What's feedback been so far on your Delving post?

**Tadge Dryja**: I don't know if there's anything on Delving.  I need to write a
bit more about how it doesn't -- I want to write a bit about how it doesn't do
sort of fine-grained exit and how it may not be possible.  So, I've talked about
this with some people at Chaincode, some other people, and it's like, "Oh,
that's clever".  And I think Jeremy Rubin, who introduced OP_CTV, is like,
"Okay, yeah, that's cool".  It's not really that much better than OP_CTV.  It's
like, it saves 32 bytes, and those bytes are discounted anyway.  So, I don't
actually think, you know, if people have already done a bunch of work on coding
OP_CTV, I don't think it's worth scrapping that and say, "Oh, let's do it this
way instead.  It saves some bytes".  It's so similar that it's probably not
worth changing.  But it does feel like this is a new way to do it that maybe
could be useful in other situations, because it feels sort of like you're only
using keys and you're not using signatures at all, which is kind of cool.

So, you could do it in something like Mimblewimble.  There are certain cases
where you really don't have very much power, and all you can do is add and
subtract keys, and this is compatible with that.  So, it feels like it may be --
I want to get it out there so people can look at it and say, "Hey, maybe you can
use this somewhere else where it actually does do something more powerful".

**Mike Schmidt**: Murch, any thoughts?

**Mark Erhardt**: I think it's nice to put out fragments or seeds for bigger
constructs like that.  But yeah, I still maintain to be Switzerland on the whole
introspection discussion!

**Mike Schmidt**: Probably a good idea.

**Tadge Dryja**: Yeah, I'm generally pretty -- like when people were arguing
about OP_CTV a couple of years ago, I was like, "Yeah, we should do this".  I'm
much more soft-fork happy than I think many other people working in the space.
But yeah.

**Mike Schmidt**: Well, there's a big gathering of some of those folks here in
Austin.

**Tadge Dryja**: I know, I wish I could be there.

**Mike Schmidt**: Yeah, the bitcoin++ event on scripting.  We'll see what comes
out of that.

**Tadge Dryja**: I was there last year, I'll be there next year.  But yeah,
can't go this year.

**Mark Erhardt**: Yeah, it sounds like they have a lot of consensus around what
they want to do next.  So, I do hope that they also get together to write up why
we should be doing it and convince all the rest of us.

**Mike Schmidt**: Oh, Murch, I couldn't tell if that was sarcastic or not, I
haven't been following.  Is there actually consensus coming out of this?

**Mark Erhardt**: No, but they agree.  I mean, this is all the people that want
to do introspection, right?  So, I've been following some live tweeting and
there seems to be a lot of excitement among this crowd and they seem to be
agreeing on a lot of things.  So, I feel this is the right crowd to sit down
together and write it up in a way that inspires the rest of us.

**Tadge Dryja**: I guess, wait, one thing about that.  Now that I think about
it, the exploding keys, it does the same thing as OP_CTV, but there is no
introspection in that -- oh, I guess there is.  I'm just thinking of how you'd
code it.  Yeah, yeah, you'd still have to look at the output.  Okay, never mind,
yeah, I guess it's still introspection.  It's just a weird way to think about
it, but yeah.

**Mike Schmidt**: Tadge, thanks for walking us through this.  You've left this
Lego piece out for people to potentially construct something in the future.
Other than that, any calls to action for the audience?

**Tadge Dryja**: No, no, just check it.  If you're familiar with fun elliptic
curve things, look at it and say, "Hey, maybe you could extend it to this way".
And I'll try to post again maybe this weekend about what it doesn't do, and I
wish it would, but how that might not be possible.  So, yeah, just take a look.
Thanks.

_Analyzing a contract protocol with Alloy_

**Mike Schmidt**: Yeah, thanks for joining us, Tadge.  This next item may be of
interest to you, or maybe I'd be curious of your feedback if you can hang on a
few minutes.  The news item is titled, Analyzing a contract protocol with Alloy.
And in Podcast Optech #291, we had on Rijndael, who was talking about a vault
prototype that he had created using the proposed OP_CAT opcode.  Separate from
that, Alloy is a specification language for modeling software behavior.  And
this week, what we're covering is Dmitry Petukhov; I'm sorry, Dmitry, for
butchering your name.  He combined these two things and created an Alloy spec
modeled on the OP_CAT vault prototype.

So, in addition to Alloy's spec language, there's some analysis utilization
tools that complement having something in a formal spec language.  And it
sounded like Dmitry was doing this sort of to learn Alloy and potentially play
around a bit, but he's actually done some analysis on this vault using OP_CAT,
and there were a couple findings that actually tangibly came out of that.
Tadge, I'm curious, have you used any sort of modeling specification language
tools like Alloy before to model your ideas, or other things?

**Tadge Dryja**: No, I have not.  I know there's people pretty interested in
different formal verification and specification.  I haven't used any of those
things, but it sounds cool.

**Mike Schmidt**: Murch, have you used any such tools before?

**Mark Erhardt**: No, formal modeling or anything like that is a bit too far in
the theoretical script stuff for me.

**Mike Schmidt**: Well, Dmitry did a great job of not only creating the spec of
this vault prototype using OP_CAT, but also documenting his spec work with
comments.  And after the analysis, he had a couple findings that I'll quote
here.  We summarize them a bit in a newsletter, but I think maybe it would be
useful to hear it from his words.  The first finding is, "The specified model
demonstrates the need for the covenant script to explicitly check input index,
and also for the software handling the covenant to never lock the funds at the
output with an index other than 0".  And the second finding was, "The model
demonstrates that there is no need to enforce the number of inputs and outputs
of the current transaction, only number of outputs in the previous transaction
in the 'complete_withdrawal' case".  So, it seems like there were some tangible
things that the computer was able to deduce from having this specified, which is
quite interesting and I'm wondering if any of the folks here in Austin doing
their Bitcoin Script-y stuff are working on something like this to formalize
some of their proposals.  So, I thought it was interesting.  Murch or Tadge, any
additional thoughts?

**Tadge Dryja**: I know that people are testing OP_CAT and it's a fun, much more
powerful thing than it would appear to be, because literally all it is, you can
stick two byte arrays together, and that's it, but apparently you can sort of do
everything with it.  So, I know that in the last few days it's activated on
signet, and people are using it, so that's cool, but I haven't looked into it
nearly enough, but I should.

**Mark Erhardt**: Yeah, I've read the BIP a couple times in the past week.  So,
it got a BIP number last week, it looks very well specified.  It is also an
extremely small operation.  It literally just takes the top two stack items,
combines them, like Tadge said, as a concatenation.  So, if you have AB on the
stack, where B is the top element, it will become concatenated B as the new top
element, and that's all it does.  But for example, if you want to do a merkle
tree evaluation where we use a concatenation to hash together the two txids or
leaf, sorry, children nodes that -- well, sorry, anyone that's looked at merkle
trees knows that it's a binary tree, it starts at the txid level at the bottom,
and it combines at each level two nodes below per concatenation.  So, if you
have OP_CAT and we already have a hash opcode, you can actually do a merkle tree
validation.

There's some interesting ideas of what you could use that for, for example, you
can prove that a transaction was included in a block with sufficient hash, like
enough proof of work.  You can't prove that it's actually part of the best
chain, but at least it's in a block that has a lot of work.  And you can make
another transaction therefore depend on something else being confirmed.  Again,
not in the best chain, just in a heavy proof-of-work block.  And people are very
creative.  Apparently Poelstra has put out a couple of blog posts on OP_CAT and
schnorr tricks, what you can build with it; there's vault designs with it;
there's some thought on, you can do Lamport signatures with it, where it's not
100% sure whether that would actually be quantum secure, because you can still
spend with the keypath if you have a scriptpath that would have the Lamport
signature in it.  There's all sorts of crazy Bitcoin wizard stuff.

**Mark Erhardt**: Murch, you've been doing your OP_CAT homework lately, huh?

**Mike Schmidt**: As I said, yeah, I've gone through.  I think I've looked at
every of the 150 open PRs in the BIPs repository last week, and OP_CAT was one
of the ones that I fully reviewed and I actually recommended it for merging,
because from a clerical perspective, it fulfills all the requirements set out in
BIP2.  I still have no opinion on whether it should be merged -- sorry, it
should be merged to the BIPs repository, absolutely, so we can just continue
talking about it.  I am not sure whether we should deploy it, I have no opinion
on that.

**Mike Schmidt**: Tadge, I roped you into the second news item, and I appreciate
you hanging out with us, but if you have other things to do, obviously we
understand and you're free to go.

**Tadge Dryja**: Yeah, I'm okay, I blocked out an hour.  So, I can stay, or if
there's other stuff going on, I can hang out.

**Mike Schmidt**: All right, yeah, great, it'd be great to have you.

**Mark Erhardt**: Did you have more to say on OP_CAT?

**Tadge Dryja**: I like OP_CAT.  I mean, I think it's amazing how much you can
do with just these one or two tiny opcodes that used to be in Bitcoin and then
got disabled for seemingly different reasons.  And so people are also thinking,
maybe you can do this stuff without any new opcodes; maybe there are
constructions where we need so little that maybe we can get away to get
something like OP_CAT without a new opcode.  But it does seem that if you do
construct all these useful things, you might as well put in OP_CAT.  And I think
similarly, if someone's trying to make Lamport signatures in OP_CAT, then it's
also like, well, if there's a real desire for Lamport signatures, could we have
an opcode for that?  Then it would probably be more efficient and easier and
secure, and so on.  So, it's always the tension between, okay, we want a very
general thing that people can use to do whatever they want, and then also the
specific, well if they're all doing a few certain things, it's a lot better to
optimize for those things.

So, I think it's cool to see OP_CAT testing, but then if you end up seeing only
one or two useful things with it, maybe you actually propose that as what you
make the change to.

**Mark Erhardt**: Yeah, I was also going to jump in on this tension between
being able to build a lot of stuff with these tiny new opcodes, but it being
extremely convoluted and inefficient.  Defining your own Lamport signature
scheme in script would surely be in a very large script, I would assume.
Similarly, if you want to do a merkle tree verification, I mean there's no
recursion in script, so you'd have to know how deep it is and things like that
probably in advance.  So, you could do it, but it would just be painful.  So, if
we want to do stuff like that, it would be maybe better to add the specific use
cases.  I mean, you could still put in OP_CAT, but then have specific opcodes
for the general or the specific applications that people want to generally do.
Yeah, anyway, I agree with you!

_Arrests of Bitcoin developers_

**Mike Schmidt**: Next news item, Arrests of Bitcoin developers.  So, it's a bit
of a non-technical thing that we've included in the newsletter, but we thought
it was important to flag for everybody, although I think probably most people
have heard of some of these news items: the two developers of Samourai wallet
being arrested last week for their involvement in developing the software, and
other accusations; also, I think we mentioned two companies announcing their
intention to stop serving US customers.  I think it was Phoenix wallet announced
that, I don't recall who the other one was.

**Mark Erhardt**: Wasabi.

**Mike Schmidt**: Wasabi as well.  And then, I think the FBI put out a sort of
concerning letter about self-custody and the dangers of that, and it could be
confiscated and all kinds of things.  And I think there's even more of this sort
of activity going on in the last few days.  So, slightly concerning to those of
us in the space.  Murch, I have a couple resources I'll point folks to in a
second, but do you have any top-level thoughts here?

**Mark Erhardt**: Well, obviously it's never nice to see people that work in a
similar job as your own getting arrested for seemingly non-correct reasons.  I
mean, one of the main points in this indictment appears to be that they were
acting as a money transmitter, which seems to be in contradiction to the FinCEN
guidance of years before, where having a self-custodial wallet that you just
write the software for does not make you a custodian or money transmitter,
because it's the user themselves that holds their own money.  And so, that sort
of stuff feels a little concerning, especially since I think a lot of us are
working on software that enables, in this broader definition of money
transmission, money transmissions, and that is just, yeah, definitely something
that I think a lot of us are having an eye on.

On the other hand, if they do have evidence that it was used to launder money
specifically, I think that probably they'll be able to get a jury of peers to
make that stick, and that's maybe another part that's a bit concerning.  How do
you explain the nuances of open-source development and whether or not something
is actually custodial, what level of control the developer has over the
installations of the users, and so forth, to a jury of your peers that is picked
from the broader population?  I feel like there is a good chance that just the
technical acumen of such a jury would make them susceptible to finding an
incorrect decision, in my opinion.  So, I don't know, I think we're all watching
what's happening here.  I've seen that Coin Center and some others have started
commenting on this, and I'm sure there's some fundraising and trying to provide
legal support.

So, if you're in a position to allocate money towards that sort of thing, I
think we kind of are in a new cycle of essentially the crypto wars.  We've seen
a lot of privacy encroachment in the last few months.  Well, Congress recently
extended the surveillance from Patriot Act and not only extended it in time, but
also in scope.  In Europe, there's a lot of attempts to get chat privacy down to
basically backdoor all encrypted chat devices, applications I should say.  So
all together, I don't really love the trend.  I hope that we could get some good
news in this arena at some point.

**Mike Schmidt**: You mentioned Coin Center.  I was hoping we can get somebody
from Coin Center on to chat with us about this news item today, but that fell
through.  However, I would point folks to two different resources on this topic
from them.  The first one was a recent blog post from Coin Center titled, DOJ's
New Stance on Crypto Wallets is a Threat to Liberty and the Rule of Law, which
addresses some of the discussion topics that we brought up today so far.  And
then second, Coin Center's Peter Van Valkenburgh was on a Twitter Space with the
Casa folks speaking about some of these issues.  So, if you're curious more
about the legal details from someone who has a legal background, check out those
resources.  Murch or Tadge, anything else on this item?

**Tadge Dryja**: Yeah, I mean, privacy work is really important, and it's also
hard to get funded, and a lot of people don't want to work on it because of
things like this.  I think this case is one where it's hopefully going to end up
being, even if they do end up getting in a lot of trouble, it's hopefully not
for just writing the software, it's for some other things they've done or said.
Hopefully, that's what ends up sticking, but rather than, "Oh, yeah, if you
write any kind of open-source software that deals with money, you're responsible
for what everyone does with that money".  Then, all Bitcoin development
basically has to be anonymous at that point.  And so hopefully that's not at all
what happens, but yeah, definitely something to keep track of.

_CoreDev.tech Berlin event_

**Mike Schmidt**: Last news item this week was about the Bitcoin CoreDev event
in Berlin.  Many Bitcoin Core contributors met in person for a CoreDev.tech
event last month, and there were several transcripts from some of the sessions
that some of the attendees provided transcripts for.  And then, we also listed
out, in addition to, or including those presentations, there were code reviews
or working groups or other sessions at the event, and then we listed out all the
different topics that had at least some formal session during the event.  Murch,
this seems like a pretty good list.  It seems like what you would want your
Bitcoin Core developers to be discussing and working on; what do you think?

**Mark Erhardt**: I thought it was a good event.  I don't know how many people
work in a similar situation as us, but if you just encounter people in text all
day long, it's sometimes hard to get a sense for who they are as people and to
build up this just charitable interpretation of everything they say.  And these
meetings, these in-person meetings are important to just meet these people,
build rapport, and the speech bandwidth is just so much higher than when people
are interacting on PRs where they might -- I mean, everybody has a lot to do, so
it might be a few days until someone gets back.  Being able to just discuss an
idea with all the people in the room for half an hour can be months' worth of
online discussion.  So, it's usually very productive and just great for building
out the relationships between the developers, so I always enjoy going to these.
I think we made good progress on a lot.  I think we also just understand better
where most of the people in the project stand topics and that helps where to
allocate time and how to deal with certain demands that come from the outside to
the group or, yeah, all together, five out of seven full score, would go again.

_Bitcoin Inquisition 25.2_

**Mike Schmidt**: Releases and release candidates.  First one is Bitcoin
Inquisition 25.2, which I think we somewhat referenced earlier in the discussion
about OP_CAT being activated on signet.  A couple of changes with this Bitcoin
Inquisition version.  The first one involves the use of BINANA numbers rather
than BIP numbers.  I think we had talked with AJ at some point about this, but
to quote the motivation from AJ, "BIP number assignment is acting as a
bottleneck, so route around it by creating our own Bitcoin Inquisition Numbers
And Names Authority and use that for heretical deployments".  So, Bitcoin
Inquisition is now referencing proposals using their BINANA number instead of
the BIP number.  Hopefully, Murch can continue to make that bottleneck not a
bottleneck anymore, but I guess by the time that that's happened, AJ's already
routed around it with BINANA.  And notably, maybe the headline here is that
Inquisition re-enables the OP_CAT opcode that we talked about earlier, and also
then patches a bunch of things from Bitcoin Core 25.2 onto Bitcoin Inquisition.
Tadge or Mirch, anything to say here?

**Mark Erhardt**: Yeah, I think it's a good thing that the BINANA repository
moves so quickly.  It's my understanding you basically just have to write up
something that looks sufficiently comprehensive and you'll get your number
almost instantly.  I think that overall, that should be what the process should
be more like.  I think the BIP repository should not be much of a bottleneck.
Clearly we should have some standards on what we accept just in quality, but
other than that, things should get numbers very quickly.  They're just ideas,
though.  The idea is to have a central place and document to reference so that
all of our distributed conversations about BIPs where, I don't know, people meet
in person and talk about it, or at a meetup or in an IRC or video chat or on
Twitter, being able to reference one single document and being sure that you're
all talking about the same technical details is extremely valuable for this
distributed conversation to ever get to any end.

So, well, we've only assigned three numbers in the last week, we've merged one
proposal to the repository.  Clearly, we had some catching up to do.  We're
down, I think, almost 90 PR have been processed, either closed or merged.  So,
now there's still the non-low-hanging fruit, so we need to catch up on the
actual written-up BIP proposals.  We've provided some feedback already.  There's
a few that look almost ready to be merged, and then I hope that in the future,
with so many more people on it now, it'll be back down to a few weeks of someone
opening a high-quality PR and it getting merged and having a number and just
being able to be discussed based on a clear reference.  And that's really the
purpose, right?

**Mike Schmidt**: Tadge, are you a Bitcoin Inquisitionoor?

**Tadge Dryja**: Yeah, I think it's great.  Run a node of Inquisition.  People
have sort of said attacks only make Bitcoin stronger, and I'm somewhat skeptical
of that stance in many cases, but in this case it's like, yes, if you want to
attack stuff, attack OP_CAT.  Start running Bitcoin Inquisition nodes, see if
you can make weird, bad things happen to the signet network and ruin things.
That's extremely valuable for us to know, because that's sort of the whole
purpose of these testing networks.  And so, anyone who wants to try out rekking
Bitcoin, this is the best chance to do it because it's quite possible there is
something that could go wrong with OP_CAT.  And so, try it out and try to break
it.

_LND v0.18.0-beta.rc1_

**Mike Schmidt**: Next release this week is LND v0.18.0-beta.rc1, and this
release accounted about two dozen bug fixes that were in there; and also
feature-wise, there's a bunch of things like inbound routing fees, taproot
watchtowers, and some other things that we've covered in the newsletter over the
last few months.  But maybe instead of getting into each feature, Murch, it
might make sense to have someone from LND on when 0.18 or 0.18-beta is actually
released?  Okay, seems like you agree.  So, that's a little teaser, I guess, for
you all, but we'll hope to get somebody on from LND when this is ready to go,
because there were quite a bit of bug fixes, quite a bit of features.

_Bitcoin Core #27679_

Notable code and documentation changes.  Bitcoin Core #27679, which allows ZMQ
messages to be sent using Unix domain sockets, in addition to over TCP.  ZMQ is
a way that's existed in Bitcoin for quite some time for custom applications to
get notifications when certain events happen in Bitcoin Core, so for example a
new block, and then the custom application can handle that information itself,
whatever it wants to do with that information.  And we talked about this a few
episodes ago, but Unix sockets can be faster than TCP ports.  And we talked
about that, I guess it was in Podcast #294, when this Unix domain socket support
was added as an option specifically for communicating with Tor with respect to
that PR, and now we're talking about doing it with ZMQ.

Now, the funny thing with this PR is that ZMQ support for Unix domain sockets
already existed.  It was undocumented and potentially unintentional previously,
but it was possible and the LND folks actually used that undocumented ZMQ Unix
domain socket feature for quite some time, but then Bitcoin Core implemented
more strict option parsing logic in 27.0 and that borked LND.  So, now this PR
essentially turns that feature back on.  Murch, what would you add to that?

**Mark Erhardt**: I know nothing about Unix sockets, I'm afraid.  But yeah, if
you ever were in the position that you wanted to know what your node was doing
and you solved that problem by polling regular on some RPCs to see if the state
had changed, there's an actual interface that will dispatch an alert when events
happen, and that is way more convenient.  So, maybe look into ZMQ in that case.
And the other way of doing something like that well would be, we have USDT in
Bitcoin Core, and that's not anything that has something to do with Tether.
It's the user-space-defined trace points, and if you compile those into your
Bitcoin node, you can get specific parts of the code base to directly push
information, log information to, I think, operating system level logging.  And
then you can read out, for example, coin selection results and stuff like that,
which is very convenient if you're developing stuff around Bitcoin Core.  So,
yeah.  Okay, that's all I got!

_Core Lightning #7240_

**Mike Schmidt**: Core Lightning #7240, which adds a feature for Core Lightning
(CLN) to be able to fetch a block from a peer if CLN's local Bitcoin node
doesn't have it.  Why might the Bitcoin node not have it?  Well, for example, if
you're running Bitcoin Core and it's running in pruned mode, you might not have
that block.  And a quote from the PR, "This is something that happens when CLN
tries to fetch a block from bitcoind that has already been pruned by bitcoind".
It usually doesn't take long until CLN asks bitcoind for blocks that have
already been pruned.  In this case, CLN just retries to get the block every
second without success, so that seems like a bad thing to happen.  Maybe we have
a Lightning, former Lightning person?  Tadge, why would you need like an old
block in lightning; what's that for?

**Tadge Dryja**: Probably, there's a bunch of reasons, but I don't know the
specifics of why CLN is doing this, but I guess for gossip messages.  If you're
syncing up, someone saying, "Okay, this channel exists", the gossip messages can
sometimes trail the actual transactions by quite a bit.  And so, if someone's
saying, "Hey, this new channel exists, so update your graph to reflect that
here's a new connection", you might have to go back to a block that you saw a
day ago or something, and be like, "Okay, yeah, that's the transaction", to make
sure it's confirmed.

**Mike Schmidt**: Okay, yeah, that makes sense.

**Tadge Dryja**: There's other reasons, but that's the most likely one, because
most other things are happening in real time, but that can happen with a pretty
significant delay.

**Mike Schmidt**: There was a mention that I think LND was doing something
similar, so I don't think it's CLN being too crazy here, but I did not
understand the motivation myself, so thanks for explaining that.

**Tadge Dryja**: Yeah, and that whole thing is also something people are talking
about changing.  Because right now, when you say, "Here's a channel I have on
the LN", you point to the actual UTXO, right, you give the txid and stuff.  But
it'd be better if you didn't have to, and you could just say, "Look, there is a
channel, and you can use it, but I don't have to show you where it is onchain",
because it's a huge privacy loss.  But really, the only reason it's there is for
anti-DoS.  So, there's a bunch of proposals now about how to still have anti-DoS
without pointing and losing your privacy by showing the actual UTXO.  So, yeah.

**Mike Schmidt**: Is that the gossip 1.5, 1.75, 2.0 kind of stuff?

**Tadge Dryja**: Yeah.

**Mike Schmidt**: Okay.

**Tadge Dryja**: And that stuff related to this possibly, but I think you'll
still end up having some of these requirements.  But it might change.

**Mark Erhardt**: Yeah, this is especially interesting in the future move to
P2TR-based channel or funding transactions.  So, when we have P2TR outputs that
present channels, they would no longer be clearly visible as being 2-of-2
multisig.  So, if we didn't have to point at them to announce a channel, we
would be able to essentially use LN channels without ever anyone noticing that
they were LN onchain, except if they get closed unilaterally.  And so, yeah,
right now, this is pretty visible anyway because 2-of-2 is not used that much
outside of Lightning.  Chances are, if you see a 2-of-2 transaction, it is just,
yeah, the greatest likelihood is that it's Lightning.  But we also point out
which UTXOs created channels, so those are some longstanding privacy concerns
that people have been working on.

_Eclair #2851_

Eclair #2851 begins depending on Bitcoin Core 26.1 or greater, and removes code
for ancestor-aware funding.  Murch, I punted this one to you because I think as
I was clicking around familiarizing myself, one of your PRs was one of the
underlying discussion points here, so do you care to summarize this one?

**Mark Erhardt**: Yeah, we got last year support for when you build a
transaction that has an unconfirmed parent, so you're spending a transaction
output of an unconfirmed transaction with a lower feerate, then Bitcoin Core
used to treat it like any other UTXO and not allocate any extra funds to bump
the parent.  So if, for example, your parent transaction had significantly lower
feerate, it would mean that your transaction actually didn't queue at the
nominal feerate, but at the ancestor set feerate, where the parent basically
pulled it down and would potentially cause it to get confirmed way later.  So,
we changed that in Bitcoin Core that if you do use an unconfirmed input and you
want a transaction at a certain feerate, not only will it create the new
transaction at that feerate, but it will also pay the fee deficit that you need
to add to the parent transaction in order to achieve a feerate with the whole
package at the demanded feerate.

So, there had been a problem for anyone that was using unconfirmed inputs
before.  So, Lightning, some services that created withdrawal chains or
generally chain transactions, and in Bitcoin Core, this gets solved
automatically now, and it looks to me like Eclair is now choosing the support in
Bitcoin Core over their own custom implementation and just relies on our
software.  So, I hope it's all great!

_LND #8147, #8422, #8423, #8148, #8667 and #8674_

**Mike Schmidt**: Thanks, Murch.  There's a flurry of PRs that we covered here
under one bullet, LND #8147, #8422, I'm not going to list the other ones.  But
this slew of PRs improves LND's sweep functionality.  So, in LND, there's a
sweep service that mainly handles two different scenarios in LND, most commonly
sweeping back outputs from a forced close transaction to the wallet; and the
second scenario that the sweep service is activated is when it's being used
because a user has called bump fee, and fed a new unconfirmed input to be
handled by the sweep service.  So, there's these two scenarios where the sweep
service is used in LND, and we noted in the newsletter that there is a new
implementation that LND has pushed out using these PRs, also adding a budget
field that is the max amount to pay in fees.

The PR noted that, "In order to sweep economically, the sweeper needs to
understand the time sensitivity and max fees that can be used when sweeping
funds.  This means that each input must come with a deadline and a fee budget,
which can be set via the RPC request or the config, otherwise the default values
will be used".  So, that's from the documentation.  And actually, one of these
PRs has a bunch of documentation on this particular sweep service.  There's
actually a sweep/README file as part of these PRs, which documents LND's sweep
subservice to a much greater detail than I've gotten into here.  Cool.

_LND #8627_

We have one more LND PR, LND #8627, which now defaults to rejecting
user-requested changes to channel settings that require above-zero inbound
forwarding fees.  So, in order for LND nodes to remain compatible with nodes
that don't support inbound forwarding fees, LND now rejects positive inbound
fees by default.  And the user can override that default with the
accept-positive-inbound-fees option.  We spoke about support being added to LND
for inbound routing fees in Podcast and Newsletter #297, and we even had Joost
on Podcast #297, who was the author of the inbound routing fees feature.  So, if
you're curious about the details of inbound routing, you can listen back for his
explanation there.  And it sounds like they're flipping a default now in LND for
that to be off.  Murch or Tadge, anything to elaborate there?  I feel like I
could probably dive deeper, but I'm less familiar with this than I would like to
be to do so.

**Mark Erhardt**: Yeah, I was staring a little bit earlier at this, and I hadn't
heard about it.  And I realize now that three weeks ago you, and Dave did the
show, so that's probably why I didn't hear much about it.  So, my understanding
is that usually you only charge a fee on what you forward.  And the way it looks
is, let's say you're Bob, you receive a forwarding request from Alice, you're
supposed to forward it to Carol.  And then on your channel, your Bob-to-Carol
channel, you get to charge a fee on what you forwarded.  So, only the step where
you act as the hop that forwards on the outbound, you usually are allowed to
collect fees.  For example, that means when Bob pays Carol directly, Bob doesn't
charge a fee on himself, because that doesn't make sense.

Now, the idea I think behind the push for inbound fees is, (a) let's say your
channel with Alice, as Bob again, is very skewed and traffic always comes more
in one direction than in the other, it might matter more to you on which channel
the forward arrives rather than what channel you send it on towards.  So, there
had previously been no way of you, as the recipient side of that channel, to
charge a fee, like you can only charge fees in the direction Bob to Alice, but
you'd really want to be able to have financial incentive, incentivize traffic
financially from Alice towards Bob, because it skews your traffic in some way.
So, the idea here is instead of only being able to charge when you forward on
the outbound channel, you can also charge a fee on the inbound channel.  So, you
could set a setting when a multi-hub payment comes through the Alice-to-Bob
channel, you'd have an inbound fee on it too.  Now, you could have different
inbound fees on different channels and different outbound fees on different
channels.  That gives you a lot more control on the financial incentives to
shape traffic.

My understanding is that this is pretty contentious and most Lightning
developers oppose inbound fees.  So, that's what I've been picking up in the
reading up on this earlier today.  Tadge?

**Tadge Dryja**: Yeah, I mean is something contentious in Lightning development?
No, really?!  So, yeah, that's a great explanation.  I think it's somewhat
contentious.  My take is, I don't think it's bad, I think this adds a lot of
complexity for maybe not that much utility.  Can't you do this a simpler way, or
do we really need these, I think, are some of the arguments about it.  And I
sort of agree that in many cases, you don't need this; there may be some cases
that do benefit from it.  So, that may end up what happens, where there are some
nodes that are in situations where they want to be able to say, "Well, yeah, I
care about the input, the channel it's coming in on becoming more unbalanced
than the channel it's going out on.  So, I want to do these fees", and you can
get some compatibility there.  But I wouldn't be surprised if some
implementations or some nodes that people use don't really support these things,
just because the people don't want to bother implementing it.

I mean, I can sort of diverge a little.  While this is somewhat controversial, I
think the real controversial one is going to be the failure fees.  Because
inbound fees, you can sort of say it's similar.  It's mainly the opposition
that's just like, "It's kind of complicated".  But failure-based fees, I think
it's an interesting idea.  I think it maybe might be necessary in the future.
But that's the idea that, well, right now, you pay fees when your payment
actually gets through.  But there's also ideas of, well, maybe you should pay a
fee even if it doesn't, even if it fails.  And I think there's a lot of
interesting things going on with fees.  They're all kind of a mess, and yes,
it's controversial.  But yeah, I think people will start trying to use this, but
I don't know, we'll see if it really gets broad adoption.

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: Yeah, I was considering jumping in on the routing fees, and I
think one of the concerns with that is, of course, the possibility of jamming,
and especially fast jamming.  So, whenever you build up a multi-hop payment, you
lock up funds, right, or people stage them for the HTLCs and they can't use
those funds for other things.  It also blocks slots on channels.  So, if there's
someone that builds up tons of channels and then fails them by attaching a
message in the end that doesn't go through, or paying themselves and then just
waiting for the timeout, and just before the timeout not actually finalizing the
payment and letting it just unravel again, this sort of behavior, we're not
seeing a ton of that.  It would be a way of generally decreasing the UX and
quality of the network for other users, and this is why people are considering
these routing fees.  And then I think these would be magnitude smaller than fees
on successful routing, and I think a lot of the anger could be managed easily by
making it a better UX.

If you just overestimate a little bit the fees that a payment will eventually
pay and use the gap between the final actual fee as a budget to make a few
routing attempts and pay those routing fees, I don't think that users would even
notice.  Like if you just say, "Okay, probably this is going to cost 30 sats.
Let's say 50 sats, and we'll probably need three or four attempts, and each of
those will be 1 or 2 sats, and eventually, your estimated fee was 50 sats, you
pay 34, user's happy because he got it cheaper than the initial estimate.  I
think with the right UX and messaging around it, I don't think that it'll blow
up that hard.

**Mike Schmidt**: Any comments, Tadge?

**Tadge Dryja**: Yeah, I think if we can get it to be UX-easy and people don't
complain about it, then that's good.  Because, from the beginning, I've sort of
thought of fees as weird and kind of backwards on Lightning, where the real
thing you want to discourage is a stock payment, where whether it's intentional
or, you know, almost all the things that happen that go wrong in Lightning are
because of bugs or things being set up wrong, and it's very little malicious
use.  But you can't tell when you see something get stuck, is it malicious or is
it just a bug?  And those can be pretty disruptive where you might have a script
or software, and then you're like, "I have 100 HTLCs stuck in this channel, and
everything's unusable".  And that can also be unusable for a bunch of other
people, and you want that to be discouraged.

So really, because right now with fees in Lightning, you're paying when things
work, and that's sort of backwards, because really you should be paying sort of
a fee when you screw up and make things not work for other people.  But
definitely, I think the idea of routing fees or failure fees makes a lot of
sense, but yeah, it is also potentially opening up another thing where it's bad
UX where someone's like, "Hey, I tried to pay, and it charged me 5 sats, and it
didn't even work.  And so, where did my money go?"  That sounds really bad, but
hopefully it can be like a really small amount that doesn't -- and hopefully,
the end result is that routing works even better, so you very rarely see failure
fees.  So, that would be the ideal case.

**Mike Schmidt**: Right, I just wanted to jump in.  Absolutely, the big problem
is stuck transactions.  And the worst case of those is when you're trying to pay
and it gets stuck somewhere, and you sort of have a Schrödinger payment; it
neither went through, nor did it properly fail, and you can't repeat the payment
unless you risk to pay twice.  So, yeah.

**Tadge Dryja**: Yeah, it's a mess, and it happens.  It happens from bugs
sometimes, but also it would be very easy for someone to do this maliciously.
None of the nodes support doing this on purpose, but it's like a trivial change
to be like, "Here, I'm going to do this".  And then you could annoy a lot of
people.  It doesn't steal their money exactly, but the time value of that
channel, it does really impede it.  So, this would be something to fix.

**Mark Erhardt**: I think the recipient could use an invoice twice, right?  So,
they could literally collect a payment twice.  Can you clarify that?

**Tadge Dryja**: Yeah, you don't want to double send.  If they have the same
payment with the same payment hash coming in on two channels, they can sort of
take both at the same time, potentially.  So, you don't want to be sending
duplicate HTLCs with the same payment hash on multiple channels because, yeah,
you could end up paying twice.  And then, there's other techniques to mitigate
that, like multipart payments and stuff.  But for a regular payment, you don't
want to send it twice.

**Mark Erhardt**: Yeah, and stuckless, I think, where you sort of send only part
of the secret, and only after the endpoint asks back, you give them the rest.

**Tadge Dryja**: Right, so there's ways around that, too.  But fundamentally,
those all help when the two ends are cooperating and helping, but things can get
stuck in the middle and you just have no way around it, really.

**Mike Schmidt**: I'll take the opportunity to solicit any questions you may
have for Murch, myself, or Tadge about the newsletter.  We have three more PRs.

_Libsecp256k1 #1058_

Next one is Libsecp256k1 #1058.  I will assume the role of golden retriever in
front of the keyboard to summarize this one.  It changes the algorithm used for
generating public keys and signatures to be constant time, in order to avoid
side-channel attacks.  The PR was opened in 2021, and this was actually the
third attempt at reworking this algorithm, it looks like.  And in addition to
avoiding side-channel attacks, this new algorithm also is 12% faster.  And we
also, in the newsletter, link to a galaxy-brain post from Stratospher about her
thoughts after reviewing the PR, if you want to jump into some of the
interesting details here.  Murch or Tadge?

**Mark Erhardt**: I am not sure if I heard that right, but both the original and
the new implementation are constant time.  We generally want all the
cryptographic operations to be constant time, because non-constant time elliptic
curve stuff could potentially be a side-channel vulnerability that leaks keys or
other secret information about the wallet state or signer state.

**Mike Schmidt**: That's right, you're right.  If I stated that, that was
incorrect.  Yeah, both are constant time, and the new one is 12% faster.

**Tadge Dryja**: So, is that really constant time?  It just got faster?  No, I'm
just kidding!

**Mike Schmidt**: Well, it's consistently faster.

**Mark Erhardt**: Consistently faster for any.  I think the funny thing about
this one is this PR is the third attempt by Peter Dettman, and I think the first
and second ones were started in, when is this, 2018 and 2019.  So, if you're of
the opinion that Bitcoin Core is sometimes slow, Libsecp can be even slower;
this was five years in the making!

_BIPs #1382_

**Mike Schmidt**: Next PR to the BIPs repository, #1382, assigning BIP331 to
package relay.  I believe we've been referencing BIP331 for a while since it was
tentatively assigned to 331 back in 2022, but I guess that was in a PR that
wasn't officially merged until recently.  Murch, this appears to be merged as
part of the new BIP editors beginning their work.  Maybe it's a good opportunity
to see how it's been going for you.  It sounds like you spent a lot of time
reviewing BIPs over the last few weeks and it seems like things are moving
along.  So, good overall?

**Mark Erhardt**: Yeah, I want to actually clarify that news item.  So, the
number was assigned in 2022.  It recently got merged last week into the BIPs
repository.  So, this is the logic, the new P2P messages to announce the relay
of packages.  Rather than just sending a single transaction, this provides new
P2P messages, or specs them, to say, "Hey, I not only want to send you one
transaction, I want to send you multiple related transactions as a package".
So, yeah, the number was assigned in 2022, and I think it's been ready for merge
for at least a year or so, and now it's merged.

_BIPs #1068_

**Mike Schmidt**: Thanks for clarifying, Murch.  Last PR, BIPs #1068, which is
simply a change to BIP47, which swaps two parameters in the reusable payments
code BIP, and this was to match an implementation in Samourai Wallet, which I
think is the major implementer of BIP47, so fairly minor thing.  Took a while to
get merged, but glad we got there.

**Mark Erhardt**: Yeah, I merged that.  So, this is a little bit of a funny PR
to the BIPs repository.  This was opened by Justus Ranvier, or I don't know how
they prefer to pronounce that name.  It was opened in 2021.  This is the author
of BIP47 setting BIP47 to final.  It has been implemented by at least three
different wallets, so this is appropriate.  And since it's the author changing
their own document in one minor detail to match the actual implementation that
is being used by all of these three implementations, this is very appropriate.
And I don't know exactly why it took three years, but as part of our new BIP
editor roles, this got another look and just got merged.

**Mike Schmidt**: I don't see any questions or requests for speaker access, so I
think we can wrap up.  Tadge, thanks for joining us this week and sticking on.
It's always great to have a Lightning person because Murch and I can sometimes
stumble through some of that, so thanks for hanging on with us.  And, Murch,
thanks always as my co-host, and thanks for all the listeners this week.  See
you and hear you next week.  Cheers.

**Mark Erhardt**: Cheers, hear you next week.

**Tadge Dryja**: Cheers, yeah, thanks, bye.

{% include references.md %}
