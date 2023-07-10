---
title: 'Bitcoin Optech Newsletter #258 Recap Podcast'
permalink: /en/podcast/2023/07/06/
reference: /en/newsletters/2023/07/05/
name: 2023-07-06-recap
slug: 2023-07-06-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Gloria Zhao to discuss [Newsletter #258]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/73081824/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-6-6%2F338258267-44100-2-d9555c33c19e6.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #258 Recap on
Twitter Spaces.  It's Thursday, July 6th, and we will do some introductions and
then jump into the newsletter.  Mike Schmidt, contributor at Optech and
Executive Director at Brink funding Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch.  I work at Chaincode Labs on Bitcoin stuff.

**Mike Schmidt**: Gloria?

**Gloria Zhao**: Hi, I'm Gloria, I work on Bitcoin Core, sponsored by Brink.

_Waiting for confirmation #8: Policy as an Interface_

**Mike Schmidt**: We don't have any news items that we reported in this
Newsletter #258, but the silver lining to that is that we can jump right into
our Waiting for confirmation series, and we have a special guest and co-author
of the series, Gloria, here to talk about this.  We've been talking about how
node and network resources can be protected using policy rules that are a bit
more restrictive than Bitcoin's consensus rules.  And then in this post, Gloria,
you outlined why those policy rules are important to socialize to the broader
Bitcoin community, especially applications, second-layer protocols, and
contracting protocols.  Gloria, you can take this wherever you want, but maybe
you can explain a bit why socializing policy rules is important, and then maybe
we can get into some of the examples of Lightning transactions and adhering to
those standardness rules a bit.

**Gloria Zhao**: Yeah, for sure.  I think last week's talk, sorry, you can hear
the background noise!  Last week, somebody asked a question of, how easy is it
to change a policy rule in Bitcoin Core; can you just like unilaterally merge or
do something?  And the answer is of course no, because for example, if someone
is interpreting the inversion field a certain way or they're relying on it being
able to relay and then suddenly you make that non-standard, essentially you can
cause applications to no longer be able to use the network transaction relay to
get their transactions confirmed.  So that's very, very bad.  And so that's kind
of a baseline of, okay, we have an interface; the transaction relay policy is an
interface that we have to keep somewhat stable and be concerned about keeping
that way for the applications that use it and for applications that may want to
use it in the future.

Then the other part of this post is talking about where those policies can
really get in the way, particularly if you have kind of security assumptions or
you really rely on things being able to confirm and being able to, say, connect
to the network and broadcast through the "normal mechanism", having it relay
through the network to a miner.  And so, this is kind of a generalized
statement, but let's say you're building an L2 protocol where you have a
contract where you have spending conditions enumerated between two untrusted
counterparties, and the idea is to keep things offchain until somebody tries to
cheat or something goes wrong and you can always go onchain, and hopefully the
security model is the same because you've already accounted for all of those
potential paths and committed to those spending conditions, and there is some
kind of timelock within which somebody can get their money back if the
counterparty tries to cheat them.

Now, of course, that kind of puts additional reliance or dependency on being
able to use transaction relay or being able to get something confirmed.  This
series is called Waiting for confirmation, and here we're introducing this idea
of, well, you really need to get something confirmed otherwise someone might run
away with your money.  And so pinning attacks, which is defined in this post, is
where someone is using some kind of imperfect heuristic or some kind of
limitation in policy that is the result of, for example, we tried to make a
trade-off between DoS and incentive compatibility, and we said, "Hey, we're just
the 26th transaction, that's a descendant of something unconfirmed".  We want to
limit that because of DoS reasons, but it could be an amazing CPFP, and it would
be incentive-compatible to accept that.  But we've made the trade-off where we
said, okay, after the 25th, we're not going to take it.  And we're like, "Oh,
okay, maybe it wasn't the right trade-off", or maybe that gets in the way of
someone being able to emergency CPFP a commitment transaction, for example.

So, how can we refine those trade-offs or refine these imperfect decisions that
are made in policy to enable use cases like, okay, in a shared transaction, we
should guarantee that at least two parties are always going to be able to CPFP
that transaction?  So that's what carve out is.  Yeah, that's kind of a summary
of the post.  Murch has his hand raised, so I'll pass the mic to you.

**Mark Erhardt**: Yeah, I wanted to get a little more into how the policy rules
are an interface between the expected behavior on the network and the needs of
the app layers/L2s.  You've already given some examples, but basically in the
past few posts, we've talked a lot about how we need to limit risk against DoS
vectors and how we need to protect local resources on computers, the individual
nodes that are participating in the network.  But on the other hand, of course,
we would love to give guarantees for transaction relay.

So, generally on the Bitcoin network, we do not have any guarantees for relaying
unconfirmed transactions.  We do have guarantees for block relay.  Everybody
needs to get new blocks, every node, but not everybody needs to get every
unconfirmed transaction.  And that is especially a problem for second-layer
protocols that have a limited time window in which they require a confirmation.
Otherwise, as Gloria said, the counterparty might run away with their money.

So, I think we want to stress here that the communication goes both ways.  On
the one hand, the limits and the policies and changes to the policies need to be
socialized to the broader Bitcoin community before they are put into Bitcoin, in
order to give people time to chime in and to make their concerns known.  But on
the other hand, the second-layer protocols and apps need to consume the
interface, try to be creative with what's available, and also communicate their
needs in order for the right things to get prioritized.  So, for example of
course, we've had Gloria working on package relay for, well, I don't know how
long, two years now, or almost three years, I guess, because this is going to
remove a lot of these issues and make it easier to submit transactions to the
network in a way that they can consistently be relayed.

So, yeah, just wanted to stress how this communication goes both ways and how
people shouldn't assume that policy is made somewhere over there, but rather
that it is an iterative process that can use feedback from many different
avenues.

**Gloria Zhao**: Yeah, and next week is going to be about some of the projects
that exist or proposals at various stages in the process to update some of the
policies.

**Mike Schmidt**: Gloria or Murch, anything you'd like to tie off on this topic?
And of course, if anybody has questions or comments, feel free to request
speaker access or comment on the thread, and we can try to get to your question
as well.

**Mark Erhardt**: Well, I think much ink has been spilled about pinning in the
last year or so.  So, this is one of the major concerns about transaction relay
pinning, and then of course, the high feerates that have made it hard for people
to get, for example, commitment transactions into the mempool at all, since the
commitment transaction, at the time when the last time the channel was updated,
commits to a specific feerate; and in order to get a CPFP going, the parent
transaction by itself at least needs to be able to get into the mempool.  So,
yeah, this topic has been more relevant in the past three months than for a
while because we had been spoiled by really low feerates for almost two years
straight.

**Gloria Zhao**: Yeah, on the good side of that, it's getting a lot more review
on package relay, which is nice.  And yeah, it has been two years.  It's a hard
problem.

**Mike Schmidt**: Gloria, thank you for jumping on.  I'm hoping you can hang out
for a bit because I think you did the write up of one of the Bitcoin Core PRs.
Maybe you'd do a better job of explaining than Murch or I would.  All right.  We
can move to the Releases and release candidates section of the newsletter.

_Core Lightning 23.05.2_

We just have core Lightning 23.05.2, which is a maintenance release with some
bug fixes.  It fixes a compilation error when using the experimental features
flag.  It fixes the JSON parsing error and an error related to the listpeers
GRPC and makes some updates to the pay JSON RPC.  I see we have a requested
speaker here.  Bitcoin Sikho, welcome.

**Bitcoin Sikho**: Hey guys, how are you doing?  Hi Gloria, hi Murch.  I have a
quick question, please.  It's technical, I'm not too technical, but you know the
policy that we're talking about implementing, how does that get applied?  So, if
I'm running a node, a really older version of it, and it's locked, I mean, I'm
not updating anything, usually with regards to a user-activated soft fork, you
would have to update your node.  But how does policy get implemented; like, on
which layer, which level does it get applied to the network; how does it work?
Sorry, I'll have that question, please.

**Gloria Zhao**: It's the same idea as consensus rules.  You would need to
update your node, and that would include the code that implements the new policy
rules.  And, yeah, you wouldn't be enforcing them until you upgraded.

**Bitcoin Sikho**: Oh, right, okay.  So, it's just, again, I have to update the
node.  So, if I don't, then I don't adhere to that policy, right?

**Gloria Zhao**: Exactly.

**Bitcoin Sikho**: Perfect, makes sense.  Thank you.

**Mark Erhardt**: To knit a little bit, it's a little different from consensus
rules in the sense that things will generally still work if nodes implement
different policies.  So, policy only affects directly what you will accept into
your mempool and what you will forward to your peers.  So, if your node runs
with a different policy, it might offer some transactions to its peers that they
would not themselves accept or forward, or vice versa, it might not accept some
of the transactions that other nodes would already accept and forward.  For
example, when the Bitcoin Network adopted the segwit update, old nodes will not
accept segwit transactions to their mempools and will not forward them.  They
will, however, accept them when they see it in a block.

So, yes, you choose your policy by updating your software, some of the policies
might even be changed by configuring your node differently.  There's a few
settings that affect policy, but yeah, for the most part, you pick them per the
software that you're running.  I see Gloria has another comment.

**Gloria Zhao**: Yeah, so you pointed out that since consensus rules are, I mean
hopefully all soft forks, before you upgrade, you might -- so, you were talking
about whether you would accept something that somebody else wouldn't.  And that
relationship is somewhat related to the fact that rules aren't being restricted
in soft forks.  I think, as a mostly general statement, I mean I'm sure there
may be cases where this isn't true in the future, a policy change would be a
relaxation of rules.  So, before you upgrade, if everyone else has upgraded,
then you would just be blocking those transactions from entering your mempool.
But of course, if/when they get mined, you would have to download them as part
of the block.

Then I guess, if we're talking about distinctions between the way that policy
and consensus would work when you're updating your node, with the policy
changes, there would never be, or hopefully there's not -- okay, usually there's
no activation mechanism, so as soon as you start your node, you're going to
start enforcing those new policy rules.  Sorry, I said that because there was a
PR in the past to add an activation mechanism for a policy rule.  It wasn't
merged, but I guess it's conceivable.  Whereas with consensus rules, usually
there's some kind of activation threshold where you're like, okay, we're going
to look at what miners are signaling in blocks, and then at this period, we
determine that the soft fork has activated.  Whereas for policy, it would just
be as soon as you started your node, after you upgraded it.

**Bitcoin Sikho**: So, can you pick and choose between a policy and a consensus?
Say, for instance, if I don't want segwit, but the latest release on the Core
does include a policy change, can I pick the policy and leave out the segwit, or
do I have a choice?

**Gloria Zhao**: So, with the way that all the software is bundled together
right now, no.  Of course if, I don't know, we get kernel one day and you can
have a previous version of kernel with a newer version of mempool policy built
on top, then that would be possible.  Theoretically, yes, it's possible, but
unfortunately, you can't even update the GUI without pulling in all the rest of
the code changes, right, just simply because Bitcoin Core is currently this
massive piece of software with a bunch of things not modularized.  But the goal
is...  I mean, I agree with what you're hinting at with this question here, that
it's weird that we aren't more modular, and you have to get all updates at once,
or none at all, yeah.

**Mike Schmidt**: Gloria, was the policy to relax the minimum standard
transaction non-witness size to 65 non-witness bytes; was a variant of one of
those PRs merged?

**Gloria Zhao**: Yeah, so a few months ago, I feel like this went into 25.  So,
it used to be that the minimum non-witness size was 82 or 83, I can never
remember.  And the reason for that was it should be 64 or it should be 65,
essentially to avoid ever relaying an exactly 64-byte transaction, and that was
relaxed by Greg's PR; who is in the chat actually, hi.  And so, I guess as a
concrete example, we've just been talking about if you did not upgrade, then if
somebody sent a 70-byte non-witness serialized size transaction, you would not
accept that into your mempool, but other people might.  So, yeah.

**Mark Erhardt**: I wanted to comment a little more on the difference between
consensus and policy and how they're rolled up.  You said that usually consensus
rules would need some activation code and need the network to agree before they
become active, whereas for policy we can roll them out on an individual
node-to-node basis, because we don't give any guarantees about propagation of
unconfirmed transactions.  So, the mempool itself is not covered by consensus in
the sense that we don't converge on a single exact same mempool all across the
network; everybody has their own mempool.  We try to get them as homogenous as
possible, but we don't need to agree on it 100% for the network to work.  So, to
have slight differences in how we forward and accept transactions to our
mempools doesn't necessarily break anything.  So, it's fine for nodes to have
slightly different rules and that's also why we can relax rules.

With consensus rules, if we relax rules, that's a hard fork, right, because new
things that are acceptable by the more relaxed rules would break old nodes and
make them stop following the blockchain.  Whereas for the mempool content, if
you accept something into your mempool that others don't, that doesn't break
anything.

**Mike Schmidt**: But per some of our discussion previously, there are
advantages to having more homogenous mempools, so there's that consideration as
well, right?

**Gloria Zhao**: Yeah, of course, it's best if everybody upgrades together
because then transactions relay more smoothly, it's not going to hit a bunch of
black holes on the way to try to get to a miner, and then compact block relay
will work better if everybody has the same stuff.  So yeah, of course, it's
ideal if it's smoother.  I think people are always so surprised.  I'm like,
"Yeah, it's best if everyone has the same stuff in their mempool".  But they're
like, "But there's no such thing as _the_ mempool".  I say, "Yeah, but wouldn't
it be great if there was?"  But yeah, the network should still function much
better with different policies than with different consensus rules across the
network.

**Mark Erhardt**: Of course, there's _the_ mempool; it's a room in our office
here!

**Mike Schmidt**: We have a written question on the Twitter thread here that
asks, not really related to mempool, but more to consensus, "Do user nodes have
just as much voting power as miner nodes in a block validation?  In case of
modification of the consensus, can the miners force the acceptance without the
agreement of the standard nodes?"

**Mark Erhardt**: Well, yes.  So, if miners, a majority of the hashrate starts
enforcing stricter rules, by default, those blocks that follow a stricter set of
rules would still fit the larger set of rules and everyone would go along.  So,
strictly speaking, if miners implemented a soft fork together or had a cartel to
censor certain transactions, they could unilaterally, well not unilaterally, a
majority of the miners could implement that together.  However, the users could
band together in turn, make a block that breaks that rule and require that this
block is part of their blockchain in order to hard fork out of this more
constrained rule set that the miners would be imposing.  But that would be, of
course, difficult to coordinate.

So, yeah, miners can sort of soft fork without anybody else, but people could
see what's going on and could perform actions to break out of it.

**Mike Schmidt**: Murch, we were just wrapping up the Core Lightning 23.05.2
maintenance release.  Did you have any comments on that; largely a maintenance
and bug fix release?

**Mark Erhardt**: Sorry.

_Bitcoin Core #24914_

**Mike Schmidt**: Moving on to the Notable code and documentation changes
section of the newsletter, the first one here is Bitcoin Core #24914, which
changes the way that wallets are loaded in this particular forthcoming release
that's related to this PR.  Gloria, I know you did the write-up on this.  Do you
care to maybe elaborate on what that changes and what people may be needing to
be aware of in terms of loading their wallet in the future?

**Gloria Zhao**: Yeah, I think in terms of user changes, the important thing to
note was that previously with corrupted records and the wallet database files,
the wallet would load and print warnings.  And then I think in this case, there
may be cases where it will just fail, but you would still be able, if that
happens, to first of all open an issue or talk to achow about it, but also you
could just use an older version, import it with the warnings but without the
total failure, and then migrate it, and then the newer version would resolve
those errors and give you a new file.  So, that's the user-facing thing to think
about.  Hopefully if anyone encounters these, but hopefully nobody does,
hopefully they can see this in the release notes.

But what happened under the hood was it kind of changed the way in which the
database was parsed where, I don't know if this is interesting to people, but
instead of, I think it was parsing everything twice, in the first round looking
for dependencies between records, like for example you need to load these keys
before you load those transactions, or something, what it does is it says, okay,
first I'm going to load all of these types of records, and then I'm going to
load all these other types of records, and so on and so forth.  And so, as a
side effect, it handles those corrupted records differently and users should be
aware that if this happens, check out the release notes, try an older version,
migrate, etc.

**Mike Schmidt**: It sounds like from some of the comments in the PR here by
achow, that not only is the current approach potentially slow, it also sounds
like there's some future improvements that can really cause some drastic
slowdowns to keep the current algorithm in place.  So, this is potentially an
improvement that will alleviate that concern in the future, for whatever future
improvement he's alluding to here.

_Bitcoin Core #27896_

Next PR from the newsletter is Bitcoin Core #27896, which removes the
experimental system call (syscall) sandbox feature.  And so, in Bitcoin Core
#20487, which was a PR merged in late 2021, it added an experimental feature to,
"Allow only expected syscalls to be used by bitcoind".  So, syscalls are how a
program dictates to the operating system kernel to perform some tasks.  So,
programs use syscalls at the operating system level to perform a variety of
functions that could be file I/O or network interaction.  And so, the operating
system under this PR, this previous PR, would terminate bitcoind if it made any
of those types of operating syscalls, outside of ones that were specifically
white listed.

So, this was behind an experimental flag and it was merged in late 2021, and it
was only available on Linux and you had to be using the x64 architecture.  And
in a recent issue related to that feature, Wlad opined, "I think after having it
integrated for a while, it's time to reflect on the status of the experimental
syscall sandbox.  It was worth a try, but personally I have come to the
conclusion that it's unmaintainable.  I don't think this is something we can
ever enable by default for end users".  And so Wlad opined on the
maintainability, and in some follow-up comments, folks pointed out that there
were better supported alternatives for providing that sort of sandboxing that
folks can use.  And there was also commentary about whether Bitcoin Core should
even have a responsibility of managing syscall sandboxing.  Murch or Gloria, do
you have commentary on this feature and the removal of this feature?

**Mark Erhardt**: I only learned about this today, but it seems to me that
having three separate implementations of such an invasive feature across the
three supported operating systems, or if there's even more by now, would be a
lot of work.  And I saw that Wlad had cited at least five bugs that were caused
by the syscall sandbox.  So, it seems to me that that indeed would have been a
huge maintenance burden.  But other than that, I'm not super-familiar.

**Mike Schmidt**: Gloria, I presume as a maintainer, this is a welcome removal?

**Gloria Zhao**: Yes.  Maintenance burden is, I think, a significant factor
here.  I've heard a lot of complaints about it.

_Core Lightning #6334_

**Mike Schmidt**: Next PR is Core Lightning #6334, which updates and expands
Core Lightning's (CLN's) experimental support for anchor outputs.  This PR now
enables anchor spending support so that CLN can essentially lowball the
commitment transaction fees and can open anchor-based channels.  And a note in
the thread here for this PR notes that anchor-based channels use larger
commitment transactions with the trade-off that they don't have to use a
worst-case fee, but can bump the commitment transaction if needed.  So, in order
to do that, there needs to be some funds set aside in order to do that fee
bumping and there's some defaults set to 25,000 satoshis to do that and you can
customize that amount.  Murch, I see your hand up.

