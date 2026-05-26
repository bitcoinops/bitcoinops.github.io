---
title: 'Bitcoin Optech Newsletter #378 Recap Podcast'
permalink: /en/podcast/2025/11/04/
reference: /en/newsletters/2025/10/31/
name: 2025-11-04-recap
slug: 2025-11-04-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt discuss [Newsletter #378]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-10-4/410597323-44100-2-832b991e31576.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome to Optech Recap #378.  This week, we're going to be
covering the disclosure of four low-severity vulnerabilities in Bitcoin Core; we
have five Stack Exchange questions; and then we have our Releases and Notable
code segments.  Good news for listeners, Murch is back co-hosting this week.
Welcome back, Murch.

**Mark Erhardt**: Thank you.  Yes, I've been traveling for three weeks,
attending TABConf first, then I was at CoreDev, and then I actually got to spend
ten days with my family in Germany, which was wonderful.

**Mike Schmidt**: Incredible.

**Mark Erhardt**: So, I'm back.  I still have the cold that I caught after
TABConf, but it's getting there.

**Mike Schmidt**: Well, we're glad to have you even in a slightly reduced, cold
state.

**Mark Erhardt**: Cold storage!

_Disclosure of four low-severity vulnerabilities in Bitcoin Core_

**Mike Schmidt**: We don't have any special guests this week.  We'll just jump
right into the news section.  We just have the one news item titled, "Disclosure
of four low severity vulnerabilities in Bitcoin Core".  This was motivated by a
mailing-list post from Antoine Poinsot, announcing these four advisories that
were fixed in Bitcoin Core v30.  As a reminder, low-severity disclosures happen
two weeks after a major release.  That was the disclosure policy that we covered
in Newsletter #306.  There's obviously other severities that have different
disclosure policies.  And if you're wondering what a low-severity vulnerability
is, quoting from the bitcoincore.org website, "Bugs that are challenging to
exploit or have minor impact on a node's operation.  They might be triggerable
under non-default configurations or from the local network, and do not pose an
immediate or widespread threat".  Go ahead, Murch.

**Mark Erhardt**: For context, there's four different categories that these
disclosures have: low, medium, high, and critical.  Low are disclosed two weeks
after they are fixed in any version.  So, now that these low severity issues
have been fixed in Bitcoin Core 30.0, they are being revealed two weeks after
the release of 30.0.  Medium and high, which are more exploitable to very
exploitable, are revealed once all of the versions that are maintained are not
vulnerable anymore.  So, once the last version that had that bug gets
end-of-life'd, they are being disclosed two weeks later; and critical
vulnerabilities are disclosed on custom timelines depending on the issue.  They
might be disclosed much quicker because the network needs to be informed and
needs to react, or they might be disclosed much later because they also affect
derivative software, and those tend to have very different life cycles in
Bitcoin Core.

**Mike Schmidt**: One thing to note, three of these four vulnerabilities, at
least looking at the bitcoincore.org timeline for each of them, has a 29.1 fix.
One of them didn't and I'm not sure if that's just because it wasn't fixed due
to considerations, or if maybe that just wasn't updated in that particular post.

**Mark Erhardt**: No, one of them was actually not fixed, and I believe the
reason is, so when we introduce fixes for bugs, backporting them is a very big
signal, right, because while there are dozens of changes going into the master
branch, and it is easier to covertly fix a security bug in the master branch,
only bug fixes are backported to the prior or to the other maintained major
branches.  So, if you want to find vulnerabilities, a very easy thing to do
would be to only inspect the backports.  There are very few, they're very small
usually, they just fix small issues, and then realize that one of those fixes
might actually have bigger consequences than stated in the release, or sorry,
commit messages.  Yeah, either of those actually.  So, I think one of them was
not backported on purpose until it was fixed in 30.0.  And if I recall
correctly, it is now being fixed in another release.  I think there is a 29.2
release already in the works that will fix that remaining issue.

**Mike Schmidt**: That's good color.  Thanks, Murch.  Actually, fanquake, one of
the Bitcoin Core maintainers, has a pinned tweet on October 12, outlining the
challenges to making security fixes in something like Bitcoin Core versus
something like Google Chrome.  So, check out that tweet for some of the insights
that he's thinking about, at least.  Okay, let's jump into the four here.  We
can give an overview of them.

The first one, "Disk filling from spoofed self-connections".  Murch, I had to
look up what a self-connection was, but I guess it's pretty self-explanatory.
It's when in Bitcoin Core, a node unintentionally connects to itself.  Do I have
that right, Murch?  Great.

**Mark Erhardt**: I think it is actually not connecting to itself, but you
pretend that the message you're sending is coming from the node itself.

**Mike Schmidt**: And in this case, the attacker would actually wait for the
victim node to connect to it.  And then, based on that information in that
connection, he can reuse the version message nonce to trick a victim node into
making a lot of self-connections or attempted self-connections.  Okay, so that
doesn't sound so bad, right?  But the danger here is that when a self-connection
occurs, it's logged to the log file on disk.  And if the attacker keeps
repeating that same process, it can fill the node's hard drive.  Now, in this
particular situation, the attacker only has a 60-second window in which that
nonce is valid, so they can do it a bunch -- I'll just use the word 'bunch' of
times -- in that 60 seconds, but it would actually take a very long time to
actually fill the disk.

**Mark Erhardt**: Right, so pretty hard to exploit, only makes your node write
extraneous log messages, and then of course creates a data footprint on your
node.  And let's be honest, writing so much log messages that your node crashes,
you have to do a lot of stuff.  And so, this is low severity.

**Mike Schmidt**: Yeah, and I think the log message itself is quite small, so
you just need more and more and more of those.  I'll get to the mitigation here
after the second vulnerability, because it's the same mitigation.

**Mark Erhardt**: Maybe just a little color.  I saw in the timeline here that
this was reported in 2022 and I think it just got a little delayed in the
discussion of the security disclosure, and it took a while to get fixed.  It was
re-reported, and then finally the fix got merged.  Just looking at the timeline
here.

**Mike Schmidt**: Second vulnerability is titled, "Disk filling from invalid
blocks", in which an attacker repeatedly sends invalid blocks to exhaust the
disk space, similar to the last bug.  This time, the attacker sends clearly
invalid blocks to a victim node, and that victim node also logs entries in which
those blocks are given to it each time.  And so, eventually, you give enough of
these invalid blocks, the attacker could fill the disk eventually.  But again,
this would take a long time.  And the mitigation for this and the previous
vulnerability were the same.  They were fixed in the same PR that essentially
added log-rate limiting more broadly, so it took care of both of these log
filling attacks.

**Mark Erhardt**: Now, I might be wrong on this, but I'm pretty sure you
disconnect a node if they send you an invalid block.  So, I'm not sure though if
you could just make a new connection and send the invalid block immediately
without being asked for it.  So, there might be an aspect here where you have to
make a ton of new connections to even send those invalid blocks on top of
creating invalid blocks and sending them.  And then also, we're not storing the
invalid block.  We're just storing a log message for each invalid block.

**Mike Schmidt**: Right.  We actually do get into some of the connection or
disconnection in an unrelated one of these third or fourth vulnerabilities.  But
yeah, I'm not sure on there if you would get disconnected from sending a clearly
invalid block.  Exercise for the listeners.

Third vulnerability, "Highly unlikely remote crash on 32-bit systems".  This is
in which a pathological block could crash a 32-bit node.  I thought actually the
write-up here was going to be better than my summary.  So, to quote from the
bitcoincore.org recap of this, "Before writing a block to disk, Bitcoin Core
checks that its size is within a normal range.  This check would overflow on
32-bit systems for blocks over 1 GB, and make the node crash when writing it to
disk.  Such a block cannot be sent using the P2P block message, but it could, in
theory, be sent as a compact block if the victim node has non-default large
mempool which already contains 1 GB of transactions.  This would require the
victim to have set their -maxmempool option to a value greater than 3 GB, while
32-bit systems may have at most 4 GB of memory.  This issue was indirectly
prevented by capping the maximum value of the max mempool setting on 32-bit
systems".

**Mark Erhardt**: Okay, first nit, you're misreading this.  Some of these values
are GB, and the last value is a GiB bit, which refers to a slightly different
unit, but that's just nittiness, I know.  Anyway, it's pretty dumb.  You would
expect a very, very small memory node with an ancient CPU architecture to set an
extremely high non-default mempool, and then have over a GB of transactions that
are being used to create an invalid attack block.  So, yeah, anyway, this is not
even once in a blue moon.  You have to set up your node in an extremely
unintuitive, dumb way to even be vulnerable to this.  But anyway, it was found
and fixed.

**Mike Schmidt**: Yeah, and it was fixed in Bitcoin Core PR #32530.  They titled
this one as a covert fix.  And, Murch, we covered that in this podcast and we
had no idea.  I remember there was a -maxmempool and some other setting on
32-bit systems that we had talked about previously.  So, it got by us.

**Mark Erhardt**: Yeah, also, maybe let me elaborate on the GB versus GiB.  So,
the System International de Unit, the international system of units, is using
base 1,000, obviously, base 10, and computers use base 2.  So, it makes much
more sense to have units that are based on 2<sup>10</sup> power, 1,024.  And
that is what these units are, where a random 'i' appears after the magnitude
modifier, the prefix.  So, here in this case, Giga (G) becomes Gibi (Gi), Tera
(T) becomes Tebi (Ti), and so forth.  And that means the unit to the 9th power
would be GB per the system of units, and GiB is 1,024<sup>3</sup> to the third
power.

**Mike Schmidt**: We need Murch on more vacations so he can double-click on
these things for us.  Thanks, Murch.

**Mark Erhardt**: Well, you're welcome.

**Mike Schmidt**: Okay, last disclosure titled, "CPU DoS from unconfirmed
transaction processing", which involves specially crafted unconfirmed
transaction that can cause resource exhaustion.  In this case, an attacker can
send a non-standard transaction to a victim node, which would take a few seconds
to validate.  I'll go on, but I wanted to have a sidebar here, Murch.  How long
does it normally take to validate a normal transaction?

**Mark Erhardt**: Microseconds.

**Mike Schmidt**: Okay, so orders of magnitude more for this specially crafted
transaction.  So, in this case, to your point earlier, it was noted in the
write-up that this attacker would not be disconnected after providing this
non-standard transaction.  So, the attacker can continue to repeat this and slow
the victim node, which is unfortunate.  I think in the write-up, it was compact
block propagation was the concern, but obviously anytime someone's making you do
a bunch of work on your node, and you could potentially have more of these
attackers doing the same thing, that's not a great thing.  So, the issue was
actually mitigated over three different PRs, reducing the validation time in
different script contexts for each of those PR, and we have a fix.

**Mark Erhardt**: Yeah, looking at the timeline, this was reported in April this
year, so I think this might have come out of research for the consensus cleanup
BIP, because Antoine Poinsot reported that and he had been looking into how to
craft the worst possible blocks for block validation.  So, the first fix
mitigating the worst-case quadratic signature hashing is actually pretty nice.
I think we covered this one on here.  So, in legacy input scripts, when we
calculate what the signature committed to, the so-called transaction commitment
or sighash (signature hash), we have to repeat the calculation for every
signature check in that input.  And it will calculate data based on all of the
other inputs, all of the outputs, and generally the whole structure of the
transaction.  And what this fix does, if I connect this right to what we've
talked about previously, is if there's multiple signature checks in a single
input script, it will cache a big portion of the sighash calculation for the
same sighash flag.  And, yeah, so this would mitigate these attack transactions.
Yeah, I just pulled it up; #32473 is exactly that.

**Mike Schmidt**: That's the midstate one, right?

**Mark Erhardt**: Yeah, I think we must have talked about that a few months ago.

**Mike Schmidt**: I think we did, yeah.  Well, we can wrap up this news item by
thanking the responsible disclosure from the individuals here.  That would be
Niklas, Niklas, Pieter Wuille, and Antoine Poinsot.

**Mark Erhardt**: And Eugene for rediscovering them.

**Mike Schmidt**: And Eugene.  Go Brink-ies!

**Mark Erhardt**: Stop being so biased!

_Why was -datacarriersize redefined in 2022, and why was the 2023 proposal to expand it not merged?_

**Mike Schmidt**: Selected Q&A from the Bitcoin Stack Exchange, "Why was
-datacarriersize redefined in 2022, and why was the 2023 proposal to expand it
not merged?"  Pieter Wuille walks through how the -datacarriersize relates to
OP_RETURN, and why the different proposals evolved the way they did.  He notes
that -datacarrier wasn't redefined in 2022, saying, "It referred", -datacarrier,
that is, "to a specific type of output (scriptPubKey starting with OP_RETURN and
a single push) when it was introduced".  I believe that this 2022 reference is
part of when, I think it was the end of 2022, when the inscription scheme to
embed data was sort of invented.  Although, I think mostly in 2023 was when
people think of it, but I think it was late 2022.  That's my assumption of
what's being referred to here in the 2022.

