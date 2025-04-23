---
title: 'Bitcoin Optech Newsletter #337 Recap Podcast'
permalink: /en/podcast/2025/01/21/
reference: /en/newsletters/2025/01/17/
name: 2025-01-21-recap
slug: 2025-01-21-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by vnprc to discuss [Newsletter #337]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-0-21/393462203-44100-2-ec084b377dffa.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #337 Recap on
Riverside.  Today, we're going to talk about mining pool payouts with ecash,
offchain DLCs, the LDK v0.1 release, and we have five Notable code highlights
today.  I'm Mike Schmidt, contributor at Optech and Executive Director at Brink.
Murch?

**Mark Erhardt**: Hi, I'm Murch, I work on Bitcoin stuff at Localhost.  Evan?

**Vnprc**: Hi, I'm vnprc online, I go by Evan though.  I'm working on a project
called Hashpools that we're going to talk about today.

_Continued discussion about rewarding pool miners with tradeable ecash shares_

**Mike Schmidt**: Yeah, and we're going to jump right into it since the
discussion of ecash and Hashpools is our first news item titled, "Continued
discussion about rewarding pool miners with tradeable ecash shares", which is a
continued discussion since our last coverage of the same Delving thread in
Newsletter #304.  So, for some background, refer back to that one.  In #304, we
discussed Ethan Tuttle's Delving post where he surmises that a mining pool can,
"Provide auditable, small-scale, private pool rewards in the form of e-hash".
We also, in that previous coverage, highlighted a reply from BlueMatt where he
pointed out that a challenge, as he sees it, is that there's no standardized
mining pool payout mechanisms, at least at the large pools, that would allow
miners to calculate their payout over short periods of time.  He also then asked
why a mining pool would implement ecash shares when they could just pay out
using an ecash mint or using the LN.  And then, there was a little bit more
discussion, and then the thread sort of went dead for three months or so until
vnprc/Evan, you noticed our coverage of that topic in the Optech 2024 Year in
Review post.  And then you noted, "I believe I have solved many (all?) of the
issues raised here and discovered several new insights".  So, Evan, thank you
for joining us.  Maybe you can provide any additional background on the topic
that's important to what you've been working on, and then let us know what you
found in implementing your Hashpool project.

**Vnprc**: Yeah, for sure.  Thank you for having me on as well.  And thanks for
the Optech Year in Review.  It took me all day to get through that, and then I
was surprised that the thing I'm working on was one of the topics.  Yeah, so
I've been working on this project, I've been thinking about it for years.  If
you recall several years ago, there was a post, it came out of the Fedimint
group, about Fedipools or Poolimint, it had different names.  I feel, and I felt
since then, since before then, even, that there was a lot of potential at the
intersection of ecash and mining pools, a lot of unexplored potential.  And I've
just been sort of chewing on this idea for a while.  And I think one of the key
pieces that was missing at the time of Fedipools was representing mining shares
as ecash tokens.  So, I was just sort of pursuing like, what could we do with
ecash that is novel and new.  Anything of intrinsic digital value, I think, is a
natural place to go to represent as ecash tokens.  And then, I leaped to mining
pools and I thought, what if we represent mining shares?  They have intrinsic
digital value.  It's sort of locked up in the pool account while the pool is
doing share calculations and before they make payouts.  It's a custodial system,
and I think there's a lot of potential here for ecash to help.

To Matt Corallo's point, the reason that we don't do quick turnaround payouts is
because, so I guess we should back the truck up.  There's two large payout
mechanisms for mining pools, there's two large popular ways to do this.  One is
called FPPS or First Pay Per Share.  And the way that works is that the mining
pool itself assumes all of the payout variants of mining pool rewards.  So, the
payout variants, as you know, mining Bitcoin blocks is a random process.  It's a
stochastic process, which means you never know when you're going to hit a block.
It's kind of like buying lottery tickets, you never know when you're going to
win.  So, there's something called payout variants.  So, every miner who mines
is going to sometimes get more rewards than expected and sometimes less, and
this variability is kind of difficult to manage as a business.

So, the kind of first thing we built as a mining industry, I say 'we', I'm new
to the mining industry, the first thing we built was FPPS payout shares.  So,
the mining pool assumes all of that payout risk, they pay out the steady rate
per share to miners who mine to that pool.  This is a pretty good model, it's
like an obvious place to go, but I think the problems are that in our current
mining pool architecture, the mining pool does a lot of things all at the same
time.  It selects block templates, it prices hashrate, that's what happens when
the mining pool assumes all of the payout risk.  The mining pool gets to price
hashrate.  And I think in particular, this combination of building block
templates and pricing hashrate is kind of a problem and it's led to where we are
today with large, centralized mining pools that frankly have too much control.

**Mark Erhardt**: May I jump in briefly?

**Vnprc**: Yeah, go ahead.

**Mark Erhardt**: So FPPS I think stands for Full Pay Per Share.  And the
problem there is of course, you're getting paid for blocks the miner hasn't
found yet, right?  So, as you're working towards a block, you keep getting paid
per share that you submit to the pool.  The pool has some sort of key by which
they give you money for each share that you submit.  And then eventually, they
will find blocks and with those blocks, they can cover the advance they gave
you, but they're giving you basically the money before they even earned it.  So,
the problem with that is that it's really only possible for big operations to do
this because you have to have a lot of money in the bank in order to pay in
advance before you find the next block.  Sorry, back to you.

**Vnprc**: Exactly, and that causes issues down the road, because you've got
mining pools now that can compete; rather than competing on the quality of
service they deliver, they compete on how large their capital reserves is, or
how much money they have in the bank, and this is a centralizing pressure.  The
other way to do payouts that was popular before FPPS sort of took over was
called PPLNS or Pay Per Last N Shares.  And the idea here is that the mining
pool does not assume the payout risk, does not assume the variability of
payouts.  Instead, you push that risk downstream to the miners.  The miners only
get paid when blocks are found.  And the most naïve way to do this is called
proportional mining.  So, just every time your pool finds a block, you pay out
everyone who mined a share that contributes to that block.  And essentially, you
drop your account balance to zero, you start collecting shares again, and for
each share, they get one chunk of the next block that the pool finds.

The problem with this is that it's a little bit too variable still, because
there's something called pool hopping.  So, if you think about it, the value of
a mining pool reward in this scheme is a simple division problem.  You've got
the block reward as the numerator, and you've got the number of shares as the
denominator.  So, the first share that gets mined after the last block is a '1'
in the numerator.  So, that first share gets the entire denominator.  So, that
share is overvalued compared to all the other shares around.  The second share,
again, gets 50% of the block reward, the third share gets one third.  So, these
very first shares after a block is found are super, super-valuable.  And the
last, if it takes a long time to find a block, say it takes longer than
expected, the last shares that roll in before the block gets found are
undervalued, so they're worth less than the initial shares.  So, we have this
problem called pool hopping, where a miner would jump into a pool right after a
block is found, mine up those first initial valuable shares, hoping that the
pool finds another block quickly.  And if the pool doesn't, they jump ship, they
go to another mining pool and start mining other more valuable shares.

This leads to hashrate thrash.  So, you've got people piling in and then all
leaving at about the same time.  So, this is bad for proportional mining.

**Mark Erhardt**: Especially if it's already late and everybody leaves, it'll be
even later until the block is found.  So essentially, they're written off the
shares, right?

**Vnprc**: Yeah.  It's like a mining pool death spiral that's localized to a
single mining pool.  It's bad news for mining pool as a business.  The way PPLNS
handles this is you amortize the value of the shares over a large number of
blocks.  So essentially, you say, and I won't get into the formulas of the
calculations here, but you say, "For every share I mine, I want it to count for
about eight blocks".  I think OCEAN is the only PPLNS pool I'm aware of today at
scale, although DEMAND is coming online.  I'm very excited for DEMAND to launch.
OCEAN, I think, splits it across eight blocks.  So, they calculate based on the
current hashrate how many shares it should take to find eight blocks.  Again,
this is a random process.  And for each block that is found, they look at a
window of shares that were submitted, corresponding to what it would take to
find eight blocks if everything happened like at a normal distribution.

**Mark Erhardt**: I think if I recall correctly, TIDES specifically, which is
the payout scheme that OCEAN uses, looks at a count of shares corresponding to
what would be expected for the next eight blocks.  And whoever mined any of
those count shares in the last period of time gets a payout on this current
block.  So, there's basically the sliding window on the count of shares
submitted rather than a time or the last n blocks, and you're in potentially for
more than eight blocks or less than eight blocks, depending on how quickly they
find the next eight blocks.

**Vnprc**: Yeah, that's a very good point.  So, they literally count each share
individually.  So, every share that lands, it's sort of as continuous of a
calculation as you can do.  And my proposal sort of chunks that up and we'll get
into that a little later, but keep that in mind.  So, I think the PPLNS, a
couple of comments.  PPLNS is just fundamentally more fair, because the mining
pool itself isn't paying in advance.  The pool doesn't collect any rewards until
the miners collect rewards, and the miners collect a reward exactly commensurate
with the pool luck, how often the pool finds blocks.  So, there's none of this
hidden calculations.  The pool puts their profit margin out there in public and
everyone knows ahead of time how much the pool is making.  I think this also
allows us to do a lot of verifying after the fact, and we'll get into that a
little bit later.

But when thinking about how to do ecash payouts, how to represent a mining share
as an e-hash token, PPLNS just naturally fits better, because we can essentially
allow the ecash tokens to represent the shares and push all the variability down
and keep everyone honest and upfront.  I think you can build it with FPPS
payouts, but it doesn't make as much economic sense.  And the reason for that,
well, okay, so I guess we should explain, there's sort of another insight that I
got into in the post, which is layered mining pools.  And that sort of plays
into how, I don't know how to explain this from start to finish!

**Mark Erhardt**: Well, maybe I can jump in and give a high level.  So, FPPS is
very attractive to miners, because as soon as they submit something, they get
paid, so they don't have to wait, they take less risk.  It is potentially very
bad for a mining pool because they take all the risks, they pay in advance,
block withholding hurts.  So theoretically, people could mine towards the pool
and not submit when they find a valid block and the miner pool operator would
have all the risk of that.  So, basically what has happened is that there's some
extremely big entities in the mining space, ANTPOOL, and they have so much money
in the bank, they've been essentially dominating the mining markets such that
even some other mining pools have been pointing their hashrate at ANTPOOL in
order to get the FPPS payout, even if they have other payout schemes to their
mining pools; or just funnelling it through basically.  And so, even when
ANTPOOL is nominally, I think, like a quarter of all hashrate, they've built a
block template for a much bigger portion of the entire hashrate, because so many
other mining pools are pointing their hashrate at ANTPOOL.  So, even if you're
mining with another mining pool, potentially you're mining under ANTPOOL block
template.

**Vnprc**: Right.  So, one of the places I want to get to, and I explained this
in the Delving post, if you listeners have gone and read the Delving post, one
of the places I want to drive towards is distributing block template production,
because as Murch described, ANTPOOL, their block templates are too widespread.
So, we need to decentralize that.  But I'll get to the layered mining pools in a
second.  I want to finish explaining how the ecash payouts work.  So, in order
to do payouts fairly without the pool assuming all of the risk, what I've found
is that we can just tie into this PPLNS share accounting system and develop
tranches of ecash key sets.  And essentially, we release a tranche of ecash
tokens for a particular time period, and those tokens all represent all shares
mined in that time period.  And then, we can have a sliding window of times, and
when the pool finds a block within that sliding window, just like with the TIDES
payout mechanism, we're going to dole out the value of those block rewards
according to how many of these ecash epochs are within the share accounting
window.

So, the way it works is, instead of having a -- and this is why I call it an
accountless mining pool, because with ecash, there are no accounts.  You just
hold a bag of coins, those are bearer certificates, and the centralized
custodian, in this case a mining pool, has no idea which coins belong to you.
So, instead of horizontally stratifying all shares in terms of who mined them,
the mining pool instead can just look at these vertically stratified contracts
essentially, that says, "Here are all the shares we received between 15.00 and
16.00 UTC on this date", and it can calculate the share value of those shares
irrespective of who owns the tokens.  And when the maturity window closes and
those shares have accrued all of the block rewards they're going to accrue, the
mining pool/ecash mint, because they're one in the same now, can start redeeming
those tokens for bitcoin, because the value of the e-hash tokens is locked in
bitcoin.  And the pool, because the window has expired, if the pool finds any
more blocks after this time period, it doesn't count towards those shares,
because they were mined far enough in the past.  Is that clear?  Does that make
sense?  Okay, cool.

So, this sort of vertical stratification gets us away from a lot of the privacy
issues of custodial mining pools.  The pool no longer has to KYC you.  You can
just show up and start mining and retrieve your tokens.  The pool doesn't need
to know or care who you are.  When it does payouts, the pool again doesn't need
to know or care who you are.  And I think the real magic is that these are ecash
tokens, so they're tradable.  So, if I mine an e-hash token that doesn't have
any value right now, I can go to a second-party marketplace or third-party
marketplace and sell that token based on the speculated value of what kind of
rewards the pool should find.  And this allows us to simulate FPPS mining.  But
instead of the pool assuming all of the payout risk and leading to this problem
where we have deep capital accounts deciding who wins and loses, instead we can
create a third-party marketplace of traders, who professionally trade this risk
and ought to be pretty good at it because we'll introduce competition.  Right
now, there's just not that much competition in the mining pool.  That's sort of
the major thrust of e-hash as a concept.

**Mark Erhardt**: So, basically the payouts would still happen at the time that
you mine, but you're getting a future value that you're unsure of.  It's like a
placeholder token for depending on how many blocks the mining pool finds, how
quickly, will eventually have a fixed denominated value, but up to that point
has an uncertain future value.  When I was reading this News item, I was
considering, "Oh, why don't you just get like eight tokens the moment that you
mine and it's for the next eight blocks?"  But now, I realize if they're
counting actually the number of shares submitted, you might not get a share in
the next seven, only in the next seven blocks or in the next nine blocks,
depending on how quickly they come in.  So, you can't really give that.  And if
you instead get a payout based on when the block is found and they just give you
a share of block X, a share of block Y, you instead have to wait again until the
block is found in order to get paid out.

So, now I understand you get these placeholder tokens that accrue value until
the eight-block hash horizon has been passed.  And then, you know the exact
value before that, the value is speculative, but that allows you to trade them
immediately, based on when they were found rather than anything else.

**Vnprc**: Precisely, yeah.

**Mike Schmidt**: If I'm thinking about this correctly, instead of the pool
assuming the luck risk or the individual hashers or miners assuming that risk,
you've sort of tokenized the luck and therefore the risk, and then you can now
outsource that to parties, traders, whomever, who specialize specifically in
pricing that risk, such that it's sort of outsourced to a new party.

**Vnprc**: Yeah, they can specialize.  You can also just hold your tokens to
maturity.

**Mike Schmidt**: Sure.

**Vnprc**: You can say it's your neighbor.

**Mark Erhardt**: Isn't that introducing also speculation and shenanigans,
though?  I just realized, if I had my own mining operation with like, say, 5% or
so, and I buy a few shares of like the last few couple of hours on a small
mining pool, they would be pretty undervalued at that time.  And then I point my
hashrate at that mining pool, find more blocks more quickly, and thus get paid
out for the previously undervalued shares, because I can now make them count
towards multiple blocks by finding blocks more quickly in that, let's say OCEAN.
OCEAN has like 0.5% to 1% of the hashrate.  I buy up shares from the last few
hours and then I mine on OCEAN for half a day to find a bunch of blocks.
Wouldn't that really increase?

**Vnprc**: That's a really interesting point.  I haven't thought of that.  I
think it would work inside of a share window or inside of one of these ecash
epochs?

**Mark Erhardt**: Yeah, I mean I wouldn't steal from anyone, in the sense that I
actually increased the rate at which the mining pool finds blocks, the payout
would be higher, therefore there's more value to share.  I just buy up the
proportion of the block reward on the cheap, because people don't expect the
shares in the future blocks to be that valuable.  You could do some stuff like
that!

**Vnprc**: Well, just a couple of comments.  You could.  I wouldn't even say
that you're doing anything shady or anything underhanded.  I think that's just
the free market at work.  A couple of comments are, number one, those shares
might not be for sale.  So, if I'm just mining, I have an S9, I use it to heat
my house just for funsies.  I'm probably not going to sell those shares.  I'm
going to hold them to maturity.  So, that sort of suppresses the amount of
shares that are on the market.  And number two, you can play these speculative
games.  You can buy up… yeah, you can absolutely do that, and I don't think
that's necessarily …

**Mark Erhardt**: I mean, on the other hand, that does provide liquidity to the
people that want to get out quickly, and the risk is on the person doing the
shenanigans.  It's just interesting.  I hadn't considered that before this
conversation.

**Vnprc**: Yeah.  If the share producer sells the shares to you at what we know
in the future will be a depressed price, I mean, that's good on you.  That's
just, like, maybe these are the professional traders and how they will operate.

**Mark Erhardt**: And it moves hashrate to smaller pools potentially!

**Vnprc**: Yeah, that's one of the things I'm most bullish about, is I want to
move more hashrate to smaller pools and I want a more ergonomic experience for
small miners.  And that sort of gets into the ecash payouts.

**Mark Erhardt**: I guess on the other hand, you can do the same thing.  You
sell your shares on the expected value on a big pool, then you leave the big
pool and they're overvalued, you got the overvalued price, got out.  So, I think
this actually, I'm probably missing, I've thought about this all about three
minutes, I'm probably missing something, but this could significantly create
incentives to move hashrate from big pools to small pools, or really depress the
share value for early sales due to the uncertainty.  Sorry, you had some more
high-level stuff to say about this, I think.

**Vnprc**: No, this is great.  I love it when you take in the details and think
of stuff I hadn't thought of.  So, the share window is going to be configurable.
So, maybe this would be an incentive for the pool operator to maintain a small
share window to minimize this opportunity for a hash whale to come in and swing
the markets.  I don't know, interesting game theory.  I'll have to -- well, it's
not even built yet.  So, I'm just trying to get e-hash issuance working right
now.  I guess once it's live, we'll see what kind of games we can play.

But yeah, to more high level, there's sort three large moving pieces that make
this whole process work.  There's e-hash issuance.  And by the way, e-hash, I'm
just using to distinguish ecash tokens that are backed by mining shares or proof
of work, because you literally produce a block header, you hash it, you look at
the zeros at the beginning.  And that's how you measure, it's called the
difficulty, or that's the denomination of these tokens.  I'm distinguishing it
from ecash, which is backed by some other currency, probably bitcoin, but it
could be stablecoins or Beef Bucks or whatever.  So, there's three large moving
pieces to making Hashpools work.  There's issuance, which is receiving mining
shares and doling out e-hash tokens; then there is redemptions, which is after
the maturity window for those tokens expires, you need a way for users to redeem
their e-hash tokens and probably get ecash out, although you can build any kind
of payment mechanism you want.  You could do BOLT12 payouts, you could do ecash
payouts, you could do stablecoin payouts, whatever floats your boat.  So, that's
redemption.  And then, the final piece is verification.

So, one of the cool things, so there's this protocol that Callebtc wrote up
maybe a year or two ago that really has gotten the wheels spinning and is sort
of integral to my project.  It's called Proof of Liabilities (PoL).  And the way
it works is you save, both on the wallet side and on the mint side, you save all
of these little pieces of data that go into making an ecash token.  So, an ecash
mint has private keys that it uses to sign these tokens.  That's how you verify
that the mint actually signed this piece of data that it's never seen before,
and that's called a key set, and you need a different key for each denomination.
The denominations go 1 sat, 2 sats, 4 sats, 8 sats, powers of two, all the way
up to 64 bits.  It's like having a $20 bill versus a $100 bill.  That's a key
set.

So, periodically, the mint is going to rotate the key set so that it no longer
will sign new tokens using these old keys, it's going to have new keys to sign
these new tokens.  And once you do that, you've sort of closed the gates, you're
not issuing any more tokens with this key set, so you can wait a certain amount
of time for users to redeem all of those tokens.  And you can build in, which
hasn't been done in the cash ecosystem yet, but it's coming, you can sort of
build an expiration.  So, if I have an ecash token and the key set has expired,
I have a two-week TTL on that, or Time To Live, before that token becomes
worthless, or at least before the mint is not guaranteed to redeem the token.

**Mark Erhardt**: So, you could no longer transfer the token and you could only
turn it into ecash, or whatever balance on your mining account?

**Vnprc**: Yes.  So, e-hash transfers once the maturity window is done and that
e-hash stops accruing bitcoin rewards.  I'm planning to turn it off so that you
can't trade that to other people.  Of course, it's self-hosted software, so if
you want to fork it and run your own code, you can do what you want.  This is
how I'm planning to build it.  The cool thing is that if you read Calle's PoL
protocol, we can actually go back and verify every single operation of the Mint.
You look at all these pieces of data, the blinded signature, the blinded
message, the unblinded signature, and the unblinded message, where Calle calls
them burn proofs and mint proofs.  You can publish all of these proofs, and
someone can go in, everyone can go in and verify that the mint was operating
honestly and did not create any tokens out of thin air or did not inflate the
money supply.  It's a tricky proposition when you're only using ecash.

My proposal actually, if you read the PoL protocol that Calle has written up,
there's a few gaps.  The mint actually can inflate the money supply without
being detected, only as far as the number of tokens that do not get redeemed.
So, if I issue 100 Beef Bucks worth of tokens, I close out my key set, only 99
of those Beef Bucks get redeemed before time runs out.  I can actually inflate
the money supply by 1 extra Beef Bucks and no one will be able to detect it,
because someone didn't redeem that last Beef Buck token.  The cool thing about
my proposal is that I actually also want to prove, since we're using PoW, there
actually is a paper trail for every mining share that gets submitted to the
mining pool as well.  What I would like to do is publish a merkle proof of all
of the mining shares that were submitted, and then combine that with the proof
of all of the e-hash operations, and they should sum up to the same number.

In this way, without any question of foul play, we can prove that the mint has
been operating fairly, that every token that was issued was backed by PoW, and
it literally doesn't make sense for the mining pool to inflate the shares
because they would have to actually do the work of mining, in order to generate
any cash token that doesn't trip up this verification scheme.  It's just easier
to do the work of mining than it is to try to cheat and inflate the supply to
counterfeit tokens.

**Mark Erhardt**: Question.  So, I get why you would want to stop being able to
issue the old key, the hash token with the old key.  So, after it has a fixed
value, speculating on it doesn't make sense anymore, it doesn't make sense to
transfer the e-hash token anymore, so it should be turned into regular bucks.
But why do you want to close the redemption?  Once it has fair value, wouldn't
it be fine to be redeemed three weeks later or five weeks later?

**Vnprc**: The reason you want to close the redemption window is so that you can
publish these proofs.  If someone has an outstanding token and you publish… I
need to think about this.  I think it's bad news.  It's bad for their privacy or
perhaps their money can be stolen if you publish this proof before they have
redeemed their token.  And like you said, the reason we want to stop trading
e-hash tokens after their maturity window has expired is because we essentially
now have a stablecoin.  We have a bitcoin stable coin with some arbitrary value,
depending on how many blocks the pool found and how many shares it issued in
that time window.  We're not in the business of running stablecoins.  You can go
to wrapped bitcoin on Ethereum, or whatever.

**Mark Erhardt**: Right, so basically if you don't redeem your token in time,
you just don't get your money.  It's a donation to the mining pool.

**Vnprc**: Yeah, well actually, it's a donation to everyone else who mines
shares in that epoch.  You actually can redeem your tokens early before the
maturity.

**Mark Erhardt**: No, no, no, wait.  The value is already fixed for the token,
so everybody got paid out and they're not getting more.

**Vnprc**: You're right, yeah.

**Mark Erhardt**: So, if you don't redeem it, you just give it to the mining
pool, right?

**Vnprc**: Yes.  Okay, so there are two time windows here.  There's the maturity
time window, during which you hold e-hash tokens and you can trade them and they
accrue value.  Then there's the redemption timeout window, during which you
can't trade e-hash tokens and they do not accrue value anymore.  If you don't
redeem your e-ash tokens during the redemption window, then the mining pool
collects those rewards.  It's like leaving money in the bank and never closing
your bank account.

**Mark Erhardt**: Okay.  Game theory.  If the mint stops redeeming or just
blocks you from redeeming or blocks certain IP addresses or so, they'd get your
money.  So now, based on who they're interacting, they might actually be able to
rug only specific, well, subsets of their users.

**Vnprc**: If the mint is able to identify certain users, probably through their
network traffic analysis or something, they could discriminate against those
users.  Maybe geolocation.  Maybe my mint doesn't like this jurisdiction for
some reason.  But just like any business in the real world, if you go to the
family dollar and they give them a dollar and they don't give you the goods that
you want to buy, then you don't bring your business there anymore.  You go on
Better Business Bureau and tell them this is a crappy company and don't do
business with them.

**Mark Erhardt**: Fair enough.  All right.  I think we've dove pretty deeply
into this one.  Do you have still some points that you wanted to bring up?

**Vnprc**: Yeah, there's one more thing.  So, this model I've described works
for a monolithic mining pool.  So, I've described a mining pool that works top
to bottom.  But there is an issue.  If you want to spin up a new mining pool,
there's sort of this zero to one phase where you're not finding blocks very
often.  And if you push all of the luck risk down onto your miners, they're not
going to get paid very often.  And this is a problem for anyone who's mining and
expects to claim those profits.  So, what I've found, and this is one of the
other insights that I mentioned that Schmidty discussed at the beginning, you
can actually just layer mining pools.  And I think this is going to be a really
powerful model for distributing block template production, because as long as
the pool is a PPLNS pool, I can just create an account with that pool, I can
operate my own mining pool.  When I receive a share, I send it upstream to the
larger PPLNS pool.  I can do all my ecash, e-hash stuff at my layer.  And the
upstream pool is now just a dumb aggregator.  It receives shares and it issues
payouts and it doesn't assume risk, it doesn't need to have a capital account to
front people the money.  We can really separate concerns this way, and I think
this is a more fundamentally scalable model because it distributes block
template production.  This was a big revelation that sort of kickstarted me and
motivated me to really dive in and build this.

**Mark Erhardt**: So, this assumes that the upper layer offers Stratum v2 (Sv2)
block template creation by the miners and then you pay out based on their payout
strategy, or do you have your own PPLNS but you get the money from upstream?  I
guess you could do either depending on it.

**Vnprc**: You could do either.  There's a couple of things.  So, I mentioned
black template production.  We don't even have to go there yet.  The first place
I'll go is just mining upstream to a larger pool.  What that gets you is more
regular payouts.  So, on OCEAN right now, I think they're finding a block a day
or even more.  They're finding blocks really regularly.  So, I could set up a
Hashpool that mines to an account on OCEAN.  OCEAN accounts are pseudonymous, so
you just provide a Bitcoin address, so there's no KYC there.  And my miners now
would get paid out at a regular cadence, based on how often OCEAN finds blocks.
So, that's a huge benefit.  That allows me to launch a Hashpool without, you
know, collecting gigahashes, exahashes of hashrate.

I think where I want to go with this is, yes, I want to start using Datum or
using the job declarator protocol of Sv2.  I don't think it requires Sv2 to get
there, because Sv2 or SRI already has the capability of down-translating into an
Sv1 protocol stack.  So, I can do my ecash stuff using Sv2, using the latest
tech.  And then if I have to go to Sv1 to talk upstream to OCEAN, I can do that.
I don't think it's a huge lift engineering-wise.  But the other thing that gives
me hope is that DEMAND Pool is launching soon, and they're going to be a full
Sv2 stack.  So, I won't have to down-translate and lose all the security
benefits and the efficiency benefits to mine upstream to DEMAND.  But like I
said, I want to distribute block template production, so I think we should try
everything.  We should mine upstream to OCEAN, DEMAND, anybody else that wants
to run PPLNS.

I think it would be a major coup if we could get one of these large mining
pools, perhaps the largest American mining pool, to offer a PPLNS service.  That
feels like winning to me.  So, I really hope we can get there.

**Mike Schmidt**: Excellent.  Excellent discussion.  That was a fun one, and I'm
glad we had the time today to get so deep.  And obviously, thank you, Evan, for
joining us.  You're welcome to stay on.  If you need to drop, you have things to
do, we understand.  I would encourage folks to check out the discussion thread.
And I believe you also had a presentation at one of the conferences, that is
recorded and is referenced within the thread.  Which event was that?

**Vnprc**: Yeah, I presented a talk at BTC++ Berlin, the ecash Edition, back in
October.  I'm most active on Nostr.  If you find my Nostr account, maybe we'll
put in the show notes or something, I'll go and note that out right now, so
it'll be at the top of my feed.

**Mike Schmidt**: All right.  Thanks again, Evan.

**Vnprc**: Thanks guys, I'm going to drop.

**Mark Erhardt**: Cheers.

_Offchain DLCs_

**Mark Erhardt**: Our second news item was titled, "Offchain DLCs".  Developer,
conduition, posted to the DLC mailing list a post titled, "DLC Factories", where
he proposes to create a rolling DLC which can be endlessly renewed if both
parties to the DLC can come online to sign new DLC contract execution
transactions periodically.  As part of my reaching out to conduition to have him
join us on the podcast this week, he actually pointed out some corrections to
our writeup from this past newsletter that we're covering today.  So, the plan
is to issue a correction in this week's forthcoming newsletter on this topic.
So, as we sort of work through that with him and are working on that forthcoming
newsletter, Murch and I thought it would actually be best that we punt on this
discussion until those corrections are hashed out, and then we can cover this
news item more fully next week instead.

_LDK v0.1_

So, we'll move to the Releases and release candidates segment.  We have one, LDK
v0.1, a milestone released codenamed, "Human Readable Version Numbers".  So, I
think we noted that in a previous podcast that it looked like they had changed
the versioning.  Some notable features that I saw in this release was the
upstreaming of the Lightning liquidity crate into Rust Lightning; support for
BIP353, Human Readable Names; more aggressive onchain state resolution batches
into single transactions, which I think we talked about a couple of weeks ago;
under-the-hood work to support dual-funding in a future release; a couple dozen
other API changes; and if you look back at Optech's Notable code segments for
the last couple of months, you'll see coverage of a bunch of those as well.  The
release also had called out in particular 12 bug fixes and 2 performance
improvements.  And the release notes contain several notices about backward
compatibility as well.  So, review those when upgrading.

**Mark Erhardt**: Yeah, I wanted to pull out one specifically there.  If you're
still on an old version, the previous version before v0.1 was v0.0.125; but if
you're on v0.0.123 or earlier and you have any pending HTLCs (Hash Time Locked
Contracts) or unclaimed payments, you cannot directly upgrade to v0.1.  You must
first resolve your HTLCs and unclaimed payments before you can upgrade.  I think
that one was important.  So, do read the release notes and especially the
backwards compatibility section if you're on an older version than the latest.
Especially look at it if you're on v0.0.123, which is three versions back.

