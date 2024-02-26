---
title: 'Bitcoin Optech Newsletter #281 Recap Podcast'
permalink: /en/podcast/2023/12/14/
reference: /en/newsletters/2023/12/13/
name: 2023-12-14-recap
slug: 2023-12-14-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Dave Harding are joined by Bastien Teinturier and Rodolfo Novak to
discuss [Newsletter #281]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-11-19/fcb26684-880f-083e-f42e-97ffcc9fd80e.MP3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome to Bitcoin Optech Newsletter #281 Recap.  We are today
doing this without Mike, so you'll have the pleasure of me trying to walk us
through a newsletter here.  I have Dave here as a co-host today, and we are
joined by t-bast.  Dave, do you want to introduce yourself?

**Dave Harding**: Hi, I'm Dave Harding, I'm the co-author of the Optech
Newsletter and of Mastering Bitcoin 3rd edition.

**Mark Erhardt**: T-bast?

**Bastien Teinturier**: Hi, I'm Bastien, I'm working on Lightning, Eclair and
Phoenix.

_Discussion about griefing liquidity ads_

**Mark Erhardt**: Yeah, and I myself, I'm Murch, I work at Chaincode Labs and I
contribute to Bitcoin Optech.  All right, so our main news item today is the
discussion about griefing liquidity ads.  Some of you might remember that we had
been talking about this topic just two weeks ago in Recap #279, where we also
had t-bast on.  This is about the possibility that when you rent liquidity from
a Lightning ad provider, that you are not restrained on the amount that you can
put on your end of that channel.  And if the other party, for example, gives you
10,000 sats liquidity, you might put 10 times as much on your side, so you
actually would be able to push 11 times the total amount to the other side, and
the funds would be locked up for the entire time of when that channel was
rented.  It sounds like the discussion continued on the Lightning mailing list,
or where are you discussing these days?  Have you moved to your forum yet?

**Bastien Teinturier**: No, we haven't yet.  We're experimenting with Delving
Bitcoin or potentially Discourse, but we are mostly doing everything on the
mailing list until the end of the year.

**Mark Erhardt**: Right.  So anyway, would you like to summarize or recap what's
been going on in this discussion?

**Bastien Teinturier**: Yeah, of course.  So a lot has happened since two weeks
ago, where we were starting to discover all the potential subtleties about what
you are actually buying when you are buying inbound liquidity, so I'm going to
try to walk you through the thought process and how the design evolved based on
the thought process.  So, the overall goal is to allow people to ask other nodes
to pay other nodes so that the other nodes add some funds on their side of the
channel, so that new nodes that join the network are able to have inbound
liquidity, receiving capacity, to make sure that they are able to receive
payments over LN.  So once you start wanting to do that, the obvious thing is
then we just need the seller to be able to advertise their rates, how much
buyers would need to pay if the seller has to add more liquidity to a channel,
and initially we only did that.

But then we thought the issue is that if Alice buys liquidity from Bob, she pays
Bob at time t, they make a splice or create a channel, and in that channel then
Bob has liquidity on his side.  Then nothing prevents Bob from just closing the
channel immediately and being paid for the liquidity, but then getting that
liquidity back.  So, we thought that we should add a duration to those purchases
and we should enforce those durations on the seller side, add the
CHECKLOCKTIMEVERIFY (CLTV) in the transactions to make sure that if Alice wants
to buy liquidity for one month, then Bob's output in the commitment transaction
is going to have a one month CLTV so that if Bob force closes, his funds are
still locked.

That looked like a good idea because it protects buyers, but then it actually
harms sellers, because the buyers can actually grief the sellers because of the
attack that we mentioned two weeks ago, where Alice can buy 1 sat of inbound
liquidity from Bob and then she can splice in 1 bitcoin and then push those
bitcoin to Bob's side, and Bob has only been paid for 1 sat, for example, for a
month or two months or three months, but then he has 1 bitcoin of liquidity that
is locked.  And that is an issue, especially since there's going to be a lot
less sellers than buyers in that market.  Buyers are mostly going to be a lot of
anonymous nodes that just joined the network, want to get inbound liquidity, and
they will turn to, I guess, a smallish number of sellers that are well
positioned in the graph.  And so, the number of sellers is going to be much
higher than the number of buyers, and sellers will have a more long-lived
reputation.  So in this attack, sellers are taking too large of a risk compared
to the risk that buyers are taking.

So initially, what I started thinking two weeks ago was that we could just split
the seller's output into two parts.  One part would be the amount that the buyer
has purchased, and in that part we would put a CLTV; and the other part, another
output on the transaction, would use the normal funds of the seller.  This is
actually doable, we can do that, but it creates a lot of complexities,
especially when you start potentially having multiple purchases at the same
time.  For example, Alice starts by buying 10,000 sats for one month, but then
two weeks later, she wants to buy 50,000 sats for three months, then one week
later, she wants to buy another amount for another duration; you have a lot of
leases that are active at the same time.  This is totally doable at the protocol
level, we can handle that, but it adds a lot of complexity and it creates a lot
more outputs in the commitment transaction, which is something that is annoying
for the seller, because if there's a forced close, the seller has many outputs
that they need to claim onchain, which is costly because they need to provide a
witness for the script.

So, it is another way that the buyer can slightly harm the seller, even though
the seller could choose to reject more purchases to ensure that they only have
one additional output.  But even adding one new output has a lot of interactions
with many other parts of LN and many other features in LN, so it really adds
complexity.  So at that point, we started to take a step back and think about
whether those CLTVs are actually really worthwhile and what we actually really
want to achieve here, because those CLTVs have a lot of complexity and it looks
like their only goal is to protect the buyer from the seller just going away
with the liquidity instantly.  But there are a lot of things to consider here.

First is that the sellers really have an incentive for that liquidity to be
used.  They are selling their liquidity so that a normal buyer will buy
liquidity that they will actually use, which will result in routing fees for the
seller, which is a healthy incentive for both the buyer and the seller.  What we
actually really want to achieve is that the buyer and the seller create a
relationship where if everyone is benefiting from the situation, the seller is
going to keep adding inbound liquidity to the buyer, because this is something
that also makes them earn money.  And the buyer wants to have inbound liquidity
almost all the time, at least as much as possible, and that cannot be really
protected by CLTVs.  Oh, I didn't see that, Murch, you had a question?

**Mark Erhardt**: Yeah, I just wanted to ask, so if one of the main issues with
this griefing opportunity is that the buyer can add an unlimited amount of
liquidity on their side, why don't liquidity ads just also restrict the buyer's
side?  So if you make an ad you say, "I'm offering 100,000 sats of liquidity,
but no more of 1 billion on the buyer's side", or something like that.  Wouldn't
that be a way forward to restrict the griefing potential?

**Bastien Teinturier**: It would restrict the griefing potential, but it's kind
of a tragedy of the commons because an honest buyer, you are really happy if an
honest buyer adds a lot of liquidity, because whenever they push liquidity to
your side, they are actually making you relay those funds to an outgoing channel
while you are as a seller earning routing fees.  So, if that buyer is really
honest, you want them to push as much liquidity as they want.  You want all the
liquidity you can to be flowing in both directions, because that is what will
bring you the most revenues and that is what will give the buyer the best
experience as well, because they won't be restricted in how much they can send.
I think it would be a bad idea to restrict both this way buyers and sellers,
just because of the potential for attack on a very small number of attempts.  So
I really like to avoid that.

**Mark Erhardt**: I missed the connection there; now I see why you were talking
about that.  Okay, so you don't want to restrict the buyer side because that
actually makes more money for the liquidity ad provider, so what else happened
in this discussion since then?

**Bastien Teinturier**: So since then, I've tried implementing the solution
where we create a separate output with a CLTV, and I was really unhappy with all
the complexity that it brings because it interacts with fast closing, it
interacts with the channel reserves, because it interacts with the commitment
transaction fees.  It interacts with splicing as well, where you have to
consider in which output you put the funds.  It interacts with whenever you
relay, fulfill, and fail Hash Time Locked Contracts (HTLCs), you have to make
sure that you put the amounts in the right buckets.  So it's a lot of
complexity.  And we started shifting the discussion to whether that complexity
really is what we want, really fixes something that we really want to fix.

Personally, I think the sellers really have an incentive to play the game
honestly here because they have long-lived identity and they have less
incentives to cheat than the buyers, basically.  And we should not also restrict
the sellers too much because the sellers, to survive economically, they will
have to be able to allocate their liquidity efficiently.  And that's at the time
that they cannot predict, because that's when the mempool is going to be empty
and the fees are going to be low that they will want to take this opportunity to
be able to move liquidity to where it is needed the most.  And I think in that
case, they should be able to move liquidity from channels that are completely
idle to places where the liquidity is best used, because otherwise the sellers
will just end up going bankrupt because they don't make enough money to cover
their costs.

I think it's better to just rely on incentives on both sides to play honestly,
than to add CLTVs and create a very complex protocol that doesn't really fix the
incentives, because the CLTV would only guarantee that at most, the amount that
you paid for is going to be available in inbound liquidity.  But what you really
want to guarantee when you make purchases from a seller is that the seller is
going to do their best so that everything works well.  And most of the time,
they will add more liquidity than what you bought because you are potentially an
interesting node to route to.

So, the discussion is still ongoing.  There have been mails on the mailing list
in the past few days about that, and it looks like Keagan and Matt both agree
that the CLTV doesn't really fix the right things and adds a lot of complexity,
but I'm still waiting for feedback from more people to see if it would be
acceptable to do liquidity ads without any CLTV.  So, stay tuned to see how the
discussion evolves in the next weeks or months.

**Mark Erhardt**: All right, so basically the solution was over-engineered and
less tech will make it better by just allowing the market to resolve the stuff?

**Bastien Teinturier**: Yeah, I hope so.

**Mark Erhardt**: Dave, do you have any questions or comments?

**Dave Harding**: Yeah, I guess my question is, I mean I'm convinced by your
argument, but let's say we try it out and we don't use the CLTV, but a year from
now we decide that it's not working, people are closing channels way earlier
than they expected at least time and we want to try adding CLTV later.  How much
extra work do you think that will be for implementations versus doing it right
now from the start?  Do you think that's going to be roughly the same amount of
work as doing it now, or do you think it's going to be a lot more work to go
back and update everybody later on?

**Bastien Teinturier**: That was one of my arguments for not doing the CLTV
right now, is that it's not going to be harder to add it later, because
basically we can create the protocol with lease durations of zero or no lease
duration, which would indicate, "Do not add a CLTV".  And then later, we can
just add a new field that says, "Oh, by the way, I want that duration", and if
that field is present, then you do the version that uses CLTV.  So, I don't
think it would be hard to add it afterwards if we see that the version without
the CLTV is not good enough.  And this way, we can even support both in parallel
and the seller would advertise whether they offer only leases that don't use a
CLTV or leases that do use a CLTV, and buyers could also choose, depending on
whether they have implemented the CLTV version or not, to either use a CLTV or
not.  So, I think that's also a good argument to start without it, because we
always have the option to add it later without more complexity.

**Dave Harding**: That sounds very, very persuasive to me, for trying it out
without the CLTV.  And then, if people want to try to experiment, bring it
later.  The only other thing was, I have some recollection of some sort of
Lightning Labs product, it's not decentralized liquidity ads, it was a
centralized product.  I thought they were using something similar to a CLTV lock
on people who put liquidity into channels.  So, I guess if people use that other
system, there's kind of a parallel system and we can see how that works in
comparison, maybe.  Those are my only thoughts.

**Bastien Teinturier**: Yeah, I think this is called lightning Pool.  I don't
know if people are still using that.  And I think the only difference is that
they didn't realize that there was this potential griefing attack.  But also,
one of the reasons they didn't realize it is that they do not have dual-funded
channels and they do not have splicing, and it's dual-funded channels and
splicing that make it easier for the buyer to grief.  That's why they can just
put a CLTV directly on the output because the channel size is fixed.  I think
they use a different channel every time you want to buy a new lease, which is
something we want to avoid now that we have splicing and it's much more
efficient to have only one channel.

**Dave Harding**: Right.

**Mark Erhardt**: Thanks.  All right, I think if there's nothing else about
liquidity ads griefing, we would be moving on.  All right, cool.  So, our next
section in the newsletter is Changes to services and client software.  We have
seven updates here.

_Stratum v2 mining pool launches_

First is that the DEMAND mining pool started recently and it is offering a
Stratum v2-based solo mining pool and they're working on making pooled mining
with Stratum v2 happen soon as well.  So, this is the first Stratum v2-organized
pool in the world as far as I know, so that's interesting.  I'll just keep
moving unless you raise your hand, okay.  Oh, and t-bast, if you need to drop,
obviously we understand that you have a lot of things to do, but if you want to
stick around, you're welcome to stay.

**Bastien Teinturier**: Yeah, I'll stick around for ten minutes and then I'll
have to drop off.  Thanks.

_Bitcoin network simulation tool warnet announced_

**Mark Erhardt**: Thanks for joining us.  All right, second update.  We've
already talked a lot about that one last week, when we had Matthew Zipkin on.
The warnet software was announced.  Warnet is essentially a way of simulating a
whole Bitcoin Network with a number of different nodes.  You can specify those
nodes directly in scripts.  So you could, for example, run multiple nodes, some
of which are different versions than others, and you can use this warnet
software to observe how announcements of transactions and IPs and other P2P
behavior emerge across a network of nodes.  So, this is pretty cool stuff and
there's also ongoing collaboration with LN developers to basically use this as a
way to also simulate LN activity.

_Payjoin client for Bitcoin Core released_

Thirdly, we have a release of payjoin-cli, which is a Rust project that adds a
command line tool to send and receive payjoins with Bitcoin Core.  So, this is
coming from, we had Dan Gould on a while back, I don't remember exactly which
episode, and talked a bunch about the payjoin SDK, and this is coming out of
that same corner.  So, if you run payjoin-cli, there's a demo on the README
page, how to do payjoins with yourself on regtest.  I'm not entirely sure how
easy it is to set it up on mainnet, but presumably that's possible now, too.
Did you look more into this, Dave?

**Dave Harding**: I did look more into it, but we did cover, what is it, Payjoin
Rust, the Payjoin Developing Kit, a couple of months ago, so I wonder if this is
actually using that as a backend.  And it's really great to see.  Obviously, I
would prefer to have it directly implemented in Bitcoin Core, but having this as
a first step is really great.

_Call for community block arrival timestamps_

**Mark Erhardt**: Super, thanks.  The next item is a call for block arrival
timestamps.  So 0xB10C and some other people have been submitting the timestamps
extracted from their debug log of when their nodes first saw blocks, and this is
being collected in a GitHub repository.  If you're running a full node that is
always on and you're willing to just extract those timestamps, per height one
timestamp, there's a Python script in the repository that you can use to search
and extract the data from your debug log and submit it.  And I assume that this
is going to be used in -- well, it's publicly available and presumably
researchers are going to use it to look at how blocks propagate through the
network.  Any thoughts or comments so far?

**Dave Harding**: I mean, the only thing to really note is, for those who don't
know, blocks have a timestamp in them that theoretically tells you when that
block was created, but miners can fudge that date quite a lot, and for various
reasons, they do.  So, looking at people's logs for their nodes for when they
received the blocks can be much more accurate, in addition to telling you how
that block propagated on the network.  It just gives you an idea of when that
block was actually sent in the first place.

**Mark Erhardt**: Yeah, so the restrictions on block timestamps are actually
that each new block must be one second greater than the MTP of the prior blocks,
and that's the Median Time Passed, which is just the median timestamp of the
last 11 blocks.  And it also has to be earlier than two hours in the future of a
node's network time.  So, if your own node sees a block that has a timestamp
that's way in the future, it'll not accept it either.  And one of the things,
for example, is that mining pools give out block templates that mining pool
participants work on, but they might be working on those for 30 seconds or a
minute, so there's a discrepancy between the timestamp of the block template and
when the block was actually propagated.

Earlier, people were doing timestamp rolling in the block header as an
additional source of entropy, which I don't think has been happening much
anymore, because people are instead using overt ASICBoost and other techniques
to get more entropy out of the header without changing the coinbase.  So yeah,
anyway, it would be interesting to see how the blocks' arrival times diverge
from the timestamps in the block headers.

_Envoy 1.4 released_

Next, there was a release of Envoy 1.4.  This is Foundation's mobile wallet and
hardware wallet companion software.  It looks like it's adding coin control and
wallet labeling, with multisig support in the works, I think.  Sorry, no, not
multisig; what is BIP329?

**Dave Harding**: That's wallet labels.

_BBQr encoding scheme announced_

**Mark Erhardt**: Yeah, all right.  BBQr encoding scheme announced.  So, there
is a way of encoding larger files, for example PSBTs, into an animated series of
QR codes, and there's a standard for that now which you can use, for example, in
a setup where you have an air-gapped device that has a camera.  So, you would
just basically flash a number of QR codes in a row and transfer more data than
you can stuff into a single QR code, and this is called BBQr.

_Zeus v0.8.0 released_

Finally, there's a release of Zeus v0.8.0.  That looks like a huge release to
me.  I saw that it had more than 900 commits since v0.7.  And one of the things
that is supported there is zero-conf channel support, and I also saw that there
was simple taproot channel support in that release.  So, any more comments on
service and client software?

**Dave Harding**: Not really, just for those who might not know, simple taproot
channels is something that LND has been pioneering, and I don't know, I mean
maybe t-bast has some comments on the perspective of simple taproot channels
from other implementations.  But just as a technical background, my
understanding is what it does is it uses P2TR for the deposit transaction and
probably the other transactions too, and it also uses MuSig2 for the transaction
signing.  But it continues to use HTLCs for the actual payments, so it's still
compatible with payments relayed by other nodes on the network.  I don't know,
t-bast, did you have any comments on simple taproot channels?

**Bastien Teinturier**: Yeah, I think that they are experimenting with it, but
it's just a beta at that point because they are, the last time I checked, there
were some comments on the spec PR that required breaking changes on some of the
scripts to make them compatible with miniscript, for example.  And Laolu
confirmed that the version they rolled out in LND, they're explicitly using a
different feature bit to make sure that this is not the final spec version, and
that they can then later roll out the final spec version.  So right now, what
they're going to use will not be spec-compliant and will only work between LND
nodes.  But I hope that in the next, yeah, maybe two or three months, then we
can look in the spec and they can update to use the final version.  But it
should be compatible with any other LND node right now, and when the spec is
final it should then become compatible with other implementations.

**Mark Erhardt**: Super, that sounds great.  All right, we'll be moving on to
our monthly segment, Selected Q&A from the Bitcoin Stack Exchange.  We have five
questions, or five topics, some of which cover multiple questions.

_What are all the rules related to CPFP fee bumping?_

The first topic is whether there are any rules related to CPFP fee bumping.  And
Pieter Wuille points out that in contrast to RBF and all the rules surrounding
RBF for reprioritizing transactions, CPFP is simply emergent behavior from
transaction topology and there are no special additional policy rules regarding
CPFP.  Dave, if you want to jump in, just go ahead.  I'll leave a little bit of
a break.

**Dave Harding**: Okay.  Well, I mean while this answer is absolutely correct,
as you would expect from Pieter, I think it is worth noting is that the mempool
does have limits on the relationships between transactions and the size of
related transactions.  So you can't always get a transaction in the mempool to
use CPFP fee bumping; sometimes, you just can't get it in there for that to
work.  So I think it's just maybe a little confusing for people.  The limits for
the mempool can actually be listed in Bitcoin Core.  I think you have to do
bitcoind-debug-help, or it's help-debug, I can never remember the order of those
things.  But you can actually print out the rules there, at least most of them.
So, there are some things you have to think about if you're going to be using
CPFP fee bumping, but there's no specific rules, like Pieter says, for whether
that will work or not.

**Mark Erhardt**: Right, that's a good point.  So, the ancestor sets and
descendant sets of transactions are limited.  We currently, in Bitcoin Core by
default, only permit descendant sets of 25 and ancestor sets of 25.  So, if you
submit a transaction and one of its ancestors already has 24 other transactions
that in some way descend from that transaction, it will not be accepted into the
mempool, as an example.  We've been talking a lot about cluster mempool recently
here at our office, and the restrictions there would probably change a little
bit, but we would still probably have a limit on the size of a cluster.  We also
talked about this last week with Pieter when he was on.  So, these sorts of
limits are related; also related is the total size of these transactions.  So,
the entire descendant set or ancestor set of a transaction cannot exceed 100
kilo-vbyte (kvB) plus the carveout, I think, 101 plus carve-out.

**Dave Harding**: So just to pop in again, one of the ways people might see this
happen, where they can't do a CPFP fee bump in practice is, if they do a
withdrawal from an exchange and the exchange makes a pretty heavy batch, so the
exchange pays 100 people or even 500 people in the same transaction, and a bunch
of those people try to fee bump the exchange's transaction, they all create
childs, you might not be able to create an additional child.  We also, of
course, see it in high-level protocols like LN, but I think that exchange batch
payment is where people might actually run into the case where they want a CPFP
fee bump a transaction and they just can't, at least for the moment.

**Mark Erhardt**: Yeah, and another example is here, that the parent transaction
by itself just has such a low feerate that it is not permitted into the mempool
because it is below the dynamic minimum feerate, and then you can't CPFP because
even though you could submit a child for descendant limit reasons, the parent
cannot get into the mempool, and then the child is an orphan and will not be
propagated and added to the mempool either.  Okay, I think we've got this one
covered pretty well.

_How is the total number of RBF replaced transactions calculated?_

The next one is about how the total number of transactions that will be replaced
is calculated in replacement, RBF evaluation.  So, we had a user on Bitcoin
Stack Exchange in the past month that has been diving pretty deep on RBF topics,
so we had a whole battery of these.  One of questions here was, if you look at
the conflict set of a replacement, there is a quick check in the very beginning
of the RBF checks, which is whether it evicts or the replacement displaces more
than 100 transactions.  There is a way in how this check can overestimate the
number of transactions that are getting replaced, which is you go over the
direct conflicts of the replacement, and you just add up their descendant sets.
So, you might be noticing now, if some of the descendants of the direct
conflicts overlap, you would be counting them multiple times in this case.

So, the 100 limit is not actually enforced to the letter, you don't sum up and
get the whole transaction tree just to see whether it affects more or less than
100 transactions, you would just be counting the descendant set counts of the
direct conflicts, and you would fail to do a replacement if that is greater than
100.  All right, I think we exhausted that one already, so we're moving on.

_What types of RBF exist and which one does Bitcoin Core support and use by default?_

There's another question about RBF, and this was about what types of RBF exist,
which ones of those Bitcoin Core supports and uses by default.  So, this
question dove a little bit into the history of how RBF got implemented into the
possibility of having first-seen-safe (FSS) replaceability, which basically
required that a replacement transaction features all of the outputs across the
replaced transactions, so none of the payments could be dropped when you replace
a transaction, which then after being proposed and discussed for a while, never
got implemented.

So, the style of replacements that Bitcoin Core implements at this time is
opt-in full RBF.  So, you can only replace transactions that have signaled
replaceability, but then you can do anything you want with them.  You can drop
all the outputs, you can recombine them, you can divert the money back to
yourself.  So, if a transaction signals replaceability, it would be a warning
for any observer that this transaction is not reliable yet, like any other
unconfirmed transaction really but more explicitly, and that you should wait for
confirmation before relying on having been paid.  We also, of course, covered in
the last year that Bitcoin Core merged a configuration option for
mempoolfullrbf, which permits full replacement even on transactions that had not
signaled replaceability, if you turn it on and are relaying such transactions.

Yeah, so a big problem with the FSS replaceability would have, for example, been
that if you have a change output on your original transaction and then you
replace it, you first have to bring more funds in total, and then you'd have two
change outputs on the first replacement and so forth, because all of the outputs
of the original would have to reappear on the replacement, and there's no way
for the network to know which ones are the payments and which ones are the
change outputs, so there's really no way of not redoing change outputs if you
require FSS.  Do you have something to add here, Dave?

**Dave Harding**: One small correction.  I believe on the FSS, you do have to
bring in additional input, but you don't have to add additional output, because
the requirement is all the outputs have to be the same amount or greater.  But
still, it's just a pain no matter how you cut it.

**Mark Erhardt**: Right, so you could basically reuse the same destination for
the change output, but you'd have to increase the amount on it, and that would
also reveal, of course, to the observers which one was the change output.  All
right.

_What is the Block 1,983,702 Problem?_

We had a question about the 1,983,702 problem.  So, Antoine Poinsot gave an
overview of the history of BIP30 and BIP34 with duplicate transactions and the
mandate to put the block height into the coinbase transaction, and how that all
came to pass, because we had two pairs of duplicate transactions where some
miners reissued the same coinbase transaction on different blocks and overwrote
a prior coinbase output, so that actually it had not been spent yet.  It was
created twice and then of course could only be spent once afterwards.  So, 100
bitcoin were lost in that manner actually.

So, what is the 1,983,702 problem?  Well, it turns out that the way that BIP34
rule was implemented, it requires you to push the block height as the first few
characters in the coinbase field in the coinbase transaction, which really is
the input field of the coinbase transaction, but since the coinbase doesn't
spend an existing UTXO, it works differently than inputs on regular
transactions.  So, it turns out that all the random data that had been pushed
into coinbase fields before that point sometimes overlaps with the scheme of
pushing a block height, and there's a number of different blocks in the future
where some past coinbase would match the block height so someone could go and
repeat the same coinbase transaction in the future again.

Antoine explains all this and then in a related question, it was asked how
likely it is for the coinbase transaction to actually be repeated.  So, both
Antoine and myself go into detail on how likely that is, and in my opinion it's
pretty much a nothingburger, because repeating the coinbase transaction would
mean that someone has to give all the money that was paid out in the original
coinbase again to the same miners from back, I think it was 2011 or so.  So, if
someone really, really feels like giving a 170 bitcoins, because there was a
substantial amount of fees on that block, to a random bunch of miners from block
164,384, which would be 2011 or 2012 or so, then that would happen.  So, I don't
think people are going to be that generous and therefore we don't really have a
problem there.

**Dave Harding**: I have a few quick questions for you.  So, first of all, if
you repeat a coinbase from a previous epoch, you can only do that if the amount
of fees collected in that block equal or exceed the subsidy from that previous
epoch, right, because the coinbase transaction for the previous epoch is only
valid if it pays out an amount equal to the subsidy plus the fees, right?

**Mark Erhardt**: That is correct, yeah, and that was one of the
misunderstandings of the asker there, I think.  They were under the impression
that just because the coinbase transaction could match that of a prior block,
they could basically for free put it back into the later block and then create a
bunch of extra money and create inflation that way.  But of course the subsidy,
or rather the rules of how much money you're allowed to create in a block, are
checked based on the height of the new block.  So, if there's a new block now at
over 800,000, you're only allowed to trade 6 -- wait, sorry, this is block
height 1,983,702, so the subsidy would only be 97 millibitcoin plus change.  And
to pay out a 170 bitcoin to the recipients of the coinbase, they'd have to
collect a whopping 169.9 bitcoin in fees, just to pay it out and give it away to
the original miners of that old block.

**Dave Harding**: That's pretty cost prohibitive.  And the other thing was you
said it was a nothingburger, but I thought one of the problems with duplicate
transactions, it wasn't that you could just duplicate the coinbase, but by
duplicating the coinbase, you could also create additional transactions that
would duplicate, because you can also create duplicate txids for the spends from
the coinbase transactions, and they're going to have the same outpoint, they're
going to have the same identifier in the input.  So, you can create additional
transactions that have the same txid, and if you have multiple transactions with
the same txid, you can do weird things to the merkle tree, because Bitcoin's
merkle tree, it has a weird thing; when you use two txids, it assumes that's
just one txid at the upper level node.

So, I don't know if I would want to say it's a nothingburger.  Obviously, it's a
really expensive attack because you're going to be blowing, like you said, 170
bitcoin, but if you can start doing weird things to the merkle trees, maybe you
can break Bitcoin in various ways we wouldn't expect.

**Mark Erhardt**: Right, so when you create a coinbase transaction that matches
in the txid, since the inputs are uniquely identified by the outpoint of
whatever transaction created it and the index, the position and the output list
that created funds, you would be able to replay transactions that spent from the
coinbase back then too.  However, if any of the UTXOs still exist, BIP30
actually prevents you from accepting that into a block again; it's invalid to
overwrite an existing UTXO.  And so, since the coinbase transaction is the first
transaction in the block, there would be no way to spend the same UTXO twice in
a block, like you couldn't reorder it that you spend it in a block, create it
again, and then spend it again, because -- oh, you might actually.  Okay,
anyway, I don't think it's going to happen because of the 170 bitcoin giveaway,
but I'm going to have to think a little more about the descendant transactions,
because they're obviously not the first transaction in a block.

**Dave Harding**: Yeah, well I mean the thing is right now, we're not enforcing
on mainnet, we're not enforcing BIP30, we assume that BIP34 fixed the problem.
So, if it weren't for the fact that we have now set it up so that at block
1,983,702, we will begin enforcing BIP30 again, if we hadn't done that, then
there would be a risk of an attack vector to the merkle tree.  I think the
long-term question here is, what are we going to do in the future?  Do we want
to do BIP30, which is kind of a pain because it involves every time you receive
a transaction, you have to check the UTXO database for every output in the
transaction in addition to every input in the transaction, which was probably
worse back in the day before ultraprune, which is what we now call the LevelDB
UTXO set.  Anyway, I think we're going way too long on this, I'm sorry.  It's a
nice geek nerd snipe, but I think the developers have probably got this in hand.

**Mark Erhardt**: Well, interesting enough, we still have over 1 million blocks'
worth of time, so that's something like 17 years or so, maybe; no, actually
more.  So far, we've had 800,000 blocks, so longer than Bitcoin has existed, but
there might be potential for a simple solution, like someone asked recently on
Stack Exchange why BIP34 wasn't implemented by just requiring coinbase
transactions to set their LockTime to the current block height.  And so far, I
think coinbase transactions are not restricted in any way on the LockTime, So we
could actually just perhaps additionally require that coinbase transactions in
the future restrict their LockTime to the current block height.  And if all the
affected blocks where we have these prefix overlaps do not have the LockTime set
to that future block that matches their prefix, which I think would be highly
likely, then we could just completely prevent repetition of coinbase
transactions that way.  But that's just an ad hoc idea here from the top of my
head.

_What are hash functions used for in bitcoin?_

You said we are going too long on this already, so maybe we'll move on to the
fifth and last topic from Bitcoin Stack Exchange.  This one's going to be quick.
So, someone asked what hash functions are used for in Bitcoin, and Pieter really
got into that and lists over 30 different places and applications of hash
functions in consensus rules, P2P protocol, wallet implementations, and node
implementations, and tells us that there's more than ten different hash
functions that get used at different points in Bitcoin.  So, if you're
interested in that, check out this question.

**Dave Harding**: I don't have any comments on that, but I actually wanted to
ask if we could go back to the previous section where we covered the BBQr
encoding scheme.  I think Rodolfo might have some comments.  So, I was going to
see if he wanted to talk.

**Mark Erhardt**: Did you have a comment on BBQR?

**Rodolfo Novak**: More like I mentioned to David, if anybody has any questions,
I'm happy to go over.  That's something that we proposed, it's our spec.

**Dave Harding**: So I did have a quick question.  I think Blockchain Commons
had their own animated QR code, or they were advocating somebody else's
standard.  Are you aware of that and did you look at how that compared?

**Rodolfo Novak**: Yeah, absolutely.  So, we took a peek at that.  I think
there's a couple of wallets that use it with a smaller install base.  And
unfortunately, that spec requires too many dependencies for how we prefer to do
things and is not optimized enough.  So, essentially we wanted to make something
that works well embedded and was very simple and followed sort of principles of
how QRs are best optimized.  And because it's so early, I think it's nice to
have a few specs out there and see what best can we come up with, because right
now QRs suck!  And people are pretty unhappy with them.  So we figured, hey,
let's put the hat on the ring and see if we can come up with something.

It's about 30% more optimized for PSBTs.  That means you have a much higher
chance to fit that in a single QR, which is the best case scenario.  And then if
you do have animation, with this spec, you save about 30% as well, so you have
about 30% less frames.  That's very helpful.  And then you don't need a byte
word list in memory, so that's 256 times four bytes they require to have in
memory, and embedded that's quite a bit of memory that gets wasted.  They
require a different CBOR library that is not the original CBOR library.  We do
support CBOR, but it's not required.  What else?  And there is some very, at
least unknown to me, checksum algo called xoshiro256 that they're using.  They
also require a library, while we're just using the standard ZLIB that everybody
uses for this kind of stuff.  So that's sort of the initial review we had on it.
And, yeah, so we decided to go in at the more sort of simplistic kind of
approach for more embedded compatibility, let's put it this way.

**Dave Harding**: Okay, another question, and I'm sorry I've been going off the
rails, Murch, but a few months ago in the newsletter, we covered the transaction
compression scheme from Blockstream that they want to use, I think they're
actually currently using with Blockstream Satellite.  And it did things that
were unique to Bitcoin, like public key recovery.  So, instead of including a
public key in a transaction where it was otherwise committed by other data, like
in a P2PKH, it would recover that key, and that way it could save a bunch of
bytes.  It could save, you know, 33 bytes per public key per transaction.  And I
was wondering if you had thought about taking any of those techniques and
applying them.  I understand that this is planned to be run on embedded hardware
where computational expensive stuff like public-key recovery might not be a good
option, but I had wondered if you had thought about any of that stuff.

**Rodolfo Novak**: You know what, to be honest, I have not looked into that
standard yet!  There is so much happening in Bitcoin that I just I haven't had a
chance.  But I mean I think I echo what you said, it sounds very interesting,
from what you're saying.  But at the same time, I'm not quite sure if it fits
within the home of the hardware wallet needs.  Yeah, I'm not quite there.  If
you want to talk about yet another nerd snipe, I'm curious if anybody has worked
on a PSBT v2 standard for exfil anti-klepto stuff?  Because so far, I only see
sort of proprietary vendor-specific versions of that and I'd be very curious if
anybody's working on that.

**Dave Harding**: I'm not aware of anybody working on that, but you're right
that absolutely should be stuff that people are working on and getting that
standardized.  As we move to more and more multisig stuff and people are going
to be using more and more hardware-signed devices, that's really important.
Murch, that's it for my questions.

**Mark Erhardt**: Okay, thanks.  I do not have questions about BBQr at this
point, but if some of our audience have questions later, we'll ask towards the
end for people to join us as speakers and ask their questions.  So, if Rodolfo
is still there, he might be able to take it then.

_LND 0.17.3-beta_

So, we are moving on to the Releases and release candidates section.  This time
we only have one release.  That is LND 0.17.3, which appears to be a bug fix
release with just a small number of bug fixes.  But if you're using LND, you
might want to check that out.

_LDK #2685_

Then finally, we get to Notable code and documentation changes.  We have first
LDK #2685.  And, Dave, I might be leaning on you a bit here.  I know that you
wrote all of the summaries.  So, this looks like LDK added a way to get
blockchain data from Electrum.  Is there more to know about this one here?

**Dave Harding**: No, not really.  LDK previously had the capability to get from
other blockchain-style servers, like the Blockstream one, whatever it is,
Electrs or whatnot.

**Mark Erhardt**: Esplora.

**Dave Harding**: Esplora, yes, Esplora.  So now, they've just added support for
an Electrum-style server instead.

_Libsecp256k1 #1446_

**Mark Erhardt**: Yeah cool.  Next, libsecp256k1 #1446 removes some of the
hand-optimized assembly code for x86_64 because a bunch of the compilers have
gotten so much better.  That applies both to GCC and clang.  And now the
compilers themselves are just doing better for the project than what that
previously human-optimized code was doing.

_BTCPay Server #5389_

All right, moving on.  BTCPay Server #5389 adds the BIP129 secure multisig
wallet setup, or support for that rather.  This allows BTCPay Server to interact
with some other wallet software that implemented BIP129 already and to use
hardware signing devices in that context.  So, if you had been aching to use
multisig with your BTCPay server, it looks like this is getting on the road.

**Dave Harding**: Yeah, I guess, Rodolfo, if you're still here, I think, if I
recall correctly, Coldcard implements BIP129.  What has been your guys'
experience with that?

**Rodolfo Novak**: Sorry, Harding, I missed the beginning of the comment.

**Dave Harding**: So we're talking about BIP129, the secure multisig setup, and
I seem to recall Coldcard is one of the initial supporters of that; is that
correct?

**Rodolfo Novak**: Yeah, so we did support it.  It's more like a Nunchuk.  Hugo
sort of came up with most of the spec, we just added comments to it.  I don't
know, I have mixed feelings with it.  It is a good initial thought around how to
create coordination, like quorums, in a more secure manner, so especially when
we're talking about air-gapped coordination.  But I don't think it quite
achieves what it needs to achieve.  And we haven't seen enough adoption to get
more commentary or more suggestions on how to improve it and grow it.  So, we
support it.  Nunchuk uses, it does add some safeties, but I'm not sure it quite
does it.

**Dave Harding**: That makes sense.  I've been following the protocol
development, at least lately, and I really need to see it in action.  So, I've
probably got to just break out some stuff and give it a try one of these days.
Yeah, I mean the idea there is that it'll help the user interface while
retaining security, but it looks like an extra layer on top to me, from a
protocol level.

**Rodolfo Novak**: Yeah.  So, I think that the biggest challenge, if you just
think of this from very simple first principles, a few years ago what we tried
to do was, hey, I want to create a multisig script quorum just using the
hardware wallets, no computer involved, right?  So what we did is with the
Coldcard, you put in a micro SD card; let's say you have three Coldcards on the
desk, you put the micro SD card in one and you say, "Hey, create a quorum for
me, create a multisig".  And then it's going to ask you, what's the m of n you
want.  It's very simplistic in terms of options, but it does the basics.  And
then it asks you to rotate that SD card to the next Coldcard that gives one more
xpub, and that Coldcard registers that script and the previous xpub, and then
subsequently the third one, and then it goes back to the first one so that the
first one has all that.

So, the idea is we want the hardware wallet to know the other xpubs to reduce
the attack surface on change attacks, grifting attacks, or anything else that
could be maybe a PSBT being altered in transit, or for you to compare, say for
example, first address on a software wallet on the desktop versus what your
hardware wallet is showing, right?  Because the idea for us at least is, how can
I not depend on the computer, because the computer in our view is always
compromised.  So, that's great and all, but this is not an encrypted or
handshaked kind of interaction.  And what the Bitcoin Secure Multisig Setup
(BSMS) tries to do, like the next level of that, is try to standardize and
create a little bit of a check.

I think it's been a while, it's been I think probably like two, three years now
since we looked into that.  But if I remember right, the issue is we couldn't
come to a standard in which we would have a handshake based on maybe the seed or
something that everybody would agree and start using their hard wallets.  And
then I think that a lot of this died because there's us supporting, we have the
quorum, people use it, Nunchuk uses it, but in terms of multivendor, I can't
remember if anybody else ended up actually implementing this and trying to do
anything similar.  We don't know of many wallets out there registering the
multisig script and quorum in the actual signer.

**Dave Harding**: Yeah, I'm not aware of any other hard wallets doing it.  So
hopefully, if BTCPay server has implemented this and they'll put it out in the
next release, maybe people will get a little bit more experience with it and
we'll have a little bit more information by which to tweak the protocol or find
something better in the future.  Thank you, Rodolfo.

**Mark Erhardt**: All right.  Before we move on to the last item, I wanted to
call to the audience, if you have any questions and/or comments, please request
speaker access so we can add you up here and you can talk to us after we finish
the last newsletter item.

_BTCPay Server #5490_

Okay, finally, we have another BTCPay Server PR, that's #5490, and they switched
their source of fee estimates and now they're using mempool.space as their
default source for fee estimates.  The motivation was that prior, the fee
estimates came from the local Bitcoin Core node, but they observed that Bitcoin
Core doesn't quickly respond to changes in the local mempool, which of course is
a known issue given that Bitcoin Core only estimates fees based on the past
blocks.  So, it doesn't actually compare with what is in the current mempool.
So, yeah, you should hopefully see that transactions from BTCPay Server are more
reactive to the actual content of the mempool, because mempool.space bases their
fee estimates on the current queue.  So, do you have anything on that, Dave?

**Dave Harding**: Yeah, actually when I was writing up the summary for this PR,
I went and looked at their code and made a couple suggestions on their PR, which
they have, one of their developers has now opened a PR forum.  So, the two
things here, that if you're another developer who's thinking about doing
something like this, pulling fees from an API, the two things I suggest is, one,
you should definitely sanity check the results you receive, or you could end up
massively overpaying fees if there's a problem with the remote API.  For
example, if somebody hacked mempool.space, they could get everybody to overpay
fees.  And the other thing was, I suggested they introduce some jitter into
their fees that they use.

So, if you're a user of the BTCPay with this PR implemented, you want to send a
transaction, BTCPay Server calls out to mempool.space, gets a feerate, and then
you immediately use it and broadcast the transaction with that feerate.  Well,
mempool.space sees that transaction, they know what feerate they gave a certain
IP address within the last few seconds, and they see that, and they can probably
associate that transaction with your IP address.  So, I suggest that they insert
a little jitter.  Ideally, I think that would be great if they could just get
those feerate estimates over an ephemeral Tor connection.  But if they can't do
that, that was my suggestion, was put a little randomness in that feerate so
it's a little harder to associate with a particular IP address.

**Mark Erhardt**: Yeah, or also just maybe wait a little longer with the
broadcast.  Most of the time, it's fine if a transaction goes out 10, 15, 20
seconds later.  So, if there were more of a range there, that might also help.
Yeah, so this would be all from the newsletter today.  I don't see any questions
and comments so far.  This is our final newsletter for this year, a final
regular newsletter for this year.  There will be an annual review newsletter on
the 20th, and then we'll be done for this year again, the sixth year of Bitcoin
Optech.  Dave?

**Dave Harding**: It's my two weeks of vacation!

**Mark Erhardt**: Wow, yeah.  All right, cool, thanks everyone and we'll hear
you, well, I guess are we doing a Twitter Spaces for the annual?  What do you
think, Dave?

**Dave Harding**: I assumed we were.  We did last year, so I assume we were, but
you, Mike, and I can all talk about it and see what we decide.

**Mark Erhardt**: All right, then it sounds like you'll hear us next week again,
and other than that, happy holidays, bye bye.  Oh, and thanks to our guests,
Rodolfo and Bastien for joining us, and my co-host Dave.

{% include references.md %}