**Mark Erhardt**: Yeah, there's this outlandish theory that -datacarrier,
because of the name '-datacarrier' and some claims certain developers have made
in the more recent past, refers to all possible ways how data could be inserted
into Bitcoin transactions.  But very specifically, -datacarrier was defined to
refer to a script that starts with OP_RETURN and a single push, that was
introduced in, what was it, 2013, or whatever?  2013, I think, yeah.  And it's
always referred to that.  And very specifically, the config options,
-datacarrier and -datacarriersize only refer to this specific output script that
starts with that prefix.  And then someone made up this outlandish narrative
that obviously, -datacarrier must have referred to all possible ways of
inserting data into transactions forever, revising history.  And now, this is
one of the major talking points in this debate where we continue to have Twitter
against our better judgment.  Did you want to double-click on anything else
here?

**Mike Schmidt**: Yeah, there's a couple more.  Each of these questions kind of
had multiple questions, so I pulled out a couple of pieces to talk about.

**Mark Erhardt**: Sure, go ahead.

**Mike Schmidt**: There were some follow-up questions in that initial question
asking about, why not expand the -datacarrier option, per what Murch mentioned,
to other ways that data could be embedded in Bitcoin?  Pieter notes, "In 2022, I
considered the -datacarriersize a legacy from a different period of time, when
very different concerns plagued Bitcoin development: blocks weren't full, and it
wasn't worth discouraging the development of solutions to take advantage of
unused block space; by 2022, when blocks were regularly full due to organic
growth, this concern simply didn't exist anymore, and the prevention of
unbounded resource growth on node operators had been taken over by the
appropriate technique: consensus rules (specifically, the block size, and later,
block weight limit).  In 2022, I would have been of the opinion to keep the
status quo, as long as the old default policy rule didn't seem harmful.  In
2025, it is apparent to me that it is widely ignored anyway, and thus does more
harm than good, and thus I'm of the opinion that node operators are better off
not enforcing such a rule".

