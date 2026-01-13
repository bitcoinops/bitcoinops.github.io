---
title: 'Bitcoin Optech Newsletter #386 Recap Podcast'
permalink: /en/podcast/2026/01/06/
reference: /en/newsletters/2026/01/02/
name: 2026-01-06-recap
slug: 2026-01-06-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Anthony Towns and Mikhail Kudinov to discuss [Newsletter #386]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-0-6/415611734-44100-2-abfed94204166.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #386 Recap.
Today, we're going to be talking about a vault-like scheme using blinded MuSig2;
there's a proposal for Bitcoin clients to announce and negotiate P2P feature
support; and then we have our Changing consensus monthly segment this week that
covers a few different topics.  We talk about the 2106 timestamp issue, a couple
of items on CTV, there's a new idea for an opcode for helping out with
consolidation transactions, and then we're going to talk about post-quantum
signatures as well.  This week, Murch, Gustavo, and I are joined by two guests.
Mike, you want to introduce yourself?

**Mikhail Kudinov**: Yeah, hi everyone, my name is Mike.  I recently joined
Blockstream and you probably know me as one of the authors of post-quantum
hash-based signatures for Bitcoin.

**Mike Schmidt**: Awesome.  Thanks for joining us.  And we also have AJ.  Hi,
AJ, who are you?

**Mark Erhardt**: AJ is muted.

**Anthony Towns**: Hi, I'm AJ, I work on Bitcoin Core and have done some
Lightning stuff in the past.  I've been looking at BIPs and consensus changes
stuff over the past couple of years.  So, that's what I'm paying attention to, I
guess.

_Peer feature negotiation_

**Mike Schmidt**: Well, thank you both for joining us.  For those following
along, we're going to go a little bit out of order since we have our guests
here.  We want to make sure we get to their segments first.  So, we're going to
jump to, in the News section, "Peer feature negotiation" proposal.  AJ, you
posted to the Bitcoin-Dev Mailing List, this is a proposal for a new P2P
negotiation mechanism, and this would allow Bitcoin nodes or Bitcoin clients to
announce and negotiate support for optional features, and then maybe we can get
into how that's done now and why what you're proposing is maybe smoother or has
advantages for the Bitcoin Network.  So, what are you trying to get at?  We've
had you on for the template sharing, is this related to that?

**Anthony Towns**: Yeah, so there's a few P2P improvements that I and others
have been thinking about over the past few years.  So, the one I've been working
on has been template sharing.  And the idea there is that nodes that participate
in template sharing will generate a block template, share that with their peers,
and that will be another way of getting the high feerate transactions shared
around, so that If a transaction had missed out, like you'd missed out seeing it
relayed when it was first announced, once it was ready for the next block, you'd
see it that way.  And that would be a little bit more censorship-resistant, a
little bit better for compact block reconstruction and so forth.

But to introduce new P2P functionality like that, we want to introduce new
messages.  And we want to do that in a backwards compatible way so that if I
connect to a node that doesn't support this feature, everything just works
right.  The way we've done that in the past has been a versioning scheme.  So,
every P2P feature bumps the P2P version.  So, I've got no idea what the number
for that is, but it's a constant in the code that just gets incremented by one
every time someone introduces a new feature.  And that works, but it kind of
imposes a centralization thing, where you've kind of got to have a mutex on
incrementing the number, and whoever gets to increment the number gets to put
their feature in for that number.  And also, because it's just a number, if you
say, "I'm doing version 70,020", does that imply you support the feature that
was included in 70,019?  And it kind of has to, but your implementation might
not want to do that at all.

**Mark Erhardt**: Well, at least I think it has to handle the message, right?
You can only increment your version number if you can handle people sending that
new message, right, even if you don't support the feature?

**Anthony Towns**: Yeah, so depending on what the new feature is, it can be
really easy to ignore.  So, if it's just a new message, then you just ignore the
message and maybe everything's fine.  But if you're changing the way that
transactions are relayed, so you're introducing a witness data structure and
maybe old nodes don't understand the witness data structure, you have to have
some additional way of dealing with that.  And so, the features we've done
recently that have had this sort of negotiation in particular have been the
transaction relayed by the wtxid instead of the old txid, and the address v2
relay.  So, that's a different encoding, particularly of Tor v3 addresses to
support the longer Tor strings that we couldn't support with the old encoding.
And when we do those, you've got to choose which encoding you're going to use,
because you're saying, "I've got a transaction, it's this hash".  And if you
send the wrong hash to an old node, that's just going to confuse them and
they'll probably disconnect from you.  And if you send the wrong address format,
they just won't understand it at all and they won't get any addresses to contact
peers at all.

So, when those things were happening, there was a bit of a controversy on the
mail list about how to do it.  And what ended up happening was that we'd both
bump the version number to say, "Hey, there's these new messages that we're
going to send".  And then we'd send some new messages to negotiate whether we
support the new feature.  That was very ad hoc, and that was the way it ended
up.  But the way that it was done was we just introduced the messages first,
particularly for addrv2, and then that caused incompatibility with btcd, which
was seeing this new message and saying, "I don't understand this, I'll just
disconnect".  Yeah, Murch?

**Mark Erhardt**: I believe that some node implementations were strictly not
allowing messages between version and version acknowledgement, and that had sort
of been the gentleman's agreement before.  But now, the feature negotiation, I
think you're proposing, and we had also done that for wtxid relay and P2P v2,
that the negotiation happens between sending the version message and the verack.
So, do you know where that came from, the understanding that no messages are
sent between those two, or why is this the right place now to negotiate?

**Anthony Towns**: I don't know that there is a right place and a wrong place.
It's a matter of opinion, a matter of design, a matter of taste kind of thing.
I think the node implementations that do this are mostly written in other
languages that I haven't been able to fully trace through, so I'm not 100%
confident in exactly what they do or what they did.  But I believe that the idea
is that those implementations would reject unknown messages whenever they
appeared before verack or after verack and disconnect as a result.  And
particularly after verack, that makes some sense, because if you're getting
messages you don't understand, that's a definite waste of bandwidth.  And you'd
prefer nodes to just negotiate things first and only send sensible stuff
through.

The idea was to more explicitly relax that message sent to it before verack,
because that's the negotiation phrase, it's very brief, there are very few
messages, it's not going to have a whole lot of spam, data, whatever happening
there.  So, slightly extending what you accept for a brief period seems less
permissive than doing it forever sort of thing.

**Mark Erhardt**: Right.  So, basically between version message, where you
introduce yourself to the peer, and acknowledging the version message, where you
say, "Okay, we understand each other.  This is the sort of connection that we
want to have", you would add these new feature messages where you're allowed to
communicate which optional features you support and would like to use.  And
then, after the version acknowledgement, basically the terms of the connection
have been set.

**Anthony Towns**: Yeah, exactly.  So, at the moment, we negotiate some things
like what address format, whether we support wtxids, what version of compact
block encoding we support.  And then, the version message itself has a few
things like what service bits we support, whether we're an archival node or not.
And then, the verack is just sent to acknowledge that we've received the
version, we've sent all our negotiation stuff, and we're ready to continue.  So,
once both sides have sent that, then yeah, it's open season.

**Mike Schmidt**: Is it binary?  Like, let's say template sharing, for example,
you just say, "Yes, I support", or not.  Or my understanding is there's also
like a series of bits that you can say what kind of template sharing things you
also support.  And is there a back and forth around that, as an example?

**Anthony Towns**: So, what I'm proposing is that there's no back and forth.
It's just, "These are the things I support and I hear from you the things that
you support, and we just calculate the same result from both those same bits of
data as to what this connection will support".  That aligns with what we've done
with version message stuff.  So, when we receive the different version numbers,
we'll just choose the smaller of the two, and that's the capabilities of the
connection in our current system.  And that, at least in theory, keeps things a
little bit simpler.  The data that gets sent, I'm proposing that it has two
parts to it.  One is an identifier to say which feature we're talking about, and
I'm proposing that be textual, the same as the current message types are.  So,
when we send a tx message, that's the literal character's tx identifying the
message type.  But then the data that's associated with that, the actual
transaction that goes through, is still binary encoded, it's not like a JSON
blob or anything.  And the same thing here.  So, you say, "I support this
feature", and if that feature has customization things the way compact blocks
does, then that goes in binary as a parameter after.

**Mike Schmidt**: Makes sense.  How has feedback been so far, AJ?

**Anthony Towns**: So, I got some private feedback.  I passed it around before I
posted it.  I haven't had any feedback other than this talk since posting it.
That's probably a good sign because usually bad things will get more of a
response, but equally it's been over Christmas and the New Year.

**Mark Erhardt**: Yeah, and I have some experience with the talking to an empty
room!  No, it seems very sensible.  It seems like a good way of making it
possible or more clear which optional features different node implementations
might want to support.  And especially with the advent of lib consensus, or,
well the kernel, Bitcoin kernel, and maybe people running more different
implementations, it makes more sense to be able to negotiate optional feature
support.

**Anthony Towns**: Yeah, and this is much more a proposal that other BIPs can
adopt or choose not to adopt as they see fit.  So, it's not like if your node
implements this, but no BIP that uses it, that's kind of a no-op.  You could
just write that in the docs to say that, "I support this", without actually
writing any code.  So, in that sense, it's not a critical decision where it
becomes important as when it gets used by other BIPs, like the sendtemplate one
eventually.

**Mark Erhardt**: Well, you'd better make sure that you don't reject a node
connection just because they send unknown messages!

**Anthony Towns**: Right.  So, the proposal specifies that you only send these
messages if you have the higher version number that this BIP introduces, which
in theory might be the last higher version number we need, but it's still a
higher version number.  So, if you don't advertise that, you won't see these
anyway.

**Mark Erhardt**: Cool.  That sounds great to me.

**Mike Schmidt**: AJ, what's the steelman against this?  Why could this
potentially have drawbacks or downsides?

**Anthony Towns**: I don't think that there are many downsides to it.  I think
the main objection is likely to be aesthetic, as in you could do pretty much the
same thing this other way, and that would be just as good, and people might
prefer that.  There's a section in the proposal that lists some of the other
ways and why I chose this one.

**Mark Erhardt**: Yeah, I think this strikes me as something that is just, we
would like to have a language for negotiating these features.  And pretty much
as long as you don't do it in a really detrimental way, anything is fine as long
as there's just some language defined.  Well, maybe this is uncharitable, but it
just sort of is like, "Hey, how do we talk about this?  Here's an idea".

**Anthony Towns**: Yeah.  So, we discussed this on the list five years ago or
something, and didn't really come to a conclusion, and have more or less not
introduced new P2P messages since then, because the last time we did it was a
little bit controversial and a little bit buggy.  And having an answer, maybe
even if it's not the perfect one, might allow us to make progress.  And like I
said, this is something BIPs can use.  It's not like, if you come up with a BIP
and don't want to use this proposal, that doesn't introduce an incompatibility.

**Mark Erhardt**: Didn't we introduce package relay messages, or are those not
used yet?  Maybe those are just specified in a BIP, not actually adopted yet.

**Anthony Towns**: Yeah, so we have both Erlay and package relay messages
specified in a BIP with the same negotiation procedure that we used for -- and
also utreexo P2P messages specified in a BIP that all use the same negotiation
message we used for wtxid relay.

**Mark Erhardt**: So, basically, if your proposal got support, we would ask
those other ideas to adopt your scheme of communicating about those features,
but they're already almost compatible.

**Anthony Towns**: Yeah, that would be the idea.

**Mark Erhardt**: Cool.  Sounds great to me.  Where do I sign?

**Mike Schmidt**: Murch, remind me the theory behind how the preferential
peering worked for Sub-sat Summer.  Was it literally just a list of known node
addresses, or were people using the feerate filter to connect to each other?
I'm thinking I'm connecting that with AJ's proposal here, that you're sort of
making it easier to preferential peer with people who share similar capabilities
or values as you do to do something on the network preferential peer subnetwork.
Am I thinking about that right?

**Mark Erhardt**: I mean, this feature negotiation doesn't directly introduce
that capability, but you could add, of course, more logic in the backend that
checks, "What features should I negotiate with my peer, and is this the one that
I want to be preferentially connected to?"  My understanding was that the
low-feerate nodes, that was a list that was passed around manually, and people
just used addnode to connect to additional nodes on that list.  And beyond that,
we already had the configuration option to set the allowed minimum feerate, and
traditionally a number of node operators had run a node with a lower feerate
already.  Like, people had just set it to zero or to other very low values.  So,
low-feerate transactions had basically been floating around in the P2P Network
for a long time already, but they just never got mined.  So, when miners
actually started including them into block templates, it gave these node
operators a little more upwind and they started explicitly making more
connections with other peers that also supported low-feerate transactions, in
order to pass around the low-feerate transactions more quickly.

So, I guess knowing the feature explicitly would make it easier to code up this
preferential peering, but the way I read AJ's proposal, it's not included.  It
doesn't specify stuff about disconnecting when features are not supported.

**Mike Schmidt**: Sure.

**Anthony Towns**: The main thing for preferential peering is not the feature
negotiation so much as the service bit stuff.  So, when you add a service flag
or a feature that also shows up in the DNS feeds, so you can query for nodes
that actually support this feature, and it gets shared around at least somewhat
reliably on the address relay, so you hear about nodes that support the feature,
then you can connect to them, see that they have the feature.  And that was used
with the Libre Relay stuff for them to try and preferentially peer.  I think
there's been some stuff for some of the UASF soft fork ideas, the ones that
don't have lots of miner support, to do that too, but I don't know how advanced
they are.

**Mike Schmidt**: Well, I think we did this one pretty good.  AJ, anything else?
It sounds like you're going to continue to work on this, you're looking for
feedback.  Anything else you'd call the listeners to do?

**Anthony Towns**: Comment on the mailing list if you have further thoughts and
comment on the BIP PR once that's up if you have any further thoughts.  And if
you're writing a BIP or implementing a BIP that uses it, then see about using
it.

**Mike Schmidt**: AJ, thanks for your time.  Thanks for joining us.

**Anthony Towns**: Thanks, I'll stay on.

_Hash-based signatures for Bitcoin's post-quantum future_

**Mike Schmidt**: All right, great.  We're going to jump to the Changing
consensus segment and the last item there titled, "Hash-based signatures for
Bitcoin's post-quantum future".  Mike, you and Jonas Nick posted about
evaluating hash-based signature schemes post-quantum for Bitcoin, and you found
that there were significant optimization opportunities in signature sizes.  And
I guess I'll just use that as the lead-in.  You take that where you want it.
You guys had a paper about this.  Maybe you want to get into why you're looking
at this, what you're looking into and what you found.

**Mikhail Kudinov**: So, yes, we started looking at possible options for
post-quantum solutions for Bitcoin.  And from our perspective, I think
hash-based is one of the first options to look at, because it doesn't introduce
any new assumptions, rather than a secure hash function that is already used
inside Bitcoin.  There can be some debate if one can want to use a different
hash function in the signature, but let's keep it out of the topic for now.  For
now, we will also focus on SHA256 essentially, maybe with a trimmed output.  And
hash-based signatures, while they are somewhat simple in their construction,
there is quite some variety of options and trade-offs you can use.  First of
all, now known, SPHINCS+ SLH-DSA.  It's a hash-based signature scheme that was
standardized by NIST as a post-quantum alternative for signatures.  And this is
kind of a basic option to go to.  But SPHINCS+ signatures are somewhere around 8
kB size.  So, this is quite something.  And if you want to go lower, then you
have to start to play around.

The first and crucial observation is that hash-based signatures are very
dependent on the number of allowed signing operations.  So, usually, for
example, in ECDSA, you don't care much.  I don't think anyone ever talked about
how many signings can you do with a single keypair.  For hash-based signatures,
it's actually important.  So, NIST had this requirement of the signature scheme
to support 2<sup>64</sup> signing operations, which is a huge number essentially
chosen, so that for any practical scenario, you don't care about it.  It's
essentially like, "Okay, I can sign as many as I want.  I don't care".  And if
you say, "Okay, in my use case, I'm sure that I will be signing a much smaller
number", then this gives you a very significant performance boost.  So, by
allowing, for example, 2<sup>34</sup>, probably I think it almost halves the
signature size.  It's more or less, I don't know, 5 kB, maybe 4 kB, something
like this.

**Mark Erhardt**: Quick question.  So, 2<sup>64</sup> is obviously enormous.
That is sextillions, or something, 10<sup>19</sup> I think.  And so, we are very
fond of people not reusing addresses.  So, for the most part, for our output
types, wouldn't we be fine with a very low number of signatures, more like on
the order of less than 100 is fine.  Would that make it less secure?

**Mikhail Kudinov**: So, the comfortable amount of signatures that we are happy
to allow is the question that we're also happy to discuss with the community.
So, one thing to look at is, okay, yes, we don't want to reuse addresses, and
stuff like this.  Most of the time, maybe you're even just using a single
signature and then you move to a new keypair.  Just a one-time signature
probably is not the best idea, maybe you misused it or something, so maybe let's
have some more.

**Mark Erhardt**: Yeah, one time is bad because we'll need to be able to RBF,
and things like that.  So, we do need to be able to make multiple signatures,
but yeah.

**Mikhail Kudinov**: Exactly.  And then the question rises, how many more?
First is that there is still a possibility of reusing addresses.  For some
scenarios, it's important, for example people put their addresses online and
get, I don't know, donations.  Updating it over and over again can be difficult.
Next, we also thought about layer 2.  In layer 2, you want to create more
signatures that they don't end up on the layer 1, but you're still publishing
those and they are visible.  And so, if you go over the budget, your security is
destroyed.  So, the number that we are happy to end up with is a question of
debate.  When we say a low number such as, for example, 100, then we're also
coming into a realm of so-called stateful signatures.  What does stateful mean?
This is again, ECDSA is essentially a stateless scheme, but no one talked about
it because there was nothing to compare.  Here, for hash-based, you have two
types of possible options, stateful and stateless.  And a stateful scheme is a
scheme that for each signing operation, you need to update your secret key.  And
for example, if you're only allowed to do 100 signatures, that you technically
can do pretty fast, you should with each signing operation count, and if you go
over the budget, you're screwed.  So, you have to be careful about it.

The SPHINCS+ is called stateless, because you don't need to update your
security.  And then, we can go with a lower number, as I said, for example
2<sup>30</sup>.  And still, maybe we can still consider it stateless since we're
thinking that we'll actually be using less than 100.  And so, a boundary on
2<sup>30</sup> is essentially, with even a margin on top, you will still never
run into it.

**Mark Erhardt**: For our listeners, 2<sup>32</sup> is 4 billion, I believe.
So, there's quite a margin between 100 and 2<sup>32</sup>.

**Mikhail Kudinov**: Yeah, so we did some kind of comparisons to the real-world
counting of how many blocks will 2<sup>32</sup> signatures feel.  I think it was
something more than a year or two years, something like this.  If just one
person would be signing and putting 3-kB signatures in the blockchain, he would
fill two years, maybe, this is a rough number.  So, yeah, so this is the first
thing to decide, where to set this boundary.  And the second thing, as I said,
stateful versus stateless, because again, if we still do a big number,
2<sup>30</sup>, but we can do stateful, this can also reduce the signature size.
But this stateful, it is very important to understand that it is difficult to
handle this updating of secret key, because for example if you have two signing
devices, they must be either synchronized with each other or they should have a
sort of partition of, okay, this device is signing only with this, I don't know,
iterations, and this one, they should have different subsets of signing.

**Mark Erhardt**: Like, one uses even, one uses odd, or something.  So, they
never use the same secret keys.

**Mikhail Kudinov**: Yes.  And then, backup-ing.  If you've lost, then you need
to kind of have a safety.  There was also a nice idea proposed, I think, in the
appendix of our paper, where we can combine with essentially a merkle tree.
From the left, we do a stateful, and on the right, we do a stateless.  And then,
you're using stateful until you're sure that your state is secure.  And for
example, if you need to backup your wallet, then you go to the stateless version
that is less efficient but it's safe to use.  This also has its downsides.
Essentially, you're introducing two signatures instead of kind of one, and then
this mismanagement can still happen.

**Mark Erhardt**: Sorry, just to understand that right, you are proposing that
in our taproot tree or other way of spending the outputs, we would have two
different schemes of spending, where the stateful one is basically on the online
device that keeps track of state easily; and you could have, for example, the
stateless one used with hardware signers, or after you have multiple copies.
And you would basically have these two alternative signing mechanisms rather
than just a single one?

**Mikhail Kudinov**: Almost.  One can see them as like two different schemes,
one can look at these two different schemes as one big scheme, and so that would
use the same kind of secret seed to generate the whole thing.  So, the details
may be a little bit different, but essentially the idea is, yes, you have kind
of two options of signing.  One is stateful, one is stateless, and you only use
the second option when you think you mismanaged your state.

Here, I think I want to mention also that, for example, speaking of reducing the
number of signatures, the National Institute of Standards of USA, running this
post-quantum competition for selecting the algorithm, they are now also
considering reducing this boundary on the number of allowed signing for certain
scenarios.  For their cases, they mostly consider kind of root CAs,
Certification Authorities, that do very little signing, so one can do again
lower there.  So, this is not some crazy new idea.  This is what has been
discussed even out of Bitcoin space.

**Mark Erhardt**: Maybe a follow up question.  So, you said that using the
stateful signing scheme would enable you to have even smaller signatures.  You
originally said something about 8 kB for a SPHINCS signature, and then you
mentioned 3 kB.  Is 3 kB already the reduced size, or is that just an
optimization of the stateless one?

**Mikhail Kudinov**: For stateful, there are also possible trade-offs there.
The lowest number I think you can get is somewhere around 380 bytes.  So, this
is very little compared to the original number.

**Mark Erhardt**: That's only 8X increase or so.  We're almost getting there!

**Mikhail Kudinov**: But this thing, such an option, will grow with each new
signing.  So, the first signature will be 380 bytes.  The next one will be
bigger.  I don't remember how much bigger, but it will grow pretty fast.

**Mike Schmidt**: That's good, because we don't want you to do that!

**Mark Erhardt**: Well, it makes address reuse more expensive and it makes RBF
more expensive.

**Mikhail Kudinov**: Yeah.  And again, you can always switch.  For example,
again, you're growing, growing, growing, and then when your growth becomes more
expensive than using a stateless, for example, option, you can jump to that one.
If you use a balanced version, a balanced means that each signing in the
stateful will be the same, then the performance is not that great.  I think you
can maybe go away with something like 2 kB or 2.5 kB for a low number of
signatures there.

**Mark Erhardt**: So, if it doubles every time and you start with 380, that
gives you something like four signatures before you reach that size.  So, at
this point currently, I'd say the 380 sounds better.  Are there other trade-offs
too?

**Mikhail Kudinov**: Yes.  So, here we're talking kind of this is the major
things that affects number of signatures, and stateful versus stateless.  And
next, we have different optimizations that essentially just appeared after the
SPHINCS+ was already selected.  And some of those optimizations were even
discussed inside of the community, whether to adopt them or not, but essentially
people decided we'll almost publish the standard, let's not change things up.
And those optimizations just change the scheme internal mechanisms a little bit
here and there.  Security-wise, they're essentially keeping the same
conservative security guarantees.  Maybe it's slightly different theoretical
assumptions, but yeah, I would say high-level view is that the security stays
the same and they give some sizes boost.  So, I think with each of the
optimizations, you can save a couple of hundred kB.

There is also a nice trade-off between the signature size and the signing time.
So, these optimizations essentially force the signer to do some extra work to
find certain nicer values.  And the nicer the value, the smaller the signature.
And then, we can push the signer really hard.  They will have to sign, I don't
know, for a couple of seconds or, I don't know, we can push really hard and then
it will shrink more.  Or we say, okay, we have this hardware wallet and it's a
low power device.  If we push too hard, this will take too much time and the
user will be very unhappy with it.  So, let's not push that much so we can
require from the signer to do a bit less, and then we will have slightly less
savings in the signature size.

**Mark Erhardt**: Yeah, that was what I was going to ask, how does that interact
with hardware signers?  Would it be possible to do signatures with hardware
signers?  So, you can answer that already.

**Mikhail Kudinov**: It would be possible, but to answer precisely which
parameters to use, this is what is highly kind of, we want to excite our
listeners and the readers or the community to do as much benchmarking as they
want to, choose the scheme that you like, follow our discussion.  If you can
implement it on a hardware device, on your laptop, different languages,
different parameters, and post some benchmarks, how long did it take you?
Because for now in the paper, we estimate, based on some estimation of how much
time the SHA evaluation will go.  This was kind of the number of SHA evaluations
for SPHINCS+, this is relative SHA evaluations for these different proposed
schemes.

**Mark Erhardt**: Yeah, maybe the general question that comes to mind is, would
it generally be possible to do signatures with a hardware signer, because they
usually have very little memory, these signatures are pretty big, there might be
a lot of computation.  So, if it's generally possible, that might be acceptable.
Most people don't do that many transactions, at most maybe a few per day.  So,
if they know that it'll take a long time, they could just, say, let their
hardware device calculate for a minute, and then they get half the price on
their transaction.  That might be an acceptable trade-off, as long as they know
in advance, okay, this might take a couple of minutes, or whatever.  But I'm
just sort of wondering whether embedded devices are even capable of this
performance at all.

**Mikhail Kudinov**: I think they should be, but this is not something that we
precisely checked.  So, this is a good option also to look at.  There are also
different types of implementation.  Some of them can, for example, streamline
the signature.  This can be also an option, because you don't need to store all
of the signature.  If you can just streamline parts of it, maybe this is also an
option.

**Mark Erhardt**: So, you mean to stream it to the companion device?

**Mikhail Kudinov**: Yes.

**Mark Erhardt**: Okay, like just not send all of it at once, but in chunks.
Okay.  Yeah, so you put out a bunch of abstract explorations of the topic and
you came up with a number of nice optimizations.  Is the 380-bytes signature
that you mentioned, does that look like the state of the art at this time?

**Mikhail Kudinov**: So, let me check our table.  So, I think what we have, we
have two tables.  One table is sharing about the bound on the number of
signatures is 2<sup>40</sup>, 2<sup>30</sup>, 2<sup>20</sup>.  These are the
options that we consider kind of to be still in the stateless area.  I think
2<sup>20</sup> is already a little bit closer to, 'one needs to be careful'.

**Mark Erhardt**: Yeah, it's about a million.

**Mikhail Kudinov**: Yeah.  So, with 2<sup>30</sup>, I think the lowest
signature size that we have in the table is 3.5 kB roughly.  And for
2<sup>20</sup>, something around 3 kB.  Here, one has to mention that we didn't
run kind of a full brute force of possible options.  Maybe there is some
slightly better parameters, but I would say nothing will impress.  If we stay in
the same boundary on the number of signatures, maybe we can find something that
is 3,300 instead of 3,500, but nothing drastically.  Even 3,300, I highly doubt.
But yeah, so for stateless options, I think 3,500 for 2<sup>30</sup>, around
3,000 for 2<sup>20</sup>, for 2<sup>40</sup> is essentially 4,000.  So, 10 in
the exponent gives you around 500 bytes.

Speaking of these optimizations, that kind of small, small blocks inside, this
is another question that was raised in the mailing list.  It's like, "Oh, we
have SPHINCS+.  If we just reduce the number of signatures and don't change
anything else, maybe we can reuse other implementations or they will be out of
their support, because it is used outside of Bitcoin and we can reuse those
stuff".  Maybe yes, maybe no; here, I'm less aware.  People argued as well that
Bitcoin is sufficient just to force companies to introduce hardware support on
its own.  So, maybe we should not rely so much on it.  Security-wise, I would
say these modifications don't introduce new problems.  Implementation-wise, yes,
there will be implementations that are kind of SPHINCS+ and you would have to
change them.  These new optimizations, some of them are very little in terms of
their implementation changes, some of them a little bit more.  But in general, I
think hash-based signatures, kind of comprehensive-wise, is not
super-complicated.

Of course, having a lot of implementations is beneficial.  Would you want to pay
maybe 200 bytes for reusing implementation?  Maybe yes, maybe no.

**Mark Erhardt**: I think there was also a concern that NIST in the past has put
out schemes that might have been vulnerable in some ways to make them easier to
crack.  So, having some changes that are Bitcoin-specific might make it more
secure in that regard.

**Mikhail Kudinov**: Here, I would say we are pretty safe, unless the hash
function is secure that we're using inside.  I was working also on the security
proof on the SPHINCS+ during the NIST competition.  Essentially, you can show
that if you can break the scheme, you can break the hash function in some way or
another.  So, in that regard, I would say it's pretty safe from backdoors.

**Mark Erhardt**: Okay, that's good to hear.  I had one more question and that
was, we discussed, I think last week or a couple of weeks ago, well, not last
week, but last episode or two episodes ago, some exploratory work by Conduition.
And I was wondering whether you had seen that and had any comments.

**Mikhail Kudinov**: Yes.  That was great work, I think.  I also highly
recommend to look on it for people who didn't see that.  So, I think a short
summary of what he did, he took SPHINCS+ and then he tried to implement it with
as much parallelization as possible, and then showed some benchmark.  This is
really cool work and shows you how much speed-up you can have with a nice, very
optimized implementation.  We also asked if he could look at possible deviations
from the schemes proposed in the PDF.  He, I think, agreed and maybe we will see
some extra numbers for these optimized or deviated schemes.  The question is
also whether most of the implementations or hardware, software wallets will
support this parallelized option.  So, one thing is very nice to see how far can
you go, but then we also need to look at how far on average will people go.
This is a very highly optimized version.  I think it has some intermediate
steps, it's like, "Okay, I optimized this part, I ran it, these are the
benchmarks.  Then I did some more, then I did some more", so there, you can also
see some middle ground there.

**Mark Erhardt**: So, basically, Conduition did a lot of work on performance of
implementations for SPHINCS.  And if we decided to go with a SPHINCS-based
signature scheme, that would probably help implementers get to really optimized
implementations of SPHINCS.  But you'd be interested in also seeing what a basic
implementation of SPHINCS+ would perform like, because maybe most implementers
wouldn't go that far and put in all that effort for all these optimizations, and
it would still have to be performant enough for them to use if they use a
simpler implementation.  Cool, thank you.

**Mike Schmidt**: Maybe one last question.  Mike, do you believe that it's
prudent for Bitcoin to avoid non-hash-based signature schemes for post-quantum?
Should lattice just be not considered in your mind, or how do you think about
that?

**Mikhail Kudinov**: I think lattices should be considered.  Let's not
immediately kick them out, because the main problem with hash-based is that you
cannot do much fancy stuff.  So, for example, you cannot do public key
derivations.  So, you cannot have your software wallet to generate public keys
that your hardware wallet will be able to sign for.  Or, we also looked a little
bit at possible multisignatures and threshold signatures.  There are some
approaches, but essentially none of them are good.  Essentially, I would say you
cannot do this.  And latest based is very promising in that regard.  We are
planning to look at what is the performance there, what you actually can do, how
much is it better, and stuff like this.

In terms of security device, I would say, yes, the lattices were for quite some
times, and then the crypto analysis during the standardization process before
and after it is very active in that field.  Yes, there can be some improvement
in this crypto analysis and some numbers could go lower.  So, maybe it is also
interesting to look at some more security margins.  For example, hash-based, we
looked at the hash function output, essentially 128 bits, which gives you 128
classical security.  Maybe for lattices, we want to have a little bit of a
margin.  But maybe even with the margin, it can still perform a little bit
better and offer us nice features that hash-based schemes lack.

**Mark Erhardt**: So, with the lattice-based post-quantum algorithms, we might
be able to have significantly smaller signatures.  But my understanding is that
the lattice-based constructions are much newer and a bunch of them got broken
during the competition too.  So, there might still be just a little more work
until they are proven as secure as something simple like hash-based signatures.

**Mikhail Kudinov**: So, first of all, the signatures can be smaller.  Some of
them actually might be on the same kind of 3-kB size.  The default kind of, yes,
it is much smaller than SPHINCS+.  If we're thinking about this optimized
SPHINCS+, then for some schemes it can be matching, for some schemes it can be
actually quite small.  Again, there are certain problems to think about.  In
terms of security, yes, there were some schemes that were broken.  But
essentially, they were just bad proposals.  There were, I think, the biggest
number of lattice-based schemes that got to the final round before choosing what
to standardize, and this was the main idea of which will the NIST actually
choose.  And I think currently the schemes are pretty solid.  And again, they're
standardized, they will be used nationwide to protect, I don't know, digital
communications sooner or later.

People say, okay, in the real world, you can update your parameters easily.  So,
maybe you can choose these parameters that you're happy now.  If you see some
improvement in the crypto analysis, most likely it will not be a huge jump in a
day.  It will just grow a little bit, so you would be able to just select bigger
number of, I don't know, dimension or whatever.  For Bitcoin, we don't want to
update our parameters regularly.  So, that's why I say maybe we can just put a
little bit of margin there.

**Mark Erhardt**: Okay, thank you.  That was very insightful.

**Mike Schmidt**: Well, I think that was a good deep dive.  Obviously, folks can
go deeper and actually jump into the paper.  I think we already have a call to
action from Mike here for the audience, which is experiment and tweak the
parameters and do some benchmarking and then report back to him and Jonas and
the mailing list.  Anything else, Mike, before we move on?

**Mikhail Kudinov**: Maybe don't be scared, because we also tried to write this
paper very introductory.  We start from essentially very beginning and try to
introduce these concepts step by step.  So, even if you didn't work before with
hash-based schemes, take a look.  It will not be as scary as you might think.

**Mark Erhardt**: Maybe one more question.  As we have been seeing the quantum
debate in the Bitcoin community bubble up and become a little hyped in the past
few weeks, how worried are you about quantum computers arriving soon, and how
soon?

**Mikhail Kudinov**: Again, this is the problem with this discussion.  It's so
heated because no one knows.  No one can give you a definite answer, this will
not arrive until then, or it will arrive at this time.  From my perspective,
being a non-quantum physicist, or I'm not involved in developing quantum
computers, I wouldn't expect them to arrive in the nearest future, in a couple
or few years from now on.  On a longer term, maybe in 19, 15 years maybe, yes.
But this is so speculative because we see a lot of development, both from the
hardware side and from the algorithmic side, because obviously for this
algorithm, you need this heavy hardware machinery to run, I don't know, schnorr
algorithm.  If you improve the algorithm to require less qubits and less gates
and stuff like this, this kind of brings the timeline closer and closer.  And we
see improvements both in the hardware and in the algorithms.  There was recently
like a decrease of by 20 times in the number of qubits required to run such
algorithms.

So, I think the main message here is, we need to prepare.  We cannot be early to
be ready.  Maybe we have a lot of topics to discuss, we have a lot of topics to
agree on inside of the community, and then it's better to be ready and just
maybe not use it until sometime.  Then we get caught spontaneously and say, "Oh,
we should have…"

**Mark Erhardt**: Okay, yeah.  So, the time to prepare is now, but we are also
not super-worried that we are already late.  If we're doing research now and
working on implementing a new output type or scripts that can handle
post-quantum signatures or introduce the utility to the Bitcoin network, we're
still in a good time?

**Mikhail Kudinov**: That is my feeling again.  There is no one can say I can
prove it to you, but yeah, this is how I see the situation.

**Mike Schmidt**: Mike, thanks for joining us.  We appreciate your time and
hanging on and chatting to us about this.

**Mikhail Kudinov**: Thank you for having me.

**Mike Schmidt**: Yeah, cheers.  We were being conscientious of our guests'
time, but we did want to bring up an item that is not in the newsletter for this
past week that we're working on covering for the newsletter this week in some
capacity, which is this wallet migration failure notice from Bitcoin Core.  So,
there was a post yesterday in the bitcoincore.org blog, as well as some of the
social media content that noted that in some rare cases, when you migrate a
wallet from essentially the legacy format to the more modern format that we've
covered here on the show several times, under some circumstances, including if
you're using an unnamed wallet.dat file, so " ", just empty quotes name for your
wallet, it can result in wallet data being deleted from the wallet folder, aka
risk of loss of funds if that cluster of conditions aligns.  Murch, you probably
have more technical things to say about this, but is it correct to say that it's
only when migrating, that it's a seemingly rare circumstance, and that it does
or can result in loss of funds, assuming that in that scenario, somebody didn't
have a backup of those files?

**Mark Erhardt**: So, very specifically, this only applies to legacy wallets,
legacy unnamed wallets, which the Bitcoin Core wallet has not been creating for
the past five years.  It only happens for unnamed wallets.  So, I think for the
last five years, Bitcoin Core has forced you to pick a name for your wallet, so
that also doesn't apply anymore.  And it only happens when the migration fails.
So, this could, for example, happen when you are running a pruned node and your
wallet was not loaded while you were pruning.  So, some of the history the
wallet would need to catch up on is not there and you try to migrate the
previously unloaded wallet.  So, you have a wallet that is probably at least
over five years old, you have been pruning, you are now loading the wallet in
and migrating it while the node was pruned and doesn't have the history that it
needs to prune.

There might be some other circumstances, like if you did a lot of very custom
things to your wallet, there might be other reasons why the migration doesn't
succeed.  And so, in this case, in all of these circumstances, it is possible
that the wallet's directory gets deleted, because the migration fails and in the
cleanup of the failed migration, because the wallet was unnamed, it deletes the
wallet's directory instead of the directory for the migrated wallet.

So, what we have done is we have pulled the Bitcoin Core 30.0 and 30.1 binaries
from the Bitcoin Core website for the time being.  There will be a 30.2 release
soon that fixes this issue.  And very specifically, if you have a very old
wallet, we would recommend that you do not attempt to migrate it at this time.
Now I hope that this will not cause any loss of funds because if you have a more
than five-year-old wallet, hopefully you have several backups somewhere else.
But this is, of course, still scary in the sense that v30 is the one that
removes the legacy wallet.  So, if you want to continue to use your Bitcoin Core
wallet and you had a very old Bitcoin Core wallet, this version would force you
to migrate it to a descriptor wallet, because legacy wallets cannot be loaded
anymore except for migration, which is why we pulled the binaries for the two
releases from the Bitcoin Core website.

So, please, if you have an extremely old wallet, or generally a legacy wallet,
we recommend that you do not attempt to migrate at this time, wait for the 30.2
release.  You could also migrate it to a descriptor wallet with an older
release, like a 29.2 release.  The bug is only present in the major branch 30.
So, if you want to continue using the latest version, you could migrate it with
an old version and then continue using it on the new version.  Yeah, that is my
understanding so far.  Yeah, this is obviously pretty terrible with the
potential outcome that the wallet's directory is deleted.  But if you ever do a
migration, I hope you would also do a backup of your wallet before you attempt a
migration.  I think that is a reasonable expectation.  So, again, hopefully,
please don't lose any funds, but please be aware that this issue exists.  And if
you're running a legacy wallet and want to upgrade, please wait for 30.2.

**Mike Schmidt**: Yeah, obviously it's terrible that there's a loss-of-fund
potential and I'm sure there's going to be folks looking at exactly how all that
happened, and maybe there'll be more information on that.  A couple of things to
add to what Murch said.  The binaries are still on the bitcoincore.org website,
but I think they're just moved out of being linked to from the releases page,
and things like that.  I think there's a subdirectory that has those in there if
you need it.  And maybe just to reiterate what Murch I think made clear, just if
you're not using the wallet, you're fine.  If you're using the wallet and it's
working for you and you don't need to migrate it, you already migrated it or it
already was a non-legacy or descriptor wallet, you're fine and you can continue
using it.  It's strictly the act of migrating an old wallet to a new wallet, an
unnamed wallet specifically.  But probably to be safe, you probably don't want
to do any wallet migrations using these two softwares until the 30.2 is
released.

I do see that there is a draft PR for 30.2rc1 on bitcoincore.org website.  We
will try to cover this topic and get the word out to as many folks as we can in
the newsletter on Friday, with up-to-date information.  And I assume there will
be a PR associated with this fix that we will also cover in the Notable code
segment at some point.  So, we will keep you all up to date, but do not do any
wallet migrations with 30.0 releases right now.  Anything else, Murch?  Okay.

**Mark Erhardt**: No, that covers it.  Thank you.

_Building a vault using blinded co-signers_

**Mike Schmidt**: Okay, a couple jumbled things out of order, but we're going to
go back to the News section and we're going to go to the first news item titled,
"Building a vault using blinded co-signers".  This was a news item motivated by
Johan Halseth's post to Delving, and he posted a vault-like construction.  So,
we've talked about vaults previously on the show here.  And this particular
vault construction uses MuSig2 blinded version as co-signers.  I hadn't dug into
the blinded variant of MuSig2.  And you'll see in the newsletter, we actually
link to the blinded version, which is actually also by Halseth as well.  And the
idea with this proposal, and there's also proof of concept attached to it, is to
prevent blind signing while still preserving signer privacy.  So, each signing
request includes this zero-knowledge proof showing that the transaction that the
signer is about to sign for satisfies some conditions.  And in the example that
he gave, it was this timelock, and I think there's also some coordination around
MuSig2 that needs to be done, aggregating things and nonces that's above my pay
grade, that essentially is attested to with this proof so that the blind signer
can sign knowing that it's not just signing anything that comes to it, that
there is some criteria.  Yeah, go ahead Murch.

**Mark Erhardt**: Yeah, let me just jump in quickly, because there's a bit of a
contradiction here.  We're using blinded signing, but the signers are not
blindly signing.  So, the idea here is that you basically have a co-signer that
is set up to provide a signature and enable you to spend your funds, and you
would provide them a zero-knowledge proof that what they're signing adheres to
the policies that you've set up with them.  So, they are capable of checking
that you should be allowed to make the transaction, but they don't actually
learn the transaction that you're signing.  So, they're blind to the actual
content of what they're signing, but they are not signing without any checks,
because then it would be pointless.  If someone just signs anything you give to
them, obviously there's no security benefit from it, except maybe the secret
knowledge of whom to give it to for the signature.  But yeah, so this is blinded
signing versus blindly signing.

**Mike Schmidt**: So, the nice thing about this approach, obviously, is it
doesn't require any consensus changes, which we had the vault BIP at some point,
we have CTV (CHECKTEMPLATEVERIFY), we have all kinds of covenant things that can
do vault-y things.  But this approach, you don't need any changes to Bitcoin to
satisfy that.  Obviously, it has its own potential drawbacks.  There's actually,
Johan put a prototype implementation that's available for signet.  So, you can
play with some signet coins on there and see how it works.  And there's some
diagrams and links to some of the content he has on GitHub around blinded MuSig2
and the architecture of this approach.  So, a lot of thorough work in there for
folks who are curious about these sorts of things, dig in and provide feedback.

_Year 2106 timestamp overflow uint64 migration_

Okay, jumping back to the Changing consensus segment, we have two items on the
2106 timestamp overflow issue.  First one, "Year 2106 timestamp overflow uint64
migration".  So, this is the first of the two.  This person is somewhat
alarmingly, alarmistly, saying -- okay, well maybe we should frame this a bit.
So, the Bitcoin's block header timestamp uses 32 bits.  At some point, that
fills up.  That's the year 2106 problem that people have talked about that,
"Hey, there may need to be a hard fork or maybe somebody can come up with a
creative software way to get around this".

**Mark Erhardt**: Yeah, basically, so the way we write timestamps in blocks will
eventually overflow.  And because we use an unsigned 32-bit integer there, we
have until 2106 until that happens.  And some people might want to use
timelocks, or whatever, to lock funds for 100 years, allegedly.  I don't think
that's a great idea, but some people might want to do that.  And if that were
the case, this timestamp issue might come to pass.  I must admit, I struggle a
little bit with the motivation here, because you could still lock your funds up
to that time just using block heights, which works perfectly fine.  I think we
cannot express times in the timelock that are bigger than 2036 anyway, because
that uses a signed integer.  So, the time frame until that is reached is half of
that until the unsigned integer overflows.  And so, we can't express timelocks
bigger than 2036 anyway, so I just don't really see how 2106 could be pressing.

Also, we do probably want to have some sort of hard fork where when that
timestamp overflows, either we start using 64-bit timestamps, although that
would just really be a lot of extra data in the block headers, so maybe we'll
just start counting from zero.  And after a certain number of blocks in the, I
don't know how many millions, we allow timestamps to overflow and start at zero
again, and we treat that as added to 2106.  So, there's a few pretty simple hard
forks that we could do that allow this to be handled without any problems.  And
it seems a little premature to be worried about something that won't affect us
for another 81 years, 80 years, sorry, it's 2026 now, yeah.

**Mike Schmidt**: What year is it?  Yeah, I think some of the examples from the
write-up, you know, "30-year bonds issued in 2080, that would be broken".

**Mark Erhardt**: I mean, even if they were broken, we can't express timelocks
like that anyway, because we use a signed integer in script.

**Anthony Towns**: We don't use a signed integer in locktime, so you can still
do it with pre-signed transactions though, right?

**Mark Erhardt**: Yeah, with presigned transactions, yes.  But just use block
height, right?

_Relax BIP54 timestamp restriction for 2106 soft fork_

**Mike Schmidt**: Merge touched on a potential mitigation to this, but this can
also lead us into the second news item related to this, which is, "Relax BIP54
timestamp restriction for 2106 soft fork".  So, this could be a way to mitigate
this timestamp overflow issue as a soft fork as opposed to a hard fork.  And
this gets into BIP54, which is the consensus cleanup, and its tightening of
timestamp restrictions to combat the timewarp vulnerability.  And by tightening
that up, you lose the ability to, I guess, exploit it for good, which would be
potentially the idea that Josh brought up here in his post, saying, "H1ey, we
could use essentially this off-by-one timewarp vulnerability to essentially slow
down time and make it so that each epoch is like one second, or something like
that, so that we never have to worry about the timestamp overflowing.  I'm sure
I missed some of the nuance there.  But, Murch, obviously that would ruin things
like timelocks as well if time just slowed down, right?

**Mark Erhardt**: Yeah, so I must admit I haven't dug too deeply into this one.
But my understanding is that instead of fixing timewarp, we could use the
timewarp bug to pretend that the time is flowing shorter, and then we can have
some shit-fuckery to pretend that that we can fit all of those timestamps into
the existing number and we could soft fork a fix that way.  And I think while we
have been avoiding hard forks so far because they have a very great potential to
split the network and fork off nodes from the network, I think that making a
hard fork fix to such a clear-cut issue in the next 80 years is in the realm of
quite doable things.  So, I just don't think that this sort of convoluted
solution that potentially reintroduces timewarp issues and so forth, that we're
just finally getting around to fixing with the consensus cleanup, would be
attractive compared to just, "Well, let's allow the timestamp to overflow or to
be bigger after it runs out".

The simplest fix that I can think of is when the timestamp overflows, we change
the encoding of timestamps to be bigger so we can encode times that are greater.
And we have 80 years to do this presumably 15-line code change and roll it out
to the network.  Seems drastically more attractive to me.

**Mike Schmidt**: Well, and you touched on a point that came up in the
discussion.  I think this discussion happened on the mailing list and Delving.
And I think what I'm referencing is on the Delving portion of it.  And it was
brought up at your point, Murch, that we want to avoid forking people off of the
network or onto a separate chain.  But the good news here, I guess you could
phrase it, is that people who don't upgrade would just stop and not actually be
on some alternate chain.  And so, maybe that is a distinguishing feature of this
hard fork versus other potential hard forks.

**Mark Erhardt**: Also, basically, we just need to decide how we want to solve
it in the next 80 years.  And then, in 80 years, people have to be upgraded.
And if you're not going to upgrade your software for 80 years, I don't know what
universe you're living in.  But I think that coordinating a hard fork, the hard
part will be to not lose track of it and to actually have the same thing
implemented in all the software.  But that point is in 80 years.  So, I'm just
not getting worked up about this problem for the next 60 years, if I even have
that much time.  AJ, you've been quite active in this discussion.  Are we
missing anything here?

**Anthony Towns**: No, I don't think so.

_Understanding and mitigating a CTV footgun_

**Mike Schmidt**: All right.  Next Changing consensus item, "Understanding and
mitigating a CTV footgun".  This was a post from Chris Stewart.  He opened a
Delving thread about a known footgun with OP_CHECKTEMPLATEVERIFY.  The scenario
is if, and I hope I get this right when I explain this, if the amount in an
unconditionally enforced CTV template is less than the sum of the output
amounts, outputs can be permanently unspendable.  The example that was given, at
some point, suppose someone creates a template address which forwards 1 bitcoin
to cold storage.  If you create an output to that address that's less than 1
bitcoin, that bitcoin will be frozen permanently, because you cannot satisfy the
condition.  That's what really helped me understand it.  But maybe, Murch, you
can summarize the general idea a bit better.

**Mark Erhardt**: Yeah, I was going to make a similar example.  But the general
idea is you probably don't want to hand out addresses that encode a script that
relies on CTV with a specific amount, because people might send smaller amounts
to it.  If you're doing this yourself and you have a 1-bitcoin UTXO, and then
you assume that you'll be able to send 1 bitcoin to the recipient, you might
actually be able to do that by negotiating an out-of-band payment for a miner to
put the zero-fee transaction into the blockchain.  But if you hand out an
address that requires, I don't know, 1 millibitcoin to be sent somewhere and
someone sends 2 millibitcoins to it, you might be forced to burn 1 millibitcoin
in fees; or vice versa, if it's smaller, you would just simply be unable to
spend it at all, because it can only be spent with that transaction, and the
transaction requires a larger amount to be sent to the output than is available
on the input side.

So, this is generally an issue with all sorts of covenant constructions.  And I
think it is sort of a reason why you wouldn't hand out addresses that encode
covenants, but rather use them as raw scripts.  But I don't know how much of an
issue this is in practice if you just avoid giving out addresses that encode
this.  AJ, you've thought a ton about this sort of stuff.  Can you enlighten us
a little more?

**Anthony Towns**: So, I mean, the footgun is like a general thing that you can
do today.  If you give out a scriptPubKey, that's an OP_RETURN statement and
someone sends funds to it, those funds can't ever be spent.  So, I don't think
of it as something special to covenants.  It's just the script encodes rules
that won't ever be allowed to be spent.  So, if you send some coins there, then
they're lost and that's fine.  So, whether you can spend funds depends on the
rules that are being enforced by the script.  So, if your rules are, "You must
send this amount of coins and can have no other inputs", then that's an easy
footgun.  If you can express more complicated rules, like, "All the funds from
this address must go to this particular output", which was what the OP_VAULTS
stuff, I think, was designed to allow you to specify, then writing scripts that
way lets you avoid the footgun entirely, if you've got an expressive enough
scripting language to actually write that at all.

**Mark Erhardt**: Yeah I think that specifically is really easy to do with
OP_CHECKCONTRACTVERIFY (CCV) which is a proposal by Salvatore Ingala.  And I
think that that was sort of put as an example of how CCV might be more flexible
and less footgun-y than CTV.

**Mike Schmidt**: Yeah, I think Brandon Black brought that up as a response to
Chris's post, BIP443.

_CTV activation meeting_

Well, we have another CTV item.  This is just a quick note that there was a CTV
activation meeting.  This was hosted by 1440000bytes on IRC meeting.  They
decided on BIP9 and some activation parameters and it didn't look like, at least
the time of writing, there was any responses to that.

**Mark Erhardt**: Well, I read the meeting notes.  It looks like some four
people were present and they had a very high-level discussion about how to
activate BIP119 CTV.  And I think what I noticed was that the people were not
that active in protocol discussion before.  So, I don't know who knows where
this meeting was, but there's a few people that think CTV should be activated,
and they have come to agreement on the terms that they will be proposing, I
guess.

**Anthony Towns**: There's already, LNHANCE activation proposal for CTV,
PAIRCOMMIT and CHECKSIGFROMSTACK (CSFS), which is, at least according to its
parameters, already able to be signaled and will remain so for a couple of
years, I think, 2028 maybe.

**Mark Erhardt**: So, yeah, I think this meeting suggested for CTV to start
signaling in April.  Obviously, or as far as I'm aware, there is no client that
implements CTV and these activation parameters yet.  As far as I'm aware,
there's at least two soft fork proposals that are supposedly in the signaling
period right now; as you said, LNHANCE and the recent BIP110 that started
signaling at the start of this year, I think.  So, wake me when you see some
signals.

_`OP_CHECKCONSOLIDATION` to enable cheaper consolidations_

**Mike Schmidt**: Continue with Changing consensus, we have,
OP_CHECKCONSOLIDATION, consolidation, which would enable cheaper consolidations.
This is from billymcbip, who proposed OP_CC, which is an opcode that would
return true if it's executed on input with the same scriptPubKey as an earlier
input in the same transaction, aka if you're spending from a bunch of coins that
have the same pubkey, then you can essentially label, "Hey, the signature of
this first one applies to the rest of these".  And as long as that matches, then
you don't have to sign those additional inputs, thereby having some sort of
consolidation fee savings.  Murch?

**Mark Erhardt**: Yeah, so basically, you can think of this as a poor man's
version of cross-input signature aggregation.  As long as you spend multiple
UTXOs that have the same output script, you sign for them once, you have to
commit to that in advance by having the OP_CC opcode, and then you would be able
to have a transaction with several inputs and a single signature.  Now, this is
the most charitable way I can describe this idea, because I think it is an
absolute non-starter.  We should not ever encourage and incentivize address
reuse.  This is completely no-go.  There should never be financial incentives to
reuse output scripts.  So, I think that the prior proposal that we had by Tadge
Dryja a couple of months ago or so, where he allowed outputs to commit to other
output scripts, or sorry, it was OP_CHECKINPUTVERIFY (CIV), and you would commit
to a specific UTXO that is also present on a transaction rather than an output
script, so you would reveal at the time that you create the transaction that
another input is associated with the same user, which is sort of the same
information you already revealed by having a number of inputs on a transaction,
assuming that the transaction was not created by multiple users.  And that seems
much more incentive-compatible to what we want to see on a network.

We absolutely do not want to make it cheaper to reuse addresses versus not
reusing addresses.  That's just a complete no-go and I think this proposal is
dead on arrival on that point alone.

**Mike Schmidt**: The Tadge post was from November last year titled,
"Post-quantum signature aggregation", and it works how Murch outlined.  You
essentially say that, in locking to this specific UTXO being spent in the same
transaction as me, you're sort of delegating the signature, if you will.  And
the idea there was more, at least the use case that Tadge had in mind when he
wrote this up was, you know, this is like post-quantum signature aggregation,
because then you could have, like we talked with Mike earlier, this large,
post-quantum signature for one of the inputs, and then the rest would just say,
"Hey, I'm piggybacking off of this one".  And so, you achieve something similar
without the requirement to be reusing addresses.

**Mark Erhardt**: And maybe if anyone else is wondering why this is safe, so you
might be wondering, "Well, can then other people just add other UTXOs with the
output script to the transaction?"  No, they cannot, because the first
signature, of course, should be  sighash default, which commits to all of the
inputs.  So, the first signature would commit to all of the other inputs being
present, and if more inputs were added, it would become invalid.  So, overall,
if you own all of the inputs, this would be a safe construction, and you could
create a single transaction that spends many inputs with a single signature with
either Tadge's CIV or this proposal.  And I think also, Brandon Black proposed
that you could do something similar with CCV, if that got made available.

But anyway, I think any of the other approaches are actually acceptable, whereas
the CC is an absolute no-go for me.

**Mike Schmidt**: Well, that wraps up the News and Changing consensus.  The
Changing consensus monthly segment always seems to be a big one, Murch, and so
we're 90 minutes in.  We're going to jump into the Releases and release
candidates at this point.  We have Gustavo, who's been on with us, quiet giant,
who's going to walk us through this BTCPay Server release as well as a handful
of Notable code changes.  Hey Gustavo.

_BTCPay Server 2.3.0_

**Gustavo Flores Echaiz**: Thank you, Mike.  Thank you guys for that deep dive,
that was very interesting.  So, now we start with the Release section.  This
week we only have one release, which is BTCPay Server v2.3.0.  So, they wrote a
blogpost on top of the release notes that you can check out if you want to learn
more about this release.  But basically, it includes features we had covered in
the Notable code and documentation changes, specifically one called
Subscriptions.  Subscriptions allows a server administrator to sell a recurring
subscription that people can sign up to a plan.  So, this can be products or
services, digital or physical, that they manage through their store.  This is
available both through the user interface and through the API.  Then there's the
monetization feature, which basically allows ambassadors, people that are
onboarding merchants in local situations, it allows them to get paid for
onboarding those merchants.  So, those two features we covered in previous
newsletters, so you can find more info on that.

But also, there's a new version of the plugin builder.  The 1.0 version is
released.  At the center of this is a ratings and reviews feature on the plugins
that are available in the BTCPay Server ecosystem.  So, people can rate and
review plugins, also improve email rules, payment request redesigns, and 14 new
languages available in BTCPay Server.  So, quite a release, an interesting thing
to follow.

_Bitcoin Core #33657_

We now follow with the Notable code and documentation changes.  We have many
news on Bitcoin Core and a few more on the Lightning implementations; and
finally, a few updates on the specifications.  We'll start with Bitcoin Core
#33657 introduces a new endpoint that allows you to obtain a specific byte-range
of a block.  So, by specifying a blockhash and a byte-range, you can obtain that
byte-range specifically.  And this, more specifically, allows you to obtain
transactions and not have to download the whole block.  So, this was motivated
by external indexes implementations, such as Electrs, which want to fetch a
specific transaction instead of having to download the whole block.  So, this
endpoint allows them to partially read block data and not have to download the
whole block.  Any extra thoughts here, Murch?

**Mark Erhardt**: Yeah, so basically this works because blocks are serialized in
a very specific way, and they will always be in the same order on disk.  Bitcoin
Core stores where each block starts on disk.  So, by knowing which block number
and what bytes in a block, it would be able to be resolved on every single node
in the same way, go to that block, walk this many bytes and then start picking
the data.  The thing that I was wondering when I looked at this very
superficially was, how does the request know which byte-range they're asking
for?  Where do they get that information?  Do they remember?  If they already
know about the transaction, why would they not have the transaction itself, but
have the byte-range they are asking for?  So, do you have any idea or insight
into that part?

**Gustavo Flores Echaiz**: I couldn't find that information, to be honest with
you.  I'm going to try to find it for later reference.  But yeah, that's
actually a very good question.  Sorry for that, I wouldn't know the answer.

**Mark Erhardt**: Well, maybe someone would tell them, "Hey, you can find us in
block *blah* at that byte to get it yourself", but that just seems like an odd
piece of information to store if you're not storing the actual transaction.  And
if the person that instructs them to get the data already knows the transaction,
they could just send a transaction and like a merkle branch or something to tell
the node how to verify that it exists.  I see how it is efficient and how it can
be served, I just don't understand how anyone would be in a position to ask for
the data.

_Bitcoin Core #32414_

**Gustavo Flores Echaiz**: No, very good question.  Definitely something to look
into.  We follow up with Bitcoin Core #32414.  Here, a periodic flushing is
introduced during the process of reindexing chainstate.  So, basically, if you
find your UTXO set to be corrupted, you will run -reindex-chainstate.  And
previously, there was no flushing during the whole process, only when you
achieved and reached the tip that the flushing to disk would happen.  However,
this could lead to if you, for example, had a crash on your node, then this
could result in substantial progress being lost if you had specifically set a
large dbcache option.  So, this allows you to constantly periodically flush the
UTXO set that you have that you have in memory, you can flush it to disk, so
that if there was a crash during that moment, you wouldn't lose the progress you
achieved during that time.  This process of periodic flushing already existed in
IBD (Initial Block Download), so this now just adds it to the
-reindex-chainstate process.  Any extra thoughts here?

**Mark Erhardt**: Yeah, and just because it's been a big topic lately on how the
UTXO set is managed by Bitcoin Core nodes, the UTXO set is generally primarily
stored on disk.  So, as a node goes through the blockchain, it will parse each
block, look up all the UTXOs that are necessary to verify the inputs on
transactions, and then cache the outputs that are being created in a block and
it'll look up every missing input from disk that it needs to verify the
transactions in the block.  And at the chain tip, while a node is just running,
whenever it sees unconfirmed transactions, it'll load into the cache any UTXOs
that are necessary to verify inputs.  So, only during IBD, the whole UTXO set
might be present on a full node, because if you have an extremely large dbcache,
it would never flush to disk completely.

So, there have been several improvements to the flushing behavior of Bitcoin
Core in the past, I think, one-and-a-half years or so.  Originally, only when
the dbcache was completely full, we would flush the whole UTXO set to disk
completely, which means everything that is in the dbcache would be written to
disk and the dbcache would be emptied.  And I think it probably was Andrew Toth
noticed that you could have a performance improvement, of course, if you
periodically flushed the UTXO to disk and then kept everything that was still
relevant in the cache instead of deleting it.  So, only the dirty data, the data
that had been changed, ie UTXOs that were stored on disk but had since been
spent, would get written out to disk.  And all the UTXOs that had been created
and were still present and that were in the cache would just stay in the cache.
And we therefore would not need to load them again right after the flush if they
become relevant for future transactions.

So, this was first introduced during IBD.  Now, this PR also introduces the
behavior to reindexes.  And I think where we previously had the flush to disk
every 24 hours, where we actually delete everything, and where we used to
actually delete everything and write it to disk in order to make the node not
lose any progress, we now do these non-emptying flushes where we write only the
dirty UTXOs to disk and keep the unchanged UTXOs in cache.  And I think we might
be moving to doing this every hour instead of every 24 hours.  So, basically the
problem why we were doing this in the first place is if you process blocks and
only keep the UTXO set in cache, we have not recorded the updates to disk yet.
And if your node were to crash at that point, you'd have to go back to the last
block that we updated the UTXO set on disk for, and have to reprocess all those
blocks to re-derive the current UTXO set.

So, flushing to disk makes us safe against crashes or unclean shutdowns, and
saves us time if something weird happens.  And keeping all of the still relevant
UTXOs in the cache saves us time because we don't have to warm up the cache
again when we're missing UTXOs that would have been in the warm cache.

**Gustavo Flores Echaiz**: Thank you so much, Murch, for that extra context.  If
listeners want to learn more about this, you can not only check out this PR, but
also the one referenced #30611.  That's when this is added every hour instead of
every 24.  So, all the details that Murch talked about can be found there.

_Bitcoin Core #32545_

We follow up with Bitcoin Core #32545.  In here, there's a replacement of the
algorithm being used for cluster linearization.  The new introduced algorithm is
called spanning-forest linearization.  And the reason why the change was made is
because the previous algorithm was taking too long to handle difficult clusters.
So, the new algorithm can resolve any observable clusters.  Basically, this was
tested on historical mempool data that indicated that this algorithm could
linearize all clusters in tens of microseconds.  The previous algorithm had sort
of a latency in difficult clusters.  It could handle simple ones probably more
efficiently than this new algorithm, but on the difficult ones, it took more
time.  Maybe, Murch, I saw you commented on Delving on this, so maybe you can
help us with the details?

**Mark Erhardt**: Yeah, sure.  So, we actually talked a ton about this with sipa
in our last episode in December for the Year-in-Review.  We did a very big deep
dive into the different algorithms and the work on it.  The general idea here is
that the already implemented algorithm was a more primitive approach where we
looked at the chunks in the cluster and bubbled up the things that we wanted to
pick to the front of the cluster.  And that did work, but as Gustavo mentioned,
it was not very performant for large clusters.  The spanning-forest
linearization is a much more performant implementation.  It's more complicated.
So, Pieter and suhas spend a lot of time on researching these and improving the
linearizations over time.  And now that it was mature enough, it was picked as
the highly optimized algorithm to linearize clusters, and it got merged now.  If
you want to get all the details, please find the section of the Year-in-Review
Podcast that we did a couple of weeks ago and hear directly from Pieter.

**Gustavo Flores Echaiz**: Thank you, Murch.  That's great advice for listeners.
Check out the previous episode, which will give them all the details.  But
basically, the point here, the objective is to have just a better way to deal
with difficult clusters.  And this new algorithm is able to handle them more
efficiently.

_Bitcoin Core #33892_

We move on with Bitcoin Core #33892, where the relay policy is relaxed to allow
opportunistic 1p1c (one-parent-one-child package relay), where the parent
underpays the minimum relay fee even if it's a non-TRUC (Topologically
Restricted Until Confirmation) transaction.  Here, what happens is that it
allows non-truck parents to also be included, so relayed.  The reason why this
was done previously is because mempool trimming around non-TRUC transactions was
kind of complicated, but this is no longer a concern because of cluster mempool.
Cluster mempool allows for easier linearization of these transactions.  Any
extra thoughts here, Murch, Mike?

