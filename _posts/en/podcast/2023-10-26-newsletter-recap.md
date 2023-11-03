---
title: 'Bitcoin Optech Newsletter #274 Recap Podcast'
permalink: /en/podcast/2023/10/26/
reference: /en/newsletters/2023/10/25/
name: 2023-10-26-recap
slug: 2023-10-26-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Bastien Teinturier, Fabian
Jahr, Ethan Heilman, and Armin Sabouri to discuss [Newsletter #274]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-9-26/352852970-22050-1-abc2853a7ccfe.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #274 Recap on
Twitter Spaces.  Today, we're going to be discussing the replacement cycling
vulnerability in LN which we alluded to last week, including future and current
mitigations; we're going to talk about a bug related to assumeUTXO and some
covenants research by Rusty Russell; a proposed BIP for the OP_CAT opcode; some
interesting Stack Exchange Q&A; and finally, Bitcoin Core 26.0rc1.  I'm Mike
Schmidt, I'm a contributor at Optech and Executive Director at Brink funding
open-source Bitcoin developers, joined by my co-host, Murch.

**Mark Erhardt**: Hi, I'm Murch, I work on Bitcoin stuff at Chaincode Labs.

**Mike Schmidt**: And t-bast.

**Bastien Teinturier**: Hi, I'm t-Bast, I work on Eclair and the lighting
specification at ACINQ.

**Mike Schmidt**: Fabien?

**Fabian Jahr**: Hey, I'm Fabian, I'm sponsored by Brink and I primarily work on
Bitcoin Core.

**Mike Schmidt**: And Ethan, although Ethan plus one.

**Ethan Heilman**: I'm Ethan, I'm co-founder of BastionZero.  I've done a bunch
of work on the P2P network and atomic swaps.

**Mike Schmidt**: And does your co-contributor want to introduce themselves as
well?

**Armin Sabouri**: Hey, guys, Armin here.  I'm joining as a listener, but I'll
probably speak on Ethan's mic.  I'm working on sidechains at Botanix Labs, and
I've been working on multisigs for the better part of a decade now.  Yeah,
thanks for having me today.

_Replacement cycling vulnerability against HTLCs_

**Mike Schmidt**: Well, thanks to all our special guests for joining.  We're
going to go through the newsletter sequentially here, starting off with three
news items that are somewhat related.  It is the replacement cycling
vulnerability that came out last week against Hash Time Locked Contracts
(HTLCs).  We had a brief writeup on this in the last newsletter but didn't have
a chance to get into it too deep, because it was announced late in the
publication cycle last week.  But Dave, the primary author of the newsletter and
these news sections, really dug into the details in this week's writeup breaking
the news into three separate sections.

First one is an overview of what is this vulnerability; the second section is
what updates have been made to LN implementations so far; and the third section
is what ideas are there for additional mitigations.  Luckily, we have t-bast,
who was able to join us this week, to help unpack the topic.  T-bast, maybe
let's start with, what is the vulnerability itself; maybe under what conditions
does this vulnerability apply; and how is the attack executed?

**Bastien Teinturier**: Sure, so first of all, for anyone who hasn't read it
yet, the summary by Dave on the Optech newsletter is really, really great.  It
really explains all the details and subtleties with some examples.  So, it's
really good to read at your own pace if you want to fully understand this.  So,
the way it works, and it is highlighted a lot in the summary, is that this is an
attack on routing nodes.  If you are just a wallet, an end node that only sends
payments or receives them, you are not affected at all.  It's when routing nodes
forward an HTLC and the HTLC expires, they have to close the channel and publish
an HTLC timeout transaction to be able to get the HTLC back.  And that happens
when you, let's say, are receiving an HTLC on what we will call the upstream
channel, and then you are forwarding it on what we call the downstream channel.
So, the HTLC expires first on the downstream channel so that you have time to be
able to get your funds back onchain for the downstream channel, and then
failback the HTLC on the upstream channel without having to close that channel.

The goal of this attack is to make sure that you are not able to get your HTLC
timeout transaction for the downstream channel confirmed in time, so you have to
make a decision for the upstream channel before you're able to get the funds
back.  So, you will end up failing the HTLC upstream, which means you have not
received the money, but then the attacker on the downstream channel is going to
reveal the preimage but later, so that you send money downstream but you have
not received matching money upstream.  So, that's how they make you lose money.
And this is supposed to be impossible because the only two ways to spend the
HTLC output on the downstream channels are either by revealing the preimage for
that payment, which would let you claim the funds that come on the upstream
channel, or you getting the funds back through the HTLC timeout transaction.
And there are no other ways to spend the script for that HTLC output.

But the thing that Antoine found, and is a nice mempool trick, is that you as
the honest node publish your HTLC timeout, so you expect it to confirm, but then
the attacker is going to publish their HTLC success transaction, the one that
reveals the preimage.  This will replace your HTLC timeout in the mempool, but
if that transaction gets to your own mempool or gets confirmed, then you learn
the preimage so you are able to get paid upstream.  So, what the attacker does
to prevent that is that they can replace that HTLC success transaction by
invalidating one of its parents.  So, what they do is replace one of the parent
transactions so that the HTLC success doesn't have the output it was spending
anymore.  And if they do that very quickly after publishing the HTLC success
transaction, then it is likely that no miners will get the HTLC success
transaction mined, and you may not receive it in your mempool either, so you
don't have an opportunity to get the pre-match.  But that depends on a lot.

To be able to successfully create that attack, you have to have very good
overall knowledge of a P2P network; you have to be able to inject transactions
at the right time in the right places; you also have to be able to eclipse the
node of the victim, so that they don't see your transaction that contains the
preimage; and this is also an active attack, where the attacker has to actually
replace transactions with a higher and higher feerate, so some of those
transactions will get confirmed, which makes the attacker pay some onchain fees.
So, every block that the attacker is trying to sustain the attack, he has to pay
for it.  So, for all of those reasons, we should not dismiss this attack because
someone who is a really very well-motivated and well-funded attacker, who could
have potentially very precise control of a P2P network, would maybe be able to
carry out that attack.  But in practice, it is really hard to carry out and
there are a lot of mitigations in place to make sure that even if you're able to
carry it out, you will not gain a lot of money.

So, I don't know how much we want to go into the details of those mitigations,
but at least that's the high-level view of the attack.  But it's really easier
to understand if you read slowly the mailing list with details of the
transaction setup, so don't hesitate to do that.

_Deployed mitigations in LN nodes for replacement cycling_

**Mike Schmidt**: Thanks for that overview, t-bast.  I think it would maybe help
clarify the issue to also get into some of the deployed mitigations that we got
into in the newsletter that certain implementations have put into place.  Maybe
you want to talk through those a bit?

**Bastien Teinturier**: Yeah, sure.  So, first of all, there are three main
mitigations.  The first one is playing on the timeout, the number of blocks you
have to get that transaction confirmed, because the more blocks you have to get
this transaction confirmed, the more the attacker has to pay fees to evict your
transaction and get another transaction confirmed instead.  And also, the more
blocks, the more time you have basically to get your HTLC timeout transaction
confirmed, the more likely it is that you will find one miner that the attacker
didn't correctly reach that will eventually mine either your transaction or the
HTLC success transaction.  So, the first mitigation is to make sure that you
have a large enough timeout.

Then, another mitigation is to make sure you republish your HTLC timeout
transaction regularly, so that the attacker has to continually do the cycling of
evicting your HTLC timeout transaction with the HTLC success transaction, then
evicting again the HTLC success transaction by making one of the parents
invalid.  So, the more frequently you do that, the harder it is for the attacker
to carry on this attack.  Then, another mitigation is to watch your mempool,
because the attacker, to be able to replace your transaction, first has to
insert the HTLC success transaction that has the preimage, and then replace it.
But if you're able to see that transaction, you are able to extract the
preimage, and then the attack doesn't work anymore.  So, if you're watching your
own mempool, and you are able to see that transaction, then you are completely
protected from that kind of attack as soon as the transaction at least reaches
your mempool; you're not being fully eclipsed by the attacker.

Then another mitigation, what else did we do?  Longer expiry deltas, rebroadcast
frequently, and then more aggressively raising the fees of your HTLC timeout
transaction to make sure that the attacker also has to more aggressively pay
fees to be able to carry out the attack, so that in the end it ends up like a
scorched-earth strategy, where you are ready to pay up to the HTLC amount in
fees.  So, the attacker will end up paying even more than that without being
able to steal any money.  But those are mitigations, but they don't fully fix
the attack.  Potentially in theory, an attacker with perfect control over the
P2P network and what transactions are injected and at what rate would still be
able to exploit that and attack you.

That's why the ideal fix would be a change at the Bitcoin level, where when the
miners create their block template, the thing is that there's a big inefficiency
here for them, because they first receive an HTLC timeout transaction that
potentially pays a large fee because you are getting really close to a timeout
and you really have to get that transaction confirmed.  Then, this one is
evicted by an HTLC success transaction.  Then, the HTLC success transaction is
evicted again because it loses one of its parents.  But when that happens, the
HTLC timeout transaction can be reintroduced into the mempool.  So, the miners
would potentially be able to figure out that, "Oh, I previously evicted a
transaction, but now I can actually put it back in my mempool, and it's a
high-fee-paying transaction.  So, I should put it in my block template, and then
the attack would disappear entirely".

But this potentially has other subtleties, when you start getting into modifying
the block template code or storing more transactions that have been evicted from
the mempool.  You want to make sure that you are not opening yourself to those
attacks, so this is not as simple as that.  But at least conceptually, there's a
big opportunity loss for the miners.  And that's why ideally, I would love to
see it being fixed at that level, but that's probably really hard.

**Mike Schmidt**: Go ahead, Murch.

**Mark Erhardt**: I'm curious, as someone that I discussed this attack with in
the last week suggested, why doesn't the, I think you called it an HTLC success
transaction onchain, signal finality; why does it signal RBF when the
transaction is pre-signed and cannot be changed by the author?  Would that,
assuming that mempoolfullrbf is not fully adopted by the network, mitigate the
replacement cycle?

**Bastien Teinturier**: First of all, yeah, I'd say we want to assume that
full-RBF is on, otherwise, it could still be gamed.  Yeah, it would be harder to
pull out.  I think that if I remember correctly, reason why we have to put that
in sequence, but I don't remember.  Yeah, I don't remember why.  I think there's
a reason why the HTLC success transaction has to signal RBF, but I can't
remember why; I would have to look at the spec again.

**Mike Schmidt**: So, just to clarify for listeners, we see notices of
vulnerabilities in software, and I think the common resolution to a lot of that
is, "Oh, just put in a quick code fix and upgrade and all is good".  And in this
case, there isn't some such fix that just magically puts us away.  The
mitigations here are raising the cost for the attacker to do this and not
necessarily fixing it straight away.  Go ahead, t-bast.

**Bastien Teinturier**: Yeah, one first good reason to make the HTLC success
RBFable is that otherwise, you are creating another attack vector in the
opposite direction, when for example if you receive an HTLC, you want to fulfill
it because you have a preimage, but then the other node closes the channel.  You
need to make sure that you are able to get the HTLC success transaction mined
before the timeout of the HTLC is reached, because otherwise the other node
would be able to publish their HTLC time of transaction and they would get back
the funds.  And this would be exactly the opposite to this attack, where you
would have paid the money downstream and you have learned the preimage and you
are fighting to get the money back on the upstream channel.  So, if you are not
able to RBF your HTLC success transaction, potentially it's just not going to
confirm before the HTLC timeout can be published and then you would be
completely screwed.  So, you will really have to make sure that the HTLC success
transaction can be RBFed.

**Mark Erhardt**: But I thought that, wasn't part of why the replacement cycling
works was that the defender cannot actually change anything about the HTLC
success transaction and it is completely predetermined?

**Bastien Teinturier**: No, because since we introduced anchor outputs the HTLC
transactions are using, they have one output that comes from the commitment
transaction and we're using SIGHASH_SINGLE, SIGHASH_ANYONECANPAY on that one,
and you have to bring your own funds in additional inputs to set the fees of the
HTLC success transaction, because by default it pays zero fees.  So, you really
have to bring fees and then we also let you change those fees by updating that
transaction, because otherwise you would have to guess right from the very
beginning what the feerate is for the whole duration of the CLTV expiry delta,
which would be dangerous.

**Mark Erhardt**: I see.

_Proposed additional mitigations for replacement recycling_

**Mike Schmidt**: T-bast, I think we got into some of the proposed additional
mitigations here.  You talked about miners retrying past transactions.  You also
mentioned the scorched earth, and it sounded like you mentioned it in the case
of that already being implemented.  Are any of the LN implementations doing that
sort of increased fee mitigation that you talked about?

**Bastien Teinturier**: Yeah, I think we've all been doing that, at least on the
Eclair site, since we introduced anchor outputs, I think, almost two years ago.
That was the strategy we had in our HTLC transaction logic, that we would keep
raising the fee until we get closer and closer to the end of the timeout.  So,
that would eventually reach the scorched-earth scenario, where you spend the
whole HTLC amount in fees.  So, this was already here and had been already here
for a while, and I think the other implementations do the same.  And the other,
yeah, we also change the fee regularly.  I'm looking at the newsletter right now
to see the list of the other proposed improvements.

So, the next one was to have pre-signed fee bumps by Peter Todd.  And it's
interesting because this is actually a proposal I made on the spec, I think a
year ago or something like that, where we would pre-sign transactions at various
feerates to make sure that even if my goal was not exactly to protect against
that attack, but rather that if the other node goes offline, you have
potentially a transaction at a feerate that matches the current feerate to be
able to be more fee efficient.  But the issue with that is that either it takes
a lot of bandwidth, or you're losing a lot of granularity in the feerate you are
paying, especially once you get into higher feerates, because you cannot sign
for every increment of 1 sat/byte, because that wouldn't scale.  We wouldn't
want to sign 250 different versions of each transaction, for example, especially
since you have to re-sign every HTLC transaction while they are pending.

So, what I think that Peter proposed is that we do powers of twos, but if we do
powers of twos, for example, we have one transaction at 128 sats/byte and
another one at 256 sats/byte.  If really the current feerate is 140 sats/byte,
you would have to use the one at 256 sats/byte, which is already quite a lot
more than what you could do.  So, you are wasting a lot of fees and being really
fee inefficient.  So, while it would work-ish, it would be really fee
inefficient in my opinion to do it that way.

**Mark Erhardt**: I think you could certainly find a different curve where you
maybe scale double or even four times in the earlier steps, but then later level
off and use a smaller factor, especially in the granularity of -- I mean, going
from 500 to 1,000, for example, makes absolutely no sense; 128 to 256 definitely
hurts already.  But yeah, I understand that also a big problem would be that you
just have to keep track of a lot more state and have more decisions to make when
you broadcast what, and so forth.  Isn't that the main issue with this approach?

**Bastien Teinturier**: Yeah, definitely.  That's definitely another issue and
since we've already implemented something that looks partially like that in
Eclair for Phoenix, we do have to track more state and store more signatures.
So, it is not a very satisfactory solution.  So, yeah, I agree that I'm not
really satisfied with that idea to fix this issue.  I think we can do better.

**Mike Schmidt**: One final discussed potential mitigation here was this
OP_EXPIRE op code, which would make a transaction invalid for inclusion after a
certain block height, assuming that the transaction script had an OP_EXPIRE in
it.  Seems fairly invasive, but t-bast, do you have a thought on that?

**Bastien Teinturier**: Yeah, I find this one really interesting, because it
would at least really let us express exactly what we want from our scripts.  We
want the HTLC success to be allowed before a certain time, and then we want the
HTLC timeout to be the only way to spend that.  And what would be really nice
with that is that we wouldn't have to overpay the HTLC timeout, we wouldn't have
to be in a rush to be able to get those funds back.  So conceptually, it really
looks like the kind of thing we'd want.  But I have no idea what all the
second-order effects would be of having such an opcode in Bitcoin, so that's the
part where I just don't know.  I would like it for this specific use case, but I
don't know if there are other reasons of negative things it could do and other
reasons to dismiss it because yeah, maybe reorgs, maybe expiring transactions is
something that we haven't done.  So, yeah, I'm not sure.

**Mark Erhardt**: Yeah, I think the proposal to have something that allows
transactions to expire at a certain block height has come up quite a few times,
and there is a huge issue with that around reorgs.  For example, let's say Alice
creates a transaction that can only be included in the next block, but it has an
enormous value and pays an enormous fee.  It creates first an incentive for
other miners to attack the previous block in order to collect that fee; second,
it creates the problem that if people start building other transactions on top
of those unconfirmed transaction trees, you only have to block that one parent
transaction to obsolete the entire downstream of descendant transactions.

So, one thing is that people could have additional incentive to censor a
transaction that is expiring after the next block.  But the other one is that
people could be encouraged to attack the previous block in order to mine a
competing block that does not include a transaction, in order to invalidate a
whole tree of descendant transactions.  This could basically make a Finney
attack way more profitable because you only have to reorg one block in order to
potentially gain a multiple of the paid transaction back, because multiple
downstream payments could be invalidated that way.  So, I think philosophically
we have had a few discussions about this in the past, and I think it would be
very hard to get support for this proposal.

**Mike Schmidt**: T-bast, other than encouraging folks who run an LN node to
update to the latest versions to make sure these mitigations are included, any
parting words for the audience about your outlook on LN and this particular
attack moving forward?

**Bastien Teinturier**: Yeah, sure.  So, I think professional nodes should not
be really worried about this attack because professional nodes have a good
enough set of stable nodes and mostly are making sure that it's not easy to
eclipse attack their Bitcoin node, that it's not easy to figure out which node
is their Bitcoin node associated to their LN node.  But that could be more of an
issue for non-professional users who run, for example, on a Raspberry Pi, where
by default bitcoind and the LN node run exactly on the same hardware and have
the same IP address, which makes it really easy to see which Bitcoin node you
have.  But even then, bitcoind still has already quite a few mitigations against
eclipse attacks.

So, you're probably fine, even in that case, but it would still be a good idea
to make sure that your bitcoind node doesn't share the same IP address as your
LN node.  I think that's the main thing that you can easily change and would
already provide good enough protection, because if the attacker is not able to
eclipse attack your node, and you are, for example, watching your local mempool,
it is very likely that you will receive the HTLC success transaction and will be
able to extract the preimage so that the attack doesn't work.

**Mike Schmidt**: Great point.  T-Bast, thanks for joining us and walking us
through these news items.  You're welcome to stay on or if you have other things
to do, you can drop as well.

**Bastien Teinturier**: I'll stay, of course.

_Bitcoin UTXO set summary hash replacement_

**Mike Schmidt**: Excellent.  Next item from the newsletter in the news section
is titled, Bitcoin UTXO set summary hash replacement, and this was an item
posted to the Bitcoin-Dev mailing list by Fabian, so I will let him sort of take
the reins here.  Maybe Fabian, to start, what is the hash of the current UTXO
set and why does anyone need it?

**Fabian Jahr**: Yeah, sure.  So, the UTXO set is the coins that are possible to
spend at any point in time, and so that means there is a UTXO set for every
block height and there is a possibility to hash it of course.  You have to first
decide how you actually take the information from these coins and serialize it,
so that's why also the name of the hash is serialized hash.  And so, after
you've serialized it, then you hash it, and we actually have two different
algorithms right now to hash them.  And the first one that is pretty old uses
simply SHA-256, and then we also have the new hash algorithm to do that.

The reason why actually this only got very interesting now, with assumeUTXO,
because before I think there wasn't really a good use case for it.  There were
ideas being thrown around for using this hash, but to my knowledge there wasn't
really a protocol that was using it on top of Bitcoin, at least nothing that
really caught on or got serious interest.  I think it's first interesting to
repeat how assumeUTXO really works under the hood when you start using it, to
understand how it's relevant in that context.  So, when you start your node, the
first time you run a node ever, and you want to use the cool new feature, assume
UTXO, you have to assume the UTXO set from somewhere.  It's not really relevant
where you get it from, there are ideas for that in the future as well.

So, you have it and so you start your node and then you run the first RPC, that
is called loadtxoutset I think, or could be also loadutxoset; I think txoutset,
and you provide the file that you have that has the UTXO set.  And so, what is
happening then in the background, and this is going to take some time, is that
this file is being read by the Bitcoin Core node, and it just takes piece by
piece the coins out of this file and reads them, puts them in its local UTXO
set.  And then at the end, it runs this hashing algorithm on the UTXO set.  And
then, when everything is done and it receives this hash, then it checks this
hash against the chain parameters.

If you are on testnet or signet, this is already possible right now.  There will
be a hash that is part of the list where it's permitted to load the UTXO set
that results in this hash, and so that is the big security mechanism that we
have for assumeUTXO, is that in the code, there are these hashes hardcoded and
checking against these hashes in the chain params then lets you realize if you
have a UTXO set that is possibly malicious, that is either not the right height
that you are expecting, or potentially somebody has been giving this to you to
trick you to accept coins that you shouldn't be accepting that are actually not
there, for example.

So, I would go into my discoveries first, unless there are any questions about
this for now?

**Mike Schmidt**: No, go ahead, that's great.

**Fabian Jahr**: Okay, so last week I was doing some follow-ups to assumeUTXO
that was just merged, and as part of that I also wrote some tests.  And the test
that I was writing, particularly in this case, is that I was basically
malleating this UTXO set file.  So, my expectation was that I know what is being
written in the file and I know what is being read from the file, so before I
provide the file to the node, I can change some content of it, then it's going
to throw some errors.  And then when I change something else, it's possibly
going to throw the same error or it could also be throwing a different error.
And so when this content is written, there are some basic checks in the
beginning and then that gives a certain error when basically the reading of the
content doesn't make any sense.  But then also, when you do some specific
changes that are, let's say, more correct or not as stupid, then the process is
going to fail much later, and it's going to fail at the end when we're actually
doing the hashing of all the UTXOs that were loaded.  And then it's going to
check against the chain params, and at that point, it should fail.

So, that was my goal with the particular test, to make a change in the file and
then see it only fail at the end when the hash didn't match the chain params.
And so then when I implemented this, I actually didn't see the test fail.  And
so, that was very surprising to me and I actually first thought that I was doing
something wrong, like a very classic thing to do, because I actually know the
hashing code quite well because I refactored it at some point.  And so, I
thought the hashing code cannot be wrong because I know we have tests that
covers it.  And so, I actually thought I had some misunderstanding of the
deserialization of that code, like there was some possibility to change the file
there and it was actually still resulting in the same UTXO set.  Like then it in
itself would also have been a problem, but not as big as a problem as we then
had.

So, I posted this observation because I was going to bed basically, and then the
next morning, Sebastian had already found the issue and the issue was actually
in the hashing code.  So, actually, we were loading a different UTXO set, like
the malleated UTXO set.  It actually resulted in a different UTXO set, but the
different UTXO set yielded the same hash because there was a bug in this hashing
code.  And this particular bug was that basically just some parentheses were
removed from a specific line.  And what that specific line does, it basically
compactly saves the height at which this coin was created, and then also whether
this coin is a coinbase.  So, it has a logic where it basically saves these two
kinds of information in one single number.  Since there are several things going
on in the same line, you need to have some parentheses in order to do the
operations in the right order.  Then these parentheses were removed at some
point, and that resulted actually in different hashes.  But then this never was
discovered because this change apparently was before we actually had coverage of
this.

The test that I wrote for this hashing algorithm I added in, I think, 2020, and
this change was being made in 2018.  So actually, this was always wrong, and I
just hadn't covered this particular case in my tests.  And so, yeah, the hash
has been wrong for a very long time, but this also underlines a bit that this
has never been really used for anything critical previous to assumeUTXO
probably, because

then it might have been discovered.

**Mike Schmidt**: Thanks for walking through the journey that you got to find
this particular bug, because that was actually one of my questions.  So, I think
outlining how you got there is informative to the audience, and thanks for
discovering this, and hopefully we can get a fix in there.  You called out to
the mailing list seeking feedback from users of that potential field that can be
malleated.  Did anybody reach out, and were there any types, classes of users
that could be affected by this, other than obviously the assumeUTXO use case?

**Fabian Jahr**: No, nobody reached out, thankfully actually, otherwise it could
have been a mess.  But in this case, yeah, we actually already have the fix in,
it was merged two days ago.  So, yeah, maybe I can speak about that, but nobody
has reached out.  And as I said, I think nobody is really using this.  That was
also my feeling before.  But if somebody reaches out, then we can still take
action and include the old hash again.  But yeah, since what I described is
actually the hash is not correct, so we rather not like, because in certain
scenarios like in assumeUTXO, it's actually not safe to use it anymore.  And so,
yeah, maybe I should talk about what we've done.

There was actually a way to fix it very minimally by just adding the parentheses
back basically, but there were also some other issues with it discovered.
Niklas wrote the fuzzer very quickly and discovered some further potential
issues with it.  In the end, what we did is we actually changed the whole
serialization format, but it was not anything new that we introduced.  Instead,
we use the same serialization now that is also used for MuHash.  And so, we also
incremented the version of this hash_serialized, so we basically now use the
same serialization for both the SHA-256 hash, which is now called
hash_serialized_3, as well as for the MuHash.  And so, it's recommended if you
are looking at this hash for any kind of use case, then you will have to switch
to this new version 3.  It's very simple; in the place where before
hash_serialized_2 was returned by gettxoutsetinfo, now it's going to be
hash_serialized_3.

I have actually a commit that is ready to go where we could do some
compatibility, where we could have the normal workflow with the deprecated RPC,
and that would then show the hash_serialized_2, the old one as well.  But as
long as nobody reaches out and says they need this for some reason, because they
cannot upgrade to the new hash quickly, we didn't really see a reason to include
that.

**Mike Schmidt**: Fabian, thanks for walking us through that.  You're welcome to
stay on for the rest of the podcast, or if you have other things to do, you can
drop.  Oh, Murch has a question.

**Mark Erhardt**: Yeah, I wanted to ask.  So, we were going to talk about
Bitcoin Core26.0rc1, and one of the big headliner items there of course is also
assumeUTXO.  So, I might have missed it in the beginning of your introduction,
but if you have to drop, I would like to ask you what the exact feature coverage
of what's shipping in 26 is going to be.  But if you're going to stay on, we can
talk about it later.

**Fabian Jahr**: I will stay on.  I'm not sure what you mean by feature
coverage.

**Mark Erhardt**: So, I know that the snapshot loading is in, but are we
actually shipping a snapshot in 26 now?  And I think that there is no mechanism
yet with how the data for the snapshot hash is being distributed, so that was
going to be my line of questioning.

**Fabian Jahr**: So, yeah, the distribution stuff is unsolved, so it's out of
band that you would need to get a hold of the file that includes the UTXO set.
Examples where this can work for that I always say is like if you get a node
like a RaspiBlitz or an Umbrel or so, it could be preloaded, but this is
unsolved and there were just some ideas thrown around about it lately.  And
then, in terms of being able to use it, so this is actually something that I
think we also need to communicate well in the release notes, is that the chain
parameters are not there yet for mainnet.  We actually just left them out
because I guess there was a feeling that maybe, for example, test coverage is
not as good as it could be.  And so, there is going to be only chain params for
signet and for testnet included in the release.  So, when you run the actual 26
release and you don't want to malleate the chain params yourself, then you will
only be able to use it in testnet and signet.

I just wanted to add one more thing that I think was really cool to see for me,
like the effort, like I'm here speaking about it now, but yeah, as I said, this
was actually discovered and the fix was merged within less than a week.  And
that was particularly because I was trying to do the changes quickly, but then
also there were several people that were responding quickly and doing review and
giving feedback.  And so, yeah, this was really great that there were three,
four or five people that were really taking action quickly also and helped
getting this in as soon as possible.

**Mike Schmidt**: Excellent.  Nice work, Fabian.

**Fabian Jahr**: Cool, thanks.

_Research into generic covenants with minimal Script language changes_

**Mike Schmidt**: Next item from the news section is titled, Research into
generic covenants with minimal Script language changes.  And unfortunately, the
author of this research and the post of the Bitcoin-Dev mailing list, Rusty
Russell, wasn't able to join us, so we will summarize as best we can the work
that he's been doing.  Rusty posted to the mailing list with a link to his blog,
where he explores ways of achieving covenant functionality using some simple new
opcodes.  He calls his preferred approach to covenants "fully complete
covenants", which involves pushing some specified field or more than one field
of a transaction onto the stack for evaluation, which is in contrast to what he
calls "equality covenants", where a hash of the requested transaction's fields
is put onto the stack for evaluation.

So, if you're curious about Rusty's high-level thoughts on types of covenants,
check out his posts, separate from the one we highlighted in the newsletter,
titled Covenants in Bitcoin, a Useful Review Taxonomy.  I think that's a good
way to categorize, at least at some level, the different types of covenant
proposals.  His posts that we highlighted in the newsletter this week walk
through an initial example of introspecting a single taproot scriptpath, and he
goes through a few different steps.  In step one, he uses either a new opcode
OP_CAT, which we'll get to potentially in a minute, or OP_MULTISHA256 to get a
tapleaf hash of the script.  And in step two of his example, he then uses a new
opcode, OP_KEYADDTWEAK, to tweak the pubkey by that tapleaf hash that was
calculated in step one.

In step three, he prepends the segwit v1 bytes for taproot, which are OP_1 32,
and then compares all of that with the scriptPubKey of the transaction in
question, using again either OP_CAT or OPMULTISHA256.  And that was just a
simple example of a simple single taproot scriptpath.  He has different examples
of script in his blogpost that walks through that.  And in order to do more than
one tapleaf condition, he notes that another opcode, either OP_LESS or
OP_CONDSWAP, are needed.  And in order to enable even more useful features,
there would be changes needed to the semantics of the OP_SUCCESS type opcodes.
And, Murch, I know you have some things prepared as well.  That was my takeaway
from reading through the blogpost.  You want to jump in?

**Mark Erhardt**: Sorry, I think that got mixed up.  I have some stuff prepared
for the release candidate later.  Honestly, I have not been closely following
the entire transaction introspection debate.  I'm waiting for people that are
really excited about these potential new use cases to make up their mind what
sort of proposal they are trying to champion, because right now, the way it
looks to me, there is still a lot of disagreement or differing preferences on
what people want to do, what people need to do that.  So, I have not spent
enough time on it yet to have some firm opinions on it.

**Mike Schmidt**: Well, it looks like we've lost Ethan, who I was going to ping
on this to see if he had an opinion, given his work on OP_CAT.  But yeah, I
think take a look at those two blog posts from Rusty's blog, one that we link to
in the writeup, and then the other one that I've noted as a useful review of
taxonomy.  And hopefully at some point, we can get Rusty on to talk about this
and some of his other thoughts on Bitcoin Script and covenants.  I see Ethan's
back.

**Mark Erhardt**: Yeah, maybe I can elaborate a little bit more on my position.
So, I think we've had a lot of discussion in the last year, and I have the
impression that the topic has been making a lot of progress, especially since
OP_CTV was pushed into the main discussion for a bit, and other people became
aware that there are engineering and research questions that need to be
addressed.  I think, for example, that James picking it up and saying that
OP_CTV would perfectly fit the OP_UNVAULT needs of his vaulting proposal, and
Rearden Code writing a big summary on what exactly the differences of ANYPREVOUT
(APO) and CHECKTEMPLATEVERIFY (CTV) and his own preferred style of combining
them would be.  So, I see that people are making progress on all of this, but
personally I'm just not involved enough to have a personal need for any of
these, so I've just not been reading much on it.  I see Ethan's here now.  I'll
shut up and let him talk.

_Proposed BIP for OP_CAT_

**Ethan Heilman**: Hi, thanks, I'm joining from the train.  I guess the reason
I'm very excited about OP_CAT is that Bitcoin doesn't really have a general
purpose way to combine things on the stack.  And so, when I've attempted to
build interesting scripts, this was always the roadblock.  So, OP_CAT is kind of
following from the idea of the UNIX philosophy of a very simple, basic, modular
opcode that lets you combine things on the stack, and that you can use with
other opcodes to build complex behavior, where we don't dictate how you will use
it, we just provide this nice, simple way to combine things on the stack.

**Mike Schmidt**: Ethan, you've muted yourself, I think.

**Ethan Heilman**: Oh, yeah.  So, I guess just thinking through some of the
things you can build with OP_CAT, but not an exclusive list, is you can, say,
build merkle trees in Bitcoin Script now.  So, for instance, if you have OP_CAT,
you can take two objects, concatenate them together and then hash them, and then
take two other objects, concatenate them together and then hash them, and then
concatenate the two hashes together and then hash them.  So, this allows you to,
for instance, do tree signatures or tree pubkeys, in which you commit to a large
number of pubkeys in a single hash, and then show the merkle path to that merkle
root.  But there's just so many things that can be built with OP_CAT, and it's a
very simple change.

**Armin Sabouri**: Yeah, this is Armin.  The other thing people are really
excited to use with OP_CAT is CTV-style covenants.  Andrew Poelstra has a
three-part blog on how to do this, I don't know if Rusty goes into this at all,
but there is an opportunity for users to essentially put all the components of a
transaction that would spend on the stack, concatenate them, and then use
another hypothetical opcode, called OP_CHECKSIGFROMSTACK to check if -- well,
CHECKSIGFROMSTACK just checks a message against an arbitrary signature.  So, you
would essentially check if the transaction that's spending is the one that's
being provided on the stack.  So, you use that same signature with the normal
OP_CHECKSIG to verify that, and then you could just do whatever introspection
you want on the transaction components.  Yeah, so definitely look into Andrew's
blogs for a comprehensive understanding of how that works.

**Mike Schmidt**: Go ahead, Ethan.

**Ethan Heilman**: And this is a very simple change to add.  Our reference
implementation is based on the Elements version of OP_CAT.  So basically, you
can just take an OP_SUCCESSX and redefine it to OP_CAT and soft fork it in.

**Mike Schmidt**: And just to clarify my understanding, and maybe for some of
the listeners, over ten years ago, what was it, back in 2010, there were a few
bugs found in some of the opcodes and Satoshi made a change that disabled 15 of
them, which actually we get to in the Stack Exchange, I think, as well.  And I
think one of those opcodes was OP_CAT in Bitcoin Script.  But the proposal that
you guys have written up doesn't add OP_CAT back to Bitcoin Script but instead
introduces OP_CAT as a new tapscript opcode; do I have that right?

**Ethan Heilman**: Yes, that's correct.  We're adding it back as a --

**Mike Schmidt**: And also to clarify, I think we had a similar situation a few
weeks ago in Newsletter #272.  We had on Steven Roose, who was outlining his BIP
to specify the OP_TXHASH code, and he made it clear that that was just
specifying how the opcode could work, and that he wasn't proposing any sort of
soft fork activation, just specifying his ideas on how OP_TXHASH might work.  I
think that's similar to what you're proposing here.  The BIP is saying how this
could work, and you're not actually proposing something as part of a soft fork
activation; is that right?

**Armin Sabouri**: Not quite.  I think Steven also is proposing a soft fork,
even if the BIP is not specifying that, I think the BIP is still a draft.  So I
think actually, if I understand Steven's proposal, it's to get to a soft fork.

**Ethan Heilman**: Yeah, that's correct.

**Mike Schmidt**: Murch, do you have any clarifying questions or comments?

**Mark Erhardt**: No, I think I've said everything.  I afford myself not to have
an opinion on introspection at this time.

**Mike Schmidt**: Ethan, I heard you mention the elements codebase.  There's an
implementation of OP_CAT in Elements and Liquid currently that's running; is
that correct?

**Ethan Heilman**: Yes, that's correct.  Elements added OP_CAT a while ago and
it's actually fairly similar with just a few small changes to what Satoshi
originally had for OP_CAT, and so since that's been fairly well tested, we're
basing our implementation on the Elements implementation of OP_CAT.

**Armin Sabouri**: Yeah, actually the plan to implement this is just to take the
Elements PR that re-enables OP_CAT, change it so that it uses one of the
OP_SUCCESS opcodes restricted to tapscript, and the plan is to implement it into
AJ's Bitcoin Inquisition signet.

**Mark Erhardt**: I do have the impression that those two are training too hard;
I'm not getting their sound at this time.

**Mike Schmidt**: Yeah, I think we made it through most of the explanation
without them being in a tunnel somewhere.  I think we could probably wrap up.
Ethan and Armin, thanks for joining.  You're welcome to stay on if you need some
train entertainment.  Otherwise, I think we'll move on with the newsletter.

**Ethan Heilman**: Thanks for having us.

**Mike Schmidt**: Thanks for jumping on in such a stressed situation.  It's
great to get your feedback.  Next section from the newsletter was Selected Q&A
from the Bitcoin Stack Exchange.  We have six that we highlighted this month.

_How does the Branch and Bound coin selection algorithm work?_

The first one, I'll tee up to Murch.  Murch, how does the Branch and Bound coin
selection algorithm work?

**Mark Erhardt**: Well, glad that you asked.  So, I recently realized that this
question had never been asked on Stack Exchange, and some people that are
familiar with the topic will realize that I'm talking about my own work from
2016.  So, this is the subject or one of the results from my master thesis that
I wrote seven years ago.  So, anyway, I just asked and answered that question
and described how Branch and Bound actually works.  And really what it does is,
it is essentially an exhaustive search to find the least wasteful input set that
produces a changeless transaction.  So, we're trying essentially the whole
combination space of all UTXOs in your wallet and see which one would be the
least costly compared to a hypothetical spend in the future, and we use that to
create a changeless transaction.

So, clearly that doesn't always have a solution so in the case that it doesn't
have a solution, we fall back to other coin selection mechanisms; but when it
does have a solution, creating a changeless transaction is a smaller
transaction, it is therefore a cheaper transaction, it also has some privacy
benefits not to send change back to yourself, it breaks some of the core
assumptions about transactions that they always have two outputs, one is change,
one is a receive.  So, to some analytics software, it might look like you're
doing a consolidation rather than a payment.  Yeah, so anyway, if you're
interested in coin selection, there's a few topics on Stack Exchange to that
effect.  And I think in a lot of wallet software, this is still an unsolved
problem.  So, if you're interested in that, come talk to me.

_Why is each transaction broadcast twice in the Bitcoin network?_

**Mike Schmidt**: Next question from the Stack Exchange is, "Why is each
transaction broadcast twice in the network?"  And the person asking this is
referencing an early mailing list post from Satoshi in which he noted, "Each
transaction has to be broadcast twice".  And the assumption of the person asking
this, as well as Antoine who answered it, was that at the time that Satoshi
wrote that, the transaction was broadcast twice because there was once during
the transaction being relayed before it was confirmed in a block, and then the
transaction data was also then included during block relay when that transaction
was confirmed in a block.

The confusion maybe from this person or maybe the reason this person is asking
is that that's not the case anymore.  With the addition of BIP152, which is
compact block relay, means that the transaction data needs to only be broadcast
once to a peer, either when you're relaying transactions to that peer or when
that block gets in because of the compact block doesn't include redundant
transaction information, so you really only need to parse that once to appear.
Murch, any thoughts?  Oh, hand up.

**Mark Erhardt**: Yeah, I wanted to share an anecdote by a seasoned Bitcoin
protocol developer.  Back in the early days, when a new block came in, you would
just get a small spike of data because people would just offer you that block,
you'd download that block, and then you'd push it out to all your peers again.
He noted that in some video calls that he was on, he could see who was running
Bitcoin Core nodes because they would all start stuttering at the same moment.

So, now that we have compact blocks, that doesn't really happen that much
anymore, because we spread out all of the transaction relay to before the block,
and usually, hopefully, you have seen something like 99% or more of the block
content before you see the block announcement.  And with the compact block
announcement, you basically get a recipe how to rebuild the block from your
mempool.  And in the optimal case, you have all the transactions, but if not,
you might be asking only for a handful of transactions, and usually they are not
that big unless they include a bunch of memes.

_Why are OP_MUL and OP_DIV disabled in Bitcoin?_

**Mike Schmidt**: Next question from the Stack Exchange, "Why are OP_MUL and
OP_DIV disabled in Bitcoin?"  And so these are two opcodes for multiplying and
dividing, and we alluded to this earlier in the change that Satoshi made, which
disabled a bunch of opcodes within weeks of two vulnerabilities, one being the
one return bug, which allowed basically anybody to spend anybody's coins; and
there's also a link to the OP_LSHIFT crash bug.  Both of those bugs were
discovered in the weeks prior to Satoshi disabling those 15 opcodes that I
mentioned earlier, which included OP_CAT, but also included these opcodes, which
to my knowledge, there weren't necessarily any concerns about multiplying and
dividing.  But Murch, are you aware of any potential vulnerabilities there, or
was just Satoshi being cautious in disabling a wide swath of things in the wake
of two vulnerabilities?

**Mark Erhardt**: I'm not aware of any other vulnerabilities, but we also had a
related question on Stack Exchange recently, which asked why OP_MUL was never
reintroduced since then.  And Pieter replied that there just doesn't seem to be
a known use case of anything interesting that you could do with it.  So, maybe
it was also just Satoshi taking a good look at the opcodes that were there and
being overly cautious, but also taking out opcodes that weren't that interesting
in hindsight.  I mean, as always, we don't know what Satoshi thought and he's
been a little reticent in the last 12 years, so I don't think there's going to
be more insights coming!

_Why are hashSequence and hashPrevouts computed separately?_

**Mike Schmidt**: He hasn't responded to any of my emails!  Next question from
the Stack Exchange, "Why are hashSequence and hashPrevouts computed separately?
And Pieter Wuille answered this question, and he indicated that if you split up
the to-be-signed transaction hash data into prevouts and sequences, those
precomputed hash values can be used once for the whole transaction and can also
involve a bunch of different signature hashes (sighashes) as opposed to not
precomputing those.  I think the person who was asking this was thinking about a
particular SIGHASH_ALL signatures, whereas there's other sighash types,
SIGHASH_ANYONECANPAY, SIGHASH_NONE, SIGHASH_SINGLE, in which you're signing for
different pieces of the data.  So, by precomputing those two pieces of data, you
have everything you need for the rest of the transaction.

_Why does Miniscript add an extra size check for hash preimage comparisons?_

Next question from the Stack Exchange, "Why does Miniscript add an extra size
check for hash preimage comparisons?"  And Antoine answered this one as well
noting that, "Hash preimages are limited size in miniscript to avoid
non-standard Bitcoin transactions", so transactions that wouldn't be by default
relayed on the P2P network, "and also to avoid consensus-invalid cross-chain
atomic swaps", so in the case that you're swapping your Bitcoin for LN or some
such thing, you could end up where one side of the swap is valid and one side is
not if those preimages are too large, compared to that chain's consensus
requirements.  And he also notes that by limiting this in the way that
miniscript does, "The witness costs can be accurately calculated", which has its
own value.

_How can the next block fee be less than the mempool purging fee rate?_

Last question from the Stack Exchange is, "How can the next block fee be less
than the mempool purging feerate?"  And the person asking this included a couple
of mempool.space dashboards.  One showed the default mempool purging 1.51
satoshis/vbyte (sat/vB) transactions, and then the second screenshot indicated
that the estimated next block template was going to be containing transactions
that were 1.49 sat/vB, and Gloria answered this question.  She gave two cases in
which this could be true, and also indicated the one that she thinks is likely.
And the explanation that she thinks is likely was that when the mempool's full
and transactions need to be evicted from the mempool in order to not exceed the
max mempool size, that at the time that the eviction occurs, the mempool min
feerate is incremented by this -incrementalRelayFee.  That doesn't evict all of
the transactions that are lower than that feerate, so there are some
transactions that would still be in the mempool that did not need to be evicted
in order to stay within the maximum mempool size.

In this case, there was a bunch of potential I think it was consolidation
transactions that were right around that feerate.  And so that would explain why
it's purging "1.51 sat/vB", but the next block is actually going to include 1.49
sat/vB.  Murch, any clarification there?

**Mark Erhardt**: Yeah, I just wanted to point out that when your mempool starts
purging stuff because it's running full, it will actually bump its minimum
dynamic mempool feerate to a value 1 sat/vB higher.  So, if you purge something
at 1 sat/vB, it'll immediately jump to 2 sat/vB and will not accept any new
submissions below 2 sat/vB.  So, even though you only kicked out the lowest,
everything under 2 sat/vB still remains beyond that.  You would continue to
evict if you get more submissions at higher feerates and your mempool bumps into
the limit again, but this is not a special case or a weird case.  This is more
or less always the case when you bump that everything else that was also below
that feerate remains.  We don't kick unnecessarily more than we need, we just
kick until we're down below the limit again.

Now, how would you even get a feerate of 1.5?  Well, the dynamic minimum mempool
feerate, that's a mouthful, decays over time again, so it would just be simply
stupid if you could resubmit the same thing right after you kicked it out.  So,
once the limit has been popped up a bit, over time it will slowly decay down to
no limit at all, but only as it is not full and needs to evict new stuff again.
So, you would only ever get to 1.5 by decaying back down, but this is of course
not the case on the mempool side.  Mempool actually has a way bigger mempool and
keeps a lot more transactions around and doesn't expire them after two weeks
either, so they just calculate the dynamic minimum mempool feerate that you
might see on your own node if you're running it.  Or maybe they have a second
one with the default and read it off of there, but I think the first is more
likely.

**Mike Schmidt**: Murch, during that bumping of the minimum mempool feerate by 1
whole sat/vB, doesn't that mean that if I'm a miner, I'm potentially now keeping
transactions that are less profitable from a feerate perspective than I could
be, because I'm now excluding, I guess, in the example of going from 1 sat/vB to
2, I'm now not including 1.9, but I am including what was there before, in this
example, the 1.49 or whatever; is there a mismatch in incentives there?

**Mark Erhardt**: That is correct.  Basically what we're doing is we're saving
bandwidth.  We're limiting what we're accepting at this moment because it is
very unlikely to be interesting to include it in blocks for a long time.  When
your mempool data structure hits 300 MB, and this is not a serialization size,
this is just memory on your computer, you have something like 90 to 120 blocks
or so worth of transactions bidding on being in the next block.  So, if you're
bumping up by 1 sat/vB, you're probably just not allowing a few things in the
low range territory to be submitted to your mempool, but you have ample other
transactions waiting to be included, probably some six years or so blocks' worth
of transactions that are bidding a higher feerate.

Well, in this case specifically, we had a ton of transactions waiting between
one and two, but still you're going to get the highest feerate transactions and
going to continue to accept them, but there would potentially be a mismatch like
that, where you keep some lower feerate transactions but do not accept slightly
higher.

**Mike Schmidt**: So I, as a just noble node runner, am protected from a
bandwidth perspective with this; but if I am a miner, I might not care about the
bandwidth protection and might care more about the fees, and maybe I'm
incentivized then to run a modified version of Bitcoin Core in order to get
those fees?

**Mark Erhardt**: I think you would maybe modify the configuration.  Yes, as a
miner I would probably have multiple nodes that are connected to the network in
order to learn about new transactions, especially juicy transactions, as quickly
as possible.  So, even if something is broadcast right before I find my next
block, I hopefully have already included it in my block template.  Also, if my
connection to the network has an issue, like the node goes down, or someone is
DoSing it, or whatever not, I do not stop learning about new transactions for my
block templates.

So clearly as a miner, I would like to have multiple border nodes that then
connect to my template-creating node.  And maybe my template-creating node would
run with a bigger mempool and without an expiry in the first place, and probably
also mempoolfullrbf, so I ensure that I always learn about the highest feerate
transactions and keep other queuing items around as long as possible, in order
to build the best block templates.  But then I might also be running multiple
border nodes with different configurations.  So, maybe most of them are default
configuration, but maybe there's a couple that have a bigger mempool in order to
relay everything to my template-creating node.  Or, maybe I'll have some that
are mempoolfullrbf and some that are not, so that I keep both the original
transactions and the replacements and make sure that I see everything.

But yeah, I sometimes wonder how much of this miners do, because a lot of them
seem to be mostly focused on the logistics game, like saving money on the energy
price, the cooling, the setup, the maintenance, staff, and so forth.  Yeah,
maybe, I don't know how much they also work on optimizing their interactions
with the network.

**Mike Schmidt**: Back in our earlier discussion of the replacement cycling
attack, there was also one of the mitigations which involved miners doing
something a bit different with transactions that they've seen as well.  So,
maybe even more incentive for them to start fiddling with that, which could have
bad outcomes as well.  We covered the explanation that Gloria gave that she
thinks is the explanation for this mismatch in the charts on mempool.space for
this example.  But she also mentioned another explanation that could result in
something like this, which is the asymmetry between ancestor scoring, which is
used for including transactions in a block, and descendant scoring, which is
used for eviction from the mempool, as another possible explanation to why this
mismatch could occur.

Then she also links to our Optech topic on cluster mempool, and an issue on the
repository explaining cluster mempool, as well as this asymmetry between
ancestor and descendant scoring.  I don't know if you have any comments on that,
Murch.  I know we talked about that a bit with the Mempool and Policy Series
special that we did on the newsletter.

**Mark Erhardt**: Yeah, cluster mempool, to sum it up, would fix this asymmetry,
in that once we track transactions in the form of clusters instead of ancestor
sets, we would have asymmetric eviction and block building.  So, the things that
we mine last would also be the first things to be evicted, and that is actually
one of the really exciting things about the cluster mempool proposal.

**Mike Schmidt**: That wraps up the Stack Exchange section.  We don't have any
Notable code and documentation changes this week, but we do have three releases
that we highlighted in the newsletter.  Murch, as our resident Bitcoin Core
developer, although we also have Fabian on today, I thought maybe it would make
sense for you to highlight what you think is important about these maintenance
releases, as well as the 26.0 release candidate.

**Mark Erhardt**: Yeah, while it is release season, we've seen 24.2 and 25.1
drop this week, and 26.0 is in the making.  The point releases, as we've stated
here a few times already, are mostly about bug fixes.

_Bitcoin Core 24.2_

I think the most notable changes in 24.2 are that we have a fix for avoiding to
serve stale fee estimates.  So, this was an issue, if I remember correctly, that
comes up when you bring back online a node that was offline just for a couple of
hours, less than the time window to lose all data on fee estimates.  The window
is, I think, somewhere around three hours for the estimate to be complete.  And
then it would come back online after a couple hours of being offline, and
happily serve you the estimate that is based on two-hour old mempool data.  So,
there's a fix for that.  This has also been backported to 25.1.

_Bitcoin Core 25.1_

In 25.1, there's also a fix for parallel compact block downloads.  So, this
addresses an issue where if you got an announcement of a new block and you were
missing a couple of transactions, and usually you first try to get that from the
node that has announced a block to you first.  But if this node then is really
slow to offer you up the actual transaction data of the missing transactions,
you might be stuck on trying to validate that block.  And I had a cursory look
on that.  From what I understand, the solution is to ask for the missing
transactions for block templates from more than one node, and potentially ask
some high-bandwidth nodes to also provide copies of those transactions,
especially if that is just slow to come in from the first announcer.  So, I
think that is mostly what I would wrap up on the two point releases.  Fabian, if
you have more, please feel free to jump in, otherwise, I'll be looking a little
bit at what is coming in the 26.0 release.

_Bitcoin Core 26.0rc1_

As usual, this is a release candidate, so it's not final yet.  We might find a
bug or two yet.  The release notes are not completed yet.  If people are relying
on the Bitcoin Core software and are interested in running that in production
soon in their backend, or whatever, we always encourage to read the entire
release notes and to maybe start putting it in their test setup to see if
there's any issues.  There is a bunch of new RPCs, RPC changes, new features, a
bunch of changes in the wallet.  And let's take it from the top.

So, we've talked a ton already earlier about assumeUTXO.  As Fabian earlier
said, the code for loading the snapshot is in, and there will not be a snapshot
shipped in the release because there is maybe a little more test coverage to be
built out there, and a little more maturity to arrive with the assumeUTXO code,
so it's only being shipped for testnet at this time.  There's also BIP324
support being shipped.  So, if you have been hankering to encrypt all the
connections between your Bitcoin node and its peers, you can now turn on support
for v2 transaction relay.  This is off by default, but if you turn it on, two
peers that both support the new v2 relay will figure that out during the
handshake and then start using v2 P2P messages in order to communicate with each
other, and will encrypt their traffic.

If you do not rely on your node doing all the right things on your backend and
just run it as a hobbyist without big infrastructure hanging from it, or are
more on the adventurous side, I would encourage you to turn that on, just like I
will when the release is out, and tell us if anything interesting happens that
shouldn't be happening, please.

Let's get to the new RPCs.  There are four new RPCs.  One is
getprioritisedtransactions.  So, if you are a miner, you might have manually
changed the order in which you want to mine transactions in the next block by
prioritizing a transaction, for example, because you have personal interest in
that being included or somebody bribed you out of band to get a confirmation
more quickly.  Now there is an RPC to see which items have been changed from
their regular fee-based priority.  Again, anybody catching me to make a mistake,
I've only been staring at this for a few minutes, so I might misremember
something.  And if you care about this sort of stuff, please read the actual
release notes.  Also, the release notes are incomplete still at this time
because it's rc1.

Second item is a submitpackage RPC.  I think we've covered that one a little bit
previously.  Submitpackage is used to test whether multiple transactions
together would be able to enter the mempool rather than them being evaluated
separately.  So, usually all transactions would be processed individually and
each transaction, for example, has to supersede the dynamic minimum mempool
feerate.  But if you, for example, have a low-feerate parent transaction and a
high-feerate child, you will now be able to submit that to your own node via RPC
and get your node to evaluate those two transactions together.  And if the child
bumps the parent high enough that both of them would be viable in your mempool,
they will be accepted into your mempool.

So, this is new, this is obviously part of the package relay effort.  And if
you, for example, run LN infrastructure, this might be an interesting RPC for
you to look at.  Jesus, getting lots of messages here.  There is further an
importmempool RPC.  We've had a way to export the current mempool for a while.
If you, for example, run multiple nodes because you're a miner and you want to
synchronize what mempools they have, you could use the exportmempool and the
importmempool RPCs to transfer from one node to your other node.  Danger here is
if you just randomly import mempool stuff from other nodes, I think not all the
checks are run on it because it assumes that the stuff is already validated.
So, don't randomly download mempools from other people and then trust them to
accurately portray unconfirmed transactions, or they could also fiddle with your
prioritization.  So, it imports, for example, the prioritized transaction
settings on transactions.  This is more a thing you might want to do if you run
multiple nodes and want to import mempools from one to the other, but maybe be
cautious if you're downloading mempools from other people.

There is also a getaddrmaninfo RPC.  Sorry, this is turning a little bit into a
soliloquy.  Let me know if you want to jump in or have comments on anything.
So, with getaddrmaninfo, we get an overview of what's in the new and in the
tried table of the nodes address manager, and it just gives you a count of the
addresses in new and tried, as well as a sum of all the networks.  There is
further a P2P change that makes sure that if you are connected to multiple
networks, you always try to keep one connection open on every network, which
previously not necessarily was true.  So, for example, if you were connected to
Clearnet and Tor, but you had way fewer items in your table for Tor, you might
lose connection to the Tor Network.  We will now protect at least the last
connection to each network, so you're always connected to each of the networks
that your node uses.

Before I do wallet, let me say something about testnet.  There's a huge change
on how Bitcoin Core will interact with the testnet.  So far, testnet was the
Wild West, and you would allow all transactions.  We will now make your node
interacting with testnet, a lot more like mainnet, in the sense that your node
will not accept non-standard transactions on testnet by default.  If you want
the old behavior, there is a way to turn that back on, but generally we will not
accept to our mempool or propagate non-standard transactions on testnet anymore.
And I think the motivation here is mainly that we want to remove the difference
in UX.  So, some people might have been testing their stuff on testnet and
everything works great and then when they move to deploy their software on
mainnet, they realize that it actually does not work because they were using
non-standard transactions, and the change to how we behave on testnet will now
remove that source of confusion.

All right, wallet changes.  A bunch of RPCs now return whether a transaction has
been abandoned as an abandoned field.  Hardened derivation is now indicated y
and h on some of the descriptor and PSBT RPCs.  Previously, that was an
apostrophe.  And as anyone that has been trying to use the Bitcoin Core node
from the command line has noticed, getting the quotation marks for all of your
calls right is a hassle.  So, having an apostrophe in the PSBT and descriptive
descriptions sometimes made it harder to correctly phrase your command line
commands, and now being able to use h instead makes that easier.

A bunch of informational RPCs that get information include now a
lastprocessedblock and that will make it easier for you to learn about whether a
response has been outdated by now or not, because you know what the latest state
of the node was when you got that response from the RPC.

In the walletprocesspsbt and descriptorprocesspsbt calls we now return the final
transaction if it is final already.  So, if you are processing a PSBT and you're
adding a signature and this finalizes the transaction, you don't have to call
separately to get back to final hex; you immediately get that delivered if the
transaction is now complete and can directly put that into sendrawtransaction
for example.

Also something that is not in the release notes yet, because I haven't written
them yet, if you're spending unconfirmed inputs and the parent transaction has a
lower feerate than the target feerate of the transaction you're creating, you
will automatically bump the parent transaction to the same feerate now, which
means that you're not creating an unexpected CPFP situation and undershoot the
target feerate that you were aiming for.  I call this ancestor-aware funding or
automatic CPFP.  And if you want to read more about that, I will write release
notes soon.

Okay, this is my 26.0 preview.  If you're interested in any of those features,
please do test the new release candidate.  If you're interested in reading more
about it, please look at the release notes.  And if you want to get into Bitcoin
Core development, we should talk about that some other time!

**Fabian Jahr**: I think the one new RPC that wasn't mentioned yet is the
getchainstates RPC.  Just want to add that.  So, we talked a bunch about
loadtxoutset, and if you actually succeed in loading the UTXO set, then there's
going to be temporarily two chain states.  So, one is going to be at the tip,
and the other one is going to do Initial Block Download (IBD) in the background.
And so, to monitor the process, you can call getchainstates to see what the
progress is.

**Mark Erhardt**: I just grabbed through that and see that it is mentioned in
the loadtxoutset RPC, but that might need to be its own bullet point.

**Mike Schmidt**: Murch, awesome.  I had no idea you were going to have such
thorough notes.  This is great.  We can point people to this as a definitive
place to look for 26.0 ads, so thank you.

**Mark Erhardt**: Thanks, glad that it was well received.

**Mike Schmidt**: Well, thanks everybody for joining us.  Thanks to our special
guests, Bastian, Fabian, Ethan, Armin, and always to my co-host, Murch.  See you
next week.

**Mark Erhardt**: See you.

{% include references.md %}
