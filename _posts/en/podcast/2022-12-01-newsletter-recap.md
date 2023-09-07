---
title: 'Bitcoin Optech Newsletter #228 Recap Podcast'
permalink: /en/podcast/2022/12/01/
reference: /en/newsletters/2022/11/30/
name: 2022-12-01-recap
slug: 2023-12-01-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt discuss [Newsletter #228]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-7-23/344142091-44100-2-e2228b68caf54.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: This is Bitcoin Optech Newsletter #228 Recap.  I'm Mike
Schmidt, a contributor at Optech and Executive Director at Brink, where we fund
open-source Bitcoin developers.  Hey, Murch.

**Mark Erhardt**: Hi, I'm Murch, I am also an Optech contributor and I work at
Chaincode Labs.

**Mike Schmidt**: All right.  Well, we have one news item this week, a few
releases and five PRs to review.  All right, let's jump into the newsletter.

_Reputation credentials proposal to mitigate LN jamming attacks_

So, Antoine Riard posted to the Lightning-Dev Mailing List a proposal around
reputation credentials to mitigate jamming attacks.  And so, we've had a couple
discussions on this recently, but as a quick overview, in Lightning you have
channels between nodes, and a couple of potential attack vectors, under a class
of attacks called channel jamming attacks, are either filling up the limited
Hash Time Locked Contract (HTLC) slots between particular nodes, or filling up
the value or liquidity in those channels.  And so, both of those types of
attacks are called channel jamming attacks.  And we had some research that Clara
and Sergei had published a few weeks ago, and Clara came on and discussed some
of that on recap, I think that was #226, about some of the research that they've
done and some potential recommended paths forward.

Antoine has a post here to the Lightning-Dev mailing list that sort of builds on
that and comes up with a credential-based reputation proposal, and I think he
has some sample code as well and some documentation around the spec for this
particular approach.  I'll pause there and, Murch, any comments on framing this
up before we move forward with the proposal?

**Mark Erhardt**: Yeah, let me rephrase that.  I think it's more of an
alternative approach rather than building on top of what we heard about two
weeks ago.  And let me say one more thing about jamming.  So, as you said
already, you can either block all the slots in the channel, which is the number
of payments that can be in flight at the same time, which we store in HTLCs.
So, for each payment that is being forwarded at a time, we have one HTLC in
flight.  So, we distinguish slow jamming and quick jamming, slow jamming being
somebody fills up one of those limited resources, either the slots or the value,
the forwarding capacity, and holds it for a very long time; or quick jamming is
just very quickly doing a rapid succession of many payments and temporarily
locking up the limited resource.

So, these two things require different types of fixes, as we heard about two
weeks ago.  For the slow jamming, we noticed that very quickly, that while
somebody is holding our resources and they're not giving them up, and they're
keeping it for a very long time, so it's easy to recognize.  But to rectify it,
we just need to find out whether or not we want to give resources to people in
the first place, so that's where reputation might come in.  And the quick
jamming one is, we just tried to get people to compensate us for every attempt
of a payment through our channel with an upfront fee.  So, these are the
mitigations from a proposal that we heard two weeks ago.  And I think that's
relevant because I think the new proposal by Antoine is maybe best understood by
putting it into the context of the previous.  All right, back to you.

**Mike Schmidt**: Yeah, thanks for elaborating there.  So, to get into a little
bit of what Antoine is proposing, right now when you're spending, you choose a
patch to the receiving node across multiple hops, and hopefully independent
forwarding nodes.  And you can describe instructions about how to forward that
on and who to relay next, and there's all kinds of encryption so that everybody
only sees the minimum amount that they need in order to perform that routing.
And what Antoine is proposing here is that each forwarding node should only
accept those instructions, those routing instructions, if there's one or more of
these introduced credential tokens that were issued previously by that
forwarding node.  So, instead of just blindly following the instructions, I
require some sort of credential to even consider routing that payment further.
And so, there's a couple ideas about how those credentials could be created and
distributed.

I think Antoine introduces the notion of bootstrapping this credential-based
system by having upfront fees, but there were some other ideas tossed in the
mailing list as well, which we can get to.  I'll pause there, Murch, to have you
opine on, I guess, the conceptual nature of this proposal in terms of
introducing credential tokens as a concept, and then also the idea of
distributing these credential tokens initially with upfront fees.

**Mark Erhardt**: Right.  So, the credential tokens, you can think of them as a
pass or ticket for someone to be able to route a payment through you.  And you
as a forwarding node would basically create a Chaumian token, a blinded token,
that you hand to a potential sender, and they hold onto it until they want to
use it, and then they show, "I have a pass, I can send a payment through you".
I think what clearly can be said at that point already is, the whole
introduction of another pass system or credential system will introduce a lot of
complexity, because you now have to have a way to acquire them, you have to
store them, but remember what they were for and how much payment they can allow
to pass through.  I think the acquisition of them is going to slow down and
maybe be a UX issue, especially for someone like a mobile client.

Honestly, so Lightning is not my main focus of interest, so I'm spitballing a
little bit here now, and I've also not followed the whole discussion.  I've read
into it a little bit now, but if I'm saying something wrong here, please feel
free to correct me.  I did an hour later on our Twitter thread.  And the notion
that if you're a mobile client and you're only online occasionally, and then
when you want to make a payment, you first have to find a route and then acquire
tokens for each hop along the route seems to me like a huge increase in
complexity.

The benefit that I've perceived that this proposal has so far is where the
approach we heard two weeks ago would require you to pay upfront fees that are
unconditional and are paid on every attempt for a payment.  With these tokens,
you do get some passes and you have to acquire them once, but they are returned
to you or you get new tokens whenever you make a successful payment.  So, while
you have to sort of buy yourself or make an effort to be credentialed for the
first time, after that you can continue to send with the tokens that are
returned to you.

**Mike Schmidt**: So then, I guess in that scenario, you're putting up some
value to initially acquire some trust to get those credentials, but moving
forward, I guess, based on previous success or speed or etc, if you're a good
routing partner, then you can potentially be earning those tokens outside of
just payment.  So, it does become, I guess then, a reputation-based system after
that initial bootstrapping, which is somewhat similar to the research we talked
about previously, right?

**Mark Erhardt**: I think that the effective game theory of how it would play
out -- and I should say, the games that people are playing and the positions
that they get into would end up being different.  So, with the proposal we heard
two weeks ago, my first instinct would be, you might grant people a trusted
status if you have out-of-band reasons to do so.  So, I don't know, your friend
also comes online with a Lightning node and you know that they're not going to
try to jam you, so you immediately give them a trusted status as an initial
setting.  And it is sort of a little bit of good faith that you put into these
people that you provide trust to.  They can abuse it probably exactly once,
right?  Once they send a jam, you will take their status as trusted and relegate
them to being able to only use part of your resources.

So, with the proposal we heard two weeks ago, you only score, or provide a
reputation for your neighbors, you keep that locally, and for each neighbor, you
either call them trusted or not trusted.  And trusted neighbors can use all of
your resources, so they can use all 483 HTLC slots, and they can use the whole
capacity for forwarding.  Non-trusted nodes can only use a subset of, say, maybe
you only use three-quarters of your resources for non-trusted requests.  So, a
non-trusted node could never jam you because they just never have access to all
of your resources.  We can, however, lock up your channel for other non-trusted
users, but that does not block your trusted peers or recursively or transitively
the trusted peers of your trusted peers to forward something to you.  So
basically, once that is abused, you take away the trusted status and they're
relegated to be like everybody else.

Here, it seems to me like the long con would be, I play a good peer for a while,
and then once I've acquired a ton of these tokens, I distribute them to a number
of different nodes and then I can jam someone because I have a lot of their
tokens and just lock up all their funds with a slow jam.  I don't know if that's
fair.

**Mike Schmidt**: Quick question on that.  These Chaumian tokens that are
distributed, that's done in a way such that if you issue credentials to the
same, I guess, entity, that's not tied, right?  So, if I issue two credential
tokens to you and then you abuse with one of them, I can't then figure out a way
to mark that second token as also tainted; is that right?

**Mark Erhardt**: Correct.  So, they're supposed to be blinded, as in the person
that handed them out for their node or the node that issued them can recognize,
yes, this is a token for me, but he does not know where it came from.  They're
fungible between each other, and they're not signed over to a specific
recipient.  I think there was something in the mailing list that they could be
assigned to a specific node so that basically both sides are locked in.  But I
think you can't really -- that would make the UX a lot worse also.

**Mike Schmidt**: Yeah, on a similar note, we noted in the newsletter that, I
guess, Clara actually brought up whether it was transferable between users, and
then all of a sudden you get this marketplace of credential tokens.  Yeah, but
it sounds like because those tokens are issued in a blinded way, that even if
there was a marketplace, you'd have to be trusting the person selling you these
credential tokens to not spend it, because there's no way to prove the chain of
ownership or prove that they couldn't use that token again in the future.

**Mark Erhardt**: Right.  And the issue of the token, of course, is that --
sorry, we keep saying token and maybe in the context of cryptocurrencies, token
is a bad term to use, because it could get confused with shitcoins.  But what
we're really talking about is this credential pass.  But why we say token is
because it's based on an idea of a Charmian E-cash token, I think.  So, yeah,
the server sees the token when they created and there's no way to prove that
they didn't hand it out to multiple people, or that they at some point just
stopped accepting all of the tokens that they gave out, or that they started
charging more credentials for the same amount of forwarding, or anything like
that.

**Mike Schmidt**: There were a few examples of criteria that you might use to
distribute credential tokens, either initially or in an ongoing way, and you can
really use any criteria.  Like you said, if I know you, I could just give you a
bunch of these credential passes or credential tokens based on that, it doesn't
have to be algorithmic or anything.  But one route that was mentioned that I was
curious of your opinion on, and I think that Antoine mentioned that there would
need to be more research into this, but the notion of UTXO ownership proofs;
what are your thoughts on that, on something like that as a criteria to, I
guess, earn these credential passes?

**Mark Erhardt**: I think that this ties into a push of trying to make Lightning
more private.  Currently, when people create a channel, they have to put up a
commitment transaction and basically they show everyone and tell everyone, "We
have a channel here and this channel belongs to that UTXO.  This is the UTXO
that we used to establish the channel".  So of course, this creates an onchain
footprint that directly links this pseudonymous name of the channel, the node
IDs of the channel that are involved, the two channel owners, with an onchain
UTXO.  So, there have been some ideas flying around on how we could be able to
prove that we have a UTXO as the two channel owners without revealing which UTXO
this is exactly.

So, I think this is really linked to that idea that, "Hey, I showed that our
channel is not virtual, but we actually have a UTXO somewhere, or even that I
have an unrelated UTXO of a certain amount.  And for this proof, I get an
initial token", so basically as a way of how I could bootstrap my initial token
acquisition.  And then after I have tokens and I make good faith payments for a
while, I would just basically have enough tokens to keep it rolling.

**Mike Schmidt**: Makes sense.  Anything else you'd like to comment on, on this
proposal?  We don't like to get too opinionated here, but it sounds like you're
preferential to a local reputation-based channel jamming attack mitigation
versus sort of spilling over a lot of logic into these tokens and potential
marketplace, and having things outside of the node itself and additional things
to keep track of, etc; is that right?

**Mark Erhardt**: Yeah, so I want to add a disclaimer first here.  I'm not a
Lightning expert and I have spent insufficient time to heavily opine on this,
but my initial response to reading this feels like it is a lot more complex and
it is not obvious to me what the big benefits is.  I think the biggest benefit
that I've identified so far is that we wouldn't have the upfront fee, as in you
don't pay fees for a failed attempt necessarily, but in a way you still do
because if a payment doesn't go through, you would lose a credential token
probably, you wouldn't get back the credential token.

I think that if this proposal came up again, I would want to know better how it
compares to previous ideas and what the benefits are that mitigate the
additional complexity.  Because it's very easy to argue that this is a lot more
complex, I don't think that is hard to argue at all, so why do we need this
additional complexity; what benefit does it have?  That's not obvious to me.

**Mike Schmidt**: Well, perhaps if the discussion continues and we end up
covering this sort of topic in a future newsletter, we can get Antoine on to
discuss a little bit more about some of the pros and cons and some of the
feedback that he gets over the coming weeks on this proposal.  But it sounds
like we can maybe wrap up this item.

**Mark Erhardt**: Yeah.  Getting the champions of proposals on to give something
a fair shake definitely seems like a fair thing to do.

**Mike Schmidt**: Yeah, and we do try to do that every week.  But this week,
Antoine was busy with all other obligations and couldn't join us, unfortunately.

**Mark Erhardt**: All right.  I think, yeah, we can leave it at that.  Well at
least, I don't have anything else to add!

_LND 0.15.5-beta.rc2_

**Mike Schmidt**: Okay, that's fine.  We can move on to releases.  This first
one is the LND-beta.rc2 that is, I believe, the same one that we discussed and
covered last week.  Any comments on that, Murch?

**Mark Erhardt**: It still seemed to mostly be a bug fix.  I think they added
taproot.  I think that was the same release that -- no wait, that's 15.5
already.  Yeah, no.

**Mike Schmidt**: It did have some bugs related to taproot with remote signing,
it says in the release notes.

**Mark Erhardt**: Okay, yeah, okay.  No, I think did we talk about 15.5 last
week already?

**Mike Schmidt**: It was in last week's newsletter, yeah.

**Mark Erhardt**: Okay.  Yeah, I think there was something with taproot fixes,
but I don't know anything else about it.  Again, not a Lightning expert.

_Core Lightning 22.11rc3_

**Mike Schmidt**: And the next release here is just the next release candidate
for Core Lightning 22.11.  And the release notes are, "This release introduces a
change in the versioning numbered scheme, which should be backwards compatible",
but I think we discussed that a bit last week as well.

**Mark Erhardt**: Yeah, actually I looked around last week and people that are
interested in what else is in this new major release, from the release tag
itself, it's a little hard to find, but look at the changelog.md in the main
folder of Core Lightning (CLN), and you will find the actual writeup list of all
the changes.

**Mike Schmidt**: Oh, okay, that makes sense.  Yeah, there it is.  Okay.  Well,
interesting nickname for this release, the Alameda Yield Generator!

**Mark Erhardt**: Yeah, CLN is well known to have a bit of a competition every
time who comes up with the most ridiculous version name!

**Mike Schmidt**: That's pretty ridiculous!  Okay, one thing that maybe we want
to comment on, maybe we don't want to comment on, is what's not in the release
section this week, 24.0.

**Mark Erhardt**: Well, yeah, so there's a story there.  Right at the time when
24.0 was tagged and packed up as a binary, we noticed that there were two bugs.
So, one bug is with the new Mac Ventura 13.0 release, there is a crash bug in
the GUI for Mac.  There's something about when you close the window, that the
processors don't talk to each other correctly anymore and it causes the Bitcoin
client to crash, so very uncool.  And the second one is, there is an issue with,
let me try to get that straight, if you use preset UTXOs in a transaction, and I
think also run a coin selection, so the preset inputs are not sufficient to pay
for that transaction by themselves, it may overcount the preset inputs and that
can cause you to overpay fees in the context of using subtractfeefromoutputs.

So, if you're using your full node with a wallet, I would suggest that you hold
off from upgrading to 24.0, even though the binary's available.  There is a bug
fix release coming, hopefully within a week, which is going to be 24.0.1, and
we're going to have a fix for the new macOS version and we will also fix that
wallet option.

**Mike Schmidt**: Okay, so a bug related if you're running on Mac and then
there's a bug.  It wasn't clear to me.  It's in coin selection, but it only
applies if you're doing manual coin selection, or what's the scenario there?

**Mark Erhardt**: Correct.  So, if you preset inputs, as in you do either via
the CLI, the Command Line Interface, or there's a tool in Bitcoin Core where you
can manually pick your UTXOs you want to use in a transaction.  I think either
would apply.  It causes the transaction building to start with a preset set of
inputs.  And there's an issue with deduplicating the preset inputs from the
available coins with which we run coin selection later.  So, theoretically it
can happen that if you have preset inputs and also need to pick more from the
UTXO pool to build the transaction, that it picks the same ones twice, and
obviously that can either cause you to not have enough funds to pay it, or if
you do subtractfeefromoutputs, that you pay fees for two of the same output
twice.  So, if you're building transactions with your Bitcoin Core, please hold
off on the upgrade.

**Mike Schmidt**: Okay, thanks for speaking to those, Murch.  I figured it was
worth mentioning, even though it's not something that's directly in this
newsletter.  We can talk about that more next week when we note that in the
newsletter as well, if there's anything further to discuss.

_Core Lightning #5727_

In terms of Notable code and documentation changes, first one here is Core
Lightning #5727.  This PR changes the JSON request ID from numeric to a string
type, which at first I thought was a rather bland change, but there's actually
some interesting rationale for that and things that can be done that is noted in
the documentation, particularly the scheme that CLN is recommending for creating
that string identifier, including information about the binary and the plugin,
and then having a counter based on that is part one.  Then part two is that you
can chain these identifiers together to come up with a bit of context.  So, if a
plugin is calling another plugin, which is calling another plugin, you sort of
get this chaining of the identifier that keeps track of that call stack, if you
will, and that can, I guess, help with debugging or logging or associating these
calls with the origin.

**Mark Erhardt**: Yeah, let me jump in there a little bit.  So, this PR
specifically deprecates the old numeric.  So, CLN has been doing this for a
while already, as far as I understand.  And yes, the purpose of the new format
is to keep track of the chain of events that led to a request being built, and
that's helpful for debug purposes, of course.

**Mike Schmidt**: Yeah, I think that's probably good on that item.

**Mark Erhardt**: Yeah, cool.

_Eclair #2499_

**Mike Schmidt**: Next PR here is an Eclair PR, #2499, "Allows specifying a
blinded route to use when using a BOLT12 offer to request payment.  The route
may include a route leading up to the user's node plus additional hops going
past it.  The hops going past it won't be used, but it'll make it harder for the
spender to determine how many hops the receiver is from the last non-blinded
forwarding node in the route".  So, I took that literally from the newsletter
description.  Murch, do you want to augment on maybe what the motivation is
behind specifying a blinded route when using offers, and why you'd want to do
that?

**Mark Erhardt**: So, we've been talking about offers for a very long time, and
I think it's an interesting topic insofar as it provides new mechanisms by which
nodes can negotiate a payment.  So, most people are probably familiar with LN
invoices, which is BOLT11, where essentially the recipient just provides
instructions for a potential sender to create a multi-hub payment to them.
Encoded is a preimage that the sender will use to build up the chain of HTLCs,
and the recipient has the secret, the preimage, and the HTLCs have only the hash
of that, which then can be resolved with the preimage.

But anyway, with BOLT12 you get a whole range of new things that you can do.
So, you can ask in band across, via the Lightning Network, with onion messages;
you can send a message to a node and say, "Hey, could you please generate an
invoice for me?"  And this is called a request for an offer, or this mechanism
is generally described as offers.  I guess, you know what, I really need to read
up more on Lightning if we're doing so much Lightning every week!

**Mike Schmidt**: We really are, aren't we?  Maybe that's a third co-host!

**Mark Erhardt**: We need to find a Lightning co-host, that's what we need.  So,
this is pretty popular among a number of implementations, but it's gotten a
little pushback from Lightning Labs, not necessarily because it's a bad idea,
just because they have different priorities right now that they want to spend
their engineering resources on.  So, the other implementations have been pushing
forward on the implementation of BOLT12, so CLN, Eclair and LDK also have been
having here and there a news item, "Hey, we can do this part of BOLT12 now, we
can do that part of BOLT12 now".  But as we've just seen with research this
week, about 90% of the nodes on the network are LND and don't support BOLT12
yet.  So, it's kind of fun to see how BOLT12 is getting picked up slowly by this
subset of the network, and I hope that eventually it will also encourage
Lightning Labs to follow suit and start offering more BOLT12 features.

Anyway, this request specifically now, one of the big benefits of BOLT12 that it
enables is, it provides the recipient with an ability to get more privacy.
Usually with the BOLT11 invoice, the recipient has just an invoice here and
says, "Here I am in the network, find a route to me in order to pay me".  So,
the sender has great privacy because they're building the route, and then of
course it's a set of onion layers where each hop can only see the previous node
that forwarded it to them and the next node that they're sending it to, and
nobody can tell who the endpoints are except the endpoints.  So, the sender only
gets seen by the next hop as just the previous node in the chain.  And the
recipient, of course, has almost no privacy from the sender, because the sender
knows who they're trying to send to.

So with BOLT12, one of the things that you get is something we call a blinded
route.  And the blinded route allows people to include essentially the last few
hops already as an onion package in their invoice.  So, instead of knowing the
recipient and building a path to the recipient, the sender now builds a route to
the outer barrier of that onion package.  So, maybe if Zoe is the recipient, we
would send it to Xavier two hops away, because Zoe encoded a hop from Xavier to
Yvonne to Zoe in this package and it's not visible to the sender what the last
few hops are.

What I thought was really exciting about this news item here now is the
realization that you of course do not have to leave the last hop as being the
recipient, you could make up arbitrary additional hops after that.  The onion
might look a little bigger then, but you don't have to use those hops, right?
Because Zoe already knows the secret, if there's two more hops, she would just
not build up those HTLCs, but use the secret directly to pull in the payment.
Anyway, I thought that was kind of fun to think about.

**Mike Schmidt**: Yeah, I think that the term that I saw in the PR was, "These
dummy hops", you could add these dummy hops at the end to obfuscate things a
bit, while actually having the ability to not pass those along, obviously,
because those two after you are actually just dummies.

**Mark Erhardt**: What I don't quite understand here is though, I mean does it
matter what you put in the onion here?  Couldn't you just put random data there,
because nobody but Zoe will unwrap that onion anyway.  So, what does it help to
make dummy hops here instead of just putting a little kernel of random data?
That would be my follow-up question here, but I haven't looked into it yet.

**Mike Schmidt**: Yeah, that makes sense.  I think I saw something about random
pubkeys or something, but yeah, I guess it could just be really anything.  Yeah,
a question for our future co-hosts.

_LND #7122_

Next PR is an LND PR, #7122, and it adds support to lncli for processing PSBT
files in binary format, so BIP174, which is the BIP that specifies PSBTs,
Partially Signed Bitcoin transactions.  In the spec, it notes that those PSBTs
could be formatted in either Base58 or binary formats.

**Mark Erhardt**: Base 64.

**Mike Schmidt**: Oh, sorry, so used to saying Base58!  Base64 or binary.  And
LND supported the Base64 encoding of PSBTs in plain text or from a file, but not
this binary PSBT format, and so this PR adds the capabilities to consume that
PSBT in binary format.

**Mark Erhardt**: I want to jump in and talk a little bit about the models of
PSBTs.

**Mike Schmidt**: Do it.

**Mark Erhardt**: So, if you want to generate a multi-participant transaction,
or if you even just want to, by yourself, generate a transaction that is signed
by multiple devices, you need to find a way to transfer these PSBTs, or just
incomplete Bitcoin transactions, between the participants, or between the
multiple devices.  So, this was a problem that was encountered by multiple
people or entities before, and they came up usually with their own ways of doing
that.  So for example, when I was working at BitGo, we had essentially our own
format on how we would send the incomplete transaction from the server to the
client to add their signatures, and then the client would send the half-signed
transaction back to the server for the server to countersign and get it ready to
be sent off.

So, what PSBT did was it created a public standard on how to format all the
necessary information so that other parties can provide their parts too.  But
now instead of, I don't know, Ledger having a way of doing that, Trezor having a
way of doing that, BitGo having a way of doing that, Bitcoin Core having a
different way of doing that, we now have a shared language with which we can
communicate these PSBTs.  So BIP174, the PSBT BIP, essentially just came up with
a best practice, "Here is how we express the incomplete transaction and transfer
it over the wire".  And yeah, so especially in the context of multisignature
contracting systems like Lightning, having support for PSBTs is pretty useful.
And what lncli is doing here is it's just catching up to the last bit of BIP174
that they hadn't been -- or actually, I haven't verified that, so I should take
that back.  They are catching up with a piece of the BIP that they haven't done
yet; I don't know if it's the very last.

**Mike Schmidt**: Murch, you have a bit of hands-on experience with PSBTs.  I
can essentially understand that PSBTs can be encoded in these two different
formats, the Base64 or in a file as binary.  Why have those two options; why not
just have one format?  Do you know the rationale and the motivation behind these
different formats?

**Mark Erhardt**: I do not, but I can guess.  So, I wrote this news item
actually, and I looked at BIP174 briefly.  I think Base64 would be something
that is more human usable.  The information is compactly represented, it's just
64 different characters that represent, well, binary data, essentially.  And
that would make it easier to copy it around or put it on a command line item.
So, having the plain text Base64 is more convenient to use in the command line.
And binary is just the under-the-hood language of computers.  So, I don't know
why the file is in Base64 as well, but maybe it's just, "Let's pick something
and that's how we're doing it".  But in a file, we don't care whether it's a
little longer or a little shorter, we're going to have to import the file
anyway.  We only see the file name, so whatever benefits binary might have here,
the downsides of having a much longer string doesn't affect us here.

So back to LND here briefly.  I believe that LND already had been using Base64
in files as well.  But in the BIP, it only specifies the Base64 plain text and
the binary in the file, so I guess they had their own interpretation of how they
wanted to do that.

_LDK #1852_

**Mike Schmidt**: Okay, that's fair.  Thanks for that.  Next PR here, LDK #1852,
and that allows LDK to accept a feerate increase proposed by a channel peer,
even if that feerate isn't high enough to safely keep the channel open at the
current time.  And digging into this PR a bit, LDK, when potentially interacting
with a channel peer that let's say is LND and uses different fee estimation
techniques, that LND node may come up with a lower feerate due to that.  And
because that feerate may actually be too low in LDK's expectation, LDK I believe
would previously close that channel.

What this PR changes is that instead of closing that channel at that already
lower feerate, at least take the slightly higher feerate and close it at that.
So, this PR changes the behavior to accept that higher feerate, even if it is
lower than what LDK would recommend to keep the channel open, and then can close
at that point.  Murch, thoughts on that?  Did you get a chance to dig into that
PR and what BlueMatt was talking about with interactions with LND and their fee
estimation?

**Mark Erhardt**: I have not dug into this deeply.  I think I want to take
another spin at the underlying problem here.  So, when the network, as in the
onchain transaction queue, the mempool, starts exhibiting a lot higher feerates,
say for example if an unnamed large Bitcoin exchange just decides to do all of
their half-yearly consolidations in one afternoon and suddenly increases the
average feerates by a factor 7, then a Lightning node might say, "Hey, dear
peer, I would like us to increase the unilateral closing fees on our channel in
light of the current mempool conditions, and could we please renegotiate the
state of our channel with new closing transactions that have a higher feerate".
So, even if there's maybe not a payment being forwarded, nodes can always
ratchet forward the state of their channel and create new closing transactions,
right?

So, what is happening here is now the partner of LDK is saying, "Hey, I would
like to increase the closing fees of our channel", which is a benign request
because the closing fee is always paid by the closing party, I believe.  So, the
LDK is now, instead of saying, "Yeah, but your fees are still too low", and
closing the channel, it's going to say, "Sure, I like the idea of having more
security.  If that makes you comfortable, let's do it".  And I'm not sure, I
think reading what we had written in our news item, a future change may close
channels if the feerate is still too low.  I think that currently, LDK does not
hit it with a hammer yet, so it doesn't necessarily get shut down, even if the
feerate is too low still.

**Mike Schmidt**: Yeah, I think that hypothetical is maybe exactly what happened
here, and I guess the peer to the LDK node, in this example being LND, was
potentially suggesting feerates that didn't even meet the mempool minimum
feerate, due to the large, quick increase due to those consolidation
transactions that were dumped.  And so, that might have been the motivation for
this particular PR a couple of weeks ago.

**Mark Erhardt**: Yes, the timing of this PR seems auspicious, 17 days ago.

**Mike Schmidt**: There are multiple offending exchanges doing consolidation
batches, right, or was that proven to be one entity?

**Mark Erhardt**: Actually, there was another one a week later.  So, Binance
dumped more than a whole mempool onto the mempool, which was especially funny
because now they started pushing out the tail end of their own consolidation
transactions from the mempool, because they had just submitted too many
transactions!  That increased the minimum feerate of -- sorry, just to
reiterate, when I say "the mempool", I'm talking about an abstract construct
that doesn't in reality exist, but more each node has their own mempool, but
they share a very largely overlapping behavior across the network, and I'm
talking about what most mempools would contain with the default configuration,
right?  So "the mempool" is just shorthand for most of the nodes running with
the default configuration will have this, right?

Anyway, so the default configuration of Bitcoin Core is to have 300 MB of memory
as allowed for keeping track of unconfirmed transactions.  And when you dump
something like 90 to 110 mega vbytes of transaction data, unpacking that and
putting that into the mempool data structure and looking up the UTXOs that are
being spent and adding that data and so forth, will end up having about 300 MB
of deserialized data in the memory.  So with only 90 to 110 blocks or so, you
tend to exhaust the default limit of full nodes.  And when you do that, you
raise the minimum feerate of that full node, because they start kicking out
transactions that have a lower feerate.  So the lowest feerate transactions get
kicked out first.  And if you end up dumping more than a whole mempool on it
with 13.5 satoshis per vbyte (sat/vB), you're raising the minimum feerate for
anything to be added to the mempool to 13.5 vbytes.  So, new transactions that
paid less than that wouldn't even get accepted to the mempool of a node.  They
would just say, "Hey, you don't meet my minimum feerate".

So, what I assume what happened here and caused LDK to merge this PR was the
channel partner of the LDK node was saying, "Hey, I would like to increase the
feerate of our closing transactions because it's unsafe below", but then
actually propose a feerate that still didn't meet those 13.5 sat/vB, and if they
had used that closing transaction it would still not have gotten into the
mempool in the first place.

**Mike Schmidt**: Excellent combining a bit of the mempool weather report with
this PR from LDK, I like it!

**Mark Erhardt**: Oh, the second one we can call out too.  Crypto.com did a
similar bullshit a week later, but at least they dumped a lot less on the
mempool so they didn't monopolize the whole mempool.  And they only did it at 8
sat/vB.  And both of them overpaid because they could have totally just waited a
day longer and done it at 1 sat/vB.  Rant end!

**Mike Schmidt**: I think I asked you this last week or maybe it was a couple of
weeks ago, in dollars or I guess in Bitcoin, how much did they overpay in these
two examples, if you've done the back-of-the-napkin math on that?

**Mark Erhardt**: I think Binance overpaid by 12.5 bitcoins or so.  Okay, so
there's a crutch here.  A block holds 1 million vbytes.  A bitcoin is 100
million sats.  So if you buy 100 blocks at 1 sat/vB, you're paying exactly 1
bitcoin.  Well, they paid for about 100 blocks, which probably was more like 120
blocks over the few days, and they paid 13.5 sat/vB.  So, they must have paid
something like at least 13, 14, if it was 120 plus 20% in fees.  And I strongly
suspect that if they had submitted it at 1 sat/vB, since blocks weren't full,
they would have instead of monopolizing the mempool, bid on all the extraneous
block space that was up for grabs.  And so, I would say that they overpaid at
least 10 bitcoins, even if they could have gone way lower, even if they wanted
to get through a bit quicker.  And so, I would say that's $150,000 for
consolidations that they paid that they didn't have to.  For crypto.com, I
didn't do the calculation, but a magnitude less maybe.

**Mike Schmidt**: So, doing that twice a year even when "the mempool" is fairly
empty, costs them roughly $300,000 a year to do it this way versus another way.

**Mark Erhardt**: To put it differently, they could pay somebody for a whole
fucking year to fix that!

**Mike Schmidt**: Yeah, or they could consult with you for a few months and then
donate the rest to charity.

**Mark Erhardt**: Exactly, yes.  Well, I don't want to spend a few months on it,
but I'm happy to explain it to them!

**Mike Schmidt**: Well, it doesn't look like CZ from Binance made it into this
Twitter Space today, so unfortunately we won't be able to ask him directly, but
CZ can feel free to reach out to Optech if he's concerned about burning those
bitcoins.

**Mark Erhardt**: I mean, it means that they obviously are making too much money
and it doesn't hurt them enough to fix it.  But when it gets into the range
where you can pay a person for a year to work on this, it's just it feels like,
"How about you just fix it once and then save that money?"  It's just sort of
like, I don't know, hard to watch.

**Mike Schmidt**: And, Murch, maybe I'm oversimplifying, but if they have some
sort of a script that's going through and creating a consolidation transaction
and then another one and another one and another one, I mean can you just add a
sleep in there?  I mean, just sleeping between broadcasting those transactions
and there you go, you trickle them out over a week or two.

**Mark Erhardt**: I mean, to be fair, they must be automatically generating a
bunch of transactions.  And since they're probably sending a ton of money
around, I would suspect that somebody is creating those offline with a tool and
then getting them all signed in a batch.  So, it's probably a lot more
convenient to generate these all at once, and it probably involves some level of
manual effort somewhere.  But yeah, you could just generate them at a way lower
fee, and then instead of dumping them on the mempool immediately, you could just
trickle them out and they would go through just fine, they would cost a lot
less.

**Mike Schmidt**: Well, you've somewhat steelmanned Binance's case here, but
yeah, to your point --

**Mark Erhardt**: That was not my intention!  I mean, improvements could be
done, and I think it would be compatible with the reasons why they might be
doing this.  But, yeah, never mind.

_Libsecp256k1 #993_

**Mike Schmidt**: Okay, we'll move to our last PR for this week, which is
libsecp #993.  And libsecp has build options which did not include some
experimental modules in the past, and I think these have been labeled as
experimental modules for a couple of years, it seems.  And now, these
experimental modules are now included by default when you build the libsecp, and
those modules are extra keys for working with x-only pubkeys, ECDH, and schnorr
signatures.

**Mark Erhardt**: Elliptic Curve Diffie-Hellman.  It's a way to generate a
shared secret between two parties.

**Mike Schmidt**: And so, these additional modules, which were behind and
experimental, are now default and included.  And there was some discussion about
a fourth module potentially being built by default, but there were some concerns
about how folks might use that particular module, which is labeled "recovery",
and maybe, Murch, you're more familiar with what that module does and why it's a
concern.  So, three were turned on by default now for folks to use in libsecp,
and then one still, you have to sort of override that default if you want to do
recovery.

**Mark Erhardt**: I am not super-familiar with this.  It sounds to me like a few
parts of libsecp have reached a level of maturity where people are confident to
just roll them out by default.  Key recovery is -- no, I don't know enough about
it to opine on this at this point.

**Mike Schmidt**: "Prone to misuse", was from the quote there.  So, yes, if
you're using libsecp, take a look and see if those are useful to you.  They've
been available, but now they're on by default.  All right, thanks, Murch.

**Mark Erhardt**: Thanks.  See you around.  Bye.

**Mike Schmidt**: Bye.

{% include references.md %}
