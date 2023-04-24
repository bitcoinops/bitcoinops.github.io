---
title: 'Bitcoin Optech Newsletter #243 Recap Podcast'
permalink: /en/podcast/2023/03/23/
reference: /en/newsletters/2023/03/22/
name: 2023-03-23-recap
slug: 2023-03-23-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Alekos Filini to discuss [Newsletter #243]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/67545048/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-2-29%2F2a4fe187-8895-deaf-5429-21ee45ce15f8.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #243 Recap on
Twitter Spaces.  We have a special guest who will introduce himself shortly.
I'm Mike Schmidt, contributor at Optech and also Executive Director at Brink,
funding open-source Bitcoin developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I do Bitcoin stuff at Chaincode Labs.  I've
been working on reviewing a BIP and writing a BIP this week.

**Mike Schmidt**: And, Alekos?

**Alekos Filini**: Hi everyone, I'm Alekos.  Until recently, I was the let's say
lead maintainer of BDK or the BDK library.  Now, I'm kind of in between jobs.
But yeah, I'm kind of stepping down from BDK a little bit, so I'm still unclear
what I'm doing right now, but yeah, I'm here representing BDK, even though I'm
not anymore lead maintainer of the project.

**Mike Schmidt**: And we don't have a BDK-related news item this week, but there
is a major restructuring that we covered in the PR section, and I think it would
be interesting to have some thoughts on that.  So, I thought it would be great
to have a look about BDK #793 later in our discussion.  So, thank you for
joining us.

**Alekos Filini**: Thank you for having me.

**Mike Schmidt**: Yeah, absolutely.  There's no news items this week that we
noted in #243, but we do have a monthly segment in which we highlight
interesting updates to Bitcoin wallet services and other client software that
use Bitcoin or Lightning, and there were quite a few updates that I found in
trolling through my notes and some of the repositories that I take a look at, so
we can jump in and go through that first.  Murch, any announcements before we
jump into that?

**Mark Erhardt**: I don't have any.

_Xapo Bank supports Lightning_

**Mike Schmidt**: All right.  Well, the first interesting client software update
that we noted this week is Xapo Bank supporting Lightning.  So, I think folks
maybe have heard of Xapo before.  I think that they're now called Xapo Bank,
because I think they spun off the custodian portion to Coinbase and are left
with this Xapo Bank, and they have a series of mobile apps and they announced
support for those mobile apps to be able to send Lightning payments using those
Lightning mobile apps, and they've mentioned the underlying infrastructure
provider as Lightspark.  Murch, any thoughts on that integration?

**Mark Erhardt**: I have not tried it out myself yet.  I think it's pretty cool
that a bona fide bank is getting on the payment rails of Bitcoin, even if it was
a Bitcoin company first!

**Mike Schmidt**: Yeah, and it's also interesting, I think Lightspark, there was
some mystique and mystery about what they're working on, so it's nice to see
that some of that behind-the-scenes work that they're doing is coming to
fruition and with a fairly large player and a bank, so that's interesting to
see.  Hopefully see more from Lightspark.

**Mark Erhardt**: I don't have a lot of inside knowledge there, but it sounded
to me like they first decided that they were going to do something with
Lightning and then they tried to figure out what their product was going to be,
so I think that might have added to the mystique.

_TypeScript library for miniscript descriptors released_

**Mike Schmidt**: Perhaps.  The second thing that we noted in the newsletter was
a TypeScript library for miniscript descriptors being released.  So, TypeScript
is a JavaScript-based language and there is now a descriptor library with the
fairly uncreative name of Bitcoin Descriptors Library, which has support for
PSBTs, descriptors and miniscript.  And then there's also, as part of the PSBT
process, the signing or the finalizing, there's support for single signing as
well as hardware signing.  Murch, did you get a chance to look at this library
at all?

**Mark Erhardt**: I did look at it a little bit.  So, I didn't look at the code
too much, but I was very impressed by the ReadMe.  The ReadMe looks very
elaborate and well readable.  And the other thing that really impressed me is
that the whole project appears to have started only in January, so they're only
two months in and they seem to have brought support for a bunch of things
already.  So, whoever is going to use that, I think you'll enjoy the
documentation they're writing.  Yeah, let me know what the code's like when you
look at that more.

**Mike Schmidt**: I found after the fact that there's actually a website we link
to the GitHub for the project, which is what we usually do, because sometimes we
actually list a link to the project's website if there is one and I wasn't aware
that there was one.  But in preparing for the Spaces, I did stumble across the
bitcoinerlab.com website, which has even more documentation and discussion about
what this library does.  So, in addition to the ReadMe that Murch was impressed
with, there's even more documentation on their website, so check that out.

I noticed there's talk of miniscript, there's talk of descriptors.  I don't see
anything policy-related, and maybe, Murch, it's a good opportunity, although I
think we've done it a few months ago, to maybe just quickly outline what's the
difference between miniscript descriptors and policy.

**Mark Erhardt**: I think that, yeah.  So, there are multiple levels of
miniscript.  Miniscript by itself is a subset of the script language that is not
ambiguous, I guess.  So, with miniscript policy, you can describe a somewhat
human readable policy of what you want the wallet to behave like, and then the
miniscript compiler will compile that to miniscript, which in turn is a more
readable representation of an underlying script, as in the Bitcoin transaction
language.  So, I assume that they just cover all of that and don't confront the
reader with the distinctions there immediately, but I have not looked to that
level to confirm that.

**Alekos Filini**: I don't have any experience with this level specifically.  I
think maybe they only do the second step where you have a descriptor and you
want to create a script row between scripts given the descriptor so that you can
use it for generating other addresses or monitoring if you've received some
funds, or something like that.  So anyway, it will probably be easier just
implementing this descriptor to script compared to the full miniscript
libraries, like the Rust miniscript and the C++ library.

Then they also have the compiler.  So, those libraries, they take the very
eye-level description and they compile it down.  Maybe that's a lot of
complexity that maybe they don't really care about initially, so they just want
to start with if you've made a script, or I can give you a script so you can
monitor addresses, etc.  That's already a big chunk of what most users need
actually.  Most of the time you just need that if you have a JavaScript wallet;
you are fine with just that, you don't need a compiler in your project.

**Mike Schmidt**: Yeah, that's good insight into Murch's point.  It seems like a
fairly young project, so potentially some of that stuff could be added in the
future.

_Breez Lightning SDK announced_

The next item that we noted was Breez Lightning SDK being announced and we've
linked to a blog post from Breez announcing this open-source SDK.  It seems like
they're targeting mobile developers, and specifically mobile developers that are
building apps that aren't necessarily Bitcoin-focused or wallet-focused, so it's
a way to add in Lightning features to an existing app.  So, it would be nice to
see some adoption of this SDK because it would mean broader adoption of
Lightning and Bitcoin in the mobile app round realm, which is interesting.

The SDK behind the scenes in order to fulfill that Lightning integration and
some of the Bitcoin features actually uses Greenlight, which is a Blockstream
product, and then they also provide some of their own Breez LSP features, and I
think there's some fiat on and offramps that they're planning to work on using
MoonPay behind the scenes.  So, it's pretty cool, it's nice to see Greenlight
also getting some usage.  Murch, did you get a chance to look at the SDK and
some of the features?

**Mark Erhardt**: I have not dived in too deeply, but the idea that you can just
provide a wrapper for all of the Lightning interactions seems very sensible to
me.  Just like with a credit card, you don't really need to know how the credit
card works under the hood to understand the concept that you can use it to
perform a payment that somehow in the background is settled between your bank
and the merchant, right?  So, if they actually manage to wrap up everything that
needs to happen in the background and you essentially just come down to, "I need
to pay this amount", and it's maybe even presented in fiat, and they have
wrapped all complexity around for the user, well presumably Lightning payments,
but yeah, that sounds like a pretty sweet application of using Greenlight in the
background and plugging it in to a front end like Breez.

**Mike Schmidt**: Yeah, very cool, and for folks who aren't familiar with
Greenlight and how that fits in here is that a node will actually be provisioned
that is managed by the Greenlight Blockstream team, but they don't hold your
keys, they'd never have any of the keys or the keys never touch their
infrastructure, so they're merely the ones managing the node.  So, these users
would have their own node and their own keys as well.  And my understanding from
the announcement from Breez is also that if there's multiple apps that integrate
Breez, that the "end user" can actually see the same balance across their
different apps, so there'd be one balance shared between the apps if folks are
using the Breez SDK, which is pretty cool.

I haven't tried it, didn't run SDK, but just from their announcement and digging
into some of the documentation, that's what I gleaned.

**Mark Erhardt**: Yes, I think it's also interesting to see that now that
Lightning infrastructure is maturing and more services are offering packaged
products, the possibility to take multiple of them and plug them together to
offer yet another composed product is growing.  So, yeah, Greenlight on the one
hand here doing the heavy lifting on the Lightning Network side; Breez offering
basically the repackaging the wrapper, the integration with other processes, is
pretty cool.  It kind of reminds me how LDK plugs into BlueWallet to do the
heavy lifting on the Lightning side, where BlueWallet now can offer
self-custodial Lightning to its users.  I think it's really nice to see how
things are coming together slowly and products are getting more refined that
way.

_PSBT-based exchange OpenOrdex launches_

**Mike Schmidt**: The next piece of software that we spoke about in this segment
of the newsletter is PSBT-based exchange OpenOrdex launches, and this is an
open-source exchange essentially for trading ordinals using PSBTs.  And since
you're actually trading bitcoin for bitcoin, it can all be done in this
pre-signed PSBT, or I guess the seller signs their portion of the PSBT and that
acts as part of an order book that somebody can then complete by signing and
then broadcasting the rest of that PSBT to the network.  Murch, any thoughts on
this?  I thought it was interesting that PSBT functioned as like an order, and
sort of like an order book.  I think there's nostr involved here as well for
some of the order book stuff, but PSBT is the format that this order book is
being passed around in.

**Mark Erhardt**: Yeah, I think that's a really nice way of -- I mean, as I may
have mentioned before, I'm not really that much following the whole ordinal
inscription movement or hype, but it is a kind of nifty way of presenting and
producing this marketplace.  So, when an inscription's written to the block
chain, the inscription is sort of attached to one specific satoshi, and the
ordinal scheme of course gives a framework of how they're supposedly tracked and
uniquely identified, so you can sort of say, "Well, exactly this satoshi owns
the inscription".

I saw another PSBT-based ordinal marketplace being announced on Twitter the
other day, and they basically use a transaction structure where the first input
is just a dummy input, and then the second input basically provides the satoshi
that holds the inscription and also leaves a slot open for the buyer to put
their own address.  And, since you can have signature hash flags, where each
signature in Bitcoin has a modifier that says what parts of the transaction it
commits to, and if you use the SIGHASH_SINGLE flag, you can set that you're just
committing to certain inputs and outputs.

So in this case, for example, you would build a transaction that has certain
parts still open that the other side that wants to take the offer can plug into,
but then you provide the input and thus determine what you're offering to sell.
And you also provide an output which basically says how much money will appear
in a specific address of yours.  So, yeah, it's kind of nifty, even though I'm
not really that excited about the whole thing!  But yeah, kind of cool how
they're doing that.

**Mike Schmidt**: I see Rijndael in the Spaces giving thumbs up.  I think it was
his tweet that I saw originally that was what brought this project to my
attention.

_BTCPay Server coinjoin plugin released_

The next item that we saw that was notable for the Bitcoin Optech community was
BTCPay Server coinjoin plugin being released, and I think the BTCPay folks had
some announcements on Twitter.  But I think the most comprehensive announcement
was from the Wasabi Wallet team, so we noted their blog post in the newsletter.
And it's an opt-in feature for BTCPay Server merchants that can turn this on and
the plugin supports the WabiSabi protocol for coinjoins.  I think if you dig
into the post a bit, there's a few different ways in which you can be doing
coinjoins, and one that we didn't explicitly outline was that merchants, when
they do their scheduled payouts, can actually use coinjoins to do those payouts
as a secondary option within this plugin.

So, take a look at the writeup from Wasabi, and if you're into coinjoins and
you're into Wasabi and you're a BTCPay merchant, check it out.  Murch, did you
dig into this item at all?

**Mark Erhardt**: Yeah, I did read the blog post.  I wanted to point out maybe
what sort of threat model people are thinking about when they are considering
using this plugin.  So, you may have seen, for example, when big exchanges do
consolidations on the network, like Binance recently, that people immediately
see, "This is Binance doing consolidations".  And, why is it so easy to tell?
Well, in Binance's case, Binance heavily reuses singular addresses, so they have
one address that's responsible for their hard wallet, or maybe a few but very
few.  So, whenever somebody deposits into Binance, they will see their funds
flow to their hot or cold wallet of Binance afterwards, so it's extremely
obvious to anybody watching which funds go through Binance and end up there.

The same can be mitigated a little more if instead of using the same address for
your hot wallet over and over again, you use new addresses, as you should, and
especially if you use a separate address for every single deposit of the same
user.  So, even though you could have a single address for a depositor that they
can always deposit into the same address and you know how to tie their deposit
to their IOU, or their list in the database, well anyway, the problem with that
is if you are a merchant and somebody comes and pays for a product in your
store, they know of course what UTXO they created in order to pay you; and if
they keep track of that, they might be able to fingerprint your wallet.  If you
spend that UTXO with a bunch of other coins, they might learn about other
addresses of your wallet.

So inherently, if you have a large volume of payments, it might be difficult for
you to have financial privacy and, for example, you don't want to leak to your
competitors how much volume your shop is doing, or whether you're cash-strapped
currently and your money is moving extremely quickly because you have to pay for
deliveries with the money you just took in, or other things that people might
learn by watching your financials.

The idea here is, instead of just directly scooping up all your funds and
consolidating them into one address, you can move them through a coinjoin, where
it gets potentially mixed with a bunch of other merchants, or other users that
are participating in Wasabi's coinjoin scheme, and that way you break the
mystery-shopper attack, and you also break the common input heuristic that says,
"Probably all inputs on that transaction belong to the same wallet".

So, yeah, privacy is not a crime, just in case that wasn't clear!  The crime
supposedly is money laundering, but just keeping your financials private is not
a crime and actually good business sense.  Well, that went on a little longer
that I thought!

**Mike Schmidt**: Yeah, that was great context.  Thanks for walking through
that, Murch.

_mempool.space explorer enhances CPFP support_

The next item that we noted in the client and services updates section of the
newsletter is mempool.space adding enhanced CPFP support.  So, mempool.space is
a block explorer and they've had support for Child-Pays-For-Parent previously,
and what CPFP is, is a technique for fee-bumping a transaction.  So, if I have a
transaction that's say paying 1 satoshi/vbyte in the mempool and it's not
getting confirmed at the speed that I had hoped, I can actually create a child
transaction at a higher feerate, let's say 10 sats/vB.  And because that child
transaction depends on the parent transaction, when a miner's looking at
including that 1 sat/vB in a block, it will actually consider that, "Hey, I
actually get this 10 sat/vB transaction with it", which has the effect of
raising the effective feerate of the parent transaction.

That's been represented in mempool.space's block explorer for transactions that
are in the mempool.  There was this additional field for effective feerate, so
instead of seeing the 1 sat/vB fee, you'd actually see the effective feerate,
including that child transaction, for transactions that were in the mempool.
But this new change that they have has similar user interface and similar data
for transactions that are already confirmed.  So, if you look at an old block
and you see that the average feerate is 20 sats/vB and you see this transaction
in there that was paying 1 sat/vB, now you get the context of that and it will
actually include ancestor and descendant information about transactions that are
in a block, which would maybe enlighten somebody as to why a low-feerate
transaction got confirmed, because it had some descendants that paid for its
feerate essentially.

Murch, did you get a chance to look at this, and maybe you want to augment or
correct any of the CPFP information that I outlined about mempool.space?

**Mark Erhardt**: No, you did a marvellous job of explaining all that.  But
yeah, I'm pretty excited that they're now surfacing that information, because
previously the minimum feerate on blocks could really be confusing if really the
effective feerate of all transactions in a block was say 20 sats/vB or more.
Sometimes if a package of transactions came in with a low-feerate parent and a
high-feerate child, it would look like the minimum feerate was lower in the
block, but really it actually all fit because the child paid for it and it was
sensible to include the transaction.

_Sparrow v1.7.3 released_

**Mike Schmidt**: Next item from the newsletter that we noted was Sparrow v1.7.3
being released, and this release includes BIP129 support for multisig wallet
setups and custom block explorer support, among other features.  So, Murch, I
think we've talked about another wallet standardization which is similar, and I
do get confused by this sometimes, which is BIP329 is the labelling BIP, the
ability to label transactions and inputs and outputs and addresses I think is
BIP329 which was assigned in the last few months.

This is similar in that it's a multisig wallet setup BIP, but it's BIP129.  We
haven't talked about this much in the newsletter or in our Spaces.  Are you
familiar enough with BIP129 to maybe give a quick overview, Murch?

**Mark Erhardt**: Yeah, so BIP129 is an informational BIP, or maybe not
informational but rather it's a procedure on how multiple different wallets
could coordinate if they want to build a transaction together.  So, we've talked
a bunch about PSBT and descriptors in the last month, but the part that was
missing still was how do wallets even start talking to each other in order to
exchange that information with each other.  So, BIP129 addresses the steps, let
me quote from the BIP.

So, "Whether the multisig configuration is correct and not tampered with,
whether the keys are leaked during the setup, and whether the signer must
persist information and in what format".  So, it basically gives a framework for
wallet implementors on how to talk to other wallets to coordinate a multisig
transaction.  Then of course, once you have coordinated and you're talking to
each other, you can use the protocols that are specified, like MuSig, on how to
actually produce the signatures and securely coordinate that; but how do you
even coordinate that you want to make a transaction together.

I think this was written by a few wallet developers that basically were
interested in having a standard on how to do this together.  I see names of
people that work on Nunchuck, Coinkite, Shift Crypto, being a hardware wallet
producer, I don't know who Aaron Chen is, but Rodolfo Novak also from COLDCARD.

_Stack Wallet adds coin control, BIP47_

**Mike Schmidt**: The next piece of software we noted this week was Stack Wallet
adding coin control and BIP47/paynym features.  Murch, I don't know if you want
to scold me for linking to the coin selection entry on Optech with coin control;
I know I sort of use those a bit interchangeably and I know you have a
preference for coin selection versus coin control, the meaning of each.  Both of
these are privacy-related features, or potential privacy features, added to the
Stack Wallet, which is not a wallet we've covered previously.

**Mark Erhardt**: Yeah, I hadn't seen Stack Wallet before either.  It looks like
it is a wallet for Monero, Bitcoin, Bitcoin Cash and a few other things.  So,
the features that we described in our newsletter seem to include coin control,
which yes, I distinguish from coin selection.  In my opinion, coin selection is
the term to use when you're talking about the automated process of how your
wallet picks the coins it is using to fund a transaction, aka input selection;
whereas, coin control usually refers to when the user has the ability to
manually select which UTXOs they want to spend.  I've also seen people use coin
control for coin selection and vice versa, so there seems to be some confusion
here.

Other than that, it seems to be GPL-licensed and I don't know what Dart is as a
programming language.

**Mike Schmidt**: I think that's Google's.

**Mark Erhardt**: I have actually no idea about this wallet beyond that!

**Mike Schmidt**: Yeah, I think Dart is a Google language.  I think maybe it
does something with Java or JavaScript.  Yeah, I guess we can make everybody
angry, because we covered paynyms, which is like a Samourai thing, we've covered
Wasabi and we've covered ordinals.  So, everybody can be angry about our
coverage of software this week.

_Wasabi Wallet v2.0.3 released_

The last one is Wasabi, so we noted Wasabi's WabiSabi plugin for BTCPay, and the
last one here is Wasabi Wallet v2.0.3 being released, and actually was released
a day before the newsletter.  Some of the Wasabi developers actually appended a
commit which did this writeup.  This adds taproot coinjoin signing and taproot
change outputs, along with also coin selection -- or sorry, coin control; sorry,
Murch, for sending, and then some speed improvements and additional changes
which were less relevant to the Optech audience.  Any thought on Wasabi, Murch?

**Mark Erhardt**: This time you did it on purpose, right?!  Yeah, so in this
release, they have opt-in manual coin control for payments.  So, I think on the
one hand, that is always cool for actual power users that want to keep track
really for every single UTXO that they receive and spend, where it's coming
from, who knows about the ownership of that UTXO, what other context might be
available, and that want to be extremely deliberate about what they mix and
don't mix.  But in the long term, I don't think that is a viable scalability
strategy for privacy.  If you expect everybody to jump through these sort of
hoops, you just end up most people not doing any of it.

That's why I tend to think more about coin selection should work, so we can
hopefully automate most of that and have good standards for how wallets pick
transactions that have good privacy automatically, maybe even recognize context,
or allow you to label addresses when you receive, and then deduce context from
that.  But yeah, it's a long road, we'll get there eventually and meanwhile,
power users can do it manually.

_LND v0.16.0-beta.rc3_

**Mike Schmidt**: We noted one release this week in the newsletter, which is LND
v0.16.0-beta.rc3, and I know last week we mentioned that we were going to pull
in someone who could walk us through the features of this release, similar to
what we did with Core Lightning a few weeks back, and that is under way.  The
Lightning Labs folks prefer to jump on and talk with us about the features after
this is actually released, so we'll get them either next week or the week after,
and I think they'll provide a better overview of this release than we could.
So, I'm okay punting it again, Murch, if you are.  All right, great.

_LND #7448_

Speaking of LND, the first notable code change, LND #7448, adds a new
rebroadcaster interface to resubmit unconfirmed transactions.  Murch, why would
LND need to be resubmitting unconfirmed transactions to be broadcast?

**Mark Erhardt**: So, in the past few months, at this point, there's been a new
sort of demand on block space, and we've actually had a growing subset of
transactions that have not confirmed in a very long time.  We are now at over
916 MB of memory usage for mempool.spaces mempool monitor, which is clearly
slightly more than the 300 MB that mempools hold by default.  So, everything
below 4.99 sats/vB is currently being purged from the mempool, or from default
mempools.

So, what LND is addressing here is, when a transaction gets dropped from other
mempools, there is no mechanism for someone with a big mempool, such as
mempool.space, for example, that will get the transaction resubmitted to other
people's mempools.  So, having a bigger mempool is actually not helpful unless
you are a miner and are worried that eventually the mempool will be empty and
you will want to include transactions that you had previously purged, or that
default mempools had previously purged.

There has been work in the past on Bitcoin Core to make every node rebroadcast
transactions when they had transactions that they would have included in the
previous block, but didn't see in the block.  I guess that's just starting up
again; there was a break there in the author of those PRs not working on it for
a while.  But for LND concretely to solve their own problem, where the wallet is
responsible for keeping transactions in mempools and making sure that they get
rebroadcast if they didn't confirm yet, they are now adding this rebroadcaster
interface.

What is does specifically is, it offers the transaction to the connected full
node, and of course if the node already has the transaction, it will not
resubmit it to its peers, so there's no big privacy loss here.  But if the
attached full node has purged the transaction previously, but now the minimum
feerate of their mempool is low enough that it would fit again, the node will
accept it again from the LND and will of course also then offer it to its peers
again, since it's new inventory.

LND was doing this already when it was running in Neutrino mode, because in
Neutrino mode, it doesn't have a dedicated full node that it's talking to, but
can just communicate with any nodes that offer BIP157/158, which is the client
side compact block filters; and now also, if you have a dedicated full node,
every block it will try to resubmit unconfirmed transactions to that full node
and that full node, if it hadn't had that transaction but can accept it now,
will relay it.  So, this is a mechanism on how to get transactions back in the
mempool after they were dropped.

**Mike Schmidt**: Murch, do you have a personal preference or opinion on whether
this should be a wallet responsibility, or responsibility at the node level?

**Mark Erhardt**: I think I can argue both sides.  So, if it's a wallet
responsibility, you get the advantage that if you change your mind and the
transaction was purged widely from mempools, you can just not rebroadcast it,
but rebroadcast a different variant.  That plays well, even if you had signalled
finality on your transaction originally and you're mostly connected to a network
that respects the finality of transactions, aka doesn't do mempool full RBF yet.
It doesn't matter nearly as much if the whole network moves to mempool full RBF,
because then every transaction that just pays more fees will propagate.

So, if you change your mind, you can just write a new variant that conflicts
with the original, and whether it's been dropped from mempools of not, it will
propagate if it just pays more fees.  So, that's actually one reason why I think
mempool full RBF would be more useful now than it had been when it was
originally proposed, because with the extremely full mempools lately, I would
expect that more people have stuck transactions and need to rebroadcast them.
That's why it might have been better for wallets to have the ownership, or the
onus of making sure when a transaction gets rebroadcast.  The receiver also has
an interest of transactions going through because if they get paid, they want to
of course make sure that the payment goes through.  So, a receiver might also
want to rebroadcast transactions that pay them.

Finally, I think it would be a huge boon for privacy because of course, when a
wallet continues to rebroadcast a transaction, the nodes that are connected to
the node that serves the wallet will see that a transaction gets offered more
often than it should be from specific nodes, and they can deduce that the node
is connected to the original sender, or maybe receiver, of this payment
transaction.  So, if we instead move to a paradigm where every node, when it
sees that it has a transaction that should have been included in the previous
block but didn't get included, when it says, "Hey, that should have been in the
last block, let me rebroadcast them", that would lead to every single node doing
these rebroadcasts and thus getting much better privacy for sender and receiver
in that case.

So, in the long run, I would hope (a) that we just get away from opt-in RBF and
move to full RBF, where every transaction is just evaluated on the merit of the
fees that it is paying currently; and then (b) every node rebroadcasts every
transaction whenever they see that it should have been included.

**Mike Schmidt**: Thanks for elaborating on that, Murch.  Anything else on this
LND rebroadcast PR?

**Mark Erhardt**: No, I think that is all.

_BDK #793_

**Mike Schmidt**: Well, the last pull request that we highlighted in the
newsletter this week is BDK #793, and our special guest has been waiting 45
minutes to walk us through this PR.  So, without further ado, Alekos, what is
this major restructuring of BDK; what is the bdk-core project; and maybe just
give us a quick overview of BDK, how Core fits in, and maybe the evolution of
those two different pieces of software?

**Alekos Filini**: Yeah, so maybe I'll start from the last question, so what is
BDK?  BDK is a Rust library that can be used to build generic Bitcoin wallets.
And when I say generic, I mean generic in terms of policy.  So, when we were
talking about miniscript before, BDK uses miniscripts, so you can build a
wallet, I don't know, that is a simple singlesig; you can build a multisig; you
can build complex wallets where you have time locks and complex conditions.
This is what we mean by generic.  In theory, with BDK, you can build let's say
any kind of wallet that you want.  Obviously there are limitations, but that is
kind of the goal.  So, we want to maybe build a library that is very flexible
that can adapt to different use cases, like you’re building desktop wallets,
mobile wallets, or web wallet; we want to be able to do a bit of everything.

It's funny, we started in 2020, I think, so it's been being developed for two or
three years now, and at some point we realized that basically BDK would work
well for most use cases, for most users, especially users that don't need any
kind of advanced features, users that maybe don't even have a deep knowledge of
Bitcoin, they just want to build something simple.  For those users, BDK would
work well.  But as soon as somebody wanted to do something a bit more
complicated, some kind of more complex protocols, basically something that would
need a more low-level access, BDK would not work really well for them, because
BDK is this kind of simple API to use and if the API is good for you, that's
fine.  But if you need something more low level, you will not really be able to
do that.

The other thing we realized was that BDK was this kind of monolithic thing that
would do a little bit of everything.  So, when you think of a wallet, you have
many different components that work together.  So, for example, you have code to
monitor the chain so you can see when you receive funds; you have code to do
coin selection, for example; you have logic to create a transaction.  When you
construct a transaction, obviously you do coin selection, but on top of that
there's also some logic for setting the correct fields, the correct nlocktime,
nsequence, stuff like that, and BDK was just one library basically doing all of
this.  We also realized that maybe some people would be interested in using some
of these components, maybe not necessarily the whole BDK library; maybe somebody
is just interested in taking the code to monitor the chain for some project
they're building.

So for this reason, since we wanted to offer a more low-level access and since
we wanted users to be able to use individual pieces of BDK, we started this BDK
Core subproject.  It was kind of a parallel project that went on for a little
while.  So BDK, the library, was still being developed but in the meantime, some
other people, mainly Lloyd, LLFourn, they were working on this bdk-core concept.
The idea was to basically have different components that work together, but that
can also be used independently.

So at this point, I think bdk-core has been going on for many months, maybe a
year, I don't know exactly when it started.  At this point, we are confident BDK
Core, or let's say using the bdk-core components together would make a much
better BDK, because it would give users a lot more flexibility that would be
able to get more low-level access if they want to, while they could also keep
using the same old API if all these components were together.  So, they don't
necessarily have to use the low-level thing, they can also use all of them
together and just get an easy API.

So, this PR, this #793, was basically merging these bdk-core components within
BDK, so now the BDK repo is composed of a few different crates.  Crates is just
Rust language for packages.  So now, in the BDK repo, there are these bdk-core
components that you can use independently if you want, and then there's a BDK
crate which has been refactored to essentially use those components inside.  So,
if you are a BDK user and you were using the full library, the API doesn't
really change all that much.

There are improvements there as well that are kind of a consequence of the BDK
Core restructuring.  So, the normal BDK API is improving a little bit, is
getting more flexible, but it's mostly staying onchain, so for BDK users that
won't really make any difference.  But for maybe users that looked into BDK in
the past and, I don't know, figured BDK would not be for them because it was not
flexible enough or would not offer something, with this refactoring it would
maybe become useful for them, they could re-evaluate, because now they would get
this lower-level access kind of thing.

I think this is pretty much all.  I don't know if I've covered what you had in
mind.

**Mike Schmidt**: No, that was great.  Maybe a quick note from you about whether
it's new users or existing users of BDK, maybe the timing, and what you're
looking for in terms of testing or feedback on this.  What should folks do if
they're interested or they're using BDK currently?

**Alekos Filini**: Yeah, that's a good question.  So, I'm not super up to date
about the time when this is going to be ready and released, because the original
plan was to be ready at the beginning of this year, so this thing has been
delayed a little bit and as I said before, now I'm lowering my effort there, so
I don't know when this would be 100% ready.  But the fact that it's been merged
into Master, it means that it's getting there.  So now, mainly what we need is
testing and feedback from users.  What I would say is, if you're a user of BDK,
you could try switching to BDK to using Master instead of using the released
version and see what happens.  You are probably going to have to make changes to
the way you interact with BDK, which should be mostly minor changes, but I don't
know, if something goes wrong for some reason and you need big changes, let us
know.

So for current users, I would say just start to update and see what happens and
provide feedback.  For people who are considering using BDK, maybe just don't
look at the current released version, because currently the latest release is
still based on the old architecture.  So, maybe if you look at the latest
release, you think, "BDK is not for me".  If you want to spend some time, look
at this PR and look at the documentation around bdk-core because once this will
be released, I think it will be a pretty major change in terms of how powerful
the library will be, what kind of things it will offer.

**Mike Schmidt**: Excellent.  Murch, do you have any questions or comments on
this BDK PR and the bigger project?

**Mark Erhardt**: No, that sounds great, yeah.  So, the way I understood it is,
you basically have refactored the inner parts or the inner workings of BDK into
a library that you use yourself to still provide the old API of BDK; but now,
the library components themselves are standalone, usable by other people that
have needs that are more low level; is that a good summary?

**Alekos Filini**: Yeah, that's pretty much it.  So, most of the refactoring was
actually around the code that monitors the chain and the code that persists your
transactions, your UTXOs on disc so this is where we focus the most.  So there
are components that you can use; if you have a project that just needs to
monitor the chain, you can just use the components individually without having
the whole BDK wallet thing.

Then I think one other component was the coin selection, because before it was
kind of embedded within BDK, now it's a separate module I think, I'm not sure
about that, but that was one of the ideas with bdk-core.  So, if it's not there
yet, it should come soon.  And then, yeah, that is pretty much it, and then BDK
has been refactored to use those components internally.

**Mark Erhardt**: Great then, cool.  That's also impressive that you guys
managed to do that so quickly.  We've been working on this for Bitcoin Core four
or five years or so!

**Alekos Filini**: Yeah, I mean I think being a smaller project, obviously it's
much easier to iterate and move faster.  On Bitcoin Core, everything takes
longer.

**Mike Schmidt**: If anybody in the Spaces has a question, feel free to raise
your hand or request speaker access.  We did have one comment that I want to get
your thoughts on, Murch, which is someone saying, "CPFP is a crime against
Bitcoin".  Murch, what do you think about CPFP being a crime against Bitcoin or
not?

**Mark Erhardt**: I feel like that could use more context.  I think that
generally, there are different approaches on how you can change your mind about
transactions or reprioritize transactions.  So of course, RBF, where you just
make a conflicting transaction that has a higher feerate, is cleaner in that it
uses less block space, but then obviously can only be done by the sender; CPFP
is also available to recipients.  Either of them have a privacy impact in that
if somebody watches for what transactions conflict with each other, they can
probably guess if different inputs were used, that the inputs are also
controlled by the same sender or senders.  With CPFP, they will guess that
either the recipient or the sender attached their transaction, so they might be
able to glean more information on who the output went to in that regard.  I
don't know what else would be criminal about CPFP, so more context would help.

**Mike Schmidt**: Hey, Rijndael.

**Rijndael**: Hey, good morning.  I actually came up, I had a question about the
new BDK 1.0 architecture.  Really excited to see the refactoring happening.
I've written a lot of small processes that just use parts of BDK, but you kind
of had to create the whole wallet even if you didn't use all of it, so I'm
excited to be able to pick and choose components out of BDK to use.  Do you
think that the big refactoring is also going to have an impact on the APIs that
are exposed through the FFI layer to languages like Swift or Kotlin, or do you
think it's primarily going to be like a Rust component refactor?

I'm thinking about different projects that I work on that use BDK and trying to
get some sense of how much code we're going to have to go rewrite.  If it's
mostly just on the Rust side, that's kind of different than if those changes
flow through all the layers of FFI to get to something like Swift or Kotlin?

**Alekos Filini**: I think some changes will get to FFI as well, but it should
be mostly smaller changes, because I mean the FFI tries to mirror as much as
possible the Rust API and the goal here is not to change the Rust API too much.
But if we do change and one thing where it needs to change for sure is on the
syncing because again, most of bdk-core was focused around monitoring the chain.
So, syncing is a term we use in BDK for synchronising your internal state with
the chain, so if there are any transactions for you, you store them in your
cache.

So, the code around syncing will change a little bit, but really you can check
out the examples in the PR.  I think it's like four lines of code that needs to
change in Rust, and it's probably going to be more or less the same in FFI
because again, we mirror the API as much as possible.

**Rijndael**: Great, thanks.

**Mike Schmidt**: It doesn't look like there's any other questions.  Murch,
anything else that you would like the listeners to be aware of before we sign
off?

**Mark Erhardt**: I've found another way how CPFP could be a crime.  So, I know
of some Bitcoin developers that would much prefer if we weren't able to spend
unconfirmed outputs at all, so in that regard it might also be a crime!  All
right, no, I have nothing else.

**Rijndael**: Well, Murch, I'm sure you could do CPFP for PSBT offers in
ordinals and just piss off more people!

**Mark Erhardt**: If we're just looking to be angry about things, there's plenty
to go around!

**Mike Schmidt**: Well, thank you, Alekos, for joining us and talking about BDK,
thanks to my co-host, Murch, and thank you all for joining and participating in
Bitcoin Optech Newsletter #243, and we'll talk to you guys next week.  Cheers.

**Mark Erhardt**: Cheers.

**Alekos Filini**: Bye, thank you.

{% include references.md %}