**Mark Erhardt**: Yeah, maybe just to clarify, and I think this is driving off a
comment AJ made actually in this PR.  To be clear, we do not relay transactions
alone that are under the minimum relay transaction feerate.  So, when you set up
your node and you pick your minrelaytxfee, your node communicates this in form
of a fee filter to its peers and tells peers not to send transactions that have
lower fees than that minimum feerate, and that is generally respected.  And if
they send stuff anyway, the node will throw them away because they're below his
minimum relay transaction feerate.  However, in the context of a CPFP package,
where the child brings more fees that makes the whole package exceed the minimum
relay transaction fee, now the parent transaction becomes re-considerable.  So,
when a transaction was previously rejected for having a feerate that is too low
by itself, if a child shows up and says, "I'll pay for my parent", then we will
allow this transaction to be reconsidered in that context.

**Gustavo Flores Echaiz**: That's exactly right.  And now cluster mempool allows
us to do more things, and this is just one of those examples.  We move on with
the Lightning implementations.

_Core Lightning #8784_

We have Core Lightning #8784.  Here, a new field is added to the xpay command,
which we have covered extensively in multiple newsletters, specifically #330
where it was introduced.  A payer_note field is added that enables a payer to
provide a payment description when requesting an invoice.  So, this is from the
payer's perspective, that wants to request a BOLT12 invoice, and will add a
field so that the payee can generate an invoice with that description.  Xpay is
a plugin and sort of an abstraction of underlying commands, such as
fetchinvoice, and fetchinvoice already has a similar payer_note field.  So, this
PR adds it to the xpay command and also wires the value through the underlying
flow.  Xpay can also handle BOLT11 invoices, but this is specific about the
request of an invoice in the BOLT12 scenario, and adding a payment description
and wiring to the underlying commands being used.

