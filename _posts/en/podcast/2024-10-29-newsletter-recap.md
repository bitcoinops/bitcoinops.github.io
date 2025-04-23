---
title: 'Bitcoin Optech Newsletter #326 Recap Podcast'
permalink: /en/podcast/2024/10/29/
reference: /en/newsletters/2024/10/25/
name: 2024-10-29-recap
slug: 2024-10-29-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Elle Mouton and Andrew Toth to discuss
[Newsletter #326]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-9-29/388920064-44100-2-5c27e4859b0dd.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #326 Recap on
Twitter spaces.  Today, we're going to be talking about updates to Lightning
gossip, a draft BIP for sending silent payments using PSBTs; we have eight
questions from the Bitcoin Stack Exchange, including some questions about
pay-to-anchors (P2As), BIP324 decoy packets, BIP69, and Bitcoin puzzles with
1,000 bitcoin locked in them; and we also have our regular segments on Releases
and Notable code changes.  I'm Mike Schmidt, contributor at Optech and Executive
Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs and we just announced
that we're founding a new office on the West Coast, Localhost Research.

**Mike Schmidt**: Congratulations on that, Murch.  Do you want to say a few more
words about that?

**Mark Erhardt**: Yeah, sure.  So, we're looking to be an NGO and we're looking
to fund a few people to work full-time on Bitcoin projects, probably at first
mostly Bitcoin Core, and we're going to start doing that pretty soon.

**Mike Schmidt**: Awesome.  It was great to see that announcement yesterday.
Congrats to you and everyone.  Elle?

**Elle Mouton**: Hi, I'm Elle, I work at Lightning Labs, and I'm currently doing
a bunch of work on the gossip update proposal for Lightning.  Andrew?

**Andrew Toft**: Hi, I'm Andrew, I work at Exodus Wallet doing Bitcoin stuff.

**Mike Schmidt**: Well, thank you both for joining us.  If you're following
along, we're just going to go through Newsletter #326, starting with the News
section.

_Updates to the version 1.75 channel announcements proposal_

First item, "Updates to the version 1.75 channel announcements proposal".  Elle,
you posted to Delving Bitcoin.  The post was titled, "Updates to the Gossip 1.75
proposal post LN summit meeting".  Listeners might be familiar with the LN's
gossip network as the means to advertise channels for affording payments, but
maybe, Elle, you can help us understand what's wrong with gossip as it is today,
and maybe how the changes outlined in your post about a version 1.75 of the
gossip improves that.

**Elle Mouton**: Okay, cool.  So, those are two, I would say, big separate
questions, but I'll give a summary of the two.  So first, the current gossip
network we have in the LN, this is how we find out about new channels that we
can use for routing our payments, we find out about new nodes, and we also find
out about channel updates, so that's updates of the channel fees that the
various nodes are charging, if you want to route across them.  So, this is
great, but it was very much designed for announcing P2WSH channels.  So, that's
segwit v0.  So, it's not taproot compatible.  So, we can't actually use the
current messages to advertise taproot channels, and so that's the first big
thing, is that we need a new set of messages to be able to understand taproot
channels so that nodes can go and know how to verify taproot channels.  So,
that's the one thing.  The second thing is related to that, which is related to
the taproot soft fork, which is that now we have segwit.  So, currently a
channel announcement is quite big because we have four signatures involved, so
it's pretty large.  And with MuSig2, we can now squash that all into one.  So,
that's very nice, because once we have an announcement, we need to persist it
for the lifetime of the channel.  So, we want these things to be as small as
possible.  So, that's the other thing.

Then, another thing is that currently, gossip doesn't really propagate very
reliably across the network for various reasons, like the querying protocol is
its own thing.  But one of the major reasons is, currently we timestamp various
messages, such as the channel update, by a Unix timestamp.  You could create a
new channel update, ie change your channel fees, every second, because you can
just update the timestamp every second.  And so, that makes it quite easy for
you to spam the network with these updates.  And it also just means that if
someone else is able to create the spam, then your channel updates is not going
to reliably propagate across the network necessarily, because the more of these
updates there are, the harder it is for nodes to sync their set of the gossip
messages.  So, that's another update that the new protocol will have, is these
messages will no longer be timestamped by a Unix timestamp, it'll be timestamped
by block height.  So, that basically makes it so that you can only create a
valid update once every block.  Then, if you want to do a burst of changes, you
can save up, so to speak, these updates.  So, your newest update just needs to
be with a block height that's not newer than our latest current tip, but also it
must be greater than the previous update you sent.  So, that really rate-limits
more naturally the number of updates that you can create, and that also makes
syncing better and more reliable, and also then minisketch will possibly be
something we can look into for gossip syncing, now that there will be fewer
updates.  So, that's the big reason that we are updating the gossip protocol, so
those reasons.

Then, the big changes that we discussed at the Tokyo Summit was, well, the major
change is really that we're also going to use this new set of messages to
advertise legacy channels, and when I say legacy channels, I mean P2WSH
channels, so that for those channels, we can also take advantage of all these
other benefits I've mentioned, such as the rate-limiting.  So, that's kind of a
big thing, because initially the proposal was just for taproot channels.  So
now, it will kind of do both.  And then the other part is that we've
restructured how the messages are going to look, because currently with gossip
messages, you have a serialized set of data and then a signature that covers
that entire thing.  That's very limiting, and so now we've restructured the
message structure so that it's going to be pure TLV, so that's Type-Length-Value
format, and then we're going to have that the signature only covers a certain
range, and then there will be an unsigned range.

What that helps with is now we can, for example, add SPV proofs for our peers to
these channel announcements.  So, me, someone who is just propagating gossip, I
didn't create the update, but my peer is asking for SPV proofs because they're a
light client; I can just add this to the message now, it doesn't need to be
signed.  So, that's very nice, because the alternative is the SPV proof is added
to every single message, and then every single node on the network must persist
the entire thing, and that can be quite large.  So, yeah, those are the major
changes.  And then I've also just set out a strategy for rolling this update
out, because it is quite large.

The final thing that's quite cool is, because we're now going to be able to go
back and recreate announcements for our legacy channels, because all the
implementations will now have to be able to do that, this opens up the avenue to
allow us to potentially announce a previously unannounced channel, ie make a
private channel public.  So, that could be something that this new update will
let us do.  So, yeah, that's the summary.

**Mike Schmidt**: Elle, of the items that you outlined just now, all of those,
do you feel like that has buy-in from implementations in the LN ecosystem, or
are any of those still being debated at the moment?

**Elle Mouton**: Currently, it seems like everybody's bought into it, and that
kind of was the purpose of this post, of like, "Let's see what everyone feels".
But I think everyone was on board and at the Summit, there weren't really any
big conflicts about this.  So, cost seems to be clear for now, yeah.

**Mike Schmidt**: You alluded to having a strategy to roll this out.  Is there
more meat there that you can dig into?  What is the strategy or timeline,
assuming that there aren't big objections?

**Elle Mouton**: Yeah, sure.  So, the idea is, this is a network-wide upgrade,
right, so it really is quite big.  Gossip is a big part of how a node, I would
say, is implemented.  Like, it's just very in there.  And so to do all of this
in one go with one feature bit to signal, "I can do all of this now", is really
quite a big load.  And so really, the idea is just to have three or four feature
bits that will help us roll this out in a more piecemeal fashion.  Otherwise,
it's just too much for implementations, I think.  So, I generally don't like
these big-bang approaches of, "Let's just do one feature bit with all these new
things".  So, the idea here is that the very first feature bit, so let's just
call it feature bit 1, will mean I can -- and when I say 'I', let's say I'm a
node -- it means that if I'm announcing this feature bit, I understand all the
new messages, so I can verify both legacy channels and taproot channels using
the new protocol.  And I can create the new messages for taproot channels, ie I
can announce simple taproot channels.  So, that's feature bit one.

Feature bit two will be a way to signal to your peer, "Hey, listen, this legacy
channel we have from way back when, I'm able to, if you want to, we can re-sign
the channel announcement with the v2 protocol, or V1.75, whatever, and we can
reannounce".  So, it's just telling your peer, "I can do that now".  And the
reason that's a separate feature bit is, I think, implementation-wise, that's
quite a big lift by itself, because now you're handling locally two channel
announcements for your own channels, two channel updates for your own channels,
and you kind of need to know how to do that.  And, yeah, so I think that's quite
a big lift.  That's why it's a separate feature bit.

Then the third feature bit is just these kind of small extensions, such as the
SPV proof.  So, it's a way of telling your gossip level peers, "Hey, I am able
to provide and willing to provide SPV proofs if you ask me".  So, that'll be on
the gossip query level.  Then a possible fourth feature bit, and this is another
one to signal just to your direct channel peers is, "I'm willing to announce a
channel that we previously didn't announce, so it was previously private, I'm
maybe willing to announce it now".  So, those are kind of the four feature bits,
yeah.

**Mike Schmidt**: Okay, excellent.  Yeah, thank you for outlining all that so
clearly.  Murch, do you have follow-up questions?

**Mark Erhardt**: I do.  So, my first one would be, so we heard about simple
taproot channels a few times in the, I'd say, last year, one-and-a-half years.
Is this something that is rolling out across the network now, or is this an
LND-only feature so far?

**Elle Mouton**: So far, it's only LND, but I think, if I'm not mistaken, that
Eclair is really kicking into gear now, so I think they are currently busy
implementing it.  So, yeah, all the other implementations will slowly start.
But the cool thing is, just while we're on this, is that you can totally
implement the gossip version before actually being able to open simple taproot
channels.  So, you can basically start routing over simple taproot channels if
you just do the gossip stuff, without actually having to go implement taproot
channels yourself.  So, that's pretty cool.  But yeah, the other implementations
are slowly starting, yeah.

**Mark Erhardt**: Wait a second.  So, routing over taproot channels would not
require you to be crafting packages that are taproot-specific for each hop?  Is
it still HTLC-based (Hash Time Locked Contract), not PTLC-based (Point Time
Locked Contract)?  Oh yeah, right, that's orthogonal, right?

**Elle Mouton**: Yeah.  That's exactly why these are called simple taproot
channels, because we're still HTLC-based.  And so, yeah, the packets that update
HTLC messages, all that, will still look the same.  So, you just need to be able
to know how to verify that the channel is legit, which this will let you do, and
then you can route over it, yeah.  So, simple taproot channels don't use PTLCs.

**Mark Erhardt**: OK, cool.  And now, final question.  There was a lot of talk
about decoupling the channel announcement from a proof, or from revealing
specifically which funding output creates the channel.  Did that come up at the
summit?  Is there progress towards that?  Clearly, it's not in this part of the
new channel messages.

**Elle Mouton**: Yeah, so great question, and that's exactly why this is called
gossip 1.75 and not gossip 2!  The idea is that gossip 2 will be this more kind
of divorced proof between the channel announcement and the actual UTXO.  So this
currently, with the 1.75 version, will still directly link.  But the idea is
that to make the messages flexible enough that we can then, when we do this move
to V2, we can hopefully still use the same set of messages.  Because everything
is TLV now, so for example, where we have the TLV that says what the outpoint is
of the channel, we can easily remove that now, and then you have your different
kind of proof.  So, hopefully things are extensible enough to move to that
future still.

**Mark Erhardt**: Cool, thank you.

**Elle Mouton**: No probs.

**Mike Schmidt**: Elle, we had, or I guess maybe for the audience, we sort of
focused on this gossip discussion this week, but last week we had roasbeef on to
talk more broadly about the Lightning Summit notes.  And we got into a bunch of
different sub-bullets, including this gossip upgrade that we were talking about
today.  So, if this sort of thing is interesting to you, or you wanted to learn
more about what Elle mentioned with this Tokyo Summit, check our newsletter and
also our podcast from last week.  Elle, any parting words?

**Elle Mouton**: No.  Yeah, I mean, feedback very welcome on the Delving post,
that's all.

**Mike Schmidt**: Excellent.  And I see there's a draft PR as well, so I guess
some feedback welcome either venue.

**Elle Mouton**: Yeah, absolutely.

**Mike Schmidt**: Well, Elle, we do have one LND PR that I believe you reviewed,
later in the newsletter, if you have time to stay on.  If not, we understand and
you're free to drop.

**Elle Mouton**: Cool, I'll stay on.

_Draft BIP for sending silent payments with PSBTs_

**Mike Schmidt**: Next news item titled, "Draft BIP for sending silent payments
with PSBTs".  Andrew, you posted this draft BIP to the Bitcoin mailing list a
couple of weeks ago.  I think our listeners are familiar with conceptually the
idea of using Partially Signed Bitcoin Transactions (PSBTs) as a way to
coordinate Bitcoin transaction information, usually for the purposes of
eventually signing and then broadcasting it; and also separately, the silent
payment proposal, which is used to generate unique onchain receiving addresses
using an offline payment identifier.  So, I think folks probably have that level
of understanding.  But maybe a way to lead into your post is, why is it that
these two technologies can't currently be used together?

**Andrew Toft**: Hey, great question.  So, a silent payment code, we call it a
'code' to differentiate it from an 'address', which is what gets broadcast
onchain.  So, with the code, you can give a static code to any of your people
you want to receive payments from.  And the only way to associate that payment
with the silent payment code is to have the private keys of either the inputs to
that transaction, or the private keys to the silent payment code.  So
effectively, the only people who know that that payment happened are you and the
sender.  And so, this is amazing for wallet UX because wallets can just have one
static silent payment code and never have to worry about generating new receive
addresses.

So, to get wallets to implement receive support though, a lot of them will
require ubiquitous sending support, right, because they don't want to implement
receiving to something that no one else can send to.  So, a lot of wallets
internally rely on the PSBT spec, and even if they're just a software
single-signer wallet and not passing around PSBTs, they're still relying on
constructing the transaction, signing the transaction, and serializing and
broadcasting with the PSBT.  So, if we want to have ubiquitous setting support,
we need to make it easy for wallets to just upgrade their PSBT library.  And so,
to add silent payments to PSBT though, there are some changes we need to make
because there's some new rules with silent payment transactions.  Like, one of
them is that a silent payment transaction can't be spending inputs that are
segwit v2 and up.  So, it's not forward compatible to future segwit versions,
but that's pretty easy to solve with PSBTs.

The main problem is that when you add an output, you don't yet know what the
actual address is.  And PSBTs today, if you add an output, it requires an
address.  So, we talked about whether we needed a PSBT v3 for this or not, and
it turns out we can do this in an easier way than making a new version.  And
it's what we call a silent-payment-aware PSBT implementation.  And so, this
aware implementation allows you to add an output with no address, provided that
the output also has a silent payment code attached.  And when you go to sign
this with the aware implementation, the signer, because it already has the
private keys, will take those payment codes and generate the addresses and
attach the addresses to the outputs and then sign the transaction.  And so, once
the addresses are attached to the outputs, it now becomes fully
backwards-compatible with the existing PSBT v2 spec.

It's also compatible the other way.  So, if you upgrade to a
silent-payment-aware implementation, but you're not using silent payments, then
it will work exactly the same way.  So, if libraries go ahead and upgrade to
become silent payment aware, it doesn't make any risk for wallets to upgrade if
they're not even going to use silent payments.  But if they are using silent
payments, all they have to do is upgrade their library and they'll be able to
sign and send silent payments.  So, that's what this PSBT silent payment BIP is
trying to do or trying to standardize.

**Mark Erhardt**: Thanks.  That's a good overview and a nice start.  I have a
gripe with the terminology.  It is so unfortunate that we have started calling
our invoice identifiers 'addresses' for so long, because really one thing that
silent payments introduces is something that could very well be called a static
address.  So, yeah, but obviously that's not your fault.  So, terminology gets a
little confusing here.  I was wondering, in the BIP draft, I've been traveling a
lot, sorry, I haven't read it yet fully, but I glanced at it earlier and it says
that this is only covering the case where you are creating a transaction by
yourself with a silent payment in it.  Why doesn't this translate to a
multi-signer situation?

**Andrew Toft**: Yeah, I mean so for your first point about the terminology, I
think we could call it a static address or a static payment code.  I mean,
that's kind of outside the scope of the BIP.  But I believe that the current
spec is actually compatible with multiple signers.  The reason that initially it
was for only a single-signer setup is because of the lack of the DLEQ (Discrete
Log Equality) BIP, but now I published a draft for a DLEQ BIP as well, which we
can use to have multiple-signer support.  The reason we need this DLEQ is
because of the difference with what is happening with the private keys.

So, usually when you pass your PSBT to a signer and it returns a signature, you
can verify that that signature is correct to the transaction you're trying to
broadcast, and if it's not, well the network will not accept it, but the
software wallet itself can just say, "This is a bad signature".  What happens
now though, when you pass a PSBT to the signer, the signer is also generating
the output addresses.  And if the signer is malicious or has an error and
computes the address incorrectly, then you're burning those funds, because the
recipient won't be able to decode that as a payment going to its silent payment
code.  So, with the DLEQ though, it acts the same way as a signature but for the
address.  So, the signer can attach a DLEQ proof to the PSBT, along with the
signature, when it gives it back to the software wallet.  And the software
wallet can then, the same way it verifies the signature, verify the output
addresses computed by the signer with those DLEQ proofs to know that they are
actually correct, without having to have access to the private keys.  And in
that way, we can do multi-signer support.

**Mark Erhardt**: Could you, in two sentences, explain what DLEQ stands for?

**Andrew Toft**: Discrete Logarithm Equality proof, I believe.  And so basically
in two sentences, I'm not sure.  But if you know there's two public keys, with
the proof, you can verify that the multiplication of one of those private keys
with the other corresponding public key, you can verify the result of that
multiplication is using the correct private key to the corresponding key pair.
I'm not sure if that's the best explanation, but I tried.

**Mark Erhardt**: So basically, with the DLEQ thing that you're publishing in
parallel, it'll be possible to prove that you correctly constructed the output
script for the silent payment, and the other signers would not be caught in
accidentally burning the funds because you're malicious?

**Andrew Toft**: Yeah, that's correct.  But also, sorry, I forgot to mention,
the DLEQ proof is a proof for basically the share, the ECDH (Elliptic-Curve
Diffie-Hellman) share.  It's similar to an ECDH, which is what a silent payment
is, right?  There's an ECDH between the sender and the recipient, but there's
multiple senders.  Each signer, like each private key owner of that transaction,
can create the ECDH share for their inputs, and then with those shares, you can
combine them all to create the output address.  And so, that's what actually
makes it able to be multi-signer, but the DLEQ proofs now allow all parties to
verify that those shares were created correctly.

**Mark Erhardt**: That's very cool.  And I take it that these DLEQ proofs would
also be stored in the PSBT fields in some manner?

**Andrew Toft**: Yes, that's right.  So, when you are creating your output
addresses as a signer, you will attach your ECDH share as a global field, with
the key value being the payment code, and the input outpoints it is for and the
value being the ECDA share, and then you do the same thing for the proof.  So,
whenever someone gets the partially signed transaction, they can find the
corresponding shares and proofs, verify the shares, combine all the shares to
create the addresses.

**Mark Erhardt**: Okay, so basically this allows us now, for the first party
that participates in the PSBT, to create the skeleton for the output in their
own part of the share.  They hand it off to the next participant, could they
even add an input?  I guess they could even add an input and then ...

**Andrew Toft**: Okay, so one of the new rules in this spec is also that if you
add a share, basically not a signature but a share, the inputs-modifiable field
is set to false, because if you add new inputs to a transaction, they will
change the silent payment address, the address that's computed.  Because the
address that's computed relies on all the inputs, private keys.  So, if you add
or remove one, you're going to now change the address so your share is no longer
accurate.

**Mark Erhardt**: Oh yeah, of course, thank you.  So, it's still one round to
construct the full set of inputs, and then it's another round for everyone to
sign off on it, but it is now possible to do it with multiple parties without
trusting each other blindly.

**Andrew Toft**: Sorry, I misspoke there actually.  Because it's an ECDH share,
you can actually add inputs.  You can't remove inputs that the share is using,
so the share is committing to these input outpoints, but you can add new inputs
as long as you also add a share for them.  And so in that sense, it can just be
one round.  Maybe it's one round.  If you add your share and you -- well, then
you can't sign for the whole transaction until you have all the shares.  So,
yeah, it has to be multi-round.

**Mark Erhardt**: Okay, it sounds like there's at least some double-checking
going on still, but that sounds very cool.  Thank you for working on this.

**Andrew Toft**: Thank you.

**Mike Schmidt**: Andrew, what's feedback been on the mailing list, and is there
anything open to the BIPs repo yet?

**Andrew Toft**: There's a PR open to the BIPs repo.  Hasn't been much feedback
on the mailing list, so if anyone has any feedback, please let me know.

**Mike Schmidt**: Any other follow-up questions, Murch?

**Mark Erhardt**: Thank you, I'm good.

**Mike Schmidt**: Okay, great.  Andrew, thanks for jumping on with us and you're
welcome to hang on for the rest of the show, or if you have things to do, we
understand, you can drop.

**Andrew Toft**: Thanks.

**Mike Schmidt**: Next segment from the newsletter this week is our monthly
segment on selected Q&A from the Bitcoin Stack Exchange.  We have eight that we
selected this week.

_Duplicate blocks in blk*.dat files?_

First one, " Duplicate blocks in blk*.dat files?"  And this person, it seems
like they were writing their own block file parser and came across the same
block information in multiple of those .dat files and had a question of why that
would be.  Sipa, Pieter Wuille, was the person who answered this, just noting
that the structure of the block data files are actually quite unstructured, and
there's no right to the order necessarily.  You can't assume the order, you
can't assume that it's all from the active chain tip, it actually includes stale
blocks as well.  And particular to this person's question, it can actually
result in duplicate blocks in those data files as well, and that's completely
normal.  Murch, I don't have much familiarity with this, but ...

**Mark Erhardt**: Yeah, so my understanding is that while we're downloading
blocks, especially in IBD (Initial Block Download), we are requesting blocks
from a lot of people in parallel.  Usually, we shouldn't be getting the same
block twice.  But for example, if one of the blocks was slow for a while, and
then we request it from another peer, or I think we especially do this if it's
the next block that we need to process, because even though we're downloading in
parallel, we're only processing linearly, we write everything that we receive to
these block files.  So, it is possible that you might have two requests out at
the same time and you're writing them to the blocks at the same time.
Altogether, my understanding is that the blocks files are indexed.  So, if you
want to look up a specific block, your node remembers in which file, at what
depth in the file each block starts.  And it'll only keep one index per block,
but it doesn't preclude information appearing twice.

So, yeah, if you want to parse the block data directly yourself, I think there's
some caveats or some surprises for you there.  It might be easier if you just
run Bitcoin Core, re-index or something, and listen to ZMQ on the side and then
build your own database.  Well, depends on what you're trying to do.

_How was the structure of pay-to-anchor decided?_

**Mike Schmidt**: "How was the structure of P2A decided?  I thought this was an
interesting question.  So, with P2A, you want this tiny anchor output that you
can feed bump off of, or CPFP off of.  So, you want it to be as small as
possible.  But the smallest witness program is 2 bytes, so the anchor needs to
be at least 2 bytes.  And P2A also uses segwit in order to avoid txid
malleation.  And it's a segwit v1 program versus segwit v0, because segwit v0
has the requirement that the program be either 20 bytes for P2WPKH or 32 bytes
for P2WSH, so that would be too big or bigger than desirable.  And it needed to
be a static value so that it can be easily part of P2P policy.  And the final
encoding that was decided for P2A script is this bc1pfeesrawgf, because it's a
vanity address that starts with fees.  Yeah, Murch?

**Mark Erhardt**: A small correction here.  So, v0, the first bout of native
segwit outputs, they are only defined for length 20 and 32, and all the other
lengths have been declared invalid.  But the length 20 and 32 outputs, the
witness programs, they have a canonical meaning.  So, if you create a 20-byte
witness program, it will be interpreted as a P2WPKH output.  And famously, that
one does need a signature in the input, or in the witness stack to be precise.
So, witness v0, actually we just used two lengths and then burned all the other
lengths when it rolled out.  We didn't make that same mistake for v1 because v1,
we left all the other ones unencumbered, so different lengths just don't have
any meaning yet.  And that allows us to use other lengths besides the one
defined for P2TR for new output types.

So, we have another v1 output type here that has a much shorter length.  And in
fact, it is interpreted as basically an anyone-can-spend output that has a fixed
input script, which is empty, because all native segwit inputs have empty input
scripts.  So, while some native segwit inputs do require witness items to be
precise elements on their witness stack, this one does not, and that makes the
input very small.  It also has a very small output because the witness program
is only 2 bytes.  And the output script was chosen so that in the bech32m
encoding, it says 'fees' in the word, right?  So, yeah.  And if I'm not
mistaken, this length would make it exactly the right length to create a 65-byte
transaction of non-witness bytes, so it's bigger than 64, which we were thinking
about not allowing anymore.

**Mike Schmidt**: Next question -- oh, go ahead, Murch.  Did you have something
else to say?

**Mark Erhardt**: Oh, I was just going to say instagibbs is here, so if I got
something wrong, he can jump in.  And maybe also a short shoutout to the
attendance of the Atlanta BitDevs last week.  I confused myself about P2TR.
This is a much better explanation!

_What are the benefits of decoy packets in BIP324?_

**Mike Schmidt**: "What are the benefits of decoy packets in BIP324?"  Okay, so
BIP324 is the encrypted traffic BIP for Bitcoin Core, which allows optimistic
encryption between nodes, so you're not sending plain text messages between each
other.  And Pieter Wuille answered this question of, "What are the benefits of
decoy packets, and what are the potential uses of decoy packets?" in his answer,
and I thought that Murch would be a good person to sort of enumerate some of the
details here.

**Mark Erhardt**: Let me try to summarize instead.  So, the idea of v2 transport
is, of course, to have an encrypted connection.  And encryption is nice because
nobody sees what the content is of what you're sending.  But encryption doesn't
necessarily preclude people from seeing the general shape of what you're
sending, right?  So, for example, if you always make a connection and then you
first send a certain amount of bytes and then you follow up with another certain
count of bytes, and so forth, there might be patterns in there that still allow
people to get a pretty decent idea of what you're doing.  Like, "Oh, that
probably was a Bitcoin transaction.  And actually this length indicates that it
most likely was this Bitcoin transaction, because a new Bitcoin transaction just
got broadcast to me that had exactly that length", right?

So, if you have these decoy packages and also if you allow some garbage to be
sent in between, this allows people to obfuscate the patterns in your traffic
and, this is currently not implemented, but hopefully in the long term, allow
people to just send a little more data, but therefore obfuscate what patterns
underlie this data, even if it's encrypted.

**Mike Schmidt**: And so, there's allowance for this in BIP324, but there's no
actual implementation of it in what we have in Bitcoin Core currently, is that
right?

**Mark Erhardt**: That's my understanding, yeah.  So, it's basically already
designed to be extended in that manner, and especially, for example, if we add
an authentication protocol, it'll prevent people from pattern-matching on the
traffic if people include garbage and decoy packages in between.

_Why is the opcode limit 201?_

**Mike Schmidt**: "Why is the opcode limit 201?"  In the answer here, Vojtěch
answered, and he referenced a 2010 commit by Satoshi that added a limit to the
number of non-push opcodes.  He thought he was making that limit to 200.  This
was in a commit that added, "Additional security limits".  But it turns out that
that first commit to put that limit in place was slightly off and the limit was
actually 201.  So, I suppose we are now left with this opcode limit of 201
moving forward.

**Mark Erhardt**: Yeah, maybe don't change your variables' magnitudes while
you're in your control block.  So, from looking at the code here that Vojtěch
quoted, it was that it was incremented after the comparison instead of before
the comparison, and better would be to first increment the OpCount and then
compare.

_Will my node relay a transaction if it is below my minimum tx relay fee?_

**Mike Schmidt**: Next question from the Stack Exchange, "Will my node relay a
transaction if it is below my minimum tx relay fee?"  Murch, you answered this
question, so I'll let you answer this question.

**Mark Erhardt**: All right.  So, if you send a transaction, the first thing you
have to do is build that transaction and convince your own node to accept it.
And if you're building a transaction that your own node doesn't like, it'll also
not forward it to anyone else, because we will only forward stuff that's in our
own mempool.  So, the question here was, "Can I use my node to send something
that my own node wouldn't accept?"  And the answer is no, because you have to
configure your node to accept your transaction first, and even then it'll only
forward it to other nodes that also have the same non-default configuration.

In this case specifically, sending something below the minTxRelayFee would mean
that you have to have a peer, or multiple peers, that also accept transactions
below minTxRelayFee, and then it has to propagate through the network until it
finds a miner that also has a below minTxRelayFee configured.  And then, you
have to convince that miner to mine it, even though the economic incentives are
not good, because in the last year, we've always had something like 70 blocks'
worth of transactions waiting that paid at least 1 satoshi per vbyte (1 sat/vB).
If you're paying less than 1 sat/vB, naturally your transaction would queue
behind that.

_Why doesn't the Bitcoin Core wallet support BIP69?_

**Mike Schmidt**: "Why doesn't Bitcoin Core Wallet support BIP69?  Murch, this
is another one that you answered.  Maybe we can start with what is BIP69?

**Mark Erhardt**: So, BIP69 is a BIP that proposes that the inputs and outputs
on transactions should be lexicographically ordered.  I believe the inputs are
by amounts and the outputs are by output scripts first, or something.  The
problem with that is there's certain applications for bitcoin transactions that
require other orders.  So, for example, if you want to have a SIGHASH_SINGLE,
where an input only commits to one specific output, obviously those two have to
align.  Or, there might be a hidden other situation below what is apparent in
the transaction that might make people choose a different transaction input or
output order.  So overall, this BIP has always been a little controversial with
a few people saying that it shouldn't be adopted in the first place.

If it were adopted by every transaction, it would be great.  It would remove a
lot of fingerprints in the sense that everybody is obviously just using this
canonical order and nobody would stick out for using a different order.  But if
we are looking at what people are doing today, there's a well-known hardware
wallet that just sorts the inputs by age, which is the worst possible, because
it's so obvious that they are building this transaction.  There are some that
keep them in the order they picked them from the mempool, and that might also
reveal some things, like for example, indicate which one is the change output or
not.  Either way, the recommended way of building a transaction is that after
you finish picking all of your inputs and deciding all your outputs, is that you
shuffle all of it before you finalize the transaction.  And the reason for that
is if you shuffle stuff, if another pattern seems to be there that might or
might not also be caused by just having a random order, and if everyone looks
random, the occasional ordered input may at least have a small likelihood of
having been achieved randomly.  Overall, please just shuffle your inputs and
outputs.  Don't use BIP69.

_How can I enable testnet4 when using Bitcoin Core 28.0?_

**Mike Schmidt**: "How can I enable testnet4 when using Bitcoin Core 28.0?"  And
Pieter Wuille answered with two different configuration options that you can
use.  You can set chain=testnet4 or you can set testnet4=1.  So, play away on
testnet4.  Murch, you want to shill testnet4, or are we good?

**Mark Erhardt**: Well, we rolled out a new testnet with the v28.0 release, so
it's been officially supported for a few weeks now.  Some of the more
enthusiastic community members had already implemented support on their other
software stacks, and so testnet4 is actually already, I want to say something
like 50,000, 60,000 blocks in.  I think testnet4 could currently use a little
more love by miners.  It looks to me like there might only be a single miner
currently collecting almost all of the blocks.  So, if you're testing some
mining hardware or just want to do something for fun that you don't expect to
get money for, maybe point your miner at testnet4 and mine some testnet4 coins
that you can then use for testing or distribute to other people.

The big advantage, or the main point why we rolled out testnet4 is to get rid of
the block storms vulnerability.  In testnet3, there was a quirk that the minimum
difficulty block that you were allowed to mine, after 20 minutes had passed from
the prior block, could reset the difficulty to the minimum difficulty if it was
done on the last block of the difficulty period.  And that, of course, then made
it super-easy to mine a ton of blocks very quickly.  This doesn't work on
testnet4 anymore.  There seem to be a lot of minimum difficulty blocks being
mined right now on testnet4.  Every time when there's a full difficulty block
mined, someone seems to churn out six or so testnet4 blocks with minimum
difficulty immediately.  So, if you want to get in on the fun, take a good look
at the BIP, or just throw your testnet4 configuration into your config file and
you can get going immediately.  There's also several faucets already, so it
shouldn't be too hard to get coins.

_What are the risks of broadcasting a transaction that reveals a `scriptPubKey` using a low-entropy key?_

**Mike Schmidt**: Last question from the Stack Exchange, "What are the risks of
broadcasting a transaction that reveals a scriptPubKey using a low-entropy key?
This is slightly rephrased from the original question on Stack Exchange which
was, "Bitcoin Puzzle 66: Is this unconfirmed transaction archived anywhere?"
Maybe a bit of backstory.  I hadn't heard of these puzzles and maybe others have
not either.  So essentially, someone, I think it was nine years ago or so,
locked a bunch of bitcoins into outputs secured by a varying amount of private
key entropy.  There's 160 of these puzzles with increasing difficulty to find
the private key.  So for example, of these 160 puzzles, in puzzle 1, the range
of possible keys was one key, so that puzzle was quickly solved.  Likewise,
puzzle 2 had two possible keys, puzzle 3 had four keys, puzzle 4 had eight
possible keys, etc, all the way up to puzzle 160, which I think has
2<sup>160</sup> possible keys.  And so, people have been playing around with
these puzzles trying to essentially grind bitcoin, as opposed to mining bitcoin.

As of today, 79 out of these 160 puzzles has been solved and 52 bitcoin been
paid out.  And the reward for that last puzzle is 16 bitcoin.  So, the reason
this got to the Stack Exchange is it seems someone had solved this puzzle 66,
having brute forced the 66th private key.  But when this person went to claim
the reward, it appears that their transaction accidentally revealed the
scriptPubKey which, because of the way these puzzles are structured, revealed
essentially information publicly that reduced the entropy to the point where a
bot, and there are these bots that watch the mempool for these sorts of
vulnerable transactions, saw the transaction and somehow quickly grinded the
private key using that additional information revealed in the original
transaction, created a conflicting transaction to claim the reward with a much
higher feerate, and claimed the 6.6 BTC reward for itself.  Sorry, Murch, I see
you have your hand up.

**Mark Erhardt**: Yeah, so in this question on Stack Exchange, they alluded to
accidentally revealing more information about this private key, and it wasn't
clear to me how that had happened.  I'm wondering whether they're just talking
about publishing the transaction on the open mempool versus having a miner
directly work on putting it into a block without broadcasting it to the main
mempool.  Because even if you have a pubkey, it's not clear to me why it would
be much easier to find a private key from that, because clearly you still have
the discrete log problem to solve.  So, I guess you know that it's a 66-bit
private key and that helps you, but if you know that in advance, why wouldn't
you just search for the 66-bit private key?

**Mike Schmidt**: Yeah, it wasn't clear to me either, although I saw there was a
Stacker News item and there's also a Bitcoin Talk thread.  And I think somewhere
in there, it was mentioned that this revealing reduced the entropy to 33 bits,
which is why it was grindable in a few minutes, I guess.  But I don't
understand.

**Mark Erhardt**: I guess it might be faster to do because you no longer have to
check whether the public key converts to the specific address.  So now, you only
have to check private key to public key, which might just be faster, but it's
not clear to me why it would be so much faster.  Anyway, if somebody knows about
that, how about you drop a comment in Twitter under this Spaces and let us know.
Or if you're here, raise your hand.

_Core Lightning 24.08.2_

**Mike Schmidt**: Releases and release candidates.  We have Core Lightning
24.08.2.  One notable feature I saw was that Core Lightning (CLN) now remembers
and updates channel hints across payments, which was a PR that we discussed on
this show in Podcast #324.  And then there were a couple of fixes.  One was a
crash error with gossip larger than 4 MB, and one was a crash error related to
erroneous timeouts.  So, update to the latest CLN.

_Eclair #2925_

Notable code and documentation changes.  If you have questions for Elle, Andrew,
Murch, or myself, feel free to request speaker access or drop a question in the
thread here.  Eclair #2925 adds an rbfsplice command that RBF fee bumps a
splicing transaction that is not confirming in a timely manner.  So, since
splicing requires participation between the two channel parties, there are two
messages exchanged to coordinate the RBF fee bump.  There's this tx_init_rbf,
and then the other party responds with the tx_ack_rbf.  And note, this feature
is not available when using zero-conf channels because of the potential to lose
funds.  Anything to add there, Murch?  All right.

_LND #9172_

Elle, are you still with us?

**Elle Mouton**: Yeah.

**Mike Schmidt**: Do you want to talk about LND #9172, and this is related to
the mac_root_key?

**Elle Mouton**: Yeah, sure.  So, basically, it just allows you to already start
producing macaroons before your LND node has even started or synced or has its
own seed, or whatever.  And so, you basically provide LND with the root key that
you want to use for your macaroon DB, and basically your macaroon DB, you can
think of it as the private key, the thing that it's going to go validate -- by
the way, macaroons are fancy authentication tokens, so fancy cookies for LND.
So basically, the root key is the thing you go and check the macaroon signature
against, and you can basically tell LND, "Okay, please use this as your root
key", instead of it generating its own one.  And then, you can then create
macaroons without having to wait for LND, on the first startup of LND, wait for
it to sync to the chain and sync to the wallet, because previously we had to
wait for all of those things.

**Mike Schmidt**: I saw in some of the writeup two use cases where this would be
useful.  One would be, I think, testing scenarios where you want some
determinism to be able to test against.  And then, the second one is in a remote
signing setup where there's maybe two different LND nodes using something like
VLS, or some other remote signing protocol, to coordinate between the two.  Do I
have that right now?

**Elle Mouton**: Yeah, exactly.  So, for the reverse remote signer case, instead
of needing to wait for the node to sync before generating a macaroon, before
giving the other node the macaroon it needs to connect to the first node, now
you can just immediately get that macaroon and give it to the node that needs it
without waiting for the sync, yeah.

**Mike Schmidt**: Thanks, Elle.

**Elle Mouton**: No problem.

_Rust Bitcoin #2960_

**Mike Schmidt**: Last PR this week, Rust Bitcoin #2960, which separates some
cryptographic functionality into its own Rust crate, specifically the
ChaCha20-Poly1305 encryption that is used in BIP324 that we talked about
earlier, the encrypted traffic.  Yeah, so not only can that same encryption be
used with BIP324 for encrypting communication between Bitcoin nodes, but the
specific motivation for this split in this PR is that the payjoin project is
looking to specifically use the same algorithm for some of its communications.
So, Rust Bitcoin thought it would make sense to pull it into its own crate.
Anything to add, Murch?

**Mark Erhardt**: I think it's very cool that more implementations are
implementing v2 transport, and I can't wait when this is broadly adopted and we
might eventually be able to even have an authenticated connection via the
encrypted transport protocol, for example, to use between a light client and
your own phone node at home and stuff like that.

**Mike Schmidt**: I don't see any request for speaker access or questions, so
thank you to our special guests, Andrew and Elle, thank you to my co-host as
always, Murch, and congratulations again on Localhost, and thank you all for
listening.  We'll see you next week.

{% include references.md %}
