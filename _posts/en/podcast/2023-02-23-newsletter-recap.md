---
title: 'Bitcoin Optech Newsletter #239 Recap Podcast'
permalink: /en/podcast/2023/02/23/
name: 2023-02-23-recap
slug: 2023-02-23-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by James O'Beirne,
Christian Decker, and Russell O'Connor to discuss [Newsletter #239][news239].

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/65694485/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-1-27%2F8312452a-43df-af11-29e5-f4553e76d78c.mp3" %}

## News

{% include functions/podcast-note.md title="Draft BIP for OP_VAULT" url="news239 op_vault" anchor="op_vault" timestamp="1:18" %}
{% include functions/podcast-note.md title="LN quality of service flag"
  url="news239 ln qos" anchor="ln-qos" timestamp="4:15" %}
{% include functions/podcast-note.md title="Feedback requested on LN good neighbor scoring"
  url="news239 good neighbor" anchor="good-neighbor" timestamp="13:58" %}
{% include functions/podcast-note.md title="Proposed BIP for Codex32 seed encoding scheme"
  url="news239 codex32" anchor="codex32" timestamp="20:27" %}

## Selected Q&A from Bitcoin Stack Exchange

{% include functions/podcast-note.md title="Why is witness data downloaded during IBD in prune mode?"
  url="news239 se1" anchor="se1" timestamp="36:40" %}
{% include functions/podcast-note.md title="Can Bitcoin’s P2P network relay compressed data?"
  url="news239 se2" anchor="se2" timestamp="40:39" %}
{% include functions/podcast-note.md title="How does one become a DNS seed for Bitcoin Core?"
  url="news239 se3" anchor="se3" timestamp="41:18" %}
{% include functions/podcast-note.md title="Where can I learn about open research topics in Bitcoin?"
  url="news239 se4" anchor="se4" timestamp="44:00" %}
{% include functions/podcast-note.md title="What is the maximum size transaction that will be relayed by bitcoin nodes using the default configuration?"
  url="news239 se5" anchor="se5" timestamp="47:55" %}
{% include functions/podcast-note.md title="Understanding how ordinals work with in Bitcoin. What is exactly stored on the blockchain?" url="news239 se6" anchor="se6" timestamp="50:07" %}
{% include functions/podcast-note.md title="Why doesn’t the protocol allow unconfirmed transactions to expire at a given height?" url="news239 se7" anchor="se7" timestamp="51:00" %}

## Releases and release candidates

{% include functions/podcast-note.md title="BDK 0.27.1"
  url="news239 bdk" anchor="bdk" timestamp="52:44" %}
{% include functions/podcast-note.md title="Core Lightning 23.02rc3"
  url="news239 cln" anchor="cln" timestamp="53:16" %}

## Notable code and documentation changes

{% include functions/podcast-note.md title="Bitcoin Core #24149"
  url="news239 bc24149" anchor="bc24149" timestamp="53:57" %}
{% include functions/podcast-note.md title="Bitcoin Core #25344"
  url="news239 bc25344" anchor="bc25344" timestamp="56:10" %}
{% include functions/podcast-note.md title="Eclair #2596"
  url="news239 ec2596" anchor="ec2596" timestamp="58:09" %}
{% include functions/podcast-note.md title="Eclair #2595"
  url="news239 ec2595" anchor="ec2595" timestamp="59:31" %}
{% include functions/podcast-note.md title="Eclair #2479"
  url="news239 ec2479" anchor="ec2479" timestamp="59:45" %}
{% include functions/podcast-note.md title="LND #5988"
  url="news239 lnd5988" anchor="lnd5988" timestamp="1:00:09" %}
{% include functions/podcast-note.md title="Rust Bitcoin #1636"
  url="news239 rb1636" anchor="rb1636" timestamp="1:00:42" %}

## Transcription

**Mike Schmidt**: Well, let's get started, everybody's here.  Welcome everybody
to Bitcoin Optech Newsletter #239 Recap on Twitter Spaces.  We are joined by a
few special guests highlighting their segments in the news section, so we'll go
through introductions real quick unless, Murch, you have any announcements this
week?

**Mark Erhardt**: None.

**Mike Schmidt**: All right, well I'm Mike Schmidt, I'm a contributor at Bitcoin
Optech, and also Executive Director at Brink where we fund open-source Bitcoin
developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin stuff.

**Mike Schmidt**: James?

**James O'Beirne**: Hey, I'm James O'Beirne, I work on various Bitcoin projects,
OP_VAULTS, AssumeUTXO and a few other things.

**Mike Schmidt**: Christian?

**Christian Decker**: Hi, I'm Chris, I am a long-time bitcoiner, first-time
caller, working on Lightning.

**Mike Schmidt**: And Russell?

**Russell O'Connor**: Hi, my name's Russell O'Connor, I work at Blockstream, and
I'm here to help present the work of Dr Curr and Professor Snead on the Codex32.

**Mike Schmidt**: Well, thank you all for joining us.  We can jump in, we'll
just go sequentially through the newsletter, which will knock out the special
guest news items first, and I've also shared a bunch of tweets related to the
newsletter in this Spaces.  If folks want to follow along, you can read those
tweets and also drill into the underlying newsletter to follow along with the
content and associated links.