**Mark Erhardt**: Yeah.  So, I wanted to double-click on a little aspect that
came up earlier, which is, why wasn't -datacarrier expanded to refer to other
types of inserting data?  Well, (a) because there's dozens of ways how you can
insert data, infinite, probably.  Like, if you can use OP_IF, you can also use
OP_NOTIF, you can use a PUSHDIRECTLY, a PUSHDROP, you can use ANNEX, you can use
non-standard transactions that use future segwit versions.  Please don't do
this.

**Mike Schmidt**: Fake pubkeys, private keys.

**Mark Erhardt**: Yeah.  So, if you're not even capable of enumerating all the
ways, how would you be able to have a policy rule that refers to all of them?
The whole idea of -datacarrier referring to all possible ways of inserting data
is blatantly absurd.  So, no, -datacarrier refers to one very specific way of
adding data to a transaction.  And one of the first feedbacks the PR to expand
-datacarrier in its meaning got was, "Why don't you create a separate config
option for this other way of inserting data that you want to regulate?" which
then was never followed up on.

_What is the smallest valid transaction that can be included in a block?_

**Mike Schmidt**: This was answered by Vojtěch, who enumerated the absolute
minimum fields and the sizes of those fields for a valid transaction.  He points
out that the smallest possible serializable transaction is 10 bytes, but because
transactions need to have at least one input and one output, that results in
actually a valid 60-byte transaction.  Then he follows up noting, "Such a
transaction needs to be spending a non-segwit output that allows for an empty
scriptSig, for example the bare script OP_TRUE".

