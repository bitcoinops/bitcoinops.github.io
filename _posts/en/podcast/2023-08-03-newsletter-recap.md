---
title: 'Bitcoin Optech Newsletter #262 Recap Podcast'
permalink: /en/podcast/2023/08/03/
reference: /en/newsletters/2023/08/02/
name: 2023-08-03-recap
slug: 2023-08-03-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Tom Trevethan, Lisa Neigut, and Dusty Daemon to discuss [Newsletter #262]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-7-4/341868981-22050-1-b738171ee15fb.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #262 Recap on
Twitter Spaces.  It's Thursday, August 3rd, and today we're going to be talking
about Bitcoin transcripts and the LN spec meetings; we're going to talk about
blind MuSig2 signing and statechains; a BTCPay Server release; and a slew, eight
Core Lightning (CLN) PRs as well.  We'll do some intros and then jump into it.
Mike Schmidt, contributor at Bitcoin Optech and Executive Director at Brink,
where we fund Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work on Bitcoin stuff at Chaincode Labs.

**Mike Schmidt**: Tom?

**Tom Trevethan**: Hi, my name's Tom, I work for CommerceBlock and we're
developing a Mercury layer, which is a statechain protocol, a blinded statechain
protocol.

**Mike Schmidt**: Dusty?

**Dusty Daemon**: Hey, I'm Dusty, I work on CLN, specifically on the splicing
code and spec, that's my main thing; Dusty Daemon.

**Mike Schmidt**: Well, thank you both for joining us.  We'll jump into the
newsletter and just go sequentially through that, starting with the News
section.  We have two news items this week.

_Transcripts of periodic LN specification meetings_

First one is transcripts of periodic LN spec meetings.  So there's an LN spec
meeting that happens every other Monday.  Those meetings are open to the public
on IRC, and also there are video links available for higher bandwidth
communication, and they use Jitsi to do those chats during the meeting.  And
these every-two-week meetings are different than the LN Summit in-person meeting
that we discussed in detail in last week's show.  Look back to #261 where we
jump into the details of that particular in-person meeting.  It looks like the
way that it works is there's an issue that's created on the BOLTs repository
that outlines and solicits agenda items, including recently updated proposals,
stale proposals, waiting for interop, and long-term updates.  And then
contributors to the spec and different implementations jump in, provide some
agenda items, and they go through that every couple weeks.

What we highlighted this week is that these meetings are being transcribed using
a combination of AI tools and human review.  And the transcriptions that come
out of those discussions are published on the Bitcoin Transcripts website, which
I don't know if we've talked about on our Optech Recap before, but that's
btctranscripts.com.  And the Bitcoin Transcripts project is based on a website
from Bryan Bishop, Kanzure, you may know him as, which accumulated a lot of
Bryan's notes over the years on different Bitcoin events, different conferences,
that his masterful typing and transcription speed is very conducive to capturing
all that information.

So, the Bitcoin Transcripts project builds on top of that.  It includes
transcripts, transcriptions from events like Adopting Bitcoin, BTC++, Advancing
Bitcoin conferences, transcriptions from some BitDev meetups, transcriptions
from podcasts, like there's some of the Chaincode podcasts in there, the Noded
podcast, Let's Talk Bitcoin.  And then that transcription content is also used
as one of the pieces of data that the bitcoinsearch.xyz website uses.  And as a
reminder, that's a technical Bitcoin search engine and the content is searchable
from these transcripts that we talked about for the LN spec meetings, alongside
Bitcoin Talk posts, mailing list posts, and content from ourselves, Bitcoin
Optech as well.

**Mark Erhardt**: And Stack Exchange.

**Mike Schmidt**: And Stack Exchange.  Murch, did you have any comments on
either the spec meetings, the transcripts site, or the bitcoinsearch.xyz?

**Mark Erhardt**: Yeah, just about the transcripts.  The main point of those
transcripts is that the people that can't attend the meeting can read up in
verbatim what the items were, or the actual discussion word for word.  I think
for most of us, the summary is sufficient, but this is just for the people that
would usually attend the meeting but couldn't be there.  Or really, really
curious people that want to read the whole thing.

**Mike Schmidt**: And then one other point before we move on is that we
discussed, in our coverage of the LN Summit, that one of the items was trying to
be more active on the Lightning-Dev IRC chat room.  And it seems like people are
really taking that to heart because there's been a bunch of activity for
Lightning-related talk in that IRC channel, so good to see.

_Safety of blind MuSig2 signing_

Next piece of news from the newsletter is safety of blind MuSig2 signing.  And
Tom had posted to the Bitcoin-devs mailing list about a blinded two-party MuSig2
protocol and that was part of your Mercury statechains deployment, I believe.
Maybe you can explain the idea of blinded MuSig signing and how it fits into
your statechain setup, and maybe to calibrate the audience, folks probably know
high-level summary of some of these terms, but not necessarily all of the
detailed cryptography.

**Tom Trevethan**: Okay, sure.  So essentially, just a very, very quick summary
of what we're doing with the statechains is that the idea is that you have a
trusted server, and that someone basically generates a shared public key, where
one key share belongs to the server, one key share belongs to a client, and you
generate a shared address, and then someone deposits some money into that to
create a UTXO, which is controlled by that shared address.  And then, you can
then transfer ownership of that UTXO to a new owner in a way that the shared
public key stays the same, but a new owner has a new key share, the server
updates its key share, and also you cosign a backout transaction with the
server, which will return the money after a timelock if the server disappears or
is shut down.  Basically this timelock, this nLockTime timelock, is set sometime
in the future, and as you transfer this UTXO between one owner to a new owner,
you decrement this locktime.  And so whoever has the one that's expiring soonest
is the current owner.

So, currently we have an implementation of this, and we're using a two-party
ECDSA.  And the server essentially performs the role of verification that the
rules are being followed in terms of the signing of the backup transaction.  So,
what we're doing is we're kind of implementing a new version of this where we've
made two big changes, or two big design changes.  The first one is we want to
shift over to using a schnorr signature instead of the two-party ECDSA.  The
two-party ECDSA is very complex and computationally expensive and therefore
slows everything down, and so we want to move over to using a schnorr where we
can use a MuSig-type scheme, which is much more efficient.  And the other one is
that we want the server to be completely blinded.

So, the server now no longer does any verification of cosigning when it cosigns
the backup transaction.  This means that the server really -- we want the server
not to be able to know anything about this coin that it's co-signing for, so we
don't want it to know the full shared public key; we don't want it to know the
final signature; we don't want it to know the transaction signature hash
(sighash) that it's signing for; and that all verification is then shifted to
the new owner.  So, the new owner basically receives the full sequence of
previous owner's backup transaction, and the only thing the server can report is
how many things it's signed.  So if there's been, say, four previous owners, the
new owner would receive five backup transactions, his own backup transaction and
the backup transaction of the four previous owners, and then the server would
report that it's generated five signatures on this shared key.

So, yeah, we basically wanted to develop a scheme that we could use this with
schnorr and using MuSig2, and I kind of suggested a scheme to the mailing list,
where kind of naively thinking, okay, so when you generate the shared public
key, so doing a 2-of-2 MuSig2-type setup, where essentially the party 1 -- so,
yeah, if we say party 1, party 2, so party 1 is the server, party 2 is the user,
party 1 just sends their key share to the user, the user doesn't send its public
key share to the server, so the server never needs to know the full address.
And that instead of the server computing its own, what we call here the
challenge value, so this is the hash of the ephemeral keys and the public key
and the sighash, the message, this is just received from the user.

This didn't work for several reasons.  One is that actually the c value can be
used, if you scan the entire blockchain, you can actually find which signature
has been created.  Also, the other issue was this, pointed out by Jonas Nick,
was that you can use this so-called Wagner attack, basically, by having a user
or a series of users or a series of owners basically generate a number of
signatures.  They can generate an additional signature if they're able to choose
the ephemeral key value and these c values.  And basically, yeah, you can
arithmetically determine a challenge value and essentially generate an
additional signature beyond the one that the server has cosigned.  This
basically means that because the server is not able to basically verify the
construction of the challenge value, it can't know that this hasn't been
selected specifically by the user, with basically that hasn't included the
ephemeral commitment of the server.

However, going through this and kind of discussing it with Jonas, I think we've
come up with a scheme where we can mitigate this, essentially by having the user
basically commit to the values it uses, and the server records these
commitments.  And then when the state coin is transferred to a new owner, the
new owner can retrieve these commitments from the server and then verify them
against values that's received from the previous owner, basically to prove that
the challenge value was computed correctly, including the ephemeral key share
from the server.  So, essentially there's no way that this Wagner attack could
have been applied.  So, yeah, based on this, we've written up a new model for
this, a new protocol, which I think we'll send back to the list and see if
anybody's got any further comments on it.

**Mike Schmidt**: Murch?

**Mark Erhardt**: Cool, that sounds really good.  So let me try to recap it in a
couple of sentences.  Statechains basically are a shared UTXO model where you
have a facilitator, and then all the other participants that are senders and
receivers can just keep trading a fixed amount of bitcoin, like 1 Bitcoin or so,
that they sent back and forth.  And where previously the server was also the
arbitrator that enforced the rules, now you have managed to find a way, you
hope, to blind the server completely to what the transaction is doing, and only
is basically ensured that the side of the server is facilitated and the points
are transferred correctly so that the protocol can continue using the same UTXO
without moving it onchain, but changing the ownership.  And, yeah, so you
described that there was basically a key cancellation attack in the first
scheme, but you're hopeful to have a solution now?

**Tom Trevethan**: Yes.  So, I think we do basically.  So essentially the server
is now going to be trusted to just report; so the server is going to be trusted
for several things.  So, the server is going to be trusted to correctly report
how many times it's generated a partial signature, and it's also going to be
trusted to have basically received commitments to the ephemeral signing keys
that the user uses before it generates that partial signature.  And then it's
going to store that information, and then anybody who then is a receiver of a
state coin can take the full set of information about previous signatures that
the server has cosigned, and verify that the only things that the server has
cosigned are the set of backup transactions of previous owners, which are all
valid according to the protocol.  So, there's no way that the server could have
cosigned something else, which would allow someone to steal the coin.

**Mark Erhardt**: Yeah, and then on the other hand, the recoveries are
timelocked with a decrementing timelock so that the latest owner is the first to
be able to recover?

**Tom Trevethan**: Yeah.

**Mark Erhardt**: Business model-wise, how does the statechain operator get
financially rewarded for facilitating the service?

**Tom Trevethan**: Well, yeah, so that's another change that we're having to
make for this new version.  So currently, because the server is not blinded and
the server verifies everything it signs, we take a withdrawal fee.  So, when
someone withdraws a coin, basically they create a withdrawal transaction which
is verified by the server and that has to include an output paid to us, and it's
a 0.5% fee of the total amount.  So, there's no fees for transfers or deposit,
but just when you do a withdrawal, before the server cosigns the withdrawal
transaction, it checks that this is there.  But when the server is blinded, it
can't do any of these verification checks.  So, in this case, the only way we
can charge a fee is out of band.

So, we've now created this method of, you basically make an out-of-band payment
with Lightning in order to initially generate the deposit address.  So, you have
to pay a Lightning invoice in order to create the deposit address essentially.
So, now the fee payment is completely separated from the actual state coin
creation and transfer process.

**Mark Erhardt**: We just had Bob join us.  Bob, did you have a question or a
comment?

**Bob McElrath**: Yeah, I wanted to ask, the attack here is a collusion attack
between the server and the previous owner.  So, it seems to me that the server
could report one fewer signature and one fewer commitment than it has actually
done.  Is that an attack and how can you mitigate it?

**Tom Trevethan**: I mean, yeah, the server's trusted to create it, to report
exactly how many partial signatures it's generated.  But the attack that was
discussed on the mailing list is the fact that a user can generate an additional
signature, essentially.  So, the server only cosigns, say for example, four
partial signatures, but a user could then possess five valid signatures using
this Wagner attack.

**Mark Erhardt**: So to respond to the other part of Bob's comment, it's not a
collusion attack, it's only an attack by the user, correct?

**Tom Trevethan**: Yes.  So, I mean obviously the key part of the statechain
idea is that in the original case, the server is trusted to verify that
everything it cosigns is valid; and in the blinded case, the server is trusted
to basically correctly report how many partial signatures it's generated on
shared key.

**Bob McElrath**: So, it seems to me that the set of previous commitments should
be equal to the number of signatures it's created, right?

**Tom Trevethan**: Yes.

**Bob McElrath**: So the server storing both of those, it seems to me there's a
solution here where that set of commitments could be stored elsewhere, and
therefore the server can't lie about it.

**Tom Trevethan**: Yes, but I mean you would just be trusting another server to
correctly state that these commitments were received before the partial
signatures were generated.

**Bob McElrath**: That's true, but imagine this blob of commitments was
encrypted. and the users of statechain who are passing the UTXO around also pass
the encryption key for that blob to each other, and somebody is storing an
opaque blob of data.  It could be the server, but it could be something else
too.

**Tom Trevethan**: Yes.  You can imagine that you could commit to this somehow,
you can use some commitment to Bitcoin to do this.

**Bob McElrath**: Can those commitments be passed directly between the users?
Why does a server need to store that?

**Tom Trevethan**: The key part of the mitigation of this attack is that the
server has to have received these commitments from the users; the server has to
receive this commitment before it generates the partial signature.  So, if the
partial signature is received by the user before it generates the commitment,
the user can basically use this Wagner attack to choose the r values.  So, as
I'm understanding it, it's the fact that the server basically is being trusted
to not issue the partial signature until it receives a commitment.  So, in that
sense, what is important is the server's sequence of operations and that this
has been done in the correct sequence.

**Mike Schmidt**: Bob, did you have any other questions or comments?

**Bob McElrath**: No, that's it.

**Mike Schmidt**: Tom, it was mentioned in the responses to your mailing list
post, I think it was Jonas Nick that said, "As far as I know, blind MuSig is
still an open research problem", and it looks like you guys are working on this
particular research problem.  But I'm curious if there's other groups or
academics that are also working on this that you've come across, either through
this mailing list post or otherwise.

**Tom Trevethan**: Yes.  I mean, I know that other people are looking at it.  I
mean, our application is very specialized in that we're using the fact that you
can have a blinded server that reports the number of signatures it's generated,
and that this can be used specifically for this state-coin protocol.  But there
are some others.  I think it was this Moon Settler had come up with this blinded
schnorr scheme, which actually I used as the method to blind the challenge value
to the server.  And he was interested in basically using it for like a 2FA
mechanism, you know, having some kind of 2FA wallet or something, where the
server basically wouldn't be able to know anything about the transactions it's
cosigning.  But I haven't seen anything else, I don't think.

**Mark Erhardt**: Well, it's pretty cool to see that you got so much response
and input on the mailing list and even here in our Twitter Spaces.  So, it
sounds like you're moving forward with this quite well.

**Tom Trevethan**: Yeah, it's good to get that kind of response, I think,
because it's quite a niche problem, but it involves some quite interesting
cryptography.

**Mike Schmidt**: Tom, any final words as we wrap up this segment?

**Tom Trevethan**: No, I don't think so, except that I'm going to send our
updated protocol to the mailing list probably later today, just hopefully if
there's any more comments and discussion.

**Mike Schmidt**: All right, Tom, well, thank you for joining us.  You're
welcome to stay on and discuss the rest of the newsletter, and if you have other
things to do, you're welcome to drop.

**Tom Trevethan**: Okay, thanks.

_BTCPay Server 1.11.1_

**Mike Schmidt**: We have one release that we covered in the newsletter this
week, which is BTCPay Server 1.11.1.  And the 1.11.1 is just a release that
includes bug fixes, but the 1.11.0 release, which happened last week, has some
new features to this piece of software, including improved invoice reporting,
point of sale cart redesign, and also adding categories to the point of sale
apps, and also some other improvements and fixes.  Murch, I'm not sure if you
have anything to add on that release.

**Mark Erhardt**: I do not.

**Mike Schmidt**: All right, we'll jump to our Notable code and documentation
changes, and I'll use this opportunity to solicit from the audience if you have
any questions, as we progress through these PRs, on anything we've talked about
or will be talking about in the next 20 minutes or so.  Feel free to comment on
the Twitter thread if you prefer to type, or you can request speaker access and
we'll get to you at the end of the show here.

_Bitcoin Core #26467_

First PR is Bitcoin Core #26467, which allows the user to specify which output
of a transaction is change in the bumpfee.  So, when you're fee bumping, you get
to designate which output is change.  And I saw in the PR, and Murch, maybe you
can help me with this, achow mentions, "We will try to find the change output of
the transaction in order to have an output whose value we can modify so that we
can meet the target feerate.  That part makes sense.  And then he goes on to
say, "However, we do not always find the change output, which can cause us to
unnecessarily add additional outputs to the transaction".  Murch, help me
understand, what's the scenario where Core can't determine the change output?

**Mark Erhardt**: So for example, if you had an external signer, you wouldn't
necessarily be able to identify that an output is yours.  Or if you're, for
example, creating a raw transaction for a wallet that you are not watching.
Basically, in scenarios with multiple participants, or if you're creating a
transaction for essentially an external signer, you would have this.

**Mike Schmidt**: And so this is a way to designate that this particular output
is changed, so then when you bumpfee, the fee bumping can be deducted from that
particular output then?

**Mark Erhardt**: Correct.  It would basically just instruct the wallet, or
rather the software that is building the new replacement transaction, which
output to deduct the additional fees from.

_Core Lightning #6378 and #6449_

**Mike Schmidt**: Excellent.  Next PRs, I think eight of them, are to the CLN
repository.  The first two that we highlighted in the newsletter were #6378 and
#6449.  Luckily, we have Dusty and Lisa here to help us through some of these
CLN PRs and probably describe them much better than we would, including the
context for all this.  Lisa, we missed your introduction in the beginning, maybe
you want to introduce yourself?

**Lisa Neigut**: Sure.  Hey guys, my name is Lisa, also known as niftynei.  I've
been a long-time CLN maintainer.  I stepped back a bit more recently to work on
some Bitcoin education stuff through Base58, but happy to be here to talk
through some of these Lightning changes on CLN.  I think you guys picked some
really interesting PRs to go through, so excited to get into them.  Do you want
me to jump into this first one?

**Mike Schmidt**: Just one quick question before.  What's with the flurry of CLN
PRs this week?

**Lisa Neigut**: Yeah, that's a great question.  So, the answer is we just cut
our rc1, release candidate 1, for the next release.  The flurry of PRs is coming
from getting everything merged before the release.  So, I think we're on a
probably every three months release, kind of release schedule.  The way that the
release process works in CLN is that we have a different release captain every
release.  So, our releases are scheduled.  This one is scheduled for August, so
we're in August, so it's time to start getting the candidates out.  And Rusty
Russell, this long-time project lead, just so happens to be the release
candidate this time, and so he's just making sure everything gets in before the
deadline.  So, I guess it's basically deadline-driven programming.

**Mike Schmidt**: Excellent.  All right, do you want to tackle these two PRs in
some of the context there and then we can move along?

**Lisa Neigut**: Yeah, sure.  So, this is kind of interesting, because I think
it exposes some of the security properties around Hash Time Locked Contract
(HTLC) timeouts.  The general idea is that typically if you have an HTLC that
you're passing along as a routing node to the next node, you're going to want to
make sure that you basically set a timeout that if by that time deadline, the
node that you've passed the payment to hasn't either failed the payment back to
you or sent you a successful preimage to clean the payment, typically what you'd
want to do is fail that channel to chain.  And then, as soon as you've failed
that channel to the node that you forward the payment to, to chain, you would be
able to then turn around and fail back offchain the payment to basically the
incoming node, the node that offered you the payment in the first place.

What this PR is saying is that there's some cases where it doesn't make economic
sense for you to fail the outbound payment to chain.  But in those cases, we
weren't turning around and failing the HTLC back, basically.  So, we were making
it such that it was likely that both of the channels would fall to chain as
opposed to keeping one of the channels open basically.  The second paragraph of
this explanation, I think really gets into it.  For those of you that are
looking at the Optech, specifically the last sentence that says, "Prior to this
PR, the node wouldn't create an offchain cancellation".  Well, maybe it's the
first sentence, I'm sorry, "Bob's node either spends using the refund condition,
but the transaction doesn't confirm, or he determines the cost is too high, is
higher than the value".

Anyway, so basically there's certain HTLCs you've committed to that just don't
make sense to claim onchain, or maybe you're trying to claim it onchain, and it
fails to get to a block in a good time.  So, this is just kind of making our
cancellation logic a little bit cleaner, so that your channels are less likely
to start falling to chain.

**Mark Erhardt**: So, the way I gather this, if you have, for example, a really
tiny payment, like 1 satoshi or so, when the channel is closed, you would have
this dust HTLC on that channel; and in the usual closing transaction, it would
of course broadcast that channel to the blockchain and settle all of the HTLCs.
But the HTLC here would be smaller than the fee to broadcast or to add that HTLC
to the transaction.  So, instead of trying to do that, a while back already, it
would just drop that HTLC, but then the other channels that were already part of
this multi-hub contract downstream would also see the HTLC expire and then close
their channel.  And now instead we tell them, "Hey, we are not going to claim
that money onchain, please keep the channel open instead".  Is that right?

**Lisa Neigut**: Yeah, I think that's it.

**Mark Erhardt**: Somebody wanted to chime in!

**Lisa Neigut**: Yeah, sorry, exciting things happening out here!

_Core Lightning #6399_

**Mike Schmidt**: I think we can move to the next PR, Core Lightning #6399, adds
support to the pay command for paying invoices created by the local node.  I
guess either Lisa or Dusty can answer, whoever is more familiar.  Why would we
do such a thing?

**Dusty Daemon**: Well, I think because she's got a dog going, I can start it,
she can finish, she probably knows more about it than me.  But this sounds like
a self-pay update, and this ends up being important for if you're doing
complicated things like the PRISM projects, where their node takes in one
payment, splits it among n people, so the idea is if you have like ten people
that want to split a payment equally, it goes through their PRISM thing.  They
need a way to account for that and they want to use all of CLN's fancy
accounting stuff.  So, if they just mark it as a payment to themselves, it makes
all the accounting work nice.  We didn't really support paying yourself with an
invoice, which is a fake payment, but this update, as I understand it, makes
that possible.  Maybe Lisa can add more if she knows more.

**Lisa Neigut**: No, I think you nailed it, Dusty.  So, I think PRISM is a
really amazing present use case.  There've been people in the past who ask us if
they're able to create an invoice and then market it as paid basically to
themselves.  If you think about it, it's like, I don't know, invoices are useful
documents, like Lightning invoices are like an upgrade.  I consider them a very
strong upgrade to onchain payments, because they give you an amount and a place
to send the money and how long you have to pay, and all that; there's a lot of
information in there.

So, I could see a Lightning invoice being a useful document to tell other people
how to pay you and when to pay you, etc.  And then you just, for your internal
accounting, want to be able to, let's say for whatever reason, I don't know,
this is kind of a forced example, someone ends up paying you in cash or
something for that Lightning invoice, you know, the invoice is like a request to
be paid.  If they pay you through some other method, then it would be really
nice to be able to mark that invoice as paid basically, right?  being able to
self-pay is sort of a way of doing that.

So I think Dusty really nailed it with, it's more of like an accounting thing,
right, like you can create invoices now and mark them as self-pay.  It should be
pretty cool, okay.

**Mark Erhardt**: Another example might be if you're operating a Lightning
Service Provider (LSP) that has custodial amounts too, then if one client pays
the other client and they don't know that they're using both the same service,
you would be able to mark the invoice as paid and just update the internal
accounting, right?

**Lisa Neigut**: Yeah, I think so.

_Core Lightning #6389_

**Mike Schmidt**: Next PR, also Core Lightning PR, #6389, adding an optional
CLNRest service, which sounds like it's a wrapper to CLN's RPC that provides a
REST interface.  Is that right, Lisa and Dusty?

**Dusty Daemon**: Yeah, that sounds right, yeah.

**Lisa Neigut**: What's so exciting about this though, is that up until this --
so this will be in our next release, right, so it just got merged.  Prior to
this, the only way you could talk to CLN was through a Unix socket over a
Lightning channel using commando or via gRPC.  So this rounds out what I would
call the, I don't know, quadfecta, not a trifecta, the quadfecta of ways to
communicate with a CLN node.  So, now you can use gRPC, you can use the Unix
socket built-in RPC, you can use the Commando LN socket way of doing things, or
now you can just use HTTP, which we all know and love, so that's kind of cool.

I think this will probably be the last, knock on wood, this will probably be the
last way that we expose talking to the CLN RPC.  And so it's cool, we've rounded
out the set of ways that you can talk to us.

**Dusty Daemon**: Yeah, I think this is going to be highly appreciated, because
a lot of developers, they have a certain way of doing things already, maybe they
use a REST API, gRPC, or whatever.  So, it's useful for CLN, you just support
all of the methods to make onboarding of new developers to using it easier.  And
after this, it sounds like CLN has every single possible way, so that should
help new people coming on to CLN.

_Core Lightning #6403 and #6437_

**Mike Schmidt**: Excellent.  Two more Core Lightning PRs here, #6403 and #6437,
moving runes authorization and authentication out of the commando plugin and
into the Core functionality.  We talked about commando in #210 and we recapped
that in our Twitter Space.  Lisa, maybe you can let us know maybe why you moved
this.  Also, I don't know if this is true, but did you guys move the commando
plugin into the Core, or is that still a separate piece?

**Lisa Neigut**: Yeah, so this is tightly related to the previous one that we're
talking about.  Basically, now that we've exposing a REST API, we need an
authentication method that you can use to verify that the person calling that
RPC has permissions to do that.  We had previously written an authentication
system, called runes.  It was tightly tied to what I was calling the LN socket
or connecting over Lightning channel way of talking to the RPC.  This
authentication module, the runes part of it, was kind of baked into the built-in
CLN plugin, called commando, which handled those Lightning channel RPC requests.
So, since we want to reuse that same functionality now for these API requests
that are coming in over HTTP, just like a different transport layer basically,
we needed to move it out of the commando plug-in into a more generalized part of
the codebase, so that it could be accessed by those two different kind of
transport managers either coming into a Lightning socket, I guess I'll call it,
or over an HTTP socket.

**Mike Schmidt**: Okay, that makes a lot of sense.  It sounds like to answer my
question about the commando plug-in, that is bundled with CLN, but it is still a
plugin, is that right?

**Lisa Neigut**: Yeah, that's right.  Yeah, so that's still in CLN.  It's been
in CLN, it ships with it since probably our last release or maybe two releases
ago.

_Core Lightning #6398_

**Mike Schmidt**: Next Core Lightning plugin is 6398, extending the set channel
RPC with a new ignore feed limits option, that will ignore the minimum onchain
feed limits for the channel.  Lisa, why would we want to ignore the minimum
onchain fee limits for the channel?

**Lisa Neigut**: This is a great question.  I think the answer is, we really
don't want to.  This is a good thing to use.  I think the suggestion is to use
it with channels that you trust not to be malicious.  The general idea, though,
is that we've seen with mempool feerate, I guess I should say block space
auction, prices went pretty high the last six months or so.  We've had pretty
full mempools, which means that the feerate that you're paying to get bytes into
a block has been pretty high or moving around a lot.

When those move around, you kind of get into a situation where both of the nodes
currently need to have a general agreement around what the current feerate is.
And if they get out of the disagreement at any point, it'll cause the channel to
force close.  So basically, your channel will go to chain and that can be very
expensive, depending on what the last negotiated feerate was for a commitment
transaction.  And we definitely saw some people kind of hitting this over the
last few months.  I know earlier this year, there were some people that had
forced closures that were quite expensive, because they had negotiated pretty
high feerates prior to their disagreement about what the current feerate was.

There's a lot of places where this disagreement about the current feerate can
come from.  One of them was in Bitcoin Core.  So, what do you call it?  I think
Bitcoin Core is fixing this, so there was a thing.  Anyway, Bitcoin Core had a
thing where when it first started up, would give you a feerate which wasn't
commensurate with market.  So, that was causing problems for Lightning nodes
that were using whatever Bitcoin Core told them, especially at startup.  Anyway,
so basically there was a lot of sources of bad information about feerates.  And
so, this just lets you ignore the feerate discrepancies.  What do you call it?
It lets you ignore these feerate discrepancies so that your channels aren't
force closing due to them.  So, it basically removes a force close vector.

But I wouldn't recommend using it on channels other than ones that you kind of
have a good reputation node that you're with, because if you let people pick
feerates that you don't agree with, like that are too low or that are too high,
depending on what your role is in the channel, this could either end up costing
you a lot of money if you end up getting force closed and it wasn't really
supposed to be that high, or it could make it such that it gets very difficult
to mine a commitment or a force closed transaction when you need to.  So,
there's like a timeliness factor there.

**Dusty Daemon**: Yeah, I think this is obviously a feature you just shouldn't
use.  But I think what happened is over the last, what is it, six months where
the mempool rates have been crazy, there were a lot of lagging nodes that were
caught.  You know, the tide went out, they weren't wearing shorts, kind of
thing, and they had their feerates that just were stuck at like 1 sat/vbyte.
And if one node is locked into the low feerate and the other one's using a
realistic feerate, everything breaks, right, they can't negotiate anything, and
you have to essentially force close those things.  So, we saw a whole wave of
force closures when the mempool feerates went up, just because some people, for
whatever reason, whether it be bugs or on purpose, had their nodes locked into
low feerates forever, and they all got exposed.

But there were a lot of weird situations people got stuck in.  They were like,
"All right, we're both trying to shut this down, but we can't actually shut down
the channel because during boot up, the feerate negotiation fails, so it's just
continually in this failure loop".  So, this is kind of like a nuclear option,
like just trust them for a second so I can get in there and force close it, or
whatever I want to do, sort of thing, and it ended up being needed in a lot of
weird places.  And obviously, Lisa mentioned the Core update for the mempool
feerate on bootup thing, which should resolve some of these.  But now there's
this nuclear option in case it happens again, and there's some problem that
hasn't been foreseen, is my understanding of it.

**Mike Schmidt**: Murch, I'm curious about this Core bootup feerate issue that's
being mentioned here.  Are you familiar with it?

**Mark Erhardt**: I was just trying to find it.  So, I remember dimly that there
was an issue when you restarted your node within the time frame that your
feerate estimates, your long-term feerate estimates, had not expired yet, but
you didn't see any transactions recently.  You would basically have a gap in the
time frame and you would use very old feerate estimates, from before you went
offline, and serve them up as your best guess.  I think that this is one of the
multiple issues that really needs to be addressed in Bitcoin Core's fee
estimation.  Generally, the approach is from 2015 and it's not been
significantly updated since.

So, yeah, between you and me, I would say that the feerate estimation in Bitcoin
Core is a tad too conservative, and something that takes the current mempool
into account would probably in most cases be better in practice for you.  So for
example, Bitcoin Core lags behind when the feerates are going down, and it also
lags behind a little bit when the feerates are going up, because it does not
take into account what's currently in the mempool, but only what has recently
been confirmed and it previously saw in its own mempool.

_Core Lightning #5492_

**Mike Schmidt**: Next PR to Core Lightning, #5492, adding USDT, not tether, but
User-level Statically Defined Trace points, and the means to use them.  We
covered this previously when USDT trace points were added to Bitcoin Core.  I'm
curious if, Lisa or Dusty, you guys have an idea of the kind of lift that was
involved in adding this to CLN, and then maybe you could also explain why these
sorts of trace points could be valuable in CLN.

**Lisa Neigut**: Yeah, I think Christian Decker is the one who worked on this
the most, so I read it.  Too bad he's not able to join us, because I think this
is definitely something he could speak the most to.  Looking at the PR though, I
would say the list wasn't terrible.  It's less than 500 lines of new code to get
this working.  Probably the biggest thing in setting it up if you want to start
using it, is you need to make sure that you've installed some new software.  So,
let me see if I can find the -- you just have to install the, I don't know what
it says the systemtap-sdt-dev is.  But basically if your machine has these
necessary tracing headers available in your system, then it'll start tracing by
default if you compile it with them turned on, so to speak.

What's cool about it, I think, is it gives us a very system level, maybe you
guys already talked about this, but it gives a really system level way of doing
tracing that is, if you don't have the tracing turned on, it doesn't have any
impact on runtime, is my understanding, so that's pretty cool.  I think one of
the downsides to this tracing stuff, I don't know if downsides is exactly right,
but you have to manually add trace points into your codebase.  So it looks like
we've added them for a couple of things.  Whenever we get a new block, we trace
how long it takes to get a new block.  We check how long it takes to add, to do
a couple of things in the wallet or around adding new blocks or filtering new
transactions, just so you get an idea of when a new block comes in, where are
you spending time parsing that block, which might be useful to trace.  I've been
doing some startup time stuff, and we have a lot of tracing around startup, we
have a lot of tracing around wallet level stuff.

I think it's notable that we don't have any tracing here around, like how long
it takes to sign an HTLC hasn't been added.  So, I think this is a good initial
thing.  But in order to get a really good understanding of where time is being
spent in CLN, we're going to need to go in and I think add more tracing certain
kinds of stop points.

**Mike Schmidt**: Murch, do you have any comments on tracing?

**Mark Erhardt**: Yeah, we added that to a BIP, or 0XB10C mostly, added that to
Bitcoin Core about two years ago, or so.  And the cool thing about it is that it
hooks directly into the Linux kernel infrastructure, so you can have way more
fine-grained logging than you would have if you had a custom log system built
into your software, because it doesn't print lines anywhere.  It actually gets
evaluated at the Linux kernel level, and you can, for example, collect
statistics or have custom scripts that directly interact with that data.  So,
yeah, super useful to do the nitty-gritty detailed tracing where you want to
collect how long things take or, yeah, to optimize, to find out which areas to
optimize for performance.  We also use them in coin selection, for example, in
Bitcoin Core.

**Mike Schmidt**: Lisa, Dusty, that wraps up our Core Lightning PR marathon for
this week.  Do you guys have anything else you'd like to say about either these
PRs or something that's forthcoming in the release, or anything for the
audience?

**Dusty Daemon**: I'm super-excited about my splicing code getting merged in,
it's the experimental mode.  I've been working on it a long time and I'm just
really pumped to be rebased, one, because it's exciting, and two, because I can
stop rebasing now that it's merged!  But the splicing code's in there now, you
can use it if you enable the experimental thing.  It's obviously in reckless
mode.  You should only use it if you're comfortable losing the funds you play
with.  But it's exciting to get it out there.  And the Voltage CTO, Justin, he
already was screwing with it before it got merged in.  He just took the branch
and he's been doing splices over at Voltage, which is fun, and he's been already
spotting issues.

So, this release is kind of meant to get people that want to be on the frontier
to help find bugs and issues, and Justin's already found two, so that's great.
If you want to be on the frontier, I'd love it if you turned on experimental
splicing with some funds you don't mind losing and just screw around with it,
that'd be awesome.  I'm pumped.

**Lisa Neigut**: Yeah, and I think all of the stuff, so all of these changes we
just talked through and the splicing work that Justin's been doing is all
currently available in the release candidate 1, which I understand got tagged
yesterday.  So for the bleeding-edge CLN runners, it's available and ready to
use and it's been tagged and go crazy.

_Eclair #2680_

**Mike Schmidt**: Dusty, you gave me a good segue to talk about this Eclair PR
#2680, which adds support for the quiescence negotiation protocol.  Maybe you
can talk a little bit about that protocol and how it's used in splicing?

**Dusty Daemon**: Oh, sure, yeah, the protocol that I could never pronounce for
the life of me, the quiescence protocol.  Essentially, the way Lightning
protocol works, it's designed to be as fast as possible.  So, it's sort of
designed so when messages are sent, I kind of just spam messages at you, and you
spam them at me, and they all kind of line up because the protocol is perfectly
designed for that to work, and that makes just everything that little bit
faster, which is important for Lightning.  But for certain more delicate things,
we need to switch to a turn-based protocol process, and that's called the
quiescence mode, or STFU for short, which is the, what, Something Fundamentals
Underway, I think the acronym is.

But this basically says, once you get a chance, stop using the normal protocol,
stop sending me messages, and just chill out, and we're going to slow down and
go turn by turn.  And this is really important for splicing, because splicing is
modifying a core piece of the channel, we can't have the channel modifying
underneath us as we're doing the splice action.  So, splicing is the first real
user of the STFU, quiescence protocol, but there will be more down the road, to
be sure.  And it basically just simplifies the protocol down, slows it down a
little bit, to allow us to do more complicated things.

**Mike Schmidt**: And so we're talking about Eclair in this scenario, and we've
covered Phoenix Wallet, which supports slicing.  But it sounds like Eclair
hadn't supported this particular protocol, and because Phoenix deals only with
Eclair, I guess we could get away with not supporting that particular piece of
the protocol.

**Dusty Daemon**: Yeah, I suspect so.

**Mike Schmidt**: Got it, okay.

**Dusty Daemon**: So, to interrupt going between CLN and Eclair, STFU is
probably the first step to get done.

_LND #7820_

**Mike Schmidt**: Great.  Next PR is to the LND repository, #7820, adds a bunch
of fields to the BatchOpenChannel RPC that were not previously available, they
were only available in the single OpenChannel RPC.  And the PR notes that it
reconciles these parameters between the two RPCs, and that the genesis of this
request was multiple clients wanting to assign initial channel fees while
opening channels in batches.  And while this PR was adding those missing initial
channel fee parameters, they decided to add all of the other fields from the
OpenChannel requests that were applicable to the BatchOpenChannel RPC.  Murch,
any thoughts on this one?  Okay, thumbs up.

**Mark Erhardt**: I'll let the Lightning people chime in if they have something
to say, but I don't.

_LND #7516_

**Mike Schmidt**: Next PR, LND #7516, extends the OpenChannel RPC with a new
utxo parameter.  And so that allows specifying one or more UTXOs from the
wallet, which should be used to fund this new channel.  And that's obviously
useful to make it easier to do coin control/coin selection when you're funding
using the command line.  And there was a note from this PR that, "We also have
to ensure that our wallet keeps enough funds to cover for the anchor reserve
requirement".  Maybe Lisa can help us.  Lisa, why do we need to have an anchor
reserve requirement here?

**Lisa Neigut**: Oh, yes, the anchor tank, as I've decided to call it.  So, this
has to do with anchor channels.  The anchor tank is, as the name says, related
to the number of anchor channels that you currently have out.  Prior to anchor
channels, anchorable, I should say, channels in Lightning, you were able to --
any of the amount of fees that might be needed to force close a channel were
kind of bucketed into each of the channels independently.  So, each channel had
its own little, I would say, onchain tank reserve that was kind of subtracted
out of each channel's balance internally, so the amount of sats that you had
available to transact with in that channel would get smaller or bigger just
depending on what the mempool feerate stuff was doing.

Anchors kind of pulled that out of each individual channel and made a more
global thing, that I'm calling the anchor tank.  So, it's a sats tank that you
need to keep UTXOs and some satoshis in such that if you need to force close a
channel or some channels at once, you have satoshis available basically for that
task.

**Mike Schmidt**: Excellent, thank you, Lisa.

**Mark Erhardt**: So, basically just a UTXO stash, not some offchain funds.

**Lisa Neigut**: Exactly, they have to be onchain and available to spend.

**Mike Schmidt**: Murch, any comment on this coin control feature added to LND
RPC?

**Mark Erhardt**: Sounds great.  You should always be able to choose your UTXOs.

_BTCPay Server #5155_

**Mike Schmidt**: Last PR this week is to the BTCPay Server repository #5155.
It adds a reporting page to the back office and it provides currently two
reports, a report about payments and a report about onchain wallet activity.
But there are more reports planned for the future, like payout reports and
refund reports to come in future versions.  You can also export these reports to
CSV, and the reporting feature that they've created here is extendable by
plugins, and you can add additional reporting information via plugins as well.
Murch, any comment on that, or anything else to wrap up the newsletter?  All
right.

Well, thank you to Lisa and Dusty for bailing Murch and I out on these Core
Lightning PRs, it's much appreciated.  Apologies for the late notice.  Tom,
thank you and Bob for joining and discussing and going back and forth on some of
the MuSig2 signing stuff, especially in the context of statechains.  And thanks,
as always, to my co-host, Murch.

**Mark Erhardt**: Thanks.  See you soon.

**Mike Schmidt**: Cool.

**Dusty Daemon**: Hey, thanks for having me.

**Mark Erhardt**: Thanks, guys.

{% include references.md %}
