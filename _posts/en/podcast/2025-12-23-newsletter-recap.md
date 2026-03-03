---
title: 'Bitcoin Optech Newsletter #385 Recap Podcast'
permalink: /en/podcast/2025/12/23/
reference: /en/newsletters/2025/12/19/
name: 2025-12-23-recap
slug: 2025-12-23-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Bastien Teinturier, Rearden
Code, and Pieter Wuille to discuss [Newsletter #385: 2025 Year-in-Review
Special]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-11-24/414965325-44100-2-bdd568ae0e465.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #385.  This is
our 2025 year-in-review special.  It's going to be a little different, since
it's this year-in-review, from our normal weekly newsletters.  One, it's going
to be a bit longer, and two, we're going to go quite a bit out of order.  We
have a few guests that are going to be joining us on different categories of
topics, and so we figured it made more sense to chunk those topics together than
it did to go month-by-month through the entire year.  So, we're going to jump
right into it.

We have a guest with us now for the first segment.  We're going to talk about
Lightning stuff, and who better to have than t-bast.  Bastien, you want to say
hi?

**Bastien Teinturier**: Hi, I'm glad to be here.

_LN ephemeral anchor scripts_

**Mike Schmidt**: We pulled out a handful of Lightning-related items that we
covered in the year-in-review but, t-bast, I think you had a perspective of
maybe walking listeners through your maybe more holistic than the items that we
happened to highlight perspective on Lightning in 2025, and we can obviously
touch on the items from the year-in-review as well.  So, how should folks be
thinking about Lightning?  How are you thinking about Lightning?

**Bastien Teinturier**: Yeah, so people may not have noticed it because a lot of
things are things that we have been working on for years, for many years.  But
what I've found really interesting with 2025 is that it really feels like the
end of a cycle of features that we've been developing for a very long time.  And
a lot of those things that people have been hearing about for years, like
splicing, taproot, v3 transactions, are things that have come into production in
2025, or are just waiting for minor cross-compatibility things before they
actually get merged to the spec and get into production for everyone.  So, this
is really a lot of stuff that required a lot of work, many years of work, but
all of those things are basically finalized.  So, I find it really interesting
because it looks like we haven't made a lot of progress, because those are
things that we were already talking about years ago, but years ago we were
talking about with just a vague spec.  Then, we started implementing them.
Then, it gave a lot of feedback to the spec and the spec changed a lot.  Then,
we ended up with a spec that was almost final, but we needed multiple
implementations to actually implement it.  And we are at that point here for
many things.

So, it really feels like we've done mostly a lot of very complex changes to the
channel transactions and structure with taproot and v3.  And it looks like for
2026, the only next feature, next wave of improvement, is going to be combining
v3 and taproot.  And once we get to that spec and to this being implemented,
we're going to have reached a point where we've done all the optimizations we
wanted to do in the channel transactions and basic channel construction based on
Poon-Dryja.  And then, if we want another wave of really big changes to
Lightning Channels, we're probably going to have to wait for covenants or
something that changes the game more deeply than what we can do with just that
kind of improvements.  Go ahead, Murch, if you have a question.

**Mark Erhardt**: Yeah, I do.  So, one of the interesting things that had been
floating around was that we wanted to get away from announcing the channels
based on the funding output.  I know that there was some talk about Gossip 1.75
getting close to shipping.  If I'm jumping ahead, tell me, if we're going to get
into that later, but isn't that one of the things that is still outstanding, not
announcing the outputs?

**Bastien Teinturier**: Yeah, this one is really outstanding and hasn't
progressed that much in 2025, I think.  We've rather focused on getting the
taproot channels shipped and seeing what we could embed in the gossip changes
for taproot that are part of taproot 1.75, but I don't think we have concrete
plans to really work on implementation for not announcing the channels yet.
This is probably something that people are going to work on in 2026.  But there
are still some unknowns on that one, and that's why it hasn't made that much
progress in 2025, in my opinion.

**Mark Erhardt**: Yeah, so, okay.  So, we're still basically missing the
construction that will enable us to make sure that there's dust protection, that
people can't announce channels that don't exist and have no backing, or at least
not excessively so.

**Bastien Teinturier**: Yeah, the cryptography around that is at the point where
there are implementations of various crypto schemes that could work but are
definitely not production ready.  So, we're at a stage where we don't know if we
want to commit to one specific cryptographic scheme for that that is not
production ready, and for which we haven't written any code and have just taken
basically a protocol that is existing in the library.  So, that is the part
that's going to take some time to audit what we can actually really use and
reliably use on mainnet.

**Mark Erhardt**: Okay.  All right.  So, much for my interruption.

**Mike Schmidt**: So, folks may be familiar with taproot and v3, but maybe,
t-bast, you can outline why is that exciting specifically for Lightning?

**Bastien Teinturier**: So, v3 is mostly exciting because it is better security
for your channels, so basically it works around the carve-out mempool issues
that you potentially have for pinning that people can, in theory, steal funds
because of mempool behavior.  And moving to v3 transactions fixes that, so
better fund safety.  And taproot makes the channel construction more efficient,
because spending the channel out point is now just one schnorr signature, which
is better than the non-taproot version, which uses a 2-of-2, which is a larger
witness.  So, especially in a world where you are using splicing and you are
splicing that channel regularly, it is important to have a more efficient way of
actually spending that channel.  So, taproot does that.  And taproot also makes
sure that your onchain output is indistinguishable from any P2TR input.  So,
it's much better, even though we still announce it, as Murch highlighted.

We haven't done the public part of taproot channels yet, but in the first phase
we're still going to announce them on the network, which will be bad for
privacy, at least for public channels; but it's still really nice for private
channels, the ones you choose not to announce what every wallet is using,
because now that they are using taproot channels, that channel output is
indistinguishable onchain from any other taproot output.  So, it's a privacy
improvement and it also paves the way for all the things that LND wanted to do
with taproot assets, which only becomes possible once you have taproot channels.
And yeah, that's all.  And potentially PTLCs (Point Time Locked Channels) later,
even though I'm not sure when we're going to go down that road.

_Splicing_

**Mike Schmidt**: You touched on splicing, and that's one of the items that we
had in the year-in-review.  Where are we at today with splicing and also,
looking forward into the future, how much iteration does there need to be done
on splicing, or is it sort of more of a binary feature, like it's on and
supported?

**Bastien Teinturier**: It is completely final.  We have tested cross
compatibility between Eclair and LDK.  The only thing is that LDK does not have
RBF support yet and RBF is an important part of splicing.  But from the spec
point of view, there shouldn't be anything that changes.  And we are also
waiting for C-Lightning (CLN) to update their implementation to match the latest
spec.  But it is mostly minor things.  So, we all agree that the spec is final.
We have three implementations.  Eclair is complete; CLN only needs a few tweaks;
and LDK only needs RBF support.  And then, we're going to be able to just turn
splicing on for everyone.  LND is lagging behind on that one and doesn't have
any support for splicing yet, but Laolu says that they're going to work on it
eventually.  And once it's done, I don't think there are -- there's no splicing
v2, basically.  Once it's done, you get the full benefits of splicing, which is
that you can move liquidity around your channels more efficiently, which is
really important if we want routing nodes to be more efficient in the way they
manage their liquidity, and pay less onchain fees when they move liquidity to
somewhere that it's more needed.  And as the network grows and the payment
volume grows, it's going to be more and more important for node operators to do
that job of allocating their liquidity efficiently.  And splicing is really the
most important tool here, so that they don't have to just close channels and
reopen channels, which takes time and costs more in fees.

**Mike Schmidt**: Would you say that the end user of Lightning, the effects that
they're going to see is not necessarily that they're going to be the one doing
these splices, but that the Lightning Service Provider (LSP) that they may be
using, or the wallet they may be using, would be doing that on their behalf, and
that maybe there's improvements in liquidity and maybe the fees are a little bit
cheaper as a result, and maybe the usability is a little bit better because of
the speed?

**Bastien Teinturier**: Yeah, exactly.  And for people using Lightning on
wallets, splicing is really the thing that lets them have only one single
channel, which is way more efficient, and have their LSP automatically manage
the liquidity so that the liquidity part of Lightning just disappears from the
users and makes a much better UX, which is what we do in Phoenix.

**Mark Erhardt**: Right, basically it gets rid of half of all the transactions
you need to manage channel state, and it essentially moves you to a point where
you can start using your onchain balance as Lightning channels at the same time
without any loss, right?  Especially with MuSig coming out, it looks like
single-sig spends.  Yes, you need someone else to sign off, but if they're
always available and generally willing to assist you, you could essentially have
an onchain wallet where all of the UTXOs are Lightning channels at the same time
without any other onchain overhead.

**Bastien Teinturier**: Yeah, exactly, which is much better for wallets.

_Channel jamming mitigation simulation results and updates_

**Mike Schmidt**: All right.  That sort of covers some of the work that you guys
have been doing the last year on features that have sort of slowly been worked
on under the covers, that we've covered in PRs.  Maybe we want to talk a little
bit about some of the warts that remain in Lightning, maybe channel jamming?

**Bastien Teinturier**: Yeah, exactly.  Next, I wanted to mention that channel
jamming is a research topic that has seen a lot of progress in 2025 and
specifically this year, because this is something that we've known from the very
beginning of Lightning, that channel jamming was potentially an issue.  But we
didn't have good solutions against some channel jamming attacks.  And we spent
years basically not having a very good solution, thinking that reputation-based
systems could work, but details need to be worked out to create a reputation
system that people cannot game.  And in 2025, mostly Carla Kirk-Cohen and Clara
Shikhelman made a lot of research work on the reputation algorithms that we
could use to implement channel jamming protection.  And they reached a point
where they had an algorithm that really works well enough in many simulations
that has been audited by many contributors to try to attack it and verify that
it works, and is also quite simple to add to an existing Lightning
implementation, doesn't require huge changes on the messages, on the flows, on
the data you store.  And we're at a point where this is implemented in LDK and
in Eclair, and we're starting to collect data on real nodes to see how well it
performs in practice on mainnet and in simulations that are simulating attacks
on a big enough network.

So, it really feels like in 2025, we've validated that we have a solution that
works and channel jamming will not be an issue.  We can mitigate that kind of
attacks, which is really a great improvement.  And similarly, we've had -- yeah,
go ahead, Murch.

_LN upfront and hold fees using burnable outputs_

**Mark Erhardt**: So, the reputation is for the slow jamming, right?  And fast
jamming is the advanced fees?

**Bastien Teinturier**: Yeah, it could be addressed by having a very small fee
that for wallet nodes, would basically be hidden from you and paid by your LSP,
taken from the other fees that you normally pay with your payments.

**Mark Erhardt**: Or just the wallet shows you an overestimate of the fees if
you're not using an LSP, and then uses some of the fees for paying for the
advanced fees of multiple routing attempts.  If you pay less than it initially
said, that's usually fine from a psychological perspective!  Okay, so both of
these are ready now.  I think you only had talked about reputation just now, so
I was wondering what's the latest on the advanced fees?

**Bastien Teinturier**: Yeah, that's because reputation was the hard one,
because upfront fees are actually simple.  There are potentially a lot of ways
to do it slightly differently, but it is easy to implement and it is easy to
tune the parameters so that they work and they protect against attacks.  It's
much easier to compute what parameters you need to be safe than for reputation.
So, that's why we focused on the reputation side because it's the hard one, and
for fast jamming, the solution is quite simple.

On a related note, something that has really progressed a lot also in 2025 is
hardening implementations, doing a lot of security stuff, a lot of work by Matt
Morehouse and other contributors, to find a lot of security issues in
implementations.  And that is great because we need more of that.  There's been
a lot of fuzzing also happening mostly on the potentially less critical stuff,
like parsing of messages and invoices.  But this is a start and this is an
interesting start because fuzzing is going to be useful for security.  So, that
has been really nice to see.  And the end result is also that all
implementations have spent more time auditing their codebase themselves, and
making sure that they removed everything that looked weird or they looked at
parts of the code that they hadn't looked at for years.  So, the end result is
that all implementations are, in my opinion, much better and much more secure at
the end of 2025 than at the beginning of 2025.

**Mark Erhardt**: I think with the cross-implementation fuzzing especially,
you'd also get some benefits towards being better spec-compliant and having no
unexpected behaviors where the implementations diverge slightly, or fewer of
them, hopefully.  So, overall, not just decode bases individually, but the
interoperability of the implementations is probably improving.

**Bastien Teinturier**: Yeah, that was a good opportunity to improve the spec in
a few places where it was not clear enough, and different implementations
actually implemented different things.  So, that was another benefit as well.  I
think that there's still work.  The spec has not gotten easier because we're at
a point where we eventually want to remove all the stuff from the spec in favor
of the new ones that everyone supports, and remove the things that are not
supported anymore.  But we haven't actually decided to jump in and do that and
remove stuff, so I think that the BOLTs are more bulky than they were before,
which is not good for newcomers reading the bolts, but eventually they're going
to get smaller and they're going to get better.  And for example, moving to v3
channels means that we're able to simplify a lot of things in the spec by
removing the fact that we were previously able to update the feerate of the
commitment transaction.  And that had a lot of edge cases that we had to explain
in the spec and a lot of weird test vectors.  All of those things are going to
end up disappearing.

It will be really nice when we get to that point, because then the BOLTs will be
simpler and Lightning will actually get simpler than what it was years ago.  We
can simplify the protocol, which is a good thing.  But we're at a point where
the BOLTs are still a bit messy because it still documents the older stuff and
the new stuff.

**Mark Erhardt**: The feerate disagreements led to force closes, right?  And I
was wondering, why would they lead to forced closes and not, when both the
channel partners realized that they wouldn't agree on feerates, that they would
close together?  Was it really unilateral closes, or am I misunderstanding this?

**Bastien Teinturier**: Yeah, it was really unilateral closes, because it would
happen when one side decided that the feerate was not enough and the other side
would not want to increase it.  And then, by fear that you could not get that
commitment transaction confirmed if you needed to, you would force close, which
was really bad.  But the other alternative to not do anything was potentially
bad as well.  So, we decided to have this scorched earth strategy like that
until we got to a point where we had anchor outputs and package relay working
well enough that we could just remove that entirely.  And we're at a point where
we have removed that entirely.  And almost all of the channels on the network
are using anchor outputs and don't need that kind of force close anymore.  But
there are still a few channels that have that and we still have this in the
spec, because we want to keep documenting it for existing implementations and
older channels.  But I hope we can get rid of those, because they are really a
part of the spec that is really confusing, that creates a lot of weird edge
cases around reserve management or other kind of stuff or dust.  So, they have
been a source of nightmares over the years that we're really glad that we can
get rid of.

**Mark Erhardt**: Okay, sorry, this came up at a meetup recently and when I
thought about it, I was confused, because if both of them are talking and trying
to negotiate a fee and they disagree on the fee, they're both active.  So,
wouldn't they be able to bilaterally close the channel?

**Bastien Teinturier**: They're not both active.  It's just that you have your
commitment transaction at a given feerate.  If you are not the opener, it's not
you who can update that feerate.  It's only the opener who can decide to update
the feerate.  And you're seeing that the onchain feerate is rising steadily and
that your channel is below that.  So, you think that if the onchain feerate
keeps rising and the other guy does not update the feerate, then you're screwed,
so you decide to force close.

**Mark Erhardt**: Right. But how do you close a channel bilaterally usually,
when you don't have a feerate disagreement?  Why wouldn't you be able to use
that instead at that moment, and only force close if the other person doesn't
respond?

**Bastien Teinturier**: Okay, you're right.  No, at that point, if the other guy
is online, you could also initiate a mutual close, and you should be able to
agree on a feerate; or at least with the new closing protocols, just have one
version of a transaction that pays the feerate that you want and by having you
pay that feerate.  But, yeah, it's mostly if the other guy is offline.  It's
mostly been an issue for wallets when you have been offline, that you close
while they are offline.  It's true.

**Mark Erhardt**: Okay, I couldn't answer that question, why didn't they mutual
close at that point instead of forced closing?  Anyway, sorry, I'm sort of
taking us on a tangent here.

**Bastien Teinturier**: Mutual closing, so we've updated the closing protocol,
but not everyone supports it yet.  I think it has been shipped in Eclair, LND,
not in LDK, and I'm not sure if CLN has activated or kept it experimental for
now.  And before that protocol, there were cases where you would not agree on a
feerate when mutual closing and then you would be stuck.  And then, the only
option was to unilaterally close.  And that is something that had been happening
a lot, where mutual close, and that's one of the reasons why we changed that
closing protocol in 2025.  The other reason was that we needed one that worked
for taproot and that supported RBF.  But we had a lot of cases where you wanted
to mutual close, but you couldn't agree on a feerate, so nothing was happening
and nobody was signing, and you had to unilaterally close.  And it was a game
of, is it you who is going to unilaterally close or me?  And both nodes were
kind of watching each other, you go first, you go first.  And eventually, one
had to unilaterally close because the funds were otherwise stuck.

**Mark Erhardt**: I see.  So, what I was missing is, it would usually lead to a
mutual close, but then also the mutual close negotiation for the feerate would
fail and then people would unilaterally close.  And that was the part that I was
missing, and that's why I thought, that's really weird, why wouldn't they?
Because you actually did.  And okay, sorry.  Back to the year-in-review, maybe.

**Bastien Teinturier**: The real issue in that case that if you have initiated a
mutual close, then you mark the channel as you're not going to forewarn any
payment on that one anymore.  So, once you initiate the mutual close, you really
want the closing to be as fast as possible.  So, if you cannot agree on a
feerate and the other guy just doesn't agree with your feerate for hours, then
you're going to have to unilaterally close, because you want to eventually get
your funds back to move them to a channel where you can actually relay payments
and get fees from that.

Okay, so the other two topics, high-level topics I wanted to mention for
Lightning.  A small one is that there has been some UX improvements for wallets,
mostly because of BOLT12 being more widely adopted and human Bitcoin addresses
being also more widely adopted, which makes it more easy to pay someone to
something that is easy to remember, or at least is human-friendly.  And I hope
that this gets more adoption in the future in other wallets.  And the last
topic, which is more for 2026, just a realization of what has been slowly
happening in 2025, but is really mostly going to take place in 2026, is that
layer 2 wars are coming and it's really nice, it's really a good time that this
is happening.  For many, many years, there was basically only Lightning as a
layer 2.  Nobody was working on anything else, or at least not at a scale that
mattered where they would actually get something shipped with production-ready
code.

We've seen that two implementations of Ark have made very good progress in 2025
and are getting production-ready, and this is really interesting.  Spark also
has shipped, I think, to production.  And there are other people that are
working on L2s that are credible, that have different trade-offs than Lightning.
And I think it's a really interesting thing and it's really nice that this is
happening.  And I'm really curious to see how it will unfold in 2026 and what it
will actually change for users.