**Mark Erhardt**: I was really confused by the title of this PR because we
currently cannot accept zero feerate transactions to the mempool by default.
Even if the minimum dynamic mempool limit were not much higher than that right
now, we would never accept transactions with zero fee into the mempool.  And so,
if you're trying to CPFP a transaction, you still need to get the parent
transaction in first by itself and then submit the child with the higher
feerate.  So I'm kind of wondering, I guess this is kind of experimental still,
and they might be trying it out on testnet in anticipation of v3 and ephemeral
anchors coming eventually, but that seems very early because we currently can't
submit packages yet.  But really, this is Gloria's area of expertise.  Did you
happen to look more into this?

**Gloria Zhao**: I didn't, but I think for testing, it's probably fine.  And,
being optimistic is good for getting package relay in.

**Mark Erhardt**: Yeah, I was looking a little bit at the PR, but it had 36
commits and touched over 90 files, so I didn't quite have the time to dig out
what exactly it did.

**Mike Schmidt**: Yeah, Rusty did note that this is experimental for one
release, and then it's expected to be the default in future releases.  I don't
have anything to add to the comment you had, Murch, about it being zero fee Hash
Time Locked Contract (HTLC) support, other than the comments about being able to
execute or open anchor-based channels more broadly.  So, perhaps we can have
some clarification in the future about the zero fee part of that.  Yeah, I did
also think it was interesting that this PR touched 98 files and added 2,700
lines of code and removed over 1,000 other lines of code, so it was quite a
beast.