**Mark Erhardt**: My memory is a little hazy here.  We're making 64-byte
transactions invalid with consensus cleanup, or we're proposing to, right?  But
there was a question for a while whether we should make only 64-byte
transactions invalid or everything 64 and smaller.  Did we end up just making 64
bytes it, or everything smaller too?

**Mike Schmidt**: It's a good question.  We've had so much chat about it, I
don't know where it's landed, to be honest.

**Mark Erhardt**: So, I believe that the consensus cleanup BIP, BIP54, makes the
proposal to disallow 64-byte transactions in general, because they have the same
length as inner leaves in merkle trees use as their input for the hashes, and
there's some shenanigans you can do exploiting vulnerabilities in the design of
how Bitcoin uses merkle trees, which is consensus so we can't change it
willy-nilly.  But what we can do is we can disallow 64-byte transactions.  And I
think we actually just allow 64-byte transactions, or if consensus cleaner
activates, not other sizes.  So, yes, you could create this transaction that
Vojtěch describes, which would have an empty input script and an empty output
script, refer to a specific UTXO that is being spent, obviously; you always have
to have that in an input.  And then, have an amount field for the output, which
you always have to have, and it's for some reason 8 bytes.  And yeah, so that
gives you a minimal valid transaction of 60 bytes.

_Why does Bitcoin Core continue to give witness data a discount even when it is used for inscriptions?_

**Mike Schmidt**: "Why does Bitcoin Core continue to give witness data a
discount even when it's used for inscriptions?"  Pieter answered this one as
well.  I think the simple answer is Bitcoin Core implements the Bitcoin protocol
consensus rules, but he does jump into a little bit more detail.  He goes on to
say, "In my view, because there's no reason not to.  Inscription data is
certainly dumb, but I don't see it as harmful".  And he also goes on to say, "I
personally think inscriptions are silly, and wish they would go away, but that
isn't a good reason for (attempting to) outlaw it.  Even if it was, it is just a
cat-and-mouse game until other schemes for storage are developed", which is sort
of what we were talking about earlier.

**Mark Erhardt**: Also, just to reiterate, segwit was a block size increase, and
the whole point of the block size increase was to enable having more
transactions in blocks.  So, if we start giving a discount to witness data, that
is a block size decrease, obviously, and that would reduce the throughput.  And
we're very close to using all of the block space, even if we have some blocks
that are non-full recently.  And in the past, we've seen that even if we are
very close to using all of the block space, fees are very low; but the moment we
just go 1% or 2% over the supply of block space in the demand, the feerates tend
to explode to whatever equilibrium it reaches for higher feerates that people
are willing to pay for their transactions.

So, yes, we could remove the witness discount.  This could be implemented as a
soft fork.  You could just count the witness bytes at full weight, which
obviously makes smaller blocks, and smaller blocks are a subset of bigger blocks
and therefore a soft fork.  But, y'all would have to realize that that also
means that the amount of block space that is being produced essentially goes
down, the blocks get smaller, it would make P2TR the cheapest input type, which
I think is hilarious and great, would be great.  But overall, segwit was
specifically designed to make inputs cheaper in comparison to outputs, as in not
that inputs are cheaper than outputs, because they're not, they're still more
expensive than outputs, but to shift the ratio.  Previously in legacy inputs,
for example, P2PKH inputs have 148 bytes, or 147 if you grind the signature, and
the output is 34 bytes.  So, it's between four and five times bigger for the
input; and on P2TR the ratio is 57.5 to 43, which is much closer, right?

So, even though certain people, like Adam Back, keep repeating that inputs are
cheaper than outputs, which is not true, it's simply not true, they are way
cheaper with the native segwit types than with legacy scripts in comparison.
So, the ratio changed and we wanted inputs to be cheaper because we want people
to spend their UTXOs rather than create more of them, when they have the option
and choice between those two things.

**Mike Schmidt**: Murch, you just addressed one of the things that was a
secondary question within the Stack Exchange question that Pieter answered,
around the discount factor and trade-off.  So, I won't get into that one.  I
think you answered that well.  And there was another piece that Pieter answered
in responding to another question, "How do current Core defaults ensure that
block space remains prioritized for monetary transactions rather than subsidized
storage?"  And Pieter responded to that.  I'll take an excerpt of that
responding, "They don't, and never did.  I don't believe node implementations
are, or should be, in a position to judge what transactions are good and bad.
It is, and should be, up to the market".

**Mark Erhardt**: Correct.  That's just not a frigging design goal.  Go on!

