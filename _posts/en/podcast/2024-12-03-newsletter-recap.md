---
title: 'Bitcoin Optech Newsletter #331 Recap Podcast'
permalink: /en/podcast/2024/12/03/
reference: /en/newsletters/2024/11/29/
name: 2024-12-03-recap
slug: 2024-12-03-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Anthony Towns to discuss [Newsletter #331]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-11-9/391258082-44100-2-b0cbe926a0df1.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #331 Recap on
Riverside.  Today, we're going to be talking about the Bitcoin Lisp language; we
have nine questions from the Bitcoin Stack Exchange, including questions about
ColliderScript and a couple of questions on pay-to-anchors (P2As); and we also
have our usual segments on Releases and Notable code changes.  I'm Mike Schmidt,
contributor at Optech and Executive Director at Brink where we fund Bitcoin
open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin stuff.

**Mike Schmidt**: AJ?

**Anthony Towns**: Hi, I'm AJ, I'm a Bitcoin Core dev with MIT DCI, and these
days I'm working on Lisp stuff.

_Lisp dialect for Bitcoin scripting_

**Mike Schmidt**: Well, that's a good segue.  We're going to go through the
newsletter sequentially here, with our first and only News item being about that
Lisp dialect for Bitcoin Scripting.  AJ, we covered the progression of what was
once called BTC Lisp over the last couple years.  In 2022, you posted to the
Bitcoin-Dev mailing list about the idea and we covered that in Optech Newsletter
#191.  And then, in 2023, we covered a discussion about comparing something like
BTC Lisp to existing Bitcoin Script, with some additional opcodes, and that was
in Newsletter and Podcast #275.  And then this year, earlier this year, we
covered your Delving post titled, "Overview of Chia Lisp for Bitcoiners", and
that was in Newsletter and Podcast #293.  And in this newsletter, we covered
several of your recent posts about Bitcoin and Lisp.  Maybe for those that
didn't hear or don't recall those previous discussions, maybe you can quickly
summarize your motivations and goals for the project, as well as your research
around there?

**Anthony Towns**: I feel like maybe the best way is actually jumping into the
second point, which is comparing the Winternitz post-quantum signatures between
the great script restoration approach and the Lisp one.  So, my original
thinking that got me on to thinking about Lisp in the first place was that there
are two things that you can't really do in Bitcoin Script as it stands, and that
are really difficult to do, even if you think about simple improvements to
script.  And those things, one of them is just looping.  There's an 'if'
construct in script which lets you do branching, but there's no 'go to' or
'while' or 'for' or any sort of looping construct that lets you do the same bit
of code multiple times with different parameters, or any sort of thing you'd do
looping or recursion for.  And the other thing that it can't really do is
structured data.  So, it's got its stack, it's got its alternative stack, and
you can put little strings of data on the stack and that's about it.  So,
there's no classes, there's no arrays, there's no dictionaries or hashes.  And
you can still do pretty much everything with just a stack, but it makes any sort
of programming you want to do a lot harder.

So, Jonas Nick posted on Twitter about his implementation of the Winternitz
One-Time Signatures (WOTS) in his implementation of Rusty's enhancement of
script, to do everything that Satoshi originally thought it should be able to
do.  So, bringing back CAT, bringing back multiplication, bringing back big
integers, and all of that stuff, but it still doesn't have the structured data
or the looping.  And so, what that means is that a couple of things that you
want to do with a WOTS is calculate lots of merkle trees, because merkle trees
is the approach that uses to be quantum resistant.  And to do a merkle tree, you
need to look at all the individual leaves and hash them together and hash those
together and hash those together and hash those together up to 16 levels.  And
then you want to combine 64 of those things.  And that's just doing the same
operation a bunch of times, which is what looping is perfect for.  But since
script and GSR both don't have loops, you have to write the code out for that
for every possible iteration, which makes your program 16 times 64 times larger
than it would be if you could just write a simple loop.

There are obviously a million different programming languages all with their
million different ways of doing looping.  I picked Lisp because it gives you a
general language, but has kind of the simplest possible way of going from basic
opcodes to being a full language.  Like, it doesn't introduce type analysis, it
doesn't have three or four different ways of doing the same thing that are more
convenient in different scenarios, it's just got very basic building blocks that
seems to me like a good fit for a consensus language.  So, that's where I was
coming from with that.

**Mark Erhardt**: Cool, that sounds good so far.  So, you implemented the
Winternitz signatures, demonstrated that it's significantly smaller, like a
sixth or maybe even a twentieth of the size.  So, do you want to get into the
bll (Basic Bitcoin Lisp language), symbll (symbolic bll), bllsh (bll shell) from
here?

**Anthony Towns**: So, I pronounce them, 'bll', 'symbol' and 'bullish'.

**Mark Erhardt**: Oh, I see!

**Anthony Towns**: Yeah.  So, when I was working on BTC Lisp last, I got some
replies, and the one that matched what I was feeling trying to write demo
programs in it most was that you really need to have it be somewhat
straightforward to write code, and have it be something that you can debug once
written.  And so, one of the natural ways of doing Lisp is that you can write
Lisp programs that manipulate Lisp programs really easy, because everything's a
Lisp, both all the data and all the programs.  But when you write a program that
manipulates another program, and then you want to run that other program, you've
got to understand both the program you've written and exactly how it's been
manipulated to be what gets told to the computer.  And that gets you into the
same sort of problems as debugging macros in C and templates in C++.  And I
mean, we write templates in C++ and debug them, so it's not impossible, but it
gets really complicated and confusing because you've got to hold a lot more
stuff than just what you wrote in your head to do the debugging.

So, I banged my head against that wall for a while and eventually decided that
this is stupid.  What you want to do is have the high-level language that you're
writing code in, you want to be able to step through that and debug that
directly without having to worry about any code rewriting or compilation, or
whatever going behind the scenes.  So, that made me decide essentially that you
really want two languages.  You want the consensus one that can be compiled to
and run in the consensus code base, but the code that you're writing in, you
want to be able to interpret that pretty much directly too.  And so that's what
the difference between bll and symbll is.  Symbll is a slight variation on bll
that makes it much more pleasant to code in, like you can name variables and
have functions, and you can have 'ifs' that don't execute both sides of the 'if'
every time.  And those all have straightforward translations into bll, but don't
really make it cost significantly more or anything else.  So, they're things
that you can not worry about and not be too surprised by the things that you're
ignoring there.  But it is, in a sense, it's interpreted in the debugger as a
language of its own.  So, when you step through in the debugger, you're not ever
seeing anything but symbll code.

**Mark Erhardt**: Right, so -- sorry, go ahead.

**Anthony Towns**: Bllsh here is that debugger which lets you do a REPL-like
view of both symbll and bll code as you see fit.

**Mark Erhardt**: So, basically you extended your original language, bll, with
two further tools to make just the user interface for would-be developers that
want to write in those languages much more accessible?

**Anthony Towns**: Yeah, so the BTC Lisp stuff I was doing, if you wanted to
execute that, you had to edit the .py file and make an explicit function call to
run stuff.  So, having a REPL for it is so much better, even just for me.  And
the Python REPL code's actually pretty cool because you can hook it into
readline and do 'up arrow' and 'save history' and stuff.  So, that was like, I
don't know, 20 minutes of work and 100 lines of code or something, and it is
just an order of magnitude improvement.  And because it's now interactive, you
can put in step-through debugging and printf debugging and actually make that
also much more easy to develop.  And it's still kind of simplistic and basic,
like you write your list of expression on one line; you can't make a multiline
list program and indent it and make it really nice like that.  It's all
one-line-at-a-time coding, but I mean still pretty preliminary sort of thing,
right?

**Mark Erhardt**: Okay, cool.  So, at what stage are you now with your Bitcoin
Lisp project or bll, Bitcoin Basic Lisp language, I guess?  So, you've clearly
been able to use it to implement both this quantum-safe WOTS and the flexible
coin earmarks that seem to be a development or evolution from
OP_TAPLEAF_UPDATE_VERIFY.  So, would you say that it's ready for other people to
start playing around with?

**Anthony Towns**: It's totally ready for other people to start playing around
with.  So, there are examples of how you can simulate both the BIP342 ...  So,
in Bitcoin, when you have a signature of a transaction, there are kind of two
calculations that you do.  One is you collect all the interesting bits of the
transaction and hash it together.  And you take that as the tx message, which is
in this case defined in BIP342.  And the second calculation is you take that
hash that you calculated and plug it into schnorr signing from BIP340, and that
produces the actual signature.

So, one of the things that I've obviously been thinking about for a while is the
noinput, anyprevout sighash (signature hash) idea.  And so, that is basically a
different way of grabbing a hash that would then be put into the schnorr
signature.  And so, one of the nice things about a general programming language
is that you'd be able to implement these ideas without needing a consensus
change, because you've got all the power to do that calculation by writing a
clever script, without needing to go and update everyone's node to make a really
efficient implementation of whatever new functionality you've got.

**Mark Erhardt**: So, one second here.  The sighash opcodes, they live at a
different level than the input script and output script of UTXOs.  So, I assume
that you would have to do a new sighash or something in order to be able to have
it at the bll level later, or how would that plug together?

**Anthony Towns**: So, the replacement for the CHECKSIG operator in script in
bll is two opcodes, one of which is to calculate the sighash, and the other of
which is equivalent of OP_CHECKSIGFROMSTACK (CSFS).  So, instead of taking two
parameters, the pubkey and the signature, it takes three parameters, which is
the pubkey, the message to be signed and the signature, which is the same three
parameters that BIP340 specifies.

**Mark Erhardt**: Okay.  And the message could be constructed on the stack using
bll?

**Anthony Towns**: Yeah, so the tx message opcode that's in there now just takes
a 1-byte parameter, that is the sighash byte from signatures currently.

**Mark Erhardt**: Okay, awesome.  Yeah, I see.

**Anthony Towns**: So, the idea is that you're able to replace a call to tx
message with your own code that can calculate the correct sighash of whatever
you want to be signing that way.  And so, I've got an example code in the bll
Lisp that calculates the exact SIGHASH_ALL hash via tx introspection, rather
than just handing it off to the tx message thing.

**Mark Erhardt**: Okay, yeah, cool.  So right now, sighash is of course tied to
an input, because the sighash flag is input dependent.  And you solve that by
changing how signature checking in the input script works in the bll language,
where you can either use something that essentially reimplements the current
behavior with the sighash flags, or you can just outright do it as a CSFS, where
you would provide your own message to be checked, and that could be constructed
on the stack with the bll codes.  So, if and when that whole bll language would
be implemented as presumably a new taproot leaf version, I assume?

**Anthony Towns**: Yeah.

**Mark Erhardt**: Yeah.  Then you would be able to be extremely flexible because
you can just essentially, on the fly, create your own signature checking
mechanism by defining what the message is that needs to be signed, and
potentially even, on the fly, calculating that in the transaction on the stack.
Yeah, that sounds very flexible.

**Anthony Towns**: Yeah, so there's an example in there in the repository of
doing that for SIGHASH_ALL.  And so, to turn that into one that didn't look at
the inputs, you would delete the parts that look at the input.

**Mike Schmidt**: Right.

**Anthony Towns**: There's likewise a thing that calculates the taproot
scriptPubKey, given essentially the control block and the script information, so
it does the merkle calculation and it does the internal public key addition
stuff, like the multiplication and adds, in ECC to do that.  And there is also a
direct implementation of BIP340 in terms of secp, again, multiplication and adds
in ECC curves.

**Mark Erhardt**: Very cool.

**Anthony Towns**: Yeah.  So, those are relatively easy to test correctness for
because you can just compare them to real transactions.  But I think they're
also kind of useful building blocks, and that's something that people could look
at if they get into it.

**Mark Erhardt**: Yeah, so did I catch that right that you said you are
reimplementing essentially the OP_INTERNALKEY BIP with the extracting it from
the control block?

**Anthony Towns**: Yeah.  So, there is just a tx opcode in there that has 20-ish
parameters, which will get you all the different parts of the transaction, so
the nSequence, the nLockTime, the parent txid, the stuff about the UTXO being
spent, the output value.  So, when you have a transaction and you're verifying
it, you have the prevout from the UTXO set that it's being verified against, and
you need that information for exactly what I was just saying.  One of the things
that BIP342 specifies that you're signing is information from the prevout, so
you're signing the scriptPubKey that you're spending, for instance, and the
amount that you're spending.  So, in order to reimplement that, I had to make
that accessible to the Lisp code, and all of that stuff is in the tx opcode.

**Mark Erhardt**: So, it sounds to me that it would be pretty simple to simulate
something like CTV (OP_CHECKTEMPLATEVERIFY) or OP_TXHASH from that, because you
can pick and choose which parts of the transaction you want to put on the stack.
You have CSFS already, so you can sort of have these transaction introspection
things.  Yeah.

**Anthony Towns**: It's very similar to, I believe, the OP_TXHASH spec that I
looked at.  It's a little bit more verbose because this gives you a bit more
structured data room to give parameters to things than you can easily do in
script, and it obviously doesn't automatically hash things afterwards.  But
yeah, otherwise it's very close to that.  I haven't looked at exactly simulating
CTV, but approximate simulations, like the tx message, is already calculating
something very similar to the CTV hash.  So, changing that to be an exact match
for CTV wouldn't be very hard.

**Mark Erhardt**: So, would it make scripts much bigger to manually redo all
these other opcode operations, because you have to sort of specify which parts
of the transactions are relevant, and so forth; is that a downside here that the
script has to replicate all the parts of what happens in these packaged opcode
proposals?  Would that be right, or am I misunderstanding?

**Anthony Towns**: So, all the packaged opcodes are more or less duplicated in
the opcodes I've got.  So, like I said, OP_CHECKSIG is now two opcodes instead
of one.  So, that might be 4 bytes to encode instead of 1.  And if you want to
implement your own thing, like OP_ANYPREVOUT (APO), then yes, that's a lot more
bytes than if someone had put it in consensus as just a single-byte thing.  But
they're not an extreme number of bytes; it's like going from single-sig to
3-of-3 multisig, or something like that.  That's about the sort of size that it
seems to be getting.

**Mark Erhardt**: And how extensible would this approach be?  So, whatever, if
someone implements their own take on OP_VAULT and it becomes super-popular and
then you want to put it in as a pre-packaged operation in bll, would that just
be a soft fork or how would more stuff be added?

**Anthony Towns**: So, I haven't implemented it.  I've kind of spec'd it out,
but there is a soft fork opcode which takes as a parameter an expression that is
evaluated in the context of some future specified op_fork.  So, it should be
flexible in that way.  This is the approach that they use in Chia Lisp, so it's
already battle tested in that sense.

**Mark Erhardt**: So, is that sort of like OP_SUCCESS, or it's more like an
OP_NOP?

**Anthony Towns**: It's kind of both.  So, it's an OP_NOP in the same sense that
it just returns nil.  The way that you write the code that goes in it has to
throw an exception and fail the transaction; it can't return data because
there's no way of doing that.  But it's much more like an OP_SUCCESS in that the
code that's within that expression, that you as a scriptwriter give to it, can
do anything.  So, you can introduce a new elliptic curve, you can do efficient
calculations on that curve, you can come up with the results, you can compare
the results to each other, as long as the end result of all that calculation is
throwing an exception or saying, "Yeah, everything's fine".

**Mark Erhardt**: All right.  May I throw you a curve ball?

**Anthony Towns**: You can try!

**Mark Erhardt**: So, if you approach this from a different angle, what problem
are you solving with your bll proposal?

**Anthony Towns**: At a higher level than lack of loops and lack of structured
data, right?

**Mark Erhardt**: Okay.

**Anthony Towns**: So, let me answer the question as I think you've asked it.
Having done signet for a couple of years now and trying to get test soft forks
and stuff on that, the thing I've been most surprised at is how hard it is to
actually get what seemed like pretty simple soft forks to a reasonable state of
code, like CI's passing, doesn't have any obvious bugs, it kind of looks like it
works all right.  So, I had thought CAT would be the absolute simplest example
of that and take like half a minute to get in and deploy, because it's already
been there, it's available in Liquid, we know what it does, there's some level
of interest in messing around with it.  And that took, I don't know, four or
five months or something to get into signet, which really doesn't have that
higher standard for code quality, and like, it's not going to lose anyone any
money and stuff if it goes in, right?  Obviously, CTV and APO and the new IPK
and CSFS and stuff have also been really slow to progress.

So, that's made me much more enthusiastic about the idea that we get some sort
of general language available so that people aren't trying to change consensus.
They can just focus on writing their own scripts, because I mean that's hard
enough, let alone consensus changes.

**Mark Erhardt**: Yeah, I mean people should be reminded occasionally that when
they come up with a new transaction mechanism or like input script type, they're
designing a cryptographic interface or a cryptographic protocol.  So, yeah, it's
harder than it looks.

**Anthony Towns**: Yeah.  And so, you've got all that hardness in just
specifying a protocol.  And then when you're trying to do consensus changes,
you're trying to come up with a language that makes doing good protocols easy
and makes doing bad protocols hard, ideally at least one or the other.  And I
mean, there's few enough people that know how to do just the development thing.
Finding anyone who knows how to make that development thing easy and whatever, I
don't know, it's a hard problem.  And yeah, the other thing is even if none of
this makes it into mainnet consensus, just having it be something that's
available for testing out ideas and having a quick proof of concept also seems
like a win to me.  I don't know.

**Mark Erhardt**: Okay, cool.  So you would, well, maybe not be as excited, but
it would already be a win if you had it available in signet for people to be
able to prototype soft fork behavior that they want to pursue, and it might make
it easier to get stuff running on Inquisition or signet in general.  And that
way, making a first draft and concept and being able to play around and testing
stuff wouldn't require the heavy lift of making Bitcoin-Core-compatible soft
forks before they can be merged in signet; and making those compatible with the
other soft forks that are being tested on signet potentially, in conflict with
various things, various aspects of the software that various people are
pursuing.  Yeah, that sounds interesting.

So, I have been staring at the, "Flexible coin earmarks", thing a couple of
times, and I must admit I don't think I fully understood what you were doing
there.  Do you want to get into that?

**Anthony Towns**: Sure.  Do you have any specific questions?

**Mark Erhardt**: So, it sounded like you were able to spend UTXOs in a
predefined manner, such that the change had to come back to you, and you could
create other outputs, but the mechanism of that eluded me.  And what would it be
used for?  Or, yeah, could you maybe describe it at a high level again, what it
is and how it would be used?

**Anthony Towns**: So, I guess we'll go with the eltoo example.  The idea of
eltoo, not L2, is you have Lightning channels.  The Lightning channel has a
funding transaction that is on chain.  It is essentially a 2-of-2 signature that
to be spent, has to be signed off by both channel parties.  And the eltoo
approach is to say that, okay, we'll establish these offchain spends and we'll
update them each time there's a new state, and the way we'll set them up is that
if someone pushes an old state onchain, then any later state can be used to
spend that spend as well as the original funding transaction, and so on
recursively.  So, if someone tries to cheat by spending an old state, that's
fine, we'll just update it to the latest state and no one's any worse off.

**Mark Erhardt**: Right.  Each transaction binds to all predecessor transactions
and can spend their output.

**Anthony Towns**: Yeah.  And that's something that SIGHASH_ANYPREVOUT was
designed to allow.  But the thing that it doesn't really deal with is some of
the complexity when you've got some open payments pending in the channel when
you're trying to close it.  So, the idea is that when you close the channel
onchain and publish its latest state, you have maybe, I don't know, maybe 200,
300 blocks of wait time, which is to give your counterparty a chance to publish
a later state so that you don't just steal all the money straightaway.  But the
problem is that in that 300 blocks of wait time, one of the pending payments on
your channel might expire and you want to reveal the hash preimage to claim the
funds that have gone through.  But if you wait the 300 blocks, the timeout's
occurred and that means the other guy can just take the funds from that HTLC
(Hash Time Locked Contract).

The way that we do that currently is that in the LN-penalty model, we have
different outputs for all the HTLCs on channel and you can update the output for
that particular HTLC, so that it goes from being claimable by either the
preimage or the timeout or by proof of someone cheating, to just be claimable by
my signature after a delay, because I've already revealed the preimage; or, by
the other guy proving that I cheated and published an old state.

**Mark Erhardt**: Right, so thinking about this, yes, the channel closure, or I
think it's called 'trigger transaction' in eltoo, must always have the same
inbound amount and the same outbound amount.  And then there's another
settlement transaction that's chained off of that, and that would be the one
that takes care of the remote side and local side outputs and the HTLCs.  But
clearly, for the ability to overwrite the channel state, the re-bindable part of
the transactions, the trigger transaction has to have some sort of timeout that
allows later trigger transactions, or I'm not sure what the proper term was,
whether it was trigger transaction, but the one that actually triggers the
closing, they have to be overwritable with the latest state.  And if the
settlement transaction had the HTLC that times out in between, you'd still lose
the money.  So, your idea is to use earmarks here in some cool way?  How would
that work?

**Anthony Towns**: Well, so let me just summarize how it is in eltoo, or
LN-Symmetry as it's been spec'd up until now, which is, as you said, so once
you've established a state onchain, you've got a little bit of time to update
that to a later state.  And after that timeout's passed, then you publish the
settlement transaction which, take that one UTXO and expand it to different
UTXOs for the balances and the open HTLCs, and that's when you claim it.  But
that has the problem that if you've got an HTLC that's about to expire, then
that kind of forces you to close the channel if you've gone out of contact with
people quite a bit earlier than you would otherwise, and there are other reasons
that gets a bit awkward.

So, in the context of earmarks, the idea there is that the UTXO that's spent the
funding transaction is onchain, is waiting for this timeout.  It still has the
entire channel balance as its value, but internally to the scriptPubKey, it's
earmarked different parts of that total value.  So, it's earmarked part of it
for my channel balance, it's earmarked part of it for your channel balance, and
it's earmarked the rest of it between the various HTLCs that are still pending.

**Mark Erhardt**: And the earmark is part of the output in the sense that at a
specific state of the channels, different HTLCs existed; or is it independent of
the channel?

**Anthony Towns**: While you're still operating offchain, the channel state is
the balances and the open HTLCs.  When you are generating the commitment
transaction for that, you're encoding those as earmarks, and that gets put into
a merkle tree and goes into the calculation of the scriptPubKey.  And so, that
scriptPubKey is the scriptPubKey of the UTXO that goes onchain when you close
the channel.

**Mark Erhardt**: So, the scriptPubKey would encode in the earmarks the HTLCs,
whereas it would still look as a total balance, but under the hood somehow a
transaction pre-definition of where outputs have to be spent afterwards is
carried.

**Anthony Towns**: Yes, emphasis on the 'somehow', but I'm still working out how
to actually code that.

**Mark Erhardt**: Okay, but then if it gets re-spent by a later transaction,
because the later transaction might encode a different set of HTLCs with
earmarks, if it were able to rebind anyway, even though there were earmarks in
the previous output, the earmarks might change, right?

**Anthony Towns**: So, the idea behind earmarks is you've got two ways to spend
a scriptPubKey with earmarks.  One way is via the keypath or by some other way,
which just totally disregards all the earmarks, and you want to do whatever both
parties have authorized.  And so, that would be the update state to a later
state because someone was cheating or restored from backup, or something.  The
other way of spending is via the earmarks.  And so, that can involve updating
the earmarks or releasing some funds according to the earmark specification,
introducing a new earmark.

**Mark Erhardt**: Right.  So, basically the internal key would stay the same,
but the tweaked key would be depending on the earmarks, but wouldn't that mean
that both parties in the channel have to be aware of all the previous earmarks,
in order to recognize their commitment transaction output and be able to
re-spend it?  Oh, I guess they would recognize it by it spending the funding
output.  Yeah, okay, sorry!  Okay.

**Anthony Towns**: No, you're quite right there.  That might be a breakage in
how I'm thinking of it at the moment.

**Mark Erhardt**: Oh, okay.  Well, it sounds interesting.  I think it might be
still a little raw!

**Anthony Towns**: Absolutely.  I mean, I think I've got an idea of how to code
that up in bll.  And even then, once it's coded up, you've still got to figure
out how to use it for actual interesting applications in a way that makes sense.
The problem I always have with eltoo is remembering exactly how much information
you've got to be able to -- to be able to spend these things, you need to
recreate the scriptPubKey or the scripts inside them.  And to do that, you need
to be able to recover some degree of information about stuff.  And you don't
want to keep too much information around because eltoo, the idea is that you
only have to keep the latest state around.

**Mark Erhardt**: Right, exactly.

**Anthony Towns**: But in that case, you need to have the person who closes the
channel, in effect, get forced to publish the information that you're not going
to have if you don't have the old state.

**Mark Erhardt**: Yeah, that's right.

**Anthony Towns**: And particularly with Lisp and some sort of powerful thing
like that, you can just force them to publish the state as part of the spending
conditions.  So, I think that's finessable at the very least.  But yeah, it
definitely needs thought.

**Mark Erhardt**: Yeah, I think I also hadn't really considered the conflict
between the potentially timing out HTLCs and the follow after publishing the
trigger transaction/initial -- maybe it's 'staging transaction', right?  Staging
and settlement?

**Anthony Towns**: I think it's 'layered transactions', or at least that's how
it was originally introduced on the Lightning-Dev list.  I'm not quite sure.

**Mark Erhardt**: Okay, as long as everybody knows what we mean!

**Anthony Towns**: Yeah.

**Mark Erhardt**: Okay, yeah, cool.  Thanks for walking us through that and for
the food for thought.

**Anthony Towns**: Yeah, sure.  I think it's cool.

**Mike Schmidt**: Yeah.  You guys are riffing and actually doing protocol design
here on the show, which is kind of fun.  Yeah, maybe just zooming out and
summarizing for folks.  There's been a lot of discussion recently about
enhancing the expressiveness of bitcoin transactions.  A lot of that has come in
the form of new opcode proposals.  In some cases, that's a single opcode that's
maybe general purpose, if you will; in some cases, that's an opcode that is very
specific to a specific use case; and in some cases, folks are bundling packages
of these proposed opcodes into proposals for soft forks as well.  AJ, you're
taking a different approach and saying, what if we just had a new language
besides Bitcoin Script to codify the behavior of transactions and not be tied
down by the restrictions around Bitcoin Script.  And you found this variant of
Lisp, I believe it's the Chia blockchain has had a version, programming language
version of Lisp on their blockchain for some time.  And so, it sounds like
you've used that as a base and now we actually have a bll, a language; we have
the symbll, which is sort of the miniscript, or the higher-level language that
compiles down to bll; and bllsh, which is a way to sort of real-time experiment
with what that would look like on a command line.  And you've noted some of the
benefits that you've seen.

We talked about the WOTS signatures being much smaller.  We've talked about
potential implications using this flexible coin earmarks in LN-Symmetry, or
eltoo, but also, I guess, those earmarks can also be used in vaults and
joinpools or coinpools or payment pools, or whatever we're calling them these
days.  And so, it's really more of an overhaul or alternative to Bitcoin
Scripts, maybe similar to Simplicity, if folks are familiar with that.  Is that
a nutshell summary?  Anything else you'd add or correct there, AJ?

**Anthony Towns**: That seems pretty accurate to me.  And yeah, it's a very
similar approach to Simplicity and Symfony.  So, it would be a separate taproot
scripting type, just as Simplicity is on the Liquid testnet.  The symbll
higher-level language is a similar approach to both what Chia Lisp does with
Chia Lisp versus its low-level CLVM, and what Simplicity does; Simplicity is the
low level and Symfony is the high level.  So, yeah, it's a somewhat different
set of trade-offs than that, which I'm hoping we'll be able to compare in more
detail as people write more Symfony code and bll starts getting a bit more easy
to experiment with hopefully.

**Mike Schmidt**: And so, even in what I would wave my hands and say would be v1
of bll, you get some of these benefits that we talked about out of the box.  But
I think you and Murch were also talking about, there's this mechanism to be able
to upgrade the bll language with additional opcodes in the future.  So, not only
do you get a lot of this stuff immediately, but you have this sort of
extensibility that would be built in as well.  Do I have that right?

**Anthony Towns**: Yeah, so I mean I haven't implemented quite all of the
opcodes that I've spec'd out for bll, so the soft fork one for one thing.  But
when writing the WOTS+ stuff, I needed to implement the shift opcode, I think,
like the Bitwise shift opcode, because I hadn't done that and didn't have
something else that was convenient to implement it with.  So, it's still in the
stage where adding opcodes is kind of just, add them once you figure out how you
need them and figure out a good way of making them work.

**Mike Schmidt**: Murch, anything else before we wrap up this news item?  Okay,
I'll look at that visual cues.  AJ, thank you for joining us.  Thank you for
your time, for your 50 minutes here that you've spent with us talking about
this.  Seems very cool.  I hope we'll cover more of these developments as they
come forth and people can start playing with this.  You're free to stay on for
the rest of the newsletter or if you have other things to do, like sleep, you're
free to drop as well.

**Anthony Towns**: I might as well stay on for now, I reckon.

**Mike Schmidt**: All right.

**Mark Erhardt**: Yeah, you might have some input on ColliderScript, huh?

**Mike Schmidt**: That's a good segue.

**Anthony Towns**: I'll be happy to listen.  I don't think I know anything about
it.

**Mark Erhardt**: All right.

_How does ColliderScript improve Bitcoin and what features does it enable?_

**Mike Schmidt**: We can jump right into that one since that's our first
question from the Stack Exchange.  So, yes, we have our monthly segment,
interesting questions from the Stack Exchange.  We found nine interesting ones
this month, and the first one is, "How does ColliderScript improve Bitcoin and
what features does it enable?"  We actually had Ethan Heilman on last week to
discuss his work contributing to the ColliderScript white paper, and that
proposal would use grinding, or similar to mining techniques, to achieve
covenant-like functionality but at a high cost.  I think we were talking in the
millions of dollars or more for a single transaction.  So, if you want to hear
straight from Ethan's mouth, refer back to Podcast #330 for our discussion
around ColliderScript.  This week was really a higher-level question about
potential uses of ColliderScript, which include, among the general covenant use
case that we discussed last week, the use case of vaults, the emulation of the
CSFS opcode, and validity rollups.  So, there's a lot going on there.  Murch,
you had a week or more to digest some of the ColliderScript stuff.  Do you have
any further thoughts on this idea?

**Mark Erhardt**: Not that many yet.  So, my understanding is basically just
that you can pretty much do anything.  All of the operation is out of band and
you prove that you did it right by having the right hash, or something, to
satisfy the out-of-band conditions.  And that way, you can very easily check it
in script because we can do hashes in script.  But to have precomputed that
correct script, you spend multiple blocks' worth of hashrate on finding a hash
collision, and that sort of makes it hard for other people to spend your money
in other ways.  And I'm still not entirely sure how practical that would be.  It
would be more like a once-a-year or maybe once-a-month thing, because it would
be so expensive with the millions of dollars' worth of hashing cost.

**Mike Schmidt**: And from our discussion with Ethan, it sounds like there are
optimizations that would bring that number down, although it doesn't seem
feasible that this would be something that an individual would use anytime soon.
It seems like the use case here would be these validity roll-ups, or some sort
of a roll-up where you could justify these high costs, because there's so much
economic activity happening on these roll-ups or these bridges or these chains,
or whatever.

**Mark Erhardt**: Yeah, sure.  If you hooked up a whole sidechain or a second
layer on it and funneled all the activity through this proof, or anchored it
with this proof, then maybe you'd be willing to spend, I don't know, $1 million
once a week or something.  But I think I'm still missing the vision or the
application.

**Anthony Towns**: I think it's more the academic, as in this is proof that this
is possible, rather than the practical.

**Mark Erhardt**: Right, exactly.

**Mike Schmidt**: Yeah, it's funny that you say that, AJ, because when you
started talking about the Bitcoin Lisp thing, that's kind of what I thought as
well.  I was like, "Oh, he's just playing with this thing".  I think Poelstra
and Russell O'Connor came out with their offline, I forget what it's called, but
way to calculate and sign transactions all offline.  But it does seem like
sometimes these things --

**Mark Erhardt**: You mean the paper volvelles.

**Mike Schmidt**: Yes, yes, exactly.  I forgot what the parent name of all that
is.  But yeah, here we have it.

**Anthony Towns**: That's just the pubkeys.  It's not doing signing, surely, or
sharing private keys, rather?

**Mike Schmidt**: I think there was at least one --

**Mark Erhardt**: I don't think you can sign transactions with it, I think, or
maybe I'm misremembering.  But yeah, it's about key sharding and manually
calculating pubkeys.

**Mike Schmidt**: I think there was a Stack Exchange question that we had at
some point, which was like, "Could you do it offline?"  And of course, Poelstra
comes up with some crazy --

**Mark Erhardt**: Sure, sure.  Just takes a week or so of calculating at your
desk!

**Mike Schmidt**: Okay, all right, next question.  Or, AJ, anything else on
ColliderScript?

**Anthony Towns**: No.

_Why do standardness rules limit transaction weight?_

**Mike Schmidt**: No, okay.  Next question from the Stack Exchange, "Why do
standardness rules limit transaction weight?"  And, Murch, you both asked and
answered this question, so I will let you ask and answer this question again.

**Mark Erhardt**: Okay, yeah, so this question came up at a conference recently.
I was attending a talk and the speaker suggested that really, we should be
dropping the standardness limit on transactions, because clearly there is a
demand for big transactions now with people putting huge pictures into the
blockchain and wanting to do roll-ups or STARK proofs, and all sorts of things
that might consume multiple blocks' worth of block space.  And if we don't allow
them via standardness, people would just evade that, use dark mempools and get
miners to include them directly, or so the argument went.  And so, someone from
the audience brought up the question whether everybody is aware of why
transaction weight is even limited in the first place by standardness rules.

So, to be clear, by consensus, transactions can take the whole block.  A single
transaction, even the coinbase transaction, could be just the size of the whole
block, and that's a valid block.  But on the unconfirmed transaction layer, what
we propagate on a network with Bitcoin Core at least, we limit transactions to
100 kilo-vbytes (kvB), which translates to 400,000 weight units.  So, you cannot
have more than one-tenth of the block space for a single transaction.  So, I
asked this question and I answered this question.  Eva also gave another answer
in order to sort of write up the thoughts there.  And so, while larger
transactions would permit the introduction of these novel mechanisms, or STARK
proofs and whatever, big pictures I guess, it would also make bigger
consolidation transactions and batch payments more effective, but only slightly
because you're mostly just making the overhead smaller per payment output that
you're creating, or getting slightly less transaction overhead and number of
outputs per inputs for a consolidation, but that is an asymptotic savings.  So,
really bigger transactions don't make it that much more effective; I don't think
that's a good argument.  So really, we're only talking about having bigger
transactions for these novel mechanisms.

The problems that bigger transactions introduce are that all these thoughts
around transaction relay, incentive compatibility, validation cost, the
potential time that it can take for a transaction to be validated, they're
significantly easier for smaller transactions because they're bounded.  You can
waste less network resources if you can only ever send a smaller package that
has to be validated at once.  And of course, the quadratic hashing problem is
limited to legacy transactions.  So you could, for example, only drop the limit
for non-legacy transactions, and that would resolve some of those issues.  But
there's another big issue around block template creation.  So, block template
creation is inherently a knapsack problem, and knapsack problems are NP-hard
problems that cannot be optimally solved in polynomial time, which means
basically that the more options you have, the more complex the computation is to
find the optimal solution.  Usually, these problems are solved by having a good
enough solution which can be calculated efficiently.  And we use often greedy
approaches for that, like just do it step by step and always take the locally
best option to get closer to the target, and then you'll probably get a pretty
decent but not optimal solution.

The problem with trying to find the best block is that you want to optimize for
the total fee revenue, but transactions are multidimensional in that they can
vary in size, they can vary in fee, and therefore they have a feerate, but the
size matters in that at the tail end of the block, once not all of the remaining
transaction options fit into the block, having picked other stuff earlier
excludes transactions to be picked later.  So, if you have very big
transactions, you get to the point where maybe including a few small
transactions excludes a lot of the big transactions and you can't get the
revenue from that.  And that might actually lead to a less revenue block than if
you had picked a bigger transaction, even though it didn't have the highest
possible feerate.  So, it moves the tail end problem of the block way earlier
into the block, and that can lead to people needing to run a linear solver or a
more complex mechanism to find the optimal block, rather than using a simple
greedy approach.

So, this can actually make building a block that has good fee revenue, and fee
revenue will be our main block reward component in the future, can make that a
multidimensional problem, and that means that you might need significant compute
to extremely quickly calculate a good new block template.  And that means that
smaller miners are at a disadvantage, because it's clearly way easier for a big
miner that has some percentage of the total hashrate to put a few computers here
that can quickly calculate new block templates; whereas a home miner, that has
maybe one rig or two rigs, will not run a high-end computer to quickly build
block templates at the same time.  So, in these ways, big transactions can
significantly increase the advantage of bigger mining operations, and that would
lead to another centralization pressure.  All right, I talked a lot.  AJ or
Mike, do you have some other thoughts on this?  I guess I knocked you out!

**Mike Schmidt**: Go ahead, AJ.

**Anthony Towns**: I really don't.  I thought that pretty much covered way more
than anyone needs to know about it.

**Mark Erhardt**: Okay.

**Mike Schmidt**: So, we don't need ColliderScript transactions then?  It's bad
for Bitcoin, is that what you're saying?

**Mark Erhardt**: I'm saying that one of the reasons why it's currently easy for
small miners to compete is that they can just very quickly find a pretty decent
block.  And if we had very, very big transactions, it could become much more
costly to find the optimal block, and that might make at least a few percentage
points difference, and that would be bad for small miners.  I guess that will
seem much simpler.  You can cut out the long explanation later!

**Mike Schmidt**: That's the good part.

**Mark Erhardt**: All right.

_Is the scriptSig spending an PayToAnchor output expected to always be empty?_

**Mike Schmidt**: Okay, next question, "Is the scriptSig spending a PayToAnchor
output expected to always be empty?"  The person asking this also asks whether a
transaction spending a P2A with a non-empty scriptSig would be non-standard.
Pieter Wuille answered that, yes, scriptSig should be empty because, "Segwit
outputs are subject to a number of rules, but one of them is that they can only
be spent using an empty scriptSig".  Thus, it would also be consensus invalid.
Pretty straightforward answer there.  I did link to last month's Stack Exchange
segment, where we went into the construction of P2A and how that was decided.
So, check that out if you're curious about this new P2A thing.

_What happens to the unused P2A outputs?_

Next question is also about P2As, "What happens to the unused P2A outputs?"  And
I did not prepare any notes for this, so, Murch, I don't know if you have a good
summary here, otherwise we can paraphrase instagibbs' answer.

**Mark Erhardt**: Right, so P2A comes in two flavors, one of them is unkeyed and
one is keyed.  The keyed ones can only be spent by the two channel participants,
because it needs a signature and they have the key for that.  They would be
hopefully cleaned up whenever an anchor gives you extra money by spending it
back to yourself at some low feerates.  Hopefully, once we get TRUC
(Topologically Restricted Until Confirmation) transactions, ephemeral dust and
unkeyed P2A outputs, then we would only have a single anchor and it is
mandatorily spent on every transaction, so they wouldn't linger in the first
place.  For the current situation, where we have anchors on transactions
generally that are not necessarily spent because the commitment transactions
might have enough fees by themselves, they would hopefully also have sufficient
value that they would be cleaned up eventually, when feerates are low, by anyone
because anyone can spend them.

**Anthony Towns**: So, I think P2A, I think there's a difference between the
anchors in the Lightning sense and P2A as the ephemeral output, the bc1p fees
stuff.

**Mark Erhardt**: Right, so yeah, there is a difference.  So, currently we
already use anchor outputs and currently commitment transactions that use anchor
outputs have two anchor outputs that are keyed to a single party and each party
has their own.  So generally, only one of them would ever be spent because the
commitment transaction gets put into the mempool and somebody, if they need to
bump it, they would attach their own child transaction to their own anchor.
Correct me if I'm wrong on that one.  But P2A now creates a new output type, and
generally that is a witness program output.  What am I looking for?  A native
segwit output.  And native segwit outputs have a witness program.  In this case,
the witness program basically translates to OP_TRUE.  But native segwit outputs
can only be spent with an empty input script.  And in this case, they also have
an empty witness because they are already true in the witness program
themselves.  So, you only have to state which input you spend per the outpoint
with the txid and the vout, and don't have to provide more authentication or
authorization to spend the UTXO.

So, this output type is new.  It's not being used anywhere yet in Lightning.
But because it's ANYONECANSPEND and very cheap, it would make commitment
transactions slightly cheaper, and you would be able to transition to having
only a single one.  Originally, ephemeral anchors was proposed as a single
composite and it got split out into P2As and ephemeral dust.  So, with the
ephemeral dust, you could have a P2A output that has an amount of zero in the
output, and that would allow you to force that both the parent transaction has a
fee of zero, the anchor output itself is worthless, and you are forced to spend
it in order to be allowed to include -- sorry, in the mempool, we would only
accept the parent transaction because it has a zero fee in the context of a TRUC
transaction, where the child brings the fees, and then, yeah, it would be
cleaned up immediately, and we would only have one.

Sorry, there's a bunch of different concepts here coming together.  AJ, did that
respond appropriately to your interjection?

**Anthony Towns**: Yeah, I think so.

**Mark Erhardt**: Okay, thank you.

**Mike Schmidt**: Seardsalmon clarified that it was codex 32 was what we were
looking for earlier.

**Mark Erhardt**: Right.

_Why doesn't Bitcoin's PoW algorithm use a chain of lower-difficulty hashes?_

**Mike Schmidt**: Next question from the Stack Exchange, "Why doesn't Bitcoin's
PoW algorithm use a chain of lower-difficulty hashes?"  Person asking this
question posted a few different graphs that, based on his research, would show
that if you had a bunch of lower-difficulty hashes instead of one
larger-difficulty hash that you would have tighter predictability in when blocks
would come in and wondered, "Well, why don't we just do that instead?"  And both
Pieter Wuille and Vojtěch answered that that would violate the progress-free
property of mining, which is desirable and good for decentralization.  But
maybe, Murch, what is progress-free mining and how would progress-free mining
being violated be bad for decentralization?  Sorry to put you on the spot?

**Mark Erhardt**: No, I'm all there for it.  So, what we want out of mining is
that miners with a percentage of the hashrate get roughly the same percentage of
the blocks.  And that is achieved by basically making this PoW scheme do a
lottery on all of the proposed blocks.  So, every time someone hashes, it's like
buying a lottery ticket and about 1 in, I think it's 5 times 10<sup>23</sup>
power, about 1 in, what is it, 500 quintillion tries wins a valid block.  And by
having each of these lottery tickets have the same chance of winning, we achieve
that everybody that is attempting to mine has a corresponding chance to win the
valid block with their attempts.  Like, how often they enter in the lottery,
that's how big their chances of producing the valid block.

If we introduced something like this where we had to make a sequence of 10
hashes in order to find a valid block, people would find the individual hashes
with the corresponding probability of succeeding at finding a valid block.  But
because you have to succeed 10 times in a row, it would extremely bias towards
the people that have the most hashrate to achieve 10 successes in a row before
anyone else.  So basically, we would turn our scheme, where everybody gets
blocks according to their hashrate, into a scheme where the miner with the most
hashrate wins almost all blocks.  And that would be a terrible step back from
our PoW system.

_Clarification on false value in Script_

**Mike Schmidt**: Great explanation.  Thanks, Murch.  "Clarification on false
value in Bitcoin Script".  This person was asking what exactly is false in
Bitcoin Script, and Pieter Wuille listed three different values that evaluate to
false, and anything outside of those three values is evaluated to true.  The
three values are 1) an empty array; 2) an array of just 0x00 bytes; and 3) an
array with 0x00 bytes with a 0x80 at the end.

