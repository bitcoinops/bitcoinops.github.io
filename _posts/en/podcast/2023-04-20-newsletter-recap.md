---
title: 'Bitcoin Optech Newsletter #247 Recap Podcast'
permalink: /en/podcast/2023/04/20/
reference: /en/newsletters/2023/04/19/
name: 2023-04-20-recap
slug: 2023-04-20-recap
type: podcast
layout: podcast-episode
lang: en
---
Dave Harding and Mike Schmidt are joined by Maxim Orlovsky to discuss [Newsletter #247]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/69137119/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-3-23%2Fb33e4579-60f7-5cce-0d2a-d57ab109cc54.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #247 Recap on
Twitter Spaces.  Some quick introductions and then we'll jump in to covering
this newsletter.  I'm Mike Schmidt, I'm a contributor at Optech and I'm also
Executive Director at Brink, where we fund open-source Bitcoin developers.  And,
Murch wasn't able to make it today, but the good news is Dave Harding was.  So,
welcome Dave.

**David Harding**: Thanks for having me, Mike.  So, I'm Dave Harding, I have
been the primary author of the Optech Newsletter for the past five years, and
I'm also currently doing an update on the book, Mastering Bitcoin, doing a third
edition.

**Mike Schmidt**: Awesome.  And, we're joined by a special guest today, Dr Maxim
Orlovsky.  Do you want to provide a quick introduction for the folks who may not
be familiar with your work?

**Dr Maxim Orlovsky**: Yeah, sure.  So, I'm from LNP/BP Standards Association,
which is non-profit, working on developing layer 2 and layer 3 protocols on top
of Bitcoin.  And one of the main things that we did over the last four years is
RGB, which became a smart-contracting layer, or programmability layer for
Bitcoin and LN.

_RGB update_

**Mike Schmidt**: Well, thanks for joining us, and we can jump right into the
newsletter in which we cover RGB, and specifically a post, Maxim, that you sent
to the Bitcoin-Dev mailing list.  And I know that the newsletter writeup is
covering this v0.10 release in your post to the mailing list, and I think we can
get into some of the details of that particular release.

But maybe taking a step back, you mentioned that you're part of the LNP/BP group
and RGB is one of the efforts within that group.  Maybe you can just provide a
high-level overview of what is RGB.  I think maybe some listeners are less
familiar with it.  I know that it's probably pretty common, that folks have
maybe heard of some announcement of RGB a few years ago and maybe haven't heard
about it since.  So, what is RGB?

**Dr Maxim Orlovsky**: Yeah, sure.  RGB appeared as an idea back in 2018, or
maybe even earlier than that, as a result of cooperation between Giacomo Zucco
and Peter Todd, who are well-known in the Bitcoin sphere.  Peter Todd proposed a
new concept, called client side validation, the whole idea of which was that we
need to move, and we can move, a lot of things out of block chain.  And by
moving a lot of things out of block chain, we can actually increase the
scalability and privacy at the same time.  Giacomo took that idea and he coined
a term of RGB as the colored coins on the LN, which were made possible by this
client side validation idea, literally meaning that, "Let's take the idea of
issuing assets on Bitcoin and LN and put it into client side validation
paradigm.  That's how RGB was born.

Later, in 2019, I joined the team, and together with Giacomo we created this
LNP/BP Association with the idea of bringing RGB into practice.  The end result
was that already, in 2020, the RGB started transforming into not just colored
coin or assets, because nobody was happy about just doing a layer for new
shitcoins on Bitcoin, but into a programmability layer for Bitcoin and LN, which
may allow advanced forms of smart contracts, and advanced forms of
programmability, as well as increased privacy for Bitcoin operations.  And we've
been developing this for years and we've had a number of iterations, and that
last iteration you mentioned, which went live literally a week ago, allows
full-fledged things.

So, anything people are doing on smart contracts on other block chains is now
possible to be done in Bitcoin and LN, but without the need of introduction of
new tokens.  So, many things can be done with pure Bitcoin and LN, which
actually wasn't possible before.

**Mike Schmidt**: We went through an example in the newsletter writeup, about
Alice and Bob and Carol and Dan issuing tokens and parsing them around between
themselves, some examples being onchain transfers, and then also in the last
example between Carol and Dan doing offchain transfers.  Can you maybe enlighten
folks, when these tokens are being exchanged offchain, is this using a separate
protocol from LN; is it a modified LN implementation; or, can you explain a
little bit how that works for me?

**Dr Maxim Orlovsky**: Yeah, I'll try.  There are a number of things which are
separate from each other we need to go through in order to answer this question.
The first thing is that all the tokens, and not only tokens, but any one of the
smart contract states, because many of the smart contracts, they do not operate
with tokens, they have different forms for the state, all this exists on the
client side meaning that it is kept by the client the same way as clients keep
private keys or wallet descriptors, meaning that if they lose their data, they
will lose their assets and they will lose their smart contracts.

So, this is what client side validation is about.  Users keep this data and they
share this data outside of block chain.  But by which means do users share the
data?  Well, RGB doesn't care about that as a protocol, it is abstracted from
the question of the way how the data is sent from one user to another user.  And
it is able to work with different ways of sending the data.  As of today, we
already have at least two of them.  One is using some form of relay servers,
called RGB RPC; and the other one is based on LN, which allows to share the data
through the LN.  We have created a dedicated protocol, called Storm, which
provides a data layer for LN and it operates on top of LN, and you can do that
to send this data in a more decentralized fashion.

Also, we think that it would be possible to share client side validation data
through nostr, or other systems, and at the end of the day, they can be sent
between users as just the plain files, inserted into emails or chat messages.  I
hope that answers your question.

**Mike Schmidt**: Yeah, I think so.  I'll follow-up with something that you
mentioned in your explanation, which is these different types of smart contract
that don't involve tokens.  So, I think our writeup involved tokens, but also
noted that there's other use cases; I think folks are familiar maybe with
colored coins and the fact that you can issue these tokens.  What are some
examples of use cases that you are excited about that don't involve additional
tokens?

**Dr Maxim Orlovsky**: I tried to cover the most exciting use cases for RGB in
the very last answer in the Bitcoin-Dev mailing list.  I will briefly go through
that.  The most exciting tokenless applications are the following: the first one
is the digital identity.  In the world of web of trust, one of the main problems
which wasn't fully solved was the procedure of key revocation.  There was no way
how somebody can revoke his key, and afterwards that everybody is able to
instantly see that fact, and also prove that the key was indeed revoked, because
if the information about the key revocation is not published, it isn't possible
to detect this fact.

With RGB and single-use seals, which are used by RGB, for now the key revocation
becomes fully provable and undeniable, meaning that once you revoke the key, it
is known to the whole world and it is also impossible to prove that the key
wasn't revoked.  This is for example one of the cases that RGB does without
involvement of any tokens or even bitcoin as a coin itself.

Another example might be thought of with DAOs, which are Decentralized
Autonomous Organizations also run in a tokenless way.  And the DAO being
different voting rights, which can be executed by different people, and the
difference of this DAO from any other DAO is that with RGB you can prove that
the whole history of the DAO operations is unique.  You can't do that with the
OpenTimestamp-type systems, because when you do OpenTimestamps, you can create
alternative commitments.  So, while you can prove that something, some fact, had
a place in the past, you can't prove that an alternative fact hasn't had a place
in the past, because you can create alternative commitments.

With RGB, you can have a whole history of events, which can be proven to be
unique without any other alternative history.  It uses the same mechanism it
uses to provide the double-spending, and the same mechanism is leveraged to
create non-doubled histories of events, and that allows a new type of DAOs,
which were not possible on the Bitcoin ecosystem before.

There are also many interesting financial applications now around RGB, like the
whole area we call Bitcoin finance, which appears from the merge of RGB and LN,
together with such things as Storm, which I mentioned before.  Here, you may
introduce some tokens, but these tokens would be more traditional forms of
financial contracts, like options, futures, which are quite crucial for any
large economic systems, and you can organize trade with these tokens, including
decentralized trade, decentralized exchange, creating derivatives or basing of
different forms of smart contracts, and doing things like automatic
market-making and crypto-collateral-based derivatives.

So, that's quite a lot of things which may happen due to RGB.

**Mike Schmidt**: It's a bit fortuitous that we have Dave Harding, who's joined
us today, as not only did he do the writeup for the newsletter on this topic
this week, but he also engaged in the mailing list discussion.  So, Dave, I've
monopolized the questions so far; perhaps you have some clarifying comments and
questions for Maxim?

**David Harding**: I'm just here to learn.  I guess one question I have for
Maxim is, one of the things I noticed looking through your code, at least the
code from the LNP/BP Association, and I may be looking at the wrong code, is
that you guys use Electrum backend a lot.  And when I was thinking through the
protocol, it seems to me that it's something that requires random access to the
entire block chain.

So, a traditional Bitcoin wallet can use something like an Electrum backend and
it's really convenient in that case.  That way, it can go and just ask the
Electrum Server to give it any output from any previous transaction, and I'm
saying this for the listeners, I know Maxim knows all that stuff.  The downside
of that approach is that the person who runs the Electrum Server has to go
through the entire block chain, has to maintain a copy of the entire block
chain, has to build a very large index of every output in the block chain; and
over time, as the block chain grows, there's just more and more data that they
need to store, their index gets bigger, they need a beefier server.

One of the things that Bitcoin developers, when thinking about the regular
onchain protocol, have done is try to make sure we continue to design a protocol
in a way that we don't depend on something like Electrum servers.  So, a
self-custody wallet today can use something like BIP157, 158 compact block
filters, and they can just grab these small filters for the entire block chain
and they can find which block contains a transaction they have.  And those other
things that they can do suggest minimizing the amount of data that they need.
And any wallet that scans to a block can just lose that block, so a pruned full
node can have a wallet without storing any historic block chain state.

So, one of my questions here for Maxim is, when I look at the RGB protocol, it
feels to me like it might depend, or at least certain applications depend on
having random access to the entire block chain state.  Is that actually a
requirement or am I just making that up; and what are the implications for the
scalability of the protocol?

**Dr Maxim Orlovsky**: Thank you very much for looking deep inside the code
actually on the writeup that you've done, I think it's great.  You were able to
explain things in more simple words than I was able to.  Now specifically to
your question, no, RGB do not depend on Electrum.  It is true that the current
library they default to, Electrum implementation, why?  Well, because it's the
most commonly used infrastructural thing, but the whole code of RGB is
abstracted from a specific, we call it transaction resolver, through the
interfaces, and RGB does the verification interacting with the transaction
resolver provided by specific wallet implementations, such that the user has the
ability to change the transaction resolver.

Technically, the information we need from Bitcoin block chain can be provided
today by three main backends: Bitcoin Core itself, or any alternative coin
implementation that exposes Bitcoin Core RPC API; Electrum Server; as well as a
modification of Electrum Server, called Esplora, made by Blockstream, which
provides HTTP interface as well, which is more efficient than the usual Electrum
interface.

We are also working on a thing called BP Node, Bitcoin Protocol Node, which will
be a new type of indexer capable of providing much faster responses to the
requests from wallets on both Bitcoin-related things, LN-related things and
RGB-related things, such that for instance you can ask this backend to monitor a
specific wallet descriptor, which includes some complex miniscripts, timelocks,
and so on, and it will be updating you about new transactions happening to that
descriptor.

However, BP Node, it's a rust project, it's still a work in progress, so it's
not been released.  But potentially, it will be one of the best ways of being a
backend for] block chain indexers for RGB as well.