**Mike Schmidt**: I'm curious, you said war, L2 war.  But when I see the Ark
materials, they're like, "Oh yeah, we're Lightning, this is Lightning".  So, do
you see that, at least in the Ark regard, as an alliance in this war, or how do
you think about that?

**Bastien Teinturier**: Yeah, I'm not seeing this as a war at all, because the
angle is just that we have to do things that are useful.  And if things that are
useful emerge, we should not treat it as a war.  And there's no turf of, "Oh,
you're stealing my users.  I'm stealing your users".  The end goal is that we
have people that are happy and that are using the most efficient thing for what
they want to do.  So, I'm not seeing it as a war at all.  But people in Bitcoin
like to show things as wars, there are people fighting each other all the time
on Twitter.  So, I'm just calling it L2 wars, but I don't think it's really
going to be an L2 war.  It's going to be an explosion of L2 for the greater
good, hopefully.

**Brandon Black**: I don't know if you guys used Ark yet or Arkade, the test
wallet they have out there.  I use it and all I used it for was to receive
Lightning and pay Lightning, and it was frankly a great experience.  And I was
like, "Well, okay, there's a better Lightning wallet now", is really the way I
thought about it.  So, I agree with Mike's point.  I mean, it's really a great
experience and I'm glad they're out there doing it.  So, good stuff on the layer
2 front there.

**Mark Erhardt**: Yeah, I agree.  I was wondering, so there's also Cashu and
Fedimint.  Do you see any interactivity with them as well?

**Bastien Teinturier**: That's a good question, because I think it was mostly in
2024 that there was a lot of experiment around Lightning and mints and ecash.
Yeah, I haven't watched that scene a lot in 2025.  I still think ecash is
interesting, but with different trade-offs.  And yeah, I don't have a very
strong opinion on that.  I don't know.  It really is for different use cases, in
my opinion, but there could be synergies as well.  But I'm not an expert on that
at all.

**Mark Erhardt**: Yeah, I just thought if we're listing everything, that that
came to mind too.  Okay, cool.

**Mike Schmidt**: T-bast, anything else that you think folks should know about
Lightning before we wrap up the Lightning segment?

**Bastien Teinturier**: Yeah, that was all my high-level view of what happened
in 2025.  And if you want details, everything is in the year-in-review and all
the weekly newsletters.  But yeah, that was the way I wanted to describe what
this year was about for Lightning.  So, I think that's all.

**Mike Schmidt**: Thank you for joining us, Bastien.  We appreciate your time.

**Bastien Teinturier**: Thanks for having me.

**Mike Schmidt**: Cheers.  You may have heard another guest join us.  Rearden,
do you want to say hi to folks, and then we can jump into some things that you
helped author for the newsletter and year-end-review, and stuff that you have
your eye on, I know?

**Brandon Black**: Yeah.  Hi, I'm Rearden, for those who know or don't know, and
I started contributing to the Optech Newsletter this year.  And it's been a hell
of a year for Bitcoin, so excited to be on this end-of-year review.

_Summary 2025: Soft fork proposals_

**Mike Schmidt**: Awesome.  Thanks for joining us, thanks for helping author the
year-in-review.  A big chunky piece of that was some of our callouts.  We had
these callouts that sort of categorized things that maybe weren't month by
month.  One of those was soft fork proposals.  Just a small, light, soft fork
proposal callout.  Rearden, how would you approach summarizing this for
listeners?  What was 2025 all about in terms of proposals?

**Brandon Black**: Yeah, I think the high-level summary is really that it was a
really active year, probably the most active since taproot activated, really, of
new proposals and focus on old proposals.  There was just a lot of activity
around soft fork.  And I think a lot of the reason for that is probably the
reinvigorating of the BIPs repo that happened, starting about two years ago.
People realized it was alive again this year, and so people started doing stuff
with BIPs because it was alive again.  So, that's my kind of high-level summary,
is that we just saw a lot of stuff out there and new different opcodes and major
surgery type soft forks and kind of everything in between.

**Mike Schmidt**: The first category of those that you wrote up and chunked into
this segment was titled, "Transaction templates".  How do you think of
transaction templates versus just a "normal" opcode proposal?

**Brandon Black**: Yeah, so the idea of a transaction template is when we're
talking about restricting the way bitcoin is spent.  I mean, that's what most
soft forks do is they add some new restriction, because if it's not a new
restriction, then it's a hard fork.  We're making something incompatible by
relaxing the rules in some way.  So, soft forks generally restrict something.
And the category of transaction templates is kind of the way to restrict next
transactions that almost has the fewest knobs in it.  You're just trying to say,
"What is the next transaction that this UTXO can be spent in?"  And so, the two
active proposals around that are CTV (OP_CHECKTEMPLATEVERIFY) and
OP_TEMPLATEHASH, where CTV was the older proposal that applies to all script
types and restricts almost precisely the next transaction that spends some
output; and TEMPLATEHASH is the newer taproot-only version.  I shouldn't say
version, variant maybe, I don't know how to call it, that also very closely
restricts the next transaction, but really focuses on if we're only doing
taproot outputs, what are the correct restrictions for taproot outputs for the
next transaction?  And then, there's a couple of different call it packages of
opcodes that could go with those that really interoperate very well.

The one that is very commonly connected with either TEMPLATEHASH or CTV is CSFS
(OP_CHECKSIGFROMSTACK).  Because if you have CSFS in either one of those, you
can very closely duplicate the functionality of the BIP118 SIGHASH_ANYPREVOUT
(APO) proposal.  And so, there's kind of a, I'll use a buzzword, there's synergy
there, where if we do something like a transaction template along with CSFS, we
get APO functionality pretty much as well.  And so, that's kind of the rough
summary of what's going on here.  And then, in the write-up obviously, there's
some more details around the specific packagings.

**Mike Schmidt**: Makes a lot of sense.  T-bast got out just in time before I
started asking him what he thought about LN-Symmetry and some of the transaction
template proposals in terms of Lightning, but we'll let him off on that one, we
won't hunt him down for his preference there.  We also talked about the
consensus cleanup, formerly the great consensus cleanup, BIP54.  This sort of
ties in, Murch, with what we're going to talk about a little bit later in terms
of AJ Towns, his thoughts on forking, the fork guide, he did a write-up for
that.  And I know that Steve Lee and company have done some analysis on protocol
changes as well.  And it seems like consensus cleanup is, by any of those sort
of process measurements, including the somewhat tongue-in-cheek BIP-land roadmap
for a consensus change, it seems by any of those measures that consensus cleanup
is sort of moving along that track.  I don't know if Rearden or Murch, you have
thoughts on the progression or where it is?

**Mark Erhardt**: Yeah, sure.  I would say that it is striking me so far as a
fairly uncontroversial change.  People have been aware of the issues for many
years.  They are not super-pressing in the sense that most of them are pretty
hard to abuse, but if they got abused, it would be pretty bad.  And for some of
them, we would see it coming from far away and we might even be able to react,
but just fixing them and making it impossible to abuse them in the future just
seems to be a broadly-considered good idea.  It's been moving very thoroughly.
The research into each of these four things that are being fixed has been
ongoing for two years with multiple iterations of improved research results and
lots of data supporting just how bad things could get if they got abused.

So, as soft forks go, I think this is a pretty uncontroversial, but maybe also
not super-hard-demanded soft fork at this time.  So, it's been moving slowly.
I've been hearing people talk about it more often lately, and I think that's
probably the expected next step, is that people just take a better look at it.
And there might be the activation software being coded up now and it's on the
inquisition repository as a PR right now that is moving forward.  Eventually,
this will move on to the Bitcoin Core repository and I think then they'll get
another round of big review.  And given that it is so uncontroversial and it is
probably unlikely to be abused overnight, I think it's also very safe to
activate with a longer activation window, and there's no big pressure on getting
it out of the door.  So, I think it's a very thoroughly and done-right soft fork
taking its time in comparison to some other approaches lately.

**Brandon Black**: One thing I want to say about it is I've noticed some changes
to Bitcoin Core that implement the changes for consensus cleanup as policy rules
for now, which I think is, you know, we've talked a lot about policy this year
in various contexts.  And this is really where policy does great things, because
we use policy to kind of check and confirm that nobody's using this thing before
we change the consensus rules to match that.  And this is exactly how that
policy engine can be used to great effect.  And then, we can safely deploy
consensus cleanup because we know nobody's using it, because we can see that
there's not transactions violating it, being pushed to miners directly, and
they're not being pushed to the relay network, and this makes it an even safer
activation.  So, that's also a nice thing that I've seen happening.

**Mike Schmidt**: We had a segment within the segment here, just on opcode
proposals.  We sort of went through the transaction template bundles earlier,
and there's sort of these one-offs.  We have CCV (OP_CHECKCONTRACTVERIFY), aka
MATT.  How should folks think about MATT, Rearden?  I know that a lot of people
are excited about it, but a lot of people are excited about CTV and TEMPLATEHASH
as well.  So, why am I excited about CCV?

**Brandon Black**: Yeah, so CCV is a very high-level opcode in that it does one
job.  And that one job is it looks at the scriptPubKeys and restricts them in
certain ways.  And then, it has like a half a second job of doing a little bit
of amount flow within that, where you can say, if I've restricted this output,
all the value from the inputs must go to this output.  It's kind of the general
summary of that flow control that it does.  The neat thing about that is I think
it almost kind of threads an in-between between a very specific template, like
CTV or TEMPLATEHASH, and a very general opcode like TXHASH.  So, TXHASH lets you
restrict anything about a transaction, any way you want to, kind of.  And CTV is
saying, well, we don't want to open up all of this choice essentially for
developers, but we can get a lot of the useful functionality with this more
narrowly-scoped opcode that just affects, "Okay, I'm specifying that
ScriptPubKey must look like this, and the amount must flow in this way", without
picking out pieces of the transaction and kind of doing this fiddly stuff.  So,
that's what CCV does.  And yeah, it matured quite a lot this year.  I think it
got published officially into the BIPs repo?  Yeah.  And so, it's out there.

**Mike Schmidt**: Yeah, BIP443.

**Brandon Black**: Yeah, BIP443.  So, I'm really excited about that one.  And
the biggest thing that it enables, which bitcoiners have requested in various
ways for a very long time, okay, the biggest thing to me, Salvatoshi would
disagree as to what the most important thing is probably, but to me, the most
important thing that it enables is the ability to do reactive security, where
because you can restrict next ScriptPubKeys, you can have what's called a
vaulting construct.  Previously, OP_VAULT did this.  OP_VAULT was officially
replaced by CCV now, and CCV lets you do that reactive security, where when
someone tries to move this bitcoin, there's a time delay, and you can recover
that bitcoin during that time delay to a new safe place.  So, that's a super
cool feature that CCV enables.

**Mark Erhardt**: So, I have a question back.  You said that CCV can restrict
the output scripts.  My understanding is that it works by saying, money from
this input has to flow to one or more specific output scripts.  What other
restrictions around output scripts?  Am I missing something?

**Brandon Black**: Yeah.  So, you can restrict the inputs or outputs for taproot
inputs or outputs by saying it must have this data attached to it, meaning just
a hash of anything basically.  Or it must have this taptree, these scripts, or
it must have this internal key, or all of those.  And so, you can apply
different restrictions.  And depending on your use case, you might want to say,
"You must keep the same internal key flowing through, but you can change the
taptree", or, "You must keep the same data, but you can change the internal key
and the taptree".  So, there's different ways you can apply that restriction.

**Mark Erhardt**: I see, thank you.

**Mike Schmidt**: Rearden, you want to touch on Script Restoration as well?

**Brandon Black**: Yeah, great.  So, yeah, Script Restoration is this big
project that Rusty Russell first proposed in Austin at Bitcoin++ a couple of
years ago.  It's been moving forward.  He got joined by Julian256, I forget full
name there, on the project.  And they've been refining what it means to do
Script Restoration, because there's kind of two parts to Script Restoration.
There's restore what script originally had, and then there's bring script into
the modern world as well.  And so, they've refined that, they now have four BIPs
drafted, and they're working on benchmarking to make sure their numbers are all
correct for it.  And I think this really remains this great aspirational
project, where we can see how Bitcoin Script makes it harder to build Bitcoin.
Even talking with t-bast about Lightning, Lightning has had to work around
limitations in Bitcoin Script for all of its existence in order to get the
Lightning contracts the way they want them.  And if we had restored script, the
Lightning BOLT developers could really do almost whatever they want with their
Lightning scripts to get the best functionality for Lightning users.

So, I don't know like what the timeline or anything for Script Restoration would
be, but it is this great aspiration of let's make Bitcoin more useful to people
building tools for people using Bitcoin.

**Mark Erhardt**: So, what concretely does it mean to restore a script?

**Brandon Black**: So, If we look back at Bitcoin when it was first published,
the script opcodes included, OP_CAT, MULTIPLY, DIVIDE, a bunch of opcodes that
were disabled by Satoshi in that 2010 CVE, where there were a bunch of DOS
vulnerabilities that had to be closed.  I think there was an, "Oh crap", moment
for Satoshi of, "Bitcoin is getting useful and we have to make it safe".  So, at
the time, script didn't have global resource limits.  And so, any of those
opcodes that could be used to expand the resources by repeatedly using those
opcodes had to be disabled.  And so, Script Restoration says we now have a
knowledge, after running Bitcoin for a decade-and-a-half, of how to limit
resources.  And even in taproot, we basically acknowledged we know how to do
that, by switching from the sigops limit to the sigops budget.  Oh, we know how
to budget for resources now.  And so, Script Restoration acknowledges that,
says, "We can budget for these more expensive opcodes that could be repeatedly
applied to grow resource usage.  Now we can bring all the opcodes back".  Well,
we've also upgraded Bitcoin in those last several years.  We've added taproot,
we've done other things, so we need some additional features to make script be
able to do everything it could do back in 2010, under the taproot world.  And

So, that's why I think it matches the Script Restoration.  We need the new
features to interact with taproot, and we restore the functionality that it had
in the early days before they disabled those opcodes.

**Mike Schmidt**: And there's the varops piece as well, and we had Julian on
talking about that.

**Brandon Black**: Well, the varops is that new resource management, yeah.

**Mike Schmidt**: Yeah, exactly.  And so, folks are curious about that.  I think
it was last week, Murch, that we had Julian on, if not, in the last two weeks,
talking about that.

**Brandon Black**: Awesome.

**Mark Erhardt**: Okay, could you weigh in on a big controversy for me?  Great
Script Restoration or Grand Script Renaissance?

**Brandon Black**: We just called it a revival.

_Updated ChillDKG draft_

**Mike Schmidt**: We had, Rearden, segments on some other scripty things.
Obviously Rearden's doing a lot of not just soft fork proposal opining and
drafting himself, but also just looking at other ways to use script in
interesting ways.  So, some of the items from the year-in-review we pulled up
into a segment to focus on those sorts of discussions.  Maybe this first one
isn't quite in that vein, but you did author it, Rearden, which is the updated
ChillDKG draft.

**Brandon Black**: Yeah, I mean, I'm normally a huge fan of FROST and general
signature aggregation schemes for Bitcoin.  That's really, in some ways, what
drew me into working full-time on Bitcoin in the first place, was wanting to
work on MuSig stuff.  So, ChillDKG is a key generation method for FROST keys.
So, for those who maybe aren't aware, FROST is the threshold signature scheme
kind of pairing to MuSig, the multisignature scheme.  So, MuSig is always n-of-n
signing, whereas FROST can give you t-of-n signing in a distributed way.  Now,
the challenge with FROST is there's a published IETF RFC for it, but that
doesn't include a way to generate the keys separately.  It only tells you, if
you want to generate the keys in a secure location and then split them, you can
do that.  But it doesn't have a distributed generation where the whole key is
never in one place.  And so, ChillDKG is a proposal kind of specifically for
Bitcoin Frost keys, how do you generate the keys in a distributed way so that
the whole key is never in one place, it's never vulnerable potentially to an
attacker?

The thing that I think is great about ChillDKG and why I called it out in this
little, short blurb I wrote for it, is that because it's designed to work
specifically with Bitcoin, the way they designed it, when you run ChillDKG, you
get a transcript of the session.  And that session transcript is similar to a
wallet descriptor.  If you were making, let's say, a script multisig 2-of-3,
you'd get a descriptor at the end, and that's what you can back up
semi-publicly.  It's a privacy risk, but not a security risk.  And as long as
you have a threshold of keys and that descriptor for a script multisig, you can
recover your wallet.  And with ChillDKG, as long as you have the transcript from
the session from any of the key generators and a threshold of keys, you can
recover your wallet.  So, they designed this specifically to work within the
same security domain as other Bitcoin things we already do.  And I think it's
very well designed for that.  So, it's a cool project.

**Mike Schmidt**: And some folks may say, "Well, okay, so that's how you
generate the keys.  What about the signing?"  We actually talked about that.
That was in 2024, believe it or not.  The signing was actually before, due to
some of the nuance that Rearden mentioned about generating these keys, which is
why it sort of got updated later.  But if you refer back to Newsletter #315,
which is August of last year, I believe, you can see where Sivaram talks about
the signature, the signing process for that.

_Offchain DLCs_

All right, offchain DLCs and Conduition.  What's Conduition up to here, Rearden?
I thought we had offchain DLCs.

**Brandon Black**: Yeah, so this is like a new kind of offchain DLCs with
different trade-offs.  We live in Bitcoin land and cryptographic land,
everything is trade-offs.  And so, the short version of offchain DLCs is in
general, you can think of it kind of the same way we think about offchain
payments with Lightning.  You can have offchain contracts with offchain DLCs.
The previous offchain DLCs, you had to fully pre-compute every possible DLC
transition, and the only option was to proceed or resolve onchain.  With the new
method that Conduition posted, you can have a DLC factory where if all
participants are online and are able to collaborate, then you can extend the DLC
into new contracts.  So, let's say you had a DLC, you were betting on whatever,
this season's sports ball games, and the participants are still cooperative.  At
the end, you have some balance assigned to each party.  You can actually extend
it and do the next season's bets as well without ever closing onchain.  And so,
that's an example.  But the general construction here is that it's a DLC
factory, which means that as long as everyone's cooperating, you can extend it;
similar to how, as long as everyone's cooperating in a Lightning channel, you
keep making new payments.

**Mike Schmidt**: I know when we talked about DLCs in years past, there's always
this oracle piece to it.  Is that still the case?  Even though these are
offchain, you still are relying on oracle to say, "Hey, the sports ball result
was this"?

**Brandon Black**: Yeah, I mean that's fundamental to DLCs.  We'll always have
the oracle in there, and they're always going to have the trade-off where you
might want to have multiple oracles, but that blows up the size of the DLC
signature bundles significantly.  So, DLCs have their trade-offs, they have
their uses.  This is just a new way to do DLCs, but the same trade-offs
generally.