**Mark Erhardt**: I have a note here.  We computer scientists make a distinction
here between a false value and a falsy value.  So, a truthy and a falsy value
are things that evaluate to true when cast to a Boolean or evaluate to false
when cast to Boolean.  So, in this context, I would say there's only one false
value, which is the empty array, which is the canonical encoding of the number
zero.  But the other values here are falsy, in the sense that they also evaluate
to false, but are not the Boolean false.  End of note!

_What is this strange microtransaction in my wallet?_

**Mike Schmidt**: Fair point, Murch.  Next question is, "What is this strange
microtransaction in my wallet?"  And I think the person is really just referring
to the amount that ended up in this person's wallet and not the size of the
transaction.  In bytes, it was small.  Then Vojtěch went on to explain the
mechanics of an address poisoning attack and ways to mitigate such attacks.  And
I think there was actually some news in the last month or two about a fairly
large amount of some coin, I think it was a non-bitcoin poisoning attack, where
the idea is you send a small amount of tokens to an address that looks very much
like the address that you're sending to, and in most cases that would mean like
a vanity address or grinding the beginning of the address and the end of the
address to look very similar to the original address.  And the hope is that when
someone goes to transact in the future, sending coins to themselves, for
example, or sending elsewhere, that they would actually copy that address that
looks very much like the address but isn't their address, and then send it
there.  Now, that's obviously much more common in the case that you would be
reusing an address and continuing to send to yourself, which is another reason
that you would not want to reuse addresses.  Go ahead, Murch.

