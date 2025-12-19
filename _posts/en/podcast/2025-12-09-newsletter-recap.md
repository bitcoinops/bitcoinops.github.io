---
title: 'Bitcoin Optech Newsletter #383 Recap Podcast'
permalink: /en/podcast/2025/12/09/
reference: /en/newsletters/2025/12/05/
name: 2025-12-09-recap
slug: 2025-12-09-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Moonsettler and Julian to discuss [Newsletter #383]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-11-9/414070627-44100-2-1b414ed922d2.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #383 Recap.
This week, we're going to be covering a consensus bug in the NBitcoin library
found via differential fuzzing; we're going to talk about the LNHANCE soft fork
proposal and how it combines three different covenant style opcodes into a
single proposal; we have a call to benchmark Bitcoin Script under the proposed
varops budget; and then, we're going to talk about some optimizations to
SPHINCS+, which is SLH-DSA, for post-quantum signatures.  This week, we're
joined by Julian.  Julian, do you want to introduce yourself?

**Julian**: Sure.  I'm Julian, and I've been working on restoring Bitcoin Script
for like half a year now, and also, of course, the varops budget.

_Consensus bug in NBitcoin library_

**Mike Schmidt**: Excellent.  Well, thank you for joining us.  We'll jump into
the News section, but we'll get to your Changing consensus item shortly.  First
and only news item this week titled, "Consensus bug in NBitcoin library".  This
was motivated by a Delving Bitcoin post from Bruno about a consensus failure in
NBitcoin involving the OP_NIP opcode.  Murch can correct me if I'm pronouncing
that incorrectly.  And he found that using differential fuzzing.  Maybe for some
context, NBitcoin is a .NET library.  I believe it's written in C# and it's for
working with Bitcoin if you're doing .NET stuff, sort of an API to do Bitcoin-y
stuff in .NET.  He gets into the post about why traditional fuzzing would not
have found this, namely because there wasn't a crash.  I think the deviation in
behavior was in sort of a try/catch structure, so the traditional fuzzing might
not have found that.  Murch, are you familiar with the OP_NIP opcode?  We sort
of get into it a bit in the write-up here.

**Mark Erhardt**: I cannot explain it from the top of my head, but I can look it
up if you want to continue meanwhile.

**Mike Schmidt**: No, I'm not even sure, well, I guess it is germane to the
discussion.  It's removing something in place, it looks like.  And during this
shift in NBitcoin, it caused the code to try to access the previously removed
end of the array, which caused an out-of-bounds exception, which was then
silently caught, causing I think it was in Bitcoin just to be a valid script,
and Bitcoin Core it wasn't, or vice versa.  So, essentially there was a
consensus discrepancy based on that script evaluation.

**Mark Erhardt**: The way I understood it, it tried to remove an element from
the array that wasn't there anymore, like the sequence of steps was implemented
incorrectly.  OP_NIP removes the second element from the top of the stack.  So,
it leaves the top element untouched and then removes the element underneath.
And for some reason in this, if the stack was full, so 16 elements or something,
from the description of this bug, it would try to access an element that was no
longer present in that frozen exception and crashes NBitcoin.  The biggest
consumer of NBitcoin, by the way, is what?

**Mike Schmidt**: BTCPay Server?

**Mark Erhardt**: Yes, very important project.  So, because there is no full
node implementation of Bitcoin and using NBitcoin, this is not a
consensus-critical issue in that sense.  I assumed that it would not be used to
interpret anything for BTCPay server either, or maybe it would, but OP_NIP
doesn't get used all that much, I think.  Maybe only in bare scripts, I guess,
right?  Or I guess you could do it in scripthash or a P2WSH.  But anyway, it's a
less commonly known opcode.

**Mike Schmidt**: Yes.  And because there was no full node, you mentioned that
they could roll it out pretty quickly.  If you look at the timeline and the
Delving post, everything happened on the same day.  Bruno reported it, Nicolas
confirmed it, Nicolas opened up the PR, and the 9.0.3 version was released all
in the same day.

_Benchmarking the varops budget_

Moving to our monthly segment on changing consensus, we'll jump a little bit out
of order because we have Julian here to talk about our second item from the
Changing consensus segment, "Benchmarking the varops budget.  Julian, you posted
to Bitcoin-Dev mailing list, and I think Delving Bitcoin, about benchmarking
Bitcoin Script execution under the proposed varops budget, which is originally
motivated from the Script Restoration effort.  Listeners may be familiar from
this discussion from Newsletter and Podcast #374 on the Script Restoration BIPs.
Julian, maybe you can remind us a bit about what is varops and how it's
different from sigops?

**Julian**: Yeah, exactly.  I wanted to start a little bit with the idea of
having a computational budget in general.  So, I think about it similarly to the
block size limit, which I think everyone's very familiar with.  So, block size
limit has probably many reasons to exist.  But for me, the main reason is to
keep the network decentralized.  You want the nodes to be as simple to run as
possible.  And just to address these hardware limitations that computers have
for the block size, it's probably the internet speed and also, if you want to
run full archival node, the storage and probably also memory.  Essentially, you
want the chain to be as small as possible to run a node, and therefore we don't
want the chain to grow infinitely fast.  So, we have a block size limit and we
have a very controlled amount of data.

**Mark Erhardt**: I think one very important reason to have a block size limit
is the speed at which you can process a single block.  Because if you allow very
big blocks, it could be very slow for other miners to process that block.  And
then, the miner of the first block would have an advantage to start for the
succeeding block.

**Julian**: Yes, right.  So, it's also important that the data is passed around
through the network as fast as possible and that works much better if the blocks
are small.  Okay.  But then if you run a node, you're not just downloading the
block and storing it away, but you are also validating the transactions inside.
And for that, you're running the script interpreter.  And for most transactions,
it really just verifies the signature.  And so, it runs these sigops, that's how
we call them in short.  And since verification of signatures is relatively slow
to compute, as you say, we already have kind of a budget for computationally
expensive operations, but it's just super specific for sigops.  So, the sigops
budgets, I simplify a little bit, but it basically says you cannot have more
than 80,000 sigops in one Bitcoin block.  So, as with the block size limit, if
you produce a block which has more inside, it will just be invalid.

So, now you might ask the question, do we have any other operations which are
also slow to validate or slow to process on a CPU?  Because this doesn't address
the speed of the network, but now the computing power of the node.  And right
now, if you were to try to attack Bitcoin by making an absolutely slow
transaction, a maximally slow transaction, you would probably actually go for
repeatedly hashing the maximum stack size element, because you can actually
produce scripts that are slower than just putting in the maximum amount of
sigops.  And so, I think it's quite reasonable to ask, why do we only have a
sigops limit and not, for example, also another limit for hash operations,
because they can be also slow, not as slow as the sig validation, but it is
really the same concept?

**Mike Schmidt**: Okay, so we have an idea of varops.  Do you want to tie it
into GSR?  Like, could we do varops without GSR?  Or I know I came out of that
effort, but maybe talk about the relation.

**Julian**: Yeah, exactly.  So, of course, this is not a real motivation to add
now a new constraint to Bitcoin.  The idea is that if we were to potentially add
new operations like we would like to do in GSR, then it would be great to have a
framework which just captures how much compute should be allowed in a
transaction.  And specifically, for GSR, it contains 15 opcodes that have been
disabled and some of them are also computationally expensive, and this is mostly
the multiplication and division.  You might think that multiplication is quite
fast on a modern chip, but it really depends how large the operands are.  So, if
you have two very, very large numbers and you want to multiply them, there
should be some kind of limit.  So, it would probably not be a good idea to just
reactivate all the opcodes without having some constraint like that in place.

**Mark Erhardt**: Yeah, maybe one comment here.  So, when we introduced segwit,
one of the reasons, or the main reason why we introduced the weight limit
instead of having two separate limits for witness data and the non-witness data,
is that you want a single dimension in which you define the limit.  Because if
you have multiple dimensions in which you design the limit, you introduce a bin
packing problem to block building.  So, basically, it seems to me that varops is
an attempt to replace the sigops limit in a way that is also easy to align with
the weight limit, because we still only want a single dimension for people to
build blocks, to estimate fees, and so forth.

**Julian**: Yes, exactly.  Russell O'Connor, I think, posted this onto the
mailing list.  And the varops budget really tries to generalize the sigops
budget.  And it would completely replace that in this new tapleaf version.  So,
you wouldn't think about sigops anymore, it would just be a general
computational budget, which would apply to all operations, which takes some
amount of time to execute.

**Mike Schmidt**: Maybe get into a little bit about your benchmarking and then
also, I know it seems like there's also a call to action here for people on
different operating systems and hardware.

**Julian**: Yeah, maybe to understand why we want to have a benchmark, why it's
important.  The varops budget in its current state, maybe I'll explain a little
bit how it actually works.  I think that would help.  So, it's similar to the
limit in tapscript, where it is on an input scope.  So, for each input,
depending on its size, you get more sigops.  You have at least one and then if
your input is very large, you can potentially have multiple sigops in there.
And very similarly in varops, we take the weight of the transaction, then we
multiply it by a budget factor, which is like a free parameter of that model,
more or less.  And then, this gives you the computational budget for the whole
transaction.  And then, we iterate through all inputs.  And as each opcode is
executed, we just subtract the cost.  If the budget ever goes below zero, that
would make the transaction fail.  It would throw in like a new script error that
we introduced, and the transaction would be invalid.

Maybe to clear up also, the budget in its current form is very high, so you
would not be really thinking about it if you just broadcast a normal
transaction.  This is really to catch these worst cases if you were to try to
multiply, for example, some arbitrary large numbers.  And it wouldn't really
impact the average user or someone who just uses normal transaction signing.
So, yeah maybe the question is how do we define the cost for each opcode, and
also what kind of factor do we use.  So, making the budget proportional to the
weight is pretty straightforward, I believe.  But then, you have this factor
which has to have certain dimensions.  Currently it's set to 5,200, and then of
course you need to define the cost for each operation.  So, for example, I can
use hashing.  Maybe if we use a hashing function currently, it takes 10 varops
budget per byte hashed.  So, since the operands are always of unknown size, so
the operators always act on operands of various sizes, and this is why the
budget is variable.  So, this is kind of where the name comes from.  It acts on
various variable-sized operands.  And so, we always calculate the cost per byte.
So, if you hash 1 byte, it will cost 10; if you hash 20 bytes, it would cost
200; and so on.  So, it kind of assumes a linear scaling in how long hashing
takes, which is not 100% correct, but it is on the right order of magnitude.

All these variables, these three parameters in the model, they have to be
verified through some empirical data, which is the benchmark.

**Mark Erhardt**: So, basically, depending on the size of the transaction, you
get a bigger budget of varops.  And then, depending on what you do in the
script, you pay down from that budget, depending on the opcodes you use, how
much data go into the opcodes and are processed.  And you are now trying to
benchmark this in order to make sure that the costs for the opcodes roughly
align with the actual computational cost.  And you're hopefully also verifying
that whatever you do, and want to do that is reasonable, doesn't exceed the
budget; and vice versa, maybe unreasonable things are prevented by the budget.
Is that roughly a good understanding?

**Julian**: Yes, we can talk a little bit about the methodology of the
benchmark.  Really, the goal is, let's say we have the script completely
restored in the form of how Rusty Russell proposed it right now, and we also at
the same time have the varops budget enabled.  Then, it is a nice thought to
have, in this state, the worst possible script.  So, what I mean is the script
with the highest validation time, of course, it is not higher than whatever you
can do right now.  So, for example, you can put now 80,000 sigops into a block.
And after restoring script, it would be great if you cannot produce any script
which is slower than those 8,000, just assuming that 8,000 is the worst right
now.  But in fact, with hashing, you can also produce even slower validation
times.

**Mark Erhardt**: I think 80,000 sigops is the block limit, right, not the
transaction?

**Julian**: Yes, exactly.  We are looking at it on block scale.  So, I think
this makes it a little bit easier to understand the dimensions.  So, 80,000
sigops, for example, is around two seconds maybe on a modern machine.  And if
you just assume you have the whole block filled with, for example,
multiplications of very large numbers, then it would be great if the slowest
execution time we can measure would be still below those two seconds, or
whatever your machine benchmarks for 80,000 sigops.

**Mark Erhardt**: Yeah, that seems reasonable.

**Julian**: And there in the post, if you read the Delving post, there was quite
a bit of discussion around the methodology itself.  Maybe to clarify, the idea
is if someone wants to try to create a maximally slow transaction or a block,
whatever, if you can already use legacy script or existing tapscript leaf
version, we don't really need to constrain the script much further, because
there is already a worst case right now.  And our BIPs, they would not change
tapscript itself, they wouldn't constrain it more.  They would actually add a
new leaf version, where you can use the varops budget and the new enabled
opcodes and some other changes, like the stack size limits, which are quite a
bit higher.  And yeah, the issue with the benchmark is that depending on the
machine, you get very different results, which is maybe a little bit surprising.
But especially for the hashing functions, they highly depend on if they are
hardware-accelerated, or really how they are implemented on each architecture.
So, it would be really great to have a lot of data, just a lot of data from new
machines, from old machines, from Intel, AMD, from ARM chips, from all the
operating systems you can think of, from different compilers, just to collect a
big amount of data.  And based on that, we would of course then verify or adjust
our three parameters.

**Mark Erhardt**: Cool.  So, basically, people can just get your benchmark from
your repository and run that?  Is it packaged like that?

**Julian**: Yes, I want to provide also binaries directly, but it's all in the
post.  You can check out my branch, then compile with benchmarks on and then run
this new binary.

**Mike Schmidt**: Julian, I had a follow-up.  I think you may have touched on
it, but I just want to make sure for my own understanding.  You don't actually
execute to determine the budget.  You inspect the script and then that's how you
build this budget.  You see the size and then you add in the various opcodes and
their associated budget to see if it's exceeded.  Is that right?  You don't
execute and then see, you inspect the transaction's opcodes in order to
determine if that transaction exceeds its varop budget, right?

**Julian**: No, we don't do that.  We execute the script interpreter and if the
budget goes below zero, the transaction is invalid.  And for some cases, you
have to make sure that you first check how expensive is the next operation
before executing it, because yeah, the same problem.  If you multiply these two
huge numbers, then you want to check before.  So, we do that for expensive
operations like that.

**Mike Schmidt**: Okay.  That makes sense.

**Moonsettler**: Yeah, it's dependent on the stack state, right?  So, you can
only really check the next operation, how expensive it would be.  You can't just
foresee indefinitely into the future because then, you basically have to execute
the script anyhow.

**Mike Schmidt**: Right, makes sense.

**Julian**: I believe Rusty has built a tool that wants to do exactly that.  But
you should ask him about that, because I believe just executing is very simple
and you always have the correct response.

**Mike Schmidt**: Julian, I suppose the call to action for listeners here is to
participate in the Delving discussion, but also run your benchmarking tool on
their hardware, contribute the results back, so that you all can calibrate
accordingly.  Anything else?

**Julian**: Yes, I also always appreciate feedback on the BIPs for the varops
budget, for the great script restoration.  And I am also looking for a code
reviewer for the implementation.

**Mike Schmidt**: Well, thank you for your time.  Thanks for joining us and
walking us through the different pieces here.  We appreciate it.  Thanks,
Julian.

**Julian**: Yeah, thank you.

**Mike Schmidt**: Moon, I'm sorry I didn't see you earlier.  If we skipped your
item and you were here, that's my fault.  Do you want to introduce yourself
really quick, and then I'll introduce the item and you can run with it?

**Moonsettler**: Hi everyone, I'm going with the nick, Moonsettler, and I'm
mainly trying to move the LNHANCE proposal forward nowadays on Bitcoin.  I'm
also very much interested in the whole script restoration, varops thing.  I
think it's a good direction for Bitcoin.  I'm not sure if we are ready to take
that leap.  I'm a bit pessimistic on people's reactions, but I very, very much
like it.

_LNHANCE soft fork_

**Mike Schmidt**: Well, you're taking your time and energy and putting it
towards trying to improve Bitcoin, which is what brings us to the LNHANCE soft
fork item from the Changing consensus this past week.  You proposed on the
Bitcoin-Dev mailing list, soft fork for LNHANCE.  I think some of us have been
hearing about LNHANCE, but you posted to the list to aggregate these four
constituent opcodes that have BIPs and reference implementations.  Further down
the line, you have OP_CHECKTEMPLATEVERIFY (CTV), we have OP_CHECKSIGFROMSTACK
(CSFS), OP_INTERNALKEY and OP_PAIRCOMMIT as the four different opcodes that roll
into this bundle called LNHANCE.  Moon, I'll let you take it wherever you want,
but maybe you can help listeners understand what, as an end user, they might
get, what could we achieve with these opcodes?

**Moonsettler**: Okay, so like I mentioned, I'm a really big fan of script
restoration, so this is not the end goal that I have in mind for Bitcoin.  Not
saying that we activate LNHANCE and then ossify.  LNHANCE is meant to be like a
super-ultra-conservative fork that does not really change Bitcoin fundamentally
all that much.  It sort of makes LN and LN-adjacent layer tools better, more
scalable, easier to work with, more flexible, basically better tools for
developers to make Ark-like covenant pool and LN-related channel factory
construct.  So, that is the scope of this proposal.  It tries to do just that in
the interim period while we figure out what to do with script, because we can go
in a lot of directions with script.  We can go the Simplicity direction, we can
restore script.  They all have various trade-offs.  Where we will draw the line
exactly, I don't know.  As things move in Bitcoin, this can take many, many
years to figure out, worst case.  Or absolutely worst case, nothing happens and
we stay as we are.

I personally believe that these four opcodes are so limited in impact in second-
and third-order effects, and stuff like that, that we should be able to have
consensus on them right now.  We should have the capacity to have consensus on
them.  And that is why I'm pushing this particular proposal, because I believe
it's realistic to activate this as they are.

**Mike Schmidt**: You mentioned improvements to Ark, maybe you mentioned it, but
is there LN-Symmetry improvements or working towards that as well, right?  Do we
get LN-Symmetry/eltoo?

**Moonsettler**: Yes, we absolutely get Lightning-Symmetry.  The reason why I
think Lightning-Symmetry is a better name for it than LN-Symmetry is there is
nothing network about it.  This improves a channel construction between two
peers.  It does not affect how the network is structured, although it makes
PTLCs (Point Time Locked Contracts) more possible or possible.  So, that can
have a a bigger effect on how the network is formed, but the symmetric channel
itself is just between two peers.  That is their private matter, it does not
really affect the network.  It can relay the same HTLCs, (Hash Time Locked
Contracts).  Nobody needs to know that this is a symmetric channel, that's my
point.  However, symmetric channels are extremely composable because they don't
rely on txid non-malleability.  I'm not sure how to phrase this properly, but
basically, you don't have to predict the transaction ID of any UTXO or virtual
UTXO that will eventually hit the chain for this construct to work.

So, the way they work is you have much more flexibility, you can even stack them
on top of any covenant construct or even into each other.  So, basically, you
can have statechain-like constructs that can spawn LN channels, and stuff like
that.  And you have this flexibility that you don't need to predict the txids
for it.  It works.  That's the whole point of the symmetry channel.  So, I think
it's going to be like a basic construction building block that is going to be
way more significant than just a Lightning Symmetry child between two people.

**Mark Erhardt**: Okay, one short question.  You said that, did you mean LNHANCE
enables PTLCs or LN-Symmetry enables PTLCs?

**Moonsettler**: Yeah, LNHANCE should enable PTLCs as far as I know.

**Mark Erhardt**: It's not clear the relationship to me; the relationship is not
clear to me.  Shouldn't PTLCs be enabled by a taproot channel?

**Moonsettler**: I'm not sure either.  For some reason, I heard that it's very
complicated to do that, but if you have CSFS, it's much easier.  That's what I
heard.  I did not dig into PTLCs personally, so maybe the information is
inaccurate.

**Mark Erhardt**: Oh, okay.  So, CSFS interacts positively.  I see, okay, yeah.

**Moonsettler**: That's what I heard, yeah.  But my main focus is really this
basic construction building block that I want to add.  And also, with CTV and
CSFS, we can do a lot of interesting things.  Like, we could do non-interactive
channels that you can just keep your key code basically and rebalance your hot
balance as you spend from it.  You can just increase it and you can just do this
operation, let's say with a hardware wallet signing, and stuff like that.
Technically, you can do these things without these constructions, but you always
run into stuff like the backup mechanics, and the size and complexity of backups
that you have are always worse without covenants.  So, the main reason why we
want to do covenants and not just presigned transactions is that we want to have
good static backups, as static as possible, and we want to have like an 01
backup state for Lightning.  So, we want to have basically better UX on that
front and something more safe for people and more efficient for the Bitcoin
Network.

A lot of times, where you want to have some form of covenant between two people,
I think it's a good way to frame covenants as a promise that you cannot break.
So, if there is a 2-of-2 multisig between two parties, then they can of course
collaborate to change the outcome, but neither of them can just unilaterally
change the deal.  So, that is sort of a covenant.  CTV is much simpler.  There
is no signature.  You just basically calculate the hash of the of the outputs
that you want to have and you can commit to it.  And that makes it
non-interactive.  You don't need two people to cooperate, you don't need all
that co-signing interactivity.  You can basically just unilaterally commit to
something that another party can look at and say, "Okay, I see that if this and
this condition is fulfilled, then I get paid".  So, we believe these are simple
and powerful enough primitives to warrant a soft fork, because you always have
to check if the gains are enough to warrant to go through the process.  We think
it improves a lot of things.  It's enough and they are very safe and limited.
That's the idea of it.

**Mike Schmidt**: Moon, how do you think about OP_TEMPLATEHASH, or the
collection under OP_TEMPLATE, where you also have CSFS, you have OP_INTERNALKEY,
you have a variant of CTV that's taproot-native, called OP_TEMPLATEHASH, and
then you don't have the PAIRCOMMIT.  Maybe just contrast for listeners what
tangibly, out of the things that you said so far, wouldn't happen with that
variant, and then we can get your take on it.

**Moonsettler**: Okay, so this proposal is also perfectly capable of doing
Lightning-Symmetry and a lot of the stuff that we talked about.  I have seen
construct proposals that need a PAIRCOMMIT, but most of the stuff that we talked
about does not specifically need PAIRCOMMIT.  PAIRCOMMIT is just a very simple,
cost-effective, safe way to commit to two stack elements that we currently do
not have in Bitcoin Script.  We can of course hash a single stack element, but
we do not have something that can commit immutably to two stack elements,
immutably in the sense of finding a hash collision.  So, that's not impossibly
impossible, but practically we consider it not really feasible.  And PAIRCOMMIT
has a very specific reason in regards to Lightning-Symmetry.  We want to have a
situation, like I said, we want the 01 backup, that the channel peers always
only have to hold on to their latest state as backup, they don't have to hold on
to all the hundreds or thousands of states signed.  This is a much safer, less
risky operation.

The other part of the less risky is you do not have a penalty.  So, if you screw
up anything, if you accidentally push an old state, because you restored from
backup, you restored the virtual machine, whatever, you push an old state to
change, there is a disagreement, communication breaks down, you don't get
punished.  The other party will just spend to the latest state automatically.
That's your expected outcome.  And also, if there is at any point in the
Lightning state machine, if you have a situation where cooperation breaks down
or an HTLC approaches a timeout, or whatever, you can just push whatever latest
state you have to the chain, you will not lose all your money.  That is why I
say really, there is the Lightning operator, and this is the other part of it,
of course.  It makes the whole thing actually simpler for developers.  I know
that we already have a Lightning Network, where the developers have struggled
through all this complexity and danger, and it's a bit weird to say, "Okay, but
we could have done this a lot better".  But I think we will get enough benefit
out of this for this to be a reasonable move.

So, PAIRCOMMIT is related to this.  So, to have the 01 backup, if someone pushes
an intermediate state to the chain, because they don't have the latest backup or
they are trying to cheat, we don't know, right, they push an old state to chain,
and all we need is the latest state to spend to it and we need to be able to
reconstruct that script.  And to reconstruct that script, we would need to know
what was the settlement, the shape of the settlement transaction for that state.
But we don't have the backup, we only have the latest backup.  So, what we want
to do is we want to force the party that pushes an intermediate state on chain
to also provide this information.  He needs to provide everything in the witness
that we can use to reconstruct the script of the transaction and then we can
spend to the latest state.  I'm not sure if I explained it clearly enough, but
that's the whole point of PAIRCOMMIT.  Yes?

**Mike Schmidt**: Oh, I thought you were going to wrap up.  I was just going to
plug that Moon, you and Rearden were on Podcast #330 when we talked about the
update to the LNHANCE proposal, just about a year ago, talking about this
specific opcode addition to the LNHANCE bundle.  So, if people are curious, they
can also jump back to that to get up to speed as well.

**Moonsettler**: Great.  Okay, so then I will mostly just mention that we don't
absolutely need to have this.  So, if you don't have PAIRCOMMIT, if you only
have CTV, CSFS and INTERNALKEY, then what you would do is you would put this
data into an OP_RETURN, right?  So, the intermediate state would look like a
spend that has an OP_RETURN, the data is available.  OPRETURN data is, of
course, four times more expensive than witness data, so that's an inefficiency.
Everyone has less space in the block if we do this.  We are trying to be
efficient, so that is a motivation.  So, we want to have this recovery data in
the witness.  And the other approach to this is the TEMPLATEHASH approach, which
makes it possible, because of the way they compute this sighash-type hash using
the taproot schematics.  It commits to the annex.  And you can put this data, if
you relay non-empty annex into the annex, and that gets the witness discount.
Of course, you can also use OP_RETURN with TEMPLATEHASH, because it commits to
all the outputs.

So, it's basically like CTV, but CTV does not commit to the annex; TEMPLATEHASH
commits to the annex.  If I had to explain, the greatest difference between the
proposals is this.  And I think there is a possibility that if we start relaying
non-empty annex, then we will see another exogenous asset hype cycle regarding,
because that's kind of like the ideal place for any exogenous asset payloads.
Like I said, it gets the witness discount, it's contiguous data, so on, so on.
I don't want to harp too much on it.  I already told everyone what I think about
this.  I think there is a risk, but it's not a technical and not a first-order
risk.

**Mark Erhardt**: So, your argument would be that PAIRCOMMIT makes it more
efficient to help people recover from a channel closure where they lost all of
their backup data?  Would then the TEMPLATEHASH, I don't remember what they
called it, but TEMPLATEHASH plus CSFS and INTERNALKEY, would you say that it
gets significantly enhanced if PAIRCOMMIT got added to it?

**Moonsettler**: No, it does not get enhanced significantly.  But I would say
actually, TEMPLATEHASH, because of the way CTV works, you have to sort of have
that TEMPLATEHASH that you have to check and verify against on the stack.  You
have to include this somehow, either as part of the data signed or as a witness
parameter, right?  So, you have to have the TEMPLATEHASH data on the stack.
That means you have to add this to your witness cost.  Now, with TEMPLATEHASH,
you can do that, you calculate this TEMPLATEHASH and have it on the stack with a
single opcode operation, single byte cost, and then you can check a signature
against it.  That means you can actually, instead of using 33, 34 bytes, you can
use like 1 byte.  So, technically, TEMPLATEHASH makes an even more efficient
Lightning-Symmetry implementation possible.

So, if you are only interested in Lightning-Symmetry and covenant pool
constructions, Ark-like constructions, and you value the simplicity of the
TEMPLATEHASH implementation, like, you put a large value into that simplicity
and the fact that it's tapscript only, there have been people who were not happy
about using an upgradable NOP code and stuff like that, then you would think
that this is a strictly better proposal.  From a certain perspective, it is
strictly better.  Like I said, we are trying to consider a lot of different
risks.  When we propose these four opcodes, we are trying to consider social
trauma risks as well.  And from that perspective, I think LNHANCE is better.
But from any technical perspective, I think TEMPLATEHASH, CSFS and INTERNALKEY
are a very, very good, solid proposal.  So, I like it on a technical level.  I
think it is going to have a regrettable, how do you say this, fallout in the
social space.  If we go that direction, that's what I predict.  And again, if I
think that we are going to have script restore, we are going in the GSR
direction, this is another aspect to all this, then we are going to have CAT.

So, any PAIRCOMMIT, VECTORCOMMIT proposal can be implemented with CAT.
PAIRCOMMIT is still a simpler and safer way to do it, but you can use multiple
opcodes to emulate basically what PAIRCOMMIT does, and CAT is one of them.  Of
course, a very, very significant threshold breaks in expressivity if we just add
CAT.  So, if I was like 100% sure that we are going to have script restored,
then I would say it might make sense not to add an opcode that was specifically
selected because we thought that we can't have consensus on CAT.  So, that would
be another aspect of this, why you would prefer TEMPLATEHASH, yes.  But if you
say that future is a bit uncertain and we want to improve things now, and the
community is sort of traumatized already and we want to minimize the potential
for these exogenous asset token-related traumas, then I believe LNHANCE is the
better choice right here, right now.

**Mark Erhardt**: Okay, I see.  Because you think that if TEMPLATEHASH came for
the improved backup version with the Lightning-Symmetry, as you call it, you
would want to use the annex for data storage.  And that would lead to people
using the annex for witness stuffing and that would blow up, of course.  So,
LNHANCE, by having PAIR COMMIT, would have a witness construction that doesn't
specifically allow more data stuffing, and that way it's socially safer.  Is
that your argument?

**Moonsettler**: Yes, yes.  And again, if you had PAIRCOMMIT with TEMPLATEHASH
and TEMPLATEHASH, let's say, only committed to the annex being there or not
being there, not the annex data, just annex present or not present, In that
situation, I might even consider that proposal superior to the current LNHANCE
proposal with CTV.  Although, we also like CTV for its ability to be used as
bare CTV.  You can use it in legacy script without whole witness thing, and
everything.  We like that in theory but in practice, it always seems to be that
you really want taproot.  You really want to have, so long it's not broken, that
keypath be available for any cooperative change and optimization, like you can
just skip the whole script tree, taptree thing, and you can just do a single, I
mean, It's probably a collaborative music-based signature, but it still looks
like a single-sig, and it reveals minimal information about what happened
onchain.

So, that is a preferable way to resolve things cooperatively, always.  So long,
again, we do not have this cryptography broken, that is very efficient and also
baked in all of these protocols to have that ability to shortcut the script
execution.  So, from that regard, it's not super-valuable, but from another
perspective, we actually like that CTV can exist outside of tapscript.  So, this
is like a coin toss, or it can go either way depending on personal preferences.

_SLH-DSA (SPHINCS) post-quantum signature optimizations_

**Mike Schmidt**: And we have one more Changing consensus item this week,
"SLH-DSA (SPHINCS) post-quantum signature optimizations".  We were unable to get
conduition on, so I'm going to do my best to talk about post-quantum signature
optimizations.  Murch can chime in if I make a mistake, otherwise conduition's
got some great blog material as well.  So, yeah, conduition posted to the
Bitcoin-Dev mailing list about optimizing the SPHINCS signing algorithm.  I
found out that SPHINCS+ is now called SLH-DSA.  Murch is already waving at me.
What's up, Murch?

**Mark Erhardt**: No, sorry.  I was just looking what you had written in chat
earlier.  But I think SPHINCS+ is the nickname and SLH-DSA is Stateless
Hash-based Digital Signature Algorithm.  So, it seems much more, technically.
But I don't know, maybe you're right.  I haven't researched the order of things.

**Mike Schmidt**: This has been a quantum-resistant signature scheme or
algorithm that's been a candidate for the BIP30 proposal and other ideas around
quantum resistance to Bitcoin.  Conduition has made a bunch of performance
improvements in the algorithm that he believes he may now possess, "What may be
the fastest publicly available implementation of SLH-DSA, (at least on my
hardware", and possibly also one of the fastest GPU implementations".  Moon, I
see your hand up.  Moon, you're muted.

**Moonsettler**: Sorry.  So, I just wanted to chime in on that you generally
don't want, strictly technically, something like SPHINCS for Bitcoin.  If your
goal is just to have like one signature per spending a UTXO, then SPHINCS is
way, way overdone.  We can have much more efficient post-quantum signature
skills using hashes.  SPHINCS is more suited to not-Bitcoin context and into a
context where you have to sign multiple times, even many times.  But this has a
cost, right?  So, basically, in Bitcoin what the developers are trying to do is
balance out the typical use cases in Bitcoin against the cost of using something
very general and not really developed with Bitcoin in mind.  And the key piece
seems to be this random forest of one-time use signatures thing, where basically
you are trying to make it stateless because you can only use these hash-based
signatures one time.  So, if you don't want to have to maintain a state in a
signing device, that's a pain in the ass, then you have to take a digest of the
transaction and use that as a source of randomness and find a random tree branch
that you want to sign with.  So, that is kind of what they researched, if I
understand it correctly.

**Mark Erhardt**: I have to disagree briefly.  I would love if we could make
UTXOs, like, if you could only sign a single time for a UTXO, that would be
great.  But we cannot do that.  That would obviously get rid of address reuse
immediately, which would be brilliant.  But what if you create a transaction
that, for example, if you have to bump a transaction because it was too low fee
the first time, right?  So, there's always situations in which you have to
reissue the same transaction.  So, even if you don't have any address reuse, you
have to be able to sign more than once for Bitcoin transactions, or it would be
very easy to just censor your transaction from being confirmed, waiting until
you make a signature, and then forge your signature and steal your money.  So,
we need many, many times signatures.

**Moonsettler**: Yes, yes, I agree.  However, Bitcoin has this thing with
taproot already, where you can have non-balanced trees.  SPHINCS is ideal, I
mean, imagine to have a balanced merkle construct set that they call
hyper-forest, or whatever, I don't know.  And basically, the Bitcoin equivalent
would be, most of the times you want to have one signature, but you want to have
the ability to have multiple, many signatures at more cost, more storage cost,
more bandwidth cost, more fees as a backup if you have to, but you are
optimistic.  You actually think that your first, let's say 90%-something of the
times, your first signature will get into a block.  So, you want to have that
really efficient.  And that's what I wanted to mean that SPHINCS is not really
suited for Bitcoin, but this research looks great.  I did not dig into it, but I
really, really liked what I read so far.

**Mark Erhardt**: That's an interesting point.  If you had sort of a tree of
possible leaves to spend from, and you only get to use each leaf once, but you
could still have many leaves and the cost would just gradually increase.  That
would actually also satisfy our requirement.  But then when you, for example,
fee bump your transaction, your transaction would also increase in size, which
is kind of funny.  At the higher feerate, you also have to make the bigger
transaction.

**Moonsettler**: And it's stateful, right?  That's what I mentioned.  The
downside is that it looks more suited for Bitcoin, but the statefulness bites
you back.

**Mark Erhardt**: Right, so back to SPHINCS.  SPHINCS is based on a modified
version of Winternitz One Time Signatures (WOTS) and on a few-time signature
scheme, I think that's the point, with the Forest of Random Subsets (FORS) and
merkle trees.  So, the big downsides are they're enormous comparatively to what
we're using these days.  I don't have it here from the top of my head, but we're
looking at several kB for pubkeys, and signatures currently are in the several
hundred bytes at least, I think 800 bytes or more.

**Moonsettler**: What do we call a pubkey?  Because in theory, everything can be
just represented as a hash when you are dealing with a pubkey in script, right?
So, when you are representing a pubkey in script, everything is just a hash, a
forest root is just a hash.  So, I'm always confused by this.

**Mark Erhardt**: You could make a commitment to a public key into the output,
and thereby use the output data cheaply or use less output data that is
expensive, and then provide the additional information in the witness to prove
that you were authorized to spend, and so forth.  Or maybe not the witness, but
another extension because the data is so much bigger here now.  Otherwise, that
would be a huge throughput decrease.  But how you implement that specifically is
maybe not that important, but generally per operation that we're performing, per
input that we're spending, we would have a lot more data onchain to authorize
the transaction.

**Moonsettler**: Yes, I think right now we have like 65-byte signatures, 65 to
80 bytes, something in that range, right?  And the smallest hash-based signature
was 304 bytes.  And actually, what I have been playing with ranges from 800 to
3.5 kB.  These are very primitive.  The proposal that they have been looking at
are actually better.  But if you want to use the stateless structure, then it is
going to be kB, that's for sure.

**Mark Erhardt**: Yeah, and stateless is very important.  For example, on
hardware devices, we would not have access to what's in the mempool or what has
been signed before, or it would be very painful to store.  If you, for example,
use some sort of Tails-implemented wallet, or whatever, where you don't know
what you did before, or generally have signers that don't track previous
interactions, we absolutely would like stateless signatures.

**Mike Schmidt**: Well, conduition is not necessarily improving any of these,
the output of these, but more so the optimization and the performance of doing
these particular operations.  So, for SLH-DSA, his optimizations,
performance-wise, required several MB of RAM and some pre-computation, so it
wouldn't help in these resource-constrained environments like hardware signing
devices.  In his post, he wrote up a bunch of different optimizations to improve
performance, SHA256 midstate caching, XMSS tree caching, which is one of the
internal data structures used in SLH-DSA; he applied some hardware acceleration
using dedicated hardware instructions from CPU manufacturers, vectorized hashing
paralyzing some of the hashing operations, multithreading to paralyze some of
the other operations, GPUs, and the Vulkan graphics programming API to further
paralyze some operations.  And the output, the data comparison or the time
comparison, in his notes, his code can then sign a message in 11 milliseconds,
while the fastest open-source library he notes is 94 milliseconds.  That's the
PQClean library.  His code can generate keys in 2 milliseconds, whereas PQClean
takes 12 milliseconds.  And I also saw that there was a big speed up in
verification, according to the visuals on his chart.  I didn't see exact
numbers, but it looked like at least an order of magnitude faster on
verification as well.

**Mark Erhardt**: I think he wrote somewhere that the signature verification was
almost as fast as the elliptic curve signature verification.  Oh, actually,
that's in our write-up here.

**Mike Schmidt**: Because we didn't have conduition on, I would encourage folks
to not just read our summary, but he has a blogpost that he references in his
original post to his conduition.io website that gets into the details.  And that
blog also has an earlier post from a few months ago, I think it was a few months
ago, overviewing the different hash-based signature schemes.  So, if you're
curious about these kind of things, I think that those two blogposts would be
very informative for folks.  Yeah, Moon?

**Mark Erhardt**: I would also encourage everyone to take a look at it.  It
looks extremely well organized, well written.  I haven't had time to dig into
it, I don't think I will.  But it also looks like you need to really take some
time because there is a lot of very complex stuff in there.

**Moonsettler**: I actually love this.  It's much more refreshing to me
intellectually than the whole filter talk and all that thing about OP_RETURN.
So, I like this better.

**Mark Erhardt**: We're talking about a low bar here.

**Moonsettler**: Yeah, but one more thing I wanted to say about all this.  So,
we are talking about all these things because of the potentially
cryptographically-relevant quantum computers to appear in the coming few years.
This is not a certainty.  A lot of people are handling it as a certainty.  We
don't know.  It has a huge cost for Bitcoin to upgrade, assuming that we are
going to have cryptographic and quantum computers.  And if that does not happen,
then this cost was paid for nothing, basically.  And that is another reason why
I think we should probably consider stateful signing first and only migrate to
more comprehensive post-quantum solutions if that future actually unfolds.  So,
I'm on the side that says we should just enable the basic primitives, where
people can use them to create quantum-safe outputs, where you have optionality
at spend time.  So, you can decide at spend time if you want to use an AC
signature, if you want to use an EC signature that is signed by a post-quantum
algorithm.  This can be a different tapleaf, you know.  You can just reveal a
tap leaf where you also have to provide a lamport signature, which is very
inefficient.  These WOTS's are much more efficient, computationally heavier, by
the way.  So, lamport is computationally very lightweight, WOTS is
computationally heavier.  So, it's a larger cost for every node, but a smaller
cost in terms of data storage and network propagation.  So, you have to balance
these things out.

But I digress.  My point was that I believe we first should provide people with
the optionality to have a quantum-resistant way to spend their coins at spend
time, so they can decide "I heard in the news that someone somewhere cracked a
160-bit elliptic curve signature and they proved it that they could crack it
with a quantum computer.  Okay, I am going to spend my 1,000 bitcoins or 10,000
bitcoins now attaching some form of quantum-hard algorithm from this day on".
But maybe someone closing an LN channel does not really care about it if the LN
channel is like 1 million sats.  So, it's not going to happen all at once.  It's
not going to make every UTXO capable all at once.  People have different
perspectives.  I personally believe we should give them the freedom and I think
we should take a hard look at more Bitcoin-friendly stateful constructs for now,
before the migration happens, before the full post-quantum migration happens.
That's just my take on this.  Sorry.

**Mark Erhardt**: Awesome, thank you for that.  I was going to say something
very similar.  I think the BIP360 is currently again in a pretty substantial
rewrite and it's getting closer and closer to this taproot without the keypath
construction.  And I think that would very much fit into what you're describing,
where we would have a script leaf that is spendable just with schnorr
signatures, and slightly more expensive because you have to go to the script
leaf, show in the control block that it existed in the tree, and then you would
have the option to have post-quantum leaves next to that, that you can fall back
to.  So, when you spend, you can just simply only reveal the post-quantum leaf
and use that.  And I hadn't actually considered previously the route of going
stateful first, but you could even have leaves for stateful and stateless.  And
that might be interesting.

**Moonsettler**: Yes.  And the first thing, the most important thing is to deal
with long-range attacks, right?  And BIP360 already deals with long-range
attacks, if everyone migrates to BIPS360, of course.  We can do nothing about
non-migrating UTXOs, sadly.  Or, that is a very difficult conversation I don't
want to steer into.  But first, you have to deal with the long-range attack.
And when it looks like short-range attacks are becoming maybe possible
practically, then you really have to deal with the short-range attacks.  Again,
I think first optionally, and then we will see.  And once sufficient
capabilities demonstrated, we absolutely have to migrate a full post-quantum,
maybe stateless signature scheme with another block size increase, another
extension block, or something.  We will see, I guess.

**Mike Schmidt**: Awesome.  Moon, thanks for chiming in on that one.  I think we
can wrap that up and thus wrap up the Changing consensus segment for this week.
And we'll move on to Releases and release candidates.  Moon, you're welcome to
hang on, or if you have other things to do, we understand.  We have two releases
this week.  I'll turn it over to Gustavo, who authored this, and the Notable
code segment for this week.  Thanks, Gustavo.  Welcome.

_Core Lightning v25.12_

**Gustavo Flores Echaiz**: Thank you, Murch. And thank you, Moon and Julian, for
all the great work in explaining.  So, this week we have two releases on the LN
front.  The first one, Core Lightning v25.12, also called Boltz's Seamless
Upgrade Experience, adds a few new features, such as BIP39 mnemonic seed phrases
as a new default backup method; pathfinding is improved; xpay, the paying
method, is also improved heavily; experimental JIT channels are added; and there
are many other features and bug fixes.  One important thing to remark from this
release is the vast array of performance improvements for large nodes.  I
believe that's why they call it the Boltz's Seamless Upgrade Experience, because
Boltz, being a service that uses Core Lightning (CLN), benefits from these
improvements for large nodes.

Importantly to also add that there are breaking database changes related to
these performance improvements.  So, this release includes a downgrade tool, in
case something goes wrong when upgrading the database, but we're going to be
covering that in more detail in the Notable code and documentation changes
section.  So, that covers Core Lightning v25.12.  There are many more features
and bug fixes explained in the change log or release notes of this new version.

_LDK 0.2_

So, for LDK v0.2, This is a major release of LDK that adds splicing in an
experimental manner; serving and paying static invoices for async payments,
which has been a work of many months, even maybe even years on LDK; and finally,
zero-fee-commitment channels using ephemeral anchors are also part of this
release.  It's important to note that splicing is expected to be compatible with
Eclair and future versions of CLN.  However, the async payments implementation
will only work with LDK-based nodes.  Also, another important change is the
expansion of the API to offer a native Rust asynchronous API.  So, a few methods
are updated to operate in asynchronous manner.  But many, many more changes
right there.  So, that covers the release section.  Murch, Mike, any comments,
anything to add here?  Perfect.

_Core Lightning #8728_

We move on with the Notable code and documentation changes, where we have CLN,
LDK, LND, BTCPay Server, and also a BIP improvement.  So, we start with Core
Lightning #8728.  Here, there's a bug fix related to the password you enter when
unlocking your hsmd, or simply the key related to your CLN node.  So,
previously, once a user would enter the wrong passphrase, hsmd would crash with
an unknown message type.  Now, this is properly handled so that it doesn't crash
if you enter the wrong passphrase.  It will simply handle this user error edge
case and exit cleanly.  So, maybe not a huge improvement, but quite user-facing,
because the user wouldn't understand why it would simply exit.  It would fail or
crash instead of just responding that the wrong passphrase was entered.  And
particularly what happened here is that it was using write_all() and write_all()
was missing the wire protocol length prefix.  So, when lightningd would receive
the error or message type from hsmd, it wouldn't interpret it correctly.
However, write_all() is replaced with wire_synce_write(), which makes it that
there's no unknown message type error and this is properly handled and exits
cleanly.

_Core Lightning #8702_

So, we move on with Core Lightning #8702.  This is the one that I was mentioning
in the Release section.  There's a lightningd-downgrade tool that is added.  In
case there's an error when you upgrade your database, you can safely downgrade
it to 25.09 in case of an error.  So, not much else to say here, just a safety
mechanism for the new release.

_Core Lightning #8735_

And finally, the last one for Core Lightning, #8735.  Here a long-standing bug
was fixed, where basically CLN, when it restarts, it will roll back the latest
15 blocks; well, by default, that could also be configurable.  When it rolls
back those latest 15 blocks, any transactions it had saved, or let's say UTXOs
it had saved, it will reset the spend height of those UTXOs that were part of
those 15 blocks.  It will reset that value to null, because it rolled back the
block so it removes the spend height value of the UTXOs that were spent in those
blocks.  However, the bug was that when restarting and re-syncing the chain and
downloading the blocks, it would not properly update the spend height of those
UTXOs.  So, basically, what this PR does is that CLN will now make sure to
re-watch all UTXOs, including those that were rolled back and spend height was
removed.  So, not only does that move forward so that the bug is removed in the
future, but it also adds a one-time backward scan to recover any spends that
were previously missed due to this bug.

So, for example, if you had a node, last week a UTXO spend height was changed to
null because you had rolled back those 15 blocks, and it had failed to re-watch
that UTXO and upgrade updated spend height when restarting, it will now do a
one-time backwards scan to make sure all UTXOs are re-watched.  And the issue
here caused was that Core Lightning could relay channel announcements that had
already been closed, because it would fail to re-watch a UTXO that was spent
that would close a channel.  Yes, Murch?

**Mark Erhardt**: Yeah, you said it towards the end, but when I read this, I
missed the actual thing.  So, when you restart a CLN node, it might miss a block
or miss announcements.  So, on starting the node again, it goes back 15 blocks
and reprocesses the blockchain and the announcements from there.  And in order
to do so, it would sort of reset the state to 15 blocks in the past, which would
mean that it changed how it perceived channel states back to 15 blocks ago.  So,
if CLN had a state change in those blocks, it would actually not re-watch the
new channels because it sort of would remove information from its database and
then not recollect it on this 15-block rescan.  So, this seems like someone
thought about, "Oh, in order to process this correctly, we need to roll back the
state", but then something changed in how things got processed versus the first
time, and it wouldn't get reprocessed in the same way.  So, it caused, if you
had any statechain during the time, these 15 blocks, it would introduce some
observation differences versus the original scan.  Anyway, it seems like they
fixed it.  It's kind of scary that they had this bug, I must admit, but good
that they fixed it.

_LDK #4226_

**Gustavo Flores Echaiz**: Yeah, exactly as you mentioned it Murch.  That was a
good way to rephrase this PR.  Thank you for that.  So, we move on with LDK
#4226.  So, here two things happen.  I would say, if we follow in the commit
order, three new local failures are added that are explicitly related to
trampoline payment forwarding.  So, LDK has a very minimalistic trampoline
payments implementation where forwards were not yet implemented.  So, three new
failure reasons are added as a first step towards supporting trampoline payment
forwarding.  As well, another safety mechanism is also added that basically
enforces the trampoline onion recipient constraints.  This means that tests are
added to cover the validation of trampoline payloads against the outer onion.
And this is specifically related to the amount and the CLTV
(CHECKLOCKTIMEVERIFY) fields of received trampolines.  So, just a safety
mechanism and overall preparation towards more support for trampoline payments
in LDK.

_LND #10341_

So, the next one is LND #10341.  Here, a bug is fixed where basically, on a
restart of the Tor service, LND would re-add the same Tor onion address to the
node announcement, and so the getinfo output.  So, basically, the onion address
would just be duplicated in that announcement and that output of the command.
So, here instead, the PR ensures that the createNewHiddenService will never
duplicate an address.  So, if the Tor service restarts, it will make sure not to
duplicate an address that is already present in the node announcement message or
the getinfo output.  So, this wasn't a major issue, it's just a cleaner way of
handling a Tor service restart.  Anything to add here, Murch, Mike?  Perfect.

_BTCPay Server #6986_

We move on.  We have BTCPay Server #6986.  So, a new feature here is introduced
called Monetization, which enables ambassadors, which are BTCPay Server users
that run a server that are doing a lot of work onboarding users and merchants,
this feature allows them to monetize their work.  And how does it work?
Basically, when I'm an ambassador and I'm, let's say, onboarding users and
merchants to BTCPay Server in my city or my country, I will often run a server
and tell them to sign up to my server so that they can create their store on my
server.  This feature allows server admins to require a subscription for user
login.  So, this means that a user that creates an account on my server, or
let's say a merchant that creates an account on my server, would enter first a
default seven-day free trial period.  And I could, as a server admin, then
configure a starter plan or a second-tier plan.

Really, this builds on a feature we described in Newsletter #375 called
subscriptions, where merchants can define recurring payment offerings and plans
to users.  So, this is just a way, an extension of the subscription feature,
allowing ambassadors of BTCPay Server to monetize their work in this way.
However, there's defaults, like I mentioned, of a seven-day free trial period
and a free startup plan.  However, admins can customize this in the exact way
they want.  Finally, existing users that already had a store on a server of an
ambassador will not be automatically enrolled into a subscription, though the
server admin can easily migrate pre-existing users to the new subscription
model.  Any extra thoughts here?  Perfect.

_BIPs #2015 _

So, the final one, BIPs #2015, adds test vectors to BIP54, which is the
consensus cleanup proposal.  Here, new test vectors are added for the four
different parts of the consensus cleanup soft fork.  This is generated using the
BIP54 implementation that is available on an open PR in Bitcoin Inquisition.
And also, a custom miner test unit that is included in the custom Bitcoin Core
branch is also used to build these test vectors.  So, this also includes
documentation and instructions on how to use and review these test vectors to
review this proposal.  So, in Newsletter #379, this was also covered in the
Changing consensus section.  So, you can check that newsletter for additional
context on these test vectors in this BIP proposal.  So, that covers this
section and the whole newsletter and show.  Murch, Mike, if you have any
thoughts, please?

**Mark Erhardt**: Yeah, so we require or we emphatically suggest that BIPs have
test vectors before they move to proposed, and they're required before BIPs move
to final.  So, having test vectors to test that you implemented a BIP correctly
means that it makes it much more likely that the different implementations of a
specification are interactive, they are all spec-conform.  And so, the great
consensus cleanup is moving towards, well, it's been a multi-year process.  It
was originally proposed in 2019.  There's this redo or warming it back up by
Antoine Poinsot in the last two years.  And with the test vectors now, I think
the BIP is not just completely specified, but also it's easier to implement
completely.  I think this is a another milestone towards being able to actually
propose activation of the great consensus cleanup.

So, I think that if the consensus cleanup is something that you're interested
in, it's time to get a little more verbal about it and to mention that this is a
proposal people should be looking into and supporting, because I think it's by
far the closest among soft fork proposals that is on the adoption curve or
readiness curve.  So, yeah, anyway, great consensus cleanup is getting closer to
being.

**Gustavo Flores Echaiz**: Thank you, Murch.  I want to add that if people are
interested in this specific proposal in Newsletter #340, there was a breakdown
of the different parts of this proposal, which are the legacy input sigops
limit; increasing the timewarp grace period to two hours; and the duplicate
transaction fixed.  So, people can check out Newsletter #340 for additional
context to fully understand what this proposal is about.

**Mike Schmidt**: Yeah, and check out the topics page as well, where you see
references to some of what Gustavo mentioned among other mentions.  And I think
that Antoine's been out as well doing podcasts and videos with people about
BIP54 and why we should be thinking about that as a potential Bitcoin protocol
change.  So, thanks, Gustavo, for taking us through the Releases and Notable
code segment.  Thank you, Murch, for co-hosting as well.  We want to thank Moon
and Julian for joining us and for you all for listening.  Cheers.

{% include references.md %}
