---
title: 'Bitcoin Optech Newsletter #382 Recap Podcast'
permalink: /en/podcast/2025/12/02/
reference: /en/newsletters/2025/11/28/
name: 2025-12-02-recap
slug: 2025-12-02-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt, Gustavo Flores Echaiz, and Mike Schmidt discuss [Newsletter #382]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-11-3/413673391-44100-2-cb7d01a263dee.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #382 Recap.
Today, we're going to be talking about updated statistics around compact block
reconstructions; we're going to talk about a motion to activate BIP3 and replace
the current BIP process; we have three questions from the Stack Exchange; and
our usual Notable code and Releases segments.  This week's show is going to be
Murch, Gustavo and I.  We don't have any additional guests joining us, so we'll
jump right into the news section.

_Stats on compact block reconstructions updates_

First news item titled, "Stats on compact block reconstructions update".  We
don't have 0xB10C here, but 0xB10C posted to Delving Bitcoin.  He's updated his
thread with new statistics based on compact block reconstruction.  He made a few
different changes to his monitoring setup.  This is a follow-on from his Delving
thread earlier.  I think we actually talked about it August of last year
originally, and that was in Newsletter #315, and then we also touched on it
again in, I think it was #339.  It's a thread of a series of updates from 0xB10C
about how often his nodes can reconstruct compact blocks.  And then, he's sort
of riffed on that a bit.  I think in #315, we talked about that data informing
setting mempoolfullrbf to true in Bitcoin Core, and informing that PR.  And so,
it's been an interesting thread to scroll through.

But this newsletter this week, we highlighted three different updates from that
thread.  The first one was 0xB10C, adding the tracking of the size of the
requested transactions, in kB, when the reconstruction fails.  So, you have this
compact block that comes in that gives you, I think, Murch, do you call it the
recipe for the block, or do you call it the table of contents for the block?  I
forget.

**Mark Erhardt**: Both, or the blueprint.

**Mike Schmidt**: The blueprint for the block.  And then, if you're missing some
of those ingredients, then you have to go ask your peer for those transactions,
essentially.  And depending on how many you're missing and how big they are, you
could potentially do that at the same time the compact block comes in, which is
what David Gumberg was working on with his compact block prefilling.  That was
what I referenced earlier.  We talked about that in #365.  That's when a node
pre-emptively relays some transactions along with the compact block, ones that
it thinks that its peer might not have.  Okay, so that was the first change that
0xB10C added, is logging those sizes.  There could be further analysis done
there potentially to help this compact block prefilling by David Gumberg.

0xB10C also updated one of his nodes.  And as a reminder, 0xB10C has this sort
of monitoring effort that he works on where he has several nodes that are
collecting information about the Bitcoin Network.  He updated one of his nodes
to use lower minrelayfee settings, and that was in Bitcoin Core #33106, that PR,
and he saw that that node had a significant improvement in compact block
reconstruction rates.  And he also noticed a noticeable drop in average
requested transaction size.  That was the second update.

After that, he switched all of his other monitoring nodes to also use that same
lower minrelayfee, and he found that most nodes, I think all nodes, showed
higher reconstruction rates and requested less data from peers, which is not
entirely unexpected.  There are some interesting graphs in the Delving thread,
where you can see where this sub-sat summer came in, and there was a lot of
transactions that ended up in blocks that nodes did not have because of the
minrelayfee setting being higher than what was being confirmed in blocks.  So,
nodes would then get those blocks, not have, in some cases, half of those
transactions, and need to request those.  And so, you could see that progression
in 0xB10c's Delving thread, where there's this chart of his different nodes, and
sort of a green if there wasn't that much data that needed to be reconstructed,
or it was a successful reconstruction without requesting more data; and then,
there's red where you needed a bunch of data in order to reconstruct the block.
And you could see it go in from green to red.  And then, when he made this
update to allow the acceptance of these lower feerate transactions, then you can
see it go back to green.

That was quite a bit of explanation on my side.  Murch, I'm sure you have more
to augment that.

**Mark Erhardt**: Well, turns out that if you have a more restrictive mempool
policy, then the majority of the miners, or even just some portion of the
miners, you will not have the transactions they mine.  And this is exactly the
effect that we saw here.  The minimum feerate got lowered organically by some
number of nodes, and then these transactions propagated due to them peering with
each other manually.  And when some miner started accepting them into the
blocks, these blocks contained a lot of transactions nodes hadn't seen, and that
means additional round trips at every hop that the block takes through the
network as it is gossiped along.  And now that nodes accept them again, or much
more nodes accept them, suddenly the block propagation is faster again.

**Mike Schmidt**: Yeah, who would have thought, right?  A couple of things I
wanted to add that 0xB10C mentioned.  He mentioned, in hindsight, he wishes he
would have kept maybe some of those additional monitoring nodes on 29, or I
guess the higher min feerate setting, so that he could have a true comparison,
that it wasn't just a change in environment with the mempool and the
transactions being confirmed, it was truly version against version or setting
against setting, to show that you still have that red or bad, poor
reconstruction rate versus the better reconstruction rate with the lower
setting.

**Mark Erhardt**: I mean he could have even just updated to 30 but kept one node
with a higher minrelayfee set manually, right?  So, that would have still given
him that information.

**Mike Schmidt**: So, to summarize, lowering minrelayfee when there's a lot of
low feerate transactions being confirmed will improve your node's block
reconstruction and it will reduce the bandwidth usage for your nodes.  Anything
else on this item, Gustavo or Murch?  Great.

_Motion to activate BIP3_

Second news item, "Motion to activate BIP3".  Murch, you posted to the
Bitcoin-Dev mailing list a formal motion to activate BIP3, which proposes new
guidelines for creating and preparing BIPs.  BIP3 would replace the current BIP2
process.  I have a series of questions but you can just take this story however
you want.  What's the latest with BIP3?  What is a formal motion?  What
objections remain?  Go.

**Mark Erhardt**: I don't know.  Formal motion is just, I started working on
this in spring 2024, and I think I opened the first draft on a PR in May.  So, I
had been tinkering away on this for something like 17 months now or 19 months,
right?  Yeah.  Anyway, whatever, the proposal had matured quite a bit.  It's
been reviewed by over a dozen people at least.  It first had something like 400
comments on my private repository, then I opened up against the BIPs repository,
where it has had something like seven improvement PRs since then and another few
hundred comments.  So, since the commenting had slowed down and it felt pretty
mature at this point, I proposed and I had been getting pretty good feedback
from a number of BIP repository contributors, I felt that it probably was ready
to activate.  I had finished the work that I had planned, what I wanted to
address in BIP3 in February this year, so about 10 months ago.  So, I thought
that with almost two years and it being set to complete, or in old terminology,
proposed for, what is it, almost 10 months, I assumed that we'd be ready to
activate potentially.

Obviously, when you suggest that something actually starts getting used,
suddenly people finally get around to spending the hour to read it, and we've
had quite a few comments recently.  Unfortunately, I was also traveling for
Thanksgiving last week, so I'm only catching up to these comments now.  I feel
like some of the comments have been already addressed in the past.  There's been
so much discussion about it that it's just a matter of pointing the commenters
at the prior discussions.  But there are also some that seem to need to be
addressed still.  So, I don't anticipate that today anybody would assume that it
has rough consensus.  So, I don't think it's going to activate today.  Anyway, I
spent several hours yesterday responding to people, and I assume that I'll be
doing more of that this week.

What is a formal motion to activate?  Well, the provision for how process BIPs
activate is if they have been discussed for at least a month and they seem to
have rough consensus, they'll be activated.  And it leaves the determination of
that to whoever makes that determination, which presumably is us collectively on
the mailing list saying, "Hey, this seems good to go.  Let's go, let's activate
it".  Given that there is no more formal guidance on that, and I also haven't
put it on myself to make it more formal in BIP3, presumably that'll just end up
being a discussion on the mailing list, where people agree or disagree.  And
once that crystallizes out, we'll hopefully eventually activate it or not
activate it, whatever we decide.  You said you had some questions.  How am I
doing so far?

**Mike Schmidt**: Formal motion; what's the latest, you sort of gave us the
timeline.  Objections that remain, yeah, I think Gustavo did a write-up about
the surge in AI and LLM tools, garbage BIPs, essentially, and it seems like
that's a sticking point.  I don't know, maybe you want to touch on that.

**Mark Erhardt**: Yeah, okay.  So, let me touch upon that.  As I said, my
planned work was finished in February, but a couple of amendments had been made
in the past few months.  One PR that was added to BIP3 recently was, "Let's
forbid the use for AI tools".  We had gotten at least a handful of BIPs, some of
which hadn't even been discussed on a mailing list before, where people just
opened PRs to the BIPs repository.  And clearly, the original idea must have
been theirs, but then an LLM had been instructed to write a BIP.  These
proposals tend to be extremely deficient in that they are usually not practical
to adopt, they cannot be implemented, they're not technically sound.  It turns
out that language models that just predict what the next word is going to be in
a specific context don't necessarily make sound designs of cryptographic
protocols.

So, this has been a pain point for the BIP editors, because if you're trying to
be fair and at least give something a read, we're going to spend several hours
on reading it and pointing out where the problems are.  But the author probably
spent 10 minutes on generating it, and that becomes a trivial DoS vector for the
BIP editors.  We don't have that sort of time that people can throw poorly
constructed BIPs at us and we then have to spend the time to read it.  So, the
proposal was to generally restrict AI and as several commenters pointed out
rightfully, good actors wouldn't benefit from this, because a good actor that
actually has an idea, that actually wants to write a good BIP, they will use
tools to improve their BIP and they will read the whole thing and own it and
make sure that it's high quality, and it will be of no consequence what tools
exactly they use to arrive at the point that it's a high-quality proposal.  And
bad actors would not disclose in the first place that they used AI, and would
still continue to expect to be treated to a full review, even while probably a
failure.  Obviously, they did not put in the effort to make a high-quality BIP.

In hindsight, probably that amendment to BIP3 got merged a little quickly.  It
seemed like a no-brainer, but really the more pertinent rule was already there,
which is we require that proposals are high quality, that they're discussed on
the mailing list first, and whether or not they used AI is probably not
enforceable in the first place, and it results in something being low quality.
And when it's low quality, it shouldn't be too hard to find a few points to
present why something is low quality.  But perhaps also importantly, we've
talked a little bit about the expectation of whether BIP editors have to reply
to every single email about BIPs or fully review every single proposal that is
open to the BIPs repository.  And several commenters said, it's probably not a
good use of our time and we should not.  And I think that's maybe the conclusion
and solution to this.  We'll just remove the determination about whether or not
you're permitted to use AI tools, but double-down on BIPs have to be high
quality, and if they're not, we're not going to spend a whole lot of time on
them.

**Mike Schmidt**: That makes sense.  It seems reasonable.  I mean, where is your
head at with that, Murch?  Do you agree?

**Mark Erhardt**: Yeah.  I mean, I thought that saying that AI stuff is not
welcome seemed pretty obvious, but I guess the phrasing of how that rule was
introduced was not high quality enough!  So, in hindsight, yeah, we merged that
I think end of October, or maybe early November, and that didn't help.

**Mike Schmidt**: You mentioned in your post to the mailing list a few weeks ago
that you were going to give four weeks, which in the newsletter we note as a
deadline of today.  So, given that there's still some back and forth, is that
being extended?  What's the next step?

**Mark Erhardt**: I mean, as the BIP2 process doesn't say who exactly decides
whether there is rough consensus, and that is more of an emergent determination
that people might propose on the mailing list, I said 'we' are giving four more
weeks, just to be clear.  It had been open to review for so long, I felt that it
might make sense to try and timebox it and elicit some feedback.  So, four weeks
seems very reasonable for a single document to be read.  Obviously, some of that
feedback only came in the last couple of weeks and will have to be at least
responded to.  But anyway, I think there will be a couple of follow-ups.  I
don't think we have to even talk about whether it has rough consensus today,
because obviously we'll have to amend that AI point.  And then, there's a whole
list of other questions that need to be answered to.  I've already answered to
the PR, but I hadn't answered to all of the mailing-list posts yet, because
there were about 20 or so.  Most of them are on the AI stuff, but there's a
couple of others too.

So, anyway, in hindsight, maybe holiday season is not the best time to try to do
this sort of thing.  But I'm also getting to a point where I feel this has taken
a lot of time and unless we're actually going to decide something, this will
stretch out forever.  So, I'm just trying to push a little bit towards coming to
a conclusion here.

**Mike Schmidt**: Now, Murch, let's say it's adopted in the next few weeks here,
or whatever, however that happens, you could always make changes to it, right?
Or would that necessitate it being a BIP4?  How does that work?

**Mark Erhardt**: So, until BIP2, BIPs were supposed to not get edited after
they're proposed, or very little, and definitely not after final, which is the
status that is used for BIPs that are adopted by the network or active process
BIPs.  We found that with BIP2, which had been adopted in 2016, there were a
number of things that cropped up since then.  And not being permitted to change
a process BIP felt like an unnecessary restriction, because if you're just going
to change a minor point in the BIP process, writing a whole new BIP seems
excessive.  So, BIP3 proposes that process BIPs are living documents, and once
BIP3 would be adopted, the way to amendments to BIP3 would be to propose them to
the mailing list and to discuss them for at least a month.  And if there is
consensus to adopt them, to adopt them, which is very similar to what BIP2 did,
but applies the process of activating process BIPs also to amendments of process
BIPs.  So, yes, it could be changed, but it would be changed with a large public
footprint, in the sense that it would be discussed on the mailing list.

To be honest, if someone has a better idea, that would be welcome.  But given
that there is no gremium or quorum or working group that is actually defined who
exactly is relevant to the BIPs process or involved and people review at their
own interest and own time, I just don't see a different way of making sure that
changes to the BIPs process get seen in public and get discussed in public,
except for discussing it on a mailing list.  So, yeah, they could be amended now
with BIP3, which is basically what we have been doing to BIP2 in the recent
past, although BIP2 does not expressly allow it.  I mean, just for example, you
can't amend BIP2, but the BIP editors are defined in BIP2.  So, if we get new
BIP editors, we're not supposed to change it.  It just doesn't make sense,
right?  I think it's just aligning what had been done in practice with what the
actual rules are, in the sense that now the discussion can happen and you can
amend the process without writing a whole new BIP, which has been a
several-hundred-hour effort for me in the past, well, almost two years.  So, I
just assume that we don't want to do that every few years.

**Mike Schmidt**: Well, it seems like it takes the pressure off of activating
BIP3 if you know that you could change it if there's something that comes up or
there's something that could be done better.  Obviously, you don't want that and
you outlined the process to do that.  It's not just a fly-by-night thing where
you're just going to go in one night and change it.  But that would seem to take
some pressure off of wanting every little thing to be perfect for eternity in
there.  Well, of course, I know that's probably what you want, but it would be a
living document by its own process.  So, that's good and takes some pressure
off.  So, it seems like you've fixed a couple of things, addressed a couple of
things, and we get BIP3, so great.  Thanks for your work on this, Murch.

**Mark Erhardt**: Well, hopefully.  We'll have to see how it pans out.

_Do pruned nodes store witness inscriptions?_

**Mike Schmidt**: Okay.  All right.  Let's move to the Stack Exchange.  We have
three questions in this month's Stack Exchange.  First, "Do pruned nodes store
witness inscriptions?"  And this is a question answered by Murch.  So, Murch,
does a pruned node store witness data?  And if it does, does it have to store
inscription data?

**Mark Erhardt**: Yeah, so pruned nodes are nodes that are fully-verifying or
fully-validating nodes that have consumed the entire blockchain, but then over
time throw away old blocks as they fall out of the tracked window.  So,
generally, a pruned node has to keep at least the last 288 blocks.  And when
blocks are older than that, they just get removed from the disk.  And so, the
pruned node basically just has a sliding window of the last blocks that it is
aware of.  From those 288 blocks, it keeps every byte.  So, yes, pruned nodes
store witness data exactly the same as all the other blockchain data they store,
and throw it away at the same time as they throw away other block data.

Now, there's an interesting property if you're syncing a new node with
assumevalid, which means you expect that transactions were valid if they are
buried deep enough in the blockchain, as in the scripts were not invalid,
because obviously they wouldn't be part of the best blockchain, let alone part
of the best blockchain buried several months of other blocks on top of them.
So, if you're syncing a pruned node that is using assumevalid, you could
theoretically not even download witness data, because you just download the
witness data, you do not do signature script validation, which is the only thing
that we use witness data for, and then you throw away the witness data when the
block falls out of your sliding window.

So, as an optimization for pruned nodes, you could forgo downloading witness
data for all the blocks that fall into the assumevalid window and only start
downloading witness data after you pass the assumevalid block for the last tail
end of the chain.  Yeah, I think that's all, right?

**Mike Schmidt**: Yeah, I think there was a follow-up.  This person was assuming
that it was that the node didn't need to store inscription data, so then was
saying, "So, why is OP_RETURN better?" but because you do have to store the
inscription data.

**Mark Erhardt**: Okay, if the additional question is, "Why is OP_RETURN
better?" for the most part, I think they're very similar in the way they affect
Bitcoin nodes.  You download them, you store them in the blockchain, you do not
store either of them in the UTXO set.  The difference is, from a system
resources perspective, OP_RETURN pay four times the cost.  OP_RETURN outputs,
because output bytes are non-witness data, cost 4 weight units per byte, whereas
witness data is witness data and affected by the segwit witness discount, and
therefore pays 1 weight unit per byte.  And that means that for the same cost
and the same amount of block space, you can get four times as many bytes stored
in the blockchain.  And that of course makes the blockchain grow more per block
space purchased.  And then, the other thing is that some inscription schemas,
let's call it that, they are extremely dumb designs and they require outputs to
determine what happens with the inscription that was created.  And this leads to
additional outputs being created, which is not really an aspect of witness data
or inscriptions themselves necessarily, but a specific subset of very dumb
protocols built on top of inscriptions that lead to additional output creation.

Theoretically, you could have the same sort of dumb protocols on top of
OP_RETURN.  So, I think that's mostly a wash as well.  But currently, protocols
in OP_RETURNS are not quite as dumb, so maybe that's a win for OP_RETURN too
then.

_Increasing probability of block hash collisions when difficulty is too high_

**Mike Schmidt**: "Increasing probability of block hash collisions when
difficulty is too high".  The person asking this question is saying, "Hey,
difficulty is going up.  You're going to have more hashes.  What happens, or is
it likely that there would be a collision in the block hash?"  And Vojtěch
answered this question, that obviously it's incredibly unlikely to occur.  And I
think we actually had a question on this before, or there was some discussion
about having additional fields for larger difficulties, but it was so
astronomically a small chance.  So, yes, basically the probability of that,
unless SHA256 is broken, is extremely unlikely, even with higher difficulty.
And then, Vojtěch also goes on to explain the second part of the person asking
this question, which is, "Why is the ID of a block essentially a hash of a block
header as opposed to some other scheme?"  And he went on to detail that, and he
also talks about the commitments in the block header and that essentially rolls
into why the block hash is what it is.  I won't read through these three bullet
points that he has in there, but pretty straightforward.

**Mark Erhardt**: I think the thing that is sometimes missed by people here is
just how unfathomable big 2<sup>256</sup> power is.  So, 2<sup>256</sup> power
is bigger than 10<sup>77</sup> power.  So, it is a number with 78 digits, right?
For comparison, there are maybe 10<sup>23</sup> stars in the universe.  So,
that's a number with 24 digits.  So, just the estimated amount of grains of sand
on earth are 10<sup>18</sup>.  So, there's more stars than grains of sand on
earth, but this is extremely dwarfed by just how unbelievably big
2<sup>256</sup> is.  You add 50 more zeros behind the number of stars in the
universe to get to that number.  Maybe that helps a little bit with why a hash
collision is extremely unlikely, because a hash collision would mean that you
pick two numbers out of this 10<sup>77</sup> and they are the same, and that
just doesn't happen.

**Mike Schmidt**: Well, Vojtěch also outlined that similarly saying, "It's not
going to happen unless you harness all the energy in the observable universe,
and then some, for the sole purpose of finding the collision".

**Mark Erhardt**: I think I saw a comparison once that was if we used all of the
energy of the sun just to count up to that number, the sun would burn out and
the heat death of the universe would arrive earlier than us just counting up to
that number.  So, let's just not be scared about this.

_What is the purpose of the initial 0x04 byte in all extended public and private keys?_

**Mike Schmidt**: "What is the purpose of the initial 0x04 byte in all extended
public and private keys?"  The person asking this is saying, "Hey, I see that
BIP32 specifies this 4-byte version and it starts with 0x04.  BIP 49 has that 04
as well.  BIP 84, 04".  So, they all have this sort of prefix, if you will, and
the person was wondering if that means something.  And Pieter Wuille answered
that it's just a coincidence that all of these 4-byte prefix versions are chosen
just to be specific values for which the resulting Base58 encoding would be xprv
for xpriv, or xpub for xpub, so that you have the Base58 encoding of those.
Anything to add to that trivia?  That seems like that would be something in one
of these Bitcoin trivia games at some point, if it wasn't already.

_LND v0.20.0-beta_

Moving to Releases and release candidates.  We have LND v0.20.0-beta, and we'll
bring in Gustavo who wrote up the Releases and release candidates and Notable
code and documentation changes for this week.

**Gustavo Flores Echaiz**: For sure.  So, this I think we've covered in already
three newsletters, the RCs of LND v0.20.  So, this is just the final official
release of LND, where here multiple bug fixes are introduced, a new noopAdd HTLC
(Hash Time Locked Contract) type is added, support for taproot fallback
addresses on BOLT11 invoices introduced, and many other RPC and lncli
improvements.  So, you can check out the release notes for that.  The other
major bug fix was a fix on premature wallet rescanning that we also covered in
about two or three weeks' newsletters.  So, yeah, finally the release is here,
no more RCs for this one.  I think we talked about it on others, but maybe you
guys want to add something here?  All good?

**Mike Schmidt**: Yeah, I think we've covered it the last few weeks, thanks,
Gustavo.

_Core Lightning v25.12rc1_

**Gustavo Flores Echaiz**: Perfect.  So, the next one is Core Lightning v25.12.
This is the first RC of this version.  The major changes in this one are that
BIP39 mnemonic seed phrases are now added as the new default backup method for
new nodes.  There's also many other improvements to xpay, which is the a plugin
used to pay invoices that uses an advanced routing system behind it called
askrene.  So, askrene is also improved with a new RPC command, called
askrene-bias-node, that allows you to favor or disfavor all channels related to
a peer.  I think we covered this one in the past newsletter.  Basically,
previously, let's say you had an issue on a channel, the bias would only
disfavor that specific channel.  Now, it will disfavor all channels of a
specific peer.  Additionally, a new subsystem, networkevents, is added to access
information about all peers.  We also covered this one in the last, or two
newsletters ago.  And finally, experimental JIT (just-in-time) channels is added
through a couple of options, and just in the mode where the LSP trusts the
client.  So, yeah, this is worth checking out and testing.  I already see that
the second and the third RCs have been released since then.  So, if you want to
test this one, check out the third RC.  Any thoughts here?

_Bitcoin Core #33872_

Okay, moving on to the notable code and documentation changes section.  We have
about ten PRs we covered this week.  So, the first one is on Bitcoin Core
#33872.  Here, a previously deprecated startup option, called -maxorphantx is
now fully removed.  Using it results in a startup failure.  So, in Newsletter
#364, we covered that there was a big change on how transaction orphanage works,
to preserve 1p1c (one-parent-one-child package) relay in the face of DoS spam
attacks.  So, basically, the issue with this setting -maxorphantx transaction is
that it defaulted to 100 orphans, but an attacker, a spammer could just replace
your entire orphan set and basically render your 1p1c package obsolete.  So,
here, in #364, we covered that there was a big improvement where limits were
changed to have global caps and peer caps to basically protect against DoS spam
attacks.  And at that moment, in #364, precisely in Bitcoin Core #31829,
-maxorphantx was deprecated.  And now, in this newsletter, we cover that it has
been completely removed.  Any thoughts here, Murch, Mike?

**Mark Erhardt**: Yeah, I wanted to chime in.  So, we had talked a lot about the
orphanage before.  The orphanage is, of course, for storing transactions for
which we don't know the parent yet, or are missing a parent.  This is much more
important now in the context of package relay.  So, when we do 1p1c packages, we
rely on the orphanage to have the child when we see the parent, in order to see
that parent and child together as a package would be attractive to add to the
mempool.  And being able to churn the entire orphanage with only 100
transactions made it very easy to break the support for 1p1c by just spamming a
bunch of orphan transactions, child transactions without parents.  So, the
orphanage was completely re-architected in the recent past so that we would
store instead the entries that we store in the orphanage, and sort of globally
limit the resources.  But if a single peer broadcast a lot of entries to the
orphanage, they would first churn out their own announcements and not affect
organic orphans that we received otherwise.

So, yeah, the orphanage was completely re-architected.  It will be much more
robust now to facilitate package relay.  And in that context, the configuration
option, -maxorphantx, did not make sense anymore, because we now have a global
limit and limiting just the account was removed.  And now, also the config
option was completely removed.

**Gustavo Flores Echaiz**: That's exactly right.

**Mike Schmidt**: We linked to this in the newsletter, but there was the PR
Review Club that we did with Gloria on this PR, and I thought it was good
explanation of not just this PR, but why this work is going into the orphanage
and what the orphanage is.  Murch elaborated on it just now a bit, but if folks
are curious about this particular data structure and why it's getting this
attention, check that out.

_Bitcoin Core #33629_

**Gustavo Flores Echaiz**: Yeah, that was in Newsletter #362, where the PR
Review Club was added for this PR.  So, it's #33629 where the cluster mempool
implementation is now completed.  Here basically, the general idea is that the
mempool is partitioned into clusters and each cluster is limited to 101 kvB
(kilo-vbytes) and 64 transactions each by default.  And each cluster is
linearized into fee-order chunks, which are sub-clustered feerate-sorted
groupings.  So, let's say you have a cluster with 64 transactions and there can
be like 20 chunks and the chunks are subgroups that are sorted by fee, right, so
you've got your chunks that pay the highest fee and you have your chunks all the
way down to those that pay the lowest fee.  The higher-rate feerate chunks are
selected first for inclusion of block template, of course, and the lowest
feerate chunks are evicted first when the mempool is full.

Another important point about cluster mempool is that the CPFP carve-out rule is
removed.  And also, it removes ancestor and descendant limits that are now
obsolete, because cluster mempool dictates the limits.  And also, transaction
relay is updated to prioritize higher feerate chunks.  Finally, the RBF rules
are updated to remove restrictions that replacements can't introduce new
unconfirmed inputs.  There's changes to the feerate rule.  It used to be that
your new transaction has to have a higher feerate than your previous transaction
to replace it.  But now, there's an overall cluster feerate rule, where this new
transaction has to improve the overall cluster feerate to replace the old
transaction, which is kind of similar, but a bit distinct.  Anyways, finally,
the final RBF rule update says that it replaces the direct conflicts limits with
a directly-conflicting clusters limit.  So, yeah, very important PR here, the
completion of a cluster mempool.  There was a follow-up that we're going to
cover in the upcoming newsletter, but yeah, this was the main completion PR for
this project.  Any thoughts here, Mike, Murch?

**Mark Erhardt**: Yeah, so we've talked a lot in the past already about cluster
mempool.  Cluster mempool has been a multi-year project by some of Bitcoin
Core's most prolific contributors.  First, maybe the good news is for the users
of Bitcoin, unless they're doing very weird, odd transaction graphs, they should
not notice at all a difference.  So, while we are very excited at the mempool
design level, hopefully you will not at all notice that cluster mempool is
rolling out.  If at all, you might notice that when you're trying to get, for
example, a withdrawal from an exchange to go through more quickly, and you
immediately try to spend the output that you received, it will collaborate with
other transactions spending from such a batch payment, rather than competing for
inclusion.  So, in the ancestor-based block-building, each of those child
transactions would be evaluated with the parent, and a batch payment being
pretty big, you'd have to pay a substantial amount of fees in order to bump a
parent transaction significantly.  And with many different child transactions
trying to spend from a batch payment, they would all be contributing towards
that being a chunk that has a high feerate.

It might become a little less transparent to the individual node of whether or
not the transaction will actually expedite, how much it'll expedite.  It's very
transparent that it will expedite if you pay more on your child, but the final
effect of the final chunk feerate might be less obvious because other people
interact in collaboration with the parent-effective feerate.  So, it might be
slightly less clear what the minimum fee is to get the effect you want, but
overall, things should come through more quickly if they get bumped.  So, yeah,
I think for wallet designers or people that are worried about how bumping will
work in the future, If you use the same strategy as before, you will just
achieve the same effect or a better effect by doing the same thing as before and
pretending that your transaction is the only one that matters to the parent.  If
you're trying to minimize the fees you're paying, you would have to run a full
node and be aware of other child transactions of the parent that you are
bumping.  And then, you could assume that these transactions will remain in the
mempool and pay a lower fee to achieve the same effective feerate.

So, that all being said, hopefully you would not even notice a difference.  It
should only get smoother.  For people that are mining, they should find that
with a cluster-mempool-based node, their block templates will be slightly faster
to build, or maybe not even notice, and eviction would be slightly more
efficient.  So, overall, hopefully you don't notice anything.  If you're
building huge peel chains or frequently-batched payments, that would hopefully
work a little, better because the cluster limit is bigger than the prior
descendant limit that was only 25.  The package limit is still the same.  That
was also the descendant limit in total weight.  So, either the descendant
structure or ancestor structure were limited to 101 kvB, and now also the
cluster is limited to the same.  Yeah, so us nerds are very excited about this.
This is scheduled for release in 31.  It'll come out in April, but the effect
should hopefully be transparent to just benign to all the users.

**Gustavo Flores Echaiz**: Great summary.  Thank you so much for that, Murch.
So, yeah, that completes the cluster mempool project, besides for a follow up PR
that we'll be covering in the upcoming newsletter.  But yeah, I think kind of
relevant when people were talking a lot about the mempool lately.  So, if
someone wants to dig into the details, there's a lot of opportunity for that.

_Core Lightning #8677_

Moving on with Core Lightning #8677.  Here, many improvements are made for the
performance of large nodes, nodes that have just millions of potential channel
events or chainmoves events.  So, a few things are done.  First, the number of
commands related to RPC and plugin are limited, how many of these commands can
be processed at once is limited; there's a reduction of unnecessary database
transactions for read-only commands; and there's a restructuring of the database
queries to handle millions of channelmoves or chainmoves events more
efficiently.  What I thought was interesting was the last part of this PR, where
a filters option is introduced to a few hooks that enable plugins to receive
specific invocations.  So, instead of, let's say xpay, a specific plugin used to
pay invoices, instead of xpay receiving all events from the node, it can only
subscribe to specific invocations so that it only receives what it strictly
needs.  And this is probably the main improvement that allows for more
efficiency and performance on larger nodes.  But overall, many, many
improvements for that.  Any thoughts here?  Awesome.

_Core Lightning #8546_

Core Lightning #8546.  Here, a withhold option is added to the
fundchannel_complete event or command, which delays the broadcast of a channel
funding transaction until sendpsbt is later called or the channel is closed.
So, basically here, the idea is to allow LSPs (Lightning Service Providers) to
postpone opening a channel until a user provides sufficient funds to cover the
network fees.  So, let's say translating this to the user's experience, a user
using a wallet wants to receive over LN but doesn't have any channels or
specifically any incoming liquidity.  So, an LSP allows a user to fund for this
channel, but it won't open the channel until the user has funded sufficient
funds to cover the network fees.  And this is necessary to enable the other mode
in JIT channels with client-trusts-lsp, right, because here the LSP could
technically never broadcast this channel funding transaction.  But in general,
the reputation of the LSP makes it that he will, once a user provides sufficient
funds to cover the network fees.

So, this is clearly just a precursor to another PR, where the follow-up mode,
client-trusts-lsp will be added in Core Lightning (CLN) to fully support JIT
channels.  Any thoughts here?  Perfect.

_Core Lightning #8682_

Moving on, Core Lightning #8682.  So, this is the last one of the CLN PRs.
Here, the way blinded paths are built is updated to require peers to have the
option-onion-messages feature enabled.  So, for a peer to be chosen part of a
blinded path, only the blinding route option is needed, or only that feature
needs to be enabled for that peer.  However, there was reports of an issue where
LND nodes that would have the route blinding option, so they would be selected
for a blinded path, would fail to forward a BOLT12 payment.  So, basically the
solution found in this PR was to require peers to not only have their blinded
route feature enabled, but also have the onion message feature enabled.  And
this makes it that what was a previously chosen LND node that would fail to
forward a payment is no longer chosen, unless he supports both features.  And if
he does, then he shouldn't fail to forward the BOLT12 payment.  So, kind of a
minor detail, but important to note.  Any thoughts here?

**Mark Erhardt**: I think I disagree a little bit on the characterization here
in the end.  So, it sounds like actually the route blinding required for BOLT12
payments that onion messages are exchanged to, so this is a bug, it picked nodes
for the blinded path that could not participate in this because they didn't have
the option.  So, this strikes me more as a bug fix.  Don't pick nodes that
actually can't process the feature that you're trying to use.

**Gustavo Flores Echaiz**: Right.  Well, that is a good addition to this.  I
guess what confused me was kind of the discussion they had on this PR.  But
yeah, that what you said makes more sense.

_LDK #4197_

So, let's follow up with LDK #4197, first of three LDK PRs.  Here, this is an
interesting one.  So, basically, when a node disconnects and reconnects to a
peer, they will share a channel_reestablish message to synchronize on the state.
Usually, previously, the node would fetch the signer, which might just be part
of the same node, but sometimes the signer can be remote.  So, while the node
fetches specifically the commitment points to the signer to make sure that the
peer and the node are at the same state, the node would pause its state machine
when its signer would be remote.  So, here, instead of the node pausing the
state machine while fetching a commitment point from its potentially remote
signer, LDK caches the two most recently revoked commitment points in
ChannelManager to be able to respond to a peer message without needing to fetch
the commitment point from the signer.  So, because ChannelManager at some point
had those commitment points, previously it didn't save them, but now it caches
them to not need to communicate in real time and pause the state machine.

So, what happens here?  Well, in normal cases, the LDK would simply confirm that
what its peer sent as the commitment point makes sense.  However, if a peer
presents a different state, then LDK or the ChannelManager will communicate with
the signer to validate the commitment point.  And if LDK finds it to be invalid,
then it will force close the channel.  However, if LDK finds that the state is
valid, but doesn't have that recorded commitment point, then LDK crashes because
this is an unexpected situation.  So, in Newsletters #335, #371 and #374, we
cover other updates to LDK on channel_reestablish.  Yes, Murch?

**Mark Erhardt**: Is this crashing when it is presented with a valid state that
it doesn't have?  Is that the outcome now after the change, or was that the
behavior before it was fixed?

**Gustavo Flores Echaiz**: That has always been the behavior.  What has changed
is the caching of the two most recent revoke points.

**Mark Erhardt**: Okay, so does it actually crash or throw an exception?  So,
basically, what we're saying is, let's say you and I have a channel and we sign
these commitment points.  When we exchange transactions, they are signed, so you
would be presenting me a something that I had committed to, that was signed with
my key that I can validate I have signed in the past, that does not match my
records.  So, essentially this could only happen if I had rolled back to some
sort of backup and was unaware of an alternative history that you have.  I guess
there's just no provisions for handling this, because this is basically a user
error and hard to prevent and shouldn't ever happen naturally.  But if you're
aware of the situation, outright crashing seems odd.  So, that's why I was
asking back whether this is the final outcome.

**Gustavo Flores Echaiz**: Right.  Well, the description says LDK needs to panic
in this situation, which to me translates to crashing.  But maybe they meant
something else by it.  But yeah, this is an extremely rare situation where your
node has basically lost its latest states.  So, it can validate that it was
valid, but it doesn't have it, so it then panics or crashes.

**Mark Erhardt**: Yeah, I guess maybe if you're trying to reestablish a channel
that you don't have the latest history for, and your channel partner presents
you with an alternative history that you committed to, that is not easy to
handle.  So, maybe this actually does lead to a crash then.  Yeah.

_LDK #4234_

**Gustavo Flores Echaiz**: Yeah, precisely that.  So, following up with LDK
#4234, here the funding redeem script is added to the ChannelDetails and the
ChannelPending event to enable LDK's onchain wallet to reconstruct the output or
transaction out of a channel, and accurately estimate the feerates when building
a splicing transaction.  So, basically the problem here was that LDK's onchain
wallet was building a splicing transaction, it was unable to properly estimate
the fees because it didn't know the exact size or virtual size of the input used
from the channel funding transaction.  So, here, the funding redeem script is
added to a few events, which enables LDK's onchain wallet to properly
reconstruct this channel funding transaction output that it uses as an input,
and accurately estimate the feerate when building this splicing transaction.

_LDK #4148_

Perfect, let's move on with LDK #4148.  Support for testnet4 is added to LDK by
simply updating the rust-bitcoin dependency to version 0.32.4.  So, you can
check out Newsletter #324 for when we covered that Rust Bitcoin added support
for testnet4.  So, LDK here is simply updating its dependency to add the support
as well, and it also adds that as a requirement.  It also adds this version of
Rust Bitcoin as the minimum supported version required for specifically the
lightning and lightning-invoice crates, which LDK uses.

_BDK #2027_

Finally, the last PR covered in this newsletter is BDK #2027, where a new method
called list_ordered_canonical_txs is added to TxGraph, which returns canonical
transactions in topological order, where parent transactions always appear
before their children.  So, in Newsletter #374, we covered a major change to BDK
where a struct called CanonicalView was introduced, which performs a one-time
canonicalization of a wallet's TxGraph.  Canonicalization just means that it
will basically linearize the transactions of the wallet.  And here, a method is
added that basically builds on top of this to easily return the transactions in
canonical and topological order.  There were two methods that are deprecated,
called list_canonical_txs and try_list_canonical_txs, to prioritize the new
ordered variant.  The way it's different is that it builds in topological order,
where parent transactions always appear before their children.  So, you can
check out Newsletters #335, #346, and #374 for previous work related to this on
BDK.

**Mark Erhardt**: Thanks, you answered exactly my question that I was about to
ask, "What was canonical transactions again?"  So, I just wanted to mention it
absolutely makes sense to order these transactions topologically, which means
that parents come before children, because of course if you have change outputs
and so forth, they would only be able to occur in that order.  So, whatever
you're doing with this list of transactions, which is presumably some sort of
algorithmic treatment of that, would make more sense to consume them in the
order of topology.

**Gustavo Flores Echaiz**: Exactly that.  So, that completes this newsletter.
Thank you, Murch and Mike, and all our listeners.

**Mike Schmidt**: Yeah.  Thank you guys for co-hosting this week.  And yeah,
thanks for everybody for listening.  Murch, any final parting words?

**Mark Erhardt**: No.  Thanks, hear you soon.

**Mike Schmidt**: All right, cheers.

{% include references.md %}
