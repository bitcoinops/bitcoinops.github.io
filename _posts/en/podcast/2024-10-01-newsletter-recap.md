---
title: 'Bitcoin Optech Newsletter #322 Recap Podcast'
permalink: /en/podcast/2024/10/01/
reference: /en/newsletters/2024/09/27/
name: 2024-10-01-recap
slug: 2024-10-01-recap
type: podcast
layout: podcast-episode
lang: en
---
Jon Atack and Mike Schmidt are joined by Gloria Zhao and Jonas Nick to discuss
[Newsletter #322]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-9-1/387366708-44100-2-92c8fd26b16f7.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #322 Recap on
Twitter Spaces.  Today, we're going to be talking about a Bitcoin Core 24.0 and
earlier vulnerability, channel jamming mitigation testing, a new client-side
validation paper, a draft of an updated BIP process; we have six interesting
Bitcoin Stack Exchange questions to go through; and we have our weekly segments
on releases and notable code changes as well.  I'm Mike Schmidt, contributor at
Optech and Executive Director at Brink.  We have a special co-host this week.
John, do you want to introduce yourself?

**Jon Atack**: Sure.  So, yes, Murch is off taking some much-needed vacation
time, I believe, so I'm filling in for good old Murch.  I'm Jon, I'm currently
located in El Salvador working on Bitcoin, Core Dev and the BIPs repository
maintenance and editing.  And I'm gratefully now supported by the Maelstrom
Fund, OpenSats and the Human Rights Foundation.  So, cheers.

**Mike Schmidt**: Thanks for joining us, Jon.  Gloria?

**Gloria Zhao**: Hi, I'm Gloria, I work on Bitcoin Core and I am generously
sponsored by Brink.

**Mike Schmidt**: Jonas?

**Jonas Nick**: Yes, I work at the Blockstream Research Group, mainly on
cryptographic questions, signatures and related things, as well as since a few
months, I work on client-side validation protocols as well.

**Mike Schmidt**: Excellent.  Thank you both, Gloria and Jonas, for joining us
this week.  For those following along, we're just going to go through the
newsletter sequentially, #322, starting with the News section.  Gloria, are you
still there?

**Gloria Zhao**: Yes, sorry.  I have a five-minute limit on my Twitter app.

_Disclosure of vulnerability affecting Bitcoin Core versions before 24.0.1_

**Mike Schmidt**: First News item, "Disclosure of vulnerability affecting
Bitcoin Core versions before 24.0.1".  Gloria, Optech has covered some of these
recent historical disclosures.  We note Newsletter and Podcast #310, as well as
Newsletter and Podcast #314 for previous batches of disclosures.  And, Gloria, I
know that you and Niklas have also dove deep into those disclosures in our Brink
podcast as well, so I'll plug that here.  What is the vulnerability this week,
Gloria; maybe frame it up for us?

**Gloria Zhao**: Sure.  So very briefly, quick sentence, these are advisories
for old versions that are end of life, and we do it to acknowledge people that
found the bugs and patched them, encourage people to upgrade to maintained
versions, and document these bugs so that we can learn from them and future
people can learn from them.  That's the quick spiel.  So, this vulnerability,
this particular one, was known for a long time, but what changed was, (a) the
cost of the attack versus the damage that it would do, and (b) our preferred
approaches to addressing this vulnerability.

So, the vulnerability itself is tl;dr an Out Of Memory (OOM) that would be
caused by someone sending you lots of block headers.  So, to frame it more
generally, as you know, when you join the Bitcoin Network, you need to sync the
chain.  So, that involves downloading all the blocks on the main chain and
validating them so that you get a sense of what the chain state is today.  Of
course, this string of blocks is pretty big, it's hundreds of gigabytes.  So,
since 0.8, we do a headers-first sync.  So, what we first do is we sync the main
chain using just the 80-byte block headers, and once we're like, "Okay, yeah,
this is the most-work chain", then we'll go and download the block data itself,
validate all the transactions, calculate what the UTXO set is, etc.

However, even with the fact that you are first downloading only the headers --
so to give you a sense of what the size is, if each one is 80 bytes and we have
about 660,000 blocks in our main chain, that'll be like 70 to 80 MB.  So, that's
quite small compared to the full blockchain.  However, you can be receiving lots
and lots of headers from a peer.  Again, this is an anonymous, untrusted peer on
the network.  They could send you hundreds of thousands, or millions, or even
billions of headers that look like they're building up towards a lot of work,
but ultimately do not result in the main chain or are not useful to you.
They're not actually the Bitcoin blockchain.  So, we need a way of, even with
proof of work in place, which is a very natural way of checking, "Okay, this is
quite anti-spam, because you need work", we still need a way of saying, "Okay,
is this actually going to result in today's most-work chain?"

So historically, we've used checkpoints.  So, within the code, hard-coded are
basically the block hashes of blocks at certain heights.  So, I think the last
one was around 100,000, more than 10 years ago.  And so, the idea is you're not
going to download anything that doesn't match these checkpoints.  So, for
example, someone couldn't send you -- like in the first few blocks, there wasn't
very much work being done, there weren't miners using ASICs to figure out what
the nonces were going to be and whatnot.  And so, it's very easy to create lots
and lots of low-height block headers very cheaply, and it's less easy to do that
off of the checkpoints.  However, we do understand that because the last
checkpoint was quite a long time ago, it is still possible for someone with
quite a lot of compute to create a headers chain off of the last checkpoint, and
then they create a bunch of headers, they gradually ramp down the difficulty
until it's a lot lower, and then they can create like a billion headers.  And if
they send this to you, then even with all the checkpoints logic, you will OOM
because you have many, many gigabytes of headers.  Even as small as they are,
even though the work does match what the checkpoint said that you were going to
do, you are downloading lots of data and you OOM.

So, yeah, that's the background of what the vulnerability is and it's been known
for a long time, but it was always considered quite an expensive attack.
However, and I'm reading directly from the report here, because you can compare
the amount of work to do to create these headers versus the amount of work that
it costs to mine blocks on the main chain, you can kind of get a sense of the
cost in bitcoins or the cost in blocks.  So, in 2022, they found it was about
14.73% of a block.  If you, instead of deciding to mine blocks today, you
decided to create this DoS-y headers chain, that's what it would cost you.  And
then I think this year, that number is even lower.  So, we're like, "Okay, this
is relatively cheap compared to the past to do this attack that could OOM
anybody on the network who is trying to download the main chain".  And, sorry…

**Jon Atack**: Do you want to explain what OOM is for the non-programmers?

**Gloria Zhao**: I'm very sorry.  OOM stands for Out Of Memory.  So basically, I
don't know, should I explain what memory is?  It's the amount of space, your
computer's workspace.  And typically you don't have, well, some people do, but
typically you don't have like 100 GB of memory.  And when you exceed that, the
operating system will kill this process, or something worse could happen.  But
essentially, your node crashes.  And this would be pretty bad, because if you
imagine you're a user, I don't know, you've got your Raspberry Pi, you've got
your node set up, and it's downloading the main chain, you're going to be
running your own node, you're going to be your own bank, and your node crashes.
And you're like, "Oh, that sucks!"  That's all fine.  Once you figure it out,
you start it up again, it crashes again.  "Oh, that's annoying!"  And then you
just find yourself not able to ever sync the main chain and join the network
properly as a fully validating node.

**Mike Schmidt**: So, does the attack have to be repeatedly executed against
that victim in order to keep crashing them, or is there some state that is
achieved once and then just can't get out of it?

**Gloria Zhao**: You know, that's a good question.  I would have to look at the
code for that.  I'm not sure.  Sorry, when you say 'state', as in like when I
reload the node, will it crash again immediately or somebody has to send me the
chain?

**Mike Schmidt**: Yes, right.

**Gloria Zhao**: So, yes, I don't know the answer to the question, I'm sorry,
but we can look it up and probably if you ask on Stack, or maybe there already
is a Stack Exchange question for this, I just would have to look at the code and
I don't have it in front of me right now.  Sorry.

**Mike Schmidt**: Sure.  Is it only nodes in Initial Block Download (IBD) that
are vulnerable to this attack, or let's say I turn off my node for a few days
and I come back on, am I also vulnerable to this attack?

**Gloria Zhao**: No, once you have the most-work chain, like you've already
synced, then you're not going to go and download less work blocks or chains, do
you know what I'm saying?  If you've already found the main chain, then you
don't have this problem.

**Mike Schmidt**: Okay, so even if I'm offline for some period of time and I'm
not sure what the latest is, even weeks or months, I have that history, at least
of a few months ago, is serving quasi as my checkpoint in your explanation
earlier?

**Gloria Zhao**: Right, yeah.  So, you have the equivalent of like a modern-day
checkpoint, because you've already determined what you think the most-work block
at that height is.  The checkpoints are there for when you don't know yet.

**Mike Schmidt**: Folks may think, "Okay, well if this header chain gets too
big, just start writing it to disk", or something like that.  How do you think
about that approach?

**Gloria Zhao**: I mean, you can run out of disk space too.  Let me think.  It's
been a while since I reviewed this PR.  But I can talk about the approach that
the PR takes to reset, if that's preferable.  So, like I mentioned before, we
have this Headers Presync, so not the block data, but just the 80-byte block
headers.  But in this case, the gist of it is we could be downloading lots of
headers, but we don't really know where it's going.  And so, the new approach
taken by this PR is to basically download in two passes, where in the first pass
we store commitments to extremely, extremely small, like 1 bit for every few
hundred blocks; block headers, to be exact.  And so, in the first pass, you're
like, "All right, cool, you're telling me this chain, and I'm kind of dropping
all the headers as you're telling me about them because I just want to see where
this is going".  And then, when you get to what seems like today's most work,
like the end of the chain, the tip of the chain, then I'm like, "Okay, cool.  I
know where that's going, so I'm going to download them from you again, and this
time I'm actually going to commit them to memory/disk".

In the beginning you've stored, again, 1 bit for every I think it's 500 or so
headers, so you're only storing a really, really tiny amount.  And you do that
so that you can remember the second time that they're serving you the same chain
that they did the first time.  That's the approach in the PR.

**Mike Schmidt**: That makes sense.  We made a reference to that in Newsletter
#216, the Headers Presync approach, but then there was also this note in the
newsletter about a bug that Niklas discovered in that logic.  Are you familiar
to be able to speak to that?

**Gloria Zhao**: Kind of not really.  I haven't looked at the details, but
essentially the thinking there was a lot of people don't really like checkpoints
philosophically because just on principle, the idea that you have effectively a
piece of consensus logic that is hard-coded by developers is kind of icky.
That's not how we want consensus rules to be written.  And so they're like,
"Okay, can we get rid of checkpoints?"  And so, they thought about it, but then
I think this was a few months after the presync logic was merged, Niklas found a
bug where essentially we were dropping a return value.  And so, I think it was
something to do with the end bits of the last header in the headers message,
which would contain a few thousand.  There was an edge case where it could
return false.  In that case, we really shouldn't be storing this header.  And
so, in this special edge case, if somebody sent you a list of headers that had
this particular thing, it could bypass the presyncing logic and it would go
directly to being stored.

So, it was like, "Whoa, that was a close call".  They fixed the bug and this all
happened I think before the release was cut.  But they're like, "Whoa, maybe we
should keep the checkpoints in for just a little bit of time, because that would
have been pretty bad if somebody found this bug before it was patched".  And so,
yeah, today on master, the checkpoints are still there.  But we're not adding
new ones.  Yeah, sorry.

**Mike Schmidt**: We had a Stack Exchange question, I think it was last month,
which was, "Hey, it's 2024, why do we have checkpoints in the code?"  And, yeah,
I don't remember who answered it, but it was something along the lines of,
there's no known attacks that the checkpoints are preventing, mitigating
against, but it's this class of unknown attacks.

**Gloria Zhao**: Exactly.  It feels like it's belt and suspenders, right?  Just
in case there's another bug like that, it might be nice to have.  Again, the
last checkpoint was more than ten years ago, and we're not adding any new ones.
I think people would be very against adding new checkpoints.

**Mike Schmidt**: Yes.  Technically, I guess you could be updating that
checkpoint every release, and that would be a way to sort of mitigate against
this kind of attack, but philosophically, that's not the route that the
community or developers philosophically would want to go.

**Gloria Zhao**: Yeah, exactly.  I wondered when I was reading up here, "How do
other chains do it?"  And it's, yeah, like signatures on trusted blocks usually,
equivalent to checkpoints.

**Mike Schmidt**: Yeah, I remember in years past, chains that especially were
deeply reorg'd would start doing checkpointing quite frequently to prevent
against that.  Jon anything to add?

**Jon Atack**: Well this has brought back an anecdote from 2017.  I remember
this reminds me, these out-of-memory things scare us I think fairly deeply.  I
remember at the Breaking Bitcoin in September 2017, a developer actually went up
on stage and revealed an out-of-memory bug on stage at the conference.  He
literally broke Bitcoin in front of everybody, and pretty much shocked the whole
room, and of course was fairly roundly condemned for not disclosing responsibly
his bug.  But yes, these things are scary.

**Mike Schmidt**: Gloria, thanks for joining us.  We do have some interesting
Bitcoin Core-related Stack Exchange items if you want to stick on.  Otherwise,
we realize if you have other things to do.

**Gloria Zhao**: Thanks.  I'll have to go soon, but I'll stick around for a
little bit.  Thank you.

_Hybrid jamming mitigation testing and changes_

**Mike Schmidt**: Next item from the newsletter in the News section is titled,
"Hybrid jamming mitigation testing and changes".  And this was motivated by a
Delving Bitcoin post from Carla Kirk-Cohen.  She posted a post titled, "Hybrid
Jamming Mitigation: Results and Updates".  And I think it makes sense maybe to
set some context here before going further, maybe talk a little bit about what
is channel jamming.  So, channel jamming is a class of DoS attacks against the
LN, where an attacker attempts to exhaust one of two resources on the victim
node or nodes.  One is the liquidity in the channel.  So, they can exhaust that
liquidity by sending a large amount of satoshis to themselves, for example,
potentially across many channels, but it all goes to themselves; and instead of
receiving their own payment, they can either delay or reject that payment after
a period of time, and effectively that locks all the channel's involved funds
for that period of time.  And then after that delay or rejection of that
payment, they could just get a refund.  So, the attack is essentially free.  So,
that's the liquidity side of things.

Then there's also the second resource that can be exhausted, which is the
Lightning node's Hash Time Locked Contract (HTLC) slots.  Each channel can have
843 pending payments in a single channel.  So, an attacker could potentially
send 843 very small payments through a series of channels, similar to what we
outlined above with the large transaction or the large payment, and that could
potentially jam, depending on how many channels are involved, 10,000 slots.
Again, filling those slots can be done without paying any fees.  So, those
resources can be attacked or jammed, as the term is here.  Two different
approaches would be fast or slow jamming.  Fast jamming would be a constant
stream of quickly failing payments that's sent to the victim node continuously
to consume their resources.  And that kind of attack can be difficult to
distinguish from the expected rate of payments through the network; it's a
little harder to identify.  And then there's slow jamming, which is an attack of
slow failing payments that are sent to the victim node, and then they're held up
to expiry and then failed right before the channel goes to chain.  Those
payments are easier to identify, because that's not really how the LN behaves
typically.

So, we have this fast jamming/slow jamming, we have these two resources that
we're trying to protect against.  So, channel jamming is bad.  So, we have these
Lightning researchers that have dedicated their time to work on a bunch of
mitigations.  I was going to reference a few of them that we've covered in
Optech, but there's actually so many that it makes sense to just point to the
Channel Jamming Attacks topic on the Optech wiki for references to all these
different discussions.  So, check out that reference and you'll see all of the
progressive research that has been done over the years.

So, Carla and Clara have spearheaded one approach to mitigating these channel
jamming attacks.  Their approach is a hybrid approach involving two components.
There's a reputation-based system that can mitigate the slow jamming attacks
that I described; and then there's a monetary or fee-based mitigation for the
fast-jamming class of attacks.  We summarize in the newsletter that it is
essentially, "A combination of HTLC endorsement and a small upfront fee".  So,
that's their approach, and I think they've published some research on that over
the last year.  But earlier this year, they actually wanted to test that
approach.  So, they conducted what they call an attack-a-thon, where they
invited other Lightning devs to try to break that hybrid implementation.  And
that gets us to this Delving post that we covered in the newsletter, which gets
into a lot of the details of the attack attempts during this attack-a-thon.  I'm
not going to get into all that here, but I would invite you to review the
Delving post for all the interesting details.  We summarize in the newsletter
that most of the attacks failed, and the definition of failure in this
attack-a-thon was that the attacker spent more to attack than other types of
attacks that are known; or the victim node actually made more money during the
attack than they would have normally made during normal Lightning operations.

One attack was successful that we noted.  This was the sink attack, where the
attacker tries to decrease the reputation of the victim node by creating a bunch
of shorter or cheaper paths on the network and, "Sabotaging payments forwarded
through its channels to decrease the reputation of all the nodes preceding it in
the route".  So, there was this one class of attack that wasn't addressed by
their hybrid channel mitigation approach, but to address this new sink attack,
Carla and Clara also introduced a new bidirectional reputation.  So, that means
a node will consider both the reputation of the incoming node as well as the
reputation of the outgoing node, when the node is considering whether to forward
something during its payment decision-making, or its forwarding decision-making,
I guess I should say.

So, the incoming node's reputation is calculated as they had outlined previously
in their original research.  What's added here is their approach to calculating
the outgoing node reputation.  And the post includes a deeper dive into a
variety of the considerations for the outgoing node reputation calculation and
consideration.  So, I'll leave the details to the listener to get into those
details.  But Carla and Clara are also planning additional experiments, maybe
another attack-a-thon, to ensure this bi-directional reputation approach that
they are working on also works as expected.  Jon, I don't know if you got a
chance to jump into this news item or have any comments.  We reached out to both
Carla and Clara, and of course, Murch knows a bit about it, working with those
folks at Chaincode, but everybody is out of town or busy.  So, that's my
summary.

**Jon Atack**: Yes, indeed.  I actually thought that was the most interesting,
personally to me, part of the newsletter, perhaps in part because I don't follow
the Lightning side of things nearly as closely.  But yes, it looks promising,
the bidirectional reputation.  It seems like a more comprehensive way to
calculate the reputation, but I'm looking at this at a surface level a bit from
the outside.  It looks good to me from what I can see.  Certainly, I think it
makes sense that it was the longest section of the newsletter, because I
definitely found it the most interesting.  Though client-side validation,
fielded by Jonas, looks interesting as well.  So, perhaps that's a good segue.

_Shielded client-side validation (CSV)_

**Mike Schmidt**: Yeah, that's a good segue.  Jonas, you, Liam Eagen, and Robin
Linus posted to the Bitcoin-Dev mailing list about a paper you all worked on
about a new client-side validation protocol called Shielded CSV.  We can take
this any direction you want to set the context for listeners, but I thought
based on some of the comments on Twitter, maybe it would be interesting for you
to speak a bit about how your thinking of client-side validation has evolved
over time, and then maybe you can get into Shielded CSV as part of that.

**Jonas Nick**: Yeah, okay.  That is one way of doing it.  I would have planned
to start with a summary, but we can start --

**Mike Schmidt**: Do it.  Yeah, go ahead.

**Jonas Nick**: Okay.

**Mike Schmidt**: Whatever route you think is best.

**Jonas Nick**: Yeah, because I tend to give the totally bird's-eye view, and
then people usually get lost.  So, my attempt at a summary of the protocol.  So,
we can describe Shielded CSV as a transaction protocol to create a layer 1 on
top of a blockchain, for example Bitcoin.  And that blockchain, the requirement
we have for that blockchain is that it allows to embed arbitrary data.  If we
have such a blockchain then we can use Shielded CSV to create a layer 1, by
which we mean a system whereby we can transfer a cryptocurrency or IOUs, spare
tokens, assets, etc.  A property of this layer 1 is that it inherits the
double-spend security from the underlying blockchain, for example Bitcoin, and
all the other security we care about, like can we actually spend the coins, can
someone steal our coins, they depend on crypto assumptions for signatures, proof
systems, etc.

The data that we need to embed into the underlying blockchain is 64 bytes, and
that would be ignored by full nodes of Bitcoin.  And one crucial property of the
system is that the actual coins and what we call 'coin proofs' are sent directly
to the receiver of those coins through a one-way private communication channel.
So, we don't put those coins directly on the blockchain, otherwise we wouldn't
be able to get this 64-byte footprint.  The coin proofs that are sent to the
receiver are succinct, so they don't depend on the size of the transaction
graph, they have a constant size.  And this protocol is what we call 'fully
private', because it does not leak transaction history or anything about the
transactions themselves.  The receiver just receives a coin but cannot infer any
further information.

Why did we build this, why were we interested in this?  We think that this is a
more efficient design for private cryptocurrencies, a private cryptocurrency
like Monero, Zcash, because the zero-knowledge proofs, they are not part of the
blockchain and they are not verified by the full nodes of the blockchain; they
are just sent directly to the receivers of the coin.  But the more important
motivation for us was to improve the privacy of Bitcoin where we would use
Bitcoin as the underlying blockchain, and then we need some sort of bridging
mechanism between blockchain Bitcoin and Shielded CSV Bitcoin.  We don't
describe how to build such a bridging mechanism.  Ideally, it would be something
trust-minimized like BitVM, but it wouldn't be Bitcoin anymore, but you could
also conceive something like a one-way peg or a federated peg.  Any questions so
far?  Otherwise, my plan would be to basically give a strawman client-side
validation protocol, something that people might have in mind when they think of
client-side validation, and then go into a little bit how we were able to
improve on that traditional client-side validation model.

**Jon Atack**: Jonas, I did have one question I was meaning to ask you here.
So, the proposal described confirmation costs as being a 64-byte update and that
the cost of validation is fixed.  But I didn't see an order-of-magnitude idea, a
general idea of what that validation cost would actually be apart from being
fixed, which is a great advantage.  What kind of size or cost are we talking
about?

**Jonas Nick**: So, for the nodes of the system, what they do is they have a
data structure that they maintain that we call the 'nullifier accumulator', and
that is roughly equivalent to a UTXO set, because we don't use bitcoin
transactions or the UTXO set.  Nodes in Shielded CSV, they have a separate data
structure.  We call it the nullifier accumulator.  To maintain this nullifier
accumulator, nodes scan through the blockchain, search for these nullifiers,
which are these 64 bytes.  This 64-byte array that is written to the blockchain,
we call it a nullifier.  And they verify this nullifier, but the verification is
just essentially a single schnorr signature verification.  So, for every
nullifier full nodes of Shielded CSV encounter in the blockchain, they do a
single schnorr signature validation, and if it passes, they need to put it into
this nullifier accumulator data structure.  And on top of that, if we build
Shielded CSV on Bitcoin, they also need to verify the Bitcoin consensus rules to
be sure that they actually have the best Bitcoin blockchain.

**Jon Atack**: Okay, so if I understand correctly, aside from the cost to scan
and validate the blockchain of Bitcoin itself, which will grow with time, it's
fixed to the cost of verifying one schnorr signature?

**Jonas Nick**: Yes, for the nodes of the system.  And there is additional
computation required by receivers of coins, or of payments, because they need to
verify what we call 'coin proof'.  And this is a more expensive verification
that depends on the specific succinct zero-knowledge-proof system that you would
want to use for Shielded CSV.  But it is not dependent on the size of the
transaction graph, it is essentially constant.

**Jon Atack**: Thank you, Jonas.

**Mike Schmidt**: Do you want to go through your strawman?

**Jonas Nick**: Yeah, all right.  So, my strawman client-side validation
protocol is essentially some version of colored coins.  We create a colored coin
-- I had a good name for a colored coin.  Let me check what ChatGPT suggested.
Docoin or Frogecoin.  I think both are good.  All right, let's go with Docoin.
So, we have some issuer creating, let's say, 100 docoins.  They do that by
saying, "This particular bitcoin output, which has not been spent, now
represents 100 docoins".  This bitcoin output may just contain 1 sat, it doesn't
matter what bitcoin amount is actually in that output, it just says, "This is
100 docoins".  Okay, so if they want to spend those 100 docoins, they make a
bitcoin transaction.  And in that bitcoin transaction, they also commit somehow
to this sort of new balance of outputs.  So, they make a bitcoin transaction,
which again has some outputs with arbitrary amounts essentially in the outputs,
but they also commit to a specific balance of docoins.  So, I don't know, 20
docoins go to the receiver and 80 docoins change.

So, the receiver sees this transaction and he just sees I received, let's say,
one bitcoin sat.  So, there's an additional step that needs to happen offchain,
which is that the sender of the payment needs to send what we call the proof to
the receiver, and that essentially enriches the transaction graph that we have
on Bitcoin saying, "Okay, so we sent 20 docoins to you and 80 docoins were
change, which means that the sender essentially needs to send the whole
transaction graph connecting the transaction to the receiver to some issuance
transaction.  And the receiver will check this enriched transaction graph, will
check, "Okay, there are no docoins have been created out of thin air and
everything checks out, the additional commitment signatures, etc".  So, this is
basically how many of the client-side validation protocols in general work.  You
have bitcoin transactions and you have these offchain components sending proofs
directly to the receiver.

The client-side validation model is much more powerful than that.  So, already
in 2013, Peter Todd basically realized that.  I wasn't aware of this for, I
don't know, I only learned about it last year.  Because the client-side
validation approach is much more general, essentially it means that in our
blockchain system, we can entirely remove the transaction validation rules from
the consensus rules.  Why are the transaction validation rules part of
consensus?  Peter Todd says, in 2013, this is just an optimization, because
blocks can just contain arbitrary data.  And when nodes receive the arbitrary
data, they can just locally, client-side, interpret them as transactions.  And
if they are not able to interpret them as valid transactions, then they just
ignore these transactions.  So, they don't care about it, they don't put them
into their data structure, UTXO set, nullifier accumulator, or whatever.

Using this insight, we can come to the conclusion that we don't actually need to
write full transactions into the blockchain but rather we can just derive short
pieces of data from transactions that we call nullifiers, and we put those
nullifiers into the blockchain just to prevent double spending.  But the
transactions themselves, we can send them to the receiver.  So this is kind of
the framework we're using to build the Shielded CSV protocol.  Yeah, I think
this is the main idea to get to the 64-byte nullifiers.  And then the other
question is, how do we get these short, succinct coin proofs and the privacy?
And the answer to this can be explained much simpler, which is just essentially,
the easiest way to say this, apply recursive SNARKs, so Succinct Non-interactive
Arguments of Knowledge, to the coin proof, such that the coin proof is just
something that proves there exists a transaction graph that connects this coin
to a bunch of valid issuance outputs, but you don't reveal the transaction
graph, you just prove it exists, there are no double spends, etc.  You use a
zk-SNARK so you get this privacy from the zero-knowledge property of this proof
system.

But in the paper, we use a different abstraction than these zk-SNARKs that is
called 'PCD', Proof-Carrying Data, but I don't think the details are relevant.
Maybe what is relevant is that you can build PCD from other constructions than
just recursive zk-SNARKs, for example folding, people have heard of that.  And
so, yeah, we have this paper, it is built on a bunch of primitives that we don't
instantiate.  So, we just assume we have some PCD mechanism, proof-carrying data
mechanism, it has these properties; we assume that we have nullifier
accumulators, they have yet other properties; and using that, we built a
specification that we wrote in Rust that builds on these abstract primitives
such that, so everyone knows this zero-knowledge proof system space is
developing very, very quickly.  And essentially, the Shielded CSV is independent
of that because you can use whatever concrete instantiations are best at the
time to actually build this protocol.

**Mike Schmidt**: Jonas, would you mind elaborating on something for me, this
interplay, or potential interplay I guess I should say, between something like a
Shielded CSV and BitVM?

**Jonas Nick**: Yes, so Shielded CSV, as I tried to make clear, is sort of a
separate system from Bitcoin whatever blockchain it uses, so you need some way
to connect the two systems.  Otherwise, you can just issue Tether or something
on Shielded CSV.  But we don't, at least for us, the authors of the paper, this
is not a super-interesting use case.  We want to add privacy to Bitcoin.  So, in
order to achieve that, you need a bridge from Bitcoin to the Shielded CSV
protocol.  And the way you would implement that bridge is that you would, for
example, use a BitVM-based bridge.  And instead of giving a coin and coin proof
to the receiver and the receiver verifying coin and coin proof, you would give
coin and coin proof to the bridge, abstractly speaking, and the bridge would act
just like any other receiver and would do the same verification than a normal
receiver.  And if that verification passes, you get your coins that you've
withdrawn from Shielded CSV on the Bitcoin side again.

**Mike Schmidt**: Okay, all right, thank you for clarifying that.

**Jon Atack**: Do you have any plans to draft a BIP from this?

**Jonas Nick**: That is a good question.  So, I think it's too early and there
are also a lot of open questions.  And the question would be, what would the BIP
really specify?  I think maybe it's certainly a future path we could take,
trying to specify this more, but right now I think it's a little bit early to
put this into a BIP.  But now that I'm thinking about it more, maybe not.  But
important I think for a BIP would be that it's fully specified.  Also, these
abstract primitives that I mentioned, they need to be specified in order to
really have interoperable implementations.  And so, I think this is an open
research question, what are the actual instantiations that you would want to use
for such a system, because there are these various trade-offs?  Do you want to
use STARKs, or do you want to use folding based on bullet proofs or something
else?  So, a lot of open questions still.

But there is one thing, one BIP that we already depend on that is not yet in the
BIPs repository, or hasn't even been suggested for the BIPs repository, which is
schnorr signature half aggregation.  So, we depend on that to actually create
these 64-byte nullifiers.  So, maybe that would be an intermediate step, a small
one, but it would be a step.

**Mike Schmidt**: What has feedback been so far on the paper?

**Jonas Nick**: I think the feedback has been very positive.  There are
certainly some drawbacks of this model.  Maybe I should mention those as well,
that people have already mentioned.  In particular, what may be most relevant to
end users is this sort of problem that you need to send coin and coin proof
directly to the receiver through some anonymous communication mechanism.  In
Bitcoin, we don't need that because we have all the data on the blockchain, all
nodes download the data, so that is essentially an anonymous communication
channel; whereas in these client-side validation models, we need to send
something directly to the receiver.  And especially if you want to have it
private, then we have this additional problem of somehow making it anonymous.

If we meet in physical space in real life, then sending coin and coin proof is
just scanning a QR code or a video of QR codes, or something like that.  But if
the receiver is not online and I can't reach them directly, then I need to
somehow put coin and coin proof to some server, and the receiver needs to have a
privacy-preserving way of getting coin and coin proof from the server once the
receiver goes online.  We go into those problems a little bit in the discussions
section of the paper.  So, this is sort of a trade-off that you get by
client-side validation.  But some people were super-excited.  Someone even
mentioned on the mailing list that this is a good case for adding a
zero-knowledge-proof verifier opcode to Bitcoin's consensus in order to build a
proper bridge that does not rely on BitVM.  I think it's a bit too early for
that, but certainly an interesting response.

**Mike Schmidt**: Jonas, thanks for joining us.  Any parting words for the
audience and how they can get involved, other than reading and providing
feedback on the paper?

**Jonas Nick**: Yeah, I think right now, the main thing to do is just read the
paper and if you want to leave feedback, then Bitcoin mailing list would be an
example.  I opened the thread there.

**Mike Schmidt**: Excellent.  Thanks again for joining us, it's
super-interesting.  Jon, did you have one more point?

**Jon Atack**: Yeah, Jonas, I'm looking forward to reading your BIP draft on
this.

**Jonas Nick**: Okay!

**Jon Atack**: The anonymity and privacy implications are really compelling
here.  Congratulations on that.

**Jonas Nick**: Cool, thanks.

_Draft of updated BIP process_

**Mike Schmidt**: Well, speaking of BIPs, our last news item this week is
titled, "Draft of updated BIP process".  And unfortunately, Murch is not here to
cover his own mailing list post to the Bitcoin-Dev mailing list to announce the
PR of the draft BIP.  But we have another BIP maintainer here.  Jon, do you want
to drive discussion here?

**Jon Atack**: Sure.  So, yes -- oh, my computer is beeping a lot, sorry.  There
have been concerns in the past about the limitations of the current BIP2, which
describes the process and roles of the BIP editors and how the BIPs' workflow
and process take place, and it is about a decade old, I believe.  So, Murch
valiantly proposed to rework it and to modernize it and to take into account
some of the...  The idea is basically to clarify some aspects and simplify
things that can be simplified, and maybe drop some things that didn't actually
see adoption as expected back then when BIP2 was ratified, the comments system
being sunsetted, the workflow being reworked.  I think the two main things in my
eyes are simplifying the statuses, because there are currently nine and the idea
is to basically drop that down to four statuses of, say, Draft, Proposed,
Active, and then Abandoned replacing the other five; Draft, Proposed and Active,
yes.

The other thing really, I think the only part that really has affected me since
taking on the role in late April is the question of the scope of the BIPs
repository.  We've had a few discussions that were relatively, well, we didn't
come to agreement, even amongst the editors, particularly regarding the scope
for things like, is policy in scope?  Is policy research and development
documentation in scope for the BIPs repository?  And things like, say, ordinals
and inscriptions, and so on.  I would say the ordinals one is, to my knowledge,
the only unresolved case of scope.  And we still have to come to some sort of
consensus on what is in scope for the BIPs repository.  Ruben wrote a research
paper actually that went into that; a research paper, I'm exaggerating.  He
wrote a long gist, but a quite developed one, where he suggests, for example,
drawing a line at consensus protocols that involve tokens would be considered
off-topic.  So, there's a discussion that's ongoing.  I think the scope is the
most difficult part.

I personally haven't felt terribly annoyed at the current BIP2, but it does
leave some leeway for the editors to have to make value judgments, then that's
probably where the new process, in my eyes, would add the most value.  Anyway,
review has been ongoing, first privately and now publicly, and I encourage
anyone who has input and would like to review it to do so.  I don't know if
there are any questions.

**Mike Schmidt**: It seems like it's definitely generated a lot of discussion.
I see hundreds of different comments on the PR.  It sounds like you've distilled
some of the back and forth into a few different important items for the
listeners.  Yeah.

**Jon Atack**: Yeah, I think Merck's two mailing list posts describe very well
-- the last one was two weeks ago -- they summarize very well the ideas behind
the changes.  Now, the one that's two weeks ago, he's updated his proposal since
then, but it's more or less apart from, I think, status namings.  He proposed
Preliminary, Ready, Active, and I think it's now Draft, Proposed, Active, which
I prefer, because it's much more similar to what we have now and involves fewer
switching costs; it's easier to switch over to the new one.  Yeah, I think the
main review at this point is hammering out and polishing the PR to get it into
some sort of ready in shape for final review and maybe merge.  And I suppose
scope hasn't attracted too much bikeshedding yet, to my surprise.  I don't know
how much -- there's a continuum between BIP editor judgment and making it very
clear with formal criteria what is not in scope, which I think might be
difficult to do.  But I don't know.

**Mike Schmidt**: Well, if you're interested in these BIP process updates, check
out the newsletter, which we link to the discussion and the PR.  And there's
also the Bitcoin-Dev mailing list post that Murch put out.

**Jon Atack**: Yeah, I think that's it for that topic.  Do you want to cover the
Stack Exchange?

**Mike Schmidt**: Let's do it, all right.  So, this week we highlighted our
monthly segment on Selected Q&A from the Bitcoin Stack Exchange.  We thought
there were six interesting ones this month.

_What specific verifications are done on a fresh Bitcoin TX and in what order?_

First one, "What specific verifications are done on a fresh Bitcoin TX and in
what order?"  And Murch answered this question, and he lists what he says is,
"Just a quick rundown" of checks performed on transactions when they are
submitted to the mempool.  His quick rundown, he lists a couple of dozen checks
on transactions across a variety of methods in Bitcoin Core, including things
like transaction size, no duplicate inputs, mature coinbase inputs, and 20 or so
other checks that are done across a few different methods, CheckTransaction,
PreChecks, and AcceptSingleTransactions and their related functions.  John, I
don't know if you've splunked into these sort of checks, or have anything to add
there?

**Jon Atack**: It's certainly one of the most interesting parts of the Bitcoin
codebase, and I encourage any new Bitcoin developer to review and look through
that code and get familiar with it.  No, I don't have anything particular to
add.  Yeah, those look about right, those look very good.

_Why is my bitcoin directory larger than my pruning data limit setting?_

**Mike Schmidt**: Great.  Second question from the Stack Exchange, "Why is my
bitcoin directory larger than my pruning data limit setting?"  And that actually
isn't the exact question verbatim, but that's what I took away from the
question, so I sort of paraphrase that question here.  And Pieter Wuille
answered and he noted that, essentially the confusion here is that the prune
option limits the size of Bitcoin Core's blockchain data, but not the size of
the Bitcoin directory itself, which can include other things like optional
indexes, mempool backup files, the chainstate, wallet files, and other files.
Those are not included in the prune option limit and they grow independent of
that prune size.

**Jon Atack**: Large wallet files are interesting because, for example, I
believe that very large industrial wallets don't use Bitcoin core wallets
because they don't scale well to hundreds of millions in size of bytes, and
things just sort of slow down radically.  And I believe Andrew Chow in the past
has made proposals to speed those up.  But for now, I think if instagibbs is
still listening, I think that my understanding is the industrial players use
their own internal wallets instead.  But anyway, that's an aside.

**Mike Schmidt**: Hey, Chris, I saw you requested speaker access.  If I was
delayed in getting to you, I just saw it now.  Did you have a question or
comment?

**Chris Guida**: No worries, yeah, I just put my hand up just now.  I was going
to comment that if you prune your blockchain to 550 MB, your directory is still
going to be like 12 GB, and most of that is going to be the chainstate, it's
going to be the UTXO set which, fun fact, used to be like 4 GB a couple of years
ago.

**Mike Schmidt**: Yeah, thanks for clarifying.  That's a good example of it.  I
think the answer elaborates on that a bit as well.  Chris, why is the chainstate
so large?

**Chris Guida**: So, mostly because of the BRC-20 spam attack that happened from
about February -- well, let's see.  I guess ordinals sort of started in February
of 2023, and then BRC-20, I think, started shortly after that.  And most of
those transactions, they just have this JSON blob that gets stored in
inscription, and that goes into the UTXO set and never gets eliminated from the
UTXO set, because those are never spent.

_What do I need to have set up to have `getblocktemplate` work?_

**Mike Schmidt**: Next question from the Stack Exchange, there's actually two
related questions here.  The one that we highlighted was, "What do I need to
have set up to have getblocktemplate work?" so getblocktemplate being Bitcoin
Core's method for generating a candidate block based on mempool and other
factors.  This user, CoinZwischenzug, also asked a related question about how to
calculate the merkle root and coinbase transaction for a block.  It looks like
this user's potentially trying to play with some mining operation and is trying
to get certain data from Bitcoin Core.

Essentially the answer to both of this user's questions around mining is that,
yes, Bitcoin Core can give you some information about a candidate block, but
typically the coinbase and merkle root and other things are supplemented by
having some sort of mining or mining pool software to sort of fill in the gaps,
since Bitcoin Core is not necessarily a mining software anymore, a lot of that
software is spun out by the coinbase.  Jon, any comments?

**Jon Atack**: Yeah, when you type in RPC in it and you're not sure what the
inputs are, simply precede it with help, and you get usually a very detailed, in
this case very detailed documentation, though it doesn't necessarily describe
the relationship between exterior miners and RPC.  But it tells you in very
great detail what you need to provide and what you get back.

_Can a silent payment address body be brute forced?_

**Mike Schmidt**: "Can a silent payment address body be brute forced?"  I think
there was potentially a bit of misunderstanding in the person asking this
question.  They sort of referenced, maybe I'll quote them, "Can sender generate
all 4 billion addresses of the private key, destroying privacy?"  And I think
that thought was that given a silent payment address, that they could somehow
brute force these 4 billion addresses and find information about a user's silent
payment transactions.  Josie, who answered this question, points out that he
believes that that 4 billion number is something that the person asking the
question got from BIP32 wallets.  In the BIP32 wallets, I think there's some
reference to a 4 billion, the ability to generate 4 billion addresses from a
BIP32 wallet receive addresses, but that is not related at all to the process of
generating a silent payments address.  And Josie goes through a summary of
generating a silent payment address and silent payment code.  All of the details
are documented in BIP352.  I don't think we need to go through all of those
steps here.  I think it was maybe a bit of a misunderstanding that you could
somehow degrade silent payments privacy by doing some sort of brute force or
grinding attack to compromise the privacy benefits.  Anything to add, Jon?

**Jon Atack**: No.

_Why does a tx fail `testmempoolaccept` BIP125 replacement but is accepted by `submitpackage`?_

**Mike Schmidt**: Well, this particular question, I was hoping Gloria would
still be on, but the question is, "Why does a tx fail testmempoolaccept for
BIP125 replacement reasons, but is accepted by submitpackage?"  And this is a
question asked by somebody who's going through the Bitcoin Core 28.0 Testing
Guide, and looked at some of the output from some of the commands in that
Testing Guide for 28.0, and was confused why one of the testmempoolaccept failed
one of the checks, but submitpackage evaluated and it was accepted.  Ava Chow
pointed out that the testmempoolaccept RPC only evaluates transactions
individually with no other context.  And as a result, the example from the
Testing Guide, which was using RBF BIP125, failed because one of those RBF
checks failed within the context of that one transaction.  However, if you take
the context of a package, which is the relation of one transaction to another in
a parent-child relationship, it takes the context of that parent-child
relationship as a package, and therefore the BIP125 rule is fulfilled and the
package of transactions is accepted.

So, there's a different scope of the test of testmempoolaccept versus submitting
the package.  Jon, any thoughts on packages or testmempoolaccept or BIP125
replacements?

**Jon Atack**: Yeah, so testmempoolaccept is, I believe, a long-standing RPC,
whereas submitpackage is a newer experimental RPC.  The documentation for it
indeed says, "This RPC is experimental and the interface may be unstable".
Refer to doc/policy/packages.md for documentation on package policies.  So, it's
not entirely astonishing.  And, yeah, that's why these are marked as
experimental and they can change.  Software clients shouldn't rely on them yet.

_How does the ban score algorithm calculate a ban score for a peer?_

**Mike Schmidt**: Last question from the Stack Exchange, "How does the ban score
algorithm calculate a ban score for a peer?"  And Bruno answered this question,
he referenced Bitcoin Core #29575, which was a PR that we covered in Newsletter
#309, so somewhat recently.  And that PR simplified the misbehaving scoring
system, or the ban scoring system, and it really simplified things into two
increments: 100 points, and it changed the sort of ding that you would get by
being a misbehaving peer; and then also reduced a variety of the other criteria
to 0.  And so, there's a list that he provides in his answer here of the
different scoring, because it used to be a bunch of smaller increments, and if
you tripped a certain threshold, you would be disconnected.  And a lot of the
more egregious ones were simplified to just go to 100 and result in a
disconnection; whereas other ones that could result from normal operation were
moved to 0.

If you're curious about that list, check out that that PR and also Bruno's
summary of this particular answer in the Stack Exchange.  Jon, you ever mess
around with the ban score or the behavior calculation scores in Bitcoin Core?

**Jon Atack**: Yes, there was a discussion maybe a couple of years ago, the idea
was brought up I believe by Pieter Wuille, to remove ban score entirely.  And
I'm not quite sure if that's actually been done or not, but the idea was to
track the resources that a peer, on a per-peer basis, to track and calculate the
resources that a peer connection was costing your node, and then to use that as
a basis for disconnection, which would solve a lot of things, and to remove the
whole ban score entirely.  I'm not quite sure what the status of that is.  I
need to catch up on that area, on that topic.

**Mike Schmidt**: Yeah, this was also sipa's PR, this #29575, which sort of
recalibrated the misbehavior scoring and set a bunch of maybe more egregious
things to 100, which would result in that disconnection; and then, there were
two that were set to 0 that were maybe unavoidable types of behavior that
shouldn't be penalized.  So, check out that list, check out that PR if you all
are curious about how you score your peers.

_BDK 1.0.0-beta.4_

Releases and release candidates.  We have two that have been on here for the
last few weeks, so I don't think we need to jump into them.  The BDK
1.0.0-beta.4 release with the re-architecture of BDK into these separate crates.
We've also covered some BDK PRs over the last few weeks.  Maybe that'll make it
into the beta.5, maybe not, we'll see.

_Bitcoin Core 28.0rc2_

And then we have Bitcoin Core 28.0rc2, which we've talked about a bit.  Jon, I'm
curious, maybe not, you're free to opine obviously on the RC, but I'm curious
how you approach, as someone who does a lot of testing, how do you approach
testing a release candidate?

**Jon Atack**: So, just to jump back, I was grepping the code based on master
and, wow, the ban score field was actually removed in v22 from getpeerinfo.  So,
yeah, it's been simplified and deprecated and removed apparently.

Sorry, release testing.  Well, I mean I'm in an unusual position.  I pretty much
only run either master or I compile a PR branch.  So, I'm constantly rebuilding
Bitcoin Core and trying it in different ways.  And whatever I come across, yeah,
I'm looking for whatever isn't working.  Release testing, there's so many things
you can try.  I'm not too sure how many people actually really test RCs.  I fear
it's not a great number.  I could be wrong, I hope I am, but people come across
things in their ordinary use of Bitcoin Core and hopefully report them when they
open issues, and ideally during the RC process and not after a release.  There
is a Testing Guide as you mentioned.  I'm sorry, I haven't looked through it
yet.

**Mike Schmidt**: Yeah, we've encouraged folks in the past, who are curious, of
playing around with the RCs.  Obviously, the testing guide is a nice way to get
you playing with some of the new features and become aware of changes to the
software and ways to test it.  But if everybody followed the Testing Guide
exactly, you'd exactly get the output from the Testing Guide, which isn't
necessarily super-helpful, although testing on a variety of machines is helpful.
So, we've always encouraged folks as well, you know, download the RC and, yeah,
mess with the Testing Guide, sure; but also, use the software as you would
normally be using it and use the features that you normally use that you're
familiar with, and you would know if something is amiss.

**Jon Atack**: I actually have some skin in the game on this.  Since about, I
don't know, six or seven years now, I continually run Bitcoin Core, whatever I'm
testing version of it, usually master, or PR branch rebased to master.  I always
rebase to master to test a PR, so master plus whatever changes I'm testing on a
PR.  I actually use live funds.  I have some amounts on my laptop and I'm
messing with skin in the game, not necessarily a giant amount, but yeah,
definitely I'm using it with real money.  I know that's not advice!

**Mike Schmidt**: Yeah, I would say that we...

**Jon Atack**: I reckon it's my job, so I do that!

**Mike Schmidt**: Optech does not endorse such an approach for listeners!

**Jon Atack**: Not at all, no!

_Eclair #2909_

**Mike Schmidt**: All right, Notable code and documentation changes, we have
three this week.  Eclair #2909, and this actually fixes a bug with Eclair where
it would not be possible to add route hints when creating an invoice if you were
running an Eclair node with only private or unannounced channels.  So, as a
result, the user could not receive any payments.  The fix in this PR was to
allow route hints when creating a BOLT11 invoice.  So, that involves changes in
this PR to the createinvoice API that now takes an optional privateChannelIds
parameter, and you can use that then to add route hints through private
channels.  I want to say that there was a warning, I didn't put it in my notes.
Oh, I guess we put it in the writeup though.  There's some privacy implications,
so you should use scid_alias if you're concerned about privacy there, which you
should be.

_LND #9095 and LND #9072_

LND #9095 and LND #9072 are parts 3 and 4 respectively of LND's custom channels
project.  And LND's custom channels project enhances LND's support for the
taproot assets protocol, that is also something that they've done a lot of work
on, for issuing tokens on Bitcoin and transferring them using the LN.  Part 3
and 4 add support in the RPC and CLI, channel funding and closing changes, and
changes to LND's invoice HTLC modifier, all in the vein of this custom channels
project.  I don't have anything else to add there.

_LND #8044_

Last PR this week, LND #8044.  This is a PR titled, "Lnwire: add new Gossip 1.75
messages".  As a reminder, Lightning nodes advertise their availability to
forward payments on the network using channel announcements to peers.  These
announcements are relayed through the Lightning gossip network, and right now
these announcements are using v1 gossip to spread over the network.  And Chris,
if you want to jump in at any point, being a Lightning guy, you're free to do
so.  The downsides of the current v1 gossip protocol that Lightning uses
currently is, there's two things: one, channels are announced using the specific
UTXO that the two channel parties control, which is bad for privacy; and also,
the v1 gossip protocol requires P2WSH UTXOs with a specific script.  So, anyone
using something different, like simple taproot channels, for example, is forced
to use unannounced channels.

As a result, we have a bunch of Lightning developers over the years that have
been working on improvements to the gossip protocol.  For example, we had t-bast
from the ACINQ team on in Podcast #261, where we covered the Lightning Summit, I
believe it was last year, where potential gossip changes were discussed.  There
were ideas around a v1.5 gossip, a v1.75 gossip, and a larger overhaul v2.0.
And it seems, coming out of that meeting, that the gossip v1.75 protocol had the
most support and is what some implementations are moving with.  Also LND is
moving forward with it, because that's what this PR is about.  So, this is LND's
first step towards gossip v1.75 support.  LND has a tracking issue for their
gossip v1.75 project, and that's issue #7961.  So, this is the first of many
changes required to support gossip v1.75.  Jon or Chris, any comments on that?

**Jon Atack**: Nope, not here.

**Chris Guida**: Yeah, unfortunately I haven't been following the spec meetings
that closely, but I do know they're working hard to try and rework gossip.  So,
yeah, just rooting for them.

**Mike Schmidt**: I forgot to solicit questions from the audience.  I didn't see
any in the thread or speaker requests, so I apologize for not soliciting
earlier, but I think we can wrap up.  Jon, any parting words you'd have for the
listeners?

**Jon Atack**: All good for me.  I think we've covered everything quite well.
I'm really keen to see more about this Shielded client-side validation from
Jonas.  Big boost of encouragement there.

**Mike Schmidt**: Yeah, it seems like there's a lot of good feedback so far.
So, kudos to you, Jonas.

**Jonas Nick**: Thanks, cool.  It's great to hear.

**Jon Atack**: I'm personally looking at trying to review the quantum resistance
BIP.  This has seen a resurgence of interest lately, with what appear to be more
perhaps concrete advances in the field, whereas it always seemed like something
that would maybe happen someday for sure, but not tomorrow.  So, I'm trying to
have a look at that BIP.  It involves a bit more math than most BIPs.

**Mike Schmidt**: Jonas, do you care to comment on quantum?

**Jonas Nick**: Yeah, it's easy.  You just need to understand elliptic curve
isogenies for that.

**Mike Schmidt**: Sounds pretty straightforward.

**Jonas Nick**: Right.

**Jon Atack**: I mean, yes, the main risk that's being evaluated is on the ECC
side of it.

**Mike Schmidt**: Well, I think we can wrap up.  Thank you to Jonas for joining
us and Gloria, and Chris for jumping in with some questions.  And thanks to our
special co-host this week, Jon Atack.  We'll see you all next week.  Cheers.

**Jonas Nick**: Bye, thank you.

**Jon Atack**: Bye everyone, cheers.

**Mike Schmidt**: Thanks guys.

{% include references.md %}
