---
title: 'Bitcoin Optech Newsletter #227 Recap Podcast'
permalink: /en/podcast/2022/11/23/
reference: /en/newsletters/2022/11/23/
name: 2022-11-23-recap
slug: 2022-11-23-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt discuss [Newsletter #227]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-7-23/344148614-44100-2-95641937bd8db.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: We've had a bout of heavy news for the last month on these
recaps, and I think this is the counterbalance to that.  So, we have no
significant news this week from the mailing list, but we do have our monthly
Stack Exchange segment, where we troll through questions and answers from the
Bitcoin Stack Exchange and put things that are somewhat interesting or
educational for the audience into the segment this month.

_Did the P2SH BIP-0016 make some Bitcoin unspendable?_

The first one is an interesting one because, well, I'll jump into it, then I'll
get into some of the nuance, but the question is, "Did the P2SH BIP16 make some
Bitcoin unspendable?"  And the user who answered this, bca-0353f40e, noted six
outputs that existed before the script format was activated, and one of those
outputs was spent before the activation of P2SH.  And the question is, are those
remaining five UTXOs still spendable or not?  And at first, I thought that the
answer was that they were spendable because I was looking and reading the BIP,
and there was a section saying that it was essentially activated after a certain
time.  I think it was timestamp and not block height, but there was some
activation based on timestamp and that the rules didn't apply to earlier --

**Mark Erhardt**: Earlier transactions.

**Mike Schmidt**: Yeah, but it turns out, at least if I'm understanding
correctly now, that actually that BIP, unless I'm misunderstanding, is incorrect
and the code actually implemented activation that applied to everything except
for one exception block, which was the exception block that contained the P2SH
transaction that was spent before activation, or before that format was
activated.  Have you been following along with that in my last minute updates to
this particular Stack Exchange entry in the newsletter?

**Mark Erhardt**: I have not.  I read over it once but I looked into this myself
now because I was curious, and what I understand now is the rules were
originally implemented in the BIP that they would only apply after activation.
So, all the transactions that happened before activation would have to be
validated per the old rules, and all the transactions after activation have to
pass the new rules.  So, any UTXOs that existed at that time would not be
exempt.  And so, originally when I read the BIP, I thought that they had
explicitly exempted all the UTXOs that were created before activation, and would
make the UTXOs' spending be validated per the old rules, but that's not what was
done.  It was explicitly applied to the transactions.  So yes, they did make six
UTXOs that already existed at that time unspendable.

**Mike Schmidt**: Okay.

**Mark Erhardt**: Oh, and the second part as well.  The second part is, in 2018,
the change was backported to the genesis block because there's only one single
exception where one transaction used this pattern before BIP16 was activated.
So, they ported the rules back to count for all transactions since genesis
block, and hardcoded this single transaction as an exception that is validated
differently.  So, that simplifies, of course, transaction verification because
you don't have to check whether a transaction happened after a specific block,
you only have to check whether it's this specific transaction and validate that
single transaction differently.

**Mike Schmidt**: So, how do you feel about breaking those UTXOs?

**Mark Erhardt**: I mean, it could have been done a little more benignly by
applying it to the UTXOs instead of the transactions, so that any UTXOs created
before activation would fall under the old rules.  But let's be honest, 0.044
Bitcoin in what was it, 2012?  In 2012, that was like 40 cents or so, so I
understand why there was not extra effort done to take care of that.

**Mike Schmidt**: Are there other examples of making UTXOs unspendable that come
to mind in a similar way; obviously you can burn your own coins, or whatever,
but something that was a change to the software protocol?

**Mark Erhardt**: I mean, I guess I think with segwit activation, if there had
been any transactions that followed the new magic pattern of having just a zero
-- actually, I haven't looked into this.  I think that it could have potentially
happened with segwit activation, wrapped segwit specifically, but I believe that
the pattern would have been nonstandard before already.  So, it's highly
unlikely that somebody would fit exactly that pattern.  I'd have to look into
it!

**Mike Schmidt**: Instagibbs, I think, has something to say.

**Greg Sanders**: Yeah, so I was looking at the history of standardness a few
weeks ago, and I'm wondering how were these outputs even made, because prior to
P2SH, or what was supposed to be OP_EVAL, which was swapped out at the last
second, if I remember correctly, no outputs were standard except for very small
types, right?  So it was like P2PK, P2PKH, and I think naked multisig up to
2-of-3, or something; everything else was non-standard.  So I was just
wondering, does anyone know how these were made?

**Mark Erhardt**: I mean, it was probably also a lot easier to mine at home, so
people might have just created them, included them in their own blocks.

**Greg Sanders**: Yeah, I'd be interested to double-check.  Maybe I'll
double-check that, but it could be people's self-mining these patterns, I guess.

**Mark Erhardt**: I mean, you can still create non-standard scriptPubKeys, even
without addresses.  Well, that's more of a question later in our segment.  But
yeah, you'd have to either convince a miner to include it.  I think maybe some
-- was there even mining pools yet in 2012?  I don't think there -- there may
have been just at the time when the first few mining pools came up.

**Mike Schmidt**: I was looking at the block heights of these outputs too, and
it seems like it's relatively close to the activation.  So, it was likely some
developer who was aware that that was going to be the pattern messing around,
would be my thought.

**Mark Erhardt**: It's 38,000 blocks, right?  No, sorry, 3,800.  Yeah, that's
only three-and-a-half-weeks, you're right.

**Mike Schmidt**: Well, that's an interesting one, I thought.  Anything else,
Murch, you'd like to say about the Stack Exchange question, other than rejecting
my edits that I attempted to make on it?

**Mark Erhardt**: That wasn't me!

**Mike Schmidt**: I was incorrect!  I thought I was fixing something because the
BIP didn't match, but I guess the BIP doesn't match reality.

**Mark Erhardt**: Yeah, I think that was the author of the answer themselves.

_What software was used to make P2PK transactions?_

**Mike Schmidt**: All right, the next question from the Stack Exchange was,
"What software was used to make P2PK transactions?"  And this was definitely
before my time, so I don't have any firsthand experience of that, but Pieter
Wuille pointed out that those outputs were created from the original Bitcoin
software, early versions of the Bitcoin software, regarding the coinbase
transactions.  And there was also this notion of paying to IP address, where you
would plug in an IP address that would respond with a public key, and you would
pay to that public key after getting that information back from an IP address
query asking for that public key.  Murch, are you familiar with any of this
ancient history?

**Mark Erhardt**: Only by tale and lore, honestly.  So, there never was an
address format for P2PK.  P2PKH was sort of the introduction of addresses for
P2PK, and that still worked for a long time as the coinbase output because when
you write your own transaction, of course, you know the scriptPubKey already,
you can just write the scriptPubKey in, so there is no need to transfer it to
another user in the network.  But transferring a pubkey to another user, there
never were any rails for that, except this abominable idea that you ping a node
at a specific IP address and ask them for where to pay, "Hey, give me a
scriptPubKey", or actually, "Just give me a pubkey".  So that's, of course,
completely unsafe because a man-in-the-middle attacker could just intercept that
call, especially since none of that was encrypted, and go like, "Hey, I'm the
recipient, just pay to this pubkey" and return that.  That was, from what I
read, removed already in 2010.  So, ancient times.

**Mike Schmidt**: I think people are familiar with putting in an address and
sending, and that being the "destination" of the bitcoins.  So during these paid
to public keys, what would be done if, say, you and I are communicating out of
band and you provide me your public key; how would I go about sending to that?
Do I craft the script myself there, or how would that have worked back then?

**Mark Erhardt**: I guess if you gave the pubkey out of band, you would have
been able to just use send and the pubkey.  That should have worked, yeah.  But
well, there was no checksum, there was no nothing to make sure that everything
went right in the transfer.

**Mike Schmidt**: Satoshi Nakamoto is joining us.

**Mark Erhardt**: That sounds like fake news to me!

**Mark Erhardt**: Maybe Satoshi Nakamoto wants to comment on the original
Bitcoin software.  Satoshi Nakamoto, do you have a comment on some of the Stack
Exchange items we're talking about?

**Satoshi Nakamoto: **Yeah, I just wanted to say that if you really dig into
Bitcoin's early, early code, it's script kiddie stuff.  So, where it really
started was, how do you make a coin; what the fuck is a coin online?  And it
came to me that it would be already there because the casinos were using like
chips.  So, that's where the base code started in that direction.

**Mike Schmidt**: Thanks Satoshi.  Murch, anything else on early P2PK
transactions?

**Mark Erhardt**: Well, maybe let's just mention that P2TR now is basically also
a form of P2PK, because in P2TR, the address encodes a witness program that is
de facto just a public key, tweaked with a script tree, so we're making the full
circle, we're back to just paying for public keys.

_Why are both txid and wtxid sent to peers?_

**Mike Schmidt**: Yeah, exactly.  Next question from the Stack Exchange was,
"Why are both txid and wtxid identifiers sent to peers?"  And this is also
answered by sipa, who references BIP339, and essentially explains that passing
around wtxids is better due to malleability and other reasons, but due to
backwards compatibility, we still need to keep track of what the txids are in
case we have a peer that doesn't support wtxids.

**Mark Erhardt**: So the problem here is, of course, that the txid is only
calculated from the non-witness data in the transaction, and if you want to
cover the witness data too, you need to use the wtxid.  So, when you announce a
transaction to peers with the txid, if the node accepts an announcement via
txid, a malicious peer could use that to give them a fake witness, and you'd be
unable to see whether or not they gave you the actual transaction or just a
malleated transaction because the witness data is not covered by the txid.  So,
you'd have to download the same transaction again from other people announcing
it, and you might actually even be given a broken transaction multiple times if
you are only asking for the txid.

So, what we wanted was to be able to request transactions per wtxid, but since
that is a change in the protocol behavior, we only had that behavior in newer
clients, and that's what BIP339 is about, how to announce that you would like to
communicate about transactions per wtxid and how to request them, and that only
nodes that are capable of doing so will actually request them that way and trade
them.

**Mike Schmidt**: So, there was this period of time then where segwit was
activated, but the way that you were requesting transactions at the P2P layer
was still txid and not wtxid, until this BIP339?

**Mark Erhardt**: Yeah, actually for almost three years, I think.

**Mike Schmidt**: Cool.  Anything else on that, Murch?

**Mark Erhardt**: I think that covers it.

_How do I create a taproot multisig address?_

**Mike Schmidt**: Next Stack Exchange question is, "How do I create a taproot
multisig address?"  And so, the person asking this question saw the 998-of-999
tapscript multisig transaction and wanted to mess around and create their own
multisig and do something more than the previous max key limit, that was due to
some, I think, script limitations that you could do, and wanted to do this in
taproot and was wondering how to do that.  And so sipa again answers, and he
explains that you can do this now.  Previously, you were doing createmultisig
and addmultisigaddress to create a non-taproot multisig, and that does not
support these new wallets and only supports legacy wallets.  And so, as of 24.0,
you can use descriptors and newer RPCs like deriveaddresses and
importdescriptors.  Then there's this new descriptor, multi_a, which maybe,
Murch, you can enlighten us on.  And then you can create a taproot-compatible
multisig script using a combination of those RPCs in that descriptor.

**Mark Erhardt**: I want to correct something quickly.  Descriptor wallets have
been in 0.21 and the taproot descriptor exists since 22.0, but now in 24.0 the
taproot descriptor is capable of using this multi_a.  So, descriptor wallets are
not quite as new as it just sounded.  Regarding the multi_a, I'm not 100% sure,
but I think that it will create a single leaf with an OP_CHECKSIGADD
construction, but it might be even smarter and actually build a tree.  Although
for 21 out of 210, I'm pretty sure that the OP_CHECKSIGADD construction would be
the cheapest.

**Mike Schmidt**: Yeah, you're right.  If I was inferring that the descriptor
support was new, that's not true.  It's the multi_a descriptor support that's
newer and enables the construction of these taproot-compatible multisig scripts.
And yes, I don't know behind the scenes whether multi_a is creating a giant tree
or if it's doing the CHECKSIGADD exercise.

**Mark Erhardt**: So basically, I'm just going to roll with that it must be an
OP_CHECKSIG leaf.  And what I would expect here to happen is that you basically
just get this taptree with a single leave that has the 210 public keys in the
script and then requires 21 signatures from those.

_Is it possible to skip Initial Block Download (IBD) on pruned node?_

**Mike Schmidt**: Last question from the Stack Exchange is about the ability to
skip IBD on a pruned node.  And this user who's asking this question, Carlos, I
think maybe misunderstood what the assumevalid option is.  It appears, based on
the sample code that they provided and the question that they were trying to do,
an assumevalid for a somewhat recent block and was assuming that assumevalid was
just going to not require any IBD, based on whatever block he put into that
option, and was attempting to skip the IBD that way.  But that is not what
assumevalid is, although there's a similarly named effort underway, called
assumeutxo, in which you can download the UTXO set and validate it against a
hash that would be in the Bitcoin Core source code, and you'd get a similar
effect as to what Carlos was thinking that assumevalid was doing.

So sipa again, I think he answered four of these this week, points out that
project.  And that's not something that's available currently, but that's
something that's being worked on.  Murch, assumeutxo, assume valid, IBD?

**Mark Erhardt**: Yeah, so the IBD, or the synchronization to catch up with the
current chain tip, is a point of friction when people first start using Bitcoin.
And depending on what hardware you have available, that can take a few hours to
two days to perform, so there's a few cases in which you might want to skip
that.  So for example, if you have already performed a full synchronization
yourself and you want to bring up a second node, you might trust your first node
to have done the work correctly and want to transfer the state from that first
node to the second node.  Or, a little more dangerously, you might trust another
person to give you a copy of their state and import it.  So, for a while, there
were ways to do that on P2P-sharing networks like BitTorrent and bootstrap a
node more quickly that way.

The big danger with that is, if somebody gives you a fake UTXO set that has
additional UTXOs, they could, for example, give you a transaction that spends
these UTXOs or even a block that confirms the transaction that spends such
UTXOs, and you would be alone on a chain tip that accepts this block, while
everybody else would reject it because they don't know the UTXO.  Or even worse,
they could just remove some of the UTXOs and once any of them get spent, you
reject the actual blockchain and are also isolated from the network.  So, this
opens up nodes to a network-splitting attack, or to basically put them into a
position where it's easier to cyber- or eclipse-attack them, and then I think
there's just this big ethos in Bitcoin, where we expect every full node to have
done their own full validation, because that's where the full comes in; that's
for a fully validating node, right?  So, if you just trust someone to give you a
set of UTXOs, that's sort of dangerous.

I think this is a little better when it's just hardcoded in a release to say
like the state of three months before the release, and you're already trusting
the developers not to have put in any malicious software into the release, so
you might choose to also trust them that they have correctly compiled the UTXO
set at a time three months before the release, and only need to catch up the
last three months.  But since we want to minimize trust, we actually would have
implemented this in a way where even if you do this jumpstart, and you start
from the point three months ago and build the remaining UTXO set from there, we
would, in the background, have the node do a full synchronization from the
genesis block, and then validate over time that it actually started out at the
correct point.  And if not, probably either warn the user or at least overwrite
the old state with the actual correct state.

So, this project's been underway for a few years already.  I think that it is a
pretty big lift, and this might not have been dealt the warmest reception
because some people are worried that it undermines this ethos of full validation
to some degree.  Yeah, sorry, I rambled a bit.

**Mike Schmidt**: No, that's good, that's good background.  I think the only
thing that maybe you could elaborate on is, so what does assumevalid do then?
You kind of got into the background and the motivation of assumeutxo and
bootstrapping a second node based on the trust and source, but so what should we
be using assumevalid for then?

**Mark Erhardt**: Oh yeah, good point.  So assumevalid is an optimization for
the IBD that allows you to skip script validation up to a certain point.
Essentially, it makes the assumption that if a certain block header is part of
your best chain, then up to this block, the scripts are correct, otherwise the
blocks wouldn't have been chained together in the best chain, because it would
have been invalid.  But you still parse the whole blockchain and you build your
own UTXO set and you update it with each block.  So, you end up having done a
full validation of where all the money was created and how it was transformed
over the years, but you don't check every single script; and that, I think,
speeds up synchronization by about, I'd say probably 30%, 40% or so, from the
top of my head.  Yeah, so it only skips script validation.

The height and the block up to which this is done is updated with each release
and set to, I don't know, like a month before the release.  And so you'll be a
bit faster to validate all the blocks up to that point, but then do full script
validation from that point on.  You will also do full script validation if the
designated header is not part of your best chain, or if you turn it off.

**Mike Schmidt**: Yeah, I was going to point that out as well.  Actually, it's
part of the release process to update that variable in the source code.  It's
part of the checklist to getting a release out.  Thanks for the background
there, Murch.  That's it for the Stack Exchange.  Moving on to the Releases and
release candidates.

_LND 0.15.5-beta.rc2_

LND 0.15.5-beta.rc2.  Wow, that's a mouthful.  That's just a maintenance release
for LND with some minor bug fixes.  I don't think we need to get into any of
that.  Murch, any comments there?

**Mark Erhardt**: I think the only interesting one was that it uses P2TR on sent
coins now for the change outputs.  So, if you send money out of your LND node on
chain, it will now create P2TR change outputs.

**Mike Schmidt**: Oh, nice, okay.

**Mark Erhardt**: I think the other ones were just bug fixes, as far as I could
see.

**Mike Schmidt**: Okay, I just assumed it was bug fixes, so I didn't even drill
into it.  Thanks for unearthing that for us.

_Core Lightning 22.11rc2_

Core Lightning 22.11rc2, a release candidate for Core Lightning (CLN), and
they've changed their version numbering scheme to be consistent with the
semantic versioning numbering scheme, which Bitcoin Core has done as well,
right?

**Mark Erhardt**: I think they are actually doing a different thing.  Where
Bitcoin Core is only counting up and we increment the major version just by one
every major release, I noticed here that they use something that looks like
Ubuntu release numbering.  So, I interpret that as year.month, 22.11, but I
haven't dug into it.

_Bitcoin Core #25730_

**Mike Schmidt**: In terms of code changes this week, there's four of them.
First one, Bitcoin Core #25730, and that changes the listunspent RPC.  It adds a
new argument that allows the option to include any immature coinbase outputs.
So the listunspent RPC returns a list of unspent transaction outputs that the
wallet knows about and lists those.  And immature coinbase outputs are recently
mined coins that need 100 confirmations in order to be spent, and right now,
listunspent RPC does not include those outputs that are immature coinbase
outputs, in contrast to something like the listtransactions RPC, that does
include immature transactions.  So, there's an additional option now for the
listunspent RPC to say, "Include any immature coinbase outputs", and that'll
show up in the list.

**Mark Erhardt**: To clarify, listunspent only lists the wallet's UTXO pool, so
not all unspents in the network.  So in this case, the immature coins would have
been coins that the wallet has mined to itself.  So, I don't know exactly how
furszy got the idea, but maybe some miner asked, "Hey, we want to keep track of
the funds that we mined ourselves", and for them this argument would be useful.
Immature coins, of course, are the outputs of coinbase transactions which are
unspendable for 100 blocks, well, only spendable in the 100th block after the
coinbase was created.

**Mike Schmidt**: Yeah, I saw I think it was BDK that originally opened the
issue for this, so I'm not sure if that has anything to do with Stratum v2 or
mining or anything like that.  But yeah.

_LND #7082_

LND 7082.  So, you can create no amount of private invoices, but in LND, if you
didn't provide an amount, then routing hop hints were not provided.  And if you
did provide amount with the private option, it was providing the route hints.
So, the PR here allows route hints to now be provided for private invoices that
don't have an amount provided.  And as a quick background, route hints are data
that suggest part of a routing path between a spender and a receiver, so that
they can send payments through nodes that potentially they previously didn't
know about.  And so for whatever reason, those route hints were not populating
for a private no-amount invoice creation in LND previously.

**Mark Erhardt**: Maybe to clarify, this should not be confused with blinded
paths.  So there is a feature in Lightning that allows the recipient, instead of
telling the sender about their own node, to essentially give a package of a few
layers of an onion that declares an endpoint that if the sender reaches, will
have a route included to reach the recipient.  And the route hints, on the other
hand, are basically just a set of directions how to find a hidden node, or I
should say an unpublished node, in the network.  And yeah, for no-amount
invoices, there's also the problem, or the added difficulty, if the last hop
next to you notices that the invoice might have not had a specific amount
declared, they can keep more and forward less and steal money that way.  So,
yeah.  Anyway, now we have some hop hints for no-amount invoices in LND.

_LDK #1413_

**Mike Schmidt**: Next PR here is LDK #1413, and that removes support for the
fixed-length onion data format.  We've covered this in a few different
newsletters.  BOLT4 was updated to remove the fixed-length onions from the spec
and that was about a month ago.  And actually, even before that was removed from
the spec, CLN, LND, and Eclair also had previously removed support for that.
So, it seems like this is the last domino of that to fall.  Murch, thoughts?

**Mark Erhardt**: Yeah, I think we've talked about this quite a bit already, so
we might not want to bring it up in the next one anymore!  It's just this old
format that was less flexible and basically over-defined is now removed
completely from the network.  We've already reported that something like all but
three nodes on the network weren't using it anymore, so I guess those last few
nodes should maybe, at some point, update from their well-beyond end-of-life
versions of software, and I think we're smooth sailing from here.

_HWI #637_

**Mike Schmidt**: Last PR this week is the Hardware Wallet Interface (HWI) #637,
and it adds support for the forthcoming Ledger app 2.1.0, and that's the
software that supports the Ledger signing devices, hardware wallets.  And in
that Ledger app, there's additional support that comes for allowing multiple
internal xpubs, support for the wsh descriptor, Witness Script Hash descriptor,
support for signing messages, OP_RETURN output support and wallet policy
language.  So, there's a bunch of goodies in the Ledger software that HWI now
can support once Ledger app 2.1.0 is released, which I don't think it is yet.
And the only other thing here is, the author who made these changes to HWI,
Salvatore, who spoke with us last week, is also working on a BIP for manuscript
wallet policies, which is cool.

**Mark Erhardt**: I think at this point it's also fair to give another shout out
to Andy.  Andy has, over the last few years, built this library for Bitcoin
Core, the HWI, and I think it has been one of the driving contributors to the
wallet interfaces, especially hardware wallets, to get a lot more compatible.
He's the author of PSBT, the HWI, and the Output Descriptor Standard.  So, I
think these are three of the key points that make it much, much easier for
wallets to interact and create multiparty transactions and multisig transactions
with each other.  So, I think I just wanted to mention that this is a really
important effort and if you see Andy, you should be appreciative of that.

**Mike Schmidt**: Yeah, a shoutout to achow for all his great work.  Good to
have you back, Murch, thanks for joining.  Thanks everybody for listening and
we'll see you next week.

{% include references.md %}
