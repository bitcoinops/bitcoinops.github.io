---
title: 'Bitcoin Optech Newsletter #367 Recap Podcast'
permalink: /en/podcast/2025/08/19/
reference: /en/newsletters/2025/08/15/
name: 2025-08-19-recap
slug: 2025-08-19-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt discuss [Newsletter #367]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-7-19/405929742-44100-2-98de920f2e5c8.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Optech Newsletter #367 Recap.  Today,
we're going to cover two release candidates and four PRs.  We have no guests
this week, so it's just going to be Murch and I, and there's also no news this
week.  So, we're going to go right into the Releases and release candidates
segment.

_LND v0.19.3-beta.rc1_

LND 0.19.3-beta.rc1, which is an RC for LND that we covered last week.  And
actually, last week, when we covered some of the contents of this RC, there were
actually some gossip-related changes related to the RC that we also covered in
the Notable code segment.  So, if you're curious about that, refer back to #366
Podcast.

_Bitcoin Core 29.1rc1_

Bitcoin Core 29.1rc1 is an RC that we covered last week and the week before.
Last week, it was Gloria and I talking about it, and two weeks ago, Murch and I
covered it as well.  So, I would refer back to that those materials.  Murch,
anything to add on that release?

**Mark Erhardt**: No, not really.

**Mike Schmidt**: Okay.

**Mark Erhardt**: I think we already covered that this one makes the
pathological legacy transactions with a large count of sigops non-standard.  I
think that's still the biggest and most interesting.

**Mike Schmidt**: Yeah, I think that's the big one.  So, I guess if you're doing
the extremely pathological things, check out this RC to make sure that it
breaks.

**Mark Erhardt**: I think there's been only a dozen or a couple of dozen
transactions in the whole history of Bitcoin that were above this, and they are
very deliberately doing weird stuff.

**Mike Schmidt**: And they were all Core developers messing around!

**Mark Erhardt**: Maybe, I don't know.  The other one that I saw was that that
maxmempool and dbcache are being capped on, was it 32-bit systems, or whatever,
which I guess shouldn't really affect people much anymore.

**Mike Schmidt**: And if you look at what's in that RC, you can reference some
of the PRs, and I think we've covered many of them in previous shows.  I didn't
list them all out here, but we did cover that dbcache default, and we covered
the pathological transactions PR as well.  So, if you want to dig into some of
that a little bit deeper, maybe cross-reference the Optech Newsletter with the
PRs that are in this RC.

_Bitcoin Core #33050_

Notable code and documentation changes.  Bitcoin Core #33050 titled, "Don't
punish peers for consensus-invalid txs".  Maybe some background here and, Murch,
you can chime in if you have something to add.  But so, if you're running a node
and your node's peer misbehaves, for example sending invalid blocks or headers
or a variety of other misbehaving type things, Bitcoin Core will discourage that
node; discouraging meaning disconnecting from that node and not connecting at
least outbound to that node for, I believe, 24 hours.  Although I think it will
accept an inbound.  So, you're essentially slapping that node on the wrist for
misbehaving, at least in terms of your node's operation.  This discouragement or
punishment can apply for standardness rule violations as well as consensus
violations.  So, this PR is no longer going to punish peers for relaying
consensus-invalid transactions to the node.

So, there's two big parts of this PR.  The first part, and there's three commits
but two of them have the meat of the changes, one is a test-related one.  The
first is eliminating the punishment or discouragement for consensus-invalid.
And the rationale there is that what an attacker could do, so in an
adversarial-minded scenario, they could make a non-standard and
consensus-invalid transaction.  And due to the way that the discouragement is
processed, it would hit the non-standard check first and thus you'd be able to
bypass the consensus check.  And so, because that's possible, the consensus
check is kind of not doing what was originally intended, and so that's why AJ
has proposed to remove it.

I have those quotes up now that I wanted to bring up earlier.  AJ says, "Do not
discourage nodes, even when they send us consensus-invalid transactions, because
we do not discourage nodes for transactions we consider non-standard.  We don't
get any DoS protection from this check in adversarial scenarios, so remove the
check entirely to simplify the code and reduce the risk of splitting the network
due to changes in transaction relay policy".  And sipa actually chimed in with a
comment, I'm taking these a bit out of order just because I think they logically
make sense, but sipa chimes in saying, "I agree that the current ability to
distinguish consensus versus standardness failures doesn't really achieve much.
It is not the case that consensus invalidity is inherently harmful to us in
terms of DoS potential more than non-standardness violations, and attackers
today can already mask any consensus invalidity by causing a non-standardness to
be detected first, evading the punishment".  So, that was sort of back to what I
was trying to articulate earlier.  Murch, I said something earlier that I think
is now incorrect after having reread this and spit it out.  There is no
discouragement when standardness rules are violated?

**Mark Erhardt**: So, the behavior in that regard changed a few times in the
past years.  It used to be that we would have a score for each peer, how much
they have misbehaved, and then only ban or discourage them after they accumulate
a certain amount of score.  So, basically we would allow them to do stuff that
we don't like several times, depending on what they did, and that was recently
changed to either immediately lead to a ban or disconnect, or by leading to no
discouragement at all.  Okay, so this discouragement meant that if we got a new
peer request to connect, we would disconnect the peer that we wanted to
discourage first.  They were not getting banned or disconnected immediately,
they would just be the first to be disconnected next time we disconnect someone.
And I think that we might still sort of do that, but I don't remember 100%.  I
do know that the whole ban score thing was discontinued.  We just either
immediately disconnect or don't do anything.  And yeah, with the regard to the
consensus and standardness checks, my understanding is now that we just get a
single pass of all the checks, so it'll be computationally a little faster.  And
yeah, so it's basically a code improvement, dropping some unnecessary code,
making it a little faster, and it does not increase the dust surface, because we
still do the checks, but all together, I think.

**Mike Schmidt**: Yeah, if you're parsing only once, then you're only doing one
set of checks versus two, and that was the second part of the PR, is removing
that second pass of checks, which has a performance benefit.  I believe that
there is a PR that's tracking IBD (Initial Block Download) performance, and I
think it referenced this PR as one of the things that is improving IBD
performance.  Sipa says one more thing that I think would be interesting to wrap
up with, "So, it seems the benefit of this distinction", and I think he's
referring to the standardness versus consensus distinction, "is largely so we
can kick peers with diverging consensus rules.  That is worthwhile, but we have
other measures that take care of this already, disconnecting ones that give
invalid blocks and actively seeking out more connections when we don't learn
about a new block for a while".

**Mark Erhardt**: Right, so you could send consensus-invalid transactions, for
example if you have not upgraded to a soft fork, some soft fork activated,
you're still on an old version and someone gives you a transaction that used to
be valid, but is no longer valid.  If you forward that, then you would be
basically running a legitimate node, not attacking or anything, but still
sending a consensus-invalid transaction.  And we might not want to disconnect
our peer just for running an outdated client, right?  But if someone sends us an
invalid block, that is definitely a sign of something being wrong.  So, either,
well I guess we could have the same issue with an upgraded node in a soft fork
scenario.  Someone mined an invalid block according to the new rules and this
peer propagated it.  So, if someone did that, we could probably split off a lot
of the outdated nodes that way, like there would be a rift between the outdated
nodes that accept the new block and the upgraded nodes that do not.  But for
transactions, that's all a little less clear, because transaction data is a
little more lenient.  You can do more stuff in it, they're not proof-of-work
covered.  We also don't have propagation guarantees like we have for blocks.  We
only do our best effort on forwarding transactions.  So, anyway, making it
faster to go through transactions is worthwhile.

**Mike Schmidt**: Murch mentioned some of the history around this behavior in
Bitcoin Core and actually, one of the follow-up comments AJ posted in the PR
referenced several of historical PRs and their interplay in this discouragement
and in this discussion, including some of the edge considerations around soft
fork timing and things like that.  So, if you're curious, dig into that comment
by AJ and follow all those historical PRs to get up-to-date.

_Bitcoin Core #32473_

Bitcoin Core #32473, introducing per-txin sighash (signature hash) midstate
cache.  Murch?

**Mark Erhardt**: So, when we validate transactions, we have to check that the
signatures actually commit to the correct transaction.  And we do that by
crafting something we call a sighash, which is not confusing at all because it's
not a hash of a signature, but actually more of a commitment to the data in the
transaction.  So, this sighash is basically, in the default case, composed of
the list of inputs, the list of outputs, the amounts, and some other data, but
not the signature data.  And we calculate this separately for each input that is
being checked and signed, because every input has to commit to all the other
inputs and all the outputs.  And if you, for example, had two inputs that spent
from the same output script, you wouldn't want the same signature to be valid
for both.  You wouldn't want someone to be able to just take the signature of
the first input and pack it on the second input, right?  That would be terrible.

So, these sighashes are not just calculated per input, but actually they are
calculated when we run OP_CHECKSIG.  So, if you, for example, had OP_CHECKSIG
multiple times in a script in a complex spending condition, this would be
calculated multiple times.  And this is especially terrible if these scripts are
big already, because a lot of data needs to be hashed.  Well, all of this is
really fast still unless we're talking about huge things.  But for example, if
you're building a transaction deliberately that has a ton of OP_CHECKSIGs in the
script and the script itself is large, you get a compounding effect and it
really takes a while to validate that.  What this PR does is it introduces a
cache for the mostly calculated sighash before the parts that are specific to
the current signature are added.  So, this stays the same for all of the
transactions signatures in the same input.  So, if you have multiple signatures
in one input, we can reuse this calculation, most of it, and just pull it from
the cache instead.

So, this PR is only for legacy transactions, as in everything before taproot
actually.  And so, yeah, we cache most of the sighash calculation per input.
So, if we have the same input and the same sighash type, because if you have
different sighash types, this cache will not work because, for example,
ANYONECANPAY, or something, would be a different commitment than the default
commitment, right? The SIGHASH_SINGLE or SIGHASH_ALL commits to different
inputs.  So, this cache would only apply for the same sighash type and only per
input.  Oops, sorry, I talked too loudly, my microphone was oversteering!  Yeah,
anyway I meandered a little bit.  Did it become clear?

**Mike Schmidt**: Yeah, yeah, I think that makes sense.  Interestingly, these
last two PRs were both tagged with the validation label in GitHub.

**Mark Erhardt**: Yeah, oh, I wanted to mention something.  You were talking
about IP, IBD performance.  IBD performance is going to look like it's going to
be really nicely improving in the next release.  I saw some estimations that
with several IBD improvements coming, currently it's already over 20% faster.

**Mike Schmidt**: I saw something about that too from l0rinc, yeah.

**Mark Erhardt**: Yeah, exactly.

**Mike Schmidt**: Yeah.  That's great to see.  Obviously, there's a lot of
discussion about Core developers and their 'what have you done late lately for
me as a node runner?'  And if you look at 20%, that's obviously a big number for
a project that's been around for this many years.  And if you then dig into,
like I saw that there was a gist or something, the tracking issue for the
performance improvements, and I think there was like a dozen there that were
being tracked.  And you drill into the work that goes into each one of those, I
mean this is not tweaking a database setting to get that 20% improvement.  So,
there's a lot of work that goes into it.

**Mark Erhardt**: Yeah, there's been a lot of benchmarking and testing and a few
people have been really looking at flame graphs and performance analytics, where
exactly the time is spent.  I think we talked to l0rinc recently that he found,
for example, that when you XOR the blocks so that they are obfuscated on the
disk, if you just pick larger chunks of the data, it becomes significantly
faster.  And a few other, like the code changes.  Some of these code changes are
just a couple of lines, but regardless of that, weeks of work went into testing,
looking at what exactly the performance improvements are, analyzing the code
segments, where the performance losses are, and then, yeah, the result might be
a two-line code change and a bunch of tests.  But yeah, so there's been a ton of
work on IBD performance in the past few years, also by other people like Andrew
Toth, and a bunch of that is coming in the next release.

_Bitcoin Core #33077_

**Mike Schmidt**: Bitcoin Core #33077, which is part of the Bitcoin kernel
project, which is the effort of Bitcoin Core to modularize consensus, including
critical components of Bitcoin Core, like block validation, transaction
validation, header rules, etc, into a separate library.  The project has also
been referred to as libbitcoinkernel and includes an API that, I believe, the
API is currently a work in progress, but a way for you to interface with that
logic.  So, this PR is part of that broader project, but the PR this week is
titled, "Kernel: create monolithic kernel static library".  Prior to this PR,
the kernel library required a bunch of the libraries that kernel depends on to
also be available in the file system; whereas after this PR, all of kernel's
dependencies are embedded in the kernel library itself.  I'll pause there,
Murch, because I was a little bit worried that I had this wrong, because if you
didn't get it, I didn't get it.  Does that make sense so far?

**Mark Erhardt**: No, I think that's right.  That's how I understood it too.
So, basically, previously the way it was set up, if you wanted to use the
libbitcoinkernel library, you had to have a few other libraries built as well.
And from reading the PR, it sounded like those instructions were not necessarily
obvious to the library consumers.  And now, the libbitcoinkernel library
directly incorporates its dependency, so it's more standalone.  You only have to
reference that single dependency in order to use the libbitcoinkernel, rather
than the Bitcoin kernel and the Bitcoin kernel's dependencies separately.  And I
think this is basically a quality-of-life improvement for people that want to
consume the libbitcoinkernel library downstream or in other projects.  But happy
to be corrected if I misunderstood that.

**Mike Schmidt**: Yeah, Murch, maybe you can help me get back in my developer
days.  There's also the risk that you were referencing the correct library, but
the incorrect version of that library, which could potentially have unintended
behavior.  So, for the example, kernel referencing secp, you might have secp,
but maybe it's a different version from what kernel expected.  Is that also a
valid concern?

**Mark Erhardt**: That seems very reasonable to me.  Yeah, if the interface was
the same between the dependency and libbitcoinkernel, it would just work.  But
if the code had changed under the hood, it might behave differently than
expected.  So, compiling everything into this monolithic static library would
prevent version clashes like that, yeah.

**Mike Schmidt**: Well, we did mention secp in that example I just outlined, but
one of the dependencies of kernel is secp, libsecp256k1, and in order to embed
secp in the kernel, secp needed to make changes to expose its own underlying
object files, basically like the executables or the binaries, you might think
about it.  And we did cover that change and discuss that in Newsletter and
Podcast #360.  That was libsecp256k1 #1678 PR, which explicitly stated, as the
motivation, being able to be used in kernel.  So, here we are.

**Mark Erhardt**: Yeah, I think this was part of the change to the CMake build
process, where in libsecp, we also needed it to be built with CMake in order to
work in these sort of build processes for Bitcoin Core in that way.

_Core Lightning #8389_

**Mike Schmidt**: Core Lightning #8389.  This is a PR that implements the
changes in BOLTs #1232, and that was a change to the BOLT spec which updates the
channel_type feature to be assumed as opposed to optional.  The channel_type
feature is used to signal support for certain LN channel features.  For example,
you could signal that this channel is going to be a zero-conf channel, or you
could also signal support for different channel commitment formats.  And
basically, this channel_type feature has been around for three years, and
basically all the implementations support it.  So, the change was made to the
spec to make this assumed, or I guess basically required.  And Core Lightning
(CLN) in this PR made the change in their implementation to support that assumed
feature.

**Mark Erhardt**: Right, so 'assumed' in this context means that you require
other LN nodes to set the channel type when opening a channel.  And this
follows, of course, the spec change.  And I think all of the implementations had
been doing it for a while.  So, now they changed it to 'required' and will not
open a channel with you if you don't send the channel_type.

**Mike Schmidt**: Short one this week, Murch.

**Mark Erhardt**: Yeah.  Well, we can only do as much as there's news, right?!

**Mike Schmidt**: All right, thank you all for listening, we're here next week.

**Mark Erhardt**: Yeah, bye bye.

{% include references.md %}
