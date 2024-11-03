---
title: 'Bitcoin Optech Newsletter #311 Recap Podcast'
permalink: /en/podcast/2024/07/16/
reference: /en/newsletters/2024/07/12/
name: 2024-07-16-recap
slug: 2024-07-16-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Vojtěch Strnad and Fabian Jahr to discuss [Newsletter #311]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-6-16/383297039-44100-2-65b3bb610e885.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #311 Recap on
Twitter Spaces.  Today, we're going to talk about the interesting B10C
transaction with its creator, and we're also going to review the open PR for
Testnet4 with its author.  And we have two, just two releases and two notable
code changes this week.  I'm Mike Schmidt, contributor at Optech and Executive
Director at Brink, funding open-source Bitcoin developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin stuff.

**Mike Schmidt**: Vojtěch?

**Vojtěch Strnad**: Hi, I'm Vojtěch and I spend a lot of time tinkering with
Bitcoin and answering questions on Bitcoin Stack Exchange.

**Mike Schmidt**: Fabian?

**Fabian Jahr**: Hey, I'm Fabian, I'm an open-source Bitcoin developer and I'm
supported by Brink and HRF.

_News_

**Mike Schmidt**: Thank you both for joining us this week.  We actually didn't
note any news items this week, but we did include a note about a recently
confirmed Bitcoin transaction.  Vojtěch, you posted to Stacker News an item
titled, "Definitive explanation of my weird Bitcoin transaction".  Maybe for
folks that don't know the details, what is this transaction and the interesting
inputs and outputs in it, and then maybe we can even touch on why you did such a
thing?

**Vojtěch Strnad**: Yes.  So as a summary, it's a transaction with every kind of
standard input and output, and also one not yet defined segwit output, which
uses the script taken from the ephemeral anchors proposal, and it includes a lot
of Easter eggs.  For example, it uses every possible sighash (signature hash)
flag, it has a custom transaction ID.  There's a really long list of Easter
eggs, we can go over them later.

**Mike Schmidt**: Yeah, so everything's outlined on this Stacker News post.  And
I think, do I recall correctly, Vojtěch, that this took you about a year to put
together, that you actually learned Rust for optimizing part of the way that you
created this; is that right?

**Vojtěch Strnad**: Yeah.  I started working on it about a year ago.  It was
when I was creating a spreadsheet to compare different blockchain explorers.
And so, I needed a transaction with every kind of input and output because, for
example, some explorers aren't decoding OP_RETURN outputs.  At the time, some of
them even didn't decode taproot addresses, even though it was more than a year
after taproot activation.  So, I had this idea to have one single transaction
that I could reference, a kind of benchmark.  And so, I started creating it.
And when you have such a transaction, you have a lot of free variables.  You
need to choose the input and output amounts, you have the sequence numbers, the
locktime field, you need to choose what scripts you're using for the script
inputs.  And so, it took me a long time to figure out how to make it as
interesting as possible.

**Mark Erhardt**: I also thought that would be really useful for testing all
sorts of Bitcoin implementations and block explorers.  I wrote a blogpost myself
about deviations in the size of transactions a long time ago.  So, I'm
wondering, what sort of discrepancies did you find about different block
explorers by looking your transaction up there?

**Vojtěch Strnad**: Yeah, as I said, well for example, the transaction
uncovered, I think, three bugs in mempool.space.  I fixed one of them, two of
the others were fixed already.  And also, mempool.space added the transaction as
a test case in their automated tests, so that's pretty cool.  But the other
discrepancies of Bitcoin explorers, I already knew, as I said, for example, some
of them aren't showing the OP_RETURN data, they just show null as the address
and it doesn't say anything useful.

**Mike Schmidt**: Vojtěch, you mentioned needing to choose a bunch of variables
for certain amounts of outputs and things like that, and you've chosen
historically significant to Bitcoin numbers for a lot of those, perhaps all of
those.  Do you want to point out a few of your favorites?

**Vojtěch Strnad**: Well, for example, the locktime field, for that I used the
timestamp of the Genesis block, which is January 3rd, 2009.  I also included
this date as one of the sequence numbers.  The other sequence number is the
publication of the whitepaper.  Then there's also Satoshi's birthday, at least
the birthday that he had on his profile.  And then there are also some CVE
numbers, the vulnerabilities discovered in Bitcoin, the most notable ones
anyway, for example the inflation bug in 2010 that created 184 billion bitcoin,
if I remember correctly.  So, that's also referenced.  And also referenced are
the PR numbers in Bitcoin Core that implemented segwit and taproot respectively.

**Mark Erhardt**: I was wondering, with so many of the numbers preselected,
where was still the free picked numbers that you used in order to grind the
txid?

**Vojtěch Strnad**: So, the txid was grinded with the signature in the first
input, because if you notice the signatures, most of them are shorter than
usual.  There's lengths of 71, 70, 69, all the way down to 64.  And so, the
first input was the only one that doesn't have an unusually short signature.
And so, that was probably the only grinding vector I could find to customize the
txid.

**Mark Erhardt**: Very cool!

**Mike Schmidt**: You also did some grinding on the signatures to get the
various lengths of those encoded signatures of 71, 70, 69, 68, 67.  How much
compute power went into, I guess, the various components of that, as well as the
broader txid grinding?

**Vojtěch Strnad**: So, the signatures were actually easy.  For the shortest
ones, I used a pre-computed r value so that I only had to compute a few bytes of
the s value.  And yeah, the signatures in total took just a few hours.  The txid
was the most intensive part and the one that I actually had to rewrite in Rust,
and it still took over a month on my PC.

**Mike Schmidt**: Vojtěch, you should have a class on creating this transaction
from scratch.  Everybody has to go through and learn about all these nuances to
the protocol.  I think that would be very educational for people.

**Vojtěch Strnad**: The source code for the transaction, the tool that created
the transaction, is published on my GitHub, and also the link is in the comments
of the Stacker News post, if anyone is interested.

**Mark Erhardt**: It seems to me that a lot of people were surprised that you
could just send to an unencumbered segwit output.  I really enjoyed that you
highlighted that future segwit versions are standard to send to, and that's a
deliberate design decision in BIP350.  Everything else is actually stuff that's
being used already.  Why the ephemeral anchor one?

**Vojtěch Strnad**: Well, yeah, as you said, it was creating a future segwit
output.  I actually used a different script.  It was, I think, version 16
segwit, also a 2-byte, which already has some funds on mainnet, for whatever
reason, so I thought I could send some more.  But then Greg Sanders came up with
the ephemeral anchors proposal and I saw this really neat script, the bc1p fees
one, and I thought it would be better to use this one.

**Mark Erhardt**: I saw that you did a little bit of magic with the merkle tree
of the scriptpath, P2TR spend.  Do you want to dive a little bit into how you
could embed all these other transaction references?

**Vojtěch Strnad**: Yeah, so this is actually, I don't know if anyone's ever
done this before, but if you don't care about having other scripts in the merkle
tree and also you don't care about having a keypath, but I think you could also
have one if you didn't use an unspendable key, in taproot you need to provide
the hashing partners, as they are called, or the merkle branch steps.  And I
found out that you can just customize these if you don't care about having any
other scripts in the tree.  So, each of these is 32 bytes, and I selected 21
historic transactions to be put in this merkle tree.

**Mike Schmidt**: Very cool.  Vojtěch, anything else that you think the audience
would find interesting or educational about what you've done here?

**Vojtěch Strnad**: Well, for example, as I mentioned, some of the signatures
required a custom pre-computed r value.  Some of them were the 64-, 65-, and
67-byte signatures, but also there are three signatures that are 59, 58, and 57
bytes.  And these use a special r value that's actually the half of the secp
curve generator.  This was, I think, discovered by Greg Maxwell, that if you
take the half of the generator, it actually has a very small x value, and this
can be used to create very small signatures.  But also obviously, the nonce of
these signatures is known, so you could compute the private key from these.  So,
I only use these in a multisig, so it's still secured by at least one key.  So,
that's a very interesting elliptic curve fact that many people, I think, don't
know.

**Mark Erhardt**: I wanted to give a shoutout to one thing you mentioned only in
the writeup.  Please be sure to not use Bitcoin Core or Electrum downloaded over
hotel Wi-Fi.  Do you want to provide the background on that one?

**Vojtěch Strnad**: Yeah, so there's a known scammer that's currently being
referred to the Crown Prosecution Service in the UK.  And he, let's say,
bamboozled another Bitcoin developer into believing he could sign with the
Genesis block key, I think.  And one way that might have been done is
downloading an illegitimate copy of Electrum over hotel Wi-Fi.  We don't
actually know how it happened, but we can be pretty confident that there was no
actual proper signature happening.

**Mark Erhardt**: Yeah, especially since I think Electrum later confirmed that
there was no download from London that day.

**Vojtěch Strnad**: Good point, yeah.

**Mark Erhardt**: All right.  I think, yeah, if people are building a new block
explorer or work on a library that parses Bitcoin transactions, this one is an
interesting one to feed into the test vectors, because if your software has a
hiccup here, you can find a fully-fledged explanation on what all should be
happening and what all should be discoverable here.  So, I guess if nothing
else, there is now an embedded test vector in the main Bitcoin blockchain that
everybody will have to be able to parse.  So, that's pretty cool.

**Vojtěch Strnad**: One thing to note is that this transaction is completely
standard and there are other weird things in the Bitcoin protocol that you can
only uncover with a non-standard transaction.  For example, B10C is listening
here.  He made a transaction before taproot activation, and because it's before
taproot, it doesn't need to have any signatures on the taproot inputs.  But this
caused a bug in mempool.space because it assumed that every taproot input would
have signatures or a witness, and it doesn't.  So, there are other transactions
that you should look into and add as test cases.

**Mike Schmidt**: So, maybe we'll have you on next year when you create that,
huh?

**Mark Erhardt**: I think that would be very scary if we're technically able to
create another taproot transaction without a signature.

**Mike Schmidt**: Well, I mean, a non-standard version of what he's done here.

**Mark Erhardt**: All right.  Thank you very much.  This was really entertaining
and educational.

**Vojtěch Strnad**: Thank you for having me.

**Mike Schmidt**: Yeah, you're welcome to stay on.  Otherwise, if you have other
things to do, you're free to drop.  Thanks for joining us, Vojtěch.

_Testnet4 including PoW difficulty adjustment fix_

Next segment from the newsletter is our monthly segment on Bitcoin Core PR
Review Club.  This month we covered Fabian's PR titled, "Testnet4 including PoW
difficulty adjustment fix".  And this is a PR to Bitcoin Core to implement
testnet4 as a new test network to replace the old testnet3.  For some backstory
here, in Podcast #297 we had on Jameson Lopp, who discussed his mailing list
post about a bunch of problems that he documented with testnet3, which is the
current test network that is widely deployed and used for the last 13 years.
Fabian, we then had you on in Podcast #306, where we covered your draft BIP for
testnet4, which is currently still in open PR to the BIPS repository, I believe.
And for this week's PR Review Club, it's Bitcoin Core PR #29775, which is the
implementation we referenced in Newsletter #306.

Maybe to kick off the discussion, Fabian, what are we trying to achieve here?
And maybe then what's the latest on the BIP and implementation?

**Fabian Jahr**: Yeah, thanks for having me.  So actually, the PR came first
before the BIP, so that's I guess the more OG part.  The BIP was just written
later because some people wanted to have some more formal description of what
was actually going on.  The PR initially was just basically an exploration of
myself to see what a fix to some of the issues could look like.  So, going back
to what Jameson already probably discussed when he was present and what was
really the main topic of his mailing list post, was that we should have a reset
of what's currently testnet3.  Primary reasons are, there is a bug which lets us
exploit the 20-minute exception rule that leads to what is called block storms,
which means that a lot of blocks can come around with minimum difficulty, which
is not great, which makes it very hard to follow the chain at all and use it in
general.  And also, it has been seen for quite a while that testnet coins were
being sold for actual money, because almost all of the block subsidy has been
mined already because we're nearing, I think, block 3 million or something.

Yeah, so generally quite hard to use testnet3 and it has been around for 13
years, which is quite impressive, but also part of Bitcoin is slaying your
heroes.  So, yeah, we have to slay testnet3 in order to make a place for a
better version that should at least prevent block storms from happening, and
also this should also mean that there's less trading going on, or hopefully no
trading going on, because we make it more clear that this testnet, whatever the
current testnet is, can be reset at any time.

**Mike Schmidt**: Okay, great.  Maybe it sounds like the block-storm
vulnerability, or bug, I guess you could say, was one of the main motivations
for Jameson's post.  You touched on it, but will you break that one down just
maybe slightly more for the audience?

**Fabian Jahr**: Sure.  So, in testnet3, there is one rule that is an exception
that is different from mainnet, and that means that you can mine a block with
minimum difficulty if the time of 20 minutes has elapsed since the last block.
But since we're using timestamps on the blockchain that you can fake, you can
say, "Okay, we're actually 20 minutes in the future," when we're actually not,
and that means you can mine such a minimal difficulty block, even with a CPU, at
any time.  So, this exception was okay and we keep this rule in, but then there
was a problem arising from that because when we do the difficulty readjustment
at the end of every period, we look at the previous block and decide, "Okay, how
much do we want to adjust?  Do we adjust up or do we adjust down?"  And the
problem then is, if the last block in the previous period was actually one of
the blocks that were mined with this one exception rule, that means that had
difficulty 1, then we would adjust based on difficulty 1.

That means that for the whole next period, we would have difficulty 1, which
would mean very, very easy-to-mine blocks throughout the whole period, and then
also, of course, gradually the difficulty has to increase.  It can increase only
fourfold maximally, and so we would have very fast blocks for quite a while.
And yeah, that is what's called a block storm because the blocks are coming in
so fast that it's very hard to keep up, even if you have a quite good computer
and quite good connection.

**Mark Erhardt**: Yeah, the interesting thing is, usually if you accidentally
mine the last block in a difficulty period and reset it to one, you cause one
difficulty period of difficulty 1, and then presumably if there's some hashrate
on the network, one difficulty period of difficulty 4, one of difficulty 16, one
of difficulty 64, and so forth.  But if you mine the blocks at the accurate
time, you can trivially put the timestamp on the last block in the same
difficulty period 20 minutes into the future, and therefore reset the difficulty
and each difficulty period back to one.  That way, you can basically have block
storms indefinitely, which was demonstrated by Jameson Lopp when he, I think,
mined for a week or two straight to, I don't even remember how many, but like a
million blocks or something.  Yeah, anyway, you can artificially keep down the
difficulty perpetually with this vulnerability or with this feature of testnet3.

**Mike Schmidt**: We touched on block storms, which was one of the questions
that was highlighted in the PR Review Club writeup for this week.  Another one,
Fabian, I think could be interesting, and we can take this any direction you
want as well, was maybe touch on the time warp fix that's in the PR.

**Fabian Jahr**: Yeah, so the time warp attack, I'm not very good at explaining
it I think just in words, maybe Murch can jump in.  But the time warp attack can
help make the block storm issue worse and also it can be much easier exploited
using the 20-minute exception rule even when we don't have block storms.  So
that's why additionally, a fix to the time warp attack was added to the PR as
well on suggestion, and this is basically the exact same fix that we have in the
great consensus cleanup.  Sorry, I'm blanking on how many minutes it is.

**Mark Erhardt**: I think two hours, right?  The first block of the new
difficulty period cannot be more than 120 minutes in the past of the last block
of the previous difficulty period.  I'll verify the 120 minutes!

**Mike Schmidt**: Fabian, we have a question from the audience.  Larry asks,
"Why create testnet4 since we now have signet?  Why not just use signet?"

**Fabian Jahr**: Yeah, I mean that's a valid question.  And in general I would
say, unless you need testnet, then it's great to use signet.  And signet has a
constant block delivery rate, and that makes it quite comfortable.  And I think
for most application layer Bitcoin projects, it's probably the better choice
even.  Of course, one reason that you might want to use testnet is that you want
to do mining, like you do anything with mining, you have a miner, you do
anything miner-related.  I think for that, having the testnet is great.  I think
testnet is also great as an addition to signet if you want to test anything with
a not-constant block rate, and potentially also reorgs.  It has been planned for
a very long time that we would have reorgs on signet basically being done for
us, produced for us by the signers of signet.  But as far as I know, this still
hasn't happened, because just nobody has implemented it.  So, I think if you
want to just randomly see some reorgs on your application, then I think having
testnet in addition to signet is also great.

Then, as far as I know, it's also not so easy to get a non-standard transaction
into signet.  Maybe you can send a non-standard transaction to any of the
signers and they will include it in a block for you, but they shouldn't
propagate over the network.  And so on testnet, you can exploit the 20-minute
exception rule to mine your own block with your non-standard transaction
included.  So, that's kind of more of a hacky feature of testnet, but yeah,
that's also one of the things that people like about testnet.

**Mark Erhardt**: Sorry, I was looking at the great consensus cleanup discussion
in Delving, so you might have said it, but one thing that you can't do on signet
generally is test mining setups.  So, I've heard that some of the mining tools,
when they work on their setups, they'll turn it on to testnet for a bit to try
and see that everything is configured right before using it with their entire
hashrate.  And that, of course, doesn't work on signet because blocks are signed
into existence.  Maybe just as a short callback, the issue with the time warp
attack is that the difficulty periods should really be overlapping in Bitcoin,
so the end of the previous should match up with the start of the new.  However,
there is an off-by-one error so that the start of the new difficulty period is
the first block of the difficulty period, while the end of the difficulty period
is the last block of the difficulty period, which means that there is a gap of
one block, and that means that you can shift the start time of the next
difficulty period in relation to the end time of the previous difficulty period.

With the fairly lenient rules for timestamps of blocks, this allows you to keep
all of the timestamps caught in the past by giving each block just a timestamp
that increases by one second, then to use the actual time for the last block in
a difficulty period.  And that means that over time, the start time of the
difficulty periods and the end time of the difficulty periods will diverge
further and further, which then at some point leads to the difficulty dropping
to one-quarter of the previous difficulty in every single difficulty period.
So, this is an exponential attack, where after only something like four weeks,
you can reduce the difficulty of a network to one by just exploiting this time
warp with a majority of the hashrate.

The fix with keeping the timestamp of the last block within some range of the
first block's time is a soft fork and very easy to implement.  So, that
basically prevents that you predate the first block in new difficulty periods,
because it can't be set more than two hours in advance of the last block's time.
So, usually they can shift a little, and it's possible for blocks to have
timestamps out of order, but by limiting how much the first block can be set
into the past, the time warp is effectively defanged.

Okay, back to wherever we were.

**Mike Schmidt**: Thanks, Murch.  Fabian, what outstanding work is there to be
done for testnet4, like, when testnet4?

**Fabian Jahr**: Yeah, I mean generally, I think on the BIP and the PR itself,
there's not that much outstanding right now, I think.  And I know there's still
some review work being done by some people that have not published it.  So,
maybe there's some further churn coming in.  And the one feature, I would say,
that is still requested of the new testnet, is embedding some interesting data,
and this is also a nice callback to the first topic with an interesting
transaction from Vojtěch, is that initially in testnet3 within the first 574
blocks or so, there were some interesting transactions embedded.  And so, the
request was that we would do this again in testnet4.  And so, yeah, I mean that
is something that I think generally is a good idea for this exact same reason as
we have already discussed previously on the interesting transaction, that having
weird transactions in the chain that forces every software that uses the testnet
chain to be able to handle these, that can be great test vectors for all of the
software.  And so, that's why I think that's a good request.

The only question is, or the only issue is, it's kind of a bottomless pit.
There are all kinds of great ideas of what to put into that, and it's not so
easy to implement that.  We already spoke about this a little bit the last time
I was on, and so I kind of brought this up as a question to people, of what they
would think of how to approach this.  And I've gotten a little bit further
there.  So, I've started the project.  It's not really doing much yet, but I'm
trying to base it off of the Bitcoin Core function test framework.  So, it's
kind of a similar approach that, for example, the Optech taproot workshop also
chose to leverage that infrastructure, and basically, yeah, then built all of
these interesting transactions on top of that using code in Python.  I think the
nice thing about this is that there's quite a lot of people that have at least
done some work on the functional test framework in Core, so there's a larger
body of people that are potentially contributors, just dropping in and
implementing one interesting test case, and then they can leave.  There's some
infrastructure there already, like documentation there, for people to get on
boarded on this kind of infrastructure.

Yeah, so that's what I'm trying to base it off of.  So, I will embed the first
500 blocks from testnet3 straight over, and then there are quite a lot of ideas
of where to get interesting transactions from.  They are in the repo in the
README also mentioned, so I mean we can probably put it in the notes of the
podcast.  But it's on my GitHub, it's test_chain_init.  It's a very creative
name that I came up with.  And there in the readme, there are quite a lot of
ideas that people have already named.  And so, if anyone is interested in
contributing, then please feel free to do this.  Just to name a few: the fuzzing
seed corpus is an interesting source of transactions; the taproot functional
tests is very interesting; we have vectors, static vectors also in the test with
interesting scripts.  So, yeah, if you're interested in this kind of stuff, feel
free to check out the repo or just approach me and I will be working on this
myself as well.

**Mike Schmidt**: Vojtěch?

**Vojtěch Strnad**: Yeah, I have a question regarding the interesting
transactions at the start of the chain.  As I understand it, in testnet4, many
of the soft forks will be active since block 1, unlike on testnet3.  Are there
any collisions with transactions that were previously valid at the start of
testnet3, but aren't valid anymore?

**Fabian Jahr**: I don't know yet, I haven't gotten that far!  I actually just
basically dumped all of the blocks and all of the transactions so I don't have
to have the full chain on my disk anymore, but I haven't really inspected it
much.  The only fact that I can say already that kind of surprised me a bit is
that it's not like that these 500 blocks are completely full.  Just every couple
of blocks, there's like one, two or three transactions, so it's not a huge body
of transactions that is in there.  But yeah, whatever is doable, I will take and
port over.  So, yeah, it's something like 500 to 1,000 transactions, so I'm not
sure if we will get too much weirdness out of that, but I will report back.  I
will definitely publish something on this once we have at least a little bit of
this tool working, and report back what issues I ran into.

**Mark Erhardt**: I just wanted to jump back to, when testnet4?  So, my
understanding is that if this gets merged, and it seems the PR seems to be
fairly close, it would be shipped with the next release of Bitcoin Core.  Would
testnet4 then be already the standard testnet that the new Bitcoin Core release
defaults to, or is it intended to be optional at that point?

**Fabian Jahr**: No, it's not the standard.  So, I mean, we're always a bit
watching out for people that are not so quick with updating the software.  So,
we will launch with, or at least that's the plan on the PR right now, is that
there's an additional parameter that you can start the node with, which is
testnet4.  So, you can start with testnet4 equal to 1, and then you will use the
testnet4 chain.  But if you continue to start with testnet equal 1, then you
will just have testnet3 still included, and you will still run it.  And that's
going to work at least throughout the next version of Bitcoin Core as well.  And
so then the question is, do we want to switch over to default of this testnet
equal 1 and completely drop the testnet4 start param, or if we want to drop the
general default and just make everything just testnet4?

I think maybe we still have some conversation in the future, because a lot of
people are fans of the idea now of resetting testnet more often, maybe even
yearly or every two years or so, or at least every halving.  So then, it would
make sense to just always have the version in there, because that's also a clear
mock indicator what we are on and that this will be implemented in the future.
Yeah  but the status right now is that Dash testnet will still be testnet3 after
the next version, even though this PR request is merged in its current form.

**Mike Schmidt**: Fabian, thanks for joining us.

**Fabian Jahr**: Thank you.

**Mike Schmidt**: You're welcome to hang on, otherwise if you've got other
things, you can drop.  We've just got a few items left in the newsletter.
Releases and release candidates.

_Bitcoin Core 26.2_

Bitcoin Core 26.2 is officially released.  So, if you're running any of the
Bitcoin Core 26x versions, you'll want to get any improvements or bug fixes in
this maintenance release.  Murch, anything notable there?  All right.

_LND v0.18.2-beta_

Second release is to LND, LND v0.18.2-beta.  In Podcast #309, we covered LND
v0.18.1, which was a bug fix release that addressed an issue with matching error
text strings between certain versions of btcd.  So, essentially there was some
looking at the error text message for the user and then doing some conditional
space on that, and between the different btcd backends that LND could be using,
those error messages differed and caused an issue in that v0.18.1 from a few
weeks ago.

This v0.18.2 release addresses a similar text-matching bug, also involving a
mismatch of error strings, both of which contain similar starting text between
different versions of btcd.  Murch, assuming that I'm getting this right, it
seems like error message string matching isn't maybe a great way to determine
the status of an RPC call or in communication with some client and server?  I
mean, isn't a best practice using error codes or something else?

**Mark Erhardt**: Yeah, I would generally agree it's probably also something
that can be fuzzed pretty efficiently.  It's just also probably something that
is difficult to do, because as far as I understand, the active development of
btcd has slowed down a lot, and it's mainly being developed now due to utreexo
and LND as a source client.  So, I guess breaking downstream compatibility by
changing errors or error codes is something that should be anticipated, but it's
also easy to overlook that something else depends on an exact phrasing.

**Mike Schmidt**: Notable code and documentation changes.  If anybody has a
question for Vojtěch, Fabian, myself, or Murch, let us know.  We'll try to get
to your question after we wrap up these notable code changes.

_Rust Bitcoin #2949_

Rust Bitcoin #2949 adds a method in Rust Bitcoin for checking the standardness
of an OP_RETURN length.  Previously, Rust Bitcoin just had a single method,
is_op_return, and that method evaluated whether an output was a consensus rule
valid OP_RETURN output.  And now, Rust Bitcoin has added a second method,
is_standard_op_return(), and that method evaluates whether an OP_RETURN adheres
to Bitcoin Core's standardness policy for OP_RETURNs.  So now, there's two
methods in Rust Bitcoin, one is Bitcoin Core's standardness rule, one is
consensus rule evaluation.  So, Bitcoin Core standardness rule for OP_RETURNS
is, I believe, an 80-byte maximum size.  You can contrast that 80-byte size
limit to the consensus limit on OP_RETURNs, which I believe has no formal limit,
which means it's limited by the maximum size of a Bitcoin transaction.  Do I
have that right, Murch?

**Mark Erhardt**: I think it's limited by the script size limit, yeah.

**Mike Schmidt**: Okay, gotcha.  Okay, so if you're doing OP_RETURN stuff in
Rust Bitcoin, check out that new method.

_BDK #1487_

Last PR this week, BDK #1487, is a PR titled, "Add support for custom sorting
and deprecate BIP69".  The sorting reference pertains to both the order of the
inputs as well as the order of the outputs of a transaction.  Before this, BDK
PR transaction outputs and inputs could be sorted using this lexicographical
approach outlined in BIP69, that was one strategy you could use; and there was a
shuffle strategy; and then finally, an untouched strategy.  The default option
was, and is, I think it still is, shuffle, which is randomized input and output
orders.  And then with this PR, in addition to those strategies I mentioned,
there's now hooks for a developer to provide their own and potentially different
input and output sort functions.  And the BIP69 ordering option strategy is
deprecated.  Much, I wanted to tap you in on BIP 69, and is BIP69 a good idea or
a bad idea?

**Mark Erhardt**: Yeah, so BIP69 is a 2015 proposal that involved the suggestion
of having a fixed recommended order for all inputs and all the outputs.  And the
idea was that if everybody builds transactions in exactly this way, it would
remove some fingerprints.  For example, there is a big hardware wallet that
orders all of their inputs by age, so confirmation count, which basically
reveals which software and hardware wallet created the transaction.  So, there
is a bunch of fingerprints in that sort of behavior, and the hope would be that
transactions are not easily assigned to specific software that created it, so we
would generally like every wallet implementer to reduce these easily
recognizable fingerprints.

It turns out that BIP69 did not get full adoption by every single wallet
implementation.  And in fact, it cannot be adopted in some cases.  So, for
example, if you are using specific orders on inputs and outputs in order to have
matching SIGHASH_SINGLE, or some other constructions with multiple parties that
require the inputs to be in a specific order, you simply cannot follow the
recommendation of BIP69.

So, in my opinion, BIP69 itself has become a fingerprint, because there's only a
few wallets that implement it.  And by having this very recognizable ordering,
you sort of reveal that your transaction was created, or likely created, by one
of the softwares that uses it, especially if you have a high number of inputs
and outputs.  If you have a single input and output, obviously it always matches
the required order.  For small counts, like two or three, there's still a very
high likelihood that you just

randomly followed BIP69; but for high counts, it's obvious when it matches the
order that you must have been following this lexicographical ordering.

So, anyway, the recommendation is that instead you would always use random,
because even if then sometimes there is an order that seems unlikely, there's
always a likelihood that it randomly got shuffled that way.  Yeah, especially if
certain hardware wallet developers are listening in, I would love them to think
about how to create a randomly-ordered transaction instead of an age-sorted
transaction.  So, yeah, in my opinion, this proposal is a bit outdated, and I
wouldn't recommend that people still implement it.

**Mike Schmidt**: Thanks, Murch, for that commentary on BIP69.  I don't see any
requests for speaker access or questions, so I think we can wrap up.  Thanks to
our special guests, Vojtěch, as well as Fabian, and always my co-host, Murch,
and you all for listening.  Thanks, everyone.

**Mark Erhardt**: Thanks.  Hear you soon.

{% include references.md %}