_LND #9489 and #10049_

We move on with LND #9489 and #10049, which are related in the sense that #10049
adds the foundation required for #9489, which is the big piece.  So, basically
what #9489 does, it introduces a new experimental gRPC subsystem that that if
you want it enabled, when you compile, you have to signal a build tag,
switchrpc, that is non-default.  So, this is a non-default experimental feature,
but basically this subsystem adds three new RPC commands, BuildOnion, SendOnion,
and TrackOnion, which basically allows an external software to handle, let's
say, pathfinding and determining of the onion characteristics it wants.  And it
just calls LND for specific actions related to the HTLC (Hash Time Locked
Contract) delivery, but in specifics, first of all, build the onion, send the
onion, and then track where the onion is going.

A big problem found while building this is how can you ensure that this is
idempotent?  How can you ensure that an external system will not trigger LND to
send two HTLCs when in fact it only wants one to be sent?  So, that's the other
PR, #10049, adds the foundation required for external attempt tracking.  So,
this makes an external software able to track the payment attempts it has
relayed to LND.  And this LND #10049 also adds the groundwork for a future
version that will be fully idempotent, so like a SendOnion v2 that will by
itself manage all the attempt tracking and not just make it simpler, and allow
also more entities to dispatch the attempts.  So, right now, this is only safe
to allow one entity to dispatch an attempt, because if you had more than one
entity or external software controller that would attempt to dispatch and send
onions, you could accidentally send two HTLCs instead of one and trigger a loss
of funds.  Yes, Murch?

