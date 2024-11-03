---
title: 'Bitcoin Optech Newsletter #320 Recap Podcast'
permalink: /en/podcast/2024/09/17/
reference: /en/newsletters/2024/09/13/
name: 2024-09-17-recap
slug: 2024-09-17-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Bruno Garcia, Shehzan
Maredia, Gloria Zhao, Fabian Jahr, and Gregory Sanders to discuss [Newsletter #320]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-8-18/386577876-44100-2-086cd0291434.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #320 Recap on
Twitter Spaces.  Today we're going to talk about mutation testing for Bitcoin
Core, there's a cool DLC-based loan setup in Bitcoin that we have Shehzan to
talk about.  We have Gloria and Fabian with us today.  Gloria will be joining
shortly to discuss Bitcoin Core 28.0.  And then we have our usual segments on
Releases and Notable code changes.  I'm Mike Schmidt, contributor at Optech and
Executive Director at Brink, funding Bitcoin open-source developers.  Murch
isn't here yet to introduce himself.

**Mark Erhardt**: Hello, I'm Murch.

**Mike Schmidt**: Oh, he is!

**Mark Erhardt**: I think this works now!

**Mike Schmidt**: You're here!  Okay, good.

**Mark Erhardt**: I don't know, anyway, it works now.  Yeah, I work at Chaincode
Labs, I work on Bitcoin stuff.  Good to hear you.

**Mike Schmidt**: Bruno.

**Bruno Garcia**: Hi everyone, I'm Bruno, I am Bitcoin Core contributor and
Educational Director at Vinteum.

**Mike Schmidt**: Shehzan.

**Shehzan Maredia**: Hey everyone, my name is Shehzan and I'm the founder of
Lava.

**Mike Schmidt**: Fabian.

**Fabian Jahr**: Hi, I'm Fabian, I work on open-source Bitcoin stuff, mostly
Bitcoin Core, and I'm working with Brink.

**Mike Schmidt**: Greg.

**Greg Sanders**: Hi, I'm with Spiral, and I do mostly Bitcoin mempool stuff.

**Mike Schmidt**: Well, thank you all for joining us.  We have a special guest
for many of the segments this week, so it's great always to hear from the great
work you all are doing.  Appreciate you taking the time to join us.  If you're
following along at home, it's Newsletter #320 and we're going to go through
sequentially here, starting with the News section.

_Mutation testing for Bitcoin Core_

The first News item, "Mutation testing for Bitcoin Core".  Bruno, you posted to
Delving Bitcoin, a forum post about a new Python tool that you've created called
Mutation Core that is a mutation testing tool for Bitcoin Core.  Maybe to start,
what is a mutation tool and why is it useful?

**Bruno Garcia**: Great.  Mutation tests basically is used to evaluate the
quality of existing tests.  So, mutation testing basically modifies a program in
small ways.  And we modify a program, and then we run the tests to check if the
tests are able to detect that change.  It's useful to check if our tests are
good, for example, because we usually check, for example, code coverage, but
this is not enough.  So, to know if our tests are really good, it's important,
for example, to have mutation testing.  And yeah, this is basically a
definition.

**Mike Schmidt**: So for Mutation Core, what files are targeted for mutation and
which are not, or are you mutating all the files?

**Bruno Garcia**: With this tool, you can specify which file you want to mutate,
or you can specify the PR or commit.  And when we specify a PR or a commit, for
example, the tool, you check which files and which part of the code you are
touching.  And based on this, we apply the mutations only on this piece of code,
basically.

**Mike Schmidt**: And the mutations, is it changing existing lines, is it
deleting lines, is it adding lines of code or parts of code, or maybe you can
walk through some of that?

**Bruno Garcia**: We basically change, for example, I can give an example.  We
have, if A greater than B, we can modify it to, for example, A greater than or
equal, or A is less than B.  Then B, we can add some break, some continuing.
There are a lot of mutations.  And specifically on this tool, I designed some
mutation operators for Bitcoin Core.  So for example, it can increase the value
of C amount or decrease.  And, yeah, but there are a lot of mutations that it
can do.

**Mike Schmidt**: And the idea is that after making this change to the code,
that the unit test or functional test should pick up on that change and catch
that there's an error?

**Bruno Garcia**: Yeah, yeah, it should fail.  So for example, if I modify the
code and run the test, we expect the test to fail.  If the test doesn't fail, so
we can add one more test case, or whatever.

**Mark Erhardt**: How many mutants are created per line?  Are you trying all the
things, or is it just a single one?

**Bruno Garcia**: You can specify.  You can generate just one mutation per line
or a lot of mutations per line.  Thinking about, for example, CI/CD, it's good
to generate less mutants.  So, you can specify that you want to generate just
one mutation per line.

**Mark Erhardt**: So would it always create the same mutation, or is it random?

**Bruno Garcia**: It's the same.

**Mike Schmidt**: Is there a library that you use that does this sort of
mutation and then you've added some Bitcoin Core sugar on top, or is this
something that is really from scratch that you've created?

**Bruno Garcia**: Yeah, it's from scratch.  I use RegEx to detect some patterns,
for example to detect for a variable or a constant using C amount.  So, I use a
RegEx to detect it, and then I replace the value increasing 1, or decreasing by
1, and yeah.  But I wrote this by scratch.

**Mike Schmidt**: Have you been using it yourself before you've now published
it, and if so, has it been fruitful?  Has it uncovered things that should be
covered that weren't previously covered?

**Bruno Garcia**: Yes, yes.  I use it a lot to review some PRs, to check if, for
example, if you are writing a new feature, you basically write tests.  Then I
use this tool to know if the tests are good, for example.  And there are some
mutation operators designed to test fuzzing.  And it also mutates functional
tests by removing statements and method calls to check if the test is good or
not.  So for example, if a test passes with a statement or method call remove
it, it could indicate a problem in the test.  So I also use this tool to
evaluate the functional tests, so not only mutating the source code itself.

**Mike Schmidt**: Who's the intended audience to run this tool?  Obviously,
you're going to continue running it.  I assume you want other Bitcoin Core
developers to potentially run it against their code before or during a PR.  Is
this something that you would like other folks to be running as well and
uncovering things, or maybe talk a little bit about that?

**Bruno Garcia**: Yeah, yeah.  It would be good if other developers run it
basically to test their own PRs, their own code.  But I'm working on basically
when someone push a PR or push a commit, I'm working on a version of this tool
that could run the mutation testing automatically and give a report to the
developer like, "Here is the surviving mutants", then you can verify, and yeah.

**Mike Schmidt**: You mentioned running it against open PRs.  Is this something
that you've also run against the existing codebase of things that are already
merged and potentially years old as well?

**Bruno Garcia**: Yes, yes, both cases.

**Mike Schmidt**: Excellent.  Murch, did you have any other questions?

**Mark Erhardt**: Finally, we figured out who tests the tests.  That was a joke!
Sounds really cool.  Thank you, Bruno!

**Bruno Garcia**: Thank you.  The idea of applying mutations in the tests
specifically, the idea is new.  It was published in an article in an academic
paper this year.  So yeah, this idea is basically something new.

**Mike Schmidt**: Awesome.  Thanks for putting that out there, Bruno.  You're
welcome to stay on.  If you have things to do, we understand if you need to
drop.

**Bruno Garcia**: Thank you.

_DLC-based loan contract execution_

**Mike Schmidt**: Second news item this week titled, "DLC-based loan contract
execution".  Shehzan, you posted to Delving about Lava Loans, which is a
DLC-based loan protocol.  And I want to get into that, but maybe perhaps first
you can explain the context of what you've been working on with Lava more
broadly, and then we can jump into the loans component.

**Shehzan Maredia**: Yeah, thanks for having me on.  Basically, the reason to
work on Lava Loans, in the last two years, we've seen a lot of people wanting to
borrow against their bitcoin.  Usually people will borrow because they don't
want to sell.  Selling often involves taxable consequences and losing exposure
to bitcoin.  A lot of people that hold bitcoin, the asset, don't want to let go
of their bitcoin and would like to expose themselves to price appreciation if
they can.  But today, and even two years ago, there were a lot of people that
were borrowing using custodians, basically giving unilateral custody of their
bitcoin to FTX or BlockFi or something else like that.  There's been a ton of
custodians that were around like two years ago that have basically gone bust
now.  And a lot of these custodians didn't go away because of lending against
Bitcoin.

Actually, lending against bitcoin is not that risky because bitcoin is now a
very liquid asset and they can hedge themselves by inputs on open markets.  It
was really because they would take users' bitcoin and rehypothecate it, running
trades that ended up not doing as well as they thought they would.  Alameda was
one of those examples that thought they could just take bitcoin and run GBTC
trade and a bunch of other trades and thought there were no risks, but they
ended up being a lot riskier than people thought.  In Ethereum, actually,
regardless of all the problems in Ethereum, a lot of ETH ended up being borrowed
on some protocols onchain that didn't go bust because they weren't being
rehypothecated.

At Lava, we think that we could do a better job in building a protocol that lets
you borrow against bitcoin more trustlessly, where you can have more confidence
that your bitcoin is not going to get rehypothecated.  We use DLCs.  Tadge
initially proposed DLCs a while ago, and we use it to let you lock your bitcoin
on the layer 1 and then borrow a digital dollar.  You can move it; we have a way
for you to move it instantly back to your bank account.  And then during a loan,
the bitcoin just stays there, you know it's not moving anywhere.  You can either
repay the loan, which is a fully atomic interaction, so if you repay, you get
your bitcoin back as a borrower.  But the DLC enables, for example, the ability
to facilitate loan expiration, which is when, like, if a loan expires, the end
of a loan term, you can use a set of oracles instead of just a single party.
You can choose a set of oracles.  In DLCs, the oracles are blinded, so they
don't know about the contracts that are using their data, and you can actually
have each contract use its own set of multiple oracles.  And you can use that
price attestation to resolve a loan execution event.  Let's say on expiration,
you could have in this context of Lava Loans, the lender receives some amount of
bitcoin based on what they initially lent, plus the interest, and the borrower
receives the rest of bitcoin.

Basically there's already a bunch of borrowers that still use custodial
services, like Binance, for example, is the most popular now.  This is an
alternative for those people who might not want to KYC their bitcoin, give it to
Binance and then give unilateral custody of their bitcoin up.

**Mike Schmidt**: If I'm understanding correctly, if I have bitcoin and I need
some form of dollar liquidity, I can lock up my bitcoins in this DLC and as part
of that setup, there's something like an atomic swap that the bitcoin goes into
the contract, and at the same time I, as the borrower, would get USDC or USDT or
something like that on another chain.  Am I getting that right?

**Shehzan Maredia**: Yeah, exactly.  We don't even require there to be
stablecoins on the Bitcoin blockchain.  My view is that there's no point of
doing that, especially even for Bitcoin censorship resistance.  We probably
don't want issuer control and more issuer growth on the Bitcoin blockchain.  So
yeah, you can atomically swap and get any stablecoin.  There's a bunch of
stablecoins that are dollar-backed and Treasury-backed like Tether or USDC.  And
so, you can atomically initiate a loan and atomically repay a loan, so there's
not oracles that are being used for loan initiation and repayment.  And then you
can take your stablecoin and withdraw it to your bank account, for example.  And
then if you don't repay the loan, it'll probably expire at some point.  Let's
say you borrowed for a year.  At the end of the year, it'll expire, and then
you'll just get back the bitcoin minus what was owed to the lender in dollar
terms.

**Mike Schmidt**: And then while the coins are locked, there is this DLC, and
you mentioned I and the person lending me these dollar tokens can agree on one
oracle, or I guess you could have a collection of oracles that we agree on, and
then there's some sort of mechanism to reconcile the price as time goes by.  If
the bitcoin price goes down, there would be some sort of a liquidation based on
those oracle attestations.  Is that right?

**Shehzan Maredia**: Yeah, exactly.  Yeah, we made this open-source oracle
implementation, called Sibyl.  So basically what that does is, it tries to
figure out the price using exchange APIs and then makes this attestation to it.
And then you can have a bunch of different people running an oracle and choose a
multi-oracle setup per DLC.

**Mike Schmidt**: So for folks who haven't looked into this, I think we linked
to it in the newsletter, but if not, click on the News item and go to the
Delving post and then there's a link to this white paper with obviously a lot
more details, because there's quite a bit of technology here going on with the
swaps, the DLCs; was there adapter signatures being used here as well?

**Shehzan Maredia**: Yeah, yeah, for DLC stuff we used adapter signatures.

**Mike Schmidt**: Yeah.  Very cool.  What's feedback been on the technical side
so far?

**Shehzan Maredia**: It's been great.  A lot of great feedback from a lot of the
Bitcoin developers.  And yeah, it's been really good from users and developers.

**Mike Schmidt**: Excellent.  Sorry, I've been monopolizing the questions.
Murch, do you have questions?  Okay, thumbs up.  Awesome.  Well, Shehzan, thanks
for joining us.  Any calls to action other than check out the post, check out
the white paper, maybe download the app and play with it; anything else?

**Shehzan Maredia**: Yeah, there's like a CLI as well that you can play around
with if you're more technical and listening to this.  If you have any questions,
feel free to DM me on Twitter and we can go over anything.

**Mark Erhardt**: Well, I have one question maybe.  So, you would be trusting
multiple oracles to remain available, right?  And so, I'm not sure if there's a
marketplace, or enough time that oracles have been around to have that sort of
trust in them.  How would you ensure that these oracles remain available?
They're not getting paid, they don't know what the contract is that they're
providing information for, or are they paid?  How does it work?

**Shehzan Maredia**: Yeah, there's been a lot of research around this, like
SuredBits did some back in the day, and then they're not around anymore, but
there's been a lot of research around oracles.  I mean, this is a very long
conversation, but the tl;dr is you probably just want your oracles to be run by
institutions that you trust.  For example, we have a bunch of these Bitcoin
institutions and companies that will run oracles.  It's not that expensive to
run an oracle at all, like a couple dollars a month in server cost.  And you
know, the oracle, you just want like liveness guarantees, so you just want to
trust these oracles to be live, and you can trust the companies that you think
have the infrastructure engineers to do this.  If the oracles wanted to collude,
they wouldn't be able to directly earn money from the DLC, because the outputs
are already known ahead of time, but they could collude with a party.  And so,
you just want to choose a trusted set of oracles.

The oracles are definitely a trust factor, but the benefit here is, the
alternative is you're just trusting a single party or a custodian, right?  Here,
at least you have more flexibility on who you're choosing, and it's a lot easier
to have a globally distributed set of oracles versus a custodian that's globally
just distributed, that you can independently choose the custodial parties, if
that makes sense.

**Mark Erhardt**: Yeah, that makes sense.

**Mike Schmidt**: Bob, did you have a question?

**Mark Erhardt**: I can't hear Bob.

**Shehzan Maredia**: I can't either.

**Mark Erhardt**: We lost Bob.  All right.  So, Shezan, the lender would earn
money, just interest; the funds are co-owned or co-custodied by the lender and
borrower together with a smart contract that is based on these distributed
oracle inputs; and so, there is a financial incentive for the borrowers.  It
sounds like it's just a strict improvement over the design of the custodial
borrowing that went on with various companies that got into financial trouble
recently.  What was stopping us from doing this before?  Is it just that the
technology wasn't ready, are the financial incentives much worse, or how does it
compare with the previous?

**Shehzan Maredia**: Yeah, I mean I think that our team is doing a lot with
DLCs.  There's really, I think at this point, no other company really working on
DLCs from what I'm familiar with.  I know SuredBits was doing a lot back in the
day, and 10101 shut down recently, and they were doing something completely
different.  So, yeah, I think it's a lot of the technology work we've done
around DLCs.  We made this oracle implementation, a library to use DLCs in this
application, for example, as well.  And I mean, in the last two years, everyone
was just basically launching.  For loans, everyone was just launching custodians
basically.  But I do think that the market today wants a more self-custodial
option.

**Mike Schmidt**: Bob, you're back.  Can we hear you?  We cannot.

**Shehzan Maredia**: Yeah, we can't.

**Mike Schmidt**: Bob, if you want to throw it in the chat, if you have
something that is pithy that can go in there, we can read it out and try to go
through it.  Otherwise, I think we should probably move on with the newsletter.
What do you think, Murch?

**Mark Erhardt**: Yeah, I'm good.

**Shehzan Maredia**: All right, thanks for having me on.

_Testing Bitcoin Core 28.0 Release Candidates_

**Mike Schmidt**: Yeah, thanks for joining us.  Next segment of the newsletter
is our Bitcoin Core PR Review Club monthly segment.  Testing Bitcoin Core 28.0
Release Candidates was the Review Club meeting this month, so it was not a
review of a particular PR, but the 28.0 Testing Guide that we covered last week.
We thought this was a good opportunity to bring on some experts to walk us
through the release.  Right now, it's an RC, but I think the big pieces are
there.  So, we have Gloria, Fabian, and Greg, who all contributed to this
release.  Gloria, Fabian, and Greg, the Testing Guide outlined eight topics.  I
don't know if we want to go through those sequentially or what makes sense.  I
defer to one of you to maybe take the reins, and we can go through those eight,
or go in a different order, whatever you want.

**Gloria Zhao**: Hello, can you hear me?

**Mike Schmidt**: Hey, Gloria, do you want to introduce yourself real quick
since we missed you in the beginning?

**Gloria Zhao**: Great, yeah.  Sorry for being late.  I'm Gloria, I work on
Bitcoin Core.  Greg and I made some of the cool features in 28 that we're very
excited about.  I think testnet4 is also a good one that Fabian would be the
expert on.  But I guess I can also first give the spiel on the Testing Guide.  I
think you already did a Spaces on it, but for everyone who missed that, for
every major release such as 28.0, which is the next one, we always put out RCs.
And the idea is everybody should test the RCs and find the bugs before the
release comes out.  And I think historically, we've had some trouble getting
people to do this.  And so one of the efforts includes this wonderful Release
Guide that rkrux put together.  It's always a really amazing volunteer and I'm
told it's a great learning opportunity.  So, if anybody wants to do 29, please
reach out to me.  And the other initiative is to do a Review Club meeting, where
everybody goes through the Test Guide together and we can kind of help each
other out, connect to each other on testnet4, relay packages to each other, send
each other coins, etc.  And that kind of has a little bit more of an integrated
environment for trying out all the new features.

You mentioned eight topics.  I don't have them off the top of my head, but the
ones that I'm excited about are, of course, the 1p1c (one-parent-one-child)
package relay, package RBF, TRUC, sibling eviction with TRUC.  There's also
Ishaana's PR for tracking wallet conflicts in mempool.  I think that's a bit of
really important kind of tooling, or not tooling, but really important, what's
the word for it?  Like, things you need to handle when you have different
conflicts in mempool, especially with I guess mempoolfullrbf being on by default
now, you can have more unexpected conflicts.  So, it's really great that wallet
handles that properly.  I guess now, I might hand the mic over to Fabian to talk
about testnet4, and then we can talk more about mempool stuff later.

**Mike Schmidt**: And assumeUTXO mainnet as well.

**Gloria Zhao**: Yes, I'm sorry.

**Fabian Jahr**: I have the list in front of me, so I can also give the points
in detail.  The first one is testnet4.  So testnet4, as laid out by BIP94, has
also been a topic in Optech previously.  That has been added, and so you can
start it with the testnet4=1 option, and then you're going to sync testnet4.
The Testing Guide kind of lays out how you can test it against the previous
release and how their testnet4 is not supported yet.  I think beyond that,
really my suggestion would be that you just sync to the testnet4 node, which
should be really quick, it's not taking up much space.  And then you just play
around with it.  If you have anything that you have been doing on testnet3
previously, then just try to do it on testnet4.  You can get coins.  For
example, there's a faucet on mempool.space.  And yeah, I've just seen testnet3
seems to be attacked again.  So, yeah, it would be a great time to try out any
tooling that you have, that you might use, to test it out on testnet4 and maybe
keep using it in the foreseeable future.

**Mike Schmidt**: Excellent.  And for that reference back to that conversation
previously, I think it was another PR Review Club that we did a recap on in
#311, and Fabian was on there talking about testnet4.  So, if you want to
double-click on that, check out #311 for more details there.  Gloria, the second
one here was TRUC transactions.  Do you want to give your pitch and why folks
are excited about TRUC transactions in 28?

**Gloria Zhao**: Sure, yeah.  I'll say one more thing about testnet4, which is
because testnet4 got merged after a lot of the mempool things and the package
relay stuff, most of the miners running testnet4 also have those changes.  And
so, there are some pretty nice, interesting demonstrations of cool transactions
on testnet4.  So, I did a zero-fee TRUC package-relayed transaction on testnet4.
I think I was the first person to do that.  But as 28 comes out, it would be
great if someone beats me to the punch on mainnet.  So, feel free to do that.
And I think t-bast also used TRUC and Pay-to-Anchor (P2A) to do a zero-fee
commitment transaction, like LN commitment transaction on testnet4.  So,
testnet4 has some cool transactions now, so it has that going for it.

Anyway, so the feature I'm supposed to talk about is TRUC, which is outlined in
BIP431.  So, as a reminder or refresher, we had a lot of features that we
really, really wanted to build, like package relay, package RBF, less pin-prone
RBF set of rules, and less pinning in general.  And this was a project with a
massive scope, or easily was subject to a lot of scope.  And one of the main
blockers that we ran into was comparing these features and these anti-pinning
and these incentive-compatibility design goals with DoS resistance and trying to
make sure that all of the new policies that we add, like assessing, "Okay,
what's the package feerate?  What's the CPFP that we can effectively apply to
these transactions as we're validating them, or as we're evaluating them for
eviction or replacement?  How can we make that with computational bounds that
are acceptable to us?"  And this turned out to be a huge, huge, huge, huge
challenge because of how permissive topologies are in our current mempool setup,
which is something that we inherited from Satoshi's decision-making, not to
knock on him.

But we thought, okay, on the one hand, as a long term goal, we can try to change
fundamentally how the mempool structure, that's what cluster mempool is, to kind
of create better bounds and a better trade-off between DoS protection and the
ability to assess transactions in a more holistic manner.  But TRUCs are like,
"Okay, I have these mempool policies that I want to implement, what are the
topologies that are really useful and also a good trade-off?"  And it's 1p1c.
We found that that addresses a lot of use cases, not all of them, but it is
extremely useful and it is dead simple to implement.  And even moving forward
past if we had cluster mempool, we can still use this as a kind of anti-pinning
idea.  And so a lot of people are thinking of TRUCs as restrictions, which it's
in the name, Topologically Restricted Until Confirmation.  It is a restriction
and they're like, "Oh, I'll just let v3 transactions in, but they won't be
subject to these restrictions".  But I think that's kind of missing the point.
It's more, we have these v3 transactions that we can assess more holistically if
we apply these restrictions to them.

These restrictions happen to be something that is well within the bounds of what
people might be creating their transactions for.  Like 10,000 vbytes is way more
than what the average person needs, right?  Like if your one payment has, I
don't know, just a couple of inputs, which is very, very common, and it has the
payment you're trying to make and your change address, that's usually not going
to be 1000 vbytes.  So, 10,000 is plenty.  So, that's my argument.  And same
thing with the L2 use cases, like with Lightning, and I saw someone talk about
DLCs.  Greg has also written something up for Ark.  Well, sorry if I just
revealed that you're working on a guide, Greg, but there's going to be
literature about the best ways to use this.  So, yeah, sorry, I just covered
TRUC and package relay, package RBF, a lot of different topics.  But they're all
very intertwined, and this is kind of the first really, really major milestone
in terms of all of those projects making progress.  And you'll be able to use
that in 28.  Okay, I'm done!

**Mike Schmidt**: Greg, Gloria referenced t-bast's example.  I think he posted
on Twitter at some point saying that it involved TRUC as well as P2A.  Maybe you
want to talk a little bit about P2A, and that's the sixth one in the list here
from the guide.  What is P2A and how did what t-bast do involve P2A and TRUC
transactions, and why is it cool?

**Greg Sanders**: Right, so P2A is a different type of output that goes along
with the idea that some transactions need a way to attach fees onto that
transaction using a child.  And so, for example, today with the LN, commitment
transactions have two anchors, one for each side, and each side has a key in it
for spending it.  This is necessary for this format because if you have a shared
output to spend for these fees or a keyless output, then your counterparty can
do pinning attacks by including overly large or weird topologies that restrict
how you can do RBFs, and that's problematic for time-sensitive transactions,
like LN.  So, with TRUC transactions, the topology is restricted and we can
confidently replace things, also with sibling eviction.  There's a new trade-off
we made where you can say, "Well, I don't really care who adds fees to this
parent transaction using a child, using CPFP, so I'll allow anyone to do it".

So, with a keyless anchor, P2A, it saves space, the output is 29 vbytes smaller,
and spending requires no signature data, It's just an empty witness output.  And
so, you save around 50-something vbytes, off the top of my head, versus a keyed
anchor.  And if you believe that the TRUC restrictions are sufficient to avoid
pinning, then that's like a net gain.  It also allows arbitrary watchtowers to
help as well, so you don't have to share key material with a watchtower to allow
it to fee bump your commitment transaction.  And this goes for other things too.
So, this doesn't include having zero value outputs.  That's now been called
ephemeral dust.  So, the minimum size is 240 satoshis, fyi.

**Mike Schmidt**: Thanks, Greg.  Murch, any follow-up at this point?  We have a
few more from our punch list here.

**Mark Erhardt**: I'm just very excited.  So, this is, of course, a stepping
stone for commitment transactions to use new mechanisms.  And with the fee spike
recently, we saw a bunch of channels getting closed because LN Node
implementations couldn't agree on the current feerate or didn't accept the new
proposed feerate from the other side because they deemed it too high, and a
bunch of channels were closed.  So, one of the things where this will help in
the future is when commitment transactions can have a zero fee because they're
bumped with a P2A output and a TRUC transaction, then you can bring the fees to
insert your commitment transaction into the blockchain, always decided at the
time when you create the closing transaction.  Sorry, the closing transaction is
the commitment transaction, but it doesn't have to carry its own fees.  The fees
can be brought by the child transaction that is created at the moment.  So, you
can on-the-fly decide the feerate that you need.

That makes commitment transactions a lot more flexible and this whole
negotiation around feerates of commitment transactions sort of becomes
secondary.  And this is a long-term plan, of course.  We'll probably have to
wait for a year or so for this to be rolled out in the LN broadly, but one of
the impacts is that the UX on LN gets a lot better.

**Greg Sanders**: Yeah, to pipe up a little bit, I think you're going to see a
lot of that benefit is simply from people updating their nodes, so 1p1c relay.
So, I think you'll see a number of LN implementers be more relaxed or turn off
this kind of unilateral close on fee disagreement kind of behavior, because once
it's not a security risk, you're not worried that the parent transaction can't
make it to the mempool of a miner at all.  Once you're not worried about that,
you can relax a bunch.  So, I think you'll start seeing better effects within
the year, even without transaction format changes.

**Gloria Zhao**: I think in general, probably for LN users, because fewer force
closes and you don't have to overestimate the fees on a commitment transaction,
I imagine that you'll see basically costs go down.  Just overall, it becomes
cheaper to use LN, both in the spikes where you don't have to pay the fees to go
onchain for your accidental force close, but also hopefully the margins can be a
little bit lower in terms of fees.

**Mike Schmidt**: Fabian, jumping to the assumeUTXO item from the Testing Guide
and release, what about assumeUTXO has changed in this forthcoming 28.0 release?

**Fabian Jahr**: Yeah, so I mean the big thing that has changed is that it's
ready to use on mainnet.  So, we have parameters in the code now for mainnet
that is for the last halving block, so 840,000.  And so, you can use it now.
Aside from that, the output format of dumptxoutset has changed.  So previously,
you could use dumps for signet and for testnet.  These will not work anymore,
and the Testing Guide goes into a bit more detail about how to test that, how to
test a new format, and you should see error messages that would make sense for
you if you use an older dump.  But personally, I think the mainnet part is the
more exciting part.  And my suggestion there is kind of similar to the testnet4
thing, is if you have the availability in terms of a machine, where you can
start a new node and just start it with assumeUTXO with a dump, then to let that
run, and then to try out all of the things that you usually use your node with
to some capacity on that node, while it runs and while it's syncing in the
background.

So, there's quite a few edge cases that we have discovered over the last couple
of months.  And we're still finding some smaller edge cases about how to handle
the state that node is in while it's syncing in the background from this
assumeUTXO dump.  And so, that's very helpful if you just try out using your
node.  Whatever you do with your full node, basically just try it out.  Call all
the RPCs that you like and look at the output, look if it makes sense, look at
the logs if it makes sense.  We just found another edge case, and this is just
basically logging that does not look correct, but yes, some wallet-related
descriptor import functionality that was assumed to work different than it
actually does now.  So, yeah, basically just try it out, have fun with it, would
be my suggestion.

**Mike Schmidt**: Excellent.  Thanks, Fabian.  Gloria, you may have mentioned it
in your sort of overview summary, but do you want to give a little energy
towards why mempoolfullrbf is now on by default?

**Gloria Zhao**: Sure.  So, I think this debate, there is a lot of debate on the
option itself, surrounding the idea of, "Is full-RBF good or bad for the
network?" and that was hotly debated.  And the decision to do this has nothing
to do with that.  I think it wasn't relevant in this situation.  I would say
this decision was motivated entirely by whether or not it is harmful to a node
operator, to the person running Bitcoin Core, if mempoolfullrbf is turned on or
off.  That's what informed the change of the default.

So, as a general rule of thumb, when there are differences in mempool policy,
basically between what the miners are running and what you are running, it means
that the miners will be mining a lot of transactions that are not in your
mempool when they are included in blocks, and that can be difficult for a number
of reasons.  One is your compact block reconstruction will not work and you'll
require an extra round trip when you fetch that block.  And then when you get
the block, you haven't seen this transaction before, you haven't validated it
before, so it just takes a little bit of extra time for you to go ahead and do
that.  And across the network, again defaults matter for the network as a whole.
When you have poor block reconstruction at each node, that really ups the
latency of block relay, and that means more frequently you have races, that
means you have reorgs more often, and it's just unhealthy for the network as a
whole.

So, when we were considering this PR over the past, I think, two years that
we've had this option, we've kind of kept an eye on, okay, how much are miners
using full-RBF?  And more directly to the point is, how much are we seeing
compact block reconstruction suffer?  So, for example, my personal testing
basically included running a non-full-RBF node and seeing what transaction --
so, okay, so my node did not have full-RBF, but it did have the full-RBF logic
and it would log whenever I received a transaction that was a valid replacement,
but the only reason I rejected it was because it wasn't signaling.  And then I
would log again when those transactions were confirmed, and then I used a
mempool.space API to check which mining pool created those blocks.  That gave me
data that seemed pretty overwhelmingly to support the claim that most of the
mining pools are doing full-RBF.  So, that gave me a signal as to what adoption
looks like on the miner side.

Then, 0xB10C had full-RBF nodes and non-full-RBF nodes and comparing the block
reconstruction rate, and it was pretty night and day, at least from how I saw
it, where you go from like in the 90% to, what was it?  There were some 40%,
some 70%, very, very low.  We really want that number to be extremely high, like
as close to 100% as possible.  And so, it's this very clear thing that the
default option is causing your node to reject a lot of transactions that are
very likely to be mined for a known reason, like a known difference in policies
between what the default is and what miners are running.  And just, I think
that's the most compelling reason.  And of course, if you are expecting that
your transactions that were signaled non-replaceable to not ever be replaced,
that's not very safe.

I think, I can list other reasons, but I think I don't really want to get into
the debate as to like, is full-RBF good or bad?  I think we should focus on the
argument that your block relays is just worse and the network's block relay is
worse.  So, hopefully that gives some color to that.

**Mike Schmidt**: Yeah, thanks, Gloria.  And then one other thing that you had
mentioned earlier in the overview, that maybe you could elaborate for the
audience on slightly, is this mempool conflicting transactions.  How was such a
thing handled previously, and how is what's changed in 28 better for users?

**Gloria Zhao**: I'm going to try to punt this to Murch actually, because I did
review this PR, but it's been months now and I can't really give you all of the
details.

**Mike Schmidt**: Murch, do you have a synopsis off the top of your head?

**Mark Erhardt**: Yeah.  So, I believe the difference is that previously, we
didn't distinguish whether a transaction was conflicted in the mempool or
conflicted in the blockchain properly, and we sort of have better tracking, like
a higher resolution on what exactly the conflict state of a transaction is.  So,
you could have, for example, more than one conflict.  If you have multiple
inputs on a transaction, and then each of those inputs gets spent by another
one, there would be multiple conflicts that prevent you from entering your
transaction into the mempool.  So, now it counts if other conflicts are removed,
whether your transaction can be re-added to the mempool.  And I think previously
it was just binary, whether the conflict exists or not.  Now, your wallet sort
of tracks all of the different conflicts, how many of them are there, and
reports more appropriately to the user what exactly the issues are.  So, it's
more of an information than a behavior change.

**Mike Schmidt**: Great.  And I think we at least touched on briefly all of
these eight points, at least from the Testing Guide for 28.  Gloria, Fabian,
Murch, or Greg, is there something that isn't a feature that is highlighted in
the Testing Guide, or a category of bug fixes, or anything that you'd like
people to know about that isn't feature-related that we should inform people on
for 28?  Okay.  Murch, anything to wrap up this section?

**Mark Erhardt**: No, I think please test, especially if your business depends
on running Bitcoin Core, and check whether all of the mempool changes and RBF,
and so forth, would affect your business processes, and give us feedback if
there's something we need to know about.  Otherwise, yeah, the release is
hopefully out in a couple weeks and I, for one, am looking forward to seeing
more TRUC transactions and P2A stuff and play around with testnet4.  It's been
pretty fun.  I've mined some blocks using the difficulty drop rule, the
20-minute exception, and I've also created my own zero-fee transaction and
bumped it with a TRUC child.  So, just playing around and using these new
features has allowed me to learn a little more about the RPC.  So, it can be a
fun exercise and can be helpful if you find something that shouldn't be
happening.  Yeah.

**Mike Schmidt**: There's some big pieces in this release and, Gloria, maybe as
a maintainer, you've seen a lot of releases and changes over the years, and it
must be nice to see some of these projects that we've talked about here on
Optech, but also have been worked on for a long time, sort of get across the
finish line here, right, TRUC transactions, assumeUTXO, etcetera.  Do you have a
perspective on that you'd like to share?

**Gloria Zhao**: Yeah, this one's a banger, really good one.  Yeah, that's it!

**Mike Schmidt**: Well, congrats to you three for your contributions in this
release, and obviously the whole team of developers that worked on this release
and are continuing to work on getting this release out the door and testing.
Yeah, Murch?

**Mark Erhardt**: I wanted to correct something that I said about the mempool
conflicts change.  So, there is also a behavior change, and that is the Bitcoin
Core wallet.  When it is now aware that one of the inputs of a transaction is
mempool-conflicted, as in spent by another transaction in the mempool, it allows
you now, without abandoning the transaction, to re-spend that input.  So, it's
more than an information change, it's also a user experience improvement around
a conflicted transaction.  If you get paid, for example, and then the payment is
replaced -- well, sorry, I'm not going to get into this detail because I have to
think more about it.  But anyway, there's a behavior change there after all.

**Mike Schmidt**: Check out the Testing Guide, jump in, and you can actually
walk through an example of this yourself, so if you're curious about that
particular item.  Gloria, Fabian, Greg, thanks for joining us.  We have two
Bitcoin Core PRs at the end of the newsletter if you want to hang out, otherwise
we appreciate your time.

**Gloria Zhao**: Thank you.  Sorry, I've got to go, but thanks.  Bye bye.

_LND v0.18.3-beta_

**Mike Schmidt**: Moving to the Releases and release candidates section of the
newsletter, we have three this week.  First one, LND v0.18.3.  This is a beta
release.  It's out of RC status.  It is, "A minor release with primarily bug
fixes and stability improvements".  I think we touched on some of these items
over the last few weeks.  I'll summarize here.  This release includes some items
from our Notable codes section over the last month or two: extended blinded path
support, support for sending and receiving blinded paths using BOLT11 invoices.
We talked about, I think it was last week, the temporary banning of peers that
send too many invalid channel announcements.  There's the addition of the min
relay fee estimate to fee estimation API calls; there's additional manual coin
selection support in the SendCoinsRequest RPC; and LND also added the CLTV
expiry argument to a couple of their calls, the addinvoice and addholdinvoice
calls, which allow users to set the minimum final CLTV expiry delta; there's
also the ability to now use multiple blinded paths in a multi-part payment; and
there's a dozen or I think 15 or so bug fixes in this release.

So, they call it a minor bug fix release, but there are some features there as
well.  Murch, anything to add?

_BDK 1.0.0-beta.2_

BDK 1.0.0 Beta 2.  We covered this previously, so refer back to other
discussions for the details.

_Bitcoin Core 28.0rc1_

And Bitcoin Core 28.0rc1.  We discussed the big-picture features of this release
just a few minutes ago and we also had rkrux on last week to discuss the Testing
Guide.  So, jump in there and test away.

_Bitcoin Core #30509_

Notable code and documentation changes just two both Bitcoin Core this week.
Bitcoin Core #30509.  Fabian, you're still on.  I don't know if you're familiar
with this PR, or familiarized yourself with it in the meantime.  Do you have a
summary for the audience, or do you want me to take it?

**Fabian Jahr**: Sure, I took a brief look.  I didn't review it in detail, but I
think it allows the bitcoin-node executable to be controlled via a socket with
the -ipcbind option.  And most interesting, I think, is the wider context of why
that is being added right now, and that is the Stratum v2 work that Sjors is
doing.  I haven't checked out the latest state of the conversation there in the
last couple of days, but my understanding is that the plan is now to have a
mining service that basically does all the Stratum v2 stuff, and that then talks
to the bitcoin-node executable via this socket.  There was some discussion about
how to do this previously, and there were I think ideas of adding more of the
Stratum v2 stuff into the bitcoin-node, and so this is going with a more modular
approach, and this is basically taking parts out of the multiprocess project
from Bitcoin Core, which has been going on for quite a long time but has kind of
been stuck.

Also, because I think while it's a very good idea and I think everyone agrees
that it would be a good idea to do, there were less kind of concrete use cases
for realizing this multiprocess approach and splitting up the project.  And so
now, with the Stratum v2 context, with its new mining service being introduced,
that is very good to see that this also helps parts of the multiprocess project
move forward.

**Mark Erhardt**: So, I for one, when I read this news item, was not fully in
the picture, so I had to look up a few of the terms, and I thought I'd share my
research.  So, IPC in this context stands for Inter-Process Communication.  And
the idea here is that the multiprocess project will split the Bitcoin Core
binary into multiple binaries, and there will be three.  One is bitcoin-node,
which is the part of Bitcoin Core that is interacting with the network and doing
the P2P and the blockchain processing.  So, it's sort of a drop-in replacement
for bitcoind.  The second one is bitcoin-gui, which is a drop-in replacement for
bitcoin-qt.  And now I'm blanking on the third.

**Mike Schmidt**: Wallet.

**Mark Erhardt**: Oh yeah, right, wallet, of course.  So, if you run a Bitcoin
wallet, it would be a separate binary instead of a part of the Bitcoin Core
binary.  And so, the IPC here, as Fabian explained, is about communicating
between these binaries so that, for example, the wallet can make calls to the
bitcoin-node, or in this case the Stratum v2 stuff, like a little node service
could communication with the bitcoin-node.  That is roughly what I took away
from it.  Anything to add, Fabian?

**Fabian Jahr**: Yeah, I mean that's basically what I referred to previously,
like this split of the bitcoind into three different binaries.  This was the
original idea of the multiprocess project, basically like the minimum thing that
Russ wanted to do with it.  And that's what I meant, like while everyone agreed
it was a good idea, there was just not a concrete need for it to be done.  And
so with the restricted resources that we have, it was just moving slow to not at
all over the last couple of years.  And so now, if there is a potential for
introducing a fourth binary, which would be then the Stratum v2 mining service,
then this becomes more interesting because it allows basically to do the Stratum
v2 mining service with this approach, over kind of putting the Stratum v2 code
into a bitcoin-node or so, which I think a couple of people were not so happy
about that approach.

**Mike Schmidt**: I mean, we can already interact with our bitcoin-node, right,
via RPC.  So, what are the advantages of IPC?

**Fabian Jahr**: I'm not that deeply into it to give you the exact details.
There was some conversation about doing it over RPC, but yeah, there was a
pretty long conversation and I wasn't fully into it.  I mean, the RPC is less
robust, less fast than IPC, but for the details I think somebody else will need
to speak about it.  But this was an idea that was discussed in the original
Stratum v2 PR.  So, if you want to revisit that, please look into that PR and
see the approach discussions there.

**Mike Schmidt**: Yeah, that was my assumption as well.  Probably something
performance-related, especially if we're talking about Stratum and mining
performance.  Maybe not throwing out calls occasionally to the RPC is the best
way to do it, but yeah, that's just speculation, I guess.  Murch, anything else?
Oh, sorry, go ahead.

**Mark Erhardt**: Yeah, I wanted to add on, my impression was the same as
Fabian.  IPC in this case is more of an integrated communication between the two
processes that work tightly together, where the RPC is more used to do the
external calls to the bitcoin-node, treating it as a black box as a whole.  So,
I think, yeah, IPC is faster and it's sort of a privileged communication
channel, whereas RPC is authenticated at that level.  So, it's also viable as an
external communication channel.

**Mike Schmidt**: Really exciting.  I'll echo some of the sentiment from Fabian
to see some traction on the process separation project, aka multiprocess
project.  So, it's great to see.

**Mark Erhardt**: Yeah, also it's been going on for seven years, so it's nice to
see it come to -- it looks close to being there to actually get it fully
implemented and separating the binaries.

_Bitcoin Core #29605_

**Mike Schmidt**: Bitcoin Core #29605.  I have some notes here, Murch and
Fabian, unless somebody's familiar with this PR.

**Mark Erhardt**: I think I've looked a little bit at it.  So, the point here is
if you have a seed node configured, and in your configuration it's sort of a
point of contact that you can reach out to, to get your first addresses of other
Bitcoin peers to connect to.  And it used to be that while it was configured, it
would always make this call out.  So, this would give the seed node a lot of
power to influence what your address manager content looked like, and it also
sort of revealed unnecessary amounts of information to the seed node, because
once you had connected to the network a few times, you would have your own
address manager content, and you wouldn't actually need to do this.  So, you
sort of leaked information gratuitously to the seed node.

The change here is, even if you have the seed node configured, it is treated
only as a fallback.  While you have your own nodes that you want to connect to
already, you first use your own address manager content, and you only fall back
to the seed node if you do not have other contents.  If you don't know about
nodes or you can't reach any of them anymore, then you will reach out to the
seed node to get some.  And this just makes us more robust against seed node
providers.

**Mike Schmidt**: Yeah, we had a similar-ish PR previously.  It was Bitcoin Core
#28016.  And in that case, it was the deprioritization of DNS seeds compared to
seed nodes, because the speed of DNS seeds is much quicker.  It deprioritized
the DNS seeds over seed nodes.  Now we have seed nodes versus what we may have
in our local address manager, and the prioritization getting bumped on what
we've acquired in our local address manager over the seed nodes.  So,
interesting prioritization of finding peers PRs going on here.  Anything else we
should cover, Murch?  I think that's it for this week.

**Mark Erhardt**: Yeah, I think we're through.

**Mike Schmidt**: Well, thanks to all our special guests.  We had Greg on, thank
you Fabian, thank you Gloria, thank you Shehzan, thank you Bruno, and as always,
thank you to my co-host, Murch, and for you all for listening.  We'll see you
next week, except Murch!

**Mark Erhardt**: Hey!  Yeah, I won't be here next time.

**Mike Schmidt**: We'll see if we have a mystery co-host next week, so stay
tuned.  Cheers!

{% include references.md %}
