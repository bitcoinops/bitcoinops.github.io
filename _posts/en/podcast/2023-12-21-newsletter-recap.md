---
title: 'Bitcoin Optech Newsletter #282: 2023 Year-in-Review Special Recap Podcast'
permalink: /en/podcast/2023/12/21/
reference: /en/newsletters/2023/12/20/
name: 2023-12-21-recap
slug: 2023-12-21-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt, Dave Harding, and Mike Schmidt
discuss [Newsletter #282: 2023 Year-in-Review Special]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-11-27/0daee4d9-3fb5-dbea-71ca-d093b977db24.MP3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #282, a 2023
Year-in-Review Special on Twitter Spaces.  In this special edition, we're going
to review all the notable developments in Bitcoin during 2023.  We're joined
this week by Dave Harding again, as well as my co-host, Murch.  I'm Mike
Schmidt, Contributor at Optech and Executive Director at Brink, funding Bitcoin
open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch.  I work with Chaincode Labs and work on Bitcoin
projects all day.

**Mike Schmidt**: Dave?

**Dave Harding**: I'm Dave Harding, I'm co-author of the Optech newsletter and
of Mastering Bitcoin 3rd Edition.

**Mike Schmidt**: Well, as we get started, I'd like to encourage, even more than
normal, any questions or comments from the audience?  I see some smart people
here.  Since we're reviewing all of 2023, pretty much any topic is fair game.
If you have some nagging question in your mind or some comment, we'd love to
hear from you.  Feel free to request speaker access or comment on this tweet,
Twitter thread, to put in something that we should talk about, that you're
curious about.

_Summary 2023: Bitcoin Optech_

Before we jump into the technical summaries, I actually wanted to jump to the
Optech callout from the year in review.  I know we had that towards the end, and
we don't necessarily love to pat ourselves on the back, but I'm going to take
the opportunity to do so here as we get started.  We noted in the callout that
we had 51 newsletters this year, a 10-part policy series authored by both Murch
and Gloria, 15 new topic pages on our Topics Wiki, over 86,000 words in the
newsletter, which is the equivalent of about a 250-page book.  I think maybe
last year, we had a 200-page book, 250 pages this year.  Also, last year, late
last year, we started the podcast and that's been something that folks have
enjoyed.  So, we've continued that this year with over 50 hours of podcast audio
content and additionally, nearly a half million words of transcripts.  And we've
also gone back and finished transcribing all of the podcasts from last year as
well.

Since we're sort of in the celebratory mood, I wanted to callout Rachel Green,
who does the transcriptions for all of our podcasts.  She is a human being, and
she is familiar with all of this Bitcoin jargon.  It's actually surprising, the
amount of jargon and the amounts of accents that we get with our guests, that
she's able to transcribe these as accurately as she is without much input from
me.  So, there's very few pieces of feedback that I need to provide her on these
transcripts before we get them out to you.  So, if anyone is listening and needs
human transcription work for any Bitcoin video or audio content, I can't
recommend her highly enough.  Feel free to reach out to me, @bitschmidty on
Twitter, or you can just send a message or tweet to the Optech handle and I'll
connect you.

Also, as part of our weekly podcast recaps, we've had 62 different guests
throughout the year.  And I actually feel very lucky that we've been able to get
so many of the original authors of the different research proposals, project
owners, and developers that we highlight in our news sections that we cover each
week.  I feel like we're extremely lucky to have them provide first-hand
content.  I think we do a good job of second-hand digesting some of this, but to
hear it straight from their mouth is super-valuable.

We also had nearly 200 non-English translations of the newsletters this year.  I
believe all of the 2023 newsletters, sans some that are just going to be coming
in through the end of the year here, have been translated into Japanese by
Azuchi, Czech by jirijakes, French led by Copinmalin, and Chinese led by Jeffrey
Hu, who is hulatown, with input from freeyao and editor-Ajian.  We also had two
great field reports this year, one by Brandon Black from BitGo about MuSig2, and
another one by darosior from Wizardsardine about miniscript.  So, that is our
patting ourselves on the back.  Dave, I see we've lost Murch temporarily, so I
don't know if you have any comments on that while I add him.

**Dave Harding**: Just, I'm just really appreciative for all of the people who
came on the podcast and all of the reviewers we received on the newsletters for
the year.  What you guys see when you read a newsletter is the finished product,
and it's people like Mike and Murch who review this every week, but also a lot
of the people whose specific stuff is covered in a newsletter come to review the
newsletter and help us put out accurate content.  So, I'm really, really
appreciative of that.

**Mark Erhardt**: I wanted to give a shoutout too, if that's okay right now.

**Mike Schmidt**: This is the time; we're celebrating.

**Mark Erhardt**: Well, so some of you might have seen that already, but
Chaincode Labs is organizing a program for people to bootstrap themselves into
Bitcoin open-source development.  It is a three-month program.  We're expecting
that people will invest at least 10 hours per week, but if you have the time,
you might want to put more into it, and that starts with the start of the next
year.  The application is open until December 31.  If you've always wanted to
become an open-source contributor, but you just didn't know how to bootstrap
from knowing a bunch of conceptual stuff, having read the books, to actually
writing the code, this is an opportunity for you.  So, check out
learning.chaincode.com.  This is free of charge, and we hope to bring a lot of
people into open source or other developer roles in Bitcoin.

**Mike Schmidt**: Excellent.  I've invited Jameson to join us for no particular
reason, other than he may have some smart things to say as we progress and
celebrate this year of Bitcoin and Lightning developments.  Hi, Jameson.

**Jameson Lopp**: Hello, yeah, it is that time of year.  I've been undertaking
my own end-of-year stats and metrics aggregation stuff, so I hope to get my
annual post out in the first week of the new year.  Anyway, I think it's typical
bear market to building stuff, so while a lot of things have been quiet outside
of the sort of ETF drama, I think it's great that we have seen quite a bit of
progress happening at the protocol and the application levels.

**Mike Schmidt**: That's a perfect segue to one way I wanted to lead into this
discussion.  And this is, I guess, for Murch, Dave or Jameson, and we can start
with Dave, maybe.  Dave, similar to last year, I wanted to ask you your totally
subjective opinion on your thoughts about relative "progress" in 2023 compared
to other years.

**Dave Harding**: Yikes.  Again, I think we had a really good year.  Like
Jameson said, it's been a good year for building.  Bear markets, or whatever you
want to call coming back from a bear market, are good years for building.  I
think this year, we've had a lot of really good new ideas, so things like Ark
and a lot of this sort of second-level covenant thinking.  We've had a lot of
new ideas on that front.  We've also had a lot of ideas that have paid off.
Bitcoin Core, we had things like assumeUTXO and encrypted P2P connections; and
in Lightning, things like onion messages and blind routing, and it looks like
we're getting really close to BOLT12 offers.  So, it's a really good mix of
things that are looking five years in the future, and things that we thought of
five years ago that are paying off now.  So compared to other years, I don't
know, it's just been a good year.

**Mike Schmidt**: That's fair.  I am putting you on the spot.  Murch or Jameson,
I don't know if you have any thoughts on that high level, and then we can maybe
jump into some of the months-by-months.

**Jameson Lopp**: Yeah, I mean what are the things that have actually been
implemented and are changing this year versus what are the things that are being
kind of played around with?  It does seem like we've seen some acceleration on
the just proposal side.  And of course, if you look at Bitcoin as a sort of
decision tree of trying to figure out what is the "best path forward" for the
ecosystem and the protocol, it's all about coming up with a lot of ideas and
throwing them against the wall, getting a lot of feedback, people trying to
figure out what are the pros of any good idea versus the potential cons, of
course wanting to implement things that cause no harm or the least harm possible
to people who are existing protocol users.  So, we've definitely had a lot more,
I think, ideas.  The question, of course, is how many of these will be able to
get through the gauntlet of development and consensus.

I guess people who are maybe less technical and more paying attention to the
social media scene, of course, are probably mostly going to be thinking about
all the drama around Inscriptions and Ordinals and the effects that that's been
having on block space demand.  So, there have been, I guess, more practical
changes from that perspective, and of course then we once again get to have the
whole "what is spam?" debate.  And regardless, I think that it has captured more
interest both from technical and non-technical people.

**Mike Schmidt**: Murch, did you have any high-level thoughts?  Maybe no
high-level thoughts, but maybe technical difficulties.

_Bitcoin Inquisition_

Jameson, you mentioned a bit about the gauntlet, which I will also use as a
segue into our first item from January, which has become sort of a place where
new ideas go, which is AJ and his Bitcoin Inquisition that is running on signet,
for testing proposed soft forks and even things that aren't soft forks, that are
protocol-related changes, to be able to test those out.  I think we had
announced that late last year and then it's now live and it has a bunch of
different proposals on it, SIGHASH_ANYPREVOUT, OP_CHECKTEMPLATEVERIFY (CTV).  I
think there's some support for ephemeral anchors, and I think there's some open
PRs for things like OP_CAT.  OP_VAULT may be in there, or there is a PR for it.
Is this the way that new proposals are going to be vetted, is this sort of a
step along the path?  What do you think, Dave?

**Dave Harding**: I think, you know, we can never make it a requirement.  We
need freedom in the future to choose how to do things, but I think it's a very
good way forward to have these things set up on a really good testnet.  We've
done this in the past.  Segregated witness had its own testnet; it had several
actually called SegNet.  And I believe we activated taproot early, and we have a
history of activating soft forks early on testnet.  And I believe taproot was
actually implemented on the SegNet, sorry, again early for testing, and this is
just a testnet where we throw everything out there.  There's no money you can
lose, but we can see what people build on it and do with it, and from that we
can inform changes to the proposal, but also whether that proposal is worth
putting more effort into, just by seeing what people do on a testnet and being
able to see how that affects other users of the system.

**Mike Schmidt**: Murch, are you back?  Oh no, okay.  He's messaging me
profanities, so that's not good.  Dave, I don't know if you want, do you want to
just go through the newsletter sequentially, or are there specific things that
we should call out along the way, skip over certain things; how do you want to
approach it?

**Mark Erhardt**: Hey, can you hear me?

**Mike Schmidt**: Yeah, you sound great!

**Mark Erhardt**: Good, great.

**Dave Harding**: I don't have anything specific I want to call out, Mike.  I
think every one of these things is important in its own way and I don't want to
say some are more important than others, but I realize it's a long newsletter,
so whatever you decide to do, I'm happy to just sit here and opine on it.

**Mike Schmidt**: Well, we can go through one-by-one and not play favorites
then, and if we decide to drill into one in particular, we can.  And maybe we
can just provide quick overviews of some of this tech, and if folks have
questions about it, we can drill into it.

_Swap-in-potentiam_

The second item from January was swap-in-potentiam, a non-interactive method for
opening LN channels.  That's the high level.  Dave or Murch, how would you break
that down a little bit more, and what sort of progress have we noticed since
this January item, if any?

**Mark Erhardt**: Yeah, I thought that was a really nifty idea, and it didn't
really require any new changes.  It just required creative application of stuff
that existed already.  So basically, what you're doing is you're receiving to an
encumbered, with a timelock encumbered, output script, and while this timelock
is active, you and a designated Lightning Service Provider (LSP), for example,
can immediately open a channel from the staged UTXO.  So, you receive sort of to
a staging area, the funds are locked for some time.  After the lock, you can
just spend them by yourself, so you just have to wait for your funds to come
back to you.  But while they're staged, you can immediately use them to splice
them into a channel.

I think this ties in nicely with a lot of other activity we've seen around LSPs
and LN services, professionalizing, thinking really about what services they
want to offer, offering liquidity and all sorts of things that tie into like
bigger services trying to use LN and also end users having better access to LN
liquidity.  So, I believe that it's now in use with Phoenix and there was at
least one other project working on it.  I think that was a really cool, creative
idea.

**Mike Schmidt**: I see a question in the thread here and, Murch, you are
explicitly cc'd on this, which is from jão saying, "I'm missing Floresta/utreexo
stuff on this recap".  I suspect that's reference to the coverage or lack
thereof in the Year in Review.  Dave, as the primary author, how do you think
about utreexo and any associated progress this year?

**Dave Harding**: I think there's been a lot of progress.  So, we covered it
last year in I believe December of 2022.  Calvin Kim posted to the mailing list
saying that he was going to be using some Bitcoin announcement bits to tell
people when a node was capable of serving utreexo data.  But a lot of the work
this year has been kind of that quiet background stuff, not the kind of stuff
that we typically cover in the newsletter, because people were just working the
code, making it better.  And I believe Calvin recently said on Twitter, or
somewhere, that they're looking at getting some really good clients out there
early next year.  So, hopefully we'll have some more coverage soon.

**Mike Schmidt**: Yeah, that makes sense.  And I think to your point, maybe
there hasn't been too much utreexo engineering protocol work itself as compared
to, I think we've highlighted at least a couple of times, utreexo client service
software integrations, including the Floresta thing, which is I guess the way
these things go, right?  The innovation has sort of been out there for a while,
and now industry is starting to adopt it in various forms.  So, I hope that
helps answer your question, jão.  Go ahead, Murch.

**Mark Erhardt**: Since I sort of missed out on the high view overview thing, I
think this ties back nicely to what I wanted to say.  I think that this year, a
lot of stuff, a lot of groundwork that had been laid came into active use.  So,
for example, we saw that taproot went from, well, being active for over a year
to suddenly, well, in a funny way but making up more than 50% of the outputs at
times.  So, we saw MuSig2 get implemented with multiple services get fully
spec'd out; we saw miniscript come in and become available for P2WSH and for
P2TR.  So, while there weren't that many new building blocks that were
established, we saw a lot of application developers mostly, or also protocol
developers, pick up existing things and finalize them, move them forward.

So this year, I'd say we were making use of the tools that we had built
previously rather than creating new tools, and I think that's also true for
utreexo, where the proposal's there, people know what we're aiming to do, well,
not me personally but what direction it is going.  But it's not quite there yet,
it's coming soon.

_BIP329 wallet label export format_

**Mike Schmidt**: And an example of a quick turnaround for a proposal and
implementation would be this last item from January, which is the wallet label
export, which I think late last year was an idea and was actually assigned
BIP329, which makes it easy to back up important wallet-related data that isn't
just the BIP32 seed, so some labels related to outputs and things like that.
And not only was that assigned then in January, but we covered in our Client
services section, several wallets that had actually implemented 329 by the end
of the year.  Obviously, something like that is maybe a little bit more
straightforward and a quicker cycle from proposal to implementation than some of
the other things we've talked about here, but I think that's one example of what
Murch is talking about.

_Ordinals and inscriptions_

You also mentioned the funny adoption of taproot, which is a lot of discussion
that we covered in February when this Ordinals and Inscriptions thing was new to
everybody and we weren't sure exactly what it was.  We had a few different
discussions on the effects of those particular protocols on the Bitcoin
blockchain and specifically, the mempool as well.  And there was a lot of
discussion early on.  And it's funny reading the summary here, because it seems
like we're still having this same conversation of like, should this type of
information, these types of transactions be censored?  The quote from Andrew
Poelstra back in February, months and months ago, which I think is where the
technical community is at, is there's no sensible way to prevent people from
storing arbitrary data in witnesses without incentivizing even worse behavior
and/or breaking legitimate use cases.  Murch, Dave or Jameson, any thoughts on
Ordinals and Inscriptions?  Murch?

**Mark Erhardt**: I think that Andrew is completely right on this.  If you try
to squash it, it's basically impossible.  It will be a cat-and-mouse game.  It
is trivial to come up with a different envelope, so you can't just look at the
envelopes.  So you would basically, if the game goes on too long, in the long
run just start to restrict to only standard scripts, and that's not something we
want to do.  We want Bitcoin to have an open script engine where you can write
your own output scripts, where you can use miniscript to come up with some sort
of cryptographic contract that exactly incorporates your ideas.  And if we lock
it down to just some standard set of output types, that becomes impossible.  So,
in the long run, people can just write data to the blockchain.  They will have
to pay for that.  That tends to be fairly big transactions, so they'll pay more
than a comparable payment transaction, but well, if that is what they choose to
buy their block space for, that's what they can do.

What really has me a little more annoyed/thinking is people writing data to the
UTXO set.  And I think that is sort of a tragedy of the commons.  Whenever you
write data to the UTXO set directly, it takes resources from the whole network
that do not get freed up.  Everybody has to keep the entire UTXO set around,
otherwise they can trivially be split off from the network by someone actually
spending a UTXO they don't know about.  And it basically gives the minimum chain
state that a full node needs to be able to stay at the chain tip and validate
the entire state of the network.  So, I hope that that sort of behavior at least
stops.  I don't think that that has any sort of advantage other than, well,
trolling users that are concerned about it.  And yeah, so I just think, to say
concretely, the stamps stuff is on a different level detrimental than OP_RETURNS
or Inscriptions, and I don't see any advantage except for the trolling aspect.
So, yeah, there's different qualities of problems here.

**Mike Schmidt**: And I think with respect to the UTXOs, my understanding is
that some of that is unnecessary, and it's not clear to me if that's trolling or
just inefficient, and some guy hacked some of this together in a weekend and it
caught on and maybe they needed to have some consulting with you, Murch, about
how to appropriately stuff things in so that it's not as egregious.  Jameson?

**Jameson Lopp**: Yeah, I mean I think if it can be done, it will be done.  And
a lot of the arguing is really about, I think, trying to incentivize or
disincentivize certain behaviors.  In general, I think trying to ban or block
certain behaviors does turn into that kind of Whac-A-Mole game that is probably
not the best use of the protocol engineering resources.  And perhaps it makes
sense to talk more about trying to incentivize people to use something like
OP_RETURN, maybe even lifting OP_RETURN limits if it is believed that that might
make some of this more egregious behavior go away; hard to say.  This does turn
into, I think, a bit of an economics problem.

I've seen people also bemoaning the fact of Inscriptions getting to take
advantage of the witness discount, and perhaps it would be sensible to try to
remove this discount to make it more expensive for them.  But I haven't seen any
actual practical proposals of how one would be able to do that, and I haven't
seen any strong arguments or really any argument of why removing the witness
discount would make sense in the context of the reason of why the witness
discount was originally implemented, which was to help to realign some of the
imbalance of incentives between creating and destroying UTXOs.  But as Murch
said, the stamps UTXO issue is probably, from a technical perspective, one of
the more egregious uses of blockchain.

**Mark Erhardt**: Yeah, I wanted to hook in there.  So, removing the witness
discount would be a soft fork, it is possible.  You would basically just start
counting all data in the witness stack with the same weight as input scripts and
output scripts.  That would significantly reduce the block space that is
available by changing the formula by which the block rate is calculated.  And I
agree with Jameson that I don't think it's a good idea, because we actually do
want people rather to write data to the witness instead of writing it to, say,
the bare multisig outputs as stamps do.  When you do make witness date the same
price as bare multisig data, people have even less reason to not use bare
multisig.  At least bare multisig right now is significantly more expensive than
Inscriptions.  So, yeah, and for the general users that actually use Bitcoin for
payments, I think the witness discount makes a lot of sense.  It incentivizes
people to be thoughtful about how many UTXOs they keep around and to spend
inputs rather at times where it would be cheaper to just create an output with
the old rules, with the non-segwit outputs.

So this behavior, where it was so much cheaper to create outputs that maybe
creating a change output that you could avoid by having a perfectly matching
input set, would be the preferred option, just so you can save that input that
would match up to make that an exact input set.  That goes away when inputs and
outputs cost almost the same.  So, yeah.

**Mike Schmidt**: Dave?

**Dave Harding**: I agree with everything about removing the segwit discount
would be bad for the long-term health of the UTXO state.  I just wanted to add a
quick note that if we did soft fork out the witness discount, that is
theoretically confiscatory.  So in theory, somebody could have created a
pre-signed transaction that's larger than 1 MB, because we've seen segwit
transactions that are larger than 1 MB.  And so, one of the things we do when we
try to make a soft fork is we try very hard to avoid creating any sort of soft
fork that could render somebody's reasonable pre-signed transaction invalid,
because if they destroyed the keys that were used to pre-sign those
transactions, those funds are permanently lost.  So, we try very hard to do that
type of soft fork.  So, if we were going to change the witness discount, we're
going to reduce the witness discount, we'd have to be really careful about that.
It has to be a very long conversation in the community.

Another comment I had was an extended version of Andrew's quote here featured in
the year-end newsletter, is he points out that most of the ways that we can play
Whac-A-Mole just end up increasing the cost of these sort of data storage things
by 2X or maybe 3X the cost.  And if those protocols were afraid of a 2X, people
using those protocols were afraid of a 2X or 3X increase in costs, fees would
eventually just outpace them, and we've already seen that.  Fees are much more
than 2X or 3X today than they were a few months ago or a year ago.  And so, it
just seems like a very ineffective game for Whac-A-Mole, and it just has all
these problems, all these downsides.  So for me, I personally just try to tune
it out as much as I can.

**Mike Schmidt**: I don't have any crystal ball, I don't think any of us do, but
there have been instances where certain protocols or businesses have monopolized
the block space, maybe not to the degree that it has been this year, but you had
Satoshi Dice, which was a huge percentage of transactions for a while; you had
the I believe it was 8.00am Eastern Time dump of individual transactions for
BitMEX for a while that would flood the block space temporarily; and you had
things like VeriBlock for a while, that was a significant percentage of
transactions on the network, doing their proof-of-proof protocol, which is sort
of in my mind like an OpenTimestamps, except for every single proof had its own
transaction, or some such thing.  And those things are gone now, so who knows
what happens with the Ordinals and the Inscriptions thing, but I guess maybe
there's some rhyming of history there.

**Jameson Lopp**: Yeah, I mean this is, I believe, the Bitcoin ecosystem
continuing to try to find product market fit.  Entrepreneurs and developers come
up with new use cases for the Bitcoin protocol and maybe they make sense for a
little bit of time, but over the long run they don't make economic sense.  And I
think it's kind of interesting to see people get bent out of shape because of
others who are using Bitcoin in a way that they don't approve of.  All I can say
is there are a ton of transactions that I've made over the past decade that are
pretty stupid, that all of you, and myself included, are going to have to
continue to store for the rest of eternity.  I was just able to do them at the
time because they made economic sense, and I don't feel bad about them getting
priced out.  I don't really miss being able to play those dice games for a few
pennies.

**Mike Schmidt**: We have a couple of questions from the audience I want to jump
into.  One is, "Question regarding the ordinal stuff y'all are talking about.
Is it possible to prune witness data as someone who runs a node?  If so, what
are the pros and cons?"  Murch, you have a comment?

**Mark Erhardt**: Yeah, I'll take that one.  So, we do not have only witness
data pruning, and that wouldn't actually be that much more useful.  So, I guess
if you only pruned the witness data, you could still rescan to a lower depth.
But generally, if you have a pruning node already, you will not have the
complete history, and the witness data just gets removed when the block gets
removed.  I guess you could sort of implement that in a way that you first
remove all the witness data that is past a few hundred blocks or so, and you
keep the remaining block data without the witness data, and then you could have
a little more blocks without the witnesses, but I don't know.  The script blocks
aren't that useful themselves either.  If you were doing that, I would rather
recommend that you keep the compact block filter data structure, because then
you can just do a rescan by scanning the compact block filters, and then you
know exactly which block to download one more time.

So, if you're running a pruning node, I think the vanilla pruning setup works,
but maybe turn on the compact block filter if you're rescanning frequently.
Then you get something like the best of both worlds.

**Mike Schmidt**: Dave?

**Dave Harding**: I just wanted to add a quick note about that, which is I
believe there's an open PR to Bitcoin Core that for when you first start Bitcoin
Core, it doesn't validate the signatures on really old blocks.  And there's an
open PR to not even download the witnesses, which is where the signatures are
placed, to not even download the witnesses for blocks that you're not going to
validate the scripts for on old transactions.  So, there kind of is what this
person is talking about.  There's an idea, and it looks like Murch has some
comments on that.

**Mark Erhardt**: Yeah, this happens, but only when you're in pruning mode.  So
basically the idea is, if you're in pruning mode, you'll download all the
blocks.  But if you're running with assumevalid, which means you check that the
transactions are well-formed, you check that their txids are correct, you check
that the transactions are featured in blocks, and you calculate your own UTXO
set, but you don't actually check the scripts because script validation is
computationally very expensive, then you don't download the witnesses for blocks
that you'll prune later anyway, because you're only going to download, not look
at them, and throw them away.  So, you're just short-cutting there by not
downloading data you're not going to use.

**Jameson Lopp**: So, somewhat related to that, I'm just finishing up my annual
node syncing tests.  And when I do those syncs, I actually disable assumevalid,
so it is performing every validation check of every signature for the entire
blockchain.  One nice thing to note is that thanks to the ongoing great work of
some of the developers working on the libsecp project, it seems like every year
they manage to find another 10% or 15% performance improvement there, which
really helps fight back against the ongoing, ever-increasing validation demands.

**Mike Schmidt**: To loop in Lightning here, we have a question from the
audience from Larry, which is, "Does the recent increase in the size of the
mempool negatively affect L2s like Lightning?"

**Mark Erhardt**: Yes.  So, there's a huge issue for Lightning nodes right now,
which is a lot of the commitment transactions are created at substantial
feerates, but feerates that have been outpaced by the current mempool
conditions.  And if there's enough transactions waiting with these very high
feerates, most nodes will start dropping other transactions that are going to be
the last ones that get included into blocks.  So, the lowest feerate
transactions get evicted from nodes mempools.  However, if your dynamic minimum
mempool feerate on your node is higher than a transaction that you're trying to
broadcast, it will never get accepted to your own mempool, you cannot give it to
your peers, the nodes on the network generally will not propagate the
transaction, it'll never get to the miners.  And that is even true if you're
CPFPing a transaction.  So, if you're throwing a commitment transaction into the
mempool and trying to attach a child transaction to the anchor output that bumps
the commitment transaction to an appropriate feerate, it's still not going to
get in if the parent transaction, the commitment transaction's feerate is at a
feerate to load to get into the mempool.

There's great work right now on a subset of the package relay proposal right
now, that is just the idea.  How about we start with packages that have a single
parent and a single child and we get package relay working for that first?  And
then at least for the Lightning use case, generally this should become much less
of an issue, that they cannot close channels unilaterally because they have a
pre-signed transaction with too low of a feerate.

**Mike Schmidt**: Moving on.  Oh, Dave, you have a comment?

**Dave Harding**: I would just quickly add that this is something that we've
always known we'd have to work on with Lightning and developers have been
working on this, both on the Lightning level and at the Bitcoin Core level.
Like Murch was talking about package relay, we also have earlier stuff in
Lightning, like anchors, which is based on CPFP carve-out, which also was
implemented in Bitcoin Core a number of years ago, and then developers working
on the next generation of stuff of this, like v3 transaction relay and ephemeral
anchors.  So, this is just not a surprise to anybody.  It's something that we've
known was a concern and developers have been putting a lot of their time and
effort into finding not just a temporary fix for this, but actual long-term,
permanent fixes to this problem.

**Jameson Lopp**: I mean, I know that we've been hearing of these force-closed
channels and that there has been an uptick in them, but I don't think it's at a
catastrophic level.  Anecdotally, my own nodes have not experienced any of these
force closes, and it seems like at a global level, if you look at the number of
open Lightning channels, there really has not been a significant drop.

**Mark Erhardt**: There's also a related issue here.  So basically, a new
commitment transaction is created every time the channel is updated, which
happens, for example, when you add a Hash Time Locked Contract (HTLC) or fold an
HTLC back into the channel balance.  And at that point, when you create these
new commitment transactions with your channel partner, you can also set a new
feerate on your commitment transaction.  But imagine currently the mempool is
over 300 satoshis per vbyte (sat/vB).  So, you forward a payment for your
channel, and you say, "Well, in order to be able to get my transaction into the
mempool, maybe the dynamic minimum right now is 30 or 50 sat/vB", and you say,
"Well, we should really update the feerate on the commitment transaction to 30
or 50 sat/vB, so that if I have to unilaterally close my channel, I can put it
into the mempool.  And then let's say the latest BRC-20 token is finished to be
minted, the mempool goes back to last year's sort of behavior, and you can get
transactions of any feerate into the mempool.

So, that enables you to attach transactions to your commitment transaction and
bump it to the appropriate feerate again, but your commitment transaction is
still stuck at 30, 50 sat/vB, and you pay 30 to 50 sats when you close it
because, say, your peer disappeared right after you made that commitment
transaction with them and never came back.  So, you can sort of get stuck on
high feerates in that manner.  And all of that, like the flexibility of being
able to pick the appropriate feerate at the time of when you need to
unilaterally close, that would be enabled when we get the one parent, one child
package relay.

_Bitcoin Search, ChatBTC, and TL;DR_

**Mike Schmidt**: Jumping back to February, we highlighted a few different
useful Optech recommends sites and tools around BitcoinSearch.xyz, which is a
Bitcoin-specific search engine, which by the end of the year had added a chatbot
interface, including a specific Murch Bot with an amazing avatar with suave
hair, if you want to check out and interact with the Murch Bot.  There's also a
few other different Bitcoin engineer bots that you can interact with and ask
questions to.  And then also, part of BitcoinSearch.xyz is TL;DR, which takes a
look at some Bitcoin developments and tries to summarize those for folks who are
interested in quick summaries of some of these discussions, similar to what we
do in Optech.  Murch?

**Mark Erhardt**: Yeah, I just wanted to point out, so BitcoinSearch.xyz is fed
with specific resources, like the mailing list, Bitcoin Stack Exchange, certain
forums, and you will generally find pretty high-signal results on the first page
there.  And this chatbot that uses ChatGPT under the hood is specifically
configured to not hallucinate.  So, if it doesn't find good sources, it'll just
tell you it can't answer your question, but not make up nonsense.  And it'll
usually give you five sources that are very closely related to the topic you're
asking about.  I've had great success with just trying to find some old mailing
list thread, and even if it said it couldn't summarize the question that I had,
it would tell me exactly where that mailing list thread appeared and I could
just read the base source.

_Peer storage backups_

We also talked about in February, Core Lightning (CLN) adding support in an
experimental way for peer storage backup, allowing a peer to store some backup
data about the latest state of its channels with its peers, so that if it
disconnects and potentially loses some data, it can request that backup file and
keep chugging along.  I think there's some other innovations along there, some
fraud-proof discussion about some of that later in the year as well.  Murch or
Dave, any comments on that?

_LN quality of service_

Talked about Joost and his proposal for high availability flags in LN channels,
which allows the signaling, the self-signaling that a channel is reliable for
payment forwarding, which spawned some interesting discussion about reputation
systems from Christian Decker, and some additional proposals that were done
previously about overpayments.  I don't know how much you want to jump into some
of these, but worth mentioning.

**Dave Harding**: I'll just go really quick on, I think the overpayment of
recovery or boomerang payments or refundable overpayments, whatever you want to
call it, is something that will be easier with Point Time Locked Contracts
(PTLCs) when we upgrade to full support for taproot and LN channels.  I think
that's a really exciting development.  And the basic idea there is that if you
have a bit more Lightning balance than you need at the moment, you pay a bit
more than you need to for a payment.  But you do it in a way that allows the
receiver to only claim a limited amount of those, so the actual amount that
they're supposed to get paid.  And by doing that, we can basically do something
that's kind of like forward error correction in internet protocols, which is
just send a whole lot right now, and as long as some of it gets through and
enough of it gets through, the payment is successful.  And I think that can
significantly improve payment quality on the LN.

**Mark Erhardt**: Yeah, and I wanted to jump in on the reputation systems.  So,
the funny thing about reputation systems is that you either have to trust the
assessment of other participants in the network, or you can only locally collect
data and trust yourself.  And I think that was sort of the crux of the
discussion there, was in Bitcoin, at least on the base layer, we generally do
not want to trust peer nodes for anything.  Obviously, we get data from them,
but the data is all signed and cryptographically signed, so they cannot fudge
with it.  But we don't trust them to tell us what the best chain is, or, well we
kind of trust them that they tell us about everything we want to know about, but
we have guarantees for the blocks in that regard as long as we're connected to a
single honest peer.

With the reputation system, I don't know if we get into that later in the year,
but there was some interesting progress on making a local reputation system
where you trust your peers to report what they have to say about the payment.
But this sort of iteratively can turn into a chain of people saying, "Yeah, I
got this from someone that I got good-quality traffic from all this time, so I'm
going to say this is good-quality traffic.  And then, if the next peer gets this
message with the label, "Oh, this is good-quality traffic" from a peer that they
trust, they'll also just forward this good-quality traffic flag, and so forth.
That is part of the jamming solution that people are working on right now.

_HTLC endorsement_

**Mike Schmidt**: Yes, and that's actually the next topic from February, which
is we've outlined the progression of the channel jamming discussion that started
last year, and we highlighted the paper where this channel jamming was
discussed, and we progress along the year with folks asking for feedback about
suggested parameters for channel jamming, some of the HTLC endorsement
discussion that we just mentioned, a draft specification based on that feedback
for how the testing could be done for channel jamming, the discussion topics
that was brought up at the Lightning Development Meeting, which led to some
discussion about alternative approaches potentially; and then in August, the
announcement from developers associated with Eclair, CLN, and LND implementing
parts of the endorsement protocol to begin collecting that data.  So, it's nice
to see that progression from late last year to this year, from an idea to
something that's actually being collected and can be acted upon.

_Codex32_

Last item from February is Russell O'Connor and Andrew Poelstra's proposed BIP
for backing up and restoring BIP32 seeds.  The project is called codex32.  I
didn't know it was Russell O'Connor and Andrew Poelstra.  I thought it was
Professor Snead, but it looks like those two engineers were involved.  It
involves Shamir's Secret Sharing with a bunch of configuration options, and a
lot of the work that can be done in backup and validation here can be done,
interestingly enough, with pen and paper.  And there's some interesting, I
guess, helpful tools that you can use as well, analog tools, non-digital tools,
to verify your shares offline.  So, I think it's interesting.  We had, I think,
a Stack Exchange question or two on this earlier in the year where I think
Andrew Poelstra went into some interesting detail on even further offline
computation that you could do.  So, I think it's cool.  I haven't tried it
myself.  Murch, Dave or Jameson, I don't know if you have any feedback on
codex32?

**Mark Erhardt**: I have tried it myself.  It is very cool, very nifty,
extremely nerdy, and a lot of time until you get an actual key generated.  I
think I was at Bitcoin++ in a workshop and spent something like an hour or
one-and-a-half hours on it, and I think I was a quarter done.

**Dave Harding**: I've also tried it, also thought it was nifty, and also took a
bunch of time.  But I'd be really interested to hear Jameson's take on it, since
he is something of a backup specialist.

**Jameson Lopp**: Yeah, I mean I think the short version is it's not
particularly practical.  I don't think we're going to see much adoption of this.
It's always good to have people playing around creating other options.  And for
the extreme nerd, who doesn't want to even trust calculators and hardware and
stuff, that's certainly an interesting, uber-paranoid route that you can go down
if you're willing to put in the time and effort.  But I think I'm not going to
be recommending it to many people as a more normie backup option.

_Hierarchical channels_

**Mike Schmidt**: Our next item, which is the first one for March, is a paper by
pseudonymous developer, John Law, talking about a way to create a hierarchy of
channels for multiple users from a single onchain transaction, channel factories
essentially, building on some of his other ideas about tunable penalty
protocols.  And It seems like John Law, whoever they are, comes up with these
interesting ideas and it takes a long time for the community to digest, if at
all, what he's been putting out. Dave, I know you've spent a lot of time
understanding what John Law has put out.  Would you want to augment on some of
what he's proposed, in not only the channel factory idea but some of the tunable
penalty stuff?

**Dave Harding**: I think this stuff is really interesting.  It's hard, I think,
for people to get into because it's a completely different design for the set of
transactions that we would use in LN from what we use now.  And I remember when
I first read the original Lightning paper, it was just really hard to think
through all these state transitions and stuff.  But now that I've been doing it
for five years, it's just really easy.  And then people who work on LN every
day, again the state transitions to flow, it's just embedded in your memory.
And when you come across a completely different design, it's just a lot of
thinking and hard work.  But I think this is a very interesting idea, the
tunable penalties in general, and this specific iteration on it.

One of the things that this allows us to do is capture a lot of the benefits of
eltoo, but eltoo requires a consensus change, while John Law's stuff does not
require a consensus change.  So, you can think of it as a fallback option if we
never get eltoo, or something that allows us to implement eltoo, these ideas are
here.  There are still benefits to SIGHASH_ANYPREVOUT and eltoo, but this is a
way to capture a lot of the benefits, and then he extends it in a lot of
interesting ways.  But to understand that, you've got to read through dozens of
pages of really hard-to-understand state transitions and stuff.  And again, as
far as I know, nobody is actually working on turning these ideas into code,
which for me is a little sad, because they are really interesting ideas with a
really unique set of benefits.

**Mark Erhardt**: I'm reminded of ZmnSCPxj's joinpool's proposal at this point,
which I thought sort of hit a similar issue.  We've seen a lot of innovation
around rebalancing channels and liquidity ads and so forth.  And with having
funds staged in a different kind of liquidity pool that can be used to rebalance
channels, you would be able to get rid of a lot of the onchain interactions that
are necessary to rebalance, like some of splicing, which right now with the
current mempool conditions are super-expensive.  So, I think that if the mempool
stays any way like the last few months, we will see a lot of innovation in the
last year or two, just because necessity begets ingenuity.

_Summary 2023: Soft fork proposals_

**Mike Schmidt**: We have a callout here after March, which is 2023 summary of
soft fork proposals.  Obviously, we could probably take four hours just on this
section alone to try to even attempt to give these topics justice.  Maybe we
could provide more of an overview of what the types of discussions are going on
here.  There's things like OP_VAULT, we have OP_CHECKTEMPLATEVERIFY (CTV), we
have MATT, OP_TXHASH, there's BIPs, there's proposed BIPs, there's, "Let's
re-enable OP_CAT opcode".  Dave, where should the listeners and many of Twitter
followers who are clamoring for a soft fork around opcodes and covenants, how
should we think about that?

**Dave Harding**: I know this is not a popular opinion, but I think we're still
at this stage where we want developers who are working on these proposals to
keep discussing and come up with something of a unified proposal, with a talk to
us about what you expect these proposals to accomplish and whether we have a
good framework for evaluating what we want as users.  And so, I know there are
people who want this stuff now, but I think we still have too many ideas on the
table and not a good criteria for selecting among them for what will be the next
soft fork.  So, I think it's still a point of more discussion.  And I know that
doesn't make some people happy, it doesn't make me happy.  I am frankly kind of
tired of writing about these things, because it feels a lot like all talk and no
action, even though I do think more talk is probably the way to go.  That's
where I'm at.

**Mike Schmidt**: Murch?

**Mark Erhardt**: Yeah, I had a long discussion yesterday with a few CTV
proponents, and that actually ended up in a call with Brandon Black.  And I
think to give an overview of the positions, I feel very much like Dave, that the
current stage of introspection or covenants discussion is that the people that
are heavily invested into this discussion are still sort of tinkering on the
details, what are exactly the trade-offs of different proposals; what exactly is
the problem we are trying to solve; how much better is that opcode or this
opcode at solving that problem; what are the criteria to decide?  There's been a
lot of good work by some people to better compare all of the existing opcodes to
incorporate some of the benefits of different proposals into a more unified
proposal.  And yeah, one step that I would love to see before people talk about
activating one of these opcodes is more demonstration of what problem that
actually solves, what other proposals or application it significantly improves.
CTV, for example, has been on inquisition for quite some time.

So, if someone wants to demonstrate just how much better some transaction
constructions that we already use or that we would be using are with CTV or
OP_TXHASH, that would be an element of the narrative that would help with
getting a lot of the undecided people to make up their minds.  And while people
are just talking about ideas, or claiming this is better and that is better, or
we're still coming up with new proposals, we're not going to make progress
unless people actually demonstrate the benefits and incorporate, like build some
excitement on what we can do with these new things.

**Jameson Lopp**: I think the main thing that I would mention is that I would
like for people to get it out of their heads that you're going to be able to do
a user-activated soft fork of any of these things, especially if there isn't
already overwhelming consensus for it.  There is no precedent for actually
activating anything via a user-activated soft fork, and I think that the game
theory around user-activated soft forks is that they only make sense when there
is overwhelming consensus for something, but the miners, for some reason, are
blocking activation.

**Mike Schmidt**: I'll give an anecdote, which I think sums up my own personal
perspective of it, which I guess lends some credence to Dave's, maybe we do need
to talk about this more, or at least some people need to talk about this more.
I had a conversation with one of the developers that was proposing, let's just
say, covenant proposal X.  And they said that they were going to post this idea
and try to get a BIP and all that.  And I said, "Well, what do you think of
covenant proposal Y?" and the response was, "Oh yeah, I have no idea how that
one works".  And that, to me, kind of sums up where we're at.  There's a lot of
proposals, but this coalescing of knowledge, even between the people proposing
these things, perhaps isn't there.  And so it seems then, based on that anecdote
or maybe that perspective that results from that anecdote, that maybe we aren't
at the point where something needs to be activated until at least people are
aware of the other proposals and can at least articulate more details about why
their proposal is better and in what ways.  So, go ahead, Murch.

**Mark Erhardt**: Yeah, I agree and I also wanted to add a little bit.  I've
seen frequently the comparison with segwit or taproot and between, let's say,
CTV and segwit and taproot, like at what stage that proposal was when it was
activated.  And I think that there is a very distinct difference in the type of
soft fork these are.  With segwit and taproot, there was a bunch of features
right in the soft fork that would immediately be realized upon activation.
Whereas, of course, they also provided some tools and improvements that had to
be built up, but the things that we were trying to get to were directly provided
by the soft fork itself.  With these introspection opcodes, it is more of a tool
to build other things, a building block, so activating that opcode will only get
you a small portion of the way.  It matters much more what people are going to
build with these building blocks.

So, if you think about how taproot was discussed before and what benefits were
seen, you know as soon as it gets any sort of adoption, these benefits are
realized.  Whereas with CTV, it matters, or CTV and OP_TXHASH, for example, it
matters so much what people are actually trying to use it for in order to see
what you want to activate in the first place.

**Mike Schmidt**: I saw Rearden Code pop in, so I immediately invited him
because we're talking, Rearden Code, about the callout from our 2023
Year-in-Review Newsletter that was about soft fork proposals, and I know that
you were involved with some of that.  Our discussion just immediately before you
joined was, it seems like there still needs to be more discussion, to Dave
Harding's dismay, since he has to summarize that discussion.  I'm not sure if
you have things to add to that.  Obviously you missed some of it, but maybe give
us your perspective on this discussion of soft fork proposals and covenants?

**Brandon Black**: Yeah, thanks so much for having me up.  I think the biggest
message I would say I have at the moment is that I've spent close to a year now
researching covenant proposals, proposing my own, going down various rabbit
holes, and the thing I haven't been able to do in about a year of actively
working on it is make any improvements to CTV.  CTV, I hate to admit sometimes
that I can't find a way to improve something.  I try to with everything that I
see, and I can't find a way to improve it.  And so while some are saying that we
need more time to discuss various proposals, I would say that CTV has been out
in the open for a very long time and has absolutely achieved rough consensus in
terms of a technical perspective.  In Bitcoin, we obviously have also a social
consensus aspect that we have to figure out.  But there's been literally not a
single technical objection to CTV in two years.  There have been, "We could do
better" objections, which I agree with, and I like TXHASH and I like other
things as well.  But all of the things that are, "We could do better", can be
added as an upgrade to CTV, and we should do CTV now.  That's what I have to
say.

**Mike Schmidt**: Any feedback from our audience?

**Mark Erhardt**: Short and sweet, and certainly a position you can take!

_Watchtower accountability proofs_

**Mike Schmidt**: Okay, we can move on.  In April, the first item that we
highlighted in the Year in Review was this ability to have accountability proofs
for watchtowers in LN, in cases that they fail to respond if there's a protocol
breach.  And Sergi suggested a mechanism based on cryptographic accumulators
that watchtowers can use for creating commitments, and then users of those
watchtowers can later use to produce accountability proofs if a breach occurs
and the watchtower did not report it.  Murch, or Dave?

**Dave Harding**: I just want to add, I think this is a really useful
contribution to the watchtower discussion.  It's not enough to just have some
watchtower out there who you send your encrypted backup states to and you hope
that they do the right thing.  You want to be actually able to prove that they
didn't do the right thing, otherwise I mean what exactly is the point, right?
People can just spin up a service and you'll send them stuff and they'll charge
you money, because it's one of the ideas here for watchtowers, and Sergi
actually worked for a company that was hoping to charge for watchtower service
and put a lot of work into that; but so, you're going to pay them and if they
don't do their job, you have no way to prove that.  So, what he's offered here
is a way to prove that your watchtower hasn't done this job.  So, you can go on
social media or you can leave a, not just a customer review, but an actual proof
review saying, "They were supposed to do their job and they didn't".  So, I
think that's a really useful thing to have.

_Route blinding_

**Mike Schmidt**: Next item from April involved route blinding, which is also
referred to as rendez-vous routing, hidden destinations, blinded paths, or route
blinding.  That was merged into the LN spec in April, and I don't know if, Dave,
do you want to provide an overview?  What is Route Blinding?  I thought things
were already sort of encrypted and whatnot on the LN when you're routing, so
what is route blinding then?

**Dave Harding**: So, you're right, things are already encrypted on the LN, but
the spender knows the path, the entire path to the receiver on LN before we had
route blinding.  And so as a receiver, you basically had to tell somebody where
you were.  And if you had an unlisted node, you still had to tell the spender
what your node was, and that associates with your UTXO.  What this allows the
receiver to do is, they choose the path for the final few hops to their node,
and then they encrypt that using the typical encryption we use on LN.  And they
give that to the spender, and the spender sends to the first hop in that path,
but the spender doesn't need to know the remaining hops in that pre-selected
path by the receiver.  So, the spender doesn't learn the receiver's node or the
nodes around the receiver's node.

So, it's this nice improvement in privacy.  It's kind of similar to Tor hidden
services, where a Tor hidden service doesn't need to tell you their real IP
address or their real domain name or anything, but you can still contact them
over the Tor Network.  So, it's kind of similar to that.  It's a nice privacy
improvement that allows you to keep your channels completely independent.  The
people who are sending you payments, it's completely leak-free of where you are
on the network and what balance you might have or other characteristics of your
node.

**Mike Schmidt**: So, maybe is a crude analogy here that if I'm getting
something shipped to me and I don't want the shipper to know my physical home
address, that I would have them ship to like a PO box and then go pick it up?

**Dave Harding**: That is a very good analogy, yes.

_MuSig2_

**Mike Schmidt**: Next item from April is BIP327 being assigned to the MuSig2
protocol for creating scriptless multisignatures.  Dave, I think there's been
some change in terminology about scriptless multisignatures versus some of the
old terminology I know we used on the Topics Wiki.  Maybe a good place to start
to explain MuSig is just maybe some of that terminology and why we're calling it
scriptless multisignatures now?

**Dave Harding**: Yes, actually, while I was working on the third edition of
Mastering Bitcoin, I knew I wanted to introduce the idea of multisignatures that
don't require opcodes, special opcodes to use, and I played around with a few
different names while writing the book.  and then I came up with this idea of
calling multisignatures that use OP_CHECKMULTISIG and related opcodes, scripted
multi-signatures, and then the idea of calling the ones that don't require
special opcodes scriptless multisignatures as a call out to scriptless scripts
from Andrew Poelstra.  So, I actually reached out to Andrew and I said, "What do
you think?"  He said, "Hey, it's a pretty good idea".  So, I actually talked to
Mike and Murch and the other people at Optech and said, "What do you think?"
And they said also, "That's a good idea".  So, we're trying to change our
terminology over to this, where if you're using OP_CHECKMULTISIG, we're going to
call it a scripted multisignature; and if you're able to use it, do it just
using math alone, we're going to call it a scriptless multisignature.  And so
MuSig…

**Mike Schmidt**: Dave, I think you cut out.

**Mark Erhardt**: Yeah, I don't hear him either.

**Mike Schmidt**: Okay, Dave, I think you're back.  Yeah, we can hear you.  For
some reason, you were not a speaker, now you're back.

**Dave Harding**: Yeah, I was hurt!  Anyway, so a script with multisignature is
a way that two or more signers can collaborate on creating a signature using
math alone.  And MuSig2 is a protocol for doing that.  And it's currently the
favored protocol for doing that for most cases, although there are other
protocols in the MuSig family that can do that.  MuSig family provides n-of-n
multisignatures, so every person who contributes key material has to also
contribute signature material for a signature to be valid, whilst there's other
protocols, scriptless threshold signatures, that will allow only a subset of the
entities who contribute key material to need to sign.  But MuSig2 is very useful
for things like LN, where you're looking for two parties to always be in
agreement anyway, and it can save roughly half the space over a scripted
multisignature.  And it looks identical to a single-signature by a single
entity, so it has some very nice privacy improvements too.

**Mike Schmidt**: So, the way we've outlined it in the Topics Wiki is that
there's scripted multisig, which uses Bitcoin Script to do multisig opcodes, and
so you can see things onchain that maybe you don't want people to see;
scriptless multisignatures is a category including MuSig, MuSig2, and that group
of proposals, which is m-of-m, so you have to have the full quorum to sign; and
then threshold signatures, Dave, would you say a threshold signature is also a
scriptless multisignature?

**Dave Harding**: That's the word we're currently using, but we could break that
down into scripted threshold signatures.  That would be k-of-n with
OP_CHECKMULTISIG, so say 2-of-3; and you could have scriptless threshold
signatures that again are entirely dependent on math.  That would be something
like FROST.

_RGB and Taproot Assets_

**Mike Schmidt**: Next item from April is the announcement of RGB v0.10, which
is a protocol for creating and transferring tokens, among other features,
including additional smart contract capabilities and a lot of other features
that are all validated offchain.  This is part of a category that we've put on
the Topic Wiki as client-side validation, which includes technology like RGB,
but also taproot assets, also previously known as Taro.  Murch or Dave, any
comments on client-side validation or the RGB release?  Okay.

**Mark Erhardt**: I think we can dive into client-side validation as a concept
briefly.  So, one thing that we've seen other networks do is that if you have
abundant block space and don't really charge for it, you can obviously put all
sorts of cryptographic contracts directly into transaction outputs and inputs.
That is a bit of a privacy issue, of course, because everybody can see what sort
of contract you're executing, which may include sensitive business information
that you wouldn't have to reveal as long as everybody agrees.  So, basically
Bitcoin always operates under the paradigm that if you can just prove that a
contract was executed satisfactorily and you can post that proof to make the
transaction go through, that is the preferred way of creating a cryptographic
contract in Bitcoin.

We get that sort of behavior, for example, with taproot.  If you have an
under-the-hood k-of-k owned output that has various different conditions under
which it gets spent that are all encoded in the script tree, as long as all the
participants are available and agree that some condition has been reached and
that payout should happen, you never have to reveal the leaves of the script
tree.  You can just make the MuSig signature and just do a keypath spend.  But
if any parties are not participating in the payout per the obviously achieved
condition, the other people can force the conclusion anyway.  And this is sort
of taken further with taproot assets and RGB in that you can have complex
contracts, also DLCs actually, that operate completely outside of the
blockchain, but you can boil it down to a proof that something has happened and
allows for a resolution of the contract.  And yeah, that is very
blockchain-space-efficient.  It is much more private, and actually except for
rather complex to implement at times, it allows you to do a lot more things on
the out-of-band stuff.

_Channel splicing_

**Mike Schmidt**: Last item from April was discussion about splicing protocol in
LN, which allows the rebalancing of channels by either splicing in, meaning
adding funds to an existing LN channel, or splicing out, meaning taking funds
out of a channel into an onchain Bitcoin output.  And we also highlighted that
by the end of the year, both CLN and Eclair support some form of splicing
functionality, which I think is really cool.  Go ahead, Murch.

**Mark Erhardt**: I think one thing that's super-interesting with splicing that
we're just seeing the beginnings of, is essentially with swap-in-potentiam
splicing, you can have an onchain wallet that is Lightning-enabled and you can
sort of have funds that are very easy to put into LN and then revert to your
solitary control after some time.  And it sort of starts to show how maybe in
the future, people are going to be much more heavily integrated between onchain
and LN interactions, sort of like you have a checking account and a savings
account, and they are integrated in one app; you'd have an LN and a holding
wallet that is one app.

**Dave Harding**: I would go a little further than Murch and just say I think
the goal here is to have a single balance, to open up your wallet and it says
you have, you know, 10 million sats and you don't even need to care how the
wallet is storing those funds.  You can make onchain transactions out of those
funds using something like a splice out, and you can make Lightning transactions
using those funds, whether by using an existing channel or by instantly opening
an existing channel, like Murch said, using something like swap-in-potentiam.
So, the user experience, I think that a lot of LN developers are working towards
that you just have a wallet.  It's not a Lightning wallet, it's not an onchain
wallet, it's just a wallet.  And you can make instant payments over the LN or
you can make less instant payments for large values using an onchain payment.
It should all be extracted away for users, I think that's the ultimate goal
here, and I think that they've made great progress on that this year.

**Mike Schmidt**: Do persistently high feerates put a kibosh on that vision?

**Dave Harding**: Not in my perspective.  I mean, we talked a little bit earlier
about the challenges of closing channels in LN due to high feerates, or managing
channels so that they don't have to be closed.  But persistently high feerates
just mean that another class of onchain transactions becomes economically
infeasible, but that LN is even more useful.  For people who are only going to
be using their wallet with very small amounts, they're probably going to have to
use some sort of custodial solution until we have better solutions for
joinpool-style constructions, where multiple people share UTXO.  Right now we
don't have good solutions for that.  Some of that is discussed later in this
newsletter I think, so we can get into that there.  But no, I think the goal
there is again to have a single unified balance in your wallet.  It's just your
bitcoins and you can spend them on Lightning instantly or you can spend them
onchain.  Again, the recipient has to wait for some confirmations.

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: I just want to extend slightly on that.  Basically, the LN is
an escape valve for onchain transactions.  When there's too much pressure in the
mempool, the higher the pressure in the mempool, the larger the payments that
make sense on LN.  And sure, LN's only been worked on for eight years.  It'll
probably take 20 years before it's completely disappeared in the background like
internet has today.  But yeah, we're working, or many people and many different
projects are working on a number of interesting different solutions for that.
And for the time being, we have known this for ten years.  Since we pay for
transactions per the weight of those transactions and not the amount that is
being sent, transactions that transfer less wealth will be priced out by
transactions that transfer more wealth because the relative cost is so much
lower for large payments.

_LSP specifications_

**Mike Schmidt**: Next item from the newsletter is about Lightning Service
Providers (LSPs).  There was a call for standards earlier in the year.
Initially, I think there was two different, LSPS1 and LSPS2, which has now
evolved.  It looks like looking at the repository, that there's three different
specs in the LSP spec.  The first one is transport layer, which describes the
basics of how clients and LSPs communicate to each other; LSPS1, which is
channel request, the ability to purchase a channel or buy channels from an LSP;
and LSPS2, which is just-in-time (JIT) channels, describing how a client can buy
channels from an LSP by paying via a deduction from their incoming payments,
creating a channel just in time to receive the incoming payment.  Murch or Dave,
any thoughts on LSPs or the specs?

**Dave Harding**: Just what we say in the newsletter, which is I think actually
taken from ZmnSCPxj, which is that just having standards for this is really good
for allowing clients to be portable between different LSPs.  Right now, there's
kind of an incentive, because the LSP space is still being pioneered, for each
pioneer, each company that's working on this, to have their own protocol and
their own client.  So, you think about something like Phoenix.  Phoenix uses
ACINQ's node by default.  And if there's no standard for that, then every LSP's
going to have their own client and you won't be able to choose who you want to
use as a service provider.  But if there's a good standard out there, we can
have multiple clients and you can choose your service provider.  That means we
have a diversity in service providers and that mitigates some of the
centralization problems with LSPs.  So, I think this is a great initiative and I
hope they keep working on it.

_Payjoin_

**Mike Schmidt**: Next item for May is about payjoin, which is a sort of mini
coinjoin protocol that helps break the common input heuristic used by
Chainalysis.  We talk about Dan Gould's efforts around, I think he's got a grant
to work on payjoin-related projects, so I think we covered the Rust Payjoin
project; most recently we talked about the payjoin-cli project, which is
providing add-on for creating payjoins within Bitcoin Core; and there's a PDK
that we also covered as well; and he also has a draft BIP for serverless
payjoin, which doesn't require spender or receiver in a payjoin to be online at
the same time.  A lot of grindingly hard work from Dan Gould.  Murch or Dave?

**Jameson Lopp**: I actually believe payjoin is probably the most practical form
of coinjoin when it comes to adoption.  And I generally don't recommend people
go around doing coinjoin, especially if it's an ongoing thing.  It can get
really expensive if fees are high.  There are proposals that will hopefully
bring that down in the future.  Also, in order to be doing ongoing coinjoins,
you're probably going to have your keys in hot wallets, and there's still a lot
of ways that you can kind of screw up and shoot yourself in the foot if you're
not handling your UTXOs well.  In general, I think that for mainstream adoption,
we would prefer to abstract away the concept of UTXOs as much as possible.  But
with payjoin it's just like, okay, I'm going to go make a payment, and if
whoever I'm paying also supports this protocol, it sort of automagically happens
in the backend.  So, I think the biggest problem here is just network effects.
I think that payjoin is something that we should prefer to see every wallet
support, and it just do it automatically so that people don't even have to think
about it.

**Brandon Black**: I just wanted to add to that.  I did some research on
payjoin, I don't know, a couple years ago at BitGo, and one of the things that I
think people don't always think about with payjoin is that it's a huge benefit
to recipients, especially people like exchanges or anybody who runs a large
wallet that takes deposits, so merchants or exchanges, because it helps them
with UTXO management.  Instead of accumulating tiny UTXOs that need
consolidation, as we see Binance doing all the time and making a mess of things,
with payjoin you don't accumulate UTXOs, you consume UTXOs and grow them
gradually as you receive payments.

**Mike Schmidt**: That's interesting, Murch.  I'm sure you've thought of
something similar.  What are your thoughts on that?

**Mark Erhardt**: Well, that's true, but there's also the disadvantage that
transactions generally get bigger.  So, if a lot of people adopted this at the
same time, there might be just more competition to get into the blocks, so it
might drive up fees altogether.  But yeah, I agree with Rearden.

**Dave Harding**: I would just add to that.  One of the things we call out in
this paragraph is one of Dan Gould's explorations in using a form of payment
cut-through with payjoin.  So, I think what Rearden Code is describing, an
exchange that's receiving lots of fairly small payments from its customers is
probably also processing lots of fairly small withdrawals from its customers.
And so, what payjoin can allow you to do, at least in theory, is that if
customer Alice is depositing money with Bob, and Bob also has a withdrawal
request from customer Carol, Bob can set the payjoin to pay Carol from Alice.
And so, you don't need to consolidate and you don't actually have larger size
transactions, you're actually possibly reducing the amount of transactions used,
and yet Bob is still satisfying all of the things.

Now, is this practical?  I don't know.  If the exchange can queue up withdrawals
for a long time, which may not be the case, but if they can, this could be an
option, this could actually work.  But it's something he explored and it's
something I think I'd like to see more exploration of in the future.

_Ark_

**Mike Schmidt**: Last item from May was the Ark protocol that we covered, and
we mentioned earlier the idea of joinpools which is allowing multiple users to
trustlessly share ownership of a UTXO.  So I'm curious, Dave, joinpool, at least
the idea, has been around for a while, so why is Ark so special?

**Dave Harding**: Well, I think the key innovation in Ark is this sort of expiry
notion, so it automatically expires after a period of time.  I believed Burak
proposed one month, but obviously as this gets nearer to production, they'll
probably play around with values and there could be different service providers
that have different values.  But basically, you can trustlessly withdraw your
money from a contract that involves multiple people and at the end of the month,
any remaining value in that contract rolls over to the service provider.  This
allows the service provider to do a whole bunch of interesting things instantly,
and still you're trustless because you can withdraw if the service provider
doesn't allow you.  So, for example, by agreeing to forfeit your claim on your
portion of the shared funds, by forfeiting those funds to the service provider,
the service provider can send your money over LN for you, or can roll it over
into a new contract where you're also sharing funds with a bunch of people.

It's just a really interesting construction, and we've actually seen it adopted
in other places.  For example, if you go back to the soft fork section, there's
a proposal from John Law that uses a similar construction to scale up LN to
potentially billions of users without changing the onchain footprint.  Is that
practical?  I don't know, this is still discussion stuff.  But it's just a
really interesting idea.  Again, its key feature is this sort of automatic
expiry, but that allows you to use it trustlessly up until that expiry,
including withdrawing before that expiry.  So, as long as you obey the protocol,
your funds can't be stolen, but it allows the very efficient use of onchain
space.

**Mike Schmidt**: Brandon?

**Brandon Black**: Yeah, I thought I'd give a name to this.  I don't know if
they're still using it, but they called it an Anchor Time Locked Contract, was
the name they used, ATLC.  And it's a great little unit of Bitcoin development
where you can say, "This transaction only becomes valid if this other
transaction appears onchain".  And so, when you have some kind of a way to
predict future txids, you can then make something that depends on a future txid
appearing, and that's kind of the key thing that enables Ark, is that anchor
lock.

_Silent payments_

**Mike Schmidt**: Moving on to June, we highlighted silent payments.  And I
guess in June, we had the BIP for silent payments, and there's been a bunch of
work including a PR that we covered in the PR Review Club Meeting later in the
year, silent payments being a reusable payment code.  I believe it's a
bech32m-formatted payment code that you could post, for example, if you were an
organization funding Bitcoin Core development and you wanted to take donations
and you wanted to post a static address online; you can post that payment code,
which is not a Bitcoin address, but you can derive Bitcoin addresses from there
and then any donations made to that organization, folks would not be able to
track that by having a single Bitcoin address on the website.  So, pretty cool
there.  Murch or Dave, I'm sure you have something to augment on that.

**Mark Erhardt**: Yeah, sure.  I'm pretty excited about silent payments because
it takes an idea that is very old and really deeply dives into the trade-offs
and the design space, and comes up with something that is always recoverable
from onchain and does not require extra block space or notification
transactions, and nobody can ever see that two outputs belong together unless
they're spent together.  And the other interesting aspect of this is that you
get sender privacy, so the recipient cannot tell who sent the money to them
either.  I think that it is a very interesting new variant of doing a static
payment code, and I hope that once it's merged, a bunch of wallets will adopt
it, because I can totally see this sort of get an address book function and
other extensions that make it super-useful to Bitcoin users.

_Summary 2023: Security disclosures_

**Mike Schmidt**: We had another callout here after June, which is security
disclosures.  We talked about three of them this year.  The Milk Sad
vulnerability and Libbitcoin bx command, which due to a lack of entropy in that
tool resulted in wallets being created that eventually led to the theft of a
significant number of bitcoins.  The second vulnerability is fake funding, DoS
attack against LN nodes.  This is something that Matt Morehouse disclosed
responsibly and thus all affected nodes were able to update, and I don't think
we've seen any exploitation of that particular LN vulnerability, and it seems
like that fix sort of closed the issue.  Whereas this last security disclosure,
replacement cycling attacks against HTLCs, is something that there wasn't
necessarily a completely clean fix for.  The replacement cycling attack, which I
believe Antoine Riard disclosed, is something that we've gone over a few times
in depth.  But in terms of fixes, there's only the ability to increase the cost
of the attack and not necessarily prevent it wholly.

Murch, or Dave, I don't know if either of you want to explain what exactly is a
replacement cycling attack?  I think that's maybe one of these three
vulnerabilities that might be more interesting to jump into than the other two.

**Dave Harding**: So, replacement cycling is simply using RBF, transaction
replacement, to remove from mempools a transaction that at some point would have
done something, would have closed the channel in the correct state.  And by
doing that, you can close the channel in an incorrect state.  And I think the
solutions that have been deployed are probably entirely satisfactory.  They
don't guarantee that we're going to prevent this attack, but they're pretty good
and we have a very long piece about that in the linked article.  So, if you want
to get the details, go back and read that, it's got graphs and everything.  But
yeah, I think we're pretty good.  Some of the discussion is about perfect
solutions to this attack, and the only one of those I know that is an actual
perfect solution would require a soft fork and it's got some pretty significant
downsides.  So, I don't know that's ever going to happen, but I think we're
doing pretty good on this front.

But it's definitely something that people who are using HTLCs or PTLCs, these
timelock contracts, any sort of timelock contract, maybe even something like Ark
with its ATLCs, people who are designing, using these constructions and are
going to live in a world where replacements are common and expected, they need
to go back and look at these things and consider them.  And of course, there's
probably more we can do with the base layer to try to avoid these sort of
unfortunate replacements in the first place, maybe.

_Validating Lightning Signer_

**Mike Schmidt**: Moving on to July, we have two different Lightning-related
items that we highlighted in our year in review.  The first one is talking about
Validating Lightning Signer, VLS, and the beta of their project from July.  And
the idea behind VLS is that you separate the operation of the LN node itself
from the keys that can control the funds of that LN node.  So, you would have
the node processing the request, and for any signing that would be required,
some sort of remote signing device would be used instead of local keys.  There's
also then some checks that VLS does, and you can set some limitations there on
the signing side of things, so that you're not just blindly signing everything.
I think it's an interesting project.  Murch or Dave, any thoughts?

**Mark Erhardt**: I think what hasn't been mentioned in this context that much
yet is that similar principles also apply to other hardware signing devices for
onchain transactions.  So, you can increase the security of hardware signing
devices quite a bit by having some sort of policy framework that gets checked by
the hardware signing device, for example that a transaction to be signed needs
to be signed by some sort of author key that gets validated, or that there's
policies of, "I don't want to sign too much money if it's too big, I require
additional information or signatures to sign for stuff".  This happens more at
the enterprise level, but yeah, if we get this VLS up and running and
professional LN services adopted, I could see a bunch of the work also percolate
down to hardware signing for onchain transactions.

_LN developer meeting_

**Mike Schmidt**: Second lightning item from July is just a general discussion
from the Lightning Developer Meeting that was held in person, which covered a
variety of topics, some of which we've already discussed here.  But, Murch or
Dave, do you want to call out any of the topics from that meeting specifically
here?

**Mark Erhardt**: Well, I'm just excited about taproot tunnels, and there's
progress on that, but that's it.

_Onion messages_

**Mike Schmidt**: Moving on to August, we highlight support for onion messages
being added to the LN spec.  I think, Dave, you had mentioned that earlier in
the discussion, I forget when, maybe something about the progress that we've
made this year in calling out onion messages specifically.  Maybe you want to
elaborate on the importance of that.

**Dave Harding**: I don't know that onion messages are super important, but
they're one of the bases of BOLT12 offers, which I do think is important.  So,
onion messages, they use the same routing method as used on regular LN, but to
send a short message between nodes, and it's only one direction.  So, payments
in LN flow two directions.  So, you send the money locked up to a hash in one
direction and then when it gets accepted, the receiver releases the preimage for
that hash and the payments get resolved going back in that direction.  So, it
goes from the sender to the receiver and back.  And this requires nodes to store
data about the information that they have, about the payments they have
forwarded, and those payments are resolved.  Because onion messages are only one
directional, your node forwards it and then can forget about it entirely, except
for maybe keeping a little statistics to make sure its bandwidth isn't being
abused.

It's a very simple proposal.  It's better than the way people were sending
messages on LN before, which was using single satoshi payments that they would
then cancel.  That had all sorts of little problems about it.  So, this is a
much nicer way of allowing nodes to communicate.  And of course, because even
though the messages are one way, that doesn't mean they have to be only one
direction.  The sender can send to the receiver their return address.  They can
say, "Look, here's a message, and if you want to send me a reply, here's where
you send it".  And onion messages comply well with blinded paths, which we
discussed earlier.  So, instead of the sender telling the receiver their return
address, they send them a blinded path back to them.  So, the sender can contact
the receiver, and the receiver might be themselves using a blinded path, and the
receiver can then go back and contact the sender, again using a blinded path, so
neither one of them learns their locations on the network.  So, this is a really
nice communication protocol for LN.  I think Murch has something to say.

**Mark Erhardt**: I just wanted to repeat that metaphor from before.  Basically,
you get to use a post box in each direction now, and maybe that's also a general
comment on LN development this year; receiver privacy got much better.  We
already had very good sender privacy, in that the sender built the onion route
and then any hop after them never knew more than just the hop before and after,
didn't know where it originated, didn't know the destination.  But with now the
blinded paths adoption, we also get receiver privacy, where the destination
might be unknown to the sender.

_Outdated backup proofs_

**Mike Schmidt**: We talked a little bit earlier in our discussion about peer
backups in the context of LN, and this next item potentially harkens back to
that, which is Thomas Voegtlin's proposal that would actually be, there would be
a fraud proof and a penalty for providers offering outdated backup states to
users.  Dave, is this just for peer backups of LN channels, or could this be
used in a broader context?

**Dave Harding**: Could be used for anything, anything where you want to give
somebody multiple different versions of something, but you only want them to
return to you the most recent version.  You can do this right now, no changes to
Bitcoin, for just a fraud proof you can publish online.  You can put in a blog
post and say, "This person didn't do their job".  And if we made some consensus
changes to Bitcoin, or we found some clever cryptography, maybe something like
BitVM, I don't know, we could enforce that onchain.  So, you would have the
ability to say in an LN channel, but again this is a generic mechanism that
could be applied to other places.  In an LN channel, you could store your latest
state with your peer and if your peer gave you an outdated state and you were
able to prove it, you could close the channel on them and take all their money,
or even more than all their money if they were willing to put up an extra
deposit.

This would be very useful for any LN node, and especially nodes I think that are
using LSPs, where there's already kind of a relationship there.  You can use it
today with LN nodes with LSPs, where they have an established business entity
and proving that that business violated the protocol, you could use it today to
say, "Look, don't do business with XYZ".  So, it's a very nice, simple, clever
protocol with immediate benefits and potentially could long term become baked
into protocols like LN or DLCs or other protocols where it's critical that
everybody has their latest state, but you have real people with real computers
that might crash sometimes, so you need to be able to recover that state with as
little fanfare as possible.

_Simple taproot channels_

**Mike Schmidt**: Murch, when we talked about the Lightning Developer Meeting in
July, you said one thing that you were excited about is taproot channels.  And
that's the last item from August here, is LND adding experimental support for
simple taproot channels.  Why do we care about simple taproot channels; what do
we get out of that?

**Mark Erhardt**: So, one downside of Lightning channels in general is -- so,
they use 2-of-2 multisig outputs, and these are scripted outputs.  So,
basically, if you look at the blockchain and you see a 2-of-2 output being
spent, you can guess that was probably a Lightning channel.  When you make the
funding output a P2TR output, and especially when the two channel partners close
the channel eventually cooperatively or do a splice, while they're doing this
cooperatively and the P2TR output is spent with MuSig, it looks like any other
single-sig P2TR output being spent.  And especially with splicing, you wouldn't
necessarily get this very long-lived UTXO that just sits around forever.  So, as
long as we have an unannounced channel, a cooperative close, we would never even
know that this output was used to create a Lightning channel.

If we manage to get a way with which we can announce channels without revealing
what funding output exactly they refer to, we might have the ability to no
longer have Lightning channels be linked to onchain outputs at all.  So, we just
see P2TR outputs, and P2TR outputs get spent on a keypath spend later, and we
would never be the wiser just from observing the onchain traffic, and even with
the channel announcements on the LN that these outputs were funding outputs to
channels.

_Compressed Bitcoin transactions_

**Mike Schmidt**: Next item from the Year in Review is this discussion in the
proposal around Bitcoin transaction compression.  Tom Briar posted this idea to
the Bitcoin-Dev mailing list, a way to make a Bitcoin transaction smaller using
some different approaches for saving space on fields within the transaction.
And the idea here would be that on low-bandwidth transmission capability media,
you'd be able to use this compressed transaction version, potentially.  This is
not a proposal per se to redo the Bitcoin P2P Network to use this, but for if
you're passing transactions outside of the P2P Network on a low-bandwidth
device.  Go ahead, Murch.

**Mark Erhardt**: I wanted to correct you here a little bit.  This sounded like
the transaction itself is getting smaller, but what we're only talking about is
the serialization of the transaction being compressed.  So, the transaction
itself will still have the same size on P2P Network, and especially what is
written into the blockchain must of course adhere to the consensus rules, but
this makes it easier to transfer all of the stuff you need to know in order to
recreate that standard representation smaller and cheaper.

**Mike Schmidt**: Yeah, that makes sense.  And I think the mediums that he
mentioned were, if you're transmitting these things via satellite or through
steganography, trying to encode a transaction into an image or whatnot.  So,
cool idea.

_Summary 2023: Major releases of popular infrastructure projects_

Next callout from the Year in Review is Major releases of popular infrastructure
projects.  I think in the interest of time, we should not go into each one of
these.  But I think folks should take a look and I think you'll see some common
threads throughout the year, especially on the LN side of things, lots of
mentioning of dual funding and offers protocol, lots of mention of splicing.
And so, I think you can see some of these ideas maturing throughout the year if
you sort of scroll through the list that we put together.  We discussed a bit
about the big pieces in Bitcoin Core 26.0, including v2 transport and
assumeUTXO.  Maybe, Dave or Murch, do you want to jump into that any more, or do
you think we touted that enough so far?

**Dave Harding**: I don't have any comments on that specifically.  I just wanted
to mention, you asked earlier in the show how I thought this year compared to
previous years, and I think this is the biggest and most impactful year of
actual code released that we've covered so far.  So, that's a really nice
signal, I think.

**Mike Schmidt**: Awesome.  So, if you're curious about some of the details,
jump into the newsletter and check this out yourself.  I don't think it's worth
going into it, given we're at the two-hour mark already.

_Payment switching and splitting_

October, we talked about this idea of payment splitting and switching from Gijs,
I believe, Gijs Van Dam, and we actually had him on the show in October to go
through some of the idea around payment splitting and switching, which I don't
feel like I am capable of summarizing in two sentences, but Dave or Murch, do
you?

**Mark Erhardt**: If I remember correctly, this was about when you forward
payments in Lightning, instead of directly using the next hop and a single
channel in there, you could sort of make a mini parallel payment where you split
up a forward that instead of covering that single hop exactly on how you were
directed by the sender, you would split it and route part of it through another
node.  So for example, if you have Alice, Bob and Charlie, Alice is forwarding
to Bob and Charlie is a parallel node that has both a connection to Alice and to
Bob.  You could split it 50-50 and half of it goes through Charlie to Bob.  And
basically, there's some nifty thinking here on how to locally split a forwarding
instead of just forwarding it directly, and this could make it, like if you
don't have enough funds in the next hop directly, you could sort of do a JIT
routing sort of operation in order to move the funds in parallel instead.  And
this also helps improve privacy.

_Sidepools_

**Mike Schmidt**: We talked about coinpools earlier and there's a similarly
named sidepools, that ZmnSCPxj proposed in October, with the goal of hopefully
enhancing Lightning liquidity management.  Dave, how does that work?

**Dave Harding**: Basically, the idea there is for nodes that are providing a
lot of forwarding service, so they're forwarding services, they're really big on
this, a bunch of them are going to get together and open a single UTXO that they
share.  And similar to sharing a Lightning channel between two nodes, they can
transfer balance around between each other, so you can have multiple people.
And the idea there is they're only going to use this once or twice a day to
rebalance their channels.  So, you can rebalance on LN now, at least in theory.
It's not very well supported by the software, but you can rebalance channels
using your existing software.  But this would be a reserve pool of funds that
these channels would have, and they would all get together, a bunch of operators
get together at a particular time every day and just do a big rebalance of their
channels.

Rebalancing is really useful for LN for forwarding notes, because funds tend to
flow more in one direction than the other.  That makes these channels imbalance
and once the channel gets too imbalanced, it can't forward any more funds.  So,
these rebalancing operations will make payments more reliable for everybody and,
yeah, I think Murch mentioned earlier that he thinks this high-fee regime will
encourage people to work on these solutions next year, so just proposing them,
and ZmnSCPxj has told me that he is actually working on code for this, so
hopefully we will see it sooner than later.  Go ahead, Murch.

**Mark Erhardt**: I wanted to highlight an advantage of this over just having
these same funds in big channels that you could use to rebalance.  So, if you
have these staged funds and they're owned by multiple people, not just two,
essentially you get some of the benefits that you would get out of channel
factories where instead of just being able to allocate funds to the channel
partner of a lightning channel, you can of course allocate funds to any of the
other participants in the channel from your own balance.  So, what it basically
can be thought of as, when you open a channel with five other peers, you get the
superset of all the channels that would be possible between all of those peers
at that time.  And by having a relatively big group, compared to at least
Lightning channels, you can use funds in all of these directions at the same
time.

Since you are sort of doing an out-of-band swap between your Lightning channel
balance and this fund in the side pool, you do not exhaust liquidity in other
Lightning channels in order to move the funds to the channel that you are trying
to rebalance, you can directly rebalance a channel and sort of teleport the
funds from the sidepool.  So, it both doesn't interrupt the rest of the LN and
shift other balances out of the way there, and you get the superset of all
possible channels between the participants.

**Mike Schmidt**: Dave, you said ZmnSCPxj's actively working towards some of
this?

**Dave Harding**: That's what he told me.  I corresponded with him a bit about
this before we wrote about it and he said this is his next big project, so we'll
see what happens.  No pressure, ZmnSCPxj!

_AssumeUTXO_

**Mike Schmidt**: Amazing.  I'll put it on my look-forward-to-2024 list.  Next
two items are significant projects within Bitcoin Core that have been in
progress for several years, in some cases multiple owners, definitely multiple
contributors, and they were merged in time for version 26.0.  The first one is
assumeUTXO that we spoke about, and the second one is BIP324, implemented v2
encrypted P2P transport, encrypting traffic between nodes.  I think I would echo
Dave's sentiment that it's nice to see long-term projects being able to garner
attention from developers, whether that's code authorship or review or testing,
and getting those across the finish line when those folks decide to put their
time towards it.  So, great to see.  There could be a lot said about both of
these.  I think we have, over many months, said quite a few words about them,
but Dave or Murch, anything to add?

_Version 2 P2P transport_

**Mark Erhardt**: I think that at least BIP324 is also later its own -- I don't
know, never mind, this is its own topic!  I think that there is some stuff
coming down the pipeline here that is going to significantly improve sort of the
resilience of the network to surveillance.  And I think it's high time that we
work more towards that, just because before that it was too cheap to get a good
sense of everything that was going on on the Bitcoin Network.  And yeah, so I'm
excited to see this work happening.

_Miniscript_

**Mike Schmidt**: Next section from October, we talked about miniscript
descriptor, getting additional improvements, and also the ability to create
miniscript descriptors for P2WSH outputs, and also miniscript support related to
taproot.  Some of those were in earlier months, but we correlated all that here
in this paragraph.  And yes, the October miniscript support to support taproot,
we had Antoine on the show talking about tap miniscript, which is the title of
the corresponding PR in Bitcoin Core.  Murch, I know you're a miniscript guy.
You want to add anything to that?

**Mark Erhardt**: So, this ties in nicely with a bunch of other things that have
been happening in the wallet story.  So, PSBTs have gotten a lot more adopted
this year, descriptors have arrived in the Bitcoin Core wallet, or maybe that
was last year, but now it's the default.  And with miniscript, what we get is we
get a very accessible way of defining complex payment conditions that we can
easily backup because they're compatible with output descriptors.  So, I think
this is more one of those building blocks that will really come to fruition in
the next few years, but we've seen already a few projects that have started
building more complex output scripts that make use of miniscripts.  So, for
example, you could have a taproot output that has a decaying multisig option.
So at first it's, I don't know, 3-of-3, and you can only spend it that way.  But
if you lose one of the keys, you get access to the money with two of the three
keys after a year.  And then maybe after two years, you get access with it with
only one of the three keys.  And all of that is hidden in the script tree of
that taproot output, but it is never seen onchain unless you need it.  But it's
riding along with your output every time you create an output.

This is, for example, exciting if you're willing Bitcoin to your descendants,
you could for example have just some timelock in your script tree that they
eventually get access to it, even if you don't formally transfer any key
material to them, because you can just put a key they already own in there that
only becomes valid after some time.  And I'm sure there is going to be a bunch
of other innovation of what people can do with this, but it's just never been as
accessible to wallet developers.

_State compression and BitVM_

**Mike Schmidt**: Last item from October involves some Bitcoin zero-knowledge.
Robin Linus posted to the Dev mailing list, and I think he was working with
Lukas George, using validity proofs, and specifically they had a prototype
running that proved the amount of cumulative proof of work in a chain of block
headers, and also then allowed a client to verify that a particular block header
was part of that valid chain, which is super-cool.  You see the zero-knowledge
stuff around, not too much in Bitcoin, although there's more discussion about it
lately, and I think that was a cool prototype.  I'll pause at that item, and
Dave or Murch, do you have any comments on that?

**Dave Harding**: I think it's just a really cool thing.  You can think about
how it might compare to assumeUTXO.  Like, if we got this working really well
and we were convinced it was secure and everything else went right, we could
allow a Bitcoin Core client to start off and do its initial stake using just a
validity proof.  And so, you would know that all the blocks, all your UTXO set,
had been completely verified by another client.  You would have the proof of
that, but you wouldn't have to do the verification yourself.  So, it's a nice
feature there, but it's also a nice feature for a bunch of interesting contracts
that they're talking about.

They're talking about a conversion of RGB or taproot assets, which could be even
more private because right now in those client-side validated protocols, you do
need to transfer proofs of all the previous state changes that affect the tokens
that you're about to receive.  And with this, the validity proof, you can only
transfer maybe a few megabytes of data that would be completely private and
opaque to you, but would give you a complete assurance that the tokens you were
receiving had been previously validated correctly by all users.  So, it's a nice
improvement.  I'm glad to see people working on this kind of stuff.

**Mike Schmidt**: Next item from October is payments contingent on arbitrary
computation, aka what you've seen around as BitVM, which allows a large
arbitrary program to be broken down to some very basic primitives and then
essentially stuffed into a taproot tree, and allows you to do some interesting
verification and program execution, although there is a substantial amount of
offline processing that's required then to run and validate that.  This seems
interesting to me, we've covered it a few times.  I can't say I understand fully
the technicals, but it does seem like it's got a lot of potential and there's a
lot of interested parties contributing and building on top of this.  Murch,
Dave?

**Mark Erhardt**: I think this ties back a little bit to what I said about
having the actual contract logic live out of band, and just proving that it was
executed correctly.  From how I understand this, basically it allows you to
construct some sort of program out of band that you agree on being the
conditions of your contract, and only as long as everyone agrees, you just do
the simple thing, you spend the funds together.  If there's a conflict or
someone tries to cheat, you can prove that they cheated with a series of
transactions onchain.  So basically, you run a little program in a succession of
Bitcoin transactions that proves that the funds really belong to you.  That's
roughly the understanding that I got and what you can do with it.  I think that
this is more of a five to ten years out sort of proposal.

There's been some discussion of very small building blocks, but from what I can
tell you, it would basically have to implement a whole second-layer programming
language in order to be able to have these contracts that can be broken down to
this series of transactions.  So, I think this might go into hiding a little bit
if it continues to be pursued, and might actually have a big reappearance in
five to ten years.

**Mike Schmidt**: Dave, any thoughts on BitVM?

**Dave Harding**: One of the things I like about it, which is purely
argumentative, is that for a while some people have had concerns about recursive
covenants on Bitcoin.  And at least for contracts involving a counterparty,
because you require a counterparty to use BitVM, you can't enforce arbitrary
contracts, but it kind of it shows that some of the things that people feared
are already possible in Bitcoin and if they're not a major problem now, maybe
they won't be a major problem in the future and we can be a little bit more
flexible in what options we consider for upgrading Bitcoin in the future.  But I
think it's a really nice, if theoretical, concept that also has practical
implications, but I think it's a really nice theoretical concept for thinking
about what's possible in Bitcoin and where we might want to go in the future to
make this stuff not just possible, but easy to use.

_Offers_

**Mike Schmidt**: Moving on to November, earlier in our discussions, we
elaborated a bit on blinded paths and onion messages and some of the
implementation thereof, and here in November, we're talking about offers that
depends on them.  And we sort of walked through a summary of the offers
protocol, also talking about some of the evolution of CLN and Eclair, and
updates to LDK associated with offers.  And then we also had a discussion with
t-bast in November about an updated version of Lightning addresses that is
compatible with offers.  Murch or Dave, anything to add there?

**Dave Harding**: Just again, I know I keep saying this and I know you guys are
probably tired of me saying this, I think this is another really nice upgrade to
Lightning and to the user experience.  Offers, it makes it a lot easier to do a
bunch of things in Bitcoin and Lightning related to payments than it is now.
For example, you'll get t-bast's proposal for adding basically LN address
support to offers.  It allows you to do LN addresses kind of stuff entirely
through the Lightning protocol.  You don't need to use an HTTP server, an SSL
certificate, you don't need to set that up, you don't need to manage it, people
can just use it with a small thing in their DNS, or whatever.  And for stuff
like repeated payments or for static payments where you have a code that people
just scan and they can pay you, or subscriptions, you have all this stuff that's
just enabled by this really nice protocol.  It's just going to make using
Lightning a lot nicer.

One of the things I think it will help with a lot is just using accurate
pricing, for stuff that's priced in fiat.  Because offers protocol allows the
spender and the receiver to have a back-and-forth communication about how much
to pay.  It makes a lot of those things, like fiat exchange rates and making
sure you pay instantly and handling payment failures, a lot easier for users.
It's all going to happen in the background, the users won't see it, and
hopefully it'll just work a greater percentage of the time.  So, I'm excited
about this, sorry for rambling!

_Liquidity advertisements_

**Mike Schmidt**: Always good to hear a Harding ramble!  The last update from
November is around the spec for liquidity ads, which had some reinvigorated
discussion over the last few weeks.  Dave and Murch, I know you guys spoke with
t-bast last week about some of the potential considerations or potential
downsides with liquidity ads, and I think we had nifty and t-bast on a few weeks
ago to talk similarly.  Maybe based on your conversations last week, what's the
state of liquidity ads that you think you'd summarize for folks?

**Dave Harding**: I don't think there's any downsides to liquidity ads
themselves.  We were just talking through the implications of a particular way
of doing them, of committing to the length of time you want the channel to stay
open after you buy liquidity.  The advertisements themselves, they're really
good.  I mean, if you're going to go for a downside, dual-funded channels are a
little bit more complex than single-funded channels, but the ability to have a
contribution by both parties to the channel is definitely worth it.  And I like
to point out that dual-funded channels is actually the original design for LN,
and the developers realized that they could use single-funded as a
simplification to get it out the door earlier.  But dual-funded is really the
way to go.  And liquidity to advertisers is just going to allow better
management of your funds, especially at people who want to receive money, which
I usually focus on the business side of that, because businesses obviously have
a need to receive funds for customers.  But when I open up my Phoenix wallet
now, and I see it has a little liquidity button at the top, I realize, yeah, I
might want to get paid more than my current channel balance allows, and I can
now click this button and it'll do a splice-in liquidity for me and I'll be able
to receive that $100 or $200 payment that I couldn't receive before.

So, it's a really nice feature.  I'm excited to see that start getting deployed
hopefully next year.  Right now, it's just specified but it's implemented in two
clients and hopefully it'll get into the full specification and it'll get
deployed more and more next year.

**Mike Schmidt**: As we move into December, I wanted to solicit again from the
audience, if there's any questions or comments you have for Dave, myself, or
Murch, feel free to ask away.  Otherwise, after we wrap up December, we'll wrap
up.

_Cluster mempool_

First item from December is about Cluster Mempool, which is a little bit under
the hood in Bitcoin Core, redesigning the way that the mempool works to simplify
certain operations.  We dug deeply into the topic with one of the folks
contributing, Pieter Wuille, in Recap #280 and we dug into that for about 30
minutes with him.  So, if you're curious the details there, jump into that.
Murch or Dave, what would you like to highlight about cluster mempool and the
discussions that have been going on on the Delving Bitcoin forum?

**Mark Erhardt**: Have you heard about our Lord and Savior, cluster mempool?!
No, I think it's just addressing so many of the issues that we've been having
with mempool around eviction, maybe a little bit around pinning; it'll make RBF
better, it'll make package relay much, much easier, it'll make block building
both better and faster.  I think it is just on overall huge upgrade on how
mempool will work in Bitcoin Core.  This is just an implementation detail
really, but I think it will also bleed a little bit into the policy of Bitcoin
Core, like what might be able to get into mempools and what might get
propagated.  So, I think this is the most significant update to how we think the
mempool works since probably 2015.

**Dave Harding**: Part of my job in choosing topics for the newsletter, I look
to see what is getting developers excited.  And if you just heard the way Murch
was talking about mempool, there are a lot of people talking about cluster
mempool the same way, with the same enthusiasm.  So, I think this is definitely
something we're going to see a lot of work on, a lot of excitement about in the
future.

_Warnet_

**Mike Schmidt**: Last item from our Year in Review is discussion about warnet,
which is a tool that came out of some of the Bitcoin developers scratching their
own itch and needing a way to test and simulate different P2P topologies of
Bitcoin Core nodes, although I think additional nodes are supported or plan to
be supported.  And how it works is you can set up a topology of nodes and how
they are connected and different versions of Bitcoin Core software on a testnet.
You hit a button, and those are essentially spawned and begin interacting with
each other, and you can customize certain interactions using scenarios, which
are ways of the network behaving.  I suppose, for example, before the Ordinals
craze took off, somebody could have had a similar idea for such a pathological
scenario on warnet and fired up a bunch of activity and potentially diagnosed
some pitfalls that could have occurred with such volume on the network.  And so,
warnet's a tool for that, it's a very interesting one, I think, and we had on
the show, for Recap #281, some folks talking about warnet and the use cases for
that.  I think we had Zipkin on talking about some of the research that he's
done using warnet for a particular PR, showing how it behaves under such stress.
So, cool tool, Murch?

**Mark Erhardt**: Yeah, I just wanted to illustrate a little bit what that can
be used for.  So for example, we had this big discussion towards the end of the
last year about mempoolfullrbf, and one question that was open in that regard
is, how many nodes actually have to flip the flag in order for transactions to
propagate with full-RBF without having signaled?  And there were some thoughts
on that and some calculations, but being able to actually spin up a few nodes
and see how much nodes you have to flip the flag on in order for transactions to
propagate in this network is something that you could test on a warnet with this
tool.  So, it just gives us tools to evaluate sort of these emergent behaviors
on the whole network that come to pass due to many different versions, having
different configurations, mempool sizes, flags, preferences on peering, and so
forth, and simulating these and getting statistics on stuff rather than just gut
feelings.

**Mike Schmidt**: Dave, Murch, any final parting words for the audience as we
wrap up our Year in Review and our content for the year from Optech?

**Mark Erhardt**: I just wanted to say it's been a really cool experience to
host the recap all year.  I hope that people are getting stuff out of this.
Yeah, I hope to be doing this for some time longer and we always love to hear
from you guys if you enjoy it.  And other than that, thank you, Mike, for doing
your excellent preparation every week, thank you, Dave, for pioneering a
kick-ass newsletter every week, and I'll see you next year.

**Jameson Lopp**: Yeah, if there's I guess one thing I can contribute here, is I
think it's amazing that the ecosystem has grown to the point where there is so
much development going on that there's actually a need for this type of recap.
So, I think positive idea all around that we have even gotten to this point, and
glad to see those of you who are contributing to help distill a lot of these
really, really technical and nuanced conversations.

**Mike Schmidt**: Thank you especially to Dave Harding, who is the primary
author of the newsletter, and I believe the sole author of this giant writeup
for the end of year.  And obviously, we want to thank all of the contributors
who contributed to the projects, ideas, discussions, mailing-list posts that
spawned all of the summaries that Dave spearheaded this year.  Dave, were you
going to say something?

**Dave Harding**: That was basically it.  I'm really, really thankful to all the
developers and just everybody who's making meaningful contributions to these
discussions.  I love just writing about your work, it's very inspiring to me.  I
hope it helps that I'm able to summarize this stuff, but it's just even if I
wasn't writing about it, I'm just very, very grateful to everybody who's working
on Bitcoin, so thank you all.

**Mike Schmidt**: Happy New Year everybody, and we will be back with our regular
publication on Wednesday, January 3.  Happy holidays and Happy New Year till
then.  Cheers!

{% include references.md %}
