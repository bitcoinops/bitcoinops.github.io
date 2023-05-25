---
title: 'Bitcoin Optech Newsletter #250 Recap Podcast'
permalink: /en/podcast/2023/05/11/
reference: /en/newsletters/2023/05/10/
name: 2023-05-11-recap
slug: 2023-05-11-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by [[Larry Ruane]] and Thomas Hartman to discuss [Newsletter #250]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/70848537/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-4-22%2F21902180-05a7-70e7-f692-5c866a0842ee.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #250.  It is
Thursday, May 11, and we have some special guests who will introduce themselves
shortly.  Thank you all for joining us.  I'm Mike Schmidt, contributor at
Bitcoin Optech and also Executive Director at Brink, funding open-source Bitcoin
developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work on Bitcoin stuff at Chaincode Labs, and
we've been talking a lot about mempool in the past few days here in Bitcoin
Park.

**Mike Schmidt**: I bet; a lot of activity in that mempool.

**Mark Erhardt**: Rod really has a hand for picking the exact right time to do
stuff in advancements in advance.  He managed to have Casey here end of
February, and now he has all of us here right as the mempool is blowing fuses!

**Mike Schmidt**: Larry?

**Larry Ruane**: Hi, I'm Larry Ruane, I'm a Bitcoin Core contributor on a grant
from Brink, and I do a lot of code review and also help out a lot with the
Review Club and with the Optech newsletter, the part about summarizing the
Review Club.

**Mike Schmidt**: Thomas?

**Thomas Hartman**: Hi, I work full time on improving Bitcoin.  The focus is
Blockrate Binaries, this white paper, and my objective is to get miners paid
even after the block, so to speak, goes away.  That's kind of my focus; get
miners paid.  More transaction fees is good.

_Paper about PoWswap protocol_

**Mike Schmidt**: Well, we'll go in order of the newsletter so folks can follow
along if they have that up, which actually the first news item is a paper about
PoWswap protocol, and maybe if I could just briefly summarize my understanding,
and then, Thomas, you can correct any of that and elaborate a bit.  So, in
Bitcoin script, we have the ability to express time locks in either time or in
blocks, so you could create a conditional script that allows for spending coins
when each of those conditions is met, and we give the example in the newsletter
of Alice's key in the time conditional, and Bob's key in the block height
conditional; and, whichever one of those happens first would allow that party to
move the coins first, and thus you can achieve some sort of a bet on hashrate.

Now, Thomas, can you explain, is that structure that I outlined correct; and,
why would such a structured bet be valuable for the Bitcoin ecosystem; and,
maybe you can speak a bit to the motivation for formalizing something like this?

**Thomas Hartman**: Yes, it's correct.  There's one tiny nit; so, the title is
Blockrate instead of Hashrate, because it will only work with hashrate if you're
within a difficulty adjustment, because as soon as the difficulty adjusts, you
don't know how many hashes are going into the blocks into the future.  So,
hashes over time, you know, hashrate, doesn't work beyond the two weeks.  Blocks
divided by time, blockrate, that will work indefinitely into the future on
mainnet.  Probably, you could do a soft fork to get actual hashrate, hashes over
time into the future, but you'd need to change Bitcoin.  I actually originally
was interested in doing that, and I'm still interested in doing that, but it's
hard, soft forks are hard, so I figured it was better to focus on what can
already be done on Bitcoin; so hence, Blockrate.

Why is it good for Bitcoin?  Well, one reason, as I originally said, is I like
to see more activity and more competition for block space.  I don't like the
high fees when I'm using Bitcoin, but we all know the block subsidy is going
away.  So, this ordinals and whatever else is going on, I'm kind of rolling my
eyes, but I actually think it's good that the fees are going up and that people
are going to have to switch to using LN; that's the future.

Actually, part of this was I was worried and I thought, "What if we just keep
cruising along and gradually over time, fees keep going down; we've got to get
the miners paid?"  So, what else can we use this block space for and what can we
use it for that's Bitcoin-y, because I guess BRC-20, or whatever it is, it all
seems kind of scammy and nonsense, but Blockrate Binaries, or if we get a soft
fork in, Hashrate Binaries, it's like the essence of Bitcoin is energy; you can
basically predict the value of Bitcoin in energy in all kinds of flexible ways.

So, if there is an attack, if there's a censorship attack on Bitcoin or capital
controls or any of that, as long as you've got some way to use the internet, via
Core or whatever, and miners are still mining blocks, you can hedge your
purchasing power based on what you think is going to happen by this market.  And
if it's a big market, a lot of people will use it, and that will keep miners
mining also during an attack.  So, it's sort of a defensive posture, worst-case
scenario.

Now, if there isn't this huge attack on Bitcoin, is it still useful?  Yeah, I
think so.  It's a free market.  I think eventually, the users would probably be
miners, energy providers, anybody that's transacting.  So, if we get oil price
in Bitcoin, or kilowatt hours priced in Bitcoin, I think you could use these
types of instruments to improve your business processes, and it doesn't require
custody and it doesn't require oracles, it just works, just works on Bitcoin.
And of course, if you're just a bitcoin holder, same thing, you can look at what
you think is happening; and in the same way people now hedge their purchasing
power in dollars, you could hedge your purchasing power using these types of
binaries, based on what you think the market is going to do.

**Mike Schmidt**: Now, help me understand that.  I understand that there's a
component here for miners, and we can get into the envisioned applications of
that type of contract in terms of insurance for, we use the term hashrate, but
blockrate, I guess, is what you're portraying here.  Now myself, if I have a
bitcoin and I want to keep its purchasing power, there's centralized ways of
doing things like that, options or futures or things like that where I could use
an exchange, or some such thing.  How would this type of contract help me keep
my purchasing power, because it seems like the contract is tied to blockrate and
not the bitcoin exchange rates; could you maybe tie that together for me?

**Thomas Hartman**: Okay, well shall we take the scenario where there's capital
controls and there's no more exchanges and things are getting dicey; or, should
we just assume that things keep going the way they are now and we continue to
have custodial, centralized exchanges, and all of that?

**Mike Schmidt**: It might simplify the example, at least for myself, if I
understood in the context of today how I might be able to use this?

**Thomas Hartman**: So, in the context of today, let's say that you think that
we're at a high, let's say that you think that the dollar value is going to go
down a lot, like when it went from $60,000 to $15,000; we've all seen these big
ups and downs.  You would have to say, "If the dollar value goes down, what's
that going to hashrate?" and find someone who's willing to take a binary.  So, I
guess all other things being equal, if the dollar value goes down, hashrate
should also go down.  In fact, it's a loose coupling, because a lot of miners
have already bought, so you kind of have to look at the mining market.

But you could say, "I think a lot of people think the dollar's going to keep
climbing, hashrate is also going to keep climbing; I disagree, I think we're at
a climax, so I'm going to buy some very cheap, out-of-the-money bets that
hashrate is going to go down, aka the blockrate is going to go down".  You'd
have to translate from hashrate into blockrate and see what's this going to do,
"Basically, do I think we're going to be seeing 10-minute blocks, which is just
a steady state, or is it going to go down a bit?"  So, you'd probably say it's
going to go down a bit, maybe we're going to see 10-minute-and-20-second blocks
for the next, I don't know, 3 months, and make some binary bets on that, find
some, in your view, naïve counterparties that will take it.

The three months passes and lo and behold, you were right, the dollar price
crashed, a lot of miners turned off, blocks start coming in slow, and maybe
you've got 50% of your money in bitcoin or something, and that hurts whenever
there's a big bear market.  But you hedged a little bit and you make as much
back as you can on this derivative.  And you also don't have to worry of course
about FTX stealing your money; non-custodial.

**Mike Schmidt**: That's super-interesting.  I'm looking at a chart that shows
the hashrate and the price, and there is some correlation there for sure.  So, I
guess there is some potential protection, although the example of the 2021 high
until let's say the trough at $15,000, the bitcoin price went down by whatever
that is, 80%, and the hashrate looks to have almost doubled.  So, I guess in
that scenario, maybe it didn't correlate, maybe there's some quirks to this but,
Murch, I see you have your hand up.

**Mark Erhardt**: Yeah, one of the problems is that the hardware production is
also a limiting factor.  So, the hashrate can often not grow quite as much as
maybe the price would move; and the other way, when the price tumbles, the
hashrate might have still already been ordered and it's cheaper to plug it in
and run it after you have already made the investment, than to let it languish
in a warehouse.  So, I think it's probably not going to be perfectly correlated
and hashrate lags a bit.

**Thomas Hartman**: Yeah, it's loosely correlated, for sure.  It seems to be
more correlated over a longer period of time.  I mean, I've thought through a
lot of this stuff and a perfect example, it wouldn't have worked in 2021.  I
guess you need to follow what's going on in mining.  These are tough markets to
trade, but sometimes tough markets to trade are good.  It raises the overall IQ
of the market, and it gets you focused on the energy production.  This isn't
going to go online for a while, this is probably going to take a few years.  And
when and if it does, things keep changing.  There might be less precipitous rise
in hashrate.

In my view, everything that gets people thinking about energy instead of
dollars, instead of shitcoins, is good, and this gets you thinking about energy
and mining in terms of your trade.  So, it's a little bit of mindshare kind of
thing; it's a trade, and it's a trade that doesn't require oracles, which I
really like a lot, and it just requires figuring out what's going on with
mining, and people don't think about that too much.  People think about getting
your dollars so you can pay your rent, pay your utility bills, and everything's
in dollars.  I want people to think in hashes; that's kind of the underlying, I
guess, marketing strategy you could say, and it doesn't have to be to hedge your
bet when you're at a climax high.  I mean, at any point you could say, "What's
mining going to do; what do other people think mining is going to do?  If I have
a better view on it and people are willing to trade this, I can make money,
create a community around that.

**Mark Erhardt**: I mean, I really appreciate how it's actually tied to onchain
and doesn't need an oracle.  There's an example in our newsletter with the
actual opcodes, and of course we use a height-based time lock on the one hand,
and a time-based time lock on the other hand, and just whichever one is reached
first decides how to pay out.  So basically, it's like a forex contract, just on
either time or block height.  But you said earlier something about you wanted to
have the hashrate recorded as an onchain statistic; could you elaborate on that?

**Thomas Hartman**: So, I'm calling this blockrate, almost to call the attention
to the fact that this is not a hashrate binary contract, unless -- it can be a
hashrate binary contract as long as you know what the difficulty is.  As soon as
you don't know what the difficulty is, in the future, you don't know how many
hashes are going into blocks, so you can't make bets on hashes any more.  But
you can always make bets on blocks, that's simple; how much time passes; how
many blocks are going to be in a time span; binary bet, you're done.

You can do the same thing with hashes if you add the capability to the protocol
to know the total chain work, and that's not that hard to do.  So, the same way
we now have a time lock basically that says, "This transaction can be mined as
soon as the time exceeds such-and-so value".  Okay, well if this transaction can
be mined as soon as the chain work exceeds such-and-so value, now you can do the
same thing with hashes that you do currently with blocks.

**Mark Erhardt**: Oh, I think I get it now.  So you mean that we would put an
opcode that can introspect the total work of the block chain, or the accumulated
work of a chain tip, which of course we don't have here?

**Thomas Hartman**: Yeah, and it would have the same semantics as the thing that
introspects the total blocks, everything the same.  Would this be doable; is it
safe for Bitcoin?  Intuitively, I think it's probably doable, but I don't know;
that's kind of a research topic.

**Mike Schmidt**: Thomas, you mentioned the way we walk through this, it seems
pretty trustless in terms of the script that we've outlined.  But I saw in the
paper you mentioned something about, "It may require careful counterparty
selection for the best results; can you explain?

**Thomas Hartman**: So, there's a problem.  In the paper, it's under the section
called Contention.  So, what happens is, you get a tie.  The bet is, "Okay,
we're going to mine the next block before 600 seconds", 10 minutes.  And then,
lo and behold, the next block is just about 10 minutes, or maybe it's like 598
seconds, so there's 2 seconds.  So, at this point, as soon as both
counterparties note that basically either side can collect the bet, both sides
will say, "I want to collect".

Now technically, you could look and say, "Well, it was actually underneath 600
seconds, so I'm going to be an honorable person and because it was under, my
side technically lost.  Even though I could collect the money, I'm a good
person, I'm honorable, I want to have a good reputation, so I'm actually going
to let this go to the counterparty".  But that requires honor, or some kind of
game theory for people to play fair.  Again, this is only a problem if you're in
a contention scenario and it's a near miss, but it's a problem and I'm not sure
what we can do about that.  That's kind of a follow-up, next paper type thing.

**Mike Schmidt**: Maybe piggybacking off of that, you mentioned that it could
just be close and then both parties can claim.  I guess when you're choosing
your counterparty, there's also consideration of if they're going to -- let's
say I win this bet and I have maybe the clearance of not just a few seconds, but
maybe several blocks in order to claim my reward here.

**Thomas Hartman**: Oh, yeah, as soon as it's not close, then you're good, then
this works normally.

**Mike Schmidt**: Yeah, unless my counterparty is somewhat malicious.  Is there
a way to prevent my transaction from confirming in those few blocks' span?

**Thomas Hartman**: Yeah, the paper talks about that too.  I mean, now you're
talking about transaction censorship, so I think Gleb or Antoine wrote a whole
paper full of all the ways you could stop -- it's much easier to accelerate your
transaction to getting mined; it's very hard to block transactions.  But
theoretically, let's say there's only a small number of mining pools and you
know all of them and you just pay them and you just say, if there's three mining
pools that have 95%, just pay them not to mine this transaction, and then 5%
chance that it gets mined, but you've got 95% covered.  But you don't actually
<!-- skip-duplicate-words-test -->see that that much in the wild.  Transaction censorship is hard and just
diversifying the mining pools, yeah, that would be a way to do it.  There might
be other ways to do it too, I don't know.

You can play with timestamps.  If you're a miner, you can lie about the
timestamps within what the protocol permits you, so there's all kinds of
strange, little attacks.  So, at the protocol level, this is not ready for prime
time, this needs more work.

**Mark Erhardt**: Yeah, I was just going to jump in on that too.  Putting on my
adversarial thinker hat, I was considering that the time lock locked to the time
is actually permitted to put the transaction into the mempool, I think, when the
median time passed; so, the time across the last 11 blocks is 1 hour in the past
from it.  So, yes, if people starting fudging with the times on blocks, or if
the time is pretty off on one of those blocks, it could shift it a little bit.

It seems to me that the contract would be a lot more likely to resolve in the
intended way for longer timespans, but something like just betting on the next
couple of blocks would be fairly difficult to enforce.

**Thomas Hartman**: Intuitively, I agree.  I think it works longer for longer
timespans, but I need to game it out more.  I'm sure it won't work for shorter
timespans, but I'm not sure that it will work for longer timespans with all the
shenanigans.  There's two ways to attack this.  The first way is just to build
it and then see people doing their shenanigans; and then, the second way is to
game it out at the protocol level.  So, I'm more leaning towards the second way,
because it's going to be expensive to build all the software out just to have it
not work, but I've considered also, let's go for it and see what happens, you
know what I mean?  I'm kind of considering it, or maybe we'll do both at the
same time, I'm not sure.

**Mike Schmidt**: Thomas, anything else that you would need as a takeaway or a
call to action for folks listening?

**Thomas Hartman**: Well, I'm sort of recruiting and I'm looking for protocol
developers that are interested in helping evaluate these edge cases, potential
failure modes, and help game them out for follow-up research.  I'm probably
going to continue working with Antoine and Gleb, but there might be people that
are very interested.  There's a budget for this, I'm open to hiring people, and
I know that Chaincode Labs works on these types of projects.  I think on the
last Twittercast, there was, what was it; it was that company that's internal to
Block; Spiral?  I'm interested in any other of these protocol development labs.
I'm hoping to start connecting with them soon and figure out if there's any
mutual interest.

Also, I'm building a demo, which will be custodial but will allow you to get an
intuition for what these binary contracts look like.  It will probably be
custodial on testnet, but I'm just trying to figure out, will this work in the
wild; and in some sense, "It won't work", would be a very valuable answer for
me, because then I can be like, "Okay, we tried, it didn't work, move onto the
next thing".  I'm kind of in that grey area, maybe this will work, maybe it
won't work, feeling hopeful mode right now.  And if it does work, then I would
love to have miners make a lot more money, because there's serious volume being
transacted on this, ideally on LN, but LN still pays the miners for the open and
the close transactions, and you know, get people transacting in and thinking
about real-world things.  It's basically an energy market and it runs on Bitcoin
and it can't be shut down, if it works.

**Mark Erhardt**: It might actually be interesting to try this on testnet,
because testnet actually does have a very dynamic block rate with the occasional
and frequent block storms.  So of course, it will not be able to test for how it
would work on mainnet, but it might be a good test of the primitives.

**Thomas Hartman**: Yeah, it will definitely be on testnet first.

**Mike Schmidt**: Thomas, thanks for joining us and walking us through that.

**Thomas Hartman**: Thanks, guys.

**Mike Schmidt**: Murch, if you're good, we can move on with the newsletter?
Awesome.  Next section of the newsletter is releases and release candidates.

_Core Lightning 23.05rc2_

I have in here the Core Lightning 23.05rc2 release.  I did see that in the last
days, actually the v23.05 official release appears to have been tagged, also
nicknamed as Austin Texas Agreement, ATXA; Austin represent!  We talked a little
bit about this release previously.  It includes blinded payments supported now
by default, PSBT v2 support, and some new things that I noticed in the release
notes, looking it over this morning, is allowing that slight overpayment, even
using multipath payments as the spec now recommends, I think we've covered in
previous discussions.

There's also some additional feerate options in CLN.  And the last thing that I
thought was notable was spending unilateral close transactions now use dynamic
fees, based on what you define as a deadline, and also using RBF instead of
fixed fees, and I thought that was interesting.  Murch, did you have anything
else notable in this release that you want to talk about?

**Mark Erhardt**: I must admit that I was pretty busy with other things and I
have not read the CLN release notes.  But, I have an idea why so many people
have been thinking about dynamic fees instead of fixed fees recently, and have
been working on RBF!  What we've seen, because maybe somebody will listen out of
the short timeframe where this is in the presence of minds, we had in recent
days a peak or a craze on block space demand, where people were outbidding each
other to reach whole blocks above 500 sats/vbyte minimum feerate, and this was
basically caused by a form of bidding, or rush to mint tokens with the BRC-20
thing that's going on in the latest wave of inscription and formats.

It has caused a lot of the infrastructure projects, and also companies,
off-guard, because for the last two years the mempool has been pretty benign and
blocks have been going down to being partially, or non-full, at least once per
day almost every day in the last one-and-a-half, two years.  So, suddenly having
that go up to 500 times that in less than two weeks was definitely a big
surprise for some.  So especially very big changes in feerates is a problem for
LN channels, because when you negotiate a commitment transaction, you do include
a feerate for what you assume will be enough to close that channel unilaterally,
in case the other party disappears.

What we've seen in the past couple of weeks is that, with the huge demand and
over 500,000 transactions waiting to get confirmed, the eviction feerate, the
feerate under which default mempools were dropping transactions, went above 20
sats/vbyte.  Some of those standard feerates that you might have negotiated on
commitment transactions would have been below the lower end of what nodes even
kept in their mempool.  So, you wouldn't be able to submit your commitment
transaction at all, and you wouldn't be able to CPFP it because it's not in the
mempool.  So, there's been a bit of a focus on a lot of projects in the past
couple of weeks to shore up the CPFP and RBF features.

_Bitcoin Core 24.1rc2_

**Mike Schmidt**: The next release that we highlighted this week in the
newsletter was Bitcoin Core 24.1rc2, and there are some release notes drafted
and there are some fixes and optimisations to P2P, RPC, build system, wallet,
GUI changes.  And so, if you're someone who's running 24.0 now and you'd like to
test some of those changes, I'm sure all feedback would be welcome.  Murch,
you're a bit closer to all this than I am.  Is there anything specific that
folks should be looking to test?

**Mark Erhardt**: I was just looking this over a little bit.  I think that the
migratewallet thing might be interesting to test.  Other than that, well you can
find the release notes in bitcoin/doc/release-notes.  So, if you want to spend a
little time to familiarize yourself with the bug fixes that are being pushed
out, you can just find a list there, and maybe just pick one or two to look
into, if you want to help out with the testing.  I might want to lose another
sentence on what we're doing here.

So, in Bitcoin Core, we only release new features with the major versions, and
then the minor versions, we only release bug fixes and things we've fixed, or
improved, in the release cycle after the previous major release to a point
release.  So, these are smaller and they don't have new features, so if you're
running a node for your company and rely on it to not go down, it might be safer
to run a point release, rather than upgrading to the major version for a few
weeks after the release, while people are rolling it out in other ways and
testing it further, if something might have been missed.  So, this is for the
people that are not quite yet ready to upgrade to the next major release, and we
are generally dependent, all of us, to spend some time running the software.  A
bunch of us are running off of master already, so we have the newest features.
But when people that have different concerns and use the software in different
ways also test it a bit, that is definitely helpful.

_Bitcoin Core 25.0rc1_

**Mike Schmidt**: And speaking of major releases, there is a release candidate
for Bitcoin Core 25.0, and we noted that in the newsletter as well, and there's
a draft release notes for 25.0 on the Wiki repository if folks want to jump in
and start reviewing some of that, testing some of that.  Murch, based on some
chat you and I had earlier, maybe we'll jump into some of the details of this
release in a future podcast?

**Mark Erhardt**: Yeah, I expect that there might be a couple more release
candidates.  Usually, we actually get the final version maybe in the third,
fourth or fifth release candidate.  And when it's more final, we can probably
spend a little time to go over everything.  Today, we also have already the PR
Review Club coming up, so we'll probably just do that next week.

**Mike Schmidt**: All right, let's jump into the PR Review Club entry for this
week.  As Larry mentioned in his intro, not only does he contribute to Bitcoin
Core, and not only does he help facilitate some of the PR Review Club meetings,
but he also volunteers his time to select one of the PR Review Club meetings and
do a write-up for the newsletter each month.  Larry, maybe a quick comment on
why folks should be interested in PR Review Club in general, and then we can
jump into the particular PR that's being reviewed for this month?

**Larry Ruane**: Yeah.  I actually wanted to mention that from a distance,
people might think that the PR Review Club is a group review of a PR in the same
depth and detail that an individual would review a PR, so really getting into
each exact line of code and things like that, and it's really not like that.  We
stay at a pretty high level and really, the Review Club itself doesn't end up
suggesting code changes on individual lines of codes.

A lot of what we do in Review Club is background learning.  So, in this case, it
has to do with the prioritization of transactions, which we'll get into more
detail in a minute, but that's a concept that a lot of people may not be
familiar with, and there's some history behind that.  So, we talk about history
and concepts, and I'm trying to say, don't be intimidated or afraid to join in,
any people out here who have some technical level of interest, but they don't
focus on the actual lines of code.  It's completely open, there's no sign-up to
join in Review Club.

If you follow the link at the top of this section of the newsletter, you can
find out the details of when we meet.  It's a weekly meeting and all are
welcome, and you don't even have to participate in the sense of actually
contributing.  It's an IRC meeting, so it's not video or audio or anything like
that.  But you can just lurk.  People who lurk are completely welcome, and just
get a feel for what kind of things are being discussed.  They're one-hour
meetings, so that's kind of my pitch.  I think we'd love to have more people
participate in Review Club, including hosting Review Club too; we can always use
help there.  There's one person designated as the host, who'll be leading the
discussion in a way, but it's very freeform and informal.

**Mike Schmidt**: Thanks for giving that overview, Larry.  Yeah, I think it's
very lurker friendly.  You can even go back and look at the IRC transcripts for
different meetings and the different meeting notes.  So, even if you can't or
don't want to participate in the live discussion, you can just review that after
the fact, and that's sort of what we're doing now.

_Add getprioritisationmap, delete a mapDeltas entry when delta==0_

This PR that you selected for review this week has to do with prioritizing
transactions, which is actually something that I wasn't very familiar with until
I reviewed your write-up in the actual Bitcoin Core PR Review Club meeting.  If
I'm understanding it correctly, there's a prioritisetransaction RPC that lets a
node operator provide a txid and a fee delta parameter to that RPC, and that fee
delta parameter is the amount of satoshis to add or subtract from that
transaction's absolute fee, not the feerate.  And that additional fee is not
something that's actually paid, but it affects the algorithm for selecting
transactions into a block.

Larry, (1) is that correct; and (2) what scenarios might this be used?  Then we
can jump into the actual PR itself, once we get the concepts down.

**Larry Ruane**: Yeah, that is correct.  I was going to just step back for a
second, more at a higher level, this is an example of a PR where there's a lot
of contentious arguments on the mailing list about policies like RBF and so on,
but this is an example of a PR that's just pretty low level and focused and not
controversy, and it's just a nice, small improvement in the clean-up, and we
have a ton of these kinds of PRs that are happening in Core.  So, some people
from a distance might think that everything is contentious and argumentative and
all that, but there are a lot of PRs like this that are happening all in
parallel.  They may take a little while to merge because they're not urgent, but
there are a lot of efforts like this going on, there's a lot of activity in the
repo that from a distance, people might not be aware of.

But yeah, you summarize it correctly.  My first impression when I've heard about
this RPC is that it changes the fee of transactions in the mempool, but that's
impossible because to change the actual fee of a transaction would require,
first of all you'd have to have the signing keys, and it would change the txid,
and transactions are immutable; that can never happen.  So, what this does is,
as you said, this RPC will change the effective fee of a transaction in the
mempool, and it's really only intended for miners, although anybody can use this
RPC, but it wouldn't have much effect, I don't think, with any users except
miners.  And it's basically a way of modifying the effective feerate so that a
transaction would be included in a block more readily, or even in the other
direction.  If, for some reason, a miner wanted to censor a transaction or
deprioritize it, then that's even possible.

So, this RPC can either add to, or remove, or subtract from the actual feerate
of the transaction.  And the main use case that we are aware of is if a miner is
getting paid out-of-band to include a transaction in a block, so he's getting
paid in some other way.  So, the transaction itself might have a very low fee,
or even a zero fee, but the miner still has incentive or reason to include the
transaction in the block.

**Mark Erhardt**: I think in the context of what we've seen in the mempool just
now, another thing that is interesting is, if your transaction is below the
eviction feerate of the mempool, you can still call prioritisetransaction on
that txid and help it be treated at a higher feerate, in order to let it enter
your mempool locally.  So if, for example, you want to CPFP a transaction, you
can't put it in your own mempool because it's below the eviction feerate, then
you might be able to get it into your mempool that way, then CPFP it.  And if,
for example, you're directly connected to a miner that has a bigger mempool, and
thus a lower eviction feerate, that way, you might be able to broadcast both the
parent and the child transaction to the miner; even if the miner then later
doesn't prioritise it themselves, they would at least receive it.

But the long-term, better solution for that of course is package relay, which is
a project that's still in flight, but the idea there is that we allow multiple
transactions to travel together when they form a package that would be at a
higher effective feerate if you treat them together, instead of individual
feerates.

**Larry Ruane**: One thing Murch has said, actually, shows the reason why this
RPC can prioritize a transaction by txid without the transaction even being in
the mempool yet.  So, that's one of the questions we have in this list here,
just to jump ahead on that.  So, a miner, or anyone, can prioritize a
transaction and then add their transaction to the mempool; whereas, doing it in
the opposite order might not be possible, because its feerate doesn't reach the
minimum.  If a transaction enters the mempool and is prioritized, and then it
later, for some reason, any reason, it gets evicted, it will stay in this data
structure that we mention here, that's mapDeltas.  So, the prioritization
adjustment, that entry will remain in the mempool state, even though the
transaction itself is out.  So then, the transaction can come back in again and
this prioritization will apply.

**Mike Schmidt**: We've used this particular PR to talk about the notion of
prioritization in general.  Prioritization existed before this PR and this PR
actually provides some additional features on top of it.  It looks like there's
two main pieces to this.  One is, there is this getprioritisationmap RPC that
did not exist previously, even though you could prioritize or deprioritize
transactions.  There was not a great way, outside from inspecting the mempool
about that file directly, of actually getting that prioritization.

So, that RPC surfaces that information, and then it also looks like during that
process of prioritization, if you happen to be deprioritizing a previously
prioritized transaction, or prioritizing a previously deprioritized transaction,
and that delta went back to zero, it removes that entry from the map instead of
it just sitting there at zero, which I guess doesn't initially seem that harmful
to me, Larry.  But other than just being the right thing to do, was there an
issue with these entries sitting in there with a delta of zero?

**Larry Ruane**: No, I don't think so.  We don't really know exactly how miners
use this RPC.  So, if they prioritize tens of thousands of transactions, or
something like that, and then for some reason, they deprioritize them, and the
way you do that is you run this RPC again with the existing prioritization, and
that makes the result zero, currently without this PR, that stays in memory
until bitcoind restarts.

By the way, I just noticed getting ready for this podcast that the new RPC, the
name mentioned in the newsletter is wrong, and it's also wrong in the title of
the actual PR.  So, I think the PR author, Gloria, changed the name of that RPC.
I'll get this fixed in both places, but it was called getprioritisationmap, and
now it's called gettransactionprioritisations.  So, there's a slight mistake in
the naming right there.  But Mike, like you said, it returns the contents of
this data structure that maintains these deltas, or these prioritizations, and
just returns it as a JSON array of objects.  One of the nice, little features
there is that the individual entries for the prioritizations mentions there's a
boolean that says whether the transaction's in the mempool or not.

**Mark Erhardt**: I think I heard briefly that one of the issues with the
prioritisationmap was that it automatically cleans up; if a transaction gets
mined, then it's removed.  But if, for example, a transaction gets replaced, it
doesn't get removed because the transaction itself never made it into the
blockchain.  So if you, for example, run a miner that has highly opinionated
thoughts on what transactions should be prioritized or not, for example there
were, at some point, exchanges that were running their own mining pool and they
were always prioritizing their own transactions to be in the next block; so for
them, they might always keep those replaced originals in their
prioritisationmap.

I think that it could lead to them just having an ever-growing list that even is
persisted to the mempool.dat and reloaded and it would never get cleaned up.
So, with this PR now, this feature that probably just didn't get a lot of
attention before, gets the clean-up function and the clean-up function is more
sophisticated than just deleting mempool.dat.

**Larry Ruane**: Yeah, that's a good summary.

**Mike Schmidt**: Murch, a question for you.  I know Optech likes to focus on
the cold, hard facts, but I wanted to get your subjective opinion on Bitcoin
Core facilitating the ease of out-of-band transaction prioritization, or even
parsing transactions around out-of-band with this set of RPCs.  Do you have a
thought on that?

**Mark Erhardt**: Thanks for putting me on the spot!  But I have a thought on
why we have mempools, and I think it's a bit of an anti-pattern to send your
transactions to a specific miner.  I'm aware that this has been happening a
little more in the past three months, because people have been trying to get
really big inscriptions into blocks, and the only way to send a non-standard
transaction is to directly communicate with a miner, and then convince them
out-of-band to actually include it, because the standardness rules apply to most
nodes on the network, and of course they also apply to any miners that run with
regular configured Bitcoin nodes.  The standard rules mean that anything that is
out of the scope of standard rules does not get added to the mempool, nor does
it get relayed.

For example, one of the standardness rules is that no transaction can be bigger
than 400,000 weight units, which translates to usually around maybe -- the limit
is 400,000 weight units, but a lot of the inscriptions, there were some that
were almost the full 4 MB.  Somebody put a high res image of a Bitcoin Magazine
cover into the block chain, for example.  And so, why is this an anti-pattern to
give something directly to a miner to put it into a block?  Well, we want
everybody to be able to become a miner immediately, whenever they feel that
other miners are not prioritizing the right transactions, or engaging in
censorship.  And to that end, it must be possible for everyone to get the best
transactions from their own node.

So, we want to enable all of the best transactions and the best feerate
opportunities to gossip around in the regular network.  If you engage a specific
miner out-of-band (a) nobody else sees that transaction, (b) you have to wait
until that specific miner finds a block, whereas if you're bidding on the open
network, of course you're engaging all miners at the same time, if your feerate
is high enough.  So, I just don't think that it is a good trend to try to build
up separate mempools to prioritize non-standard behaviour.  It doesn't seem like
a good idea for me.  Maybe, if there's actual use cases that use transactions
that don't fit into the scope of our standard rules, we have to amend the
standard rules at some points.

But for example, the maximum size for a standard transaction doesn't seem to be
one that we should be touching any time soon, because the block building is so
much easier if you have smaller pieces.  So if we, for example, allowed
transactions to fit in the whole block, it becomes a lot more binary, "Is this
transaction in or is it not?" and it might lead to non-linear behaviour in
decision-making for block-building, and stuff like that.  So, yeah, not a big
fan of these ideas so far.

**Mike Schmidt**: Well, one thing that seems to have also been occurring lately
with these protocols using non-standard transactions, is that due to the fact
that they've been parsing these transactions out-of-band, it seems that there's
been an increase in block orphan rates.  Are those two tied together, Murch, the
fact that there's an increase in orphan rates; because when the block is
propagated, potentially some additional data needs to also then be transmitted
in these out-of-band transactions to go along with, which creates some overhead
and increases the chance of another block being found; am I getting that right?

**Mark Erhardt**: Yes, that's a good point, yes.  So, in ancient times, before
we had compact block relay, we would basically relay all transactions twice:
once when they're announced in the network and we gossiped them around; and the
second time, when the block was found, when we would transmit the whole block.
That leads to bandwidth spikes where right after the block is found, every node
that receives it will offer it to all of its peers, and most of them might not
have seen it yet, so suddenly you receive 1 MB and you have to forward 100 MB in
just a very brief amount of time.

Now that we realize that we already have most of the transaction data, we
introduced something called compact block relay, and it's essentially just
transmitting the header of the transaction and a table of contents, in the form
of short txids.  And then, everybody that has those transactions will rebuild
the block just on their end, instead of receiving the whole transaction set
again.  When you transmit transactions out-of-band, you're breaking this
preceding of the block data to the network, because especially, for example,
when you put an almost 4 MB image into the blockchain, nobody has that
transaction yet.  So, we are falling back to the point where people get the
block announced and then they have to ask back, "Hey, wait, I'm missing these
transactions.  Can you send them to me?"

We're introducing more round trips, we're introducing this bandwidth spike
again.  Of course, it also takes longer to receive the transaction data before
you can validate the block, before you forwarded them to other peers.  So, the
time that it takes for a block to propagate on the network is increased, which
leads to more often people tying and finding a block at the same block height.
Larry, you wanted to say something?

**Larry Ruane**: Well, real quickly, I think one thing I'll just emphasize what
you said a few minutes ago, that we want mining and operating pools to be as
open as possible.  So, we don't want to this to become kind of like an exclusive
club that newcomers, or potential newcomers might think, "I can't really get
into that club, because the club is where these out-of-band things happen", just
to emphasize your point on that; I thought that was a great point.

**Mark Erhardt**: Yeah, exactly.  If you basically make transaction submission
be something that you do by calling an endpoint of a miner, people are just
going to submit to the three to five biggest miners at most, and it really
hampers the smallest miners to have fair competition, because they'll not see
the best transactions.  They'll not only have a way smaller hashrate in the
first place, which has slight disadvantages, but they'll also just not get all
the feerates that others can collect.

**Mike Schmidt**: I think we did a good job of reviewing prioritization in this
PR Review Club meeting.  Larry, thank you for jumping in and walking us through
some of that.  You're welcome to stay on as we wrap up the Notable PR section of
the newsletter.

**Larry Ruane**: You're very welcome, thanks.

_Bitcoin Core #26094_

**Mike Schmidt**: Bitcoin Core #26094, adding block hash and height fields to a
few different RPCs.  Now, these RPCs are wallet-related, and one thing that we
note in the newsletter is that they could benefit from including the valid block
hash and height in the response.  And I guess a question for you, Murch, why is
it valuable for these RPCs to also include the latest block data?

**Mark Erhardt**: Well, one thing that I can think of is, if you're making that
call, you might want to write it away somewhere in a log, or from an enterprise
use, for example.  Then, if you have stored the context of it, it's probably
more useful in your logs, because you can go back and see what was in the block
chain at that point; and, yeah, just storing more context.

_Bitcoin Core #27195_

**Mike Schmidt**: Next PR is Bitcoin Core #27195, and I think we covered
something related to this recently, which is the ability, when you're fee
bumping, to be able to add and remove outputs from a transaction, when you're
bumping; and bumping meaning RBF, fee bumping a transaction.  But it sounds like
previously, you weren't allowed to remove all of the external outputs of a
transaction and just have the fee bumped transactions return all the funds to
your own wallet; whereas now, with this PR, you can remove all the original
transactions, outputs and spend back to yourself, and effectively have this
cancelling of the transaction.

But I thought we could already modify the fee bumping outputs in a replacement
transaction, but apparently you couldn't remove all of them.  Murch, maybe you
can comment on that nuance?

**Mark Erhardt**: I think it was essentially a bug in how we treated the change
address as a second-class citizen.  The change address is basically implicit, in
that it is not an explicit recipient of the transaction.  So, when we remove the
explicit recipient in order to reclaim our funds on a transaction that was
stuck, for example, then we weren't able to promote the change address to an
actual recipient that Bitcoin Core recognized as being a destination.  It was
just sort of, "How do I get the remainder of the funds back?"

So, just looking briefly at this, from what I understand, it is Furszy is
essentially removing this issue around not being able to send back to yourself.

_Eclair #1783_

**Mike Schmidt**: The next PR we covered in the newsletter was from Eclair,
Eclair #1783, adding a cpfpbumpfees API for CPFP fee bumping on one or more
transactions.  We also noted in the newsletter that there is an updated list of
recommended parameters for when you're running Bitcoin Core.  Murch, I don't
know if you got a chance to look at that recommended list, but instead of a
default of 25 for ancestors and descendant counts, they went with 20.  I'm
unclear on why they did that.  Do you have any reason that you think that they
might have done that?

**Mark Erhardt**: Well, in my unsophisticated opinion on this matter, I think
generally when people have a super-long chain of unconfirmed transactions, that
is a bit of a smell and points towards them probably doing something that they
could solve more efficiently.  So, being a little lower there seems reasonable
to me, especially because it -- so, 25 is the limit in Bitcoin Core where it
will stop relaying descendants, because they become non-standard, or fall out of
our policy rules.  So here, it gives the other parties involved in your
transaction maybe, or maybe yourself if you have another way of interacting with
the chain of transactions, a way of adding another child transaction to bump,
because you have a few more slots left.  Maybe that's the reason.

**Mike Schmidt**: Okay, yeah, that seems rational.

_LND #7568_

The next PR we had was LND #7568, adding the ability to define additional LN
feature bits when the node is started up.  And, digging a bit into the history
around this PR, there was a note that, "Today, it's possible to create all sorts
of meta, or overlaid protocols, that hook into LND using various interceptors
provided by LND.  However, none of these are able to currently advertise feature
bits, or custom TLVs in the node announcement message".

So, it sounds like there was a degree of customization allowed in LND in terms
of what you could do, but you couldn't advertise that you support certain
features using the LN feature bits.  Murch, (1) is that correct; and (2) maybe
just a little bit on what are LN feature bits, and who can decide what they put
in those bits or not for these different protocols?

**Mark Erhardt**: From what I remember, the feature bits are essentially an
announcement from your node what protocols and features they support.  So, for
example, with the upcoming Point Time Locked Contract (PTLC) outputs, or taproot
channels, or other such things, once you upgrade your node to a version of
software that supports that, it will announce it in its feature bit list as
setting the bit to flag that it has that feature and can support it.

So, maybe another tidbit is, I know that there are standard features that
everybody needs to have.  Those tend to generally have even numbers.  And then
there's more experimental or optional features that are odd in an effort to say,
"Are these okay?"  It's okay to be odd!  Anyway, I don't know much about LN
actually, so I think that's roughly what feature bits do.  So, from what you
described it, it sounds to me just that with the hooks on running additional
software externally from LND itself on channel interactions, or node requests,
it sounds like a way to easily get the information about what features you have
added on to your LND node into your node announcement, without making that very
intrusive into the LND codebase.  That's my take on it.

_LDK #2044_

**Mike Schmidt**: Last PR for this week is LDK #2044, making several changes to
LDK's route hinting for BOLT11 invoices.  And it sounds like some of the
motivation behind this PR is that currently with LDK, there isn't a limit to the
number of route hints that can be added to a particular invoice.  When a
receiver wants to provide those route hints, depending on how many channels a
node has, you could actually be sending a pretty large amount of data, and that
could actually break a bunch of different clients along the way.  So, LDK has no
limit on that, whereas LND has a limit of route hints to 20, and this PR changes
LDK to only include the "top three channels" now.  And the top prioritization is
based on both efficiency and privacy considerations now.

Then also, there were some changes in this PR around route hints that would
suggest multiple paths to the same non-existing phantom node, and so both of
those changes are involved with this particular PR.  All right, thank you all
for joining us on this podcast.  Thank you to Thomas, thank you to Larry for
joining us and lending us your expertise, and thanks as always to Murch, my
co-host.

**Mark Erhardt**: Thank you, that was a nice episode.

_Celebrating Optech Newsletter #250_

**Mike Schmidt**: And we'll see you all for next week, #251.  I guess maybe we
could comment briefly, we did have a note at the end of the newsletter, and I
don't think we often like to pat ourselves on the back, but there's a bit of
that here in celebrating Optech Newsletter #250.  We've taken the opportunity,
every 50 or so newsletters, to update folks on context of Optech and what we're
working on.

Obviously, we started out as a way to liaise information from the open-source
community to the business community.  It turns out a lot of people were very
interested in that content who weren't necessarily running a business.  And so,
the newsletters have been valuable for both types of audiences, individuals as
well as businesses, and we've expanded on that mission.  I'm working with
somebody now to refresh the compatibility matrix, which is interesting.  We can
get that more robust, add some taproot stuff, maybe some PayJoin stuff, maybe
some other aspects of testing to that wallet, in addition to opening it up to
contributions from outside.

Dave has done great work on augmenting the Wiki topics; I think we have over 100
now.  And now Murch and I have been trudging along with our podcast and having
great guests, like Larry and Thomas, on to talk about their ideas.  So, check
out the newsletter for this week, #250, where we also acknowledge a lot of the
contributors who have helped in the past year with translations, review and
contributions to the newsletter; there's a lot in there and we to make sure
everybody gets their pat on the back as well.

So, thanks Murch, thanks Larry, and thanks Thomas for helping us get to #250.
Cheers.

**Mark Erhardt**: See you next week.

{% include references.md %}