**Mark Erhardt**: Yeah, so this is much more common in cryptocurrencies where
people tend to have only a single address in the first place.  So there, of
course, it's worth to sort of populate their wallet with other addresses that
look extremely similar, because they're so used to seeing their address, they
might not double-check.  So, I hope that most Bitcoiners are less susceptible to
this because they always use a fresh address anyway.  And I also want to break
another lance here for the, what is it, BIP353, the DNS names for Bitcoin.  So,
this is a newish BIP that was proposed in the last months, and it proposes being
able to have a static address in your DNS record for your domain that could be
used, for example, for a BOLT12 invoice and/or a silent payments address.  And
if you use this, you could have an address book where you resolve the DNS record
to payment information, and then you would hopefully not be susceptible to
looking at addresses and guessing which address you want to pay.

**Mike Schmidt**: Yeah, and with silent payments, silent payments can sort of
act as an account, if you will, but because it's not an actual address that you
would reuse, it's not susceptible to these sorts of attacks.  So, another thumbs
up for silent payments.

_Are there any UTXOs that can not be spent?_

Next question, "Are there any UTXOs that can not be spent?"  And Pieter Wuille
answered this.  I think a lot of our listeners are probably familiar with
OP_RETURN outputs as something that cannot be spent, and as a result is not
stored for future potential spending.  I was not familiar with a scriptPubKey
longer than 10,000 bytes and, Murch, are you familiar with why a scriptPubKey
that is longer than 10,000 bytes would not be spendable?

