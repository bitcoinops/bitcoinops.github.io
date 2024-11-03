---
title: 'Bitcoin Optech Newsletter #321 Recap Podcast'
permalink: /en/podcast/2024/09/24/
reference: /en/newsletters/2024/09/20/
name: 2024-09-24-recap
slug: 2024-09-24-recap
type: podcast
layout: podcast-episode
lang: en
---
Rijndael and Mike Schmidt are joined by Andy Schroder and Virtu to discuss
[Newsletter #321]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-8-24/386982145-44100-2-a39501afa9c39.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #321 Recap on
Twitter Spaces.  Today, we're going to be talking about proving a UTXO is in the
UTXO set in zero knowledge; Lightning offline payments; DNS seeding for non-IP
networks; we have six interesting ecosystem software updates to talk about; and
we have our regular segments on releases and notable code changes.  I'm Mike
Schmidt, I'm a contributor at Optech and also Executive Director at Brink, where
we fund Bitcoin open-source developers.  Murch couldn't make it this week, but
we have a special guest co-host today.  Who are you, special guest co-host?

**Rijndael**: Hey, good morning, my name is Rijndael.  I am a coder over at
Taproot Wizards.  Happy to be here and talk about some of the new releases and
projects.

**Mike Schmidt**: Thanks for joining us.  Virtu?

**Virtu**: Hey, I'm a grantee from Spiral working on Bitcoin Core P2P stuff.

**Mike Schmidt**: Andy?

**Andy Schroder**: My name is Andy Schroder, I am working on distributed charge.
It's aiming to Lightning-enable the energy grid, so I have a number of
implementations.  I've got an EV charger, a general purpose electric meter,
basically hardware and software that streams energy and satoshis in opposite
directions.  So, it's a "don't trust, verify" approach to delivering energy.

_Proving UTXO set inclusion in zero knowledge_

**Mike Schmidt**: Very cool.  Thank you both for joining us this week.  If
you're following along, just bring up Newsletter #321, and we're going to go
start with the News section in sequential order here, starting with the first
News item which is, "Proving UTXO set inclusion in zero knowledge".  And this
was motivated by a delving Bitcoin forum post by Johan Halseth, who posted about
a proof of concept that he created, that allows someone to prove that they own a
UTXO that is in Bitcoin's UTXO set without actually revealing which output is in
the UTXO set, which is interesting.  The tool is named utxozkp and it's written
in Rust.  And the idea is that since UTXOs are scarce, you could potentially use
ownership of a UTXO as part of an anti-DoS toolset.

One example that we elaborated on was that Lightning channel announcements are
tied to UTXOs potentially, and you could potentially do that instead in a way
that doesn’t reveal what the actual UTXO is, unlike today.  And then another
application of such a tool that Johan outlined in his Delving post, or maybe it
was perhaps in the repository for his tool, was being able to prove that you
control a certain amount of coins without revealing which coins you control,
which is something that would be obviously useful for exchanges, or anyone else
doing proof of reserves and wanting to do so in a more private way.  I do have
some notes on how the tool works, but Rijndael actually has played with and used
this tool, so I will maybe turn it over to him to outline his experiences with
it.

**Rijndael**: Yeah, and this is probably going to intersect with some of your
notes a little bit.  It's a neat project to play with.  It uses a framework
called RISC Zero.  If you haven't seen it before, or if you're not familiar with
it, the idea is that instead of having you construct a STARK prover and verifier
by hand and doing all the moon math yourself, you can write a program in
something that can compile down to RISC-V as a target.  So, Rust is the common
thing that people use these days.  And then the idea is that RISC Zero will
generate a STARK prover and verifier for the execution trace of your program
running in like a RISC-V VM.

So, what's nice about that -- there's some downsides.  The downsides are that
the prover ends up being slower than if you kind of hand coded it, and the
proofs end up being a little bit larger because you're actually making a proof
over the execution of a virtual machine and what different registers are at
different steps of the program.  But the advantage of it is that you can use a
lot of existing Rust code.  So, the way that Johan's project works is you start
by taking a UTXO snapshot from your node and then you can construct a merkle
tree out of it, and you parse into the prover your merklized snapshot of the
UTXO set, along with a public key that you want to prove has a UTXO in that set.
And what it does is inside the prover, it constructs a little merkle proof up to
the UTXO snapshot, and then it blinds the public key by adding a little tweak.
And so what the proof ends up committing to is a tweaked key and a merkle root.
So, you don't know what the underlying pubkey was, you don't actually know what
the full merkle authentication path is.  All that you know is that there's a
tweaked pubkey that if you were to untweak it, it controls some Bitcoin in the
UTXO set.

So, it's a neat little project.  I think it's pretty cool to hack on.  If
anybody's interested in playing with STARK provers for Bitcoin-y stuff, this
would actually be a really great jumping off point because it uses existing Rust
code.  It would be pretty straightforward to do things like, say, I control a
UTXO and it commits to a particular tapleaf, or as you mentioned a minute ago, I
control a UTXO and it contains a certain amount of bitcoin, or it was spent by
or created by some other pubkey or something.  So, it's a nice way to kind of
work with existing Bitcoin code and existing constructs without having to kind
of build a STAR verifier yourself.

**Mike Schmidt**: Yeah, pretty cool.  There's a lot of these zero-knowledge
topics seeping their way into Bitcoin discussion and seeping their way into the
newsletter recently.  I must admit, I didn't play with the tool, and I am quite
a neophyte when it comes to some of the zero-knowledge stuff, so thanks for
walking us through some of that.  Did you, Rijndael, happen to play at all or
read about the anonymous usage tokens from curve trees, the aut-ct, that was
discussed in the Delving post as sort of a comparison way of doing something
similar?

**Rijndael**: Yeah, that was a thing that I want to say Waxwing did a while ago
for, probably for JoinMarket, because JoinMarket as the concept of hosting a
bond and using that as an anti-sybil mechanism.  And I think there's a similar
thing that Waxwing ended up doing to use curve trees to kind of prove that a
UTXO is included in the set.  Those proofs are going to be smaller and more
compact than the STARK proofs that Johan's project is producing.  I think the
thing that is interesting, especially for what I imagine the average off-tech
listener would be doing, is that I think it's easier to add more functionality
to the proof in this RISC Zero prover.  You don't have to go and figure out
really advanced cryptography to build the proof or to verify the proof, you can
just write some Rust code and then have the tool chain build a prover for you.

So, I think the thing that Waxwing did is probably better for this specific
case, I think the specific case of proving ownership of a UTXO at a specific
moment in time, which is an important caveat, because there's nothing that
proves that you aren't going to spend it in the future, right?  So, for
proof-of-reserve use cases, you might take a snapshot, prove that you have the
money, and then the next block you spend the money, and that can create some
problems.  So, I think Johan's project is kind of a nice jumping-off point for
maybe adding proof of other attributes of the UTXO or of relationships between
them, or something else.  So, maybe I have a UTXO and one of the tapleafs that
it's encumbered by will let Andy spend it after some timelock, and I don't want
to divulge what the full script is or something, but I want to be able to prove
that that tapleaf is included in this taproot address.  You could do something
like that really, really easily by extending the code that Johan has.

**Mike Schmidt**: Very cool.  If you're curious about those anonymous usage
tokens, and I guess it was Waxwing, and I think it was related to JoinMarket as
well, we covered that in Newsletter #303, and we also had Waxwing on in Podcast
#303 to discuss that, so if you want to hear that differing approach, check that
out.  There's a good discussion going on in Delving.  I think AJ is
participating, I think Davidson, who did Floresta and some of the utreexo
technology used in here.  And then, as Rijndael pointed out, there's some
interesting tech for folks to play with.  If you are jumping into Rust, if
you're curious about STARKs, utreexo, this is maybe a good proof of concept for
you to play around with.

**Rijndael**: Yeah, and just a little bit more color on STARKs too.  I think
part of the reason why people have seen it popping up on the Bitcoin timeline is
SNARKs have much more compact proofs, but they rely on more exotic cryptographic
assumptions.  The thing that's really, really cool about STARKs as a proof
system is that the only cryptographic assumptions that they make are that you
have a strong hash function, and that you can evaluate polynomials.  So, Bitcoin
already makes a bunch of assumptions about SHA2 being a good hash function.  So,
if you're willing to accept those assumptions, then STARKs are a proving system
that kind of fit into the ecosystem well, at the expense of them having larger
proofs than SNARKs do.  So, there's a team that's working on trying to implement
a STARK verifier in script using OP_CAT, there's people that are trying to use
STARKs for other privacy features.  I think it's something that you're going to
see a lot more of, and tools like RISC-V make it a lot easier to experiment and
prototype these things.

So, if you're interested in seeing what does one of these proofs look like, what
does the workflow look like, what are the kind of interfaces that I can use when
I'm building ZKPs with STARKs, I think Johan's project is just a really good
thing to just go clone and start hacking on.

_LN offline payments_

**Mike Schmidt**: I think we're probably good to wrap up that News item.  What
do you think?  Awesome.  Next item from the newsletter titled, "LN offline
payments".  Andy, you posted to Delving a post titled, "Privately sending
payments while offline with BOLT12".  And in that Delving post, you started off
outlining a particular scenario that you had in mind.  Would you mind outlining
that for us as an intro to the post and the topic?

**Andy Schroder**: Yeah, sure.  One thing I think, I might've had a little bit
of clickbait on the title there, because it's really kind of remotely
controlling your online node is really what this is.  But basically, the concept
here is you have an online node somewhere, but you want to leave it behind and
then yourself go offline, but then still have some way to trigger payments to be
made on your behalf from your node securely while you're away.  And this concept
that I came up with here basically reuses the BOLT12 messaging workflow, but
then makes some changes on the way the messages are actually relayed.  And then
it kind of allows your phone, which you might be initiating the process with, to
relay a message through the merchant or the payment receiver's node back to your
online node.

So what happens is, before you leave home, leave connectivity with your online
node, you need to basically exchange some secret keys for the invreq_payer_id
field, and then also you need to get some paths to actually communicate through
onion messaging to your node.  And you actually put in the key word in your
newsletter, they're basically like tokens that you can issue to yourself and
then use them later.  So, when you leave home with your phone which has these
invreq_payer_ids that have been pre-exchanged, then you leave the internet but
then you need to make a payment, and you find a merchant that uses BOLT12, and
then that merchant has the ability to receive your invoice request over NFC
instead of over an onion message.

That's one key difference here is you get the offer from the merchant, then you
send them an invoice request over NFC or Bluetooth, and then they receive that
invoice request, and then they send the invoice back to your node; but they send
the invoice over the normal onion messaging to your node.  And when your node
gets it, it sees that you authorized the invoice to be sent to you.  And that's
one key area where you'd need to actually make a spec change to BOLT12, is there
needs to be a way for the invoice that's sent to your node over onion messaging
to include a signature from your invoice request.  And that signature is kind of
like you're exercising your token.  But anyway, when your remote node receives
the invoice with the signature that I'm proposing be added to the invoice that
came from the invoice request, then your node sees, "Okay, I should go ahead and
make this payment because it's been authorized by myself".

You can kind of expand this beyond you and just make it your whole family, maybe
you could reuse your node in the same way.  So, it's not just a one-person
thing.  There's really a lot of accounting flexibility that could be built in to
your remote node that you're remote controlling, based on any kind of spending
constraints you might want to put on it as far as rate limits or maximum payment
sizes, or things of that nature.  Maybe you want some of your tokens to kind of
progressively expire over time.  A lot of different protections you could make
in case something is compromised out in the field there.  You could always
revoke the tokens at any time.  And these tokens are quite a bit different than,
say, a Cashu Mint token, because they're really just you issuing them to
yourself.  So, since it's your own node, you don't have to do as much complex
stuff with blinded signatures and all kinds of things.  It's really just like
more of a bookkeeping thing on your end, rather than actually minting
cryptographic tokens that are transferable, because you're not really
transferring them to anyone else.

So, I propose this just in a simple workflow with a phone wallet, but a big
interest to me working on distributed charge is to make devices out in the field
that are paying for physical products, such as energy, to be able to make
payments with really no or unreliable cellular internet connectivity, and then
still maintain privacy, because these messages are onion routed back to your
home node and that's a pretty key thing there.  Other methods, the merchant
could provide a Wi-Fi hotspot to the sender, but that presents a lot of problems
because maybe they want to use it just to get free internet, or then you're
going to have to use Tor, which is another stack, and it's just good to kind of
keep all this messaging under the Lightning onion messaging layer.

So, there's some alternatives that I thought of when I was coming up with this
idea.  There's something called a Bolt card.  It's like an LN URL withdrawal
method that kind of does a similar thing, but it doesn't really provide privacy
or security or any kind of spending limits.  It's just like a trust-the-merchant
kind of approach.  There's also L402 as kind of a way to do sort of offline
payments if you want to pre-buy something with a merchant, but you kind of have
to know who your merchant is and how much you want to spend in advance before
you can do that.  And then ecash, you can transfer that offline in kind of a
related way, but that just depends on whether the merchant actually cares about
your ecash token and if they trust that they're going to get anything out of the
mint.  So, you could also, if you're using LND, issue a lot of one-time use
macaroons for controlling your node that way, but that would require all
merchants to be familiar with how to communicate with LND.  And you really have
to expose how to connect, like where to find your node to use that approach.

With this workflow that I propose with BOLT12, I think it's pretty flexible
because BOLT12 hopefully is going to be a pretty widespread standard, and it
should work across wallet and node implementations without a lot of interop, and
whatnot, that could lead to just heavier software stacks and more chances for
problems if the node is trying to control a node that it's not really designed
to.  So, you can also do something similar with onchain transactions.  If you
have your UTXO set stored offline and your private keys for your UTXO set, you
can actually do offline spending as well in the same way.  Andreas Schildbach's
bitcoinj-based SPV wall for Android actually does this.  It can receive a
payment request over a QR code, BIP21, and then it'll actually communicate over
Bluetooth with the merchant, and then relay the signed Bitcoin transaction.  So,
there is kind of a mechanics of how this could communicate already out in a
wallet somewhere for onchain transactions, but really that's not feasible to use
onchain transactions for day-to-day purchasing, and you don't really have the
flexibility to void your tokens, and then you have privacy issues with onchain
stuff.

So, there's a lot of options to also do offline payments, but I think this new
one that I've proposed is really going to be something that actually could take
off.  If we get a few implementations adopting this, then I think it could be
pretty powerful.

**Mike Schmidt**: Yeah, it seems like you've touched on a genre of common need
in the LN ecosystem.  As you mentioned, several folks chimed in in your thread
with similar ideas.  I think it was t-bast with BLIP28, and I think Core
Lightning (CLN) has commando plugin for remote control in CLN, and ZmnSCPxj
posted something referencing a tweet of a similar idea that he had.  Are you
familiar with any of those?  I know you mentioned ecash and Bolt Card and
macaroons.

**Andy Schroder**: Yeah, I didn't really know about t-bast's proposal until he
responded and I kind of looked it over in the last few days, and it doesn't look
to me like it uses onion messaging, as far as I can tell.  It seems to me like
it's similar to the commando plugin.  The best I understand about commando is
you actually have to have a TCP socket directly with the node that you're
controlling.  I don't think it relays the commando commands over onion
messaging.  If you're aware, I'd like to know.  And ZmnSCPxj, his sketch wasn't
as deep, I guess.  I'm not sure of the tweet that he was referencing in his
reply, so I'd have to see more details on his actual proposal.  I think both
ZmnSCPxj and t-bast were kind of proposing a more complete remote control of the
node.

This here, what I'm proposing, is kind of really simple and I think maybe we
could use a variety of options depending on your needs, whether you want to have
full control of the node or something simple.  And I guess it depends on, maybe
they make their full-control thing easy to scope out and limit the control, like
make it so that you can use a subset of that remote control; that's possible.  I
guess I'm just a little concerned that for making a simple payment, you're going
to have to have too many relaying of messages back and forth a few times, and
I'm trying to make it so that you can do just a single push of a message and you
don't have to keep doing a lot of back and forth with this merchant, because if
you're using NFC, you're going to have to keep tapping, and that's a little bit
of a usability thing.  So, I guess we'd have to see how their proposals get
implemented, is maybe part of the answer on which way is better.

**Rijndael**: Yeah, I think when I initially saw the proposal, my first thought
was, "This looks a lot like LN URL, at least from a use case perspective".  But
I think something that's really key here that's different is that the messaging
is done over onion routing, so you don't need to have the payer maintain a
publicly-accessible web server in order to bake off these tokens.  And just like
you said, compared to something like commando or some other project, you're
really just interested in scoped, like spend authorizations, that you can bake
off and then hand to a merchant and then the merchant can drive retry behavior,
right?  Like if you're paying for electricity at an EV charging station, if
there's a problem with making the payment, you don't want the buyer to have to
keep tapping the QR code or tapping the NFC or whatever; you want to let them do
it once, go about charging their vehicle, and then let the merchant redrive
failures or retries, or whatever.

So, I think for that kind of use case, this makes some sense.  You probably
don't want to treat this like ecash, where you bake off a token and then you
carry it around in your pocket for weeks and like hand it around to people,
because the buyer can revoke it whenever they want and you don't know that it's
been revoked until you actually try to redeem it.  But I think for making the
payment flow a little bit asynchronous, it's an interesting idea.

**Andy Schroder**: One thing you said, "You're relying on the buyer revoking
it".  And it's basically the same thing as like a check with a bank.  I mean,
you can write a check and give it to somebody, but that check can always be
canceled if you want.  And there's pros and cons to that.  But hopefully here
with this approach that I proposed, you're hopefully doing it within a few
seconds, so you don't have to worry about that scenario.  But one option I
didn't really get into with this is the invoice request that you're sending over
NFC or Bluetooth back to the merchant.  Another thing you can do before you
leave home, if you want, is use a similar workflow where you print out on paper
a bunch of invoice requests that you could hand out to merchants, and they would
have the amounts predefined, but you could almost create your own paper note for
claiming funds on your Lightning node.

So, say you do go on a trip, you go to another country, your phone gets smashed,
but you still have these pieces of paper in your backpack, or maybe you put them
wherever, you can still maybe get somebody to accept it because they can
instantly claim it.  And it's kind of a way to issue some kind of redeemable
thing that a merchant can claim instantly and they don't really have to worry
about it if they've already claimed it, but you can always revoke it whenever
you get home.  And I think paper could be a cool media for this.  I mean, even
giving a gift in a birthday card or something, it's just a whole lot better than
the old days where you could do like a paper wallet from bitcoinpaperwallet.com
and it's got a private key and stuff.  I mean, this is like a Lightning-enabled
way of doing a paper wallet.

**Mike Schmidt**: Rijndael, any other follow up questions?

**Rijndael**: Nope, that's great.

**Mike Schmidt**: Andy, any parting words for the audience or calls to action on
the thread and what you're planning to do, how people can participate?

**Andy Schroder**: Sorry, I just lost you there.  My speakers went off.  Could
you repeat that?

**Mike Schmidt**: Sure, just anything you leave the audience with or any calls
to action for people who might want to get involved with the idea?

**Andy Schroder**: I guess I am not an expert on BOLT12, so if you can find a
flaw in my proposal, I'd definitely be interested in knowing that.  Also, I've
proposed adding a new field to the invoice.  Basically, it's copying field 240
from the invoice request to field 239.  That's basically your signature.  If
anybody can see a problem with that, I would like to know, because it's pretty
hard to read some of these BOLTs, and I tried, but if there's something that can
be done to improve this, that'd be awesome to know about.

**Mike Schmidt**: Excellent.  Well, Andy, thanks for joining us.  You're welcome
to stay on as we go through the rest of the newsletter.  Otherwise, if you have
things to do, I understand and you're free to drop.

**Andy Schroder**: Thanks for having me.

_DNS seeding for non-IP addresses_

**Mike Schmidt**: Our third and final News item this week is titled, "DNS
Seeding for non-IP Addresses".  Virtu, you posted to Delving a post titled,
"Hardcoded seeds, DNS seeds and Darknet nodes".  You created some statistics on
hardcoded seed nodes to see how fast reachable seeds decrease over time.  I want
to get into your findings, but maybe some context for the audience first.  Maybe
you can explain a little bit about DNS seeds versus seed nodes and how is using
Bitcoin Core with something like Tor impacted.

**Virtu**: Yeah, sure.  As I'm sure most of you know, whenever you set up a new
Bitcoin node, it doesn't know about any peers to connect to when you first start
it.  So by default, the first mechanism it uses to discover new peers is DNS
seeds, if your node is using an IP connection, so that is IPv4 or IPv6.  So, it
will send a DNS packet to the DNS seeds and they will reply with a bunch of
addresses that belong to Bitcoin nodes that hopefully are reachable, and your
node will then connect to one or more of those and send a get address message,
and the peer will reply with around 1,000 addresses of Bitcoin nodes that it
knows about.  And from there, you can bootstrap your node with peers.  If, for
some reason, the DNS seeding mechanism doesn't work, or if you are using a
darknet-only node, that is a node that is only connected via Tor or I2P or
CJDNS, you're falling back to another mechanism, which is called the hardcoded
seed addresses, which is more or less a bunch of known addresses of Bitcoin
nodes that is hardcoded into the Bitcoin Core binary.  This list is refreshed
about every major release update, and it contains addresses for all supported
network types, that is IPv4, IPv6, onion addresses, I2P addresses, and CJDNS
addresses.

I had a look at how much of these hardcoded addresses are reachable as we move
forward in time.  So, I took a look at the last four releases, which back then
were v24, v25, v26, and v27.  And it turns out that even after about two years,
so v24 was released in January 2023, there's still like 80 to 100 of reachable
IP addresses, but only around 10 or so for onion and I2P.  The reason there's
only so little for the darknets is that these were manually curated in the past,
and I think this was fixed in the meantime, so there should be more available
right now.  And the conclusion of this investigation is more or less that these
hardcoded DNS seeds seem good enough if you're running a darknet-only node.  So,
as I said before, if you're using a darknet-only node, you can't use the DNS
seeds, but you have to fall back to these hardcoded seed addresses from the
binary.  But still it looks like it's okay.

**Mike Schmidt**: So, the hypothesis, or I guess the question that you had
before this was, do the hardcoded seeds -- or, what sort of degradation of the
accessibility of those hardcoded seeds occurs over time between releases?  Since
the hardcoded seeds change every release, there's going to be some amount of
those nodes that are going to drop off, or for whatever reason have their
address changed, etc, and so you sort of measured how many of those stick around
for the different networks, right?  And it sounds like your conclusion is,
enough.

**Virtu**: Yeah, that's right.  So, the highest churn, or the highest loss, is
in the IPv4 addresses.  I think that's maybe because people are trying out nodes
and then turning them off again; or maybe due to IP address changes from nodes
that are run at home.  IPv6 is slightly better.  And then for darknets, these
are rather stable, so there's only about 10% to 20% of degradation from release
to release.  So, maybe I should say that there's roughly a couple of hundred of
each of these addresses hardcoded into the binary right now and after six
months, hundreds are still available.  And even after two years, there's high
double digits or even triple digits left.

**Mike Schmidt**: Hey, Emzy, did you have a question?

**Emzy**: Maybe I have something to add, or maybe I didn't follow closely
enough, but it's interesting to mention that before the DNS seeds for Tor,
hidden service v2, they had a way to announce hidden service addresses because
they were shorter and they were fitting into IPv6, they were encoded in IPv6.
So, that was in the past, there was a way for the DNS seeds to report on Tor at
least.  But now, the addresses are too long.  But maybe you're getting to that.

**Virtu**: Yeah.  So, my original motivation for analyzing the availability of
these darknet hardcoded seeds was to figure out whether not having them
advertised via DNS is a problem.  My conclusion is that actually it's not, but
still you can argue two ways.  Everything seems okay, but on the other hand you
could also argue, why don't we improve the DNS seed infrastructure to allow also
to publish darknet addresses using DNS messages?

**Mike Schmidt**: So, talk a little bit more about that discussion.  Were folks
receptive to that?  How would that work, etc?

**Virtu**: Yeah, so as Emzy said, or rightfully pointed out, IPv6 records, which
have 128 bits of data, they were sufficiently large for them to encode onion v2
addresses.  And I was just exploring different options or different ways to
encode the longer, newer onion addresses, or I2P addresses and CJDNS addresses
in some custom encoding.  And the first thing I tried was DNS NULL records,
which are more or less binary records in which you can store arbitrary data.
And I just used a BIP155-like encoding where you don't convert the entire
human-readable or bech-whatever encoded addresses, but you just extract the
public keys that are necessary to derive this address, which is just 256 bits,
and then serialize them and store them in binary data in DNS NULL record.

While this worked, there's one issue that sipa pointed out.  Right now, Bitcoin
Core uses getaddrinfo, which is a process call to do the DNS resolving, and this
has the advantage that it doesn't require any low-level DNS code.  It
automatically uses the system's configured name server, which means that when
Bitcoin Core sends the DNS messages to the DNS seeds, this is done through
whatever name server is configured on your system, which is probably your ISP's
name server, or some public DNS server from Google.  So, the DNS seeds will see
the request coming from this IP address and not yours, which is positive for
privacy.  Plus, it offers caching by the ISPs, or whatever public name server,
to reduce traffic.  And all of this we don't get with DNS NULL records because
they're not really standardized in the DNS protocol, so getaddrinfo cannot be
used.  We would have to either use custom code to send the DNS query, or depend
on some external DNS library to do the call.

I think these are good reasons to not use the DNS NULL records, so I tried
something else, and we can actually use the DNS AAAA records, which are used for
IPv4 addresses.  You just have to announce some sort of special encoding by
using maybe a reserved prefix from the IPv4 address range and then cut up the
longer data, let's say the 256 bits that correspond to a Tor address, into
chunks that are small enough to fit into multiple of these AAAA records.  And
this gives us the upside that we can keep using getaddrinfo, we don't need to
add extra DNS code to Bitcoin Core, we retain these privacy-preserving features
and the caching.  The only downside of using the AAAA records is that the
efficiency of the encoding is slightly lower than with the DNS NULL record,
because you have this overhead of using the special prefix to announce the
special encoding.  But other than that, there's no downsides to doing it.

**Mike Schmidt**: Pretty cool stuff.  Rijndael, do you have questions or
comments?

**Rijndael**: No, great explanation.

**Mike Schmidt**: All right, well I saw even as of yesterday, Virtu, there's
still discussions going on in the Delving post thread.  So, if folks are curious
on commenting and getting into some more of the details of what you discussed
here, they're free to jump in on that.  Anything else you'd like folks to know
or take action on before we wrap this news item up?

**Virtu**: Yeah, maybe if someone has an opinion on whether this is actually
beneficial to privacy, because he's running a darknet-only node and would
benefit from being able to receive these addresses via the DNS servers, that
would be nice.  Because otherwise, I mean if people are running nodes that are
connected via multiple networks, including Clearnet, then I don't think we need
this extra overhead.

**Mike Schmidt**: Thanks for joining us, Virtu.  You're welcome to hang on, or
if you have other things to do, you're free to drop.  The next segment from the
newsletter is our monthly segment on Changes to services and client software.
We highlighted what we thought were six interesting updates to ecosystem
software this month.

_Strike adds BOLT12 support_

The first one is Strike adding BOLT12 support, and as we published the
newsletter on Friday, BOLT12 is an officially merged BOLT into the spec.  We
covered Strike, I don't know what newsletter it was, but we highlighted their
BOLT12 Playground, which was sort of a way to play around with BOLT12 that they
published for the community.  That was probably in the last few months here, and
now they officially support BOLT12 offers, and they also support using BOLT12
offers in the context of BIP353, which is the DNS payment instructions BIP.  And
so, pretty cool to see what seems to be one of the highly-used Lightning wallets
implementing this out of the gates.  Rijndael, any comments?

**Rijndael**: No, I was just going to mention the BOLT12 being merged into the
BOLTs repo, which is exciting and really timely for a lot of these news items.

**Mike Schmidt**: BlueMatt had what I thought was a funny tweet saying, "It's
now okay to get your BOLT12 tattoos".  So, if you're a crazy person, go for it!

_BitBox02 adds silent payment support_

Next item we highlighted was BitBox02 adding silent payment support.  So, the
hardware signing device, BitBox02, now you can use silent payments with that
hardware signing device.  And we linked to their blogpost that did a little
writeup about silent payments and their support thereof, as well as this payment
requests implementation that they have.  And I don't know that there is a BIP or
anything around this sort of payment request workflow that they've implemented.
I know some other folks have done it.  I think there was a standard from Trezor
doing SLIP-0024 previously.  Rijndael, do you have any insights there?

**Rijndael**: So, there's a bit for silent payments itself; it's 352.  And that
recently got implemented in Cake Wallet and now BitBox02 is adding support for
it.  In terms of whether people wrap it in BIP21 payment URI or something else
is a good question.  I don't know if there's a standard for it yet.

**Mike Schmidt**: Yeah, I think the payment requests is orthogonal to the silent
payments thing.  It was more of a separate payment request feature that they
have.  Yeah, and I think that actually may have come out before silent payments,
but yeah, if you're curious about that, check out BitBox02.  It's good to see
them supporting early Bitcoin tech being released.

**Rijndael**: Well, and it's nice to have more wallets to play with silent
payments.  For a long time, if you've wanted to play with this, you just had to
check out Josie's branch of Bitcoin Core, build it, and send yourself stats back
and forth.  So, now that there's actually end user devices and software that
support it, it's a lot easier to play with.

_The Mempool Open Source Project v3.0.0 released_

**Mike Schmidt**: Mempool Open Source Project v3.0.0 released.  So, this is the
open-source set of software that somewhere behind the scenes powers the
mempool.space website.  So, if you want to run something like that yourself,
check out that 3.0.0 release.  There's a few features that we noted in the
newsletter that they've added: New CPFP fee calculations, additional RBF
features, including full-RBF support, P2PK support for some legacy stuff, and
also some new mempool and blockchain analysis features.  I haven't run it, looks
cool.  I like mempool.space.

**Rijndael**: Yeah, if you run this new version, you actually get the RBF
dashboard, which is super-helpful, both for watching the current state of the
mainnet mempool, but also if you're working on software that makes bitcoin
transactions in 2024, you probably have to spend some time thinking about fee
management.  And so, having better tooling to be able to visualize like if your
CPFP came out with the right fee or not is really helpful.

_ZEUS v0.9.0 released_

**Mike Schmidt**: Zeus v0.9.0, which adds some interesting features: transaction
batching, which of course Optech loves and wants to celebrate, and the batching
also includes LN channel open batching transactions; there's additional hardware
signing device support, watch-only wallets, and they have some additional LSP
features that they've added there as well.

_Live Wallet adds consolidation support_

Fourth item this week, we highlighted Live Wallet and its support of
consolidation simulations.  I hadn't seen this application previously, but it's
an application that sort of analyzes the cost to spend a set of UTXOs.  So, you
can imagine that you load up your UTXOs into this tool, and it shows sort of
what is going to be the cost to spend those UTXOs at different feerates.  And of
course, you can use that then to determine when certain outputs, if they're
small, would be uneconomical to spend.  And so, I thought that was a pretty cool
sort of niche tool to play with.  I think there's also support for multisig as
well in the tool, but this 0.7.0 release that we highlighted includes features
to simulate, if you were to consolidate some of those UTXOs, what would that
look like from a fees perspective moving forward, so some of the trade-offs for
actually executing the consolidation transaction versus keeping the UTXO split
up as you have them today.

There's also a feature then, if you like the simulation of what consolidation
would look like, you can actually generate a PSBT to move forward with that
actual consolidation transaction.  So, pretty cool, pretty cool tool.

_Bisq adds Lightning support_

Last piece of software we highlighted this month was Bisq adding Lightning
support.  So, you can now, if you're a Bisq user, you can settle trades using
the LN, which seems pretty cool.  Supporter of Bisq and supporter of LN, so this
is good to see, although not a hands-on user here.  Rijndael, do you have
anything?

**Rijndael**: Yeah, there's also some nice chat improvements in Bisq.  A big
part of dispute resolution in Bisq is talking to your counterparty and trying to
figure out what happened or who didn't send what they were supposed to.  So, it
looks like in the current release, they made a bunch of chat improvements for
interacting with people, and it's nice to see Bisq v2 getting fleshed out.  It
was a dream for a couple of years, but it's actually real now.

**Mike Schmidt**: That wraps up the Changes to services and client software
segment this month.  We have our weekly coverage of Releases and release
candidates next.

_HWI 3.1.0_

First one, HWI 3.1.0, which adds support, and I think we covered this in a merge
summary previously, for Trezor Safe 5, the signing device.  It also adds
additional Ledger support under the hood, additional Linux compatibility, and
fixes parsing of taproot descriptors that have a single leaf.

_Core Lightning 24.08.1_

Core Lightning 24.08.1.  We covered the 24.08 release previously, so if you're
curious what's in that major release, refer back to that.  This is a release
that fixes a few crash issues and some other bugs from 24.08.  There were eight
issues fixed in total.  I won't enumerate them here, but check out the release
notes and update your CLN node accordingly.

_BDK 1.0.0-beta.4_

BDK 1.0.0, we are on beta.4 now, and this beta.4 didn't seem to have anything
too crazy for the audience.  Mostly, it fixes a versioning mistake that was made
with the previous beta candidate.  There were two of BDK's dependency crates
that had issues, so they fixed that up for beta.4.  We have a couple of BDK PRs
later in the newsletter that may or may not be in this 1.0.0 release.

_Bitcoin Core 28.0rc2_

And last release this week, Bitcoin Core 28.0rc2.  We had Gloria and Fabian on
last week in Podcast #320 to discuss the 28.0 features from a high-level
perspective.  And in #319, the week before, we had rkrux on, who was the author
of the Bitcoin Core 28.0 Testing Guide to talk about testing the RC.  I don't
have anything to add.  I'm not aware of changes that were made between the two
release candidates, so I won't pretend that I know the difference there.
Obviously some things have changed for testing.  Rijndael, do you have any
commentary there to add?

**Rijndael**: No, I mean the Test Guide is really good.  It walks you through a
couple scenarios that you can walk through yourself and has some really detailed
instructions on setting up that environment.  So, if you want to play with it,
really easy to do; it's a very well laid-out Testing Guide.  And then, if you
find any issues, you can cut tickets.

**Mike Schmidt**: Moving to the Notable code and documentation changes for this
week.  If you have a question for Rijndael, myself or our guest speakers, feel
free to request access, or you can drop a note in the thread here and we'll try
to get to your question by the end of the show.

_Bitcoin Core #28358_

Bitcoin Core #28358 involves dropping the dbcache limit.  So, the dbcache option
refers to the maximum UTXO database cache size.  A lower dbcache value makes
initial sync, or IBD, much longer.  But after the initial sync, the effect is
less important for most use cases, unless you're doing some mining stuff where
validation of blocks is important.  So, before this change, large dbcache values
were automatically reduced to 16 GB.  However, as noted in the description for
the PR, due to recent UTXO set growth, the current maximum value, which was that
16 GB for dbcache, is not sufficient for anyone who wants to complete IBD with
the UTXO set held completely in RAM, which is obviously a performance
improvement.  So, this PR drops that 16 GB limit and does not replace it with
another limit; there's just no limit now.  Rijndael, are you responsible for the
bloat of the UTXO set?!

**Rijndael**: No, despite everybody's best efforts now.

**Mike Schmidt**: So, if you're doing IBD, check that that value no longer has
that limit.  So, that should help folks with a little bit faster IBD if you have
such copious amounts of RAM.

_Bitcoin Core #30286_

Bitcoin Core #30286 involves optimizations around cluster mempool.  We've spoken
about cluster mempool a few times in depth, going through the idea conceptually
as well.  So, check out our references on the Cluster Mempool Topic page.  We
had Pieter Wuille on in Podcast #312 and Podcast #280, specifically to discuss
cluster mempool.  As a reminder, cluster mempool is a project whose goal is to
be able to reason better about the effect of transactions on the blocks that a
miner would create if it had the same mempool as your local mempool.  And it's
proposed as a replacement for the current ancestor-based mempool implementation.
This particular PR improves cluster mempool's existing candidate search
algorithm from a previous PR, with a bunch of optimizations in order to find
high feerate subset candidates for cluster mempools implementation.  There are a
bunch of interesting writeups that Pieter Wuille has done, that we noted and
linked to in the description.  There's a Delving Bitcoin post, and it's section
2 of that post that essentially has been done in this PR for these optimizations
to find the high feerate subsets.  So, if you're interested in the minutia, jump
into that Delving post.

_Bitcoin Core #30807_

Bitcoin Core #30807 is a fix for a bug where a peer of yours in Bitcoin Core
would request historical block.  If you were running assumeUTXO, you may not
have that block yet.  Especially, I guess the case here is, if you're an
assumeUTXO node that's syncing the blockchain in the background still and that
peer requested a historical block from you and you didn't have it, they would
get no response.  And so, it would cause that peer to disconnect from your
assumeUTXO node.  So, the fix involves the assumeUTXO node instead signaling to
its peers the NODE_NETWORK_LIMITED flag, which indicates that you'll serve the
last 288 blocks from the chain tip, instead of what was being signaled
previously, which was just NODE_NETWORK, which assumed all historical blocks
prior to the chain tip.  So, by signaling that limited flag in the meantime,
while the assumeUTXO node is still downloading blocks in the background, you
won't get disconnected from your peers.

_LND #8981_

LND #8981.  This is part of a series of PRs in LND to implement dynamic
commitments, their approach to channel commitment upgrades.  It's actually a
refactoring PR, so it's not super-interesting.  It moves the paymentDescriptor
type to only be used within the LN wallet package.  And so, there were some PRs
noted that were going to be building upon this to allow for the channel
commitment upgrades to be done more easier in LND.  Potentially, the idea behind
channel commitment upgrades are that there's changes to the format of the
Lightning commitment transaction in Lightning, or really any other change that
would affect the commitment transaction, having a way to facilitate that without
having to close the channel and then reopen a new channel.  So, this is some
plumbing work refactoring behind the scenes to support that in the future.

_LDK #3140_

LDK #3140.  This is a PR titled, "Support paying static invoices".  And in LDK,
it adds support for async payments in BOLT12, adds the ability to fetch an
invoice from an always-online node on behalf of a potential mobile device node
that is often-offline recipient.  The PR notes, "Async receive is not yet
supported, nor is sending async payments as an often-offline sender.  Upcoming
PRs will add async receive, which will allow us to test the flow end-to-end".

**Rijndael**: Yeah, I think the target deployment story for this is, you have
something like an LSP, and then you've got like a mobile wallet, and the idea is
that when the mobile wallet comes online, it can signal to your LSP like, "Hey,
I'm online now", and it can complete some HTLCs (Hash Time Locked Contracts)
that are in flight.  So, I think that that's the direction that they're heading
towards.  There was a thing that I want to say BlueMatt and t-bast and a few
other people worked on a while ago for handling async receive, and I think this
is a continuation of that work.

_LDK #3163_

**Mike Schmidt**: LDK #3163 is another BOLT12 offers-related PR for LDK.  This
one's titled, "Introduce Reply Paths for Bolt12 Invoice in Offers Flow".  I'll
paraphrase some of the commit messages here, which when I dug into, clarified
the motivation.  This PR introduces reply paths in BOLT12 invoices to address a
gap in error handling.  Previously, if a BOLT12 invoice sent in the offers flow
generated an invoice error, the payer had no way to send this error message back
to the payee.  So, by adding a reply path to the invoice message, the payer can
now communicate any errors back to the payee, ensuring better error handling and
communication within the offers flow.

_LDK #3010_

And one more LDK PR, LDK #3010 titled, "Introduce Retry InvoiceRequest Flow".
And this PR adds functionality for an LDK node to resend an invoice request to
an offer reply path if the node didn't yet receive the invoice.  So, before this
change, if an invoice request message on a single reply path failed due to
something like intermittent network connectivity or disconnection, it wasn't
retried.  So now, there will be that retry to handle intermittent connectivity
case.

_BDK #1581_

Last two PRs are to BDK.  BDK #1581, which allows a custom fallback algorithm
for the BranchAndBoundCoinSelection algorithm.  So before this, users were
forced to use SingleRandomDraw as a fallback to BranchAndBoundCoinSelection.
But now, there's a generic type parameter that you can specify a fallback coin
selection algorithm, potentially your own custom implementation of BDK's coin
selection algorithm class, in order to fall back if BranchAndBound didn't find a
coin selection set of candidates for you.  Yeah, go ahead.

**Rijndael**: I was just going to say, I can't believe Murch isn't here for
this.  He'd be sad!

**Mike Schmidt**: I know, right?  It's too bad, he'll be kicking himself!  The
only other note I had here was that in the description or one of the comments,
there was a note that this is a breaking change.  So, be aware of that if you're
a BDK user.  And I think this is one of the ones that was unclear if it was
going to be in this 1.0.0 release that they're working on.

_BDK #1561_

Last PR this week, BDK #1561, which removes BDK's bdk_hwi crate from the project
and moves the functionality in that HWI crate to rust-hwi, which has a couple
benefits.  One, it simplifies BDK's workspace, and also it helps out with some
of the nuance around their continuous integration testing and some of the
challenges they've had there.  So, just really a simplification.  Obviously, if
you're using the HWI crate, look for that rust-hwi migration.

Rijndael, I didn't see any questions or hands raised, so I think we can thank
our special guests.  Thank you to Andy, thank you to Virtu, and thank you for
Emzy for jumping in with a question and comment, and for our special co-host
this week, Rijndael, for joining us and helping us go through this newsletter.
Appreciate you jumping in.  Thanks all, see you next week.

{% include references.md %}
