---
title: 'Bitcoin Optech Newsletter #301 Recap Podcast'
permalink: /en/podcast/2024/05/09/
reference: /en/newsletters/2024/05/08/
name: 2024-05-09-recap
slug: 2024-05-09-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Ethan Heilman and Gloria Zhao to discuss
[Newsletter #301]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-4-9/4dcc47e1-c499-7bf6-f49f-c83950ce3aaa.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #301 Recap on
Twitter Spaces.  We're going to be talking about lamport signatures on top of
ECDSA signatures today; we have a PR Review Club meeting that covers Bitcoin
Core's transaction orphanage; and we have a regular releases and notable code
sections, including some PRs related to package relay.  I'm Mike Schmidt,
contributor at Optech and Executive Director at Brink, funding open-source
Bitcoin developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs, I've been doing a lot
of BIP reviews.

**Mike Schmidt**: Ethan?

**Ethan Heilman**: Hi, I'm Ethan, I'm a cryptographer that works on a bunch of
different stuff, but sometimes I do some Bitcoin Core development and I love
thinking about protocols and Bitcoin Script.

**Mike Schmidt**: Awesome.  Gloria should join us later and she can introduce
herself then.  We're going to jump into Newsletter 301 and go sequentially here,
starting with the News section.

_Consensus-enforced lamport signatures on top of ECDSA signatures_

We have one news item, titled Consensus-enforced lamport signatures on top of
ECDSA Signatures.  Ethan, you posted to the mailing list, titled Signing a
Bitcoin Transaction with Lamport Signatures, (no changes needed), and it sounds
like there was some discussion of OP_CAT and lamport signatures and that maybe
we don't need OP_CAT for lamport signatures, maybe we could achieve some quantum
resistance, and Andrew Poelstra is talking about BitVM covenants.  Maybe, Ethan,
you can help us out here.  Where should we begin?

**Ethan Heilman**: Sure.  So, this all started when I was writing the OP_CAT
BIP, people were asking me lots of questions about OP_CAT and lamport signatures
and quantum resistance.  And so, I ended up having this conversation at the DCI,
at the MIT Digital Currency Initiative, thinking through some of this stuff.
And during that conversation, I realised that while generally you need OP_CAT to
build lamport signatures in Bitcoin, you can build lamport signatures using
Jeremy's old trick from 2001 to sign 32-bit values, like these math values.  And
so thinking through that, it was like, well, what can you sign?  And there's not
that much that you can make a 32-bit value.  So it's like, well, if you could
sign a signature, then you could sign the transaction hash and make the spending
of a Bitcoin output dependent on a lamport signature that signs the spending
transaction.  But how do you take lamport signatures, which probably I need to
explain, and ECDSA signatures and sign the ECDSA signature with a lamport
signature?

So, the thing that I realized is that the 32-bit value that you can extract from
an ECDSA signature is the size.  So, if you call OP_SIZE on the ECDSA signature,
you'll get its size, and the size varies with what's signed in a random way.
And there's a lot more detail to the way in which it varies, but if you do some
clever tricks, you can kind of make the signature size depend on the hash of the
spending transaction, and then you can sign that size.  So, you can sign the
spending signature is 59 bytes long, or the spending signature is 58 bytes long.
And if you do enough signatures, you can amplify the security offered to
cryptographic levels.

Now, there's a whole bunch of assumptions on this and I want to be very upfront.
No one should use this unless they really understand what they're doing, and
this is very preliminary, but you could use this to basically get lamport
signatures in pre-tapscript outputs, basically using the size of the ECDSA
signature as a proxy for the ECDSA signature, assuming some other things are
also true and fixed about the ECDSA signature.

**Mike Schmidt**: So, the variability in size of the signature is the trick
here, the fact that that occurs naturally, you're taking advantage of that in
this protocol?

**Ethan Heilman**: Exactly, and this is not true with how schnorr signatures are
encoded in Bitcoin.  So, it's like one difficulty for using this trick in
tapscript is, schnorr signatures are either 64 bytes long or 65 bytes long, and
the only difference is whether you include the signature hash (sighash) flag
byte.  And the ECDSA signature in Bitcoin, basically they truncate the zeros.
So, an ECDSA signature in Bitcoin consists of two parts, the R and the S, and if
there's a bunch of zeros out in front of the number, they'll just make it
shorter.  So, if you think about this almost like proof of work and there's some
really early schemes which are super-fun that people did back in the day, of
essentially grinding signatures to get lots of zeros so that their size would be
smaller, and then having a rule that like, "This transaction could only be spent
if the signature is shorter than this", forcing someone to do an enormous amount
of work to spend that signature.

But you have to be very careful because the R value, we know that there's an R
value, which has lots and lots of zeros, that exploits a mathematical property
of ECDSA.  So, if you just assume that the R value has a random number of zeros,
like the S value has a random number of zeros, someone will be able to construct
an R value that's much shorter and use that to break the scheme.  But we use
that property to actually help us.  We assume that it is difficult to find an R
value that is shorter than the R value that exploits that mathematical property.
And so, then we use that to assume that the R value is always fixed to be that R
value, which is not at all secure from an ECDSA point of view, because using the
same R value or nonce leaks out your key.  So, these ECDSA signatures, we're not
using them for the ECDSA signing part, We're using them for showing some
equivalence to what the hash of the spending transaction is.

**Mike Schmidt**: You may have touched on it in your explanation so far, but
maybe make it explicit for me.  Where does the quantum resistance come in here?
Is it just the fact that lamport signatures themselves are quantum resistant?
And so, if we are able to add those in some fashion, that you get the quantum
resistance, or maybe connect the dots for me there?

**Ethan Heilman**: Sure, so lamport signatures are thought to be quantum
resistant, if the hash function is safe against quantum attacks.  And it's
generally assumed that hash functions like SHA256 are.  But one thing that we
should be very careful about is that while these lamport signatures are quantum
resistant, P2SH, which is the pre-tapscript way that we would have to do this,
only has 80 bits of collision security, and against the quantum computer would
only have 80 bits of pre-image security.  So probably, while this is technically
a quantum-resistant scheme due to the number of bits in P2SH, it is probably the
case that you would not actually want to use this to introduce quantum security
into Bitcoin.  You could use lamport signatures to introduce quantum security
into Bitcoin in theory, but because P2SH has a small hash output size, it's
probably vulnerable to Grover's algorithm.

**Mike Schmidt**: You noted in your mailing list post a series of open
questions, and the fifth one here is, "Is there any use for this beyond a fun
party trick?"  So, I saw the mailing list post got quite a bit of feedback and
discussion from a few individuals.  Is there anything here beyond a fun party
trick, you think?

**Ethan Heilman**: So, that's a really good question.  And when I posted it to
the mailing list, I thought hard of, how can I use this?  And I was like, I
can't figure out anything, but maybe someone who's more clever than me or has
some different insight can figure things out.  And so, as far as I'm aware, no
one's managed to use this to build covenants or do anything useful with it.  But
I actually think that this is a neat primitive that you could use in other
schemes.  So, I have some hope that someone will come up with something more
than a neat party trick.  But I'm actually pretty satisfied with it being a neat
party trick.  It's kind of fascinating that you can do this, and it asks a bunch
of really interesting questions about like, we're making all of these
assumptions about ECDSA signatures that are not typically made when thinking
about their security.  So, I think there's some hope that people can figure neat
things out on top of it.

But as far as I'm aware, the problem is that there aren't sufficient opcodes in
pre-tapscript scripts to do BitVM.  And then, when you go into tapscript with
BitVM, because schnorr signatures don't have this size property, they're always
fixed size essentially, where you could do BitVM or you could do some OP_ADD,
zero-knowledge proof, you don't have these signatures.  But maybe there's some
way to connect outputs.  Instagibbs actually just asked a question about, "What
about P2WSH?" and I hadn't thought about that.  I think P2WSH probably has
enough.  That's SHA256, right?  It's 32 bytes.  So, that probably is quantum
secure.  In terms of the quantum security of this signature, that's interesting.
Let me think about that some more.  I would not use this signature for quantum
security because we're still trying to figure out if it's secure in the regular
world, let alone in the quantum world.  But yeah, I'm actually going to pause
for a second.

**Mark Erhardt**: Maybe something different.  We often see reports about this
and that getting better in quantum computers, but there also seems to be a
general concern with the noise of the quantum bits.  Are you plugged in at all
in how far along quantum computers are, and when we would actually want to have
lamport signatures?

**Ethan Heilman**: So, I am not a quantum computer scientist, so I won't answer
that question.  I think that there needs to be more work exploring how Bitcoin
survives in a world with quantum computers, because I think it is very possible
for Bitcoin to do that.  I don't know whether lamport signatures are the right
approach or not.  They are an approach, and they're pretty simple to build, but
there has to be thoughts given to the fact that tapscript has the keyspend path,
and the keyspend path, if you solve the discreet log of it, would always spend
it.  So, even if you had OP_CAT-based lamport signatures in tapscript, you
wouldn't actually be safe, because someone could use the quantum computer to
determine the keyspend path.  So, I think it's a really interesting area of
research to ask, what is the best way to make some of these things quantum
secure?  But I don't have strong opinions on that yet.

**Mark Erhardt**: Thanks.

**Mike Schmidt**: Murch, did you have any other questions?

**Mark Erhardt**: If I'm honest, I still don't quite understand how the short R
comes into play.  I think that was maybe -- or at least it wasn't obvious to me
from the writeup.  I think we use this sort of well-known, very small R value,
and because it's so super-small, we assume that it would be hard to find
something as small.  But that always means that the ECDSA key is leaked because
we reuse the same nonce.  Is that correct?

**Ethan Heilman**: That's correct, and I can provide some intuition about the R
question.  So, imagine that we did not use the short R, and essentially what the
attacker is trying to do, like let's say there's like four ECDSA signatures, one
of them is 59 bytes, one of them is 58, and the other two are 59, the attacker
has to basically be able to generate a signature in that second position that is
58 bytes.  And the length is the addition of the R value and the S value.  So,
the attacker could, if we didn't use the short R value, just grind R values
until they found a signature of that length.  So, by kind of forcing them to fix
the R value, we force them to attack all the signatures.  They can't just make
progress by brute-forcing the first one, which shouldn't actually be that hard,
and then make progress by brute-forcing the second one.  Instead, we require
them to guess all the signatures at once, because we constrain them to use only
that R value.  It's like a trick of fixing that R value using the size.  But if
they had found an R value that's shorter, then they would be able to play all
sorts of games and break the scheme.

If they had a quantum computer, they could actually find the smallest possible R
value.  But that would also allow us to find the smallest possible R value.  And
so, it would be like, the attacker would break existing signatures, and then we
would use the R values that the attacker used to break their signatures to
actually make the scheme more secure.

**Mark Erhardt**: I'm not quite sure I understand why they now have to attack
all signatures.  Wouldn't they just need to guess the S value?

**Ethan Heilman**: So, if they guess the S value -- they should just be able to
guess the S value, they should be able to know what the S value is.  What they
shouldn't be able to do is -- so, yeah, I should be clear.  This scheme leaks
out your ECDSA secret key.  We're not using the secret key for any security
whatsoever.  Basically what we're using is, we're using the S value as a proxy
for the hash of the spending transaction.  And so, if you have multiple
signatures and they are all for the same transaction hash, then to change their
size you need to change the transaction hash, which then changes all your
signatures.  So, you could think about it like picking a lock.  Rather than them
being able to pick the pins one at a time to re-randomize and try to find the
ones of the right length that line up, they have to change the transaction hash
and then that will force them to recalculate all their signatures, which will
have all different sizes.  Did that explain your question?

**Mark Erhardt**: I'm still confused, but let me try maybe to explain it back to
you.  We use the special R value, and the S value is derived from the
transaction hash, or the transaction commitment I should say, at least that's
the term that we are trying to push with Mastering Bitcoin, and the R value; and
since the R value is essentially known, the S is basically also known, but it is
still hard to produce a transaction commitment, because how does it commit to
the lamport signature, or something?

**Ethan Heilman**: So, the attacker should be able to just create these ECDSA
signatures at will.  What the difficulty that the attacker faces is creating an
ECDSA signature of length 58 or of length 59 in a particular position.  So, if
you had like four signatures, they might be able to get a 58-length signature in
the first position, but they wouldn't have it in the second position.  And the
thing that we've signed, basically we sign a statement, we do a lamport
signature of the positions that have the 58-length ECDSA signature.  And so, the
attacker has to create a transaction hash that has the right length in each one
of those positions.  And so, the attacker can create ECDSA signatures at will.
The secret key's leaked out, so they can just sign as much as they want.  But it
should be computationally difficult for them, if you just imagine that they're
getting the lengths and random positions, to line up those random positions with
the positions that we've signed with the lamport signature.

**Mark Erhardt**: I think I need to stare at this a little more.  I did invite
Dave, though, who I just saw come online, so if he has any questions, he might
be more versed in this because he did the writeup.  That's it from me, Mike.

**Mike Schmidt**: Gloria, I see you've joined.  Thanks for joining us.  I'm not
sure if you have taken a look at anything that Ethan has proposed or spoken
about in this Spaces, but you're welcome to comment on it if you have.

**Gloria Zhao**: Very interesting.  I just got back from vacation, so I don't
have any comments right now, but I'm going to give it a read.

**Mike Schmidt**: Excellent.  Well, if Dave jumps on, he can ask some questions.
Ethan, anything that you would say to the audience as we wrap up this news item?

**Ethan Heilman**: I think if this scheme does not make sense to you at first,
it didn't make sense to me at first either.  It's very strange, but it's also
just very fun.  There's something that I find -- there's some stuff that I do
that I'm like, okay, well it's more of a chore.  But this just feels like such a
fun scheme that it might be worth just figuring out how it works, because you'll
kind of laugh at the fact that it works at all.

**Mike Schmidt**: I see Rearden Code in here.  Maybe Rearden Code wants to hack
on this idea.  He's got a lot of those things juggling around in his brain.
Ethan, you're welcome to stay on as we move through the rest of the newsletter.
Otherwise, if you have other things to do, we understand and you're free to
drop.

**Ethan Heilman**: Awesome, thanks so much.  Thanks for having me on.

**Mike Schmidt**: Gloria, do you want to do a quick introduction for folks who
may not be familiar with you?

**Gloria Zhao**: Sure.  I'm Gloria, I work on Bitcoin Core, sponsored by Brink.

**Mike Schmidt**: Thanks for joining us today, Gloria.  We have a PR Review Club
and you are the author and host.  The title of the PR is Index TxOrphanage by
wtxid, allow entries with same txid.  Gloria, you're the author as well as host
of this PR Review Club that we highlighted this month, so thanks for joining us
to explain this PR.  The PR seems to make improvements to Bitcoin Core's
transaction orphanage data structure.  Maybe a place to start for the discussion
would be, what is the transaction orphanage and maybe we can get into the
improvements you are proposing here.

**Gloria Zhao**: Sure, yeah, and I think this might make more sense after we
describe the PR, which is I think two or three items below this one on the
newsletter.  So, I don't know, I don't want to do a last-minute change.

**Mike Schmidt**: No, we can do that.  How about real quick, we have a speaker
request, and then we can maybe jump out of order if it makes sense for
explaining things.  Everything Satoshi, do you have a question or comment?

**Everything Satoshi**: Hi, guys, pleasure to be here.  Actually, I had a quick
question for Gloria before we jump into the PR review.  And the question is, so
recently there's a video of Gloria on the What Bitcoin Did podcast.  I don't
know how recent the video is, but I had a quick question, sort of clarification
from the podcast.  And the question is, you made a very good point for people
who run old nodes, old software, as your reason being security bugs, and
whatnot.  So the question is, for people who do run old versions, just for the
sake of storing the time chain, all the transactions and whatnot from maybe 10,
12 years ago, would you still discourage that as a result of the security bugs,
or would you prefer that they do that at their own risk, I guess?  Then, that's
a quick question and I probably can go now.

**Gloria Zhao**: I think generally from a security perspective, it's not a great
idea to run unmaintained software.  I think that goes for pretty much anyone
using any kind of software.  So, yeah, you use at your own risk.  I wouldn't
recommend it.

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: Yeah, I wanted to chime in on this one as well.  Basically,
the problem with software development is, even if the software was all correct
back when it was created, everything around the software that you're deploying
also shifts, right?  So, you might have updated your operating system since;
some of the libraries that got used in the old version have updated their
versions; you might be using a new compiler meanwhile to compile your C++ code,
and so forth.  So, even if the software would have been perfect and bug free in
the context of when it was published, it might have new interactions with other
libraries and software that you're running, and there might be bugs now in how
it is executed; or there have been bugs in that version and they've been fixed
since.

But we only maintain the latest two versions of Bitcoin Core and the two major
releases, and some security issues or fixes for those are backported to older
versions.  But generally, anything that's significantly outdated may or may not
be buggy by now.  So, if you're running really, really old software, that's the
risk you're running, and nobody's going back and running all these very old
versions with new operating systems in the context of new libraries, or anything
like that.  So, you'd just be sort of a completely uncommon case, and you might
be affected by issues that only affect you in this very uncommon case.

**Mike Schmidt**: Jumping back to the newsletter, Gloria, the PR Review Club
that we have in, I guess, sequential order of the newsletter is actually, I
guess, a potential improvement or a robustness on some of the PRs that we
highlight later in the newsletter, of which you are the author of all of these.

_Bitcoin Core #28970 and #30012_

So, maybe starting with #28970 and #30012, do you want to talk about
one-parent-one-child (1p1c) package relay with some limitations, and then we can
get into the optimizations from the PR Review Club?

**Gloria Zhao**: Yeah, sure.  Thanks for being flexible.  I just felt like it
would make more sense here.  There's almost like a 1p1c relationship between the
PRs.  So, #28970 is, I think, pretty exciting.  I think it's a big win.  It's
the first thing that we can really call, "package relay" that we've merged into
Core from a behavior perspective, I mean.  So, as a user, this is the first time
I have a PR where I can say, "Hey, guys, now if you have a 1 satoshi per vbyte
(sat/vB) transaction and the mempool, or your mempool and everyone else's
mempool, fills up because there's a lot of transactions and they start purging
lower feerate stuff, including your 1 sat/vB transaction, you can now attach one
child to it to CPFP it above that mempool minimum feerate, and it might
propagate.  And I say "might" because there are scenarios in which it's not
going to work, particularly if there are adversaries trying to purposefully get
your transaction to not be accepted, or if things are not working super-well.
It's not 100% reliable and there are quite a few things that we're trying to do
to make it more reliable.

So, I have a node that's running this right now.  It's actually not just default
size, which is 300 MB, it's actually 150 MB, and I get 1 sat/vB transactions
with their CPFPs.  I'd say I see 200 to 300 of these packages per hour.  And I
think last time I checked, I tried to pull up my note but it's taking a bit
longer than I expected, like 70% to 80% of the transactions that that I accept
via package evaluation end up getting confirmed.  And so, even though that's an
argument to say, even though I have a 150-MB mempool and it's not as big as the
giant mempool.space one, I still get quite a bit of use out of that space, and
I'm still seeing a lot of the low-feerate fee bump transactions.  And I'm
accepting them when they come out in a block, I already have them in my mempool,
I get those compact block relay hits.  So, from a node operator perspective,
it's useful.  And of course, for a transactor's perspective, you can fee bump
your 1 sat/vB transactions, so that's very exciting.

The way that it works is, it's opportunistic.  So, there's no P2P protocol
change that's happened, even though we have things that we've proposed and
actually the BIP331 just got merged last week, or two weeks ago, so that's all
still working, but we've kind of optimized for this 1p1c case, and it was fairly
simple to get this code merged.  So, it opportunistically detects when you have
a low feerate parent, so it failed mempool validation because it was below the
mempool minimum feerate, and when it detects a transaction that's missing
inputs, as in you tried to look up the UTXOs in the UTXO set on the mempool and
it wasn't there, and that happens to match with the transaction that was low
feerate.  So, we'll kind of intelligently match these things together and try to
submit them opportunistically, and that is enough for us to get these 1p1c
packages.

_Index TxOrphanage by wtxid, allow entries with same txid_

It makes use of -- so this is where we talk about the PR Review Club PR, if
that's okay if I continue on to that?  Yeah, okay.  So, it uses the orphanage,
and you previously asked, Mike, what an orphanage is.  So, when we receive a
transaction, we might look up its UTXOs and see that they're missing, and this
can happen in just normal operation, even if everybody is doing exactly what
they're supposed to, where let's say there's parent and child transactions, and
you just happen to download the child before the parent, let's say because you
requested them from two different peers and one of them just happens to be
faster than the other.  And so, you receive the child first, and because you
haven't seen the parent yet, it'll be missing a UTXO.  But just from a
bandwidth-saving perspective, since we know that this can happen, it is often,
again, we can be opportunistic and just be like, "All right, I'm going to hold
on to this transaction".  It's missing a parent, so I consider it an orphan
transaction, and I put it in the TxOrphanage.

As soon as that parent comes in, we accept it, and then we can go ahead and look
in our orphanage and we have a child that corresponds to this transaction, and
we'll submit it.  Again, with the 1p1c PR #28970, we additionally will try to
submit them together, not just after the parent has been accepted, also if the
parent has a low feerate.  And yeah, so we have this orphanage.  It, in
practice, is a data structure that kind of looks like a map from txid to a
transaction, along with some information like which peer sent it to us and how
long we've had it effectively, so that we can expire them after some time.  And
we also keep track of what UTXOs each one spends just for quicker lookup, in
case we want to know that information.

But the orphanage is kind of a best-effort data structure.  We've never tried to
make guarantees with, "Yeah, we're definitely going to make sure that if we get
an orphan, we absolutely 100%, as long as it's honest, we'll always keep it.
We've never made guarantees like that.  And that's partially because it's not
really in the critical path, you would say.  So, any transaction in a release
version today, for Bitcoin Core at least, should be -- as long as you download
them in the right order, you should accept them.  But with this opportunistic
package relay stuff, the child needs to be in the orphanage at some point in
order for you to end up accepting these transactions, right, because the
parent's too low feerate.  And the only, say, critical path, the only code path
we can go through in order to accept these transactions is through orphanage.
And so, that kind of places more responsibility on our orphanage data structure
and our orphan handling logic to really treat these transactions with a little
bit more care, to try a bit harder to guarantee that it doesn't have the
problems that it has.

So, anyway, we've been talking for years that the TxOrphanage has these problems
where an adversary can pretty easily attack it, and we've considered this pretty
low priority because, again, you shouldn't really need the orphanage for
"regular transactions".  But now, with this package relay stuff, as well as the
designs that we've made for more generalized package relay, the orphanage
becomes a bit more important.  And so, there's some low-hanging fruit as well as
some slightly more complex orphanage buffs that we want to put in.

Okay, and so this PR Review Club PR is about the fact that we index the
orphanage by txid.  So, of course, if you're familiar with segwit, txid and
wtxid are different.  The txid just commits to the non-witness data, so the
inputs, the outputs, the version, etc.  It doesn't commit to the witness.  So,
you can have different transactions that have the same txid but different
witnesses.  And this is a feature, but you can also imagine it having problems.
So for example, if I see a transaction with the signatures and witnesses, if I
take that signature out or if I replace the signatures with some garbage data,
the transaction has the same txid but a different wtxid.  So, this is where you
can imagine things going wrong, if you're trying to mess with the orphanage.

So, I know you're only going to put one transaction per txid in your orphanage,
right?  And let's say there's a package that I really want to censor because, I
don't know, it's my counterparty's package.  I'm trying to steal money from
them.  And so, when I see this child come through, I'm going to malleate it.
I'm going to take out the signature, put garbage, maybe I'll make it completely,
very different, and I'll send you that transaction.  And what's going to happen
is even if there's an honest party that sends you that child, you are going to
be like, "Okay, this is an orphan.  Am I going to put it in my orphanage?  Oh, I
already have it"; drop it on the ground.  And that's really unfortunate, because
I've just blocked you from downloading and keeping that correct child.

Obviously, there is a way to resolve this.  When you go to actually validate
things, you're going to be like, "Oh, this child's invalid", and you're going to
drop it.  But then you need another peer, another honest peer to send you those
two transactions again.  And typically, nodes are not going to tell everybody
everything twice.  And so, it's not guaranteed that you're going to lose this
transaction, but also it lowers the probability that you're going to end up
accepting it quite badly.  And of course, I can send you yet another malleated
version of that child.  And so, this is an example of a very active adversary
trying pretty hard to censor transactions, but it is something that we want to
avoid.

So, this this PR just first of all replaces the map to be by wtxid instead of by
txid, and allows the orphanage to have multiple transactions that have the same
txid, which obviously only one of them is valid, but because it's kind of this
data structure that you're going to use to house transactions from many peers,
which may or may not be honest, and you have no idea which one is the correct
one, it makes sense for you to keep multiple.  Yes, Murch, you have a question.

**Mark Erhardt**: No, I have a correction.  Wouldn't it be possible to have two
valid children?  For example, with P2TR inputs, you can have either the
scriptpath spend or the keypath spend.  And while unlikely, it could be possible
that someone first use the scriptpath to spend, and then whoever they were
signing with came back online and then they instead created another transaction
with the keypath spend, so they could both be valid.

**Gloria Zhao**: Yes, sure, sorry.  I meant that ultimately, only one of them is
going to end up onchain, but yeah, they could both be consensus-valid
transactions, definitely.  But ultimately, only one of them is going to be
useful to you, if that makes any sense.  But yeah, and you can have replacements
of the same transaction.  Oh, I guess those would have different txids, or they
can.  They could also be one slightly smaller than the other.  But anyway, yes,
you are correct that they can both be valid.  But yeah, I mostly meant that only
one of them is useful.

**Mark Erhardt**: All right, let me maybe just quickly recap.  So, the problem
that we're addressing here is when we first see a transaction, we don't know
necessarily whether it's going to be a valid transaction or what feerate it pays
if we don't know the parent transactions, because we can only calculate the
total fee spent if we know the inputs, and the inputs might not have been
created from our perspective yet because we haven't seen the parent transaction.
So, we don't know the value of the outputs on the parent transaction, therefore
don't know the fees, therefore cannot make any determinations about the
transaction for which we don't know the inputs.  So, we stuff it in our
orphanage and wait to see all the parents, in order to be able to fully validate
the transaction.  And there is, as far as I know, a mostly theoretical attack
vector here, where an active attacker will give us a malleated witness to a
transaction and makes us store that in the orphanage, because we can't validate
the transaction without the parent.  And then if we see the actual valid
transaction later, we would throw it away because it matches on the txid.  You
fix this by indexing on the wtxid instead of the txid.  So far, so good.  So,
yeah.  Oh, sorry, I thought you're continuing from here!

**Gloria Zhao**: Oh, no, I just wanted to say that, yeah, that's correct.

**Mark Erhardt**: All right, cool.  And now to tie this back to the 1p1c, this
is especially useful in the context of having stuff in our orphanage already,
because let's say someone is trying to close a Lightning channel.  The
commitment transaction has a pre-negotiated feerate, which may currently be
below the dynamic minimum mempool feerate, so they can't actually broadcast the
commitment transaction because it's too low feerate, and therefore they cannot
CPFP the commitment transaction because the child transaction would propagate,
but it would propagate without the parent, and without the parent it cannot be
validated, so it ends up in an orphanage.  But now, with your prior change,
#28970, you will look up in the orphanage, "Hey, this parent transaction that
I'm trying to validate that has too low of a feerate, does it happen to have a
child that's currently waiting in the orphanage; and if I package them together,
they pass the dynamic minimum mempool feerate and go in?"  So, that's a broader
context recap, too.

**Mike Schmidt**: Gloria, I have a question.  Before #28970, and we note this in
the writeup in the newsletter, that the peer would notice that the parent's
feerate was too low and refuse to accept it.  So, does that mean now that I'm
going to be still trying to hand low-fee parents out to my peers and if they
don't support #28970, that they're going to penalize me for that because I'm
giving them something below their feefilter settings potentially?  Maybe explain
the interplay between the feefilter settings and a peer saying, "I don't want
anything below this feerate", and me then now handing them parents with low
feerates.

**Gloria Zhao**: Sure.  So, I'll explain the feefilter thing first, and then
I'll talk about what happens before and after #28970.  So, the feefilter message
you will send to your peers, which is kind of an approximation of your minimum
feerate, it's approximated because otherwise it can be a bit of a privacy issue,
and also your own knowledge of your minimum feerate is not exact either.
Anyway, you'll just say, "Hey, don't announce these transactions to me, because
I'm not going to take them anyway", and there's no penalty for announcing or
sending those transactions anyway.  I think it's actually a bit more of a
bandwidth savings on the transaction sender side.  And so, there's absolutely no
penalty or discouragement or anything for "violating" this feefilter, it's more
of just a friendly message.

So actually, before #28970, we would be sending the parent anyway.  So, because
when you receive a transaction where you're missing the inputs, it's an orphan,
right, you're going to request the parents from the peer that sent you that
transaction.  And the feefilter is only used in announcements.  It's not used in
like, "Oh, you asked me for this transaction.  Yeah, I'll send it to you".  We
don't apply the feefilter there.  So, the amount of parent requesting and parent
sending actually doesn't really change with this PR, it's just that before, it
was definitely totally useless where they'd send you the low feerate parent and
you wouldn't accept it, and now you might.  So, yeah, there's the clarification.
Yeah, the feefilter message, we're not penalizing anyone for it, and actually we
were already wasting that bandwidth before.

**Mike Schmidt**: Okay.  That makes a lot of sense and there's some good nuggets
of knowledge in there.  We talked about the PR Review Club, which is #30000,
which adds some robustness to this 1p1c implementation.  And then, we also noted
in the Newsletter that there is a follow-up PR that may potentially add
additional robustness to this protocol, by giving each peer their own portion of
the orphanage.  Is that right, Gloria?

**Gloria Zhao**: Yeah, essentially, like I said before, the orphanage is shared
amongst all our peers, and we don't try to guarantee any peer that they have a
certain amount of locker space in the orphanage.  And so, if one adversary is
just sending orphans over and over and over and over again, we evict them
randomly as well, so we might just end up kicking everybody's useful orphans
out.  Like I said, the orphanage is not really considered a robust data
structure, and we haven't made it a priority to change that, but now we are.

So, yeah, the follow-up PR that you mentioned, #27742, adds kind of a token
bucket mechanism, where I think it was outbound peers only.  So, outbound versus
inbound peers.  Outbounds, we control, whereas inbounds, you can imagine
adversaries, they could take up ten slots of your inbounds.  They could just
make connections to you to try to attack you.  So, outbound peers would receive
a certain amount of "protected orphans",  so each token, let's say, is worth 100
bytes or 1,000 bytes of storage in orphanage.  And so, anytime an outbound peer
sends us an orphan and we're trying to do package relay with them, then we will
see if they have any tokens to spend on protecting those orphans, and so, we'll
protect those orphans from eviction.  So, if our orphanage fills up in space, we
will evict everything else, but not the protected orphans.  And then if this
orphan turns out to be useful, ie we accept it to mempool, then those protection
tokens are replenished.  If the orphan turns out to be invalid, then we take
those tokens away.

So, if a peer is misbehaving, or even if they just have a different policy, for
example, then the amount of protection they receive will decrease over time,
whereas the ones that we do have the same policy with or are sending as valid
orphans, they'll always have a good amount of tokens that they can use.  So,
that's kind of a high-level overview of what that PR does to try to buff up
orphanage.  There's some others as well.  These aren't merged, by the way, so
maybe we should wait until these are merged to talk about on the Recap!

**Mike Schmidt**: Yeah, we could probably get deeper when it actually happens,
but I just wanted to give a little sneak preview for everyone.  Murch, did you
have a question?

**Mark Erhardt**: Yeah, but I guess we're not going deeper at this time!

**Mike Schmidt**: Gloria, we didn't touch on #30012, but it looks like that's
just maybe some follow-ups to #28970 and nothing worth digging in there
specifically.

**Gloria Zhao**: Yeah, it's mostly just follow-ups.  I don't know if there's
anything exciting in here.

**Mike Schmidt**: Great.  Well, Murch or Gloria, anything else interesting from
our combination PR Review Club #28970 and #30012 that we should wrap up before
we move on?

**Mark Erhardt**: I just want to highlight again how cool it is that even
without any P2P message changes, we can now propagate 1p1c.  Sure, only
opportunistically, but as long as nobody is turning our orphanage, we should
probably have a pretty good success rate here.  So, anyway, this is super-cool.

**Gloria Zhao**: I agree.  I just wanted to do my victory lap of getting PR
#30000!

**Mike Schmidt**: Now, you can admit it here, the Optech Recap is a safe, safe
place.  Were you waiting for #30000?

**Gloria Zhao**: I was, and then I gave up.  But then, I went to open the PR and
I happened to get it.  So, yes and no.

**Mike Schmidt**: All right.  Gloria, you're welcome to hang on.  We've got a
couple more Bitcoin Core PRs and a couple of releases, but obviously you have a
lot going on and if you have to drop, we understand.

_Libsecp256k1 v0.5.0_

Jumping back up, Releases and release candidates.  We have two this week.  First
is Libsecp v0.5.0 release.  It includes improvements to key generation and
signing algorithms, increasing the speed of both.  We covered that PR last week
with Libsecp #1058 and noted a 12% speed improvement.  This release also adds a
new function that sorts public keys using lexicographic order.  And also noted
in the release from the authors was that the secp binary is also a lot smaller
now, which the authors expect would be beneficial to embedded users of the
library particularly.  Anything to add on that release, Murch?

**Mark Erhardt**: Yeah, the lexicographic order of pubkeys, I think, is used
both by silent payments and by MuSig, so that's how it got in there.  And, yeah,
that's all I have.

_LND v0.18.0-beta.rc1_

**Mike Schmidt**: Second release is one that's been on for a week or two, which
is this LND v0.18.0-beta.rc1 release candidate.  We have covered a bunch of
these LND-related PRs here over the last few months.  If you just cannot wait,
you can go back and try to figure out which of those are going to be in this
release.  But I think we'll jump more into detail on this release once the
release is final, and I'm outreaching at the moment already to LND folks.
Hopefully, we can get somebody on to walk us through all the highlights, so stay
tuned on that.

_Bitcoin Core #28016_

Notable code and documentation changes, we've touched on a couple already.  I'll
take the opportunity, if you have any questions, feel free to post them in the
Space chat here in the thread or request speaker access.  Skipping down now to
Bitcoin Core #28016, which begins waiting for all seed nodes to be polled before
polling DNS seeds.  Murch, I have some notes here, but I think you've spoken
with the PR author, so maybe I'll let you have a take at it, unless you want me
to go.

**Mark Erhardt**: Yeah, I'll try.  So, this PR addresses an issue where if you
configure your node to use a seed node, which is basically a node designated to
be asked for new addresses of peers first, so far what has been happening is if
you didn't have seeds in your tried table and new table, yet in your AddrMan,
you would eventually ask the DNS seeds, and at the same time then also ask the
seed node.  My understanding is that DNS seeds are super-fast to respond because
that's their entire purpose, and they'll just immediately give you a whole list
of peers.  And the seed node might actually be droned out by the DNS seed
response, and because they happen in parallel, the DNS seeds would usually serve
you new addresses more quickly than the designated seed node that you
configured.

So, what this change does is if you do configure a seed node, you will always
ask this node for new addresses when you start your node, but it will also give
a head start to the seed node before asking DNS seeds if there is nothing in
your AddrMan.  I believe it's a 30-second head start for the seed node.  So, you
will first query the peer that is designated to be queried to ask for new
addresses before you ask seed nodes, with a 30-second head start, and that
should give you a bunch of addresses already before you hear from the DNS seeds,
all those long lists.  Yeah, that's roughly what I understood this PR to do.

**Mike Schmidt**: Question for you, Murch, and/or Gloria, who may know it, what
is a fixed seed, which would be something that triggers after one minute?  So,
we sort of have the seed node with the head start and then the DNS seed and then
fixed seed after a minute.  Anybody know what fixed seeds are?

**Gloria Zhao**: Murch, do you want to take it?

**Mark Erhardt**: No, you go ahead.

**Gloria Zhao**: Oh, it's just the address of someone that we know, like for
example who is probably going to be running a node.  I mean, fixed seeds are
really hard because when we write this, it's going to be hardcoded in the code.
And like Murch mentioned before, this code is going to be supposedly maintained
for about two years after its first release.  So, it's really difficult to know
who's going to be running nodes in two years, which is why fixed seed is kind of
the last resort in terms of who you're going to connect to when you're starting
up.  That's it.

**Mike Schmidt**: Okay, that makes sense.  So, it sounds like we have three
buckets.  I could provide my own seed nodes individually, otherwise DNS seeds
are queried.  If that somehow fails, there's just, I guess, IP addresses or, I
guess, depending on the network, addresses that are known to run Bitcoin nodes
as a very last resort.  Got it.  Cool.  Thanks, Gloria and Murch.

_Bitcoin Core #29623_

Last PR this week is Bitcoin Core #29623, titled Simplify network-adjusted time
warning logic.  In Newsletter #288, we covered PR #28956, which was the PR that
actually removed adjusted time from validation code.  And in News #284, we
covered a PR Review Club about that PR.  And essentially, what that PR #28956
did was, this notion of adjusted time, it's actually called Nuke adjusted time,
that PR, but it made adjustments to a local node's time based on the reported
time of its peers, its network peers.  But this adjusted time historically led
to some problems in the past and was determined not to provide any meaningful
benefits to nodes these days.  So, #28956 removed the notion of adjusted time
based on your peers' time, and replaced that adjusted time with a warning to the
node operator that if the node appeared to be out of sync with the network, they
got some messages informing them of such.  So, that was all #28956.

Great, so what does this #29623 do?  This picks up where #28956 left off, in
terms of #28956 actually made some concessions to make review easier.  And so,
this PR that we're covering this week actually takes into account some of the
refactors that were intended for that original PR to refactor and simplify that
code and separate it out into its own separate PR.  A couple of things I saw in
the calculation logic included changing the warning clock out-of-sync threshold
to 10 minutes; so if you're more than 10 minutes out, you'll get a warning.
This PR adds additional warnings to the user through a variety of means.
There's an RPC warning, I believe, a GUI warning, etc.  Additionally, it removes
the startup argument, titled -maxtimeadjustment, and also changes the offset
calculation to be a rolling calculation based on peers, I think 50 peers,
instead of previously it was the first 199 outbound peers that you connected to
that you used for calculating the offset.

So, this PR this week essentially included a bunch of those maybe refactors or
simplifications that weren't included in the original one for ease of review.
Gloria, I think you were a reviewer on one or more of these mentioned PRs.  Do
you have anything that you'd add or correct based on that?

**Gloria Zhao**: Sure, yeah, it's definitely a simplification and it does some
pretty nice cleaning up.  I'd say the only tragic thing is it removes my
favorite line of Satoshi code, which is the comment saying, "Never go to sea
with two chronometers.  Never go to sea with two; take one or three".  I'm a bit
sad to see that go, but it's a good cleanup, it's a good PR!

**Mike Schmidt**: That's funny.  I have seen that quoted elsewhere.  I didn't
realize that this killed that.  So, RIP Satoshi comment.  Murch, anything that
you'd add?

**Mark Erhardt**: I saw that there's a fuzz test being added, so we'll add some
qa-assets to that and fuzz it hard for a week or so.

**Mike Schmidt**: All right, I don't see any questions or requests for speaker
access, so thanks to Ethan for joining us, thanks to Everything Sats for your
question, and Gloria for your opining on Bitcoin Core PRs in the Review Club.
Always great to hear you explain these things.  And thanks always to my co-host,
Murch.

**Mark Erhardt**: Thanks, it was a great one.

**Mike Schmidt**: See you next week.

**Mark Erhardt**: Yeah, hear you soon.

**Gloria Zhao**: Thank you.

**Mike Schmidt**: Cheers.

{% include references.md %}