**Mark Erhardt**: Yeah, that's a consensus rule.  Scripts cannot be longer than
10,000 bytes.  And funnily enough, we allow it in the creation of a
scriptPubKey.  But then, when you spend from that UTXO and it is evaluated for
the input script on validity, it fails.  So, you can create outputs that have
output scripts with 10,000 bytes, but you can't spend them.  And apparently, we
do not store them in the UTXO set of Bitcoin Core.

**Mike Schmidt**: Now, I know there's like burn addresses, like
1-something-something-Eater, or BitcoinEater, or whatever it is.  Now that, even
though people acknowledge that as a burn address, the assumption then is that
those coins are burned and can't be used again, that is stored and that's part
of the caveat here, which is like the breaking of cryptographic assumption, so
if there were some break in the cryptography, that you could actually spend from
that burn address, right?  And that's why that's continued to be stored, right,
and you obviously don't want manual tagging of what's spendable either.

**Mark Erhardt**: So, to recap, what you're saying here is the 1BitcoinEater
address I think is a valid address that has, like, a probably unknown private
key.  So, someone obviously just picked the words, there's way too many words
for it to be actually a vanity address, and therefore it is considered
completely unlikely that they also know the private key, because they picked the
address and didn't pick it via the private key.  There is another burn address,
I think, that uses a value for which there provably cannot be a private key.  I
think, maybe it was the generator point or something, something that is
unspendable.  And a bunch of people have been using that, I think, for a
sidechain or, I don't remember, some proof-of-burn scheme.  And so, there's two
variants of those that are provably unspendable and ones that just seem
extremely likely to not have a known private key.  And the 1BitcoinEater address
is no known private key.