_Eclair #2936_

**Mike Schmidt**: Notable code and documentation changes.  Eclair #2936 is a PR
titled, "Delay considering a channel closed when seeing an onchain spend".  And
this PR implements a change that was merged to BOLT7, which is the routing
gossip Lightning spec.  And that change to the spec was in 2022.  And it
specified, "A delay of 12 blocks is used when forgetting a channel on funding
output spent as to permit a new channel announcement to propagate, which
indicates this channel was spliced".  So, Eclair will now implement that
particular recommendation from the spec, and will store spent channels in a new
spent channels data structure.  That spent channel data structure, if a new
spent channel sits in there for 12 blocks, it is determined to not be part of a
splice and will be removed.  And if that spent channel enters that data
structure and it matches the spend of a shared output of a recently spent
channel, it will be marked as a splice.  So, good to see some foundational
splicing.

_Rust Bitcoin #3792_

Rust Bitcoin #3792 is a PR titled, "Add BIP324 v2 P2P network message support".
BIP324 introduced an encrypted transport protocol and Rust Bitcoin has actually
had a separate project in their repositories for BIP324 things previously, and
this PR brings the encoding and decoding functionality for BIP324 messages into
the main Rust Bitcoin repository.  My understanding is there was some weird
copying and pasting of Rust Bitcoin code into that other repository.  And so, by
bringing this back upstream, it sort of simplifies a lot.

