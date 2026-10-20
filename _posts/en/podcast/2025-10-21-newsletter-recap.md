---
title: 'Bitcoin Optech Newsletter #376 Recap Podcast'
permalink: /en/podcast/2025/10/21/
reference: /en/newsletters/2025/10/17/
name: 2025-10-21-recap
slug: 2025-10-21-recap
type: podcast
layout: podcast-episode
lang: en
---
Gustavo Flores Echaiz and Mike Schmidt are joined by Francesco Madonna and supertestnet to discuss [Newsletter #376]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-9-28/410145486-44100-2-a52d19dd7fb1c.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #376 Recap.
This week, we're going to be covering an update on the proposal for peers to
share current block templates with other peers to improve propagation across a
divergent mempool network.  And we also have a covenant-less vault construction
that we're going to get into first, built from existing primitives and doesn't
require a soft fork.  And we have our normal Releases and Notable code segments
as well.  This week, I'm co-hosting with Gustavo again, and we are joined by two
guests.  Francesco, you want to introduce yourself for listeners?

**Francesco Madonna**: Yeah, hello, everyone.  I'm Francesco, I'm the Founder
and CEO of BitVault.sv, the first solution to solve the problem of physical
attacks and hacks.  I'm interested in the security side of Bitcoin.  I think
Bitcoin is cybersecurity for money and can very well serve this purpose for the
people.  Also, I like to scale and I identified what we all know, some problems
with the self-custody experience, which is essentially the loss of the keys.
Non-custody is great, but we are all scared to lose our keys.  And so, I've been
dwelling in my mind for a long time how to overcome this issue, and one year and
two months ago, I started thinking about it more deeply and came up with a
draft.  So, I decided to go talk to Super Testnet to have a first review of this
concept.  He was so kind to review it.  I remember for three days and three
nights, he always pushed it back and tried to find some way to crack it, because
I told him to try to find a way to crack it.  And, yeah, sorry, I don't want to
be too long.

**Mike Schmidt**: Yeah, we'll jump into that more in a second.  I want Super
Testnet to introduce himself as well.  Who are you, Super Testnet?  Where are
you, Super Testnet?

**Super Testnet**: Sorry, I'm having some connection issues, I apologise.  Yeah,
I'm Super Testnet, I'm an independent software developer.  I focus on research,
development, and prototyping of typically layer 2 ideas, although in this case,
I'm researching and possibly going to make a prototype of a layer 1 thing.
Yeah, and that's basically it.  I just do that all the time.  I either come up
with ideas or I review other people's ideas and if I think they're really cool,
I'll try to build them and show how they can work.  I also do a lot of
education.

_B-SSL a Secure Bitcoin Signing Layer_

**Mike Schmidt**: Well, thank you both for joining us today.  For those
listening, we're going to go a little bit out of order.  We're actually going to
do the second news item first since both of our guests today are participating
in the second item.  We want to be conscious of their time.  So, we're going to
jump right into that, which is, "B-SSL, a Secure Bitcoin Signing Layer".  And
this was spurned by a post from you, Francesco, about B-SSL, the Bitcoin Secure
Signing Layer that proposes a taproot- and timelock-based scheme with three
spend paths.  And I'll let you take it from here.  Maybe you can explain a
little bit of the motivation, you started getting into that already, and then
the more technical approach as well.  So, go ahead.

**Francesco Madonna**: Yeah, disclaimer first of all, I'm not a developer.  I
just like to design systems.  I like theory and logic, and that's what I focused
on.  I'm learning a bit of Python, but still early compared to the professional
here.  So, what this problem was for me was really challenging for everyone and
their self-custody experiences.  If you lose your keys, I mean, it's over, game
over.  So, I ask to myself, how can you make that non-custodial system where the
user owns his own keys and he can also give a copy of one key to one custodian
and another key of a multisig of a 2-of-3 to another custodian, and the two
custodians cannot collude.  So, if you lose your keys, you can go to the
custodians, you pay them for the service, and they can just be useful to give
back the key and you can recover the funds.  And this was a lot challenging
because I thought one year ago when I started thinking about it, it requires
some maybe opcodes which were not available, still not available.  The first
draft I submitted to Super Testnet was likely possible, but I would have needed
the CSV (CHECKSEQUENCEVERIFY) plus the CSFS (CHECKSIGFROMSTACK).  So, I kept it
in my drawer for one year, and then just kept thinking about it.  But I was
thinking to start to do it on Liquid, then to push the activation of CTV
(CHECKTEMPLATEVERIFY) on the mainchain, until ten years ago for a series of
fortunate happenings, then I went back into it.  And with many reps, I managed
to find a solution which is covenant-less.

So, basically, to sum up how the scheme works, it's like, say, the taproot
policy.  Then, you have three keys, or the multisig, so three, A, B, and C.  So,
the user has the key A, has the key B, and has the key A1.  The key A1 is a
mirror copy of the key A, and it's there just to recreate the redundancy,
because the key B with C cannot be used.  This is being sacrificed.  So, the
custodian, on the other hand, has only key C, one custodian has the key C of the
multisig, and the key B1, which is a mirror copy of key B.  Now, when it
clicked, it clicked because I thought to have the policy with the three-tiered
system, where the policy 1 has one time delay, the policy 2 has another time
delay, and the policy 3 has another time delay.

So, the policy 1 states that the user can sign after a short time delay by
utilizing his key A plus the key C of the custodian, which is liberated, let's
say, by a Convenience Service (CS), which is how BitVault works.  CS is trusted,
it's open source, whatever.  But what if the convenience service is tampered,
doesn't work, or the custodian doesn't comply?  Nothing happens because there is
the leaf number two, which states the user can sign independently with his key A
plus key B plus one year.  So, you can always unilaterally move the funds after
one year, it's always in control.

Now, we need a third condition here to make sure that the two custodians cannot
collude.  And the third condition is the third leaf, which is B1, which is the
mirror copy of B, by custodian one, plus the key C, plus three years.  And this
makes sure that if the user moves the fund after one year and nine months, so he
will always have one year to move the funds independently before the three-year
time is up.  He can always be in control and the custodian cannot collude.  I
talked to a developer friend of mine who said that it's possible to be
automated, the rollover of the funds, after the vault origination.  So, to me it
was clear the problem was solved at this point.

So, I submitted the paper to Super Testnet, they viewed it, they liked it, and
they also offered some very good ideas to make it better, be automated, and
there are a lot of other use cases of this discovery, as I name it.

**Mike Schmidt**: All right, so Super, maybe you can help opine on this, and
maybe for listeners, you can maybe tell us your take on how this is different
from some of the other collaborative custody or insurance type products, the
Lianas out there.  And then, maybe you can also give your thoughts on the
scheme?

**Super Testnet**: Sure.  In general, I think this scheme is a three-path
scheme.  There's three different leaves in the taptree.  At a high level, the
first one lets the user spend their money with two-factor authentication
provided by the CS with a 15-day timelock.  So, if you want to spend your money,
you can't do it until 15 days have passed.  And that's supposed to protect
against kidnapping schemes, where someone kidnaps you and says, "Send your
money, or we're going to hurt you or your family", or something.  You can
provably show, "I can't spend this money for the next 15 days".  And if they
know that in advance, they may not even try, because that kind of time delay
increases the cost of such an attack, especially if you're a really wealthy
person and you've maybe got people trying to rescue you.  It's really expensive
for the attackers to hold you captive for 15 days.

The second path is a recovery method.  After a one-year timelock, you can
recover your coins without the help of the CS.  And that's nice because if the
two-factor authentication service goes down, if they disappear, if they become
malicious, you don't need them.  After one year, you can get your money out
unilaterally.  And the third path is the custodian path, where if three years go
by and you haven't spent your money or moved it or cycled it, that's considered
an indication that you've lost your keys, and the custodian can take your money
out and put it in some kind of custodial account.  And this could also, I think,
be used for some sort of inheritance thing.  It might be easier if you die and
put in your will something like, "Hey honey, you don't have to learn how to use
a Bitcoin wallet.  Just log into my Coinbase account or Robinhood account or
whatever, and after three years, the money should be there because the custodian
sweeps it into there".  That might work really well for an inheritance scheme as
well.  But it also works if you're worried about losing your keys.  Well, at
least you have the fallback that after three years, you'll get it back as long
as the custodian is not also malicious.

So, I think that's a pretty cool idea and that's what the white paper outlines.
I think it has some flaws.  One of them is that if you put money into this
vault, the 15-day timelock starts counting, and you're going to have to cycle it
again after 15 days.  Otherwise, the first path, it's got that 15-day timelock,
but if you put money in there, and then the 15 days go by, it doesn't apply
anymore, so you kind of have to cycle it again.  So, there's a couple of ways to
resolve that.  Both of the ways that I've thought of or heard of reuse presigned
transactions.  But you could set up a series of pre-signed transactions before
you put money into this scheme, so that without your interaction, the CS could
broadcast a transaction, cycling transactions that keep on putting your money
back into the vault and resetting the timelock, which sounds like it could work.

Then, I thought of a way that if you put your money into one Bitcoin address
that is just a normal Bitcoin address, and then signed a transaction that puts
the money in the vault there, you could give a copy of that transaction to the
CS and to yourself.  So, you keep a copy, and they keep a copy, and then delete
the private key to the address that your money's in.  And that would effectively
make it so that if you ever want to spend your money in the future without
needing to cycle, you could then just broadcast that transaction to put it in
the vault.  That would trigger the 15-day timer.  And after that, you can spend
your money.  So, those are some of the proposals I made for how to improve the
design of the system.  And yeah, those are my basic thoughts on it.

**Mike Schmidt**: For those listening and couldn't see Super Testnet drop, so we
can carry on the conversation from here.  Gustavo, I'm hearing there's just
pieces of this that sound familiar.  Obviously, there's component of this 2FA,
which makes me think of Green wallet from back in the day, where you have some
form of a 2FA and sort of a 2-of-2, which also had a similar fallback mechanism.
I don't remember what the timeframe was, but if the CS shutdown or was
malicious, then after some period of time, you could also then take unilateral
control of your funds.  And then, it has this third path, which is sort of the,
I guess, inheritance, or some sort of a bad event happens and you don't have
access to your keys or whatever, then you have this ultimate fallback as well.
Gustavo, do you have questions for Francesco?

**Gustavo Flores Echaiz**: No, I think it was pretty clear from that explanation
what would happen here.  I guess the only question is, so the first path, it's
completely configurable depending on the provider's policies, right?  Let's say
I'm a co-signer, I could decide to offer this service with a configurable two
hours versus a 15-day delay, is that it; that's up to the co-signer to decide?

**Francesco Madonna**: Yes, the CS which offers this service which avoids that
the coins get spent before the time delay has passed, I mean can be either
self-hosted or managed.  So, if it's self-hosted, it's not better for attacks,
it's better if it's hosted by the custodian, because you have a kind of
redundancy there.  But if you self-host it, in the short term, you are more
secure, because you can better move and control it, make sure nothing happens.
And if it's open source, then it's trustworthy.  So, that's a nice addition.
And so, you can play with the configuration a bit there, depending on what end
result you're looking for.  More secure in the short term or for the keys
recovery, or whatever.  So, this marks, in my opinion, the end -- he's back, so
maybe he has some comments.

**Mike Schmidt**: Welcome back, Super Testnet.  Did you want to continue your
thoughts?

**Francesco Madonna**: I think it marks the end between non-custodial and
custodial, because nobody after this will go to a custodian service to make him
to dispose of his funds.  He can move, while they can just pay the custodian to
hold the keys, and the custodian cannot move the coins.  So, that's a really
paradigm shift for the custodian.  So, I guess as soon as the first custodian
will start to use it and sell this service, why would anybody give the control
of the funds to a custodian?  We'll just use the recovery service now.  If you
can talk, interrupt me.  No?

**Mike Schmidt**: Francesco, how has feedback been from the community on your
idea?

**Francesco Madonna**: It's logically sound, feasible onchain, covenant-less.
It's very usable, it's great usableness, I think everybody's happy.  I am
because I understood that was the last missing piece for self-custody to scale
to the masses, because come on, why other people use custodians is because
they're fearful of losing their keys.  Now, that's not possible anymore.  Until
the custodian, they pay for in a legal framework, they actually give back the
keys.  But again, the custodian, they cannot steal the funds, even if they don't
give back the keys.  So, what's their incentive there of losing all of the
customer if they cannot steal the funds?  So, they'd better give back the keys
if the user ask for it, because otherwise they end the business.  So, there's
also a kind of economic incentive there, which makes it, yeah.

**Mike Schmidt**: Gustavo, anything else before we move on to the previous news
item?

**Gustavo Flores Echaiz**: All clear from my side, thank you.  Very cool idea.

**Mike Schmidt**: All right.  Well, Francesco and Super Testnet, thank you both
for joining.  Sorry, we had a little technical difficulty.

**Super Testnet**: It sounds like you can hear me, but I couldn't hear what you
said.  Sorry, Gustavo.

**Francesco Madonna**: By the way, if you go to b-ssl.com, you can read the
whitepaper.  Thank you.

_Continued discussion of block template sharing_

**Mike Schmidt**: All right.  Thanks again for joining us, Francesco.  Cheers.
We're going to jump back up to the first news item, which is titled, "Continued
discussion of block template sharing".  And the idea, as a reminder for folks
here, although we've covered it a couple of times, is that full nodes could
occasionally send each other their current block template.  I think there's
actually the first two full blocks' worth of transactions that would be encoded
like a compact block to their peers periodically, in order to share within the
network what you think your best two blocks' worth of transactions are, and your
peer does the same.  And the idea is then, even if you're not going to relay
some of those, that they would be cached and that you would have those for
enhanced or faster compact block propagation than you would if you weren't aware
of those transactions.

We actually had AJ on when we covered his post originally in Newsletter #366.
So, we have both the written version and also AJ's thoughts from the podcast in
#366.  And then, we also covered when there was a BIP draft opened on block
template sharing, and that was in Newsletter #368.  We talked about it with
Murch, but we did not have AJ on for that one.  But we sort of see the progress
of this proposal over the weeks.  And recent feedback on that original Delving
thread focused on some concerns around privacy or fingerprinting risk based on
these template deltas.  And we also noted in the newsletter that the spec moved
to the BINANAs repository.  And so, you can find the link for that in the
newsletter.  But Gustavo, did you get a chance to dig into some of this privacy
and fingerprinting concern?

**Gustavo Flores Echaiz**: Yeah, so I guess the main concern about
fingerprinting or privacy is that when I've requested a template, a block
template, and I as a node have found which transactions I want to request
directly because I don't have them yet, over time, it gives the sending node the
ability to determine what is my mempool policy rules, right?  Because if I'm
always requesting sub-1 sat transactions, then he can over time predict and kind
of craft what my sub minimum relay fee configuration is.  The same with
OP_RETURN, or all sorts of mempool policies.  That's the main concern, the main
privacy concern, is it just allows another node, a peer node, to determine what
are your mempool internal policies.

The other concern is the collision that an attacker could deliberately craft
colliding txids, and then once you compare against your mempool the template
with those txids, collisions change which items you request, and again it leaks
your mempool composition.  But all ideas turn around basically the fact that you
can get identified as a node, either through your relay mempool policies, or an
attacker could craft a colliding txid, short IDs specifically, which are the
ones used to identify each transaction, and that confuses which transactions you
request, because two transactions have the same colliding short ID.  But yeah,
that's basically the main concern.

So, this was moved as a BINANA, Bitcoin Inquisition Number and Named Authority,
so that it could address these considerations and just to refine the proposal.

**Mike Schmidt**: Was there also discussion about whether it should be a BIP or
not?  Or was it moved to BINANA just for continued work on the draft?

**Gustavo Flores Echaiz**: From what I understood, it was moved to BINANA to
address these concerns, to refine the proposal, to not be vulnerable to these
sorts of attacks or leaks.  That's the idea I kind of got from this.

**Mike Schmidt**: All right, great.  Well, I mean, normally we would maybe cover
that in more depth, but we've already covered it twice.  So, I think this is
just a good update for our listeners.  I think we can wrap that one up and move
to the Releases section.  We have three releases this week that we covered.

_Bitcoin Core 30.0_

First one, Bitcoin Core 30.0.  Gustavo, I'll turn it over to you.  You can go
through the Releases and Notable code.  I'll have some things to say as well.

**Gustavo Flores Echaiz**: For sure.  So, this week we have both Bitcoin Core
30.0 and Bitcoin Core 29.2.  So, Bitcoin Core 30 is the latest version release
of Bitcoin Core.  You could find the release notes on the newsletter, but there
are several significant improvements.  The most popular ones are those that have
changed the defaults on some mempool relay policies.  Specifically, the minimum
relay feerate was dropped to 0.1 sats/vB (satoshis per vbyte); and for any
incremental relay feerate, the same thing; and for the default minimum block
feerate, which always has to be lower than the minimum relay feerate, that was
dropped to 0.001 sats/vB, which is effectively the minimum.

There's also the OP_RETURN outputs.  Multiple OP_RETURN outputs are now standard
in a transaction.  The default datacarriersize, which effectively limits the
number of the bytes or vbytes that an OP_RETURN output or transaction consumes,
the cap is basically lifted, because it's raised to 100,000, which is
effectively the standard transaction size limit.  So, the defaults here are
changed for that.  But in preparation for BIP54, there's a new maximum on the
legacy signature operations that are included in the standard transaction.  A
new cap is put at 2,500 and there's improved transaction orphanage DoS
protections and other package relay transaction orphanage improvements.  A new
bitcoin CLI tool, which allows you to you experiment with the inter-process
communication (IPC) mining interface for Stratum v2 integrations.  A new
implementation of the coinstatsindex, because I believe it was a race condition
that had an issue.  The previous implementation had a race condition issue, and
this new implementation fixes it.

The natpmp option now being enabled by default, I think this one's pretty cool.
So, if you have a node behind a firewall, you don't have to configure your
router.  Bitcoin Core by itself can make sure that it's reachable through natpmp
protocol.  And finally, support for spending and creating TRUC (Topologically
Restricted Until Confirmation) transactions are also added to this version of
Bitcoin Core.  So, a very heavy release.  I recommend everyone to check out the
release notes for all the other updates.  Any thoughts here, Mike?

**Mike Schmidt**: Yeah, I have a couple of thoughts.  I actually put together a
Twitter thread a couple of weeks ago, and I looked at the release from a little
bit different perspective.  I looked at all the PRs essentially between 29.1 at
the time, I think, and the master, which was basically going to be 30.  So, I
counted 577 PRs merged that were related to v30.  And I exported those into a
Google Sheet for people to look for themselves, but I categorized things by the
different labels and did some metrics on it, with seeing that tests were
actually the most prevalent PR in the release.  I know a lot of those we don't
talk about, and neither does Twitter, but I think we all want the software to be
better tested.  And then, we sort of go through all the other top labels,
including the build system.  There's a lot of documentation changes so that
users can understand how the RPCs work, and things like that.

I know you highlighted some of the policy-related PRs.  If you look at the
policy label, that was four PRs out of the 500 or so PRs were policy-related,
although those are, of course, higher profile.  Discuss and fight about those.
But obviously, there's a lot of other PRs in there.  Also, something that didn't
make the release notes, and I guess this is something that Bitcoin Core
developers don't include in the release notes, is performance improvements.  If
you look at v30 IBD (Initial Block Download) versus 29, it's actually 20% faster
in 30 than 29.  And if you look back to v25 IBD, actually v30 is twice as fast
as Bitcoin Core v25.  So, there's been some good improvements.  I think lots of
shaving off percents here and there that have been done over a series of PRs.
And so, I think it's nice to acknowledge that.

Then, review comments-wise, I thought it was interesting to see those numbers
and I took a look.  And of those PRs, there was those 500 or so PRs, there was
about 16,000 total review comments on those code changes, which is about 30
review comments each.  And I also looked and saw how long each PR was open and
looked at some aggregates there.  The average PR was open for 41 days before
being merged.  But that does include a lot of these sort of smaller
documentation and trivial PRs.  And when you take those trivial PRs out and look
at how long the PRs were open, they were open on average 60 days.  So, over two
months per PR.  So, I thought it was interesting to dig into the release from a
different perspective, because we talked on the show before about the features,
we talk about some of the individual PRs on the show here, but sometimes we
don't look at the aggregate and all of these other PRs and what exactly are
they, how are they categorized.  And so, I took a look at it that way.

**Gustavo Flores Echaiz**: Very cool.  I hadn't thought of it like that, but
yeah, that's a great analysis.  Awesome.  Let's move forward.

_Bitcoin Core 29.2_

So, Bitcoin Core 29.2, this is a minor release, containing several bug fixes
that were part of Bitcoin Core 30, but as a minimum maintenance release, Bitcoin
Core 29.2 has bug fixes related to the P2P, to the mempool, to the RPC, and many
CI docs improvements.  Anything you want to cover in detail on this one?

**Mike Schmidt**: No, I don't think so.  I think that's good.

**Gustavo Flores Echaiz**: Awesome, yeah.  28.3 should come out, if it hasn't
already since we wrote this newsletter.

**Mike Schmidt**: Yeah, I think I saw fanquake posted earlier.  Yeah, 28.3 is
out and there's release notes for that.  So, check that out if you're proactive.
Otherwise, we'll talk about that next week.

_LDK 0.1.6_

**Gustavo Flores Echaiz**: Perfect.  So, we have v0.1.6 for LDK.  This is a
release that includes mostly security vulnerabilities related to DoS, and a
funds theft potential attack too.  And it has other performance improvements and
several bug fixes.  So, basically there's talk of two vulnerabilities, one of a
DoS.  This one, basically the way it works here in the release note, it says
that when the channel has been foreclosed, we have already claimed some of its
HLTCs onchain.  And we later learned a new preimage allowing us to claim further
HTLCs (Hash Time Locked Contracts) onchain.  But this, in some cases, generates
invalid claim transactions leading to loss of funds.  So, basically, I believe
this was part of the Notable code and documentation changes.  Yeah, so I'll just
cover that at that point.  Any extra thoughts here?

**Mike Schmidt**: Yeah, I was just going to say, I think we get to that later.

**Gustavo Flores Echaiz**: Yeah, perfect.  Okay, so moving on to the Notable
code and documentation changes.  This was an easy week, just five topics.

_Eclair #3184_

The first one, Eclair #3184.  In here, there's an improvement in the cooperative
closing flow, where a shutdown message is resent upon reconnection, when it had
already been sent before disconnecting.  So, this is just Eclair aligning to the
BOLT2 policy that whenever the message, shutdown, which is used to communicate
that we want to cooperatively close a channel, well, if a node disconnects, on
reconnection, it just sends the message again.  And specifically for simple
taproot channels, Eclair generates a new closing nonce for the recent shutdown
message and persists it to allow the node to produce a valid closing signature
later.  So, this is just Eclair updating the nonce that is used to produce the
signature.  So, in case it got shut down when it disconnected, it doesn't
persist the previous nonce that was part of the first shutdown message; it will
create generate a new nonce for the new message.  Any thoughts here?  No?
Awesome.

_Core Lightning #8597_

Core Lightning #8597, this one prevents a crash that occurred when a direct peer
returned a failmsg after Core Lightning (CLN) sent a malformed onion message via
sendonion or injectpaymentonion.  So, basically, CLN used to treat the failmsg
response from a direct peer as if it was a failonion message that came from a
further down hop.  So, it basically expected that the failmsg, because it didn't
come from a direct peer so that it was encrypted, because it failed to decrypt
an unencrypted message, it simply crashed.  But now, it's able to handle this
failmsg response properly because it comes from a direct peer.  And so, it
doesn't try to decrypt the message, it's already decrypted, and the node now
returns a clean error instead of just crashing.  Any thoughts here?

**Mike Schmidt**: No, it makes sense.  I mean, maybe a little bit surprising
that that was in there, but maybe I don't understand the full nuance.  But yeah,
thanks for explaining it.

**Gustavo Flores Echaiz**: Yeah, I mean it's always sometimes surprising the
things you hear, right?  This is the point I make with a lot of people.  I'm
like, "Bitcoin is not a finished project".

**Mike Schmidt**: Yeah, I mean we've had Matt Morehouse talk about these things
too, especially in the Lightning ecosystem.  So, I'm glad they're fixing these
things.

_LDK #4117_

**Gustavo Flores Echaiz**: Awesome.  LDK #4117.  This one introduces an opt-in
deterministic derivation of the remote_key using the static_remote_key feature.
This allows users to recover funds in the event of a foreclose using only their
backup seed phrase.  Previously, the remote_key depended on per-channel
randomness, which required the channel state to recover funds.  So, this new
scheme is opt-in for new channels, but when you splice an existing one, it
automatically applies.  So, just an improvement here on how a user can recover
funds when a peer forecloses a channel, using only his backup seed phrase, not
requiring static channel states that someone has auto-generated for you.  This
is just a simple recovery mechanism.

_LDK #4077_

LDK #4077 adds two events, SplicePending and SpliceFailed.  The first one is
emitted once a splice funding transaction is negotiated, broadcast, and locked.
So, except in the event of an RBF, the splice is pending, it will confirm at
some point.  However, the failed message is emitted when a splice aborts before
locking, due to an interactive-tx failure, tx_abort message, a channel shutdown
or a disconnection.  So, just two new user-facing messages, events, added to
LDK.  Any thoughts here?

**Mike Schmidt**: Yeah, it sounds like for splicing, as part of the splicing
protocol, they have this quiescent state or quiescence, and no channel updates.
And it sounds like if something goes wrong with the splice during that, that's
when LDK will emit this SpliceFailed event, it seems.  Seems pretty
straightforward.  And then obviously, client applications can handle that
accordingly.

_LDK #4154_

**Gustavo Flores Echaiz**: Exactly, that's exactly right.  We finish with LDK
#4154, which updates the handling of the preimage onchain monitoring, to ensure
that claim transactions are only created for HTLCs whose payment hash matches
the retrieved preimage.  So, for example, this is the one that we were talking
about on the Release section related to LDK.  So, whenever a node learns of a
preimage when he's monitoring the chain, he used to try to claim every HTLC that
he possibly could, expired ones, and those that in his cache or in any safe
space, he had his preimage.  And this would turn it into some failure claim
transactions, invalid claim transactions.  So, now the node will only claim the
preimage he learns at that moment.  He won't try to claim other HTLCs that he
could potentially claim, to make sure that he doesn't produce an invalid claim
transaction.  And in some cases, the previous behavior could even lead to fund
loss if the counterparty timed-out another HTLC first.  So, just an improvement
in the handling of how LDK tries to claim HTLC's onchain and reduces the risk of
producing invalid transactions and potential fund loss even.

**Mike Schmidt**: Makes sense.

**Gustavo Flores Echaiz**: Any extra thoughts here?

**Mike Schmidt**: No, nothing to add there.  Yeah, just a short Notable code
segment.  Well, we've had shorter, but you've been in for a bunch of long ones.
So, we'll give you a break this week.  I guess you gave yourself a break this
week with only five.  We want to thank our guests this week, Francesco and Super
Testnet, for joining us to talk about the vault construction that they put
together.  And obviously, thank you to you, Gustavo, for co-hosting again this
week and for you all for listening.  Cheers.

**Gustavo Flores Echaiz**: Thank you, Mike.

{% include references.md %}
