---
title: 'Bitcoin Optech Newsletter #359 Recap Podcast'
permalink: /en/podcast/2025/06/24/
reference: /en/newsletters/2025/06/20/
name: 2025-06-24-recap
slug: 2025-06-24-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Bryan Bishop, Robin Linus,
and Rene Pickhardt to discuss [Newsletter #359]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-5-24/402749274-44100-2-f07cb660491b5.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome to Bitcoin Optech Recap #359.  Today, we're going to
be talking about restricting access to the Bitcoin Core project discussion, we
have garbled circuits in BitVM3, an update on a Lightning channel balancing
research, and we have four ecosystem software updates that we're going to get
into.  Murch and I are joined this week by three special guests.  Brian, do you
want to introduce yourself?

**Bryan Bishop**: Yeah, I'm Bryan Bishop, Bitcoin Core Contributor, background
programming, started the Bank, done startups, write code, build products.

**Mike Schmidt**: Robin?

**Robin Linus**: Hi, I'm Robin Linus, I'm the creator of BitVM.  I work at
ZeroSync, and I'm doing a PhD on Bitcoin at Stanford, and I like to say I'm the
Bitcoin researcher at Stanford.

**Mike Schmidt**: René?

**René Pickhardt**: Yeah, I'm an LN researcher and thinking a lot about LN
reliability and liquidity management.

_Proposal to restrict access to Bitcoin Core Project discussion_

**Mike Schmidt**: Great.  Thank you three for joining Murch and I this week.
We're going to jump in and just go sequentially, starting with the News section.
We have three items.  First one, "Proposal to restrict access to Bitcoin Core
Project discussion".  Bitcoin Core development is currently done in public on
GitHub, which is great for transparency, but also means that there can be noise,
brigading, and potentially social pressure on contributors to that project.
Bryan, you recently posted to the Bitcoin-Dev Mailing List about an idea to move
development to a private, membership-based collaboration space while keeping the
code open.  Bryan, what do you see as the core problem you're solving, pun
intended, and why make this case now?

**Bryan Bishop**: Well, so the core idea here, yes, pun intended indeed, is that
there needs to be a closed space exclusively reserved for software development
purposes.  And anyone on the internet can currently create their own private
communities or closed spaces, and there is no ability for anyone

anywhere to prohibit this or stop people from privately communicating with each
other.  And the observation here though is that there is quite a spectrum from
totally closed spaces to completely open spaces.  On one extreme end, a
completely closed private space is one that no one is able to read and no one is
able to access or use; and on the other extreme is a completely open space where
everyone can read it and everyone can write to it.

Right now, I would say the Bitcoin Core Project is a little bit closer to the
side of the spectrum where everyone can read it and everyone can write to it, at
least for comments, issues, code review and PRs on the GitHub project page.  And
this has been a persistent issue for Bitcoin Core developers because of having
this ability for public right without moderation, basically means that one of
the primary spaces where Bitcoin Core developers go to collaborate with each
other is also public right with no moderation and no delay.  And so, what if,
and bear with me, what if we chose to try experiments where we did not do that?
What if, for example, people could register, and then after registering, there
is a delay before their first comment can be posted?  Or what if they register
and their profile is approved by one or more other existing people, or
something, in the project and things like that.  And this is mainly around the
ability to write comments, issues, or other posting capabilities.

This is not to say that we should eliminate, for example, open-source code, or
disallow people from reviewing code, or even reading comments or issues that are
posted.  It's solely that we can choose to make a closed space that has
different rules other than what the defaults that GitHub provides.

**Mike Schmidt**: And the timing of this is very close to one of the recent
kerfuffles on GitHub around OP_RETURN, the OP_RETURN PR specifically, although
there's obviously been a bunch of discussions outside of the GitHub repository,
but a lot of those then spilled into the GitHub PR itself, being somewhat
distracting for the contributors.  I assume that this is sort of your solution
or reaction to that?

**Bryan Bishop**: Well, a little bit.  I guess I should have listened to the
Optech Recap podcast more often, because I was not aware that this was such a
popular issue outside of GitHub.  From my perspective, I was following PRs and
issues and discussions in the Bitcoin development community and there was a
bunch of irrelevant things posted on a PR.  And I was like, "Well, that's weird.
We should just probably, instead of deleting comments after they're posted, we
should probably just invite people to make comments instead".  And when I posted
my proposal, I'm starting to get the sense that there's something I was unaware
of, possibly through Twitter, or X, that I didn't understand the full extent of.
And that's still a little bit confusing to me.

The responses to my post have been quite bifurcated.  Developers read it and go,
"Oh, that's interesting.  And yeah, maybe that's useful.  Or maybe there's some
sort of incremental thing we could do.  Or it might not be totally necessary",
which is interesting feedback.  And then, on the other hand, on x.com, I got
responses such as, "This is the most terrible idea I've ever heard of, and
everyone should be able to post to the developers' areas no matter what", which
was also interesting feedback, which if you do believe that, if that is
something you very strongly believe, that everyone should be able to write
comments everywhere that developers do their work, if someone really believes
that, I would suggest formalizing that, such as write a document, set of
principles or something.  I don't happen to believe it, but I'm sure some people
do and according to the x.com reactions, a few people might.

**Mike Schmidt**: Well, we have a Bitcoin Core contributor here on the call and
I wanted to see, Murch, if you had any feedback on the idea or any of the points
we've touched on so far.

**Mark Erhardt**: Well, I'm fascinated that you say you weren't aware of how
popular this topic was outside of GitHub, because that was something that was
occupying a lot of my time in the last month.

**Bryan Bishop**: I work very hard to insulate myself from certain social media
effects, and I'm not always successful.

**Mark Erhardt**: That is really funny.  Because it was such an overwhelming
drain on my attention in the past month that I congratulate you on your success
of insulating yourself.  Either way, I think there's multiple things here.  One
is a lot of people seem to have a very strong feeling about how much of Bitcoin
Core ownership they should have.  And on the one hand, I think our project is
very successful, in the sense that if people want to share in the process, that
is a good thing.  I think that a lot of developers work on building the project
that they are interested in having, and this happens to also be something a lot
of other people are interested in, but there's no direct ownership of the
community on the time of the contributors.  So, there's a very odd dynamic in
that sense.

I think it would sometimes be nice to be able to have a delay, or like a
mitigation of the worst brigading.  Nobody really benefits when 200 new comments
are added to a PR in a couple of days and most of them are repetitive and do not
add new information.  But occasionally, we do get outside people that show up
for the first time and then end up sticking around, or have just some valuable
insight on a singular topic.  So fully insulating it, I think, probably takes a
bit away from the interactive nature of how the project's set up right now.  But
yeah, I think the main problem was just how popular the topic was in general,
even outside of GitHub.  The GitHub interaction was only sort of the tip of the
iceberg.  I'm not sure if that would actually help much at all.  It is still a
conversation that needs to be had with the community.  So, if the community
conversation happens outside anyway and someone just takes a screenshot of a PR
and then gets hundreds of people riled up and talking about this, it helps if
someone, say, takes the role of a developer advocate, or just one of the
developers feels like they need to chime in and explain.

So, yes, it would definitely help the people that don't want to have those
conversations to help insulate them, but it's also a signal that we need to talk
more to each other when this sort of brigading happens.  So, I don't, I don't
know whether the effort of instituting changes to our workflow like that would
be worth it because it's, well, every half year or so, one of the PR blows up
like that.  So, I don't know, that's from the top of my head.

**Mike Schmidt**: Bryan, we have the mailing list where people can opine and
discuss things that is in particular pieces of code or PR.  Where would you
imagine, or what are some ideas of where you'd imagine that the more external to
Bitcoin Core contributor people would take their feedback and or grievances on a
particular PR?  What venue would that occur in, in your mind?

**Bryan Bishop**: It's a great question.  And what's really funny is, ever since
becoming one of the BIP editors, or probably before as well, there's this very
interesting tension where from a BIP editor perspective and BIPs repository
perspective, often the thing to say is, "Well, go to the mailing list with that
idea".  And as a mailing list moderator, I have to say, "Well, don't post that
on the mailing list.  This is a bad email, this is dumb, or this is a noise", or
something, "go post it somewhere else".  And I don't say, "Well, go post it on
BIPs", but essentially the message is, "Go post it somewhere else".  And so, I
would say the general solution though is that thankfully, this is the internet,
the World Wide Web, and anyone can create new communities or forums, or anything
they want, to aggregate people to talk about things that they want to talk
about.  I don't think it's necessarily the role of the Bitcoin Core Project to
necessarily host that platform for hosting those discussions.

Now, I would also add that, for example, both BIPs and the mailing list are not
Bitcoin-Core-hosted either, certainly adjacent.  There are certainly related
people involved and are participating in both.  But in general, the concept of
free speech in our different countries does not require people to host the
speech of others.  And thankfully, there are ways of creating other platforms to
post whatever you want.  And so, one question, one way to interpret your
question, Mike, is, am I interested in hosting those discussions?  Me
personally, not really.  Am I interested in reading them sometimes?  Yeah, I
suppose so.  I don't know though.  It's not necessarily the Bitcoin-Development
mailing list, right, because the mailing list is supposed to be about Bitcoin
development.

**Mike Schmidt**: Any two cents on that, Murch?  I know obviously, Twitter was a
big part of the most recent discussion around OP_RETURN.  It's very hard to
collate those ideas that are in various Twitter threads into something that you
can point at and discuss.  Stacker News was one that had some discussion as well
that I think, Murch, you were participating in.  I don't know, did any of those
feel like they were productive places for the community to opine?

**Mark Erhardt**: I thought that the Stacker News thread answered a lot of
questions, but maybe it was too one-sided.  I don't think that it helped really
inform.  One of the biggest things that hasn't really been addressed at all is
that one side basically has produced some 30 or so podcasts on this topic, and I
don't think that there was maybe one from the other side, or maybe a couple.
But there was just a huge imbalance in how invested people felt on this topic.
And essentially, the area of discussion in the podcast sphere self-replicated,
and a lot of the talking points that I find completely absurd got propagated
like mad, and I guess people listen to podcasts a lot more than they actually go
to GitHub or read the mailing list or Stacker News.  So, in the end, I still
feel that most of the people just never really even engage with the
counterarguments and are very upset.

But yeah, I agree that you don't have to host a conversation if you don't want
to.  It is certainly not the right place for hundreds of people to come in and
shout at each other in our workplace.  That just is not productive.  And I know
numerous Bitcoin Core contributors just immediately muted the thread and did not
look at it at all.  But yeah, the nice thing about it is it's sort of central.
It's at least a place where people would see a response potentially, because
with the wholly distributed conversation in podcasts that usually only have one
guest on that talks about one side of the issue, it just doesn't really lead to
an informed community.  So, I don't know.  It's a terrible place, but maybe not
the worst outcome out of all, because at least stuff gets seen there.  I don't
know, I rambled, sorry.

**Mike Schmidt**: I did pull out what I thought was some interesting comments
from TheCharlatan on Bryan's post, and I'll quote a couple of those here,
because I just thought they were interesting.  The Charlatan said, "The
perceived brigading did not impede the project from making progress on the
issue.  It led to a rare moment of alignment in the form of a common statement,
brought more eyes to reviewing the PR, and finally led to a resolution of the
question.  The discussion was also focused on the two PRs and did not impede
progress on the other 300-plus others".  And he goes on to say, "It also shows
that our organization is still the same scrappy, loose collective of individuals
with individual approaches and opinions capable of tolerating dissent.  If I
were to choose a client to run my money on, these are all soft qualities I'd
look out for".  No need to respond to that, I just feel like I wanted to add
that in.  Bryan, anything that you'd say in closing out this discussion?

**Bryan Bishop**: Well, one observation I'll make, and first of all, I don't
think I can disagree with the quotes you just read.  Yes, it is true that the
project continues, and everything.  That's great.  It seems like there's a
number of different issues that are either being confused or coming to the
surface here, just between questions about how Bitcoin Core developers work
together, the role of developers interfacing with the public, and then the
public's role in what they want to do or hear about, or what happens when people
are upset, or they have an opinion that they want to express, or what happens if
there's misinformation?  Who's responsible for that, or who is responsible for
correcting it, or responding to the outrage?

I don't have any answers to any of these issues or questions, but they might be
separate issues and separate topics.  And by more carefully structuring our
inquiries into these matters, we might be able to at least come to certain
conclusions.  For example, I think from my email, one very interesting idea that
came up multiple times was the idea of, "Well, Bryan, your proposal was very
strong.  What if we try something smaller?"  It would be nice to be able to
experiment with different ideas more quickly and trying different strategies,
and if they don't work, we can cancel it or we can undo it, or something.  For
example, moderating and delaying new posts, or trying a different experiment,
such as all new posts by new members that have never posted before get delayed
by one hour, what about two hours, what about one day, or something?  And if we
can just try different experiments, and whether we try them on the Bitcoin Core
GitHub repository or not, whether they're tried in different areas or different
places on the internet, I think that ability to experiment and see whether that
benefits us and benefits the work that we're trying to do is a good outcome.

**Mark Erhardt**: Yes.  But one of the points that really got people upset was
this sort of experimentation.  There were some new approaches to moderation
tried in this PR specifically.  A bunch of comments got hidden for repeating
already discussed points or for personal attacks, and a few people even got
banned for personal attacks.  And they, of course, then turned around and said,
"See, they're censoring my speech".  And as you might think of bitcoiners, that
got them really going.  And so, there is just several levels of delicate
communication here, where people just are looking for points to score.  And for
example, delaying comments by a day, I think it might be cleaner to just prevent
people from posting than to delay their posts or hide them or delete them,
because not being able to post might be less aggravating than posting but then
not being visible or removed.  So, I don't know.  I'd certainly love for the
overall situation to improve, but I just find it very hard to know what the
actual solution is here.

**Bryan Bishop**: Yeah, I wish I had answers for you.

**Mike Schmidt**: Well, Bryan, thanks for coming on and talking about some of
these ideas and experiments, and representing your mailing-list post.  We
appreciate your time.  We understand if you need to drop.

**Bryan Bishop**: Yeah, thanks for having me.

_Improvements to BitVM-style contracts_

**Mike Schmidt**: Next news item, "Improvements to BitVM-style contracts".
Robin, you posted to Delving Bitcoin about BitVM3, a new BitVM approach using
something called "Garbled Circuits".  This approach makes SNARK verification on
Bitcoin over 1,000 times more efficient than BitVM2, but maybe you can walk us
through what BitVM3 is, and how it improves on the most recent prior design in
BitVM2.

**Robin Linus**: Sure.  First, maybe a quick recap of how BitVM2 works.  BitVM2
is doing optimistic verification of SNARKs.  SNARK proofs are these magical
proof systems that essentially allow us to compress infinite amounts of
computation into a very succinct proof, and they are super-great for second
layers, for bridging Bitcoin to rollups to sidechains, and essentially
trust-minimized bridges.  And, yeah, these trust-minimized bridges, they are
essentially enabled by SNARK verifiers, by Bitcoin being able of verifying a
SNARK.  Ideally, we would do that in Bitcoin Script, but unfortunately, that's
not possible in Bitcoin Script today, so we are doing this optimistic
verification.  In BitVM2, that's essentially using optimistic computation.

So, you have these two roles.  You have like an operator who operates the
bridge, and then you have challengers that can challenge the actions of the
operator.  And if the operator wants to do a peg-out, he has to commit to a
SNARK proof that proves the validity of his peg-out.  And then, every challenger
can read this proof from the chain and verify it offchain, and if it's
incorrect, they can challenge the operator.  And in Bitvm2, the problem is this
so-called assert transaction that the operator has to do is roughly 4 MB, and
also the disprove transaction that the challenger has to do is also 4 MB.  So,
it's quite a large transaction.  And even worse is that the operator has to lock
collateral to essentially make a bet that they bet nobody can disprove them. And
if you can disprove them, then the operator pays you to disprove them.  And this
collateral is quite large, it's on the order of $10,000 to $15,000, and that
makes BitVM2 bridges very clunky and expensive.

Now, the idea of garbled circuits is to minimize these transactions by a factor
of like 10,000 or something; both the assert transaction and the disprove
transactions become way smaller.  The assert transaction is reduced from 4 MB to
roughly 50 kB, and the disprove transaction is reduced from 4 MB down to roughly
200 bytes.  So, that's a huge game changer, in particular because the collateral
is for the disprove transaction, and now it's just 200 bytes instead of 4 MB.
So, you don't need any collateral at all anymore.  So, yeah, that makes it
orders of magnitude more cheaper.

**Mike Schmidt**: Robin, why don't you need the collateral anymore?  Isn't there
still some funds at stake if someone is not telling the truth?

**Robin Linus**: No, there should be some small collateral that is painful for
the operator to lose, but there is no collateral required to execute this huge
transaction anymore..

**Mike Schmidt**: Got it.

**Mark Erhardt**: Previously, they'd have to buy a whole block or even several
blocks, and at certain feerates, that would be very expensive for 200 bytes.
That's much cheaper.  So, just the cost to create the disprove transaction is
much smaller.  But you do want some sort of collateral in the sense that
punishment for making false claims is executed, right, like the penalty
transaction on LN?

**Robin Linus**: Yeah, exactly.  So, there is some disincentive to lie, but it
can be just orders of magnitude cheaper than buying a whole block of block
space.  Yeah, and how does that work?  Well, it works with some very magical
tool called garbled circuits.  And first of all, I have to give credits to
Jeremy Rubin and also to Liam Eagan, and I think also Sergio Lerner has been
working on that.  Multiple teams independently of each other have been figuring
out this solution, and now the entire BitVM Alliance has pivoted to this new
approach, and we are exploring in parallel multiple different approaches of how
to make it as practical as possible.  But it was definitely Jeremy Rubin who
kind of popularized it.  He garbled-circuit-pilled me, and then I was just
mind-blown.  And then I garbled-circuit-pilled everyone else.  And yeah, how
does that work?

Well, first of all, we can picture that garbled circuit as just like a black
box, and that black box allows us to verify a SNARK, and this black box is
communicated offchain.  So, the operator sets up this black box and then sends
it, or publishes it such that every challenger can download it.  And then during
peg-out, the operator has to assert again to a proof.  So, they publish a proof
in the chain, and then everybody can read that proof and feed it into the black
box, into the garbled circuit.  And now, the interesting thing is they can
validate that proof in the garbled circuit and they will get a result, either
true or false.  The proof is either true or false, it's correct or incorrect.
And if it's incorrect, they learn a secret, and they learn that secret only if
the proof was incorrect.  So, that secret essentially acts as a fraud proof.

If you know that secret, that means the operator published an incorrect proof,
and this makes it extremely cheap to disprove the operator, because you just
need to publish that secret onchain and then you have disproven the operator.
You don't have to execute the entire SNARK, or you don't have to verify the
entire SNARK onchain anymore.  You just feed that SNARK into that black box and
if the SNARK is incorrect, then you learn that secret which represents false,
and that is sufficient to disprove or to falsify any incorrect SNARK proof.
That is essentially the magic how it works.  And since all the other computation
is now offchain, it becomes extremely efficient onchain.  Onchain, we just need
to commit to the proof, or the operator has to commit to the proof and
essentially sign it.  They have to sign every bit of it, so it's still like 50
kB or something, but that's it, we don't need anything else.

This makes everything way more efficient but there are still some challenges to
it.  The big problem is what's the size of the garbled circuit?  Garbled
circuits have been invented, I think, in 1997 or something, so they're already
quite old.  And there is that standard scheme called Yao style circuits after
the guy, Yao, who invented it.  And if you apply just that simple scheme, then
you end up with a garbled circuit that is roughly 500 GB, or something.  But
this 500 GB is not enough.  You also have to prove that this circuit is actually
correct, because I give you 500 GB of something, but you have no idea what it
is.  You have to be sure that this is actually representing a SNARK verifier and
that if I give you a SNARK, then you can actually verify the SNARK with that
garbled circuit.  So, you essentially need another SNARK to verify that this
garbled circuit is actually representing the circuit that I claim.  And, yeah,
proving 500 GB of garbling tables is extremely expensive.  And usually, in the
SNARK/STARK world, we can just outsource computation.  We can just rent huge GPU
clusters, and most of these big proving companies, like RISC Zero and SP1, they
have optimized all of that, and it's essentially their business model to sell a
compute to people.

However, here we have the problem that we are computing on private data.  If I
give that garbled circuit, including that secret, to a proving service, then I
have to tell them my secret, essentially making them a trusted party.  So, we
don't want that.  And in particular, we don't want all operators to use the same
proving service because then it would become a single source of failure; all
operators would now have to trust that one proving service to not leak their
secret.  So, we would like proving to be efficient enough that every operator
can just do it on their own computer.  And this is where the entire complexity
starts.  How do we make these garbled circuits efficient enough such that you
can easily prove them as an operator who doesn't want to invest more than, I
don't know, $2,000 or $5,000 or something?  And this is essentially the research
problem that everybody's working on right now.  And there are different ways to
do that.

A very interesting result that we had was from Citrea, from Hakan, the Head of
Research at Citrea.  He figured out a way to change the transaction graph such
that we can have a one-time setup.  So, we just need a single setup for
arbitrary many peg-ins.  That's already changed quite a lot, because even if the
setup is quite expensive and takes let's say a month or even two months, it
would be kind of viable because we have to do it only once and then we can use
it forever for arbitrary many peg-ins, and that would be kind of okay-ish.  So,
that would be a solution, even of course a painful solution, but at least it
would be practical to some degree.  And, yeah, then there are all kinds of other
solutions or other approaches that people are exploring.

The Bitvm3 solution that I published is based on RSA, and it has a couple of
cool properties.  First of all, you can essentially send the circuit in plain
text, and then the challengers can just verify it in plain text.  And then, you
can re-blind it very cheaply such that you only have to prove that the
re-blinding was correct, and they still know that the underlying structure is
the same that they verified in plain text.  And this kind of bypasses the most
expensive part, namely the proving.  You don't have to prove the correctness of
the circuit anymore.  You don't need a zero-knowledge proof anymore to prove the
circuit, you just give the circuit in plain text and they convince themselves
that that circuit is actually correct.  And in the naive solution, that's
roughly 5 TB.  The good thing is that this 5 TB would be for arbitrary many
re-blinding, so it's just a one-time cost, but it's still 5 TB, and that's a lot
of data that every operator would have to send around.  Also, every challenger
would have to store these 5 TB, and then it becomes quite expensive.

There's a solution for that.  I'm working on a solution for that, or I think I
found a solution for that, I guess, is the most correct way to put it.  And
that's essentially about reusing subcircuits.  You have a subcircuit in
particular for feed multiplications, because a SNARK verifier is essentially
roughly 30,000 feed multiplications. So, if you would have a subcircuit for feed
multiplication, you can just reuse it 30,000 times and that would reduce the
circuit size by roughly a factor of 30,000.  And that is indeed possible with
that garbled circuit approach.  I think I found a solution for that, or I did
find a solution for it, but I don't have a security proof yet, so it might be
broken.  I'm not entirely sure if that optimization works, so I don't want to
promise too much, but it seems quite promising.  And so far, nobody was able to
break it.  But the only problem might be that I haven't shown it to people who
are smart enough to break it.  So, I don't want to promise too much, but it's
definitely a very exciting area of research, or direction of research.  And this
would bring the entire circuit size down to 2 GB, and that would essentially
solve the communication problem and the proving problem at the same time.

Also, just to mention the other directions that other people are working on,
Jeremy Rubin came up with an idea he calls delbrag, 'garbled' spelled backwards,
'delbrag', That is essentially an optimistic way of verification.  You just
claim that your circuit is correct, but you also commit to a taproot, which
essentially encodes every gate of the circuit.  And if any of the gates is
incorrect, then you can disprove them onchain.  However, that is reintroducing
the problem of the collateral, because you have to execute a transaction that is
roughly on the size of 100 kB, or something, to make this disprove.  So, you
have to put up collateral again to execute a 100-kB transaction, or to be able
to execute a 100-kB transaction if somebody is lying.  So, that's not optimal.

Then Liam Eagan, he is working on a thing called designated verifier.  Usually,
a SNARK is such that I publish a SNARK and then everybody can verify it
independently.  He's using a designated verifier, where just verification is
essentially permission; you have a permission set of verifiers who can verify
the SNARK.  That is of course a drawback, but you gain a lot from that because
the circuit becomes much simpler.  It's a 1,000-times or 10,000-times simpler
circuit when you have these designated verifiers.  And the other solution is cut
and choose, which is essentially I don't send you one circuit, I send you like
50 circuits, and then you just open some of them, or you ask me to open some of
them, and then you just keep the remaining ones.  And that is essentially the
most simple way.  But of course, it comes at the expense of more communication
complexity, but the verification becomes quite cheap.  And, yeah, if you're
willing to just send a lot of data around, then this is the most simple approach
and it's relying on the least complex cryptography.

**Mike Schmidt**: Murch, I saw you were going to say something there.

**Mark Erhardt**: Well, I tried.  But I was wondering.  So, SNARKs, I think the
first time I heard more about SNARKs was with Zcash and famously, their setup
required a trusted setup and it required numerous parties to promise that at
least one of them actually destroyed their secret data that they contributed.
Do I understand right that this SNARK setup would not have that sort of trusted
setup, but rather it's basically transparent and everybody just verifies that
the circuit is correct.

**Robin Linus**: No.  This is another level of complexity, like what particular
proof system are you using?  And you're right that sometimes SNARKs is used as
the umbrella term, but others use it as SNARKs, and then there are STARKs, and
the 'T' in STARKs are the transparent SNARKs.  They have a transparent setup,
which requires no trusted party.  Yeah, there is that huge trade-off, like
SNARKs are much, much smaller.  Just to give you an order of magnitude, SNARKs
can be as small as 128 bytes can prove arbitrary complex statements, like
constant size.  No matter how complex your statement, it's always 128 bytes, so
just two Bitcoin signatures, which is quite miraculous actually.  And STARKs,
the transparent version, they're different sizes and you can compress them to
multiple degrees, but they are roughly on the order of, even if you compress
them a lot, 50 kB.  So, they're almost 1,000 times larger.

**Mark Erhardt**: So, could you just clarify, for the setup of BitVM3 that you
described now, would that be a trusted setup?  You said that there's the worry
about not revealing the secret to the big computation provider?

**Robin Linus**: Oh, that's two levels here, right?  We have on the one hand the
proof system, and in general we have that question, are we using a proof system
with a trusted setup, or are we using a trustless setup?  And this is in general
the question, like how big is the data that you have to inscribe into the chain
when you want to publish that proof?  And then, there is the question about the
garbled circuit, and the garbled circuit can be completely trustless, so it
doesn't introduce another trusted party.  Of course, you can outsource it to
some proving service, and so on, then you would introduce a trusted party, but
we are working on solutions that they would be completely trustless.  But to use
that trusted version of SNARKs, or these STARKs, you would have to use bigger
assert transactions, and they would become roughly by a factor of 1,000 bigger.
So, that's essentially not possible, because a SNARK is already 50 kB and if you
would increase it by a factor of 1,000 --

**Mark Erhardt**: Yeah, you'd have to buy 50 blocks of data, or something, and
that sounds prohibitive in cost, or depending if you can put it in witness data
and split it up less obviously.  If it all has to be one chunk, it just doesn't
fit.

**Robin Linus**: Maybe you can do some tricks, like these STARKs, they do
multiple queries and you can add some proof of work (PoW) essentially to it.
And if you spend like, I don't know, $50,000 on PoW, then you can do way, way
fewer queries; instead of 50 queries, you can get away with like 7 queries, or
something, and then your proof becomes proportionally smaller.  And then, you
might be able to fit it into a single block.  But yeah, it becomes much more
expensive to generate the proof.

**Mike Schmidt**: Wild.  It sounds like there's still research to be done here.
This is a fairly leading-edge or bleeding-edge sort of research that you and
some of your, I guess, peers in the BitVM space are working towards.  I feel
like I even understood some of what you said today, so I think you did a good
job of explaining it, Robin.  What's the call to action here?  I guess if folks
are using some flavor of BitVM and want to be familiar with the latest, I mean,
your post basically references BitVM3 and Jeremy Rubin's paper, so I guess folks
should be familiar with that.  I assume all of the other participants in the
Alliance are also already all familiar with these discussions as well.  What
else would you have people do?

**Robin Linus**: We have quite an active Telegram channel.  I think it's called
bitVM_chat.  You can join it and people are always happy to geek out about
garbled circuits, BitVM and Bitcoin Script in general.

**Mike Schmidt**: Okay, awesome.  Anything else on your side, Murch?  Alright,
Robin, thanks for joining us yet again.  We really appreciate your time and you
coming on and chatting with us about these.  You can imagine Murch and I trying
to go through this without you.

**Robin Linus**: Thanks again.

_Channel rebalancing research_

**Mike Schmidt**: Our final news item this week is, "Channel rebalancing
research".  René, you recently posted to Delving Bitcoin about your latest
research and associated notebook titled, "A Geometric Approach to Optimal
Channel Rebalancing", and this research builds on some of your earlier work on
payment channel networks, and also explores whether globally-coordinated
liquidity replenishment could improve LN routing success, especially, and you
get into it in your post, if you start with a heavily depleted LN setup.  René,
maybe you can walk us through your optimization approach and what results may
imply for folks operating LN nodes?

**René Pickhardt**: Yeah, sure, of course.  So, as most people will probably
know, for the last year, I have been working on a mathematical model, a
mathematical theory of payment channel networks.  And most of the time, the
results that I've provided were basically limitations showing boundaries of what
is possible on the LN.  This new result is actually a much more positive result,
as it shows what we can actually achieve with these techniques.  For many years,
I think people had the intuitive understanding that routing and liquidity
management are somehow connected problems.  And now, with this mathematical
theory of payment channel networks, we have the tools to actually express these
problems with the same mathematical formulation and just see that there are two
sides of the basically same metal.

The main idea that people have been doing previously is to say, if their
channels deplete, maybe we can do a circular rebalancing.  Not everybody pursues
these ideas.  I have to say some people prefer to play with fees or to play with
control valves of limiting their max_htlc size, but some people are trying to
basically do offchain rebalancing by sending sats on a channel where they have a
lot of liquidity, in a circular fashion through the network to themselves, to a
channel where they don't have enough liquidity.  And this game of circular
rebalancing has this problem that when I rebalance my channels, I might
unbalance some other people's channels, and vice versa, of course.  So, we're
all playing against each other.  What has previously been discussed on this
podcast was that also in routing, the selfish behavior is actually one of the
reasons why the network depletes so heavily.  And while depletion in itself is
not limiting the fact of whether a payment can be conducted between two nodes,
it makes it much harder for sending nodes to find the route.  So, as a node
operator, what you could do is you could try to undeplete those channels, which
improves the reliability of those payments that are actually possible and
feasible on the network.

So, what this framework does is it looks at this channel replenishment problem,
but not in the manner of circular rebalancing, but it looks at what happens if
all the nodes would coordinate in order to find that liquidity state that is
most beneficial for all the wishes of all the wishes of all the node operators.
And the wishes can be announced by the node operators themselves.  So, in this
notebook, I just used the same wish from every operator which was, "Please do a
50-50 balance split on all channels", but that does not have to be the case; I,
as a node operator, could observe my channels and be like, "Hey, on this
channel, I always want full liquidity; on that channel, I really don't want
liquidity".  And all those node operators could announce their wishes, and then
you use the math to basically compute the liquidity state that is geometrically
closest to the wish that is announced by all of the node operators.

What I could show is that there are substantial improvements in liquidity if
you, for example, take this 50-50 balance split wish, and it is actually
possible to achieve states that are very close to the desired state for
everyone.

**Mike Schmidt**: Is the benefit here for folks sending?  You're talking about
node operators sort of expressing a preference and then getting together and
reorganizing liquidity accordingly.  I assume that's for the benefit of routing
payments, or how do you decide the success?  You have this 50-50 split in
liquidity, but are node operators also wanting to capture fees, for example, or
how do you factor in the bigger picture node operator wishes?

**René Pickhardt**: The main problem that we see on the LN is if a sending node
wants to send out a payment, they have to make several attempts to actually
deliver the payment.  And one of the main reasons is that in their path
selection, they occasionally select channels that are depleted.  And when they
do so, what this means is that the node operators on this path cannot earn the
fees, even though they may have the liquidity, because downstream, one node
operator doesn't have the necessary liquidity to complete the payment.  And fees
on the LN are only paid if the payment successfully is being routed.  So, if
node operators increase the reliability of their node, what this means is that
they actually earn the fees when the payment requests are being made through
them, so this is one advantage to the node operators.

Another advantage is if you look at channel depletion, channel depletion usually
occurs because there's high demand in those channels.  When you do reverse
logistics and a channel replenishment protocol, you basically reverse the
natural flow through the network.  As we have discussed last time in the
podcast, usually within cycles, there is a natural rotation, which means the
liquidity is always towards one end of those channels in a cycle.  So, for those
node operators, economically, it may make sense to undeplete those channels,
because there's already a lot of demand in the other direction.  But since many
channels are part of many different circles, it's sometimes not so clear how to
do that.  And this is where my research basically starts to ask the question.
So, instead of identifying three cycles where I'm in and identifying the
rotational flow in those cycles, I can just observe my channel and be like,
"Hey, usually on this channel, I like that, and other people can care for their
own channels".

So, I want to reiterate on the fact that while in the research, because it's a
simulation, I use this 50-50 split; it does not have to be that 50-50 split.  It
could actually be depletion in the exact opposite direction, because you see,
"Hey, I always want full liquidity on that channel", which would mean if
occasionally a payment would go in the other direction, well, yes, then the
channel was depleted.  But usually, a node operator would only want that
liquidity on that side if the channel has a certain direction in which routing
requests are coming in.

**Mark Erhardt**: So, it sounds like you would want to find a route where every
party wants the funds to move in one direction, and then everybody would improve
their local liquidity, and that would make every party participating in the
routing happy.  But of course, channel balances are private by design and it's
an important property of the LN to keep the channel balances at least fuzzy and
maybe not transparent at all times.  So, how would people know where to find the
liquidity for these multi-benefit rebalancings?

**René Pickhardt**: Yes, so I mean that is one of the problems.  I mean there
are several issues with this approach that I think I also mentioned in the blog
article.  The nodes that coordinate on this, the easiest way for them to do this
was if they would share their liquidity information, in particular to also solve
the math problem of how to optimally distribute the liquidity among the nodes.
You could have a lightning service provider that manages liquidity for many
nodes and could be a central coordinator.  That wouldn't be a part of a protocol
solution, but nobody would prove it.  It's similar to the discussion that we had
about discussions on Bitcoin Core, whether they should be privatized or not.  I
mean, you cannot forbid people to create services like this.  So, you could have
a central coordinator who gets the liquidity information, solves the problem for
the nodes, and basically tells the nodes where to rebalance with whom.  This
network of nodes would be a highly reliable subnetwork of the LN.

**Mark Erhardt**: Could it be possible, usually when you make payments, you
indicate you want this to happen right now, you offer fees, and so forth, that
you sort of have a, "Please only participate in this payment if it's to your
benefit", type of payment offer.  And then, you could just shoot out proposed
cycle rebalancing, where every party does not take fees and they only
participate if it's to their benefit.  And since you're not really time-pressed
to get it done and you're just looking around, "Hey, would that be a more
private variant?"  Well, it is sort of like probing, but it would just be cycles
to yourself where you ask, "Hey, is this to your benefit too?" and then,
"Participate, please".

**René Pickhardt**: I mean, yes, you could think of something like this to
improve privacy.  I mean, the main issue and problem here, if people decide that
they are interested in a solution like this, is how to make this as a
distributed protocol.  A solution like yours would certainly be interesting.
And one of the benefits of this particular research is that with this research,
we know the gold standard and how good the best solution is, so that if we would
try an approach like yours, Murch, we could test how close to the optimal
solution is your approach, right?  So, if for example, I mean I'm just making up
numbers, your approach would be, let's say 99% accurate.  Well, I mean that is a
really, really good solution, right?  And we could know this because we would
know the optimal solution, at least in a simulation.

But I have to make one thing clear here.  The idea of this rebalancing is not to
do it in single cycles.  So, if I am a node, what I could do is I could say,
"Hey, I'm sending out 100,000 satoshis on three channels.  I'm receiving 300,000
satoshis on another channel.  I'm sending out another 200,000 satoshis on the
next channel".  The only thing that has to happen is that all those numbers add
up to zero; I have to receive as many sats as I'm sending out.  But the way how
I'm doing this is not in single cycles anymore.  So, even the solution that I
provide, dissecting it into cycles is non-trivial.

**Mark Erhardt**: Right, because there's of course a huge degree of complexity
here, because every node has many different channels and you basically want to
cherry-pick out of many, many different channels which ones should participate,
because they're all moving in the same direction.  So, you do need a good
overview of the local network.  Maybe there's a smart, cryptographic,
zero-knowledge sort of approach where people can dump their information and it
drops off routes without telling anyone the actual balances.  But for the time
being, it sounds like the theoretic optimum would require full transparency.

**René Pickhardt**: Yes and no.  I mean, one solution that is somewhat in the
middle is that you could basically announce, "These are my 100 channels, and on
those 50 channels, I want that many sats of liquidity inbound; and on those
channels, I want that many sats outbound, and this is my wish for rebalancing".
This doesn't tell you, "Oh, yeah, the channel is empty and this is everything".
I mean, of course, if you want the full liquidity, the full capacity, then it
tells you the channel is empty and you want to have it full again.  But you
could basically choose those numbers.  I mean you're not guaranteed that you get
those numbers.  In this optimal solution, it could even be that for a single
node on a single channel, the situation becomes exactly against their wish,
because it's overall still the closest solution to the global problem.  That
being said, it's highly unlikely because the wishes of the operators should
somehow naturally go towards each other.  And even if that happens locally, I
mean as soon as a channel is depleted, you would re-trigger the replenishment
thing, and then you would get some liquidity back.

**Mark Erhardt**: There has been a lot of talk in the past about upfront fees.
I was wondering, you said currently channels only get paid when the payment goes
through and that's a problem.  With upfront fees, there will be a very small,
but a small payment to even participate just in an attempt.  Do you think that
that would help with the situation, because (a) there's more financial incentive
to pick the best route first; and (b) it provides a little bit of money in a
channel in the direction that you want more liquidity in the future?

**René Pickhardt**: Yeah, so I don't have a good answer to this, to be frank.
If you look at how I have conducted my research in the past, I have studied the
routing problem quite a bit and now the liquidity management problem.  And one
particular area that I haven't studied well yet is the fee problem, like
generally how to choose fees, what is the dynamics there, how is everything
happening.  I know that there's a lot of game theory involved there and it is my
understanding that upfront fees would certainly change certain things and
incentives.  For me it's not even clear that the upfront fees stay tiny.  I
mean, I do understand that currently the idea of the upfront fee is to be tiny,
but that doesn't have to be the case.  You could make it larger.  I mean, as
soon as you have it in the protocol, nobody forbids you to charge a high upfront
fee and make the other fee tiny.  So, yeah, I don't know how upfront fees would
really change the dynamics here.

Of course, if upfront fees are being charged, I would assume that users would
expect routing notes to have the liquidity.  I mean, if I pay you upfront, I
would expect you to deliver my payment.  So, given that we go in the direction
of upfront fees, if I was just the user, I'd be like, "You'd better provide
reliability".

**Mark Erhardt**: Sure, but that doesn't make any promises about the
further-down-the-route hops.  I mean, I might take the upfront payment and have
the liquidity, but the next hop might not.

**René Pickhardt**: They took the fee and should have the liquidity, right?

**Mark Erhardt**: Sure, but I still pay all the hops before the hop that doesn't
have liquidity.

**René Pickhardt**: True, yeah.  So, what I'm basically saying is, I don't even
know if users would adopt to an upfront-fee setting if the reliability in the
network is not much higher, because it's a gamble.  I mean, if every hop is a
50-50 chance, because almost half of the channels are being depleted, then it's
really hard to make the case for upfront fees, unless you do a probabilistic
setting where you say, "Yeah, I expect to pay that many upfront fees for
nothing".

**Mark Erhardt**: Yeah, I guess.

**René Pickhardt**: But as I said, I haven't studied it properly, right, so I
mean I shouldn't speculate around this.

**Mark Erhardt**: I also need to correct myself.  Upfront fees would not move
fees in the channel that doesn't have sufficient funds.  They would move fees in
the channel before that.  So, I was incorrect in my prior statement.  So, back
to your actual main research.  You say that it is computationally very expensive
to find these rebalancing multi-benefit situations and it requires a lot of
data.  So, what is your current situation?  I think you're saying you'd like
input on whether this is worth pursuing?

**René Pickhardt**: Yes.  So, I think the main question that I'm putting out to
the community is, we know that we have reliability issues on the LN, and we do
have some ways of how to mitigate them.  Roughly a month ago, I put out a post
to Delving Bitcoin where I showed all the various approaches that exist.  Some
of them include severe protocol changes; some of them are more applications on
the LN; some of them are more best practices; some of them are maybe
philosophically wanted, some of them not.  What I can show here is that the
general idea of offchain channel rebalancement certainly does make a difference.
It improves the LN in the sense of, right now when we try to make a payment and
we can't deliver the payment, we don't know if the network doesn't have enough
liquidity in general to deliver the payment, or if we have just hit depleted
channels all the time.  If you apply my results and a payment fails, the
likelihood that the network is just not able to provide enough liquidity is much
higher.  So, then we could actually do an onchain transaction to fix this,
right, so we would have much better semantics of why a payment really fails.

So, we know that this approach is helpful for the network, but it's really,
really hard to make a decentralized protocol out of this.  We could try to do
that, but if people then say, "Yeah, we don't want to go in this direction
anyway for other reasons", well, then we shouldn't, right, because it's hard by
itself anyway.  So, this is one of the questions, and this is something where I
would really love to have community input because, I mean of course, I can now
spend half a year to try to come up with a reasonable protocol.  But given that
we already know the trade-offs at this point, I think it would be much nicer if
there was some feedback of, "Is it worthwhile pursuing or not?"  And then, it's
still not clear if we can find a decentralized protocol that is very close to
the optimal solution, because the optimal solution currently only works with
perfect coordination or a central coordinator, which is perfect coordination.

**Mike Schmidt**: That sort of leads into my usual wrap-up question, which
you've sort of already answered, which is calls to action for the community.
You've outlined some questions here.  You have three also in your Delving post,
open questions for the community.  So, I would encourage folks to take a look at
that if they're interested in the topic.  There's also the notebook and
associated code for folks to experiment with.  So, if folks are curious about
this topic, there's plenty of content and code and simulations to dig into.
Anything else you'd add, René?

**René Pickhardt**: I'd highly encourage LSPs and node operators that do not
only operate one node to try these ideas with their network of nodes.  Because
the general gist with this is, if you control a sub-network of the LN, this
network could be much more reliable than the rest of the LN if you apply these
research results to your own subnet of nodes.  Of course, if the entire network
would adapt, this would be even more beneficial, but it can be adapted by a
subsection.  And I mean, this would improve the service of those LSPs, but it
would also improve the overall reliability of the network.  So, yeah, from that
perspective, I highly encourage people who run nodes to take a look at these.
And if you have feedback and questions, of course, you can always reach out.  As
long as I'm able to open-sourcely talk about stuff, I mean, I don't have to
mention your name or so, but I mean, I'm doing research on the open-source side.

**Mike Schmidt**: Thank you for your time, thank you for hanging on for your
news item later in the show, René.  We appreciate that.  We understand if you
have other things to do and need to drop.

**René Pickhardt**: Thanks for the invitation and for all the work that you're
putting in communicating all the updates.

**Mike Schmidt**: Appreciate that, René.  Thank you.  We have our monthly
segment on Changes to services and client software next.  It was a slower month
compared to previous months.  I think we've been in the 10 to 12 range.  We have
four pieces that we're highlighting this month.

_Cove v1.0.0 released_

First one, Cove v1.0.0 is released.  Cove Wallet in its recent releases, I think
it was 0.5 and 0.5.1, included features around coin control support and also
BIP329 wallet label features.  Murch, other than being proud of me for not
linking to the coin selection topic because this is coin control, any thoughts?

**Mark Erhardt**: No.  I just looked a little bit at the release notes and it
looks like this wallet is moving pretty quickly.  There have been something like
four releases in the past month.  So, they seem to be picking up their features.
I haven't looked too much into it though.

**Mike Schmidt**: Yeah, there's a lot of good Bitcoin tech in there already, and
I think there might have been a page on their GitHub that also outlines things
to come.  So, maybe check out that wallet if that's something that you're
interested in toying around with.

_Liana v11.0 released_

Liana v11.0 released.  We covered many of the Liana early versions, but it's
been a while since we covered Liana recently.  So, in a few of their recent
releases, Liana included multi-wallet support.  They also included additional
coin control features, additional support for hardware signing devices, and
other features as well.  So, definitely if you haven't looked into Liana in the
last many months or years since we talked more about them, check out what they
have going on.

**Mark Erhardt**: I see that coin control features and coin selection features
are very popular again.  And I would remind people that recently, we've been
seeing a few transactions get confirmed below 1 sat/vB (satoshi per vbyte) on
the network.  So, it looks like at least two mining pools are now not even
enforcing minimum relay transaction feerates.  So, if you are looking to
consolidate, you might even be able to do so at low feerates.  And that's
especially relevant in the context of wallets like Liana, where after some time
out, the security of your UTXOs degrades, or not degrades, but falls back to
lower security levels on purpose, and you might want to move your coins
occasionally.  So, filters like being able to filter by a minimum confirmation
amount or a confirmation count can be very useful to make some targeted
consolidation transactions and refresh.

**Mike Schmidt**: And we actually get into a BTCPay Server later on that has
added those exact features to filter for UTXOs based on certain criteria.

_Stratum v2 STARK proof demo_

Stratum v2 STARK proof demo.  StarkWare demonstrated a modified Stratum v2
mining client that actually uses a STARK proof to prove that a block's fees
belong to a valid block template, without revealing the transactions in the
block.  So, Stratum v2 does have this ability for you to not disclose the
transactions that you're mining on, if you're mining under the Stratum v2
protocol.  But my understanding, it was an open problem of whether those blocks
fees' associated with those transactions.  And so, that was sort of an open
problem that Stratum v2 folks had somewhere in their repository.  And now, the
StarkWare folks have actually done essentially a zero-knowledge proof to prove
that those fees are part of a valid block template without revealing the
transactions, which seems cool.

**Mark Erhardt**: Yeah, I think so far, the solution was that the mining pool
would have to sample a share occasionally from the miner, randomly say, "Oh, you
just submitted a share, please show me that one".  And then, would have to check
that all of the transactions listed in the template are available and accurately
represented, and that the coinbase transaction is valid.  And that would incur a
large overhead for the mining pool.  So, being able to prove in a succinct proof
that your block is valid and the fees you're stating are correct, would probably
make it both more efficient and more reliable for mining pools to offer this.

_Breez SDK adds BOLT12 and BIP353_

**Mike Schmidt**: Last piece of software this week, Breez SDK adds BOLT12 and
BIP353.  Breez SDK has a couple of different variations.  This is specific to
the nodeless variant.  And in 0.9.0, that nodeless variant added support for
receiving using BOLT12 offers, and also support for BIP353, which is DNS payment
instructions, which specify human readable names, which is cool, I love that.
And the nodeless variant of Breez SDK actually uses the liquid network sidechain
to facilitate some of their operations.

**Mark Erhardt**: Yeah, I remain very excited about sort of the contact book
without address reuse coming to Bitcoin payments with BIP353, BOLT and silent
payments.  You can repeatedly pay people without reusing addresses and, yeah, it
pops up everywhere, it's great.

_Core Lightning 25.05_

**Mike Schmidt**: Yeah, it's a nice usability enhancement.  Releases and release
candidates, we have Core Lightning 25.05.  I pulled out a few notable things
that I'll just go through quickly, and then point to the podcast with Alex.  The
first one is that commit and revoke message handling is now faster, meaning
quicker payment settlement and more responsive channels.  Also, the reckless
plugin can now auto update any plugins that are already installed via reckless
update, which makes plugin management easier.  There's also additional
functionality for splicing interoperability with Eclair, and splice RBF
features.  Core Lightning (CLN) has also added peer storage, which went from an
experimental feature to default, which improves peer reconnection and latency
associated with that.  Also, improved anchor fee calculations, a fix to askrene
routing when using high-capacity channels, and officially, this will be my last
time that I point to our #355 Recap Podcast with Alex Myers, that he and Dave
went into more in-depth with these features.  So, I figured I'd give a shout out
since the release is official.  Let's still check back to Alex talking about
some of this.

**Mark Erhardt**: I also thought that the name of this release is very funny,
"Satoshi's OP_RETURN Opinion"!  And I noticed that one of the new contributors
to CLN in this release is a familiar name.  Jiri Jakes, our Czech translator for
the Optech Newsletter, appears to have contributed to this release.  So, that's
cool.

_Eclair #3110_

**Mike Schmidt**: Oh, that's awesome.  Yeah, I didn't pick up on that.  Cool.
Notable code and documentation changes.  Eclair #3110 is a PR titled, "Increased
channel spent delay to 72 blocks".  So, previously Eclair would wait just 12
blocks before considering that a channel was closed after its funding output was
spent.  But a change to the splicing specification now recommends 72 blocks, so
that a splice can propagate the network.  T-bast actually noted in that BOLTs
PR, changing that to 72 that, "The channel can keep its history in path finding
scoring/reputation, which is important".  So, they want to keep the continuity
of the channel, even if you're splicing in funds.  And so, that's why they
increased that to 72 blocks.  And similarly, echoed in the draft release notes
for this PR is, "When we detect that a remote channel has been spent onchain, we
wait for 72 blocks before removing it from the graph.  If it was a splice
instead of a close, we will be able to simply update the channel in our graph
and keep its reputation".

_Eclair #3101_

Eclair #3101 adds a parse offer RPC, so that Eclair users can read the BOLT12
offer amount among other fields.  Eclair also allows paying offers with a
currency other than BTC.  In the tests that I saw as part of this PR, for
example, euros was included as the currency that was used.  I don't exactly
understand how that mechanism works, but it was mentioned in our write-up as
well as the PR and is in the test.  So, I don't know how that conversion works.

**Mark Erhardt**: Yeah, that sounds curious.  How would the exchange rate be
calculated on the fly and agreed upon?  So, anyway.

**Mike Schmidt**: Maybe we can dog-ear that for the next time we have t-bast on,
which has been a while.  Usually, we have them on fairly regularly.

_LDK #3817_

LDK #3817 rolls back support for attributable failures, that we covered in
Newsletter and Podcast #349 when they were originally put in.  And the author of
this PR noted that, "Until a sufficient number of nodes on the network has
upgraded, it's not possible to use attribution data to assign blame.  Otherwise,
nodes that have not upgraded yet would already receive penalties".

_LDK #3623_

LDK #3623 is part two of LDK's peer storage features, adding new peer storage
features to LDK.  Previously, LDK would store peer data and send the data back
when reconnecting.  With this VR, LDK will now also send peer storage
information to all channel peers whenever a new block is mined.  And there's
also logic to decrypt peer storage based on requests from a peer.  There are
also further PRs planned around peer storage to come as well, as indicated in
the PR discussion.

**Mark Erhardt**: Every block?  Do you remember how much the peer storage was
allowed to be?  It was like a few kB, or so?

**Mike Schmidt**: The size?  Yeah, I don't recall.

**Mark Erhardt**: Well, so if it's like 10 kB and we have 144 blocks, that's,
well, still only a little more than an MB.  Never mind, that's fine, but just
interesting!

_BTCPay Server #6755_

**Mike Schmidt**: BTCPay Server #6755 is a PR that, "Enhances the coin selection
interface in the wallet by introducing advanced filtering options and improving
usability".  Obviously, they meant coin control interface, although they are
doing manual coin selection, I guess is fine.  So, there are now filters in
BTCPay Server for minimum amount, maximum amount, and creation date of the UTXO.
I saw the interface, they had a nice video in the PR that showed there's
essentially a text box, and that text box will parse these different filter
syntaxes, and then the resulting UTXOs will show up in a table below.

_Rust libsecp256k1 #798_

Rust libsecp256k1 #798.  So, I don't think we've covered Rust libsecp256k1, but
it is a wrapper around secp, the cryptographic C library that we cover more
often in the newsletter.  And this PR addresses a bunch of follow-ups around
that wrapper's library's MuSig2 implementation, and officially completes Rust's
secp implementation of MuSig2.  So, there was a follow-up PR before this one,
and then there was the original implementation, but they are now calling this
the official support for MuSig2 in Rust secp.

**Mark Erhardt**: So, that means of course, is BDK using Rust secp probably, and
probably LDK?  So, it sounds like this will downstream and we'll get all of that
stuff eventually also in the SDKs for Lightning and wallets.

**Mike Schmidt**: The exciting thing when BDK originally came out is that these
sorts of things would be proliferated, these pieces of Bitcoin tech would roll
out a little bit quicker, because you wouldn't have all these different hundreds
of wallets having to implement it, right?  So, yeah, if it gets in BDK and folks
use it, you'll get to see more adoption.

**Mark Erhardt**: Yeah, well, it's only been, what is it now, three-and-a-half
years since taproot, so good to see MuSig2 support roll out to that extent.
There's now also BIPs for descriptors with MuSig2 and key derivation with
MuSig2.  PSBT v2 is getting more adopted.  We are seeing some hardware wallets
implement support.  Maybe we'll get music to channels eventually on LN.  So,
we'll see.  It'll get there eventually.

**Mike Schmidt**: We want to thank our guests this week, Bryan Bishop, Robin and
René for joining us.  Murch, thanks for hosting this week and for you all for
listening.

**Mark Erhardt**: Hear you next time.

{% include references.md %}
