---
title: 'Bitcoin Optech Newsletter #398 Recap Podcast'
permalink: /en/podcast/2026/03/31/
reference: /en/newsletters/2026/03/27/
name: 2026-03-31-recap
slug: 2026-03-31-recap
type: podcast
layout: podcast-episode
lang: en
---
Mike Schmidt and Gustavo Flores Echaiz are joined by Dusty Daemon to discuss [Newsletter
#398]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-2-31/421144992-44100-2-cbf3924088c47.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #398 Recap.
Today, we have some Selected questions and answers from the Stack Exchange in
our monthly segment; we have Releases and release candidates; and we also have
some Notable code and documentation changes, including the splicing BOLT being
merged into the Lightning spec.  This week, Gustavo and I are joined
appropriately by Dusty.  Dusty, who are you?  What have you been doing the last
few years?

**Dusty Daemon**: I'm Dusty Daemon, I've been doing splicing for years now.

**Mike Schmidt**: Well, I guess you're the right person to have on today then.

**Dusty Daemon**: I like to think so, I've been doing longer than anyone else.
So, yeah, let's go.

_BOLTs #1160_

**Mike Schmidt**: All right.  Well, for those listening along, we're going to
actually jump down to the very last item in the newsletter, which is under the
Notable code and documentation changes, BOLTs #1160, which merges the splicing
protocol into the Lightning spec.  Dusty, people are very excited about this.
We've had you on before, we've also talked about splicing, people maybe even
using tooling and wallets that have splicing.  So, what does it mean that it's
now in the spec?  Why is it there now?  Maybe give us the lay of the land and
you can maybe do a quick overview of what is splicing and why people are
excited.

**Dusty Daemon**: Absolutely.  So, the specs in Lightning are a little different
than the other places.  When the spec gets merged, it's different than the BIP
process.  When a spec gets merged, it's because it's actually implemented and
tested cross implementations.  So, the analogy would be like browsers, right?
If you have a certain new HTML feature that works on two browsers at least, then
it goes into the spec.  So, the spec merging is like the final process.  It's
like, spicing's done, it's out there.  We actually got three to go through with
this one, which is awesome, more than the two that's normally required.  So, the
spec's fully in.  You want me to go into what is splicing?  Should I just do a
high level on that?

**Mike Schmidt**: Yeah, I think a high level would be good.

**Dusty Daemon**: Cool.  So, in the beginning, there were Lightning channels,
the very beginning.  I'm going to gloss over how Lightning works, cause that can
get a little complicated, a little tangent-y.  But Lightning works through
channels.  So, when you are entering the LN, you make a channel to somebody, and
then you use the channel hops to get places in Lightning.  And the thing about
these channels is you have to put bitcoin in the channel.  So, the amount of
throughput the channel can handle is limited by how much bitcoin you put in.
And so, from the beginning, there was this idea of like, "Hey, what if we want
to change that throughput number?"  It turns out it's just really complicated.
It's kind of like changing the size of the wings on a plane while it's flying,
sort of deal.  So, it got kind of got pushed off and pushed off until
eventually, a consensus was reached on a solution.

Splicing, at its core, allows you to change the size of a Lightning channel.
You could simplify the explanation down to just that.  But that does hide some
of the awesome, magical things that become possible.  And just to go real quick
over one of them, as an easy example.  So, if you wanted to, say, make an
onchain payment to a Bitcoin address from your Lightning funds, you could do
that by reducing the size of your channel for the amount of onchain payment you
want to do, and also vice versa.  So, even though all we're doing is changing
the size of the channel, it exposes a bunch of really cool features, and that's
just a taste.  There's plenty more that are possible afterwards.

**Mike Schmidt**: Awesome.  Well, I know you've spearheaded a lot of the work
here, and so I guess even though, like you said, splicing has sort of been
rolled out to several implementations already, this is a nice celebration for
you, and I'm sure listeners can hear your excitement.  Are there other
interesting uses?  I mean, you gave the splicing-out, I guess, example.  You
could splice-out and make a payment.  Given that this has been around now and
some people have been toying with it for a while, what are the most common
cases?  Is it LSPs, rebalancing channels and things like that?  What have you
seen to the degree that you've heard feedback or observed?

**Dusty Daemon**: So, knowing what's most popular is always hard because
Lightning is so private.  So, you've got to do some speculation, right, there's
some guesstimation here.  But there's two major ones I would point to.  One is
the Phoenix iPhone wallet, which is an app for you to be able to have a
Lightning wallet that makes payments.  And before integrating splicing, they
were trying to make a seamless process.  So, whenever you ran out of funds and
you wanted to add some funds to your Lightning balance, you'd have to send some
funds in, it would open a new channel.  I remember looking at one buddy's app
and I was looking in the settings, and you can see how many channels he had.  He
had like 20-something channels for one little wallet, and that's a lot to
manage.  The chain fees start adding up, and there can be complicated issues
with keeping that many channels open when you're just trying to do a payment.

So, Phoenix integrated splicing, and now they have one channel.  So, in the back
end, it just simplifies all kinds of things.  But for the user, that translates
to it's cheaper.  Like, when they announced it, they actually literally cut
their fees in half, I believe.  And it runs faster and more smoothly.  There's
less weird cases you can get stuck in.  So, that's a big one that I think is
pretty huge.  It's just Lightning wallets get a lot better with those collection
of features.  And on the other side is, if you're a big Lightning routing node
and you're doing a lot of throughput, those people have to do a lot of work
balancing all their channels.  So, they're the guys in the background making
sure payments can actually get through the entire network.  And they constantly
are trying to analyze where it's going, try to move the channels to be in the
right spot, get liquidity where it needs to be, and they have to open and close
channels and move funds around quite a lot, particularly when you have one-way
flows.

So, imagine a scenario where people are making remittance payments from the US
over to El Salvador, or something.  You get a lot of one-way flows.  One-way
flows are the hardest demands for those guys.  And splicing, well, it doesn't
solve that problem completely.  It is a massive tool.  You can more than double
your ability to throughput more bitcoin through your channels that are going one
way, with the same amount of funds, without having to go as crazy.  So, I think
those are the two categories today that I'm sure are happening in mass.  And I
think we're going to see a lot more coming up, which is actually just jumping
ahead a bit.  That's what I'm getting ready to work on now.  Now that splicing
is done, ratified in the spec, there are a lot of other cool ancillary things we
can start to do that I'm going to be working on soon.

**Mike Schmidt**: Are these things that you're looking at, these next things, is
this more like things using splicing as it is today, or is this like splicing
v2?

**Dusty Daemon**: Splicing as it is today.  It's kind of like how, if we use
taproot as an example in Bitcoin, and it enabled a whole bunch of stuff to be
done, there's a lot of things in taproot we haven't even used yet that are
possible to use.  Splicing is in a similar state.  There's a whole lot of things
we can do with it that are possible now that it's on the network and major
implementations have it and it's getting deployed, that I want to start
tackling.  One big one is I want to start merging more transactions.  Splicing
is written in an open transaction sort of protocol, where we can add arbitrary
inputs and outputs to them, and this allows us to start merging all kinds of
things.  The easiest example would be merging two splices.  So, if I want to
splice two channels at once, that can be one transaction, there's no need for it
to be two.  And that's actually something I got in the last Core Lighting (CLN)
release, is now you can start doing n splices at once, which is awesome.

But things I'm ready to do is start adding in channel opens and also arbitrary
transactions.  Like, if you're doing an onchain payment, maybe one day, like, a
payjoin, there's no reason that can't also be a splice.  There's a theoretical
world where every onchain transaction is also merged with the splice.
Everything's a splice at some point, right?  These are some possibilities.  But
even if we get 10% of the way there, like if 10% of blocks are one single
splice, that's an awesome world.  We've added more privacy, we've made
transactions cheaper, more efficient chain usage.  And the other thing that I
think is not obvious at first is, if you can make it cheaper to join a
coinjoin-like transaction, you're going to get a larger set of people doing it
that are just doing it to save money.  And that makes the anonymity, I can never
say this word right, the anonymity set, it makes that set much better and bigger
by having more people in it, making the privacy gains a lot more awesome.

So, that's some of the things, and there's some other little things too.  And
I'm really excited to both celebrate splicing that's done and look ahead to
what's possible to do now, and some other stuff too.

**Mike Schmidt**: I can interpret that a lot of users are listening to your
energy and your cool ideas and saying, "Well, like what?  What are these
projects called?  Where?  Is there an umbrella thing that this guy's working
under?  How do I jump in on this?"  And so, is there a place to point people to
yet, or is this sort of still in your head?

**Dusty Daemon**: Well, it depends on the level you want to go.  You can follow
my GitHub, read my PRs, maybe review them.  I'm always looking for more reviews
of PRs.  But of course, that requires a level of technical deep competency.  But
to follow it, I think just keep posted.  These are all still in the heavy dev
stage, a lot of these ideas, and eventually they're going to start becoming --
there's a little bit of PR work that has to be done, right?  Like, I'd love to
get payjoin involved, I'd love to look at, I don't know, JoinMarket, what
they're doing, I haven't really looked through those very much; and eventually,
get wallet providers.  So, those are some things.  I think the way this stuff
is, this is really like core infrastructure stuff.  This is the foundation of
things.  And other code will end up using it to build the building on top of the
foundation.  So, it's kind of hard to be too much of a layman.  I mean, I guess
just follow content like this if you want to.  That's probably one of the best
places I can think of for that.

**Mike Schmidt**: I have a bit of a curveball for you here.

**Dusty Daemon**: Okay, I'm ready.  All right, curveball, let's go.

**Mike Schmidt**: Where's the quote?  Okay, so we had ZmnSCPxj on a couple of
months ago.  And he says, "Yeah, so basically my opinion here is that we got
nerd-sniped with splicing, but we should probably have focused on swapping
first.  Because it turns out, if you go down to it, it's actually much smaller
in block space to use swapping than splicing, even this mythical batch splicing,
which is theoretical, but which is probably not going to get implemented anytime
soon".  So, there's a few different ways to go with that.  But the reason that I
actually just brought that up while we're talking, because I remember him saying
critical, I don't know, things about splicing.  And I wondered if you are
familiar with his thoughts beyond just that quote, and what your take is on
that?

**Dusty Daemon**: Unfortunately, I'm not too familiar with his opinions on that,
but I love his comment that it's this mythical thing that mythically one day,
we'll have these joined splices.  And in a certain sense, he's absolutely right,
it's a difficult goal to get to.  And there are some problems to solve along the
way that there's no clear solution, particularly like reputation.  So, if
somebody starts joining splices and they're a bad actor, they could, say, add
inputs and outputs to a transaction that they never signed, right?  It's a form
of DDoS sort of, it's different than DDoS, but it's got that vibe to it.  That's
a problem has to be solved.  And one of the issues is because everything's so
private, forming reputation is difficult.  Like, I might be doing a splice with
Mike, who is doing with someone else, and that person is adding in malicious
inputs and outputs.  I can't tell if it's Mike or that guy.  This is a real
problem to be solved.  And I think in the sense that he's saying it's a long way
off and it's hard to get to, he's absolutely correct.  I still think we can,
it'll just take a while.

The first part, I'm not sure what benefits he's hoping for from the swap over
splice.  I'd have to see a little more detail.

**Mike Schmidt**: It sounds like onchain space maybe.

**Dusty Daemon**: I'd have to look at it more.  I'm not familiar with anything
like that, but it's entirely possible that maybe one day, with the splice merge,
something he's talking about would be better than splice, but it's not today.
But without more details, I couldn't really speak to it, you know.

**Mike Schmidt**: Okay, yeah, sorry, I didn't mean to curveball, and we don't
like to necessarily do throwdowns here on Optech, but I figured I would bring
that up, because I knew you'd be a good sport about it.

**Dusty Daemon**: All good!

**Mike Schmidt**: Okay, well I think we will incidentally get into some of the
technicals around splicing, because there are a few PRs this week that are
around splicing.  And of course, Dusty did not author all these PRs and is not
familiar with all these implementations' nuance, but he can maybe provide some
color commentary.  So, maybe we'll just quickly pivot and Gustavo can pull out
the splice-related PRs, do his summary, and then we can have the color
commentary from Dusty.

**Dusty Daemon**: Great, yeah, my first time seeing them.  So, this is going to
be a fun, genuine reaction.

_Core Lightning #8450_

**Gustavo Flores Echaiz**: Perfect.  All right, so this week we have a few PRs
related to splicing, a few that you actually authored, so we have three about
CLN, one on LDK and, yeah, that's it.  So, the ones on CLN which you authored,
and which we'd like you to give us a bit more details are, the first one is
#8450 which I think that's the extension of the scripting engine of CLN, that
allows it to then implement the splicein and spliceout commands that are in the
follow-up PRs, right?  But here, there are a few concepts that are interesting
that we would like you to go more into, one being cross-channel splices, which
you kind of already discussed about; but the other one being multi-channel
splices.  Some people maybe don't understand the difference between these two
concepts, if there is any.  Maybe they're closer than they would be.  And also,
I think an interesting problem that was solved by this PR was the dynamic fee
calculation, because you kind of get into a loop and into a circular dependency
when you add additional inputs, so you increase the transaction weight for the
required fee, but then you might require additional inputs to pay those fees.
And that's basically what this PR is about.  So, please tell us, help us
understand the difference between these concepts and how this worked, since you
are the author behind this PR.

**Dusty Daemon**: Absolutely, I love that summary.  So, starting from the top
there, a cross-channel splice would be splicing funds from one channel to
another; and a multi-channel splice would be a larger concept that cross-splice
would be one of.  So, multi-channel splice just means there's more than one
channel involved.  So, it could be a cross-splice, it could be two
cross-splices, it could be a triple.  So, you could do something, for example,
like take funds from one channel, splice it into three other channels, right?
Or you could, say, take funds from two channels and then make an onchain payment
and put some funds in your cold storage.  That's not necessarily across two
channels, but it'd be a multi-channel splice.

Multi-channel splicing is really what really tests your splicing code, can it
handle this, because there's so much interleaving of complex steps that have all
been theorized, but in practice are quite difficult to get right.  So, that's
something really exciting in this PR, is it's adding the cross-channel abilities
to the splice group.  Then, of course, building test cases for that, is
basically the ultimate rigorous test of the entire splicing system.  So, I'm
really excited to get this in and have it working as well as it is.

Then, you were asking about, what was it again?  Oh yeah, fee calculations.
Weirdly, it was probably the hardest problem of this whole thing.  You'd think
fees, whatever, you attach them, some sats on the end of it, who cares?  But I
wanted to make it so we could have the user say what feerate they wanted and
honor it, or at least get as close as possible to honoring it; sometimes you get
to round a sat here or there where you have some dust limit issues, but do our
best to honor the feerate.  And it turns out that gets it gets very complicated
because this is a problem regular onchain wallets have, is if they want to pay
an amount and they need just a little bit more to pay the fee, they have to add
another input to the transaction.  And people are familiar with this tech
probably already, not in their head, of course, they already know this.  But if
you aren't familiar, adding more funds to a transaction makes the transaction
bigger, which means then you have to pay more fees to the transaction.  You can
get in this loop, as I was saying, where by adding funds to pay for the fee
makes it so expensive, you have to add more funds, which makes it bigger, making
it more expensive.  You can see how this can easily iterate out of control.

This has been well solved in onchain wallets, but splicing has the same problem,
but different, where we have to figure out the feerates in a transaction that
also has channels flying around and onchain funds coming in, onchain funds going
out, and solve all that.  And the goal of this splice engine that I built here,
side note, it turns out this engine was really important.  And specifically, my
goal is to build it in a way, I'm building it with as least dependency on CLN
as possible.  Maybe one day when the other -- I do suspect the other
implementations are going to come around to this problem and realize, "Oh, crap,
this is really, really hard".  And so, I'm trying to make it its own standalone
library.  And it does exist outside of the main Lightning implementation.  It
just needs access to a certain set of RPC calls to manage splices, and it can
manage this quite complex state.  But I figured it was worth it solving it for
all cases.

So, this engine can solve every kind of splice that can exist, go through, get
the feerates right, get balances going where they're going to go, also handle
things that sound simple but are quite complex, like, "I want to do a percentage
amount.  Maybe I have a million sats that I'm putting in, I want you to divide
them equally between these five channels".  Or, "I want you to put half in this
channel and the rest over the other four", stuff like this.  You start getting
these circular dependency problems where the actual sat amounts require multiple
passes over the information to get the correct amount out, and other things too.
Like, maybe you want to take half of my available funds to this channel,
whatever that number is at the time, which is constantly changing.  I think
every time you run the splice, it'll be a different amount than it could be a
minute later, because payments went through.

So, I'm going to implement the hard thing and implement it as well and as
elegantly and tested as I can, and then come back and implement things like
splicein and spliceout.  And one of the awesome things about this is, after this
PR, I made the splicein and spliceout PRs that the actual functional code is
like one to two lines, because it's just calling into things in the splice
script, right?  And this engine allows us to do much more complex splices; and
importantly, it allows it to do it where the user doesn't have to know very
much.  Like, in theory, all the stuff splice script does, you could do by hand,
but you're going to be managing a lot of PSBTs.  Like, the amount of times that
a PSBT mutates in a simple splice can easily be, like, five potentially.  And if
you're doing cross-channel splices, It doesn't just become ten.  It actually
gets, I don't know the exact number off hand, but it's more than ten if you're
doing two channels.  And it starts growing quite ridiculous amounts, the more
stuff you're doing.  And there are actually ways for users to screw it up and
lose funds.  Like, some people like to put a PSBT into an online website that
will parse it for them or change something about it, and then download it back
in.  A very clever website could take your PSBT, recognize this for a splice,
inject your funds into the PSBT, paying them, for instance.  And you'd have to
be aware of this as a user to not let that happen, because your node might just
go and sign that, and then just give them all your money.

So, that's one footgun that you kind of got to worry about.  And by using this
system, I can find all the footguns and just prevent them from happening.
You're not going to fall into any of these footguns that I'm aware of by using
this system.  So, a bunch of those sorts of benefits.  And I'm excited for the
future after.  This is the core functionality of splice script going.  There's
also future awesome things that are coming down the pipe, particularly around
things like automated Lightning nodes, which we haven't really talked about.
I'm going to talk a lot here.  Please jump in, I'm talking too much.  I'm
getting excited.  But the automated Lightning bots have always been sort of a
dream from the beginning of Lightning, and they've always been terrible.
They've always just been terrible.  And over the years, we've gotten some decent
ones coming through.  Like in CLN, we got a CLBOSS, right?  But there's not a
lot of options.  And part of the reason is because they're very hard to build.
And with splice script, once we add channel opens to it and closes and a couple
other features, you could build something like CLBOSS, a Lightning management
thing, with much less overhead code, where you're just managing complicated
channel state and much more prescriptive, like, "This is what I want the node to
do".  And then, all of the complex stuff is handled inside of this engine.

So, that's what I'm excited about.  That's what this PR is about in, I guess,
not a nutshell, a long shell.  But yeah.

**Mike Schmidt**: Awesome, Gustavo, I know you have a couple more.

_Core Lightning #8856 and #8857_

**Gustavo Flores Echaiz**: Yes, perfect.  Thank you so much, Dusty, that was
great.  So, the next one is a quick follow up to that PR, is #8856 and #8857,
which in conjunction, they add two new RPC commands to CLN splicein and
spliceout splicing, which, well the name kind of tells it.  Splicein allows you
to add additional funds to a channel, while spliceout allows you to remove funds
from a channel.  Or even, the spliceout also basically says that you can remove
funds into another channel.  So, it becomes effectively a cross-splice.  And
this was all possible before, right, with the experimental dev-splice RPC.  But
now, you're moving it beyond experimental, if I understand, and you're making it
more accessible?  Can you please give us a little background on that?

**Dusty Daemon**: Yeah, absolutely.  And those are really good points, and
you're nailing exactly what's exciting with those PRs.  I'll cover your last
question first.  There's a lower level.  In CLN, we always make lower-level
APIs, RPC commands for doing stuff, and then we build the higher-level ones.
So, this is building the higher-level one.  There's a low level API.  It's like
splice_init, splice_update, splice_signed, things like that.  There's a couple
of these commands that you can combine together and mutate your own PSBTs and do
this stuff.  Quite difficult to do and error-prone.  This is a command that just
does it like one shot.  Like, "Hey, just give me an amount and I'll splice it
in, give me an amount and I'll splice it out".

One of the awesome things about the splice, so splicein, spliceout, just to
explain it for those that aren't familiar with this, is you're adding funds from
some onchain source into your Lightning channel.  So, typically, it'd be your
onchain Lightning wallet, you store some excess funds that are ready to use for
Lightning kind of in a staging area, but not used.  You splice them into the
channel, now your channel has that extra balance inside of it.  And then,
spliceout would be the reverse flow.  You have funds in a channel, you want to
take it out, you want to bring it back onchain.  And one of the awesome things
about the way this is architected is because of this splice script engine,
spliceout lets you specify the destination as your onchain wallet or another
channel, and then just auto-magically, you can get a cross-channel splice using
the spliceout command.  A little spoiler, what's coming soon is actually you can
add a Bitcoin address to there too.  So, spliceout ends up being this sort of
magical command where you can move the funds wherever you want it to, creating
this sort of elegant, much more elegant, I think, simple user experience.  I'm
really excited about it.  I think we're starting to see the awesome, more mature
stages of splicing appear.

_LDK #4472_

**Gustavo Flores Echaiz**: That's awesome.  It really seems like we're finally
reaching the point we've been looking at for years, and so that this can
actually become effective and powerful.  Well, that's great.  Those were the two
PRs that you covered.  There's another PR on LDK, which maybe you don't have the
exact background, but maybe you have extra thoughts to add.  So, it's LDK #4472.
Here, there was a potential funds-loss scenario that is fixed, where basically
the tx_signatures message could be sent before the counterparty's commitment
signature was durably persisted.  So, this would allow to broadcast and the
splice transaction to confirm.  But then, if your node crashed without having
properly persisted your counterparty's commitment signature, then you would kind
of lose ability to enforce the channel state.  So, this fix defers releasing the
tx_signatures until you have ensured that you have properly updated your channel
monitor and have persisted the commitment signature from your counterparty.  So,
maybe you have some extra thoughts to add to this.

**Dusty Daemon**: Oh yeah, this is so easy to have happen.  I've done the same
code in CLN.  So, the way in general Lightning is architected is we build
transactions and sign them that are pre-empting future, things you can call
justice-y transactions, and then we sign the initial transaction.  So, it's the
reverse order of what people are used to.  Like, if you have transactions that
go onchain in order ABC in Lightning, we sign it CBA.  And each time we confirm,
"Was C signed correctly?"  "Yes".  "Okay, now we can sign B".  "Okay, was B
signed correctly?"  "Yes".  "Now we can sign A".  So, what the commitment is, is
you're signing the equivalent of the justice transaction before you go over and
sign the splice thing.

So, when you're doing a splice, you're taking the existing channel state and
you're building a transaction that moves that channel state over to a new UTXO.
And before you can do that, you must first sign the justice transactions on that
new future UTXO.  So, that's sort of what's happening here.  It's easy to
accept, very important that you get the commitments before you sign the tx,
absolutely.  And one of the other challenges is that, one thing I noticed, if
you're doing multichannel splices with a lot of channels, you have to actually
sign much earlier than you think, because you might need to parse that signed
transaction state from one channel to another over your own local RPC.  So, you
have to actually sign before you send the signature.  So, you need to have
special code that handles when you send the signature and make sure that you
have the correct children signatures already signed.  So, I can't load it here
on GitHub.  GitHub's going down.  What isn't going down?  Is everything
vibe-coded these days?  Oh, I got it up.  Okay, just checking it out.  Yeah, I'm
not going to look through it now, it's a big PR.  But good that they found that,
excellent thing to find.  And I could totally see it happening.  Easy little
thing to slip in.

**Mike Schmidt**: Awesome.  Well, Dusty, I think you've served your tour of duty
on the Optech Recap here and helping us through some of these PRs.  We
appreciate all your work on splicing.  It sounds like there's some exciting
things coming.  People should follow your work on GitHub and try to get involved
wherever their technical and interests lies.  So, thanks for your time, Dusty.

**Dusty Daemon**: Hey, thanks so much, thanks for having me.  Have a good rest
of the Optech.  Take care.

_What is meant by Bitcoin doesn't use encryption?_

**Mike Schmidt**: Cheers.  We are going to jump back up to the Stack Exchange
Q&A.  We have four this month that we highlighted.  First one is, "What is meant
by 'Bitcoin doesn't use encryption'?"  And this person I think saw some
communication from Adam Back talking about probably quantum, and mentioning that
Bitcoin doesn't use encryption.  And this thing somewhat comes up a lot.  And I
think it's good to sort of remind ourselves of this conflation between
encryption and using other types of cryptography more generally.  So,
encryption, and I think Pieter Wuille answered this one, encryption is
specifically about hiding information from a third party.  In Bitcoin, your
transactions are fully public, so there isn't something that you're hiding or
concealing.  What Bitcoin is actually using is digital signatures, so both ECDSA
as well as schnorr can prove that you've authorized a spend without revealing
your private key.  So, it's using cryptographic math, but it's different than
encryption.  So, Bitcoin itself does not use encryption.

Maybe it's important also to note that with encrypted transport, which is what
Bitcoin Core added in the last year or two, encrypted communication between
nodes, previously all that was in plain text.  That can now be encrypted when
you're communicating with your peers.  So, Bitcoin Core does use encryption in
that regard, but Bitcoin more broadly, the protocol does not.  Anything to add
there, Gustavo?

**Gustavo Flores Echaiz**: No, I think that was great.

_When and why did Bitcoin Script shift to a commit–reveal structure?_

**Mike Schmidt**: I'll jump to the next question from the Stack Exchange, "When
and why did Bitcoin Script shift to a commit-reveal structure?"  This is a nice
little 'history of Bitcoin Script' question.  And that evaluation happened
gradually over many years, different iterations.  Satoshi's original design had
folks paying directly to raw public keys, so raw pubkeys.  It was just sitting
right there in the output for anyone to see.  Then you had P2PKH, which was sort
of a first step towards a commit-reveal kind of scheme.  You hash the public key
in the output, and then you only reveal that public key at spend time.  And then
you have P2SH, which extended that sort of pattern into more arbitrary scripts,
not just the pubkey that you're hashing; but you commit to a hash of the
spending conditions, and then you reveal that full script when you spend.  And
then, segwit and taproot continued refining that approach, and with taproot
being the most private version in that you can commit to all these different
spending conditions and only the one that you actually spend, if you're using
the scriptpath, is actually revealed.

So, you can see how this evolution added also to privacy in some regard, in that
the spending conditions weren't revealed till spend time.  And in the case of
taproot, not all spending conditions were revealed.

_Does P2TR-MS (Taproot M-of-N multisig) leak public keys?_

Next question, "Does P2TR multisig, or P2TR-MS, leak public keys?"  And the
short answer to this one is yes, and maybe it's worth understanding why.  In
P2TR-MS, where you have this M-of-N multisig in one of the single-leaf taproot
scriptpaths, all of the public keys are exposed when you spend.  And maybe we
don't need to get into it, but there's a mechanical reason for that.  Both
OP_CHECKSIG and OP_CHECKSIGADD require the public key.  It corresponds to that
signature to be present in the script, and so there's no way to hide unused
keys.  This was actually answered by our usual co-host, Murch, who isn't here
today, who would probably elaborate on that.  But if you're looking for more
private ways to do multisignatures, you can use MuSig2 keypath spending.  That's
probably the best and most cost-efficient way.  And there's folks working on
things like FROST and threshold signatures, which would be another good way.
But this P2TR-MS is something that's available today as well if you want to do
threshold signatures without waiting for FROST.

**Gustavo Flores Echaiz**: Makes sense.  And this is, of course, if you spend
this specific path, right?  So, if you had spent a different path, this wouldn't
be revealed.

_Does OP_CHECKSIGFROMSTACK intentionally allow cross-UTXO signature reuse?_

**Mike Schmidt**: Right, exactly.  And our last question this week from the
Stack Exchange, "Does OP_CHECKSIGFROMSTACK (CSFS) intentionally allow cross-UTXO
signature reuse?"  And this kind of connects back to our discussion last week on
BIP446 and BIP448, when we were talking about OP_TEMPLATEHASH and re-bindable
transactions.  So, sort of riffing off of that, normally, Bitcoin sighashes,
you'd bind to a specific UTXO, and so you can't take a valid signature then from
one input and then reuse it elsewhere; whereas CSFS deliberately does not do
that.  The signature is over some arbitrary message rather than a specific input
to a transaction.  And that might sound initially like a security issue, but
that's sort of the whole point.  So, with something like OP_TEMPLATEHASH, you
can build re-bindable transactions.  So, that same commitment can be applied to
a new UTXO.  And that idea is sort of the foundation for L2 or LN-Symmetry.  The
potential next version of Lightning could use something like that.  In that
update mechanism, you have the channel state updated, and the old state doesn't
become a punishment vector the way it does in current Lightning.  Anything to
add there, Gustavo?

**Gustavo Flores Echaiz**: No, that makes sense.  Thank you, Mike.

**Mike Schmidt**: Great.  Well, we can pass it back to you, Gustavo, for the
Releases and the remaining Notable code items.

_Bitcoin Core 28.4_

**Gustavo Flores Echaiz**: Yes, thank you Mike, perfect.  So, now we have this
week two releases.  Bitcoin Core v28.4 is a maintenance release of a previous
major release.  So, here, a few bug fixes are backtracked around the whole
unnamed legacy wallet migration failure that affected v30.  So, some fixes that
were later added when 30.2 was released to fix what was the vulnerabilities of
30 and 30.1, well now these are also backtracked to the v28.  So, you can find
in the release notes about three different PRs that address these issues.  And
additionally, there's other build and CI changes, and the removal of one of the
DNS seeds that was covered in the PR #33723.  Luke Dashjr's DNS seed was removed
because it wasn't compliant with the requirements for a DNS seed.  You can find
the release notes directly on the newsletter to have more details around that.

_Core Lightning 26.04rc1_

Next one is Core Lightning 26.04rc1.  So, this one has all the changes we were
just discussing with Dusty around splicing, so the new ability to do
cross-splices between two channels, and the new commands, splicein and
spliceout.  There's some other different additions as well.  One important one
is now being able to include fronting_nodes as an option when you create a
BOLT12 offer.  This allows you to specify preferred peers that help route payers
to your invoices and offers.  And actually, this can apply to both BOLT11 and
BOLT12.

There's multiple other highlights for users and for developers, since this is
also a developer-heavy release which has multiple improvements for developers.
So, please check it out if you want to test it.  If you want to learn more about
it, you can find more details on the RC announcement on GitHub.  And there's
also the changelog, which would give you the full picture of the PRs and the
comments that are part of this release.  So, that completes the Release section.

_Bitcoin Core #33259_

So, on the notable code and documentation changes, we have three PRs on Bitcoin
Core, so we'll start with them.  The first one, #33259, is a new field that is
added to the getblockchaininfo RPC response, that is called
backgroundvalidation, and is built for nodes that use assumeUTXO snapshots.  So,
what this new field does is that it gives you the snapshot height, the current
block height and hash for background validation, median time, chainwork, and
verification progress.  So basically, if you have an assumeUTXO node that has
synced from the snapshot block towards the tip, and you have fully synced to the
tip, now you will do background validation.  That means validating all the
blocks that came before the snapshot.  You can do that while you are, let's say,
synced to receiving new blocks as well.

So, previously, getblockchaininfo wouldn't give you any info on your background
validation.  It would simply indicate that IBD (Initial Block Download) was
completed and verification was completed, because it wasn't specifying
additional information for assumeUTXO nodes.  So, it was just assuming it was a
regular node and it would see you had synced to the chain tip.  So, it would
just tell you that IBD was complete.  However, your node was still running
background validation.  So, this new field now gives you all the info you need
while you're in background validation as an assumeUTXO node, which now gives you
more visibility into the current status of your node.

**Mike Schmidt**: Makes sense.  Yeah, pretty good usability addition there,
pretty straightforward.

_Bitcoin Core #33414_

**Gustavo Flores Echaiz**: Exactly.  Next one is Bitcoin Core #33414.  Here,
Bitcoin Core enables what are called the Tor proof of work defenses.  So, this
was a concept that was added to Tor a few years back, where basically an onion
hidden service can require clients that connect to it to make some proof of work
before being able to connect to it.  So, it's a way to distinguish real users
from attackers, and it's a defense that can be added to onion services.  So, now
this PR enables these proof of work defenses for automatically created onion
services when supported by the connected Tor daemon.  So, if you have a Tor
Daemon that has the version that supports proof of work defenses, and Bitcoin
Core automatically creates this onion service, it will automatically enable the
proof of work defenses.  But this only happens when your Tor daemon has an
accessible control port and Bitcoin Core listenonion setting is on, which it is
by default.  So, this will make Bitcoin Core automatically create a hidden
service, and it will enable the proof of work defenses.

For those that are manually creating onion services, it's suggested that the
users add to their Tor config the required setting to enable proof of work
defenses, but this PR is about enabling, by default on, automatically-created
onion services.

_Bitcoin Core #34846_

The next one is Bitcoin Core #34846.  Here, two new functions are added to get
the locktime and the nSequence of an input, so the transactions and locktime
field, and the inputs and sequence field, which are the timelock fields.  This
is added to the libbitcoinkernel C API that we had introduced in Newsletter
#380.  So, libbitcoinkernel has been discussed multiple times before, and it
basically allows external software to simply leverage the internal code of
Bitcoin Core and not have to use things that are not part of the internal
kernel.  So, now this new libbitcoinkernel C API has additional functions that
allow you to get the timelock fields.  And this is specifically important when
you want to check BIP54 rules, such as the coinbase transaction nLockTime
constraints, without manually deserializing the transaction.  So, you can
directly just obtain these fields without having to do additional work.

However, the other BIP54 rules still require separate handling.  This is
specifically about the coinbase nLockTime constraints in BIP54, also known as
the consensus cleanup soft fork.  So, this is about fixing the duplicate
transaction vector that could affect some early coinbase transactions, and this
basically enables to remove the enforcement of the BIP30 checks that were
previously required.  With the consensus cleanup soft fork, we can basically
remove that requirement.  And this PR that I'm just discussing allows an
external software using the libbitcoinkernel C API to access these fields more
easily.

So, the next two PRs, or three PRs that we cover are those from CLN, which we
discussed earlier on with Dusty.  So, that was the extension of the CLN's splice
scripting engine that would enable it to handle cross-channel splices,
multi-channel splices, and dynamic fee calculation.  That was #8450, which Dusty
gave a lot of details about that.  And the next ones, #8856 and #8857 were
combined into one item, which are the new splicein and spliceout commands.

_Eclair #3247_

So, next one is Eclair #3247, where this was highlighted as an important change,
because it adds an optional peer-scoring system that enables a node to track
forwarding revenue and payment volume per peer.  So, this is disabled by default
but when it's enabled, it periodically ranks peers by profitability, and could
then optionally automatically fund channels to top-earning peers, or
automatically close unproductive channels of peers that are not making forward
revenue to our node.  There's also other automatic settings, such as the
automatic adjustment of relay fees based on volumes.  And this can all be very
much configured.  You can start with visibility only before opting into
automation.  But this was a missing piece for specifically people that will use
nodes for routing payments and earning forwarding income, to now have full
visibility on the statistics specific to each of their peers in each of their
channels, and then the capability to take automatic actions to further optimize
their revenue.

_LDK #4472_

So, the next one is LDK #4472 which Dusty also gave us a bit of explanation
around it.  So, this was a potential fund-loss scenario that affected LDK,
because there was a sort of lag of how you had already released the
tx_signatures without having persisted the commitment signature of your
counterparty, which made it that if your node would crash, then you could lose
the ability to enforce the channel.  But now, the fix, like Dusty explained,
defers releasing this tx_signatures until you're absolutely sure that you have
persisted that counterparty's committing signature.  And that means that you
would be absolutely sure that you can enforce your channel state.  Because in
Lightning, if your peer does a unilateral exit, you want to be able to contest
directly on the Bitcoin Network that if your peer tries to cheat and tries to
publish a previous state that was invalid, you want to be able to have your
counterparty's commitment signature to be able to contest that.  But if you
hadn't persisted it effectively, then you would lose that ability.  So, this PR
ensures all the steps happen in the right order to avoid fund-lost scenarios.

_LND #10602_

So, the next two are from LND.  The first, LND #10602, is a new RPC that is
added to the switchrpc subsystem.  So, this new RPC is called DeleteAttempts.
But before explaining that, I'm going to maybe give a background on what this
switchrpc system is.  So, in Newsletter #386, we discussed the introduction of
an experimental subsystem called switchrpc, which allows an external controller
software to handle pathfinding and payment lifecycle management while using LND
for HTLC (Hash Time Locked Contract) delivery.  So, that means that in that
coverage, we included BuildOnion, SendOnion, and TrackOnion RPCs.  So, this
basically allows external software to do the pathfinding, to find the route for
the payment, and then to simply tell LND, "Hey, can you build this onion, send
it, and then track it?"  So, this was covered in Newsletter #386.

Now, there's been a few additions ever since, but the one we're covering in this
newsletter is the ability to delete an attempt that was either successful or
failed, so that LND doesn't have it anymore in its attempt store records.  So,
you have to ensure, as an external controller software, to have properly
persisted, or to no longer have a need for LND to track the attempts that you
had dispatched previously with the SendOnion RPC in the switchrpc system.  So,
this is just an additional command that is added to the system so that people
can better manage the records that are kept in LND's attempt store.  All good,
Mike?  Perfect.

_LND #10481_

So, the next one is LND #10481.  Here, a new bitcoind miner backend is added to
LND's integration test framework.  So, as you might know, the team behind LND is
also the team behind the btcd implementation of a Bitcoin node in Go.  And a lot
of the code in LND used to be heavily dependent on having btcd as the Bitcoin
backend of the LND software, or as some call it, the chain backend.  So,
previously, before this PR, lntest, which is LND's integration test framework,
was assuming that a btcd-based miner was going to be used, even when bitcoind
was used as the chain backend.  So, what this PR does is it adds or creates a
new bitcoind miner backend that can be used in LND's integration test framework
when bitcoind is used as a chain backend.  So, it's basically extending the
support it has for btcd to bitcoind, which is Bitcoin Core.

So, this change allows tests to exercise behavior, specifically on the miner
side of things, that depend on Bitcoin Core's specific features, such as v3
transaction relay and package relay.  So, everything that touches mempool and
mining policy that only exists in Bitcoin Core can now be properly tested within
LND with this new addition.

**Mike Schmidt**: Awesome.  Thanks, Gustavo.  Thanks for co-hosting this week as
well.  We missed Murch, but it was great to have Dusty on as a guest this week.
And we thank you all for listening and we'll hear you next week.  Cheers.

**Gustavo Flores Echaiz**: Thank you.

{% include references.md %}
