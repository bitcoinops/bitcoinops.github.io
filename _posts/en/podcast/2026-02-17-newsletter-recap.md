---
title: 'Bitcoin Optech Newsletter #392 Recap Podcast'
permalink: /en/podcast/2026/02/17/
reference: /en/newsletters/2026/02/13/
name: 2026-02-17-recap
slug: 2026-02-17-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Gustavo Flores Echaiz are joined by Sebastian
Falbesoner and Oleksandr Kurbatov to discuss [Newsletter
#392]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-1-24/418739898-44100-2-2a6577e48d595.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mark Erhardt**:  Good morning, this is Bitcoin Optech Newsletter #392.  Today,
we're going to talk about a proposal to limit the silent payments recipients,
and we're talking about BLISK, a boolean circuit logic integrated into a single
key.  And we have a few Release candidates and a bunch of Notable code and
documentation changes for you, especially LN stuff this week.  So, let's get
right into it.  We are joined by two guests, Sebastian and Oleks.  Would you
like to introduce yourselves?

**Sebastian Falbesoner**: Yeah, I'm Sebastian.  I'm a many years' Bitcoin Core
contributor and also a little more into libsecp lately.  And I'm funded by
Brink.

**Oleksandr Kurbatov**: Yeah, my name is Oleks.  I have recently joined
Blockstream as a cryptography researcher.  In the past, I also made a lot of
tricks with Bitcoin and zero-knowledge proofs (ZKPs), but yeah.

**Mark Erhardt**: Thank you.  Thank you for joining us.  Also with us is Gustavo
today again.

**Gustavo Flores Echaiz**: Hi, Murch.  Hi, everyone.  Thank you for having me.

_Proposal to limit the number of per-group silent payment recipients_

**Mark Erhardt**: Wonderful.  So, let me get to the first News item.  We've seen
a discussion, I think we reported on it a few times already, and the context is
for silent payments, when you have multiple recipient outputs that are all going
to the same silent payments recipient, it could become quite expensive for that
recipient to scan the silent payments outputs.  And there is now a proposal to
limit the number of outputs that can go to a single recipient to 1,000.
Sebastian, you've been looking at this for some time.  Can you provide a little
more context on what exactly the issue is here and maybe why it only affects a
single recipient?  You do have to scan all P2TR outputs anyway, right?

**Sebastian Falbesoner**: Yeah, so for the historical background, in libsecp,
the cryptographical library used in Bitcoin Core and the wider Bitcoin
ecosystem, we have been working on implementing a silent payments module for
quite a while now.  I think it is at least two years.  Yeah, I know, getting
late!  At least two years, we have reached take four or five already; well, take
five having been closed recently.

**Mark Erhardt**: Let me jump in there right now.  So, we've been promised
silent payments.  How come this is taking so long?  What's the problem?  Who do
we have to lean on to?

**Sebastian Falbesoner**: Two weeks, TM!  Yeah, so I think we're quite far
already, but within the last months, one reviewer found a potential issue on the
recipient side, on the scanning side.  So, the issue is, it could perform quite
bad in the worst case, the worst case being that a sender crafts a transaction
that fills out a whole block, like maxing out the consensus limit of 1
mega-vbytes.  So, this will be a transaction that is non-standard, because the
non-standard limit is 100 kvB (kilo-vbytes).  And if a sender crafts a
transaction where all the recipients are going to one entity, one group -- so to
give a little context in silent payments, a recipient address not only consists
of one public key, but two.  So, there is a scan public key and the spend public
key, and a group is defined as all recipients that share the same scan public
key.  The spend public key can be different due to a mechanism called labeling,
like you can tweak spend pubkeys.  So, it's a little cheaper to scan, so it's
meant as a mechanism to differentiate the incoming payments.  So, it shouldn't
be confused with accounts, because there are privacy drawbacks.

But yeah, to come back to the topic, so we found that if such an adversarial
transaction is created with a little more than 23,000 outputs, or it's a little
more, I don't know the exact number now in my head, but so you just divide the
maximum block space by the space it will take for one taproot output, because
silent payments only creates taproot outputs.

**Mark Erhardt**: Yeah, I think 23,000-something is right.

**Sebastian Falbesoner**: Yeah, something a little more than that, assuming that
one taproot output takes 43 vbytes, I think.  And yeah, so the scanning we do
currently in the module is we go through all the transaction outputs and see if
there is a match.  And doing that is not just comparing a fixed output, there is
some elliptic curve calculation included to detect labels.  So, we just have
first an unlabeled output candidate and we subtract that from each candidate in
the output, and then we look if the result is in one of our labels in our label
cache.  So, for each output, there is some quite expensive elliptic curve
operation to be done for each output.  And yeah, if we assume now we have a
match, we have to do the same thing again because we derive a different tweak.

**Mark Erhardt**: Right, let me jump in briefly and give a little more context.
So, in silent payments, the nifty thing is we get reusable addresses, because we
can send to the payment instructions multiple times without it looking like the
same output script onchain.  And the way it works is that it takes all of the
public key information and creates an Elliptic Curve Diffie-Hellman with a key
exchange with the recipient public key; we'll talk more about ECDH in just a
little while.  And so, the recipient basically just checks, "If I try to do a
key exchange with my public key and the information from the inputs, does any of
these outputs look like it's paying me with that construction", right?  So, this
is unique because the inputs are always required to be unique, you can never
spend the same UTXO twice.  So, if a UTXO is spent, the output will be unique.
But if you paid the same recipient multiple times, it would generate the same
output script.  So, the way we get around this is we increment a counter for
every time someone is paid.  We tweak it with a +1 basically, and that way we
get a new output script every single time.  And for everyone else, it looks
indistinguishable from any other P2TR output.

So, the way I understand you here is, we have to scan them in order.  Now, I'm
curious, wouldn't it work that we require payments to the same recipient to be
in order?  Like, sure, if you're paying five people, it could be Alice, Bob,
Carol, then me, and then me again.  But couldn't we just require that outputs
are ordered in the order that they are going?

**Sebastian Falbesoner**: Yeah, that was another suggestion in the more recent
discussion.  But that would be a far more invasive change because the BIP is
already out for some time and the BIP says the order doesn't matter.

**Mark Erhardt**: Unfortunately, you always learn more the longer you're
pursuing an idea!

**Sebastian Falbesoner**: Yes.  If we do that, we called it the ordered K idea
and the limited K idea, so we even had these fancy names already.  But the
ordered K would be very invasive.  I think there were some privacy issues
raised, I'm not sure if they are based on a good foundation, but I think my
prime argument would be it's too late for that.

**Mark Erhardt**: Well, because silent payments hasn't been adopted that broadly
yet.  There's probably like three wallets that use it so far.

**Sebastian Falbesoner**: Maybe it's still possible, yeah.  I think one argument
was also that it's more secure on the sender side of the libsecp API if we do a
limited K because we can error out if it's not respected.  Whereas in the
ordered K, we can create some result, but we would still have to give
guarantees, "Oh, please never modify the order of this".  So, it's much more in
the hands of the upper layer to follow whatever we write in the docs.

**Mark Erhardt**: Right.  For example, Bitcoin Core will shuffle the outputs on
a transaction.

**Sebastian Falbesoner**: Yeah, for example, yeah.  So, things like those you
cannot do anymore.  Also, I don't know if you think about batch transactions on
exchanges.  I don't know if they shuffle outputs or not, but one would have to
be really careful to then keep the order, as otherwise payments cannot be found.

**Mark Erhardt**: Right.  Or, or if someone does a coinjoin and multiple people
happen to pay -- well, never mind, they'd have to coordinate them anyway to
tweak the number.

**Sebastian Falbesoner**: Yeah.  I'm not familiar with those details of
coinjoins, if there is some ordering, sorting or randomizing included or not,
but yeah.

**Mark Erhardt**: Right.  So, basically the concern is the recipient would have
to scan all outputs.  And then, let's say on the last one, the recipient finds a
payment to themselves.  And then they're like, "Well, there could be a second
payment", and now they have to scan all of them again.  So, with 23,000
payments, if they were ordered exactly reverse and it scanned in the correct
order, then it would always be super-slow.

**Sebastian Falbesoner**: Yes, to give some concrete numbers here, I think it
was in the range of about 10 minutes, 9 to 10 minutes on a more modern machine.
And one first optimization you can do is just randomize the outputs, because
then finding one K is already cut in half.  So, I think it's close to
n<sup>2</sup>-half in the worst case, like you don't always go to the end, but
always closer to the end.

**Mark Erhardt**: So, of course if he's nice to you and actually orders them in
the right way, then it also takes much longer.

**Sebastian Falbesoner**: Yes.  So, with that, we could go down from roughly 10
to 5 minutes, but that's still kind of not ideal.  So, I think it's hard to
reason what is the right number, but I don't think we want to be on the same
order of magnitude of the block time, if that makes sense, right?  I mean, it's
still an unanswered question, "What is a good range to be in?"

**Mark Erhardt**: So, what would be the constraint here?  So, the recipient gets
paid by you 23,000 times, and on the machine where they scan for silent
payments, they'll now be slow.  So, if this is an exchange, hopefully they have
a separate machine to scan for silent payments, and some of the silent payment
recipients might be informed a few minutes later.  If it's a home user, congrats
on getting paid 23,000 times.

**Sebastian Falbesoner**: I mean, one detail to that, it doesn't necessarily
mean that the funds go to the recipient.  You could have 20,000 outputs with
zero sets, right, because there is no reason to respect the dust limit.  It's a
non-standard transaction anyway already.  And it could be that only in the last
find, there is some bigger amount that it's worth it scanning.  I guess you
could apply some filter and say if the total amount is below that and then
threshold, then just skip it, it's not worth it.  But it's not necessarily that
a high amount of funds go to the recipient.  The main cost is the fees, or the
bribe for the miner to include the block.  It's a non-standard transaction.

**Mark Erhardt**: It could even be worse, you make 23,000 payments to the
recipient that are all zero sets and then the last payment goes to someone else.

**Sebastian Falbesoner**: Yes, that is also very much possible.

**Mark Erhardt**: Right.  So, why still 1,000?  Isn't it maybe a little
unexpected?  We see very few transactions where there are 1,000 payment outputs
in the first place.  Why would anyone ever need to pay 1,000 people on the same
scan key?

**Sebastian Falbesoner**: Yeah.  One thing that was brought up, if one exchange
sends to another exchange with a large batch transaction, I mean, I guess they
wouldn't want to use non-standard transactions, but that was one thing that was
brought up.  And in general, the 1,000 number is still more of a placeholder.  I
mean, I know in the newsletters it was stated as it was my concrete suggestion,
but I gave the feedback, "Oh, let's keep it as my suggestion.  If we say it's a
concrete one, then maybe it's easier to get feedback".

**Mark Erhardt**: I don't know, it seems still pretty big.

**Sebastian Falbesoner**: Yeah, I think I wouldn't have sleepless nights if we
go to the order of hundreds or something.

**Mark Erhardt**: Yeah, 200 or something would probably be fine.

**Sebastian Falbesoner**: One other suggestion was to just take a tenth of the
maximum.  So, we would still have the worst-case standard transaction size.  So,
that would be 2,350-something.  But yeah, I'm not sure if that's really
necessary.  It's now a trade-off of what worst-case time are we willing to
accept.  So, with 1,000, we are at 30 seconds unoptimized.  With the randomizing
of the outputs, we are on roughly 15 seconds.  And then, there is one other
interesting optimization that helps both for the worst and the average case.
That is a batch inversion.  And then, that brings another 2.5X improvement.

**Mark Erhardt**: Batch inversion being, you find the first output and then you
scan, is it the next one or is it the previous one?

**Sebastian Falbesoner**: It's more like after you do these elliptic curve point
additions, you're in some internal representation, Jacobian coordinates, and you
have to transfer those back to a fine coordinate, like only with XY constants to
serialize them, so that the label cache lookup can be done.  And that needs one
inversion per each transaction output, and you could do those in batches.  So,
you do that within a single K-value that you look to this inversion at several
outputs at once, which is significantly faster.

**Mark Erhardt**: And the inversion is always different for each tweak, right?
You couldn't just scan for the first 10 tweaks on every output right away?

**Sebastian Falbesoner**: Yes.  So, it's the result of a calculation where the
thing you subtract from the text output is different for each K-value.  But for
that reason, yeah, it helps also for the average case.

**Mark Erhardt**: All right.  And this is holding up silent payments now?

**Sebastian Falbesoner**: I think so.  Yeah, I'm pretty positive that this is
one of the last blockers.  Yeah, we did quite spend a long time on alternative
scanning approaches.  So, there is a thing where you do the scanning in the
other direction, where you loop over the labels and look at the result, "Oh, is
any of this result in my transaction outputs?"  And this has the drawback that
it scales not well with the number of labels.  So, for use cases with many
labels, it gets slower and slower with each additional label.  And the
functionality as described in the BIP that we implemented, it's basically
independent of the number of labels because the lookup is done in a hash map.
So, that has a nice 01 lookup cost property.

In retrospect, I regret a little that we spent so much time into looking that we
could have proposed a protocol change earlier, but I don't know, in my head it
was like, "Oh, that's too late already.  That would be silent payments v1
already, like the next version".

**Mark Erhardt**: But seriously, yes, it's implemented now by, I believe,
Sparrow, by CakeWallet, and I think Nunchuck just announced that they
implemented it.  But let's say you start using v2 now and v2 requires that it's
ordered or limited to 200, or whatever you decide in the end.  And for the ones
that ruled it out, sure, maybe I assume the silent payments address would have
to change for the users, but the implementation cost of that I assume would be
pretty low.

**Sebastian Falbesoner**: Yeah.  I mean, the plan now is to not change the
version, because we are reasonably confident, or maybe there will be still some
feedback that indicates otherwise.  But so far, it seems like no one even
creates transactions with more than one recipient.

**Mark Erhardt**: Right.  Wouldn't it also be pretty easy to, if you ever see a
transaction that is this big, you ignore it and just scan it in the background
in chunks or something?

**Sebastian Falbesoner**: You mean like do that on a separate thread?

**Mark Erhardt**: Yeah.  Like, I mean most of the time I think we don't see
transactions with that many payment outputs anyway.  But then, if you do, how,
how urgently do you usually need to know that you got paid?  Can you not just
chunk it in and scan in background?

**Sebastian Falbesoner**: Yeah.  I mean, this would probably introduce a code
path that it's so rarely executed that I don't know, you cannot even test it.
But yeah, so far there was explicit feedback from two developers that said
they're fine with the limit.  They cannot think of any use case.  There was one
slightly related feedback about we need good API documentation, because the
current scanning API is capable of scanning hundreds of thousands of labels
easily.  But if everyone using that API hands out and creates that many labels
already, then that might be not interoperable with every type of wallet.  So,
for example, light clients, they are more restricted in the number of labels
they can use.  So, it's important that we point that out.  Like, if you create a
lot of labels, then don't expect that every wallet that will ever exist will be
able to import and scan for those.

**Mark Erhardt**: When you're talking about API, you're now talking about the
API of libsecp, right?

**Sebastian Falbesoner**: Yeah.

**Mark Erhardt**: Yeah, okay, thank you.  So, users of libsecp would be
predominantly Bitcoin Core, but also other Bitcoin projects that use libsecp or
wrap libsecp for crypto.

**Sebastian Falbesoner**: Yes, exactly.

**Mark Erhardt**: So, the next step would be to decide what the actual limit is
and to improve API documentation to release libsecp and roll out the silent
payments?

**Sebastian Falbesoner**: Yes.  Just yesterday on the PR, it's PR #1765.  I
think on libsecp, I proposed a limit of 1,000.  I proposed API documentation and
there's been positive feedback so far, but maybe I'm sure there will be some
more bike-shedding.  One open question might be, if you find a transaction that
exhausts the K limit, wouldn't users want to look ahead and see, "Oh, it could
be that there is still something hiding in the more than K_max", so would we
want to provide recovery tools for that, or something?  But that would
complicate the API.  But I guess there will be some bike-shedding discussion
about that.

**Mark Erhardt**: I mean, it's a little bit sort of a discussion similar to, you
give an address to someone else and they interpret it to construct a different
output script.  Like you tell someone, "P2TR public key", and they P2PKH
instead.  It's like, "You're not following my instructions on how I want to be
paid.  Did you actually pay me or not?"  Like, if you go and dig a hole in my
backyard because you have my address and bury money there, did you pay me when
you were supposed to drop it into my mailbox?"

**Sebastian Falbesoner**: Yes.

**Mark Erhardt**: I feel like it's good to think about this, but just imposing a
limit and widely communicating that you shouldn't pay more than 1,000 times to
the same recipient seems like doing more than this might be overthinking.

**Sebastian Falbesoner**: Yes, I agree, but I wouldn't be surprised if that
comes up in the discussion.  But other than that, I would hope that we are ready
soon.  That was one of the major blockers over the last few months, I would say.
I mean, the investigating of alternative scanning approaches was interesting.
It led to a lot of benchmarking data.

**Mark Erhardt**: I see you're following the tradition of other Bitcoin
developers that say something is engineered properly when it's over-engineered
140%!

**Sebastian Falbesoner**: Yeah, I guess you could say so, yeah.

**Mark Erhardt**: All right.  Gustavo, Alex, do you want to chime in on this
one?

**Gustavo Flores Echaiz**: No, I think it was quite clear, thank you.

**Mark Erhardt**: All right.  Do you have any call to action or other
information to share, Sebastian?

**Sebastian Falbesoner**: One small thing.  I'm trying to make a signet block
with that exact attack.  I'm just still working on including it.  It's
non-standard, so I have to bribe a signet miner to include it, but once that is
ready, I will post it on the mailing list with all the key material and the
label data needed, so other wallets can see if they are affected by this attack.
Or maybe it reveals other things, right?  If you get paid 20,000 times per
transaction, even if you don't have an issue in scanning, it could be that it
reveals that, I don't know, your GUI is crashing because it's not prepared to
get 20,000 times in a single transaction.  So, once that is ready, I will share
that as well.  And otherwise, if there are no further objections, I think we
will introduce either that limit or a similar one and, yes, hopefully be able
soon to ship the silent payments module in libsecp.

**Mark Erhardt**: Are you worried about popularizing the attack by talking about
it so much?

**Sebastian Falbesoner**: No.

**Mark Erhardt**: Okay.

**Sebastian Falbesoner**: It's an unusual attack.  Also, something to point out,
I don't know if I mentioned that in the mailing list attack, all the others are
not affected.  It's only affects that single targeted entity.

**Mark Erhardt**: Right.  It only affects the recipient that is being paid
actually.  And you still have to buy all that blockspace, right?

**Sebastian Falbesoner**: Yes.

**Mark Erhardt**: I mean, 20,000 outputs at 43 bytes is still, well, the whole
block is 1 million bytes, so it's a hundred thousand sats, even at 0.1 sat/vB
(satoshi per vbyte), which seems unlikely.

**Sebastian Falbesoner**: I would be very surprised if we ever see that attack
on mainnet.  But better to be prepared for it than not.

**Mark Erhardt**: Okay.  Now, stop delaying silent payments!

**Sebastian Falbesoner**: Yes.  Two weeks, TM!

**Mark Erhardt**: Okay.  No, I'm still very excited for that to roll out more
broadly.  I think it's one of the more exciting privacy techniques that has come
up in the last few years.  All right.  Thank you, Sebastian, for joining us.

**Sebastian Falbesoner**: Thanks for having me.

_BLISK, Boolean circuit Logic Integrated into the Single Key_

**Mark Erhardt**: We're going to talk about BLISK next.  You can stick around or
not.  See you!  All right, cool.  As I said already, we'll be talking about,
"Boolean circuit Logic Integrated into the Single Key" with Oleks, and this is
called BLISK.  You posted on Delving Bitcoin about BLISK.  And the idea here is
with MuSig and FROST, you can create threshold signatures and multisignatures in
the sense that you can design a certain number of keys to form a quorum.  So,
you can do with FROST things like 3-of-5; with MuSig, you can only do n-of-n so
2-of-2, 4-of-4, 16-of-16.  And with BLISK, you described that you can construct
a boolean logic where you can use logic AND and logic OR to combine keys into,
well, logic expressions, boolean expressions, I should say.  I read that you use
ECDH to construct the OR gates and you use MuSig2 to construct the AND gates.
And that's about all that I understood from this.  Oh, and onchain, you only see
a single public key.  You only need to accept a single signature, but offchain,
the participants in the output script have to construct that output script in
some manner.  So, I'm curious, how much effort is that whole out-of-band setup
there?

**Oleksandr Kurbatov**: Yeah, basically we started this research more than one
year ago and initially we tried to resolve another problem, totally another.  We
worked on verifiable key agreement mechanism.  For example, if you're operating
in the chat and you have like many, many different participants, to make your
networking efficient, you need to have a kind of broadcast encryption key.  And
if each participant controls their own key, you need to have this verifiable key
establishment mechanism.  And if you want to have a robust environment, where
nobody can break the system on their own, you need to combine all keys together
to receive a single value and use it for broadcast encryption.  And then, we
decided to see on this problem from a different angle.  We came to the idea,
okay, if Alice -- so ECDH, that's literally what an OR gate does.  Because if
you have Alice and Bob and they are combining their secrets and their public
keys to the single value, if we are asking who exactly can access the key: Alice
or Bob, because Alice can derive the same key and Bob can derive the same key.
So, that's literally what an OR gate does.

**Mark Erhardt**: Right.  So, an Elliptic Curve Diffie-Hellman handshake creates
a shared secret, which is produced from the public key of one side and the
private key of the other side.  So, I only got it now when you explained it, but
the OR gate basically is, "I know the public key of Alice.  So, it's either
Alice's public key and my private key, or Alice knows my public key, so Alice's
private key and my public key can also construct a shared secret".  Okay, that's
pretty cool.  Go on.

**Oleksandr Kurbatov**: And that's very important that only Alice or Bob can
derive the same key.  So, Carol cannot do that, Dave cannot, etc.  Then, we have
looked on multisignature n-of-n constructions.  And that's literally what an AND
gate does.  Because if we have Alice and Bob and key aggregation mechanism like
MuSig2 key aggregation mechanism, and if we are asking who exactly can produce
the signature: Alice plus Bob.  So, Alice cannot do that without Bob, Bob cannot
do that without Alice, only them together.  And yeah, logically, we decided to
build a tree or a kind of a circuit where each gate can be represented as an
ECDH or MuSig2 aggregation mechanism.  And basically, it worked.  So, right now
you can define the list of public keys of all participants.  So, Alice, Bob,
Dave, Carol, etc.  Then you can write the logic how exactly you want to see your
policy, so who exactly must co-sign the transaction to have a valid signature.
And then, you need to compile everything.  One missing component is ZKPs,
because when you are constructing ECDH secret, you need to prove that you have
constructed that in the right manner.  Basically, that's it.

**Mark Erhardt**: So, how are they compiled into a single public key then?  Is
it just an addition of the public keys?  I would assume that that can't be it,
because then maybe there would be cancellation attacks or things like that.  So,
at a high level, could you explain how you go from the boolean logic to a single
public key?

**Oleksandr Kurbatov**: Right.  Just imagine the tree and we have public keys of
each participant, except tree leaves.  And then, we need to calculate values in
nodes.  And there is dependency on what kind of node we want to calculate,
because for n nodes, we need to make a key agreement or a key aggregation
mechanism, like MuSig2.  But if you're operating with OR gate, definitely Alice
or Bob, so one of the children, should calculate this secret and appropriate
public key.  And that's why we need ZKPs, because we require only one party to
calculate the common secret.  But no one should be able to forge the tree
itself.

So, yeah, definitely we need to first of all define how exactly we need to
calculate appropriate nodes in the tree.  And one additional note that we need
to represent this circuit in CNF form, this Conjunctive Normalized Form.  It
means we need to have only one AND root gate with a lot of children OR gates.
So, yeah, it's kind of like trusted setup, but this is not a trusted setup
because we are using bullet proofs.  For example, you can use any proof
framework which doesn't require you to have this toxic waste and trusted setup,
so it can be completely verifiable, but this is setup.  So, you cannot take only
one coordinator who will calculate an entire circuit.  You need all parties,
like not all parties, but enough forum of them to collaborate, create the final
public key.

**Mark Erhardt**: So, basically, all of the involved participants agree on the
boolean expression that they want to implement, then all of them have to
participate at various steps, either to contribute to the OR constructions or
the AND constructions.  And then, you use ZKPs to prove that every party
participated correctly for the parts that others cannot look into.  When we talk
about trusted setup, for example, in the context of Zcash, there is a group, an
in-crowd that creates the circuit that is used by everyone later.  But in this
case, the people that rely on this expression are also participating.  So, in a
sense, it's like a trusted setup, but only for the people that are in the
trusted crowd, right?

**Oleksandr Kurbatov**: Yeah, definitely.  Everybody should agree on the same
policy.  It's how organizations operate.  Because we have, I don't know, CEO
signature is required plus, I don't know, CFO plus CMO, etc.  So, all parties
are already agreed with the defined policy, and this is totally fine.  It's how,
for example, we just created the multisignature.  We agreed that we're going to
use this public key, that's the kind of agreement, and we have the same type of
agreement in the BLISK.  So, all parties need to make a short interactive round
to compute the final public key.  And then, what is very interesting is that you
can then update the key without interactions with other parties.  If, for
example, only my key should be changed because, I don't know, the previous was
compromised or, I don't know, I have lost it, I don't need to re-DKG
(Distributed Key Generation).  So, BLISK doesn't require DKG, I can operate with
existing key.  I don't know, I have used that ten years and I can easily connect
it to the BLISK instance.

**Mark Erhardt**: But that generates a new output script, right?

**Oleksandr Kurbatov**: What do you mean by the output script?

**Mark Erhardt**: So, the output script, the scriptPubKey that people pay to in
the end is a product of all the input public keys and the boolean logic, right?
So, if you change one of the keys, it would be a new output script, right?

**Oleksandr Kurbatov**: Yeah, that's right.  I mean, for example, if you have
already set up this public key to the smart contract, you can easily update
that.  In the case of Bitcoin, you need to have enough quorum to co-sign the new
transaction, to transfer money to the new P2TR address.

**Mark Erhardt**: Sure, but you need to tell everyone else that you update your
key, because they wouldn't be tracking it anymore.  So, the non-interactive part
is you can unilaterally propose it, but everybody else is involved again in
this.

**Oleksandr Kurbatov**: Yeah, I mean for example, in Frost, if you're updating
your own key, you cannot do that without involvement of all parties, because
everybody participates in your DKG procedure.  In this case, all other keys can
remain the same, but only my part will be updated.  So, I don't need them to
store new secrets, new key shares, such like, so we don't need that.

**Mark Erhardt**: Right, but they do need to sort of be aware of the new tree
construction and what outputs to scan.  Yeah, cool.  So, the big advantage here
is, of course, that you can have more complex restrictions or constructions than
just with two out of these three or all of these.  Where do you anticipate this
BLISK will be used?  Because it sounds to me like the setup for these output
scripts is pretty heavy with ZKPs and first coming to agreement what the policy
should be.  Sounds like maybe manual even.

**Oleksandr Kurbatov**: I have attached benchmarks in the paper and definitely,
yeah, you're totally right.  Everything depends on the policy you want to have.
If this policy is complex, I don't know, it requires, I don't know, a large pool
and circuit, definitely the setup takes more time.  The signature process will
be like very easy, so it's just an instance of MuSig2 solution.  But the setup
will be harder and harder depending on the complexity of the circuit.  But for
example, for real life examples, if you want to emulate threshold 2-of-3 with
this construction, or Alice plus Bob or Carol, setup takes milliseconds.  And
so, yeah, it can be done by, I don't know, any device.  So, the proving system
is not quite difficult.  So, you're not proving, I don't know, the KVM execution
trace.  You're proving only the simple operations: ECDH and that's it.  You can
prove that efficiently.

**Mark Erhardt**: Right.  So basically, if a wallet wanted to implement this,
onchain it looks completely the same.  All of the complexity is out of band with
the setup where now they might need to be able to verify a ZKP that proves that
the ECDH was done correctly, which probably wallets wouldn't have yet, but could
perhaps get through some library, like libsecp or similar.  And then, the
signature is basically, you just sign regularly and it gets aggregated according
to the circuit?

**Oleksandr Kurbatov**: The same process as in MuSig2.  It's just a schnorr
signature.  So, verification is the same, so yeah, no difference.

**Mark Erhardt**: So, when you set up a boolean logic policy like that, would
you be able to have key derivation on top of that?  So, you can basically have a
single output script that is the zeroth iteration of it and then you just tweak
it differently, like extended public key sort of stuff?

**Oleksandr Kurbatov**: That's a good question.  You can tweak that, no
problems.  But for example, it has the same problem as silent payments have.
So, for example, you cannot P2TR, where is the multisignature behind.  So, if
this taproot is like aggregated MuSig2, you cannot pay the silent payment to
this address because they cannot derive an appropriate ECDH and receive a new
key.

**Mark Erhardt**: Sure.

**Oleksandr Kurbatov**: The same here.  So, the final public key, you cannot
just create ECDH with this public key and pay, I don't know, silent payments to
this address.  So, the tweaking can be done, but the amount of techniques is
limited so you can do it properly.

**Mark Erhardt**: But it sounds to me like you could at least use it as a
generator for many different output scripts so you don't get massive address
reuse, with just incrementing or labeling.

**Oleksandr Kurbatov**: Yeah.  I need to think.

**Mark Erhardt**: I'm just jumping into new topics here.  Okay, so basically the
idea is maybe this could be used at a enterprise level set up or for smart
contracts, or do you think this would be interesting maybe as a bridge setup
technique, or how do people use this in the future?

**Oleksandr Kurbatov**: Yeah.  For me, like, what's the most important part?
You cannot express real life by the pure threshold signature.  So, if you have a
condition, Alice or Bob and Carol or Dave should sign, you cannot express a
simple policy by threshold signature.  That's not possible at all.  It means if
you need to have something more flexible than pure, you're going to use BLISK.

**Mark Erhardt**: Well, you could do it in a script leaf of course currently,
but that would require leaking a lot more information on what's going on under
the hood, and it would be more expensive onchain.  The big advantage here would
be the complexity moves out of band and you don't reveal what's the business
logic underneath.  But we could do something like this currently with script,
just not as elegantly.

**Oleksandr Kurbatov**: The reason why we like MuSig2 or FROST is because they
are hiding the policy behind.  So, we can verify only the single signature, but
we have no clue how many participants participated to produce the signature.
The same in that, you can hide the policy itself, because the verifier can
verify only the single signature.  You don't reveal anything about your policy
structure, about your organization structure, so this data is hidden.  And
probably, that's just beautiful, yeah.

**Mark Erhardt**: Right.  So, you posted to Delving about this, you mentioned
the paper.  So, is the next step that this is going the academic research route,
or you also have a proof of concept; are you working on a project that is making
use of this, or how does this fit into the bigger picture?

**Oleksandr Kurbatov**: Yeah.  We have already done a compiler so you can define
the set of public keys, you can write the boolean policy and it will compile
with the single public key.  So that's already done.  That's not a
production-ready framework, so it's not recommended to use it in your wallets or
applications because it's not audited, battle-tested, etc.  But we've just shown
that it's possible, and we use it for benchmarking of different constructions.
Recently, just yesterday, I came with the idea that this approach can be
extended with DLC contracts.  So, you can combine some, I don't know, events
from the real world with the policy defined before in BLISK and combine more
interesting, I don't know, cases, etc.  So, probably we will research a bit in
this direction.  Yeah, finally, I have no clue how it will be used, but I see
potential in this approach.  Let's see.

**Mark Erhardt**: Right.  So, basically, you're providing this new primitive,
and now people tend to be pretty creative with this sort of stuff, and you're
just waiting to see what's coming.  Cool.  Do you have a call to action, or are
you asking for feedback, or what would you like to see as the next step?

**Oleksandr Kurbatov**: I don't know.  Everything is open source right now, so
everybody can reuse that.  It was just research we were interested in.  So,
yeah, the public could use it wisely.

**Mark Erhardt**: Oh, maybe one more question.  So, one of the things that
people have been doing is provide security proofs of this.  Is there a security
proof for this construction already?

**Oleksandr Kurbatov**: Yeah, in the paper.  Yeah, one more interesting point,
that we've just shown how you can combine MuSig2 and ECDH, but you are not
limited only with those primitives.  If you have, for example, a post-quantum
multisignature scheme and post-quantum key encapsulation mechanism, you can do
the same.  So, you're not limited only with elliptic curve points.  If you have
those primitives, that's it.  So, you can have a post-quantum BLISK, and it will
work fine.

**Mark Erhardt**: All right.  Well, that's pretty cool research.  Thank you for
sharing.  Gustavo, do you have anything else on this?

**Gustavo Flores Echaiz**: No, this is a very fascinating idea, so thank you for
sharing that.  Well, maybe my only question would be, do you see any limitations
to this protocol that you invented?  How far could someone take it?

**Oleksandr Kurbatov**: Yeah, probably the biggest limitation I see right now is
it's hard to support this technology, for example, by Hardware Security Modules
(HSMs).  Because if you're operating with FROST signature or with MuSig2, each
HSM can produce their own signature and coordinator will aggregate everything.
But if you want to support other cryptographic constructions, like ECDH
derivation, etc, plus some interactive rounds, at least set up, you need to use
the software and hardware which is ready to support it.  Right now, it's not
possible, it's not feasible.  So, it has some drawbacks comparing to existing
multisignatures and threshold signatures, but yeah, for wallets, it doesn't
matter; I mean for mobile wallets, for software wallets.  So, yeah.

**Gustavo Flores Echaiz**: Makes sense.  Thank you so much.

**Mark Erhardt**: All right.  Thank you for joining us and telling us about
BLISK.  We will be moving on to the Releases and release candidates section.
You're welcome to hang on, but if you have other things to do, we totally
understand.  Thank you for your time.

**Oleksandr Kurbatov**: Yeah, thanks for having me.  Take care.

**Mark Erhardt**: All right.  Gustavo, do you want to take it from here?

_Bitcoin Core 29.3_

**Gustavo Flores Echaiz**: Yes, I do.  Thank you, Murch.  So, this week we have
four different releases, the first one being Bitcoin Core 29.3.  So, this is a
maintenance release of a previous major release series.  And here, there's
multiple bug fixes that are included.  The main ones are those that were related
to the wallet migration bug that was discovered in v30 and v30.1.  So, as much
as some bugs only applied to 30 and 30.1, the fixes were backtracked to apply to
29.3 so that we could just adapt to the new mitigations that have been put in
place for this bug.  Also, you can check out the Newsletter #387 for more
context on this issue.  And also, specific on the News section, we covered that
incident, but also we covered the PRs that were used to fix that bug.

Also, another important part of 29.3 are the per-input sighash mid-state cache
that reduces the impact of quadratic sighashing in legacy scripts, and the
removal of peer discouragement for consensus-invalid transactions.  What does
that mean?  So, CVE-2025-46598 was disclosed late last year, where it was
discovered that a CPU DoS (Denial of Service) attack from unconfirmed
transaction processing was possible.  It was judged low severity, but basically
this maintenance release 29.3 also includes the fixes that came for that
specific issue.  So, you can check out the release for more details, but this is
basically just a maintenance release that backtracks a few fixes on 29.

_LDK 0.2.2_

We move forward with LDK 0.2.2.  Here, this is another main release that follows
up two releases from last week's newsletter related to LDK as well.  Here, the
main difference is the update of the feature flag for the splicing feature that
has moved to the production feature bit.  And we will cover this more in the
Notable code and documentation changes, because this is a PR of this week.  But
there's also other issues, such as when a restart happens, there could be an
operation that is left hanging and the channel manager doesn't receive the
asynchronous confirmation that an operation was completed, followed usually
through the follow-up of a block connection.  And so, yeah, just a few fixes
around a few synchronization events.

_HWI 3.2.0_

We follow up with Hardware Wallet Interface (HWI) 3.2.0.  This is a release that
includes support for new hardware wallets, such as Jade Plus, BitBox02 Nova.  It
also adds support for testnet4, native PSBT signing for the Blockstream Jade
hardware wallet.  And finally, MuSig2 PSBT fields are added.  And there's also a
notable code change related to MuSig2 support in an HWI that we will cover more
in detail in a little while.  Yes, please, Murch?

**Mark Erhardt**: Maybe for context, the Bitcoin HWI is a package, a library
that is shipped by Bitcoin Core contributors.  And it's, for example, used by
Bitcoin Core to interface with a number of different hardware wallets.  But I
think it's now also used by other software projects for their interfacing with
hardware wallets.  So, when hardware wallets get added here, that generally
means that these hardware wallets can be used by a number of different software
projects, software wallets now as signing devices.

**Gustavo Flores Echaiz**: That's exactly right.  Thank you, Murch.  So, for
example, Wasabi Wallet is an example of a wallet that will use HWI for
integrating with different hardware wallets.

_Bitcoin Inquisition 29.2_

So, the final release is Bitcoin Inquisition 29.2, which is based on the second
RC of 29.3 Bitcoin Core.  The main difference with the previous version of
Bitcoin Inquisition is that it implements the BIP54 proposal and disables
testnet4.  And also, this newsletter includes a notable change that covers the
implementation of BIP54 in Bitcoin Inquisition 29.2.  Yes, Murch?

**Mark Erhardt**: For context, Bitcoin Inquisition is meant as the tool for
experimenting with proposed soft forks.  So, it has a bunch of experimental soft
fork support, and it runs on the signet, on the main signet that is run by some
Bitcoin Core contributors.  So, disabling testnet4 might sound scary for a
moment until you think about Inquisition is only meant to run with signet.  So,
obviously testnet4 does not support these experimental soft forks and mainnet
certainly doesn't either.  So, Inquisition is not supposed to work with
testnet4.  It was an oversight that it did, and it just basically will say, "No,
this is signet software, don't use me with testnet4", is the background here.

**Gustavo Flores Echaiz**: Thank you, Murch.  Yeah, so mainnet and testnet3 were
already disabled, so this is just testnet4 being disabled in addition to other
networks that were disabled that that are supposed to be disabled.  And also,
BIP54 is the new edition of this release, but Bitcoin Inquisition from previous
releases includes proposals such as BIP118, ANYPREVOUT (APO), BIP119,
CHECKTEMPLATEVERIFY (CTV), and other similar type of covenant or covenant-like
proposals.

_Bitcoin Core #32420_

We move forward with the Notable code and documentation changes.  This week we
have about 12 different PRs to cover.  The first one, Bitcoin Core #32420,
updates the Mining IPC interface, which we have covered many times on the
newsletter, that allows external Stratum v2 client software to connect to
Bitcoin Core to interface with Bitcoin Core for external block template
creation.  So, here, what is done is that Bitcoin Core will stop including a
dummy extraNonce in the coinbase scriptSig when interfacing with external
Stratum v2 clients through the Mining IPC interface.  So, a new option is added
so that any RPC or interface in Bitcoin Core can choose to include this dummy
extraNonce or not.  And the IPC codepath obviously sets that as false to not
include it.

So, basically, what does this all mean?  The scriptSig of the coinbase, it has
basically two rules related to it.  It must be between 2 and 100 bytes.  And
since BIP34, it must also start with a push of the block height.  The dummy
extraNonce is included usually for internal usage, such as the internal miner
unit tests, they will use that dummy extraNonce.  But it was never shipped
outside of Bitcoin Core.  So, for example, when a real miner used
getblocktemplate, getblocktemplate RPC would exclude the coinbase entirely
because the miners would build their own coinbase.  So, this was mostly an
internal tooling for internal mining and related tests.  So, when the Mining IPC
interface was added and implemented, this was basically overlooked and the dummy
extraNonce was shipped to external Stratum v2 clients, and they would then have
to either strip it or simply ignore it.

So, this PR basically adapts to the new reality where there's now a Mining IPC
interface.  So, it stops including a dummy extraNonce, which use case was pretty
much only internal.  And there's also a security reason behind this change.
It's that if an external mining software would strip or ignore the scriptSig
entirely or strip the dummy extraNonce from the scriptSig, if a future soft fork
happened that required additional commitments in the scriptSig, well, the
external mining software that was used to simply ignoring it could just
accidentally break consensus, right?  So, this is also the rationale behind this
change.  Any extra thoughts, Murch?

**Mark Erhardt**: Yeah, I wanted to talk a little bit about the scriptSig field
of the coinbase.  So, coinbase inputs are special in the sense that they do not
commit to a specific UTXO that they're spending.  All inputs on Bitcoin
transactions usually tell us what input they are referring to for the spend.
But coinbase transactions obviously pay out the mining reward, so they do not
spend a UTXO.  They still have a previous, like, an outpoint that they commit
to, but it's a fixed value.  So, they always fill out the previous txid and the
output counter on that with specific values.  And then, the field afterwards,
which you call a scriptSig, which would be the input script for other inputs, is
actually the coinbase field.  And the coinbase field here is special because it
has special requirements.  As you said, it has to be between 2 and 100 bytes.
It has to start since, was it BIP34, with the height?  And, yeah, so the
coinbase field is what would be the input script or scriptSig for other inputs.
And, yeah, coinbase inputs are special.  Coinbase transactions also can only
have a single transaction input, which also is unusual.

**Gustavo Flores Echaiz**: Thank you, Murch.  And just to add on top of that,
well, the extraNonce is what allows a minor to add additional nonce values.

**Mark Erhardt**: Yeah, and to add to that, the extraNonce is not a special
field.  It's basically just using the coinbase field after the height to put
arbitrary other content.  And by changing a single byte in the coinbase
transaction, obviously you change the merkle root and by changing -- wait a
second.  Yes, you change the merkle route.  I was confused for a moment because
the coinbase transaction is obviously ignored for the segwit commitment in the
merkle tree for the segwit transactions.  But in the regular merkle root, the
coinbase contributes of course, so that changes the header of the block that
you're trying to create, and therefore gives you a new sequence of nonces that
you can iterate over or time-roll on or version-roll on, or whatever you want to
do.  So, changing a single byte in the coinbase transaction gives you new block
headers to work with and that's why it's used as an extraNonce.  Once the nonces
are exhausted, you can change the coinbase transaction to start over with the
regular nonces.

**Gustavo Flores Echaiz**: Right, and just to bring back to the PR after that
great explanation, it's that this dummy extraNonce is mostly useful for internal
mining or testing, because miners will simply create their own coinbase
transaction with their desired extraNonce.

_Core Lightning #8772_

So, we move forward with Core Lightning #8772.  This is a fairly simple one.
Here, Core Lightning (CLN) removes full support for the legacy onion payment
format, which had a fixed length.  This was very early days in Lightning.  It
was completely removed from Bitcoin Core, from CLN and the BOLTs specification
in 2022, but it was brought back to CLN in v24.05 after it had found that some
older versions of LND were still producing these legacy onion payment formats.
So, it added a sort of translation layer to translate the legacy format to the
new variable length format.  However, this is no longer the case since LND
v18.3, so support is no longer needed.  Yes, Murch?

**Mark Erhardt**: Just to clarify, you said it removes full support or do you
mean it fully removes support?  Like, it removes all support?

**Gustavo Flores Echaiz**: Yeah, it removes all support.  Thank you for making
me clarify that.  Yes, so it basically removes this translation layer that it
had added after.  It's no longer needed because LND new versions simply don't
produce it anymore.

_LND #10507_

So, this follows up with a PR on LND #10507.  So, here, a new boolean field is
added to the GetInfo RPC response.  So, there was already another boolean field
called synced_to_chain.  So, what are the differences between these two boolean
fields and what is the necessity of the new one?  Basically, the new
wallet_synced field will indicate whether a wallet has finished up catching on
the current chain tip.  So, if you simply want to know if your wallet has caught
up to synchronizing to the blockchain, you can use that field to know just that
precisely.

The other field, synced_to_chain, would consider this, but would only turn true
if not only you had fully synced to the current chain tip, but your channel
graph router, which validates channel announcements, had also completed its job,
and another component called the blockbeat dispatcher, which is a subsystem that
coordinates block-driven events internally with different internal parts of LND,
that would also have to be completed or synced before returning true.  So, this
new field allows you to simply know your status with blockchain synchronization,
and not worry about full synchronization or up-to-date work from other
components.

**Mark Erhardt**: So, basically that would tell you when you're up-to-date with
your own channels and your onchain payments even before you are up-to-date with
the channel graph.

**Gustavo Flores Echaiz**: Exactly.

**Mark Erhardt**: Cool.  All right.

_LDK #4387_

**Gustavo Flores Echaiz**: We move forward.  We now have four different LDK PRs
to cover.  So, the first one, LDK #4387.  Here, like I was mentioning in the
Release section, because this is part of the new LDK release, the splicing
feature flag is changed from the provisional bit 155 to the production bit 63.
So, why did LDK use bit 155?  Because it saw that Eclair also uses it and it
just went along with the same feature flag bit as Eclair to be fully compatible.
However, later, the LDK team realized that Eclair uses a custom Phoenix-specific
splicing implementation that predates the current splicing specification that is
in draft status, right?  So, the Eclair team is not going to update or hasn't
updated their splicing implementation until the splicing specification is merged
and leaves draft status.  Until then, they remain with their custom
implementation.  So, the LDK team didn't know this and they had tried to be with
the same feature flag bit as Eclair, but later realized that when trying to
attempt a splice between LDK and Eclair, this would lead to, first of all,
deserialization failures, and then reconnections that would never lead to a
successful splice.

So, now the LDK team says, "We're just going to point to the production bit,
because we're basically implementing the draft specification that will probably
get merged over the next few weeks".  Yes, Murch?

**Mark Erhardt**: Do you know whether this was in the released version already
of LDK, or is this on the development branch?

**Gustavo Flores Echaiz**: That's a very good question.  And, yes, this was in
the released version.

**Mark Erhardt**: But just a bug fix, not just a fix to the development?  Okay.

**Gustavo Flores Echaiz**: Exactly.  Yes, so this is why the version with this
fix is released, because it was already released.

_LDK #4355_

So, the next one is a new feature added on LDK #4355, which basically adds
support for asynchronous signing of commitment signatures exchanged during
either splicing or dual-funded channel negotiations.  So, the way it works is
that when using an asynchronous signer, when receiving a call to sign the
commitment, it will immediately return; and later, the asynchronous signer will
call back once its signature is ready.  So, this is mostly ready for splicing.
So, for example, HSMs could be now used for signing, splicing, commitment
signatures in LDKs.  For dual-funded channel negotiations, this is simply the
foundation, but some more work is required for adding full support to
asynchronous signers.

_LDK #4354_

The next one is a very simple one as well, LDK #4354.  This one is something
that was missed probably by the LDK team, or was long due.  It's making channels
with anchor outputs the default in LDK.  The way they do this is they've got to
put the config option of negotiating channels by default, which means that
automatic channel acceptance is removed, because all inbound channel requests
before being accepted, the wallet has to ensure it has enough onchain funds to
cover fees in the event of a foreclosure.  So, this simple change on two config
options was necessary to simply make channels with anchor outputs the default in
LDK.

**Mark Erhardt**: So, the difference here is, of course, that with regular
channels, the side that opened the channel is always on the hook for the fee for
closing.  And with anchor channels, the party that closes uses their anchor and
brings the fees in the anchor output.  So, it's a CPFP construction, and that
means you need to have additional funds available in order to be able to close
the channel unilaterally.

_LDK #4303_

**Gustavo Flores Echaiz**: Thank you for that extra context, Murch.  And the
final one of the LDK ones, LDK #4303, this is not a released.  So, this is a bug
fix on a branch that was unreleased.  So, here, two bugs were fixed where an
HTLC (Hash Time Locked Contract) could be double-forwarded after your channel
manager restarts or your LDK node restarts.  So, basically, in one case, you had
received an HTLC and you were going to forward it, but on your outbound channel,
you were waiting for something to clear for that channel to be ready for you to
forward the HTLC.  But somehow, your channel manager or your LDK node restarted.
So, on restart, LDK would miss that the HTLC was in the internal queue, and it
would simply create another HTLC and dispatch both at the same time.

In the other scenario, the HTLC had already been forwarded, settled, and had
been removed from, let's say, the internal logging, but the inbound side still
had a resolution for it.  So, you would restart before it would fully resolve at
that level.  So, on restart, it would dispatch another HTLC.  And this led to
some potential loss of funds.  However, this was never released, it never
shipped.  So, the bug fix came right on time.

**Mark Erhardt**: Yeah, the problem here would be, of course, if you create the
same HTLC twice, you're essentially paying the recipient twice for what they're
forwarding.  So, they make one full HTLC more on the forward, and with the
recreating an already settled output, the other side already has the secret, so
they can simply take the output immediately.  And neither of the two is
intended.

_HWI #784_

**Gustavo Flores Echaiz**: Thank you for that extra explanation.  The follow up
is HWI #784.  This is something we discussed briefly on the release notes.  But
basically, PSBT serialization and their serialization support is added for
MuSig2 fields, including public keys, public nonces, partial signatures.  So,
basically, this is HWI getting prepared for implementing MuSig2 signing on
hardware wallets.  Basically, this is a PR from the HWI repo, #784, where
serialization and deserialization of MuSig2 fields is added, PSBT support for
that is added, which is basically a preparation for signing MuSig2 transactions
by hardware wallets all specified in BIP327.  So, probably a next version of HWI
will move forward with full MuSig2 support.

**Mark Erhardt**: So, the problem here is, of course, when you're creating a
MuSig2, you need additional information in order to know how the signatures are
being aggregated.  And for this construction, you need more information then was
included in the regular PSBT setup.  So, this is basically a necessary step for
hardware signers to be able to sign MuSig2 outputs.

**Gustavo Flores Echaiz**: Precisely.  Give me just a second.  Okay.

**Mark Erhardt**: I can do the BIPs if you want.

**Gustavo Flores Echaiz**: Yeah, definitely.  I think it would be very valuable
if you do the BIPs, please.

_BIPs #2092_

**Mark Erhardt**: All right.  BIPs #2092 is an update to BIP434, which we just
introduced recently, which is the feature message to negotiate between nodes
what features you want to use and maybe what versions of those features you want
to use.  So, when we introduced BIP324, the P2P v2 encrypted P2P messages, there
is a message ID system there.  There's long and short messages, and this just
adds the message ID for the BIP434 feature message.  It also introduces, in
BIP324, an auxiliary file where these message IDs are stored, because it's not
really part of BIP324, so we decided not to put it in there.  But it's something
that other BIPs might want to add to when they designate certain message IDs.
So, it's a separate file in BIP324's auxiliary files.  If you're looking to
reserve any message IDs, check there that you're not double-booking anything.
Did I miss anything?

**Gustavo Flores Echaiz**: No, that's perfect.

_BIPs #2004_

**Mark Erhardt**: Okay.  The BIPs PR #2004 adds Chain Code Delegation as BIP89.
BIP89 is a newly-published BIP that it's basically a way of keeping your
transactions more private from a collaborative custody provider.  So, when you
usually have collaborative custody, where your provider has some of the keys and
you have some of the keys, and they co-sign every transaction for you, they
would know about all of your wallet activity because you share your output
scripts with them, and they can see when you get paid and when you pay, even if
you construct the transaction completely on your end with your set of keys.
With the Chain Code Delegation BIP, the authors, Jurvis and Jesse, introduce a
method where you take all of the responsibility of tracking the funds, and you
can get the co-signing of the custodian only when you want it, and you only
reveal the transactions where they co-sign, and they only learn about the
transactions they participate in.  And they do this by not knowing the chain
code, which is how you derive from the main secret all of the other keys in the
extended public key chain.

So, you, as the customer of the custody service, know the derivation path, and
you basically just tell the custodian, "Here, I want to make this transaction.
Here's my proof that it's me and that it fits the policy per which I'm allowed
to spend this amount", or whatever.  And then, the custodian gets the derivation
path from me to sign.

**Gustavo Flores Echaiz**: Yeah, I just want to add, well, first of all, this is
a fascinating topic, in my opinion, and a great proposal.  But you can check out
Newsletter #364 and listen to the related podcast that came with it for extra
context.  This was heavily discussed there.  But also, there's a blind mode for
that.  I don't know how secure it is.  I think it's not as secure as the
non-blinded signing mode.  But in the blinded signing mode, the delegator or the
signer learns nothing, neither the message, neither the public key.  It's only
provided a blinded challenge and it signs it and that's it.

**Mark Erhardt**: I think that one is more just future work.  So, the actual
proposal does not fully specify the blinded mode, but I think Jesse basically
outlines how it could be implemented if people wanted to work on it.  But people
should correct me underneath this tweet if I'm wrong about that one.

_BIPs #2017_

All right.  Third PR to the BIPs repository.  This is PR #2017 to the BIPs
repository, and this publishes BIP110.  If you've been on Twitter in the last
three months, I think you've seen mention of BIP110.  This is also known as
Reduced Data Temporary Softfork (RDTS), a proposal to introduce seven new
consensus rules to forbid some types of transactions that some people think
shouldn't be happening.  BIP is written up complete enough to be published, and,
yeah, it was published now.  I should say, it is somewhat controversial, because
introducing seven new consensus rules that, for example, forbid the use of OP_IF
and IP_NOTIF in tapscript, limiting the height of tapscript trees, and also
limiting all push opcodes to only 256 bytes may cause people to have their funds
frozen.  The authors of the BIP have addressed that to some degree.  They do not
apply these rules for any UTXOs that exist before activation, but only on new
UTXOs that are created after activation of this PR.

So, the soft fork is supposed to be active for one year once it activates.  It
is also a little controversial per its activation method.  It reduced the
signaling threshold to 55%, and it has mandatory activation in September after
mandatory signaling in August.  So, any nodes that have upgraded to RDTS, to the
activation client for BIP110, will start forcing every block to signal for
activation on this proposal in August.  So, if this is not followed or supported
by a majority of the hashrate at this point, they will fork themselves off and
be on a stale chain tip or slower-moving chain tip that does not follow the rest
of the network for not signaling readiness.  For more on this, just look at
Twitter for three minutes.  There's everybody bashing in each other's head on it
for the past few weeks.  Just to be clear, I did review this, I did publish
this, I still think it's a terrible idea, and I don't think it's a problem for
me saying so.

**Gustavo Flores Echaiz**: No, absolutely not.  I think it's very, very just
rational to say that.  Do you know if this has replay protection?  Let's say in
the case of a fork, do you know how protected a user would be from
double-spending or issues like that?

**Mark Erhardt**: It does not have replay protection.  So, all the transactions
that are accepted by BIP110 will be valid on either chain tip.  And if you spend
a regular transaction, it would flow on both of these.  So, with previous soft
forks, this was a big concern before Bcash split off.  The Bcash developers
finally, in the last hours, literally I think in the last two days or so before
the proposal, finally changed the transaction format to introduce replay
protection when they realized that they didn't have majority support.  And in
this case, so some of the concerns are around reorgs that if this proposal had
any a reasonable amount of support, there probably would be at least a few reorg
blocks.  But then also, if the heights diverge drastically, it might be possible
for Lightning channels to be resolved differently on the two chain tips,
especially if you're running a Lightning node and using a BIP110 node as the
source of truth on this.  This may open you up to some loss-of-funds situations.
And, yeah, so no replay protection.

If you do want to spend your funds separately on these two chains, you can wait
until there's some block rewards that have been distributed in the network.  Any
funds spent from a block that can only exist in one of the two chains will
spawn, like if it's spent, all of the outputs on that transaction can also only
exist on that chain.  And that sort of can infect the whole network.  So, if
there's any outputs that only exist on that chain, anything that is spent in
transactions with those, or spent from outputs that were created from those,
will also only be able to exist on that chain.  And that way, funds can be split
eventually.  The alternative is sending funds to yourself on both chains until
you manage to send them to two different addresses.  So, if you, for example,
have very different feerates on the two networks, you could send it first on the
network with the low feerate.  Then, once it's flowed, you can send another
transaction on the other chain tip with a higher feerate, sending it to a
different address.  And then, you've also split your funds successfully.

Obviously, if a reorg happened on one of those two chains, this could be
resolved in the other direction.  So, you have to be careful that this gets a
few confirmations.  But once you've split your funds, you can use that UTXO that
only exists on one chain to create transactions that are only valid on one
chain.  And that way, you can split all of your funds and then you can dump
whatever side you want, for example, or create Lightning channels that only
exist on one of the two sides.  There's a lot of misinformation around this
being inevitable to succeed just because it is a soft fork.  And I want to be
very clear that soft forks are not inevitable.  A soft fork that is enforced by
a small minority of the network, especially a small minority of the hashrate and
a small number of nodes, and especially a small part of the economic activity of
the network, cannot enforce a soft fork.  It will stall on a shorter chain that
has less PoW.  The rest of the network will simply continue to follow the most
worked chain and pull away.  So, don't believe everything you read on the
internet.

_Bitcoin Inquisition #99_

**Gustavo Flores Echaiz**: Thank you, Murch.  That was very well needed, I
believe.  So, now we just have a final PR to cover on the newsletter.  This is
the Bitcoin Inquisition PR #99.  The implementation of the BIP54 consensus
cleanup soft fork is added on Bitcoin Inquisition and on signet.  So, we
discussed many times this proposal.  It was merged, I believe, only a few weeks
ago, like last month, and also we had the BIP author, Antoine Poinsot, on this
show on the last episode, #391, because he basically talked about addressing
remaining points on BIP54.  So, I don't believe those points have already been
addressed.  I believe this Bitcoin Inquisition merges the BIP as is, but there
could still be some changes to the BIP proposal.  Is that accurate?

**Mark Erhardt**: No, I think the addressing outstanding points was mostly
discussing the concerns that were brought up, and I think neither of the two has
actually changed the proposal.  So, the two points were specifically whether or
not the nLockTime field on coinbase transactions has been described as a
valuable extra nonce space for miners.  And we discussed the validity or the
saliency of that claim and rejected it basically on noticing that it saves you,
like, a couple of hashes on the coinbase itself.  But there is a number of
different things that you can do on the block header itself.  Or, if you're
updating the extra nonce or any other field on the coinbase, it's like 1 more, 2
more hashes on the coinbase transaction to get to this point.  It's probably not
something that people would be getting super-excited about.  It's not used right
now.  And forbidding it is a level playing field.  Right now, it's not being
used.  If we forbid it from being used in the future, it doesn't hurt anyone
specifically.

The other one was whether or not only forbidding 64-byte transactions creates a
consensus scene, where it's weird that 63-byte transactions are allowed and
65-byte transactions are allowed, but 64-byte transactions are not allowed.
This is specifically in reference of the stripped size of transactions, so
transactions without witness data, but I really don't see it being a bigger
concern that smaller transactions might be allowed and only one specific size
not being allowed.  And even so, if we did want to also forbid 63-byte
transactions, and I think the smallest possible thing is 62-byte transactions.
Yeah, 41 bytes for the input, 10 bytes for the header, 1 byte -- sorry, 60 bytes
might be possible, but whatever.  So, I don't share that concern.  And Antoine
looked into these and rejected these, so I don't think the BIP actually changed.

BIP54, the consensus cleanup as is, is now on signet and I'm looking forward to
seeing the PR to Bitcoin Core soon.  I think that'll get a little more review
and hopefully move the proposal forward.  I think in light of other soft forks
currently being proposed, BIP54 uses a very deliberate and different approach.
This has been two years of research.  These are rules that are engineered to
have minimal impact on any users, other than sweeping changes that definitely
will disenfranchise established protocols and wallet constructions.  So, yeah,
my money is on BIP54 activating earlier.

**Gustavo Flores Echaiz**: Makes sense.  Thank you so much, Murch.  Well, that
completes the PR section and the newsletter.  Yes, Murch?

**Mark Erhardt**: For 'activating' meaning adopted by the whole network, not
just being enforced by a handful of nodes on the network.  Yes, this is the PR
section.  Thank you, Gustavo, for preparing that and joining me on this Optech
Newsletter.  Thank you to our guests, Oleksandr and Sebastian, for talking us
through the concern around paying silent payments recipients too often, and
BLISK, the boolean circuit logic integrated into the single key, which seems to
allow some very interesting constructions that also look like a single-sig P2TR
output.  Unfortunately, who knows how long we can use them with quantum coming
any century now.  So, yeah.  Hear you next week, Gustavo?

**Gustavo Flores Echaiz**: Yes, thank you much.

**Mark Erhardt**: All right, that's it.

{% include references.md %} {% include linkers/issues.md v=2 issues="" %}
