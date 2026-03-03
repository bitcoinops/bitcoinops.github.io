---
title: 'Bitcoin Optech Newsletter #357 Recap Podcast'
permalink: /en/podcast/2025/06/10/
reference: /en/newsletters/2025/06/06/
name: 2025-06-10-recap
slug: 2025-06-10-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Jose SK, Clara Shikhelman,
Vojtěch Strnad, Robin Linus, and Dan Gould to discuss [Newsletter #357]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-5-12/402052376-44100-2-c5f2f42f2a6b7.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #357 Recap.
Today, we're going to be talking about sinking full nodes without witnesses; we
have our monthly segment on Changing consensus that has three items this month.
One is covering a quantum computing report, we're also going to discuss an idea
for a consensus change to limit the maximum weight of transactions in a block,
and we're also going to talk about age-based expiration for dust outputs in the
UTXO set, along with our normal Releases and Notable code segments.  I'm Mike
Schmidt, contributor at Optech and Executive Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at localhost research on Bitcoin.

**Mike Schmidt**: Jose?

**Jose SK**: Hi, I'm Jose, I'm working currently on the Floresta lightweight
utreexo node.

**Mike Schmidt**: Clara.

**Clara Shikhelman**: Hi, I'm Clara and I'm a researcher at Chaincode Labs.

**Mike Schmidt**: Vojtěch?

**Vojtěch Strnad**: Hi, I'm Vojtěch, I'm a Bitcoin enthusiast and a free-time
educator.

**Mike Schmidt**: Robin.

**Robin Linus**: Hi, I'm Robin, and I work on BitVM and I'm doing a PhD on
Bitcoin at Stanford.

**Mike Schmidt**: Amazing, thank you all for joining us.  Murch was saying
before the show, he's excited about this one.  We've got a lot of interesting
topics and I think we're specifically excited because you all are here to help
represent the work that you're doing.  So, we'll jump into our News section.

_Syncing full nodes without witnesses_

We have one item this week, "Syncing full nodes without witnesses".  Jose, you
posted to Delving Bitcoin a post titled, "Witnessless Sync for Pruned Nodes".
In that post, you summarize some analysis of skipping assumevalid witness
downloads for pruned nodes, and you also conclude that there could be a
reduction in bandwidth usage by more than 40% during IBD (Initial Block
Download) that could be possible.  Maybe, Jose, you can briefly explain some of
the background concepts, like assumevalid and pruned nodes, and then we can get
into how they can come together to realize the benefits that you outlined?

**Jose SK**: Yeah, so the first time, I think the first time that this was
discussed, it was in 2016 in a bitcoincore.org post, where they were listing the
benefits of segwit.  And then we saw one of those potential benefits, which was
simply that we could skip downloading the witnesses for some kind of lightweight
nodes or nodes that are skipping stream or signature validation, right?  But at
the time, there wasn't such a thing as assumevalid.  There were checkpoints.
So, we were skipping, as far as I know, we were skipping the signature
validation until the checkpoint.  But then, that was kind of limited and I think
it has been removed recently, the checkpoint thing.  But anyway, assumevalid was
actually introduced in 2017, in the same year as segwit.  After that, nobody
thought, no, I don't know if thought, but I haven't seen anywhere after segwit
was activated.  The idea was you need to simply skip downloading these witnesses
that we are already knowing they are valid, right, because of assumevalid.

So, the background of this whole thing was two years ago, in Bitcoin Stack
Exchange, I simply asked a question, I thought it was a dumb question, which is
basically, "Why are we downloading the witnesses for these assumevalid blocks
for pruned nodes?" because these pruned nodes will download this data and not
check it, because they use assumevalid, which is on by default.  They will
simply not verify these witnesses and then remove them, drop them.  So, I simply
asked that.  Pieter Wuille answered, actually that would be possible.  But the
problem is that actually, we are doing some checks with those witnesses
currently.  It is not like we can simply skip them currently, because we need
them for the resource limit checks, the sigops, size, and even the block weight,
because block weight depends on the witnesses, so we need them for that.  Also,
for the witness commitment, we need to check the commitment in the coinbase
transaction.  Another check, which is that the node legacy input can have
witnesses.  I think those are all the things that we are doing with the
witnesses currently that are not covered by assumevalid.  But he said that we
could actually cover those things in assumevalid.  It is not like it's a really
big chain for assumevalid.  It does seem trivial things to cover with
assumevalid.  And if we did that, we could have a really big cut in bandwidth,
because witnesses currently are taking a big part of the block.

After that post, from Bitcoin Stack Exchange, there was a PR in Bitcoin and
there was a discussion.  Many people agreed with the idea, but there were some
concerns about the data availability stuff.  But, the number is actually from
comment, Pieter Wuille said that in the last 100,000 blocks, 43% of the data was
witnesses, and that was two years ago.  So, I don't know actually what would be
the number currently, but probably like 40%, or something like that, or more.
Murch is in.

**Mark Erhardt**: Well, given all the inscription data, I think the witnesses
are a lot more of the block right now.  Well, at least in the last few years.

**Jose SK**: Yeah, probably more.  That's why I say probably more than 40%.

**Robin Linus**: Shouldn't it be, like, 75%, since 1 MB is transaction data and
3 MB is witness data?

**Jose SK**: In the extreme case, you mean, right?

**Mark Erhardt**: In the extreme case, 4 MB of witness data would fill a 1 MB
block.  But really, we only have something like 1.3 MB to 1.6 MB in most blocks.
So, witness data is much less than almost all of the block.

**Jose SK**: For that famous block, that was a full inscription, 4 MB, that
would be for this kind of witnessless thing, no, that would be empty, basically.
So, yeah, that was the background, basically.  Because of the data availability
concern, that PR didn't progress anymore.  Currently, it is up for grabs.  So,
yeah, that's two years ago, right?  So, I think it was two weeks ago, I don't
know why, I thought about this again.  And I said, okay, let's try to think
about this again, like is this really a problem to not allow these witnesses?
And I tried to write some kind of reasoning.  I was just reasoning about that.
And what I found is what I have written in that post and also published it in
Delving Bitcoin.

**Mark Erhardt**: Yeah, let me try to summarize a little bit again.  Assumevalid
skips the script verification, but it still does all the checks where it hashes
the transaction data and thus ensures that the txid is what was committed to in
blocks.  And it also, I think in the original, hashes the witnesses and checks
that the witness commitments in the coinbase transaction works.  Obviously, we
don't check the scripts in the witness section for validity, because we're
skipping the script checks in assumevalid.  So, what happens specifically on
pruned nodes is, we download all the witness data and then we just hash it and
check that it is there, and throw it away as soon as the block is more than two
days in the past, and we prune it away.  So, basically, 40% of the bandwidth is
just spent on checking that witness txid matches the commitment in the block.
But if you are assuming that the script was valid because it's buried so deep in
the blockchain, you may as well trust that the coinbase was validly committing
to a witness that was present when the transaction came.  So, the security
assumption change is fairly small, except that you do not actively check that
the witness data is still available on the network.  Is that roughly a good
summary?

**Jose SK**: Yes.  Not only the hashing thing, but we also need to check the
resource limit stuff.  But yeah.

**Mark Erhardt**: So, you implemented this and I think you wrote that it was
easier than you expected?

**Jose SK**: No, there's already a Bitcoin Core PR.

**Mark Erhardt**: Oh, you didn't implement it, you just reviewed it?

**Jose SK**: I just gave a bit of feedback.  I have nothing to do with that PR,
I mean in terms of code.

**Mark Erhardt**: Oh, okay, I misunderstood that then.  Okay, so you're
basically just bringing up the discussion again, and you had this discussion
with Ruben, and he argued that the security assumptions are changed slightly,
because we now no longer check the availability of the data, but just trust that
it was available, similar to how we trust that the scripts were valid.  What
else did you find out?  Do you think we should still move forward with this?

**Jose SK**: What I found is that, so the concern is that we are not checking
the availability.  But what I actually found is that if the witnesses were
missing in the block, and Bitcoin Core auditors and reviewers and developers saw
that block without the witnesses, if they thought the scripts were valid, they
would be lying, right, because if an input doesn't have the witness, the script
evaluation fails.  So, in some way we are saying here that actually
availability, at least in some point in the past, it was needed for the scripts
to be valid, because the missing witness means it is an invalid script
evaluation.  So, that's what I'm saying.  I'm saying that assumevalid is
covering the one-time availability check.  We know that if we are trusting
assumevalid, we know that these witnesses were available, because assumevalid is
already stating they are valid and so they were available.  It is a
precondition.  It cannot be valid without them being there.

**Mark Erhardt**: Right, I agree.  To steelman Ruben's argument, as I understand
it, I think he also argues that we do not check whether the witnesses are still
available on the network now, as in, do people have copies of the whole
blockchain?  But maybe that is an assumption we can make with several 10,000
full nodes on the network!

**Jose SK**: Yeah, but the behavior is the same for any regular pruned node,
because imagine you have your pruned node, imagine it is assumevalid zero, like
you are validating everything, downloading everything, you are checking
availability once, which is during IBD.  You download the whole blockchain and
then you discard everything, and then you don't need to, each year, redownload
the whole blockchain to check if that data is still available in the network.
Pruned nodes, as far as I know, they don't require checking availability.  You
check it once, that's why I say the one-time availability check at IBD, and then
you can run that node for five years, seven, whatever.  It seems enough to check
it once.  That's the current assumption, as far as I know, for any pruned node.
So, what I'm saying with the assumevalid thing, it is the same thing, the same
trust assumption.  We know this data was available at some point in the past, so
maybe five years or whatever, but it is the same thing for any regular pruned
node.

**Mark Erhardt**: Okay, all right.  Do you have a call to action or something
else to summarize?  Otherwise, I think we can move on from this topic.

**Jose SK**: Call to action, I hadn't thought of that.

**Mark Erhardt**: So, for example, a call to action could be, you still think
this could be attractive for node operators that want to bootstrap a pruned node
in an environment where bandwidth is very expensive, for example, so that would
be a good reason to push for this.  And if your argument, that it has very small
changes to the security assumptions, is convincing to other people, that might
be a good option to have maybe not a default option, but an option to have a
lower-bandwidth bootstrapping mechanism, and someone should pick it up again.

**Jose SK**: Yeah, like the post is trying to reason about that, but I agree
completely that a more conservative solution would be to simply, if you want to
speed up IBD time, the most conservative solution would be to redownload the
witness data, but after your sync, right?  So, at least IBD time is smaller, but
then you check, or I would argue you recheck the witness availability later once
you are synced.

**Mark Erhardt**: That is starting to sound a lot like assumeUTXO.

**Jose SK**: Yeah, the same, yeah.

**Robin Linus**: Do we actually know how much of the time in IBD is spent
downloading and checking the witness data?  Because as far as I know, the
biggest component of an assumevalid node is looking up UTXOs in the UTXO
database.  So, I'm not sure if the speed-up in IBD would be worth it for such a
pretty major change from my point of view?

**Jose SK**: Yeah, that's a very good point.

**Robin Linus**: And also, if bandwidth is really expensive for you, then the
bandwidth minus 40% is still going to be pretty expensive.

**Jose SK**: Yes.

**Robin Linus**: So, in that case, assumeUTXO is probably much better for you.

**Jose SK**: Yeah, in most cases, yeah.  If your bottleneck is the database
stuff, the input-output operations, yeah, definitely, it will not be a
significant change.  But maybe for, yeah, if you have some sort of accumulator,
like utreexo, then in that case, likely this will be an improvement, yeah, a big
improvement.

**Mark Erhardt**: All right.  I think we'll wrap this topic now and move on to
the next one.  Thank you for your research, Jose.

**Mike Schmidt**: Yeah, thanks, Jose, for joining us.  You're free to drop if
you have other things to do.  Thanks for joining us, though.

_Quantum computing report_

We're going to move to our Changing Consensus monthly segment, and that means
we're going to talk about quantum this week.  There is a quantum computing
report that was published recently.  Clara, you posted to Delving a summary of
that report, that you and Anthony Milton authored, and it's titled, "Bitcoin and
Quantum Computing: Current Status and Future Directions".  Quantum and Bitcoin
has been a hot topic recently, but what does your research actually show?

**Clara Shikhelman**: So, this report is more a systemization of knowledge.  We
just wanted to gather, in one, place pretty much what we know and where do we
stand, what people are looking at right now.  So, what we know is that if
quantum computing will happen, and especially cryptographically-relevant quantum
computers will appear, this is going to be a problem for Bitcoin, because all of
our signing schemes right now would be broken.  So, the level, not all UTXOs are
as scalable as each other, there are some differences there.  We give some
explanation about this in the report.  We also talk a bit about mining, which we
should probably be less worried about, just because of the difficulty of quantum
mining competing with ASICs, and so on.  But I still think it's very interesting
and a potentially fruitful research topic, but it's definitely not at the same
urgency as anything that has to do with signatures.

We talk about what, in general, other entities believe the timeline will be.
This predicting the future is a very, very difficult kind of hobby, but all we
can do is say what people that research this are thinking.  We also discussed
what signatures and what potential changes are available right now.  But as this
is a very hot research topic outside of Bitcoin in general, in academia and so
on, we're getting better and better signatures, better and better schemes.  So,
there's a bit of a game here.  The longer we wait, the better infrastructure we
can build, the more trust we have in these new schemes.  On the other hand, if
we believe that quantum computers are coming at some point, we need to act.  And
then, we talk about the acting and the 'at some point'.

So, we suggest two possible timelines.  One is the slower, more comprehensive,
where we take about seven years to research everything very carefully, do the
implementation, slowly move to quantum-secure signatures, and so on.  And given
the assumptions right now by NIST and other entities, this is well within the
framework of when they expect any relevant quantum computers to appear.  But
sometimes there's like this jump forward, this burst.  So, the second timeline,
which we think will take approximately two years, including the migration of
UTXOs, this can happen much, much quicker and it's a dual track.  So, we can
jump from one to the other, depending on our assumption, how things develop.
So, these are the main things we talk about in the report.

**Mark Erhardt**: How would the two approaches significantly differ?

**Clara Shikhelman**: The two approaches, so for example, if for some reason
tomorrow there's a big jump on the engineering level that allows quantum
computers, we have to say, okay, we just need to choose the best available
signature that we have right now.  Maybe it will not offer multisignature, maybe
it will be much larger.  Right now, it will have to be much larger.  The
verification will be slower, but we just choose something, we implement this.
All of the UTXOs that are immediately vulnerable, so UTXOs that have their
public key on the blockchain, not hashed.  So, all of this needs to immediately
move, and then we need to have other migration decisions made.  So, this goes
for both timelines, but this means we need to decide right now what do we do
with immigration.  And the big question, which is the philosophical question
that we talk about a bit is, what do we do with UTXOs that don't move, can't
move because the keys are lost, or for any other reason; what do we do in this
kind of situation?  Again, this is a decision that will need to be made hastily
in this more quick timeline, which to be honest, I don't think, if I had to bet,
I would not put a lot of money on this.  But I also don't bet that my plane will
crash, but I learn my emergency exits, so it's good to have it there.

**Mark Erhardt**: Right.  So, the two-year approach would focus on moving the
vulnerable coins first, would just have to be a fairly simple proposal that can
be implemented very quickly.  What would the comprehensive approach look like?
Presumably, since it's such a hot topic, the signature schemes are currently
evolving very quickly still.  I think since we saw the first draft of BIP360,
we've seen a lot of discussion about different signature schemes, eventually
even the recommendation by NIST now for the first post-quantum algorithms.  So,
do you think that in a few years, we might actually get post-quantum schemes
that are not prohibitively huge?

**Clara Shikhelman**: It's possible.  It's difficult to tell, so there's no
reason for it not to happen.  There's no mathematical limit that alludes to the
fact that quantum signatures need to be huge.  So, I do expect things to get
better and better, but again, this is very, very difficult to guess or
guesstimate how quickly the schemes will get smaller or more efficient.
Sometimes, the verification time is a problem.  But I think in the more
comprehensive track, we'll take longer to study more deeply the suggestions.
Bitcoin does not usually follow NIST schemes, like libsecp is not NIST.  There
are other things being worked on inside academia, and so on.  So, there's going
to be a pretty long phase where we all sit down, carefully read the papers,
understand.  For example, we want multisigs, we want all of the cool
functionality that taproot offers.  And then, if we want to step away from that,
then we want to offer similar functionality, and so on.

**Mark Erhardt**: Sorry, I have a follow-up question.  You said that about 4
million bitcoin you estimate are immediately vulnerable by their public keys
being known.  Oh, sorry.

**Clara Shikhelman**: And we're doing some follow-up work on this number, which
might be larger.

**Mark Erhardt**: Right.  So, this is, of course, reused addresses that are
based on hashing, which then have published a public key in inputs and other
schemes that are already with a public key present on the output side, which is
P2PKH or P2TR, for example.  Have you also looked at the number of UTXOs that
hold these coins compared to just the amount of bitcoin?  How much of the block
space would that take?

**Clara Shikhelman**: So, we have, and actually my co-author, Anthony Milton, is
now also checking other exposures of public key.  For example, when forks
happened and people suddenly owned bitcoin and also UTXOs all in Bitcoin Cash,
and so on, for some reason some of them decided to get rid of these altcoins,
but by doing so, exposed the public key and it's available there.  So, we're
still working out a more comprehensive number.  But back to your question, it
really depends on how much block space will we give to that.  But this is
something, at the best case, we're talking about months, at the worst case it
can go on for years.

**Mark Erhardt**: Right.  For example, one could implement new protocol rules
that prefer spending of these old coin types and forbid sending money to them in
the future, in order to make sure that things only move out of the vulnerable
state, but not into it anymore.  But if it were really dire and needed to happen
very quickly and the quantum schemes are huge because, say, the output scripts
required several kB of output script to create the post-quantum locks, then of
course maybe this would have to be paired with a block-size increase or
extension block sort of scheme, or something where we can store all that.

**Clara Shikhelman**: Yeah, some kind of discount or something like that would
be probably considered.  But again, this will need to be a hasty decision only
in the very unlikely case that tomorrow morning …  And this is very important to
say, we don't have quantum supremacy for anything relevant at all.  So, I know
you're welcome to come back to New York and make me eat my invisible hat, but I
would be very surprised if we'll need to use the quick scheme.  But again, it's
good to have it there.

**Mark Erhardt**: Right.  Okay, last question from me for the moment.  We've
seen a number of different proposals being put out there on the mailing list,
and also some BIP drafts coming up, I know of at least three BIP drafts in the
BIPs repository.  Have you also looked at what the current state of art of
proposals for Bitcoin are?

**Clara Shikhelman**: So, in general, we gave a quick overview, but the bottom
line is that everything is very, very early stage.  There's a lot more work to
be done, a lot of research to be done.  There is some research that is
happening.  Research in general is a very quiet process.  So, there are a few
people sitting at home reading papers and staring at whiteboards.  And sometimes
they join the discussion, but sometimes they're just doing the responsible thing
of taking the time and studying the subject deeply before moving forward.  So, I
think at this point we can say that everything is very, very early stage.

**Mark Erhardt**: Cool.  Would anyone else like to chime in on this topic?

**Mike Schmidt**: I have a quick question.  Clara, part of this is around when
it comes, when it's here.  How do we know when it's here?  How do we identify
that it's happening or could be happening?  It's not going to be a binary thing,
right?  So, what does your mind say about that?

**Clara Shikhelman**: So, I think maybe the correct question is, how do we know
that it's coming soon?  Because if it's already here, in many senses, it's too
late.  But I think that a good sign would be quantum computers showing some
supremacy compared to whatever classical computer we have right now, on a
problem that is not designed specifically to be better for quantum computers and
irrelevant for anything else.  So, I think this would be the first sign.  We'll
say, "Okay, so this is really happening, this is not just PR conversations, this
is not just funding being moved from place to place.  We have an actual
scientific proof that we have a quantum computer that is better than a classical
one".

**Mike Schmidt**: I see.  So, it would be sort of a proxy.  So, there's this
other puzzle or thing that quantum computers are solving, it's not, "Oh,
Satoshi's coins moved", it's something outside of Bitcoin that we could say,
"Okay, if they're there, then they're getting close to being here"?

**Clara Shikhelman**: Yeah, then maybe we need to move quicker.  There's a bunch
of quantum canaries of different qualities floating around there.  But I would
start worrying much more, losing some sleep at the moment, that we'll have a
computer showing quantum supremacy.  That being said, this doesn't mean that we
should just sit at home, sip our beers and not do anything.  I think we should
continue doing what we're doing now, which is very carefully studying the
problem and preparing for that day.  And sudden movements have a cost, because
new cryptographic schemes, we don't have the trust in them, we don't know that
they can't be broken.  So, it's very healthy to give it a while, to allow some
PhD student to break the scheme, get their tenured position, and then we'll use
a different one.

**Mark Erhardt**: I think Robin was trying to chime in.  Robin?

**Robin Linus**: Yeah, I've actually got lots of questions.  The first question
I had was, I think all these schemes are based on lattice problems.

**Clara Shikhelman**: Not all of them, but the most prominent ones are.

**Robin Linus**: I think all the ones that are not one-time signatures, is that
true?

**Clara Shikhelman**: That's an excellent question.  I'm literally looking.  So,
there are some hash-based.

**Robin Linus**: Yeah, like Winternitz and Lamport.

**Clara Shikhelman**: Yeah.  So, some of them are one time.  I'm not sure that
all of them, but yeah.  There's also isogeny, yeah.

**Robin Linus**: I was wondering, there was that paper, I think it was called,
"Quantum algorithms for lattice problems".  There was a guy who said he found a
quantum algorithm to break the hardness of lattice algorithms with quantum
computers.  I think the paper was retracted because they found a bug in the
paper, but I think I've heard quite a few cryptographers saying that it might be
possible to fix that bug, and then lattice-based crypto would not be considered
post-quantum anymore.  So, is that a concern?  Or do we have a fallback?

**Clara Shikhelman**: So, I think it's a great point to what was said earlier.
That's why waiting is very healthy.  That's why we don't want to go for
something right now and then it will be broken.  There are some other options,
as I said, like things based on hashes, isogeny, and so on, but it's a very
active research topic.  So, I couldn't say right now.  If you said, "Okay, right
now, choose a scheme.  We have to go with something.  Decide", I would first of
all point to, I am not a quantum cryptographer, so I would talk to somebody who
has the right education.  But also, I think there are options that are
considered feasible, but not perfect, not exciting, and we're waiting both for
better things to come up, and also to make sure that the other things are not
broken.  I think I know what paper you're referring to.  Let's see if they can
fix it and then all of the lattice things go out of the window.  But to the best
of my knowledge, this is not the case right now.

**Robin Linus**: But I think the paper still, how do you say, disrupted the
confidence in lattice-based crypto a lot.

**Clara Shikhelman**: Yeah.  So, honestly, we'll just have to wait and see and
give some time.  Because in general, in cryptography, we sort of trust that
something can't be broken because nobody broke it.  You never know.

**Mark Erhardt**: One counter-question, what recent breakthroughs or milestones
have been reached by quantum that would sort of illustrate that it is making
progress?  I remember a couple of years ago that there was a news headline that
quantum had factored 21, and that doesn't seem super scary if we're looking at
these sort of numbers that would need to be factored to break DLCs.

**Robin Linus**: I think it also exploited some special structure in 21.

**Clara Shikhelman**: So, I think the past year or so, there were things from
Microsoft with their Majorana-based quantum computers, and so on, that point to
different structures, different ways to build quantum computers.  I think, yeah,
there were a bunch of announcements from Google also, there's Willow, but there
was nothing there that you can say, "Okay, this is the real thing".  That's
where we are right now.

**Mark Erhardt**: All right, so I can still continue sipping my beer and say
that quantum seems more like the cold fusion of computer science to me.

**Clara Shikhelman**: I think that's an exaggeration.  I wouldn't go to the
level of, "It's cold fusion, it's not happening and it's never going to happen",
because a lot of really smart people are getting a lot of money to do this, and
maybe they can.  And there are some very prominent people, like Scott Aaronson,
who was really on the front of, "It's all FUD and it's not happening anytime
soon".  And then recently he said, "Okay, this is a time to change the message
and we need to have a plan".  So, enjoy your beer, but keep posted, be part of
the discussions, because maybe it won't, but maybe it will.

**Mark Erhardt**: Okay.  Robin, did you have maybe one more question or so?
Make it count.

**Robin Linus**: One more question.  I could ask the heretic question, but I
think the more interesting question is about stock aggregation.  That's maybe
not another interesting topic, that we can just aggregate all these signatures
that are too large into one STARK and maybe save the block size this way?

**Clara Shikhelman**: Yes, maybe.  So, in general, like STARKs offer a lot of
functionality and it can help with this, but then it can allow for other things
to happen on the blockchain.  And people have different thoughts about Bitcoin
in general, and should it happen, should it not?  So, there's the question of,
do we want to allow a broader functionality that helps with quantum, but also
with potentially meme coins?

**Robin Linus**: I think they are two different questions, no?  On the one hand,
the question if we would want a STARK verify, like essentially OP_STARKVERIFY in
Bitcoin Script that would allow us to do a general verification of programs; or
if we just use it for witness compression?

**Clara Shikhelman**: Okay, yes, sorry, I thought your question is, do we want
to allow OP_STARK, OP_CAT, and so on?

**Robin Linus**: For witness compression, because these signatures are so huge
and we could get around that if we would just compress them into one single one
per block.

**Clara Shikhelman**: I know there is some works and some thoughts on that, but
then you do want to do this carefully, because I'm not sure there's a way to do
this only for quantum signatures and not for other things.  So, again, we need
to tread carefully and decide what is it exactly that we want to put on the
blockchain.

**Mark Erhardt**: All right.  Thank you very much for this great overview.
Clara, do you have any more summary or call to action that you want to add to
the segment?

**Clara Shikhelman**: So, I think the call to action is, I can't shout it any
louder, do not reuse addresses.  And if quantum computing is the thing that will
make you stop reusing addresses, so be it, stop reusing addresses.  Beyond that,
I think there's work and discussion to be made.  So, if you're a cryptographer,
especially quantum cryptography, come on board, there's a lot to be done.  And
there is, of course, the philosophical dilemma of, what are we going to do in
the case of quantum computers with UTXOs that did not migrate?  And I think this
is a very interesting discussion that we need to understand deeper.  And then,
it would be good to get all of this discussion out of the way, just in case
we'll need to act quickly.  So, there's a bunch of research topics and
discussion topics out there.  But if you'll take one thing, do not reuse
addresses.

**Mike Schmidt**: Clara, thanks for posting this research, summarizing it, and
joining us today to talk about it.  It's an important topic and I'm glad we have
smart people like you aggregating this information together for us.  Thanks for
your time.

**Clara Shikhelman**: It's been a pleasure.

_Transaction weight limit with exception to prevent confiscation_

Next item from the Changing consensus segment is titled, "Transaction weight
limit with exception to prevent confiscation.  Vojtěch, you posted to Delving
Bitcoin, "Non-confiscatory Transaction Weight Limit".  Maybe you can explain a
little bit of the motivation for your post, and also wanting to limit
transactions' weight at the consensus level?

**Vojtěch Strnad**: Sure.  So, as you probably know, there is a policy rule in
Bitcoin Core, and other nodes probably as well, that limits the maximum weight
of a transaction to 100 kvB.  And we recently went through the exercise of
learning that when people start bypassing a policy rule, then we could just turn
it off, as just happened with OP_RETURN.  But in this case, it would not be a
good idea.  For example, the weight limit ensures that -- well, let me go to
pre-segwit inputs, which have a quadratic hashing problem.  This means that when
you, for example, create a transaction that has 10 times as many inputs, then
it's 100 times as difficult to verify.  This is one of the reasons that we have
this limit in the first place.

Another reason is that block template building gets more difficult the larger
transactions you have.  Ideally, you want a lot of small transactions to be able
to construct a semi-optimal template.  And the more larger transactions you
have, the more computational power you have to invest to get to a somewhat
optimal result.  Actually, the whole problem is, I think, what's known as
NP-complete.  So, there is actually not a known solution that would create fast,
optimal templates.  And very recently, a couple of mining pools announced that
they would be bypassing this policy rule for the purposes of BitVM transactions,
which have to be very large because BitVM scripts are very large.

So, what do we do here?  Some people would be apparently okay with just making
the policy limits a consensus rule, basically killing BitVM in its infancy.  I
thought we could create a sort of carve-out to allow at least one oversized
transaction in a block, but with the provision that it would be the only
transaction in a block.  This has a very good reason, because if you allow one
big transaction, then again, block building becomes difficult again.  But if you
allow just one, then block building is basically you try the normal block
building process, and then you look at the highest fee oversized transaction,
and you just pick whatever gives you more fees.  But there are more problems
with this approach, as I mentioned in my original post and other people
mentioned.

**Mark Erhardt**: All right.  And that sounds like a very good summary already.
I heard BitVM, so I think I'll first ask Robin whether he wants to chime in on
this topic.

**Robin Linus**: Yeah.  So, we are fully aware of the fact that these huge
transactions are a bit crazy.  And we are working on an optimization using
double circuits, and they would allow us to get rid of these crazy transactions.
And the craziest transactions that we would have then would be 70 kB, and the
rest would be just standard transactions.  Actually, 70 kB is also standard, I
think, so it wouldn't be that bad anymore.  It's a huge pain for ourselves to
have these huge transactions.  We actually don't want to execute them ever.
Probably they never have to get executed because it's just in case somebody
cheats.  But if they cheat, they will lose a lot of money, so they probably
won't do it.  So, most likely we won't ever execute them, but in the current
design, it isn't necessary that it would be possible to execute them.  But
hopefully we get rid of that.

**Mark Erhardt**: Right.  So, you're not strictly opposed, you're saying, Robin,
because hopefully in the long run, this is not really a limitation of BitVM that
it needs whole blocks of data.  Also, you could probably split up your data into
multiple standard transactions.  No?  Okay, never mind then.  Vojtěch, you say
that using the 100,000 vB as an outright limit has some pushback.  Do you want
to elaborate why we shouldn't have no exception?

**Vojtěch Strnad**: Well, the first reason is, as you already know, there are
known use cases for such large transactions.  And although they might be able to
optimize to a smaller size, that might not be the case with every possible
future use case.  And we probably don't want to close the door forever to
something that could turn out to be actually really helpful in scaling Bitcoin.
So, actually Greg Maxwell chimed in to say that this limit could just expire
after, like, n years.  And if by then a use case for large transactions
appeared, we could just let it expire; and if not, we could do another soft fork
to extend it, which is, well, I mean nobody likes soft forks, especially not
recurring.  But it's an idea, it's something we can consider.

**Mark Erhardt**: It would make sense if you think that perhaps we will find
pressing needs for larger transactions in the long run.  I have another related
question, which is, the current average transaction size is 340 vbytes.  Why do
we even need such a high limit as 100,000 vbytes?  Shouldn't we then even soft
fork in a smaller limit that makes it even more likely that people are building
optimal templates with low computational cost?

**Vojtěch Strnad**: Well, for example, another use case for very large scripts
is huge multisigs, which I don't know who needs, like, 500-of-600 multisig, but
the protocol allows it and since we now allow it, it would look pretty bad if we
removed this option, because people today might be already building with this
option in mind and they wouldn't want to see it removed.

**Mark Erhardt**: So, even though BitVM was identified as a likely antagonist of
this change, BitVM representative here says it's probably not a big deal.  Is
there any other pushback towards this so far, or has it just not hit the news
cycle yet?

**Vojtěch Strnad**: Well, for example, there have been very large transactions
embedding large jpegs, for example.  And even though there are very few people
who would actually be impacted by not being able to do this again, again there's
a kind of rule in soft forks that we don't disallow any existing functionality.
And especially, we try to go around making transactions invalid that people may
already have signed and just not broadcasted yet.  For example, if you look at
the reasoning behind the recent consensus cleanup revival from Antoine, he went
to great lengths to make sure this doesn't happen.  For example, this proposal
doesn't include the weight limit.  It instead proposes a signature limit that's
very generous but still makes the worst case for block validation a lot better.

**Mark Erhardt**: All right, cool.  So, does anyone else want to chime in here
still?

**Mike Schmidt**: Vojtěch, you may have already articulated this and I missed
it, but what is the challenge that's introduced by having these large
transactions when building a block?

**Vojtěch Strnad**: It's just that the algorithm for packing blocks optimally
works better.  The heuristics work better if there are a lot of small
transactions, because we are not using an optimal algorithm.  As I said, that's
NP-complete, that's exponential time, or whatever, so we are using a heuristic
approach that is fast but non-optimal, and it's less optimal if you have large
transactions.

**Mark Erhardt**: Right.  This is about the tail effect when you pack a block.
As soon as you hit the first transaction that has a high enough feerate to be
considered but doesn't fit into the block, you have to compare that with
removing other transactions that were already selected and instead, picking this
bigger transaction.  So, where previously with the heuristic, you can basically
just walk down the list of the highest feerate transactions until you have a
full block, as soon as you hit a transaction that is larger than the remainder
of the block, it becomes a 'try all possible combinations' problem, and that is
very expensive to evaluate.

**Mike Schmidt**: And that goes for cluster mempool as well; cluster mempool
solves this?

**Mark Erhardt**: That is correct.

**Vojtěch Strnad**: No, cluster mempool just solves the ancestor and descendant
relationships, but this problem with large transactions is present even when
there are no relationships between those transactions you're mining.

**Mike Schmidt**: Vojtěch, thank you for joining us.  You're welcome to hang on.
We've got one more Changing consensus item, and then we have our Releases and
Notable code segment.

_Removing outputs from the UTXO set based on value and time_

Last Changing consensus item, "Removing outputs from the UTXO set based on value
and time".  Robin, your Delving Post proposes a soft fork for removing low-value
outputs from the UTXO set and we can remove them after a certain period of time.
I think all else equal, we all want a smaller UTXO set for Bitcoin, since it
makes running a node easier.  In fact, witness discount is one example of a
change previously to incentivize the spending of UTXOs instead of creating them.
But what you're talking about in this post is a little different from that.  Can
you get into the origin of and the issues with these low-value outputs, and how
you might see removing them from the UTXO set?

**Robin Linus**: Yeah, the guys from mempool.space, they published some
interesting statistics about the UTXO set.  Essentially, it says that since
ordinals started in, I think, 2023 or something, the amount of UTXOs doubled
from like 90 million to 180 million, or even more.  And the serialized size of
the UTXO set even tripled from roughly 4 GB to almost 12 GB.  And half of the
UTXO set are dust UTXOs, so they are values of below 500 sats, or something.
And I think it's fair to consider them spam.  Also, if you look at the
characteristic that they are hardly ever spent, most of these UTXOs, they get
created and they remain in the UTXO set forever.  Maybe at some point in the
future, for some reason, they all get spent at once and we are getting rid of
them, but it's quite likely to assume that they will never get spent.  And yeah,
it's a growing problem.  And there are all these weird protocols that
incentivize the creation of dust UTXOs for ordinals things, and like all kinds
of means of some meme tokens, all kinds of stuff that is not the core mission of
Bitcoin, I would say.  And yeah, that raises the question if we can do something
about it.

In particular, the entire OP_RETURN drama, I would call it, was started by the
question of Citrea inscribing unspendable outputs into the UTXO set essentially
for proof of publication.  So, they use it as a data publication layer, which is
also not very nice.  So, I wondered if there is a way to get rid of these spam
UTXOs in some elegant way that wouldn't be too much of an invasive change.  My
first idea was just to have an expiry date.  So, essentially you take the amount
and then you subtract the UTXO age times the dust limit, or something.  So, you
take some formula that essentially tells you when a UTXO expires.  And once the
UTXO expires, you just remove it from the UTXO set and it becomes unspendable.
So, that was the first idea.  I posted it on Twitter and very quickly, people
wanted to kill me, because they said it's like confiscation maybe!  Like, "We
cannot confiscate people's money no matter how many sats; every sat counts and
we should not touch people's money".  So, I thought a little bit more about it.

Also, I talked to Luke Dashjr and he told me that we could just have some kind
of accumulator scheme, and then you could make them spendable after.  To explain
it better, UTXOs would still expire, but they would not become unspendable, but
they would be moved into that accumulator.  And then, you could spend them by
providing an inclusion proof for your UTXO in that accumulator.  And then, yeah,
essentially they are still spendable, but the burden of storing them or the
burden of proving them shifts to the user, away from everyone to that individual
user.  And it turns out that we already have a TXO accumulator scheme in
Bitcoin, because the blockchain in itself is actually an accumulator.  Since we
already have merkle trees in every block and since everybody's storing the
header chain, we can essentially just use merkle inclusion proofs, the ones that
already exist, to prove inclusion of particular UTXOs in the blockchain.

So, the only thing that would be missing then would be to prove unspentness.  We
could just have quite a compact scheme that would essentially just be a pointer
into the blockchain.  So, we would have essentially the block height, then the
transaction index, and then the output index.  And this triple would uniquely
identify every UTXO or every TXO in the chain.  And then you could just store
sets of these numbers to have all the expired UTXOs or to represent all the
expired UTXOs.  And this set can be stored quite compactly.  We could compress
it down to, let's say, 200 bytes without too much engineering, because they are
very low entropy.

**Mark Erhardt**: Sorry, 200 bytes per pruned UTXO?

**Robin Linus**: In total, sorry.

**Mark Erhardt**: Oh, okay.  I was going to say that's bigger than the UTXO
itself!

**Robin Linus**: No, no, sorry, that was maybe a bit confusing.  I meant for
these 5 GB of dust UTXOs that are currently in the UTXO set, we could compress
them down to roughly 200 MB.

**Mark Erhardt**: I see, okay.  So, basically the idea is if you have very low
value UTXOs, after some amount of time passes and the UTXO has not been moved,
we would add them to an accumulator or some data structure and people can later
spend them, but now they have to add proof.  Wouldn't that make it even more
unlikely that they're spent, because now it takes more data to spend them?

**Robin Linus**: Maybe, but that would be less of a burden because it's way more
compact, like you reduce it down to, I don't know, 5% of the data essentially.
Also, the other thing is that with a very high probability, these UTXOs just
will never get spent in the first place.  So, if 99% of them never get spent, we
maybe move the needle to like 99.9%, but this is just negligible actually.

**Mark Erhardt**: I mean, very likely, all the Sochi spam, for example, with the
1 sat outputs that were spammed at a bunch of different addresses, those are
just economically unspendable at pretty much any feerate.  Even if a transaction
only costs 1 sat, making a transaction eats up the entire UTXO amount.  So,
there is a limit under which transactions are completely unexpected to be ever
spent.  I'm not sure, so the mempool.space UTXO report identified that, I
believe, 49.1% of all UTXOs are 1000 sats or less.  So, this is still
significantly above the dust limit for some of the output types.  For P2TRto
output, the dust limit is 330 sats, and that's counting how much it would cost
to create the output and spend the UTXO at 3 sats/vB.  So, in actuality, to
spend a P2TR keypath output is only 58.5.  No, yes, 58.5.  Yeah, go ahead.

**Robin Linus**: I think something like that, but you're right that 1,000 sats
is more than the dust limit for many output types.  However, I think they also
published a more, like, fine-grainer statistic and it shows essentially the same
that even for, like, if you look at the specific output types, roughly 50% of
the UTXO set is exactly the dust limit.

**Mark Erhardt**: We do have to see that since Christmas, about 17 million of
the UTXOs have been consolidated from 187 million to 170 million now.  Of
course, we would hope that other people also see that trend, but clearly a lot
don't because we wouldn't have empty blocks if people were consolidating, even
at minimum feerate.  So, yeah, to me it makes a lot of sense to say this is such
a tiny amount, and clearly nobody is even spending this at minimum feerate, so
maybe we can just burn it.  However, as we know, a lot of bitcoiners are
extremely sensitive regarding confiscation or burning-nation and even for
minuscule amounts like 1 sat, will go to war.

**Robin Linus**: Yeah, also there's another type of outputs which are provably
unspendable or most likely unspendable, because people are just inscribing
STAMPS, they're inscribing images into the UTXO set and they're doing it
purposefully to spam the UTXO set or to make them unprunable.  And all of them
will never get spent because people just don't have the keys to spend them.

**Mark Erhardt**: I think that is incorrect actually, because STAMPS very
deliberately uses a 1-of-3 multisig scheme, where 2 of the pubkeys are data
carriers, and the 1 pubkey is a key in the wallet, because that way they can
threaten that they would be able to spend it and you actually cannot delete them
from the UTXO set.  It's part of their scheme.

**Robin Linus**: Interesting, yeah.

**Mark Erhardt**: It's the way to be as annoying as possible.

**Mike Schmidt**: Diabolical.

**Robin Linus**: Yeah.  With Dust Expiry, you could get rid of them.

**Mark Erhardt**: You could, yes.  I mean, obviously, the people that have
received dust amounts that are not tied to any other sort of asset or
sentimental value are not as perturbed about this.  Like, someone losing 1 sat
that they would have to spend 100 sats to ever spend is probably not going to
lose sleep over that.  But some people have been using very small amounts to
store inscriptions or ordinals or pictures or Colored Coins protocol, or who
knows what.  And of course, for people not running these out-of-band or
client-side validation protocols, they wouldn't be aware of this special meaning
of these UTXOs.  So, pruning them away might be considered an attack by these
out-of-band schemers.  But looking at the landscape of the OP_RETURN debate in
the past few years, this might be immensely popular with many bitcoiners!

**Robin Linus**: Yeah, ironically, many people attacked me for it.  It was also,
from a PR perspective, really bad to first post the idea of burning the coins
and then coming up with the second one, because people just stopped reading at
'burn' and then they thought I'm the Devil, and then it doesn't matter anymore
what else I said!

**Mark Erhardt**: Yeah, I know that feeling.

**Mike Schmidt**: I assume harkening back to our previous topic on quantum,
within that discussion, there's the 'let quantum computers steal these
unmigrated coins' and then there's the 'burn them'.  I assume, Robin, you would
be on the side of burning them then, because that would essentially achieve this
goal eventually if that were to happen?

**Robin Linus**: I don't understand that debate.  I would have to dig deeper
into it.  I'm not quite sure what the pros and cons are for burning and not
burning it.  So, I can't really make a statement about that.

**Mark Erhardt**: I think that's also not necessarily true, because some of
those UTXOs -- oh, I guess if it's dusting of addresses that had been used
before, it's always address reuse, and yes, they would get burned.  But you
could still receive very small amounts to fresh addresses that are hash-based.
So, you could theoretically have some tiny amounts that are not
quantum-vulnerable.

**Mike Schmidt**: Robin, any parting words, calls to action?

**Robin Linus**: If you're interested in that, go on Delving Bitcoin and comment
on the thread.  For me, it was just a simple idea that I wrote down.  I'm not
really working on it.  I don't invest that much time actually.  I thought it's
just worth writing it down.

**Mike Schmidt**: Well, Robin, thanks for joining us and opining on not just
this item, but some of the other items as well.  We appreciate your time.

**Robin Linus**: Thanks for having me.

_Core Lightning 25.05rc1_

**Mike Schmidt**: Releases and release candidates, we have two this week.  First
one, Core Lightning 25.05rc1, which we covered in depth when Dave had on Alex
Myers a few weeks ago, and that was in #355 podcast.  So, check that out for a
comprehensive deep dive by somebody who's involved with the project.

_LND 0.19.1-beta.rc1_

The second release was LND 0.19.1-beta.rc1.  We covered the major release, which
was LND 0.19.0-beta in Newsletter and Podcast #355 as well, and this is a minor
follow-up release with some bug fixes.  There is a memory leak that was fixed, a
serialization bug around writing a backup file, there's a case where bumpfee
didn't give an error response, they fixed the case where LND would crash related
to running on some 32-bit systems.  And then, there was a couple of fixes
related to the rbf-coop-close that they launched in 0.19, one where a peer would
not disconnect properly, and another error where the correct production feature
bit for rbf-coop-closes wasn't being sent.  And actually, I don't think that was
a bug, I think that was actually just a feature change in this minor release
that they perhaps forgot in the 0.19.0 release.  Murch, did you notice anything
else?  All right.

_Bitcoin Core #32582_

Notable code and documentation changes.  We have Bitcoin Core #32582, which adds
additional compact block logging to help measure performance of compact block
reconstruction.  This PR is related to a Delving post by 0xB10C that we covered
back in Newsletter #315 around compact block reconstruction statistics and some
analysis and data around that.  Murch and I discussed that data in Podcast #315,
so if you're curious, jump back to that.  The change in this PR now logs
additional information around the total size of transactions that a node
requests from its peers, the number and total size of transactions that a node
sends to its peers, and a timestamp to track how long the mempool lookup step
takes.  So, these are all, from what I saw, logging statements in the code.  And
so, folks who are going to run the forthcoming version will have access to that
additional log information and be able to run additional statistics, like 0xB10C
did last year.  Murch?

**Mark Erhardt**: Yeah, so David has been looking at the impact of compact block
relay slowing down, and also whether it might make it faster if some of the last
transactions received by nodes before the block arrives were to be sent along
with the block announcement directly.  So, I think this is just related to the
work he is doing in order to establish the exact impact and the experiments he's
running, and then why not upstream it and make delogging available to anyone
that wants to look at it.  So, yeah, this is a tiny code change.  It just adds
eight lines of code, or actually modifies four and adds a few, and just gives a
little more insight in the quality of compact block relay.

_Bitcoin Core #31375_

**Mike Schmidt**: Bitcoin Core #31375 adds a new binary executable named
bitcoin-m, which can be used to discover and launch the various other existing
Bitcoin Core binaries.  This PR is actually part of the multiprocess effort
within Bitcoin Core to provide separate binaries for things like the GUI or
node.

**Mark Erhardt**: This is a PR from end of last year.  This is related to the
multiprocess.  We're talking about PR #31375.  This is part of the multiprocess
project, and as we've debated or discussed in previous versions, the idea of
multiprocess is to split up the Bitcoin Core binary into multiple different
binaries that run in separate processes.  Currently, everything runs in one
process.  So, for example, when a new block comes in, the wallet will be frozen
for a moment until the block is processed completely.  And the idea here is that
you could, for example, separate the node, the GUI, and the RPC client.
Specifically with this new binary, that is a wrapper for the multiprocess
binaries, you can start with bitcoin-m in order to parse which ones of the other
binaries you want to start.  Or I think I'm misstating that, sorry.  If you call
bitcoin-m, it will start in the multiprocess mode, whereas with just bitcoin,
it'll start the regular old bitcoind.

As far as I'm aware so far, only the RPC for -ipcbind works differently, and
there is still ongoing work that will enable to make these different processes
run on separate machines, or to be able to start and stop them independently.
So, right now, even though there are multiple processes, I think that everything
would start or stop together when you kick it off.  Anyway, this is probably the
longest-running project that is still being actively developed, the multiprocess
thing.  We're pretty excited that it's coming along like this.  If you want to
understand all the changes and new features, I would suggest that you take
another look at #31375.  Presumably, it has release notes that state all of the
relevant information in detail.

**Mike Schmidt**: The only other thing that I would add, if you can hear me, is
we covered this PR in the PR Review Club segment last month, in the Newsletter
#353, and we had stickies-v from the PR Review Club in Podcast #353, where we
got into some of the more nitty-gritty details of the PR.

_BIPs #1483_

BIPs #1483 merged BIP77 titled, "Async Payjoin".  Murch, you want to introduce
our special guest that we didn't previously introduce?

**Mark Erhardt**: Yeah.  Hi, Dan, thank you for joining us.  Do you want to
introduce yourself?

**Dan Gould**: Hi, Murch, hi, Mike.  Thanks for having me guys.  Yeah, I'm
working on payjoin for a long while.  This BIP PR is almost two years coming
along, so it's great to see it merged.

**Mark Erhardt**: Yeah, I'm very excited.  This has been a huge effort by you,
and meanwhile there's I think four or five people part-time or full-time working
on payjoin-related topics.  Do you maybe, I think we've talked about this a
little bit already, but I think it's been maybe some 90 episodes or so.  So, how
about you give us a little overview again, what exactly maybe payjoin is, how it
differs from the prior payjoin approach, and where we're at?

**Dan Gould**: Wow, I can't believe it's been 90 episodes.  We've definitely
been cranking along.  Like you said, there are a number of people working
full-time and part-time and volunteer on Payjoin Dev Kit now to bring this stuff
to the world.  But first, let's get through why that matters, why we have
payjoin.  So, I think the best frame to view payjoin through is the one of
batching, because people know, through the scaling growing pains that Bitcoin
had, that the exchanges needed to batch outputs in order to reduce the overhead
that it took to make payments, to make transfers, because it cost too much for
people.  What the exchanges did though only let them batch outputs of
transactions, because they controlled the whole transaction.  If two people, one
on each side of the transaction, maybe one sending us a value and receiving some
value, both batch their inputs and outputs, then you have payjoin.  Payjoin is
basically the mechanism to coordinate that kind of batch.

So, this idea has been around for a while and these transactions that batch
inputs and outputs can be created in all sorts of different ways, both with this
old synchronous payjoin protocol, and even in Lightning, and even before that
with some manual construction where you just pass around transaction data and
come up with a valid transaction.

**Mark Erhardt**: Let me maybe just jump in very quickly.  So, the efficiency
gain of batching payments is, when you make a payment in a single transaction by
itself, you need at least one input and usually you need a change output where
you send to yourself and you have the transaction header.  So, you have one
input, one header, one output as overhead for creating one payment output.  If
you make many payments in parallel with many different transactions, you pay
always this overhead.  If you instead make one transaction, you might have one
or a few inputs, many payment outputs, still only one transaction header, and
still only one change output.  So, you can save on the overhead, not of course
on the outputs you want to create, which are the intended goal of the
transaction.

With payjoin now, when the sender and the receiver collaborate to build a
transaction, you can batch payments with receiving, or you can parse through
payments and you can sort of skip the step where you first receive it and then
consolidate the UTXO later, or spend it in another transaction, by having the
receiver and the sender add inputs and then create a single change output that
goes to the receiver, while also potentially making some payments.

**Dan Gould**: Yeah, I second all of that, Murch.  The important thing to
remember with the savings from batching, the most important thing I think, is
often forgotten, which is that you're not just sharing the transaction overhead,
but you're also reducing the number of inputs you need to spend to enact your
payments.  And the input is really the expensive part of the transactions, on
the order of ten times more expensive than the header itself.  So, when we can
do more creative batching that allows us to reduce the number of outputs we
create, that reduces the burden of inputs we'll have to spend later.  And the
really neat thing that gets a lot of people excited about payjoin is that having
multiple different parties contribute inputs to a transaction breaks this common
input heuristic, where a third-party observer could assume that all the inputs
to a transaction came from one person.  And this is a privacy problem that
Satoshi singled out in the whitepaper as something that was kind of necessary
from his design.  But payjoin breaks that.

In the past, what's thought of as payjoin, this coordination mechanism to make
these batches, was a synchronous protocol where I sent a message to someone I
wanted to send to.  They would add their input and respond with a message, and
this needed to happen on HTTP synchronously, both people needed to be online.
This BIP77 protocol makes it so that the receiver doesn't need to run a server
and the sender and receiver don't need to be online.  This can all happen using
an untrusted third-party server.  And we add some improvements to metadata,
privacy, and encrypt messages by default and don't require TLS dependencies.
It's an upgrade focused on adoption.

**Mark Erhardt**: That sounds super-attractive.  Whereas previously, if you
wanted to run or create payjoins, you run your own server, you didn't have all
the payment or all the communication rails to communicate that you wanted to do
a payjoin, and adoption is minuscule.  I think BTCPay Server has it.  Is there
any other projects that implemented the prior versions of payjoin?

**Dan Gould**: To receive, I think it was just BTCPay and the JoinMarket client.

**Mark Erhardt**: Right.  So, now, by having the directory where people store
the payment, the PSBT that encodes the payjoin they want to create, and I
believe the directory can actually not read the payload, it is encrypted from
the sender to the receiver and the directory is just serving the space but
cannot interact or even observe what is being negotiated between payer and
receiver, that makes it a lot simpler for any sort of client to implement
payjoin support.

**Dan Gould**: That's right, Murch.  The untrusted directory sees only an 8 kB
blob of random data effectively for each message.  So, all the messages look the
same.  And in order to interact with the directory, you use an Oblivious HTTP
server so that the directory doesn't even know your IP address.  And this makes
it so that the directory doesn't have the ability to link senders and receivers
together, or even link IP addresses to particular people doing payjoins?

**Mark Erhardt**: Yeah, so I would argue that not just this makes it so much
simpler to implement in wallets, but also PSBTs have come a long way since
payjoin v1 was proposed.  We have other standardization schemes like, yeah, I
think PSBT is actually the biggest, but it is much more established by wallets
in general to participate in multiparty transactions or multi-signer
transactions, people who want to sign transactions between their hardware
devices and an online device that tracks the wallet.  So, all of the
infrastructure to make this happen has been built out a lot more than it used
to.

**Dan Gould**: Yeah, three huge things on this point.  One is that the Oblivious
HTTP does the metadata hiding without Tor.  So, it actually just works in the
web browser even.  If you can do some basic encryption using cryptographic
primitives that are used by any software that uses Bitcoin, then you have the
ability to send the network messages, as long as you can send HTTP.  The second
thing is that, like you said, PSBT is everywhere.  So, basically, any sort of
Bitcoin wallet library is able to do this.  And the third is that the
asynchronous operation has a benefit, I think, beyond what's really talked about
in public, which is that a lot of these payment processors, say you're an
exchange and you want to adopt this to cut through withdrawal to user deposits,
you want to batch these transactions together so you can save even more money on
the type of batching you do already, your payment processing system is probably
asynchronous.  It might not necessarily be offline, but you probably have some
manual authorization that goes through.

So, a big part of why we ended up building this robust async system was so that
we could be used with the payment processors.  You'd be surprised how difficult
it is.  Well, maybe you wouldn't be surprised, but I think the world at large
would be surprised how difficult it is to get a synchronous endpoint to be
served by an exchange where there's all this logic happening in the background.
So, like I said, everything serves so that the payjoin protocol can be adopted
all over the place by using the Payjoin Dev Kit.

**Mark Erhardt**: So, you're saying that this saves cost and that's the primary
purpose?

**Dan Gould**: I think that's the most attractive purpose.  I think a lot of
people want to adopt this because of the privacy benefits, of course.  You see
it, the early adopters were Bull Bitcoin Mobile, who has plans to integrate with
their exchange.  This is public, Francis will go and tweet about this.  And you
have Cake Wallet, who's really interested in the privacy aspects of it.  So,
they rolled out payjoin v2, the async payjoin, in their mobile wallet.  And it's
all interoperable, backwards-compatible with the synchronous payjoin of old.
But I think for those businesses to stay competitive, you have to support
batching going forward.  And I think payjoin is just the next iteration of
batching.  And as a consequence, we can have a privacy-by-default upgrade, where
maybe you don't have perfect privacy, but payjoin makes it so that the most
aggressive surveillance practices, dragnet surveillance practices, are
significantly less effective than they used to be, even if just some of the
volume on the network is using this technique.

**Mark Erhardt**: Yeah.  So, by breaking the common input ownership heuristic,
which was described by Satoshi in the whitepaper saying, "If you see a
transaction, very likely all the inputs must have been controlled by the same
party", and even if there's just a number of transactions that break this
heuristic, it will sow some doubt about this heuristic, and clustering just
addresses based on the common input ownership heuristic will be less reliable.
It'll increase the effort to do onchain surveillance.

**Dan Gould**: Which is important, particularly as bitcoin gets adopted as
money, because having this clustering available brings a lot of risk to bitcoin
holders for something like a wrench attack.  If you're transferring money to a
counterparty and that counterparty can cluster your whole wallet, figure out how
much money you have, figure out the people you're doing business with, they
might be able to profile an individual as a particularly lucrative target for
attack.  So, having some basic privacy makes it more attractive and convenient
to use bitcoin as money, especially self-custody, where otherwise maybe you'd
say, "Oh, I need to put all my money in the exchange, all my bitcoin, I need to
use a custodian, because they give me that level of protection”.

**Mark Erhardt**: I would also argue that it's extremely attractive for people
accepting onchain payments, because one of the things that leaks is volume of
business and it leaks information about their business patterns and success to
their competitors; and making it slightly more private on how much money flows
through their business might also be attractive from the business and receiver
side.

**Dan Gould**: Agreed.

**Mark Erhardt**: So, let's back out a little bit.  You said there's these
directory servers and pretty much anyone could run one of them, and then if I
run a client that connects to a directory, would I be able to get to verify that
all these privacy properties hold as discussed?

**Dan Gould**: So, anyone can run the directory because the source code is all
at github.com/payjoin/rust-payjoin.  You'll see the directory there.  You spin
it up and provision TLS and someone can connect to it through an Oblivious HTTP
relay.  The clients do all of the privacy-preserving measures.  So, your client,
if it is a correct client, if you use Payjoin Dev Kit, or hopefully we see some
alternative clients now that the BIP is merged and people have a spec to build
to, but if you have a proper client, the client is doing the encryption and
encapsulation through Oblivious HTTP so that the payload you send is exactly
uniform with all of the other payloads, and you don't have to worry that a
directory is malicious.  You're not trusting the directory to preserve your
privacy.

**Mark Erhardt**: If the payload is limited to 8 kB, does that mean you can only
create small transactions?

**Dan Gould**: For the time being, with our current iteration, that is the case.
This is on the order of tens of inputs; I think hundreds of inputs would be very
hard.  But it's possible to append messages through multiple mailboxes.  It's
something we haven't implemented yet.  I think it's important to note for
transparency that if you use v1, you're sending an unencrypted payload, so the
directory would be able to see that you're giving it to a third party.  This is
a limitation of the v1 protocol.  However, in that protocol, the v2 receiver
that's backwards-compatible with the v1 sender will disable output substitution
so money can't be stolen, but the directory could see that there's an original
PSBT that gets upgraded to a payjoin.  So, you don't have the same privacy.  The
common input ownership heuristic isn't broken from the perspective of the
directory, but this is kind of a limitation of v1 that's already there.

**Mark Erhardt**: Right.  So, you're saying that while you're fully
backward-compatible with v1, if you're implementing this just now, go
straightaway, just implement v2, you get all of the bells and whistles of the v2
protocol?

**Dan Gould**: Definitely.

**Mark Erhardt**: So, you said that there is now work on the Payjoin Dev Kit.
Do you want to talk maybe a moment about that?

**Dan Gould**: I'd love to.  So, Payjoin Dev Kit is exactly what it sounds like.
It's a software development kit that lets you plug payjoin into whatever wallet
you have.  So, it's just pure functions with the machinery to validate the PSBT
you get from your wallet, package it into a nice network message, and send it to
the directory so that your counterparty can receive it and handle all the
errors.  All the main code is in Rust and we have foreign language bindings
through FFI.  Right now, our Flutter bindings are the furthest along because
Bull Bitcoin and Cake needed them.  We've also got some Python bindings, but
we're actively recruiting someone to help with the FFI bindings so that we can
have this correct implementation of Rust delivered across languages.  And I
think for reference, it's kind of attractive to people to understand that this
is also actually how even Signal works.  They've got this core, correct
Rust-type state machine, and then all of their mobile implementations, desktop
implementations are foreign language bindings that bind back into that one
really well-tested code path.

**Mark Erhardt**: That sounds cool.  So, now that the BIP is merged, what are
the next steps?  How are you anticipating that payjoin moves forward?

**Dan Gould**: There are so many!  I wish it was one thing, you know?  So, like
I said, the foreign function interface bindings, the Payjoin Dev Kit, making
that robust, getting the documentation out there, having other people actually
do the integrations on their own is a huge part of what we're doing.  But even
below that, making the library ergonomic so that you can't shoot yourself in the
foot is definitely our number one priority.  Getting the Rust to a point where
you can just have it in your UI, we tell you exactly what to present to your
users, we tell you exactly which tick boxes to give them, is what we're rolling
out in our next release.  So, if you use the Bull Bitcoin or the Cake Wallet
implementations, you might see that they're a little limited and you're not
entirely sure what's happening under the hood.  And we want to expose a little
bit more of that status to the end user wallets.

Then, once we have those two things, once we have the correct state machine that
exposes the status, once we have the foreign language interface, then it really
comes to the hard work of integrations, where we are working with wallets and
service providers and institutions to get this into their hands and make sure
everything works for them with support.

**Mark Erhardt**: I just had a random thought.  So, payjoin is specifically
aimed at two parties collaborating, I believe, a sender and a receiver.  Would
it be thinkable that multiple parties build a transaction using payjoin?

**Dan Gould**: It would.  There's actually a hidden feature in Payjoin Dev Kit
that lets you do this with multiple senders right now to one receiver.  So, if
you had, like, four different senders, the receiver can wait until it gets a
number of them and then respond to all of them for signatures.  This requires
more communication, it's not just one round of communication.  We intend to --
when I say 'we', I'm talking about all of us working on Payjoin Dev Kit, we've
got a great team -- we intend to keep this asynchronous so that it can be
robust.  But I think in the future, you might be able to think of this as sort
of a pseudo, like a pre-mempool of its own, where you have your PSBT, your
transaction intent that you want to communicate with everyone else who's willing
to make a batch.  And you can get benefits from that, which is maybe someone's
willing to pay for a little bit of privacy, maybe you're going to get a better
feerate from delaying and batching with a whole bunch of people.  So, your
effective fee is less for the same output.

This is on the horizon.  We do need help with research to this end.  We're
really focusing on what we just merged after two years, getting this into
wallets.  But I think the future does hold a special place for multiparty
payjoin.

**Mark Erhardt**: Cool, that sounds exciting.  Are you then worried about people
talking about limiting the size of transactions?  We discussed this earlier, I
don't know if you had joined already.

**Dan Gould**: It depends to what extent, right?  I don't know the orders of
magnitude.  Maybe I wasn't paying attention.

**Mark Erhardt**: Sorry, this is a little out of the leftfield, but we were
discussing earlier about a proposal to reduce the transaction size limit to the
current standard size limit.  Vojtěch was talking about his proposal in that
regard.  So, currently the proposal says the maximum standard transaction size
would become a consensus limit, so 100 kvB, which of course is a lot bigger than
the current 8 kB that you were talking about.

**Dan Gould**: Yeah, I think you can still get significant improvements when it
comes to batching at the size of 100 kvB.  But yeah, I don't know how popular
such a proposal would be in the first place.  So, need I even worry about it?
I'm not sure.

**Mark Erhardt**: All right.  I think we've covered both the asynchronous
payjoin proposal, or payjoin v2, quite extensively.  The BIP is BIP77.  It is
now available in your favorite BIP websites, and of course the BIP's repository
itself.  And so, do you have any other parting words or calls to action?

**Dan Gould**: I want to shout out all the people that have supported the
project, both financially and with development effort.  They're many.  And I
think if you're interested in contributing, then we definitely need some help
with FFI and we need some help with research.  Get in touch at payjoin.org,
you'll find our contact information.

**Mark Erhardt**: Thank you very much for sticking around so long and for this
comprehensive overview of BIP77.  All right, I think that wraps our newsletter
today.  I would like to thank my co-host, Mike, and all of our guests, Jose,
Clara, Vojtěch, Robin and Dan.  Thank you again for your time and I'll hear you
next week.

{% include references.md %}
