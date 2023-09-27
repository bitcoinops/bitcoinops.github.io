---
title: 'Bitcoin Optech Newsletter #226 Recap Podcast'
permalink: /en/podcast/2022/11/17/
reference: /en/newsletters/2022/11/16/
name: 2022-11-17-recap
slug: 2022-11-17-recap
type: podcast
layout: podcast-episode
lang: en
---
Mike Schmidt is joined by Salvatore Ingala and Clara Shikhelman to discuss [Newsletter #226]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-7-23/344163965-22050-1-47dfb81e92649.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Thanks for joining everybody.  This is the Bitcoin Optech
Newsletter #226 Twitter Spaces Recap.  Some quick introductions; myself, Mike
Schmidt, contributor to Bitcoin Optech, as well as Executive Director at Brink,
where we fund Bitcoin open-source developers.  Salvatore, you want to introduce
yourself?

**Salvatore Ingala**: Yeah, my name is Salvatore.  I work at Ledger on the
Bitcoin application.  But today, I'm here mostly for some research that I'm
doing on the side on governance and Bitcoin smart contracts.

**Mike Schmidt**: Clara, do you want to introduce yourself and your background?

**Clara Shikhelman**: Hi, so I'm Clara, I'm a researcher with Chaincode Labs,
and one of my recent projects has to do with unjamming the Lightning Network.

**Mike Schmidt**: Excellent.  Well, thank you both for joining today.  We'll be
missing Murch, as he is down in El Salvador at the Adopting Bitcoin Conference
currently and was unable to join this week, but he'll be back next week.  I
think we can just jump into the news here.  We'll just go in order.

_General smart contracts in Bitcoin via covenants_

I will post the tweet thread as we discuss here, so everybody can follow along,
but this is Newsletter #226, and the first news item is general smart contracts
in Bitcoin via covenants.  And luckily we have Salvatore here, who authored a
Bitcoin-Dev mailing list proposal for a new type of covenant, and we can have
him maybe walk through the motivation for that, maybe compare and contrast with
some other proposals, and how it could benefit things like joinpools or
optimistic rollups.  Salvatore, you want to give a bit of background about your
motivation here, why did you start this side project; what are you trying to
achieve; maybe compare with some of the existing proposals out there and walk us
through your thought process?

**Salvatore Ingala**: Yeah, sure.  So, I don't know how much we should assume
about covenant knowledge on the audience.  Should we introduce also what
covenants are, or are we diving into this?

**Mike Schmidt**: Yeah, I think it's a good idea for you to maybe explain
covenants at a high level and what your interpretation of what that can enable,
etc, and then we can go to your proposal.

**Salvatore Ingala**: So, to keep it as simple as possible, so a covenant, there
might be a different definition for different people, but for me, what I
consider a covenant is, is any UTXO, so any coins that have any kind of
restrictions on the destination of where these coins can go, right?  So
typically, when you lock some coins in any kind of wallet, single-signature,
multisignature, you specify what are the conditions to spend the coins.  But
once you prove that you are able to satisfy those conditions, there is no
restrictions of where you send these coins.  And so the idea of adding covenants
is that by adding some restrictions on the outputs, there are some interesting
constructions that can be done.

So, the first published idea I think back in 2016, was about using covenants for
something like a vault, where instead of spending coins directly, you have a
two-step process where on the first transaction, you take coins out of the
vault, but then you have to wait for a week before you can spend them; and then
on the second transaction, you can spend them wherever you want.  But in this
week, if the transaction was not something that you wanted to do, you have time
to claw back these funds, for example.  So, this is an example of something that
you could do with covenants.  And so more recently, there are many ideas of
different kinds of covenants that could be used for different things.  And so to
go more specifically on the idea that I'm discussing and proposing, this is
something that I was already thinking probably back in 2019.  At the time, the
application was something that is called state channels, which can be considered
as a generalization of Lightning channels.

But more recently, I started to be more interested in the idea, because I
realized that there are actually more potential applications, and there are some
other things that happened.  One is that the Bitcoin community is more open to
talk about covenants now, there is more interest, and there are more
applications that we realize now that are possible to do.  And so, more
specifically, this idea that I propose, it's not yet an exact proposal for a
soft fork, let's say, like CHECKTEMPLATEVERIFY (CTV) could be.  CTV has been
already specified a long time ago, so there is one specific opcode, and there
was even a proposal for a soft fork.  Well, here, it's more like discussing that
if you have some basic requirements on what you can do with a covenant, then you
can build certain constructions.

So, if you look at the, I think there is a link, yeah, there is a link to the
mailing post, there is some very simple things that you need the opcodes to do.
Like, you just need to be able to do two or three things.  So, one is that you
need to be able to commit to the future scripts of the output of the next
transaction, and that's similar to some other proposals, like CTV, but here you
want to instead be able to attach to the UTXO, to the new coin that you're
producing, some data that is computed by the script itself.  And therefore, it
can also depend on the stuff that is put in the witness stack.  And so, there
are these few basic ingredients for committing to the future scripts and being
able to forward some data.  It could be just a simple hash to the next output
and very simple operations that you can do on this data, and these very simple
things allow to do quite general constructions.

So, what I try to argue is actually that you can do fully arbitrary smart
contracts, but with some potential trade-offs, because we don't want to do
computations on the blockchain, and so the approach that is used is that instead
of doing the complex computations on the blockchain, you do the computations
offchain, and then there is a protocol that allows to prove that the computation
is correct.  I realize that I mentioned a lot of things a little bit too fast,
so I think I'll pause here for a moment!

**Mike Schmidt**: No, I think that's a great start.  I think maybe for
listeners, it might help to put what you've explained the infrastructure is in
into an example, and I know there are there was the chess example from your
post.  Maybe you can walk through that practical example and weave in some of
the details about your proposal there.

**Salvatore Ingala**: Yeah, so maybe even simpler than chess could be something
like, let's say, you want to play rock-paper-scissors on the blockchain, because
chess is something that has a lot of moves before you reach the end of the game,
right?  Well, rock-paper-scissors is just like, okay, Alice plays a move, Bob
plays a move, and that's it, right?  And so if you think about what is this game
as a smart contract, there are different actions that need to be taken from the
two parties.

There are just two parties, Alice and Bob, and the actions that they are doing
are very simple, which is like, okay, I make my move, you make your move.  And
so compared to a Bitcoin transaction that how we do now, that the only thing
that it does is spending some coins for destroying some UTXOs and producing some
new UTXOs, some new coins, if you want something that can be considered a smart
contract, you need to also have some kind of state.  So blockchains, like
Ethereum, that have smart contracts that have this arbitrary state, you can
imagine them as you're running some codes, so like a program that can update
some memory.  There is an infinite memory, which is a key value map, and you can
update it.  So, you can imagine programming and modifying this state.

But this has huge problems with scalability, because now this huge state needs
to be carried by all the nodes, and this is something that we don't want to do.
And so, the idea here is that in these UTXOs that are encumbered by the
covenant, we also carry the state, which is part of the smart contract.  And one
of the things that is not too difficult to understand, but need some thought, is
that you never really need to carry a large amount of states in the UTXO,
because one thing that you can do is that all this, if you need more than, let's
say, one variable, if you need ten different variables, instead of storing all
of them inside the UTXO, you can hash them and put the hash in the UTXO, right?
And to improve on this, instead of just putting a hash, you can build a merkle
tree that has leaves with these values, and you just put this hash in the UTXO.
This still commits to the entire state, and so you can use transactions when you
need to modify the state.  You can often go the rules on how the state can be
modified, and these transitions can be verified by script.

So, if you imagine playing a game like rock-paper-scissors, Alice makes her
move, and let's say it's rock.  And so the move, rock, needs to be added to the
state somehow; and then the next move is Bob plays the move, and so this also
needs to be added to the state; and now we can decide who's the winner.  Of
course, this contract has an obvious problem, which is, well, Bob will see the
move before he plays his move.  And so we need to improve on this and we can
discuss how to do this.  And the idea is to commit to the move before and reveal
it.  But this doesn't really matter for the design of the covenant itself.  Like
for the covenant to design smart contracts, what we need is that we need to be
able to commit to some state in the UTXO and we need to be able to verify that
we are updating the state correctly.  Once we have these two simple ingredients,
now we can do arbitrary stuff.  Then, making it scale is a whole different
issue, and then we can get into that.

**Mike Schmidt**: So the first step in this rock-paper-scissors example, there
would be an onchain transaction that would essentially enter both parties into
this game in which the rules are then applied via this covenant, and then some
state that's being able to be passed between that initial onchain state and
future states.  And those future states can all occur offchain and would then,
at the end of this example of the rock-paper-scissors, would you need to then
have an onchain to settle, or could you keep the settlement offchain, or how
could that work?

**Salvatore Ingala**: In the way I described it right now, I'm assuming all
state transitions happen onchain, right?  But of course, this doesn't scale well
because you don't want to do every transition onchain, but this is something
that you can solve in the same way that the Lightning Network solves.  Like for
many contracts, instead of publishing to the blockchain each single update to
the state, if you just have all the parties to agree what is the new state, what
they can do is, well, they sign offchain the state, the new state, and since
there are signatures from all the parties, anybody can go to the blockchain and
say, "Well, this was a state that was signed by everybody".  And this is
actually very similar to what eltoo will do for the Lightning Network, because
that's essentially what you can do.  You replace an older state with a newer
state, as long as everybody signs, you can do the entire game offchain.

So, the covenants themselves don't directly move contracts offchain, but they
allow arbitrary contracts.  And then once you can do arbitrary contracts, simple
economic incentives will push you to do as much as you can offchain anyway.

**Mike Schmidt**: That makes sense.  And you gave the example of chess, but then
you've also given this example of rock-paper-scissors, which is simpler in a
sense.  But then you also mentioned the fact that, well, of course, with
rock-paper-scissors, as opposed to chess, rock-paper-scissors is something where
you both act sort of simultaneously without knowing what the other person's
doing, whereas chess you sort of have these alternate taking turns.  And I think
you mentioned it's not necessarily germane to your proposal, but that in that
case, you would actually be doing commitments to your move so that you can have
that simultaneousness sort of simulated within the contract.

**Salvatore Ingala**: Yes, exactly.

**Mike Schmidt**: Okay, that makes sense.

**Salvatore Ingala**: And, of course, I want to clarify that examples with games
are not endorsement, they're just academic examples.  There are more interesting
contracts to do onchain!

**Mike Schmidt**: Yeah, we can get to that shortly.  I suppose that if we were
wagering in this rock-paper-scissors game, we would execute our commitments and
then reveal our rock, paper or scissors.  There would be a designated winner
based on that contract, and I guess if there was a bet that was wagered there,
that we would then publish that final version onchain, and I would get my money
because I chose rock, or whatnot; is that right?

**Salvatore Ingala**: Yeah, exactly.  One of the things that you would want to
add in the proposal is also some introspection, for example, on the output or
input amounts, so that you can allow to decide how the money is split, for
example, at the end of a contract.  But that's relatively easy to do.  There
were proposals already for an in-out amount of code in other covenant proposals,
and that's basically the same thing.

**Mike Schmidt**: And some protocols have done things like shove data into, like
OP_RETURN, or whatnot, to sort of keep state, and it sounds like what you're
proposing here is to put the state in the witness; is that correct?

**Salvatore Ingala**: So actually, one of the things that got me excited about
thinking about this proposal again is that taproot transactions, in particular
P2TR, has a very neat trick that allows to basically hide the state inside the
P2TR output.  Because by using this trick of using a merkle tree to represent
the state, basically the state is just a simple hash, 32 bytes.  And so, what is
a P2TR output?  P2TR at the same time, the typical P2TR transaction, encodes one
public key and a merkle tree of states.  This is what P2TR is if you read the
specs, right?  And so the way it does that is by using a trick in schnorr
signatures, where you can take a public key and you can do a process called
tweaking this public key, where you produce another valid public key; and the
new public key that you produce at the same time commits to the old public key,
but also some data.  And in P2TR, this is used to commit to the states.  So,
that's why you have the keypath spend and the script-path spend, where you can
have many different scripts, right?

So the idea is that, well, in this type of covenants, I need to commit to some
additional data, right?  And so the idea is that you can take a P2TR output that
has an internal pubkey and the tapscript, the taptree, which is all the scripts,
and you can use the same trick to take the internal pubkey and tweak it with the
covenant data.  And so in this way, what you get is still a P2TR output, and you
just have a different internal pubkey.  And then you can add one opcode to be
able to push this data, which is in the internal pubkey, to the stack, and this
is how you can allow this piping of the data that goes from the previous
transaction to the next pen.  So, you basically need the covenant opcode that
allows you to force the output to be a P2TR output constructed in this way with
the additional data.  And then on the next transaction, you will put that on the
stack again by using the same trick.  And so, this allows to embed this data
without any additional weight on the blockchain, because the UTXO is still as
big as a normal P2TR UTXO.

**Mike Schmidt**: Very cool.  We've been talking about games, chess, and
rock-paper-scissors.  What other more interesting financial things or smart
contracting things could you do with this sort of construct?

**Salvatore Ingala**: Yeah, so one of the things that gets me excited about
covenants that have this kind of power is that I believe that you can do really
arbitrary computations.  So, I think that any construction that you can do with
any kind of covenants should be possible with this type of covenant proposal.
There could be some trade-off that we can get into, but one of the applications
that was proposed was, I already mentioned state channels, but basically state
channels would be playing games like chess offchain and being able to settle
them, right?  This we mentioned already.

But there is the idea of doing coinpool, for example, that is a type of channel
factories.  One of the things that we don't talk about so much is that even if
Lightning is very cool and exciting and getting better over time, we already
know that it doesn't grow alone to a worldwide scale.  We cannot onboard
hundreds of millions of people on the Lightning Network where each of them has a
Lightning channel, so we do need other ways of allowing people to share UTXOs.
And so the proposal with coinpool is that instead of having two people to share
one UTXO, you will have a pool of many people, maybe 10, maybe 50, maybe 100,
that all share a single UTXO.  And still it's interoperable with the Lightning
Network.  So that was proposed with different covenant opcodes, but I am quite
convinced that this should be possible to be implemented also with these kinds
of opcodes as well.

Another thing that I'm excited about is that because of this mechanism of the
fraud proofs, it should be possible to implement a variant of rollups, in
particular optimistic rollups.  So, rollups are a scaling idea that is mostly
being researched in the context of Ethereum, but there was recently a very
well-written report by John Light about the possibility of introducing rollups
in Bitcoin.  And so, what is a rollup?  Basically, a rollup is the idea of
having a separate ledger where you can do transactions, and so you can lock some
money into some contract and then move coins inside this separate ledger, and so
there is some operator that handles the rollup, let's say, right?  But we want
the operator to not be trusted in terms of custodying the funds.  And with
rollups, in theory, it's possible to do that, meaning that the operator could
potentially censor, but if at some point the operator stops being honest, people
can just take their funds out and there is no trust required there, meaning
people are free to take their funds out by just using the blockchain.

The way they do this is by using zero-knowledge proofs, which is some magic
cryptography that basically takes some state of the rollup and then you get a
bunch of transactions and you get some new state.  And instead of putting all
these transactions on the blockchain, you just put the proof that you had some
valid transactions that bring the old state to the new state, right?  And so, if
you look at it this way, it looks very similar to what we can do with covenants,
because we have some state, we have some very complicated way of modifying the
state, and you have a final result, which is again a state.  And so the idea is
that to enable rollups in Bitcoin, we will need some kind of covenant, probably
a recursive covenant, and we will need an opcode, which is able to verify
zero-knowledge proofs.  This would enable what they call validity rollups, where
the transition is actually fully validated by the blockchain.

There is another variant, which is optimistic rollups, where instead of having
the blockchain validate the transition, the blockchain is optimistic, meaning
you accept the transition, but if the transition is actually not valid, people
can challenge it, and so can either bring what is called a fraud proof, like you
can prove that the transition was not valid, and then the operator will be
slashed and people can take their funds out.  So this is the idea.  And this is
probably not a good idea to try to explain it in a Twitter Space, like how the
fraud-proof mechanism works, it's pretty long, but there is a way of doing a
fraud-proof protocol that works for arbitrary computation.  And so it seems like
that it's possible using these kind of covenants to implement optimistic
rollups, where even if we don't have the opcode to verify zero-knowledge proof,
you can use a protocol instead of a single opcode, where if the proof is not
correct, people can challenge it, and there is a way of resolving the challenge
and figuring out who was right about it.

**Mike Schmidt**: Okay, so this proposal could help potentially with designing
joinpools, channel factories, potentially with optimistic rollups.  It sounds
great.  What are the trade-offs?

**Salvatore Ingala**: I would say the main open question is, do we really want
arbitrary smart contracts in Bitcoin, right?  So, there are different opinions
here, and there is actually also some research about what kind of problems could
that bring.  So, there was some research by Gleb Naumenko on trying to come up
with smart contracts that can be done with covenants, where you try to bribe
miners to transfer transactions, for example.  And so, the risk would be that by
enabling covenants, we enable some more complex smart contractive primitives
that could enable these things, that could skew the incentives for the miners.
So, this is something that there are different opinions, definitely need more
research, but it's definitely worth mentioning and worth thinking about.

**Mike Schmidt**: Okay.  What about, how has feedback been on the mailing list
or if you've spoken with people outside of the mailing list one-on-one, how do
you interpret the reception of the idea?

**Salvatore Ingala**: So far, it seems good.  I probably need to become better
at explaining things, but yeah, that will be an ongoing process.  I think there
are a lot of people who are getting excited about covenants and what can be done
with it, because it's getting more and more clear that the layer 2 space doesn't
end with Lightning, but there are potentially other things that could be done
that improve both the utility, meaning being able to do potentially more things
with Bitcoin, but even just scaling.  There are some potentially great scaling
solutions that would be enabled by covenants and definitely more research
needed, but that would be possible, plus other constructions like vaults are
definitely very interesting, because they could make self-custody a lot stronger
and easier.

So, definitely there are a lot of applications and I think a lot of people are
interested in finding the best possible ways of enabling these kinds of things
in Bitcoin.  And I think this proposal, it's strong in one thing, which is that
it shows that quite minimal and seemingly not changing -- some changes that
don't affect much what nodes have to do in Bitcoin, like it doesn't affect much
layer 1, actually enable layer 2 constructions that are a lot more general and a
lot more powerful.  So, I think it's exciting that potentially we could enable
to keep the layer 1 extremely simple and extremely lightweight, like it is now,
but still enable the same kind of layer 2 constructions that are possible
basically in any other altcoin.  Because we have seen that all the attempts at
making layer 1 scale basically ended up in nothing, but what is actually working
is actually finding other ways of making layer 2 solutions that work.  So, I
think that's a great research direction.  It's a lot in line with a Bitcoin way
of thinking on layer 1 and layer 2, and I think it's a very promising direction.

**Mike Schmidt**: Yeah.  Thank you for doing the research and putting this
together.  You mentioned you have a role at Ledger and I'm curious at all, is
this a part of that role, or are you literally stopping your day-job work at
Ledger and start in your free time doing this sort of research, or are they
sponsoring you to do that as well; how is that working?

**Salvatore Ingala**: So, as I mentioned, I already had this idea much before I
joined Ledger, at least the basic form of the idea.  I discussed it with other
people at Ledger, with Charles Guillemet, the CTO, and people are excited about
it, so it won't be difficult to find some time even during my job probably to
think about it, but it's still a side project.  I definitely look forward to
having more people thinking about it.  Already from some feedback I got, I got
multiple improvements already, and I definitely could benefit from contributions
from people who are more experienced than me in trying to modify Bitcoin Core to
actually make a proper covenant proposal, for example.  So yeah, I look forward
to having a community of people interested in developing on it, which seems to
be happening anyway because there is the workgroup on the IRC that started
recently to discuss about covenants.  And so things are moving, so I'm excited.

**Mike Schmidt**: Excellent, well thanks for coming on to describe your proposal
here.  Anything else that you'd like people to be aware of before we move on to
other topics?

**Salvatore Ingala**: No, I think that's all.  For any comment or any input,
feel free to write.  The website is the merkle.fun, and yeah, merklize all the
things, that's the message!

_Paper about channel jamming attacks_

**Mike Schmidt**: Excellent.  All right, the next news item in Newsletter #226
was a paper about channel jamming attacks, and we have one of the authors of
that paper, Clara, here to walk through what are jamming attacks and what are
these different types of attacks and what are their potential mitigation
strategies, based on some simulations and research.  So, I think for purposes of
this audience, we can assume that folks are familiar with Lightning and
Lightning channels, but perhaps a quick overview of channel jamming attacks and
what you're trying to get at here, Clara, to maybe lead into the research you've
done.

**Clara Shikhelman**: Sure, so this research work is a joint project with Sergei
Tikhomirov, which is also from Chaincode, and we decided to explore the
well-known problem of channel jamming in the Lightning Network.  The thing about
the Lightning Network is that when you route a payment, you pay a fee only if it
succeeds.  When a payment fails, you don't pay anything, everybody gets their
money back, but you can use it to do a lot of unpleasant things, and one attack
factor is just the jamming.  So, if there is a channel between Alice and Bob
that Eve just decides to render useless, she can send these transactions that
would never go through and stop the channel from working for a while.

So, each channel has two resources which are limited.  The first one is the
liquidity, that is the number of bitcoin that can go in one direction, and also
a number of slots.  That is, there's Hash Time Locked Contracts (HTLCs) in
flight that are not resolved, there's a limit on the number that can be on a
channel.  So, Eve can just take up all the slots, or take up all the liquidity
with these transactions and then never resolve them, so nobody else can use
these slots, or nobody else can use this liquidity.  So, the channel is stuck
and then Alice and Bob are not getting the routing fees, people can't send
payments through the network, and so on.  So, this is the basics of the jamming
attack.  The main problem with this, or one of the main problems, is that this
is completely free.

**Mike Schmidt**: Okay, so you've outlined the issue, an evil actor can sort of
tie up these limited resources.  And I guess maybe a quick question, do you have
research to say how often; I know some of these attacks, it's hard to tell
between an actual attack and just normal Lightning Network functionality, but do
you have research on how prevalent these sorts of attacks are in your
estimation?

**Clara Shikhelman**: So, probably not much of it is happening now.  But you
know, you usually want to prepare for the earthquake before the earthquake.
When it's happening, it's a bit too late.  So, the Lightning Network is, in many
ways, in very young stages, we don't see a lot of business attacks or things
like that.  But once the Lightning Network will be a really useful place, I can
just assume we'll start seeing that.

**Mike Schmidt**: Yeah, it would make sense.  Adversarial thinking in Bitcoin is
advantageous.  You mentioned the attack generally, but I know in your paper you
split the jamming attacks into two types of channel jamming attacks.  Do you
want to outline what each of those are and what the delineation between each is
in your mind?

**Clara Shikhelman**: Sure.  So, I will use this also to speak about the
solution.  So, the jamming attack, we split it into two main flavors.  In the
first one, the attacker just goes out there and it's very clear that they're
doing something wrong.  They send a payment or a series of payments over a
channel, blocking it completely, and then not resolving it for days.  If this
happens to your channel, you can very easily understand that either you're under
attack, or somebody is using the Lightning Network in a very, very wrong way.
So, somebody is doing something very wrong, you don't know if it's on purpose or
not, but somebody is doing something they should not be doing.  And this kind of
attack we call the slow jamming attacks.

The thing is, we're suggesting to mitigate them just by having a reputation to
your neighbors.  We can go into this a bit more later, but you're assigning,
you're telling your neighbors, "Okay, whatever HTLC you're giving me, there is
some responsibility on it.  And if I'll see you're sending me things that are
clearly doing something wrong, then we will have a bit of an issue here and your
reputation will go down".  The problem with this kind of thing is it's very
difficult to tell when is somebody clearly doing something wrong, right?  So, if
you're holding this for days, okay.  But let's say the attacker sends an HTLC,
it gets stuck for half a minute, then immediately they fail it, the HTLC is
released, and then immediately they send a new one.  And then they keep doing
this for hours.  So, at any given moment, you just have this one HTLC which
resolves within 30 seconds.  But at the end, this can continue for days, so your
channel is still stuck.

This kind of attack, it's trickier to blame and things like that, because it's
not clear if something is happening on purpose, not on purpose, what's going on.
And this kind of attack we're calling the quick version of the jamming attack.
And to resolve this, we're suggesting upfront fees.  So, the upfront fees can be
very, very low, but to do the quick jamming attack, you have to keep sending
this transaction, sending and sending and sending them, and then these fees
accumulate to something that can compensate the victims of the attack.

**Mike Schmidt**: That makes sense.  So, the mechanics of the attacks are the
same, you just categorize them into slow and fast.  You get an example of days,
and then you give the example of 30 seconds.  Is that roughly what you classify
the different attacks into, is something less than a minute versus something, I
guess, longer than hours; is that kind of how you categorize them?

**Clara Shikhelman**: Yeah, roughly speaking, I would think about this this way.
When implementing the solution, you will take upfront fees always.  But if
you're under slow attack, you need to decide something about the reputations of
your neighbors.  This is a decision that a node takes individually and doesn't
share with anybody else.  This is between the node and themselves.  And then
they are free to say, "Okay, anything under a minute, that's okay, I will not
take anybody's reputation down"; somebody might say, "Okay, I'm good with half
an hour"; somebody might say, "Okay, ten seconds and you're done".

So, we have some recommendations and there's a bit of a work in progress we're
discussing in the mailing list and on some calls, what exactly should be the
parameters and how we should go forward.  We're also considering other
solutions.  So, there's no magic number, but there are some suggestions.

**Mike Schmidt**: And you've touched on a bit about the upfront fees or
unconditional fees, I guess, that would discourage this fast jamming in which it
would be required to be done repeatedly.  So, you're slowly bleeding out
satoshis if you're trying to execute that attack.  You've mentioned reputation,
and maybe you can just dig into that a little bit more.  My understanding from
what you're saying is that it's not something where you're scoring this
reputation number and publicizing it to other folks.  That's something that's
local to your own node for your own purposes; is that right?

**Clara Shikhelman**: Yeah, sure.  So, let's start by talking about reputation.
So, there is a node and they have a few channels.  Now, for now, we're
suggesting binary reputation, your neighbor's reputation can be either high or
low, that's it.  And then in each channel, you're allocating some of the
liquidity and some of the slots for risky transactions.  Now, a transaction is
considered risky if either it came from a neighbor with low reputation, or a
neighbor with high reputation gave it to you, but they were not willing to vouch
for it.  So, each neighbor when sending a transaction will also say, "This is a
transaction, I can't tell you where it came from, but it either came from a
trusted source or I don't know where it came from.  Don't put it in only in the
risky allocation".

So, when I'm getting a transaction that I deem risky, I will check if I have
some of the slots or the liquidity allocated to this kind of transaction.  If I
have some, I'll give it, and if not, I will not.  When I get a transaction from
a neighbor with high reputation and they're willing to vouch for it, then I will
allow this transaction my full liquidity and all of the slots.  So, an actual
question is how do you even get a high reputation with a node?  So, our
suggestion is that first of all when we start, everybody starts with low
reputation.  You don't know who's the person on the other end, and they need to
start improving themselves.  We suggest that you start, first of all, following
others sending bad HTLCs, HTLCs that get stuck and things like that.  That would
stop them from getting a high reputation.  But if they, over time, repeatedly
send good transaction but clear quickly and accumulate enough fee, then after a
while and after they have done this to -- so, there's a threshold we're thinking
about but once they pass a threshold and prove that they're worth taking a risk
with, then you're saying, "Okay, you're a good neighbor, you can have the
liquidity and use of all of the slots.  So this is the idea of the reputation.

When it comes to upfront fees or unconditional fees, this is much simpler.  So,
when you're forwarding an HTLC, the person forwarding it will receive some fee
from you whether the transaction succeeds or not.  Now, it's very, very
important for the incentives to be correct.  This unconditional fee has to be
very low.  So, we don't want a node to be motivated just to take the
unconditional fee, tell you, "Oops, it just failed", and drop the transaction.
So we're suggesting a pretty -- our number that came up in simulation was about
2% of the total fee.  It is low enough so the incentive would be still to
forward the transaction down the route, but if you're under attack, this will
compensate the node for the fees that they're not getting because their channel
is not used.

**Mike Schmidt**: That makes sense.  And there's two parts to that fee.  There's
the one-time base fee, and then proportional to the payment amount, which I
guess is compensating for the liquidity that would be taken up with that
particular attempt.

**Clara Shikhelman**: Yeah, so because you can jam based on slots and based on
liquidity, so the base fee will take care of the case if the attacker is trying
to take up all the slots, and the proportional fee will take care of an attacker
that's trying to take up all of the liquidity.  And also, a lot of the
motivation we had when choosing the solutions had to do with how organic they
are with the Lightning Network, how easy will it be to implement, a lot of the
parts needed are already in use, and people know how to do this.  Sergi Delgado
helped us to do a very nice PoC for these unconditional fees, which is really a
change of two lines of code.  So, having this structure of the fees is also in
line with how fees already work in the Lightning Network, so it should make
everything pretty easy to implement and move forward.

**Mike Schmidt**: You mentioned implementation is fairly straightforward.  What
are the downsides of this approach to mitigating these types of attacks?
Obviously, there's some additional satoshis that would be required, and
obviously, there's some overhead in maintaining some reputation local to the
node.  Other than those, what potential downsides do you see with this approach
or considerations in this sort of approach?

**Clara Shikhelman**: So, with unconditional fee, there are two main downsides.
The glaring one is, of course, the user experience.  In general, people are
uncomfortable with trying to do something, failing, and then having to pay for
it.  So this can be, well, people that are very versed with the Lightning
Network, understand jamming, understand that it's really a very, very small
amount, would probably be on board; these are the reactions that we're getting.
For people that don't know and don't care about the inner workings of the
Lightning Network, they're usually using some kind of a wallet and this can be
obfuscated by the wallet itself, because the extra fee you have to pay if you
tried once or if you tried five times is not that different, it's a very, very
small change.  So, the wallet can say, "Okay, the amount of fees is going to be
at most X", and in almost every case you're going to pay less than X, which is
usually a pleasant surprise.  So, this is the UX part of unconditional fees.

Another issue is that the simplest way to implement the unconditional fees, so
say we have a route from Alice to Bob to Charlie to Dave, Bob will see how much
upfront fee in general, so along the whole route, Alice is planning to pay.
This is just an artifact of the easiest way to implement it.  This means that
Bob can guess how long is the route, because if there is a lot of unconditional
fee waiting to be paid downstream, Bob knows there is a long way to go; if
there's just a bit Bob, knows, "Okay, it's one of my neighbors, or neighbors of
neighbors, but this is not going far".  So, this can also be resolved by
slightly overpaying the upfront fee and then the sender will take whichever part
was overpaid and take it as part of the payment, but this is suboptimal because
there is a potential for some privacy leaks, which we definitely don't want
that, so this should be done carefully.

When it comes to reputation, so as this is something that is internal to the
node, the implementation is again pretty straightforward.  It's very, very
local, you don't need to change anything on the network or things like that.
But the main issue with this is that when you join the Lightning Network, it's
not as easy to transact things as for well-established nodes.  So, if you're
just going on the Lightning Network to make small payments, to buy coffee and
things like that, you never need the full use of the liquidity of channels or
the full use of slots; you're good, you probably won't even feel the difference.
On the other hand, if you're trying to establish a serious routing node, then it
might be that you'll need to jump a few more hoops, maybe by an established node
through somebody, or spend some more time creating a reputation with some
neighbors.  I don't think that this is going to change significantly, but it's
not optimal.

The issue is that when somebody is joining the Lightning Network, we have zero
ways to know, are they joining to just attack everything, or are they there to
be part of the Lightning Network?  So to say, we need to get to know each other,
at least on the neighbor level.

**Mike Schmidt**: That all makes sense.  So yes, you mentioned usability,
considerations around usability, considerations around privacy potentially, and
then I guess some considerations around the structure of the network factoring
into new nodes coming online, and somewhat being potentially discriminated
against a bit while they're earning their reputation?

**Clara Shikhelman**: Yeah, so these are the main considerations.  So, there are
some other suggestions that we're considering and comparing, but currently I
believe this is the best suggestion to go forward with.  There are some other
things that we have on our wish list that we just don't know how to do.  So, in
a perfect world, the fee charged by the node will just be a function of the time
the funds are locked in the channel.  But for now, we don't have a good way to
do this because there's no real notion of time either in the Lightning Network
or in Bitcoin.  So, there's no clock taking that we can rely on, but maybe
someday somebody will figure out a better way to do this, and we'll find a way
for all of us to agree about how much time passed from a moment, and then we can
move on to even better solutions.

**Mike Schmidt**: I believe in the paper you talked a bit about running
simulations.  I'm curious how you do that with something like the Lightning
Network.

**Clara Shikhelman**: So, when working on simulations, we had two approaches.
The first one, when you're thinking about an attack on a single channel, you
don't need to simulate the whole Lightning Network, right?  You need to have
Alice and Bob, and you need to have the attacker.  And then you do need to do
some guesswork about the flow of transactions from this to -- when we're
thinking about the unconditional fee, our main question in the simulation was,
how much of an unconditional fee you need to ask for so that the routing node
will be compensated when under attack.  So, for the routing, we wanted to be in
a situation where a routing node is earning the same amount of fee, whether
they're under a jamming attack, or if business as usual and only honest
transactions are coming through.

So of course, because the Lightning Network is private, we don't know how many
transactions are coming through, but we just used some standard guesses about
the distribution of transaction, both the pace and the sizes of these
transactions, and compared based on them.  Now, when a node is choosing how much
upfront fee they should charge, they can use the simulation and put in the
parameters that they know, because they know how much transaction they're
seeing, they can guess pretty much distribution, they can plug it in to the
simulator and get back the magic number of what should be the unconditional fee
for them not to care about jamming.

We also did slightly more sophisticated attack scenarios where there is a node
and the attacker is trying to block all of the channels at the same time, and
they can do something a bit smarter with how do they route through the channels
and things like that.  And to do this, we used a snapshot of the Lightning
Network and simulated above it.

**Mike Schmidt**: Very cool.  Yeah, I've spoken with people about trying to or
not trying to do such simulations, so that's why I was curious about it.  It
seems like you've gotten some reception on the mailing list.  How would you
classify the feedback so far on your and Sergei's work?

**Clara Shikhelman**: So for now, I think all in all the feedback is not bad.
People are asking very good questions.  So, we had already two conversations in
the spec meeting, and then we had the meeting that was dedicated only to the
solution.  We'll probably have some more, but I think for now the reception is
pretty good.  There are some things we should be very careful about before
changing, so personally I'm really looking forward to further discussions, and
there's a lot of choices to be made about how exactly to go forward with these
kinds of solutions.  And we're also revisiting old solutions just to make sure
we're not missing something in either of the two parts.  So, things are going
well, but I think it's the right choice to do things slowly and carefully before
changing anything network-wide.

**Mike Schmidt**: Seems reasonable!  Well, thank you for joining us and thank
you for doing this research.  Like you mentioned earlier, the analogy of an
ounce of prevention, so when things do happen, we're prepared for these sorts of
attacks, even if they're not necessarily prevalent on the network now.  So,
thank you for being proactive and putting your time towards that.

**Clara Shikhelman**: Thank you for inviting me.

**Mike Schmidt**: Absolutely.  Moving on in the newsletter, we have a monthly
segment about Changes to services and client software, and this is something we
do once a month.  We sort of aggregate a bunch of Optech-y related changes to
software out there, whether that's mobile apps or desktop apps or services that
are implementing scaling technology, implementing things like taproot.  And I
guess I would use this opportunity to ask the audience, if you see things in the
future that you think are interesting and applicable to this segment of the
newsletter, there's lots of software out there, and I am personally responsible
for this segment each month.  I have a list and I follow Twitter and I try to
make notes on these things, but if there are things you think we're missing and
that we should be aware of for this particular segment, feel free to tag myself
or tag the Optech Twitter handle so we can keep this list as comprehensive as
possible, given the plethora of software out there.

_Sparrow 1.7.0 released_

The first notable update was to Sparrow.  So, in Sparrow 1.7.0, they added
support for canceling transactions, and they're using RBF to enable that
particular feature.  So, I think we've talked a bit about using RBF to fee bump
a transaction, but in this case they're using that same fee bumping mechanism to
cancel a transaction.  So if, for whatever reason, you don't want that
transaction that you've already broadcast to confirm, you can feed bump and send
that back to yourself.  So, Sparrow's implemented that feature using RBF.

_Blixt Wallet adds taproot support_

The next change is related to the Blixt wallet and Blixt wallet v0.6.0 adds send
and receive support for taproot addresses, so that's great.  I know we had a
flurry of these taproot-related integrations over the last six months to a year
or so, and so it's good to see folks are continuing to adopt that.

_Specter-DIY v1.8.0 released_

Likewise, with this next item, Spectre-DIY has also enabled taproot keypath
spending support, so you can spend via the keypath, not the script path just
yet, but you can use that; you can use taproot with your Spectre-DIY.  And so,
folks are probably more familiar with Spectre's desktop application, but this is
a separate DIY hardware wallet that you can go out and buy the components for,
and there's some software obviously then to run that hardware and that software
now supports taproot keypath spending.  I would also note that they support
reproducible builds, which is pretty cool as well.

_Trezor Suite adds coin control features_

The next update was to Trezor.  So, Trezor Suite, which is the software that
interacts with your Trezor, has added some coin control features.  So, if you
want to get down and dirty with coin selection on your Trezor, you can now
choose which unspent outputs you'd like to use for your transaction.  And you
might want to do something like that for privacy purposes, or there may be other
reasons that you want to do that.  Maybe you yourself want to do some
consolidation of your UTXOs or, like I mentioned, privacy purposes, you might
want to do that.

_Strike adds taproot send support_

Strike adds taproot send support.  So, with Strike's wallet, you can now send to
bech32m taproot addresses, so they are off the naughty list on When Taproot? so
Murch will be happy about that.

_Kollider exchange launches with Lightning support_

And then the last notable update from client and service software this month was
an exchange called Kollider that launched.  I've seen they've been sort of in
progress for a year or so now.  And they're an exchange that is heavily focused
on Lightning.  So, I don't even know if you can deposit or withdraw outside of
Lightning, but the idea is that if you're trading, you want to put as few funds
as possible on the exchange, and there's obviously some timely reasons that you
might not want to do that given what's happened with FTX in the last couple of
weeks.  And so, Kollider lets you just quickly put in a Lightning deposit to
their exchange.  You can keep the minimal amount of funds that you need on
Kollider, and then withdraw those funds quickly using Lightning.

If you look at their announcement, there's some other software that they've also
released, including a browser-based Lightning wallet, which could be pretty
cool, so check that out.  That does it for client and service software updates.

_Bitcoin Core 24.0 RC4_

There are a couple releases that we noted this week, notably Bitcoin Core 24.0
RC4.  We have that in here, but the link in the newsletter goes to
bitcoincore.org, which actually doesn't have the binaries there right now, but
that RC4 has been tagged, and we have a testing guide that we link to in the
newsletter.  If you're interested in testing that release, use that guide as a
sort of jumping-off point.

_LND 0.15.5-beta.rc1_

And then there is an LND beta.rc1, which is just minor bug fixes, and I don't
think there's anything interesting to jump into with that particular release, so
we can jump to Notable code and documentation changes.  We have a few here from
Core Lightning.

_Core Lightning #5681_

The first one, Core Lightning #5681, adds the ability to filter the JSON output
of an RPC on the server side.  So if you're interacting with your Core Lightning
(CLN) node, you may be making a bunch of calls to the RPC and potentially
pushing a lot of data one way or another.  And if you're querying, for example,
your CLN node and a bunch of data is coming back, if it's local and it's on the
same machine, that might not be an issue.  But there are, more and more often,
these sort of remote interactions with Lightning nodes.  And so CLN enables you
to cut down on the amount of traffic you're sending.  So, in the case that
you're really only interested in a couple of pieces of data from an RPC and
you're remotely, you don't have to send back potentially tons and tons of data
on the wire to a remote client.  You can provide these filters and the server
itself will do the filtering and only send you back what you're looking for.
So, that can help from a performance perspective, so that was pretty
interesting.

_Core Lightning #5698_

Another PR here from Core Lightning, #5698 updates the experimental developer
mode to allow receiving onion-wrapped error messages of any size.  And we've
discussed these onion error messages previously, but there are some interesting
use cases that can be enabled with larger error messages.  And we talked a bit
with t-bast and Joost a couple weeks back on some attribution that could be done
and some interesting data that could be in those error messages that could be
useful, but it does require larger error messages.  And while BOLT2 recommends
256-byte error messages currently, it doesn't say that you can't use larger
messages.  And in fact, there's a PR to the BOLTs repository that encourages use
of larger messages, up to the 1024-byte, so that you can pass additional data
along the network.  And so this is a PR to CLN to support receiving those larger
error messages without any issue.

_Core Lightning #5647_

The final Core Lightning PR for this week is #5647, and that adds in a plugin
manager that's titled reckless.  So this reckless plugin manager can allow you
to install CLN plugins by name.  So, right now, well actually, always, CLN has
sort of focused on customizing your node using these notions of plugins, which
are pieces of software that you can download and customize to change how you
interact with your node and how your node performs.  And so, this reckless
plugin is a sort of, I don't know, I was thinking of it like an npm for CLN
plugins.  And so for example, currently, in order to install a plugin, you need
to find the source, copy it, install dependencies.  There's some testing you can
do, then you've got to activate it, and then you've got to update the config
file.  And so, what this reckless plugin manager does is you simply type in,
"Hey, I want to use this plugin", and you provide the name of that plugin, and
this plugin goes out, finds that plugin, and does all that work for you without
you having to do all of that.  So, there's obviously pros and cons to that, but
it obviously makes it a bit more convenient to install and manage plugins, so
that was a pretty cool feature to add.

_LDK #1796_

The next notable PR here is LDK #1796, and it updates the get_relevant_txids()
function to return not just the txids, but also the hashes of the blocks
containing those referenced transactions.  So, my understanding of this function
is that right now, it will return a set of txids that are towards the top of the
blockchain and at risk of potentially being reorgd.  And if you're an
application and you're using LDK, if you're curious about what those
transactions are that are towards the top of the chain, right now you have to do
any sort of tracking around which block those transactions are in.  And if that
block changes, you're responsible for sort of doing all of that bookkeeping.
Whereas the update to this function now will include not only those transactions
that could be reorgd, but also the block that they have most recently appeared
confirmed in, and that can help with some bookkeeping if you're an application
building on LDK.

_BOLTs #1031_

And then the last PR for this week is BOLTs #1031.  We've talked about this in
different contexts, but it allows a spender to pay a little bit more than the
requested amount when you're using multipath payments, and there's been some
various reasons that we've talked about the rationale for that in the past.  In
the past, we've talked about that in the context of, there's some privacy
concerns because you can overpay if you're an intermediate node, but not if
you're the final node in a hop.  And there were some privacy concerns about
that, and allowing overpayment can eliminate that detecting if you're the final
hop in that chain.  But for purposes of this week, we're talking about the
reason that you might want to overpay in a multipath scenario would be, an
example given in the newsletter here, that Alice wants to send a 900 sat
transaction in two parts, but both of the paths require a minimum of 500 sats to
be routed.  In that case, with the change in this BOLT, which is #1031, you can
actually now send two 500 payments to meet the minimums for your peers, and so
you actually end up paying 1,000 sats total, and you've overpaid by 100 sats,
but you're able to get the route that you preferred in that example, so another
use case for allowing these overpayments.

So, that's it for #226.  We only went a little bit over time this week.  I want
to thank Salvatore and Clara for joining us.  Thank you guys for your time and
thanks for hanging around for this space, as I think it's always great to get
the authors of these sorts of discussions and research to come on and explain it
for themselves, as opposed to Murch and myself trying to do the translation.
So, it's really valuable that you guys attended today.  Thank you, thank you
much.

**Salvatore Ingala**: Thank you, and thanks for the newsletter.

**Mike Schmidt**: Absolutely.

**Clara Shikhelman**: Thank you.

**Mike Schmidt**: All right, everybody.  We'll see you next week for Newsletter
#227.  Thanks for joining us and have a good week.  Cheers.

{% include references.md %}