**Mark Erhardt**: I think that might have been a little hard to follow because
we got very much into the details.  I think the overarching idea here is that
LND introduces a way of using a second external device to do the route-finding.
So, you send the RPC command to your node but your node actually hands it off to
another device that has a better overview of the state of the network, and
decides what way to route the HTLCs, and so forth.  So, I think that's the
overarching idea here.

**Gustavo Flores Echaiz**: Exactly.  Thank you very much for adding that extra,
simple explanation.  Also, a future LND instance could be slimmed down and not
contain any routing components.  So, this is also the idea of where this could
go.

**Mark Erhardt**: Yeah, basically, I think this sounds like adding support for a
very thin client that externalizes the route-finding similar to how some other
Lightning wallets use an LSP (Lightning Service Provider) to do most of the
heavy lifting for routing.

_BIPs #2051_

**Gustavo Flores Echaiz**: That's exactly it.  Thank you, Murch.  We follow up
with the specification changes.  So, here, we have BIPs #2051, which makes
several changes to the BIP3 specification.  And, Murch, you were behind this, so
I'll let you add more in a second.  But basically, there was a lot of feedback.
We discussed this, I think, two, three newsletters ago.  There was a lot of
feedback and discussion around the changes that were made and covered in
Newsletter #278.  So, this reverts the guidance against using LLMs or AI
systems, and it broadens the reference implementation format.  So, maybe, Murch,
you want to add something here?

