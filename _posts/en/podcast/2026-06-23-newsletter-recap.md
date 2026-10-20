---
title: 'Bitcoin Optech Newsletter #410 Recap Podcast'
permalink: /en/podcast/2026/06/23/
reference: /en/newsletters/2026/06/19/
name: 2026-06-23-recap
slug: 2026-06-23-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
rkrux, Roland Bewick, and Steven Roose to discuss [Newsletter #410]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-5-23/426702396-44100-2-c7ac3b4c6d8.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome, everyone, to Bitcoin Optech Newsletter #410 Recap.
Today, we have one News item, which is a discussion about wallets dropping
opt-in RBF signaling, and we have a big week for Ark in our monthly Changes to
client and service segment.  We're going to be talking about Bark, a couple of
Ark wallets, we have Alby, and some other items.  We also have our weekly
Notable code and documentation changes that Gustavo will walk us through.  And
we have some guests this week.  Murch, Gustavo and I are joined by rkrux. Rkrux,
you want to introduce yourself very quickly?

**Rkrux**: Hi, everyone, I work on Bitcoin Core.

**Mike Schmidt**: Thanks for joining us.  We also have Roland.

**Roland Bewick**: Hey, I'm Roland, I work on Alby, which is a self-custodial
Lightning and Bitcoin wallet.

_Discussion of removing RBF signaling from wallet transactions_

**Mike Schmidt**: Awesome, thank you both for joining.  We may have one more
guest join us later in our recording.  But for now, we're going to jump to the
News section and cover that item I mentioned, "Discussing removal of RBF
signaling from wallet transactions".  Rkrux, you posted to the Delving Bitcoin
forum proposing that wallets should consider stop signaling for opt-in RBF in
the transactions that those wallets create.  And you also opened a corresponding
Bitcoin Core PR to do exactly that.  Maybe, rkrux, it would be helpful if you
talk a little bit just about what the signaling actually is and why it may not
be needed now and why it may actually be a good idea to remove it, or why it
might not be a good idea to remove it?

**Rkrux**: Yeah, sure.  So, this RBF signaling was a part of BIP125.  And I think
it was deployed many years back.  It was a way for the users to tell that the
transaction is replaceable later if the need arises, by creating a follow-up
transaction that spends the same inputs but with a higher fee and feerate.  And
the way this signaling used to work was that in the sequences of the inputs of
the transactions, a certain number was set which was supposed to be less than
the max value minus one.  And if such a number was seen in the inputs, then it
used to act as a signal that this transaction could be replaced in the future.
But since, I think, v28 of Bitcoin Core, the full-RBF functionality became the
default, in which every transaction was replaceable as a standard.  So, this
signaling is not required and it's effectively redundant.  So, that's why I
raised a PR in Bitcoin Core that changed the default signaling, or rather that
changed the default value of the inputs in the transactions, so as to stop
signaling for replaceability.  And that's why I also raised a question in the
mailing list asking other wallet developers their ideas and their inputs on
whether they intend to stop the signaling as well by choosing a different value
for the input sequence numbers.

Over there, I got feedback that the MAX-2 value, which is actually the most
common value to signal for replaceability, that is the most common at the
moment, more than 75% of transactions do that.  And Murch chimed in, along with
the Electrum developers, and then I got an idea that maybe since this number
should be something that's accepted by the wide wallet community as the standard
or a best practice, so to reduce the fingerprinting vector, maybe we should
stick with this value for now.  And that's why I closed that PR on Bitcoin Core,
and the default value is unchanged.

**Mike Schmidt**: Murch, I know you commented on the discussion here, and I know
you probably have some thoughts.

**Mark Erhardt**: Yeah, so basically we introduced, or, well, it wasn't really
that active in 2015.  But in 2015, we had the signal that transactions could be
marked as replaceable, because RBF was somewhat controversial.  So, it was
designed to be opt-in.  And over time, the signal got a little muddled because
miners do have a financial incentive to always accept replacements if they pay
more.  So, the reliance on just this mempool policy, well, I think we learned a
lot about how reliable mempool policies are in the last year, so maybe let's
leave it at that.  And over time, there were some nodes that actively allowed
replacements, even if transactions had not been marked as replaceable.  So, over
time, the new default became all transactions are replaceable, even if they are
marked as non-replaceable per the BIP125 signal.

So, every input has the sequence field, and you always have to pick a value for
the sequence field.  Some popular values in the past were zero or maximum, and
maximum had become interpreted as marking a transaction final.  So (a) that
means we're not expecting that it will be replaced, this is the final version of
this transaction; and (b) locktimes are disabled.  So, if you want your locktime
to be enabled, you would have to set MAX-1 in at least one of the input
sequences.  So, there's a sequence field on every input.  And if any one of them
is set to a value below final, the transaction is not final and locktime is on
and it is replaceable -- sorry, not replaceable.  Replaceable was MAX-2, but now
every sequence value is acceptable for replaceability.  Per mempoolfullrbf, the
default behavior of Bitcoin Core nodes on the network, any transaction that pays
more fees will be accepted to replace an original transaction.

So, with people having adopted the RBF, the replaceability signal, so much more
over the years, going back to not signaling replaceability would actually be
leaving the majority signal.  Right now, it's about 75% of transactions that
signal replaceability.  All transactions are replaceable.  So, some people are
trying to express something by not signaling replaceability.  And there are some
wallets that still always set final.  But yeah, the majority of transactions are
marked as replaceable per the BIP125 signal.  So, just sticking with that seems
easier.  And I would also recommend that as the best practice going forward for
all wallets.  So, if you are thinking about what value to set, the default value
should probably be MAX-2, which per the old rules, would have marked your
transaction as replaceable.  But again, any transaction replacements will be
accepted if they pay enough anyway.

**Mike Schmidt**: Murch, you outlined a couple of the extreme values that could
be for that field.  And then the most common one, 75% being replaceability,
after that being the way that you opted in to opt-in RBF BIP125.  What else is
going on in that design space?  Is there anything else?  What are the other
values used for, if at all, or nobody uses those?

**Mark Erhardt**: Actually, I haven't researched it, but dimly I remember that
some Lightning implementation uses it to signal something about channel status.
But you could set any sequence value between zero and MAX-2 to still be
replaceable.  And I think that there was some aspect encoded there about maybe
their CHECKSEQUENCEVERIFY (CSV) or something.  Other than that, I don't think
there's anything going on there.  Rkrux, do you know better?

**Rkrux**: No, none comes to my mind right now.

**Mark Erhardt**: Well, anyway, you have a 4-byte field on every input, so
presumably someone's going to come up with making better use of some free data
field.  That seems to be par of course especially in the last couple of years.

**Mike Schmidt**: I'm sad, I'm upset that I even brought that up.  Who knows
what's next?

**Mark Erhardt**: Yeah, Mike, how dare you!

**Mike Schmidt**: Rkrux, you mentioned that you closed the PR in favor of keeping
the status quo.  Is there any further work or insights here that you would like
to articulate for the audience before we wrap up this item?

**Rkrux**: Yeah, so even though the default value stays the same, but I do intend
to remove the replaceable option from the RPCs in Bitcoin Core, because the
concept of signaling for RBF is outdated.  The default value can stay, but I'm
unable to think of a reason why we should provide for such an argument for an RPC
request to the end user.

**Mark Erhardt**: Yeah, I think the default policy is, if we can't think of a
reason in which case an option is used or can make a recommendation how the
option should be set in different circumstances, there's just no reason to have
an option.  And having too many options that don't mean anything is not a good
practice.  So, I second this.

**Rkrux**: That's good to hear.  I do have a PR open for it.  I look forward to
reviews on that one.

**Mike Schmidt**: Do you think we got into the fingerprinting enough, like why
it's a good idea for some wallet to not choose some unique value to show that
everyone's using their wallet onchain?  Like, maybe that's obvious to people.

**Mark Erhardt**: I hinted at it with saying that we should go with the majority
option, but let me explain it a little better.  So, Bitcoin transactions are
pretty uniform in general by design.  There's the same number of fields for
every input and output.  There are fixed sizes for those.  For a lot of the
values, we have defaults that everybody uses.  So, most transactions should look
somewhat indistinguishable from each other.  However, if wallets behave
differently on some fields, and especially if there are multiple such fields
that wallets behave differently about, transactions might have what we call a
fingerprint that identifies which wallet created that transaction.  And for
example, if there are two parties participating in a chain of transactions and
the fingerprint switches midway through from one to the other, you might be able,
for example, to tell what the change output is, or you can group transactions to
participants, can cluster outputs belonging to the same wallet, things like that.

So, the best practice generally is to try to look exactly like other
transactions in any aspect that you control.  Obviously, you wouldn't control
when people continue to use old output types that are becoming less prevalent,
or if they mix an old output with a new output, and so forth.  But stuff like
sequence or locktime, signature grinding can be controlled and should be
controlled.  So, if you're developing a wallet and haven't thought about
fingerprinting, there's some research into that.  And so far, I think it's pretty
easy to distinguish most wallets from each other.  But we could do better there
and just try to look more alike.

**Mike Schmidt**: Yeah, I think in general, people may be offended, "Oh, you want
everything to be homogenous and uniform", but obviously there's advantages to
blending in with the crowd.  We had that discussion at the node level with
Naiyoma and Daniela about fingerprinting nodes so that you could identify certain
things about nodes, which is not good for privacy.  But the same applies with
wallets.  And I think also, I forget who we had on that was doing payjoin
transaction fingerprinting work as well, but I think Ishaana has done some wallet
fingerprinting work as well.  So, maybe that's to wrap up.  We'll put that in
this discussion in a broader context with that.  Rkrux, thanks for joining us, we
appreciate your time.

**Rkrux**: Sure.  Thanks for having me.  Cheers.

_Alby Hub v1.23.0 released_

**Mike Schmidt**: We'll move to our monthly segment on Changes to services and
client software.  We're going to jump a little bit out of order, down to Alby Hub
v1.23.0 being released.  And we have Roland here to talk about that item.  I
don't think, other than some mentions in some of these podcast discussions, that
we've actually formally discussed what Alby is, what is Alby Hub.  So, I'm
excited to have Roland on to maybe give us the big picture, and then we can talk
about some of the JIT (just-in-time) channels that we covered in the experimental
Ark backend.  So, the floor is yours.

**Roland Bewick**: Thanks very much for having us on.  So, Alby, we do products,
tools and services to make it easier for both businesses and individuals to use
Bitcoin, which we think is the global native currency of the world.  And Alby Hub
is our flagship product, which is a self-custodial next generation Lightning
wallet.  So, Hub is really important here.  It's not like a standard Lightning
wallet, where you just scan QR codes and make payments.  But it's really the idea
of being a hub connected to all the different apps that you use.  And each app
has a budgeted permissioned connection to your hub, so you have full control over
what other apps are doing connected to your Lightning wallet.  So, this enables
some really cool things, especially for developing Bitcoin and Lightning apps and
makes it really simple.  Also in the agent space, which we're doing a lot of
research recently, you can give an agent permissioned and budgeted access to your
Lightning wallet to make payments.  And we also do a lot of things around
improving the developer experience for building simple Bitcoin apps.  So, we kind
of abstract away the difference between the different Lightning node
implementations, so that developers can just focus on building their apps.

So, in the latest release, I think we made a great step to lower the barrier for
people who are getting started with the Lightning wallet, two different, separate
ways, so JIT channels.  So, Alby Hub, first and foremost, is self-custodial,
fully open source.  And the default implementation is LDK.  So normally, when you
start Alby Hub, you have to open a channel, so that you can receive or you can
send payments.  And up until now, the way that that has been done is that we use
LSPS1 or I think it's BLIP51, which is basically you can purchase liquidity in
advance.  So, when you start Alby Hub, you kind of have to estimate, say, "I'm
going to receive $1,000 or $10,000", or whatever it is, and you would buy a
channel to cover that so that you can receive incoming payments.  But actually,
Alby Hub is a bit different than some other Lightning wallets that work with LSPs,
in that we are completely open.  So, we're not locked to just one liquidity
service provider.  You can even open outbound channels to any node on the
network, but we work with about six different LSP partners, which users can
choose to purchase liquidity from, and they come with different pros and cons,
different prices for the liquidity, how long you can rent this liquidity for.

So, all of this is a bit complex and also, you have to plan it out advance.  So,
JIT channels kind of simplifies that.  So, when you start Alby Hub, even if you
don't have any channels, you can just simply click 'receive', generate an
invoice, and someone can pay you.  And a small fee will be deducted from the
payment to actually open your first channel.  So, this is great for a UX
perspective as well.  It's simpler and also cost of opening the channel is
smaller, because the actual size of the channel will only be slightly higher than
the amount you receive.  So, there's still a lot of UX challenges here and we need
to do some follow-up iterations, I think.  And ideally, we want more of our LSP
partners to support this.  But I think it's quite exciting.  It's a good
direction.  And users of Alby Hub still have full control, so they can disable
this feature if they don't want it, and they can open outbound channels or just
purchase the standard channel in advance if they like.  So, yeah, whatever suits
your needs, Alby has all the options there.

**Mike Schmidt**: Yeah, great explanation.  I'm particularly curious, and if you
had more on the JIT channels.  I'm sorry that I'm interrupting you, but I did want
to segue to the Ark piece as well, because I'm curious, as somebody who's focused
on developer usability and sort of abstracting things away, but also being able
to integrate with different backends, how are you guys thinking about this Ark
thing in combination with Lightning?

**Roland Bewick**: Yeah, I'm really excited personally.  I was the one who worked
on the back implementation for Alby Hub.  I think it's our sixth backend now.  So,
we did some calculations.  I think if you're a beginner or a casual user, Bark is
a lot cheaper for you than Lightning, because you have to do the initial
investment to open a channel.  Whereas Bark, the Ark Service provider, will
handle the channels for you.  It will cost a bit more on a per payment basis, but
in your whole lifetime of sending payments, if you only sent 100 payments or less
than that, then actually Bark is a lot better.  So, there is a trade-off of
course, because Bark is centralized, right?  So, Alby Hub, we have a lot of pride
in the fact that we're fully open source, and we're not dependent on any single
party, right?  So, you can open a channel to anyone, you can always send payments,
you're never dependent on a single piece of infrastructure.  So, this is the
trade-off that you have to make.  But what I think is really cool about Bark and
Second in general is that they see a future where there are multiple different,
completely isolated, Ark service providers.  And I think, at least personally, I
think that's really important.  So, in the future, Alby Hub runners could use a
different Ark service provider if they wanted to.  And that also means that if one
gets shut down, it's not just like the whole Bark backend is no longer usable,
because you can find another one.

**Mike Schmidt**: And right on queue, you said Bark, you said Second, and look who
appears.  Hey, Steven.

**Steven Roose**: Hi, sorry for being late.

**Mike Schmidt**: Yeah, no problem.  We're actually going through with Roland
Alby's 1.23 release, which had JIT channels, but also this experimental Ark
backend.  And so, I was picking his brain on how they are thinking about
traditional Lightning and Ark.  And so, that's the context that you just jumped
into.

**Mark Erhardt**: What we just heard is that the channel open is, of course,
cheaper and more convenient.  But over time, the fees are a little higher.  So,
there are trade-offs here.  And I don't want to put words in mouths, but there
was some mention of Ark being of course more centralized.  So, I thought that
might trigger you.

**Steven Roose**: Well, it is centralized.

**Mark Erhardt**: I mean, one thing that I understand is that Ark is of course
designed that any participant can unilaterally exit.  But especially for smaller
amounts that might not be trivial or there are more transactions, there's more
block space to be purchased to exit an Ark.  Anyway, how about you join the
conversation?

**Steven Roose**: Yeah, missing a little bit of the context.  But yeah, definitely
Ark is centralized, but it's trustless.  So, you have a central server, but you
don't have to trust the server to hold your funds or to be nice.  If you verify
everything the server does, you sign with your own keys; if the server is doing
weird stuff, you can always go onchain.  So, it's very important aspect of the
protocol.  When it comes to fees, you said the fees might be a bit higher.  That's
definitely contestable.  I mean, liquidity fees should be a lot lower because the
liquidity is way more efficiently allocated within an Ark than within channels,
right?  If you have an LSP-style model, the LSP has to allocate your inbound
liquidity and it just sits there for one user at a time.  If the user is not doing
anything, then liquidity is kind of wasted; while in Ark, the liquidity is kind of
allocated on demand.  So, if the user needs to receive, the liquidity is used from
the server for that receipt.  But if the user's not doing anything, nothing really
needs to be allocated, except for a little bit for all the refreshes.  But users
that refresh really late in their lifetime, so very close to the expiry of their
VTXOs, really minimize the liquidity need for the refreshes.

So, that's two things I already want to mention.  Not sure where you want to bring
the conversation further.

**Roland Bewick**: Yeah, just on the fees actually, yeah.  Just to mention, so for
users who only make a small number of payments, actually it's a lot cheaper to
use Bark than open a Lightning channel themselves, right?  So, I think that's
great for onboarding new users, especially.

**Steven Roose**: Yeah, I think for normal retail users who make a few payments
day, I think Ark or Ark-based protocols are going to be a lot cheaper.  When it
comes to merchants making hundreds or thousands of payments a day, it's to be
seen.  I think Ark for them is definitely easier to use and implement because they
don't have to do all the channel stuff.  But yeah, having your own Lightning node
is probably going to be more efficient for them.  But it just comes with the
technical maintenance burden of actually doing that.  So, I think there's a
trade-off there for those users.

**Roland Bewick**: One thing I think is also interesting, that Alby Hub is an
always-online wallet, right, that it's actually very well-suited to Bark,
especially with the refreshes, that we can basically remove almost all fees
because we don't have to refresh far in advance to estimate the next time someone
opens the app on their phone, or something like that.  That's not the case here.

**Steven Roose**: Yeah, that definitely makes it more trustless, especially we
initially wanted all the Ark refreshes to be fully interactive, so the users sign
everything during the whole process.  But on mobile phones, that was really,
really hard to actually make work, especially on iOS, or some of the more managed
Android distributions, where you don't really have a lot of time to do stuff in
the background.  So, we have these delegated refreshes where you kind of trust a
set of co-signers to be there at the signing ceremony every hour, or when you
need it to do the signing correctly and actually remove the keys after signing.
But in the case of Alby Hub, where you're actually an always-on device, you can
actually fully participate in the interactive process and make sure that all your
transactions are signed by yourself, so you have full trustlessness, which on a
mobile device is a lot harder to get actually.

**Mike Schmidt**: Roland, as we transition into some of these Bark and Ark items,
is there anything else on the Alby front that you'd like to highlight before we
move along?

**Roland Bewick**: Just one thing, especially regarding Bark as well.  So, we're
really impressed with the work the Second team has done.  And even their Bark SDK
is really easy to build on.  I've seen people live-coding wallets in a matter of
an hour or less.  But there's a new way also opened up with the Alby Hub
integration, in that people can build Nostr Wallet Connect (NWC) apps, powered by
Bark, through Alby Hub, and that's a really great way to join quite a large and
growing ecosystem of different apps, and really have seamless, automatable
payments, which I think opens up a whole number of use cases.  And we really need
people to spend bitcoin and not just hold it.  Right?  So, we're always looking at
how to make the UX ten times better than what people have today with fiat
payments.

So, if you want to try building, we have different agent skills.  So, with a
single prompt, you can build a full app with bitcoin payments inside it, powered
by NWC, and it's an open protocol, so it doesn't work just with Alby Hub, but it
works with a whole bunch of different wallets that implement this protocol.  So,
yeah, really excited for the future.  Things are getting easier, the barrier is
going down every day.  So, this is really the time for Bitcoin to shine, I think.

**Mike Schmidt**: Roland, thanks for joining us.  You're welcome to hang on, or if
you have things to do, we understand, and you're free to drop.

**Roland Bewick**: Thank you.

_Bark live on Bitcoin mainnet_

**Mike Schmidt**: Steven, we're going to jump to your item.  So, for listeners,
we're jumping back up in the Changes to services and client software segment to
the item titled, "Bark live on Bitcoin mainnet".  Second, announced that Bark,
its Ark implementation, is now available on mainnet.  I think it was a few months
ago that we covered the launch on signet.  We mentioned the Ark server and the
Bark SDK, barkd, but maybe, Steven, why don't you be the one to walk us through
this suite and how things have gone so far?

**Steven Roose**: Yeah, when you said a few months ago, that's very generous.  But
it was probably more like a year ago almost that we were live on signet.

**Mike Schmidt**: Yeah, I guess it was.  Newsletter #346, which was March 21,
2025.  Okay, all right, so last year, yeah.

**Steven Roose**: Yes, last year.  Yeah, I mean we're very excited.  It took us
longer than we had hoped, definitely, but we're live on mainnet with our server
for a few months.  We were first in a private mainnet beta setup with some of our
testers, some of our integrators.  But when we felt comfortable enough to open it
up to the public two weeks ago, we did so.  And since then, we had a lot of
positive feedback.  We also launched a fun anecdote.  We launched the same day
that Claude opened up their Mythos or their Fable model.  So, the first two days
went very smooth, there was not a single incident.  We were very happy, we were
like, "This is very unexpected".  And then, the day after, we had three different
people sending us critical vulnerabilities that somehow AIs had found, and we
spent the weekend patching those.  But other than just spending the weekend
patching those really fast, there was not really anything critical that happened.
So, yeah, we're very happy with how it went the last few weeks.

_Noah Ark wallet announced_

Maybe highlight our two or three main integrators.  We already heard from Alby
Hub.  We also have Noah wallet.  So, Noah is the team from the earlier Blixt
wallets.  They decided to adopt the Ark protocol, built an entirely new wallet
based on top of our SDK.  It's called Noah.  It works pretty well, works actually
very well.  They're working on a UI update.  But yeah, it's been a daily driver
for some of our team since they enabled it for mainnet, so it's pretty solid.

_Arké Ark wallet announced_

Then, there's been Arké, built by Christoph from the Bitcoin design community.
It's an iOS-only wallet, but it has some very interesting UI and design
implementations.  He's basically trying to put in practice some of the design
guide things that the design community has built over time, and he's using the
Bark SDK to do that.  He's a bit of a developer, but he's definitely not like a
professional full stack developer.  And it's been amazing how much and how well
he's been able to build these things using AI and our SDK.  The wallet is pretty
solid as well, it looks very nice.  So, definitely try it out if you're on iOS.

**Mike Schmidt**: I have a question about that.  Did I see that Arké, does Second
have a mobile app that that was based on, or did they just use Bark and put the
front end on themselves?

**Steven Roose**: I didn't understand the first thing you said.

**Mike Schmidt**: Yeah, I guess let me jump into the repo where I saw it.  It
says, "A Bitcoin iOS app based on the Ark protocol prototype".  Okay, so you guys
didn't have a mobile app that they put a nice, clean face on.  They actually took
the protocol and put the whole app on themselves.  Okay, I misunderstood that.

**Steven Roose**: Yeah.  And so, how he started, he started doing a Mac desktop
wallet using our bark, or standalone daemon that we also launched.  And then, when
we released the Swift bindings, that were direct language bindings to our Rust
SDK, he decided to use that.  And then, he could do it on iOS as well, because on
iOS, running the daemon is a lot harder.  So, yeah, I just still wanted to
highlight we have our SDK live, it's Rust-based, but we have bindings in Swift
TypeScript for both web and React Native.  We have a bunch of other languages,
Kotlin and stuff.  We have barkd, which is a standalone program that you run on
server applications for merchants, and stuff like that, that has a REST HTTP
interface, so it's very easy to work with.  It does all the background stuff you
need to do without you having to do anything.  It's pretty low on configuration.
You just call the APIs to make payments, check your balance, stuff like that.
And then, we launched ourselves a web wallet based on barkd that we kind of built
ourselves.  We packaged that for Umbrel.  We're in the process of packaging that
for Start9 as well, so that you can run it on your hardware devices that you have
at home.  And then, we also announced a BTCPay Server plugin, that in one or two
clicks, you can receive Lightning payments in BTCPay Server using Bark with
minimal setup.  That's also using barkd under the hood.

So, yeah, we kind of announced a bunch of things in the course of this one week.
And feedback so far has been good.  Obviously, it's very early, so user numbers
have been moderate, but definitely not as many complaints and issues that we had
expected.  So obviously, some users have gotten themselves into some weird
situations with some bugs, but it's definitely been very positive so far.

**Mike Schmidt**: Now, given the newness of this, and obviously you guys have been
working on this for a while, maybe you have some indication, I'm curious, where
are you seeing the uptake in usage?  Like, where is Ark really going to shine and
be used sooner than later versus other use cases or areas?

**Steven Roose**: I think definitely our first target audience for this is the
self-custodial Bitcoin user who wants to have Lightning.  I think Phoenix has been
a market leader in this segment of the ecosystem for a very long time.  But
Phoenix also comes with paying liquidity upfront, sometimes channel closures or
channel top-ups, and all that kind of stuff.  So, it comes with onchain fees.  So,
definitely that segment of users is going to be the first adopters of Bark I
think.  Noah Wallet is a really good alternative to Phoenix.  It's fully
self-custodial, it works pretty well.  You don't have to think about channels.  It
just shows you your balance and you can receive Lightning, you can send Lightning.
So, that's pretty great.  And I think we're seeing a move of all these small-scale
custodial wallets kind of realizing that legally, that's pretty difficult for them
to uphold.  And a lot of them are looking for non-custodial solutions for their
apps to adopt.  And we've seen, because we were a bit late to launch this, that a
lot of them have adopted the Spark protocol.  But we're also hearing some negative
feedback sometimes of using Spark, especially payments can be slow.  Also, the
trust model is a bit difficult for some people to accept.  So, I think some of
those might adopt Bark as an alternative to Spark, or just some of them have been
waiting because they didn't like Spark enough, and they've been waiting for a
solution and they might adopt Bark.

So, I think some of those custodial solutions that are trying to uncustodialize,
basically, could use this, because the UX is pretty good.  It's very easy to
integrate, it doesn't come with all the UX problems that made people move to the
custodial solutions in the first place, channels and capacity and stuff.  So, I
think it has a lot of potential in any kind of wallet implementation for now.

**Mike Schmidt**: Yeah, I want to double-click on that a bit.  I've heard the last
18 months or so, and probably more, and I just am not in this world, but the idea
of graduated wallets and folks saying, especially when maybe fees were a bit
higher, that there's a certain threshold where maybe it's okay for a certain point
of funds to be custodial, and then you sort of graduate into a Lightning channel,
and then you maybe graduate into onchain or cold-storage Bitcoin.  And I think the
thought process pre-Ark was that folks could use ecash for that small balance, or
that they could use something like Spark for that.  And now, it sounds like what
you're saying is maybe perhaps for those smaller balances, they could use Ark.
But then I'm curious.  If Ark were sort of the cheap entry point, is there a
reason to graduate from that?  You can just use Ark and interact with Lightning,
and maybe then your graduation is into cold storage, if you want to start stacking
for the long term.  But Ark can maybe satisfy both of those pieces and not just
fulfill the ecash Spark area.  How are you thinking about that?

**Steven Roose**: Yeah, I think you hit it spot on.  I think with smaller balances,
you can definitely use Barg.  It's not going to be as trustless, because if the
cost to exit is in the similar range than your balance, it doesn't make much
sense.  But at least the server cannot just run away with your money.  You can
still try to contest it, even if you're going to burn most of the money in fees.
So, there's still this protection that the server cannot just disappear, take all
your money, and go to the Bahamas, or something like that.  So, you still have
some protection.  And when your balance starts to grow, your exit actually becomes
reasonable in cost compared to your balance.  And then, it just kind of becomes
workable for even quite large balances.  Obviously, you're going to want to
consider doing your refreshes interactively.  But we're also working on some
additional things to make the delegated refreshes actually have a better trust
model, by adding third-party cosigners that you can actually trust; either you're
a wallet developer or some trusted parties in the ecosystem, like mempool or
something like that.

So, definitely you can get to a pretty good trust model for higher balances with
this.  Obviously, it's not called storage, you still need to use something that
comes online regularly, so something like a phone.  It's not like it's safe if you
just disappear for half a year and then try to get your balance back.  So, you
kind of need a device that at least regularly can send some messages to the
server.  But yeah, I think having Ark for your small to medium-large payments, and
then just savings going to onchain or something like that, makes a lot of sense as
a model.  You can actually directly send from your Ark balance to an onchain
address.  We call it offboarding, because you get out of the Ark.  And so, yeah,
actually our Bark wallet and SDK comes with a built-in onchain wallet as well.
So, you can receive your onchain funds there if you want and then put them into
the Ark.  And if you have a lot of balance in the Ark, you can basically offboard
them from Ark back into your onchain wallet.  But we support third-party onchain
wallets.  So, wallets that already have an onchain wallet right now can just add
Bark on top, and then kind of manage the back and forth with their onchain wallet.

So, I think it makes a lot of sense, yeah, that you can use Bark for any types of
payment that you're doing regularly, just having your savings somewhere else.

**Mark Erhardt**: I wanted to make a few remarks.  The first one is a little far
away from when it came up, but a lot of people are maybe aware that many of the
Ark projects have 'Ark' in the name.  So, there's Bark, there's hArk, there's
Arké, Noah's Ark, and so forth.  But Spark is not an Ark.  Spark is a
statechains-based protocol, just to make that clear.  And I wanted to also make
clear, so what is a little more expensive in the Ark is the unilateral exit, where
you have to pay for a chain of transactions, because you have to execute an entire
branch in each tree of transactions.  But if you just want to exit the Ark, that
would be just a regular onchain output that you pay for.  So, sorry to talk your
book, Steven, but I felt that that was not necessarily coming out clearly.  So,
the unilateral exit is a little less trustless.  You need to have a little more
amount ready to pay off that whole tree.  And yes, you can contest even with a
small amount.  So, it might get burned mostly, but the Ark would still look bad
there.  But if you just want to get out of the Ark, you could just receive an
onchain payment out of the Ark and you would probably, presumably, only pay for
the output.  You can tell me more about that.

Then, I was wondering, so the idea of the Ark came basically out of the idea, how
would we have a multiuser Lightning node?  And in this case, of course, the
Lightning capability, is that based on VTXOs that span Lightning channels, or do
you run a Lightning node and then just convert balance received into VTXOs
credited to the users?  How does paying Lightning into the Ark and receiving it as
a new user work?

**Steven Roose**: Yeah, so currently we, basically do VTXO-to-Lightning swaps
conceptually.  So, a user creates an HTLC (Hash Time Locked Contract) in the Ark
using a virtual output, and it has the same payment hash.  And then it tells the
server like, "Hey, I have this HTLC coming to you.  If you make this payment,
there's a Lightning invoice.  You get the preimage, you can give it to me and you
can claim the HTLC".  So, it's basically putting one more HTLC in the Ark and then
routing the rest of the HTLCs through the LN.  And then, on the receive end, you
basically tell the server, "Hey, I have this Lightning invoice that I want to
receive.  The server will give an HTLC to you in the Ark, and then you give the
preimage, the server can claim the money, and then you basically have the HTLC in
the Ark".  So, it's using swaps now.  So, every payment creates a new Ark VTXO
which, if you do a lot of payments, can cause your exit to be very big.

So, in the future, we're working on what we call virtual channels, where you
actually create Lightning-channel-like things inside the Ark, and then you can do
multiple sends and multiple receives from these channels.  But at every month,
when the VTXO expires, basically you get a free chance to rebalance that liquidity
there.  So, every time, for example, if the user sent all his money, the liquidity
just goes like a normal VTXO, goes to the server, and then the user either doesn't
get anything anymore, or he just asks for some inbounds.  There's definitely
considerations to be made there.  But definitely for people that have high volumes
of payments, high numbers of payments, the virtual channel approach will be a lot
better.  But for people that don't make too many payments, there's actually not
really a problem with having the current approach, other than that your exit might
be a bit more costly.  But you can always refresh and then your exit costs get
basically refreshed to the minimal.

So, yeah, it's essentially a swap from the Ark to Lightning, but we hide all that
in the SDK.  You just pay Lightning, receive Lightning.  You don't have to be
doing preimages and in-swaps, the SDK does all that for you.

**Mark Erhardt**: It was just reminding me of the Phoenix way of doing it.  What
do they call their onchain payment channels; PROTEM channels?

**Steven Roose**: Just in time?

**Mark Erhardt**: No.  When you receive an onchain payment, they receive it to a
2-of-2 multisig HTLC sort of, what was it called, channel approach?

**Gustavo Flores Echaiz**: Swap-in-potentiam?

**Mark Erhardt**: Swap-in-potentiam, thank you, that was it.

**Mike Schmidt**: Nice, that was a good call by Gustavo.

**Mark Erhardt**: So basically, it sounds like it is a step that follows the
Lightning protocol to receive and send funds from the Ark.  The VTXOs are HTLCs,
so it's sort of like a submarine swap into the Ark.  And if you have that virtual
channel that persists for a month, it would be based on a virtual TXO, so it
wouldn't, currently by Lightning standards, be visible on the LN, because channels
have to have a funding output that the channel is tied to.  But you would
essentially get a month-long-lasting channel in the Ark that you could then
rebalance automatically every month, because it's not an onchain UTXO, it only
exists virtually.  So, rolling it over costs whatever rolling over a VTXO in Ark
costs.

**Steven Roose**: Yeah, and because the channels are so cheap, they just exist in
the Ark, and Ark payments currently in our SDK are free.  You can just make as
many Ark payments as you want.  So, the channels are basically free.  It means
that your Bark SDK can just manage every VTXO being a small channel.  So, if you
receive any amount, it just becomes a new channel with all the capacity of your
sites.  And if you need to send, you can just use any of the VTXOs that you have
to basically send partial VTXOs out.  I think it would be pretty nice.  It's not
really hard to manage these channels with ad hoc state, you just have the
additional thing that you need to keep the channel state as well.  But already in
Bark, you kind of need backup of your database to have all your VTXOs.  We're
working on some kind of recovery feature using the Ark server, but definitely you
shouldn't rely on the Ark server.  That's the whole point.  So, we want to offer
it for users that, just like a last resort, lost everything.  I just have my seed
phrase.  We can resurrect your VTXOs.  But you should definitely have backups of
your database, because VTXOs are kind of like bearer tokens, because if you don't
know the transactions, there's no way for you to get them, other than someone
giving them to you.  And then, it would be the server, but if the server doesn't
do it, you cannot really claim your money back.  So, yeah.

Then, to go back to your Lightning channel question.  So, these are channels
between the user and the server, so on the edges kind of channels.  But we could
also support actual channels between two users inside the Ark and then use those
channels also for routing.  But, like you said, indeed, these channels, for them
to be announceable in the Lightning gossip network, you need to have some kind of
funding txid.  I was at the last Lightning spec meeting and we talked a lot about
how we could extend the gossip protocol to support not-onchain channels in a
hopefully very generic way, so that it's not just made for Ark but it can be made
for anything in the future.  I think we made a lot of progress with getting on the
same idea to go forward basically to make it general.  So, yeah, I mean that's
definitely a possibility.  I don't think the two routing channels in the Ark is
something that makes a lot of sense, as long as mempool onchain feerates are so
low.  So, we're definitely ourselves looking more into the last-resort users
having a channel with the server model.  But on the longer term, I think the
actual routing channels in the Ark might make sense as well.

**Mark Erhardt**: Well, okay, so maybe the comparison that I made with submarine
channels is not helpful, but rather you can think of the Ark as your LSP, and you
would have channels with your LSP, and your channel would be private from the
network right now, unless there's some way later to announce channels that do not
have an onchain funding output.  Okay, and yeah, it would strike me as funny to
have a channel between two users on an Ark when sending in an Ark is already
basically free and easy.  So, yeah, maybe we'll hear more about that.  I was
wondering, so Ark's still a fairly new concept, not fairly new for the people that
have been working on it, but they are not that established yet.  Could we maybe go
a little more into the trade-offs and how it's run?

So, you operate the Ark, you're the Ark service provider.  My understanding is
that to roll over the VTXOs in between you, you sort of have to provide liquidity
onchain in order to cover all of the unilateral exits.  That was one of my main
concerns when the concept was originally proposed by Burak, that the amount of
money that you would have to put up to fund all the unilateral exits would become
prohibitive.  My understanding is you found a way around needing the full amount
for liquidity.  Do you want to go a little bit into that?

**Steven Roose**: First of all, on your earlier points, we are currently the only
party operating in our server, but our server code is fully open source.  Anyone
can run and spin up their own Ark server.  We definitely hope that people will be
doing that, growing the ecosystem.  But yeah, for now, we have at Second our own
Ark server.  Yeah, to answer your question, first of all, it's what I think people
have when thinking about this.  Obviously, users bring their own money, right?
So, if someone comes into the Ark, the unilateral exit is funded by this user's
money.  We don't have to front that money.  So, when someone comes into the Ark,
they have their own liquidity that they bring.  And then, when they do a refresh,
their VTXO is kind of about to expire, it's going to soon expire.  Expiring means
that the server has access to the funds.  And then, they want to swap it for a new
VTXO.  And that's the point where the server has to use some of its own liquidity
to create a new VTXO.  And then sometime later, it can unlock these funds again
from the old VTXO.

So, basically, the amount of liquidity that the server needs to keep continuing
this protocol indefinitely is always related to how long users wait for their
refresh, right?  So, if a user is always refreshing one day before the 28-day
expiry, that means that the server needs to front the liquidity for this user for
one day, every 28 days.  So, that's 1/28 of this user's balance the server needs
to have as running liquidity.  That's the default behavior that we have for users.
We also made it free if you refresh in the very last two days of the window, that
you don't pay for the refresh fees.  So, it would mean that the server kind of
needs 1/28 of the user liquidity to operate the Ark.  We think that's quite
reasonable, especially if you look at LSP solutions.  They even sometimes have up
to 50%, because the channels are kind of balanced.  So, they have a lot higher
liquidity requirements.

Obviously then, it gets worse if users start immediately refreshing.  So, imagine
they have a VTXO that still has more than two weeks to go until expiring.  They
refresh it, then the server has to front this liquidity and wait two weeks before
they can access the old liquidity.  So, obviously, we're going to charge this user
a higher fee.  We basically have a fee schedule that is progressive with how long
your VTXO still has to expire.  So, like I said, we have the first two days for
free, then we have a fee up to seven days, a fee up to 14 days, and then a fee for
more than 14 days.  So, yeah, if you're constantly going to refresh and use up our
liquidity, we're going to charge you basically for this liquidity increasingly.
So, currently, there's no real need for users to do this.

An additional note: if you receive HTLCs because you're receiving a Lightning
payment, so if the server sends you an HTLC, these VTXOs have a way shorter
expiration time, so that it's cheaper for you to refresh them sooner.  So, we made
them, I think, four or five days.  So, if you receive them, you can basically
immediately refresh them almost for free, so that people that want to get out of
this HTLC trust model, which is a bit different, they can immediately refresh
without having to pay the full 30-day liquidity fee.  So, yeah, that's kind of how
it works.  I think it makes sense.  We're definitely ready for a lot more
liquidity than the users that we have right now, but we're only two weeks in.
Let's see how that goes.

**Mark Erhardt**: Just one follow-up question.  So, if I remember right in Burak's
model, he was talking about a round being every five seconds and then it being
refreshed.  And my napkin math indicated that one Ark Service provider would take
like 30% of the block space.  And I thought, "Well, who's going to pay for that?"
And do I understand right that, well, you must have a round at least once a day or
so if you're offering that HTLC's VTXO's time-out in five days.  So, how often do
you do these rounds, and how do they tie into the other status of the VTXOs?

**Steven Roose**: Once an hour is currently our configuration.  We could reduce it
a bit, but it definitely depends.  I mean, we're going to have to see how it goes
with cost and adoption.  Obviously, initially, because there's so few users, most
of the rounds are just one or two users refreshing and we're basically subsidizing
the onchain fee for those users.  But as soon as there's larger amounts of users
refreshing, it kind of amortizes the onchain fee to almost nothing, because it's a
fixed onchain fee that can just serve all the users doing the refresh.  So, yeah,
it's currently once an hour.  Obviously, when no one shows up, we don't do
anything.  And this means that in the current behavior, when you have a free
refresh in the last 48 hours, it means you have basically 48 chances to get in if
you want to do the interactive one.  If you do the delegated one, you just send
the server your request.  You say, "I want to get a refresh", and the server will
do it in the next round.

**Mark Erhardt**: Okay, awesome.  Thank you.

**Mike Schmidt**: Steven, I've got one more.  This is like an Ark Q&A day.

**Steven Roose**: That's nice.

**Mike Schmidt**: I suspect that some of our listeners are deep in this.  They are
developers, they are running several Ark-related wallets on signet, and things
like this, and playing around with it.  But I suspect there's another group of
listeners to the podcast who are just maybe listening from afar on what's going on
with Ark.  And we have not had anybody from Ark Labs on recently, we probably
should.  But I wanted to maybe have you do your best to articulate the big-pieces
difference between what you guys are doing at Second and what they're doing at Ark
Labs, in the most intellectually honest way that you can.

**Steven Roose**: Yeah, I think I can do that.  I think our main differences are
not necessarily our implementation.  I think we both have small differences in how
we interpret or implement the Ark protocol, but both of us are just still doing
the Ark protocol in some flavor.  I think our main difference is what segment of
use cases we're trying to focus on targeting.  We're exclusively trying to target
payment users for now.  So, we're very focused on getting Lightning UX right,
while it seems that Arkade is trying to attract developers to build applications
on their platform.  While they also support payments and Lightning swaps, it seems
that they're more trying to get people to build using their Arkade script, their
extended script functionalities to have people build, I don't know, all kinds of
DeFi applications and stuff like that.  I think that's the main difference, it's
more our focus.  I can't speak for their recent, I have not had time to follow
some of their developments.  So, I don't know if they made any recent changes to
their protocol and stuff like that, but that's how I interpret it.

**Mike Schmidt**: All right, that's fair.  Thanks for that.  And I think the other
Ark items from the newsletter we've already touched on, including the Arké wallet,
the Noah Ark wallet, and then we had Roland on talking about all these.  So, any
other parting Ark words, Steven?

**Steven Roose**: Not really.  I would say if you're a developer, try it out.
Like Roland already said, it's incredibly easy to do when you're vibe coding.
There's SDK documentation, there's REST OpenAPI documentation, so you can just
feed all this in your Claude, or in whatever agent, and you can just get stuff
done pretty easily.  So, yeah, we tried to optimize the API to be simple and just,
yeah, you can build anything you want.  If you're not a developer, definitely try
one of the wallets, Noah or Arké or Alby Hub.  If you're a merchant, you're
accepting payments, we have our BTCPay Server plugin, so you can also try that
out.  It's super-easy to use.  Yeah, just try it.

_Sparrow Wallet 2.5.0 adds silent payments receiving_

**Mike Schmidt**: Great.  Thanks for joining us, Steven.  You're welcome to hang
on or you're free to drop if you have other things to do.  We are going to jump to
the top of this segment and talk about Sparrow Wallet 2.5.0, and there's a lot
here.  You can jump into the release notes for this Sparrow release, but the
things that we highlighted here, I think the big one is adding silent payment
receive support.  Now, we covered their silent payment send support a few months
ago in their 2.3.0 release.  And we've sort of had Craig on steps along the way,
covering things like Frigate.  And we've talked, I think Sebastian was on, about
some of the worst-case scanning that is required on the receive side.  So, we've
sort of built up a little bit of knowledge around why receiving silent payments is
non-trivial and some of the tech that went into that.  So, it's great to see that
Sparrow has this actually in a production wallet now.  So, very cool.

_JoinMarket NG 0.32.0 released_

And I think we covered everything else from this segment, except for the last
item, which is JoinMarket NG 0.32.0 being released.  This is a software fork of
the coinjoin implementation, JoinMarket, community-maintained version.  And they
added support for Neutrino.  So, this would be compact block filters on the back
end.  So, they have this maker-taker model for their coinjoin setup.  And that is
now integrated at the mempool level for Neutrino, the flavor of compact block
filters.  I forget if it's 157 or 158.  And there were some improvements to the
Fidelity bonds and some other improvements you can check out from the release
notes.

Okay we can wrap up that segment that was a good one this month, and we can skip
the Releases because there are no releases this week, and jump into the Notable
code And documentation changes.  Gustavo.

_Bitcoin Core #35221_

**Gustavo Flores Echaiz**: Perfect, thank you, Mike, and everyone that did the
intro to this episode.  Now we're going to get to the final section.  So, this
week we have three PRs from the Bitcoin Core repository.  The first one, #35221,
adds support for a new BIP called BIP434, also called as a peer feature
negotiation framework or proposal, which we've covered both in Newsletter #386 and
#390, first when it was announced in #386 to the Bitcoin-Dev mailing list, and
then in #390 when it was assigned a number and it was merged to the BIP's
repository.  So now, Bitcoin Core has implemented this BIP by adding a new type of
P2P message called feature, that would be exchanged between version and verack,
which are the existing P2P messages.  And this would allow a Bitcoin Core node to
advertise optional peer features that are not yet part of this inclusion, this
specific PR does not advertise, or any specific optional feature.  It simply
creates the message type that would be used and also updates the P2P protocol
version number.  So, the negotiation mechanism is implemented.  Bitcoin Core is
also told to ignore invalid feature IDs.  Also, the feature message has to be sent
between version and verack.  So, for example, if it was sent after, then it would
disconnect with a peer that either sends it incorrectly after verack, or that
sends a malformed message.  And yeah, that's pretty much the intro on this.  But
maybe, Murch, you want to say something about this?

**Mark Erhardt**: Yeah, I wanted to explain a little bit about the protocol
version number.  So, the protocol version number was here bumped to 70017.  It
usually gets incremented when new messages are added, and this is communicated
during the handshake of two nodes.  So, when a node says now they speak version
70017, they aren't now supposed to understand the feature, what was it called?
The peer feature negotiation messages.  And if they speak an older version of the
P2P protocol, they would not be expected to understand it.  So, a node that come
that connects to another peer and says, "Hey, my version number is this or that",
will indicate now whether they understand the feature negotiation framework or
not.  Yeah, that's basically how we've been updating the P2P protocol in forever.
But that, of course, is a little bit orthogonal to whether you support optional
features or not, and so forth.

So, we also have two other mechanisms to communicate about which features a node
supports.  For example, there are the service bits which are feature flags, where
a node can indicate whether they support specific node services, for example,
serving compact block filters or whether they have the full blockchain available
to serve new IBD (Initial Block Download).  And now the peer feature negotiation
framework, where peers can communicate not just whether an optional feature is
proposed, but which version of an optional feature is preferred.  So, they could
communicate multiple different versions of a feature that they support, and then
the two peers would find out which of them they speak both and maybe support the
latest that they both speak.

**Mike Schmidt**: Does that mean that P2P protocol version won't need to be
updated as often or ever, because you'll just use the feature negotiation?

**Mark Erhardt**: Yes, maybe it'll be not updated as often, but I'm not sure if
we're done with it altogether because there might be some features that we want to
roll out generally across all Bitcoin nodes in the future, and that might happen
again with the protocol version number.

_Bitcoin Core #35254_

**Gustavo Flores Echaiz**: Thank you, Murch, and Mike for that question.  Next item
is Bitcoin Core #35254.  Here, there's an improvement to ensure that
key-derivation material that was kept in memory gets actually wiped off after it's
been used.  So, specifically we're talking about when you are deriving an
individual key from, let's say, a master key from a BIP32 master key, and some not
exactly the chain code value, but data that was derived from the BIP32 chain codes
when trying to derive an individual key was kept through values not named rkey and
temp, which are stack buffers; these were kept in memory unnecessarily after being
used.  And this applies for both BIP32 key derivation, but also BIP324, which is
the v2 P2P transport protocol, so the key material used to generate the encryption
keys for the P2P transport, where some of this key material was left in memory,
even after usage of it had been done.

So, now, the type of chain code, a specific value, is updated to have memory
cleanse the structure, basically ensuring that all this data gets wiped off memory
after being used.  And like I said, we're not specifically talking about the chain
code, but some values that were derived from that, that were used in the process
of deriving these keys.  So, now, that is updated.  Also, I wanted to mention that
in a previous newsletter, #397, we covered some similar work in Bitcoin Core.  It
was the item #31774.  Some similar work had been done in Bitcoin Core.  So, this
might not exactly relate, but similar work ensuring that a key material that is
left pending in memory gets wiped off.

_Bitcoin Core #35498_

The next item, #35498, here a specific race condition is fixed when trying to
fetch a block from a specific peer that simultaneously is disconnecting.  So, what
could happen here is that a specific thread would start the process of fetching
the block, but will not lock the peer state, which would allow another thread
simultaneously to proceed with the disconnection of the peer.  And then, the
initial thread, which is in the process of fetching the block, would basically hit
an assertion failure, because it could not be able to fetch the specific peer's
node state, because simultaneously the other thread had removed that node state
when processing the disconnection of the peer.  So, now, simply the thread that is
processing the FetchBlock request locks what is called cs_main, which basically
indicates to other threads to not process the disconnection of the peer
simultaneously.

So, when trying to fetch a block, if the peer had already disconnected, then that
failure would hit.  If the peer had not yet disconnected, then the FetchBlock
request would process.  But this PR ensures that there's no such race condition,
where another thread would simultaneously process the disconnection of a peer.

_Eclair #3318_

The next item, now we jump on to the Eclair repository.  This is item #33318.  So,
here, there's an edge case when two peers that are involved in a splicing
transaction reconnect.  So, the issue here was that the node that would reconnect
would send its channel_reestablish message.  And before it received the peer's
channel_reestablish message, it would detect, probably by scanning the Bitcoin
Network, that the spliced transaction had properly locked.  However, because it
had not received the channel_reestablish message from the peer before detecting
that the splice had locked, it would simply act as if it was offline.  It would
not send the splice_locked message to the peer.  Later on, the peers would realize
that they're sort of out of sync about the funding state, and this would cause a
force flow.

So, now, even if Eclair doesn't receive the channel_reestablish message when
reconnecting from the peer, it will still send the splice_locked message, so it
will act as if it was online, even if previously it would act as if it was offline
because it had not yet received the channel_reestablish message.  So, just a
specific edge case around when making a splicing transaction with a peer, when
locking a splicing transaction, you get disconnected.  Now, we ensure that even if
the other peer hasn't yet sent the channel_reestablish message, which is the
message you send when reconnecting, you as a node will still send the splice_locked
message to ensure that both peers don't get out of sync.

_LND #10789_

The next item, from the LND repository, is an interesting one, because last week we
covered the release, maybe it was two weeks before, but recently we covered the
release of the latest LND version, which the main point from it was the
implementation of onion messages, which are required for implementing BOLT12.  So,
now, we get the first PR related to the implementation of BOLT12, and we don't yet
have a real implementation of BOLT12, but we, for example, get just the basic
infrastructure, a message type, a codec package, and even the TLV
(Type-Length-Value) infrastructure required for later implementing BOLT12.  So,
probably in the next few weeks, we will expect more work on the LND repository
towards completing the implementation of BOLT12.

_Rust Bitcoin #6321_

The next item, from the Rust Bitcoin repository, #6321.  Here, there's an edge case
where, when receiving a segwit transaction, if something called, which I described
here as an element count, but there's another more correct way of naming this,
give me just a second.  Yeah, it would be better to say that each input has a
witness field, and those witness fields start with a stack item count.  And that
is basically a preview towards the number of items that will be included in the
witness.  However, an attacker could send a transaction pretending that there
would be more stack elements than there would actually be.  So, you could say,
"I'm going to have this amount of stack elements in the transaction".  However,
there's way less stack elements in it.  So, an attacker could lead Rust Bitcoin
into believing that it would have to reserve or force a larger allocation than
actually required.  So, a few bytes of input could claim a large witness stack and
force an allocation of up to 16 MB on Rust Bitcoin.

So, now the change is that the decoder appends the received witness bytes to its
actual content, to the actual stack elements that are included before allocating
space to it.  So, just quite a simple fix here, just ensuring that Rust Bitcoin
doesn't allocate unnecessary space before actually reviewing the stack elements
that are present.

_LDK #4685_

And the final item, from the LDK repository, #4685.  Here, LDK prepares towards the
implementation of a new BOLT proposal called BOLT12 payment proofs.  In Newsletter
#405, we discussed how Core Lightning (CLN) added the experimental support for
BOLT12 payer proofs, which basically allow a payer to prove that they paid an
invoice using the payment preimage image, but also the payer's signature and the
invoicing note signature, so basically saying, "This invoice was paid and was paid
by me and was paid to this specific node".  So, LDK wants to also implement this
proposal.  So, this item in the PR #4685 basically takes the first step by moving
the nonce used by payers for BOLT12 invoices.  It moves it from the context in the
blinded reply path.  It moves it from there into the payer metadata.  So, actually,
LDK initially had included that nonce in the payer metadata.  However, it moved it
into the offers context of the blinded reply paths when implementing that.  But
now, LDK finds itself in incompatibility with the upcoming BOLT12 payment proofs
proposal.  So, it moves back the nonce into the payer metadata so that later, when
trying to create a payment proof for a BOLT12 invoice, a payer can regenerate the
specific key that was used for that invoice, by not only his internal key state,
but also using the nonce, combining the internal key state with the nonce to
create the specific key that was used for that specific invoice.

So, this is not really a functional change, other than moving the nonce from one
part of the invoice to the other, but we should expect an upcoming feature, which
would be the implementation of the proposal of BOLT12 payment proofs, in a future
PR.  And that is the last item, unless you guys have something to say that would
complete the newsletter.  Thank you.

**Mike Schmidt**: No, nothing to add.  Thanks for doing that, Gustavo.  And we also
want to thank rkrux, Steven, and Roland for joining us earlier.  Thank you, Murch
and Gustavo, for co-hosting and for you all for listening.  Hear you next week.
Cheers.

**Mark Erhardt**: Cheers.

{% include references.md %}
