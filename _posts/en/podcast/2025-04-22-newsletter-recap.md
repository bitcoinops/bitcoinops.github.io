---
title: 'Bitcoin Optech Newsletter #350 Recap Podcast'
permalink: /en/podcast/2025/04/22/
reference: /en/newsletters/2025/04/18/
name: 2025-04-22-recap
slug: 2025-04-22-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Niklas Gögge to discuss [Newsletter
#350]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-3-22/398828677-44100-2-4a0419294433e.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #350 Recap.
Today, we have nine interesting updates to Bitcoin ecosystem softwares,
including a fuzz testing tool for Bitcoin implementations; we're going to cover
the Bitcoin Core 29.0 release; and we have our regular Notable code segment as
well.  I'm Mike Schmidt, Contributor at Optech and Executive Director at Brink,
funding Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch.  I also volunteer at Optech and I'm a
Co-founder and contributor at Localhost.  Now, we have our own Bitcoin
contributor hub in the Bay Area.

**Mike Schmidt**: Amazing.  Niklas?

**Niklas Gögge**: Yeah, hi, I'm Niklas, I work on Bitcoin Core at Brink, and
mostly do security engineering things like fuzzing.

_Fuzz testing tool for Bitcoin nodes_

**Mike Schmidt**: Well, Niklas, thanks for joining us this week.  We did not
have any news items that we highlighted in the newsletter.  So, we're going to
move right to the Changes to clients and services software segment this month.
Murch, I'm going to go a little bit out of order in deference to Niklas's time.
So, we'll do the, "Fuzz testing tool for Bitcoin nodes".  Fuzzamoto is a
framework for using fuzz testing to find bugs in different Bitcoin protocol
implementations, through external interfaces like P2P and RPC.  Niklas, you're
the author of this tool.  Maybe you can talk a little bit about the motivation
for the tool and we can get into what it does and what it can do.

**Niklas Gögge**: Right.  So, one of the motivations for this tool was that the
most common type of fuzz test that we currently have in Bitcoin Core usually
tests like an isolated class or an isolated function on its own, and obviously
that requires that those components are isolated otherwise you can't test them
in isolation.  But historically, Bitcoin Core has various parts of the codebase
that aren't very modular.  So, before you can really fuzz test stuff, you'll
have to refactor first.  So, part of the motivation for this tool was to do fuzz
testing without having to do refactoring work prior.  And I was somewhat
inspired by the functional tests that we have already, which basically spin up a
whole bitcoind instance and then test it through the RPC interface or the P2P
port, basically any public interface on bitcoind.

So, for this new tool, Fuzzamoto, I decided to do the same approach.  So, for a
test, I'll actually run a bitcoind and then fuzz through the P2P port or the RPC
interfaces.  And the way to make that deterministic so that no state accumulates
within the Bitcoin Core instance that you're testing, it's using something
called snapshot fuzzing, where basically the test runs within a VM that has the
ability to snapshot itself and then also reset quickly to that snapshot.  So,
when I run a test case, it'll do all the things that the test does.  And then,
at the end of the iteration, I'll reset the VM to the initial state so that the
fuzzing is deterministic.  And yeah, I'm heavily leaning on a tool here called
Nix, which already implements all the snapshot fuzzing stuff, so I'm basically
just using that tool to achieve this.

**Mike Schmidt**: Am I right in assuming that there's some overhead in this
orchestration process, compared to how fuzzing would normally go?

**Niklas Gögge**: Yeah.  So, compared to the regular in-process fuzzing that we
do, this is significantly slower.  But still, well, in my early testing, it
still seems fast enough to be practical, especially if we just add a bunch of
CPU.  It does seem like this can be a practical way of writing tests.  And then,
once we have these kind of tests, hopefully it'll reduce the risk of the
refactoring and putting the lower-level tests in place.  So, this is not meant
to replace the isolated tests, because with the isolated tests, you can probably
make stronger assertions on internal state than you can if you test from all the
way outside.  But if you have those higher-level tests in place, those give us
more assurances on doing the refactoring, putting the lower-level tests in
place.

**Mike Schmidt**: So, if you could wave a magic wand, everything would not be
done using Fuzzamoto.  You would modularize the code and componentize it so that
it could be tested in process fuzzing.  But because there's challenges in
refactoring the code, both in terms of effort and then risks that something, I
guess, could go wrong during the refactor, you've come up with Fuzzamoto as a
way to sort of fuzz test things that are not currently easily fuzz tested.  Do I
have that right?

**Niklas Gögge**: Well, I don't have any data on this.  But I think the sort of
integration style test that Fuzzamoto would be would still make sense, even if
we had the more isolated tests.  And I mean, this is pretty much the same as
having unit tests and integration tests.  You want to have both, because there
could be bugs that only arise from the integration of the different components.
So, if you have isolated tests for an individual function, maybe you won't catch
the bug that only happens if you use that function with a bunch of other
components.  So, I think the answer would be you probably still want to have
both in any case.

**Mike Schmidt**: Okay, so Fuzzamoto, because I know there's the functional
tests, which are sort of like integration-ish tests, you would still use
Fuzzamoto, even in the presence of having those functional end-to-end tests?

**Niklas Gögge**: Yeah, I think, well, what they add on top of the existing
functional tests is that just like any fuzz test, they basically remove bias
from the test that you write.  So, you might find edge case bugs that you
otherwise don't find.

**Mike Schmidt**: Makes sense.  We mentioned in the write-up, well, what we
mentioned and didn't mention in the write-up is that this is not a Bitcoin Core
specific tool, or at least the end state of this tool is not Bitcoin Core
specific.  Can you talk about how other implementations might be able to use
this?

**Niklas Gögge**: Yeah, so I've created a few abstractions that basically would
allow to harness currently any full node software.  So, something like btcd or a
Libbitcoin-based node, you could also harness with this and then test those in
the same way that you would test Bitcoin Core.  The general approach of this
would technically work for any type of software that has an internet port open,
but I'm trying to keep it scoped to, for now, Bitcoin 4 nodes software; and in
the future, I think it would also be fun and make sense to include LN
implementations.

**Mike Schmidt**: And if somebody wrote the appropriate architecture for this to
go against btcd or Libbitcoin, I guess they could run that independently and
surface any bugs, just like you're doing here with Bitcoin Core.  But is there a
way to sort of compare, like would you run the same test at the same time
against the different implementations and be able to see divergences in output?
Would that be something you could do with this tool, or is that in scope?

**Niklas Gögge**: Yeah.  So, you could do both.  You could just run each
implementation individually and just fuzz for crashes, for example.  But yeah,
this isn't currently implemented, but a future version of this will make it
possible to test, let's say, bitcoind and btcd against each other.  So, you can
look for consensus bugs, or just differences in behavior on the P2P layer, for
example, which is also something that might be really nice for Bitcoin Core just
on its own to make sure that we're not changing behavior unintended.  So, maybe
we change something in the P2P stuff that we weren't intending to change; and
then, if we had a test that basically compares the behavior of master to an
older version, we could maybe catch those breaking changes as well, which for
something like consensus bugs would be very nice to have.

**Mike Schmidt**: Murch, do you have any questions or comments?

**Mark Erhardt**: Well, I was going to jump in on the, "Isn't this for multiple
implementations?" but you've already covered the differential fuzzing.  And
yeah, being able to compare an old version of Bitcoin Core with a new version of
Bitcoin Core via the differential fuzzing to see that they behave the same way
still, I hadn't considered that, but that's pretty useful too.

**Mike Schmidt**: Niklas, if we have listeners that are technically adept and
want to play around, what would you recommend them to do, other than going to
the repository?  Are we talking about giant servers or a farm they would need,
or can they just run it locally and play with it on their own machine?  How
might that work?

**Niklas Gögge**: Well, all you need is an x86 machine, yeah x86 architecture.
That should pretty much be it.  It doesn't need to be anything crazy to run it.
Yeah, and I have steps in the readme which should explain how to get it running,
but if anyone is having trouble, you can also ping me.

**Mike Schmidt**: And what sort of components are covered and not covered?  And
are you looking for folks to contribute other, I guess, I don't know if the
words 'component' or 'integrations', like have you have you tested all of the
RPCs or all of the P2P interfaces, or is that some percentage done and you're
looking for contributions?

**Niklas Gögge**: Yeah, I mean, it's definitely not all done.  Currently, I have
what I have one test for, for example, the compact block protocol.  But there
are other things in the P2P layer that I currently have not written tests for
and am writing tests at the moment.  Yeah, I mean, if someone is interested in
contributing and you have experience with Rust or Bitcoin Core or fuzzing,
that'd be very much appreciated.  Feel free to reach out.  There's also a few
open issues for stuff that I have planned to implement.

**Mike Schmidt**: Awesome.  Niklas, thanks for walking us through this today.
And we appreciate your time and understand if you have other things to do, you
can drop.

**Niklas Gögge**: Thanks for having me.

_Bitcoin Knots version 28.1.knots20250305 released_

**Mike Schmidt**: Okay, we're going to go back in order here now.  And we
covered Bitcoin Knots version 28.1.  I thought there was a notable piece in this
release that included support for signing messages, including for segwit or
taproot addresses, and also adding verification for Electrum-signed messages.
And there of course are other changes in Knots, but I thought those were the
most notable ones for our audience.  Murch, what's your take on why it's been so
long to get something like BIP322 or signing messages for segwit and taproot
addresses into Core or more widely adopted?

**Mark Erhardt**: There's a lot of pushback on whether signing messages is a
good idea, because when it came out or in the context of regulators taking a
second look at Bitcoin, some regulators stated, "Well, for your tax report,
you'll have to prove to us all the bitcoins that you hold and you have to sign
messages with each address.  Or for withdrawing money, you have to sign a
message for us that this is your address", and things like that.  So, my
understanding is that there were quite a few people concerned that it's being
used for that and maybe then it shouldn't be available at all.  I'm on the fence
here, because on the one hand it's very useful to build other stuff like audit
tools or tools that show that services have liquidity, although it's obviously
hard to prove that they're actually not under the water or anything, because it
would be easy to hide other obligations.  But yeah, so it's a tool that provides
capabilities that are useful for proving stuff to other network participants,
but it's then also used by regulators and oversight institutions to get more
information on users.

**Mike Schmidt**: That makes sense.  A bit of a double-edged sword.  So, you at
least understand the cons of that argument.  Thanks, Murch.

_PSBTv2 explorer announced_

PSBTv2 explorer announced.  So, I think there's been a PSBTv1 or is it, I guess,
version 0, I don't remember, explorer previously, which is a web interface that
you can plop in a PSBT and it'll parse everything out for you in a web
interface, so you can see what's in there.  So, now we have a PSBTv2 explorer
using a v2 PSBT data format.

**Mark Erhardt**: Yeah, I clicked around in that a little bit.  That looked
really cool, but I didn't try it in detail.

_LNbits v1.0.0 released_

**Mike Schmidt**: I want to say that it was the Unchained Capital folks that put
out that piece as open source, so maybe something that they were using
internally that they put out to the community.  LNbits v1.0.0.  I think many
folks have probably heard of LNbits over the years.  I don't recall if we've
covered them in Optech previously, and I thought that this 1.0.0 release was a
good opportunity to do so.  LNbits is a software that can plug in with a variety
of LN wallets and can provide some accounting and other services on top of those
wallets that you've plugged in.  So, if you're using a bunch of different LN
wallets and you want to have some unified functionality across some of those,
check out LNbits.

_The Mempool Open Source Project® v3.2.0 released_

Mempool Open Source Project v3.2.0 released.  This release adds support for a
bunch of cool Optech-y stuff, like v3 transactions, anchor outputs, the
broadcasting of 1p1c (one-parent-one-child) packages, and also has the ability
to visualize Stratum mining pool jobs.  And there's also a bunch of other
goodies in there.  So, check that out.  I thought that was worth surfacing.

**Mark Erhardt**: Yeah, I thought that the UTXO bubble chart is pretty cool when
you look at an address with multiple UTXOs.  It also very clearly surfaces
people that shouldn't be reusing addresses.  And I also thought that it was
pretty cool that there is a warning for address poisoning attacks now.  And I
saw that there was support for v3 transactions, anchor outputs, and apparently
also the ability to package broadcast.  And I didn't look into how that works,
but I assume through the API that you can just push a transaction, just like old
block explorers used to have a submit_transaction API, or even web interface.
And I expect that you can push two transactions together there now in some
manner.

**Mike Schmidt**: And I'm not sure how far the open-source project release is
behind the mempool.space version of it.  But if it's something that you're
interested in running yourself, this is a lot of good, interesting goodies.  So,
if you're if you are already running mempool locally, consider upgrading to get
these additional features.

**Mark Erhardt**: Yeah, the website seems to be running 3.3-dev already, so
they're a little ahead of the curve.

_Coinbase MPC library released_

**Mike Schmidt**: Coinbase MPC library released.  So, Coinbase open-sourced
their C++ library for securing keys for use in multiparty computation, (MPC)
schemes, and they also, and I thought this was a little bit of a, "Hmm?" they
had a custom secp256k1 implementation that is part of that.  So, I think a lot
of the exchanges or custodians use MPC versus something like multisig, because
you can use MPC with a bunch of different altcoin chains; whereas multisig might
not be possible on all of those other chains.  So, they've chosen MPC as their
security mechanism.  And so, Coinbase has open-sourced a library.  I don't know
if that means they're using it or not, but they've open-sourced the C++ library
for their MPC implementation.  Murch, are you a little bit suspect of secp
implementation being part of that?

**Mark Erhardt**: Yeah, my understanding is that Coinbase has been using
single-sig basically for, well, at least since segwit activation.  They rolled
out native segwit v1 single-sig addresses, P2WPKH at that time, and they were
based on MPC already.  So, I assume this is an implementation of that scheme.
I'm not wary of a libsecp implementation.  I would hope that Coinbase has
sufficient funds to employ cryptographers that know how to do that.

**Mike Schmidt**: Murch, why is MPC not a popular solution for Bitcoin-only type
wallets or custodians?  What's the downside?  I mean, Coinbase is using it, some
of the other custodians are using things like this.  Give us the other side of
that.

**Mark Erhardt**: My understanding was that MPC was very new cryptography when
it came out in this use case early on, and people were a little worried that
there would be security issues or vulnerabilities discovered.  Now, I think it's
been out for seven, eight years and I haven't heard major failures.  For ECDSA,
it's somewhat complicated to implement.  Two-party is pretty straightforward,
three-party gets complicated and above that, I think it's more or less
unimplemented.  This is way easier with the schnorr signatures, which is why we
now have -- MuSig is a form of MPC basically.  So, with schnorr signatures this
is going to be more widespread; but for ECDSA signatures, this is pretty
complicated, and I think people wanted to stay away from that because the
onchain multisig is much, much simpler technically, much easier to implement.
It does cost more blockspace, of course.  MPC looks like single-sig on the other
hand, so the advantage is you can pay less for your blockspace, or require less
blockspace for it to achieve equivalent results.

So, for example, Ethereum doesn't have a native multisig and MPC basically just
plugs in a single-sig replacement, that is actually under-the-hood constructed
by multiple parties.  So, it works across the board for many different
cryptocurrencies and you only need one stack to operate everything.

_Lightning Network liquidity tool released_

**Mike Schmidt**: Lightning Network liquidity tool released.  The liquidity tool
we mentioned here is Hydrus, and it takes a look at the state of the LN, and it
also factors in past performance of different channels and nodes to
automatically open and close LN channels for your LN node.  And currently out of
the box, it supports LND.  I believe that they have plans to support other LN
implementations in the future.  And so, Hydrus will essentially look around the
network, figure out when to open and close LN channels based on liquidity, and
it also uses batching for those channel opens and maybe channel closes as well,
but it supports batch.

**Mark Erhardt**: That sounds like a great tool right now, especially with the
low feerates, especially if it's feerate-sensitive and does it when 1 sat/vB
(satoshi per vbyte) transactions are going through.

_Versioned Storage Service announced_

**Mike Schmidt**: Versioned Storage Service announced.  Versioned Storage
Service, abbreviated as VSS, is a framework for open-source cloud storage for LN
wallet data as well as Bitcoin wallet data.  And the focus here is non-custodial
wallets.  There's obviously a need to be backing up LN state and information, as
well as Bitcoin wallet information.  And so, this is a cloud storage solution
that does that in an easy-to-use way.  I don't have the details on how they do
that in the cloud in a privacy-preserving or encrypted way, but Murch, did you
get a chance to look at this one?

**Mark Erhardt**: I did not, no.  I don't have anything to add.

**Mike Schmidt**: Okay.  Well, maybe as a note of affiliation here, this was
posted on the Lightning Dev Kit (LDK) blog.  So, this isn't just a scheme out of
nowhere to collect your backup data in some capacity, so check out that blogpost
for the details.

_Bitcoin Control Board components open-sourced_

If you're following along in order, we already talked about Fuzzamoto, which is
the fuzz testing tool for Bitcoin nodes, previously.  So, we'll move to the last
item this week, which is, "Bitcoin Control Board components open-sourced".  This
was actually called, "The Braiins Control Board", and now they're renaming or
rebranding that to, "The Bitcoin Control Board".  And as part of that, I think
they're working with the 256 Foundation to get some of this appropriately
open-sourced.  And they're open-sourcing various components of the hardware and
software of their BCB100 mining control board.  I wanted to note that not
everything is open source; the control board is open source, but the Braiins'
custom mining firmware is not open-sourced.  So, not everything, but it's always
good to see more of the mining industry open-sourcing components.

**Mark Erhardt**: Yeah, that might be a nice synergy with projects like Bitaxe
that are working on other custom home-built boards and mining hardware.  I'm not
plugged into that community too much, but I was wondering whether that would be
able to be combined with the Bitaxe stuff maybe.

_Bitcoin Core 29.0_

**Mike Schmidt**: I do not know the answer to that that, but maybe someone can
reply in the Twitter thread or on Nostr to us on this.  Releases and release
candidates.  Murch, Bitcoin core 29.0.  I know at the time of the podcast
recording last week, it was officially released, and you guys had mentioned it
on the podcast last week.  I did have a list of items that I thought were
notable that I'll run through here, if that's okay.  Okay, Bitcoin Core 29.0
dropped support for UPnP using libnatpmp, and that was replaced with a custom
implementation of PCP and NAT-PMP.  As a reminder, UPnP lets devices on a local
network automatically open ports on the router, which is the purpose.  The old
UPnP libraries were sources of vulnerabilities, and we've discussed one or more
of those on this show previously as a CVE.  And we also covered the PR to add
the custom implementation, and that was Bitcoin Core #30043, and we talked about
that in Newsletter and Podcast #323.

The next item that I wanted to highlight from the release was improvements to
orphan-handling.  And the Bitcoin Core node will now try to download missing
parents of child transactions that are orphans from any peer that announced the
orphan transaction, not just the first peer that announced that orphan
transaction.  And we covered this PR in more depth in the PR Review Club titled,
"Track and use all potential peers for orphan resolution", and that discussion
was in Newsletter #333.  And we actually had Gloria, the PR's author, on in
Podcast #333.  So, I'm using this release as an opportunity to point to a lot of
those previous discussions for folks that are curious about the details.

29.0 also adds a new policy for ephemeral dust, which allows zero-fee
transactions with a dust output to appear in the mempool, as long as they are
simultaneously spent in a transaction package.  So, Murch is going to correct
me.

**Mark Erhardt**: No, I'll just add something.  Very important, they are only
permitted on zero-fee transactions.

**Mike Schmidt**: That's right.

**Mark Erhardt**: So, maybe I missed you saying it, but the idea here is of
course we don't want people to put ephemeral anchors into the UTXO set unless
they will be spent.  And one way of almost guaranteeing that they will be spent
is by adding the ephemeral anchor, or permitting the ephemeral anchor only if
there's only a single one, and it is on a zero-fee transaction, so the fees have
to be brought by the child transaction.

**Mike Schmidt**: So, the end effect of this policy is that no dust will
actually be added to the UTXO set, which is a positive.  And the benefits of
ephemeral dust include helping protocols like Lightning, Ark, timeout-trees,
BitVM 2.0.  And so, I think those projects, at least from what I can tell, are
excited about this change.  If you're curious about the details around ephemeral
dust, we did a PR Review Club in Newsletter #328, and we had on Greg Sanders,
who is the author of the PR, on Podcast #328 to explain the details.

**Mark Erhardt**: Yeah and this works especially well with P2A (pay-to-anchor)
and in combination with the TRUC (Topologically Restricted Until Confirmation)
transactions.  So, the idea is to use all three together.

**Mike Schmidt**: Bitcoin Core 29.0 also included a change to mining.  So, due
to a bug in the default block reserved weight for the block header, transaction
count, and coinbase transaction, it was accidentally reserved that space twice.
So, 29.0 fixes that double reservation and frees up a bit more space by default
for miners to include other transactions.  We had Abubakar, who was the author
of this PR, on in Podcast #336 to explain his work, and that was under the news
item, "Investigating mining pool behavior before fixing a Bitcoin Core bug".
So, for the details of the motivation there, listen to Abubakar explain.

There were also changes around RPCs, including testmempoolaccept, submitblock,
getmininginfo, getblock, getblockheader, getblockchaininfo, getchainstates, and
get blocktemplate.  So, if any of those RPCs sound familiar to you, check out
the release notes for what's been updated there.  Murch?

**Mark Erhardt**: Yeah, so a bunch of these mining RPCs provide more information
now.  And if you're building block templates, there's new stuff.  So, I think
especially miners will want to look at the release notes carefully, both with
the 1,000 vBytes that are additionally available for block templates and with
the RPCs.

**Mike Schmidt**: There's also a new RPC for getdescriptoractivity that we
covered in the show.  I don't have the reference there, but that essentially is
an RPC to find all of the activity for a given set of descriptors.  Under
settings, with 29.0, -mempoolfullrbf is now on by default.  So, full RBF is now
the default behavior without the need for signaling.  Murch?

**Mike Schmidt**: I want to say that that was already the case for 28.0 and what
29.0 changed was that full-RBF setting was removed.  It was not just on by
default, but the setting is removed now, because it has been so widely adopted
by the network, it doesn't make sense to turn it off.

**Mike Schmidt**: I see.  Oh, you're right, I misread the release notes.  It
does, "Starting with 28.0", it was set.  Okay, yeah, I thought the same thing,
but then I just missed that in the release notes.  Okay, strike that.  With
29.0, the Bitcoin Core build system has been migrated from Autotools to CMake.
Users who download the binaries won't even be aware of the build system change,
but under the hood there was a ton of work by hhebasto and other members of the
Core team to make the switch to CMake for doing builds.  There was a mailing
list post from Cory Fields, I think last year, that noted, "Maintaining
Autotools is a huge burden and it's only getting worse over time as it's
virtually unmaintained".  And he goes on to say also, "CMake is a perfectly
reasonable choice for a modern, free and open-source build system with
substantial momentum".  We had hhebasto on in Podcast #316 to discuss the news
item, "Bitcoin Core switch to CMake build system".  So, hhebasto gets into some
of the details and hard work that happened there, in #316.

**Mark Erhardt**: Yeah, and maybe to just summarize a couple of the benefits,
one thing is that it's much easier to cross compile to different architectures,
and so CMake is just much more widely supported now.  And we get, what is it
called, out-of-tree builds?  I'm probably saying this wrong, but it's very easy
to just have multiple configurations of Bitcoin Core built in parallel.  So, for
example, I have been setting up the fuzzing for the QA assets in the past few
days.  And where I used to need two copies of Bitcoin to build one fuzzer with
sanitizers and one fuzzer without sanitizers, I can now just have those two
configurations in two different build folders where I build to.  It's just nicer
for developers, and I'm very happy that the developers put in all this effort to
update us to this much better system.

**Mike Schmidt**: There were some items that I didn't pull out of the release
notes, but these were ones that I thought were interesting to me anyways.
Murch, did you have anything else to add on this release item?

**Mark Erhardt**: Yeah, I had one more.  I thought it was notable that there was
a fix for a port collision regarding onion listening nodes.  So, if your node is
listening on the Tor Network, you were able to set the regular port, the
clearnet port, and the onion port was always the same.  And that meant if you
wanted to run multiple full nodes on one system or on one IP, you would have the
problem that the onion nodes would clash.  And now that was changed.  If you set
the dashboard startup option, the onion port will be that port plus one instead
of always 8334.

**Mike Schmidt**: And that PR that Murch just mentioned about the port
collisions, that was from Newsletter #335, and the PR is #31223.

_LND 0.19.0-beta.rc2_

LND 0.19.0-beta.rc2.  Murch, you did a great recap of this RC last week.  So,
folks, check that out.  I don't think I could do that justice.  So, refer back
to Podcast #349 for that.

_LDK #3593_

Notable code and documentation changes.  LDK #3593 is a PR titled, "Implement a
way to do BOLT12 Proof of Payment".  So, in BOLT12 offers, when a payment is
made, the person making the payment can receive cryptographic proof that the
payment was completed.  This is called a proof of payment.  They can show the
proof of payment after the payment without relying on the recipient to prove
that that payment was made.  So, it's sort of like a receipt, but it's a receipt
that can't be faked.  Before this PR, you could do proof of payment in LDK, but
it was a bit more cumbersome.  So, this PR adds the BOLT12 invoice to LDK's
payment send event when the payment is completed, making it a little bit easier
for you to do this proof of payment.  And then, a third party can verify that
payment was made by showing the invoice and confirming that the payment hash
matches the hash of the payment preimage.

_BOLTs #1242_

BOLTs #1242.  This is a change to the LN spec that makes the payment secret
field mandatory in BOLT11 invoices, and then marks that feature as ASSUMED in
the spec.  The PR is related to the BOLT4 part of the spec around LN routing
onion specifications.  Maybe to note what payment secrets are, there are extra
pieces of data that are added to the BOLT11 invoices that senders include in
their BOLT4 onion payments, that allow the person receiving to only accept a
payment from the intended sender, which helps prevent probing attacks against
the receiving node when using multipath payments.  Maybe to piggyback on that
last explanation, the PR noted, "This change improves protocol privacy by
ensuring that all Lightning invoices contain a payment secret.  The payment
secret prevents intermediate nodes in the payment path from probing for the
destination by generating their own payment onions"

Something else that I saw from the discussion that was interesting, was that
originally the payment_secret field was optional in some cases, in order to
maintain backward compatibility at the time that it was initially rolled out.
But now, after several years of wide adoption, the payment secret is required
everywhere, and this feature has become standard across the LN and should be
considered a core part of the protocol, rather than an optional feature.  That
wraps up the Notable code segment.

_Correction_

We did have a little correction from last week's newsletter, specifically around
SwiftSync.  And we noted three categories of error in that SwiftSync write-up in
this correction.  Murch, you had on Ruben and Sebastian last week, and maybe you
want to walk through a summary of that?

**Mark Erhardt**: Yeah, we had the author and the implementer of this proposal,
or a prototype of this proposal, on last week.  And I was lucky enough to hear
about the correction being written before we recorded.  So, actually, we already
were using the correct terminology and explaining it right in last week's recap.
But in the newsletter, we called the structure to which we add and from which we
deduct the UTXOs, while we're processing the blockchain without building the
UTXO set, a cryptographic accumulator, but it is not a cryptographic
accumulator.  It is an aggregator.  And I'm sure some people might know what
that means, or where exactly the difference lies in those two things.

Anyway, there were also a couple of other minor issues that were parallel block
validation does not require assumevalid.  So, if you're not building the UTXO
set, but you only know which UTXOs to keep because you need them at the end,
obviously you can process blocks in any order and process transactions in any
order, because you only keep the UTXOs that are supposed to be in the UTXO set
afterwards anyway.  And the aggregator will allow you to deduct before you can
add and still get the same result.  So, you can do parallel block validation.
And it was also stated that SwiftSync is able to validate blocks for similar
reasons as utreexo, but that is not the case.  Do you have it in your head?  I
don't.

**Mike Schmidt**: We can point to the third bullet in the correction and also to
last week's discussion.

**Mark Erhardt**: Yeah.  Anyway, yes, I think I basically explained why parallel
validation is possible with SwiftSync.  You don't actually store all the UTXOs
and you don't have to consume UTXOs in order to process the inputs of later
transactions, so you can deduct and add transactions.  But I think you would
need to know the amounts of the inputs, because the input amount is one of the
things that goes into the aggregator.  So, you might need extra data to process
blocks in parallel, because the input amounts would otherwise only be available
for the UTXOs that are being consumed.  And I don't, from the top of my head,
remember how utreexo is different.  So, please refer to our write-up.

**Mike Schmidt**: And if you're listening to this Podcast #350 without having
listened to #349 and none of that made any sense, we did just put out #349 to
your favorite podcast catcher.  So, check that out.  You can hear Ruben and Dave
and Murch and Sebastian talking about SwiftSync, which was the topic of
correction for this week.  Thank you to Niklas for joining us as a special guest
this week, and thank you, Murch, as my co-host for co-hosting this week and
covering for me last week.  We'll hear you next week.

**Mark Erhardt**: Thanks for your time.

{% include references.md %}