**David Harding**: Okay, so just to follow up, and I know this is not
super-important, I'm just curious here and we have you on the line, so I'm
thinking about one of your recent emails, you had these things called state
extensions you were describing, that are kind of disconnected from other
contract states.  They're published on the chain, or they're committed to
onchain, but they're disconnected, I believe, from the rest of the contract
state.  And in the example we were talking about on the mailing list, we have a
party who needs to do a proof of publication, that they were the first to find a
result.  So, they need to publish something onchain to establish its time point,
if you will, when it occurred that they were the first to do this.

It just seemed to me from that perspective that a later client, who needs to go
back in time and validate the history, is going to need to look through the
entire block chain to see if anybody else published something first.  And for
that, I think you would need complete access to the block chain.  And for it to
be fast, when the block chain is several hundred gigabytes, you'd kind of need
this random access.  Am I missing something; is this just because it's a special
case, so most RGB wouldn't need to do this, but in a special case you might need
to do this?  Could you help me think through this?

**Dr Maxim Orlovsky**: Yes, sure.  Let me start with state extensions.  State
extensions are the way how an open public unknown set of participants may
participate in an existing RGB contract.  Their introduction allowed us to move
from the concept when only existing, pre-defined set of participants participate
the contract into an open set of participants, which may be important for the
cases which you mentioned.  And in fact, these state extensions are disconnected
from block chain; they do not require any onchain event to happen.  However,
anything produced with the state extensions are not final until one of the
contract participants has included the state extension produced by somebody else
into the history of the contract; and by doing this inclusion, basically linking
it to block chain state.