**Mike Schmidt**: Yeah.  "Policy rules at best provide inconvenience to
developing solutions that rely on non-standard transactions. They have been used
successfully in the past to this effect, but this breaks down as soon as
sufficient market demand causes development of approaches that bypass the public
P2P transaction relay mechanism".  So, Murch, just to be clear, you don't like
spam, right?

**Mark Erhardt**: I don't like spam.  I think ordinals and runes are dumb.  I am
completely uninterested in them.  You will not find me make protocol changes to
support this use case.  It is just a fact that the possibility of doing data
insertions is a causal effect of allowing to have a flexible scripting system.
By having a programming language with which we can define what spending
conditions apply to UTXOs, we permit data insertions.  And this is a very
deliberate trade-off because we want to have programmable money.  If you don't
want to have programmable money, you can make it much harder to insert data.
But we do want to have programmable money, we do want to have the LN, we do want
to potentially have Ark, we do maybe want to have other cool UTXO sharing
schemes.  Clearly, the current system does not scale to 8 billion people.  And
if we do want to scale up Bitcoin use without only relying on custodial
solutions, we will use the programmable money aspect of Bitcoin to build cool
shit on top of Bitcoin.

If you want to see cool shit to be built on top of Bitcoin in the future, you
don't want to fight all possible ways of data insertion.  If you want to have a
system that does not permit any sort of data insertion -- I mean, even cache
allows data insertion.  You can draw an Abraham Lincoln vampire slayer on a,
what is that, a 10 or a 20?  A 20, I think.  Yeah, anyway, maybe use
Mimblewimble Grin.  Their UTXOs are public keys, I think, on the ECDSA curve.
It's pretty hard to insert data there.  Even so, you can fucking grind them, it
just doesn't make the blockchain bigger.  You can still insert data there.  But
it would have to be a very, very drastically different system than Bitcoin to
get rid of data insertions.  And in my humble opinion, a system that is a lot
less interesting than Bitcoin, but if you subscribe to that being the most
important thing that should happen to Bitcoin, someone proposed a BIP recently
on the mailing list and opened a PR.  I hear that on social media, people call
it BIP444.  I have yet to see the number assignment on the BIPs repository.

But yeah, anyway, if you think this is a good idea to yank out the
programmability of Bitcoin in order to fight spam, and that's your main cause in
life right now, that's the thing you should read and support, and then fork off
and do your Mimblewimble-like sort of coin thing.  I don't think that's very
interesting.  Have fun.

**Mike Schmidt**: Well, we will be covering our Changing Consensus monthly
segment next week, and there's at least two proposals that have gotten some
discussion on the mailing list and elsewhere that do attempt to cut down on
programmability in different ways.  So, we'll talk about those probably next
week.  But yeah, to your point, there's still other ways to embed data, even if
you take out those few ways that are being used now.  I think Stamps are still
possible with fake pubkeys.  Sorry, go ahead.

**Mark Erhardt**: Obviously, you can just insert data into a regular payment
outputs and nothing prevents that.  It's just slightly more expensive.  It's
much more disruptive, too.  And then, even if you found a way to change output
scripts, for example, by a hard fork or by making invalid all existing script
types and requiring that people make signed invoices where they commit to
actually being able to spend output keys, you could still grind those, add data
there.  You could put it into the nSequence field, you could put it in the
locktime field.

**Mike Schmidt**: Put it in the schnorr signatures.

**Mike Schmidt**: I mean, you're just talking about preventing something that is
not preventable.  There's just harm mitigation.  And yeah, sorry, go ahead.

**Mike Schmidt**: I guess what I struggle with is it appears, and I think it is,
there's an infinite number of ways to do this.  So, it's impossible to stop
without a completely separate system.  And even then, there's all kinds of
literature on how you can still somehow sneak things in.  But also, for what?
To me, I don't like spam.  I think it's a nuisance, but it doesn't seem like
it's a risk to Bitcoin.  So, why go through all of this?  It just doesn't make
sense to me that when I see people talk about it online, they talk about block
space, they talk about the UTXO set; but we have a fixed block size or block
weight limit.  I'm sorry, Murch, I know you're here now, I can't just say block
size.  Those things are in place already, and we have a difficulty adjustment
which limits the rate at which those can come out.  And the same things that
would happen with spam to basically the same degree happen with people just
using the chain normally.  Obviously, it's not exactly true.  I think there's
maybe more garbage as a result of inscriptions, for example.

But it's directionally the same, and it's the same problem that folks are
working on when they're working on things like SwiftSync and when they're
working on things like utreexo or cutting down IBD (Initial Block Download)
times, like in Core 30, going down 20%.  Those things are already being worked
on, regardless of if it's spam or not, so I have a hard time wrapping my mind
around it being an existential threat.

**Mark Erhardt**: Yeah, I don't think it's an existential threat.  I think that
currently, monetary bitcoin transactions are the cheapest ever.  I just sent a
few transactions last week and some people wanted to be paid by Lightning and
some people wanted to be paid by onchain, and I literally paid 20 times the fee
on the Lightning transaction than the onchain payment.  So, monetary
transactions are not being priced out right now.  They are as cheap in sats as
they ever have been.  With the recent undermining of the minimum feerate,
they're actually even cheaper.  I used BlueWallet, I just exported the hex and
submitted it directly, and it got confirmed in the next block at 0.3 sats/vB
(satoshis per vByte).  And so, if you want to fight spam, just make bitcoin
transactions and pay for the block space, and then the monkey pictures will have
less block space or have to pay more for it.  And I just don't see it.  This is
so quixotic, it's so absurd.  It was really good not to think about this for ten
days.  It's been great, very relaxing.

