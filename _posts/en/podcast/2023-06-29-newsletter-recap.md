---
title: 'Bitcoin Optech Newsletter #257 Recap Podcast'
permalink: /en/podcast/2023/06/29/
reference: /en/newsletters/2023/06/28/
name: 2023-06-29-recap
slug: 2023-06-29-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Gloria Zhao, Robin Linus,
Dave Harding, and Pavlenex to discuss [Newsletter #257]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-5-30/337505041-22050-1-313e11a9d78ca.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #257 Recap on
Twitter Spaces.  It's Thursday, June 29th, and we're joined hopefully later by
Greg Sanders to talk about coinjoin pinning and v3 transaction relay, we have
Robin Linus here to talk about sidechains and speculative consensus upgrades,
Murch and Gloria to talk about policy and protecting network resources.  We have
five questions from the Stack Exchange, a BTCPay Server 1.10.3 release, a bunch
of LN-related PRs.  So, let's go through some introductions and we'll jump into
it.  I'm Mike Schmidt, contributor at Optech and Executive Director at Brink,
where we fund Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin stuff, and
we recorded two great episodes that are coming out shortly at the Chaincode
podcast!

**Mike Schmidt**: Excellent.  Gloria?

**Gloria Zhao**: Hi, I'm Gloria, I work on Bitcoin Core, and I'm sponsored by
Brink.

**Mike Schmidt**: Hey, Robin, who are you?

**Robin Linus**: Hi, I'm Robin, I work on ZeroSync.  We are applying
Zero-Knowledge Proofs (ZKPs) to Bitcoin.

**Mike Schmidt**: Excellent.  Well, I've shared a few tweets in the Space so
folks can follow along.  We also have the website version of the newsletter if
you care to pull it up; it's #257.  And, since Greg may be joining us, I want to
stall for him and maybe we can go a little bit out of order.

_Speculatively using hoped-for consensus changes_

Robin, we can talk about your news item first, which is speculatively using
hoped-for consensus changes.  And, Robin, maybe to set the context a bit, it
sounds like this is a similar idea to Spacechains, and that there are BTC that
are sent to some destination for purposes of being used on a sidechain, but
whereas in spacechains those BTC are burned and no longer spendable on the
mainchain, the idea with this Some Day Peg idea is that coins aren't burned, but
sent to a long timeout output.

In the example, I think it was 20 years' locktime that would be spendable by
anyone after that timelock, but there's an additional spending condition that
could spend the coins before that timelock if you satisfy a Bitcoin script
fragment using opcodes with semantics that aren't currently defined in
consensus.  And the example given, I think, was a script that used a reserved
opcode speculatively as an OP_ZKP opcode.  Am I getting that right; and maybe
you want to fill in some of the holes there?

**Robin Linus**: Yeah, exactly.  First of all, I have to clarify, it's not only
my idea.  I was hanging out with Burak and Super Testnet, and we were just
talking about Bitcoin and joking about things.  And during that, Burak came up
with the idea that we might use an opcode that doesn't yet exist, or that
doesn't exist yet.  And, yeah, the idea was based on Ruben Somsen's perpetual
one-way peg, which as you described, basically just burns bitcoin to mint some
other coins, some sidechain coins.  And, yeah, people opposed it a lot.  Nobody
likes the idea of burning bitcoins, apparently.

So we thought how to improve it, and the idea is that we could have someday a
ZKP verifier that would allow us to do trustless two-way pegs.  And since we
don't have that yet, we could just pretend that we already have it and make
people use it even before it exists.  If people use it, then they also have an
incentive to lobby for actually activating this software that would be required,
and the more people use it, the higher the incentive of the community to
actually activate it.

**Mark Erhardt**: Well, the incentive for them to lobby for it, not necessarily
for the community, because lost coins just increase the scarcity of all other
coins, right?

**Robin Linus**: Oh, true, yeah, but here the coins wouldn't get lost.
Actually, yeah, they would be given to miners if the software would not get
activated.

**Mike Schmidt**: So, you're incentivizing the users of the coins on the
sidechain who could potentially redeem it to activate, but you're also
simultaneously incentivizing miners then to not activate it, because they could
scramble for these coins?

**Robin Linus**: Well, actually, miners do have an incentive to activate it too,
because of course they could just steal the coins, but the problem is every
miner could steal the coins.  And if enough coins are locked and if all
timelocks open at the same block height, then miners would have an incentive
forever to overwrite that block and to fork and to give the coins to themselves.
That would create huge chaos and it's kind of an even better incentive for the
community to actually activate it.

**Mark Erhardt**: Catching up to your thought process here, that sounds more
like a very dangerous precedent and maybe an incentive for the community to
change the outcome so that the miners will not be able to claim those funds.

**Robin Linus**: Yeah.  To be absolutely upfront, I am not very serious about
this proposal.  I think it's very funny and I think it's worth exploring this
idea and thinking about this idea, but neither Burak nor Super Testnet nor I are
very convinced of this idea.  We do see that it's very problematic, in
particular from the political perspective, because the incentives of it are
super-strange.

**Mark Erhardt**: Yeah, I agree.  I was reminded yesterday again how it's
important to keep an open mind and look at things in two or three different ways
before you dismiss them.

**Robin Linus**: The interesting idea here is that it's mostly a political
solution, right, it's not a technical solution.  The technical solution is
basically postponed to some point in the future.  It's more like an incentive
structure, I would say.  And if it works out, I don't know, but there are
incentives to do that, and that's kind of interesting, I think.

**Mike Schmidt**: And the mechanism here is repurposing a reserved opcode for
potentially, for example, the ZKP, repurposing that as an OP_ZKP opcode.  And I
think we've talked a little bit recently, in recent Spaces here, I think with
Joost and others, about trying to preserve those reserved opcodes so that
they're not used today and that they can be preserved for future use.  Whereas
this would be, I guess, you could in theory be doing something like this sooner
than later.

**Robin Linus**: Yeah.  I would not be certain how to implement this actually,
because we would have to find consensus on some kind of ZKP verifier.  And as
far as I understand the industry, there is no verifier that you could just take
off the shelf and you're good.  It's not the same situation as when Satoshi
invented Bitcoin that he knew, well, we have the signature schemes and they have
been out there for years and we can just use them.  I think he just chose some
of OpenSSL that he thought is reasonably good.  And I think we don't have that
situation yet in the field of ZKP, so it wouldn't be easy to choose a particular
verifier right now.  But we would have to choose one.

**Mike Schmidt**: Would you need to choose one before, because really all you
need is which opcode you want to repurpose, and then I think in the example,
there's just some sort of a hash, right, and so however that would be
implemented could be determined at a future date, right?

**Robin Linus**: Yeah, we thought so originally, but the more I thought about
it, the more I thought it's probably not true.  First of all the question is,
how specific do we want that opcode to be?  Should it be generic OP_ZKP_VERIFY,
or should it be only for a particular thing, which could be like a two-way peg
or so?  If we would say we want something very specific for only a particular
two-way peg, then it wouldn't be necessary to define all the details right now,
because we could figure them out later and just adapt them such that they fit
our use case later on.

But if we want to have generic ZKP verifier, then yeah, we have to define the
specifics of it up front before we can use it, because otherwise what we do will
be incompatible with the ZKP verifier we can be verifier.  You mentioned the
program -- sorry?

**Mike Schmidt**: Sorry, go ahead, Robin.

**Robin Linus**: Yeah, I don't want to talk too much like I'm happy if you give
feedback in between because I don't know if I'm making sense or not.

**Mike Schmidt**: I was just curious if Murch or Gloria had any comments or
feedback on the proposal.

**Mark Erhardt**: I think that it's the game theory and incentives around what
happens, depending on how much money is used with this opcode, and how that
might affect the dynamics of whether or not this is getting implemented.
There's a few too many open variables there for me to...  My first reaction is
that I'm not very comfortable with the idea!

**Robin Linus**: I'm not sure if I like it or if I hate it!

**Mike Schmidt**: Dave, do you have a comment?

**Dave Harding**: I just wanted to maybe correct something that Mike said in the
introduction, which was, he said that if we define the opcode, like we make a
consensus chain to define the opcode, we could start using this thing right
away.  I think maybe that's confusing two different things, which is, one, if
this was done, if we would take this risk, they could start sending money to say
a sidechain that used this right away, but there's no way that I can think of
that they would be able to withdraw money from that sidechain in less than
whatever the period of time was.  So, Linus suggested 20 years; there's just no
way to allow a withdrawal in less than 20 years, even if next year we defined an
OP_ZKP_VERIFY opcode.  So it's just you're really committed to this if you're
willing to take that risk.

**Robin Linus**: Well, you can always use atomic swaps if you find someone who
wants to swap in.

**Dave Harding**: That's fair.  But I'm just saying, the set of funds committed
to the sidechain, it's stuck there for 20 years.  There's no way for that pool
to get any smaller in less than 20 years, even if we, as a community, change the
consensus rules to support the feature that was being proposed.

**Mike Schmidt**: You're right, Dave.  I guess I misunderstood that.  I thought
that there was sort of a conditional there that was either the ZKP thing
activates and you can withdraw before, or anybody can grab it after the
timelock.  So, I may have misunderstood that.

**Robin Linus**: I guess in theory it would be possible to implement it such
that you can use it right away as soon as it gets activated.  But I guess that
would require a hard fork and not a soft fork.

**Dave Harding**: Yeah, I agree.  I spent a fair amount of time while writing
this trying to think of a way around that which I think it would be more
appealing, if there was a way to pull those funds back into Bitcoin early.  But
I just couldn't see a way to do that with just a soft fork.

**Robin Linus**: Yeah, with a soft fork, I think it's impossible, but with a
hard fork, it should be possible.  You just need like the opposite of an OP_NOP;
you need something that currently fails, and then after the hard fork, it
succeeds.  Then it would be possible.

**Dave Harding**: No argument from me.

**Mike Schmidt**: Murch, anything else before we move on?

**Mark Erhardt**: I'll just play the grouchy old man here and say, if you're
banking your money on hard forking to get new speculative features, I think
you'd better be ready to have signed them off!

**Robin Linus**: I mean, we just tried to be better than burning, right?  So
this is a slight improvement over burning your BTC.

**Gloria Zhao**: I kind of had a thought about using this as a general
speculation on consensus changes.  I think there's two scenarios that are my
absolute worst nightmare, one of which is two people create conflicting opcodes,
for example, and then you put money into that, and then suddenly it's like,
okay, now we have to decide whose money to burn.  And that's not something that
I think we can -- that makes me very uncomfortable, as Murch said.  And the
other one is it's kind of almost a negative bug bounty, where if you're in a
situation where you found a heinous bug that would allow you to steal anyone's
money that used this opcode, you're almost disincentivized to reveal that,
because what you really want is for the soft fork to happen so that you now get
all that money, which is already locked up for you conveniently.  I don't know,
maybe I'm simplifying it too much or thinking the worst case, but that's kind of
my grumpy-old-man thoughts about this.

But you know, I interpret a lot of things sometimes as just like a general push
where like, "Hey, we really need to figure out how we get rough consensus and
discuss soft fork proposals".  So, I think it's good for that kind of
thought-provoking kind of thing.

**Mike Schmidt**: Robin, thanks for joining us.  You're welcome to stay on and
comment on the rest of the newsletter.  Otherwise, if you have other things to
do, you're free to drop.

**Robin Linus**: Yeah, thanks for having me.

_Preventing coinjoin pinning with v3 transaction relay_

**Mike Schmidt**: Absolutely.  So, I think we'll go back to the first item of
the newsletter, and I'm hoping between Murch, Gloria, maybe Harding and myself,
we can go through this.  Luckily, the author of the v3 transaction relay rules
proposal is here to help.  Maybe I can lob a softball to Murch here to start
this discussion, which is the discussion of preventing coinjoin pinning with v3
transaction relay, which is a mailing list post that Greg Sanders sent to the
Bitcoin-Dev mailing list.  Murch, I suspect you can handle this one.  Maybe we
can explain how a participant in a collaborative coinjoin transaction could
today prevent that coinjoin transaction from confirming; and then after that, we
can get into what part of the v3 transaction relay proposal assists in the
remediation of that kind of attack.

**Mark Erhardt**: Sure, I can try to give it a stab, but Greg just told me that
he'd be here so I didn't read much up on it!  Anyway, the general problem here
is that when multiple parties are trying to build the transaction together and
there is more than one contributor that submits UTXOs to it, they can of course
always build more transactions that also use the same UTXO.  And, while the
coordination for the coinjoin is ongoing, where they first must tell each other
what inputs they're using, somebody builds probably a PSBT and maybe some people
are starting to sign it, they could still submit a second transaction that
spends the same UTXO.  And depending on whether or not replaceability has been
set on that second transaction, it might prevent the coinjoin transaction after
it's signed to get accepted to mempools because there is already a conflicting
transaction in the mempools.

So, I think there's the obvious case where that transaction is just there and
there's a conflict and everybody knows that the coinjoin transaction was not
accepted to mempools because of the conflict, but there is also a way in which
that can be done that it's not -- sorry, if the other coinjoin participants have
already submitted the transaction to their own mempools and the transaction by
the attacker is already submitted to many other mempools on the network, then
they might come into a situation where none of the two transactions can replace
the other one, and the other participants in the coinjoin don't realize that
there is a competing transaction in other people's mempools, and they could get
stuck and be waiting for a long time.  I think, Dave or Gloria, did I get that
roughly right?

**Mike Schmidt**: Thumbs up from Dave.

**Mark Erhardt**: Okay, so the idea here is now as a solution, you could just
stage the funds just in quotes, even the original source material, because if
the funds are already sent to an address, or I should say an output, that is
controlled by all participants of the coinjoin, then of course the funds cannot
be double spent because they are already controlled by the coinjoining
participants.  And the idea is here each participant, in order to sign up for
the coinjoin, first sends the funds to the coinjoin conglomerate, and then when
the funds are confirmed, they only try to perform the coinjoin.  And then of
course there's a fallback path when it times out, it goes back to the
participant, pretty much like how when we open a channel or a Hash Time Locked
Contract (HTLC), we have the two paths where we get to reclaim our funds after
it times out.

**Mike Schmidt**: Okay, Murch, that makes sense to me.  I think the part that I
didn't understand in reading through this is, where does v3 come in in any of
that?  I understand that there's this staging step that would help mitigate the
pinning, I'm unsure where the v3 part comes in.

**Gloria Zhao**: I think it's because -- well, maybe I shouldn't have unmuted my
mic.  But my understanding was that if the staging transaction is v3, then it
forces the next transaction to be v3 if it's still unconfirmed.  But then I was
wondering if all the staging transactions are separate transactions, or if
that's all one transaction.  But yeah, that's my understanding, that you're
doing the forced inherited signaling, but I don't know.

**Dave Harding**: So as I understood the proposal, all the staging transactions
are separate transactions.  They're all deposited to the same scripts basically,
but they're all separate transactions and they need to be confirmed before the
coinjoin starts.  So, that was actually going to be also my question for Greg
when he was here was, does this actually require v3?  Because it seems to me
like this works without v3.

I guess the downside of this proposal is this is just more heavy on the chain
than existing coinjoins.  And it's especially, I think, I don't want to say
problematic, but it's especially heavy if we consider what we want for
coinjoins, which is we want them to be using in the future, if we have signature
aggregation, cross-input signature aggregation; it's going to be especially
heavy if we have to go through this process to avoid pinning of coinjoins.  So,
I personally didn't see this as a really great solution, but it is a solution if
pinning of coinjoins is becoming a major problem.

**Mark Erhardt**: Especially if we consider that coinjoins might be performed in
order to increase privacy by mixing up clusters between multiple wallets, then
having this step in between where everybody pays to the same script before is
such a huge fingerprint that it at least would make that case completely absurd.

**Dave Harding**: Yeah, I think looking at Greg's proposal, he covered both the
cases of what we currently have is implemented by JoinMarket, where the
coinjoins are between a small group of peers, and the cases that we have, like
in Wasabi and Whirlpool, where the coinjoins are kind of coordinated by a
central coordinator.  And so, in the central coordinated coinjoins, I think his
proposal is a lot more efficient and useful.  But again, like Murch said,
there's a fingerprinting vector there that, I don't know, I guess I think it
exists currently with coinjoins.  They kind of look like they might be
consolidation transactions maybe, but I think they're pretty onchain
fingerprintable right now.

**Mark Erhardt**: Actually, I realize where I'm going wrong with this.  So, I
think the way JoinMarket and Wasabi and other bigger coinjoin proposals work is
that it's fairly obvious that a coinjoin is happening, but the outputs gain
privacy because they become unassignable to the original entrants of the
coinjoin.  So, you're creating an anonymity set by saying, "Yeah, sure, we all
paid into this pot, but now you can't tell anymore whose output each one was
when they came out of the coinjoin".  And therefore, I think maybe the
fingerprint going into the coinjoin is not that bad, because people are already
pretty open about being in the coinjoin, but you still get the benefits of the
outcome.

**Gloria Zhao**: I have a question, it's a really dumb question.  Is
ANYONECANPAY (ACP) used in this regime, because I've just noticed that it's a
quote text of, "Circling back to my ACP point,…"?

**Dave Harding**: Not so far as I know.

**Gloria Zhao**: Okay.

**Mark Erhardt**: I have no idea.

**Mike Schmidt**: Should we wrap it up, Murch?  All right.

_Waiting for confirmation #7: Network Resources_

Well, next item from the newsletter continues our tech series on transaction
relay and mempool policy, titled Waiting for confirmation.  In a previous post,
we outlined some considerations around using policy to protect a node's
resources.  And in this post, we're talking about protecting network resources.
So, maybe to start, Gloria or Murch, whoever feels comfortable, maybe we can
outline some examples of what are Bitcoin's network resources in the way that
we're thinking about it in this post?

**Mark Erhardt**: Well, how about I just start because I wrote most of this.
So, some of the network resources that we're trying to protect in the Bitcoin
network are of course just the overall blockchain size, the UTXO set as a
representative of the current state of the network, and we want to protect the
upgrade hooks.  So, we have a bunch of mechanisms still in place that are
currently allowed by consensus to be used, but in policy protected in order to
have a smooth upgrade path for later soft forks and protocol changes.  So, those
are the three that come to mind.

**Mike Schmidt**: And then, Murch, I think we outlined in the protecting of the
individual node resources some examples of how those particular resources are
protected.  And so I guess in this case, how are we protecting those three
different kinds of resources that you've outlined?

**Mark Erhardt**: Yeah, so, sorry, I'm blanking pretty hard right now!  Gloria,
do you want to jump in?

**Gloria Zhao**: Yeah, I mean the general theme is, yeah, we have standardness
rules to just stop things, or put a price on things that we consider taking up
various network resources.  I think one of the best examples in here is about
adding arbitrary data into the blockchain, and how -- the blockchain is this
highly replicated perpetual storage that you can get tens of thousands of people
to store forever for you.  And so, of course, there's going to be demand for
that.  And then I think recently, there's been lots of -- we generally in
Bitcoin, I think we have a kind of culture of like, "Oh, yeah, protect network
resources, keep UTXO sets small, keep blockchain size small, so that new nodes
can bootstrap", and we keep the cost of running a node small and it's feasible
to do it on a Raspberry Pi, etc.

So, for example, with people putting jpegs or putting any kind of arbitrary data
into their transactions, people feel that that needs to be stopped.  They're
like, "Oh, yeah, maybe add a rule to prevent 'arbitrary useless wasteful data'
in transactions, because we have lots of standardness rules right now that are
already censoring".  And my take on that is, as protocol developers, I don't
think we have a place in saying what is legitimate payment and what is
legitimate data to stuff into the blockchain, and what is wasteful or not real
payments.  I think that goes against the whole philosophy of Bitcoin.  But for
example, this idea of pushing arbitrary data on chain, there are various costs
associated with that.

So I think, again, the best example in here is talking about putting it into a
bare multisig versus putting it into an OP_RETURN.  I think the introduction of
a single OP_RETURN "null data" or "data carrier" output was made standard as a
way where it's like, "Okay, we're not going to tell you that this arbitrary data
is useful or not useful or meaningful or not meaningful, but if you're going to
do it, put it in an OP_RETURN so that we don't have to put it in the UTXO set",
for example.  So, I think that's the best one that I would point to within the
article.  Murch has something to say, so I'll hand the mic back to you.

**Mark Erhardt**: Yeah, so I think people realize that it is impossible to
prevent people from publishing data on the blockchain.  And as Gloria already
mentioned, it is very attractive to have at least a few small pieces of data in
the blockchain where it will essentially live forever.  And when you cannot
prevent people from doing that, we can at least maybe encourage some best
practices where we get people, if they need to do it, to do it in a way that it
doesn't pollute the UTXO set, doesn't live in this piece of state that we have
to keep around forever because we use it to validate transactions, to validate
blocks.

So, yeah, we introduced OP_RETURN outputs to basically have a path to cater to
this need without encouraging the worse ways of doing that.  And so, in a way,
the resurgence of the stamps recently is really unfortunate because bare
multisig was essentially completely unused, and when people then say, "Oh, yeah,
we do actively want to publish to the UTXO set rather than just a blockchain",
so people have to keep it forever in the active data rather than just a
blockchain, that sounds a little counter to how we would like people to behave
on the network.  Given that we have this huge global state, it's essentially
like if you have a class of students and you're making every student correct
every other student's homework, you're probably going to get a few people that
are very stringent about it and find every mistake, but it's also a lot of
replicated work.  And that's what we're doing with the blockchain.  Every single
node is looking at every other single node's submissions to the network.  So, we
want to keep that small in order to scale up.

We embody a lot of the goals for our network in the way the network is
constructed and the peer-to-peer nature of it.  If we allow people to just waste
network resources, we will not be able to run nodes at home easily.  We will
make it more expensive and less accessible, we will reduce the number of
entities that need to be convinced, coerced, or blocked to get undue influence
on the network; so, yeah, philosophically we want the cost of running a node to
be as small as possible so that we get a widespread, diverse set of node
operators so that there's a lot of people that check each other's homework.  So,
the post here is mostly about that, how we can use policy in lieu of consensus
rules to encourage best practices, to encourage social behavior, where people
maybe take themselves back a little bit in order for the whole network to be
able to exist in its current form to keep censorship-resistance and our
leaderless configuration of the network alive.

**Mike Schmidt**: Gloria, any further comments before we wrap up this section?

**Gloria Zhao**: Yeah, the biggest theme I wanted to get across was essentially,
we have no business censoring transactions on the basis of use case, but on the
basis of what network resources we're trying to protect and are critical to all
of these ideological goals, we have; I think like policies is a great way to do
that.  And I think one thing that we didn't mention actually in any of these
posts was sometimes policy is a way to add a rule to the network that really
should be consensus.  But it looks like Harding has his hand raised.

**Dave Harding**: So, I kind of want to disagree with Gloria on this, I'm sorry,
Gloria.  But I think maybe we do have a good reason to make decisions based on
use case.  So, as a node operator, I'm willing to serve data, even if the
government doesn't want me to serve that data, in order to help protect other
people's ability to use free money, which is what I think of Bitcoin as; free as
in a sense of freedom money.  On the other hand, I'm not necessarily willing to
run a node and to put my freedom at risk if I disagree with the government in
order to serve other people's data, especially if that data is, let's say,
breaking copyright law, or let's say that data is child pornography.  And that's
the kind of arbitrary data that some people want to store in the blockchain.

Now, other people want to store other sorts of arbitrary data.  For example, we
had a user on here a few weeks ago talking about using the annex to store
data-related bitcoin transactions, which again, I'd be fine with that as a node
operator.  But as a node operator, I don't necessarily want to store people's
arbitrary data that isn't related to money.  And so I think there is a reason to
think of use cases here, in the sense that we could lose node operators if those
node operators felt like their goodwill was being abused.  So, I just wanted to
put that out there as a take.

**Gloria Zhao**: Yeah, sorry, what I meant by "we" is as protocol developers.  I
don't think that if you're writing, let's start with like consensus rules,
right?  I don't think it would be appropriate to have consensus rules that as
devs we impose on people.  I mean, okay, sorry, how do I say this?  Yeah, at the
protocol level, I don't think we should police based on use case.  At the node
operator level, I think, yeah, it's totally an individual decision.  If you want
to change your node to ban anything you think looks like a jpeg, or any use case
that you particularly dislike, I think that was what the last post was about,
was policy as an individual choice.

But I don't know that it makes sense to say, "Oh, this jpeg --" okay, something
like child pornography is very black and white, but the types of decisions that
are typically made by financial institutions, that police who gets to use money
and who doesn't, I mean, this is kind of how we think about it in Bitcoin,
right?  The types of decisions that they make are not really ones that I think
are suitable for what we're trying to do here, if that makes sense; so,
difference between we as a protocol developer making decisions and we as
individual node operators making decisions.

**Dave Harding**: I see somebody else wants to talk, so I'll just go really
quickly and just say, I don't think we necessarily have the tools to block the
things that I would want to block.  I say child pornography; I don't think we
have the tools to block that at the consensus level.  And so as protocol
developers, we can't really spend a lot of time thinking about that because we
just don't have the tools.  But if we had the tools, I think it would be very
easy to get support to block that.  So anyway, I'm finished.  Thank you, Gloria.

**Mike Schmidt**: We have a speaker request from user Oflow.  Go ahead.

**Oflow**: Hey, what's going on?  Yeah, I actually agree with Gloria, and lots
of love and lots of respect to you, Gloria, I appreciate what you're doing.  I
like to look at it similar to a dollar bill.  Obviously, this is a bad example,
but it's perfect for this situation.  Anyone can have a dollar bill and choose
to write over it and put anything on it.  Obviously, some dollar bills that
might be written on or might have beautiful art subjectively on it, but at the
end of the day, it's a dollar bill, it's fungible, you're able to go and spend
it.  So, that's the way I would look at it.  Once you start telling people that
they can't spend their dollar because it has a smiley face on it, that
fundamentally messes with Bitcoin.  That's what I think.

**Mike Schmidt**: Thanks for that comment.  Gloria or Murch, anything else you'd
like to say before we tease the next post in the segment and move on?

**Mark Erhardt**: Yeah, I wanted to maybe have a comment, a personal opinion on
the inquisition, what is it, the pictures?

**Mike Schmidt**: Inscriptions?

**Mark Erhardt**: Thank you, it's been a very long week.  We have the Lightning
Summit in New York this weekend, I've been talking to people all day, every day,
and sorry, my brain's just fried!  So, with the inscriptions that we've been
seeing on the network, I think it's totally fair that we focus on Bitcoin trying
to be the digital currency of the internet, for being an attempt at creating a
global currency, and we don't really need to cater to every single use case.  I
think OP_RETURN, for example, being introduced as a means to make sure that
there is a way for people to publish data, a small amount of data, without
having too many consequences for other network resources, is a good means of
preventing it to happen in a worse case or trying to mitigate because we cannot
prevent.

But on the other hand, I'm also thinking that I am completely unconvinced that
having a platform to do BRC-20 tokens is a good thing.  I don't think that it
serves our use case to achieve a global currency.  The harsh truth though is
it's really hard to block these sorts of proposals in an effective way, because
we can sure block this incantation with which the data is pushed to the
blockchain, but then they'll just come up with another one, and then we're just
going to get into an arms race, a game of Whac-a-Mole, where you just block
specific uses.  And then eventually, we come to a point where you just cannot
have an open scripting system, and where people can have maybe brilliant new
ideas of how we can build a second-layer protocol to have a scaling technology
with which we can get the currency of the internet use case better facilitated.

So, we do want to have this open scripting system, we do not want to play
Whac-a-Mole, so what can we really do as protocol developers to curb this use
case?  Well, one thing we can do is to protect the growth of the blockchain and
to basically have everybody grow their adoption against this very fixed limit
and just have use cases price each other out, and hopefully that makes the use
case of currency survive, because money has a very high density of value for low
amount of data.  And hopefully, stuff like writing a series of 8-bit graphics to
the network does not have the same value density.  But I see a few comments.
Maybe Robin?

**Robin Linus**: You mostly said all the things that I just wanted to say.
First of all, it's impossible to permit it.  And second, the only way to really
prevent it is to price these use cases out with higher value use cases.  The
only thing I wanted to add is that I think the best way to do that is to
increase the network effects, which is, in the end, the number of users.  And I
personally see no way onboard users in a frictionless way, other than adding
sidechains like BIP300 and stuff like that.  I think that's the best solution to
add enough people so that the monetary use cases become so valuable that they
price out all the inscription things.

**Mike Schmidt**: Oflow?

**Oflow**: Yeah, so I like to look at Bitcoin for what it's functioning as, and
I see it as a settlement layer.  And I like to compare it to one of the biggest
settlement layers that we have in the world today, which is Fedwire.  And yes,
Fedwire is settling trillions of dollars per day, and Bitcoin literally can do
that; the transactions per second (TPS), there is literally a small difference
in TPS.  And I agree with Robin in that regard -- nice to see you here -- that
essentially the more adoption that we bring to Bitcoin, essentially the more
funds that get settled on that settlement layer, and pricing out arbitrary data
is the way they go about it, instead of specifically trying to change the
protocol in a way where we might specifically damage it, or try and limit it
from a consensus level, because what's being done is not out of consensus, it's
literally in consensus.

Even if we look back at Satoshi, Satoshi literally put arbitrary data into
Bitcoin, not that what Satoshi does is the defining factor of Bitcoin, but
specifically it has been done before and it's in the history of Bitcoin to do
it.

**Mike Schmidt**: We have another speaker request here from Bitcoin Sikho.

**Bitcoin Sikho**: Yeah, hey guys, I've got a question for Gloria.  You
mentioned that to protect the network, we need to introduce policies.  So, what
sort of policies are we talking about?  Would there be like a dust limit on the
transaction, or what exactly can we look forward to, when you say policy changes
to curb unwanted use of the network?

**Gloria Zhao**: Oh, yeah, I was mostly referring to current policy, such as
exactly, like the dust limit.  So for example, let's imagine there was no policy
and you could broadcast a maximum consensus, like block size transaction, that
just creates as many zero value UTXOs as you can fit, and that costs nothing and
you just do that over and over and you blow up the UTXO set.  So, dust limits
say, "There's a minimum value on --" sorry, what's the list name?  nValue on
outputs that you need to put on transactions in order for them to relay, for
example.  Murch has a hand raised.

**Mark Erhardt**: Yeah, I was going to mention, we have a link in the newsletter
that links to a Gist by instagibbs, where he goes over the Policy Zoo.  And what
he goes into is, he gives a list of all the policies that we currently have
active on the network, and he categorizes them as in what motivations they have.
So he looks at, is this to protect individual nodes against DoS attacks; is this
for security where transactions that have certain properties can mess with the
network for no good reason; is this to protect upgrade hooks or to…?  Anyway, so
there's a link in there that you can look at for an overview of the current
policies.

In general, I think we choose to use policies when we cannot introduce a
consensus rule because potentially there could exist transactions that were
pre-signed for which the keys were destroyed, that rely on being able to be
committed into blocks eventually at, I don't know, 20 years later.  And if we
now forbid opcodes that were live at some point in the network, we would prevent
them from ever confirming their transaction.  So, we cannot prevent people from
using previously acceptable opcodes, but we can discourage their use on the
network because, for example, they are really costly to validate for nodes, or
they just are huge in the UTXO set, like their multisig, for example.  I see
there's more speakers again.

**Bitcoin Sikho**: I have a follow-up question, sorry if you don't mind.  How do
you implement these policies; is it like for consensus, obviously you either
need the miners on board or the nodes on board?  So, how does the policy get
implemented; is it the devs just vote on it and then just release it like an
update?

**Gloria Zhao**: Okay, so I think policy changes relatively infrequently, but
the process is not just the devs decide on something and then push it.  I think
typically the process is you post to the mailing list, you air it out, you talk
to any application that might possibly be using this field.  So for example, if
I'm trying to ascribe value and policy to version #3, I will go and see if
anybody else is using that.  And if somebody is, then I don't want to invalidate
their thing, so I'm not going to propose that.  But yeah, you socialize it as
best you can, and then you propose it, and then you can put it behind a flag, I
don't know.  But yeah, it's kind of in the middle.  It's not like you need all
the miners to be on board.  If you were to add a policy that causes them to lose
money, I think they would probably, hopefully say something and say, "No, I
don't want to run this".  But yeah, it's something in between just pushing it
and getting everybody on board.

**Mike Schmidt**: Robin?

**Robin Linus**: I just want to ask, there is no policy to prevent inscriptions;
we can only make it more expensive and more complicated for developers, but we
cannot really have any kind of effective policy that would really prevent
inscriptions, right?

**Mark Erhardt**: I mean we could, for example, reduce the acceptable size of
input scripts, but again, we do want to be able to have a flexible scripting
system, we afford that to ourselves.  Putting in arbitrary limits on things may
prevent us from using it in other ways later.  So, really stamping down on all
of those errant block space demand increasers feels like potentially a problem
for the future.

**Gloria Zhao**: It feels like something that's in witness data.  Maybe this is
a hot take, but it feels like something in witness data and/or something that is
OP_RETURN, where you don't store it perpetually, and you might be able to throw
it away, and you don't have to demand everyone download it when they bootstrap.
Stuff like that is almost like, would very much prefer people using that if
they're going to do it.  I guess this is my whole point.  If it's a choice
between stuffing it into a bare multisig, and stuffing it into witness data, I
think it's pretty clear from the perspective of node resources which one we
should prefer.

**Mike Schmidt**: Oflow, do you have another comment?

**Oflow**: Yeah, this is actually directed towards Gloria.  What do you
specifically think about upgrading Bitcoin script basically to Simplicity; and
what type of effects do you think that would have on Bitcoin, adversely or
positively, which the positives are probably more obvious than the negatives, so
more emphasis on the negatives?

**Gloria Zhao**: I think I am vastly less qualified to answer this than someone
like Murch or Dave Harding, so is it okay if I pass it on to them instead?

**Oflow**: Sure.

**Mark Erhardt**: So, I think that Simplicity is an interesting way of
introducing a lot more scripting flexibility that is much easier to prove
correct and to also program in than we have with our current script system.  The
current script system is fairly arcane, has some weird behaviors.  I think it's
getting a lot better already with the introduction of miniscript, because that
makes it much easier for humans to reason about and to express exactly the
conditions that they want to encode.  With Simplicity, that would be
supercharged, because Simplicity would be a much more powerful language, yet we
would be able to formally verify what exactly the outcomes of a Simplicity
script could be.

My understanding is that we would be introducing that as essentially a new
version of script for tapleafs.  So, it could be soft forked in, it would be
fairly easy to do so, we could have very strong guarantees about what you can do
with it, and I would hope that we would essentially be able to write cooler
smart contracts for how we use our digital e-cash.  But the danger and downsides
might include that it also becomes a lot easier and more powerful to do fancy
altcoins on top of Bitcoin.  So, what I really would not like to see Bitcoin
become is yet another altcoin casino like Ethereum, where people are just
trading a new shitcoin by the hour that gets traded back and forth.  I do see
some use for, say, colored coins like stablecoins, where people need to express
value in their local currencies and perhaps do not have the stomach to deal with
the current volatility of Bitcoin.  But yeah, the danger of having a more
powerful scripting system would mean that we also invite the DeFi space to build
more on top of Bitcoin, and I sometimes wonder whether that's something we want
or not.

**Mike Schmidt**: Robin, maybe one last comment and we can move on to the Stack
Exchange.

**Robin Linus**: Yeah, I just wanted to say that Paul Sztorc's pitch is always
that if we had sidechains, then we could kill all altcoins, and Simplicity would
enable sidechains because it would enable two-way pegs.

**Mark Erhardt**: But do we want that?  Because even then, the sidechains will
increase traffic just to perpetuate the existence of the sidechain on Bitcoin.
We will have more use cases that compete with our use of Bitcoin as a currency
system.  It is hard for me to assess whether the introduction of broad sidechain
capabilities is going to have a beneficial outcome for Bitcoin.  And on the
other hand, I think that, for example, Liquid introduced a lot of ways of how
you could have currencies or tokens/native  assets on Liquid, and I've seen very
little uptake of that.  Now, people might say that that is due to the
performance of Liquid marketing or something.  But I just don't see, it's not
obvious to me that that is an outright benefit to Bitcoin, but please feel free
to push back one more time on me.

**Robin Linus**: Well, the best argument why people are not doing much shitcoin
casino things on Liquid is that bitcoiners just are not that much into gambling.
But yeah, it's a different discussion.  My entire point was that sidechains in
general, they can kill all the old shitcoin narratives because there cannot be
any new shitcoin narrative that could promise something that you could not do as
a Bitcoin sidechain, and I think that that is a good thing in general.

**Mike Schmidt**: All right, perhaps this is a good opportunity to move along
the newsletter.  I think we had some good discussion there.  People like talking
about policy and people like asking Gloria questions.  So, Gloria, thank you for
being here.  Next section of the newsletter is Selected Q&A from the Bitcoin
Stack Exchange.  So, once a month we pick out some interesting questions from
the Stack Exchange and go through those, and this month we have five of them.

_Why do Bitcoin nodes accept blocks that have so many excluded transactions?_

The first one is, why do Bitcoin nodes accept blocks that have so many excluded
transactions?  And maybe a bit of background to this question is this user,
commstark, who asked the question is referencing a metric called Block Health,
which I think is provided on the mempool.space website as a tool to see if the
block that came in matches what a particular node expected that block to contain
in terms of transactions.  So, mempool.space has some metrics around this that
they evaluate blocks against what they expected, what their mempool expected;
and there's also an additional tool provided by 0xB10C, called
miningpool.observer, that does something similar, that shows how many
transactions were missing or extra transactions that were included in a block
compared to what that node or series of nodes thought were going to be in that
block.

So, the question here is, if there's blocks that are being mined that don't
include certain transactions that were expected to be there, why wouldn't we
just block, or I guess not accept that block from that mining pool or that
miner, because maybe they're censoring transactions?  So Pieter Wuille answered
this question pointing out that, essentially the variance in different nodes'
mempools related to transaction propagation kind of makes it such that you can't
really be sure that a mining pool or a miner is censoring transactions.  Murch,
I see your hand up.  Do you want to add to that?

**Mark Erhardt**: Yeah, I think one thing that's interesting to point out here
is that we didn't really have good tools to watch the difference between block
templates, expected block templates, and the actual blocks being published on
the network.  I know, of course, 0xB10C has had the miningpool.observer for a
while already, but with the advent of it being added to mempool.space, it just
became a lot more visible.  So I think it's funny how the visibility of metrics
like this pushes curiosity of people on why we're not able to prevent that.  I
see Harding wants to chime in.

**Dave Harding**: I just want to quickly disagree with Murch.  I think we do
have the tools for that.  If you enable debugging for compact blocks on Bitcoin
Core, it'll tell you what it got from the nodes, on high-bandwidth nodes.  So,
I'm just looking at my debugging log right now.  And so, I have a recent block
here.  It says, "Successfully reconstructed block… with one transaction
prefilled", so that's what we received from the high bandwidth here, "3,214
transactions from the mempool, including at least zero from the extra pool, and
then 15 transactions requested".  So my node requested 15 transactions that it
didn't have from that block when it received.  So, I just wanted to point out
that we did have that tool, but Murch is right that these websites are making it
more accessible to regular users.

**Gloria Zhao**: Well, we don't have the logging to see if something was
missing.  So we don't regularly build block templates, for example, and then
check to see what was missing in the actual block.  I'm sorry, I'm just being a
contrarian, I guess.

**Mark Erhardt**: Although I also just talked to some people yesterday and we
talked about how that would be a useful thing to keep track of in order to, for
example, assess the quality of our mempool to do feerate estimation.  But
getting back to my earlier point, so on the one hand, I think it's funny how the
curiosity is driven by just making this publicly visible.  Thank you, Harding,
for correcting that we couldn't get it as in other ways previously.  But the
other thing is, transaction relay on the network is a best-effort thing, so we
can never tell whether other nodes actually had received the transaction before,
unless we gave it to them directly ourselves.  And so, if they don't include
that transaction, it might have been for benign reasons: they just restarted
their node, they weren't online when this transaction made the rounds, or things
like that.

So, if we required other nodes to be homogenous with our mempool, we would
essentially have a consensus protocol we had to run on the content of the
mempool, rather than the blocks being published being our consensus mechanism
with which we agree what the order of transactions on the network is.  So, it's
just completely impractical that we have agreement on the content of mempools
and therefore we cannot expect people to have the same block templates, I think.
Oflow, what's up?

**Oflow**: Question, why don't we have something like Dandelion in Bitcoin?

**Mark Erhardt**: That's a good question.  So, precisely the reason for
Dandelion was that it introduced some new DoS vectors, because when you pretend
to everybody else that you haven't seen a transaction yet, let's say we have ten
peers and eight of them submit the same transaction to us via Dandelion, we have
to pretend to each of the other ones that we haven't seen it yet until we see it
on the open network.  So, we essentially get a situation in which we have to
keep up to a complete mempool for every one of our peers that we pretend is not
known to everyone else, so we basically get a function or we open a pathway for
other nodes to write to our memory directly.  And there were this and a few
other issues how it could turn into a DoS vector, that could not be mitigated by
discussions on how to improve the protocol.

I think that there is currently work by Vasil Dimov on a single-shot submission
to a Tor node.  The idea here is if you want to submit a transaction to the
network instead of giving it to your peers and potentially revealing to the
peers that you're the source of the transaction, because you're the first one
that tells them about it, you would connect to a random node on the Tor network,
only give the transaction to that node with a fresh connection to the Tor
network, and then disconnect from the Tor network again, and then hope to see
the transaction on the open network after as a way to confirm that it has been
successfully broadcast.

That way, we could get sort of a single hop Dandelion, where we just make a very
private first connection and a lot of the issues around when to submit it to the
broader network, to keep separate mempools for each of your peers for the
Dandelion transactions versus regular transactions, they don't apply to this
very simple approach.

_Why does everyone say that soft forks restrict the existing ruleset?_

**Mike Schmidt**: Next question from the Stack Exchange was, why does everyone
say that soft forks restrict the existing rule set?  And in looking at more
details of the motivation for this question, it seems that this person is seeing
that seemingly, you can still spend in the "old way", even after a soft fork, so
what exactly is being restricted?  And so Pieter Wuille answered this question
and provided the examples of the taproot and segwit requirements that were
added.

I think that the takeaway here is that it is restricting the rules and making
tighter rules, but it's not restricting common types of transactions or spends
or outputs.  It's restricting, ideally, some format of a transaction that hasn't
been used or has been used sparingly so that it has to adhere to the new rules.
Go ahead, Murch.

**Mark Erhardt**: I think this ties very nicely into our Waiting for
confirmation series post today, because this is an upgrade hook that has been
used.  We had essentially already put a fence around native segwit transactions
of higher versions.  So we've had v0 and native segwit for a while since segwit
came out.  But v1 through, is it 15 or 16?  I think 16, are consensus valid and
unencumbered by rules, but policy disabled.  So, we do allow sending to outputs
that use the new versions, but we prevent inputs from using the new version.
So, the restriction that we add here is, instead of having no rules applied to
v1 native segwit inputs, we now expect that they fulfill the template of taproot
transactions.  And that is a restriction from no encumberment to only the rules
specified in taproot, and that's how we get the restriction of rules here.

_Why is the default LN channel limit set to 16777215 sats?_

**Mike Schmidt**: Next question from the Stack Exchange is, why is the default
LN channel limit set to 16777215 stats?  We have Vojtěch, who explained the
history around that limit, and then the change to wumbo channels at some point,
and also linked to our Optech's large channel topic for more information, which
includes a quote from Rusty saying that people are going to lose money using
this new technology, and he would sleep better if he could pay you back with a
beer or coffee, with the amount that was potentially lost with this new
protocol.  That was an early quote of his. and I think since then, it was 2018,
allowed these wumbo larger size channel sizes.  I thought that was interesting
that we got a topic reference from the Stack Exchange.  Murch?

**Mark Erhardt**: Yeah, it's funny how 42 millibitcoin is the cost of a beer,
though.

**Mike Schmidt**: Maybe not anymore!

**Mark Erhardt**: Yeah, not quite, I mean it's like $1,200!  But yeah,
essentially Lightning is fairly complicated.  It's extremely simple if you think
about what the core concept is, and it only uses the idea that you can spend an
output in two different ways, either locked by a hash or locked by a time.  And
then on the other hand, well, we have the Lightning Summit here this week, and
we had 30 or so Lightning developers yesterday at our New York BitDevs, and
they've been working, people have been working on Lightning for eight years.

This simple idea and just trying to work out all the engineering challenges
around that is keeping about 40, 50 people full-time occupied, working on three,
four, maybe five Lightning implementations now.  So, the foresight of Rusty to
say, you know what, people are going to use this before it's ready, and let's
limit how much funds are on the line when people are recklessly storming the
network, seems pretty foresightful at this point.

_Why does Bitcoin Core use ancestor score instead of just ancestor fee rate to select transactions?_

**Mike Schmidt**: Next question from the Stack Exchange is, why does Bitcoin
Core use ancestor score instead of just ancestor feerate to select transactions?
And I know we talked about this briefly in our Waiting for confirmation series a
few weeks ago on incentives.  Gloria, how would you frame Suhas' answer to the
question?  He seems to outline that it's a performance optimization.

**Gloria Zhao**: Oh, so ancestor score, sorry, I didn't prepare, but ancestor
score is the minimum of your ancestor feerate and your own feerate.  So, you can
imagine a CPFP, you're bumping your ancestor, so your ancestor feerate is going
to be lower than your own feerate because you're fee bumping your ancestors.
Whereas, you can also imagine situations where, I don't know, you're spending
your change output from a payment that was pretty urgent, but this new payment
using your change output is not as urgent, so the child transaction actually has
a lower feerate than the parent transaction.  So in mining, there's no point.
If you look at ancestor feerate alone, it doesn't make sense in that case.

But anyway, so we could still use ancestor feerate as the first sort, where you
take the highest ancestor feerate, and then you take that one, and then you
start adding those to the block and then updating things as you go, but that's
less efficient than using ancestor score, which is the minimum, because you'll
catch things like the child having a lower feerate sooner.  I can go and read
Suhas' answer, but okay, maybe Murch has!

**Mark Erhardt**: There's another thing here that is a little more subtle.  So,
in a straight line of transactions, or let's say when one transaction has a tree
of ancestors that is more complicated, for example a diamond or just two parents
that both have a -- let's say you are spending from two CPFPs, then it is
possible if they have overlapping ancestry for your own individual feerate to be
lower than your ancestor set feerate.  This is usually not easy to create, but
it makes it fairly difficult to decide whether or not transactions should be
included right now or not, because you can increase the overall ancestor set
feerate by adding two ancestor sets together that individually would have a
lower feerate.

So if you want to evaluate all of these situations conclusively, you spend more
computation time and it's just faster to opt.  Well, even if you're attaching
yourself to multiple sets of transactions and increasing the overall quality of
the package that way, we're just not going to evaluate it that way because it
takes more time and makes it more complicated.  And so we default to, you can't
be better than your own feerate.

_How does Lightning multipart payments (MPP) protocol define the amounts per part?_

**Mike Schmidt**: Last question from the Stack Exchange has to do with multipath
payments, which is a technique for splitting higher value HTLCs into many lower
value HTLCs, that may be more likely to succeed when you route them through the
network.  And the question is, how does Lightning MPP protocol define the
amounts per part?  So, when you're doing this splitting, is there some sort of
mandate in this protocol that says you should use a certain size part or a
certain algorithm to determine what those size parts should be?  And René
Pickhardt pointed out that there is no protocol specified or mandated part size
or algorithm for picking those sizes.  And he also points to a bunch of
research, a lot of which was driven by his own research on the topic into
payment splitting research, which I don't feel like I can try to summarize in
this discussion, but if you are curious, please check out that answer from René
and review some of the literature on that.

**Mark Erhardt**: Yeah, maybe just one comment here.  René has written, of
course, what has become known as Pickhardt Payments, which indicates, or he has
found an optimal solution to the flow problem there on how you should route
payments and how you should attempt to route payments, and so he's exactly the
right person to answer that.  My understanding is that it's not the optimal
solution to split into equal parts.  And yeah, other than that, I will join Mike
in asking you to read the source material if you want to understand all the
details.

_BTCPay Server 1.10.3_

**Mike Schmidt**: Next section of the newsletter covers Releases and release
candidates, of which we have one, and we have a representative from the BTCPay
Server team to give us the highlights of this release.  So, maybe, Pavlenex, you
want to introduce yourself, maybe give a quick summary of BTCPay Server for
people, and then a couple of highlights from this 1.10.3 release.

**Pavlenex**: Yeah, sure.  Thank you so much for having me, I hope you guys can
hear me well.  So, yeah, I'm Pavlenex, I've been working in Bitcoin open source
for six years now.  I've been mostly involved in BTCPay Server as a janitor or a
PM, however you prefer, and I've also been involved with Stratum V2 recently and
a bunch of other projects, but let's say BTCPay and Stratum V2 are my focus
these days.

BTCPay Server, so for those of you who don't know, it's just an open-source
self-hosted and free payment processor for anybody to use to accept Bitcoin
payments without fees, without intermediary, on your own terms.  I think it's
also a very important infrastructure project in Bitcoin.  A lot of people build
on top of BTCPay, we have a lot of projects built on top of it by using our
stack or just using our API.  So that's, I guess, the short description of it.
If anybody here does not know what BTCPay is, you can go to btcpayserver.org on
our website and read more about it, or just send me a DM, I'm happy to answer
any questions that you may have.

In terms of our releases, so this specific one that we released two days ago is
1.10.3.  Unfortunately, it's a minor release, which means a lot of boring work
and a lot of fixes and bug fixes.  But what may be interesting to hear is how we
came up with this release, so I'll tell you a very quick story.  So, the team
was in Prague for BTC Prague Conference.  We had a booth there and a lot of
people approached us with feature requests and simply to complain because as an
open-source project, we don't really keep a track of users, we don't know how
they use BTCPay Server or what problems they have.  So, people just kept
appearing in our booth and just reported bugs.  So, then we realized that all of
us needed to have notes, and then we took a bunch of notes.

Then once we were back from Prague, we tried to consolidate all that
overwhelming feedback from people, but then we started organizing it.  So, let's
try to fix things first before we ship new features.  And that also I think
shows the direction in which BTCPay Server is slowly going.  We are maturing, we
want to have core software, which is very stable, very high performance,
flexible, but then we also want to have, let's say, plug-in ecosystems so that
people can build features on their own, in a way similar to what WordPress maybe
is doing, even though some people may not like that model.  For us, it's been
quite successful, I guess.

So yeah, this particular one, well, you can see just by reading through the
release notes that we were heavily focused on fixing point-of-sale (POS) bugs.
The main reason for this is that we had a person in Prague accepting Bitcoin
payments in Paralelní Polis, which is like a co-working space for bitcoiners,
maybe also crypto people.  But they had, for that particular part of time, like
seven days, they had over 3,000 transactions on BTCPay Server POS.  So
obviously, they had a lot of feedback.  And for us, it was very interesting.  I
was always peeking around their shoulders, seeing how they use software, and
then we identified a bunch of things.

So, most of those bug fixes are actually around improving the POS experience,
fixing the NFC payments.  And then we have a couple of others, like crowdfunding
and a few others.  But I don't think that's very important for people or
interesting to listen.  But you can go to our blog to read about our 1.10.0
release; I think you guys linked it already.  And you can see some of the
highlight features, I guess, there.  But yeah, I will not bug you too much about
BTCPay Server.  I just want to say thank you for always including all of our
releases, even though they may be boring.  I really appreciate you guys, the
work you do, and yeah, also how correctly you always report on the work we are
doing, which means that you're doing quite a lot of research to be able to
convey all of the things that we are shipping.  So, thank you for that.

**Mike Schmidt**: Thank you for those kind words and thanks for jumping on last
minute within just a few minutes of us starting this Spaces.  I was hoping
somebody from BTCPay could join and you jumped on and you made it through an
hour-and-a-half to get to each segment, so thank you!

_Core Lightning #6303_

Next section of the newsletter is notable code and documentation changes.  The
first one that we have here, actually a slew of Lightning-related PRs, but the
first one is to Core Lightning #6303, which has a new command to set some config
parameters dynamically, presumably without having to restart.  This is somewhat
related to another PR we covered about CLN configuration recently, in Newsletter
#255, that helped with configuration specifically for passing configuration
options to plugins when they are restarted.  And I know that in that PR, they
were setting the context for a wider sort of rework of their configuration
setup.  So this builds on that.  Murch, any thoughts?

**Mark Erhardt**: Isn't it funny how for some reason, all of these Lightning
people are looking to have all their decks in a row recently?!

**Mike Schmidt**: Maybe there is some sort of event going on?!

**Mark Erhardt**: Man, it's amazing!

_Eclair #2701_

**Mike Schmidt**: Next PR is to the Eclair repository, #2701, which now records
the timestamps of when an offered HTLC is received and when it is settled.  And
so, this allows tracking of how long those HTLCs are pending, at least from that
node's perspective, and it can be a longer pending HTLC may be an indication
that there is a channel jamming attack in progress.  And also having that
information, those timestamps, may also contribute to mechanisms which could
help mitigate such channel jamming attacks.  Murch?

**Mark Erhardt**: Yeah, we have talked a little bit about different types of
jamming and mitigations in the past few months.  So, just as a reminder, the
researchers working on this topic generally distinguish between slow jamming and
fast jamming, where fast jamming just means that you do a barrage of many
payments in order to lock up all of the slots on a channel, whereas slow jamming
is a way of just keeping a multi-hop payment open on the receiver end, not
pulling in the payment for a long time.  And especially with the recent block
space demand spike, some of the Lightning implementations have been increasing
their CLTV deltas, as in the time that each hop reserves on being able to close
their HTLC out onchain in case that a payment doesn't go through or a peer
disappears -- sorry, just the latter, not the former.  And so the, I think that
jamming is moving forward.

We have the idea of having advanced payments in order to pay for every hop, to
pay a minuscule amount of satoshis to every hop for the opportunity cost of
keeping an HTLC open.  And on the other hand, we're talking about local
reputation of your own peers that if you work together with peers a lot and
forward payments for them a lot, you may start to endorse payments that they
have endorsed as coming from a good source as a means to protect at least half
of your channel capacity and channel slots against slow-jamming attacks.  And
yeah, that's just a short, small rundown on jamming again.

_Eclair #2696_

**Mike Schmidt**: Next PR is Eclair #2696, which allows users of Eclair to now
specify fee prioritization using keywords like slow, medium, or fast instead of
the previous option, which was specifying fee prioritization using a numbered
block target of when the user would want the transaction confirmed.  This fee
prioritization applies for the funding and closing transactions, and you can
configure those separately.  The default setting for both, I believe, is medium
for both the funding and closing, but you can configure different values for the
funding versus the closing.  And I took away from this PR that it's not adding
additional options, per se, but they're trying to get away from block targets,
and they're not just simply adding additional ways to provide that fee
prioritization.

**Mark Erhardt**: I think that's a good thing.  I think that the expression of
trying to express the urgency of your transaction in a block target is
inherently a weird UX.  People either want to be in the next block or in the
second next block; and after that, I think expressing it as count of blocks
seems odd, because that's not how people think about transactions.  People want
to have their transaction go through before noon or by next morning or by the
end of the week or something like that and expressing it as slow, medium, fast
is just a better way of going there.

_LND #7710_

**Mike Schmidt**: Next PR is to LND #7710, storing HTLC extra TLVs in Onion Blob
Varbytes.  And so TLV is Type-Length-Value record, and this allows spec upgrades
to transmit extra fields in this TLV stream.  Some uses for that extra data may
be route blinding, and it can also be used for channel-jamming countermeasures.
We also mentioned in the newsletter write-up that there could be other ideas for
future features.  And looking into the PR, another way this extra data could be
used was for keeping track of local reputation information about a forwarded
HTLC.  Murch, any thoughts on this PR?  All right.

_LDK #2368_

LDK 2368 allows accepting new channels created by a peer that use anchor
outputs, but this does require the controlling program or individual to
deliberately choose manually which to accept for each of these new channels.  So
LDK, as a library, isn't aware of what non-LN UTXOs the user's wallet controls
behind the scenes.  So, it uses this prompt to give whatever program is
controlling the wallet, and potentially LDK, a chance to verify that it has the
necessary UTXOs with sufficient value that could be required to properly settle
an anchor channel on chain.

**Mark Erhardt**: Do you want to talk about anchor outputs a little bit?

**Mike Schmidt**: Sure, yeah, I know there's a couple of PRs here related to
anchor outputs for LDK.

**Mark Erhardt**: Right, so my understanding from yesterday's BitDevs is that
anchor outputs are moving forward quite a bit.  So, anchor outputs help, of
course, or let me take another step back.  One of the issues that Lightning
channels have is that the commitment transaction gets updated every time there
is a state change of the channel.  State changes happen either when a payment
goes through the channel, both when the HTLC is created and the HTLC is removed;
or when one of the two peers just starts talking to their counterparty and says,
"Hey, I feel like the feerate's changed a lot", or, "I want to announce a new
flag", or generally want to change the features or parameters of the channel,
then they would also re-announce the channel.

However, if for example, at that point, one of the channel partners is not
present, or that hasn't happened in a long time, it is very easy for the
commitment transactions to have committed to feerates that are not current.  And
especially with the feerate spike we saw a while back, a bunch of channels were
just stuck at having commitment transactions with feerates that were very low
and underestimated, and by themselves the commitment transactions were not
competitive to be included in blocks and vice versa.  After you come down from a
fee spike like that, the feerate may be set way too high and when you do publish
a commitment transaction for a channel where the peer disappeared, you might be
overpaying by magnitude.

So, anchor outputs generally allow you to move that decision on what feerate you
might want to use to the time at which the commitment transaction is published.
The commitment transaction now only has to meet the minimum dynamic mempool
feerate, because we still need to be able to first submit the commitment
transaction into mempools in order to be able to CPFP it, but then after that,
the anchor output is available for you to attach a CPFP and to bring more fees
in order to bump the parent transaction, the commitment transaction, the actual
unilateral channel close that you want to perform, and your new transaction that
bumps it.

So currently, there's two anchor outputs on each transaction, one for each
party, and they have gone to a length to make these anchor outputs have
sufficient amounts that they will be cleaned up later.  And I think they did
that by making the commitment transaction have a CHECKSEQUENCEVERIFY (CSV)
timelock, so either party can claim them after the commitment transaction is
settled on the chain if they hadn't used it for bumping yet.  And then after a
few blocks, it becomes ANYONECANSPEND, and people can just go and clean up those
anchor outputs.  And I think they are at 330 sets or something, so it should be
economical to clean them up at low feerates later.

We had a speaker request or something, or did I miss something?

**Mike Schmidt**: I might've missed it, I didn't see it.

**Mark Erhardt**: Okay, anyway, that was just a little rundown on anchor
outputs, or maybe one more sentence.  In the long term, of course, we would hope
to transition to v3 transactions and ephemeral anchors, which further improves
the situation, because now you only have to have a single output on it.  The
ephemeral anchor is ANYONECANSPEND but has no value itself, and we force people
to -- they can only publish a transaction with an ephemeral anchor if the
ephemeral anchor is spent in the same package.

That's at least the concept right now.  Of course, this is all work in progress.
And that would both make the transaction, the commitment transaction smaller,
would fully move the funding of the commitment transaction to the time when it
is published, and ephemeral anchors can be tiny because they have an OP_TRUE
output, which is only 9 bytes.  So, yeah, lots of movement in that area.

**Mike Schmidt**: Oflow, did you have a question?

**Oflow**: Yeah, I just missed the last thing.  Can you explain the anchor
again; what does that mean again?

**Mark Erhardt**: Sorry, in the interest of time, I think you can listen to the
episode later.

**Oflow**: Yeah, thank you.

_LDK #2367_

**Mike Schmidt**: Well, Murch just gave a great overview of anchor outputs, and
that was in relation to LDK #2368.  And there's also the LDK #2367, which makes
anchor channels accessible to regular consumers of the API.  This PR removes the
config flag that was temporarily hiding anchor-related API calls from the public
API, and so they've removed that.  So, that's accessible now to anybody using
LDK who wants to do anchor channels.

**Mark Erhardt**: One thing that I missed was, especially with the spec summit
currently, I think that the different implementations have been coordinating on
anchor outputs, and there are at least two, I think, that have finished
implementations now.  So I think we're moving to an anchor-output-based
commitment transaction system more broadly now; it's starting to get adopted,
from the top of my head.  I'm not really that plugged into Lightning.

_LDK #2319_

**Mike Schmidt**: Another LDK PR, #2319, which allows a peer to create an HTLC
that commits to paying less than the amount the original spender said should be
paid, allowing the peer to keep the difference for itself as an extra fee.
Murch, why would we allow such a thing?

**Mark Erhardt**: Well, if the last hop, the actual recipient is good at leaving
a little bit of the funds with the previous hop without the sender needing to
know about that, you can do fun stuff like open a channel from -- sorry, I think
it's useful in the context of loops, submarine swaps, where you are trying to
pay the service provider a fee.  And since it's strictly opt-in, if the last hop
forwards too little and the recipient says, "Well, that doesn't match my
invoice", they can just decline it, and the last hop fails at claiming those
funds.  But if the last hop and the recipient agree, they can have an
out-of-band agreement on some extra fees going to the last hop that weren't
present in the onion messages, because those are constructed by the sender, of
course, and they don't necessarily know that they're under the hood paying both
the last hop and the recipient.

So, yeah, I think it's a building block for making stuff like fees for submarine
swaps and splices and loop in and loop out and dual funding and all of those
things easier to do, and it sort of is an alternative approach to the proposal
of Thomas Voegtlin that we talked about last week, where he suggested that there
may be two payments specified in a single invoice.  I think that you can
achieve, in some use cases, a similar thing by just letting the last hop collect
a little bit of the money intended for the recipient.

**Mike Schmidt**: And I think another use case that I'm not sure you mentioned
that we pointed out in the newsletter was the creation of just-in-time channels,
JIT channels, and so there's another use case there.

**Mark Erhardt**: Oh, yeah, that was the thing I was thinking of, or I was
supposed to think of!

_LDK #2120_

**Mike Schmidt**: Next PR is LDK #2120, which adds support for finding a route
to a receiver who is using blinded paths.  And noted in the PR, this is blinded
paths provided in BOLT12 invoices.  And so, blinded paths also has a few other
names, like rendez-vous routing, that we've used in the past, and that's the
technique to allow a Lightning node to send a payment to a node that is
unannounced without learning where that node is in the LN network topology.  And
so, now that is now also supported by LDK, so LDK is really cramming here.
Murch?

**Mark Erhardt**: Yeah, I was going to ask whether we should give an overview
into that one too, but are we running out of time?  We're almost at two hours.

**Mike Schmidt**: I think we could probably skip it this go-around.

**Mark Erhardt**: All right, yeah, I think you got the gist of it anyway.

_LDK #2089_

**Mike Schmidt**: LDK #2089, adds an event handler that makes it easy for
wallets to fee bump any HTLCs that need to be settled onchain.  Quote from the
PR, "Without having to worry about all the little details to do so".  Another
piece that I saw from the PR discussion was, "While the event handler should in
most cases produce valid transactions, assuming the provided confirmed UTXOs are
valid, it may not produce relayable transactions due to not satisfying certain
RBF mempool policy requirements".  And also noted, and related to that
potentially invalid transaction, that, "While we may consider implementing this
in the future, we chose to go with a simpler initial version".  Murch, did you
get a chance to look at this one?

**Mark Erhardt**: Unfortunately, I'm unfamiliar.

_LDK #2077_

**Mike Schmidt**: Okay.  Next PR is also to LDK, #2077, which is essentially a
refactor PR that refactors a bunch of code that makes it easier to later add
support for dual funded channels, which is exciting.  I don't have any comments
from the PR on that one.  Murch, anything there?

**Mark Erhardt**: Yeah, so I don't know how familiar people are, but there are
some interesting dynamics around the person or the user that opened the channel
versus the counterparty, in who pays for fees.  And so, in one side where this
expresses is that when the two participants disagree on the feerates that
commitment transactions have, they have slightly different interests because
some of that is always paid by one side.  And from what I understand, Dunxen is
just moving here to more clearly track what type of channel it is; is this one
where we open the transaction or is it one where the other party open it?  That
makes it easier to have the right code routines to negotiate and to keep track
of stuff, and yeah, in light of dual funding, to maybe have a separate category
for that as well.

_Libsecp256k1 #1129_

**Mike Schmidt**: Last PR here is to Libsecp repository, #1129, implementing
ElligatorSwift technique.  Murch, you did the write-up for this, I think you'd
be better suited to give a summary of what is ElligatorSwift and how it fits
into some broader initiatives?

**Mark Erhardt**: Yeah, sure.  So, ElligatorSwift is a technique of essentially
encoding a public key, an ECDSA public key, in a 64-byte value that is
indistinguishable from random data.  And so, one of the things on how nodes on
it -- well, Bitcoin nodes on the network are very easy to fingerprint because
they send Bitcoin traffic and all traffic is currently sent in the clear on the
network.  There has been a long-time initiative in trying to encrypt all traffic
on the Bitcoin network.  This is currently moving forward in form of BIP324, the
v2 P2P protocol, in which all traffic will be encrypted.

This still means that it's probably fairly easy for ISPs and other nodes along
the route in the internet to tell that people are participating in Bitcoin
traffic because, well, a node was found and suddenly the traffic of that kind
spikes, and so forth.  But in the long term, not only do we want to encrypt all
the traffic, but there is the thought of allowing nodes to authenticate with
each other.  And ElligatorSwift is here used to, actually I think I'm jumping
ahead too far.  ElligatorSwift is used to establish the handshake for the BIP324
P2P messaging.  And instead of telling at the handshake, "Hey, here's my pubkey
that I want to use to establish an encrypted session with an ECDH", we send 64
bytes of random-looking data and it becomes indistinguishable.  Sorry, did I get
everything?  Am I missing something big?

**Mike Schmidt**: No, that's great.  Yeah, I mean, it's pretty cool that this
got merged.  Obviously, it's another step in moving forward with BIP324, and
it's pretty cool that they've done this in a way that it looks totally random to
an onlooker.  So, pretty impressive technology.

**Mark Erhardt**: Do let me jump a little bit ahead, though.  So, once we have
all traffic encrypted, we would like to authenticate each connection, or at
least pretend to authenticate each connection, to make it really hard to
man-in-the-middle attack.  And while it's hard to show or to pretend that we're
not Bitcoin traffic, I think it will be fairly easy for other protocols to
pretend that they are Bitcoin traffic.  And this could, for example, help other
P2P networks to hide traffic that looks like Bitcoin traffic; and it will make
it easier to, for example, if you have a light client that you want to be sure
is talking to your own full node, to authenticate that you're talking to your
full node and to authenticate from the full node's perspective that the light
client is the one that you're talking to.

So, there is a very nifty, cutting-edge cryptography research paper coming out
at some point that describes this technique that we're working on.  I think it's
been described, a counterparty has been described before, but yeah, there's some
really cool stuff that's just moving on a more year-to-year scale that's going
on and hopefully coming out; well, this decade!

**Mike Schmidt**: And if you're curious a bit about this authentication that
Murch mentioned, we discussed it a little bit in our Newsletter #255 Recap, in
our discussion with Matthew Zipkin, I think it was in the Bitcoin Core PR Review
Club section, where we were talking about one of his PRs and brought this topic
up.  So if you're curious, you can jump to that section of that podcast and
listen further if you're curious what the use cases might be there.  Murch?

**Mark Erhardt**: I think I said the wrong word.  I'm talking about countersign
and we do have an Optech topics page for countersign.  So, if you are interested
in the mechanism that is being proposed for how we will do authentication on the
encrypted v2 P2P transport protocol, that would be the page that you're looking
for.

**Mike Schmidt**: Any announcements before we wrap up, Murch?

**Mark Erhardt**: Yeah, I have to fill my own bags again.  We had a lot of
Lightning people in our office this week.  We sat down with Rusty for the
Chaincode podcast, and with Rusty we talked more about what are all the
important things that Lightning developers are working on; and the other one is
we sat down with Elle and Oliver from LND to talk about the situation with
simple taproot channels where funding outputs for Lightning channels.  We will
hopefully soon be moving towards using taproot outputs as the funding outputs,
and there's a lot of discussion still around the exact details of that.

As we're speaking, the Lightning Summit is discussing this and other topics for
the spec, and we picked the brain of Elle and Olly a little bit on that, and
those episodes of the Chaincode Podcast will be coming out sometime in the next
couple weeks and I think they'll be really cool.

**Mike Schmidt**: Excellent.  Yeah, thanks, Chaincode Podcast is a great
podcast.  So, if you're a listener of our Optech Recap Podcast, you would
definitely find value in those discussions, so I encourage you to subscribe to
that feed as well.  Well, thanks to my co-host Murch for a great marathon two
hours this week.  We had some great guests.  Thank you to Gloria, Robin, Dave
for jumping in, Oflow for some questions, and also for Pavlenex for representing
BTCPay.  And we'll see you all next week.  Cheers.

**Mark Erhardt**: And Bitcoin Sikho, and yeah, thanks, was a great episode.  See
you soon.

{% include references.md %}