The second part of your question is actually unrelated to state extensions, and
it was that you can construct RGB contracts which use onchain events as a way of
signalling something.  And this is actually because in my reply, it was put
together with state extensions, but in fact these two things aren't connected;
you can have onchain signalling without state extensions as well, and you can
have state extensions without any form of onchain signal.  And yes, you're
right, that onchain signalling may require random block chain access.

But the reality is that it is up to the contract creator and developer to choose
a specific form of onchain signalling.  RGB at its consensus level doesn't
require onchain signalling and doesn't provide a default way of onchain
signalling.  Thus, it will be up to the contract creator to select a form of
onchain signalling which will be efficient in terms of both speed and time,
otherwise this contract wouldn't be used much by the users, because it will be
slow or not working with the Electrum backend.

So, with this BP Node, I was mentioning of course one of the things we will be
providing is more efficient block chain indexes which allow this random block
chain state access.  And with this, probably a thing we could fast-forward
updates to RGB; it's a way how you can introduce new functionality into RGB
protocol.  We will have more functions which allow introspection of the Bitcoin
block chain.  Also, the current version, v0.10, there is no random block chain
access in RGB allowed.  However, with one of the future updates, the random
block chain access will come, which will enable this form of signalling, and the
specific forms which will come will depend on our progress with the BP Node and
efficient block chain indexing.

**David Harding**: That answers my question very well, thank you.  Mike?

**Mike Schmidt**: So, the announcement from the mailing list talked about this
v0.10 release.  I think a lot of this discussion on RGB, at a high level, is
important for folks, but I also didn't want to miss anything that you thought
was notable for folks about this v0.10 release at a high level, so maybe give an
opportunity to tell folks what's updated and what they should consider if
they've used previous versions, etc.

**Dr Maxim Orlovsky**: Yes, sure.  V0.10, probably one of the largest changes in
RGB, which we've been working on for more than half of a year, and it also
includes some functionality which we thought and contemplated for several
previous years.  Specifically, this release allows a thing we call interfaces.
Interfaces fully abstract the functionality of the smart contract such that now,
when you have a wallet supporting RGB and somebody does a non-standard smart
contract, the users of the wallet do not need to update their software to use a
new kind of smart contract.  What they can do is that together with the
contract, they import an interface and implementation of the interface created
by the contract developer, and now their wallet supports new forms of the
contract.

So, it allows you to do very advanced stuff, not being blocked by the vendors,
by the wallet developers, by us as an association defining some sort of
standards.  Any independent developer can do whatever they like with RGB without
asking permission, filing a standard, or talking to wallet developers.  And it
will be up to the end users, who will be installing this contract, reading who
did this; and if they trust the developer, they can plug in this interface
thing.

Other very important news is that now you can write RGB smart contracts in rust,
and you have access to a rich type system.  The state of the smart contract can
be any complex data type you can write in rust, and then you can compile this
data type into your smart contract.  I think this is also quite a huge step
forward.  We are working on a special programming language, called Contractum,
which is a Haskell style functional language to programme RGB smart contracts.
But the compiler is not yet released and before this language is created,
actually writing smart contracts in rust is the main way we assume smart
contracts will be written.

There is another one which you can use at low-level assembly, called AluVM
assembly, but this is much harder than rust, so probably rust was quite a big
innovation.

**Mike Schmidt**: One follow-up question.  So, we talked about this latest
version, we talked about the history of RGB; can you comment briefly on the RGB
project's roadmap, maybe just a few things that you're looking forward to and
near-term releases?

**Dr Maxim Orlovsky**: Yes.  RGB is made in layers.  So, the main layer of RGB
is the consensus layer, which we tend to move towards specification, so less and
less things would happen with the consensus layer.  And the thing that is
released in v0.10 is the most stable release we had so far.  There are not many
things going to happen there, but for sure some of them will be evolving in the
future, including the one that we already mentioned, which is random block chain
access.  There will be also an access to the state of the LN channels, and there
will also be a more advanced use of zero-knowledge proofs, including
Bulletproofs++, rangeproofs and including potentially zero-knowledge-based
compression of the history of the contract.

That's pretty much everything that may happen in this layer, and the main
innovation with RGB would be happening on the layer above, which is a standards
library and wallet integrations, where we plan a tool chain for the developers.
And the most exciting things there are first more deep and advanced integration
of RGB with the LN, which will allow doing many, many things not possible
before.  This also requires some changes and improvements to the LN protocol
itself, we are working on them, and they are naming this extended version of LN
protocol Bifrost.

It is important to get things like multi-peer channels working.  We also work on
channel composability, such that you can construct channels inside channels
inside channels.  That is more than channels factories, because the structure of
the channel itself will be composable of different components, like you can add
discreet log contracts (DLC) outputs to the channel, or you can use non-standard
type forms of outputs and so on.  So, it's a standard protocol that adds this
composability to LN channels.  Combined with RGB, it will allow multiple
channels, which can operate in a very fast and efficient way with RGB smart
contracts offchain, not requiring mining transactions for those complex
operations.

Another thing we are excited about is this Contractum language and Contractum
compiler, which should help people to write RGB contracts and start exploring
this new world.  And the very last thing that is worth mentioning is that in a
very long-term perspective, it would take years for sure from now, we are
working on the creation of a new layer 1 medium; I don't want to call it block
chain because it's not actually a block chain anymore.  It's a way how you can
run client side validation with a layer 1 in the most efficient way, where
instead of block, you have one signature which includes a lot of commitments.
And of course, this layer doesn't feature any coin, any cryptocurrency, nothing
of that sort.

With that, as I described in my latest reply to Bitcoin-Dev mailing list, it
would be possible for RGB to operate both on Bitcoin and this new medium, such
that Bitcoin can be lifted or moved into RGB from the mainchain, and operating
on the new medium with this client side validation, which will unlock much
larger scalability that is possible with block chain, or even with the LN today.

**Mike Schmidt**: Dave, any follow-up questions before we move on?

