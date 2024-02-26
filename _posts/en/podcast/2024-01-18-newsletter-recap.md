---
title: 'Bitcoin Optech Newsletter #285 Recap Podcast'
permalink: /en/podcast/2024/01/18/
reference: /en/newsletters/2024/01/17/
name: 2024-01-18-recap
slug: 2024-01-18-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Brandon Black, Chris
Stewart, Gregory Sanders, and Oliver Gugger to discuss [Newsletter #285]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-0-18/4d496957-12df-b1b6-0e4b-014bf523c749.MP3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #285 Recap on
Twitter Spaces.  Today, we're going to be talking about a vulnerability in Core
Lightning (CLN), the LNHANCE soft fork proposal, the 64-bit arithmetic soft fork
proposal, cluster mempool and the CPFP carve-out policy, updates to Bitcoin
transaction compression specification we covered previously, minor extractable
value and ephemeral anchors, and a collection of notable code changes.  I'm Mike
Schmidt, I'm a contributor at Optech and Executive Director at Brink, funding
open-source Bitcoin developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs to improve Bitcoin.

**Mike Schmidt**: Brandon?

**Brandon Black**: Hi, I'm Brandon Black or Rearden.  I recently joined Swan,
and in my free time I work on Bitcoin stuff to get more people on Bitcoin.

**Mike Schmidt**: What are you doing at Swan?

**Brandon Black**: I'm helping with their self-custody offering.

**Mike Schmidt**: Cool.  You have experience in such things.

**Brandon Black**: It's true.  I have like a trend going on.

**Mike Schmidt**: Chris?

**Chris Stewart**: Hi, yeah, I'm Chris Stewart.  I'm an independent Bitcoin
developer.

**Mike Schmidt**: Oliver?

**Oliver Gugger**: Hi, I'm Oli, I work at Lightning Labs mostly on LND and
taproot asset stuff.

**Mike Schmidt**: And Greg hasn't yet attained speaker privileges, but we all
know Greg, right?  He's a stalwart attendee.  Well, we're going to jump into the
newsletter.  I've shared some tweets in the Space that covers what we covered
this week in the Newsletter #285.  We'll go through sequentially and Greg will
introduce himself.  Hi, Greg.  Bye, Greg?  Greg, who are you?  Getting the
silent treatment.

**Mark Erhardt**: So, Greg is a wizard at Spiral and he works on LN-Symmetry and
especially v3 transactions and some parts of cluster mempool and package relay
right now, and that's totally butchering it but roughly covering it too.

_Disclosure of past vulnerability in Core Lightning_

**Mike Schmidt**: That's his actual title, Bitcoin Wizard, I think.  First news
item this week is Disclosure of past vulnerability in Core Lightning.  Hi, Greg.
Yeah, we can hear you.  Okay, great.  So, CLN vulnerability.  In Newsletter
#266, we covered the fake funding vulnerability, which was disclosed, which
involves a scenario where a malicious actor can start the channel opening
process with a victim's lightning node, but never actually complete the channel
open process.  Essentially, they don't broadcast the channel open transaction,
which is okay if it's done one time, but if the attacker repeats this process
thousands or millions of times, it could cause issues due to the resources of
the victim's node being wasted on these fake funding requests and not being
available for other LN node operations.  In our podcast on #266 discussing that
issue, we had Matt Corallo on to talk about that vulnerability, if you're
curious of the details of that particular fake funding vulnerability.  LN
implementations had mitigated that vulnerability by the time we discussed that
disclosure and all was good.

However, in subsequent retesting of fixes to the fake funding, Matt Morehouse,
who discovered the original vulnerability, also noticed that for CLN
specifically, he was able to trigger a race condition in CLN implementation, and
the race condition occurred with the interplay of the channel open process and
the chanbackup plugin.  Essentially, the vulnerability had laid in wait for a
while because no one was actually using that chanbackup feature, until the peer
storage backup feature made use of that channel backup and the plugin that
actually used that channel backup hook.  So, at the time that the peer storage
backup feature was released, that vulnerability was essentially unleashed and
Matt Morehouse was the one who caught that particular race condition and
reported it to the CLN team responsibly, and a fix was made.

There's also a great write-up that Matt Morehouse did, getting into the
disclosure in detail on his blog, which we've linked to in the newsletter as
well.  Murch or special guests, anybody have any thoughts on that vulnerability?
Murch gives me the thumbs up, great.

_New LNHANCE combination soft fork proposed_

Next item from the newsletter, it's titled New LNHANCE combination soft fork
proposed.  We have the author of this proposal here, Brandon Black; he posted
this to the Delving Bitcoin, some details about the soft fork, I'll let him
explain it himself.

**Brandon Black**: Hi there, thanks for having me up.  And yeah, just to
introduce this a little bit, as many folks know, I've been kind of learning in
public and going down this rabbit hole of covenants and soft forks and
ANYPREVOUT (APO) and CHECKTEMPLATEVERIFY (CTV), and everything for close to a
year now.  I think it'll be a year next month that I've been really on this
rabbit hole.  And after all of that and spending time talking to all the authors
of various proposals and whatnot, and seeing what exactly we can actually do in
practice with these covenant proposals, this LNHANCE combination seems to be the
cleanest way to get pretty much everything that we want to be possible on
Bitcoin.  While there may be better ways to do certain things, this was the
clean way to get the thing.  So now what is it exactly?

This combines CTV, which is the proposal BIP119 from Jeremy Rubin, and the way
to think of CTV briefly is that it restricts the next outputs that some bitcoin
can be spent to.  And specifically, CTV restricts all of those outputs.  You
can't restrict to just one or just a couple, it's all of them.  But it can be
much like an APO signature can be rebound to different inputs; the CTV covenant
can be rebound to different inputs as well.  So, there's a lot of overlap in the
things you can do with APO and that you can do with CTV.  To be very specific
again, CTV covenants are very similar to SIGHASH_ANYPREVOUTANYSCRIPT|SIGHASH_ALL
signatures.  So that's one part; CTV.  The downside potentially to CTV is that
you can't use it easily with signatures unless you also have something like
CHECKSIGFROMSTACK (CSFS).  And so in LNHANCE, we add CSFS, which lets us check a
signature against that template hash, which then gets us pretty much the full
functionality of SIGHASH_ANYPREVOUTANYSCRIPT|SIGHASH_ALL with CTV and CSFS.

There's one more thing that's kind of a difficulty that's been shown in using
taproot recently, and it's been talked about for a while, but recently actually
Rusty posted about it, and that is that the control block uses a significant
number of witness bytes, and 32 of those bytes are representing the internal key
of your taproot output.  There are cases, quite a few of them it turns out,
where you're not using that internal key directly to sign keypath spends.  So
both the APO proposal, which uses the magic byte 1 to copy that key and use it
in checking a signature directly, and my LNHANCE proposal here, which has a
separate opcode for pulling that internal key and putting it on the stack, are
trying to find ways to make use of those bytes so that in the cases where
they're not specifically needed for a keyspend, they can be used for something
else useful.  And so, that's what OP_INTERNALKEY allows us to do.

Because that internal key, if you're not going to use it as a keyspend, should
be a nothing-up-my-sleeve (NUMS) point, and one of the ways to create a NUMS
point is to hash some known data and treat it as a public key, we can use a hash
that might be a CTV hash, for example, as that NUMS point and be able to make a
CTV that's almost as efficient as a bare CTV using tapscript in this way, and
yet then kind of the anonymity set growth of being in the taproot key pool until
it's spent that way.  So, those are the three parts of LNHANCE, and I call it
LNHANCE because it really does enhance LN.  It enables Ark in the original way
that Burak envisioned it, although he's now moving on to some other fancier ways
of doing Ark, but it enables Ark in the original way he proposed it, and Ark was
originally envisioned as a LN wallet; it enables John Law's timeout trees; it
enables LN-Symmetry with a combination of these opcodes; it also enables the
simplified Point Time Locked Contracts (PTLCs) that Greg can potentially tell us
more about.  You can do PTLCs with existing scripts, but they're pretty hard to
deal with, and with these opcodes, you can make pretty PTLCs.  Yeah, that's why
I called it that.

**Mike Schmidt**: Yeah, that was going to be one of my clarification points, is
that the name makes it sound LN specific, but there's also all these other
protocols that could benefit from this.  Yeah, go ahead.

**Brandon Black**: Yeah, I think it's, is it LN specific?  No, but most of the
things that we really, really want and that this enables are kind of around the
LN.  It's like at the edges of LN, how do we onboard people better?  And LNHANCE
really helps with that.  Another example that I forgot to mention just now is
non-interactive channels.  Once you have these signed covenants, it becomes
possible to build.  The details aren't as worked out quite as I would like yet,
but it's looking very likely that you can get either a fully non-interactive
one-way channel using these, or a non-interactive channel open for a two-way
channel using these opcodes.  Details still to be worked out on that, but it's
looking very likely we can get those to work.

**Mike Schmidt**: Instagibbs, I saw that you commented on the original Delving
post, and you're also driving a lot of the LN-Symmetry work.  Do you have
particular thoughts on the proposal so far?

**Greg Sanders**: Not much.  Just the one caveat that we're talking about, yeah,
application, things we want to do with covenants.  The one use case which is
still under development that it probably doesn't do is something like vaults,
practical vaults at least, right?  But other than that, sounds about right.

**Mike Schmidt**: James, I see you're in here.  If you want to participate and
comment on vaults or anything else related to the software proposal, you can
request speaker access.  Brandon, what's the feedback on the proposal been so
far, both on Delving or Twitter or elsewhere that you've had in some of these
conversations?

**Brandon Black**: You know, frankly I've been blown away by the overall
positivity around it.  People seem pretty excited about this combination, where
we're kind of -- I've been trying for a year, basically, to resolve the fight
over APO versus CTV.  And finally, I think I've found something that brings us a
good combination of those features, so really extremely positive.  I've been
working with AJ on getting the BIPs into his new BINANA repository, so that he
can potentially add the CSFS and OP_INTERNALKEY to Inquisition.  He had some
great feedback over there.  Yeah, overwhelmingly positive feedback so far.

**Mike Schmidt**: Hey, James.  Did you have any comments or questions?

**James O'Beirne**: Yeah.  Sorry, I'm at a coffee shop so the sound might not be
great.  But yeah, I think it's really interesting work.  I would say I'm still a
little bit confused about how OP_INTERNALKEY fits in and what motivated that.
Is the purpose to combine that with CSFS to somehow emulate APO, or is there
some other way that it fits in?  I mean, I think the nice thing about it is it's
a very simple, primitive sort of common sense to have available.  And then the
only other thing that was on my mind was just echoing what Greg said about
vaults.  I think for me that's still, alongside LN, far and away the most
compelling use case for covenants.  I think it's just widely applicable.  This
proposal doesn't address that, but it's interesting work nonetheless.

**Brandon Black**: Yeah, I'll clarify a little bit on OP_INTERNALKEY.
OP_INTERNALKEY doesn't enable anything that would not otherwise be possible.
It's a way to do certain things with fewer bytes, and that's the same reason
that the APO proposal includes that magic single byte key of the 1 key, is just
to be able to reuse the internal key inside a script when you otherwise would
just be wasting those 32 bytes in the control block, because there was no other
reason to have a separate internal key there.  So, it doesn't enable anything
fundamentally, but it does reduce the number of bytes needed for doing
LN-Symmetry, or for doing a CTV where you have no keyspend available.

**James O'Beirne**: Cool, thanks.

**Brandon Black**: Oh, and then on vault, as you know, because I've talked to
you on DMs a little bit, I'm very open to saying that we should take LNHANCE and
do LNHANCE plus vault.  As Luke likes to point out, you can have multiple
activations in progress at the same time, so I'm also open to having them going
together, because as you also point out, vault isn't dependent on the CTV,
although it works very well with CTV.  I'm a big fan of your work on vault, as I
think you know, so would love to do some combination of those things as we move
forward with thinking about what's next for Bitcoin.

**Mike Schmidt**: Brandon, where is the idea at in terms of something from a
writeup to working code; can you maybe explain the progress that you've made?

**Brandon Black**: Yeah, so I have PRs out against the world, basically, with
working code.  They're not all in an absolutely consistent state right now, but
Inquisition, MutinyNet and Core, some are in draft state right now as I work
through some of AJ's feedback, and I'm working on getting that all updated.  So
yeah, working code out there.  It has, I would say, reasonable test coverage in
terms of using the Bitcoin Core transaction test framework to test end-to-end
transactions, but not end-to-end through the RPCs.  I don't have RPC-level
testing of it in place at this time.  But there's working code.  Chris Guida is
working on updating Greg's APO branch to the current CLN, so that we can then
work on porting APO to use LNHANCE just to verify that everything does indeed
work that way, and I think that'll be a big step towards readiness.  Yeah, so
the code is out there, but we have some work to do on prototypes.

**Mike Schmidt**: Is there a particular call to action for the audience,
depending on their varying level of technical capabilities?  Obviously, some of
the wizards you want to take a look at some of this, but maybe there's some
prototyping that people can do or building on top of some of what you've done?

**Brandon Black**: Yeah, a couple of things would be amazing.  One is, I would
love to see some other ideas for different kinds of vault-like things you can do
with CTV or with CTV and CSFS.  We've been banding about some ideas for that,
and they're never going to be as good as OP_VAULT, but I'm curious what else is
possible there.  And you can base that work on James's simple CTV vault, which
does the very simplest CTV vault, but maybe there are some cooler vaults we
could do.  And the other thing is review the BIPs.  There's obviously, as we
said, OP_INTERNALKEY is a very simple concept.  That BIP needs some textual
improvements probably.  I'd love a review on that.  And then CSFS, there's a
couple of design things around CSFS that are worth considering, most
particularly AJ gave me some feedback yesterday as to whether CSFS should bother
supporting ECDSA at all, and I would love people's thoughts on that specific
question on the BIP PR.

**Mike Schmidt**: Murch, thumbs down?

**Mark Erhardt**: Yeah, I think that in a schnorr signature world, there's so
many things that are easier and better.  I don't think that we want to build out
support for old things, and I don't really see the point.  I think we're going
to move forward more towards P2TR as the standard-type world.  So I don't know
if it would be worth -- or maybe I just don't see an obvious reason why it would
be worth even supporting ECDSA.

**Brandon Black**: I've been coming around to that direction.  What happened,
just to give history, it's kind of an interesting tidbit.  I originally wrote
it, the CSFS BIP, with the simplest possible concept, "Make a new sigop in all
of the different script types that behaves exactly like the other sigops, using
only their already known signature checking methods and semantics".  But of
course, the old CHECKSIG semantics on legacy scripts are kind of a mess.  So,
then I realized it's better to bring the tapscript semantics to the new sigop
CHECKSIGFROMSTACKVERIFY.  At that point, might as well do schnorr, but I left
ECDSA support as well and I'm thinking it should be dropped.

**James O'Beirne**: Brandon, one of the things that I'm curious about, as to
whether you have any opinions on after your investigations, are something like
TXHASH.  There was a lot of talk about that.  And for those who don't remember,
TXHASH, as proposed by Steven Roose, is like a more flexible version of, or more
parameterizable version of CTV.  Have you uncovered any uses that are uniquely
served by something like that, or do you think that the combination of CTV and
CSFS are pretty sufficient?

**Brandon Black**: It's a little hard to know.  There are definitely things that
are easier with TXHASH.  They tend to be around fee management in these output
tree proposals, like timeout trees or Ark.  These have these trees of CTVs or
TXHASH-restricted outputs, and the fee management of those can be quite a
challenge.  So, that's where I think that the TXHASH work really kicked off, was
then looking to resolve some of those issues in the Ark design.  So, I don't so
far see things that are only possible that we have concrete designs for with
TXHASH, but I see things where the fee management might be easier with TXHASH.

That said, TXHASH is a strict upgrade and a clean upgrade to CTV.  TXHASH
itself, TXHASHVERIFY I should say, includes a default mode which is nearly
identical to CTV's hashing mode.  I don't think we should tie these things
together in this way of, "Oh, so I do TXHASH or CTV?"  I think we should do CTV
and continue developing TXHASH as an upgrade to CTV.  And I don't think there's
any reason to delay CTV or to, I don't even want to say delay, there's no reason
to relate them in that way.  If we do CTV first, great; if we do TXHASH, because
we get it all worked out first, that's also fine.

**James O'Beirne**: Yeah, I think I agree with that, and I think that it's worth
pointing out probably the main risk.  Someone might ask, "Well, if TXHASH
encompasses CTV and it's more flexible, why wouldn't we do that?"  And I think
the answer for me there is that there are a lot of caching considerations that
come up to avoid things like the quadratic sighash attack, when you introduce a
bunch of parameters for what can go into the sighash.  And if you even just look
at the code that Stephen Roose produced, it's quite a bit more complicated than
something like CTV is.  So I think you have a good way of looking at it; I agree
with that.

**Mike Schmidt**: Brandon, thank you for joining us.  We have some other
interesting news items that you may want to stick around for, but if you need to
drop, we understand.

_Proposal for 64-bit arithmetic soft fork_

We have a Proposal for 64-bit arithmetic, and we have the proposal author here,
Chris Stewart.  Chris, you posted a draft BIP to the Delving Bitcoin forum for
enabling 64-bit arithmetic operations on a future soft fork.  Maybe to start
with, what sort of arithmetic operations are currently possible with Bitcoin
Script, and what are the limitations with that currently?

**Chris Stewart**: Yeah, so we have some arithmetic operations in Bitcoin Script
currently, like an OP_ADD opcode, OP_SUB opcodes.  They all interface with this
internal class called CScriptNum, which has some pretty hard-to-reason-about
semantics associated with it.  It's a 32-bit signed integer representation of
numbers.  Interestingly enough, we can actually extend that to a 5-byte number
representations on the stack, but cannot actually do anything with 5-byte
numbers on the stack, aka  consuming them with a subsequent OP_ADD or OP_SUB
opcode.  All this is just to drive home the point that there's extremely
hard-to-reason-about semantics about the current arithmetic operations in
Bitcoin.  If anyone doesn't believe me, go try and implement an interpreter
that's consistent with these rules.  There's a wonderful file in the Bitcoin
Core repo called script_valid.json, and maybe there's a script_invalid.json as
well that details in length how the consensus rules around these opcodes
currently work.  I guess I want to give a little background on how I got
motivated to do this, because I think this is a vision that I would like to see
Bitcoin to go.

I was preparing for Chicago BitDevs in the fall of this year.  I think I finally
got around to reading AJ Towns' proposal called OP_TAPLEAF_UPDATE_VERIFY; I call
it OP_TLUV for short.  I thought this was an extremely compelling proposal that
I hadn't really seen come out of the Bitcoin ecosystem in quite some time.
However, this proposal allows you to kind of non-interactively join outputs and
leave outputs.  The key thing here is non-interactively doing this.  What I
learned in DLC world, interactivity is just a killer, and we're learning that
lesson over and over again with various Bitcoin protocols.  So, whenever we can
move to non-interactivity, I think we should.  However, this TLUV proposal is an
absolute elephant of a proposal.  There's a lot in there, there's a lot of
reasoning that needs to be done, and I was like, "Okay, how do we decompose this
problem?  What do we need to actually get there in 10 or 20 years?" which is
kind of the rate that it seems that it takes for Bitcoin to change things.

So, if we decompose this thing, there was this cool opcode in there called
OP_IN_OUT_AMOUNT.  So, that could push the input amounts and output amounts onto
the stack, and you could do script operations based on how much money is leaving
the smart contract or joining the smart contract.  So I'm like, "Okay, that's
really cool, that makes sense.  We've decomposed one layer here".  And then I
start reading about IN_OUT_AMOUNT and AJ writes that, "Well, this actually isn't
even possible today because we can't even support 64-bit arithmetic operations
in Bitcoin".  So I'm like, "Oh, wow, so that seems like a nice, small piece that
I can carve off here.  We can hopefully not have too much contention around
64-bit operations and let's get the ball rolling here".

I also went and saw this actually has been implemented before in Bitcoin
derivative blockchain, the Elements project.  So, it was really heartbreaking
for me to see that this is work that's kind of been done already.  I think
everybody agrees that it's valuable, but the political angle of actually getting
things activated on Bitcoin is just not a fun process and it's not very
rewarding either.  So, what I'm doing with this proposal is just literally
taking work from the Elements project, bringing it over to Bitcoin, becoming the
standard-bearer and dealing with the politics to get this stuff activated.  My
goal is to get this really merged into Bitcoin Core this year.  According to
fanquake, we've got a 27.0 release in March and then I think a 28.0 release in
October.  My goal is to have this in the 28.0 release.

So, now a little bit about how the 64-bit opcodes actually work.  One other
problem with the existing opcodes, like OP_ADD, OP_SUB, in the interpreter
currently is it doesn't give you a great way to handle overflow scenarios.  So,
one thing that's introduced with this 64-bit opcode here is, it gives you the
ability to check for overflows on a multiplication operation, for instance; or,
say if someone's trying to divide by zero in the OP_DIV 64 opcode, we would now
push FALSE onto the stack and check these things in advance, so then when you're
writing your script, you can properly handle scenarios like this where you
receive bad inputs and build an OP_IF, OP_ELSE_IF conditional logic based on
whatever you want to do in your failure scenario where your inputs would result
in overflow ops.  There's also an OP_NEG64, so negate your 64-bit stack top.
There's OP_GREATER_THAN64, OP_LESSTHAN64, a bunch of comparison opcodes.  I
think this also has the ability to clean up a lot of complexity in the sense of
number encodings in the Bitcoin protocol.

I've got feedback on this proposal from people in this call, and I'm still
working on giving an in-depth answer.  So, I'm shooting at the hip here a little
bit, but I do believe this is to be true.  There's the classic thing in computer
science where it's like, "Oh, we have a protocol, it doesn't fix what problem we
have.  So, let's make a new protocol".  And then at the end of the day, you have
two different protocols that no one coalesces around, and that's kind of the
case with numbering in the Bitcoin protocol.  We have output values, which are
int64s.  Those are like the satoshis that you see in the protocol.  And inside
of Bitcoin Script itself, we have another number encoding that's a minimal
length number encoding.  The minimal thing is a key consideration here for
malleability purposes.  If you want to read more about that, check out BIP62.

But we do have two different numbering protocols in Bitcoin, and my 64-bit
arithmetic protocol suggests moving back to just little endian 64-bit numbers
and getting rid of the minimal encoding.  The reason why I think this is the way
we should be going is because, well, again, we're going to have two numbering
systems in Bitcoin no matter what.  People want to do math on satoshi values.
Hopefully in the future that's not part of this specific proposal, but we sure
as heck aren't changing the number representation of satoshi values.  So, maybe
we should consider changing the interpretation logic.  And I believe we can do
that in a safe way that doesn't change malleability.  It will increase witness
sizes a little bit.  I still need to do the analysis on how much we're talking
here, like are talking hundreds of megabytes, gigabytes over the history of the
blockchain; I haven't done that.

But anyway, so this is kind of where I'm at with the 64-bit proposal.  I, again,
would like to get this done this year.  I think it could be relatively
uncontroversial, but I'm open to questions.  Sorry, I ranted a lot there.

**Mike Schmidt**: Chris, you got into this a bit, but maybe just to be explicit
for listeners, you're not proposing to change the existing arithmetic opcodes,
but instead adding new opcodes that can handle 64-bit integers in specific ways?

**Chris Stewart**: That's exactly right.  I would like to see the old opcodes
disabled in new witness versions, or maybe even tapleaf versions.  I'm still
trying to understand what's possible with the new leaf versions that we have in
the Bitcoin protocol.  But I think we should just get rid of the old numeric
operations in a future release.

**Mike Schmidt**: You answered one of my questions I think, which was I know you
work at SuredBits and you guys are working on DLCs, and you sort of connected
the dots here from DLCs, non-interactivity, TLUVs, 64-bit arithmetic.  Is that
sort of the rabbit hole you went down?

**Chris Stewart**: Unfortunately, with SuredBits, one of the biggest problems we
ran into is just interactivity of setting up DLCs.  It is just a killer.  Any
sort of interactive protocol requires a ton of overhead out of band, and
especially when you start introducing multiparty protocols.  So, say if you
wanted 100 people on a DLC instead of just 2 people, that communication
complexity scales pretty horribly.  So, that's why I had interest in TLUV
because I think it allows us to start doing things like we see on other
blockchains, such as Ethereum with basically censorship-resistant financial
markets deployed to Ethereum.  But again, that's the elephant that I'd like to
get to someday.  I'm taking a bite out of this elephant by trying to just get a
very small proposal activated, not even allowing access to satoshi values in the
script interpreter yet; I'm just trying to do 64-bit arithmetic, and then we'll
take another bite out of the elephant if this goes well.  And if this takes five
years to activate, I probably won't be around for that, because that's just
demoralizing.

**Mike Schmidt**: There was one part of the BIP that maybe you can help
elaborate a bit on, and you may have touched on this, but maybe we can elaborate
a bit further.  The BIP also describes the set of conversion opcodes to convert
existing Bitcoin protocol numbers into, you mentioned these 4- and 7-byte little
endian representations.  Can you talk a little bit more about that?

**Chris Stewart**: Yeah, so this is something that's been requested from other
Bitcoin developers that are interested in this 64-bit proposal.  I didn't
originally have them in, and I am really trying to avoid scope creep here
because as your features grow linearly, your bikeshedding possibilities and
concern-trolling grow exponentially.  So, I am really pushing back against
introducing things like, say, a left-shift operator or a right-shift operator,
or other sane things that could be included in this proposal; but I want to keep
this to be a slim, fat, soft fork rather than a fat one.  Again,
concern-trolling and bikeshedding grows exponentially as your features grow
linearly.  However, this is something that people said is valuable and they
would find valuable for their work.  It does allow you to convert from, say,
little endian 32-bit numbers to little endian 64-bit numbers, from the
ScriptNums that are currently used in Bitcoin, to 64-bit little endian signed
integers.  So, those are included in there.

If people think that this is unnecessary and again is introducing more features
at the cost of our exponentially growing bikeshedding and, I guess, bikeshedding
possibilities, I think I could cut those out too and just literally go with the
four strictly arithmetic opcodes, OP_DIV, OP_MUL, OP_ADD and OP_SUB.

**Mike Schmidt**: Murch, James, or Greg, do you guys have any questions about
what Chris has been talking about?

**James O'Beirne**: Yeah, I'm kind of mystified by TLUV, to be honest, because
to my knowledge it was never fully specified.  To recap for people, TLUV was
kind of a conceptual idea that AJ Towns came up with and correct me if I'm wrong
in anything here Chris, but it's basically just saying, "Hey, what if you could
articulate some allowable transformation that the taptree could go through on
its way to being spent?"  But that method of articulating the allowable
transformation I don't think ever actually came to be.  So, TLUV to me was kind
of unspecified.  Is that not the case for you, Chris?

**Chris Stewart**: That is exactly the case for me because, James, frankly why
would you work on something like that when it's extremely complex and we can't
activate simple things like 64-bit arithmetic on Bitcoin?  So, I have a lot of
interest in that.  You'll probably see more of me writing about TLUV in the
coming months, although being realistic about where the Bitcoin political
process is at, I wouldn't expect to see that anytime soon.  However, I think the
vision is absolutely wonderful and that's something that I want to work towards.
And again, looking at TLUV as the elephant, this is the smallest piece of the
elephant that I could take and think that's possible to get activated in a
reasonably short timeframe.  I guess I shouldn't say activated, merged into
Bitcoin Core and deployed in nine months.  But maybe I'm being a little overly
optimistic here.

**Mike Schmidt**: I see there's a bunch of discussion on Delving in response to
your post.  How would you summarize the feedback there and elsewhere so far?

**Chris Stewart**: I mean, I think it's relatively positive.  There's concerns,
like the number encoding is the number one thing that I've got pushback on, with
the joke about, "Why would we have two encodings?  We've already got one, and
then a third person is going to come along and create their own encoding".  My
pushback on that is just like, "Yeah, we've got two encodings.  That is the
world that we live in with the Bitcoin protocol right now.  Satoshi values are
just different than the script numbers that are used".  I think the script
numbers are pretty bad, I think they should go away, obviously not in a hard
fork way, but we should soft fork them out slowly over as time goes on.  That
also allows us to reduce complexity in the interpreter.

So right now, we have these things called fRequireMinimal flags, which says,
"Hey, we need to require the minimal encoding of a number in the script
interpreter".  Well, that makes sense.  That is an acute problem that we had in
the history of Bitcoin in that, let's call it 2010 to 2017 era, where we had a
lot of malleability of scripts, specifically tinkering with script numbers to
adjust the txid by just encoding them slightly differently.  However, my
pushback on this would be, "Well, let's just require all numbers to be 8 bytes".
There's no malleability, it's compatible with other number representations in
the Bitcoin protocol, like satoshi values, and I mean I think that just reduces
overall complexity for new people being onboarded into the project too, because
they can just now use the little endian number representations that they've
learned in their computer science career, software development careers along the
way, rather than having to learn our esoteric number encoding that currently
exists.

It is a fair criticism that this will increase witness sizes slightly.  I still
need to run the numbers over the historical blockchain to figure out how much,
but I don't think it's a needle-mover personally.  But we'll see what the
numbers say.

**James O'Beirne**: Well, it's not even just about historical numbers.  I mean,
a lot of the prospective soft forks include specifying txout position parameters
and a lot of small numbers.  So, if you're fixing 8 bytes for every single
number, I mean that just strikes me as a potentially terrific waste of space.

**Chris Stewart**: Well, and I guess that's really the question, is how much do
we care about blockchain disk space, specifically in the witness versus, I don't
know, comprehendability, readability, understandability of the protocol?  And I
guess that's a choice that we, as Bitcoin developers, need to make.

**Mike Schmidt**: Chris, thanks for coming on, thanks for explaining the
proposal, and you're welcome to stay on as we go through the newsletter, or
you're free to drop if you have other things to do.  Thanks, Chris.

**Chris Stewart**: Thanks, guys.

_Overview of cluster mempool proposal_

**Mike Schmidt**: Next item from the newsletter is titled Overview of cluster
mempool proposal.  So, back in Newsletter #280, we covered cluster mempool
discussion and we also provided an overview of cluster mempool.  We also have a
cluster mempool topic now on the Optech website.  And also in Podcast #280,
covering Newsletter #280, we discussed cluster mempool with Pieter Wuille, who
is working on it.  So, for some background, check out that great discussion with
him.  And on top of our writeup and chat with Pieter in #280, Suhas has now
posted a proposal overview to the Delving Bitcoin forum that we linked to in
this newsletter.  While we encourage listeners to read that post and get further
explanations around cluster mempool, this week we specifically noted a detail
about the writeup from Suhas involving CPFP carve-out policy and its relation to
cluster mempool.

Murch, I know you're somewhat involved with the cluster mempool effort and team.
Maybe to start, can we give a quick summary of carve out first, and then maybe
comment on the relation to cluster mempool here?

**Mark Erhardt**: Sure.  So, the CPFP carve out is a strategy to prevent
pinning, and the idea is if you have, for example, a transaction output that is
owned by two parties in some fashion, or yeah, there's a transaction with two
outputs and one person adds a bunch of descending transactions to it that either
hit the descendant size limit or the descendant count limit, it would be
prevented that another person adds another descendant of the same transaction
because the limit is already exceeded.  So, the limit is currently 25
descendants and I believe that a chain of descendants is not permitted to have
more than 101 kilo-vbytes (kvB).  So, this would be a strategy for someone that
is trying to prevent a transaction from confirming, to prevent you from adding
your own CPFP to bump it to get a quick confirmation.  The CPFP carve out now
permits that a single time, someone is allowed to add another transaction to the
first, like as a child to the first transaction in such a chain, so it only can
have a single ancestor, I think, and is limited in size.  And yeah, so this
basically permits the counterparty to bypass this limit a single time to be able
to bump their transaction in a two-party protocol.

The problem now, how that interferes with cluster mempool is, in cluster mempool
we would be aiming to drop the descendant limit altogether and also the ancestry
limit, because we now think of transactions rather in the context of all the
connected transactions transitively across child and parent relationships.  And
therefore, if we had this kind of carve out, this might appear at various
different points in the cluster.  So, you would be able to add multiple
transactions to a cluster.  And then of course, the cluster size limit, the
count of transactions that a cluster can have and the weight limit a cluster may
have would be exceeded at multiple points, and then really the limit on the
cluster wouldn't be effective and we'd have to engineer instead with the
expected overall size with all the potential carve-out transactions.

**Mike Schmidt**: So, in this case, what is the proposed solution to that
incompatibility between carve out and cluster mempool?

**Mark Erhardt**: My understanding is that the idea is to move two-party
protocols, like LN channels, to a new transaction version, namely v3
transactions.  And v3 transactions would opt into a topology restriction by
themselves, which would prevent the sort of pinning that we currently are
bypassing with the CPFP carve out.  So, by opting into v3 transactions, the CPFP
carve out would be unnecessary because the problem that it remedies can no
longer occur with v3 transactions.

**Mike Schmidt**: You've mentioned two-party protocols, and I think CPFP carve
out was largely an LN-driven policy, but we also note in the newsletter on this
topic that as discussion has progressed around cluster mempool and mempool
management in general, folks who are developing software related to mining
wallets or other contract protocols should take a look at what Suhas wrote up
and engage with some of this discussion to make sure that, I guess, all the
bases are covered.  So, if you're a developer in one of those fields, obviously
take a look at what Suhas wrote up and engage.  Murch, what else is there to
talk about, about cluster mempool and carve out?

**Mark Erhardt**: Well, there's a whole series of really interesting posts on
Delving Bitcoin.  The overview is a great point to start, but if you're more
interested in how it all works, there's a bunch of related writeups of the
details of how clusters are linearized, how it all could work together.  There's
also a draft branch that Suhas mostly has been working on.  I also know that the
comparison mechanism that we came up with, with how we think about two different
variants of the same cluster, is now a topic for package relay and v3
transactions, so instagibbs has been looking at it.  There's been a bunch of
interest from other developers.  So, this is pretty exciting, moving quickly.
If that sort of tickles your interest, I think it's a good time to get a look at
it.

_Updated specification and implementation of Bitcoin transaction compression_

**Mike Schmidt**: Next item from the newsletter is titled Updated specification
and implementation of Bitcoin transaction compression.  So, back in Newsletter
#267, we described the initial proposal by Tom Briar for Bitcoin transaction
compression.  This update this week is an update to that specification.  The
proposal is a spec to represent Bitcoin transactions in a smaller number of
bytes by applying various techniques to save bytes on transaction
representation.  Check out Podcast #267 where we actually had Tom Briar on, the
author of the proposal, and we got into a lot of those techniques in that
discussion.  The use case for such a thing would be able to represent a Bitcoin
transaction in bandwidth-constrained mediums.  We know satellite transmission,
and Tom talked about steganography as well.

The post from Tom that we covered this week updates that original spec with some
additional optimizations and to quote the newsletter that quotes Tom, "Removing
the grinding of nLockTime in favor of a relative block height, which all of the
compressed inputs use, and the use of a second kind of variable integer".  So,
if you're curious about the details, check out News #267 and Tom's updated post
that we covered this week.

_Discussion of Miner Extractable Value (MEV) in non-zero ephemeral anchors_

Next item from the newsletter is Discussion of Miner Extractable Value (MEV) in
non-zero ephemeral anchors.  We have Greg on this week to talk about this topic
and he was the one who posted to Delving Bitcoin to discuss these concerns.
Greg, maybe to start, what is MEV?

**Greg Sanders**: So, sorry, I might cough through this discussion, but MEV,
well, there's a few definitions.  We're going to talk about the ones I think
Bitcoiners normally are talking about.  So, MEV stands for Miner Extractable
Value, and this is mostly when we're talking about kind of the evil kind, which
is not transaction fees, right, because that's transaction fees.  But we're
talking about something like, can the miner mess with the mempool in specific
ways to gain more fees than the transactors were expecting; or maybe not just
fees, but grab more value?  So, if you think of the ephemeral anchor example, I
think it's fairly straightforward.

Let's imagine you put 1 bitcoin into an anyone-can-spend output, like an OP_TRUE
output, ephemeral-anchor-type output, then it stands to reason that everyone
will try to take that.  So, everyone will start making transactions, trying to
sweep it, put it into their own wallet under their own key.  But in the end, a
miner theoretically, whoever mines the block should be inserting their own
transaction that takes the entire bitcoin and puts it in their wallet.  So,
that's kind of the MEV and the MEV scenario I was discussing.

**Mike Schmidt**: Okay, now maybe relate that more to a more practical ephemeral
anchor.  Are there satoshis in an ephemeral anchor normally?  Should there be?

**Greg Sanders**: Right.  So, most discussion when we talk about ephemeral
anchors is, "It would be nice if we could have zero-value outputs".  And there's
a bunch of good reasons for this.  If you have CTV activated, for example, this
would be a great way of paying for fees in a CTV transaction, where you have
this state transition happen, and then someone does a CPFP that brings the fees
using this zero-value anchor.  But there's actually flexibility here that the
output is identified as an ephemeral anchor by the scriptPubKey itself, not the
value itself.  So, you're allowed to have any value there.  And this comes into
play with other protocols where the LN spec allows for Hash Time Locked
Contracts (HTLCs) that are too small to be viable to be what they call trimmed,
which means you basically remove that output from the commitment transaction,
don't actually include it, and you dump those satoshi values to transaction
fees.

One wrinkle here is that with the ephemeral anchors case, we don't want a
transaction from ephemeral anchor to include its own fees because that
incentivizes a miner picking up that transaction by itself, leaving dust in the
UTXO set.  So, it also simplifies implementation as well, but basically there's
these two points, that we want an ephemeral anchor transaction to have zero
fees, but we want to be able to put that value somewhere, and the most natural
place to put it would be in the ephemeral anchor itself, in the LN case.  So,
depending on defaults and whatnot, you could have up to, I did some math, with
modern channels with default configuration, you get something like 13,000 to
30,000 Satoshis sitting in an output that would be freely grabbable by anyone.
So, it's kind of the practical result that sets up this scenario.

**Mike Schmidt**: So, due to these trimmed HTLCs, essentially there are some
extra satoshis lying around.  And if they end up in an ephemeral anchor, we end
up with the MEV case that you outlined earlier, obviously not with 1 bitcoin,
with a smaller amount, but it can sort of mess with the incentives?

**Greg Sanders**: Sorry, can you use that question again, I missed it?

**Mike Schmidt**: Yeah, I was just maybe paraphrasing what you said.  Did I get
that right?

**Greg Sanders**: I think so, yeah.

**Mike Schmidt**: Okay, so we noted the alternative solutions that were
proposed, three of them, only relaying transactions that are fully miner
incentive compatible being one; two, burn trimmed value; and then three, ensure
that MEV transactions propagate easily.  Any of those that you'd like to
double-click on?

**Greg Sanders**: Let's see.  So, the first one was incentive compatible.  The
second one was which one?  Sorry, I'm not at my computer right now.

**Mike Schmidt**: The first one, yeah, miner incentive compatible; burned is
two; and then ensuring propagation is three.

**Greg Sanders**: Yeah, so I think ideally what you do is you have bots sitting
around the network, and I think this is BlueMatt's point, you'd have bots
sitting around the network, or scripts running, that would notice this and then
immediately burn it to fees, because that's kind of the natural thing.  In many
cases, it would be enough fees to get a transaction confirmed anyways, and so
maybe it's useful just to do that.  So, you could have essentially bots front
running and sending it all to miners.  And while that's true in an
incentive-compatibility way, the problem is imagine that if you're doing a race
condition where someone wants to take the fees, then they can front run those
front runs and add an additional satoshi in fees to whatever transaction they
make.

Or actually, no, you don't even have to do that.  They send it to themselves and
you don't even have to add additional fees.  So, when they do the replacement
check, so RBF rule 3 will say, "Does it have as many Satoshis in the placement?"
Yeah, but the fewer burn to fees would not satisfy the incremental relay fee.
So essentially, whoever gets there first is kind of an incumbent, and there's
incentives for the incumbent to be someone who's just taking fees for
themselves.  So, in that case, you'd have to be relying on miners running their
own software on the side that do this kind of analysis and swap-out if
necessary.  So, that's kind of one way you could do it.

I think the better way to do it is probably to front run that just
automatically.  So, when a node gets an ephemeral anchor transaction and child,
rather than submitting a new child, kind of front running and submitting it, we
just imagine we're doing an RBF.  So, you simulate the pure burn RBF, say, "Does
this beat incentive-compatibility-wise a pure burn RBF?"  And if it does not,
then you reject it; if it does, you accept it.  So, this reduces the incentives
to where someone will send funds to themselves or use those output value to pay
for their own transactions.

**Mike Schmidt**: We noted that there was no conclusion that seemed to have been
reached at the time that we published the newsletter yesterday.  Would you agree
with that?

**Greg Sanders**: No, so we don't need agreement on this, which is the good
part; this is just like relay policy.  So, my current plan is, first, I'm
working on importing some of the cluster mempool logic that you guys have been
talking about, called the diagram checks, which does a proper incentive
compatibility check.  My plan is to apply those diagram checks to the case where
you're conflicting with a size 2 cluster, right, so parent-child, yeah,
conflicting with the child of a size 2 cluster, and then do proper
incentive-compatibility checks on that.  And then I'm just going to filter out
anything that doesn't beat a pure burn RBF in a diagram check, because the
diagram check code is going to be there for other reasons anyways, and it's
really simple to apply, so why not?  That's my conclusion for now.

**Mike Schmidt**: Murch, James, any comments or questions?

**Mark Erhardt**: So, there was one thing.  I'm not sure, you probably covered
it already in your writings, but could you clarify maybe?  So, if the problem is
that the miner is front running, spending the ephemeral anchor, that means that
they can collect the money from the ephemeral anchor, but the transaction gets
confirmed so mission accomplished.  So, how is that a problem?

**Greg Sanders**: Oh, we just don't want to make miners have to run bespoke
software to be as competitive as other people.  We want mining software to be
dumb and easy.  That's all.  I agree from a security perspective, from a smart
contract security perspective it's not a problem, but I'd rather relay mining
code be stock and people make money doing that.  Obviously, you can't mitigate
all circumstances if people do weird stuff that opens up MEV in other ways.  But
if I'm proposing a way, I don't want to propose a way to increase MEV inherently
on a popular protocol.

**Mark Erhardt**: Yeah, that's fair.

_LDK 0.0.119_

**Mike Schmidt**: Greg, thanks for joining us.  You're welcome to stay on.
We've wrapped up the news section for this week.  We have one release to cover,
which is LDK 0.0.119.  The headline feature that we highlighted here in the
newsletter is receiving payments to multi-hop blinded paths, which we've
actually covered in individual notable PRs in the last months.  Additionally,
this release has 280 commits from 22 authors, which includes bug fixes, category
of changes related to performance improvements, a bunch of API updates, and some
notes about backwards compatibility.  So obviously, LDK node operators and
users, check out the details in the release notes for all of the details there.

As we move to the Notable code and documentation changes, I'll take the
opportunity to solicit any questions from the audience, whether you want to
request speaker access or leave a comment on the thread here.  We'll try to get
to that by the end of the show.

_Bitcoin Core #29058_

Bitcoin Core #29058, which makes some changes in preparation to have v2
transport the default.  So, if v2 transport is enabled, this PR now will allow
Bitcoin Core to use v2 for -connect, -addnode, and -seednode; and additionally,
also adds a field to the output table from netinfo that notes v1 versus v2
transport, sort of a reporting mechanism.  Murch, may have more to say on this.

**Mark Erhardt**: Not really much.  So, v2 transport was rolled out with the
last major release, of course, but currently it only is used if both nodes that
are connecting organically already have it active.  You can't just reach out to
a specific node and connect to them with v2.  It will always use v1 protocol if
you use -connect or -addnode in the last release.  So of course, in the long
term, we'd like to transition all of our nodes to that new v2 protocol and to
that end, it needs to be supported by all of the mechanisms that we use to
connect to nodes.  And we still need to be backwards compatible so that when a
counterparty does not speak the new protocol, we can fall back to the old one.
So, this is just more of the groundwork to be able to default on.

**Mike Schmidt**: So, that optimistic and fallback mechanism is not something
that's in 26, is that right?

**Mark Erhardt**: I don't think so, no.

_Bitcoin Core #29200_

**Mike Schmidt**: Bitcoin Core #29200.  So, a Bitcoin Core node using I2P may
only connect to I2P peer destination if both sides have sessions with the same
encryption type.  So, I2P supports multiple encryption types.  This is an
anonymity network similar to Tor.  And since Bitcoin Core is not currently
setting the encryption type before this PR, when Bitcoin Core was creating I2P
connections, it used the default encryption type labeled type 0.  And after this
PR, Bitcoin Core's I2P session creation uses both type 0 as well as the new type
4, which will allow Bitcoin Core to connect to I2P pairs of either type, and it
will also then use the newer, faster type 4 as preferred type.  I didn't get
into any of the encryption jargon.  Murch, I don't know if you're familiar with
any of those types of encryption or you think it's worth noting anything there?
All right.

_Bitcoin Core #28890_

Bitcoin Core #28890, removing the -rpcserialversion configuration parameter that
was previously deprecated.  We covered the deprecation and discussed that
rationale behind that in Podcast #269.  That was a configuration option that
allowed users to specify the format of the raw transaction or the block's block
hex serialization, and allowed users to continue to access blocks and
transactions, but without any of the segwit fields.  As segwits then rolled out
and adopted widely, that configuration parameter was deprecated and now removed.
Anything to add, Murch?

**Mark Erhardt**: I just want to steelman how this is a good thing, because
segwit's been in Bitcoin Core since 0.13, which is now 13 major releases ago,
and it's been active since August 2017.  So, we're a push six-and-a-half years
ago.  If you're still using non-segwit and are opposed to reading full blocks,
of which over 90% of the transactions are segwit transactions, you're probably
on the wrong network.

_Eclair #2808_

**Mike Schmidt**: Eclair #2808, allowing users of Eclair to specify the maximum
amount that their node is willing to pay in onchain fees in order to open a
channel.  The way that you do that is a parameter titled
--fundingFeeBudgetSatoshis, and that parameter is available for the open RPC.
And the default of that parameter is set to 0.1% of the amount paid into the
channel, and that same parameter is also used in the rbfopen RPC in order to
specify that funding amount.  And from the PR, it also notes, "It will work with
both the single- and dual-funding cases.

_LND #8188_

Next PR, LND #8188.  Oliver, thanks for hanging on for us.  It's been 70
minutes, but we got here.  This PR to LND adds features for getting debug
information, encrypting it to a public key, and decrypting it given a private
key.  Oliver, maybe you want to get into that a bit and why this might be
interesting.

**Oliver Gugger**: Yeah, sure.  Thanks for the invite, and thanks for the
newsletter by the way as well, always love it.  So, yeah, the PR basically
solves two problems that we commonly have.  The first part is that we now
finally have an RPC that just returns the current configuration of LND as LND
knows it, so fully parsed and combined from command line arguments and the
config file.  So, that should be very helpful to just get that over an RPC, and
as well as the last lines of the log file.  So, because that now can be exposed
over RPC, it will also be easy for UIs or wallet softwares to display this.
Before, the user had to go into the command line to get the log files or find
out what the config is.  So, this alone is already a great addition.

Then, I went one step further, and that we basically added the common line
command that collects a bunch of info about the node, puts it into a text file
and encrypts that for a given public key.  And the reason for that is that
usually if a user has an issue and they open issue on GitHub, we request logs
and config options and basically all the information we need to find out what
the problem is.  But then, users usually just post it with all their public keys
and channel points and all the kind of privacy-sensitive information still in
there.  So, they kind of have to dox themselves, which isn't always nice.  Or,
if users are very sensitive about that, then they're redacted to the point where
the logs aren't useful anymore.  So, this command helps in a way that it just
encrypts the whole thing for a receiver, so that the receiver will need to
provide a public key, and then basically this information can be delivered in a
complete, but privacy-preserving way.

So, yeah, I hope that the wallets will start adding the log file and config
display option.  And then I guess the next step for us would be to provide a
public key so users can start sending encrypted debug information.

**Mike Schmidt**: So, it protects that important and potentially identifiable
information that is maybe now floating around in GitHub issues, or I guess even
if you're worried about someone spying on your email if they're interacting with
you, that can now be encrypted.  And you all on your side will have access to
decrypt that in order to help folks troubleshoot, so you'll have a team there
that would be able to decrypt that information and then help troubleshoot
accordingly.

**Oliver Gugger**: Correct.  And also, that the command just assembles all the
information we normally request in separate commands, with just one command.
So, we get more information that we might have gotten previously, but in a more
privacy-preserving way.  So, it's hopefully a win/win for both sides.

**Mike Schmidt**: Is there a precedent already for projects doing something like
this, or is this kind of the first of the kind that you guys are blazing a
trail?

**Oliver Gugger**: I have no idea.  I'm sure there must be, but I don't have an
example present.  It's just something we discussed for a long time.  We had
other ideas in mind, but then I just had some time on a weekend and just coded
it, and hopefully it will be used.

**Mike Schmidt**: So, I guess it's a good idea for other software projects who
are similarly collecting that information from their users, maybe take a look at
what Oliver and the LND team have done here and see if there's some way that you
can protect your users as well in similar scenarios.  Maybe that would be the
call to action for the audience.

**Oliver Gugger**: Yeah, that would be great.

**Mike Schmidt**: Oliver, thanks for hanging on, thanks for joining us, thanks
for blazing the trail here.

**Oliver Gugger**: Yeah, cheers.

**Mike Schmidt**: Oliver, you may --

**Mark Erhardt**: There's two more LND commits, I was just going to say!

**Mike Schmidt**: I think I just put that together in my brain!  Oliver, you may
be able to help augment these two PRs.  I know I didn't brief you on that, so
maybe it would be a bit off the cuff.  Are you familiar with the next two/three
PRs that we're covering here?

**Oliver Gugger**: I mean, I've definitely seen them, but I wasn't involved in
the review, so I'm not sure how much context I can give you, but we could try.

**Mike Schmidt**: Okay, well, I can take a crack at giving a summary and then
maybe you can jump in with some of your bespoke knowledge on the topics if
applicable.

_LND #8096_

LND 8096, adding a, "Fee spike buffer" to address potentially stuck channel
issues.  So, a scenario can arise where if the channel funding party doesn't
have many satoshis in the channel, and if feerates spike, the funding party may
not have enough to be able to accept an incoming HTLC payment because they don't
have enough funds to pay for its fees.  So, even though they are the ones
receiving an incoming payment which would increase their balance, they're not
able to accept that.  So, the suggestion from BOLT2 is that the person funding
actually keep an extra reserve of satoshis to ensure additional payments can be
received, and now LND implements that specific recommendation.  We also linked
in the newsletter to the fact that that was implemented quite a bit ago by CLN
and Eclair to mitigate similar issues.  Oliver, any comments?

**Oliver Gugger**: I think you summarized that pretty well.  I guess we just
basically missed this change in the spec and were late in implementing it, and
this caused interop issues with CLN and Eclair, especially during the high fee
spike.  So, yeah, I'm very happy that we could address and fix this.

_LND #8095 and #8142_

**Mike Schmidt**: Last two PRs are both to LND as well, #8095 and #8142.  Both
add more plumbing to LND to be able to handle blinded paths.  So I guess
similar, Murch, to the slew of blinded-paths-related PRs that we had in the last
months from LDK about blinded paths, it now appears that you and I can go
through covering a similar set of PRs for LND for the next couple months.
Specifically, #8142 is titled, Expands Validation of Blinded Routes, which is a
fix for a bug that was surfaced via fuzz testing, it looked like.  And #8095 is
titled, Add Invalid Onion Blinding Handling for Blinded Paths, and that includes
a nice series of diagram images, which could be helpful for folks curious about
the internals of blinded paths.  Oliver, anything to add on Blinded Paths in
LND?

**Oliver Gugger**: Unfortunately not.  It's an area I'm least involved in, but
I'm super-happy about all the progress that's being made.  And as you mentioned,
it's just two PRs in a series of, I think, quite a couple more that are needed
to get this fully working.  But yeah, we're excited to get a lot of movement
here.

**Mike Schmidt**: Excellent.

**Mark Erhardt**: I wanted to actually jump back to the previous topic a little
bit.  It's kind of funny how the channel reserve is sort of the -- well, also
I'm a little out of my element here, because I have basically a superficial
understanding of how lightning works under the hood.  But the channel reserve is
kind of a tricky topic, because it is supposed to prevent the other party from
closing the channel out of turn and stealing funds, and to have a minimum
punishment penalty available.  But it's also set to something like 1% of a
channel and it is therefore so small that a well-prepared adversary that just
first pushes all the funds to the other side can minimize their risk for an
attempt of closing a channel out of turn.  And it's also the source of a bunch
of headaches like this, "Oh, because the channel reserve is too small, I can't
actually receive funds because I won't be able to increase my commitment
transactions fees to the point where I, as the funder, can pay for it".

Maybe in the whole context of us talking about LN-Symmetry earlier, this is one
of the reasons why LN-Symmetry would be so much easier as an update mechanism,
because the fee-paying is actually pushed back to the point where you actually
want to submit the commitment transaction, and you bring the fees in another
input to the transaction.  I see that Dave is requesting speaker access.

**Mike Schmidt**: We're in trouble; Dave's here!

**Mark Erhardt**: He probably has some corrections for what I'm just talking
about.

**Dave Harding**: So, I think this reserve that we're talking about here for
this PR is separate from the channel reserve.  So, this is just about covering
the fees necessary to add an HTLC to a commitment transaction.  So, if you added
HTLC, you would add an output, it makes the commitment transaction bigger.  And
you also need to pay for the HTLC success or timeout transaction, which also
requires onchain data.  And in the pre-anchors LN protocol, all those fees need
to be paid for by the party who funded the channel.  This is in single-funded
LN.  And in anchors, that party still needs to pay a minimal amount of fees,
enough to get the commitment transaction into mempools.  And it gets, I think
it's zero for HTLC-X transactions now.

So, this is a separate and completely voluntary reserve, and it's not so much of
a compatibility issue between the implementations, as I understand it, as it is
an issue of if that party doesn't have a voluntary reserve, it just can't pay
for the fees, and so its counterparty is just not going to allow it to accept
any funds, and so the channel gets stuck and there's just nothing it can do
except close at that point.  So, it's just a voluntary reserve.  I think there
are those concerns with the penalty being so small, but I think this is a
completely separate issue.

**Mike Schmidt**: So, we have channel reserve and now we have this sort of
fee-buffer reserve separate.

**Dave Harding**: Yeah, buffer is a great name.  I probably should have used
buffer.

**Mark Erhardt**: One follow-up here.  Why would the channel be completely
stuck?  Couldn't the recipient just reject the inbound payment and then wait for
the fees to go down?  Or do you mean stuck just while the fees are high?

**Greg Sanders**: With the current protocol, duplex protocol, there's no way of
rejecting a payment like that.  You have to accept it and then fail it.  Rusty
has a proposal to switch to simplified updates, which would be kind of
synchronous, and then you could bolt on a fast fail message onto that, and so
perhaps that would be possible.

**Mark Erhardt**: Okay, second follow-up question, especially while you're here,
Greg.  If the channel update mechanism moved to LN-Symmetry, I would assume that
the HTLC outputs would also be subject to the fees being brought later, because
all of the update transactions cannot have fees, right?

**Greg Sanders**: Correct.  It requires zero-fee update transactions, which
spurred a lot of the current work for LN today.

**Mark Erhardt**: All right, I rest my case.

**Mike Schmidt**: I don't see any questions or comments from the audience, so I
think we can wrap up.  Thanks to our special guests, Oliver, Greg, Chris,
Brandon.  Thanks to Dave for joining us to clarify at the end there, and thanks
always to my co-host, Murch, and for you all to listen.  Cheers.

**Mark Erhardt**: And thanks for James for jumping in and talking to us too.

**Mike Schmidt**: Yeah, thanks James.

**Mark Erhardt**: All right, hear you next week!

**Mike Schmidt**: Cheers.

{% include references.md %}