_The ever-growing Bitcoin blockchain size?_

**Mike Schmidt**: Well, we mentioned the Bitcoin blockchain size growth, and
that actually is a good lead into the next question from the Stack Exchange,
which is, "The ever-growing blockchain size?"  And Murch, you gave some numbers
around block files and undo files representing about 740 GB.  Oh, this next
one's got an 'i' in it.

**Mark Erhardt**: Gibibytes.

**Mike Schmidt**: Gibibytes.

**Mark Erhardt**: Or 790 GB.  You see, due to the compounding effect of powers
here at GB, these two, GB and GiB already diverge quite a bit.  734 versus 788.

**Mike Schmidt**: The serialized size of the UTXO set is currently about 10.7
GiB, and that the Bitcoin blockchain, from your observation, is currently
growing at approximately 80 GiB per year.  Anything you want to add to that?
That was your answer I hijacked.

**Mark Erhardt**: Right.  So, here's another narrative that I would like to poke
a few holes into.  A lot of people have been going on and on about how the
policy change of OP_RETURN is going to lead to blockchain bloat, and the
blockchain is limited to linear growth.  The maximum that the blockchain can
grow at is 4 MB (not MiB) per block.  And we have about 52,000 to 54,000 blocks
a year, depending on how much the miners add in hashrate.  And each of those
blocks can at most be 4 MB.  So, the blockchain growth is strictly linearly
limited, right?  And if you add OP_RETURNs to transactions, you're buying 4
weight units per byte.  In that case, if you fill a block completely with
OP_RETURN shit, it can at most be 1 MB, not 4 MB.  And in that case, the growth
of the blockchain is significantly lower than the linear limit, right?

So, anyway, the actual growth of the blockchain is about 1.8 MB, or between 1.6
MB and 1.8 MB per block.  So, if someone created a bunch of output data or
OP_RETURN data, blocks would go down in size.  And if people wanted to grow the
blockchain as quickly as possible, they'd have to add a lot of input data
specifically in the witness section, and big witness sections would then be
stored on the blockchain, but they don't contribute to the UTXO set.  And
witness data is discounted, because it is read once when you validate a
transaction.  You download the whole transaction, including the witness data,
and then you check whether the transaction has been authorized correctly, per
the witness data.  And once you've confirmed that, you don't ever look at the
witness data again, unless someone asks for that block and you send it to them.

So, yes, blockchain size is growing.  It's growing linear, it's growing with
every block.  It's linearly limited and hard drives sizes are growing faster
than the blockchain.  It's getting cheaper to store the blockchain.  Even though
the blockchain is growing, the hard drives are growing faster and the price per
GB is dropping.  And so, it's actually getting cheaper to store the whole
blockchain.  And then, maybe while we're talking about pet peeves of mine, and
I'm ranting, sorry, a full node is a node that has processed the entire
blockchain.  Yes, that requires downloading the blockchain and going through all
the transactions and building the UTXO set locally.  But if you're running out
of block space and turning on pruning and throwing away the blockchain after you
have processed it, that's still a fully validating node.  You still have
processed the entire blockchain, you're still capable of creating block
templates, you're still capable of validating transactions locally and enforcing
all rules of Bitcoin.  You don't need to keep the entire blockchain on your node
in order to be a full node, a full node that can do everything on the network
except serving old blocks.

Yes, we need nodes that keep the whole blockchain around, but pruned nodes do
almost everything you need, except if you want to have a txindex.  If you want a
txindex, or if you're running your own mempool.space instance, or whatever, then
you need the whole blockchain, or if you want to help people bootstrap to the
network.  Anyway, pruned nodes are full nodes.

_I read that OP_TEMPLATEHASH is a variant of OP_CTV. How do they differ?_

**Mike Schmidt**: Context shift for this last question.  Last question from the
Stack Exchange, "Is OP_TEMPLATEHASH a variant of OP_CTV?"  And I think we all
know, probably listeners as well, yes, it is.  Some folks saw some room for
improvement with CTV (CHECKTEMPLATEVERIFY) and made suggestions, and I think
those suggestions were originally not taken, and then they just created
OP_TEMPLATEHASH.  And then Rearden, in his answer, sort of categorized things by
capability, efficiency, compatibility, and then which fields are hashed between
CTV and TEMPLATEHASH.  Murch, I don't know if you wanted to jump into that or
you just want to point listeners to that Stack Exchange question to read it
themselves?

**Mark Erhardt**: Yeah, I think there's an excellent answer.  So, if you want to
read it, it goes into all of the details.  But basically, one of the biggest
points that had been brought up in review and feedback to CTV had been that it's
unclear how valuable it would be to add CTV to legacy script.  And so,
TEMPLATEHASH specifically does not get added to legacy script, but only to
tapscript.  So, it can only be used in P2TR outputs, and the designers of
TEMPLATEHASH feel that that is a better design trade-off.  And there's a few
more, even deeper in the technical weeds, other things here.  So, maybe let me
go back a step.

