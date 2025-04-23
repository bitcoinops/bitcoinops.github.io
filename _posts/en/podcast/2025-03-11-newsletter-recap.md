---
title: 'Bitcoin Optech Newsletter #344 Recap Podcast'
permalink: /en/podcast/2025/03/11/
reference: /en/newsletters/2025/03/07/
name: 2025-03-11-recap
slug: 2025-03-11-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Matt Morehouse, Matt Corallo, and
Hunter Beast to discuss [Newsletter #344]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-2-11/396389129-44100-2-7fea555a6a94a.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #344 Recap on
Riverside.  Today, we're going to have a discussion about Bitcoin Core's
priorities; there's an LND vulnerability we're going to discuss; we have our
monthly segment on Changing consensus and our usual segments on Releases and
Notable code changes.  I'm Mike Schmidt, contributor at Optech and Executive
Director at Brink, funding Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Localhost Research.

**Mike Schmidt**: Matt Morehouse.

**Matt Morehouse**: I'm Matt Morehouse, I've been working out at Lightning
Network with a focus on security.

**Mike Schmidt**: BlueMatt?

**Matt Corallo**: I'm Matt Corallo, I work at Spiral on LDK.

**Mike Schmidt**: Thank both of you Matts for joining us.  We have an
interesting newsletter this week and we appreciate your input.  We're going to
start with the News section.

_Disclosure of fixed LND vulnerability allowing theft_

Our first news item is titled, "Disclosure of fixed LND vulnerability allowing
theft".  Matt Morehouse, unfortunately you're back on the show again today,
which means another vulnerability disclosure.  This time, you posted to Delving
referencing a blog post of yours, where you outline an exploit on Lightning,
specifically in this case LND, that you call, "Excessive Failback Exploit".  Can
you talk us through the exploit?

**Matt Morehouse**: Yeah, so this is a vulnerability that affects LND versions
0.17.5 and below, and it allows an attacker to steal funds.  The vulnerability
itself exists in the same logic as the LDK force close vulnerability that we
discussed last month.  And what I explained last month was when a commitment
transaction confirms onchain, your LN Node needs to check the HTLCs (Hash Time
Locked Contracts) on that commitment.  And if any upstream HTLCs that are still
outstanding are missing from the confirmed commitment, your node generally needs
to fail those back so that the upstream node doesn't force close the channel.

But what I didn't explain last month is there's actually an exception to that
rule.  There's one case where you absolutely do not want to fail back the HTLC,
and that would be if you know the preimage for the upstream HTLC.  And the
scenario where that could happen would be an HTLC is routed across your node,
and the downstream node reveals the preimage and then signs a new commitment
transaction, where the HTLC is removed from the commitment, and the value of the
HTLC is added to the downstream node's balance.  But at the same time, the
upstream node does not fully complete the resolution of the HTLC.  So, maybe
they go offline or they just ignore the preimage that you relayed to them.  And
in that scenario, if the downstream commitment confirms, it's going to be
missing that upstream HTLC.  But if you try to fail it back, you can lose funds
because the downstream node already claimed it.

So, this is where the vulnerability existed in LND.  Where this scenario would
happen, the downstream commitment would confirm and then LND would attempt to
fail back the upstream HTLC.  Luckily, LND would usually catch itself.  It would
realize it had already relayed the preimage upstream and then say, "Oh, I
shouldn't fail this back".  But unfortunately, before it caught itself, it would
update the database and mark the upstream HTLC as failed, which meant if LND
were to restart before the upstream HTLC got fully resolved, it would then
reload state from the database, think the upstream HTLC needs to be failed and
would send a failure message.  And at that point, LND would lose the entire
value of the HTLC.

This was fixed in LND 0.18.0, where they added a preimage check to this failback
logic so that they don't even attempt to fail it back anymore if the preimage is
known.  So, if you haven't updated yet you should update at least to 18.0.
Preferably just go to the latest 0.18.5.  There's been a lot of bug fixes since
then.

**Mike Schmidt**: Matt, is the restarting of the LND node required in order for
this exploit to go through, or is that just one of the cases in which that might
happen?

**Matt Morehouse**: Yeah, so the restart is required.  So, the attacker would
need to control the upstream and the downstream nodes in order to manipulate LND
into this state where the bug exists.  But once they do that, all they really
need to do is get LND to restart or wait for a restart.  And there's different
ways this could happen.  The simplest, and if I was an attacker, I would just
try to find some unpatched DoS vulnerability.  It's not as difficult as people
might think and I think it's probably easier than finding this vulnerability
was.  I mean, if you just go to any LN node's GitHub page and search for issues
that talk about crashes or panics or assertion failures, every one of those is a
potential DoS vulnerability.  And so, if you find just one of those and you can
crash the node, then this attack becomes very easy to carry out.  And on top of
that, you don't necessarily even need to cause the restart yourself.  LND allows
CLTV (CHECKLOCKTIMEVERIFY) deltas of up to two weeks.  And so, if you start this
attack and then you just wait, and within two weeks if LND restarts on its own,
then you can successfully carry out the attack.  So, you could imagine maybe the
node restarts periodically on its own, maybe they set a certain time once a week
that they restart their node, or maybe a new version of LND was just released
and you suspect they're going to upgrade within the next two weeks, you could
start this attack.

Yeah, so the restart is required, but I think it's a little easier than people
might realize to get that to happen.

**Mike Schmidt**: Yeah, that makes sense.  Yeah, at first I thought this was
only going to be something that somebody like you would know how to get the node
restarted, but yeah, it makes a lot of sense, especially like new releases
coming out.  You probably suspect that that's a likely time to install the
latest version and restart.  One thing I wanted to touch on here was the
relation to the BOLT spec.  Can you talk a little bit about the BOLT spec and
how that intersects with this exploit?

**Matt Morehouse**: Yeah, so the spec in this case doesn't talk at all about
preimages when commitment confirms and this failback needs to happen, and you
might argue that it should be obvious you shouldn't fail back an HTLC when you
know the preimage for it.  But I don't think it was as obvious as we all hope it
would have been.  And so, I submitted a PR to make the spec a little more
obvious and directly call out this issue and say that, if you know the preimage,
do not fail it back, you can potentially lose funds that way.  And I think the
evidence is that this wasn't obvious.  Every other implementation, at one point,
also had the successive fail-back that they would do, and they independently
fixed it.  Whether they realized this was a potential vulnerability or not, I'm
not sure.  But the point is, it wasn't obvious, and I think updating the spec is
good in this particular case and maybe generally for other potential tricky
parts of especially the onchain resolution logic, it might be good to look at
that part of the spec and see, does this actually match up with what my node
implements?  And is there potential problems in the spec or in what I actually
implemented?  Because this is very important stuff to get right.

**Mike Schmidt**: Matt Corallo, you actually made the fix that was referenced in
the Delving post and Matt Morehouse was hypothesizing whether you knew about
this being a bug or an issue when you did it.  So, I guess you could tell us.

**Matt Corallo**: Minor correction, we did not have the same bug.  It was a
slightly different bug that we had related to persistence, inversions and sent
payments, rather than forwarded payments.  So, we would mark a payment as sent
and then it's possible that we didn't persist properly to ensure that the
payment remained sent and then the peer could actually fail the payment.  But
this was a fairly unrelated bug and largely related to the way LDK does
persistence, more related to the way LDK does persistence than anything related
to the BOLTs.  So, we never did have this bug, but I guess maybe the other ones
did.

**Mike Schmidt**: Matt Morehouse, you opened up a PR that we referenced in the
News section this week, and I see as of yesterday, it looks like that PR is
merged, is that right?

**Matt Morehouse**: Yeah, we talked about it at the spec meeting yesterday, and
no one voiced any concerns about it, but there was a general discussion about,
is it valuable to fix these sorts of things in the spec or not, and there are
opinions on both sides.  I know it was expressed that maybe if we get too
descriptive and too exhaustive in the spec, then people stop thinking critically
about it and they just implement whatever the spec says and then that could
cause widespread bugs as well.

**Mike Schmidt**: Murch, any follow-up questions or commentary before we move
on?  All right, Matt Morehouse, thank you for joining us.  You're welcome to
stay on for the remainder of the newsletter, or we understand if you need to
drop.

**Matt Morehouse**: All right, thanks folks.

_Discussion about Bitcoin Core's priorities_

**Mike Schmidt**: Second news item this week titled, "Discussion about Bitcoin
Core's priorities".  Antoine Poinsot posted three blog posts to his blog
recently under a common theme of, "What are Bitcoin Core's priorities?".
Antoine wasn't able to make it today, so Murch and I will give, I guess, our
takes with the caveat that we are not trying to speak for him but just trying to
digest the content that he put out.  His first two posts seem to provide some
context to the discussion.  He outlined that in Bitcoin Core, people are working
on their own things and there is no broad agreement about what the scope of
types of work in Bitcoin Core is.  And thus, with no scope, it is harder to
prioritize for contributors whether to review something or something else, or
what a contributor "should" work on that is more or less valuable.  He then
concludes that without scoping and thus without prioritization, that Bitcoin
Core work will get, "Further dispersed and will inevitably lead to reduced
overall software quality".  He recommends his scope for the project which is,
"Bitcoin Core should become a robust backbone for the Bitcoin Network, balancing
between securing Bitcoin Core software and implementing new features to
strengthen and improve the Bitcoin Network".

He then goes on in his third post to get into some of the details of what that
sort of scope and prioritization may look like.  He sees the Bitcoin Core
multiprocess sub-project as a way to modularize the codebase.  That multiprocess
project has been ongoing for almost 10 years now, I think.  And he recommends
splitting the current Bitcoin Core codebase into three different codebases: the
node itself, the GUI, and the wallet.  And then, he noted some benefits of such
a split, including the workflow of each of these projects not disrupting the
others, the ability for the wallet and GUI to potentially iterate faster and
maybe garner more contributors as a result.  I think there's probably more that,
Murch, you might pull out of there, but I wanted to see if you felt that, is
that a fair characterization of Antoine's position?

**Mark Erhardt**: Yeah, I think the main point that he has is everybody uses
Bitcoin Core as in its node function.  Every user of Bitcoin Core does this and
a lot of the users of Bitcoin Core actually do not use the wallet or GUI
functionality.  They only run the Bitcoin daemon.  They participate as nodes in
the network, they use Bitcoin Core as middleware or as source of truth for their
wallets or their other infrastructure.  And because Bitcoin Core is the main
piece of software used to span the Bitcoin Network, this should be the priority
of the Bitcoin Core project, according to how I understand Antoine.  And the
wallet and the GUI respectively are used by fewer people that run Bitcoin Core.
A lot of users even install it without those components in the first place.

So, separating these into separate repositories and projects may help focus the
testing efforts and the review efforts in the node and make that more robust.
Whereas the wallet could, for example, have a different release cycle.  Whenever
a feature comes out, it could be released immediately, based on the latest
release of the node.  Or if, for example, changes in the node were necessary to
improve the wallet after the release of the latest node update, the wallet could
release an updated wallet with the new feature.  And stuff like fuzz testing
could be split up so that bug hunting, fuzz testing, and all of those things
that are right now covered by people working on node, to a large degree as well
for the wallet and GUI, could be a responsibility of the other projects only.
All right, this is all trying to channel what I understand Antoine's position to
be, just to be clear.

**Mike Schmidt**: There were a few responses that we highlighted in the
newsletter.  We had Anthony Towns questioning whether multiprocess would really
make as clean of a split as was outlined, because the individual components will
still remain tightly coupled, at least as things are today with multiprocess.
And also, Dave Harding expressed some concern around everyday users being able
to validate their own incoming wallet transactions.  Are there either of those,
Murch, that you think are worth double-clicking into?

**Mark Erhardt**: Yeah, so for example, the wallet needs to have access to the
mempool in order to learn about unconfirmed transactions, and that can happen of
course for an interface, but that makes this interface basically now something
that is specified across two projects, which increases the overhead.  And
similarly, the wallet needs to be able to scan the old transactions, needs to
learn about transactions that are relevant to the wallet, wants to calculate
balances and so forth.  So, there's a lot of data that flows between the node
and the wallet.  And then, the GUI is mostly used for the wallet.  So, the GUI
in turn is heavily coupled to the wallet and mostly representing this
information plus a little bit of statistics on who we're connected to, how much
we're uploading, downloading, and so forth.  But the GUI is mostly, again,
tightly coupled to the wallet, so splitting it up would be a lot of work.  And I
think that the interfaces and then having to deal with versioning of the various
releases with each other and making sure that you, for example, keep a feature
branch that depends on a newer version of the upstream project in line with the
older version, it could introduce overhead.

So, it is not completely obvious to me that splitting up the projects would
actually reduce the burden on the node project significantly, especially as long
as no new features are introduced and us having a pretty decent test core set
for all of the projects.  Well, I'm not sure how much maintenance burden is
introduced on the node project that would actually be shed if they were split.

**Mike Schmidt**: Matt Corallo, you are one of the earliest contributors to the
Bitcoin Core project, and I'm curious if you saw any of this discussion or if
you haven't, maybe based on what we've chatted about just now, if you have
initial two cents you'd like to contribute to the discussion?

**Matt Corallo**: I mean, I don't contribute to Bitcoin Core much anymore or at
all really, so I don't really feel like I should have much of a voice in the
conversation when they decide how to structure their projects.  I would just
highlight that obviously, the Bitcoin Core wallet is still fairly important in
the ecosystem, as much as there are many, many other wallets today that there
didn't used to be.  But the last numbers I saw were some years ago, but it was
still doing double-digit percent of the transactions in the entire Bitcoin
blockchain.  So, it's still fairly important that it continues to grow.  And it
is still kind of a fairly good wallet in terms of the technical features that it
offers, even if not necessarily the user experience.  So, it remains an
important part of the ecosystem and it needs to get its love.

**Mike Schmidt**: Murch, anything else you think we should discuss on here?

**Mark Erhardt**: I think it's an interesting discussion and I appreciate that
it would be great if the Bitcoin Core node project could be more focused or had
more resources.  Well, we have always more work than we can do.  And I
appreciate this idea.  It's not a new idea.  This discussion has happened a few
times before.  I think I can see it both ways.  I could see it being split off,
maybe helping both projects to refocus a little bit; but then on the other hand,
I could also see that that causes hardly any benefits for either project but
more overhead.  So, I'm not 100% sure what the right answer is here.

_Private block template marketplace to prevent centralizing MEV_

**Mike Schmidt**: Moving to our monthly segment on Changing consensus, which are
proposals and discussion about changing Bitcoin's consensus rules.  I'm actually
going to jump a little bit out of order in deference to our guest here, and
we're going to go to the third item of this segment, which is titled, "Private
block template marketplace to prevent centralizing MEV".  Matt, you and a
collaborator, 7d5x9, worked on an approach about what the Bitcoin community can
do in response to a future of MEVil on Bitcoin.  Maybe first, what is MEVil in
your definition, and then what does your response to MEVil entail?

**Matt Corallo**: Yeah, so MEV (Miner Extractable Value) is this term that
basically came from Ethereum that is very, very broadly defined and includes
basically all of the revenue that miners or stakers are able to gather.  It's
sufficiently broadly defined that it's not all that useful as a term, and so
some time ago, someone else that I adopted coined the term MEVil, which really
refers to this concept of extractable revenue or revenue that miners can get,
but which is very complicated to get, sufficiently complicated in fact that in
order to get this revenue, miners or stakers, or what have you, have to invest
substantial effort, in various forms, in hiring the most competent engineers,
paying very high salaries to do so, in co-locating servers in the right data
center next to exchanges, or in the Ethereum case, that's the stakers, in having
high capital allocation that they can allocate on centralized exchanges so that
they can do arbitrages across centralized and decentralized exchanges, various
things that really drive up the cost of being a competitive miner.

When you drive up the cost of being a competitive miner, of course, mining is
highly competitive, miners tend to get similar-ish electricity prices and have
otherwise similar revenue.  And so, as a result, if you start driving up the
cost for some miners, then a smaller miner just can't compete, right?  If
there's some additional fixed cost for mining that wouldn't otherwise exist,
then a small miner will just not be able to compete, they won't get the same
revenue, and they'll go out of business.  So, it really drives substantial
mining centralization if we see the kind of MEV extraction games that we see on
Ethereum.  Ethereum does have this problem.

So, what Ethereum has done is they have these large marketplaces.  So, they have
this thing called proposer-builder separation, where the entity that selects the
transactions that go on the block, that builds the block template, is separate
from the staker.  And this means that the entity that selects the block template
is basically a high-frequency trading firm, it's a specialized company that has
these additional resources that can invest in building the absolute optimal
block template.  And the result of this is that some 80%, 90% of block templates
in Ethereum are built by entities and in marketplaces that enforce OFAC
sanctions that otherwise censor transactions going to chain.  And this would be
worse in a PoW world.  Of course, if you have a staker that doesn't make quite
as much money as the next staker, that's kind of okay; if you have a miner that
doesn't make quite as much money as the next miner, they'll simply go out of
business.

So, this is a substantial concern as people start to build more complicated
activities on top of the Bitcoin blockchain, whether it's decentralized
exchanges or more tokens, more trading, stablecoins, all these things might
introduce some risk in the long term.  So, the question is, what can we do about
it?  And so, yeah, a collaborator and myself put out this paper describing
basically a variant of Ethereum's proposer-builder separation, that tries to
maintain censorship resistance and some level of decentralization, while also
allowing these separate entities to do this advanced MEV extraction.  So,
instead of in Ethereum, proposal-builder separation requires that the separation
be full block templates.  So, they propose entire sets of transactions, entire
block templates, and the miner can't add their own transactions.  This is in
part because of Ethereum's design with a global state, but also just generally,
it doesn't have to be that.

So, we propose separating it out so that these advanced MEV extraction companies
can extract MEV and post specific transactions or groups of transactions and
bids in a marketplace, so they can say, "Here's a group of transactions I want
to see included in the block.  As long as they're included, let's say, first in
the block or before some other transactions in the block, I'll pay X".  And
then, the miner can look at those but can also look at the public mempool and
can select the best block template themselves.  Because they can pull from the
public mempool and because they'll pull from the public mempool as long as those
transactions pay the most, it allows you to retain some level of censorship
resistance, but they still can get paid for the MEV extraction activities.

The only further step that we go to is that a lot of these MEV extraction
companies and techniques, they want the ability to have transactions that don't
enter the public mempool at all.  And of course, if they post the whole
transaction data into some marketplace that the miners see, the miners can just
copy and paste it in the public mempool.  So, instead, we propose using SGX, or
some other similar technology, to allow miners to have transaction data which
they can use in building a block template, but not actually be able to access
that transaction data until they find a whole block.  And once they find a whole
block, of course, their local machine and their code running in the SGX
container can reveal that transaction data to them and then they can broadcast
the block.

**Mike Schmidt**: Maybe for our audience, it might be helpful, I think folks
probably see what's going on on Ethereum and say, "Oh, MEV is a problem over
there".  Maybe give for the audience, like, what is a canonical MEV for Bitcoin,
or even MEVil?

**Matt Corallo**: Yeah, so a big part of MEV in Ethereum, something like
double-digit percent of all MEV in Ethereum, is just the arbitrage between the
Ethereum USDC pair on centralized exchanges or decentralized exchanges.  So, as
people look to add stablecoins on Bitcoin, and then people can post one-sided
bids and asks on PSBTs of trades of Bitcoin to stablecoins, that by itself might
introduce the same exact arbitrage concerns that you see in Ethereum.  So,
that's one, and a very obvious way that this might happen as stablecoins start
to become more available on Bitcoin natively.  But of course, there's also
concerns around base roll-ups, client-side validation protocols.  So, there's
various people who've proposed building more generic exchanges, or it's in
Ethereum called the automatic market makers, that people are looking at using or
deploying via client-side validation protocols in Bitcoin, so based on ERC-20 or
similar token schemes, which would also have a similar MEV concern.  But also,
just people generally looking at building client-side validation-based smart
contracting languages in Bitcoin, which it's unclear what level of adoption
those will get if people are at least talking about it.

**Mark Erhardt**: So, if you say the whole MEV thing is bad and so forth, why
are you proposing a marketplace for it in the first place?

**Matt Corallo**: Yeah, that's a good point.  So, basically because we're not
sure what else to do.  So, on one hand, the Bitcoin community might decide to
not use schemes which have MEV concerns, so might not adopt these things.
People might not want them, but people might also just use these things.  The
Bitcoin community might choose to not move forward with various governance
proposals because they might make MEV a little easier, or they might not, or MEV
might happen via a client-side validation proposal that doesn't need a consensus
change.  There's a lot of ways in which MEV might happen that we don't have any
control over, and also the Bitcoin community might decide that the value of some
of these consensus changes which might make MEV easier is higher than the risk.
And so, it's worth having a kind of best worst-case scenario basically, so if we
end up in a world where MEV is a real thing on Bitcoin and it's driving MEVil
and it's driving centralization and we're really worried about this MEVil
problem, then what's the best we can actually do?  And basically, this is our
answer to what we think the best we can do is.

Now it is not great.  I'm not going to be super-happy if the stitch deployed and
all the Bitcoin miners are using it, because it is fairly centralized.  You have
these marketplaces that might become the arbiters of which miners are allowed to
have high-value, high-revenue mining, right?  A marketplace could decide to ban
a miner and that would destroy the revenue.  And so, it is still very
centralized.  But it is better than PBS, and more specifically, it's better than
if we just sit back and do nothing, and MEVil becomes a large problem in
Bitcoin, then the result will simply be that only the large pools, and really
probably only one or two pools, are going to be able to compete at all, and
everyone else is going to pay drastically low.  So, the alternative is much,
much worse, even if this is pretty bad.

**Mike Schmidt**: How do you define a threshold for something that this would
trigger in your mind, or you just get started on it now; or is there something,
a line in the sand that at least you have in your mind for when this would be
something to push?

**Matt Corallo**: I don't have a specific line, no.  I think this is something
that could be built today and maybe should be built today, and then we just hope
that no miners use it.  Basically, the market will probably only adopt something
like this if it actually adds material revenue.  More generally, I think just
hopefully, I think in practice people won't use it, but also it only really
kicks in if there's material revenue to be gained from it, right?  Like, if this
marketplace exists and all the miners use it, well, if there's no revenue from
it, if there's no transaction bids in it, it doesn't really matter, miners will
still pull all of their transactions from the public mempool.  So, I think this
is something that should be built.  I don't really have time to do it myself.  I
think in an ideal world, this would be built and deployed and would be available
for people to use if they have some kind of fancy MEVil kind of extraction they
want to do, and then hopefully this can at least somewhat reduce the
centralization pressure from it.

**Mike Schmidt**: Any notable feedback so far?

**Matt Corallo**: Not really.  I think a lot of feedback of the form that we
expected of like, "Oh, this is bad".  But yes, it is, but it's the best we can
come up with, and no one has proposed alternative schemes, I think, that are
credible.

_LDK #3342_

**Mike Schmidt**: All right, Matt, thank you.  Thanks for joining us.  I'm
hoping you can stay on for just another minute or two, because we have an LDK PR
that you can hopefully help Murch and I with, not to put you on the spot.  But
LDK #3342, which is titled, "Introduce RouteParametersConfig".  What's going on
here, Matt?

**Matt Corallo**: Yeah, so this is just a long tale of BOLT12 stuff, really.
So, we have various config knobs that people can use when they select a route,
including the maximum fee you want to apply, the number of hops, all kinds of
various knobs.  And historically, the way LDK has worked is you get a BOLT11
interface, you set these knobs, you convert it into a route, and then you give
LDK back the route.  But now, with BOLT12, that's not how it works anymore
because you just directly give LDK the offer, and then LDK fetches the invoice
for you and then builds the route internally in itself.  And so, there wasn't a
way to actually set any of these knobs when building a route for a BOLT12
payment.  And so, this is adding the ability to set these knobs for BOLT12
payments.

**Mike Schmidt**: Makes sense.  We have one more request for you to stay on,
Matt, because we have discussion of BIP360.  Are you able to stay on?

**Matt Corallo**: Yeah.

_Update on BIP360 pay-to-quantum-resistant-hash (P2QRH)_

**Mike Schmidt**: Okay, great.  So, Murch, we're jumping all around today.
We're going back up one on Changing consensus to, "Update on BIP360
pay-to-quantum-resistant-hash (P2QRH)", and we've been joined since the intro by
Hunter Beast, who posted to the Bitcoin-Dev mailing list about this topic.  But
Hunter Beast, why don't you introduce yourself for the audience before we jump
into it?

**Hunter Beast**:** **Oh yeah, hi, I'm just the author of BIP360.  I've been
working full-time in the Bitcoin space for about four years now, most of that
time actually is spent on token stuff, so I also have some thoughts on MEV and
MEVil, but we can save those for another time.  But I do respect and appreciate
the work that Matt has put into that because he's thought a lot about it.  And
it's interesting that you're introducing kind of like an AMM technique for
Bitcoin, which is interesting.  Cool.  So, Matt, while you're on, before we go
into the BIP360 update, I don't want to lose your attention because I know that
you have some objections to the P2QRH proposal I have.  You've made some of them
clear on the mailing list, and I just want to maybe hopefully, I don't know if
this is the forum to hash that out, but I do want to kind of communicate about
that if that's cool.

**Matt Corallo**: Yeah, I mean maybe you want to start by explaining what the
proposal is, and then we can get into it?

**Hunter Beast**: Sure.  So, essentially the proposal is to create a new output
type.  We're not supposed to call it an address format because address format is
technically a different thing, like bech32, or whatever, whereas an output type
is like P2QRH.  And so, basically that stands for quantum-resistant hash.  It
introduces post-quantum cryptography (PQC) to Bitcoin, and it also introduces a
separate field in the transaction, called an attestation.  And as a result, it
introduces kind of like a novel way to commit to public keys and their hashes in
kind of a merkle tree format that is distinct from how taproot does it.  And the
reason why it's kind of this distinct abbreviated mechanism that's very specific
to the use case of either single-sig or multisig keyspends, is because it's
basically like tacking on additional locks, or almost not really quite locking
scripts, but just signatures, right, tacking it on to existing taproot
functionality without really augmenting it or interfering with it.

The major reason I wanted to do that was, I wanted a field that had
stripped-down scope with basically no scripting capabilities.  And so that way,
no arbitrary data can go into it that isn't either a public key signature or a
public key hash.  And so, all that can be validated in advance by the nodes
essentially, and so no junk data can really make it in there, unless you really
grind with a bunch of computational power, which at that point you might as well
just pay 4X what you're paying.  And then also, another thing, this isn't
specified in the BIP, but I want to kind of target the capability of maybe a 16X
or some other non-4X discount to signatures and public keys when included in a
transaction.  And so, essentially, that's kind of the high level of the BIP.
Murch, do you have a comment?

**Mark Erhardt**: Yeah, I was going to try to bring it back up a few levels of
zoom.  I feel like we're already very far into the details.  I think the main
point is that there's been a lot of news around quantum computers becoming more
viable in the past couple of years, and we're starting to think about how we
would want to respond to this in the next few years.  And how I understand your
proposal is, you are proposing a new output type that is similar in the
construction to P2TR, except that it doesn't have a keypath spend, as P2TR has,
based on only the key.  No?  Okay, at a very, very high level, would you like to
say it again?

**Hunter Beast**: It doesn't necessarily alter the semantics of taproot, it
really just wraps around it.  It's this additional field where additional
signatures can be added.  And although this isn't specified in the BIP, I'm also
considering making it so that it is exclusive to PQC.  And so, if you want to
include like a schnorr signature, you do that inside of the tapscript, like the
witness, right, inside of the witness.  And so, yeah, it's basically just
bolting on PQC to Bitcoin, and Bitcoin has this assumption that you're only
really using one signature algorithm, and it's dramatically complicated if you
introduce multiple.  And so, that's why I want to kind of scope down what's
capable in the attestation in addition to the potential for abuse.  And even
ordinals people I've talked to aren't keen to have an additional field with
additional discount, or even just increasing the witness discount, because that
kind of debases ordinals in a way.  So, nobody wants that.  If we were to offer
an additional discount, then it would be…

But anyway, you want me to describe essentially what it does at a high level.
It just adds a new output type or address.  Sometimes people call it an address
format, even though it's technically incorrect.  And so, it's just like a new
address that allows a wallet to generate public keys for PQC algorithms.  There
are three specified in the BIP.  And then, it allows you to commit to that in
the address, and then include signatures and the public keys themselves in a
separate field in the transaction, called an attestation.  Is that a good
explanation of BIP360?

**Mark Erhardt**: I think that's better, yeah.  So, what I was going to add was
it basically has a merkle structure similar to taproot.  And in the leaves,
instead of having alternate scripts, we have alternate post-quantum schemes, and
you can then later, I think, spend by revealing a subset of these, I believe
only one, is that right, or more than one?

**Hunter Beast**: Well, it'll be multisig-capable.

**Mark Erhardt**: Okay.

**Hunter Beast**: Yeah, and that's actually something we're working on now, it's
not specified in the BIP.  That is the one piece of the BIP that's really not
well thought out.  And I have some good thoughts on it now, so I'm working on
that basically.

**Mark Erhardt**: All right.  So, what it would allow us to do is to have funds
in a scheme that is post-quantum safe and hopefully we could then, if quantum
computers come to pass, make it impossible to spend with vulnerable key
material.

**Hunter Beast**: Yeah, and one thing, Matt, you brought up was that you don't
think this is the right approach because you have this alternate approach where
you disable keypath spends.  It's not something that I specify in the BIP at
all.  It's kind of orthogonal in functionality, I think.  And so, I'm kind of
curious, does that make sense, my thinking, because if I want to include a 16X
discount, I don't want to necessarily include that for the witness, right?

**Matt Corallo**: I think part of the problem, my main concern with this kind of
thing is it proposes adding various signature schemes that just aren't really an
option today, or that I think don't make sense to deploy today, right?  Like,
actually doing anything other than hash-based signatures basically is too early.
There's various faux quantum schemes, lattice-based and whatnot, but committing
to them in Bitcoin's consensus, when it's non-trivially likely that specific
instances of them will be broken at some point in the next decade, seems like a
questionable idea.  And so, if we take that as not really an option, then the
only thing left is for hash-based schemes, which are incredibly inefficient,
which means really the only thing we could do with them is to have them hidden
somehow such that they're not used today, they're not required to be used today,
and at some point in the future, we make them required.  So, we could do it via
a parallel thing or we could do it as taproot behaves now.

The taproot leaf option has two variants.  There's the variant of, at some point
in the future, we decide that we want to freeze all coins that are not stored in
keys that are PQC, don't have a hash-based signature fallback, which would mean
that we just do it, you just add an OP_SPHINCS+ and you're done, in tapscript,
right?  Or we could do it in the future, where somehow the outputs themselves
commit to the fact that they have a PQC pubkey in the taptree somehow, and that
would mean something like, there's various ways to do it, but you could do it
via a new taproot version, you could do it via a tweaked pubkey somehow, so
there's those two variants.  But I think those are very simple, very
straightforward, and accomplish basically the most we could realistically
accomplish today, again because actually using these things, actually using PQC
in any way today is just really not an option.

**Hunter Beast**: Well, so SPHINCS+, I'm glad you mentioned because it is
hash-based, and so that addresses one of your concerns.  And the 128-bit
version, well, let's call it the NIST I version of it, is actually not terribly
large or super-slow in verification in comparison.  So, it's actually definitely
an option.

**Matt Corallo**: It's still orders of magnitude larger than what we have today.
So, it's still not really something like, okay, we can take the blockchain and
reduce transaction throughput by several orders of magnitude, but I don't think
people would go for that.

**Hunter Beast**: Well, okay, so the thing about SPHINCS+ also is that it's like
ten years old, so it has a good amount of eyes on it, it's DGB crypto, so we can
be pretty confident that it's pretty capable, I think, in the foreseeable
future.  So, it is definitely, like, a good amount of security as an algorithm.
There is however the other complication, like okay, yes, maybe it's larger by a
certain order of magnitude.  Let's just call it both together something like,
actually I can't do the math, but it is much larger.  The thing is if we were to
offer a 16X discount, then maybe that would be not as big a reduction in
throughput.  I've done the math for Falcon, not necessarily for SPHINCS.  I
think it's maybe, let's just do half that for SPHINCS.  It would be like 500
transactions per block, or public key signature pairs, so like the bare minimum,
like maximum, best-case scenario is like 500 transactions per block, if you have
a 4X discount, and this is just my rough mental math.  But if you have a 16X
discount, you could basically double that, more or less.  It depends.  Oh, Matt
had to hop, okay.

**Mark Erhardt**: Yeah, that would still mean that we're going down by about a
factor of 7 or so, per my mental math, if we move to a post-quantum scheme like
that.

**Hunter Beast**: Yeah, so we go from like 7 TPS to like 1, right?

**Mark Erhardt**: Yeah, exactly.  So, it sounds like there's a little bit of
pushback on the approach so far.  There's some questions about how mature the
post-quantum schemes are at this point, when everybody is still sort of
exploring the topic.  Or I mean, people have been working on exploring the topic
for a few decades, but it's never felt really that dire as it did now, and I
think people are stepping up the PQC research at this point a bit.  So, in your
BIP360, you specified a new output type and you introduced a proposal on which
three schemes could be used to construct this output type.  You've gotten a lot
of feedback recently when you announced it, or re-announced it on the mailing
list, your updates.  How would you characterize the feedback that you've gotten
so far?

**Hunter Beast**: Yeah, well, maybe first I should go into the update.  So, one
of the major updates is that we originally had four signature algorithms, but I
had to deprecate one of them because it is substantially slower and if a block
were to take 1 second to verify normally, if they were instead using SQIsign
transactions, it would take more like 4 hours to verify that same block, which
has obvious concerning DDoS implications.  So, that's kind of a no-go, and we
deprecated SQIsign from the BIP.  And I went over some other potential
algorithms we could use, but I described the rationale for just sticking with
the three that were chosen.  And in particular, the FIPS compliance is also a
really good selling point, because it will have more hardware support in things
like HSM and also in maybe even hardware acceleration on SOCs and various
microchips, so that could actually be really useful.  And in the future, to just
be using beaten path crypto, that could be accelerated through hardware.

Then also, I'm not a fan of disabling keypath spends like Matt suggests.  I
provided my reasoning in a separate thread, but basically, I just think that
it's confiscatory and I don't want to interfere with existing capabilities.
Maybe they could do like a segwit v2 that just disables keypath spends, so that
it's basically kind of a QR version of taproot that basically only uses
scriptpath spends, and then it allows you to deprecate schnorr signatures
whenever you want.  But the problem with that is it basically doesn't allow you
to increase the witness discount without also increasing the amount of abuse, or
what some people call abuse.

I did come up with a draft BIP for something called pay-to-taproot-hash (P2TRH),
which just hashes the key, which is like an x-only public key that's provided in
segwit v1.  I just did that for a couple of reasons.  One is to have an
alternative proposal, but also just to go through the full thought exercise of
what that would look like and what the trade-off is.  It's essentially like 8.25
vbyte overhead per input, if you also have to provide an x-only public key in
addition to every schnorr signature.

**Mark Erhardt**: Wouldn't that break batch validation, I think?

**Hunter Beast**: Batch validation, would it break it?

**Mark Erhardt**: Maybe I'm mistaken there.

**Hunter Beast**: Like key aggregation?

**Mark Erhardt**: Batch validation for processing blocks more quickly.  But
yeah, so you're talking about this additional new draft, the P2TRH, and it's
basically P2TR, but except for the key being directly provided in the output,
you would have it hashed, so an ECDSA public key, and otherwise it would work
the same?

**Hunter Beast**: Oh, yeah.

**Mark Erhardt**: They're both keys on the libsecp curve, and there's an ECDSA
signature scheme and a schnorr scheme, sorry.  Yeah, you're correct to call out
my imprecision.  And the idea would be then that we still have a new output type
rather than plugging it into P2TR, right?

**Hunter Beast**: Right, yeah.

**Mark Erhardt**: So, if we're doing a new output type anyway, why not go with
P2QRH anyway?

**Hunter Beast**: Yeah, right.  That's a good question, and I would say it's
better to focus on P2QRH.  So, I just wanted to put that out there as work that
I did, as a sort of thought exercise, like what are the alternatives.  Also,
Matt did his own proposal of just disabling keypath spends, which I don't like.
But if you disabled it in a separate output type, then maybe that would be fine,
so long as it's optional and not mandatory.  But the only problem with that is,
it doesn't solve the problem of short-exposure attacks because, well, why
wouldn't it?  Actually, no, it might, it would, I think it would, yeah, because
if you disable keypath spends and you just didn't use secp256k1, you know,
elliptic curve cryptography at all, then yeah, that could be a viable option,
even against short-exposure attacks, because you're not using a secp or elliptic
curve cryptography, so that's fine.  And that might be a good proposal.  It does
require new opcodes in tapscript.  Basically, what Matt's proposed, like an
OP_SPHINCS+ sig verifier, or whatever, that's definitely a possibility to do.
The only problem with that is we can't discount that additionally without
causing more consternation around potential abuse.  So, that's basically the
trade-offs there.

Also, in the update, I mentioned that people have pointed out that NIST V
signatures are overkill, because they offer 256 bits of security and secp
technically only offers 128 bits of security, even though it literally says
secp256k1.  And that's due to a couple reasons, but one of them is Pollard's Rho
attacks.  So, essentially, it works a lot better if we downgrade from NIST V to
NIST I, because they're also much smaller and faster to verify, and there's no
reduction in overall security assumptions, and so it's not so bad.  And, yeah,
also I mentioned that I'll be going to a few places to advocate for BIP360,
including the MIT Bitcoin Conference in Boston, also an OP_NEXT in Virginia,
BTC++ in Austin, Consensus in Toronto, and BTC25 in Las Vegas, and later in the
year, TABConf in Atlanta.  So, if anybody has any questions, they can also
hopefully hit me up there.

**Mike Schmidt**: Well, there's a good call to action to wrap it up, Hunter
Beast.  I apologize for the late notice on the Recap this week.  I'm glad you
were able to join us just in time to opine on this discussion.  Thanks for
joining us, Hunter Beast.

**Hunter Beast**: Thank you.

_Bitcoin Forking Guide_

**Mike Schmidt**: Jumping back up on the Changing consensus monthly segment, we
have a topic titled, "Bitcoin Forking Guide".  AJ Towns posted to Delving,
pointing to a Bitcoin Forking Guide website that he created.  He references the
BCAP paper, which was from late last year, which is an effort to analyze
Bitcoin's consensus mechanism from the different perspectives of various
stakeholders, including economic nodes, investors, influencers, miners,
developers, and users and application developers.  He expressed dissatisfaction
with the BCAP paper's lack of specific recommendations for both developers
proposing consensus changes as well as actions other stakeholders could take in
the consensus process.

AJ's guide advocates for what he calls, "Consensus before consensus", which he
outlines as an approach to achieve social consensus for a proposed consensus
change before changing the consensus code, which might seem obvious.  The guide
has six phases in total.  The first four phases of AJ's guide are around
establishing social consensus, and then the final two phases ensure that the BIP
and test vectors are ready and that the code is merged and active on test
networks.  And then finally, activation.  Murch, as a BIP editor and also
recently refining the BIP process, you've obviously given some thought to parts
of the processes that AJ outlines, so I wanted to get your take on it.

**Mark Erhardt**: Yeah, I think it's very nice that AJ is approaching this from
a different angle and providing concrete suggestions what to do, and it's also a
lot shorter to read, which makes it more approachable.  I think the research
development and development phase is probably the hardest part.  It's the part
where you really dig up exactly is needed, what exactly the benefits and
downsides and other trade-offs are of how you're trying to approach a solution.
And so, the other parts, the power user exploration, industry evaluation and
investor review, essentially they follow, let's say, at least a very specific
description of the idea, maybe at a level of just before the BIP draft is done,
or maybe even after the BIP draft has been published and is close to being
complete and proposed.  People are actually trying it out, playing around with
it on staging grounds like Inquisition, have maybe thought a little bit about
what sort of constructions they would build with the new proposed tools, and
have been using this exploration as a mechanism to provide feedback for the
proposal.

So, it seems to me that using this description of the entire process, a lot of
the proposals that we've been talking about in the past few months are still in
the research and development or power user exploration phase, and I think the
building consensus part from there is important.  I think that it might be easy
to be caught in looking at your own proposal, often talking to the people that
have questions about your proposal, and then perceiving that there's a lot of
interest by those people that are talking about the proposal.  But it be
difficult to ascertain how much beyond that the idea has even propagated.

**Mike Schmidt**: Although it was meant and is meant to be more actionable than
the BCAP paper, AJ also notes it's only a fairly high-level guide.  Of course,
there's not a checklist or anything like that and this is of course his approach
and his guide.  So, hopefully it's useful for folks in the ecosystem.  I know I
saw Greg Sanders reply to the Delving thread.  He said, "I guess I'd park my
LN-Symmetry Project work under, 'Power user exploration'".  So, there's at least
one person who's thinking or hypothesizing about where their project would be in
this guide.  So, maybe it's useful for others as well.

**Mark Erhardt**: Hunter Beast has someone working on a potential consensus
change.  Did you have a look at the writeup from AJ?

**Hunter Beast**: Yeah, actually.  It's good.  I can say that we're still firmly
in step one, but step two, which is the power user exploration, I think we're
moving towards, as I work on test vectors, even though it's still kind of like
step one, but people can kind of test out the cryptography side of things,
because I'm actually forking Rust Bitcoin into something that supports PQC and
also the separate attestation field.  And so, I think that'll be fun for people
to play with.  You would have to be a power user though, but it would be
basically like what you'd want if you wanted to add PCQ to your wallet or node
software or LDK, that kind of thing, right?  And so, yeah, it's also just really
helpful to spell out the steps, because back when I was at OP_NEXT, the OP_NEXT
that we had in Boston of last year, the general consensus was that we kind of
don't know how to fork Bitcoin anymore.  I mean, with Vlad, who stepped down as
the lead maintainer, largely because he was being attacked by Craig Wright
through the legal system, and then if he didn't appoint anybody else to succeed
him as a lead maintainer, largely because if somebody had, then they would also
be a target of those legal attacks.  And so basically, in some ways, Craig
Wright could be credited with crippling Bitcoin Core dev, but that's maybe a
controversial opinion, a spicy take.  But regardless, that's kind of my
understanding of it.

So, for us to recover that capability to do more community-driven soft forks,
instead of something that has the blessing of a Core dev, then it's really
useful to have an explicitly outlined set of steps for people to have
merit-based community consensus, and for us to outline that these steps have
been gone through and that's just all part of the PoW.  And so, I guess there's
maybe a higher standard now for soft forks, as there should be, because another
thing is, Bitcoin is a $2 trillion asset class now.  And so, that's great, but
also makes everybody super nervous, including myself, of making any changes to
it.  And so, there has to be very much like the PoW put in to establish
consensus and we can just tick off the boxes in a way, right, "Have we gone
through all six steps?" or at least the prior steps, and there's like kind of
subtasks for each step that AJ outlined.  And so, yeah, basically, that's my
opinion of it.  It's very good work, and I'm really glad he did it.

**Mark Erhardt**: Mike, back to you.

_Core Lightning 25.02_

**Mike Schmidt**: I think we can move to the releases and release candidates
segment this week.  We have one release, which is Core Lightning 25.02.  I'll
read a few of the notables from the release notes.  I did not reach out to
anyone from Core Lightning (CLN) to come on, so apologies there.  Core Lightning
25.02 includes channel backup features that allow CLN peers to be watchtowers
and allow the node to generate penalty transactions; it also has the ability to
restore blacklisted runes, the permissioning system used in CLN; there's a bunch
of fixes to xpay; the setconfig fix that we talked about recently is in there,
so CLN doesn't crash if you don't have right access to the config file; it fixed
a bug where, "We would fail to collect our own funds if we force closed a
channel we had leased with experimental-dual-fund"; there's better splicing
interoperability with Eclair; BIP353 DNS payment instruction support in the
fetchinvoice RPC; there's improved channel limit data in the listpeerchannels
RPC; there's a new set of notifications for when a plugin stops or starts; and
the clnrest is now a Rust plugin.

_Eclair #3019_

**Mike Schmidt**: Notable code and documentation changes.  Eclair #3019 is a PR
to prioritize a remote commitment instead of a local commitment coming from the
Eclair node itself.  So, because the local nodes version of the commitment
transaction would need to include CSV delays and the remote one wouldn't, if
there is already a peer or a remote commitment in the mempool, Eclair will now
just leave that one instead of creating this less favorable one that would then
compete with the remote commitment.  The remote commitment also doesn't need any
additional transactions from the local node to resolve any pending HTLCs.  So,
there's a couple of reasons that Eclair would want to defer to a remote
commitment, and they've put that logic in in this PR.

_Eclair #3016_

Eclair #3016 adds internal functions for creating taproot Lightning transactions
for simple taproot channels.  The PR notes that there are no functional changes
to Eclair yet, but it's also notable that the scripts in this PR differ from the
open PR to the BOLTs repository for simple taproot channels.  In this case,
Eclair actually used miniscript to generate the scripts, which is the origin of
the difference in the scripts.  And I saw that there was actually some
discussion on the BOLTs simple taproot PR, discussing the miniscript
compatibleness, if you will, of some of the scripts.  So, that discussion is
ongoing.

_Rust Bitcoin #4114_

Rust Bitcoin #4114 is a change to Rust Bitcoin's mempool policy to allow for
transaction sizes down to 65 bytes.  This matches Bitcoin Core's current policy
and is a change for Rust Bitcoin, which had the previous limit as 82 bytes.
Murch, it makes sense that Rust Bitcoin would match Core's policy, but why did
Bitcoin Core's transaction relay policy change from 82 bytes to 65 bytes in
2013?

**Mark Erhardt**: Basically, we came up with new output types that we declared
standard that would allow us to have smaller non-witness parts of transactions.
And the magical limit seems to be 64, above 64, because there is a weakness in
the merkle tree construction for the block in Bitcoin where there is not a
distinction between the leaf nodes and the inner nodes of the merkle tree.  And
therefore, you could use a 64-byte transaction to confuse wallet software by
pretending that a transaction is an inner node of a merkle tree.  And to prevent
that, Bitcoin Core prevents using 64-byte non-witness parts of transactions.

_Rust Bitcoin #4111_

**Mike Schmidt**: Thanks, Murch.  Rust Bitcoin #4111 adds support in Rust
Bitcoin for pay-to-anchor (P2A) outputs.  P2A outputs were added in Bitcoin Core
28.0, and P2A, along with a slew of other mempool policy features, were covered
in Greg Sanders in a nice writeup on the Optech blog titled, "Guide for Wallets
Employing Bitcoin Core 28.0 Policies".  So, if you want to read about P2A and
also some of the other goodies in Bitcoin Core 28.0, check that out for the
details.

**Mark Erhardt**: We also, I think, discussed that in Newsletter #315 if you
want to listen.

_BIPs #1758_

**Mike Schmidt**: BIPs #1758, which is, "BIP374: Add message to rand
computation".  Murch, resident BIP author, or sorry, BIP editor, and author
actually, what's this one all about?

**Mark Erhardt**: So, this didn't introduce BIP374, but updates BIP374, and
BIP374 deals with the Discrete Log Equality Proofs (DLEQs) that we use when we
want to create a silent payment with multiple senders in the transaction.  There
has to be a way for the senders to contribute to the creation of the output and
the silent payments output, which is based on the key material of the inputs,
and the DLEQs are used to prove that the shard for the output was correctly
provided.  And someone noticed that there would have been a potential if there
were more than one DLEQs provided for the same public key and combined public
key for the sum of all inputs, and if this proof also used the same nonce, you
could leak the private key of the input that you're signing for.  So, instead of
that, the new construction with the rand field using also the content of the
message, commits to something that is different for every transaction that is
being created.  And that way, this, although hopefully unlikely, but existing
vulnerability is mitigated.

_BIPs #1750_

**Mike Schmidt**: BIPs #1750, which is also an update to an existing BIP.  This
is an update to BIP329, and the PR says, "Add optional data fields, fix a JSON
type".  Murch?

**Mark Erhardt**: Yeah, BIP329 deals with the wallet label import and export
format.  And what this update does is to add a few more optional fields that are
not necessary to just import wallet labels between wallets, but that might be
useful if the same format is used in the context of descriptors or for
reporting, when you want to know the exchange rate at which transactions were
created, and things like that.  So, with these optional fields, it might be
easier, for example, to export transaction history from a wallet if you need to
do accounting for your own books or tax reporting, or something like that.

_BIPs #1712_

**Mike Schmidt**: And last PR this week, or PRs, it's BIPs #1712, which is BIP3
updated BIP process, and also BIPs #1771, BIP3 address follow-ups.  Murch, do
you know anything about these?

**Mark Erhardt**: Yeah, I've been spending a bit of time in the roughly year
now, last year.  We had last year a big discussion on some of the frustrations
and friction with the BIP process.  This, on the one hand, led to a few more BIP
editors being added to the repository, and us now being six BIP editors that
process changes, updates and new BIPs to the repository. And additionally, there
was a lot of discussion about what works and doesn't work that well with the
current BIP process.  So, the current BIP process was specified by BIP2, I
think, a little over eight years, and as you might imagine, Bitcoin has changed
quite a bit in the last eight years, and there have been a few issues with the
process that just aren't addressed in an eight-year-old document.

So, I've talked to a lot of people that are invested or contributing to the BIP
process, collected what changes we might want to make, and ended up writing,
essentially it started out as an amended version of BIP2, but I think for the
most part it is a complete rewrite at this point, that covers a new proposed
process for how we write BIPs, how BIPs move through the various statuses, and I
want to think that in a lot of ways it's a bit streamlined and made easier.  We
have, for example, nine statuses in the old BIP process and the existing active
BIP process, and this new proposal only has four statuses.  And there's some
other parts in BIP2 that just never really achieved widespread adoption, such
as, for example, the comment system that got removed.

If you are invested in the BIP process and interested in that working well, I
would like to invite you to give the recently merged BIP draft, or BIP3, a read
and comment.  I've been a little busy moving to the West Coast myself and as I
pick up this, I hope that I can soon move it to a complete proposal, or rather a
proposed proposal, according to BIP2, so that I can suggest it for activation.
And at that point, I would hope that people have thought a little bit about
whether or not this serves their needs better than the existing BIP2 process.

**Mike Schmidt**: Well, congrats on all your work on that and the move as well.
That's it for the newsletter today.  Thank you to Matt Morehouse and Matt
Corallo for joining us, thank you to Hunter Beast for jumping in at the last
minute as well, and of course to my co-host on the West Coast, Murch.

**Mark Erhardt**: Thank you and hear you soon.

{% include references.md %}
