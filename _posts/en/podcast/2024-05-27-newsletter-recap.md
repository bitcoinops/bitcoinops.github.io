---
title: 'Bitcoin Optech Newsletter #304 Recap Podcast'
permalink: /en/podcast/2024/05/27/
reference: /en/newsletters/2024/05/24/
name: 2024-05-27-recap
slug: 2024-05-27-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Andrew Toth, Antoine
Poinsot, and Tony Klausing to discuss [Newsletter #304]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-4-27/378919194-44100-2-e55d520472a15.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #234 Recap on
Twitter Spaces.  Today, we're going to talk about how we can potentially upgrade
existing LN channels; there's a news item about mining pool payout schemes and
ecash; PSBTs for silent payments; there's a proposed miniscript BIP now; and
there's this idea of stable channels that we're going to jump into as well.  We
also have our regular sections on notable code changes, releases, and
interesting updates to client and service software that we noticed this month.
We'll do introductions.  Mike Schmidt, contributor Optech; Executive Director,
Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin Project.

**Mike Schmidt**: Tony?

**Tony Klausing**: Hey folks, Tony Klausing here, bitcoiner, software developer
working on stable channels, which is synthetic dollar balances on LN.

**Mike Schmidt**: Antoine?

**Antoine Poinsot**: My name is Antoine Poinsot, I'm the CTO of Wizardsardine,
and I'm contributing as well to the Bitcoin Core software project.

**Mike Schmidt**: Andrew?

**Andrew Toth**: Hi, I'm Andrew Toth, I work for Exodus Wallet, and I'm also a
hobbyist contributor to Bitcoin Core.

_Upgrading existing LN channels_

**Mike Schmidt**: Excellent.  Thanks everybody for joining us.  We have five
news items this week.  The first one is titled Upgrading existing LN channels,
and this is a Delving post from Carla Kirk-Cohen who posted, "Trying to wrap my
head around the various ways we could go about upgrading Lightning's existing
channels, specifically in the context of upgrading to use v3 channels to improve
our resilience against pinning attacks".  In her Delving post, she outlines
components of LN channels that users may want to update, including parameter
updates, which are potentially updating the constraints that are normally
exchanged during channel opens.  The second class of component that she thinks
could use updating is commitment updates, so the ability to change the format of
a commitment transaction, potentially to upgrade the channel type, including to
anchor outputs, v3 transactions, or simple taproot channels.  And the last
category of potential LN channel updates would be the funding-output-related
updates.  Potentially a user would want to change the spending output to change
the capacity or output type, and in the newsletter we noted, "Originally all LN
funding transactions used a P2WSH output; however, newer features such as PTLCs
(Point Time Locked Contracts) require funding transactions to use P2TR outputs".

So, after outlining these three ways that LN Channels could be updated, she then
goes on to outline three existing approaches that could be used to achieve these
different types of updates.  First one's titled "Dynamic commitments", which is
an open proposal draft in the BOLTs repository.  The second one is, "Splice to
upgrade", and that is an idea, not a draft proposal, but an idea that since
splicing already requires updating a channel with an onchain funding
transaction, it could also potentially update the commitment transaction format.
The third potential approach to making these updates is "Upgrade on
re-establish", which is a proposal that has an open PR on the BOLTs repository
as well, that allows updating channel parameters, but does not address the other
two components of the funding and commit transaction updates.  There was a bunch
of tables and data that she included in her post to compare the different
approaches.

Murch, I don't know if you would want to augment or clarify anything that I've
summarized so far, and we can maybe jump to a conclusion after that?

**Mark Erhardt**: Yeah, I wanted to jump into the dynamic commitments, because I
thought that one was the least obvious just from that one line.  So, what is a
"kickoff" transaction?  Basically, the problem with trying to update your
commitment transactions is that you still need to be able to use any of the old
ones in response to the counterparty trying to cheat.  So, the kickoff
transaction is basically just a wrapper for the original series of commitment
transactions, and it is a new funding transaction that spends the old funding
output to a new funding output.  So, when you want to go onchain, you first
spend your original funding output to the new funding output, and then the
commitment transaction on top of the funding output, the new one that is, so you
would have to go onchain with two transactions instead of a single commitment
transaction.  I thought that's kind of funny.

Splicing sounds interesting, especially when people go and splice in funds and
splice out funds already.  So, ACINQ is doing that of course with Phoenix
Wallet.  If this becomes a more established pattern and people fairly regularly
add balance or use their channel to pay transactions onchain, that would be of
course a pretty nice, obvious way, or occasion at which to update your channel
completely, because you're essentially recreating a new channel with the
starting balances of the old channel plus the new balance.  So, it would be
optimal; if people do it anyway already, that would be a great time.  So, yeah,
otherwise it looks like everybody will have to shut down their channel once and
create a new channel once if they want to start using new features, and that
sounds, well, a little uncomfortable for people that have long-established
channels and would need to go onchain with all of that data.

**Mike Schmidt**: Carla concluded, "That it makes sense to start work on a
parameter plus commitment upgrade via dynamic commitments", and I think t-bast
from the Eclair team seemed to agree in the thread with that sort of approach as
well.  Murch, I know you're occasionally in the office with Carla.  Is there
something more that you would add in terms of next steps or takeaways from her
posts?

**Mark Erhardt**: No, that was all I had.

_Challenges in rewarding pool miners_

**Mike Schmidt**: All right.  Next news item, titled Challenges in rewarding
pool miners.  This was a post by Ethan Tuttle, who posted to Delving a post
titled ECash TIDES Using Cashu and Stratum v2, which is a bunch of terms in the
title.  So, you have the notion of ecash; the Cashu system; you have TIDES,
which is Ocean's mining pool payout scheme; and then Stratum v2, all sort of
intertwined in the title there.  Ethan's idea is that mining pools could reward
miners using ecash tokens instead of the existing schemes that they use now, and
that miners could then sell those tokens in the short term, or wait for the pool
who issued those tokens to mine a block, at which point that pool would then
exchange tokens for actual bitcoin in the form of satoshis.  One issue that was
pointed out by BlueMatt here was that given the types of payout schemes that the
large existing Bitcoin miners use, those schemes don't really allow for the
calculation of payments over shorter time intervals.  And so, that's one
potential struggle that this ecash system might have trying to issue; how much
ecash do you issue if these sort of pool payout scheme algorithms can vary?  And
someone else pointed out that in TIDES, the mining shares that a miner
contributes to the pool is actually paid out multiple times, so how would you
handle ecash issuance in that scenario, where potentially you get multiple ecash
over time and multiple redeems?

As part of this news for this week, Dave actually did a pretty long mining pool
topic that was added to the Optec Index this week.  So, if you're curious about
mining pools and different payout schemes, take a look at that.  I thought that
was a great write-up.  So, I'll pause here.  Murch, what do you think?

**Mark Erhardt**: I mean, one of the complaints that people have about mining
pools is that the mining pool holds the payout until there's a threshold
reached.  That is somewhat mitigated by the first mining pools paying out in
Lightning now, which allows way smaller amounts to be paid out fee-efficiently.
And so far, I think it's slightly preferable to pay out to ecash immediately,
because the user now has an ecash token and they can trade that among each other
already, or among other parties that are willing to trust the mining pool for
the counter.  Well, they are a counterparty to all the ecash tokens, right?  But
it sounds like it's not the most pressing problem that mining pools have.

For most, I think that is that pay per share is basically the most attractive
way to get paid out as a miner, because you don't have to depend on the luck of
the mining pool; you get paid regardless of whether they find a block or not.
But on the other hand, you need to have significant cash reserves as a mining
pool in order to give this sort of advance payment before you even find a block.
So, it's been something that has been supporting the bigger mining pools, and
especially ANTPOOL has used to its advantage, because ANTPOOL is actually paying
out the expected value almost without fees in PPS.  So, it's using this advanced
payment method, but not taking a fee for that or making it less attractive.
There's no trade-off, so everybody's been getting the best deal if they mine
with ANTPOOL economically.  So, yeah, I don't know.  There seem to be a lot of
difficult issues there, and I'm not sure ecash addresses the most pressing ones.

**Mike Schmidt**: And, Murch, actually we're announcing some of it later, but
there's some Lightning payout from mining pools and now we're talking about
ecash.  Are you aware, I didn't see the word "reorg" in any of this Delving
post, but how would something like that be handled?

**Mark Erhardt**: I'm not sure.  I think that most of the mining pool
calculation happens within like 100 blocks or so from the mining pool getting
the share and then seeing how much fees they collected, and so forth.  So,
there's actually significant issues around trying to figure out whether the
mining pool fairly paid you in the first place.  I'm not sure whether a reorg
would complicate this significantly because either way, you have to basically
wait a day or so until you know how much you finally got paid.  And a reorg
would, at that point, also be a day in the past.

**Mike Schmidt**: Antoine, Tony or Andrew, if you guys have any comments on this
ecash mining pool discussion or our previous discussion on upgrading LN
channels, feel free to chime in as we progress here.  Murch, anything else on
this topic?  Great, all right.

_Discussion about PSBTs for silent payments_

Next news item, titled Discussion about PSBTs for silent payments.  This
discussion was spurred by Josie Baker, who posted to Delving Bitcoin about PSBT
extensions for silent payments (SPs) and cited a draft by our special guest,
Andrew Toth.  Andrew, do you want to explain briefly SPs, and then maybe some of
the work you've done on the specification and what exactly we're trying to
achieve here?

**Andrew Toth**: Yeah, sure, thank you.  So, SPs is a way that you can just
share a static address and it creates a new output that can't be tracked on the
blockchain.  Basically, you need the private keys to be able to determine which
outputs are yours, and so it solves a lot of the problems that I think a lot of
wallets have.  One of the major UX problems with Bitcoin for new users is that
they expect their address won't change.  They have this mental model that it's
like an account.  And so, you can see this; like, I know Trust Wallet even
disabled the fact that you could reuse addresses.  So, when I saw SPs, I was
like, this is a huge UX boon for a lot of wallets, because it's going to let us
just show a single static address, and users can use that forever and never have
any of their payments linked.

When I saw this, I reached out to Josie, and I asked him, "How can we basically
get this into PSBTs?"  And sorry, I jumped ahead a bit there, but basically I
was thinking, "How can I get this into Exodus Wallet?"  And the first step would
be to enable sending support, because for a lot of wallets, you'll need
ubiquitous sending support before they'll even consider adding receiving
support.  And also, they won't see an immediate benefit by adding sending
support either.  So, we'll have to make it a very easy sell for them to add
sending support, to pay to an output.  So, a lot of libraries, like for example
Exodus uses bitcoinjs-lib, I know BDK also they use PSBTs internally to
represent a transaction that's not yet ready to be sent, so it's still being
constructed.  And so, to allow sending to some payments to be ubiquitous, we
needed to add support to PSBTs.

When I was looking at the PSBT spec, one of the requirements was that every
output that's added has to have an output script, and that's fundamentally
opposed to BIP352, whereas you don't know what the output script is until you
are ready to sign, basically.  So, I reached out to Josie.  I was like, "How can
we get this into the PSBT spec?" and we started discussing how we could add it.
And so, I fleshed out a draft for how we would have to modify it.  And
basically, to send to SP addresses, we would probably have to upgrade to a PSBT
v3, because it is backwards-incompatible for the reasons I stated, because you
have to be able to add an output with just the SP code instead of the output,
and it needs to be computed after.  And then, there's also some other things,
because BIP352 doesn't allow you to add inputs that are spending from future
segwit versions, and it doesn't allow you to spend inputs that have
SIGHASH_ANYONECANPAY, but these are things that are compatible with earlier
versions of PSBT.  So, we need to basically have a way to enforce mutual
exclusion between those two things if you're adding SP outputs.

Also, there needs to be basically a rule where you have all the private keys.
So, like right now, there's an updater that adds things but doesn't have access
to the private keys, and there's a signer which may only have access to a
private key of the index it's trying to sign.  Sorry, I've been going on for a
while.  Murch, did you have something you wanted to say?

**Mark Erhardt**: You kind of started talking about my question I was sitting
on, so I am curious.  Basically, you can only calculate the correct output
script at the point that you know all the inputs.  And all of the participants
that are contributing inputs need to contribute their private keys at some stage
of this in order to calculate the elliptic-curve Diffie-Hellman (ECDH).  So, I
was curious, in your current draft it sounds like you can only send to SP
outputs if there's only a single entity that creates the transaction.  That sort
of runs counter to the idea of PSBT, in that it is a format that makes it much
easier to have multiple senders in a transaction.  Is there a way that you can
keep it private who the SP recipient is, while creating a transaction with
multiple senders?

**Andrew Toth**: Yeah, so first of all, you can actually have other people add
inputs after you compute technically, because you can add inputs that are not
lexicographically the first input, and so that won't change the input hash, like
a P2TR that doesn't have a private key; and also other inputs, like multisig and
things, can be added as well.  But yeah, to your question, so PSBT is also kind
of just used as like a Swiss Army knife for Bitcoin libraries to create their
transactions, so it doesn't necessarily have to be that you have to pass it
around to different parties.  But to support that, Josie did mention on a
discussion there that signers could contribute a basically ECDH share, which
would be like a Diffie-Hellman-like signature multiplied by the spend key, and
they could all return that as well.  And so, that is one solution we could do.
I think that will make the protocol quite a bit more complex in the PSBT though,
but yeah, it's definitely something we should explore.

**Mark Erhardt**: So basically, everybody that contributes an input, if it's
multiple parties, would have to attach their ECDH share; and then anyone that
wants to add SP outputs could use all of the ECDH shares to calculate the
correct output script and add it.  And nobody would be the wiser because at that
point then, it would look the same as any other P2TR to all the other PSBT
collaborators.  Is that right; did I understand that right?

**Andrew Toth**: Yeah, that sounds right to me.

**Mike Schmidt**: How has feedback been so far, Andrew?

**Andrew Toth**: I haven't shared it too widely yet, it was still a pretty rough
draft.  I didn't expect to get this much attention from Bitcoin Optech about it
yet, but I will be sharing it in the SP IRC channel as well to get some more
feedback.  But it would be great to start moving this forward so we can get
ubiquitous sending support throughout the ecosystem.

**Mark Erhardt**: Thanks for working on this, I'm super-excited.

**Mike Schmidt**: Andrew, you're welcome to stay on.  I think we have a PR that
you're the author of later.  If schedules allow, we'd love to keep you on to
explain that.  If not, we understand.

_Proposed miniscript BIP_

Next news item, Proposed miniscript BIP.  This is a Bitcoin-Dev mailing list
post from Ava Chow about a draft BIP for miniscript.  And that draft BIP is
actually heavily authored by our special guest, Antoine.  Antoine, was there not
already a miniscript BIP?  What's going on here?

**Antoine Poinsot**: I think Murch wants to say something first.

**Mike Schmidt**: Go ahead, Murch.

**Antoine Poinsot**: I think he's gone down.

**Mike Schmidt**: Yeah, we might have lost Murch.  Why don't you go, I'll work
on this with him.

**Antoine Poinsot**: Yeah, cool.  So, there was no BIP yet, because nobody
basically did it yet.  However, the specifications for miniscript have been used
in production for quite a while now.  The implementation as part of output
descriptors have been implemented in Bitcoin Core for two years, I think, and
they've been adapted to taproot as well.  So, all the elements in order to have
a BIP as part of the standard Bitcoin standard development was ready, but just
nobody took care of actually writing a BIP and proposing it.  So, Ava stepped up
a little while ago and started writing the backbone of the BIP in MediaWiki,
based on Pieter Wuille's website.

We sat down, the three of us, so Pieter, Ava, and I, during a recent Core Dev, I
think it was in March, and decided what we actually wanted to include into the
BIP, because Pieter's website was more trying to give the intuition behind how
miniscript was designed.  And as you would read through the website, as you
would scroll down through the website, you would go through each section and it
would mix the specifications of the language with the rationale for each of the
sections.  So for instance, first you would go with the definition of the
fragments of each miniscript fragment and its corresponding Bitcoin Script, then
you would go on with the type system, which describes why we have a type system
at all.  Then we'd discuss the resource limitations, if I remember correctly,
and then we would tackle the malleability properties and then go on about
defining additions to the typing system for enforcing malleability properties.
And so, it made a lot of sense to a reader trying to learn about miniscript, but
maybe it was not the most efficient approach for someone interested in
implementing the specifications of miniscript.

So, the approach that we agreed upon, when we sat down at Core Dev, was to
basically take all the specifications and put all the specifications at the
beginning of the BIP, so we are going to have both tables for the base-type
system and the malleability-type system, and strip out all the rationale, which
is going to be in a second section, in the rationale section of the BIP
afterwards.  So, yeah, that's basically the idea behind the BIP.  That's
Pieter's website written down in a BIP format by Ava, and trying to format it
more like a BIP rather than a website.

**Mike Schmidt**: Other than the reorganizing of the content and specification,
you mentioned separating rationale from the actual specification itself.  Are
there deltas from this BIP to what people may be familiar with in terms of using
miniscript, or is it really just documenting what we have today?

**Antoine Poinsot**: It's only documenting what we have today for anything
meaningful.  The specifications of miniscript do not change.  Whether it is the
old P2WSH specifications or the newer-ish taproot specifications, no
specification changed.  We only maybe changed the wording of one sentence or two
in order to better explain the rationale, but no, nothing substantial changed.

**Mike Schmidt**: Murch, do we have you back?

**Mark Erhardt**: I think so.

**Mike Schmidt**: As a BIP editor, what are your thoughts on this proposed BIP?

**Mark Erhardt**: Well, I guess I'll have to read it and then presumably merge
it pretty soon.  I mean, I think it's a well-established idea that has been
discussed a lot.  There's already a few implementations, and so forth, so I
don't anticipate that this one will be either controversial or need a long time
to get merged.

**Mike Schmidt**: Excellent.  Antoine, anything else interesting outside of this
BIP in miniscript world, or some of the work that you guys are doing on Liana at
Wizardsardine?

**Antoine Poinsot**: Not on the top of my head, but maybe Salvatore, not very
recently, but a while ago, maybe six months ago, he posted about how to
deterministically derive the internal key for a taproot descriptor, which has no
keypath spent.  So, we use it in Liana, so I'm going to take the example for
Liana, and it's implemented in Ledger as well.

Let's say you have a simple Liana wallet, which is 2-of-3, which after one year
degrades into a 2-of-5, and you do not have MuSig support yet, so you are using
script-based multisig.  So, you are going to end up with, well, depending on
your computation, two or more branches, or maybe one, but it's not happening, so
two or more branches in your taproot.  So, to make it simple, let's say you have
one branch without a timelock, and 2-of-3 multisig; and a second taproot branch
with a timelock of one year since the output was created, plus a 2-of-5.  In
this case, you need to find an internal key for the taproot output, such as when
you are going to verify your descriptor on your signer, the signer can verify
that the internal key is unspendable.  Otherwise, since the threat model
usually, when you're using this type of wallet and when you're using a signing
device at all, is that you should not trust information displayed on your
laptop.  So, you're going to verify the information on your signer and your
signer needs to display to you, "That's a taproot output.  But fear not, it's
not spendable through the keypath.  I checked that".

How you, as a signer on the firmware, can check that is that you need a
deterministic way of deriving the internal key from a nothing-up-my-sleeve point
on the curve, and you want more properties.  You want -- actually, there is
Salvatore in the room.  He could speak to this.

**Mike Schmidt**: We invited him, so maybe he's indisposed right now.

**Mark Erhardt**: I think he's just listening!

**Antoine Poinsot**: Yeah, he's listening.  So, yes, and you could want more
properties.  So, let's say in BIP340 or BIP341, I think it's in BIP340, I don't
remember, basically there is nothing-up-my-sleeve point used in the BIPs, in the
taproot BIPs, one of the three, and you could just say, "I'm always going to use
this point as the internal key", so that it's easy for the signing device to
check that it's a nothing-up-my-sleeve.  Obviously, that's bad because then all
your taproot spends are going to have the same internal key and it's going to be
obvious onchain.  So, you need some sort of randomization of the internal key,
but you don't want more data to backup.  So, you need to find a way to derive a
different internal key for each descriptor ideally without encumbering the user
with more data to backup, to retrieve the outputs in the future while they
recover from the descriptors.

So, Salvatore came up with a scheme which has all these properties using his
wallet policy BIP, which is a subset of descriptors, specifically in the context
of being used by hardware signers.  So, yeah, that's interesting and slightly
related to miniscript.

**Mike Schmidt**: Awesome.  I'm glad I asked you that question.  Thanks for
jumping into that.  Murch, did you have any follow-up on this news item?

**Mark Erhardt**: I do not.

**Mike Schmidt**: Antoine, thanks for joining us.  You're welcome to stay on for
the rest of the newsletter.  If you need to drop, we understand, cheers.

_Channel value pegging_

Last news item this week, titled Channel value pegging.  Tony, you posted to
Delving about a proposal and some code for stable channels.  I guess the
motivation for stable channels is somewhat this notion of the terminology of
stablecoin, but maybe you want to explain the idea of what is a stable channel,
and then we can jump into some of the mechanics behind it.

**Tony Klausing**: Great, thanks guys for having me.  So, that's right, this
project is an open-source project called Stable Channels and the overall goal or
motivation is to bring more stability-like tools, similar to stablecoins, to the
Bitcoin Network.  Stablecoins themselves are tremendously popular and
profitable, but a big problem with Bitcoin is the price volatility, and so I
think that dissuades some users from getting involved in Bitcoin.  And so, I was
just thinking about other ways that we can offer stability to users, stability
of purchasing power, stability of store of value, similar to what holding your
money in the US dollar, or some other fiat currencies, can give us.

So, stable channels, the tl;dr is that it matches up stability seekers, so I
call them stable receivers, and they want the stable US dollar on their side of
the channel, and stability providers, and they are willing to take the
volatility of the stable receiver, or provide the stability as a service to the
stable receiver.  And then we create a dual-funded channel with these two types
of users, and we settle sats very frequently so that we keep the stable user
stable in dollar terms on his or her side of the channel.

Let's take an example like today, the Bitcoin price is approximately $70,000.
And so each user, the stable receiver and stable provider, will put in 1 bitcoin
into the channel.  The stable receiver says, "Hey, I want to be stable at
$70,000".  And every minute or every X minutes, whatever makes sense for the use
case, or X seconds, each user goes out and queries five different price API
feeds.  Right now, those are Bitstamp, CoinGecko, Coinbase, a couple of other
ones.  We take the median of all of those exchange prices, and then based on
that updated price, let's say the price of bitcoin went down, then on the stable
receiver side it takes more bitcoin to keep the stable receiver stable at
$70,000.  So, the stable provider sends a payment over the channel to the stable
receiver.  And so that means that the stable receiver, on his side of the
channel, might have something like 1.001 bitcoin, something like that.

So, yeah, that's the basic idea.  And by settling sats very frequently, we can
minimize the counterparty risk at any given time because the difference is so
small.  So, it's important to know that these channels are just vanilla channels
with no DLCs, right?  We just get the price API feeds and settle the difference,
and there's no modifications to Bitcoin Scripts, and there's no tokens involved.
Obviously, there's no banks involved; it's more of a P2P approach to do stable
bitcoin balances.

So, as far as where I am with the development.  Oh hey, Murch, go ahead and ask
your question.

**Mark Erhardt**: I have many.  So, one question I sort of feel pushed into is,
if they independently look up the prices from these five sites and get a median,
what would happen if they happen to pull half a second apart and get different
results for the price?  How do they come to an agreement here?

**Tony Klausing**: Yeah, that protocol to suss out the actual price would have
to be in addition to the protocol right now.  I found sometimes the price is off
slightly.  Even running on the same server, sometimes the prices are slightly
off.  But each side kind of keeps track of their version of the truth!  And
then, in practice, I've found that it works decently well, and the software is
written so that it settles the difference if there's a difference of 0.01%.  And
so, if there's a difference of, you know, 1 penny on $100, then we settle the
difference.  If we wanted to expand that, Murch, to have some type of like, "Oh,
okay, here's the price I got, here's the price you got", then another thing we
could do is when we send over the payment, maybe add some memo that says, "Okay,
here's the prices I got", and the other guy says, "Oh, okay, here's the prices I
got", and see if they match up.

But at the end of the day, either you're getting the money that you're supposed
to have or you're not!  And so, based on that information, we assign the other
counterparty a risk score.  So, in other words, have they been paying on time?
And this is very rudimentary right now, but the idea is, have they been paying
on time; have they been online or offline; and what's going on?  So, Murch, I
hope that helps a little bit.

**Mark Erhardt**: Right, so basically if the counterparty is always $3 above you
and you keep track of that, you eventually assign them a higher risk score
because they're lying to you consistently, or something like that?

**Tony Klausing**: So, if one counterparty is only paying the other
counterparty, and, "Hey, man, I'm supposed to be kept stable at $70,000, and
you're only even keeping me stable at like $69,500 for a while" then that's not…
In practice, I haven't discovered that.  The exchanges are pretty close to each
other.  But yeah, basically if one side isn't paying, then there's an issue.
And as I mentioned in the Delving post, I think this system would make better
sense for decently cooperative counterparties.  But even in the event where
there is an uncooperative counterparty, you always have the recourse to close
the channel and get out of the stable channel.

**Mike Schmidt**: That is the recourse then?  So, if I'm using this system to
get a free option, if you will, and if the price moves extremely against me,
then I'm not going to cooperate regardless of what the price feeds that I see
is.  Then the counterparty to me, when I'm cheating, is to close this channel
and in theory there, I guess, could be some loss on their side then?

**Tony Klausing**: That's right.  So, I mentioned in the Delving post a few, I
don't know if they're countervailing measures, they're just some characteristics
of stable channels to consider if somebody wants to cheat.  And one thing is
they have to pony up a lot of capital to play.  They also need to contribute to
channel opening and closing costs.  And in the event of an uncooperative close,
they may have to wait days or weeks to get their money, their bitcoin, in which
case the price might have changed a little bit.

Another way to handle this instead of closing the channel is just to say --
because I presume like a lot of Bitcoin people have a pot of fiat that they keep
and a pot of Bitcoin that they keep.  And if one of their trade counterparties
stops cooperating, then, "Oh, well, that's Bitcoin" and you know, that's just
Bitcoin!  You don't necessarily have to close the channel, but you just say
that, "Now I just have a regular Bitcoin LN channel", and turn off the stability
mechanism, essentially, and you just have a regular LN channel.

I think a couple other ways to address this free option challenge might be to
use moving averages for prices, so that in any given time period, the price
doesn't move as much.  And another kind of opposite way to do it is to settle
super-frequently, every second or whatever, but that obviously has technical
challenges.  And a final, simple way is to diversify your counterparties so that
you don't have all your eggs and your bitcoin in one basket, so to speak.

**Mike Schmidt**: Tony, what's feedback been to the idea, to your posts
publicly, as well as any feedback you've gotten privately that you're up for
sharing?

**Tony Klausing**: It's been really great.  Most of the feedback has come from,
I'd say developers, just because it's a little bit abstract for folks to
understand.  You kind of have to understand how LN channels work to understand
how this could work.  As far as practically speaking, some people, the biggest
question I get is that how people are going to cheat this, or the stability
mechanism is going to break down, and I think that's fair feedback.  The code
for it, I started as a Core Lightning (CLN) plugin, in that it works best on
CLN, and I plan to extend the functionality using CLN.  There's also a
standalone LND Python app that it's compatible with.

I mentioned how developers are interested.  Some of you folks may have seen the
boardwalkcash.com ecash wallet in the past week or two, and on the back end,
that uses a mint.  That mint is at uMmint.cash.  And this is all -- I didn't
make the ecash wallet, but I did make the stable channel, so this is a number of
developers coming together for this product.  And then, that mint uses a stable
channel to offer the stable Lightning balance on behalf of its ecash token
holders.  So, that was a really encouraging application of stable channels to
the real world and people playing around with it.  So overall, it's been pretty
good, and I think people seem to want to bring some type of more stability tools
to Bitcoin.  And working with LN is challenging and a little bit slow, but
between cooperative actors on reliable servers, the LN works very well.  And so,
it's been going good and I look forward to working on it more.

**Mike Schmidt**: Great.  Well, anyone listening who's interested in discussion
of these types of items, jump on Tony's Delving post and collaborate there.  And
if you're interested with tinkering, grab that sample code that we linked to
from the newsletter, and I think you said, Tony, it was a CLN plugin that you
could do this with?

**Tony Klausing**: CLN plugin and LND Python app.  And if you're having any
issues at all, I'll be happy to sit with you and make it work.  We're trying to
just test on different machines, different versions and all that to see what the
bugs are and iron things out.  So, I appreciate any feedback, appreciate it.

**Mike Schmidt**: Thanks for joining us, Tony.  You're welcome to stay on or if
you have other things to do, we understand.  That wraps up our News section.  We
have a monthly segment that we highlight interesting updates to Bitcoin wallets,
services, and other software, called Changes to services and client software.
This month we have a bunch, I think it's ten this month.

_Silent payment resources_

The first one is Silent payment resources.  I sort of aggregated a few different
things under this bullet point, including an SP website, which is
silentpayments.xyz.  It's an informational website.  I also happened to see this
month two TypeScript libraries for SPs, a Go-based backend and a web wallet for
SPs.  And there's also been a link to the silentpayments.xyz/docs/developers
page, which highlights different libraries that people are putting out that
utilize SPs.  Obviously, a lot of this is new work, so caution is advised with a
lot of this beta or new software.  Cool.  Another silent payments update.
Murch, did you have something on the first one?

**Mark Erhardt**: Just maybe, when we're talking so much about SPs, there is a
longstanding concern about the term "address" in Bitcoin.  In the real world and
generally, we consider address as something that is a semi-permanent identifier
of a location or maybe an IP address, or something, that doesn't change, right?
So, a few years ago, some people made a BIP in order to change public perception
of what an address is and tried to push it more towards calling what we
currently call Bitcoin addresses, "invoice identifiers", and to give them this
single-use characteristic and remind people that addresses should only be used
once.

I think the funny thing is now that we have SPs, SPs are actually addresses.
This is an actual Bitcoin address.  And yeah, this is the one that you can put
out there and permanently use, because when you receive a payment, it's
completely unidentifiable for third parties that they were received to the same
recipient, and they generate a new output script from the address.  So, these
are really a form of static address technology and reusable address.

_Cake Wallet adds silent payments_

**Mike Schmidt**: Cake Wallet recently announced their beta release that
supports SPs as well.  So, a lot of SP love going on out there, you love to see
it.

_Coordinator-less coinjoin PoC_

Third item that we highlighted here is a proof-of-concept (PoC) tool titled
Emessbee, which is quite a creative name.  It's a PoC project to create a
coinjoin transaction without a central coordinator.  I think this was Super
Testnet that cranks out a lot of these interesting PoCs.  The repo was
originally titled Coinjoin workshop, now titled I think Emessbee.  I did not
play with it.  Seems interesting.  Murch?  All right.  And obviously, Tony,
Antoine, or Andrew, if you guys have any insights on some of these pieces of
software or commentary, feel free to just jump in.

_OCEAN adds BOLT12 support_

Fourth piece of software, OCEAN adds BOLT12 support.  So, the OCEAN mining pool,
they've been wanting to do LN payouts since they announced the OCEAN mining pool
late last year, and they figured out a way to do it.  They're allowing their
miners, who are already required to have a Bitcoin address sort of on file, if
you will, with the pool to sign a message using that Bitcoin address that
essentially encapsulates their BOLT12 offer.  And this is part of a payout setup
for OCEAN.  So, they now can pay BOLT12 offers as part of their LN payout, which
is pretty cool.  Murch?

**Mark Erhardt**: Yeah, and BOLT12 is, so to speak, a similar, corresponding
type of receiving LN payments as SPs, in the sense that it is reusable and it
comes with privacy features.  In the BOLT11 setup, the recipient usually has
extremely little privacy because it outright tells the sender who to send to.
But with BOLT12, you can have a blinded path, so they would at best know a few
hops near the receiver.  And that way, this fits well with OCEAN setup, which
doesn't do KYC and allows people to just jump in, set up their miner, only
provide an address I think through the Stratum protocol, you can provide an
address to get your payout.  So, it's all ad hoc and immediately paid out just
to the address and there's no further business relationship.

_Coinbase adds Lightning support_

**Mike Schmidt**: Pretty cool.  More LN updates.  Coinbase adds LN support.
They did not do that in-house, they're using an LN infrastructure company called
Lightspark, and Coinbase has integrated Lightspark technology for deposits and
withdrawals using LN.  Yay, so no more "when LN for Coinbase?"

_Bitcoin escrow tooling announced_

Next piece of software, a Bitcoin escrow tooling set announced by the BitEscrow
team.  This is a bunch of developer tools for implementing non-custodial Bitcoin
escrow.  I think behind the scenes, I think you can maybe plug in your own
escrow agent, but BitEscrow obviously provides that as an option as well; that's
how they make their money.  There's a bunch of open-source developer tools for
folks interested in doing Bitcoin escrow in a non-custodial fashion.

_Block's call for mining community feedback_

Next item we highlighted here was Block, the company Block, and their call for
mining community feedback.  So, they posted an update about their 3nm mining
chip progress, but in addition to the actual just chips, they're trying to put a
Bitcoin mining sort of broader comprehensive system together.  So, they are
continuously asking the community for feedback.  This time, it's mining
community feedback that they're asking about in terms of, what kind of software
features are you looking for out of your mining hardware provider; what sort of
maintenance?  And there's also some other questions that they are hoping that
the community can help shape feedback on their mining system.

_Sentrum wallet tracker released_

Sentrum is a wallet tracker software that released recently, and this is a
watch-only wallet that actually, the idea here is that you provide this
watch-only wallet information and then some configuration information about how
you would like to be notified about if there's any changes related to that
wallet.  So, there's a bunch of notification options.  I think there's a slew of
communication ways that you can get notified that something's changed regarding
receiving a payment, for example.  You can get that as a desktop notification,
SMS, etc.  So, pretty simple, sort of like Linux philosophy of tools.  You have
this little tool that's just going to notify you when there's a watch-only
update to your wallet.

_Stack Wallet adds FROST support_

Stack Wallet adds FROST support.  This is the v2.0.0 of Stack Wallet, which
added threshold multisignature support using the FROST threshold scheme.  And
there's actually this modular FROST Rust library underneath all of that.  This
seems like fairly cutting-edge stuff.  I am unsure of the maturity of any of
this, but it is something that I thought was interesting to highlight.  Murch, I
don't know if you have any familiarity with this FROST Rust library, this
modular FROST Rust library, but yeah, I mean, I wanted to highlight it, but I
also asterisk this stuff's kind of new, it seems.

**Mark Erhardt**: Yeah, I don't want to sound mean, but I looked at the 2.0
release and from what I see, it's three people working on this, and in a single
release, they added Peercoin, Solana, Tezos, Stellar, FROST and taproot, and
that just gives me a bad feeling because it's so many things at once.  Maybe
they are super-efficient and really good programmers, but I know for a fact that
there's a few teams with cryptographers working for multiple months/maybe going
on to years on getting FROST safe to deploy in an enterprise environment, and
there's a lot of caveats.  There's a lot of things how you can do that wrong and
leave key material exposed.  So, I'm not familiar with Stack Wallet, but it just
sounds very ambitious, and I hope that they did their due diligence with that
implementation.

**Mike Schmidt**: We have heard about, I believe the name of the library is
libsecp256kfun, which I think has some FROST stuff in it that Lloyd Fournier and
the Frostsnap folks are working on.  I had not heard of this modular FROST Rust
library.  So, yeah, we're highlighting this, but we are not vouching for it in
any capacity.  Feedback welcome.

_Transaction broadcast tool announced_

Last piece of software was another of these sort of minimalist kind of tools.
This one is a transaction broadcasting tool called Pushtx.  All it is is a
simple Rust program that when you want to broadcast a transaction, it actually
starts the program, it looks at the DNS seed, and grabs some nodes there, looks
to see if Tor is running, and then broadcasts the transaction to ten different
Bitcoin peers, and then closes the program.  Murch, as a Bitcoin Core developer,
what do you think about that sort of approach of just only connecting to nodes,
broadcasting, and then sort of shutting down the "node".

**Mark Erhardt**: That sounds like a great idea.  And I'm very curious to see
how many people are going to start using that.  There is a similar PR in Bitcoin
Core.  I think I see Vasil also contributed to this, so I'm not quite sure what
the direction here is.  Is that just moving out of Bitcoin Core to be deployed
faster?  Well, anyway, the single connect to a Tor node in order to submit that
transaction is pretty cool because it gives you sort of a similar privacy model
as with Dandelion, which had all these open DoS attack surface.  And, well, if
it works and if those transactions come back to Clearnet from those Tor nodes
that received them originally, it would be a great way to improve the privacy of
submitting your own transactions.

**Mike Schmidt**: That wraps up the Services and client software section.

**Andrew Toth**: Sorry, can I just jump in there?

**Mike Schmidt**: Sure, yeah.

**Andrew Toth**: Yeah, I just want to say that I think this library is also
great for -- so there's a PR to Bitcoin Core, but that's in C++ and this library
is in Rust, so if any Rust wallet wants to add this private sending, they can
use this library to do that, which is great.  And then also, just a
clarification, it doesn't have to send the transaction to a Tor node, it sends
the transactions through Tor, which could be like through an exit node to
another Clearnet node, right?  And I think, yeah, echoing what Murch said, this
is a much simpler solution than Dandelion, and it's also ready today, so I think
we should really embrace this approach.

**Mark Erhardt**: Thanks for the correction.

_Bitcoin Inquisition 27.0_

**Mike Schmidt**: Releases and release candidates.  Bitcoin Inquisition 27.0.
This version of Inquisition is a signet client that essentially enables protocol
changes on signet in a way that you can sort of test out these particular
changes.  There's a bunch of cool stuff on there now.  27.0 activates OP_CAT
actually, which is specified in BIP347, as well as the BINANA repository
BIN24-1.  So, you can now play with OP_CAT on Inquisition, and if it's something
that you think is going to break, then go break it in Inquisition.

Also in Inquisition 27.0, support for annexdatacarrier was dropped.  That was an
option that allowed pushing from 0 to 126 bytes of data into the taproot input's
annex field.  That is now not supported any longer in Inquisition.  The plan
with that was to use the feature to allow people to experiment on signet with
eltoo.  I'm not exactly sure what happened with that, but this is being removed
now.  Additionally, pseudo-ephemeral anchor support was dropped as well.  And
then there is a new evalscript command for bitcoin-util, which can be used to
test script opcode behavior.  And you can actually specify different scriptSig
versions, so witness v0, tapscript and base are the options there.  Murch, did
you get a chance to look at this Inquisition release?

**Mark Erhardt**: I did not, but I'll talk a little about OP_CAT, okay?

**Mike Schmidt**: Sure!

**Mark Erhardt**: I mean, there seem to be a lot of people super-excited about
OP_CAT, and it's kind of interesting that they are, because OP_CAT by itself is
such a primitive building stone.  In a way, it allows you to do a lot of things
that are super-complicated and certainly wouldn't be adopted on mainnet just due
to the block space cost, but it would allow them to build these PoC
implementations of a lot of features that may or may not be demanded by the
broader community.  So, one thing that I hope to see on signet now is that
people show a few of these other opcodes in simulated fashion with OP_CAT in
order to show us how cool that would be if we had those.

Also, I saw someone mention, well, a lot of people have been saying, "Oh, OP_CAT
has been considered a bad idea many times in the past".  I haven't really seen a
lot of evidence of that.  If you are looking for ideas what you could do with
OP_CAT in order to prove that it's broken and shouldn't be adopted or turned on,
I would suggest that you could look, for example, at Bcash, which had OP_CAT for
six years, so they probably have some OP_CAT transactions that you can look at.
Anyway, I'm kind of curious.  I'm not personally invested in OP_CAT, but a bunch
of people have been talking about it and been very excited about it.  So, I'm
curious to see what people do on signet with it, and please show us it's broken
or it's really powerful.

_LND v0.18.0-beta.rc2_

**Mike Schmidt**: LND v0.18.0-beta.rc2 we've covered for several weeks.
Actually, I looked and there's actually a beta.rc3 out now.  When that is
actually out of RC status, we will cover it in the future.

_Bitcoin Core #27101_

Notable code and documentation changes.  Bitcoin Core #27101.  So, Bitcoin Core
has JSON-RPC functionality, but before this PR, the JSON-RPC server behaved
quite unique.  There's sort of a blend of support for JSON-RPC 1.0, 1.1, and 2.0
different behaviors.  This PR triggers strict JSON-RPC 2.0 spec behavior when
there is a JSON-RPC key that is set to the 2.0 value, so that key value pair
being detected now triggers appropriate JSON-RPC 2.0 spec behavior explicitly.
And also then, that sort of flag, if you will, helps preserve backwards
compatibility for the way things currently are as well.  Murch, anything to add
there?  All right.

_Bitcoin Core #30000_

Bitcoin Core #30000, what a cool PR number!  This allows multiple transactions
with the same txid to coexist in Bitcoin Core's TxOrphanage.  By indexing on
wtxid instead of just txid, you can now have two transactions with the same txid
in the orphanage.  We talked about this previously in Newsletter and Podcast
#301, as this PR Bitcoin Core #30000 was actually the PR Review Club highlight
in episode #301.  And we even had Gloria, the PR's author, on to explain it.
So, I think if you're looking to learn more about this, that would be a good
place to jump in.  Murch, we could punt everybody to that episode, or we can try
to elaborate on some of that here as well.  What do you think?

**Mark Erhardt**: I'm happy to talk more about it, but I was like, "Hadn't we
talked about this already?"  So, I guess it's only been three weeks.

**Mike Schmidt**: Go check out Gloria talking about this PR so we don't butcher
it on her behalf.  That is Newsletter and Podcast #301.

_Bitcoin Core #28233_

Bitcoin Core #28233.  I am relieved to see that Andrew is still in this Spaces.
He is the author of this PR and all I had down in my notes was, "Andrew?"  So,
Andrew, thank you for sticking around.

**Andrew Toth**: Hey, thanks.  Yeah, so this was great to get merged, but
basically some background on it is, your Bitcoin Core node has the UTXO set
which is all the unspent outputs, and whenever a new block comes in, it deletes
all the entries from the UTXO sets that are inputs to that block in their
transactions and writes new UTXOs for all the outputs.  And so, it does this
during validation.  It also checks that every input belongs to the current UTXO
set, otherwise it's an invalid block.  And so, when you're doing your initial
sync, it's basically doing this over and over for every block
800,000-and-something times, and so that can be very slow if all your UTXO set
is stored in memory, because for every block it'll have to delete all inputs and
write all outputs.

So, what Bitcoin Core does, it has this cache to store the diff of the UTXO set
so that it doesn't have to write it for every block.  So, it'll keep storing all
the spent UTXOs, but mark them as spent, and then just store the outputs in the
cache and not write them to disk.  And then once that disk gets full, so this is
the toggle you have in your config, the dbcache, it will flush all those changes
to disk and then wipe the cache.  Historically, this is the only way to write
all the UTXO changes back to disk, was to flush the cache and erase it, and now
you're back to a zero cache.  So, every time a new block comes in, now you have
to read every input back into memory, and that can be slow on a slow disk, also
because LevelDB doesn't have batch reads.  So, you have to read every single
input as the block is being connected and read each one individually from disk
while you're validating that block.  And so, once you're done IBD, you don't
really need this anymore because you can connect to every block as it's coming
every ten minutes, you don't have to do it as fast.  But there are some services
that really want your block connection to be fast.

So, what this PR does is change the way we save that cache to disk by not wiping
all the UTXO set out of it so we can persist that cache to disk.  So basically,
every 24 hours, so we don't lose data, it writes that cache to disk after IBD.
But it would flush that cache every 24 hours.  So now ,we don't flush it, we
keep all the UTXO set in memory, and so every block that comes in can be
connected much faster.  It doesn't have to read every input from disk, it can
just keep it in the cache.  Yeah, I hope that made sense.

**Mark Erhardt**: This is really cool.  This read from disk is not to be
underestimated, especially people with small, well, microcomputers, and if they
have connected their hard drive via USB, I think that is for many nodes the
bottleneck; is that right?  So, it doesn't really matter that much when you're
at the chain tip, because every time you see a transaction in your mempool, you
will already load the inputs.  So, the loading of the inputs for the new block
that is going to appear happens over time, and you generally are aware of all
the transactions that are in your mempool.  So, if you've seen almost all or all
transactions that are in the next block, you have all of the UTXOs in your UTXO
cache, right?  Oh, go ahead.

**Andrew Toth**: Well, I mean I think the mempool UTXO set is different than the
dbcache UTXO set.  And so, when you find a new block, it doesn't have to fetch
the transactions that are in the mempool from peers, it can just use them, but
it still has to then, for each input of that block, read the input from disk.
And so now, it has a longer-lived cache, so it doesn't have to read those
inputs.  So, what that means is like, for miners, so I noticed that there's a
lot of miners that sometimes have blocks that are empty, and this is because
once they receive a new block, before they finish validating it, they start
mining on an empty template.  And then, once they actually finish validating
that block, can they start actually mining with the transactions.  So, what this
will do is let them mine a full block faster.  So, ideally it will result in
fewer empty blocks.

**Mark Erhardt**: Now, I'm going to go out on a limb here.  I'm sure you've
looked at this more carefully recently than me, but I believe when you validate
a transaction, you need the inputs in order to be able to do script validation,
which we do on everything in a mempool.  And I believe at that point, we also
put stuff in the cache.  Is that not right?

**Andrew Toth**: I don't know if we put it into the UTXO cache.  We might, but
if we do, we're not clearing it every 24 hours like we used to.

**Mark Erhardt**: Yeah, and I'm super-excited about that.  You get me, right?
That's a great improvement because previously we've seen every time you flush
your UTXO cache completely, your block validation times spike after that for
like a factor 2, even.  And now, even if you have a small cache and you have to
flush kind of frequently, well, actually that's wrong.  If you flush fully, you
still flush, but only when you have the 24-hour-based flush, you keep it warm,
right?

**Andrew Toth**: Yeah, so right now, if you set your dbcache to like 5,000, you
probably only have to do a flush once a year or so probably, right?  So, you
won't have to do a full flush for a long time once you're out of IBD.

**Mike Schmidt**: Thanks for explaining all that Andrew and for the questions
from Murch.  Did a much better job than I would have, so I'm glad you stayed on,
Andrew.

_Core Lightning #7304_

Core Lightning #7304 adds the ability for CLN to, if it cannot find a path to a
node in an offers-style invoice_requests workflow, to just use a direct
connection for sending an onion message.  This would be for the case when a path
cannot be found, but the IP address of the LN node is known, for example if the
peer is a public node that's gossiped their IP address.  And this improves some
interoperability between CLN and LDK.

_Core Lightning #7063_

Core Lightning #7063, titled Reduce the feerate security margin in high fee
environments.  I'll quote a bit from the PR here, "The feerate security margin
is a multiplicative factor applied to the feerate of some transactions in order
to guarantee that the transaction remains publishable and has a sufficient
chance of being confirmed".  Previously, that security margin was a constant
value of 2, which essentially gave a margin of 100% feerate.  So, in low feerate
environments, that's obviously fine, if you double very low feerates, 1 satoshi
per vbyte (1 sat/vB) to 2 sat/vB.  But while it's fine in low fee environments,
it hasn't been a great fit lately with higher feerates.

So now, this PR re-architects that, instead of being a factor of 2, to have a
10% margin.  So, instead of 100% margin, it's a 10% margin in higher feerate
scenarios.  So, after this change, the multiplier starts at 2X the current
feerate estimates, and then as the feerates approach daily high maxfeerate, that
2S goes down to 1.1 as feerates increase, so making that margin a little bit
more dynamic based on what the conditions are for feerates.  Murch, this might
be something that you're interested in if you didn't get a chance to look at it
already.  I don't know if you did.  What do you think?

**Mark Erhardt**: I see Tony was going to say something.

**Tony Klausing**: I just wanted to mention that this channel reserve stuff,
like when I was working on stable channels, it's kind of a difference between
the RPCs of LND and CLN when you say, "Hey, what's the balance in my channel?
How many stats do I have in my channel?"  For example, LND takes out the anchor
outputs and channel reserve, and CLN treats it differently.  So, this whole
business with accounting for channel reserve and anchor outputs, and whatever it
is, can get hairy when you're trying to really suss out what every set is doing
in the LN channel.  And it was just a little bit of a pain point for me when
working with it.  Just something I wanted to mention quickly.

**Mark Erhardt**: Sorry, go ahead, Mike.

**Mike Schmidt**: Oh, I have nothing smart to say.  Did you have something smart
to say?

**Mark Erhardt**: I think that we saw in the past year a bunch of situations
where high-fee spikes caused issues between interoperability issues, similar to
the ones that Tony mentioned with the feerates, where one node said, "Hey, I
want to have a feerate of at least X", and then the other node was like, "Oh, I
don't want a feerate of more than half-X", and then they disconnect.  And I
think this is now related to the extreme spikes in feerates we've been seeing,
where suddenly we've had a block where previously the feerates were in the 8 to
12 range, and then suddenly someone starts minting a new rune and, whatever,
like the feerate goes to 250.  So, now the LN nodes that had previously
established a feerate with which they felt comfortable to be able to get their
commitment transactions through, would probably, in subsequent HTLCs (Hash Time
Locked Contracts) or channel updates that they negotiate, use a higher feerate,
right?

**Mike Schmidt**: Tony, did you have anything to say based on what Murch
mentioned?

**Tony Klausing**: No, I think it's just more ironing out all of these edge
cases with high fees, which Murch said, we didn't seem to face until the
super-high-fee environment.  It's just one of those edge cases with LN that
you've got to iron out over time and see what's best.

**Mark Erhardt**: I mean, in a way, you can have all sorts of feelings about
ordinals, inscriptions and runes, but one thing that they help us do is stress
test our software to high feerates, which a lot of us have been talking about
for many years.  If there is more adoption, if the price goes up, eventually
feerates will go up because people will be able to pay larger fees to get their
transactions through, and that will naturally make it hard for low-amount cases
to be competitive onchain.  So actually, one thing that I'm surprised to see is
that these extreme feerates that we've been seeing in the last year has not
caused an efficiency improvement in many established businesses.

So obviously, P2TR is pretty well established now already, and especially if you
have a multisig setup, it is a very significant decrease in input script size.
So, for example, if you have a 2-of-3 multisig, a P2WSH input is 104.5 vbytes;
and with P2TR, it would only be 58.5, I think.  So, you'd outright save
somewhere around 40% on every input if you switch to P2TR.  And I know that
service providers have implemented P2TR, but on the other hand we see the likes
of Coinbase still using wrapped segwit, which is for a single sig, 91 vbytes.
And even though they've been paying all these fees and there was this ridiculous
situation with this ordinal marketplace, where they collected all these tiny
payments because Coinbase will consolidate them for free for them, they're
paying this 50% extra on input size, even though the fees are ludicrously high.
So, theoretically, all of these high feerates and the stress testing would
provide economic pressure to make your business more efficient.  And I would
have expected, especially with the high feerates, people to start adopting at
least P2WSH or P2TR in order to save.  Yet, the biggest businesses don't seem to
feel any pressure at all, and it's quite astonishing.  So, in a way, feerates
are still too low, or they're just making too much money with other things.
It's kind of ludicrous.

**Mike Schmidt**: Well, Murch, we've run into something similar before.  I don't
remember if it was a year ago or more, but I think they're maybe still doing it,
but the Binance consolidation dump, there's some inefficiencies that they were
doing, I think.  You and I had spitballed it.  Maybe it was something like $2
million or something annualized that could be saved if they did it a different
way.  This is just another, I guess, version of that now.

**Mark Erhardt**: Yeah, it's on the range of an engineering day or maybe an
engineer week to enable sending to P2TR, or to do your consolidations better,
and they're burning money like mad.  My offer is still open.  If you give me 10%
of your savings, I'll come and implement it for you!

_Rust Bitcoin #2740_

**Mike Schmidt**: Last PR this week, Rust Bitcoin #2740, which is adding a
difficulty adjustment calculation in a method named from_next_work_required.
So, this from_next_work_required method takes parameters of the previous
difficulty target, a timespan between the current and previous blocks, and a
network parameters object, and then it returns the expected next difficulty
target.  So, if you need that sort of information in Rust, you can now use Rust
Bitcoin to calculate the next difficulty target.  Anything to add there, Murch?

I did not solicit questions at the appropriate time, but we did have some
comments here.  Salvatore actually linked to the post that we were talking about
with regards to taproot keys.  So, check that out in the Twitter Space thread.
I'm not going to read out the URL here by any means.  Murch, you got a shoutout
with your SP addresses being a real Bitcoin address.  And Larry makes a mention
talking about, I think it was the Bitcoin Core #30000 PR, about the fact that a
transaction can have multiple txids, and that he says, "It may be worth
mentioning transactions with the same txid can have different wtxids, but not
vice versa".  I did not see any other questions or comments.

**Mark Erhardt**: Would you like me to explain that?

**Mike Schmidt**: Oh yeah, go ahead.

**Mark Erhardt**: Okay, so the whole idea with segwit was that we needed a way
to fix a bunch of transaction malleability issues, which was you could negotiate
a transaction with a counterparty, but then not rely on that txid remaining
unchanged because, for example, the counterparty would be able to just re-sign
their side of the transaction and thereby change the txid.  Even worse, there
are issues with the ECDSA signatures, where any party can change the
transaction's signature after the transaction has been broadcast.  For example,
you can just flip the S value in the signature, and that also does change the
txid in legacy transactions.

So, the trick with segwit is that the malleable data still exists in the
transaction, but it only appears in the witness stack.  And the witness stack,
or the witness section in general for all inputs, does not contribute to the
txid; it is skipped for the calculation of the txid.  However, in the block, you
still want to have a way in order to commit to the wtxid data.  So, we added a
new commitment in the block, which is on an OP_RETURN output in the coinbase
transaction of segwit blocks, which commits to the wtxids of all the
transactions.  And the wtxids are different from txids such that they do commit
to the witness data.  They take the whole serialized transaction, including the
witness data, to calculate the wtxid, whereas the txid is only calculated from
the non-witness data, which also makes it backwards compatible for non-segwit
nodes.

So, to have a transaction that has the same outcome is possible by having, for
example, a different witness section, where one spends the keypath and one
spends the scriptpath, or where just one signature was made slightly
differently.  And if you have a different signature on your segwit transaction,
it would have a different wtxid, or if you're doing an alternative spend, like
keypath versus scriptpath; whereas, the txid stays the same because witness data
does not matter for txid.  So, this ties into the whole Bitcoin Core #30000 PR
about the orphanage, how you would be able to have two transactions that have
the same txid but different wtxids.

The shenanigan that people would be able to do here is, if they changed the
witness stack in a way that the transaction is invalid, you might see a
transaction with a specific txid already, and then be like, "Well, this is
invalid".  And in the very original behavior, you might not ask for this
transaction again after it's announced by a peer to you.  You would reconsider
it if it appeared in a block, I think.  But people realized that and then made
it so that when you saw an invalid transaction with an issue in the witness
data, you would only not request transactions with the same wtxid anymore, but
still be open to look at a second version with the same txid.  /rant!

**Mike Schmidt**: That was great.  Larry, thanks for noting that.  And then,
Murch, thank you for double-clicking on that and explaining that.  I think that
wraps up the newsletter for this week.  Thanks to our special guests, Andrew,
Antoine, and Tony, and to my co-host, Murch, as always.  Thanks for your
questions and comments from the audience, and we'll see you next week.

**Mark Erhardt**: Enjoy the holiday.

**Mike Schmidt**: Cheers.

{% include references.md %}
