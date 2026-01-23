---
title: 'Bitcoin Optech Newsletter #388 Recap Podcast'
permalink: /en/podcast/2026/01/20/
reference: /en/newsletters/2026/01/16/
name: 2026-01-20-recap
slug: 2026-01-20-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Bruno Garcia to discuss [Newsletter #388]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-0-20/416508653-44100-2-bafa5f5ceb023.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome, everyone, to Bitcoin Optech Newsletter #388 Recap.
Today, we're going to talk about some updates and improvements to mutation
testing in Bitcoin Core; we also have an update to the BIP process and a special
guest for that; and we have a couple of guests as well, they're going to join us
for a few components.  Joining Murch and Gustavo and myself, we have Bruno.
Bruno, you want to say hi?

**Bruno Garcia**: Hi, glad to be here.

**Mike Schmidt**: Where are you at, Bruno?  Who are you working for?

**Bruno Garcia**: Oh, I'm working on Bitcoin Core and I'm Head of Engineering at
Vinteum, and also I'm the creator of bitcoinfuzz.

_An overview of incremental mutation testing in Bitcoin Core_

**Mike Schmidt**: Awesome.  Jumping to the news, we have, "An overview of
incremental mutation testing in Bitcoin Core".  Bruno, you posted to Delving
Bitcoin about your work on improving mutation testing in Bitcoin Core.  I know
you did a little recap in your write-up about how mutation testing is done in
Bitcoin Core today.  But we also had you on in our Podcast #320 Recap, where you
talked about mutation testing.  I think that was back in 2024.  So, if folks are
listening to what you say and are curious about the fundamentals of it, they can
refer back to that episode.  But maybe as you introduce what you're working on
now in incremental pieces to this, Bruno, maybe you can just give the lay of the
land.  What's the summary of how we're doing it today?  And then, we can
introduce incremental mutation testing.

**Bruno Garcia**: Yeah, cool.  So, in Bitcoin Core, we have mutation tests.
Basically, what we do is every week, so every Friday, we get some files from
master branch, and then we run the mutation analysis.  Then we get the results
and publish at coredev.dev.  So, basically this is what we do.  So, we have some
files that we want to mutate and we define some tests that test those files, and
then every week we run this analysis.  But it's basically based on the master
branch.  And now, I am trying an approach to do incremental mutation tests.
It's basically mutation testing per PR.  So, what we do is basically we get the
code from master branch every week.  But what I want to do is basically run
mutation testing per PR.  So, basically I have a PR, then I have the files and
the line of codes that the PR touches basically, and then we apply the mutations
only in that code.  So, yeah, this is the general idea.

**Mike Schmidt**: Maybe you can get into, like, why not just mutate it all?
Maybe talk about some of the requirements of why that would be maybe a naïve
approach and not be efficient.

**Bruno Garcia**: Yeah.  Mutation test is basically very expensive, because you
have, for example, if I do a mutation in a code, I have to compile the code and
I have to run the tests to test that mutant.  But specifically in Bitcoin Core,
we have unit tests, we have functional tests, we have fuzzing, and we have a
single functional test that takes over one minute to run.  So, if I had many,
many, many, many mutants, it would take hours and hours to run.  So, yeah, doing
mutation tests per PR is great because you can create mutants only for the lines
of code that PR touches.  Basically, using git diff, we can see the difference
and say, "Okay, I'm going to apply the mutants here".

**Mike Schmidt**: Maybe I'll give you my naïve question, which is, is there
tooling to do creating mutants without having to go to the source code and
recompile?  Like, can you manipulate the binary in some way and create mutants
that way?

**Bruno Garcia**: Yeah.  The tool I created, basically we create the mutants
based on the source code itself, but there's another tool that applies the
mutants, that creates the mutants based on the binary, so you don't need to
recompile.  Of course, this approach has some limitations because you have some
limited operators.  But yeah, it works well.  But I personally think this is not
the main problem we have.  I think the main problem is our tests take too long
to run.  Because in compiler we have cache, for example, we can use ccache.  But
if I have to run a functional test that takes like two minutes to run, this is
bad.

**Mark Erhardt**: Right.  So, with the ccache, compiling can be just, on a fast
machine, a few seconds, maybe 20 seconds or so, depending on what files were
touched.  You only have to recompile the touched files and the rest just gets
linked together again.  And then, running the tests is really the expensive
thing.  So, in our write-up, we mentioned that you found ways to prefilter the
mutants and maybe score them, or in some way pick only the ones that seem most
promising.  Can you talk a little bit about what approach you take there?

**Bruno Garcia**: Yeah, basically I do some analysis on the source code to only
create useful mutants.  So, for example, if I have 'if … print'.  Okay, it
doesn't matter if I change this 'if', because it's just a print, a log, or it
doesn't matter for us.  So, we have a lot of ways to skip creating this and not
to use it for mutants.  And, yeah, so I define it in my tool.  So, for example,
okay, you can skip if the line is basically a log debug or log print.  And the
other problem of mutation testing is because sometimes you create mutants that
we call 'equivalent mutants'.  So, when you compare the behavior of the mutant
with the original code, the behavior is basically the same.  So, one way that I
make sure this mutant is equivalent or not equivalent is doing differential
fuzzing.  So, doing differential fuzzing between a mutant and the original code,
I can spend some minutes and know that, okay, I can kill this mutant or it can't
be killed.  So, yeah, it's this approach that I worked at last year.

**Mark Erhardt**: So, that sounds expensive too, though.  If you say that
functional testing for a few minutes is expensive, finding out whether two
pieces of code are semantically equivalent by differential fuzzing for several
minutes seems like the same cost.  So, preferably you would like to avoid
creating them in the first place?

**Bruno Garcia**: Yeah.  But I usually do it if I am really in doubt about that
mutant.  But my previous research has shown that our corpora is enough to say
it's equivalent or not.  So, I really don't need to run for minutes.  Like, we
have our QA assets, we have the first corpora, and the inputs we have there are
enough to say if a mutant is equivalent or not.  I just have to mount the
differential fuzzing setup and use those inputs to test it.  But there are many,
many, many approaches to define if a mutant is equivalent or not.  For example,
I think not super-effective, but the most famous one is TCE, Trivial Compiler
Equivalence, where they compare the binary, because the compiler does some
optimizations and the final binary might be the same, so you can compare it.
But I think it can detect basically 20% of the equivalent mutants at all.  But
differential fuzzing is enough, and it's better because our corpora is very
strong.

**Mark Erhardt**: So, you said that you learned from Google's research that you
shouldn't surface more than, say, seven different mutants.  If you create more,
how do you pick which ones are the most relevant?

**Bruno Garcia**: Yeah, it's a great question.  So, sometimes I generated the
analysis for a PR, then I realized that, okay, we have hundreds of unkilled
mutants.  But if we have hundreds of unkilled mutants, it's basically saying to
me, "This PR isn't good at all".  It should improve the tests in general.  But
for some specific PRs, like four or five PRs, I had around ten unkilled mutants
or five unkilled mutants.  And Google follows an approach of just reporting to
the developers at most seven mutants.  If I have more than seven, I basically do
a manual analysis and I choose like, "Okay, these mutants are more important
than these ones".  But what I want to avoid is spamming PRs, like, "Okay, here
is unkilled mutants.  Here, here, here, this, this, this", which is bad because
the PR gets polluted.  So, I usually limit this number to seven at most.  But my
experience shows that I'm usually showing one, two, at most three mutants.

**Mark Erhardt**: So, it sounds like your mutation testing is highly manual, or
there's a lot of steps where you have to take another look at it.  Does that
mean that it could benefit from having more helpers, or does it require a lot of
expertise and really other people wouldn't be able to jump in quickly?

**Bruno Garcia**: Yeah, other people could help.  I think what we have to do is
basically, after running the analysis, we have to basically analyze the unkilled
mutants to know, "Okay, this matters; this doesn't matter", and it requires some
manual efforts and it requires some knowledge about that PR.  Because for
example, I applied mutation testing for the cluster mempool PR, and then I
reported a mutant that was not useful.  But I didn't realize it because I wasn't
aware of the general approach of cluster mempool.  But yeah, it requires some
manual efforts, people can join and help.  And we need some manual efforts.
Like, for example, when I'm doing mutation tests per PR, for example, supposing
that Murch created a PR changing something in the coin selection algorithm, so I
have to choose which tests I'm going to run, and it requires some manual
efforts.

So, I know that if Murch touches the coin selection, I can run coin selection,
coin selector or coin selection unit tests, I can run some wallet-related
functional tests, but it requires some manual efforts to define it.  Because if
I'm going to run the whole test, the whole functional test or unit test, it
would take a lot of time.  So, yeah, I created another tool to tell me, for
example, if someone touches coin selection, which test should I run?  But it
didn't work very well because, for example, coin selection, we have some
specific tests for coin selection, right?  But we have many other tests that
will touch that part of the code.  Because any wallet-related test can basically
require coin selection, but not specifically those tests are really testing coin
selection algorithms, you know what I mean?

**Mark Erhardt**: Yeah, that makes sense.  The outcome of coin selection would
affect transaction building, and so forth, and so you'd want to basically know
which test suites are relevant for a PR before you do the mutation testing in
order to cut down the time to evaluate the mutants.  But that requires knowing
about the codebase and how things are connected and what tests exist, and so
forth.  So, this introduces the manual effort here.

**Bruno Garcia**: Yeah, I think other projects like, if I'm not wrong, Rust
Bitcoin, they have mutation tests like automated, incremental mutation tests,
but it's because they basically only have unit tests, I guess, and it's very
fast, so they can run everything, so it's fine.  But it's not our case,
especially because of the functional tests.

**Mike Schmidt**: Bruno, maybe you dropped in the fact that you can use
bitcoinfuzz or some fuzzing as assistant to what you're doing with mutation
testing.  It might be useful for listeners if you can give a one-sentence
explanation of what is the goal and outcome of mutation testing; what are you
trying to find?  And then, maybe contrast that with what is bitcoinfuzz trying
to achieve; and what is something like Fuzzamoto trying to achieve?  And then,
maybe people can kind of see how these things are different and also maybe fit
together.

**Bruno Garcia**: Yeah.  Basically, Fuzzamoto, bitcoinfuzz or fuzzing Bitcoin
Core and other projects, we are basically trying to discover bugs.  With
mutation tests, we are trying to find bugs in our tests, because software can
have bugs, but tests are software, basically.  So, we can have bugs in our
tests.  So, mutation tests is basically to evaluate our tests.  So, if they are
good, adequate, so yeah.  So, this is the difference.  We are not finding bugs
in our application, we are trying to find bugs or we are trying to improve our
tests.  That's the difference.  Because most people, most people rely on code
coverage, "Okay, I have these tests covering 100% of my code", but it's not a
good metric.  So, mutation test is basically to evaluate the test itself.

**Mike Schmidt**: Murch, did you have anything else?

**Mark Erhardt**: Yeah, I was gonna chime in too, but basically the idea is to
create small mistakes in the code which tests the tests.  If the tests catch
changes to the code, they are better; if they don't catch changes to the code,
they need to be improved.  And by knowing what changes to the code don't get
checked, you know what to improve about the test.  So, it basically gives you
specific instructions where your test coverage is lacking and how you can
improve the test.

**Mike Schmidt**: Well, Murch hinted at a call to action for listeners if people
have some bandwidth and want to try to break the tests.  Maybe they're familiar
with a certain area of the Bitcoin Core codebase or would like to be, they could
maybe add value to the work that you're doing.  What else might listeners be
able to help out with, or what should their takeaway be, Bruno?

**Bruno Garcia**: Basically, it would be great if people can give me some
feedback about the mutation analysis, because with these feedbacks I can improve
the tool and generate better and better mutants.  So, it's basically a call for
action.  And yeah, so even if I basically post a mutant in a PR and you think
like, "Okay, this is not usable", tell me, because I use this information to
improve the way I generate the mutants, like Google does.

**Mark Erhardt**: You said that it takes a long time to run some of this stuff.
Would it be possible for people to donate compute if they have a computer
somewhere that has spare cycles?  Can they run mutations for you and report them
back?

**Bruno Garcia**: Yes, sure.

**Mark Erhardt**: How would that work?  Would they just get in touch with you or
is there an automated tool they can run?

**Mike Schmidt**: Yeah, SETI@home, is there like a mutation@home?!

**Bruno Garcia**: Yeah, I have the bcore-mutation tool.  And in the README,
there is a lot of information about how to run it.  But basically, after running
the mutation, the analysis, it will generate a JSON file.  Then you can share
with me and that's fine.

**Bruno Garcia**: Cool.  Although I think mutate@home will not be popular as a
project name!

**Mike Schmidt**: Well, Bruno, thank you.  Thank you for your time, thanks for
joining us.  You're welcome to stay on, but you're free to drop if you have
other things to do, we understand.

**Bruno Garcia**: Thank you.

_BIP process updated_

**Mike Schmidt**: We are going to continue with the News section, since we're
waiting on another guest that we were going to jump to next, but we will move
to, "BIP process updated".  Murch, I know in the write-up here we say that,
"After more than two months of discussion on the mailing list", although I think
the discussion has been going on much longer than that and your work on this has
been going on much longer than that, we have BIP 3.0 achieving rough consensus
over the Bitcoin Improvement Process.  Maybe folks have been following along,
but I think it would be good to have maybe a quick overview, you know, what is
BIP3; what does it change to BIP2; and what should people be aware of, big
picture?

**Mark Erhardt**: Right, so BIP3 is the new BIPs process.  It was proposed to
replace the old BIPs process, which was BIP2.  Many of the larger ideas remain
exactly the same, but there is a bunch of improvements and simplifications.  So,
for example, the number of statuses has been drastically reduced; we do not at
all track community sentiment or evaluation of the ideas in the BIPs repository
anymore, except when things have deployed on the mainnet, we will mark them as
being deployed.  There's a few changes to the formatting.  We do not require all
sections as we did before, but rather we leave it up to the audience, the
authors and the BIP editors to decide whether all of the necessary topics have
been covered and the BIP is comprehensive already.

Other than that, yeah, we replaced the Standards Track type with the
Specification type.  And the idea here is that we can tell whether something can
be implemented and if it can be implemented and you can be compliant to the
specification, then you have a Specification BIP; if it's about the BIPs
themselves, it's a Process BIP; and if it can't be implemented but is otherwise
interesting information for the Bitcoin community, it's an Informational BIP.
And yeah, so there is a section in BIP3 that details all of the changes compared
to BIP2.  And the document itself is also, well, maybe a little long to read,
but should hopefully cover aspects of the BIP process more comprehensively than
BIP2 did.

So, yeah, it is now active since Wednesday, or I should say 'deployed' per the
new lingo.  If you're writing a new BIP, please check out BIP3, follow the
guidelines of BIP3 to format your BIP and when to submit it.

**Mike Schmidt**: Well, congratulations, Murch, on getting that across the
finish line.  It seems like once you've sort of pushed for acts that nobody
really had anything to bring up in terms of objections, so I know it's been like
a two-year process for you, so nice job getting that across the finish line.
What happens with existing BIPs and BIPs that are also in progress now?  How did
you handle, or how is that being handled?

**Mark Erhardt**: Yeah, in the activation PR, I updated all of the existing BIPs
so that the status fields would be right, the changes to the preamble would be
applied, and so all of the published BIPs are already updated to the formatting
of BIP3.  The ones that are currently in flight, the author should probably take
a look whether they're already updated or not.  They might need to make a few
small tweaks to the preamble.  The CI has been updated, so if you make any
changes to your PR, the CI will also point out if there's any formatting
discrepancies.  There's a few follow-ups.  We had a big number of informational
BIPs that always confuse people that they were informational, because they
mostly are about interoperability between different projects, and so forth.  So,
for example, I believe BIP32, the derivation of keys from a main secret in a
wallet, the hierarchical deterministic wallets if you will, is marked as
informational and that doesn't make sense, because if people derive keys
differently, that wouldn't make it very interoperable and wallets wouldn't be
able to use backups or mnemonics of other wallets, right?

So, one of the follow-ups that is still open is that I want to go through the
existing BIPs and propose that some of them be moved to Specification BIPs.  And
then, we've had a big number of BIPs that have been in draft for many years, so
I would like to follow up on those and reach out to the authors, ask them
whether they're still working on it.  Sometimes, really, they just haven't been
updated in a long while.  Some of them have been adopted and are deployed to
mainnet, so they should be updated to a more proper status.  Some of them are
complete, as in there's no additional work that needs to be happening there.
They're proposed basically to the community as an idea and should just be marked
as such.  And then, there's a few drafts, I think, that just have been abandoned
and that are not being pursued anymore, and maybe we can close those.

**Mike Schmidt**: There is a section titled, "Changes from BIP2".  So, if you're
curious and you just want to know sort of the delta, the tl;dr delta between
BIP2 and BIP3, check out that header in BIP3 and you can very quickly be up to
date.  There's a series of a couple of dozen bullet points here that Murch put
in to get you up to date.  Anything else, Murch?

**Mark Erhardt**: No, that's all.  I'm very happy it's finally done and
deployed.  So, yeah, happy to get on to another thing.  Although that might be
partially follow-ups to the previous one.

**Mike Schmidt**: Of course.  Releases and release candidates.  Gustavo's here
with us and he can walk us through the Releases and release candidates and
Notable code and documentation changes.  We do have one potential appearance
from a PR author.  Maybe we will skip his item in case he joins us and is able
to walk through that, since he'll do a great job of talking about his own PR.
But in the meantime, Bitcoin Core 30.2, Gustavo.

_Bitcoin Core 30.2_

**Gustavo Flores Echaiz**: Thank you, Mike.  Yeah, so this week we have two
releases.  The first one is Bitcoin Core 30.2, which as we've talked in the last
two episodes, fixes a bug where the entire wallet's directory could be
accidentally deleted when you were migrating a legacy wallet that was unnamed
and that migration failed.  You can check out the Newsletter #387, or listen to
our past episodes for more details on that.  So, on the last newsletter we
covered that the RC for this release was announced, but in this newsletter we
finally announce that the maintenance release is official.  It also had some
release notes if you want to look at all the details, but the release was mostly
focused on fixing this issue and other improvements, but the focus was this.

_BTCPay Server 2.3.3_

So, we also have BTCPay Server 2.3.3, which is a minor release but has a very
interesting feature that we will cover later in the Notable code and
implementation changes, which basically allows you to create PSBTs, unsigned
PSBTs, that you can sign on external devices.  And you also have a new API
endpoint that allows you to upload these signed PSBTs.  So, basically it
introduces cold wallet transaction support, not only to BTCPay Server, but
specifically through BTCPay Server's API, the Greenfield API.  Other changes
include removing CoinGecko-based exchange rate sources, so BTCPay Server, in the
release notes you can see that now using this API mandates the use of an API
key.  It used to be an open API and now you require a key, so it is phased out
from BTCPay Server because of that.

_Bitcoin Core #33819_

Okay, so we can now move on to the notable code and documentation changes.  We
have two on Bitcoin Core.  So, the first on Bitcoin Core is, there's two commits
on this PR #33819.  What the first commit does is that it simply renames a
function called getCoinbaseTx() to getCoinbaseRawTx().  And the reason why this
is renamed is because we want to free up the name for the second commit where
the previously used name, getCoinbaseTx(), is introduced as a new method to
replace the previous method.  So, the problem with the previous method that is
now called getCoinbaseRawTx() is that it would feed clients a dummy coinbase
transaction that they would have to deserialize to then be able to create their
own coinbase transaction.  The new method instead provides a structure that has
all the fields required to recreate your own coinbase transaction.  So, this
just makes the process simpler for clients, specifically Stratum v2 clients that
are creating their own block templates.  They can use this method to more easily
create coinbase transactions.

So, for example, the fields we can find in this structure are the version
number, the sequence, the witness, optional, and other fields, as well as
locktime, required outputs, block reward remaining.  So, anyways, this just
makes simpler the creation of a coinbase transaction using this new method.  The
previous method that is renamed is deprecated alongside another two methods that
depended on it called getCoinbaseCommitment() and getWitnessCommitmentIndex().
Any thoughts, additional comments here?  No?  Perfect.

**Mark Erhardt**: I think the sequence is fixed, right?  In coinbase
transactions, you always have to use the same sequence value?

**Gustavo Flores Echaiz**: Yes, that's right.

**Mike Schmidt**: All right, sorry, just that threw me off for a moment.  Okay,
cool.  So, basically we're moving aside the RPC call that gave the raw tx as
serialized for the network, and instead we return a structure with all the parts
of the coinbase so you can edit it yourself.  This is supposed to be better for
Stratum v2, where people might want to mine at home and bring their own
coinbase.

**Gustavo Flores Echaiz**: Exactly.  An incremental change to improve the
experience of external Stratum v2 clients.

_Bitcoin Core #29415_

**Mike Schmidt**: Maybe you can walk us through Bitcoin Core #29415, "Broadcasts
own transactions via short-lived Tor or I2P connections", which seems
super-useful for people.

**Gustavo Flores Echaiz**: Yes.  So, this is a PR that has been worked on for
multiple years, well, at least almost two years.  It was opened in February 2024
and it was merged last week, so about two years.  Basically, what happens here
is that Bitcoin Core will create short-lived Tor or I2P connections when
broadcasting a transaction using sendrawtransaction if you activate the new
boolean option, privatebroadcast.  And this means that every time you make a new
transaction, it will use another connection so that your transactions cannot be
linked between themselves.  And it will change connections for every different
transaction.  So, not only you're concealing your IP address because you're
using the Tor or I2P connections or the Tor proxy when you're connecting to IPv4
and IPv6 peers, not only you're concealing your IP address, but you're also
using separate connections every time you broadcast a transaction using the
sendrawtransaction RPC, and that's really the value here.  It's the short-lived
connections that you do when broadcasting the transactions, and this is what
prevents linkability between these transaction broadcasts.  Yes, Murch?

**Mark Erhardt**: Yeah, so one of the big concerns privacy-wise for Bitcoin
operators is when they send their own transactions, all of their peers realize
that they receive a new transaction for the first time from the originator.  And
if someone is running many nodes on the network, as we know some network
surveillance do, they will be able to pinpoint who the originator of a
transaction is.  This PR addresses that problem by instead of broadcasting new
transactions to all of its peers, it makes random connections with private
network options, like I2P and Tor, it just spins up a new node connection, sends
the transaction, pings, waits for the pong and disconnects.  So, it basically
teleports the transaction to some other node in the network, and after that,
waits for a moment and sees if the transaction organically comes back.  If not,
it'll do it again.  It'll ping several peers over time and just make the
super-private connection, give them the transaction, immediately disconnect
again until it sees the transaction be broadcast around in the regular network.

So, it stores, it puts sort of its own transaction on the ledge, and its peer
manager notes that it has sent it to certain peers.  But only when it comes back
on the regular network, it broadcasts it to everyone, just as if it had received
a foreign transaction.  So, this completely decouples the originator of the
transaction from where the transaction first appears on the network.  And yeah,
this has been a super-long project.  I think this is at least the second
approach to this.  And I'm personally pretty excited because this had been such
a privacy hazard for a long time, that we see this huge improvement to it.  I
was going to ask a few follow-up questions of Vasil, but unfortunately we don't
have him here today.

**Mike Schmidt**: Well, me as well.  Maybe, Murch, I can ask you one that's
maybe a bit more high-level that came to mind with this PR.  So, Dandelion had
its own problems, but it sort of tried to solve the same issue, right?  Does
this obviate the need for something like an improved Dandelion, like is this
considered a solved problem now, broadcasting, if people use this?

**Mark Erhardt**: I think this is better than Dandelion, yes.  Basically,
Dandelion still had the problem that you were asking your peers to participate
in essentially a conspiracy against the network, "Hey, I'm giving you this
transaction, but don't broadcast it, just forward it to someone else".  Of
course, the neighbor didn't know whether they were the first hop or the third
hop in this stem phase of Dandelion, but you still leaked the originator of the
transaction to at least one peer.  In this case, yes, the recipient knows, "Oh,
this is an ephemeral new private connection.  Clearly, this is coming directly
from the originator to me".  But because of how the connection is being made,
they can't actually tell who the originator is in clearnet; they don't learn the
IP address.

So, I think this takes the idea that led to Dandelion, "We want to obfuscate who
the originator of a transaction is", and improves on it by basically just
inserting the transaction on some random points on a network until it is
properly broadcast.  And it gets rid of the concerns with the stem phase, where
Dandelion required you to have separate mempools for every peer to facilitate
these stem phases.  And now, you just remember who you sent a transaction to,
but there is no multi-hub, there is no keeping track of who you told about
transactions in the stem phase or whether you saw them later.  It's binary
basically, "Have I seen the transaction?  Then I can broadcast it.  Otherwise, I
remember who I sent it to".

Yeah, I think my follow-up was, how does this work for transactions that linger
for a while in your mempool?  Because currently, nodes would rebroadcast
transactions every 24 hours.  I hope that this would also happen with the
privatebroadcast mode, but I was gonna ask Vasil that.  Maybe if someone knows,
you can reply in our Twitter thread with the answer.

**Mike Schmidt**: Murch, does this PR broadcast a transaction in this ephemeral
Tor connection to a handful of nodes?  It's not just 'send it out to one and
hope it works', right, it's 'send it to many'?

**Mark Erhardt**: I mean, maybe Gustavo knows more details, but my understanding
is that it'll keep doing this a few times, or until it sees its own transaction
come back through regular transaction broadcast.  So, the PR said somewhere that
it takes roughly one second for transactions to come back organically.  So, if
you just start private broadcast and every two seconds or so, redo it with a new
peer, eventually it'll work, I think, and you would limit how many of these
ephemeral connections you have to make.  The concern here would be, of course,
if you give a transaction only to a single peer, they might blackhole it instead
of forwarding it; they might be a spy node; or just blocks only, or something.
So, you want to be able to send it to multiple peers, and that happens this way.
This was also a concern with Dandelion, which was much harder to solve then.

**Mike Schmidt**: Yeah, and if you're not sending to multiple nodes, I guess it
would look like it could potentially be originating from the node that you
happen to send it to the first time.  Although I guess as this becomes more
prevalent on the network, then no one's going to really trust that the node that
is sending out early versions of these transactions is the node that is the one
originally broadcasting it.  Okay, anything to add Gustavo?

**Gustavo Flores Echaiz**: Yeah, just to say that the nodes do say that it is
sent to multiple peers.  However, I'm not sure to know if it does try one and if
it doesn't get a response and it tries another; or if it just tries multiple at
a time and then if it has a general response, it tries more.  But it does try
multiple peers, and it will keep doing that until it receives confirmation it
receives back the transaction and goes through the normal flow of propagating a
transaction.

**Mark Erhardt**: Oh, I have maybe one little follow-up on Dandelion.  I didn't
explain very well why it was complicated with mempools on Dandelion.  So, when
you broadcast a transaction and it has two phases in Dandelion, first the stem
phase where every peer just forwards it to one more peer, and then the fluff,
where someone randomly then decides to broadcast it.  And the problem here was
everybody along the way had to basically keep track whom they got the
transaction from so they wouldn't send it back to the same one, and who they
sent it to, and then behave differently regarding that transaction until they
saw it back to the network.  Like, they would pretend not to have seen the
transaction.  But with this approach that we now actually have in Bitcoin Core,
you don't have to pretend.  It's just as soon as you get it on a network, you
use it as if it were a foreign transaction and you had seen it for the first
time.  And everybody that you broadcast it to just treats it as a new
transaction they received.  So, there's none of the special behavior and you
don't have to have extra mempools for every peer.

_Core Lightning #8830_

**Gustavo Flores Echaiz**: Thank you, Murch.  So, we will forward with Core
Lightning #8830.  Here, there was an issue that was detected that in the past
release version of Core Lightning (CLN), a new method to backup wallets was
introduced, which basically introduced BIP39 mnemonic 12-word seed phrases.  And
that release introduced the functionality to recover from those 12 words.
However, it didn't introduce the changes required to recover from your HSM
secret file that had a new structure, because it had a new way of backing up
wallets.  So, this PR, #8830, what it does is it introduces a new function
within hsmtool that will work with previous formatted HSM secrets and newly
formatted HSM secrets.

So, what it does, this new getsecret method, is that it replaces the old
getsecretcodex method, and it will work with both types of nodes, either the
previous nodes or the modern nodes.  And on the modern nodes, it will output the
12-word seed phrase from your hsm_secret file.  After that, once you have that
12-word seed phrase, you can use the recover plugin that is also updated to
accept these mnemonics that are issued to these new node versions.  So,
basically, this PR implements all the functionality required for you to recover
your node, either from your 12-word seed phrase or from your hsm_secret file
that has a new structure that the previous methods weren't able to read.  If you
want to look more into the new version of CLN, you can check out our Newsletter
#383 or the episode that came with it.

_Eclair #3233_

We follow up with two Eclair PRs, the first one, #3233.  This is a very simple
one where the issue fixed here is that when you are using Eclair on either
testnet3 or testnet4, Bitcoin Core would fail to estimate the fees due to
insufficient block data.  So, now, Eclair starts using the configured default
feerates in testnet3 and testnet4 when it doesn't have sufficient data.  It will
use those configured feerates, and this PR also updates the default feerates to
better match current network values.  So, for example, the minimum was
previously 5 and now it's 1.  So, in general, every default feerate is decreased
and they're measured in satoshis per byte.  Yes, Murch?

**Mark Erhardt**: So, specifically, Bitcoin Core would not be able to estimate
feerates if it doesn't have current mempool data or if it just spun up, right?
The way Bitcoin Core estimates feerates is by watching what came into its
mempool and what got mined.  And then, from the things that it saw previously in
its mempool and then appear in a block, it estimates what the correct feerates
are.  So, if you don't permanently run a testnet node and you're trying to get
fee estimates from the node, spinning up a new node will not be able to give you
accurate fee estimates until it's run for a few hours.  So, they basically just
engineer around this problem by having default feerates in testnet3 and 4.

**Gustavo Flores Echaiz**: That's exactly right, Murch.  I would just add that
the problem is also that, for example, in testnet4, the blocks are often just
empty, and Bitcoin Core just doesn't have the data.  Even if it's properly
synced, it just doesn't have the data because most of the blocks are empty.  And
also, the issue that is fixed, issue #3105 in Eclair, also mentions that there's
a configuration option in the Bitcoin configuration file called fallbackfee, and
they tried that and that doesn't work.  So, the solution has to be to add a sort
of fallbackfee in the Eclair configuration file to be able to solve that in this
situation.  Yes, Murch?

**Mark Erhardt**: Wait a minute.  So, if blocks are empty, feerate estimation
just doesn't work at all anymore; is that so?  I'm asking seriously.  I hadn't
considered that, but sure.  This isn't something we anticipate on mainnet, I
guess.

**Gustavo Flores Echaiz**: Right, exactly.  Well, this is what the issue PR
says.  To be honest, I didn't verify if that's the way exactly how Bitcoin Core
code works.  I just assumed that the PR description was valid on that, but it
does kind of make sense.

**Mark Erhardt**: I would have assumed that if it's just all empty blocks, it
would just eventually say a minimum feerate.  But I guess if we're basing our
estimations on transactions that are getting confirmed, you can't distinguish
empty blocks from people just mining empty blocks, even though there are
transactions there or no transactions existing.  So, I guess that's an
interesting case that only applies to testnet.

_Eclair #3237_

**Gustavo Flores Echaiz**: Yeah, definitely.  So, we follow up with Eclair
#3237, where the channel lifecycle events are basically updated to be compatible
with both splicing and consistent with zero-configuration channels.  So, two new
events are added, one called channel-confirm and another one called
channel-ready; and another, called channel-opened, is removed.  So, basically,
here the idea is to consider that, for example, when you have a
zero-confirmation channel, you will be ready for payments before your channel
funding transaction is confirmed.  So, this is why there has to be a separation
between these events, because in the zero-configuration case, the channel-ready
would actually happen before channel-confirm.  And however, in most other cases,
the channel confirms before being ready.

What does exactly each mean?  Well, channel-confirm, as the name kind of
signals, it means that the funding transaction is confirmed, and this is also
updated to be emitted once a splice transaction confirms, which previous event
life cycles didn't properly consider for the splicing case.  And channel-ready
for payments means that the nodes have exchanged the message, channel-ready,
when the channel is created or splice_locked when it's a splicing transaction,
which means that they've communicated between themselves on the Lightning
Protocol that they're ready to use the channel.  So, the channel-opened, which
was actually a subset of channel-ready, is removed because it kind of lost its
use case.  Any thoughts here?  Perfect.

_LDK #4232_

We move on with LDK #4232.  This is something we covered in the past newsletter
for both Eclair and LND, and now it has arrived to LDK as well.  So, here what
happens is the support for the experimental accountable signal which replaces
HTLC (Hash Time Locked Contract) endorsement, as proposed in both BOLTs #1280
and BLIPs #67, these two are the PRs that update the specifications for the new
accountable signal protocol that replaces HTLC endorsement.  And as we mentioned
in the past episode, basically the reason why this happens is because the HTLC
endorsement would kind of try to punish nodes that were sending the
transactions.  If their transaction later failed, HTLC endorsement, the goal was
kind of to spot and punish those nodes.  However, those nodes are not
responsible or cannot be held liable because the HTLC fails later downstream,
and is often the result of another's node.

So, the accountable signal instead, what it does is that it basically, once it
forwards a payment, it will take into account the peer it's forwarding to.  And
if it fails, it will hold accountable the downstream peer to which it is
forwarding the HTLC.  So, LDK implements this in a way where it will signal
zero-value accountable signals on its own payments and on forwards that have no
signal, but if it's forwarding an HTLC coming from a peer, let's say from an LND
or Eclair node, that has actually added an accountable signal, it will copy that
incoming value and it will forward it as well.  So, if you want to know more
about the implementations in LND and Eclair, you can check out the Newsletter
#287 or the episode that came with it.  Any extra thoughts here?  Perfect.

_LND #10296_

We have three final PRs to cover.  The next one is LND #10296.  This is a very
easy one.  There's an RPC command called EstimateFee.  And this PR, what it does
is that it adds an inputs field to the command so that you can get a fee
estimate using specified inputs.  So, previously, you would use this RPC command
with the destination address and the amount you want to send to that address,
and LND would select automatically the UTXOs to add to the transaction, and it
would estimate the fee based on that automatic UTXO coin selection.  Now, this
PR allows a user to specify which inputs they want to add to this transaction to
be able to estimate the fees based on a coin control configuration.  This
doesn't mean that LND didn't have previously already implemented coin control.
It did.  However, this means that when it estimates fees, it can estimate fees
for specific inputs instead of just letting the wallet select them
automatically.

_BTCPay Server #7068_

We move on with BTCPay Server #7068.  This is the PR that I was mentioning in
the Release section that is the main change brought into the new release of
BTCPay Server.  Here, basically what is done is this PR allows users to generate
unsigned PSBTs, and this isn't done through a new API.  Instead, it modifies an
existing PR and it creates, let's say, two edge cases, one where the keys to
sign the PSBT exist within the BTCPay Server wallet.  So, if the keys exist to
sign the PSBT, BTCPay Server will simply sign the PSBT and issue a signed PSBT.
If the keys don't exist, then BTCPay Server will issue an unsigned PSBT that you
can sign remotely with an external key, and also a new endpoint is added to
broadcast these externally signed transactions.

The description of this PR basically comments that the benefits here are to use
BTCPay server in setups that have stricter regulatory requirements.  So, they
have a discussion quoted in the PR description.  Probably some users had
requirements related to allowing for external key signing through the API.  But
in general, this is just, at the same time, better security and in automated
environments, because this was already allowed in BTCPay Server.  It's just
brought into the API to allow automated environments to execute transactions
with greater security.  Perfect.

_BIPs #1982_

So, the last PR of this newsletter is BIPs #1982, which adds BIP433 that
specifies a new standard output type called Pay-to-Anchor (P2A), which was
previously already implemented in Bitcoin Core, but is now added as a BIP so
that other implementations can get ahead and implement it in the same manner as
well.  Yes, Murch?

**Mark Erhardt**: I just wanted to say, basically it publishes the BIP to the
BIPs repository, adds in the sense of it is now published.  So, this is
currently in draft status, but I assume that it will be moving pretty quickly to
deployed because it's actually already being used on the network.  The BIP was
written because a lot of Lightning implementations do want to use anchors and it
was considered useful for there to be a specification in a widely accessible
way, and that's this BIP now.

**Gustavo Flores Echaiz**: Thank you, Murch.  We covered the addition of P2A
through a Bitcoin Core PR.  Anyways, just to say that I cannot find the specific
number, but just to say this was previously implemented in Bitcoin Core.  Yes,
in the PR #30352.  So, you can check that if you want to look more into the
implementation details of P2A.  But the BIP433 text also documents and specifies
the requirements for implementing P2A as a standard output type.  And the
creation of these P2A output types has been standard for multiple versions
already.  The significant change brought on to the Bitcoin Core #30352 is the
spending of these outputs.  The creation of this output type was already
standard before that implementation.

**Mark Erhardt**: Right, because we consider all native segwit outputs, even of
future versions or any lengths that are not encumbered yet, as standard outputs.
But for the spending them, that is non-standard until it's introduced.  Support
for P2A was added in Bitcoin Core 29.0.  So, that's been out for, well, nine
months or so.

**Gustavo Flores Echaiz**: Thank you, Murch.  And that completes the code and
documentation changes section and the whole newsletter.

**Mike Schmidt**: Awesome.  Thanks, Gustavo.  And we also want to thank Bruno
for joining us earlier.  Unfortunately, Vasil couldn't make it, but we hope we
did his PR justice.  Thank you, Murch, for co-hosting as well, and you all for
listening.  Cheers.

**Gustavo Flores Echaiz**: Thank you.

**Mark Erhardt**: Cheers.  Hear you soon.

{% include references.md %} {% include linkers/issues.md v=2 issues="" %}