**Mark Erhardt**: Right, so the oracle thing is just because we don't actually
have information about the real world in Bitcoin, unless it is injected by some
third party.  But the nice trade-off for oracles in DLC is, other than in some
other cryptocurrencies, the oracles do not learn what they're being used for
because the keys are tweaked into the contract.  So, oracles, unless they're
informed out of band, do not have an opportunity or incentive to fudge results
to change contract outcomes, and potentially just could make it much safer and
more interesting for many things.

**Brandon Black**: Yeah, you have to be very careful that if you're entering a
DLC, you don't have a reason to suspect or for it to be incentivized for your
counterparty to conspire with the oracle.  That's kind of what you were talking
about.  The oracle should be an unbiased third party, and there's no onchain
reason they would find out what they're being used for, or anything like that.
But if there was a conspiracy between your counterparty and the oracle, they
certainly could mess with you.

_Chain code delegation_

**Mike Schmidt**: I think we can move to chain code delegation.  Rearden, what's
chain code delegation?  And I think, is it being worked into some products
already?

**Brandon Black**: Yeah, so as far as I know, this is going to be live in Bitkey
pretty soon.  And so, yeah, what it is, it's funny, it's one of these things
where it's so simple, it's surprising it wasn't done sooner once it's done.  But
no one had written about it, no one had really proposed it, and so now it's
written up and now people can do it.  And all it is, is we know when you make an
extended private key for BIP32 hierarchical deterministic wallets, there's two
parts to that.  There's the chain code and there's the public key.  That's why
it's twice the length of a plain public key, right?  Everyone knows there's
these two parts to it.  Well, this research is basically, well, if you split
those two parts up, you can have a different set of privacy and security
guarantees.  And so, the way it works is you take the chain code, and the client
who wants to use someone's signing infrastructure with privacy generates the
chain code, but doesn't tell the signer about the chain code.  The signer just
generates a plain secret key and shares the public key with the user who wants
to use that signing infrastructure.  And now, the user can potentially retain
full privacy by offering just to send tweaks, essentially, "Here, here's a
message and here's a tweak.  Sign this", to the signer.  Or they can send,
"Here's some UTXOs.  Sign for these UTXOs, and here's the tweak to sign for them
with".  And depending on which way they do it, either just a message or the
actual UTXOs to sign for, they can get different benefits from that signing
service.

So, the signing service in the blinded case is just protecting a key.  They're
kind of like a YubiKey.  They protect a key, and maybe they do a great job, but
they're not giving you any kind of wallet-level security.  But if you're willing
to give up just privacy over the UTXOs that they're going to sign, they can also
enforce policy, "You can't spend more than two bitcoin a day using our signing
infrastructure, because you tell us each UTXO you're sending", and it limits how
much they will sign for.  But they still don't know how much bitcoin you have.
They only know how much they've ever signed for.  And so, this is kind of
remarkable, actually, because previously we've always had the situation where if
you use a collaborative custody provider, they know your wallet.  And that's a
pretty big trade-off for some people.  Like if you've got 100 bitcoin, or
whatever, in a wallet, you don't want to give Swan or Unchained or Casa, or any
of these collaborative custody providers, your xpubs, and then now they know
you've got 100 bitcoin or their servers get hacked, the world knows you have 100
bitcoin.  That's a bad situation.  But with chain code delegation, now you can
still use their signing infrastructure, they can still even enforce policy, but
they don't know how much bitcoin you have.

**Mike Schmidt**: Yeah, that's great.  I know Bitkey's using it, but I feel like
sometimes, the hardware signing devices can through a wrinkle in the
understanding.  But I think folks understand like the Unchained model, and that
they know what your funds are.  And I guess partially, they could bill based on
how much they're helping you manage.  But in this scenario, they might not,
depending on what level of service they're providing and what you're providing
them, they might not even know how many coins they're securing.  So, yeah,
that's very cool.  Murch, any thoughts?

**Mark Erhardt**: Yeah, I wanted to talk about trade-offs a little more, maybe I
missed it when you said it.  But obviously, now that the two parts of the
extended public key are split up, the chain code and the main secret, and the
third-party signer or the service provider doesn't have the full information,
they can help you less with recovery, right?  So, did you go into that already?
What's the trade-off?  What are we losing here?

**Brandon Black**: Yeah, we did not talk about that.  Yeah, so obviously there's
two trade-offs here.  One is, now you have this additional piece of data in
addition to your normal wallet descriptor that you, as the client, have to
secure.  It still doesn't have any coin security implications.  So, it can be
put like on a Google Drive potentially.  But if someone gets that Google Drive,
just like with your descriptor, they find out how many coins you have.  And with
the current implementations, other than Bitkey, that use where the provider has
the whole descriptor, they can help you find your coins to sign for them.  So,
all you need to bring back is one of your two hardware devices in these kind of
typical 2-of-3 scenarios.  And the provider brings their key and the descriptor
to find all the coins.  Whereas if you use a chain code delegation, you must
have the descriptor and the chain code in order for the provider to help you
recover your coins.  So, yeah, I think that's the trade-offs you're dealing
with.

**Mark Erhardt**: And you have to run a watch-only wallet on your end to
actually know which coins are yours, unless you're going to reveal it to your
signing provider at the time of signing.

**Brandon Black**: Yeah.  One thing that you could do, of course, with this is
that you could now have kind of a two provider situation, where you have one
provider is the signing infrastructure and the other is the wallet.  And so, you
can split your risk in other ways.  I mean, in general, I think the trade-offs
are very manageable, but you have to be aware of them for sure.

**Mark Erhardt**: Yeah.  Also, to be honest, running a watch-only wallet to
watch your own coins seems pretty reasonable for many different reasons.  So, I
would hope that people don't weigh that trade-off too hard.  But then, security
is often traded off with convenience and, well, this is one of those cases,
probably.

**Brandon Black**: For sure.

_Probabilistic payments_

**Mike Schmidt**: There was a few discussions this year about probabilistic
payments, or this idea of somehow injecting randomness into the outcomes of a
transaction.  Rearden, why would I want to do that?  And then, what are the
ideas around it?

**Brandon Black**: So, the biggest reason I know of to do that is, if you have
the need to pay a very small amount on a regular basis, and then you can
basically conditionally make that payment based on some randomness, and then the
result on average is the correct amount being paid, but you never actually
create the dust outputs that you would create if you made those at a regular
time.  Let's say you need to pay 100 sats every day, or something.  Instead, you
pay 1,000 sats every day with a 10% probability.  On average, you're going to
pay the correct amount, and if that's enforced by some onchain contract, both
parties can probably agree that on average, they're going to transfer the right
amount of value with this probabilistic method.  You probably wouldn't do this
onchain, but it is somewhat common with Lightning.  People use Lightning to send
100 sats all the time.  And right now, in Lightning, often those payments are
basically just trust-me-bro payments, which is fine because it's 100 sats, who
cares?  But if you had probabilistic HTLCs (Hash Time Locked Contracts), you
could send a real HTLC that has the correct probability of really paying.  And
even if the channel were to suddenly close during one of these payments, on
average, it would settle correctly.  And that's basically the cool thing.

**Mark Erhardt**: So, this is pretty much one of the things that could help with
the extremely small amounts that currently flow in the LN.  A, the Lightning
Network allows to pay millisatoshis, so 1,000th of a satoshi, per the spec.  I
don't think it happens all that much, but you could.  And you can't express
those onchain, so you can't make HTLCs for those.  But then, actually, for even
smaller counts of full satoshis you can't really make HTLCs for them without
paying more for the HTLC than they would be worth.  So they are, as Rearden
says, trust-me-bro payments.  And by making them probabilistic and squashing
them into a random event that happens every once in a while, you get amounts
that you can actually express in HTLCs without losing all the money.  Obviously
also, with the minimum feerate going down by a factor 10 in the summer, I think
that we can express smaller amounts in HTLCs without losing all of its value.
But that's a separate topic for later.  Hi, Pieter.

**Pieter Wuille**: Hello.  Can you hear me?

_Summary 2025: Quantum_

**Mike Schmidt**: Hey, Pieter.  Thanks for joining us.  We were just going to
wrap up one more item, but I think you may have something to say on it.  But it
was one that was a callout in the year-in-review that Rearden authored, at least
partially authored, and then handed off to me to maybe frame it or soften it a
little bit more than he might have.  And that topic is Quantum, which I guess is
a bit timely that it came out in the year-in-review newsletter, because a bunch
of people that very day basically started talking about quantum again online and
having a fight about it.  And I think our callout in the year-in-review was
actually referenced quite a few times by people on work that is being done at
the R&D level with regards to quantum.  Rearden, what's going on with quantum?
What are Bitcoin developers doing this year with regards to quantum, without
getting into quantum stocks and things like this?

**Brandon Black**: Yeah, I mean I think there's huge movement around quantum
this year.  And what is great about it really is that it dovetails with other
things we've already talked about.  When Rusty Russell first proposed the Script
Restoration, for example, one of the things he wanted was a non-keyed hash-only
variant of taproot.  And one of the quantum-resistant proposals, BIP360, is
exactly that.  And so, there's this nice dovetailing of BIP360 is something that
kind of everybody wants.  We realized after doing taproot, where there's always
a keyspend, that while the development of taproot was talked about, and I'm sure
Pieter has some opinions on this, that having a key on everything is going to be
a privacy benefit, because almost every contract can be expressed with a
cooperative key condition.  Rusty has pointed out that, or has argued, let's
say, that there are cases where that isn't the case, where the only way to
express the resolution of the contract is through some script.  And if you don't
want a key, you're kind of wasting 32 work units of key that you didn't need.
In addition, if you're looking for protection from long-range quantum attacks,
kind of the gradual development where there might be a quantum computer that can
break one key in a year at first, and then one key in six months, and then it
kind of gradually improves, those long range quantum attacks right now would
only hit reused addresses, P2PK and P2TR addresses.  But if we had P2TSH from
BIP360, then we'd have a kind of taproot-like variant that would also be
protected from those long-range quantum attacks.

That's kind of the most active proposal that was going on in quantum.  Should I
talk about some of the other ones as well?

**Mike Schmidt**: Yeah, I think so.  You can pull out a few different things
that you think is interesting.

**Brandon Black**: Cool, yeah.  So, I think the other biggest thing to talk
about is that there's a lot of collected knowledge and mitigation proposals out
there for what we do in various quantum scenarios, and it's been frankly
discussed a lot this year.  My personal favorite of these is the Tadge Dryja and
Tim Ruffing proposals around commit/reveal style recovery.  Prior to this, as
far as I know, the state of the art in how we might recover people's coins, if
there were to be a sudden quantum break and we had to disable elliptic curve
signing on Bitcoin, was what Adam Back had briefly talked about, where if they
had a hierarchical deterministic wallet, you could use their knowledge of the
chain code, that we just discussed in chain code delegation, to recover a wallet
worth of funds in a post-quantum-safe way.  These tx commit/reveal schemes that
Dryja and Ruffing proposed would actually let even people that don't have a
hierarchical deterministic wallet still recover their coins, because they do
know something secret, which is the exact hashed contents hiding behind either
the taproot public key or the witness scripthash, or whatever the hash they have
of their address; they have some secret, and using that secret that they
technically do have, they can still recover their coins.  So, that's my personal
favorite.

The other cool work that's been going on is kind of broadly put under the
signing schemes.  I really liked the work around -- is that in here actually?
Might not be in this section.  Anyway, it was mentioned in the newsletter
somewhere, the SPHINCS+ work, where it was basically worked out that if you
optimize SPHINCS+, verifying it can be pretty much as fast as verifying elliptic
curve signatures.  But before that work, pretty much all the signature
verifications of post-quantum signatures were very slow.  So, this can help us
relax about quantum a bit, because even if we have to go to post-quantum
signing, our node resources for verification, compute resources at least, won't
be massively expanded.  That's great news for Bitcoin.  And then similarly --
oh, go ahead.

**Mark Erhardt**: Yeah, sorry.  It is in the section, the third paragraph from
the bottom.  We didn't have Conduition on, but we did talk about the work in
optimizing, like, the blogposts that Conduition put out and the research for
optimizing these hash-based post-quantum schemes.  And so, this is especially
nice because my understanding is that NIST is proposing a very similar scheme,
but using a different hash function.  And the way Conduition or others are
proposing it is to use SHA2, which we already use for hashing and other things
in Bitcoin.  So, it would sort of be our own flavor of the same scheme, which
might have some security benefits by us knowing that we already trust all the
components much heavier.

**Brandon Black**: Yeah.  And the last thing I wanted to highlight maybe from
this was just that also, we can get post-quantum signature functions with very
small changes without necessarily coding into the Bitcoin Core client a specific
post-quantum signature scheme.  If we have access to something like OP_CAT,
doesn't have to be OP_CAT specifically, but something like OP_CAT, I was talking
with Moonsettler, it could also be PAIRCOMMIT and SPLIT, there's a few other
things you could get, you can get post-quantum signatures.  And even those are
not insanely expensive.  2,000 vbytes (vB) per signature, well that's a lot.
It's something that we can at least talk about that.  And that's the kind of
size we're looking at to do just script-coded OP_CAT-style post-quantum
signatures.  So, that's the way I come away from the quantum situation, in terms
of development, is that there's a ton of progress.  We actually have pretty good
solutions in many different areas for Bitcoin, even if there were to be either a
gradual or sudden quantum break.

**Mike Schmidt**: There is a report that we highlighted at the beginning of this
callout, which was from Clara and Anthony, and I think it came out of Chaincode,
sort of having a broad overview, what is the impact of quantum potentially on
Bitcoin and what are some potential mitigating strategies.  There's more in
there than just that, but that's sort of the tl;dr.  If some of this more
concrete stuff that Rearden is talking about is too technical, you need it in a
broader picture, check out that report and that'll sort of get you up to speed.
I think there was a Quantum Summit in San Francisco, or there was, but I think I
believe it was recorded, and there are sessions on that as well, if you want to
get up to date.

**Brandon Black**: And they published a summary paper as well.

**Mike Schmidt**: Okay, great.  Murch, did you have something to say as well?

**Mark Erhardt**: I had one comment, yeah.  Obviously, if we went to signatures
of 2,000 bytes, we would only be able to fit, I had calculated it, 2,000 of
those in a block.  And so, that would be significantly fewer inputs than we
currently have per block, but it might not be the end of the world.  It
certainly would increase feerates probably.

**Brandon Black**: Yeah, I mean I think if we really end up in this world, we
would end up having a conversation at least about either a new extension block
for quantum signatures, or an adjustment in some way for them.  Whether that
would actually happen is hard to say, but we know from segwit that it is
possible to add extension blocks for purposes such as maintaining kind a
reasonable incentive structure around the creation versus consumption of inputs.
One other thing to highlight around that is that Tadge Dryja, who's done other
work in this area that I already mentioned, he also proposed a way to kind of
depend on this input style semi-signature aggregation, where you're like, "Oh,
this input can be spent as long as it's spent with that other input".  And if
you have that kind of a commitment, instead of needing one signature per input,
you could need one signature per spend from a wallet who shares a common input
hierarchy.  And that'd be another way to mitigate the cost of these larger
signatures.  That method that he mentioned would be much more costly than our
current signatures.  But if we had post-quantum signatures that are much larger,
it would be much cheaper to do it that way.  So, I think there's, again, a lot
of optimism.  Like, this is not the end of the world.  We have great solutions
for these quantum issues.

**Mark Erhardt**: Just let me rephrase what Rearden just described.  So, if you
wanted to spend multiple inputs and you knew in advance that you would be
spending them together, you could encode an output as having an option to spend
it with a previous existing UTXO.  And you could sort of piggyback on a single
signature and the other ones just say, "Look at that UTXO.  If that one's
signed, I'm happy".  And because we have script trees, we could actually be
pretty broadly committing to previous outputs, and people could then deliver
their signature with a single input and spend a number of different other inputs
along with the signed input.  Of course, this would make even more obvious that
all of the inputs are owned by the same sender, but I guess trade-offs
everywhere, right?

**Mike Schmidt**: What about this idea that BlueMatt had of putting something
into a script leaf using tapscript?  What about sort of having this break-loss
solution, so that people can feel comfortable today, even if that's not even
really fully implemented?  I maybe have a few question marks there on how that
might actually work.

**Brandon Black**: Yeah, I think the idea there was if we can come up with,
"Here's an amount of commitment that you can put in", and we don't know the
exact structure it needs to be, but you make some preimage and you hash it in a
certain way and you make commitments out of it and you put that in a script, and
then you have an op code that follows it.  And then later, we figure out exactly
what post-quantum signature scheme we're going to use, and it uses that preimage
hashes that you've already put in there with that opcode to verify a
post-quantum signature.  I also have questions around it, to be honest.  How
would we know how much data, what kind of data to hash and everything?  But it's
a good thought experiment, at least, of could we put an opcode that's like
OP_MAGICPOSTQUANTUM, and we kind of put some data with it, and then we can later
figure out how to use that data with that opcode.

**Mark Erhardt**: I think generally the approach of keeping the established
output scripts at the top layer and having fallbacks in the script tree, that
potentially use much bigger signatures but would be post-quantum secure, could
be very helpful.  But of course, as long as there is the taproot output itself
and the taproot output is spendable by a key, you do have the problem that for
long-range attacks, the key directly could be attacked.  So, often this thought
experiment is combined with the idea that you either disable the keypath spend
in the case that a quantum attack actually becomes imminent or likely, and
people have to then start using their fallback; or that you deliberately
introduce a new output type in the first place where people sort of say, "If I'm
using this output type, I do have a post-quantum fallback and it's fine for me
to renege on the keypath spend", like sort of P2TR but when quantum becomes
likely, we can nix the keypath.  That would be another way of allowing people to
use the currently way more block space efficient schemes until a Q-Day actually
became likely.

**Mike Schmidt**: Now I can hear listeners screaming into their podcast apps,
"You guys have Pieter on and you're talking about quantum and you're not asking
him his thoughts".  So, Pieter, do you have thoughts that you'd like to share
about any of the quantum topics that we brought up for 2025, or something else
unrelated that's quantum?

**Pieter Wuille**: It's a hard question.  I don't know.  I have to say I'm not
nearly as optimistic as some of you seem to sound.  I'm quite worried, not so
much about quantum computers, but about what solutions will be necessary and to
what extent Bitcoin would be able to maintain the properties that make it
valuable.  There's an inherent trade-off of like, well, letting coins be stolen
or confiscating them, which has had a lot of discussion this year and I'm happy
to see the discussion.  But many of these things, like having the ability for a
break-glass path within a taproot script, I don't know how much it gains us
because the thing that I worry will hurt Bitcoin first is a, "Help, there's
quantum evolution and I don't know if my coins are going to be secure, so I'm
going to move my coins elsewhere, sell them for something, whatever".  It's sort
of a fear of fear rather than fear of the problem itself.  And for that to be
resolved, I think, yes, you need a way to make coins quantum-secure, but not
only do they need to be quantum-secure, they need to be visibly quantum-secure.