So, if anyone -- well, that is a P2PKH address, so not even the public key is
known, so even breaking Discrete Logarithm Assumption, DLA, I guess, that it's
hard to go from public key to private key, even if that were broken, so if we
got quantum computers, this wouldn't be susceptible because nobody has spent
from it ever.  So, the public key that corresponds to this address is also not
know, so they'd also have to break the hash here in order to get from the
address to a public key, and from the public key to a private key.  So,
hopefully that would not become spendable, but people would be able to spend
from P2PK and from any addresses that have known public keys, even if they're
hashed.  Sorry, go on!

_Why was BIP34 not implemented via the coinbase tx's locktime or nSequence?_

**Mike Schmidt**: Next question from the Stack Exchange, "Why was BIP34 (block
v2, height in coinbase) not implemented via the coinbase tx's locktime or
nSequence?"  This was a question from 2018, which had an answer the same day in
2018 by Pieter Wuille that said, "That would have made perfect sense, and I see
no reason why that wouldn't have been the superior way of doing it.  However, as
far as I remember, nobody suggested it at this time".  So, that was Pieter's
answer from 2018.  Antoine Poinsot answered this year, just a month ago,
pointing out that the nLockTime can't be used to set the height of the block
that it's included in, because the nlock value represents the last block at
which the transaction is invalid, not the first block at which it is valid.  And
so, you couldn't do a one-to-one there.  He goes on to say you could do
height-one, but there's some complexity there.

