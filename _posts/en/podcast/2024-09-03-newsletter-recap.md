---
title: 'Bitcoin Optech Newsletter #318 Recap Podcast'
permalink: /en/podcast/2024/09/03/
reference: /en/newsletters/2024/08/30/
name: 2024-09-03-recap
slug: 2024-09-03-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Jay Beddict to discuss [Newsletter #318]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-8-3/385762869-44100-2-a9dc4966bf2f3.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #318 Recap on
Twitter spaces.  Today, we're going to be talking about the new Bitcoin Mining
Development mailing list, we have seven interesting questions from the Bitcoin
Stack Exchange, and we have our Notable code and Release segments this week,
including the Bitcoin Core 28.0 release candidate.  I'm Mike Schmidt,
contributor at Optech and Executive Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin projects.

**Mike Schmidt**: Jay?

**Jay Beddict**: Hey, I'm Jay Beddict, I'm the VP of Research at Foundry and
general Bitcoin goblin.

**Mike Schmidt**: If you're following along, we're just going to go through the
newsletter in sequential order starting with our News section.

_New Bitcoin Mining Development mailing list_

We have one news item this week, and our special guest, Jay, here was the one
that motivated it.  Jay, the news item is titled, "New Bitcoin Mining
Development list", and you announced the new mailing list.  Why don't you walk
us through maybe some of the motivations.  I know you, myself and Murch talked
through some of these ideas, but I'm curious to hear from your perspective why
this might be necessary.

**Jay Beddict**: Yeah, absolutely.  So, I come from an earlier time in Bitcoin
where everybody hated the miners.  I think Bitcoin thrives in the adversarial
context.  But, part of the problem from that time, pre and then during the
blocksize wars, there's a distinct lack of communication that went on,
especially on the tech side, between the development of Bitcoin Core and the
development of mining technology.  I think that it's not to put blame on to
anyone person, but that exacerbated that specific problem and then that's what
festered.  Then recently, in the last year or so, we're starting to see a lot
more interest from the developer side in mining, and we're just seeing more
interest in mining in general.

So, of course, listeners might be aware of the Bitcoin Development mailing list,
excellent resource for many years at this point for really good, deep technical
conversation in a more formal format that allows anyone to go in and read, see
what's happening, ask questions of contributors, pose ideas to the community and
get solid feedback.  And having been in the mining side for almost ten years
now, which is insane to say, but we never really had that.  We've had a lot of
individual group chats, which are really important to have these private spaces
where people can talk freely and openly about ideas and let them sort of
marinate before putting them more publicly.  But what I've been noticing,
especially in the last year, with things like OP_CAT, things like BIP300 and 301
coming back up, there's a lot of talk about, "Oh, well we can get miners to
activate this", or we can, I don't know, come up with some really crazy ideas
that haven't really thought through some of the mining intricacies, and we
haven't really had a space to do that.  We've been put into different group
chats and we've had conversations in person, but there's been sort of a there's
been difficulty in sharing that knowledge out.

So, what I wanted to do with this mailing list is have a space similar to what
the folks at Bitcoin, the Bitcoin Development mailing list, have to allow for
deeper technical conversations to happen in the open -- we're all working on
open-source software, none of this should be too secretive -- and help suss out
the ideas around things like OP_CAT, things like BIP300, Ark and these other
covenants, you know, CHECKTEMPLATEVERIFY (CTV), all these things that have had a
lot of developer interests, but might be lacking some input from the mining side
or vice versa; things that are coming up on the mining side right now, like
Stratum v2 and certain mempool policy desires that haven't really been discussed
across the bridge between the mining community, the developer community, and
even the user community.  So really, this is just a way to distill all that.
And then of course, selfishly, I don't want to be in 300 Telegram chats.  So,
having the big, meaty conversations in one spot, I think, is helpful from that
place as well.

The other side, I talked a lot about the developer bridge, but there's also just
no space for the mining tech community to just talk about some of these deeper
things.  So, we talk about firmware and hardware.  A lot of that gets done also
in silos.  That doesn't help Bitcoin to have that.  So, having space here where
folks, like the BIDEX guys, who are doing some really fun stuff, can talk about
some of those motivations of the technical stuff in a format that allows others
to hopefully respectfully give their comments or give their praise.  And for me
too, near and dear to my heart is Stratum v2.  Stratum is a great discord, but
it's a discord and those are a little bit harder to parse through some
information.  And I wanted to have a space that the Stratum v2 guys, that's our
SRI team, could share their findings, their work in a slightly more readable,
searchable format.  Whilst the Discord is very useful for having in-the-moment
conversations and thinking through things, I think some immortalization of some
of these concepts so that people can share them years from now is important.
So, it's a long-winded answer, but that's kind of the motivation.

**Mike Schmidt**: Excellent, yeah, thanks for walking us through that.  Murch,
do you have things to add on there before I get my two cents?

**Mark Erhardt**: Yeah, I mean if you go by the mailing list and look at the
archive, there's three topics on there now, and I posted one of them, and that
was, is it an issue if we now activate the rule from the great consensus cleanup
that the first block in a new difficulty period cannot be dated more than ten
minutes before the last block of a previous difficulty period?  And I was
wondering how I would even get feedback from miners about that topic.  So, on
testnet4, I don't think that that is going to create a lot of issues.  But if
someone is going to mine on testnet4, or some miners find that this timestamp
restriction on this rule would interfere with how they deployed their hardware
or how they organized their mining pool, or something, it would be great to find
out.  So, I posted about that to the mailing list, and I hope that people, the
right audience, gets to see my message.

**Mike Schmidt**: Yeah, it seems to me, as an observer, that the mining industry
has really become its own industry over the years, right?  And whereas maybe a
decade ago, it was the developers that were maybe also mining, or maybe longer
than a decade ago, but it's sort of been this division of responsibility in the
community: developers are focused on code; miners are focused on energy and data
centers and policy.  And, part of me just wished that all participants would
read the newsletter, listen to this podcast, and pick out what is interesting
for them, including those in the mining industry, like Murch mentioned, the
testnet4 change.  I think there was a Bitcoin-Dev mailing list post that was
mining-related about oblivious shares, that we talked about in Newsletter #315,
but it's probably not realistic for somebody to parse through all of this
dev-related news that we cover in a newsletter and try to find out the one or
two mining nuggets that may be in there in a given couple months or something
like that.

So, perhaps this list can serve as a way for us who are following that to say,
"Oh, this looks like it's mining related.  Maybe we should alert this Mining-Dev
list about this discussion", and they can jump over to wherever that discussion
is taking place, whether that's Delving or the Bitcoin-Dev list, or elsewhere,
and contribute to it.  So, that way they're sort of subscribing to this list, as
a high-signal list, and not just a dump of everything, and they have to manually
go through and parse it.  At least that would be a hope for me.

**Jay Beddict**: Yeah, I think that's something I failed to mention in my
ramble, but I do think that's the goal here, is let this be high signal.  So,
there's a lot that we're all dealing with at all times and it's coming from all
ends, but my goal with this was to have a place where people come and say, "Hey,
this is pretty critical".  It's not the latest drama, it's not who's getting
bankrupt, it's not who's dumping shares on shareholders, or whatever; it's,
"Hey, this is low-level, pretty critical stuff that will have long-term impacts.
We need to have constructive conversations around how to manage it".  So, I
completely agree that that is definitely one of the key motivations here,
because there's a lot of stuff that comes through on Nostr and on Twitter that's
really interesting, but I don't know if it's critical to the advancement of the
mining space or Bitcoin in general.  So, I want to make that a space where we
can have those bigger conversations and let people focus on their day jobs,
right?

Mining is a rough industry, so let people focus on their day jobs, keeping those
ASICs running and keeping the lights on, but have the space for, "Hey, someone
posted to the mailing list.  This is actually pretty important.  Maybe we should
spend a couple of minutes looking at this", and hopefully contributing back,
having a conversation, but at the very least, as you said, helping people find
where these conversations are happening, because that's been pretty hard to do.

**Mark Erhardt**: Yeah, and then also in the other direction, I mean it's come
up before, but for me, it's just been difficult to get a sense of what miners
are aware of, what they're talking about.  So if, on the other hand, I, as a
developer, can just subscribe to this list to see what's on the mind of miners,
that would be super-helpful.  Although, so far, this has yet to pick up some
steam!

**Mike Schmidt**: Yeah, we'll see.  I think at least in terms of seeding some of
these topics, the risk/reward is very low cost to cross-post something and let
folks know.  But yes, at some point it would be nice to have pool operators and
miners and other mining ecosystem participants to post something themselves or
reply or ask a question.  But, it's one of those things, we've got to get the
motivation going and get the momentum going and hopefully we can do that in the
next month or so.

**Jay Beddict**: Yeah.  And I mean, the mining side has historically been very
quiet and cagey.  So, I intend to harass people in a polite way to share their
thoughts, because I think, again, ultimately it helps everyone here to build
this bridge, right?  The devs should still mistrust the miners and the users,
right?  It's that sort of school model, right, with the three factions, but
doesn't mean it needs to be totally disrespectful.  And I do think that as we
advance the space, there's going to be more overlap.  I think you made a really
good point where historically the miners and the developers were kind of
overlapped, and now it's definitely very distinct.  But the beauty of Bitcoin is
it's interdependent as well, and so it doesn't really help anyone to be too
cagey about what you're doing.  I don't want this to devolve into like pubco,
stock price speculation conversations.  I think that's not helpful for anyone.

But yeah, I do think it's sharing knowledge, sharing problems that you're seeing
as an operator in the mining space, and other people have probably seen it too.
Maybe there's a technical solution, maybe it's as simple as you need new CAT6
cables, we've seen that too.  So, yeah, I think it'll be helpful to push the
mining side a little bit on this and that's my job.  So, I'd be happy to spread
motivation.

**Mark Erhardt**: I think it will hopefully also help to create a few personal
connections, because right now, I mean I know a couple of people that work in
mining, but for the most part, people that are publicly-facing seem to mostly be
concerned on energy price and finding new locations where they can house and set
up Bitcoin mining operations.  It feels more like an operations research
project, and I'm sure there must be a bunch of people that work on the technical
side in mining.  I have absolutely no clue who these people are and what their
names are, so if some of them start posting to the mailing list, maybe I know
who to talk to?

**Jay Beddict**: Yeah, I always joke mining is a niche of a niche of a niche;
and then if you're on the pool side, we're a niche of a niche of a niche of a
niche.  So, I think that's a great point, Murch.  And getting people to know
who's also working on the problem is helpful in making those connections, and I
do think that's something that we can accomplish with this list.

**Mike Schmidt**: Excellent.  Well, if you're interested in these sorts of
topics and the interplay between mining and development, whether that's node
software development or mining protocol like Stratum v2 development or firmware,
feel free to subscribe to that newsletter or that mailing list.  It's in
Newsletter #318, so very low-risk, potentially high-signal group.  So, that
would be my call to action.  Anything else you'd say, Jay?

**Jay Beddict**: No, I think the only other message is, keep your coins off
exchanges and your name in the databases.

**Mike Schmidt**: Good advice.  Jay, thanks for joining us this week.  You're
welcome to stay on as we go through the rest of the newsletter.  Otherwise, if
you have things to do, we understand.

**Jay Beddict**: Appreciate it.  I'll happily lurk.  Thanks, guys.

**Mike Schmidt**: Next segment from the Newsletter is our monthly section on Q&A
from the Bitcoin Stack Exchange.  We have seven this month.

_Can a BIP152 compact block be sent before validation by a node that doesn't know all transactions?_

First one is, "Can a BIP152 compact block be sent before validation by a node
that doesn’t know all transactions?"  So, this was actually a question from Dave
Harding, and Antoine Poinsot pointed out that if you received a compact block
and then forwarded it on to another peer before validating all of the included
transactions were at least committed to by the block header, there would be a
DoS vector there.  Maybe, Murch, do you want to double-click on any of that
question and answer and elaborate?

**Mark Erhardt**: Yeah, so compact blocks, maybe as a brief recap, is a way of
sending block recipes rather than the complete content of the block.  So, you
just tell another node, "Hey, here's the header, here is a list of short IDs
with the transactions in order, and then they can compile it from their own
mempool if they have everything.  So apparently, it is a violation of the
compact blocks protocol to forward the block before it's validated, in the sense
that you do have to check the header.  And checking the header means also the
merkle proof, the merkle root in the header, which means that you have to check
that all of the txids hash up to the merkle root before you forward.  So, you
don't have to validate all the transactions, you can do that later, per spec,
but you do have to check the header before forwarding.  And yeah, so interesting
question.

**Mike Schmidt**: We need to validate that all of the txids are in the merkle
tree, but whether those transactions are valid or not is done after we would
forward on that compact block; is that right?

**Mark Erhardt**: Well, sort of, because whenever you add something to your
mempool, you already validate the transaction itself.  So, if everything was in
your mempool, you should have validated everything already so you sort of have
done both already, you just haven't done it in the union.  So you could, for
example, still have a block that has two conflicting transactions – no, you
can't, because they wouldn't be both in your mempool.  No, I think you basically
have done the full block validation at that point, you just haven't applied it
yet, and you haven't double-checked it, I guess.  Luke, you have input?

**Mike Schmidt**: Hey, Luke.  Over.  Well, we'll see if he joins us to speak
shortly.  Oh, hey, Luke.  Did you have a comment on the Stack Exchange Q&A on
compact blocks?

**Luke Dashjr**: No, I didn't see it.

**Mike Schmidt**: Oh, all right.  Did you have a question or comment, or do you
just want to hang out with us?

**Luke Dashjr**: I guess just hanging out.

_Did Segwit (BIP141) eliminate all txid malleability issues listed in BIP62?_

**Mike Schmidt**: All right.  Second question from the Stack Exchange or, Murch,
were we good with that one?  Okay, second question from the Stack Exchange, "Did
segwit (BIP141) eliminate all txid malleability issues listed in BIP62?  BIP62
wasn't one that I was familiar with, but Vojtěch explained a variety of things.
He talked about all the ways that TXIDs can be malleated, how segwit addressed
malleability, and what non-intentional malleability is, and then referenced a
policy-related PR that the person asking the question referenced that didn't
necessarily address the malleability, but it was more of a policy thing.  Murch,
were you familiar with BIP62?

**Mark Erhardt**: I was actually, yes.

**Mike Schmidt**: Okay, you were.  All right.

**Mark Erhardt**: So, BIP62 was a 2014 proposal that was trying to work around
the natural malleability permitted by the ECDSA standard.  So, ECDSA signatures
are famously not always the same length, and it has a fairly quirky way of how
things are serialized.  And so, BIP62 basically came up with a number of rules
that would lead to other third parties not being able to malleate signatures
after their broadcast.  So for example, in the input script, there's various
ways how you can create equivalent inputs, and the input script itself is the
only thing that's not committed to by the signature, because clearly that would
be self-referential, right?  The signature and legacy inputs are in the input
script, so you can't sign the input script with the signature, because you would
be signing yourself, which you can't do.  So for example, people could insert a
data blob and then an OP_DROP after it, and it would still be the same
signature.  But that would of course not be the minimal way of expressing the
signature or the input script.

So, BIP62 is now withdrawn because it's obsolete, but essentially all of the
things it tried to achieve were achieved with segwit, because segwit inputs
famously, well not wrapped segwit, but native segwit inputs have an empty input
script, so malleability in the input script is no longer a concern because it's
always empty.  And by taking the witness data, the signatures and so forth, into
the witness stack, this is still malleable in all the ways that they used to be
before segwit.  However, the witness stack doesn't contribute to the txid, and
therefore the third-party malleability that led to txid changes is no longer
there.

**Mike Schmidt**: It wasn't clear to me from Vojtěch's answer if segwit did
indeed fix all of those malleability vectors, but from what you're saying, all
nine of those that are listed in BIP62 are resolved by segwit; is that right?

**Mark Erhardt**: That's my – sorry, Luke, say again?

**Luke Dashjr**: I don't think? I think that's necessarily true because the
signature is no longer part of the txid at all.

**Mark Erhardt**: Exactly, yeah, I think it's true.

**Luke Dashjr**: And if I recall, part of the reason why BIP62 didn't really go
anywhere and why we ended up with segwit was because nobody was ever completely
sure that BIP62 was sufficient.  Luke, I have a question for you.  Are you aware
of the new Bitcoin Mining Development mailing list posted by Jay last week?

**Luke Dashjr**: Yeah, I joined it.

**Mike Schmidt**: Oh, okay.  Great, excellent.

**Mark Erhardt**: Yeah, I had one follow-up.  And that is of course, a lot of
the problems that we had with ECDSA signatures obviously don't pertain to
taproot inputs, because taproot inputs use schnorr signatures, and schnorr
signatures use a new serialization format that is not malleable.  So, it's
always the same length and that also solves a lot of these issues.

_Why are the checkpoints still in the codebase in 2024?_

**Mike Schmidt**: Next question from the Stack Exchange, "Why are the
checkpoints still in the codebase in 2024?" the code base referring to the
Bitcoin Core codebase.  Lightlike noted that ever since the Headers Presync PR,
which is Bitcoin Core #25717, the Bitcoin Core codebase has no known
requirements for checkpoints.  But he also, and others, emphasize that there
could be unknown attack vectors that the checkpoints are protecting against.
Maybe, Murch, what is a checkpoint?

**Mark Erhardt**: Right.  So, the checkpoints have been in the codebase, I think
the highest one is around block 200,000, and they essentially prevent using a
different header chain before the last checkpoint, by requiring that certain
hashes appear at certain heights in the blockchain that the node accepts.  The
Bitcoin node will just not even consider an alternative header chain if someone
starts from the Genesis block and mines, for example, a low-difficulty
blockchain up to block 200,000.  So, you could split off at 200,000 and then do
attacks from there, but up to 200,000 or so, maybe it's 192,000, but ancient
history either way.

So this was, of course, a concern early on when it was fairly easy to re-mine
the entire start of the blockchain, because there's very little work there from
today's perspective.  And this was sort of a cheap way of making sure that
nobody attacked the start of the chain and then misled new onboarding nodes to
first follow an incorrect chain.  People misunderstood for a long time that this
was still security-relevant because frankly at this point where we're, what is
it, over 640,000 blocks further along, it doesn't really matter whether someone
re-orgs more than 100 blocks or more than 1,000 blocks, either way that would be
a catastrophe.  So, protecting the chain only up to 200,000 doesn't really have
any consensus implications at this point.  And with the release of 24.01 and the
Headers Presync, where we now do process the header chain twice, the first time
just making sure that the header chain we're following actually has sufficient
work to overpass the minimum work requirement to tell us that we're on the best
chain, and the second time actually processing the same headers and keeping
them, that has sort of the same result in that it's impossible for us to be
misled to be on an incorrect chain and to download a ton of blocks and validate
them and store them when they're not actually part of the best chain.

**Mike Schmidt**: Murch, what is your take on leaving the existing checkpoints
in the codebase as is versus removing them and there being potentially unknown
attack vectors?

**Mark Erhardt**: I'm not aware of any.  I mean, if you were eclipse attacked
while you're doing your IBD (Initial Block Download), someone could possibly
feed you an alternative chain that also has as much work as the Bitcoin chain,
but I mean that's a lot of work, so I just don't think that that would be an
interesting attack vector for people.  I guess it doesn't really hurt, but
except in the sense that it fosters this misconception that checkpoints are
still consensus critical.

_Bulletproof++ as generic ZKP ala SNARKs?_

**Mike Schmidt**: Next question from the Stack Exchange, "Bulletproof++ as
generic ZKP ala SNARKs?" And this is a question about a bunch of different
pieces of cryptography, one of which the person answering, Liam Eagen, actually
worked on.  I believe Liam worked on the bulletproof++ white paper, and he
jumped into the details of what SNARKs are currently in use, the different types
of SNARKs, as well as how bulletproof/bulletproof++ plus a BitVM-type protocol
and OP_CAT might work together to verify such proofs in Bitcoin Script.  There's
a lot of buzzwords in this question and answer and, Murch, I don't know how much
you've played with any of those pieces of technology.  I know that there was
like an OP_CAT week or something like that on the Stack Exchange because there's
a bunch of OP_CAT questions this go round, but anything to add on Liam's answer?
Obviously, our summary of it is quite succinct compared to what he put on the
Stack Exchange.  So, if that sounds interesting to you, jump into it.  But
maybe, Murch, you have a comment.

**Mark Erhardt**: Yeah, well I'm not a cryptographer, I wouldn't pretend that I
understand all that stuff.  But my understanding is that he says you can build
ZKP systems based on bulletproofs.  But in the context of trying to validate
them in script, it would be a lot more complex than other SNARKs, and therefore
he seemed to indicate it's unlikely that they will get used in that context.
That's what I took away from reading it.

_How can OP_CAT be used to implement additional covenants?_

**Mike Schmidt**: Next question from the Stack Exchange, "How can OP_CAT be used
to implement additional covenants?"  And Brandon Black/Reardon Code, described
the proposed OP_CAT opcode and sort of walked through how that provides, as he
says, additional covenant functionality to scripts.  He calls the timelocks,
probably correctly, existing covenant scripts.  Murch, do you want to talk about
why there's these OP_CAT questions in the Stack Exchange?  Was there like an
OP_CAT week, or did you seed questions, or how did that work?

**Mark Erhardt**: Yeah, we used to do that quite often, or we had a while where
we did it regularly, where we would pick a topic and try to get people to
specifically ask and answer questions in the hope to get a few people look at
Stack Exchange more frequently.  So, there was a lot of debate on OP_CAT again
recently and I wanted to finally start to better understand what's going on.
So, I had talked with Brandon in Nashville and we sort of agreed that a lot of
the conversation is happening in these not-publicly-visible, or
hard-to-summarize conversations, either in chat groups or on Twitter threads.
And I mean, if you're in a meandering conversation on Twitter with different
branches and so forth, it's just really hard to get a good overview of what's
going on, and you'll probably miss a lot of the conversations unless you're
directly tagged.

So, my hope was that maybe some of the frequent questions that people have
regarding OP_CAT would find their way to Stack Exchange or the mailing list,
where people will be able to read up on it and not have to go hunt all these
disparate conversations, or I mean how do you even hunt Telegram groups you
don't know about, or whatever.  So, yeah, I kicked off this OPCAT Week and we
collected some seven or so questions.  Again, if people have questions about
proposals and protocol research and so forth, that is totally on topic on Stack
Exchange, so please feel free to ask your questions there.  And I seem to have
at least garnered the interest of a couple of people that have looked at it and
given answers, so maybe you'll get expert answers to your OP_CAT questions.

In this specific topic about OP_CAT implementing covenants, a covenant in
general is a way of restricting how an output can be spent, by making sure that
certain aspects of the spending transaction follow some restrictions.  And, in
this case, you would do that by requiring that the entire spending transaction
is pushed to the witness stack, and then you can rebuild the transaction
commitment, the thing that we sign with the signatures on stack and sign it and
compare – well, you would compare basically what the signature is committing to
on the stack.  And that way, by being able to introspect all the parts that have
been pushed to the witness stack and maybe being able to enforce certain
restrictions on certain elements of that, you would be able to basically
restrict any element of the transaction, and then check on the stack that the
composition of the total transaction fits your schema and was signed correctly.

The way it works in this case is that, yeah, well I have already explained it.
You push all the transaction parts of the spending transaction to the witness
stack and validate that the data matches the input of OP_CHECKSIG.

_Why do some bech32 bitcoin addresses contain a large number of 'q's?_

**Mike Schmidt**: Thanks, Murch.  Next question from the Stack Exchange, "Why do
some bech32 bitcoin addresses contain a structure with a large number of q
characters?"  The person asking this noticed some bitcoin addresses with an
unusual number of q's in a row.  And it turns out, and I didn't know this, but
apparently there's this OLGA protocol that's being used to put arbitrary data
into the UTXO set using essentially these fake P2WSH outputs and encoding data
into the address, into these outputs, which is creative and ridiculous at the
same time.  I didn't happen to see any of these addresses when I'm perusing
mempool.space, but you can see some of the examples from the question on the
Stack Exchange that we linked to.  Murch, creative and ridiculous?

**Mark Erhardt**: Well, frankly, we can't really prevent that people use hashes,
or what should be hash outputs, in output scripts as data carriers because they
look pseudo-random if they put other stuff there.  Like, how do you even filter
that?  So, this is essentially a revisit of the debate from, I don't know how
long it's been, 10 years, 12 years ago, where OP_RETURN in the first place was
made standard, so at least if people are going to write stuff to the blockchain,
they wouldn't write it directly to the UTXO set.  And that was, of course, also
a big debate in the last year with the stamps and inscriptions and all of that.
So, essentially this is a demonstration of why it's really hard to effectively
prevent that behavior, because in the worst case, they'll just go and write it
to P2WSH outputs, and it would be extremely difficult to prevent that without
just forbidding P2WSH outputs in the first place.

So, I'm not a fan, but if people got to write stuff to the blockchain, it would
be nicer to do OP_RETURN, and knowing that this is from the stamps people, I
suspect that that is exactly what they know, and that's why they're doing it.
So, yeah, as long as it stays as little as it is, hopefully maybe we should just
ignore it.  And, yeah, all the q's, what's happening here is they write data to
the P2WSH output in the witness program, and their standard apparently requires
that it's zero padded.  So, if you write something that's shorter than the
amount of data that you have available, you just add q's, which is the zero in
bech32, until you hit the end of the data part of the witness program, and then
of course, there's the checksum afterwards.  So, the q's stop at some point and
there are some other characters in the end.

**Mike Schmidt**: Luke, how would we stop this?

**Luke Dashjr**: It's probably pretty trivial.  It looks like it's based on a
counterparty so it's probably already filtered by Knots.

**Mike Schmidt**: Yeah, I did see mention of counterparty in there, but it's
encoding the data into the P2WSH outputs and I don't think it's doing what
counterparty was doing previously, right?

**Luke Dashjr**: This one hasn't even come across my radar yet, so I don't know.
I'd have to look at it more.

**Mark Erhardt**: Yeah, I mean, bare multisig is sort of standing out as being
exceptionally dumb and easy to spot because nobody else is using it for anything
else.  But P2WSH outputs, which have this 32-byte data witness program, well
maybe I'm wrong, but it doesn't seem obvious to me how you would filter that
unless they have some sort of magic that identifies what they're doing, but then
if you filter it, they would just change the magic.

**Luke Dashjr**: As long as they have an intent for someone else to decode it,
whatever they're using to decode it can always be turned into a filter no matter
what you do.

**Mike Schmidt**: So, essentially pools would then run the OLGA protocol from
stamps?

**Luke Dashjr**: You don't need the whole thing, you just need enough to
identify that it is a spam in the first place.

_How does a 0-conf signature bond work?_

**Mike Schmidt**: Yeah.  And our last question from the Stack Exchange, "How
does a 0-conf signature bond work?"  Murch, if I'm not mistaken, you asked this
question.  So, maybe we can define what the idea of that was, and then we can
get into the implementation detail.

**Mark Erhardt**: Yeah, so I was asking what the use cases were of OP_CAT if we
activated just OP_CAT by itself.  Ahat would it make better?  What would we be
able to do that we hadn't been able to do without OP_CAT before?  And there were
a few things that were brought up.  One was the perfect vault that Rijndael came
up with, which is based on OP_CAT and sort of very closely related to the
previous topic we talked about.  And then there was the mention that DLCs would
get more efficient with OP_CAT.  And finally, there was this, "You can make sort
of zero-conf work again".

So, for the longest time, there had been this disagreement on how useful
zero-conf is or not.  So here, the idea is, well if you cannot create a second
transaction that spends the same output without leaking the private key, people
would be able to rely on a transaction, the first version of the transaction
they see, because if a second one comes along and they catch this conflict, the
two signatures together would leak the private key.  And so, the way that would
work is that you lock your funds in a special output that requires them to be
spent with a specific R value in the signature.  And if you create two
signatures for different messages with the same R value and the same private
key, you get a set of equations from which you can calculate the private key.
So, basically by creating a conflicting transaction, the sender would reveal
their private key, and that would lead to a scorched-earth scenario where the
recipient and the sender, or maybe also the miner, can just turn all of the
input into fees.  And the idea is while the sender isn't guaranteed to get paid,
they sort of expect that the sender doesn't want to lose their entire input, and
therefore they're not going to create a conflicting transaction.

Given that this would probably make the input quite a bit bigger and you have to
sort of stage your funds in these covenants before you can spend them, I'm not
sure if it's 10X better.  I also don't think that zero-conf was ever the killer
feature of Bitcoin that some people see it as.  So, well, it was one of the
examples given to motivate OP_CAT.

**Mike Schmidt**: Doesn't that scorched-earth policy then mean that miners are
advantaged to being able to take advantage of such a protocol?

**Mark Erhardt**: Yeah, maybe there is some game theory there that miners would
generally stop accepting those transactions and just wait until the sender gets
frustrated, because they have no other way of moving this transaction anymore at
that point.  Well, they could CPFP it, so maybe they could motivate some miner
to break the cartel, but there might be some mind games where miners were like,
"Well, this is below minimum fee rate and this will never go through, so we're
waiting for your conflicting transaction to take the input".  But I guess, yeah,
it just doesn't allow RBF, it still allows CPFP, so maybe that's not too
dangerous.  The other thing is that the recipient is not guaranteed to get paid.
It just guarantees that the sender loses money if he misbehaves.  I don't know
if that's sufficient to make – well, maybe for small payments, yes, but then
small payment and big input maybe would be a deterrent.

**Mike Schmidt**: Well, and if the sender is a miner, then maybe they don't even
lose money, right?

**Mark Erhardt**: Right.  If they are fairly certain that they can be the first
to spend that or they think that the recipient is not monitoring for conflicts
to -- I mean, it would take some time for people to catch on, so maybe they
would feel that it's still secure by obscurity to double spend.  Either way, it
is an idea, it's interesting, it seems to work as a theoretical construction.
Yeah.

_Core Lightning 24.08rc2_

**Mike Schmidt**: Interesting idea.  Moving to the Releases and release
candidates section of this newsletter.  First one, Core Lightning 24.08rc2.
Since this newsletter, I saw that Core Lightning (CLN) actually had an rc3 for
this release, and also a final 24.08 release, nicknamed Steel Backed-Up
Channels.  So, I suspect we will cover that official release in this next
newsletter, and so perhaps we dig into the details then.  What do you think,
Murch?  Great.

_LND v0.18.3-beta.rc1_

LND v0.18.3-beta.rc1.  This is a minor release, although it does contain quite a
bit of changes and bug fixes.  Fifteen bug fixes by my count, several RPC and
LND CLI changes, a new feature that temporarily bans peers that send too many
invalid channel announcements, and then a bunch of internal changes related to
changes in the BOLT specification and updates around that.

_BDK 1.0.0-beta.2_

BDK 1.0.0-beta.2.  So, we moved on to the second beta for BDK's 1.0 release.
I'll quote from this beta.2 RC.  It says, "The primary user facing changes are
re-enabling single descriptor wallets and renaming LoadParams methods to be more
explicit.  Wallet persistence was also simplified and blockchain clients no
longer depend on bdk_chain crate".  So, I think we talked about the single
descriptor wallet PR last week.  So, if you're curious that is dealing with,
check back to #317 where we talked about that.  Anything to add there, Murch?

**Mark Erhardt**: Just a question, maybe.  So, usually we talk about RCs in this
context.  Is this to be understood as an RC or even a pre-RC, just better
version that people can play around with?

**Mike Schmidt**: Yeah, we note in the description in the newsletter that it's
an RC.  It's noted in GitHub as a pre-release; it's tagged as a pre-release, so
not quite ready yet.

_Bitcoin Core 28.0rc1_

And the last RC this week, Bitcoin Core 28.0rc1.  There is a stub for a testing
guide for this release, but it's currently empty.  So, Murch and I decided that
when that testing guide gets drafted, we would like to do the deep dive on the
release at that point.  But, Murch, other than encouraging folks to test their
existing setups and infrastructure on the RC to ensure proper functioning.
Anything else that you would add this week before we do the deeper dive in a
future discussion?

**Mark Erhardt**: Yeah, I think it's a big release.  There's a few cool features
that hopefully also get appreciated by the user space.  I think assumeUTXO is in
there.  If people are concerned about IBD taking too long, they'll be able to
first catch up with the chain tip and then do the full sync in the background.
So, there is a commitment being shipped for block 840,000, which is the halving
block, so about four months' worth of blockchain that you have to parse to catch
up to the chain tip to rebuild it from the UTXO set.  And there is testnet4
being released with this.  It's been already running for a few months, but now
Bitcoin Core will have support in this version.  And I think one of the coolest
things is the one-parent-one-child package relay (1p1c), which hopefully will be
adopted quickly, and then some changes to how Lightning commitments will work
hopefully will be able to follow from it.

**Mike Schmidt**: This would be one of those items that we probably would want
to surface to the new Bitcoin Mining Development mailing list, yeah?

**Mark Erhardt**: I think it will actually not affect them too much.  They might
want to be aware of it.  I think that the next one will be slightly bigger for
miners.  I hope that cluster mempool will be released in 29.  So, well, that's a
long time from now!  Anyway, 28 is scheduled for end of September.  Yeah, Jay?

**Jay Beddict**: Yeah, I was going to say, I think with 28, the v3 transactions
have some weird fee stuff going on that may be relevant.  So, I might just make
a quick little post there just as awareness.  I mean, I think this is probably
very off topic, but from a pool operator perspective, obviously we care greatly
about this release, because it could impact the way that blocks are composed.
So, I'll write a little something for that.  But yeah, 29 is going to be even
more relevant, I think.

**Mark Erhardt**: Awesome.

**Mike Schmidt**: Moving on Notable code and documentation changes.  I'll take
this opportunity to solicit any questions that the audience may have.  You can
post that in the thread here or request speaker access if you have a question
for Jay, Luke, Murch, or myself on the newsletter.

_LDK #3263_

Otherwise, first PR, LDK #3263.  This is a change to LDK's handling of onion
messages, specifically around APIs for handling instructions on how and where to
send an onion message.  The reason for these internal changes is that LDK's
current architecture, it isn't possible to represent the way that it operates
now in LDK's bindings.  So, when you want to use LDK in non-Rust environments,
for example, there's bindings for C or C++ or Python, those specific
considerations weren't able to be in those bindings.  So, they've sort of
re-architected how they handle those onion messages and the APIs around them to
accommodate those bindings for users of LDK software that use those bindings.

_LDK #3247_

LDK #3247 is a PR that deprecates an older method of calculating a Lightning
channel's balance.  The older method, named balance_msat, was described as,
"Complex and originally had a different purpose that is not applicable anymore".
And my understanding is that the purpose and sort of raison d'être of that
method was to address potential underflow issues that do not exist anymore in
the LDK codebase.  Good news is that there is a better method that already
existed before this PR for calculating a channel's balance in LDK, and that is
the get_claimable_balances method, which is a, "Method that provides a more
straightforward approach to the balance of a channel, which satisfies most use
cases".  So, that balance_msat is now, as of this PR, deprecated and it will be
removed in an upcoming release.

_BDK #1569_

And our last PR, and this was I think referenced in the BDK-beta.2 earlier, this
is BDK #1569.  It adds a new bdk_core crate to BDK, and this is more of an
architectural change than any sort of addition of functionality.  This bdk_core
crate contains some of the core BDK data types that were previously in the
bdk_chain crate.  And so, that's items like BlockID, ConfirmationBlockTime,
CheckPoint, and a bunch of other data structures.  And the reason that they did
that was, the motivation was actually described in a different issue on the BDK
repository that noted a few different things.  It says, "We may want to be able
to iterate fast on bdk_chain without breaking wallet.  It will be a nice
property for a project that uses BDK.  It can stay put on a specific bdk_chain
version, but still use the latest chain source crate version and the
introduction of bdk_core crate that moves structures and types from bdk_chain,
and that will stay more constant.  And so, that means that BDK sources of
blockchain data, like Esplora, Electrum, or Bitcoin Core RPC can now only need
to depend on the bdk_core and not bdk_chain.

So, some sort of, I guess, certain parts of the BDK codebase iterate faster than
others.  So, they wanted to separate some of the more constant pieces out into
this core so they can iterate faster on some of the other crates.  Anything to
add?

**Mark Erhardt**: Just something that was written in the newsletter.  They also
managed to make bdk_esplora, bdk_electrum and bdk_bitcoind_rpc only depend on
bdk_core, so they don't depend on bdk_chain anymore.  So, besides the wallet,
just seems to be helpful.

**Mike Schmidt**: Jay thanks for joining us and covering the news item on the
new mailing list.  Luke, thanks for jumping in and answering some questions.

**Luke Dashjr**: No problem.

**Mike Schmidt**: And thanks always to my co-host, Murch, and for you all for
listening.

**Jay Beddict**: Thanks all.

**Mark Erhardt**: My pleasure, hear you soon.

{% include references.md %}