Both CTV and TEMPLATEHASH provide ways how an output can commit to a future
transaction.  And committing to future transactions is super-interesting because
you can, in a single output, commit to entire trees of transactions or future
outcomes.  And once that output is mined into the blockchain, people can rely on
those future transactions being the only way this output can be spent.  And that
is useful for UTXO's, sharing schemes, vaulting, and in this specific case also
for a concept called, LN-Symmetry, as opposed to LN-Penalty, which is the
existing scheme how unilateral closes on LN channels happen.  LN-Symmetry
specifically prescribes a different way of doing LN channels, where the
commitment transactions are symmetric between the channel participants, which,
for example, would make it much easier to have multiple channel participants
instead of just two.  So, this is described in the context of channel factories,
and there's various other UTXO sharing schemes that people have been
hypothesizing about that would be possible with LN-Symmetry, or an opcode that
does similar things as APO (ANYPREVOUT), BIP118.

Anyway, so basically what TEMPLATEHASH is, is an attempt by a different set of
authors to address outstanding feedback and to make slightly different design
trade-offs.  For example, it commits to the annex, which CTV does not.  And
while CTV commits to the input count and output count, OP_TEMPLATEHASH does not.
So, it's very similar, it's trying to achieve similar things.  The design
trade-offs are just because people felt that that was the things that were
outstanding regarding the CTV feedback.  From my read of Rearden's answer here,
he perceives TEMPLATEHASH to basically do all the things that CTV could do,
except the congestion control scheme.  And my understanding of the congestion
control scheme, I don't see the incentive to use that by the people that would
need to adopt it.  So, I'm rather bearish on congestion control.  And therefore,
in my opinion, TEMPLATEHASH appears to be a slightly narrower proposal that
scratches basically all of the edges of CTV.

**Mike Schmidt**: And if you're curious about Rearden's answer and details, jump
into that fifth Stack Exchange question from the newsletter this week.  Murch,
thanks for taking that one.  We can wrap up that segment and move to Releases
and release candidates.  We have two.

_LND 0.20.0-beta.rc1_

We have LND 0.20.0-beta.rc1.  This RC has several fixes in it.  Notably, it
addresses a premature wallet rescan issue, and we're going to talk about that
below in the Notable code changes segment.  Testing is obviously encouraged as
this is an RC.  Please provide your feedback.  There's also a link to the
release notes in the write-up, so you can see all of the details of what was
changed and fixed in this RC.

**Mark Erhardt**: Awesome.  Man, we're at 20 releases of LND!  That is just
wild.  It's like yesterday when it was reckless to use Lightning!

_Eclair 0.13.1_

**Mike Schmidt**: I was going to say reckless as well.  Eclair 0.13.1.  This is
a minor release for Eclair, which includes some database changes in preparation
for removing pre-anchor output channel functionality.  Eclair node operators
must first run 0.13.0 to migrate channel data to the latest internal encoding.
So, if you're running Eclair, I would suggest not just listening to us talk
about it, but for this one, you probably want to jump into the release notes and
make sure you're doing the right things in the right order and understand what's
happening there.

_Bitcoin Core #29640_

Notable code and documentation changes.  Bitcoin Core #29640, which fixes a case
where node restarts could result in different tiebreaking chain tips.  I have
some notes on this one, Murch.  The issue comes from how tiebreaks for
equal-work blocks are handled.  If two blocks have the same amount of work, the
one that is activatable first wins.  That means that the chain of blocks for
which that node has all of its data and all of the ancestor blocks, the variable
that keeps track of that, whether it's activatable or not, is this nSequenceId,
which is not a value that is persisted over restarts of the node, which means
that when a node is restarted, all the blocks are loaded from disk, and that
nSequenceId is 0.  Now, when trying to decide what the best chain is when you're
loading blocks from the disk, the previous tiebreaker rule is no longer decisive
anymore.  So, that means we need to fall back to another tiebreaking rule, which
is whatever block is loaded first, and that was noted as whatever block has a
smaller memory address.  That means that if multiple same-work tip candidates
were available before starting the node, it could be the case that when you
restart, the selected chain tip after restart does not match the one before.

I'm not entirely sure why that's a bug, but I do understand it.  Maybe, Murch,
you have more color or corrections there.

**Mark Erhardt**: I mean, you'd want stable behavior.  So, yes, this is a bug,
but it's also a nothing burger, just to be clear.  It sounds scary.  You'd have
to stop your node while there's two competing chain tips.  Your node has both of
them.  And then you restart it immediately, and it doesn't really matter which
chain tip you're on, unless you happen to be running a really big mining pool or
something.  You'll just mine on one of the two chain tips.  If you do find a
block, you'll break the tie and you'll get money.  Sounds great.  Anyway, if you
don't mine, if you're offline for more than half an hour or so, it's extremely
likely that a new block was found and that breaks the tie, and then you'll just
load the wrong block and then reorg anyway.  Yes, it's a bug.  You'd want to
stay on the chain tip between reloading, shutting down and starting again.  But
this is not an issue, in practice.

_Core Lightning #8400_

