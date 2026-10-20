---
title: 'Bitcoin Optech Newsletter #358 Recap Podcast'
permalink: /en/podcast/2025/06/17/
reference: /en/newsletters/2025/06/13/
name: 2025-06-17-recap
slug: 2025-06-17-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Antoine Poinsot, Peter Todd,
Josh Doman, and TheCharlatan to discuss [Newsletter #358]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-5-17/402348085-44100-2-e516e54c780c1.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome to Optech Newsletter #358 Recap.  We're going to talk
today about selfish mining, transaction relay censorship resistance, we have
updates to BIP390, the MuSig descriptor spec, we have a discussion about a
library for encrypting descriptors, a PR Review Club covering the bitcoinkernel
project, and our usual Releases and Notable code segments.  I'm joined by my
co-host, Murch today, and we have some special guests.  Antoine?

**Antoine Poinsot**: Hey, my name is Antoine Poinsot, I work at Chaincode Labs.

**Mike Schmidt**: Josh?

**Josh Doman**: Hi, my name is Josh Doman, I'm an independent developer.

**Mike Schmidt**: Charlatan?

**TheCharlatan**: Hi, I'm TheCharlatan, and I work on Bitcoin Core.

_Calculating the selfish mining danger threshold_

**Mike Schmidt**: Thank you all for joining us this week.  We have a few news
items that you all are a part of, and so we'll jump into that right now,
starting with, "Calculating the selfish mining danger threshold".  Antoine, you
posted to Delving Bitcoin a post titled, "Where does the 33.33% threshold for
selfish mining come from?"  And maybe for our listeners, we can frame things a
little bit first.  Maybe first, what is selfish mining?

**Antoine Poinsot**: Selfish mining is a strategy that a miner can follow that
consists in strategically withholding blocks when they find a block.  So, in
this case, when I mean a miner, I mean essentially a mining pool, or of course a
very big solo miner.  And by default, Bitcoin Core nodes are going to broadcast
a block as soon as a miner finds it.  And a selfish miner is going to diverge
from this basic strategy, that is optimal up to a certain threshold, in the hope
of actually finding a higher proportion of blocks compared to the hashrate, the
share of the network hashrate it controls.

**Mike Schmidt**: All right, great.  And so, can you get into some of the
previous research on selfish mining, and then what you and Clara jumped into
when you got a little deeper into that?

**Antoine Poinsot**: So, something akin to selfish mining was discussed very
early on in Bitcoin Talk in 2010, and it was later formalized and laid out in
details in a 2013 research paper, which described the strategy, which is the
paper I linked to and I studied with Clara, and that my write-up is based on.
This research paper was pretty seminal, because it not only demonstrated that it
was possible for a miner to follow a more optimal strategy than the "honest"
one, rather let's say the default one, if they can sibyl the network, which is
if they can get their block to propagate faster than everybody else; but also,
if they do not have this ability, the strategy is more optimal past a certain
threshold and after enough time.  Then, selfish mining was later studied more
and more after this paper, which opened up a whole lot of research, and there
were many papers with slightly tweaked selfish mining strategies.  I'm not
familiar with every one of them, but there is some more optimal strategies that
depend on other conditions and other parameters.  But I was more interested in
getting the intuition and verifying the math behind the actual basic strategy
of, "I do not have a privileged access to the P2P Network.  I can still follow
independently, without coordinating with anybody else, a strategy that is going
to guarantee me finding more blocks after enough time".

**Mike Schmidt**: Can you explain the privileged status or the sybling the
network for faster propagation?  How does that come into it?  Is this to
mitigate chances of orphan, or something else?

**Mark Erhardt**: Yeah, exactly, to mitigate the probability that you get a
stale block.  So, the intuition behind selfish mining is that you are going to
try to cause more stale blocks to the rest of miners on the network than you
have to yourself.  Because mining in Bitcoin is a zero-sum game, you can
increase your gain by making your competition fail more rather than improving
yourself.  Like, both strategies are equivalent.  And it is a zero-sum game
because of the difficulty adjustments which is, let's say you have 40% of the
network hashrates and you have a stale rate of, I don't know, 25%, and then you
cause to the rest of the network, the 60% of the rest of the hashrate, you cause
them to have, I don't know, a 50% stale rate, then the network as large is going
to only find, as I said here, is only going to find 60% of the blocks it should
have found within two weeks.  So, it's going to take longer to find these
blocks, so the difficulty is going to readjust to take the stale rate into
account.  And once the difficulty readjusts, you're just going to have a higher
proportion of the actual blocks found, because you have a lower stale rate.

So, yeah, selfish mining is all about stale rate.  And just to answer your
question from Mike then, Murch, and then to answer your previous question about
the propagation, how it plays into this, is that you're often going to end up in
a race in selfish mining, whereby some other miner in the network found a block,
they propagated to the rest of the network and you had a block that you had not
propagated.  And you learn that actually this other miner found a block and so
you want to propagate your own private block to the rest of the network as soon
as possible, and this other miner obviously wants to do the same.  And there is
a race parameter in the selfish mining paper which guides the assumption of the
share of the network you can get your block first before the other miner can get
to them.  And if you can get your block first to them, it means that they will
start mining on top of your blocks, which increases the likelihood that the
other miner is going to go stale and not you.

**Mark Erhardt**: Sorry, you said that the rest of the network would have a
stale rate of 60%, while the selfish miner would have a stale rate of 25%.  How
can a miner that is in the minority have a lower stale rate than the rest of the
network?  I would have assumed that the stale rate would be higher on the
selfish miner, but it would still work out for them in general.

**Antoine Poinsot**: Yeah, so the numbers I stated were just arbitrary to just
illustrate the zero-sum game of the difficulty adjustment.  But this is how, if
you run the simulation that I provided in my post, you will see that the selfish
miner has a lower rate.  And this is because the selfish miner is not announcing
its blocks by default, which is a lot like the honest -- all the other miners
are assumed to follow the default strategy of always publishing their blocks.
If they don't, well then the model does not take that into account.  And in this
case, you can think of multiple scenarios.

**Mark Erhardt**: Sorry, I think I just got it.  May I jump in?  So, the stale
rate only applies to cases where there is two competing blocks.  And in the case
that there are competing blocks, it goes well in 75% of the cases for the
attacker and 40% for the defender.  Is that what you were … no?  Okay, sorry.

**Antoine Poinsot**: No, the stale rate is over a period, you're going to find
very, very high stale rates for it.  That's why we say that selfish mining would
be obvious if one miner starts following it, because massive stale rates and a
lot of reorgs on the network.  And tl;dr, the reason why the selfish miner
imposes a higher set stale rate than the others is that the others are going to
waste the hashrate mining on blocks that are guaranteed to go stale when a
selfish miner manages to find a longer chain.  So, you can think about it like
the paper does by describing the various situations you can end up in.  A
selfish miner is always going to, when he finds the block, he just puts it on
the side privately.  He never announces it by default, which is if the selfish
miner finds a second block on top of his private block, then he's guaranteed
that as soon as someone publishes a block, he's just going to reorg it out,
which is for the whole time that the rest of the network is trying to find this
block that is guaranteed to go stale.  And this is why, because the rest of the
network is not keeping it private and doing the same to the selfish miner.  The
selfish miner is taking advantage that the rest of the network is telling him,
"Hey, I have that many blocks, I have that many", and then the selfish miner has
knowledge of how much advance it has compared to the rest of the network.  And
that's why it allows the selfish miner to strategically release the blocks that
he withheld and cause a higher stale rate.

**Mark Erhardt**: Right, of course.  The attack only starts if the attacker
finds the first block, and this just randomly happens.  And since it's a
progress-free competition, it's the same as time zero for everyone else, they
are still working on the same height.  So, let's say an attacker has 40%, just
as you earlier said, now they have a 40% chance to find the next block before
everyone else finds this block.  That's not true.  40%, they find the next block
while 60%, the others find a block.  So, it's almost two-thirds the chance of
succeeding at that point, right?

**Antoine Poinsot**: Yeah.  So, you can simplify this by just saying that when
the honest network is finding a block, the miner is just going to change step
and start mining on top of this block.  So, at any point in time, the selfish
miner has 16% chances of finding two blocks in a row.  As soon as they find two
blocks in a row, they're guaranteed that the rest of the miner is wasting their
hashrate mining on a stale block.

**Mark Erhardt**: And the simulation assumes now that he always loses races, or
that he wins some of the races?

**Antoine Poinsot**: The simulation is for the worst case and my study is for
the worst case for the selfish miner, which is he always loses all races; that
is, in the event that he finds a block, keeps it private, but does not find a
second block on top of it, and then the rest of the network finds a block.
There is a 1-block race.  And in this case, the selfish miner is propagated as
soon as possible, or its the same.  And in this case, we just assume that the
only miner mining on top of the selfish miner's block is itself, nobody else.
Everybody else is mining on top of the "honest block".  I don't like to assign
honest business to this, because it's a possible strategy.

**Mark Erhardt**: So, what spurred this renewed interest in selfish mining?

**Antoine Poinsot**: I don't know.  I guess I always just thought I understood
it and I didn't.  And then I went to the paper and I wanted to study the math
and I couldn't, but I have the chance of being at Chaincode and I have a math
PhD sitting next to me.  So, I was like, "Clara, can you explain me the math in
the paper?"  And so, we went through the math together and I got a better grasp
of it, so I wanted to share.

**Mark Erhardt**: Well, okay, let's say the motivation might have been that two
miners together have, or one mining pool plus all the mining pools that appear
to work on the same block template has 41% of the hashrate.

**Antoine Poinsot**: Yeah, ANTPOOL could clearly pull up selfish mining.  It's
unclear why they don't start doing it.  It's also the case that the model does
not describe, what if multiple selfish miners appear at the same time, because
let's say that, I don't know, in response to this, Foundry and MARA joined
forces to do the same, they would be past the threshold, where they are able to
do the same.  And in this case, I tried to run it on my simulation, it was doing
random stuff.  So, it's pretty unclear.  So, the uncertainty certainly plays a
big part, but it's also the case that the mining subsidy is decreasing
exponentially, so we should expect miners to start playing games at some point,
I think.

**Mark Erhardt**: Two selfish miners with both over 30% sounds quite horrible,
because only less than a third of the hashrate would then announce naturally,
and then almost always get reorged by two blocks immediately.  So, that sounds
like a ton of reorgs.  That sounds like a very unstable network.

**Antoine Poinsot**: Yeah, and also, which is the argument that is put forth in
the paper, is that the selfish mining pool is going to find a lot more blocks
than its hashrate at the expense of the smaller pool.  So, miners on the smaller
pools are going to have to switch pool or go belly up.  The operation won't be
able to continue if they just cannot pay the bill.  So, it's really going to
lead to an equilibrium, a large, big pool.  And maybe in the case of two selfish
miners, maybe two large, big pools, but I don't know, I have not studied.

**Mark Erhardt**: I think it would maybe even lead to basically a majority
attack, because the other selfish miner does not announce blocks either.  So,
they would only announce if something is broadcast.  So, I don't even know what
would happen if the selfish miner is in the absolute majority.  Would they ever
publish a blog?  Anyway, this sounds fascinating.  So, what were your learnings?

**Antoine Poinsot**: That it's real, I guess.  This is a strategy.  There is
some uncertainty attached to actually pulling it up on the main network.  You
don't get revenues from it immediately.  You need to wait after the difficulty
adjust and it would be very obvious.

**Mark Erhardt**: I mean, you'll have standard revenue at least, right?  You
find 40% of the blocks before you start attacking, and then you will still have
the same absolute count of blocks found, but probably the fees would -- yeah,
yes, of course.

**Antoine Poinsot**: No, you inflict to yourself some stale rate.

**Mark Erhardt**: Oh, right, okay.  You actually do lower your revenue
temporarily?  Right.  Okay, fair.

**Antoine Poinsot**: In the long run.  So, you've got some costs, some
short-term costs, you've got some certainty, and you've got probably an angry
Bitcoin community, but I don't think that's a big argument, because it's unclear
also how we would fix it as well.

**Mike Schmidt**: Yeah, that's what I was going to say.  We're bitcoiners and we
want to do something about this.  It sounds like there's no magic.

**Antoine Poinsot**: There has been research on the topic.  And one obvious
thing is to take stale blocks into account in the difficulty adjustments, which
is a hard fork, and might also create perverse incentives for other reasons.
For instance, we have seen some altcoins that were playing with different
difficulty adjustments, calculations and rewards calculations.  For instance,
Ethereum had this anchor blocks that they took into account, but then they
didn't take into account for the difficulty adjustments, so it didn't prevent
selfish mining.  But then, it still incentivized anchor mining, which was, you
had the strategy on Ethereum at the very beginning where you could just mine
anchor blocks instead of mining the main blocks, and it was more profitable for
a miner.  So, yes, it's probably something we don't want to really have to
touch.  But probably we should have a plan in case it happens.

**Mark Erhardt**: Although there's been more research since then and there's
some interesting proposals I saw.  One of the two authors of the 2013 paper,
Ittay Eyal, I think, had, what was it called, Colored Chain proposal, that we
talked about at the Bitcoin Research Week.  But anyway.

**Antoine Poinsot**: Yeah, I don't remember how it works, but I did hear about
it as well.

**Mike Schmidt**: All right, Antoine, thanks for jumping on and explaining the
summary of that research for us.  We don't have Peter Todd here for the next
news item, but I did pencil in a Notable code diversion for Bitcoin Core #32406.
Antoine, you want to hang on for that one?

**Antoine Poinsot**: That's the OP_RETURN one, right?

**Mike Schmidt**: Yes.

**Antoine Poinsot**: Sure.

_Bitcoin Core #32406_

**Mike Schmidt**: Yeah, okay.  So, #32406 removes the existing 83-byte OP_RETURN
limit by raising the default data carrier size while keeping the data carrier
options and marking them as deprecated.  So, for reference and for listeners,
Murch, you and Sjors spoke about a lot of discussion around this PR in
Newsletter #352, we covered it; and Podcast #352, you and Sjors went through
that for about an hour or so.  So, listeners can go back to that to hear that
chat if they haven't already listened.  But, Antoine, since then, I think the
dust has settled, the PR's merged.  What's your perspective on this PR?  How
would you summarize any updates since a few weeks ago for our listeners?

**Antoine Poinsot**: I'm not sure what to say.  Yeah, the PR was merged.  It was
pretty obvious given the wide consensus that were around this PR from all
Bitcoin Core contributors.  It's going to be released in the next version, the
next Bitcoin Core version, which is going to be 30.0, which, Murch, I think is
expected in three months, something like that?

**Mark Erhardt**: October.

**Antoine Poinsot**: Okay, so four months.  And yeah, I think we probably won't
talk about it much at this point.  I don't think it's going to have much effect,
if only to avoid the perverse incentives that it was setting for people that
just want to rely on it for their timely transactions.  Yeah, I don't have much
to say, to be honest.

**Mike Schmidt**: Murch, it looks like you want to say something.

**Mark Erhardt**: Yeah, well, I've been following the debate a lot.  I've also
spent a lot of time talking to various people that had concerns around this PR.
My takeaway was that first of all, I still think that this policy is pretty much
a nothing burger.  A lot of people misunderstand that this is only a mempool
policy change, which means it affects only what unconfirmed transactions are
being accepted to the mempool of Bitcoin Core nodes and being relayed to their
peers.  I think a lot of people misunderstood that even though something like
99.5% of all nodes on the network were not forwarding large OP_RETURN
transactions, we've seen over 10,000 OP_RETURN transactions that break this
limit in recent blocks.  So, I think we see that the narrative that having a
mempool policy broadly adopted, almost absolutely adopted, does not prevent
these transactions to be in blocks.  Sure, they only get mined by two miners
currently, or two mining pools I should say, and these two mining pools earn
more on their block templates due to being able to include these juicier
transactions, so it is rational for them to include them.  They're consensus
valid after all, so the blocks will propagate just fine.

I think that one of the things that bothered me a bit was that the effectiveness
of not including these transactions in your own mempool was heavily overstated.
We see them get included at minimum feerate in whatever block is mined next by
some miner that includes them.  So, I think the policy does only hamper the
other miners from having an equal footing in earning revenue.  Either way, the
other thing that a lot of people were concerned about was that this would
immensely increase block sizes, and it cannot increase block sizes because
OP_RETURN data lives in outputs, and outputs are non-witness data, so they have
a weight of 4 weight units per byte.  And if you fill a block with non-witness
data, blocks cannot be more than 1 MB.

So, finally, it's only more economic to create OP_RETURN outputs up to about 140
bytes before the existing inscription construction is cheaper.  And I think the
concern that we'll see humongous OP_RETURNS all the time is overblown.  We will
see some because people are doing BitVM and other second-layer constructions
that rely on humongous commitments in transactions, and they're just going out
of band.  They even have signed agreements already with mining pools that they
will be able to get their transactions mined.  So, I think the obvious choice is
just to accept these into the mempools so that all mining pools will include
them and have an equal footing, even if it means that there will be minusculely
more data moved towards OP_RETURNS from other ways of including data in blocks,
or maybe even a little bit of extra data being included.  Because overall, we've
just talked about selfish mining.  We talked about how two block template
creators create about 71% of all blocks.  If we want smaller mining pools to
have the best chance to participate in the mining ecosystem, we are going to
have to try to make it as fair as possible to them.

So, I don't know.  The whole debate seems just fueled by the other side being
very invested in it, and us being not that invested in it, because it just
doesn't feel like that big of a deal.  But yeah, so it got merged.  Finally, I
had one final takeaway that's important.  A ton of people approached me and said
that they were less upset about the limit increasing, but more upset about the
option going away and them not being able to control what is in their mempool.
Now, I think that is a little bit of an unnecessary option for people that just
run nodes at home.  But one thing that actually convinced me was, people that
want to move forward and build their own block templates, and do not want to
include large OP_RETURNS, can use this option to control what is in their block
template.  So, I think I'll continue to argue that we don't remove it in the
next version after 30, so 31.  If people continue to have that sentiment, it is
deprecated in the sense that developers are suggesting that you don't use it
unless you know exactly what you're doing, because we think that it's overall
better for the health of the network if you accept large OP_RETURNS and forward
them to small miners.  But if you do wish, I assume that the option will stay
probably for another version or two at least.

Anyway, that's my takeaway.  Yes it got merged because it had very broad support
by Bitcoin Core developers, and I think also most of the technical community was
very convinced after they actually engaged with the arguments.  But we should do
a better job of explaining stuff to the broader ecosystem.

**Antoine Poinsot**: I have two things to add to this, besides that I disagree
with regard to the option, but I won't die on this hill, I think it's fine if it
stays.  You mentioned mining centralization.  I think it's worth underlining
that if we have, in Bitcoin, structural forces that just push to having miners
that control more than half of the hashrate, then Bitcoin is worthless.  Like
the entire point of Bitcoin is censorship-resistant transactions.  If one person
decides whether you get your transaction in or not, it has no purpose.  It's
just a very expensive way of doing something that could be done much more
efficiently.  And then, which is interesting, because the company that has been
financing this whole communication operation against Bitcoin Core for this
change has claimed that were mining more decentralized, it would not be an
issue.  And I think it's a big confusion, because if you just go through the
thought experiment of a completely decentralized mining, then people that just
want to get their transaction just mine blocks to get their transaction in.  And
there is no more such thing as limiting transaction based on mempool policy,
right?  So, the more mining was decentralized, the less the mempool policy
matters.

**Mark Erhardt**: I feel like you're skipping a few steps in that line of
argument.  Sure, if people wanted specific transactions to be mined and they
could go and mine a block, they would get it in, of course, if it's consensus
valid.  But also, to mine a block is a significant investment.  So, if they were
trying to do it and not succeeding, they would just spend a lot of money on it.
I'm not sure if that's really an effective way of getting your own transactions
mined.

**Antoine Poinsot**: Yeah, I might say what I mean is that the Bitcoin Core
standardness is relevant to Bitcoin just because of how centralized mining has
been and because a few actors have been respecting the Bitcoin Core standardness
rules.  The more actors you would have, the more likely it would be that one of
them would just stop respecting it.  So, the more decentralized the mining, the
less the central decision of Bitcoin Core on standardness matters.  That was my
point.  It's not as easy as just saying anyone could be drafting a block.  It's
just on a spectrum, it would be much easier if you have more diversity.

Then the other point was, yeah, well, maybe not worth rehashing this.  So, yeah,
that's all.

**Mike Schmidt**: Antoine, thanks for hanging on for that Notable code
diversion.  We understand if you have other things to do, and you're welcome to
stay if you'd like.

**Antoine Poinsot**: Thanks for having me.

_Descriptor encryption library_

**Mike Schmidt**: All right.  Our next item was, "Relay censorship resistance",
but Peter's not here.  I'm going to stall for him by skipping a little bit out
of order here, and we will go to, "Descriptor encryption library".  Josh, you
posted to Delving Bitcoin about your descriptor encrypt Rust library for
encrypting wallet descriptors.  Maybe before we get into the library, can you
explain a little bit about your motivation for wanting to encrypt wallet
descriptors?

**Josh Doman**: Sure.  Thanks for having me.  I am relatively new to Bitcoin and
the way that I got comfortable initially with the idea of self-custody was when
I learned about multisigs.  And so, I went through this process of setting up a
multisig, and at the end of the process, I was surprised to learn that my seed
phrases were not enough to actually recover my funds.  I was using one of the
service providers that do collaborative custody, and it was a really shocking
kind of scary user experience to be thrust at the end of the page with this
scary thing you've never seen before, that you also need a backup somewhere and
you don't know what it is.  And so, my motivation was to find a way to backup
that data in a public format so that people don't need to back up offline
anything but their seed phrases to help improve that user experience and make it
a little bit safer.  Because a lot of people are scared off today from
multisigs, based on things they see on Twitter about how you can lose your
money.  So, that was my initial motivation.

I built kind of a proof of concept over a week or so earlier this year that only
worked for standard multisigs, that lets you basically encrypt it and then store
it as an inscription on the blockchain, which I know there's a lot of different
people with different opinions about whether that's something that's appropriate
to do or not.  But for me, it solved my problem because I could make a one-time
payment and not have to worry about it ever again.  The horror of it though is
finding a way to encrypt descriptors such that you cannot decrypt it without
having enough keys to spend the funds.  And so, that's what this library does.

I was motivated for a couple of key reasons.  I spoke with notmandatory, who
encouraged me.  That was pretty cool.  He said, "You should make this a Rust
library so that wallets could integrate it".  And then, I also saw a post that's
independent of what I had built by salvatoshi, who had devised his own
encryption scheme that was simpler than this.  It only encrypts the descriptor
with one of the keys in the descriptor.  So, if you have one key, you can
decrypt it.  And I wanted to flesh out my approach, which is a little bit more
robust and better for certain use cases, especially if things are stored in
public, or if for whatever reason you want to store your descriptor next to your
seed phrase, but you don't want someone to be able to see how much funds you
have.  And so, this is also my project for the Bitcoin 2025 hackathon, and so
those are my motivations for building this.

**Mike Schmidt**: Okay, great.  Yeah, go ahead, Murch.

**Mark Erhardt**: So, basically the idea is usually when you have a multisig,
let's say 2-of-3 multisig, you require two private keys in order to spend, but
of course you need all three public keys in order to be able to recover what
your UTXOs actually were, plus the information how the multisig was constructed,
which usually has some derivation path information, and so forth.  So, this has
been a problem for a long time.  People have been confused for years about, "Oh,
I have two of my keys.  Can I get my funds back?"  No, you can't, because you
don't have the third public key.  So, the standard solution to this was usually
that with the file that backs up your private key, you also store a description
of your wallet.  And this got way easier with descriptors, because previously
with the xpubs, you actually didn't have information about what the keys were
used in, what output scripts, because it only encoded the key information.

So, what I'm gathering here is instead of just storing the descriptor
information next to one of the key backups and with every one of your key
backups, you are encrypting it.  And other than salvatoshi, where you need a
single key to decrypt it, which means if anyone gets one of your backups, they
can see both the key and re-derive the descriptor and therefore see all of your
funds, this one requires them to have a spending quorum in order to see it.
What's this about putting it in the blockchain for backup?

**Josh Doman**: I would say that each to their own.  I think that this is
clearly a very sensitive topic, and a lot of people are against putting anything
that's not payment-related data in the blockchain.  One of the reasons why I
felt that this was kosher is that I do consider it payment-related data.  I need
this data to spend my funds.  And various projects, like utreexo, require users
to back up other data that if they're running a light client, that today already
exists on that blockchain.  So, that's the philosophical approach for why I
think it's okay.  I think that the answer to your question is you don't have to
back it up on the blockchain, and this library does not dictate you do so.  This
is purely a library to very efficiently encode the descriptor data, minimum
number of bytes, and encrypt it.  You can store it wherever you like.

Now one of the reasons why putting it on the Bitcoin blockchain is useful is it
makes recovery much simpler, especially for people who maybe are your heirs or
people who don't know where to look.  Because it's in a fairly well-recognized
place where you can easily access that data by downloading the blockchain, users
can scan it and find it if they have enough keys.  Whereas if you store this
data, let's say in Google Drive, well, they might delete it, or maybe your heirs
don't know how to access it, they don't know where it is.  And so, that's the
reason why I think that putting it on the blockchain could make sense if you're
willing to spend the money.  I think it's also worth saying that the cost of
doing so is finite in terms of the number of vbytes, meaning that if you can
afford to make a multisig transaction or a transaction with a more complex
descriptor, you can almost certainly afford to put that data onchain if you want
to do so.  Because, for example, a 2-of-3 descriptor encrypted, if you were to
put it in the witness data, it's only about 100 vbytes.  And so, I don't know if
that helps answer your question.

**Mark Erhardt**: Yeah, thank you.  So, I understand the privacy part of someone
finding one of your backups, and let's say it's a seed phrase and it's a file
that's stored next to it, or a written-out descriptor for getting the
construction of your wallet back.  So, you lose privacy if any one of your
backups is compromised.  But so you're saying, why not just store your
compactly-encoded backup with these files?  That would still satisfy it.  So, it
isn't necessary for people to put it on the blockchain.  They can just store
their seed phrase together with this encrypted descriptor package.

**Josh Doman**: Yes, I would say that's certainly true.  I would say there's two
benefits to putting it on the blockchain if you want to do so.  The first is you
can still use decoy setups.  So, while it's true if you encrypt it and you store
it next to your seed phrase, they might not be able to see how much money you
have in it, but they'll know that it's part of a more complex setup, which some
users might care about.  And second, and I think it's also worth saying that I
think it's important to build for all types of users; people have different
types of wants and needs.  And I think that for some people, they would prefer
to minimize their cost and put it right next to their seed phrase and print it
out and figure out how to do that.  I think that for other people, like people
of my parent's generation, etc, it's already complex enough to learn how Bitcoin
works.  They buy this hardware wallet, they download it, tells them how to put
their seed phrase on, they understand how that works.  Cool.  I think that if
there was a simple, in their wallet, press a button, pay a little fee, and now
they don't have to really even learn too much about what the descriptor is, I
think that there would be some interest in that solution for some people.  It
certainly is something that I want for myself, and that's enough reason for me
to build this.

**Mark Erhardt**: Maybe one more follow-up.  So, if that is a standard function
in wallets, how could just importing the file that is stored next to the seed
phrase not also be a standard function?  Downloading the whole blockchain,
scanning all of the inscriptions seems a lot more complex or time-consuming than
being able to import the file through a standard that's implemented by many
wallets.

**Josh Doman**: That's true.  So, in the post, I mentioned that if you do want
to store it on the blockchain, what you should do is attach a 4-byte hash of
each combination of fingerprints that can be used to spend the funds.  That way,
you can then have an indexer that can be run by myself or you could build it
yourself, or also, you can use a centralized service.  And all you need to do is
connect your devices and press recover.  So, that's actually how I built the
original service, the multisigbackup.com that I released a few months ago, is I
have this thing running in the background, it's open-source.  I haven't built
that for this version, but if there is demand, I can do that.  But that's how I
imagine it would work, users would just connect their devices that they know
they have, press recover, and then they can access their money.

**Mike Schmidt**: Josh, thanks for coming on and representing your ideas on the
show today.  You're welcome to stay on it, but if you have other things to do,
we understand and you're free to drop.

**Josh Doman**: Thanks, Mike.

_Separate UTXO set access from validation functions_

**Mike Schmidt**: Murch, I'm going to jump to the PR Review Club section because
we have a special guest waiting in the wings.  Bitcoin Core PR Review Club, this
month, "Separate UTXO access from validation functions".  Sebastian, this is
your PR, which is currently still open on the repository and in the process of
getting review and feedback.  And it's part of the bitcoinkernel project.  Maybe
for listeners who aren't familiar yet, maybe you can give your elevator pitch
summary of the kernel project, then we can jump into the PR?

**TheCharlatan**: Sure.  The kernel project is the attempt of isolating the
validation rules that are currently contained inside Bitcoin Core and putting
them into a separate library.  And then, as the penultimate goal, we would
publish this library as part of a Bitcoin Core release, and other projects would
be able to use this validation library to either reimplement their own full
nodes or access Bitcoin Core data structures easier.

**Mike Schmidt**: All right, excellent.  Okay, so we have the context now of the
kernel project.  Why do we want to separate the UTXO set from validation
functions?

**TheCharlatan**: Yeah, so this is kind of part of a longer effort, and I guess
the first step towards that effort.  So, one of the more interesting clients
that one could build on top of a kernel library would be a utreexo client.  And
in utreexo, you would ideally not like to maintain a full copy of Bitcoin's
chainstate.  But for security reasons, you also probably don't want to
re-implement the entire block validation logic that Bitcoin Core contains.  So,
the middle road is what this PR intends to implement, by isolating out the
chainstate from the rest of validation.

**Mike Schmidt**: So, is this a strictly refactor PR; you're just sort of moving
things behind the scenes and ideally nothing would change for users, but the
library would have additional capabilities for these other clients in the
future, like utreexo?

**TheCharlatan**: It is not a strict refactor, but it gets kind of close to it.
So, there are some changes to the order of validation operations, and we do
introduce some new assumptions of when data structures are in a certain state.
But overall, the changes are mostly move-only.

**Mike Schmidt**: How nervous does making those sorts of assumptions and changes
make you with regards to the files you're touching here?

**TheCharlatan**: That's a tricky question, I guess.  But I think the scope of
the change is kind of limited, because it doesn't introduce any new logic.  And
when you review it, you can pretty clearly see how the logic gets moved around.
So, I don't think there's much possibility for some foot guns that might be
introduced through this change.

**Mike Schmidt**: One of the questions in the PR Review Club session has to do
with, there was a question for the audience and participants in the Review Club
about where you might have concerns about performance.  Are there performance
implications in this PR, positive or negative?

**TheCharlatan**: Yeah, so what the change does, it preloads all the coins that
are being spent in a block at the beginning of validation, and then uses this
preload directly for the rest of its validation operations.  And what the code
did so far is it would cache these coins into a map and then do a map lookup for
the coins for every operation.  So, then there is a small speed-up there,
because we don't do this map lookup every time, but it is kind of insignificant.

**Mike Schmidt**: How would you summarize, I was just trying to pull up the
tracking issue for the kernel project, because I like to give that to folks
because I like to follow along.  But how would you verbally summarize progress
on kernel and where we're at and what the next big pieces are?

**TheCharlatan**: Yeah, so I think the project is currently at a point where
most of the changes for isolating out parts that we really don't want in the
kernel are kind of done.  And we're now more in a phase where we're doing
changes to bring features through a potential future kernel API to potential
future users.  So, we're more trying to figure out what the use cases are and
how we can make the library useful for people.

**Mike Schmidt**: What is or is not in kernel?  Because I think I saw people
arguing about if there were mempool things; it sounds like we're abstracting
away UTXO set in this scenario; what's in or not in that people might not be
familiar with?

**TheCharlatan**: Yeah, so there's two sides to that question.  One is what is
actually being compiled code-wise into the kernel library, and that is currently
all the block validation logic and the mempool.  So, all the policy logic is in
there too.  Then, I also have a proposed API for the library, and that so far
only includes script and block validation features, as well as functions to read
data from the various data structures that we have in Bitcoin Core.

**Mike Schmidt**: Do you see, is mempool going to be in there in the final
state, do you think?  Would that be like a separate component?  Or how do you
think about that?

**TheCharlatan**: It's an open debate at the moment, but I would like the
mempool to be split out of it.  I think if we want to realize the full potential
of what this library has to offer to alternative implementations, we should
probably not make them build on how we exactly implement policy and mempool
rules in Bitcoin Core.  At the same time, it's kind of weighing off of allowing
full flexibility, but also realizing that the way we've implemented the mempool
in Bitcoin Core is pretty solid, and re-implementing all of that logic might
also be challenging for alternative clients, like utreexo.

**Mike Schmidt**: I see.  And so, that was going to be my question, what's the
argument to keep it if you're saying like, "Yeah, we can really pare it down and
people can build their own structures on top".  I guess the counter to that is,
"Mempool is secure and strong and we don't want to reimplement it".  Is that the
argument against?

**TheCharlatan**: Yeah, basically.  But I mean, for example, in the Knots case,
where they do want to implement all these extra policy rules, and probably have
some kind of stable interface that they can use to implement these rules against
that doesn't change all the time, so they don't have to rebase all the time and
maybe do a mistake on one of those rebases.  So, that might be an argument for
at least making the policy rules a bit more pluggable.

**Mike Schmidt**: Murch, do you have any questions for Sebastian?

**Mark Erhardt**: Actually one, yes.  I've seen multiple mentions lately again
in the context of the kernel project, that the Electrum server ecosystem is
quite muddled.  There are three different implementations that have all taken
multiple approaches to implement the Electrum protocol with different features.
How easy would it be to build an Electrum replacement on kernel?

**TheCharlatan**: Yeah, that's basically the reason for the other bigger PR I
have open at the moment against Bitcoin Core, which would allow, for example, an
Electrum indexer to read Bitcoin Core's block data through the kernel library
while Bitcoin Core is running and doing validation tasks simultaneously.  So,
I'm not fully convinced yet if re-architecturing some of our internal storage to
allow these kind of parallel tasks on our data is the right approach here, but
it is definitely interesting.  I think it could bring pretty significant
performance boosts to these external indexes.

**Mike Schmidt**: Murch, for reference, we had on Eric Voskuil to talk about
libbitcoin and some of the parallelization versus Bitcoin Core's current UTXO
model of ordering, that we just published that podcast this morning.  And
Sebastian, I think, was also on the line listening to at least some of that.

**Mark Erhardt**: Oh, I was wondering who that was.  You mean Brink?

**Mike Schmidt**: Yeah, yeah, sorry Brink.  Yeah, so if listeners are curious
about that side conversation, you can find that on brink.dev or our YouTube
channel.  Charlatan, really appreciate your work on this project and always try
to get discussions going about that wherever possible on the show.  How would
you leave the audience with any sort of call to action or something to chew on
with regards to kernel?

**TheCharlatan**: Yeah, so I have the kernel API PR open, which surfaces a C API
for the kernel library.  And it now has wrappers in four different languages, so
in C++, in Rust, in Python, and in Go.  And, yeah, it would be cool if people
could try that out, see what they can build with it, if they can build their own
full nodes with it, just experiment with it a bit.  It's definitely fun to do.
So, I've also implemented my own Rust full node with the kernel library.

**Mike Schmidt**: And I think the natural inclination is to go to implementing a
full node, which is obviously very cool, but somewhat intensive.  But I know
folks like, I think, Abubakar have used the kernel to do fee estimation or fee
analysis that was a lot quicker than sort of parsing the blocks straightaway.
So, there's a lot of other things that you can do, other than trying to roll
your own node.

**TheCharlatan**: Yeah, building out data analysis tools is pretty fun too.  The
cool thing is, with the way the API is laid out, parsing it to a thread pool or
some thread pool worker framework that just massively parallelizes reading from
disk, or similar I/O tasks, makes reading data from the blockchain really fast.
So, if you just plug that at the start of your analytics pipeline, that could
really speed up things for you.

_Updating BIP390 to allow duplicate participant keys in `musig()` expressions_

**Mike Schmidt**: Next news item is titled, "Updating BIP390 to allow duplicate
participant keys in musig() expressions".  Murch?

**Mark Erhardt**: Right.  So, Ava Chow, who's been working on implementing MuSig
and PSBT in Bitcoin Core, has written a bunch of the corresponding BIPs.  BIP390
is the BIP that specifies how to create output descriptors for MuSig2 outputs,
or MuSig2-based outputs.  And one of the things that were in BIP390 was that it
was forbidden to reuse the same participant public key more than once in MuSig2
output script descriptors.  Then, when she got to actually implementing that,
she found that it was quite complicated to implement, and now is wondering, is
there actually a problem that is being solved by not allowing repetition of the
same public key?  And so, there's a mailing-list post and this PR where this is
being discussed.  And so, far it seems that MuSig2 explicitly allows reuse of
keys.

One concern was reuse keys in the context of deterministic nonces, but MuSig2
generally advises against deterministic nonces in this context anyway.  And
then, yeah, so far it sounds to me like nobody has found a major issue with
repeating keys.  The PRs and mailing list discussions are still open in order if
you, listener, have some concerns or thoughts on this topic, please chime in.
Otherwise, BIP390 will be probably updated to allow implementation of output
script descriptors with repeated participant public keys.  And, yeah, so it's
still unclear to me and Ava stated as much why anyone ever would want to do this
with duplicate keys.  But if there is no problem with it, BIP390 will be amended
to allow it.

**Mike Schmidt**: Thanks, Murch.  It sounds like Peter might join us.  But as
the show must go on, we can jump to the Releases and release candidates for the
time being.

_Core Lightning 25.05rc1_

Core Lightning 25.05rc1.  We've had this on for a few weeks.  It was best done
by Dave and Alex in Podcast #355 where they went through that release.

_LND 0.19.1-beta_

LND 0.19.1-beta.  We covered this minor LND release last week, in #357, when it
was in its RC form, and we went through a bunch of the bugs and fixes in there.
So, refer back to Podcast #357 on that.  And that wraps up the Releases and
release candidates section.  And we can actually jump back to the news section
because who do we have on the line?  You want to introduce yourself?

**Peter Todd**: Yeah, let's see.  Can you hear me?

**Mike Schmidt**: Yeah, I can hear you.

**Peter Todd**: But yeah, I'm Peter Todd, known for talking about Bitcoin a lot,
very occasionally actually doing real work.

_Relay censorship resistance through top mempool set reconciliation_

**Mike Schmidt**: Thanks for joining us, Peter.  We stalled just enough for you
to be able to join us for the, "Relay censorship resistance through top mempool
set reconciliation".  Peter, you posted to the Bitcoin-Dev mailing list a post
titled, "Censorship Resistant Transaction Relay - Taking out the garbage(man)".
I think it might be good for you to explain what's been going on with your Libre
Relay nodes and these garbageman nodes, so that listeners can understand the
context for what you get into in this post.  People may have heard of Libre
Relay, probably haven't heard of garbageman.  I'm not sure, maybe you can just
set the battlefield for us before we get into strategy.

**Peter Todd**: Yeah, so Libre Relay uses a strategy I've used for many years
now, which is basically if you have relay rules that allow transactions that
other people don't, the way that you make your rules actually achieve anything
is by finding other peers with the same rules as you do, the same more Libre
rules as you do, and peering with them.  Now the case of Libra Relay, frankly
Libra Relay is mostly a project to make a point that Bitcoin Core can't get away
with trying to go and tighten relay rules to stop transactions people actually
want mined.  And notably, of course, one thing it does do is it relays OP_RETURN
transactions that were above what was previously in Bitcoin Core's limit.  And
then, it also allows transactions that use the annex in a standard way.

But anyway, the point is garbageman, that is a project that doesn't like this
more Libre relaying rules.  And what they want, what they've been trying to do
is a sybil attack against Libre Relay by pretending to be a Libre Relay node,
but not actually relaying the transactions that Libre Relay would.  When I say
pretending, the trick that Libre Relay uses, as well as my previous full-RBF
peering nodes, was we just advertise the service bit.  And then, we connect to
other nodes also advertising the service bit.  I forgot off the top of my head
what the number is.  It's like number 30 or something, but you know.

**Mark Erhardt**: 23, I think.

**Peter Todd**: Yeah, 29, 23, whatever it is.  But as you point out, that chunk
of service bits was something I basically got allocated, if you will, for
"non-standard uses" and experimental uses many, many years ago.  But of course,
when I say allocated, the problem with service bits is you can go on, you know,
there is no way to verify directly that a bit actually means that someone's
going to relay your transactions, and that's why garbage man is potentially
effective.  And in my post, I did go talk a little bit about you know how many
nodes that have to run for a certain amount of success, and so on.  But to get
to our point here, the proposal for what I posted on the Bitcoin-Dev mailing
list is to basically use the same mechanism we use right now to prevent sybil
attacks against block relaying, namely you figure out if a peer is relaying
something better than what you have right now, and if so, you switch.  And then
periodically, you drop the worst peer.  Now with blocks, you can do that with
chain height; with fees, it's a little more complex, but basically you can do
this with total fees.  How many total fees is your peer advertising that would
get into, say, the next one or two blocks?  And if one peer is less than others,
well, drop that peer.  And then periodically, just try a new peer at random and
see if they're doing better.

As long as you do this consistently, eventually you're gonna find a peer that
isn't blocking the transactions you want to see and you'll get, over time, more
and more peers that have the same relay policy as you, thus defeating this kind
of attempt at blocking transactions.

**Mark Erhardt**: Okay, I have a couple of questions, (a) I was wrong, it's bit
29; (b) the one question I had is, how do you manage to get comparable results
from all of your peers?  Do you send the request for their top two blocks at the
same time, or how are the results comparable?  Because otherwise, a node that
had more time to collect transactions since the last block might have just more
good transactions.  So, the later you are asked for it, the better you would
look in this comparison.

**Peter Todd**: Yeah, I mean I think these are all questions that will get
answered when someone actually tries to implement this for real.  I'd say the
biggest challenge to doing this is currently without cluster mempool, it's hard
to just quickly compute what would be, say, the next block or two worth of
transactions.  And once cluster mempool is implemented and in Bitcoin Core, then
it becomes easier to make that calculation.  And I think you're absolutely
right.  If I have a node that had recently turned on and was missing a lot of
transactions, it may very well be the case that peers implementing this method
would tend to go drop it until it got more transactions, which I think is okay.
From their point of view, this is indeed a peer that is not very useful yet, and
it may take time for it to get enough transactions to be useful.

**Mark Erhardt**: Right, that was going to be my follow-up question.  How do you
rejoin the network if all of the peers were running this protocol?  If you spin
up a new node, you'll always be the least useful and you'd have no way to get
new transactions because you don't have peers, so you wouldn't get better.
Wouldn't that potentially make it impossible for people to bootstrap new peers?

**Peter Todd**: Well, this question actually gets down to a subtlety of what we
mean by useful.  You see, there is actually two different types of relay we're
talking about here.  One is sending transactions to peers, and getting
transactions from peers.  And to do this properly in a way that actually defeats
censorship, you actually need to only consider the transactions a node sends to
you, not the other way around.  A good example is, in fact, garbageman's already
implemented this, if I give you a transaction and then you give it me back, that
is not an example of you doing effective relaying, or at least it's not proof
that you are.  Proof that you're doing effective relaying is if you give me a
transaction that I did not give you in the first place.  And it's likely that a
way to make this work, in reality, is to think more of relaying as actually a
unidirectional thing; I send out to nodes and then I receive stuff from nodes,
and you would only use this technique on the receiving side.

I want to make an important point here, which is I don't see this being as a
replacement for all transaction relaying.  I see this as being a backup
mechanism to ensure that even transactions that may be censored still do get
relayed.  So, one way to implement this might be to have a separate set of relay
peers, where we only use this mechanism and we do not in fact use a more
standard INV mechanism.  But these are all questions that need to be explored
more.  The purpose of my mailing list post was not to say, "Hey, here's the
solution".  Here is a class of solutions that look promising and obviously more
research is needed.

**Mark Erhardt**: Right, that makes sense.

**Mike Schmidt**: You mentioned cluster mempool as a piece of interesting
technology that we talk about in the show pretty regularly.  I don't think I saw
in your post, but it is in our summary, but I do think you made reference to the
broad category, set reconciliation.  We mentioned Erlay and minisketch.  Is this
something that you're actively working on or just soliciting ideas from
implementing some of this stuff?

**Peter Todd**: Well, so something I want to make clear here in case I haven't
already is, this mailing list post, none of the ideas in it are really mine.
Mostly that comes from a discussion I had with Greg Maxwell about set
reconciliation and how it could be used for this purpose.  So, I personally am
not working on this, although depending on how things go, I might in fact be the
person who does more work on this precisely and implement this.  We'll see what
happens.  My understanding is currently a lot of the harder code for set
reconciliation has already been written.  What's left is integration of existing
code into the actual logic to do this for the mempool for real.  But I haven't
personally looked at this in detail, so I can't authoritatively say anything on
that.

**Mark Erhardt**: I actually have looked a little more at this.  So, what is
being referenced here is the Erlay idea.  Erlay is a protocol for reconciling
what you will be announcing to your peers, what new transactions.  So, instead
of always immediately announcing new transactions as they become available in
your inventory, you would occasionally just compare notes with other peers about
what you will be telling each other about, and then much more efficiently but at
a larger cadence, get these announcements settled with all of your peers.  The
idea is that this would allow you to have much more peers for less overall
bandwidth use.  And the trade-off with that is you do want still some peers that
just do regular announcements, because otherwise it would slow down how quickly
you learn about new transactions.

So, this reconciliation mechanism uses something called minisketch where it uses
Moon Math to compare and calculate all of the pieces of data that would be
announced to each other.  And I think what Peter is proposing, it could instead
of comparing the announcements with each other, be used to compare the txids of
the transactions in the top two blocks.

**Peter Todd**: Yeah.  And I should say, again, this may be something that you
do in parallel to other efforts to use Erlay, this isn't necessarily an
either/or.  But I think that the key thing to say there is, why you would want
to do this mechanism is just so that you could efficiently say, "Hey, this guy
claims that he can provide me with this much fees, yet he has not done so, thus
I will go ban him for lying".

**Mike Schmidt**: Peter, have you thought about, it seems like there's been some
back and forth between these two implementations trying to trick each other,
etc, and you're proposing potentially this way.  Is there a counter to this
approach that the garbageman folks might be able to get around something like
this?

**Peter Todd**: Well, so I'd point out, I mean this hasn't really been a
back-and-forth situation at all.  In fact, if anything, I have not taken really
obvious steps that could make garbageman less effective, because I'd rather see
it get to the point where it actually did have some effects.  That would be
useful to understand how that actually plays on reality, because at the moment,
there just don't seem to be enough garbageman nodes of any impact at all; they
would have to run far more than are currently running.  One example being how
this might happen is, for instance, if Bitcoin Knots added this by default, and
my understanding is Luke Dashjr isn't very interested in doing that, because
there's obvious legal issues around this too.  But let's say hypothetically they
did.  Well, then as far as I know, assuming this type of relay became was
possible to implement in the way that I think it is, I don't know of any counter
to it.  Now, certainly, garbageman spinning up a bunch of nodes might make it
take longer for a new node to actually be effective at relaying, but given time,
because effectively the entire network is eventually searched for peers,
assuming that people actually need these transactions to happen and thus there
is that signal, that costly signal, relaying will work.

So, yeah, I mean it seems to be a very effective approach, but as always, it has
to actually be implemented and better understood to know whether or not that's
true.

**Mark Erhardt**: Yeah, I think that if you actually only did this with a subset
of your nodes every block, once or so, and you did it roughly at the same time
with all of the peers that were selected for this reconciliation step, you would
sort of get a signal which, let's say you do it with 20 out of your 125 peers
once every 10 minutes, you'd be able to get rid of one of your 125 peers per
block.  So, you'd cycle through 150-ish peers per day.  And eventually, that
would lead to you having more peers that have a good mempool.  And we also have
to note that most of the transactions included in the next block were only
broadcast in the last ten minutes.  So, actually, even if you're only online for
a few hours, you tend to have a very decent mempool.  And maybe the concern
about new nodes joining is not that dire, because there's enough nodes that
they'll cycle through them for many hours, so they should have a good mempool at
some point.

**Peter Todd**: Yeah, the calculation I did on the mailing list, if I remember
correctly, was basically assuming you do this process, say, every three minutes.
Dropping one not-so-useful peer every three minutes basically means that with
current numbers, you would end up having your best peers in, I think, something
like two days, which isn't great, but it's not terrible either.  So, I think
that's a pretty good improvement on the potential status quo of garbageman
actually working.

**Mike Schmidt**: Peter, thanks for hopping on and joining us.  Oh, do you have
one more thing to say?

**Peter Todd**: Yeah, I'll just point out one last thing, which is, despite all
this discussion we had, something to point out is that garbageman is only really
effective by itself for nodes that only make outgoing connections.  Because
nodes that accept incoming connections, one brute-force way to defeat it is to
just spin up nodes that have an enormous number of outgoing connections.  So,
whether or not anyone actually bothers to go and do this remains to be seen.
But anyway, thanks for having me on.

**Mike Schmidt**: Yeah, thanks again Peter.  Cheers.

**Peter Todd**: All right, bye.

_LDK #3793_

**Mike Schmidt**: Jumping back to the Notable code segment, which we started
earlier, we went through Bitcoin Core #32406 on the OP_RETURN limit size
earlier.  So, we'll jump next to LDK #3793, which implements a new message
batching approach using start_batch messages.  Previously, LDK used a custom
batching approach.  However, the LN splicing specification has recently been
updated to use these start_batch messages, which treat a series of messages
together as one logical message.  I'm hoping at some point we'll get a splicing
or an LN person on to dig into that a little bit more, but that was my takeaway.

_LDK #3792_

LDK #3792 introduces initial support for v3 commitment transactions.  Murch?

**Mark Erhardt**: Yeah, I heard the trigger word here.  So, we've been talking a
ton about TRUC (Topologically Restricted Until Confirmation) transactions, which
use v3 to signal that they would like to opt into the topology restrictions
until confirmed.  And we've also, I think, mentioned ephemeral anchors.  So,
this PR in LDK hides behind a test flag, a by-default-off new option to start
creating commitment transactions that have a fee of zero by using TRUC
transactions and ephemeral anchors.  And the idea here is, so we've, in the past
years, had a lot of LN channels close, especially when the feerates spiked,
because when two LN nodes disagree on what the new fee for a commitment
transaction should be, the outcome can be that they disagree and close the
channel instead, because the side that was paying the fees doesn't want to
increase and the other side demands higher fees.

One other solution in this context was that whoever wants to pay more fees can
pay the fees but the other party will not pay the fees.  And the TRUC
transaction approach is the more elegant one, which means you can make
commitment transactions, which is the transaction that is used to make a
unilateral close at zero fees.  And then, when you actually close a channel
using the commitment transaction, you bring the fees with the child transaction
that is attached via the ephemeral anchor.  So, from looking at this PR a little
bit, my understanding is it is now available in LDK, or rather in the next
release of LDK, and it is not on by default.  If you do turn it on, your node
will attempt to ask your peer whether the channel that you're trying to create
would work as a zero-fee commitment transaction if the peer also supports this.
And then, the two will together create this TRUC and ephemeral-anchor-based
commitment transaction.

One downside of these channels is that the HTLC (Hash Time Locked Contract)
limit will be reduced, because TRUC transactions are limited to 10,000 vbytes,
the parent, and 1,000, the child.  But we're talking about the commitment
transaction, which is the parent transaction in this pair of transactions, and
with the 10,000-vbyte limit, you can fit fewer HTLCs, so they're limiting the
HTLC to 114 instead of 483.  And, yeah, so pretty cool to see this out in the
wild.  I hope by the end of the year that we will have this more broadly adopted
across the LN implementations, and that hopefully will significantly reduce the
difficulty of running your own LN Node.

**Mike Schmidt**: I know BlueMatt, who is on the LDK team, is super excited
about these zero-fee commitment transactions.  So, obviously, it seems like
they're one of the ones leading the way here.  So, thanks for summarizing that,
Murch.

_LND #9127_

LND #9127 adds an option to LND's addinvoice command when using blinded paths,
for the user to be able to include which channels they prefer to receive the
payment on.  So, the option allows multiple channels and can be extended to
multiple hops leading to the node.  And there was an issue that was motivating
this change that noted that it actually allows the user, the LND user, to
specify paying over a specific channel, which gives that LND user an extra
liquidity control lever.  So, you can sort of quasi route things by specifying
these channels.

**Mark Erhardt**: Just seeing this summary, I wonder whether there's a privacy
issue here.  If you provide a single blinded path, you're just advocating or
you're revealing that you're in the vicinity of the entry node.  But if you
provide multiple different entry nodes, you're revealing that you're in the
intersection of the vicinities of these entry nodes.  So, I'm wondering whether
you you're sort of giving information to triangulate.

**Mike Schmidt**: Yeah, that's a good point.  You may be having more liquidity
benefits, but privacy hits.  And I didn't see that in the notes, but I also
wasn't looking for it, but that's a good point, Murch.

_LND #9858_

LND #9858.  This was actually part of the 0.19.1-beta release that we discussed
last week, which is actually now out.  After this change, LND will correctly
signal support on the P2P network for RBF cooperative close feature, including
the appropriate production feature bit, which in this case is 61 for RBF
cooperative closing support.  So, I think previously it was either in the
non-productive state or they just hadn't turned on signalling for the feature.

**Mark Erhardt**: It sounds to me that they were only using it as a testing
feature before, and now it's a production feature, which would indicate that
it's more mature.  I also note that it has an odd bit, which means that it is
not mandatory because it's okay to be odd.  And so, mandatory features that you
will require your peer to have if you have them are the even numbers, and the
odd numbers are bits that are optional that you can have and it's fine if your
peer doesn't.

**Mike Schmidt**: And the production are under 100, and the staging versions is
the same number with '1' in front of it.  Is that right?  So, for example, the
production for the RBF closing support is 61, but the staging bit, I think, is
161.

**Mark Erhardt**: That sounds reasonable.  Also, I was only guessing at the
prior thing.  And so, if someone disagrees, please let us know!

_BOLTs #1243_

**Mike Schmidt**: Last PR this week to the BOLTs repository, #1243, which makes
a change to the BOLT11 invoice protocol specification.  It actually clarifies
that a mandatory field that is present, but has an incorrect length, that
invoice should actually be failed instead of skipping that field.  Previously,
it was ambiguous about how that should be handled.  So, this PR corrects that
ambiguity that was present in the spec previously.  Murch, I don't recall, but
it feels like we covered perhaps LND or LDK, who ran into an issue with this, in
a previous podcast discussion.  I couldn't immediately bring it in for reference
for the listeners, but I think we did talk about something like this.  And the
issue here was actually surfaced via some differential fuzz testing between
different implementations.  And so, we applaud that fuzz testing work from Bruno
who surfaced that originally.  Anything else, Murch?

**Mark Erhardt**: I think we got everything.

**Mike Schmidt**: All right.

**Mark Erhardt**: It was a lot of jumping around today!

**Mike Schmidt**: It'll be fun editing for the timestamps, and all of that.  All
right, well, thank you to TheCharlatan, to Josh, Peter Todd, Antoine for joining
us this week, and thank you, Murch, for co-hosting.

**Mark Erhardt**: We'll hear you next time.  Cheers.

{% include references.md %}
