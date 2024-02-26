---
title: 'Bitcoin Optech Newsletter #272 Recap Podcast'
permalink: /en/podcast/2023/10/12/
reference: /en/newsletters/2023/10/11/
name: 2023-10-12-recap
slug: 2023-10-12-recap
type: podcast
layout: podcast-episode
lang: en
---
Mike Schmidt is joined by Steven Roose and Gloria Zhao to discuss [Newsletter #272]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-9-12/350856559-44100-2-071780dcaee98.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #272 Recap on
Twitter spaces.  Today, we're going to be covering the newsletter items
including a draft BIP for the OP_TXHASH opcode; a PR Review Club meeting
summary, discussing preventing type safety bugs in Bitcoin Core; some merged PRs
that finish the first phase of the assumeutxo project; some recently merged PRs
around BIP324, encrypted communication between nodes; and a PR allowing
submitting packages of transactions outside of just regtest in Bitcoin Core; and
more.  I'm Mike Schmidt, I'm a contributor at Optech and also Executive Director
at Brink, where we fund Bitcoin open-source developers.  I don't think Murch is
going to be able to join us today, but the good news is that we are pleased to
be joined by some very special guests to discuss this newsletter.  Steven, you
want to introduce yourself?

**Steven Roose**: Sure.  Hello, I'm Steven, Bitcoin developer.  Been at
Blockstream for the last five years or something, currently on sabbatical.
Excited about developments around covenants.  Yeah, lots of things are
happening, so excited to talk about that.

**Mike Schmidt**: Gloria?

**Gloria Zhao**: Hi, I'm Gloria, I work on Bitcoin Core.  I'm sponsored by
Brink.

**Mike Schmidt**: And we did promote that James O'Beirne would be able to make
it.  I know his schedule's a bit up in the air, he may not be here, but we can
speak to the assumeutxo project on his behalf when we get there, if that's the
case.

_Specification for `OP_TXHASH` proposed_

First item from the newsletter is a news item talking about the specification
for the OP_TXHASH opcode.  Steven, you posted to the mailing list about a draft
BIP you've been working on that proposes two new opcodes, OP_CHECKTXHASHVERIFY
and OP_TXHASH, that specify a basic transaction introspection primitive.  Maybe
we can start there.  Maybe you can give us your definition of what is a
transaction introspection primitive.

**Steven Roose**: Good question.  I guess an introspection primitive is anything
inside Bitcoin consensus rules that gives a spender of a transaction some way to
look at the transaction itself and what the transaction consists of, right?  So
something like CHECKSEQUENCEVERIFY or CHECKLOCKTIMEVERIFY also gives you some
limited introspection to look at sequence numbers of inputs and locktime values
of transactions.  And what OP_TXHASH or OP_CHECKTXHASHVERIFY are trying to do is
to generalize that and give you introspection in a limited way to the entire
transaction, everything related to it.

**Mike Schmidt**: So, what can we do if we can look at the transaction using
some of these opcodes, maybe some use cases that could be advantageous for
users?  I know you mentioned a couple of examples of motivation and types of use
cases.  You said it's useful to reduce interactivity in multi-user protocols;
it's useful to enforce some basic constraints on transactions.  Maybe we can
translate those two categories of motivations into something that folks can
maybe feel is a bit more tangible.

**Steven Roose**: Sure.  So, maybe wind back a little bit.  Another proposal
people are probably more familiar with is called CHECKTEMPLATEVERIFY (CTV),
which is in summary a more limited version of CHECKTXHASHVERIFY verify.  So,
this will give you introspection into the entire transaction summarized into a
single hash, while TXHASH lets you pick out more specific parts of the
transaction.  So, anything that is a use case of CTV can be done with TXHASH as
well.  These spaces include parts of what vaults would do.  So for example, in
most of the vault constructions, you need to actually look at what the
transaction is doing and enforce some basic constraints on this transaction are
met, for example, that it has relative timeouts, some things like that.  TXHASH
cannot do that on itself, but you would need that in almost any vault
construction.  This is why OP_VAULT also includes CTV.

Other things you could do with TXHASH is just general enforcing that certain
addresses are being paid, certain -- yeah, so that your transaction sends money
of a certain amount, a certain value, without needing the users involved in the
transaction to actually put signatures on the transaction.  Yeah, I don't know
what more specific use cases you'd like to go into.

**Mike Schmidt**: Maybe in terms of -- sorry, go ahead.

**Steven Roose**: Something that it can do is like the traditional ANYPREVOUT
(APO) or Eltoo or LN-Symmetry stuff, because in those models that are currently
being built for that, actually a signature is still required, a signature that
we currently can't have.  But OP_TXHASH could serve as a segue into allowing
those things when it would be combined with another opcode; it's called
CHECKSIGFROMSTACK.  So, if we would have this opcode called CHECKSIGFROMSTACK,
which checks the signature not over the transaction, but over any value that is
put on the stack in the Bitcoin script, together with TXHASH, this could enable
all kinds of different signature hash (sighash) improvements, like ANYPREVOUT,
ANYSCRIPT, or things like SIGHASH_GROUP or SIGHASH_BUNDLE, as it's been renamed;
I don't know which one is the latest name.

So, if you have a generalized, "Pick certain fields of this transaction and hash
it", and you can have something else like, "Sign over this message that is the
hash of these fields of this transaction", you have a very powerful construction
to do almost all of the things we're currently talking about that covenants
would give us.

**Mike Schmidt**: You mentioned in the write-up, "The construction specified in
this BIP can lay the groundwork for some potential future upgrades".  And you
mentioned one of those with the OP_CHECKSIGFROMSTACK, I think you also mentioned
OP_TX.  How do you think, as someone who's proposing this -- those would be
future, but these two opcodes that you propose being current, how do you think
about excluding those and making them a future upgrade versus including them in
this original proposal?

**Steven Roose**: Yeah, so they're not really included in the proposal.  So, I'm
not trying to propose a soft fork activation specifically, just a specification
for the opcodes, and then other opcodes could be specified in different
specifications.  Then I'm hoping later on to bundle one or two or more of these
opcodes into an actual soft fork proposal.  So, like you can see in the BIP,
there's no activation mechanism, there's no BIP9 deployment specified or
anything, it's just the specification of the opcodes.  And hopefully later on,
we can either bundle this with CHECKSIGFROMSTACK or do separate soft forks for
all the different opcodes.  That will depend on the politics and how people like
these opcodes and how people like the other opcodes that are not included in
this BIP.

**Mike Schmidt**: That makes sense.  There was a section from the writeup as
well titled Open Questions.  Are there one or more of those that you'd like to
highlight for the audience in terms of things that still need some
investigation?

**Steven Roose**: If you could remind me, because I've been working on these.  I
think one of them, for example, was the resource usage.  So, I had some
conversations with AJ or other people on the Delving Bitcoin forum, and I think
in the latest version of the BIP and in an MR that I drafted for Rust Bitcoin, I
found a caching strategy for TXHASH that would alleviate all quadratic hashing
concerns, make sure that all large parts of the transaction are only to be
hashed once, and then any invocation of the OP_TXHASH opcodes has kind of very
clear bounds on how much data is ever going to be hashed, if you use the caching
strategy that is outlined in the implementation.  I'm planning to add a more
detailed description of this caching strategy into the BIP, but first of all I
had to figure out if it was possible.

So yeah, one of these concerns, one of these open questions I have already, I
think, worked on, and if you could remind me what the other one was?

**Mike Schmidt**: Yeah, the first one was, "Does this proposal sufficiently
address concerns around resource usage and quadratic hashing?"  And then the
other two, well, there's one that was more general feedback about how people
feel towards a proposal like this, which I guess is more general feedback and
less technical; but you noted being implemented as a soft fork as is, like
BIP119, or combined in a single soft fork with CHECKSIGFROMSTACK, which you kind
of touched on already.

**Steven Roose**: Yeah, so exactly.  What I did in the last week or two was, the
BIP specifies two different parts, right?  So, it specifies a general
construction that I call the TxFieldSelector, which allows you to basically
select different parts of the transaction that you want to include.  But this is
a general construct and it can be used with TXHASH, but it could also later on
be used for, for example, something like OP_TX or a sighash type.  And I wanted
this construction to be as powerful and as useful as possible, not only for
template checks like OP_TXHASHVERIFY, but also later on for usage with
CHECKSIGFROMSTACK.

So, I added some other things that are not necessarily useful when checking
transaction templates, but are more useful when doing something like sighashes,
so for example including the control block of the current input, including the
last OP_CODESEPARATOR position of the current input, and having a shortcut for
something like a SIGHASH_ALL, which currently is not the default value for the
CHECKTXHASHVERIFY, so that this construction is very general and is, not to say
all encompassing, but that it actually can include all the things we can
currently think of.  And then this construction can be used, maybe, across
different opcodes and different uses.  So, that's what I've been working on
mostly, and then an implementation, a reference implementation, and a caching
strategy for all this.

**Mike Schmidt**: Looking at the mailing list and also the draft PR that you
have to the BIPs repository, there is no commentary there, but you mentioned
that there's been some back and forth on the Delving Bitcoin forum potentially,
and you've probably gotten maybe offline feedback as well.  So, what sort of
feedback have you gotten that you care to share?

**Steven Roose**: So, I would like to mention, there's this other guy, I don't
know his real name, but his pseudonym is Rearden Code, who's proposing something
very similar to this, basically an upgrade to CTV that instead of allowing you
to mix and match different fields of transaction, has some specific predefined
combinations so that they are more tailored to specific use cases and they would
consume less bytes.  And so, I've been having some back and forth with him about
the benefits and the drawbacks of both of these alternatives.  And generally, I
think the feedback has been quite positive, given that people don't seem to like
APO all too much and CTV seems to have been blocked for a long time, which was
mostly my motivation for this proposal.

I think Russell O'Connor came up with this idea of OP_TXHASH almost, or even
more than two years ago, but no one ever really did the work to specify how this
could or would look.  And so, what I did was try and do this because a lot of
commentary I've heard of CTV is that it's not powerful enough and it's actually
very annoying in most of the things people say that it can be used for.  So,
with TXHASH, it would alleviate most of these concerns of CTV, while also
opening the way towards an alternative to APO, ANYPREVOUT, that people might
like better, instead of using a sighash flag for that, doing something like
TXHASH plus CHECKSIGFROMSTACK.  So, I think that the feedback has been mostly
positive, yeah.

**Mike Schmidt**: Anything else that you think the audience should be aware of,
or any calls to action for the audience?  I know you have a detailed
specification here in Rust, you obviously have the BIP open for commentary in
the mailing list.  Anything else that you'd like folks to take a look at or
provide feedback on who are listening?

**Steven Roose**: I would say anyone who's technical, it would be very helpful
to look at the exact specification of the TxFieldSelector, and to see if there's
any combinations that people could think of that are useful that I forget.
Mostly what I think I will be doing next is, people have been asking me, "Give
us some use cases, show that this is useful and show what this can do".  And so,
I think I'm going to try and build some summary website where it goes over use
cases that people talked about and how this could be achieved with this, because
it seems that in our current landscape, any proposal needs to have its own
website and show its merits to the people.

So yeah, if you have use cases that could be used by this, definitely let me
know somewhere, either in the mailing list or in the forum.  If you have
questions, if this could be used for a certain use case you have, definitely
ask, and then we can take it through.  I think this is the most useful feedback,
like use cases and concerns about this proposal.

**Mike Schmidt**: Is there work that's been done on OP_TXHASH with regards to
elements and the Liquid Network, or are you looking for this strictly in a
Bitcoin sense?

**Steven Roose**: Yeah, this is mostly Bitcoin related.  Liquid has recently
added some real peer introspection opcodes that basically give you insight in
different fields of the transaction without needing to hash them.  So, I don't
think Liquid needs something like TXHASH because it's more limited than what it
already has.  So no, I don't know of any plans for Liquid to include this.  This
is mostly just a Bitcoin thing.

**Mike Schmidt**: Greg Sanders has a question or comment.

**Greg Sanders**: Yeah, I just have a question.  So, I've talked to you a little
bit offline, but I think it's good to talk about it out loud.  What doesn't this
do that something like OP_TX or Liquid introspection can do; what are the
limitations here?

**Steven Roose**: That's a good question, because it depends on other things.
Like currently, there's almost no limitation, there's almost no difference,
because if you want to do useful things with something like direct introspection
or OP_TX, you almost always need something to manipulate data as well.  So, you
need either 64 bits arithmetic to do useful things with values, or you need
OP_CAT to do useful things with script buffers.  So without CAT or 64-bit
arithmetic, I think OP_TXHASH or OP_TX or direct introspection is kind of the
same in sense of use cases.  But ideally, we would get over our fear of OP_CAT,
especially now with the whole BitVM thing being released recently.

Maybe if we can get OP_CAT and 64-bit arithmetic, then obviously direct
introspection is more useful.  Then you would totally be able to replace, for
example, OP_VAULTS, you can actually look at values from the input and values
from the output and do math on that and then have checks on that.  But without
those things, there's currently no difference.  I think we get all the inputs,
all the values you want to check.  If you can't do math, you can just put on the
stack through the witness or through the script.  Does that make sense?

**Greg Sanders**: Yeah, so I think I haven't sketched it out exactly, but I
think you can do very, very limited vaults with TXHASH, but there wouldn't be
any batching, right, so this idea that you could introspect input values
directly to do math on them and assert outputs.  But there's still limited ways
this can be used.  So, I think that's kind of where it's basically, in some
cases, like you can do less efficient but similar things, right?

**Steven Roose**: Yeah, exactly.

**Greg Sanders**: That makes a lot of sense because once you talk about
numerical opcodes, that's another can of worms to open.

**Steven Roose**: Exactly!  So, just for the audience, I think what you're
talking about is that with TXHASH, you can pick any value of the transaction,
right?  So, something you can do is say, "Pick the value of the amount of the
input at index zero and get the amount"; and then with another OP_TX, you can
say, "Get the amount of the value of output zero".  And then you can check that
the hashes are the same.  So, you can't really look at the amounts itself, but
you can check that there's equality between the input and the output.  And
that's already useful, for example, for vaults without more advanced fee
handling or without, like you say, batching and bundling of multiple inputs into
a single output.

**Mike Schmidt**: Steven, thank you for joining us.  You're welcome to stay on
through the rest of the newsletter, or you're free to drop if you have other
things to do, but thank you for your time.

**Steven Roose**: Cool, thanks for having me.

_util: Type-safe transaction identifiers_

**Mike Schmidt**: Cheers.  Next section from the newsletter is our monthly
segment on a Bitcoin Core PR Review Club session.  This month, we highlighted
Type-safe transaction identifiers, which is a PR from Niklas Gögge, and it's
labeled in the repository as a util.  The PR aims to improve type safety by
introducing a new transaction identifier type with txid and wtxid.  Gloria, I
saw you had commented in the PR, "I've definitely written and seen bugs that
could be prevented if txid and wtxid were different types".  So, maybe given
your familiarity with seeing this as an issue, you can maybe outline what are
the potential pitfalls here and how does this PR begin to address that?

**Gloria Zhao**: Yeah, sure.  So, I mean this PR is mostly a refactor, but I
don't know, it addresses bugs that could be pretty bad, I think.  A uint256 can
represent actually three different types, so block hash and a transaction hash
of two different types, with or without the witness data, which is something
that we've had since segwit, of course.  And, yeah, I'm very happy to admit that
I've written bugs where I accidentally passed in the transaction identifier with
the witness, because that's usually a much safer way to commit to specify a
transaction to a function that assumes that it's a txid without the witness.
And we have a lot of those kind that were written before segwit existed, and
there was only one way to refer to a transaction.  Now that there is witness
data, that's almost always the best way to refer to a transaction, because you
want to avoid bugs where there are mutations of the same txid but with different
witnesses.

Yeah, I've seen a lot of bugs in review.  I've written a lot and fixed, where we
use a txid instead of a wtxid, or vice versa.  So, I think we've frequently
talked about just making it type safe, ie making two different types and
enforcing that only one of the two types is used, where it's meant to only
represent one of those two types.  And somebody finally wrote the PR and went
through the bikeshedding hell and frustrations of people saying, "Oh, this
changes so much code, etc".  But I think it can be very beneficial in the long
run in preventing bugs.  So, yeah, that's it.  We had a fun discussion about
type safety and compilers and whatnot during the Review Club.

**Mike Schmidt**: One thing that I thought was interesting, this was in one of
the questions from the writeup, but maybe it's good to call it out explicitly,
is that if a variable can represent three different things as you outlined, you
could potentially, as you gave the example of, parse in txid when wtxid is
expected, or vice versa, and the feedback mechanism to know if you're doing
something wrong there is you have to run it, right, and then see that an error
occurs in a certain scenario versus if you explicitly type these things, then
when you compile, you'll see a compile error before you even try to run any of
that.  Is that right?

**Gloria Zhao**: Yeah.  So, really common tests that I'll write is, like while
I'm fuzzing, for example, I'll create two transactions with the same txid and
I'll change the witness data, so they have the same txid, but they have
different wtxids.  And then I'll go through all the code paths and make sure the
data structure doesn't fall over if I have two transactions like this.  And that
catches the vast majority of bugs that I've written or that other people have
written, but it wastes a lot of time.  I've spent at least a few hours plumbing
a fuzzer crash, only to find that, "Oh, right, of course, they have the same
txid".  If the compiler just tells you right away, that can save a lot of time.

**Mike Schmidt**: I know you have to jump shortly.  One thing that I think would
be interesting for the audience is a two-part question.  One, what is the
transaction orphanage?  And I guess the follow-up relevant to this PR is, why is
that a good place to implement these type-safe transaction identifiers?

**Gloria Zhao**: Oh, yeah, sure.  So, while we are participating in relaying
transactions, sometimes we'll come across a transaction that spends an input
that doesn't exist to us.  So, it spends a UTXO, and we look that UTXO up in our
UTXO set and in our mempool, and it doesn't exist.  And that can be benign, so
that it could have an unconfirmed parent that we just haven't seen yet because
there's a race in downloading these transactions.  Or, we just came out of IBD,
and the parent was broadcasted while we were still catching up on chainstate.
And it could also be malicious, where someone is sending us garbage
transactions.  But either way, we put it in a memory-limited orphan transaction
pool.  It's an orphan because it's missing a parent.  And we use that to try to
hold on to this transaction while we try to download its parents.  And it's
quite an important data structure for package relays, just to throw that out
there.

Then your second question -- sorry, there's a dog following me, I don't know if
you can hear that!  The second part of why it's a good candidate for txid and
wtxid distinguish?  I guess it's one of those data structures where we might
need to look things up with either a txid or a wtxid.  So, when you look up a
parent that you're missing, you only know it's txid.  You don't know the witness
data, because it's in a prevout.  But of course, the vast majority of time,
we'll also look up things by witness transaction ID.  And so, I'm maybe not
articulating this very well, but I guess it's a data structure where we have
scenarios where we'll use either txid or wtxid, and we'll treat those uint256s
very, very differently.  And so we need to know what the type is, but we are
going to run into situations where we use both.

So, hopefully that answers the question, and it was also relatively well-scoped
in terms of number of lines touched.  So, that's probably also a reason why we
started with tx orphanage.  I don't know, you'll probably have to ask Niklas.

**Mike Schmidt**: I'll take an opportunity here to encourage folks who are
interested in the technicals to attend these meetings live when they happen, or
review them after the fact.  You have developers like Gloria in there asking and
answering questions related to the PR or unrelated to the PR; you have folks
like Larry Ruane, stickies-v, sipa is in there on this particular meeting, and
so it's a really great way to get their thoughts on how they approach looking at
these PRs, and there's lots of knowledge to be gained there.  So, if you find
yourself technically curious, I would again encourage folks to attend that.

**Gloria Zhao**: Yes, I would encourage, and people of all levels are welcome.

**Mike Schmidt**: Gloria, anything else that you would say about this PR Review
Club PR before we move along?

**Gloria Zhao**: No.

**Mike Schmidt**: All right.  Thank you, Gloria, for joining us and helping us
walk through that PR.  We're going to move to the Releases and release
candidates section of the newsletter.  We have two this week.

_LDK 0.0.117_

The first one is LDK 0.0.117.  We actually covered many of the PRs that rolled
into this release in the last month or so, including a few PRs related to
estimating liquidity in remote channels to facilitate better routing.  We talked
last week about the batch funding of outbound channels.  We talked a few weeks
ago about improved watchtower support, and there were also four anchor output
channel-related bug fixes in this release, including one that could potentially
lead to loss of funds.  So, take a look at the security section of the release
notes to review that particular potential loss of funds bug, as well as a couple
others related to anchor output channels.  And there's also a lot of PRs noted
in the release notes that we didn't cover in the last few weeks of the
newsletter.  So, check out the release notes for this release for more details
on that.

_BDK 0.29.0_

The second release that we highlighted in the newsletter was BDK 0.29.0, which
is a maintenance release.  There's two things that changed here.  BDK was
updated to use Rust Bitcoin 0.30, so updating dependency.  And there's also a
fix for a bug when syncing coinbased UTXOs on Electrum.  So, a bit of an edge
case there, but if you're somebody who could be impacted by that scenario, you
probably want to be upgrading.  So, that's BDK 0.29.0.

Moving to the Notable code and documentation changes.  As we go through these,
if anybody has questions, I see Steven is still here, instagibbs is still here,
so if you have any questions on what they were speaking about earlier or any of
these PRs, feel free to raise your hand, request speaker access, or leave a
comment, and we'll try to get to your question.

_Bitcoin Core #27596_

The first PR that we highlighted here was Bitcoin Core #27596, which finishes a
large part of the assumeutxo project in Bitcoin Core, which allows a node
operator to both use an assumedvalid snapshot and to do full validation sync in
the background.  And users can load a UTXO snapshot via the loadtxoutset RPC.
But we did note that this feature is not available on mainnet until activated.
Maybe I can use this opportunity to ask instagibbs if he has thoughts on
assumeutxo.  Anything to add, Greg?  Putting you on the spot.  Thumbs down.
Well, this was hopefully going to be a victory lap for James to come on and tout
the assumeutxo project and the great progress that was made, including this
being included in the next release.  Unfortunately, he was unable to make it.
Hopefully, we can get him on in the future to take his victory lap on the
project.

_Bitcoin Core #28331, #28588, #28577, and GUI #754_

Another important project that we've covered recently is the version 2 encrypted
transport from BIP324, and that is the next set of PRs that we highlighted from
the newsletter, which included Bitcoin Core #28331, #28588, #28577, and a
Bitcoin Core GUI PR #754, which adds support for encrypted communication between
nodes as specified in BIP324.  We had Pieter Wuille on to talk about BIP324 at a
high level.  This was in Newsletter #268 and our recap discussion on that.  So,
if you're curious as to his thoughts on it, jump back and listen to that one.
The feature is off by default, so you will not be speaking v2 encrypted
transport by default, but there is a -v2transport option to turn it on, if
you're running the latest Bitcoin Core version, and your node will then attempt
to negotiate encrypted transport with its peers if they also support v2
transport.

The GUI PR that is related to this implementation adds BIP324 specific labels in
the user interface, specifically on the peer details page.  There's no UI/UX
elements to turn on or off BIP324, you need to use that flag.  The GUI change
also includes output about the session ID.  So, if you do find a peer that
speaks v2 transport, you negotiate a session ID with that peer, which is useful
to compare with your peer if you happen to have communication with that peer,
and you can compare session IDs, which can be used to detect potential
man-in-the-middle attacks if those session IDs don't match.

So, take a look at that.  I know that's been a long time coming, there's been
multiple BIPs related to this sort of functionality, it's been several years in
the works.  It's great that this is in, and folks should take a look at that.
There will be release candidates that include this feature that I would
encourage everybody to take a look at.  And hopefully there will be also a
testing guide, including some of these features, so that everybody can test that
out on their own.

_Bitcoin Core #27609_

Another big project-related PR, Bitcoin Core #27609.  Unfortunately, Gloria had
to drop, but it was an opportunity for her to take a bit of a victory lap here
on the submitpackage PR.  This PR makes the submitpackage RPC available on
non-regtest networks, so you can actually use submitpackage on mainnet, and
there's some commentary here about open considering opening this up on mainnet,
where miners could potentially be using this RPC for something like transaction
acceleration services.  We saw folks like mempool.space opening something like
that up compared to what they're doing now.  You can do this locally, but since
this is not fully implemented at the P2P level, this is not package relay.  You
can submit transactions locally, but there's no way to communicate those
packages to other peers.

So, this is something that's still in progress as part of the package relay
project.  There is a package relay tracking issue, where you can follow a lot of
the progress going on there, including this particular PR #27609.  Greg, do you
have any comments on package relay, submitpackage, or the BIP324 rollout?

**Greg Sanders**: Well, I'm super-excited for BIP324.  On package relay, there's
still a ton of work to be done.  This is just one way that people can start
integrating and testing, and maybe slightly improve their chances of propagating
certain types of transactions.  So, long way to go.

_Bitcoin Core GUI #764_

**Mike Schmidt**: Next PR this week is to the Bitcoin Core GUI, Bitcoin Core GUI
#764, which removes the ability within the user interface to create a legacy
Berkeley DB wallet.  So, legacy wallets are being deprecated in upcoming
releases, they are being replaced by descriptor-based wallets.  So, removing the
functionality now in the GUI could potentially save users having to migrate
their, "Legacy wallet into a descriptor wallet in the future".  Power users can
still create legacy BDB wallets currently, if they really want to, either using
an older release, or you can use the RPC console and use the createwallet RPC.
But given that there's a lot of work around transitioning to descriptor wallets
and there's plans to deprecate the legacy wallet, you probably don't want to do
that unless you know what you're doing.

If you're curious about the broader effort in Bitcoin Core specifically to
retire the legacy wallet, check out the tracking issue on the repository that's
titled Proposed Timeline for Legacy Wallet and BDB Removal, which is issue
#20160.  You'll see a bunch of different issues related to potential timing and
releases of when certain things will be turned off and certain other things
added, as part of that larger project that this GUI PR rolls up to.

_Core Lightning #6676_

Last PR this week is to the Core Lightning repository, #6676, which adds a
command to populate PSBT outputs from the wallet.  So PSBT is Partially Signed
Bitcoin Transaction, and this is used in Core Lightning (CLN) to receive funds
into the onchain wallet interactively using PSBTs.  It can either create or
modify a PSBT.  The end state there is, it adds a single output with a specified
amount of satoshis.  This particular RPC returns on success an object which has
the PSBT string which is unsigned, given the parameters that you've parsed it.
It also estimates the added weight of the added output that the RPC adds to the
PSBT, and it also includes the index of where the output was placed in that
PSBT.

This added function also was part of the PR that added output and splice-out
tests in CLN, and those tests also specifically made use of this RPC.  So,
splicing is moving along in CLN.  Instagibbs, any comments on the GUI PR or this
CLN PR, or I guess, Steven, any other comments on the newsletter as a whole
before we wrap up?  Thumbs up from Greg.  Excellent.  Well, thank you Stephen
for joining us.  Thanks to Gloria for joining us.  Thanks for instagibbs for
jumping in and chiming in and asking some good questions, and we'll see you all
next week.  Cheers.

{% include references.md %}