**David Harding**: I just wanted to see if Maxim wanted to provide a little bit
more detail on their plans for confidential transaction-based amount blending,
because I thought that was actually really clever when I read about that, how
they're going to use that to improve privacy.

**Dr Maxim Orlovsky**: That's already used.  So, what we are using is we are
using this technology developed by originally the Blockstream guys, which is
confidential transactions, where we use Pedersen commitments to hide the amount
of the asset.  Together with the Pedersen commitment, we have to use a
rangeproof, so we stick to bulletproofs.  It was in RGB until this version.

In this version, for now we're temporarily not creating bulletproofs, and we
still use Pedersen commitments, but the data are kept in the explicit amounts
such that when a new bulletproofs version, which is Bulletproofs++, will arrive,
we will be able to pack the history and blend all past data with this new
Bulletproofs++.  So, that will be one of the next updates of RGB.

We are waiting for Bulletproofs++ to be finished, because they are not finished
in the implementation, it's just a paper which is being implemented by
Blockstream as of today.  And when that implementation would be completed, we
will be able to migrate all existing smart contracts on the use of bulletproofs,
and the confidential transactions will become the default way of parsing amounts
around, and also they will be applied to all historical data as well.

**David Harding**: Yeah, so I thought that was really cool, when you have one
party giving a future party the past date.  They don't have to tell the future
party anything about the specific amounts transferred in the previous states.
So, if Mike gave me some tokens or some lifted BTC and I gave it to Maxim, Maxim
would have no idea how much Mike and I transferred.  Maxim would still be able
to do a full validation of the client side validation of the previous state
transfer to make sure everything was correct, but he wouldn't learn any of the
amounts.  I thought that was really, really awesome.

I have one last question, and a kind of general question for Maxim, which was
when you're working on an RGB contract, how much do you need to be aware of how
the protocol works at the base layer, so the Bitcoin protocol?  I'm thinking
kind of in comparison to say an Ethereum developer writing a contract in
Solidity, and not really thinking through everything, so their contract is
exploitable by a miner's trackable value, or these other things that happen in
Ethereum, because you think the entire contract is the code that you're writing
in Solidity, or whatever.

If you're writing an RGB contract, do you need to be very aware about how UTXOs
happen on Bitcoin, how reorgs happen on Bitcoin, what miners do for transaction
selection; or, when you're writing an RGB contract, can you just write the code
and as long as your code is good, it's going to work?  What's your take on that,
Maxim?

**Dr Maxim Orlovsky**: One of the things we're constantly thinking about is not
to repeat Ethereum's story and not to create Ethereum 2.0 on Bitcoin.  Well,
time will show if we have succeeded in that or not.  Of course, I think it's
impossible to do a system which is absolutely safe, such that somebody dumb or
with bad intentions wouldn't be able to do something wrong with that; I think
nobody is protected from this.  However, what we tried to do is that, as you
asked, when you develop RGB contracts, you don't have to think about reorgs and
low-level things in Bitcoin block chain itself.  They're fully abstracted and
the system operates in the same way for all the smart contracts, so all the
validation of onchain data is performed exactly the same and you don't program
that part.

Another thing that we did to improve the readability and make recording more
simple, is that we have these languages that we are developing, they are
functional style, meaning that they're more declarative rather than imperative.
And when you use a declarative model of programming, it's much harder to do
something wrong.

The last part, which is very important, is that we very clearly define the
concept of ownership of the state or the date.  One of the main pitfalls of
Ethereum is the use of an account-based model, such that when you write a smart
contract, you must always make sure that you check who is the owner and who has
the right to perform and execute that or that operation, and how this operation
should happen.  And people are frequently forgetting about making these checks,
or making them in an improper way.

With RGB, you are not worried about that, you don't do that because everything
is linked to the UTXO, and the UTXO actually defines who is the owner, and only
the owner has the right to perform operations, and that right is not checked by
RGB itself, it is checked by the fact that you are able, as an owner, to spend
that UTXO with a Bitcoin transaction.  So, in this way, we're just literally
leveraging the existing Bitcoin as a state-ownership system, not reinventing the
wheel and not doing anything of the sort that Ethereum had to do with this
account-based model.  So, this is the good point.

The bad thing about that is that of course it requires a huge product change
when you try to develop something with RGB.  You can't just come from Ethereum
and Solidity world and write RGB contracts, because it's not that you can't
cross-compile Ethereum to RGB, even more you can't develop the contracts using
the same paradigms that are used to develop contracts in Ethereum.  So, that's
one of the reasons why people frequently say that something is not possible with
RGB and will try to apply the same logic of Ethereum to RGB and Bitcoin.  Of
course, it wouldn't be possible because with that logic, it is not possible by
definition.

However, it is possible if you change how you see the state management, the
smart contracting, and when you move to a new programming paradigm, many things
become much simpler but they don't require a lot of effort, like in Ethereum.
Many cases, when in Ethereum, you need to create a token; here, you don't need
to do that.  And where in Ethereum, you need to control the access rights, here
you don't need to do that, and so on and so forth.  So, that's probably the
recap of programming on RGB.

**David Harding**: Thank you.

**Mike Schmidt**: As we wrap up here, Maxim, if folks are interested more about
RGB and potentially contributing, and maybe even potentially donating to the
project's efforts, where would you direct folks?

**Dr Maxim Orlovsky**: Well, I think the main place to read about the technology
is rgb.tech website, which we will be keeping updated.  Of course, the best
place to contribute and to go deeply is GitHub, RGB-WG, workgroup organization.
There is also a way to donate through GitHub, but GitHub takes its share.
Another option is just to connect to us, send an email to info@lnp-bp.org, and
we will provide you a BTCPay Server address and stuff like that.  So, the best
way to contribute, go to GitHub; the best way to learn, go to rgb.tech.

We will also be releasing a whitepaper we called blackpaper as a joke, because
comparing to existing whitepapers, it doesn't offer any token, it doesn't
contain a lot of marketing information, and is very focused on the
confidentiality.  So, that's why it's a blackpaper, which would be probably the
main resource, once it's released, to learn RGB in-depth before starting to
contribute to the codebase.

**Mike Schmidt**: Well, thank you, Maxim, for joining us to explain this news
item and all things RGB.  Hopefully, we can keep you on for just a minute
longer, as I think this next update does involve some work that you or your team
has done.  So, if you hang on for just one more minute, we can get your comment
on that.

**Dr Maxim Orlovsky**: Sure.

