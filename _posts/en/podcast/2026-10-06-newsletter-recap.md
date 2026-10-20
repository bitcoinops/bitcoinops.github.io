---
title: 'Bitcoin Optech Newsletter #425 Recap Podcast'
permalink: /en/podcast/2026/10/06/
reference: /en/newsletters/2026/10/02/
name: 2026-10-06-recap
slug: 2026-10-06-recap
type: podcast
layout: podcast-episode
lang: en
---
Gustavo Flores Echaiz and Brandon Black are joined by Matt Morehouse to
discuss [Newsletter #425]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-9-8/433722383-44100-2-e6e0f48f23457.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Gustavo Flores Echaiz**: Hi everyone and welcome for another episode of the
Bitcoin Optech podcast.  Today, we're covering Newsletter #425, and I'm
pleased to be joined by Brandon, Rearden Code, and Matt Morehouse.  Brandon,
would you like to introduce yourself; and later on, Matt, please?

**Brandon Black**: Sure.  I'm Brandon Black or Rearden Code, I've been working
in the Bitcoin industry for almost ten years now on various things,
self-custody, whatnot.  Most recently, I started my own Bitcoin node
implementation because I got sniped by the vibe-coding vibe.

**Matt Morehouse**: And I'm Matt Morehouse, and I work on LN security.

**Gustavo Flores Echaiz**: Awesome.  Thank you guys.  Today, I'll be hosting
with Brandon since Murch and Mike couldn't make it.  So, this week we have two
News items and a lot in the Changing consensus section; and later on, two
Releases and multiple Notable code and documentation changes.

_Disclosure of two DoS vulnerabilities in Eclair_

We're going to start with the first News item.  So, "Disclosure of two DoS
vulnerabilities in Eclair".  Matt, you posted on Delving Bitcoin about a
responsible disclosure of two DoS vulnerabilities affecting Eclair v0.13.1.
And both of these vulnerabilities were fixed back in May 2026 in v0.14.0.  Any
users that are still running an older version should upgrade now.  So, Matt,
would you like to give us maybe an intro to what these vulnerabilities were
about?

**Matt Morehouse**: Sure.  Both of the vulnerabilities have similar impact,
where they could basically cause Eclair to use an extreme amount of resources
and eventually crash.  The first vulnerability is related to Eclair's feature
bit parsing.  So, in the Lightning protocol, there's this concept of feature
vectors that are used to advertise the different features that your node
supports.  So, there's different messages you send to peers.  In those
messages are these feature vectors, which are a bit vector where each bit
corresponds to one feature.  So, if you set the bit to 1, it means, "I support
this feature", and if you set it to 0, it means, "I don't support this
feature".  Now, Eclair's problem was that the way they parsed these feature
vectors was extremely inefficient.  So, they would actually iterate the entire
bit vector bit-by-bit six different times, and they would allocate multiple
heap objects for each bit in the vector.  And so, the maximum length feature
vector you can have in the protocol is 64 KB.  And if you sent one of these
maximum length feature vectors, Eclair would allocate over 300 MB of data on
the heap.  Now that's not all at once; it would allocate some data and then
free some data.  But cumulative over the course of processing the message, it
would allocate 300 MB of memory, and it would take up to 300 milliseconds to
process one of these messages.  So, an attacker could simply send a whole
bunch of messages that have these max length feature vectors, and Eclair would
run out of memory within a few minutes and crash.

The fix that Eclair did for this was basically to optimize their feature
vector parsing.  So, instead of iterating the peer's feature vector, what they
do now is they simply check the certain feature bits that Eclair knows about
in the feature vector.  So, Eclair has a list of around 30 features they
support, and so they just check the offsets in the peer's feature vector to
see if the peer supports those too.  And then, they pretty much don't look at
any other part of the feature vector, and they'll just store it as a bit
vector directly instead of allocating data on the heap for each bit.  So,
after the fix, Eclair processes a single message in one to two milliseconds
and the heap churn is much lower; I think it was around 200 KB, or something
like that, and the attack no longer works.

The second vulnerability is similar in that it causes Eclair to allocate a lot
of memory, but the mechanism is different.  So, in the Lightning protocol, in
the gossip part of the protocol, there's a couple of messages where you encode
a list of short channel IDs (SCIDs).  And these are basically to tell another
node, "Hey, I'd like some data or some information about these channels; do
you have any?"  And then, if the node does, then they can respond and send you
some gossip messages to help you update your view of the Lightning graph.  And
in the early spec, there were two different ways to encode these lists of
SCIDs.  The first way is just a simple, plain array, where each SCID gets 8
bytes in the array, and you just line them up next to each other and send them
on the wire.  The second way was using zlib encoding.  So, you could have a
long list of SCIDs that gets compressed into a much shorter payload and then
gets sent on the wire that way.

Now, in 2022, this second encoding, the zlib encoding, was actually removed
from the spec, I believe because at the time LDK was trying to implement this
part of the spec and they didn't want to take a dependency on zlib, because
zlib had had security issues in the past.  And all the implementations agreed
at the time that we don't actually really need the zlib encoding, so let's
just remove it, and the plain array encoding works good enough.  So, within a
month of that change to the spec, Eclair removed support for sending
zlib-encoded data.  But they kept in the ability to receive zlib-encoding
data, because it would take a while for the network to update.  And so, they
still wanted to be able to communicate with the rest of the network with nodes
that hadn't upgraded yet.  And they had planned to have this second phase
happen sometime in the near future and remove the ability to receive
zlib-encoded data as well, but they just never got around to doing that.  And
so, as late as a few months ago, they still allow receiving zlib-encoded data.

What this means for an attacker is that they can send a small payload that
decompresses to a large amount of memory.  The maximum compression ratio for
zlib is about 1,000 to 1.  So, if an attacker creates a pathological payload,
a 64-KB message on the wire could turn into 64 MB in Eclair's memory.  And so,
I did some experiments with this, and sure enough, by sending an all-zero
payload, it decompresses to 64 MB.  And then, to make matters worse, Eclair
would allocate additional heap memory for each 8 bytes of that list.  So, each
8 bytes corresponds to one SCID, and Eclair would allocate 48 bytes total for
each one of those.  So, we end up with a total of, like, 450 MB of memory that
Eclair would allocate.  So, an attacker just sends a few of these zlib bombs,
and Eclair runs out of memory and crashes.

Their fix was to just remove zlib support entirely.  It's been gone from the
spec since 2022.  No one's even sending it anymore, and that fixed that.  But
both of these, again, were fixed in Eclair 0.14.0, so make sure you upgrade.
There's also several newer security releases on top of that.  So, I would
upgrade to the latest one if you haven't yet.

**Brandon Black**: I had two questions for you about this.  One, were you
specifically looking for vulnerabilities when you found these, or was it kind
of happenstance from other work you were doing?

**Matt Morehouse**: Yeah, I was looking specifically.  So, the first
vulnerability, the feature-parsing one, was found by fuzzing.  We have a new
Lightning-specific fuzzer called Smite that basically acts like a malicious
node, and will connect to a target Lightning node and will send random stuff
on the wire to it.  And in this particular case, the scenario that was being
fuzzed was Smite would connect to Eclair, it would complete the
BOLT8-encrypted handshake, and then it would just send random bytes over the
encrypted connection.  And then, it would send a ping and wait for the pong
from Eclair, and if the pong took too long to come back, then it flagged the
input as potentially causing a crash or a hang or just being slow.  And so,
one of these inputs happened to be an init message that had a very large
feature vector in it.  And so, that kind of tipped me off to the issue here.
And then, looking further, figured out the code was very inefficient and tried
exploiting it and came to the crash.

The second one was found by telling an LLM to basically look for the similar
pattern in Eclair.  So, I gave it the text of the first vulnerability and I
said, "Here's a vulnerability where Eclair allocates magnitudes more resources
than it takes an attacker to send the message.  Are there any similar possible
ways an attacker could do this?"  And it came up with a list of potential
things, and then I just worked down the list, and the zlib bomb was the one
that ended up working.

**Brandon Black**: Very cool.  My other question was, what are the
consequences to a node if it gets taken offline by this in the LN?  I know
we've talked about that before on this show, but it's worth reiterating why
these DoSs really matter for Lightning nodes.

**Matt Morehouse**: Yeah, a Lightning node needs to be online in order to
protect its funds.  If the Lightning node is offline and your peer
force-closes, they could force-close with an old commitment that's been
revoked.  And if your node isn't online to see that and punish that, then you
can lose funds that way.  Now, there's watchtowers which can help with that,
but if your node's not online, even if you have a watchtower, you can still
lose HTLC (Hash Time Locked Contract) values.  So, there's ways to steal funds
if you can't handle an HTLC onchain quick enough, then your upstream peer can
time it out and get a refund on it.  So, it's very important for all Lightning
nodes to be online all the time.  These particular vulnerabilities, they would
crash your node once, and then you could restart your node, and hopefully your
node would be able to process onchain events in the small window between
restart and when the attacker could crash you again.  But you'd have to keep
restarting and there's no guarantee.  So, to be safe, you'd rather just not
have your node crash at all.

**Brandon Black**: That's good advice right there.  Yeah, also, I mean I think
Lightning, we've learned over the many years now of Lightning that when
possible, it's best to have some degree of relationship with your channel
partners, because if you have a channel with someone and they find something
like this, they can cause you pain.  If you have a little bit of trust of just
not malice with your channel partners, the LN works quite a bit better.  So,
yeah, awesome stuff.

**Gustavo Flores Echaiz**: Totally.  Thank you so much, Matt.  So, I had a
question.  So, do you know the reason why, in April 2022, BOLT7 removed the
zlib encoding?  Was it because this type of vulnerability was feared, or for
another reason?

**Matt Morehouse**: All I can speculate, well, I can only tell you what the PR
that removes it says.  I wasn't aware of whatever conversations were happening
outside of the PR at the time.  So, it's possible that they knew of this
attack vector already, and that was another reason for removing it from the
spec that was not stated in the PR.  But what the PR basically says is LDK
didn't want to take a zlib dependency, and that the zlib-encoding type wasn't
needed anyways.  And then, everybody commented, "Concept ACK sounds good", and
then it got merged.

**Gustavo Flores Echaiz**: Understood, okay.  So, it wasn't like this was
already known as a potential vulnerability.  Maybe it was understood by some,
but it wasn't disclosed and presented publicly.  Awesome.  So, besides
upgrading to v0.14.0, do you have any other advice for listeners, any action
items they should pick up from this item?

**Matt Morehouse**: I think in general, just stay updated.  There's a flood of
all kinds of vulnerabilities being reported lately with LLMs.  And so, if
you're running a Lightning node, you should be watching releases like a hawk
and upgrading as soon as possible.

**Gustavo Flores Echaiz**: Totally.  Well, thank you so much, Matt.  Brandon,
would you have any other questions for Matt?  On my end, that would be it.
Awesome.  So, you're free to drop, but you can also stay in the podcast if you
wish to.  Thank you so much, Matt.

**Matt Morehouse**: Yeah, thanks, folks.

_Proposal for wallet label synchronization_

**Gustavo Flores Echaiz**: Awesome.  So, now we're going to go to the next
item in the News section, which is, "Proposal for wallet label
synchronization".  So, I don't know how much you looked into this one, Matt,
but from my understanding, Jakub posted to the Bitcoin-Dev mailing list
proposing a standardization spec of how wallets can basically communicate
between themselves or synchronize wallet labels between themselves.  So, I
believe there are two open questions here.  How can they do this in a manner
where only they can decrypt the information?  And also, how can they transport
this information?  So, my understanding is that Jakub proposes that the
descriptor data, which is technically considered not fully private data, but
in most cases it is data that only wallet holders have, that the descriptor
data would be used to sort of decrypt and find the information for wallet
label synchronization.  And Jakub also proposed Nostr as a reference transfer
protocol.  But the protocol only requires a service that can store and return
data.

I saw some major pushback from Craig Raw, where he basically says that this is
not a bad idea in itself, it's just that label synchronization should be part
of a broader inter-wallet communication, which should include other use cases
such as PSBTs, multisig setups, and payment confirmations.  Because he does
bring a good point that wallets could not just have the need to synchronize on
wallet labels, but on other types of data.  Craig Raw also pushed back on the
use of Nostr as the reference transfer protocol, since exchange of financial
data should optimize for privacy rather than censorship-resistance, and noting
that he's working on a BIP for canonical output descriptors.

I think this is an interesting proposal.  It does sound similar or at least
inspired partially by something we covered in the previous newsletter, which
was BIP138, which was a compact encryption scheme for non-seed wallet data.
But this is more applied to wallet labels, or not just encrypting or
decrypting information, but rather creating a sort of synchronization
specification system that works through a transport protocol and also has
techniques around how to find the data and decrypt the data.  So, would you
have any thoughts you would like to add here, Brandon?  I would just say that
if listeners are more interested, they can look at the original Bitcoin-Dev
mailing list comment.  They can also reply to it since Jakub is looking for
feedback here.  But please, Brandon, if you have any thoughts, I would love to
hear them.

**Brandon Black**: I think my biggest thing is, as you said, there's recent
talk about other kind of related parts of the wallet ecosystem.  I think we're
seeing, as Bitcoin matures here and people have wallets that live a long time
that have multiple signers in them, obviously companies that support multisig
wallets already have somewhat of an interchange that they're doing of this
kind of data between the different signers in that wallet.  But when you're
doing it in an open-source way, there isn't a standard yet for doing that.
And so, I think this is reflecting a need for standardization of things that
right now you only get when you use a vendor for your multisig.  And I hope
this kind of stuff goes forward.  There's been lots and lots of talk about
this kind of thing in terms of how you encrypt and retrieve descriptor data,
and how you exchange PSBTs, and even payjoin essentially relates to this,
because payjoin uses Nostr as an option for how to exchange in-progress
payjoins.  So, I think hopefully we'll see kind of a coalescing of these
different proposals and get a general interop library essentially, where
wallets can make payjoins and label synchronization and all that stuff work
together, as Craig kind of said.

**Gustavo Flores Echaiz**: Totally.  Yes, I was recently thinking about this
and, for example, I use Nunchuk, and Nunchuk has a sort of internal transport
protocol where we can basically share data with other multisig participants.
But yeah, it would be really cool to have a sort of standard that wallets can
apply and wallets can become interoperable this way.  And I also think this is
particularly related to coin selection.  So, for example, yes, BIP329 allows
for a standardized way of exporting labels from a wallet and importing them
into another wallet.  But let's say you are two signers in the same multisig
wallet trying to coordinate signing and also selecting specific UTXOs.  Well,
synchronizing wallet labels in real time would be really helpful in order to
both have the same information on the specific UTXOs that will be chosen for
this wallet.

So, yeah, once again listeners, if you are curious to learn more about this,
Jakub shared this a few weeks ago, on September 13, on the Bitcoin-Dev mailing
list.  You can reach out to him, you can also join the conversation for
further feedback, and we'll also be patiently waiting for Craig Raw's work,
because he said he's working on a BIP for canonical output descriptors.  So,
he seems to have some ideas on this topic and potentially maybe brings on a
solution that will solve it.  That's it for this section, and we can jump in
directly to the Changing consensus section.  Brandon, the floor is yours.

_Continued discussion of PQC output types_

**Brandon Black**: All right.  Yes, we have several interesting items in
Changing consensus.  As has been common, a chunk of it is about post-quantum
stuff, with the first item being a continuation of the discussion we've
covered twice already on Optech Changing consensus, about post-quantum output
types.  This is a big topic, which is why it's taking up a lot of bandwidth,
let's say, on the mailing list and on Delving as well.  The basic question
here is if we're going to make a new output type that's for post quantum
particularly, what does that look like?  And how do we, as an ecosystem,
create the right incentives for users to move to that type when it's right for
them?  Because Bitcoin isn't about forcing people to change how they do
things, we've never done that kind of thing.  We always want to look at, I
think, a Bitcoin ecosystem in avoiding confiscation, as was worked hard on in
past soft forks and past changes.  And so, there's a lot of debate here.

The most recent conversation is really about the incentives, where if we were
to create a new output type that supports both a post-quantum signature
scheme, but also cross-input signature aggregation (CISA) for existing
secp256k1-based signatures, that would create a situation where moving to the
post-quantum supporting output type would also give you a fee savings on your
existing elliptic curve secp signatures.  And so, the debate is, is that the
right thing to do?  Antoine Poinsot posted about how that's kind of an
opposite-direction pull.  You're kind of pulling some people that are
fee-sensitive, but then some people that aren't fee-sensitive into the same
output type, and is that the right incentive?  So, yeah, it's a huge
conversation.  We've covered it three times here for a reason.  It's worth
users following up on this and commenting, because this is one of the biggest
conversations happening in Bitcoin right now.

As everyone probably knows by now, I don't think quantum is necessarily coming
to attack Bitcoin, but I think this is a very, very important conversation,
because we are going to want additional crypto systems in Bitcoin, regardless
of quantum.  We might want zero-knowledge proofs (ZKPs) of some sort, we might
want a hash-based signature for various reasons, especially as we think about
Bitcoin existing for 20, 50, 100 years.  We don't want to be relying on a
single crypto system forever.  So, really worth diving in here and considering
the shape of the next output type after segwitv1 P2TR, (Pay-to-Taproot),
whether that might be P2MR (Pay-to-Merkle-Root), P2TRv2, or something else
that's not proposed yet.  Really worth thinking about this stuff.

**Gustavo Flores Echaiz**: Thank you, Brandon, that was really good coverage.
Could you just remind for listeners what P2TRv2 is?  Maybe some didn't listen
to the previous episode where we covered it.

**Brandon Black**: Yeah, so I'll cover both P2MR and P2TRv2.  So, P2MR is
basically taking P2TR and taking out the internal key.  So, existing taproot
has an internal key and then a script tree, and you can spend either using a
keypath or a scriptpath.  P2MR is a pretty, in a certain way, simple change.
It just takes out that internal key.  So, it's just a merkle root of script
tree; there's only a script spend.  And so, that makes it kind of the root
spend path is now quantum-resistant because it's a hash-based spend path not
vulnerable to quantum.  And so, users could then put still an elliptic curve
secp signature in one of those scriptpaths, but it's hidden behind a hash and
therefore resists quantum attack, as long as you don't reuse addresses.  On
the flip side, P2TRv2 basically takes taproot exactly as it is, copies it, but
says, if you're using P2TRv2, you expect that at some point, your keypath will
become unspendable.  So, when you use P2TRv2, you as the user are accepting
you cannot always rely on keypath.  So, you should either expect to rotate
your UTXOs frequently, or have a scriptpath that you can fall back on.  And
that's kind of, if we needed to turn off secp for some reason in an urgency,
without confiscating anyone's coins who didn't opt into that potential
confiscation, we could turn off the keypath spend on P2TRv2.

Now, inside either of these, you could hide -- hide is maybe the wrong word,
but you could put a quantum-resistant signing scheme as well.  And so, the
details could be similar under the hood.  The question here is about what the
root level looks like.  Is it P2TR with an internal key that could be
activated, or is it just P2MR?

**Gustavo Flores Echaiz**: Right, totally.  Very, very interesting.  So, it
seems that, I mean, this research has had a little while going already and we
still haven't settled, but it's great to see a discussion here.  So, if
listeners want to learn more about it, the discussion is still ongoing, very
actively on Delving.  It started a few months ago, I believe, in July.  But
now, it still has recent communication updates.  So, everyone's welcome to
join the conversation, but also to learn more about the details directly on
Delving.

**Brandon Black**: Yeah, it's a huge conversation, and I think it's going to
keep going because there's no perfect answer.  And we'll find, I think, the
right compromise.  I'm glad that the minds like Pieter Wuille and Antoine
Poinsot and Conduition are in there thinking hard about it, because a lot of
it goes above my pay grade for sure.

_Block-wide signature aggregation via SNARKs_

All right, moving along, speaking of ZKPs that I mentioned, as we're talking
about post quantum again, we're facing the very real possibility that
post-quantum signatures might be much larger than our existing secp256k1
signatures.  And we're talking potentially an order of magnitude larger.  So,
we either accept a much lower throughput on Bitcoin transactions, or we need
to do something.  Some conversations have kind of looked around at what it
would look like to separately price post-quantum signature data, so that we
would have larger blocks that could potentially have, I think Conduition
cited, a terabyte per year of blockchain growth.  I mentioned an order of
magnitude; that kind of matches, right?  An order of magnitude faster
blockchain growth to facilitate a similar transaction throughput with
post-quantum signatures.

I think for most bitcoiners, that's probably not something we really want to
do.  That would be a significantly higher cost for node runners, and we want
to keep the network decentralized, all these things we talked about.  So,
what's the alternative?  And that's where this post comes in.  Conduition
posted about really a sketch at this point, it's not a fully fleshed out
proposal, but for a way that we could have a block-wide proof that all the
signatures were validated, rather than having every signature embedded in the
blocks that every node stores.  So, nodes would relay all the big signatures,
so we'd have a higher relay bandwidth.  But once the blocks are mined, they
would only include a compact proof that all the signatures were validated and
were valid at the time the block was created.  And then, nodes would only
store that smaller proof durably.  And that proof could be in the shape of a
SNARK.

So, Conduition did some proof-of-concept work on this, looking at how big the
proof would be, and it came up with about 500 KB probably.  So, we'd end up
with this interesting kind of block structure, where the main transaction data
might be up to a megabyte, and then you'd have this one big proof over all of
that transaction data that those signatures were valid that would take up
another half megabyte, and blocks would be about the same size they are today
when you total it all up.  And then, I think he made a valid point similar to
the incentives conversation we were having about post-quantum output types,
that if we have the option for a ZKP of all the signatures. we should not also
have the block format allow individual signatures, because that creates kind
of a weird incentive distortion thing, where some users can disproportionately
use resources by kind of forcing their full signature into the block, or a
miner could kind of overuse node resources by not doing a SNARK when they
should have.  So, if we're going to do this, we would want all the signatures
to go into the single SNARK.

Then, the other thing he brought up is that unfortunately, anytime you're
adding new cryptography to a system, there's a risk that the new cryptography
is worse than the old cryptography in some way.  And that's a big part of the
whole quantum conversation as well, and part of the reason that P2TRv2 exists;
let's use the existing stuff we know works until we know it doesn't so that
we're not over-reliant on the new stuff.  And so, he suggested that we would
have a way to fall back out of this SNARK-proof block format if they were to
be found vulnerable.  It wouldn't be a permanent addition initially, it would
be, I'd say potentially, a temporary soft fork that eventually forks itself
out if needed, similar to how we would fork out secp if needed for a quantum
vulnerability.  I know that's a whole other conversation we've talked about on
this podcast before.  So, just worth saying, it's similar that conversation of
how you would handle adding new cryptography, and how Bitcoin as a whole
system would handle the potential need to someday disable any cryptography it
relies on.

There were some other kind of posters that replied to this about the quality
of the proofs that are required for this, and how when you're SNARK-proving
this block, you're essentially recursive on the SNARK proof of the previous
block, and it's not absolutely clear that that's proven secure yet.  And then
also, that an abuse of a signature could now potentially delay a miner's
ability to produce block templates by slowing down the proving of the SNARK
that needs to be embedded in the block template before it can be mined.  So,
that's something else that has to be thought about if we're going to add
what's called another layer to what miners have to do, right?  Right now,
miners have this pretty quick job they do, where they pre-select transactions,
and then when it's time to make a new block, they quickly grab the top block
chunk to start mining on it.  If we have a SNARK they have to produce, now
they have to do work that might take several seconds before they can start
mining on a new block.  And if some user's signature can make that work long,
now you're attacking a miner by sending them a transaction that delays their
ability to start mining.  All things to think about as we go down new
cryptographic roads.  Questions?

**Gustavo Flores Echaiz**: Very interesting.  Well, thank you so much for
explaining all that.  Yeah, I have a few questions.  So, I mean, even on the
best-case scenario, you still have some major trade-offs right?  So, you add
an extra job to a miner, but you also complicate more the work of individual
nodes that verify these SNARK proofs.  Is my understanding correct that those
are the trade-offs, or are there other trade-offs even in the best-case
scenario?

**Brandon Black**: The main one is on the miner side.  For the nodes, this
actually will end up being a quicker verification, I think, even than secp
signatures.  The single SNARK proof that covers all of the post-quantum
signatures of the whole block, verification of SNARKs is very quick.  So, the
nodes are going to actually get more efficient, it's really on the miner.  So,
we essentially trade some miner work for some node work, which that, to me at
least, seems like a reasonable trade-off.  For the nodes, it's really about a
trust trade-off, where now the nodes can't see directly, when they get a
SNARK, all of the transactions that were in it in the same way they could.
Now, a big powerful node could actually do that, hold all of the signatures,
and rebuild the SNARK on its own.  But I would expect most people running most
nodes would only validate the SNARK, not re-prove it to themselves.

**Gustavo Flores Echaiz**: Right, understood.  Okay, and that's assuming that
everything goes well with the SNARK cryptography, which as you mentioned, has
some potential risks.  I believe other cryptocurrencies have had issues
implementing such cryptography, right, which has led to, like, unable to
verify the supply of those coins; is that correct?

**Brandon Black**: Yeah, and of course, just to keep perspective here, Bitcoin
would not be using a STARK or a SNARK, either of these zero-knowledge
structures to prove the shape of the transactions themselves.  This would only
be proof of ownership, proof of authorization.  And so, we wouldn't have any
kind of supply vulnerability, even if the SNARK was totally broken.  We would
have potentially coins moved, not by their owner, but we wouldn't have any new
coins or any double-spend or anything like that.  So, this is a lower-risk
thing than, like, a full Zcash implementation style thing.  But there is still
a trusted setup involved in some of ZKP structures, I think, that was talked
about in this thread, if you want to get down into the details and read the
whole Delving conversation.

**Gustavo Flores Echaiz**: Right, understood.  Thank you for making that
clarification.  I think that wasn't completely clear to me, but now it is.
So, yeah, if listeners want to learn more about it, there's a bunch of links
and a conversation in Delving about this all.  So, really cool stuff.  Let's
move on to the next topic.

_Bounds on chain length with BIP54 time warp fixes_

**Brandon Black**: Yeah, keep going.  So, the next one, we get out of quantum
land, which makes me happy because, you know, that's me!  On to BIP54.  This
is a really cool result that Pieter Wuille developed.  So, the topic is BIP54,
the consensus cleanup.  And one of the things that consensus cleanup aims to
do is to fix this category of attacks on Bitcoin called time warp, where
miners can manipulate the Bitcoin block time.  Miners can do this because
Bitcoin doesn't have a true oracle to real time, right?  The time on Bitcoin
blocks is whatever the miners say it is within some bounds enforced by the
protocol.  In the current Bitcoin, those bounds are very wide, and miners can
manipulate the timestamps significantly to affect the rate of block
production.  And that's what Pieter Wuille went to look at, is right now,
miners are essentially unbounded on how fast they can produce blocks by
manipulating the timestamp.  If we implement BIP54 and make it the consensus
rules of the network, he proved that there is a provable bound on how fast
they can produce blocks, even if they maximally abuse the new BIP54 rules.
And that's a very cool result, it means BIP54 works, it does what it's
supposed to.  It kind of puts a bound that we can understand, in terms of the
relationship between the real rate of block production and the rate specified
by the protocol, of about one block every ten minutes.  And it gets actually
very close.  I think the proof shows it's within about 1% of the intended rate
by more closely tying the timestamps to each other through the Bitcoin
protocol and to the work.  So, that's basically the summary of it.

If I understand correctly, this prevents a malicious group with hashrate from
creating a false headers chain that creates many millions of blocks and forces
a new Bitcoin node to explore that chain in order to find out which the
most-work chain is.  Once BIP54 is the rule of the network above a certain
height, the nodes know how many blocks a legitimate chain can possibly have
and are never forced to explore many, many millions of blocks to find the tip.
And so, that's the attack that this defends against, in addition to just the
general growth of the chain being a known rate versus there was actually talk
some years ago that users may not have read about, where someone proposed
rather than changing Bitcoin's block size to get more transaction throughput,
let's just abuse the existing loose rules on block timestamps so we get more
blocks; and that way, we get more throughput without actually changing the
block size.  And so, this closes both of those potential vulnerabilities In
the protocol.  But Pieter was focused on the headers one.

**Gustavo Flores Echaiz**: Right, that's very clear.

**Brandon Black**: Questions on that one?

**Gustavo Flores Echaiz**: No.  Just, so basically, this is not about a new
idea.  Instead, it's about proving that the proposal is quite solid at fixing
the vulnerabilities, the potential risks that could occur without them; is
that correct?

**Brandon Black**: Yeah.  And one thing I think is really cool about Pieter
being able to go back and prove this is that in the development of BIP54,
there was a huge amount of debate about these timestamps.  And the reason
there was all this debate about it was that they wanted to make sure that
normal miners, without applying any BIP54 rules to their own internal stuff,
wouldn't accidentally violate it.  They wanted the rules to be, okay, these
protect from attacks, but they're not going to kick off an old miner who
didn't upgrade to BIP54, who accidentally tweaks the timestamp a little bit,
their clock's off by five seconds.  And so, even with all that conversation
and relaxing, like, the original BIP54 had even tighter bounds.  They relaxed
it a little bit to make sure that we wouldn't be kicking off miners
unnecessarily, and it still does the job correctly.  So, I'm very glad to see
this result that matches kind of the theory that was done many months ago on
BIP54.

**Gustavo Flores Echaiz**: Awesome.  Great, thank you, Brandon.

_Comparing covenant proposals for vaults_

**Brandon Black**: All right.  So now, the next one we have here is about
using different covenant proposals to build reactive security vaults.  I have
to be a little bit careful.  I realized when I wrote this, I didn't include
the words, 'reactive security' in the title.  Unfortunately, the word,
'vault', for good reasons, is used everywhere in Bitcoin.  In this item, we
are talking about reactive security vaults, meaning a Bitcoin storage
structure where if there's an attack, an attacker gets the key that releases
the funds, there's time between when they can post a transaction and when it
can actually happen, letting a user react to that before the funds are
actually gone to the attacker.  And so, Lillian Wang posted about this to the
Bitcoin-Dev mailing list and Delving Bitcoin, about how different proposals
compare in implementing these reactive security vaults.  And basically, what
she came up with was that for a simple vault structure, something like CTV
(CHECKTEMPLATEVERIFY) or I added in TEMPLATEHASH, because they're equivalent
for this use case, it is kind of the right shape of opcode to implement simple
vaults.  And I think that matches what we've seen with both James O'Beirne's
older simple CTV vaults, and also ademan's recent more complex CTV vaults
proposals.  Both of those show that for vault structures that are, let's say,
infrequently accessed, relatively simple, you want to have a low cognitive
load of thinking about how they work, CTV or TEMPLATEHASH works really well
for those things.

If you want to do vaults and get other stuff along with it, there are other
proposals that might work better.  If you need your vaults to have nuanced
rules around coin access and which coins come out in which ways, then TXHASH
is maybe better.  And if you need your vaults to be more functional as an
everyday wallet, where you can have change going back into the vault and you
can deposit arbitrary amounts, and these kinds of everyday functionality for a
vault, then something like CCV (CHECKCONTRACTVERIFY), which replaced OP_VAULT
for this purpose, would be more suitable.  But again, the overall conclusion
is that simple vaults work well with CTV or TEMPLATEHASH.  And that, again,
matches what the rest of the ecosystem is seeing, but it's cool to see someone
going down the road and looking at each of the proposals and how they fit for
that use case.

**Gustavo Flores Echaiz**: Totally.  That's very clear to me.

**Brandon Black**: One thing that came up that I added to the summary here and
is worth mentioning, is there's an interesting nuance, which is that
SIGHASH_ANYPREVOUT, formerly the SIGHASH_NOINPUT proposal, can also be used
for these things, but it has one additional risk versus CTV or TEMPLATEHASH,
which I think is reflected in the fact that TEMPLATEHASH and CTV have had more
mind share for several years now.  They're kind of tighter.  They protect
against more kinds of risks in the way they're implemented.

**Gustavo Flores Echaiz**: Really cool ideas.  It's really nice to see the
comparison between all these different covenant proposals, right, because
sometimes it just feels like there's a new one and a new one, and you kind of
lose track of the multiple ones.  So, if listeners are curious about how these
proposals compare for building vaults, this is a great read.

**Brandon Black**: Yeah.  And I think right now, at least, I think the
mindshare in covenant proposal is around the TEMPLATEHASH plus CSFS
(CHECKSIGFROMSTACK) plus INTERNALKEY proposal, BIP448.  And that is, I think,
where I would direct users.  If you want to learn about one covenant proposal,
look at BIP448.  I would recommend looking at others because I love that
stuff, but I'm not saying everyone has time to read everything.  So, if you're
going to read just one, read BIP448 and it's kind of three related BIPs.
There's a lot of work around that right now.

**Gustavo Flores Echaiz**: Makes total sense.

_Depots for probabilistic Lightning channels_

**Brandon Black**: Moving along to our last Changing consensus item, we have
John Law's latest proposal.  John Law has over the years posted many
remarkable proposals for Bitcoin protocol ideas, how we can use Bitcoin better
as users.  And this one's called depots.  And the idea here is how do we get
everybody into the LN?  He's been working on that for a long time.  He built
timeout trees, which is in some ways a relative of Ark.  So, this is another
proposal that kind of works with something like BIP448 that we were just
talking about.  And this one allows potentially millions of Lightning channels
to be produced from a single output on chain.  And the way it achieves this, I
think, is very clever.  And that is that because each of these channels might
be very small and the balance might not really be possible to resolve into an
onchain output without all of it going to fees, for example -- that's one of
the challenges with something like Ark or Spark right now, is that if you have
a small Ark or Spark output, you try to go onchain, the whole output's
consumed by the fees to go onchain.

So, how does Depot solve this?  It says, well, we don't actually give every
user an individual way to get out onchain.  Instead, to protect users from a
malicious depot operator, if the depot operator doesn't honour the contract,
the whole output goes to one of the users in the chain with a probability of
one over the number of users.  So, each user is assigned a random value, and
you don't know until the operator violates, if the operator violates, one of
those will get the whole thing.  And so, every user has a net expected onchain
value, in the event that the operator violates, of their proper value.  In
reality, one user would get the whole thing.  So, it's an incentive-compatible
structure where if it ever were to actually go onchain, there would be this
weird thing where one user gets a windfall and the others get nothing.  But
this hopefully keeps the operator honest so that never actually happens.  As
long as the operator's honest, everyone gets their own correct values out, and
the operator rolls them forward kind of similar to an Ark, where it rolls
forward over time by sweeping the old channels into a new depot.  According to
Law, this structure would let us keep everyone, the whole world, in Lightning
for the cost of about 1 or 2 vbytes per user per year, which if you think
about it, that's enough that we could really actually put every person on the
LN.  It's very inexpensive to do it this way.

Then, yeah, there's one last little item that was talked about, which is that
there's a difference here between Ark or timeout trees, which is that the
users can't be automatically rolled into a new depot like they can in a
timeout tree or an Ark, they need to participate.  And so, if users lose their
stuff, they might lose their value in an old depot, rather than being able to
be recovered into a new one.  So, just a little tidbit of difference.  I think
it's a very interesting construction.  It's another way where if we have some
relatively constrained covenant addition to Bitcoin, it'll make a material
difference in our ability to serve users with self-custody on Bitcoin.  So,
great to see more applications for these different covenant proposals coming
forward.

**Gustavo Flores Echaiz**: Really cool stuff.  So, is my understanding correct
that this is similar to Ark, where a user has to come online, for example,
every two weeks, every 28 days?

**Brandon Black**: Yes, it has similar properties to Ark there where they will
roll over periodically.  If I understood it correctly, however, if users don't
roll over, they can be just automatically put onchain for relatively low cost
compared to Ark.  So, there's like a trade-off where you can't be
automatically rolled into a new one, but you can be put onchain more
affordably, if I understood correctly.  Don't quote me on that though, it's a
little complicated.

**Gustavo Flores Echaiz**: Right.  But also, at the same time, it also says
that the balances are typically too small to be worth claiming onchain, right,
that's the whole point?

**Brandon Black**: Fair, yeah.

**Gustavo Flores Echaiz**: Right.  This is a sort of like, I cannot claim back
my funds because they're too small to be claimed back, but I can have a chance
at winning big, right, at getting the whole value.

**Brandon Black**: If the operator is malicious, you have a chance of winning
big, yeah.

**Gustavo Flores Echaiz**: Interesting proposal.  Definitely something I had
never thought of.  So, definitely cool to see the depots idea.  So, we'll see
where this goes.  Hopefully, there's feedback to the conversation.  I think
people have already left some feedback.  So, if listeners are interested, they
can also jump in into Delving to drop some additional feedback.

**Brandon Black**: Absolutely.  And that's all for Changing consensus this
month.

_LND v0.21.4-beta.rc1_

**Gustavo Flores Echaiz**: Awesome.  Well, thank you so much, Brandon, for
being here and helping us out with this section.  Very cool stuff.  Now, we're
going to jump into the Release sections and we're going to finish with the
Notable code and documentation changes.  So, this week, we've got two release
candidates on the LND side, v0.21.4 and v0.20.5.  Both of these are
maintenance releases.  So, actually, when we wrote the newsletter, they were
both at the RC level.  But now, since precisely the day of where we published
the newsletter, now they're fully in beta.  So, these are official maintenance
releases.  There are no longer testable RCs.  Users are recommended to upgrade
for security reasons, and they include multiple fixes.  We cover some in the
Notable code section below, specifically the ones related to channel
announcement synchronization and restriction on new legacy channels.  This
release, v0.21.4, also requires explicit channel types when opening channels.
So, you can no longer assume a channel type, you always have to specify one
when opening a channel.

There's other fixes related to pending HTLCs, unintended cancellation of AMP
invoices, and SQL graph migration failures.  So, if listeners want to learn
more about the pending HTLCs issues or the AMP invoices, we covered that
precisely in Newsletter #424, so just the previous one last week.  And
finally, v0.21.4 also has a new feature where WalletKit can now reserve
outputs until their spending transactions reach a specified confirmation
depth.  So, this is a mechanism to block other transactions from selecting
these UTXOs.

_LND v0.20.5-beta.rc1_

And v0.20.5-beta is very similar to v0.21.4.  It backports several fixes,
including those for pending HTLCs, AMP invoice cancellation, and channel
synchronization.  But it also adds bounds on onion payload parsing.  And the
bounds on onion payload parsing was already a fix that was included in version
v0.21, so this was simply backported to v0.20.5.  So, once again here, the
action item is to go and update your LND node if you are using LND and haven't
updated yet, similar to the action item that Matt told us about Eclair, and in
general, right?  Lightning is a very complex system, so it potentially can
have multiple vulnerabilities.  So, it's always very important to stay
up-to-date across all implementations, particularly in this moment in time we
are where it seems that AI models are becoming more and more powerful and more
able to find new vulnerabilities.

_Bitcoin Core #29278_

We move to the notable code and documentation changes section.  So, here,
Brandon, if something's not clear, please let me know; if you have anything to
add as well.  So, we have multiple items in the Bitcoin Core repo, about seven
of them.  The first one, #29278, this is a new configuration option called
-maxfeerate that caps the fee rate of wallet transactions at 10,000 sat/vB
(satoshis per vbyte) by default, but this is of course configurable.  It was
previously thought that this was possible, or at least there was some
confusion that -maxtxfee, the existing config option, although it was
documented as an absolute fee cap, so not a per-vB fee cap, but rather just an
absolute fee, some code was already interpreting that existing option as a fee
per 1,000 vB.  So, -maxtxfee, the existing option, was playing both roles
accidentally.  So, now, this PR not only introduces the new config option, but
also ensures that the previous option only serves its intended purpose of
being an absolute fee cap rather than a feerate cap.  And the new option
separates the feerate limit from the total fee limit and applies to
transaction creation, fee bumping, CPFP, and regular wallet broadcasts.

**Brandon Black**: This is such an important change to avoid fat-finger loss
of funds.  We've seen many cases over the years in Bitcoin of massive fees.
There's one notable case where I think a miner returned like something like 80
bitcoin worth of fees to the accidental spender.  We shouldn't be counting on
miner goodwill, we should have better software, so this is great.

_Bitcoin Core #35984_

**Gustavo Flores Echaiz**: Totally agree with you.  Let's jump on to the next
item #35984.  So, this is a bug when signing PSBTs, when using SIGHASH_SINGLE.
So, SIGHASH_SINGLE signs an input to make it commit to the output at the same
index as the input being signed.  So, if I sign input number two, it will
commit to output number two; and if I was later to change output number two,
then the signature would simply be invalid then.  However, if the
corresponding output is missing, legacy signing, so pre-segwit signing,
produces a signature over a constant hash.  The problem is that this signature
can be reused to spend other UTXOs controlled by the same key.  So, when
legacy signing with SIGHASH_SINGLE when there's no corresponding output, I can
then later on switch the UTXO if it's controlled by the same key and the
signature will still be valid.  So, it doesn't specifically commit to the UTXO
being signed, it only can commits to the key being signed and the position in
the absence of the corresponding output.  Very important to say that this
requires both the corresponding output to be missing and also legacy signing,
because this doesn't affect legacy segwit v0 or taproot.  So, the problem was
that anybody could change the UTXO and the signature would still be valid.

So, now, this bug is now fixed, where Bitcoin Core now leaves such inputs
unsigned.  So, it will refuse to sign if there's no corresponding output,
because the whole point of SIGHASH_SINGLE is to commit to the corresponding
output.  So, Bitcoin Core will refuse to sign precisely this input.  However,
it will still sign the PSBT's other inputs.  And this was a check that was
already present in raw transaction signing, but it has now been extended to
PSBT signing as well.  If someone wants to learn more about the SIGHASH_SINGLE
bug in legacy signing, we covered in Newsletter #207 how Rust Bitcoin fixed
the occasion of that bug.  So, you can also learn more of how Rust Bitcoin
implemented it back then.  But that specific item is also linked to a
coinspect.com blog article that explains further how this bug or incident
worked.

_Bitcoin Core #35301_

Next item, Bitcoin Core #35301.  This is a very exciting item, because it's
the beginning of the implementation of BIP352, also known as silent payments,
inside Bitcoin Core.  So, now, this doesn't mean that you as a user can
already use it through the RPC or through the GUI.  But now, Bitcoin Core has
support for encoding and decoding silent payment addresses; it can derive
taproot payment outputs from eligible transaction inputs; and it can also scan
transactions for payments to a recipient.  This also adds support for labels,
which are a way to distinguish payments to different derived addresses and
identify change when using silent payments.  So, this of course builds on
libsecp256k1, a silent payment module that we covered in Newsletter #415.  So,
it's really cool to see Bitcoin Core finally implement silent payments after
the module was added to libsecp256k1 a few weeks ago.  So, really exciting
news, and we're hopeful that this will conclude into usable features soon.
But if I look at the BIP352 tracking issue on the Bitcoin Core repository, I
can see that the pre-works and the refactors have all been done, and now this
major one was implemented.  So, there remains a few steps.  But we're
definitely getting closer to full implementation after the tracking of that
issue was started more than three years ago.  So, this has been a long way
coming, and it's now finally getting to Bitcoin Core.

_Bitcoin Core #36312_

Next item, Bitcoin Core #36312.  This is about a fix in the experimental
opt-in private transaction broadcasting feature.  So, we covered the
announcement or the addition of that in Bitcoin Core in Newsletter #388.  To
remind listeners, this is a feature that allows a user to broadcast
transactions to short-lived Tor or I2P connections, or to the Tor proxy to
IPv4 and IPv6 peers, when using sendrawtransaction.  So, this allows you to
temporarily conceal your IP address and it protects the privacy of you as the
transaction originator when your node broadcasts your transaction to your
network peers and to the Bitcoin Network.  However, there was a bug when if
there was a misbehaving peer that you would like to discourage from your node,
so you would like to disconnect from this misbehaving peer, you would
previously disconnect both the private broadcast connection and your regular
Bitcoin Core node connection.  However, the problem was that a malicious peer
could deliberately trigger these disconnections to make sure they can observe
that both of these connections disconnected at the same time.  So, they can
then assume that you are the one behind both connections, and that weakens
considerably transaction origin privacy.

So, now, in the case where you would discourage misbehaving peer connection,
in the regular use, it will leave private broadcast connections intact, so it
wouldn't disconnect them separately.  However, if you're in the private
broadcast mode and you want to disconnect the peer, it would do so without
discouraging their address from your general connection.  So, it either
happens in one, it never happens in both at the same time to avoid a malicious
peer from correlating both addresses back to your node.  And if listeners want
to know more about what it means to discourage a misbehaving peer, the
Newsletter attaches a reference back to Newsletter #106, where a documentation
change in Bitcoin Core was made to clarify the distinction between manual peer
banning and automated peer discouragement.  So, you can learn more about that.
But basically, this is what your node does when it basically finds that a user
is misbehaving, and it will not ban it, but it will discourage it by simply
disconnecting once, which eventually, the peer could connect again to your
node, so it doesn't fully ban it; it simply disconnects.

_Bitcoin Core #36284_

Next item, #36284. This is another bug fix in Bitcoin Core where, when using
the option -avoidpartialspends or the wallet's avoid_reuse flag, your wallet
could reject the payment despite you having enough funds to pay for this.  So,
what is -avoidpartialspends?  When you use the -avoidpartialspends function,
your wallet will by default spend all outputs received to the same address.
So, even if you don't need to select all the UTXOs that were received to the
same address because the amount can just be paid with simply one, it will
still select all these UTXOs so that they can be consolidated and they can be
moved to a change address.  So, this is a privacy feature.  However, when
using this feature or the wallet avoid_reuse flag, where the wallet
avoid_reuse flag prevents the wallet from spending bitcoins received to an
address that the wallet had already used for spending, with this one, it's not
your wallet spending multiple UTXOs; when choosing coins for a transaction,
your wallet will make sure to never select a UTXO that was received in an
address that you had already previously spent from.  And this is once again a
privacy protection, but potentially it could even have further implications
when we consider quantum computing as a potential attack.  This is also a
protection around creating multiple signatures.

Anyways, the point is that when using this flag or the previous described
option, if a group failed eligibility check, for example limit on unconfirmed
ancestors, its value was subtracted twice.  So, for example, you have 4 UTXOs
of 1 bitcoin each.  You need to spend 3.5 bitcoins.  You have 3 bitcoins that
are fully confirmed, so you select those.  Excuse me, that's not it.  If you
want to spend, for example, 2.5 bitcoins, and you have 3 bitcoins that are
fully confirmed, but you have one that is not confirmed yet, so it fails the
eligibility check, it gets subtracted twice.  So, from having 4 and from
having 3 available, instead it gets reduced to 2 available, because the one
that was unavailable gets subtracted twice, where it shouldn't, it should only
be subtracted once.  So, the fix is to make sure that it only gets subtracted
once when using this specific flag or options.  That was the only occurrence
where such a bug could occur, and the worst outcome was simply your wallet
rejecting a payment despite having enough eligible funds.  And if, for
example, that UTXO would confirm, then the issue would have disappeared, so
this was a temporary issue and not that consequential.

**Brandon Black**: It almost seems like we should be just not allowing spends
with -avoidpartialspends if there are any candidate UTXOs that match the set
that are unconfirmed, because now we have a UTXO that is going to the same
address and isn't getting included in the full spend of that address.  I feel
like the subtraction is wrong.  I don't know, I almost want to make a new PR
to Core that kills off this fix by saying we just don't allow that.

**Gustavo Flores Echaiz**: You think?  Maybe you could potentially propose
that.  But why do you think that?  Can you share more?

**Brandon Black**: So, the idea of -avoidpartialspends is that when you spend
coins that were sent to an address, you spend all the funds sent to that
address.  If there's an incoming unconfirmed payment to that address, you
shouldn't just subtract that from the candidates and see if the group still
fits.  You should say if there's unconfirmed, this whole group is not eligible
for -avoidpartialspend, because now you're going to end up with a UTXO, sort
of, at that address again.

**Gustavo Flores Echaiz**: Right.  I think that's a misunderstanding, okay, so
maybe I mis-explained myself.  But it's not a UTXO that is related to the
group targeted by -avoidpartialspends, it's a completely unrelated UTXO.  It's
a UTXO that is in a completely different address.

**Brandon Black**: Oh, I see, it's because the group failed eligibility
checks?

**Gustavo Flores Echaiz**: Exactly.  So, it doesn't have anything to do with
that.  It's just a completely random group that was unconfirmed and its value
was subtracted twice.

**Brandon Black**: Okay.  Definitely no problems and good bug fix.  Got it
now.  Thank you.

**Gustavo Flores Echaiz**: Right, okay.  Yeah, no, that was good.  Thank you
for saying that because I did run into that doubt when I was writing this.
So, it's good that you brought that up so that it's fully clear for listeners.

_Bitcoin Core #35752_

Next item, #35752.  This is another bug fix.  This is actually quite an
interesting and big one because it's about eight different potential bugs in
one PR item.  So, this PR fixes error handling when encrypting a wallet,
changing its encryption passphrase, or adding private keys.  So, the recurring
problem here is that errors weren't properly handled.  So, for example, you
would think that you change your passphrase because it would appear as
successful, but in reality the database write would fail.  However, Bitcoin
Core wouldn't give you that feedback of that error, it would simply make you
think that the passphrase update was successful, and later on, only the old
passphrase would work.  So, your passphrase change completely failed, and
Bitcoin Core didn't properly inform you about it.  It made you think it was
successful, and you could have potentially destroyed the previous passphrase
and you would have gotten locked out of your funds.  I want to be precise
here, when I use the word, 'encryption passphrase', I'm talking about
specifically the password that you use on Bitcoin Core when encrypting or
decrypting a wallet file.  So, I'm not talking about BIP39 passphrases, so
it's important to make that distinction.

So, that's the first case where it would fail.  But there's multiple others,
such as when encrypting your wallet for the first time, it could also report
success, despite missing required key records or leaving plain text private
keys in the database.  So, once again, the encryption process makes you think
it's successful when in reality, it isn't.  And there's multiple edge cases
like that.  So, the next one, for example, when you add a private key, failed
private key insertions could leave keys only in memory, causing them to
disappear from the wallet upon reloading.  So, you thought you added a private
key to your wallet, but it gave you some feedback that it was properly added,
although it wasn't.  And there's multiple other edge cases.  The point here is
that this PR now prevents basically these errors from silently happening,
right?  It will give the feedback, the correct feedback, and it will properly
handle those errors so that users are fully aware of what was successful and
what wasn't when setting up wallet encryption or making a passphrase change,
or even adding a private key to their private key set.

**Brandon Black**: Are we aware of any loss of funds from any of these issues,
or were these all found by doing some code analysis?

**Gustavo Flores Echaiz**: Yeah, I don't think we've seen any.  There wasn't a
reported issue of a user.  This was the developer himself, l0rinc, if I'm
spelling correctly, finding this himself.  Hopefully, no loss of funds have
happened.  And probably this required multiple things to occur at the same
time, right?  It is potentially possible that users haven't run into this bug
themselves, but I guess we'll know more eventually.  Sometimes these things
are not fully disclosed at first and only later we know the full details.  But
yeah, potentially this was a consequential bug, so I'm really happy this was
now fixed.

_Bitcoin Core #35813_

The next item, Bitcoin Core #35813.  So, this is a new wallet RPC, called
listrawtransactions, that lists every transaction known to the wallet and it
returns one entry per transaction.  So, the difference with listtransactions,
that was an existing RPC, is that listtransactions returns accounting entries.
So, for example, a self-transfer to a receiving address appears as both a send
and a receive, so it's a double entry.  It got sent and it came back into my
wallet, but in reality it's just one transaction that appears twice, while a
transfer entirely to a change address would simply not appear in
listtransactions.  It would be considered as fully an internal operation that
shouldn't be presented with the listtransactions RPC.  So, now,
listrawtransactions will actually deliver every known transaction for the
wallet and return one entry per transaction, not potentially two or zero.  And
you can also use the count and skip parameters for pagination, while the
verbose argument adds decoded transaction details.

_BIPs #2276 and #2277_

The next item, now we're getting into the BIPs repository.  So, this was a fix
in PSBT finalization rules that could discard information needed for later
signing or transaction extraction.  So, the first one is in BIP376, there was
a requirement to delete PSBT_IN_WITNESS_UTXO.  The BIP376 is the specification
about how to spend silent payment outputs with PSBTs.  And there was an
instruction that when finalizing a silent payment input, you would delete
PSBT_IN_WITNESS_UTXO, which references the prevouts, or the previous outputs,
that are being spent in the transaction, so all the inputs of the transaction.
However, the problem was that if you would discard that information, other
taproot inputs would be unable to compute their signatures, because their
signatures required the information of all inputs of the transactions, or of
all previous outputs that are being spent.  So, now, that instruction is now
removed from spending silent payments in PSBT's specification, BIP376, so that
other taproot inputs in the same transaction are able to compute their
signatures from the information of all previous outputs.  So, that was the
main fix, and that's in PR #2276.

The second one, PR #2277, updates BIP370, so a different BIP specification,
which is the one defining PSBTv2, which is now the standard version, as of
Bitcoin Core v32, which we've only seen a RC of, not yet the full release.
So, in this, the second PR updates this specification BIP370 to retain
previous output identifiers, sequence numbers, and required locktimes after a
PSBTv2 input is finalized.  So, previously, when finalizing a PSBTv2 input,
those fields could get discarded, although deleting those fields could have
invalidated the PSBT or altered the extracted transaction.  So now, the
specification is updated to avoid that issue.  The second PR also updates
BIP371, which is the specification for taproot fields for PSBT.  And
basically, what happens is that an erroneous instruction to delete output
taproot derivation data during input finalization is also removed from BIP371,
probably for similar reasons as the previous issues, where it could either
invalidate the PSBT or block signing of other inputs.  Anything to add here?
No?  Perfect.

_LDK #4993_

We jump in now into the Lightning implementations.  We have one from LDK and
multiple ones from LND.  So, the first one is about LDK.  I want to say that
LDK PRs are now on a different repository, no longer on a GitHub, but instead
on git.rustbitcoin.org.  So now, those PRs will link to this new repo.  So,
PR #4993.  This is a bug that could cause a wallet to spend a reserved input
in a transaction conflicting with an unconfirmed splice.  So, this occurred
if LDK automatically would reject an RBF fee bump because the channel had
already been force-closed, it could instruct the wallet to release inputs
still needed by the original splice.  So, for example, imagine you're in a
channel, you want to splice the channel, but at the same time, you probably
even broadcast the splicing transaction, but then you see on the blockchain
that your peer has broadcasted a force-closed transaction for that channel.
So, while these transactions are in the mempool and haven't yet confirmed, an
RBF fee-bump attempt might trigger on your splice transaction.  However, LDK
will reject that RBF fee-bump contribution because it will observe that the
channel is already in force-close progress.

However, this means that LDK would then instruct the wallets to release inputs
still needed by the original splice.  And then, another transaction could have
grabbed the inputs that the original splice was using for the splice-in, the
additional inputs that were going to be added into the channel.  And even if
there were successive fee-bump attempts, this could also receive duplicate
release instructions, or even keep reservations after they were no longer
needed.  So, one RBF attempt made clear that it would release the inputs of
the splice, and other transactions could potentially try to grab them.  But if
there were multiple successive fee-bump attempts, then the behavior could
become even weirder, where duplicate release instructions could occur, or some
reservations could apply for longer after even all these transactions had
confirmed or been discarded.

So, now, each funding contribution records which inputs and outputs it
inherited from earlier attempts.  So, failure tells the wallet to release only
the contributions on reservations.  You never have to worry about your wallet
accidentally releasing inputs that an unconfirmed transaction is using with
this bug fix.

_LND #11173_

Next item, and now we get into the LND repo, which like I mentioned in the
release section, many of these items were included in the latest release.  So,
the first one, #11173, this is a bug fix where an invalid or oversized channel
range response could stall the initial sync of channel announcements until the
next scheduled attempt.  So, what does that mean?  In Newsletter #417, we
covered how LND added a protection, amongst what other implementations have
been doing, adding more and more protections lately.  And LND basically added
a limit of a maximum of 100,000 SCIDs per reply channel range message.  So,
the goal of that was simply to bound the size of that message.  So, a user
that was attempting to send a very large number of SCIDs would simply get
blocked at 100,000, because I believe the LN today is around 60,000.  So,
someone sending you more than 100,000 is obviously sending you incorrect data.
The attempted goal was simply to block that message.  However, the bug was
that LND would receive, for example, that message with more than 100,000
SCIDs, and it would simply stop syncing.  It wouldn't look for another
eligible peer, it would simply stop syncing, but LND would have a scheduled
attempt system where an hour later, it would resume syncing.  So, it wasn't
like it would forever stop syncing.  It would simply stop syncing for maybe
like one hour or less.

However, now, the fix is if there's another eligible peer, which there almost
always is, LND will simply retry continuing the synchronization with the other
eligible peer and temporarily exclude the failed peer from selection.  And the
existing connection to the failed peer would still remain open, so it doesn't
disconnect from the peer, it simply stops selecting him for concluding the
channel announcement synchronization.

_LND #11190_

Next item, LND #11190.  Here, LND is updated to reject BOLT11 invoices
containing multiple payment hash fields, even when the hashes are identical.
Okay, so this is a very interesting one, because this was actually a major
bug, and so I didn't write it here precisely.  But I found out about this news
later when making my BitDevs presentation in the monthly BitDevs meetup we
have in Mexico City.  And the thing is, I don't know if you remember, Brandon,
when lnp2pBot declared they had shut down about a month ago, they disclosed
that it was because of this issue.  So, the invoices in a library by Alex
Bosworth had an issue that was possible because of this missing part in the
spec.  So, first I'm going to talk about the issue.

So, LND now will reject BOLT11 invoices containing multiple payment hash
fields.  Before, it wouldn't, okay?  So, as a receiver, I could send a sender
a BOLT11 invoice with two payment hashes, and LND previously would accept it,
and it would use the first payment hash and would ignore the rest, as it's
recommended by the BOLT11 spec already.  However, other invoice parsers, such
as the library invoices that I mentioned earlier, would choose a different
hash.  And there would be a sort of incompatibility between LND and the other
invoice parser, where a Lightning node could basically get fooled into
thinking that it didn't pay a payment because it would say that, "Well, I paid
this".  Well, the user would say, "Well, this is the payment hash of the
transaction", because he would choose the second one, and LND would only
identify the payment to the first one.  And if a system was using both LND and
the other library, it could create a sort of issue where it would think it
hadn't paid it, but it had, and it could potentially trigger a second payment
to that user.

So, now, LND simply rejects duplicates to remove fully that ambiguity.  And
roasbeef, the one behind this PR, also opened a BOLTs PR #1357, where he
requests to modify the spec to reject an invoice with duplicate payment hashes
because, like he says, it was a recent hack of a popular Telegram p2pBot that
exploited this ambiguity, which is lnp2pBot.  Some libraries' invoices, the
library that I mentioned, took the first payment hash while some took the
last.  So, LND took the first and it seems invoices took the last.  And if you
were running a system that exhibited both variants of the behavior, then your
system could get tricked into thinking it never paid out a withdrawal.  So
now, hopefully, the specification will get updated to include this change, and
we won't be having these type of issues eventually.  But also, even if that
isn't added to the BOLTs specification, LND has already covered themselves by
rejecting any BOLT11 invoice that contains multiple payment hashes.  So, at
first, it seemed not that consequential, but now that I've looked into the
details, it was pretty consequential.  Anything you want to add here, Brandon?

**Brandon Black**: No, I mean, it's interesting.  Do you know why the invoices
allow multiple payment hash fields in the first place?

**Gustavo Flores Echaiz**: Right.  It probably seems like this was a
misunderstanding, because it does allow.  But it always said, like, a writer
shouldn't include, but it never said a reader must fail the payment if more
than one p field is present.  So, how the BOLT specification works is that
sometimes it will define things for a writer different than for a reader, and
this was one of those cases where it was doing that.  And also, for example,
it was saying a reader should use the first p field as the payment hash, it
didn't say 'must' use the p field as the payment hash, right?

**Brandon Black**: Oh, that good old RFC language distinction, 'should' versus
'must'?  Absolutely.

**Gustavo Flores Echaiz**: Exactly.  So, yeah, unfortunately, the language
used and the omission on the reader side led to this issue.

_LND #11212_

Next item, LND #11212.  This is about removing support for opening or
accepting new channels using the legacy commitment format.  So, this is what I
described earlier in the Release section.  So, in Newsletter #305, we covered
how this was already removed from the BOLT specification, and LND simply had
kept support ongoing and now has fully aligned with the BOLT specification by
removing support for opening or accepting new channels.  However, if you have
existing legacy channels, they remain usable with LND.  The problem with
legacy commitment formats is that they derive the key for the output paying
the counterparty, using a per-commitment point, which means that if your node
loses its channel state, recovering funds from its peer commitment transaction
therefore requires that peer to supply the missing point.  New channels,
static remote key channels, keep the output key unchanged across channel
updates.  So, from your wallet BIP39 seed phrase, you can recover the output
key, because it's unchanged across channel updates.  You don't need the
dependency of the per-commitment point.  And in Newsletter #67, which is
referenced here, we covered how LND added support for the option static remote
key, which is the preferred commitment format.

So, LND had had already, for a long time, support for this, but it had kept
ongoing legacy support for new channels for longer than necessary.  So, now,
this PR fully makes that change.  And also, Eclair previously, earlier this
last year, so almost a year ago, on October 31, 2025, we covered in
Newsletter #378 how Eclair had also made that change.  So now, LND does as
well to avoid users to potentially lose funds by using the legacy commitment
format.

_LND #11258_

Finally, the last item of the section in the newsletter is #11258, which fixes
a bug where forwarded HTLCs could remain unresolved if LND restarted after the
outgoing channel was closed and its records cleaned up.  So, here, it's a
classic situation of an HTLC getting forwarded.  The downstream node forwards
one HTLC to me, I forward a similar value HTLC to my upstream node, however my
upstream node fails the HTLC and closes the channel immediately.  And if, for
example, I was unable to fail back the HTLC into the incoming channel because,
for example, the downstream node was offline during that time, for example, so
I was unable to fail back the HTLC, if LND would restart as well -- so, it
requires multiple things to happen at the same time.  The upstream node closes
the channel, my LND node restarts, and the downstream node is unavailable to
receive the HTLC failed message, that leads to a situation where LND simply
kind of forgets that it has to fail back the HTLC to the downstream node,
because it has sort of cleaned up the record of the channel that is now
closed.  So, it kind of doesn't remember that the upstream peer failed back
the HTLC, so it cannot tell the incoming channel of that failure and also fail
back the HTLC.  That would leave the incoming HTLC stuck, and it would force
the downstream node to force-close the channel in order to be able to claim
back the funds onchain.

So, now, the fix is for LND to save pending responses separately from the
closed channel state.  So, even if a channel gets closed, it will remember
that it still has this response pending, and it still has to fail back the
HTLC to the downstream node.  So, it now retains the information needed to
match them to incoming HTLCs, and can also replay them on startup, so it
doesn't keep this in memory, but actually in disk, so it persists across
startups.

That is the final item of this section and that completes the whole
newsletter.  Anything you want to add, Brandon, before we finish?

**Brandon Black**: I'm just going to echo what Matt said earlier, which is,
update your software.  It's a wild time in security-sensitive software and we
all deal with money regularly.  Probably a lot of listeners maintain Bitcoin
nodes or Lightning nodes, or whatever.  Update your software.  That's my
closing message for this Optech podcast.

**Gustavo Flores Echaiz**: That's a great message, Brandon, completely agree.
Thank you so much, Brandon and Matt, for being present.  Thank you, listeners,
and we'll see you next week.

{% include references.md %}
