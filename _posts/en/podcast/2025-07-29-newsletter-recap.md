---
title: 'Bitcoin Optech Newsletter #364 Recap Podcast'
permalink: /en/podcast/2025/07/29/
reference: /en/newsletters/2025/07/25/
name: 2025-07-29-recap
slug: 2025-07-29-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Matt Morehouse and Jesse Posner to discuss [Newsletter #364]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-6-31/404891918-44100-2-eb6b0d281c481.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #364 Recap.
Today, we're going to talk about an LND vulnerability related to gossip; we're
going to talk about a technique that allows custodians to enforce spending
policies without having an xpub; we want to talk about post-quantum signature
schemes and how they could support things that we like, like HD wallets, silent
payments, and other wallet primitives that we have today; we have three Stack
Exchange questions; and then we have our regular Notable code and Release
segments.  Murch and I are joined this week by Matt Morehouse.  Hey, Matt.

**Matt Morehouse**: Hey, folks.

**Mike Schmidt**: And Jesse Posner.  Jesse, how are you doing?

**Jesse Posner**: Good, happy to be here.

**Mike Schmidt**: We're lucky to have both of you to help us cover the news this
week.  We have three news items that you both are involved with.

_LND gossip filter DoS vulnerability_

The first one titled, "LND gossip filter DoS vulnerability".  Matt, you posted
to the Delving-Bitcoin Forum about a disclosure of a vulnerability in LND around
gossiping.  What exactly did you find?

**Matt Morehouse**: So, this vulnerability affects LND versions 0.18.2 and
below, and it basically causes the LND node to run out of memory and either
crash or hang.  The vulnerability itself is pretty easy to understand.  In the
LN protocol, there's this message called the 'gossip timestamp filter', and this
message is something you send to your peers to basically tell them you want to
receive gossip within a certain range of timestamps.  And this could be gossip
that's received in the future and you want them to forward it to you, or it
could be gossip that they received at some point in the past and you're asking
them to load that gossip from their database and send it to you.  Now, this is
fundamentally an asymmetrical interaction.  So, the gossip timestamp filter is a
40-byte message, but the amount of gossip you're requesting from the peer could
be several megabytes.  And so, it's very critical that LN implementations are
careful in how they handle this, so that they don't use too many resources.

Unfortunately, LND was not careful in this regard, and they did just the
simplest way of handling this message you could think of.  They loaded all the
requests of gossip into memory at the same time, and then attempted to send it
all immediately to the peer.  And what this meant is, it was very trivial for an
attacker to just send a whole bunch of gossip timestamp filters and cause LND to
run out of memory.  And that's the entire vulnerability.  LND 0.18.3 included a
mitigation for this, where they basically limited the global number of gossip
timestamp filters that they would service at the same time.  They didn't really
fix any of the large memory usage per request, but this global limit is enough
to prevent LND from running out of the memory.

**Mike Schmidt**: Did I see that there was another attempted mitigation as well?

**Matt Morehouse**: Yeah, so the first attempt at fixing this, it could be
easily bypassed.  So, it was a per-peer limit originally.  But unfortunately,
it's very easy for an attacker to imitate different peers by just setting a
different node ID when they connect to you.  And so, this mitigation could be
easily bypassed just by changing your node ID on each connection attempt.

**Mike Schmidt**: Because it doesn't have to be a channel peer that is
requesting this information, right?  So, you can spawn up as many of these as
you want.

**Matt Morehouse**: Exactly.  You don't have to open a channel at all.  The
attack is zero cost.

**Mike Schmidt**: Okay, so previously there was no limit on rate-limiting the
number of these requests, or the potential, I guess, size that you would be
returning or amount of work that would need to be done per each request, but now
there is a limit on the number of requests, is that right?

**Matt Morehouse**: Yeah, so there's still no rate-limiting on how fast they
will send the messages to you, but there is a limit to how many gossip timestamp
filter requests they're going to respond to at any given time.  So, once that
limit is hit, then any other gossip timestamp filter messages just get queued,
and they don't respond to them until some point in the future when they have
more bandwidth.

**Mike Schmidt**: And I saw that in your write-up, you also noted that you set
up a test for this.  How long did it take for you to crash the LND node in your
testing, and maybe what was the size of that machine?

**Matt Morehouse**: Yeah, so I set up a small machine with 8 GB of RAM, 2 GB of
swap, and the RAM pretty much ran out immediately once I started the attack.
And once that happened, it started swapping, and the LND node became basically
inoperable, it was just super-super-slow.  I wouldn't feel safe if my node was
swapping like that, because there's no guarantee it's going to respond to revoke
commitment transactions being mined, or things like that, in a timely manner.
But I kept doing the attack and it took two hours after swapping started for the
process to actually be killed by the operating system.

**Mike Schmidt**: Was there an interesting story in how you found this
particular vulnerability?

**Matt Morehouse**: Not really.  So, I was just looking at the code and I didn't
have to look very hard to find this.  I don't think this vulnerability is very
difficult for people to understand or even notice.  I think any experienced
engineer would be able to spot this.  So, that makes me extra concerned about
code quality in general.  If I wasn't even really trying to find a vulnerability
here and I saw it, that's kind of scary to me.

**Mike Schmidt**: Well, I guess the call to action for folks here is if you're
running an older version affected by this vulnerability, you should be
upgrading.  And any other takeaways you think here, Matt?

**Matt Morehouse**: I keep saying this, but I think there needs to be more
investment in security for LN in general.  So, this vulnerability was introduced
seven years ago and I think back then, LN was kind of in its infancy.  And I
think it's totally understandable that people were trying to just get something
shipped that worked.  But I think this sort of mindset has carried over even
till today.  And I'd really like to see more security development or
security-focused development, because things like this could totally destroy the
reputation of the LN.  I mean, if you think about it, this vulnerability
affected all LND nodes.  LND is 90%-plus of public routing nodes on the LN
today.  And if an attacker had exploited this, the whole network could have been
brought to its knees basically, and no one would have been able to route
payments and people's funds would have been at risk, people could have had money
stolen from them because their nodes weren't online to punish revoke commitment
transactions.  And you know, what does this do to a user who's trying LN for the
first time, and then all of a sudden, they can't make any payments or they lost
funds somehow, or whatever?  They're never going to want to come back to LN
again.

This is my major concern, is that eventually something like this is going to
happen and what's the impact going to be on Lightning, what's the impact going
to be on Bitcoin adoption as a whole?  I'd really like to see all the
implementations investing in more security type work and more careful
engineering of how they develop these new features and things like that.  It's
definitely slower development to do, but I think this is the right way to go
long term.  And if your company is building their entire business model around
Lightning, some large-scale attack like this could really, really hurt your
business.  And so, you should be considering getting ahead of this and trying to
prevent major security catastrophes like this from happening.

**Mike Schmidt**: We've had you on before, Matt, as well as other disclosure
individuals, who have gone through what it would take to execute a particular
exploit.  And based on what you've said here, this one could have a high impact,
but also fairly easy to execute, right?  You can imagine just a little script
that could do something like this across the network.  So, yeah, I share your
concerns and I guess in second, that encouragement of bolstering Lightning
implementation security.  Murch, any thoughts?

**Mark Erhardt**: Yeah, maybe a little earlier would have fit better, but I was
trying to understand the vulnerability a little better.  So, the messages that
were being repeated were the gossip messages, and you could just basically
duplicate the same messages, or were you asking for updates more often than you
needed?  Could you explain in a little more detail how the attack worked,
assuming that it's safe to explain in detail, because it's been fixed for a year
now?

**Matt Morehouse**: Yeah so this gossip timestamp filter message, it sounds like
it's just a filter like, "Only send me this gossip that you get in the future".
There's actually a second purpose to it where you can, if you set a timestamp
sometime in the past, then you're asking the node to load all its gossip from
its database that's newer than that timestamp and send it to you, and that's
where the vulnerability here is, is you request a whole bunch of gossip all at
once.  And if the node just blindly responds to that and sends all that gossip
to you, now they're using a ton of memory and a ton of bandwidth to do that.
So, this could be easily exploited for LND by just sending a whole bunch of
these gossip timestamp filters and LND would load all the gossip every single
time and run out of memory.

**Mark Erhardt**: I see.  So, the malicious attacker would simply ask, "Send me
all the gossip", and it could ask for the same gossip multiple times, there's no
deduplication or anything; like, there could be ten of these queued from the
same peer?

**Matt Morehouse**: Yeah, absolutely.  So, the spec actually says that a new
gossip timestamp filter that comes in should replace any previous ones, but LND,
to this day, has not implemented that.  And, well, they used to handle all of
them at the same time, and now they will handle the first five of them and then
they will start queuing them after that.  But even if LND did do this, like the
spec suggests, it still doesn't fix the vulnerability because you can have many
different peers all requesting gossip.  And they don't replace each other's
filters, they just replace their own.  So, that also ties into your first
attempt at the mitigation was at this per-peer level, but you could bypass it by
just pretending to be many different peers.

**Mark Erhardt**: So, it sounds like even if you do queue it, it would be still
a bandwidth-wasting attack that exists here?

**Matt Morehouse**: Yes, and so actually it's funny you bring that up, because
that's something LND is dealing with right now, kind of the aftereffects of
fixing it this way.  So, they recently implemented some rate limits that were
maybe a little overly conservative.  And then just by the natural traffic, where
people were requesting this sort of historical gossip data, they started hitting
those rate limits and then peers were disconnecting, because they thought the
connection was idle, and they were running into issues this way.  And if they
had fixed this originally by instead of just limiting how many gossip timestamp
filters they handle at once, if instead they had fixed this by loading less
gossip into memory at a time and just sending it every now and then and kind of
trickling the gossip that way, I think they probably would have avoided the
issues they're seeing now.  It's hard to know for sure but I think that's the
main source of their pain right now that they're dealing with, is they're
spending way too much outlying bandwidth on gossip as a result of the gossip
timestamp filter handling.

**Mike Schmidt**: Matt, one of the things that comes to my mind is, okay, this
is one implementation that is handling this poorly and in the spec maybe doesn't
even address this type of concern.  So, did you try the other implementations?

**Matt Morehouse**: I've looked at the other implementations and I don't think
any of them have this vulnerability.  They're all more careful about how they
handle gossip timestamp filter.  They do this more of a trickle of gossip
instead of just sending it all at once, and none of them just load it all into
memory.  They always load a few messages at a time and then when they have
outgoing bandwidth available, they'll send those messages to the peer, which I
think is the intended way to implement this.  I don't think normally you would
respond to the gossip.  The idea behind gossip is not that you send all the
gossip at once, it's that over time you converge on a full understanding of the
network just by collecting gossip here and there, and so on.  I think, yeah, it
only seems to be affecting LND because of the way that they handle this message.

**Mike Schmidt**: Got it.  Well, Matt, thank you for joining us.  We appreciate
your time in explaining this item for us.

**Matt Morehouse**: Absolutely, thanks for having me, guys.

_Chain code withholding for multisig scripts_

**Mike Schmidt**: Next item from the news section titled, "Chain code
withholding for multisig scripts".  Jesse, you and Jurvis have been working on
research to improve privacy and security of collaborative custody.  You can take
this any way you want, but I thought maybe one way to start would be you can
explain what are the existing issues with privacy and security in today's
setups?

**Jesse Posner**: Yeah, absolutely.  So, I think one thing that is really scary
for anybody who is a self-custody user is the idea of your balance and your home
address, that data being leaked, because that could make you a target at your
home.  And when we look at how the collaborative custodians operate right now,
in most instances, they have that data in their databases.  So, they know
people's billing addresses, they might know their shipping addresses, they might
know information about their emergency contacts, and they also know their
customer balances.  And in some cases, this is more deliberate because they want
to know this information for analytics or customer support, so they'll have the
entire descriptor that they just store outright.  But let's say a collaborative
custodian doesn't want to know its customer's balances.  There's not a
straightforward way to not have that information by virtue of the fact that they
hold one of the keys in a multisig.

So, when we look at how multisig works outside of taproot, whenever you spend a
multisig UTXO, you reveal all the public keys that are involved in the multisig,
even the ones that aren't participating.  So, a collaborative custodian, if they
wanted to find their customer transactions, they could use their xpub to derive
child keys and then scan the blockchain and look for any of their child public
keys.  If they show up in the blockchain, they would know that's a customer
transaction, even if they weren't involved in signing.  So, that's kind of the
core issue.  And then, there's an additional issue, which is what if we wanted
to keep transaction data private even when the collaborative custodian is
signing, which is an even higher bar for privacy?  So, those were the two main
motivations behind this idea.  And then in the course of it, we realized there's
some cool security benefits in addition to the privacy benefits as well.

**Mike Schmidt**: Just so I'm clear, the privacy part makes sense.  We wrote
'security' as well, but that seems like it's a physical security thing more than
any sort of cryptographical or otherwise security, right?

**Jesse Posner**: Actually, there is sort of a cryptography security component
as well.  And so, with encryption, we have this idea of forward and future
secrecy.  Like, this is something, for example, that Signal provides, where if
one of the secrets is leaked in a Signal chat, it only decrypts a single
message.  It can't decrypt any of the past messages and it can't decrypt any of
the future messages.  And so, we end up getting a similar attribute with chain
code delegation, where if a collaborative custodian's private key is leaked, if
they don't have a chain code, that private key is actually not usable to spend
any UTXOs, because not only do you need the private key, you need to know the
public keys you need to sign for, and you need to know how to tweak the private
key to sign for those child public keys.  So, let's say a custodian learns a
BIP32 tweak or ten BIP32 tweaks, and so their private key and some set of tweaks
is leaked simultaneously.  Then, the only UTXOs that could be signed for with
that data is the UTXOs that are tied to those tweaks.  And any UTXOs that were
created before or after would not be spendable.  So, we noticed this as a cool
benefit of this technique, even though it wasn't part of the original
motivation.

**Mike Schmidt**: I think it might be helpful for people if we remind everybody
what the chain code is and not the office in New York.

**Jesse Posner**: Yeah, absolutely.  So, you have this thing called an xpub,
which is really useful, because with a single static data structure, you can
derive many, many public keys.  And of course, in Bitcoin, we're always trying
to avoid address reuse.  And so, this makes it really easy for a wallet to
generate many, many addresses or many, many keys with a single piece of public
data or private data.  There's an xpriv and xpub, one for the private keys, one
for the public keys.  So, what the xpub consists of is you have a standard
public key and then you have this additional 32 bytes of random data that we
call the chain code.  And basically, if you concatenate those two things, you
have an xpub.  And the public key is your kind of root of the system.  And then
the chain code gives you a method to tweak that public key and derive child keys
with it.  And so, the problem is if a collaborative custodian has an xpub, they
can derive the whole key tree and they can see all these different child keys.
But if they only have half of the xpub, they only have the public key part and
not the chain code part, they can sign, but they can't derive child public key,
and so they wouldn't be able to identify them on the blockchain.  And if we
combine that with blind signing, they wouldn't even be able to identify
signatures that they were involved with as well.

**Mike Schmidt**: Maybe a quick sidebar, I know we're going to talk about
quantum in a second, but one of the concerns with quantum is that you've shared
your xpub with services or providers that may now have the public keys in their
database or wherever, and if they are malicious or get hacked, that those public
keys that you thought were not publicly available, are.  Does this scheme also
help with that?

**Jesse Posner**: Yeah, I mean, it makes it so that it's less likely those
public keys are going to leak, because they're not sitting in a third-party
database.  And so, yeah, I mean, even if you're not engaging in address reuse,
even if you're using a hashed key-based address scheme, if your xpub leaks or
any of your public keys leak, then that puts those UTXOs at risk for a quantum
attack.  So, the less exposure of that data, the less likely that it will leak.
And so, one way we can do this is with taproot.  If we want the kind of weaker
privacy property, which is basically if I don't use the collaborative custodian
for signing, because a lot of the shape of the systems oftentimes is that maybe
you have, let's say, a 2-of-3 where a third key is held with a collaborative
custodian, and that's only used for emergencies or for recovery purposes.  But
most of the time, you're just using your own keys.  And so, a nice property we
would have is in the default case where I'm not using the collaborative
custodians key, I sign with my own keys and they won't be able to recognize
those transactions on the blockchain.  And only in the rare case would I have to
use the collaborative custodians key and then they would only learn about that
transaction.  Although in practice, if you're using it for recovery, it's
probably going to be a sweep transaction and they're probably going to learn
your whole UTXO set in the process, wouldn't necessarily be persistent in their
database.

But in general, it'd be nice to have this property where I can sign in a way
that's more private, if available, and then only in emergencies would I sign in
a way that's less private.  And we could do that with this chain code delegation
technique, or you can do that with taproot.  Because with taproot, when you use
a given spending path, it doesn't reveal all the different spending paths, all
the different scripts.  It only reveals the one that you used.  So, that's
another way of getting this property.  However, if in addition we want to have
it so that even the custodian doesn't learn the transactions that they are
involved with, then taproot alone is not sufficient; we would still need to use
this technique.  And so, this would have to be layered on with chain-code
delegation, so they don't see their own public keys, and a blind schnorr
signature, so they can't actually recognize the nonce commitment or the
signature on chain or the message that's being signed.

Then, there's an additional technique, called predicate blind signatures, where
if a custodian needs to enforce a policy, maybe like a time delay or a screening
for like OFAC'd addresses or something like that, you could attach a
zero-knowledge proof (ZKP) that asserts that the policy predicates have passed,
so they can verify their policies.  They don't learn the transaction data, they
don't learn the balances.  And so, even with taproot, if you want that kind of
full privacy case, this technique is still quite useful.

**Mark Erhardt**: Yeah, that's what I was going to throw in.  With taproot,
you'd still have to decouple or split up the descriptor.  This is pretty cool.
So, yes, we never want address reuse.  Address reuse has only downsides
essentially, except for a tiny little bit of convenience in some cases.
Especially in the context of quantum, if we're going to talk about that soon,
address reuse actually makes your coins vulnerable for long-range attacks,
because if your public key is on the chain, which is the case only after
spending for many of the existing output types, for some it's also the case for
all as soon as you're being paid; but with address reuse, if you reuse a
hash-based address, your public key is on the chain and a hypothetical quantum
attacker would be able to attack your public key and decrypt the private key
from that quantum decrypt.

So, I really like the idea of splitting up the chain code from the public key,
making the xpub two separate things.  The downside, of course, is many of the
services that you show usually show you the balance that you have onchain.  So,
it would also require additional work from the service provider that they find
ways in which you can retrieve your balances from the service without revealing
to the service what your balances are.  So, that might be possible with some
client-side block filtering but it would require more bandwidth, more
computation on the side of the client, and it also would require that the backup
of the output descriptor that is being used happens client side, or maybe an
encrypted backup is left with the service provider.  So, as so often, the
trade-off for more security and more privacy is less convenient, a more
complicated scheme, and a little more overhead for the service provider as well.
I think it's a great idea, but as usual, there's trade-offs.

**Jesse Posner**: Yeah, those are absolutely some great caveats to point out and
are absolutely valid.

**Mike Schmidt**: Jesse, you mentioned in your write-up, well, we talked about
the potential spending paths in tapscript, and you also mentioned in your
write-up the use of MPC, or you also mentioned FROST as a potential solution to
the problem.  Can you tell us why those aren't great ideas, or are they?

**Jesse Posner**: They are, yeah.  Nick Farrell has a great post about how FROST
can similarly kind of solve this privacy problem for the collaborative
custodians.  And it's also a similar technique, where the chain code is not
known by the collaborative custodian.  In an MPC world, so in a non-MPC
multisig, each signer has their own xpub, has their own chain code for their set
of keys.  But in a FROST world, there's a single chain code because in a FROST
world, there's only one public key.  There's multiple signers, but just a single
public key, and the private key is split between them all.  So, that also means
there's only one chain code.  So, it kind of more naturally lends itself to the
idea, well, maybe not all the signers need to know the chain code.  And as part
of the FROST protocol, and also I think, yeah, the same technique is used in
MuSig, due to the linearity of the schnorr signature, the BIP32 tweak can be
added at the end during the aggregation phase.  And so, the signers themselves,
the challenge hashes they use have to have the full public key for the child key
that they're signing for.  But when they use their private key or their share of
a private key, they don't have to sign with the BIP32 tweak itself, they can
just sign with the root private key.  And then, somebody else can add the tweak
into the signature due to the linearity of schnorr at the end of the process.

So, that is why with FROST, or with MuSig, it does this nicely where you can
have some signer that doesn't know the chain code.  They're given a challenge
hash to sign or they're told what the public key is when they sign, and then
their tweak is added after the fact.  And if they weren't involved in the
signature, because they don't have the chain code, they wouldn't be able to
recognize it on chain.

**Mark Erhardt**: May I put you on the spot?  I was just wondering.  So, one of
the value-adds of having a distributed signing setup is that the other parties
could be configured to only sign blindly or for small amounts.  If the
participants no longer learn what amounts are flowing because they're blinded,
you are essentially making a request from your co-signer that they sign via your
device, and it may be the same device that also controls the original key.  Now,
you're just making a request to a service, they blindly sign whatever you send
them.  Aren't you reducing your security from 2-of-3 to where one of them is
conditional and to 1-of-3?

**Jesse Posner**: Yeah, I mean I don't know if it's a full reduction to 1-of-3
because they might be able to authenticate who you are.  I mean, it's definitely
a weakening, there's no doubt about that, and there's a substantial security
issue if they'll just sign anything that's given to them.  And so, there's two
different ways to deal with that.  One is that when you do ask the signer to
sign, they don't do it blindly.  You give them the transaction, they can verify
the details, and if they're not involved, they wouldn't be able to recognize
these transactions onchain.  But when they are involved, then they do learn the
data.  And so, that's one approach, or the other approach is this ZKP approach,
where whatever the signer needs to know is asserted with a ZKP, and that way
they can parse their policies.

Now, the thing about ZKPs is generating them with a mobile client is not
necessarily going to be practical, could take a couple of minutes and drain a
bunch of battery life, and all of that.  They're getting more efficient over
time, and so that might at some point become, at least with the kind of general
purpose ZK proving systems, like a SNARK or a STARK, if there are specific
policies where you don't need a general-purpose ZK, it could potentially be made
much more efficient and be generated on a client.  But the kind of easy mode is
to use a general-purpose system, where you can assert any arbitrary statement
about the transaction whatsoever.  One thing that really also makes it difficult
is you're asserting a statement about the preimage to a hash.  And so, usually
you'd need the more heavy machinery of like a SNARK in order to make statements
about preimages as they relate to hashes.  So, it works great if you have a
desktop client and a more powerful CPU.  If you want to do this on a mobile
phone, then you could run into performance issues.

**Mark Erhardt**: Right.  That's some good thoughts right there.  So, it sounds
like something that would be great.  How do we incentivize service providers to
actually adopt this sort of scheme, because if we don't demand it, I am not sure
it's on top of their to-do list?

**Jesse Posner**: Yeah.  I mean, I think customers asking for it.  I think
hopefully we're going to see a collaborative custodian introduce this, because
it could be a good competitive advantage to say, "Hey, why don't you use our
service instead of the other person's service, because you're going to be a lot
safer?"  And I think wrench attacks are some of the scariest things that we have
to deal with as bitcoiners.  So, from a customer perspective, I'm going to want
to use a service that takes that attack seriously and doesn't put myself and my
family at risk to use the service.  And so, if we can even just get one company
to come out and use this technique, that's really going to encourage everybody
else to get on board, because I think a lot of customers are going to value this
feature quite highly.

**Mark Erhardt**: Yeah, I think so too.  Sorry, Mike, go ahead.

**Mike Schmidt**: Jesse, we should give you an opportunity, if you want to, to
talk about what you're working on and if it's related to this at all.

**Jesse Posner**: Yeah, thank you.  Yeah, me and my co-founder, Erik Cason, we
started a company a few months ago called Vora, where we're focused on a lot of
the problems we've seen with self-custody, including related to wrench attacks
or government seizure or key loss, which are basically the three main risks that
you think about as a self-custody user.  And so, we are building an integrated
hardware wallet, full node and home security system all in a single package, and
we've got some cool cryptography and recovery techniques and hardware
innovations.  But one of the main things we're focused on is, we are going to
deliver this full-stack chain-code delegation, blind schnorr signatures, and
predicate blind signing with the ZKPs.  And because our integrated node and
hardware wallet is a desktop-class server with a high-end CPU, we can generate
the ZKPs, we aren't dealing with mobile clients.  And because there's a full
node, because this is the other place where data can leak, even if you do all of
this stuff, if you're querying your blockchain data from a third party and
you're not running your own full node, that's another place where your balance
information and your transaction information can leak.

So, to really get the full safety as a self-custody user, you need this stack of
you need your own node, and if you're dealing with a collaborative custodian,
you need the chain-code delegation, blind signing, and all of that stuff
together.  And so, we're working hard to provide that and to ship something to
customers so that they can feel safe even when they're securing high-value
amounts of bitcoin.

**Mike Schmidt**: Very cool, Jesse.  Anything else you want to say on this item,
either Murch or Jesse, before we move to the next Jesse item?  Okay.

**Jesse Posner**: Yeah, I think that covers it.

_Research indicates common Bitcoin primitives are compatible with
quantum-resistant signature algorithms_

**Mike Schmidt**: Great.  Third news item this week, "Research indicates common
Bitcoin primitives are compatible with quantum-resistant signature algorithms".
Jesse, we have you again for this news item.  There's been a lot of chatter
recently about quantum and Bitcoin.  Some of the chatter includes which
post-quantum signature scheme Bitcoin might move to if quantum computers
appeared.  With some of these hash-based schemes, it seems like we might lose a
lot of the niceties that we might be used to in wallets, like HD wallets, MuSig,
FROST, etc.  But you've dug into some of the research and at least for some of
the lattice-based post-quantum schemes, maybe we can keep some of those goodies.

**Jesse Posner**: Yeah, exactly.  So, I was recently at the Bitcoin Quantum
Summit at Presidio Bitcoin and encourage folks to check out the videos.  There's
a lot of great talks.  But it really got me thinking about post-quantum
cryptography.  And one of the things that I heard a lot of people lamenting
about it is, "Hey, if we have to go to this post-quantum world, we're going to
have to give up some of our favorite techniques in Bitcoin.  We're going to have
to give up our BIP32 key tweaks and our HD wallets, we're going to have to give
up silent payments, we're going to have to let go of adapter signatures, we're
going to have to let go of MuSig, FROST.  And all of these techniques kind of
use the same sort of tricks, which is with ECC public keys, we can tweak public
keys and that ends up having a relationship to the corresponding private key,
because there's a mathematical geometric structure that is intact, even when
you're modifying public keys, that that translates down to the private key
level.  And so, this is this beautiful, powerful technique that we're able to
use for all these different tools that have become fundamental to Bitcoin.  So,
we do not want to have to let these go and give them up.

So, I did a little bit of digging.  I'm not an expert in post-quantum
cryptography.  I'd like to become one at some point, but I'm just starting to
establish, to zoom out and just kind of think about in principle or in theory,
is there a way that we're going to be able to bring these techniques over into a
post-quantum world?  And as you mentioned, Mike, there's a couple of different
post-quantum proposals on the table.  So, there's BIP360, which is proposing a
post-quantum address scheme.  And in the BIP, it identifies two of what they
believe are the most promising post-quantum signature types.  And one of them is
a hash-based technique called SPHINCS.  And then, the other is this MLDSA that
uses lattices for its post-quantum cryptography.  And with the hash-based
technique, it's going to be very difficult, if not impossible, to have similar
types of features with those signature types, because hashes destroy the
mathematical structure of what they're hashing.  And so, if you modify a hash,
it's not really going to have any relationship back to the preimage of the hash.

However, lattices do have a mathematical structure that is preserved.  And with
lattice cryptography, we have these random points in this high-dimensional
field, and then you're trying to find these very convoluted vector paths to the
point.  So, the point is kind of like the public key, and the vector path is
kind of like the private key.  And so, if you tweak the public key, you do get a
change to the underlying path that you get to the new key in a proportional way.
And so, it felt like, just looking at it from a very high level, that we have
enough structure here that we should be able to have some analogous techniques.
And so, I started doing some digging to see, are there any papers out there that
have explored this?  And it turns out it's a very hot area of research for
post-quantum cryptographers, and there's been a number of papers.  There's a
paper that specifically introduces an HD wallet, BIP32-style scheme built on
lattices, and has stealth addresses.  So, it has silent-payment-style public
identifiers where a sender can derive an address that is only known to them and
the receiver.  And then, there's some other papers that have MuSig-style key
aggregation.  And then, there's even a paper that does FROST-style threshold
signing.

We're still at the early stages of this research, and if the mathematicians are
already discovering these techniques, I think it's very promising that we're
going to have more discoveries here that will have better efficiencies, improved
properties, and that the cryptographers of Bitcoin should not be discouraged by
post-quantum, that there's still going to be a lot of room for creativity and
bringing in all the kinds of techniques that we know and love.  So, that was the
main purpose of this post, is to start a conversation around that.

**Mark Erhardt**: All right, I want to throw a little cold water.  Yes, sounds
good.  So, BIP360 was recently overhauled.  The BIP360 proposal now is a little
condensed to proposing a new output type that is very similar to taproot
outputs, but does not allow a keypath spend.  So, by having only a scriptpath
spend component that is hash-based, it would be immune to long-range attacks,
unless of course they are reused.  Don't reuse addresses, please.  They do
discuss a little bit two different types of post-quantum safe signature schemes,
however they no longer propose one.  They are working currently on a second BIP
that would make a recommendation in this regard.  Now, I am not at all a
cryptographer but my understanding is there are two different schemes, because
they want to have a fallback in case one of them gets broken.

One of them is based on lattices.  So, that would be potentially, down the road,
compatible with all the good things that Jesse has described to us.  The big
issue there is lattice cryptography is based on new cryptographic assumptions
that are fairly young.  There have been some breakthroughs in how to break them.
This is generally still pretty nascent cryptography.  There are now some
standards approved by NIST, but in the first round of those standard
submissions, some of these proposals were broken on the first weekend.  So, even
if they are currently approved, there might be some of them that still get
broken.  The nice advantage of the lattice-based cryptography, as far as I
understand, is that they can be way more performant and they can use way smaller
signature and public-key sizes.  So, I don't have the numbers on top of my head,
but I think it was Falcon that is interesting at this point.  And it's barely
one-digit multiple in size from current output types; whereas the hash-based
signatures are more like factor-100 bigger, or maybe let's say 50.

But the other fallback is based on hashes.  So, I think that was SPHINCS.  You
correct me, Jesse, you know all this better.  But these would be way, way bigger
and they would be more expensive to calculate.  However, they make fewer
cryptographic assumptions, up to none, compared to what we have already.  So,
the downside there of course would be that all of that would not be compatible
with the goodies that Jesse just described.  So, I would imagine that it might
be difficult to have a scheme that's based on not reusing addresses, where I
guess you could have a construction where you have a merkle tree with script
leaves, where one has the Falcon signature that is performant that might be
based on MuSig or based on FROST or other goodies with derived addresses, no
address reuse.  But then, the second leaf would always be the same two keys and
both of them would be ginormous and both people have to sign with like a 4-kB
signature in order to make that transaction work.  So, yes, but there is some
caveats there.

Again, I was also at the Quantum Summit a couple weeks ago, there is some debate
about how quickly this is impending upon us.  I know nothing about quantum
computers, but from what the experts said, it sounded more like we'll find out
in the next five years to me.  We'll know more in the next five years how
quickly it's coming, not it's going to be here in five years, but what do I
know?  And about the whole cryptography thing, since it is such a hot topic
right now for cryptographers, for people that have business in cryptocurrencies,
and so forth, I think the speed at which stuff is being discovered is only
accelerating.  So, hopefully in the next five years, as we are watching this,
unless other people are convinced to do otherwise and do more than I will be
doing in the next five years, they will hopefully have better schemes by then,
hopefully schemes that are compatible with these good derivation paths and key
aggregation schemes and threshold signature schemes, and we'll have a better
idea of what we want to do.

Regardless of that, I would like to invite all of you to actually read BIP360
and other proposals that are being brought up, because this is a conversation
that is happening right now.  And even if we're not going to have to react
urgently to a cryptographically-relevant quantum computer in the next five
years, one thing that we really need to debate is, if we had to, what would be
our proposal that we have in the drawer that we can get going in the next six
months, and what needs to happen with the other coins that don't move, because
there's millions of coins, between 4 and 8 million coins probably lost, so these
will not move.  A lot of them are on P2PK output types, and a bunch of them are
on reused addresses.  So, for these coins that do not move, what is the
appropriate handling of that?  Should they be frozen and based on something like
the Life Raft proposal from the Quantum Summit recoverable, that might only work
for a subset of keys because some of them might not have any scriptpath spending
or might not be derived from a BIP32 style address?  Or should they just be up
for grabs for anyone, because quantum computers are great for humanity and the
Bitcoin Network wants to subsidize that, even if there is no benefit to the
Bitcoin community to invite people to misappropriate funds otherwise?

That's the debate that we need to be having in the next couple of years.  It's
been ongoing on Delving, on the mailing list.  You might have seen some podcasts
or blogposts that also dip their toes into that, but that might be a topic you
want to also look at.

**Mike Schmidt**: Jesse, from what you've said, I think I know the answer, but
you mentioned all this innovation and schemes that are being built on lattices.
I suppose that the amount of innovation on the hash-based schemes is zero
because, like you said, the whole point of the hash is that it is obfuscating
the underlying information.  And so, there's no research being done there and in
theory, nothing can be done on that front, or…?

**Jesse Posner**: Yeah, I think I think this SPHINCS scheme is kind of old, or
at least based on some older techniques, and is a little bit more settled.  But
there may be some MPC tricks that we can do with hashes, and there was a little
bit of discussion at the summit about that.  But you could potentially have
multiple parties contributing to building a hash where none of them knows the
full preimage, and they're using some kind of MPC to collaboratively construct
these things.  So, I think that's basically the only opportunity we'd have to be
able to kind of extend the techniques we apply to the SPHINCS-style signature.
I don't think we'd get the full array of everything we want to be able to do,
but we would be able to get some kind of multisig, multiparty schemes that
probably could be done with MPC.

**Mike Schmidt**: Anything else to say on this topic, Jesse?

**Jesse Posner**: Yeah, I mean I just think it's a little bit risky as a
mathematician or a cryptographer to put too much time into this, because like
Murch said, we don't even know if it's going to be viable.  One thing that is
unfortunate or just a feature of these systems is that we rely on hard
cryptographic problems and we don't have proofs that the problems are hard.  All
we have is time that nobody's come up with an efficient solution within some
segment of time.  And if it hasn't been done in 10 years or 20 years, we build
confidence that it can't be done.  So, there's no efficient solution that's been
found to the lattice hard problems, but not that much time has been built in
yet.  And one day we could wake up and somebody's found an efficient solution,
not only with a quantum computer, but even with a classical computer, there
could be efficient solutions lurking out there.

So, you could spend tons and tons of time figuring out BIP32 and FROST for
lattices, and then all that work disappears.  But it's also a great opportunity
to do something new and innovative and it very well might hold up, and it very
well might become a critical part of the future of Bitcoin.  And if you're a
cryptographer that's just getting maybe a little bit bored of elliptic curves
and schnorr signatures and ECDSA, it's a whole new world of mathematics that
lattices opens up with a lot of fun puzzles and things to think about.  And I
just think for me, the main takeaway is let's not get discouraged about the
post-quantum future.  Let's stay excited, let's stay inspired, let's stay
creative about what might be possible, even if we have to move to that world.
Because there's going to continue to be innovation and new ideas, and we're
going to continue to be able to build great things with Bitcoin, and we
shouldn't think of that as just sort of the end of the road.  And so, that's my
main takeaway.

**Mike Schmidt**: Nice way to wrap up, Jesse.  Thank you for your time on both
of these news items.  We appreciate you joining us.

**Jesse Posner**: Yeah, this this was fun.  Thanks for having me.

**Mike Schmidt**: Cheers.

**Jesse Posner**: See you.

**Mike Schmidt**: Moving on to the monthly segment we have on Q&A from the Stack
Exchange.  We have just three this month.  Sorry, Murch.

**Mark Erhardt**: First, let me jump in right there.  People, you've got to feed
the beast.  All of you are just talking to AIs now in order to learn about
Bitcoin stuff.  Sure, there is the mailing list and maybe, for example, the
transcripts from this podcast that might get consumed and used for training
eventually.  But I'm low-level sure that also all of Stack Exchange was consumed
to train all of your LLMs.  So, for all the new topics, if you stop asking
questions to Stack Exchange, our LLMs will stop learning.  So, feed the beast!

_How does Bitcoin Core handle reorgs larger than 10 blocks?_

**Mike Schmidt**: Well, it's funny you mentioned that because this first Stack
Exchange question was, "How does Bitcoin Core handle reorgs larger than 10
blocks?  And TheCharlatan answered and pointed to a section of the Bitcoin Core
code that handles reorganizations and has this maximum of 10 blocks' worth of
transactions that are re-added to the mempool.  But I wanted to dig deeper, and
I did ask the AIs this one, and they had no idea what the 10-block consideration
would be in Bitcoin Core, when I was even giving it more and more hints about
re-adding transactions to the mempool.  So, I should actually follow up to that
question or ask a separate question but maybe, Murch, you know the answer.
Let's say that there's a 15-block reorg, so 10 blocks' worth of transactions are
going to be re-added.

**Mark Erhardt**: I think I just noticed this this morning, so it's not fixed
yet, but I think there's a misunderstanding here.  I believe that transactions
are only added back if the reorg is not more than 10 blocks.  If the reorg is
more than 10 blocks, no transactions are added back to the mempool, is my
understanding.  I will double-check this later, I might be wrong on this one.
So, the concern I think probably is, you can fit about 6,000 transactions into a
block I think, or maybe I'm off.  Usually there are like 3,500 transactions per
block or so.  And so, if you go back 10 blocks, you'll add back something like
35,000 transactions to the mempool.  And I think the concern is that you would
just basically flush out all the unconfirmed transactions that are still
waiting.  So, when you're reorging, you are reorging to a chain that has more
weight, right?

If you're reorging 10 blocks, you're reorging to a chain that probably has 11
blocks.  If the other chain also includes transactions, most likely almost all
of these transactions will also be confirmed in the other chain tip.  Now, the
easiest way to verify that would be by putting them in the mempool, by using
this already verified script and so on, but we would lose all of our unconfirmed
transactions, they would get flushed out.  I think with 35,000 transactions,
you'd probably eliminate a third or half of the mempool on default settings that
would just get dropped on the floor.

So, I think the trade-off here is if you are reorging more, instead of putting
it back in the mempool, you process those blocks in full and get all the data
for the blocks from peers, and that way maintain the content of your mempool.
But also again, I'm mostly speculating here.  I know speculation shouldn't be
spoken about.

**Mike Schmidt**: You should ask on the Stack Exchange, Murch, or ask and
answer.

**Mark Erhardt**: Well, first I'd have to find out what the actual answer is.
But that seems to be the most likely concern.  You'd have all this data churn in
your memory and then most of it would be confirmed immediately again, and then
you'd forget about all these other unconfirmed transactions that are still
waiting.

_Advantages of a signing device over an encrypted drive?_

**Mike Schmidt**: Yeah, that makes sense.  I guess, stay tuned, listeners, for
next month's Stack Exchange where we might update the answer here.  Second
question from the Stack Exchange, "Advantages of a signing device over an
encrypted drive?"  This person was wondering, "Hey, I have an encrypted drive
that achieves the same thing as these fancy Bitcoin hardware signing devices or
hardware wallets".  And RedGrittyBrick points out that one main difference
between using an encrypted drive versus a hardware wallet is that when you
unencrypt your drive, everything, all of the data is sitting there unencrypted.
And when you have a hardware signing device, they're specifically designed to
not unencrypt and have available that data for someone to steal from you.  So,
this sort of key extraction or private data extraction attack is what hardware
devices are designed to help mitigate.

**Mark Erhardt**: Right.  By a hardware security module, like an HSM, or just
the signing devices that people use at home, they are deliberately built exactly
to resist this sort of vulnerability by having a very minor or small interface
that is well controlled.  You can only get certain actions from the hardware
signer like, "Sign this message.  Yes, it is actually me, I authenticated this
request", or whatever, and then you get a signature just for that transaction
you provided.  You can usually not exfiltrate the key material at all.  But if
you're just looking at an encrypted hard drive, the hard drive, when it's
mounted and decrypted so you can use it, is readable by the operating system.
So, when there's malware on the operating system, it can read that hard drive.

_Spending a taproot output through the keypath and scriptpath?_

**Mike Schmidt**: Last question from the Stack Exchange, "Spending a taproot
output through the keypath and scriptpath?"  And I think we talk about this a
lot on the podcast and in the newsletter.  We talk about scriptpath and keypath
spends, but I just thought that this answer was a good refresher for folks
potentially.  So, Antoine Poinsot answered and included a diagram from
learnmeabitcoin.com, which I thought was helpful to visualize the different
pieces of the structure when we say scriptpath, what all does that mean when we
talk about leafs, what does that look like?  And there's a cool visualization
there.  So, I thought we just point people to that to refresh themselves when
we're talking about scriptpath and keypath spins.

**Mark Erhardt**: Also, a shout out to Greg.  His website, learnmeabitcoin is
awesome if you want to understand how actually the output types work or key
derivation, and that sort of topics.  There is even multiple level like, explain
it to a beginner, explain it advanced, explain it to an expert.  Frankly, I look
up stuff there occasionally and it's amazing.

_Libsecp256k1 v0.7.0_

**Mike Schmidt**: Releases and release candidates, libsecp256k1 v0.7.0.  This is
noted that it's primarily a maintenance release.  But along with some internal
fixes in secp, it also includes some changes that affect the public API,
including removing previously deprecated function aliases, and also some small
changes to the data types of existing fields in the API.  So, check out the
release notes for any details.  If you're using secp, you should probably always
be checking those release notes.  Yeah, that's it on secp.

_Bitcoin Core #32521_

Notable code and documentation changes, Bitcoin Core #32521.  This is a PR
titled, "Policy: make pathological transactions packed with legacy sigops
non-standard".  Murch, we've had Antoine on to talk about the consensus cleanup.
This appears to be related to that, but maybe you can sort of explain how this
is something that we should consider doing just before consensus cleanup, or if
there even is or is not consensus cleanup?

**Mark Erhardt**: Right.  So, when we introduced the block weight limit instead
of the block size limit, we created a single metric by which the block was
limited that was stricter than the block size limit, but in a different way in
an area that legacy nodes wouldn't consider part of the block, you were actually
allowed to write more data.  Now you'd think that transactions are only limited
by block weight, and that is true for all of the output types that people
regularly use.  But there's actually a second limit that makes it a
multi-dimensional problem that people usually never run into.  But it is
possible to run into the sigop limit for standard transactions.  Now, the sigops
are sort of a loose translation of how much cryptographical computations need to
be done to verify a transaction.  Like, OP_CHECKSIG is one signature operation
in that sense.  Other operations have a weight to how much they count into
sigops.  So, for example, OP_CHECKMULTISIG counts as 80 sigops in this limit,
because an OP_CHECKMULTISIG could have up to 20 keys and that's expensive to
verify, and legacy outputs are multiplied by 4 generally.  So, OP_CHECKMULTISIG
counts like 20, but if it appears in legacy code, it counts as 80.

So, if there's a limit in blocks for how many sigops you're allowed to have, and
I think that, was it F2Pool ran into this limit a few years ago, when they had
blocks full of stamps.  And, yeah, do you have more details on that one?

**Mike Schmidt**: Oh, no, I didn't see it was stamps, but I was actually
bringing that up while you were talking, because I knew that people may be
familiar with the sigops limit at the terms of blocks because there was invalid
blocks from F2Pool.

**Mark Erhardt**: I think it was a couple of years ago, or so, F2Pool mined two
blocks that were invalid because they exceeded the sigop limit for blocks while
being within the weight limit.  So, just for the people that weren't aware,
there is the second limit that usually never gets hit by the most commonly used
output types, because their sigop budget is something like 40 weight units per
sigop, or whatever, and usually it is always way lower for standard output
types.  The weight dominates so much that it is not a concern.  If you're doing
not stupid stuff but stranger stuff like multisigs and legacy code, you can hit
this limit.

So, back to our original question.  The problem is, if we're going to make
transactions with an excessive amount of sigops invalid, as in they cannot be
mined in blocks because it will make the block invalid and the miner loses
money, miners that haven't upgraded yet and mine blocks might create invalid
blocks if someone spams these invalid transactions on the network and they
appear standard to them and they appear in the blocks that these un-upgraded
miners mine.  So, we wouldn't want miners that are a little slow on the update
to build blocks that bring a bunch of un-upgraded nodes on a chain that will not
persist because it's invalid to the majority of the network; and we don't want
the miners to lose money either.  So, before activating the great consensus
cleanup that invalidates these transactions for good, we would want to make them
non-standard so any miners that are at least running a few versions earlier and
maybe not the upgraded version yet, but have upgraded at some point, they would
not include these in their blocks.  And the nodes would not propagate them,
would not keep them in their mempools.  They would still follow a chain if a
miner mined it, but if miners don't mine it, it would be safer.

So, this is the context that I understand this to come from.  It looks to me
like it got merged before the feature freeze of 30.0.  So, the next version,
Bitcoin Core 30.0 is going to have this limit and makes these pathological
transactions non-standard.  So, nodes would not propagate them, nodes by default
would not include them in their blocks.  This is also one of the things that
miners probably won't want to manually change and pick up transactions for
because, yeah, they are intended to go consensus-invalid eventually, so probably
don't want to collect them.

**Mike Schmidt**: Do you know if a transaction like this has been mined on
mainnet in the mainchain?

**Mark Erhardt**: I believe that Antoine posted a list of all the transactions
that would be in conflict with this limit, and I think it's in the PR, one sec.
No, maybe it was somewhere else, maybe it was in the mailing-list post.  Yeah,
here it is.  Looks like maybe 40 transactions or so.  Yeah, there have been
some, but generally it doesn't look like stuff people usually do a lot.

**Mike Schmidt**: And we want to limit this because there are certain
shenanigans that people can put together that would result in a very slow
validating transaction or block, is that the...?

**Mark Erhardt**: Right.  So, the context for the introduction of this limit is
people could create blocks that are extremely slow to validate.  This would be a
big problem for people that run low computationally-capable devices like
microcomputers, Raspberry Pis and stuff like that.  It would also be a concern
for other miners, where the miner of the block that is this attack block would
gain a lead time on the other miners, or maybe even crash their nodes, make them
incapable of following the best chain, and thus increase their own relative
hashrate to the total network.  So, I think that Antoine has been researching
the worst possible blocks for a couple of years.  His conclusion is that by
limiting the sigops, a transaction is allowed to have these attack blocks
essentially become mitigated to a degree where they are slow, but not
concerningly slow.  So, this is sort of the lowest limit that he felt made it
mostly safe, but is high enough that it will never be hit by any common or
non-pathological transactions.  So, just transactions that are deliberately
created to be slow to validate would even meet this limit.

**Mike Schmidt**: We covered some of that discussion about the great consensus
cleanup soft fork and the adaptation of it that Antoine came out with back in
February, and that was Newsletter #340.  So, if you're curious, some of the
details about the consensus cleanup, but also some of the thinking that went
into this particular discussion that is now being rolled out in policy, check
#340 for that.

_Bitcoin Core #31829_

Next PR, Bitcoin Core #31829, a PR titled, "Improve TxOrphanage denial of
service bounds".  Murch, we spoke with Gloria in Podcast #362, because this PR
happened to be highlighted in the PR Review Club, and she was kind enough to
come on.  And you and her had a great conversation about all things orphanage
and all kinds of tangents we went on with her, which was great.  Do you have a
tl;dr on this one?

**Mark Erhardt**: Sure.  Yeah, I guess I can.  So, the bigger context is that
Gloria has been working on package relay for several years, might be almost five
now.  And the idea is currently, we only propagate transactions separately by
themselves.  But often, transactions may only be attractive to be included in
mempools and blocks as groups, because a child transaction might be paying for
the parent transaction and the parent transaction by itself doesn't seem
attractive at all, and previously may have poorly propagated in the network, but
with the child would have been attractive enough to be included in the next
block.  In the future, it would also be amazing if we were able to propagate
multiple parents with one child, for example, or multiple children together with
one parent that overall make it attractive to include the entire group together.

So, in this context, last release, no two releases ago, I think even, 28,
included something called the opportunistic one-parent-one-child package relay
(1p1c).  So, if you got an announcement of a parent transaction and the parent
transaction was denied entry into the mempool due to a low feerate, and then
someone announced a child transaction to you and the child transaction is
obviously an orphan, and we can't even figure out the feerate of the orphan
without knowing the parent, but the parent was only denied entry to the mempool
due to a low feerate, then we would now consider these two as a package together
and see if parent and child together would be attractive to include in the
mempool.  This relies on transactions being in the orphanage, which is a data
storage where we keep transactions that are missing inputs.  And when we receive
such a child for which we missed the input, we would ask the relayer for the
parent transaction, and then we can do the test whether they're as attractive as
a package.

This was not very robust necessarily in the face of antagonists, because an
antagonist could just broadcast a bunch of different transactions that are
missing inputs and churn the orphanage, and then people would lose these
transactions maybe before they hear about a parent.  So, #31829 introduces a
restructuring of the limits of the orphanage.  Where we previously only allowed
100 transactions, we now allow transactions per peer; and where we used to just
randomly evict one of the orphans whenever we got a new orphan, we now look at
who's been sending us the most data, are they DoSing us?  The node that is
sending us the most stuff that is just sticking around and not getting
processed, those announcements are evicted first, and that should make it more
robust for this use case for opportunistic 1p1c.  And, yeah, I think the overall
limit goes up a little bit.  We'll use now, I think, up to, what was it?  1 MB
or so per peer.  But overall, it just is a rework on how the orphanage works in
order to make it more robust against this orphanage churning attack.

**Mike Schmidt**: Makes a lot of sense.  The orphanage is being used in more use
cases now, so it should be a little bit more robust.  And so, adding these
limits helps protect against attacks on that orphanage.  Those are also more
likely to happen given that the orphanage is being used more now.

_LDK #3801_

LDK #3801 adds to LDK's implementation of the attributable failures bolt
feature.  Previously, LDK would log some information when an HTLC (Hash Time
Locked Contract) failed, for example, information about the failure, the
different positions in the attempted route, as well as how long nodes held the
HTLC.  So, that set of failure information was in line with BOLTs #1044 that
specified and does specify the attribution data LN protocol feature that we've
talked about previously.  But the PR this week adds those HTLC hold times, not
just to the failed payments that we'd covered previously, but also to successful
payments.  And originally the idea of including this data in successful payments
was a separate BOLTs PR, but has since been combined with the original
attribution data BOLT PR.  And I think we've talked about this on the show, but
the hold time information is represented in hundreds of milliseconds.  So, the
two in there would actually be 200 milliseconds.  And we discussed, I think,
with some folks about why there is that sort of rounding and bucketing that goes
on for potentially privacy purposes.

_LDK #3842_

LDK #3842 is a PR titled, "Add Shared Input support in interactive TX
construction".  It's a PR that's part of LDK support for splicing.  One
requirement of splicing is the ability to work with a channel peer to construct
a transaction together.  And part of jointly constructing that transaction is
the back-and-forth negotiation with the other party, which is not included in
this PR.  But what is included in this PR is the ability for LDK to handle the
idea or notion of shared transaction inputs at all.  And so, that's what this PR
does.  It includes a bunch of plumbing work to support that in LDK's data
structures and workflow.

_BIPs #1890_

BIPs #1890 updates the async payjoin BIP, which is BIP77.  Murch, I saw you
commenting and reviewing in that PR to the BIPs repo.  What are we changing here
about async payjoin?

**Mark Erhardt**: Right.  So, async payjoin relies on a bunch of data being
exchanged through basically URLs, and a bunch of unique resource identifier
libraries were treating a + basically as a stand-in for spaces.  This was
pointed out by some presumably people implementing BIP77.  There have so far
only been two full implementations of it, I think.  So, after conferring with
the projects that had already implemented asynchronous payjoin, BIP77, this
structuring of how the parameters and the URIs were separated was changed from a
+ to a - so that this would be in line with the libraries that were treating it
not spec-conform, but very commonly as a blank space.  And, yeah, so this is
basically just a very natural small improvement due to people starting to
implement the BIP and finding out that there might be something that can be done
differently.  And all of the parties that have been implementing it already have
adopted this change.

So, if you're implementing BIP77, check the change log.  There's a small change
there, but it shouldn't be hard to implement.

_BOLTs #1232_

**Mike Schmidt**: Last PR this week, BOLTs #1232, which updates the LN spec to
treat the option channel_type feature as assumed.  So, the channel_type can, for
example, be used to signal support for zero-conf channels, "Hey, we're going to
do an anchor output", or other features.  And so, maybe this quote from t-bast
will help, "This feature has become more and more useful as we've introduced
various channel commitment formats, and has been introduced more than three
years ago.  It should be safe to assume that every implementation sets this TLV
field".  And so, that was from the PR itself.  Basically, this has been around,
basically all the implementations support it.  So, change it from basically
optional to assumed, or I'll interpret that as required, although I assume
there's a reason for it be calling assumed.  So, that is an assumed thing now on
the LN as of BOLTs #1232.

We want to thank our guests, Jesse and Matt, for joining us this week.  Murch, I
thank you for joining as a co-host, and for everyone for listening.  We'll hear
you next week.

**Mark Erhardt**: Hear you next week.

{% include references.md %}