**Mike Schmidt**: The next segment of the newsletter this week involved our
monthly feature on changes to services and client software, where we look around
at the ecosystem and see what wallets or services or libraries are implementing
interesting Bitcoin technology that we cover on the Optech website.

_Descriptor wallet library adds block explorer_

The first entry is descriptor wallet library adding a block explorer, and
coincidentally descriptor wallet library is affiliated with some of the work
that Maxim has been doing.  It's a rust descriptor-based wallet library that
builds on rust-bitcoin and supports a bunch of cool Bitcoin tech, including
descriptors, miniscript, PSBTs, and in the most recent couple of releases, a
text-based block explorer.  Maxim, maybe you can briefly explain descriptor
wallet library and the block explorer that was recently added?

**Dr Maxim Orlovsky**: Yeah.  Descriptor wallet library is the library we did at
LNP/BP Association, so we had basically three main directions: Bitcoin
implementations of libraries; LN implementations of libraries; and, RGB.  It was
created to be used by RGB and LN implementation we also had, and this new
version, it brings ability to parse separate specific control blocks, because we
found out that it is impossible with any existing Bitcoin explorer today,
including mempool, to look into the witness data of the taproot path script
spendings.  And for developers, it's quite crucial to understand what's in
there.

This comment line too is pretty simple in terms of user interfaces, but what it
allows you is you just parse the transaction ID and you can look into taproot
witness details, which can be very helpful for those who work with taproot.

**Mike Schmidt**: Dave, any questions or comments?

**David Harding**: No, that just sounds like an awesome feature set.  The way
I've been doing that is just by hand-parsing the hack, so it will be very nice
to have a tool to do that for me.

**Dr Maxim Orlovsky**: Glad to help.

**Mike Schmidt**: Maxim, you're welcome to stay on and comment on the rest of
the newsletter as we go through it, but if you have things that you need to do,
you're free to drop as well.

**Dr Maxim Orlovsky**: Thank you, I'll stay online.

_Stratum v2 reference implementation update announced_

**Mike Schmidt**: Next change to client and service software that we noted this
month is Stratum v2 reference implementation update announced.  We haven't
discussed Stratum v2 too much on this show previously, so it might make sense to
give a quick overview of Stratum v2's features.

So, there's a Stratum v1, which is essentially a protocol for facilitating
communication between miners and mining pools, and that v1 has been out for a
long time, and there's this v2 that is being worked on currently.  Some
improvements for v2 include that the v2 is actually a more standardized protocol
when compared to Stratum v1.  Stratum v1 was less precisely defined, and it
resulted in different implementations having semi-compatibility with one
another, so v2 helps tighten that up a bit.

A second feature is one that probably most people are excited about when they
hear Stratum v2, which is the ability for an individual miner within a mining
pool setup, as opposed to just the centralized pool operator, being able to
select transactions to include in the candidate block.  So, I think that's what
most people are excited about, but there are some other improvements as well:
default encryption and using the Noise protocol authentication for protection
against man-in-the-middle attacks; there's some performance improvement,
including data transfer optimizations; and finally, v2 is being rolled out in a
flexible way, allowing a variety of different configurations, including
involvement of Stratum v1 mining devices to be able to participate in certain v2
Stratum setups.

The latest post, which is the one we highlighted in this segment of the
newsletter, is about a new Stratum v2 reference implementation, and that
includes the piece that I mentioned previously a minute ago about individual
miners' ability to select the transactions that would go into a candidate block.
So, if you're a miner or part of a pool or a firmware maker, you should be
looking at this and be being able to provide some feedback to the project,
because they note in this post that feedback will, "Have a high impact on
the development direction".  Dave, any thoughts on Stratum v2 and this reference
implementation?

**David Harding**: Well, you can put me for one of the people who just loves the
idea of enabling miners, the people who actually provide the hashrate, to choose
the transactions that are being included in the blocks, not leaving that to a
pool-level decision.  And one of the things that is really nifty about that,
that I don't hear often much, is that it may actually slightly improve the
pool's profitability.

One of the reasons for that is the miner who finds a block in the existing
protocol, where they don't choose the transactions, they have to send the
winning hash back to the pool, the pool has to add that to the block template
they created, and then the pool broadcasts out that block.  Whereas, if the
miner is running a local a node and they're using Stratum v2, when they find
that winning hash for the block, they can broadcast that block directly.

They also send the hash back to the mining pool, and the mining pool does all
the things I just described, but the miner who finds the winning block can be
the first one to broadcast it; it removes a little bit of latency.  We're
talking for a typical miner somewhere between 50 and 100 milliseconds probably,
maybe a bit less.  But that's a somewhat significant amount when we have an
average of 10 minutes between blocks; you can do the maths.  I think it will
improve profitability by maybe 0.01%, somewhere around that order.  But it's
something when a block is worth $50,000, or I don't know what they're worth now;
$100,000.

It's just really nice that miners and pools have worked together on this and
that there are people out there sponsoring this, like Square, etc.

**Mike Schmidt**: Thanks for adding that point, Dave.  That's something that if
I had heard about it previously, I don't recall that, so it's an interesting
additional benefit.

_Liana 0.4 released_

The next piece of software that we highlighted in this month's coverage is Liana
0.4 being released.  We covered the 0.1 and 0.2 releases previously, and to just
give a quick recap of what Liana is, it's wallet software that features a
recovery key.  And so, the typical case for this might be if you lose access to
your keys, for whatever reason, you can have some sort of a fallback for that
that includes a timelock, so that if that's a different set of keys, that that
group of people cannot move your bitcoins until some sort of a timeout has been
reached.

They've been iterating on this approach for the last few releases, and this 0.4
release allows the possibility to configure additional timelocked recovery
paths.  So, an example from the blog post that we linked to would be, "Let my
funds only be spendable by myself for one year and if they don't move for a
year, let them be spendable by my spouse and children, along with an attorney.
Then, after a year and three months without the funds moving, let them be
spendable by my family alone".  And the Liana team notes in the writeup that
that would obviate any potential attorney that is non-compliant or inaccessible
or malicious, by having a second fallback to just have the family be able to
move the coins after an additional timelock.  So, that's interesting.  Dave, did
you get a chance to look at the Liana release?

