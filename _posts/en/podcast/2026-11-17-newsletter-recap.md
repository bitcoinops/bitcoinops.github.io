---
title: 'Bitcoin Optech Newsletter #431 Recap Podcast'
permalink: /en/podcast/2026/11/17/
reference: /en/newsletters/2026/11/13/
name: 2026-11-17-recap
slug: 2026-11-17-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Antoine Poinsot to discuss [Newsletter #431]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-10-17/436999564-44100-2-95a98778dc61d.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #431 Recap.
We're going to talk about some Bitcoin Core vulnerability disclosures in older
versions; we have a draft BIP for the anti-exfil signing on hardware devices;
the testnet5 genesis block; and also what was going on, three months of poor
compact block reconstruction, we have a Delving thread on that; and our
Notable code and documentation changes and Releases as well.  Murch, Gustavo,
and I are joined this week by Antoine, a regular of the show at this point.
But Antoine, for folks who don't know, who are you, what are you working on?

**Antoine Poinsot**: My name is Antoine, I work at Chaincode Labs on Bitcoin
Core, mostly on security-related topics, I would say.

_Disclosure of three vulnerabilities in Bitcoin Core_

**Mike Schmidt**: Thanks for joining us.  We're going to jump to your news
item titled, "Disclosure of three vulnerabilities in Bitcoin Core".  Antoine,
as I mentioned, you're a regular.  You were on two weeks ago, that was #429,
and we talked about Bitcoin Core's new sort of fast lane for easy-to-find bugs
and disclosing them sooner, and that was around the 32.1 release.  And you
also mentioned, I think during that discussion, that there were three older
bugs that would be disclosed on the regular schedule.  Here we are.  This is
the news item encapsulating those three.  Maybe to recap the difference, what
was the difference between the three vulnerabilities two weeks ago and these
three, and then we can get into each of the three?

**Antoine Poinsot**: Yeah, so the disclosures two weeks ago were
unanticipated.  They happened to happen at the same time as the 32.1 release,
but it was unanticipated because it's three vulnerabilities that were found
through automated LLM scans, which means that anyone can just point an LLM to
the codebase and it would spit out these vulnerabilities.  So, for those, we
adopted a new version of the security disclosure policy, which optimises for
shipping fixed binaries, fixed versions of the software to users as soon as
possible.  And as we're doing that, we also full transparency publish the
security disclosures at the same time immediately as soon as the binaries are
published.  So, that was the three that were published at the same time as
32.1, which were also fixed in 31.2, confusingly, and 30.3 or the 30.4 and
29.5.  So, we not only fixed it in the latest release, we fixed it in all
minor releases for versions that were currently maintained.  And these are
just the regular security disclosure process for Bitcoin Core that Bitcoin
Core has been using for over two years now.  These were not found through
automated LLM scanning.  They were found by regular security researchers and
contributors to the project.  And so, they went through the process of slowly
fixing them covertly, have the new releases out, and as soon as the latest
vulnerable version goes end of life, we publish the details, so as to be able
to have as many people upgraded by the time that we release the details.

**Mark Erhardt**: Right, so 29, the major branch 29 is end of life now.  These
were fixed in 29, or before 30.0 at least.  And so, now that the maintained
branches are 30, 31, and 32, the v29 is end of life, and therefore the last
unfixed version is end of life, and the disclosures happen two weeks after the
release.

**Mike Schmidt**: All right, so what do we have in here?  We have one high
criticality and two mediums.  So, maybe we can start with the high, the TRUC
(Topologically Restricted Until Confirmation) sibling eviction bug?

**Antoine Poinsot**: Sure.  So, the TRUC proposal has a feature called sibling
eviction.  Normally, a transaction may only replace another if it conflicts in
the input; it's spending the same UTXO.  And so, you can RBF it and replace it
with a new one.  For some pinning protections, transactions can opt into a
regime of policy rules whereby a transaction spending another unconfirmed
transaction can replace another one even if it doesn't conflict with it.  So,
let's say you have a first transaction that has two outputs, and these
transactions has two children, one on each output, they don't conflict with
each other.  But if they opt in into this regime, the new one spending this
transaction may evict its sibling.  Yes, Murch?

**Mark Erhardt**: To make it very easy, TRUC transactions are only allowed to
have one parent or one child.  So, they are always forming packages of two
transactions.  So, when a solitary TRUC transaction has two outputs, it can
only have one child transaction.  So, even if the two candidate transactions
that we're talking about, the siblings that each spend an output of the parent
transaction, spend different outputs, under TRUC rules they're allowed to
replace each other because the parent TRUC transaction can only have one
child.  So, the higher feerate transaction is accepted to replace the other
transaction, even though they spend different inputs.

**Antoine Poinsot**: Yes.  So, not only is it allowed, it must replace it.
So, the other one must go if the new one arrives and is higher feerate, and
everything.  Unfortunately, there was a bug in Bitcoin Core where that sibling
eviction was applied during a reorg.  So, if a block was mined, which Bitcoin
Core would not mine it by default, but if a block was mined with inside it
transactions that opted into the TRUC regime, so v3, but did not respect the
topology of TRUC, which had two transactions spending the same transaction
through two different outputs in one block, Bitcoin Core, when reorging the
block and reapplying the transaction to its mempool, would apply the sibling
eviction and would evict one of them.  And if it so happens that the one being
evicted also had a child, it would leave your mempool in an inconsistent
state, where you have a transaction that spends coins that don't exist.  And
it would lead, if you are a miner, to not be able to create new block
templates until you restart your Bitcoin Core node.

**Mark Erhardt**: So, the problem here specifically is, let's say a TRUC
package was mined in a block, but there was a competing block at the same
height that did not mine the same TRUC package.  And then, if in the mempool
there was a second child of the confirmed TRUC parent, or additional
descendants, for example, when the other block got a child block, it would
reorganize, roll back all the transactions that were confirmed in your
previous chain tip, put them into the mempool, and then play forward the two
blocks.  And now, the problem was that the TRUC transaction was pushed back
into the mempool, where we had already a sibling and further descendants of
the confirmed package, and sibling eviction was triggered in the mempool and
one of the two siblings got kicked out, for example the one that was still in
the mempool, because that one was going later anyway.  And now, the
descendants were not evicted, only the sibling.  And in sibling eviction,
clearly you only have to evict one transaction because TRUC transactions
cannot have descendants.  So, assuming a mempool that was fulfilling the
invariants of TRUC, you couldn't have those descendants.

So, during reorg we removed some of the restrictions on the mempool because we
just push all the confirmed transactions back into the mempool and play
forward.  But sibling eviction was not disabled.  But then also, due to
transactions becoming unconfirmed, the TRUC rules could be injured.  And this
led to a situation where we would have descendant transactions without their
parents in the mempool, so the mempool was in an inconsistent state.  And now,
the miner could no longer build valid blocks, if it picked any of those
unconfirmed descendants that shouldn't have been in the mempool.  And this
state persisted until a node was restarted.

**Antoine Poinsot**: Very clear.

**Mike Schmidt**: And during restart, I guess there's a process that runs that
wouldn't normally run during the node's operation, which puts it in the
consistent state, is that right?

**Antoine Poinsot**: Yeah, we ditched the transactions with a valid parent.

**Mike Schmidt**: Got it, okay.

**Antoine Poinsot**: Should I continue down the list?

**Mike Schmidt**: Yeah, we can go down the list.  Maybe just a quick note:
responsible disclosure.  This is reported by Niklas back in September of last
year, and Greg Sanders opened the fix a few days later.  Gustavo, you actually
covered this PR in Newsletter #375.  Neither Murch nor I identified that it
was a potential fix.  Yeah, we totally knew!  No, we had no insight into that.
And so, yeah, it looked normal when we covered it.  Fixed in v30, 29.2, and
28.3 over the course of a week.

**Antoine Poinsot**: Yeah, that's actually a good point to discuss the report
here, because we often discuss the details of the bug because that's what's
interesting, but it's also interesting how it was found and how it was
reported.  So, this was found by Niklas Gögge through his Fuzzamoto work,
which is black box fuzzing.  In Bitcoin Core, you have black box tests in
Python where you exercise some scenarios in a high level manner, such as this
peer sends that type of message, then a block is received, then that peer
sends another message and there is a reorg, and whatnot.  So, Niklas extended
this to using a fuzzing framework to test various scenarios in a black box
manner with his framework, Fuzzamoto.  And that's a finding from Fuzzamoto.
So, it's a direct downstream.  Nobody found this bug in a review in testing
before.

So, it's directly downstream of Niklas' work on this framework, which has
proven its usefulness, and it's also a good example of leveraging AI not for
finding bugs immediately.  AI is good for security research and good for
defence and security, not only because you can just ask it to find vulns, but
it's because it can help you build frameworks for better testing, where before
it was tedious to just go through all the scenario, go through all the
boilerplates, to write more fuzzing targets, to write an entire new framework.
In this case I won't go into the detail, but the black box fuzzing needs a
whole bunch of VM restart and stuff, and the LLMs are pretty good at doing
this.  And leveraging LLMs there, I'm pretty optimistic that going forwards,
we can prevent these types of bugs; well, lower the probability of introducing
new bugs by having these techniques.

**Mike Schmidt**: One more maybe comment/question for you, Antoine.  Are you
aware, since there was sort of this embargo on disclosing this one, were the
reports that you've gotten from Loupe and Red Team, and whatever, over the
last six or nine months, did they also find this; or was this still hard to
find by LLMs, even up 'til its disclosure?

**Antoine Poinsot**: So, it's hard to say.  So, nobody reported it besides
Niklas.  So, it was reported over a year ago by Niklas, and nobody's since
ever reported it.  None of the automated LLM scanning.  It's also higher
severity than anything that we have publicly disclosed found by an automated
LLM scan.  It's also the case that if you check out the tag for a vulnerable
release and point one of the new models to it and say, "Find a bug in reorg
handling", it will find it.  So, we had Greg Sanders play around with that,
and he said that, "Yeah, new models can find it by a very simple prompt",
like, find a bug in reorg handling is not rocket science.  So, they can find
it, but it's always easier in hindsight.  It's always easier to be like,
"Yeah, now that we know about the bug and we ask an LLM, actually the LLM can
find it".  But in the other direction, the LLM didn't find it.  The
counterpoint to this is that sure, but most of the automated LLM scanning
efforts are on master and on the latest releases that are fixed.  So, they did
contain the fix.  So, most of the scanning didn't go in previous vulnerable
versions.  So, you can't know for sure.

**Mike Schmidt**: Interesting discussion there.  I think we can move to the
next one, the Tor -whitelist bug.

**Antoine Poinsot**: Yeah.  So, that one was found by Martin and myself.
Martin used to work here at Chaincode and there's a whole bunch of context
around this one.  So, I wrote a blogpost about it in on my personal blog
giving more opinionated context.  So, it was at the height of the Knots
debacle.  It was just around the Bitcoin v30 release.  And at this time, the
public discourse was a lot around number of nodes on the network, like did
Knots have more reachable nodes; did Knots have more total nodes on the
network than Bitcoin Core?  And there were a bunch of people that genuinely
updated their Bitcoin Core nodes to be to Bitcoin Knots.  Notably, we know
that Start9, the company, defaulted to Knots and sold a whole bunch of home
nodes, the turnkey solutions.  So, a lot of the Knots nodes were legitimate.
But there was also people artificially inflating these numbers by spinning up
new nodes in the cloud or faking that, creating new IPs pointing to the same
node, such as you can fake the count, but it's all the same node behind it.

So, Martin just had a quick look, but it was really offhand, just small
investigation in what nodes could definitely be categorized as Sybil, as fake,
because it would use the caching in the address gossip; so, for Bitcoin Core
and Bitcoin Knots, gossip IP addresses that run Bitcoin Core that are
announced to them and they forward them.  But just always forwarding new
addresses leaks a bunch of internal states of your node and can be used to
infer the topology of the network.  So, Bitcoin Core is going to cache the
reply it will send to a request for addresses, and this cache is for 24 hours.
So, the technique that Martin was curious to just use is to query addresses
from a bunch of Knots nodes and see which ones would have, like after an hour,
all these IPs would resend exactly the same set addresses, which would
definitely categorize them as having exactly the same cache, therefore being
exactly the same node.  Eventually he would find a bunch of clusters that did
this in Bitcoin Knots.  So, a few hundreds, definitely Sybil, probably a lot
more that were just new nodes bootstrapped on the cloud.  But that's not the
interesting part here.

The interesting part is that in doing so, he observed that all the Knots nodes
running behind Tor would just not cache anything at all.  And so, why would
they not cache anything at all?  That makes no sense.

**Mark Erhardt**: So, usually, in order to improve the privacy, nodes would
remember which addresses they gave out in address request for, I don't know
what timeframe, Antoine can fill that in, of course.

**Antoine Poinsot**: 24 hours, yeah.

**Mark Erhardt**: 24 hours.  And so, one of the concerns would be if you keep
rolling a new subset, revealing about 30% of your new table and tried table,
the nodes that you know about, if you keep re-rolling the set and telling
about other nodes, you would leak in your entire body of addresses.  And that
would make it easier for someone to observe how well they're doing to Sybil
you or eclipse you, or learn about the topology that you might have with other
nodes.  So, usually, nodes only tell you about a small portion and only change
that in larger, well, in daily tact.  Back to you.

**Antoine Poinsot**: Yeah, so that's the concern and that's also why we're not
quite concerned, but very curious why would Knots nodes not implement this
cache.  Luke has a whole bunch of dubious changes, but this one has no
rationale at all.  There is no reason why Knots would do this.  So, we started
investigating and we just couldn't find anything.  So, also, we investigated
there is a big, big amount of change between Bitcoin Core and Bitcoin Knots,
even at the time.  So, at the time Bitcoin Knots was still a Bitcoin client.
It was not a client for a different network that has forked, it was just a
software fork of Bitcoin Core.  But there was still a lot of changes that also
received very little review.  So, I was like, "I'm sure I'm going to find this
bug in there somewhere".  There's, like, tens of thousands of lines of codes
difference between the two.  And well, I didn't.  And then, we tried to
reproduce it and we couldn't reproduce it, I couldn't reproduce it locally.  I
wrote some tests.  And yeah, we just gave up at some point and went back to
doing real work.

But Martin actually went and ran a further experiment overnight and when we
come came back the next morning, we could see that none of the Knots nodes on
clearnet were affected.  A lot of Knots nodes behind Tor were affected.  And
none of the Bitcoin Core nodes, whether behind clearnet or behind Tor, were
affected, and we could reproduce it locally.  And Martin also made the point
that the distribution of Knots nodes was largely biased towards Tor.  There
were more Bitcoin Core nodes overall.  There were more Bitcoin Core nodes on
Tor than Knots nodes on Tor, but amongst the Knots nodes, the vast, vast
majority of the users were behind Tor.  And that's why he was looking into it
in the first place, because it's so easy to Sybil on Tor.  New identities are
free.  So, like, could that be turnkey node solutions?  Because the turnkey
nodes always have Tor bundled, because they abuse it to have remote control,
to use it as a VPN for remote access to the node.

**Mark Erhardt**: Also, it works as a hole punch, because if you can't get
access to the open network from behind a firewall or router, Tor will always
allow you to have inbound connections.

**Antoine Poinsot**: Yeah, so that's my point.  If they use it for remote
access, they use it to bypass the firewall.  And then, also I pointed out that
there was a difference in how nodes would handle the whitelist.  They would
also give permissions to never cache the addresses.  And yeah, it was the case
that the vast majority of the node-in-a-box turnkey solutions whitelisted the
Tor peers.  And so, all Tor peers will have whitelisted permissions, which
means you lift DoS restrictions, you lift privacy mitigations, and it was only
observable on Knots nodes because Knots also gave the set of permissions which
lift the address privacy mitigations.  But it was all nodes that were
affected, even Bitcoin Core nodes.

**Mark Erhardt**: So, the difference was that when you whitelist a peer, it
would exchange addresses more often, presumably in order to populate the
BIP110 nodes more quickly to their peers?

**Antoine Poinsot**: That's a good question.  So, it was before; at the time,
it was pre-110.  It was still on the mass psychosis timeline.  We're past the
"Core devs are pedophiles", but we are just before the emergency temporary
soft fork.  So, that was not the rationale, it was just a random Luke code
change like so many others in Knots at the time.

**Mark Erhardt**: Okay.  And then, the node-in-the-box setups usually just
whitelisted the Tor daemon, or no, they whitelisted Localhost in order to have
access with other services like block explorers?

**Antoine Poinsot**: Yes.  So, maybe I should explain.  The -whitelist
permissions is a set of permissions.  You have address, you have relay, you
have mempool, and when you just -whitelist equal an IP, it will give a set of
default permissions, but not all of them.  And the difference between Bitcoin
Core and Knots was that by default, Knots would give more permissions than
Bitcoin Core.  And that's why it was observable, because it would lift the
caching on addresses as well.  And so, coming back to the node-in-the-box
turnkey solutions, the reason they would do that is that some applications
need the whitelisting.  So, some applications running on the box need to be
able to spam your P2P ports with request and not be disconnected, this type of
things.  So, for instance BTCPay Server, the indexer of BTCPay Server needed
it.

So, by default, the configuration of all these node-in-a-box would just
include -whitelist Localhost.  What could happen?  That's fine.  That's
Localhost, it's trusted.  And it turns out that in Bitcoin Core, and that's a
bug in Bitcoin Core, or at least a big footgun, Bitcoin Core would treat
peers' inbound Tor connections as coming from the address of the Tor proxy, of
the Tor daemon.  And the Tor daemon runs on Localhost.  So, it would whitelist
all these, which makes no sense; Bitcoin Core shouldn't whitelist Tor
addresses, which it knows the address doesn't mean anything.  It can know it
inside the node, and that was the fix.  The fix was just don't apply the
-whitelist permissions to peers that you know are coming from behind a Tor
proxy.  And so, that's what made it expose the bug, and it was pretty
widespread.  It was thousands of nodes, I would say a rough estimate, probably
5,000 reachable nodes were all completely DoSable and with privacy mitigations
lifted.

**Mike Schmidt**: You mentioned the different parties involved or different
projects involved here, the node-in-the-box, Knots.  So, how did you handle
disclosure or not with those parties?

**Antoine Poinsot**: Yeah, good question.  So, despite my criticisms of Luke,
we did, because it was found by Martin and I, but I was the one who pinged
Luke.  I told Luke because it represented 90% or 80% of Knots nodes.  All
Knots nodes were DoSable and vulnerable to this.  Because many of these people
just were just discontent with Bitcoin Core and didn't necessarily think
people are evil, or whatever, I did tell Luke so he could fix it for these
people, even if I personally strongly disagree with Luke's worldview.  So, I
did disclose it to Luke, who was reasonable in the handling of the embargo.
He said he would respect the embargo and he did respect the embargo, which
that was just a surreal experience for me, where he would publicly insult me
of anything on Twitter, and then in private in he would be almost reasonable
in DMs.  And I couldn't say anything.  And also, you had a subset of the Knots
users who were very terminally online and using, like, "Oh, I upgraded my
Knots node", as if it was owning the Core Devs.  So, they would just be like,
"Fuck you, Core devs, I upgraded Knots", and I'm like, "Yeah, but you're not
owning me, you're upgrading to the vulnerability I disclosed".  But I couldn't
say it.  So, it was a very, very weird experience.

**Mark Erhardt**: Yeah, I've had the same experience with Luke, where in
different contexts he just behaves completely differently.  He just sort of
boxes things and he's different people in different contexts, and they have
nothing to do with each other, is sometimes the feeling.  Anything else on
that one or should we move to the compact block stall one?

**Antoine Poinsot**: No, I think that's it.  If you want some of the details,
there is a blogpost, but that's basically what I just described, is what I
wrote on my blog.  Last one is a blocks processing stall, which the impact is
that a malicious peer could stall you from processing new blocks, could stall
you for ten minutes, and under more constraint conditions, they could even
stall you forever.  So, that's harder to exploit but it's a pretty high
impact.  The reason for this bug is that Bitcoin Core would implement, I would
say, "We don't want a single peer to stall your block download".  So, if one
of the peers is stalling you, we're going to request the block from other
peers.  But there is always a trade-off where you don't want to ask too many
peers, or if you already have a block in flight from one peer, you don't want
to increase the bandwidth, especially if you have a low bandwidth, of asking
it from more peers, which is going to slow down the download of the earlier
peer.

So, there's a whole bunch of logic to avoid doing this in Bitcoin Core, and it
so happens that a few different unrelated facts put together, and the core
thing was that you could malleate the block, the witness part of the block,
and Bitcoin Core would not check it before updating the state of the in-flight
blocks and the block download.  So, you could trick the victim into clearing
the state of downloads, but also not sending the right block.  So, you would
malleate the block, send it, the peer would be like, "All right, that peer is
sending me the stuff, so I'll just not request it from more peers so I don't
shoot myself in the foot", but actually they would shoot themselves in the
foot because then this peer would just stall for ten minutes.  And then, after
the ten minutes' timer, the victim would reissue a new request.  And if the
attacker could occupy the three peers that are used for the parallel block
download, the new request will always go to the attacker who could just
restart the ten minutes' timeout forever and forever and stall the peer.

This was discovered by Eugene Siegel.  I think he discovered it through code
review, an ancient wisdom these days.  And yeah, he emailed the Bitcoin Core
security list in April 2025.  Initially, that's an interesting case as well.
I don't think we even say it in the advisory, but initially we filed it as a
low severity, because our misunderstanding was that you would only be able to
stall the node if you had all its parallel block download connections, which
is already an assumption that you make.  It's already an assumption in the
node, so it's not part of the threat model.  It's not great that you could
stall it forever, but it wasn't quite a big severity issue.  But you could
still stall the node for ten minutes with only one of these peers, as long as
you are the first to announce the block to the peer.  And if the node was
running in -blocksonly, which is a non-default but fairly common
configuration, you would just be able to stall them with a single peer.

So, a low severity issue is disclosed two weeks after a fix is made available.
And so, I don't remember when we made the release.  I think we fixed it in 29
or 30.  But just right before this release, I think it was right before 30, in
September or October 2025, went through it again, wrote the advisory, and I
was like, "Wait, writing the advisory, it's higher impact than I expected",
brought it back to the security team and we bumped it to medium severity.  So,
put it back in the tracker, actually not disclose it, wait another year
because then being from low to medium means that instead of disclosing
immediately, you disclose in three release cycles from now.  And each release
cycle is six months, so it's pretty long.  And so, after all this time, it's
finally public.  It was fixed a long time ago.  I think it was, yeah, it was
fixed first in the major version of 30, but a fix was also backported to the
29 series.

**Mark Erhardt**: Right, the PR was merged on June 30.  So, that would have
been for the October release, which would have been v30.  So, the difference
between a low severity and a medium and high severity is two release cycles
later, once the latest version without a fix goes end of life.  So, that's two
cycles after it first gets fixed.

**Mike Schmidt**: Curious about these three.  Are you aware of them being
exploited in the wild?  I guess probably the first one would be the most
obvious one if it had been, but anecdotal reports on the others?

**Antoine Poinsot**: I'm not aware, but all the big miners have upgraded.  So,
I did check with most of them.  All the big miners have upgraded past this
version.  It would also have required creating a reorg.  So, it would need
mining power.  So, it's also pretty likely that once most miners have
upgraded, that someone is not going to expend mining power to try to trigger
it when it's probably not going to reward you anything.

**Mark Erhardt**: Actually, I would disagree with Mike.  The one that is most
likely to be exploited here is the inbound Tor connections whitelisting, which
we also heard was exploited.  Martin used it not as an exploit, but he
discovered it by the exploitative behavior being visible on the mainnet.  So,
in a way, all these nodes basically asked for being exploited the whole time
they had that configuration.

**Antoine Poinsot**: Yes, so that's true that he unintentionally exploited
that behavior, but we also intentionally, once we knew it was a vulnerability,
did not use it to observe what nodes were vulnerable.  We were very curious to
know what's the portion of Bitcoin Core nodes that were vulnerable, because
from the first scan, none of the Core nodes are vulnerable because none of
them disabled the address caching.  But we could have just used another one,
like send a mempool message, and see which ones disconnect us or not.  Those
that don't disconnect us would have been the vulnerable ones.  But we decided
not to do it for obvious reasons at the time, not to come as Bitcoin Core Devs
exploiting a vulnerability in Bitcoin, but also just there is a difference.
And when you stumble upon something, you do normal legitimate experiments and
it turns out something.  And then, once you know the details, you know it's a
vulnerability and it could be exploited to DoS nodes.  To intentionally do
something related is trickier.  So, I wouldn't say Martin exploited this.

**Mark Erhardt**: Yeah, thank you!  No, Martin stumbled upon it.  But it's
much easier to exploit and it was so widespread that I would have said that
this one would have been the easiest to exploit or the most likely.  And
basically, by being exploitable, it became visible in the first place.

**Antoine Poinsot**: Yes, I agree that it would be easier to exploit and most
likely.  I have some stats on my blogpost about the share of nodes that are
still running a version behind Tor that is vulnerable.  I think it's something
like 20% of the network.  13% of reachable peers are still running a version
without the mitigation behind Tor.  So, they might be vulnerable.  You don't
know if they set -whitelist equal to something, but they might be.

**Mark Erhardt**: So, this is Bitcoin Core nodes, because my impression was
that the Knots nodes upgraded much more quickly and drastically?

**Antoine Poinsot**: That's the combination of Bitcoin Core nodes and Knots
nodes, both of them before upgrading to a release that contains the fix.

**Mark Erhardt**: Yeah.  Well, especially among that crowd, 30.0 was not that
popular.

**Antoine Poinsot**: Yes, but even before Bitcoin Core, you could get the fix
without having to update to 30.  It was backported to 29.

**Mark Erhardt**: Right, okay.  All right.  I think we can wrap the security
disclosure discussion.  Do we want to move to testnet5?

_Testnet5 genesis block to be mined_

**Mike Schmidt**: Yeah, that sounds good.  That was a good discussion though.
Thanks, Antoine.  But we're going to keep you around because you have a dotted
line on this next news item, "Testnet5 genesis block to be mined".  We
published on Friday, so the 'to be mined' has actually happened, but let's
recap it.  So, we've talked about this for a while.  The potential upgrade to
a separate network, testnet5 network, to replace testnet4, and some of the
issues that we've discussed over the years with that, we covered that in #409
and #412.  But if you have a new test network, you need a first block, you
need a genesis block for testnet5.  Historically, I think developers just mine
one and publish it, but AJ posted a plan to do it in the open instead so that
there's nobody who gets a head start, even though these things are meant to
have zero value.  People have attributed value to them over the years, which
is another motivating factor to have a new testnet to stop that sort of
behavior, I guess.  And he put he posted, I think it was mid or early last
week, about the plan to use block 975,744, which was expected November 13,
which was Friday, and wanting to use the hash of that block as the commitment
in the genesis block for testnet5 so that there couldn't be any tampering.
This is sort of the Chancellor on the brink of bailouts, but using Bitcoin
blockhashes for that.

Now, the reason to announce that and sort of try to shepherd people into
mining that genesis block was that there's also a change in testnet5's minimum
difficulty, which means that it's about a million times higher than testnet4's
minimum difficulty.  And so, in order to get that block mined, it could
require some ASICs.  So, that's why AJ made the post just sort of like a
callout to people to pool to mine that.  I could pause there, Murch or
Antoine, and we can certainly talk about BIP54 as well?

**Mark Erhardt**: Yeah.  I looked a little bit at the block progression.  So,
when you say November 13, you also have to mention a time zone.  In UTC, the
genesis block was mined at 5.00 in the morning on the 14th.  That is UTC.  And
in 14 hours and a few minutes, the first difficulty period raced by.  And then
actually, the second difficulty period after difficulty increased to 4x, it
went even faster; it took only ten hours.  And so, we're on the third
difficulty period in testnet5 already with a little over 5,200 blocks.  And I
found a block explorer already.  One interesting thing is that one third of
all blocks were mined by P2Pool v2, which is a new project to organize mining
in a decentralized fashion.  This is a sidechain that mines blocks together.
They have their own chain, a shared chain, where they build a blockchain to
contribute work.  And then, everybody puts the transactions that are picked in
the shared chain into their block templates.  And whenever a block is found,
the block directly pays out the P2Pool v2 participants.  So, apparently the
people working on that project thought that testnet5 would be a great way of
testing it, and they got a third of all blocks so far.

**Mike Schmidt**: It should be noted that this mining of the genesis block,
now there's values to actually put in for placeholders that were in BIP95 that
specified the rest of testnet5.  And so, obviously that BIP's updated, but
those same parameters need to actually be put into node software.  And there's
some other things that are in testnet5 as well.  What else could be in there,
Antoine?

**Antoine Poinsot**: Testnet5 enforces BIP54 since the genesis, from the
genesis.  So, all the BIP54 new consensus rules are enforced since genesis.
And testnet5 would be a useful indicator of miners being able to deal with
these new consensus rules in the mining pool software, because by being able
to mine on testnet5, they just may make the information public that the mining
pool can be adapted to set the locktime to the block height, and what have
you, to be compatible with BIP54.

**Mike Schmidt**: Now, BIP54, there is a PR to Bitcoin Core that is open
currently, correct?  So, what are the miners that AJ called to action; how are
they ensuring compatibility with BIP54?

**Antoine Poinsot**: Oh yes, so Bitcoin Core has been BIP54-compatible for
multiple versions, I think since v29 or even v30, if you want to be exactly
accurate.  So, miners running Bitcoin Core as far as 29 should not be worried
about mining a block invalid to BIP54, except for actions that they take on
their side of the stack, which on their side of the stack is the generation of
the coinbase transaction.  And so, that's the part that they need to update to
avoid mining BIP54-incompatible blocks.  And so, that's the part that, if they
just connected the infrastructure without updating it to testnet5, it would
just show up as you're mining invalid blocks, which is great because you want
this to happen on a test network so that they can update without losing any
money.  And then once they do, the whole public gets the signal that they
have.

**Mark Erhardt**: So, concretely in BIP54 we're proposing, or rather Antoine
is proposing, that miners must set the locktime to a block height adjacent
number.  And this will cause all new blocks to be incompatible with previous
blocks that appeared on the chain.  So, there are a few blocks that preceded
the activation of BIP30 and BIP34.  And these blocks could have their coinbase
transactions potentially exploited.  But sorry, I said that incorrectly.  By
setting the locktime in the coinbase transaction, the coinbases must be
different, because none of those old blocks that could be replayed had
locktime set.  And thereby, the BIP54 rule requires all coinbases in the
future to be unique.

**Mike Schmidt**: What happens if someone on this testnet doesn't adhere to
one of the BIP54 rules?  It sounds like, Antoine, you're saying there's
forward-compatibility from versions back in Bitcoin Core, but right now people
are violating that on mainnet, if you will.  So, what happens if it's violated
on testnet5?  Is there some enforcement mechanism of the rules that isn't
present on mainnet?

**Antoine Poinsot**: Yeah, the nodes would refuse the block.  The consensus
rules of BIP54 are always enforced on testnet5.  So, if a miner, who is
forward-compatible by all other rules, still creates a block with a coinbase
transaction that doesn't set the locktime correctly, then when they broadcast
this block, all the other testnet5 nodes on the network will ignore the block
and they would lose the reward, even if on testnet the reward isn't worth
anything.

**Mike Schmidt**: I did have some notes here about updates since the
newsletter, but I think Murch covered that pretty well.  And I think we have a
BIPs PR maybe later in the newsletter.  So, anything else on this item?
Antoine?

**Antoine Poinsot**: I'm checking the stats of the pool of AJ live, and one
petahash just joined the network earlier this morning.  So, there is 1.5
petahash per second currently mining on testnet5.  And if people want to run
testnet5, you can compile the PR by Fabian Jahr to Bitcoin Core.  It's not yet
released in a Bitcoin Core release.  And I think some of the people involved
in the testnet5 effort are going to make binaries available, which will be the
latest Bitcoin Core version, plus the testnet5 patch.  So, anybody can just
run it.

**Mike Schmidt**: Excellent.  Antoine, thanks for joining us today.  We
appreciate your time.

**Antoine Poinsot**: Thanks for having me.  See you.

_Draft BIPs for anti-exfil signing_

**Mike Schmidt**: We're bouncing around the News section still.  We're going
to go to, "Draft BIPs for anti-exfil signing".  Connor wasn't able to join us
to walk us through his idea here, so Murch and I will do our best.  But this
one's related to hardware signing devices and the fact that every signature
needs this random number, called a nonce, and the device picks it.  You maybe
don't know how it's picked, so a device with bad firmware could in theory pick
nonces in a pattern that would leak your seed or other information through
signatures, and those signatures would look totally normal onchain.  So, this
is one method of exfiltration, which is getting the seed off of the device and
out into the public.  There is an idea, and we've talked about this on the
show, even going back to double-digit newsletter days, of anti-exfil signing.
And there's a fix.  And some hardware signing devices have this in place, but
the idea is that have your host, so that could be your computer or your phone,
add its own randomness to that nonce, and then make sure that the device
actually used that randomness so that the device can't covertly leak that
information out to an attacker.

As I mentioned, some manufacturers do this.  I think Jade does this right now.
But Connor posted two draft BIPs to the mailing list to standardize the way
that folks can do this.  And so, there's an initial first draft BIP that
covers the signing itself, and that covers schnorr signatures as well as ECDSA
signatures, and it's a two-round protocol.  The first one that hosts picks the
randomness and then sends only a commitment to it.  And then, in that second
round, the host reveals the actual randomness.  Yeah, Murch?

**Mark Erhardt**: I think the hardware device would also have to commit to its
randomness, because if the hardware device can change its part of the nonce
after receiving from the host, it would still be able to leak information.
So, I think the two rounds are, both sides commit to, say, a hash of the
nonce, and then both sides reveal or use.  Well, the hardware signer uses the
actual nonce after the host reveals it.  And then, the host can double-check
that both of those commitments were used.

**Mike Schmidt**: Yes, and so that two-round process prevents this idea that
if this potentially malicious device saw the host's randomness first, then
what it could do is sort of keep trying nonces until it embedded whatever that
secret information that it wanted in there.  So, that first round of
commitments takes that potential attack away.  So, that is what the first
draft BIP handles.  And then, the second draft BIP handles the ability to have
three different per-input fields in PSBT that actually carry the information
required to do those commitments and exchange that information.

**Mark Erhardt**: Yeah, basically an extension to PSBT to support this through
the PSBT process.  So, PSBT specifies a number of fields that the different
participants can fill out.  And by having fields there for the nonce
commitments and then the nonces presumably, I didn't read it in detail yet,
they would be able to have this with more parties or with hardware devices
that implement PSBTs, in order to communicate with the host device.

**Mike Schmidt**: So, that's the idea from Connor and in some ensuing
discussion, Sjors has actually an experimental draft for one scenario here.  I
think it's a single-signer taproot keypath signing.  And I think there's some
divergence between what Sjors is doing and what Connor is doing here.  So, I
think Sjors plans to align his prototype implementation, or his experimental
implementation, to Connor's spec.  And one other thing that I wanted to pull
out from the write-up and discussion was that the author says that the
cryptography has not been audited, and so he is asking for review.  So, that's
a call to you all, listeners, to see if you can take a look at this.  Yeah,
Murch.

**Mark Erhardt**: And I think Mike mentioned it, but to make it very clear,
this is a protocol that is already in use by several; I think it's Jade and
BitBox that already have support for this.  It just hasn't been specified
fully.  So, this is essentially a BIP that tries to specify a protocol that's
already in use and make it broadly available.

**Mike Schmidt**: Maybe one other asterisk here.  I believe this approach only
covers single-signer only, so things like MuSig or FROST are out of scope for
this.  Obviously, that could be follow-up drafts or BIPs as well to handle
those scenarios.  Okay.  Anything else on that one, Murch or Gustavo?

_Continued discussion of compact block reconstruction stats_

Our last news item this week, "Continued discussion of compact block
reconstruction stats".  When we have this 'continued discussion' prefix in our
news items, it means we've covered this previously.  I think we've covered
this one twice before.  This is a Delving thread from 0xB10C that actually
links off to some other discussions, but the idea is compact block
reconstruction rates over time.  And 0xB10C has his Bitcoin BNOC group that is
a Network Operations Collective, which is essentially a bunch of volunteers
looking at behavior on the network.  And he, of course, is one of those
volunteers.  And he reported in September that his nodes could only build 1%
to 5% of blocks during that time without asking for anything.  So, Murch, I
think he uses this table of contents for the block.  In the best case, you
already have all of the ingredients that go into that.  And worst case is that
you don't and you have to keep asking for more additional information.  0xB10C
noticed that there was this period of time where he didn't seem to have the
ingredients for those blocks in a regular cadence, and he was requesting about
100 KB of transactions per block to fill in the gaps of that table of
contents.

After that, Greg Sanders came in and said that nearly all the transactions
that his node was missing belonged to these chain of rune mints.  We're
starting to get a little bit outside of my knowledge about how these minting
protocols work with these meta protocols on Bitcoin.  But essentially, these
mints or these token mints were reaching mining pools minutes before the rest
of the network, which caused then node operators to see this inability to
reconstruct the block through compact blocks.  I have a bunch of other
information here, but let's let Murch opine.

**Mark Erhardt**: I think there was a second factor here.  So, all those mints
were being sent and someone was trying to minimize the onchain fees to get
those mints mined.  They made long chains and they sent them at 0.1 sat/vB
(satoshis per vbyte), the absolute minimum feerate.  And then, they had these
long chains of transactions linked with P2A (pay-to-anchor) outputs.  P2A
outputs, of course, are ANYONECANSPEND.  So, these chains were trivially
broken by other peers that just spent the P2A output in a different way.  And
apparently, the P2A outputs had a small amount of money, but a big enough
amount of money that if you just created a second transaction that spent all
of that P2A output to fees, it would potentially increase the feerate of, I
assume, a single parent transaction to 4 sat/vB, which then of course would be
a lot more attractive to mine.  But the RBF rules require that you actually
increase the total amount of fees and not just reshuffle them.  So, the P2A
outputs, I assume, were spent down in the later transactions.  They were just
carrying the money to fund the rest of the chain.  And the fees didn't
actually go up by replacing the P2A output with another transaction, it just
made the chain of transactions have less weight.

So, depending on which chain of transactions was seen first, nodes would only
accept one or the other, because they paid the same amount of fees but didn't
properly replace each other.  So, same amount of fees but lower weight, of
course, has a higher feerate, but it doesn't fulfill the absolute more-fee
requirement for an actual replacement, with the transactions being broadcast
without an announcement.  So, usually when you send a transaction, you first
send an inventory message to your peer, "Hey, I have transaction txid.  Do you
want it?"  And the other node replies either, "Not at all", if they have it
already, or, "Get tx".  And for a long time now, because some old nodes had
not adhered to the announcement, we have been accepting transactions just
being broadcast directly at us, which we sometimes talk about getting rid of.
So, whoever was doing those RBF replacements, or actually, I don't remember
who was doing that.  I think the chains themselves were just being broadcast
at peers without announcements.  And assuming they were broadcast to a lot of
nodes, that's how they probably got to the miners so quickly.

**Mike Schmidt**: I read that as well, they announced the broadcasting without
announcement.  What does that do in this scenario?  Is it relevant to how this
played out, or is it also just an interesting thing that happened along with
this minting process?

**Mark Erhardt**: I guess it wouldn't have changed who accepted it for modern
nodes, because giving the announcements and then the peer would have said,
"Hey, I don't have this", they have just got them one by one.  But I think you
would have had to announce them in the right order for that to work properly.
Otherwise, you would sort of create orphan transactions in the other people's
nodes.  So, just playing the whole chain directly would save a bunch of round
trips and might just expedite it.  I'm not firm on that; that's speculating.

**Mike Schmidt**: Okay, so we had this chain of token mints using P2A, and
that would then have another P2A and an OP_RETURN, and then another P2A and
OP_RETURN, and another P2A and an OP_RETURN.  And like you said, it's
ANYONECANSPEND, so other peers would then jump in the middle of that
potentially.

**Mark Erhardt**: "Nice P2A output you have there.  Wouldn't I rather take
that as fees?  Thank you"!

**Mike Schmidt**: And so, that's happening sort of across the network in a
non-deterministic way.  And so, then you get what 0xB10C and Greg saw, which
was poor compact block reconstruction rates, because their node happened to
see XYZ version of this scheme, whereas what ended up being mined was
something different that they weren't aware of, and so they needed to go ask
for that additional transaction data.  Okay, so as all these things do, it
sounds like this behavior stopped on October 8, according to the thread.  And
then, subsequently the compact block reconstruction rates recovered basically
that same day.  I think there was also something from 0xB10C's post.  I don't
think we had it in the newsletter, but he says that the person doing this was
after these uncommon-goods rune mints, and that the sweeping peer used the
user agent p2aburn:1.0.  And so, there was actually an operator on the network
using that as the user agent for their node.

**Mark Erhardt**: So, the interesting thing is, of course, usually a P2A
output is intended to ensure that the parent transaction will get mined,
right?  You add a vestigial output, or actually not vestigial, an output that
will be picked up by yourself in the next transaction where you bring the
actual fees.  But if someone else takes the P2A output and creates a child
that gets confirmed more rapidly than yours, your transaction still gets
confirmed.  However, this is an unorthodox use of P2A, of just making outputs
as small as possible, because P2A outputs only have 8 bytes for the amount,
and then the script portion of the output would take 4 bytes.  So, 12 bytes in
total instead of the usual 43 bytes for a P2TR output.  So, if you're trying
to minimize your blockchain footprint, you might use P2A.  But I assume they
noticed at some point that all their chains were being disrupted, and that was
actually causing more trouble than these minuscule savings at 0.1 sat/vB were
worth.  And I didn't look, but presumably they'd move to outputs that are
actually in some way tied to their own spending, and that way they can control
their chains better.

**Mike Schmidt**: That's probably good on this mess of an item!  It's
interesting that you do have folks monitoring the network for this sort of
thing.  Now, this particular scenario was annoying but not entirely
debilitating to the network, but it's good to have folks monitoring the
network for any sort of activity that may impact the Bitcoin Network,
especially as we're in this crazy AI era where there's a lot of exploitation
going on.  So, kudos to the BNOC team for keeping an eye out for this and
keeping us abreast of it.  That wraps up the News segment.  We can move to
Releases and release candidates.  I'll turn it over to Gustavo for this
portion.

_LDK v0.3-rc4_

**Gustavo Flores Echaiz**: Excellent.  Thank you guys.  So, we have three
releases this week; well, three release items, since a few items package two
releases each.  So, the first one is LDK v0.3.  This is the fourth RC for this
next major version.  We covered the previous RC in Newsletter #426.  This has
a few features, such as RBFs are now possible for splice transactions; and
also, anchor channels are now negotiated by default.  Also, upgrading
invalidates previously issued BOLT11 invoices, since the containment of
payment metadata has changed.  And there's also multiple
backward-compatibility changes, so developers and users are invited to review
the release notes that come with it.  If you want additional details, I think
in Newsletter #426 we did discuss it a bit more.

_LDK v0.2.8 and v0.1.14_

The next one is more important because it's a security release for both the
0.2 and 0.1 branch, specifically v0.2.8 and v0.1.14.  Both of these fix
vulnerabilities that could lead to a loss of funds or a special DoS attack on
the node.  We didn't add them as individual items in the Notable code section,
because they came a bit after the cutoff time.  So, they will be covered in
more detail in next week's section.  But briefly, for example, how could a
node lose funds?  For example, an attacker, a malicious channel peer could
prevent a node from claiming a forwarded payment after a force-close, or by
causing it to sign a channel state that it wasn't properly monitoring.  So,
these are the types of edge cases we've seen so many times already over the
past few weeks across Lightning, and they're not stopping.  So, users are very
invited to upgrade.  Version 0.2.8 also has additional fixes, such as a
potential overpayment vulnerability, specifically in excessive routing fees
when paying static BOLT12 invoices.  And it also has an attack against LSPS2
services that provide just-in-time (JIT) channels.  There's also a
cooperative-close fix that we're going to discuss separately in the Notable
code section that both of these releases have.

_LND v0.21.8-beta and v0.20.8-beta_

Next item comes from the LND repo, so v0.21.8-beta and v0.20.8-beta are new
maintenance releases.  I think just last week, we were covering the latest LND
security releases, and now we have another batch.  Actually, I think we've
done three weeks in a row of new LND security releases.  So, once again, users
are very invited to upgrade since it has multiple vulnerabilities, almost all
of them around AMP invoice recovery, channel funding, restored-channel
force-close, we're going to be covering below in the Notable code section.
But once again, there's just so many different bug fixes included in these
releases, which is why it's so important for users and operators to upgrade to
the latest versions.

_Bitcoin Core #36142_

Now, we move forward with the Notable code section.  The first one comes from
the Bitcoin Core repository, #36142.  So, this is about a fix on command
injection through the Tor control endpoint.  So, the way this works is that
when Bitcoin Core creates its onion service, it sends a message over the
control port called ADD_ONION.  And this asks Tor to generate a key.  And Tor
replies with a private key.  And previously, Bitcoin Core would simply not
validate at all this private key that the control port answered with, right?
It would just fully trust it.  However, the vulnerability is that, for
example, a temporarily compromised Tor control port could return a private key
that included what could potentially be arguments for the ADD_ONION command.
So, because Bitcoin Core writes that key and keeps that key and persists that
key, the problem is that Bitcoin Core, on every later attempt, it will start
by reading the file back and sending it back to the Tor control port, for
example ADD_ONION plus the private key.  But if the private key is encoding or
including or composed by what could be arguments that could be added to
ADD_ONION, that's how the vulnerability gets exploited.

For example, if an attacker fully and permanently controls the control
endpoint, injection gains very little.  But the real value for an attacker is
if the malicious response gets persisted to disk, but for example, the
attacker only had a temporary man-in-the-middle position.  So, he could
temporarily take over the control port, ship a specific private key that
includes some arguments that would later on get always persisted to disk, and
every time Bitcoin Core communicates to the control port, it would play this
private key that potentially included arguments.  So, I looked into it, and
for example, an argument that could have an impact would be setconf.  So, if
you were able to include setconf inside this composed private key, you could
then change the Tor config, for example, add port mappings or exposing
services.  And also, saveconf would make those changes survive restarts.

So, now the fix is for Bitcoin Core to validate the keys before saving or
reusing them to ensure that no key has a control command or argument included
in the key.

_BIPs #2251_

The next three items are from the BIPs repository.  The first one, BIPs #2251,
this is about a new BIP394, which is a draft specific specification for the
rawtr() output script descriptor, which we had previously discussed in
Newsletter #419.  This has been previously implemented in Bitcoin Core since
v24, which precisely was covered in Newsletter #213, so has been included in
v24.  And now, there's now an official specification about this output script
descriptor type, which unlike the tr() output descriptor type, this one takes
the output key directly without applying a tweak.  And the issue with it and
the reason why it's not been recommended is that there's no way to prove that
there's a secret spending path.  So, for example, if someone else gave me this
output script descriptor, I would not be able to prove that this other person
didn't include a secret spending path.

**Mark Erhardt**: Yeah, let me jump in there briefly.  So, we already have a
taproot descriptor and that one will give you the internal key and the hash of
the script tree optionally.  Otherwise, it will use a NUMS point
(nothing-up-my-sleeve).  And so, if someone receives a tr() descriptor, they
have the full view of whether there is a script tree or not, and usually, I
think, if the script tree is provided, it also gives you the entire structure
of the tree.  So, you learn about all the leaves.  What the rawtr() descriptor
allows is to collaborate without revealing the internal structure of the
script tree.  So, you could use this, for example, if you want a watch-only
wallet to be able to scan for your outputs without actually having the
internal tree structure on that box, right?  So, you could use it to import a
watch-only descriptor to your server, or something, and just watch for your
outputs coming in.  Well, I guess you do need to know who you're collaborating
with or use it internally, otherwise it's unsafe, because there could be
scriptpaths where the other party spends by themselves.  Yeah, but it's useful
for privacy reasons.

_BIPs #2347_

**Gustavo Flores Echaiz**: Thank you, Murch.  Great extra context.  Next item,
once again from the BIPs repository, PR #2347 updates BIP95.  So, this is
related to what we were discussing earlier in the episode about testnet5.  So,
these are the specific technical changes required to make the genesis block of
testnet5 easier to mine using pool infrastructure, right?  So, as we said
before, the difficulty of testnet5 is considerably higher, I believe a million
times higher than testnet4, which required some changes to the genesis block
to make it mineable using pool infrastructure.  What are these specific
changes?  For example, the commitment to a recent mainnet blockhash was
initially going to be included in a public-key field in the coinbase output,
but is now moved to a readable text part in the coinbase input script.  So,
that's one of the changes that makes it more compatible with traditional pool
infrastructure.  Additionally, another benefit is that the output now uses an
OP_RETURN, which explicitly marks it as unspendable.  The output was already
unspendable before this changed, but this just makes it very explicit.  Again,
another change for compatibility with pool infrastructure is to allow miners
to vary the block version to expand the available mining search space.

**Mark Erhardt**: Right, so this was all in preparation for the testnet5
launch.  And AJ had contributed these suggestions, I think, a week or two ago.
And actually, it was possible to connect to AJ's mining pool to contribute to
mining the genesis block in advance, and that's why he made some of the
genesis block transaction more like standard coinbase transactions, so it
would be easier to use existing software stacks.

_BIPs #2342_

**Gustavo Flores Echaiz**: Precisely.  The next item, BIPs #2342, this
clarifies BIP34.  And just to give a little background on what this is, this
clarifies BIP34's block height commitment at very low heights, because BIP34
was deployed on mainnet at height 227,931 so it didn't consider very early
heights.  But since BIP34 is also part of now the testnet4, and I think as
well testnet5, of course, it now has updated its specification to describe how
heights 1 to 16 must use the single-byte opcodes OP_1 through OP_16 without a
length prefix.  It also notes that the coinbase input script must still
contain at least 2 bytes, so the height opcode alone is insufficient.

**Mark Erhardt**: Yeah, so BIP34 was introduced to ensure that coinbase
transactions would be unique.  And the method of doing so was to require that
the first thing that had to go into the coinbase field, which is the input
script of coinbase transactions, so coinbase transactions can only have a
single input, and instead of an input script that authorizes someone to spend
a UTXO, it doesn't spend an input.  So, it has a different structure.  And the
coinbase field specifically, it has to have the block height at the start.
And the block height has to be encoded in minimal bytes.  It has to be encoded
as compactly as possible.  However, for the first 16 blocks, that would mean
that it has to use the single-byte opcodes OP_1 through OP_16.  And those
wouldn't be enough to reach the minimum length of the coinbase field.  The
coinbase field has to have at least 2 bytes.  So, in order to fill up the
coinbase field, this clarification requires that there is zero padding
afterwards in order to fill it up to the first 2 bytes.

_Core Lightning #9610_

**Gustavo Flores Echaiz**: Thank you, Murch, that's great.  Now we move on to
the Lightning implementations.  We start with Core Lightning #9610.  So, this
is a fix for a peer-triggered crash caused by an oversized HTLC (Hash Time
Locked Contract) amount.  So, for example, if a peer proposed an HTLC with a
bogus amount of at least 92 million bitcoin, it would set the amount field's
highest bit.  This could cause the value to underflow, and it would get
interpreted as a negative during a signed balance check.  So, of course, it
would pass the balance check because the value would get represented as a
negative value, even though initially it was 92 million bitcoin, so it would
bypass the check for sufficient funds.  However, later on when trying to
construct the commitment transaction, it would trigger an assertion and it
would terminate channeld, which is the channel subprocess, and this would
trigger a crash in Core Lightning (CLN).

So, the fix is simple, CLN simply rejects amounts above the BOLT1 ceiling of
21 million bitcoins, of course expressed in millisatoshis, before even
performing the arithmetic around the balance.

_LDK #5507 and #5532_

The next item comes from two different PRs from the LDK repo, #5507 and #5532.
Both of these are bugs that happen during cooperative-close that could combine
signatures for different transactions.  In the first one, LDK is trying to
negotiate a cooperative-close transaction with a peer, initiates a
transaction, keeps the cache of the signature of the first transaction, but
then the peer proposed a second transaction.  And in there, it would reuse the
cached signature from the first transaction, just because the proposed fee
matched.  Somehow, LDK was simply looking at whether the proposed fee matched
the signature that was cached.  And if it did, it would reuse it and then it
would broadcast the transaction.  And of course, the transaction could never
get confirmed because it had an invalid signature.

In the second case, it requires specifically the LDK node to use an
asynchronous signer, and for that asynchronous signer to be unavailable when
an initial signature is requested.  This means that the fix is implemented for
LDK to clear the pending signing state.  Excuse me, when the async signer
would fit would be unavailable, the peer also has to disconnect.  So, both of
these things need to happen.  And if that was the case, then LDK could
potentially grab the old peer signature.  So, very different from the first
edge case, where it would grab its own signature, so it would grab the old
peer signature and try to combine it with the new local proposal after
reconnection.  And this would result in the same situation, where LDK
broadcasts an invalid closing transaction.  And that leaves the funds stuck
and they require additional recovery.

_LND #11492_

So, then the next five items come from the LND repo.  These are all the
different bugs that I previously discussed in the Release section.  So, I'm
trying to go briefly here, because once again we could get stuck in so many
details that are found here.  The first one is a problem when LND is unable to
find the preimage needed to claim an outstanding HTLC part of an AMP (Atomic
Multipath Payment).  So, previously, LND, when trying to find these preimages,
it was treating them as if they had invoice-level preimages, so if they were
regular invoices, not considering that the AMP HTLC preimages are stored
somewhere else inside LND.  So, that would make it hard for LND to recover
onchain these HTLCs.  It was simply unable to find within its storage system
the preimages required to recover them.  So, the fix is simply for LND to look
in the correct place in order to find these AMP preimages and be able to
recover these HTLCs onchain.

_LND #11479_

The next item, LND #11479, this is specifically when trying to broadcast a
transaction that opens multiple channels.  We know LND has had support for
that for multiple years already.  We covered it in Newsletter #166.  So, when
LND broadcasts that transaction onchain, it could get a sort of error during
broadcast that would make it think broadcast fail, but actually broadcast went
through, for example, a response times out.  LND would previously assume this
meant that the transaction failed to broadcast, but it could have broadcast
either way.  Previously, LND would simply abandon the pending channels and
release their reserve wallet inputs.  So, an LND node could simply construct
other transactions with these inputs, even though the transaction was already
in the mempool of multiple network nodes and was waiting confirmation.  So,
now, LND, even when getting this error type, it will still keep these wallet
inputs reserved, and will monitor the transaction.  If the transaction cannot
confirm, the retained payment channels would require manual cleanup.

_LND #11340 and #11374_

The next item combines two different PR, #11340 and #11374.  So, these cover
the extension of the BOLT12 offers support in LND that we've been covering for
several newsletters already.  Now, there's offer creation and invoice request
handling that has been implemented.  There's even now an RPC command called
CreateOffer, or an lncli command called createoffer, that does creates the
offers.  The first PR adds a handler that validates requests against stored
offers.  The second PR connects the handler to incoming onion messages.  This
feature is obviously only available in development builds, requires multiple
additional configurations, because it's considered extremely experimental.
And something else important to say is that we seem to be nearing the
completion of the receiver side implementation of BOLT12 in LND.  So, let's
say the data model was the first part of it, the receiver side is now almost
completed.  But for it to go live, we still need to go through sender-side
implementation, multi-hop paying offers and RPC parity.

**Mike Schmidt**: One quick note, if people want to follow along with a bunch
of these merged PRs that we've covered historically and the sort of roadmap
for BOLT12, it is #10736 on the repo.  So, check that out if you want to
follow along.

_LND #11480_

**Gustavo Flores Echaiz**: Thank you, Mike, for that extra note.  So, the next
item, #11480, this is a fix when LND would crash when attempting to
force-close a channel restored from a static channel backup.  So, if a user
was attempting to force-close a channel with a static channel backup,
something that you shouldn't really do, because a static channel backup
doesn't usually contain the latest state of a channel, but if somehow a user
was on the force-close path, it would simply trigger a crash in the LND node,
because you're not supposed to be able to do that with a static channel
backup.  So, the fix is now for LND to simply reject the local force-close
attempt, because else it would just trigger a crash of the node.

_LND #11481_

The next and final item, LND #11481, this is actually an interesting one
because it fixes how LND would cache the starting block height for scans that
check whether a transaction has confirmed.  So, if LND wants to monitor a
transaction that has a revoked commitment that was broadcasted by a peer, an
attacker could propose a fake channel funding output with the transaction ID
of the revoked commitment transaction, but with a different output script.
LND would previously cache the scan starting height by txid alone.  So, if the
attacker proposes a transaction with the same txid as the one that LND should
be monitoring for, the one with the revoked commitment, that could confuse LND
into seeing, "Okay, this new transaction that has this txid hasn't been
confirmed.  So, I'm going to start monitoring for it at height, let's say,
900,000".  But what if the revoked commitment one was actually confirmed a few
blocks before?  Then, LND would get confused and it would simply try to
monitor for that revoked commitment starting at a height that is after the
height that it was actually confirmed.  And this could cause LND to simply
delay the detection of the revoked commitment and of course the penalty
transaction and reaction.  This could lead LND to simply be unable to reply to
a revoked commitment and potentially lose funds.

So, now the fix is for LND to not only check for the txid, but of course for
the output script inside the transaction, so that it doesn't get confused
between two different transactions by an attacker.  And that completes the
newsletter.  Thank you.

**Mike Schmidt**: Thanks Gustavo and thanks to Murch for co-hosting.  We want
to thank Antoine for joining us earlier and for you all for listening.  We'll
hear you next week.  Cheers.

{% include references.md %}