{:#op_vault}
_Draft BIP for `OP_VAULT`_

Our first news item this week is Draft BIP for OP_VAULT, and I happened to see
James was in the Space, so I added him as a speaker.  James, what's changed
since we last talked about OP_VAULT?  I noted there were some changes that were
noted in your mailing list post, and then we can talk about the inquisition item
as well.

**James O'Beirne**: Yeah, I think not so much has changed, especially not from
an interface perspective.  I think some aspects of the proposal have been made
more explicit in terms of shifting the execution of the validation more towards
fully specifying stuff using the witness stack versus doing a kind of automatic
detection based on scanning through outputs and output structure.  So, really
just kind of some implementation improvements I think.  And then, a few things
have become a matter of policy instead of consensus, so really kind of anything
that existed as a provision to prevent pinning has been moved out of consensus
and into policy, just to kind of allow for maximum flexibility.

So, the long and the short of it is that not much has changed, it's all pretty
formalised in the BIP and the implementation's been brought into accordance with
the BIP.  So, hopefully it gets a number soon, because then we can throw it up
on Inquisition and start actually playing with it and maybe get some wallet
software going.

**Mike Schmidt**: James, I won't ask you about activation method.

**James O'Beirne**: Yeah, I forgot that was a hot-button issue for some people.
I thought the least controversial thing I could possibly say was, "Hey, we could
just do this in the same way that we did Taproot", but I guess that needs a
little bit more attention.

**Mark Erhardt**: Looks like it, yes, indeed.  Let's not go into it too much,
we'll have all that discussion when you actually formally propose activation!

**James O'Beirne**: For sure.

**Mike Schmidt**: I think it's interesting that the Bitcoin Inquisition effort
has been sort of part of the pipeline of proposals wanting to get their change
into Inquisition to be tested, so we talked about that with Rodolfo the other
day, James, but I think that's an interesting change to proposals being promoted
in the ecosystem.

**James O'Beirne**: I think it's really healthy, because it's made me consider a
few things that I hadn't previously.  And I think just the more kind of holistic
usage that we can get with things of that nature, you know, potential consensus
changes or even policy changes, just the more of a hands-on intuition you can
get, the better, so I think it's a great development.

**Mike Schmidt**: Murch, anything else on OP_VAULT before we move on?

**Mark Erhardt**: Maybe just in the context of activation preparation.  No,
sorry, it's also that Greg was writing about ANYPREVOUT recently, and he said he
would first simulate it in Liquid, and I thought that was also an interesting
approach, because Liquid already has covenants, so he said that he would have a
simulation in Liquid and test it there.  I don't know, maybe if he gets that
done, he could also put it in the Inquisition, just as another approach.

{:#ln-qos}
_LN quality of service flag_

**Mike Schmidt**: Second item from the news section in this week's newsletter is
the quality of service flag proposal, or mailing list post from Joost.  Joost
was unavailable to represent his mailing list post this week, but maybe we can
catch up with him in the future, but there was some discussion on the
Lightning-Dev mailing list about this particular ability for a node to signal
that a particular channel is "highly available" according to the operator, so
sort of some self-reputation there.

I saw that Christian had replied with some thoughtful feedback that applied not
just to this mailing list post, but some thoughts on reputation systems in
general.  Christian, do you want to frame a discussion and maybe summarise
Joost's proposal briefly before outlining reputation systems more broadly?

**Christian Decker**: Yeah, absolutely, and thank you for pointing out that my
reply doesn't only apply to, or isn't aimed as criticism against Joost's
proposal, but it's more, let's be careful about how we build these reputation
systems.  They can be dangerous if we sort of go through them in a greedy
fashion.  Each individual change isn't bad, but the combination ends up being
worse than the parts that constitute the overall change.

So, Joost's proposal essentially gives node operators an option of saying, "I
have a channel that I am dedicated to maintaining as balanced as possible, such
that you can always assume that there is some liquidity on this channel.  And
therefore, if you pick it and it is empty, then I misbehaved, I didn't hold up
my end of the negotiation.  I told you that this channel is highly available,
but it wasn't usable by you", so the sender can then impose a stricter penalty,
so to speak.  This should act as an incentive to the operator of that channel
that self-announces this as a highly available channel, to take particular care
about the balancing of that channel.

That's all good and fine, but I wanted to take a moment to essentially open up
the discussion about not only the design space of these reputation systems,
because there is a lot of pre-existing literature in academia that we could use
and that we could refresh and basically build upon.  I, for example, have been
in contact with these reputation systems in the past in the context of
BitTorrent, where some nodes download too from other nodes, and these other
nodes upload data from themselves.  So essentially, it's a tit-for-tat where I
give a little and I get a little; and these always broke.  So, we'd better make
sure that we understand the issue well and that we can come up with a solution
that actually addresses the underlying problem.

Specifically in this case, my concern was that we're talking about penalising
nodes for not adhering to their self-imposed restriction of, "This channel must
be balanced".  That in itself is not really incentive-compatible, because
penalising in this case means that I won't touch that channel, despite maybe
knowing that it would be usable now, just because I got burned before so I won't
try this.  In reality, we should really be using any channel that we might have
an idea could be usable, independently of whether we like that node or not.
We're purely sort of utilitarian in the sense that if there is a path, I will
use it; if it is a cheat path, I won't use it any more.

That is the comment on the specific thing.  And the wider idea is that we should
be careful about how we design these reputation systems, because if we try 50
different types, then we might end up in a situation where each individual
reputation decision that nodes take might be beneficial, but in combination
there is an emergent behaviour that is detrimental to the network as a whole,
which we've seen several times in the BitTorrent case.

Finally, the value of reputation systems essentially comes down to what
information do I gather, how wide that information is, how much do I know about
the network in its entirety, and how big the chances are of using that
information in the future.  So, if I'm an end user and I detected some node that
is not very reliable, well how big are our chances of me actually being able to
use that information in the future?  If I'm an end user, I might do a payment
every couple of hours; but using the same node or channel is very unlikely.  So,
any information I learned about these from my occasional interactions with them
might be totally out of date by the time I use it.  That's where reputations
sort of fall apart.

**Mike Schmidt**: Christian, is there a bundling of reputation ideas that have
been floating around in Lightning that you are a fan of, or think should be
pursued; or, are you more sceptical in general?

**Christian Decker**: So, I think they definitely have a value, they have a
reason to be there.  I'd prefer to exhaust non-reputational and
non-game-theoretic approaches first, but at some point we will have to touch
those options as well.  Any sort of system where I can actually enforce a state
is safer than a system where I can encourage correct behaviour, by the very
nature of those two verbs essentially.  But I would probably put the cut at some
place between, "Okay, that's information that I myself have learned from
interacting with the network", that still being okay; and the step beyond that,
namely accepting reputational information that I cannot verify locally into my
local decisions.  That would be a step too far in my mind, simply because any
time we rely on information we can't verify, we can inherently be manipulated to
do something we might not want.  That's probably the separation step between the
two places of me being comfortable and me getting really uncomfortable.

**Mike Schmidt**: You mentioned in your mailing list post what you categorise as
three different types of reputation systems: one being first-hand experience;
the second being inferred experience; and the third being hearsay.  Based on
what you're saying here, you would be averse to the two, hearsay-based
reputation systems for the reasons you've outlined; and it sounds like
first-hand experience you think could be valuable.  And then, what is inferred
experience and how does that fall in between, and how do you think about that?

**Christian Decker**: So, inferred, I would say, is information that we can
verify, but we haven't a witness locally, so if we're presented, for example,
with a proof of payment, an invoice, that allows us to infer that somebody has
paid that payment.  So, that's still very much first-hand observable things, or
inferable from other observable data we have available.  It's only that
admittedly, pointedly chosen hearsay that would go beyond what I think we should
be comfortable with.

**Mike Schmidt**: Murch, have you given any thought to this mailing list post,
as well as the general discussion about reputation systems?

**Mark Erhardt**: I kind of want to revisit the start of this.  From what I
understand, the idea here is that a node self-proclaims that they are an
excellent service and will always be able to forward payments that arrive at
their node.  What problem does this solve?  I know that there were some
complaints, or observations, that there's a lot of hobbyist nodes on the
Lightning Network still, with default configuration, and they tend to be less
well-maintained and might have channels all skewed in one direction, or are just
spottedly online.  But how does self-labelling yourself as an excellent service
not just -- why is that not just self-advertisement?  How is there actionable
information here?  That's merely what I'm missing.

**Christian Decker**: That's very much one of the core criticisms that we have.
And of course, the central idea of the self-advertisement is essentially that as
a hobbyist, you wouldn't use that, and therefore as a sender, you could rely on
that signal to make routing decisions that give you a better chance of
succeeding, right.  The criticism of this machine self-announcement is of
course, hey, who wouldn't signal this flag.  If you don't signal it and senders
take it into consideration, you're basically hurting your own chances of being
used in a route.  And if you signal it and senders use it, you might get some
additional traffic, nodes will prioritise you higher and the penalty isn't that
big, because essentially you're being skipped for routing decisions going
forward.

I think the bigger criticism here is that as engineers, we always strive to make
it possible for participants in the system to essentially move to any position
in the system itself.  We don't declare somebody as a central node but we want
everybody to have the same chances of occupying a certain position in the
system.  And by adding these differentiating factors, we are in fact making it
more difficult for people to move from one mode of operation into some other
mode; and this loss of permeability between different spaces, say end user
moving to becoming a merchant, or a merchant becoming a routing node, or vice
versa, any sort of obstacle we put in place between these moves is detrimental
to our users, and as such should be prevented, in my mind at least.

**Mark Erhardt**: Cool, thanks.

{:#good-neighbor}
_Feedback requested on LN good neighbor scoring_

**Mike Schmidt**: There is a related item in the newsletter, which is the next
one about good neighbour scoring.  Have you taken a look at that, Christian, and
do you have thoughts, similar feedback on reputation when applying it to this
sort of research that Carla and Clara have been working on?

**Christian Decker**: Absolutely.  This would pretty clearly fall into the
category of things we can observe directly, right.  We make a local decision,
tell our peer and they then basically can, after this trial, see it succeeded or
it didn't succeed.  So, we're now relying solely on local information.  And
depending on how that plays into the individual decisions, this can be a very
powerful tool.

If you're familiar with networking technologies, this very much resembles how
backpressure is handled in IP networks.  Each individual switch makes a
decision, "Hey, my buffers are full" or, "My buffers aren't full"; "I drop a
packet" or, "I don't drop a packet", and then my upstream has to retransmit a
section.  Providing backpressure, making local decisions based on local
information, we can still get an overall better network by just doing tiny
things.

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: I just want to jump in, please?  We should maybe first specify
what topic we are talking about.  So, we talked about this a few weeks ago, I
think, with both Carla, and before that, we had Clara and Sergei on that wrote a
paper last year.  We are talking about the approach to mitigate slow jamming, as
in big payments that are then held for a long time open by not settling at the
sender's end.

The idea here is, instead of making all of the funds available in our channels
for every peer, we make about half of our funds available to any peer and half
of our funds are reserved for peers that we consider good neighbours.  And we
locally assess whether we categorise that peer as a good neighbour or a bad
neighbour, or a neutral neighbour maybe.  Everybody starts as a neutral
neighbour and as other peers send traffic through us, give us routing fees, we
will eventually assess them to be, "They're bringing revenue in, their payment
cleared quickly", so at some point we'll set them to, "They're a good neighbour,
they're good for me".

Now, the idea is to propagate this in a sort of single-hub network, where if I
have a good neighbour that sends me a payment, I allow them to take my good
neighbour reserved resources, so the second half of all my channel funds and
slots, and I will endorse them to my peer that I forward to.  Now, the receiver
of that new forwarding hub will say, "Well, if my peer is a good neighbour and
they've endorsed this forwarded payment as being from a good neighbour, then
transitively I will also endorse it as being a good neighbour".

As long as everybody is satisfied with their peers' performances along the
route, they get access to the highway, so to speak.  But as long as people are
not satisfied or people haven't proven themselves yet, we relegate them to only
half of our resources, and that makes them unable to jam us.  So, a new node
that just appears will not be able to take all of our channel funds and will not
be able to lock us from forwarding other payments.  But in general, unless there
is a lot of traffic going on, a neutral node will be able to route because we
usually don't take more than half of our resources.  Christian, back to you.

**Christian Decker**: As I mentioned, this is something that takes a local
decision into consideration, "Is this a trusted peer from my point of view?
And, do I want to endorse a payment to my peer, transitively extending that
trust relationship from my peer to the next hub essentially?"  That is also
where the backpressure analogy comes in.  Everybody takes a local decision and
as a route, we collectively have a certain behaviour that emerges from that,
namely that some packets have to be retransmitted.  And in this case, if you're
a trustworthy route, or the origin, then your payment will be endorsed and you
get a higher probability of succeeding in the end.

The important thing to note here is that like any reputation system, this trust
score or this endorsement is based solely on our past experience.  We
essentially use the past experience to make an estimation of what happens next
in the system.  And like any financial advisor will tell you, past performance
not a good indication.  There is a really nasty type of attacks in reputation
systems, where you essentially build up a reputation over time, while at the
same time essentially they attack the network using those reputation, and
there's no way of defending it essentially.

**Mark Erhardt**: That's an important point to make of course, yes.  But for the
most part, as long as peers behave benignly, you would eventually declare them
to be good peers; or at least if they also manage to have routes where the
payments clear quickly.  So it just generally makes it harder for an attacker to
come in and jam, because the jammer would first have to build up reputation.
So, at least it takes time and they can't just move in and immediately jam.

**Christian Decker**: Correct, yes.  So, the danger of using reputation systems
is that there is a sort of flag day where everybody turns evil, despite their
prior reputation.  But that's not the steady state; so once they lose the
reputation, they'll have to build it up again before they can re-attack
essentially.

**Mark Erhardt**: Cool, then I think we might move on to the Codex32 seed
encoding scheme with James and Mike.

**Mike Schmidt**: Yeah, I think that sounds good, Christian, unless there is
anything else on either of these news items that you felt we should cover more
deeply.

{:#codex32}
_Proposed BIP for Codex32 seed encoding scheme_

**Mike Schmidt**: That's a nack!  Let's move on with the Codex32. Well, Russell,
I know this is not your proposal, but some alter ego's proposal.  Maybe it would
make sense to go through maybe just a bit of background for our listeners about
BIP32, SLIP39 and then we can jump into the scheme that you all have, well not
you but the professors have, regarding encoding seeds.

**Russell O'Connor**: Yeah, so this sort of goes back to this idea of doing hand
computation for dealing with master secret data, and whether that's feasible or
not.  So, I was pretty sceptical of Dr Curr's idea that you could do hand
computation with secret data in a reliable way, because you would want to make
sure that you have some sort of checks on to make sure that you're not making
mistakes in your process, and stuff like that.

In fact, maybe I should go back a little bit further to SLIP39, and other ways
of dealing with secret data historically, which is that when I deal with loading
up a master seed into my hardware wallet, or something like that, I'm personally
a little bit sceptical of the utility of hardware digital systems to come up
with the entropy needed to make a master secret.  These devices are digital
devices so they're not used to making non-determinative stuff.  And even if they
do have a fancy hardware entropy generator, it's hard to tell internally whether
that's failed or not.  So, maybe this is my ignorance on the topic, but I just
generally don't trust it.  So, I always have used dice to generate my master
secret words.

But the problem with BIP32 is that they have this SHA-256-based checksum that
you need to satisfy in order to enter it into hardware wallet and even after
rolling dice, you can't really compute that checksum.  So, I was stuck a little
bit.  I do know that some hardware wallets will let you enter dice roll into the
system and I think that's a big improvement.  I didn't have one at the time.
But I got intrigued by the Dr's proposal for doing hand computations for it, and
for doing Shamir's Secret Sharing, which is a way of storing your master secret
data, whether it's on Cryptosteel for whatever in its distributed matter that
you split the secret into a large number of pieces, and as long as you have a
friction threshold number of two or three, they can be brought together to
reassemble the master secret.  But individually, the shards alone, if you have
less than the threshold, many of them leak no information about the master
secret.

So, SLIP39 is an implementation of this secret sharing, but again it has a bunch
of computational intensive checksums that you couldn't generate by hand.  If you
don't want to trust your digital devices with the master secret generation, you
need a different system that allows you to operate by hand.  It took a while,
but I became convinced that indeed this hand system is practical to use, and
moreover it's also designed not to really compromise on anything.  So, even if
you're not doing hand computation, it's still a very perfectly normal and fine
system to use, and so it would make it a good standard for a wide range of
users, from the experts who don't trust digital computers and want to do things
by hand, to novices who aren't prepared to do that and just want to have the
hardware wallet, or whatever wallet they have, handle the process for them.
It's works well in this entire broad way range of scenarios.

**Mark Erhardt**: So, I visited a workshop by an acquaintance of Professor Snead
in, I think it was August last year in Austin, where this acquaintance presented
some of their volvelles and I was wondering, is that still the same process, or
is there a big improvement since last August?

**Russell O'Connor**: No, it's exactly the same process.  The only change that
we've made lately is that the standard 13-character checksum only operates up to
400 bits and BIP32 allows for up to 512-bit secrets.  Now, the recommended
number for a cypher secret is 256 bits, which is less than 400, right, and I
would personally actually recommend even smaller master secrets.  128 bits is
the minimum size, and I think that's what people should aim for.  But in order
to completely support the wide range of up to 512-bit secrets that BIP32 allows,
we added a second checksum that contains 15 characters to support these
extra-large master seeds, and those aren't designed to be hand-computed, but
they are part of the Codex32 BIP.  So, we have one unified proposal to handle
the entire BIP32 range of master secrets.

**Mike Schmidt**: Russell, can you talk a little bit about those error
correction features?  I think I read something like you could have eight or more
characters missing, or you can plug in a question mark and it can be restored,
even with that missing information, those different parameters.

**Russell O'Connor**: Yeah, so that 32-address format, this is largely based on
the Bech32 address format, which has a six-character checksum.  That can detect
four errors and in theory, correct two, although they recommend not doing error
corrections for addresses.  If you have an error, you should just go back to the
source and ask for a new address, and I think that's better.  However, when it
comes to storing your master secret, you definitely do want to do error
correction, because if there's an error in your stored data, there's no source
of truth to go back to, so you want to be able to do error correction.

So, this entails creating a longer checksum.  So, we have 13 characters in our
checksum, rather than Bech32 6 characters.  This longer checksum allows us to do
error correction on each individual share for up to four errors.  If you have
unreadable characters rather than simply incorrect characters, you can correct
up to eight unreadable characters.  And there's sort of a sliding scale between
this, so if you have two unreadable characters, then you can correct them, and
additionally three actual error characters, and so it sort of slides between the
number of missing characters, called erasures, and actual erroneous characters,
which are just incorrect characters located somewhere in there.

Furthermore, these BCH codes in this case can correct -- if you have unreadable
characters that are 13 characters in a row, or otherwise within a small block of
13 characters of data, you can also correct what are called burst errors, where
you're missing this block of 13 characters somewhere in the middle of your data,
because you've spilled wine on your sheet, or something like that.

**Mike Schmidt**: That's pretty impressive.

**Mark Erhardt**: So, how much time and effort is this going to be?  I print out
my volvelles, I start filling out the chart.  I think when I attempted this the
first time in Austin, I was about a solid hour in and I think maybe a third or a
quarter done.  So, this is about the time investment that I have to do.  So, the
advantage would be, I never make my private key material touch any digital
devices, yet I can verify that the checksums match up, so I have multiple
secrets that belong together; and I hope I could also verify that I have the
full secret all on paper.  But how much time do I have to invest to operate in
this manner?

**Russell O'Connor**: It gets easier with practice.  Andrew Poelstra has a lot
more experience with this process than I do, but my understanding is that it is
on the order of an hour or more per share that you want to create the checksum
for.  I believe once you have threshold many shares produced with valid
checksums, the production of additional shares is somewhat faster, which is
nice.  Typically the threshold is pretty low, so I would go two or three; it
depends on exactly what your preferences are, but it is going to be a long
process.

I also do want to correct that you do eventually put these -- typically you
would eventually put these shares into like a hardware wallet, preferably a
hardware wallet that would then support the Codex32 format, so you just plug in
the shares and it would run the seed for you there.  The advantage here is that
you have generated the seed yourself using dice, so you know that it's random.

We also have a worksheet for debiasing the dice, so that even if you have air
pockets in your dice, you go through the debiasing process and you still get all
the entropy that you need from rolling dice so you know that the master secret
is generated securely; you know that the shares are generated properly, that the
shares aren't secretly leaking the master seed data because you manipulated it
yourself, or any other underhanded things that a hardware wallet might try to do
in manipulating the seed data.

So, in a combination of this and you then add the anti-exfil on the signatures
and doublechecking the public key generation, you can actually find yourself at
a point that even if a hardware wallet is trying to be malicious, it is actually
unable to convert your master secrets.

**Mike Schmidt**: Russell, I think you probably went through this and maybe I've
misunderstood it, but there was an example share that we put in the newsletter.
I'm rolling my dice, I'm creating entropy; is that amount the master share, or
is there a master share and then sub-shares, or are there just a bunch of master
shares that I'm generating with the dice, or is there one master and then you
derive the shares out of that?

**Russell O'Connor**: Yes, so MS stands for Master Seed, right.  In particular,
this is a BIP32 definition, which is the entropy that's used to generate your
master node in your HD wallet, so that's what MS stands for.  And when you're
rolling the dice, if you have an existing master secret that you want to split
up this way, when you're rolling the dice, you are basically producing blinding
factors, they're just purely random data that creates a situation that when you
have threshold many blinding factors when you start deriving the additional
shares beyond the threshold, that blinds the master secret as well.

If you're generating a fresh master secret, there's a shortcut you can do where
you just make threshold many random shares, and when you take these random
shares and you work to reconstruct the underlying master secret for them,
because all those threshold many shares were random, the combination of them
just ends up with a random master secret, which is fine because you want your
master secret to be random in the first place.  So, depending on your point of
view, you can think of this randomness when you're creating the first threshold
many shares, instead of a blinding of the underlying master secret, if that
makes sense to you guys.

**Mike Schmidt**: It does, thank you for clarifying.  Murch, James or Christian,
any follow-up questions?

**Mark Erhardt**: I think while you say that it's very accessible for novices,
especially trusting this process and understanding all that's going on might be
more difficult than just buying a hardware wallet or something and starting to
use.

**Russell O'Connor**: Let me clarify.  For novices, what I would do is say that
the hardware wallet generates all the shares for you and you just store them in
the standard way that you would deal with, with maybe SLIP39, or what have you.
So, what I'm saying is that novices, if your hardware supports Codex32, you can
have it generate shares for you and you can store those shares, and you would
just treat it the way you'd normally treat your BIP39 secret, except you have
the secret sharing scheme.  And it's not like you have to use the hand
generation aspect of this protocol.  Even if you don't want to use the hand
generation, you're not confident in your skills, you don't want to invest the
time, that's all very reasonable and it's still a great system to use, even if
you don't take full advantage of the expert mode, so to speak.

**Mark Erhardt**: I see, thank you for clarifying that, because I was going to
say that the hand-crafted seeds definitely sound like high wizardry to me.

**Russell O'Connor**: Absolutely.  I think the extreme end of the hand
computation is actually only going to be for experts who are interested in that.
But I do want to emphasise that you can completely forego all the hand
computation, rely on your hardware wallet to generate the shares for you, and
you still have an excellent, compact system with a very high-quality error
correction code that will keep your master seed very secure.

**Mark Erhardt**: So, is that the main difference, that Codex32 improves on the
error correction over SLIP39?

**Russell O'Connor**: Well, I would say the main benefit is to have enabled this
extra expert mode.  Actually, I think people should take it very seriously, and
seriously consider especially depending on the value of the Bitcoin that you
want to store, they should consider the threat of hardware wallets.  But it's
more incidental that the error correction quality is slightly higher than
SLIP32, but I wouldn't say that would be a main feature.  If that were the only
difference, I probably wouldn't suggest it.

**Mike Schmidt**: Thanks.  And, James, you wanted to say something?

**James O'Beirne**: Yeah, I don't think it'll come as a surprise to anybody that
I'm very excited with how something like this might compose with vaults in
Bitcoin, because I think it's very compelling that this expert mode that
Russell's talking about could be used as your recovery path, and your trigger
key could be something that's a little bit easier to access, or something that's
actually living within a hardware wallet.  Russell, do you think it's practical
that the kind of hand-generation that you're describing could yield a pubkey
that could then be used in a recovery path; or, do you actually need to use some
kind of a mechanical device to generate an initial derived address?

**Russell O'Connor**: I'm not 100% sure I'm following you, but I will say that
the mapping from the master seed entropy through BIP32 to any node in this thing
including the master node, or any of the subkeys, is a computational-intensive
process that just doesn't seem to have any hope of being able to do by hand.
That is a bit of a problem when it comes to trusting hardware wallets to
correctly produce public keys.  And sort of an open research question of how to
deal with that, my current recommendations would be to use multiple hardware
wallets perhaps to ensure that the public keys that they're deriving are
consistent with each other, from different vendors, of course.

**James O'Beirne**: That makes sense.  I was just asking about the step between
hand-generating entropy and then coming up with an address that you can actually
use in some other scheme, like vaults, because I do think this is a really
appealing target for say the recovery path in the vault scheme.

**Russell O'Connor**: Yeah, you would have to use a computer to pick out a
derivation path and produce a public key.  You basically can't produce public
keys by hand at all.

**James O'Beirne**: Yeah, that makes sense.  So, I guess you could be
particularly choosy about the device that does that process, something that
never touches the internet or…?

**Russell O'Connor**: Yeah.  It's also not that sensitive, what you want to do
is replicate it between different vendors to make sure they all agree that the
derivation path from that seed is the same and you would try to keep these
devices off.  The devices should be independent and not even touching any
computers at all.

**James O'Beirne**: Yeah, that makes sense.

**Mike Schmidt**: Great, thank you, Rusty Russell O'Connor, and thank you,
Christian, and thank you, James.  You guys are welcome to stay on.  We're going
to go through the rest of the newsletter, which includes the questions from the
Stack Exchange and notable PRs, but you're also welcome to drop off if you have
more pertinent things to do.  But thank you all for joining us.

**Russell O'Connor**: If I can just add one more comment about this?  I didn't
realise it until the mailing list discussion, David Harding and other people are
interested in the fact that you can do verification of your share integrity
against random errors by hand without having to go through the full recovery
process, which is interesting.  And furthermore, as we lately discovered, you
can actually shortcut this verification process through sort of a partial
verification that's a little bit easier, even easier to do by hand.  So, that's
a very interesting and an exciting development.

**Mike Schmidt**: Very cool.  Yeah, thanks for pointing that out and thanks for
joining us.  Murch, shall we move on to the Stack Exchange?

**Mark Erhardt**: Yeah, I think we have a lot to go through still in this
newsletter.  Let's go to the Stack Exchange questions.

{:#se1}
_Why is witness data downloaded during IBD in prune mode?_

**Mike Schmidt**: Excellent.  Well, each month, the newsletter takes one week
out of that month to cover questions from the Bitcoin Stack Exchange, where a
lot of Bitcoin experts look for questions and provide insightful answers.  We've
chosen a slew of them for this week's coverage, and the first one is, "Why is
witness data downloaded during IBD if you're in prune mode?"

This is actually something that Sipa answered and actually I think he noted in
his answer on the Stack Exchange that he was a bit surprised and hadn't thought
of this before.  And he notes that essentially, there's not much value to
pulling in that data if you're just going to basically discard it.  I think
there's some incidental checks that are done on that witness data that would
have to be bypassed.  But there's already a PR open now, Niklas Gögge opened up
a PR to address this and there'll be a review club covering this next week for
those who attend PR review clubs.  We've linked both of those in the newsletter.
Murch, what do you think on this?

**Mark Erhardt**: Yeah, maybe to clarify, it is when you're in prune mode and
you're still in the assumed valid part of the synchronisation.  So, we have
speedup in the beginning when you sync a new node.  Every time we release a new
version of Bitcoin Core, we put in an assumed valid height where we hardcode the
hash of a block; and if your header synchronisation comes across this block ID,
it assumes that everything up to that block, the signatures are fine.  It will
still go through all transactions and build the UTXO set, but it will not verify
that the signatures are accurate.

Usually, that's buried multiple months, so there's a lot of proof of work there.
The whole blockchain must have been accurate in order for full nodes to accept
it anyway and basically you're saying, "I know that this is buried behind months
of proof of work, so clearly the signatures must have been valid.  So, we are
just going to build the UTXO set ourselves, but not verify all of the scripts
and signatures".

So, the point here is, witness data is signature data and if we're not going to
read it directly, downloading it to throw it away, because we'll also prune it,
then it does not make sense and so this would be a further optimization.  I
think the only check that would be performed is that we use the witness data to
calculate the witness TXID, which we then in turn use to check the witness
commitment in the coinbase transaction, which makes sure that all the witness
data that was attached to the block matches the commitment in the coinbase.

If you're just basically going through the blockchain to build your UTXO set at
the current height and don't mean to keep a whole archive, there's no need for
you to.  Well, it could be cheaper, especially now that we have so much more
witness data, to be able to skip some of this.

**Mike Schmidt**: Yeah, exactly, there's a huge influx of witness data recently.
So, I guess at the point that this PR is merged and the assumed valid checkpoint
is further into the future, then you wouldn't have to worry about downloading a
bunch of jpegs.

**Mark Erhardt**: Assumed valid is not a checkpoint!  So, assumed valid
basically says, "If there is a block that has the hardcoded ID in your chain of
headers, then you will assume that up to the block that has been specified, the
scripts are fine.  If this block ID does not appear, you're not in uncharted
territory".  And the big difference between checkpoints and assumed valid is, if
assumed valid doesn't come to pass, you will be able to sync with whatever
blockchain you presented, which very likely is not what you were looking for,
but it'll work.  With a checkpoint, any data before the checkpoint, if it
doesn't end up in the checkpoint eventually, it's going to be considered
invalid.

**Mike Schmidt**: That's fair, fair correction.

**Mark Erhardt**: Accepted by your node.  So, we've not been doing any
checkpoints.  I think the last one was height 220,000, so what is that; seven
years ago?  No, more.  Anyway…

{:#se2}
_Can Bitcoin’s P2P network relay compressed data?_

**Mike Schmidt**: Next question from the Stack Exchange, "Can Bitcoin's P2P
network relay compressed data?  And the question was specific about if there was
a bunch of zeros and a bunch of OP_RETURNs, was there a way for the Bitcoin P2P
network to be able to compress that data when it's passing it around?  And
Pieter Wuille answered this question and he notes essentially, no, there is no
compression.  But he does point out two different discussions from the mailing
list, in which compression was discussed at the P2P level, and then also pointed
out that Blockstream Satellite actually has its own custom transaction
compression.

{:#se3}
_How does one become a DNS seed for Bitcoin Core?_

Next question from the Stack Exchange, "How does one become a DNS seed for
Bitcoin Core?"  User Paro answered this question and he actually noted a series
of different requirements to become a DNS seed.  As a reminder, a DNS seed is a
series of servers from well-known contributors that return IP addresses of
peers.  So, if you're new to the network and you don't know who to connect to,
you contact these DNS seeds and they'll provide you a variety of different
addresses.  And there's actually some specialised software that you need to run
in order to do that, and that's noted in the Stack Exchange answer as well.  I
think Sipa has a seed project that you'll need to run, a bitcoin seeder, which
you'll actually need to run on the back end of that.

We also point to, not in the newsletter, but actually in the answer on Stack
Exchange, we point to the piece in the codebase of where those seeds actually
exist.  And if I recall I think, Christian, are you one of those?  Christian,
are you a DNS seed for Bitcoin Core?

**Christian Decker**: Of course I am.  So, yeah, there are a couple of pull
requests that sort of define the world of seeds over time in the Bitcoin Core
project.  I run one of them and they are by no means required to run the same
seed software.  My seeder, for example, is crawling and serving using custom
Python code that I wrote a couple of years ago.  But the requirements got more
stringent over time for good reason.

So, for example, we're not allowed to log anything that isn't strictly necessary
to operate the seed.  We are also encouraged to run to sort of scan the network
for active nodes and not return stale nodes.  And for a while, I also ran the
comparison off the various DNS seeds with a couple that were really strange that
were essentially just serving static nodes, not refreshing anything.  So,
there's a wide variety, and for good reason.  This is something that supports
the network, it is complementary to the other mechanisms, but there are rules in
place to minimise the information we extract from the nodes itself.

**Mike Schmidt**: Excellent, yeah, thanks for jumping in on that.  How long have
you been a DNS seed?

**Christian Decker**: That goes back to my PhD time, so that must be eight years
now, nine maybe.  It was really easy to get your seed in initially!

**Mike Schmidt**: Well, thank you for your service.

**Christian Decker**: To be honest, I forgot about my seed for a long time until
somebody mentioned that there are now new ways to interact with seeds and mine
didn't implement.  It comes up every couple of years; it's not a high churn
project, so to speak, so I'd encourage everybody to run one because the more
sources of nodes that we have, the less we are reliant on a single one.

{:#se4}
_Where can I learn about open research topics in Bitcoin?_

**Mike Schmidt**: Next question from the Bitcoin Stack Exchange was, "Where can
I learn more about open research topics in Bitcoin?" and this was answered by
Michael Folkson, who provided a variety of sources of interesting topics.  But
two that I thought were interesting to highlight in the newsletter was, one,
Bitcoin Problems, which I think has been around for a while, and lists a bunch
of community-managed open research problems that could be potentially valuable
to have more research with respect to Bitcoin and Lightning; and then the second
resource is at Chaincode Labs Research.  Murch as a Chaincoder, do you want to
comment on Chaincode Labs Research?

**Mark Erhardt**: So, the latest that I had heard is that we have a prize now
for academic papers that advance Bitcoin and Lightning Network.  I think we're
giving it out the first time this year, and I know that there was work on
writing up a whole set of different questions that people could still look into
as academics, especially that would benefit Bitcoin applied researchers, I'd
say.  I'm not sure whether that ended up being part of the Bitcoin Problems
page, or whether that is still in the pipeline, but -- oh, yeah, Christian
probably knows more about this anyway.

**Christian Decker**: I was more wondering if it includes only open questions,
or whether there is also the opportunity for people like me, who essentially
just collect data, and the idea of eventually doing something with it, if there
is a possibility for us to contribute at these data sources as well, just
because every once in a while I come up with an idea of what I'd like to do,
then I start collecting data, and then I forget about it, or something else
comes along.  And I'm for sure not the only one, and providing this data to
other researchers might accelerate research in this area.

In particular, I have a couple of Bitcoin on-chain propagation data and the
gossip dumps for the last three years for Lightning, and stuff like that.  It's
not as visible as it could be; so, if there's a place for it, I'd love to add it
to your research collection.

**Mark Erhardt**: Cool.  I know there is a related project that Josie Bake was
working on, who collected mempool data and was working on cleaning that up to
make it available as a corpus for research.  I think the intention was in the
long term, to make that more of a bigger repository that collected a variety of
data, so he might be the right person to approach about this.  Although, I also
know that he is currently focused on working on silent payments.  Yeah, anyway,
we'll see.

**Christian Decker**: Yeah, guess where he's getting that data from?

**Mark Erhardt**: Yeah, I know that he talked to you about it.  You were one of
-- I think he collected from at least three resources and combined it.

**Christian Decker**: Also, the data has the tendency of being much cleaner if
you actually have people looking at it, so my data collection obviously ran for
years in the background with me not caring too much about it; so, I can't vouch
for its consistency.  But it's data that you can't reach otherwise nowadays,
there might be value in it and I'd love for this kind of work and effort not to
go to waste.

**Mark Erhardt**: Right, yeah.  So, next question, or do you have something
more?

**Mike Schmidt**: Well, maybe a little piggyback there, encouraging folks who
are interested in these sorts of problems, or may know somebody who's interested
in these sorts of problems, I think it's interesting to try to get these
research problems out there, not just to only get answers to them or maybe
improvements on ways of doing things, but also to get academia and potentially
smart people looking at Bitcoin and Lightning and realising that there are
interesting problems here, that this is a real thing, and hopefully bring talent
to the ecosystem.  So, take a look at those problems and pass it on.

{:#se5}
_What is the maximum size transaction that will be relayed by bitcoin nodes using the default configuration?_

Next question from the Stack Exchange, "What is the maximum size transaction
that will be relayed by Bitcoin nodes using the default configuration?" and we
have Sipa here again answering, pointing out Bitcoin Core's 400,000 weight unit
standardness policy.  He also notes that it is not currently configurable.
Obviously, you can do a different build to patch.  Then he sort of explained
some of the intended benefits of that limit, which was DoS protections.  I think
a few of these questions, and I'm sure you've noticed this, Murch, with your
moderation of the Stack Exchange, it seems to be there's a lot of questions
surrounding witness and policy and Ordinals and that sort of thing.

**Mark Erhardt**: Yeah, they all crept up in the last four weeks.  I have no
idea what's prompting them all.

**Mike Schmidt**: Any comments on that relay limit?

**Mark Erhardt**: Yeah, I think it's not actually -- I guess maybe we should
make it configurable.  But on the other hand, we really do want mempools to be
fairly consistent.  A lot of the benefits of having a mempool are tied to people
having homogenous mempools or similar mempools, at the very least.  If you start
having very different mempool policies and different pool content, we make nodes
more fingerprintable, the relay benefits for new blocks tend to go down.

So, really what we want mempools to be is primarily the source for building
blocks, then a communication tool to get transactions to miners to select into
their blocks, and then to get a good selection of transactions to the blocks,
and for everybody to have a good view on what will be the next block so that
they can do better fee estimation, and that they know what to relay to peers, so
that eventually we can hopefully make good decisions about what we need to do
with our transactions to reprioritise them, or what to evict from our mempool
when we overflow.

It could be possible to make limits like the standardness weight limit on
transactions configurable, but also that's probably just not a good idea.

{:#se6}
_Understanding how ordinals work with in Bitcoin. What is exactly stored on the blockchain?_

**Mike Schmidt**: That makes sense and thank you for providing the rationale
there.  Next question from the Stack Exchange is about Ordinals and about what
exactly is stored on the Bitcoin blockchain with the Ordinals approach.  I saw a
few questions in the Stack Exchange about this and I've seen stuff on Twitter.
I think a lot of people are under the assumption that for whatever reason, that
this data's being shoved into OP_RETURNs.  Potentially, that's just what they're
used to historically; I think counterparty was putting data in there, for
example, and that's just where folks think the arbitrary data goes.

But we had a little pseudo code sample illustrating that essentially, it's not
in the OP_RETURN, that there's an unexecuted script branch that essentially says
IF_0 and then pushes in a bunch of data and then ends the IF statement.  There's
a series of those types of pushes with the protocol, which is how that data gets
put into the witness.

{:#se7}
_Why doesn’t the protocol allow unconfirmed transactions to expire at a given height?_

The last question here is, "Why doesn't the protocol allow unconfirmed
transactions to expire at a given height?" and Larry both asked and answered
this question, and he references Satoshi on why it's not a good idea to have
seemingly useful ability for an unconfirmed transaction to have an expiration
height.  So, I guess the idea would be that after a certain block height, that
this transaction would not be valid, if it hasn't already been mined.

So, I think what Satoshi was getting at, and maybe one of many reasons to not do
that, would be if the expiration height is near the current height and you get
rid of the transaction in the block, there's a bunch of child transactions that
then come from that and then a reorg, and that transaction with the expiration
doesn't get in to the block height expiration, and now you have a bunch of child
transactions that potentially created a bunch of economic activity that then
essentially got rugged.  That's the gist of the argument that I got from
summary.  Murch, is that directionally correct?

**Mark Erhardt**: Yeah, I think that's a good summary.  The big problem with
making transactions expire at a certain block height is that it becomes gameable
by miners, or like a pinner to make it uncertain whether or not the transaction
will ever confirm.  If we don't have an expiration, we can assume that something
with sufficient fee rate will eventually confirm, or even if a reorg happens,
the best transactions will get picked into the new best chain.  But with the
expiration, that just becomes more complicated, it opens up attack surfaces to
steal from people.

{:#bdk}
_BDK 0.27.1_

**Mike Schmidt**: Onto the releases and release candidates' section for the
newsletter this week. We have a security update from BDK 0.27.1, which is a fix.
If folks are using the SQLite backend, there is a vulnerability that's been
published that an overflow can occur in certain versions.  So, if you're using
BDK's SQLite database feature, you should consider upgrading, and I think it's
really just a version bump on some dependencies under the hood that resolves
this.  Any comments, Murch?

**Mark Erhardt**: No, sounds good.  Upgrade if you're affected!

{:#cln}
_Core Lightning 23.02rc3_

**Mike Schmidt**: And then, Core Lightning 23.02rc3, we had a couple of
Blockstream folks on last week to walk through some of this.  Christian,
anything that you would like to add about this release candidate, or that you
hope folks would test or be aware of?

**Christian Decker**: So, this being release candidate 3, we are pretty sure
that it is going to work.  However, any additional testing is of course very
welcome.  The final release should follow in the next couple of days, unless we
find something breaking and I guess you already mentioned all of the headline
features, so I will skip those since during the release process, no new features
are added to the roster.  I probably can't tell you anything.

{:#bc24149}
_Bitcoin Core #24149_

**Mark Erhardt**: Yeah.  Then I'm going to talk about Bitcoin Core #24149, which
is a PR that recently got merged, and this PR adds signing support for
miniscript descriptors, specifically only P2WSH-based miniscript descriptors.
This is a big one though.  We've talked numerous times about miniscript in the
last couple of years.

The point here is that we will be able to, in a fairly high level language,
describe an output script and then generate the whole set of addresses that are
based on the same script with just this one general description of it.  And now,
we have watch-only wallets added to Bitcoin Core a while back; now, we also have
signing support.  Specifically this means that Bitcoin Core can now sign for any
miniscript-based output descriptors that are using P2WSH.  P2TR is to follow
still.  And especially more work went in during this PR to make rudimentary PSBT
support, so if you're presented with all the necessary preimage information and
keys, and get a PSBT, you will be able to sign for it with Bitcoin Core.

I think there's maybe some edge case though with PSBT where it cannot sign, even
though it should be able to sign for it.  And, yeah, Bitcoin Core wallet will
not be able to build transactions for all miniscripts yet, because there are
some features missing for estimating the size of inputs.  But we also had
recently a PR merged where you can tell the transaction building process what
input size to expect for certain UTXOs.  Altogether, it sounds to me like people
can really take a hard look at miniscript and start thinking about how they
would build interesting output scripts that they can define in miniscript.

**Mike Schmidt**: It's nice to see this PR merged, as I think it's been over a
year since it was originally opened; so, nice to get that functionality merged.

**Mark Erhardt**: Yeah, multiple years since work on miniscript started.

{:#bc25344}
_Bitcoin Core #25344_

**Mike Schmidt**: Bitcoin Core #25344, which updates bumpfee and psbtbumpfee
RPCs.  Those RPCs already exist and this PR augments the capabilities of those
RPCs to allow specifying different outputs for the replacement transaction.  So
for example, you can add, as noted in the newsletter, you can add an output and
that could be done for something like iterative payment batching for an exchange
that is trying to send out a bunch of payments; and if things don't go through,
you can continue to add outputs while you're bumping the fee.  Or, there's a use
case of removing outputs.  Some wallets use RBF to cancel a transaction, for
example.

I didn't see too much drama on this, but it's an interesting change.  Murch, do
you have thoughts on that?

**Mark Erhardt**: Transaction inputs belong to the sender until the transaction
is confirmed, they can do whatever they want with it.  People that think that
unconfirmed transactions are any more than a payment promise or hint at what
payment might be received are just sorely mistaken.  I'm a totally hardcore
hardliner on this one!

**Mike Schmidt**: I didn't mean to trigger you, although I suspected that maybe
that might have!

**Mark Erhardt**: No, it's kind of partially joking.  But it sort of ties into
the whole RBF debate: is sender allowed to deal with transactions until they
confirm?  And I think for the most part, all of our engineering is based on the
assumption, once stuff gets into the blockchain, that's when the network has
agreed on it; and before that, it's more advisory.  In a way, this is just a
missing feature that is finally being delivered.

**Mike Schmidt**: We have a few more PRs here.  I'll take the opportunity to
open up the floor for folks that have any questions.  Feel free to raise your
hand or request speaker access, then once we wrap up going through the rest of
these PRs, we can get to your question.

{:#ec2596}
_Eclair #2596_

Eclair #2596, well I guess we're on the topic of RBF so, limiting the number of
times a peer attempting to open a dual funded channel can RBF fee bump the
channel open transaction before the node won't accept any further attempted
updates.  So, I think there's actually two pieces to this PR.  One is limiting
the number of replacements; and the second one is actually limiting the minimum
number of blocks in between each of those fee bumps.  We go into some of the
rationale here about what the motivation is.

I think there is some comment on the PR, I think it was from Dave, that actually
outlined, "Hey, isn't this already handled by the rules around RBF to permit DoS
attacks?" and the conclusion is that they're not able to execute all of those
checks, because these are unconfirmed transactions potentially with unconfirmed
inputs, and that you could essentially send a bunch of transactions and not
actually follow the RBF rules.  So, that's why there's actually this separate
limit put in place at the Eclair.

**Mark Erhardt**: I think the point here is just that we don't want people to
bump transactions all the time and waste our cycles to entertain their many
attempts, because that would allow them to waste our bandwidth and DoS us.  So,
this is just sort of a sanity limit that is placed into it to curb attack
surface.

{:#ec2595}
_Eclair #2595_

**Mike Schmidt**: Another Eclair PR is next #2595, and it seems to be some
internal functions related to supporting splicing.  We've seen a flurry of these
over the last few weeks, so it's good to see progress going on there.

{:#ec2479}
_Eclair #2479_

Eclair #2479, adding support paying offers, and we outline in the newsletter a
particular user flow.  A user receiving an offer tells Eclair to pay the offer;
Eclair uses the offer to fetch an invoice from the receiver and verifies the
invoice meets the expected parameters, then pays the invoice.  So, a fairly
standard paying offer flow there that is now supported in Eclair.

{:#lnd5988}
_LND #5988_

LND #5988, adding a new optional probability estimator for finding payment
paths.  So, this is some previous research.  We actually highlight this from
Newsletter #192, which was way back a year ago, and LND has implemented this
additional probability estimator that is based on some of the research that René
Pickhardt did, I believe.  And this is already in c-lightning and
rust-lightning, and it's now taking into account channel capacity when doing
path finding.

{:#rb1636}
_Rust Bitcoin #1636_

Our last PR for this week is Rust Bitcoin #1636, which is adding a
predict_weight() function.  There's a bit of a chicken and egg here, in that you
sort of want to know the weight in order to get the fee, and the fee for the
weight, and so you can use this predict_weight() function.  In the input to the
function is a template for the transaction; and then the output of this function
is the expected weight.  It's obviously useful for fee management to determine
which inputs you need to add into the transaction, and it can provide a pretty
good estimate without actually having to construct the actual transaction
itself.

I don't see any requests for speakers, so I would like to thank our guests,
Christian, Russell, James for joining us, and my sometimes co-host, Murch.
Hopefully we can work on some of these issues for next week, or we can try and
find a different platform if the issue persists, but thank you all for joining
us for 90 minutes covering Newsletter #239 and we'll see you all next week.
Cheers.

**Christian Decker**: Thank you very much.  Cheers.

{% include references.md %}
[news239]: /en/newsletters/2023/02/22/
[news239 op_vault]: /en/newsletters/2023/02/22/#draft-bip-for-op-vault
[news239 ln qos]: /en/newsletters/2023/02/22/#ln-quality-of-service-flag
[news239 good neighbor]: /en/newsletters/2023/02/22/#feedback-requested-on-ln-good-neighbor-scoring
[news239 codex32]: /en/newsletters/2023/02/22/#proposed-bip-for-codex32-seed-encoding-scheme
[news239 se1]: /en/newsletters/2023/02/22/#why-is-witness-data-downloaded-during-ibd-in-prune-mode
[news239 se2]: /en/newsletters/2023/02/22/#can-bitcoin-s-p2p-network-relay-compressed-data
[news239 se3]: /en/newsletters/2023/02/22/#how-does-one-become-a-dns-seed-for-bitcoin-core
[news239 se4]: /en/newsletters/2023/02/22/#where-can-i-learn-about-open-research-topics-in-bitcoin
[news239 se5]: /en/newsletters/2023/02/22/#what-is-the-maximum-size-transaction-that-will-be-relayed-by-bitcoin-nodes-using-the-default-configuration
[news239 se6]: /en/newsletters/2023/02/22/#understanding-how-ordinals-work-with-in-bitcoin-what-is-exactly-stored-on-the-blockchain
[news239 se7]: /en/newsletters/2023/02/22/#why-doesn-t-the-protocol-allow-unconfirmed-transactions-to-expire-at-a-given-height
[news239 bdk]: /en/newsletters/2023/02/22/#bdk-0-27-1
[news239 cln]: /en/newsletters/2023/02/22/#core-lightning-23-02rc3
[news239 bc24149]: /en/newsletters/2023/02/22/#bitcoin-core-24149
[news239 bc25344]: /en/newsletters/2023/02/22/#bitcoin-core-25344
[news239 ec2596]: /en/newsletters/2023/02/22/#eclair-2596
[news239 ec2595]: /en/newsletters/2023/02/22/#eclair-2595
[news239 ec2479]: /en/newsletters/2023/02/22/#eclair-2479
[news239 lnd5988]:/en/newsletters/2023/02/22/#lnd-5988
[news239 rb1636]: /en/newsletters/2023/02/22/#rust-bitcoin-1636
