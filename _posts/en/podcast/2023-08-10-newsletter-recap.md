---
title: 'Bitcoin Optech Newsletter #263 Recap Podcast'
permalink: /en/podcast/2023/08/10/
reference: /en/newsletters/2023/08/09/
name: 2023-08-10-recap
slug: 2023-08-10-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Dave Harding, Clara
Shikhelman, Peter Todd, Josie Baker, and Eduardo Quintana to discuss [Newsletter
#263]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-7-10/342610057-22050-1-d35d8a5e90ba5.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #263 Recap on
Twitter Spaces.  It's Thursday, August 10, and we'll be talking about a
vulnerability in Libbitcoin that has resulted in some loss of funds; a
discussion of DoS and Lightning; Clara is going to be speaking about Hash Time
Locked Contract (HTLC) endorsements and plans for implementations on Lightning
to collect that data; Peter Todd is going to talk about some of his proposed
changes to Bitcoin Core's default relay policy; Josie's going to join us to walk
through Bitcoin Core PR Review Club related to silent payments; and then we have
a Bitcoin Development Kit (BDK) release and some notable code changes, including
the renepay plugin for Core Lightning (CLN).

We'll go through some introductions.  Mike Schmidt, Contributor at Optech and
Executive Director at Brink, funding Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hey, I'm Murch, I work at Chaincode Labs.

**Mike Schmidt**: Dave?

**Dave Harding**: I'm Dave, I help with Optech and I'm also the co-author of a
third edition of Mastering Bitcoin.

**Mike Schmidt**: Peter?

**Peter Todd**: Hey, so I've been working on and off Bitcoin Core for quite a
few years, more recently off.  But even more recently, I did do two PRs as
people have noted, and I'm also involved with timestamping with OpenTimestamps
and a bunch of consulting stuff.

_Severe Libbitcoin Bitcoin Explorer vulnerability_

_Libbitcoin Bitcoin Explorer security disclosure_

**Mike Schmidt**: The first item of the newsletter, which this week happens to
be an action item, which we have not seen in a while, we have it as an action
item and we also cover it in the news section in more detail; I think we could
probably cover all of the discussion here initially and then skip it when we go
to the news.  So Severe Libbitcoin Bitcoin Explorer vulnerability involving the
bx seed command, which creates BIP32 seeds.  Well, apparently this seed command
only used 32 bit of system time to generate the seed, which is an incredibly
small space, and it seems that someone has discovered this and has potentially
or definitely stolen approximately 30 Bitcoin worth of funds from users using
this exploit.

Dave, I saw that you had posted on Twitter about raising awareness for this.  I
believe maybe some of the researchers who have discovered this reached out to
you since you were doing some work on Mastering Bitcoin.  Do you want to walk
through a bit of the detail there?

**Dave Harding**: Sure, actually I first heard about it from Murch, who
apparently heard about it from one of the researchers.  So, first of all, we saw
the action item which is if you used Libbitcoin's bx seed command, or you think
you may have used a process that involved it, you definitely want to go check
them on your wallet right now.  If you don't know what you're doing, if you
think you might have used software that used it and you're not aware of the
software, go talk to the people who made the software.  Just go out there,
investigate if you think this may have been involved in your process at all.

So, there were a number of popular instructions, including in the second edition
of the book Mastering Bitcoin and also on the Libbitcoin website, that suggested
that you use the bx seed command as the first step in a process to creating
either private keys directly or creating seeds for hierarchical derivation
wallets, or for creating mnemonics that will also be used to seed an HD wallet.
And like Mike said in the introduction, it's only using 32 bits of entry, that's
about 4 billion combinations; it's possible to check the generated addresses for
an HD seed for 4 billion of those in a day or so on a computer.  It could be a
bit slower, depending on what optimizations you used or not, but it's possible
to do using a single computer in a reasonable amount of time.  So it's very,
very insecure.

Most of the instructions, pretty much all the instructions, did not have any
disclaimer about the lack of security on this command.  There was one set of
instructions that did, and the author of the command has claimed that because
that one set of instructions had a disclaimer that was pretty hard to understand
unless you were already well-versed in cryptography and cryptographic security,
and even then, if you were well-versed, it was sort of ambiguous, but yeah, so
it was one set of instructions that had a disclaimer, the author has claimed
that this is intentional behavior that this is not secure.  However, none of the
sets of instructions that the authors of Libbitcoin wrote provided a safe way to
use the command.  So it's a little disingenuous, I think, to claim that this is
intentional behavior.  It may be intentioned, but it was not very helpful to the
users, and as I said in the introduction, about $1 million have been lost in
Bitcoin, quite likely possibly more, because of this attack.

I really don't know what to say besides, this is a really important thing to do
to have your process checked by an expert.  Even in this case, I don't know, I
suspect a lot of people would have missed this problem.  I certainly didn't
notice it was a problem.  Not great, definitely a security vulnerability.  Like
I said in the beginning, if you think Libbitcoin's bx seed command was used in
your process at all, you absolutely need to go out, check your wallet, and try
to see what you can do, if there's anything you can do.

**Mark Erhardt**: I think one thing that at least my cursory look at this
revealed was that it had an option where you could set the length of the key
material generated, and it was like 128, 192 or 256, however there was no way to
use it with more than 32-bit input material.  It would just, whatever you give
it, cut it down to 32 bit.  So, even if you gave it a different seed from some
other better entropy source, it would still curtail the entropy to 32 bits,
which as we said, is only 4 billion possible tries, regardless of where the
entropy originally came from.  And so, at least in the Mastering Bitcoin
example, it was presented in the context that the operating system provides the
entropy, but later when that was changed, that comment in the book was not
updated.  So, I don't know, I don't think that saying this was intentional is a
good way of wrapping it.

**Mike Schmidt**: A couple of notable things from the discovery of this.  This
class of error or bug is use of cryptographically weak, pseudo random, number
generating.  It's also similar to an issue that happened with another wallet,
called Trust Wallet, last year, where I believe there was a similar issue with a
similar type of attack, and I think maybe even using one of the same underlying
libraries which had the same issue.  There is a website with details on this
research that was done by some folks, called milksad.info.  And if you're
wondering why it's called Milk Sad, if you run this command on the versions that
are affected with a system time of 0.0, since the seeds were essentially derived
from the system time, you could just put in a fake system time of zero, and it
would always generate the same exact secret.  And it was a mnemonic with "milk
sad wage cup" as the first words.  So, they decided to name this website and
this uncovered research, Milk Sad.

The website also has a lookup service where you can look up a hashed version of
your seed to see if it's in the list of affected seeds.  Obviously, all sorts of
caveats if you're going to be doing that and handling key material as well.
Murch or Dave, anything else to add?

**Peter Todd**: I mean, I think this is one of those things where the problem
is, this kind of apparently bug is indistinguishable from an intentional
backdoor.  And my advice to anyone using Libbitcoin is just stop at this point.
The developers are trustworthy and that's that.

**Mike Schmidt**: Maybe a similar comment, it looks like also that there's been
a significant drop in the GitHub activity since around the time that this bug
was being exploited.  So, not sure what that has to do with any of this attack,
but maybe be cautious of using this tool at this point, or these tools.  Murch?

**Mark Erhardt**: No, I think that Libbitcoin has been less actively maintained
in the last four years already, so I think it was always a fairly small team and
I think that maybe featuring it this strongly in a book like Mastering Bitcoin
is a little much of an endorsement that misled some people into thinking this is
a widespread tool, but I don't think that Libbitcoin was ever that well
reviewed.  So, just seconding Peter's comment here, I don't think you should be
using this tool in your process.

**Dave Harding**: I can say that as of yesterday, all mentions of Libbitcoin
will not occur in the third edition of Mastering Bitcoin; they've all been
removed as of the commit yesterday.  So, that is definitely changed.  I had
already removed the appendix that was the problem in an earlier change, but like
Mark said Peter said, this is not a well-reviewed library.  It's got other
problems, and it's got this really big problem.  So, yeah.

**Peter Todd**: And I want to go say in support of Mastering Bitcoin here, I
mean this kind of mistake in a book, it happens.  I mean, books are an enormous
amount of effort to write.  Expecting book authors to in-depth review every
single thing that they go reference, well in theory, yes, they should do it.  If
they don't, consider yourself warned.  Writing a book is a lot of effort and
people don't always catch every single issue there.  The responsibility here is
on Libbitcoin and if you copy and paste something out of a book, you probably
should get it reviewed by someone else.

**Dave Harding**: I've been writing about Bitcoin for about ten years now.  I've
made lots of mistakes, including there's a CVE out on some documentation I wrote
about Pete's opt-in RBF implementation, and so there's a CVE out on that, so I'm
very well aware that making mistakes to documentation is absolutely something
that's going to happen. that.  So I'm very well aware that making mistakes in
documentation is absolutely something that's going to happen, it's just really
sad.  The whole thing I think is just very sad.  And I don't know, I just wish
it had broken differently.

_Denial-of-Service (DoS) protection design philosophy_

**Mike Schmidt**: Moving on to the News section of the newsletter, the first
item is DoS protection design philosophy.  We covered in the newsletter and in
our recap discussion a few weeks ago, in Newsletter #261, a series of talking
points that happened at the Lightning-Dev Summit in-person meeting.  And one of
those topics was heavily focused on channel jamming discussion.  AJ responded to
the email thread related to that discussion and he says, "The cost that will
deter an attacker is unreasonable for an honest user, and the cost that is
reasonable for an honest user is too low [to deter] an attacker", and that was
towards the beginning of his discussion about a potential alternate way to price
out attackers with regards to channel jamming.  Dave, did you want to say
something; did you want to walk through this?

**Dave Harding**: I'm sorry the newsletter was unclear on that, that was
actually in the notes.  So that was in Carla Kirk Cohen's notes about the --

**Mike Schmidt**: That's right.

**Dave Harding**: AJ didn't say that, sorry.

**Mike Schmidt**: AJ didn't say that, you're right.  But yes, okay, so the notes
did say that, and then AJ suggested an alternative to pricing out attackers.
And he sort of resurrects this idea from a few years ago about forward
commitment fees and reverse hold fees.  Dave, you may be better at speaking to
this than I would.  Maybe you want to talk about this old idea and the
revitalization of it?

**Dave Harding**: Sure.  I mean, the main point I think being made in that
thread by AJ, and I actually had a discussion with him about this on the
Bitcoin-dev IRC channel, is that it's just trying to set the costs in the
protocol as similar as possible to the cost being borne by the users, the people
running the nodes.  And that way, as long as they're earning a reasonable
profit, attacks just aren't economical.  If somebody comes in and they attack,
then nodes can increase their capacity and get paid for it.  It's a simple idea,
hard to implement, of course.  And AJ wanted to just kind of work through that
idea, see how it would apply in practice.

In doing so, he found an old email that he had written, but not sent, to a
thread from a couple of years ago about charging two sets of fees in the
network.  The first set of fees would be a forward commitment fee.  So, this
means that the sender of the payment pays the fee forward to the following hops,
through each hop on the route that he chooses.  That would be a very small fee
to cover the cost of just processing an HTLC.  So, there's a little bit of cost
that you bear.  AJ was suggesting one millisatoshi (msat), so a thousandth of a
sat.  It's just a very tiny value just to cover the small cost.  And then the
main cost in the channel jamming attack, and also in just holding invoices open,
which is something that people want to do sometimes, is the cost of capital.
It's having your funds locked up and not doing anything else productive for that
time.  So, AJ wanted to have reverse hold fees, because the person who receives
an HTLC has the ability to jam it.  So, they would pay backwards along the route
to the previous people.

The challenge with this is that that's got to be based on time, and there is no
way to have a completely universal clock.  The blockchain does provide a clock
that we all agree on, but it's just blocks don't propagate at the same speed to
the network.  There's a lot of challenges there.  But yeah, tiny forward
commitment fees, and then a backwards fee going from receiver towards spender
for the amount of time it took to settle a payment on Lightning.  That would
cover the cost of capital.  Those wouldn't be perfect, but they would recover
some of the fundamental costs that Lightning nodes are faced with, from routing
payments and having payments delayed.  So, that was his basic idea.

**Mike Schmidt**: I believe we have Clara now.  Clara, do you want to introduce
yourself, and then we can work you into this discussion since you had some
interaction on this particular mailing list post?

**Clara Shikhelman**: So hi, I'm Clara, I work at Chaincode.  Yes, so we talked
about this over the mailing list, and I think as with many ideas that have to do
with jamming, there's a lot of basic ideas floating around, but you really need
to put in the work and figure out all of the details.  And personally, I'm not
sure the details in the solution can be worked out.  Maybe they can.  You know,
it would be very, very relevant when we'll get to talking about upfront fees and
things like that, but that's mostly what the discussion was about, it was about
the details.  So, I don't know if anybody's planning to actually jump into this
and work them out, but it seems that currently that's not on the table.

**Mike Schmidt**: Murch or Dave, any other notables from this news item before
we move into other channel jamming discussion?

**Dave Harding**: I mean, I think Clara's absolutely right that this is a really
challenging thing to work out.  This is a thread that AJ kind of brought back
from two years ago.  So two years have gone by, nobody has worked them out in
that time.  I think the summary in this newsletter is AJ is just trying to say
he thinks this might be an interesting direction for research.  He's not saying
that anybody should be doing it right now, but it is an interesting direction
that people might want to look at in the future, even as we work right now to
deploy easier solutions.  It doesn't mean they're easy, they're just easier,
like reputation and stuff.

_HTLC endorsement testing and data collection_

**Mike Schmidt**: Well, speaking of reputation, the next item in the newsletter
for this week is HTLC endorsement testing and data collection.  And so, a
Lightning Node has channel liquidity, like we just spoke about, and also HTLC
slots, and both of these resources are potentially vulnerable to attack from
other members on the network.  And channel jamming is the name of the attack
that we're talking about in the previous item, and also this one, that can
target those resources.  We've gone into the attacks a bit in detail for Optech
previously, so look for old podcasts or newsletter entries on channel jamming.
We also have a topic on channel jamming for more details.

Luckily, we have researchers, like Clara, who have been working on mitigations
to these channel jamming attacks, and one potential mitigation involves
reputation systems.  And one such system is called HTLC endorsement, and that's
been set forth.  This week, we've actually added HTLC endorsement to Optech's
Topics wiki.  Clara, maybe to start, can you explain HTLC endorsement and its
relation to some of the previous local reputation discussions we've had
previously?

**Clara Shikhelman**: Sure.  Just to give a general overview, the complete
solution has two parts.  There's the part that has to do with reputation, which
is the thing we'll focus on in this discussion; and then to complete behaviors
that are not solved by reputation but can be still considered as jamming, we'll
probably also use some kind of a fee structure.  But when we're talking about
reputation, we want to focus on local reputation.  That is, if each node looks
at its neighbors and decides whether to allow them to use all of the HTLC slots
or all of the liquidity; or do they get just a part of the, say, half of the
HTLC slots and half of the liquidity?  And we do this because new neighbors, or
neighbors that didn't behave good before, and other reasons, I don't want to
allow them the full capacity of my channel, because if I will allow them, they
can easily jam me.

So, to build reputation, we expect the neighbors to send payments, to forward
payments, the payments should resolve quickly, the payments should pay fees.
There's a whole list of what we consider a good behavior and doing this, they
gain a high reputation and by gaining a high reputation, they unlock more
privileges to use more slots and more liquidity.  So, this is the first part and
this is the general behavior that we want.  What we want to avoid is, say,
somebody sends me an HTLC and I don't trust them.  I don't want to forward this
HTLC and put my reputation at risk with my neighbor.  That's why we have an
endorsement.  Endorsement is a way to tell my neighbor, "Here's an HTLC.
[Either] I think it's fantastic, it's going to go through, please let me use all
of the HTLCs that I'm allowed to use, [or] I cannot endorse it", and say,
"Listen, I don't know what it is.  Don't allow this HTLC to use the complete
slots and the complete liquidity".  So this is the main idea behind endorsement.

**Mike Schmidt**: So based on an individual node's interaction with a peer,
there's some sort of algorithm that then scores a particular peer, and HTLCs
that come from a peer can then be labeled by that node as endorsed or not.  It's
a binary thing, right?  And then when you forward that along, you forward that
binary flag along as an endorsement or not?

**Clara Shikhelman**: Yes, exactly.  And then when I receive something, I will
flag it as endorsed if, first of all, I received it as endorsed, and second of
all, if I trust the neighbor.

**Mike Schmidt**: And so this is all local.  So, if a peer or a neighbor is
behaving well to me, I may endorse HTLCs coming from them.  But if that same
neighbor is, according to the algorithm, abusing a different peer, then their
HTLCs may not be endorsed.  It's all local, as in the local reputation, and
dependent on how you've interacted with that particular node, not some shared
reputation?

**Clara Shikhelman**: Yes, so the reputation I give a node only depends on their
interaction with me.  I don't know what else they're doing on the network, I
don't know how they behave with their neighbors, and so on.  It's only based on
the specific interaction that the node can observe, that is interactions with
them.

**Mike Schmidt**: And so you have to collect this data in order to do analysis
on it to determine the endorsement or not, and is that what we're talking about
here with testing and data collection, is just beginning to collect those pieces
of information?

**Clara Shikhelman**: So the first thing we want to do is to have a general
sanity check of the algorithm, of the philosophy, of the sole solution, and this
is what we're aiming to do, so we would like nodes to collect data and to run
tests, just to make sure we are on the right track.  This is the first phase and
then we will see how the endorsements also propagate through the network.  But
the basic idea is to make sure that things work the way we think they work.  Our
first priority is, of course, in times of peace as it is right now, that nothing
gets harmed.  That's the last thing that we want to see happening.  Once we see
that no harm is done, we also want to see that, if indeed somebody decided to
attack, the results would be as we expect them to be.

**Mike Schmidt**: And so it looks like you have some buy-in from the different
Lightning node implementations, and so they are, I guess, pledging to put in
code that will start collecting this local reputation data?

**Clara Shikhelman**: Yes.  I think everybody agrees that we should do something
about it before things get messy.

**Mike Schmidt**: Okay, so assuming that these changes are put into the
different implementations, who would be the one collecting the data and
contributing to some larger body of data to do the analysis; is it just any node
operator that turns on a flag to log this data, or how would that work?

**Clara Shikhelman**: So each node operator can choose to collect the data.
Later on, they can also decide to use it, to share it, but this is really an
opt-in thing.  I really hope, and here's a call out to everybody, I do hope you
will opt in because the more data we have, the better results and better
algorithms we can come up with.

**Mike Schmidt**: And so, I'm collecting this as a node operator.  I've opted
in.

**Clara Shikhelman**: Thank you.

**Mike Schmidt**: Oh, no, in theory!  And I now have this pile of data.  Who do
I send it to, and is that data going to be shared, the aggregated data going to
be shared publicly for everybody to analyze, or just researchers, or how will
that work?

**Clara Shikhelman**: So we're working on the details right now to make sure
we're doing this as carefully as possible.  So, of course, we're involving
people whose job is to work with data and figure things out.  But the main idea
currently is that you will run some local analysis and share with us some
aggregated data.  And only with researchers, we're definitely not going to make
this data public at any point.  There's also, whichever data would be shared
with us, there's some randomization and fuzzing that will be added on top of it.
Yeah, but we're planning to do this very, very carefully for, I assume, obvious
reasons.

**Mike Schmidt**: Murch or Dave, do you have any comments or questions on the
effort here?

**Dave Harding**: I just think it's great.

**Mike Schmidt**: All right.  Murch gave the thumbs up.  So I guess we've
already gone through the call to action here, which is node operators, once
these flags or these opt-in data collection metrics are available, consider
collecting that data and providing it for research purposes.  Anything else,
Clara?

**Clara Shikhelman**: No, thank you.

**Mike Schmidt**: Thanks for taking the time to join us.  You're welcome to stay
on or you can drop if you have other things you're working on.

_Proposed changes to Bitcoin Core default relay policy_

All right, proposed changes to Bitcoin Core default relay policy is the next
item from the newsletter, and Peter Todd started two threads and has two PRs
related to these potential policy changes in default relay policy.  The first
one involves full RBF by default.  Peter, maybe you can talk a little bit about
how things are now and how you would like things to be with this default being
changed?

**Peter Todd**: Yeah, well, so full RBF, to recap, simply means that you apply
RBF rules to all transactions, rather than transactions that sets the BIP125
flags.  And the number one rationale for this, and really the reason why the
mempoolfullrbf flag even exists on Bitcoin Core, is that in multiparty
transactions, such as coinjoins, you can cause a lot of trouble if people in
your transaction double-spend inputs to it at low free rates.  And basically,
long story short, the issue that causes is that if that transaction cannot be
replaced by the intended transaction, and that low-fee transaction gets to a
large percentage of hash power, it can take a very long time to actually make
forward progress in your multiparty protocol.  Because there's no easy way for
you to determine whether or not a low-fee double-spend exists, particularly for
more decentralized coinjoin protocols, where you're not relying on, say, a
central coordinator.

The thing that full RBF does is it just means that in nearly all cases, either
the low-fee transaction gets replaced, in which case you make forward progress
in the expected amount of time, or the low-fee double-spend isn't so low fee,
it's actually the higher-fee one, and thus it gets mined in a reasonable amount
of time.  And while the coinjoin round or other multiparty rounds may fail, at
least you've made forward progress because you can determine that failure's
happened and you can move forward and use other inputs and so on.  So, that's
the clear rationale there.

There's a lot of other rationales, such as just having BIP125 in general makes
life difficult for wallet authors.  A lot of wallets lately have been removing
the ability to opt out of transaction replacement at all, because it just causes
issues.  If users send transactions with low fees, their transactions get stuck,
well, what do you do?  There's no easy solution to that other than double-spend
with a higher fee.  So, that's caused a lot of issues.  And of course there's
also privacy concern there, given that BIP125 does create one more way of
distinguishing one wallet from another.  But the multiparty one I think was the
main reason that full RBF got added.

Now, in terms of adoption, I haven't measured it recently but when I measured it
in December of last year, it looks like roughly 20% of newly upgraded nodes had
decided to turn on full RBF.  And I suspect the number currently is lower than
that, but it's a reasonable amount.  And more importantly, a lot of nodes, or at
least there's a core group of nodes that exist that use my full-RBF peering
patch, which ensures that full-RBF nodes are connected to each other.  And that
peering patch means that there is at least some group that propagates full-RBF
transactions.  And that means that the miners that have turned that on, which
appears to be somewhere between maybe 30% to 40% of hashing power, they do mine
full-RBF replacements fairly frequently.

This is relatively easy to see by the fact that my OpenTimestamps calendars make
full-RBF replacements.  And notably, I did change them recently to send the
initial transaction with feerates significantly above the minimum mempool limits
to ensure that this is an accurate statistic.  And Antpool in particular, as
well as Binance Pool, they're mining this stuff all the time.  So, I think we
have very good evidence that they have in fact turned this on.  And I suspect
the reason they've done this, of course, is because Binance has a habit of doing
consolidation transactions with RBF off.  And they've had issues there where
these consolidation transactions get stuck.  And people pointed out that it
looks like they've been double-spending their own consolidation transactions,
just to move them along faster.  So, there's an obvious use case for them.  And
when you have your own mining pool, you can do things like this.

So, I think that's kind of your background.  And as for, "Why would I want to
turn this on?" well, obviously you might as well go and get these benefits for
everyone, and I don't think there's a valid argument against it right now, so I
think that sums it up.

**Mike Schmidt**: In terms of arguments against it, maybe more generally, how
would you classify the reception from the community to the PR and the mailing
lists posts?

**Peter Todd**: Well, I think in general, I mean one way I could almost put it
is apathy towards this, which is what you'd expect because the reality is,
essentially everyone assumes that a transaction is unconfirmed until it
confirms.  There's been a small vocal minority of people making a big issue
about this, but when you actually ask them to provide examples of merchants that
actually depend on the so-called first-seen behavior that Bitcoin Core defaults
to, they can't come up with examples.

We have GAP600, which has made claims that they have a bunch of merchants, but
they refuse to provide actual examples of these merchants actually accepting
unconfirmed transactions as valid, and this has been going on for months.  I
keep on pressuring them to provide actual examples and they just refuse to do
so.  And frankly, my suspicion is that they don't actually have real examples of
this and are pulling some kind of shady business, where they make promises to
people that the service works, and then don't actually deliver.

**Mike Schmidt**: Murch or Dave, do you have any thoughts on enabling
mempoolfullrbf by default in Bitcoin Core?

**Mark Erhardt**: Yes, many.  So, I guess I first have to broadly agree that
unconfirmed transactions are unreliable.  They are more of a payment promise
than a reliable form of settled payment, or anything like that.  So, if I could
travel back in time, I think I would definitely allow replaceability from the
get-go and hopefully we would avoid this whole opt-in business.  Or perhaps if
we had a flag, at least the default would be replaceability and people could opt
out and signal finality.  That would have probably reduced a lot of the pinning
behavior and other research topics that we've been talking about quite a bunch.

But I think in the merging of mempoolfullrbf last year, we also saw and learned
that quite a few people regard the signaling of finality as a social signal, as
in ,"I don't intend to make a replacement for this transaction".  And that has
tempered my enthusiasm a little bit for pushing mempoolfullrbf very hard.  I
also don't really see that many issues in production right now.  I don't know, I
think I would probably give it a little more time and wait a little longer to
see perhaps some more measurements and if it's really been adopted sufficiently,
then we can still turn it on in a later release, not necessarily this one yet.

**Mike Schmidt**: Dave?

**Peter Todd**: Well, correct me if I'm wrong, but we basically are going to
have one more release in roughly a month, and then the next one after that
follows, you know, what, six, nine months or something like that afterwards?
So, I'd say a perfectly reasonable thing to do would be just merge this in like
a month and a week, so it would hit the release after the next one.

**Mark Erhardt**: Yeah, the feature release for the next release is in October.
The next release is probably expected in November or early December, and then
the one after that would be in May, June next year.

**Peter Todd**: Sounds good to me.

**Dave Harding**: I would echo Murch and then Peter, and pretty much anybody
reasonable on the idea, that unconfirmed transactions are not final, don't
accept them as final; that's the full stop there.  I'd also kind of like to
mention that my enthusiasm for this is tempered.  If you had asked me two years
ago, I would have been like, "Absolutely, let's do this, it's time.  Let's go
in".  I am not as convinced as Pete by the argument that this severely affects
coinjoin.  We've had a discussion on the mailing list about this.  I think
that's just a difference of opinion there.  I should clarify my remark.  It
absolutely does affect multiparty transactions, such as coinjoins, in a few
limited cases.  I don't think the damage is significant, and I think that's
where Peter and I disagree.

I was kind of surprised when we had a discussion last year about adding the flag
at all to Bitcoin Core by some of the -- there were some interesting remarks by
Suhas Daftuar, about if we designed relay policy from scratch right now, we
might have an interest in non-replaceability for the sake of keeping the
implementation simple.  Not that it should be the default policy, it would be an
opt-in policy for non-replaceability, just because you don't have to deal with a
lot of pinning vectors and stuff if you do that, because your only option then
is to CPFP if you want to fee bump.  I think it's a very interesting idea
intellectually.  In practice, my guess is that we're eventually going to enable
this flag by default, and so maybe we should just rip the Band-Aid off.  I don't
know.

**Peter Todd**: I mean, so for RBF versus CPFP, I take -- actually, so here,
I'll start by first of all saying I don't think we're actually in disagreement
about how bad this is for things like coinjoin.  I would rate this as sort of a
moderate issue for coinjoins.  I don't think this is something that ends them
because if it was something that completely made the idea non-viable, we
probably would have seen more attacks already, including deliberate ones, and we
just didn't.  This has happened quite a few times, probably by accident, and for
the individual coinjoin, it's a real nuisance, but it's not something that
people have spent a lot of effort attacking.  Although, a counterargument to
that might have been because we have had miners running full RBF for almost a
year now for sure, and probably even a bit longer than that.  So, maybe we just
didn't see those attacks because in fact, a small percentage of miners running
full RBF is enough to mitigate them.  I could be wrong on that too.

But I think in general, I just think we're closer in agreement on the severity
of it.  And my main argument is overall, this is beneficial, and I just think
the value of having non-replaceability is very low.  And where I think we do
disagree is RBF versus CPFP.  I think CPFP is definitely the inferior way of
doing things, and I think RBF is definitely underused in protocols like
Lightning, and other situations where it would have been very easy to pre-sign
multiple transactions at different feerates and just broadcast them as
necessary.  The fact is storage and bandwidth is reasonably cheap compared to
onchain space, and CPFP is just a more expensive way of doing things.  And
certainly going into the future, I think it's going to matter even more, and
we'll probably actually see protocols like Lightning getting redesigned and
tweaked in ways to use RBF more aggressively.

**Mike Schmidt**: I think in the interest of time, we'll move on to the second
of the two threads that you started on the mailing list and associated PRs,
which is removing specific limits around OP_RETURN outputs.  So right now,
Bitcoin Core will not, by default, relay or take into the mempool any
transaction that has more than one OP_RETURN output, or any OP_RETURN output
that has more than 80 bytes of data associated with it.  Peter, maybe you can
talk to a little bit about why it's a good idea to drop this standardness rule
or relax it?

**Peter Todd**: And I'll point out, there's also one other thing that you missed
there, which is the current rules do not distinguish between operator and
outputs that actually carry data and ones that don't.  And even though this
standardness rule is about preventing data from being included in transactions,
bare OP_RETURN outputs that don't carry any data at all are also affected.  For
instance, you can't have more than one of them in a transaction.  And also, if
you seemingly turn off OP_RETURN data to zero, it actually prevents
non-data-carrying OP_RETURNs as well, which I don't think really is intended
behavior.  But anyway, that's just sort of a quibble.

But yeah, more generally, I mean, so where this came from is Chris Rowland for
various identity-related things and so on, he identified a need for expanding,
for making use of OP_RETURN in certain scenarios with more than 80 bytes.  The
80 bytes is a limit that was set up when the whole OP_RETURN mechanism was
adopted to begin with.  And, this point of fact, I'm the guy who is responsible
for OP_RETURN existing at all.  I mean, I identified a need for this many, many
years ago and suggested that we add this as a consensus rule, that scriptPubKeys
starting with OP_RETURN, which are provably unspendable, because the first thing
that happens in the script execution is the OP_RETURN is seen, and then that
immediately fails the script.  So, we know that they cannot be spent.  And
unlike other unspendable outputs, OP_RETURN outputs are never even added to the
UTXO set to begin with, which certainly has advantages if you do not intend to
spend an output.

But then the standardness rule of only allowing 80 bytes' worth of data, or to
be exact, 83 bytes' worth of script data, including the push opcodes and so on,
that's something that was added by others when this was actually merged to
Bitcoin Core.  And like I said, Chris Rowland identified a need for more than
that for certain types of transactions.  He was willing to put up a $1,000 to
put in a few hours of work and get the PR done.  And I agree that this is sort
of a paternalistic limit.  I don't think it really makes sense to have, when
there's so many other ways of publishing data.  In certain cases, doing an
OP_RETURN makes sense, in other cases it may make sense in other ways, but it
just seems silly to have this one remaining paternalistic limit in standardness
rules.

Now, I don't know if you're aware, but the PR has been closed due to a flood of
I think very poorly technically formed commenting about it, so I kind of agree
with that, I don't think it's going to get merged.  But if you have a reason to
need this, the thing I would tell people designing applications is you should
have fallback mechanisms that don't use OP_RETURN.  And the more these kinds of
applications get used, maybe this issue will get revisited in the future.  And
if not, well, make sure you have fallback mechanisms.

**Mike Schmidt**: One comment from a developer was saying something along the
lines of removing these restrictions that you're talking about removing could
potentially open up additional transaction pinning vectors.  Do you have any
more details on what was meant there?

**Peter Todd**: Yeah, well, for the audience, transaction pinning just refers to
mechanisms that make it difficult to replace transactions.  And where this
hypothetically could come from is maybe if your node doesn't see the OP_RETURN
transaction that is pinning the transaction it's trying to replace, yeah, that
can kind of be a concern, but the space of things that allow that is quite
broad.  So, I don't think that's a concern that's really specific to OP_RETURN,
I think that's just a concern in general.  I think you're better off designing
protocols where this really isn't an issue.

An example where that might be true is, Lightning channel things are an example
where you might want to use RBF to replace transactions to get it to make
progress faster, right?  Suppose you have multiparty channel opening as an
example, and your counterparty is trying to lock up your funds by preventing
that transaction from confirming, and maybe they accomplish this with an
OP_RETURN, or some other mechanism that you just can't see, to make it hard for
your fee bumps to increase.  Well, like I say, any difference in relay policy
potentially exposes you to this and you probably just want to, in general,
design the protocol to be robust to not seeing why transaction isn't getting
replaced.  I kind of rate this is relatively low.

For things where it really matters, like a good example would be the Lightning
commitment transactions, where you're trying to get a state in an adversarial
situation, I kind of got asked, "Well, surely we should be using things like
OP_CHECKSEQUENCEVERIFY (CSV), etc, to make pinning not an issue to begin with".
I think that's a much better approach and using that in conjunction with, say,
RBF where you've pre-signed a bunch of transactions at different feerates to
cover all eventualities, I'd say that's a better approach than hoping that
pinning is not an issue and trying to design mechanisms more related to that.
So, that's kind of my view on it, but I know other people disagree.  Also, my
part, I mean I've got to go write up more about my viewpoint on RBF versus CPFP
there, so that's on me too.

**Mike Schmidt**: Dave, Murch, aren't we just putting data in the witness these
days?  What do you think about relaxing the OP_RETURN limits?

**Mark Erhardt**: Yeah, I've been thinking about this a bit this week.  So, I
oppose this change actually, and my opposition comes from two observations, or
maybe three.  One is, I don't think that we should encourage further use of the
Bitcoin blockchain as a data publication mechanism.  We do have enough room for
a hash.  If people want to publish something and timestamp it into the
blockchain, they can hash it, publish it elsewhere, and per the hash in the
blockchain, prove that it existed.  I mean, that's basically what Peter does
with OpenTimestamps, right?

**Peter Todd**: No, it's not.  I mean, you're talking about different
applications there, though.  Timestamping and data publishing are very different
things.  And one does not replace the other.

**Mark Erhardt**: You've talked a lot already.  I can talk now, yeah?  So, I
don't think that the blockchain is good for publishing data, I don't think that
we need to encourage that further.  It makes it cheaper to publish data up to
135 bytes; it makes it widely more accessible to publish data; I think that the
arguments that I have seen what it should be used for don't really seem that
huge of a benefit to me personally.  You can disagree with that.  And therefore,
just because other mechanisms have been discovered by which you can publish
data, doesn't mean that we should open up more avenues to do so, (a); and (b)
for example, we can skip witness data during the Initial Block Download (IBD) if
we're running a pruned node anyway already, which we can never do for OP_RETURN
data.

So, there are ways that witness data does not affect us that OP_RETURN data
does.  And so, I just don't really see huge benefits.  I do see some small
downsides and we've had this rule forever, it doesn't seem to bother a lot of
people, so I think it's fine to keep it.  Now you can respond if you want.

**Peter Todd**: Well, I mean so I just want to make clear with this.  It really
bothers me how people present timestamping as a solution to these kind of
problems.  Because, I mean you're welcome to go say that Bitcoin should not be
used for publication, but it really annoys me to see people mislead people by
saying, "No, timestamping is good enough".  Now, the answer could very well be
that, "Well, we just don't want your use case to work and ideally we would make
your use case not work.  Let's go tell people that something else provides the
same benefits", is I think just wrong and we shouldn't mislead people that way.
We should be honest to them about what Bitcoin is or isn't capable of doing.

Now, it is also I think interesting how I think you're the only person, well, I
mean maybe not in general, but in the GitHub discussion around that PR, no one
actually brought up what you just mentioned about IBD with witness data versus
non-witness data.  So, I think it kind of says something about the low quality
of discussion we had, that that obvious point never actually got mentioned.  And
I personally don't agree with that, but you certainly are being smart to go
bring that up, and it's just something that never happened in that PR.

But when you look at it from the point of view of the people using this, I mean
like I said before, I think it just makes more sense for them to design things
that have alternate mechanisms of publishing.  And you can reap most of the
benefits of OP_RETURN, which tends to come down to Simplified Payment
Verification (SPV) proofs, because going through witness data involves going
through coinbase transactions, which have unboundedly large size, which is quite
a problem for certain types of publication mechanisms.  This is actually why
OpenTimestamps does not timestamp data via witnesses, because pre-taproot, there
wasn't a good way to go do that that didn't involve going through the coinbase
transaction, which can be arbitrarily big.  Post-taproot, there is one method
that can do this, although it's a bit risky, but pre-taproot that wasn't really
possible.

But anyway, I mean I think the bigger picture is, this PR was closed because
it's not likely to get merged.  And I don't think it's good for people designing
these types of things to assume standardness rules will be set in any way
beneficial to them.

**Mike Schmidt**: Dave, any commentary on this?  Okay.  Well, if any of the
listeners are interested in this type of discussion around policy, like these
two points that Peter has brought up today, there's some philosophical and other
discussion about relay policy and mempool in our Waiting for confirmation
series, which is aggregated as a blog post on the bitcoinops.org website, so dig
into that if some of this discussion is perking your interest.  Peter, thanks
for joining us.  You're welcome to get back to your beautiful scenery.  I'm glad
your connection held up and you sounded pretty good.  Thanks for joining us.

**Peter Todd**: Thank you, and credit goes to silent.link for the digital
whatever SIM card, or whatever that actually made all this work.  So thanks to
them and thank you for having me on.

_Silent Payments: Implement BIP352_

**Mike Schmidt**: Absolutely.  Next section from the newsletter involves a
select Bitcoin Core PR Review Club PR.  And this month we've selected Silent
Payments: Implement BIP 352, which is a PR by Josie, who has joined us.  Josie,
you missed the introduction, so maybe you can do a quick introduction for folks,
and then we can jump into some of the details here.

**Josie Baker**: Yeah, sure.  Thanks for having me too.  So for introductions,
I'm Josie.  I work on Bitcoin Core pretty much full-time as a contributor.  I've
done stuff around the wallet and some other things, and for the past eight
months or so, I've been working on silent payments with Ruben Somsen.  Silent
payments was a proposal he came up with, I think around March 2022.  And then I
heard him give a presentation on it, got really excited about it, and decided to
help write the BIP.  So, we worked on that for several months.  And then I
started working on an implementation for Core, which was based off a PR that a
pseudonymous developer, w0xlt had opened.  And so I'd been working on that for a
while to kind of keep it up to date with the BIP.

So, the PR Review Club we just did is kind of the ready-for-primetime version of
that PR.  So, we've broken it up into the first part, which is what we reviewed
on the PR Review Club, which just implements the protocol from the BIP; and then
I've also opened a sending and a receiving PR that are both based on that PR.
Sorry, that was longer than just an introduction.

**Mike Schmidt**: No, that's good, we're jumping into it.  Okay, so there's sort
of this parent or tracking PR for silent payments progress.  And I guess I
should note that that is specific to Bitcoin Core.  And I guess there would
ideally also be work for other wallets who wanted to implement silent payments
as well.  It looks like you're focusing first right now on the Bitcoin Core
implementation and then potentially in the future, other wallets?

**Josie Baker**: Yeah, maybe it's worth saying a few things about that.  So
we've been working on two things concurrently, which is, one, the BIP.  And
maybe for those that are less familiar, this is an application layer BIP,
meaning it doesn't have anything to do with consensus, it's just a technical
spec for how wallets could implement this protocol, which is silent payments.  I
think we spoke about the BIP itself several months back when we first opened
that PR to the BIPs repo, here on the Optech Recap.  And since then, the BIP has
gone through several rounds of very thorough review.  And just, I'll take a
second here to give a huge shoutout to all the people who have contributed to
that review, it's been super-helpful.

There's not been really many changes on the protocol itself.  We've made a few
refinements since then, like changing the format of the address and a few other
tweaks.  But I would say I'm feeling pretty confident that the BIP is settled.
So, if you wanted to go out and start implementing silent payments today in your
wallet, you could do that reasonably safe.  And we've split it up so that
sending is much easier to implement than receiving.  So, my hope is that as the
BIP settles and we refine the wording and add more test vectors, people can
start implementing sending and receiving support in their wallets.  And then,
because I'm more familiar with Core, that's where I'm going to focus, getting it
into the Bitcoin Core wallet.

What that'll look like is, if and when those PRs get merged, you'll be able to
get a silent payment address for your Bitcoin Core wallet, which means that
you'll be able to send to other silent payment addresses and you'll also be able
to receive silent payments to the Bitcoin Core wallet.  But yeah, very much this
is a wallet protocol, so it becomes more useful the more wallets that implement
it.  And we tried to learn from what happened with taproot, where it's really
important for adoption that people can send to and parse silent payment
addresses.  You might not care about receiving silent payments, but if I want to
receive them and I post my silent payment address but nobody's wallet can send
to it, it's not going to be that useful.  So, we put a lot of time into making
sure that sending is really, really simple.  And so my hope is that even while
we're still working on this PR for Core, which implements the full thing, that
other wallets can pick up and start implementing sending support.

**Mike Schmidt**: You mentioned our discussion previously.  In the Recap #255
Newsletter, we had Ruben Somsen and Josie on discussing the draft BIP for silent
payments.  So, if you're curious about a higher-level discussion, maybe jump
back and listen to that segment.  I know we're a little bit off of this Core PR
that we've selected for the newsletter, but I do have a quick question since
we're on the topic of other wallets and libraries.  Your focus on Bitcoin Core,
getting some Bitcoin Core functionality and also in the wallet, is there a plan
in the future to have something like we covered recently, a payjoin development
kit that is separate from the BDK for folks to integrate payjoin into their
wallet; is that something that would be planned in the future, or would that be
a different team taking initiative there?

**Josie Baker**: Yeah, I mean, absolutely.  I think the right way to encourage
wallet adoption is make it as easy as possible for people.  I mean, we're all
busy, some of us are just doing this for the love of the ecosystem, so it's very
difficult to -- I would never want to be in the position where I'm going to some
open-source project and being like, "Hey, we came up this new thing.  Can you
take time off from what you're busy with to implement my thing?"  And so, after
the Bitcoin Core PR, I'd really like to focus on what are the popular wallets,
Software Development Kits (SDKs), that people are using, and how can we make it
easy to integrate silent payments there?

The really cool thing is, and this is just, I mean, it's been very humbling and
kind of blown me away, people have approached us and been like, "Hey, this seems
cool, how can we help out?"  So there's been a group of developers that were
working on a stealth address development kit.  And so they were like, "Hey, we'd
like to include silent payments in that", so we've been working with them.
There's another developer who approached me and said, "This seems really cool,
I'd like to do an implementation in Rust, with the view that this Rust crate
could then just be imported to Rust projects and use silent payments".  And so,
the goal there would be we have this Rust crate that implements the protocol,
not like a full wallet, but just the silent payments protocol, and then that
could be included into something like BDK.  So then, any wallet that uses BDK as
their SDK would get silent payments there.  I'm working on JavaScript
implementation.

So I think, yeah, just focusing on getting libraries out there that people can
use makes it much easier to approach wallets and be like, "Is this something
you're interested in?  Here's the tooling.  We've got test vectors, etc".  For
me, I know Bitcoin Core wallet, I can maybe hack my way around Rust, but you
don't want me running around and implementing stuff in JavaScript.  So, my
approach on that is going to be, how can I document, how can I make as many test
vectors as I can so that it's as easy as possible for you, the wallet developer,
to come pick this up and implement it in your language of choice?  I mean, I
guess we'll see how things develop.

Once we have it in Bitcoin core, I think that's the right time to start
marketing and advocating for it and talking to wallet developers.  And like I
said earlier, so far I've been just really humbled and blown away by how people
have approached us and shown interest in this, because of course I think silent
payments are cool, and Ruben thinks it's cool, and you spend a lot of time
working on something and then you put it out there and you're like, "I hope
other people think this is cool".  And so far, it seems like there's been some
enthusiasm about it.  So I'm pretty hopeful about wallet uptake and adoption.

**Mike Schmidt**: Back to the PR in question for the PR Review Club, which is
#28122, that implements the logic for BIP352, which is the silent payments BIP,
without any wallet code.  So Josie, what is the non-wallet logic code that needs
to be in Core before you can put in the other two PRs that involve actual
sending and receiving?

**Josie Baker**: Yeah, before I jump into that question, maybe it's worth
mentioning, this PR Review Club was the first in our new monthly format.  So PR
Review Club used to be once a week, now it's going to be once a month, where
instead of one meeting, we do two meetings.  And the cool thing about that is it
gives us more time to prepare the notes, it gives the people who want to attend
the club more time to read and prepare.  And then doing two days instead of just
one, so two hours in total, it really allowed us to dig into the PR.  So that's
kind of a shameless plug for PR Review Club.

To the specific question, what parts of silent payments don't involve wallet
code?  So, I'd say that really, silent payments is, at the base of it, a
protocol for how a sender and receiver can deterministically create a shared
secret.  And so, the sender creates a shared secret and then the receiver uses
information already in the blockchain, which is the pubkeys present in the
inputs to a transaction, to arrive at the same shared secret, and that's how
they can find this address that is unique to them.

So, that first PR for Core isn't really talking about how we do it in the
wallet, how we parse the address, and it's more just, how do we make sure the
right primitives are in Core so that we can implement this protocol?  So, for
example, with silent payments, we use the private keys of the UTXOs that you
want to spend to do the Diffie-Hellman step.  So, we needed to add some
functions in Bitcoin Core so that we could add private keys together.  For the
receiver, they look at a transaction and they look at the public keys and then
they want to add those public keys together to do the Diffie-Hellman step.  So,
we needed to add some functions to Bitcoin Core for adding public keys.

Then, we added some functions that do the silent payments protocol.  And then,
those functions will then be used in later PRs in the actual wallet code.  And
my reasoning for wanting to do it this way is, to do it all at once is going to
be a massive and complex PR, so we want to break it up into small chunks that
people can reason about.  And doing it this way also made it easier to test the
Bitcoin Core implementation against the test vectors on the BIP.  Because now, I
don't really need to worry about modeling things as UTXOs or transaction inputs
and outputs, I just have this interface that accepts public and private keys and
then spits out public and private keys.  And then we can very easily test that
Core logic and then have more confidence in the later PRs, when we build the
wallet logic on top of it, that we're implementing the protocol correctly.

**Mike Schmidt**: Okay, so this PR is for the non-wallet logic code, and this is
referencing one of the Review Club questions.  So, why is this PR adding a bunch
of code to the wallet directory then?

**Josie Baker**: Yeah, great question.  I think at the end of the day, like I
mentioned earlier, this is an application layer BIP, and it's a protocol for
wallets to communicate with each other.  So, when we're talking about code
separation and organization of Bitcoin Core, we like to keep these things as
modular as possible, so it's easy to reason about what's going on in the code
base, the safety, etc.  And so, since silent payments is just going to be
strictly used for wallets, like you generate an address, you want to send to
that address, it's all happening in wallet software, we wanted to organize that
code under the wallet directory.  We had some good discussion about that too, of
like, "Well, is that really the best scenario, or is that really the best place
for the code?  And can you think of an example where we might want to use silent
payments logic outside of the wallet context?"

One example that was brought up in the PR Review Club is, "Well, yeah, I could
have a Bitcoin Core node that is scanning for silent payments, but not actually
using them in the wallet.  And they're scanning for silent payments in order to
hand them off to a light client.  So, the light client doesn't have access to
the blockchain, but the light client wants to receive silent payments.  They can
have a Bitcoin Core node doing the scanning for them, collecting that tweak data
that they need, and then parsing it off to the client to do the actual protocol
and drive the outputs".  And so in that case, yeah, maybe you do want some
silent payments code to live outside the wallet so that I could compile Bitcoin
Core, don't compile it with the wallet, but just have it running and scanning
for silent payments.

**Mike Schmidt**: There were some questions in the PR review club about
versioning and compatibility.  I invite everybody to look at all the questions,
including the ones we highlighted in the newsletter, and not just the ones that
I'm choosing to ask here.  But maybe for folks to wrap their head around
versioning, maybe you could give an example of what would a potential example
improvement, version improvement to silent payments be, so we can wrap our minds
around what versioning of silent payments even means?

**Josie Baker**: Yeah, I think versioning is just this really interesting
question of, like, versioning is a beast, right?  And I don't know if you caught
this part, but it basically boils down to how can we futureproof and predict the
future?  So, one example that comes up, in silent payments, we pick a subset of
scriptPubKey types that will be used for this shared secret derivation step.
But let's imagine in the future we soft fork in some new output type, entroot.
Now there's taproot and bech32, now there's this new output type, entroot, and
we want to also include that in this shared secret derivation step.

What we would do is we would release a silent payment v1, because we're on v0
now, so we have a silent payments versions v1.  And v1 would say, "If you're
sending to a v1 address and you want to spend these entroot outputs, it's fine
to include them".  And the receiver will recognize that this is a V1 transaction
and they'll include those entroot outputs in the shared secret derivation.  So,
that's one example that we thought of that I think helps us be pretty resilient
to soft forks in the future, without really needing to change stuff.

Another example would be, maybe we want to add more data to the silent payment
address, some metadata.  Kind of a contrived example I thought of was with
silent payments on the BIP, when we're talking about like clients.  In theory,
if we assumed this perfect, private P2P messaging protocol, you can imagine that
the receiver, instead of scanning for silent payments, could just get a
notification from you, the sender.  You, the sender, crack the silent payment,
and then you encrypt it, a message with the txid, or something, and you encrypt
it to their silent payment address using the pubkeys, and then you send them
this notification, they decrypt it, and they're like, "Oh, yeah, someone sent me
a silent payment", and then they get that without having to scan the chain.  And
this is okay because they can always fall back to scanning the chain if the
notifications are missed or censored or unreliable.

So, one idea I had was, okay, well yeah, this perfect P2P messaging protocol
doesn't exist today, but if it does, then maybe the receiver wants to put a hint
in their silent payment address that says, "By the way, I accept notifications,
and I want them over this protocol", like let's say Simplex or something, and so
they put some little byte or two in the address.  And so that would be an
example of a future version, where if I'm a v0 silent payment sender, I'd read
their address, and I don't understand anything about notifications because I'm
still using the v0 portion of the protocol, so I just ignore those extra bytes,
send them a silent payment, and they would find it by scanning the chain.  But
if I'm a v1 and I do support it, notifications, I read that address, I'm like,
"Oh, this receiver accepts notifications", so I'm going to go ahead and send
them a notification as well.

So, that gives an example of one where the shared secret derivation part might
change, and then there's an example where just the protocol might change.

**Mike Schmidt**: Thanks for walking through that, Josie.  I think I heard one
potential call to action for the audience here, which is folks who are
technically capable and potentially working on wallet or library software and
are interested in pursuing silent payments in their wallet or service, they can
reach out to you and coordinate on any questions that they may have in their
implementation.  Is there anything else that you'd call for the audience to do,
other than review these PRs that are currently open?

**Josie Baker**: Yeah, I would say if you're someone who works on and reviews
Bitcoin Core, we'd love to have your review on the PRs that are open.  So, that
PR that we went over in the Review Club, I think that's the one that I would
love to have the most attention on right now, because I think it's the most
ready.  And the other two that I've written for sending and receiving will also
depend on it.  And then like you said, if you're in the broader ecosystem and
you work with wallets or you're contributing to and involved with wallet
projects, and this is a protocol that you're interested and want to implement,
please reach out.  I'd love to help in any way I can.  And also, having these
people, like these bleeding-edge first movers, who come and want to start
implementing this, has really helped us a lot because they've had great
commentary.

If you go to the BIP, you can see a ton of comments from a few people who've
started to implement it.  And they're like, "Hey, by the way, think about this
test; and I found this edge case and maybe you want to think about that".  And I
mean, code is what matters.  So, people implementing this is really what gives
us confidence that we have a good, solid and robust protocol.  So yeah, feel
free to reach out.  I'd love to see people just tackling sending, you know, like
pretty much every mobile wallet today could implement sending fairly trivially,
and that would do a lot to make the case for adoption.  So, if that's something
that you're interested in, I'd love to chat.

**Mike Schmidt**: Thanks for joining us, Josie.  You're welcome to drop if you
have other things you do, and you can hang out with us.

**Josie Baker**: Yeah, thanks for having me.  Always fun to join these and have
a chat.

_BDK 0.28.1_

**Mike Schmidt**: Next segment from the newsletter is Releases and release
candidates, of which we have one, BDK 0.28.1.  It includes a bug fix and also
adds a taproot descriptor template, BIP86.  And so with that feature change,
users can now, if you're a BDK user and you upgrade to 0.28.1, you can now
create taproot descriptors with templates.

_Bitcoin Core #27746_

Bitcoin Core #27746, simplifying the relationship between block storage and the
chainstate objects.  Murch, I think you're better equipped for explaining this
one than I am.  Do you want to take a crack at it?

**Mark Erhardt**: I'll take a crack at it.  So, assumeUTXO of course is a
project where we try to be able to serve a snapshot of the UTXO set, and then in
the background have a full node, on the one hand start synchronizing the rest of
the chain tip from the UTXO snapshot, and in the background also to verify that
the UTXO snapshot was accurate by syncing the whole blockchain in the
background.  And from my understanding, this PR lays the groundwork for being
able to have two UTXO states in the Bitcoin Core, where one of course would be
the one starting from the snapshot and heading towards the chain tip, and the
other one is starting from the Genesis block and heading to the UTXO snapshot.
And yeah, that's pretty much what I know about it.

**Mike Schmidt**: So, some foundational assumeUTXO work.  Dave?

**Dave Harding**: Actually, I just want to add some clarification here.  I think
we actually have, for about a year-and-a-half now, actually had the ability to
have two separate chainstates in Bitcoin Core for the assumeUTXO project.  What
this PR does, as I understand it, is it changes the logic related to how we
store blocks.  So currently, the decision made to store blocks by Bitcoin Core
on disk, which is a DoS factor, like if somebody can just send you random junk
data that looks like blocks and you store it to your disk, you can eventually
run out of space; so, what this PR does is removes some of the chainstate logic
that was in that decision loop to store blocks.

So previously, the decision made to store blocks, you had to check the
chainstate to see, for example, if that block connected to a previous block.
And now a lot of that logic has been removed, so you don't actually need as much
chainstate in order to decide whether to store a block.  And that's just really
good for separation of concerns in the code, so that you're not pulling that in.
It's really good if you have these two separate chainstates, that you can do
this logic separately.  That's all it does.

_Core Lightning #6376 and #6475_

**Mike Schmidt**: Thanks for clarifying, Dave.  Next two PRs are to the Core
Lightning repository, #6376 and #6475, which implement a plugin called renepay.
And luckily, we have an author that contributed to these PRs here, Eduardo.
Eduardo, do you want to introduce yourself and then you can explain renepay?

**Eduardo Quintana**: Okay.  Hello everyone, can you hear me?

**Mike Schmidt**: Yeah.

**Eduardo Quintana**: All right.  So, I started working on renepay from a
theoretical point of view in 2022.  It was an idea from a paper by René
Pickhardt of 2021.  The idea is to, let's say, propose a new payment algorithm
for the LN.  Just to give you an idea of what's the current state, right now,
when you want to try a payment on the network, you will search for a path with a
minimum cost or fees in the network in order to forward the payment from the
source to the destination.  But usually, these kind of payments will fail
because of this lack of liquidity in the channels along this path.

So, with renepay we have a model of the network in which we define the state as
some kind of a Bayesian model.  So, the state of the network is not a certain
value of the liquidity in each channel but a probability solution on the
liquidity.  And as a first approximation, we use the probability distribution
which is uniform.  So for example, if there is a channel which does not belong
to us, it will belong to some other nodes, we don't know where the liquidity is
but it has a capacity of 3 million sats, then we say that initially, this
probability distribution would be a uniform distribution from zero to 3 million
sats.  And once we send the payment that includes that channel, the payment goes
through, then we know that the channel has had, when we send it, at least the
capacity, the liquidity, for us to forward the payment on.  We update the
knowledge of the state of that channel.  So, that's why it's called Bayesian
because we update this knowledge every time we interact with the network.

So at the end, we make use of these multipart payments.  And if you think of it,
if you make many, you divide your payments into many parts, you are decreasing
the probability of your payment going because you are exposing yourself to more
risk of finding no channels with less liquidity than the other.  But at the same
time, you are diminishing the amount of liquidity that you are asking for each
of these paths.  So, the algorithm tries to find a sweet spot between making
many, many paths and with a low liquidity, so in order to increase the
reliability of each payment trial.  But as a matter of fact, this was just a
simplistic way of putting it.  At the end, there is a more robust way to solve
this problem, which is the use of minimum cost flows algorithms, in which we
consider a cost function that is related to the probability of a forwarded
payment, given the amount that we want to forward, and the cost in fees that
this payment is going to cost for the person who's sending the payment.

So right now, this plugin is already merged into CLN.  It surely has a lot of
bugs because it's just in its infancy.  This was the result of three months of
work, my first contribution to CLN as a matter of fact, and there are many
things to try.  There is the possibility that this plugin is very inefficient
because we haven't highlighted many different min cost flow solver, but at least
this is the first trial and it's a candidate for the future payment algorithm
for the LN.  Something more to add, I guess, what promises is that with the
usual payment algorithm, you have sometimes many, many failures to try to
deliver the payment and after a certain time you will just stop trying.  But
with this renepay, you can put a limit on how many trials you want to have or
how much time you want to wait for it, but theoretically you can deliver because
this algorithm, once you start running it, it by itself starts discovering more
where the liquidity is allocated along the network and from the source to the
destination.  So, here you can forward as much amount of sats as the actual max
flow you can actually deliver.  And well, that's pretty much the summary of what
renepay is.  If you have any questions, I'm glad to answer.

**Mike Schmidt**: Well, it sounds like there's some work to be done, potential
bug fixes, maybe performance improvements.  So, I'm sure you have your hands
full there.  Are you aware of any of the other Lightning implementations working
on something like renepay?

**Eduardo Quintana**: Okay, so I think it was six to seven months ago, I know of
Carsten Otto was working on his own, it's like a sort of a plugin for LND, it
was called manageJ, I don't remember exactly, but there is a discussion on the
Linux forum.  That's the only implementation that I know that precedes the one
in CLN, so we are right at the beginning.

**Mike Schmidt**: Dave or Murch, do you have any questions or comments about
renepay?

**Dave Harding**: I just wanted to answer your previous question that LDK also
merged an implementation very close to René and Richter's original description.
I did that a few months ago; we covered that in the newsletter, I believe.

**Mike Schmidt**: Okay, great.

**Mark Erhardt**: I kind of wanted to repeat something that I'm not sure was
super-clear.  So, the way that this payment planning algorithm works is that it
tries, as Eduardo said, to find a sweet spot between the count of parts on the
multipath and the amount per path.  And then whenever an attempt fails, it will
learn and update its model of the network for where the liquidity is available
and not available in the Lightning chart.  So with each attempt, for example, if
it cannot route X amount in a channel, it knows that X is too much, so it can
change the assumed channel liquidity for that channel to zero to X, the
statistical -- I think it's the average or you can later correct me!  Anyway,
the sweet spot between zero and X would then be picked as for the model, whereas
previously it would have first assumed that about half of the capacity is on one
side.

So, with each attempt it learns, it's a Bayesian learning algorithm where it
updates its model with each attempt, and that's why it very quickly finds an
optimal route for the updated model.

**Eduardo Quintana**: Okay, so just let me clarify that.  Once we try payment
along the path and there is a channel, but one of the channels that fails
because it cannot forward these X amounts, then we know for sure that every
channel before that channel was able to forward it, so we state this in our
knowledge.  And that channel that failed, we also state in our knowledge the
fact that this liquidity is below X.  So, if the liquidity distribution is a
uniform function, let's say at the beginning it will be zero to the capacity, so
it could be anywhere between zero and the capacity, and there is a probability
distribution function to describe this.  And once we know that the liquidity is
less than X, X-minus-1, then we update the knowledge by changing this
probability distribution from zero to X-minus-1.

I know it sounds very complicated, but it is just a uniform probability
distribution, so it can be described by two numbers, A and B, which are the
bounds, the lower and the upper bounds of where the liquidity is.  It's just two
parameters for each channel.  At the beginning, A is zero and B is the capacity.
And once we start learning things about the channels, we update these two
numbers.  There is one detail, which is the fact that as time goes by, channels
that do not belong to us, they have movements in their liquidity because the
network is dynamic and we don't know about other payments that are going out of
there.  So, I propose a way to forget the knowledge of where the liquidity is
with time.  And by now it's linear, but it can be something else.  It's just a
proposal, but it's also something to think about.

**Mike Schmidt**: Well, Eduardo, thank you for joining us.

**Eduardo Quintana**: Okay, thanks for having me.  Yeah, thanks for walking us
through that and thanks for your work on renepay.

_Core Lightning #6466 and #6473_

Next PR from the newsletter is Core Lightning #6466 and #6473.  And this adds
support for backing up and restoring a wallet in CLN using codex32.  So, there's
actually an RPC called getcodexsecret that will print out the formatted Hardware
Security Model (HSM) secret in BIP93 format, and BIP93 is the codex32 BIP, which
is the standard for backing up and restoring a master seed from an HD wallet
using Shamir's secret sharing.  And these changes also allow for restoring the
LN node and CLN from a similar 32-byte secret encoded at that same codex32
secret.  And both of these are within the Lightning-hsmtool, which is the Core
Lightning's way of interacting with HSM secrets in Lightningd or CLN.  Murch or
Dave, anything to add there?

**Dave Harding**: Well, I mean, about this specific PR, I just have nothing
really to add.  I do want to say that I think codex32 is really cool and I'm
really excited to see wallets starting to add support for it.  It's going to be
a long time until we have a lot of wallets supporting it, but I'm glad to see
CLN taking the first step.  I also got a message from René Pickhardt correcting
my earlier comment about LDK implementing his system, so I just wanted to
correct that.  They implemented part of it.  They implemented a probabilistic
model of liquidity, but not the actual pathfinding algorithm or payment planning
algorithm, as I believe René likes to call it, so I wanted to correct that,
sorry.

_Core Lightning #6253 and #5675_

**Mike Schmidt**: Thanks for clarifying, René and Dave.  We have another pair of
PRs to CLN, Core Lightning #6253 and #5675, adding experimental support for
BOLTs #863, which is the draft spec for splicing.  We had Dusty Daemon on last
week when we went through a bunch of other CLN PRs, and he spoke a bit about
splicing and his work on it in our #262 recap podcast.  So if you're curious
about some of the details there, check out that podcast.  We've also talked
about splicing a few different times in the newsletter and on our recap here.
So, Murch, I'm not sure how much you want to get into it, other than a round of
applause for rolling out more splicing-related work.  Thumbs up from Murch.

_Rust Bitcoin #1945_

Next PR is to the Rust Bitcoin repository, #1945.  This one's a little bit
different.  It modifies the project's policies for how much review that a PR
requires before it's merged, if that PR is just a refactoring PR.  And they
changed their contributing markdown file details and added a section that they
call refactor carve output, in the contributing file.  And the relevant text
there is, "This repository is going through a heavy refactoring and 'trivial'
API redesign as we push towards API stabilization.  As such, reviewers are
either bored or overloaded with notifications.  Hence, we have created a carve
out to the 2-ACK rule".

So, I guess traditionally they've had a two-act rule for the Rust Bitcoin
project, and they have a carve out here that states, "A PR may be considered for
merge if it has a single ACK and has sat open for at least two weeks with no
comments, questions, or NACKs".  So, I think that was the relevant segment from
the change in their policy.  And we noted in the newsletter that other projects
with challenges getting refactors may want to investigate Rust Bitcoin's new
policy.  Murch or Dave, any thoughts?

**Dave Harding**: I wanted to add that when I was a maintainer of a project, I
really liked merge deadlines, pretty similar to what they're doing here, which
was that once something got a little bit of review, or even if the PR was opened
by a maintainer who deemed the PR to be minor, they would say, "This is going to
get merged on such-and-such date, unless somebody complains".  And again, you
still need to have somebody who knows the project and can say that this is safe.
But as long as that's in place, I think a lot of this minor stuff can be dealt
with in a more simple way.  And the time-based deadline just makes it clear to
everybody what's going to happen and when it's going to happen so there's no
surprises.  So, that's what you really want to be as a maintainer, is not a
surprise the people who are contributing to your project.  So, I thought this
was just a good idea and I was glad to see this project doing that.

_BOLTs #759_

**Mike Schmidt**: Last PR this week is to the BOLTs Repository, #759, adding
support for onion messages to the LN spec.  And onion messages allow sending
one-way messages across the LN using encryption and blinded paths.  Onion
messages are also used by the BOLT12 offers protocol.  Dave, maybe a question
for you.  It seems like we've been talking a lot about onion messages for the
last year or plus in the newsletter, and also on these recaps, but it wasn't
even merged into the spec.  Do you have insight into why that took so long?

**Dave Harding**: I think they were waiting for -- there was some holdout there,
I think, from LND.  So, Olaoluwa Osuntokun, roasbeef, or Laolu, he was
concerned, as we've covered in previous newsletters, that onion messages are
subject to abuse.  They're free to send, they don't involve any money, any
lockup of capital.  You can technically send them even if you don't have a
channel with a node, although most implementations only allow you to send that
to your direct peer.  So, it's kind of just like an extra onion routing layer
over the internet.  It's basically what Tor provides, and Tor has its own
problems.

So, he was concerned about message spam.  Now, in previous newsletters that
we've addressed, I think I might link it here in the, yeah, we have a link in
this newsletter to a previous newsletter, #207, about some discussion about
trying to solve that spam issue, that DoS abuse, where people can just send
messages to your node for free, using up your bandwidth and your peers'
bandwidth.  But the guys said there was some concern there, and so they wanted
to make sure it was safe.  Everybody wanted to discuss it to the point where
everybody was relatively okay.  And I think that they finally got to that point.
But before that point, it needed to be implemented, and people have been
building stuff on top of it, most notably BOLT12, the offers protocol.  So, I'm
excited to see this merged, and I'm really excited to see offers.

**Mike Schmidt**: For those curious about some of the tech that we just talked
about, we have Optech topic entries for onion messages, blinded paths, and
offers on the Optech Topics page for more detail.  All right, fairly beefy recap
this week.  Thanks to all our guests for joining.  Thanks for Dave, Eduardo,
Murch, my co-host as always, Clara, Josie, Peter Todd.  We had a great set of
contributors this week.  Thank you all for your time.

**Mark Erhardt**: Thanks, hear you soon.

**Mike Schmidt**: Cheers, bye.

**Eduardo Quintana**: Thank you.

{% include references.md %}