**Mark Erhardt**: It wasn't totally clear from just a news item to me.  Rust
Bitcoin now has BIP324 support, is that right?

**Mike Schmidt**: Just the encoding and decoding of the messages.

**Mark Erhardt**: Okay.  So, it will not use it yet at the network layer?

_BDK #1789_

**Mike Schmidt**: No.  BDK #1789, which changes the default Bitcoin transaction
to version 2.  Transactions signaling version 2 were defined in 2015 around
enabling OP_CHECKSEQUENCEVERIFY (CSV) for relative timelocks, which you can
restrict the age of the output being spent.  In our summary, we noted only 15%
of the transactions were still using version 1.  So, version 1 type wallets have
a smaller anonymity set and thus worse privacy.  BDK already did have version 2
support before this PR and this PR simply changes the default version to version
2 moving forward.

**Mark Erhardt**: This is a little interesting.  I saw that, I looked at some
statistics and it had been down to almost 90% version 2 transactions.  And
recently, there was a resurgence of version 1 transactions.  So, someone that's
doing more transactions now is using v1 still.  And, well, I don't know.  It's
still valid.  If you're not using CSV, you don't need version 2, but it was down
to below 15%, now it's almost 25% again.  It's kind of funny to see.

**Mike Schmidt**: There was also an issue that I thought was interesting that
partially motivated this PR and it noted, and I'll quote a portion of the issue,
"It's likely that less than 15% of version 1 transactions are created by old
wallets.  It is also likely that BDK would be used with newer output types.  If
these two assumptions hold, it would make it possible to identify a BDK
transaction with near certainty".  Murch, you agree with that assessment?