**Mike Schmidt**: Core Lightning #8400, which adds a new BIP39 mnemonic backup
for its hsm_secret function.  Default new nodes on Core Lightning (CLN) will
have this BIP39 mnemonic that has an optional passphrase for backups.  And it
also keeps the legacy backup, which was that 32-byte secret for existing nodes.
And that hsmtool is also updated to support both of those backup mechanisms.
And then finally, this PR also introduces a standard taproot derivation for
wallets.

_Eclair #3173_

Eclair #3173 drops legacy channels.  This is what we were talking about earlier.
It removes support for legacy static_remotekey/default channels, and users
should close any remaining channels before upgrading to 0.13/0.13.1, which is
what we noted earlier with the 0.13.1 release.  "Node operators that still have
such channels must not run this version of Eclair, which will otherwise fail to
start".  So, again, if you're doing Eclair things, I'm sure it's fine, but it
sounds like you need to take correct action here and not just blindly upgrade.

**Mark Erhardt**: Yeah, I mean I think there's a very small number of people
that run Eclair, because it's very heavily enterprise-geared towards big
operations, LSPs (Lightning Service Providers).  And I would very heavily hope
that people that run such a big operation read release notes before they
upgrade.  But either way, so that thing we've been talking about for years at
this point, where we will get better channels, is starting to happen.  I believe
that in the context of this, Phoenix, whenever you receive funds to your
channel, or splice-in or out, it will update you automatically to these new
channels too.  They announced something like that recently.  Did we report on
this?  We probably must have.

**Mike Schmidt**: It doesn't come to mind.  Maybe we did, but I forgot.

**Mark Erhardt**: Maybe it's still coming up in the industry updates soon.
Anyway, yeah, we're now moving to that 1p1c (one-parent-one-child) channel
construction that I've probably explained here five times already, if not ten.

_LND #10280_

**Mike Schmidt**: LND #10280, wait for header sync before starting chain
notifier.  This is a fix that prevented premature rescans on wallet creation,
especially with the Neutrino backends, or using compact block filter backends.
So, this defers LND's chain notifier startup until the headers are synced.  So,
for whatever reason, that could have happened.

_BIPs #2006_

Last two PRs to the BIPs repository.  BIPs 2006, which updates BIP3 authoring
guidance.  What are you trying to clarify here, Murch?

**Mark Erhardt**: So, the BIPs repository is for people to propose informational
or specification BIPs.  The idea is whenever a number of different people or
projects need to coordinate on something, or you want to share best practices,
or otherwise want to communicate ideas, concepts, proposals to the technical
Bitcoin community, you should write BIPs.  What you shouldn't do is ask a large
language model (LLM) to predict what a BIP text could be for a variety of
different topics, and then open a PR and waste all of our collective time.
Please stop using LLMs to generate frigging BIPs.  Not interesting, they're
crap, they're not technically sound.  If you're trying to design a complex
cryptographic protocol, a text predictor is not going to help you write a
technically sound proposal.  So, just stop.

Anyway, what we're putting into BIP3 -- which is, by the way, proposed for
activation, and I would love for people to say that they want it to be
activated.  It could be our new BIP process.  It's very similar to the old BIP
process, but has a few new guidances that bring us into the 2020s.  For example,
specifying that if your BIP text appears to not be original work by the author
and very heavily based on LLM-produced text, we will not read it.  We will close
it and tell you to fuck off.  Thank you!

**Mike Schmidt**: We're going to get the 'explicit' rating on the podcast apps.

**Mark Erhardt**: Yes!

**Mike Schmidt**: Anything more on that one?

**Mark Erhardt**: I don't know.  We we've been getting a lot of these LLM BIPs
and frankly, I've spent too many hours on trying to read them and telling people
where actually the technical issues are.  And this is just not a good use of BIP
editor time.  So, if you want to engage with the BIP process, please actually
research the ideas that you want to work on and write a decent BIP on it that
you would not be ashamed to provide to a colleague that has limited time and
wants to know what you're proposing, like the actual specific ideas you're
doing.  That's the point of BIPs, not to create text.  If we were interested in
what an LLM might do, we would put a prompt into an LLM and read it ourselves.

**Mike Schmidt**: Well, I'm glad you guys are pushing back.  It sounds like
usage of these LLMs in the BIPs repo is on the uptake, and obviously that's not
great.  So, I'm glad you guys are pushing back against that.

_BIPs #1975_

We have one more BIPs PR, BIPs #1975, involving Tor and BIP155.  What's going on
there?

**Mark Erhardt**: Yeah, so this is a very small minor update.  BIP155 specifies
addr v2 messages.  It specifies how we communicate where nodes can find other
Bitcoin nodes.  And in the past, there were ways to announce Tor v2 addresses.
Tor v2 addresses are no longer used, so clearly this small aspect of BIP155 is
outdated.  And this change just adds a note that Tor v2 is not used anymore and
clients must not gossip or relay Tor v2 addresses; they must ignore them when
they receive them.  And that's the whole change.  I see that the author of this,
Bruno, that wrote this update to BIP155, added a changelog, which is proposed in
BIP3.  So, if you like that sort of thing in BIPs, where you can very easily get
an overview how the BIP changed over time, you should please endorse BIP3 so we
can activate BIP3 and get a new BIP process.  Thank you very much.

**Mike Schmidt**: That wraps up the newsletter.  Murch, it's great to have you
back.  Thank you everyone for listening.  We'll hear you next week.

{% include references.md %}