_BIPs #1452_

Next PR from the newsletter is to the BIPs repository #1452, and this updates
BIP329, which is the informational BIP that standardizes the format for wallet
labeling metadata.  And so as a reminder, BIP329 can apply labels to things like
transactions, addresses, pubkeys, inputs, outputs, and extended public keys
(xpubs).  And in this particular PR, it adds a new field, which is a boolean,
true or false spendable field to wallet labels, and it's specific to the output
record type.  So, I don't think you're supposed to be putting spendable on other
record types, like transactions, addresses, etc, where it wouldn't really make
sense.

The PR author noted, "Since this is wallet-related metadata, it's similar to
labels but not captured elsewhere", so they're including it in this BIP329.  It
was also an interesting point here that it does expand the scope of the BIP very
slightly because it's almost making it a wallet metadata BIP instead of purely
label-related, because wallets may have to take certain actions or not take
certain actions based on the value of that spendable flag.  Murch?

**Mark Erhardt**: I think the main point here is that you want to keep track of
stuff being labeled as unspendable so that, for example, if you have a dust
output being sent to one of your addresses that you had previously used to
receive and send funds, so basically an attempt at forcing you to reuse an
address, you might choose to never spend those funds and label them as
unspendable, so your automatic coin selection would ignore those specific UTXO.
And so, especially in that regard, you want to keep track of such labels between
moving wallets and importing wallet metadata between wallets.

