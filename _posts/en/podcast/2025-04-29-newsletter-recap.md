---
title: 'Bitcoin Optech Newsletter #351 Recap Podcast'
permalink: /en/podcast/2025/04/29/
reference: /en/newsletters/2025/04/25/
name: 2025-04-29-recap
slug: 2025-04-29-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Jonas Nick and Salvatore Ingala to discuss [Newsletter
#351]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-3-30/399359950-44100-2-9032d4c3fad37.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #351 Recap.
Today, we're going to be talking about aggregate signatures and the DahLIAS
scheme; we're going to talk about backups for wallet descriptors; we have nine
questions from the Stack Exchange; and we have our usual Releases and Notable
code segments as well.  I'm Mike Schmidt, contributor at Optech and Executive
Director at Brink, funding Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hey, I'm Murch, I work at Localhost on Bitcoin stuff.

**Mike Schmidt**: Jonas?

**Jonas Nick**: Hello everyone, I work on cryptographic research at Blockstream.

**Mike Schmidt**: Salvatore?

**Salvatore Ingala**: Hi everyone, I work at Ledger on Bitcoin stuff.

_Interactive aggregate signatures compatible with secp256k1_

**Mike Schmidt**: Well, thank you both for joining us as special guests to
represent your news items this week.  We're going to jump right into the News
section.  First news item titled, "Interactive aggregate signatures compatible
with secp256k1".  Jonas, you, Tim, and Yannick published a paper titled,
"DahLIAS: Discrete Logarithm-Based Interactive Aggregate Signatures", which is
an aggregate signature scheme with constant-sized signatures.  Now, on this
show, Murch and I have spoken a bit about FROST, which would be k-of-n threshold
signatures and n-of-n MuSig2 multisignatures.  But maybe you can help start the
conversation by distinguishing those from this category of aggregate signatures
that DahLIAS is part of.

**Jonas Nick**: Right.  All right, so DahLIAS is a cryptographic protocol and
more specifically, an interactive aggregate signature scheme.  And to get an
idea for what this is, it may be helpful to look at the syntax of verification
algorithms for various signature schemes.  So, for example, you have what we can
call single-sig; one representative would be a schnorr signature or the ECDSA
scheme, where the verification algorithm takes a single public key, a single
message and a single signature, and then outputs true or false, depending on
whether the signature actually was valid.  In a multisignature or threshold
signature scheme, the verification algorithm takes multiple public keys, a
single message and one signature and outputs true or false.  And in an aggregate
signature scheme, the verification algorithm takes multiple public keys,
multiple message, one per public key and a single signature and outputs true or
false.

So, the difference between a multisignature or threshold signature and an
aggregate signature is that in the aggregate signature scheme, every signer
signs their own message.  And to illustrate this idea, we can build a very
simple aggregate signature scheme from a single signature scheme, like schnorr
for example, and we call this the trivial signature aggregation scheme.  And to
do that, we just define the aggregate signature in this trivial scheme to be the
concatenation of the individual single signatures, the single schnorr
signatures.  And then, our verification algorithm for this trivial aggregate
signature scheme would just iterate through all the individual signatures,
checks that they are valid using the single signature verification scheme, and
if they are all valid, it returns true; and if one of them is invalid, it
returns false.  And so, what we are interested in then is an aggregate signature
scheme that is more efficient than that.

So, in DahLIAS, the signatures, they are constant size, meaning that they are
independent of the number of signers.  And moreover, verification is twice as
fast as the trivial aggregation scheme using batch verification.  And one of the
novel contributions of DahLIAS is that it works on the same curve as ECDSA and
schnorr signatures that we currently use in Bitcoin.  And in that case, the
public keys are also the same as an ECDSA and schnorr, 32 or 33 bytes, and a
DahLIAS signature is always 64 bytes.  Also, DahLIAS signing requires two
communication rounds, similar to MuSig2, and it supports key tweaking, so in
particular taproot commitments and BIP32.

**Mike Schmidt**: That was a great walkthrough, even I understood it.  Maybe you
can help clue us in.  It's interactive, you're aggregating the signatures,
you're signing different messages.  Is this what we've heard maybe discussed
previously, like this is full aggregation; this is not half aggregation, right?

**Jonas Nick**: Yes, so there's an alternative scheme, aggregate signature
scheme, that is known as half aggregation, which is non-interactive, meaning
that there can exist some entity or some algorithm that just takes individual
schnorr signatures and outputs a half-aggregate signature.  The advantage of
that is that it's non-interactive.  You can just do it, just grab the
signatures, collect the signatures, output such a half-aggregate signature.  But
the disadvantage is that those signatures, they are not constant size, they
depend on the number of signers.  And half aggregation, as the name suggests,
means that the signature that is output by this aggregation algorithm is about
half the size as the trivial aggregate signature scheme that we discussed.

**Mike Schmidt**: And maybe you can talk a little bit about the relation of
DahLIAS to cross-input signature aggregation (CISA).  Is this the sort of
breakthrough that folks have been kind of waiting for, or what's the relation
there?

**Jonas Nick**: Right, so the main application we have in mind for this in the
Bitcoin space is CISA, which would mean that a transaction would just have a
single aggregate signature instead of having signatures for every input.  And
the advantage then of course is efficiency, because right now, you need
typically one signature per input which takes space.  So, instead, you could
have one single aggregate signature for the entire transaction and if it's
invalid, the transaction is invalid.  And you could introduce that via a soft
fork, but so far there does not exist a BIP draft that would exactly specify how
that would work, but it certainly seems doable with a soft fork.

**Mark Erhardt**: So, the idea here is that each of the components or
contributors of the signature signs their own input, and it all gets aggregated
together into a single signature, which of course lends itself to the CISA.  I
think one of the issues around CISA was the interaction with key tweaking or
adaptor signatures.  Would it then here be the case that if you use this scheme
to sign, you can't use adaptor signatures at the same time, or at least not more
than one across all the inputs?

**Jonas Nick**: Yeah, so that is a good question.  I don't think there's a
definitive answer to that.  So, half aggregation would break adaptor signatures,
sort of, at least if you would implement half aggregation.  At least if the
adaptor signature would require working on the keyspend path, and if we would
only do half aggregation on the keyspend path, then half aggregation would
prevent adaptor signatures.  And full aggregation like DahLIAS, as far as we
know does not prevent adaptor signatures, but it's probably true that it would
only work for one adaptor signature across those inputs.  That is probably true,
but as I said, I don't think there's a definitive answer to that.  It's a good
question.

**Mark Erhardt**: A second follow-up question, you said that it could be soft
forked in.  Clearly, we can create a new output type that is spendable with the
DahLIAS scheme.  Is there any way to make existing outputs spendable with the
DahLIAS scheme so that it would become cheaper to spend existing UTXOs?

**Jonas Nick**: Also good question.  I haven't thought about this in a while.  I
believe there are some interactions with OP_SUCCESS that make this difficult.
So, I believe the current thinking is that it would require a new segwit
version.

**Mark Erhardt**: That's all my questions for the moment.  Mike, back to you.

**Mike Schmidt**: Jonas, what would the soft fork entail?  I think folks maybe
are used to, "Hey, we got these Schnorr signatures.  Wow!"  There's a lot of
work that you guys did on this, but we got MuSig2 and that is a schnorr
signature, and FROST similarly.  But it sounds like in this scheme, there's
actually a new type of signature involved.  So, we can't just layer in
cryptographic magic on top of what we have in the protocol now, is that right?

**Jonas Nick**: Yeah, that is because aggregate signatures, they just have a
different syntax than single signatures.  And also, the verification algorithm
then looks different to regular schnorr signatures.

**Mike Schmidt**: And I think we mentioned in the newsletter, I don't have it
right up in front of me, but something about the size and shape, or something,
would be similar to Schnorr signatures, but it won't be a Schnorr signature?

**Jonas Nick**: Yes.  So, the shape is similar.  I mean, 64 bytes, same as a
schnorr signature, and it also consists of a group element and a scalar.  So,
very similar to the BIP340 schnorr signatures, and public keys are the same as
we're using in schnorr signatures right now.  And so, this is sort of the novel
contribution, because there have already existed aggregate signature schemes
with constant-size signatures, so very efficient at least space wise.  But they
would require switching to a different curve, which of course it's not
impossible, we can upgrade Bitcoin to do that, but it would be a much more
complex upgrade to Bitcoin, and therefore harder to get consensus on and build
the libraries, and wouldn't work with the existing tooling because you have
these new types of public keys, new libraries, etc.

**Mike Schmidt**: Now, some of the buzz recently has been around
quantum-resistant signature schemes.  Does DahLIAS address that at all, or is
that just a completely separate consideration?

**Jonas Nick**: No, it's not completely separate.  So, because DahLIAS works on
the same curve as schnorr and ECDSA, it also has the same vulnerabilities if
practical quantum computers existed.  So, yes, they are just as vulnerable to
quantum computers as schnorr and ECDSA signatures, because they depend on the
discrete logarithm problem, which as we know, since '94 I believe, is not
actually hard if you have this physical device that's a quantum computer.

**Mike Schmidt**: And in the paper, you guys detail these aggregate signatures
as, this would be a building block for something like CISA, right, that you're
not getting into how would you pass around these messages on the Bitcoin Network
or some other network to actually aggregate these things together; you're just
merely providing the primitive and that would be future research, is that right?

**Jonas Nick**: Right, yes.  So, the paper is entirely focused almost on the
cryptography, and we have a little application section that kind of explains
what this could mean for Bitcoin.  But since it's interactive, we only imagine
this to work on the transaction level and not the block level.  So, if you
collaboratively produce a transaction, there's already some interaction
involved, because you need to parse the transaction around and then sign the
transaction.  So, we imagine some of these DahLIAS protocol messages could be
added to PSBT, similar to how the how MuSig2 protocol messages have been added.
Salvatore or Murch, any other follow-up questions for Jonas?

**Salvatore Ingala**: I have a small question.  So, first of all, thanks for
doing all the hard work on the cryptography.  I'm not a cryptographer myself,
but I implemented at least one of your BIPs, which is BIP327, together with the
other ones that were related to MuSig2.  And in my experience, it was probably
the most enjoyable BIP to implement, because implementing the hardcore
cryptography part ended up being one of the easiest and less time-consuming for
my work at Ledger.  So, thanks for that.

**Jonas Nick**: Thanks, that's great to hear.  Our BIPs tend to be relatively
long.

**Salvatore Ingala**: Yeah, but it's good.  It means I don't have to figure out
too many things by myself, which is helpful.  So, related to that, the question
I have is this, that for MuSig2, you can easily define a new type of descriptor,
which is how you aggregate the keys.  How would that happen in a hypothetical
soft fork to support this signature aggregation?  Because at this point, now the
aggregation is no longer at the key level, but it's at the signatures level.
So, you have an idea how that would look like?

**Jonas Nick**: Well, I guess if you have a descriptor, you somehow need to know
whether you are supposed to produce a regular schnorr signature or a DahLIAS
partial signature that will be aggregated.  I think it's a good question, but I
haven't thought about that at all.

**Mark Erhardt**: Given that the output descriptor describes the output script,
I think if we get a new output version for the DahLIAS outputs, I think that
should be compatible with the output script descriptors.

**Salvatore Ingala**: But yeah, my understanding there is that you would kind of
have to label each key to say that this key is aggregated.  And if they are in
the same transaction, there could be potentially multiple groups of keys that
are aggregated together, in theory.  So, you will have to be able to somehow
identify which keys are aggregated together as well, right?

**Jonas Nick**: So, in DahLIAS keys are not really aggregated.  There's no
notion of key aggregation, really.  So, I don't see exactly where the problem
would be.

**Mark Erhardt**: So, if I may, the output script is a regular script, and then
the aggregation only happens optionally on the side of the inputs.  So, if you
have several inputs, the participants probably can but don't have to aggregate
their signatures for their DahLIAS inputs.  But the output script would just
need to indicate that it's a DahLIAS output script, or that's how I have been
puzzling it together so far.

**Jonas Nick**: Yeah, that sounds reasonable.  Although, I suppose depending on
how the soft fork works, if you still allow a single-signature spending, then
yeah, at the time of output creation, you shouldn't have to decide whether you
want to later spend it with an aggregate signature or just a single signature.

**Salvatore Ingala**: Cool, thanks.

**Mike Schmidt**: Jonas, we can wrap up that news item and we have you on
talking about aggregated signatures, and there actually was a question from the
Stack Exchange on that.  So, I wanted to go a little bit out of order and ask
that question.

_Practicality of half-aggregated schnorr signatures?_

The question is, "Practicality of half-aggregated schnorr signatures?"  And the
person asking this question seems to be wondering if the usefulness of
half-aggregated signatures in practice is negated if all of the independent
signatures are needed anyway, to be sure that all the signatures are correct.
Is that assumption correct?  Maybe you can dig into the prerequisites of that
question.

**Jonas Nick**: Yeah, so this is a rather technical note that we have in the BIP
that the person who had this question read, but as the comments then later
showed, they missed an important word, which was 'valid'.  So, what could happen
in half aggregation is that you receive a bunch of signatures, you aggregate
them, and then you verify this aggregate and it verifies.  So, the verification
algorithm returns true.  But that does not mean that the individual signatures
would verify if you just parse them to schnorr verification.  And this sounds
like a problem, right, because an adversary maybe not having the secret keys
could maybe do that and then produce an aggregate signature, so the entire thing
would be totally broken.  There wouldn't be a point of having an aggregate
signature scheme.

So, the reason why this is not a problem is that an adversary actually cannot do
that without having first seen the valid signatures.  So, what could happen is
that there are some honest, proper signers, they produce valid schnorr
signatures, and then an adversary somehow modifies them such that individually
they don't verify anymore.  They would do that by adding and subtracting some
values of these signatures.  But when you aggregate them and verify them, then
the signature would still verify.  And this is not a problem because the signers
were honest.  They have signed the actual messages and produced those
signatures.  The adversary can only change these individual signatures, but they
cannot come up with such a signature on their own.  There are some applications
where this could be a problem, where when you make this assumption that when you
aggregate and then verify, that the individual signatures would also verify.
So, there are some applications, potentially even applying to a potential
Bitcoin soft fork, where this could be a problem.  So, it's important to
consider, but it does not break the security of this aggregate signature scheme,
at least the normal security.

**Mike Schmidt**: Excellent.  Jonas, thanks for staying on.  I neglected to give
you an opportunity to provide a call to action on DahLIAS.  I assume you're
looking for feedback and review, but maybe you can specify what you're looking
for from the community?

**Jonas Nick**: Right.  If people want to read this, this would be great.  And
if they have feedback and also, if they want to work on an actual BIP that would
implement such a soft fork, I mean as I said, the BIP doesn't exist yet.  So,
there would be some value in actually writing this.  And this holds both for
full aggregation like DahLIAS, but also half aggregation.

**Mike Schmidt**: Well, thanks for jumping on, Jonas.  We understand you're a
busy man and if you need to drop, we understand.

**Jonas Nick**: All right, thank you.  I think I'm staying on.

_Standardized backup for wallet descriptors_

**Mike Schmidt**: Great.  Next news item titled, "Standardized backup for wallet
descriptors".  Salvatore, you posted to Delving Bitcoin a post titled, "A simple
backup scheme for wallet accounts".  In it, you speak about backing up wallet
descriptors, but maybe to tease out some of the motivation and some of the
background that you put into that post, I'll throw out a naïve take.  Salvatore,
I thought we just needed to write down our 12 words or 24 seed words and we're
all good.  Maybe get into why that isn't true, and then the digital versions of
backups that may additionally be required?

**Salvatore Ingala**: Yeah, good point.  Some people think that if they remove
the signature, like 2-of-3, all they need is two keys and they're able to spend
the policies.  And sometimes the fact that this is not true ends up going viral
on Twitter and people are surprised.  And the reality is that, well, you need
more because you need full knowledge of the script.  That's true for something
as simple as multisig, and of course becomes even more true when you do more
complicated stuff, like what people are doing now with miniscript and all this
timelock and combining multisig with timelocks, all these kind of things.
Because, if you don't know the exact script that you need to spend a
transaction, the exact script is only committed in the transaction, but you need
to kind of sign it.  So, you need to be able to reveal it on chain when you
spend a transaction.  And so, if you lost that knowledge, you still control the
keys, but you are not able to produce a valid transaction spending it.

So, this sometimes leads to these alarmist tweets about the fact that, "Oh,
multisig or miniscript or complicated policies are dangerous", which I've always
been pushing back saying like, "Well, backup is a much easier problem than
storage of secrets, like the seed, and should be treated differently".  So, I
had many discussions with people over the years where I see creative solutions
like printing, for example, the descriptor on metal, the same way that they do
for the seed, which is something that I always tell people, "Well, don't,
because you're applying techniques that were designed for objects that have
different security requirements for just backups that are much different".  The
reason it's different is that, I am motivated in the post that there is a
distinction between secrecy and privacy.  So, while the seed is secret, because
that's what allows you to spend the funds, and so if you know the seed,
basically you're the owner of the funds.  And so, for something that is secret
like this, you don't want to do digital copies.  So, that's why we have hardware
signing devices, so we can keep the keys separated from where you have the
software wallet, for example.  And having more keys, having more copies of this
seed in a way makes your backup more resilient, but it also makes it more
dangerous, because it means if you have multiple places where you are storing
this, someone might find it and now they're able to spend their funds.

Instead, the descriptor, like the xpubs, even if we call it xpub because it's a
public key in terms of cryptography, it's still private information.  So, it's
private in the sense that you don't want to tell it to everybody.  So, it's
public in the sense that it describes what are the keys that ends up onchain,
which are the ones that then you use to actually produce the signatures for.
But still, knowledge of the xpubs or the descriptor allows people to identify
your UTXOs and your transactions onchain, so you basically lose your privacy.
And so, you want to keep it private.  And here, the requirements are different,
because now, of course, attackers might still be interested in trying to find
your descriptor, but it's much less valuable than finding your seed, because it
only gives them some information about your funds, but it's not the same as
actually getting control of your funds.

So, the way you can defend something like that is not the same that you can
apply when you are trying to defend the seed.  And anyway, for descriptors,
having digital copies is unavoidable, because every time you interact with a
software wallet, you already have a digital copy on the computer, which is an
internet-connected device.  So, having additional digital copies, of course it
can expose you to some more risk of having this information leaked, depending on
how you store it, but it's not as catastrophic as losing your funds.  So, that
was a bit like the motivation of the scheme.

**Mike Schmidt**: Okay, yeah, that makes a lot of sense.  I'm motivated.  What
do we do about it?

**Salvatore Ingala**: So, yeah, the core idea is that, well, in a descriptor,
you have all the xpubs of all the participants in the signing policies.  So, if
it's a multisignature 3-of-5, you have these five public keys.  In a miniscript
wallet, again, you might have multiple spending conditions, but each of them
might have some public keys that are given by the participants.  So, you already
have some public keys that are of interest.  They are the public keys of the
people who are interested in knowing the descriptor.  And so, if we are backing
up the descriptor, those are exactly the people you want to be able to decrypt
this descriptor.  And the reason you might want to encrypt the descriptor is
because once the descriptor or the wallet policy is encrypted, you can store it
in places that are much less trusted, potentially even on the cloud or in a
public place.  You can make a tweet with an encrypted descriptor and that
doesn't reveal anything, right?  And so, of course, a lot of people have this
interest in encrypting the descriptor.  Murch has a comment.

**Mark Erhardt**: If you tweet the descriptor encrypted and then later it gets
spent and the public key is visible, one of them, wouldn't that allow any
observer of your tweet to decrypt your output script descriptor and therefore
see your entire wallet history?

**Salvatore Ingala**: Yeah.  So, if someone gets the public key that is used to
encrypt this descriptor, then yes, because now they become indistinguishable
from one of the legitimate decryptors of this descriptor.  But it's not the same
public keys that go onchain, because in a wallet you have a descriptor, you have
the root xpub from which all the public keys are actually derived, and so -- in
fact, maybe I'll go into describing what is the scheme.

So, in a descriptor, you have, as I said, all the xpubs that are this root of
all the keys that are derived from these xpubs, right?  And each xpub kind of
belongs typically to one of the parties that are in this wallet, in this
account.  And so, the trivial idea would be like, well, that's a public key.
You can just encrypt the descriptor with one of these public keys.  And now,
that entity will be able to decrypt the encrypted descriptor.  And now, if you
want everybody in the descriptor to be able to decrypt this, the trivial
solution would be to just do that again for each of the public keys that you
want to be able to decrypt.  And it works, would even potentially work
reasonably well in practice, because the descriptors are not that big, so making
five copies or ten copies is not a huge deal.  But it's kind of like it feels
redundant and computer scientists don't like redundant things.  So, you can see
that there is room for optimization here.

So, the second iteration of this is that, well, if you want all those public
keys to be able to decrypt the descriptor, you can first generate a shared
secret somehow.  It can even be random.  And then you encrypt this secret with
each of the public keys.  And so now, each of the public keys is able to decrypt
this secret, and now you use this secret instead with normal symmetric
encryption now to encrypt the rest of the descriptor.  So, in this way, the only
thing that you encrypt many times -- so basically each of the public keys that
are involved, you will have to encrypt it.  And so, you have n encrypted keys in
the backup, plus a single copy of the encrypted descriptor.  So, this already
solves the duplication problem, because an encryption of a public key is not
very big.  And that works.

I will say the final idea that is added to this is that, well, this could work,
but another problem is that if you're encrypting this descriptor with the public
keys that are in the descriptor, the private keys for these keys that are needed
for the decryption could be in a hot wallet, could be in a hardware signing
device.  And so, that means that you will need to implement the logic for
decrypting wherever these private keys are stored.  So, that, I feel like it
could be a very big problem for adoption, because now it means that before you
can use these backups, you need hardware signing devices to be able to implement
the decryption, and you need each of them to do it, so you need to define a
standard.  And this would be very difficult because, like the usual
chicken-and-egg problem, there is no demand until people start using a feature,
but you need people to actually implement the feature before you can use it.

So, the next idea is that, well, since what you want is that anybody who has the
xpub, so anybody who is a party in this descriptor, should be able to decrypt
the encrypted backup.  Instead of using the xpubs as a public key in asymmetric
cryptography, we just use the xpubs as a source of entropy, as a source of
randomness.  And basically, we can just generate a pseudo random key by hashing
this public key.  And so, what we get is now an asymmetric secret that anybody
who knows the xpub can generate.  So, if you know the xpub, hopefully you
shouldn't give the xpub to everybody if you are a part of the descriptor, but as
long as you have the xpub, now you will be able to decrypt this encrypted
descriptor.  Basically, once you do that, then you can even think of making this
fully deterministic.  Now you don't even need randomness.  And I commented, so
there is Jonas here, so I hope I don't get burned by the actual real
cryptographer; but because here, there is only a single plain text that will be
encrypted with that secret, just having enough entropy should be enough for
having reasonable security.  So, even if this violates the standard semantic
security that is used typically in cryptography, that should be safe.  And Jonas
raises his hand, so I'm prepared to be roasted now!

**Jonas Nick**: No, it's okay, just to be clear, so you're using public keys as
inputs to derive some secrets, right, for the encryption?

**Salvatore Ingala**: Yeah, so I use in the scheme, to be more precise, I
actually haven't described exactly the scheme, I use the combination of all the
xpubs in the descriptor to generate the shared secret.  And then, this is the
shared secret that I use to encrypt the descriptor.  And then, this shared
secret, I encrypt with each of the individual keys that are derived from the
xpubs.

**Hunter Beast**: And why don't you derive a secret key and use that to encrypt
the descriptor?

**Salvatore Ingala**: You derive the secret key how?

**Jonas Nick**: Like, each signer could derive a secret key, right, and then
encrypt it.

**Salvatore Ingala**: Yes, that could be an alternative.  But again, we go to
the problem where we need the signing devices, or whatever you're using to
produce signatures, or something where you store the keys, to implement this
feature.  By moving from the asymmetric cryptography to the symmetric
cryptography, the main goal would be that basically this encryption scheme could
become a node-dependency, something the software wallet can implement without
requiring any new feature from the signing devices, because they already have
the feature of being able to export the xpubs.  And in a way, I don't think that
you're really losing any significant security properties, because the people who
know the xpubs are exactly the ones who you want to be able to decrypt the
descriptors.  I know that taking a public key and hashing it and using it as a
private key looks a bit dirty, but I think it can be motivated in a reasonable
way.

**Jonas Nick**: Yeah, at least it sounds very simple.  The only thing you need
is the descriptor to encrypt the xpubs.

**Salvatore Ingala**: Yeah, exactly.  It's kind of like you can make it a pure
function that gets a descriptor and gives you out the encrypted backup.

**Jonas Nick**: And so, one thought I had was like the ciphertext, depending on
how you do it, may leak the length of the descriptor.  So, if you post the
ciphertext of your huge descriptor on Twitter and then later someone sees a huge
descriptor on the blockchain, then that might be secure.

**Salvatore Ingala**: Yeah, that's definitely true.  And anyway, this is not
like a BIP proposal yet.  This is more like a blueprint.  I feel like my
impression is that this is kind of on the right track, so the call to action
will be like, okay, for people working on software wallets, look, if it has the
properties that you will want from a wallet backup, I will be very interested in
working together to come up with an actual real BIP.  And cryptographers, please
also review if I did any wrong assumption.  There is definitely more work to do
in actually making it a real BIP.  Also, you want a reference implementation, it
has a test vector and everything.  And also, it would be nice to see if there
are other features that people demand from this.  But hopefully, there are
features, not features that would completely change the way this scheme works.
That will be the hope.

**Mike Schmidt**: Now, there's a lot of potential stakeholders that would be
interested in something like this, so I can imagine feedback or debate on some
of this.  How has the feedback been so far?

**Salvatore Ingala**: Yeah, there have been a few replies on the post.  There
was some reply from a guy named Josh on Delving, that he worked on a somewhat
related scheme, but that was only for multisig because it was based on basically
Shamir's Secret Sharing.  So, in that sense, it's a little bit more complex, but
not that much more complex.  But the problem is that the moment you go towards
Shamir's Secret Sharing, automatically it doesn't generalize to miniscript where
you have different spending policies.  And so, I don't think there is a common
ground that works for both those two approaches, let's say.  And there were some
comments from Kevin, from Wizardsardine, developers of Liana, and his concerns
are more about adding some error correction mechanism.  Although my impression
is that that's more out of scope, in the sense that error correction for me,
it's more a property of the storage, where you store this, while the scheme is
about what is it that you're storing, so not how you store it.  So, I think they
have two separate things because, for example, if you store a descriptor on the
cloud, it's not your concern to do error correction.  Cloud backup either fails
or error correction is someone else's business.

**Mike Schmidt**: Murch, do you have any comments or questions?  Okay.  So, I
guess, Salvatore, do you want to give a call to the audience of developers and
hardware wallet folks?

**Salvatore Ingala**: Yeah, as I say, for call to action for software wallets
mostly it would be, look into it if you're interested, if it works for you.
Because so far, basically all software wallets I've seen, typically they say,
"Oh, this is your descriptor, don't lose it, copy, put it somewhere", and that's
not a great UX, I think we can do a lot better.  And once we have a good, simple
mechanism for encryption and backup, things like storing it on your Google
Drive, for example, could become a lot more attractive to people, and I think
it's a reasonable approach to take.

**Mike Schmidt**: All right, Salvatore.  Thank you for joining us.  Jonas, we
actually did get a question that came in during the descriptor backup discussion
from Seardsalmon saying, "What are the other curves mentioned that have Sig-Ag
theory or implementation?  If I recall, there was BLS and schnorr EdDSA, not all
the curves ever, but previously mentioned in Bitcoin related research".

**Jonas Nick**: Yeah, so I think the previous main candidate for signature
aggregation, CISA, in Bitcoin, would have been BLS signatures.  They have been
around for a while.  They would require a new curve.  But there are also
signature aggregation schemes that rely on different assumptions that don't
really need even elliptic curves.  For example, there are also signature
aggregation schemes that have assumptions based on lattices or assumptions based
on hashing.  But they are typically not as concretely efficient as something
like DahLIAS.  So, for example, a hash-based scheme would be interesting.  I
think that is sort of future work, because that would potentially be
post-quantum, so it would be not vulnerable against a quantum computer.  And
we're already assuming that SHA-256 is collision-resistant, because otherwise
Bitcoin doesn't really work, merkle tree doesn't work, etc.  So, the question
is, can we build an efficient, or at least a relatively efficient, aggregate
signature scheme from that?  But those schemes, they are quite complex or not
very efficient.  So, that is going to be, I think, very interesting future work.

**Mike Schmidt**: All right.  Well, Salvatore, thank you for joining.  You're
welcome to stick on as well.  We have some Stack Exchange questions that might
be interesting, but if you need to drop, we understand.

**Salvatore Ingala**: I'll stick around a bit.

_What's the largest size OP_RETURN payload ever created?_

**Mike Schmidt**: The second Stack Exchange question this week was, "What's the
largest size OP_RETURN payload ever created?"  Timely question.  And Vojtěch
links to a metadata protocol transaction, Runes, which had just over 79,000
bytes as the largest OP_RETURN.  Murch, I thought that there was a limit on the
size of the OP_RETURN?

**Mark Erhardt**: Yeah, that's a misconception that comes up occasionally.
There is a mempool policy limit, which also differs between different
implementations of the Bitcoin protocol.  The Bitcoin Core limit is 83 bytes for
the output script, which gives it, I think, a payload of exactly 80 bytes.  But
the limit in other clients, I think Knots is 40 bytes.  The limit was never
there for the consensus rules, so because an OP_RETURN output is already
unspendable, the 10,000-byte limit that makes a script unspendable doesn't
really apply because the output is already unspendable.  So, basically, I think
the limit would be 30 MB or so, which is the network message, which is of course
then limited by the transaction size, which is limited by the block size.  So,
yeah, I guess you could make a block that is a whole 1 OP_RETURN, unless I'm
missing something which is quite possible.

I did look into this transaction very briefly and mempool.space reports that it
is a Runestone, and I looked it up further by just googling the txid.
Apparently, it is the runestone for a Rune called BARRELS-OF-OIL!

_Non-LN explanation of pay-to-anchor?_

**Mike Schmidt**: Yeah, I saw that on mempool.space as well.  All right.  Next
question from the Stack Exchange, "Non-LN explanation of pay-to-anchor?"  The
person asking this is kind of saying, "Hey, pay-to-anchor (P2A) is always
entwined with LN in the way anchors are structured for LN.  Can you give me an
example of P2A that's not LN and what's the rationale there?  And, Murch, I
don't know if you want to get into all the rationale, but you detailed the
rationale and structure of P2A output scripts.  How would you summarize?

**Mark Erhardt**: Yeah, I think I understood that question a little different.
It just says, don't use LN lingo to explain it, but rather what is it for?  So,
P2A is generally a keyless native segwit v1 output with a 2-byte witness
program, which means 'keyless' says you don't need a signature in order to spend
it.  In fact, anyone can spend it just by referencing the output, and we
identify outputs uniquely by stating the txid and the vout, which we call an out
point.  And, yeah, so it's native segwit v1 because it follows the pattern with
the witness program that all native segwit outputs share.  This one specifically
starts with an OP_1, which indicates it's v1.  And that's permitted because
taproot, when it got introduced, only encumbered 32-byte witness programs in the
v1 space; whereas when we introduced a v0 native segwit outputs, we encumbered
20 and 32 bytes and everything else was declared invalid.  When we got taproot,
we only encumbered the 32 bytes and we left everything else valid to be defined
in the future.  So, yeah, basically the address shows up as fees-something,
because the 2 bytes just cause that address to be derived from the output
script.  And it's a valid output because all native segwit outputs are valid to
any version of Bitcoin ever.  And Bitcoin Core considers it a standard
transaction when an input is spent, since 28.0.

So, the question was specifically, how does it fit together with ephemeral dust?
Ephemeral dust is a new mempool policy in 29.0, which makes use of P2A, or not
necessarily actually; ephemeral dust just states that you can have an output
that is below the dust limit if the transaction itself is zero fee, and that is
standard for TRUC (Topologically Restricted Until Confirmation) transactions.
TRUC transactions can have a fee of zero and still be standard.  And they would
only make it into the mempool if there's a second transaction that pays fees for
them that is a child transaction of the zero-fee transaction.  The last, final
rule for ephemeral anchors is, if there is a transaction that spends an output
from the zero-fee transaction that has the dust output, the dust output must be
spent by that transaction.  So, you can spend only the dust output or more than
one output of the transaction, but you must spend the dust and that makes it
ephemeral, because the transaction that creates the dust output does not pay
fees, so there's no incentive for any miner to ever include these, unless
someone pays them out of band.  And the fees are brought with the child
transaction and the child transaction, in order to be allowed in the same
package, must spend the dust output.

Yeah, so P2A and ephemeral dust, they do play well together.  You can make
ephemeral dust transactions with the P2A output script, using TRUC transactions
as well.  And then, you have a nice two-transaction package that propagates
well.

_Up-to-date statistics about chain reorganizations?_

**Mike Schmidt**: Next question from the Stack Exchange, "Up-to-date statistics
about chain reorganizations?"  The person asking this is more asking about the
statistics around chain reorgs, how common are two-, three-, and four-block
reorgs nowadays?  They found some data sources, but they weren't sure if there
was an anomaly there because they weren't seeing any of the longer reorgs
nowadays.  Murch, you helped answer this along with 0xb10c.  0xb10c posted to
the Bitcoin Data/stale-blocks repository, where he collects a bunch of stale
blocks as much as he can find, based on the nodes that he's running and the
information that he receives.  You also pointed out forkmonitor.info and
fork.observer.  Forkmonitor has an RSS feed of this sort of activity, and
fork.observer has a visualization based on some of their recent history.  Do you
want to elaborate on any of that?

**Mark Erhardt**: Sure.  So, stale blocks have become fairly uncommon.  They
used to be much more common.  We would have a stale block about once per day.
And then there were a few improvements on block propagation.  And from the
rumors I've heard, a bunch of mining pools updated their hardware that piloted
their mining pool.  Some of the mining pools apparently were running very
low-powered devices as controllers for their mining pools, and that added
additional latency because these Raspberry Pis, and other microcomputers, would
take forever to validate the block, and that gave their mining pool more time to
work on the old template and we had stale blocks more often.  So, in fact
lately, we have, I think, a one-block reorg about once every two weeks or so
roughly.  So, that's exceedingly uncommon now.

0xb10c writes here that there have been only two two-block reorgs since November
2020: one was at block height 788,686, which I think would have been about April
2023, from the top of my head; and the other one was in November 2020.  So,
those two are about two-and-a-half, three years apart.  So, I don't remember
when we last had a three-block or four-block reorg.  Anyway, that stuff doesn't
happen that much anymore.

**Mike Schmidt**: And if you're curious about some of the data yourself, jump
into that Bitcoin Data stale-blocks repo and you can run your own analysis on
it.  Go ahead, Murch.

**Mark Erhardt**: Oh, yeah.  Also, if you're running a super-old node, like if
you started running a node in 2011 and still have the original blockchain that
you processed, the block files, 0xb10c has a tool that he publishes in this
repository, or ask him for it, but it writes out the stale blocks that your node
has seen.  And that's how all the contributions of what he collects in the
stale-blocks repository have been collected, because obviously his node didn't
see all of the stale blocks and he's crowdsourcing more information.  So, if you
have a super-old node and want to contribute to historic data, you could get in
touch with 0xb10c in order to help collect your stale blocks.

**Mike Schmidt**: On the readme for the stale-blocks repository, there's a
section for contributing full stale blocks and contributing stale-block headers.
There's some shell scripts that you can run and that, I think, would be very
welcome.  Good idea for call to action, Murch.

_Are Lightning channels always P2WSH?_

Next question from the Stack Exchange, "Are Lightning channels always P2WSH?
Polespinasa notes, in his response, the P2TR simple taproot channels that are
something that we've discussed on the show a few times, particularly around LND
that supports P2TR on the LN, specifically edging towards their Taproot Assets
project, which relies on taproot and has the ability to have assets other than
Bitcoin using the LN.  Polespinasa also noted some support, or lack of support,
from Core Lightning (CLN) who doesn't support taproot channels but does allow
you to have a P2TR address for onchain, and likewise, Eclair, that doesn't
support taproot channels yet, but they do have taproot in one of their products
for their swaproot swap protocol.

_Child-pays-for-parent as a defense against a double spend?_

Next question from the Stack Exchange.  Murch, you answered this one.  I thought
this was kind of interesting, "Child-pays-for-parent as a defense against a
double spend?"  I feel like you might do a better job of summarizing what the
person is asking for here and how CPFP comes into it.

**Mark Erhardt**: Yeah, basically they were looking at a transaction that had a
single confirmation and they were starting to maybe ship out the product or, if
it's a digital good, handed that over already.  And then, the sender of the
money would publish two blocks to reorg out this transaction and divert the
money back to themselves.  And they are asking, would it now be possible to
offer a transaction that pays a humongous transaction fee in order to get their
own shorter chain used to extend to a longer chain tip and basically reorg out
the attacker again?

So, in theory, this has been discussed quite a few times.  I think AJ has a few
write-ups on this sort of topic in Delving.  I haven't pulled them up yet,
unfortunately.  But the general idea here is that the transaction by itself
would not propagate, of course, because in the chain tip, or in the best chain
from what all other nodes have seen, the input is spent already, right?  You
would need to use the money that was sent to you via this very big transaction,
let's say 10,000 bitcoin as in the question, and you send 100 bitcoin in fees on
a child transaction from the payment that went to you on the now stale chain.
In order to see that transaction with the 100-bitcoin fee, they would have to
even consider the stale chain tip as a potential alternative history.  But once
they've seen the better chain, the longer, heavier chain, they wouldn't consider
the transaction valid anymore, nodes would not forward the transaction.  So, in
order for anyone to even consider this offer, this bribe so to speak, they would
have to run custom software that invalidates the last block or last few blocks,
whenever there is more than one chain tip they're aware of, in order to check
whether there would be any such bribes.  At least at this point, I'm not aware
of any mining pools running all this extra overhead in order to see whether
anyone is trying to bribe them to build out a stale chain tip.

The next problem with this approach is once the attacker sees that you're trying
to bribe the miners into double-spending the attack, the attacker can just start
to offer a bribe themselves for the miners to stay on their chain.  And given
the large amount, and given that they're stealing and benefiting more already
because they have both gotten their money back and the goods, they can probably
outspend the defender, the victim of the attack, because the victim of the
attack needs to at least make back their losses, while the attacker has already
a 100% gain to start with.  So, they might be able to outspend.  The attacker
also is ahead already by one block, so it's much more likely for them to win,
especially if they just offer that bribe for people to extend the already best
chain tip, because that transaction does propagate.

Finally, I don't think that miners should consider running this software,
because miners benefit indirectly from the perceived stability of the Bitcoin
Network and the reliability of confirmations.  If miners actually worked on
subverting the reliability of confirmations, I could see that backfiring on the
overall value of Bitcoin, and miners being huge holders of Bitcoin would shoot
their own foot that way.

**Mike Schmidt**: Excellent walkthrough, Murch.  Folks may listen to this
scenario and also think of previous hacks that have occurred.  I think there was
something with Binance at some point, where they got hacked and then there was
discussion of if there was going to be some sort of a reorg.  And the reason
that this approach would not work there is because in the approach outlined by
Reggie in his question, there was actually an initial transaction that was valid
that the person being double-spent had, in order to have then a way to
incentivize the reorg.  Whereas, if the funds are just stolen and there's no way
to incentivize that with CPFP, like in this example, that was never a
discussion.  This approach wasn't discussed back then.

_What values does CHECKTEMPLATEVERIFY hash?_

"What values does CHECKTEMPLATEVERIFY hash?"  Average-gray outlined the fields
that CHECKTEMPLATEVERIFY (CTV) commits to.  I actually think he used maybe some
different wording in his answer.  I actually went to the BIP and took the fields
out, which is nVersion, nLockTime, input count, sequences hash, output count,
outputs hash, input index, and in some cases, scriptSig hash.

_Why can't Lightning nodes opt to reveal channel balances for better routing efficiency?_

"Why can't Lightning nodes opt to reveal channel balances for better routing
efficiency?"  René Pickhardt, who we've had on the show a few times before
talking about routing efficiency, explained some of the concerns.  He notes the
potential staleness of the data that is being propagated through whatever means
this would be propagated, the trustworthiness of the data.  So, the idea here
is, can you say what the balances are between all the channels and have that as
part of your gossip or network graph?  And so, the staleness of the data, the
trustworthiness of that data, and then certain privacy implications as well.
Yeah, go ahead, Murch.

**Mark Erhardt**: There's also the concern that if every node wants to update
the whole network on basis of every payment, that the amount of data that would
have to be sent around in the network, besides making all the payments
transparent and losing all privacy, the amount of data would just be completely
unsustainable.  The channel announcements, just the existence of channels, are
something like 150 MB, or even more.  That might already be a compressed graph.
Imagine if each of these were updating several times per hour, maybe several
times per minute, and making new announcements all the time.  That would
probably incur quite the bandwidth cost.

**Mike Schmidt**: Yeah, indeed.  You'd have a trade-off between the bandwidth
and the staleness, I guess.  You'd still have the trustworthiness and then, best
cases, privacy is completely ruined because you can see every single payment if
you saw this all real-time, I guess.  And then, if you're curious about some
previous discussion from this, I think it was actually René's own, was it René's
own proposal?  Yeah, from 2020 to the BOLTs repository, which is actually still
open, where he outlines this, and there's a thread over the years of some
discussion.

**Mark Erhardt**: To be clear, I think he only proposed that it would be shared
two degrees, so to your friend and to your friend of a friend, which would of
course make the amount of data that flows much smaller.  Let's say if you have
ten peers and each of your ten peers has nine additional other peers besides
you, you would only have to reach about 100 other nodes, or even less if they're
interconnected.  Whereas, if you have to reach every other node in the network,
which is I believe several thousands, that would of course be much more.

_Does post-quantum require hard fork or soft fork?_

**Mike Schmidt**: Last question from the Stack Exchange, "Does post-quantum
require hard fork or soft fork?"  And Vojtěch answered this one.  He outlined a
vision that would involve a post-quantum (PQC) signature scheme being done via a
soft fork, and then folks migrating their funds to this PQC scheme in time for
the quantum threat to actually be materialized.  And then, he noted a separate
question which is, "What do you do about coins that are vulnerable, especially
publicly exposed?"  And he outlines one option is to do nothing, let them be
stole by quantum attackers; and another option is making those coins unspendable
with a soft fork after a set deadline.  And he outlines yet another option,
which was making those coins unspendable.  I think he had one here that would be
a hard fork.  Oh, he notes the only time that we would need a hard fork is if we
first wanted to make the vulnerable coins completely unspendable with a soft
fork, and then later wanting to re-enable spending with a secure signature
scheme.  So, that would actually be a hard fork.  I butchered that a little bit,
Murch, but maybe you can clean it up.

**Mark Erhardt**: Yeah, you could even do this with a soft fork.  You would just
freeze them for a few years and you could update that if you need more time.
But by the freeze only being time-limited, you could soft fork it and then it
would heal itself and become spendable without a hard fork.  But yeah, so I was
pretty surprised.  This debate has also been ongoing on the mailing list and on
Stacker News and other places, and I'm very surprised by a huge number of people
proposing or advocating for, "Just let the attacker have the coins.  We should
never burn any other people's coins.  Certainly, you shouldn't appropriate them
and not even burn them".  I was just so surprised because among technical
contributors, the overall tenor seems to be that people say, "Well, this is a
systemic risk and we would need to burn it and there is absolutely no reason why
Bitcoin should incentivize development of quantum computers".

So, to me personally and a few other people, it seems strange that people are
much more leaning towards, or at least in the discussions that I've read, a lot
of people are leaning towards, "It's the responsibility of the key holder to
keep their coins safe and we should never touch any other people's coins, so let
the attacker have it, because they know the key and at that point, we can't tell
whether it's the attacker or the original owner.  And if there's millions of
coins going back into other hands, oh well, so be it, and we'll just have to
weather that, I don't know, tanking value or something".  So, yeah, interesting
how at least a big number of social media participants come down exactly
different to me that question.

**Mike Schmidt**: And it doesn't seem like, from what I've seen either, that
there's people that are on the fence.  It seems like there's an initial gut
reaction one way or the other, and they're just on the extreme ends of it.  Is
your read, when you're reading some of these discussions, that people are like,
"Hey, don't touch it, or let it be stolen.  Don't force people, don't lock
people's coins involuntarily"?  Is what is behind that, in your opinion, some
principle or is it that, "Hey, this quantum thing is hyped and it's not actually
ever going to happen, so therefore we don't want this precedent of speculatively
locking people's funds, because we think this quantum thing is going to happen".

**Mark Erhardt**: Yeah, I think that's all three.  So, there's people that are
saying, "Quantum's not going to happen anytime soon and we don't have to be
worried"; there are people that are saying, "We should never touch other
people's coins in principle.  You should be able to go away for 25 years and
come back and your coins should be spendable.  We should never plan for any sort
of collaborative action on other people's coins"; and then some mix thereof.

_LND 0.19.0-beta.rc3_

**Mike Schmidt**: Moving on to the Releases and release candidates, we have LND
0.19.0-beta.rc3.  We've had some version of this RC on for a while.  I believe
it was #349, Murch, where you gave a nice overview of this forthcoming release.
So, I'll point people there, and we won't jump into it today.

_Bitcoin Core #31247_

Notable code and documentation changes, Bitcoin Core #31247, which implements
serializing of MuSig2 PSBT fields.  And maybe as a background, users who want to
coordinate on creating a transaction can use the PSBT structured data format to
pass around partial bitcoin transactions.  However, with the addition of MuSig2,
the old PSBT fields were insufficient and new fields were added to the PSBT in
order to support the required MuSig2 participants being able to exchange PSBT
files with each other.  And so, BIP373 specified what those MuSig2 PSBT fields
were.  And now, Bitcoin Core is working towards supporting, receiving, and
spending of inputs using MuSig2 aggregate keys in the wallet.  So, this PR today
that we're talking about is part of, and split off from, a broader PR to achieve
that functionality.  That PR is, "Be able to receive and spend inputs involving
MuSig2 aggregate keys".

A little slice of that was carved off for this PR that works towards that goal
by doing three things: one, it implements serialization and deserialization of
the MuSig2 PSBT fields that were specified in BIP373; it also adds the MuSig2
fields in the decodepsbt RPC; and finally, it adds BIP373 test vectors.

**Mark Erhardt**: Yeah.  From my understanding, it still doesn't mean that, or
maybe I'm wrong about that, but I don't think that it means that the Bitcoin
Core wallet can participate in MuSig2 transactions yet with PSBT or otherwise.
I believe we're still working on support for that.

**Mike Schmidt**: That's right.  You can check out the, I don't want to call it
a parent PR, but the one that this #31247 was split off from was #29675, which I
think is the more comprehensive actual implementation that Murch is referencing.

_LDK #3601_

Last PR this week, LDK #3601, which changes the way that LDK handles error
codes, specifically updating the handling of HTLC (Hash Time Locked Contract)
failure codes, error codes, and they want to now represent all possible BOLT4
error codes.  It involved changing the representation of errors from integers in
LDK to a named enumeration, and also adding previously unrepresented error
codes.  And there was a bunch of internal refactoring commits as part of this PR
to facilitate those changes from the int to the enum.  There's also a separate
open PR to LDK that reflects these failure reasons in the API, but that's a
follow-up PR to this one.  I didn't see anything else too notable there.

Murch, you're good?  Awesome.  Salvatore, thanks for hanging on and thanks for
joining us this week as a special guest.

**Salvatore Ingala**: Thanks for having me.

**Mike Schmidt**: Jonas dropped, but thanks to him for joining on the News and
also some of the Stack Exchange discussion.  And thank you to Murch, as always,
co-host, and for you all for listening.  Cheers.

**Mark Erhardt**: Cheers.  Thanks for your time.

{% include references.md %}
