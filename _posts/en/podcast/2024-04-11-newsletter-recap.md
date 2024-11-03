---
title: 'Bitcoin Optech Newsletter #297 Recap Podcast'
permalink: /en/podcast/2024/04/11/
reference: /en/newsletters/2024/04/10/
name: 2024-04-11-recap
slug: 2024-04-11-recap
type: podcast
layout: podcast-episode
lang: en
---
Dave Harding and Mike Schmidt are joined by Kulpreet Singh, Chris Stewart,
Jameson Lopp, and Joost Jager to discuss [Newsletter #297]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-3-15/d396762c-7d41-5f20-5795-2ce8808e122c.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #297 on Twitter
Spaces.  We're going to be recapping a few news items.  First one is DSL for
experimenting with contracts; we're going to be talking about the proposed
updates to BIP2; we're going to also talk about some discussion about resetting
and tweaking potentially testnet; and we have a Bitcoin Core PR Review Club,
where we're going to talk about 64-bit arithmetic and our usual sections on
releases, release candidates and notable code changes.  I'm Mike, I'm a
contributor at Optech and I'm also Executive Director at Brink, where we fund
Bitcoin open-source developers.  Dave?

**Dave Harding**: I'm Dave Harding, I'm co-author of Optech Newsletter and
co-author of the third edition of Mastering Bitcoin.

**Mike Schmidt**: Kulpreet?

**Kulpreet Singh**: Hi, I'm Kulpreet, I'm essentially a contributor to
Braidpool, but I keep getting distracted by other more fun things to do in
Bitcoin.

**Mike Schmidt**: Jameson?

**Jameson Lopp**: Hi, I'm a Co-founder and Chief Security Officer at Casa, where
we help people self-custody.

**Mike Schmidt**: Chris?

**Chris Stewart**: Hi, I'm Chris Stewart and I'm an independent Bitcoin
developer.

**Mike Schmidt**: Well, thank you all for joining us this week.  We're going to
go through the newsletter sequentially so if you're following along, I've
tweeted out a few highlights, but feel free to jump into the newsletter on
bitcoinops.org #297 starting with the News section.

_DSL for experimenting with contracts_

DSL for experimenting with contracts.  Kulpreet, you posted to the Delving
Bitcoin forum about a DSL, which is a Domain Specific Language, that you're
working on for Bitcoin and scripting and maybe advanced contracts.  Maybe,
Kulpreet, you want to provide an overview of what a DSL is, and maybe we can
jump into some of the details of what you're working on.

**Kulpreet Singh**: Sure, definitely.  Well, DSL is, I mean it's difficult to
characterize what a domain-specific language is, but the way I see it is that it
has first-order functions and commands specific to a certain domain.  For
example, in the case of the Bitcoin DSL, some of the commands are to build a
transaction just by saying what the transaction should look like, or to extend
the chain to a given number of blocks.  And you could even stretch that, so for
example, in the Bitcoin DSL, we expose all the JSON-RPC commands as kind of
first-order commands in the DSL itself.  So, that's how I kind of classify DSL,
that the operations required in a certain domain are just first-order functions
there.  You can just directly call them, as opposed to jump through hoops to
make an HTTP call, etc.

In the Bitcoin DSL, it's interesting.  So, when I first got into Bitcoin, of
course there's the good old "learn Bitcoin from command line" tutorial that
almost everybody goes through, or Mastering Bitcoin, and whatnot, but it's all
kind of slow and clunky.  You have to copy/paste things, you have to write some
Rust and C++ code to get your hands dirty, or even just Python code.  You kind
of get lost in the weeds and it takes a lot of persistence to stay chasing what
you want to learn in Bitcoin to get somewhere.  So, I always had this itch that
it would be nice to have a higher level DSL, as I said, to be able to do at
least the introductory parts of Bitcoin quick and easily, right?  They should
be, "Hey, this is what a transaction looks like, this is how you build it", and
hide away all the complexities of segwit v0, segwit v1, what is segwit, what is
not segwit, just hide all of that away from users, and let them see that if you
write a condition, like a locking condition, and build a transaction, then you
can unlock it like this, and so on and so forth, and you can make some certain
assertions.

Thankfully, the Bitcoin space has evolved so much that there's amazing things
like descriptors and miniscript, which is cool, but it made writing the DSL a
slightly bit harder.  But the fact that you have those tools makes it so much
more easier to write the rest of the stuff around them to be able to do things
in Bitcoin, for example to be able to write transactions.  Now, one thing that
made the project actually plausible and easier to do was that we were not
concerned about the security of the scripts generated, we were not concerned
about the speed of it, at which these would run.  So, if you really want to
write production code, you should really go back to your Rust and C++ libraries,
and whatnot.  This is just a tool to kind of play around and to be able to
communicate your ideas with others in a more crisp manner so that things are
clear, because if it's executable code, there's fewer uncertainties around it.
Anyway, I've spoken a bit, I don't know if you want me to continue.

**Mike Schmidt**: We touched on DSLs, I think, in the past on this show.  I
think there was a DSL, yeah, Doppler, that was an LN testing tool that was a DSL
for spinning up LN node topologies.  That included on and offchain payment
activity.  I'm not sure, there's another LNSim tool, I'm not sure if there's a
specific DSL for that.  And then I know that Warnet has this idea of scenarios
and I'm not sure how they implement that.  Are you familiar with any of those
tools, and is there overlap there?

**Kulpreet Singh**: I actually looked at Doppler because I was curious if that
would just suffice for what I wanted to do.  However, it was really specific to,
as you said, spinning up and down LN nodes and to be able to define a cluster of
nodes in a script, and then it would just go fire it all off.  But for example,
what we are trying to do with Bitcoin DSL is to be more lower level so that,
it's kind of conflicting, but you can write contracts in Bitcoin.  For example,
you can describe the Ark protocol using this.  Whereas the Doppler tool, I
remember, is really specific to spinning services up and down for LN.  I don't
know the third one that you mentioned, I haven't seen that, so I'll definitely
be looking into that.

I think there are differences, I mean huge, as to what we want to achieve in
each of these.  There's a few other languages which I think, in some way,
miniscript put an end to all of that in a way that, "Okay, here's a nice way to
do it", which were largely just being able to write the script itself, like
Bitcoin Script itself, in some other ways, say for example, I don't remember the
name of it, but it looked like JavaScript and you would write contracts in it
and it would compile to script.  Similarly, Sapio by Jeremy Rubin is a similar
tool.  It's like in Rust, and it gets compiled into Bitcoin contract.  But those
are just compiling down to script, whereas what we want to do is be able to
write transactions and be able to say what are the locking and unlocking
scripts, like scriptPubKey and scriptSig, in again a very high-level tool like
miniscript, or whatnot, and then be able to, one transaction is spending the
other, and then the output of this one is spent by another transaction.  All
that can be kind of composed and written and described.  It's kind of difficult
to talk about it all without a visual there, but I hope people kind of follow
what I'm trying to say here.

**Mike Schmidt**: What do you think, Dave?

**Dave Harding**: Well, I mean thank you for working on this.  One of the things
I think about when I looked at your code there is, I think this is really,
really useful for just developers communicating with other developers about how
a smart contract protocol can work.  You give the example of Ark.  I remember
reading the original description of Ark and it just hurt my head.  He was
inventing new terms, he was describing this really novel thing, and it reminded
me, looking at your DSL and thinking of Ark, of how a few hundred years ago,
people used to describe algebraic equations using words.  And then somebody had
the idea of a notation, and we have this standardized notation now, and it makes
it so much easier for us to just see the structure and understand how the thing
works.  Words were sufficient to get the point across, but having a quick and
concise notation just makes this really easy.  And so, I'd like to see something
like your DSL get adopted for people just describing, they want to post on
Delving on a mailing list and they say, "I have a new protocol I've just
invented", and they can just sketch it out, hopefully with a few lines of this
sort of prototype language or pseudocode.

We see people doing that with miniscript and descriptors now.  We used to write
whole scripts on the mailing list, and now people will just use a very concise
miniscript or a descriptor to do it.  Like I said, I think your language is a
really good fit for this sort of prototyping community.  And what I liked about
it, an additional thing I liked about it, is that it is functional.  It's not
just pseudocode, it's actually code that can be run, so you can quickly sketch
out your language, I mean your new contract protocol, you can quickly sketch it
out, and then you can go in and use the code to fill in all the edge cases, and
then you can start to develop your client against this very quickly written
pseudocode, and just make sure you're hitting all the cases that you identified
in this high-level description, and I think that's just a nice boost to actually
getting these protocols from the concept stage to the developer buy-in stage to
the first client stage.  And then also, that pseudocode, that prototype
language, that's still out there for new people to learn how it works.  So, I
just think this is great.  Thank you so much for working on it.

**Kulpreet Singh**: I mean, I'm really delighted the way you've described it
all, because this is what I really wanted to get across.  This is the point,
like if on the mailing list, we used to kind of to and fro the contract
conditions and say, "Okay, what happens in this case?" and everybody was
inventing their own pseudo language.  Primary motivation was also like, in the
past, there was discussions of channel protocols and it's all like, "Here's a
pseudo language, this will be spending this thing, this will be spending this",
and you're lost as a late-stage newcomer, right?  So, you've really hit the nail
on the head in terms of what my dream was to do with this language.

I mean, also it kind of eliminates the case like, okay, here is how I describe
the protocol, it works, you can run it in a notebook, etc.  And the other person
on the receiving end on the mailing list can say, "Hey, but I've coded this
condition where it fails".  That would be an ideal outcome too.  But thanks,
Dave, I really appreciate that you actually really got what I'm trying to do
here, so thanks a lot.

**Mike Schmidt**: You mentioned the notebooks.  In some of my experience in my
past life, there was these web developer type tools that had like HTML, CSS, and
JavaScript at a specific URL, and you could tweak it live there and sort of play
it.  I wonder if there'd be something similar where you could kind of share
these URLs, which would sort of have the script loaded, and like you said, maybe
in a notebook.  Obviously, there's a Bitcoin node behind some of this which
makes it a little bit more complicated, but that would be a cool way to share
and collaborate, I think.

**Kulpreet Singh**: I mean, that is a cool point, because this is exactly what
I've been doing as well.  Right now, if you pull the repo and just go "justlab",
it basically starts a Docker instance, which runs a regtest node inside it and
opens a Jupyter Notebook with a kernel that interprets this DSL, so you can just
start working away.  And my dream is also for some of the protocols that I'm
personally interested in, for the moment at least, to have those notebooks
ready, so that if somebody pulls the repo, they can, when they fire things up,
some of the examples of the current popular protocols are already there, right,
it's a big compendium.  It's also a way for me to make sure that the DSL has
enough features to be really useful.  For example, yesterday I was trying to do
silent payments, right, and I realized I haven't exposed group operations, where
you multiply, a scaler and a point.  So, I kind of exposed that too so that I
can describe the silent payments protocol.

So, yeah, going back, sorry, I digressed there, but notebooks is definitely
there now already.  I was hoping to host them online somewhere, but that's just
another production step I don't want to take another three, four days of my life
doing that.  At the moment, at least you can pull it.  And if you have Docker
installed, you'll have a notebook running on your machine immediately, because
the image is also on GitHub, so you don't have to build the image locally.

Another thing is that, sorry, I'm just going to take another minute, but another
idea is that within a notebook, you could have multiple versions.  So, for
example, you have the Bitcoin Core node running, so you have the standard
features available, but nothing stops us from shipping images with different
forks of Bitcoin, with different covenants enabled, etc, so that those authors
of those tools, just like in Sapio, they could demonstrate using the same DSL,
but talking to a different fork of Bitcoin Core that this is how you can do it,
right?  And all those images could be on GitHub, too.  So, I think the
possibilities are interesting.  It's a question of getting enough sample
contracts out there so that people find the utility of it and are happy to spend
some time trying to write things with the DSL.  But who knows where that goes.

**Mike Schmidt**: Are there any parting words for the audience, calls to action?
Do you want people to play around with this, download and tweak it themselves,
other calls to action?

**Kulpreet Singh**: Yeah, absolutely.  I would love help with trying to describe
any other protocols that I haven't yet thought of to capture there, which is
almost all of them.  I've only done Lightning and Ark, and I'm currently doing
silent payments.  I would love if somebody wanted to have a go at being able to
describe how Rune works.  It's a very simple protocol, right?  But it's just the
DSL captures it, or anything like that.  To download it, you just go to the
GitHub, and README has all the instructions.  And I promise, it's not a big
build time, because Docker images are already built and on GitHub.  So, when you
go "run", everything just downloads once and you're done.

**Mike Schmidt**: Kulpreet, very cool, thanks for joining us.  You're welcome to
stay on, but we understand if you have other things to do and you need to drop.

**Kulpreet Singh**: Thanks.

_Updating BIP2_

**Mike Schmidt**: Next news item is titled Updating BIP2.  Dave, we've had a bit
of BIP meta discussion going on the last few weeks.  I think we covered, in the
last few weeks, choosing new BIP editors and some discussion around that that's
gotten pretty lengthy on the mailing list.  But now we're talking about a sort
of different discussion that spun off in relation to that, about updating BIP2.
How would you frame up what Tim's posted to the Bitcoin-Dev mailing list here?

**Dave Harding**: I think this is probably an opportune time.  So, when the BIP
repository was started years ago by Amir Taaki, he created BIP1, which described
how to create BIPs, how to modify BIPs, and what the roles and responsibilities
were of the BIPs editor.  Eventually, the BIP editor duties get passed on to
Gregory Maxwell, and when Gregory Maxwell passed them on to Luke, Luke actually
made an update of BIP1, creating BIP2.  So, now we're at a point of talking
about choosing new BIP editors.  It seems like this is the historic kind of time
when we would look at the process and decide if we want to update it, and Tim
had some ideas.  Some other people had some ideas, the main one of which I think
was possibly reducing the scope of discretion for BIP editors.

Right now, BIP editors have a lot of responsibility, according to BIP2, for
evaluating an idea.  They have to evaluate it to see if it's a sound idea, and
that's not really explained what that means.  A lot of people, I think, who are
commenting on this are the ideas that really the job of the BIP editors is to
prevent the BIP repository from being overrun by spam.  We don't want somebody
going out there and creating 1,000 BIP proposals, all of which are just
chat-GPT-created text.  But beyond that, as long as the idea seems at least
tangentially related to Bitcoin, is something that probably should be
standardized, we should probably just let it be, and give it a number, and allow
it to live in the BIPs repository, and allow developers and users to decide what
they want to use.  Beyond that, Tim also had some other comments.  He doesn't
like some of the licenses that are allowed for BIPs.  When you run a BIP, you're
allowed to choose which license you can issue it under, and there's a stack of
suggested licenses.  I think you actually might be required to choose from that
stack at this point.  He suggested that some of those were not good for
documentation, they were really designed for code, which is fine.

Also, one of the things that was introduced in BIP2 that wasn't originally in
BIP1 is that every BIP has in its headers now a field called "comments URI",
which is the place where people are encouraged to leave comments on a BIP
describing why they think it's a good idea or why they're opposed to it.  And
also a summary, which is created by the BIP editor, of those comments.  And this
has been underused and some people who have created BIPs really don't like the
summaries of their BIPs.  I think one of the big examples is, wow, what is it?
The BIP39, or whatever, is unanimously discouraged for implementation, so seed
words.  I think a lot of people are confused by that since it's such a widely
used thing.  But that's just basically it.  It came out of this idea that there
wasn't really a lot of opposition on the mailing list to this, there wasn't a
lot of discussion about it either.  I think it probably is time for an update.

**Mike Schmidt**: Great summary, Dave.  We also noted at the end of this news
item that in that related discussion about nominations of new BIP editors, that
the deadline that some of the developers had outlined had been moved to Friday,
April 19, which is just over a week from now.  I think the original proposal was
to potentially get that done this past week.  So, there's still opportunity, I
guess, to nominate and advocate for moderators to the BIPs repository.  Anything
else you'd add here, Dave?

**Dave Harding**: No, that's it.

_Discussion about resetting and modifying testnet_

**Mike Schmidt**: Next news item, Discussion about resetting and modifying
testnet.  Jameson, what's going on with testnet?

**Jameson Lopp**: More of the same, but also some new stuff.  So, as I outlined
in my mailing list post, it's actually been 13 years since we've done a reset of
the test network.  And interestingly enough, the test network is actually on
block height 2.5 million-something, so the block reward is down around 0.014
testnet bitcoin.  Results of that are that you can't really get much testnet
bitcoin by mining it.  And the length of the blockchain, that height, is
actually a result of a weird edge case that happens where every once in a while,
it's actually like every 12% or so of difficulty resets, we hit this particular
edge case that causes the mining difficulty of testnet to get permanently reset
down to 1, the lowest possible difficulty, which then kicks off this huge flood
of blocks that get created.  We're talking like dozens of blocks per second.
You can easily see like 10,000 blocks added in the span of a few hours or a few
days as the difficulty EPECs get run through, kind of like speed running, all
the way back to what the difficulty was before that permanent reset happened.

Also, really the thing that led me to send this email and start discussing this
is that testnet itself has been getting used a lot more, but getting used for
some scammy stuff.  And the result of that is that people like myself, people
who have a bunch of testnet bitcoin, we've been getting just hounded by people
asking us for coins, and specifically by non-developers.  I have no problem
handing out testnet coins to people who are actually building on Bitcoin, but
I've been getting flooded because now there are people who are participating in
these airdrop type things on testnet and they're expecting to get real value out
of that, and so they're a lot more desperate in order to get these testnet
coins.  In fact, that has gone to the point now where there are actual markets
where people are buying and selling the testnet coins.  I would say that one of
the most fundamental principles of testnet is that it's not supposed to have any
value, and that's supposed to help in the distribution of these coins freely
amongst anyone who is interested in building.

So, this is really why I've floated this idea of doing a reset and if you've
been reading along the discussion, it's kind of interesting because it's been so
long since we've done a reset.  I think some people are a bit more hesitant to
push for that.  And then I was basically saying, if we're going to do a reset,
why not fix this edge-case bug as well?  Technically, it would be possible to
fix that bug without resetting testnet, but there's open questions around how
much work do we want to put into doing this and should we all just bundle it
together?  So, I don't know, I would say most people seem to be generally in
favor of doing these things, but there definitely was a bit of pushback and some
people questioning whether or not a testnet4 would be successful, like is there
enough like economic value already entrenched in testnet3 that would prevent
people from switching over to a new testnet?  So, interesting discussions.  I'm
hopeful that we can continue just making some progress on this because I'm just
kind of annoyed at the current situation.

**Mike Schmidt**: I had no idea the depths of what was going on on testnet.
That's actually pretty wild.  Dave, what do you think about Jameson's mailing
list post and what's going on in testnet3?

**Dave Harding**: Well, I mean I agree with Jameson that when testnet coins
acquire an economic value, the only mechanism we have, the mechanism we've used
historically, is to reset testnet.  I think one of the most interesting
counterpoints to resetting testnet on the thread came from Peter Todd.  And his
point, and Calvin Kim made a similar point, was that testnet, in 13 years of
people testing it and doing all sorts of weird things, it's just acquired a
decent sized repertoire of just weird and interesting edge cases.  And if you're
writing wild software, especially if you're writing consensus code, like you're
working on an alternative node implementation, it's just really useful to be
able to run your code against testnet.  And if everybody were to abandon
testnet, the data would still be out there, but it just wouldn't be as
accessible.  And I don't know, maybe there's a wide variety of clients on
testnet.  I haven't actually gone out and tried to quantify that, but there
could be a large variety of people running weird nodes and weird wallets on
testnet that are going to do weird things when they interact with your code.
And that's one of the things you want from testing, is you want to be able to
test against other people doing weird things.  So, I think that's the only
argument that resonates with me about not resetting testnet, is that we have
this repository of weirdness, and we maybe want to keep that.

Then there's the difficulty reset bug that Jameson is talking about.  The reason
that exists is because there was a concern that somebody would take mainnet
miners and they would run up the difficulty on testnet really high and then stop
mining, and nobody else would be able to make progress.  If they stop mining
right after a difficulty change, then it would take 2,016 blocks of
high-difficulty mining to have testnet make any progress at all, and I think
that's a concern.  I haven't seen that adequately addressed in the thread for
me.  What are we going to do if that happens?  So, I think there's some open
questions there, but again, I think the economic issue there, if people are
valuing testnet coins, testnet reset is what we're supposed to do.  Go ahead,
Jameson.

**Jameson Lopp**: Yeah, so there were a few different proposals around ways that
we could tweak the, call it the minimum difficulty rule.  So, this block storm
edge case is actually a combination of the fact that testnet has a special
minimum difficulty rule whereby if 20 minutes go by without a block, you're
allowed to temporarily mine a minimum-difficulty-of-1 block just in order to
keep the network progressing.  And that in and of itself is generally okay.  The
problem however is that the difficulty retargeting logic additionally, for both
mainnet and testnet, for every network, it has an assumption in the difficulty
retargeting logic where it only looks at the difficulty target of the last block
before doing a retargeting recalculation, because it assumes that the difficulty
has been the same for that entire mining EPEC or difficulty EPEC.  So basically,
what happens is if you hit one of those minimum difficulty rules on the block
right before a retargeting happens, it's like, "Oh, our difficulty was only 1
before, so we'll just go forward and recalculate off of that".  So, it would be
possible to only fix the retargeting rule if you wanted.

But actually, Andrew Poelstra had a suggestion, and I think that his suggestion
was basically that we change the minimum difficulty rule so that it would have
to be several hours in the future.  The reasoning for that is that it's actually
possible, if you wanted to be malicious or adversarial, you could trigger that
difficulty reset rule at any time right now, because the consensus rules for the
timestamps and the block headers have a fair amount of leeway in them and nodes
will generally accept blocks with timestamps, I believe, up to two hours in the
future from whatever the current clock time on your node is.  So technically, I
could tell my testnet node to create a difficulty-1 block and just claim that it
did so 20 minutes in the future, and the rest of the network would accept it and
I could build off of that and kind of create this runaway testnet block
generation if I wanted to.  But if we changed that minimum difficulty rule so
that it would have to be like two or three hours in the future, that would
prevent that sort of gaming issue, and I think it would make it much less likely
that we would hit the permanent reset issue.

**Mike Schmidt**: Go ahead, Dave.

**Dave Harding**: I just wanted to say, yeah, I think if I'm reading Andrew's
proposal correctly, what it means is that there wouldn't automatically be a
difficulty reset at six hours.  You would just be able to mine a single lower
difficulty block.  He suggests raising the default difficulty, but let's ignore
that for now.  That would mean that for 2,016 blocks, if I understand his
proposal correctly, you would have a six-hour gap between each block.  So,
instead of taking two weeks to mine 2,016 blocks, it would take, what is that,
six months, eight months?  I think that might be too slow for testnet.  Now I
could be misreading his proposal.  I will reply on the mailing list and seek
clarification.

But yeah, I mean it's an interesting idea.  I think this is just something that
if we're going to reset, it would be nice to address this at the same time, both
the block storm issue of blocks too fast, but also the problem of blocks too
slow, and see if we can find a way.  Yeah, go ahead.

**Jameson Lopp**: It's not perfect.  He didn't give reasoning on why he chose
six hours.  I think anything more than two hours would be sufficient to prevent
that sort of gaming.  So, I think you could easily go with like a two-hour,
one-minute window or something like that, you know, whatever is just beyond the
threshold for gaming it.  But yeah, you're kind of hitting on an issue that
hasn't really been discussed which is, what is the desired minimum wait time to
get a confirmation on testnet?  And this is also why I brought up the question
of, well, do we even care about testnet anymore when we have signet, which is
much more reliable on the block times?  The consensus seemed to be that testnet
is not really fully replaceable by signet; they offer different things?

**Dave Harding**: I didn't say this on the mailing list, but I'm in the camp of
just go with signet, kill testnet.  But you're right that most of the people who
expressed an opinion, they'd said they want testnet.  I personally think testnet
is really only interesting to miners at this point, now that we have signet.
But I'm fine with testnet living.

**Mike Schmidt**: That was going to be my comment/question as well.  Dave, you
mentioned this repository of weirdness on testnet.  There's a default signet,
but there's nothing to say that somebody can't encapsulate this repository of
weirdness, at least to the degree that it can be recreated on signet, and have a
bit more of a sort of chaotic signet going on.  I don't know if anybody's
working on something like that, and if it would address folks like Calvin's
comments about wanting a bit more chaotic environment to test in.

**Jameson Lopp**: Yeah, chaosmonkeynet!

**Chris Stewart**: If I could chime in here, I think just creating an archive of
these weird transactions somewhere would be independently valuable.  Just
thinking about it out loud, it seems like the hard things that maybe would kind
of port over to say testnet4 from a testnet3 is like timelock stuff embedded in
scripts, because otherwise with all your weird scripts, it seems like you could
just swap out the public keys and then just publish them on testnet4 in the
first couple of thousand blocks.  Another thing, in just terms of value of
testnet over signet, just in terms of alternative consensus implementations,
along with miners, there are just these weird scenarios, again with time,
reorgs, things like that, that have value from the perspective of a separate
consensus implementation that's just hard to replicate on signet.  Whereas if
you're just strictly developing a standalone wallet application, I do think that
point stands for why signet is a standalone replacement for testnet.

**Mike Schmidt**: Jameson, Chris, Dave, anything else to say before we move on
in the newsletter?  All right.

**Jameson Lopp**: No, it'll just be interesting to see, I guess, how difficult
it is to keep moving forward on this.  You would think that something like
testnet, which is supposed to be resettable and not supposed to come with any
guarantees, would be easy for us to move forward on.  But I think it's actually
kind of interesting to look at this issue almost through the ossification lens
and the fact that the test network has built up value in a variety of different
ways.

_Implement 64 bit arithmetic op codes in the Script interpreter_

**Mike Schmidt**: Jameson, thanks for joining us.  You're welcome to stay on.
We understand if you need to drop.  Next section from the newsletter is our
monthly segment on a Bitcoin Core PR Review Club.  This month, we highlighted a
PR by Chris Stewart, who's joined us, titled Implement 64 bit arithmetic op
codes in the Script interpreter.  Chris, we've had you on a couple times to talk
about 64-bit arithmetic.  This is obviously a bit deeper of a dive that the PR
Review Club folks did, and I think you were the host of this.  I'll open the
floor to you to maybe opine on what you think is different, maybe recap the idea
at a high level, and then we can get into any interesting technical things that
came out of the review.

**Chris Stewart**: Yeah, so high-level motivation for the 64-bit arithmetic
stuff is, I would like to do math on satoshi values in the Script interpreter,
and currently we don't have enough precision in the Script interpreter to do
that.  Satoshi values can be up to 51 bits in value, or I think the actual 21
million bitcoin, if you were doing math on that; whereas our numeric opcodes or
arithmetic opcodes in the interpreter only supports 32-bit precision with an
asterisk there.  In certain cases, we've already kind of lifted that 32-bit cap,
and that's for timelock opcodes, like I was mentioning earlier.  So, those
timelock opcodes are called OP_CHECKSEQUENCEVERIFY (CSV) and
OP_CHECKLOCKTIMEVERIFY (CLTV) and they require 5 bytes of precision to do that,
just because of wall-clock Unix time.

So, the data structure in Bitcoin Core that handles our numbers inside of the
interpreter is called CScriptNum.  There's a nice parameter that we discussed in
the Bitcoin Core Review Club called nDefaultMaxNumSize, I believe off the top of
my head, that allows you to specify how many bytes of precision you would like
to have in the Script interpreter.  So, when CLTV and CSV were activated on the
Bitcoin Network in circa 2015, 2016, we already extended the precision a little
bit then.  What I would like to do is, again, get OP_TAPLEAF_UPDATE_VERIFY
(TLUV) activated in Bitcoin Core, and to get there, we need 64-bit arithmetic.

So, the things that came out of the PR Review Club that I think are of note is
again, just highlighting the interoperability concerns between existing opcodes
that we have in Bitcoin's Script interpreters, such as OP_SIZE, that take, as
input, a value on the stack and do something with that value.  In the case of
OP_SIZE, it's count how many bytes are on that value and then push it back onto
the stack.  However, if you look at the implementation in interpreter.cpp, there
are hard-coded limits of what the maximum amount of bytes these opcodes can
accept.  So, what we need to do is, we don't want to fragment the interpreter
across things that allow 4 bytes as inputs and things that allow 8 bytes as
inputs.  We want to have this kind of seamless interoperability between the two
numeric systems that are out there.

So, for old consensus clients, we of course need to stick with the old 4-byte
inputs.  However, with new consensus soft forks, we want to potentially extend
that in thinking about how to best design the 64-bit soft fork to allow for
further extensions to maybe say 256 bits in the future, rather than just 64
bits, is something that we kind of discussed during this Bitcoin Core PR Review
Club.  I'd like to thank Gloria for allowing me to lead this and got some great
questions about it, specifically around interoperability stuff.  I'd encourage
people to go read the IRC chat logs on bitcoincore.reviews, I believe, is the
website, and I'm happy to answer any questions over Twitter DMs or elsewhere if
you are interested in the subject.

**Mike Schmidt**: All of the PR Review Club interactions are on IRC and are
captured and logged, as Chris mentioned, at the bitcoincore.reviews website.
For this particular PR, it's bitcoincore.reviews/29221.  And there's also a
bunch of back information that's provided before these PR Review Clubs are held,
which may be interesting for listeners.  And in addition to that, we linked in
the newsletter to the work-in-progress BIP, as well as the discussion on the
Delving Bitcoin forum on the same topic.  Dave, what do you think about 64-bit
arithmetic?

**Dave Harding**: I'm really thankful to Chris and everybody who participated in
the Review Club for working on this.  A very large number of the soft fork
proposals that are floating around would benefit from 64-bit arithmetic
operations.  So, this is just something that's going to be useful pretty much
any direction we go, except for ossification.  So, I'm just really thankful that
people are working on this.  And the thread on this that Chris started on
Delving Bitcoin, I think it's up to like 40 posts.  So, people were putting a
lot of thought and discussion into this and trying to figure out the best way to
do this.  And I'm just really thankful for that high-quality engineering on what
is kind of, you would think of as a really boring thing.  But we need people to
be working on the boring things and just making them great or we're never going
to get them in Bitcoin.  So, thank you, Chris, and thank you to everybody who
participated in this PR Review Club.

**Mike Schmidt**: Chris, Dave alluded to some of the potential future use cases
and why 64-bit may be required.  You mentioned representing satoshi amounts.
Maybe, can you give us the canonical, maybe joinpool, coinpool type example for
why you'd need 64 bits?

**Chris Stewart**: Yeah, so if you're interested in any sort of broad covenant
proposal, things with covenants generally have restrictions on the amount that
you can withdraw from the output the covenant is encumbering.  So, for instance,
you might want to have a rate-limiting covenant that says, "You can only
withdraw 10 bitcoin every 2,016 blocks", or something like that, every
difficulty adjustment period.  To do that, to be able to perform the arithmetic
or the math to enforce that covenant in the Script interpreter, you need to be
able to push the amount of Satoshis that you are restricting for withdrawal onto
that stack.  And to be able to fully support the entire range of values that we
can possibly have in the Bitcoin protocol, we need 64 bits of arithmetic.
There's a lot of other proposals kind of lingering out there that would like to
introduce cryptographic opcodes into the interpreter that would require, say,
256 bits worth of math, but let's take things slow.

I think I agree with Dave's sentiment of, this is something that a lot of people
want to do across a broad proposal or a broad variety of soft forks, and this is
kind of taking the commonalities between those proposals and trying to just
separate it out and get this into Bitcoin independent of whatever the ultimate
proposal we end up with for covenants in Bitcoin, try and take what is the
commonalities between them all, get it activated so we can get one blocker out
of the way.  Now, my quote, I think I've said to you Mike a bunch of times now,
"If you're going to eat an elephant, do it one bite at a time", and I think this
is one of the smallest bites that we can take.

**Mike Schmidt**: Chris, thanks for joining us to walk through this and again,
folks who are curious about the technicals here, jump into the Bitcoin Core PR
Review writeup, and thanks for joining us, Chris, you're welcome to stay on.

_HWI 3.0.0_

Releases and release candidates, we have three this week.  The first one is HWI
3.0.0 and it sounds like the main or only change that went into this version,
which required a version bump, was a change to the way the HWI is default
scanning for emulators.  There was an issue that was brought up.  I think
someone was using Sparrow Wallet and they were unable to find hardware devices.
And it turns out that HWI by default was looking at certain ports on the
computer for emulation purposes by default, and because some other software was
running at one of those ports, it actually screwed up that person's setup and
they weren't able to connect their hardware device.  And so, this change turns
off that default scanning for those different ports and actually solves the
issue for this particular use case and potential issues in the future.  So, you
have to explicitly turn on that emulation in the future.  Dave, I sort of
skipped ahead to HWI #729 there.  Do you have an elaboration on that PR as well
as this release?

**Dave Harding**: Yeah, it's just like you said.  It just happened that, like I
said, the person was running something on a particular port that's often used by
emulators, and HWI basically froze.  So, they couldn't use it, and I think it
may have frozen Sparrow Wallet for them too, because Sparrow Wallet was waiting
for HWI to reply.  So this, just by default, assumes you aren't running emulated
hardware, and if you are, you just have to parse an extra flag.  So, it's a
nice, clean bug fix.

_Core Lightning 24.02.2_

**Mike Schmidt**: Core Lightning 24.02.2, which is a maintenance release
addressing an incompatibility between Core Lightning (CLN) and LDK as part of
the gossip protocol.  Dave, did you drill into that incompatibility at all?

**Dave Harding**: Yeah, a little bit, actually.  I saw the LDK fixed it or
addressed it on their side last week, and now CLN is addressing it on their
side, so hopefully everybody will be okay.  It's just a case of, there's a
gossip-sharing protocol between different nodes, and CLN was kind of forcing it
down LDK's throat.  They were saying, "Oh, no, you have to take our gossip", and
LDK was set up by default to not accept it, and this was causing disconnects
between the nodes.  So, now LDK has changed their implementation so that they
will accept the gossip from CLN and just throw it away, that's their temporary
fix, and CLN is now looking at updating the spec to allow LDK to tell them they
don't want the gossip.  So, again, it's just a little issue and it's been fixed
on both sides now.  So, that's good.

**Mike Schmidt**: You mentioned the change to the spec.  It looks like Rusty has
that open PR for the sort of BOLT cleanup PR, and that includes some additional
feature deprecation as a result of this discussion; did I get that right?

**Dave Harding**: That is correct.

_Bitcoin Core 27.0rc1_

**Mike Schmidt**: Bitcoin Core 27.0rc1.  We've talked about this the last couple
weeks.  We were fortunate enough to have one of the authors of the suggested
testing topics for 27.0 on a few weeks ago.  I think that might have been #295,
so if you want to jump into the details there, that is the best place to do it.
Anything that you'd add here Dave?  Right.  Moving to the Notable code changes
segment of the newsletter this week I'll take the opportunity to solicit any
questions or comments.  You're free to comment in the tweet thread for this
Space, or you can request speaker access and we'll try to get to you by the end
of the show.

_Bitcoin Core #29648_

Bitcoin Core #29648 of the show, removing libconsensus after it was previously
deprecated.  Dave, we covered this a little while ago.  This was #288, it says
in the newsletter.  That seems pretty quick, or maybe you have a comment on when
these changes will actually roll out to end users, as opposed to just a few
newsletters ago.

**Dave Harding**: Correct.  So, when Bitcoin Core does this kind of weird thing
that I haven't seen other open-source projects do, which is when they start
working on a new release, so they're ready to take all the changes they've made
in the last six months and put them in a new release, they fork off that branch
and then continue developing on the master branch.  So, any changes made in
Bitcoin Core this week or the last few weeks, those aren't going to be in the
upcoming version of Bitcoin Core, which is 27; they're going to be in 28.  So,
this change is being made now in the master branch, but it's not going to affect
anybody using Bitcoin Core for at least another six months, if they keep to the
regular release schedule.

So, this is not a sudden change, this is exactly what you would expect.  They
decided that they were going to deprecate it with an announcement in 27 and then
they were actually going to remove it in 28.  And again, one of the reasons this
can move so quickly is because there's apparently nobody who uses it, except for
the Rust Bitcoin consensus library, and they don't use it a lot and they're
happy just pinning to an old version for now.  So, if anybody else is using it,
if you're listening to this podcast and it's really important to you, you still
have plenty of time to reach out to the Bitcoin Core developers, and I encourage
you to do so.  You have a few months, and they can un-deprecate it.  It's just
git revert.

But if not, it's going to be removed, and going forward the project is
continuing to work on separating consensus code from other code in the project
through the Libbitcoinkernel project.  That's different design than the
consensus, hopefully it's a more maintainable design for the project, but it
accomplishes much of the same thing, it's isolating that critical consensus
code, separating it from the less critical code in Bitcoin Core.  So, it's easy
for reviewers to see when consensus code is being changed, and it's easy for
other projects to extract that code out and use it if they want to be completely
compliant with Bitcoin Core.

_Bitcoin Core #29130_

**Mike Schmidt**: Bitcoin Core #29130 adds two new RPC calls, one,
createwalletdescriptor, and the second one gethdkeys.  What do you think, Dave?
Will you break these down for us?

**Dave Harding**: Okay, well these are both related.  The headline one here is
the createwalletdescriptor.  And basically, this is a way of upgrading an
existing descriptor-based Bitcoin Core wallet.  So, when a new protocol, like
taproot, rolls out on the network, people with an old wallet who are using a
previous type of address, for example segwit v0, bech32 addresses, they may want
to switch to the new version.  To do that as a descriptor wallet, you have to
create a new descriptor.  So, this RPC just allows the user to specify what they
want in very easy-to-understand language.  In this case, they just say, "I want
bech32 addresses, I want the new stuff", and the wallet will automatically
create those descriptors and import them and start looking for them, looking for
payments received to them.  It'll allow you to start creating addresses to give
to other people with that thing.

This PR also includes a second new RPC, gethdkeys.  And this is for a case of
descriptor wallets that include multiple HD keys already, so multiple bech32
keys.  If you already have several in your wallet and you're creating a new
descriptor, you need a way to select between those.  So, this RPC gives you a
way to do that.  It allows you to list out the HD keys so that you can say,
"Okay, I want bech32 addresses for this particular set of keys".  It also gives
you a way to get the private HD key.  We don't recommend that.  Taking that key
out of the wallet and using it anywhere can be dangerous.  But if you know what
you're doing and you have some special use case for that, it's a powerful tool.
Previously, you had to back up the wallet and extract the HD key from the wallet
backup.  So, this is a way to do it entirely in RPC.

But yeah, the main thing here is createwalletdescriptor and it's just a way to
upgrade your wallet to the newest, latest and greatest thing.

**Mike Schmidt**: The next five PRs here are all to the LND repository, and I'll
bring on a special guest who has not introduced themselves yet.  Joost, welcome.
Maybe introduce yourself for everybody?

**Joost Jager**: Hey, hi guys, hi all.  Yeah, so I've been working a lot on LND
in the past.  These days, I'm also working on different things,
non-Bitcoin-related stuff, but still working on small projects on the side.  And
this inbound fee project has been running for almost two years now, I think,
since I've opened the PR.  And, yeah, it finally landed, so good opportunity to
talk about it a bit here.

**Mike Schmidt**: Well, thanks for joining us.  Would you like Dave and I to
take these first non-inbound-routing-fee PRs, or do you feel comfortable
speaking to those?

**Joost Jager**: No, yes, please.  I haven't been following those very closely,
I wouldn't be able to comment much there.

_LND #8159 and #8160_

**Mike Schmidt**: Sure.  So, the first two PRs to LND are associated.  It's
#8159 and #8160, and that adds experimental but off-by-default support for
sending payments to blinded routes.  #8159 was titled Preparatory work for
Forwarding Blinded Routes, and #8160 is Support Forwarding of Blinded Payments,
and then we noted also the third of this trio of PRs to LND is Blinded Route
Error Handling, which is still an open PR.  Dave, you may have more to add to
that.

**Dave Harding**: Yeah, so blinded payments were added to the specification a
few months ago.  They're already supported by CLN and Eclair and LDK.  So, LND
is a little bit behind the curve on this, but they are catching up fast.  And
what blinded routes allow you to do is for the receiver of a payment, when they
create their BOLT11 invoice, they can append a blob to it that contains
onion-encrypted routing information for the last few hops to their node.  So,
they give you the path to an introductory node, and they send that to the
sender.  Another sender never knows the node ID of the node receiving the
payment.  So, this is really good for privacy, it's a really nice feature.  LN
still has other privacy issues, but this is closing one of the things, which is
now you just don't need to know exactly who you're signing the payment to.  You
got an invoice and the person that invoiced is willing to accept your payment
and hopefully deliver a service in return for it, but now you just don't need to
know.  So, I'm happy to see LND work on this and it looks like right now it's
experimental, but you can use it right now and there's a follow-up PR for
testing, and hopefully it'll be in the next release or two.

**Mike Schmidt**: We have a topic entry for Blinded Paths and some other names
for it, rendez-vous routing, hidden destinations, and I like to think of it as
PO boxes on LN.  Thanks for summarizing that, Dave.

_LND #8515_

Next LND PR, #8515, updating multiple RPCs to accept the name of a coin
selection strategy to be used by LND.  And then we also link back to Newsletter
#292 for some additional information.  In digging into this, there's three
different configurations for coin selection.  There's largest, random, and
global config, which I think is sort of an ability to specify to use the
default.  Dave, what's LND trying to do here with allowing coin selection
strategies to be input to the RPCs?

**Dave Harding**: Well, there's different coin selection strategies you might
want to use for different network conditions.  For example, largest, I assume
that means it's spending the highest value UTXO that you have, and that's great
for conserving fees.  It means you're adding a minimal number of inputs to your
transaction.  But what it ends up doing is it kind of grinds your UTXO set down
to dust.  As you use the largest ones, you just get smaller and smaller UTXOs.
So, you want to use a larger strategy when fees are really high to save money,
but it will eventually cost you more money in the long term if that's the only
strategy you use.

Random is a very simple strategy.  It just randomly adds UTXOs to your inputs,
and this is kind of consolidating because it has an equal chance of choosing a
large UTXO or a small UTXO.  And so, you'll start to build up larger UTXOs in
your change outputs from using this strategy over time.  So, that's more suited
to times when the fees are lower.  And I assume eventually, LND plans to add
additional coin selection strategies and possibly for that default strategy,
they'll look at the network conditions and try to guess which strategy to use to
optimize for the user's goals.  Bitcoin Core already does this.  We discussed
that I think last week or two weeks ago when a coin selection strategy, a new
one by Murch, was added to Bitcoin Core.  And this is just how wallets, I think,
are going to be designed in the future.  They're going to have a variety of coin
selection strategies and they're going to have a heuristic for choosing between
them to try to best match the current network conditions to reduce the user fees
both today and also in the long term.  So, this is just good progress, I think.

_LND #6703 and #6934_

**Mike Schmidt**: Next two LND PRs are by Joost, #6703 and #6934, adding support
for inbound routing fees.  Joost, I think this might be the largest PR-related
writeup that we've had ever on the newsletter, so there must be something
interesting going on here.  Maybe you want to introduce the idea for us.

**Joost Jager**: Okay, that's a great introduction.  I guess we should start
with reiterating the billing model of routing nodes, that currently routing
nodes receive a compensation for forwarding their payments.  The model that they
use to calculate what the fee will be is only based on the destination of the
payment, the next hop in the path.  So, it doesn't matter from which node the
routing node receives the payment, it's all equal, it can only set a fee based
on the outgoing direction.  And it has always been like that, at least since I
joined in 2017, it was already like that.  I don't know if there's any more
history.  Probably the thinking was at that point, someone hands you a Hash Time
Locked Contract (HTLC), it doesn't cost you anything.  So, the charging happens
on the outbound side, where the routing node is actually locking up their own
capital.

Yeah, seems to make sense, but still there were routing node operators asking
for the option to differentiate more, to differentiate also based on the
direction from which the payment comes in.  And what these two PRs do is that
they add experimental support for this.  So, if you're running LND with those
two PRs merged in, so that will be the next release of LND, 0.18, then you will
have the option to not only set the outbound fee for each channel, but in
addition to that, for each channel, you can also set an inbound fee, and that
inbound fee will be charged if a payment arrives through that channel.

**Mike Schmidt**: Joost, maybe walk through why a node operator would or would
not do something like this.

**Joost Jager**: Yes, this is just such a great question because what I've
noticed within myself and also with other Lightning devs is that there is a bit
of a gap between the experiences that you gain as a developer for the LN and the
experiences that a routing node operator gains.  They are in this game where
they set their fees, where they are rebalancing, they do all kinds of things,
and the exact dynamics there are not that easy to intuitively get as a
developer.  As a developer, it's just providing the basic building blocks for
them and they just optimize whatever way they think is best.  So, I've been
struggling myself also a little bit with coming up with examples why would this
be useful.  It seems there was a demand, people asking for this, but then
understanding the exact use cases and also in combination with, are these use
cases actually going to benefit the network, yes or no, it's actually quite
complicated.  But one very simple scenario that I always keep in mind is the
following.

So, suppose there is Alice, Bob and Carol, and Alice and Carol are sending each
other money through Bob, and this is perfectly balanced.  This is the ideal
world for Bob because he has his two channels, and traffic goes back and forth
all the time.  It could be millions of payments every day, and for every
payment, he earns a fee.  So, his costs are very low, and he could charge a low
fee for that service.  If the situation is that all the traffic is
unidirectional, so let's say Alice always sends to Carol through Bob, what
happens then is that at some point, the channel between Alice and Bob will be
depleted, and Alice might close the channel and just open a new one.  So, over
time, Alice might be opening new channels over and over and just pushing the
balance out to Bob.  Bob with Carol also has a channel with a limited capacity.
So, Bob will also be forced to do this, to keep closing and reopening new
channels.  So, the cost in this scenario for Bob is much higher.  And this is
how I think about this.

If you're a routing node and there are peers that keep each other balanced and
they don't cost you any chain fees, you can use a low fee for forwarding their
payments.  But if there is another source that is much more single directional,
then you cannot really differentiate.  So, at that point, you've got two
options.  Either you charge a higher fee for everyone to cover the scenario
where you need to close and open new channels, or you just close the channel to
peers that are not as much in line with your desired traffic shape.  So, with
this change, what can routing node operators do with this?  With this, they are
able to distinguish between those two cases, and they can, across the board,
lower their fees and/or accept more peers than they might do currently, just
because some of those peers might not match the desired traffic profile that
they're looking for.  And the end goal of all of this is, of course, to make
Lightning cheaper.

**Mike Schmidt**: Dave, I'm going to turn the questioning over to you.

**Dave Harding**: Okay.  Well, I first want to apologize both to Joost and to
our readers.  The reason this is a really long item in the merge summaries
section is because I failed to cover it back when Joost brought it up on the
mailing list about two years ago.  I actually went back to try to figure out
what happened, and that would have been covered in Newsletter #207.  And we
actually covered a different routing fee discussion back then by the developer,
ZmnSCPxj.  And so, I'm just really apologetic here to everybody; we should have
been covering this earlier.

So, two of the pieces of feedback when I was looking into this and writing up
this summary, two of the pieces of feedback I saw from other developers were,
first, Bastien was concerned that this really isn't the right role for, say, Bob
in this case is deciding how much Alice should be paying to route through his
node.  He really felt there should be, as you said as there is in the original
protocol, a clear separation of concerns here.  And I was trying to think
through his point, and this is not his point, this is my summary of it, but
basically Alice can offset any change Bob makes with this protocol.  So, if Bob
decides to use the inbound routing fees to lower the cost of going, say, from
Carol to Alice, Alice can raise her costs and actually capture more fees if she
believes that she has the right strategy.  So, I think this only works if Bob is
addressing somebody who's doing a poor job of managing their channel and doesn't
believe in what they're doing.  If the person believes in what they're doing,
they can offset any change made by Bob.  Is that correct; is that how you view
Bastien's concerns, Joost; am I summarizing that correctly?

**Joost Jager**: Yeah.  I need to go back a little bit in time to those
discussions, because they were quite heated at some point.  I understand the
point that he's making, like say it's not up to you to decide who's going to
send you an HTLC.  But then I'm just wondering, what is then the solution for
the problem I tried to explain, where a routing node operator either needs to
raise fees for everyone or just decline connection requests from certain nodes.
And I wouldn't say those are nodes that are poorly managed, because it's just
the case that there are nodes that are just sources of payments.  So they are,
by definition, unbalanced, but not necessarily poorly managed.  Of course, in an
ideal world where the whole economy is within the LN, everything might be
balanced, but that's probably a long way off.  So, I would try to avoid labeling
those nodes as poorly managed.

**Dave Harding**: Sure.  Yeah, and it seemed to me like the only solution he
presented in the arguments that I saw, and again I don't want to stand for his
opinion here, just what I read, was just closing the channel.  And I do think
that having another tool in the toolkit before closing a channel is probably a
good idea.  So, I thought this was a good idea, but maybe I don't completely
understand his concerns there.  And the other developer feedback came from Matt
Corallo, and he preferred a different mechanism for accomplishing the same
things.

So, as I understand it, the way this PR to LND works is that you're sending out
an extra field in the channel gossip message that says, "Hey, I'm going to be
charging", or in the default case in the initial implementation, "offering a
refund on routing fees on the inbound side".  And so now the spender, when they
create their onion-encrypted packets and they tell each hop how much to forward
to the next hop, say Alice is forwarding to Bob, they tell Alice to forward less
to Bob than would normally happen with non-inbound routing fees in this initial
case, where it's only going to be discounts.  And Matt preferred a solution
where instead of having the sender decide how much they're going to send, have
the sender send the original amount that they would send, but have Alice and Bob
negotiate with each other, as peers, an alternative inbound routing fee that
would be applied at the point the HTLC was committed.

It seemed to me that the advantage of the approach that LND is taking now is
that any nodes that adopt this, senders can adopt it, so it's kind of
sender-driven, whereas the approach that Matt was taking would be peer-driven,
so it would require your peers to update rather than the senders.  The advantage
of Matt's approach is that it wouldn't require a new gossip message, it wouldn't
require advertising this, it wouldn't require tweaking it in a global setting,
it could be changed by peers very quickly in a non-public way.  So, I felt like
there was a good set of trade-offs there.  And when we see trade-offs, there's
not necessarily a right answer there.  But I just thought that was an
interesting difference of approaches.  I didn't know if you wanted to comment on
that.

**Joost Jager**: Yeah, definitely interesting alternative approach.  I also have
been looking into this quite a bit up to the point to even prototyping it in LND
just to see how things work out.  I think about one functional difference though
with the PRs in LND that have emerged recently, and the difference is that if
you just negotiate between the peers, the sender, on a very small scale, doesn't
really know whether the next peer is the exit, the final hop.  So, the final hop
is also going to charge the inbound fee there, and in the LND proposal
currently, the final hop does not charge an inbound fee.  And you wouldn't
really be able to do this in Matt's proposal, because the penultimate node
doesn't really know that the next one is the final one, for privacy reasons.
So, there's a functional difference, but other than that, I think different
trade-offs and needs sort of aiming for the same thing.

But I felt that it did get a little bit messy with two nodes negotiating this
local extra fee that the sender part of that pair of nodes needs to work into
the advertised outbound fee.  But it's definitely true that for that, senders
don't need to do anything and the peers need to upgrade barriers.  In this
proposal, the senders need to upgrade.

**Mike Schmidt**: One second, we're adding Dave back here.  Sorry, Dave, I think
you're back.

**Dave Harding**: Thank you for that explanation.  And one of the things I would
add there as a note is that I think it's possible to do both approaches.  If
uses on the LND side take off and the other developers decide that they would
prefer to go with max peer-to-peer negotiated inbound fees, it's possible to do
that in parallel and ultimately to switch to it, or to continue using both sides
in parallel.  So, I think overall, this is just an interesting addition of
features to the network and we're basically just going to have to see what
happens.

**Joost Jager**: Yeah, that's exactly it.  It's difficult to predict how this
works into the current dynamics in the LN.  It's very implemented and very
optional, so a relatively safe way.  Cases such as global negative fees, things
like that, are all not possible in the current implementation, just to make the
delta as small as possible and still try to get this practical feedback from
routing nodes to see how this works for them.

**Mike Schmidt**: Joost, thanks for joining us and thanks for hanging on till we
got to this portion of the newsletter.  Anything else you'd say before we move
on?

**Joost Jager**: No, that's all.  Thanks for covering this one.

_Rust Bitcoin #2652_

**Mike Schmidt**: Thanks, Joost.  Rust Bitcoin #2652, which changes what public
key is returned by the API when signing a taproot input as part of processing a
PSBT.  Dave, from the quote you have in here, it sounds like people were
expecting a different public key being returned, which is potentially
technically incorrect, but now Rust Bitcoin has changed to returning that value
within the API.  Maybe, is that right, or correct me where I'm wrong here?

**Dave Harding**: I'm going to confess that I'm honestly a little confused what
was happening before and what is happening now.  So, I'm just not going to
comment on it, sorry!

**Mike Schmidt**: Well, if folks are curious, they can jump into this #2652 PR
on the Rust Bitcoin repository, which is part of a bigger project and there's a
series of commentary there.  So, you're on your own for this one, guys, sorry!

_HWI #729_

Last PR is HWI #729, which we covered earlier in the segment on HWI 3.0.0 being
released, so I don't think we need to rehash that here.  I do not see any
comments or requests for speaker access.  So, Dave, any parting words?

**Dave Harding**: Thanks for reading and thanks for listening.

**Mike Schmidt**: Yeah, thanks to all our special guests this week.  We had
Chris Stewart on, we had Kulpreet , we had Jameson and Joost, and thanks to my
co-host this week, Dave Harding.  See you all next week.  Cheers.

{% include references.md %}