**Mark Erhardt**: Yeah, so I have been working on BIP3, a new BIP process, for a
long time.  We had a discussion on the mailing list recently about whether it's
time to activate BIP3, and a few people added some comments and suggestions to
the latest changes that had been made to BIP3.  In particular, it was
controversial that there was guidance added that said that LLMs are not to be
used in creating BIPs, because it sort of suffered from the issue that the
people that could produce high-quality text using LLMs would be punished for
being fair and stating that they used LLMs, or would basically be prohibited
from using this efficiency tool.  But the people that already write bad BIPs
would never disclose that they used an LLM and would just produce a lot of BIPs
that are low quality that would waste people's time, and would never tell people
that they hadn't written it themselves.  So, the guidance on that point was
rolled back.  We still think that essentially, the idea is if you submit a BIP,
you are responsible for making sure that the BIP is high quality and whatever
tools you use is up to you.  But you own the text that you submit, and if it's
crap, just keep it to yourself.

Anyway, because of the feedback that was provided to BIP3, a few more changes
were made to BIP3 that got merged in early December.  I have since sent another
email to the mailing list proposing that we might be ready to activate BIP3
again.  So far, there seem to be crickets responding to that, and if you have
strong opinions about BIP3 being ready for activation, I would appreciate a
public statement of support, because it has been communicated to me that as the
author and BIP editor, I'm not supposed to be the person that says it's ready to
merge.  But in my humble opinion, it's ready to activate.  So, if you feel the
same way, please publicly state so, so we can move on and get this thing out of
the door.