Maybe also a tangent here, what really confuses me sometimes is how coin control
is used in two different ways and sometimes even interchangeably with coin
selection.  So, coin control here means the ability to label UTXOs individually,
whereas in Bitcoin Core, coin control is used to refer to the module that allows
you to do manual coin selection.  So just, yeah, that's it!

_BIPs #1354_

**Mike Schmidt**: Last PR for this week is also to the BIPs repository and is
BIPs #1354, and this adds BIP389 for the multiple derivation path descriptors
that we talked about in #211, and it essentially augments the BIP300 key
expression of descriptors to be able to include both receiving addresses and
change addresses.  So right now, descriptors describe the scripts that are used
in a wallet, and in most wallets, you usually require two descriptors, one for
receiving and one for change, and those descriptors are often very similar.
Thus, it's useful to have some sort of a notation to represent both of those
descriptors as a single descriptor when there's only a small derivation step
difference in the different values.  So, I guess this is making it easier for
descriptors to describe what would be a common wallet.  Murch?

**Mark Erhardt**: Yeah, maybe to explain it slightly differently, when you have
a range descriptor, it really is a template for all outputs in a series of
addresses, and that would just generally be like an xpub, and then all the
derived addresses by incrementing the child counter on the xpub.  And here, what
Andrew noted is, very often wallets will have a separate set of, or a separate
range descriptor for the change outputs, because it's an easy way of keeping
track of whether funds were sent externally or deliberately to an address versus
whether they were created automatically by means of creating a transaction where
you send funds to a different destination and had some left over.

