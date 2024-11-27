---
title: 'Bitcoin Optech Newsletter #329 Recap Podcast'
permalink: /en/podcast/2024/11/19/
reference: /en/newsletters/2024/11/15/
name: 2024-11-19-recap
slug: 2024-11-19-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt discusses [Newsletter #329]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-10-22/390307436-44100-2-8c40dda52943.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs on Bitcoin stuff, and
I'm going to do the Bitcoin Optech Newsletter #329 today all by myself.  Today,
we have two News items, two Releases, and four items from the Notable code and
documentation changes.  We'll jump right in.

_MAD-based offchain payment resolution (OPR) protocol_

So, apparently, John Law posted another micropayment protocol, and this one is
based on something fresh and new again.  This is based on mutual assured
destruction of some funds that have been put up by both users.  The idea here is
if both users are punished, if something goes wrong, they might be incentivized
to work together in order to get their money back.  And you get to save onchain
fees because there's no penalty transactions, there's just this one fund that
gets slashed if something goes wrong.  The idea is because the two users need to
just keep each other happy, they'll be able to have a fast settlement, even
something within a few seconds could be enforced, and there's no forced channel
closure when communication breaks down.  So, they'll be able to have a channel
linger for some time and pick it up later again, as long as none of the two
decides to go onchain and destroy their funds that they put up.

The idea here is that it could potentially be used in channel factories, timeout
trees or other nested structures.  And some people that responded to John Law's
post on Delving Bitcoin brought up the concerns that putting aside this bond
requires even more funds than the usual channel reserve, where others had been
confused in the past that you can't really spend 100% of your channel balance,
only 99%, you might get a similar confusion or UX issues around here, needing to
put up a lot of funds that can get slashed next to the channel.  And Matt
Morehouse also brought up the question of whether it might be possible to
blackmail or slowly entice the counterparty into appeasement and stealing more
than your share out of the put-away funds.  Discussion is still ongoing, so if
this sort of stuff is your jam, jump in on the Delvin Bitcoin conversation.

_Papers about IP-layer censorship of LN payments_

All right.  Yeah, sorry.  As I said, I was at a workshop all day, so I'm
probably going to be able to go through these fairly briefly.  The second news
item this week is that Charmaine Ndolo summarized two recent papers.  One recent
paper that describes an attack, a network-level privacy attack on the LN; and
the second one, a payment censorship in the LN despite encrypted communication.
The first paper is by other people.  She contributed to the second paper.  What
she describes in these two papers is that it is possible to attack privacy and
censorship in the LN, even if you're just observing the metadata of TCP/IP
packets in order to guess what type of payload, for example, in HTLC (Hash Time
Locked Contract), these packets might be transporting on the Bitcoin Network.
Sorry, you're a network-level observer, for example, an autonomous system or an
ISP, and just by looking at the metadata of the TCP/IP packets routed from the
LN nodes to other LN nodes, you might be able to guess that someone is sending
in the HTLC.

So, if you're a network observer, like an AS, you might also be able to see
multiple of the participants in a multi-hop payment.  And by observing the
message progression, you might be able to guess several of the hops of a
multi-hop payment.  If you are also a participant in the LN, you might be able
to combine this information to learn about the rough amount, and then even
selectively sensor forwarding or even delaying the failure of a payment by being
a man-in-the-middle and being able to guess where roughly a payment is routing.
The paper also proposes a few mitigations: one, to deviate from the default
port, which may not be sufficient; two, to use Tor; or, generally to use padding
of your messages, for which maybe something like adaptive padding, such as
WTF-Pad might be useful.  And finally, when you're running an LN node that does
pathfinding, you might want to take into consideration which ASs the information
travels through while you're doing your pathfinding.

I said this a little earlier when fewer people were on here, but due to me being
alone tonight, if you want to jump in and want to participate in this
discussion, feel free to raise your hand or ask for speaker access.  We're now
going to the Releases and release candidates section.  Both of the releases this
week are BTCPay Server.

_BTCPay Server 2.0.3 and 1.13.7_

So, BTCPay Server released two new versions, one is version 2.0.3 and the second
one is 1.13.7.  The releases appear to be related in that both of these have an
explicit comment that if you use Boltcards, please upgrade.  Apparently, one of
the fixes that is included in both of these releases deals with Boltcards
getting bricked if you are doing certain actions while you have an unexpected
Boltcard inserted.  So, if you use Boltcards and use BTCPay Server, you might
want to upgrade to one of those two versions, depending on your needs.  The
version 2.03 appears to have two new features as well.  These pertain to
Greenfield.  One is that histograms now include Lightning data and API
endpoints, and another is that you can add images for app items.  There's also
about 20 bug fixes and 6 other improvements.  And again, if you use Boltcards,
they recommend that you upgrade to this one.

The other one appears to be a backport to version 1.13.7.  And it has a few bug
fixes, four of them, and one of them is the Boltcards-related one.  Cool.  Okay,
so if you're a BTCPay Server user and you use Boltcards, please be sure to take
a look at the release notes of those to figure out whether that's something you
need to take care of.

_Bitcoin Core #30592_

We're getting to the Notable code and documentation changes this week.  The
first one is Bitcoin Core #30952.  This one is interesting in that it removes
the mempoolfullrbf startup option, so it gets rid of people turning off the
ability to opt out of full-RBF.  The argumentation here is full-RBF has been
broadly adopted by the network and nodes that opt out of full-RBF will simply
have an incomplete mempool, and therefore this is detrimental.  In the broader
context of this, in the recent release of Bitcoin Core v28, we turned on
mempoolfullRBF by default.  This PR is of course to the master branch in the
repository, so this PR will only be released in version 29 in April.  So, if
this is of concern to you, please chime in on the conversation.

_Bitcoin Core #30930_

Next, we have a second Bitcoin Core PR.  This is #30930, and this one adds a new
peer services column in the netinfo command.  So, if you call the netinfo RPC,
you will now see which peer services are offered by your peers.  The column
shows the various services via a single character.  If the peer is a full
blockchain data archive, it'll have an n; if it has bloom filters active, it
will be b; segwit support is a w; compact filters is c; and if you are a pruned
node, that looks like an l to me.  And finally, if the node offers v2 P2P
transport protocol, so the new encrypted BIP324 P2P protocol, then it will have
a 2 in this column as well.  So, if you call the netinfo command on your node
right now, you will see a little more about what your peers are capable of in a
very quickly readable format.  You might need to look up what the letters meant
again, but there is also another optional filter that you can use with the
netinfo command, which is outonly, and then you will only display outgoing
connections instead of all of your connections.  Also, if you have any questions
or comments, of course, please feel free to ask for speaker access.

_LDK #3283_

So, two more notable code changes.  One in LDK, this is PR #3283.  We've talked
a bunch already about BIP353, which adds DNS-based human-readable payment
instructions, and this is now implemented in LDK.  So, LDK can now consume these
human-readable payment instructions that you can put into your DNS record and
resolve them to get an invoice via the BOLT12 offer scheme.  There's a few other
methods that have been added to LDK in order to make that work.  And yeah, we
had talked about all of this stuff more already in Newsletter #324, so that
would be five weeks ago.

_LND #7762_

Finally, we have an LND PR.  This is LND #7762.  And this PR updates several
lncli RPC commands, which now respond with status messages instead of returning
empty responses.  So, this will hopefully more clearly indicate that the command
was successfully executed.  The affected commands include wallet releaseoutput,
wallet accounts import-pubkey, wallet labeltx, sendcustom, connect, disconnect,
stop, deletepayments, abandonchannel, restorechanbackup, and finally
verifychanbackup.

Yeah, so sorry for being so brief and at an odd time this week.  Thank you for
joining me, and that is what I have on the Optech Recap this week.  I don't see
any comments on our tweet, and nobody has stepped up to be a speaker, so I'll
just hear you next week.  Have a nice evening.

{% include references.md %}
