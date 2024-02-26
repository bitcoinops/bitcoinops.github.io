---
title: 'Bitcoin Optech Newsletter #287 Recap Podcast'
permalink: /en/podcast/2024/02/01/
reference: /en/newsletters/2024/01/31/
name: 2024-02-01-recap
slug: 2024-02-01-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Gloria Zhao and Brandon Black to
discuss [Newsletter #287]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-1-7/f85bb118-472b-11ae-56ff-e2c8b403081c.mp3" %}

{% include newsletter-references.md %}

## Transcription


**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #287 on Twitter
Spaces.  We have glozow and Rearden Code with us today, and we're going to be
talking about sibling eviction for v3 transactions, opposition to CTV based on
commonly requiring exogenous fees, we have six interesting Stack Exchange
questions, and we also have our weekly releases and notable code change
segments.  I'm Mike Schmidt, I'm a contributor at Optech and also Executive
Director at Brink funding Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs.

**Mike Schmidt**: Gloria?

**Gloria Zhao**: I'm Gloria, I work on Bitcoin Core, I'm sponsored by Brink.

**Mike Schmidt**: Brandon, just in time.

**Brandon Black**: Hi, I'm Brandon, I work at Swan now, though my work in this
is not sponsored by Swan.  I'm working on covenant stuff.

**Mike Schmidt**: Thank you both for joining us.  If you want to follow along
with this discussion, bring up Newsletter #287.  We're going to try to stay in
order, starting with the news section.

_Kindred replace by fee_

We have two news items this week.  The first one is titled Kindred replace by
fee.  Gloria, I noticed that you titled your Delving Bitcoin post Sibling
Eviction for v3 transactions and didn't even use the word "kindred".  So, did
Dave take some naming liberties here?

**Gloria Zhao**: I think so, yeah, and perhaps he's trying to make a more
generalized definition.  There was a bit of discussion about how in v3 it's your
sibling because it's your direct parent's direct child.  So, if we're thinking
in human family tree terms, that's always your sibling.  So, credit to Greg for
this idea, at least I got that idea from him.  When he proposed this, it was not
a v3 thing, it was kind of a general thing, where if you are exceeding
descendant limits, the idea was, okay, what if you just knock out one of your
ancestors' descendants?  And I guess so then it could be more than just your
sibling, in a kind of non-v3 scenario, so I think that's where Harding's coming
from.  I think AJ suggested calling that "cousin eviction".  I don't know, I
feel like at some point we shouldn't use family tree words because it gets a bit
Game of Thrones-y, if you use that to talk about mempool transactions.

**Mike Schmidt**: Yeah, I saw you had a tweet that illustrated that, I think,
recently!

**Gloria Zhao**: Yeah, I decided to start making some memes to enjoy this
process a little bit!

**Mike Schmidt**: I think we could probably assume the audience is familiar with
the notion of RBF and some of the mechanics there.  But maybe walk through how
you can replace something by fee that isn't the transaction itself, that you're
replacing something else.

**Gloria Zhao**: So, I think Harding's framing of this in the Optech Newsletter
was actually really good, so I'll go with a similar format.  So, with RBF, we
kind of have this philosophy or this framework where in our mempool, we try to
keep it consistent, right, and we have certain limits and rules that we abide
by, and one of those things is you can't have double spends in your mempool.
It'll get very ugly to try to keep track of them; I mean, we want a consistent
mempool.  So, with this in mind, with this kind of hard limit, if we see another
transaction that breaks that limit…  Hello?

**Mark Erhardt**: Yeah, we lost you there for a moment.

**Gloria Zhao**: I have a five-minute limit of Twitter on my phone.  Okay, so
you get a new transaction that would cause you to break your limits if you were
to accept it, ie you have double spends.  So, what we're trying to do is just
keep the most incentive-compatible version that is within our stated limits.
And so with RBF, we have some way of assessing that this new transaction is more
incentive-compatible to keep in our mempool, because it gives miners more fees
if they mined it.  And then we have some kind of rate-limiting mechanism, that's
where rules 3 and 4 come in, so that it's not like each replacement has one
extra satoshi and then we're allowing a bit of spam there.

So, this is kind of extending that concept from just double spends to our
package limits.  So, we have ancestor and descendant limits, and those are there
for DoS protection.  We've kind of decided that after the 25th transaction, the
potential mempool operations get too computationally complex for us to handle,
which is why we limit them to 25.  And so, let's take CPFP carve out out of the
equation first.  So, when we get to the 26th one, we'll be like, "No, we can't
handle this" and we'll just reject it.  And that can be a real shame if, for
example, this was a really, really high feerate transaction and you had received
25 low feerate ones.

Of course, CPFP carve out is designed to make it so that, in very specific
scenarios where we really want to make sure that we're able to accept this other
kind, I'm going to abstract the details a little bit, we allow one extra one.  I
think that's not great; we're kind of compromising on what we said was our DoS
limit, and we're like, "Just one extra is fine".  So, an alternative approach is
to consider evicting one of the children that is in that descendant set, number
3 or number 4, number 24, whatever, so that you can accept this new one, still
stay within your DoS limits, but you have a more incentive-compatible set of
transactions there.

When Greg first suggested this, there were a few things that made me hesitant.
One is, it's very computationally complex to decide what you're going to evict.
You could have multiple ancestors and each of those ancestors can have their own
descendants.  And within that descendant set, you can have various combinatorial
choices in terms of what you should evict.  So, for example, if you're coming up
against the size limit, instead of just the count limit, you might have to evict
multiple transactions.  You need some kind of general framework of saying,
"Okay, if I take some subset of these transactions, it would be more or less
incentive-compatible".  So, it's very computationally complex to do this.  And
another issue was it's quite full-RBF-y, because if you're thinking about the
question of, what if some of those descendants, I don't know, didn't signal RBF,
or this ancestor didn't signal RBF, etc, this is maybe outside of the realm of
what users are expecting with respect to replacements.  And both of these issues
are not an issue in v3.

So in v3, you only get one parent, one child, so there's only one choice for
which descendant you might evict.  And you can't have multiple ancestors, so the
set of possibilities is -- there's two possibilities, right?  You keep the old
one or you bring in the new one.  And all v3 transaction signal replaceability,
all of their ancestors and all of their descendants have to be v3, so they're
all signaling replaceability, and that's not an issue.  And then the third thing
that motivated opening this beyond just, "Oh, this is a really cool thing that
you can do in v3", which is great, but I think the biggest thing that pushed for
this was, we were trying to figure out how we can pattern-match existing LN
commitment transactions and enroll them to this v3 policy, if it takes them some
time to change their commitment transaction format explicitly, to actually you
know change the inversion field on those transactions; like, how can we make it
work with existing transactions?

One issue that we ran into was, well today, there's two anchors, right, and the
remote or the local can each spend either version of a commitment transaction.
And of course, normally you'd just spend your own anchor and you'd publish your
commitment transaction and spend your local anchor.  But that's not guaranteed
if someone is trying to screw you and they're trying to pin you, so they
broadcast yours and they spend their anchor, and you have to prepare for that,
right?  And so we're like, "Okay, should we roll a new one parent, two child
kind of thing?  Should we add a carve out to v3?"  And then Greg and Suhas were
like, "Well, why don't you just do sibling eviction, because with v3 it's easy,
and that would very trivially solve this problem?"  And on the Delving post, I
think it's Matt Morehouse, we commented and broke down the possibilities of
like, your commitment transaction, your anchor, their commitment transaction,
like all of the possibilities of what your counterparty might be broadcasting to
mempool.  And with this, with package RBF and sibling eviction with v3, it
works.  You'll always be able to fee bump either version of a commitment
transaction just by broadcasting a fee bump off of your own anchor output.

So, it seems like a neat thing to add to v3, and it nicely solves this imbued v3
LN issue that we have.  So right now, I think this is a nice part of the
roadmap.  Still seeking feedback, particularly from LN folks.  Yeah,
implementation's there.  It builds off of v3, so that's still the thing to get
in first, but yeah, that's the idea.

**Mike Schmidt**: Gloria you mentioned that imbued v3 logic, and we talked about
that.  For folks who want to dig into that more, Newsletter #286 from last week
under the Proposed changes to LN for v3 relay, there's a bullet there discussing
some of that and linking off to a post from Greg Sanders as well.  So, if you're
curious about that, jump in there.  One thing that I thought was notable, or I
at least wanted to get your feedback on, Gloria, was, does this eliminate the
need for ephemeral anchors?

**Gloria Zhao**: Oh, no.  So, like I said, Greg came up with sibling eviction
and really, really liked the idea.  Again, sibling eviction is when you don't
conflict with each other, you don't have a conflicting input and yet you're able
to replace each other.  And so he thought it'd be really neat and it's part of
the set of features that you get with ephemeral anchors.  So, ephemeral anchors
has this must-spend anchor output, right?  So, you can have n outputs that are
from this shared transaction, and each counterparty might spend their own
outputs, but you always have to spend the anchor output.  And so that implies,
essentially, sibling eviction, because all of the children are forced to
explicitly conflict with each other.  They will spend the same input.  And so
ephemeral anchors emulates this behavior.  It's basically like, the users have
to do this instead of sibling eviction being the mempool policy.  Hopefully that
makes sense.

But ephemeral anchors has several other huge benefits.  The most important ones
that I've mentioned here are that you get a zero-value anchor, which is very
important in LN-Symmetry.  And the other one is the anyone-can-spend much more
efficient output script.  So, your CPFP has a smaller input size, and so again,
the analogy that Harding uses is, the amount of fuel that you need to move the
fuel in the rocket is a lot less, so it's much more fee-efficient to do the
anchor CPFPing this way.  So, yeah, I'd still say those are very tangible and
very important benefits of ephemeral anchors, even if sibling eviction is
already a given.  So, yeah, I don't think this makes ephemeral anchors redundant
at all.

**Mike Schmidt**: Brandon, I see some thumbs up coming through.  Do you have
comments or questions about what Gloria's outlined?

**Brandon Black**: No, I just think she said exactly right, that ephemeral
anchors are still very, very valuable, but the sibling eviction can -- I think
she said exactly that it lets some older transactions also take advantage of
similar benefits before they move over to ephemeral anchor channels.

**Mike Schmidt**: Murch, do you have any questions or comments for Gloria?

**Mark Erhardt**: More of a comment.  It's my understanding that ephemeral
anchors might also be interesting for other smart contract protocols.  So, the
benefit of having an anchor that any party that is participating in the contract
can spend, and that only takes 50 bytes, 9 bytes for the output, where 8 are the
amount and an OP_TRUE, and an empty input script with just a reference of what
UTXO you are spending for 41, that seems pretty attractive to a bunch of other
proposals as well.

**Mike Schmidt**: Did you, Murch, get feedback specifically about that, or is
that just something that you've theorized?

**Mark Erhardt**: More like something that seems obvious.

**Mike Schmidt**: Yeah, I guess I can add to that.  I think in James's vaults
paper, he specifically mentioned using ephemeral anchors and v3 in the fee
bumping solution.  So, yeah, Murch is not making that up.  There's definitely
people building L2 things that have mentioned it.

**Mike Schmidt**: Awesome.  Gloria, you made a call for some more feedback on
your post, especially from LN folks.  So, if you're an LN folk, take a look at
her post, take a look at the news item this week in the newsletter, and feel
free to provide feedback.  Go ahead, Murch.

**Mark Erhardt**: Actually, I have a follow-up for Gloria.  So, v3 transactions
and ephemeral anchors fit into the overall package relay and package RBF family
of updates to mempool policy and Bitcoin core code.  Would you like to give us a
small update where the overall project is these days?

**Gloria Zhao**: Sure, yeah.  So, there's kind of two stages of the project as I
see it right now.  There's one parent, one child package relay, which is
hopefully happening soon, and that includes package RBF for v3, the one parent,
one child topology, and package relay for the one parent, one child topology.
And that gives us a base layer of being able to support and bring new
functionality to existing applications that have these fee bumping requirements
like LN.  It also paves the way for adding cluster mempool, which is quite an
invasive change to mempool data structure and validation, but a pretty
comprehensive set of improvements to how mempool works, how RBF works, how
validation works; kind of a no-brainer is how I'm calling it.

When we have that in, then I mean I'm dreaming about this beautiful new world
where a lot of things are fixed and things work better.  And that then is a
foundation upon which we can build much more complex package validation, package
RBF rules, so that we can get to, let's say for example, ancestor package relay
or a sender-initiated chunk-based package relay that is a bit more general and
featureful.  So, those are the three milestones.  Suhas has an issue open on
Bitcoin Core to talk about whether this is an adequate kind of continual support
of users that are using things like CPFP carve out that have to go away with
cluster mempool.  Yeah, there's a lot, a lot of code that's written.  There's
ten open PRs right now, I counted them up a couple days ago, that all build off
of each other and are blocked on v3.  So, I think we're trying pretty hard to
make sure that we get as many people involved with understanding and being
consulted on for these changes.

So, yeah, it's very exciting.  There's a path towards solving all the problems
that we've been talking about for many years.  That's very exciting.

**Mike Schmidt**: Gloria, thanks for joining us.  There may be some interesting
discussion later in the newsletter that you might want to chime in on, but we
realize if you have other things to do, you can drop.

**Gloria Zhao**: Yeah, thanks for having me.  I'll stay on for a bit.

_Opposition to CTV based on commonly requiring exogenous fees_

**Mike Schmidt**: Second news item this week is titled Opposition to CTV based
on commonly requiring exogenous fees.  The initiator of this discussion was
Peter Todd on the Bitcoin-Dev mailing list, referencing our discussion about
exogenous fees.  Well, he wasn't referencing it, but we reference our exogenous
fees discussion, including our topic on exogenous fees, as well as Newsletter
#284, where we talked about exogenous fees.  One of the people who was replying
in that thread was Brandon Black, who's joined us to sort of, I guess, represent
this news item this week.  Maybe, Brandon, you want to explain from scratch what
Peter Todd's getting at here and what your thoughts are on what he's saying?

**Brandon Black**: Yeah, I'll do my best to steelman his point here, which is
there's absolutely a truth, and we've talked about it in the circles that are
more supportive of OP_CHECKTEMPLATEVERIFY (CTV), there's a truth that people who
enter into an offchain protocol, whether that be LN or in the future, maybe
timeout trees or Ark or something like that, they're not truly holding
self-custody if they don't have a way to unilaterally get back to onchain
Bitcoin, because otherwise their holding of bitcoin is not based on the true
Bitcoin consensus rules if they can't get back onchain.  And so, Peter's point
was that if they have to have a separate UTXO outside of the protocol in order
to pull themselves onchain, that's not actually scaling Bitcoin, because the
thing that these CTV protocols are trying to scale is the number of users who
can hold bitcoin in their own self-custody.  And to do that, they need to share
UTXOs, but if they need their own UTXOs to go onchain, we're not scaling.  So,
that's the steelman of Peter's argument, I think.

**Mike Schmidt**: Okay.  I mean, that seems like a reasonable objection, but
what are your thoughts on it?

**Brandon Black**: So, I think it's weird.  It kind of looks very far into the
future and says, okay, in a very distant future, everyone has to be offchain,
and in that future, no one can have their own separate UTXO in order to pull
themselves onchain.  Whereas, the reality of right now is that most people who
currently hold their own bitcoin have many UTXOs.  And if we were to have some
of these CTV-based scaling protocols, let's say I could join three timeout trees
and five Arks, and those are all shared UTXOs where I'm among thousands of other
people, and maybe I also hold one UTXO of my own in reserve in order to pull
myself onchain when I have to.  So, I've reduced my need for UTXOs from
currently, let's say I've got 20, to now instead I have 1 plus 20 shared, so
I've reduced my UTXO, so I have scaled Bitcoin, even though I still have to hold
one UTXO of my very own.  And so, that's like a step in scaling.

Then as these protocols mature, exactly the kinds of things that Gloria was
talking about here and Murch as well, having ephemeral anchors, because they're
anyone-can-spend, it lets any party pay the fees for pulling some particular
sequence of transactions onchain.  To get there, we have to have full package
relay, where you can pull many transactions onchain with a single spend, where
you spend many ephemeral anchors in one transaction.  But that's a future that
is in sight, as Gloria said now.  In that future, then I might have my 20 UTXOs
all in shared UTXO pools, and I might have a contract with a provider where I
can pay them via one of those pools to pull a different one onchain using one of
their UTXOs.  So now, many people can use a provider, who has a few UTXOs to use
to spend ephemeral anchors, and we've really, really scaled.  So, I guess the
point here is that, yes, a UTXO has to exist in order to spend out of these
offchain protocols, but it doesn't have to be one per offchain protocol, and it
doesn't have to be one per person even as the future extends farther.

**Mike Schmidt**: Okay, there's this theme maybe not letting perfect be the
enemy of good, and there's been a lot of that discussion lately, and maybe that
applies here where Peter is making a point that's true, but the fact is that
there can be a lot of benefits between now and this very, very far-off future
where people don't have their own separate UTXO to be able to withdraw from the
coinpool, for example.  Okay, that makes sense.  So, he recommends abandoning
CTV and working on another covenant scheme; I assume you're not on board with
that!

**Brandon Black**: Yeah, I mean you said it very well.  Let's not let the
perfect be the enemy of the good, or even the better be the enemy of the good
here.  And then, there was a long discussion between me and Matt Corallo and
Peter, to some degree, on X two days ago now, further digging into this, and I
think any individual offchain protocol can often be made better by using some
more advanced form of commitment, whether that's as Matt Corallo was talking
about, a more explicit set of transaction introspection opcodes, or whether
that's using something like OP_TXHASH that lets us, with high granularity,
select parts of a transaction to commit to.  We can use those things to make a
protocol work better for some specific cases, bringing the fees inside the
protocol, making them endogenous to the protocol.  And then, that lets the user
of that protocol RBF it directly.

I'm not against that, it's just that each individual protocol is going to have
very different and sometimes difficult requirements to do that.  And in the
meantime, using exogenous fees and ephemeral anchors, any protocol can handle
fees using exogenous fees and ephemeral anchors, and they can do it in a
well-defined way that Gloria and Murch and others are working to make a reality.
So, let's focus on all protocols can use this, and potentially some protocols
that need to, because they, for example, have more frequent exits onchain, will
move the fees endogenous using more advanced opcodes, but that shouldn't be a
blocker to doing the thing with exogenous fees that everybody can use.

**Mike Schmidt**: Gloria, your name was invoked, as well as some of the projects
that you're contributing to.  Do you have thoughts on some of what Brandon said
in relation to CTV and opposition to it?

**Gloria Zhao**: If I had a nickel every time someone said, "We need package
relay" on Optech Spaces, I'd be so rich right now!  But yeah, I mean we were
just talking about Peter Todd's criticisms of exogenous fees, as we call it, and
how that's a reason to improve that through things like ephemeral anchors.  I'm
not going to comment on CTV.  I think, I don't know, I'm worried about saying
something that is not well researched enough.  So, maybe one day I will go and
read the lots and lots of literature so that I can come with my official
informed opinion, I guess.  But yeah, that's all I'll say.

**Mike Schmidt**: That's fair.  Brandon, I don't know if we talked on this, but
John Law's reply about fee-dependent timelocks; did you elaborate on that
already?

**Brandon Black**: I haven't.  I remember reading it when he first posted it,
but I honestly don't remember it all that well right now.  But it would be
another way to improve this.  Basically, it lets transactions say, "This next
transaction can't happen until the feerate has been low enough that the earlier
transaction could have gotten into a block".  And that way, people have the
opportunity to make sure they can bump at a fee that they pre-agreed to.  So,
that's another way to reduce the need for either exogenous or endogenous fee
bumping, because you code into your protocol that when someone wants to go
onchain, they have at least until fees fall to some predetermined rate to make
their counterclaim against some resolution.

**Mike Schmidt**: Brandon, thank you for joining us.  I know we talked about
trying to get BlueMatt on as well.  He couldn't make it, but I think we had a
good discussion nonetheless.  Anything else you'd like to say on the topic?

**Brandon Black**: No, that's it.  Thank you very much.

**Mike Schmidt**: You're welcome to stay on, but if you have other things to do,
we understand.

**Brandon Black**: I'll hang for now.

**Mike Schmidt**: Next section from the newsletter is our monthly segment from
the Stack Exchange.  We've picked out six questions and answers this week to
cover.

_How does block synchronization work in Bitcoin Core today?_

The first one is, "How does block synchronization work in Bitcoin Core today?"
and Pieter Wuille explains that since Bitcoin Core 0.10, which included the
introduction of headers for synchronization, that essentially the Bitcoin
blockchain data includes three different data structures: there's a tree of
headers; there's block data for each header in the tree; and there's an active
chain tip, which is pointing to a header entry in that tree, which includes the
associated UTXO set.  He then goes on to explain three different processes that
act upon those three different data structures: header synchronization, which is
the process of requesting and storing headers from peers; block synchronization,
requesting and storing blocks from peers; and block activation, which is the
validation of blocks that the node has received, and then changing the active
chain tip.

Pieter does a much deeper dive into these three data structures and these three
processes in his answer, and as with all sipa Stack Exchange answers, I would
invite you to go read that firsthand yourself.  Murch, anything that you'd add?

**Mark Erhardt**: No, I was going to do a similar thing and say, really you
should read the actual post because it's very in-depth, it's very detailed.
It's also the only and first overview we've had in a long time that details, I
think, more or less the entire picture, because I mean it's become more
complicated over the many years, first with header sync, now with the pre-header
sync, and there's a lot of thoughts in there to make DoS attacks and
disk-filling attacks and other things not hurt nodes.  So, yeah, if you really
want to get an overview of how all of that fits together, I would suggest you
take some time, read it, make some notes, read it again!

_How does headers-first prevent disk-fill attack?_

**Mike Schmidt**: Well, Murch, you mentioned header pre-syncing.  That leads
into the next question from the Stack Exchange that we wanted to highlight for
folks, "How does headers-first prevent disk-fill attacks?"  This was actually an
old question from 2018 which had a good answer.  I think it was actually from
Dave Harding, but Pieter Wuille added some new information pertinent to the
question since that original answer years ago, specifically header pre-syncing
that Murch mentioned.  So, as we noted in the last question, header sync was
present since Bitcoin 0.10, and that helped defer downloading blocks until the
header chain was validated and had sufficient proof of work, so that kept nodes
from downloading a bunch of blocks from a potentially invalid chain.

However, there was another potential issue that remained, which was if a peer
gave you a bunch of bogus, low proof-of-work difficulty header chains, what do
you do with that?  And the headers pre-syncing feature added in Bitcoin Core
24.0 helps mitigate that type of attack by downloading the headers twice, once
to verify the work on the chain, and then a second time when the node
permanently stores those headers, and then there's some hashing magic that makes
sure that those two downloads sort of match each other and that you're getting
the same headers each time.  And that PR that added pre-sync also allowed the
removing of checkpoints from the Bitcoin Core codebase.  Anything else you'd
add, Murch?

**Mark Erhardt**: Yeah, basically the issue is, if you're getting a header
chain, you wouldn't know that it is interesting to you until the total work on
that header chain exceeds the minimum chain work.  So, in Bitcoin Core, we track
sort of a hard-coded value with every release.  That's about a month from the
release.  And if your chain tip that is being proposed to you doesn't have at
least that much total work, you're probably downloading something strange.  Now,
as you progress in a header chain, they could just leave you hanging there and
not give you the rest.  So, you would never be at a height where you would
evaluate that min chain work, and then they just give you more and more of these
low-difficulty chains in parallel, and they could fill your disk with all these
barren header chains.

That is the attack that is being prevented here with the pre-syncing, where we
first download them, make ourselves some commitments to check that the second
time we download it, we get the same stuff, but we throw away the headers that
we've gotten until we reach min chain work.  And only if we do reach min chain
work, we go back to the same peer and say, "Hey, give it to us again", and then
check against the commitments that we've created for ourselves, whether it
actually is the same thing they're giving us, so that they can't give us bogus
the second time.  And yeah, so this gets around this disk-filling attack, and
that also removes the last reason why we needed the checkpoints.

_Is BIP324 v2transport redundant on Tor and I2P connections?_

**Mike Schmidt**: Next question from the Stack Exchange, "Is BIP324 v2transport
redundant on Tor and I2P connections?"  And it's a reasonable question since the
point of v2 is to encrypt communication between peers and Tor already does that.
And sipa in his answer notes that there isn't really an advantage from an
encrypted traffic perspective, but he did note that there's potential
computational power saved using v2.  And, Murch, I think aren't there also some
bytes saved in transmission as well with v2?

**Mark Erhardt**: Yeah, it turns out that by encrypting all of the P2P messages
into this byte stream, it actually takes less data to transmit all of the
messages.  And so, there's a tiny little bit of bandwidth savings, but yeah, as
Pieter notes, that's not the main reason we're doing this.

_What's a rule of thumb for setting the maximum number of connections?_

**Mike Schmidt**: Next question, "What's a rule of thumb for setting the maximum
number of connections?"  Pieter, again, explains in his answer, which you should
read, that outbound connections are already limited to ten, so setting the
maxconnections setting to something higher really only affects inbound
connections.  And then he goes on to note one benefit of having more
connections, which is resistance to eclipse attacks, while noting also the costs
associated with additional connections being additional bandwidth, latency
during block propagation, increased CPU usage, and the most important factor he
noted, which was memory usage.  He also notes in his answer that, "There's a
project to increase the default number of inbound connection slots in Bitcoin
Core if they're blocks-only connections.  Anything to add on that, Murch?

**Mark Erhardt**: Yeah, in that context it would still be nice to eventually get
erlay, which basically uses Moon Math to allow two nodes to first synchronize
which transactions they would be telling each other about.  And so, instead of
announcing each transaction that you learn about directly to your peers, you
would sync up your announcement lists against each other.  And the math on this
is really interesting, because it actually requires you to only transfer as much
data for your synchronization as the number of disagreements you have on your
announcement lists, and the other party learns which transaction you were trying
to tell them about.  So, this has been worked on, or has been in the pipeline
for four or five years or so.  And if that eventually comes to fruition, that
would also make it much, much cheaper to have more connections.

_Why isn't the upper bound (+2h) on the block timestamp set as a consensus rule?_

**Mike Schmidt**: Next question from the Stack Exchange, "Why isn't the upper
bound (+2h) on the block timestamp set as a consensus rule?  And our friend,
LeaBit, was at it again, asking a few questions about the block timestamp
restrictions, specifically around the rule that blocks cannot be more than two
hours into the future.  So, we noted a few different questions in the writeup
this week all pointing to different questions around this topic.  A couple of
things that I pulled out of a couple of the answers that I thought were
interesting was, this is from sipa here, "I consider the 'max two hours in the
future rule' to be an essential network rule of the Bitcoin Network.  Without
it, the system would be woefully insecure.  It's not a mere policy rule, but it
is also not, and cannot be, a consensus rule".  So, I thought that was
interesting on one of the topics.

One of the questions was, "Why isn't this a consensus rule?  Why can't things
that aren't part of the blockchain be consensus rules?"  And in relation to the
question of why it cannot be a consensus rule, sipa states, "Yes, consensus
rules can only depend on information that is committed to by block hashes.
Anything cannot be guaranteed to be observed identically by every validator at
every point in time.  And when consensus rules yield different results for
different validators, the chain can fork".  So, I thought this whole topic is
interesting.

Murch, you've maybe given more thought to this particular rule and its
straddling of, is it policy, is it consensus; but it's this other category of
important thing that isn't policy or consensus, or I guess it is policy but not
consensus.  Go ahead, Murch.

**Mark Erhardt**: Yeah, so the issue here is that if a block is timestamped more
than two hours in the future, obviously as your clock moves forward in time, you
eventually will drop below that two-hour limit and then you would consider that
block valid.  So, especially if you set it exactly 2 hours and 15 seconds into
the future, the first few nodes that see it, or maybe a node that has a slightly
off timestamp, would reject it but other nodes would accept it, and you might be
able to split the network on what they consider their active chain tip there.

The other one is, we base our difficulty adjustments on the timestamp of blocks,
so if you were able to fiddle with the timestamp of specifically the last and
the first block in the difficulty period, you can affect the difficulty.  So,
there must be some limit on what values you can use.  So we, on the one hand,
can't have it as a consensus rule because it depends on the local computer's
clock whether or not they'll accept it; and on the other hand, we do absolutely
need some sort of delimitation of how you can pick your timestamp, because
otherwise you can fudge the difficulty.  So, yeah, it's not a consensus rule,
but it's very important for the network to work properly.

**Mike Schmidt**: We talked about adjusted time.  Murch, maybe comment on how
that plays in here.  When we talked about adjusted time last, we were talking
about nuking it.  I don't remember if that was Niklas or stickies-v that we had
on to talk about that in a PR Review Club, but is adjusted time related to this?

**Mark Erhardt**: Yeah, I think the two-hour rule is currently based on the
adjusted time, because if your own computer's time were off, you would sort of
mitigate that slightly by looking at the timestamps of, what is it, only
outbound peers' version handshakes.  Maybe Gloria knows better.  Correct me,
please, if I'm wrong on that.  But basically, you get also some feedback from
your peers and use that to check your own local time.  And on that base, the
two-hour rule.  And I think there are some issues.  I think we talked about this
in the context of Niklas' PR, that when peers tell you wrong timestamps in their
version handshakes, they could affect your adjusted time locally and maybe, for
example, make you reject a block unnecessarily.

So, what we really would want is to get away from trusting our peers in any sort
of manner, except if they give us data and we can verify the data, we trust that
data because we've verified it ourselves.  So, I think the idea was to instead
hitch this "two hour in the future" rule to the Median Time Past (MTP), which
would again be timestamps in blocks, rather than something more squishy like
what our peers are telling us.

**Mike Schmidt**: Gloria, did we move from network-adjusted time to MTP or local
time?

**Gloria Zhao**: To local time, no, in Niklas' PR?

**Mike Schmidt**: That's what I was thinking, yeah.  Okay, so now the attack
vector is, if you can change the clock on someone's machine, then you've forked
them off the network?

**Gloria Zhao**: I think if you can change someone's clock, they have a lot of
problems.

**Mark Erhardt**: Oh, yeah, and MTP wouldn't be that safe either, because that's
a stuck point in the past.  So, if you don't find a block for three hours, you
wouldn't accept one with an actual timestamp anymore.

_Sigop count and its influence on transaction selection?_

**Mike Schmidt**: Last question from the Stack Exchange, "Sigop count and its
influence on transaction selection?"  This question was inspired by a tweet that
noted a large number of stamps protocol transactions can use up the entire
80,000 per block sigop limit.  And I think, mononaut, I think you're here, and I
think it was your tweet that spurred this question.  The person asking this
question then wondered, "How does that limit, that sigop limit, impact miners'
block template construction?"  And as a second question, "How does that sigop
limit affect mempool-based fee estimation?"  And I think, mononaut, you also
answered this question saying that, "Only 62 of the last 10,000 blocks had
sigops as the limiting factor during block template construction".  And you also
noted the bytes-per-sigop option in your answer.

So, Murch, does it seem that the answer to both of these original questions is
that sigops are not factored into transaction selection, other than the limit
not being exceeded, and similar for mempool feerate estimation tools?

**Mark Erhardt**: I think that I would like to punt this question to Gloria.

**Mike Schmidt**: Oh, Gloria, do you know something about this?

**Gloria Zhao**: Yeah, so there's a sigop limit and there's a weight limit,
right, and you're trying to maximize fees while staying within these limits.
And this is two-dimensional knapsack, for those of you who like algorithms.  And
actually, it's not just two-dimensional knapsack, is it; there's also
dependencies between the items.  So, this is a very NP-hard problem to solve.
And especially because sigops limit is usually not the limiting factor, as
mononaut said.  What we do is we just roll --we have one metric for virtual
bytes that encompasses the maximum of both, where you use the ratio between the
two limits as the kind of multiplier for getting from sigop size to virtual
size.

So, yeah, I mean I'm kind of wondering, if we hit the sigops limit in the block
template producer, couldn't we just greedily continue with the next zero sigop
highest feerate transactions as we go?  I guess it would be somewhat complex,
but we could maybe greedily fill that in, right?

**Mark Erhardt**: We had a few blocks a while back where exactly that happened.
So, stamps use 1-of-3 of three multisig outputs, and they're bare multisig so
they count as 80 sigops per output, and so you can't have more than 1,000 of
them in a block.  So, when stamps were briefly actually being used, they
basically exhausted the sigops limit very quickly, and then the rest of the
block was filled with non-sigop transactions.  But that highlighted again a
little bit the issue with bare multisig, where even this very high 80 sigops
count -- or, the virtual byte of these transactions is increased by the sigops,
because we count them as a higher weight because they have excessive sigops
amounts.  And, yeah, it leads to this two-dimensional optimization problem that
Gloria mentioned.

**Mike Schmidt**: Murch or Gloria, are you aware of people fiddling with the
bytespersigop option?

**Gloria Zhao**: Mononaut, maybe, is my guess!

**Mark Erhardt**: I think I saw an issue or a PR that suggested that we increase
the factor by which we count the sigops towards the vsize, but I don't remember
the details.

**Mike Schmidt**: I invited mononaut up if he or she wishes to speak, but in the
meantime I think we can move on in the newsletter to the Releases section.

_HWI 2.4.0_

We have one this week, HWI 2.4.0.  We noted the RC last week for this release
and now this release is out.  Two notable things that it adds is (1) support for
Trezor Safe 3, which is a hardware signing device, and (2) support for Python
3.12.  As we move to the Notable code and documentation changes for this week,
I'll open up the floor to the audience for any questions or comments you have on
this newsletter, or you can leave something in the tweet thread and we'll try to
get to that at the end of the show.

_Bitcoin Core #29291_

First PR, Bitcoin Core #29291.  Last week, we had Niklas on, who told us about
the bug he discovered where negative OP_CHECKSEQUENCEVERIFY (CSV) values caused
issues in btcd.  This PR adds a test vector to Bitcoin Core corresponding to
that bug.  This test vector is a JSON file that resides in Bitcoin Core, but can
be used by alternate implementations as well.  And if it had been run by
alternate consensus implementations, if it existed when it was discovered, it
would have caught this consensus failure bug that Niklas had discovered and
responsibly disclosed.

_Eclair #2811, #2813 and #2814_

Next three PRs are to Eclair, #2811, #2813 and #2814.  Last week, we covered
Eclair #2810, which was some foundational work around trampoline payments.  And
this week, these three PRs are also related to Eclair's trampoline
implementation.  To quote the newsletter on these PRs, "Adds the ability for a
trampoline payment to use a blinded path for the ultimate receiver".  So
previously, trampoline privacy depended on using multiple trampoline forwarders
so that none of the forwarders knew that they were the last forwarder, and that
required longer paths and more fees.  But with blinded paths, now forwarding
payments through even a single trampoline node can prevent that node from
learning the ultimate receiver.

T-bast was also on last week and he was the one who described Eclair #2810, and
he talked about how Eclair's getting to spec version out that would be
interoperable with LDK.  And he was also hopeful that trampoline was something
that could be finalized this year.  Anything to add, Murch?

**Mark Erhardt**: Yeah, I just read this here again, and I'm actually a little
confused.  Even if you use multiple trampoline forwarders, wouldn't the last
forwarder know that they're the last forwarder, because without a blended path,
they still have to set the final destination, right?  So, is it just forwarding
trampolines that don't learn anything, or am I misreading that?

**Mike Schmidt**: Yeah, I guess you're right in the way that this is worded, and
I don't know the actuals on that.  Shucks, if only we had t-bast on every week!

**Mark Erhardt**: We really need a Lightning expert here.  Maybe just as a
refresher, a trampoline payment is used when you basically are running an LN
light client and you don't necessarily know about the entire network of channels
that exist in the LN; you basically give a receiver onion to the trampoline and
say, "Hey, could you please route that to the receiver?"  And now, the receiver
onion apparently can contain a blinded path instead of just the final hop, and
that way, the trampoline only learns the rendez-vous point, instead of the final
destination of the receiver.

_LND #8167_

**Mike Schmidt**: LND #8167.  This PR fixes a bug with LND where users couldn't
mutually close with pending Hash Time Locked Contracts (HTLCs).  So, before this
change, when LND received a shutdown message, it would actually force close the
channel, which obviously requires extra onchain transactions and fees to settle.
And after this change, LND behaves in the way, according to BOLT2 channel close
recommendation, which is that LND should wait for the HTLC to be resolved, not
add any new HTLCs, and then reply with a shutdown message.  So, this is
actually, I guess, I would call it a bug fix.  And actually, it's outlined as a
bug fix in the PR.

_LND #7733_

Next PR is also to the LND repository, #7733.  LND had previously added support
for simple taproot channels, and this PR adds support for taproot channel
commitments in LND's watchtower implementation.  The LND watchtower server and
client are both updated with this PR to support backing up taproot channels.
Murch, do you want to say anything on taproot channels or this PR?

**Mark Erhardt**: Well, I'm looking forward to that future when we have them,
but it turns out that these smart contract protocols, even if their core idea is
deceivingly simple, are very hard to develop.  And once you actually have people
using them, you're fixing the airplane in flight, and that makes it just so much
more difficult.  So, I don't know, taproot channels might still take a while.

_LND #8275_

**Mike Schmidt**: Last LND PR for this week, #8275.  Back in Newsletter #259, we
covered the LN specification cleanup proposed news item, where Rusty Russell
proposed to remove some features that were no longer supported by most current
LN implementations, and then to also assume other features will always be
supported.  Those changes were proposed in BOLTs #1092, which although it's
still open to the BOLTs repo, is something that LND is going to enforce with
this particular PR.  Go ahead, Murch.

**Mark Erhardt**: Yeah, so maybe a little context here.  The LN protocol has a
feature bit vector that for every feature uses 2 bits, an odd bit and an even
bit, and they both tell whether something is supported or not.  So, 0 and 1
would both refer to the same -- yeah, I think it's 0 and 1, 2 and 3, 4 and 5,
and so forth, they both refer to the same feature.  And there's this cute rule
called "it's okay to be odd".  If you talk to an LN peer and that peer has some
feature set to odd and you don't understand what feature they might be referring
to, that's fine, you just ignore it.  However, when they set the feature bit to
even, then if you do not speak that feature, they will disconnect you, or you
disconnect them if you don't support it.  I'm not sure which direction drops the
connection there.

But anyway, this is basically just how you distinguish between optional features
and mandatory features.  And my understanding is that the features that are
being set here to mandatory all have been deployed for many years, and all of
the LN implementations support these features, so it doesn't sound scary to me
that LND is starting to enforce this even before the BOLT is merged.

**Mike Schmidt**: And likewise, those removal of features that are no longer
supported, I think in #259, I don't have it up in front of me, but I think Rusty
noted that basically there were no implementations or very few implementations
or nodes on the network that were deviating from either the removal or adding of
these features.  So, yeah, it seems safe.

_Rust Bitcoin #2366_

Rust Bitcoin #2366 deprecates the .txid() method on the Transaction objects and
begins providing a replacement method named .compute_txid().  And that
.compute_txid() method operates the same as .txid() did, but it's renamed to
signal to developers that it's a computationally expensive method.  And that's
because every time that that method is called, the txid for the transaction is
calculated again, so it's not just a simple getter, which is kind of what it
looks like.  But when it says compute, now you know that there's going to be
some resources put towards computing that txid.  And it's similarly, I think,
for witness, and I think there were a couple other ids that were similarly
renamed to compute.  Murch?

**Mark Erhardt**: This PR, I haven't looked at it more in depth, and I'm not
that familiar with Rust either, but it seems to me that txid is one of those
parameters of an object, a transaction object nonetheless, that sort of once
you've computed it, want to keep around.  But maybe I'm just misreading the
intention here.  I find this a little funny or odd, but maybe someone can post
in the comments on our Recap in Twitter why that isn't just a stored field?

**Mike Schmidt**: Perhaps they're building a transaction and you call it once
something, and call it again something else.

**Mark Erhardt**: If it's a non-final transaction, that would make more sense.
Yeah, maybe that's it.

**Mike Schmidt**: Yeah, I mean there is some interesting discussion in the PR.
I think Andrew Poelstra was somewhat against this change at first and came
around to it.  But yeah, if you guys know more, feel free to comment on it.

_HWI #716_

HWI #716, adding support for the Trezor Safe 3 hardware signing device, which is
rolled into the release that we just mentioned earlier for HWI 2.4.0.

_BDK #1172_

BDK 1172 adds a block-by-block API for the wallet.  So, the use case for
something like a block-by-block API would be, if a BDK wallet user wanted to use
the API to iterate over a bunch of blocks, and then update that specific wallet
based on any transactions that impacted that wallet in those blocks; or
alternatively, we noted in the newsletter that user can also potentially use
compact block filtering to find only blocks that have an impact on that wallet
and iterate over that subset of the blocks to update the wallet accordingly.

_BINANAs #3_

Last PR this week is to the BINANAs repository BINANAs #3, adding BIN24-5, which
lists other pertinent Bitcoin and related tech spec repositories for reference.
So, we talked about the BINANAs repository with AJ, I think it was last week.
So, if you're curious about what he's doing there, check out our discussion with
him.  And this particular PR adds references to the BIPs, BOLTs, BLIPs, SLIPs,
LNPBPs, and DLC repositories for spec references.  I also realized when I was
looking at this, Murch, I think there's an LSPs one, right, a Lightning Service
Provider (LSP) spec repository?  Do you remember having a chat about that?

**Mark Erhardt**: I think we talked about that a while back, yes.  There were
some of the (LSPs) getting together to sort of formalize what sort of interface
an LSP should have, which might then in the long run enable a light client to
not be locked into a specific LSP, but maybe to have LSP connections with
multiple different implementers of that standardized interface.  So, instead of
maybe having your Phoenix wallet only connect to ACINQ server, you might also
have a few other LSPs that in parallel provide a channel to your light client.

This might be especially interesting in a world where we maybe move towards more
use of LSPs but still not want to be locked in with all of our funds to a single
LSP.  My colleague, Clara, wrote a paper about that, Maypoles: Lightning Strikes
Twice, where she explores an idea that is related to how many connections nodes
should at least make in the network, even if they're light clients.  Yeah,
anyway, you can probably find that if you search for Maypoles, "May" like the
month and "pole" like a halberd.

**Mike Schmidt**: It looks like I'll have to open up BINANAs #4 then and add
LSPs.  Anything else to announce, Murch?  We don't have any questions.

**Mark Erhardt**: I do not have any additional news to announce today.

**Mike Schmidt**: Well thanks to our special guests, Gloria and Brandon, for
joining us.  Thanks to my co-host as always, Murch, and thank you all for
joining and listening.

**Mark Erhardt**: Cheers.

**Gloria Zhao**: Thank you, bye.

{% include references.md %}