**David Harding**: I did not, I just quickly skimmed the notes while you were
talking.  One of the things that I would quickly mention here, which is not
Liana-specific, but as the ecosystem rolls out support for descriptors and
miniscript, it's going to be a lot easier to make these policies portable from
one wallet to the next.  So, you'll be able to have a tool, like Liana, that
helps you choose these policies, helps you build these policies with a nice user
interface, etc, and then you're going to be able to copy that into a different
wallet.  And those wallets might share a path, or they might not share an HD
path, they might be completely separate, but I think that we're looking at a
future where we're going to have more access to these sorts of simple policies
for defining how to use your coins, and it's going to make everything so much
more robust when it comes to the security of your bitcoins and safety of your
bitcoins, across life events.

_Zeus adds fee bumping features_

**Mike Schmidt**: The next notable software release was Zeus adding fee bumping
features, and this is in Zeus v0.7.4, adding fee bumping using both RBF and
CPFP, and that includes for regular onchain transactions, but also including LN
channel opening and LN channel closing transactions.  This update includes a lot
of the plumbing for a bunch of different backends, but the first implementation
here being LND.  And I messaged Evan Kaloudis, who works on the Zeus project, to
make sure I understood accurately what was going on, and he confirmed that
typically this fee bumping uses RBF, but it can also use CPFP in certain
situations.  So, there's some logic and flexibility in these fee bumping
scenarios.  Dave, any comments?

**David Harding**: Fee bumping is great, it's something that we need in the
future.  Did we skip the Coldcard update?

**Mike Schmidt**: Yes I did, unintentionally, and of course Rodolfo's here and
I'm embarrassed!

_Coldcard firmware supports additional sighash flags_

Yes, the Coldcard firmware supporting additional signature-hash (sighash) flags.
So, to set the stage, a sighash flag is something that you can use to indicate
which part of the transaction is signed by a signature.  Most typically,
SIGHASH_ALL is the sighash flag that's used, which is, "Sign all inputs and
outputs".  But Dave, maybe I can throw a question to you: what's an example
usage of a sighash flag that isn't SIGHASH_ALL?

**David Harding**: There's two other main flags, one is SIGHASH_NONE, which by
default, if I recall correctly, only signs the input to the transaction, it
doesn't sign any of the outputs.  Then there's SIGHASH_SINGLE, where the
signature only covers input that adds it and the corresponding output.  So, if
you use SIGHASH_SINGLE on the second input, it also covers the second output.
And there's a modifier, called SIGHASH_ANYONECANPAY, which just makes this all
more complicated.

A SIGHASH_SINGLE is really interesting, and it's something that they're actually
using in LN right now.  What you can do with it is kind of do multiple
transactions together.  So, you have an input that, let's say, contributes 1
bitcoin to a transaction, and you expect to receive 0.9 bitcoin in change.
Well, you'll just make sure your input and your change are in the same position
in the transaction, and the other 0.1 bitcoin that I contribute can be spent by
any of the other outputs.  So, you can take this transaction, you can hand it to
somebody else and you can say, "Hey, look, you pay fees".  Now, 0.1 bitcoin is
way too much for fees, but you get the idea there, that you can just parse
around these transactions and your parts are protected by your signature; nobody
can take that transaction and prevent you from receiving that 0.9 bitcoin.  But
they can also go and add their own inputs and outputs.

_Utreexo-based Electrum Server announced_

**Mike Schmidt**: The last piece of software that we highlighted in this week's
newsletter is Floresta, and this is an Electrum protocol-compatible server that
uses utreexo on the server side to decrease the server's resource requirements.
And right now, we noted in the newsletter that this software currently is only
supported on the signet test network, but I think we can breakdown a couple of
pieces of the technology that are in this project, the first being utreexo,
which is an alternative to storing the entire UTXO set, and instead you store a
merkle tree that's updated after each block.  That has some significant
decreases in the amount of disk space needed to run a node.  So, this project
has married utreexo with the Electrum protocol that we discussed a bit earlier,
which is a client server protocol that allows lightweight wallets to connect to
a server that can provide information that supports that light wallet's
operation.

Something notable from the blogpost that introduces this project is, it sounds
like they initially set out to create a node that also included a wallet, but
realized that there's a bunch of work and overhead with creating and maintaining
a wallet, and instead decided to create a utreexo-based Electrum Server, and
then let folks use whatever wallet they wanted that could speak the Electrum
protocol.

The project also noted that it required significantly less disk I/O and disk
space, even more so than a pruned node using Electrum Personal Server.  And
another thing notable from their blogpost is that they noted if you're okay with
the trade-offs of assumeUTXO you can actually have assumeutreexo full node
running on your smartphone.  So, I thought that was interesting.  Dave, what are
your thoughts?

**David Harding**: I think I should have clicked on this earlier.  I'm a little
confused how it works, but I think this could be a really nice thing.  So, it
looks like it's kind of a replacement for, or an alternative to Electrum
Personal Server.  That's a little client that you run beside your Bitcoin full
node that finds just your transactions using Bitcoin Core, and serves them to
you over the Electrum protocol.

So, if you want to run a full Electrum Server, as we were talking with Maxim
earlier, or something like Electrs, or whatever, you have to build this really
beefy index.  I think your Bitcoin Core client plus your Electrum Server, you're
probably looking at at least 1 TB of data, maybe it's 2 TB now, I don't know
what it is.  With an Electrum Personal Server, you just store the data related
to your transactions, so it's basically the size of your wallet on your full
node, so it's very efficient.

One of the problems with Electrum Personal Server is if you decide to, in your
client wallet, load a new wallet that has history going back before the current
block, you kind of have to go through the entire block chain again and scan
things, and that's especially painful for a pruned node.  But if you have
utreexo, you might be able to request out to another utreexo server, they have
names for these, I can't remember what they are, but a data server and utreexo
protocol, and they can provide you just the information you need connected to
the utreexo root.  So, it would be fully authenticated data, your full node will
have verified every transaction in its history; you'll know this data that
you're receiving from the server you're calling out to is correct and valid, so
there's no S2X fork going on there.  But your utreexo-based Electrum Personal
Server will be able to serve your wallet data.

Again, I'm a little confused from this announcement exactly how it works, so I'm
going to have to look at it in detail, but I think this is pretty cool.