If people are moving their coins to maybe quantum-secure paths within a
tapscript tree, but we can't observe how many people are doing that, that
doesn't actually solve the problem.  Maybe put even more cynically, if I'm
holding a small amount of coins myself, I really don't care about them.  I have
no incentive to move to a more expensive post-quantum scheme because the value
of my coins, nobody's going to steal my coins as a small coin holder.  Who
cares?  Like, I am worried about the 100,000 BTC UTXO that, you know, Binance
has somewhere.  As long as that one is not post-quantum secure, I am worried
about the value of my coins, even if mine are post-quantum secure.  And so, it's
something I've argued a bit on Delving with people about.  I think this is an
overlooked property that we not just need the ability to secretly make coins
quantum-secure, but if this is a real concern, you should have a way of making
them visibly so.  Sorry, short rant.  Please continue.

All of that said, I'm very happy with the evolution that we've seen the past
year.  There's been a much more mature discussion about the threats and
potential solutions, and I'm very happy to see that.  But I'm not sure what the
solution will be.

**Mark Erhardt**: Yeah, I think you make a very good point and one that we
hadn't discussed yet, which is it is very hard to tell how quickly quantum is
coming, but especially in the past couple of weeks, the discussion and panic
about quantum was coming pretty quickly.  And several people have been talking
about how especially people that allocate a lot of money are starting to
mitigate risk and are really concerned about this perceived under-research
issue.  And so, of course, (a) I think that research has been fine this year,
but (b) the problem becomes a social one, where we not only have to do the work,
but we have to convince people that the work is being done and it's being done
fast enough.  And I think that's the arena that we're currently not winning in.

**Pieter Wuille**: Yeah, I don't even know if that's possible.  People talk
about, "Oh, we, as the Bitcoin ecosystem, need to have a post-quantum plan that
we can show the world that we're ready".  But how could we commit to such a
plan?  The ecosystem that will need to agree to adopt those rules is not us.  It
is us a couple of years from now, or hopefully decades or longer from now.  And
I find it just strange use of language to be able to say to have a plan.  You
don't have a plan in Bitcoin consensus rules, unless it is the consensus rules,
period.  You can do research.  Research is amazing, but you can't call it a plan
unless it's adopted.  I think that's a decentralized versus traditional thinking
kind of thing.

**Brandon Black**: One thing I think that does help me stay optimistic is
frankly the progress on Script Restoration or Script Renaissance, or whatever
you want to call it, because if we had something like restored script for
Bitcoin, it would give people actually lots of options to build their own
signature schemes.  And they would be more costly than current elliptic curve
signatures, but they would be manageable in cost under the restored script model
with big number math and additional hash flexibility and script size
flexibility.  So, that leaves me pretty optimistic to your point there, Pieter,
of we have a path where we can build in something that lets people make
individual choices within consensus.  And I think that's really why Rusty wants
to take that direction as well, is we want to give people more freedom without
having to change consensus for everybody's different opinions.

**Pieter Wuille**: I'm going to have to disagree with this too, I'm afraid.  I
don't believe choose your own security model works at all.  And this is a
thought experiment that brought that up a few times, which is maybe not too
far-fetched.  A few years from now, someone invents a post-quantum scheme that
has all the properties we want.  It has something BIP32-like, it's small, it's
fast, can do PTLCs and everything else with it, and it was invented that day.
You could imagine that within a couple of months, some part of the ecosystem
starts going, "This is the solution we've been looking for.  Quantum risk is
becoming more and more real.  We need to adopt this as soon as possible".  While
at the other side, you might have a group within the ecosystem is like, "What
the hell, dude, this was invented literally yesterday.  I'm not putting my money
on this".

But the difference in opinion between these two hypothetical groups is actually
even bigger, because the first group doesn't want to just have the option of
adopting this scheme.  If they're truly worried about a quantum computer being
around a corner, they want everyone to move to it.  While similarly, those who
believe it is just an insecure, dumb idea would want no one to move to it.  And
I think in the extreme, and this is a deliberately non-realistic extreme thought
experiment, but in this extreme, these two groups, simply there's no way to make
them share the same chain.  Because if they believe that significant adoption of
either side is going to threaten the value of their own coins, they would not
want to share.  So, it boils down to, I think, even though bitcoin is a currency
for enemies, you do need to agree on something.  And what you need to agree on
is the cryptography you can trust.  And without that, all of this to say, I
think for experimentation and thought experiments and flexibility while figuring
things out, having lots of options for building things yourself is interesting,
but it's not a long-term solution.  A long-term solution will need to be
everyone agreeing on a scheme to use and agreeing that everyone should use it.

**Brandon Black**: Great thoughts, man.  Thank you.

**Mike Schmidt**: Murch, anything else you think we should touch on in quantum?

**Mark Erhardt**: Well, maybe just a little sober thought, which is if one of
the biggest concerns is that the introduction or the idea of a new scheme is
going to be very controversial because, let's say, half of the network wants it
and the other half absolutely doesn't, then this panic about quantum attacks or
Q-Day being driven so hard is even more detrimental, because not only does it
push people to the point of this disagreement faster, but we'll have less time
to have a good solution that might be able to convince more people.

_Cluster mempool_

**Mike Schmidt**: Well, I have a feeling we'll have plenty of discussions about
quantum in 2026 on the show here, Murch.  This is maybe a good spot to wrap that
up for now.  We have Pieter, who as you all hear, has joined us.  And we have a
few items that he's contributed to this year that we wanted to get his thoughts
on, some interesting projects.  The first one that I think comes to everyone's
mind when we talk about 2025, what kind of stuff has Pieter been doing, is
cluster mempool.  So, Pieter, it seems like it's here, it's in, right?

**Pieter Wuille**: Yeah

**Mark Erhardt**: SFL got merged now!

**Pieter Wuille**: Yeah, after almost three years, I think, I look back in
history, I think it was around January or February 2023 that Sjors and I started
talking about this idea.  And it took maybe a bit longer than we had
anticipated.  I think at some point, we were aiming to have it merged by the end
of 2024, so off by one.

**Mark Erhardt**: It's just an off-by-one area!

**Pieter Wuille**: No, but I think we're in a great state.

**Mike Schmidt**: I think some people might maybe skip all the newsletters and
podcasts all year and maybe they'll read this one and maybe they'll listen to
this one.  What would you tell those folks?  What is this and why is it
important?

**Pieter Wuille**: So, I think that the number one reason is just something in
the Bitcoin Core and mempool design was just fundamentally broken, maybe not in
a way that's directly exploitable, but just felt so wrong that that could
happen.  Step back, so Bitcoin Core mempool reasons about a set of unconfirmed
transactions.  They are being used for validating new transactions that come in
because they can depend on other unconfirmed transactions like CPFP.  They're
being used by miners to grab what transactions go into the next block, they're
being used for fee estimation, and a number of other things.  And one of the
rules mempool has is that it never allows two conflicting transactions at the
same time, just the DoS attacks blow up exponentially, and I mean that in the
actual scientific sense of the word, if you allow conflicts.  It's just so hard
to reason about.  So, we don't allow that.  That means when a conflicting
transaction comes in, we need to either reject it or kick whatever it conflicts
with out.  And so, that's part of the reasoning too.

**Mark Erhardt**: So, why was conflict management so difficult before cluster
mempool?  How does cluster mempool improve conflict management?

**Pieter Wuille**: It's better.  It's still fairly hard, I would say.  But I
realize I'm explaining the more complicated scenario.  I'll skip to the simpler
one, which is eviction, just when a mempool fills up.  We call it a mempool
because we keep it in memory.  Not that that's really strictly necessary, but
also memory is big enough.  So, by default, it's a couple of hundred MB worth of
transactions that are kept.  But at some point during transaction floods, it
fills up and you need to decide what to remove.  And so, a logic is used to
determine basically what are the worst transactions in the mempool.  And that is
done based on their feerates, lowest feerate ones.  But of course, when you
evict the transaction, you also need to evict all its descendants.  You can have
a CPFP where you try to evict a parent; well, now you need to evict a child too,
because a child is invalid without the parent.  So, when evicting, we basically
look at what's the lowest feerate of any group of transactions we could remove,
together with all its descendants.

It turns out that in pathological situations, this could include the very first
transaction you want to mine.  And this, I think, was the direct motivation for
the cluster mempool work.  We wanted a solution to this problem where we can't
actually reason about what transactions are good and bad.  And I guess an effect
of that is that this eviction logic makes bad decisions.  But the core issue is
really -- yeah, you want to say something?

**Mark Erhardt**: Yeah, sorry, I wanted to recap a little bit.  Basically, the
heuristic we were using to evaluate which transactions should be evicted first
was the descendant score, while we used the ancestor score to determine which
transactions we would pick into blocks first.  And the only proper way that we
would have had to know which transactions would be included in blocks last,
rather than having the worst descendant score, was by basically building blocks
through the whole mempool until we got to the end and realized what we would
pick last.  Obviously, if the mempool is up to 300 MB, that's an immense amount
of work just to determine what you're going to evict from the mempool, because
it's overflowing and not really credible.  And therefore, we used something like
the descendant heuristic, which works fine in most cases.  But we can construct
examples, as you said, the pathological example, where the descendant score
would indicate that a group of transactions should be evicted, and it would kick
out a transaction that would be in the first group that gets picked by the
ancestor score.  And now, with cluster mempool, this has changed, of course.

**Pieter Wuille**: Yeah, exactly.  And even if you can't follow the whole
reasoning here, I think that the higher level observation is the Bitcoin Core
mempool couldn't reason about how good or bad individual transactions are until
the mining algorithm is run, and that's fairly slow.  And so, we can't do it all
the time.  And it makes bad decisions as a result of that.  And one example is
this bad eviction, but it also is reflected in making bad decisions when making
replacements, bad decisions what order to relay transactions, and maybe gets
skewed feerate estimation, and so forth.  And so -- yes?

**Mark Erhardt**: Also, bad decisions on building blocks, because ancestor score
actually doesn't necessarily give you the best group of transactions.

**Pieter Wuille**: That too.  And so, altogether, what has changed?  We
basically partitioned the mempool into groups of related transactions.  And by
related, I mean parents, children, but also cousins, nephews, and any ancestor
of your descendant of your descendant of your ancestor, anything related in that
sense becomes a cluster.  And instead of running the mining algorithm at mining
time, we run it anytime the mempool changes, but we just run it on this small
partition of related transactions.  And that basically gives us sort of a
pre-computation, we do the heavy lifting ahead of time, but only on small groups
of transactions that keep it manageable.  And the vast majority of clusters are
one or two transactions.  This is not a hard problem.  And as a result, we get
to use this pre-computed data for everything, for relay, for eviction, for
replacement, for fee estimation, and so forth.

It does come with one big and hopefully not too impactful practical policy
change or relay change.  That is, there used to be limits on the ancestor set
and descendant sets.  So, that just counts for any given transaction, how many
unconfirmed ancestors does it have, or how many unconfirmed descendants does it
have?  And by default, in Bitcoin Core, those were limited to 25 each, including
the transaction itself.  That is now changed.  So, there are no more ancestor
limit, no more descendant limit.  Instead, there is a cluster count limit of 64.
And so, this is your ancestors and your descendants and the descendants of those
ancestors, and so forth.  All of that combined can no longer exceed 64.  But in
return, we can basically run optimal mining, like find the optimal order on each
and use a much better reasoning about all of it.

**Mark Erhardt**: Just to be clear, so the ancestor size limit or weight limit
and descendant weight limit have been also transformed to a cluster weight
limit.  So, the whole cluster is now limited to 101 kvB (kilo-vbytes).  And for
many transaction patterns, this cluster limit actually is an increase in how
many transactions might follow each other.  So, if you have a peel chain, where
you just keep spending from one UTXO, you were previously limited to a chain of
25, and now you would be limited to a chain of 64.  However, due to the clusters
extending to the descendants of ancestors and ancestors of descendants, they can
sort of grow sideways.  So, in the past, we've had clusters that well exceeded
1,000 transactions.  And for these sort of super-clusters, they would not be
permitted under this new standardness rule, and they would be limited to 64.
So, if you're constantly spending unconfirmed transactions and unconfirmed
transactions with many inputs, where that previously managed to fit into the
ancestor and descendant limits, those are probably the only people that will
feel this new limit.

**Pieter Wuille**: Yeah, and it's a good question how much of those
super-clusters, as you call them, reflected actual desirable patterns that
people rely on.  It's not just because we see those things emerge on the network
that there's a use case that's dependent on them.  And to be clear, it's not
that it becomes illegal to have these transaction constellations.  They just
cannot be simultaneously in the mempool.  What may have happened, or what might
happen now, in case a similar scenario were to play out, would be that the first
64 transactions of it make it into the mempool, then at some point some of them
get mined, and now the rest get relayed, and it slowly grows from there.  So,
think of it more as like the mempool gets a window of at most 64 that walks
through your whole constellation.

**Mark Erhardt**: Or alternatively, if someone adds a very high-paying child to
one branch of a cluster, that would push out transactions that are much delayed.
Or is that happening right now, or do we still have only CPFP RBF?

**Pieter Wuille**: Yeah, I don't really know what's happening in terms of
patterns, I haven't looked.  But as far as I know, the only real things that
people are doing are CPFP and peel chain kind of behavior.  And there is a bit
of a self-reinforcing effect here, of course, because CPFP works, and it works
because the old algorithm supported it, and thus people can make use of it, and
people do.  With cluster mempool, much more complicated things become possible,
like it wasn't possible before to have two children bump the same parents.  That
becomes possible now.

**Mark Erhardt**: It was possible, but they were competing, right, because they
were in separate ancestor sets.  So, they would be evaluated separately.  Now
they get evaluated as one chunk.

**Pieter Wuille**: Right.  They wouldn't be treated as both contributing to the
same parent.  And so, those things become possible.  I don't know if people will
use it.  I wouldn't say that that is the goal.  Certainly, nice if it turns out
to be possible, but the goal is really just we've introduced an abstraction
layer that can properly reason about the feerate quality of groups of related
transactions and use it for everything.  And it also turns out that we can do a
much better job at reasoning about those than the old algorithm could.  So,
that's a nice benefit there.

**Brandon Black**: Yeah, it seems like especially for exchange withdrawal use
case, where an exchange can take one big UTXO and pay 1,000 people at once,
previously just the single highest paying of those -- if this exchange is a
low-fee transaction, and then someone tries to CPFP it, not really on purpose,
but they just try to spend from it, the single highest paying child is going to
try to pull up through, whereas with cluster mempool now, the top 64, top 63
highest paying children will all try to pull it through.  So, I think there is
actually a pretty big practical benefit in these exchange wallet use cases.

**Mark Erhardt**: So, I think my question from earlier got lost.  One of the
interesting contexts of cluster mempool was that it would become possible to
evaluate multiple transactions for replacement.  I believe that so far, only
CPFP, or sorry, two-transaction package replacement has been merged.  But is it
conceivable also that if you had a cluster of 64, what happens if someone else
broadcasts a juicy 65th transaction?

**Pieter Wuille**: Yeah, I think right now, if it just attaches to it, it will
be rejected.  I think instagibbs has floated the idea of kindred eviction, of
the ability for a transaction to be added to a cluster and then have something
else within the cluster be evicted.  I think there are some questions about DoS
risk there and how to reason about it.  But I wouldn't call it fundamentally
impossible or a bad idea, but that's not implemented.

**Mark Erhardt**: So, there's this ongoing research, so to speak?

**Pieter Wuille**: Yes.

**Mark Erhardt**: All right.  Could you maybe tell us a little bit, you spent a
lot of time this year on delinearization of clusters.  We already talked about
how clusters are found.  They're basically just all of the transactions that are
related to each other become one cluster.  Obviously, every transaction can only
belong to one cluster, because it's right there with all its relatives and any
unrelated transaction will be a separate cluster.  But we sort of described it
so far as running the mining algorithm on the cluster and then knowing the
mining scores for every single transaction in that cluster.  Now, we haven't
really talked about chunks yet at all, but the idea is that when we have the
cluster, we split, or not split but we think in the cluster as segments of the
cluster being grouped together at the same feerate, because they will be picked
by the mining algorithm in groups into the block.  And we call those chunks.
Sorry, you correct me if I'm saying anything wrong.  And now, one of the big
research areas was, how do we efficiently run the mining algorithm on this
cluster?  How do we find out the order of the clusters?  And you called that
linearization and you had three approaches for this.

**Pieter Wuille**: So, when we started this project, the idea was just on these
groups of transactions that we call clusters, we run the mining algorithm.  And
the mining algorithm was the mining algorithm that we had, which was
ancestor-sets-based mining, the same algorithm that we've had since, I think,
2015 or so.  And we know it is suboptimal in the sense that, for example, it
will not discover two children paying for the same parents.  And so, once we
restricted ourselves to -- and I think you touched on this a bit, but the
observation we made is that really, the only computationally heavy part is given
a group of transactions that are related, figuring out what's the optimal order
to mine them in.  And once you have that, you can sort of chop it up in these
groups of transactions that will get picked together.  I don't think this is a
good medium to explain it, but there are many Delving posts that go into it.
Just take from me, all you need to know is for every group of transactions in
the mempool that are related, what is their relative order with respect to each
other that you would mine them in.  Then, picking the best combinations from all
the clusters is a very simple problem.  It's sort of a merge sort, you can think
of it, just pick the highest chunks from each in decreasing feerate order.

But so, everything boils down to, okay, you're given a group of transactions,
what order do you want to mine them in?  And we generalize that a bit.  We call
that the linearization algorithm.  It is turning them into a linear sequence of
transactions.  And throughout time, I remember you and I, Murch, talking about
this in the office at Chaincode a while ago on various algorithms for how to do
that.  And so, I think somewhere, I forget when, it was last year or the year
before --

**Mark Erhardt**: I even had my own approach.  Unfortunately, it was worse than
all three of yours!

**Pieter Wuille**: So, I think somewhere in 2023, we came up with this what I
thought was a pretty neat optimization trick that basically gave a square root
speed-up in the worst case to the algorithm, but it was exponential.  It took
basically the square root of 2<sup>n</sup>, where n is number of transaction
steps in the worst case.  And this meant that we could probably do like 10, 15
transactions optimally in all cases, and maybe somewhat bigger in many practical
cases, but wouldn't be able to guarantee it because it's still a fundamentally
exponential algorithm.  It's essentially iterating sets of transactions to
include, and that the number of possible subset of a set is 2<sup>n</sup>, and
there was a heuristic that allows you to skip a whole lot of them, but it's
still fundamentally that.  And so, I was pretty proud of having this algorithm,
wrote big posts on Delving about it, implemented it, got it reviewed and merged
in Bitcoin Core.