**Mark Erhardt**: Yeah, you could either use the height previously, or you could
require that the nSequence field is set to the max value, which means that it's
not locktimed.  But I think that the coinbase nSequence value, isn't that
already fixed and has to be 0000?

**Mike Schmidt**: I don't know.  Maybe AJ knows.

**Mark Erhardt**: Does AJ know?  Well, I'd have to search that right now and
that might be out of our time availability.

**Mike Schmidt**: We'll leave that as an exercise to the listener.

**Anthony Towns**: I think it's just that prevout is now not necessarily the
nSequence, is why.

**Mark Erhardt**: Oh, right.  The prevout is, I think, some combination of zeros
and Fs, right?  Yeah, okay, let's move on.

_Core Lightning 24.11rc2_

**Mike Schmidt**: Let's move on.  Releases and release candidates, Core
Lightning 24.11rc2.  I think since it's a major release, we can probably cover
it in more depth when it comes out, but it will have some of the features that
we've covered in the Notable code segments recently, including xpay, BOLT12 by
default, improvements to HSM functionality, and a bunch of, I think they said,
"Nasty bug fixes", in there.

_BDK 0.30.0_

BDK 0.30.0.  This threw me for a loop, I was waiting for the BDK 1.0.0 still.
Several minor bug fixes in this BDK release, and also prepares for the
forthcoming 1.0 release that we have discussed previously by, "Preparing
projects for migrating wallet data to the 1.0.0 version of BDK".

