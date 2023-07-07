---
title: 'Bitcoin Optech Newsletter #255 Recap Podcast'
permalink: /en/podcast/2023/06/15/
reference: /en/newsletters/2023/06/14/
name: 2023-06-15-recap
slug: 2023-06-15-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Gloria Zhao, Ruben Somsen,
Josie Baker, Matthew Zipkin, and Joost Jager to discuss [Newsletter #255]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/72428283/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-5-21%2Fe52157e5-4248-0bdf-eb5b-fb4557e33214.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #255 Recap on
Twitter Spaces.  It's June 15th and we have a nice lineup of news items as well
as special segments.  We'll be talking about the taproot annex today; we'll be
talking about silent payments; we're going to talk about our Waiting for
confirmation series, talking about DoS protection; we have a Bitcoin Core PR
Review Club that we'll get into; and then Releases and PR updates at the end of
the newsletter.  Jumping right into it, let's do some introductions.  I'm Mike
Schmidt, contributor at Optec and Executive Director at Brink, where we fund
open-source Bitcoin developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin projects
full-time.

**Mike Schmidt**: Tidwell?  All right, we'll skip Tidwell.  Ruben?

**Ruben Somsen**: Hey, yeah, I've been working on silent payments for the past
half year with Josie.

**Mike Schmidt**: Josie?

**Josie Baker**: Hey, Josie, I work on Bitcoin Core and Bitcoin Core-related
projects.  Yeah, like Ruben said, I've been working on silent payments, working
on writing the BIP, and also the implementation for Bitcoin Core.

**Mike Schmidt**: Joost?

**Joost Jager**: Hey, I'm Joost.  I've been working quite a bit on LND and the
Lightning space in general, and recently also moving a little bit into the L1
space, seeing what that's all about.

**Mike Schmidt**: Excellent.  Well, thank you all for joining us.  We'll jump
into the newsletter and we'll just go chronologically.  This is Newsletter #255.

_Discussion about the taproot annex_

The first news item is discussion about the taproot annex.  And I think it was
episode 253 of the podcast, Joost, where we were discussing the transaction
relay over Nostr topic and how relaying transactions on Nostr could afford some
benefits in terms of resiliency and also potentially more liberal rules around
relaying transactions or packages of transactions.  And one example that came up
during the conversation was the relaying of non-standard but consensus valid
transactions using the taproot annex field, which was introduced with taproot
activation, and the intention of the annex was for future soft fork use.  Now,
Murch, before we have Joost explain his mailing list post, what is the taproot
annex?

**Mark Erhardt**: Yes, so the taproot annex is an input field that is basically
an optional additional input field.  Naturally, we can't just add input fields
to the regular transaction serialization, that would be a consensus change, so
it's serialized into the witness stack.  But you can think of it as basically a
field like the sequence on the input, and so far it's unused.  The idea is that
we can use it in future consensus and protocol upgrades.  There's now some
proposals floating around how it could be used.  Yeah, that's pretty much it.

**Mike Schmidt**: So, Joost, maybe now that we know what the taproot annex is at
a high level, and we sort of know the background of the discussion, what content
from your mailing list post do you want to jump into in terms of how potentially
this taproot annex could be used, and what sort of use cases; maybe you want to
jump into that?

**Joost Jager**: Yeah, indeed.  There's two ways to approach this.  For one,
it's very technical, like what could the format be?  What are the concerns with
enabling the taproot annex?  But indeed, as you say, I think the use cases are
really important.  I jumped into this quite naively; initially I thought, okay,
let's just enable it and everybody can use it for whatever they want.  But
obviously, smarter people had thought for a long time about stuff like that
already, which I discovered in maybe the past two weeks in replies that people
patiently posted to my mailing list posts.  But the main driver for me to be
very interested in this is simulating covenants with pre-signed transactions.
And this is an idea, I don't know who came up with this originally, but I do
know that Bryan Bishop has his Python repository where he creates a time-locked
vault using pre-signed transactions.

So the idea is that you move funds into a special address, and this address can
only be spent from using a key for which the private key has been deleted.  So,
the only way to spend those funds is using prepared pre-signed transactions that
you need to hold on to, and those are the only ways that you can spend that
coin, and those pre-signed transactions have outputs with certain conditions
that create the logic of the vault.  So in case of a time-locked vault, what you
do is you create the vault using a transaction, and then you've got two
pre-signed transactions.  So, one allows you to move those funds into, let's
say, cold storage, like a super-safe storage location; and the other spend path
allows you to un-vault, and un-vaulting means that you will get access to those
coins, but only after a timelock, so not unlike a physical vault where there is
a time lock that you need to wait out in order to access what's inside the
vault.

There are some problems with this.  So, one is that you are creating signatures
using a key that you're deleting, but you have to be very sure that you're
deleting that key.  So this part, I'm not really proposing to solve using the
annex.  But what I think is very interesting about the annex is that it allows
you to save those signatures of the pre-signed transactions into the full
transaction itself.  So normally, if you create those pre-signed transactions,
there's data that you cannot lose.  You need to hold on to that because if you
lose that, and this is the signature in particular to spend the vault output, if
you lose that, you lose the funds.  And the idea of storing it on the chain, of
course, is to leverage Bitcoin's superior robustness properties so that you
cannot lose that information.

You could, for example, try to do this with an inscription.  The only problem
there is that you create a circular reference because you want to back up the
data of those pre-signed transactions into the transaction that they spent.  And
because the txid, when you use an inscription for example, is depending on the
actual content that you inscribe, it means that the pre-signed transaction is
spending from a txid that is dependent on the pre-signed transaction itself.
I'm not sure if maybe I should stop here to see if people are still following
along here, what the problem is of trying to back up those signatures on the
chain.

**Mike Schmidt**: Go ahead.

**Mark Erhardt**: Yeah, I have a question here.  So if we put data in the Annex,
it is irrelevant for script validation, but the input signature still has to
commit to that.  So the signature -- oh, I see, yes, never mind!  The signature
obviously does not change the txid, and therefore you don't get the problem that
you have with the inscription.  I see, I answered my own question, sorry.

**Joost Jager**: Yeah, so that's the idea, and I think so far I haven't seen
another way to do this.  So, it seems this is a unique property of the annex
where you can store data about child transactions, in this case pre-signed
transaction signs with an ephemeral key; you can store them without creating
that circular reference.  So, this is the main use case that I have in mind,
like a way to get covenants.  So it's not only for vaults, but you could also
imagine other use cases of covenants that you can simulate, or maybe you could
also say implement, using these pre-signed transactions and making them safer
than they used to be by storing the critical data of those pre-signed
transactions on the chain itself.

**Mike Schmidt**: Now if those signature pieces of signature data --

**Michael Tidwell**: Hey, Joost, I have a question if I may.

**Mike Schmidt**: Go ahead.

**Michael Tidwell**: You mentioned these are going to be for deleted keys, and
I'm wondering how would you ensure the key is deleted?

**Joost Jager**: Yeah, well that's the other part of using pre-signed
transactions that makes it potentially not as secure as using a real covenant.
So, this is assuming that you've got the signature itself secured, then there
can still be worries about, okay, is the key actually deleted, or is it held
onto by someone; or was the ephemeral signer compromised?  And a way to mitigate
this, and I think this is also in Bryan's prototype already, is to have multiple
of those ephemeral signers.  And using MuSig2, you can keep the -- in terms of
chain space, combine multiple signatures.

So what you could do is, for example, you've got a hardware device that does
ephemeral signer, and then maybe there's people or companies offering ephemeral
signing services out on the internet that you can use to create a key, sign
using that key and get the key deleted again.  And if you combine all of those,
it doesn't matter if one of them holds onto the key because the aggregate key is
still ephemeral.  So this would be a way to mitigate this to some extent.

**Mike Schmidt**: Joost, are there other use cases that you had in mind for the
annex, or was there feedback on the mailing list or elsewhere about things that
folks were potentially going to use the annex for?

**Joost Jager**: Yeah, I think the other bigger one, but it doesn't interest me
personally so much, is just that it can make inscriptions more efficient,
because currently with those inscriptions you always have a commitment
transaction that's spent to a specific output, and then there's the reveal
transaction that inside the tapscript is going to reveal the actual data of the
inscription.  And with this, that would be much simplified, because basically
any taproot spend you can accompany by arbitrary data, so there's not a commit
reveal, and this means that the total number of bytes onchain to store the same
data goes down, so more block space left for other things.  But this is not
really a functional improvement, it's mostly an efficiency gain.

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: I have a follow-up question on the re-vaulting with your
proposal, annex vault.  So, if I re-vault a payment because, I don't know, it
was flowing out, but you -- sorry, you said there's a way to get access to the
funds or maybe I'm -- okay, what I'm trying to do is compare it to the recent
OP_VAULT proposal by James O'Beirne.  So, if you have a vault here, it only has
one path to spend, right?  It can only go to one specific address, which is the
one that you have pre-signed the transaction for; is that right; single path?

**Joost Jager**: Yeah.

**Mark Erhardt**: So, wouldn't the key for the address that you're paying to
become your new single point of failure -- so, what's the difference between
that and holding the funds in that destination address in the first place,
because if you lose access to the destination address, the attacker just needs
to wait for the transaction to go through?

**Joost Jager**: So you mean the key, the ephemeral key becomes the single point
of failure, is that what you mean; or the output of that pre-signed transaction?

**Mark Erhardt**: The ScriptPubKey that you're paying to.

**Joost Jager**: With the pre-signed transaction you mean, or the vault?

**Mark Erhardt**: Correct.

**Joost Jager**: The vault, okay.  Yeah, well you could say it, but the idea is
that this key is deleted, right?  So it's not the same as keeping it in your
wallet, where you also have that key stored somewhere.

**Mark Erhardt**: Sorry, I think we crossed the wires; the destination address
where you receive the funds from the vault with the payout transaction.  If that
is unchangeable and you have no other path to spend, essentially you're in a
single point of failure.  So it's not clear to me how this is an improvement.

**Joost Jager**: Yeah, now I remember.  I think when I initially explained this,
like ten minutes ago, I was talking about two spend paths, but let me correct
that.  I think the most basic idea is that there is one spend path from the
vault to un-vault, and the output of that is time locked.  And then you're
saying if the destination is fixed, you just wait out a timelock and then you
have access to the funds anyway, so it's just a nuisance.  But the way this
should work is that if you do this un-vault and there is a timelock that allows
you to spend it, while you're waiting for that time to expire, you can also use
a second pre-signed transaction that sweeps those funds that are now pending
release, sweeps those to a more safe destination.

**Mike Schmidt**: Does that make sense, Murch?

**Mark Erhardt**: Yeah, I think we're getting a little too far into the weeds.
I guess my question would be how a proposal that is based on an annex vault
would compare to the OP_VAULT proposal.  Maybe that's the question that I'm
really trying to ask.

**Joost Jager**: I see.  So, I'm no expert on the OP_VAULT proposal.  I think
the general idea is sort of the same, like if you create a vault using the
annex, there's a timelock path and there's a recovery path.  So, in case you see
an un-vault operation that is not authorized or you didn't un-vault that, you
can rescue those funds and sweep them to cold storage.  I think in that regard,
they are similar.  The difference, though, is that with OP_VAULTS, you don't
need to worry about these ephemeral keys that really need to be ephemeral.

**Mike Schmidt**: Joost, can you comment a bit about some of the considerations
that Greg Sanders brought up in terms of things that he's been experimenting
with with LN symmetry, and considerations around coinjoin and multiparty
protocols that came out of that?

**Joost Jager**: Yeah, so I don't know that much about LN symmetry, but I do
understand the problems brought up with coinjoins.  And this is assuming that
suppose taproot, or suppose the annex would be standard without restrictions.
It means that anyone could add an annex to inputs that they sign.  And one of
the ways to create problems with this is if you're in a coinjoin type of
protocol and you are the last one to sign, everybody has signed already, the
feerate has been determined, and then you sign, but you also add a very large
annex to the transaction, and you sign for that, and then you publish.

This means that the transaction, like everybody was counting on a certain
feerate, and now all of a sudden that feerate is much, much lower because you
added such a big annex to the input.  And then the coinjoin transaction does not
confirm.

**Mark Erhardt**: To be clear, I think this could be done by any participant in
the protocol by just malleating the transaction after it was signed by everyone,
because the annex is only committed to by the signature on the same input.  So,
the other inputs do not commit to annexes of, well, each annex is only committed
to by the same input, so there's only first-party malleability controlled by
every single signer.

**Joost Jager**: Yeah, yeah, that's true, but I think that one is easier to do
something about.  So, let's say the coinjoin transaction is finished and one of
the participants creates a different version of that with an inflated annex and
just publishes that.  What I understand for this is that currently there is no
replacement of such transactions.  So, even though if another participant would
come up with the same coinjoin transaction without that annex, which
consequently has a higher feerate, Bitcoin Core is not going to do the
replacement; it holds on to the first transaction that it sees.  And I think
there's an older PR that allows for replacement of transactions that have the
same txid, but a different witness, if those increase the feerate of the
transactions, so basically making the replacement, or the mempool, more
incentive-compatible, because you would have more space for other transactions.

**Mark Erhardt**: Right, but you might get a cheap broadcast there if the fee
increase isn't at least one in relay transaction fee step.

**Joost Jager**: Yeah, and then the proposal in that PR is just to require a
minimum reduction in the witness size so that you cannot reduce it by one byte
each time you broadcast.

**Mike Schmidt**: Gloria?

**Gloria Zhao**: Can I interject?  Yeah, so I think Murch already brought up the
problem with the PR, which actually this is mentioned in the post, our policy
post later.  But yeah, RBF currently requires you to pay "new fees" to pay for
the bandwidth of the replacement transaction, and you can't do that if you're
not changing the txid because you're going to have the same inputs and outputs.
I think with the reduction, there's a proposed rule of, if the transaction is
decreasing by enough size, aka the feerate goes up by enough, some threshold
where we're like, maybe this is okay, because you would only be able to do this,
I don't know, log in times, and that would be okay, but then you would still
have the same pinning problem where you can have one of the participants
broadcast a version of the transaction with a stuffed witness, but such that
there's no way for you to reduce it by enough.  I mean, you'd have to look at
the numbers, but you might have a similar pinning problem.

**Mark Erhardt**: Well, since we only have first-party malleability here and not
third-party malleability, it would only be the original signer of that input
that has influence on being able to -- well, okay, if they first signed a
smaller transaction.  Yeah, I get you, never mind.

**Joost Jager**: But Gloria, do you mean that they stay just below that minimum
required reduction so that you cannot replace it with a smaller version?

**Gloria Zhao**: Yeah, essentially.

**Joost Jager**: Yeah, so they propose like 5% minimum, so if you make a 4.99%
then you cannot do the replacement and you're stuck with a slightly heavier
transaction there.

**Gloria Zhao**: Basically, yeah.  But then, they've also only stuffed it by a
little bit, so I don't know.  You'd just have to look at the numbers and see
what looks acceptable for both the application and the DoS thinking.

**Joost Jager**: Yeah, I think Greg also proposed, in addition to the 5% rule,
also always allow replacement by a input that has no annex, so that if you're
dealing with protocols that shouldn't involve an annex and somebody does add an
add annex, even if it's only 1 byte, you still always have one option to replace
it by a zero-annex version, so basically overruling the 5% rule there.

**Gloria Zhao**: Yeah, that sounds cool.  I think it's nice to finally have a
use case to think about for this witness replacement PR, because I think it's
been talked about for a few years, but it always boiled down to, well, does
anyone actually need this?

**Joost Jager**: Yeah, maybe they have something now.

**Mike Schmidt**: Ruben, I don't want to put you on the spot too much, but I was
curious if you had any feedback on this discussion.

**Ruben Somsen**: Yeah, I had a couple of thoughts.  So, one thought I have
is that if it were possible for every input to sign the same annex or the same
annex data, then you don't have the availability problem, because everybody on
the input side would have to agree that would be a consensus change, but that
would be something that could be maybe considered here.

The other thing or question I have for you is, I haven't fully read up on the
mailing list discussion so I don't know the full details, but I'm wondering if
you put the signature data in the annex, doesn't that allow anyone to publish
your pre-signed transaction?

**Joost Jager**: Yeah.

**Ruben Somsen**: And if it doesn't, then I'm also wondering, well then
there still must be some data that must be remembered in order to be able to
publish it, so you still have this backup problem.

**Joost Jager**: Yeah, I understand what you're saying there.  So it could, for
example, be a pre-signed transaction that is a 2-of-2.  So one is an ephemeral
key, and then it still needs to be authorized using another key that you need to
remember.  But it could, for example, be the same key that you used to deposit
into the vault.  So I've also been thinking about, what would be an interesting
demo that is the minimal version that shows this, so not even a vault, just one
pre-signed transaction path?  And I think what it is, is suppose you've got a
wallet with coins, you take one of those coins, you put them into an address,
and you can recover it from an address using a pre-signed transaction, and the
only thing that a pre-signed transaction does is add a CSV log.  And you could
call this like, let's say, a Bitcoin hodl protection.

So, you've got your wallet and you locked all your coins in a way that requires
you to first broadcast the pre-signed transaction, wait out the CSV delay, and
only then you can move them to another location to protect yourself from panic
selling, for example; let's say this is what you want to use it for.  So in this
case, for all the non-ephemeral keys, you could always use the very same key
that you used to deposit into it.  So you've got a key, you deposit into it,
then you use that same key to sign for broadcasting the pre-signed transaction
to start the timer ticking.  And then the output of that is also locked to that
very same key, which is still your hot wallet key.

**Ruben Somsen**: Yeah, I see that.  That pretty much answers my question,
or at least the 2-of-2, I can see that being a solution where you need a second
signature to actually publish a transaction.  And the other idea, I can see how
that's not a problem in terms of anyone putting that CSV transaction onchain.

**Joost Jager**: Yeah.

**Mike Schmidt**: I think in the interest of time, we should wrap up here.
Joost, any parting words before we move on?

**Joost Jager**: I know there's one small thing that I found also interesting, I
think also suggested by Greg or maybe he got from someone else, is to prevent
these problems with people abusing the annex, is to create a policy rule that
just not just allows every annex to be used, but requires people, every input,
to opt into this by committing to an empty annex if they don't need an annex.
And this is something I find quite interesting.  You relax it a little bit less,
you still allow people to add annexes, but you need every input to at least
commit to an empty annex to signal that, okay, we're aware of the risks here.
So if you are using coinjoin or dual-funded Lightning channels, not every input
will do this, meaning that the transaction remains non-standard, but it doesn't
rule out the implementation of these vaults, for example.

**Mike Schmidt**: Murch, any comments before we move on?

**Mark Erhardt**: I think that I'm curious to see how much weight that would add
to transactions.  Of course, there's a little bit of a problem just around the
whole thing that other inputs don't commit to annexes.  If that had been
designed differently in the first place, this would be a lot easier.  So, yeah,
I think I'll be looking at the debate as it progresses, but I don't really have
a strong opinion in any way right now.

**Mike Schmidt**: For anyone that's curious, there is quite a bit of discussion
on the mailing list, some back and forth.  So jump into that if you're curious
about what Joost is talking about here.  Joost, thanks for joining us.  You're
free to stay on, or if you have other things to do, you can drop.

**Joost Jager**: All right, thanks for having me.

_Draft BIP for silent payments_

**Mike Schmidt**: Next news item from the newsletter is draft BIP for silent
payments, and we have the authors here, both Josie and Ruben, to talk about
their proposal.  I think maybe to kick things off, Ruben, can you summarize what
are silent payments, and then we can kind of go into some of the trade-offs and
go from there?

**Ruben Somsen**: Sure, yeah.  So, it's really an old idea that has been around
for a long time to sort of have a way to get people to create basically the
address for you in such a way that nobody can recognize onchain what the address
is.  So, maybe to make it a little bit more simple, basically you have a single
address and then anyone can use that address to derive a different address and
pay you to that different address onchain.  And this basically allows a much
simpler payment flow where today, if you want to pay someone repeatedly, you
have to ask them for a fresh address every time, if you care about privacy.
Otherwise, you could reuse the same address all the time, but now everybody can
see exactly how many coins you've received.

So, this proposal essentially allows you to have a single address, but still
onchain there'll be fresh addresses, new addresses every time someone pays you,
and only the sender and recipients know about these addresses.  So it really, in
terms of user-friendliness of how Bitcoin works or how you make Bitcoin
payments, I think it's a big step forward where you can basically have a single
address in a privacy-preserving way.

**Mike Schmidt**: And, Ruben, am I giving out this address to -- am I making
this public for anybody to use, or am I giving out an address for each of my
counterparties and then they use that address for them to generate additional
addresses?

**Ruben Somsen**: Yeah, no, it's really one address.  So you could have your
Twitter profile or something, you could have your single address, everybody can
just see that address and then send money to it and you'll just receive the
funds and everybody will be using the exact same address.  So that's the nice
thing about it.  You just have one address and you can give it out to everybody
and everybody can pay you and none of the people that are paying you can see
that other people pay you as well.

**Mike Schmidt**: And this is an SP prefixed address, correct; so it's not a
normal Bitcoin address?

**Ruben Somsen**: Yes, it's a different status format.

**Josie Baker**: I'd add one thing here to your question about, do I just
give it to everybody or do I hand it out per counterparty?  And I think one of
the things that's nice that we added to the BIP and the implementation is this
concept of labels, where you can have your one single sign-up payment address,
and like Reuben said, you can post that anywhere that people can easily discover
it.  But you can also add a label to that, and that label is a way of kind of
identifying where you're getting that payment from.

So this would allow you to use it in that scenario like you just described,
where maybe I do want to actually have these reusable addresses, but I want to
know who's paying me on the other end of it.  And so then, I could add a label
to each of these addresses that I hand out.  So, you could imagine a scenario
where you're handing out these addresses to receive payment for work and you
want to know who's paid you.  Or, let's say you're an exchange and you want to
give every single customer on the exchange a static address, unique to that
customer, that then they can pay you and you know, "Okay, hey, this customer
paid me".

So the tl;dr is it's both, right?  You can have this static address that you
just publicly post somewhere that anyone can use, but then you could also add
this label concept to it as well, which I think opens up the use cases quite a
bit for silent payments.

**Mark Erhardt**: I kind of want to follow up on the, "Can tell who paid you".
So just to be clear, as I understand it, the label allows you to modify how you
receive the funds; and if you give out separate labels for everyone, you might
have an indicator who you gave that label to, but strictly speaking you actually
do not learn anything about the sender?

**Josie Baker**: Yeah, that's correct.  The label only has meaning to you, so
you add some meaning to that label, and then you hand it out to someone, but you
don't really know anything beyond that.  It's completely on the receiver side.

**Mike Schmidt**: A couple of follow-up questions, one for Josie here.  You guys
published the BIP, there's been some discussion about this idea for the last
year or so.  I'm curious what you think the most common misconception about
silent payments is in getting feedback from the community?

**Josie Baker**: Yeah, I think the biggest misconception, and sometimes it's a
misconception and also a criticism, is that this doesn't work for mobile
clients.  That was feedback that was brought up early on, I think March 2022,
some people raised that point.  And basically what that boils down to is,
Ruben's mentioned this as a very old idea of these reusable payment codes, and I
would group all the proposals that have existed as either schemes that use
notifications, onchain notifications, and schemes that don't.  And silent
payments, as far as I'm aware, is one of the first ones that doesn't use
notifications.  And the way we get away with not using notifications is we have
to scan the chain.

So for a full node, this is not a problem.  The job of a full node is to look at
every new, incoming transaction in every block and decide whether or not it's
valid and whether or not to add it to its local longest chain.  For a mobile
client, you don't have access to every transaction in every block and you don't
want access to every transaction in every block.  So the criticism with sound
payments was, well if you're switching to something that requires scanning, it's
not going to work for mobile clients.

I'm pretty confident that it will work for mobile clients, but with the
trade-off that it's going to require more bandwidth.  So, I think we wrote a
pretty nice section on the BIP to address this of like, "Mobile client support
is going to be tricky, but we definitely think it's possible".  And I think the
clearest path forward is looking how we can do this with BIP158.  BIP158, I
don't think it's seen a lot of adoption in wallets right now, so that's kind of
an open question too, like how well does BIP158 work with mobile clients?  But
there's quite a few other ideas that we're kicking around.

I think there's definitely a path towards getting something that works with the
Electrum protocol, but ultimately it's going to come down to a bandwidth
trade-off.  You're going to have something that works with your mobile wallet in
a very privacy-preserving way, but with the cost of using more bandwidth.  And I
think a lot of the mobile wallets today are either backed by their own full
node, which then, in my mind, it no longer classifies as a mobile wallet, or
they're making some sort of trusted trade-off with some other counterparty to
give them that data.

So with silent payments, I'd say it's not much different.  We have to look at,
are we going to trust someone to do the scanning for us, whether it be my own
node; or at the expense of more bandwidth, can I actually run a mobile client in
a privacy preserving way?  I think that's the biggest one.  I don't know, Ruben,
if you have any other ones you want to add or any color to add to that?

**Ruben Somsen**: Yeah, no, I agree that that's the one that a lot of people
come back to.  Yeah, I will say, Josie ran the numbers, that's kind of
interesting to add here as well.  Basically, what we came up with is that it's
got to be -- so essentially, there is this sort of trick we can use to minimize
the amount of data that you need as a light client.  And that trick is basically
that you do not need to care about transactions that were fully spent, because
if a transaction was fully spent between the period that you last scanned and
the next time you're scanning, then that's obviously not a transaction to you
because you're not the one who could have spent it because you didn't learn
about it yet.

So with that in mind, if you scan once every three days, then with today's
taproot usage, that would be roughly 50 MB per month.  And if we assume that
everybody's using taproots and every block is completely filled with taproot
transactions, then that would be roughly 150 MB.  And if you only scan once
every month, this goes down by roughly 3X.  So then it would be even in the
worst case scenario, you would have to download an additional 50 MB per month,
and that is not a lot, I think.  But scanning once a month obviously is not
ideal in terms of, you will know that you got paid, but you have to -- the more
often you scan, the more bandwidth you would end up using.

But you can imagine that you only scan when you're at home or from Wi-Fi, or you
do scan just once a month.  And we have ideas to have out-of-band notifications
where when somebody pays you, they can send you a notification and say like,
"Hey, take a look at this specific transaction, and if you do, you'll notice
that you actually got paid".  And so, this is a way to receive the instant
notification out-of-band.  But if that out-of-band notification fails for
whatever reason, you still have to fallback of scanning once a month.

So I think we've got a pretty good, at least theoretical, sort of framework as
to how to do the light client support.  So I'm pretty optimistic about that, but
I do agree it's some extra work and it needs to be worked out.  So, it's not the
simplest way to do a light client, but in general that is what is needed to do.
I think that's the general trade-off that you get.  If you want to be as
privacy-preserving as possible, that tends to come with certain trade-offs and
that's usually inevitable.

**Mike Schmidt**: Do you guys envision this as something, when the adoption will
be rolled out, in terms of certain wallets will support send and certain wallets
will support receive; or do you see that being bundled together and that a
wallet would implement both, similar to what we've seen with like bech32
adoption?

**Josie Baker**: Go ahead, Ruben.

**Ruben Somsen**: Oh, yeah.  I think that connects to one point I wanted to
make, so that's why I'm jumping in here.  I think the really nice thing about
silent payments is that sending support is super-easy to implement.  Literally,
you're already using your private key to sign the transaction, and then you use
that same private key to generate the silent payment address that you want to
pay to.  And so, I think we're going to see relatively broad sender support, and
I think that is ultimately the important thing for adoption.  You want as many
wallets to support sending as possible.  And then if you want to receive silent
payments, then you know many people can actually send them to you.

I think the sender side is sort of where the bottleneck is in terms of adoption.
And if you contrast that to the onchain notifications, the sender supports for
onchain notifications is actually quite a hassle because now, whenever you want
to make a payment to a new address, you would have to first make this
transaction that is unrelated to your actual payments, which is sort of a UX
nightmare and it's difficult to implement.  So, I think that's really been a
hassle for BIP47 adoption, I think, and sort of impediments.  And so I'm very
optimistic that we're going to see a lot of sender-side supports; and on the
receiver side, I think that's made it a bit of a different story, but maybe
Josie can fill that in.

**Josie Baker**: Yeah, this is something I'd really like to highlight, is I
think a really big benefit of this proposal is that they are completely separate
and you can implement them separately.  So, I imagine pretty much every wallet
out there, whether it's a light client or backed by a full node, could implement
sending somewhat trivially.  I've actually been working with a few people and
hacked together some proof of concepts of implementing sending, and we were able
to do it in an afternoon with very little code.  And it's not really invasive to
how the wallet works already.  You kind of piggyback off of how the wallet works
already and add these additional steps, which I think is really nice.  So sender
adoption, everybody should do it.

All right, for the receiving side, then we talk about, okay, if you're a wallet
that is backed by a full node, then I think receiving support is not going to be
too difficult because most of that work is going to be offloaded to the full
node.  So, if you're using a wallet that's backed by like Umbrel or one of these
node-in-a-box implementations, or if you're using a wallet that can be backed by
a personal Electrum server, like BlueWallet, Envoy, whichever else, then I think
receiving should be relatively simple because the full node is going to do the
work for you.

If you're a mobile-only wallet that is not backed by a full node, then I think
the receiving becomes a little bit more challenging, and that's where we've been
putting a lot of thought into how that might work.  But how I'd love to see this
roll out is we get something merged into Bitcoin Core, which then means anybody
who's using Bitcoin Core or is backed by Bitcoin Core, either by running a full
node or using an Electrum personal server, they get sending and receiving right
away.  And then we see a bunch of wallets implement the sending side, whether
they're mobile or otherwise; and while that's all going on, we keep working on
this engineering challenge of how do we make receiving on a mobile-only wallet
feasible.

**Mike Schmidt**: Murch?

**Mark Erhardt**: Yeah, I wanted to point out something else that maybe you guys
can also chime in on.  One of the issues that I see around notification
transactions are that they explicitly flag to any third party that's watching,
surveilling the chain, that something unusual is going on here; whereas silent
payments are of course indistinguishable from any other transaction with a P2TR
output.  And so, when you're sending a transaction that does the notification in
other protocols that have previously implemented static addresses, then you have
to be very careful about this announcement being completely separate from all
the other payments and transactions that you're building with your wallet,
because it creates a strong fingerprint that you're using this protocol and you
don't want to associate it with funds that are known to belong to you.  I mean,
it already reveals who the receiver is to everybody else, the notification
transaction, so it sort of leaks social graph if people can find out who the
sender was of the notification transaction.

So, I think the most interesting part on silent payments is actually this
absolute indistinguishability from regular payments in this protocol.  And yeah,
I think just getting rid of the notification transaction is what makes this
absolutely interesting.

**Josie Baker**: Yeah, I'd add something there because I think it's related to
this conversation of sending and receiving.  Like Murch mentioned, getting rid
of the notification transaction, I think, makes the UX of implementing this a
lot easier, because you don't have to worry about how to make that notification
in a privacy-preserving way, and that can be a leak if it's done incorrectly.  I
would also mention, and this is something that I got really excited about
initially, is there may be scenarios where I want to pay someone somewhat
regularly, but I don't want them to know that all those payments are coming from
me.  And when I say me, I don't mean me, my real identity, I mean me as an
entity, me as some sort of code.  And with these notification-based schemes, you
can tell that, so we make the notification transaction, and then if I get
subsequent transactions from the person who established that notification with
me, I know that it's all coming from the same entity.

They can get around that by generating a fresh notification every time for me,
but then that kind of exacerbates the problem of, how do I make sure that those
notifications don't leak anything about my UTXOs and whatnot.  So you kind of
have this tangled web of a problem of like, well, I don't want the receiver to
know that all these things are coming from me.  And then also, if I generate a
fresh payment code, I'm raising the cost of doing the transaction because these
notifications take up chain space.  And also, I have to worry about this problem
about the notification transactions leaking information.

I think this is another reason why silent payments is very easy to implement on
the sender side.  You can implement it on the sender side and you can just use
whatever management of your UTXOs your wallet is already doing, and you don't
need to worry about leaking any information via a notification.  And you can
also implement sending and send to a receiver multiple times without worrying
about them learning anything about you.  So, this is where I think silent
payments fits really well into a reusable payment code scheme that is really
focused on privacy, and all of that has to do with the fact that we were able to
do this without using a notification.

**Mike Schmidt**: So you have a draft BIP, I assume you're looking for feedback
there.  And technically-minded listeners and readers of the newsletter I'm sure
have seen it and will take a look at that.  For other folks, maybe in the
ecosystem, wallet or other software or library folks, would you be looking for
them to reach out to you and start working on proof of concepts, or are we not
there yet; and if not, maybe what other call to action would you leave people
with?

**Josie Baker**: Yeah, so the current state of things, we have the draft BIP
that's been opened, we sent a post to the mailing list, absolutely are looking
for feedback on the mailing list post and the draft BIP.  We've already got
quite a bit of activity on the draft PR, the BIP PR, which has been really nice.
My very next most immediate task is I want to add test vectors to the BIP.

Once the BIP has kind of settled into what I would say a semi-final state,
meaning there's going to be no major structural changes, which at this point I
don't really think there will be, because we have socialized this a lot already,
so I'm hopeful that most of the feedback we would get at this point would be
refining; but once we get the test vectors on there, you have a technical
document that says how to implement it, you have some testing vectors that you
can use in your implementation to ensure that you're implementing it correctly.
I would encourage anybody who's interested in this to start implementing it in
their wallet.

We've had a few people reach out and express interest and started working on
implementations, which is really exciting.  I'd love to see it packaged as a
library that can be included in the Bitcoin Dev Kit (BDK), and then really just
focusing on that sending support first; get sending support out there widely,
and then we can start working on the receiving.

The other thing that I'm working on is we have a draft PR open against Bitcoin
Core.  This is an implementation of the BIP.  So, if you'd rather read code
instead of the BIP, head on over to the PR and take a look.  As of right now,
the PR works, as in it implements the BIP.  I've got some unit tests that I'm
pairing up with my test vectors to make sure that it's all good to go.  The PR,
I'm still kind of reworking the style of it, just refactoring, making the code
look nicer, etc, but it works.  And so, if you want to compile that PR and
actually play around with it, reach out to me, I can give you my silent payment
address.

So I'm pretty happy with where we are.  The next thing will be just socializing
that the BIP is out there, reaching out to people who are building wallets and
engaging their interest in doing this.  So, if that sounds like you, yeah,
please reach out, Twitter, Nostr, however, I'd love to chat.

**Mike Schmidt**: Ruben, any final words?

**Ruben Somsen**: I just want to say it's been an absolute pleasure working with
Josie, it's been pretty nice.  He's got a ton of energy for this.  We've been
meeting every week, going back and forth on all the implementation details and
really hashing it out.  So, that's been amazing.  I've been very happy with this
process and I'm very happy where we are at right now with the BIP and the PR,
the draft PR in Bitcoin Core.  So, it's been great, definitely, I agree.  I also
think implementing the BIP is also the best way to give review, I think, because
once you implement it, you really go down into the details and that's the people
we've gotten the best feedback from thus far, people that actually tried the
proof of concept implementation and then said, "Hey, what about this detail,
what about this detail?"  So, I definitely encourage that, and yeah, that's it.

**Mike Schmidt**: Well, thank you both for joining us this week and giving us
your insights into the proposal.  You're welcome to stay on and hang out for the
rest of the newsletter, or you can drop if you have other things to do.  Thanks
guys.

**Josie Baker**: We got to bounce, but thanks so much for having us.

**Ruben Somsen**: Me too.  Bye guys.

**Mike Schmidt**: Gloria, I think you missed the introduction portion earlier in
the podcast.  Do you want to introduce yourself quickly before we jump into the
section on Waiting for confirmation?

**Gloria Zhao**: Sure, yeah.  I'm Gloria, I work on Bitcoin Core, I'm sponsored
by Brink, I really like mempool stuff.

**Mike Schmidt**: So much that you want to write about it every week for ten
weeks!

**Gloria Zhao**: Yeah, yeah.  These weeks, I've spent a lot of my time doing
Optech stuff, which is great.  Yeah, it was hard to keep this post under 1,000
words, I had to ask a lot of people for help.  Should we just jump into it, this
post?

_Waiting for confirmation #5: Policy for Protection of Node Resources_

**Mike Schmidt**: Yeah, we can.  So if you're following along, this is a part of
a limited weekly series that we're doing in the Optech Newsletter, called
Waiting for confirmation.  This entry is called Policy for Protection of Node
Resources.  And Gloria, I think bitcoiners are probably familiar with the
concept of, "Hey, we want to keep resource requirements low so that it's easy to
run a node, so that anybody can run a node and we can keep this Bitcoin network
decentralized".  So, that would include being able to run a node on a variety of
operating systems or a variety of commodity hardware with reasonable memory,
CPU, and network bandwidth requirements, and we have that.  So great, we have
low system requirements to run a Bitcoin node.  So we're good, right, Gloria?

**Gloria Zhao**: Yeah, well, that's something that is something we have to
maintain in the way that we write the code.  Of course, having support for
various platforms is something you have to maintain over time.  But there's also
a second reason why policy is important, which is running a Bitcoin node is
signing up for a rather adversarial security/threat model.  If you're running a
node and connecting to the P2P network, you're signing up to have internet
connections with randos who you have no idea who they are in real life.  There's
no way to try to guess whether or not they're malicious, and there's not really
a way to effectively ban them either, because you don't know who that real life
entity is.  You couldn't have some kind of legal process to be like, "Hey, this
guy doxed me".

So really, the only thing you can do while operating in this adversarial
environment, where you are making internet connections, you may be accepting
connections from inbounds and essentially allowing them to send you data to
process, and then you're going to allocate CPU and memory and network bandwidth
to process this data; the only thing you can really do is program defensively to
prevent DoS attacks.  And this, I don't know, it's pretty cool.  I haven't
worked on many other software projects where this is the security model, but
it's very interesting.  And it makes protecting node resources not only an
ideal, but an imperative.

I've gotten a lot of questions from people saying like, "Why would you have
validation rules on top of consensus; isn't that censorship?  But I think
there's a really good Bitcoin Talk post that I linked to in this article, where
people are kind of imagining what is the maximally computationally intensive,
consensus-valid transaction that you can create.  And it's a combination of
signature verification, which is very computationally expensive, as well as
quadratic signature hashing (sighashing), which is pre-segwit.  But if you
combine those into a transaction with thousands of inputs within the block size
limit, then you get something that could maybe take minutes to validate.

We've seen one in the wild.  Rusty Russell has a nice blog post that I also
linked to in there about this mega transaction that apparently took 25 seconds
on average to validate using Bitcoin Core at the time.  And this is not really
something you want to sign up for when you're just trying to run a Bitcoin node
to relay transactions and all that.  So that's the best reason, I'd say, or one
of the best reasons to have policy.  So, yeah, if you're interested, read the
post, there's some examples of policies in there.

**Mike Schmidt**: So even though on the box, when you look at Bitcoin Core
system requirements, they are quite low and that's not the solution to solving
being able to run a node; you also need a series of policy heuristics and best
practices in place to also make sure that you continue to run that node into the
future, otherwise you're abused by potentially malicious peers on the network.
And you go through, in this post, a series of examples of policy that is
designed to ensure that someone can be running a node with this minimal sort of
hardware that we outlined at the beginning.  So, I thought it was a great post,
thank you for putting it together.  You mentioned a few of the links that were
pertinent, but there's a few other examples also in there that I think if folks
are interested, they should jump into in terms of transaction relay policy, etc.
Joost?

**Joost Jager**: Yeah, one thing I was wondering about the megatransaction
example, that you need to prevent things like that from happening using policy.
Isn't that an indication that really the set of valid blocks should be reduced,
like basically soft forking and not allowing blocks that have so many of these
operations; or is it that this is like a dynamic value depending on current
hardware capabilities, so you can never really hard code that in the consensus
layer?

**Mark Erhardt**: So basically, we never want to make any transactions that
people could have created in the past and thrown away the keys for it, but only
kept the signatures invalid.  So, we try to keep the consensus rules as lenient
as possible and not potentially steal or destroy funds of people that they may
have vaulted in some way.  So in that regard, we try not to make the space of
what possible transactions could be included in the future smaller, unless we
can avoid it.

**Joost Jager**: Okay, I didn't know that, that makes a lot of sense.  And the
other thing I wanted to note is that I understand policy as a way to accomplish
goals like this, but in the discussion of the annex, for example, I can also
feel that there's also different ways in which the policy has quite a bit of
power.  So, we're talking about the exact format for the annex, and then it
seems that policy is a way to enforce a particular format, which is not really
related to DoS, like whether you want, for example, a TLV format or a different
format.  Policy is going to determine what will be possible, but it's not
directly related to DoS.  So I was wondering how you guys think about that,
using policy to enforce such things as a format.

**Gloria Zhao**: Yeah, so just to be clear, hopefully I made it clear, that DoS
is not the only reason why we have policy, and there's going to be a few more
posts in the series.

**Mark Erhardt**: Let me try to finish her thought, unless she is going to be
back in seconds.  But we're planning a few more posts in this series, and one is
going to be protecting network resources.  So, not only do we have to protect
individual nodes from being DoSed, but there are also resources that are just
expensive for the network as a whole.  For example, the size of the UTXO set
incurs a cost on every node on what amount of data they need to scan in order to
see whether new transactions are valid.  And then, another post will be about
the mempool as an interface for other layers, so for example, the LN of course
uses mempool, or has other requirements on unconfirmed transactions than onchain
transactions.  Let me see what else is there.  Yeah, I'm afraid that I forgot
what exactly the question was; whether we can use policy as a way to shape what
annexes are allowed?

**Joost Jager**: Yeah, indeed.  But I am understanding that may be running ahead
of further episodes in this series, right?

**Mark Erhardt**: Yeah, maybe.  I don't think that we had planned so far to
specifically mention the annex, but one of the things that we wanted to do ever
since the issue around bech32 and upgrading it to bech32m, delaying all these
services that now are lagging behind in adding support for sending to P2TR
outputs, is we would love for all the future upgrade mechanisms to, by default,
not get created by wallets, but to get relayed, like if a node understands it,
that they can forward it to other peers that understand them; but for certain
update mechanisms to be pretty lenient on the policy, so that if your node is
not upgraded yet, it will not black hole the transaction that it sees.  But
yeah, I think I have to ponder this a little more before I can specifically
comment on it.

**Joost Jager**: Okay.

**Mike Schmidt**: Murch mentioned a few potential topics for the rest of this
series, and to tease the next one for next week, we state here in the segment
that we point out that policy is not consensus and that two nodes may have
different policies, but still agree obviously on the current chain state.  And
so next week, we'll discuss policy as an individual choice.  Gloria, I see
you're back.  I'm giving you speaker access again.  Welcome back.

**Gloria Zhao**: Sorry, I've been having Wi-Fi issues today.

**Mike Schmidt**: I'm not sure if you were able to listen to the last couple of
minutes, but Murch is sort of giving us a preview of some of the future segments
in this series including, and I think you were talking about this, Gloria, that
DoS protection of the individual node is not necessarily the only reason for
policy, but also network resources as well?

**Gloria Zhao**: Yeah.  We're going to explore some other examples and reasons
and talk about a lot of the limitations that we have in mempool policy and what
ideas we might have to improve them.  So, I hopefully have not at any point
given the impression that I think policy is perfect in Bitcoin Core.  The goal
of this series is to start conversations and try to collaborate to improve
things.

**Mike Schmidt**: Well, Gloria, thank you for joining us and walking us through
this segment.  You're welcome to stay on or drop if you have other things to do.
Thanks for joining us.

**Gloria Zhao**: Thanks for having me.

**Mike Schmidt**: I think you're the author of one of the PRs that we cover
later in the newsletter, so if you do want to hang on, we can get your take on
it, although I think we covered it in a PR Review Club segment of the Optech
Newsletter a few weeks ago.  So, up to you.  Speaking of Bitcoin Core PR Review
Club, we are joined by an unintroduced guest, Matthew Zipkin.  Matthew, do you
want to introduce yourself quickly, and then I can maybe frame the discussion
and we can jump into the PR that we discussed for this month?

**Matthew Zipkin**: Great, yeah.  Hey, my name is Matthew Zipkin, I'm a
full-time engineer at Chaincode Labs working on Bitcoin Core with the mission of
closing issues, and that's what led me down the path to write PR #27600.

_Allow inbound whitebind connections to more aggressively evict peers when slots are full_

**Mike Schmidt**: Well thank you for joining us.  The PR that we're covering,
the PR Review Club covered, allow inbound whitebind connections to more
aggressively evict peers when slots are full.  So, Matthew, maybe to give some
context to the PR, can you explain how Bitcoin Core would handle an inbound peer
request before this PR, and then maybe that will surface some of the potential
downsides and room for improvement that you put into the PR itself?

**Matthew Zipkin**: Yeah, sure.  And yeah, that title is a bit of a mouthful,
it's always hard to come up with a good title for things.  But let me put it
this way; this PR actually relates directly to a use case that I have at home
too.  So, I have a Bitcoin Core full node in my house that I run on a Raspberry
Pi, and then I have several Bitcoin light clients that I run on both my laptop
and my phone.  These are Bitcoin wallets and even Lightning wallets that can
send and receive bitcoin, but they don't need to have the full blockchain on the
device itself.  So obviously on mobile, that is super helpful.  And instead of
relying on a third party API, like a hosted wallet or a custodial system, I can
run my own full node.

So when I open up, for example, BlueWallet on my phone, or maybe Wasabi Wallet
on my laptop, those wallets connect directly to the full node that I maintain
and physically secure and install the software on all by myself.  So it's a good
model.  And I think it was brought up, BIP158, as being a light client option
for the silent payments too.  So this is a model that in a future, a fully
decentralized future, I would love to see a Bitcoin full node in everyone's
home, but you don't need a Bitcoin full node on everyone's mobile device.  So,
the idea is to assist users in a configuration where they run their own full
node, but their actual wallet is a light client that just runs on another
device.

The way that those two devices connect is over regular Bitcoin P2P connection.
You could use maybe another API or something like that, but the wallets that I
mentioned actually do connect directly over Bitcoin P2P.  So does that make
sense so far?  We're just talking about connecting light clients to full nodes
so far and over the P2P network.

**Mike Schmidt**: Yeah, that makes sense.

**Matthew Zipkin**: OK, cool.  So, the problem with that is that there's lots of
good reasons why Bitcoin Core also has a maximum limit of connections, total
peers that it will connect to.  And that is, I forget what the default is now,
probably Murch or Gloria know off the top of their heads.  It's like eight
outbounds and maybe eight inbound plus two extra block relay connections total,
I think, and maybe two feeler connections.  But either way, those can fill up
and it's also adjustable too.  If you run your own node, you can set max
connections to 1,000 if you have the bandwidth and the hardware to support that
many peers.  But either way, you have a limit of peers that your node will
connect to.  And when you hit that limit, the behavior changes a little bit.
It's a little harder to connect to that node.

So, there's a lot of interesting logic for supporting inbound connections.  This
is, you set up a full node, and other nodes connect to you to download block
data; this is using your node to help support a strong network so that other
participants can get the data they need and stuff like that, so it's always good
to support inbound connections.  But once your connection slot is full, what do
you do when the next person requests an inbound connection to your node?  And
the naïve approach would be to be like, well we just don't let them in, we just
reject it entirely.  But that's actually not great policy, because then it
leaves it open to an eclipse attack, I think, and what we'd like is some kind of
churn.

So, if you only have eight connection slots and all eight are full and here
comes a ninth person requesting to connect, we don't necessarily want to reject
them.  What we do instead is we look at the eight inbound connections we already
have and sort of pick one to kick out, and there's a number of qualifications
that we go through.  For example, we wouldn't evict an outbound connection.
There are ways to add permissions to other inbound connections, things like no
ban and whitelist, and that's kind of where this PR starts to get in.  And then
with the remaining connections that are unprotected, I think we basically pick
whichever node hasn't sent us a block in a long time or who has the lowest ping
time or doesn't send us as many transactions as the other node; we pick a node
that is the least good and evict that guy, and then we can let in the new
inbound connection.  So is that clear up to that point?

**Mike Schmidt**: Yes, sir.

**Matthew Zipkin**: All right, cool.

**Mark Erhardt**: One tiny point, I think it's altogether 125 connections that
we make, and 11 of them are outbound, so 114 inbound are by default allowed.

**Matthew Zipkin**: Okay, great, thanks.  So, that's the logic up till now, and
it sounds like what I'm talking about earlier should still be fine, that if I
want to connect to my own full node with a light client, that there should
always be a way in.  But that's actually not always true, because you could have
a limited number of inbound connection slots, and they could already be full
with some of these nodes that we would protect for whatever reason.  Or if there
is nobody to evict, then your own node will get rejected from your own node,
your own light client could get rejected from your own node.  And that has
happened to me before, even on my own system at home.  I tried to open Wasabi
Wallet and I can't connect to my own full node because the inbound connections
are full, and that seems kind of silly.  I control both of these devices, I
should be able to get in there.

That leads us to the issue, which was opened by Theymos way back in 2016.  This
is issue number 8798, and it talks about a feature that was added in a really
old version of Bitcoin Core 0.12 and then removed sometime in 2015 for being
redundant.  And you can read that issue for the specific clarity, but the user
complaint is basically what I'm saying.  You have a light client that you want
to connect to your full node, but full node is full of inbound connections, so
it can't.

All my PR does is it adds a new permission flag so that inbound nodes with that
permission flag get a little extra help in connecting to your node.  So the
permission flag, actually I need to rewrite the description and title for this
PR because after review and discussion, the approach has changed from just a
default behavior to something that we're going to specify with a new permission
flag.  So, if you have a light client, what you do is, in your full node
configuration file, you'd specify this permission, which we're going to call
forceinbound, working title; forceinbound and then specify the IP or IP range of
inbound peers that are allowed to have that forceinbound flag set.  And when
your full node detects an inbound connection request from a forceinbound peer,
it'll try a little extra harder to make room.

What it does is it goes through the normal process that I described earlier,
where it looks to see if there's anybody it can evict.  And if it can't find
somebody to evict, it picks a random node to evict.  Nodes that remain
protected, even in this case, are the outbound nodes.  We never want to just
arbitrarily evict an outbound node because that is our main weapon in peer
selection, and peer selection is extremely important to protect ourselves from
eclipse attacks.  So we don't want to mess with the outbound connections.
People are working really hard on making sure that outbound connections are
always good.  But we'll try a little extra harder to find an inbound connection
to evict, and then you can connect your light client to your full node.

Then, this opens up some vulnerabilities.  The reason why we decided to use a
special permission flag instead of making this default behavior, is because what
you could be doing is basically saying, any connections that come from this
node, that come from this IP address or this IP range, are allowed to connect to
me and I will keep kicking out peers until they're connected.  So there's a
potential attack there.  For example, if somebody were to figure out or be able
to spoof IPs, if they were able to figure out how you were configured to let
these forceinbound nodes in, they could fill up your connection slots with the
forceinbound flag and still manage to evict your peers.  So that's why we're
making it a slightly different permission flag, just so that it's a new feature,
it's not changing the behavior of anybody's existing configuration, but we still
get the behavior that we want when people opt into that.

**Mark Erhardt**: Yeah, wouldn't it be nice if we were able to sometimes decide
whether the other end of a connection has exactly the device that we're thinking
it is.

**Matthew Zipkin**: Yes, it would be really great if there was some kind of way
to identify nodes cryptographically without revealing that they're being
identified, etc.  And yeah, Murch and I are joking because that work is --

**Mark Erhardt**: That is a problem I hope that somebody solves.  And I see that
Michael Tidwell has a question or a comment.  I'll give the word to him.

**Michael Tidwell**: Hey, Matthew.  The question for you is, I was wondering if
you did have something where you cycled all your inbound connections to be
potentially like malicious people, you still have those outbound connections
that can't be cycled based on what you're telling me.  So, how would someone
eclipse attack you, or how would someone -- maybe you can just kind of walk
through, how can you still be vulnerable if you still have those solid outbound
connections; you know what I mean?

**Matthew Zipkin**: Yeah, correct, great question.  And actually the answer is
that the vulnerability I'm describing doesn't actually lead to an eclipse
attack.  So because of the outbounds, you're still safe.  But it's more of a
griefing attack and it's not really you that could get screwed, it's the other
inbound nodes that are connected to you.  So we don't want a way for an attacker
to arbitrarily break connections out there.  My personal node will probably be
fine because of the outbounds, but if I'm allowing an attacker to disconnect
some of my inbound connections, those people get screwed because they were
connected to my node, which is a great node, and all of a sudden those
connections are going to get dropped.

**Michael Tidwell**: And the follow-up question is, I know you mentioned a
whitelist earlier, but I imagine there's a way to hard code a permanent inbound
connection that isn't going to be dropped this way?

**Matthew Zipkin**: Yeah, well, so kind of like what Murch and I were alluding
to, that the only way we really have currently to identify nodes and to give
them special permissions or properties is by IP address or ranges of IP address.
So, for example, in my home it's pretty simple.  I can add a whitebind or a
whitelist rule to my bitcoin.conf file that always allows connections from
192.168.0.0/24.  Basically, anything on my local network is always allowed to
connect to my Bitcoin Core node.  That's going to be something that's really
hard for an attacker to spoof unless they walk into my house and get on my
network.

**Michael Tidwell**: And then final question is, the joke that you and Murch
were alluding to, I know it's kind of tongue in cheek or something with identity
or something; can you just kind of touch on that, because that was over my head?

**Matthew Zipkin**: Yeah, sure.  So, there's a major project, based on BIP324 in
Bitcoin Core, that Pieter Wuille has taken back charge of, and this is an
encrypted P2P transport mechanism so that when nodes connect to each other, all
the traffic is encrypted, and Optech has done a lot of great work reporting on
that.  And another feature of that encrypted connection is something called
Countersign, which Greg Maxwell proposed a really long time ago, and is also
being researched and developed right now.  And that would allow nodes to
basically identify themselves in certain cases.

So what I would be able to ultimately do once all that work is done and
deployed, is I could simply give my full node a list of public keys, of identity
keys, the same way you would have an authorized keys file in your .ssh directory
on your server.  I could tell my full node that if any light clients try to
connect to you with these specific cryptographic identities, always let them
connect.

**Mark Erhardt**: Sorry, maybe one more sentence on this is that the Bitcoin
Network does not encrypt its traffic so far, so it's basically trivial for
anyone that is along a route where we're routing the current traffic to
intercept and change the communication.  So once we have BIP324 and encrypt the
traffic between nodes, it would make sense to have some sort of authentication
mechanism, which will make it way easier for light clients to connect to
specific full nodes and vice versa.  And yeah, that's basically what that joke
was about.

**Matthew Zipkin**: Right, oh, the vice versa is important there too, because as
a light client, I want to make sure that I'm talking to the full node that I
expect I'm connecting to, the one that I might personally run and protect.

**Mike Schmidt**: Matthew, thank you for joining us.

**Matthew Zipkin**: Hey, thanks for having me.

**Mike Schmidt**: Yeah, you're welcome to stay on, but we appreciate your time
and walking us through it as the author of this PR.

**Matthew Zipkin**: Thanks, Schmidty.

_Core Lightning 23.05.1_

**Mike Schmidt**: Next section from the newsletter is Releases and release
candidates, of which we just have one, which is Core Lightning 23.05.1, which is
a maintenance release and it fixes several crashes reported in the "wild",
including a memory corruption issue with an RPC, a crash on some deletion, the
gossip store deletion failures, incompatibility with LND, which prevented
opening private channels, and a crash related to some of the dual funding that's
recently been put in.  Murch, did you have anything to add to this release?
Thumbs up, great.

_Bitcoin Core #27501_

And we have four PRs for this week that we want to recap.  The first one is
Bitcoin Core #27501, adding a getprioritisedtransactions RPC.  And this is
actually the topic that we covered in last month's Bitcoin Core PR Review Club.
So, if you're curious about the details of this, check out Newsletter #250 and
check out podcast #250, where we jump in to some of the details.  Gloria is
here, but does not have speaker access.  Murch, do you want to give a tl;dr on
what is a prioritisetransaction?

**Mark Erhardt**: Sure.  So the RPC prioritisetransaction allows us to modify
the priority with which we would accept a transaction into a block template that
we ourselves are building.  So it's a way of making your node consider a
transaction earlier or later during block building.  The idea here is, for
example, if a block builder is interested in confirming their own transactions
even if the feerate is lower or things like that, they can use
prioritisetransaction in order to individually change how the transaction is
considered during block building.

But the RPC is probably not getting used a ton and therefore it hadn't seen a
lot of review and changes in the past.  One of the issues around that RPC was
that I believe the table where we store the information about what transactions
had gotten prioritized was keeping the data forever, even if the transaction was
already confirmed.  And especially, even if you remove the priority and set it
back to "no change", we would keep an entry for that transaction in our table.
I think it does get cleared if you remove your mempool file but otherwise, even
for restarts, we would keep that information.

So, there's been a few small improvements on that behavior.  So for example,
confirmed transactions get removed, and transactions that get set back to zero
get removed, and then I think with the getprioritisedtransactions call, you can
actually output a list and see what is on your node's configuration for treating
differently or not.  And I see that Gloria is back, so she can correct anything
I said wrong now.

**Gloria Zhao**: Sorry.  That was a great explanation, thank you.  We do clear
it when a transaction confirms or if a conflicting transaction confirms.  But
yeah, it's persisted across restart, it doesn't expire.  If it's set to zero, we
don't delete it.

**Mike Schmidt**: Gloria, one question I had for you on this PR is, what was the
motivation for you to spend your time on this?  Does this connect to something
else you're working on, or did you just notice an area for improvement?

**Gloria Zhao**: So, I started looking at this code when I saw usage of
prioritisetransaction in a different project, and I mean it should only be used
by miners really, but yeah, I was kind of concerned that first of all you could
"cancel" a prioritisetransaction by setting it to zero, but you just keep that
entry around forever.  So, I was thinking if somebody uses it in production,
they have this not memory leak, but kind of, and especially if you can't even
query your node for what prioritisetransactions you have.  If it falls out of
your mempool, for example, the only option was going to be to inspect the
mempool.dat, which didn't seem very good.  So, yeah, that was the motivation for
working on it.

_Core Lightning #6243_

**Mike Schmidt**: Cool, thanks.  Next PR this week is Core Lightning #6243, and
this PR changes some of the internal plumbing and RPC output for working with
configuration variables in Core Lightning (CLN), as well as it looks like
setting the groundwork for some additional changes to the way that configuration
is managed within CLN.  It also adds a long requested feature, which has to do
with an issue that was opened in CLN a while back, and this person was noting
that when you initially start lightningd, configuration variables were passed to
the different plugins that you have enabled for CLN.

However, you're also able to stop and restart that plugin independent of the
node stopping and restarting.  And if you stop the plugin and restarted it,
these configuration variables weren't passed to the plugin, resulting in a
potentially inconsistent experience for folks using plugins.  So, in addition to
some of that plumbing work I mentioned, it fixes this issue/feature request.
Murch, any comments on that?  Great.

_Eclair #2677_

Next PR is Eclair #2677, which extends the maximum permitted number of blocks
until a payment attempt times out, and this is something that we've seen in the
past.  LND and CLN already have, I think it's about two weeks, which is 2,016
blocks.  And so, Eclair is doubling their number of blocks from 1,008 to this
2,016 number, from one week to two weeks.  And t-bast noted in the PR that, "The
network is generally raising the values of cltv_expiry_delta to account for high
onchain fees.  So we'll need to allow longer maximum deltas to avoid rejecting
payments".  So we see another instance of high usage onchain being a forcing
function in terms of folks' configuration and making optimizations.  Murch,
thoughts on this Eclair PR?

**Mark Erhardt**: Yeah, well maybe Joost can even say more about this, but the
issues around having really high feerates and feerates changing a lot all over
the place were affecting Lightning users and they started increasing the amount
of blocks they want to have for settling a Hash Time Locked Contract (HTLC) that
they forwarded in case the transaction needs to go onchain.  So basically, the
individual hops started requiring bigger block deltas for each hop, and that
meant that overall the max_cltv, which is for the entire multi-hop payment,
started being a limit for how many hops you could encode before reaching that
max_cltv.  So, I think that that was the main motivation for increasing that.

Of course, on the other hand, having a very large max_cltv means that you
potentially have to wait an immense amount of time until you know whether
payment went through or actually failed.  And, yeah, so you would love to know
as soon as possible whether payment went through or not, but it gives the last
hop, or someone along the route, a lot of leeway to just hold and not forward a
multi-hop payment and grief you.  So, I guess that's the two extremes that
people are keeping in mind here when they pick these values.

**Joost Jager**: Yeah, that's correct, indeed.  And the large effects, as you
mentioned, also make it easiest to jam channels for a long time without
refreshing HTLCs.  And interestingly, if I remember this correctly, maybe this
is two, three, four years ago, there was no maximum, so that was a severe
vulnerability that you had.  You could receive an HTLC and you were instructed
to apply a delta of 10,000 blocks, and then implementation would just do that.
So, that was when this limit and then corresponding failure message were first
brought to life.  But then they tried to lower it and now bringing it back up
again a bit.

_Rust bitcoin #1890_

**Mike Schmidt**: Thanks, Joost.  Last PR for this week is to the Rust bitcoin
repository #1890, and this adds a method for counting the number of signature
operations (sigops) in non-tapscript scripts.  The author of this PR noted that,
"Bare multisig is making a comeback, which is causing a large amount of
transactions' effective vSizes (for fee calculation) to be dependent on the
sigop count".  And I think what the author is referring to here is potentially
this Bitcoin stamps protocol that encodes data into the Bitcoin blockchain using
bare multisig.  And the author notes that, "This is a first step at making those
transactions easier to estimate fees or block templates for".

So, per our discussion with Gloria earlier about DoS attacks, the number of
sigops is limited per block.  And we've actually seen some blocks recently that
were broadcast, but they were invalid due to this specific sigops limit check.
So, I guess this utility library can help potentially mitigate some of that.
Murch?

**Mark Erhardt**: Yeah, exactly.  So the limit is 80,000 sigops per block.
There's a key on how we count each output type.  So, for example, a bare
multisig output is counted as 80 sigops, which is sort of the maximum of
possible signatures that a multisig operation could have.  I think it's allowed
to have up to 20 public keys, and then we multiply that with the witness
discount factor, so multiply it by 4.  And it looks like F2Pool might have
custom block building software, because they may have forgotten to account for
their coinbase transaction sigops.  They had two blocks in the past couple of
months where they were just slightly over the allowed sigops in their block; I
think they had like 80,003 sigops twice and that cost them two block rewards.

**Mike Schmidt**: If anybody has any questions, now would be the time to raise
your hand for speaker access, or you're free to comment on the Twitter thread.
In the meantime, I wanted to thank our guests who joined us this week.  So,
thank you to Gloria for joining us, Joost, Josie, Ruben, and Matthew, and our
part-time co-host, Michael Tidwell, for joining us.  Murch, any comments or
announcements before we jump off?

**Mark Erhardt**: No, all good for me.

**Mike Schmidt**: Okay.  Thank you all for joining us and we'll see you next
week.  Cheers.

**Mark Erhardt**: See you.

{% include references.md %}
