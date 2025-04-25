---
title: 'Bitcoin Optech Newsletter #348 Recap Podcast'
permalink: /en/podcast/2025/04/08/
reference: /en/newsletters/2025/04/04/
name: 2025-04-08-recap
slug: 2025-04-08-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Jonas Nick, Jameson Lopp,
Steven Roose, Gregory Sanders, and Salvatore Ingala to discuss [Newsletter
#348]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-3-21/398749658-44100-2-0388b8108ed22.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #348 Recap.
Today, we're going to talk about an experimental secp256k1 implementation; we
have our monthly segment on Changing consensus, which this month includes
discussions about quantum theft of bitcoins, the use of hashes to help mitigate
quantum threats, we have a consensus cleanup draft BIP.  And in a separate
recording tomorrow, we're going to discuss the benefits and criticisms of the
proposed CTV (OP_CHECKTEMPLATEVERIFY) and CSFS (OP_CHECKSIGFROMSTACK) soft fork,
as well as the CCV (OP_CHECKCONTRACTVERIFY) specification.  I'm Mike Schmidt,
contributor at Optech and Executive Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Localhost.

**Mike Schmidt**: Jonas?

**Jonas Nick**: Hey, I work at Blockstream's research team, mainly on
cryptography topics.

**Mike Schmidt**: Jameson?

**Jameson Lopp**: I'm Co-founder and Chief Security Officer at Casa.

_Educational and experimental-based secp256k1 implementation_

**Mike Schmidt**: Well, thank you both for joining us.  We have one news item
this week, which is titled, "Educational and experimental-based secp256k1
implementation".  And we have on Jonas.  Jonas, you posted to the Bitcoin-Dev
mailing list about secp256k1lab, which is a Python library for prototyping.  You
noted that the goal of the project is to, "Provide a single, consistent
interface for secp256k1-related cryptographic specifications".  Maybe, Jonas,
you can talk a little bit about this new library, and also I think some of the
history of how it came to be might be interesting for us.

**Jonas Nick**: Right, maybe I'll start with that.  So, our starting point for
this was that we were working on the ChillDKG work-in-progress BIP, which is a
BIP that is distributed key generation for FROST, which is an entirely separate
topic.  But what ChillDKG does is it uses the secp256k1 curve.  So, we wanted to
write a reference implementation and a specification that specifies ChillDKG,
and for that, we needed these curve operations.  And so, what BIPs had done in
the past was that they had a custom implementation of the secp curve operations
somewhere in their Python code, and then they considered the entire package of
the actual protocol code and the secp codes to be the reference implementation,
the specification of the BIP; which means that as a result now, we have five or
six times even in the BIPs repository almost the same code that deals with these
curve operations.  And I say almost, because there are really sometimes these
very tiny, subtle differences which don't seem to matter much, but if you want
to write specifications, then it matters whether the function returns or throws
an exception or returns none.

So, what we wanted to do, instead of writing our one custom, one-off
implementation of secp was to essentially collect the best out of all these
implementations of secp that we have and create this one library with a
well-defined interface, and then we would just use this this library inside of
ChillDKG.  And we've worked on that library and then last week, we published it
on GitHub, so now it's usable.  I wouldn't call it experimental, so we don't
really want to include all the things you can do in Python there.  What we want
to do is we want to have people experiment with it, which is slightly different.
It's not experimental because we use it in the specification of ChillDKG right
now, so we don't want to mess with the code too much really.

**Mike Schmidt**: The first thing that comes to mind is the XKCD about one more
standard.  So, there's all these implementations, so what do we need?  We need
one more implementation.  But jokes aside maybe, Jonas, why is there this need
to include Python code in the BIP?  Why not just reference secp?

**Jonas Nick**: Oh, yeah, so that is a good question.  First, regarding the
standard thing, now there's a new standard, I would counter that so far there
hasn't been a standard, there have just been implementations.  So, no one has
called their implementation a standard before, so this would be the first real
one.

**Mike Schmidt**: Okay, that's fair.

**Jonas Nick**: So, what was the question again?

**Mike Schmidt**: There's a real secp; why do we need a Python BIP secp?

**Jonas Nick**: So, the reason is, first of all, that BIP specifications and
reference code is just usually written in Python.  So, the easiest way to add
secp256k1 curve functionality is to have a pure Python implementation that is
also easy to read, easy to use, doesn't need a separate build system.  So, that
is something that we also optimize for in secp256k1lab, which is that it should
be easy to read, there's no kind of weird optimizations that make it
particularly fast or anything.  We don't try to be fast, it should be easily
readable, and that is the main goal.  And also, we don't use a package manager
right now.  So, the ChillDKG reference code, you can just execute it via the
normal Python interpreter, no need to install a package manager or anything.  We
just include the entire library in the ChillDKG reference code.

**Mike Schmidt**: Now, we've already talked about one potential user of the
256k1lab, which would be, I guess, authors of BIPs would reference this in some
capacity.  Is this something that you think other users or projects would do in
the prototyping stage, even if it's not related to a BIP, they're building
something else, or isn't that not a good candidate for this library?

**Jonas Nick**: I think for prototyping, it's definitely a good candidate.  So,
besides the secp curve operations, it also currently includes an implementation
of BIP340 schnorr signatures.  And perhaps we can add more things, particularly
ones that are already specified and have test vectors that we can easily add.
So, one project that is currently integrating this library is the
work-in-progress FROST signing BIP.

**Mike Schmidt**: Is there going to ever be a plan for this to be production
grade, because I think people may see this, "Oh, it's experimental because it's
new"; but is the idea that this would always be something that's experimental
and shouldn't be in production?

**Jonas Nick**: I mean, I wouldn't call it experimental.  I would really make
the distinction between being experimental and used for experiments.  We don't
want it to be experimental, because we use it for specifying ChillDKG, but it's
not production in the sense that you would want to run this in a production
setting.  It is very slow and we don't care about speed, because we care more
about being easily readable.  But more importantly, it is probably or most
likely very, very insecure because it has all these timing side channels, these
timing leaks, and we don't try to prevent those at all because really the
library is intended for specifications, experimentations and learning.

**Mike Schmidt**: Murch or Jameson, do either of you have questions for Jonas on
this?

**Jameson Lopp**: Sounds good to me.  I don't really work at the protocol level,
so we use the libraries that are given to us.

**Mike Schmidt**: Jonas, it is awfully kismet and coincidental, but we have a
bunch of quantum discussions today that perhaps you have some opinion on
components of that.  So, that's my segue to the Changing consensus segment for
this month.

_Should vulnerable bitcoins be destroyed?_

We noted that there were multiple discussions about quantum computing, both
theft and then how to resist such theft, the first one titled, "Should
vulnerable Bitcoins be destroyed?"  Jameson, this item was based on your
Bitcoin-Dev mailing list post, which was titled, "Against Allowing Quantum
Recovery of Bitcoin".  Your email and thought process all seemed well organized,
so I won't try to frame this up.  I'll let you frame it up, this discussion, for
the audience as you see fit.

**Jameson Lopp**: Yeah, so I thought this was an interesting thought experiment.
I did not want to wade into the quantum debate because I feel like it's very
similar to trying to debate climate change.  It's one of those, hopefully,
far-off problems, but also very difficult to pin down and quantify exactly what
the level of threat is.  But on the flipside, even though it's hopefully a very
far-off problem, we know that making changes to Bitcoin is a very, very slow
process.  So, this is the type of potential existential threat that we want to
get as far ahead of the curve on as possible.  It's also unprecedented in the
sense that we've never had an issue before where we basically wanted everyone to
migrate their UTXOs.

So, there comes this question of, how do we want to handle that?  Do we want to
further incentivize that?  Are we going to be worried about the potential
fallout of not incentivizing it?  And so, there's sort of a complex,
multi-layered set of overlapping issues here.  There's both the philosophical
issues, there's the economic issues, there's the game theory issues.  And so, I
wanted to try to create as comprehensive, multifaceted look at this, because I
know, and what I've seen already from just mentioning it to people, is that
there's a very common knee-jerk reaction of, "Oh, we must never break the
inviolable property of preventing someone from spending their coins".

But as I go into with my posts, one way or another, regardless of what the
ultimate decision is here, I believe there are going to be violations of
so-called inviolable properties.  And so, people are going to get hurt one way
or another.  And what we're going to have to decide is which path in the
decision tree will hopefully result in the least overall harm to all of Bitcoin
users.

**Mike Schmidt**: Did you come to a conclusion?

**Jameson Lopp**: Well, as I said, there are multiple potential outcomes, and my
post is really about what I consider to be the happiest path outcome, which is
one where we have come to a decision about a quantum-safe signature scheme, and
we're currently even nowhere near that, so this is somewhat speculative about us
getting to that point; and then the issue is, do we do something with these
quantum-vulnerable coins to prevent them from falling into the hands of
attackers?  And my high-level conclusion is that, if we get into a position
where we have that migration path open, that it would be best to have some date
at some point in the future whereby we say, "You need to have your migration
done".

I mainly look at this from a security and incentives perspective, because you
think that people are generally going to follow the incentives and that it's an
obvious thing that you're going to move your coins to make them safe if there is
a threat.  But from my own experience, a very concrete example of when I was
working at BitGo and we implemented segwit, we rolled out the new SDKs and the
new APIs, and then we watched for adoption of our clients to migrate over to
segwit, which was an obvious win, because it fixed transaction malleability, it
enabled for cheaper spending of UTXOs.  There were real tangible benefits to it.
But what we found is that even large enterprises that were our customers, and
were supposed to be sophisticated and have teams of experts behind them, were
laggards when it came to adopting this new technology.  And for many of them,
what we actually ended up having to do was to write our own scripts that were
calculating how much money it was costing them to not upgrade.  And then, you
have to manually reach out to people and say, "Hey, you're losing $10,000 a day
by not upgrading.  And, of course, we can't do that at the protocol level.
There's no way for us to reach out to all Bitcoin users and inform them of these
things.

So, from that perspective, if we believe that most humans are lazy laggards,
they're gonna procrastinate if they don't feel like they're in immediate danger,
then I think that having some very specific drop-dead date will help incentivize
that migration.  And then, of course, there's many other issues, such as the
fact that of course, many of these coins will never migrate because they're lost
and, for whatever reason, can't be accessed.  And what do we want to do about
the potential economic ramifications of suddenly having tens, if not hundreds of
thousands, maybe even a million or more bitcoins flooding into the market and
going concentrated most likely into a very few hands of tech giants or nation
states, or what have you.

**Mike Schmidt**: So, we wrote that you provided arguments for and against the
destruction of these coins that wouldn't move by potentially some deadline, but
you concluded in favor of destroying/making unspendable those un-migrated coins.
Maybe talk a little bit about a few of the arguments towards that, and we
outlined them in the newsletter, but maybe it would be good to hear from you?

**Jameson Lopp**: Yeah, I mean, there were quite a few.  So, I already covered
the sort of incentivization issue.  Let's see.  So, the most common thing, like
I said, that people have the knee-jerk reaction is kind of the moral and
philosophical aspect of essentially confiscating or stealing people's funds.
And the conclusion that I came to on that was that it's basically a wash,
because either you have the protocol, the entire network agree to freeze, burn
these coins, or you basically know that they're going to fall into someone
else's hands.  So, arguably, it's theft one way or another, so I don't really
see that as being a strong argument either for or against.  There is the
economic disruption argument of what happens to the actual overall value of the
network, and how does that have ripple effects upon the entire industry.

I would never go so far as to claim that allowing these thefts to happen would
destroy Bitcoin or prevent the network from operating.  But I do think that if a
large number of coins fall into a small number of hands, they are going to
liquidate a decent portion of them.  And the main reason that I believe that to
be the case is, just look at what happens with any other large-scale theft,
especially like North Korea.  Really, when one entity all of a sudden comes into
possession of millions or billions of dollars, they tend to do what they can to
diversify it and preferably get it out of Bitcoin as a system to use it for
other things.

There's somewhat of a precedent issue here.  We've also seen pushback that it's
not really in the purview of Bitcoin as a system to decide how people should be
securing their coins.  And I don't think that that's necessarily the case.  If
you look at the entire history of protocol changes, a number of opcodes have
been both added and removed over the years.  And those are specifically saying,
"We will allow or disallow you to lock your coins based upon this given set of
functionality".  It has been a long time since opcodes had been removed, that
was more Satoshi era stuff.  But back in the day, many were removed because
Satoshi decided there was not enough confidence that certain pieces of
functionality were in fact safe to use.

**Mike Schmidt**: You mentioned that there's technical considerations and
economic considerations as well.  And it seems to me that this is maybe already
becoming a little bit of a polarizing thing, where people are sort of,
"Obviously this is the way we go or obviously this is the way we go".  There's
two I'll call out really quickly here.  In one of the threads, not your thread,
Jameson, but another quantum thread, we have Pieter Wuille saying, "Of course
they have to be confiscated".  Okay, so there's Pieter's stance.  And then, in
response to a tweet I had provoking this discussion on Twitter, you have Parker
Lewis, who's maybe more on the economic side, saying, "Quantum theft, 1,000X,
not even a question", and then he goes into some economic rationale of why you
should allow that.  And I saw even, Jameson, you were promoting that you were
going to be on this discussion and somebody says basically, "Of course this is a
terrible idea", you know, so it seems quite polarizing.  Murch, it sounds like
you're itching to say something or no?

**Mark Erhardt**: I think Jameson wrote this in his write-up, but I don't
understand the point why we would be incentivizing development of quantum
computers.  Sure, they might be useful for some stuff, but why would we give
them a big portion of the Bitcoin UTXOs just because they ended up being the
first ones to develop a completely unrelated technology?  That just doesn't
compute from the incentive structure of Bitcoin, especially if it's coins that
arguably can be thought to have been lost.  Because if we do enact the soft fork
of, up to this stage, you have to spend all P2PK UTXOs, or whatever, and after
that they're lost if you don't, there will be a lot of coverage.  You'll
basically have to live under a rock to not hear about it.  So, if you then, over
the course of several years, don't move your coins, the only conclusion can be
that either you still didn't hear about it, and I don't know how you would do
that, or you lost your coins.  And if your coins are lost already, we're
actually not changing the status quo by confiscating them, and we would in fact
reapply them to the UTXO set by giving them to quantum miners.

So, I haven't seen Parker Lewis' argument, maybe he has some convincing points.
But from what I've seen, I just don't see a point for that stance at all.

**Jameson Lopp**: Yeah, I mean, so I pulled it up.  So, Parker said, "It's not
for the network to decide how people secure their bitcoin".  I obviously
disagree with that.  It is absolutely our collective incentive for people to
keep their bitcoin as secure as possible, and there have been precedents for
that previously.  Let's see.  He said, "You can't know for sure that they're
otherwise lost".  That is correct.  There is no way to know for sure, there's
only the issue of us trying to incentivize people to migrate their coins.  Let's
see, "It would set a terrible censorship precedent for the network and break a
previous valid contract".  Yes, and my argument is that that was a wash, because
this contract is going to get violated one way or another.  Let's see.  Then
there was, "Theft is still theft in any jurisdiction".  Yes, that is true, but
Bitcoin doesn't care about laws or jurisdictions or anything.  So, once again, I
also think that the moral argument is a wash there.  And then he makes the point
that, you know, the attackers would only be able to spend it once, and that is
true.

So, there's no way for us to quantify whether this would be a very long-term or
a short-term volatility, because we don't know how quickly the attackers would
be able to scoop up all of these coins, we don't know what they're going to do
with all of those coins.  Then he was suggesting that anyone who steals bitcoin
would have a priority in maximizing value.  Well, I would think they would have
a priority in maximizing the total liquidity that they could extract, but I
don't know that they would necessarily become like Michael Saylor or hodlers.
This is all speculation, of course.  So, this is a very complex issue to talk
about, and so that's why I focused not only on the philosophical and moral
aspects of it, but also on the game theory.

If we look at the actual game theory around what would be required to "burn"
these coins, it's a soft fork.  So, you don't have to get consensus from all
node operators.  You just have to get sufficient mining pool hash power
consensus.  So then, I haven't gone out and talked to the various mining pool
operators and major miners about this, but I suspect they would probably prefer
to have the value of their bitcoin not be even more volatile by giving a bunch
to quantum attackers.  This is an open question and I'm sure eventually we'll
get around to having those discussions.

**Mike Schmidt**: Jonas -- oh sorry, go ahead, Murch.

**Mark Erhardt**: Yeah, I wanted to also bring up another point that came up in
your thread.  So, as you said, humans tend to procrastinate.  If we do set a
clear deadline of, let's say, four years out or something even longer, every
UTXO that is vulnerable would have to be moved before that date.  Of course,
other people still want to use blockspace for their transactions, their
day-to-day needs, so it might help to incentivize or increase the transaction
fees on the network.  But if people procrastinate, it might end up in a run on
the blockspace toward the end of the deadline, because people miscalculate,
think they have more time than they have, because we might actually use a very
significant portion of at least a year's worth, if not multiple years' worth of
blockspace to move all these UTXOs.  So, sure, the people that are on top of it,
they would move early, get it cheap.  But then, maybe the last few months, we
would have a huge feerate spike and only the people that can afford it.  So,
game theoretically, probably the most valuable UTXOs would be saved and the
other ones would remain vulnerable past the date and thus be burnt.

But so, there's a very clear advantage to the deadline being a single day,
because everybody has that date and they know it and it's easy to remember.
Would it perhaps be better to time out UTXOs based on age so that it spreads out
a bit.  So, let's say 15 years after the UTXO was created or 20 years after the
UTXO was created, would be at least five years away for all these vulnerable
UTXOs.  And then, they would spread out and become burnt at separate times.  And
maybe that would help spread out the blockspace demand.  Have you thought about
this?

**Jameson Lopp**: Yeah.  I mean obviously, when we're talking about changing the
rules, you could change them to almost anything that you can imagine.  There
were some people who responded on the mailing list about alternative methods of
trying to basically gate the spending of quantum vulnerable coins.  You can do
that from a counting UTXOs perspective, but I don't think that you can actually
gate it from a value perspective.  And really, what I mean there is that the
value of the bitcoin is not distributed evenly across all UTXOs.  And I think I
had in my article, even if we go through the happy path and all of the active
folks migrate before Q-day, there are a number of addresses with over 10,000
bitcoin in them that haven't been touched in like 14 years that are most likely
not going to move.  Very specifically, I called out James Howells, the guy whose
hard drive is in a landfill in Wales.  He has 8,000 bitcoin and a vulnerable
address.  We know that's not going anywhere and that would get scooped up.  So,
my point is, I don't think that we can programmatically clamp down very much on
what the economic disruption would be.

There have also been other people who have very hand-wavily said, "Well, what if
instead of burning them, we try to actually reuse them for thermodynamic
security and basically change the subsidy, you know, add it to the subsidy in
the far future?"  And of course, that's totally possible, but I suspect that
that's going to be even more contentious.  I haven't seen any concrete proposals
on how to do that.  I'm of course more than open to reading anyone's ideas about
that.  I just suspect that, you know, keep it simple stupid; having a flag day
is probably the most straightforward way to go about it.

**Mike Schmidt**: Jonas, have you given any thought to this angle of the quantum
discussion?

**Jonas Nick**: Yeah, I wanted to ask Jameson on his opinion on an alternative
to a flag-day proposal.  I mean, Murch mentioned the five years out, or
whatever, which seems a bit early to me, but there's this problem of when is
this flag day, which seems to be difficult to coordinate way before it happens.
So, there's this alternative where you essentially put a discrete logarithm
challenge on the blockchain, which has a lower hardness than the secp256k1, so
it's easier to break than the usual public keys that we use in Bitcoin.  You put
it in the chain and then you add a rule that whenever this is broken, this is
spent, or whatever, then these rules apply, for example, making the quantum
vulnerable public keys unspendable.  What do you think about that?

**Jameson Lopp**: Well, I guess that is then going to be under the assumption
that someone who has quantum supremacy would actually trigger the rule, right?

**Jonas Nick**: Yes, you need some white knight to do that.

**Jameson Lopp**: Yeah.  I mean, it's theoretically possible.  I just don't
know.  If I had quantum supremacy, I probably would avoid triggering that rule
and try to enrich myself as much as possible before any burning or freezing or
whatever actually got triggered.  So, yeah, it's a tough problem, but thankfully
I think we have a long time to discuss it.  And like I said, it's not even the
most pressing issue.  First, we actually have to come to agreement on a
migration path before we can even talk about incentivizing people to use the
migration path.

**Mike Schmidt**: I dropped in the chat this btcpuzzle.info, which I think came
up in a Stack Exchange question at some point, where there actually is a bunch
of bitcoins, 1,000 bitcoins locked in different levels of hardness of the
private key.  But there's actually a range specified for each of these bitcoins
that are locked.  Is that something that would be a canary in the coal mine to
quantum, or is that just a different kind of puzzle?

**Jameson Lopp**: I guess it depends on if their public keys are exposed.

**Mike Schmidt**: They are, yeah.

**Jameson Lopp**: It's been a while since I looked at that.  So, yeah, it really
comes down to, what's the bounty?  So, if there's one with 1,000, that would
probably get triggered before probably people started going after the
Satoshi-era 50 bitcoin coinbase outputs.  But I don't think it would get
triggered before some of these other addresses with tens of thousands of coins
in them got scooped up.

**Mike Schmidt**: That's fair.

**Mark Erhardt**: Yeah, there's the Binance cold wallet, which I think, is it
over 100,000 bitcoins?

**Jameson Lopp**: Pretty much all the major exchanges seem to have over 100,000
coins in one address that already has the pubkey exposed.

**Mark Erhardt**: Yeah, so I wonder with the puzzle as well, if it's just a
puzzle without a reward, the cost might be very significant.  But if you
attached a huge bounty, such as the 1,000 bitcoins or even more, then perhaps
the white knight would not only do it for the good of the network, but say,
"Okay, I can either try to spend my quantum supremacy on going after one of
those really big addresses and steal", and that might work once or twice.  But
then if there's more than one entity, especially one that can do it at like a
thousandth of the power, they very much would perhaps think that collecting the
bounty on this trigger, UTXO with the lower difficulty, would be worth it.
Like, the second runner-up might have more incentive to collect the reward on
the trigger.

**Jonas Nick**: Right, so the question is, how big is the gap between actual
secp curve security and the puzzle?  Because if the gap is wide enough, then
maybe you have some quantum attackers which are not white knights which are
waiting until they actually can break secp, but you have this one good guy who
triggers this puzzle.  But it's probably difficult to find a suitable puzzle for
that.  So, I imagine a lot of discussions on that.

**Jameson Lopp**: Yeah, I mean I kind of mentioned it before, but in order to
actually accomplish this, you don't actually have to make any code changes.
There doesn't have to be anything implemented in the nodes.  It could actually
be done just as an agreement amongst the different Bitcoin mining pools to stop
including transactions that spend from quantum vulnerable addresses.  And I
could certainly see that situation playing out if we start to see massive
movement of quantum vulnerable coins earlier than we're hoping for.

**Mark Erhardt**: Well, in that case, I very much would prefer a flag day, where
people know in advance that this is to be expected, and not the mining pools
unilaterally starting to, in this case, maybe call it censoring.

_Securely proving UTXO ownership by revealing a SHA256 preimage_

**Mike Schmidt**: We have two more quantum related items this week.  The second
one is, "Securely proving UTXO ownership by revealing a SHA256 preimage".  This
is a post from Martin Habovštiak.  He posted to the Bitcoin-Dev mailing list
referencing Jameson's post saying, "This is somewhat related to Jameson's recent
post but different enough to warrant a separate topic".  Martin goes on to
outline an idea, which we noted in the newsletter is similar to an idea from Tim
Ruffing from 2018.  And Martin's idea, as I understand it, and I'll defer to
smarter people on this to help translate, but a user essentially can commit to a
quantum-resistant signature in an initial Bitcoin transaction, which can prove
ownership over a quantum-resistant private key without exposing any vulnerable
data.  So, that all happens in this first Bitcoin transaction.  Then later, the
user can spend both that old output as well as a quantum-resistant output
together, revealing the quantum-resistant signature.  And then, the rules would
ensure that that old output can't be spent independently of this
quantum-resistant output, they must be spent with the quantum-resistant output
as well.  This would force an attacker to either forge a quantum-resistant
signature or rewind Bitcoin's blockchain past that original first transaction's
confirmation.

One assumption that's baked in here is that we have some sort of a
quantum-resistant signing deployed, but if there were something like that out
there, is this a good idea?  Murch, Jonas, Jameson, anybody wants to chime in?

**Jonas Nick**: Yeah, so I think the main idea is that you add this additional
step.  So now, in order to spend from the quantum-vulnerable, I shouldn't say
quantum-vulnerable, this only works for outputs that are the hash of some
preimage where the preimage is unknown, right?  So, this doesn't work for P2PK,
or something like that.  And what you add is, you add an additional transaction
where you essentially commit to some data, and then you make an additional
transaction which actually allows you to spend these coins.  So, it's this
two-step process.  This is also known as a Guy Fawkes signature and it works.
The downside is that you have suddenly these two transactions, maybe that's
fine.

So, I think Martin, he brought this up to argue that these P2PKH outputs, for
example, they don't need to be burned or confiscated, because you could devise
ways in how to spend them and the Guy Fawkes signature would be one of them, but
there are also other alternatives.  For example, you could, in a single
transaction, provide a zero-knowledge proof of knowledge that you know the
preimage without revealing it, and only you can do that, if only you actually
know the preimage.  That sort of depends on how your wallet is set up, etc.  So,
this would be an alternative, of course.  I would think at least the ZK approach
would be quite a bit more complex, but at least it doesn't need two
transactions.  So, yeah, I think these are the two things you could do there.
Both work and have their trade-offs.

**Mark Erhardt**: The ZKP, that replaces the reveal of the preimage of the, in
this case, public key hash.  That would be a hard fork though, because of course
old nodes would not know how to interpret the ZKP, right?  Or I guess, do you
have an idea?  Could it be done as a soft fork potentially?

**Jonas Nick**: Sounds like it would be a hard fork.  Yes, maybe there are
creative ways for how to solve this, but right, the way you phrase this, this
would be a hard fork.  And of course, the ZKP might be succinct, at least in a
theoretic way, but concretely, it might be quite large and take rather long to
verify.  Like, it could be really, really large.  So, perhaps the Guy Fawkes
signature approach is the better one there.

**Jameson Lopp**: Just yet another wrinkle to this whole debate that hasn't
really been brought up too much yet, because we don't have consensus on what the
quantum-resistant signature scheme is going to be, but it's looking like they're
probably going to be much larger from a data size perspective.  And it's not
outside the realm of possibility that if it comes down to it and we end up
having to use an order of magnitude more data onchain per transaction, this very
easily could reignite the block size debate.  And so, we might be headed for
some sort of hard fork anyways.

**Mark Erhardt**: Yeah, although at least in BIP360, the idea is to introduce
another section to the transactions that could have different rules, sort of
like with the segwit approach of discounting a separate section of the data that
is only visible to upgraded nodes, which would be possible of course.  But yeah,
there is some extra special care that you need to take so you can't use that as
a data dump, and then you need to start transferring all that extra data at
least among upgraded nodes.  I think it might very well be more than one
magnitude more, maybe even two magnitudes more data.  And then, I think what
struck me around the conversation with this Guy Fawkes scheme there, I think
some respondents pointed out that the way the scheme was described, or depending
on how it's designed exactly, it could easily turn the new transaction also in a
quantum-vulnerable transaction, but only for short-term attacks.  So, once you
reveal the public key, the attacker might be able to RBF your transaction by
recovering the private key from the revealed public key.

Maybe these respondents misunderstood how exactly the construction worked with
the commitment.  If you do spend a quantum-resistant input too that is required
for the quantum-vulnerable UTXO to be spent, then of course it would be safe,
because the attacker wouldn't be able to make the quantum-resistant input commit
to the vulnerable input.  But if it's just a hash that you hash into your
signature, they could just produce another signature that uses the same offset,
and then they would also validly spend a pre-commitment, right?  So, all of this
is very complicated.

**Jonas Nick**: I'm not sure if that is a misunderstanding, but because that
should actually not be possible.  That is the promise of this Guy Fawkes
signature that that doesn't work, as long as the commitment transaction is
deeply enough confirmed in the blockchain.  So, there are variants of these Guy
Fawkes signatures, and none of them have been really written down in a very
precise way.  But the things I've seen also in the Optech Newsletter, they don't
work with just the UTXO model that we have.  So, the way you've wrote this down
is that nodes, they need to search for the first transaction, or whatever which
refers to that old output.  That would be a global state.  So, that would be
something new.  I believe that you could probably get this somehow better into
the UTXO model, but if that doesn't work, then this would definitely be a
downside that you would suddenly have to have this new global data structure.

**Mark Erhardt**: Yeah, there were some other mentions where people were like,
"Oh, we only burn public key hash type addresses if they've been used before".
But again, if you want to know what addresses have been used before, you have to
keep track of every single address that was used before in the whole blockchain,
which is quite a big database.

_Draft BIP for destroying quantum-insecure bitcoins_

**Mike Schmidt**: We have one more quantum-related discussion this week.  It is,
"Draft BIP for destroying quantum-insecure bitcoins".  So, this is a sort of
ongoing theme here, sort of piggybacking on Jameson's discussion.  So, if the
Bitcoin community decided, as Jameson somewhat recommends, that
quantum-vulnerable coins should be eventually destroyed if quantum risk to
Bitcoin was imminent, there would need to be some process, and we've touched on
this a bit in our discussion, but there need to be some process to achieve that
end.  So, Agustin Cruz posted to the Bitcoin-Dev mailing list a draft BIP that
describes potential processes that could happen if quantum computing comes and
there's a need to disable bitcoins that are vulnerable to quantum theft.  The
BIP is titled, "Quantum-Resistant Address Migration Protocol, QRAMP", and the
idea is to enforce some sort of mandatory migration period for funds that are
held in legacy bitcoin addresses to migrate to some future version of
quantum-resistant addresses.  The BIP is high level but it does outline how such
an enforced migration might go, including specifying terminology like migration
period of time, a migration deadline, a grace period, the rationale for this
approach, and potential criticisms of this approach.

Most of the mailing list discussion was not around this idea of the process of
enforcement, which is what the BIP was discussing, but similar to what we
discussed earlier, on whether there should be any enforcement of a forced
migration to quantum-safe addresses to begin with.  Murch, Jonas, Jameson, did
any of you get a chance to look at this BIP in any detail?

**Jameson Lopp**: I think I only skimmed it, but one other thing that came to
mind is that, like we said, there's no way to definitively reach out and inform
all users, though an existential crisis like this is going to be all over the
news, and hopefully all wallet software will implement some sort of alerting, so
that anyone who even opens a wallet will end up learning about it.  But one
other way, purely from a protocol perspective of trying to get people to realize
something is happening, is having a graduated process where you basically
restrict the creation of outputs.  Like even today, I think you're still allowed
to actually create P2PK outputs, right?  There's still there's still a handful
of people out there who are doing that, and we have no idea why.  But if all of
a sudden, you were doing that and you noticed your transactions were getting
rejected, you'd probably look into the reason behind it.

**Mike Schmidt**: Well, like I mentioned, most of the discussion, at least so
far at the time of the newsletter being authored, was around whether there
should be enforcement of a forced migration or not.  Maybe there'll be more
discussion on this in the future.  Murch, did you have something to say?  I was
just skimming the BIP draft briefly and I saw that the example period for forced
migration was 20,000 blocks, and that seemed quite short.  And that was what
made me shake my head here.

**Mike Schmidt**: Perhaps just an example.  Murch, one thing on the UTXO set, we
had discussed in maybe I think it was the previous item, that, "Hey, watch out
if you have a lot of bitcoins in a single address, right?"  Does this discussion
ramping up on quantum incentivize bitcoin holders to bloat the UTXO set with
smaller-value UTXOs?  It's sort of like, just don't be the slowest antelope,
right?  Like, if you just split up your coins enough and bloat the UTXO set
enough, you won't be targeted.

**Jameson Lopp**: I mean, from where we're standing right now, what I think it
incentivizes is people to not reuse addresses.  That's one of the biggest
problems.  Bitcoin address reuse is bad for privacy, but now it should be clear
that it's also bad for security.

**Mark Erhardt**: Yeah, and I think that's a nice side effect, one that we
should definitely promote more, like the knowledge about it, I mean.  I think
that the BIP360 draft definitely recommends having smaller UTXOs.  They talk
about basically the old coins mined by presumably Satoshi acting as a form of
shield for any UTXOs that are smaller than 50 bitcoin.  Again, in the context of
multiple exchanges having several hundred thousand bitcoin across three or four
addresses, I think once these get collected and dumped on the market to
diversify, it doesn't really matter whether your bitcoins are in a few UTXOs or
many UTXOs, you're in for a wild ride of volatility.  And so, I would push back
a little bit on the argument that it makes a lot of sense to fan out your UTXOs
more in order to be less of a target.  I think it still makes sense to have some
sort of distribution of values.  So, you have some small coins, some bigger
coins, some big chunks, to have some of the right sizes around what you're
trying to spend and not to have too much future blockspace debt.

**Mike Schmidt**: Moving on to the scripting portion of the Changing consensus
segment this week, we are joined by three special guests.  Greg, you want to
introduce yourself?

**Greg Sanders**: I'm Greg, I work at Spiral.

**Mike Schmidt**: Steven?

**Steven Roose**: I'm Steven, I'm a building Ark at Second.

**Mike Schmidt**: And Salvatore.

**Salvatore Ingala**: I work at Ledger on Bitcoin stuff.

_Criticism of CTV motivation_

**Mike Schmidt**: Thank you three for joining us for this segment this week.
The next three items are all discussions about a potential CTV and CSFS soft
fork.  Activating CTV and CSFS as a soft fork has been discussed on Twitter
increasingly in the last month or so, and some of that discussion is also now on
the Bitcoin-Dev mailing list and Delving Bitcoin.  In the newsletter this week,
we highlighted some of the discussions.  I think these discussions are likely to
overlap, so feel free to chime in with something appropriate, even if it's not
exactly on topic.  But I will at least start in order of the newsletter and we
can go from there.

The first item that we highlighted was titled, "Criticism of CTV motivation".
This was motivated by AJ Towns posting to the Bitcoin-Dev mailing list about
recursive covenants with CTV CSFS.  He pointed out that BIP119 that specifies
CTV has as its motivation allowing covenants, but avoiding recursive covenants.
And in the newsletter, we referred to these as perpetual covenants as well.  But
AJ goes on to show that if you add CSFS and bundle that with CTV, it actually
enables recursive covenants.  We'll get into definitions in a second, because I
think there's some discrepancy on what is a recursive covenant.  But AJ outlines
one approach to achieve recursive covenants in his post, and he links to an
example on the MutinyNet testnet, and he sort of walks through in his post how
he achieved that.  Since that post, BIP119 text was then updated to remove this
potentially conflicting language from the BIP, which we covered I think it was
last week.

Then, there was some debate about terminology that I referenced.  You had
roasbeef mirroring an argument from Jeremy Rubin from 2022 saying that the type
of covenant that AJ created is actually a recursive but fully enumerated
covenant, seemingly a separate classification from just general recursive
covenants.  That's point one from AJ.  He has a couple other points, but I'll
pause there.  I don't know if, Murch, do you have any idea of the
classifications of recursive versus recursive but fully enumerated versus a
normal covenant?  Is this now a standard nomenclature?

**Mark Erhardt**: I think the distinction here is supposed to be whether
something ends eventually.  Like, you have to set how many rounds it goes, then
it's fully enumerated.  But I think AJ made this point earlier as well, that if
the number of rounds that something can be enforced is arbitrarily large, you
just have to pick it in advance.  There is not a functional big difference to a
perpetual unlimited variant.  If you can make it last for 1,0000 iterations or
something, that may well just be in perpetuity, because UTXOs don't move that
often.  But other than that, yeah, I think the point is whether or not the funds
are forever beholden to the covenant after they come in or not.  But I'm sure
our guests have better idea of what the state of the debate here is.

**Mike Schmidt**: AJ wasn't able to join us, so I did my best to try to explain
that.  But if Greg or Steven or Salvatore, if I butchered that and you want to
add on to it, feel free to chime in on that item.

**Steven Roose**: I mean, if I can, I want to say, I think it's useful to maybe
think about the difference between a fully enumerated covenant or a not fully
enumerated covenant.  But the example that was posted as the example of either
of them, like a fully enumerated covenant you could build with CSFS, it's not
really meaningful because you know exactly that the money is going to be burned
in fees, because the only thing it can do is create itself again, exactly
itself, right?  So, it's kind of the same as burning.  Sure, we can talk about
what it means for a covenant to be fully enumerable or not, and the semantics
there will be significantly different than they will be probably meaningful to
talk about.  But in the context of showing that you can do either of them with
CSFS I think is not as meaningful, because the only fully enumerable covenant
you can make is one that basically spends itself to fees eventually.  So, it's
the same as just sending your money into an OP_RETURN, and no one can do this
accidentally.  You have to send your money into this thing, so you know you're
going to burn your money.  It's kind of equivalent to an OP_RETURN, I think.

**Mike Schmidt**: Okay.

**Mark Erhardt**: I want to jump in there because if you send it to an
OP_RETURN, it cannot be spent and neither collected by miners.  So, if you're
saying that the covenant spends it to fees, then it's different.  But yeah,
you're saying that the author basically gives up control of the money by putting
it into the contract.

**Mike Schmidt**: And is that what was done in AJ's MutinyNet testnet example?
If that's what roasbeef is calling recursive but fully enumerated, and recursive
but fully enumerated means it just replicates itself and spends everything to
fees, is that what AJ did on MutinyNet?

**Greg Sanders**: It doesn't put a new state, I believe, is the assertion.  So,
what he did was, he basically had it where it could go to the same script over
and over again, but go nowhere else.  And also, the amounts stay the same as
well.  So, the actual local state stays the same forever.

**Steven Roose**: Yeah.  I didn't want to say this is what a fully enumerated
covenant is.  There can be meaningful, fully enumerable covenants, but this is
just not a meaningful one.

**Mike Schmidt**: Okay.

**Mark Erhardt**: So, Steven, I think you said that with CSFS, you can only do
one that goes from the same state back to itself.  Is that also true for the
combination of CTV plus CSFS, or was that an intentional distinction that it
just is based on?

**Steven Roose**: Well, the example I read on the mailing list, I think was only
using CSFS.  I haven't seen a different example.  The one on the internet, I
don't know if that's referring to the same one.  I haven't seen one that seems
more elaborate that is maybe using a combination of both, so maybe I'm missing
part of the context.

**Greg Sanders**: No, I'm pretty sure you used both, I don't know the exact
details, but basically you're doing, oh man, I should have studied this.  It's
sort of like putting the signature in the script, kind of thing.

**Steven Roose**: Oh, using CTV, okay.

**Greg Sanders**: And then throwing away the key.  So, you make one signature
and you delete the key, and now the coins can only move in the authorized path,
which is recursively to a CTV path.  That's right, you use the signatures and
the hash as witness data, so it's not committed to.

**Mike Schmidt**: So, it sounds like the takeaway from this first point from AJ
is more along the lines of, "Hey, the motivation for the BIP was this and not
this other thing.  I just did this other thing if you add in CSFS, so maybe we
should reword the BIP", which Jeremy did.

**Greg Sanders**: Yeah, I think it's a fair point because if we write a BIP
where we say this is intentionally weak, restrained, but then if it's ever
revisited, even in the future, so let's say we got CTV by itself and then later
do CSFS, then the motivation, the original BIP would have been wrong, no fault
of the author.  So, I think making a design, unless it's hyper-explicit, should
be pretty careful not to assume that it can't be composed with other
capabilities.

**Mike Schmidt**: AJ went on, and this is the second point from the newsletter
under this segment, he goes on to say that during his implementation of this
example that we just spoke about of the recursive covenant, that he found that
the tooling for using CTV, he found it to be pretty inconvenient saying, "I
don't think this is a good indication of ecosystem readiness with regard to
deployment".  What do we think about that?  Did he miss some tooling that's
available?  Does it matter?

**Steven Roose**: I mean, then actually, as a response to that, I went on
Twitter and asked if there was any library whatsoever who supported any taproot
features before taproot was activated.  And the only example was the Python
thing that was used with the only purpose to study taproot and its
functionalities in the review.  So, there was no tooling either for taproot at
the time.  And CTVs, I mean, I think there's actually a bunch of tooling around
for CTV that is just, because it's so small, you can write your own CTV tooling
in like 15 lines.  I did it last week.  And so, people will probably have it
around in small pieces of codebases, but maybe it's not merged yet in upstream
libraries.

**Greg Sanders**: Be fair to AJ, he would also say that was probably a mistake
to have taproot rollout without tooling built out.  So, this is part of his
evolution, I think.

**Steven Roose**: Yeah.  But what I'm saying is many libraries don't want to
merge things that they're not sure are going to actually roll out, because then
they might have to delete it again, make a breaking change.  So, the fact that
it's not a feature in libraries that exists today doesn't mean that it's not
ready.  I have by now written two versions of it for two different projects
where I was using this, but it's not merged into the upstream libraries that I'm
using, I just wrote it myself.

**Mike Schmidt**: And isn't Sapio some fairly robust framework for composing
these sorts of things, or has that just not been updated, or is that not part of
this conversation?

**Steven Roose**: Well, I think Sapio, for sure it has CTV support, and I think
it's still a working thing that people can use.  There's also examples on GitHub
where you find vaults implemented with CTV.  They must for sure have
implementations of the template hash function.  So, yeah, all of the examples
that exist using CTV must have something where CTV exists.  And I think they
will be upstreamed as soon as people know it's actually in the pipeline to be
merged or to be activated.

**Mike Schmidt**: And then, the last point from AJ here is comparing CTV and
CSFS to a more comprehensive overhaul of script.  AJ has basic Bitcoin Lisp
language, or bll, and then there's also simplicity from the Blockstream research
folks.  And maybe to articulate AJ's point by quoting him here, "For me,
bllsh/Simplicity approach makes more sense as a design approach for the long
term.  And the ongoing lack of examples of killer apps demonstrating big wins
from limited slices of new functionality leaves me completely unexcited about
rushing something in the short term.  Having a flood of use cases that don't
work out when looked into isn't a good replacement for a single compelling use
case that does".  This is maybe getting more into the philosophical side of
things, but Steven, what do you think about that quote from AJ?

**Steven Roose**: I might have changed his mind last weekend!  No, I actually
spent like an hour last weekend sitting down with AJ and whiteboarding our Ark
design, and also a potentially improved Ark design that would use CTV, that I'm
going to probably detail next weekend at OP_NEXT.  No, I'm going to do it.  So,
I think I changed his mind a little bit on the maybe not working designs,
because he might just not have had the time to look into it before; on the
aspect of long-term solutions like Simplicity and bllsh, yeah, I mean, script is
obviously not the holy grail I think, but it's what we have today.  And I prefer
to think in the next 3 to 5 years instead of the next 10 to 20 years for now
because, yeah, we're trying to make things work that currently don't work.

**Mike Schmidt**: Greg, do you have a thought on that point?

**Greg Sanders**: Nothing particular.  I mean, I basically agree with Steven
that these projects are very long-term, and it's hard to know.  This is a very
difficult problem space to know how much overhaul we should be doing versus
local optimization.  And I think there's no close form answer here.  I think in
the short term, if there's obvious things to be done, we should probably do
them.  But that doesn't mean we shouldn't be looking at bllsh at all.

**Mike Schmidt**: Murch, any thoughts before we wrap up these sub-bullets?

**Mark Erhardt**: I thought it was funny in the newsletter that Laolu pushed
back to AJ on the readiness of the tooling, saying that his tools were very
straightforward.  And then the newsletter says neither of them mentioned which
tools they use, which sort of replicates our conversation, that it looks like a
lot of people have some sort of tools, but there doesn't seem to be publicly
available resources.  And yeah, if you don't say what you're using, it's hard to
evaluate the claim.

Regarding Simplicity, I mean I'm not up to the latest.  I think I heard from
Russell O'Connor last winter, in November, that it may be coming to Liquidity
soon.  But it's been sort of this five-year project, maybe ten-year project by
now that nobody really has a timeline on.  And yeah, so I'm sympathetic to the
view that we can maybe plan with Simplicity in five to ten years, especially in
Bitcoin where now if it's going to come out, I think AJ said it's like 30,000
lines of code to evaluate and we can spend five years talking about a
50-line-of-code change.  So, if someone's coming up with a 30,000-line code
change, I think even if it were available for merging right now, it might take
some time until people get comfortable enough to even consider that.  So, yeah,
if you want the tooling in the next five years, maybe that's not the easiest
path forward.

**Mike Schmidt**: I should note also that both roasbeef and James O'Beirne went
on to doubt the readiness, which I think we're agreeing on here in this
discussion, of bll and Simplicity in comparison to the readiness of CTV and
CSFS.

_CTV+CSFS benefits_

Next segment related to CTV and CSFS are, "CTV+CSFS benefits.  Steven, you
posted to Delving a post titled, "CTV+CSFS: Can we reach consensus on a first
step towards covenants?"  In that post, you link to your ideal Bitcoin protocol
roadmap, which involves enabling CTV and CSFS ASAP, followed by Great Script
Restoration at some point, and then followed by something like OP_TXHASH and
some form of direct introspection, TWEAKADD/ECMUL.  I don't know if we need to
jump into that entire roadmap, but you did in that post have a section titled,
"CTV+CSFS, what do we actually get?"  Steven, what do we actually get?

**Steven Roose**: Yeah, I think we get a whole bunch of small optimizations, but
I think they are meaningful enough.  This is obviously not a holy grail package,
right?  I think CTV and CSFS are both quite limited in their greater
functionality scope.  But for a start, we get APO (SIGHASH_ANYPREVOUT), right,
we get LN-Symmetry.  We get a slightly limited version of APO, but we can do
re-bindable signatures, so we can do a version of LN-Symmetry.  The DLC space, I
think, is growing significantly, and they have confirmed that CTV for them would
be a very meaningful optimization, both in performance and in interactivity.
And yeah, for us, for Ark, CTV is, even before I made that post, it was for me a
significant game-changer for Ark.  And recently, we've discovered an even bigger
game-changer for us.  So, for Ark, it's definitely a big game-changer.  For LN,
it can be a big game changer, it depends on the enthusiasm for LN-Symmetry.  I
don't follow the space too closely.  I know in the beginning, everyone in LN was
very bullish on eltoo and LN-Symmetry.  I know since then it has gone up and
down a little bit.

But I've heard from the latest, I've talked to some LN people, is that still
most of them eventually, if it would be possible, they would want to adopt an
LN-Symmetry version instead of the current penalty version, because it has
benefits.  They might be favoring other user experience benefits on the short
term, because they might be more significant than eltoo, but eventually they say
that eltoo is a better design.  And this would be possible to be built with CTV
CSFS.  And then, there's a whole range of other smaller things.  You can build a
very limited form of vault with CTV, maybe.  But I think CTV is just a good
general tool that then people can also try and build some other small
optimizations for.  In the very general sense, CTV just makes non-interactive
presigned transactions.  So, any protocol that does any form of presigned
transaction between two or more parties can then just cut that interaction.
They don't have to exchange signatures and they can just use CTV to do it in one
step.  And that's, I think, a general-purpose tool that many protocols
eventually can use.

CSFS equivalently is a very basic thing.  You have a signature, you have a
message, a pubkey, and you check if the pubkey actually signed or the private
key actually signed the message.  I think it's a good basic package.  It's no
holy grail, but I think there are primitives that can be useful in whichever
path we choose along the line to enable more powerful covenants.

**Mike Schmidt**: Greg, Steven mentioned a few things there, but I wanted to
double-click with you on LN-Symmetry and your thoughts about CTV and CSFS with
LN-Symmetry.

**Greg Sanders**: Yeah, I think it's not quite a drop-in replacement, it's
close, because you can't simulate SIGHASH_SINGLE, but for a SIGHASH_ALL kind of
replacement, it drops in pretty neatly.  I also think that the capabilities that
it affords, although I'm guessing other opcodes could do it too, but the
capabilities it affords allows kind of more simple constructions of multiparty
channels.  So, I think one large direction to go forward in the future for LN is
to look at multiparty channels to ease liquidity requirements and increase
payment success.  And I think LN-Penalty just doesn't scale the multiparty.  And
once you're re-architecting, you might as well go with something that's simple
and understandable.  And that'd be my continuing pitch here.

**Mark Erhardt**: Steven just said something that I want to repeat, because I
think it's a 'click' moment, "CTV just makes non-interactive presigned
transactions".  I think that may be the most pithy summary of how to think about
CTV I've heard so far.

**Steven Roose**: Most what?

**Mark Erhardt**: Pithy, like short and concise and precise.

**Steven Roose**: Oh, okay.

**Mark Erhardt**: I hadn't considered it that way.  Of course, there's the
options to resolve in multiple different ways.  But would you consider that, is
that a crutch to think about it, or is that a pretty accurate description?

**Steven Roose**: You're asking Greg now, right?

**Greg Sanders**: I think it's on point, if that's what you're asking, yeah.
And then in conjunction, CSFS allows you to make that re-bindable signature.
So, without CSFS, it's essentially where you can commit it into the output,
right?  It gets committed to, and that becomes kind of a non-interactive
signature of sorts.

**Steven Roose**: Yeah, so I forgot to mention that actually the BitVM folks are
also, when I made the post, they already were quite excited that CTV could cut
some of their interactivity.  But now, I think last week, Jeremy and Robin sat
together.  And Robin told me that Jeremy convinced him that they can actually
cut out one of their two signing groups, so they don't need to do a presigning
committee that presigns all the possibilities that they will later use for these
presigned transactions because of something that CTV also does.  Because CTV
commits to the scriptSigs, you can actually commit to sibling inputs, because it
doesn't commit to inputs, because then you would have a hash cycle.  You can't,
in the output, commit to itself, to its own input.  So, that's the only thing
that CTV does not commit to.  But it does commit to the scriptSigs of all the
inputs.  So, if you combine a CTV with another P2SH input on the same
transaction, you can actually commit to the redeem scripts of the other inputs.
And that's how in BitVM, they can actually tie the spending of one input to also
the spending of another input using CTV, without needing a signature for that.

I don't understand BitVM entirely, but Robin was very excited and said that this
could be a very meaningful optimization for them as well.

**Mike Schmidt**: You gave the example of Robin and Jeremy sitting down and sort
of discovering this together, or at least Robin becoming aware of it.  And I
think it sounds like you and AJ had a chat and you enlightened him on at least a
piece of Ark.  How should the audience think about, "Well, these are experts and
they're still discovering this thing"?  Is that a sign that, "Well, clearly CTV
is the route to go, because look, we're discovering all these ways to use it";
or is it a sign that there should be more time because we're still discovering
the space here?  How would you weigh one or the other?

**Steven Roose**: I've always made the argument that it takes a very particular
-- this is a more general argument, it takes a very particular kind of person
and mindset to be trying to invent schemes and applications and protocols with
tools that don't exist yet.  Most people are more pragmatic, they're going to
work with the tools they have.  So, it takes a specific mindset to like, "Oh, if
we have this, then we can do this", and there are some researchers in this space
that do this.  But I think more people are more pragmatic, and as soon as a tool
exists, I think we can have a whole new group of people actually trying to build
with this.  And the more this becomes real, I think the more people are actually
thinking.

But then to come back to your question, I think CTV has its inherent limits,
right?  It's not the Holy Grail, it can just commit to the hash of a
transaction.  So, I'm not worried that people will come up with something that
is dangerous in some way.  Yeah, maybe they can come up with cool ways, like the
BitVM thing, like commit to a sibling, yeah.  But committing to a sibling is not
some kind of like, I don't know, you can say a new primitive, you can commit to
a sibling with a signature, right?  It's just, again, removing that signature.
Yeah, so I think it shows that the closer we come to something actually becoming
a reality, the more people are going to think about it, and the more
applications actually might still come in small ways.

**Mark Erhardt**: Talking about people that invent schemes and think about how
to use schemes that aren't available yet, Salvatore, you've been listening to
this debate.  What do you think about the state of the debate with CTV and CSFS?

**Salvatore Ingala**: So, I didn't comment much because I didn't follow the
discussion super-closely.  I skimmed through it, but I wasn't super-clear on the
details.  In general, I like both opcodes, let's say.  I've been working, in
some of the demos I did in my own research, I was also using CTV in some of
them.  Of the two, I will say I have less doubts that there might be potential
for changes for about CSFS than about CTV, not big changes, so even CTV I think
is a good primitive for what it enables.  I will say the only doubt I have on
the specs of CTV is, so one of the design choices of CTV is to make sure that
you have stable txids, which if you are adding just CTV, is an obvious choice
that you want to have, because you want to work with existing protocols, like
extend on existing protocols that use presigned transactions.  And the only
doubt I have is that in the future, with more powerful covenants, we might end
up not really using presigned transactions as much, meaning you authorize
spending conditions in different ways, not with signatures.  And so, this choice
of forcing a stable txid might not be optimal for some of these potential future
protocols.

So, this is the only thing that I feel like possibly, in the future, might not
be optimal in how CTV is designed today.  And that's why I think exploring CTV
together with other potential future opcodes could be anyway interesting,
regardless if you're adding these future opcodes soon or now.  About readiness
in terms of doing a soft fork now, I'm not as bullish in the sense that I don't
see the wide consensus forming anytime soon, even if I wouldn't oppose a soft
fork with either of these opcodes.  And so, yeah, I'm still in the exploration
phase, I would say.

**Mike Schmidt**: Steven, I saw you nodding during Salvatore's articulation
there.  Did you have something to piggyback there or just agreement?

**Steven Roose**: No, it's a good point that our current protocols, because we
only have presigned transactions, are all based on txid stability.  That's the
whole point why segwit was introduced because LN also uses this.  And CTV of
course plays on that, because like I said, it's some kind of optimized version
of a presigned transaction.  Yeah, I mean I can see, for example, Ark also
progress into a more faraway future where it's more optimized and we don't build
on txid stability anymore.  And it's true that in that case, maybe CTV is no
longer as useful.  But I'm not sure if everything will have to move away from
that.  Maybe the simpler protocols can still be based on that; something like LN
can maybe still be based on that.  Because I think multiparty channels would be
more optimal if they don't have to be based on txid stability.

But yeah, I mean maybe a counterpoint I can say is that the maintainable codes
we have for CTV is something, like Murch said, like, well, you said 50, but the
actual code of the CTV hash is maybe like 20, 25 lines of code.  It's not crazy.
If this in ten years ends up not used, I wouldn't be too disappointed with that,
given that in those ten years leading up to that, we can actually take a lot of
advantage from it.  But yeah, it's a concern to take into account.  I think CTV
will stay useful for a quite significant amount of time, but let's see.

**Salvatore Ingala**: To be slightly more precise on why I think it's not
optimal in some cases, is that most of the times when you're using CTV, what
you're constraining is just all the outputs.  The transaction template in your
mind is, "Okay, what are the outputs that I'm allowed to have in this
transaction?" and you don't care so much about all the other fields of the
transaction.  But because we want stable txids, the CTV hash is also committing
to a bunch of other things, like nSequence, and all the number of the inputs,
for example, and all these things that would potentially change the txid.  And
in some protocols, maybe you don't want to have these constraints, because maybe
you want to have multiple more inputs, you want to be able to add more inputs
because, for example, you have to reach some amount and so you want to add more
inputs the same way that we do with normal wallets.  And in this case, you could
still do it with CTV, but first you would have to do a previous transaction to
aggregate some inputs together.  It's a small thing.  There is no situation
where these constraints break a protocol, I think, but it could create some
annoyances that some other slightly modified opcodes might not have.  So, I
wouldn't call this an opposition to CTV.  In fact, I like it and I think it's
useful.

**Steven Roose**: But I think if you say slightly optimized opcodes, the opcode
that I would see solving these problems of not needing txid stability, or not
committing to everything in the transaction, would be TXHASH.  And I wrote the
specification and implementation for TXHASH, so I obviously like it, but I
wouldn't call it a small optimization over CTV.  It's an order of magnitude more
lines of code.

**Salvatore Ingala**: TXHASH is a lot more general than CTV.

**Steven Roose**: Yeah, okay, you could maybe find some balance in the middle.

**Salvatore Ingala**: CTV as a primitive, I see this idea of the transaction
template committing to all the outputs, while TXHASH is a much bigger primitive.
And while committing to the outputs but not the fields that are just for a txid,
for me it's the same primitive.  So, it's a small variation of the same
primitive.  So, in that sense, I feel like there is a little bit of design
space.

**Steven Roose**: Okay, yeah.  You mean something like OUTPUTHASHVERIFY?  I
mean, I think if we're talking about the benefits we get from CTV in LN and Ark,
both of those heavily rely on txid stability.  So, trying to bend CTV into
something different at this point I think is not going to be beneficial.  But I
agree that future primitives we would have should be more flexible and not
really heavily focused on the txid stability.

**Greg Sanders**: Well, to be clear, LN-Symmetry wouldn't have to.  If you had
like a SIGHASH_SINGLE-like version of it, then you wouldn't have a reattachable
signature, just re-binds to whatever input you have.  That's what I call a small
optimization as well, because nobody's massively composing these transactions
with other things for safety reasons, anyway.

**Steven Roose**: So, did the original eltoo design use APO with SIGHASH_SINGLE?

**Greg Sanders**: I think it didn't really matter, but yes, at some point it
did.  I went back and forth on it for pinning reasons.

**Steven Roose**: Okay.  Well then, sorry for my inaccuracy.

_Benefit of CTV to Ark users_

**Mike Schmidt**: The next item is, "Benefit of CTV to Ark users", so we will
get into Ark and CTV slightly deeper.  But Salvatore, Greg, or Steven, any other
discussions about CSFS and CTV benefits?

**Steven Roose**: I might have forgotten some, but…

**Mike Schmidt**: We did note in the newsletter for each of the points that
Steven brought up, and I don't think Steven didn't appear to me was overstating
these points.  But there were rebuttals from folks on the DLC front, folks
saying, "Hey, DLC services are shutting down, maybe it's not
performance-related".  On the vaults, AJ says, "This type of vault isn't very
interesting", although there's counters back to that.  On the BitVM side of
things, there's people questioning the demand for BitVM.  We talked about
LN-Symmetry.  So, I'm just observing that there was some pushback, but I don't
think that's anything different than what Steven has already outlined here.
Steven, I don't think you've said that this is a silver bullet.  You would
acknowledge some of these potential downsides or limitations.

**Steven Roose**: On the DLC front, yeah, recently like 10101 shut down.  It was
a big DLC project trying to build an exchange.  On the other hand, Lava Loans
recently raised a lot more money, so there's some people stopping, there's some
people starting.  I think maybe, well, I wouldn't know to what extent the
current limitations of DLCs, that CTV might alleviate a little bit, have
contributed to 10101 having to shut down.  I think, as is mostly the case in our
space, some kind of lack of demand for certain things, you don't know if the
lack of demand comes from the user experience not being great or just there not
being interest, right?  So, it's hard to know.

**Mike Schmidt**: All right, let's move on to, "Benefit of CTV to Ark users".
Now, we touched on it briefly, it was a sub-bullet of the last segment.  But,
Steven, you posted to Delving a description of covenantless Ark, clArk, the
protocol that's currently deployed on signet.  And are you guys on mainnet yet?

**Steven Roose**: No, we did some kind of proof-of-concept demo at our launch,
but that's not a usable product on mainnet yet.

**Mike Schmidt**: Okay, yeah, I remember looking at that.  And then, you
outlined how CTV could make a covenant version of Ark better.  You've mentioned
some of it already, but do you want to go just one level deeper on what the
advantages are there?  Or it sounds like you're working also on a presentation
in the next couple days; is it related to this?

**Steven Roose**: This can be a good teaser, yeah.  So, I mean I plan to present
the benefits of CTV for Ark at the OP_NEXT conference next Friday.  But in the
more general sense, so the way clArk works is, like, the original design for Ark
was using CTV, right?  And it uses these transaction trees, which basically give
people who are at the leaves of these trees a unilateral exit path.  Because
these transactions are set in stone using CTV, you kind of know by knowing the
routes and the CTV hashes that these transactions are always going to be able to
go onchain.  No one can actually cut that through because no one can spend the
money because it's a CTV, right?  There's no way to spend it in another way.  So
then, because CTV doesn't exist, we emulated this by putting MuSig signatures on
all these trees instead of CTVs, and then everyone who lives in the tree below
the nodes would have to cosign all of the nodes to basically emulate some kind
of covenant, basically a single way to spend these transactions.  But the fact
that everyone has to sign this introduces a bunch of interaction.

The way the Ark rounds work as we do them, like in Ark rounds, you can basically
exchange your old, expiring UTXOs for new ones in a trustless and atomic way.
And the flow of a round currently is that first, everyone signs up to the round
and says, "I want to do this".  Then the server will create this tree with all
the outputs in the leaves, then all the participants have to sign this tree.
And then when the tree is signed, the next step is that everyone gets the signed
tree and then signs their forfeit signatures, which is basically atomically
binding the inputs to the new tree.  So, it's like a two-phase, well, a
three-phase: everyone signs up; everyone signs the tree; and then, everyone
signs their forfeit transactions.  And in the original design with CTV, the
participants wouldn't have to sign the tree, so it would only be a two-step:
everyone would sign up, you would immediately receive the full tree; and then,
you would sign your forfeit signatures.

So, this already cuts out a lot of the interactivity.  And it also means that
the receivers of the outputs in the tree don't have to be online to sign the
tree.  So, it means that it's possible for one user to send to another, while in
the current scheme we're using with signatures, the receivers also have to be
online.  So, we kind of only try to have users send to themselves using this
scheme, and then use other means to send to other people, so that we know that
everyone who is online is both the sender and the receiver and can participate
in the interaction process.  So, with the original design of Ark, the receivers
don't have to be online, but the senders have to still do an interactive process
to sign their forfeit transactions, atomically linking the inputs to the
outputs.

Recently, we found a way, and we're trying to validate if it actually works,
because it's weird that no one came up with this earlier, but until now, it
seems like it actually checks out, we found a way to also remove the interactive
rounds for signing the forfeit transactions.  And this means that there's only a
single interaction for every user to do an Ark round.  People just send messages
to the server, "I want this", and then they can go offline and the server can
just make it all happen at a certain moment, and there's no more interaction
needed.  And especially since we're exploring to deploy Ark for mobile on
limited bandwidth device, limited connectivity device, this is really a
game-changer for us.  Because being online during this whole round, anytime
someone can basically grieve or attack this process by failing a signature and
making everyone have to retry, and this can make these rounds cost minutes or
even an hour, because let's say an attacker has 1,000 inputs, he can just submit
1,000 inputs, sign 999, everything has to restart, then he can sign 998,
everything has to restart, and it can cause 1,000 retries of this whole process.
But by cutting all the interactivity for the rounds, there is no more attack
like this.  So, this makes it way more viable to be used on mobile devices,
because there is no more need for interactivity; I mean, the interactivity is
just asynchronous.  Now I've already spoiled a bit of my talk.

**Mike Schmidt**: Well, if you don't want to, you don't have to.  I was going to
ask the tl;dr on what the breakthrough was there.  But if you want to save that,
that's your discretion.

**Steven Roose**: And then another thing is basically, if you can
non-interactively create the output tree, it means that any party can
non-interactively create the output tree.  So, one thing that I already talked
about on Twitter a little bit and also in this post is that, for example, the
use case of an exchange wanting to pay out to multiple users, or a mining pool
wanting to pay out to multiple users, using a non-interactive Ark or using a CTV
Ark, they can actually themselves create this whole tree and then in a single
output, issue any number of Ark UTXOs.  So, for example, an exchange could be
queuing up withdrawals from people during a whole day, and then once a day they
make one output and they issue in this output a whole bunch of UTXOs in a
certain Ark, but they don't need any interactivity with the Ark nor with the
users.  They just have to, after the fact, inform the users like, "Hey, you guys
have UTXOs in this output".  And that's something that's also not possible today
with clArk.  There are some optimizations maybe with Lightning receive, but it's
not very clear yet.  We're still sketching out details on those, so I don't want
to make claims on those.  Lightning receives is also something that's not
super-easy to do in Ark.  It looks like CTV could help us a little bit, but
maybe not too much.

So, yeah, it's mostly like non-interactive receiving in an Ark.  You can send
from A to B, you can send from exchange, from outside party to B, and you can
also send to yourself without needing to be online in a route.

**Mike Schmidt**: Very cool.  Any comments or questions from our other special
guests or Murch?

**Steven Roose**: I'll see Greg this weekend.

**Mike Schmidt**: Yeah, you guys can come up with something even more new.  It
seems like every time people get together, there's some breakthrough.

**Steven Roose**: I really hope Greg is not going to tell me it doesn't work!

_OP_CHECKCONTRACTVERIFY semantics_

**Mike Schmidt**: And our last segment from this section is,
"OP_CHECKCONTRACTVERIFY semantics".  Salvatore, you posted to Delving,
"OP_CHECKCONTRACTVERIFY and its amount semantic".  And in the post, you link to
your draft BIP and a draft implementation for Bitcoin Core.  Maybe to help
remind listeners, since I don't think we've talked about CHECKCONTRACTVERIFY
(CCV) in a while, what is CCV trying to solve?  And then we can get into how it
works.

**Salvatore Ingala**: Yeah, so CCV is the implementation of an idea that I
presented the first time under the pseudonym of MATT (Merkleize All The Things).
And so, when I presented this idea originally, I focused a lot more on this big
theorem that I was happy about, which is like, okay, with relatively simple
covenants, we can compare the constructions that do fraud proofs for arbitrary
computations.  But there was no specification of what this opcode looks like,
and there are different ways you could come up with that.  But yeah, this is
something that has evolved a lot since the original posts.  And so, CCV is kind
of a distillation of the core idea that you need for that, but also for several
other kind of primitives.  And so, the primitive that CCV implements in the most
direct way I could come up with, I call it state-carrying UTXOs.

So, what is a state-carrying UTXO?  The idea is that while in Bitcoin today, all
the UTXOs, when you spend them, you cannot basically constrain what the outputs
look like in any way.  They cannot carry information to the future except with
things like presigned transactions.  And basically, adding covenants is the
whole point of adding new kinds of restricting the output.  So, it expands the
class of things that you could carry to the outputs.  And so, for state-carrying
UTXOs, the idea is that you want to be able to attach to a UTXO, so to an
output, some additional information.  It just could be as simple as a single
hash.  And so, when you're spending one of these outputs, you want to be able to
have access to the information which is committed inside it somehow, if there is
any information stored.  Potentially, you could do some computation on it,
because script can do some computations.  You can access the witness, so you can
access additional arguments that are passed by the witness.  Then, maybe you
compute something else, and you want the result of this computation, you want to
be able to carry it over to the outputs.

So, this is in a nutshell what the primitive wants to enable.  It's more like a
building block.  It's not an application, but it's a programming construct that
can be used for many things.  And so, the core idea is that this enables to
build state machines that span across multiple UTXOs, across multiple
transactions.  And one very simple example of that, which is also attached to
the Bitcoin Core implementation, is a vault.  And because in a vault, you want
to be able to have a two-step withdrawal process from the vault, so you want to
declare on the first transaction where the money is going to go.  But this is
only information that is kind of on hold for some time.  And then, in the second
transaction, after a time block, you're spending the transaction, so there is a
covenant here, you're spending the transaction and you want to force the money
to go to where you declared earlier.  So, you have to parse this information
somehow.  And so, compared to the original posts, now I worked over time on
clarifying what is the semantic of the opcode.  And in particular, like in the
implementation of Bitcoin Core, while implementing it, I realized that in the
past posts, particularly the semantic for the amounts, I never formalized it
clearly before now, and so I decided to make a post covering this in more
detail.

While in the PR that I made for Bitcoin Core showing the implementation, I also
detailed separate issues, which is what could be potentially the implementation
difficulties that I found in implementing the opcode, so what are the design
choices that I was making this implementation.  Maybe I'll stop a moment here to
ask you, those two aspects I think are two separate things, and I think it's
interesting to cover them separately.  So, I'll pause for a moment.

**Mike Schmidt**: Yeah, maybe from my own understanding, it sounds like CCV is
providing a way to tie information from a previous output to an output that is
going to be newly created, and therefore providing some ability to have state
between the two.  And that's the primitive building block that we're talking
about?

**Salvatore Ingala**: Exactly.  Yeah, it allows you to.  So, programmatically,
you can design what is the relationship between the inputs and the output,
meaning how this data is transformed from the input and what needs to go to the
outputs.  And you can also constrain the script of the output.  But you can
constrain these two things separately.  So, typically, the script of the output
is kind of fixed.  You already know it in advance what you will want to do on
the next step.  But the data will depend on the actual execution, meaning when
you spend a transaction, you can provide some arguments in the witness.  And so,
how the data is manipulated and what computation you do on the data can depend
also on what's on the witness, so it can be dynamically computed.  So, this is
the big difference with the fully enumerated covenants like CTV, where you kind
of have to declare in advance what are all the possible futures.  Well, here,
the number of possible futures, even if you do just a single transaction, could
be unbounded because it depends also on the witness arguments.

**Mark Erhardt**: So, for example, it sounds like it would be easy to have a
contract that specifies, "In the next transaction, I will have to pay Alice X
amount, at least, or exactly".  And then, it leaves the other parts of the
transaction unconstrained so you can still create a change output, and you can
set different feerates or add more inputs to fund the transaction, but this one
output is now restricted.  So, it sounds like if I were to compare it with CTV,
that the CCV allows me to make restrictions and encumbrances on specific outputs
or combinations of outputs, whereas CTV makes a determination of the txid in the
future, and like a presigned transaction that cannot be in any way changed.

**Salvatore Ingala**: So, yeah, there is a little caveat there, which is you
mentioned a restriction of saying that you have to pay to Alice at least this
amount.  And so, CCV doesn't allow to do fine-grained introspection on the
amounts.  It has an embedded amount semantics, which we can talk about.  But you
cannot check, for example, how much is the amount of one output, and do an
equality check, for example, at least not directly.  If you combined CCV with a
hypothetical amount that allows you to put the amount on the stack, for example,
then you can fully emulate CTV in that sense, because for each output, you could
do one CCV that checks the script of the output, and then you can also check the
amount using the quality checks.  And so, you could have a less efficient
version of CTV, because you have to do that for each output, while CTV is very
efficient in the sense that you can have 100 outputs but still just a single
hash to check everything.

Maybe it's a good time to talk about what is the amount semantic that CCV
incorporates, because the idea is that whenever you check a script of the
output, it's because you're sending some money there, so you probably also want
to know how much money you're spending.  Because of course, if you get an output
with zero money, in most situations, that wouldn't be a very useful contract.
And so, the covenant has to apply to the amount that you're spending in the
input somehow.  And so, the amount, like for some of the applications, what you
want is just to say, "Okay, I want to spend all the inputs and I want to spend
the entire amount exactly to this output", so that's very simple, that works,
you do one-to-one logic from one input to one output, possibly changing the
state in the middle.  And you can already do pretty advanced things, like this
might be enough already for doing things like changing a state for UTXOs, like a
sidechain, where you'd update the state.  Normally, the full amount will be
fully contained inside this UTXO.

But there are other applications where, for example, you might want to have
multiple inputs that kind of logically belong to the same account, to the same
mental contract in a way.  For example, if you have a vault and you receive
multiple transactions sending money to the same vault, you want to be able to
spend all these inputs together, so they logically belong together.  And then,
what you want is that you want to send all the amount of those inputs to some
specific output, so you want to aggregate all the inputs and send them to the
one output.  And so, this is in fact the default logic that the opcode has when
you're checking output.  So, if multiple inputs are checking the same output, of
course the script has to be the same otherwise the validation will fail.  But
then, for the amount, the amount of the output must be at least the sum of all
the amount of the inputs that are checking this output.  So, this is the default
semantic and it allows already to do this situation where you aggregate multiple
inputs in one output.

The opcode also provides one more type of semantic, which I call the deduct
semantic, which is done with one of the parameters of the opcode, which
initially was the flags, but Sjors convinced me to rename it to mode, which is a
better name probably.  And so, the idea with this deduct semantic is that you
might want to be able to spend some partial amount to some output, and then you
leave the remaining amount unassigned.  And then you do a second check on a
different output and you assign it all the residual amount you assigned to this
output.  And maybe you do that even multiple times.  So, you have some amount
you send to one input, some amount of the input you send to one output, some
other amount you send to a second output, and then all the residual amount you
send somewhere else.

So, combining these two modes of the opcode, you kind of make sure that all the
amount of the input is always assigned to at least some outputs, and you also
avoid having to do arithmetic by hand, which is something that would be pretty
tricky, both because a script is very limited.  And so, even if you add
introspection to the amounts, we don't have 64-bit numbers.  So, you would have
to somehow be able to do arithmetic on this number.  So, it's not a trivial
change to be able to do this kind of complicated arithmetic.  But even if you
had that, when you spend multiple inputs and they want to aggregate the output,
it's non-trivial to do that in script, even if you had 64-bit arithmetics,
because now who checks the amount?  Like, if every input checks the amount of
all the inputs, this is quadratic cost.  So, we would like to avoid doing
quadratic computation unnecessarily.  You could do some tricks where one
specific input checks the amount for all the inputs, and maybe all the other
inputs just check that this special input is present.  But now we start to get
into ugly scripts that we would like to avoid.

So, instead, CCV tries to put all the common amount logic, that in most cases I
believe is sufficient, as part of the opcode.  And then there could be still
some things that you might want to do.  For example, you might want to be able
to check exactly an amount of the output, but this opcode doesn't do it, meaning
we would have to add some other opcode to do that.

**Mark Erhardt**: Right, I wanted to jump in there and ask.  So, you said you
can't read exactly the amount on the output.  What you can do is you look at an
input and you say X part of either the whole amount from the input goes to one
specific output, or some portion of the input goes to some output.  Now, I was
wondering can you only absolutely define the amounts?  So, if you have an input
that is 50 bitcoin, 30 go here, deduct 30 and the residual goes there, which is
the 20, and that way of course you can split in two; or you can define multiple
absolute amounts and then a residual.  And can you do something like a relative
split, like 50% here, the rest here?

**Salvatore Ingala**: No, so the output doesn't do that.  So, basically, when
you use the deduct semantic, so you're checking some output.  So, let's say
you're spending an input, which is 50 bitcoins.  And if you use the deduct
semantic for an output, and this output is 30 bitcoins, basically what's
happening is that 30 bitcoins of the input are assigned to the output.  And so,
there is a residual amount that is still unassigned and is part of the input.
And then, on the next check that you do on a separate output, the amount of the
input that is still unassigned is just these 20 bitcoins.  So, if you do another
CCV another output with a default semantic, now you're assigning everything
else.  So, the amount of the output, in a way it's malleable.  From the point of
view of the opcode, what you know is just that the totals are always correct.
And so, for example, if malleability is a problem in the protocol you're
constructing, then you will want some other way of checking the output, either
with some OP_AMOUNT opcode or you add the signature, something else that
constrains the amount.

One application where maybe malleability is not necessarily an issue is
precisely vaults, because where I use this in vaults is to allow a partial
vault, meaning you're sending some of the amount back to yourself.  So, in this
case, you don't care as much about how much is this amount, because if you're
spending what you're doing, probably you construct a transaction, the
malleability there is not so much of an issue because all the remaining amount
is the one that goes to the output.  And as long as you have a signature in the
transaction, there is actually no malleability.

**Mark Erhardt**: Right.  So, the takeaway for me is you can assign absolute
amounts, you can at most split into two portions, and you can only use one
OP_DEDUCT per transaction or per input.  And you can never use it for fees,
because you always have to account for the whole input amount across the deduct
and the residual, so you can't divert anything to fees.  So, you have to always
bring at least one other input that brings fees, or you make a zero-fee
transaction with TRUC (Topologically Restricted Until Confirmation)
transactions.

**Salvatore Ingala**: For the for the OP_DEDUCT, you cannot have more than one
OP_DEDUCT for the same output when you're checking output, but you could have
multiple OP_DEDUCT from the same input script spending.  So, you can do CCV on
different outputs, each of them with OP_DEDUCT.  So, you can deduct some amount
from one output and then some amount to some other output, and then the
residual, you can do the default semantic.

**Mark Erhardt**: Okay, so if we split our 50 bitcoins again, I could do 30, 10,
and residual, and that would work?

**Salvatore Ingala**: Yeah.

**Mark Erhardt**: Cool.

**Salvatore Ingala**: What will fail is if you do deduct twice to the same
output, even from different inputs, or to the same output you do one deduct,
maybe once in one input, and maybe in some other input you spend with the
default logic, because there will be amounts that are kind of double-counted or
you will be burning bitcoins.  So, deduct on the output is kind of exclusive.
If you do deduct, that's the only time you're checking that output; while on the
same output, you can and you're expected to potentially to do multiple times the
default semantic, because that's precisely inputs are declaring that they want
to send their amount to the same output, and so that's fine.

**Mark Erhardt**: So, for example, if I had a vault and I had more money to
spend, I have two 30-bitcoin inputs in my vault and I want to send 40 somewhere,
I would make an output that deducts 10 from one input and the residual of the
rest, and then a second output from the input that took 10 to make a residual
change output that goes back to my vault.  And I have to bring a third input
that brings the fees or use TRUC transactions, or something.  Well, but my funds
are vaulted, so probably I need to bring a second input or a third input.

**Salvatore Ingala**: Yeah, I guess you will never want to do the deduct logic
in the vault example.  For only one of the inputs, you would use this deduct
logic, because otherwise you have to send it to different outputs.

**Mark Erhardt**: Right, you'd have to have two outputs with the same address,
which then wouldn't fulfill the purpose of sending one output with 40 bitcoin.

**Salvatore Ingala**: Yeah, and also in that case, you will probably not need to
do that, because you accumulate amounts from the inputs you're spending from the
vault.  At some point you have enough, and so only one is the one that you need
to split.

**Mark Erhardt**: Right, yeah.

**Salvatore Ingala**: In the same multi-party transaction for example.

**Mark Erhardt**: I think we understand each other.  Oh, sorry, go ahead.

**Salvatore Ingala**: The place where I think sending multiple from the same
transaction, from the same input, sending to multiple different outputs could be
useful, you could have in the future if you have direct amount checks like
OP_AMOUNT in a shared UTXO, we might want to try to implement on the other
withdrawal protocols, for example, for multiple users at once, for example.  And
so, you might do a single transaction that allows two users to withdraw their
amount.  So, you will use the deduct semantic for the first user, deduct
semantic for the second user, and then the default semantic to send back to
itself, to the same kind of construction, all the remaining amount.

**Mark Erhardt**: Right, my context here was thinking we sometimes get questions
about, "Oh, can I do something where I receive money to one address and then it
can only be spent by split 50/50 to these other two addresses?" like sort of an
auto-split payment.  And it sounds like with CCV, I wouldn't be able to, because
I don't know… sorry, my headphones just went off.  Do you still hear me?  Yeah,
okay.  Okay, so I was wondering whether such an auto split scenario could be
implemented with CCV, and it sounds to me like you could not unless you already
gave a new covenant out for every sender where you predefined a split that they
pay into, so you know the absolute amounts later for the split.

**Salvatore Ingala**: Yeah, I mean definitely with CCV alone, you cannot do
that, because you cannot the amounts except in these two logics that are
defined.  It would be definitely possible if you add direct amount introspection
plus necessary arithmetic to be able to do maths on the outputs, then yes. But
it's not the goal of this opcode.  And I feel like trying to get an opcode that
also puts together all the possible amount semantics might not be feasible.  And
then, the opcode, it's no longer a single primitive, while this amount semantic
that is implemented in the opcode, I feel like we could not get it with
arithmetics.  That's why I think it's still a good idea to put it together.

**Mark Erhardt**: Yeah, okay, cool.  I was going to ask, Greg, you've stared a
fair bit amount of time at vaults, and I was wondering how you think about CCV
as a tool to bring about vaults?

**Greg Sanders**: Value-forwarding is essentially identical, if I remember
right, or at least variants we looked at.  It's all kind of the same ballpark.
And I just think that app-specific opcodes are probably dead at this point.
Really needs to be a little more general of that.  Obviously there's tension,
the more general you get, the less efficient you might be at actual use cases.
So, it's kind of a push and pull, I don't know, it's a search problem where you
have to pick capabilities you think are useful and then validate them with real
use cases.  I think you've done a pretty good job of that with CCV.

**Salvatore Ingala**: Yeah, and for vaults specifically, so in the PR, we concur
that is in the functional test, implementing a reduced functionality version of
a vault.  Because for the full functionality version, I think, so CCV I
implemented in the pymatt framework that I presented in the past, you can get
basically the same kind of vaults that you can do with OP_VAULT if you have also
CTV; while with CTV alone, you get a reduced functionality version, in the sense
that you can do vaults where the withdrawal is always to a single address and it
has to be a taproot address.  So, you cannot do a single unvaulting and
meanwhile spend to five different people.  And also, because CCV is designed
only to work with taproot inputs and outputs, you cannot send to a segwit v0
output, for example.

But other than that, you still get the same functionalities.  You can batch
inputs together, you can re-vault immediately if you want.  And you can also
compose these kind of constructions for other use cases that are not vaults.
For example, a wallet like Liana might use CCV for the recovery transaction,
which is the one that if you lost your primary spending path, instead of using a
timelock, you could use a vault-like spending condition.  And there, I feel like
the limitation of not being able to send to multiple outputs is not a problem
anymore because if you are recovering, that's fine.

**Mark Erhardt**: So, did I understand right?  While in many ways CCV is similar
to CTV in the functionality, the two in combination actually would, for example,
be able to reproduce something similar to BIP345 vaults, and so it is it is
different enough that the combination of the two is a synergy and not a
replication where we are saying, "Why did we do that if we had that already?"

**Salvatore Ingala**: Yeah, definitely.  The CTV is great for the vault use case
because you can kind of commit to a transaction on the first transaction, but
then do the actual final withdrawal on the second transaction.  And it's very
efficient doing that, because a single hash commits to all the outputs.  Without
CTV, you could still do that if you have OP_AMOUNT, for example, because as we
discussed before, you could check each output script and the amount
independently.  But of course, it's a lot less efficient when you have many
outputs.

**Mike Schmidt**: Salvatore, any other feedback from Delving or elsewhere on the
semantics or other OP_CCV stuff?

**Salvatore Ingala**: Well, I got some comments on the BIP mostly from Sjors and
Murch.  I replied to some of them, I still have to go through a few of them.
But yeah, I mean, I will just invite people to check things out, check the BIPs,
play with them if you have ideas.  And also on the implementation, I implemented
the best way I could come up with for this primitive.  It's not the only way, so
if people have better ideas and you can find a better way, please do.

_Draft BIP published for consensus cleanup_

**Mike Schmidt**: "Draft BIP published for consensus cleanup".  I referenced
several previous discussions on consensus cleanup, as well as discussions with
folks who either authored recent posts about consensus cleanup or other
discussions around that, including the Stack Exchange from a week or two ago.
So, I will reference those now.  We have Newsletter #332, where we covered,
"Continued discussion about consensus cleanup soft fork proposal", and in that
Podcast #332, we had Antoine Poinsot on to discuss sort of reinvigorating the
consensus cleanup soft fork proposal, which is now, as of this week, in BIP
format, which is what we're covering.  We also had Newsletter #340 where we
covered, "Updates to cleanup soft fork proposal", and Podcast #340, where we had
Antoine on again, who is the author of this BIP, and he discussed that news
item.  We also had Antoine on last week, where we discussed a couple of Stack
Exchange posts that were related to his work, including 64-byte transactions, so
refer back to that episode.  I'm pointing folks to those episodes because I
think we had good in-depth discussions there, and I think for Murch and I to try
to recreate all that would be unfruitful.

One of the objections to the draft BIP that was published, that we're covering
this week, was that 64-byte transaction objections and the related merkle tree
vulnerabilities, which was a criticism made previously.  So, in lieu of
rehashing that, I'll point folks to Newsletters #319.  There was a news item
titled, "Mitigating merkle tree vulnerabilities".  We also had Eric Voskuil on
the Podcast for #319, who was the one that brought up that criticism, and we
discussed it with him in Podcast #319.  But the second objection, which was
around a more recent change to the consensus cleanup that was included in this
BIP, the change was to setting a flag that makes miners' coinbase transactions'
locktime enforceable, meaning that miners would need to set their coinbase
transactions locktime to the block height (minus 1) post activation of consensus
cleanup in those blocks.  Murch, I think we gave a bunch of people a bunch of
places to double-click on the first objection and what is this consensus cleanup
more generally.  Do you have a good explanation of what we're getting at?  I
know we talked with Antoine a bit about this, but maybe you can summarize the
second objection for folks?

**Mark Erhardt**: Yeah, let me take a little more breath here.  One is
generally, we just want it to be impossible to recreate the coinbase
transactions from the early times before the height commitment was required in
the input field.  The input script field on the coinbase input is called the
coinbase, and in the coinbase you're supposed to first, well, required really,
to first post the block height, and that happened very early on but not right at
the beginning.  So, even before that, people put random data into the coinbase
field, and some of this random data actually could be interpreted as a block
height and that allows these transactions to be recreated.

The point of the rule that Antoine proposes to introduce, which is that new
coinbase transactions need to put the height of the previous block as a
locktime, because transactions become valid or become eligible for inclusion in
the next block at the height that the locktime gives.  So, if you have a
locktime of block 100, your transaction can be included in block 101.  And by
using this mechanism in coinbase transactions, and also setting a non-maximal
sequence and enforcing the locktime, means that a transaction would not have
been valid before the moment that it is included as the coinbase transaction in
the new block that is being mined.  So, both it can't be used earlier, but it
can also not be used later anymore.

It's a little more of a theoretic property, because coinbase transactions also
commit to the actual height in the input.  And the locktime itself, by itself,
and the height commitment in the input would also have these properties, even if
the sequence is not restricted.  Now my understanding is, I had only seen this
criticism for the first time, but some miners think it is sad or unnecessary to
restrict the locktime.  We should use a different mechanism of making sure that
coinbase transactions are distinct from the earlier period by, for example,
increasing the version or setting other fields that were never used in the early
times, because the nLockTime field at the end of the transaction is very easy to
use as an additional source of entropy, sort of an extra nonce field.  And when
you're creating a coinbase transaction for a block, you could just iterate
through values in the nLockTime field and use that as extra entropy.  This is
the first time I've seen this argument.  I think we have many other sources of
entropy; I don't see why this nLockTime field is uniquely suited for that.  It
is useful maybe, but it seems fine to me.  That was my take on it, but I haven't
seen much discussion.  Maybe other people have some deeper thoughts on this or
disagree with me.

**Mike Schmidt**: Maybe the Bitcoin-Dev mining mailing list would have a
discussion on this at some point, but I won't cross my fingers.  Anything else
on consensus cleanup?

**Mark Erhardt**: Well, the BIP draft is open, so if you are one of the people
that likes to review BIPs, now is a good time to take a read of it.  And I think
it's pretty complete already from the content, so it might actually move
quickly.  But yeah, especially people that are interested in protocol
development, but also people that are interested in the great consensus cleanup,
please take a read and take your time to read it.  Leave some feedback if you
think there's stuff that could be improved or, you know, the usual stuff.

_BDK wallet 1.2.0_

**Mike Schmidt**: Releases and release candidates.  BDK wallet 1.2.0.  BDK
Wallet, as a reminder, is the name of what we previously referred to as BDK.
And in the write-up this week, we noted this release adds flexibility for
sending payments to custom scripts.  It fixes edge case related to coinbase
transactions.  And I would just add to that list that this release also contains
the PR that makes full-scan/sync flow easier to reason about.  And the PR that
we discussed recently in a previous newsletter, that detects and evicts incoming
transactions that are double-spent or cancelled, that might be interesting for
folks. Those are the additional notable things I saw there.

_LDK v0.1.2_

LDK v0.1.2, this is a release that contains, I'm sure, a lot of good work,
including some PRs we covered in recent newsletters.  But as this write-up
noted, it is a bunch of performance and bug fixes.  So, I don't have anything
specific to add or call out that I saw was interesting for listeners, but check
out the release notes if you're an LDK user.

_Bitcoin Core 29.0rc3_

Bitcoin Core 29.0rc3.  We covered RC2 last week and this week is RC3.  Murch and
I don't immediately have any known deltas between the two RCs.  We could jump on
the repo and check that, but perhaps there's some bug or build fixes that
happened between those two RCs, is our speculation.  If you're curious more
broadly what is coming in Bitcoin Core 29.0, separate from these RCs, check out
Newsletter and Podcast #346.  We had on one of the Testing Guide authors for the
29.0 release, and we jumped into a bunch of the new features.  And there still
is currently time to test that, if you want to go through the testing.

**Mark Erhardt**: Yeah, so I just pulled up the commit list.  There appeared to
be seven backports and man page updates.  So, it's just bugs that were fixed and
get backported into this release branch from the master branch.  We recently got
the new CMake build chain and there's something about CMake here, actually
several things, and something in package RBF.

_LND 0.19.0-beta.rc1_

**Mike Schmidt**: LND 0.19.0-beta.rc1.  This is the same RC that we covered in
last week's show and newsletter, so refer back to #347, where we recommended
potentially testing the new RBF-based fee bumping for cooperative closes.  And
of course, LND users will want to test this RC in their current setup and
provide feedback as well.

_Bitcoin Core #31363_

Notable code and documentation changes, Bitcoin Core #31363.  This is a PR
related to cluster mempool, the cluster mempool subproject.  And this particular
PR adds the TxGraph data structure, which is a data structure that contains all
of the mempool transactions and their relations to one another, but it strips
out all of the transaction data, except the effective fees of the transaction,
the size of the transaction, and the transaction dependencies.  Murch, you and I
did a PR Review Club that covered this exact PR and we got in pretty deep with
it, so if people are curious they can check out Podcast #341.

_Bitcoin Core #31278_

Bitcoin Core #31278. All I have down for this one is, "Murch?"

**Mark Erhardt**: Right.  So, there were two, well, an RPC and a startup option.
The -paytxfee startup option and the settxfee RPC command both set, wait for it,
a feerate that is being used by all transactions that are built by the wallet.
So, if you set either the settxfee or, even on startup of your node, set a
feerate via -paytxfee, you can set one fixed feerate for all your transactions.
Now, I think they made more sense in the olden times when block space was cheap
and feerates were predictably minimal.  But we've had a very dynamic year in
feerates, and beyond the weird name where you say settxfee and set a feerate, I
feel that the utility of an RPC command or a startup option to set one standard
feerate for all of your transactions is pretty low.  And we are deprecating
these two options, and option and command, because we think that people should
rely on more up-to-date data to set feerates, set it in their transaction when
they build the transaction, or rely on Bitcoin Core to pick one for them.  So,
yeah, we just don't think that these two commands are that useful anymore.
Please check out if that breaks your workflow or something, and welcome to a
dynamic fee environment, I guess, if that affects you!

**Mike Schmidt**: And that RPC command and startup option are deprecated but
you'll still be able to use them, but they are marked for removal in Bitcoin
Core 31.0.

**Mark Erhardt**: Right.  Joking aside, if you do use this command, you will
bump into it not working in the new version.  But you can set deprecated RPC and
then still use it.  You basically acknowledge that it's going to be deprecated
and after that, you'll be able to use it again until the next release.  But
yeah, if you're still using this, we would like to hear from you, because we
assumed that nobody would.

_Eclair #3050_

**Mike Schmidt**: We close out our Notable code set of PRs with a bunch of LN
PRs, starting with Eclair #3050, which makes a change so that Eclair will now
relay non-blinded failure messages from wallet nodes.  A common setup in Eclair
is their LSP setup, where users connect to their LSP using unannounced channel
and Eclair manages a lot of the channel operations.  Eclair seems to be
referring to these users as wallet nodes.  Something that I saw in the write-up
was, "When the next node is a wallet node directly connected to us, we forward
their failure downstream because we don't need to protect the blinded path
against probing, since it only contains our node.  Their node isn't announced,
so they don't reveal anything by sending back a failure message, which would be
encrypted using their blinded node ID".  And also, something to note here in the
PR is, "However, when the failure comes from us, we don't want to leak the
unannounced channel by revealing its channel update.  In that case, we always
return a temporary node failure instead".

So, some specific things for the way that Eclair use cases are generally
structured.  Seems great to me.  Murch, I don't know if you have any comments.

_Eclair #2963_

Eclair #2963 is another Eclair PR.  Eclair will now use Bitcoin Core's
submitpackage RPC to publish commit transactions with their anchor transaction.
So, submitpackage allows one parent transaction and one child transaction to be
broadcast together, even if the parent transaction's feerate is below the
mempool minimum feerate.  So, right now, this applies for channel force closure
transactions in Eclair, and also I saw in the release notes that this PR is
going to be a part of, "This removes the need for increasing the commitment
feerate based on mempool conditions", harkens back to Murch's previous
explanation, "which ensure that channels won't be force closed anymore when
nodes disagree on the current feerate".

_Eclair #3045_

Eclair #3045 is a change to Eclair's handling of trampoline payments.  If a
payer or intermediate trampoline node doesn't need multipath payments (MPPs) to
reach the next trampoline node, they may omit the payment_secret field from the
outer onion payload and send instead just a single HTLC (Hash Time Locked
Contract).  So, previously, every Eclair trampoline payment did have a payment
secret, even if an MPP wasn't used.  There was one wrinkle in this PR, that
BOLT11 payments are required to have a payment secret according to the spec.
So, in those cases, Eclair actually uses a dummy payment secret that the PR
author noted as a, "Somewhat hacky version, but lets us use the same code when
receiving a payment and when receiving a trampoline relay request".  So, maybe a
touch hacky, but simplifies their code.  And this is part of Eclair's trampoline
implementation.

_LDK #3670_

LDK #3670 is part of LDK's effort to implement trampoline functionality, and is
part of the trampoline tracking issue, which is in the LDK repository as #2299.
So, if you're curious as their general progress towards trampoline
implementation, check out that tracking issue.  This PR specifically implements
support for receiving a payment containing a trampoline onion packet.  This PR
does not implement forwarding payments through trampoline yet, but refer to the
tracking issue for those related PRs.

_LND #9620_

Last PR this week, LND #9620, which add testnet4 as an available network for use
in LND, alongside of testnet3, regtest, simnet, and mainnet.  Murch, the video
is already coming in handy.  You can wave when I miss something!

**Mark Erhardt**: Yeah, I don't have to chime in even, I just hold up four
fingers!  Yeah, so about the whole trampoline payment stuff, it sounds to me
that this is going to help with async payments, which would be super-exciting,
especially for LN wallets that are not always online.  If there were a way to
stage the payment on the side of the first hop, that would sort of sidestep the
whole problem with HODL invoices, where the funds are locked up along all the
hops except the last one.  Rather, it's only locked up on the first hop, where
the party that is paying is already sitting and expects that to happen.  So,
async payments and trampolines has me a little excited.  I don't know how long
it'll take until all this comes along, but, well, there's progress.  That's
cool.

**Mike Schmidt**: Yeah, definitely.  I mean, we noted the relation between
trampoline payments and async payments in the LDK write-up PR for this week.  We
saw that Eclair has a PR around trampoline payments, so you can sort of feel
that energy.  So, but yeah, hard to say when that would be concrete for end
users.  Thank you to Jonas for joining us this week, Jameson, Greg, Steven, and
Salvatore.  And thanks as always to my co-host, Murch.  Hear you all next week.

{% include references.md %}