**Mark Erhardt**: Yeah, the combination of fingerprints is probably -- like, 15%
of all transactions doesn't sound like that small of a number, but then in
combination with other fingerprints, like P2TR or P2WPKH and version 1, or some
other combinations, would probably make it a pretty useful fingerprint.  I also
noticed just now, I'll have to tell 0xB10C that there's only version 1 and
version 2 in this chart for transaction versions.

**Mike Schmidt**: Ah, yes.

**Mark Erhardt**: We have version 3 now, yeah?

**Mike Schmidt**: That's right, yeah.  Well, I thought we had TRUC
(Topologically Restricted Until Confirmation)!

**Mark Erhardt**: Yeah, but TRUC transactions, yes, that is correct.  TRUC
transactions is the construct or abstract term for what we're doing, but the
transactions that use the TRUC rules signal version 3 or use transaction version
3 in order to indicate that they would like to be restricted topologically.  So,
they should show up as version 3 transactions.

_BIPs #1687_

**Mike Schmidt**: BIPs #1687 merges the sending silent payments with PSBT's BIP
and assigned it the BIP375 number.  Murch, unpack that one for us.

**Mark Erhardt**: All right.  So, usually when you do a PSBT, you have multiple
independent parties, or one party that uses multiple devices like an AirGap
signer, or…  Anyway, we're talking about a tool to keep track of an incomplete
transaction through the various stages of it being incomplete.  One side is
probably putting together the framework with what outputs are being created,
what inputs are there; the other side either adds more inputs, more outputs,
both, or just signatures.  And so, with silent payments, one of the problems is
that when you pay to a silent payment address, you can only determine what the
output script, the exact thing you'll write into the transaction, will be once
you know all of the inputs.  So, the output script is calculated from the
private keys involved in the inputs that are being spent and the public key of
the recipient.  So, you need to know all of the inputs and you need the
participation of the signers of all the inputs in order to calculate what the
output address exactly should be.  Sorry, when I say output address here is,
we're paying a silent payment address and we need to determine the output script
that the recipient will be able to recover the funds from.