**Mike Schmidt**: They do mention that when you first connect your wallet to the
server, the bitcoin balance will show up as zero, and that's even if you have
bitcoins in your wallet.  That's because this Floresta tool doesn't keep an
address index, like Electrum or Electrs; you actually need to provide the
wallet's xPub to the server to create an index for your UTXOs.  But I'm sure
there's a bunch more detail as well in there, so check out the GitHub, check out
the blogpost to learn more, but it's interesting.  And for folks who are curious
more about utreexo, look back a couple of episodes and we had Calvin Kim on
talking about utreexo and some of the details there that could be informative
for you.

_BDK 0.28.0_

Moving on to the releases and release candidates section of the newsletter, we
have BDK 0.28.0, which we've covered in the last slew of newsletter updates, but
this is not an alpha or test release, it's the official BDK 0.28.0, and we
actually had Alekos on, who gave us a great overview of BDK 0.28.0 and some of
the bdk-core work that has been going on and the changes to the project as a
result of adding that bdk-core functionality to BDK itself, so look back a few
episodes.  I don't have the number on hand to get a more detailed breakdown of
this particular release.

**David Harding**: Just to clarify, I don't believe this release includes the
bdk-core update.  I think this is still from their mainline branch and it's just
a maintenance release.  So, some of the underlying libraries from the
rust-bitcoin project changed how they did stuff, and it's some rust-specific
thing that I didn't look into details for.  So, BDK had to put in some bug fixes
and to update their version of those underlying libraries; they had to do the
same thing as those underlying libraries did, something related to a standard
function in rust.

So, this is just a maintenance release.  BDK project, I believe, is still
working on the release for the bdk-core, changing how they do their modules and
stuff, so just wanted to clarify there.

**Mike Schmidt**: Thanks, David, I was wondering why that wasn't in the release
notes when I clicked in, so thank you for clarifying.  I know that is an effort
that is underway, and so if you're curious about that effort, check out that
previous chat with Alekos.

_Core Lightning 23.02.2_

The next two releases that we noted are both Core Lightning (CLN) releases, the
Core Lightning 23.02.2, which is a maintenance release that contains a bunch of
bug fixes, and if I recall correctly the numbering on these releases has to do
with the month and year that it was released.  So, this is a maintenance release
that is based on that February 2023 release and it's a bug-fix release.  Dave,
did you want to jump into any of the details of that release?

**David Harding**: No, I think it's just little stuff.  If you use CLN, it's
best if you use it as a developer with other applications.  Just check the
release notes, they're like five lines, so you'll be good.

_Core Lightning 23.05rc1_

**Mike Schmidt**: Core Lightning 23.05rc1, so back to that numbering scheme,
this would appear to be the target for the May release of 2023, and it's a
release candidate for CLN.  In digging in, I did not find the release notes
immediately, so I don't have anything to comment on it.  Dave, I don't know if
you drove into that at all?

**David Harding**: Not really.  So, just for listeners, I use a policy for
announcing pre-releases, you know, release candidates, of not to go into too
much detail for stuff unless it's something that the developers really want
tested, that they have a specific desire to have something tested.  That way, we
don't steal their thunder from their main release announcement.  So, if they
want to say, "Look, we just added this awesome feature, but Optech told you
about it a month ago".  We don't want to do that, so we don't usually go into
too much detail.

I think anybody who does want to read the change log, especially if you're going
to go out there and you're going to test it, it's in the main directory of the
CLN project.  So, you just go to the page that has the README, and scroll down
the list of files, and there's a CHANGELOG.md there.

**Mike Schmidt**: We have three notable code and documentation changes that we
pulled out for this week's newsletter.

_Bitcoin Core #27358_

The first one is Bitcoin Core #27358, which is an update to the verify.py
script.  If folks have downloaded Bitcoin Core previously, you know that it's a
best practice to verify the files of a particular release, and there's been some
changes recently in where certain signatures are from prominent Bitcoin
developers and other folks, and there's some improvements to the script to
automate the process of checking that.  Dave, you did the writeup, do you want
to get into some of the nitty-gritty of how this improves verification for folks
who are downloading the software?

**David Harding**: Absolutely, I think this is a very, very useful change.  So,
in the past, when the Bitcoin Core project released a new version, they put the
software up on their website and they had the lead maintainer, Wladimir van der
Laan, sign it with a GPG key.  So, he would sign a file that had a hash of all
the specific files.  So, you could download his signature, you could download
that file that he signed and you could verify that file was signed by him, and
then you could check the checksums on the specific file you downloaded for Linux
or for Windows or for Mac, or whatever.  And this is how a lot of free software
projects give you a verifiable artefact from their project, so you know that
it's actually legit software.

Bitcoin Core goes a step further.  They also do reproduceable builds, so
multiple people can all build from the same source code and get exactly the same
files or have the same hashes, so they're all going to be able to communicate
with each other and verify that the build is good, and that they're all getting
the same thing, and that they can test the software if they want to.  But
Bitcoin, we don't really want to put trust in one person.  We love Wladimir, he
left as lead maintainer, and we have this opportunity now not to put our trust
in just one person.

So now, multiple who are doing the reproduceable builds, they're all signing
those reproduceable builds.  Those signatures are out there and you can go
through and choose the people who you personally trust, or exclude the people
who you don't trust, and check their signatures on each release.  But this is a
pretty laborious process; you've got to download each signature, you've got to
run a GPG command, you've got to download the files, it's kind of a pain.  So,
several developers worked together, I believe the final developer on here was
Cory Fields, but who else did?  Andrew Chow did a lot of the initial work there
on writing this script that just goes through and automates everything.

What you do is you tell it the PGP keys of the people you trust.  So, if you
trust Andrew Chow, you download his key and you tell the script, "I trust
Andrew", and you go and find a few other people who you trust who signed this
file.  You give that to the program, the program goes and downloads those
signatures, it downloads the release files, and it verifies that the signatures
commit to the release file.  So, it's a process that you can do manually, but
it's now automated.  So, if you're willing to read through the script, and it's
looks like it's sensible Python code, you can use it to automate a process that
you should be doing anyway.

Again, Bitcoin Core here has now done something nice that it has removed trust
in any individual developer, so pretty cool.

**Mike Schmidt**: And not only can you go to the bitcoin-core/guix.sigs
repository and see these Guix attestations for different releases of Bitcoin
Core, but you too can also do a build and an attestation and put up a pull
request, so that your attestation is also included.  I know in the past,
developers have been wanting to solicit the community's involvement in any sorts
of attestation; so if you're feeling geeky, if you will, you can also contribute
your attestation.

_Core Lightning #6120_

