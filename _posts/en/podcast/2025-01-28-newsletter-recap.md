---
title: 'Bitcoin Optech Newsletter #338 Recap Podcast'
permalink: /en/podcast/2025/01/28/
reference: /en/newsletters/2025/01/24/
name: 2025-01-28-recap
slug: 2025-01-28-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Andrew Toth and Dave Harding to discuss [Newsletter #338]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-0-28/393870570-44100-2-3b67a33fdac91.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #338 Recap on
Riverside.  Today, we're going to talk about why we would want an unspendable
script descriptor expression; who is using PSBTv2s and why; we're going to talk
about an offchain rolling DLC idea; and we also have an outsized segment on
Changes to services and client software this month, due to the way that the
holiday scheduling works, so we have a bunch to celebrate there.  Murch and I
are co-hosting today and we are joined by two special guests.  Andrew?

**Andrew Toth**: Hi, I'm Andrew, I work for Exodus doing Bitcoin stuff.

**Mike Schmidt**: Thanks for joining us, Andrew.  Dave?

**Dave Harding**: I'm Dave, I'm the co-author of the Optech Newsletter and the
third edition of Mastering Bitcoin.

_Draft BIP for unspendable keys in descriptors_

**Mike Schmidt**: Jumping into the News section, we have three this week.  First
one is titled, "Draft BIP for unspendable keys in descriptors".  Andrew, you've
drafted a BIP titled, "Unspendable() Descriptor Key Expression.  Maybe we can
talk about what is an unspendable descriptor; why would I want to describe a
spending condition that is unspendable; and, why would we need such a thing?

**Andrew Toth**: Yeah, so it's primarily for taproot as the internal key, if
you're doing a multisig or multiparty taproot construction and you don't want to
use the keypath spend.  So, in that case, you need to have a provably
unspendable key so that no one could sneak in a public key there that they would
know the private key for and be able to spend the funds out from under you.  But
the problem is, so there's an unspendable key defined in BIP341 that you can use
and you can also attach some randomness to it so it's not the same for every
address.  But what that would require you to do is back up that randomness.  And
so, that's not desirable for a lot of reasons.  So, right now with normal PTWSH
multisig, everyone can just back up their BIP39 mnemonic, and if you lose your
wallet, you can recreate it by having everyone else send you just their xpubs
that they recreate from their backups.  But if everyone loses their wallets, but
still has their BIP39 mnemonics, you can't recreate that backup anymore with
just your seeds, right?  So, you'll have to actually backup more data and every
extra UX burden will result in someone losing their money.

There's another desirable property of having this unspendable key, is for
hardware wallets, so especially for wallet policies, which is used by Ledger and
a bunch of different other hardware signers.  So, when you create your wallet,
it will display you the wallet policy that you're using.  And right now, it will
have to show you the unspendable xpub and have the user confirm it, which adds
friction to the UX as well.  I mean, right now, Ledger will check the pubkey of
the xpub and show its dummy, but it'll also show you all the data.  And if we
had a standard that everyone could recreate this xpub on their own, every
hardware signer could recreate this deterministically, then we could cut that
entire step out of onboarding as well, which would be a huge UX win.  So, those
are the reasons we're trying to get to a standard here.

**Mike Schmidt**: So, just to summarize, there already is the notion of an
unspendable key that you could, I guess, hard code, if you will.  And then
there's also a mechanism to tweak that for similar purposes, but obfuscating the
fact that you're using this dummy key.  But in order to do that, you need to
store information and that causes UX friction.  And so, am I right to understand
what you're proposing here is a way to derive an unspendable key without having
to store data around it; is that right?

**Andrew Toth**: Yeah, that's right.  So, there was a little confusion, and
there's some of that in the discussion about just having a generic unspendable
expression, and I don't think that's that useful to have because you'd still
pass in the chain code.  So, I think I might tweak the title of this BIP draft
to be like, "Deterministically creatable, unspendable internal key", or
something like that.  But we want to eliminate the need for storing that extra
information and have that unspendable key be derived just from the data in the
descriptor, or possibly just the wallet policy key vector.

**Mark Erhardt**: So, I have a question here.  You cited the privacy concern of
using a static unspendable key, or a known constant.  How do you get to a key
that can be re-derived from, is that public information or shared information,
but it's not a repeated key and cannot be derived from third parties; could you
highlight that?

**Andrew Toth**: Sure, so the actual public key is a static point, described in
BIP341, and basically combining that with BIP32 extended public keys, you make
that the public key, but then you have still 32 bytes there for the chain code.
And that 32 bytes is what the randomness is and what the entropy is here.  So,
once we add that extra 32 bytes on, any key we derive from that new xpub will be
still provably unspendable, but now you cannot determine that without having
that extra hidden secret entropy.

**Mark Erhardt**: Right.  And this hidden secret entropy could just be, for
example, the aggregate public key of the involved signers or something?

**Andrew Toth**: That's similar to what we're trying to do in the standard, but
there's a bunch of nuances that make it a little more difficult than that,
right?  And so, one of those is that if we both have a -- so, say for
sortedmulti, right?  If I do sortedmulti of key A and B, and you back up your
descriptor of sortedmulti B and A, those will, with normal segwit v0, it will
create the same address every time because they would sort.  But if you're
computing based on order of what the keys are in the descriptor, you'll end up
with a different unspendable key, which is a different address.  And so, there's
been work done by Liana to do a standard like this, but unfortunately they are
using left to right creation, aggregating the public keys left to right.  And
so, that creates issues both with using sortedmulti and with using just the key
vector of a wallet policy, because that can be a different order as well than
what's in the descriptor.  But there's some comments about maybe it's not worth
abandoning that standard and we could work around these.  So, we're still trying
to figure out what the best direction is for this.

**Mark Erhardt**: So, for example, if there's three parties involved, Alice, Bob
and Charlie, and the scriptpath involves all of these three public keys, if the
shared secret were derived of those three keys, third parties, when they observe
the spend, could determine that it was a nothing-up-my-sleeve, unspendable
keypath.  So, have you considered that, or is it a separate construction in some
way?

**Andrew Toth**: Sure.  So, basically we're using the public key of the
underived xpubs, right?  So, they'll just see the public key that's already been
derived, so they won't have the actual parent.

**Mark Erhardt**: Okay, I see.

**Andrew Toth**: That's one way that it will not be detectable.  But another way
is, so if you have multiple leaves in your merkle tree that the public keys are
in, you will use those to derive this public key, but those won't show up
onchain either, right?

**Mark Erhardt**: Okay, I see.  All right, thank you.

**Mike Schmidt**: Dave, any questions from you or comments?  Okay.  Andrew, what
are you looking for from the community?  How can our audience participate
positively in what you've drafted here?

**Andrew Toth**: Yeah, I mean, just think about if you are using multisig today
and you'd like to upgrade to taproot, how could this help you and does it make
sense; and are there any other pitfalls that we haven't seen with this approach?
Any feedback like that would be great.

**Mike Schmidt**: So, check out the mailing list post, check out the draft BIP
on the BIPs repository, and opine accordingly.  Andrew, thank you for joining
us.  I think this next news item you chimed in on, and so maybe you can hang
around for that.

**Andrew Toth**: Great.

_PSBTv2 integration testing_

**Mike Schmidt**: Second news item titled, "PSBTv2 integration testing".  Sjors
posted to the Bitcoin-Dev mailing list a post titled, "Who uses or wants to use
PSBTv2", which is BIP370.  And in his post, he notes that BIP370, that specifies
PSBTv2, has been out for a few years.  And he also points to an open PR in
Bitcoin Core that would support PSBTv2, but also points out that it has received
very little review.  So, he posted to the mailing list to see who else is using
PSBTv2 because it would be useful to have something to test against other
implementations as part of the review process.  One of the replies in the
mailing list thread was Kalle who responded noting, "Ledger has a PSBTv2
implementation since a number of years back.  It's used for communication
between their Ledger Live software and the hardware wallet".  And then,
Salvatore also followed up on that same thread noting, "It is to be noted that
all the PSBT implementations in the various Ledger client libraries are bare
bones, containing just what's needed for the communication protocol.  They are
not general purpose and not otherwise complete (nor planned to become so)".

In the newsletter, we called that usage -- we titled that bullet PSBTv2 usage,
"Merklized PSBTv2".  Dave, do you have thoughts on that before we move to the
other usage?

**Dave Harding**: I thought that was an interesting aspect of PSBTv2.  Because
it separates out more of the transaction into individual fields, including the
previous transactions, you can turn that into the elements of a merkle tree and
only send the specific elements to hardware wallet needs when it needs it.  So,
when you start off processing the PSBT, you set it the merkle route, so it has a
commitment to the whole thing.  And then, you can set it an individual element
along with a merkle proof, so it can make sure that what you're sending it is
part of the PSBT it started working on, and it can process that particular
element and then forget about it.  And then, it can go on to the next element
and verify the merkle proof for that, and then process it, and then forget about
it.  And this is very useful for hardware signing devices that are very
underpowered.  So, I mean, I had not thought of that.  I don't know if PSBTv2
was designed specifically for that, but it seems to get a very nice use of it.

**Mike Schmidt**: So, due to the constraints on the hardware signing devices,
you can't just parse the whole PSBT.  And so, by sort of merklizing the
components, you can have a little API where you're calling back and forth for
pieces of that PSBT?

**Mark Erhardt**: Yeah, you could basically have a transaction that spends a
number of different inputs, and each of those inputs could be an output of a
transaction with 100,000 vB, right?  So, you might be pulling in several MB of
data in total on previous transaction data.  And generally, the hardware devices
have a restricted amount of RAM.  So, a hardware wallet would probably not be
able to store all of that and process and operate on that.  So, being able to
provide it piecemeal in a way that you can prove that it all belongs together is
pretty awesome.

**Mike Schmidt**: That makes a lot of sense.  And so, that was the first usage
that we called out in the newsletter, which was merklizing the PSBT data.  And
then, the other usage we called out in the newsletter was, "Silent payments
PSBTv2".  And Andrew, this was a reply from you.  Do you care to elaborate?

**Andrew Toth**: Yeah, sure.  So, PSBTv0 required to store the constructed
transaction unsigned when created, right?  And that would mean it would have to
have output scripts attached to each output, otherwise it's not a valid
transaction.  And so, silent payments does not have output scripts computed at
creation time, right?  You have to have all inputs added and outputs, and then
signers have to add their data, which after they've fully added all the data,
then they can create that output script, right?  And so, the PSBT for the silent
payments BIP tweaks the requirement of the PSBT_OUT_SCRIPT field so that it can
be optional, so that we don't have to have it there, which PSBTv2 required it.
PSBTv0 though doesn't even have that option, so it's not really possible to do
it there.  And so, yeah, I think that's basically it.

**Mike Schmidt**: Murch or Dave, anything to add on that before you wrap up this
news item?  Great.

_Correction about offchain DLCs_

Last news item this week titled, "Correction about offchain DLCs".  Dave, we had
a news item on this last week, and Murch and I punted on discussing it during
the podcast, because between publishing that newsletter and the podcast, we got
feedback from the author when I reached out to them to join the podcast, that
there were some changes to the original writeup from last week.  So, they had
some corrections and we covered that in the news item this week.  But given that
we have not yet broached the idea at all on the podcast, maybe you can give us
an overview of what I'm seeing as offchain rolling DLCs?

**Dave Harding**: Okay, well we've covered the idea of offchain DLCs in previous
newsletters, looks like #174 and #260, and those were basically constructed like
LN channels.  So, I mean, a DLC is a contract between two people, and you can
use it for all sorts of stuff, and the contract is decided by an oracle, so it's
a trusted third party.  The interesting thing about DLCs for the oracles is the
oracle doesn't know who's using it and they can't really interfere with the
contract.  So, it's a little different than, say, like a 2-of-3 multisig, where
the oracle is one of the parties to the contract that can see all parts of the
contract; it can see how much money is bet on it and whatnot.  In DLCs, the
Oracle can't see any of that.

The older scheme that we covered in the previous newsletters, which I'm calling
here, "DLC channels", although there's a couple variants of it that go under
different names, like I said, it works like an LN channel, where the DLCs are
made.  You make a contract and it sits around for a while and then when it gets
near the end, you can go onchain and settle it, or you can offchain settle it by
revoking it, using kind of a key exchange where people say, you know, "If I
revoke this, I revoke it by giving you the ability to steal all my money if I
violate the protocol".  And 'steal' is the wrong word for there, but it's easy.
And I made the incorrect assumption that the new protocol worked pretty much
like the old one.  So, that's what we put in last week's newsletter.  But like
you said, the author, conduition, talked to us and said we weren't quite right.
So, I dug into it in more depth.  And he's correct, of course.

His protocol has this interesting idea, where instead of the parties revoking
the transaction themselves, the oracle actually revokes it.  And the oracle
revokes it automatically, again without any knowledge of the contract, by simply
making a decision on the contract.  This is kind of weird.  It means that when
the contract is settled, neither party gets the money.  So, they have to
conclude their business themselves before the expiration date of the contract,
or they'll both lose money.  It's kind of weird, but it has this interesting
property.  So, let's think about a contract.  Let's say I have 1 bitcoin and
that's all the money I have, but I have expenses denominated in fiat.  So, I'm
going to be in a bad way if the price of Bitcoin goes down a lot.  Let's say
Mike thinks the price of Bitcoin is going to go up.  So, we can agree to a
contract where if the price of Bitcoin goes down, Mike gives me some bitcoins to
make me have more bitcoins so I have money to pay my fiat expenses; and if the
price of Bitcoin goes up, I give Mike some of my bitcoins so that he gets more
money.

With the previous DLC channels, the way we would have to do this is we would
have a succession of contracts, where I would have a first contract with Mike
for say a month, and if the price didn't really change within that month, at the
end we would create a new contract and then we would revoke the old contract.
So, we create a new contract for another month and revoke the old contract.
With this new system from conduition, what we do is we pre-commit to the series
of contracts.  So, we have a contract for the first month, for the second month,
for the third month, and we pre-sign that all at the start.  And if the price of
Bitcoin doesn't change too much month to month, we don't have to do anything.
The old contract gets revoked, the new contract goes into effect, and that just
keeps repeating.  If the price does change a lot, and let's say the price goes
down and I need money for my fiat expenses, then I can terminate the contract at
any point by going onchain near the end of one of these cycles, and I get my
money.

This is really nice for a P2P contract where you don't have both parties online
at the same time.  If you know one of the parties is always going to be online,
let's say you're opening a DLC channel, the older style, with a very established
entity that has 99.99% uptime, then you're fine.  There's some advantages there
because you can change the contract terms at any moment.  But if it's actually
between Mike and me, well, we might not have our DLC nodes online at the same
time.  So, this new contract works very efficiently for that.  I don't need Mike
to be online at any point, I can settle this contract completely myself, and it
can be a perpetual swap.  It can just keep going pretty much indefinitely, we
could sign contract states for the next hundred years easily.  So, it's a very
interesting development there.

There's some trade-offs.  We go to some details in the newsletter.  Conduition
has a very nice page about this that we link to.  I think it's interesting in
the context of DLCs, and it might be interesting in the context of other
protocols.  I haven't really thought of anywhere to use it yet, but I think it's
an idea that we really want to get out there and have people thinking about.

**Mike Schmidt**: Dave, you gave the example of sort of a contract going long,
one party's long Bitcoin, one party's short Bitcoin in the DLC, and then you
mentioned perpetual swaps.  And I guess it makes sense to me if the contract was
an undefined term, that you would have these check-in points along the way,
because there's no defined end point.  Does the construct outline for these DLCs
also apply to fixed term, if you and I are saying like, "Well, I'm just going to
bet that Bitcoin price is going to be up in one month"; would we still need
those check-ins or would this apply?

**Dave Harding**: You can still use this construction for that, you just
wouldn't pre-sign extensions to it.  You would have a single contract with it,
and then when the extension approached, you and your counterparty, if you're
both online at the same times, you could negotiate what to do with the funds.
First of all, if your counterparty isn't online, you can close the contract out
at the end of the month.  If your counterparty is online, you can say, "Let's
roll this over into a new contract", possibly for a completely different thing.
So, you start off betting on the price of Bitcoin and USD, and the next month we
could change it to Bitcoin versus Ethereum, or whatever you want to do, or just
some sort of sports game or something.  So, you can absolutely use this for
fixed terms.

As constructed, because of the trade-offs, the DLC channels protocol, the older
protocol, I think is a little bit better for short-term contracts if you can
expect both parties to be online, just because at any point, it allows you to
close out a contract and create a new contract.  The new DLC factories protocol
from conduition, it has some pretty strict time limits on when you have to do
stuff.  And if you want to change the contract, if you want to switch from
betting on the price of Bitcoin versus USD to Bitcoin versus Ethereum in the
middle of a month, let's say, you can't do that.  You have to wait till the end
of the month before you can switch over to the next contract.  So, there's
trade-offs.  In our chat with conduition, he did say he thinks he can maybe
remove that particular trade-off and allow you to cancel contracts in the middle
of the month, but he's still working on that.

**Mike Schmidt**: Dave, I think you touched on it, but maybe I missed it.  What
assumptions do we have about the oracle in this example?

**Dave Harding**: It's the same for this new protocol as it is for the old
protocol as it is for just standard DLCs onchain.  You trust the oracle to sign
a commitment to what actually happens.  So, in the case of a Bitcoin/USD price
contract, the oracle signs the price on the last day of the month, at noon the
last day of the month, or whenever the contract expires.  If the oracle lies
about that, then the contract is just going to follow the lie.  So, you do
absolutely trust the oracle to provide correct information.  What you don't have
to do is give the oracle any information about your contract.  They don't have
to have any information about you at all.  You can contact the oracle over Tor
and it's going to be completely anonymous to them, they don't know how much
value is at stake.  And that's the advantage of DLCs over other contracts for
financial instruments, is that the oracle is just completely blind to what's
happening.

So, it's a very nice thing and offchain versions of this are great for people
who want to do this often.  Like, if you're doing this on a rare occasion, for
example you want to bet on a soft fork proposal, onchain it's only going to
happen once every few years; onchain is fine.  But for an offchain, again, if
you have these sort of perpetual swaps or you're just in the business of
frequently making bets on things, then offchain constructions of course save you
a lot of onchain space.

**Mike Schmidt**: Are you at the whim of the oracle?  If the oracle's offline in
this conduition proposal, can you and your counterparty just get together and
agree, "Okay, here was actually the price", and settle it out that way?

**Dave Harding**: You can.

**Mike Schmidt**: Okay.

**Dave Harding**: There are some safety considerations there, but at any point,
you and your counterparty, if you're both online at the same time, you have that
funding output, just like you would have in an LN channel.  That's just 2-of-2
multisig, you can spend it at any time, however you would like, by mutual
agreement between you and your party.  However, this protocol, probably both
protocols, but the new DLC factories protocol is pretty dangerous if your oracle
is unreliable, because if they publish early, you both lose your money.  You can
mutually agree to spend it, but you're in a situation where your money has been
set up so that neither one of you can safely spend it unilaterally.  So, like in
everything, because you're trusting a third party here, make sure you choose
somebody you trust to be not just accurate, but reliable.

**Mark Erhardt**: I seem to remember that it was possible to have multiple
oracles contribute to a DLC.  Is that possible?  So, if you had, like, three
services and you need two of them to sign off on something, would that work?

**Dave Harding**: That works with both protocols, both the DLC channel protocol,
it works with that, and it works with this new protocol.  With this new
protocol, you would need the threshold number of signatures to trigger the
special condition that invalidates both parties' ability to spend.  But yeah, it
works just fine.

**Mike Schmidt**: Great.  Thanks, Dave, for the writeup last week, working with
conduition and the corrections this week and explaining that to us.  I think it
would be great if you hung on the rest of the discussion if you can.  Great.

_Bull Bitcoin Mobile Wallet adds payjoin_

We have our monthly segment titled, "Changes to services and client software".
We have a bunch this month, which is great.  First one, "Bull Bitcoin mobile
wallet adds payjoin".  So, Bull Bitcoin, I believe, is an exchange, but they
also have a mobile wallet app, and they've added both the ability to send and
receive using the BIP77 Payjoin v2 specification.  Pretty cool to see.

**Mark Erhardt**: Do you know if they also run, I think it's basically a blinded
server as a post box that makes it happen?

**Mike Schmidt**: I am not sure about that.

**Mark Erhardt**: Well, that would be good to find out.

_Bitcoin Keeper adds miniscript support_

**Mike Schmidt**: Comb the announcement, I guess, and see.  Bitcoin Keeper adds
miniscript support, so Bitcoin Keeper added support for miniscript in their
v1.3.0 release.  If I recall correctly, I didn't pull the notes up, but I
believe that that miniscript is specific usage in Bitcoin Keeper.  I'm not sure
that you can supply arbitrary miniscript but they're using it behind the scenes,
I think, for maybe their inheritance planning.  But I may misspeak about that.
Bitcoin Keeper people can troll me on Twitter.

_Nunchuk adds taproot MuSig2 features_

Nunchuk adds taproot MuSig2 features.  Nunchuk's always up to something cool.
So, yeah, this is beta support for MuSig2 for taproot keypath multisignature
spends.  And so, they also have a tree of MuSig2 scriptpaths that can achieve
threshold spending, like 3-of-5, and so there's a tree of those MuSigs that can
represent that threshold signing as well.

**Mark Erhardt**: Yeah, so the point there is, of course, that MuSig2 can only
represent k-of-k signatures, so 2-of-2 or 3-of-3.  But for example, if you want
to do a 2-of-3 and you only have MuSig, you can simulate that by putting a
2-of-2 as the keypath spend, and then the other 2-of-2 and the third 2-of-2 as
script leafs in the scriptpath.  And that way, with three 2-of-2 leafs, you can
have A and B in the keypath, B and C and A and C in the scriptpath, and that way
you have a 2-of-3 multisig with MuSig.

**Mike Schmidt**: And I guess the idea there would be of the three keys, the two
that are most likely to sign together would be given that preferential treatment
since it's cheaper?

**Mark Erhardt**: Yeah, BitGo does the same thing for their MuSig2
implementation, and there it's just the user key and the BitGo key in the
keypath, which are used probably 99.9% of the time, probably more even.  And
then the two fallbacks, the user key with the key service provider, and the
BitGo key with the key service provider are script leafs, and you can reveal
them as necessary, and that way you get 2-of-3 multisig, even though you only
have MuSig.

**Mike Schmidt**: And in the future, something like FROST gets rolled out more
broadly, you wouldn't need something like this as sort of a middle solution,
right?  You would just use FROST?

**Mark Erhardt**: If you had FROST, you could do the 2-of-3 multisig threshold
directly in the keypath.  And FROST is, of course, a lot more complicated.  I
don't think there is an implementation of it yet, but there's, of course, the
paper, and I think there is now work on the distributed key generation, which
we've reported on as well.

**Mike Schmidt**: And I think there's some development on the signing front as
well.

_Jade Plus signing device announced_

Jade Plus signing device announced.  So, folks may be familiar with
Blockstream's Jade hardware signing device.  There's now a Plus version.  And
the piece I thought was interesting was the exfiltration-resistant signing
capabilities and the air-gapped functionality.  I think that the folks at
Blockstream have a big, longer list of things, but I thought that those were
most important to our audience.

_Coinswap v0.1.0 released_

Coinswap v0.1.0 released.  This is noted as beta software, and it's titled
Coinswap and it implements the Coinswap protocol.  And actually, as part of this
release, it formalizes the specification for the Coinswap protocol.  And right
now, it supports testnet, and there's a few different command line applications
for different roles within the Coinswap protocol.  Do one of you want to tell
everybody what Coinswap is?

**Dave Harding**: Coinswap is a protocol for, well, like it sounds, two people
swapping coins, or possibly more than two people swapping coins.  I think it's
also been called Teleport Transactions.  And basically, a simple way of thinking
is, Murch and I both want to buy something, different things around the same
time.  And I buy the thing from Murch and Murch buys the thing from me, and this
kind of obfuscates the transaction history.  And it's not just buying stuff.
Anytime you're going to spend a coin, you go to the Coinswap server, and you
say, "Look, I'm going to go spend some bitcoin.  I'm going to spend about this
much".  And somebody else who's going to spend about that much, or is willing to
get paid for sending a transaction on your behalf, does.  And like I said, you
send two transactions at the same time and they're kind of doing what you would
want to do, but from somebody else's money.  So, it's just a very clever way of
obfuscating history without too much overhead.

**Mark Erhardt**: So, if there is a not exact match of the amounts that are
being spent and one of the two parties receives back more, would you then make a
second change output that goes to the other party's wallet; is that how it
works?  I don't know exactly how they did it in the protocol.  One of the ways
they were talking about doing it was through Lightning, so compensating you
using like a submarine swap through Lightning, and then that's obviously a very
efficient way to do it.

**Mark Erhardt**: Right, because it would also break the link.  Otherwise, if
you have two transactions but one of them pays the other user, you would relink
the history.  So, the teleport was unsuccessful.

**Mike Schmidt**: Yeah, pretty cool to see this.  I know we've covered
discussions of Teleport Transactions previously.  I know the project was on
hold, and some other folks have taken over, which is great.  So, it's good to
see it moving along, along with the actual specification being more formalized.
It's cool to see.

_Bitcoin Safe 1.0.0 released_

Bitcoin Safe 1.0.0 is released.  Bitcoin Safe is a desktop wallet and it
supports a bunch of hardware signing devices with this latest 1.0.0 release.  I
think Bitcoin Safe, if you go to the website and check out the GitHub as well,
there's a bunch of good Bitcoin tech in there that is the kind of stuff that we
cover in the newsletter, so check them out.

_Bitcoin Core 28.0 policy demonstration_

Bitcoin Core 28.0 policy demonstration.  I thought this was pretty interesting.
It's not necessarily a software that you would download and use, or a wallet
software, or something like we usually cover, but Super Testnet put together a
website that he titled, "The Zero Fee Playground", and it uses a bunch of the
mempool policy features that we covered towards the end of last year, to be able
to do zero-free transactions.  And I think he didn't initially have
pay-to-anchor (P2A) and then added P2A support as well.  So, pretty cool to play
around with.

_Rust-payjoin 0.21.0 released_

Rust-payjoin 0.21.0 is released.  Something I noticed that qualified it as a
callout in this segment was the transaction cut-through capabilities.  And we
had discussed that back in Podcast #282, actually, and I think, Dave, you were
the one back in that episode that called that out.  But yeah, I remember the
transaction cut-through posts being referenced a long time ago, and I don't
really see it being referenced or used in the ecosystem, so I thought that was
an interesting thing to call out.

**Mark Erhardt**: I recently saw that one of the things that was open for a
while got resolved.  So, there were some incompatibilities with BIP78, the
previous payjoin proposal, and there had been open BIP PRs for a long time and
they finally got resolved.  So, BIP78, the established older payjoin protocol,
and BIP77, it will be much easier to implement support for both of these in
parallel in wallets.

_PeerSwap v4.0rc1_

**Mike Schmidt**: PeerSwap v4.0rc1.  This PeerSwap is a Lightning channel
liquidity software, and with this release there were notable protocol upgrades.
So, if you're using PeerSwap already, I think you need to look and make sure
that your software you're using is compatible with this new version.  And
PeerSwap has an FAQ section I thought was interesting, like, "How is PeerSwap
different from submarine swaps or splicing or liquidity ads?"  I was reading the
release notes and thinking that same thing, and then I came across FAQ and so I
thought folks might be interested about how those things differ.  So, check out
PeerSwap if submarine swaps, splicing or liquidity ads are something you use or
are interested in.

_Joinpool prototype using CTV_

Joinpool prototype using CTV (OP_CHECKTEMPLATEVERIFY).  The CTV payment pool
repository, which is a bit hard to locate, so check out the newsletter for the
link to that, but that repository is a proof of concept that uses CTV, the
proposed opcode, to create a joinpool.  We call it joinpool.  Coinpool?  Murch,
what's the right definition here for shared UTXOs like this?

**Mark Erhardt**: I am not quite sure, but they are different things!

**Mike Schmidt**: Okay.  Paymentpool's in there as well.  Dave, do you have a
distinction or are these names for the same thing?

**Dave Harding**: I think they're pretty much names for the same thing.  We went
with 'joinpool' because that was the first name I heard it under.  I heard that
from Greg Maxwell.  And I've also heard paymentpool.  I think my current
favorite is coinpool.  It's the idea of everybody sharing a coin, which is a
UTXO.  But we just used joinpool because that's what I heard first.

**Mark Erhardt**: Okay, I think the difference is there's been concrete formal
proposals for one or the other and they are implemented slightly different.  But
generally, they're all concepts that are closely related and talking about how a
single UTXO is shared between multiple users.

**Dave Harding**: I think the fun part is that what's the difference between a
coinpool and a channel factory?  They're actually pretty much the same thing,
they just have different origins.

_Rust joinstr library announced_

**Mike Schmidt**: Rust joinstr library announced.  This library, perhaps
confusingly named, 'joinstr', implements the joinstr protocol in Rust.  The
joinstr protocol is something we talked about on a couple of shows, I think, but
it's a coinjoin protocol that uses Nostr for coordinating the participants in
the coinjoin.  Joinstr already has protocol implementations in Kotlin and Python
already, and so this is a Rust implementation.  And the repository notes that
the library is very experimental and they do not advise using it on mainnet at
this time.

_Strata bridge announced_

Last piece of software, Strata Bridge announced.  So, there's Strata Bridge and
then there's Strata.  So, Strata is a layer, I'll use the term 'layer' I guess,
being built on top of Bitcoin, and I think of it like a sidechain that is using
the Bitcoin blockchain to post state to periodically about its sidechain, and it
uses Bitcoin transactions to post that state.  And related to this Strata
platform, or sidechain, is the idea of Strata bridge, that's the mechanism to
sort of peg in bitcoins and peg out bitcoins from this Strata platform.  And so,
the Strata bridge technology is based on BitVM, specifically BitVM2, and it's a
way to make payments contingent on some sort of computation being run correctly.
There could be a lot to say here or nothing to say here.  Dave or Murch,
anything?

**Dave Harding**: I don't really know anything about this stuff, sorry.

**Mark Erhardt**: Me neither.

_BTCPay Server 2.0.6_

**Mike Schmidt**: Me neither.  Releases and release candidates, BTCPay Server
2.0.6.  This release contains a security fix to prevent duplicate payouts in
certain BTCPay configurations.  For that specific security fix, the release
notes say that the developers actually couldn't reproduce the original issue,
but that the original user reporting the issue confirmed that it was resolved in
the set of changes included in that release.  The release also contains a couple
of new features, a handful of less critical bug fixes and some general
improvements.

_Bitcoin Core #31397_

Notable code and documentation changes.  Bitcoin Core PR on the GitHub #31397.
This is part of the package relay project.  It improves the orphan resolution
process.  In Newsletter and Podcast #333, we actually had Gloria on.  Well, I
guess in Podcast #333, we had Gloria on, but we covered also in the Newsletter
the PR Review Club that was on this PR.  And so, she provided a bunch of
background information and context on this PR.  To give a quick headline summary
of the PR, but you should definitely listen to Gloria explain it, is that it
improves the reliability of orphan resolution by letting the node request
missing ancestors from all peers instead of just the peer that passed the orphan
transaction.

So, orphan transactions are transactions for which your node does not have the
parent transaction yet.  So, before this PR, Bitcoin Core would attempt to only
find the parent transaction by going back to the person that gave the orphan and
saying, "Can you provide the parent?"  But after this PR, Bitcoin Core will now
actually attempt to find that orphan's parent from a variety of peers.

**Dave Harding**: And I'll add here that in next week's newsletter, which we
have a draft of, we'll actually be mentioning this PR with relationship to
compact blocks.  So, there's been some recent discussion about compact blocks
and how effective they have been recently at quickly reconstructing blocks from
the mempool.  So, I guess in next week's newsletter, we'll cover this in a
little bit more detail, but this PR may help improve compact block resolution,
just as an incidental benefit of it.

_Eclair #2896_

**Mike Schmidt**: Interesting, look forward to that.  Eclair 2896 is a PR
titled, "Get Ready for storing partial commit signatures".  So, Eclair stores
the Lightning node's channel peer signature, which is required for the
commitment transaction.  So, that's how things have been going currently and
will continue to go.  In order to save similar information and have similar
capabilities of this unilateral commitment broadcast in a future of simple
taproot channels, Eclair is going to need to save the partial signatures that
are part of a 2-of-2 MuSig2 scriptless multisignature scheme, which is what
simple taproot channels' proposed BOLT extension requires.  This PR is part of
Eclair's project to support simple taproot channels, not surprisingly.

**Mark Erhardt**: This harkens back to PSBTv2, doesn't it?  I'm surprised that I
don't see a mention of PSBTv2 in the context of this PR.

**Dave Harding**: I don't think any of the LN implementations use PSBT, either
v1 or v2, for managing channel commitments.  Several of them support it for
constructing a funding transaction and spending your funds outside in the
wallet, but I don't believe they use PSBT or even data structures locally,
internally, for channel commitment transactions or HTLCs (Hash Time Locked
Contracts).

**Mark Erhardt**: Interesting.

_LDK #3408_

**Mike Schmidt**: Next PR, LDK #3408, is a PR titled, "Add static invoice
creation utils to ChannelManager.  Dave, I punted to you on this one.

**Dave Harding**: Okay, well, this is pretty simple.  So, this is for async
payments, and async payments are for the case where Murch wants to receive a
payment and he's willing to create the offer and the invoice.  He knows how much
he wants, or at least he knows he wants to get paid, but he won't be online at
the time that I go to pay him.  And so, this is just some tools for creating an
offer, which is an interactive protocol, but for creating an offer and a static
invoice that Murch can give to Mike.  And then when I want to go pay, I contact
Mike and Mike sends me the invoice, and then I have the details to create an
async payment.  So, Mike is, let's say, Murch's LSP, so he's the hop right above
Murch.  So, I tell Mike, "Okay, I've got the offer, you've sent me the invoice,
I'm ready to pay", and I'm going to send that to my LSP.  And then, when Murch
comes back online, Mike tells my LSP, "Murch is online, go ahead and pay".  My
LSP pays through Mike to Murch, and it all just works out.  Murch and I don't
have to both be online at the same time.

That's what the async payment does.  And this is just some tools, some utility
functions for creating the necessary offer as static invoice to make that happen
on Murch's side.

_LND #9405_

**Mike Schmidt**: Makes sense.  Great, thank you, Dave.  Last PR this week, LND
#9405.  And this PR makes the number of confirmations needed in LND before
processing channel announcements configurable.  The LN spec recommends setting
this value to 6, which is the default and has been the default, but now LND
makes that value configurable, although I think I saw that it perhaps couldn't
go below 3.

**Dave Harding**: Several LN implementations have been making the same basic
change.  I think it's to support -- I can't remember what it is to support.  I
think we mention it in next week's newsletter, but I can't remember the name of
it right now.  But I think there's a spec change coming through and they're all
just making this configurable, so they're all kind of on the same page.

**Mike Schmidt**: Is it splicing-related or no?

**Dave Harding**: I think it's a gossip change maybe.

**Mark Erhardt**: I think it might just be, waiting for 6 confirmations makes it
feel very long until you can start using your channel on the network, and
probably people have been pushing to make it quicker because in practice, 3
confirmations are probably sufficient.

**Mike Schmidt**: For now.  All right, great.  Well, I think we can wrap up.
Thank you to Andrew for joining us as a special guest.  He had to drop, but
Dave, thanks for hanging on with us as a special guest, and thanks always to my
co-host Murch, and for you all for listening.

**Mark Erhardt**: Hear you soon.

{% include references.md %}
