---
title: 'Bitcoin Optech Newsletter #353 Recap Podcast'
permalink: /en/podcast/2025/05/13/
reference: /en/newsletters/2025/05/09/
name: 2025-05-13-recap
slug: 2025-05-13-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Ruben Somsen, Salvatore
Ingala, and Stéphan Vuylsteke to discuss [Newsletter #353]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-4-15/400339013-44100-2-4aa1980b8c295.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome to Bitcoin Optech Newsletter #353 Recap.  Today, we're
going to be talking about BIP30 and a potential consensus failure vulnerability;
we're going to talk about avoiding BIP32 path reuse; we have a Bitcoin Core PR
Review Club around Bitcoin Core's multiprocess project; and we have our regular
Releases and Notable code segments as well.  I'm Mike Schmidt, contributor at
Optech and Executive Director at Brink.  Murch?

**Mark Erhardt**: Hi, I'm Murch, I work at Localhost.

**Mike Schmidt**: Ruben?

**Ruben Somsen**: Hi, I'm Ruben, I'm co-directing 2140.

**Mike Schmidt**: Salvatore?

**Salvatore Ingala**: Hi, I work at Ledger on Bitcoin stuff.

**Mike Schmidt**: Stefan?

**Stéphan Vuylsteke**: Hey, I'm stickies.  I work on Bitcoin Core at Brink.

_BIP30 consensus failure vulnerability_

**Mike Schmidt**: Well, thank you all for joining us for the newsletter this
week.  We have a few interesting topics that we'll kick off here with, "BIP30
consensus failure vulnerability", from the News section.  In Newsletter #346, we
covered the PR to Bitcoin Core that merged the removal of checkpoints in the
code.  We also had on Marco in Podcast #346, where he discussed the PR and the
background around checkpoints.  This week, we're covering, Ruben, your
Bitcoin-Dev mailing list post, where you noticed that while splunking through
old blocks as part of your SwiftSync work, that BIP30 had an unresolved
consensus bug.  Can you walk us through a little bit about what's going on here?

**Ruben Somsen**: Yeah, sure.  So, this is related to the checkpoints, because
the checkpoints sort of allow us to go back and reorg back to a point where this
bug becomes possible.  But I think to explain the bug, I would need to explain
what BIP30 is in the first place.  And with BIP30, essentially, before we had
BIP30, there was a duplicate coinbase output bug, where someone could create a
coinbase transaction, a miner, if they create a block, and then in another
block, they could create the exact same coinbase transaction and that would
create a duplicate transaction ID, because the transaction would be exactly the
same.  And because of this, actually, there have been two instances of duplicate
outputs on the Bitcoin blockchain today.  And BIP30 sought to somewhat resolve
that in a way that wasn't complete nor very neat.  But it did so by basically,
whenever you create an output, it would say like, "Okay, well, let's check the
UTXO set, let's see if that output already exists.  And if it already exists,
then it's not valid".  And so, that was how BIP30 tackled this problem.

BIP30 was activated retroactively.  So, it validates all the way from genesis,
even though it didn't get implemented until 2012.  And the two duplicate outputs
that we have today, they are basically marked as exceptions.  So, that's the
only case where BIP30 says like, "Okay, fine, we know that these exist, so we'll
let them through, but everything else is not allowed".  And BIP30 only is active
until in 2013, BIP34 activates, and there is a little caveat that BIP34 actually
has to activate for BIP30 to deactivate.  And BIP34 basically says, "Hey,
instead of checking whether every output is unique, let's make sure every output
is unique by enforcing that every coinbase transaction needs to have the block
height in it", which ensures that since every block height only occurs once,
this theoretically assures that now every coinbase output is unique, and
subsequently every other output that might spend from it.  So, this actually
isn't a complete fix, and that's why we had the consensus cleanup, but that's a
different story and is not really relevant for this, but I'm just pointing out
BIP34 is not perfect either, but for what we're talking about here, it doesn't
really matter.

So, the specific bug is related to the duplicate outputs that are in the Bitcoin
blockchain.  And essentially, what happens is, I'll just give a theoretical
example with easier block heights.  Let's say a block height 100 of coinbase
outputs is being mined.  Then at block 200, the exact same coinbase transaction,
the exact same output is being mined again.  The way Bitcoin Core handled this
in the past and handles it today is that the first output gets overwritten with
the second output.  And so, there should have been, in theory, two outputs, but
in practice, there is only one output in the UTXO set and this can only get
spent once.  So, so far, this is actually kind of okay in the sense that it's
not ideal, the miner lost some money, but arguably it was their own fault for
creating the same coinbase outputs.  Were it not for the fact that in the case
of a reorg -- so, let's say at block 200, this duplicate output was mined.  Now
let's say there's a reorg back to, let's say, block 100.  Well in a reorg, every
output that got created gets uncreated.  And so, first the output got
overwritten, and now the output that got overwritten gets removed, and so we end
up with zero outputs in the UTXO sets.  Whereas someone who just validated from
genesis until block 100 will have one output in the UTXO sets.

So, there is a consensus discrepancy and if that output then gets spent, which
is also kind of possible, but it's an old output, so it may or may not happen.
But if it's also gets spent, then some part of the network that didn't put this
to reorg, they will say like, "Well, what's this? I don't know this output, so
that's an invalid block", whereas those who did not witness the reorg, they will
see it and they'll be like, "Sure, yeah, that's fine, the output is getting
spent".  And so, that's the consensus bug.  So, as luck may have it, or
depending on how you look at it, this is 2010.  So, in 2010, these duplicates
happened.  So, we need a reorg back to 2010 for this to actually occur; and for
this reason, it's sort of theoretical, right, because in practice this is not
going to happen.  But it is kind of ugly, and it's not nice.  And the other
thing is that we've had checkpoints thus far, but with the removal of the
checkpoints, this is actually when the bug sort of comes into play.

So, one of the things we could do to fix it is we can say, well, considering
we're removing the checkpoints, we could also take that as an opportunity to fix
it right now, because removing the checkpoints is theoretically a hard fork.  In
practice, it's not going to matter, but in theory, adding a checkpoint is a soft
fork, removing a soft fork is a hard fork.  So, that would be one way to fix it.
And the other way to fix it, which we could opt to do later, let's say we go
ahead and the checkpoints get removed, what we could do is we could say, well,
let's not allow a reorg unless the reorg reorgs out both the transactions.  So,
the first at the theoretical block 100, and the second one at block 200.  So,
you say, okay, well, if you're gonna reorg back past the point of block 200, you
have to reorg back all the way to block 99.  And only if you do that, then every
node will be in agreement, because now both a new node that has spun up freshly
on the network, plus someone who witnessed the reorg, both of them, they will
say like, "Okay, well, there's zero of these outputs".  So, that's sort of the
alternative way of fixing it.

**Mark Erhardt**: I caught a mistake.  If they both reorg back to 99 and then
apply block 100, they both have one UTXO.

**Ruben Somsen**: Yes.  So, the consensus rule would be either you have block
100 to 200 in your consensus, or 100 to 200 is not part of the chain, so that
should solve it.  So then, you cannot mine block 100.  201 is fine, but the same
block 100 cannot be mined again.

**Mark Erhardt**: Well, it could be.  You just have to reorg back past 99 and
then you could apply 100 to 150 again, and then you'd still have a synchronous
network again.  You just have to go back far enough to reprocess block 100.
Isn't that what you're saying?

**Ruben Somsen**: Yeah, but it has to be a different block 100.  So, we have the
canonical chain today; do you disagree, Murch?

**Mark Erhardt**: Yes.

**Ruben Somsen**: Okay, well, would you want to work it out?

**Mark Erhardt**: Yeah, sure.  So, we said in block 100 and block 200, the same
transaction gets created twice with the same outputs.  The problem here is, of
course, that creating the same output a second time before the first one is
spent leads to only UTXO in the UTXO set.  So, if we reorg out the UTXO, we are
in trouble.  And the problem is now actually twofold, I think.  First, when you
go past block 200 on the way down, you reorg out the existing UTXO, and there
are zero UTXOs left.  But that only applies to nodes that were past block 200
already, and not to nodes that resync from scratch, that come from the genesis
block, because they would create the UTXO at 100 already.  So, you could fix it
two ways.  One way is, if you reorg below 200, you have to reorg below 100 and
reapply back up to the point that you reorg to.  So, if you reorg to 199, you
would have to reprocess from 100 to 199, and then everybody would be in the same
boat.  The people that come from the genesis block as well as the reorging
parties have recreated the block at 100.

I think there's a different problem here though.  When you reorg past the first
creation of the UTXO, your node will probably crash, because it's trying to
remove a UTXO that doesn't exist.

**Ruben Somsen**: Yeah, that's not the case, that's handled as an exception.

**Mark Erhardt**: Oh, cool, okay.

**Ruben Somsen**: But that's a good observation.  So, I think this doesn't work.
Like, you're right that you're fixing the problem, but you're fixing the problem
in a hard fork way, because there will still be nodes out there that will not
reapply -- you're basically adding the UTXO back in, in a roundabout way.  And
there will be old nodes out there that will not do that, so you're hard-forking
them off the network.

**Mark Erhardt**: Correct, okay.  You're right.

**Ruben Somsen**: Yeah.  And so, that's why I arrived at the conclusion that you
want to reorg back to block 99, and then have a completely different chain from
there.  And so, that allows everybody to stay together.  But I think it's also
just completely reasonable to fix this in a hard fork type of way and just say
like, "Look, this is far in the past.  Similar to removing the checkpoints,
let's just add that UTXO back in when the reorg occurs, and then make sure
everybody has that UTXO in the UTXO sets".  That would also be a way of
resolving this.

**Mark Erhardt**: I mean, if we're looking at this practically, if we have a
reorg of more than 15 years' of blockchain data, people can also just resync
from scratch!

**Ruben Somsen**: Yeah, I think it's still not a soft fork.  You still have that
hard fork problem that I just described, right?

**Mark Erhardt**: Yeah, of course.

**Ruben Somsen**: But yeah, I think this goes sort of into more of philosophical
territory of like, "Well, why are we even validating this old stuff in the first
place?"  And I think, generally speaking, the way I look at that is that I think
with Bitcoin, we strive for decentralization and that includes verifying
everything, allowing for these theoretical, even though never going to happen,
reorgs.  And so, I think part of the philosophy and part of the structure, just
for that reason of trying to aim for an ideal, even though we're never going to
achieve it, like it's not never going to be perfectly decentralized,
unattackable, whatever, I think striving for it is a good goal.  And I think
with that in mind, I think it is perhaps good to fix something like this.  But
practically speaking, it's inconsequential.

**Mike Schmidt**: So, if we reorg back 15 or so years, it's catastrophic
already, but I guess, Ruben, you're pointing out it can be even more
catastrophic?

**Ruben Somsen**: That's right.

**Mike Schmidt**: And it sounds like you're advocating for a fix for more maybe
on principle or philosophy than practicality?

**Ruben Somsen**: I'm not even strongly advocating for anything.  There are two
reasons why I wrote this up now.  It's because we're removing the checkpoints.
So, considering removing the checkpoints is a hard fork, this is the moment we
could fix it in a hard fork kind of way, because we're sort of doing a hard fork
already anyway.  So, that's one reason.  The second is to just write this up,
make sure people are aware that this is a thing, and just put it out there.  I
don't have a very strong opinion on whether or not we should fix this or not,
but I just wanted to put it out there, make sure everybody is aware of it.  And
I guess the second thing, because the second part of my post also just goes
into, "Well, can't we get rid of BIP30 altogether?"  And the reason for that is
that with BIP30, we are checking the UTXO sets up until 2013, up until BIP34
activates.  We're checking with the UTXO set whether an output already exists.
And this is basically double the number of lookups onto the UTXO sets.

Considering this is so far in the past, it doesn't really affect performance all
that much, but it's not a very pretty way of doing things.  And it gets in the
way of alternative implementations such as utreexo, such as SwiftSync, that do
not have direct access to the UTXO sets.  And I think Libbitcoin, I'm not sure
how they handle it.  Well, I think what they do, which is also sort of a
different way of looking at it, but they just basically currently, they have the
checkpoints, I believe, as just saying like, "Okay, well, everything up until
the checkpoint is just valid".  And so, they don't even do the BIP30 check,
because we have the checkpoint anyway.  And again, I don't think it's
unreasonable, but from the philosophical perspective of, "It's nice for
everybody to check everything", I think it would be nice to check that.  And so,
I have a workaround, which basically is, "Hey, let's just check every coinbase
output, check the txid, make sure it's unique, up until the 2013 point".  And if
we do that, it's roughly 7 MB worth of txids, so it's not a lot.  And then, you
can get rid of the UTXO set checks altogether, you could get rid of the BIP30
code even, and you'd have to add other codes, so it's not a net win in terms of
the code.  But again, this is one of those things where I think philosophically,
it's nice, it's possible, maybe we want to do it someday.

For SwiftSync, we've got to do it anyway already, if we do want to do these
checks, or something along these lines.  So, that's sort of the second part of
the post.

**Mike Schmidt**: Murch, anything else on this item?  You're good?  Ruben,
thanks for jumping on and talking us through this edge case.  It's interesting.

**Ruben Somsen**: Yeah, no problem.

**Mike Schmidt**: We appreciate your time.  You're free to drop if you have
other things to do.

**Ruben Somsen**: Yeah, I'm pretty busy, so I'm dropping out.  See you guys.

_Add bitcoin wrapper executable_

**Mike Schmidt**: See you.  We're going to jump to the PR Review Club segment,
and so we're going to skip the second news item briefly here and jump to the PR
Review Club on, "Add bitcoin wrapper executable".  This PR introduces a new
Bitcoin binary, so not bitcoind, not bitcoin-cli, but Bitcoin binary, which can
be used to discover and launch various Bitcoin Core binaries.  The PR is part of
the process separation or multiprocess project.  Stéphan, you are involved with
the PR Review Club.  I know you didn't host this one, but I know you were
involved.  How would you summarize multiprocess and this PR for our listeners?

**Stéphan Vuylsteke**: Yeah, so I guess to start with, the purpose of this PR,
and then I'll dive deeper into multiprocess and IPC as we go along.  I'm going
to keep it fairly high level.  But basically, the issue is that with the
multiprocess project, we're going to be adding a few more binaries to the
already sizable list of binaries that we ship.  So, how do you fix having too
many executables?  You add, of course, one more executable to fix the problem,
or as in one executable to rule them all.  So, diving a bit more into what that
all means, multiprocess is probably the longest running project that we have in
Bitcoin Core.  It started, I believe, in 2015.  And the initial goal there, and
it's changed a bit over the years, but the initial goal there was to enable
breaking up the monolithic Bitcoin Core process into multiple processes that
could talk to each other, with some stated goals being increased security by
isolating different processes, but also, for example, allowing different kinds
of scalability, allowing you to run different processes on different machines.
Maybe you want to run your bitcoind on a beefy server, and then you can run GUI
on your local machine, or any kind of other configuration.  And you can even
swap different processes out for each other, so you can even customize things a
bit more.

But more recently, multiprocess has really gotten a new breath of air with the
mining interface.  So, Stratum v2 has become quite a prominent project also in
recent years.  And Stratum v2 required some updates to the getblocktemplate RPC
that seemed to be quite difficult to accommodate well within the Bitcoin Core
RPC interface, without loading lots of code into Bitcoin Core codebase, which is
not ideal.  So, then the proposal was made to build this interface over IPC, so
basically using multiprocess.  What is IPC?  IPC is inter-process communication,
which is basically the concept that multiprocess used to allow these different
processes to talk to each other.  So, if you have the Bitcoin node process, the
Bitcoin wallet process and the Bitcoin GUI process, they all talk to each other
through IPC.  And specifically, for multiprocess, we use the Cap'n Proto
protocol, which is an existing protocol that focuses specifically on this kind
of communication.  And then, multiprocess is basically a wrapper around Cap'n
Proto.  So, maybe to reduce confusion, multiprocess means both the project of
separating Bitcoin Core into multiple processes at runtime, as well as the name
of the library that wraps Cap'n Proto to do this kind of communication
technically.

So, yeah, the mining interface has taken the forefront in recent multiprocess
efforts, which is also why in the upcoming release, we're going to start adding
multiprocess binaries as part of the release process.  What does that mean?  Let
me start with what it doesn't mean.  It doesn't mean that we're going to have
binaries that effectively do split up Bitcoin Core into, for example, the GUI,
the wallet, and the node process.  At the moment, the multiprocess and the
monolithic binaries are the exact same thing, with the only difference that the
multiprocess binaries allow communication over a unique socket, so that other
processes, such as, for example, a Stratum v2 sidecar, can talk to the Bitcoin
Core process.  And let me have a quick break here before I go into the purposes
of the PR that we covered in the Review Club.  Does that make sense?  Should I
dive deeper into any of these components?  I'm getting a thumbs up, so I'll
carry on.

Right, so if we're going to be adding two more binaries, namely bitcoin-node and
bitcoin-gui, which are multiprocess binaries, some reviewers have raised some
fears that this might get very confusing for users as to them figuring out which
binary you should be using for their purpose, especially as we will be adding
more of these binaries in the future.  So, then this PR tries to fix that by
basically adding this new top-level wrapper binary called Bitcoin, which accepts
subcommands as well as arguments and is going to figure out, based on the
arguments, which of these binaries it should launch.  So, for example, if you
use this new binary and you say bitcoin-gui, then this wrapper knows that it has
to launch bitcoin-qt or bitcoin-gui, based on the parameters that you've parsed.
So, if you parse, like, -multiprocess, then this can launch the multiprocess
binary.  If you don't, you can launch the monolithic binary.

So, this is a fairly simple thing.  This wrapper does not do any Bitcoin
validation logic or PTP on your node.  It just really takes commands and
arguments, finds the binaries, executes them, and adds some gel to make it
easier for the user so they can more easily find which commands are available.
In the future, this can even be extended by adding, like, Fuzzy Search.  If you
do a typo, or if you type in, "bitcoin-gi", instead of, "bitcoin-gui", then it
can tell you that these things are fixed.  So, it makes that much more user
friendly, but also it offers the benefits for the Bitcoin Core project that we
can keep the interface stable, even when we reorganize which binaries we ship,
or how they're named, and so forth, because we have this wrapper that is the
actual interface that can do the translation and that can keep things constant
for the user.  So, it gives us a bit of flexibility and freedom as well, which
is a nice benefit.

**Mike Schmidt**: In the example of the GUI, I would type, "bitcoin gui", and
then the Bitcoin binary would do what to figure out if it's going to launch
bitcoin-qt or the multiprocess bitcoin-gui?

**Stéphan Vuylsteke**: It just inspects if you've passed a -m argument to the
Bitcoin binary.  So, that's the simple way to toggle between both options.

**Mike Schmidt**: Okay, so it's all command-line-option-based, there isn't
something like in a config file somewhere where I say, "Hey, I always want to
use the multiprocess, or I always want to use the monolith"?

**Stéphan Vuylsteke**: I believe that was suggested as an option for future
improvements, but I don't think that's the case at the moment, no.

**Mike Schmidt**: Excellent.  Well, we did highlight five interesting questions
for those who want to dive deeper into this particular Review Club.  Those
summaries are up on the newsletter write-up, but I would also advocate folks go
to the PR Review Club and you can review the whole meeting and its dialogue
there.  But also, I found that the write-ups before the meeting are
super-informative.  So, if this is something that you're curious about or
worried about, or whatnot, you can check that out now.  Stickies, anything else
you think people should be aware of on multiprocess and this Bitcoin executable?

**Stéphan Vuylsteke**: I mean, give it a try, it's fairly easy if you're used to
compiling Bitcoin Core.  You can check out the PR and try and compile it
yourself.  It's pretty easy.  See if it works for you, if the interface is
useful, then that'd be useful feedback.

**Mike Schmidt**: And this will be in version 30?

**Stéphan Vuylsteke**: I don't think it's tagged for version 30, so I guess it
depends on the user feedback.  But if it is merged before branch-off, then yes,
it should be in 30.

**Mike Schmidt**: Okay, cool.

**Mark Erhardt**: Sorry, you probably said it and I missed it, but when this
ships and if it is in the 30 release, how does this change what users need to
do, if they already have scripts set up that call bitcoind in the background, or
whatever else?  Would it change anything, or is it just new people that write
their new command-line arguments with bitcoin instead of bitcoind?  For them,
it's going to be stable going forth?  What's the practical implication?

**Stéphan Vuylsteke**: Yeah, sorry, I forgot to mention that, so thanks for
raising it.  So, at the moment, there are no plans or roadmaps to deprecate the
current binaries.  So, maybe at some point in the future, bitcoind will not be a
command you can execute anymore.  But for now, this is purely additional.  So,
you can run Bitcoin as base node, or you can run bitcoind.  Both are possible.
So, nothing should change for existing users.  This is all kind of add-on extra
for people that want to use the binary.

**Mike Schmidt**: You mentioned mining as the motivation.  Maybe one more
question.  In the write-up, we have the bitcoind and the GUI separated, but is
there work on this mining piece or is the mining piece something separate that
talks to Bitcoin, the daemon?

**Stéphan Vuylsteke**: Yes, there's a couple of components there, right?  So,
Bitcoin Core has interfaces and the mining IPC interface is one of those
interfaces.  So, external applications or processes can, through IPC, use the
mining interface to talk to Bitcoin Core.  So, a client can implement the mining
interface and then use IPC to basically communicate with Bitcoin Core to get
block templates or do something like that.  So, these new multiprocess binaries
have an extra startup option called -ipcbind, which allows these external
processes to bind to them over a unique socket.  So, they can actually
communicate with, for example, the mining interface.  I believe at the moment,
the mining interface is the only IPC interface that is exposed through -ipcbind,
I need to double-check, but I'm fairly sure that's the only one that people can
use.

**Mike Schmidt**: So, I can flag that I want to open up communications via IPC.
Are there binaries that Bitcoin Core will be shipping at any time soon that will
take advantage of that, or is that just up to mining folks to develop their own
for that interface?

**Stéphan Vuylsteke**: I'm not aware of any binaries that we plan to ship that
use that soon.  So, at the moment, it would just be third-party sidecars like
the Stratum v2 template provider that could use something like that.  This is
short term.  In longer term, anything is possible, but we're trying to not do
everything at the same time.

**Mike Schmidt**: All right.  Well, I know we have a time constraint on your
side here.  So, Stéphan, thank you for joining us and representing this Review
Club this week.

**Stéphan Vuylsteke**: You're very welcome.  If folks are interested, we have a
kernel Review Club tomorrow on separating the UTXOs from certain validation
functions.  So, if that interests you, then feel free to join the
bitcoincore.reviews.

**Mike Schmidt**: And for folks that don't know, in addition to his work as a
Bitcoin Core engineer, in addition to coming on podcasts like this, he also
helps run the Review Club, and he also does the write-ups for the Bitcoin Core
Review Club for Optech each month.  So, thank you, Stefan.

**Stéphan Vuylsteke**: You're very welcome.

_Avoiding BIP32 path reuse_

**Mike Schmidt**: Cheers.  Jumping back to the News section, second news item,
"Avoiding BIP32 path reuse".  Kevin from Liana posted to the Delving Bitcoin
forum a post titled, "Avoiding xpub+derivation reuse across wallets in a
UX-friendly manner".  He and the Liana team are working on a feature for
multi-wallet support in Liana and he said he was not happy with any of the
common ways to avoid xpub reuse.  Kevin couldn't join us today to represent his
idea, but Salvatore, who's familiar with the topic and also participated in the
discussion on Delving, is here to help us understand the issue, the current
solutions, and any new solutions that are being discussed.

**Salvatore Ingala**: Hello, and I hope I do a good job in representing Kevin's
positions and ideas, because they work on software wallets, I don't.  I work
more on the infrastructure that they use, but not directly on the software
wallets themselves.  And so, the problem that he posted was about how to avoid
xpub reuse.  So, the xpubs are basically the keys that are used when you set up
a wallet, whether it's single-signature, multisignature, or more complicated
stuff like the miniscript wallets.  And so, for each of the cosigners, normally
you would provide one xpub; and so, if you have three cosigners, you will have
one xpub for each cosigner.  And so, the way we derive xpubs from one seed was
originally settled with BIP32, so that we have one seed that can be used to
derive all the possible public keys and private keys that you need for all your
possible transactions that you want to be involved with the same seed.  And so,
there are some other standards that evolved over time to kind of define how you
would derive keys for specific use cases.

That worked well until people were basically doing just single-signature stuff.
And basically, all the type of wallets were uniform, the script was the same,
the only thing that changes is the xpub.  And so, by just defining how you
derive the keys, which is what BIP32 calls the derivation path, that allows to
kind of know from the seed how you derive the keys that you need.  So, all you
care about was this derivation path.  But since Bitcoin evolved over time, and
now we move to descriptors, descriptors allowed to kind of define many possible
kinds of wallets.  So, basically, now the derivation paths is no longer enough.
And so, we discussed other occasions that if you should use anything more
convenient than single-signatures, basically you have to have a backup of the
entire descriptor that describes not just all the involved xpubs, but also what
is the script exactly, so what are the spending conditions of this wallet.

The problem still comes that, well, when you create a new wallet account with a
wallet like Liana or Sparrow, or any wallet that's multisignature, you have to
decide what xpubs you use in this wallet.  And functionally, any xpub is as good
as any other xpub because they all come from the same seed, so you would be able
to sign.  But there is a problem where if you reuse the same xpub for multiple
wallet accounts, maybe different wallets with different sets of people, even if
it works, it's still bad to reuse the same xpub, because the same xpub means
that the keys that you derive from this xpub will be the same.  And so, in many
situations, these keys will end up onchain, and this allows an attacker to
potentially link different outputs that belong to the same entity, the same
person, even if they are in different wallet accounts formally, by just
observing the blockchain; they just see that there is the same public key in
different wallets.  And so, they would notice that somehow the same entity, the
same person is involved in these two different transactions.  And so, that's at
least bad for privacy, and so we want to avoid that.

Of course, wallets have been aware of this problem for a long time.  But
normally, the way to solve this problem is to either ask the user which account
you want to derive the xpub from.  Maybe they have part of the derivation path
fixed, but then the account index.  So, for example, in BIP44, which was
probably the first to introduce this kind of account derivation, the first three
steps of the derivation path are called 'the purpose', which is kind of
identifying what kind of wallet you're using.  The coin type, which was used to
kind of distinguish if you use the same schemes for Bitcoin or for Ethereum, for
other currency, for cryptocurrency and everything, at least you can partition
keys that you use for different cryptocurrencies.  And then the account index,
which is the third derivation step.  And so, by using a different account index,
you're sure that you use different public keys.  And so, if you make a wallet,
like when you are setting up a new wallet account in a wallet, you can ask the
user, "Okay, what account do you want to use?"  And if the user is careful, they
can be sure that they don't use the same account index.  But of course, this is
something that for people who are not experts, it's hard to understand what is
the account index, why do I have to choose an account index?  And you know,
people who are experts, information gets lost, you might have used this account
index years ago and you don't remember.  So, it's something that's not great for
UX and there is a risk of making mistakes.

So, Kevin proposed what are different approaches to solve this problem with a
better UX, like if we don't want to ask the user what are things that we could
do.  And so, one idea would be that we can keep track of all the public keys
that we used in the past, all the xpubs that we used in the past, we have some
storage somewhere.  But of course, this works in theory, but then in practice,
how do you synchronize this, because you might set up a wallet account with
Liana and another wallet account with Sparrow, so there is no standard of
networks for the wallets.  Also, where do you store this information?  That's
also not a trivial question.  And so, in general, if there are solutions that
don't require state, they are easier to manage.

So, among the solutions that are stateless, Kevin was proposing different
solutions that are either to use completely random paths.  So, anytime you
create a new account, you add a couple of the derivation steps that, say, are
completely random.  And so, as long as the number of bits that's used for the
randomness is large enough, the chance that there is a collision is very low.
Probably even just a single derivation step would be enough, but maybe to be
sure, you can use two derivation steps, and that would solve the problem.
Another solution could be that you use not random, but kind of deterministic
paths.  And the solution that he was suggesting was to use time as deterministic
information.  So, instead of using randomness, you use the time to kind of seed
your information.  Murch has a question.

**Mark Erhardt**: If you were to use randomness, wouldn't that mean that you
need a new backup every time you create another multisig wallet, even though you
might already know all of the involved public keys and they are reused across
many wallets?  Every time you introduce a new random number, you need a new
backup, right, so that seems like a big step?

**Salvatore Ingala**: Yeah, but I would say for multisignature, you do need a
new backup for a new account you create anyway.

**Mark Erhardt**: Okay.

**Salvatore Ingala**: Because when creating your account, you're not going to
reuse the several points of discussion, you don't want to reuse the xpubs of the
other people either.  So, everybody will provide a new xpub.  And so, you have a
whole new set of xpubs that you have to store as part of the descriptor.  So,
the fact that you need to backup the descriptor is kind of an assumption at this
point when you use descriptor-based wallets.  And so, those are basically the
two solutions, because the other solution was to actually store state either in
the hardware wallet or in the software wallets, and synchronize them.  We
discussed why that's a bit difficult.  So, maybe I'll pause a moment to see.
Hopefully, I summarized all the points Kevin made in his initial post.

**Mike Schmidt**: Yeah, that was great, super-informative, and thanks for
walking us through that, Salvatore.  Yeah, so I mean, just to reiterate for the
audience, the primitives are there to provide this functionality.  It's just,
how do we do this in a user-friendly manner while not having some sort of
centralized coordinator who says, "Okay, now use this derivation path because
you used this one already", which I think is the third option.  Okay, so how has
the discussion gone?

**Salvatore Ingala**: Yeah, so there was some discussion, so I raised two
concerns that are actually both relatively minor concerns.  So, it was more to
be sure that the discussion is aware of these points.  So, one is that in the
examples that Kevin made, he was using entirely random derivation paths, so no
longer using at all the structure that comes from BIP44 or similar BIPs.  And I
suggested that actually, using at least the purpose and coin type defined in
that BIP still has a value, because partitioning different key hierarchies based
on the purpose, but especially the coin type for people who have multiple
cryptocurrencies, can still be relevant.  And some other wallets in particular,
I know that Ledger does it, you can put restrictions for different applications
that are for different cryptocurrencies, so that they cannot derive keys that
are not for that coin type.  So, this allows to put different access levels to
different parts of the hierarchy, so that the Ethereum app will not be able to
access the keys of the Bitcoin app, and vice versa.  So, it will still be useful
to have at least those in the hierarchy because anyway, they are fixed numbers,
they are very small numbers, so it doesn't add much friction.

The other point I made is that it would be nice to try to avoid as much as
possible to introduce randomness or entropy, because randomness is something
that introduces more information content in this backup.  And the problem with
this is that this information content is not something that you are just storing
in a file.  But for security, you also have to verify this information on the
device screen.  So, you want to put as little information as possible there,
because if you put more information, people are more likely to not check the
information there.  So, if you put a lot of randomness, for example, if you use
like three, four completely random derivation steps, each derivation step is 32
bits of random, it's quite a big random number.  And if you're not checking, if
you forget checking this number, an attacker that maybe puts malware on your
computer, the way they could steal money from you would be with a ransom attack,
where basically they trick you into registering a wallet for which you don't
actually know the derivation path, by just actually deleting the real random
numbers.  So, if you don't check with your backup when you register the wallet
on the device, you might be using one of your xpubs, but it's in a place that
you don't know how to derive.  And now, the attacker is the only person that
knows where the actual xpubs were derived from.  So, if you have a lot of
randomness, you will not even be able to brute force where these keys came from.
And so, this kind of creates a UX issue where the registration step, which is a
security-critical moment, becomes a little bit worse in terms of UX.

So, among the solutions that Kevin proposed, for example, I think the one based
on the date is a lot better, because the date in the example he used would be
encoded up to the second.  And so, the chance that you would produce two
different xpubs in the same second is probably zero.  And so, you are guaranteed
that you will never reuse an xpub.  And the entropy of comparing a date on the
device screen, I would say it's less than comparing a random number.  So, in
terms of information content, comparing two numbers that look like a date, it's
a lot easier than comparing two random numbers.  So, that's my favorite approach
among the two.  And I also tried to suggest that actually, there are good points
of trying to figure out how to keep state synchronized, because there are many
potential benefits.  But I do understand that it's a much harder approach.  I
mentioned that because there are other benefits for software wallets to have a
place where they can store information.  For example, if you label coins that
you used in the past, this label is something that you will likely not lose.
And there are potentially other things, like other metadata associated to both
your wallets and your transactions, would be nice to have a standardized place
of storing it.  And this is a small amount of data, but you would likely not
lose it.  So, I think software wallet struct should actually try to solve this
problem, because it would solve many things.  And in this context specifically,
it would allow to use just a very small number for the derivation path, because
you actually keep track of all the xpubs that you use.

**Mike Schmidt**: So, it sounds like you're leaning a bit towards the date as
the unique piece?

**Salvatore Ingala**: Yeah, I think if you want a good state, that seems the
most reasonable to me.  It solves the problem in a quite nice way and doesn't
make the UX much worse in terms of registration.

**Mike Schmidt**: Murch, do you have any thoughts?  Murch is good.  Salvatore,
you have folks listening that are maybe building libraries, building software,
what's the call to action here?  Should they just jump in on this Delving
thread, or do you have something else?

**Salvatore Ingala**: Yeah, like I will say, especially for people who are
thinking about Bitcoin as a product, that's a very interesting product question,
how to solve this problem, because it affects all the software wallets,
basically.  So, solving it in the best possible way in terms of UX matters.  It
makes everybody's experience slightly better.  So, if you have ideas, definitely
respond on the post or contact Kevin and let him know what are your ideas.

**Mike Schmidt**: Great.  Salvatore, thanks for hanging on with us to cover this
news item.  You're welcome to stay on, or we understand if you have things to do
and need to drop.

**Mark Erhardt**: I was wondering actually, Salvatore, whether you had thoughts
on one of our last items here, the BIPs #1835 change to BIP48, which is about
derivation paths for multisig wallets?  So, I figured we could maybe pull that
up if you want to stick around for that one, or if you're going to stick around
anyway, we could pick your brain on that later.

**Salvatore Ingala**: Yeah, I can stick around so meanwhile I have time to read
it.

**Mark Erhardt**: Okay.

_LND 0.19.0-beta.rc4_

**Mike Schmidt**: All right, perfect.  Thanks for hanging on Salvatore.  Okay,
moving to the Releases and release candidates section, we have good old trusty
LND 0.19.0, this time beta.rc4.  I'm going to continue to point back to Murch's
Recap in #349 of our podcast, where he did a good job of digging into this.

_Core Lightning #8227_

Notable code and documentation changes, Core Lightning #8227 is a PR that
implements BLIP50.  And BLIP50 was originally the Lightning Service Provider
(LSP) spec LSPS0 that specified how communication should work between a
Lightning Wallet and its LSP.  And we actually discussed that BLIP, which at
that time was an LSPS spec, back in Newsletter and Podcast #251, and we had the
author of that specification, Severin Bühler, on.  We noted in the newsletter
this week that the PR implementing this communication protocol, which is the
LSPS0, is related to and other specs can build upon, which this is BLIP51, which
specifies LN liquidity requests on top of LSPS0.  And that's also BLIP52, which
is just-in-time (JIT) channels, which was LSPS2.  And both of those BLIPs were
also covered in Podcast #251 when they were specified in the LSPS repository.

So, you have these three LSPS specs, one defining the communication between the
Lightning Wallet and its LSP.  That is being implemented here in Core Lightning
(CLN) in anticipation of building these future LSP specs on top.

_Core Lightning #8162_

Core Lightning #8162 is a PR titled, "Handle closed channels better".  CLN won't
forget still opening channels after 2,016 blocks, which is what it did
previously, unless there are more than 100 of them.  So, it's sort of retaining
knowledge of pending open channels beyond what it did before, but with a limit
of 100.  Part of the motivation for this PR, I'll quote, "Michael of Boltz told
me this long ago, that when fees spiked, some of their clients' opens got stuck.
After two weeks, their node forgot them, and when fees came back down, the opens
still failed".  So, there was a little bit of the motivation there.  CLN now
replies with channel_reestablish even on long-closed channels, and keeps closed
channels in memory, noting they're small, and this will allow us to efficiently
respond to re-establish them".

_Core Lightning #8166_

Core Lightning #8166 is a PR titled, "Listhtlcs pagination".  This PR actually
does a couple of different things.  One is the pagination that I'll get to.  But
the first thing in this PR is improve CLN's wait API by replacing what was
returned previously, which was just a generic details object, with something
that is more distinct.  There are objects for invoice, forward, and sendpay
types now, so you're not dealing with a generic interface, and I think it's gRPC
compliant as well.  In addition to that change, CLN also has this listhtlcs rpc
command that gets all of the HTLCs (Hash Time Locked Channels).  Previously,
that RPC returned all the results with that command, which is still the case now
by default, I believe, but the RPC also has options to specify the maximum
number of entries that are returned.  So, instead of getting 2,000 entries in
response to listhtlcs, you could chunk it and get the first 100, then the next
100, then the next 100, which is the pagination piece.

_Core Lightning #8237_

Core Lightning #8237 adds an option to the listpeerchannels RPC for CLN to
search for a specific channel based on the channel's short channel identifier.
You could do something like that previously, but it was more cumbersome, so they
added this ability to parse this short_channel_id to just pull it right out of
the list of your channels.

**Mark Erhardt**: With this whole set of CLN updates, are we about to see a CLN
release?

**Mike Schmidt**: I suspect yes, that has been the case in the past.

**Mark Erhardt**: Carry on!

_LDK #3700_

**Mike Schmidt**: LDK #3700 adds failure_reason to LDK's HTLCHandlingFailed
events to provide additional information about why the HTLC failed.  Seems
pretty straightforward.  I don't remember if it was LDK in the last few weeks,
we've had similar things where routing and other error type information is being
more granularly given back to users, the API.

_Rust Bitcoin #4387_

Which leads also to Rust Bitcoin #4387, which similar to the last PR, this PR
for Rust Bitcoin adds more granularity to Rust Bitcoin's handling of errors, by
adding more detailed error types beyond the previous generic error type that was
used previously.  I think specifically, this was in the context of BIP32.

_BIPs #1835_

BIPs #1835.  Salvatore, hopefully we stalled long enough with all these LN PRs
to see if you have a perspective on this.  Murch, I know you're BIPs editor, and
you may have some thoughts as well.  But Salvatore, did you have a few minutes
to look at it?

**Salvatore Ingala**: Yeah.  So, BIP48 was basically kind of extending the
approach of BIP44 for multisig.  And basically, what it does is that it does a
fourth hardened derivation step.  So, we mentioned the first three are purpose,
coin type, and account.  And so, this adds a fourth derivation step, which is
also half-dumped, which is the script type.  And so, the BIP defined some script
types for the type of multisig that was used at the time the BIP was made.  So,
native segwit, nested segwit, and, wait, I'm missing one, because I think I
don't see legacy in the BIP.  But anyway, so basically, different types of
multisig, it doesn't really matter for this discussion.  It defines a different
script type as a derivation step as a standard way.  And so, this PR was about
updating it, because now there is also taproot multisig.  And so, it adds a new
script type, number three, for taproot multisig.

So, formally, also yes, it makes sense to update the PR.  At the same time, I
would update the BIP.  At the same time, I will say that the entire BIP is
probably a bit obsolete by now, because now that there are descriptor-based
wallets, the assumption, as we discussed before, is that you do need a backup
for the descriptor wallet, for the descriptor.  Also, because this seems to be
written with the idea in mind that you will not need the backup, which is anyway
false, even in the context of multisignature, because if you lose the xpub of
one of your cosigners, then you're still not able to sign transactions, even if
you have the other public keys.  So, this is something that we discussed other
times.  So, this could only help you insert things where you control the keys
and you're only using multisig for redundancy.  Then probably, a BIP like this
will help.  But one of the valid reasons people use multisignature is that
different entities control different xpubs.  So, I think it's actually a sane
assumption to write software wallets that make sure that the user will not lose
the descriptor.  That's actually the safest approach.  Like, it's more footgun
prone to assume that there is value in being able to recover then without having
a descriptor, rather than teaching all the time that instead, you have to have
the backup for the descriptor.  So, that's my point of view on this.

**Mike Schmidt**: Murch, you have any thoughts?

**Mark Erhardt**: Well, just I did also take a look at the BIP just now, and it
does look like it's only wrapped segwit, native segwit, v0, multisig, and now
P2T.  So really, only these three types, and it didn't even define legacy.  I
think BIP48 is fairly young, it only came out in 2020, so I guess legacy was
sufficiently in the past at that point that it wasn't even defined.

**Salvatore Ingala**: And another point is that actually, the script type, it
only says taproot, but taproot what, is it multisig?  Where? Is it a
sortedmulti?  I think there is multi-a and certain multi-a, I think.  I don't
know if both are defined as a descriptor.  There is also a MuSig, potentially.
So, you might have different approaches for multisignatures.  So, still, this is
not necessarily enough information to even know the script type.

**Mark Erhardt**: That's a very good point.  And maybe the BIP editor should
have watched out a little more to notice that!  If you want, I think it just got
merged a few days ago, so your comment would probably still be appreciated.

**Salvatore Ingala**: Yeah, also I'm a bit skeptical on the whole BIP at this
point, I think!  But yeah, that reminds me that actually, maybe at this point,
since this was changed to have the third script type as part of the BIP, so
Ledger devices allow to have the third script type as part of the BIP.  But you
would have to ask confirmation to the user, while for the script types that were
already defined, you can do it silently.  So, for uniformity, maybe I can
remember to update this for the next release of the app.

_BIPs #1800_

**Mike Schmidt**: BIPs #1800 merges BIP54, which specifies the consensus cleanup
soft fork proposal.  Most recently on this show, we covered the same BIP, but
when it was in draft form, and that was in Newsletter and Podcast #348, and that
was with the BIP's author.  We also have a consensus cleanup soft fork page on
the Optech Topic wiki.  It can point any listeners to other discussions we've
had on it over time, as well as related PRs and mailing list posts.  So, take a
look there.  Murch, I don't know if you want to add anything to that?

**Mark Erhardt**: No.  I mean, as usual, the BIP is merged now.  It's in draft
status, which means that the author feels that the recommendation is complete
enough that it can be permanently presented to the community, but it's not moved
yet to proposed, in the sense that it's recommended for activation.  So, if you
have thoughts on any part of that BIP, we're still in the comment period, so to
speak, on this proposal.  I assume that it will be moved to proposed in the
coming, I don't know, weeks, months, and eventually maybe there will be a
proposal on how to activate it as well.

_BOLTs #1245_

**Mike Schmidt**: Last PR this week to the BOLTs repository, BOLTs #1245, which
is a change to the LN spec's BOLT11 invoice protocol.  So, during some fuzz
testing, some engineers found that there were some unnecessary leading zeros in
some BOLT11 fields, and that caused issues for LDK when they were parsing and
then reserializing an invoice, that would actually cause the invoice hashes to
change.  So, this change to the spec fixes that potential issue by requiring the
minimal data length possible, which then would standardize the serialization and
deserialization for LDK, but it's probably a good idea regardless.  The PR notes
that this doesn't appear to have been occurring in regular practice or in the
wild, but, "Because this hasn't happened and it breaks a straightforward way to
handle BOLT11 parsing, there's no reason to retain it.  So instead here, we
simply forbid non-minimally-encoded features in BOLT11 invoices".

Well, that's it for this week.

{% include references.md %}
