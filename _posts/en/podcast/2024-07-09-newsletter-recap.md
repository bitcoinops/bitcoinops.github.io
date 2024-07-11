---
title: 'Bitcoin Optech Newsletter #310 Recap Podcast'
permalink: /en/podcast/2024/07/09/
reference: /en/newsletters/2024/07/05/
name: 2024-07-09-recap
slug: 2024-07-09-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Antoine Poinsot and Elle
Mouton to discuss [Newsletter #310]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-6-9/382836441-44100-2-1d99dcefb994e.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #310 Recap on
Twitter spaces.  Today we're going to be talking about some vulnerabilities in
Bitcoin Core that were recently disclosed, BOLT11 invoice field for blinded
paths, and our usual Notable code and Release segments.  I'm Mike Schmidt, I'm a
contributor at Optech and Executive Director at Brink funding open-source
Bitcoin developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin stuff.

**Mike Schmidt**: Antoine.

**Antoine Poinsot**: Hey, I'm Antoine Poinsot.  Well, I work at Wizardsardine on
Bitcoin stuff too.

**Mike Schmidt**: Elle?

**Elle Mouton**: Hey guys, I'm Elle and I work on LND at Lightning Labs.

**Mike Schmidt**: Well, thank you both for joining us to talk through your
respective news items that we covered in #310 this week.  We'll jump in in order
and, Elle, hopefully you can hang on, there's actually one of your PRs later in
the newsletter as well.

_Disclosure of vulnerabilities affecting Bitcoin Core versions before 0.21.0_

First news item, Disclosure of vulnerabilities affecting Bitcoin Core versions
before 0.21.0.  Antoine, you posted to the Bitcoin-Dev mailing list a link to
your, well I guess it's not your, but I think you drafted the announcement of
ten vulnerabilities affecting older versions of Bitcoin Core.  Before we try to
summarize briefly each, maybe give the audience a big-picture take on what's
going on and why it's going on now.

**Antoine Poinsot**: Well, what's going on is that the Bitcoin Core project is
finally going to keep better track of disclosed vulnerability in the software
and follow a standard process to publicly disclose them.  Yeah, and why now?
Just as with anything else in Bitcoin and Bitcoin Core, especially because
people volunteered to do it, because it was seen as a priority by some of us,
with us being the Bitcoin Core contributors.  So, a subset of the Bitcoin Core
contributors got together and started discussing, it was almost a year ago in
September, what could we do better about vulnerabilities management and about,
it all boils down to being better at securing the Bitcoin Network, securing by
making sure that, or trying to avoid bugs, more bugs, more security-critical
bugs in Bitcoin Core in the future, and also about the public perception of
Bitcoin Core as a software, which turns out has sometimes security-critical bugs
and needs to be updated.  So, both of these things are achieved by starting to
more regularly, and with more standard process for transparency, disclose the
vulnerabilities in Bitcoin Core.

Hopefully, it will push people to upgrade the Bitcoin Core nodes and hopefully
it will help us, the technical community and contributors to Bitcoin Core, from
learning from the past mistakes and securing their developments in the future.

**Mike Schmidt**: And as part of that, we discussed Bitcoin Core's new
disclosure policy in Newsletter #306 and Podcast #306.  Maybe a quick question,
do you have any follow up to that policy, maybe any common objections or
misconceptions to the policy that you'd like to address?

**Antoine Poinsot**: Well actually, and surprisingly, because I was expecting a
harsher response from the Bitcoin Twitter crowd, we had overwhelmingly positive
feedback on the initiative basically around the theme that, yeah, well we're
trying to make the things more secure for users and they were generally happy.
Back when I started sharing more publicly a gist of the working group on this
topic with the Bitcoin Core team, and it ended up being discussed on Twitter,
some people, yeah, well there was two nonsense reactions.  One of them was,
"Yeah, whatever, Bitcoin Core is dead".  And this one is like, if you don't want
to believe there is vulnerabilities in Bitcoin Core, you might as well stick
your head in the sand and -- I don't know.  And the other one was, "You should
just be releasing vulnerabilities as soon as a fix is available", which is also
insane because after all, as with everything else in Bitcoin, we're playing with
other people's money, and we can't just, as soon as we are ready with the fix,
make public vulnerabilities which put users at risk and potentially their money,
or the network, or the usability of their money, if it can crash a large part of
the network.  Well, it depends on the vulnerability itself, but disclosing
immediately is just absolutely inconsequential.

So, yeah, that was the two main bad responses that we had, and it was a very,
very small minority of people who apparently did not know what they were talking
about at all.  And most people were pretty positive about it, so that's really
encouraging as well.

**Mike Schmidt**: And now there's this backlog of previously fixed
vulnerabilities, and that's what we covered this week, is ten vulnerabilities in
Bitcoin Core before version 0.21.0.  There's ten here, there's a couple
sentences in the newsletter summarizing each one.  Antoine, do you think it
would be productive to go through these ten or what do you think?

**Antoine Poinsot**: I'm fine with going through them.  Just let me remind
myself.  Maybe we can pick a couple ones which could be interesting of what's
possible?

**Mike Schmidt**: Sure.

**Antoine Poinsot**: But what's possible?  So, starting from the website
Security Advisories page, the Bitcoin Core website, I'm going to comment here.
I'm comment on the space.  So, the first one is fun.  The first one is about
BIP70, which was a protocol for direct connection between a merchant and the
buyer to sell goods in Bitcoin, and you had some sort of direct connection and
it was a bit -- I don't know the details of the BIP70 protocols, but a lot of
people had a lot of issues with it.  Turns out it had security issues as well.
It changed the URI for Bitcoin addresses to receive payments when the merchants
would display the QR code or share the URI, so that it extends it with actually
a URL or URI where you can download the payment data to the payment request.
And there was no bounds on the thing which would be downloaded.  So, an attacker
could just share a URI with a link to a website, which would make the wallet of
the other person just download a very huge file, which would be kept into memory
by the software, by the Bitcoin Core software until it crashed.  Because a
software, when it tries to allocate too much memory, more memory than there is
in the system, the kernel, which manages the system resources, is going to kill
the process.  So it would just crash Bitcoin Core.

Then, sorry, I'm not on Twitter anymore, I'm on the website, so cut me if I'm
taking too long.  The next one is, yeah, the next one is not so bad.  It's that
sending a getdata, a specific getdata for an unknown type, would make the
software basically go into an infinite loop.  But this infinite loop would be
only in a single thread that the software is using to talk to its peers, which
would have multiple threads to talk to multiple peers and manage multiple
messages at the same time.  So, that's not the end of the world.  Basically only
one thread is going to use all its allocated CPU resources, but the node would
not crash and the node would still make progress as it would still receive
messages from other peers.

Then there is the, oh yes, well, this one is bad, worse.  It depends on
basically what you assume from an attacker.  So, the third one, still on the
websites list, if you're just joining now, the third one is about DoSing, again
by memory, a node with very low-difficulty headers.  So, as you know, you can in
Bitcoin send chains of headers to nodes, and it would start following the valid
chain with the most work.  You can also send a chain from earlier blocks, right?
You can announce forks because forks happen, it's just the nature of the
decentralized system.  So, it's possible to create chains from back from the
genesis block, the Bitcoin genesis block.  However, the software would refuse
them because in Bitcoin Core, we still have in place the checkpoints, which were
put a long, long time ago.  I think the last one is more than ten years old.  At
least back in 2013, the hashrate needed to create blocks, and therefore a valid
header chain, was too much for an attack to take place by crafting a very, very
huge chain, which would take too much memory for the node to process.

Unfortunately, the check that the chain should have to be forked after the last
genesis block was removed during the refactoring in one of the Bitcoin Core
versions, and it was only put back in place a few versions later, I don't
remember exactly which one.  And so, it was possible for an attacker to craft a
huge chain of millions of blocks and send it to a node, but these blocks would
take no power to create because there would be a difficulty 1 since the chain is
crafted on top of the genesis block.  So, you would have tons of low-difficulty
headers that the node would have to process and store in memory, and at some
point it's just too much, and it was too much memory, and it would crash.

Then, due to malicious P2P messages -- well, I'm not going to go through every
single one of them.  Then the next one, the disclosure of memory DoS due to
malicious P2P messages, is similar but with a much smaller impact.  The next one
is, well, I find all of them interesting, so just cut me if I'm taking too much
time.  So, the next one is the disclosure of CPU DoS/stalling due to malicious
P2P message.  In this case, what the attacker would do -- well, the issue here
is that a Bitcoin node could receive unconfirmed transactions for which it has
not yet received the parent's transactions.

So, let's say I'm a Bitcoin user, I use a wallet, I make a transaction A.
Before it confirms, I make transaction B, chaining on top of the change output
that I got in transaction A.  Both transactions are going to relay on the
networks, and maybe one of the nodes is only going to hear about transaction B
before it hears about transaction A.  In this case, nodes have a small cache for
what we call orphan transactions because we don't know about the parent yet.
And when receiving any transaction, the node would look through its cache of
orphan transactions and see if the newly received transaction actually allows it
to make an orphan not anymore an orphan, to pick one of the transactions,
because it could be the parent of one of the transactions in the orphan cache.

The resolution of the orphans is quadratic and you could fill the cache with
expensive-to-validate-and-confirm transactions, and make the node receive
similarly long-to-validate transactions, such as the node will go through in a
quadratic manner its orphan cache revalidating every transaction every time, and
it could stall the node for up to 19 hours at a time.

**Mike Schmidt**: Antoine, we've gone through five here and I think we hit a
low, a medium and a high.  Can you comment just maybe briefly on how you think
about low/medium/high vulnerabilities?

**Antoine Poinsot**: Yeah, sure.  Thank you for cutting me.  For
vulnerabilities, you always think in terms of the impacts of the bug, what are
the consequences of triggering the bug?  Can it lead to losing funds; can it
lead to a chain split; can it lead to a crash of the software?  And you weigh it
against the ease of triggering the bug, the ease of exploiting the bug.  And so,
we have three types of vulnerability, but really we have four.  It's just that
the highest of the type of the severity levels is critical bugs, such as the
invasion bugs, for instance, which happened in the past.  For these types of
bugs, it's basically pointless to have a standard disclosure, or it would be
much more involved to think through what should be the standard process for such
bugs.  And we estimated that at this point, it's such a low percentage of the
bugs affecting Bitcoin Core that we should just face the fact that such bugs
will be treated ad hoc and focus on the three other levels.

So, we have low bugs.  These bugs either have a very low impact on the nodes of
the person running it, or are very, very hard to exploit.  So, the example that
I give on the page is a wallet bug, a Bitcoin Core wallet bug, which would need
the attacker to actually have physical access to the victim's computer.  In our
case, it's like a very high bar to meet to exploit the bug, and we would call
that a low-severity bug.

We have high bugs.  For high bugs, it would be a remote crash, for instance,
like anyone on the internet can just connect to your node and crash it.  That's
pretty bad, especially if you take into account the second-order consequences,
like maybe you have an LN node on top of your Bitcoin Core node.  If I can just
go and crash your Bitcoin Core node every time it starts up, you won't be able
to broadcast your Hash Time Locked Contract (HTLC) transactions in time, or even
maybe your (inaudible 16:55) transactions.  Although, the line is more blurry
because at this point, even if it's two weeks, you probably notice that your
Bitcoin Core node has been down for two weeks.  But still, it's pretty high.

Then we have everything in the middle, which we call medium.  It could be a
high-consequences, high-impact bug, but which is pretty hard to trigger, or the
opposite, a very simple but low-consequences bug.

**Mike Schmidt**: Thanks for diving into that.  Of these five remaining ones, do
you have a couple of favorites that you'd like to highlight?

**Antoine Poinsot**: Let me think.  No.  I think, well, there's the RCE.  The
RCE through miniupnpc is probably my favorite of the batch.  An RCE is a remote
code execution.  An attacker could execute codes on your machine.  At this
point, it's game over because it could lead to anything.  And this was triggered
because Bitcoin Core, for using the UPnP protocol, which is used to make a node
available to the wider intranet even if it's on a local network behind a NAT,
behind a router, uses the UPnP protocol; because we're not going to implement
the whole UPnP protocol in the Bitcoin software, and people have already
implemented it, we're using a library which is specialized in doing that.  This
library is called miniupnpc and is maintained occasionally only by a single
person and has bugs regularly.  And the RCE originates from this library,
basically.  This library had a buffer overflow which was found by a security
company. Wladimir van der Laan investigated the consequences of this buffer
overflow for Bitcoin Core and found a second buffer overflow in the same
library, and the combination of both could have led to an RCE in Bitcoin Core.

I feel like it's a good cautionary tale with regard to the dependencies to use
in a Bitcoin software, because you basically always increase your attack
surface.  And it's been a large goal of the Bitcoin Core project to try to
reduce this attack surface over all the years.  So, yeah, that's my favorite, I
would guess.

**Mike Schmidt**: We noted in the newsletter that additional vulnerabilities
fixed in Bitcoin Core 22.0 would be announced later this month, and
vulnerabilities from 23.0 would follow next month.  Any comment on that, Antoine
or Murch?

**Antoine Poinsot**: Yeah, upgrade your nodes, please.  Well, maybe not you guys
who are listening to this podcast, I guess it's pretty niche already, but try to
spread the word that people should really upgrade their nodes.  Yeah, I've seen
a lot of people on the network upgrade to a load, being like, I don't know,
about 1,000 nodes upgraded to 0.21 since the release last week, but 0.21 is
still ancient

and still has bugs which will be announced at the end of the month and is going
to be publicly vulnerable.  So, people should really upgrade to maintain the
version, so at least 25.2, or just use the latest version, 27.1.

**Mike Schmidt**: Murch, anything on these individual disclosures that you'd
like to jump into, or more broadly, philosophically speaking?

**Mark Erhardt**: I just had the idea to pull up Bitnodes' user agent chart, and
I was looking, and there's currently, according to Bitnodes, 2,500 nodes that
predate 22.  So, all of those would be vulnerable to some of the disclosed bugs.
And there is over 1,000 22.0 nodes.  So, yeah, I think there's a few people that
even run listening notes that might want to look into updating.

**Antoine Poinsot**: Especially your listening notes, right, because you're
basically opening up to the world being like, "Hey, crash me".

**Mark Erhardt**: Was that a hint at a crash bug being disclosed?

**Antoine Poinsot**: No, I mean it's just a typical bug that you would find.
Let's wait for the announcement at the end of the month.

**Mark Erhardt**: Sorry, I was just teasing.  I have no information, I don't
know what's in there.

**Antoine Poinsot**: Antoine, thanks for walking us through those and explaining
the severity levels and explaining the policy and some weak objections to it so
far.  I guess we will potentially be having you on later in the month and next
month to talk about some more of these.  Thanks for joining us.  You're welcome
to stay on, or if you have other things to do, you're free to drop.

**Mark Erhardt**: Actually, we are talking about the miniscript BIP later.  If
you do want to mention or talk about that, that would be perhaps interesting
too.

_Adding a BOLT11 invoice field for blinded paths_

**Mike Schmidt**: Awesome.  Second news item this week, Adding a BOLT11 invoice
field for blinded paths.  Elle, you posted to Delving Bitcoin a post titled,
"bLIP: BOLT11 Invoice Blinded Path Tagged Field".  I wanted to quote a sentence
from that post that I think summarizes the idea, and then I'll let you take it
from there, "Blinded paths themselves are a useful tool for privacy and
potentially more reliable payment delivery, and so this document proposes a
carve out to the existing BOLT11 invoice format, so that advantage can be taken
of the blinded paths protocol in the context of payments in a sooner time
frame".  Is that a fair assessment of the idea, Elle, and do you want to
elaborate on that and talk through the motivation?

**Elle Mouton**: Yeah, sure.  Yes, I think that is a fair assessment.  And,
yeah, basically the tl;dr is that blinded paths are awesome, and I think it's
going to just, like you said in that quote, it's going to first of all give
receivers more privacy.  I also think it's really cool that I think it has the
possibility of making payments more successful, like increasing the success
rate, just because now the receiver also has a say in which paths the payment
can come through via.  So, that's pretty cool because it'll have more
information about the liquidity on its side.  So, yeah, that's really cool and I
think all the implementations support route blinding now, so everyone's kind of
ready.

So, it'd be really cool if we just start using it and get a feel for it, because
we want to give people the opportunity to use it, we can see what's wrong,
there's a lot of unanswered questions such as like, what's a good number of
paths to give someone; what's not probable; how many dummy hops to add; all
these things, so we want to get a feel for it.  And BOLT11 already has tagged
fields, so it's not really a carve out actually, it's just like adding a new
tagged field, is what they're called.  That allows us to use this today without
doing the whole BOLT12 thing immediately to take advantage of route blinding,
because route blinding really is, by itself, its own thing.  So, yeah, that's
kind of it.

**Mike Schmidt**: Elle, you touched on some of the benefits of route blinding,
blinded paths.  Maybe how would you define that for the audience?  How should
they think about what that is?

**Elle Mouton**: Okay, so basically today, when you want to receive a payment,
you basically reveal exactly where you are in the network.  So, you give your
real node ID, and with that node ID people can look up in their channel graph,
"Okay, this is where you are, so these are your channels".  And even if you
don't have any public channels, you give hop hints, which basically do tell the
person who's going to be paying you exactly which UTXOs on the network belong to
you, because the hop hints give that away.  So, you really do give quite a bit
away.

So now, with route-blinding, you kind of give a pseudo-path to yourself.  So,
you can make it as long as you want even, you can have dummy hops or whatever,
but you basically don't reveal your real node ID.  And you can choose an
introduction node that is going to be a public node, and then let's say that's
like five hops away from you.  Now, you kind of blind each of those public keys
in that path to yourself, and you give the receiver that blinded path, is what
it's called, and the receiver will send to this path just like it sends to any
other node today, except it's just going to assume that those nodes are real
nodes, the public keys won't mean anything.  And then, once the introduction
node gets that HTLC and the onion, only it will be able to reveal, "Okay, this
is the actual next node that I must pass this onto", which the sender won't
actually know about.  Then eventually, the payment will get to you.  In that
way, you can increase your anonymity sets and hide exactly where you are in the
network.

**Mike Schmidt**: And, we're talking a little bit in this writeup about BOLT11
and BOLT12.  Was the intent for blinded paths to be used with BOLT12, and now
you're putting it in for consideration to also be used in BOLT11 invoices?

**Elle Mouton**: Yeah, exactly.  So, I think in BOLT12, blinded paths will be
sort of native to BOLT12.  So, BOLT12, there's no such thing as hop hints or
anything in BOLT12.  The way we're going to reveal where we are in the network
is via blinded paths, so that's awesome and that's great.  But it's its own, so
you don't need BOLT12 to have route blinding.  So you could just, as an initial
step, you could just have route blinding, and then you can have BOLT12 which
uses that.  This is just like, cool, let's make incremental steps, let's start
using this immediately because BOLT12 required a big thing to go implement, and
it requires a networkwide upgrade, because now you have to do onion messaging
and fetch invoices across the network and all these things.  So it's like, why
not take this initial step and immediately get the benefits of route blinding.

So many wallets and things today already support BOLT11 invoices, right?  And
BOLT11 invoices have feature bits in them.  So, if that array of feature bits
has this new feature, but that will indicate, "Hey, this has a blinded path in
it", the wallets will be able to go, "Okay, I understand this is a BOLT11
invoice, but it's got a feature that I don't understand.  Please ask the wallet
developer to go understand this feature".  Whereas there's no immediate way
today for -- there's no BOLT12 invoice encoding yet.  We could do that, we could
totally do that, but this is just like a nice first step, I would say.

**Mike Schmidt**: That's a good segue to one of the points that I wanted to
tease out of the discussion, which is I guess an objection.  Maybe it's an
objection, but that this incremental approach that you mentioned may result in
the burden of supporting those incremental states.  And then also, I guess
related to that objection, is that maybe offers take longer to get rolled out
now because people are using BOLT11 with these blinded paths, there's
implementation there; maybe focusing on offers would be a better approach.  How
do you think about that rationale?

**Elle Mouton**: Yeah, I guess I just don't think the overhead of going and
understanding this one extra tag field is very big.  So, for example, I've been
working on the route blinding receiving code in LND.  And so, LND has full
support for BOLT11 invoices.  So, all I really needed to go do is add this one
new extra field plus a feature bit, and then everything else can remain exactly
the same and exactly how it is today.  If I was to go and add the BOLT12 invoice
encoding, it would be quite a big job, or rather just a much larger job.  And
so, yeah, nothing against eventually doing that, it's just this allowed us to
make this available to people.  It allows us to make it available to people very
fast and I don't think it's a huge overhead.  So, yeah.

**Mike Schmidt**: Maybe comment on the fact that this is a BLIP spec and not
something that would be going into the BOLT, and what the bar would be for
implementing a BLIP versus a BOLT?

**Elle Mouton**: Right, so yeah, this is a BLIP meaning we're just kind of
saying, "Hey, this is something we're going to do.  You don't have to go
understand this to be able to use BOLT11 invoices and things".  And the idea
just being is, I think it's quite well known that other implementations won't go
implement this.  So, it's kind of just our way of saying, "Hey, listen, we're
going to go do this, and it's fine because it's kind of really just end to end".
So, it'll be the receiver and the sender who will need to be aware of this new
format, and it's just because the end goal really is to have the whole flow be
within the network BOLT12.  And BOLT11 in general is just a worse format than
the BOLT12 invoice format, which is just better in so many ways.  So, let's
still make that the goal, and therefore it's like, okay, this is kind of a
temporary thing, it's probably only going to be LND, it seems, that's going to
be implementing this, so why go and put it in the spec?  Because the spec to me
should be like, "Okay, these are the things you must understand for Lightning to
work", and this is not one of those things.  So, you could even think of it as
just a temporary thing we're doing for now to let people use it immediately, and
it doesn't need to be part of the main spec, because eventually really blinded
paths will be used in the context of offers and BOLT12.

**Mike Schmidt**: Murch, Antoine, I've been monopolizing the discussion.  Do
either of you have a question or comment for Elle?  Murch with the thumbs up.
All right.  Elle, what would the call to action be for the audience here?  Do
you have some parting words for everyone?

**Elle Mouton**: Yeah, I guess.  So, hopefully we can get this into LND very
soon.  And then really, the call to action there is just for people to really
start using it, because blinded paths are only useful if the paths are not
probable, right?  We really don't want to be able to give away where the
receiver is.  So, it'll be great if people can use it, go see, "Hey, listen, let
me try and create invoices where I have five dummy hops and only one
introduction node versus five introduction nodes.  Maybe it's really easy to
find where you are if you have five introduction nodes".  So, just to get it so
that we have more of a bigger sample space of people using this, so we really
get an idea of, okay, these are the right parameters to use.

I also think there should be a larger discussion amongst the implementations
about what these parameters should be, because if we all use different values,
then it's going to become very probeable; because if LND always uses three dummy
hubs and other implementations use five, then it's going to be very, very easy
to probe out where you are in the network.  So, I think people should just go
use it as soon as possible, I think, and get a feel for it.

**Mike Schmidt**: Thanks, Elle, for joining us and walking us through that.

**Mark Erhardt**: Maybe now I have a pointy question after all.  So, as the
idiom goes, nothing lasts longer than a provisional solution.  And I kind of
want to echo some of the points brought up by other people that discussed there.
I think it's a good thing to get more work into a hidden path, but I'm
sympathetic to the concern that rolling it out and trying to optimise the
parameters now, in the context of BOLT11, might delay the implementation of
BOLT12 support.  So, I mean you kind of addressed it already, and it's a hard
point to answer, but I also wonder whether just not adding it to BOLT11 might
actually be a conscious choice to keep the motivation to do BOLT12 high.

**Elle Mouton**: One thing I just want to point out is, figuring out which
parameters work best for route blinding will help in both the contexts of BOLT11
and BOLT12, it doesn't matter how they're used.  So, yeah, us getting more
familiar with how successful they are now and choosing the parameters to make it
the most successful isn't going to take time away from -- we're going to have to
do that anyways.  And I think it's also like, right now if we use it in the
context of BOLT 11, it's just in the context of payments, right?  In BOLT 12,
it's then in the context of fetching the invoice, because that's also going to
be done through a blinded route, and then payment.  So then, I feel like the
sooner we can get our hands on using it, the better it is for that too.  And I
really don't think this delays LND's progress in terms of implementing BOLT12,
because it really was just, "Hey, let's implement the receive logic for blinded
paths and, hey, we can just add this really, really quick carve out to BOLT11 to
make it available today", and I think that took less than half an hour to just
add that little extra bit.  So, I don't think it takes away from the speed at
which we'll implement BOLT12.

**Mark Erhardt**: Are you worried at all that that will balkanize the LN a bit,
because you want LND nodes to start using it as quickly as possible, but the
other implementations have already declared that they won't implement it; the
other implementations will not be able to pay to LND nodes anymore?

**Elle Mouton**: Spicy question!  I still think they should consider maybe just
implementing it because again, I think it'll be good for the overall network if
people can just get a feel for route blinding and let's get it into practice.
And even though the end nodes will still be LND if only us implement the invoice
thing, if an LND node is connected to a Core Lightning (CLN) node that's
advertising route blinding, we'll still be using that node within the path, and
so we'll still be exercising route blinding within the network.  So, hopefully
it will still be a good thing for everyone.

**Mark Erhardt**: Thanks for taking my questions.

**Elle Mouton**: No problem.

**Mike Schmidt**: Elle, are you able to hang on for this PR later?

**Elle Mouton**: Yeah, sure.

_Bitcoin Core 26.2rc1_

**Mike Schmidt**: Great.  Releases and release candidates, we have one that's
been on for a couple of weeks here, Bitcoin Core 26.2rc1.  Antoine, we've been
telling everybody just to test it.  Is there anything else you'd call out in
this RC for the audience?  I guess same question to you as well, Murch.

**Antoine Poinsot**: Yeah, try it in your own workflow if you're developing an
application on top of it.  For instance, for Liana, I know I have a functional
test suite, so I usually take the latest RC candidates and run my functional
tests of Lianna against the new version of Bitcoin Core.  You can try that.  If
you're a miner, try to get templates from the new version.  It's just a point
release, so really there should not be any inauguration, but in general, it's
good to check for performance, large performance decreases for instance as well.
That's it.

_Bitcoin Core #28167_

**Mike Schmidt**: Notable code and documentation changes.  If you have a
question for Antoine or Elle or Murch or myself, feel free to put it in the
thread or request speaker access, and we'll try to get to that at the end of the
show.  Bitcoin Core #28167, introducing -rpccookieperms as a bitcoind startup
option.  Murch?

**Mark Erhardt**: Sorry, yeah.  So, this is a pretty easy one.  This targets
especially nodes that run multiple different Bitcoin apps on one node.  And if
you want to segregate the Bitcoin node into a separate user space, currently it
was difficult to get access from, like say if you have an LN implementation
running in one user and you have a Bitcoin node running in the other user and
they need to talk to each other, it could be difficult to get RPC access to the
Bitcoin node on the same host.  And this enables you to, in the configuration of
Bitcoin Core, give access to separate users on the same machine.  And it's my
understanding that there previously were some workarounds that involved
executing scripts in the startup of your node, and this just feels safer and
cleaner.

_Bitcoin Core #30007_

**Mike Schmidt**: Awesome.  Thanks, Murch.  We have two more Bitcoin Core PRs
here, Bitcoin Core #30007, adding achow's DNS seeder to chainparams, and also
referencing this Dnsseedrs Rust crawler.  Do you want to comment on that, Murch?

**Mark Erhardt**: Absolutely.  So, I actually wasn't following that at all, but
it looks like Ava implemented her own DNS seed.  So, I think there must be at
least three or four different implementations of DNS seeds now and she's been
running that for two months, and now feels that it's ready and was added to the
seed list.  So, this is a completely new Rust implementation for a DNS seed.
And maybe just as a quick recap, DNS seeds are the first point of contact for
new nodes that join the network that do not have any other nodes to connect to.
So they'll reach out, I think, round robin to one of the DNS seeds, or maybe
even all of them at once, and get a first set of just IP addresses, like node
addresses, that they can connect to and see if they can find a node there.  And
then as soon as they've established a contact to the node, of course, they
organically learn about more nodes via the address gossip.

So, anyway, there is a new DNS seed being added to the configuration of Bitcoin
Core and its new software.

_Bitcoin Core #30200_

**Mike Schmidt**: Bitcoin Core #30200, introducing a new Mining interface.
Murch, what's a Mining interface and why do we need one?

**Mark Erhardt**: Yeah, I was thinking that too.  This looks like it's only a
refactor of how block templates are being pushed around in Bitcoin Core
internally and how you can ask for a new block template to be created.  And this
appears to be staging work for the Stratum v2 implementation that's being worked
on for Bitcoin Core, so this is just a refactor.  I don't think the RPCs have
been added yet, but the idea is that there will be a couple of new RPCs in order
to interact with miners using the Stratum v2 protocol.

_Core Lightning #7342_

**Mike Schmidt**: Core Lightning #7342, which fixes an issue in the issues
titled, "Core Lightning fails on Umbrel restart if Bitcoin is not synced".  And
that issue for CLN isn't specific to Umbrel, but can occur more broadly when
bitcoind is not synced.  The issue outlining this bug, if you will, noted that
bitcoind has gone backwards from 820,093 to 820,080 blocks.  Christian Decker
noted on the issue that, "This is likely a bitcoind that restarted verifying
from scratch, and if CLN were to run against it and wait, it could end up doing
so, and being unresponsive for hours if not days at a time".  So, this PR
addresses that issue, and the PR is titled, "Wait for bitcoind if it's gone
backwards, don't abort".

The PR seemed to involve a bunch of refactoring to facilitate the fix, because
Rusty from the CLN team noted in the PR, "The code is ridiculously fragile.
Every time we tried, we broke something else.  So instead, I started reworking
the code to make it simple, then I changed it.  The result is much neater and
will serve us well for any future changes".

_LND #8796_

Next PR, LND #8796, and we have the PR author with us today coincidentally.
Elle?

**Elle Mouton**: Yeah, so let me just get it open.  Yeah, so this is quite a
simple PR that Matt brought to my attention.  Basically what happens is, we've
got zero-conf channels, which is like I ask you, "Do you want to open a
zero-conf channel?"  You say, "Yes", and then we go ahead and use the channel
before it's mined.  So there's that, and that's a channel type.  But you can
also just have, how non-zero-conf channels work is, I ask you, "Do you want to
open a channel?"  And then you respond with, "Accept", and you specify, "Okay,
I'm willing to do this with you, but I need the funding transaction to confirm
with depth X".  And I think the default we use is six in LND, but don't quote me
on that.  So, that's how it usually works.  And only then, when zero-conf
channels came in, was the recipient allowed to respond with a min depth of zero,
so like, "I accept this zero-conf channel, and so therefore, the depth of
confirmation that I need is zero".

What LND was doing before this PR is basically, if I ask you, "Hey, do you want
to open a channel with me?  But I don't want zero-conf, so I just want any other
channel type".  Then you respond with, "Sure", and then you say min depth of
zero, then I would just error out.  I'm going to be like, "No, not going to do
that, because usually I expect you to only say min depth to zero if the channel
type is zero-conf".  So, the whole complaint here was, okay, why do we have
this?  Because the min depth is really the recipient's -- if the recipient is
responding with a min depth of zero, they're basically telling you, "Hey, I
trust you, right.  I trust you enough that we can just use this channel without
it being confirmed".  So, why should we care if they're just signaling to us
that they trust us?

So, all this PR is doing is now, if we say, "Hey, do you want to open a
channel?" and they say, "Cool, min depth of zero because I trust you", we don't
error out, we carry on, but we're still going to wait a min depth of one.  So,
we're going to wait for one block confirmation before we actually send them the
channel-ready message, and before we actually start using the channel.  So,
we're basically just not erroring out in that case.

**Mike Schmidt**: Excellent.  Thanks, Elle.

**Elle Mouton**: Sure.

_LDK #3125_

**Mike Schmidt**: LDK #3125, a PR titled, "Async payments message encoding and
prefactor".  This PR is actually part of LDK support for async payment
workflows.  As a reminder, async payments allow an offline receiver to receive a
payment.  The payment is actually held by a forwarding node and then delivered
when the receiver comes back online.  So, you can think about a mobile LN wallet
would be a use case for that.  This PR adds support in LDK specifically for
encoding async-payment-related messages and adds some fields for handling those
messages.  The actual flow for async payment protocol is not yet fully
supported.  You can track LDK's progress towards async payments in their
tracking issue, which I love, tracking issue #2298.  Murch, any questions or
comments there?

_BIPs #1610_

Let's move to the BIPs section.  BIPs #1610, adding BIP #379 with a
specification for miniscript.  I suspect that Antoine will have some commentary
here.

**Mark Erhardt**: Well, maybe.  Or if you do want to start, otherwise I have a
couple of sentences.

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: All right.  So, miniscript, we've been talking about for many
years.  Obviously, we're talking about the language that compiles to Bitcoin
Script and that allows you to give a definitive analysis of how a script can be
solved and therefore is like a high-level tool for thinking about output scripts
and better wallet designs.  So, this has been talked about for, I don't know,
probably around five years at this point, and finally we do have a BIP.  So, BIP
#379 specifies this software and all of the translation layers.  I think there's
three implementations at this point that are compatible with each other, and
it's useful to discover the most efficient scripts to achieve all of the defined
outcomes.  Yeah, so this is all written up and out there to read for people.
Antoine, you got anything to add here?

**Antoine Poinsot**: No, that's pretty much it.  Maybe that, yeah, it's the most
efficient script but also, and more importantly, the safe script to achieve all
the outcomes, because you might be able to find some shortcuts in scripts, such
as sometimes what Lightning used to do in their scripts, but which would not
have been considered safe by miniscript because there are more safety measures
put in place with the typing system.  And the BIP itself is more focused for
implementals, so it's separated in one part where you have everything someone
wanting to code up miniscripts can use; and then there is the discussion,
whereas the website was more an unexplained entry of how Pieter and Andrew came
up with this framework.  So, both are complementary, I guess.  If you want to
implement a miniscript parser framework, whatever, go to the BIP.  If you want
to learn more about the thinking behind miniscript, go to the second section of
the BIP or to the miniscript website at Pieter's website.

_BIPs #1540_

**Mike Schmidt**: Last PR this week is also to the BIPs repository, #1540,
adding BIPs #328, #390, and #373.  Murch, I saw this PRR was reviewed, approved
and merged by you, so I'll let you take it.

**Mark Erhardt**: Yeah, thanks.  So, this one's all about MuSig, or, well the PR
introduces no less than three BIPs, but they're all related, and that's why
they're in a single request.  So, let's take it from the top.  BIP #328
introduces a derivation scheme for aggregate keys in the context of MuSig2.  So,
the observation here is that if you create a MuSig2 shared key, that requires
you to jump through a bunch of hoops.  And after you do it once, since the
result of the process is just a regular public key, you can use this as a
starting point for generating a public key in the sense of BIP32.  And so,
instead of using multiple chains of BIP32 xpubs, where each participant keeps
track of how many derivations they've made and so forth, you only generate an
aggregate key once and then derive from that in order to generate more
aggregated keys.  So, this is less complex and reduces storage and computation
requirements for implementers, and apparently it's safe to do.  So, this is the
recommendation in BIP #328.

BIP #390 is about wallet descriptors, so how to use MuSig2 in defining a wallet
completely.  So, it just introduces the little descriptor fragment that lets you
define MuSig keys and yeah, it's fairly short.  And finally, the third one is
PSBT support for MuSig2; that's BIP #373.  And it introduces a few new input
fields for tracking the public keys of the participants in an input to compose
the aggregate public key, a public nonce, and a partial signature.  So, yeah,
those basically are all the fields in order to use PSBT, the Partially Signed
Bitcoin Transaction format, to hand around the incomplete transaction and allow
other participants to contribute towards the final MuSig signatures.  It also
introduces new output fields, particularly for the public keys of participants,
in order to generate an output script, I believe.  Yeah, anyway, that's roughly
the overview.

People that are excited about MuSig2 and have been lamenting how it took forever
to come, I think, I hope we'll see this arrive in a lot of end-user wallets
fairly quickly.  I know there are some out there already, but yeah, doing
multisig with the onchain footprint of single-sig is still the dream and pretty
awesome.

**Mike Schmidt**: No audience questions so far.  Murch, anything else before we
wrap up?

**Mark Erhardt**: Well, did anyone else want to comment on these BIPs?  Other
than that, no, I have nothing.

**Mike Schmidt**: I'll tease that next week we're going to have Vojtěch on to
talk about that interesting B10C transaction that came out in the last few
weeks, so look forward to chatting with them next week.  No questions, so I'll
thank Elle and Antoine for joining as special guests, representing their news
items and work this past week.  And thank you always to my co-host, Murch, and
for you all for listening.  Cheers.

**Mark Erhardt**: Cheers.

**Antoine Poinsot**: Thanks.  Cheers.

**Elle Mouton**: Thanks, guys.  Cheers.

{% include references.md %}
