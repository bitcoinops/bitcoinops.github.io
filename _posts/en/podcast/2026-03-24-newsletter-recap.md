---
title: 'Bitcoin Optech Newsletter #397 Recap Podcast'
permalink: /en/podcast/2026/03/24/
reference: /en/newsletters/2026/03/20/
name: 2026-03-24-recap
slug: 2026-03-24-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by Matt Corallo,
Gregory Sanders, and Sebastian van Staa to discuss [Newsletter #397]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-2-24/420691428-44100-2-436cfa460cb3f.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #397 Recap.
Today, we have our monthly segment on Changes to services and client software,
which this month includes the relaunch of the FIBRE network, and we also are
going to talk about the L402 protocol.  We also have our Releases and release
candidates segment, and this week we're going to talk about Bitcoin Core
v31.0rc1; and we also have our weekly Notable code and documentation changes,
where we touch on a BIPs PR around OP_TEMPLATEHASH.  This week, Murch, Gustavo,
and I are joined by three guests.  We'll have them introduce themselves quickly.
BlueMatt, who are you?

**Matt Corallo**: Hey, yeah, thanks for having me.  Yeah, I wrote the original
FIBRE network, so I guess that's why I'm here today.

**Mike Schmidt**: That's right.  Instagibbs?

**Greg Sanders**: I'm at Spiral.  I do various things, including looking at
respective soft forks, and I've done other things like Lightning.  Yeah, that's
about it.

**Mike Schmidt**: Sebastian.

**Sebastian van Staa**: Hi, thank you for having me.  I'm a developer, I've
been developing things for a long time.  I've been following Bitcoin for a long
time and now I'm getting started contributing to Bitcoin Core full time.

**Mike Schmidt**: Awesome.  Thank you three for joining us.  For those
listening along at home, we're going to go just a touch out of order in
deference to our guests.  So, I hope you guys can handle that.

_FIBRE network relaunched_

We're going to jump into the Changes to services and clients segment, jump down
to, "FIBRE network relaunched".  Matt, your network, what was the FIBRE
network?  Why did it get shut down?  And then, what is this new incarnation?

**Matt Corallo**: So, FIBRE stands for the Fast Internet Block Relay Engine.
That's the British spelling for those of you Americans.  And it exists to allow
miners or other groups to forward blocks very, very quickly.  So, it's really
important for miners.  If you're a miner and there's a block found somewhere in
the world, you want to make sure you get that to your nodes as fast as possible
so that your nodes can start mining on the new tip and you're not trying to do a
reorg, which you might very well lose.  So, it's a patch set to Bitcoin Core.
It was written quite a number of years ago.  It was written around the time of
compact blocks, and compact blocks is built kind of as a part of FIBRE.  I ran a
kind of "production network" on it, so offering basically just running these
nodes, connecting them to each other to relay blocks very quickly between them,
which was available for any pool or any miner to connect to, some number of
years ago, basically when it was originally written.  But there was limited
uptake.

So, today, mining is mostly large pools.  Some of them have their own relay
logic.  They're hosted on large servers that they rent that have really good
connectivity and, and, and.  And so, they do fine on relay.  They could be
better.  And in fact, when the original FIBRE network got shut down, we did see
a little marginal increase in block orphans, or sorry, not orphans, Murch is
going to yell at me.

**Mark Erhardt**: Stale blocks.

**Matt Corallo**: Stale blocks, thank you!  So, it helped a little bit, but not
materially, and pools kind of didn't care very much.  But now, there's this kind
of resurgence in attempts at re-decentralizing mining.  So, that's Stratum v2,
that's P2Pool v2, that's Braidpool, that's DATUM, that's all these new attempts
to say, "Okay, actually we're going to select blocks at the edges, which is the
critical part for Bitcoin.  We're going to actually do transaction selection at
the mining level".  But for that to work, edge miners that might not have
perfect connectivity and might not have people on staff to ensure they have
perfect peering, somehow need to have a good way to get blocks very quickly.
And so, a public FIBRE network offers them a potential avenue to get blocks.
Now this just supplements the existing P2P network.  Obviously, they're still
going to make normal P2P connections, they're still going to run a normal node.
But it's important to have something that is well-optimized.  And if they don't
have the resources to do careful optimization, it's nice to have something that
exists just kind of out of the box.  They can just go to their bitcoin.conf,
they can addnode one of these nodes, and they'll probably get blocks a little
faster.

So, Localhost spent a bunch of time rebasing the old FIBRE patch set, which had
gotten quite stale, into modern Bitcoin Core, and stood up a production network
with better monitoring and dashboards, and whatever the original one never had,
to offer this to miners as a part of some of their other work helping to
re-decentralize mining.

**Mark Erhardt**: Yeah, I want to add a couple of things.  So, my colleagues
have been working on this for the past few months.  You can think of the FIBRE
network essentially as one big node that has multiple IP addresses in different
regions, but synchronizes block and transaction data as quickly as possible
between the instances, and disseminates it to the peers it's connected to from
all of these IP addresses.  So, essentially, it's just sort of a highway to get
the blocks to all of the regions on the planet and spread it from there.  And
one other, I think, inspiration or goal here was, in the last year, we've seen a
couple of different reasons why the mempools have gotten a lot less homogenous
between different nodes on the network.  So, on the one hand, miners suddenly
started accepting low feerate transactions.  For 12 years or so, the minimum
feerate had been 1 sat/vB (satoshi per vbyte), and suddenly miners started
accepting lower feerates.  So, we had a huge spike of transactions that most
nodes didn't have in their mempools.  And we can see that in block propagation
statistics, having increased mostly, like, the time that it took for blocks to
arrive with most of the nodes, but not the 50% threshold, just a little bit on
the latter.  So, blocks were still spreading quickly, but not reaching the
entire network as quickly as before.  And the other one, of course, being people
feeling very strongly about what other users may do with the Bitcoin Network and
filtering some transactions out of their mempools.

So, blocks were just propagating a little slower than usual in 2025, which also
made people think, "Well, let's have this parallel highway where we also
propagate blocks quickly".  Matt?

**Matt Corallo**: I don't think I have anything else to add there.

**Mark Erhardt**: Maybe one more thing, currently it's in beta still, so we're
still experimenting a little bit and figuring out exactly how we let other
people connect, make inbound connections, because of course it hinges on being
able to communicate quickly between its own nodes.  And if suddenly thousands of
nodes were to connect it, that might DoS it or weigh it down.  So, it's
currently a beta and hopefully will be fully live very soon.

**Mike Schmidt**: Well, that touches on one of my questions.  From what Matt
explained, it sounds like the big boys maybe have this sort of architecture set
up, maybe not at this exact topology, but some optimizations in place.  And this
is maybe for the medium or smaller long tail set of miners.  And that leads to
my question, which is riffing off what you said, Murch, which is, is FIBRE
network going to have to support all of this long tail, or is it sufficient to
just get some nodes in some regions that would sufficiently speed up
propagation, or is everyone going to be connected on FIBRE?

**Matt Corallo**: Sadly, I think a big challenge with P2P networks generally is
you have this trade-off.  So, when we're talking about just engineering -- and I
promise I'm working towards your question -- when we're talking about just
designing the layout of the Bitcoin P2P Network, there's this kind of trade-off
between robustness and low latency.  So, you could imagine Bitcoin Core nodes
aggressively connecting to peers that had low latency, that they were close to,
to try to structure the topology of the Bitcoin Network such that it's actually
kind of geographically topographical, so you're kind of connected only to peers
that are close to you.  But this would absolutely wreck reliability, right?
That means you're only connected to peers who are close to you and no one ever
connects to peers who are far away, and then blocks never get to you to begin
with.  So, it not only has trade-offs, but it's also kind of fundamentally very,
very difficult and nigh impossible to lay out the P2P network in such a way that
it optimizes for low latency block propagation.

So, to your question, there's not really a great way to say, "Okay, well, just
one node in a region is going to get a block quickly and then other miners are
going to connect to it".  You kind of have to just say, "Look, if you're
mining, you should be able to connect to this public network in some way to get
blocks quickly", so that anyone who's mining has that kind of fair shot, without
having to spend the engineering resources to build their own relay network.  Of
course, Localhost has done a good job.  They wrote up whole documents about how
to run your own FIBRE network if you wanted to.  So, they do make it easy.  You
just kind of take the code and you get servers all around the world, and then
you've got to somehow make sure they peer with other miners.  So, they did try
to make it easy, but there's still some effort involved there in having
globally-distributed servers and getting peers with other miners, etc.

**Mark Erhardt**: Yeah.  So, for example, mining organizations could run this
themselves as well, if they wanted to.  The code is open, of course.  And one of
the ideas that we've been discussing is that we might have some border nodes.
So, the border nodes would be the things that you connect to, and then the FIBRE
nodes themselves connect to each other and the border nodes.  So, you get sort
of this one hop in between to insulate it against DoS attacks, but make the
border nodes publicly known.  But I'm not directly working on this, so take this
with a grain of salt.  I'm not speaking for the people running FIBRE directly.
Either way, the idea is just getting the blocks to more peers more quickly will
help everyone, because the more peers have the blocks quickly, the more nodes
will propagate them to others.  It's sort of like opening a second cash
register, even if the person is super-slow, will make the customers flow through
the cash registers faster, right?

**Mike Schmidt**: How do we quantify it?  What metric do we quantify?  Like, if
there's a medium- or small-sized miner that's listening and they're like, "Do I
need to get on this or not?" how would they think about what they get by being
on it or not, if they wanted to be directly peering with one of these?

**Mark Erhardt**: I mean, hopefully the FIBRE network would be the source of
bringing the block to them first very often, so they would see just marginally
faster block announcements.

**Matt Corallo**: Yeah, it should be basically free, right?  It's purely
additive.  There's just an extra connection you make in your Bitcoin node, and
if it happens to beat the P2P network, which it basically always will, great,
you'll get your blocks a little faster.  If it doesn't, shame.

**Mark Erhardt**: Maybe also to clarify, I think a lot of people misunderstand
this.  FIBRE nodes are just regular Bitcoin nodes from the perspective of other
nodes.  From the outside, they behave exactly like any other Bitcoin node.  You
wouldn't be able to tell that they're different, except internally they stream
the blocks faster by using Forward Error Correction and UDP, and then pushing
out blocks to all of their peers that elected the FIBRE node to be
high-bandwidth peers.  And the main idea is, Bitcoin Core elects nodes to be
high-bandwidth peers when they provide information early often.  Like, if you're
often the node that first announces a block, the peer will say, "Hey, would you
like to be my high-bandwidth peer and just give me the block before you even
validate it?"  This is an aspect of the compact block relay scheme.  And so, the
idea would be that the FIBRE node would be organically elected to be the
high-bandwidth peer to a lot of peers often because it has the block first, and
that way it would get to peers very quickly.

**Mike Schmidt**: Anything else listeners should know about FIBRE?  Where should
people go, other than referencing the newsletter, the Localhost blog?

**Mark Erhardt**: Yes, and I think, well, there should be a website with the
dashboard.

**Matt Corallo**: Yeah, I think bitcoinfibre.org has been updated to point to
the Localhost instance now.

_Lightning Labs releases agent tools_

**Mike Schmidt**: All right.  Well, we have another Client and service item that
I think Matt can help us with before we have him also help us with some LDK PRs.
The title of this one is, "Lightning Labs releases agent tools".  This covers
Lightning Lab's open source toolkit for AI agents to operate on the LN without
human intervention or API keys.  We mentioned the L402 protocol.  Matt, I think
you've been beating the drum on this the last few weeks as well.  What is
everyone excited about?  What's changed here?  What is L402?  How do we get the
AIs using Bitcoin?

**Matt Corallo**: Yeah, so there's a plethora of different payment protocols for
agents, right?  So, AI agents can't really directly use a credit card.  There's
a lot of fraud liability questions around who's responsible for fraud if an agent
screws up.  Obviously, LLMs today screw up quite often.  And so, who's
responsible for that, has some major questions.  As a result, Visa and MasterCard
are pushing their own agentic payments spec that is different from their
traditional credit card flows, requires more manual intervention by the human,
which limits the agentic-ness of an agent, and kind of defeats some of the
point.  So then, on the flip side, a lot of people are concluding that the
alternative of crypto is somehow better.  And so, this has basically been a story
of Bitcoin via stablecoins.  Stablecoins have large corporate backing, of
course, Coinbase, PayPal, kind of everyone has their own stablecoin now,
especially with the law change to get some clarity in the US.  Now everyone
wants to issue a stablecoin, I think we're going to see a lot more stablecoins
in the near future.  And then it's all that versus Bitcoin.

So, Bitcoin has, I think, a strong potential here as something that's neutral
and open and not tied to some corporation that could take your money from you,
that can freeze your assets.  And also, that is getting the interest and has
potential to increase fees in the future, once they're kind of the dominant
player.  But ultimately, it's all about having agents holding the same currency,
or at least being able to pay in the same currency that merchants want.  So,
it's the same classic chicken-and-egg problem that we've had with Bitcoin
payments in the past.  The only difference is this time, everyone's in the same
boat.  So, Visa and MasterCard don't have some ready-built solution for this,
merchants have to upgrade to support it.  Same with Stablecoins, same with
Bitcoin.  Everyone has the same chicken-and-egg problem.  So, this puts us kind
of on an even footing for the first time for Bitcoin payments.  And so, I think
it's really exciting that we have an even footing and that we have a real shot
here.  But there's a lot to build to get there and we have to really convince
merchants to start taking Bitcoin Lightning payments.

L402 and the myriad of other protocols, most of which support Bitcoin, certainly
not all of them, are a great start there.  And Lightning Labs has this tool, two
of them actually, L402 and the new one that Tempo did, I'm blanking on the name
of it.  I don't think it supports Lightning over x402, which is a separate
thing, some billion specs here, but it supports a few things and it's a useful
tool to be able to test these things and pay them.  I would note, I think,
agents generally, like LLMs, don't have a problem writing some code really
quickly to pay something, right?  If it tries to fetch a website and the website
returns a 402 with a text string that just says, "Pay this invoice and then
refresh the page", an agent will have no problem figuring out like, "Oh, I have
a Bitcoin wallet, let me pay it.  Okay, now I can pay it, now I can refresh the
page".  It doesn't really matter what the specific protocol is.

So, there's kind of a, I don't know how to phrase this, let's call it a Web 2.0
obsession with owning the protocol and defining the standard and the API, and
LLMs don't care.  The specific API doesn't matter anymore.  It just matters that
it's simple and readable and that you can describe it in a few sentences, so the
LLM can just write some code really quick to call it; and more importantly, that
the LLM actually has access to a Bitcoin wallet.  So, Lightning Labs has done
some cool work, but there's also moneydevkit and Alby Hub and phoenixd skills
that you can add to your agent.  And also, there's some Cashu wallets that are
agent-first that you can add to your agent.  You can give your agent access to a
Bitcoin wallet and give it some small amount of money; you don't give it all
your coins!  And then, it will have the ability to pay for things in Bitcoin.
And there's a slow but growing number of merchants who offer that.

Ryan Gentry, formerly of Lightning Labs, also launched a 402, what's it called?
The 402 Registry, I think he called it, that just lists a bunch of merchants
that accept payments, both stablecoins, but also Bitcoin, using these
standardized 402-based protocols, of which there are at least three, maybe four
now, and that agents can use to find merchants that will take stuff so that you
can just text your OpenClaw and say, "Hey, buy me some whatever", and it'll show
up at your door and you don't have to think about it, and it'll just figure
itself out.

**Mark Erhardt**: Wait, so you're saying that Bitcoin might be the native
currency of the internet?

**Matt Corallo**: I'm saying we have a shot, but we have a lot to build and a
lot of merchants to convince to integrate Bitcoin before we get there.

**Mark Erhardt**: Right.  But in this case, I think very specifically what makes
this attractive is having an agent control a Bitcoin wallet where you don't have
to interact with a bank or credentialed institution that KYC's you, and so on,
makes the setup on the agent side, I think, much more straightforward.  So,
hopefully not just an equal footing, but it makes sense for this application.

**Matt Corallo**: Yeah, entirely.  Yeah, there's all kinds of issues with why
just giving your agent your credit card number or something doesn't work.  And
again, that is why Visa and MasterCard are trying to build new things that I
think are all very short.  And so, it's really just Bitcoin via stablecoins.
And I do think actually, people see these wild claims of how many merchants take
stablecoins.  It's really not that high.  They're not used that much, especially
in the West, for more traditional commerce.  Bitcoin is actually taken by, I
would say, more merchants.  It's hard to get good numbers really.  But there are
merchants who think Bitcoin is cool and then want to take Bitcoin, and then there
are those who take stablecoins.  But no one is like, "Oh, stablecoins are
awesome.  I love stablecoins".  They're like, "The future, and I have a strong
buying with stablecoins".  It's like, "No, who cares?  They're just dollars on
tokens, right?"

So, we do have a bit of an advantage, but we have to play to it, we have to
drive it forward as quickly as we can, we have to actually get merchants to take
Bitcoin.

_LDK #4427_

**Mike Schmidt**: Awesome.  Thanks, Matt.  We want to move down to the Notable
code segment, because Matt is involved with LDK and we have two LDK PRs that he
could walk us through.  Matt, if you still have time, LDK #4427 titled, "RBF
splice funding transactions".  What's happening?

**Matt Corallo**: Yeah, so we shipped splicing in our last release, 0.2, but we
didn't actually have support for RBFing those transactions.  So, you do a
splice, basically you have all your money in a Lightning channel, you do a splice
to make an onchain payment or receive some onchain funds, you add it to your
Lightning channel, and then it doesn't confirm because you didn't pay enough
fee, and now you're stuck.  So, we finally have logic landed to support RBF.
We're still finalizing cleaning up the API and hoping to get a release out
relatively soon with support for it formally.  But yeah, it's the final piece of
the splicing logic, basically.

**Mark Erhardt**: Luckily, for the moment, the fees have been incredibly low, so
your standard fee will probably suffice.  Almost every block, fees are still
around 0.14 sats/vB to be in the next block.  So, this is forward-looking.  For
the most part, hopefully that will work out of the box right now.

**Matt Corallo**: Yeah, that's true.

_LDK #4484_

**Mike Schmidt**: And we also have LDK #4484, "Set max channel dust limit to
10,000 sats".

**Matt Corallo**: Yeah, and this is an old limit.  So, early-ish in Lightning's
history, some number of years ago, Lightning nodes didn't explicitly limit their
dust exposure.  So, this is basically, if you were to force close the channel,
how much money actually just gets burned to fees because the HTLCs (Hash Time
Locked Contracts) were too low to be onchain, or because there's some attacks
where maybe your counterparty set the fee really high because they're a miner so
they can try to claim that money; basically, money that you might lose in a
force closure that you thought you had.  And one way to limit this is nodes
fixed the HTLC dust limit to say basically, if an HTLC is over this limit, it
will appear onchain, it will be in an output, and they set that to basically the
minimum value that was non-dust onchain.

At some point, nodes realized this wasn't sufficient and started more explicitly
limiting their dust exposure.  So, when the channel gets updated, they take a
look at the commitment transaction, they say, "Okay, well if I were to force
close this, I would lose this much to fees", and they would say explicitly like,
"No, that's too high.  I'm not going to accept this update".  Now that they do
that, we have we can go back and remove the original limit, because there's no
reason for it anymore.  We can just say, "Okay, well we have the explicit
monitoring of dust exposure, so we don't have to fix the HTLC dust exposure".
And Phoenix wanted to actually deploy this, or Eclair wanted to deploy this in
production, so that they stop getting these 300-sat HTLCs that appear onchain,
which they can't really economically claim, it's not really worth it, and they'd
rather just let them disappear.  But other nodes have to stop enforcing this old
rule in order to allow them to do so.

**Mark Erhardt**: So, this is actually an increase of the limit rather than a
decrease or tighter limit?

**Matt Corallo**: Correct.  Yes, we are increasing the limit.  We didn't keep a
limit, just because it wasn't clear why anyone would want it to be too high and
you never know.  But yeah, we're substantially increasing the limit from 300 or
something to whatever it was, 1,000 or 10,000.

**Mark Erhardt**: So, sorry, you as a node operator would set this limit and
this is the sum of the amounts that you have in your channels; or is this per
single HTLC or per single channel?

**Matt Corallo**: No, this is per single HTLC.  So, you don't set this
manually, this is actually hardcoded.  And it's just, okay, technically, so your
peer sends a limit and says, "Hey, if I end up force closing, the transactions
that are built for me to force close should not include any HTLCs below this
number".  And when the channel is set up, that number is defined, each peer gets
to set their own number.  And the counterparty has to look at that number and
decide whether to accept it.  And it used to be that we would only accept a
counterparty setting exactly the bare minimum, which was 300 or whatever sats,
to make a transaction standard.  And now, we allow a counterparty to set a much
higher potential number if they want.  Obviously, they don't have to.

**Mark Erhardt**: Okay, so basically, you allowed the other party to be more
restrictive on small HTLCs than before?

**Matt Corallo**: Yes.

**Mark Erhardt**: The other party can require a larger minimum HTLC?

**Matt Corallo**: Yes, that's correct.

**Mark Erhardt**: Okay, cool.  Thank you.

**Mike Schmidt**: We referenced PR to the BOLTs repository #1301,
dust_limit_satoshis, as a relation to this PR.  I don't know if you mentioned
that, but is that true?  Is this related to that PR?

**Matt Corallo**: Yes.  That PR more explicitly updated the specs to reflect the
desire to be able to set this.

**Mike Schmidt**: Okay, Matt, thanks for joining us.  We know you have to jump,
so thanks for your time.

**Matt Corallo**: Yeah, thanks for having me.

_Bitcoin Core 31.0rc1_

**Mike Schmidt**: We'll jump to Release Candidate for Bitcoin Core 31.0rc1.  And
we didn't get into the details of what's in this release just yet.  But we do
reference a testing guide, which was authored in part by Sebastian, who's joined
us.  And maybe Sebastian can outline some of the features in this RC, as well as
how to test them.  Maybe to start, Sebastian, how did you come to be one of the
authors of this testing guide?

**Sebastian van Staa**: I took part in the BOSS Challenge this year and I got
into the final round, and I was asked to do some more contributions.  And this
was one of the things that got me started to actually write the release testing
guide, together with Jan B.  And yeah, it was one of the tasks.  It was a fun
experience for me.  I used to be on the other side of this for a long time, just
testing stuff.  And it was very, very educative and fun.  To say, I think this
is mainly educational content.  It adds a bit to the test coverage, but it's
also designed being not too hard, not too tough, to draw people into it who are
technically inclined and want to just dive a little bit deeper.  Of course, the
release doesn't rely on this alone.  This would be very bad.  We've got the
continuous integration, we've got the code reuse, but this is also like an
education.  It's one thing on top to get to know the new features, get your
hands dirty and play around with it.

The biggest change this time was, of course, the cluster mempool.  It didn't get
as much room in the release as it should have, being the major change it is.  We
are starting off very slow, so with the cluster mempool new RPC, we are, for
example, creating a parent and a child transaction.  The child transaction has a
higher feerate, so basically the child pays for parent and we check that this
ends up in one chunk.  We do the other thing, we have a more valuable parent and
a less valuable child, so that ends up in two chunks, and you get the idea.  So,
very basic tests, if the cluster mempool is actually doing what it's supposed to
do, chunking the transactions.

**Mark Erhardt**: Oh, so there's a new RPC here called get mempool cluster and
you parse a transaction, and then it will tell you about the cluster this
transaction belongs to.  Is that roughly the way it is?

**Sebastian van Staa**: Yes, yes, roughly that's the way it is.  Also, there's
another RPC for the feerate diagram, and you should get this linearized feerate,
which is very nicely explained in Pieter Wuille's slides, but it will be
difficult to explain it in this context for me in a way that people understand
it.  Let's just say you can get the feerate diagram by RPC.

**Mark Erhardt**: I can give it a shot, if you don't mind.

**Sebastian van Staa**: Thank you, yeah, go for it.

**Mark Erhardt**: So, in cluster mempool, we take all the transactions that are
related to each other and they form a cluster.  So, parents, children, and their
children and parents.  And then, we group them by the packages that we would pick
into a block template together, which we call chunks.  So, the feerate diagram
is basically a diagram over fee to weight, and it just has the points of the
chunks.  So, each chunk that will be picked into the block together forms a
point on the diagram, and that way you get sort of an overview of how much weight
and how much fee will get into the block template together from this cluster.

**Sebastian van Staa**: And the important part here that it's linearized, so
it's ordered.  So, you've got to choose your targets first, and when you fill
your block, you start with those.  And I think that's a very big thing, the
linearization of the cluster.  It's algorithmically difficult.  And so, the
feerate diagram seems to be a graph which is rising to the right, yeah.

**Mark Erhardt**: Yeah, I should correct myself.  This is not on one cluster,
this is on the entire mempool.  And this is getmempoolfeeratediagram, judging
from your testing guide, I'm just reading that on the side here!

**Sebastian van Staa**: Okay!  And we also have one test where a chain of
transactions is created of 64, and we check that this ends up in one cluster,
which is the new cluster limit.  And we check that a chain of 65 transactions
with a child-parent relation do not end up in one anymore.  So, that's the new
cluster limit at 65 transactions.

**Mark Erhardt**: Right.  That replaces the former limit on descendants or
ancestors.  We just have a cluster limit now.  So, instead of just going
downward or upward, just the entire group, the cluster is viewed and limited
together.

**Sebastian van Staa**: Yes.  Yeah, exactly.  I think the cluster before was a
lot smaller, I think it was 15 or was it 25?

**Mark Erhardt**: 25, yeah.  25 ancestors and 25 descendants, which because some
descendants of ancestors could be different than your own, could mean that
clusters were actually not limited in size.  Clara and I did some
block-template-building research a few years ago, and we found some clusters
that had over 1,400 transactions.

**Sebastian van Staa**: Wow!  That's big.  Okay, let's continue on the list
with another big change.  Not as big, but still notable.  It's the private
broadcast by Vasil Dimov.  He's been fighting for this for a long time.  The
idea here is that you can make sure a new transaction gets sent out over Tor or
I2P, which means private.  And we also have a small test for this.  It would
have been nicer to really test it, but on regtest, most of this runs, we don't
have Tor support.  So, we can just check that it fails to use this flag on
regtest.  We thought about cooking up a bigger test case on testnet4 with Tor
and stuff, but we kind of decided against it.  But if anyone is interested, you
should definitely set that up and check that this transaction gets sent out.  If
he has Tor and this flag, and if he has Tor turned off with that flag, it's
going to fail.

So, what else have we got?  A small one.  We've got the getblock RPC was
updated, so the coinbase_tx field was extended a bit.  Now we have one more
field, which is actually the coinbase, very small change.

**Mark Erhardt**: Yeah, I think the main difference here is that the coinbase
used to only be provided at verbosity level 3, which provided all of the
transactions.  But now, with work on BIP54, the consensus cleanup, people are
more interested in the content of the coinbase transaction, because they wanted
to see whether a coinbase transaction set the locktime, as proposed by BIP54,
which would make them forward-compatible to BIP54 activating.  This is a fix to
ensure that coinbase transactions are unique.  And so, the coinbase transaction
is now provided at verbosity level 1 and 2 as well.  I thought it was only 2.  I
might be mistaken here.  So, at level 3 is everything, and level 2 already
provides the coinbase transaction, and according to your testing guide, also on
level 1.  Yes, okay, you are correct.  So, anyway, you'll see the whole
coinbase transaction in getblock now.

**Sebastian van Staa**: Yes, excellent.  Thank you for clearing that up.  We've
got one more thing, the txospenderindex, which is a new feature as well, one
more index now.  It basically serves an RPC and it gives you back the TXO that
gets spent.  This is especially useful for L2 implementations.  We saw that I
think it used to fail if it wasn't in the mempool, and now it can be looked up
in the index, and we've got some examples of that.

**Mark Erhardt**: Right.  So, it's super-easy for a transaction to know where
the parent came from, because of course in the input, we define the outpoint of
the UTXO we're spending, which is the txid and the vout vector.  So, we always
know what transaction created an input.  But on the other side, it's very
difficult.  From the transaction that created an output, we have a hard time
telling which transaction spent that output later, because that's of course not
information that is available at the time that the output is created.  And
previously, that was not tracked.  So, transactions like LN transactions, that
are invested in tracking the channel anchors and seeing where they get spent,
they are very interested in being able to track where specific UTXOs are spent.
Or also, if you want to do a light wallet that is, for example, Electrum-based
or so, that is an interesting index to be able to jump from the transaction that
created an output to the one that spends it, which was previously much harder.

So, there's an optional index that Bitcoin Core will start having, if you turn
it on, and might make it easier to build Electrum-like software on top of
Bitcoin Core, or to support Lightning as the backend better.

**Sebastian van Staa**: Yes, correct.  Exactly.  We've got one more thing, the
dbcache.  We've got the -dbcache setting, which is the coin's cache.  It used to
be at 450 MB standard.  So, now the standard or default value has been increased
to 1,024.  It's quite a very simple test to check for that line on node startup,
how much cache was allocated.  If you don't set the flag, it will be 1,024
altogether.  This can be seen in the testing guide.

**Mark Erhardt**: Well, so just the dbcache is just keeping the UTXOs in cache
and the latest created and the ones that were spent by transaction in the
mempool are in this cache.  And so, 450 had been the default for, I don't know,
ten years or so, and I think computers just generally got a little more powerful
in average since then.  So, we've increased the default here.  This helps
especially during IBD (Initial Block Download), but is useful also while nodes
are running.  This will only be increased on nodes that have a minimum of 4 GB,
and it will only be increased on architectures with 64 bits, because 32-bit
architectures generally cannot access more than 4 GB of RAM.  So, in these
32-bit architectures, the limit will still be 450 by default, and only on
machines that have more than 4 GB and are 64-bit architecture, it'll be
increased by default.

**Sebastian van Staa**: Yes, exactly.  Thanks for the details.  I think I was
just booted, but you didn't really notice, I'm back now.  But I think I got most
of your explanation about the 32 and 64-bit systems, which seems entirely
correct.

Next point, a bigger change.  We've got the ASMap, or whatever you pronounce it.
I think, I'm not really sure, I'm going to call it ASMap.  So, this is the
first time -- so AS was, dang, I forgot again, what was it again?

**Mark Erhardt**: Autonomous systems.

**Sebastian van Staa**: Autonomous systems, that was it, yeah, exactly.  So,
it's basically mapping out the internet to make sure that the nodes get a very
diverse range of partners.  So, it makes it more resistant to Sybil attacks, it
even more difficult to Sybil a node if it really chooses its coordinates from
all over the internet.  So, this used to be experimental.  This is the first
time the ASMap is actually baked into the binary.  We did a collaborative testing
run two weeks ago, where ten people ran a client that would try to map this out,
which is, the whole thing is very volatile.  Even if you have ten people start at
the same Unix time, you will have maybe four or five people agreeing, so you can
basically hash some data and compare the hashes.  The process is now, I think, if
five people agree, this is going to be the valid solution, it's going to end up
baked in the binary.

So, before, the -asmap flag would look for a particular file on the disk and
just fail silently if it goes there.  And now, if you set the -asmap flag, it
will just take the data baked into the binary.  And I think Murch wants to give
some more detail how this works.

**Mark Erhardt**: Right.  I wanted to tie this back briefly to the FIBRE point
earlier.  So, the autonomous systems are sort of the regions of the internet
rather than, well, there's the IP ranges and then on top of the IP ranges,
there's the autonomous systems.  So, for example, Google will have multiple
different IP ranges and an autonomous system map will show that all of those IPs
belong to the same autonomous system.  And Bitcoin Core uses this autonomous
system map to make sure that it connects to a wide variety of autonomous systems
to get its peers.  And this sort of counteracts having low latency, because if
you connect to an autonomous system in Germany and one in the US and one in
China and generally try to distribute this as widely as possible, some of the
peer connections that you have will be very quick, because they're close to your
own internet region where you have a low latency, but a lot of the other ones
are going to be distributed all over the planet and might have a round trip time
of 150 milliseconds or 200 milliseconds.

So, in a way we make ourselves very well protected against Sybil attacks,
because we will not be connected to peers in one data center at the same time,
but it makes us slower in latency to receive blocks, and so forth.  So, the
ASMap is basically a snapshot of the internet topology at the time that it is
created, but it decays somewhat quickly, because autonomous systems keep
announcing, "Oh, this IP is now mine", or, "To route to that internet region,
you should go through me now instead of someone else".  So, over time, these
ASMaps get less accurate.  So, we will provide new ones roughly, probably on
every release, we're going to provide a new snapshot.  They do decay a little
bit, but I think some people estimated about 1% per week or so, or no, that
would be too quick.  Anyway, I don't remember the exact details.  But these maps
are good and in the broader picture, tend to stay somewhat correct for half a
year, a year, but they need to be refreshed quickly to the point that when you
take that snapshot, even if ten nodes, as Sebastian said, start at the same
time, only five of them will get exactly the same ASMap at the same time.

**Mike Schmidt**: And we had Fabian on in Podcast #394, where we covered one of
the PRs associated with this.  And he walked through cartograph and the process
of creating this file.  And so, if you're curious about some of the processes
and the networking involved there, jump back to that one.  Back to you,
Sebastian.

**Sebastian van Staa**: Yes.  One last point.  There's a new REST API endpoint,
which is called blockpart.  So, you can actually request parts of a block by
giving the blockhash the starting offset and the size in bytes that will be
handed back, which is also tested in the testing thing.

**Mark Erhardt**: Do you remember what the context is in which this was
proposed?

**Sebastian van Staa**: Actually, I was just trying to remember, but I don't.
I'm just going to open the PR and see what the context was.

**Mike Schmidt**: I will stall for a second while you look into that.  This is
the caveat that Murch and I like to add when we do these testing guides and RC
testing.  This is sort of the caveat, and I think Sebastian sort of referenced
this already, which is this is not comprehensive.  This is just an idea to get
your feet wet on some of these pieces of what is new.  Obviously, everybody uses
Bitcoin Core a little bit differently.  If you use this RC in the way that you
normally use it, and then report any issues you see, you may see things that are
different or that aren't even covered in this.  And so, you don't have to
strictly just follow this.  Yeah, Murch?

**Mark Erhardt**: I think, yeah, Sebastian, go ahead.

**Sebastian van Staa**: I just looked it up.  I mean, as always, the idea is to
save time and bandwidth.  So, indexes like Electrs, they often have to look up
the whole block or they have to use a method to get a certain index, like an RPC
method.  And just grabbing the bytes directly out of the block data is a lot
faster.  So, that's the thing.

**Mark Erhardt**: Right.  So, this PR was opened by, I think, a person involved
in Electrs.  And the main issue here is if you are getting a transaction, even
if you have a txindex on Bitcoin Core, it sort of has to go to the right block
file, then look up the offset from the start of the block, read out the
transaction data and provide it.  And if you're consuming large parts of the
blockchain with a secondary software for which the Bitcoin Core node is just the
backend, you might want to consume whole blocks or chunks of blocks.  That seems
to be the context.

**Sebastian van Staa**: Yes, exactly.  And that was the last point in the
testing guide for today.

**Mark Erhardt**: Maybe just a call to action here would be if you're interested
in getting your feet wet, like Sebastian said, you can go through the testing
guide.  It walks you through playing around with some of the new features and
updates.  But also, this could be your next release.  You could write the
testing guide if you get involved in Bitcoin development, or you could help do
Guix builds, where you just follow the instructions how to build the code from
scratch in Guix.  Or, you could help create the next ASMap.

**Sebastian van Staa**: Yes, and also, I almost forgot, there will be a PR
Review Club on this on 8 April.  So, usually, PR review means PR review, but
this time, we're just going through this release guide again together.  I will
answer questions, so please, if I got you interested, show up to the PR Review
Club on 8 April.

**Mike Schmidt**: Awesome.  So, test the RC, jump into the PR Review Club,
anything else before we wrap this one up, any other calls to action?  All right.
Sebastian, thanks for putting this together, and thanks for joining us to walk
us through it.

**Sebastian van Staa**: Thanks for having me.  Cheers.

_BIPs #1974_

**Mike Schmidt**: We're going to jump deep into the notable code segment and
talk about a PR to the BIP repository #1974.  This includes BIP446 and 448.  We
have OP_TEMPLATEHASH.  We have TRT.  Is that what we're calling this?  TRT?
TNRT?  THash?

**Greg Sanders**: TRT is Testosterone Replacement Therapy, right?!  We really
struggled to find a good acronym that wasn't begging the question, you know.

**Mark Erhardt**: All right.  Tell us a little bit about Taproot-native
(Re)bindable Transactions, and TEMPLATEHASH, please.

**Greg Sanders**: Sure.  So, these ideas are not new.  Prior efforts were done.
So, one example, is it still not good?  Unfortunately, I can't change my mic
while recording.  For some reason, the software doesn't let me.

**Mike Schmidt**: I can hit buttons.  It'll be louder in production.

**Greg Sanders**: I'll try talking closer.  So, there's been these ideas for
years where if you can commit to the next transaction in script, so you know
what you want your next transaction to be, you can take a hash of that
transaction, stick it in a script output, and then the money can only be spent a
certain way, right?  So, there are a bunch of use cases for this, but over time,
there actually ended up being more use cases for this.  So, a classic use case
here would be for Ark, which is before users are possibly even online, you have
this coordinator build a tree of transactions that pays out users.  They seed
this tree and then users come online and do a little song and dance to get their
copy of it.  And this allows, on the average case, for the block space usage to
be constant, while the number of users be growing.  So, the vbytes usage does
not grow linearly with users.  So, that's kind of one of the key things.  So,
there's also the other use case, where if you know after the fact what you want
to commit to, you can do that as well with counterparties.  So, there's, "We
want to bind the next transaction either before or after the fact" based on the
use case, and this is where this proposal comes in.

So, the first BIP, BIP446, is the TEMPLATEHASH, which is a kind of a
taprootification, I'd say, of CTV (CHECKTEMPLATEVERIFY).  It's aimed at the
exact same use case as CTV.  And then, it's bound up together with the CSFS
(CHECKSIGFROMSTACK) proposal, which I don't have in front of me, BIP348.  And
then, as an extra bonus, INTERNALKEY, BIP349.  So, the key ones here are #446
and #348.  Those are kind of the one-two punch of functionality that is being
offered.  And #349 is a simple cleanup, which reduces the kind of vbytes penalty
when you do scriptpaths.  Since you already have the internal key in your
control block, you don't have to pay for it twice in vbyte space.  So, that's
kind of it.  That is the high level pitch.  I'll pause for a second.

**Mark Erhardt**: Right.  So, INTERNALKEY basically just gives you the internal
key from the control block again.

**Greg Sanders**: Yeah, exactly.

**Mark Erhardt**: It allows it to be pushed on the stack so you can consume it,
in order to do a CSFS.

**Greg Sanders**: Yeah.  So, from that, you could do something like an L2-style
channel, where counterparties agree to the next version of the transaction using
TEMPLATEHASH.  They both sign it.

**Mark Erhardt**: L2 here standing for LN-Symmetry, just to be clear.

**Greg Sanders**: Sorry, LN-Symmetry, yeah.

**Mark Erhardt**: Because L2 sounds just like eltoo.

**Greg Sanders**: Yeah.  And then, the counterparties agree on the next state
and both sign it.  Then, they combine their signatures and then put it on the
stack and use BIP348, CSFS.  That validates the next state transition.  An
internal key can be reusing the same exact key, because they already agreed to
the inner key.  So, these three together, that's the common kind of operation.

**Mark Erhardt**: So, to look at it from the outside a little bit, if this
proposal, or these proposals, would be adopted in a soft fork, we could probably
do LN-Symmetry style channels, which we've been talking about for, I don't
know, seven years, probably longer.  And then, we could also do all of the use
cases that had been proposed with CTV, except the ones that rely on legacy
script being able to use CTV.  So, this is taproot-only opcode rather than CTV
proposed to activate it both on legacy script and on taproot.  And there's a
couple of minor details that are different too.  But as far as I understand, this
would basically give access to all of the use cases that have been discussed in
the context of CTV.  And so, how did this come to pass?

**Greg Sanders**: So, I had long been somewhat ambivalent about CTV as an idea
just because the use cases didn't seem there.  But I became more convinced as I
understood how Ark worked, and became more convinced of the ability for it to
reduce the requirement of interactivity in these protocols.  So, instead of
needing all feature participants on ahead of time, we were able to defer that to
much later.  And in a mobile-first kind of world, this makes a lot of sense.
So, I started digging into this, being more convinced of it.  I also did work on
LN-Symmetry, as you know.  So, that was a slot-in replacement for APO
(ANYPREVOUT).  I did swap it out in my in my proof-of-concept codebase; it works
just fine.  So, it's just a conceptual drop-in for that.

I was talking to Antoine at Chaincode and basically he wanted to be convinced
that there was something there.  He wasn't.  And over time, he was convinced of
it.  So, we joined up along with Steven Roose, who works at Second Tech, to work
on, well, the CTV proposal hadn't changed in like five years, and we felt that
being unchanging isn't necessarily a sign of health one way or another.  So, we
kind of went back to the drawing board and said, "How would you do it with
modern-day tooling, with taproot?  How would we justify the change?  How do we
bundle it or not?" and went through all these steps, justified every field that
we hash from first principles, or attempted to, and then basically gave what we
felt was the best effort proposal.  And so, there's been a moderate amount of
communication about it on the gist of the GitHub.  But also, I mean it's mostly
just differences in the hash, right?  So, there's discussion about annex and
stuff like that, but that's not really the important part yet.

So, that's the BIP portion of it, and it's got merged.  Thanks for all your back
and forth with us, Murch, and I'll talk a little bit about next steps, but I'll
pause there.

**Mike Schmidt**: Yeah, that's where I was going too, is next steps.  Maybe
feedback that you've gotten that you think is notable for the audience.  Can
people play with this yet?  Inquisition?  These sorts of things.

**Greg Sanders**: Right.  So, our first thing we did, we designed this, put this
in draft.  And then we said, first of all, is this a good place to stop?
Because Bitcoin Script is very basic at today, very limited.  And maybe there's
a better place to stop, so it should be going further.  So, one example is
Steven Roose's other proposal, OP_TXHASH, I don't know the number of that one
off the top of my head, which is like a programmatic version of CTV.  So, you
can basically parse in arguments to this hash and it hashes in all the
transaction data that you asked for pretty much.  So, it's kind of a
programmatic version.  So, why not go that far?  Why not go all the way to
Rusty's great script restoration?  Why not do, like, AJ's bllsh, Russell
O'Connor's Simplicity?  And so basically, tried to justify to ourselves and to
others in public forum that we think this is a good set of functionality that
has no known steep downsides, except for the fact that you have to go scrimp and
beg for a soft fork, right?

**Mark Erhardt**: Yeah, maybe let me jump in here and give you my antagonistic
view here.  So, every week we get a new covenant proposal.  We have OP_TXHASH,
BIP346; we have CCV (CHECKCONTRACTVERIFY); we have CTV, of course; we have
LNHANCE, which packages CTV together with PAIRCOMMIT and INTERNALKEY and CSFS.
What is your sales pitch or, yeah, I forgot even some
TAPLEAF_UPDATE_VERIFY, and so forth.  Why is this, in your opinion, the way to
go forward, with the context of all of these other proposals before?

**Greg Sanders**: So, it's a multidimensional kind of thing.  Unfortunately,
it's hard to bumper-sticker this.  But I would say Bitcoin Script is really
weird, really flawed.  And so, in my opinion, we either do small, as principled
as possible, scoped things in Bitcoin Script to really enhance use cases we
truly understand could work today; or we probably should think about going all
the way and throwing out script.  And by throwing out script, I mean, great
script restoration, Simplicity, bllsh, something like that, where we say, "You
know what?  Let's start kind of from scratch.  How would we want to build them
from scratch?"  And that's one dimension, right?  The other dimension is what
has been proven to be useful.  I guess it's part of that dimension.  And I think
presigned transactions is pretty straightforward.  We understand how those work,
we do those kind of everywhere, it supports payments of various kinds.

One kind of hopefully killer use case that I've been focusing on lately is
composing the LN with Ark itself.  I'm not going to get into all of that.  I've
started work on it, I have an end-to-end working demo with full functionality.
But the point is, it's using the same kind of mental model we already have in
Bitcoin.  And future capabilities, for the most part, the only one that I've
really seen that's very compelling is trying to get zero-knowledge proofs in
Bitcoin.  And that is one other functionality that's very orthogonal to this,
right?  And then, it also begs all these questions of, how exactly do you want
to do these things?  So, I think that's one attempt at explaining.  So, I don't
want to go down a laundry list why I like or don't like certain things.  LNHANCE
is very close to this.  That's basically functionally equivalent.  CCV has very
interesting ideas.  I'm not sure that we keep trying to extend Bitcoin Script
like that.  It seems principled in some ways and unprincipled in others.  I'm
not going to get too far into this, but I think it's a function of like, we
don't know what Bitcoin Script should be in some ways, I would say.

**Mark Erhardt**: So, maybe one of the things that I've seen on the mailing
list recently was that you are building demos.  I saw Antoine work on that, you
work on that.  Of course, Steven is involved in building one of the Ark
implementations.  So, you very specifically show, in the use cases that you
already have, how this would be useful.  And you have working demos that you can
show to people.

**Greg Sanders**: So, I can give a little more detail.  So, I have LDK channels
working on top of Steven's Ark software stack.  The one caveat here is that if
you want to be a mobile user, you won't be able to sign that new tree when
you're batching channels together.  It's just kind of infeasible on mobile.  And
so, TEMPLATEHASH, this kind of next transaction commitment scheme, slots in
there basically transparently to the user.

**Mark Erhardt**: Basically, the issue here is that mobile phones fail at the
interactivity requirement, right?  They are only intermittently online, they
cannot be reliably woken up.  So, being able to have these ways of committing to
things out of order or on your own time allows you to participate in these
constructions.

**Greg Sanders**: There's been testing on this.  Even if they're online, it's a
lot of signatures floating around.  And if you have one user out of a hundred
accidentally drop a packet or something, everyone has to start over again.  So,
this is very punishing versus just saying, "Hey, I'm the coordinator, I made
this for you.  Do a couple signatures with me and you're good to go", which is
night and day difference.  So, yeah, for next, it's we're thinking on proof of
concepts.  And I'm working hard on this side of thing because it's also useful
outside of TEMPLATEHASH, but also would benefit greatly from it.  We've got a
list of other ideas.  And I'd say the call to action is, if you have interest in
working on these things, proof of concepts, interested in understanding more
about what this enables, that you can reach out to us either on GitHub or email
or Delving.

**Mike Schmidt**: I was just going to plug, we had a previous episode that
Antoine came on, when we talked about the different tooling and PSBT and
miniscript around this bundle as well, so if people are curious about that.  And
so, it's more than just writing a bit.  There's infra and support tooling that
is advantageous to have the work put in initially.  So, if folks want a
reference back to that, check out the podcast page, look for Antoine.

**Greg Sanders**: We also have an open PR on Bitcoin Inquisition.  Now that we
have a BIP number, it's easier to get the PR up in shape.  And so, once we have
that up, we can run simultaneous signet infrastructures.  People can actually
play around with, like, Lightning on Ark, and things like that, and with fake
money on a realistic test network.  So, that's kind of another big milestone we
want to hit soon.

**Mark Erhardt**: All right, that was going to be my next question.  So, I think
you got me covered.

**Greg Sanders**: Yeah, it's all open source.  It's easy to stand up, which is
nice, unlike some other competing systems.

**Mike Schmidt**: Greg, thanks for your time.  Thanks for hanging on and walking
us through this and for your work on this.  We appreciate your time.

**Greg Sanders**: My pleasure.  Thanks.

_Cake Wallet adds Lightning support_

**Mike Schmidt**: Cheers.  We're going to jump back up to the Changes to
services and client software segment and jump into the first item, which is Cake
Wallet adding lightning support.  Cake Wallet, I believe it's a mobile only
wallet, but they announced Lightning support using the Breez SDK and also a
Spark integration.  We've talked about Spark before briefly, but it's a
statechain type, I guess, side system.  And Cake also has Lightning addresses.
And I know there was some discussion and debate online about Spark and the
trustless nature or not of it.  You're free to dig into that yourselves.  I
don't know if, Murch, you want to resurrect any of that discussion here.

**Mark Erhardt**: I mean, I think I can explain a little bit what a statechain
is, maybe.

**Mike Schmidt**: Excellent, yeah.

**Mark Erhardt**: So, in the LN, you have locked up funds between two parties
and you renegotiate how it will be paid out.  And that enables you to have very
quick settled transactions between the two peers.  And by having more peers, you
get a network and can forward payments, right?  In the statechain, you have a
coin, a fixed amount that is locked up with an operator.  So, there's a central
party to a statechain.  And then, the user and the operator together own a fixed
UTXO, and you hand off control of the UTXO to other users of the same
statechain by re-splitting the key and giving one shard to the new owner and the
operator holding the other shard.  So, this is similarly quick as the LN in that
you only have to renegotiate between the participants of the transaction.  You
can immediately pay any other person on the internet, rather than any other
participant of the LN, because they get access to this UTXO, so they don't have
to set anything up in advance.  So, that's a big advantage.

The trade-off is that the operator and any former owner of the same UTXO can
cheat by going back in time and spending it with the two shards.  So, you are
trusting that the operator is properly deleting the old shards after control has
been handed over to a new owner of the UTXO.  Either the operator or the old
owner has to reliably remove the shard, or you have to trust them not to cheat,
or just switch out of it after you hold it through Lightning, or whatever.  So,
you get very quick payments, you don't have the onboarding hurdle that you have
with LN, but you have a bit more trust in the operator of the statechain at that
point.

**Mike Schmidt**: And, Murch, we had BlueMatt on and I think he was the one that
outlined this idea to me quite a while ago, but this idea of a graduated wallet,
where it's sort of this end-user facing wallet.  You know, maybe you have an
onchain balance and a Lightning balance.  And then, for small amounts, maybe you
use ecash or maybe you use Spark, or something like that, where the trust
assumption is a little bit different.  And as you build that balance, then maybe
you move to Lightning and/or onchain Bitcoin as well.  And I think that's a bit
of what Cake is doing, and that's what seems to be a strong use case for Spark
as well.

**Mark Erhardt**: I think that's generally the big theme in the ecosystem right
now.  Essentially, all of the things we've talked about I think today, well, not
FIBRE, but Ark and statechains and another one that we'll talk about with the
Liquid Blockstream in a couple of points, all of these are trading off a
slightly different trust model for more convenience or different convenience for
the payment flow.  And yes, I think that we're getting very quickly to the point
where we can make Lightning payments feel transparent to the end user from the
mobile phone, where it just works.  It happens instantly, people are satisfied
that the payment is sufficiently settled.  And then, under the hood, you might
have swapped a little bit of money into a statechain, or it flows for an Ark,
or you use ecash tokens or you use the submarine swaps to LBTC.  From your
point of view, the majority of your coins are in Lightning.  The vast majority
of your coins are in a cold wallet, on a hardware wallet, or air-gapped system,
or however you have that set up.  And your pocket money is in a semi-trusted but
super-convenient cheap way, like ecash or statechains cost nothing basically to
transfer, whereas even Lightning payments have fees.  And with the onchain fees
being so low, Lightning payments have actually, at some point, for many amounts,
been more expensive than onchain payments.  But they're instant, so that is the
advantage there.

So, anyway, that seems to be an ecosystem theme in the last couple of years or
so.  And all of these big system upgrades or these big projects have been taking
a long time, and now they're coming to fruition, and they allow people to build
more convenient, more usable end-user wallets.  So, Cake, I think, is very good
at just taking what works and being very conscious of the user experience and I
think that's the main point of their blog post, if you dig into it a little bit,
is yes, Lightning is cool and it works, but when your channel closes down, you
have fees; and the setup and so on makes it less usable for an end user.
Whereas the way they found now, they could integrate and make payments to the LN
through Spark.  It works for the end user.  You probably want to limit your
exposure to the trust assumptions to whatever you feel comfortable with, but
this is pretty cool.  Also, you might have heard Cake Wallet in the context of
supporting silent payments already.  So, a little shout out to them in that
regard too.

_Sparrow 2.4.0 and 2.4.2 released_

**Mike Schmidt**: Next piece of software that we highlighted was Sparrow.  And we
have two releases from Sparrow that came out that we wanted to highlight things
from.  One was in 2.4.0, Sparrow added BIP375 PSBT fields to verify DLEQ proofs
for hardware wallet support when sending to silent payment addresses.  It also,
in that 2.4.0, added Codex32 importer functionality.  And then, Sparrow 2.4.2
added v3 transaction support, specifically noted as support for loading v3
transactions in the transaction editor.  There's a list of other things in each
of these releases in addition to whatever was in 2.4.1, so if you're a Sparrow
user or these things are interesting to you, obviously jump into those release
notes for more.

**Mark Erhardt**: Yeah, so I also see a bunch of new hardware wallets that are
now supported by Sparrow in the 2.4.0 release.  And I wanted to give a shout out
to Craig.  He's been on the show recently.  But also, he's been not only
implementing a bunch of BIPs to support them with Sparrow, he has been driving a
bunch of BIPs lately in order to drive forward the PSBT format of silent
payment.  Sorry, he's been helping on using the silent payments in PSBT and he's
been driving the descriptor format for silent payments.  And he's been working on
an annotation for descriptors to add, to make a format that uses descriptors
more usable to use as a backup.  So, we have two or three BIPs now from Craig in
flight, and he's been also just implementing a bunch of them.  So, this is
pretty cool.  We BIP editors always love when people contribute to the BIPs
repository, not only as authors, but reviewing other BIPs, and he's been doing a
great job helping a few other BIPs in related topics get more review.

_Blockstream Jade adds Lightning via Liquid_

**Mike Schmidt**: Blockstream Jade adds Lightning via Liquid.  So, there's a few
different moving pieces here.  So, Blockstream has its Jade hardware signing
device.  There's also the Liquid sidechain and then there's Lightning.  There's
also the Green app, which is sort of the app how you can interact with your Jade
hardware wallet.  And then, so I guess the top-line feature here is if you're
using all of these pieces, you can actually interact with Lightning using
submarine swaps, and that will actually convert Lightning payments into Liquid
Bitcoin, so LBTC on the Liquid sidechain, and it allows you to keep your keys
offline during that process.  Go ahead, Murch.

**Mark Erhardt**: Yeah, so I read a little bit of this on the train earlier
today.  The idea here is, as a mobile wallet user, receiving Lightning payments
is complicated.  There is various solutions that are in flight.  For example,
LDK uses the asynchronous payments and has been driving that largely.  It looks
like Core Lightning (CLN) has found an in-house solution for that.  Instead of
requiring the mobile wallet to be online, you receive it as an LBTC payment to
the Liquid sidechain.  So, the Lightning payment comes in, gets swapped by Boltz
to an LBTC payment, and then you hold some LBTC, which is Blockstream's token,
like voucher for Bitcoin, and you can swap that easily for actual Bitcoin of
course.  So, if you hold a little bit of your balance in LBTC, again, just like
we said, your pocket money or smaller amount or however you feel comfortable
about it, you can make Lightning payments from a basically onchain wallet by
swapping through LBTC to the LN.

_Tether launches MiningOS_

**Mike Schmidt**: Tether launches MiningOS.  So, Tether, yes, that Tether
launched this open-source operating system for managing Bitcoin mining
operations, and it is under the Apache 2.0 license.  I believe it's agnostic to
whatever sort of hardware you're running, and so I think we covered something
similar from Block.  They had a series of things as well under, I think, the
Proto banner, but I think this is largely a welcomed thing in the mining
ecosystem.

**Mark Erhardt**: Yeah, the big issue is that most of the mining control
software, as in the pool software that runs the actual mining hardware, is
closed source, right?  So, every mining pool invents the wheel fresh.  It takes
time for them to support new features on the network, maybe to start including
new transaction types on their mining pool.  With now two different systems that
make this open source, it becomes much easier for the ecosystem to update
quickly.  People can just come and contribute to the open-source software, well,
assuming they take external contributions, but I would hope so.  And so,
features roll maybe out more quickly and maybe mining pools are up to date to
the network reality a little quicker.  Maybe less work has to be done on the
mining pool side, making it easier for new mining pools to enter the fray and
compete.  So, yes, this is very welcome.  I haven't looked too much into the
details here, but this is the general context.

_TUI for Bitcoin Core released_

**Mike Schmidt**: And we have a TUI for Bitcoin Core that was released, a
Terminal User Interface for Bitcoin Core.  So, if you want to interact in your
terminal and feel very cypherpunk and have that sort of vibe to your
interactions with the Bitcoin Core node, this connects to your Bitcoin Core node
using the JSON RPC, and it pulls in a bunch of different information, metrics
about the blockchain and network, looking at the mempool.  And then, I guess
there's transaction search and you can broadcast and manage your peers there as
well.  It's kind of fun.  I haven't tried it myself, but the screenshots look
kind of cool.  I think many people are spending maybe a little bit more time in
the terminal than they have previously doing things with Claude and whatnot.
And so, if that's your jam, then maybe check out Bitcoin-tui.

That wraps up our Changes to services and client software.  We touched on a
Release item and some Notable code items, but we also have Gustavo to take us
across the finish line.  Gustavo, what haven't we done from releases?  We have
BTCPay Server 2.3.6.  You want to pick up there?

_BTCPay Server 2.3.6_

**Gustavo Flores Echaiz**: Yes, thank you, Mike and Murch.  Yeah, so we have
alongside Bitcoin Core 31.0rc1, we have a BTCPay Server with a minor release.
This has some API and wallets features.  For example, the get invoices endpoint
now retrieves all the payment method data for specific invoices.  So, you don't
have to make multiple calls.  You can just retrieve payment data with one single
API endpoint call.  Another one is allowing filtering of when labels exceed more
than 20, you can basically just filter labels when searching for your wallets.
So, nothing crazy but just a few improvements on the user experience, and a
couple other bug fixes as well.  So, minor release for those that are using
BTCPay Server, not a huge revolutionary change.

_Bitcoin Core #31560_

What's interesting about this week's notable code and documentation changes are
two changes to Bitcoin Core.  First, we have Bitcoin Core #31560, where the
dumptxoutset RPC, which is used to dump the UTXO set to disk, can instead of
being written to disk and then being read by another program, it's now enabled
to be written to a named pipe.  This means that the output can be streamed
directly into another process, bypassing the need to write it to disk and then
reading it again by another program.  So, the use case here presented was mostly
enabling to create, let's say, a SQLite database of the UTXO set, combining
with another tool called utxo_to_sqlite.py, that was introduced in Newsletter
#342.  So, with one simple command, users can use the UTXO set for other use
cases and, for example, build a database directly from that command.

As a reminder, dumptxoutset is used to create assumeUTXO snapshots, so that use
case was always previously covered.  But this makes it useful for external
tooling to convert it to other formats, and not waste time and processing power
into writing it to disk and then reading it again.  It can just be done in one
command.

_Bitcoin Core #31774_

The next one, Bitcoin Core #31774, is a security improvement when you're using a
password to secure your wallet.  The key material was wiped out of memory using a
method called memset, that sometimes could be optimized out by the compiler,
meaning it was removed from the final compiled code.  So, this meant that your
key material could be swapped to disk or linger in memory.  So, for example, it
would be swapped to disk when your system is running low on memory, it could be
swapped to disk.  However, now the new change is that the key material is now
protected using secure_allocator to prevent it from being swapped to disk and to
zero it from memory when it's no longer used.  So, in the PR, you can find an
issue that was associated to it, where someone basically told the story of how
this wasn't being securely erased from memory because it was using memset, and
how memset can be optimized out by the compiler at some points.  So, this is
changed to make sure that it's securely erased from memory and never swapped to
disk.  Any extra thoughts, Murch, Mike, here?  No, perfect.

_Core Lightning #8817_

So, the next one is Core Lightning #8817.  So, here, there's a couple fixes that
are included into CLN to make it interoperable fully with Eclair.  So, I believe
as of today, the splicing PR has been merged.  So, this was obviously in
preparation towards merging the BOLT specification splicing PR.  There was fixes
made in multiple implementations to arrive to an interoperable point and to
fully reflect that the implementation is fully implementing the protocol as
defined by the splicing spec PR.  So, what are those issues that have been
fixed?  The first one is announcement signature retransmission crash.  So, if
Eclair missed a signature from CLN and asked for it again when it reconnects,
CLN would send it correctly the first time.  However, if Eclair asked for it a
second time, then CLN would send an error and force close the channel.  So,
those type of issues were happening.  Another one is where Eclair would send a
channel_ready message at a point where CLN didn't expect it, and this would
cause CLN to reject it with an error about getting an incorrect message.  And
there was also some other crash and misalignment on different issues.

Then, what's interesting about this PR is that the maintainer from the Eclair
team, t-bast, created custom branches that deliberately misbehaved so that you
would test how CLN would react if Eclair would misbehave.  So, this was a good
stress test that allowed this PR to finally, for the third time, to achieve
interoperability with Eclair.  You can see Newsletters #331 for the first time
CLN had achieved interoperability, and #355 for the second time.  It's just that
Eclair kept updating to the changes in the specification more frequently than
CLN did, which is why CLN had to update to then maintain its own
interoperability with Eclair.

_Eclair #3265 and LDK #4324_

So, the fourth item we have in this list is a combination of two PRs, one in
Eclair #3265 and one in LDK #4324, where both implement what we covered in past
Newsletter #396, which was a change in the BOLT specification, where it was
clarified that the offer amount in BOLT12 offers must always be greater than
zero when present.  So, these two PRs ensure to start rejecting BOLT12 offers
when the offer amount is set, but it is set to zero.  So, this aligns it to the
changes in the BOLT specification.

I believe the last three newsletter items have already been covered at the
beginning of the episode, the two on LDK, one about adding RBF fee bumping on
splice funding transactions, and the second one about raising the maximum
accepted channel dust limit to 10,000 satoshis for zero-fee HTLCs in anchor
channels; and finally, the merging of two draft BIPs, BIP446 and BIP448, that
basically specify OP_TEMPLATEHASH, and the second one that groups
OP_TEMPLATEHASH with OP_INTERNALKEY and CSFS.  So, these were covered earlier in
the episode.  Thank you.

**Mike Schmidt**: Awesome.  Thanks, Gustavo.  We want to thank our guests for
today's show, BlueMatt, instagibbs, and Sebastian.  And thank you, Gustavo, for
walking us through the Releases and Notable code items, and thank you, Murch,
for co-hosting and for you all for listening.

**Mark Erhardt**: And thank you, Mike, for organizing this every week.

**Mike Schmidt**: No problem.  We'll hear you next week, except Murch, maybe.

**Mark Erhardt**: Yeah, I'm not here.

**Mike Schmidt**: All right.  See you all, hear you all next week, except Murch.
Bye.

{% include references.md %}