The next pull request that we noted this week was Core Lightning #6120,
improving its transaction replacement logic, and this is around RBF fee bumping
a transaction, and also includes periodically rebroadcasting unconfirmed
transactions to make sure they're relayed.  Maybe one in to digging into this PR
would be for me to ask Dave, why would we need to be rebroadcasting unconfirmed
transactions; isn't that handled by Bitcoin Core?

**David Harding**: Alas, it is not handled by Bitcoin Core particularly well,
especially if you don't have a wallet running with Bitcoin Core.  And the way
CLN does is it doesn't use Bitcoin Core's native wallet, it uses its own wallet.
So, when you send a transaction to Bitcoin Core, it sees that it already has a
copy of it, it makes sure that it's valid, and then it will relay it to all of
its full peer connections, the ones that aren't blocked-only connections.  Then
it just sits around in its mempool and hopes that it gets confirmed.

The problem is if you're relaying a transaction that you created with other
local software on your computer and you send it to your peers, well what if
those were just a bad set of peers, what if you had just started your Bitcoin
full node and you didn't have any peers; what if something else happened and
those peers that received the transaction didn't relay it to any other peers and
the whole network hasn't seen your transaction?

In the LN protocol, it's really important to get your transaction out there and
get it into a block within a reasonable amount of time.  If you're just sending
a regular transaction, your recipient might just say, "Hey, look, I'm not going
to give you the goods that you bought until I receive your transaction", and
that's just not a big problem, you can resend it.  But with CLN, you really need
to have some mechanism out there doing its best to get your transaction
confirmed.

So, this pull request helps take care of both sides of that problem.  First, it
rebroadcasts the transaction; the current rule they have is to just rebroadcast
it every hour.  And there are trade-offs there, I think we've discussed this in
previous letters.  The trade-off there is the more you rebroadcast a
transaction, the easier it is for somebody monitoring that work to intuit that
that transaction belongs to your wallet.  The real solution for this is for us
to build rebroadcasting into Bitcoin Core directly so that all nodes
occasionally rebroadcast transactions, so you can't tell that somebody
rebroadcasting a transaction is behaving any different than other nodes.  But we
don't have that yet.

CLN is taking a sensible precaution here and in addition to rebroadcasting
transactions, they have also put in some rules for automatically fee bumping a
transaction using RBF.  Again, LN transactions need to be confirmed within a
timely amount of time, and I think if you're interested in rules for automatic
fee bumping, Rusty Russell has put those, I think they're in a commit message on
this PR.  So, scan through the commit messages -- oh, they're in the main PR
description.  I think they're reasonably well-thought-out rules, even if Rusty
uses this weird measurement he calls sipa which I believe most people call, I
don't know, weight units?

**Mike Schmidt**: Consents?

**David Harding**: I think this is weight units, but yeah, Rusty is the only
person who does this and it makes reading his stuff extra fun!  Anyway, there
are some rules here; if you're doing other software like this where you want to
do automatic fee bumping, check out his rules, I think they're well thought-out
and they can help you save some thinking time.

_Eclair #2584_

**Mike Schmidt**: Last PR this week is to the Eclair repository, #2584, adding
support for splicing, both splicing-in, adding funds to an existing channel, and
splicing-out, taking funds out of a channel to an onchain transaction.  There
were some notes in the PR that there are some differences between what Eclair
has done and the current draft specification, which leads me to ask, Dave, if
you're familiar, if I'm an Eclair user, am I able to start splicing-in and
splicing-out now; I thought that we needed more implementations to be supporting
that on mainnet in order for that to be live?  What's the status of the
usability of this feature that's been merged?

**David Harding**: Well, they have not merged the protocol under the
specification, and what Eclair is describing here, like we note in the
newsletter, differs slightly from the current proposal, and I don't believe it's
100% compatible with what CLN is doing.  In particular, one of the things they
mention in the pull request, the description is, their words, they said they,
"Use a poor man's quiescence protocol", whereas I happen to know the BOLT
proposal is based on a previous proposal Rusty made for what he calls the STFU
-- you can figure out what that stands for -- quiescence protocol, where a node
sends an STFU message that tells other nodes, "Okay, stop sending me updates to
this channel, don't send me any new Hash Time Locked Contracts (HTLCs) until
I've finished the operation I'm about to work on".

That's important in splicing because in splicing, as I think was mentioned in a
previous week's newsletter where you had Lisa Neigut on, in splicing they manage
parallel commitment transactions.  So, because you have to manage this stuff in
parallel, you want to start out from everybody having exactly the same state.
And once you all agree on that state, then you can resume the protocol and go
back to just doing things your merry way.  So, this differs from the
specification proposal, it differs from what I believe is currently in CLN, or
is in a PR for CLN that Dustin Dettmer, I think is his name, is working on.  The
difference is not big and I think with this, if you want to run a pre-release
version, a non-released version of Eclair, you can open splices with other
Eclair programmes.

I don’t think this is gated behind an experimental flag or anything, but I'm not
entirely that familiar with Eclair.  So, this is exciting, I just want to say
that I think splicing is really an important feature for LN, because it just
allows you to hide from a user the difference between onchain Bitcoin and
offchain Bitcoin.  From the perspective of a user, once splicing is widely
deployed, there's just bitcoin; there's bitcoin that you can send, you have to
wait for confirmations; and there's bitcoin you can send and you don't have to
wait for confirmations, which is still different, but the user interface and the
usability just increases massively with LN.  So, I'm really happy to see Eclair
working on this, I'm happy to see CLN working on this, and I'm just going to be
really happy to see this get out there and be deployed.

**Mike Schmidt**: Before we wrap up for this week, I want to give an opportunity
to folks who have any questions for Dave or me, or I see Maxim is still here, on
anything that we've covered in the newsletter.  Feel free to raise your hand or
request speaker access.  And I will also plug Newsletter #246, both the written
version and our podcast recap of it from last week.  We did have Lisa on and we
talked about not only some of the splicing specification discussions that have
happened recently, but also more broadly what's happening with splicing, what's
the timeframe and what are the advantages of splicing.  So, if you're more
curious about splicing, definitely check out that episode as well.

I don't see any requests for speaker access or questions on the tweet that I can
reference, so I think we're good to wrap up.  Thank you to my co-host for this
week, Dave Harding, and thank you to our special guest, Maxim, for going through
the news item on RGB this week, as well as the commentary on the client and
services update section, and we'll see you all for next week.  Cheers.

{% include references.md %}
