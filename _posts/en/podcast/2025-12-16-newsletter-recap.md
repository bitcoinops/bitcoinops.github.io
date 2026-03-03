---
title: 'Bitcoin Optech Newsletter #384 Recap Podcast'
permalink: /en/podcast/2025/12/16/
reference: /en/newsletters/2025/12/12/
name: 2025-12-16-recap
slug: 2025-12-16-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Matt Morehouse and Salvatore Ingala to discuss [Newsletter #384]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2025-11-16/414515373-44100-2-49085ec881e6d.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Optech Recap #384.  Today, we're going to
talk about a series of vulnerabilities in LND that were fixed in 0.19.0; we're
going to have a talk about a virtualized secure enclave for hardware signing
devices; and because this is our last regular newsletter for the year, we
actually have both our Changes to client and service software segment as well as
our monthly segment on Q&A from the Bitcoin Stack Exchange this week as well.
Murch, Gustavo and I are joined by two guests this week.  Matt, you want to
introduce yourself, Matt Morehouse?

**Matt Morehouse**: Hey folks, I'm Matt, and I work on the Lightning Network.

**Mike Schmidt**: Salvatore.

**Salvatore Ingala**: Yeah, I'm Salvatore, I work at Ledger on mostly Bitcoin
features.

_Critical vulnerabilities fixed in LND 0.19.0_

**Mike Schmidt**: Thank you both for joining us.  We're going to jump into the
news section.  We'll go in order this week, starting with the first news item,
"Critical vulnerabilities fixed in LND 0.19.0.  Matt, you posted to Delving
Bitcoin about critical vulnerabilities fixed in LND 0.19.0, including a DoS
vulnerability and two potential theft-of-fund issues.  Maybe before we go one by
one, the headline for LND node operators is, "Upgrade to LND 0.19.0 or later".
Now, Matt, you want to walk us through these three vulnerabilities?

**Matt Morehouse**: Sure.  So, the first one, the DoS one, I called this, "The
Infinite Inbox DoS", because the vulnerability is pretty easy to understand.
Basically, there's these large internal queues that LND would maintain for each
peer that connected to them, and they had no limit on the number of peers that
they would allow.  So, an attacker could just create a whole bunch of
connections, send large messages, and fill up these queues.  And within a few
minutes, LND would run out of memory.  So, that's the entire attack, and the fix
was very simple.  They just reduced queue sizes and put a limit in place of how
many peers they would allow to connect at a time.

Now, the other two vulnerabilities are theft-of-funds vulnerabilities, which I
would consider a lot more serious.  So, definitely upgrade to at least 0.19.
You may as well go beyond that, because there's minor releases on the 0.19
branch that have other bug fixes.  And there's also the 0.20 release that just
came out a few weeks ago.  The first theft-of-funds vulnerability I called, "The
Excessive Failback Variant Bug".  This is basically the same vulnerability that
I disclosed in March of this year.  Basically, an attacker could trick LND into
refunding an HTLC (Hash Time Locked Contract) that was already claimed
downstream.  And so, this would be very unsafe and LND would end up losing the
value of that HTLC.  Now the original attack involves the attacker force closing
the channel and then crashing the LND node somehow to get them to restart.  But
there's this new variant that I discovered shortly after disclosure of the
original one, where instead of the attacker force closing the channel, if the
victim force closes the channel, then the attack can still be carried out.

So, I discovered this after the disclosure of the original bug.  I went to
update the LN specification to call out this bug and try to prevent future bugs
like it from happening in the future.  And what I noticed is there's actually
two distinct parts of the spec that needed to be updated.  There was the part
that dealt with the remote commitment transaction confirming onchain, so your
peers' commitment; and then, there's the part where your local commitment
transaction confirms onchain.  And these are basically mirror images of each
other and both need to be handled properly.  But LND only actually fixed the
case where the remote commitment transaction confirmed.  So, I had to go back
and say, "Hey, I just realized there's a whole other variant of this that needs
to be fixed".  So, they quickly fixed it and released it in 0.19.

The final vulnerability I disclosed was this replacement stalling attack, which
is probably the most interesting new vulnerability.  The basic idea behind it is
that an attacker would attempt to stall LND from claiming HTLCs onchain.  And if
the attacker could do this for long enough -- with default settings on LND,
they'd have to do this for 80 blocks -- if they could do it that long, then they
could steal any remaining balance on the channel.  So, the way this was possible
was by exploiting a couple of weaknesses in LND's sweeper system.  Their sweeper
system is basically a piece of code that handles force closes onchain, where it
looks at HTLCs that need to be claimed and then batches them into like a single
transaction, and then fee bumps that transaction as the deadline to claim those
HTLCs gets closer and closer.  And by default, LND is willing to spend quite a
lot in fees in order to claim those HTLCs.  It'll spend up to half the value of
the HTLCs.  Because of these weaknesses in the sweeper, the attacker could
manipulate LND into not bumping fees like it should.  And so, the attacker could
keep replacing LND's transactions in the mempool for very low fees and could
stall this way.

So, the way the attack would work, the attacker would have a direct channel with
the victim, and then they would route HTLCs to themselves through the victim's
node.  And then, the attacker would just halt those HTLCs and not disclose the
preimages for them.  And after some time, LND would force close the channel and
try to claim those HTLCs onchain.  Now, the sweeper would notice all these HTLCs
have the same deadline and it would batch them all into a single transaction.
Then, what the attacker does is they monitor their mempool until they see LND's
batched transaction show up.  And at that point, the attacker double-spends just
one of those HTLCs in that transaction.  So, they use their preimage to claim
that HTLC in their own transaction, and they pay just slightly more fees than
LND's batch does.  This would replace the batch transaction in the mempool and
prevent LND from claiming any of those HTLCs in the current block.

Once the attacker's double-spend transaction confirmed, LND would recognize that
this happened and it would then re-batch any remaining HTLCs and try to claim
those.  But because of one of the weaknesses in the sweeper, this wouldn't
happen immediately.  LND would wait for a whole other block before it did this.
So, each double-spend the attacker would do would basically stall LND for two
blocks at least.  It could be longer than that if the attacker's double-spend
didn't confirm right away.  And then, when LND would re-batch, it would reset
the fees paid by that batch transaction back to the minimum.  So, the attacker
could just keep spending very small amounts on fees to double-spend all these
transactions until 80 blocks had elapsed, and then they could steal the
remaining HTLCs by using their preimage to claim them and collecting the refund
on the upstream side.

**Mark Erhardt**: One question about the practicality here.  So, in order to
delay the closing of the batch, the attacker actually has to close one of the
channels, right?  He claims the HTLC and probably that does usually actually --
because he's paying more fees than the entire batch, not just does he have to
pay more fee rate, but also more absolute fees, that should be a pretty
attractive HTLC close.  So, the attacker would need at least 40 additional HTLCs
to sacrifice, to delay the main channel he's trying to collect on, right?

**Matt Morehouse**: Yeah, that's exactly right, and I did I did kind of a rough
cost estimate of this.  It's in the blogpost if you want to take a look.  But
the number I came up with was like a maximum of around 200,000 sats that would
be required to do this attack.  And using some other optimizations, it could be
as low as 100,000 sats.  Either way, it's much, much cheaper than probably the
amount that could be stolen.  So, unless you have a very small channel size, the
attacker can come out ahead.

**Mark Erhardt**: Sure, right, if there's at least one very juicy channel or
maybe, several and then the attacker routes 40 additional channels with the same
closing height, or it's HTLCs that have the same timeout, right?  So, make one
very big channel with the other side and then -- but so, how can you steal the
rest of the balance?  The balance would still have to have been on your side at
first.  So, you have to open a channel, you have to have the money on your side
first, you send the money to the other side, or…?

**Matt Morehouse**: Yeah.  So, there's some steps I skipped over, but you'd want
to open a large-ish channel, however much, basically as large as you want to
steal from the victim.  So, I don't know, 10 million sats or something like
that.  And then, you push your balance over to the victim's side and collect
that balance somewhere else.  And then, you route 40 HTLCs back through the
victim to yourself.  And you would have 39 of those HTLCs be the minimum amount
that the victim allows, and the last one would be the rest of the channel
balance.  And then, you use those 39 HTLCs to stall.  And then, at the end, you
steal that last HTLC that's super large.

**Mark Erhardt**: That's quite perfidious.

**Matt Morehouse**: Yeah.  So, this is a serious vulnerability that it took a
while to fix, and I'm glad it's finally fixed.

**Mike Schmidt**: Matt, you mentioned, for this excessive failback part two
vulnerability, how you found it, because you were going through some of the spec
work and realized that there was the other side of the coin that you needed to
address.  How did you discover the message processing or the unlimited inbox, I
think you call it, and this HTLC sweeper issue?

**Matt Morehouse**: The DoS attack, the infinite inbox one, I was just looking
at the code trying to understand how LND handled various messages.  This was
discovered around the same time as the gossip timestamp filter bug, which I also
discovered looking at their code.  I wasn't particularly looking for anything in
particular.  I just noticed, "Hey, this is a pretty big queue".  And then, I
decided I would try to see what would happen if I sent a whole bunch of messages
to fill up the queue.  And then, I decided maybe I'll do it for multiple peers,
and then got it to crash doing that.  The replacement stalling attack, I
discovered this while reviewing the new sweeper code that LND was implementing,
and I reported it to them before they ever released the new sweeper.  But yeah,
so the timing was unfortunate.  They were just about ready to release 0.18, and
then I come along with this vulnerability.  And the sweeper work they had been
doing already fixed several other vulnerabilities, and so I suggested in the
report that, you know, "Maybe you just go forward with the scheduled release
with the sweeper as is, to fix the vulnerabilities that are already known.  And
then, maybe in a quick 0.18.1 release, you fix this one".  But I did a poor job
of following up with them.  And it was, yeah, until I followed up with them
again, it didn't get fixed.  So, it took quite a long time, unfortunately.

**Mike Schmidt**: I see.  Well, you've referenced it in this discussion, but as
part of the preparation for the Year in Review Newsletter for this coming
Friday, I did a tally of all the guests on the podcast for the year and how many
times they've been on.  And Matt, you are the most frequent Bitcoin Optech
Podcast guest of the year with, as of today, seven appearances.  So, sorry to
all the LND implementations, but congrats to you, Matt, and thanks for all your
work on these.

**Matt Morehouse**: Well, hopefully I don't have to keep coming back next year.
I don't know if it's a good thing if I'm the top guest on the podcast.

**Mike Schmidt**: Maybe not, yeah.  Gustavo or Murch, any other questions for
Matt?  All right, Matt, what's your call to action?  How do we make this better?
How do we all make this better instead of you finding these things?

**Matt Morehouse**: I think ultimately we need, I keep saying this and I don't
know if this is changing anything, but we need more investment in security.  A
couple of thoughts that I had while reflecting on these.  First of all, as you
know, for me, I should use disclosure deadlines to put more pressure on
implementations to fix things quickly, and hopefully just kind of change the
culture around this so that all implementations do take vulnerabilities
seriously.  But another thing I thought about too is like, I talked about the
discovery of the variant of the excessive failback bug, how it was only
discovered after I went to update the spec.  And the only reason I was going to
update the spec was to help everyone else out.  And I mentioned this in the
disclosure for the original excessive failback bug as well, where it seems like
every implementation has had a bug somewhat like this.  Maybe it's not the exact
same bug, but all the implementations have now tripped on the same rock,
basically, and nobody ever updated the spec.  And once I went to update it, then
all of a sudden, there's other issues we need to address.  And so, it ended up
being good for everybody.

I had a conversation with Bastien because I was worried that Eclair might have
been susceptible to this variant of the attack as well.  And it turns out Eclair
was not susceptible to that, but the discussion led to the discovery of the
preimage extraction exploit that I disclosed a few months ago.  So, basically,
from just a small amount of trying to collaborate more or do something for the
common good, a lot of good things came out of it.  And so, I can't help but
wonder what would happen if all the LN implementations collaborated a little
more, or this might be a crazy idea, but I sometimes think having four different
implementations is a little unfortunate, because we have all this engineering
talent that's spread out and always competing against each other and everyone
discovers the same issues on their own, and then efforts get duplicated.  And I
just wonder sometimes if there were fewer implementations and people were
working together more, if LN would be further along and if there'd be a more
secure network.

**Mark Erhardt**: Unfortunately, not the trend we're seeing, because there's
also the Electrum implementation now.  And so, I think there's like five to
seven implementations now, four big ones.

**Matt Morehouse**: Yeah, it seems like it's going the other way.  Everyone
wants to implement in their own language and thinks they can do it better
somehow.  And it just would be great in my mind if there was something like
Bitcoin Core, where you have a lot more contributors focused on one thing, and I
think security is handled a lot better as a result.

**Mark Erhardt**: Thanks.  I was wondering, there used to be a project, I think
Christian Decker started it, for cross-implementation testing.  Is that still
happening?

**Matt Morehouse**: Is this lnprototest?

**Mark Erhardt**: I think that might be it, yeah.

**Mike Schmidt**: I think that was Rusty.  Was that Rusty or Christian?  Well,
either way, I think that's the library.

**Matt Morehouse**: I think one of them started it and then it kind of got
abandoned, but I did hear someone was picking it up recently.

**Mark Erhardt**: Yeah, and Bruno's been doing some great work on fuzz and
mutation testing cross-implementation, and also Niklas Gögge.  There's also a
bunch of different implementations for Bitcoin-based protocol, although Bitcoin
Core, of course, is the most run full node implementation.  There's probably ten
protocol implementations of Bitcoin.  And fuzz testing across implementations
and cross-compatibility mutation testing has found a bunch of issues, not just
in Bitcoin Core, but especially also other implementations.  So, how much fuzz
testing do people do in the LN so far?

**Matt Morehouse**: For most of the implementations, not very much.  The one
that is doing fuzz testing regularly is LDK.  So, they're pretty good about
writing fuzz tests for new code and stuff like that.  All the other
implementations, their fuzz tests are written by outside contributors, and they
don't really do much themselves.

**Mark Erhardt**: Well, maybe that's another thing that could help.

**Matt Morehouse**: Yeah, absolutely.

**Mike Schmidt**: Well, Matt, thanks again for joining us.  Thanks for being the
most prolific guest this year and for your hard work on these things.  We
appreciate it.

**Matt Morehouse**: Thanks for having me.

_A virtualized secure enclave for hardware signing devices_

**Mike Schmidt**: Second and last news item, "A virtualized secure enclave for
hardware signing devices".  Salvatore, you posted to Delving Bitcoin about
Vanadium, which is a RISC-based virtual machine designed to run V-Apps inside an
embedded secure element.  Maybe to help people understand the big picture, what
are you trying to achieve here?  And maybe we can go from there.

**Salvatore Ingala**: Yeah, that's a good point.  It's better to start from why,
rather than what Vanadium is.  So, I've been working at Ledger for almost five
years now, and I've been trying to bring some of the interesting features that
can be used for Bitcoin self-custody.  Miniscript has been one of my main goals
and projects, and more recently MuSig2.  And what I observed is that, well,
first of all, there are very few people working on this.  There are just a few
main vendors that most of the people use.  And in each of these vendors, there
are very few people actually actively working on Bitcoin.  So, I would be
surprised if there are more than 10 or 15 people routinely working on these
things in the whole world in total.  And that's not a lot for all the possible
things that could be done, right?

Another problem is that programming these devices is often quite difficult for
the outsiders, because they are embedded devices, so they're a lot limited.
Often, they have custom SDK, custom tooling and everything.  So, there's a high
barrier of entry if you want to develop something.  And if you develop something
for one device, so maybe not even all devices allow to run custom code, but
Ledger devices allow you to install an app that you develop if you want.  But
still, you have to learn Ledger SDKs, you're bound to embed the programming and
so on.  And so, the code that you write tends to be kind of tied in to the
vendor that you choose to implement things on.  And so, of course, if you don't
work for that company, you might be not so motivated to write code that can only
run on one device for a company that you even don't work for.  And that's
another thing.

The other problem is, so this causes a high barrier of entry for new development
on these devices.  But still, development is possible.  But the reason often
development is low is a chicken-and-egg problem, where these devices are mostly
used for self-custody technologies.  And so, when there is some new feature that
requires some substantial work, if you come to this vendor saying like, "Oh, can
you implement this new feature?" they're going to ask like, "Okay, who's using
this feature?"  And the answer is usually nobody, because people won't use it
for cold storage, and hardware wallets don't support it.  So, nobody writes a
software wallet to use those features.  So, there is always this chicken-and-egg
problem that hardware vendors don't have an incentive to build these new
features for self-custody because there are no software wallets, and so on.  So,
it's often hard to bring substantial new features.

So, the goal of this project, called Vanadium, is to try to democratize and make
programming these devices as easy as possible.  So, the goal is to kind of
remove as much as possible the limitations of embedded programming, remove the
limitations of vendor locked-in code.  So, you should write code that is normal.
In this case, Rust code, should not be locked into one platform.  And so, the
way Vanadium tries to achieve that is by kind of building a virtualized secure
enclave.  So, that means that instead of running applications natively, so
running code direct from the device, the device is running a virtual machine as
a normal application.  And then this virtual machine can run what I call V-Apps.
It's just a name that I chose to call applications running on this virtual
machine.  And in this way, you can try to kind of provide a virtual machine
which is standardized and is not tied to the limitations of the platform where
you're running it in.

So, one of the things that, for example, the VM does is that it can outsource
the content of memory pages to the host.  Like, normally you use a hardware
signing device connected to a computer, for example, and so it can use the
computer to store the content of RAM.  The same way that your laptop will use
the swapping partition if it runs out of RAM, the device can do the same using
your laptop as a swap place, basically.  And we can go into more details on how
we can keep this secure, because the security model is that we don't trust the
laptop, of course, so we need to be careful how we do that.  But this is one of
the things.  The goal of Vanadium is to try to make programming these devices as
seamless as possible, basically the same way you would program Rust on your
computer, and then you can take the same code and run it on the device.  And I
see that Murch has a question, so I'll stop for a moment.

**Mark Erhardt**: Yeah.  I mean, you got to it a little to the end, but I was
trying to extrapolate the big picture, what you actually do with these.  So, the
idea is usually a hardware signer is very limited in RAM and compute.  So, you
would be able to use the computer as an external resource to power up your
hardware signer, basically, to make it maybe into a fully capable HSM, run more
complex policies or sign more complex transactions, bigger transactions.  Is
that roughly, like, you just add more RAM and compute to your hardware signer?

**Salvatore Ingala**: Yeah, that's a part of it.  You actually add RAM, not
compute, because the compute needs to run on the device anyway, because you
cannot outsource computation and then trust, like okay, there could be some
moon-math cryptography to try to do these kind of things, but generally
speaking, no.  Like, if you want to trust computation, you have to run it in a
secure place.  So, all the computation still runs inside the VM, and the VM
itself runs inside the secure element of the device.  But it's only the RAM, the
memory, or potentially the storage, like for the code, for example, that can be
outsourced, because you can protect that by using encryption, by using
authentication, so that the host cannot do anything malicious with the code.

So, the reality is that most applications don't need a lot of RAM.  So, these
devices, even if they have like 20 kB, 30 kB of RAM, you can make it work in
most cases.  But the fact that you have to constantly worry about how much
memory you use makes development so much harder that it becomes a big barrier.
So, the goal is that you don't have to think about it.  The app can scale
automatically with the memory usage.  If you use more memory, it will start
swapping; if you don't use more memory, it will not need to swap.  So, if you do
a very simple app, it will end up not needing to swap much.  But the
optimization, so that you use memory more efficiently, can be an afterthought,
an optimization, rather than having to constantly think about it from the
beginning.  So, you can start writing code in the way that seems more
reasonable.  If you measure that, "Oh, it uses too much memory, it's too slow
because it does too much swapping", you can optimize that later.

**Mark Erhardt**: Right, so -- sorry, Mike, go ahead.

**Mike Schmidt**: Oh, I was going to say, so one thing is this additional memory
capability that Murch kind of touched on that you explained, Salvatoshi, but
also it sounds like the fact that this VM, this virtual machine, running on the
enclave would be sort of more agnostic to the device that it's running on.  So,
it could run on Trezor or Ledger or whatever, and it would have the same
capability.  So, if I write my virtual machine program once, it can run on
different hardware devices.  Do I have that right?

**Salvatore Ingala**: Yeah, potentially, yeah, that could be another thing that
might become possible, because the VM provides kind of an abstract concept of
what is an enclave that the signing device needs.  So, a signing device will
need to be able to do some cryptography, needs to be able to do hashes, needs to
be able to show something on the screen and get the user response.  And so, it's
a set of kind of functionalities that you can define once, and then you can
build the VM around this set of functionalities.  And any new compilation target
that you want to support, as long as you can provide exactly the same set of
functionalities, you don't have to rewrite the app, you can compile the app.  In
fact, the app is RISC-V, but you could even target a different VM that is not
RISC-V if you want.  If you wanted to rewrite Vanadium WebAssembly, you might be
able to run exactly the same V-Apps in WebAssembly, maybe run them on a website.

**Mark Erhardt**: So, it sounds to me like you're making a trade-off between how
much you need to have in the RAM and on the disk of your hardware device versus
getting it through the network from the RAM of the computer, right?  So, RAM
obviously is way faster, but getting data from a cable is also not that fast.
So, how, how does that all trade off?  Doesn't that also sound pretty slow to
you?

**Salvatore Ingala**: Yeah, like potentially, that can cause some performance
problems if the complexity of the app becomes much.  And right now, Vanadium is
at quite an early stage.  I already started writing an implementation of a new
Bitcoin app with some advanced features, and right now I do have some
performance issues because of too much data being passed on.  Part of the data
is the actual content of pages, but also, because it uses some merkle trees and
merkle proofs to kind of prove that the content of the pages is correct, that
adds additional bandwidth, for example.  So, you do have to be potentially a bit
careful.

I'm quite confident that the performance will be good enough for most
applications once the project is more advanced and stable.  There is a bunch of
strategies that could be adopted to kind of optimize the memory usage.  You can
try to tweak the compilation so that there is more code locality, so that the
code that needs to run together is in the same place, for example; you don't
have to access too many pages that are in different places.  You could kind of
also measure the execution of the app so that you can encode hints on what pages
are hot and should be kept longer, and what pages can be discarded immediately
because you won't need them more than once, for example.  So, there are all
these kinds of things that are not implemented yet and could be implemented.
And so, with those things, I'm very confident that the performance in the future
will be good enough for the typical use cases.  I already built some sample apps
for simple things and the performance is good enough for those.

One thing that I mentioned in the blogpost is that the performance of the VM, of
course, when you write a VM, the code execution is going to be potentially 100
times slower than the native execution.  But the bottleneck in the typical
application that you run on signing devices tends to be the cryptographic
operations, hashes, signatures, and so on.  And so, for those, you can avoid
having the loss of performance by having what is called, in RISC-V, ECALLs,
which are basically system calls.  So, if you need to do a signature, for
example, you don't simulate the signing algorithm, you just have some ECALL that
says, "Okay, you do a schnorr signature for this message".  And so, the message
and the keys are copied from the app memory to the VM memory.  And then, there
it's done at native speed.  So, signing something doesn't become significantly
slower than it would be on the native execution, and that tends to be the
bottleneck.  When I said the business logic, which is like, you're checking the
transaction, what is the sum of the inputs, what is the sum of the outputs, how
much is changed, these kind of things, even if that becomes 100 times slower,
it's fine because that's far from being the bottleneck.  So, that's the bet of
the project and I'm quite confident that it will play out in this way.

**Mike Schmidt**: So, in a steady state, let's say this is fully implemented,
the performance stuff is smoothed out, and this is an accepted standard across
the industry, what is the downside or are the downsides to this approach more
broadly, if everyone's using it?  What do we lose?  What's the bad part?

**Salvatore Ingala**: To me, in the long term, I'm actually very optimistic on
the project, meaning it could just become, in my opinion, a better way of
developing applications on the device, because you take normal Rust code and
then you compile it for some target.  You can even compile it in targets where
you don't need the VM, right?  So, if you're compiling for a target where you
have enough memory and you don't need the advantage of memory outsourcing and
everything, you can just compile it without the VM.  And in fact, the framework
can already do that.  You can run applications on your computer, and that's very
convenient when you're developing and testing, so that you can write tests in
Rust, and you test them on this code, you run the test, you do cargo tests, and
it runs the test natively, because it won't need the VM in this case.  It runs
natively, there is no memory swapping and everything.  And so, in the long term,
that could actually become just a new platform for developing apps on all these
devices that support it.

In the current deployment that I expect in Ledger devices, the only downside
would be that on a Ledger device, if you have an app installed, you could open
the app.  If it's a device that has a battery, you can turn on the device and
open an app and maybe do something in the app, like showing an address or
something, without plugging in the device.  And because Vanadium needs the host
to support the VM from the memory of sourcing, this is not possible.  So, it
will require being connected with the cable, maybe via Bluetooth, but I'm not
confident on the performance there.  So, you can only use the device when it's
plugged.  So, this potentially could be the only downside that I see for actual
running apps.

**Mike Schmidt**: Salvatore, you have listeners that are probably
technically-minded, like tinkering and playing around with things like this.
What would you tell them to do at this point?  I know it's not maybe
production-ready yet, but where can they look, where can they play with this,
where can they provide feedback?

**Salvatore Ingala**: Yeah, the reason I made the blogpost is that precisely,
even if I don't think that Vanadium is production-ready, and it won't be for a
few months at least, I think it's really developer-ready if you like to tinker
with things, meaning that I spent quite some time to improve the developer
experience, and I made a tutorial on the GitHub repository.  And really, I think
in five to ten minutes, you could be able to start playing with your own V-App.
And so, if you have any ideas, if you're a Rust developer working on Bitcoin, I
would be super-excited if you want to play with it.  Let me know if you discover
if you have any problems, if you need some feature that is missing, or even if
you just have ideas of things that could be cool to implement, please do reach
out and let me know.  I'm very excited for all the possible things that could be
built, but I'm always looking for more ideas.  So, do try it out, play with it,
and let me know, give me feedback.  That would be the best that I can get at
this time.

**Mike Schmidt**: Excellent.  Salvatore, thanks for walking us through that and
thank you for your time and joining us today.  We appreciate it.  Cheers.

**Salvatore Ingala**: Always a pleasure.

_Interactive transaction visualization tool_

**Mike Schmidt**: Moving to our monthly segment on Changes to services and
client software.  Even though we just did this a few weeks ago, we had a good
handful this month, starting with, "Interactive transaction visualization tool".
This is covering RawBit, which is web-based, meaning you can actually go to a
hosted website, but it's also open source, you can run your own.  And it's a
visualization tool, really sort of an education tool.  There's a bunch of
lessons you can go through on the RawBit website.  It'll show you exactly how
something like PSBTs work, HTLCs, coinjoins, and I think they've implemented
some of the covenant proposals as well, so you can actually visually see what is
going on with these transactions.  So, it's a cool education tool.  I think it
may have been around for a while, but I recently just discovered it.  Murch,
Gustavo, any thoughts?

**Mark Erhardt**: I think it's fairly new, maybe a month or so, or at least
that's the Delving post.  And maybe there was a prototype before that, but yeah.

_BlueWallet v7.2.2 released_

**Mike Schmidt**: Yeah, pretty cool.  We have BlueWallet v7.2.2 being released,
which adds support for taproot wallets, not just sending to taproot, but also
being able to create a taproot-based wallet for receiving.  They also have
watch-only features, coin control features within that taproot wallet, and then
support for some hardware signing devices for their taproot wallet.

_Stratum v2 updates_

Stratum v2 updates, there's a few different things lumped in here.  One is that
there's this v1.6.0, and that's of the stratum-mining/stratum and that's a
project, but also now the repository is a bit re-architected for the Stratum v2
repositories.  So, there's the Stratum v2 apps (sv2-apps) repository, and that
has a 0.1 release, and that supports what we've been talking about recently,
this direct communication with Bitcoin Core no longer needing to be a modified
Bitcoin Core, but actually that Inter-Process Communication (IPC) mechanism that
came out in v30.  You can have Stratum talking to Bitcoin Core directly.  And
so, that's actually in this apps repository now, not in the main v1.6.0 Stratum
v2 repository.

**Mark Erhardt**: Apps appear to be pretty hot right now.

**Mike Schmidt**: V-Apps, yeah, Stratum apps.  There's a bunch of other
documentation that came along recently.  There's a web tool for developers for
testing and spinning up things; there's a separate portal for a web tool for
miners to spin up pools and test Stratum v2.  So, good to see progress moving
along with that project throughout the year.

_Auradine announces Stratum v2 support_

Speaking of Stratum v2, Auradine, they announced support for Stratum v2 features
in their mining devices recently.  I wasn't able to get a ton of details,
because I saw this as a tweet.  But they did mention, "Encrypted, efficient,
secure-by-default communication".  So, I think that they're using that
communication piece for Stratum v2.  They didn't talk about necessarily miners
building their own block templates, so I suspect that's not in there.  But if
anybody has more details, shoot it my direction.  Murch maybe has some.

**Mark Erhardt**: If this is just the hashing hardware, I would be very
surprised if it were capable of building block templates, because you'd have to
have the pruned node state and a mempool.  So, that would be a fully-fledged
computer.  But just the interfaces to communicate encrypted and to get the block
templates from nodes would probably be what I expected in the firmware of a
mining device.

**Gustavo Flores Echaiz**: I also wanted to add that I looked at the website and
I saw that they don't have yet any miners for selling.  However, last month they
announced a new product, so I guess this will work with the new product they
announced.

_LDK Node 0.7.0 released_

**Mike Schmidt**: Thanks, Gustavo.  LDK Node 0.7.0 is released.  As a reminder,
LDK Node, different from LDK, is a node implementation built using LDK.  So,
it's a Lightning node using LDK that you can grab off the shelf and modify.  And
the 0.7.0 version adds support for splicing in an experimental capacity, and
also support for static invoices for async payments.  There's a bunch of other
features and bug fixes.  I think some of the items that Gustavo has been talking
about, in terms of the LSPS specs, are also in there as well.  So, check out the
release notes.  There's a bit more than what we've outlined here.  So, dig into
the details if you want to experiment with that.

**Mark Erhardt**: So, Mike, if LDK Node is a node, what is LDK then?

**Mike Schmidt**: It's a Lightning library.

**Mark Erhardt**: So, how do people usually use LDK?

**Mike Schmidt**: My interpretation is that people may be building their own
nodes using LDK, but I think LDK Node is sort of like the out-of-the-box, you
know, if you're struggling to do that yourself, this is sort of like their
reference implementation.

**Mark Erhardt**: Thanks.  Yeah, I think you were sort of begging this question!

_BIP-329 Python Library 1.0.0 release_

**Mike Schmidt**: Yeah, I assume people are cooking up all kinds of other things
with LDK as well.  BIP-329 Python library 1.0.0 is released.  This is a library
that supports BIP-329's additional fields, BIP-329 being the specification for
labeling transactions and outputs and things within your wallet and
standardizing that.  And so, BIP329 I think was already supported by this
library, but there's additional fields in BIP329.  So, if you look into the
spec, there's sort of non-critical or non-mandatory fields that you could use in
your labeling, and this library now supports that with the 1.0.0 release.
There's also some additional type validation and test coverage that they get
into.  And this is made by the team that is working on the Labelbase service.  I
think we've covered them in a previous Client services segment.  So, they have
this library in Python for people who want to do similar things that they're
doing with their Labelbase service.

_Bitcoin Safe 1.6.0 released_

Last one this week, Bitcoin Safe 1.6.0.  As a reminder, Bitcoin Safe is a
desktop wallet software, so I think it's Linux, Mac OS, and Windows, but desktop
only.  They add support in this release for compact block filters and also
reproducible builds.  One other thing that I saw in prep for the podcast is they
also have this new offline wallet functionality, so you don't need to be online
to have your wallet be able to be functioning, which is new for Bitcoin Safe.

_Does a clearnet connection to my Lightning node require a TLS certificate?_

Selected Q&A from the Bitcoin Stack Exchange, "Does a clearnet connection to my
Lightning node require a TLS certificate?  Pieter Wuille answered this one,
noting that LN connections by default already specify a peer public key using
the PUBKEY@HOSTNAME syntax.  So, it's the user who is already responsible for
configuring the correct key.  Thus, you don't need a third party to attest to
that key using something like TLS private PKI.  And so, when you're doing
something like a browser lookup where you need a certificate authority to say,
"Hey, this is sign off on this key", you're already specifying the key yourself,
so, you don't need that in a Lightning setup.

_Why do different implementations produce different DER signatures for the same private key and hash?_

Why do different implementations produce different DER signatures for the same
private key and hash?  Dave_thompson_085 answered this question.  Actually, the
person asking this question, if you dig into it, they show, "Hey, here's the
test case that I used with this private key and this message.  And here's what
Core Lightning (CLN) showed as a signature, here's what Decred showed as a
signature, LibSecP and Bitcoin Core, and they are all different signatures".
And they were wondering, are these valid for the same inputs?  How can they
produce different signatures?  And that is because you can produce different
valid ECDSA signatures, because signing is inherently randomized using the RFC
6979 spec, which is for deterministic nonce generation.

**Mark Erhardt**: It is random if you don't use the spec.  If you do use the
spec, the signature is based on the content of the message that you sign and the
key.  So, as some people might know, there is an equation system.  If you use
the same random nonce and the same key to sign for multiple different messages,
you leak your private key, right?  You can just solve the equation system and
you can calculate the private key out of that.  So, the good practice is to use
deterministic signatures, which are not random, based on the content of the
message and the key that you're using.  So, if you're signing the same message,
you will produce exactly the same signature and this vulnerability is not
triggered.  Otherwise, if you do not use this, you would be using a random
nonce, like just some very large random number, as the basis of your signature.
And if you use different random nonces with the same key, you can produce an
unlimited number of signatures for the same message that should all be unique.

However, in the past, many different, or not many, several times, wallets had
incorrectly implemented the signature generation and the random nonces were, for
example, based on the timestamp or based on a different seed for the random
number generator.  And we've had multiple instances where wallets were
generating the same addresses because they used the same randomness seed, and so
forth.  So, to basically sidestep this, it is recommended to use the
deterministic signatures with the RFC, because you would never be able to
accidentally reuse the same nonces.

**Mike Schmidt**: Yeah, thanks for correcting me on that, Murch.  It's random
'unless' you use that RFC, not 'because' of that RFC.

_Why is the miniscript `after` value limited at 0x80000000?_

Last question from the StackExchange, "Why is the miniscript after value limited
at 0x80000000?"  This question was answered by our very own Murch, who could
perhaps answer it again here.

**Mark Erhardt**: Yeah, so it's actually the 0.x8 and many zeros number is the
first one that's not allowed, because Bitcoin Script uses signed integers.
Signed integers lose one bit to the sign and therefore they are exactly a factor
2 smaller.  And that means that you can only express values up to
2<sup>31</sup>-1.  And if we count up seconds since 1970, which is the Unix
timestamp, then that takes us to 2038.  If it were an unsigned integer, it would
allow us to count up to 2106.  So, the person was asking here, "How come we can
use locktime for up to 2106 but we can only use", what was it,
"CHECKLOCKTIMEVERIFY (CLTV) up to 2038?"  Well, because in the transaction
header, the locktime field is an unsigned integer, and in script, all integers
are signed.  And therefore, even though they both have 4 bytes' precision, one
of them is half as big.  So, the after keyword in miniscript encodes a CLTV.
And if you want to encode a median time passed with it -- so CLTV or locktimes
in general can both encode block heights or time, wall clock time.  And if you
want to encode wall clock time in script, you cannot encode any values that are
later than 2038.  And that's just inherently by how the numbers work and how
locktime is defined in the context of script.

You are able to encode times later than 2038 if you encode block heights.  So,
if you use the blockheight mode, you will actually be able to encode even way
past 2106, because I think you can lock to very, very high block heights, but I
don't know from the top of my head and I'm not going to do the calculation right
now in my head.  But if you encode to a block height, you can lock later, but
with timestamp, you're limited to those.

**Mike Schmidt**: If you want to see what that limit is, you could always ask a
question on the Stack Exchange, audience, and then maybe Murch will answer it
for you there and we can cover it in January's show.  That wraps up the Stack
Exchange for this month, for this year.  And it doesn't look like, Gustavo, we
had any Releases or release candidates this week, so we jump right into the
Notable code and documentation changes.

_Bitcoin Core #33528_

**Gustavo Flores Echaiz**: Thank you, Mike and Murch.  Yes, so we start with
four different PRs from Bitcoin Core.  So, the first one, #33528.  Here, a
change is made on how the wallet can create TRUC (Topologically Restricted Until
Confirmation) or v3 transaction relay transactions.  Basically, it will make
sure that when creating this transaction, all policy rules are complied with,
and specifically which one.  So, if you go on BIP431, you'll find a rule that
says, an unconfirmed TRUC transaction cannot have more than one unconfirmed
ancestor.

So, here, what was previously happening is that the wallet was allowing to
create such transactions, even if they weren't complying with the specific
policy rule.  And later, they were rejected when trying to broadcast them.  So,
what this PR does is that it checks the rules at the transaction creation moment
and it blocks it at that moment, instead of allowing it to be created and then
block it at the broadcast level.  So, that's the first PR here.

_Bitcoin Core #33723_

We follow up with Bitcoin Core #33723.  Here, one DNS seed is removed,
specifically the one from Luke Dashjr, the Bitcoin developer.  So, maintainers
found that this was the only seed omitting newer Bitcoin versions 29 and 30.
So, you can find directly on the PR, on the comments, how many different
maintainers looked into and analyzed the behavior of this seed and others.  And
it stands out as the only seed that doesn't have any versions since 28.2.  So,
because of this, it was found to violate the policy stating that seed rules must
consist exclusively of fairly selected and functioning Bitcoin nodes from the
public network.  So, this and the maintainers judged that not including v29, v30
directly violates this policy, which was motive for removal from the DNS seed
list.  Any thoughts here?

**Mark Erhardt**: Yes, I think if you read the thread, I think you picked the
charitable interpretation.  I think the main reason is that Luke Dashjr has been
very vocal at speaking and detracting Bitcoin Core and claiming that it's
malware, and overall very antagonistic for several years now.  And several
Bitcoin Core contributors feel that if you're constantly shooting at a project,
you should probably not have any elevated privileges in the context of that
project.  And they felt that the trust had been eroded and he should not be
running infrastructure for the Bitcoin Core project.  And that's one of the main
other reasons that was stated there and repeated several times.  So, he
undermined the trust people had in him and that's why his node was removed.

_Bitcoin Core #33993_

**Gustavo Flores Echaiz**: Well said.  Thank you, Murch, for that.  We follow up
with Bitcoin Core #33993.  Here, the help text for the stopatheight option is
updated to clarify that the target height specified is only an estimate.  So,
what does this option do, stopatheight?  You basically put a block target, let's
say block 900,000, and your Bitcoin Core node will stop once it reaches that
target height specified.  However, when it will be shutting down, it might still
download other blocks.  So, basically, the help text here is updated to clarify
that this is just an estimate and blocks can still be processed even during
shutdown.  So, just to consider it as an estimate instead of as a fixed target.
Yes, Murch, go ahead.

**Mark Erhardt**: I think we should categorize it as it is.  I think that
there's a bug here.  When you use the stopatheight RPC, you explicitly want the
node to not process any blocks at that height.  But currently, it seems like
when you shut down a node, it may stop enforcing that block limit and process
blocks after that point, which is not intended behavior.  But this is basically
a warning that the node will behave unexpectedly when you shut it down after
using stopatheight.  But so far, there's still work on actually fixing the
behavior, so it works as intended.  And this warning is there until the fix will
be rolled out.

**Mike Schmidt**: What's the use?  Like, why would I do this?

**Mark Erhardt**: So, for example if you want to calculate a UTXO set at a
specific height, or if you're running an indexer where you build a table up of
all the transactions and all the UTXOs and balances at a certain height, because
who knows, you're doing accounting for up to that month, or you would want to
stop at a specific height.  Or maybe you want to re-index only from a specific
height, so you do stopatheight up to that height, and then you connect your
other software that processes blocks from Bitcoin Core as it progresses from
there.  It's basically a way to get your node up to a specific state in the
blockchain and then do usually other software things with it.

**Gustavo Flores Echaiz**: Thank you for the great context, Murch.  Yes, that
was very important to clarify.  This is not the intended behavior and there's
already discussion on how to fix it.  However, while it remains unfixed, here it
was decided to add this to document properly the current behavior.

_Bitcoin Core #33553_

So, we follow up with the last one from Bitcoin Core, #33553.  Here, there's an
improvement in the warnings in case of chain corruption.  So, the first
improvement made here is that once you download a header of a block that you
previously marked as invalid, Bitcoin Core will warn you, indicating that you
might be stuck in a presyncing headers loop.  So, for example, if there's
database corruption in your node, previously you would have no indication to
know that you were in a loop of syncing headers.  However, this PR improves the
warnings to let you know that when you download a header from a block that you
previously marked invalid, it probably means that you have database corruption,
because if multiple peers are telling you that this is the correct header and
this block is valid, and you have previously marked it as invalid, it probably
just means that your node has database corruption.

Another warning is added once your node detects a potential fork.  This warning
was previously removed because there was more sophisticated fork detection code
that was included in Bitcoin Core.  However, this fork detection code was
removed previously, and this code was leading to false positives during IBD
(Initial Block Download).  So, because this logic was removed, it was safe to
bring back this warning that could warn you about a potential fork detection
when you're in IBD.  Any additional thoughts here?  Perfect.

_Eclair #3220_

We move on with Eclair #3220.  Here, a helper method called
spendFromChannelAddress is extended to cover taproot channels that were recently
added to Eclair.  So, what this does is that if you accidentally send to a
taproot channel funding address without creating a channel, you just take the
address and fund it from an external wallet accidentally, this new method,
spendfromtaprootchanneladdress, allows users' peers to cooperatively spend UTXOs
that were accidentally sent to the channel funding addresses.  And of course,
this uses MuSig2 signatures to properly cooperate and spend these UTXOs that
were sent accidentally to this address.

_LDK #4231_

So, LDK #4231 here, basically LDK has a mechanism that once a channel funding
transaction that is considered locked is later unconfirmed, it will force close
the channel because there's a considerable risk of double-spending.  And this is
an edge case that almost never happens, because most nodes have six
confirmations as the set target to consider a channel locked in.  So, a
six-confirmation reorganization is very unlikely.  However, on zero-conf
channels, there's a whole different trust model and there's no six confirmations
before they are considered locked, it could simply be one.  However, the trust
model is already different for the zero-conf channels.  You are already assuming
that your peer could potentially double-spend your channel, you're kind of
trusting it.  So, here, instead of force closing the channel when a block
reorganization unconfirms the channel funding transaction of a zero-conf
channel, it will not do so because of the difference in the trust model.  Yes,
Murch?

**Mark Erhardt**: The zero-conf channel allows transactions to be made
immediately upon announcing the funding transaction, so the transaction is not
confirmed at all.  So, when a block reorganization happens that rolls back this
channel, so the channel started getting used even while it was unconfirmed,
zero-conf, right, and then it got its first confirmation, it got rolled back and
now it automatically force closes on that.  So, it's sort of just going back to
the zero-conf stage, which is sort of the risk the nodes were already accepting.
And still, it force closes now because of the reorg, which is really not what
you want, I think.

**Gustavo Flores Echaiz**: Exactly.  So, the risk was already assumed here and
the channel was already being used while it was unconfirmed.  So, if it goes
back to unconfirmed state, there shouldn't be a force closure because peers have
already accepted the risk, the trust model here.  So, also important to add that
obviously, the short channel ID (SCID) changes and the PR also handles that
change to allow for proper functioning later.

_LND #10396_

We follow up with LND #10396.  So, here, we work on the router's heuristics for
detecting LSP-assisted nodes.  This came from an issue where the BOLTs team said
that specifically, the LND Binance node was unable to pay them, was always
resulting in failures.  And this is because the LND Binance node was assuming
that the BOLTs node was an LSP-assisted node.  So, it was trying to pay it as if
it was an LSP-assisted node.  However, it isn't.  And the reason why was that
the BOLTs team was including some routing hints that were assumed to declare it
as an LSP-assisted node.  So, here, a few changes are made on the heuristics of
detecting LSP-assisted nodes.  Basically, invoices with a public destination
node or whose route hints destination hops are all private, are now treated as
normal nodes or non-LSP assisted nodes.  However, if it has a private
destination or at least one public destination hopped in the route hints, then
it's classified an LSP-assisted node.

So, that's the main change here, is the heuristics of how LND will consider
either a node to be LSP-assisted or not.  But also, there's another major
change, which basically says that when LND detects that this is an LSP-assisted
node, the way it pays it will be different.  It will only probe up to three
candidate LSPs and use the worst-case route, which means highest fees, to
provide the most conservative fee estimates.  The problem was also that
previously, LND could spend a lot of time trying to pay an LSP-assisted note.
So, here, it's simplified so that if it fails, it will fail faster and not get
stuck trying to probe all potential LSP candidates to pay this specific invoice.
Any thoughts here?  Perfect.

_BTCPay Server #7022_

So, we've got three final PRs here to talk about.  The first one is BTCPay
Server #7022.  Here, an API is introduced for the Subscriptions features.  So,
we talked about this feature in Newsletter #379.  Basically, this is a feature
that allows merchants to define recurring payment offerings and plans to their
users.  So, if you're a store that has a product where, let's say it could be
simply a newsletter, and so you can gate it behind a paywall and force your
users to sign up to a recurring payment plan, well here in this PR, BTCPay
Server #7022, an API is introduced for the Subscriptions features with about a
dozen endpoints that allow a developer to create, manage offerings, plans,
subscribers, and checkouts as well.  So, very cool if external apps want to
integrate this feature of BTCPay Server.

_Rust Bitcoin #5379_

We follow up with Rust Bitcoin #5379.  Here, a new method is added to construct
Pay-To-Anchor (P2A) addresses, which are a form of v3 transactions or TRUC
transactions.  So, this complements an existing method that already existed in
Rust Bitcoin for verifying P2A addresses.  Now, Rust Bitcoin can not only verify
these addresses but also construct them.

_BIPs #2050_

Finally, the last one is on the BIPs repository, #2050.  Here, the BIP390
specification is updated, which specifies how MuSig2 descriptors are built and
expressed.  Here, there's just an extension that a musig() key that is already
allowed inside a tr() can also be expressed inside a rawtr() in addition.  So,
this aligns with Bitcoin Core's implementation of MuSig2 descriptors, and also
aligns with existing test vectors within the BIP's specification.  So, this is
just a correction to align with implementations and test vectors within that
specific BIP.  Any comments here?

**Mark Erhardt**: I think rawtr() was just introduced after this descriptor.
So, I think it might have been backfilled because it didn't exist previously.

**Gustavo Flores Echaiz**: Thank you for the context.

**Mark Erhardt**: Also, I have a follow up.  So, with the blockheight-based
locktime, you could lock up to block 500 million, and 500 million blocks from
now is about 9,240 years in the future.  So, I think this should serve for most
of your locktime needs.

**Mike Schmidt**: Are you sure?  I thought bitcoiners were low time preference!
You know, we're going bigger than that, right?

**Mark Erhardt**: I mean, I could see you feel strongly about the next
generation, maybe the next three generations or so.  If you have plans for the
next 9,200 years, you definitely are ahead of the curve regarding immortality or
something!

**Mike Schmidt**: Thanks for the update, Murch.  Well, we can wrap up this final
regular newsletter of the year.  We want to thank Salvatore for joining us and
also Matt Morehouse.  As we note at the end of this printed newsletter, online
written newsletter, this is our last regular newsletter.  We're going to do the
year-in-review coming this Friday, and we will then probably have a podcast
after that, and then we'll be off for a week and back Friday, January 2nd with
our first 2026 regular newsletter.  Thanks, Murch.  Thanks, Gustavo.  Thanks,
everybody, for listening.

**Gustavo Flores Echaiz**: Thank you.

{% include references.md %}