Then, beginning of this year, Stefan Richter posted on Delving, "Hey, I asked
DeepSeek R1, an LLM about this problem, and it told me there's a paper from 1989
that solves it in cubic time".  And indeed, it did.  It took me a while to
understand the paper, I thought it was pretty densely written.  But yes, it is
indeed a cubic time algorithm in the worst case that sort of transforms the
problem to a max flow problem in graphs, and then finds a min cut through those
graphs and those become the chunks, and then you do this recursively.  And then,
you need to use a trick where you run it forward and backward at the same time
and see which one of the two finishes first, because if you run it in the wrong
direction, it can be quartic in the worst case.

However, at that same time, last year in 2024, we hosted this research week here
at Chaincode Labs, and some researchers here were interested in this problem.
And after finally convincing them that this was not a trivial problem, one of
them pointed out that actually this can be formulated as a linear programming
problem, which is a standard optimization formulation for many industrial
problems.  And there's a whole subdomain of science basically dedicated to how
to solve linear programming (LP) problems.  And this was a translation, a pretty
straightforward translation of our problem to an LP problem.  So, that means the
entire domain of LP solvers became relevant to this, and that too implied a
polynomial time algorithm would exist.

**Mark Erhardt**: Maybe let me jump in very briefly here.  So, for listeners
that don't dabble in computational complexity all the time, an exponential
problem grows sort of in the number of factors. So, if you have three, you
multiply the cost by the cost by the cost, three factors of the cost multiplied
with each other.  If a problem then grows to ten, you would have ten factors of
the cost being multiplied with each other at a cluster of 64 transactions; you
multiply the cost 64 times by itself.  That is an insurmountable amount of
computation.  But on the other hand, if you had a cubic or even a quartic
solution, you would instead have the cost growing to the third power or the
fourth power, which at up to four transactions in the cluster would maybe be
less work.  Sorry, go ahead.

**Pieter Wuille**: Let me give concrete numbers.  So, the most naïve exponential
algorithm for linearization is, every additional transaction doubles the amount
of time you need.  With my heuristic, I came up with this, every two
transactions that get added double the amount of time.  With this algorithm from
the 1989 paper, doubling the number of transactions, not adding two, but
doubling it is times eight.  And a slightly more naïve variance is, doubling it
is times 16.  And so, you can work out, if you were talking about 64
transactions, if every two doubled the amount of time, you're talking about a
cluster of 64 taking literally billions of times slower than a tiny one, where
with a cubic algorithm, it's maybe 1,000 times worse.

**Mark Erhardt**: So, just a cool 1 million time speed-up.

**Pieter Wuille**: Yeah, in super-pathological worst cases.  But of course, we
do need to worry about these, right, because someone might actually construct
such a transaction.  And jump back.  So, I was talking about this LP problem
formulation that was found at the end of 2024.  I built on that and okay, let me
take our problem, our specific LP problem, the cluster linearization problem,
and write it out on the whiteboards, "What is the LP problem?"  Now, run the
simplex algorithm, which is one of the algorithms that is the most famous
algorithm for solving LP problems, and see what it actually means, because the
simplex algorithm operates on matrices and numbers and vectors, and whatever.
But in our problem space, we're talking about transactions and feerates and,
chunks and whatever.  And so, I found a correspondence between these two, where
basically every step of the simplex problem applied to the LP formulation of our
problem corresponded to something, "Oh, that corresponds to merging these two
chunks.  This corresponds to splitting those two chunks.  This corresponds to
moving this chunk up.  This corresponds to moving this chunk down", and sort of
wrote it down.  And every step was like one of seven possible steps that could
be taken.

But some of these just look dumb.  It's like, "Okay, there's a higher feerate
chunk and a lower feerate chunk, and instead of including the lower feerate
chunk, you should include the higher feerate one.  Duh, I'll always pick the
higher feerate".  So, just stripped this down to all the things that made sense
and came up with this pretty, I think, simple algorithm, which is the
spanning-forest linearization (SFL) algorithm.  That's the one that's now merged
in Bitcoin Core.  And the big advantage, I think, compared to the one from this
1989 paper, is that it's easily randomized.  So, it doesn't have an upper bound
in its runtime.  In theory, it could randomly make the wrong decisions forever
and never finish, but this is extremely unlikely.  And in practice, it finishes
really quickly.  But the reason we care about it is by being randomized, it's
unpredictable and it would become very hard for an attacker, who deliberately
constructs hard clusters, from making ones that will deterministically behave
badly for everyone.  I saw you were raising your hand a few times, Murch.

**Mark Erhardt**: I led you down the very detailed branch and while I personally
am super-interested, I think we're losing some of our audience.  So, I was
trying to bring us a little more to the surface again.  And that was, so we had
three different approaches.  One was a little naïve, we found two optimizations
for that one was based on LP and one was based on this min cut in a graph.  And
I think one of the things that you said was the very interesting improvement of
the LP-based one, that generally each of the steps either kept the same quality
or made it better.  So, you could stop it at any time and however much compute
you had spent towards finding the optimal solution, you had improved the
solution and you could stop in between.  And I think that was ultimately why you
chose to go with the spanning-forest linearization algorithm over the 1989 one,
because the other one was only, if you run it to the end, you get a solution; if
you don't run it to the end, you get nothing.

**Pieter Wuille**: It's a bit more nuanced than that, but yes, you can also stop
it early.  Because the other one is sort of a recursive subdivision thing, you
need to have some control of, "I have this much computation budget left, how am
I going to split it among all the branches I have?"  And SFL doesn't suffer from
that.

**Mark Erhardt**: Okay, Mike, do you want to bring us up a little further to the
surface?

**Mike Schmidt**: Well, I think we can jump into the next item.  I think we did
cluster mempool deep dive.  What about, Pieter, your work on minisketch and its
relation to Erlay?

_Erlay update_

**Pieter Wuille**: Yeah, so Erlay saw some revived activity, I'd say, in the
last year, with Sergi doing lots of experiments on many possible variations of
the algorithm, with trade-offs between bandwidth, privacy, speed of propagation.
I don't actually know what the status is right now, I haven't seen much there.
I hope it gets picked up soon again.

**Mike Schmidt**: What's the big picture idea?  What are we trying to do here
with Erlay?

**Pieter Wuille**: Oh, right, sure.  So, the idea of Erlay is, Bitcoin's
partition resistance in a network is primarily dependent on the number of links
nodes have to each other.  If you're connected to 20 nodes and you only need one
of them to be honest, or connected to the honest network, that's easier to
achieve than if everyone only has four connections.  So, in order to improve the
partition resistance of the network, we want to increase the number of
connections that nodes have.  Sadly, there is a significant cost to more
connections, because if everyone makes twice as many outgoing connections, then
nodes which take incoming connections are going to see their number of incoming
connections double too.  And there are CPU costs related to that that are hard
to avoid, but there's also bandwidth costs.  And this is maybe a bit
unintuitive, because obviously we only relay a new block that comes along, we
only relay it once to appear, not over every connection, with some caveats, with
compact block mode.

But so, it's not that more connections means more blocks are being sent.  Also,
the same for transactions.  Transactions are announced using a gossip technique,
which means you tell your peers like, "Hey, I have a transaction with this
hash", and they receive that message from many of their peers and they pick one
of them and say, "Give me that transaction".  They only receive the transaction
once, but they do get the announcement for the transaction many times.  And so,
it means if we increase the number of connections per node, we will inherently
scale the bandwidth for transaction announcements, which is still 36 bytes per
transaction by all the connections in the network.  Literally, every connection
in the network will have one or two announcements going through it.  It could be
two if both sides simultaneously send it to each other even.

So, what is the idea of Erlay?  If instead of always announcing all transactions
to everyone, for some or most of our connections, we keep a set of, "Hey, here
is the set of transactions I would have announced to you in the past X seconds",
and they do the same thing.  They don't actually announce it, they just keep a
set of the things they want to announce.  And now, you run an efficient protocol
for comparing these two sets with each other every so often, and this is called
the set reconciliation protocol.  And it turns out that this can be done with a
bandwidth that is proportional only to the difference between the two sets.  So,
if they're mostly the same, it turns out you can do this with fairly low
bandwidth.  And so, this is the philosophy behind Erlay, is we could increase
the number of connections in the network without proportionally increasing the
bandwidth from announcements, by replacing many of them with regular set
reconciliations instead of just wholesale blasting out.

**Mike Schmidt**: Does that have an impact on propagation times?

**Pieter Wuille**: It does, and so it does come with an extra delay.  And so,
the strategy that's being investigated is one where you still use the normal
announcement mechanism for one or a few peers, and the hope is that this is
enough to get good propagation to the network already, not 100%, probably not
99%, but maybe 90%, or something.  I haven't looked at the numbers lately.  And
then, the last few percent is what Erlay will catch.

**Mark Erhardt**: Yeah, so one of the problems is the set reconciliation only
works really well if nodes do hear about transactions in the first place.  So,
the transaction still has to propagate for set reconciliation not to take a
whole lot of bandwidth.  But then on the other hand, you really don't want this
duplicate announcement.  So, for example, for transactions that are not in the
top two blocks of the mempool, they don't actually need to propagate that
super-quickly.  And it would be enough if they propagate slowly only to a couple
or maybe three connections per peer, and that way spread slowly, and the rest
gets filled up by the set reconciliation.  Whereas, especially for the
high-feerate transactions that are competing for the next block, you want them
to propagate quickly, and they might be prioritized and pushed out to a few more
peers.  But even those wouldn't be pushed out to every peer because some of it
gets can be picked up by set reconciliation, which is much more
bandwidth-efficient to just make sure that you have aligned on the differences
between your sets.

**Mike Schmidt**: I think we talked with, I don't know if we had a guest on,
but, Murch, there was an item a month or so ago about folks using, I think it
was minisketch to do gossip on Lightning, right?  Somebody started monitoring
gossip in hopes of getting data that would inform a
mini-set-reconciliation-based gossip.

**Pieter Wuille**: Yeah, I know Jonathan Harvey-Buschel is looking into that.  I
don't know the current status.

**Mark Erhardt**: I wonder how you know that!

**Pieter Wuille**: Well, his desk is next to mine.

**Mark Erhardt**: All right.  So, do we know anything about the status of Erlay?
I haven't heard an update in a while.

**Pieter Wuille**: I don't either.

**Mike Schmidt**: Maybe we'll see in 2026.

**Mark Erhardt**: Well, I guess we'll have to ask Sergi at some point.  All
right.  Do we have anything else on Erlay?

**Mike Schmidt**: I don't think so.  I think that was a good overview and folks
can dig into the year-in-review to click around to the few updates that Sergi
had earlier this year.

_Comparing performance of ECDSA signature validation in OpenSSL vs. libsecp256k1_

We highlighted specifically a post from, I believe it was the Stack, on
performance of OpenSSL versus secp ten years on.  Maybe, I mean you're deeply
involved with all the contributions that went into that.  What was your take of
that analysis?  I know you had some asterisks there as well.

**Pieter Wuille**: Yeah, I thought it was pretty interesting to see it
visualized.  And you can pretty clearly see periods of time when libsecp's
algorithms got attention from contributors and when they didn't.  There's these
years where it stays constant and then like, 2% off, 7% off, 20% off, 3% off
over the course of maybe two years, and then it flattens out again because
nobody's working on it anymore.  Yeah, I thought it was a nice retrospective to
see all the things we did over a long period of time sort of put in perspective.

**Mike Schmidt**: It validates the performance work that you've all put in.

**Pieter Wuille**: Yeah, it still beats OpenSSL by even more now than it did ten
years ago.

**Mark Erhardt**: Well, as it should, because we use secp all the time, every
day, every transaction, and OpenSSL does not.  So, it's quite understandable
that nobody is spending resources there on it, especially now that we don't use
OpenSSL anymore.

**Pieter Wuille**: Did you know that my first plan, before I started writing
libsecp, was to contribute a secp module to OpenSSL?  And I looked at their code
base and was horrified.

**Mike Schmidt**: That's another reason to be proud of not just the performance
but the separation, and dropping that dependency for that very reason of that
sloppy code.

**Mark Erhardt**: I would like to not throw them under the bus too much.  It's a
toolbox of all sorts of different curves and algorithms, and so forth.  So, for
the ones that are used a lot, I think they do get a lot of attention.  But
because it has so many different construction sites, it's hard to have very high
quality for all of them.

**Pieter Wuille**: It just has a way larger attack surface, and it's just a way
larger code base that does way more things.  Indeed, thanks for that.  I think
it's indeed inappropriate to criticize them for that.  But at the same time,
it's nice to have a highly tailored, very well-tested, high-performance library
that we can use that doesn't have all those extra baggage.

_Summary 2025: Stratum v2_

**Mike Schmidt**: Pieter, we've taken up a lot of your time already.  I don't
know if you want to talk about Stratum v2.

**Pieter Wuille**: I've only followed it from a high level.  So, we do have in
Bitcoin Core 30 now finally, the new IPC interface for mining, which as I
understand it, there's Stratum v2 code out there that can use it.  So, it
doesn't need to rely on a patched bitcoind anymore or wrapping around the old
interface, like asynchronous and compact and binary, and that doesn't send over
the full transaction information when the client doesn't need it.

**Mike Schmidt**: And the plumbing that went into separating these things out,
right?  Like, we have this Bitcoin node now, we have obviously the Stratum
sidecar can talk to that, but now you have this IPC interface.  And I mean,
wasn't that something that was worked on for like ten years in that office over
there?

**Pieter Wuille**: Yeah, it was.  I'm sure Russell is pretty happy with the
sudden extra attention it got and the push.  And I don't want to speak for him,
but I think Russell's goal is, like, a multiprocess future, where there are
different components within the Bitcoin Core code base that communicate with
each other through IPC.  And the IPC interface was initially being designed for
that, and has now been given an extra use of being used for this mining IPC
interface.  So, the multiprocess stuff isn't quite there, but the IPC part is.

**Mike Schmidt**: We had the Stratum v2 requirements sort of forced or nudged
along that project.  So, maybe just in a sentence or two, what would a
multiprocess Bitcoin Core future look like?  What does that tangibly mean?

**Pieter Wuille**: Like have the wallet and the GUI and the Core node run
literally in different processes, like different programs that you run, probably
on the same computer, but in theory they could even run on different systems.
And so, you get the process isolation of having your wallet and your node not
running in the same space, or the ability to run, connect the GUI and just
connect it to your node and be able to close the GUI and not close the whole
thing.  So, they become sort of pluggable components that speak to each other
and less monolithic.

**Mark Erhardt**: Yeah.  I mean, that alone is a big UX improvement.  Have you
ever run your node and then you had to shut down your node in order to look at
the GUI because you wanted whatever?

**Pieter Wuille**: It rarely happens, but yes.

**Mark Erhardt**: Yes, so annoying.  But it being a ten-year effort to pull
apart these parts so that they can be run in separate processes also seems like
a steep price for this sort of improvement.  So, I think maybe just generally,
it would help also with distinguishing the surfaces of where one part of the
project starts and ends, and maybe would lead to people being more focused on
certain areas of the code base.

**Pieter Wuille**: A large part of the effort that went into it is defining
these interfaces between the components.

**Mike Schmidt**: I was just going to round out the Stratum v2 callout with a
couple of pools that have implemented Stratum v2.  Hashpool, which is an
ecash-token-based pool, but also DEMAND Pool, which went from a solo-mining
Stratum v2 pool to pooled mining this year.  And then, there was also a mining
device manufacturing company in the last month also that announced Stratum v2
support for their miners, and that was out of the box.  And I think it was for
the encrypted communication piece of that.  And so, you're seeing uptake of
Stratum v2 here.

_SwiftSync speedup for initial block download_

Okay, well, we talked about two different things in the year-in-review that were
somewhat related.  One was SwiftSync and one was the utreexo draft that's being
published.  SwiftSync, and maybe you can elaborate on it, as a way to speed up
IBD using this hints file that says, "Hey, here's what's going to be in the UTXO
set at this block height".  So, when you do your IBD, you don't need to add
anything to the UTXO accumulator data structure as you go through, unless it's
in this list.  Is that right?

**Pieter Wuille**: The idea is you'd still do your full synchronization.  There
are two versions of SwiftSync.  One is combined with assumevalid and the other
is without.  The one with assumevalid is a lot simpler to explain.  So, you get
a hints file that you get from a semi-trusted source.  And it just tells you for
every UTXO ever in history, will it survive to the end or not, or does it get
spent along the way?  And then, you do your synchronization and every UTXO that
gets created that survives, you treat normally, you just add to a UTXO set; but
the ones you know that won't survive, instead you add to a very simple
accumulator.  And when they get spent, they also get added to an accumulator.
You create two accumulators, one of non-surviving UTXOs that I've seen being
created, and non-surviving UTXOs that I've seen being spent.  And at the very
end, these two must be the same, otherwise something was created that wasn't
spent or worse, something was spent that -- in one direction, I guess it means
your hints file was wrong; and in the other direction, it means it was
double-spent.  But it bypasses the whole database access for creating the UTXOs
that get spent within that window anyway.  And so, I think it's a pretty
interesting idea.

There's a PR now to Bitcoin Core.  I have not looked at it myself.  So, I
understand that it's pretty conceptual, because it does bring questions similar
to the assumeUTXO questions of like, where do you get the hints file?  And so,
maybe important to point out that the hints file is only semi-trusted, in the
sense that lying about it cannot ever make you accept an invalid state, but it
can make you waste a whole lot of time.  If I give you an invalid hints file,
you'll do the full sync and at the very end conclude, "Oops, this was wrong".
But you'll know it was wrong and you'll start over, from hopefully a better
source.

**Mike Schmidt**: Is that something that would be attested to in the Bitcoin
Core GitHub somewhere?

**Pieter Wuille**: That is a possibility.  I don't think discussions have gotten
to that point.

**Mike Schmidt**: So, the trick here, Pieter, seems to be bypassing the
database, the UTXO database, because it is, should I use the word, inefficient
or slow?  And by doing that, you can parallelize things.

**Pieter Wuille**: Yeah, parallelization.  Really, the speed-up comes from
parallelism because that's the important realization.  Nothing in this process
depends on the order of seeing the UTXO first being created and then being
spent.  It's perfectly fine to first see the spend and then see the creation,
because in the end, they cancel out and you're fine.  So, this means you can do
things like just load blocks in parallel from all over the chain in any order,
and just validate them pretty much independently from each other, where the
traditional Bitcoin Core database design really requires a sequential processing
of seeing the creation first and then the spend.  So, that means we must process
the blocks in order and we can't just validate them as the blocks come in, which
is already in parallel.

