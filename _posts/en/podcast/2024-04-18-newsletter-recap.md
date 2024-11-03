---
title: 'Bitcoin Optech Newsletter #298 Recap Podcast'
permalink: /en/podcast/2024/04/18/
reference: /en/newsletters/2024/04/17/
name: 2024-04-18-recap
slug: 2024-04-18-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt discuss [Newsletter #298]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-3-24/36624ded-c119-cce0-d997-fecbd9e78321.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #298 Recap on
Twitter Spaces.  Today we're going to be talking about a cluster mempool
simulation and some data that came out of that; we're going to talk about
changes to services and client software, including a Stratum-V2-related update
and a Teleport-Transactions-related update, among some other things; there is
the Bitcoin Core 27.0 release that recently made its way out; and also, our
regular releases and notable code changes updates.  I'm Mike Schmidt, I'm a
contributor at Optech and Executive Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I'm a full-time bitcoiner at Chaincode Labs.

_What would have happened if cluster mempool had been deployed a year ago?_

**Mike Schmidt**: We have one news item this week titled, What would have
happened if cluster mempool had been deployed a year ago?  And this is motivated
by a recent post from Suhas on the Delving Bitcoin Forum and, Murch, it looks
like he had a record of every transaction and block that his node happened to
receive throughout the year of 2023, and he has a record of all that.  He was
able to then replay that in its entirety against a different version of Bitcoin
Core that had cluster mempool enabled, and then he drew a bunch of conclusions
from that, which we noted in the newsletter and we can jump into, and then some
quotes as well from the newsletter.  But Murch, maybe is that the correct setup
to this?  And then, maybe we can get into what's the difference between cluster
mempool and, I don't know, do we call it legacy mempool, and then maybe some of
the conclusions.

**Mark Erhardt**: Right, so my understanding is that he must have been running
two nodes, one that was using the regular mempool, and one that was running with
cluster mempool, and he used his records to replay all of the transaction
submissions and the block discovery events.  And whenever a block was found, he
would use his two node variants to build a block template right before applying
the new block.  So basically, on the mempool, before reading in the new block,
he would build his own block template, and it's important that you build them
for both variants, rather than compare to the actual block, because your node
might have seen some transactions that weren't available to the block builder.
Often the block, the actual block, was given out to a miner and only found some
seconds after, so the mempool might include transactions that are not in the
block.

So anyway, he had then these two block templates, one from the regular Bitcoin
Core and one from the cluster mempool Bitcoin Core, and he compared those for
the fees collected in the blocks.  And yeah, pretty much that's what he did.  He
did then apply the actual block that was found though, so that'll cause us to
discuss some more stuff later.  You still there?

**Mike Schmidt**: Oh, sorry, I was talking on mute.  So, we noted three of his
findings.  The first one here, "The cluster mempool node accepted 0.01% more
transactions".  Is that just a fluke, Murch, or is there a reason behind that
number?

**Mark Erhardt**: My understanding is that it's basically, well, it means that
there's very, very little difference.  That's good news.  It means that if you
run your node in cluster mempool, it will largely process exactly the same
unconfirmed transactions.  And yeah, a difference of 0.01% is insignificant.
There is a slight difference.  So what he noted is, for example, transactions
that got accepted to cluster mempool because they were under the cluster limit,
but that didn't get accepted into the old-style mempool because they were above
a descendant or ancestor limit, and that's of course expected that different
limits will apply differently.  He also had the reverse, of course, where
something might have exceeded a cluster limit, but was in line with the ancestor
and descendant limit.  He overall sidestepped larger effects of that by
resubmitting all the rejected transactions whenever a block was applied.  So
basically, he simulates the behavior of most wallets that will continuously
resubmit transactions that haven't gotten mined yet.  So, yeah, to answer your
question, that's the good news!

**Mike Schmidt**: Murch, is primarily what's being measured there than what you
mentioned, which is under the classic mempool algorithm, it's ancestor and
descendant limit based, so that if something doesn't go into the mempool for
that reason, it exceeded those limits; and then on the flip side, with cluster
mempool, there's no notion of ancestor and descendant limits, we're talking
about cluster-size limits being hit, and so those are the two sort of rails that
are getting hit in these simulations?

**Mark Erhardt**: Yeah, that's a big part of what he is trying to find out, how
hard will these new cluster limits affect regular use on a network?  So, we have
at times seen very strange, humongous clusters in the mempool.  And because of
the ancestor and descendant limit, how it works, you can basically go down a few
child connections and then go up another parent, and you can make very broad
clusters that are connected through child-parent relationships, but that don't
directly affect each other's descendant and ancestor limits.  So, I think the
biggest cluster that I've seen was 1,400 transactions or so.  So, with cluster
mempool, we would be limiting the number of transactions that are allowed to be
in a cluster, the cluster being the transitive group, closed group of everything
that is connected via child and parent relationships.

So, a very broad cluster that would be permitted with ancestor and descendant
limits may not be acceptable for cluster limits, and vice versa.  In a cluster
limit, you could descend further than 25 transactions down, but that would of
course fall afoul of the ancestor limit.  So basically, he's trying to see, is
there a ton of people using big clusters in a way that would be affected by the
introduction of cluster mempool?

**Mike Schmidt**: The second finding was related to RBF changes between these
two simulations.  Cluster mempool uses slightly different replacement rules,
right?  I think it's focused on the feerate diagram, "Would the feerate diagram
of the mempool improve or not?" is the criteria for replacement.  And Bitcoin
Core's current RBF-related rules are basically what's in BIP125, sans some
slight differences.  So, there's some different rules there that are also being
evaluated in the simulation.  Do you want to -- first, Murch, is that correct;
and then second, what came of the simulation related to replacements?

**Mark Erhardt**: Yeah, that's correct.  So basically, in BIP125, we have a few
known constructions where essentially a replacement is allowed by the BIP125
rules that doesn't really make the mempool better.  So for example, when you
have a low feerate parent and a high feerate child, you do not need to supersede
the package feerate of that, but just the -- sorry.  If you replace the parent,
you only have to exceed the absolute fee of the entire package and the feerate
of the parent.  But the package might actually have a higher mining score, like
the package would be mined at a higher feerate than the parent feerate.  So it
is, for example, possible with the current BIP125 rules, to replace things with
stuff that does not make the mempool better.

So, that is one of the main motivations behind cluster mempool, is that it will
be easier and cleaner to assess the incentive compatibility of replacements and
actually only accept stuff that makes the mempool better.  And the tool on the
basis of which we do that is, as you said already, the feerate diagram, which
essentially is you take a cluster, you find out what the optimal order would be
for picking it into a block, and then you look at the chunks in which it would
be picked into the block.  And you can calculate the chunk feerates of those
chunks and draw those as a diagram, how much fee will you collect for how much
block space.  That forms a concave diagram and if you compare two clusters, one
with the original transaction, one with the replacement, you should see that the
replacement is at least as good as the feerate diagram of the original, but
should be better, in some part of it at least, and only then would we accept the
replacement.

Then the last conclusion that we noted from the writeup was related to, how does
this affect miners?  Is the construction of blocks or the architecture of the
mempool significantly better or worse under either scenario?  There are a bunch
of interesting histograms and graphs in the writeup that show fee differences
between the two simulations and differences in fees.  And what did Suhas
tentatively conclude there, Murch; is cluster mempool a clear win or a clear
loser for a miner?

**Mark Erhardt**: Yeah, so here it gets a little more complicated.  The thing
is, because he plays back the actual history of the last year, and the actual
history, for example, contains coinbase transactions that later get spent, so
you actually do want to replay exactly the blocks as they existed back then,
otherwise you might halfway through start having missing inputs and stuff like
that.  So, anyway, one of the things that cluster mempool can discover is when
multiple children pay for a parent.  So, if you have a parent transaction with
two transactions that spend two different outputs and they both are trying to
CPFP the parent, in the ancestor-set-based mining, what we currently use, these
two CPFP situations would be competing with each other.  The two children each
have an ancestor set fee score, and the one that has the higher feerate will get
picked into the block first with the parent, and then the second child,
unencumbered from the parent, will have a vastly higher feerate, right?  With
cluster mempool, we would discover that these three transactions would form a
chunk together, and we would calculate the chunk feerate across all three
transactions.  And in result, the three transactions might get picked at a way
higher feerate than either of the two CPFP constellations.

So, what can happen here in this simulation is that while you are replaying the
blocks, you keep collecting the best ancestor sets, but there might be a cluster
that contains some CPFP situations, and they just don't make it into the block.
So, for multiple blocks in a row, your comparison, where you build the
cluster-mempool-based based block template, would keep picking up these CPFP
situations and score higher than the ancestor set based, whereas the
ancestor-set-based block template keeps going down according to the best
ancestor sets getting picked out of the mempool, and then of course new
transactions arriving.

So, one of the concerns that Suhas has here is that the cluster mempool, since
the actual blockchain being built is not based on the cluster mempool template,
scores higher repeatedly because favorable situations of cluster mempool are not
removed by the block.  So, he can only conclude that in the direct comparison of
each mempool situation to build the next block template, every like 70% of the
cluster mempool block templates scored better, and that is a good sign.  That
means that cluster mempool does not appear to be doing worse than the regular
ancestor-set-based block template.  But it doesn't really permit the conclusion
that cluster mempool actually is always better; we sort of just have proof that
it doesn't do worse.  But altogether, those things are quite happy because you,

well, on the one hand, we know now we can do better incentive compatibility
assessments; on the other hand, we know that mining will do better.  We solve a
big issue that's been existing in existence for years, which is that the
building of block templates is not the exact opposite of pruning.  So, in the
ancestor-set-based mempool, we might prune things that are significantly better,
that contain subsets that would get picked into a near block, even though their
descendant scores are terrible, and that's why we prune them.  And in cluster
mempool, this is symmetric.  So, what we drop and trim from the mempool is
exactly the last stuff that we would ever mine, and that's another one of the
main reasons why cluster mempool is exciting.

Anyway, so the overall take that I have on this writeup is, it is looking like
cluster mempool is working great, and it will do at least as well in mining,
block templates are built way faster because we already have the order of each
cluster, so we only have to look at what part of each cluster from the front we
pick into the block, which is way faster than updating the ancestor sets all the
time doing block template building.  And RBF and cluster limits seem to affect
only a very, very small count of transactions.  So, I think overall it looks
like there's no big concern with moving forward with the cluster mempool
project.

**Mike Schmidt**: That makes a lot of sense what you mentioned about the
analysis over bias towards cluster mempool, due to the fact that the simulation
is done on data that was in an ancestor-descendant world, such that the cluster
mempool best options weren't chosen, so they just kept appearing block after
block potentially, maybe overemphasizing the value of cluster mempool.  Murch,
if I'm a miner, this sounds like something that I would be paying attention to.
I don't think there's any published timelines of cluster mempool, but maybe you
have an idea of availability if it were to continue to progress positively as it
has.

**Mark Erhardt**: Yeah.  So, there's currently a proof-of-concept branch that
Suhas is maintaining.  Hopefully there's going to be, well, Suhas and Pieter are
working on making some more improvements on that branch and then make the branch
available for first reviews.  I anticipate that that might happen in the next
month or so.  But timeline-wise, it's a very big project.  Mempool is at the
center of the node software.  It interacts with P2P, it interacts with block
building, it interacts with the wallet, because the wallet submits its own
transactions to the mempool, and so forth.  So, the draft PR that I've seen has
roughly 70 commits.  I anticipate that it might take a while until it is picked
into the master branch in smaller chunks and reviewed and everything.  It would
be nice to have it in the next release, but who knows; maybe one of the next
three releases, if we're honest with the speed that Bitcoin Core development can
progress on.

**Mike Schmidt**: Is there something that our audience, whether that's
individuals, but also potentially industry, businesses or participants, could be
doing to help this along in a productive manner, do you think, Murch?

**Mark Erhardt**: I mean, if you frequently build large clusters in your use, I
would say then probably there's better ways to achieve the outputs that you want
to create.  But if you often do that, maybe look at cluster mempool and see how
it would affect you.  If you are heavily reliant on replacement of transactions
and/or have implemented that, maybe take a look at the feerate diagram
replacement, because it works slightly differently.  And I mean at this stage,
it's mostly for the curious and heavily involved, because there's not even a PR
open yet for review.  But yeah, if you're involved at that level, maybe take a
look at those two things; and if that affects negatively, especially something
that you're working on, maybe chime in.

**Mike Schmidt**: Next section from the newsletter is our monthly segment that
highlights changes to different client software and service software in the
industry, using and adopting and releasing interesting Bitcoin tech.

_Phoenix for server announced_

First one here is Phoenix for server being announced.  I've seen it on their
site as Phoenix for Server but also more colloquially as phoenixd.  So, Phoenix
Wallet, built by the ACINQ people who do the Eclair node, they have a popular
mobile Lightning wallet, and they've now announced a simplified version of that
wallet that has a GUI on mobile, and it's a headless Lightning node they call
phoenixd, and it's focused on sending and receiving.  So, the folks behind the
scenes there at Async will be managing your channels, your peers, and any sort
of liquidity management.  So, this would be targeted at developers who want to
have some sort of Lightning send/receive functionality, but don't want to worry
about all of the plumbing associated with having such a Lightning wallet.  So,
pretty cool there.  I didn't play with it, but that's something that seems
pretty interesting to me.  Murch, what do you think about phoenixd?

**Mark Erhardt**: I think that could be very interesting for someone trying to
run some sort of Lightning-enabled business.  So obviously, if you already run a
server or so, you won't gain a lot because your Lightning Node might already be
able to do most of the things that ACINQ is doing for you.  But if you just have
a website that you want to integrate your Lightning payments into, I think this
could be a very attractive way of taking a lot of the complication out of
running your Lightning service.  And, yeah, if I were in the web shop business,
I think I might start paying attention.  I wonder whether it would integrate
well with something like BTCPay Server, but I haven't read anything about that
yet.

_Mercury Layer adds Lightning swaps_

**Mike Schmidt**: Interesting idea.  Next piece of software was Mercury Layer
adding Lightning swaps.  We've talked a little bit with the Mercury folks
previously, I believe the parent company's CommerceBlock, in their state chain
called Mercury Layer.  And this latest announcement is about adding Lightning
swap functionality to their state chain.  So, they use these hodl or hold
invoices to enable sweeping a state chain coin for a Lightning payment.  And the
way that they have that set up, so the state chain coin is separate from
bitcoin, but it's supposed to be a one-way peg, so this isn't necessarily all
chains per se.  And there's also some swapping functionality.  If you dig into
the article, which I did not unfortunately post in the writeup here, there's
some interesting research on their repository outside of just Lightning swaps,
some atomic swaps that are possible as well using similar technology.  So, I
apologize for not including that, but that's something that you can google
yourself and find the markdown file in the repository.  Anything there, Murch,
for you?

**Mark Erhardt**: No, sorry, I haven't really looked much into that.

_Stratum V2 Reference Implementation v1.0.0 released_

**Mike Schmidt**: Next piece of software is the Stratum V2 Reference
Implementation v1.0.0 being released.  We've covered the Stratum Reference
Implementation previously in its alpha version.  This is now the official 1.0.0
release.  Stratum V2, as a reminder, is a set of protocols and tools for miners
and pools to communicate.  I think probably the feature that people are most
excited about or familiar with is this idea that an individual miner can choose
their own block template, while also participating as part of a pool setup.
Obviously, that is something we, as bitcoiners, are super-interested in from a
decentralization perspective.  And in fact, 0xB10C had some analysis recently,
I'm not sure if you saw that, Murch, on Twitter, showing that it appears
potentially some pools that appear previously to be independent were potentially
participating in a sort of pool setup, and that maybe the mining and mining pool
ecosystem is a bit more centralized than we had anticipated.  Did you see that
research that 0xB10C put out, Murch?

**Mark Erhardt**: Yeah, I've skimmed it.  I saw that it looks like some of the
maybe seven or so larger mining pools are actually all -- mining is very
similar, if not the same template, as ANTPOOL.  There had been long some rumors
about several of the bigger Chinese mining pools all being just sock puppets of
ANTPOOL, but this template overlap seems to be pretty indicative of that, there
being more to that rumor.

**Mike Schmidt**: Well, hopefully, some of the miners participating in that
setup have some urge to want to help to centralize some of that and want to
participate in some block template building themselves, and they can check out
the Stratum 1.0.0 Reference Implementation release.  There's also a starting
guide.  So, if you look for Stratum V2 Reference Implementation Getting Started
Guide that can help miners integrate that technology as part of their mining
setup.

_Teleport Transactions update_

Next software update is related to Teleport Transactions.  Back in Newsletter
#192, we covered the announcement of the Teleport Transaction software.  And at
the time, I think it was a 0.1 release, and it was implementing or trying to
implement the coinswap protocol.  The coinswap protocol, as a reminder, lets
users create a set of transactions that look like different an independent --
well, they are different transactions but they look like independent payments,
but they're actually just swapping coins with each other.  So, an interesting
privacy tech but it hasn't had much momentum, at least the Teleport Transactions
project hasn't, in the last couple years, partially due to the primary author
becoming ill.  But in the last few weeks, a software fork of that original
Teleport Transactions was announced, which seems to have largely re-architected
the coinswap setup and also finished the original, and also implemented some
additional supporting features.

So, there's a tweet thread about that that you can dig into and find the GitHub
backing that, and it's exciting to see folks pick up that torch and continue
with it.  I haven't played with it, I haven't seen much feedback, but you'll
have to see people putting their time towards that.  Any thoughts, Murch?

**Mark Erhardt**: Yeah, so I think that bringing up the Teleport Transaction
proposal, in the context of taproot being available on the network, is pretty
interesting because previously, the atomic swap that is performed between the
two transactions required you to explicitly show in the Bitcoin Script what is
happening.  And with taproot, due to the tweak, you don't even show that it's a
2-of-2 multisig.  You could have a MuSig input that is under the hood, crafted
from two keys, but people wouldn't even see that it's not a single-sig
transaction, so it'll be cheaper and it will be even more like every other
transaction on the network.  I'm actually catching myself, I don't think that
you have to show it in the script, but it would be a 2-of-2 multisig in the old
style.  So, yeah, now it would just look like single-sig, so it's even cheaper
and cooler.

**Mike Schmidt**: There is a v0.1.* from the README file, which is a
future-looking version, sort of a roadmap checklist, and one of the items in
there is transitioning to taproot outputs for the protocol, which would, like I
said, enhance some privacy and obfuscate some of the contract information.  So,
that's great.

_Bitcoin Keeper v1.2.1 released_

Next piece of software that we highlighted this week was to the Bitcoin Keeper
mobile wallet.  Bitcoin Keeper is a mobile wallet app that has multisignature
capabilities, hardware wallet support, Whirlpool coinjoin support, and in their
most recent release before this newsletter was published, they've added taproot
wallet support.  So, it's good to see more taproot adoption.  I know we
highlighted a lot of that in years past, but I still want to give a little kudos
to folks that are doing that.  So, good job, Bitcoin Keeper team.

**Mark Erhardt**: Maybe here a comment.  The Bitcoin Keeper wallet was
previously known as Hexa Wallet, and so they're not coming out of the nowhere,
which was my first impression when I saw that name.  They've been around for a
while, just rebranded.

_BIP-329 label management software_

**Mike Schmidt**: Next item, titled BIP-329 label management software.  Back in
Newsletter #273, we covered a Python library that was for working with BIP329
labels, wallet labels.  So, BIP329 is a wallet label BIP that specifies how you
can attach a little bit of text to transactions or outputs, that's meant to be a
piece of private information for you to say, maybe you received this from XYZ
person and don't do this with this UTXO.  You can sort of put labels towards
those pieces of information in your wallet.  So, back in #273, we highlighted a
Python library that helped facilitate some of that; and on top of that library,
the same authors had built a hosted service for label management called
Labelbase.space.  And that team, as of this newsletter that we're highlighting,
now has a v2 of that service and software, which includes the ability to
self-host your own version of that wallet labeling management software, that
includes features like importing and exporting the wallet labels in BIP329
format, and a bunch of other goodies, so good to see someone taking the torch on
the label management side of things and moving that along.  Any thoughts there,
Murch?

**Mark Erhardt**: Yeah, so one of the things that people sometimes don't
consider when they make the backup of their wallet is, having the keys is enough
to recover all of the funds, but not all wallet backups actually store these
labels.  And, well, especially for people that take a manual approach to privacy
and build many of their transactions themselves, or at least label all of the
addresses they create extensively, that can be a real loss when they have to
jump back to a backup and don't have these labels.  So, my understanding is that
the Labelbase actually, just to be clear, stores encrypted backups, and that
would enable someone to have access to these, even if they have to roll back to
a prior state or lose the device, or something like that.  So, this is pretty
cool.  It makes life easier.

_Key agent Sigbash launches_

**Mike Schmidt**: Last piece of software we highlighted this month was Key agent
Sigbash launching.  Sigbash is a signing service, so how it works is you can
actually buy an xpub from this service and then use that in a multisig setup,
and the service will sign only in certain conditions that you specified at the
time that you purchased the xpub.  So, that could be based on hashrate, bitcoin
price, a certain address balance, or after a certain time, is what they listed
as conditions.  And I believe all those are being pulled from the mempool.space
API behind the scenes.  And a couple of interesting pieces of tech that I
thought were worth highlighting related to that, because I think on the surface,
that maybe isn't so interesting for Optech listeners.  But there's a couple
things I thought were and I wanted to hear what your thoughts were on this,
Murch.

It uses blind xpubs, which is a proposal for how to blind xpubs so that the
possession of a certain seed phrase doesn't reveal anything about what it
protects.  So, I thought that was that was cool.  I haven't heard too much about
that.  Any thoughts on that piece before I move to the next one, Murch?

**Mark Erhardt**: I don't have a deep understanding of the blinded pubkeys.  If
that is true and can be proven to be so, that would be very cool.  But maybe as
a different description or summary of what's going on here, this is an oracle,
an oracle that will sign off on something after certain events or conditions are
met.  And that enables you, for example, to make a bet on the price or hashrate
with a second party and then have this independent oracle, that doesn't even
know what it's signing or doesn't even know what you wanted the public key for,
but when you do sign something, it does see what you signed probably.  Anyway,
it's sort of like a way to automate a judgment in a bet or maybe even fancier
protocols or contracts.

**Mike Schmidt**: Yes.  Oracle is probably a good word to convey what's going on
at the heart of the service.  And the other piece of tech that I thought was
interesting, nothing sophisticated, but I thought it was a clever add-on.  So,
because it is an oracle, we'll roll with that term, instead of having some sort
of a slashing mechanism or bonds, or something like that, to ensure that the
Sigbash signing service doesn't go rogue, they make use of something that
previously was referred to as a GPG contract.  What goes on there is when you
purchase this xpub, there's a date that you purchased it, and the service will
then sign a sort of receipt with their PGP key, and provide that signed receipt
as well as an OpenTimestamps file for the GPG signed receipt, proving that that
receipt was signed on or before that date that the xpub was issued.

So, a few different things going on there.  We have xpubs, we have GPG keys, we
have OpenTimestamps to sort of ensure somewhat of a reputation system.  Now
obviously, if the service doesn't sign, that doesn't mean you get your money
back or anything, but you at least have proof that that they said they were
going to do something and they did not.  Anything to add there, Murch?  All
right.

_Bitcoin Core 27.0_

Releases and release candidates.  First one, the big one, Bitcoin Core 27.0 is
officially released.  Murch, I know we've gone through the Testing Guide, which
touched on some of the items that we covered here in the newsletter this week
with the full release.  I will turn it over to you, as our resident Bitcoin Core
developer, to outline what you think is most interesting about the release.  We
can drill in as deep or as shallow as you'd like.

**Mark Erhardt**: All right.  Well, I think the biggest elephant in the room is
that the 27 release will enable v2 transport by default.  So, we've talked about
this a number of times before, but v2 transport will encrypt all communication
between two nodes.  Note that it only encrypts it, but not authenticates it.
So, what this achieves is, if you previously had a passive listener on the way
between yourself and the node, all of the traffic was unencrypted and they
could, for example, see if you were the originator of a new transaction that
they never saw before.  If they were keeping logs on the Bitcoin traffic that
was going through their nodes, they would, for example, be able to tell that
some specific IP address might have been the sender of a transaction.  But when
now the traffic is encrypted, it takes a little more work to identify that
traffic is Bitcoin traffic, because it no longer necessarily identifies, well,
you have to run Bitcoin software in order to recognize Bitcoin traffic now,
which means that any listener along the way has to come from being passive to
actually actively man-in-the-middling any Bitcoin communication.

So, that in itself doesn't make it impossible to be surveilled, but it makes it
a lot more expensive and difficult.  It may also enable other protocols that use
encrypted traffic to piggyback on the popularity of Bitcoin and hide their own
encrypted traffic by looking like Bitcoin traffic.  And the idea in the long run
is that this may be overlaid with an authentication mechanism, where if you are
trying to reach a specific node on the other side, for example your mobile
client is trying to reach the full node that you're running at home so that you
trust your own node for information about the blockchain or unconfirmed
transactions, then you would be able to authenticate that you actually reached
the other node, and the encryption plus authentication would make it impossible
to man-in-the-middle undetected.  Anyway, that's the biggest piece probably.

There is some stuff that excites the developers.  So, for example, in the 27.0
release, we finally switched to C++20.  You require now a C++20-capable compiler
to build Bitcoin Core.  That's pretty awesome because it enables us to finally
use C++20 standard libraries and things like that.  What else?  There's a few
smaller things.  One thing that might be interesting, in the context of
potentially approaching mempool congestion, is that 27.0 comes with the
CoinGrinder coin selection algorithm.  And this algorithm will minimize the
weight of the input set when you build a transaction, if the feerate is 30
sats/vByte (sat/vB) or higher, or if you set the consolidate feerate at a lower
feerate.  So, if you are building a lot of transactions and if the Runes
protocol actually leads to a lot of block space demand in the next week, you
might want to upgrade to this release and use CoinGrinder in order to at least
build minimal transactions.

**Mike Schmidt**: I was going to say, maybe Runes is going to force people to
upgrade to 27.0 sooner than later, because they're going to want the
CoinGrinder!

**Mark Erhardt**: Yeah, I mean maybe.  And, yeah, I think those would be my
biggest ones.  Maybe for developers, it's worthy to note that the
libbitcoinconsensus is getting deprecated and this is the last version that will
ship it.  In v28, it will be removed.  It's just been a maintenance burden and
it doesn't really get used much, from what we see.  The on-disk saving file for
mempool is getting XORed now, so if you have any unconfirmed transactions that
have a funky byte string that might get picked up by a malware scanner or
something on an anti-virus software on your computer, then it's now XORed and it
won't, and that's maybe probably not a big deal, but may be interesting for some
people.

Yeah, oh, and the TRUC transactions, previously known as v3 transactions, are
now available on testnet, so we'll be able to test package relay with two
transactions pretty soon.  So, yeah, that's cool.

**Mike Schmidt**: We talked about this maybe a couple times.  I think there's a
PR Review Club on it, but we talked about network-adjusted time, and that is now
removed from the consensus code, replaced with unadjusted system time.  We had
some conversations about that.  I think you could probably google or comb the
site for those discussions if you're interested in more there.

**Mark Erhardt**: Yeah, the big problem just is, if all of your peers are lying
to you about their own time, you would have a funky time.  And so now, we're
just relying on the time of your computer.

_BTCPay Server 1.13.1_

**Mike Schmidt**: Next release, BTCPay Server 1.13.1.  Our last BTCPay release
highlight was for BTCPay Server 1.11.1, and that was in August of last year.
So, we've batched the last several BTCPay releases into a single update here.
We talked about making the webhook system in BTCPay a little bit more extendable
and pluginable, I believe is the title of the PR.  Also adds support for BIP129
secure multisig wallet setup, that would let BTCPay Server communicate with
multiple wallets as part of coordinating a multisig setup.  And we talked about
BBQr-encoded PSBT keys previously, and that's now in BTCPay.  And there's also a
bunch of other features and fixes that we did not note in this particular
release, but you're free to scroll through the last several releases back to
1.11.1 to see the details there.  Anything to add, Murch?

_LDK 0.0.122_

The final release for this week is LDK 0.0.122 and we referenced the 0.0.121 as
well; there's two separate releases.  The .122 release included two fixes that
were around serialization and deserialization, and also an optimization around
excessive unneeded persistence of state with LDK's channel manager.  So, an
optimization improvement and two fixes in 122.  And we did not have a chance to
cover 121, which was also released last week, and that release fixed a deadlock
issue, and also included a DoS vulnerability fix that seems to have crept up
since the .119 release, which was related to a scenario where during LDK's
handshake process with a peer, if a gossip message is received in the middle of
that handshake from another peer, or if the user calls a certain function
broadcast node announcement, during that time it can actually cause a panic in
Rust world and that it could be manipulated as a DoS vulnerability.  So, that
was 121 and 122 for LDK.

_LDK #2704_

We have one Notable code change this week to LDK repository.  I'll take the
opportunity, if anybody has any questions about Bitcoin Core 27.0 or any of the
pieces of software that we talked about, and Murch's great overview of the
cluster mempool simulation we did earlier, feel free to post a question or
request speaker access.  LDK #2704.  This is actually, I know we say this
section is Notable code and documentation changes, but I don't really recall
actually having a solid documentation change here until now.  I'm sure we've had
it, but this LDK #2704 is 660 lines of documentation and example code around
LDK's important ChannelManager class.  We noted, and I'll quote here, the
channel manager is, "A Lightning node's channel state machine and payment
management logic, which facilitates sending, forwarding, and receiving payments
through Lightning channels."  So, that sounds important, that sounds worthy of
having 660 lines of documentation and sample example code for, so that's what
this PR is.  Murch, anything to add?

**Mark Erhardt**: I agree.

**Mike Schmidt**: Any announcements?  Upgrade Bitcoin Core.  I saw Niklas Gögge
posted, "Something something 20%-plus of the Bitcoin Network is on an
unsupported version of Bitcoin Core".  Obviously there's features, obviously
there's bug fixes, and you can get Murch's CoinGrinder in the next 24 hours
before things get crazy.

**Mark Erhardt**: Yeah I wanted to talk about that a little bit actually.  So,
I've seen again a bunch of people talking about how they don't like some of the
new features or are generally unhappy with what Bitcoin Core contributors have
been focusing on, and therefore are running old versions.  A popular one seems
to be 22.0, for some reason.  The release cycle of Bitcoin Core is such that the
two major brand releases are maintained until a new release comes out, and then
those two latest are maintained.  So, when 27.0 was released, 25.2 was also
released, and that is the final, presumably final, release of the 25 branch.  If
there's something really dire that needs to be fixed, it might get a security
update, but features or smaller things will not be backported to the 25 branch
anymore.  24 is end of life, it'll not get support; 23 is end of life; 22 is end
of life.

In the release 27, there's been, I looked it up yesterday, about 1,170 commits.
And as you heard us talk, there's maybe a dozen or so notable new features in
the release notes, or I should say notable changes, not all of those are
features even.  So, you might imagine that there is a number of other things
that got addressed in the last six months, notably like 1,000 other code
changes.  We do fix issues, we do fix bugs.  So, if you're running a version
that is multiple years end of life, there might be a bug in it that could cause
issues to you.  That's why people are harping on, "You might want to run
maintained software".  Other things that happen are that, of course, operating
systems get updated, some libraries might get removed, eventually software will
just not install correctly out of the box, or the whole environment of what runs
on computers changes over the years.  So, even when Bitcoin remains
forward-compatible, in the sense that you can run old nodes and you'll be able
to consume all of the blockchain data that is propagated and gossiped on the
network, you might want to consider keeping with the current version, especially
if you run it as a wallet, or have a service or money tied to it.

Anyway, you do you, you can run old versions if that's your thing.  Just be
aware that we're not making this up.  We're actually working on fixing stuff,
and those fixes might be relevant to you.

**Mike Schmidt**: Maybe one reason, from the release notes of 27.0, that you
might not want to upgrade is if you are a Windows user using external signing.
That is disabled until the underlying library can be replaced with a different
library.  So, maybe a reason there to hold back if you're in that Venn diagram,
which I imagine is quite small.  And then, yeah, so I didn't see anything about
this 22 being the new thing we jumped back to.  I know we covered a Stack
Exchange question, I think it was 0.12.1 or something, people saying, "What
happens if I run it?  What happens if the network runs it?"  I don't know.  I
think if you guys want to be hardcore, like who was it, the Bitcoin-Assets guys
back in the IRC, Bitcoin-Assets channel, they said, what was it, 0.3.something
was the real Bitcoin?  So, why not just go all the way back there, get back,
what is this 22 stuff?  He says sarcastically!  Please upgrade to 27.0.  I see
we have a speaker request made.

**Mark Erhardt**: If you do want to play it safe, maybe run 25.2, or 26.1, if
you don't want to upgrade to 27 yet.  And that's reasonable.  Give it a few
weeks, especially if you have a service on it, but maybe don't run multiple-year
outdated software.  Do you allow that?

**Mike Schmidt**: Let's do it.  Satoshi's Bride is connecting.  Satoshi's Bride,
do you have a question or comment for Murch or I?

**Satoshi's Bride**: Yes, sir, thank you for your time.  My question is, if
you're going to be a brand-new miner, you want to do the new upgrade, or you
want to do something else?  That's my question.

**Mark Erhardt**: I think as a miner, you will not see a huge difference between
27 and 26.  So, if you want to play it safe, run 26.1.  It's a maintained
release that also was just released a few days ago.  Some people choose to wait
a little for a few weeks in case that the pre-release testing didn't catch
something.  If someone has an issue in production, they don't want to be on the
latest version.  That's totally reasonable.  Yeah, just keep with it and keep an
eye on it.  Maybe just don't let it run for multiple use.

**Satoshi's Bride**: Okay, and then my second question is, I was confused
between segwit and taproot and which allow more transactions total per block?

**Mark Erhardt**: So, they are slightly different in the input size and output
size.  I assume that you're talking about P2WPKH, which is native segwit v0,
which was introduced when segwit came out, and P2TR, which is native segwit v1.
They are very similar in size.  One big advantage of P2TR is that you can do
multisig where sign-off of multiple keys is required, but it still onchain only,
looks like single-sig.  So, for example, if you are reliant on a multisig setup,
that would be an obvious block space savings to switch to that.  Regarding the
actual transaction size, they're very similar.  I have a writeup where I argue
why, from the perspective of a user, it is economically rational to switch to
P2TR.  But yeah, was that your question?

**Satoshi's Bride**: Yeah, but I guess I'm asking in regards to, okay, I'm still
kind of confused about everything, but basically, the limit of -- I'm talking
about Lightning and the fees and lowering fees, and how much messages you can
send within one block.

**Mark Erhardt**: Right, okay.  So, segwit introduced something called the
witness discount, where it counts witness data at a different weight than other
transaction data.  So, with the segwit activation in August 2017, the blocks
could get bigger, up to 4 MB.  And this got more used over the years by more
people using segwit transactions; and most recently of course with inscriptions
that write to witness data, we've seen some really, really big blocks.

**Satoshi's Bride**: Okay, but if I want to keep fees low, then I would go for
the small blocks and the software with the small block ability?

**Mark Erhardt**: No, it has nothing to do with that.

**Satoshi's Bride**: Okay, I want more transactions though per block, right, if
I want to have low fees?

**Mark Erhardt**: Yes, but since we're a whole network that collaborates in
producing blocks, it's not just up to you.

**Mike Schmidt**: And Satoshi's Bride, if any of this is confusing for you, you
could also always ask your husband, who could probably clarify some of it as
well!  Murch, anything else before we wrap up?

**Mark Erhardt**: No, that's all from me.

**Mike Schmidt**: All right.  Thanks, Murch.  No special guests this week.  We
did it, just to co-host together, and thanks you all for joining us and we will
see you and hear you next week.

**Mark Erhardt**: Hear you then.  Cheers.

{% include references.md %}
