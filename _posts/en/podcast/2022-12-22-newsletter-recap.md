---
title: 'Bitcoin Optech Newsletter #231 Recap Podcast'
permalink: /en/podcast/2022/12/22/
reference: /en/newsletters/2022/12/21/
name: 2022-12-22-recap
slug: 2022-12-22-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Dave Harding to discuss [Newsletter #231]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-0-17/393257412-44100-2-6f58648129fb.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to the Bitcoin Optech Newsletter #231, our
2022 Year-in-Review Special.  I'm Mike Schmidt, contributor to Optech and
Executive Director at Brink, where we fund open-source Bitcoin developers.
Murch, you want to introduce yourself?

**Mark Erhardt**: Hi, I'm Murch.  I work at Chaincode Labs where we do Bitcoin-y
stuff.

**Mike Schmidt**: And our special guest today, Dave Harding.  Dave, you want to
give the audience a bit of your background and introduce yourself?

**Dave Harding**: Hi, I'm Dave.  For the last almost five years now, I've been
the primary author of the Optech Newsletter.  Before that, I worked on the
bitcoin.org, the development documentation, which is a few hundred pages of
documentation.  It's pretty outdated at this point, but I enjoy it.  I've also,
with Murch, contributed a bit to the Stack Exchange, obviously Murch has done a
bunch more.  And yeah, that's me, that's my background.

**Mike Schmidt**: Murch, I saw that you had hit 5 million impressions on the
Stack Exchange, is that right?

**Mark Erhardt**: Yeah, so there's this metric on Stack Exchange that estimates
how often your posts have been read by tracking how often which topics are
clicked, where you have highly ranked answers.  So, they estimate that I have 5
million reads on my Stack Exchange posts these days.

**Mike Schmidt**: Well, thank you for doing that.  I know that sometimes when
I'm searching Bitcoin things, your answers come up in the Google search results,
so thank you for that.  This is obviously our Year-in-Review Special Newsletter,
so it'll be a bit different than the previous recaps we've done on Twitter
Spaces.  I hope that we can keep our summaries of this newsletter under an
hour-and-a half; we'll see, as we've gone over an hour-and-a-half with
non-Year-in-Review recaps, but I guess we'll do our best to keep each other on
track.  And I think if we keep it to six or seven minutes per month, plus some
specials, I think maybe we can hit that mark.  So, maybe we can just jump in
real quick.

Before we go to January, I wanted to have one slight tangent and just, Murch and
Harding, if you have any comments, one thing that was asked to me recently was,
do you think 2022 was an average year for the Bitcoin ecosystem development, or
was there more progress than "usual" or less progress; and why do you think
that?  Maybe, Murch, you could take the first.

**Mark Erhardt**: Yeah, let me first do this one.  I don't know, I sometimes
feel that it's slowing down, but maybe it's just because I'm much closer to
everything and it's hard to see the big picture when you're in the middle of it.
I think that taproot, of course, was a big push, but it obviously has very
little adoption so far.  A lot of the other proposals this year seem to be more
in the preparational stage still.  I guess miniscript maybe is something that's
really rolling out, and descriptors.  I don't know, it's hard to compare,
because every in Bitcoin is seven years in real life already, and then how do
you compare stretches of seven years, you know?

**Mike Schmidt**: Dave, what do you think, as somebody who's combing through the
mailing list and PRs and things like that; what's your take on if we're average
or progressing faster or slower, or is it even a valid question?  I don't know,
what do you think?

**Dave Harding**: I think different years have different flavors.  So, some
years we go wide, and I think this is one of those years where there's a lot of
stuff going on.  Like Murch was saying, we're looking at a bunch of new ideas
and we're evaluating them, we're trying to figure out which ones are going to
work.  And then some years we go kind of deep, and those are the years where
we're really pushing on taproot adoption, or whatever; we're focused on a few
things that have reached their adoption stage, or something, where we all need
to come together and push on those.  And so, it's kind of hard to compare this
year to other years in the total amount of development.  But I think this was a
very good year.

I think that it's really important for us to do the research work and then come
back the next year and do the development work and get the stuff out there.  And
I also think, to a certain degree, the newsletter doesn't capture a lot of
stuff, because we have to focus on the high-level stuff, we don't capture the
entirety of what's happening, and there's just a lot of stuff going on.  We have
four or five major LN implementations that are all growing, and some of them in
different ways, they're doing different things.  And we have Bitcoin Core doing
its thing, we have new wallets coming out all the time that are implementing new
features.  It's just, what you see in the Optech Newsletter is just the tip of
the iceberg.  There's a lot of stuff being done at depth that we aren't
covering, but it is just as important.  So, I would say every year is better
than the year before, I would guess.

**Mike Schmidt**: Well, that's great and a very optimistic tone and I think I
agree with that sentiment.  I've shared a few tweets in the Spaces for folks to
follow along.  Obviously, if you don't have the newsletter up, great, you can
still listen, but we're going to be going through the newsletter January through
December, and if you want to follow along, great.  So, jump into that tweet and
follow along if you can; otherwise, just listen to our summary of these months.
So, I guess we could just start in with some of these innovations that we're
talking about.  We can jump into January.

**Mark Erhardt**: Let me jump in real quick, one more housekeeping item.  Do we
allow speakers or questions, comments from the audience this time, or are we
just pushing through quickly?

**Mike Schmidt**: I think it's reasonable if somebody has something to say that
adds to the discussion that they can jump in and augment the discussion or ask a
question.  So, feel free to request speaker access.  And when I see it and it's
an opportune time, we'll give you the mic, so feel free to raise your hand.

Okay, so January, I'll try to summarize in a high level and then maybe defer to
Murch and Harding to augment on some of the technical details, as that is what
you guys are great at.

_Stateless invoices_

So, in January, we had LDK merging an implementation of stateless invoices.  And
so, stateless invoices allow you to generate a bunch of invoices and not have to
store any data about them unless a payment is successful.  So, that's pretty
cool.  Now the technicals behind that, what enables that?  And I don't know if I
want to ask Murch or Harding any of these.  I guess you guys can just feel free
to chime in either way.  Why is it important that we have something like
stateless invoices so that we don't have to store this metadata?

**Dave Harding**: So the technicals, the stateless invoices work by just adding
stuff to the invoice that is generated.  So, when you pay an invoice on LN, you
send data to the recipient, the person you're paying.  So, when a recipient
generates the invoice, they add information about what you're buying to that
invoice, and they receive that back when you pay it.  So, it's a simple idea.
It's got some limitations because there's size limitations there.  But it's a
very simple idea.  And what it does is it allows you to eliminate a class of DoS
attacks against merchants.

So, if you look at say an anonymous merchant out there who's got a store on the
internet, and somebody generates millions of invoices, without stateless
invoices, they have to store millions of invoices in their database in case any
one of them gets paid.  With stateless invoices, all the data is just ephemeral.
They can just forget about your order until you pay it, which is really nice for
them.  It's not a perfect solution to this problem, but it's a really good
solution for a lot of things.  And when we're building money for people who are
going to run stores, selling things that possibly other people don't want them
to sell, we have to really think about how to prevent DoS attacks, I guess.

**Mike Schmidt**: Murch, anything to add there?

**Mark Erhardt**: I think maybe one point to stress a little more here is that
the invoice encodes the data that you need in order to make the payment happen.
So, the receiver puts in some seed for the secret that they generated, and that
they locked the Hash Time Locked Contract (HTLC) that they're eventually going
to receive to.  So, when the HTLC arrives, from the information that is in the
HTLC, they can regenerate the secret again in some fashion.  So, they do not
have to remember that they gave out the invoice at all.  They do not, both from
the logistic point of view, but also I think they can regenerate how to pull in
the money at the point when it comes back to you.

It sort of reminds me of a related problem with wallets.  So, in a wallet we
have the gap limit.  If you give out an address and then never get paid, you
have this unused address in your chain of addresses.  And you have to scan far
enough to find all your funds to bridge all these gaps of where you didn't get
paid.  And so, when you give out thousands of addresses as a merchant, and you
only get paid in some of them, you end up having millions of addresses
generated, but only thousands of them used.  And we can sort of sidestep this
problem completely with stateless invoices on Lightning.

_Legal defense fund_

**Mike Schmidt**: I'm going to segue the DoS for Lightning Node operators and
segue into DoS for legal actions against Bitcoin developers, which is the next
item in January here.  The Legal defense fund was announced, Jack Dorsey, Alex
Morcos, and Martin White announced that on the Bitcoin-Dev mailing list.  And
it's a non-profit entity that tries to minimize the headaches from legal
concerns for folks that are targeting Bitcoin developers for a variety of
reasons.  This is seemingly a recurring thing over the last few years, targets
against Bitcoin community members more generally, including media outlets as
well as Twitter personas, but this fund is specifically designed to help
developers that are being targeted with lawsuits.  Murch, Dave, any thoughts?

**Mark Erhardt**: Yeah, I mean it's kind of scary to get sued for $7 billion,
and if you know that there's other people that have your back, that might take
some anxiety out of it.  That's a pretty cool thing.

_Fee sponsorship_

Moving on to February.  February, our first item here is Jeremy Rubin's
transaction fee sponsorship idea being resurrected, which is actually an idea
from a few years ago.  And the idea with transaction fee sponsorship is actually
being able to pay the fee for a transaction in an unrelated transaction.  And
the goal there is helping other transactions confirm faster.  It's sort of like
CPFP fee bumping, but the transactions do not need to be related, which is a
cool idea.  How does that work from a technical perspective, Dave?

**Dave Harding**: We just set up rules.  Jeremy's proposal is a software
proposal.  So, we just set up a rule that says, any transaction that references
another transaction, say by putting the txid of that other transaction in an
OP_RETURN output, that other transaction we treat it as a child, we treat it as
a dependency, we say it has to be confirmed in the same block as the transaction
it references.  So, it's a very simple mechanism.  Transaction fee sponsorship,
some people really like it, I kind of like it.  But there's an outstanding
concern of it, which is we really haven't figured out all the edge cases with
CPFP.  There are still issues there.  The fee sponsorship, Jeremy has tried to
cut that down to eliminate a lot of the problems that we have with CPFP, but
that kind of makes it look hacky, it's not as flexible as we would like, it's
not as powerful as we would like, and maybe we should hold out for a better
solution.

**Mark Erhardt**: I think there were really two variants of the idea, and at
least one of them also has issues with introducing a new type of pinning vector.
And the other thing is, if you have these accounts paying fees to bump stuff,
you introduce another privacy leak, because the same account bumping different
transactions, of course, ties them together in some fashion.

_Phantom node payments_

Another notable item from February was building upon the stateless invoice
technology that we just mentioned from January, and allowing for a type of
load-balancing for a Lightning node, and that combination of those technologies
resulted in this phantom node payments.  Murch, do you want to take a crack at
explaining phantom node payments?

**Mark Erhardt**: Sure, so basically you make up a node that you purportedly
have in the network behind all of your actual nodes.  And so, you introduce this
last phantom hub that allows users that try to pay you to route through any of
your nodes to reach the phantom node.  But then in reality, you don't have the
phantom node, but you collect the money at any of your nodes in front by
basically having the secret there to already collect the second last hop instead
of the last hop.  And that allows basically, if some of your nodes go down or
get restarted or are out of liquidity, for users to automatically retry other
routes through other nodes.

So, it's an easy way to set up multiple nodes in parallel that can receive the
same payments by, yeah, that's the basic idea.  I think the only downside of
this is that it doesn't work well with split payment, what is it called,
multipath payments, because you would need a way to coordinate if payments went
through different ones of your node, whether the payment has already been
received in full.  So, yeah, kind of a nifty idea.

**Mike Schmidt**: Dave, anything to add on phantom payments?

**Dave Harding**: I just think it's a really clever method.  It's just this no
overhead, really clever adaptation of existing technology to make it really
simple to load balance payments.  It has a restriction that Murch mentioned, but
besides that, it's just really clever, I like it.

_LN pathfinding_

Moving on to March this year, another Lightning innovation is some of the work
that René Pickhardt has been doing, along with Stefan Richter.  And they updated
some research that they've done about improving LN pathfinding to make it more
computationally efficient.  I can't comment on the details there.  Is this the
same thing as Pickhardt payments, or is this just separate research from that?

**Dave Harding**: This is the same thing as Pickhardt payments.  And I think
this is an illustration of the idea that we need more researchers in the Bitcoin
and Lightning space.  René is really pushing the research side; he can do
development, but he's really pushing the research side rather than the
development side, and I find these sort of math-heavy papers very hard to
understand.  And I think it means that we need more researchers to be able to
evaluate this work, and not just produce it, but also give feedback on it and
get a discussion on this stuff really going.  Pickhardt stuff seems to be being
picked up by a number of implementations, but it's just needs a community of
Bitcoin researchers out there, I think, for us to be able to speed up the
ability to gain these insights and use them in practice.

**Mike Schmidt**: I know Clara from Chaincode has been working on the research
side, trying to solicit some of these interesting problems to the more academic
community, but it does feel like even more folks liaising these interesting
problems to computer science departments or PhDs would be valuable to (1) get
talent looking at these interesting problems, and then (2) actually solving some
of these problems.  So, I echo your sentiment there, Dave.  Murch, anything to
comment on pathfinding?

**Mark Erhardt**: Yeah, there's really a win-win situation there on the academic
research side, because I mean nobody wants to read the 15th paper about, what is
it, selfish mining or whatever, all these, or a simple simplicity contract
because that's so easy to set up in a lab.  So, getting research ideas to
researchers that will actually matter later, and that when they put in effort,
they'll actually see a significant benefit to the community afterwards and their
research actually being used later.  I think that's a really cool thing for
researchers to see.  And on the other hand, we of course benefit to get back
these new ideas this new perspective from outside from people that might have a
completely different background.

So, yeah, actually Sergei and Clara both have been working on this, but if you
know more researchers, send them the way of bitcoinproblems.org, or what the
site is.  And pathfinding, I think you've said the most things already.  Let's
move on, we don't have time!

_Zero-conf channels_

**Mike Schmidt**: Agreed.  The next item from the newsletter highlights some
changes that were made in the PR BOLT910, which changes two things about the LN
specification.  First is this addition of Short Channel IDentifiers (SCIDs),
which are aliases; and the second thing is adding a zero-conf feature BIP.  And
so, with those two changes to the BOLT spec, you can enable zero-conf channels.
Dave, what's a zero-conf channel?

**Dave Harding**: So, it's this idea that when somebody opens a channel with you
and they send you the full balance of the money they opened the channel with,
you can pay back through them with zero trust.  You can't lose any money in that
case.  So, we can actually have zero-conf channel opens in certain cases.
Again, it has to be a case where the person opening the channel sends the full
balance, or actually not the full balance, but any money they send to you, you
can pay back through them, because the worst case that would happen is that you
would lose money you didn't already have, or you would lose -- I don't know how
I'm saying that.

But it's just this basic idea, it's been around for a long time.  I think it's
been under a couple of different names and there's some vendors who have been
doing it privately, but this adds it to the specification so that all LN
implementations can, if they want, implement it in the same way and it can be
widely used.  So, it's just another one of these clever ideas that just takes
stuff out there and makes it available.  It's really cool.

**Mike Schmidt**: The example that you gave, Dave, was sort of, I guess you
could say you don't require trust in your counterparty for that zero-conf
channel.  Although, I guess if you did have a business relationship or some
other reason to have trust in the counterparty, you could also open up a
zero-conf channel that doesn't fulfill those properties that you outlined if you
trust that counterparty.  Murch, any comments on zero-conf?

**Mark Erhardt**: No, I mean, it's kind of obvious why you want it.  Nobody
wants to wait for 20 or 30 minutes to open a channel, because they are probably
onboarding right now because they want to try it out or use it.  So, the 20- to
30-minute break that people need to take in demonstrating how Lightning works or
setting up a new user or trying to make your first Lightning payment really
ruins the experience.  So, this sort of sidestep and short credit is a huge UX
improvement in this case.

_Summary 2022: Replace-By-Fee_

**Mike Schmidt**: After March, we had included in the newsletter a couple
summary sections, little sidebars, if you will, and there was a bit of a summary
about RBF.  I know the community in general is largely fatigued with this
discussion, so I don't know how deep we want to get into it since we've also
covered this recently on several of our recaps, but maybe if either of you feels
comfortable with the tl;dr here; Murch, I see you raising your hand.

**Mark Erhardt**: Yeah, I was trying to wave it goodbye!  Yeah, we've talked
about this so much already in the past few weeks.  I think that, I don't know if
I've said this before, I kind of see both sides.  I see the UX improvement for
merchants, I generally don't like the idea of zero-conf payments.  I see how
it's a useful thing if you're accepting payments and if you're doing the work of
mitigating your risk.  I don't want it to become sort of a prevalent style or
entitlement of how you can use Bitcoin, because I don't think that it'll be a
way that you can use Bitcoin in the long term.  I am kind of concerned that
trying to get it even more wedged into how Bitcoin is used today is going to
give us trouble next decade.

So, in that case I'm kind of for having them pull full RBF already.  But in the
other way, I don't see a huge benefit of ruining zero-conf right now.  I think
it reduces the signal that you can add to transactions by showing, "Hey, I do
not intend to replace this", or, "I do intend to be able to replace this", and
now everything just looks the same.  On the other hand, that's also a privacy
improvement, if everything looks the same, yeah.  So, I think there's kind of
weak arguments in all directions, and nothing is super-convincing.  It's kind of
good that we've got it merged in.  I'm also satisfied if it doesn't activate
immediately on the network right now.  So, yeah, I don't know, how's that for a
tl;dr?

**Mike Schmidt**: Ecurrencyhodler?

**Ecurrencyhodler**: Hey.

**Mike Schmidt**: Do you have an opinion about RBF?

**Ecurrencyhodler**: No, I've got a question.  So, tying the two concepts of
zero-conf channels and RBF, is there any risk of zero-conf channels disappearing
with RBF?

**Mark Erhardt**: No, I don't think so, because usually you open a zero-conf
channel when somebody is getting paid, right?  And in this case, the Lightning
Service Provider (LSP) is putting in the money to open the channel and also to
allocate a balance to the recipient.  So, yes, the LSP could then take back
their money in that case, or vice versa.  I mean, you're trusting a zero-conf
payment.  Well, if you want that zero-conf payment, I think the dynamic in a
zero-conf channel is so different from a regular zero-conf payment already,
because you already have sort of a semi-trusted relationship with an LSP.  You
usually have some sort of authentication with them, if it's only your Android
account or whatever.  I don't think that it will be impacted by mempool full
RBF.

**Dave Harding**: I just wanted to just say, yes, these are two different
layers, if you will.  So, the full RBF, I guess I'm just going to ramble like
Murch did.  The worst case is that somebody takes back money that they sent you,
but with the zero-conf channel, you would have already spent that money.  So, if
they take back that money, you come out ahead.  So, the person creating the
transaction has no incentive to opening a channel.  The person opening a channel
has no incentive to RBF that channel open because then they could actually lose
money.  So, the RBF policy does not affect zero-conf channel opens, even though
they both have similar names of zero-conf in them.  And I'm sorry, I didn't get
Mike's earlier question.  I just wanted to go into that and say, I think rather
than look at the mempool RBF debate, one of the things that we should look at is
what we take away from it.

So, there was a lot of debate about this PR adding it, you know, should Bitcoin
Core look at their merge policies; was there anything here that could have been
done better?  We knew this would be controversial, and it got merged in a
relatively quick amount of time.  I think it was fine, but what could we do
better in the future?  And we need to think about relay policy more in the
future when it comes to things like v3 transaction relay policy, other mempool
and relay policies that we're going to consider, more carefully.  Because we had
a lot of interesting ideas come up at the last minute while Bitcoin Core was
trying to release v24, that would have been better if we had those discussions
when the PR was just still open, or even at an earlier time.  So, I think that
hopefully the path forward is not looking so much at the mempool RBF, but at
other ways we can make changes to Bitcoin in a more thoughtful way.

**Mike Schmidt**: Murch, anything else to say on that topic?

**Mark Erhardt**: Maybe one more thing.  I think that especially in the RBF
debate and maybe also in the OP_CHECKTEMPLATEVERIFY (CTV) debate earlier in the
year, the discussion culture did get a little rough at times where people were
sort of making it their whole job of replying to every single comment, or
inviting Twitter to restate their opinion from DoSing GitHub threads.  And I
think, please just don't invite people that haven't really read the thread to
comment on everything; or if you if you have an opinion to state, don't state it
after every single other response, but state it once or twice while working,
then that would just be so much more helpful.  Thank you.

_Silent payments_

**Mike Schmidt**: All right, moving on to April.  April brought the idea from
Ruben Somsen about silent payments, and there's this class of, I think it was
BIP47 perhaps, and there's a silent payment proposal as well that allows you to
provide somebody with some sort of an identifier, and in some cases that
identifier is published onchain, and in some cases in silent payments, I think
you provide that identifier offchain, and someone who wants to pay you uses that
identifier to generate a unique address to pay you at.  One question I had that
maybe I forgot or I was never clear on is, are you actually providing an address
or are you providing some sort of a non-Bitcoin address in order to generate
these actually actual Bitcoin addresses that you want to get paid at?

**Dave Harding**: You're providing an identifier, if you will.  So, it's kind of
like an address, but it's not a Bitcoin address.  Software that is unaware of
silent payments can't pay that address.  A software that is aware of silent
payments can take that address and transform it into something kind of like an
HD seed, from which it can derive actual addresses to pay, and will hopefully
pay a different one each time because it's combined with information from the
transaction that is being spent from.  So, it's going to be different for every
payment, which is good because it means there's no address reuse, makes it hard
for blockchains, spy organizations, analysis organizations to figure out who is
paying who.

**Mike Schmidt**: And I guess contrasting that with BIP47 is, the identifier
would be put onchain in the BIP47 example; whereas with silent payments, that
would just communicate out of band with what that identifier would be.

**Mark Erhardt**: Yes, I believe so.  So, especially the payments are not
identifiable as such, and I think in BIP47, the worst part is the announcement
transaction that every user has to make before they can first start paying the
recipient.  So, per user recipient period, there has to be an announcement and
it always pays the same announcement or notification address of the recipient.
So, I think you learn basically publicly that a specific nim is starting to get
paid by another person, and that's just terrible.

**Mike Schmidt**: I think the most relatable use case for folks of why you might
want to do something like this would be maybe perhaps a donation identifier,
whereas if you put a Bitcoin address on your website and everybody can see who's
donated and how much, and there's all kinds of privacy leakage there.  Whereas
if you put this identifier up, there's no way to tell how much you've collected
or who's paid you, so some interesting privacy benefits there.  And I think
there was some work on actually implementing this throughout the year.  W0ltx
made some progress there.  I think there's actually a PR for a new type of
descriptor for silent payments.  So, some nice progress on that front.  Anything
more on silent payments, guys?  Okay.

_Taro_

The next item in April here is Taro, which is a protocol for letting users
create non-Bitcoin tokens using the LN and settling in bitcoin, or settling on
Bitcoin's blockchain.  So, the use case is to pass these tokens around using the
LN offchain.  And there was actually a similar proposal from I think the RGB
team, who has a similar issuance on Lightning and is also using taproot.  Murch,
what are your thoughts about passing around non-BTC-denominated tokens on the
LN?

**Mark Erhardt**: Yeah, I think it's definitely useful.  I do have some
thoughts.  Well, one of the things that I like the least about Ethereum is the
whole Ponzi ecosystem, where it feels like every person has their own coin and
is trying to grift a lot of money out of everyone else.  And so, what we get
here is specifically a way of issuing IOUs.  So, there's always a central issue
here that you have as counterparty risk ultimately, because you need to redeem
against them.  So, I think that in a way is nice and clear.  Or, I mean you
could also create a coin that has a fixed amount and just starts living on its
own but has no guarantee to be redeemable also.

What is really nifty about it is how it can be transferred on the LN, where
basically only the edge channels need to know about the IOU denomination, and
everything else in between gets routed through the LN in the satoshi payments,
or bitcoin payments, I should say.  I think that this has the potential, if a
lot of people use this, to get an actual decentralized trading marketplace going
for currency exchange.  So, if you have on the one side, for example, I don't
know, US dollar IOUs issued by me, and on the other hand you have some IOUs
issued by someone in Europe denominated in euros, you can buy euros with US
dollars through the LN, or bitcoins or whatever you want to buy, and trade
through the LN and you only need to get the offer on the one side and the offer
on the other side.

It might foster more Lightning traffic on the one hand and it might also get an
actual decentralized currency exchange going, just people trading dollars,
Tether, bitcoin directly on the LN on a marketplace where they discover each
other.  So, I mean that's a few years in the future maybe.  But looking at what
happened this year with Tornado Cash and the regulation of certain exchanges,
and the IRS looking even more closely at private payments of minuscule amounts,
I think this is kind of an interesting development.

**Mike Schmidt**: Ecurrencyhodler, you have a comment?

**Ecurrencyhodler**: I actually have a question.  So, for this tokenized
stablecoin on Lightning or Taro, which I guess can also be onchain as well, or
actually specifically for Lightning, is it such that when I send a $10
stablecoin from me to you, Murch, that the equivalent amount in sats is being
routed from me to you, or is it literally a tokenized asset inside the Lighting
channel?

**Mark Erhardt**: So, you would have a channel with one channel partner that is
denominated in that asset, and I, in order to be able to receive the IOU or
token or whatever, I would also have to have a channel.  We could even have two
separately denominated channels.  And the flow is such that you ask for an
invoice from me, I ask my channel partner, "Hey, how many sets do you want in
order to send me, whatever, 10 Tether?"  He says, "This amount of sats", then I
give the invoice to you with basically a route hint.

The last hop will be Tether from my channel partner to me and you have to send
this many sats to my channel partner.  And then you go to your channel partner
and say, "Hey, I have Tether; how many Tether do you want in order to route this
many sats to Murch's channel partner?"  They give you an offer, you pay them in
Tether, they route a Lightning payment to my channel partner and I receive
Tether.  So, nobody except the endpoints actually has to know that it's
denominated in anything else but bitcoin.

**Ecurrencyhodler**: So, the amount in sats is not getting routed over.  Okay,
yeah, that's helpful.  For whatever reason, I heard that there are different
proposals where if I was sending like $1,000 of Tether, that $1,000 of sats
would be getting routed eventually to that person, which that didn't make sense
to me.  But okay, cool, thank you.

**Mark Erhardt**: Yeah, you can also have Tether and make a Lightning payment,
right?  They just ask for an invoice, they tell you, "This is how many sats I
want", and you then go to your channel partner and say, "Hey, I have only
Tether.  How much do I have to pay you in order to get this many sats to the
recipient?"  So, you can cross at least from your starting currency to bitcoin
to the recipient currency, both of the endpoints optional.

**Ecurrencyhodler**: What are the limitations of this, or are there any
downsides to it?

**Mark Erhardt**: My biggest worry is that we get a huge economy of things
denominated in all sorts of other currencies and eventually it bleeds back into
onchain incentives and fucks up the mining incentives onchain, or something like
that.  Or that we get this whole grift universe onto Bitcoin that is currently
nicely away from Bitcoin.  I mean, we have some grift in Bitcoin, but not nearly
as much as other parts of the crypto universe.  So, yeah, that's maybe the
biggest downside.  Other than that, it looks like a pretty clean design.  You
need, I think, an onchain transaction to create the asset, and then, of course,
you need onchain transactions in order to create asset-denominated edge
channels.  But other than that, everything else after that can happen on a LN.

So, sounds like a very clean, low data footprint, onchain way of getting US
dollars and other assets onto Bitcoin, which I think is, especially in this year
if you look, for example, at El Salvador, where people cannot afford for their
money to lose three-quarters of the value, if they actually get paid in Bitcoin,
and it's their whole amount of money, they don't want to hold through a bear
market like this, maybe, but they want to hold dollars.  And this way, we could
get some of those remittances onto the Bitcoin Network and actually foster
Lightning liquidity and traffic that way.  So, yeah, maybe I'm overlooking some
downsides.  I have not looked into Taro super-much.  Obviously, it's also pretty
early in the proposal and we don't know how it'll look like when it actually
gets done and what trade-offs might still need to be made until then.  But yeah,
it sounds interesting so far.

**Mike Schmidt**: Dave, do you have any comments on this discussion?

**Dave Harding**: Not really.  I think Murch has pretty much said everything I
would have said.  You know, he's right.  If there gets to be a lot of money in
this ecosystem, we have to think about how it impacts miner incentives.  That's
the only really scary part about it.  The rest of it is, you know, just see if
it gets implemented, see if it works, see if people use it, see how it goes.

**Ecurrencyhodler**: So, if I'm understanding you all correctly, it's like,
let's say I send $1 billion of Tether over the LN, and it's on a recently
established channel or something, I could be incentivized to double-spend that
and take that money back onchain and disrupt the Lightning channel; am I on the
right track there with incentives?

**Mark Erhardt**: Yeah, and also there's not more fees just because you have a
big asset created, because it's a single payment onchain to create the asset
channel.  So, you might get into, let's say the asset is only ten blocks old or
something, but somebody created billions and it actually travels really well, I
don't know, some big celebrity creates a new coin and it travels within the
first week as like freshly baked bread, and now somebody rolls back ten blocks
in order to revert all that money, or something like that, that would just be
horrendous.

_Quantum-safe key exchange_

**Mike Schmidt**: Okay, moving on to the last item from April, which is
quantum-safe key exchange.  And this was a proposal that suggested allowing
users to receive payments to a public key and it would be secured by a
quantum-safe algorithm, which I believe would require a soft fork.  Maybe real
quick, Dave, can you summarize what quantum-safe is and maybe a quick summary of
that proposal, if you recall it?

**Dave Harding**: Quantum-safe is an algorithm that we don't believe quantum
computers would be able to figure out significantly faster than a classical
computer.  So, the phones we're on and the laptops we're on right now, those are
all classical computers.  Classical computers always make me sound like they're
really old, and quantum computers work on a different principle, and they can
solve things based on the discrete logarithm problem a lot faster, at least in
theory.  People are working on building quantum computers and it's unclear to us
how fast they're going to make progress on that.  They can build, you know, very
basic quantum computers right now.  Will they be able to build fast quantum
computers in the near future?  We don't know.

So, the idea here is that we know of different algorithms for public key
cryptography that are not based on the discrete logarithm problem, so they
should be resistant to quantum computer attacks.  Some of them have been fairly
well studied.  Should we add one of those to Bitcoin to allow people to use it?
And obviously, if there were no downsides to it, if there were no complications,
we would do that right now, why not?  The downside is that all the algorithms we
know that are quantum-safe require much larger public keys or much larger
signatures than what we have now.  So, using them would take up a lot more chain
space and we'd have fewer transactions per block, possibly a lot fewer
transactions per block.

There are a couple clever ways we can go about this, and one would be just kind
of adding them as a backup option.  So, like taproot allows you to choose
different spending conditions at the time you spend, we could set it up so that
you could choose whether to use a schnorr signature when you spent your coins or
you could choose to use a quantum-safe signature when you spent your coins.  And
we would just, as a matter of relay policy say, right now while quantum isn't an
issue, we would not allow quantum-safe spending, you have to use schnorr.  But
if quantum ever become an issue, we could just upgrade our nodes overnight
because it would be an emergency, and everybody could use quantum-safe spending.
That's the basic idea here.  It's something that we need to discuss more, is
basically my take on it, figure this out, but it would be a good thing to work
on.

**Mike Schmidt**: Thanks for that summary, Dave.

_MuSig2_

Moving on to May, the first item here is talking about schnorr multisignatures
and the MuSig2 protocol.  I don't know if MuSig2 was proposed in 2022, but I
know that there were some significant developments this year, and some feedback
and a vulnerability was found.  I'll either let Murch or Dave answer this one,
but what is MuSig2 and what is its relation to schnorr multisignatures?

**Mark Erhardt**: So, I think MuSig2 was created, or proposed, in 2020, so it's
been around and long time coming.  I think there was a minor issue in multiparty
setups with a specific situation, and I think it was easy to fix.  So, it's just
sort of maybe now that people are thinking more how this will get implemented,
what are exactly the protocol steps, they're looking at it in another angle
still, and somebody, I think the authors themselves discovered it at that point.
So, yeah, it's just part of the maturing.  I think that MuSig2 is ready to be
used now, the spec is out, if I remember correctly.

**Mike Schmidt**: And I think people are aware of, or they've heard the benefits
of moving to schnorr signatures, in that you can sort of combine multiple
signatures into one signature, but I think it's maybe less understood that
that's just not out of the box, that these MuSig proposals are the method in
which you would go about combining these signatures into a multisignature.  Is
that right, Dave?

**Dave Harding**: That is correct.  This is one of three methods that we, well
actually, a lot more than three, three methods for basic multisignature, which
is everybody signs everything.  So, we have the original MuSig proposal; MuSig 2
reduces the interaction requirements by a little bit; and then there's MuSig
deterministic nonces, which would be possibly better for certain cases of
signers.  There's also other special signature proposals that are related.  We
don't cover any of those in this newsletter, but there's progress being made on
those, too.  Those are cases where a subset of the people who can sign, sign.
So, it would be like a 3-of-5 kind of signature policy deal, whereas MuSig is
for 5-of-5 policies, if you would.

**Mark Erhardt**: Also, if you're interested in this topic, check out the latest
Chaincode podcast.  We had Tim Ruffing and Pieter Wuille on, and they talked
about MuSig, taproot, schnorr signatures, multisig and threshold signatures,
trust, second part of that conversation coming out soon.

_Package relay_

**Mike Schmidt**: The next item from May this year that was cited in the
end-of-year recap is this draft BIP for package relay.  And I think it might
make sense to quickly summarize some of the motivation for that, including
issues with CPFP fee bumping and transaction pinning.  So, we've somewhat
alluded to some of that throughout this newsletter, and we've talked about it
previously, but Murch, maybe just a quick summary of, what is the problem with
transaction pinning?  What are we partially trying to solve here with Package
Relay?

**Mark Erhardt**: So, the basic idea is that you sometimes get a transaction
pushed out of the mempool because there's too much other stuff waiting and it
drops out of the minimum feerate space.  So, now you need a way of being able to
reintroduce it and the idea is here, well, if I bring my own child that pays
more already and tell you about both of them in one step, then it'll propagate
together.  And this is just formalizing that idea for this case and some other
cases.  And this could also, for example, be used to fix some pinning issues.

**Mike Schmidt**: Dave, what are your thoughts, or do you have something to add
to package relay, CPFP, and transaction pinning all tied together?

**Dave Harding**: So, I guess the basic -- I'll take a little step back here.
So, we have a bunch of protocols like LN, LN channels that are based on the idea
of pre-signed transactions.  So, if you have multiple people cooperating to
create a transaction, you can't bump it yourself using something like RBF.  You
can't add feeds to it, you can't change that transaction in any way.  That's not
entirely true, there's signature hash (sighash) flags, but basically you can't
change a transaction and allow these protocols.  And so you need to be able to
add fees later.

In order for that mechanism of adding fees to be robust, we need to be able to
package both the original transaction and the transaction that's adding fees,
the child transaction together.  And so that's what package relay is about.  And
it's really important for these contract protocols, not just LN, but a lot of
stuff that we can envision, that we have a reliable CPFP, fee bumping mechanism,
and for that we need package relay.  It's just an important part of Bitcoin's
future, I think, and I'm glad there are really smart people working on it.

_Bitcoin kernel library_

**Mike Schmidt**: Great, thank you guys for those explanations.  The next item
from May was regarding the Bitcoin Kernel Library Project, referred to as
libbitcoinkernel.  And the goal there is to separate the sections of code in
Bitcoin Core that are consensus from the rest of the code, and put that into its
own separate library.  Murch, why do we want to do that?

**Mark Erhardt**: It would make it much easier to separate out this important
part of interpreting the Bitcoin Core rules and allowing other projects to reuse
that part so that, even if there's multiple implementations of nodes and
wallets, we don't have a different implementation for the consensus rules.  So,
for example, we saw two consensus bugs last month, with the LND transactions,
where somebody created transactions that their library didn't parse properly.
So, if they had, for example, been able to use libbitcoinkernel under the hood
in BTCD for the consensus rules, that would not have happened.  So, that's the
general idea here: package all the important consensus rules in a single small
kernel that everybody can build around.

**Mike Schmidt**: You mentioned the case in which there's alternate
implementations of consensus logic and being able to just easily import that
into other node software or other software.  Are there advantages outside of
that, like for example, just compartmentalizing this consensus code into a
separate library; does that help with testing even within the Bitcoin Core
project or any sort of advantages within the project?

**Dave Harding**: I'll take this one.  I think it probably doesn't help a lot
with testing specifically, you can do all the same tests either way.  But what
it does is help isolate it, and that makes it easier to see when we are touching
things that are part of consensus.  Consensus code in Bitcoin Core is kind of
Bitcoin's constitution, so we want to see when stuff is going on and being
changed with it.  The ideal outcome, which I don't know if we're ever going to
get there, but the ideal outcome would be to move all the consensus code to its
own repository so that it would be very, very clear when consensus code is being
changed, and so that every node implementation could in theory, again I don't
know if we're ever going to get there, use the same code.  It would be all the
same.

Now, there's probably even more idealized outcomes than that.  I don't know that
we're ever going to get to either one of those outcomes, but isolationism of
consensus code is good just for the review process.

_LN protocol developers meeting_

**Mike Schmidt**: Moving on to June, the thing that we've highlighted here in
June is the Lightning developers meeting that occurred in person, and there was
a ton of topics discussed.  Obviously, I think a couple things at least I
thought was interesting that maybe you guys can comment on, the first one being
taproot-based Lightning channels.  Murch, I might throw it to you on this one.
Why would we want taproot-based Lightning channels; what are the benefits of
moving to taproot-based Lightning channels?

**Mark Erhardt**: So, there is a tiny benefit in that the transaction will be
smaller and there will be less cost for closing the channel, because you no
longer have to multisig onchain.  You can do a single-sig, MuSig, keypath spend,
P2TR keypath spend.  But the bigger benefit is probably for privacy.  Taproot
channels would look the same as P2TR keypath spends of a single user, so it
would be firmly indistinguishable from outsiders when there is a cooperative
channel closed from any other P2TR payment.  And so there's a huge privacy
benefit there.

There's some related things that don't directly tie into taproot channels, but
we can also use taproot in the sense that we make Point Time Locked Contracts
(PTLCs), instead of HTLCs, which makes it easier to hide whether someone is
appearing multiple times in the multi-hop payments.  So, yeah, there's some cool
benefits from combining taproot into Lightning.

**Mike Schmidt**: Another thing that I thought was interesting, and Dave, you're
free to comment on the taproot-based channels of course as well, if you have an
idea, but one thing that I also thought was interesting was this idea of
recursive MuSig2, too.  Dave, maybe you can comment on what that is and why that
might be helpful for Lightning?

**Dave Harding**: So, in a Lightning channel, you're going to have two parts;
you have Alice and Bob are going to cooperate to manage that channel.  Well,
what if Alice doesn't want all of her funds to be controlled by a single private
key on her laptop?  She wants to use two keys, she wants one to be on her laptop
and one to be on her hardware wallet, and there's some other problems with that
kind of behavior in Lightning.  But what if you want to have the subsidiary
signers?  In the current protocol, the current Lightning protocol, where we
don't use taproot, we can't easily do that the way keys are managed, because we
have to specify the number of keys, it would be just a whole big pain.

But the idea of recursive MuSig2 would be if you can already combine signatures
using the MuSig protocol, you can take two public keys and you can kind of treat
them as one public key, and you can treat them as being able to create a single
signature, why not have three?  So, Alice combines her keys without Bob knowing
anything about it, and can sign but still keep those keys separate.  And so,
it's a really clever idea and it's been discussed how would that work.  First of
all, is that conceptually possible with MuSig2; and how would that work from the
Lightning protocol?  Are there any changes we would need to make to the proposed
taproot Lightning protocol to make that work?

If it can work, that would be really clever.  It would be great to have better
multisig technology all through Lightning, because it is a powerful security
enhancer to have multiple devices that have to coordinate to sign something and
hopefully prevent something from being signed in a case where you wouldn't want
it to be signed.

**Mike Schmidt**: I've sort of picked two of what I thought were interesting
takeaways from that LN developers meetup.  The things from that meeting that you
thought would be notable here?

**Mark Erhardt**: I think that offers is pretty interesting too and also just, I
want to stress the importance of developers getting together in person
occasionally.  I find that every time the Bitcoin Core devs get together and you
put your heads together and get to know people, you just work better the rest of
the year together because once you've met people, there's just a little more of
an understanding how they are, what they think about, and a mutual charitable
position.  Like, you've met this person and you are less likely to think that
they're attacking you.  So, people just tend to work better together.  And then,
just putting everybody in a room and throwing ideas out there just is usually a
very nice change of pace and creative explosion.

**Mike Schmidt**: Murch, you mentioned offers.  Did you want to elaborate on why
you think offers is an important innovation?

**Mark Erhardt**: I think it's coming later again, so let's not.

**Mike Schmidt**: Okay, we'll skip it.  Dave, anything else from the Lightning
developers meetup that you thought was interesting to talk about?

**Dave Harding**: I wanted to echo Murch's comment about how great it is to have
people in a room and how quick it is for progress.  But I also wanted to thank
Laolu Osuntokun for writing up this summary of the meeting, because for people
who weren't there, and I typically don't go to these things, it's really great
to have notes or minutes or any sort of summary of these meetings just so we
know what was discussed there, and can see what the developers are talking
about, what they're really interested in and where progress might be going in
the future.  So, thank you, Laolu.

_Onion message rate limiting_

**Mike Schmidt**: Excellent.  Moving on to July, t-bast posted a summary of an
idea for rate limiting onion messages in order to prevent DoS attacks.  And then
there was some discussion about alternate ways to prevent those sorts of DoS
attacks.  We're speaking about Lightning DoS attacks here, so if you're routing
payments through the LN, you're using HTLCs.  But there's this notion of onion
messages, which are different and are open to this sort of an attack.  Murch,
can you sort of contrast routing HTLCs versus routing onion messages, and why
are there onion messages on the LN?

**Mark Erhardt**: Well, from the perspective of the routers, I think they look
basically the same because you cannot tell what is the content of the onion that
you're passing on, right?  So, onion is here trying to convey the notion that
the package is wrapped in layers and every hop only peels one layer.  It's sort
of like a joke gift at Christmas where you have 15 layers of wrapping paper
around it, right?  Every time you pass the package on, you peel off another
layer, and then it says, "Pass it to this person, pass it to that person", and
so forth.  So, you cannot tell whether somebody is trying to make a payment or
just routing a message to another person.  If people started putting chat
applications or routing videos through Lightning or other things, then you might
get this explosion of traffic that locks up a lot of HTLCs for periods of time.

If you introduce a rate limit and only give a certain amount of your slots to
each person that you're paired with, you limit that they can lock up your whole
channel and make it inaccessible for others and actual payments.  I think we
have a bunch of other topics later in the year that go in a similar direction
with the jamming research recently and various mitigations for that that we
discussed in the past few weeks, so, yeah, I think this is an earlier one of
that.

_Miniscript descriptors_

**Mike Schmidt**: Okay, great.  The second item in July that we highlighted in
the recap for this year was discussion around adding watch-only support for
script descriptors written in miniscript.  And I'm curious as to, Dave, your
summary of how Bitcoin script, descriptors, miniscript and policy are all tied
together.  Maybe you can provide a concise recap of how those things interact.

**Dave Harding**: Oh gosh, no pressure!  So, they are all related.  So,
miniscript is a reduction of Bitcoin script to a simpler language, at least in
programmer terms.  And from that, there's a policy language that allows you to
write miniscript.  So, in the policy, you can say the outcome that you want.
You can say, "I want a policy where Mike and Murch and I can all cooperate to
spend some bitcoins or after a year, any two of us can sign to spend those
bitcoins, and we can use that as the donation fund for Bitcoin Optech", or
something.  And that can be compiled out of the miniscript.

The descriptor looks a little bit more like policy language, but what its job is
to do is to tell a wallet how to find the outputs that are being spent to it.
So, if you think about a bog standard Bitcoin address, your wallet searches the
blockchain for transactions that pay that address, and when it sees those
transactions with an output paying your address, it says, "Well, you've received
such and such bitcoins".  But we want a more general way to do that.  We want to
say, well, instead of looking for a specific address, I want you to look for any
output that pays any address for my HD seed.  And then we come back to the idea
of Mike, Murch, and I all sharing a wallet, we're going to tell the wallet,
we'll look for any output that pays Mike, Murch, and I using this weirder
contract that we've come up with.

So, we need a way to communicate all this stuff between different programs.  We
need a way to communicate for Mike's wallet and my wallet and Murch's wallet to
all be able to look at the blockchain and find these transactions that pay this
weird script that we've come up with.  So, that's what descriptors does, it
tells us how to do that.  Miniscript policy allows us to write the policy;
miniscript allows us to ensure it's correct and tell us a little bit about how
much it's going to cost us to spend it; and all these things work together and
it's really a powerful tool for greater wallet interaction in the future, which
as you can see with LNs, every Lightning channel is two wallets working
together.  In the future, we're going to have other contract protocols and we're
just going to have more complicated wallet policies.

We need these tools, these are very fundamental tools to really getting the most
out of Bitcoin.  It's been a long road.  They just get basic multisig support
working in and we're getting more advanced.  We need better tools to be able to
manage our policies.  I think this is somewhere where Bitcoin is really
accelerating over various altcoins that are focused on these onchain contracts.
With miniscript and policy, and whatnot, we're keeping a lot of this data
offchain, we're keeping it private to the people who are involved in the
wallets.  And it's just it's a really powerful direction of Bitcoin that I think
doesn't get a lot of attention because it isn't a consensus change.  It's just
all outside of consensus, but it's really important for our future.

**Mike Schmidt**: One technology that I don't know that we highlighted in this
newsletter, that I know is a favorite of Murch's and touches on this topic of
multiple parties interacting, is PSBTs.  Murch, I know you like to sing the
praises of it.  Do you want to comment on that quickly here in the context of
what Dave's outlined, as sort of a burgeoning ecosystem around different parties
interacting?

**Mark Erhardt**: I mean, I come at this from the background of having worked on
the wallet at BitGo for multiple years, and we essentially had three separate
public keychains being generated in the setup of that, and then we had a
proprietary implementation of what essentially is now Partially Signed Bitcoin
Transactions, PSBTs.  And with PSBTs, of course, if everybody had that, we could
have just used hardware wallets for the users' key plug and play, because
hardware wallets are now adopting how to do PSBTs for signing multiparty and
watch-only wallets, right?  And then with descriptors, it gets even simpler to
express what exactly the keychain is that you're referring to, because even if
you have a master key, you might not know the derivation path yet.

But in a descriptor, this is all folded in already.  And then of course, the
actual spending policy, what you're doing with the public keys and how it's set
up and how the transaction is going to look like before it's even created,
that's encoded in the miniscript.  And so with these three things, I think that
somebody could build a wallet setup like BitGo, much, much simpler, much, much
cleaner, better UX.  Yeah, you know, if you're looking to do a startup!

_LN interactive and dual funding_

**Mike Schmidt**: Thanks, Murch.  Moving on to August, the first item that we
note is Eclair merging support for the interactive funding protocol, which is
the dependency for the dual funding protocol.  Dave, will you explain what dual
funding is and why we need some sort of interactive funding protocol to
facilitate dual funding?

**Mark Erhardt**: We're not hearing you if you're speaking.  Maybe you're muted.

**Mike Schmidt**: He showed up with a blue dot for me, which I don't actually
know what that means.

**Mark Erhardt**: Oh, no.  Shall I maybe weigh in on an edge case for dual
funding for a bit.

**Mike Schmidt**: Yeah, dual funding and interactive funding.

**Mark Erhardt**: Yeah, even though the white paper specified that both
participants would add some funds to the channel, and you would basically have a
starting balance that is split between the two openers together, in practice, it
has proven to be hard to coordinate a channel opening together.  Now, I think
this has finally been formalized in the form of an update to the BOLT spec and
other parties, the implementations also starting to implement support for it.
And now you can actually open channels with funds on both sides from the get-go.
And yeah, I think that might make it easier to get started with Lightning,
because one of the biggest issues is when you open your first channel, you only
have balance on one side of the channel, and that sucks.

I think the interactive channel open is maybe also referring to alternative
approaches to get funds on both sides, which I think is, for example, the
sidecar, a product by Lightning Labs, where you basically pay through what is
it, Lightning loop or Lightning pool, in order to establish a channel from a LSP
that immediately has a balance on your side.  You buy liquidity and a new
channel in one, if I remember correctly, like I think a third party is funding
the channel open between two parties.

_Channel jamming attack mitigation_

**Mike Schmidt**: Thanks, Murch.  We'll keep on the topic of Lightning here.
We're moving into Antoine and Gleb's guide to channel jamming attacks.  I don't
think we have time here to go into maybe the details of that paper and some of
the other research that has happened this year, but maybe, Murch, you can give a
quick overview of what are channel jamming attacks, what are the two
classifications, and then maybe elaborate on that a bit?

**Mark Erhardt**: So basically, there's two limits in your channel.  There is
the capacity of how much funds can be in flight at the same time, and there is
the number of slots that a channel has, which is 483.  With quick jamming, you
would try to jam up all the slots, and you send just a ton of very small
payments at the same time.  And once all slots are taken in a channel in one
direction, no payments can be made in that direction anymore.  Actually, I think
either direction is fine because the 483 slots should be for both directions
together.  The other one is called slow jamming, which is just you route so much
capacity through a channel that all the funds in one direction are locked up and
then you route all the capacity in the other direction too and now the channel
is inactive and cannot do anything anymore.

So, these are very different attacks in the sense that they're attacking
different resources and exhibit differently on the network and different
mitigations are needed to fix them.  We've seen a bunch of different proposals
recently to mitigate them.  So, there was the paper by Antoine Riard and Gleb
Naumenko that just details everything and gave an overview of it.  And then
Clara Shikhelman and Sergei Tikhomirov, my colleagues here at Chaincode Labs,
published a paper with a concrete proposal on how to fix both of these attacks
using upfront fees and using a sort of pushback mechanism of giving only a part
of your resources to channel partners that you don't necessarily trust to have
your best interests at heart.  And yeah, since then we've seen a number of
additional proposals, too.  I think they might appear later in the newsletter.

**Mike Schmidt**: Thanks, Murch.  Dave, quick check.  Are you back?

**Dave Harding**: I'm back.

_BLS signatures for DLCs_

**Mike Schmidt**: Okay, all right.  We can hear you, great.  Dave, I wanted to
target this next topic towards you.  This is Lloyd's Discreet Log Contract (DLC)
proposal using Boneh-Lynn-Shacham (BLS) signatures, and maybe I can provide a
quick pedestrian use case version of this, which is if you want to enter a
contract with someone using DLC technology, you can come up with sort of a
program that you know that an oracle could execute, and that could be I guess as
simple as doing some form of an HTTP request to a price ticker somewhere, but
could be obviously more complicated and could be written in a variety of
programming languages that the oracle supports.

And if you and I say that on the result of a Super Bowl game, or some such
thing, and that ESPN is the oracle and there's a known URL that will provide the
score or the result, we can agree to place that bet, and if in the cooperative
case we don't need to use the oracle.  But if there's some discrepancy that I
say one team won and you're disputing that, you can then essentially send that
small program to an oracle that that runs it and then attests to the result,
which I thought was pretty cool.  My explanation was longer than I had expected,
but Dave, is that the gist of it; and maybe you can comment on some of the tech
behind it?

**Dave Harding**: Yeah, that's the basic gist of it.  It's good to compare this
proposal where DLCs are today, because DLCs are a working technology today.  The
thing is, right now, if we wanted to make a bet on the Super Bowl, we would have
to go find an oracle that we told about the bet in advance.  We'd have to tell
them, we want to bet on the outcome of the Super Bowl, and we'd have to specify
what that would look like, and we'd have to get them all set up with the price
ticker or the outcome ticker or whatever.  With this, what we can do is, like
you said, write a program.  So, you and I are the only people who need to work
on it at the start.  We need to agree on a program that does all the work that
we expect, and all we need to know is the address of an oracle that we both
trust and that would be able to run that program.  So, we go find an oracle, we
write our program in Python, we find an oracle that runs Python programs that
allows you to make requests to random HTTPS URLs, and so we're good to go.

So, it's a really nice improvement in the amount of setup you have to do for
DLCs, and also the reusability of DLC oracles, because these are trusted
entities, DLCs is a trust-based technology.  They have to build a reputation and
this allows them to really simplify that work and build a long-term reputation
for being a trusted entity.  There's a couple clever things going on here, but
Lloyd here is using BLS signatures, which is something people have been talking
about putting in Bitcoin forever.  It's used in the Chia blockchain, which is
kind of Bitcoin-like, and they were an alternative to schnorr signatures, and
consideration that they have some downsides compared to schnorr signatures at
the level of consensus.

But what Lloyd here has figured out is a way to use BLC signatures without
changing any Bitcoin consensus rules, which I just love that kind of clever
stuff.  And if we use a signature adaptor to get that signature from the oracle
into a form that could be used, a schnorr signature that could be used in
Bitcoin.  So, again, a clever idea with a significant improvement to the DLC
user experience.  I mean, I think it's just great.

**Mike Schmidt**: Yeah, I thought it was quite a cool idea.  Murch, what do you
think about it?

**Mark Erhardt**: So, one more comment on that.  The really cool thing here is
that with the way oracles are proposed to work in DLCs, the oracle already
cannot tell what it is being used in.  So, it does not know who is betting or on
what amount and with whom.  But by being able to run the program only at the
time of resolution, you also remove the possibility for the oracle to be aware
that it is even interested in the event and potentially front-running something
in that regard.  So, even though you bet on an outcome, you can only resolve
after the outcome and you remove any incentives for oracles to get in before the
resolution.

_Summary 2022: Bitcoin Optech_

**Mike Schmidt**: Thanks, Murch.  We had a callout in the next segment of the
newsletter about ourselves, Bitcoin Optech.  And a few stats I'll rattle off
fairly quickly.  51 newsletters this year, 11 new pages to the topic index.  And
I just wanted to take a quick sidebar to thank Dave for not only being the one
to create, I think, all of those topics and update them, but also having the
foresight that such a thing would even be useful.  I know you proposed that a
couple of years ago, and I thought it was a fun idea, but I find myself using
that way more than I thought.  It's been way more useful than I thought.  So,
thank you for having the idea and then being the one to create these topics and
keep them updated each newsletter.  So, thank you.

70,000 words, the equivalent of a 200-page book, and a couple of things that I
wanted to add was, obviously, we're doing these recaps on Twitter Spaces now,
and I think that that's a cool addition.  I find it valuable to interact with
the community.  I also find it valuable for myself to make sure that I'm even
more familiar with these topics than I normally am from reviewing the
newsletter.  And I think we get quite a lot of listens to these recaps after the
fact, so I think it's valuable for the community.  I also wanted to thank our
translators who have really stepped up this year.  I think every single
newsletter has been translated into Japanese, which is great.  And then we've
had the addition of, I think, German and French and Czech and the Chinese
translation is in this year.  Yeah, in Hindi as well.  So, thank you to our
translators for that as well, I'll call them out.

**Mark Erhardt**: I'm still waiting.  I think it would be so obvious to me for
us to have a Spanish translation, right?  There's a bit of a language barrier
there, but there is a lot of interest in the Spanish-speaking world with
Bitcoin, see El Salvador, also Portuguese maybe.  I think that the Bitcoin
community in Brazil is blooming.  So, if you're listening and you speak those
languages and you agree that there should be translations for that, maybe look
at our translate help.  We don't speak your language, but we'll help you with
the PRs and getting it merged and published on the website.  But if that would
be something that really moves your community forward, please do get in on that
or help somebody else get started doing it.

**Mike Schmidt**: Yeah.  And don't discount the value that that adds doing the
translation to your own understanding, I think it's valuable.  Thank you for
those who are doing the translation.

_Fee ratecards_

September, Lisa from Blockstream posted to the Dev mailing list about this idea
for a feerate card to allow a node to advertise on liquidity for forwarding
fees.  Murch, why would we need such a thing?  What problem is trying to be
solved here with these feerate card ideas?

**Mark Erhardt**: So, basically you would like your channel to operate
differently depending on where the capacity is in the channel.  And there are a
few different sort of competing interests here.  On the one hand, you don't want
to tell the network all the time.  You certainly don't want to update the
network every time a payment is routed through you; (a) that would be a lot of
messages, and (b) that would be a huge privacy leak.  But on the other hand, you
do want to sort of encourage people to route through you when your channel is
completely imbalanced in one direction, in order to move it back more to the
center in order to be a useful routing node in both directions in order to earn
more fees.  There was a lot of "in order" here, right?!

So, with the feerate cards, you basically multiplex your channel into four
different channels where you say, "Hey, if all my capacity is already on the
other side, I'm going to charge a huge fee; if the capacity is in the middle
ranges, I'll charge a low to a normal fee; if the capacity is getting very high
in the other way, I might actually pay you in order to route for me in order to
rebalance my channel".  And by having this all hardcoded in the feerate cards,
people can just try, "Hey, I'm only going to use this channel if it's cheap
right now, and make a routing attempt through the cheap feerate card".  And if
it fails, it's just basically as if, well, you tried whether there's a cheap
offer here and it failed, and then you can either try a different channel, or
you can try the higher fee tier.  Or if you just want to make sure that the
payment goes through as quick as possible and you don't mind paying for it, you
just go with the high feerate card already, and it will probably almost always
go through.

It sort of reduces the amount of messages that you have to put through the
network in order to make people aware that they can route through your channel
in order to rebalance, and it can even maybe earn people some money to do the
service to rebalance channels, and all with a single piece of information that
never changes.  So, a very cool idea.

_Version 3 transaction relay_

**Mike Schmidt**: Thanks, Murch.  Moving to October, Gloria posted a proposal
for transaction version 3 relay, and we had spoken a bit earlier in this recap
about package relay.  Dave, maybe you can help us out.  How does v3 relay
correspond to packages and some of this discussion about fee bumping?

**Dave Harding**: So, v3 is basically a package with a single child, at least
that's where it's at now.  Maybe two children in some cases, I haven't followed
some of the updates.  But basically, it's how do we solve all of the issues with
CPFP.  And I think we talked about this a little bit earlier with Jeremy Rubin's
idea for these sponsorships where he basically cut down a lot of the CPFP rules
in order to eliminate a lot of these edge cases, these concerns that we have.
Well, v3 transaction relay kind of does the same thing for CPFP in general.

It would be opt-in, so anybody who depends on the current policies, continue
using them.  But anybody who wanted a simpler interface with fewer potential
issues could use v3 transaction relay as a CPFP way of fee bumping.  And yeah,
so it's just we're looking at these contract protocols with pre-signed
transactions where people just can't modify the original transactions to add
fees, they have to add a child.  How do we make this as simple and as robust as
possible?

**Mike Schmidt**: Nice overview, Dave.  Murch, do you have anything to add
there?

**Mark Erhardt**: No, I think Dave said most of it.  Did you want to get into
the simplified ephemeral anchor outputs here already?

**Mike Schmidt**: I think it's okay to touch on it.

**Mark Erhardt**: I think that there was an interesting idea here produced in
the context.  So, if we are going to try to do CPFP almost always, the big
problem with Lightning channels, of course, is if you create these commitment
transactions that you'll be able to use later to unilaterally close a channel,
but you don't know what feerate that commitment transaction is going to be used
at.  So, you currently just add a chunky feerate to it in the hope that that
will be enough at that later time to at least keep it in a mempool so that you
can CPFP it if necessary, but you're also just overpaying in general just in
case, right?

So, with the v3 proposal and basically a guarantee that you can always get a
child in for such a commitment transaction, you could have the commitment
transaction actually be a zero-fee transaction.  And then using package relay in
addition, v3, and something called an ephemeral anchor, that is essentially an
anyone-can-spend output that has a very, very small output script and always
resolves to true and then does not need an input script at all, you could have
essentially this hook that always needs to be spent when you make a unilateral
channel clause, and it naturally already hooks the child transaction in,
basically like a hitch that you attach your child to already.

So, yeah, Greg has had this proposal and has refined it over the last few months
with, I think, the output script is basically just an OP_2 or OP_3 in the output
script, and then the input script can be emptied because OP_3 by itself already
resolves to a true stack.

_Async payments_

**Mike Schmidt**: Next item from October is about Eclair async payments and
trampoline relay.  I think maybe it would be good to just get an overview of
what trampoline is and how each thing fits into that.  Murch, I don't know if
you or Dave wants to take that one.

**Mark Erhardt**: Dave?

**Dave Harding**: Okay, so a trampoline relay is basically in the basic
Lightning protocol, the person who is sending a payment chooses the route that
payment will take from each hop, hopping from one node to the next until it gets
to the recipient.  The trampoline relay, instead of choosing the entire route,
the sender chooses one or more parts of the route, particular nodes it wants to
get that payment to get to, and gets the payment to the first of those nodes,
and those nodes choose the rest of the route.  So, it's kind of like outsourcing
your pathfinding on LN.  And this is very useful for like Lightning node clients
that run on people's phones that aren't going to be on all the time, they aren't
going to keep track of the LN gossip, so they aren't going to know how to route
payments through the LN, they're not going to have a good view of the network.
So, they can outsource their routing to another node.

What this allows you to do is, it allows trampoline node to hold the payment for
a while, because it's routing the payment, it's choosing the route, it can hold
onto it for a while.  And this allows us to add async payments.  The idea of
async payments is that people receiving payments, again, on a light client like
a mobile phone, aren't going to be online all the time.  So, some other client
needs to be aware that the ultimate recipient isn't online at the moment and can
hold that payment for a little while and say, "When that mobile phone does come
back online and checks its status, I am going to have this payment ready to go".
It is very easy to do this in a trusted way by just sending your money.  So, if
I trust Murch to hold my money, I can route my payments through Murch and I can
give him the information to claim that payment and he can hold it for me and
give it to me later.  But we want an untrusted way to do that.  And so, we can
use trampoline relay to do async payments by having that trampoline relay hold
the payments for a while until the ultimate receiver comes back online.

Hopefully later on, we're going to get an upgrade to the LN to use taproot, to
use PTLCs which will allow us to do a different way to do async payments, which
is probably even better.  But trampoline relay allows us to do async payments
right now.  So, clever.

**Mike Schmidt**: Dave, Murch and I have been talking about trying to find a
third co-host that's a Lightning expert, but it looks like we have you!

**Mark Erhardt**: Yeah, you should come on more often.  I love it!

_Block parsing bugs_

**Mike Schmidt**: The next item I think we can skip is the bugs in BTCD that
were found.  I think in the interest of time, and the fact that we've covered
this and the community has covered this fairly well, I think we can skip it.
You guys agree?

**Mark Erhardt**: Sorry, I didn't catch the first part of that.  What do you
want?

**Mike Schmidt**: Just skipping the block parsing bugs from BTCD.

**Mark Erhardt**: Oh yeah, let's skip it.

_ZK rollups_

**Mike Schmidt**: Okay, great.  And we can roll into sidechains and John Light's
post about validity rollups.  So, I think some listeners are probably familiar
with the concept of a sidechain and perhaps the implementation in Liquid, or the
proposal from Paul Sztorc on drivechains, but this is a different type of
sidechain that uses validity rollups.  Dave, maybe you can help us understand,
how does a validity rollup enable a type of sidechain in the way that John Light
proposes here?

**Dave Harding**: Well, I guess, to step back, there are different kinds of
sidechains.  So, in a federated sidechain, you trust the signers of the
federation, and in a drivechain, you trust miners.  So, these are trusted
constructions, if you will.  And in the validity sidechain, and John might kind
of contest this use of sidechain, so that's kind of open there, but I kind of
think of it as a sidechain; the validity sidechain, you're still having, say, a
federation, or possibly even miners, run that sidechain during a federal
operation, but each time they update the state, or periodically when they update
the state, they post the current state to the main Bitcoin blockchain in a very
succinct, small way.  And what you can then do, as a user of that sidechain, is
later on you can create a Bitcoin transaction that references that proof and
allows you to withdraw your money onto Bitcoin, even if the operators of the
sidechain, whether they're a federation or they're miners, don't want you to.

So, it's a sidechain with an escape hatch, if you will.  You put your money on
that sidechain, you can get a guarantee that you'll be able to get it out.
There may be some things you can do on that sidechain that you won't have that
guarantee, but your state at rest on that sidechain will be that you have a
guarantee that you can get your out of it.  How this works, there's some ideas
for zero-knowledge proofs here, which are just way over my head, and there might
be other ways to do it with just increases to Bitcoin script language.  But
yeah, it's an escape hatch for sidechains.  So, it's a powerful idea if we're
ever going to use sidechains more than we currently do.

_Encrypted version 2 transport protocol_

**Mike Schmidt**: Thanks, Dave.  The next item here is involving BIP324, which
is a proposal for encrypting communications at the P2P level, and I don't know
if this is one that we want to jump into too deeply.  Obviously, there's some
benefits in encrypting the transport between peers, namely you can detect
tampering, you can potentially help with eclipse attacks, and then obviously any
eavesdropping can be cut down on.  It's nice that this was revived after not
having a lot of action for a few years.  I don't know if we need to get any
deeper than that, but Murch, you want to get deeper, let's do it.

**Mark Erhardt**: Yeah, just one comment.  So, thanks to Dhruv, this got revived
this year, so shout out to him, great work.  The other thing that I wanted to
say is, it does help with tampering, but you have to do work outside of what
it's proposing.  Like, you have to go to your counterparty and say, "Hey, we
have a session.  Can we compare session keys?"  And when you do, you can
discover whether there's a man-in-the-middle attack or not.  So, I think that is
not the primary benefit.  The primary benefit is that it makes it more expensive
for passive observers to learn what's going on in the network.  They actively
have to man-in-the-middle in order to see who's issuing transactions to the
network, and so it just generally makes it more expensive for adversaries to
observe the network passively.

_Meeting of Bitcoin protocol developers_

**Mike Schmidt**: Thanks for clarifying, Murch.  We had a note in the summary
for this year about the Bitcoin -- we talked about the Lightning in-person
meetup, and then there was also a Bitcoin in-person meetup.  And similarly,
Bryan Bishop did a lot of transcriptions on the meetings, and I invite you all
to jump in and look at that, as well as our summary coverage of that in a
previous newsletter.  But I think we've touched on a lot of these topics
already.  But I'll open up the floor, Murch, if there's any topics from that
meeting that you think we should cover here; same question to Dave.

**Mark Erhardt**: I think the only one that jumps out of this block right now to
me is Stratum v2, which we've not mentioned yet.  So, there's a lot of effort
going into updating the protocols with which miners communicate with their
mining pools, or rather the mining pools with their miners.  And so, there's a
bunch of issues with the current protocols that, for example, make it simple for
others to hijack hashrate if you can pretend to be an ISP, or if you ASN
hijacked, or, yeah, like privacy issues.  And there's this big effort, Stratum
v2, that basically revamps the whole protocol, makes it more efficient, adds new
features, and it's coming along very nicely this year.

**Mike Schmidt**: Dave, anything from the Bitcoin developers meetup that you
wanted to outline?

**Dave Harding**: Well, I wanted to talk about Stratum v2 as well, but Murch
jumped me on that.  I do think that's a really nice thing.  And there's just,
again, it's just great seeing these developers meet in person and talk about all
these things and make progress on them.  A lot of times, like Murch said
earlier, purely electronic communications just deprives these ideas of
personality and deprives comments and feedback of the positive way in which
they're meant.  So, it's just great seeing these developers get together and
talk.

_Summary 2022: Soft fork proposals_

**Mike Schmidt**: Excellent and we now move into the most intimidating portion
of trying to summarize the soft fork proposals in 2022.  I think this could
probably be its own hour-and-a-half or two-hour Twitter space in itself.
Luckily we have one of the most talented Bitcoin developer educators on the call
in Dave Harding and, Dave, do you feel like you could summarize the soft fork
proposals or the themes thereof in in a few minutes?

**Dave Harding**: Oh, wow, no pressure, Mike, no pressure!  So, a lot of the
discussion this year was about OP_CHECKTEMPLATEVERIFY (CTV), Jeremy Rubin's
proposal from I guess about three years ago, to allow one transaction to commit
to a child transaction.  You don't have to necessarily execute that child
transaction, but you can.  You can say, this is the only way these funds can be
spent, or you can give a couple of options, but these are your options for
spending these funds.  It pre-commits to those follow-up transactions.  It's a
construction that we sometimes call covenants.  I see AJ Towns is here.  He
doesn't like the phrasing of covenants, I tend to agree with him, but that's
what we're stuck with for now.

CTV has been somewhat controversial.  A lot of people really like it, a few
people really don't like it, and so there was a lot of discussion about it this
year.  There was also discussion about the SIGHASH_ANYPREVOUT (APO) proposal,
which somewhat overlaps with CTV.  It predates CTV.  It was previously known as
SIGHASH_NOINPUT, and there's ideas for SIGHASH_NOINPUT going back to at least
2011, maybe 2010.  And APO was kind of designed around the idea of the Eltoo
update for LN.  CTV was designed around the idea of the transaction batching, if
you will, pre-commit transaction batching.  But both of them can also do a lot
of other things.

We had a compromise proposal this year.  Russell O'Connor proposed that you
could kind of combine the two ideas into a single set of opcodes, OP_TXHASH,
which would be a very flexible way of saying which parts of a transaction a
signature commits to, and if you have different signatures, you can commit to
different parts of the transaction.  And you could put that on the stack and
check things about it.  And then an old idea called OP_CHECKSIGFROMSTACK (CSFS),
which would allow you to not sign the transaction directly, but would sign, say,
previous data on this stack.  And so he took these two ideas, he found a single
way to do it that's actually more flexible.  One criticism of that proposal is
that it's too flexible, that it will allow people to do things with Bitcoin that
we don't necessarily want them to do.

Rusty Russell would later propose a slight simplification of that.  And then
even later in the year, he proposed taking that simplification and then just
removing a bunch of features from it, all the features that would allow the
extra flexible bit.  The new idea would be basically just the ideas of CTV,
which has been pretty well analyzed to say that it doesn't allow us to enable
these things called recursive covenants, which some people oppose, and yeah, I
think that's about it for CTV-related stuff.  Jeremy did try to get CTV
activated this year and there was a lot of pushback about it.  Some people are
outright opposed to it and some people just don't believe it has been reviewed
enough to be activated.

AJ Towns proposed a completely different Script language for Bitcoin.  So,
again, we wouldn't pull off the existing system, we can't do that without
breaking people's received bitcoins, but we would add another one that people
would use.  This one will be based on the Lisp programming language.  I think
that's a really interesting idea, it didn't get enough discussion.  It's kind of
the same scope as a previous idea for replacing Bitcoin's Script language, which
is called Simplicity, which was a very basic language, a minimal language for
Bitcoin, that we could use to build everything we possibly wanted and prove it
was correct, and also make it easy to convert into faster languages, faster
code.

AJ Towns, again he's focused on, I don't know if focused, but he's really good
about looking at these discussions and trying to move them forward, trying to
find other completely from-the-ground-up change to move it forward, like the
Lisp-based language; or in this case, he also proposed a Bitcoin implementation,
a fork of Bitcoin Core, not designed for mainnet but rather designed for signet,
to make it easy to test soft fork proposals.  This again I think didn't get
enough attention, but I think it's something that we should we should all out
there, every developer, should be trying to use, trying to test these things,
trying to build tools on top of these proposals to make sure that they're
actually useful; do they actually accomplish the goals they set out to
accomplish?  He's also looking to test things, like package relay, that aren't
necessarily consensus code, but would have a major impact on the network.

And finally, we ended the year with a proposal for another covenant.  This one
would allow us to use merkle trees to do some pretty fancy script stuff.  Again,
it would be by chaining Bitcoin transactions.  So, you could, in theory, chain a
whole bunch of Bitcoin transactions, where each transaction only did small parts
of a smart contract, but the collective effect would allow you to implement a
very complex contract because you broke it up into small parts.  So, that's my
summary, back to you guys to decide whether it was good or not.

**Mike Schmidt**: I think it was a great, whirlwind overview.  Like I said, I
think we could probably do two hours on those subjects alone.  I think this is
an area of development, hearkening back to earlier in our conversation, where
you say there's certain things that are maybe in the incubation stage.  It seems
like a lot of the innovations in scripting or opcodes or sighash and covenants
are in that sort of incubation stage, with the exception of CTV that had a push
earlier in the year.  Murch, any thoughts on soft fork proposals?

**Mark Erhardt**: No, Dave said it all.

_Fat error messages_

**Mike Schmidt**: All right.  Moving on to November, Joost had an update from
his 2019 proposal to improve error reporting in Lightning for failed payments,
essentially trying to attribute a payment failure to a particular channel.  Now,
we've had some PRs recently over the last months involving this, but Murch, why
do we care what channel is identified in a payment failure; what could we do
with that information; why are we trying to solve this?

**Mark Erhardt**: So, in Lightning, payments are sender-routed, which means that
the sender builds the whole onion from him to the recipient, and then of course,
the recipients peel back the onion layer by layer as the multi-hop payment is
being built.  And they only learn about the previous hop because they received
the onion from that hop, and the next hop because they forward the remaining
onion in that direction.  So if, for example, a channel doesn't have enough
liquidity, they can say, "Oh, yeah, I don't have enough money", and send it
back.  But since the hop in the middle doesn't know who the sender was, and you
don't want to leak that information to other hops along the route, they cannot
make an encrypted or onion-encrypted message back to the sender, because they
just don't know who to send it to.

So, the only way that the message goes back is they failed the HTLC attempt and
then I think they can leave a message and it just fails back, and if there's
good citizens along the route, they all just forward the original failure
message.  But if there are malicious actors, they can change the message or make
it seem that it failed somewhere else or for a different reason.  So, there's
privacy leak issues here and there's information quality issues here.

The idea that Joost is proposing here is, if we allow for a bigger data blob to
be added, we can sort of have a way how the hop that has the payment fail
encodes it, so that however many hops it has to be moved backwards, the original
sender can unpack it and can either learn the actual failure reason from the
proper place where it failed, or can learn that somebody else maliciously
changed the message along the route and learn which hop did it.  So, with those
two pieces of information, they either learn exactly what they need to do better
in the next payment attempt, or they know who along their route is playing games
and just ostracize them.  So, yeah, sorry, long explanation, but I think I got
it all.

**Mike Schmidt**: Yeah, I think you did well.  Anything to add, Dave?

**Dave Harding**: I think that was a great explanation.  One of the implications
of this, of having more space to give error messages, is that you could also
catch other problems with LN.  So, one thing a hacker could do, or could just
happen accidentally, is it could be slow to forward payments.  Somebody along
that route can hold the payment up, in a lot of cases, for potentially a couple
of hours.  And so, if you threw timestamps in all the error messages, you could
say, you know, if I'm routing a payment to Murch and Murch is routing it to you,
Mike, Murch could say, "I received the payment at such-and-such time", and then
you would say, "I received the payment at such-and-such time".  And if there was
a big gap, we could say, "Oh, well, Murch's node is routing payments really
slowly".  So, again, the bigger space for messages gives us ability to look for
more problems.

_Modifying the LN protocol_

**Mike Schmidt**: Excellent.  That finishes up November and we have December.
And December was an opportunity to highlight a few of John Law's proposals
throughout the year, including one that was in December.  He has three different
proposals that he's posted to the Lightning-Dev mailing list, and all of them
are around this idea of using offchain transactions, Lightning transactions, to
enable new features, but not requiring changes to Bitcoin code.  Dave, I think
you might be familiar with these proposals more so than Murch or I, the first
one allowing LN users to remain offline for potentially months at a time.  Do
you want to talk to that one and we can go through the other two after?

**Dave Harding**: Sure, sure.  One of the challenges, I think, in John Law's
ideas in general is that a lot of them are fairly radical reimaginations of how
LN channels work.  They're not the kind of small differences that we're used to
in a lot of other proposals.  So, they're kind of hard for even Lightning
developers, I think, to read through, because you've got to really just read
through them all and open up your mind.  So, they're a little challenging for me
as well.

Keeping users offline for potentially months at a time.  So, he reimagines how
we would do the LN channels so that if you as a user were offline, if your node
was offline for potentially months, you could still come back online and see if
somebody was trying to steal your funds and get your money back.  And the
motivation for this is to reduce the idea that we might need to use watchtowers.
Watchtowers in LN are trustless third parties who can see if somebody has tried
to steal money from your channel, and they can post a penalty transaction that
penalizes the person who tried to steal from you and send your money back to
you.  The problem with watchtowers is that basically you have to update them
about your channel state after every payment you make.  This has some privacy
implications, not necessarily directly because there's ways we can encrypt
things, but you're basically saying, "Hey, I just received a payment", to some
third party all the time, and also dependency issues.  So, you're absolutely
depending on a watchtower to close your channel successfully if you're offline,
say, for more than a day.  And you can trust multiple watchtowers, but now
you've just increased the amount of data communications you send, you've
increased the chance that you're going to have a privacy breach, and so if we
can create a watchtower-free protocol, it's kind of a win-win for everybody.
This is what Law was trying to work on, on that first proposal.

**Mike Schmidt**: And then the second proposal that he got into was separating
the enforcement for specific payments from the management of settled funds.
Actually, you got into that one with the watchtowers one, didn't you?  I think
the second one was his tuning proposal, right, tunable penalties?

**Dave Harding**: Yeah, so tunable penalties is the idea that you can separate
out an individual payment from the management of the funds in general for the
channels, yeah.  So, right now the way Lightning works is if your counterparty
tries to steal any of your funds, you can claim all of their funds.  And I mean,
that's a very strong incentive for the channel to be managed correctly, but it
also can create problems where maybe you don't want those high stakes for every
payment.  So, he's figured out a way to separate those out on an individual
payment basis.

**Mike Schmidt**: And the one we covered most recently, Murch and I, I think we
ended up talking about this one, was it last week, was optimizing Lightning
channels for channel factories, which everyone always talks about channel
factories as some sort of a panacea for scaling, but he actually has a way that
we can do it in theory.  Like you mentioned, Dave, some of these are a bit
radical, but could be done with some work in Lightning sooner than we thought.

**Dave Harding**: Yeah, so channel factories are potentially a huge improvement
in the efficiency of LN channels.  And the thing that excites me the most about
them is that I think they would help better decentralize the LN.  Right now, we
have a bunch of LSPs and that's fine when they're in an untrusted state, but
there's an incentive to have big nodes, nodes with lots of channels, where with
channel factories, there'd be more people who cooperate to open and close a
channel factory, you get a high density of individual people with lots of node
connections.  So, if the three of us and 97 other people cooperated to open a
channel factory, we could have something like 10,000 channels between us, and it
would be all very, very decentralized.

But channel factories, it's not really easy to do with the current LN protocol.
The hope there has been that something like Eltoo could help with that, but
Eltoo requires SIGHASH_ANYPREVOUT, which is a consensus change, and again that
idea has been out there for several years and it has not gotten into Bitcoin, so
we don't know how close we are to that kind of thing.  So, having Law work on
the idea of creating channel factories without a consensus change, I think
that's a really good direction for thinking.  And this is again based on his
idea of tunable penalties, where the penalty doesn't have to be all of a
channel's funds.

So here, he has separated the ability to create a single payment outside of a
channel, if you will.  Each payment is done in a separate transaction that has
no direct connection to the main channel.  So, it can go onchain without the
whole factory being closed if a single participant becomes uncooperative.
That's one of the problems with channel factories is, if 100 people have a
channel and any one of them goes offline for an extended period of time, then
you're in a lot of trouble.  So, again, this is another clever idea, but it's
hard to think about because it is such a major change to how LN works.  So, it's
something I'm glad that we can highlight in the newsletter because I'm hoping
that some adventurous LN developers will take time to look at these things and
think about them, see if they're viable, and maybe consider implementing them
because they are such a big change throughout the kind of things we work on
day-to-day.

**Mike Schmidt**: Thanks for summarizing those, Dave.  Murch, do you have any
thoughts on any of the three John Law proposals from this year?

**Mark Erhardt**: I find it really charming to listen to Harding describe them
because my take on them was so much more pragmatic.  I was immediately thinking
about the direct feasibility and I considered, for example, the channel
factories proposal to be extremely brittle, how it was described, because I
think if even only one person defected or became inactive, you'd have to
essentially tear down the whole channel factory.  But yeah, I really enjoyed
listening to Harding, sorry, Dave, describe the prospect of these out-there
ideas and how they could be perhaps inspiring or getting others to think on
whether it's possible right now.

**Mike Schmidt**: We need to convince John Law to get some voice modification
software so he can privately join us for our recaps and when we cover his work,
because it would be nice to hear from him, but I know he's privacy conscious.
But maybe we can convince him at some point in the future.  Murch, Dave,
anything that you think we should talk about to wrap up the year?

**Dave Harding**: Not for me, I just want to thank all of the incredible
contributors at Bitcoin who've been doing all this work.  It's a pleasure to get
to cover all of your work every week.  And, yeah, go Bitcoin.

**Mike Schmidt**: Murch.

**Mark Erhardt**: Thanks for all the cool working together all year long, it's
been a great pleasure.  I'm looking forward to doing this more next year.  So,
yeah, thanks for Optech.

**Mike Schmidt**: Yeah, I'll echo that sentiment.  Thank you, Murch, for all of
your contributions to Optech this year.  Dave, thank you for being the sole
author on not only this newsletter, but the topics, as I mentioned, and being
the primary author on the newsletter.  It's really great working with you guys.
There's obviously several contributors that aren't here today to Optech that I
would like to thank, as well as all the developers whose work we're
highlighting.  So, thank you all.  And we will not be having any sort of
newsletter next Wednesday, and so we'll be back on our normal publication
schedule on January 4.  So, look forward to seeing everybody in the new year.

**Mark Erhardt**: Happy holidays!  See you soon.

**Dave Harding**: Cheers!

**Mike Schmidt**: Thanks guys, cheers!

{% include references.md %}
