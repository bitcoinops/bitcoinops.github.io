---
title: 'Bitcoin Optech Newsletter #235 Recap Podcast'
permalink: /en/podcast/2023/01/26/
reference: /en/newsletters/2023/01/25/
name: 2023-01-26-recap
slug: 2023-01-26-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Valentine Wallace to discuss [Newsletter #235]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/73034387/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-6-5%2F916f95b8-2587-c267-7dcb-7900a4d8a515.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to the Bitcoin Optech Newsletter #235 Recap
on Twitter Spaces.  We'll do a couple of introductions and then jump into it.
My name is Mike Schmidt, I'm a contributor at Optech and I'm also Executive
Director at Brink where we fund Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs I do Bitcoin-y stuff.

**Mike Schmidt**: I think that's the briefest version of your intro yet!  Val?

**Valentine Wallace**: Hey, I'm Val, I work at Spiral on the Lightning
Development Kit (LDK).  And, yeah, I'm working on async payment stuff right now,
which is what I'm here to talk about.  So, yeah, thanks for having me.

**Mike Schmidt**: Excellent, thanks so much for joining us, Val.  We have one
news item before your news item, but you're free to jump in and comment on that,
and you're free to stay for the rest of the recording as well if you have
feedback on the Stack Exchange section or any of these PRs, or if you're busy,
you can jump off.

_Ephemeral anchors compared to `SIGHASH_GROUP`_

But we'll jump right into ephemeral anchors as compared to SIGHASH_GROUP.  And
this is a discussion spawned by AJ Towns on the Bitcoin-Dev mailing list.  He's
comparing something that we covered recently, ephemeral anchors, to a different
proposal that he wrote up, I think it was a year or so ago, called SIGHASH_GROUP
proposal.  And this is an opportunity for me to plug the Bitcoin Optech Topics
page, which is sort of a wiki, and this week was actually the addition of the
ephemeral anchors topic to the wiki.  So, give that a look if you want to read
up on ephemeral anchors.  We do not have one for the SIGHASH_GROUP proposal at
this time, so you'll have to jump into the mailing list post which we link in
#235 here.

Murch, does it make sense to maybe give an overview of ephemeral anchors before
we compare it to the SIGHASH_GROUP?

**Mark Erhardt**: Sure, I can jump in here.  So we've talked about this in a few
of the newsletters recently.  The main idea of ephemeral anchors is, we want a
way to decouple the picking of the feerate in channel closures from the event of
broadcasting the channel closure, because when we make our commitment
transactions, we don't know when we're going to try to use the commitment
transaction.  It might be a day later, it might be a year later, so picking a
feerate is completely blind to the time when we are going to try to use it.

So, there have been various ideas of how we could ensure that the commitment
transactions receive sufficient priority, because of course once you broadcast
your commitment transaction, you do want to get your money back, and the other
party might want to react if you broadcast an old state to penalize you.  But
one of these recent proposals is the ephemeral anchors proposal, which
essentially replaces the anchor outputs, for which we had two previously, that
were asymmetric and spendable by either side of the channel, with an OP_TRUE
script output, and the output has a value of zero.  So, they're both very, very
small, much smaller than outputs usually are, and they are not worth spending
usually.  So, to prevent them from polluting our UTXO set, we want to ensure
that if they are created, they are also always spent.

So, the idea is to make them ephemeral in the sense that the moment they are
created, they're also being spent, and we do that by adding a second transaction
that CPFPs the channel closure and attaches to the ephemeral anchor and
immediately spends it.  And this second transaction actually provides the fee
for the channel closure and itself by attaching to the anchor.

So this is a proposal, I think, that Greg Sanders brought it up in December or
November last year, and it's gotten a pretty good review so far.  We've already
reduced the transaction size, because with these outputs, transactions could be
smaller, the permitted transaction size, that is.  Yeah, how's that for
starters, Mike?

**Mike Schmidt**: Yeah, I think that's great.  I think you've outlined the
problem space, which is that offchain protocols, including Lightning, need the
ability to settle a transaction onchain potentially.  And the time that those
offline transactions are being created, those parties may not be privy to what
the feerate will be in the future.  And so there's a bunch of heuristics to
guesstimate what those are, but really a better way might be paying those fees
at the time that you actually need that transaction to be confirmed.  And so
that's sort of the problem space.  And ephemeral anchors, as you outlined, is
one mechanism to do that that is similar, but maybe a bit cleaner than the
anchor outputs that are used currently.

Okay, so that's ephemeral anchors, but how does this fit into SIGHASH_GROUP?
Maybe if you could give an overview of that, since I don't think I'm as familiar
with it as you are.

**Mark Erhardt**: So, when you create a signature in Bitcoin transactions, this
signature explicitly states to what parts of the transaction it commits.  So for
example, you can make a SIGHASH_SINGLE input that only commits to itself as an
input and all of the outputs, I think.  There's a great article by Raghav Sood,
maybe we can link to it later, He goes into all of the SIGHASH flags.  The
default behavior is SIGHASH_ALL, where an input will not only commit to itself,
but all other inputs and all outputs in a transaction.  So, this is the standard
behavior.  Everyone that adds a signature commits to the whole transaction as it
is.  But if you want to do certain multiparty transactions or other
constructions, you may want to only commit to smaller parts.

So, AJ's proposal from 2021 is the SIGHASH_GROUP proposal.  It provides a way
of, instead of just committing to a single input or the whole transaction or
nothing at all, you can declare what set of outputs you commit to.  So, each
input in a SIGHASH_GROUP would say, "I start a group of three outputs".  And
then the next input, for example, could say, "I want to use the same group as
the previous input".  So now, input one and two would commit to the first three
outputs, and then maybe the third input says, "I want to start another output
group of two", and it would commit to output four and five.  So, these two
packages could be put into transactions separately, or they can now be combined
into transactions without interactivity, which saves of course one transaction
header.

What AJ does in his mailing list post here is, he compares his own proposal from
2021 with the new ephemeral anchors proposal by Greg Sanders, and comes to the
conclusion that the ephemeral anchors proposal gains, or achieves, most of the
benefits that he was aiming for with the SIGHASH_GROUP proposal, and that it
does not require a consensus change, but only a change in the relay policy in
the mempool policy of the nodes.  So, it will be much easier to roll out, and he
thinks it gets most of the benefits.

**Mike Schmidt**: So, because the ephemeral anchors proposal piggybacks on v3
transaction relay and that proposal does not require a soft fork, that we could
potentially get ephemeral anchors easier than we would something like adding a
signature hash (sighash) flag; is that right?

**Mark Erhardt**: Yeah, also the ephemeral anchors themselves, they only needed
changes in the standardness rules.  So, as people might be familiar, the mempool
is governed by standardness rules and we will only accept standard transactions,
or specifically transactions that pass its standard test in the Bitcoin Core
codebase, to the mempool, and we will only forward transactions that are in our
mempool, so we will not forward transactions that are non-standard.  For
example, when they're bigger than 400,000 weight units, they're non-standard and
we will not forward them.

So, the ephemeral anchors, I think currently could be non-standard, because they
could potentially lead to transactions that are smaller than the previous
standardness rules for transactions.  But other than that, there's no consensus
rules that prohibit them.  Whereas the sighash rules, how signatures can commit
to parts of transactions, they are consensus rules.  So, adding another sighash
rule would be a consensus change, yeah.

**Mike Schmidt**: I don't know, did you see instagibb's response to our Twitter
thread on this topic; did you see he's had somewhat of a correction?

**Mark Erhardt**: I did not.  Please fill us in.

**Mike Schmidt**: Yeah.   We can have him on in the future to discuss this as it
seems like it's a sort of popular topic lately.  But what he says is, and he's
quoting our newsletter where we say, "SIGHASH_GROUP would still have two
advantages.  First, it could allow batching".  And so, his bit of asterisk to
this is that, "SIGHASH_GROUP doesn't make any effort to stop pinning vectors,
while the ephemeral anchors/v3 proposal is explicitly aimed at stopping pinning
vectors".  He notes then, "If we solve pinning for SIGHASH_GROUP batching, then
ephemeral anchors would probably work too".  So, he had a little caveat to this.
I can link this in the chat as well.  And he's just merely pointing out that the
problems are related and that SIGHASH_GROUP doesn't necessarily target pinning,
per se.

**Mark Erhardt**: Yeah, that's a fair point.

**Mike Schmidt**: Val, you may or may not be familiar with this topic, but I'm
curious more broadly how much folks in the Lightning space are paying attention
to these types of discussions.  So, feel free to comment in detail if you're
familiar with either of these proposals, and feel free to comment more generally
if you're not.

**Valentine Wallace**: Yeah, definitely.  Well, it definitely all seems very
important and relevant with all the mempool pinning discussion.  I'd say
personally, I don't really study that much of it, but we have members of our
team, particularly Wilmer, has been working on anchor outputs.  So, I would
imagine this would be something that he would evaluate, see whether it's
relevant for us, and maybe chip in opinions, or whatever.  But yeah, it's
definitely at the top of everyone's minds, anchor outputs, mempool pinning.  So,
yeah, I'll be excited to see where this goes.  It sounds like a great plan they
have.

**Mike Schmidt**: So, it sounds like you're like some of us that are hopeful and
eager for a solution, but not necessarily yourself following the day-to-day
approaches to actually getting the solution, although some folks are on your
team.

**Valentine Wallace**: Yeah, I'd say that's pretty accurate, unless for whatever
reason I just have a ton of free time, which hasn't happened and isn't going to
happen anytime soon.

**Mike Schmidt**: That's fair.  Murch, anything that we didn't touch on in this
mailing list post that we covered?

**Mark Erhardt**: I think we got it.

_Request for proof that an async payment was accepted_

**Mike Schmidt**: Okay, excellent.  Well, we can move on to the second news item
from this newsletter, which is titled, Request for proof that an async payment
was accepted.  Val, do you want to maybe give an overview of the context here
and what is the issue, and maybe we can dive into if there's been any responses
to your post?

**Valentine Wallace**: Yeah, definitely.  So, kind of to back up, a problem in
Lightning is that you can't receive a payment if you're offline.  So, that's a
problem for mobile users, for example, because even if they put their app in the
background, they probably won't be able to receive a payment to their wallet if
it's non-custodial.  So basically, async payments is a proposal that came out on
the mailing list from BlueMatt in end of 2021, I think.  And the basic idea is
that the sender or their Lightning service provider (LSP) will hold on to a
payment until they get an onion message from the receiver saying like, "Hey, I'm
online, you can, you can release your payment now".

So, this is kind of an improvement over previous "async Lightning payments"
because the previous ones tended to tie up all the liquidity along the route,
whereas in this one, it's only tied up on the sender's end and they had already
said goodbye to those funds anyway.  So, yeah, does that kind of, I guess, make
sense so far, the motivation and how it basically works?

**Mike Schmidt**: Yeah, I think that's great.  I'll use this as another
opportunity to plug the topics listed on the Optech website.  The async payments
was something that we've added in the last month or so as well, but Val
summarized that perfectly.  So, I think you've given us a bit of the context.
Feel free to continue.

**Valentine Wallace**: Yeah, okay, great.  Yeah, I know that's a great topic.  I
was looking it over as well yesterday.  So, basically I sent out an email, and
the email relates to a research question that's about basically, how will the
sender get an invoice from the receiver because the receiver's offline when the
sender wants to send presumably?  So, the naïve solution to this would be for
the receiver to generate a bunch of invoices and give them to their LSP, and the
LSP can just give out those invoices.  But that's actually trusting the LSP a
lot, because the LSP could just give out the same invoice over and over, and
after the first invoice is paid, they'll know the preimage and then they can
take all the money after that.  So, it's a lot of trust to be having in them.

I guess I want to note that this doesn't halt async payment progress entirely,
because right now the plan is to base it on Hash Time Locked Contracts (HTLCs),
but the receiver's LSP will just give out a keysend invoice; that's an invoice
that loses the proof of payment property because the sender supplies their own
image in the onion, but it doesn't have this trust in the LSP, if that makes
sense.  So, we're okay with that as a stopgap, but in the long term, it would be
nice to at least have the option of getting proof of payment back.

So, the research question is basically, what is a scheme that allows a regularly
offline receiver to create a reusable invoice for their LSP to provide to
senders, such that senders have proof of payment?  And the thinking is that this
will likely be built on Point Time Locked Contracts (PTLCs).  And so, yeah, that
was the question.  And actually, I did get a response last night at around
10:00pm, so I wouldn't say I fully absorbed it, but yeah, down to talk about
that as well.  But does that kind of make sense?  I feel like that was a lot.

**Mike Schmidt**: Yeah, I think it makes sense at a high level.  One thing that
I'm curious about maybe on the non-tech side of all this is, is there a group
that you go to, to propose these sorts of research topics?  I see that you went
to the mailing list.  Is that where everybody goes, or is there something else
outside the mailing list where these kind of research questions are discussed?

**Valentine Wallace**: Hmm, I do feel like the mailing list is kind of the main
one, I want to say.  But I feel like if you've just been developing for a bit,
you might also just message people individually.  You could probably also go to
the Lightning-Dev IRC channel to kind of get preliminary thoughts, or even
individual project channels like LDK, Core Lightning (CLN), Eclair, LND.  They
probably each have research channels in their communication forums too.  So,
yeah, there's a few options, I guess, but mailing list is good.

**Mike Schmidt**: In terms of a solution for HTLC-based or PTLCs, how soon could
we expect something like PTLCs?  That seems a bit far off, or am I off base
there?

**Valentine Wallace**: Yeah, you're not off base at all, they are far off!  I
mean, hopefully in the next two years, but I think the PTLC scheme is being
built on top of taproot.  So, taproot rollout, you already have to, I think,
close your channels and reopen them to get taproot channels, I'm pretty sure.
Mark, do you know if that's right?  So, that's going to be a minute.  And then
the other thing about PTLCs is that every hop in the route needs to support
them.  So, we're definitely going to be supporting HTLCs for a while.

**Mark Erhardt**: I think that PTLCs and HTLCs might actually be both compatible
with either base transaction.  So, the PTLC or HTLC would only get added as an
output to the commitment transaction.  And thus, if both sides of the channel
speak taproot or can at least produce schnorr signatures and understand PTLCs, I
think that PTLCs could be added to penalty transactions.  I do think it makes
sense though that with the rollout of P2TR as the address format for channel
anchors, funding transactions I should say maybe, that we also look into PTLCs
more.  And yes, in order to route a payment via PTLC, all hops along the route
have to be compatible.  So, only once we have a significant portion of the
network updated to understand PTLCs, we will see them up here.

**Valentine Wallace**: Yeah, and I guess I agree with all that.  I guess one
more nuance, I remember I asked Wilmer about this, and he said that PTLCs could
be built on today's non-taproot channels, but basically they're not going to, I
think is the plan right now.  But yeah, that could be in flux, but yeah.

**Mike Schmidt**: Murch, any comments or questions on the topic that we didn't
address?  I'd like to hear what the solution is.

**Mark Erhardt**: Well, yeah.  I would like to get Val's first impression of
AJ's proposal.

**Valentine Wallace**: Yeah, definitely.  I mean, I think it looks really good
from what I've seen.  I'm not a cryptographer, so I might butcher the
terminology a little bit, but my understanding is that the basic idea is that
the sender and the receiver's LSP -- okay, so PTLC invoices have a point that
needs to be satisfied.  So, rather than preimage and hash, it's like the point
and then the secret to that point.  So basically, the receiver will have a
static invoice with a point, but the sender and the receiver's LSP will get a
new point by tweaking the original invoice's point using both Bob's public key
and Bob's public signature nonce, which I'm not sure what that means, and some
kind of receipt message such as, "Alice has paid me $50, signed Bob", some
message like that.

So, basically they'll take all those ingredients and use that to tweak the point
from the invoice, and then Alice will send a PTLC payment that pays to this new
tweaked point.  And then basically, when Bob resolves the PTLC output, update
fulfill PTLC message, he will reveal the secret to this new tweaked point and
that will function as Alice's proof of payment.  So, yeah, there's one more
aspect.  Does that kind of make sense?  It's kind of in the weeds.

**Mark Erhardt**: Yes, that does make sense.

**Valentine Wallace**: Okay, great.

**Mark Erhardt**: Mike, someone asked whether we could add the link to the
mailing list post to our tweets.  Do you have it?

**Mike Schmidt**: To append it to our existing tweet thread, or to this tweet
thread?

**Mark Erhardt**: To the Spaces.

**Valentine Wallace**: I texted it to you, Mark.

**Mark Erhardt**: Okay, thanks.

**Mike Schmidt**: I'll do that shortly.  Yeah, continue, sorry.

**Mark Erhardt**: Okay, so let me try to see whether I got the gist of this.  AJ
suggests that the LSP can take the invoice information because the LSP has to
have invoice information already, otherwise they can't send invoices on behalf
of their offline user, and tweak it in some manner so that, I think, the payment
can still only be collected by the receiver when the receiver comes online.  But
the LSP essentially has given a proof already that the LSP got the payment for
the receiver.  Is that roughly right?

**Valentine Wallace**: Can you say that again?  The LSP…?

**Mark Erhardt**: Okay.  So, we are trying to facilitate a payment to a mobile
client that is offline.  The mobile client has provided an invoice, or a set of
invoices, to their LSP so that the LSP can send out invoices on their behalf.
The LSP gets however a tweaked invoice which may even include a last hop
already, so that the receiver can still be the only one that can actually
trigger the whole payment, but the LSP can still provide sort of a proof that a
prepayment or a payment commitment has been established.

**Valentine Wallace**: That could possibly…  I mean, I think the LSP just
doesn't have the tweaked invoice, I think they just have the invoice.  I mean,
they don't have the secret to the invoice's point, but yeah, I guess I probably
didn't explain that.  But I think there's the invoice and then there's the
invoice's point, which is all signed by the receiver, Bob.  And Alice is paying
a tweaked version of the point from the invoice, and I'm working with the LSP to
get that tweak.  Basically, the sender will work with the LSP in the sense that
they'll get a nonce from the LSP that was originally generated by the receiver,
Bob.  And in that way, when the payment actually comes through, the LSP will
tell Bob, "Hey, you're about to get a payment.  It corresponds to this nonce
that you were the one that generated".  Bob can see that the nonce has never
been used before, and that's how he'll know that it's a unique payment and that
it's legit.

**Mark Erhardt**: Okay, I was homing in on the wrong aspect here.  I see, cool.
So either way, only the receiver can pull in the payment, but the receiver now
has (a) an assurance that an invoice did not get used multiple times, which
breaks this possibility of the LSP of collecting money via the same invoice
multiple times; and (b) the sender also has proof that they sent the payment, so
the LSP cannot deny having sent the payment.

**Valentine Wallace**: Yeah, exactly.  In my notes, I wrote the sender can say,
"Your Honor, if you take this static PTLC invoice, where the point to unlock it
is B, you can see that if you tweak that point with this message saying that I
paid this nonce and the public key of the receiver, the secret is S.  Only the
receiver could have revealed that to me because he signed the original invoice
with P, so therefore I paid.  But yeah, I need to look into this a lot further,
but it sounds really promising.

**Mark Erhardt**: Cool, so we're expecting your response on the mailing list at
your next visit!

**Valentine Wallace**: Definitely, absolutely!

**Mike Schmidt**: And just a heads up to folks in the Space, I've shared a
couple of different tweets, the first one contains a link to the mailing list
post that Val posted a couple of weeks back; and then the second one was the
response from AJ in the last day or so, which is what we've been discussing for
the last few minutes here, so you can jump into those mailing list posts and try
to follow along as well.

**Mark Erhardt**: Okay, so we seem to have an approach now how we can
significantly improve the whole flow and protocol around async payments.  Do you
have more on that, or do you think we've got the topic covered?

**Valentine Wallace**: Yeah, I think that's pretty good.  Yeah, I guess some
final notes.  I issued a correction to the email that was sent out.  It doesn't
change the fundamental point, but yeah, just so you know.  And also, I asked
Matt what he thought about the scheme, and he thought of AJ's scheme, and he
thought that there was a non-stranding attack, potentially.  Although in AJ's
email, he does say people might have to prepay for nonces, but that's just
something to consider.  This is a developing story, I guess.  Yeah, that's it.

**Mark Erhardt**: So, it's always a little more complicated than the first idea!

**Mike Schmidt**: Well, thanks for coming on, Val, to discuss this with us.  It
sounds like, like you guys mentioned, this is an evolving idea, evolving story.
Perhaps we'll have you on in the future when there are some updates.  Like I
said earlier, you're welcome to stay on for the next 20 minutes or half hour as
we complete the newsletter, but if you want to get responding to AJ right now,
feel free to drop as well.

**Valentine Wallace**: Awesome.  Thank you so much for having me, that was
really fun.  Yeah, definitely down to come on in the future.

**Mike Schmidt**: Excellent, thanks, Val.  All right, next section from the
newsletter is Selected questions and answers from the Bitcoin Stack Exchange.
Murch, I'm curious, do you guys have a Stack Exchange topic of the week?

**Mark Erhardt**: So, okay, that's a sore point a little.  I started that in
2016 for the first time, and my learning experience was that doing one every
week is a lot of work and sort of wears the community down.  But we recently
restarted it, and we're doing a topic of the week once a month now, and we've
done it twice.  We did RBF, we got a bunch of, I think, like seven posts out of
it, and a bunch of edits on old topics; and we did actually one on LDK, which
unfortunately only prompted a few questions to be added the week after the
topics week.  But so, we're currently talking about what our February topic of
the week will be on Stack Exchange, and I'll announce it once we know.

**Mike Schmidt**: Excellent.  Well, anybody who doesn't visit the Bitcoin Stack
Exchange, I can say as the author of this segment of the newsletter each month,
that it's quite interesting to go in maybe once a month and take a look at the
recent questions and answers, especially if you sort by votes, you can get some
interesting results.  I use it when I put the segment together to try to find
interesting things, and I'm sure there's things that aren't part of this list
that folks could get value from.  So, definitely check it out.  And there's a
lot of prolific contributors on there as well.  So, the first question -- oh, go
ahead.

**Mark Erhardt**: I suspect that a few users made some New Year's resolutions to
contribute more to Stack Exchange, because January has actually been pretty
great.  We've had a lot of contributors return and come in for the first time,
and I have the feeling that we've had more questions than answers this month.

_Bitcoin Core signing keys were removed from repo. What is the new process?_

**Mike Schmidt**: First question from the Stack Exchange is, "Bitcoin Core
signing keys were removed from the repo.  What is the new process?" and it
sounds like the motivation for this question was somebody trying to verify a
binary and I think they were following something from some outdated
documentation, but it was a good excuse to bring up guix and bring up build
attestations and the separate guix repository.  So, maybe a question for you,
Murch, what are the signing keys; why did they move; and what's guix?

**Mark Erhardt**: Right, so Bitcoin Core was signed by a Bitcoin Core signing
key, essentially a dedicated key to authenticate a release, and that was
controlled by the old lead maintainer, Wladimir. And so, the process changed a
while back where instead of using gitian, where multiple people would locally
build the same binary, and only if they agreed on -- like, if the produced
binary produced the same hash on their machines, they agreed that, yes, they had
succeeded at crafting a binary from the source code that they all overlapped or
could attest to.  And then that binary, after the gitian process, was attested
to by the signing key though.

So now, we move to a new process, called guix, and that's a slightly different
build chain, and it has everybody produce their own guix attestations.  So,
anybody that does their Bitcoin Core build at home now, signs these attestations
with their own keys, and you would know, as a user that wants to verify that
they got the correct binary, you can look at all of these attestations
separately.  And I think you can easily see that they all agree with each other
if they do, but the keys of this open group of guix builders are now collected
in the repository that also collects the attestations.

So, the process around verifying the validity of a binary is slightly different.
And also, if you're interested in becoming one of the people that builds the
releases, attests to their validity themselves, I think there is documentation
on how to bootstrap yourself.

**Mike Schmidt**: Yeah, and in fact when we had Gloria on one of these recap
discussions, I think this was right around the 24.0 release candidate timeframe,
she was actually asking the community to become more involved in that.  So,
Murch, is that something that anybody can just go ahead and do, or do you have
to be a Bitcoin celebrity or Core developer to do that?

**Mark Erhardt**: No, you don't even -- well, I think it helps if you're a
developer because the skillset needed to get it all running aligns well with
that, but you don't have to actually contribute to the codebase at all.  I
believe it involves setting up a virtual machine and installing a couple of
packages, and then the guix bootstrap itself runs for a few hours or so.  But I
would hope that the documentation is sufficient for anyone that's interested to
get running with that.

**Mike Schmidt**: Well, if you're interested in learning more, dig into that
repository, which I believe houses the documentation, and you could be doing
guix builds and learning about signatures and potentially have your signature
committed to the repository as well.

_Why doesn't signet use a unique bech32 prefix?_

Second item from the Stack Exchange, "Why doesn't signet use a unique bech32
prefix?"  So, this is a user on the Stack Exchange wondering why both testnet
and signet use the tb1 address prefix, instead of having something different for
testnet versus signet.  So, address prefixes are something folks are probably
familiar with.  If you see a bech32, you'll see a bc1 prefix, and if you see a
P2PKH address, it'll be a different leading symbol.  So, there's these different
symbols that represent each of the addresses, and so why not have a signet one?
Murch, are you familiar?

**Mark Erhardt**: Yeah, so I think the idea was that all testnets could use the
same one, then you don't have to have separate address creation and you can use
a node on signet once and skip over to testnet and start using it there.  But in
hindsight, that probably was not optimal because people usually have dedicated
nodes for different dedicated systems, and especially if there's a one-to-one
mapping between networks and prefixes, it's easier to store that in
dictionaries, so having overlap there where signet and testnet have the same
prefix.

For example, we ran into that issue at BitGo too when we were setting up a
signet node for the first time, because our software implementation assumed that
every network had a dedicated prefix.  And this assumption did not hold for
signet and testnet, and only for bech32 addresses, I think.  Actually for other
address types, it did hold.  So, yeah, I guess there are some trade-offs here.

**Mike Schmidt**: So, maybe some confusion, maybe some slight complexity on the
back end, but no loss of funds concerns, because we're just talking about signet
coins and testnet coins, so no concern.

**Mark Erhardt**: Yeah, exactly.  I mean, you could have a little confusion, for
example, if somebody gives you a tb1 address and then you assume that you they
want to get paid on testnet but they wanted to get paid on signet, and you can't
directly see that from the prefix.  So, that might be another kind of UX
kerfuffle, but yeah, who cares; it's testnet coins, right?

_Arbitrary data storage in witness?_

**Mike Schmidt**: Yep, exactly.  Third question from the Stack Exchange this
month is about arbitrary data storage in the witness, and RedGrittyBrick pointed
out one of several recent taproot spends that contained a large amount of
witness data.  And some other users commented on that question on the Stack
Exchange pointing to a project that I was not familiar with, called Ordinals.
And that project actually has a subservice that allows you to embed data using
their software into the witness.  The example provided in the question actually
had an associated image on that Ordinals website, where you can see the image
version of the data that was stuffed into the witness for that particular
transaction.  So, I guess this is what we do when fees are low, right, Murch?

**Mark Erhardt**: Yep, fees are too low.

**Mike Schmidt**: So, I thought it was interesting just that bit of trivia of
what's going on and that that project is doing that.  I think that the actual
question from the Stack Exchange was, "Would these sorts of transactions be
relayed by Bitcoin Core; and will it affect the size of the UTXO set?"  Sipa on
the Stack Exchange answered the UTXO set question, "It won't be stored in the
UTXO set because the UTXO set only contains outputs and the witness data is
input-related.  And to the question of whether these transactions would be
relayed, they have large witness components, I don't know if we have an answer
from the Stack Exchange on that.  I did look into this project and they were
saying, "Keep your witness size under 400,000 weight units".  I assume that
would be the cutoff for the relay for Bitcoin 4.0.  Are you familiar with that?

**Mark Erhardt**: Actually, a transaction is non-standard if it has more than
400,000 weight units.  So, not only does the witness component need to be less
than 400,000, but the transaction total needs to be below 400,000.  So, I guess
the point here to make is, we are very defensive about the size of the UTXO set,
because even pruned nodes and basically any node needs to keep that around, and
most nodes actually keep that in memory, because that is what we look at to
validate transactions, to see whether funds are available for spending.  So, we
do want the UTXO set to remain manageable.

But the blockchain is already limited in size.  It cannot grow more than, well,
4,000,000 weight units roughly every 10 minutes.  So, I guess people using more
block space is less of an issue than people using more UTXO space or increasing
the size of the UTXO set.  I think that people using the blockchain to store
NFTs and, well, arbitrary data is a self-healing problem, because once fees go
up and this becomes popular, people that do financial transactions will just
outspend those transactions, because a financial transaction will be smaller and
we'll be able to pay a slightly higher feerate and then get priority over this.
So, they might soak up some of the abundant block space lately, but I guess if
the NFTs were super-valuable, they might be able to compete with financial
transactions and slurp up more of the block space, but in the long run, maybe
that's a personal preference, but I just don't see the high value in NFTs, so
I'm not very concerned about that.

**Mike Schmidt**: I think that's a fair assessment.  We've run into these issues
previously.  I forget, I think it was Jeff Garzik's company doing some anchoring
into the Bitcoin blockchain in an inefficient way and some fee spike period came
around.  I don't think I see them onchain doing that any more.

**Mark Erhardt**: I think that was the Proof-of-Proof by Veribit.  I don't think
that Jeff Garzik was associated with it.

**Mike Schmidt**: Okay, Veribit.

**Mark Erhardt**: We had OP_RETURN spam about two years ago, where something
like 30% of all transactions started doing OP_RETURNs.  And that very quickly
went away when we got a bit of a feerate increase.

**Mike Schmidt**: Like you said, a self-healing thing.

_Why is the locktime set at transaction level while the sequence is set at input level?_

Next question from the Stack Exchange is, "Why is the locktime set at a
transaction level while the sequence is set at an input level?"  And so, this is
a question about different types of timelocks, and there were two answers to
this question that I thought were noteworthy.  The first one is RedGrittyBrick
responding, quoting an email from Satoshi to Mike Hearn, and this is from 2011,
so this is a bit of Bitcoin history.  If folks are curious about how Satoshi was
thinking about these fields, jump in for that.  And then the second answer was
from Pieter Wuille, who explains a bit of the evolution of how those different
timelock fields have been treated over time, including different BIPs like
BIP112, BIP125, interpreting those fields in different ways.  So, I thought both
of those had a bit of value for the audience, so take a look at those.

Murch, do you want to quickly summarize the answer to the actual question, which
is, "Why is locktime at the transaction level while sequence is at the input
level?"

**Mark Erhardt**: Yeah.  So, as far as I remember, the general gist is that
Satoshi had the idea that inputs would be replaceable, or transactions would be
updatable at an input level.  So, the sequence field is at the input level, and
people would have been supposed to update transactions multiple times just by
replacing one of the inputs to change what they wanted to do, and then they
would increment the sequence number on those inputs.  And the underlying idea
was sort of a proto payment channel that he was thinking about already.

Unfortunately, that did not really align with mining incentives because miners
could have used any version of that transaction, even if the sequence number was
higher, because there was no enforcement of that.  You cannot enforce that
miners use a later version of two competing transactions, because they could
have just not seen the later version and built the block before.  So, there's no
way to distinguish and punish a miner for including an older version, because
they might as well just have not seen the new version yet.  So, the scheme was
not working, and the original meaning of the sequence was thus dropped pretty
early in Bitcoin development.  And then they later got reused to make these
relative locktime and CHECKSEQUENCEVERIFY (CSV), and all of those things make
use of sequences now.

One of the problems that we have due to the locktime field only being present at
the transaction level and not the input level, is that we cannot have a
transaction that uses both a relative locktime that is time-based and a relative
locktime that is height-based, because for a height-based locktime it has to be,
I think, under 5 million, and don't nail me to the numbers right now, but
there's a specific integer at which it's cut off.  If it's higher than that,
it's interpreted as a unique timestamp; if it's below that, it's interpreted as
a block height.  And so, since clearly it can't be both higher and lower than
that number, a transaction cannot spend an input that uses the one while another
input uses the other.

So for example, this restricts you from using certain inputs together at the
same time.  And there's, I think, also a clash with CSV, but I can't explain
that from the top of my head.

_BLS signatures vs Schnorr_

**Mike Schmidt**: Next question from the Stack Exchange involves the discussion
of BLS signatures versus schnorr signatures.  And so, as part of taproot
activating, we now get to use schnorr signatures, but this question involves,
"Hey, what if we were able to add BLS signatures to Bitcoin, what sort of things
might be possible?"  And there's three separate sub-questions that this person
had.  One is, "What are the cryptographic assumptions between BLS signatures and
schnorr?"  The second question is related to speed, if it's faster to do 100 BLS
signatures versus 100 schnorr signatures.  And then the last question is,
"Despite the different assumptions between the two, why wouldn't BLS signatures
be interesting for Bitcoin?"

On the topic of cryptographic assumptions, I think, folks, I would point them to
the answer from sipa that's on the Stack Exchange for the details there; unless,
Murch, do you want to take a crack at the BLS cryptographic assumptions, or
shall we point them to the Stack Exchange?

**Mark Erhardt**: I can talk a little bit about that.  So, Boneh-Lynn-Shacham
signatures or BLS signatures, are a fairly new construction, I think, and
they're very attractive in that they're small and they can be non-interactively
aggregated.  So, I think in the context of Schnorr signatures, some people might
have heard about signature aggregation and cross-input signature aggregation
especially.  So, the idea there is that you could have a single signature for
multiple inputs, and especially that that would be a financial incentive to
coinjoin.

With BLS signatures, that would be a lot easier because third parties can
aggregate signatures without interaction.  You don't even have to be part of the
group that creates the signatures; others can aggregate signatures.  The big
downside of BLS signatures is that they require a different curve than ours.
They need a pairing-compatible curve, and pairing, or a curve that has pairings,
is inherently constructed differently than secp256k1.  And it introduces new
cryptographic assumptions.  It looks currently like these cryptographic
assumptions are safe, they have not been broken yet; it provides these
advantages, like being able to have aggregatable signatures; but the downside is
of course that, who knows, maybe somebody does discover in the future an attack
on these pairing curves, and since these cryptographic assumptions are fairly
young, people don't seem too keen on adapting these new assumptions into the set
of assumptions Bitcoin is making, which are fairly conservative.

One cryptocurrency that does use BLS signatures already is Chia, for example.
And so, I think they write a fair bit about why they did that in, I don't know,
their documentation probably.  I've talked to their lead developer about this
once.  Yeah, so the big advantage is, you can aggregate all of the signatures in
a block, for example, and have a single signature.  And then, if the signature
passes, you know everything in the block was fine.  So, you can get a speed-up
that way.  But otherwise, BLS signatures are a lot slower, because they're much
more complicated.  You actually have to do some pretty weird curve math, I
think, to check them.  Yeah, and if you want to get a proper expert's opinion on
that, you should read the Stack Exchange answer, because he puts the right terms
to all of this and actually knows what he's talking about!

**Mike Schmidt**: I thought you did a great job, you impressed me there, and I
and I didn't realize that Chia was using BLS signatures, so that's interesting.
I know we talked about BLS signatures a few months back with Lloyd's I think it
was Lloyd's proposal for having a stateless oracle, and so that obviously
wouldn't be a change to Bitcoin, that was something that was on top of Bitcoin,
but we did discuss that a bit a few months back.

_Why exactly would adding further divisibility to bitcoin require a hard fork?_

Last question from the Stack Exchange this month is, "Why exactly would adding
further divisibility to bitcoin require a hard fork?"  So, for whatever reason,
this divisibility question has come up.  I've seen it on Twitter, I see it now
on Stack Exchange.  I think in the past, folks have sort of handwaved and said,
"If we need to, we can add more decimal places or more divisibility to
sub-satoshi amounts", and now there's some discussion going on around this.

The answer that I highlighted here in the newsletter was from Pieter Wuille,
which outlined four different approaches to soft fork methods that could enable
sub-satoshi divisibility.  But Murch, maybe a question for you before we jump
into these four soft fork variants, can you explain why it would essentially
require a hard fork; can't we just make that field bigger, or add a decimal, or
something like that without causing problems?

**Mark Erhardt**: Right.  So, the satoshi amount is the base unit of the
protocol.  When we make a Bitcoin transaction, we don't actually write a bitcoin
amount in what we send.  We do not ever use floating point numbers anywhere that
touches protocol stuff.  So, the outputs in Bitcoin transaction are specific
amounts of satoshis.  So, when we introduce more divisibility, we are either
introducing floating point numbers, which is horrible because that is the source
of all evil…

Okay, the floating points are difficult to get on all systems and different
operating systems, different chip architectures, to always resolve the same way.
If you get overflows or if you have to round, floating points are asking for
trouble.  So, there's a deliberate design decision that all the
protocol-involved numbers are always integers, and we don't want to have
floating points too.  So, introducing floating points for the amounts would be
breaking this prior approach.  We could, for example, do something crazy like,
let's just multiply every satoshi amount in the UTXO set by one million and then
continue working with satoshis, but satoshis have been redefined to be
one-millionth of what they are now.

Then we get issues with currently every amount that you could ever send on the
Bitcoin Network will fit into the size of the amount field on Bitcoin
transactions.  The amount field is bigger than the whole Bitcoin supply will
ever be.  If we multiply that, I think it is about only 15 times bigger than the
total supply of satoshis.  So, if we multiply that by a million, very, very rich
individuals might be able to create transactions that actually do not fit where
the outputs could exceed the output field size.  So, we're sort of a little
boxed in there with the field amount.  And if we wanted to increase the size of
the output amount field, that would also be a fork because of course, all nodes
expect the amount field to have a fixed length, and if we increased that length,
that would be problematic.  So, at least we would need a new transaction type, a
transaction type that would not be transparent to old nodes.

Yeah, so that's a few of the thoughts why just adding a few more points of
divisibility to the Bitcoin is not as trivial as that.

**Mike Schmidt**: Excellent.  Thanks, Murch.  So, sipa outlined a few different
soft fork methods that could achieve sub-satoshi divisibility.  My
interpretation of his responses wasn't that he was recommending any of these,
per se, but more using this as a thought exercise of how it could be done.
Murch, do you think it makes sense to go through these different methods?

**Mark Erhardt**: I think we can summarize them, really.  Or, do you want me to
try and summarize?

**Mike Schmidt**: Yeah, go ahead.  I think I have a grasp of it, but I want to
hear your interpretation.

**Mark Erhardt**: So basically, in the classical sense, we need a big change in
the consensus rules, and one that not necessarily is forward-compatible to old
nodes.  And you can basically sidestep the requirement of a hard fork by making
a soft fork that does change all these rules, but just moves all of the new data
to a separate area that old nodes don't see.  And, in a way, that is exactly
what we are talking about when we are debating soft forks versus hard forks; we
want soft forks to be transparent to old nodes and forward-compatible, so that
old nodes still can follow as much as possible of the onchain activity without
actually needing to know the exact rules, because we obviously can't go back and
change old software.

But if you, for example, have a soft fork that introduces an extension block,
where the extension block is just not visible to old nodes, then you can have
whatever the fuck you want in that extension block happening, because the old
nodes don't care.  But of course, whether or not that would classify as a soft
fork in the old sense, where they still have a general gist of what is going on,
those old nodes, that's I think the point of contention here really.

**Mike Schmidt**: And just to summarize the extension block idea, would be
something like committing to some hash in the coinbase and that hash represents
some other block of transactions elsewhere outside of the "normal Bitcoin
block"; is that right?

**Mark Erhardt**: Right.  I mean, you could still construct it in a way that the
whole block of data is propagated together and new nodes validate it essentially
in the same way.  You could sort of do it like segwit, how segwit changed how we
showed the transaction to old nodes versus new nodes, and we just deliver a
stripped transaction to old nodes without the witness data, and new nodes get
the whole transaction that they can validate including the witness data.  You
would do the same thing to the block, where the block has extension, and new
nodes get the whole block with the old part and the new part, and old blocks
only get the stripped version with the old part that is rule-compatible to them.
And you could have a commitment in the client base that ensures that you can
only have one set of extension blocks and probably also write in how much data
the extension blocks took, so that the extension block plus old block together
still fits into the rules, the weight limit, for example.

So, for new nodes that follow the new set of rules, very little would change,
except that they have a complete new set of rules.  You could essentially
introduce any change for these new blocks because it'll only be seen by nodes
that upgraded to a new set of rules.  So, yeah, you can strictly soft fork in
pretty much any change, as long as you're willing to burn down the old area.
And if you're kind, you can even make it in a way that old nodes can still send
their pre-signed transactions and be able to see that onchain.  But yeah, I
guess it's a little bit of a terminology question at that point, whether you
still call that a soft fork or not.

**Mike Schmidt**: And if you're interested in this thought space and some
ideation around this, check out Pieter Wuille's answer to this question, where
he outlined some of his ideas on this particular example of the divisibility
question.  We didn't have any releases to highlight in the newsletter this week,
and so we can jump into Notable code and documentation changes.

_Bitcoin Core #26325_

Murch, this first one I think you did the write-up for, for the newsletter, so
you're probably best equipped to explain it.  It's Bitcoin Core #26325,
improving the results of the scanblocks RPC.

**Mark Erhardt**: Right, so there's an RPC called scanblocks, which allows you
to use the client-side compact block filters to quickly look up what blocks are
relevant for a descriptor wallet.  So, it uses a descriptor, which is a compact
way of characterizing a bunch of addresses, and the compact blocks to quickly
filter.  So, compact blocks wouldn't be very compact if they had the full
information.  So, the trade-off with compact blocks is that you sometimes get
false positives.  So, if you're running a so-called Neutrino node or other
compact block client, you may occasionally think that a block is relevant to
you, when it really does not contain any information that you're interested in.
You end up downloading that block and looking for it and then realize, "Oh, that
was a false positive".

For a full node that uses its own compact blocks to scan for data, it's actually
easy to, once you get the hit, check whether actually it was a false positive or
a real positive, like an actual hit.  So, the scanblocks RPC was improved here
to verify its own hits on the compact block filters by looking at the blocks and
seeing whether, given the descriptor, that is actually a transaction that's
relevant to the scan.

**Mike Schmidt**: Okay, so beforehand, I guess scanblocks was, "Give me blocks
that are probably relevant to me" and with this change if I use this option,
then scanblocks will give me blocks that I'm definitely interested in?

**Mark Erhardt**: No, the other way around.  So before, if you were using the
scanblocks RPC, you might get a bigger list, and now it will actually make sure
that it only gives you the list of things that you need to look at.

**Mike Schmidt**: Right.  Yeah, exactly.  I think we're saying the same thing.

**Mark Erhardt**: Oh, I might have misunderstood you then.  Sorry.

**Mike Schmidt**: So, filters false positives options.

_Libsecp256k1 #1192_

Next PR is from libsecp repo #1192.  And this is a galaxy-brain PR that I think
even Harding had to go to some of the libsecp authors to get some of the summary
here.  Murch, do you want to take a crack at this galaxy-brain PR?

**Mark Erhardt**: Sure.  So, we use something called an elliptic curves in
Bitcoin, and the elliptic curves that we use is called secp256k1, which is a
curve that is close to the size of 2<sup>256</sup> power in the order, as in
there's a huge number of elements on that curve, and that's why it's safe,
because it's just such a big group of numbers that you will never exhaustively
be able to search it.  Now, we have software that essentially has to work for
all of these points, but there's edge cases where there might be an
implementation mistake or something works a little differently just for a small
number of values in the curve.  So, it turns out that if you only change one of
those parameters in the curve, you can find other curves that have way fewer
elements, namely the libsecp256k1 tests use curves with 13 and 199 elements
already to exhaustively test whether for all of those elements, this very small
number of elements, all of the signatures can be constructed properly and
everything passes.

So, I think sipa here introduced another sub-curve with fewer elements that has
7 elements, a group size of 7.  And so now, there's three groups that we test
all the assumptions of libsecp on, and we run exhaustive tests on these three
smaller curves that are very, very closely related to libsecp as a way of
saying, "Well, if for every possible value on these curves we can do everything
that we need to do with libsecp, very likely we also can for secp265k1.

**Mike Schmidt**: Nice work.  So, it cuts down on the design space, or I guess
not the design space but the curve space, so that you can do a bunch of testing
that wasn't going to be comprehensive and larger scale.  Excellent.

**Mark Erhardt**: Yeah, that's how I understood it.

_BIPs #1383_

**Mike Schmidt**: Last PR for this week is to the BIPs repo, and it assigns
BIP329 to the standard wallet label export format for that proposed BIP, which
we actually discussed this in a newsletter in Newsletter #215, and I believe we
had Craig Raw on our recap discussion and he gave his two cents on this matter;
I believe he was the guest at the time.  What this BIP proposes is a standard
way to apply labels to different parts of a wallet.  And so, those different
parts could include something like labeling an input, labeling an output,
labeling a transaction, labeling an address, and it gives a standard JSON format
to do that, so that if you were able to take your wallet from one wallet
provider to another, that potential sensitive or privacy-related information can
go from that first wallet to that second wallet, assuming that they support this
BIP.

**Mark Erhardt**: Yeah, basically if you want to be able to keep all the
labeling data that you have on one wallet when you move to a new wallet
provider, you now have a way of -- or I should say wallet implementers now have
a way of how they can exchange that information between different wallets.  And
yeah, so I don't know, if you want to move from one wallet that uses mnemonic
seeds to another wallet, you can not only rediscover all your transaction data,
but you can also import your labels.  So, the next time you have to do your
taxes or your own accounting for your private purposes, you don't have to go
back to the old software, but you can also look at it in the new software.

**Mike Schmidt**: Murch, anything else you'd like to announce for this week?

**Mark Erhardt**: No, we are doing BitDevs in New York tonight.  So, if you're
in town, come join us.  See you later!

**Mike Schmidt**: All right, sounds good.  Thanks to Val for joining us and
discussing earlier news items today and, Murch, thanks to you as always.  And
next week, just a quick announcement, I think we're going to do the recap
session on Wednesday instead of Thursday.  I will be doing some travel on
Thursday and I thought it would be nice to have both of us still at the
discussion.  So, look for that announcement on our tweet when we schedule that
Spaces, but it'll be a day earlier.

**Mark Erhardt**: Super.  Thanks for your time, and hear you next time.

**Mike Schmidt**: Thanks everybody, cheers.

{% include references.md %}