**Mike Schmidt**: Murch, is this what you were referencing earlier when you said
you're shouting into the void, speaking into the void?

**Mark Erhardt**: Well, there's a very small crowd of people that are interested
in BIPs, probably a few dozen people, that actually keep track of what's going
on.  And as AJ also mentioned, if people have issues with something, that
surfaces pretty quickly.  And sometimes it's hard to tell whether a BIP doesn't
get responses because it's a terrible idea and obviously so, or whether it's
fine and there's just nothing to nitpick about it.  And that might be somewhat
obvious to people that spend a lot of time following BIPs, but it might look the
same from the perspective of a superficial observer.  And now, obviously, the
mailing list, whenever you send a message, goes out to presumably hundreds of
people, and you want to be somewhat concise and efficient in your communication
to the mailing list, because sending a ton of emails to people, it just costs a
lot of overall man hours to communicate to the mailing list.  But it is a bit of
an unsolved issue to find out when is a BIP actually ready to be adopted.

Now, with things that get implemented, it's a little more obvious, because
projects will say, "Okay, this looks ready and a good idea, so we'll implement
support for it".  And eventually, there will be projects that have adopted it.
And as they implement, they will look into it in a lot of details, and there's a
sort of feedback mechanism built into the adoption, and BIPs get ready.  And
when they're adopted by multiple projects, they are going to be set to final,
because clearly they could be implemented, they got adopted by projects, and
they're now used on mainnet, and that makes it obvious that they should be
final.  For a process BIP that is on the social layer, this is less obvious.
So, the only way to move forward is for people to say, "Okay, this is ready and
we should adopt it".  It leaves a judgment call where people need to decide this
is ready.  And since I also wrote this BIP, I'm probably not the right person to
decide when it's ready.  So, if you feel it's ready, it's up to you to say
something.  Thank you.

