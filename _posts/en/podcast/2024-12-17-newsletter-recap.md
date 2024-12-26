---
title: 'Bitcoin Optech Newsletter #333 Recap Podcast'
permalink: /en/podcast/2024/12/17/
reference: /en/newsletters/2024/12/13/
name: 2024-12-17-recap
slug: 2024-12-17-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Dave Harding, /dev/fd0, and
Gloria Zhao to discuss [Newsletter #333]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-11-18/391776779-44100-2-837322bbb0ae2.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #333 Recap on
Riverside.  Today, we're going to talk about a recently disclosed Lightning
vulnerability; a vulnerability affecting Wasabi and the WabiSabi protocol;
research around LN channel depletion; there's a public survey of developer
opinions on covenant proposals; a paper on oracle-assisted covenants; discussion
topics from a recent Bitcoin Core Developer meeting; a PR Review Club about
orphans; four interesting Client and service updates; and three questions from
the Bitcoin Stack Exchange.  I'm Mike, contributor at Optech and Executive
Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs.

**Mike Schmidt**: Dave?

**Dave Harding**: I'm Dave, I'm co-author of the Optech Newsletter and this
week, an accidental security researcher.

**Mike Schmidt**: Floppy.

**Floppy Disk Guy**: Hi, I'm Floppy and I work on Joinstr.

**Mike Schmidt**: Gloria.

**Gloria Zhao**: I'm Gloria, I work on Bitcoin Core.

_Vulnerability allowing theft from LN channels with miner assistance_

**Mike Schmidt**: Well, thank you all for joining us.  We have quite a packed
newsletter, as this is our last regular one of the year.  So, we have all of our
special segments crammed into one, in addition to a bunch of interesting News
items, the first of which involves Dave Harding discovering a vulnerability,
disclosing the vulnerability, reporting in the Optech Newsletter on the
vulnerability, and now also joining us on the podcast to discuss the
vulnerability.  Full stack Dave Harding today.  "Vulnerability allowing steps
from LN channels with miner assistance".  Dave, what's going on?  What did you
find?

**Dave Harding**: Well, this was actually pretty much a direct outgrowth of a
summary we wrote for the newsletter back in January.  So, back then, there were
several developers, both Bitcoin developers and LN developers talking about an
idea of pre-signed fee commitments in LN channels.  And one of the interesting
points in that discussion came from Bastien Teinturier, t-bast, who said that if
you sign a bunch of commitments to varying fees, your counterparty has to assume
that you're going to use the highest of those feerates, that's what they're
going to put onchain.  I thought that was a really interesting point and we
summarized it for the newsletter.  And then, about a month later, Matt Corallo,
BlueMatt, was talking about something, and I remembered t-bast's point, and was
about to reply to Matt when I decided to take a look at the LN protocol
specification and see how did it deal with fees right now in the live protocol.

What I discovered was that it was possible, using three of the four
implementations, and the fourth implementation with non-default settings, for
the party in the channel who's responsible for paying fees, let's say that's
Alice, to jack fees up to about 98% of channel value and then immediately bring
them back down.  And then, she could move 99% of the funds in the channel over
to Bob's side and broadcast that old version of the transaction.  So, Bob would
think at that moment, right before the broadcast, that he would control 99% of
channel value.  But in reality, when that transaction gets confirmed, 98% goes
to fees.  And in that final channel state that gets confirmed, Bob controlled 1%
of the channel value on his own, direct to his address, and Alice would control
1%.  Because she broadcast an old state, Bob could take that 1%.  So, Bob would
end up with 2% where he previously, just a moment before, thought he controlled
99% of channel value.

Now, instead of broadcasting this, Alice could also try to privately mine it.
So, instead of the fees going to a miner, if Alice was able to privately mine it
and her block didn't go stale and everything was right, she would walk away with
the 98% of fees, making this a practical theft attack, even though it does have
some challenges if you were actually going to try to deploy it.  And an LN
closed transaction with no HTLCs (Hash Time Locked Contracts) is about 300
virtual bytes (vbytes), a little bit more.  So, you can close about 3,000
channels in a block using this attack.  So, Alice could steal from up to 3,000
different channels, each potentially belonging to a different person, all in the
same block.  And I just made a rough assumption that if Alice was targeting
channels for this, she could probably get about $1,000 a channel.  So, the max
she could steal in a single block would be about $3 million, so it's a
substantial amount of money.  Like I said, it was just following up on some
stuff that we wrote about in the newsletter and discovered this.  And of course,
I immediately reported it to the LN developers and they went to work fixing it.
So, that's a quick summary.

**Mike Schmidt**: Am I right to understand that LN implementations, at the time
you discovered this, would have sort of a floor value of, "Hey, I don't want
fees to go below this amount, and I'll take some mitigations or we can
communicate about that, but I'm going to express some preference that I don't
want it below this amount", but that there was no upside cap on that
negotiation, which is the crux of the issue?

**Dave Harding**: That is correct.  So, it's important to both parties in the
channel that commitment transactions, which are the offchain transactions that
can be published onchain if necessary, it's important to both parties that
commitment transactions pay a reasonable minimum feerate.  So, Alice is
incentivized to choose a reasonable feerate for that, Bob is incentivized to
ensure that she chooses a reasonable feerate for that.  However, because the
party who opens the channel, in this case, Alice, is responsible for paying the
fees, those come out of her balance and her balance alone, LN implementations
were like, "Well, it's her money, we can let her set it as high as she wants.
We aren't going to limit people on that".  And that's where this became a
problem, because she can set it much higher in one state than the amount of
money that she's going to control in a subsequent state.  So, she can kind of
pay fees that aren't going to be hers in the future.

That was one of the mitigations we talked about for this, potential mitigations,
was that once Alice set fees to a certain level, never again could she move that
value to Bob's side.  Bob would just refuse any proposal that Alice made to move
that money to her side.  However, that would mean, let's say fees became 5% of
channel value during a particular fee spike, that Bob could never receive more
than 94% of channel value, because 1% would have to stay on Alice's side as an
incentive.  And that just degrades the quality of the LN, it just means there's
less funds available to be spent.  And so, the LN developers, when we had the
private discussion about this, they said, "Let's just go all in on trying to get
exogenous fee bumping".  So, commitment transactions will either pay zero fees
with pay-to-anchor (P2A), or they'll pay some fixed level of fees, but it won't
change during the lifespan of a channel.  And if it doesn't change, there's no
risk of Alice moving those funds to Bob's side at a later point.

So, that's the solution they decided to go on, is just upgrade LN to take
advantage of recent work in Bitcoin Core's transaction-relay and mempool design,
to support better CPFP-style fee bumping.

**Mike Schmidt**: Gloria, you didn't know that you were helping mitigate this
issue, but you were, by just having a broad perspective on how things should be
improved at the mempool and policy layer, huh?

**Gloria Zhao**: Yeah, I mean I wasn't a part of this discussion.  The
vulnerability was very nicely handled, where I suppose I was working on a
solution, but I didn't know that it was a solution to this.  But yeah, that's
great.  I mean, I kind of think of it as like, there's Alice and Bob and a
payment, and then there's a miner.  So, it's almost like you have a three-way
payment channel.  And almost once you've paid a sum to the miner, you can't
expect to get that back.  I don't know, that's kind of my mental model around
this vulnerability.  But that's really cool that we can solve that.  This is one
of many things that are just kind of nicer if you can always adjust using
exogenous fees afterward.  So, it makes me very happy to hear this.

**Mike Schmidt**: Dave, I think you've framed this as a malicious party who also
happens to just add on a little mining capability at the end to take advantage
of the vulnerability.  But I think probably the scarier thing is if a miner was
the one that wanted to get involved with LN channels and confiscate it, right?
They wouldn't need to acquire any of the hash power because they already have
it, right?

**Dave Harding**: Actually, you don't need much hash power to do this attack.
You just need to be able to mine a block within the lifespan of a channel.  So,
if channels have an expected lifespan of six months, then all you need is the
ability to have a reasonable expectation to mine a single block within six
months, which is the amount of hash power that's, I don't know, $300,000 worth
of equipment.  I think it's more reasonable to expect an attacker just to rent
the hashrate.  I was surprised how easy it looked to be to rent 1% of network
hashrate when I looked into this.  After I reported it, I wanted to try to nail
down some estimates on how practical this attack was.  I just Googled for, "Rent
hashrate", and I came up with a website that would happily rent me 1% of
hashrate without any real work; just deposit some bitcoins, rent hashrate for 24
hours, 1% of network, that's enough to have a 67% chance of getting a block.
And it's just a little scary, because there's a lot of weird stuff in the
protocol where we're using standard transactions to hopefully avoid people do
wonky stuff.

So, anyway, yes, you could be a miner and pull off this attack with your
existing equipment very easily.  But if you weren't a miner, all you have to do
is set up a private Stratum server.  That way, you know the transactions locally
that you want to keep, because they're all high-fee transactions, and other
miners would love to steal them.  So, you set up a private Stratum server that
doesn't tell the hashrate that you rent the transactions that you're trying to
mine, and then you're good to go.  Just pay some money, get some hashrate,
within a day you have a block and you've stolen $3 million.

**Mike Schmidt**: Yikes!  Well, thank you, Dave, for outlining that and
disclosing it responsibly and joining us to explain it here.  Anything else,
Murch or Dave or Gloria on this item?

_Deanonymization vulnerability affecting Wasabi and related software_

Second news item titled, "Deanonymization vulnerability affecting Wasabi and
related software.  Dave, we confirmed before this discussion and you said that
you're comfortable outlining the scenario here as well.

**Dave Harding**: Sure, sure.  Wasabi and related software, like GingerWallet,
uses a type of coinjoin we call coordinated coinjoin.  So, in any coinjoin, the
idea is that a bunch of people create a transaction together.  They all
contribute inputs and they all receive outputs for roughly the amount of money
they put into the transaction.  But an outside party can't tell whose inputs are
connected to whose outputs.  So, it obfuscates the chain of transactions so that
it's hard for a third party.  In a coordinated coinjoin, the same coordinator is
helping people create a whole bunch of these coinjoins, so there's a clear risk
that the coordinator could be compromised and if they knew everything about the
construction of the transaction, they could tell you whose inputs are connected
to whose outputs.

Wasabi, and particularly with their latest WabiSabi protocol, they use anonymous
credentials.  So, say I want to participate with a coinjoin, you give them your
inputs and they give you an anonymous token that allows you to later submit the
outputs that you want in the transaction, in a way that's supposed to make you
look indistinguishable from everybody else who is requesting outputs be added to
that transaction.  However, the developer of GingerWallet, which is a spin-off
of Wasabi, discovered that one of the checks for whether those tokens were
formed in a way that prevents the coordinator from tracking you, was left off.
It was accidentally refactored out.  And so, it was possible for a coordinator
to give each client different tokens, different credentials, if you will, that
allowed them to track them when they were submitted for outputs later on.  So,
the coordinator could, in theory, figure out whose inputs belong to whose
outputs.  Still from a blockchain perspective, a third party wouldn't know whose
inputs or whose outputs are related, but the coordinator could collect that
information on all of its users and then submit it to law enforcement, or
whatever.

This was fixed on the GingerWallet side, however there is a bunch of this
problem in the current Wasabi protocol.  From what I understand, what I've been
told, the developers of Wasabi were concerned that the full range of credential
verification necessary to ensure that each party received an anonymous usage
token were too heavyweight for SPV clients, too heavyweight for lightweight
clients.  They would have to commit to the history of previous transactions,
kind of like you have to make a PSBT for a hardware wallet, you have to include
entire copies of previous transactions for legacy transactions and potentially
for segwit v0 transactions.  So, they were concerned it was just too
heavyweight, and they didn't implement full validation of the credential to make
sure it was anonymous, make sure it was truly anonymous for that user and didn't
track them in any way.

This problem was a to-do since 2021, when the WabiSabi protocol was being worked
on by Yuval Kogman, and it's never been fixed and Yuval has been quite upset
about it.  He has raised the issue multiple times.  So, this is a new specific
issue, but it's part of a class of issues that is known to exist in Wasabi.  Go
ahead, Murch.

**Mark Erhardt**: That sounds really concerning to me.  In the context of Wasabi
specifically making the claim that they wouldn't be able to tell, and this class
of vulnerabilities existing for three years directly contradicting their public
claim, I think that's that sounds very irresponsible.

**Dave Harding**: Yeah, I agree, and I think it's a little sad.  I knew Yuval
had problems, I never investigated it, and I really do apologize to Optech's
readers and listeners of this podcast for not doing that.  We don't usually
track Wasabi, that's my excuse.  It's not something that we focus on.  We focus
on infrastructure software.  But Wasabi, at a coordinator level, kind of is
infrastructure software.  So, again, I apologize for not investigating further,
even though I knew Yuval had a problem.  I didn't know about this specific
problem, but I knew he had a problem.  So, that's unfortunate.  Yuval, we've
been told he's requesting CVs for this stuff, and so hopefully we'll have a
little bit more to talk about this in the future.

**Mike Schmidt**: Dave, I appreciate your candor there, but of course I'll
asterisk that for you, and obviously that's not your job to investigate claims
of vulnerabilities in the software that we discuss.  So, I appreciate you taking
the lead on this news item and taking some accountability there, but of course,
that's not your job.  Anything else on this news item?

_Insights into channel depletion_

Next news item titled, "Insights into channel depletion", is our news coverage
on René Pickhardt's recent Delving Bitcoin post.  And we also did a Precap deep
dive with René, and there's a separate podcast from this one that you're
listening to now, that goes deep with René, and Christian Decker and Dave
Harding asking questions about this research and the approach.  So, if you're
interested at all in the discussion that we'll summarize briefly here, jump into
that.  I think it was about 45 minutes of smart people talking about the
research in depth that we wouldn't be able to get to today.  Dave, you were part
of that discussion.  Would you care to also summarize?  Sorry, it's the Dave
show today.

**Dave Harding**: Well, first of all, I was really glad we had that deep dive
discussion.  I was having a hard time understanding exactly what René was
talking about from his post.  And then, when we got both René and Christian
Decker, who are two of the foremost researchers on LN, on the same podcast and
just talking to each other, Mike and I just sat back and let them talk for a
good part of that episode.  They were really able to go into the research and
talk about a whole bunch of nuances.  So, anybody who's really interested in
this stuff, I would highly recommend you go listen to that deep dive.  The
interesting thing here is René replicated a prior result that we didn't cover in
the newsletter.  It was posted to the mailing list, I didn't cover it.  I didn't
understand it back then either.

But if we think of the LN starting as a graph, so it's a distributed graph.  A
whole bunch of people have a bunch of connections, and there's a bunch of
circuits and a connection.  So, Alice can pay to Bob can pay to Carol can pay to
Dan and then back to Alice.  So, that's a circuit.  Those circuits are going to
have a natural direction in which funds are going to want to flow.  It's defined
by the rest of the network.  It's not something that's you're easily able to
guess at just by looking at the network, but there's going to be a natural
direction.  And one of those channels is going to have less funds than the
others, or maybe they'll have the most funds, but eventually, because funds
prefer to flow around that circuit in a particular direction, one of the links
is going to become depleted, it's going to run out of funds, and that breaks the
circuit.  You can no longer send funds in that direction around the circuit.
And this naturally turns the graph into a spanning tree, which is a graph with
no circuits.  All the circuits become depleted, and then you only have one path
for any payment across the network.  It has to use parts of that spanning tree.
It doesn't have any alternatives that it can go through.

This is a very interesting result at a scientific level, but it also helps
explain why channels deplete in general.  Like, even if everybody used Lightning
for every payment, channels would become depleted, just because there's a
natural direction for funds to flow across the circuit, and that means that they
will become depleted on one side.  And a spanning tree, René points out, is
basically a hub-and-spoke topology, which is also just an interesting result
because that's something that I remember us being very clearly trying to avoid
in the early design of LN.  We were like, "No hub-and-spoke, we want a
distributed network".  But it turns out that we kind of get a hub-and-spoke
topology no matter what we want.

Now, René and Christian also talked about what we could do to delay the point at
which the network becomes a spanning tree.  And this, I thought, was especially
interesting.  René talked about how channel factories and similar constructions
can allow a greater number of wealth states.  So, in a two-party construction of
channels, like we have LN right now, ours can control 1% or 2% or 3%, Bob can
control 99%, 98%, 97%, but that's all that's possible.  If you have three
parties, the number of wealth states increases.  So, all the funds can be
controlled by Alice, they can all be controlled by Bob, or they can all be
controlled by Carol, or you could have any distribution of wealth between those.
And the amount of funds in the channel will likely be higher if each party has
the same average amount.  This creates larger channels and larger channels are
more resistant to depletion, potentially a lot more resistant if you have a lot
of users in the same LN channel factory.

René does caution that channel factories have a higher onchain cost when they
have to go onchain.  So, if somebody needs to escape that, they need to close,
the cost can be higher than a two-party construction.  So, there are still
fundamental limits to LN and the feasibility of payments across them, because
once there's not enough money for Alice to receive 3 bitcoin in the channel
factory, then an onchain payment has to be made.  But in general, channel
factories can potentially greatly improve the ability of the LN to resist
channel depletion.  So, it was an interesting result.  It's an interesting
discussion.  René is working this into a paper with a lot of other stuff.  We've
already covered a preliminary result for that in a previous newsletter, back in
June, I think.  It's just nice to see this ongoing research and to have these
interesting results be published.

**Mark Erhardt**: I have a question.  Looking at the graphs that were shown in
the newsletter and reading about your deep dive, I haven't listened to the deep
dive yet, channels are obviously bidirectional, and especially if we have a
distributed network with many connections, and the example is Alice pays to Bob,
Bob pays to Carol, Carol pays to Dave.  And once a cycle no longer sends funds,
due to one of the segments being completely lopsided, wouldn't the counter
direction in the well-connected graph still be a viable option for maybe more
fees?  But how come the network just doesn't route around the -- or maybe I'm
missing something, but how come it doesn't flow the other way after one of the
segments is depleted, or is it just -- yeah, go ahead.

**Dave Harding**: Well, René found that there's basically a preferential
direction to that.  So, it absolutely can flow the opposite direction.  The
spanning tree is not stable in the sense of, once you get to it, it's not a
terminal state because, like you said, you can flow the other direction.
However, because of forwarding fees charged on the channels surrounding the
circuit, because of the liquidity distribution across the circuit, there's a
preferential direction.  So, even when the circuit is refreshed by somebody
sending a payment the opposite way, the next payment is likely going to want to
go on the preferential direction and is going to deplete the channel again.
René and Christian talked quite a bit about trying to predict this
probabilistically, and they didn't think that it was feasible to do that.  They
thought that there was just too many probabilities involved, so the
computational cost in a real network would be too high.

But yes, I mean again, they really wanted to, and I should have mentioned this,
they really wanted to make it clear that it is in a terminal state, the spanning
tree, because you can still reroute payments the other way, and because other
things in the network can change, other conditions in the network can change,
and a different spanning tree might be next, a completely different one.
There's no way of predicting what that state is going to look like.

**Mark Erhardt**: Another follow-up question.  So, you said that bigger
channels, or channel factories specifically, would delay it, because I assume
it's an effect of the payment being such a smaller portion of the overall
channel capacity.  So, if channels keep depleting in one direction, would it
maybe just be viable to splice in more funds into channels in the direction that
they deplete in, until some other part of the network becomes the bottleneck?

**Dave Harding**: Absolutely, absolutely.  René didn't study that specifically.
He assumed a steady state network for the purposes of research.  But he strongly
emphasized that larger channels are much less likely to become depleted.  Like
you said, because of the relative difference between the channel amount and the
payment size, it's just less likely.  And you get that with channel factories.
You also just get the fact that every channel in a channel factory can, in
theory, through offchain rebalancing within the factory, support the full amount
of the channel factory.  So, not only do you get one larger channel in a channel
factory, you get however many channels you have in that, how many different
relationships there are between routing parties in that factory, that many
different channels, which all can support the maximum capacity, if everybody's
online and able to rebalance, and all the other conditions that we have for
channel factories.

But yes, larger channels are less likely to become depleted.  He found, I don't
want to talk too much, but I believe he found that using the forwarding
algorithm, or the pathfinding algorithm that he used, which is based on his own
Pickhardt Payments algorithm, because he didn't study the exact implementation
in the various LN implementations, but using his idealized function, he found
that the total value of a channel was much more important to its resistance to
depletion than the fees.  Fees weren't as important.  So, it wasn't something
that a channel operator could just tweak their fees a little bit and prevent
depletion.  Having a lot more funds in that channel would help more than
tweaking fees.

**Mike Schmidt**: One other point that came up in the discussion towards the
end, I think Christian Decker brought this up that, "Hey, this is great research
and simulation and theory.  What sort of real-world data do you have, or what
sort of real-world data would be useful to confirm this?"  And I believe René
mentioned, and we put it here at the end of the newsletter summary, that he
would be looking for data from LSPs to help validate his findings.  Any comment
on that Dave?

**Dave Harding**: Yes, he did, and if you are an LSP or you're somebody who has
a lot of channels, or for any reason you might have special insights inside
these discussions and you can provide data that you feel is sufficiently
anonymized to René, I would highly encourage you to, because he's been doing a
lot of research here.  And through Pickhardt Payments and through research like
this, we have ideas for how to make significant improvements to the LN.  So,
being able to test his assumptions against real-world data would be just
fantastic.

_Poll of opinions about covenant proposals_

**Mike Schmidt**: I think we can wrap up that news item and move on to the next
topic from the newsletter, which is, "Poll of opinions about covenant
proposals".  Floppy, you posted to the Bitcoin-Dev mailing list, and I believe
I've seen screenshots on Twitter and publicity around this Wiki entry, that is
essentially a survey of developer opinions about the different covenant
proposals that have been discussed for the last couple of years.  Do you want to
talk about your goal, what you're trying to achieve with this page and how the
response has been so far?

**Floppy Disk Guy**: Sure.  Hi everyone.  Let me start with the idea why I
wanted to do this.  So, we have been discussing different proposals since last
two years and there's no clarity about the expectations and what exactly are
developers looking for, and there's a lot of mess on Twitter.  And we were just
going in circles and it was never going to be something which can be resolved on
social media.  So I thought, let's create a Wiki page and get some clarity on
the different opinions and try to review the proposals.  It's not just opinion
poll, which would be just voting for the proposals, but I actually wanted the
different developers to review the proposals.  But if you would ask the
developers to actually open the PR and review those proposals, I don't think 40
developers would show up and review the proposals.  So, this was kind of a
different way to get the reviews done for these proposals.  And I think 15
developers have already added a rationale for their opinions in the table.

So, that was the initial idea, and I think we already have some clarity, and you
can look at the Wiki page and analyze different columns and rows to see what
exactly are developers looking for.  Like, the first thing you see in that table
is that nobody has any opinion against CHECKSIGFROMSTACK (CSFS), but it cannot
be used alone.  It has to be used in combination with other opcodes, like either
CHECKTEMPLATEVERIFY (CTV) or TXHASH or CAT.  So, you can analyze different
things from this table and I think it makes it easier to get to some kind of
technical consensus from here.  I mean, it's not the final thing.  This can be
discussed further on mailing list, but I think this helps and it's better than
discussing everything on Twitter or other social media.

**Mike Schmidt**: It's difficult to verbalize the table here in a podcast, but I
would invite everybody to go to that Wiki page titled, "Covenants support", and
there's the different proposals as columns, and then individuals who have
expressed some sort of evaluation of each proposal as rows, and there's
'evaluating', 'no', which doesn't support, 'deficient', 'weak', 'wanting',
'acceptable', and 'prefer' as the different labels that can be put for each
proposal.  And then, yeah, recently, Floppy, you mentioned this, there is now
also a rationale column that would link to a little bit more in-depth analysis
if somebody wishes to dig a little bit deeper than just these labels.  How has
feedback been in your interpretation, Floppy?

**Floppy Disk Guy**: I think feedback has been good.  If you look at the mailing
list, there were some suggestions from Jonas Nick, and I made some changes in
the table.  There have been a few other changes based on the feedback, but I
don't think it's possible to change everything at this point, because we already
have 40 evaluations in the table and if you try to change everything, it would
just break the whole table.  And the other thing is, at least people are
discussing the technical things involved in these proposals now, compared to
earlier.  And I think this momentum or the discussion after this on mailing
lists would help us to get to some kind of consensus, what should be the next
soft fork, or what should be the combination of opcodes that we use for
covenants.

**Mike Schmidt**: Dave, Gloria or Mirch, do you have any questions or comments?
Sure, I'll set myself up to be burned as a witch, but I think what sort of
irritates me with this table is that it treats these opcodes as sort of
exchangeable goods.  I think one of the big problems why no progress is being
made on this discussion is that they all are offering a solution that is
slightly different and not completely exchangeable, and they all seem to be
targeting specific problems that are slightly different.  So, there seem to be a
lot of people that are interested in getting better transaction introspection or
covenants, but exactly what they're trying to achieve with that or how they want
to achieve it, what their concerns are, are very different, and I think that is
very hard to express in a table like that.  Sure, the rationale probably
provides a little more information, but yeah.  So, my heretical belief would
still be, these people that are also interested in covenants could help the
broader community a lot to get interested by clearly defining what problem
they're trying to solve and how the solutions, and we're talking here about a
dozen solutions with a new one every two weeks, actually address that problem,
and how they compare in addressing that problem.

So, I think that a lot of the developers at least don't really engage much with
this discussion, because the people that are so interested in the topic have not
come to agreement among themselves.  There's no clear suggestion how we should
move forward.  So, if this is an attempt to get a decision within the people
that are very interested in covenant and/or to make progress, it sure looks like
a different approach, and that's a good thing.  I think that the overall problem
remains to be that we might need to define what problem is being solved.

**Mike Schmidt**: Floppy, any -- oh, Gloria, go ahead.

**Gloria Zhao**: Sorry, is it okay if I talk?  Yeah, I mean, I appreciate the
effort to try to get people to talk.  I don't really see anyone who works on
Bitcoin Core on this list, so I'm not sure if that worked.  I kind of agree with
Murch, where it feels like this table is a little bit like having a table of
people voting if they like hammers better or saws or drills or Swiss army knives
or circular saws.  And it's like, well, what are we trying to build here with
these tools?  Sure, if it's a nail, a hammer would be great.  And saying like,
if you have a hammer, everything looks like a nail.  I feel like if I were to
make some changes, it's more meaningful for people to vote on what they want to
build.  Do you want to build a birdhouse or a chicken coop, or the list goes on.
Like, are people really invested in creating some kind of ZK-rollup bridge or do
they want to make timeout-trees or do they want to make channel factories?
Like, are these the things that people want to build, and then maybe there's a
more clear solution, or the most elegant way to build those things.

Also, sorry to be very critical, I don't think it's very meaningful to have any
kind of vote without rationale.  I assume there's no authentication for any of
these names.  And I don't really care the names of the people who have these
opinions, I care about their rationale, right?  So, I don't know, if I were to
change this table, that's what I would do, but I appreciate the effort to try to
get more people on the same page.

**Mike Schmidt**: Dave or Floppy, any follow-up?

**Floppy Disk Guy**: Yes, I would like to respond to these two things.  I agree
with Murch that we can do better to explain the use cases and what exactly are
we trying to solve.  I think we have tried a lot of things with different other
websites, not exactly Wiki pages, but I think we can do better.  The next thing,
it's not true that you don't have anyone in this list who has contributed to
Bitcoin Core.  I can see at least five people who are Bitcoin Core contributors
in this list.  And since Bitcoin is not just about Bitcoin Core, I think
opinions of other people, other people that are building on Bitcoin and working
on different projects, also matter a lot if you consider consensus proposals.
Yes, this table can be improved and I would work on other things.

**Mike Schmidt**: What do you think, Murch, we can wrap up?  All right,
excellent.  Floppy, you're welcome to stay on.  Thanks for joining us, but if
you have other things to do, we understand and you're free to drop.

**Floppy Disk Guy**: Thank you.

_Incentive-based pseudo-covenants_

**Mike Schmidt**: Next news item from the newsletter is entitled,
"Incentive-based pseudo-covenants".  This is a paper by Jeremy Rubin, who was
unable to join us today to express his idea that he posted to the mailing list
about oracle-assisted covenants.  Luckily, we have on the line Dave Harding once
again.  Thanks Dave.

**Dave Harding**: So, we actually we have two separate threads from the mailing
list in this one item.  So, a covenant is a way to restrict how Bitcoin funds
can be spent, and we've always known that you could do a pseudo-covenant with an
oracle, so somebody who will only sign the transaction for you if it follows the
rules that you want it to follow.  This is a very flexible design, but it
requires trusting the oracle to only sign for you when they're supposed to.  We
have two different designs in this item for how to reduce the amount of trust
that we have to put in the oracle in that case, where we're having a
pseudo-covenant enforced by an oracle.  Jeremy Rubin suggests we have the oracle
and we have a separate oracle called the 'integrity oracle', who makes sure the
signing oracle is doing their job.  And they use something like BitVM, which is
a two-party contract protocol to ensure that the signing oracle is doing their
job.  And if they aren't, the integrity oracle, the one who's verifying stuff,
can take money from the signing oracle.

So, the signing oracle puts up a bond, says, "I swear to only sign these
transactions based on the policy that you set", and the integrity oracle checks
all that.  And if the signing oracle didn't do their job, then the integrity
oracle can take money from the signing oracle.  Now if you're a user of this
protocol, you're still trusting those parties.  You're trusting two parties, or
potentially multiple parties if there's multiple integrity oracles and multiple
bonds involved, but there's still some level of trust here.  However, it is a
good way to explore covenant design and to build protocols for, at least in my
opinion, protocols for low-value and medium-value transactions.  I would be fine
trusting a few hundred dollars to an oracle in order to explore covenant design
space, to find protocols that are useful, that kind of stuff.  And in this case
where we have integrity oracles, if you lose money because the signing oracle
violated your policy, the integrity oracle might be able to return that money to
you from the bond.  There is no requirement for them to do that, there is no way
to force them to do that, but it could happen and so you could have a pretty
good amount of insurance.

The second threat that we summarized here was from Ethan Heilman, and he
suggested a different construction.  It still uses BitVM, and the difference in
this case is that anybody can dispute the signing oracle's actions.  Anybody can
say, "No, you didn't follow my policy".  However, in this case, if the fraud is
proven, the funds don't go to the person who proved a violation, the funds are
just destroyed.  We send them to a future miner or we just send them to an
OP_RETURN output and destroy them forever, or whatever.  And so, there's no way
that a victim could get their funds back.  However, it's maybe slightly less
trusted.  Again, you can still have funds stolen from you, so it's not
trustless, but it's more trust-minimized.  Again, this is probably good for
protocols involving relatively small amounts of value, because you could always
lose your value in this, even if you, as a user, did everything right, just
because you're trusting somebody else.

So, these are two interesting designs for what I'm calling pseudo-covenants or
oracle-assisted covenants.  They're not trustless, they're not true covenants,
if you will, but they are useful tools, I think, for experimentation.

**Mike Schmidt**: I don't have any follow-up questions on that one.  Murch,
looks like you're good.  Dave, thanks for summarizing that.

_Bitcoin Core developer meeting summaries_

Our last news item this week titled, "Bitcoin Core developer meeting summaries".
This news item covers a Bitcoin Core developer meeting that happened in October.
These periodic meetings happen in person and there were a bunch of notes
published to the btctranscripts, so the Bitcoin Transcripts page, and we link to
that root page, as well as some of the individual topic discussions.  So, if
you're curious about some of the things that are being discussed by Bitcoin Core
developers, we list a bunch of them here: payjoin support, mining interface,
benchmarking, libkernel, block stalling, RPC improvements, erlay, discussion of
covenants, multiple binaries.  So, take a look.  There are notes that were
compiled by the participants of those discussions.  In previous meetings and
other meetings, we have more in-depth notes by a designated notetaker, who's
quite fast with a keyboard, who wasn't there or here, so the notes are maybe
perhaps a little bit sparse.  But I think even just seeing the types of topics
that are being discussed is probably good for people who are curious about what
Bitcoin Core developers are occasionally talking about, or at least some subset
of that.  Murch, anything to add?  Okay, great.

_Track and use all potential peers for orphan resolution_

Our monthly segment, Bitcoin Core PR Review Club, "Track and use all potential
peers for orphan resolution" is a PR by our very own Gloria, who's here today,
and it improves the reliability of orphan resolution.  I'll pause there and let
Gloria take the torch and maybe explain what are orphans and what's wrong with
orphan resolution currently.

**Gloria Zhao**: Sure.  An orphan transaction refers to an unconfirmed
transaction that you would receive on P2P network, where it's missing an input.
Like it's a UTXO from a transaction that you've never seen before.  Of course,
it's possible that this UTXO just doesn't exist, but most often it's because it
has a parent that you haven't seen before, an unconfirmed parent.  And this
orphan-handling process has existed for, I think, at least ten years, but it's
very opportunistic.  It's kind of best effort.  We're not expecting it to be
reliable, but it is fairly unreliable.  So, the problem that we're trying to
address in this PR is we only try to resolve the orphan from one peer.  And by,
"Resolve the orphan", I mean that we look at the inputs that we're missing by
txid.  The prevout contains the txid of the transaction.  And we ask the peer
that sent us this orphan for the transactions corresponding to these txids.

Of course, BIP331 has a different protocol for resolving orphans, but today the
only thing that's implemented in Bitcoin Core, at least, is to ask for parents
by txid.  But we will only ask the peer that sent us this orphan for the
parents, and if they disconnect or they fail to send it to us, they send us a
not found, or they just stall, we just give up.  And we don't remember who else
might have the orphan's parents, and this can be kind of just unreliable in
general.  But also, you can imagine that if an attacker is able to be the first
person that sends you the transaction, and then they just drop your request on
the floor, then that can prevent or at least delay you from downloading this
transaction.

There's two things that exacerbate this.  One is, nodes are allowed to send
unsolicited transactions.  So, if all of the honest peers are using the normal
method to announce transactions to you, wait for you to request them, and then
send you the transaction data, then it's easy for me to get ahead of everyone
and jump the queue just by sending you the transaction first.  And then you'll
say, "Oh, okay, it's an orphan, can you send it to me?"  So, that's one problem.
So, it's kind of easy to do this attack.  The other problem is with the 1p1c
(one-parent-one-child) opportunistic package relay that we have, we kind of rely
on orphan resolution to be part of the process.  So, the low feerate parent, at
least if fee filters are being used, will never be sent, and you'll always have
the child as an orphan first, and then you'll request the parent, and then
you'll put them together as a package.  But if you are stopped from requesting
the parent from the peers that could send it to you, then you're never going to
download this package.

BIP331 works this way as well.  The idea is, it's a very receiver-initiated,
ancestor package retrieval protocol.  So, it's not inherently better at this, at
making sure that you can reliably download packages, it's just a new way of
communicating what ancestor transactions are.  And so, this problem is very
relevant to the 1p1c package relay we have today, and also necessary for any
kind of receiver-initiated package relay that we might have in the future.  And
so, this is like a building block as well as a bug fix, as well as, you know,
it's good stuff; that's what I'm saying!

So, the way that we address this problem is we track and use all of the peers
that could provide us with an orphan resolution.  And the way that we determine
that is, anyone who announces this transaction to us, this orphan transaction,
before we received it and after, we know that they must have the parents.
Otherwise, how did they validate this transaction?  And so, we keep this in our
orphan resolution tracker, or at least we can remember or treat it as if they
had announced all the parents to us, essentially.  And so, if the first parent
doesn't respond or sends a not found, etc, we still remember all of the other
peers that could have provided this for us.  And we also bake in some of the
existing preference logic for transaction download.  So, for example, if we had
like three announcers of this orphan and two of them were outbound peers and one
of them was an inbound peer, then we're going to try to request from the
outbound peers first.  And that's good.  And that's, of course, much better than
what we have today, which is we just request whoever sent it to us, and that
could be an inbound peer, right.

So, this is just better in many ways.  The approach actually that we talked
about in the PR Review Club is a little bit more aggressive than what the PR
looks like now, and it's kind of the result of this Review Club discussion.  I
think it was a really great Review Club.  I think we went through a lot of the
interesting logic, all the links to the code are there, and we actually did two
sessions because there was quite a bit of interest.  So, yeah, PR Review Club's
great.  Please come if you're interested in learning about transaction relay,
and things like this.  And it was really productive as well.

**Mike Schmidt**: Gloria, excellent overview of the motivation and the mechanics
involved here.  Murch, I think you had something to say before I double-click on
one of these things.

**Mark Erhardt**: Yeah, I had a question.  So, could you remind me whether we
track orphans or are limited in how many orphans we keep across all peers, or
whether we store them per peer; and has that changed recently?

**Gloria Zhao**: Good question.  We have a global limit of 100 transactions in
the orphanage.  This is also a source of pain and unreliability for orphan
resolutions, and it's what I would want to tackle next after this PR.
Basically, the package relay project is currently at this stage of just
orphan-handling robustness, which includes this.  It includes being better about
tracking how much of the orphanage space each peer is using.  So for example,
today, if we reach our 100 limit, we just evict randomly, which means that if we
have, let's say, one inbound peer who is sending us loads and loads and loads of
orphans, they can turn through our orphanage and actually prevent us from being
able to use it in a useful way.  And ideally, we have some kind of way to rate
limit per peer.  Of course, now that we will have multiple peers per orphan
that's being tracked, we would say like, "Oh, well, this orphan has been
provided by 3 of our outbound peers, and these 50 are all provided by the same
inbound peer".  That obviously would be, it's very obvious to us, we should
probably have a better way of assessing those.

Then, on top of that, we can try to, let's say, guarantee orphanage usage for
maybe our outbound peers.  And that would make, for example, the package relay
stuff reliable, because we could actually guarantee that as long as we give
enough room for outbound peers, as long as there's an outbound peer that has
this package, we will download it.  Even in the presence of lots of adversaries
trying to turn the orphanage, trying to be the first to announce, trying to be
chosen as the resolver, etc, then we won't have any of these issues anymore.
So, yeah, Murch, you're correct.  I have a Dev-Wiki page on the Bitcoin Core Dev
Wiki called, "Known TX Orphanage Problems", and it lists a lot of these things.
So, this is like number two.  Number one, which we covered a few months ago, was
the fact that we track them by txid.  So, an attacker could send a witness
mutated version, and then you wouldn't replace that in your orphanage, and then
you might have trouble actually downloading stuff.  So, yeah, we're in the
60-orphanage stage of package relay.

**Mike Schmidt**: Gloria, what I was going to ask, there was one of the
questions in the writeup that referenced whether the data structure for the
orphan resolution tracker was required or not, and there was a suggestion for a
different approach.  You also mentioned that the PR in its current state is
slightly different.  Are those two related?  Did you consider this alternate
approach?

**Gloria Zhao**: Yeah, that was the approach that changed.  So, the original
implementation that I wrote was the BIP331 implementation, where we have two
methods of doing orphan resolution.  One is requesting parent txids and the
other is requesting ancestor package info using the BIP331 protocol.  And so, in
that world, I kind of determined that this data structure, this specific one
called TX Request Tracker, would be the appropriate one to use.  And so, when I
implemented it, this is what happened.  And since then, we've kind of reordered
which pieces of the project we want to merge when.  And so, now we aren't adding
BIP331 yet, but we are adding the orphan resolution tracking system.  But
actually, that data structure is not quite necessary yet.  And we have a much
simpler solution now, and that was discussed during the meeting.

**Mike Schmidt**: Very cool.  It's nice to see not only maybe junior developers
or developer-curious folks joining that meeting and learning, but also some
dialogue that has resulted, and I know this has happened before, in tangible
changes to the PR.  It's pretty cool to see.

**Gloria Zhao**: Totally, yeah.

**Mike Schmidt**: Gloria, there is a Bitcoin Core PR later that may be
interesting too.  If you stay on, obviously you have a lot of things to do and
we understand if you need to drop.  Thanks for joining us though.

**Gloria Zhao**: Thanks for having me.  I am going to drop, but I'll see you
guys.

**Mike Schmidt**: Okay, we'll see you, Gloria.  Changes to services in client
software.  We did one just a few weeks ago, so there wasn't a ton here, but we
did have four that we thought were interesting.

_Java-based HWI released_

One is a Java language-based HWI implementation.  There's actually two pieces to
this.  There is the Lark Java library, which is a port of HWI for the Java
programming language, which is sort of the underlying Java library to do
hardware wallet integration stuff; and then there's this Lark app, which is
built on top of the Lark Java library, which is a command-line application for
interacting with hardware signing devices.  I believe HWI is Python, so this is
a Java port of that and then a command-line app.

**Mark Erhardt**: That's cool.  I know that Ava has been looking for someone to
also produce an HWI or take over the project.  So, if this is it, that would be
amazing.

_Saving Satoshi Bitcoin development education game announced_

**Mike Schmidt**: Next piece of software, "Saving Satoshi Bitcoin development
education game announced".  So, there's this Saving Satoshi website, and it's
sort of a fun and somewhat graphical way to answer questions and run some sample
code and discover a little bit about Bitcoin development in a much more
approachable way.  The URL is savingsatoshi.com and I think that there was a
presentation or some discussion at TABConf about this, and anything I think that
would be top of funnel for Bitcoin developers is much appreciated.  So, if
you're curious about toying around with the technicals, it's just open-source
free site to interact with.  So, it's a very at your own leisure way to explore
some of the development side of Bitcoin.

_Neovim Bitcoin Script plugin_

Neovim Bitcoin Script plugin.  I believe that the title of this plugin is
Bitcoin script hints for Neovim, and it is specifically for the Rust programming
language.  And it will show, based on your code, the different script stack
states for each operation of Bitcoin Script within your IDE, within the Neovim
IDE.  So, it's pretty cool.  Check out the link from the newsletter.  I believe,
yeah, it is on the GitHub there.  There's a little animated gif of what it would
look like for you to interact with it.  I don't know how many people are using
that exact Rust and that exact IDE, but it seems pretty helpful if you were to
be doing that.

**Mark Erhardt**: Yeah, I think Vim is very popular and most people probably use
Neovim these days because it's been the most actively developed client, I think.

**Mike Schmidt**: Don't start a war!

**Mark Erhardt**: So, well, that might all be clouded by personal perception.
There's also the whole Emacs versus Vim.  But anyway, yes, this is probably
fairly accessible if you do like Vim.

_Proton Wallet adds RBF_

**Mike Schmidt**: Last piece of software we highlighted was the Proton Wallet
project adding support for users to be able to fee bump their transactions using
RBF.  Pretty self-explanatory.

_How long does Bitcoin Core store forked chains?_

Selected Q&A from the Bitcoin Stack Exchange.  We have three this week.  "How
long does Bitcoin Core store forked chains?"  And I actually think we had a
similar question in the past few months, but it wasn't quite as direct.  But
Pieter Wuille answered this question, explaining that, with the exception of a
Bitcoin Core node running in pruned mode, that any block that a node downloads,
regardless of whether it's part of the main chain or not, are stored
indefinitely.  I think maybe the emphasis here is 'a block that a node
downloads'.  So, that would mean if you're syncing a new node from scratch,
you're not going to get all those historical pieces of block data that aren't
actually in the main chain.  But moving forward, as your node is active on the
network, you may have a block that ends up not being in the main chain, and it
sounds like that is then kept indefinitely.

**Mark Erhardt**: I think it is strictly also possible that you happen to get a
block from two peers at the same time.  So, you might even have a duplicate of
the same block.

**Mike Schmidt**: So, even if it's the exact same block and you get it from two
different peers, it's...

**Mark Erhardt**: I think I saw something that that can happen.

_What is the point of solo mining pools?_

**Mike Schmidt**: Okay.  "What is the point of solo mining pools?"  Murch, you
answered this question and basically defined a solo mining pool and why someone
might want to use it.

**Mark Erhardt**: Yeah, basically there's a chain of components that you need in
order to run hash hardware these days.  One is, of course, an ASIC, because GPU
and CPU mining hasn't been profitable in almost a decade now, or probably more
than a decade now, actually, sorry!  Anyway, so these application-specific
integrated circuits, they are only good at one thing, and that is mining blocks.
And that is based on SHA256D.  And most notably, they're not general computers,
so they can't do many of the things that computers do.  For example, ASICs
usually cannot build block templates.  So, at the very least, you need to run a
full node that keeps track of the mempool in order to know what the unconfirmed
transactions are that they can put into block templates and builds block
templates.  But then also, Bitcoin Core can't really directly talk to ASICs, as
far as I know, so you need another piece of software in between that talks to
your Bitcoin Core that controls the ASICs and provides the updates to the ASICs.

I think I've never really dabbled too much with mining, so present people, if
you know more, please correct me.  But my understanding is that essentially,
setting up this whole tool chain requires a bunch of software and services that
run around the clock, and it's complicated.  And some people just choose to have
only the hashing hardware at home.  And then generally, they would usually join
a mining pool in order to smooth out their revenue.  When you just mine with a
single ASIC at home, the likelihood that you find a block is extremely low, and
it could run for years.  You'd be paying for electricity for years, maybe even
have to fix some parts on your hardware without ever getting revenue, and then
with a minuscule chance, at some point win a whole block by yourself, and maybe
then it was all worth it.  But most likely, you're never going to get a block at
home.

So, most people actually join mining pools in order to contribute towards
finding a block, and the mining pool measures then how much hashing is being
done by the participant and gives them revenue according to the contribution,
even if they weren't exactly the miner that found the block.  Now, some people
do run sufficient hardware at home that they occasionally do find blocks and
they do not require this smoothing, so they might be interested in minimizing
the overhead that they pay to the mining pool, or they just prefer the lottery
style, "Do I win or do I lose?"  And they would then maybe join a solo mining
pool where they have all their hashrate mining on block templates provided by a
third party.  I think they still pay a fee for the solo mining pool, otherwise I
don't see why the service would be providing that service.  But they don't share
the reward if they win.

So basically, a solo mining pool is a way of outsourcing the tracking of
unconfirmed transactions and the building of block templates, and still allows
you to not be part of a mining pool that might, yeah, if that's your preference.
Dave, I saw you nod and comment basically non-verbally here.  Do you have some
additions?

**Dave Harding**: Yeah, everything you said was correct.  I looked into this a
little bit, specifically related to the LN vulnerability that I talked about
earlier in the podcast.  And, yeah, it's like you said, people just don't want
to run the software stack that allows them to send work to their miners.
Jameson Lopp talked about this recently.  He tried to set up Stratum and run a
bunch of testnet servers using rented hashrate, and he found it to be a pain in
the butt.  And so, we have an experienced person like that who is having
challenges doing it.  You can imagine that it's a fair bit of work to run a
mining pool.  And people who have, like Murch said, enough hashrate to find a
block in a reasonable amount of time, but who don't want to do the work of
setting up a pool themselves, they can just use a solo mining pool that takes
0.5% or 1% off the top, and it's worth it to them.  So, that's all that's going
on here.  It is interesting.

Sometimes people will rent hashrate and use them with a solo mining pool.  And
I'm not quite sure why you would do that, unless there's some non-standard
transaction or something that you want to mine.  I suspect something to do with
ordinals, because that's always the culprit in these things.  But yeah, solo
mining pools are a thing.  The big one is run by CK who made some mining
software.  So, they're out there, they're a thing.  It does make some logical
sense, even though it is a little obscure.

**Mark Erhardt**: I thought you brought up a great point right there.  If you do
want to have a customized block template, I would imagine that a solo mining
pool would give you access to how exactly a template is constructed.  So, you
might be able to call prioritisetransaction and then sort of get more control
over it than when you participate in a mining pool, but less control, of course,
than if you run the whole stack.

_Is there a point to using P2TR over P2WSH if I only want to use the script path?_

**Mike Schmidt**: Last question from the Stack Exchange, "Is there a point to
using P2TR over P2WSH if I only want to use the script path?   Vojtěch answered
this question and I believe he referenced the potential cost savings and the
economics, and I think that was answered by Murch at some point in the past, so
Murch can maybe elaborate on that.  But Vojtěch also pointed out other benefits
of P2TR, including the privacy benefit, because some of the potential scripts
could be hidden using a tree of scripts.  And particular to this person's
question, which was about HTLCs in this example, Vojtěch also mentioned the
availability of PTLCs (Point Time Locked Contracts) for this person.

**Dave Harding**: I didn't read the question, but I will note that PTLCs would
be a lot cheaper with P2TR because you're just using a signature rather than the
whole scriptpath.  So, that was a definite win there, but I didn't read it, so
I'm sorry if this was already mentioned.

**Mark Erhardt**: Yeah, so basically what it boils down to is that P2TR outputs
have both options, the keypath option and the scriptpath option.  And spending
from the scriptpath adds a little bit of overhead, because you first have to
reveal what the internal taproot key was that was tweaked with the merkle root
of the script tree in order to create the external public key, which is the one
that you see in the output script.  So, if you are always going to use the
scriptpath, indeed there is a cost advantage if you know exactly which leaves
you will always be using, you should just stick to P2WSH.  If you, however, want
to have the option between multiple leaves, or if you sometimes can fall back to
using the keypath because all the involved parties are happy to sign off, then I
believe that P2TR will provide you more flexibility and might even be cheaper
most of the time.

_Core Lightning 24.11_

**Mike Schmidt**: Releases and release candidates.  Core Lightning 24.11.  I
think we mentioned, Murch, last week that we were going to try to get somebody
on to jump in and explain this release, from the Core Lightning (CLN) team.
Unfortunately, nobody could join us, but I did get a bullet point list of notes
of things that Christian Decker specifically thought were most useful and
interesting.  So, I will read off some of those as we go.  If you either of you
want to have a comment, just signal to me that you want to jump in.  Christian's
list is, BOLT12 is now enabled by default.  Expired BOLT12 invoices can now be
decoded, and previously there was an error with that.  There is a list here of a
bunch of gossip-related changes.  CLN now keeps a connection pool open to its
peers, which they get gossips from.  CLN sends their own gossip more
insistently.  CLN also asks for gossip much more aggressively now.  Under
certain circumstances, gossipd could miss the spend notification of a channel at
startup, causing stale gossip in the view, and that's been fixed.  There's
improvements to the gossip store, removing the 2 GB limit on the file and fixing
a crash caused by that.

A new payment plugin that we've discussed here on the show, xpay, along with
askrene, it replaces renepay, the idea being that xpay executes what askrene is
planning.  And he notes that it frees up future payment plugin implementers from
having to do both, like getting the actual proposed and then actually executing.
There's a couple more updates around splitting renepay into askrene and xpay, to
minimize the effort to try to route and implement new routing logic; much
improved fee handling, and also respects the fee budget; several performance
improvements to start the payment earlier; a bunch of API changes, including a
new onionmessage_forward_fail notification related to the API; inject onion
message allows sending an onion message in its encrypted form, which is useful
if CLN wants to reattempt forwards as well; a new RPC method for listaddresses
that lists all previously generated addresses; the grpc interface is now being
started automatically on port 9736.

Splicing, a few splicing things.  He mentions closing the gap between the
experimental implementation and the spec draft, even though the spec is evolving
in parallel with the implementation; dev-splice can now use splice script to
plan complex changes.  And we had Dusty on and talked about a lot of this as
well on a previous show.  Many, many, many, three manys, performance
improvements for very large and very small nodes, including better queuing for
inter-process communication as well with peers, and better use of CPU and
network resources, etc.

Well, I thank Christian for providing that writeup.  I'm sure that me reading
that list isn't quite as engaging as Christian or Rusty, or the like, explaining
it, but I hope that gives you all a flavor of what's coming or what's here in
CLN.  You can jump into the release notes and poke around for yourself.

_BTCPay Server 2.0.4_

BTCPay Server 2.0.4.  There's a few things that I pulled out of this release.
One is a feature that adds a QR code with a link to an invitation email; there's
improvements to the store users' API; there's eight bug fixes, as I counted
them, and seven, as I counted them, notable improvements, including some
usability improvements as well as plugin improvements.

_LND 0.18.4-beta.rc2_

LND 0.18.4-beta.rc2.  We covered RC1 last week, and in the RC notes it says,
"This is a minor release which shifts the features required for building custom
channels, alongside the usual bug fixes and instability improvements".

_Bitcoin Core 28.1RC1_

Bitcoin Core 28.1RC1.  We talked about this one last week.  Murch or Dave,
anything to iterate here, other than encouraging folks to test the RC?

**Mark Erhardt**: Especially if you run other software or write other software
that relies on Bitcoin Core downstream, it would be lovely if you could test the
compatibility.  On a minor release, I think that is less often an issue, but
we've had some issues where Bitcoin Core releases in the last year haven't been
tested by major other projects before the release, and then discovered minutes
after the release that there were issues.  So, we could all save a little
trouble if people do the testing before the release.

_BDK 1.0.0-beta.6_

**Mike Schmidt**: BDK 1.0.0-beta.6.  We've covered the slew of betas as they've
progressed.  This is the last planned beta test release to get to BDK 1.0
official, and we will reach out to a BDK contributor once 1.0 is out the door to
celebrate the release.

_Bitcoin Core #31096_

Notable code and documentation changes.  Bitcoin Core #31096.  My notes have,
"Gloria?"  I was hoping she'd be here for this one, but I did review this as
part of the newsletter PR, and it removes restrictions on the submitpackage RPC,
and you can now provide a single transaction to submitpackage.  Murch or Dave,
did you understand the motivation for this?  Is this just, if you're using
Bitcoin Core, you can use one RPC command now instead of toggling between two if
you have a single transaction?

**Dave Harding**: That's it.  There's no reason that you should be forced to use
a package with this.  I mean it has package in the name, but why not allow it to
send single transactions?

**Mike Schmidt**: Makes sense.  And I assume the code paths result in the same
sort of logic being executed then.  Okay.

_Bitcoin Core #31175_

Bitcoin Core #31175, removing redundant pre-checks from submitblock RPC command.
Murch, did you get a chance to dig into this one on your commute?

**Mark Erhardt**: I did try to take a look at it.  It was a little denser than I
anticipated.  My understanding is that this cleans up the interface internally,
how blocks are being processed, and just deduplicates some of the checks.
That's frankly basically what I figured out so far.  But yeah, Dave, did you
happen to have another look at this one?

**Dave Harding**: I saw basically the same thing as you.  I think it was worth
noting just because it could be an API change.  Some stuff here that you might
have expected to happen before, might be happening later on in the process.
Like it says here in the notes, it's deduplicating stuff.  But it could be a
change, and we like to just note potential API changes.  Because somebody who's
really depending on this, and if you're a miner, submit block is your RPC, you
want that to run fast and quick, this is something that you might want to test.

**Mark Erhardt**: Well, I would hope that specifically, all the same checks are
being run afterwards.  And if the RPC itself didn't change, hopefully you
wouldn't be able to notice much of a different behavior.  But yeah, so if you're
working on mining interfaces, you're probably already aware on this one, or if
you've been following the kernel library development, but it seems pretty under
the hood here.

_Bitcoin Core #31112_

**Mike Schmidt**: Bitcoin Core #31112 extends CCheckQueue functionality.
Essentially, there's improvements to script error logging in during
multi-threaded validation.  Murch, I'm not sure if you got a chance to dig into
that one.  Hands are up.  Okay, it sounds like before this change, you only got
detailed error reporting when you were running a single threaded variant,
whereas now the logging includes details even when you're running in
multi-threaded script validation, par≠one.

**Dave Harding**: Yeah, so I suspect a lot of people are running multi-thread on
Bitcoin Core, especially in production applications.  And this just means they
could be getting more errors than they used to expect.  So, again, I wanted to
highlight in the newsletter, because if you start seeing errors pop up, and
script validation does fail sometimes, you get wonky scripts, if you weren't
getting errors before, you might start getting errors now.  So, I just wanted to
make sure we highlighted that.

**Mike Schmidt**: We also noted that, in addition, the logging now includes
details about which transaction input had the script error and which UTXO was
spent.

**Mark Erhardt**: That sounds immensely useful.

_LDK #3446_

**Mike Schmidt**: Yeah, I would imagine.  LDK #3446, this is a simple PR that
flips on support for the trampoline feature flag for BOLT12 invoices in LDK.
And this PR is part of LDK's tracking issue for trampoline support, which is
tracking issue #2299 on the LDK repository.

**Dave Harding**: So, LDK is working on trampoline payments.  Eclair has
supported those and pioneered them for a long time.  But LDK is working on that
as part of trying to get a new type of async payments to deploy.  So basically,
the payment will be able to, I believe in this design, it's held at the first
trampoline hop, which is probably going to be your LSP if you're a client.
Then, when your LSP hears that the recipient is online, via an onion message,
the trampoline will then send a payment at that point.  So, a user who's not
online right now can still potentially receive a payment from somebody who is
online at a later time.  So, this is a clever way of using the existing
protocol, including its limited support for trampoline payments, to enable async
payments.  So, I am glad they're are working on that.

**Mike Schmidt**: Thanks, Dave, for the context.

**Mark Erhardt**: What is really cool about what Dave just described is, if you
imagine that an LSP is involved here, so let's say you have a mobile phone
wallet and you're connected to an LSP, your channel with the LSP from your
mobile phone will only ever be active while you're online anyway, right?  So, if
you start sending a payment and separate the invoice, or deliver an invoice via
BOLT12 to the recipient in the first place, then initiate the first hop of the
payment, or the multi-hop payment contract setup, you can go offline.  It only
affects your channel with the LSP anyway, where you will not have any activity
while you're offline, and then the rest can be resolved by the trampoline when
the recipient is online, and the trampoline itself will be online all the time.
So, this is really cool, because sometimes it had been hard to get Lightning
payments to go through, especially between two intermittently online people.
Usually, you know when you're getting paid, but sometimes you don't, right, and
so this can solve it.

**Dave Harding**: Especially with BOLT12 supporting multiple payments, you can
have recurring payments, you can have people with a fixed payment address, like
we talked about the new DNS protocol for LN addresses.  If I owe Murch $5 and I
have his murch.1 address in my address book, I can now just send that to him
anytime.  He can be sleeping, his phone can be turned off, or whatever; it
should work.  So, async payments are great.

_Rust Bitcoin #3682_

**Mike Schmidt**: Rust Bitcoin #3682 is a PR titled, "Add API scripts and output
files".  This PR adds a script to generate API files using the cargo check-API
command, specifically for Rust crates that Rust Bitcoin are trying to stabilize
the API for, which they list as the hashes crate, io, primitives, and units
crates.  It also adds a script to then query those generated API files, and the
script there has three commands: one to show all the public structs and enums;
one to show all public structs and enums excluding errors; and then, one to show
all public traits.  So, there's also, as part of this continuous integration
job, that compares the API code and its corresponding text file to detect any
anomalies or unintentional API changes.  And finally, there's documentation for
how developers are expected to run these scripts when contributing to those
particular APIs.

_BTCPay Server #5743_

BTCPay Server #5743 is a PR titled, "MultiSIG/watchonly wallet transaction
creation flow proof of concept".  It adds the idea in BTCPay Server of something
they're calling a 'pending transaction'.  My interpretation is this is like
BTCPay Server's UX on top of PSBTs, specifically targeting watch-only and
multisig wallets.  "Essentially, the system enables functionality that was
deemed to only be possible for hot wallets".  Dave or Murch, did you get a
chance to dig into this one?

**Dave Harding**: I dug into it a little bit, not a whole lot.  What it's
talking about there in that sentence is, previously if you had BTCPay Server and
you had to send somebody a refund, or you just needed to pay one of your
vendors, or whatnot, you had to have a hot wallet with a system to easily send
those payments, or if you had a hardware wallet set up with BTCPay Server, you
had to go through your own personal cold wallet set up.  Here, they have a
multisig, and like I said, for watch-only wallets where they have a hardware
device, and it's just going to walk you through the steps of sending that.  So,
you can initiate the refund, or you can initiate the payment to your vendor in
BTCPay Server.  And then, as participants in the multisig come online, it'll
prompt them and say, "Hey, did you want to refund Mike $5?  Did you want to pay
vendor Murch $20?" and they'll just click yes or no.  If they click yes, they'll
get a PSBT that they can send to their hardware walls, have it signed, send it
back to BTCPay Server.

So, it's not a fully available option in the user interface right now, I
believe.  It's still being worked on kind of in the background, but it's a way
for allowing multisig to be much more usable in BTCPay Server, and also people
who are using a single-sig watch-only wallet.

**Mark Erhardt**: I'm not sure if I'm putting a bee in someone's bonnet here,
but payjoin originally came out of BTCPay Server circles, and the new payjoin v2
proposal uses PSBTs.  So, I'm wondering whether that is at all related or might
happen eventually, because if you can run your own BTCPay Server, doing payjoins
would be quite viable and, well, I guess you're already online all the time so
you might not need payjoin v2.  But adding support for that would definitely
require PSBT.

_BDK #1756_

**Mike Schmidt**: This PR fixes an issue where querying prevouts of a coinbase
transaction would, when querying the Electrum server backend, cause an error,
which would cause any sort of syncing that was going on to fail.  This is
because the coinbase transactions don't have a prevout, or I suppose, it's just
a prevout of all zeros.  So, it was causing an issue when you were using BDK
with an Electrum back end.  So, the fix here was to add a check.  I noticed we
used the word 'exception' in the writeup, which maybe is an overloaded word in
this context.  But the fix was to add a check in BDK if a transaction was a
coinbase transaction, to not then query Electrum in that case.

_BIPs #1535_

BIPS #1535, which merges BIP348 for OP_CHECKSIGFROMSTACK (CSFS).  Murch, what's
going on here?

**Mark Erhardt**: CSFS, which we previously mentioned in one of the news items,
is a proposed opcode that would pop three items off the stack.  And that is
specifically from the bottom to the top signature, message, and pubkey.  So,
first it would pop pubkey, then message, then signature, and would be able to
check these three items, whether they compound to a signed message in the
context of the pubkey.  Yeah, so this is useful if you want to build various
covenants, or if you want to maybe, for some users of oracles or other things,
get the signature data from the stack instead of in the context of exactly a
transaction with a transaction commitment, that is always composed as you have
to for a bitcoin transaction.  So, it gives you more flexibility for things you
can sign and in what context to sign.

_BOLTs #1180_

**Mike Schmidt**: Last PR this week to the BOLTs repository, BOLTs #1180, a PR
titled, "Include BIP353 name info and invoice_requests".  This PR updates BOLT12
specifically to allow, optionally, a BIP353 human-readable DNS payment
instruction in the invoice request.  And we note a related change that this 353
info was also part of a proposed BLIP, BLIP32.  So, that BLIP was updated to
reference this updated BOLT12 having that field now.  So, it's two for one in
this one.

**Dave Harding**: Yeah.  So, what this allows you to do is say, "The person I'm
wanting to pay is Murch@..." whatever Murch's address is.  And that way if
there's multiple people using the same LN node, the payment can be redirected to
a particular one of them, so a custodial situation, or just a case where they're
sharing nodes with some future channel tech, like multiple signatures, and
whatnot.  But it's just, it's sending additional information to allow the
receiver to figure out who that payment is really supposed to go to and resolve
it from.

**Mike Schmidt**: That's it.  Quite a beast of a newsletter this week.  Thank
you very much, Dave, for joining us and walking through a lot of those news
items for us; thank you to Gloria for joining and chiming in in a variety of
sections and owning the PR Review Club that she hosted; and thank you to Floppy
for representing his Wiki tracker for covenant support.  And thank you, Murch,
as always, as co-host.  Cheers.

**Mark Erhardt**: Cheers, hear you soon.

{% include references.md %}
