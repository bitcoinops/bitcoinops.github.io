---
title: 'Bitcoin Optech Newsletter #427 Recap Podcast'
permalink: /en/podcast/2026/10/20/
reference: /en/newsletters/2026/10/16/
name: 2026-10-20-recap
slug: 2026-10-20-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Erick Cestari and Adam Gibson to discuss [Newsletter #427]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-9-20/434600391-44100-2-fd16f64f2585c.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome, everyone, to Bitcoin Optech Newsletter #427 recap.
Today, we're going to be talking about two DoS bugs in older versions of
Eclair; we have the LN-GAP discussion, which is a way to run multi-round
contracts.  The example is like a chess game inside a Lightning channel.
We're going to talk about Bitcoin Core RC4 for 32.0, and then we have our
Notable code segment with a batch of Eclair fixes, among other things.  This
week, Murch, Gustavo, and I are joined by a couple of special guests.  We'll
have them introduce themselves.  Erick?

**Erick Cestari**: Hi, my name is Erick, and I'm a Vinteum grantee, and I've
been working on Bitcoin security, especially on LN.

**Mike Schmidt**: Adam?

**Adam Gibson**: Hi, I'm waxwing, I do various privacy and crypto research
projects.

_Disclosure of two DoS vulnerabilities fixed in Eclair v0.14.1_

**Mike Schmidt**: Thank you both for joining us.  We're going to tackle each
of your items first, as they are in the News section this week, first one
titled, "Disclosure of two DoS vulnerabilities fixed in Eclair v0.14.1".
Erick's back.  I feel like when Erick's back, it's like the old Matt Morehouse
is back.  Erick, you were on back in #421.  You joined us for the Core
Lightning (CLN) ping flood bug, I think it was.  This time, we have Eclair.
Maybe just to frame up the discussion a bit, when you have two Lightning nodes
and they open a channel between them, they go through a little handshake, and
the first message uses a temporary ID for the channel until the real one
exists.  And there's two bugs in that handshake that let an attacker with no
channel and no money at risk actually eat memory until an Eclair node falls
over.  So, Erick, you found one of them, Matt Morehouse found the other one.
So, this is like a joint disclosure, and you're representing sort of both of
them here.  Both were fixed in Eclair 0.14.1, that was back in July.  We
talked about that release in #416.  So, obviously, encourage folks to upgrade.
But, Erick, maybe you can give us a rundown of the two different bugs.  You
can start with whichever you'd like.

**Erick Cestari**: Sure.  Yeah, both are related to memory usage when running
the Eclair node.  And they are related to the pending open_channel rate
limiter that Eclair has to limit peers to open too much channels, and left
them pending without funding the transaction and let the channel be open and
not just stay pending.  So, the first one was found by Matt Morehouse using
his fuzzer, which is smite.  Basically, it was found by sending multiple
open_channel and detecting that it accepts the same temporary_channel_ID
because of a race condition.  So, when Eclair adds the pending channel to his
rate limiter, he would first check it and then later, asynchronous would put
it on the map.  So, there is like a race between checking and putting it on
the map.  So, if you send two or more open_channel it could get both on the
rate limiter.  So, you could do it and leak a heap object on the process.  In
doing it, Matt Morehouse measured it, and it could leak 1 MB of memory per
second until the nodes crash.  Yeah, so the impact of this one is the DoS.

The second one was found using some sort of AI scanning, just using an LLM to
find it, and it was found by me and the AI.  But it's also related to the
PendingChannelsRateLimiter.  When you are opening a channel, you need to
exchange some message.  So, first, the funder sends the open_channel, then the
fundee sends the accept_channel, the funder sends funding_created, and finally
the fundee sends the funding_signed message.  So, to know which channel we are
talking about, first the funder sends a temporary_channel_ID, which is 32
random bytes that the funder chooses.  And then, after the fundee sends the
accept_channel and the funder sends the funding_created, it gets the
FinalChannelId, which is basically the txid plus the index, the outpoint of
the funding transaction.  So, the issue in this one was related to how Eclair
adds the temporary_channel_ID and FinalChannelId on his rate limiter, which
you can say it's basically an array.  So, it would first check if this array
already contains the temporary_channel_ID.  Then, when it gets the
FinalChannelId, it would remove all the objects in the array by filter and
filtering by the temporary_channel_ID.

So, the issue is basically that you can send a temporary_channel_ID value as
the last pending channel you have with Eclair.  So, basically, you would first
send a random temporary_channel_ID, get the channel_ID, and then you send
another open_channel, setting the temporary_channel_ID as the previous
channel_ID.  And by doing that, when Eclair tries to filter and remove the
temporary_channel_ID on the array, it would actually remove the FinalChannelId
from this array.  And by doing that, it would leak memory.  It would also
write those actors on disk.  So, when it gets restarted, it would crash
immediately, because it would load from disk to memory and it would be like a
persistent crash and crashing over and over.

**Mike Schmidt**: So, for that last one, it sounds like at least Eclair thinks
that array never actually gets above, like, two pending channels, but like the
real number of pending channels is actually growing unlimited behind the
scenes; is that right?

**Erick Cestari**: Yeah, exactly.  And the fix for this, for the second one, I
forgot to say the first, but for the second one, is basically using the
temporary_channel_ID and checking this array for both channel_ID,
FinalChannelId and temporary_channel_ID.  So, we check if that value is
already used for a channel_ID.  And for the first one, let me just recap, it's
a race condition when adding the temporary_channel_ID to this rate limiter.
So, the fix is basically doing it atomically in a synchronous way instead of
doing it async.

**Mike Schmidt**: So, you mentioned the first one was found using smite;
that's the fuzzing engine that Matt Morehouse created, similar to the one for
Bitcoin.  And that's a fuzzing engine testing lightning implementations, and
it hit this state, and Matt Morehouse was able to figure out what caused that
state.  And then, second, you used LLM scanning tools to find it.  What did
you use?  I'm just curious.

**Erick Cestari**: I have used the Claude Opus 5.5, and I've built my own
scanning.  But if you search on the internet, you can easily find how it was
built.  It's based on a Cloudflare blog post, which is called Build Your Own
Harness.  Basically, the idea is to have some sort of a first agent that's a
recon agent that scans the codebase.  And it will get the trust boundaries of
the code, the entry points, and invariants that cannot be broken.  And then,
the hunters are basically the ones that found the bugs.  And the hunters
receive small tasks and well-defined tasks to do.  And those tasks are given
by the first recon agent.  And hunters can also create other tasks for other
hunters to do it.  So, it's kind of some sort of, like, the hunter will read
the code, get deep in, and find something suspicious, and let the other spy on
you, and create a new task for other hunters to finish and evaluate if there
is a vulnerability in that code or not.

So, about the smite one, we have an oracle, so building the smites, we can put
some oracles to check those invariants and see if the implementations are
respecting the BOLTs specification. And one oracle exactly that a node cannot
accept two open_channel that contain the same temporary_channel_ID.  So, it
detects it and probably Morehouse got deep in and found that could be used to
do a DoS attack.

**Mike Schmidt**: Both of these were fixed back in July, as I mentioned, in
0.14.1.  So, folks should upgrade if they haven't already.  I think we have
some more coming, it seems like from the notable code segment.  Maybe, are you
aware if this has been exploited in the wild, or was this just sort of fixed
before anybody could actually take advantage of it?

**Erick Cestari**: No, I don't think so.  And usually, Eclair, they update
their own node, they patch it right away.  So, I don't think anyone has used
it or exploited that.

**Adam Gibson**: May I ask a general question?  It's not really about the
bugs, but about Eclair.  Is it something that is recommended to be used
generally, or is it only businesses that use Eclair?  I don't have any sense
of that.

**Erick Cestari**: Yeah, I believe I cannot talk for them, but I have the
feeling that they use it for them, but they also provide the code if anyone
wants to use it, but I don't see much users using Eclair code.  Yeah.

**Adam Gibson**: So, it's principally just the company themselves, you think,
that use it?

**Erick Cestari**: I mean, it's open source, people could use it, but right
now, definitely they are the biggest one running Eclair.

**Mark Erhardt**: Yeah, I think it's a very especially geared towards an LSP
business.  So, they have a lot of things that they need themselves.  I think
there might be a few other instances, but it's a very low count, probably I
would say under 10 maybe.

**Adam Gibson**: Got it.  Thanks.

**Mike Schmidt**: Murch, Gustavo, anything else?  Or Erick, anything else
before we wrap up this item?

**Erick Cestari**: No, thanks so much.

**Mike Schmidt**: All right, Erick.  Thanks for your work on this and
responsibly disclosing, and joining us today to talk about it.  We appreciate
your time.  Cheers.

_Offchain contracts in Lightning channels_

Second news item from the Newsletter, "Offchain contracts in Lightning
channels".  This is LN-GAP.  I'm calling it LN-GAP, I don't know.  Adam?

**Adam Gibson**: Sure, yeah.  I mean, it's one of these somewhat comical
attempts to make something sound like an easy to pronounce word, right,
governed by arbitrary programs.  But yeah, it's LN-GAP, yeah.

**Mike Schmidt**: Well, welcome back to the show.  You were on in #422, I
believe it was, to talk about Babilonia.  And that was your proposal for
coinjoins that were disguised as sort of these covert onchain bets, so that a
chain analysis company couldn't tell that you were seeking privacy explicitly.
So, that was a cool project.  This one's a little bit different.  I will defer
to you, waxwing, on introducing this one so I don't butcher it.

**Adam Gibson**: Okay.  So, yeah, I was thinking this morning about how do I
explain this?  I think you maybe take one concrete example, which is the chess
game.  By the way, the repository, which is at AdamISZ/ln-gap on GitHub, has
Demos that you can literally play a game of chess and play a game of blackjack
on regtest if you want.  But yeah, maybe to introduce it with a concrete
example, and then it sort of expands out from that.  So, let's say you're
playing a game of chess.  Now, obviously, you can play a game of chess and bet
on it if you want, but that's got nothing to do with Bitcoin.  But the idea
would be that, let's suppose that we could decide fairly or trustlessly the
outcome of the game and assign the winnings to the winning party using Bitcoin
Script.  Now, that's already a can of worms, right, because what I think most
listeners will be well aware of is that there are severe limitations in the
kinds of rules that you can encode in Bitcoin Script.  Some people will be
familiar with the idea of little script and big script, and big script is
basically hashes and signatures and evaluating them as equal or not equal to
something, whereas little script is where you can actually do arithmetic, but
you can only do very limited arithmetic and it's only on 32-bit values.  So,
yeah, very limited.

So, if I say something like, "Oh, we can decide whether a move you're playing
in a chess game is valid in Bitcoin Script", that might make you think, "Oh,
that sounds hard".  And yes, it is hard, but at the same time, it is possible.
So, part of the thing here is to get some intuition that fairly complicated
games or, let's say, contractual relationships with complicated rules can be
decided in Bitcoin Script using a few tricks.  So, one of the tricks is the
idea of verifying one predicate to decide some much larger piece of logic.
So, something like, okay, somebody's saying to me that their move in chess is
to move the bishop from c1 to g5, one square to some other square.  And there
might be six or seven or 20 different reasons why that move is legal or
illegal.  In fact, when you write them all out, it ends up being like 10 to 15
distinct rules that you have to check to decide if a specific chess move is
legal or illegal.  And the idea is that the person who is trying to claim that
the move is illegal can do so very concisely by showing one specific rule that
is broken with one specific fact.

So, for example, if I'm saying I'm moving the bishop from c1 to g5, then maybe
there's a pawn on e3 which blocks that path.  So, the person who wants to say,
"Your move is illegal", can do so very concisely by presenting one specific
piece of evidence, such as a pawn, which is in the path from the beginning
square to the end square of the bishop's move.  And this sort of dovetails
very nicely with taproot as well, because the nice thing about taproot is that
you can embed tens, hundreds, even thousands of different predicates, that is
to say rules that evaluate something to true or false, in individual tap
leaves, taproot leaves.  And so, that means that in that example, there might
be, as I claimed, 10, 15 different rules that you can check in chess to say
that move is illegal, but they can all just be separate taproot leaves.  And
if the game is more complicated and it has 100 different such legality rules,
then they can just be tap leaves and nobody cares.

So, that's the first thing, is proving that some claim isn't valid by
presenting one small piece of evidence.  If some massive statement that you're
making is false, then logically it follows that one piece of it is false, that
kind of thinking.  The other nice trick, this is well understood by people
who've been looking at Bitcoin Script tricks over the last many years, the
other trick is to use things like Lamport or Winternitz One Time Signatures
(WOTS).  And why they're important is that we don't have things like CSFS
(CHECKSIGFROMSTACK).  If we want to debate between two counterparties whether
a certain state has certain properties, we kind of have to carry the state
from one transaction to another.  And the only way we can do that is because
without covenants, without being able to constrain, we need to carry state
from one transaction to the other by signing them.  And then, because a party
has signed a particular state, they can't then sign another state.  So, we can
both, as the counterparty, use their signature, and also we can create
conditions that prevent them from equivocating and signing another state later
or in a separate branch of a tree, or something like that.

So, those two tricks together give you ways that it is at least possible, and
you can either believe me or not, it is at least possible, with the limits of
Bitcoin, such as a limited stack size.  You can't execute some utterly massive
program because you can only ever put 1,000 different items on the stack by
consensus.  And yeah, there are also limits in size, although they tend to be
a little bit less unforgiving because of the size limit of, what is it now?
Well, again, it also depends on standardness, right?  So, 100 kB or 400 KvB
(kilo-vbytes), correct me if I'm wrong, Murch, is your standardness limit for
your transaction size itself.  Is that correct?  I think it's correct.

**Mark Erhardt**: 400,000, yes.

**Adam Gibson**: Yes, thank you.  So, that tends to be less of a restriction
than the stack limit for these kinds of things, where you're executing very
complicated logic and you're limited in how you can do arithmetic.  So, if you
want to do something like divide a number, you don't just divide a number.
You can't use OP_DIV, it doesn't exist or it's not valid.  So, you have to
mess around using additions and subtractions and moving things around.  So, it
turns out that's a bit of a restriction.  So, what was I saying?  So, I was
saying that, yeah, you could kind of just take it as a claim and you can trust
me, or not and look at the code, but it is possible to decide, move by move,
whether the opponent's move is valid given the current state, which as I said,
has to be sort of moved from one transaction to the other using WOTS, or
similar.  But then, think about this question.  Okay, let's suppose we can do
that, and let's suppose the transactions are not too ridiculously big, but
they will be quite big at certain points, do we really want to play chess like
that?  I mean, the answer is obviously no, right?

**Mark Erhardt**: I mean, it sounds very, very expensive!

**Adam Gibson**: It sounds expensive and it sounds slow, yeah.  I mean, maybe
you're a fairly slow chess-mover like some of us are, but in any case, it was
still expensive.  So, then you start thinking about this idea.  And this idea,
I think, goes back to when the Ethereum people were looking at ideas of state
channels.  So, they looked at payment channels, as had been invented in
Lightning, and they said, "Well, that's cool.  But in Ethereum, we have state,
we want to do complex contracts.  So, can we do the same thing as a payment
channel, but with evaluating steps of a contract?"  Seems like a sound idea.
And one idea that came out of that was what they called ForceMove, so as one
word, ForceMove.  The idea was very simple, really.  It was like operate
offchain optimistically.

So, Alice and Bob are in a contract or a game.  Alice makes a move, Bob makes
a move, Alice makes a move and so on.  And they sort of update state just very
similarly to how you do in Lightning; you update state as you make payments.
And the idea was that if one party stalls, so after move three in a chess
game, let's say, Alice has made a move, Bob realizes he's lost his queen or
something, and he's thinking, "Well, damn, I'm definitely going to lose this
game, so I'm not going to play anymore", which if you've ever seen children
playing chess, I'm sure you're familiar with this.  This is a very common
thing, that people just don't want to make a move, because they know they'd
rather go and do something else.  So, that presents a problem if you're trying
to make a trustless scenario.  And in ForceMove, the idea was very simple.  It
was, well, if the other guy doesn't move before a timeout, then you lift the
game onto the chain.  So, you then start playing the remaining moves of the
game on the blockchain.

So, this would seem like a step forward.  But as we've just observed, we don't
want to play chess on the Bitcoin blockchain.  It's going to cost money, it's
going to take time.  If the game is 30 to 50 moves long, we're talking about
hours and hours of waiting.  So, that's why I thought to myself, well, could
you go a step further and try to sort of somehow create an architecture where
the resolution to a person stalling and refusing to move doesn't necessarily
have to go on the blockchain?  And that was basically the idea behind LN-GAP,
the main idea.  So, how could that be possible?  So, it's in some sense an
insoluble problem, because how could you prove to the blockchain that somebody
stalled?  It requires the use of a clock, right?  And the only way you could
sort of resolve it using Bitcoin's clock is to go back to what we already
said, which is to force the game onto the blockchain where you can check, you
know, a timeout using a CSV (CHECKSEQUENCEVERIFY) or CLTV
(CHECKLOCKTIMEVERIFY) clause.

So, this is the basic idea.  Since our only problem is one of recognizing that
silence has occurred for too long, let's say, let's have a trusted third party
resolve only that question.  So, in the paper, I call it a venue.  And the
idea is that you post your moves to the venue.  Now, obviously, the venue
could just be one trusted third party and that wouldn't be great, but you can
distribute this amongst a group of entities, which the parties to the contract
could even just randomly choose them or agree on the set of entities.  It
could be 5, 10, 15, it could even be 100 different entities, all of which have
this power to attest that a move has taken place.  It's somewhat limited in
some ways but it has a pretty nice properties.  First of all, the two parties
in the contract, Alice and Bob, don't have to actually tell the venue what
their moves mean.  So, this is a bit of an echo of the client-side validation
concept, that the meaning of the steps are not relevant to the adjudicating
party, because all the adjudicating party is doing is saying that Alice signed
a move before deadline one, and then for move two, Bob must sign his move
before deadline two, and so on and so forth as you go down the list of moves.

**Mark Erhardt**: So, wait a minute.  Does this venue come into play for the
entire game and it just makes sure that time is passing, or is this only
happening once Bob the three-year old stops playing after losing his game?

**Adam Gibson**: Unfortunately, no, it's the entire game, because what it's
doing is it's saying each party made the relevant move before the pre-agreed
deadline.

**Mark Erhardt**: So, Alice and Bob agree on a venue before starting the game?

**Adam Gibson**: Yes.

**Mark Erhardt**: Okay, I see.

**Adam Gibson**: So, there is quite a lot of setup.  They have to agree on the
venue and that would usually involve agreeing on a set of parties that
constitute that venue; they would then have to presign a transaction tree,
hanging off a contract output within their Lightning channel for every move.
So, this is actually maybe another big limitation with the design, in that you
can't have an unlimited number of moves.  It has to decide in advance there's
going to be move 1 to 100 or 1 to 200, or whatever it is.  Why does it have to
do that?  Well, because they represent the conditions of the entire contract,
and if you don't agree all of them, then a person who doesn't want to continue
can stall.  Making sense so far?

**Mark Erhardt**: Right, so basically we're using a chess game just as a
stand-in for any possible contract.

**Adam Gibson**: Any possible two-party contract.

**Mark Erhardt**: Yes, important.  They agree on a venue, which is sort of an
arbitrator, but it only attests to the timing of actions in the contract.  And
you need to know how many moves at most a game will take in order to be able
to commit to the sequence of timings that each party has to fulfill.  Can you
make it dependent on the previous timing?  Let's say we actually played pretty
quickly in the beginning and I do a move, you do a move, we have the first ten
moves within a minute.  Would now Bob be able to stall?  Or, sorry, we're
playing, so would you be able to stall for 109 minutes, because we had
committed that each move has to be done within ten minutes?

**Adam Gibson**: Good question.  In the current implementation, yes.  So,
that's kind of a bit crappy, but it's still following the rules of a contract,
right, which is that there is a deadline.  Stalling isn't possible, but I'm
not sure if using CSV, I can't remember now if it's actually easy or possible
or really difficult to rearrange it so that the clock starts ticking from the
previous.  Is that possible at all, though, because all of this is happening
offchain?  I'd have to look into it again.  At the moment, the basic principle
is followed, which is that there is a deadline for each move, but that
deadline is not variable.

**Mark Erhardt**: Right, okay.  So, let's say we do a minute because we can
play more quickly, but we would set basically a timeline of up to 200 minutes
for the game.  And at any point now, the other player can grief you up to
number-of-moves minutes, but there's a deadline they cannot stall
indefinitely.

**Adam Gibson**: Exactly, yeah.  So, what else?  I did send a link.  Okay,
I'll just describe it.  If you go into the repository, so it's ln-gap under
AdamISZ on GitHub, and then if you go into docs, you will find, I think, one
particular diagram is the most useful to sort of grok what's going on, which
is in that docs subdirectory, there's a file called presigned-graph.md.  And
if you look at that graph, assuming it actually displays correctly, because
apparently it doesn't for some people, but if you look at that graph, it will
show you how the contract output sort of hangs off the channel in the same way
as the to-local and to-remote outputs hang off.  And I think it's interesting
to look at that to understand the logic of the game, because the general idea
is that the contract output holds the funds that are under dispute.  So, maybe
it's a bet and there's, like, $200 in there, whatever, and it's going to
decide who gets that money.  And it could decide that there's a draw and both
sides get what they started with, or it could decide that white wins or black
wins and that person gets all the money.  Now, how it does that is that
there's basically a process of claim and then sort of counterclaim, but it's a
little complicated.

So, the initial claim would be if anybody wants to do this, because they're
saying, "Well, you know what, Bob, he hasn't posted his move and the
deadline's passed, and I can see on the venue there wasn't any move".  And in
fact, there's a mechanism whereby venue members will set what they call a
flag, and they will actually publish saying, "Bob didn't actually post before
the deadline", and it will become a matter of a threshold agreement of
deciding, "Oh, there's enough flags saying, 'No, he didn't post it'".  So, if
I'm Alice in that situation, I post onto the chain.  Well, it's like a
force-close effectively.  I'm force-closing and I'm publishing a claim that
says, "Bob didn't publish his move".  And the logic is subtle because if I do
that for, let's say, move 12, I say, "He didn't post move 12 and he was due.
He should have done so before this deadline", one way Bob can counter me is he
can say, "Well, you didn't post move 11".  And that's actually really
important, because if you don't include that logical condition, then Alice
could just, at the start of the game, say, "He didn't post move 12".  Well, he
wasn't due to post move 12.  So, there's one little level of, like, recursion
there, which doesn't go into infinite recursion, but if Alice says Bob didn't
post move 12, Bob can counter by saying, "I wasn't due to post move 12,
because you didn't post move 11", and that would end it and Alice would lose.

But of course, assuming that she didn't do anything stupid like that, she's
saying, "No, he didn't post move 12 and he was due to", then Bob's rebuttal to
that claim is to say, "No, actually, here is move 12 and here is a signature
from one of the venue members that says, I did actually post it".  Now, think
about this; Bob could be cheating here.  If he's colluding with one of the
venue members, he could have maybe not had the move posted deliberately,
sneakily, didn't post it and didn't get a signature on it from one of the
venue members.  Then Alice says, "Oh, you didn't post your move".  He could
rebut and say, "Oh, look, I have got a signature from a venue member", because
the venue member's colluding and didn't post.  You see, the thing about
signatures is they're not timed, you don't know if a signature's been
published or not anywhere.  So, he could cheat like that.  So, that's why we
need to have what we call these flags.

So, what we do is we have individual points, as in curve points, from each of
the venue members, that they can broadcast the secret for, such that you can
count up with an OP_CHECKSIGADD counting mechanism how many of them said,
"This move did not occur before the deadline".  And that has to be a matter of
consensus over the venue.  It's not an objective fact, right?  So, you'll see
some sort of philosophical commentary about this in the paper, because that is
the fundamental trust assumption that you have to create.  And my argument was
that with a combination of positive, you can actually lock fees for publishing
these attestations.  Although it's a bit of a stretch, there are scenarios in
which you can create bonds that could be slashed if they publish false
attestations, and there's the fact that if some of your venue members are
public entities whose reputation depends on not making transparent lies, then
you can make that argument as to why they would not make false attestations
like this.  Go ahead.

**Mark Erhardt**: So, you got me thinking on why we would not just rely on an
arbitrator here.  So, if there's collusion, it breaks.  Obviously, the
arbitrator also wants to be able to prove that they behave correctly.

**Adam Gibson**: What do you mean by an arbitrator is distinct from what I'm
describing?  I don't quite get it.

**Mark Erhardt**: Right.  So, you have basically a timestamping service?

**Adam Gibson**: Yeah, kind of, yeah.

**Mark Erhardt**: And if they secretly provide a timestamp that they didn't
publish, you need to be able to catch that and the only mechanism to do so is
reputation, right?

**Adam Gibson**: Well, concretely, you catch it by other people, if they
secretly sign something and then only reveal it instead of publishing it in
the venue, then you catch it by the other members having attested, "No this
didn't happen, this was not published".  So, it's essentially a threshold.
It's a majority statement of what was and what was not published before a
deadline.

**Mark Erhardt**: Okay.  So, venue is really also a multiparty construct and
it must have multiple signers?

**Adam Gibson**: No, I mean, you can have just one, but then you're just
relying on one party.

**Mark Erhardt**: Sure, okay.

**Adam Gibson**: What I'm trying to say is it is an arbitrator, it's just a
question of what it arbitrates.  What it could arbitrate is the entire
contract logic, right?  You could literally think of it as in comparison with
putting money into, let's say, a sidechain controlled by a multisig
federation.  You might put the money into a sidechain so that you can do
things on the sidechain that you wouldn't be able to do otherwise.  The
problem with that, and I make this comparison in the paper, the big negative
with that is that that means that that entity controls all the funds of
everyone, right?  Whereas here, you're taking the two-party contract logic off
of control of anyone else.  That doesn't mean that you're not ceding control
of the money, because you are, 100%.  If there is collusion, the money and the
contract can be stolen unfairly by a counterparty, because they've managed to
convince all the venue to be on their side.  So, 100%.  That's why I think
it's interesting but it's not a perfect solution in that regard, but it does
mean that the venue is not controlling all the funds.

What I think is a nice illustration of where this might matter is in the
paper, I gave an example, a silly example, I call it the Iranian Service
Provider example.  But I pointed out the idea that if two Iranian people, like
a service provider and a client, wanted to interact and use such a venue, the
first nice point is that because the moves that they're posting don't contain
information that the venue can necessarily read, the venue might not know that
they're Iranian and that they're violating sanctions, or whatever.  So, if the
venue are American public companies, and then after, let's say, three weeks of
helping these Iranian people do their business, they decide, "Oh no, we've
just found out these guys are Iranian.  We don't want to offer them service
anymore", what they cannot do is freeze those two Iranian people's funds
because they never controlled them in the first place.  What they can do is
stop cooperating.

**Mark Erhardt**: Yeah, that's an important distinction.  So, the funds remain
controlled by the two participants of the contract.  The venue only acts as an
oracle and it only attests to the timestamps on the statements made by the two
contract members.  And the statements are used to resolve the contract.  So,
having the timestamp simply attests to the presence or non-presence of these
pieces of information that are used to resolve the result of the contract.
This does remind me a little bit of the oracles in the discreet log contract
(DLC).

**Adam Gibson**: I'm just laughing because I was about to say exactly the same
thing, and it's in the paper as well.  Ultimately, this is really just the DLC
oracle or the federation or the multiparty DLC oracle concept, but it's just
trying to boil it down to the smallest possible atom, which is the only thing
it attests is the existence before a time.  Instead of, let's say, attesting
the price of oil was such and such on this date, it's just attesting that one
fact.  But apart from that, structurally, it's absolutely the same basic
thing.  But in a way, all I'm saying is, "Oh, look, this thing that we already
have, this kind of DLC oracle design, can maybe do some interesting things
that you don't realize, not just things like games.  You can do things like
chess and card games, or what have you, but you could also have things like a
file storage service, like Filecoin type thing, with the nice property that if
the counterparty in the contract stops storing your file, and you can prove
that he's stalled, he's no longer sending the merkle paths or some random
chunk of bytes in my file, which means he isn't storing it anymore, I can take
all the money as a punishment.  The other implementations of that, Filecoin,
Siacoin, and some other ideas, they didn't have that property.  They just had
the property that if he stopped storing your file, you would stop paying him.
But in this case, you can actually get an insurance payout.  This is just an
example.

**Mike Schmidt**: How do the members get paid, if at all, the members of the
venue?

**Adam Gibson**: That's another really cool little detail that I didn't
mention.  I had this idea, what I called ECOTS.  So, instead of Winternitz or
Lamport one-time signatures, you could use elliptic curve one-time signatures.
And actually, again, it's very similar to DLC.  So, the concept of DLC is that
there's some fixed nonce, which means that the final result of the signature
is also fixed, it's just that you don't know it yet.  So, you could kind of
leverage that into making an atomic Lightning payment every time somebody
attests.  So, imagine there are 50 members of this venue.  That's generous,
I've only got five in my examples.  But let's say there are 50.  You send your
moves out, your chess game moves.  Every time one of them decides to attest
it, then in so doing, I can't remember how it works now, but in so doing,
there will be a Lightning payment that they will be able to receive by
publishing the move onto the venue.  And I thought that was a really nice
feature, because trying to create this kind of structure, well, it's a lot of
extra cost, right, having all these venue members, etc.  There kind of needs
to be a fee, a revenue stream that would incentivize that.

**Mike Schmidt**: Anything else you'd like to say on this item, waxwing, and
then we'll maybe have you tease some of your future work?  Murch, any
questions as well?

**Adam Gibson**: Okay, no, just that's already probably way too much.  But
it's very hard to explain.  But I think it's kind of a fun, somewhat limited
construction.  I've kind of taken the idea and run with it in a slightly
different direction in my next thing, which is to sort of remove the venue,
but for a specific application.  The thing I didn't mention, which I probably
should have, about LN-GAP, is if I'm claiming it's for arbitrary programs,
that's kind of bogus, because as was just described, Bitcoin has limited stack
size and a limited amount of space so you can't do any arbitrary computation
on it.  That's just not true, but I did describe in the LN-GAP paper that if
the computation you were doing was the evaluation of zero-knowledge proof
verifier, then you could be effectively proving the correctness of any
arbitrary program within this limited paradigm with the venues and there's a
certain trust and there's a collusion threat, and so on.  I still think it's
very interesting, but it has a limitation.

So, what I've been working on now is taking that same idea of verifying
zero-knowledge proof within a two-party contract so that you could create
effectively a kind of L2.  And without going into details, you don't actually
need a venue to do that.  And I'll just stop there because it's too much.

**Mike Schmidt**: Stay tuned, perhaps next week.  Waxwing, thanks for joining
us.  We appreciate your time and your work on this.

**Adam Gibson**: Thank you.  Thank you very much.

**Mike Schmidt**: Okay, that wraps up our news segment.  We can jump to
Releases and release candidates.  We're seeing this one a few times with
different RCs, but I'll turn it over to Gustavo to walk us through what might
have changed.

_Bitcoin Core 32.0rc4_

**Gustavo Flores Echaiz**: Thank you.  Yes, this is the fourth RC of Bitcoin
Core.  The testing guide was updated with this new RC last week.  And now, I
don't think I've seen any changes on what was included, just things were fixed
that remain.  So, listeners are invited to keep testing Bitcoin Core.  This RC
has a few new RPCs.  One of the major changes is the rewrite of the HTTP
server, which has removed the external libevent dependency.  But mainly in
there, the estimatesmartfee combined estimator, which now includes a mempool
feerate estimator, alongside the conservative block-based estimator and a few
new RPCs and updated RPCs.  So, nothing else to say, but go test it out.
Except, Murch, please jump in.

**Mark Erhardt**: Yeah, I think there's two more interesting things.  There
are new schemes, how we store the txindex and the txospenderindex.  One of
them is backwards-compatible, the other one is not.  But if you want to use
those indexes, you can delete the existing one once you've upgraded in order
to rebuild it and get about half of the space saved for those indexes.  For
the txindex, it's not downgrade-compatible.  So, if you want to go back to the
old version, you'd have to rebuild it with the old version again.  This can
happen, of course, from the blockchain.  It just takes a few hours to build.
But yeah, some people came up with some smarter ways of storing those indexes.
And that way, they take only about half the space.  That's kind of cool in an
age where we're running into our hard-drive limits maybe for some nodes.

The other one that I had in mind is, which one was it?  Never mind.  There was
something else.  Yeah, the mempool feerate estimation.  Oh yeah, the
connections.  We increased the number of connections a node makes by default
from 125 to 200.  But only half of those are able to support transaction
relay.  So, roughly the number of transaction relaying connections would stay
the same.  And what we really increased is the number of blocks-only
connections we accept.  The idea is blocks-only connections have very little
traffic.  Optimally, you only once announce every roughly ten minutes that you
have a new block, and the other party says, "I have it too".  And then,
besides that header every ten minutes, you don't really send anything.  But in
case you are being eclipsed, having a blocks-only connection that will
announce a new block to you makes you more robust against eclipse attacks.
So, having more blocks-only connections is very cheap and makes us more
robust.

**Gustavo Flores Echaiz**: Thank you, Murch.  Yes, waxwing?

**Adam Gibson**: Sorry, may I ask a brief question about that?  I always
wondered, even from the early days, why the numbers are what they are; 120
seemed quite high to me.  I totally agree.  Having more blocks only makes
sense.  But why are the numbers what they are?  Is there any science behind
that, or is it just what we think, what we feel?

**Mark Erhardt**: Well, I don't know how they got initially picked, but I
guess that the amount of traffic that nodes had was monitored somewhat
closely, and it was found to be all right for most people.  You can obviously
set different limits, so your node can have more or fewer connections.  And
also, because for the most part, we announce that we have new transactions,
but we don't actually send all the transactions on all the connections,
because each node only receives every transaction once, we hopefully don't
actually need all the bandwidth to -- what am I trying to say here?  There is
a diminishing cost for more peers, because the brunt of the data is sending
transactions, but you only actually have to receive each transaction once.
And so, you probably only have to actually send most transactions to a few
peers, because they'll also get it from other peers.  So, it might be less
data than one would intuitively think that is necessary to maintain a peer
connection.

**Adam Gibson**: Yeah, thanks.

**Gustavo Flores Echaiz**: Thank you for the question, waxwing, and for the
extra details, Murch.  Yes, if listeners want to learn more about the topics
Murch mentioned, they are found in the release note drafts in the P2P and
network changes.  And for the indexes, you can find in the section about
low-level changes.  It talks about both the txindex update and the
txospenderindex update.  That's it for the Release and release candidates.
Now, we jump on to the Notable code and documentation changes.  This week, the
main repo we look at is Eclair, which has announced about eight different PRs
covering multiple fixes.  These are packaged in four different items, so we're
going to go one by one.

_Eclair #3396, #3397, and #3400_

The first one, which combines three different PRs #3396, #3397, and #3400, are
different ways a malicious channel peer could prevent Eclair from enforcing
HTLCs (Hash Time Locked Contracts) onchain during splicing.  So, the first one
is one where Eclair would sign a splice transaction that could not get
published because, for example, the peer would have chosen a very distant
absolute locktime, it would have added inputs with relative timelocks, or it
would also provide non-standard witnesses that could get blocked by relay
policy, or additional changes such as exceeding the standard transaction
weight limits.  So, when Eclair would try to publish this transaction, it
wouldn't be able to do so.  And the commitment transaction based on this
splice transaction would simply never be able to be broadcasted, because the
transaction would never be able to get confirmed.  And so, now the fix is to
add checks on these cases.  Eclair will simply not sign a splice transaction
that cannot be published onchain because it has these different
characteristics.

The second case is one where Eclair is trying to publish a commitment or a
penalty transaction, but at the same time, the peer has published a
conflicting unconfirmed transaction that basically reuses a same input part of
a splicing transaction.  So, the peer proposes a splicing, includes his own
input, but at the same time publishes a conflicting transaction when Eclair is
trying to publish the commitment transaction.  So, what would happen is the
peer could then RBF his own conflicting transaction and publish one that
doesn't conflict with the splice or with the commitment transactions, and
Eclair would have just had to retry publishing the commitment transaction, but
Eclair would fail to do so.  So, the fix is for Eclair to keep watching.  If
the transaction that was conflicting doesn't get confirmed and another one
gets confirmed, Eclair simply has to keep retrying the commitment or penalty
transactions until they can be broadcasted and confirmed on-chain.

The third one is one where Eclair and the peer both agree on a splice, then
they both agree on an RBF replacement.  But before they agree, or at some
point, Eclair tries to force-close the splice transaction based on the initial
splice, not on the RBF replacement.  So, what happens if the RBF replacement
gets confirmed instead of the initial attempt?  Then, Eclair would have failed
to publish another commitment transaction that force-closes the RBF
replacement of the splice, and that would have left funds locked and HTLCs
unenforced.  So, now the fix is for Eclair to recognize that the funding
transaction has changed, that it's actually the RBF replacement one that got
confirmed, and for Eclair to react to that by broadcasting a commitment
transaction that spends the splice output of the replacement transaction.  And
only then, Eclair can ensure that the funds don't remain locked and the HTLCs
get enforced.

So, those are three scenarios where Eclair would fail to enforce HTLCs onchain
during splicing, but now all the fixes have been applied.  And I also
referenced Newsletter #423, because we had similarly covered issues related to
splicing and Eclair.

_Eclair #3399 and #3394_

The next item, these two PRs, #3399 and #3394.  These are two ways Eclair
could pay a downstream peer without collecting the corresponding incoming HTLC
during on-the-fly funding.  So, on-the-fly funding is a method that Eclair
uses mostly for mobile clients that don't yet have Lightning channels but want
to receive funds via Lightning.  Eclair forwards an HTLC at the same time it
sets up a new channel for the peer.  So, it's provision of a channel in real
time, also called on-the-fly funding.  So, here the issue is that, for
example, the Eclair receives a payment that expires, and then the sender sends
a new payment that reuses the same payment hash.  So, then, once that second
payment gets routed, if the downstream peer claims the original outgoing HTLC
onchain for the first payment, Eclair basically has the preimage and it can
apply that preimage to claim either the first payment or the second one,
because remember, they both share the same payment hash.  And here the issue
is that Eclair would fulfill the new payment, even though it was supposed to
fulfill the old payment.  And if the amounts differ, then Eclair is basically
handing out to a downstream peer an HTLC of a higher amount, but claiming from
an upstream peer an HTLC of a lower amount.  So, that's how you can see how
Eclair can lose funds, because it uses the preimage on the wrong payment.

So, now the fix is for Eclair to always make sure that it fulfils the HTLC
that applies to the one that the downstream peer fulfilled.  Basically, you
don't just look at the payment hash, but also at the amount and other
characteristics of the HTLC, so you don't get confused by fulfilling a
lower-amount HTLC and losing money.

The second PR is one where Eclair makes the mistake of forwarding an HTLC, not
on the on-the-fly funding splice but on another channel it already has with
the peer.  So, yes, Eclair splices a channel with the peer, offers on-the-fly
funding for that channel, but forwards the HTLC in another channel.  So, then,
this requires for the receiver not to fulfill the HTLC.  And then, when Eclair
realizes that the downstream peer never fulfilled the HTLC, never claimed
funds, so Eclair will force-close the on-the-fly funding channel.  And by
doing that, it will simply check if there were any HTLCs on that force-close
channel that required failing upstream, and it sees no HTLCs in that channel
because the HTLC was routed via another channel, so it doesn't fail any HTLCs;
and thus, the outgoing HTLC remains claimable, right?  So, it has forwarded an
HTLC, it has failed downstream an HTLC on another channel, and it can lose
money again on one side, because the downstream peer is claiming it and Eclair
is failing it for the incoming peer, so both claim it.

So, now the fix is for Eclair to always forward the HTLC on the correct
channel, so later it doesn't get confused which channel to look at.

_Eclair #3395_

The next item, this one is a pretty simple one.  Here, a malicious sender,
constructs a malformed payment onion packet that has a valid HMAC.  So, when
Eclair receives the packet, it has a valid HMAC.  However, the malicious
sender is claiming that the payload length is larger than it actually is.  So,
when Eclair tries to decode the payload, it simply catches an uncaught
exception and crashes, because it's trying to decode something larger than
what it actually is.  So, then, the problem is that the relayer resumes
without failing the HTLC.  So, the last hop, the upstream peer, doesn't get
back his money.  Even if Eclair cannot forward the HTLC, because the length of
the packet is different from what it says, it simply never fails back the
incoming HTLC.  So, a malicious sender basically makes the downstream peer,
the hop right before Eclair, have his money locked and basically be forced to
force-close the channel to be able to claim back the money on chain.

So, now the fix is simply for Eclair to check that the per-hop payload fits
within the packet.  If it doesn't, it simply returns a failure message and it
simply fails back the HTLC, and every peer in the route can claim back their
money without force-closing the channel.

_Eclair #3401_

The last item from Eclair, #3401, this is one where Eclair is trying to
fulfill or fail an HTLC, but let's say for this example, Eclair is fulfilling
an HTLC, it has the preimage, it asks the downstream peer, "Hey, here's a
preimage", but the downstream peer, for example, doesn't respond.  And then,
Eclair has a duplicate instruction to once again fulfill the payment, but when
the duplicate instruction comes in, it gets rejected because Eclair detects
that it had already proposed a fulfillment, but the peer never replied with a
signature.  So, the fulfillment is not signed, but the second, the duplicate
instruction, makes Eclair schedule the deletion of the original stored
instruction.  So, Eclair wants to fulfill an HTLC, the peer doesn't respond,
Eclair retries to do that, but the retry makes it delete the original
instruction.  So, now Eclair is simply unable to fulfill the HTLC, even though
it has the preimage.  But the problem here is that the downstream peer has
already collected the money from Eclair, right?  So, once again, a similar
scenario where Eclair gets double-spent, pays the upstream peer, but the
downstream peer can still fail back the HTLC onchain and claim back the money.

So, now Eclair always retains the original instruction.  Even though there's a
duplicate instruction, it will never delete the original instruction to never
lose that state.

_LDK #5080_

The next two items are from the LDK repo.  So, the first one is one where it's
not the node itself that's at risk, it's his peer that can get their money
locked.  So, this is specifically about when LDK restarts and wants to process
HTLCs, it would have excluded channels undergoing cooperative close.  However,
a channel that is undergoing a cooperative close can still have HTLCs that
require fulfillment or require being failed.  So, here, LDK would simply
ignore all HTLCs from cooperative-closed channels, which consequently, if at
the same time the downstream peer would fail an HTLC and LDK was supposed to
also fail the incoming HTLC, it would fail to do so if the channel was
undergoing cooperative close.  That means that the incoming channel peer would
have to wait until expiry to force-close the channel to reclaim their money.
So, now LDK simply makes sure to include channels undergoing shutdown or
undergoing a cooperative close when restoring the information needed to
resolve existing HTLCs.

So, I think that's the last one that covers these HTLC scenarios.  So, I know
it can be a bit confusing, but now we're going to get to ones that are a bit
easier to understand.

_LDK #5087_

The LDK #5087, this is an interesting potential privacy leak when sending an
onion message over a blinded path and when you use dummy hops.  So, in
Newsletter #370, we covered how LDK added support for dummy hops on blinded
paths, which enables receivers to add arbitrary hops that serve no routing
purpose but act as decoys.  This prevents a sender from guessing the position
of the receiver.  LDK is at position three, but with dummy hops, it can claim
that it's at position six.  However, a sender could include message-content
TLV (Type-Length-Value) records that were targeted for the recipient, but he
would include it at a different position.  So, for example, let's go again
with the three and five scenario.  The sender is position one; there's a hop
in between the sender and the receiver; and LDK is the receiver at position
three, but it adds two dummy hops, right?  So, it seems that the receiver is
at position five, but it actually is at position three.

So, what the malicious sender does, it includes a message-content TLV record
at the third position, trying to guess that the receiver is at the third
position.  And the problem was that LDK was simply accepting it as if it was a
correct message.  So, then, the sender gets basically confirmation that LDK is
at position three, and position four and five are dummy and are not real,
because why else would a node at position three reply as if it was the
receiver?  So, now the fix is simple.  LDK simply rejects message-content
records at dummy hops.  So, even if it could interpret it because it is the
receiver, it will act as if it's simply a node at level three, see that this
message-content record was not destined for position three but instead for
position five, and reject the message instead of actually accepting it.

_LND #11068_

The next one from the LND repository, this is #11068.  So, this one is about a
missing check for auxiliary HTLC signatures on experimental taproot overlay
channels used for Taproot Assets.  So, what does this mean?  It means that
taproot overlay channels are channels used for Taproot Assets, or other types
of assets, so you're extending a simple taproot channel to be used for not
just Bitcoin routing but additional meta protocol assets.  So, in these
channels, it's very important for a signer to not only sign the Bitcoin HTLCs
as in a regular Lightning channel, but also provide additional signature
entries for each non-dust HTLC alongside the usual Bitcoin signatures.  This
is what allows the underlying assets, the Taproot Assets, to be properly
signed and routed.  However, if LND is, for example, the one receiving the
signature from the peer, so previously, if the peer sent a commitment that had
the required Bitcoin signatures but didn't have the auxiliary HTLC signatures,
LND would incorrectly accept it.

Now, the fix is for LND to verify that the auxiliary signatures are present.
And if they're not, it will reject the commitment and force-close the channel.
But previously, it would accept it, which meant that if the channel was later
force-closed, the missing signatures could prevent the affected asset HTLCs
from being resolved onchain, because LND would simply not have the signatures
of the peer for the auxiliary assets.  So, now LND simply makes sure that the
signatures are present.  If not, it rejects the commitment and force-closes
the channel.  However, I want to note that this PR doesn't include fixes for a
peer that is sending a commitment without the signatures.  It's about the peer
verifying that the signatures are present, but not the check that prevents a
not properly signed commitment from being sent.  So, that's probably work that
will follow up.

_Rust Bitcoin #6956_

And the last two items are from Rust Bitcoin and BDK.  The Rust Bitcoin item
#6956, this is a very interesting one because this is something that I hadn't
understood before.  But technically, a witness script and scripthash can
differ under certain conditions.  For example, when a P2WSH script contains an
OP_CODESEPARATOR, signature hashing must exclude everything up to and
including the last separator.  So, it means that previously, when creating a
signature, this Rust Bitcoin would accept a witness script, and a witness
script is always the whole contents of the script where, like I said, a
signature hash under the P2WSH situation that contains an OP_CODESEPARATOR
differs from the witness script.  But previously, it would accept a witness
script, which in this specific scenario, would differ from the required data
for signature hashing, which means that it would produce an invalid signature.

So, now Rust Bitcoin introduces a new type, called ScriptCode, for the script
data used in legacy and segwit v0 signature hashing that differs from the full
script being signed.  And specifically, like I said, it's for the case where
the OP_CODESEPARATOR is present.  So, the API now accepts ScriptCode.  You can
sign your specific transactions with this, specifically for legacy and segwit
v0 signature hashing.  But you as a caller must still identify the last
executed separator and shorten the script yourself.  Also, the PR also adds
P2wpkhScriptCode, which is another edge case which represents a fixed-size,
allocation-free representation of the standard script used to sign P2WPKH
inputs.  So, this is a very granular, detailed scenario for applications that
sign these specific types of transactions.  They would previously result in
invalid signatures, and now they will work even in the specific edge case
scenarios.

_BDK #2319_

Finally, the last item, BDK #2319.  So, this is a bug where an Electrum-backed
wallet, so if you're using the BDK component for Electrum with an Electrum
Server, here, if you had a transaction that would confirm, but then it would
get re-org'd, so it would get unconfirmed, but it would get re-confirmed via
another block after the re-org, BDK would fail to track that change, because
BDK was placing the block's header in its cache and was basically linking the
transaction to the first block that it was included in.  It would fail to
update the block header's cache, so it would still be looking at the
transaction, see that the transaction was linked to this block, see that the
block got re-org'd and the transaction was unconfirmed, and still present the
transaction as unconfirmed, even though it had now been included in another
block.

So, now the fix is simply to refresh the header cache to catch that the
transaction was included now in a new block, to basically make the link
between the transaction and the new header block, and thus allow for a
one-block reorg, for a wallet that depends on BDK, to show to its user that
the transaction was now included in a new block after a reorg.  And that's the
final item and completes the Newsletter.  Thank you.

**Mike Schmidt**: I was checking that last one.  That sounded like something
that an LLM scan would find.  Not totally sure if it did.  It did say that the
PR was generated with Claude Code, but that felt like an LLM scan one.  But
Gustavo, thanks for getting us through the Notable code segment, especially
those Eclair PRs, because there were like three and two and whatever, and
those different ones.  So, appreciate that.  We'll see the release soon.
Yeah.  Murch, anything else before we wrap up?  All right.  Well, thanks to my
co-host, Murch and Gustavo.  We also want to thank waxwing for staying on with
us, and Erick for joining us earlier, and for you all for listening.  Cheers.

{% include references.md %}