_LND 0.18.4-beta.rc1_

LND 0.18.4 beta RC1.  What I pulled out of here was just, "A minor release which
ships the features required for building custom channels, alongside the usual
bug fixes and stability improvements.

_Bitcoin Core #31122_

Notable code and documentation changes.  Bitcoin Core #31122 introduces the
change, CTxMemPoolChangeSet, which is a wrapper for creating new mempool entries
and removing conflicts.  Suhas noted two different use cases for such a
function.  The first is determining if ancestor/descendant/TRUC limits would be
violated, and then in the future there would also be cluster limits there as
well, if either a single transaction or package of transactions were to be
accepted; and the second use case would be determining if an RBF replacement
would make the mempool, "Better", both in a single transaction and package of
transaction replacements.  Murch, I think you could probably double click on
this a bit.

**Mark Erhardt**: Yeah, I dug a little into this one.  So, this is not a
user-facing change, this is totally under the hood.  This is basically a
refactor in the process between hearing about new transactions on-the-wire,
processing whether they're valid, and then adding them to the mempool.  And
specifically, this is after net processing is done and the transactions
individually are valid, before a transaction is added to the mempool.  This used
to work that first you do all the validity, and then you check for conflict in
the mempool.  And the conflict evaluation would run, and then before this merge,
if you accept that the new transaction will be added, you first, in a single
step, would remove all the conflicts, the direct and indirect conflicts, from
the mempool, then you would add the new transaction.

