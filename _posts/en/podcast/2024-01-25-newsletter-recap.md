---
title: 'Bitcoin Optech Newsletter #286 Recap Podcast'
permalink: /en/podcast/2024/01/25/
reference: /en/newsletters/2024/01/24/
name: 2024-01-25-recap
slug: 2024-01-25-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Niklas Gögge, Bastien
Teinturier, Anthony Towns, Gloria Zhao, Nicholas Gregory, and Tom Trevethan to
discuss [Newsletter #286]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-0-26/2d938f91-2d3c-cd24-76ec-61a40e72c34c.MP3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #286 Recap on
Twitter Spaces.  Today, we're going to talk about a btcd consensus bug,
Lightning with v3 relay and ephemeral anchors, the BINANA repository, five
highlighted changes to software using Bitcoin, and we have our regular segments
on releases and notable code changes.  I'm Mike Schmidt, I'm a contributor at
Bitcoin Optech and Executive Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin stuff.
Gloria.

**Gloria Zhao**: Hi, I'm Gloria, I work on Bitcoin Core, sponsored by Brink.

**Mike Schmidt**: Nicholas Gregory?

**Nicholas Gregory**: Hi, I'm Nick Gregory, I work for a company called
CommerceBlock and we've been working on things like Mercury Layer.

**Mike Schmidt**: Tom?

**Tom Trevethan**: Yeah, I work with Nick as CTO.  Yeah, we've been working on
the Mercury Layer and Lightning things and Bitcoin infrastructure.

**Mike Schmidt**: AJ?

**Anthony Towns**: Hi, I'm AJ, I work with DCI on Bitcoin stuff, apparently
breaking lots of things these days.

**Mike Schmidt**: T-bast?

**Bastien Teinturier**: Hi, I'm Bastien and I'm working on Lightning, a lot of
Lightning stuff.

**Mike Schmidt**: And Niklas Gögge?

**Niklas Gögge**: Hi, I'm Niklas, I also work on Bitcoin Core at Brink.

_Disclosure of fixed consensus failure in btcd_

**Mike Schmidt**: Thanks everybody for joining.  I've posted some tweets in the
Space, so you can follow along at home.  Bringing up Newsletter #286, we'll go
in order here, starting with the News section.  First item is Disclosure of
fixed consensus failure in btcd.  Niklas, we had you on as a guest in Podcast
#283 to talk about two LND vulnerabilities that you disclosed, and this week
you've disclosed another one, this time to the btcd full node Bitcoin
implementation.  Btcd wasn't handling BIP68 and BIP112 correctly, resulting in
consensus failures.  Niklas, maybe you can break that down for us?

**Niklas Gögge**: Yeah, sure.  So, the BIPs in question here basically
introduced relative timelocks to Bitcoin transactions, and the rules are only
active for transactions with a version 2 or higher.  And the reason for that, I
think, is that we didn't want to invalidate any pre-signed transactions.  So,
yeah, any pre-signed transactions, like version 1, we didn't want to invalidate,
so we only go 2 or higher.  Now the version itself in Bitcoin Core, or I think
in all implementations basically, is stored as a signed 32-bit integer.  But in
regard to these BIPs, they're supposed to be treated as unsigned.  So, btcd did
not treat it as unsigned, so negative versions in btcd would be treated
differently by the consensus code when compared to Bitcoin Core, so you could
have a chain split if transactions with negative versions get confirmed.  Yeah,
that's basically the bug.

**Mike Schmidt**: And so how would you trigger it?  You would just send a
version number that's insanely negative, or…?

**Niklas Gögge**: Well, I'm actually surprised that no one has done it so far.
But yeah, you would basically create a transaction with a negative version that
-- well, I guess there are multiple ways to trigger it.  You can either trigger
it through BIP68 or BIP112.  I guess BIP112 is kind of easy.  You create a
transaction with a negative version and then you use OP_CHECKSEQUENCEVERIFY
(CSV) in the script, and then the transaction will be rejected.  So, any btcd
node will basically reject the block that contains this transaction, while
Bitcoin Core accepts the block.  Negative versions are non-standard, but I don't
know, I feel like we have seen quite a few non-standard things get confirmed
recently, so I feel like it should be not difficult to get something that's
confirmed.  But yeah, no one has done it so far.  Anyone running btcd, you
should update to the most recent version.

**Mike Schmidt**: And instead of exploiting the bug, you decided to responsibly
disclose it.  Maybe talk a little bit about the timing; when did you disclose
that, and when was the fix in?

**Niklas Gögge**: Yeah, so I disclosed it last year, what was it, June, July?
Or March?  And then I think a month later, the fix was merged.  But the release
was only made in December of last year, so about a month ago.  Yeah, that's the
timeline.

**Mike Schmidt**: And obviously you're doing work on Bitcoin Core, so maybe walk
through how did you find this bug?

**Niklas Gögge**: So, I will make a longer-form blogpost about how I found it,
but basically I was differentially fuzzing the Bitcoin Core script interpreter
against btcd's, which you basically create a bunch of inputs, you give it to the
Bitcoin Core script interpreter, and then you give the same inputs to btcd's
interpreter and you check the result, that they both evaluate to the same thing.
And if they don't, then you've found a bug.  And that's basically what I did and
found this discrepancy.

**Mike Schmidt**: Maybe a bit of a meta question, and then we can open it up to
anybody else who has comments on this.  What are your thoughts on multiple
Bitcoin node implementations?

**Niklas Gögge**: Well, I guess this is a loaded topic, but I personally think
it's probably not a great idea, because bugs like this are probably guaranteed
to happen.  I think this is a great example, because this is a very minor thing
to get wrong, but then horrible things can happen, and the Bitcoin consensus is
very complex.  And in my opinion, it's basically guaranteed that you have bugs
like this if you have multiple implementations.  And I mean, even if you only
have one implementation and you keep changing the code, it's the same risk, I
guess.  But the risk is much smaller, I think, if you have one implementation
that you keep changing versus you have two completely different ones, or
multiple ones that you keep changing.

So, yeah, I think the risk of stuff like this is just too high if we have
multiple implementations.  I really hope that we finish the kernel, which is
extracting the Bitcoin consensus engine, so other projects can use it, and then
people can build alternative full nodes on top of the kernel.  I think that's
the future that I would like to see, but I know people disagree.  I would
probably have stuff like btcd around.

**Mike Schmidt**: Murch, or any of our guests this week, do you have any
questions or comments for Niklas or this bug or multiple implementations?  Go
ahead, Murch.

**Mark Erhardt**: I think the problem is simply that the rule set that we check
against is very hard to explicitly enumerate.  There's a bunch of rules that we
know about, but there's also a few rules that basically stem from quirky
behavior or implementation details in Bitcoin Core.  And even if we had a very
comprehensive set of test vectors that other implementations can also implement,
if they use different languages, it might still just cause a different
evaluation on just how the languages differ, on how they treat integers, or this
and that.  So, yeah, as Niklas said, it's just really hard to make two
implementations bug-to-bug compatible, especially if you're implementing them in
different languages.

**Mike Schmidt**: Murch, is another way to say what you've said that it's hard,
if not possible, to write up a spec?

**Mark Erhardt**: I mean, there are writeups that try to comprehensively list
all consensus rules, but they're just not complete enough that you could
implement it from that.  I guess a good way to find whether or not they're
complete is to try and implement it from there and then fill out the spec in all
the ways.  So, you can't write a spec without trying to implement it and
thoroughly checking that you match bug for bug.  And, well yeah, I don't think
it's really easy to write a spec.

**Mike Schmidt**: AJ, you posted something in the Twitter thread here.  Do you
want to summarize that, since I didn't get a chance to click and look at it?

**Anthony Towns**: So, that's a PR from Matt a while ago to change from signed
to unsigned in Bitcoin Core.  I think we decided not to do that, but just to do
the conversion in the IPC stuff instead.  So, similar sort of issue, except for
not having the actual bug in the meantime.

**Mike Schmidt**: Niklas?

**Niklas Gögge**: Yeah, I think there's actually a very similar PR on btcd,
which I didn't know about this until a few days ago, and I'm kind of surprised
that no one found the bug when they were talking about that PR.  But, yeah.

**Mike Schmidt**: Niklas, do you want to give a quick maybe summary of the fuzz
testing conceptually?  You mentioned that that was used in this case to find and
surface this bug, so maybe just a quick summary of what that is and why that is
important to be doing.

**Niklas Gögge**: Yeah, so fuzz testing is essentially just a way to automate
testing of software by throwing -- it's not really random, but I guess you can
explain it in that way.  You just throw random inputs at a program and see what
happens basically.  And usually, you throw random stuff at the program, you see
what coverage that input achieves.  If it achieves new coverage, you store it in
your set of interesting inputs, and then you keep evolving that set of inputs by
constantly mutating them and throwing them at the program again.  And the goal
is basically to just achieve more and more coverage in your program.  And yeah,
this sort of testing results usually in finding all kinds of bugs.

Compared to unit tests, it's sometimes quite hard to know when a bug happens.
Like, you can throw random stuff at a program, but if it doesn't crash, how do
you know that something weird happened?  So, you kind of need some kind of
oracle to tell you if there is a bug or not, which is why, for example, if you
have two implementations of something, you can test them against each other and
then if they behave differently, you've probably found a bug.

**Mike Schmidt**: Murch, did you have a question or comment?

**Mark Erhardt**: Yeah, a comment.  I think it's important to say that it's not
random random.  So, when you try to write unit tests, you're usually going to
try to have at least one test that tries the sunny case, as in it behaves
exactly as you would like it to; you're testing the functionality works for
proper inputs and it gives you the proper outcome.  Then you have edge cases,
where it's like, is the smallest value treated correctly?  Is one smaller than
the smallest value treated correctly as an error?  Same on the upper bound?  And
you need to do that, of course, for every parameter that you take.

Now, Bitcoin Core has a lot of functions that are very complex and have maybe
10, 12 parameters, and just trying out the whole combination space of all the
inputs, all the possible inputs for this input and how they interact with all
possible inputs of all the other combinations of all the other parameters, is
really hard to cover with unit tests.  What fuzz testing gives us is that it
does random mutations, but since it only keeps the ones that are interesting and
that further our coverage, it drives itself towards trying to enumerate all the
possible combinations that express in new behavior.  And you can basically just,
if you've written up the fuzz harness well enough, you can just throw a
computing cluster at it and let it run for a week or two and generate millions
and billions of these attempts, and you'll feel fairly confident that you've
tried almost all combinations.  So, it's basically a way of really testing all
of the edge cases in the function.

**Mike Schmidt**: Niklas, thanks for joining us and walking us through that.
Thanks for your work on this fuzzing and responsibly disclosing these bugs, and
I think we can move on in the newsletter.

_Proposed changes to LN for v3 relay and ephemeral anchors_

Next news item is Proposed changes to LN for v3 relay and ephemeral anchors.
T-bast, you posted a writeup on Delving Bitcoin about the changes that you think
should be made in LN in order to use v3 transactions and ephemeral anchors.
Maybe you could take this in whatever direction you want; what are those
changes; what has the feedback been; and then we can jump into some of the
details?

**Bastien Teinturier**: Sure, thanks.  So, there are a lot of things we would
like to change in the LN Protocol, mostly both to simplify it and to make it
more resilient to potential complex mempool situations.  On the simplification
part, there's one thing that is really annoying with LN and really hard to
explain to users, is that we tell everyone that the goal of LN is to abstract
away the onchain fees to make sure that you have a channel, you don't have to
care about onchain fees anymore because you are offchain, you don't need to make
any more onchain transactions.  But that's actually not true, because we have to
prepare for the fact that we may have to broadcast a fast-closing transaction,
and the fees that we allocate, and we have to allocate some fees to a commitment
transaction, even when we use CPFP later to bump it, we have to allocate a
non-zero fee, and the issue is that this non-zero fee is funds that are inside
your channel, but that you cannot use offchain.  And even worse than that, since
the commitment transaction size changes all the time when you are sending
payments, adding Hash Time Locked Contracts (HTLCs) to a commitment transaction,
it gets bigger, so you need to allocate more of your offchain funds to fees.
So, it's really impossible for users to understand what their balance is in an
LN Channel.

So, one very simple way, very efficient way of abstracting all that away, is to
make that commitment transaction pay zero fees.  Then we are completely
separated from the onchain fees and everything just makes sense that the funds
you have offchain can be entirely used offchain.  So, that's one of the things
that ephemeral anchors can bring us, is that we can make the commitment
transaction pay zero fees and only pay fees through the ephemeral anchor.  And
that's really nice because we also have one subtle complexity in LN linked to
the fact that this commitment transaction has to pay fees, that we have a
message that lets people say, "Oh, I'd like to update the fee rate of a
commitment transaction", and that message creates a lot of edge cases when it
happens at the wrong time.  Since we have a protocol where a lot of things can
be happening concurrently, there are a lot of bugs in all implementations where
if that update-fee message arrives at the wrong timing, where for example during
a closing where there are pending HTLCs, implementations will not treat this the
same and you can have your channel deadlock.  All of these things just go away
because if a commitment transaction pays zero fees, then we can completely get
rid of that mechanism that was used to update the fees of the commitment
transaction.  So, that's a very nice simplification.

Another very nice simplification with ephemeral anchors is that we can remove
CSVs that we added to all outputs of the commit transaction.  The only goal of
those CSVs was to make sure that we could only CPFP through the anchor output,
and first we could use the carve-out rule to make sure that we had a way to
safely CPFP, even when our counterparty is malicious.  We can get rid of that
with ephemeral anchors because we basically get rid of most pinning vectors, so
we can simplify the commitment transaction.  It both simplifies it from a
Bitcoin Script point of view, and also it makes all those outputs available to
fee bump the commitment transaction, which is really nice as well because it
means that you need less outside UTXOs in your wallet as an LN node to guarantee
that you'll be able to get your funds back onchain in time and pay the correct
fee, depending on the mempool.  And it fixes a whole class of pinning attacks
and security issues that LN nodes currently potentially have.  So, it's really a
very important change that will be extremely useful to us.

What I wanted to show with that post is that the changes on the LN side are not
that hard.  Most of the hard work, all of the hard work basically, is at the
Bitcoin Core side.  As users of this, it is really simple to use, and it is
really simple to update our protocol to make good usage of this.  So, I wanted
to highlight that and have feedback from other implementers.  I didn't have a
lot of feedback yet from other implementers.  I think that all those changes are
mostly what everyone already had in mind for changes once we have package relay
and v3 transaction, but I need to confirm that with the other teams, and I hope
I'm able to get their attention in the coming weeks.

**Mike Schmidt**: Gloria, t-bast mentioned v3 relay obviously and some of the
work that's going on in the Bitcoin Core side of things and pinning.  I'm
wondering what your thoughts are on what t-bast posted and is saying here today.

**Gloria Zhao**: Yeah, it's really, really helpful and thank you so much,
t-bast.  Obviously, I'm not an LN-spec protocol person, and Greg also had
written up what that would look like, but it is definitely very helpful to have
the people who are going to be implementing any changes that might happen
actually talking about it and working through the kinks of what can happen.  And
we also had some discussion on that thread related to, is there a universe where
we can automatically enroll existing commitment transactions to the v3 policies,
let's say in the example where it takes them a really long time to work on these
changes, which is totally understandable?  So, we can talk about that if that is
of interest.  But yeah, all I wanted to say was that this is super-helpful and
really great, and thank you so much.

**Mike Schmidt**: You touched on this in your comment, Gloria, but maybe you can
talk a little bit more about the order of operations and the different
dependencies here between maybe things like cluster mempool, v3, ephemeral
anchors, existing anchors, and LN; maybe elaborate on that?

**Gloria Zhao**: Yeah, sure.  So, v3 kind of predates cluster mempool being a
proposed thing.  I think problems were relatively well understood at the time,
and it was kind of like, "Okay, we need a way to assess incentive compatibility,
we need a way to add these features to make replacements more
incentive-compatible and safe, as well as enable package RBF, and whatnot".  But
it is not feasible to do this in any computationally acceptable way today,
unless we were to completely rip out the mempool and create a cluster mempool,
right?  So I think at that time it was like, "Okay, what if we just have mini
cluster mempool, where we carve out a section of mempool policy, where we get
all these features for a certain type of topology that we can implement those
for?"  And unfortunately, it's very, very restrictive; it's one parent, one
child.  And in that case, you get essentially a cluster limit, using the
existing ancestor and descendant limits, by setting them to 2.

So it was like, you can opt into this -- I'm sorry, somebody said, "mini
cluster" earlier today and now it's stuck in my brain and I'm saying mini
cluster a lot!  But yeah, so now that we have cluster mempool on the roadmap,
that's kind of the long-term solution to all of our problems.  But the two
things -- I just saw a thumbs down from Greg!  Okay, so we have a piece of doing
cluster mempool, but we also still have things like, what about rule 3 pinning,
and what about the fact that that gets rid of carve out?  And so we need a way
to continue supporting this like, "Okay, I might have a shared transaction and I
need to be able to CPFP it, even if I have a counterparty that is trying to
monopolize the descendant limit".  That's I guess the most general way of saying
that.  So, v3 works as a way to transition; it's a solution.

Your question was, "What's a roadmap; how do all these fit together?"  So I
think it is, we get v3 in, we get package RBF -- we get to the point where it's
like red-carpet ready for LN to switch to, and it's safe and it's usable and it
gets features done, and then we can hopefully have them switch to it.  If that's
starting to take really long, then maybe we consider doing an automatic
template, pattern matching, automatic enrollment of existing commitment
transactions to v3, type thing.  And in that time, we can work on getting
cluster mempool merged without having to worry about breaking CPFP carve out for
people.  And then after those, we might be in this whole new world of amazing
mempool policy.  And so after that, maybe we can consider further improvements
to something like v3, or we can enable some of these features for all
transactions and not just v3 transactions.  But yeah, these all fit together so
that you get nice things soon, you get really nice things later, and nobody's
thing has to break while we're working on this.

**Mike Schmidt**: Greg, I saw some emojis flying by.  Do you care to elaborate
on any of those emojis or anything else?

**Greg Sanders**: No, it's just thumbs-downing mini cluster, that's all.  We
were just talking about it offline.  I'm just joking!

**Mike Schmidt**: All right!

**Greg Sanders**: Murch, it's on you to make a good name.

**Mark Erhardt**: Oh, God!  I will probably have to reject that responsibility.
But I just wanted to say, cluster mempool makes it basically possible to think
about a lot of these in a structured way that we didn't really have a good way
of thinking about before.  So, I've heard one of my colleagues basically summed
it up as, before cluster mempool, we didn't really have a good way of thinking
about replacements of big packages in the first place; but with cluster mempool
and feerate diagram comparison, we have a structured way of evaluating when
something is actually better than the original.  And the feerate diagram is
maybe a little conservative, but when something shows up as better in the
feerate diagram, we are sure that it actually makes the mempool better in all
feerates across the entire mempool.  There will be more fees; the next mining
scores will be better; the next blocks will be better.  So, we only accept
replacements that strictly improve the mempool.

I think abstracting away a lot of the complexity that was previously
intermingled at the same level with these considerations and package evaluation,
it sort of gives us a new language of thinking about how to do all of these
projects in the first place.

**Mike Schmidt**: AJ, I would be remiss to not at least ask you if you have any
opinions or anything to add on this discussion of mempool and policy and
interplay with LN; anything to add?

**Anthony Towns**: I think it's all been pretty well covered.  I guess the only
thing that wasn't mentioned is that the eltoo, LN-Symmetry stuff requires the
zero feerate on commitment transactions.  So, rather than just being a
nice-to-have there, it's a necessary-to-have.

**Mike Schmidt**: T-bast, any calls to action for the audience?

**Bastien Teinturier**: Not necessarily for the audience, but yes, I know that
if we want to do that pattern matching of existing LN transactions to
automatically enroll them into v3, the only potential issue is for people who do
batching, where the current batch CPFP would not be accepted under the v3 rule,
unless we make changes to that, but I'm not sure exactly what we would do here.
So, we need to check.  I believe that LND is probably the only implementation
that does that, and I don't know how big their CPFP may be.  So, I'd like Laolu
or someone else from the LND team to check whether their current CPFP batching
would be compatible with this enrollment of anchor spends into v3 rules.

**Mike Schmidt**: T-bast, before we let you go, there's one thing I think you
can help us with.  We added a new topic to the Optech topics list, titled
Trimmed HTLCs.  Maybe you could provide listeners a description of what Trimmed
HTLCs are.

**Bastien Teinturier**: Yes, sure.  So, this is whenever you send a payment
using LN, you send what is called an HTLC.  And usually if that HTLC is big
enough, in order to enforce that this is fully trustless, we modify the
commitment transaction to add an output to that transaction that represents that
HTLC, and that would let the participants claim the HTLC funds onchain if
something happens and the channel is force closed.  But unfortunately, or
obviously, that cannot work for all amounts because some amounts are too small
to be claimed onchain.  So, whenever an HTLC is too small to be claimed onchain,
we call it trimmed, and we do not create an output in the commitment transaction
for it.  And instead, temporarily while the HTLC is pending, its amount just
goes to minor fees and increases the fees of the commitment transaction, which
has an interesting side effect that most people don't realize, that if you force
close with pending trimmed HTLCs, those HTLCs are lost to both participants.
They directly go to the miners.

So, this could potentially be used to make commitment transactions pay a lot of
fees to miners.  So, that's why every implementation has a limit on how many
pending trimmed HTLCs can be happening in the channel at the same time, and
that's usually configurable directly on your node.  And, yeah, that's it.

**Mike Schmidt**: Thanks, t-bast.  You're welcome to stay on.  I know we have
one Eclair PR, if you want to chime in on that later.  Otherwise, if you have
other things to do, you can drop.  Thanks for joining us.

**Bastien Teinturier**: I'll stay around, thanks.

_New documentation repository_

**Mike Schmidt**: Great.  Next news item, titled in the newsletter as New
documentation repository.  AJ, you posted to the Bitcoin-Dev mailing list with
the subject line, BIP process friction.  Maybe to kick us off, what, from your
perspective, are the frictions generally, and then maybe specifically, how does
that impact some of your work on Bitcoin Inquisition?

**Anthony Towns**: Well, I'll go the other way around and start with a specific
one.  There's a whole bunch of consensus change proposals going around.  So, the
Vault stuff, obviously the OP_ANYPREVOUT (APO) and OP_CHECKTEMPLATEVERIFY (CTV)
stuff that have been around for a while, but more recently the Vault stuff,
OP_CHECKSIGFROMSTACK (CSFS), the new LNHANCE stuff, and the total simplest one
is the OP_CAT one, which is just a really simple opcode that takes two things
from the stack, combines them and puts them back on the stack.  So, at least to
me, that's kind of a, "Okay, this should be easy, we should be able to do it
really quickly, get a PR done, get it out there and start testing it".  And I
mean, I'm not super-excited about what it can do.  I think it can do some cool
stuff with BitVM sort of things, but it's not a change-the-world sort of thing,
as far as I can see, but it should be easy and it should be quick.  And I mean,
that's the theory and practice is completely different.

So, one of the things for Inquisition that I try to do is have the activation
get signaled by the BIP number.  And so I said, "Okay, well, let's get the
OP_CAT stuff proposed as a BIP and then we can move on from that".  And by the
time it had been a month waiting for the BIP to get even a number assigned, that
got frustrating.  And so, I bit the bullet, got frustrated, did a bender,
whatever you want to call it, and said, "Okay, I'll just make my own BIPs
repository with Blackjack and whatever.  And so, that's what I went ahead and
did.  And in saying that I thought, "Well, you can't just complain about OP_CAT
not getting a BIP number, you've got to complain about everything you're
frustrated with, and that's kind of what the email went through.  So more
generally, there's been a bunch of proposals that have just been sitting there,
and it's been in general a bit difficult to get progress.

I mean, my view on that is that it's frustrating and that it should be easy, and
so that's what I'm doing with the BINANA thing, making it as easy as possible.
You write up the proposal, you get the next number in the sequence and it gets
merged and then we're done.  But like the BIP2 specification, for what it takes
to get into the BIPs repository, has extra more subjective requirements than
that.  So, one of them is it needs to report on backwards-compatibility if
that's a concern, and so that's paused a few proposals in that the authors
didn't think it was a concern, but the editors do think it's a concern.  So,
then there's a bit of debate about that, and then there's a writeup added, and
then maybe things progress.  And there's also a clause that says it has to be in
the spirit of Bitcoin, whatever that means, and so that's also held some things
up.

I don't know, to publish some stuff on the internet, that just doesn't seem
worth the hassle.  It's easy to publish things on the internet.  And so trying
to force things to be in the spirit of something just to get in a particular
repository doesn't really seem like a helpful bottleneck.  So, yeah, so I put up
the thing that works around that for at least the things I care about.  And if
anyone else wants to also use it, then they're welcome to too.

**Mike Schmidt**: Is the implication here that this repository will have
requests merged quicker and in a more liberal view than the current BIPs
repository?

**Anthony Towns**: That's the theory.  If we can replace the merging thing with
a small shell script, then that would be great.

**Mike Schmidt**: So, you'll basically merge anything that's Bitcoin-related
that's not spam; is that sort of the gist of it?

**Anthony Towns**: Yeah.  If it's really badly formatted, then we might try and
hold up and get the formatting fixed first, but in general, the sort of things
that can be checked automatically, like via a linter and otherwise.  I just
don't want to have 3,000 different numbers all referring to slightly different
versions of the same thing, and I don't I don't think anyone would want to add
Ethereum or Solana, or something, specifications to it, but if they were
completely unrelated to Bitcoin, I think those would just get stopped as well.
But otherwise, everything's fair game.

**Mike Schmidt**: In your mind, if we're looking a few years ahead, what does
success around BINANA -- I'm saying BINANA; is it banana? -- look like in a few
years?

**Anthony Towns**: So, as far as I'm concerned, the Australian accent doesn't
really do vowels very clearly, so it doesn't really matter how you pronounce it.
But you're not Australian, so you'll need to contact your own grammarians, or
whatever!  As far as success, if someone's writing a spec for something that's
going to improve Bitcoin, as long as they can get it published and discuss it as
conveniently as possible, then that's a win.  If that means that it happens in
the BIPs repository, that's great; if it happens in the BINANA repository,
that's great; if it happens somewhere else, that's also great.  If it doesn't
happen at all, then that's a failure.

**Mike Schmidt**: In terms of the scheme, maybe talk about the motivation in
terms of, it looks like the I-A-N-A, Internet Assigned Numbers Authority, was
somewhat a motivator in terms of the formatting here?

**Anthony Towns**: Yeah, so BIP is the obvious thing that everyone in the
blockchain community follows, but we've already got BIP, so I can't just use
that.  And the next thing up is RFCs, which is all right.  And the next thing
from that is IANA, and putting a B in front of that made it sound funny, so
that's what I went with.

**Mike Schmidt**: You always have a great sense of humor, AJ!  Any special
guests or my co-host, Murch, comments on the motivation behind this, the
friction?  Gloria, I don't know if it was in AJ's writeup, but at some point
recently, I came across a policy-related BIP that apparently we're not supposed
to have policy-related BIPs.  Maybe too contentious, but what are your comments?

**Gloria Zhao**: Yeah, sure.  I mean, Greg and I have opened BIPs for ephemeral
anchors and v3, respectively.  By BIP2, I think we're writing a specification
that protocol developers like LN, or node implementations that want to implement
the same policy, might refer to so that they can interoperate and have an
implementation-agnostic specification.  But we are not allowed to have BIPs,
essentially, because Luke says so.  I'm going to try not to sound salty here,
but it's quite frustrating to essentially not be allowed to propose something
because somebody says so.  And similarly, I have a BIP for package relay that
has a number, you know I did get a number assigned to it, but it's been open for
like a year-and-a-half.  I've pinged privately to try to see, "How do I get this
merged?" and no response; ping on publicly, you know, it's frustrating.

I think people have a lot of comments to say about Bitcoin development, and its
shortcomings.  I think this is a good example of that.  I think not all the
criticisms I agree with, but I think this is an example of where I think the
process is not great.  Just a little testimonial there.

**Mike Schmidt**: So, Gloria, will you be opening up PRs to the BINANA repo?

**Gloria Zhao**: Yeah, so I mean I would like an explicit rejection of my BIP
first.  One of the frustrating things is just getting no response.  I think I've
gotten a comment quoting a tweet from Luke saying why he doesn't believe policy
should -- but I would appreciate a GitHub comment.  But yeah, after that, if
that's rejected, then I think the next step would be to have a BINANA, because
having a way to canonically refer to a set of ideas and a specification is very
useful.  I mean, that's one of the reasons to have a standard, right?  It's to
be like, "I'm talking about BINANA number this, or BIP number this", and so we
can all refer to this as a canonical list of things that we all agree, like we
don't have to argue about what the definition of v3 is.  It's like, okay, we
just point at that thing and that's what the definition is.  So, yeah, I think
it'd be nice if we could consolidate where all of our documentation is, but
yeah, thank you, AJ, for agreeing to have a separate system for this spec; it's
very much appreciated.

**Anthony Towns**: So, since the Optech Newsletter came out, I merged BIN24-5 as
well, which is a list of Bitcoin-related specifications, like repos, like the
BIPs and the BINANAs.  So, there's one, two, three, four, five, six, seven,
eight of them I found, like BIPs, SLIPs, BOLTs, BLIPs, LNPBP, dlcspecs, MINT and
BINANA, that all cover pretty much dedicated Bitcoin-y sort of things.  And
then, there's another half dozen from other blockchains that I thought were
interesting that I put in there.  So I mean, we've already gone away from
everything being a BIP these days, so I'm not too worried about producing a new,
different area because we've already got plenty of those.

**Mark Erhardt**: Yeah, one of the concerns that I would have with this further
fragmentation of where we look to find specifications of stuff is, it might lead
people to post different versions of the same proposal in different
repositories, and it might muddle with what is the single source of truth.  So,
if you had, for example, a BIP proposal and at some point became disillusioned
with the BIP process, and then posted an updated proposal to BINANA as a BIN, it
might just make it confusing which one is now the authoritative or latest spec.
And I think if we just make sure that we keep an eye on that, it will be great
to have a faster-moving process that just allows us all to have a visible and
addressable space where we can post our ideas.

**Anthony Towns**: Yeah, I think on the BINANA side, that's okay-ish, in that if
you've got a BIP number assigned and want to use that as the canonical thing,
then we can just update the BIN spec to specify, "This is the same thing as BIP
number &lt;whatever>, and you should just look there for the latest text".
Doing it the other way depends on how quickly you can get the BIP text updated
to refer across the other way, which if you're abandoning the BIP, maybe that's
the problem in the first place.  So, I don't know about that, but at least I
think the other way can work okay.

**Mark Erhardt**: I think I also saw that you added version numbers, and I think
that's been something that's been missing from the BIPs.  So basically, the
policy had been for BIPs that the authors own the BIP, but there were some BIPs
that were sort of living documents that got updated a few times after they were
published, and it was always unclear, does this now require a new BIP; is this a
minor enough modification that it can go into the old BIP?  But having the
versions would just make it much simpler.

**Anthony Towns**: Yeah, so the revision number that I put in there is something
I need for the Inquisition soft fork activation strategy.  So, if you update APO
to have a different scheme for signature hashing (sighashing), then you need to
distinguish whether the soft fork that's activated onchain is the old version or
the new version.  So, I needed to encode a revision number in that.  And so that
necessarily made it into the BIN template kind of setup.

**Mike Schmidt**: So, folks can draft their proposals, and that proposal can
live in the BINANA repository.  But it also sounds like you'd be open to having,
I guess, pointers from the BINANA repository to canonical proposals hosted
elsewhere.

**Anthony Towns**: Yeah, I think once you have it canonically hosted somewhere
else, then you just replace the BINANA documents text with a link.  But in the
meantime, while the BINANA one's getting updated more frequently, then the
header of the document has an entry for alias, which a bunch of the ones that
are already there have links to the BIPs' PRs.

**Mike Schmidt**: We highlighted the four BINs in the newsletter and, AJ, you
noted number 5, which currently no PRs.  Godspeed to you as the word gets out on
this, what's going to be coming at you.  I hope it doesn't take up too much of
your time.

**Anthony Towns**: Yeah, well hopefully if it gets that popular, then it's worth
writing a merge script that can auto-merge stuff.  I'm not sure how we'd manage
to get the README updated without conflicts between proposals, but these aren't
really super-hard programming things to solve if we wanted.

**Mike Schmidt**: Well thanks for putting this together, thanks for joining us.
Any parting words for listeners?

**Anthony Towns**: No, I've been having fun making logos with the AI
image-creation stuff.  That's about it!

**Mike Schmidt**: I look forward to seeing the output of that soon.  Thanks for
joining us, AJ.  You're welcome to stay on, or if you have sleep to get to, we
understand.  Next section from the newsletter, Changes to services and client
software.  We have five that we've highlighted this week.

_Envoy 1.5 released_

First one is Envoy 1.5, which adds support for taproot sending and receiving,
and also changes the way that Envoy handles uneconomical outputs.  And then
there's also some bug fixes and other updates.  For those who want to use
taproot, they noted that you'd have to enable that from settings currently under
"Advanced", and then you get a separate new taproot-specific account that would
be created.  And also, in terms of the uneconomical output handling, Envoy, "Now
automatically excludes coins that are too low of a value to spend in the current
high-fee environment".

**Mark Erhardt**: Hey, that was also my first PR to Bitcoin Core.  When you
finish your current selection, it would filter the uneconomical inputs on that
transaction.  Unfortunately, it got merged in 2014 and reverted slightly later.

_Liana v4.0 released_

**Mike Schmidt**: Liana v4.0 is released.  Liana now includes support for fee
bumping using RBF, as well as transaction canceling, also using RBF.  And
they've also added automatic coin selection.  And they got into their blogpost a
bit about some of the rationale of why they launched, initially in the first few
versions, kept manual coin selection.  So, check out the blogpost for some more
details there.  And they've also added some hardware signing device address
verification features.  Murch, any thoughts on Liana?

**Mark Erhardt**: Sounds interesting.  I haven't tried it myself yet.  Talked to
the developers a bit.  I really like their model with the built-in
inheritance/making it easier to have fewer keys later, more spending
opportunities.  But yeah, you should check it out.

_Mercury Layer announced_

**Mike Schmidt**: The next item we highlighted is Mercury Layer announced.  And
we have special guests, Nicholas and Tom, to walk us through this.  I don't know
who wants to provide a high-level summary of what Mercury Layer is and
potentially distinguishing it from other Mercury things?  Maybe, Nicholas, you
want to take it?

**Nicholas Gregory**: Sure, yeah.  So, we originally built Mercury wallet, which
had reasonable use, I think, about three years ago, but that wasn't a blinded
solution, so we were aware of all the Bitcoin addresses that were deposited into
the state chain.  And what we've done is we've kind of redesigned a lot of the
back end, removed a lot of existing code, etc, it's probably maybe 80% smaller,
and implemented a blinded version using the MuSig2 protocol stuff, which I think
Tom came on your show about a year, six months ago to discuss.  Essentially,
it's now just a blinded server.  We only have a database with three columns in
it: a unique ID; a date of when this was created; and the number of transitions.
And we're not live, but we did put this into a test environment about a month
ago.  We've had lots of use, lots of people playing with it.

We plan to be live in a couple of weeks, but it's fully blinded.  No information
is kept on Bitcoin addresses at all, so it's quite a radical change.  And we are
going to release a wallet, but that will probably be more of an experimental
wallet.  This release is very much focused on just providing the state chain
entity itself.

**Mike Schmidt**: I think I read somewhere that the goal is to have other
wallets integrating these features.  Am I right in understanding that, that it's
not just going to be a Mercury wallet that has this feature, or did I
misunderstand that?

**Nicholas Gregory**: Yes, absolutely correct.  I mean, a lot of complaints
about the old version was very hard to integrate.  We didn't really design the
previous with integration in mind.  So, yeah, we've got a Rust API that people
can play with.  We've already had a few wallet people contact us.  People in the
Nostr community have been playing with it as well.  So, yeah, that's pretty much
the approach.  So, it's more of a layer 2 rather than a wallet, if that makes
sense.

**Mike Schmidt**: How would you categorize interest in state chains in the
ecosystem?  It feels like it's interesting technology, but just from my own
personal vantage point, it doesn't seem like it gets a lot of discussion in the
ecosystem, but maybe you have a different perspective.

**Nicholas Gregory**: Well, I think when we released it two years ago, everyone
saw us as like a competitor to Wasabi and Samourai, and that's because we
implemented coinswaps as well.  I think from our point of view, there's much
more interest right now in layer 2s.  I mean, a lot of people compare us to Ark.
Unlike Ark we don't really have the liquidity; there's no liquidity needed.  I
mean, people come to us, they deposit, they buy a stake coin off us, they pay
this with Lightning and it's theirs, it's like a virtual OPENDIME.  And I think
there's more interest right now in layer 2s than there was when we released
Mercury 1.  Maybe we don't get as much noise as LN, but it's not a competitor to
LN, it's very different.  It's more like Ark, I would say.

**Mike Schmidt**: Yeah, maybe you or Tom can drill down a bit more on maybe the
comparison of state chains and what you guys have with Mercury Layer, compared
to maybe not just Ark specifically, but coinpools, joinpools, that kind of
thing; how should folks think about the differences between those sorts of
solutions?  Tom, you want to take that one?

**Tom Trevethan**: Oh, yeah, okay.  Yeah, well I mean the big difference
obviously you have to understand with Mercury Layer is the trust element
involved, but it does mean that there's no other kinds of constraints in terms
of capitalization like there are with Ark.  I mean, one of the big, I think,
downsides of Ark is that every single transfer needs to be backed with funds by
the Ark service provider.  So, there's this kind of huge capital requirement for
it to operate.  Whereas with the Mercury Layer, there's no such requirement.
And the way that the Mercury server has been designed is that it just signs
blindly, and it isn't even aware of what it's signing for.  So, from a legal
point of view as well, it doesn't have any -- it's not… yeah. [? Tails off?
52:23]

**Mike Schmidt**: Tom, I'm curious about this MuSig2 variation.  I think we've
talked with you in the past, but maybe for folks who are listening who maybe are
a little bit gun-shy regarding things like MuSig2 or MuSig, given the iterations
that that proposal has gone through, you guys now have some sort of variation on
that.  What is the state of that in terms of its peer review and maybe ecosystem
review of that particular protocol?

**Tom Trevethan**: Yeah, it's also been discussed on the Bitcoin mailing list,
and we've kind of published the protocol that we solved these issues with the
various attacks that can be used against blinded MuSig, basically using a
commitment of ephemeral keys and things, which enables the receiver of coins
basically to verify that the challenge values have been computed correctly.  So,
yeah, I mean we've got the protocol published and obviously, we'd like as many
eyes on it as possible really.  But so far, we've not found anybody that's been
able to poke any holes in it.

**Mike Schmidt**: Murch, or any of our special guests today, any questions for
the Mercury Layer team?  Thumbs up from Murch, great.  Well, Tom and Nicholas,
it sounds like we can look forward to more news coming as you guys roll this
out.  Any calls to action from the audience in terms of Mercury Layer?

**Tom Trevethan**: Yeah, if you've got any ideas, if you want to build on it,
come to our Telegram group, message us.  We're open to ideas.  We've had all
sorts of people that have come to work with us.  One of the questions is, could
we demo how Mercury could be improved with covenants?  So, we are speaking to
the CTV guys because that would help in some capacity as well.  We can go live
as Bitcoin is right now, so there's no constraint there.

**Mike Schmidt**: Well, thank you both for joining us.  You're welcome to stay
on as we move through the newsletter.  Yeah, cheers.  Next piece of software
that we highlighted was --

**Mark Erhardt**: Actually, I changed my mind, I do have a comment.  I think
maybe if you're a frequent listener of this weekly review of what's going on,
you've noticed that a lot of joinpools, state chains, other ways of sharing
UTXOs, Ark, you know what I'm talking about, have been coming up lately a lot
again, especially with the feerates being up.  I think people are much more
aware this year again that block space is a limited resource.  It has to be by
design a limited resource for a lot of the incentives to work out for people to
continue to be able to run nodes at home.  And I don't think that it's
reasonable for everyone to expect that all users of Bitcoin will use onchain
payments as their main driver to move around Bitcoin.

There's over, what is it now, 8 billion people on this planet.  If we are
looking to build the native cash for internet, the scalability of that looks
very bleak.  And it's just not very interesting to try and scale up onchain
payments to a level where everybody can just do their coffee payments onchain.
I think that was the main message or learning from the fork wars, blocksize
wars.  But we need ways of scaling up Bitcoin use without increasing onchain
transactions as much; we need a more than linear increase on that.  And schemes
where we use UTXOs among multiple people, have offchain settlement protocols or
just pass around ownership without actually changing the UTXO onchain are an
important and big step towards being able to roll out Bitcoin to more people.
So, if you're interested in this sort of stuff, just look at the proposals and
contribute.

**Mike Schmidt**: There was a blogpost by AJ that talks a little bit about
scaling.  The title is Putting the B in BTC.  So, google that title if you want
to read some of AJ's thoughts.

_AQUA wallet announced_

Moving on in the newsletter, next piece of software that we highlighted was AQUA
wallet announced.  The AQUA wallet is a mobile wallet for iOS and Android,
recently open-sourced as of a few days ago, and that supports Bitcoin, Lightning
and Liquid.  It also has features built in that allow swapping between Bitcoin,
Lightning and Liquid.  So, if you're curious about that, check out their
product.

_Samourai Wallet announces atomic swap feature_

The last piece of software that we highlighted was Samourai Wallet announcing
atomic swap feature.  So, this is cross-chain atomic swap feature.  We link to
the research that that atomic swap feature was based on, and it allows P2P
coinswaps between Bitcoin and Monero.  And I just thought this was interesting
since I think Optech has mentioned atomic swaps in the context of research about
40 times previously, so I thought it'd be nice to actually highlight something
in the wild.  And thank you, so far, to the Bitcoin community for tolerating my
mentioning of a non-Bitcoin chain in the newsletter.  Murch, any thoughts about
Samourai Wallet or AQUA?

_LDK 0.0.120_

All right, moving on to Releases and release candidates.  LDK 0.0.120, which
includes a few different API updates and bug fixes from the release notes, but
also addresses a security DoS vulnerability, involving untrusted peers providing
input to LDK nodes that have the manually_accept_inbound_channels option set.
There's two PRs related to that vulnerability on the LDK repository.  If you're
curious, it's LDK #2808 and LDK #2809 for more details.

_HWI 2.4.0-rc1_

Next RC that we highlighted was to the HWI repository, and I wasn't immediately
able to locate anything interesting from the release notes to highlight here.
And, Murch, I don't think you were either, so if you're still good with that we
can move on, I guess.

**Mark Erhardt**: Yeah, I just asked achow whether she has any comments, but I
haven't heard anything back yet.

_Bitcoin Core #29239_

**Mike Schmidt**: Four notable PRs we highlighted this week.  Bitcoin Core
#29239.  Last week we covered Bitcoin Core #29058, which was another preparation
step in rolling out v2 encrypted transport by default.  In that PR, v2 support
was added to some configuration arguments.  And this week, we highlighted the
addnode RPC that will use v2 transport if the v2 transport setting is enabled.
Anything to add, Murch or Gloria?

**Mark Erhardt**: Well, you know, I'm really excited about v2 transport.  I
think it's an important stepping stone to make it, well, for one, way more
expensive to observe network traffic on the Bitcoin Network, but also, in the
hopes that we'll eventually get the countersign proposal to a point where it
would be accepted, it would allow us to build in a way of finding out that
you're connected to exactly the node that you want to without anyone interfering
between that node and your own node.  Right now, this is surprisingly simple
because all of the Bitcoin traffic is completely out in the open and clear.  So,
if someone wants to, for example, omit transactions along the way, for example,
your ISP, they could just modify the traffic and never let you broadcast your
transaction or never let you learn about a new block.

So, on the one hand, we already have a workaround with that by having support
for multiple other networks, like Tor, or if you use a tunnel to connect your
node through some server, you might also be able to route around your ISP.  But
by just encrypting everything by default, it's so much more expensive that I
think the gratuitous watching what's going on is, as an attack vector, just
going away.  So, if you haven't turned on v2 transport yet, I think it's -- I
haven't heard any problems yet.  I've been running it myself since the release,
and yeah, next release it will be even easier and it might even be turned on by
default.

_Eclair #2810_

**Mike Schmidt**: Bastien, thank you for holding on, because my notes for this
Eclair #2810 PR are, "Bastien?"  So, do you want to take Eclair #2810?

**Bastien Teinturier**: Yeah, let me bring it up.  What's the title of the PR?

**Mike Schmidt**: The title is Variable size for trampoline onion.

**Bastien Teinturier**: Okay, right.  All right, so trampoline is something that
we started working on five years ago, I guess, and we started shipping it more
than three years ago, and nobody else picked it up because it's only useful
basically for people doing a non-custodial wallets, and mostly nobody else was
working on non-custodial LN wallets at the time.  Now, it's coming back since
LDK is trying to enable more diversity in the non-custodial wallet ecosystem,
which is really nice.  So, they have started to look at trampoline again.  And I
hope we're going to be able to get trampoline finalized this year.

One other thing, in the initial implementation that we did a very long time ago,
the trampoline payload was fixed size, which meant you could only have a
specific amount of trampoline nodes in your route, whereas we could actually
make it just variable size very easily.  And later, I changed the specification
to make it variable size, but I didn't bother to check the implementation
because we were the only implementation available, and I wanted to wait for
feedback from other implementations before changing implementation, because I
expected more changes on the spec once other people started looking at it.  But
now that the LDK team is looking at it and this is making progress, we wanted to
take that first step of making the trampoline onion variable size, which is also
an interesting improvement when you couple trampoline with blinded paths, which
are used for BOLT12.

So, this is a first stepping stone towards using trampoline with blinded path
and finalizing trampoline, and getting a spec version out there that would be
interoperable with LDK, and then later with other implementations when they
decide to pick it up.  So, this is exciting that this is finally happening.

**Mike Schmidt**: That's great.  Thanks t-bast for walking us through that.  We
have two more sets of PRs that we are covering for the newsletter.  I'll take an
opportunity to solicit any questions from the audience for any of our special
guests who remain, and any of the topics that we've discussed here in #286.  And
I also hear, Murch, that you have a little bit more detail about the "no detail"
that we provided about that HWI release candidate.  You want to elaborate on
that?

**Mark Erhardt**: Yeah, so I hear that there is a new model for one of the
popular hardware wallets that's now supported by the new release of HWI, and
basically it's just that the old release was outdated a little bit, or someone
wanted a new release, so it's this new model that's supported now, and it was
just time to release another version.

_LDK #2791, #2801, and #2812_

**Mike Schmidt**: LDK #2791, #2801, and #2812 complete adding support for route
blinding and begins advertising the feature bit for it.  So, Murch, as we
anticipated, the deluge of route blinding PRs to LDK have happened all in one
batch here.  Maybe since we have an LN expert on, Bastien, do you care to give
an elevator pitch summary on blinded paths and whether multiple implementations
need to have full support for it in order for it to be rolled out on the
network?

**Bastien Teinturier**: Yeah, so blinded path is something that has to be used
by default when you use BOLT12.  The goal of blinded path is to hide the
recipient's identity from the payers.  If you want to receive a payment but do
not want to disclose your node ID and your identity, you just choose another
node in the network, find the route from that node to yourself, and then with --

**Mike Schmidt**: That was my fault; I accidentally hit the mute everyone
button, sorry!

**Bastien Teinturier**: No worries!  So, then once you have created a path to
yourself through someone else, you can encrypt all the intermediate nodes in
that path and your node ID and you give that blinded path to someone.  And in
order to pay you, they will have to go through that node you selected in the
network and then afterwards, they don't know where exactly the payment going.
And this requires some changes to the onion.  This really uses the onion
encryption scheme that we have, that is called Sphinx, in a slightly different
way, but is basically mostly reusing parts of that cryptographic algorithm, but
it required some code from everyone.  And then to integrate it with payment,
there are a lot of implementation details and it required some work; also, the
introduction of onion messages, the introduction of types and formats for BOLT12
invoices.

But everyone is actually actively working on this.  All four implementations are
actively merging PRs towards that goal.  So, I hope that's something that we'll
be able to test into interoperability soon as well.

_Rust Bitcoin #2230_

**Mike Schmidt**: Awesome.  Lightning's moving.  Thanks again, t-bast, for
sticking on for that.  Last PR this week is to the Rust Bitcoin repository
#2230, a PR titled, Add effective value calculation.  This change, and I'm
quoting from a comment in one of the PR code files, "Computes the value of an
output, accounting for the cost of spending it".  Murch, I'm sure you have
something to say about effective value calculations.

**Mark Erhardt**: Yeah, so effective value was described, or I think that's one
of the main contributions of my master thesis from 2016, the idea that if you
look at an input and you know the feerate already, you know how big the input
size will be, and with the feerate you can calculate how much of the fees
basically go just towards adding the input to the transaction.  And therefore,
you know how much an input contributes towards the funding that you're trying to
achieve for the whole transaction.  So, when you build a transaction, you look
at all of the recipient outputs; you know exactly what size they'll have; you
know how big the transaction header will be, which is the input counter, output
counter, version, and LockTime; and for segwit transactions, also marker and
flag.  So, those are the fixed costs, you know already how much that is.  You
can just add that to how much you have to raise in order to fund the
transaction.  And now if you can look at the inputs on the basis of their
effective value rather than their absolute amounts, it is much easier to see
whether you have selected enough funds.

Prior to my work in Bitcoin Core, we basically would just select inputs and then
check whether we can both pay for the transaction as well as the transaction
fees of the inputs.  And after this change, we only need to do it once and we
know we have enough money.  So basically, this is a pretty rudimentary change if
you want to get serious about exploring different coin selection strategies to
build transactions, and makes it a lot easier to think about the rest of it.

**Mike Schmidt**: I don't see any requests for speaker access or questions on
the thread, so I think we can wrap up.  Thanks to all our special guests, Tom,
Nicholas, Gloria, AJ, Bastien, Niklas, and always to my co-host, Murch.  Thank
you all for joining us.

**Mark Erhardt**: Also thank you to Gloria and instagibbs.

**Mike Schmidt**: Thank you, instagibbs.  Thank you, Gloria.

**Gloria Zhao**: Thank you.

**Mike Schmidt**: Cheers.

{% include references.md %}