**Gustavo Flores Echaiz**: Thank you, Murch.

**Mark Erhardt**: 'You' being general, all listeners, anyone that feels
addressed.

**Gustavo Flores Echaiz**: Thank you.

**Anthony Towns**: I sent an ACK on the PR.

**Mark Erhardt**: Thank you, AJ.  I was not criticizing you, just everyone else.

_BOLTs #1299_

**Gustavo Flores Echaiz**: Thank you, Murch, that's great.  We are almost done.
We've got two final changes that were made to the BOLT specification.  So, in
the first one, BOLTs #1299, there's a clarification -- both of these are just
clarifications of logical mistakes in the specification.  So, this one is
specific to BOLT3.  And here, when it talks about the commitment transaction
outputs, specifically the one that is called to_remote, or that pays the
counterparty, it was previously noted that, "The remote commitment transaction
uses your localpubkey for the to_remote output to yourself".  This means that it
was instructed for a payer to include a localpubkey in the output that pays the
counterparty.  This localpubkey was a per-commitment point that is no longer
valid now that the option_static_remotekey is used.  The option_static_remotekey
means that there's just now a static field that is used to enable fund recovery
without the pe-commitment point.  So, a recipient that had kind of lost its
channel state can still recover his funds even if he loses that state because of
the option_static_remotekey.  And so, this just clarifies that because of this
new option, you no longer need to include the localpubkey or the per-commitment
point.  Yes, Murch.