With this new change, you would do all of this at once.  You would evaluate the
set of transactions that are to be removed and the set of transactions that are
to be added, check whether you want to accept the change set in total, and then
effect all changes in a single step, remove everything and add the new stuff in
a single change.  The author tells me, "If you do see any differences in
behaviors, please report.  You shouldn't!"

**Mike Schmidt**: Thanks, Murch.

**Mark Erhardt**: Oh, maybe one more sentence.  So, why we're doing this in the
first place is we are looking forward to a future in which we will be processing
packages of transactions more often.  And especially in the context of cluster
mempool, it is more important to see the change of multiple transactions as a
group.  And so, this is just building towards having it for cluster mempool.
Yeah, sorry, go on.

_Core Lightning #7852_

**Mike Schmidt**: Core Lightning #7852.  This fixes a compatibility with the
pyln-client library that was unintentionally broken in recent Core Lightning
(CLN) versions, when the description field that pyln required was dropped.  Pyln
is a package that implements the JSON-RPC that CLN, the daemon lightningd
exposes.  It can be used to call a bunch of functions on the node via the RPC
interface.  It also serves as the basic basis for a lot of the plugins that are
written in Python.  So, this fix is probably well received by a bunch of people
who are using those plugins.  Do upgrade to the latest when it comes out, but if
you haven't broken your plugins in a recent CLN version, make sure that you wait
for this restored backward-compatibility to come out before upgrading.

_Core Lightning #7740_

Core Lightning #7740.  This is a PR titled, "Askrene: improving the MCF Solver".
And this PR adds a bunch of graph data structures and algorithms for operating
on those graph data structures to CLN.  And it refactors the min cost flow
solver in the askrene plugin to use those new constructs.  It also adds several
methods to improve the efficiency of these related flow calculations.  And it
also adds arbitrary precision flow unit, so you don't need to use the msat in
the calculations for the min cost flow moving forward, you can use any number
depending on the total that you want to pay.

**Mark Erhardt**: Yeah, I tried to stare at this one a little bit, but all I got
was that it basically moves some stuff at a lower level in CLN to make it more
accessible and performant.

**Mike Schmidt**: Well, good news is, related to this a bit is that we will be
doing a deep dive on channel depletion research, which is somewhat related to
this topic, with René himself.  So, look forward to that podcast coming out in
the next couple of weeks, we're going to record it soon.

_Core Lightning #7719_

Core Lightning #7719 is a PR titled, "Splice Interop", and this brings the
implementation of splicing in Eclair and the implementation of splicing in CLN
into interop status, which would allow splices to be executed between the two
implementations.  We actually spoke with Dusty, the PR's author, last week about
splicing on Podcast #330, so check that out if you want to hear more about the
status of splicing.  I think he also mentioned that this interop was coming, so,
awesome.  In this PR description, he notes all of the changes required to bring
CLN and Éclair's implementations into alignment to ensure that splicing between
those implementations work.  So, if you're curious about what the delta was
there, check out the PR description for more details.

**Mark Erhardt**: It's only 22 commits and 36 files changed.

_Eclair #2935_

**Mike Schmidt**: Yeah, just jump right in.  It's a good first issue, yeah.
Eclair #2935 adds a notification in Eclair when a force close occurs.  I don't
know the details of Eclair's notification architecture, but I assume that you
can configure notifications to arrive via a bunch of different mediums.  And so,
this is just now another notification that can happen.  Otherwise, it was just
in your log somewhere.

**Mark Erhardt**: It also literally, I think, just publishes it to the event
stream.  So, I assume it's like, yeah, it pops up or adds it to your mobile
phone notifications when it happens.

**Mike Schmidt**: Yeah, that PR is quite different.  I think it's like a
one-line code change compared to the 36 files, yeah!

**Mark Erhardt**: It is a single line, yeah.

_LDK #3137_

**Mike Schmidt**: LDK #3137 titled, "Implement accepting dual-funded channels
without contributing".  So, this PR enables LDK nodes to accept peer-initiated
dual-funded channels.  However, neither funding nor creating dual-funded
channels is supported yet in this PR in LDK.  Likewise, zero-conf dual-funded
channels and RBF fee bumping of these funding transactions are not supported yet
either.  Those are specific callouts.  But good to see, and it's part of LDK's
ongoing work to establish v2 channels.  And so, there's actually a tracking
issue for that particular category of things, establishing v2 channels, and that
tracking issue is #2302.  And actually, that tracking issue itself is part of
the broader tracking issue for LDK to support, in a big sense, the dual funding,
which is tracking issue #1621.  Good to see progress on these big chunks.

**Mark Erhardt**: It's kind of funny.  Originally, the white paper described
channels as getting dual-funded, and now after, what is it, six years of
channels being on mainnet, we're getting closer to one of the implementations
having support for it.  Or, maybe there's another one.  Maybe LND has support
for it already, or someone.  I don't remember.

**Mike Schmidt**: Is it not éclair, no?

**Mark Erhardt**: They do have splicing now, which probably could be used to
achieve an effect like that, but not sure.  I'm not sure, I might be wrong on
this one.

_LND #8337_

**Mike Schmidt**: Let's see, last PR this week, LND #8337.  This is the first of
four PRs that are around LND's protofsm initiative.  And the 'fsm' in protofsm
stands for, "Finite state machine", which is a mathematical model of
computation, where the state of a given process can change or transition to
other states based on some inputs.  The PR gives an example of a state machine
for Lightning in LND that represents the cooperative close process in LND's
implementation.  "The goal of this PR is that devs can now implement a state
machine based off of this primary interface", which I assume would help better
formalize some of the common workflows that happen in Lightning for LND
developers.

**Mark Erhardt**: I haven't looked into this one too much, but my guess would be
that having a clearly defined state that a channel is in makes it easier to
enumerate all the possible transitions to other states.  And this might be not
clearly delineated for some of the states, like while you're negotiating an
HTLC, a new HTLC is arriving, or something.  If you properly formally describe
the state, as in, "We only have to finish negotiating this HTLC first, and only
then another state transition can happen", it might be clearer how a node should
respond to such a request while it arrives.  It makes it cleaner in the sense
that you very explicitly track of where you are with everything and how you can
get to next states.  That would be my guess, I haven't dug into it.  Is that it?
You're muted!

**Mike Schmidt**: That's it.  I was going to say, AJ, thank you for joining as
our special guest this week and joining our experiment here on Riverside.
Murch, thanks as always for co-hosting, and for you all for listening.  Cheers.

**Mark Erhardt**: Yes, thanks, Mike.  See you.

**Anthony Towns**: Thanks guys.

{% include references.md %}