So, you don't know whether the other parties used the correct key to calculate
their portion of the PSBT in order to calculate the final output script for the
silent payments recipient.  And there's two new BIPs now, there's BIP374 and
BIP375.  375 specifies how to do a multiparty calculation on these incomplete
transactions in order to find out or keep track of all the information that you
need to create that silent payment recipient output; and BIP374, which I think
we reported on a couple weeks ago, makes it so you can prove that you provided
the correct part with discrete log equality proof, as I said, described in
BIP374.  So, if you're interested in implementing silent payments with multiuser
transactions, these two BIPs are your thing: 374 for a description of the
discrete log equality proofs that are used to prove that you correctly
participated in a PSBT that creates a silent payment output, which is described
in BIP375.  So, this is an extension to version 2 PSBTs, which themselves I
think were BIP370, I think.  Did I cover it all?  Did I miss something?

**Mike Schmidt**: Yeah, you got it.  That was great.

**Mark Erhardt**: Okay, yeah.

_BIPs #1396_

**Mike Schmidt**: Last PR, BIPs #1396, which is a update to BIP78 payjoin
specification to address a conflict between that BIP, BIP78, and the PSBT, which
is BIP174's spec.  Murch, what was the conflict here and how was it resolved?

**Mark Erhardt**: Yeah, so there has been work for almost two years on an
updated, newer payjoin specification; this is the third iteration now, I think.
There was payjoin in BIP78, and I think before that was BIP79, that also tried
to do something like that.  So, in BIP77, it has support for a lot more things,
and actually there was a step in BIP78 that specified that the receiver would
delete data on inputs for transactions, even though the receiver might need them
again.  And this specifically just is work towards making it more compatible
with PSBT flows I think, especially around stuff like silent payments and PSBT
v2, I think also for hardware signing.  You do need information on the
transaction that created an input, for example, to convince hardware devices
that they weren't treated.

So, this change mainly just removes that step where you delete data that later
participants in the PSBT scheme will still need, and that had been on hold for a
little bit, but finally got reviewed and then immediately implemented in BTCPay
Server the same day too.  So, it looks like there was this knot that broke in
work on BIP77 and compatibility to BIP78, so what is dubbed payjoin v1 and
payjoin v2.  And it looks like that's going to be moving forward in the next
couple of months.

**Mike Schmidt**: Well, that wraps up Newsletter #337.  Evan's dropped, but
thank you to Evan for joining us.  Murch, thanks for co-hosting as always, and
we'll hear everybody next week.

**Mark Erhardt**: Yeah, hear you soon.

{% include references.md %}