**Mike Schmidt**: Yeah, I think this is one of the criticisms that, for example,
Eric Voskuil has of the way the Bitcoin Core handles the UTXO set, right, and
how the bitcoin -- I know he's done a lot of optimization on IBD parallels.
Parallelism there, I think, is what he's sort of beaten on as the advantage.
And so, SwiftSync is sort of a way, at least during IBD, which is I guess when
you care about this the most, is to have that sort of parallelization,
parallelism in Bitcoin Core.

**Pieter Wuille**: Yeah, I think that's fair.  I mean, I think ultimately it is
far more important to focus on performance of validation at a tip than IBD,
because IBD you do only once and validation at a tip is critical for propagation
speed of blocks on the network.  But this, I guess, gives us sort of an
alternative way that can be used for the early part of IBD to use a different
algorithm that has higher parallelism instead.

_Utreexo draft BIPs_

Transitioning from SwiftSync on a related piece of technology that's been under
development, is utreexo, and 2025 brought the three draft BIPs that make up the
utreexo idea into fruition, which a lot of people were excited about.  As a
reminder, utreexo, this is a series of BIPs that represents a proposal to let
Bitcoin nodes verify transactions without storing the entire UTXO set.  So,
instead of keeping every UTXO, the nodes maintain a compact cryptographic
accumulator, I believe, is the data structure which we just sort of talked about
with Pieter, and SwiftSync as well, that commits to the entire UTXO set.  And
then, when a transaction is spent, it includes a little proof that shows, "Hey,
this is how you prove that I'm in this accumulator data structure".  And so,
it's a compact way to store that.

**Mark Erhardt**: Yeah, so the constructions are slightly different.  In
SwiftSync, you actually just have that one rolling hash basically that you keep
adding to and deducting from, or maybe like a bit string that you keep adding
and deducting from.  And if you add and deduct everything, you eventually come
out at zero.  In utreexo, you actually have a forest of merkle trees, where each
of the merkle trees commits to some UTXOs.  And then, you prove that a UTXO
exists by showing the route in the forest to a specific merkle tree and then the
branch in the merkle tree to a specific leaf, proving that the UTXO has not been
spent yet.

**Mike Schmidt**: And so, I think this idea has been around maybe seven years
now, something like this.  And so, people were quite excited to see BIPs around
that.  Since the publication of the draft BIPs, I don't think Optech has had any
additional coverage on utreexo, but obviously you can dig into those draft BIPs.
And, Murch, maybe as a BIP editor, have you seen activity there, or have you
been watching any summaries for the folks?

**Mark Erhardt**: The original or the first submission was already very high
quality and very detailed.  Several people have reviewed them in full, me among
them, and most of that review feedback has been addressed already.  There was
another round of review, I think, that is being currently processed.  I think
they are working in parallel on finishing up implementations.  They have more
than one implementation already of it and are working on the BIPs in tandem.
So, I think they are not super-focused on getting it merged immediately now.
They're sort of building up both the code and the BIPs in parallel.  I mean, the
software is out already, I think you can run it already.  There's Floresta and
what is the other one?  Utreexo node, or something?

**Mike Schmidt**: Yeah, utreexod, or something like that.

**Mark Erhardt**: Yes, thank you.  So, you can run it already.  I would probably
not run it as my only node implementation at this moment yet, but they seem to
be developing both the code and the BIPs in parallel.

**Mike Schmidt**: So, that's BIP181, BIP182, and BIP183.  BIP181 describes that
accumulator structure and how it operates.  That's what Murch outlined.  And
then, BIP182 are the rules for validating blocks and transactions using that
data structure.  And then, BIP183 are changes for nodes to pass around that
inclusion proof that I was mentioning that say, "Hey, these UTXOs being spent
are in this data structure".

**Mark Erhardt**: Yeah, so basically the actual cryptographic data structure,
the validation rules and the P2P changes necessary to propagate the stuff.
Yeah, the numbers are assigned, they're not published yet.  So, currently
they're drafts in a PR.  But you can find that draft in, I don't remember the
number from the top of my head, but yeah, it's one PR right now.

_Calculating the selfish mining danger threshold_

**Mike Schmidt**: The next two items are somewhat related.  They're both around
sort of mining incentives and behavior.  The first one was titled, "Calculating
the selfish mining danger threshold", and both of these I think were from
Antoine Poinsot, or darosior.  And he posted in June about an in-depth
explanation involving the math behind the selfish mining attack.  Selfish mining
has been a thing in Bitcoin since the paper in 2013, but Antoine sort of dug in
on the math and posted about that and concluded that, yes indeed, a dishonest
miner that has only 33% of the total network hashrate can be more profitable
than the other miners if they choose to delay announcing their blocks to the
broader network, and then mining on that block without anybody else mining on
that block.

**Mark Erhardt**: Yeah, I think the result was academically already accepted,
and there had been other papers that showed that under certain circumstances and
with other strategies, you might be even able to lower this by a small amount.
I think I saw a number of 31.8 or something.  But I think the 33% threshold is
actually pretty relevant, because you don't have to really do too much crazy
stuff to be more profitable.  So, I assume that's why that might have come up
and why he was interested in looking into it and putting out the math to make
people able to validate it themselves.

_Modeling stale rates by propagation delay and mining centralization_

**Mike Schmidt**: And then, the related item, "Modeling stale rates by
propagation delay and mining centralization", was also from Antoine and that was
in November.  This time, he's posting to Delving analyzing how block propagation
delays systemically advantage larger miners as opposed to smaller miners and he
did some modeling around that.  Murch, am I right when I think about propagation
delay benefiting larger miners has a similar effect as selfish mining?  Am I
right to think that?  Let's say that the network knew it was a block from F2Pool
and they deliberately slowed it down.  Doesn't that have the same sort of effect
as selfish mining at the end of the day?

**Mark Erhardt**: Right.  I mean, the difference is basically the network
naturally already has a delay between people finding blocks and everybody
hearing about it.  And with selfish mining, you extend that advantage by making
the times bigger, whereas you already have that effect just if everybody is
behaving as cooperatively as you you'd want them to, you already get the same
effect to a small degree.  It just takes, whatever, some several hundred
milliseconds, or in the worst case, even a few seconds for blocks to propagate
from one miner to the rest of the network.  And if you're a bigger miner, you
already have a head start on the amount of hash rate that is working towards
making your block part of the best chain, right?  If there's two competing
miners that each have found a block and they find it exactly at the same time,
the bigger miner will have more of the hashrate already working on extending its
chain, whereas the smaller miner starts with a lower amount.  And then, the rest
of the network may be split down halfway, but then still the bigger miner has an
advantage.  And if blocks propagate slowly, there's a bit of a bigger effect
there.

If we could wave our magic wand and make blocks propagate at, well, they're
already propagating at speed of light, but if the latency were zero, the amount
of hashrate would be exactly proportional to the amount of reward, and it would
be perfectly fair, and that would optimally be what we want.  But unfortunately,
we live in a real world where it takes time for the data to be transferred, then
it takes time to validate the data.  And only then, miners start building new
block templates, handing them out to all of the mining pool participants or
machines that work on it.  So, there is always going to be a little delay
between someone finding a block and other people being able to switch over.

**Mike Schmidt**: When the network was smaller, I know that's when compact
blocks came out.  Maybe mining centralization wasn't as big of a concern.  I
think compact blocks at the time, I think it was the release notes, correct me
if I'm wrong, were saying, "Hey, if you're including transactions that aren't
being passed around the open mempool and are being relayed, you're at risk of
slowing your block propagation and being hurt by that fact".  Is that because
the makeup of the network at that time was a little bit more decentralized, and
now we have this maybe more centralized network, and so now we're saying,
actually your bigger miners are advantaged by having their blocks propagate
slowly?  What's the disconnect there?

**Mark Erhardt**: The network was much slower back then.  We have had a lot of
improvements to how quickly blocks propagate.  Nodes tend to have a large
portion of all of the transactions already in the mempool, they now pre-validate
the scripts, they propagate compact blocks instead of whole blocks.  So, back
ten years ago, every block would be sent in full, which meant that you weren't
just giving the recipe how to rebuild the block from your own data, which is
maybe a few kB, but you were actually sending the whole block, which was a MB,
and every hop would send the whole block and validate it from scratch.  So, a
lot of optimizations have been made.  The internet also generally got faster.
So, computers are faster, internet speeds generally, the amount of bandwidth
that is available, increased immensely because all of us are watching and
streaming movies at home all the time.  So, the effort that goes into the
network to propagate the blocks has not shrunk, it has actually increased, but
the network has become way more capable, and that way it works faster and more
reliable.

Yeah, there's a bit of a question of how much it affects the miners, whether the
block is propagated to every node or how long it takes for the blocks to get to
the other miners, right?  And generally, miners tend to be very well connected
now.  So, even if it might take a long while for blocks to be received by all
the nodes, if all the miners or a vast majority of the hashrate has it already
and switched over, this will not affect the profitability of mining as much.
And so, it's a little complicated, but if you model it out, there's some effects
there that it actually helps big miners if it takes longer, because they have a
little more of a head start in the moat; and it hurts small miners if it
propagates slowly.  So, kind of exactly what we don't want, but that's how it
is.

_Compact block reconstructions_

**Mike Schmidt**: Well, on a related note, we highlighted in January, we
revisited 0xB10C's compact block reconstruction statistics.  This is a Delving
thread that 0xB10C posted in late 2024, I believe, and it was updated a few
times in 2025.  And so, we called that out here as it touches on a few of the
things that we've already mentioned, as well as some others, and lays the
groundwork for some future items that we're about to discuss.  But essentially,
his research and what's on the Delving is sort of, his nodes, he runs a series
of monitoring nodes on the network and logs a bunch of information for each of
those nodes and then plots different statistics from those nodes.  And he
actually did call out his monitoring project in a blogpost and explained the
architecture behind that, maybe looking for volunteers to help him run this
monitoring infrastructure for Bitcoin.  So, take a look at that.  That's linked
in our write-up in the end-of-year.

But anyways, he runs this infrastructure and he puts out, in the example of
compact block reconstruction, the rates at which successful reconstructions
occur.  And you can see in a given day, in a given one of his monitoring nodes,
is it sort of like this dark red or bad reconstruction rate, or yellow or orange
or green?  And you can see how things are going in terms of reconstruction
rates.  And one of the things that we touched on was, at some point in the year,
when people decided to use preferential peering and manually set their feerates
low, what they will accept and relay, those transactions were getting mined
because a few people had connected with some miners that had a similar lax
restriction on feerates.  And those were getting into blocks, but they weren't
being relayed on the network.  So, you could actually see that visually.  It's
interesting to see all of a sudden all these nodes get red after being green for
several months.  And they are red because they're getting these blocks full of
transactions, which in some cases, 50% of the blocks they didn't have, so they
had to then say, "I actually need these transactions", and that's an
unsuccessful block reconstruction, or at least you needed to go back and request
more information.

So, he tells a story there, if you look at those series of posts and people
commenting on that, which led to this discussion that we'll get to in a minute
about changing the min_relay_fee_rate default.  But it also led to some other
discussions.  I think your colleague, Murch, is working on compact block
prefilling strategies and commented on that thread.  Do you want to talk a
little bit about that?

**Mark Erhardt**: Yeah, I wanted to first say another thing about the data and
the observation.  So, one of the points that struck me was, usually, even if you
can't reconstruct the block from the compact block announcement, you usually
just have to get a couple of transactions, right?  But in the summer, when we
saw all these low-feerate transactions get mined, at the peak time in average
you had to get 800 kB worth of transaction data that you're missing.  So, with
blocks being on average about 1.6 MB, you literally had to turn around after the
compact block announcement and get half the block in data from your peers.  Now,
that did lead to a lot more nodes having round trips and delays that way.  But
the other thing that was maybe a little surprising is that we didn't see the
rate of stale blocks go up as much as we anticipated.  Apparently, the overall
relay network had gotten so much more robust that even though we saw huge
increases in compact block reconstructions, it did slow down the time until
blocks propagated on the network, but apparently it didn't hurt the propagation
between miners enough to drive up the stale feerates.  Not noticeably.

**Mike Schmidt**: To your point, maybe the miners, these many miners, maybe not
every miner, is more well connected than previously.  So, the fact that this
wasn't happening doesn't mean that they weren't passing it to each other
quickly.

**Mark Erhardt**: Both that they are maybe better connected to each other, but
also if more of the miners were already accepting the transaction in their
mempool, they didn't have that failure to reconstruct the block, because they
already had the transaction.  So, among miners, if they had direct connections,
it might have propagated just like any other block; whereas in the network where
the change hadn't been adopted yet, it would propagate a lot slower.  So, we
would see the statistics of the network in general taking a long time of the
block being propagated, gossiped through the whole network; whereas miners might
have been up and running immediately after the announcement of the block.  So,
obviously it's hard to tell.  And there's a lot of theorizing here, because we
don't actually have all that data, we just see some data points of people that
monitor the whole network with spy nodes.  And we certainly don't have
information on how well connected miners are specifically.  But yeah, so take
that with a grain of salt.

**Mike Schmidt**: And right now, Murch, am I right that these compact block
announcements just, like you say, give the table of contents or the recipe, but
they never include additional transactions?  But there is, in the protocol, the
ability to also, along with that table of contents for the block, include one or
more transactions that you think your peer might have.  Is that right?  And
that's where compact block prefilling would come in?

**Mark Erhardt**: Right.  So, when compact blocks were proposed as a way of
propagating and announcing blocks, it already came with the idea that you could
send the transactions that you expect your peer not to have along with the
announcement of the block.  That would save a round trip, of course, if you
guess correctly and give all the ones that are missing for your peer.  And so,
the protocol always was designed to already enable this.  But after the compact
block announcement was implemented, the pre-filling, which transaction to
forward along with the block announcement, never was implemented.  So when, this
year, people saw that block propagation was slowing down due to missing
transactions, the idea was picked up again and people started taking a good look
at what transactions were missing, what heuristics could perhaps be used to
guess at what transactions to forward to your peers.

Some research was done on how big the packages could be that you could forward
without it turning into another round trip anyway, because internet packages
themselves also have a fixed window size depending on the two peers, how they
are connected, what servers are in between. and so forth.  So, this year there
was quite a bit of testing and experimentation and analysis of that, and it
looks like there's a prototype for compact block prefilling ready.  And the
general idea is, "Well, I know which transactions I was missing.  And If my peer
had had the transactions that I had been missing, they would have announced them
to me, and I would have had them shortly after.  So, my best guess is the peer
is missing at least the transactions that I was missing too".  And so, the main
idea is to just package the transaction that you had to get from a peer in your
announcement of the compact block, and that way hopefully help your peer to be
able to reconstruct immediately, at least from the announcement.

**Mike Schmidt**: That makes a lot of sense.  Are there other heuristics being
discussed?  I think that nodes tell each other the feerates that they'll accept
at, right?  And so, you could, in theory, if there's a block that you just
received that had it below that, you could include those as well, for example.

**Mark Erhardt**: Oh, that's a good point, yeah.  So, we have the feerate filter
P2P message, which allows you to communicate to a peer not to send transactions
below a specific feerate.  Now with the block, of course, included transactions
that are below those feerates.  And you also know what your peer and you have
been announcing to each other, and our node remembers that.  So, you could, in
theory, calculate more precisely what transactions they might be missing.  But
again, you would probably bump into the limits for packages at some point.  And
for the most part, it works best if we can assume that all of our peers have
similar mempool policies as us, and receive and keep the same transactions
around and don't throw them away, because then we can sort of anticipate what
they're missing and what we need to forward to them.  So compact block works
best among node populations that have similar mempool policies.  And yeah, so if
you can just forward what you were missing, that should generally help other
peers that run the same software as you.

_Lowering the minimum relay feerate_

**Mike Schmidt**: Building on that compact block statistics thread is the
lowering minimum relay feerate discussion.  As I sort of already alluded to,
0xB10C's charts show this poor compact block reconstruction during this time
where suddenly, as we say in the write-up, some miners started including
transactions paying less than 1 sat/vB (sat per vbyte), and this happened in the
summer.  So, we named this as the Bitcoin Community Sub-Sat Summer, or
Sub-1-sat/vB Summer, if you want to be verbose.

**Mark Erhardt**: Let's be precise, mononaut, he came up with that idea and
announced, not called out, but announced it to be the Sub-1-sat/vB Summer, and
that stuck.

**Mike Schmidt**: And we referenced one of his tweets in the write-up here,
noting that 85% of the hashrate by July had adopted this lower min feerate,
which is a huge percent of the network.  And then we also note in August, 30% of
confirmed transactions were paying fees below 1 sat/vB.  And so, Bitcoin
developers saw that and said, "Hey, we should change the default in our software
and put it in previous versions as well as a bug fix, because nodes not seeing
transactions when their job is to see transactions and relay blocks is not
good".  Murch, I'm curious if you could comment on your perception of how
Bitcoin developers or Bitcoin Core developers thought that this went, because my
take was that it seemed like Bitcoin Core developers were hard on themselves
that, "Hey, this was a miss, we were caught behind, even though it was a sudden
thing", so I don't know how you could necessarily blame yourself for that.  But
it seemed like Core developers said, "Hey, we sort of dropped the ball on this.
We need to put in a fix and patch it".  Is that your interpretation of it?  Is
that fair, given how spontaneous this movement was?

**Mark Erhardt**: Well, we had already discussed several times in the past years
whether or not we should lower the minimum feerate.  And those discussions, I
think there were at least two or three on the mailing list and maybe a PR on
Bitcoin Core.  In the end, there was just not a lot of support.  Now, it looks
like there was a lot of nodes already on the network that were running with
lower minimum feerates, because that had always been a configuration value.  I
think that perhaps a lot of nodes actually had set it to zero, or another very
low number.  So, when a few people convinced some miners to start including
sub-1-sat/vB transactions, it sort of took over very quickly.  I'd like to
stress again that 85% of the hashrate by end of July and 30% of confirmed
transactions by mid-August, even though none of the popular full node
implementations actually supported sub-1-sat/vB transactions, so neither Libre
Relay, nor Knots, nor Bitcoin Core, were relaying these out of the box.  So,
they only propagated among nodes that had been configured manually to use a
different value.  And even so, 30% of the confirmed transactions were
non-standard in this way.

So, I think in a way, that was how we should expect optimally things to happen,
is that the network adopts it and then we are able to react fairly quickly to it
to mitigate the delays incurred by the changed landscape.  So, in this case, by
early September, we had the 29.1 release that already supported the lower
default minimum feerate.  And so, I think it went pretty quickly and, well,
everybody was caught off guard how quickly it happened, but we reacted fine to
this.  On the other hand, we've been getting, for example, a little bit of the
feedback that we were slow on the RBF changes, where people had been pushing for
a long time that we should always accept replacements, regardless of whether
they're signaling, if they're better.  And that took longer to get adopted, but
then Bitcoin Core also lagged behind a little bit in adopting it and making it
the default.  And then, we also got quite a little bit of feedback on being way
too fast on OP_RETURN this year.  So sometimes, if you're saying that we also
reacted wrong on this one, I think we can't win.