**Mark Erhardt**: Right, so basically, in an HTLC, there's two ways it can be
resolved.  And if both channel participants lost their state, the HTLCs would
have sort of running data that gets used to encode how to spend the funds.  And
this can be turned off with the option_static_remotekey, which basically says,
"All funds will always pay to a static secret that might be modified by the
transaction data directly".  And now, if someone has their initial backup for
their node, they can still take the funds without knowing the running data from
the channel state.  And presumably in BOLT3, the specification was correct for
the prior version where it was based always on the running data.  But with this
option of the static key, obviously the running data should not be used for the
output.

_BOLTs #1305_

**Gustavo Flores Echaiz**: Exactly.  So, just a clarification on the
specification.  Finally, the last one is also something similar on BOLTs #1305.
Now, the BOLT11 specification is updated to clarify that the n field, which
stands for the 33-byte public key of the payee node, it's not mandatory.  So, it
was written already that it was not mandatory as, "A writer may include one n
field".  So, this was already written.  But on the reader end, it said, "A
reader must fail the payment if any mandatory field, including n, does not have
the correct length".  So, this phrase that said 'any mandatory field' is changed
to say 'any field with fixed data length'.  So, just that clarification,
previously included and within the mandatory fields on the reader, and now is
updated to say that it's no longer mandatory to make it absolutely clear that it
isn't.  And that completes the newsletter, this section and the whole newsletter
as well.

**Mike Schmidt**: Awesome.  Thanks, Gustavo.  Murch, anything else to comment on
before we wrap up?

**Mark Erhardt**: Yeah, maybe just in case someone missed it earlier, we have an
advisory by Bitcoin Core that you should please not use v30 and v30.1 to migrate
legacy wallets at this time.  There's a new patch coming forth for 30.2 that
fixes an issue where in very rare circumstances, wallet migration from a legacy
wallet to a descriptor wallet would delete the whole wallet directory.  Also,
always make backups before you do anything like wallet migration.  But please,
if you're using a Bitcoin Core wallet and you have a very, very old legacy
wallet that is unnamed, there might be a danger of deleting your wallet
directory.  Make backups before migration, or better yet, do not migrate at all
with v30 until 30.2 comes out.

**Mike Schmidt**: We want to thank Mike for joining us earlier and AJ for
hanging on as our guests this week.  And we thank you all for hanging on for two
hours and listening.  We'll hear you next week.  Cheers.

**Mark Erhardt**: Cheers, Happy New Year.

**Anthony Towns**: Happy New Year, everyone.

{% include references.md %} {% include linkers/issues.md v=2 issues="" %}