So for example, in your wallet, when you give an overview of your sends and
receives, the change output should not appear in your receive tab because that
would be confusing, and it's easier to keep track of that sort of thing.  So
here, basically you have a descriptor to define two separate ranges in one,
where one refers to these automatically used addresses, and one refers to the
externally used addresses that you hand out in order to receive funds or to get
an invoice settled.

**Mike Schmidt**: And, Murch, correct me if I'm wrong, but this change, or this
new BIP also not only allows for two, but I think you can have more than two,
although I think the most common use case for a wallet would be to receive and
change; is that right?

**Mark Erhardt**: You are catching me off guard, but that does look like it.
Although, I think that the most common variant that I know is just two of these,
but for example, maybe in the context of maybe you would have a third type of
addresses, for example, if you frequently do consolidations on a high-volume
wallet, you wouldn't want to use your external address range, but an internal
address range that is not the change outputs.  Maybe for something like that, it
could be useful.

**Mike Schmidt**: All right.  Murch for Gloria, any announcements before we wrap
up this week?

**Mark Erhardt**: Nothing from me.

**Gloria Zhao**: No.

**Mike Schmidt**: Well, thank you both for joining, and thank you all for
listening, and we'll see you back here next week.

**Mark Erhardt**: Cheers, bye.

**Gloria Zhao**: Thank you, bye.

{% include references.md %}