_Increasing or removing Bitcoin Core’s OP_RETURN policy limit_

**Mike Schmidt**: Well, my impression was the Bitcoin Core developers thought
that they were behind on that.  And that does tie into the next item, which is,
"Increasing or removing Bitcoin Core's OP_RETURN policy limit".  And so, you set
the stage for it here.  So, you had full-RBF, that was sort of maybe the users
dragging Core along, but Core sort of knowing that maybe that's where the puck
was going, and slowly rolling out and changing the defaults for full-RBF.  Then,
we have Sub-sat Summer, which was sort of happened much quicker and forced
Core's hand into lowering the default min relay.  And then you have this thing
in the middle here, which is OP_RETURN.  I think a lot of people probably know
the backstory here and all the mechanics of it, but how does the way that
OP_RETURN was handled contrast with those two?

**Mark Erhardt**: The funniest thing about this upset summer was even though the
hashrate adopted it very quickly and 85% of the hashrate started including these
transactions, eventually some of the people that started off that movement
started implementing a minimum of 1 sat/vB again.  And now, we have at least
F2Pool and I think ViaBTC are both still imposing the 1-sat/vB minimum.  So, the
only blocks that aren't full that you're seeing right now, except for empty
blocks right after another block was found, have been ViaBTC and F2Pool and
maybe some other smaller miners that were just not including anything below 1
sat/vB.  So, it's kind of funny that F2Pool, I think, was one of the first ones
that adopted it, and now they're the first one to roll it back.

Okay, sorry, OP_RETURN.  I think one of the biggest parts of the whole debate
around OP_RETURN was how effective mempool policies are and how many nodes on
the network need to adopt mempool policies for them to be effectively imposed on
the network.  And one of the things that is illustrated extremely nicely here by
the Sub-1-sat/vB Summer, is actually it's a very scarily small number of nodes
that need to adopt something for it to roll out.  And we were probably looking
at a few hundred nodes that preferentially peered with each other and used these
lower minimum feerates, and together got this stone rolling in a few weeks.

So, for OP_RETURN, the context is that in April, some developers discovered that
there was an incentive, a mis-incentive maybe, to move towards putting data into
payment outputs in certain circumstances.  So, when you wanted to put data in
outputs specifically, so not like inscriptions that are in the witness section
of inputs, you basically would want to use OP_RETURN, but OP_RETURN is limited
to 80 bytes by standard transactions.  And if you had to put a little more than
80 bytes, which happened to be the case for this one cryptographic protocol
called Citrea, they found for themselves as a solution, "Well, we need standard
transactions, so our transactions go into every block.  So, we'll put a little
data into OP_RETURN and put the rest of the data into payment outputs".  And
this led to a debate of whether OP_RETURN currently still fulfils or actually
helps towards the goals for which it was introduced, and whether these downsides
of it, where it pushes people to put data into -- by the limit being so small,
it might lead to circumstances in which people choose to write data permanently
to the UTXO set instead, how those benefits and downsides weigh up against each
other.

Originally, OP_RETURN was introduced as a way to dissuade people from stuffing
data into payment outputs.  And it was curbed at a small amount because almost
everybody was running default configuration of nodes, there was not a lot of
game in town, there were no direct submissions to mining pools or hardly any.
People manually did that sort of thing, there was no infrastructure for it.  And
blocks were not full.  So, back when OP_RETURN was introduced, people were
worried about it being so cheap and blockspace being so under-demanded that a
lot of the block would get stuffed by OP_RETURN data so early in the network's
history that it would become unnecessarily expensive to keep the whole
blockchain.  Now, in comparison, this sounds familiar I know, but in comparison,
for several years now, almost all the blockspace had been fully demanded.  And
the opportunity to put data into OP_RETURN does not increase the amount of data
that we'll store in the blockchain.  It will, in fact, decrease the amount of
data that would be stored in the blockchain, because OP_RETURN data appears in
outputs, outputs are not discounted.  So, if there's a lot of data written into
outputs, it would reduce the average size of blocks, which are currently about
1.6 MB, because they have a big portion of witness data.

So, having the OP_RETURN limit was not preventing people from putting data into
blockchain anymore.  And it also didn't really significantly increase the
overhead anymore.  So, with this mis-incentive to stuff data into payment
outputs for larger data payloads, people decided, or were discussing, whether or
not to drop enforcement of the OP_RETURN size limit and the limit on OP_RETURN
outputs.  Previously, transactions were only allowed to have a single OP_RETURN
output of up to 80 bytes.  And eventually, the Bitcoin Core project adopted a
default of allowing any number of OP_RETURN outputs and any size of OP_RETURN
outputs.  It's still being limited by the standard transaction size, because it
is perceived as a way more expensive resource than witness data where most of
the data-stuffing is happening right now.  And it is vastly preferable over
putting data into payment outputs.

So, we had this little debate about this for the past eight months on Twitter
mostly.  And, well, I don't want to jinx it, but recently people have been
talking about other stuff like quantum!

**Mike Schmidt**: We're just fighting about quantum now, yeah.  And given what
you've said, this mal-incentive, "Hey, put it in payment outputs if you can't
fit it in OP_RETURN", that same logic applies at 170 bytes, or some people have
discussed lower than removing the limit, you know, 200 bytes, that mal-incentive
stays there unless you remove the limit, right?  Is that a right way to think
about why not cap it at like 200, or something like that?

**Mark Erhardt**: Yeah, if you make it 200, you have exactly the same issue if
someone needs to put 256 bytes.  Then, they'll just put the 56 bytes into
payment outputs right there.  Limiting the OP_RETURN size at consensus I think
does not yield any interesting results, and limiting witness-stuffing at
consensus breaks intended uses of witness data.  So, I just think that the best
way to fight this is by using the Bitcoin Network for the transactions that you
want to see in the Bitcoin blockchain, and by paying what you're willing to pay
for that.  And, well, we've been seeing the interest in these NFTs and images,
and whatever, colored coins and tokens, drastically reduced over the last few
months.  So, I feel very confident that as long as we just send our own
transactions at the feerates we're willing to pay, we'll price out these other
buyers of last resort of blockspace.  And technically, there's data in the
blockchain.  Yes, it maybe increases the blockchain slightly compared to it not
happening at all, but we can't put the genie back into the bottle.

So, we don't really need to fight this at the consensus level when it's already
being priced out by regular small payments.  And it's a nuisance, not a threat
or problem in my opinion.

_Peer block template sharing_

**Mike Schmidt**: Well, some people disagree with that and they have run
different policies as a result on their nodes, whether that's Bitcoin Core or
Bitcoin Knots, which has resulted in a more diverse set of mempool policies on
the network than maybe a year ago, let's say.  And that leads us to our next
item, which is, "Peer block template sharing".  So, AJ Towns saw this occurring,
saw this debate, saw this observation of the network and said, "Hey, maybe
everyone's going to run their policy, but let's continue the effectiveness of
compact blocks by mitigating these divergent mempool policies, by having nodes,
even a non-mining node, broadcast what their block template would be to their
peers in some periodic fashion, so that the peers are aware of what their peers
may think is going to go into a block, therefore maybe storing those
transactions that come in via this new P2P message".  And so, when that recipe
comes in that we talked about earlier, that even if it's not in their mempool
and they're not relaying it, they have it stored so that the compact blocks
could be reconstructed quickly and block propagation could be continuing to be
super-fast.  Is that a fair explanation of template sharing?

**Mark Erhardt**: I think that's a good explanation and I think it's an
interesting proposal.  It's not gotten super much discussion yet, but I think it
would actually work.  And, well, I guess it doesn't really solve the issue of
the people that say, "But I don't want it in my memory even.  I'll accept it in
the block because block is consensus, but I don't want it in my memory".  Well,
this would still push it in their memory.  So, if they're opposed on such
grounds, it would not help, but it would definitely help with block propagation.

**Mike Schmidt**: But even with Knots, I believe that they're using the
extrapool for a lot of this spam, these transactions that match certain
templates of runes or inscriptions, or whatever.  They're throwing it all in the
extrapool, I think.  And so, there is this slightly mysterious data structure,
slightly probably under-fortified data structure to put these things in.  And
so, I guess what AJ is saying is, "Hey, let's have a formal way to pass these
around in a formal data structure to store them, and so we're not sort of
throwing them in the back of the attic where there's some cobwebs and it's maybe
going to bust through the ceiling.  Put it in something a little bit more
robust".  That sounds to me like what he's saying is a mechanism to share these
more formally, and also store them a little bit more robustly, at least that's
my interpretation of it.

**Mark Erhardt**: Yeah, extrapool is not designed at all for this.  And while it
has a limited use, it's not designed, it can handle it pretty well.  So, what
people have been doing as a stopgap measure is use extrapool with extremely
large values, which frankly on lower-end devices is probably unsafe, because it
would allow peers to stuff their extrapool with too much data and their node
would crash.  So, I think that the extrapool is simply not the right tool for
this unless it would get some serious engineering improvements, similar to how
the orphanage was improved recently.  So, it very specifically is intended to
solve this problem and keeps the right transactions and cycles out transactions
from peers that give you way too much data first.  So, having a more formal way
of indicating to your peers what you would perceive to be in the top next block
is, on the one hand, very attractive for fixing the issue where nodes have
vastly diverging views of what should be in the next block; but it also
additionally provides a way of re-announcing transactions.

So, for example, if you have transactions that had been announced a long time
ago and the mempool has cleared down to that level, and many of your peers might
have never heard about that transaction because they weren't online then, or
they run a smaller mempool and have thrown it away, once it becomes part of your
top two blocks, I think is what AJ is proposing to sync up, you would tell your
peers about them again, and they would naturally repropagate on the network.
So, in a way, this is a very interesting way of implementing the rebroadcast
idea that had been discussed a few years ago.  And both from the block
propagation perspective and the transaction rebroadcasting perspective, I think
this is a very interesting proposal.

_Discussions about arbitrary data_

**Mike Schmidt**: After going through Sub-sat Summer and debating about
OP_RETURN, seeing maybe some of the ineffectiveness of policy, given that small
number of nodes' preferential appearing combined with miners who are willing to
be loose with their policy and what they accept in blocks, we move to October
where we have discussions about arbitrary data.  There's a couple of things that
we called out here.  One is an analysis that examined what are the theoretical
constraints on putting data into the UTXO set, even if we had a very restrictive
set of Bitcoin transaction rules.  Say we have a consensus change and you have
to verify that you can spend from this address, and could you still even then
put in arbitrary data?  And the answer was, yes, obviously less data than you
can in the witness now, but you're still able to create such token protocols, or
whatever people are doing these days, even under that restricted set of
transaction rules.

Then also, later in the year, including going through today, there's continuing
discussions focused on whether, should we move this from a policy discussion to
a consensus discussion and make some of these transactions that carry data and
that are using arbitrary data in Bitcoin, should we make them more costly to do,
change the architecture of them, make them illegal in consensus and they have to
kind of change their scheme?  Do we confiscate UTXOs that are of known holders
of these tokens, or destroy them or freeze them or whatever their appropriate
term is?  And so, those discussions are continuing to go on through today.  So,
Murch, maybe you have thoughts on that, but there were six items there that we
just went through, from compact block reconstructions, min relay, OP_RETURN,
template sharing, arbitrary data, and then they all sort of tell this
progression of what happened throughout the year, even though some of those are
a little bit out of order.  I think it tells a story and it ends with consensus
proposed changes, apparently.

**Mark Erhardt**: So, I think one very good thing that is coming out of these
sort of networkwide debates is that there's a lot of learning.  People have a
much better understanding of mempool policies, people have a better
understanding of block propagation and transaction propagation, people know more
about where we have agency and don't have agency, and better understand the
reasoning and how people consider all of these things at the consensus and
policy level.  So, in that sense, I guess this is how bitcoiners learn about the
technical underpinnings, by fighting each other about it.  But I think, having
arrived at the consensus level, some of these proposals seem to be very
ill-conceived, in my opinion.  It strikes me as silly to, on the one hand, be
super-upset about a policy change rolling out within a few months, and then
turning around and proposing a consensus change in a few months to do
drastically more restrictive things and bigger changes to how the network works
on a dime.  And so, I think that, on the one hand, it's nice to see that people
are learning so much.  But on the other hand, this has also hopefully brought
some people to the realization that some of this is more complicated than they
first thought.  And I think some people are still working on figuring that out.

_Private block template marketplace to prevent centralizing MEV_

**Mike Schmidt**: Piggybacking one more time on this thread, arbitrary data can
be used to embed JPEGs but can also be used on certain metaprotocols or
client-side validation tokens.  And so, the next item we're talking about here
is, "Private block template marketplace to prevent centralizing MEV" or Minor
Extractable Value.  And this is the idea that if someone's building some
metaprotocol on Bitcoin, there could be advantages to being a Bitcoin miner and
ordering transactions in a certain way that would benefit somebody who has a
stake in this metaprotocol in some way.  I think one example given in the
MEVpool write-up in this gist is that I think that there was this Babylon
staking protocol on Bitcoin, where people lock up their bitcoins, and only so
many bitcoins were able to be locked up.  Well, who gets to determine that?
Well, the locking is done by a transaction in Bitcoin, so the miners, in theory,
could decide what transactions got into this staking protocol and which did not.
So, maybe the miner puts their own transactions in if they want to be part of
the staking protocol, or maybe they setup a marketplace for the Babylon staking,
wait in line and pay extra money and you get to the front of the line, kind of
thing.

Well, now miners aren't just using power to do a bunch of hashes, they're also
now running the side marketplace for this Babylon protocol thing, for example.
And maybe there's another one and another one and there's different CSV
protocols, you know, there's RGB, there's Shielded CSV that's being developed.

**Mark Erhardt**: And Taproot Assets.

**Mike Schmidt**: Taproot Assets.  You can think, there's opportunity for miners
to make more money.  And the more that the miner is doing things other than
hashing, the more it benefits larger mining pools that have the resources to
have somebody to be able to go build a little Babylon staking website on the
side versus a smaller miner that maybe doesn't have the capabilities to just
spin up a website like that.  And even if they did, who would go there versus
the big miner?

**Mark Erhardt**: Yeah, I think the big problem is access.  You would only give
those transactions to the biggest miners, because you not only want to ensure
privacy, but you also want it to get mined pretty quickly.  So, naturally, this
would be a new source of revenue that only becomes available to the biggest
mining pools.  And it might lead to more people mining on that mining pool
because it has more revenue.  So, it could easily lead to sort of a
self-reinforcing migration of hashrate to the biggest mining pools.  So,
hopefully people don't misunderstand the authors.  They don't want MEV on
Bitcoin, but they've seen MEV on other networks have ruinous effects on the
decentralization of, well, staking in that case.  But now, luckily, Bitcoin by
its own nature doesn't lend itself to protocols that induce MEV as much.  And
also, because of the long interval between blocks, generally the opportunity for
MEV is a lot more restricted.  People are not going to do high-frequency trading
on the Bitcoin blockchain.  That just doesn't make sense.

But these two authors, they seem to think that MEV will eventually come to
Bitcoin in some way or another.  And if it does, they would like Bitcoin not to
end up like Ethereum, where for some time, a single party built all the block
templates.  And so, the idea here would be if there is a format on how to
express your bids on a block template, like to make the bids on reordering the
block template in a way that is interoperable that many people can run it, you
could maybe get a step ahead of it and be able to have to bid on the blockspace
of all the miners at the same time without revealing what you're trying to do
with the transaction, thus keeping the block template building decentralized and
the activity able to go into every block, which curbs out-of-band payments to
some degree, and would keep it fair as a marketplace.  So, the idea is we don't
love MEV, but if MEV comes, let's make it so that the revenue from MEV gets
distributed fairly.  I think that's at least how I understand this paper.

I hope that it remains theoretical for some while because we don't get all this
stuff on Bitcoin too quickly.  But my understanding is that people are working
on looking into how to mitigate MEV when it comes.

**Mike Schmidt**: Yeah, and I think the authors also know that with the push
towards covenants and more expressivity in script, you get the potential for
more of these potential MEV concerns.  And so, maybe that's part of the timing
of why that came out earlier this year.  I know there's a lot of discussion
about pushing for additional scripting capabilities in Bitcoin.  Okay, that
wraps up a bunch of discussion about policy and arbitrary data.

_Fingerprinting nodes using addr messages_

We have a few discussions about vulnerabilities.  First one titled,
"Fingerprinting nodes using addr messages".  This was a post from June.  We had
Daniela and I think Naiyoma on the show to talk about their fingerprinting
research.  So, fingerprinting is the way to be able to tell the information
about a node given some information that that node is disclosing.  In this case,
the node might be on multiple networks, so on IPv4 as well as Tor.  But on both
of those networks, they're leaking some little pieces of information, in this
case, addr messages that they're responding to.  There was a timestamp field and
information about what addresses and what the timestamps were on the different
networks.  These researchers could deduce that, "Hey, that IP4 node and that Tor
node are actually the same node because of what we're seeing in their responses
to these addr messages".  And they recommended a couple of mitigations.  Because
the timestamp was part of the concern, you could remove the timestamps, or you
could randomize those timestamps a bit to make them a little bit less specific
to a particular node, and so you couldn't identify that particular node.

**Mark Erhardt**: Yeah, basically when you ask a node, "Hey, give me more peers,
who do you know on the network?" and two nodes on Tor and on clearnet respond
with the same list or a huge overlap, they're probably the same node.  That's
the general idea there.  And it happens to work even better than you'd
anticipated.  They told us that a few people tested them and said, "Here's my
Tor IP or my clearnet IP.  Tell me my corresponding other", and they got 100% of
them right.  So, yeah, it's good that they found this, and hopefully some of the
mitigations get rolled out soon.

_Partitioning and eclipse attacks using BGP interception_

**Mike Schmidt**: "Partitioning and eclipse attacks using BGP interception".
Cedarctic, this was a post to Delving that we covered in September.  We had
Cedarctic on the show to talk about this, but the BGP is Border Gateway
Protocol, sort of like, I don't know, the master level internet lookups, "Where
do I go if I want to talk to this IP address?"  And there's this idea of
hijacking that's been around before, BGP hijacking.  This is different.  This is
a riff off of that called BGP interception, in which an attacker could
essentially quasi-man-in-the-middle communications between a node and its peers.
I think the BGP interception attack was more targeted, that was more like
network partitioning.  And this BGP interception is a little bit more eclipse
attack a particular node by slowly taking over the connections that that node
has.  And then, you essentially have eclipsed that node, that node has no way to
get the honest chain tip, and you can potentially feed them bad information or
just withhold information from them, in the case of Lightning, that even just
withholding information can be quite devastating.  So, he walked us through that
attack.  Pretty crazy Delving post.  Murch, I know you spoke with him on the
show.  Anything else that you'd add from that discussion?

