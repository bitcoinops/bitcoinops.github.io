---
title: 'Bitcoin Optech Newsletter #238 Recap Podcast'
permalink: /en/podcast/2023/02/16/
reference: /en/newsletters/2023/02/15/
name: 2023-02-16-recap
slug: 2023-02-16-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by AJ Towns, Yuval Kogman, Alex
Myers, and Vivek Kasarabada to discuss [Newsletter #238]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/66951337/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-2-20%2F5ea97eb6-f7fd-fa9e-2906-a6095c271e8d.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: This is Newsletter #238 Bitcoin Optech Recap on Twitter
Spaces.  I'm Mike Schmidt, contributor at Optech and also Executive Director at
Brink, where we fund open-source Bitcoin developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work on Bitcoin stuff for Chaincode Labs and
contribute to Optech.

**Mike Schmidt**: AJ?

**Anthony Towns**: Hi, I'm AJ, I work on Bitcoin stuff with DCI.

**Mike Schmidt**: Yuval?

**Yuval Kogman**: I spend a lot of time doing coinjoin stuff, I guess.

**Mike Schmidt**: Seardsalmon?

**Vivek Kasarabada**: Hi, my name's Vivek.  I do corporate development for
Blockstream, so not a dev, and that's why I need Alex!

**Mike Schmidt**: Well, thanks for joining us.  Alex, do you want to introduce
yourself?

**Alex Myers**: Sure, yeah, I'm at Blockstream working on Core Lightning.
I'm one of the newer developers there, but just doing this current release cycle
for our February Core Lightning release.

**Mike Schmidt**: Well, thank you all for joining us.  For those following along
on the Spaces, I've shared a few tweets that outline the newsletter topics and
we'll just be going through that in sequential order, starting with the news
section.  Murch, any announcements before we jump in?

**Mark Erhardt**: No.

_Continued discussion about block chain data storage_

**Mike Schmidt**: All right, let's do it.  Well, the first news item this week
is about block chain data storage, and I think this topic has been a hot topic
with the ordinals inscription project taking up a lot of block space recently,
causing a lot of chat around Twitter and some discussion on the mailing list,
etc.

**Mark Erhardt**: Oh, that's why there's so much block space demand.

**Mike Schmidt**: Yeah, I know you've been doing a lot of analysis on that.  We
should probably share some of those tweets here as well, I think it's
interesting information.  But putting data on the Bitcoin block chain is
potentially not the only way to achieve coloring coins, or the idea of
attributing data to a particular satoshi, and AJ has an idea that he
pontificated on the mailing list, which I'll let him outline, of potentially a
different way to do that.  AJ, do you want to outline your thoughts on this
matter and your mailing list post?

**Anthony Towns**: Sure.  So, the thing that I thought was particularly
interesting about the ordinal inscription stuff is that unlike all the other
things I've seen, like RGB and Taro, it has a really clear separation between
the concept of transfer of assets and creating the assets in the first place,
and I mean there's always been that separation everywhere this happened, this
different function calls for things in inscription stuff.  This is the
inscription spec and this is the ordinals spec and they're two completely
separate things.

So, the idea I posted about on Twitter originally, and then followed up on the
mailing list, was that you could just have a completely separate standard for
the inscription side of things that doesn't need to be onchain at all.  The
thing to me is that if you want bitcoin to be censorship resistant, or if you
want bitcoin to be cheap and efficient for millions or billions of users around
the world, you need to have as much stuff offchain as possible.  So, any time
you see something that goes onchain, I think the question you should be asking
is, "Can we move this stuff offchain and still get pretty much the same
behaviour?"

The way inscriptions work is just you have a transaction onchain, which encodes
all the data, or for other things maybe includes a hash of the data, or whatever
else, and that's how you tie the data and the UTXO that you're going to transfer
out, representing ownership or whatever of the data, and that's how you tie the
two things together.  But you could do it the exact opposite way round and have
the data somewhere else and have cryptographic commitments as part of the data
back to the UTXO that you want it to be associated with on the block chain, or
the ordinal that you want it to be associated with.  And so, the post is just a
quick spec of how you might do that based on a nostr-json kind of encoding.

There were a few follow-ups to that with why people think the important thing is
not so much that you got the ID, but that you're putting it on the Bitcoin block
chain and getting some cachet from having it be in, for example, the top 100,000
inscriptions on the Bitcoin block chain, and that's what makes it special and
worth money, rather than maybe the content of the image or something in the
first place.  And, I think I posted an alternative to that, which is that you
can just apply the scarcity more directly by having proof of work as part of
your nostr messages.  So, rather than paying the $6 to get it into the block
chain, you'd be spending however much CPU time that is equivalent or better to
demonstrate that you'd put the effort into this inscription, into this ordinal,
into this whatever you call the offchain version of it, that makes it scarce and
therefore collectible or valuable, or whatever.

I just think that having an offchain approach is going to be much more scalable,
and because it's offchain, that means that you can't do all the censorship
things that people are doing or worried about, where you identify a transaction
that's an inscription and then don't accept it in your mempool, don't relay it.
If you're doing stuff offchain, people just don't really have that opportunity
because they don't see the association onchain.  So, if you're trying to do all
these NFTs and trying to get the censorship resistance that comes with bitcoin,
then moving as much offchain as possible is much better for that too.  Anyway,
that's my thoughts.

**Mike Schmidt**: Murch, you've got your hand up?

**Mark Erhardt**: Yeah, I wanted to touch on something that AJ said and that
I've heard previously from someone else, and I'm hoping that I manage to restate
it correctly.  I think it's important to note that the image in most cases is
not really scarce; often, it's a copy from something published somewhere else
already.  So, the scarce thing is really the representation onchain and the
claim or the token that is onchain.  So, the ordinal is the scarce thing, the
block chain is just being used as a publication medium for often data that has
been published elsewhere already.

So really, what is a little strange around the whole inscription craze is, for
an inscription to actually be unique and/or closely associated with the ordinal
that it is supposedly tied to, I think that the data or the image would need to
commit to the specific ordinal that it is going to get published in.  So, the
data has to link to the onchain record and that has not really happened, or I
have not seen that happen yet, and that would align very well with what AJ is
proposing, where the data is published in maybe a different means, maybe
offchain, but you have maybe a commitment in the data to what is the process
onchain and create what a token or representation is, and then you actually get
scarcity because even if people right-click copy that image, it commits to a
specific owner onchain.

**Mike Schmidt**: Murch, are you saying something like the image file itself,
via steganography or some other such thing, would commit to the creation of that
NFT for example; is that what you're getting at, with the image having some
commitment back to the creation of it onchain?

**Mark Erhardt**: Yeah, so if you have say a set of seven images that are
supposedly valuable because the artist says, "I made these brilliant images and
I only will create these seven and they are a collection and a set, and I will
assign them to ordinal 100, 101, 102, 103, 104, and so forth", so this is part
of the art project; and then the images may be on the image in the corner
somewhere as part of what becomes basically the fingerprint of the image and the
hash proof of what image exactly is being traded here with the ordinal, they
commit to the number that you attach it to onchain.

So, by having the commitment in the image to commit to the ordinal, I think I
start to understand why it might be scarce.

**Mike Schmidt**: AJ, you mentioned some of the comments on your idea having to
do with there being some value to the image data being in the Bitcoin block
chain and trying to recreate that in some other manner.  Some of the feedback
that I saw was also that, "We don't know if any of these are file systems or an
example of nostr, there's no guarantee that message will be held indefinitely,
but we have this thing called the Bitcoin block chain that we all think is going
to be around forever, or maybe longer than it would be in a nostr message, or
some such thing".  What's your feedback to that?

**Anthony Towns**: I mean, if you've got this valuable NFT, then it doesn't
really make any sense to me to not have a copy of it yourself.  If you've got
offchain data that provably links to the ordinal, then having a copy of the
image, or whatever it is, yourself already has that link to the ordinal back
yourself, so you don't need everyone else to have it, you've got a copy yourself
and then you can give that to anyone you want to have it.  It's a fair claim
that, okay great, we can just have all this stuff on the block chain and then I
don't need to keep a copy; if I lose it, I can always recover it.  But for me,
that's just outsourcing the problem to a bunch of people who don't really
benefit from it, which is the whole economic externality thing and you're giving
cost to other people and they're not getting any benefit for it which, I don't
know, is annoying at best.

The other problem with that is that then people might decide, "We don't want to
pay that cost, so you know that idea that we're going to have permanent archive
nodes of Bitcoin forever?  That's just too much hassle, so we won't do that
then"; rather than Bitcoin is around forever, we've got witness data forever, we
start printing stuff, everyone prints, and then suddenly you can't go back to
genesis anymore because nobody's got all those archives, because it was just too
expensive keeping all those jpegs about.

If you want to do inscriptions, then you should be able to run a Bitcoin node.
If you're able to run a Bitcoin node with inscriptions, then you can just manage
a file system with just your inscriptions much easier than that because you
don't have to keep a copy of everyone else's.  So to me, that doesn't make
sense, but that's my opinion, not everyone's.

**Mike Schmidt**: That makes sense.  So, the owner of these offchain data pieces
is incentivized to keep them themselves, whether that's on Dropbox or their own
file system, or running a nostr relay that happens to have an archive of those
pieces of data, and so that motivation will be the reason that data stays
around, not the fact that you're externalizing this to the entire Bitcoin
Network?

**Anthony Towns**: Yeah, exactly.

**Mike Schmidt**: So, Murch, I guess the question is, when Optech NFTs on nostr
in Bitcoin?

**Anthony Towns**: When are we moving the space to nostr?

**Mark Erhardt**: …!

**Mike Schmidt**: AJ, one question that I had about your proposal, and I'm sure
you clearly described it but maybe I just missed it, it does sound like anybody
could create an NFT, let's go with the nostr example.  As the creator of the NFT
or this inscription on nostr, I as the creator can start sending ownership of
certain satoshis associated with this data to, for example, Satoshis' UTXOs, or
anybody's, it's not just the owner of that satoshi that can inscribe, there can
be other people and then you could end up spamming people with additional
information?  But I guess the point is, it's not the owner onchain that needs to
do it, it could be anybody?

**Anthony Towns**: You could do that with inscriptions as well essentially
though, because once you've created the inscription against your UTXO, you can
just send that UTXO to whoever's address.

**Mike Schmidt**: Yeah, that makes sense.  And then I think you outlined in the
mailing list post that there's the potential then that you would have several of
these inscriptions attributed to a single satoshi and it might not be possible
to split those off, those "maybe spam" inscriptions off of your satoshi?

**Anthony Towns**: Yeah, so that's a limitation of the ordinals' way of moving
assets around.  If you split out the inscription/ordinal part from these other,
like Taro and RGB, Taro lets you split up the assets in other ways and I feel
like you could probably pull out the transfer part of Taro and have an offchain
creation of assets that then says the assets follow the Taro way of doing things
and not have that problem.  But I tried reading the Taro BIP and I got lost, so
I can't actually give any details on how that would actually work.

**Mike Schmidt**: Murch?

**Mark Erhardt**: I mean, in a way that's an advantage of having offchain data
that commits to the original ordinal that it was attached to, because then if
other people attach stuff to your ordinal, you can choose, as the owner of the
ordinal, whether you keep a copy of that.  And if you don't and nobody else
does, it just disappears again.

**Mike Schmidt**: AJ, I think you referenced a previous post that was a little
bit more hostile, I guess, to this idea of colored bitcoins, and I think you've
come to the conclusion that it's inevitable and that we should deal with it, as
opposed to trying to prevent it or avoid it?

**Anthony Towns**: Yeah, the post that I linked to from sipa is pretty much what
I had been thinking until all this stuff came out the past few weeks, and
there's two things about that.  There's one that if it's unavoidable, then it's
unavoidable and we just have to do it; but the other issue is how it relates to
mining incentives or consensus change incentives.

So issuing USDT or stablecoins, or whatever, is the other side of the NFT, it's
the fungible token side of things.  And I think there's fair concern that if you
have billions or trillions of fiat dollars on the block chain, how does that
affect incentives?  Once you've got a protocol that works for NFTs, then
extending that to something that works for fungible things, and if it works for
NFTs in an efficient way, maybe it works for stablecoins in an efficient way,
and if that's eventually going to cause problems, then you want to draw a line
and try to stop it.  I think there's a fair question as to, does that actually
create incentive problems?

To me it seems like if all you're doing is moving sats around and people are
assigning value to those sats, it's not completely off the chain that you don't
have any way of telling about, then that feels the same to me as if I'm paying
$1,000 for life-saving surgery, then that means a lot more to me than you paying
$1,000 for a picture of a Bored Ape, or whatever.  That's not changing the
incentives in a fundamental way, it's just some things I value more than you
value, and if I'm going to be willing to pay a lot higher fees for my $1,000
than you are, then that's just something that we have to deal with and is
probably fine anyway.  That's kind of where my thinking's at now, but that still
seems like a really important question to think about, rather than one that I'd
say I have an answer for, or anything.

**Mike Schmidt**: So, maybe one example to think about this is in the fungible
token example, if you can attribute $1 billion to a particular satoshi, does
that mess with Bitcoin's incentive mechanism?  I guess the jury's out on that,
or you think that maybe there's not an issue with that?

**Anthony Towns**: I mean, how is that different to assigning $1 billion to one
particular UTXO, which we do already by just having however many bitcoin in it?

**Mike Schmidt**: Well, I guess the only difference in that example is that the
value "in bitcoin" versus the value being in Tether's reserves, or whatnot,
right, I'm not bringing this up as an actual concern, rather than pointing out
that there's a difference between those two.

**Anthony Towns**: Yeah, so at some point if the value of bitcoin is trivial and
miners are getting paid in bitcoin and you just can't get an amount to pay
people in bitcoin that's not trivial, then maybe that means that the security of
moving the things that are worth non-trivial amounts on Bitcoin doesn't make
sense.  But at least to me, it currently feels like that's not as much of a
concern as it felt like a few weeks ago.  But yeah, that's much more of a
feeling than something I can argue, I guess.

**Mike Schmidt**: There was another item that was related to block chain data
storage.  Actually, we have Rodolfo wanting to come in here.

**Anthony Towns**: Just unrelatedly, I've heard a bunch of people in the last
week or so saying that there's a whole bunch of Ethereum folks firing up nodes
to play around with ordinals inscriptions and NFTs, and whatnot, and I'm just
looking at Luke Dashjr's charts of node adoption stuff, and it looks like it's
gone up from 48,000 nodes a couple of weeks ago to 52,000 nodes, which is a
relatively big increase, which is interesting.

**Mark Erhardt**: I've also seen a ton of people that seem to have technical
expertise ask novice questions on Bitcoin Stack Exchange, so they do seem to be
a bunch of engineers, or people that have at least dabbled with block chain
stuff, suddenly coming on Stack Exchange to ask questions.

**Mike Schmidt**: Go ahead, Rodolfo.

**Rodolfo Novak**: Hey, guys, I was trying to avoid the topic, but I guess I
couldn't help myself!  So, I think there's a few things.  One is, my preference
on this is I don't think it's great to use the block space personally.  There is
a massive demand for this, and the perception I get from talking to people who
like this stuff is that the whole point of doing this the way that they're doing
and talking to Casey as well is that they want to do this the Bitcoin way, which
is very anchored into the chain, and the inscriptions are done once, and they're
put in a block and they don't get moved, the sats' ownership moves, and that's
how they perceive the scarcity value of this, is the fact that it is a very
early block in their ordinal system thing.  So, that's why they're not
interested in doing it offchain.

That was essentially why so many of the people doing this crap on Ethereum,
they actually created a bridge to burn their NFTs on Ethereum to bring them to
Bitcoin.  They want that to be inscribed on the Bitcoin chain, to many of our
dismay, but that is a valid transaction; in my view at least, it is a valid
transaction.  I mean, it gets in a block, it's paying a fee, I don't believe
there is spam on Bitcoin if it's paying.

The other thing that I think a lot of people are missing here in the forest for
the trees is that blocks should be full.  I mean, people should be using bitcoin
and blocks should be full.  So, the original sin here is making the Bitcoin
blocks 4 MB and having them huge, and that's the real problem.  It's kind of
similar to roads; the more roads are built, the more people buy cars and drive,
which I think is a great thing.  But using wishful thinking for blocks to be
emptier so that people can sync faster I think is the wrong way of looking at
this.  I guess I just wanted to put that out there.

**Mike Schmidt**: Rodolfo, do you think it would be the Bitcoin way if some
version of what AJ outlined comes to fruition and you're using nostr to issue
and privacy, etc?

**Rodolfo Novak**: Probably not.  I think that their goal is to actually have
the art itself inscribed forever in the cathedrals; I think that is their goal
and this was very deliberate.  It was actually kind of clever.  It's weird to
think about this as clever, but it is.  They even have MIME types on the
inscriptions.  It's very easy for any block explorer to look at a block, find
that witness and actually render it.  They don't have to support anything, but
any MIME type that exists can be essentially inscribed there if the data amount
fits.

I think the strife now is coming from the fact that people got off-guard with
the fact that the witness for taproot doesn't have a limit.  Two main issues
are, one, we could find ourselves in the next activation period, where there'll
be a lot of strife and discussion on limiting that witness size that could have
a lot of impact on scripts that people want to do.  I actually don't have an
issue with limiting that script size a little bit; it doesn't have to take a
full block, so maybe that was a mistake.  It's just too much of people arguing
about this stuff, but I feel like neither side understand each other, people
don't seem to understand the market demand for this, the reason why it was
designed the way it was designed and how it actually works.

Then, on the other side, I don't think these people understand how important
this block space is, and these jpegs could actually take away cheap block space
from, say, Lightning channels that may be economically less than the jpegs.  I
don't think the jpegs compete with actually monetary transactions at all, the
density is just too different; they'll get pushed out of that.  But for the
Lightning, that could be a concern and I don't have a good answer.

**Mike Schmidt**: You mentioned potentially tightening witness restrictions, but
there is some discussion on the mailing list about OP_RETURN space and actually
loosening the restriction on the data that you could put in OP_RETURN, even
discussion looking at a free-for-all.

**Rodolfo Novak**: I mean, Jesus Christ, no!  We've already had the discussion
about OP_RETURN 12 years ago.  I also don't like the idea of just having this
vestigial organ that OP_RETURN is around.  If you have stuff to put in there,
put it in the witness, put it in a transaction.  OP_RETURN is a weird vehicle to
put these things, in my view.

**Mike Schmidt**: Murch?

**Mark Erhardt**: Yeah, I agree with witness being a better place for it.  It's
also cheaper to put stuff in the witness.  There are already people considering
at least to work on synchronisation optimisations disregarding some of the
witness data.  In a way, I think the increased demand for block space recently
has shown again that people are willing to pay a lot more for payments.

We've had a ton of blocks that have had their minimum feerate of over 20 sats
per vbyte.  I don't really think that it's going to hamper payment traffic too
much.  It might be pushing out the very cheapest part of very smallest payments,
where people are sending micro-amounts, like less than $1 or less than $10, and
those should hopefully, in the long run, be served by Lightning or other
offchain solutions.  It will make opening a Lightning channel a little more
expensive, but I think a Lightning channel can still usually afford 20 sats per
vbyte or something.

So, if there's now a buyer of last resort to inscribe jpegs on the block chain,
but for the most part we're just using it for payments before we fall back on
the secondary use, I could see that with more demand, there will just be less
inscriptions on the block chain anyway.

**Rodolfo Novak**: There are two side effects of this that I like.  One is, we
don't have to talk anymore, no more discussions about security budget and tail
emissions crap, because technically this is filling up the blocks and giving
money to miners.  And the other thing is, maybe there are more talks about more
data compression and clever things people can do to the data that could actually
help Lightning maybe compress some of their bigger channels and things that they
want to put in there.

**Mark Erhardt**: Or, if we actually get something like Utreexo done, people can
just skip the whole witness data altogether.

**Mike Schmidt**: Go ahead, AJ.

**Anthony Towns**: So, a couple of background things.  I've seen a whole bunch
of people talking about how blocks are suddenly 4 MB and that was never
conceived as possible, and stuff, and I'm sure lots of people haven't considered
it, but that was certainly something that was pretty heavily thought through
when segwit was originally proposed and the size limit, or the witness data, was
set up so that you could go up to 4 MB.  And there's two reasons for that I
think are worth going into a little bit.

The first reason for the limit is, the way it's set up is that you've
effectively got, as long as people started using segwit addresses and spending
with segwit, then the normal sort of use case more or less got double the amount
of transactions that you could get, so that was one side of it.  But the other
side, the basic way everyone figured, was that the worst-case scenario was
something that we'd be able to cope with.  Like 8 MB was one of the other
numbers that was being thrown around at the time, and that was a little bit big
and 4 MB was something that folks thought they could deal with.

The reason that we thought we could deal with that was because the segwit
rollout got essentially delayed until we could implement the compact block relay
stuff.  So, with that enabled, I think the 4 MB stuff works pretty well and has
pretty much demonstrated that we can cope with it, cope with those sized blocks
without much impact on the network; at least, that's how it seemed as far as
I've seen, and maybe if people are actually having problems and not just
frustrated with it, then that would be something that's worth knowing about, and
maybe deliberately reducing sizes based on that.

I think the other thing that's possibly interesting, once we've got maybe a
couple of months of experience with this, is that if we're filling up, I don't
know, 50% of block space with 1 satoshi per byte, big jpegs, and maybe we've got
some idea of how much they're going at auction for and can thus get some value
on how much value that's creating versus the remaining 50% of block space that's
going to regular transactions, or Lightning channels, or whatever, and seeing
the comparative value, willingness to pay fees, whatever, for those two
different types of transactions, that might be something that miners look into
and decide to actually add soft limits to the block size again, which is
something we used to have up until 2014, or so, I think.

That sort of thing doesn't require a consensus change, it's just that miners
might decide, "Yeah, we can make a lot more money if we reduce the block size",
and regular transaction users might decide, "Okay, this is more efficient and we
can still do this stuff at essentially the same price", so it's win/win.

**Mike Schmidt**: Murch, you had your hand up?

**Mark Erhardt**: So, I'm going to jump back a little bit in what you were
talking about.  So, one effect that the 4 MB blocks have had, or maybe have had
a part in, is last year forkmonitor.info had six blocks at the same height.
Well, this year already we've seen three, so we've had three one-block reorgs in
the last six weeks already.

**Anthony Towns**: So, I had a look at that the other day as well, and I was
going to make a snarky tweet about it, but in looking at it, thought that three
or four of the ones last year were in the January/February period as well, so
I'm not entirely sure that's an actual change, rather than just a seasonal
thing.

**Mike Schmidt**: Interesting.  What would explain the seasonality in that?

**Anthony Towns**: I have no idea.

**Mike Schmidt**: Murch, any thoughts?

**Mark Erhardt**: It could be that miners move to different regions in different
seasons because of power costs, hydro being cheaper some parts of the year, and
they just have worse internet connections in those regions.  That could be a
regional/seasonal effect.  I do see that they were February and April and May
were four of them last year.  Well, anyway, I think maybe their sample set is
also just a little too small to read too much into that.  But yeah, I thought it
was interesting that we had three stale blocks already.

**Anthony Towns**: Yeah, I thought it was interesting too.  The other thing is
that we don't have a uniform mempool policy at the moment, with some people and
some miners doing the mempool full of EF stuff; and I know of the recent ones,
two of the blocks, alternative blocks, had significant-ish added transactions.
So, that's another possible current cause for that, rather than --

**Mark Erhardt**: Oh, interesting, yeah.  All right, maybe enough on this?

**Mike Schmidt**: Yeah, I just wanted to give AJ an opportunity to opine on the
OP_RETURN space discussion, if you have anything to say about that, AJ?

**Anthony Towns**: I don't see why anyone would use OP_RETURN space instead of
witness space, so I just don't see the point of that.

**Mike Schmidt**: Okay, so leave this standardness and OP_RETURN restrictions in
place?

**Anthony Towns**: Yeah.

**Mike Schmidt**: All right, we can move on.  Quite a discussion there on our
first news item.

_Fee dilution in multiparty protocols_

The next news item here is fee dilution in multiparty protocols, and you've all
kicked off this discussion, or reignited this discussion, I guess I should say,
on the Bitcoin-Dev mailing list.  Do you want to provide an overview of your
post, Yuval, and the responses to it?

**Yuval Kogman**: Sure.  So basically, the instigating thing was the estimated
witness size message in the dual funding proposal.  It struck me a bit as being
odd that there is essentially an unenforceable message, like data's being
exchanged between clients, but it's purely informational, it doesn't affect what
they do in any material way.  And thinking in the context of all this ordinal
stuff happening, I was trying to think of a way of exploiting that and realized
you need a specialized protocol that constructs transactions that actually
respect ordinals' ordering, so that you don't accidentally send your brand-new
inscription to somebody else.

But if you're able to arrange for that, you have the option as the last signer
to either reveal your ordinal commitment with a large witness, or just sign
normally as everybody expects you to.  And if you're the very last signer and
you already have everybody else's signatures, then in some sense you can get
them to pay for your fees, even though you've agreed to a different fee
contribution.

It turns out that this has already been described.  I either forgot, or missed
this at the time, but Antoine Riard described exactly this mechanism as part of
the transaction attack; he called it the witness malleability.  And also I got
the description of the mechanism itself wrong, so it's not specific to taproot,
although the attack model that I was interested in, that's the only one in which
it makes sense, the only setting in which it makes sense.  I think my post is
actually not that great, but I really liked the discussion that came out of it.

Perhaps the most interesting thing was bringing up the taproot signing algorithm
and whether or not it should commit to the control block in full in the
signature, because right now there is a malleability potential, where if a
tapleaf appears multiple times in the taps, then you can control blocks that are
as long as you like without modifying the signature, which is kind of an
interesting malleation case.  I think that's a fair summary.

**Mike Schmidt**: Murch, I see your hand up.

**Mark Erhardt**: Yeah, I had two follow-up questions, because I wasn't sure
that I understood the discussion correctly.  One is, in the output script, you
have to commit to the input script in order to be able to satisfy the input
script, right.  Is the inscription not something that you would have to commit
to in advance in the output script before you can add it in the input script; I
thought that was the case?  So, given that as a user, I would never want to
participate in an address that I hadn't seen the whole script tree through, how
much of a danger is this whole thing in the first place?

**Yuval Kogman**: So, that's kind of what I was alluding to by saying I
described it incorrectly.  Really, the issue from my point of view, I was
assuming BIP322; and the way that BIP322 works, it only commits you to one path.
So, if there was an equivalent ownership proof proposal that forces the prover
to reveal the entire tree, then yes, this issue would be entirely addressed, you
just would avoid interacting with anything that is not fully revealed.  And if
you have a taproot output with a script path that contains a jpeg that you
definitely don't want to pay for, then you just never initiate a protocol with
such an ownership proof.

I was kind of incorrectly ascribing this potential for a malfeasance to
MAST-type construction themselves and it has nothing to do with that.  This is
what shesek pointed out, but it's not really about tapscript in this regard,
it's more about the kind of ownership proofs that you use for multiparty
protocols.  And I guess my tunnel vision kind of comes from the fact that
revealing your entire taproot tree is kind of bad for privacy.  So, in a
coinjoin setting, I'm not sure how much of good idea it is to -- if you have
interesting script and you also want the privacy that coinjoins might provide
you, revealing everything you could have used as a spend path kind of undermines
taproot's privacy model.

**Mark Erhardt**: Oh, I see, because when you construct a multiparty
transaction, you are committing to which output you're going to spend.  But in
this case, you may unilaterally own that output and you don't reveal the input
script yet to the other participants, so there might be multiple ways of
spending the output with different input scripts, and that could malleate the
final transaction that everybody is committing to?

**Yuval Kogman**: Exactly.

**Mark Erhardt**: Okay, yeah, that was what I was missing.  Thank you very much.

**Mike Schmidt**: And I guess that has two effects that we described in the
newsletter: one is, you're getting your other parties to that transaction to pay
your fees disproportionately; and then also, I guess related to that, is if
you're decreasing then the effective feerate, then you could potentially run
into slow confirmation times.

**Yuval Kogman**: So, the latter part is already fully captured, I think, by the
transaction pinning stuff.  The first part, I think, everybody was assuming up
until now the main reason you'd want to inflate the witness data is postpone
confirmation as much as possible, because presumably you have some sort of
offchain contract which is time sensitive.  I don't know of any way to mount
this attack on existing protocols, for various reasons, chief among them being
how do you even control where your ordinal ends up.  So, actually constructing
it in such a way where the adversary can benefit in the way that I described I
think is really contrived, but if you are able to do that, then yeah, you can
extract a positive payoff that only has to do with how much you end up directly
paying for block space, I do think is still kind of interesting.

_Tapscript signature malleability_

**Mike Schmidt**: Murch, Yuval mentioned the spinoff discussion that we noted in
the newsletter, which is the tapscript signature malleability, in that you could
have essentially copies of the same tapscript placed in different places of the
tree, which could be one issue in regards to the fee dilution multiparty
protocol concern.  Were you aware, Murch, that there was that tapscript
signature malleability?

**Mark Erhardt**: I was not.  But the way that we described it in the newsletter
with an output being owned by multiple parties together, I don't think that is
much of a concern, simply because before I create an address with someone, I
would always require the whole taptree to be revealed to me.  I would not
participate in an output where I only see part of the tree.  So specifically in
the context of a multiparty output, the concern that a leaf appears in multiple
places, I don't see the concern in practice.

Unilaterally owned outputs, as we discussed, with coinjoins for example, I now
see the point how that might be a problem with the inputs having multiple
scripts that can spend it and then you're using a different script than you
originally showed people, and thus changing the outcome of the feerate.  But
even then, I think if there's a coordinator that puts together the transaction
before it is published, funnily enough they could still use the original script
path, because the signature, if the same leaf appears twice in the tree, as long
as they know the original script path, they could still use the smaller one,
even if you provide the signature and witness stack of the bigger one later, as
long as you revealed it previously.

**Mike Schmidt**: AJ, I know that you have your ANYPREVOUT proposal, and it
looked like you picked up on some of this discussion and how would that PR that
you opened to address this issue work?

**Anthony Towns**: So, I haven't opened an issue, not a PR to this so far.  The
way ANYPREVOUT works, or is proposed to work, is when you do a tapscript and you
want to have a signature as part of it, you say CHECKSIG, then you have 32 bytes
of x-only pubkey and then you have the signature with whatever sighash on it.
With ANYPREVOUT, instead of having a 32 byte key, you have a 33 byte key and the
first byte is just a 1 to indicate ANYPREVOUT.  And then you can use pretty much
the exact same signatures as you could with the 32 byte x-only keys, but you can
also use the ANYPREVOUT sighashes.

So, one way we could address this shortcoming is having the ANYPREVOUT sighashes
that match the current sighashes we've got also commit to the full path to the
tapscript or the tapleaf, in which case you can't suddenly switch it around to
some other thing, like when you're observing the script, you can just see that
it's an APO pubkey and you know at that point that the sighash is going to
commit to everything and they're not going to be able to switch it around.  That
seems like a possible way of doing it, and there's been a little bit of
discussion on the issue as to exactly how to commit to that, whether to do just
the level or the full path, but I think we can wrap that up and have a go and
see how it works.

**Mike Schmidt**: All right.  We have a monthly segment that we have in this
newsletter, which is Changes to Services and Client Software, and as a brief
reminder for everybody, this is a monthly segment where we highlight different
libraries, or wallet software, or other software that is adopting new Bitcoin
technology, and so we like to highlight that here for users that are familiar
with those projects and to give a pat on the back to those projects for adopting
those different pieces of tech.

_Liana wallet adds multisig_

So, the first one we had this month is the Liana wallet adding multisig.  So we
actually covered their initial release last month in which they noted that they
did not have multisig support, that they were planning on it, and I guess in a
very quick turnaround, they've already released this 0.2 release which adds
multisig support using descriptors.  As a reminder, the Liana wallet is a wallet
that includes a degrading multisig, a fallback, and that's built into their
wallet.  An initial release had singlesig and now they support multisignature,
so that's pretty cool to see.  Murch?

**Mark Erhardt**: I think more importantly, as far as I know, Liana is the first
wallet working on miniscript support for descriptors, so Antoine Poinsot has
been pretty heavily involved in a review of miniscript, so they are very excited
about the miniscript capabilities of descriptors and being able to specify this
degrading multisig in the form of a miniscript descriptor.  That's the most
exciting thing to me about the Liana wallet, is the miniscript use.

**Mike Schmidt**: Yeah, they seem to be moving fast and on the cutting edge, so
round of applause for those guys.

_Sparrow wallet 1.7.2 released_

The next one we highlighted in the newsletter this week was Sparrow wallet, and
they have a 1.7.2 release which adds taproot support and also support for
BIP329, which is the ability to import and export labels, and that was actually
a recently assigned BIP as of the last few weeks; we covered that in Newsletter
#235, so you can import and export your labels using that format, and then
there's additional support for hardware signing devices.

**Mark Erhardt**: In fact, the author of Sparrow wallet is also the author of
BIP329.

_Bitcoinex library adds schnorr support_

**Mike Schmidt**: It's a wonder they got it done so quickly.  The folks at River
Financial have a library that they've been contributing to, called Bitcoinex,
and that's a library that added schnorr support recently, and I don't think
we've highlighted this library in the past, but it's a utility library for a
functional programming language, named Elixir, so I thought that was interesting
and their support for schnorr was a good reason to include it in the newsletter.
Murch, are you doing any functional programming using Elixir?

**Mark Erhardt**: I have never used Elixir, but I did enjoy using functional
programming languages at university.  The simulation for coin selection for my
master thesis was in Scala.

_Libwally 0.8.8 released_

**Mike Schmidt**: Oh, cool.  And then the last highlight for this segment was
libwally 0.8.8 being released, and that's a sort of primitives library for doing
Bitcoin stuff.  I believe that the Green wallet uses libwally under the covers,
and some other wallet libraries as well use that.  And they added tagged hash
support, additional sighash support, including ANYPREVOUT support.  I suppose
that's for potential use on the Liquid sidechain, and additional miniscript
descriptor and PSBT functions to that library.

**Anthony Towns**: I think the APO stuff's because c-lightning, CLN, uses
libwally these days, and that's what instagibbs is working on for L2.

**Mike Schmidt**: Okay, cool.

**Mark Erhardt**: LN symmetry!

_BitcoinSearch.xyz_

**Mike Schmidt**: We have an Optech Recommends segment this week, and this is
something that was published recently, a search engine for Bitcoin technical
content.  It's called BitcoinSearch.xyz, and it's focused on Bitcoin, it's
focused on technical documentation and discussions, and it's a nice way to pull
up resources like the Optech Newsletter and our topics, as well as other
resources.  I started playing with it and I got some great results quickly.
Murch, I'm not sure if you've had a chance to play with that yet?

**Mark Erhardt**: Yeah, I've played around a little bit with it.  I think that
it will become a staple for me to find stuff for show notes linking to Stack
Exchange answers and some other stuff.  So, as far as I understand currently, we
pull in -- so, this is a project spearheaded by one of my colleagues at
Chaincode.  We pull in a mailing list, Bitcoin-Dev mailing list and
Lightning-Dev mailing list, Stack Exchange, the Bitcoin Transcript page that is
also spearheaded by Jonas.  There's the Bitcoin Talk Technical Forum, I think,
and the Optech website.

I'm not sure if there's other content, but yeah, if you want to cut through all
of the news articles and blogposts that pop up when you search for Bitcoin
topics, especially technical topics, this will give you a pretty good signal, I
think.  And, yeah, if you have ideas how to improve it, it's also open source of
course.

**Mike Schmidt**: I find myself often using Google and then adding the modifier
at the end, site:bitcoinops.org.  So, I think instead of doing that, I could add
a little shortcut to use this search engine and just type my query in there, so
looking forward to using this more.

_Core Lightning 23.02rc2_

Next segment of the newsletter is Releases and Release Candidates, and the first
one that we noted here is the Core Lightning 23.02rc2 release candidate for a
new maintenance version of this popular LN implementation.  Alex or Vivek, I'm
not sure if you guys have comments on this particular release, if there's things
notable that folks should be aware of.

**Alex Myers**: Yeah, first of all, thanks for having me, and also that search
engine I think is going to be really useful.  Looking through pretty much
anything we do on Lightning, there's a mailing list thread that goes back years.
So, first of all, this new release is the 23.02 release, which we moved on the
last release from semantic versioning to a date-based system.  So, this is just
2023 February release.  And being in February, it's generally kind of a lighter
release than other points in the year, because we've got all the holidays and
everything.  We tried for a three-month release cycle and this one was supposed
to be a lighter release than normal, which is nice for me because I haven't done
Release Captain duties on Core Lightning yet, this is my first.  But it turned
out that we actually have quite a lot of pretty cool features that are
integrated in this new release.

So, one of them that I'm pretty excited about is peer storage, which is Aditya
Sharma, that's his baby.  But this is basically 64 kB of blob storage with your
peer that you encrypt, hand it to your peer, and on reconnect, they just feed it
back to you.  It's pretty simple on the surface, it's very small, so pretty
lightweight for your peers to store, but what this allows you to do is integrate
it with your static channel backup and now all of a sudden, when you reconnect
with your peer, you basically get all this redundancy of having your static
channel backup available.

It's probably to be flushed out a little bit more so that it's just a seamless
user experience and it's still an experimental feature right now, so you've got
to set a specific flag to turn it on, but I think this could really make things
a lot more user-friendly, especially for newer players that are just setting up
a small node in the future.  They really won't have to worry about the backup
case nearly as much potentially.

Then, another cool feature that Rusty has been working on is the SQL plugin.
So, this allows you to run a custom query on your database as an RPC.  I think
this will be really useful if you're trying to access your node remotely from a
client RTL.  We've actually got this new client, clams.tech, that connects over
the Lightning Network itself using Commando, and any time you're doing something
like this, you don't want an RPC call that has a really verbose output that
you've got to filter through thousands of lines; it's really nice if you can do
that all on the node side and just return the specific query that you're really
interested in.  So, yeah, that will be really nice for developers building front
ends, I think.

Kind of along the same vein, we had this 10,000 channels project that Rusty did,
where we were just looking at some of the pain points for larger nodes, again
looking at these RPC calls that can get quite lengthy when there's a lot of
channels involved.  So, there were several performance enhancements there that I
think some of our users will appreciate.

I would say finally, it's the spec updates.  As you know, the Lightning vaults
and spec is sort of a moving target.  Currently, we've got the dual funding
efforts that Lisa, niftynei, has been working on, and does also touch a lot of
the splicing work.  But there's definite interest in the other implementations
on dual funding.  So, she's been working with t-bast at Eclair, and following
that feedback, there were some updates to the dual funding spec, and those have
all been incorporated into this latest release.  So, really hopeful that we can
have interoperability soon with Eclair.

Similarly, offers has some interoperability updates also, and yeah, I think
that's about it.

**Mike Schmidt**: So, I'm curious, what is the role of Release Captain on this
Core Lightning project?

**Alex Myers**: Oh absolutely, yeah, I should have given some background.  So,
when it comes time for release, we have a feature freeze.  So, we tag all of the
PRs that we really want to make sure they're going to be headline feature for
the current release, or major bug fixes that we want to make sure to incorporate
before the release, so just going through that, tagging them all, making sure
that there's an owner who is responsible for that, making sure that we get
reviews on all of the PRs that we're waiting for, and really it's just like a
project management role.  So, if we're going to merge conflicts, make sure
there's a sensible order for which get priority, that sort of thing.  But yeah,
that's basically it.

I work on kind of narrow aspects of Core Lightning, so mostly I focus on gossip
and plugin sort of things.  But being Release Captain, I've had to review an
awful lot of PRs, so I'm broadening my horizons there.  But yeah, you get to see
just all sorts of different initiatives, I guess, and various parts of the
codebase, so it's kind of fun.

**Mike Schmidt**: Cool, Alex, thanks for giving us a little glimpse behind the
curtain there, and we'll jump to some of these more PR --

**Vivek Kasarabada**: Alex has an official hat, you should tell them the story
about that too, Alex!

**Alex Myers**: Yeah, I don't even know, I've got this boat captain's hat.  It
gets mailed around to whoever is the Release Captain, so Lisa dropped it in the
mail to me, and I guess it will go to Shahana Farooqui as soon as I'm done with
this one.  But yeah, you've got to wear it in the meetings!

**Mike Schmidt**: Nice!  We'll jump back to some of the Core Lightning PRs
shortly.  Let's wrap up the Release Candidate and Releases section.

_BTCPay Server 1.7.11_

BTCPay Server 1.7.11.  The last release we covered in the newsletter was 1.7.1,
so there wasn't anything notable for each one of the releases in between there,
but we kind of grouped all that into this update.  There's a bunch of bug fixes
and general improvements, and I think the big thing that we noted was the
ability to migrate your BTCPay Server database from MySQL to SQLite, and then
cross-site scripting vulnerability that was fixed.  Murch, was there anything
from those BTCPay Server releases that was notable to you?

**Mark Erhardt**: To be honest, I don't follow that project too closely, because
I don't run an instance, but BTCPay Server is interesting in that they are very
responsive in their releases.  Sometimes they have multiple releases per week,
so this is maybe just to explain why we don't cover every single release of
theirs.  So, the 1.7.1 release was end of November and since then, they've had
11 more releases, right?  So last week, for example, they had three releases.

I was just scrolling a little bit through their release page, but it's mostly
all smaller things.  Occasionally there's a big release, but yeah, anyone that
is running a BTCPay Server or that runs one of the integrators should check
because they leave notes for specific user groups on their releases, like here's
for example on 1.7.4, there's a note for the integrators, for the people that
work on RaspiBlitz and Umbrel.  Anyway, those people that directly work with the
project should be reading all of the release notes definitely.

_BDK 0.27.0_

**Mike Schmidt**: The last release that we noted was a maintenance release for
BDK, and that's release 0.27.0, and after looking through the release notes, it
looks like there's a bunch of dependencies that have been bumped and I didn't
really see anything too notable for our audience.  Murch, I'm not sure if you
saw anything else notable?

**Mark Erhardt**: Sorry, I did not.

**Mike Schmidt**: All right, Notable Code and Documentation Changes.

_Core Lightning #5361_

Alex, we'll bring you back in for this.  I think you had already talked about
peer storage backups as a feature, so maybe there's not much more to say on
that.  I'm curious, as a node operator myself, why would I want to store my
backups for them; am I just being nice, or are there other reasons for that?

**Alex Myers**: No, you're just being nice.  So, I guess it depends on how many
peers you've got but in this day and age, having a small 64 kB blob of data
doesn't seem to be too burdensome.  I know Rusty's got some thoughts on this,
where now that you've got a node with these peers and it's going to be online
24/7 anyway, this could actually be seen as sort of a service you could provide.
So, I think he's interested in making this part of the spec where you could
provide data storage as a service and charge a few sats just to store whatever
blob another node is interested in stashing with you.  Maybe we ought to let
Murch chime in.

**Mark Erhardt**: I think there might be a reason for how it's in your
self-interest to store a little data for your peers, because if your peer
actually lost their state, the only thing that they can do is ask for their
channel to be closed, and closing a channel is a burden to both channel
partners.  So, if you can enable them to recover their state, and it's pretty
safe to do so in this manner because they themselves stored the package with you
that they signed and encrypted to themselves, so they know that whatever you
give them at least is accurate, your counterparty might give you an old blob,
but they definitely give you something that you stored with them for yourself,
because you signed it and encrypted it to yourself.

So, you sort of get into a fun game theory where you can just occasionally
request that, or even on every connection, and if they ever give you the wrong
one, you know that they're malicious.  But that way, they would never be able to
tell when you actually want to get the data because you need it, because you
always ask for it.  And, yeah, 64 kB is not really that much data today.  I
think it could be in your interest to do this for your peers, because you have
already a contract going with them, you already have a relationship with them
and you actually, if you're not malicious, want to help them out.

**Alex Myers**: Yeah, I absolutely agree on both counts.  It is in the node
operator's interest, and I've also thought just a little about the game theory
and just like you say, the way this protocol works is on every connection,
that's the first thing that you transmit is, "Hey, here's your blob".  So, you
don't know if that's actually needed by your peer or not, and the existing
recovery method right now goes along the lines of, you reach out to your peer
and say, "Help, please force close my channel", and then they know exactly what
sort of trouble you're in.  That can certainly be gamed if they have enough
information and are willing to take that risk.

With the static channel backups, you never know if the peer needs is or not.
And just like you say, every time you reconnect you're given it, so you can
absolutely tell if your peer's being a reliable backup partner there.  And
furthermore, I think it will be really interesting recovering a node where
you've just catastrophically lost everything, you've got a seed and let's say
maybe you have your seed phrase, so some of your onchain funds, and you randomly
connect to a peer and they say, "Oh, I noticed that here's your blob that you
backed up with me", and you say, "Oh, I didn't know I had a channel with you.
But look, I can inspect the contents of the static channel backup and it turns
out I've got dozens of channels".  So now, all of a sudden, he can seamlessly
recover.  I think that would be the dream, right?

**Mike Schmidt**: Is there a standardization for this yet?  I know that it's not
supported by other implementations, but is this something that will have
something?

**Alex Myers**: Yeah, there is ongoing discussion, I believe.  I think the spec
needs to be cleaned up a bit, but I know in the mailing list, this has been
discussed in the past, the next step.  So, this is just a completely
experimental feature for Core Lighting in this release; it's an optional feature
bit, so it's definitely not anything that other nodes will expect you to have.
But yeah, if it all looks good, this will definitely inform the spec going
forward and hopefully can be integrated into the BOLTs.

**Mark Erhardt**: I was also just reminded of Sergi's work on watchtowers, where
we talked a lot with Sergi last month, we being Chaincode, and he had also
specced out the watchtower as being able to store arbitrary blobs of data, and
I'm wondering whether some of the work that he's done to specify how watchtowers
should work might apply to this static channel backup mechanism, because it
sounds very similar to me.

**Alex Myers**: Yeah, I don't know, but that sounds awesome.  And, yeah, part of
the whole recovery story is ideally you'd like to know at least one node, one
watchtower, one source where you could retrieve your static channel backup blob
if everything else is lost.  That's really interesting, I'll have to look into
that.

_Core Lightning #5670 and #5956_

**Mike Schmidt**: Alex, you talked a little bit about dual funding, which is the
next set of PRs here, #5670 and #5956, to Core Lightning.  Is there anything you
wanted to add on that?

**Alex Myers**: Not really, just that I think dual funding is amazing.  You've
basically got inputs coming from both sides, you're doing like a mini coinjoin,
so you're already breaking some heuristics, you're creating balanced channels
and furthermore, all of this work gets leaned on heavily by the splicing work
that Dusty is doing.  I'm really excited to see this progress and I don't know
all the details of it, but I hear that there was some really good feedback from
Eclair that came out of this, so I think the spec will be in a better place
going forward and maybe we'll have full interoperability pretty soon.

**Mike Schmidt**: Awesome.

**Vivek**: Another cool note, I think, is that upgradewallet RPC are moving from
the P2SH-wrapped to native segwit outputs, so Murch is a lot happier now!

**Mike Schmidt**: Yuval, you have a question or comment?

**Yuval Kogman**: Yeah, I just wanted to mention that the thing about what I
wrote up on the estimated witness size message, my understanding is that due to
this collaboration with t-bast and his implementation, this was since removed
from the proposal, so this somewhat dubious message that inspired that attack
model.  Yeah, it's cool to see parity between implementations instigating a
re-evaluation of the protocol design questions.  I thought that was cool.

**Alex Myers**: Yeah, absolutely.  I love how just the spec process in general
works with, it doesn't get ratified until a second implementation goes through
all the pain points and these issues arise.

_Core Lightning #5697_

**Mike Schmidt**: Alex, Core Lightning #5697 adds a signinvoice RPC that will
sign a BOLT11 invoice.  What's going on there?

**Alex Myers**: Okay, so I'm not even sure what exactly this will enable or what
the impetus was.  It sounds pretty interesting.  It's a little bit risky that
you're signing without the preimage, but I think maybe there's an LNbits feature
that requires the utility, or at least it sounds like Fedimint would be able to
get some utility out of this call.

Basically, you're signing an invoice without having generated the preimage from
Core Lightning.  So, any time you go to accept an incoming payment, you would
call a plugin hook and retrieve that preimage externally.  So, I imagine you
would exchange this for some other sort of payment app in the case of Fedimint
or LNbits, or maybe you could have other users that are all using the same node,
that sort of thing.  It's kind of interesting.

I think why this wasn't a feature before is that it does open up a bit of a
security hole when you don't actually know the preimage, so you could
potentially collude to intercept a payment.  So, this might make more sense in
maybe a PTLC world, but I think it will enable some neat things to be built on
top of it, so I'm excited to see how it gets used.

_Core Lightning #5960_

**Mike Schmidt**: And then the last Core Lightning PR for this week's newsletter
was #5960 adding a security policy, which seems like a good idea and
straightforward.  You want to comment on that, Alex; I see you're on the PGP key
list?

**Alex Myers**: Sure.  I think it was just a nice method to report anything
critical that crops up in a secure manner.  I know that there was at least one
person who did a little bit of fuzz testing and did notify Rusty of some of the
issues that came out of that, and I think it was just time that having a
security policy and being able to report those bugs in a secure way is probably
the right thing to do.

**Mark Erhardt**: Yeah, I mean we saw a few security issues, or bug reports,
that could have used a security policy end of last year for other
implementations.  So, I think that all of the Lightning projects by now are used
in production by enough people that this is about time!  Also, a comment, we'll
be taking comments and questions from the general audience at the end of the
newsletter, so if you want to comment on anything we've discussed or have a
question to one of those things in a few minutes when we've done the last few
items, we'll be able to take your comment.

_LND #7171_

**Mike Schmidt**: LND #7171 upgrading the signrpc RPC to support the latest
draft BIP for MuSig2.  So, I think because MuSig2 has gone through a couple of
different iterations, there's somewhat different versions of MuSig2 that LND
supports and so now they're requiring the version of MuSig2 that you're using
when you're calling this RPC to actually specify that protocol version number so
that you get the correct protocol, and some of these changes have been made to
MuSig2 regarding security issues that they found while trying to get that to
1.0.  Murch, any thoughts on that?

**Mark Erhardt**: Yeah, I actually talked to one of the authors of the MuSig2
BIP recently.  I'm just wondering because there was this mailing list post in
October that they had found another security issue, and then in November that
they had fixed it.  So, the status of MuSig2 last I heard was that it's very
close, it's coming soon, so we only have to wait 2 more weeks to 18 months.

**Mike Schmidt**: At first I thought that you were real on the 2 weeks, but
yeah, who knows what else might be found.

_LDK #2002_

Our LDK PR which is next is actually incorrect.  Val actually okayed the change;
I opened up a PR to the newsletter.  It's actually instead of #2022, it's
actually #2002 is the PR, so if you link off to that PR from the newsletter now,
it's actually the wrong PR.  But this PR adds support for automatically
resending spontaneous payments, keysend payments, that don't initially succeed.
Go ahead, Murch.

**Mark Erhardt**: One follow-up on the MuSig, so my understanding is that it's
actually really close to coming out but as we know that things can just take
time, if something is still found, they might go back to fixing that.  So, yeah,
I think that MuSig2 is usable as it is right now already.  We know that some
people are already implementing support for it that are using some bigger wallet
services that have had MuSig support for a long time.  Yeah, I don't want to
predict any timeline, but it's actually really close.

**Mike Schmidt**: It's happening!

_BTCPay Server #4600_

The last PR for this week's newsletter if BTCPay Server #4600 and that updates
the coin selection for its payjoin implementation to avoid unnecessary inputs.
Murch, you're the coin selection guru, so do you want to talk about unnecessary
inputs, coin selection and how it interplays with payjoin?

**Mark Erhardt**: So, the unnecessary input heuristic, it is a method of telling
which one is the likely change output, because if all inputs are bigger than one
of the outputs on the transaction, then it doesn't make sense to have included
more than one of the inputs, and the other one would have been unnecessary,
unless the bigger output on the transaction is the payment.

So, the idea here is this is a heuristic use by chain analytics companies to
guess or to determine one of the outputs to be more likely to go back to the
sender's wallet as change output, and so a payjoin transaction is a coinjoin
transaction where the receiver of a transaction is providing an input to the
transaction and thus the output that was going to the receiver is increased by
the amount of the input that the receiver provided.  So here, it looks like
BTCPay Server thought more about how they construct these payjoin transactions
so that there is no fingerprint that reveals which one is the more likely change
one.

**Mike Schmidt**: All right, well that wraps up the newsletter coverage for this
week.  I don't see any speaker requests, so I guess we could thank our special
guests for joining us, my co-host -- oh, go ahead, Murch.

**Mark Erhardt**: I remembered that I actually did have an announcement.  So, we
had Greg Sanders on the Chaincode podcast recently to talk about LN symmetry and
ephemeral anchors and that episode is out, so a lot of the topics that we
touched on today are related to that; and if you want to hear directly from the
people working on it, you could perhaps listen to the Chaincode podcast episode.

**Mike Schmidt**: Excellent, good plug.  I see Greg in here, so howdy, Greg!
Thanks to my co-host, Murch, for joining, AJ, Yuval, Alex, Vivek and Rodolfo for
helping to contribute to the discussion.

**Mark Erhardt**: Yeah, thanks for a great discussion today, and hear you all
next week.

**Mike Schmidt**: Cheers.

**Alex Myers:** Thanks for having us.

{% include references.md %}