**Mark Erhardt**: So, maybe just a couple of things.  The BGP is basically, on
the internet, not all servers are connected to each other, so they tend to be
several hops apart.  And it's sort of just a set of signposts.  Every node sort
of knows, "I have to send stuff in that direction to eventually reach that IP".
So, they sort of don't know where that other server is exactly, but they know
who the right next person is to get closer to it.  And the way this attack works
is by sort of seeding false signposts and redirecting traffic to the attacker
instead of the actual counterparty of the node.  Yeah, that's maybe all I have
here.

_Differential fuzzing of Bitcoin and LN implementations_

**Mike Schmidt**: And we have one more bug-related item that we pulled out of
the monthlies, which was, "Differential fuzzing of Bitcoin and Lightning
implementations".  This was Bruno Garcia, who does a lot of work on bitcoinfuzz,
which is a library to do fuzz testing against Bitcoin and Lightning
implementations and libraries.  Cool post outlining what's supported, what they
found, different bugs.  in different libraries, which libraries and
implementations are supported, calls to action for maintainers of different
Bitcoin projects to be part of this bitcoinfuzz initiative, and also obviously
developers to contribute.

One thing that we're not going to touch on and go through in this show today is
the list of vulnerabilities.  I think t-bast touched on it a little bit in a
very positive way, saying hardening Lightning implementations, things like
bitcoinfuzz, and some of the work that Matt Morehouse has been on the show to
talk about this year has shown that anything that these Lightning
implementations can do to increase their security, the better, and that sort of
ties in here.  We're not going to go through all the vulnerabilities this year.
But as you can see from our write-up, 35 bugs in Bitcoin-related projects from
bitcoinfuzz alone.  Not all those probably made it to Optech as critical
vulnerabilities, but I think it's an interesting effort that I think if people
are interested in Bitcoin and want to contribute in some way, this might be an
easier way to get your foot in the door in building things for Bitcoin, than
maybe getting a contribution to a cryptographic library or Bitcoin Core, or
something.

**Mark Erhardt**: Yeah, maybe here the general idea is, so for fuzz testing,
you're just programmatically, pseudo-randomly traversing all of the inputs to
something.  And differential fuzzing here means you're fuzzing several
implementations at the same time, and you expect them to have the same responses
to the same things.  So, for example, if you pass a P2P message to one node, it
should accept it and return the acceptance response, just like another node
would do the same.  And if one of them, for example, accepts a message and the
other one doesn't, you have found a bug in one or the other.  You don't know yet
which one maybe, but they should behave the same way, well, if they support the
same feature that you're testing.  So, this is the general idea here, is to make
sure that different implementations behave the same way, given the same inputs.

_Garbled locks_

**Mike Schmidt**: Moving on, we are going to, "Garbled locks", or also garbled
circuits.  This was an item from June.  There was one in August as well, both
based on BitVM-related research that's been going on.  Both approaches use
garbled circuits.  One was from Robin Linus that used an idea from Jeremy Rubin
using garbled circuits.  And then later, Liam Eagen did something similar for
BitVM and this is called garbled locks or Glocks.  So, what these things achieve
are smaller onchain space being required for things like BitVM in certain
conditions. they need to post things to Bitcoin.  And I think in the Jeremy
Rubin, Robin Linus example was something like 1,000 times smaller; Liam Eagen's,
something like 500 times smaller in onchain data.  So, those are both huge
reductions in the requirements that BitVM has for blockspace.

**Mark Erhardt**: I dimly remember that Glocks was even more efficient than
garbled locks.  So, the interesting new idea that Liam had compared to the
garbled locks was there was some sort of data that we already expected the other
party to have.  And if we considered that they already had that data, we could
make a different trade-off that didn't have any loss of privacy.  And that
reduced the input size even further.

**Mike Schmidt**: It's multiple TB of offchain data setup.  So, you take the hit
on a one-time setup and you have this multiple-TB blob.  I don't know what would
be in there.  But then you're able to do this, I'm quoting our quote from the
newsletter about Robin Linus, it says, "1,000 times faster than the previous
design".

**Mark Erhardt**: Oh, I'm sorry, yeah, those are two different things.  One is
1,000 times more efficient in computation, I think, verification time is 1,000
times more efficient.  But the Glock is 550 times reduction of onchain data.  I
think the onchain data in garbled locks was still pretty big, much smaller than
the original BitVM idea and BitVM2, but the Glocks were something like 80 bytes
or so onchain, which was actually a palatable amount of data.

**Mike Schmidt**: BitVM needs this, maybe for folks who aren't up to speed on
BitVM, of which I'm one, but we could at least say that BitVM wants to have
these Bitcoin-verified computation or contracts without having to change
Bitcoin's consensus rule.  So, you commit to sort of a program, the result of
this offchain computation, and you want to commit to that onchain, and then you
can actually prove that if somebody violates that offchain contract by actually
starting to go through the execution of that, which, as you can imagine, would
result in these huge kind of numbers that BitVM supposedly needed.  But now, if
you do this huge multi-TB setup offline, you can actually shortcut it to have
quite a reduction in onchain data.

**Mark Erhardt**: I think the big takeaway is this is very novel research that
is still in flux, and we're not going to see any of this onchain in earlier than
three years or so.  So, probably there's going to be more improvements and new
ideas until then.

_Details about the design of Simplicity_

**Mike Schmidt**: We have a couple of consensus-related items that didn't go
into the soft fork callout.  One wasn't necessarily a proposal, an active
proposal for Bitcoin consensus, but it was around Simplicity, "Details about the
design of Simplicity".  So, Simplicity is, you can think of like a wholesale
replacement for Bitcoin Script that runs on the Liquid Network, and that
activated earlier this year.  And in response to that activation, Russell
O'Connor, who has essentially driven that Simplicity project for several years,
made a bunch of posts to Delving about the philosophy of Simplicity.  There's
five posts in total talking about things like type system, basic expressions,
etc.  We covered the first three posts in the newsletter, but since then there's
actually been two more.  There's a part IV and part V on Delving, getting into
everything you could possibly want to know about the Simplicity language.  What
do you think of Simplicity, Murch, is it coming to Bitcoin anytime soon?

**Mark Erhardt**: I think that it actually came faster to Liquid than I thought,
because they just merged it into Liquid recently.  So, I think that it would be
somewhat difficult to insert into Bitcoin because the entire code change is
enormous, but most of it is provably correct.  So, there'll be dragons there.
So, people would have to make a proper proposal, it would have to get a lot of
review.  I don't even know how you review something that is several 10,000 lines
of code, probably more like over 100,000 lines of code.  But if it's mostly
provably right, maybe there's an avenue, but it's sort of already
Bitcoin-ecosystem-adjacent by being in Liquid.  So, if it gets adopted in Liquid
and gets a lot of use there, that might be more reason to consider using it in
Bitcoin.  But so far, I feel like we haven't really even started the
conversation on that one.

**Mike Schmidt**: Yeah, it's a tremendous engineering effort.  I think what your
point, your latter point there that, "Hey, I'm curious to see how much
Simplicity is used on Liquid".  And if there's killer apps that people are
using, even with it being in the Liquid Network and not on Bitcoin, then maybe
that's a signal there.  And whether you bring Simplicity wholesale or there's
pieces of those killer apps that you use Simplicity for that you can bring,
would be interesting to see.

_DahLIAS interactive aggregate signatures_

Another soft-fork-related discussion, DahLIAS, which is interactive aggregate
signatures.  This was a DahLIAS paper posted in April by Jonas Nick, Tim
Ruffing, and Yannick Seurin.  This talks about what we've heard of CISA
(cross-input signature aggregation) or aggregate signatures.  This is the
whitepaper about that.  So, if you think normally in a Bitcoin transaction,
let's say you have a single-signature wallet, so you have a single message which
is a transaction and a single signature.  And then, you have things like MuSig,
where you have a single message and you have multiple signatures.  Or even the
same with threshold signatures.  Then, you have this idea of aggregate
signatures, which is multiple people signing their own message or transaction,
and putting those multiple messages in those multiple signatures, aggregating
the signatures together.  And so, you end up with this 64-byte aggregate
signature.  It looks like a schnorr signature, but it's not technically a
schnorr signature, it's its own aggregate signature that happens to be 64 bytes.
And this would be used in something like CISA.  If that proposal comes to
fruition, it would use this DahLIAS signature scheme in theory, or could use it.
And so, you have essentially, let's say you have five signatures, those five
signatures become 64 bytes essentially.

So, that can incentivize things like coinjoins where you have many people
putting in coins and you can amortize that signature across many different users
and they pay less.  Maybe they're interested in the privacy benefits of coinjoin
or maybe they're just interested in paying lower transaction fees.  So, it's an
interesting idea and DahLIAS is a stepping point along that evolution.

**Mark Erhardt**: Yeah, just to be clear, this would only apply to multiple
inputs on the same transaction, as far as I understand.  So, in a way, they do
sign the same message, in the sense that they commit to the same transaction,
but from the context of different inputs.  There is another whole thing where
you can aggregate signatures from various transactions that other networks are
using.  But in this case, we're only talking about multiple inputs to the same
transaction.  This could still be a decent reduction in the overall witness
data, because of course currently every input usually needs at least one
signature.  But if you only need a single signature across many inputs, you
could save, at the asymptotic limit, all of the signatures minus one.  So, you'd
have an average signature size of almost zero at that point, talking about very
many inputs.

**Mike Schmidt**: Yeah, you're right.  Yeah, I think when I was saying those
multiple messages and multiple signatures, I did say different transactions.
Yes, different inputs, so I believe they're still signing different messages to
authorize those spending of those different inputs.

**Mark Erhardt**: Yeah, otherwise you would be able to take a signature from one
input to another input, if they spend from the same public key.  But luckily, I
don't think that's possible.

_Bitcoin Forking Guide_

**Mike Schmidt**: We're getting close to the end.  Okay, so we talked about a
few different times in this show, in our previous part of this show, protocol
changes.  And there were two topics that we covered in the end-of-year that were
related to consensus-building and consensus-changing.  The first one is the,
"Bitcoin Forking Guide".  This was a little, mini website guide that AJ Towns
put out on his perspective of how to build consensus for a protocol change to
Bitcoin.  I think Steve Lee and the bcap people had something similar in terms
of the different stakeholders and what these different stakeholders may be
thinking about, and how changes to consensus might be thought about in a more
rigorous fashion.  This is AJ Towns' version/maybe even reaction to that
original bcap idea, and he has these different four steps: research and
development, power user exploration, industry evaluation, and investor review.
Check out, he's got a little website that you can click through with some
graphics and some very easy-to-read text.  This is not an AJ Towns
super-technical blogpost, or anything like that.  So, that was the first kind of
discussion of how you might get a consensus change put into Bitcoin.  Anything
on that one, Murch, before we go to your version?

**Mark Erhardt**: Yeah, just I was going to say, I think it was more of a
reaction.  I think it was deliberately written after bcap came out, because he
disagreed on some of the conclusions and the way it was framed.  And it's also a
much shorter document.  So, yeah, I would agree with the reaction description
more than a very similar document.  They're similar in what they're trying to
address, but rather different in their conclusions and descriptions.

_BIP3 and the BIP process _

**Mike Schmidt**: "BIP3 and the BIP process".  Murch, we've talked a little bit
about BIP3 recently.  Do you want to talk about BIP3 more?  What's BIP3?  Maybe
pretend people haven't listened all year or read the newsletter.  Give them the
headline of what BIP3 is and then we can get, maybe for the folks who do listen
regularly, an update if there is one on BIP3.

**Mark Erhardt**: So, one way of how you might propose changing the Bitcoin
Network at a consensus level, or how you might communicate about various cool
wallet features or P2P features that you're trying to introduce to the network,
is to write a Bitcoin Improvement Proposal (BIP).  BIPs are formal documents
that specify how some feature or idea would work, and we have 187 of them,
something like 70 of them have been sunset; the other ones are still in flight.
And we had been using a process that was written in 2016 to guide would-be BIP
authors through how to create such a BIP.  And now, a little bit of time has
passed since 2016, and there are some parts of the old process that never really
got adopted, or it sort of feels like it was a little too hung up on consensus
changes and making the process fit for people proposing consensus updates.  But
really, we're seeing a lot more BIPs that deal with key management or how to
create output scripts, and so forth.

So, I have been putting a lot of time in the, I think it's over a year now,
yeah, one-and-a-half years or so, to sort of go over the old guidance for the
BIPs process and write up a new document that revisits a bunch of the process,
changes it in a little way here and there, and make some improvements.  And
potentially, this is coming finally to a point where people are interested in
adopting it.  I recently proposed that, well, from my perspective, it was sort
of getting done earlier this year.  And then, we had several more rounds of
reviews, and now I hope it's also getting closer to done from other people's
perspective.  So, in November, I proposed that we could activate it if people
support activation after another four weeks or so of review, in case you hadn't
looked at it yet.  Obviously, when you start saying the big 'A' word, suddenly
people listen up and read it, and then there was more feedback and more tweaks
to be made to the document.

All of those review comments have now been addressed, and I'm asking yet again,
"Hey, in case you're interested in BIPs and you're reading that sort of stuff,
if you think that BIP3 is ready and is an improvement, please chime in on the
mailing list and say that we should start using it, and then maybe next year we
can start to do so".

_Bitcoin Kernel C API introduced_

**Mike Schmidt**: Last but not least item for the 2025 year-in-review, assuming
that we didn't skip anything, other than the notable skipping of all the
vulnerabilities and listing out all the infrastructure software updates, last
but not least, "Bitcoin Kernel C API introduced".  This was from November.  We
didn't cover it in a News item, but it was a PR Bitcoin Core #30595, which
introduces the kernel C header.  It's a way to interface with Bitcoin Core's
block validation.  There's a bunch of examples of what people are building with
this.  You can use kernel to build an alternate node implementation, we list in
the newsletter, also an Electrum server index builder, a silent payment scanner,
a block analysis tool, script validation accelerator.  There's bindings for
Rust, Go, JDK, C-sharp, and Python.  I think a lot of people seem excited to
have their hands on this.  Even people were playing with this before this PR was
merged.  They want to do Bitcoin consensus-y things, and there's a lot of
different ways to do it with these SDKs.  I feel like if we did this item
earlier in the newsletter and we had TheCharlatan on, we could probably go a
half hour with him, and we have.  Given that it's on hour five, we're probably
not going to do it total justice, but, Murch, maybe you could say some things
about kernel as well.  **Mark Erhardt**: Yeah, basically the main idea is, I'm
sure a lot of people are aware of that quote by Satoshi.  He doesn't think that
another node implementation is ever going to be a good idea.  And I don't want
to speak for Satoshi, but one of the big concerns is that a lot of the consensus
rules are somewhat complicated, and sometimes we don't even know about essential
consensus rules.  So, we, for example, had a fork in 2013 because a database was
exchanged under the hood from one format to another, and suddenly there was a
block mined that was valid in one database format but hit a limit in another
database format, and the network split, right?  That was not a consensus rule
people had on their radar, but it was de facto a consensus rule, because the new
implementation of Bitcoin Core, well, just Bitcoin back then, behaved different
than the prior version of Bitcoin.  And so, the idea here is to pull out all the
consensus-relevant pieces of code and ship them as a library, essentially, that
other projects can consume.  And then, if they build their node or other
software around it, their Bitcoin project around the kernel, consuming the
kernel, they would all be running the same consensus rules under the hood, and
one big source of potential net splits or consensus failures would be mitigated.

So, some Bitcoin Core contributors have been working on this for many years.
And this is coming finally to a point where other projects are starting to build
on it.  So, pretty exciting.  Another one of those ten-year projects that is
finally paying off, and yeah, I'm curious to see what people build with it.

**Mike Schmidt**: Yeah, super-exciting, a lot of work.  Like you mentioned, many
years, Carl Dong working on this, Charlatan working on this, other people now
seeing the momentum building and jumping in and providing feedback and testing
in different libraries on top.  It seems optimistic and it seems like it will
get more traction in the broader community than the Libbitcoin consensus library
did.  I wasn't around necessarily for that, so I can't say definitively, but it
does seem like kernel's got a little bit more excitement about it.

**Mark Erhardt**: Yeah.  I mean, even when Carl Dong was working on this, this
was already Bitcoin Kernel.  This was already a restart of a prior project.  So,
other people have been working on this for many years, even before Carl.  So,
yeah.

**Mike Schmidt**: Oh, I didn't know that.

**Mark Erhardt**: Libbitcoin consensus was the predecessor.  And I think Matt
Corallo kicked that off.  And I would want to say that it was probably in the
2015 sort of, maybe 2016 sort of range.

**Mike Schmidt**: Libbitcoin consensus was totally separate though, right, than
kernel?

**Mark Erhardt**: Yeah, exactly.  But it was the same idea, another attempt at
the same idea.

**Mike Schmidt**: Yeah, yeah, exactly.  Okay.  We did it, Murch.  We want to
thank you all.  Hopefully, we didn't put you all to sleep, unless you put this
on so that you can go to sleep!

**Mark Erhardt**: I mean, five hours, is that a new record?

**Mike Schmidt**: I think so.  I have to look back at the last year's, but yeah,
it was fun.  It was great that we had t-bast on.  Pieter and Rearden, thank you
guys for your time.  Murch, thanks for co-hosting.  Thank you everybody for
listening and happy holidays, Happy New Year.  No podcast or newsletter next
week.  We all get some time off from Bitcoin development to rest and recharge.

_Bitcoin Optech_

**Mark Erhardt**: Maybe two shoutouts.  Thank you, Mike, for always putting in a
lot of effort to prep for these and all the work that you're now doing
coordinating the newsletter.  And thanks again to Dave Harding, who had been
writing most of the newsletter as the primary author for most of the time that
Optech has existed, who recently started not regularly contributing anymore.

**Mike Schmidt**: 376 episodes or newsletters, 376.

**Mark Erhardt**: Which is, well, until a few months ago.  Anyway, Dave has been
doing an immense job here and he was so plugged into all of these topics and
such a good writer.  We are struggling with many more people to replicate
something close to what he output, and we're extremely grateful.

**Mike Schmidt**: 2018 the newsletter started with Newsletter #0, and Dave was
the primary author all the way through 375, I believe.  Obviously, some of us
were contributing along the way but, Dave, spent a lot of time on these
newsletters.  You can see him interacting with people on the email list, on
these mailing lists and Delving posts that he is trying to understand so that he
could write it for us.  He put a lot of time in that.  Every week since 2018,
with the exception of this week off that we have ahead of us today, he would do
that.  So, yeah, thank you, Dave.

{% include references.md %}
