---
title: 'Bitcoin Optech Newsletter #411 Recap Podcast'
permalink: /en/podcast/2026/06/30/
reference: /en/newsletters/2026/06/26/
name: 2026-06-30-recap
slug: 2026-06-30-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Nishant Bansal and Matthew Zipkin to discuss [Newsletter #411]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-6-1/427173965-44100-2-e46f512fa5257.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome, everyone, to Bitcoin Optech Newsletter #411 Recap.
This week, we're going to talk about a disclosure of a DoS vulnerability in
some older LND versions; we're going to jump into a Notable code PR, or a
series of PRs, around removing a dependency, called libevent, in Bitcoin Core;
and we have a bunch of questions actually this month from the Stack Exchange
that we'll get into; and then we have our weekly Notable code and documentation
changes and Releases as well.  This week, Murch, Gustavo and I are joined by
two guests.  We'll have them introduce themselves briefly.  Nishant?

**Nishant Bansal**: Hey, I'm Nishant, and I work on fuzzing LN implementations.

**Mike Schmidt**: Awesome.  And we also have Mr Zipkin.

**Matthew Zipkin**: Hi there, I'm Matthew, pinheadmz, and I'm a developer at
Chaincode Labs.

_LND zero-timestamp gossip DoS disclosure_

**Mike Schmidt**: Thank you both for joining.  We're going to jump into the
News section, which just has one item this week titled, "LND zero-timestamp
gossip DoS disclosure".  Nishan, this was based on a Delving post that you
made, disclosing a DoS vulnerability that you discovered through state-machine
fuzzing of LND's gossip handling.  Maybe you can get into, Nishant, what did
you actually find?  We can talk about the actual vulnerability itself.  And
then, I'm also curious, maybe after we wrap that up, we can talk a little bit
about what is state-machine fuzzing, since we've talked about fuzzing on the
show before, we want to hear about state-machine fuzzing.  But what did you
find?

**Nishant Bansal**: Yeah, sure.  So, I'll start from the very beginning.  So,
Lightning nodes exchange gossip messages, and the one we are going to talk
about are channel_announcement, node_announcement, and channel_update.  So,
basically, these three messages Lightning nodes share so that every other node
can know about new channels, new nodes, and basically the update in the
existing channel or new channels' routing policies.  And what happened is three
messages, every node processes, validates them, and it updates their network
graph and then again rebroadcasts these messages so that other peers can also
update their network graph, which are basically used to route payment
throughout the network via HTLCs (Hash Time Locked Contracts).  So, in LND,
there was a vulnerability in their rebroadcast logic, so LND broadcasts this
gossip message in some periodic fixed intervals, and during that fixed
interval, LND de-duplicates these messages.  So, maybe during that interval,
there is certain channel_update or channel_announcement which are the same but
their timestamps are newer.  So, LND only stores those messages whose
timestamps are latest and discards the ones which are old.

The vulnerability was that an attacker could send a channel-update or a known
announcement whose timestamp can be zero.  And on seeing the timestamp of zero,
LND incorrectly assumes that this message was already seen and tries to
deduplicate it to its map base, like internal bookkeeping.  And when it tries
to put that message to not initialize map, LND basically panics.  So, that is
what the vulnerability is.  But if the victim node restarted after the crash
and if the attacker tries to send the same message again, LND is going to
reject those messages as stale gossip, because this bug was in the rebroadcast
logic and the stale gossip part was before that in the validation stage.  So,
an attacker cannot send the same message again if it already crashes the victim
node.  But this can still be manipulated if the attacker creates a new channel
and sends again this new channel_update with a zero timestamp for that channel.

With that, I tried two ways.  So, in my post, I mentioned two ways.  One is the
very straightforward way, where the attacker tries to create an actual channel
and tries to send the channel_announcement and channel_update for that channel.
And another could be that the attacker does not have to open an actual channel;
the attacker can create a fake LN node which it only used to do a noise
handshake and which periodically sends pings so that the connection stays
alive.  And then, the attacker can fund basically 2-of-2 P2WSH funding output,
and then tries to send the channel_announcement based on that.  And since all
the LN nodes only validate that whatever the Bitcoin keys mentioned in the
channel_announcement message are valid, and output is actually that P2WSH, all
the LN nodes basically will accept those channel_announcements.  And if after
that, an attacker sends a channel_update or maybe a node_announcement further,
then it can again crash the victim node.

**Mike Schmidt**: Okay, all right.  So, it sounds like there's a few different
attacks across a few different potential messages that are possible.  One, you
mentioned the synthetic channel is probably the cheapest one, because they
could just have a 2-of-2 with themselves and then do an announcement based on
that and crash LND nodes.  Do I have that right?

**Nishant Bansal**: Yeah.  So, the attacker has to first fund the 2-of-2
output, and then based on that, it has to send the channel_announcement.  The
LN node basically has, you can say, a prerequisite that a channel_update or
node_announcement will only be processed once a corresponding
channel_announcement is fully processed and validated.  So, for these messages
to ultimately reach the rebroadcast logic, which only comes after the full
validation phase, a corresponding channel_announcement has to be parsed
completely.  So, an attacker needs a valid channel, or maybe a 2-of-2 output,
to actually crash the LND node.

**Mike Schmidt**: Okay, that makes sense.  That answers my next question, which
is why not just do a bunch of fake node_announcements?  But, per what you just
said, that's not sufficient to trigger the codepath that would crash the node
here.

**Nishant Bansal**: Yeah.

**Mike Schmidt**: Okay.  Murch or Gustavo, any questions so far on the
vulnerability and then we can talk about state machine fuzzing?  Okay.  Maybe,
Nishant, I think listeners have heard us talk about fuzzing just at a
conceptual level a few times with different folks, the idea of throwing
quasi-structured but quasi-random inputs into various functions to see how node
software or any software behaves, and then pulling out the unique cases there
or crash cases to build sort of a corpus, and then build upon that.  But maybe
we're not familiar with the idea of state-machine fuzzing.  Maybe you can let
us know what that is?

**Nishant Bansal**: Yeah, so basically, state-machine fuzzing, or sometimes it
is mentioned as protocol fuzzing, takes this traditional fuzzing to one level
higher.  So, in the traditional fuzzing, we try to think of a particular
function as a black box and try to feed all sorts of parameters it has to see
if that function has any edge cases.  But in the state-machine fuzzing, we try
to feed some sequence of messages to a particular subsystem of a whole system.
So, for example, if you take gossip, so LND has a lot of systems.  So, there is
a gossip handling system and there is an HTLC switch which handles all the
HTLC-related state transition.  So, for the gossip subsystem, there is a
specific, like once a particular peer sends a message wire message of gossip,
and that wire message is decoded and directly fed to that particular gossip
handling, that is where the state-machine fuzzing comes.  So, state-machine
fuzzing tries to initialize that particular subsystem, and then it tries to
generate a sequence of both valid and invalid messages, and tries to feed those
message to that subsystem and tries to see how that particular subsystem is
behaving, and if there is any edge case in that subsystem, or that subsystem is
not crashing, or its internal state remains consistent, even if there is any
unexpected messages coming to it.  So, that is how the state-machine fuzzing
goes.

**Mike Schmidt**: Super-interesting.  Did you build out the state-machine
fuzzing?  I guess question one.  And question two, can such state-machine
fuzzing be easily applied to other LN implementations and how they handle
gossip, or is it really custom for the way the LND subsystem works?

**Nishant Bansal**: Yeah, so for state-machine fuzzing, I came to know about
last year only.  So, I was going through LDK's first suite, then basically Matt
Morehouse pointed me to that.  So, he was my mentor I was a Summer-of-Bitcoin
student last year, so he was my mentor on that, and I was curious about fuzz
testing.  And that is where he pointed me to LDK, because I checked the state
of the state-machine fuzzing for LN implementations and during that time,
during last year only, LDK was the one which has pretty good fuzz tests for the
state-machine fuzzing.  And that is how I went through that.  And then I
thought, at that time, LND didn't have any single state-machine fuzz test.  And
so I thought, maybe I'll understand what is going on in the LDK and try to do
the same for LND.  And that is how I found this bug.

**Mike Schmidt**: Awesome.  So, this was found during your Summer-of-Bitcoin
internship?

**Nishant Bansal**: No.  So, my Summer-of-Bitcoin internship was mostly on LND,
so it was on making an application which can continuously fuzz Go projects.
And since LND was in Go, so ultimately that project was for LND.  And then,
during that time, I came to know a lot about normal fuzzing, which includes
like, functional-level fuzzing and then state-machine fuzzing.  So, once my
project completed, I thought maybe let's see what is the state of fuzzing in
LND.  And then, I came to know LND doesn't even have any single state-machine
fuzz tests, and that is how I tried to fill some gaps in the LND.

**Mike Schmidt**: Awesome.  Well, great work.  Murch, Matthew, or Gustavo, any
questions for Nishant before we wrap up?  Okay, great.  Nishant, any parting
words for listeners who might be interested in doing similar work or anything
else that's on your mind?

**Nishant Bansal**: Yeah, I think this implementation's flaws are most easy to
get exploited considering how easy they can be carried on, like this
vulnerability as well.  So, I think state-machine fuzzing is very helpful in
such cases, and it would be really great if all LN implementations at least
follow or adopt state-machine fuzzing beside their normal testing or fuzzing
approach.  I think LDK is already doing a great job.  Whatever feature they try
to add, whatever protocol they try to add, they add state-machine fuzz tests
for that.  And I think it is practical for other LN implementations to add that
as well.

**Mike Schmidt**: Awesome.  Well, Nishant, thank you for your work on this.
Thank you for responsibly disclosing it and for coming to talk to us today
about it.  We appreciate your time.

**Nishant Bansal**: Yeah, thanks, everybody.

_Bitcoin Core #35182, #34411_

**Mike Schmidt**: Cheers.  For listeners, we're going to jump out of order.
We're going to Notable code and documentation changes, which means something
interesting is happening that we want to have a special guest on for.  We have
Bitcoin Core #35182 and Bitcoin Core #34411.  And we've brought on Mr Zipkin to
talk about this.  This is around this libevent.  And I think folks, maybe
through the grapevine, have heard something about removing dependencies, some
people are working on libevent.  Matthew, what is libevent?  Why is it good to
remove libevent?  How do you move libevent?  What was libevent doing?  You pick
where you want to tell the story from.

**Matthew Zipkin**: Okay, all right.  I'll try to make it a good, interesting
story.  So, libevent is an old library written in C and it provides an event
loop for consumers of the library.  So, that means scheduling tasks, timing
things, it's single-threaded.  Node.js developers are probably more familiar
with its cousin library, libuv, and the idea of an event loop in general that
you schedule things and processes, stuff like that.  So, another feature that
libevent provides, in addition to that event loop, is the HTTP server, and this
is primarily what it was being used for in Bitcoin Core.  So, I believe it was
added, I want to say probably by Mara van der Laan, ten years ago to replace
Boost.  I think there was an HTTP server in Boost before that.  I'm not quite
sure about the very first generation, but libevent was still a popular and well
maintained library at that time.

Over the years, it's become less maintained, and certainly there's been very
few releases, I think zero releases in the last four or five years.  And in
addition to that, they're looking for a new maintainer.  There's an issue on
their repo about looking for a new maintainer, which is a bit of a red flag.
It's kind of this really important project, Bitcoin, depending on this piece of
open-source software that's going through a maintainership, leadership change,
and we've seen vulnerabilities introduced at times like that, with compression
libraries and stuff.  We don't want to get sucked into that.  And also, if you
look at the libevent issues and PRs, most of them are from Bitcoin Core
contributors.  I don't know how popular the library is anymore.  So, it's one
of the last external dependencies, meaning we, in some cases, expect the
computer to have libevent already installed and we link to it.  There's
obviously stuff like a depends build, where the entire codebase of libevent is
pulled in and we release it.  So, that's a little bit different.  But libevent
has become a liability because it's this potential risk and maintenance burden
in the depends code.  And so, there's plenty of good reasons to reduce
dependencies.

My personal adventure down this path is kind of funny.  I think two or three
years ago, whenever Core Dev Berlin was, it was around that time, I was looking
at some really old issues in the Bitcoin Core repository.  And one of them was
a feature request by users to add Unix domain sockets for the RPC server.  So,
what that means, for people who don't know, is when you run Bitcoin Core, it
spins up an HTTP server, which is what we're using libevent for, and you can
send messages to it, commands like, "Create a wallet", or, "Tell me what the
hash of this Block is", and stuff like that.  And those questions and answers
get sent over HTTP, same protocol we use for web pages.  Since typically the
client and the server are on the same machine, there's no real need for that
kind of infrastructure.  You can use what's called a Unix socket, which is
basically just a path on your file system.  Except it's not really a file
there, it's a socket and you can send data back and forth over it.  Tor, for
example, uses this, Docker uses this.  It reduces the overhead, it reduces
security risk, and it's a good feature for Bitcoin Core to have.

So, I originally was looking at how to add Unix sockets to Bitcoin Core for the
RPC interface.  Is that a question?  Was that a finger?  Okay, go.

**Mark Erhardt**: I was just wondering, so if you were able to use these Unix
sockets in order to talk from your own computer with your own computer through
the file system, would that mean that you could turn off the HTTP server,
because most RPCs interfaces should not be open to the entire internet and so
on, maybe not even to network.  So, only being able to talk through your own
computer to it would kind of make sense.

**Matthew Zipkin**: Yeah, exactly.  It would obviously be optional, because I
think after 15 years of Bitcoin Core having the HTTP server, there's probably
lots and lots of clients and applications that are used to it being there.  So,
I don't think it's something we could ever get rid of, but it would be a nice
option to switch to the Unix socket.  And as I looked into implementing this, I
hit a roadblock in libevent.  And I had an issue and maybe even a PR to
libevent back then.  But the problem with libevent is like, even if they fix
something in master branch, they haven't cut a release in so long.  And
nobody's installing libevent from master.  You do apt install libevent-dev, and
it's just packaged, you know, depending on what operating system you're using.
And the fact that libevent was not keeping their patches up to date with new
releases means we couldn't just be like, "Oh, Bitcoin Core, this version.  Use
a new version of libevent and you'll have this Unix sockets feature".  It just
wasn't going to happen.

So, we started looking into the alternatives to libevent, or there's other
solutions to this problem, which are one, we can take the entire libevent
source code, move it into Bitcoin Core, and own it, fix stuff there.  And this
is what we've done with, I want to say LevelDB.  Maybe Murch knows more than
me.  So, we've done this with the LevelDB source code.  That was one option.
Another option is to find another HTTP library that's just out there and swap.
And the third option was to write a new HTTP server entirely as part of the
Bitcoin Core codebase.  And after discussion with other developers and
contributors for Bitcoin Core, that's what we decided to do.  Any questions up
to there?  Yeah?

**Mike Schmidt**: I'm curious how much of the libevent library would need to
be/was recreated.  So, the reason I ask is I'm thinking about like OpenSSL and
secp, and that was just like a very, very small portion of a giant library that
was getting used, and so it made sense to carve off, even though it probably
was still a big chunk, into its own code that was managed by Bitcoin Core.  And
I'm curious, of libevent, how much of that needed to be recreated?  Was it
basically the whole thing, using all the features, or was it just a small piece
of it?

**Matthew Zipkin**: Right, good question.  So, yeah, libevent is primarily this
event loop, which is not really what Bitcoin Core needs.  It has an HTTP
application as a bonus on top of the event loop.  And the server is what we
really need.  It's really easy in C++ to just write a loop in a thread.  And in
fact, we do this for P2P already.  I mean, there's loops all over Bitcoin Core,
but we have the P2P messaging takes place in a thread with a loop that checks
sockets and sees if there's any connections coming in and any messages coming
in on those sockets.  So, a lot of that architecture was already there written
in C++.  The HTTP protocol itself, like get, post, URL parsing, stuff like
that, we relied on libevent for that.  The other thing I'll mention that might
not be obvious is that we also ship a client tool, bitcoin-cli, which also used
libevent for the client stuff.  So, ultimately, we would need to replace both
the server and the client.  Both were being used, both were using libevent.
And there's also smaller areas of the codebase.  The way that Bitcoin Core
interacts with the Tor daemon, a protocol called Tor Control also was using
libevent, because that's also an HTTP-based -- it's actually not HTTP but it
uses the same socket-reading protocol.  So, that was replaced by Fabian.  Other
little utilities, like parsing URLs, those were replaced by Fabian.

Then, I wrote the server replacement, which I mean it took two PRs each with
300 comments over two to three years.  The architecture went all the way out
and all the way back on how we were going to do it.  As I mentioned in the P2P
code, we already have socket-management stuff and it's cross platform, because
obviously, without any type of dependency like libevent, you can run Bitcoin
Core on all of our supported platforms, we can open software sockets and make
network connections on all those platforms.  So, we already have that stuff in
there.  And the debate early on was how much of that to reuse.  So, Vasil had a
great effort of abstracting away the socket layer into its own socket library
that could be consumed by both the P2P function and the HTTP function.  We'd
both be consuming the same socket library.  There was some pushback on that,
and so my first HTTP server actually used that socket abstraction, and then we
decided not to do it that way.

So, the way it is now, the way that it got merged is that there's
socket-handling code in a single thread loop for P2P, and basically a second
version of that code for HTTP.  And it means that we can adjust the socket
implementation very specifically and granularly, which was Cory Fields'
contribution to the debate.  So, if there's things we want at the socket level
for P2P, it won't interfere with what we need for HTTP.

**Mike Schmidt**: Very cool.  So, does this wrap up?  Do these PRs wrap up
libevent removal?  Or is it over?

**Matthew Zipkin**: Yes.  Fanquake was very excited about removing the
dependency.  And for the last six months, I think he had a follow-up ready.
After my work on the server was done, all that was needed was to remove
libevent from the build system and from the docs is basically just still being
pulled in by the build system and mentioned in certain places.  And the server
was the last thing where the code was actually consumed.  And so, having that
merged meant that we could immediately remove it from the build system.  So,
this is not something that users will notice, it's not a cool new feature.
Hopefully, nobody notices it.  We've done a bunch of extensive integration
testing and fuzz testing.  I made sure that the HTTP server was still going to
work with LND and Eclair and Electrs and as many libraries as I could find.  We
didn't want to break anything.  Of course, there were still some API breakages
from other reasons, but at least it wasn't HTTP-related.  And fuzzing, lots of
fuzzing, just ran the fuzzers all the time.  So, hopefully nobody notices that
this change has happened.

**Mark Erhardt**: Once again, it would be super-helpful if consumers of Bitcoin
Core, ie software projects that rely on Bitcoin Core's interfaces, and
especially HTTP server in this case, would run the master branch and the RCs
before the release.  Every time we ask for this, and every time a few months
later, or when the release is cut in the following weeks, someone is like, "Oh,
it breaks my use case".  That's exactly why you should be running the RC and
testing.

**Matthew Zipkin**: So, I also think this is something that we might be able to
take over.  Let me explain.  For this integration testing, what I did is, so
take LND, for example.  They have their own continuous integration testing
where they download a release of Bitcoin Core.  I think right now their CI is
pinned at like 29, maybe 30, and they run all their tests against it.  So, what
I did for each of these projects I wanted to make sure we weren't breaking is,
I forked the project, modified their CI to run my branch of Bitcoin, and then
removed all the tests that I didn't need.  And I found stuff that was breaking,
most notably, cluster mempool has changed a lot of the mempool-based RPC
responses.  Those APIs are broken.  And another one is varying taproot
activation.  I'm sure you guys have talked about this stuff with your audience
before.  And so, LND, one of the things it would do to see like, "Hey, does the
node I'm talking to know what taproot means?" and it would use the
getdeploymentinfo RPC to ask that question.  Now that taproot is buried, it no
longer is in the right place.  So, LND would suddenly, with the latest version
of Bitcoin Core, think it's not talking to a taproot-enabled node.

So, the infrastructure to do this is very simple.  I just forked all these
projects, replaced their Bitcoin Core with my Bitcoin Core and ran their CI to
see if the tests pass.  And I think this is something we could maintain.

**Mark Erhardt**: I think that is very generous of you, but it shouldn't be the
upstream project's job to go to all the downstream projects and fork their
infrastructure in order to do their testing for them.  Downstream projects
should just have maybe their recommended release in one branch and then also
the master branch.

**Matthew Zipkin**: You get on that soapbox, Mark, and keep tweeting about it.

**Mark Erhardt**: You'll be the bridge-builder!  I'll be on my soapbox saying,
"Hey, this is your job"!

**Matthew Zipkin**: I wasn't doing much for these.  Like, there was a Rust
crate that broke with the new mempool RPC changes.  And I just opened an issue
and I'm like, "Here's the patch that Claude generated for me to get your code
to work with our code".  And that's all I'm going to do, is open the issue, not
even try to open a PR, especially because I was just using Claude to generate
the PR like, "You guys know what this code does.  Just telling you, you need to
fix this".

**Mark Erhardt**: Yeah, but if you didn't do much, that should be something
that the downstream project can do.

**Matthew Zipkin**: Well, the thing is, I already have experience modifying an
RPC with Bitcoin that breaks something downstream.  And there was something, I
forget which one it was, we changed the string to a list, or something, and it
broke stuff downstream.  There's a PR open right now to formally define the RPC
interface, and I think that's interesting, so we have machine-readable
instructions on how to consume it.  So, if we break the API downstream, they
automatically know it's broken, as opposed to this kind of thing where we
change a string to a list and then stuff gets broken because they expect it to
be a list.  Anyway.

**Mike Schmidt**: Well, we need to know.  What is this downstream testing suite
that you've put together?  Does it have a cool name yet, or is it just you
patching some things together; doesn't have a hat, doesn't have a shirt,
doesn't have a logo?

**Matthew Zipkin**: Yeah, all that fun stuff.  No, nothing fun.  It started off
being manual, and then over the last two years as I was working on this, the
LLMs got good enough that I could just have an agent do it and say like, "Here
are the six forks I want you to do.  Build a Docker image, write a PR, open it
against my own fork, let's run the CI and see what happens".  And it would find
stuff like, "Oh, the mempool RPC changed".  The agent says, "I can fix that.
Here's the patch.  Now it's running".  And that's been cool.  There's also been
some hangups.  Like the first bot I tried, GitHub banned, and it had already
opened all these PRs with fixes, and those all disappeared, and that was
upsetting.  But you know, whatever.  That's just a speed bump.

**Mark Erhardt**: That brings us to another conversation that we might report
on in another week.  But there's been a lot of problems with GitHub's content
moderation lately, like they broke LDK for three weeks or something.  And then,
after tons of tries to reach out, eventually just re-enabled them and never
explained what happened.  But you know.

**Mike Schmidt**: Well, that's a pretty cool initiative that you've been
running, Matthew, and I'm glad that the LLMs can help with that.  And yeah, I
guess since you're opening PRs to these different projects, obviously it's on
them to sort of review and QC that.  So, at least the LLMs give it a good try
to fix that.  That's an interesting initiative.

**Matthew Zipkin**: At least we have the 'I told you so', so they don't open
the issues and they're like, "You guys broke this API without telling us".

**Mark Erhardt**: Yeah, I mean I'm not saying that it's not nice what you're
doing, but I'm still kind of confused how this is a conversation that we have
at least once a year.

**Matthew Zipkin**: I just didn't want to be the guy that breaks the Bitcoin
Core LND thing because I was using an HTTP thing that libevent wasn't using.
And so, the last thing I'll throw in here is, I was excited at first about
replacing libevent, because I thought we might actually be able to get a speed
up in the code.  And there are some benchmarks, notably contributed by romanz,
who I think is the Electrs developer maintainer, showing that it is actually
faster for certain HTTP requests than libevent was.  So, I was really excited
that this was going to revolutionize our CI and everybody was going to be so
excited that the functional tests are faster now.  And that's not the case.
And here's a very simple reason why.  When you build Bitcoin Core with
libevent, libevent is not built, it's not compiled with debug flags.  It's a
compiled library that you just download.  It's already as optimal as it
possibly can be.  And so, this wasn't a line-of-code reduction at all.  I mean,
it took something like 400 lines out of Bitcoin Core to remove libevent, and
added something like 2,000 or 3,000, because there was an entire HTTP
implementation in there.  And when you do a debug build, all that code is now
built with the debug flags.

So, my guess is that the functional test suite is going to run a little slower,
and that's been my observation.  And if you build with optimization, like our
releases, it's about the same, performance-wise.

**Mike Schmidt**: So, I think we've hinted at it, but this will be in the next
version of Bitcoin Core; this will not be, and the new version, internal
version, will be?

**Matthew Zipkin**: Yeah, the 32 release is when I find out if I -- I mean,
this is the thing.  HTTP, everybody who uses Bitcoin needs the HTTP interface.
This isn't something that's optional.  It's not like v2 transport where you can
opt in or opt out.  It's like.  Coinbase uses the HTTP interface, Binance uses
the HTTP interface.  There's no way around it.  This is how Bitcoin Core is
used by every single application.  Your wallet password goes through this
library.  Maybe another reason why using libevent after it's been unmaintained
is so dangerous.  So, we'll see.  Hopefully, no issues come up.  But yeah,
version 32.

**Mike Schmidt**: Matthew, thank you for your work on this.  Thanks for jumping
on and talking us through the story behind this.

**Matthew Zipkin**: Thanks for having me.  It's great to talk to you guys,
great to see you guys.  Take care.

**Mike Schmidt**: Cheers.  Back up to our monthly segment on QA from the
Bitcoin Stack Exchange, which we had none, I think, last month.  So, it was
good to see some this month.  As you can tell from the subject matter, the
Stack Exchange follows what's being discussed more broadly as people have
questions about what they're seeing online and what's being discussed.  So,
with that, we'll jump into it.

_Is it a bug that `OP_IF` is part of the tapscript opcodes?_

First one, and Murch, I think you answered a lot of these.  So, I'll be the
chaperone here, but you're the main event.  "Is it a bug that OP_IF is part of
the tapscript opcodes?"  And I think, Murch, you can elaborate on the
motivation of this question.  But given that you have these different leaves, I
guess that would be the IF, right?  And so, why do we need an IF, I think is
the question.

**Mark Erhardt**: Yeah.  So, for some reason, there's a lot of discussion about
BIP110 on X in the last few weeks again.  I think with the mandatory signaling
coming up in a few weeks, people are really trying to make or break it.  And
maybe I'll editorialize not too much here, but I feel like it's very much in
the fake-it-till-you-make-it territory right now, because the hashrate support
is under 1% and node support is a little higher, but also a small minority of
all nodes.  So, I think it's going to be a non-event.  But people are spinning
all sorts of interesting narratives around this, and then other people are
asking questions about that.  So, I asked this question because someone had
been going around claiming that having OP_IF in tapscript is a bug in the first
place.  So, I think that narrative doesn't have any legs to stand on.

IF, in general, is one of the most basic functions in every program language
under the sun.  So, removing OP_IF is something that you first have to think
about very hard, because everybody would consider that an option in any
programming language.  But more specifically, this narrative was based on the
claim that any tapscript, so any script that appears in a script leaf in the
script tree of a taproot output can be replaced with multiple leaves if it
contains an OP_IF.  And this claim is true because, of course, you can always
restructure a set of logical expressions into a disjunctive form, where you
separate all of the conditions into blocks of ANDs that are grouped and
separated by ORs, and the OP_IF would be basically an OR in that expression.
So, yes, you can always split any script that has OP_IFs into multiple leaves
that just do the expression that was in one of the two conditional branches.
However, that is (a) not always smaller and (b) it's definitely not a bug to
have OP_IF in a programming language, because that's just very basic and
present in any programming language.

So, why is it not always cheaper?  First, maybe yes, splitting up a script into
multiple parts is a privacy improvement, because you'll only reveal the part
that you're using.  But when you split into multiple leaves, you might need a
higher depth of tree.  So, if you have a single leaf, this leaf will live at
depth 0.  So, it requires a control block of zero hashing partners, and only
you have to reveal the internal public key.  But you always have to reveal the
internal public key if you spend a scriptpath.  So, at depth 0, there is no
hashing partner.  You simply show your script leaf, and for the script tree, it
is hashed with the internal key, and now you see the external key, and you have
proven that the leaf was committed to when it was created.  If you have two
leaves, you need a depth 1 tree.  So, for two leaves, you need one inner node
and then a split to two outer nodes that adds 32 bytes to each of the two
leaves.  If you want to have three leaves, you need a script tree that is at
least a depth of 2, one inner node to split the two branches.  You find one of
the three leaves, and then two more leaves split up from another inner node.
And now, the two other leaves need 64 bytes, two times 32 bytes, for the
hashing partners to prove that they're part of the script tree.  So, if the
script that you're expressing adds less than 32 bytes in the conditional OP_IF,
it's actually getting bigger by adding script leaves, because you push it to a
lower depth.

So, the other aspect of this narrative was, "Oh, if you want to put everything
into a single script, you should always do it as P2WSH, because P2WSH already
doesn't have the control block, and therefore you save the reveal of the inner
key.  And if you're showing the whole script, you only have one, so it should
live in P2WSH.  This is invalid, of course, because a P2WSH doesn't have
schnorr signatures which tapscript has.  So, for example, if you're using MuSig
or you want to tweak, that doesn't work with P2WSH.  The other one being, if
you're building a complex wallet policy, you might be using the keypath to use
one of the spending conditions.  So, if you have a spending option that is just
multiple keys signing off on something together, you can do that with MuSig if
it's 2-of-2 or 3-of-3.  You can do that with Rust if it's a threshold setup in
the keypath directly.  So, you can pull out one of the leaves into the keypath
and it'll look like single-sig to anyone else.  Both of those things are not
possible with P2WSH.  So, if someone claims that it is a bug for OP_IF to exist
in tapscript, I hope you feel that that is not a valid statement at this point.

_Why would forbidding `OP_IF` in tapscript be a problem?_

**Mike Schmidt**: Next question from the Stack Exchange is also about OP_IF in
tapscript, "Why would forbidding OP_IF in tapscript be a problem?"  So, I think
there's discussion that since OP_IF in tapscript is being abused, turn it off.
And I guess that's the crux of this question.  What might happen, Murch?

**Mark Erhardt**: So, the context here is again BIP110, of course.  The reduced
data temporary soft fork proposes seven new consensus rules, which target
different ways how data embedding is happening on the Bitcoin Network.  And the
biggest target here, of course, is to forbid inscriptions.  Inscriptions use
something called the inscription envelope, which basically is an OP_FALSE and
an OP_IF.  So, it always negates the conditional.  And then, on that dead
branch that will never be executed, it pushes the data in.  So, the data is
part of the script, but it is not part of any executable branches of the
conditionals.  And thereby, OP_IF is abused in this manner to produce a
data-embedding envelope in witness stacks.  So, the idea of BIP110 here is,
"Oh, obviously we'll just forbid OP_IF, then people can't use this envelope
idea, and no more inscriptions on Bitcoin".  So, this is naïve because there
are multiple other ways how you can easily produce another envelope that uses a
different way of creating such conditional branches, or you just push the data
and then drop it with OP_DROP, or you push the data and push it to the alt
stack, and so forth.  So, closing one of these doesn't prevent inscriptions.
It just means that with the year lead or so that you have on a soft fork,
people that want to do data embedding are going to use one of these multiple
other ways of doing the same thing.  And just if they were worried that it
activated, they would just start doing it a few months in advance with a
different method and you'd start from scratch, which is exactly why people have
been saying you can't police what people are doing on the network with
policies, because policies are broken by a minority that doesn't go along with
enforcing the policy.  But then, the second part of that is, you also can't
police data embedding effectively with forks, consensus rule changes, because
consensus rule changes move so slowly that data-embedding schemes will evade
them easily.

So, now, why would forbidding OP_IF be a problem?  Well, we already established
that OP_IF, or the IF functionality in general, is one of the most basic
building blocks of programming languages.  But very specifically, there are
numerous or several software projects that have support for miniscript, and
miniscript was built using OP_IF.  So, if you use miniscript to describe a
policy in a more human-readable fashion and then compile it to a descriptor,
the descriptor may include OP_IF opcodes.  And we can't tell what is in the
preimages of hashes.  So, if someone has some spending condition, for example,
that resolves to a keypath spend for their personal use, but then has a
scriptpath spend for inheritance or a fallback for their other wallet, or more
complex spending conditions that are based on an OP_IF, we might never have
seen that on mainnet because they never reveal the scriptpath while they're
just using their keypath fallback that is more private and cheaper.

So, if the wallet developers decided to update the software, if the software
then had a release that got rid of OP_IF, there would be no guarantee that the
user had upgraded to no longer produce OP_IF scripts, and even if they updated,
that nobody continues to send to their old wallet pattern after the time that
such a soft fork activated.  But more likely, someone that set up such a
complex script continues to just use it over time.  And then, when they send
themselves a change output after making a transaction, they might not realize
that their fallback mechanism was broken, because even if they tested it
before, they didn't expect the rug to be pulled from underneath them.  So, this
breaks user space.  This is by far the most controversial change that is being
proposed with BIP110, and I think it is completely indefensible.

**Mike Schmidt**: I think there's been some discourse online from Knots users
reaching out to folks like Nunchuck, I believe, supports things like this, or
the primitives for people to be able to do it using Nunchuck, something like
that.  And I think the encouragement from Knots users is saying, "Well, don't
let people do that, or take that part out because it could result in issues if
BIP110 activates".  And I'm curious, since it's Knots users saying that, I'm
wondering if Knots itself, would it be able to generate such addresses?

**Mark Erhardt**: Actually, yes, I think, since Bitcoin Knots is a fork, a
project fork of Bitcoin Core, and miniscript has been supported in Knots for, I
don't know, five years or so.  And I think that Knots also supports descriptive
wallets, but don't nail me down on that.  I know that Luke has been very
opposed to the legacy wallet removal, so maybe he hasn't added descriptive
wallet support either.  I don't really follow the internals of Knots that
closely.  But if Knots actually supports miniscript, which I think is the case,
and it supports descriptor wallets, then you can create wallets that have OP_IF
in Knots and they're basically breaking their own user space.  And I think the
biggest problem here is we put out software that can do these things.  We have
no idea whether people have taken up our offer and started doing those things.
They might never tell us.  They might just tinker away, see the new features
and just are turned off by the public discourse about Bitcoin and never look at
it.  And because we traditionally have had a very high bar for not breaking the
user space, they might just rely on anything that works in Bitcoin will
continue to work forever.  And just assuming that you will not break someone is
a fallacy here.

_Does a softfork always succeed?_

**Mike Schmidt**: Next question, "Does a soft fork always succeed?"  Murch, you
answered this question, and of course, give your answer.  And you asked the
question as well, but clearly you're seeing some discourse that's making you
want to surface this answer that you're going through.  But I'm also curious as
to what you think someone is thinking, like why are people thinking that soft
forks always succeed?  Like, what's the misconception there?  Is it just
historical, or maybe you can get into that, like why you think this needs to
even be asked?

**Mark Erhardt**: Well, again, a lot of people have been making some claims
that I find dangerously misleading.  And one of the ones that I keep seeing
repeated is a soft fork that is not opposed will always succeed.  And now, this
is based on a couple interesting definitions.  One is they claim that a soft
fork that's not adopted is not opposed.  So, basically, you have to actively
oppose a soft fork for it to be opposed.  Just not supporting it is
insufficient.  I think this is incorrect.  The other one is that the party or
the group of people that are enacting a soft fork will always succeed to
enforce these new rules on their own node.  And there's a difference, of
course, between your own node enforcing the rules that you've picked with the
software that you're running, which is basically true for any software that
parses its test suite, or the network adopting a soft fork.  And this is sort
of a piece of charlatanry, where they just say one thing and are truthful about
it, "Yes, of course, your node will always enforce the rules that you run", and
then claiming or pretending that it means that the network will adopt it, and I
think those are two very, very different things.

So, let's get into this a little bit.  Obviously, if you introduce a new rule
on your node, your node will, if you did it right, enforce that rule.  So, such
a rule could be, for example, a blockhash cannot have any A's in the hash.
That is a soft fork.  And you would very quickly be alone on your own network,
because everybody else accepts block hashes that exclude the number 11 from the
hexadecimal in the hash result.  But you would, of course, enforce that rule.
So, you succeeded, you soft forked from the network.  However, you're alone on
your network because everyone else just continues moving on with the Bitcoin
Network.  And exactly the same thing is happening here.  So, there's a few
people that are introducing a bunch of new rules that are very controversial
and not supported broadly.  And of course, they will succeed on being on their
own fork once they start enforcing those rules.  But that doesn't mean that the
Bitcoin Network will follow along with those rules.  So, by that definition,
yes, their soft fork will always succeed, but it might not succeed at pulling
Bitcoin along onto their new rules.

The other one is we traditionally have been collaborating with the miners to
adopt new, more restrictive rules on the Bitcoin Network.  And this works very
well, because when the majority of the hashrate enforces new rules with the
support of hopefully a big majority of the nodes, that is a stable change in
the rules.  If there are any blocks created that don't adhere to the new rules,
they will be reorganized out and they will be a part of a shorter stale chain
tip.  However, if you adopt a soft fork with a very small minority of the
hashrate, in this case BIP110 has under 1% of the hashrate right now, this
effect doesn't hold.  You start enforcing your new rules and you're off on your
own chain tip that follows those rules.  But everybody else who's ignoring
those rules keeps building blocks that don't adhere to those rules.  And they,
in this case, find about 99 or more blocks on average, while you find a single
block.  So, after a day, they'll be about 140 blocks ahead.  They will have
more work on their chain.  There is no reason for them to ever reorganize to
your chain tip, because they would be losing on out on 140 blocks' worth of
block rewards.

So, if you are trying to attempt a soft fork that does not have broad support,
and does not have the majority of the hashrate, the soft fork creates a similar
chain split as a hard fork does, where you restrict yourself to these new
rules, but nobody else's, and you're off on your own network.  And this is
pretty much what almost all the developer community sees happening here, is
that BIP110 will fork itself off with a minority hashrate.  And then, after
getting about one block per day, they will probably change their PoW to
something else, or have a difficulty adjustment, because one block per day is
not sufficient blockspace to have a network running.  And then, of course,
because the mandatory signaling starts at the start of a difficulty period,
they will have to get through 2,016 blocks for the difficulty to adjust.  And
even then, it will only adjust up to a factor 4.  So, if they fork off with
less than 1% of the hashrate, we can anticipate that it takes not two weeks,
but roughly 200 weeks to reach the first difficulty adjustment, and then
another 50 weeks for the second difficulty adjustment, and so forth.

So, unless suddenly they conjure up a lot more hashrate support for the BIP110
fork, this is dead on arrival, which is why nobody has to actively oppose it.
It'll just stop itself.

_How to set up Bitcoin Core to mine a valid block after the BIP110 activation in August 2026?_

**Mike Schmidt**: Another question in a similar vein, how to set up Bitcoin
Core to mine a valid under-BIP110-rules block for August.  I guess the time
frame doesn't necessarily -- but if I wanted to use Bitcoin Cash to mine a
BIP110-compliant block, obviously I could mine an empty block, which would be
compliant.  But how would I go about sorting out my block to fulfill these
rules using Bitcoin Core?

**Mark Erhardt**: Right.  So, there's two different phases here.  There's first
the mandatory signaling phase in which blocks are required to set bit 4 in the
version in order to signal that they now support BIP110.  This is going to
happen exactly two difficulty periods before the last possible activation of
BIP110.  So, anybody running the reduced data, temporary soft fork software,
BIP110, or the latest, Knots also supports it, will only accept blocks at that
height, that signal for activation.  So, if someone were to modify their
Bitcoin Core or try to find a block with Bitcoin Core, they would have to find
a way to set that bit in the version.  And I don't think that there is a
configuration option for that.  They'd have to modify the source code,
recompile and rebuild, and then they could use almost vanilla Bitcoin Core to
build a block that signals.

After activation, which is roughly two difficulty periods later or never, they
will enforce seven new consensus rules on transactions, which include a limit
on output scripts, a limit on OP_RETURN outputs, a limit on OP_IF not appearing
in tapscript, and script trees being at most a depth of 7, or up to 128 leaves.
And there's a few others that basically just forbid upgrade hooks that are
currently present in Bitcoin Core after hard work for many years.  And so, you
would have to either manually filter those transactions that are not in
compliance with the new rules -- again, we're speaking about a hypothetical
scenario here, just to be clear -- or you just mine empty blocks, because empty
blocks will not have any transactions that injure any of these rules.  So, if
you want to mine with Bitcoin Core, you'll have a tough time during the
mandatory signaling.  And after activation, probably the easiest is to just
mine empty blocks.

_Are BIP110 blocks on a branch with lower difficulty valid?_

**Mike Schmidt**: Next question from the Stack Exchange, "Are BIP110 blocks on
a branch with lower difficulty valid?"  Maybe some terminology here, Murch.
How do we think about branches and how does that manifest itself on my nodes
file system, and things like this?

**Mark Erhardt**: Right, this is a very frequent source of confusion regarding
splits or chain forks, right?  So, I'm not talking about a soft fork or a hard
fork, but just two different chain tips existing in parallel.  So, a valid
block is always considered within its own history, "If this were the best chain
tip, would Bitcoin Core accept it?"  That is a valid block.  Or, sorry, any
Bitcoin software that is compliant with whatever rules you're trying to test,
right, and not just Bitcoin Core.  However, obviously the point of the
blockchain is for the entire network to pick one history, one version of the
truth and to coalesce on one ground truth in the network.  And we do this by
reorganizing to the best chain tip that we're aware of.  So, 'best', it means
it has to be valid, which we discussed.  And the other one is it is the most
PoW chain tip that we know of, and valid at the same time, obviously.

So, the confusion here is people look at one chain tip and then try to evaluate
the other chain tip from that perspective.  And the same question often comes
up with the context of, "Oh, what if my transaction is confirmed in one chain
tip?  How can it also be confirmed in the other chain tip?"  Well, from the
point of the chain tip or a node that is on that chain tip and considers it to
be the best chain tip at that time, they only see a chain of blocks back to the
genesis block that is single file, there are no branches in it.  The best chain
is just one block per height.  And in the history that leads up to that block,
if a UTXO is unspent, it's spendable at that time.  And it's perfectly fine for
a competing block to also have the same transactions in it.  Because if you
were on that competing block and evaluating the chain as if that was the only
relevant block at that height, it'll also be allowed to spend the same UTXOs,
or TXOs at that point, in that block.

So, if you were now in a scenario where Bitcoin had found several hundred
blocks more than an RDTS fork -- or actually, we need thousands of blocks, the
difficulty has reset, they now have a lower difficulty chain tip -- they could
even have more blocks at that point maybe if they don't have more total work,
their chain tip will look valid to Bitcoin Core, but not attractive because it
doesn't have the most work.  So, yes, if there were a permanent split in the
network and there were two persisted chain tips, and one probably has a lot
less work, then that would look valid to Bitcoin Core, but there's no danger of
reorganizing to it because it doesn't have the most work.

**Mike Schmidt**: And does that mean a Bitcoin Core node, you gave the
hypothetical earlier of these 200 weeks of slow blocks, would Bitcoin Core
then, assuming it's connected to a node which would relay these 110 blocks,
would it then be storing that chain as well in parallel?

**Mark Erhardt**: By default, we will store headers that we hear about, but we
will only download blocks that are at the same height as our best chain tip.
So, if there were a split and there were two blocks at the same height, we
would download the block and store it in our block files.  If it's back a few
hundred blocks, if we hear about the chain tip, we would remember the chain tip
header, but not the block itself.

**Mike Schmidt**: Okay.

**Mark Erhardt**: And of course, in the theoretical situation that they get
through their difficulty adjustment, it activates after two more difficulty
periods after mandatory signaling, and now their difficulty has gone down by a
factor of 16, and now some hashrate switches over and they suddenly start
racing through blocks and catch up in height.  Even if they have a higher count
of blocks, that doesn't necessarily mean that they have more work on it.  It is
simply the weight of the blocks calculated by their difficulty and their count.
So, if one chain were progressing at 16 times the difficulty, that would still
make up for 16 times more blocks on the lower difficulty chain.  So, this was
actually a bug in the original release of Satoshi, who conflated the height for
most work, and the original release was vulnerable to low difficulty chains.
So, if someone were today still running the original release, and were
following the Bitcoin blockchain, if someone just created a difficulty 1 chain
from the genesis block, they could reach a higher height for very little
computation and the original block would have accepted that and reorged away
from our current best chain tip.  But that was fixed very, very early, and now
we follow the chain with the most work.

**Mike Schmidt**: Most valid work.

**Mark Erhardt**: We will only ever accept a valid chain.  And then, among all
the valid chain tips, we will pick the one with the most work.

**Mike Schmidt**: So, on the on the 110 side, they would not keep the headers
for the Bitcoin non-110 chain.

**Mark Erhardt**: Right.  So, Bitcoin blocks would look invalid to RDTS nodes
because they're not signaling.  So, I had an interesting idea here.  If we get
an invalid block or an invalid transaction from a peer, I thought that we might
disconnect that peer.  So, I figured that once the first non-compliant block,
so the first block that doesn't do mandatory signaling for 110, we'd find, we
would get a topology split where all the 110 blocks would go off in one
direction and disconnect all their Bitcoin peers because they don't accept
them.  But I was corrected.  Supposedly, RDTS has a special rule that allows
Bitcoin blocks to be accepted and stored, and not disconnect the peers.  So,
the topology will not split immediately.  But yeah, so RDTS nodes will probably
download and store Bitcoin blocks, or at least not disconnect their peers.  But
honestly, I can't be arsed to look at the code.

_What is the story behind Bitcoin test networks?_

**Mike Schmidt**: "What is the story behind Bitcoin test networks?"  This is
you and Antoine tracing the history of testnet from testnet1 through the
proposed, and covered, and should have been linked in this answer, testnet5
from Newsletter #409.  I should have put that link in there.

**Mark Erhardt**: Yeah.  So, we heard about a proposal to add a testnet5.  The
problem here is, of course, that testnet4 has had all these parallel chain tips
because I think through the launch of testnet4, a lot more people learned about
the difficulty exception rule.  So, on testnet4 and also every testnet since
testnet2, there was an exception.  If the timestamp since the last block had
increased by at least 20 minutes, the difficulty of the new block had be
minimum difficulty, which means that you can just tweak the timestamp and then
mine a difficulty 1 block and it will be accepted by the network on testnet,
right?  The idea was that this would enable developers at home to mine blocks
that contain non-standard transactions if they're, for example, testing a soft
fork proposal that introduces a new opcode, or to get a few testnet coins in
order to be able to test on testnet.  As all these testnets over time tend to
get monetized, where people then start trying to acquire a lot of testnet coins
and selling them to developers so developers can test, this on the one hand, to
be fair, makes it much easier to get testnet coins because you know where to
look, but more expensive.  And it also sort of undermines the incentives of
faucets to just give away testnet coins.  It also makes it harder because now,
everybody is mining these difficulty exception blocks and that raises the time
horizon of the blocks to two hours into the future, which is the maximum that
Bitcoin nodes will accept on timestamp flexibility.

So, yeah, testnet3 had these block storms, as they were called, where someone
would reset the difficulty of the last block in a difficulty period to one per
the 20-minute exception.  And then, the next block would recalculate the
difficulty and basis of the last block's difficulty.  And because that was 1,
it would be a difficulty between 1 and 4 for the next difficulty period.  And
then, of course, difficulty 1 or 4 is fairly trivial.  That's a few megahash or
something, something you can do on a very old laptop in a few minutes, and the
next 2,016 blocks would flash by if someone had an ASIC pointed at testnet.
And then the difficulty would quadruple, and the next 2,016 blocks would flash
by, because it was still way below what an ASIC could do, and so forth.  And
you would get thousands of blocks in minutes until the difficulty had risen
again to a higher level where blocks slowed down.  And some people, to
demonstrate how bad this vulnerability was, just sustained difficulty 1 blocks
for a long period of time.  And testnet3 is past its 10th halving.  The block
reward is like 546 sats now.  So, testnet3 became basically unusable.

Testnet4 was rolled out, removing the block storm vulnerability by always using
the first block's difficulty, which is fine because the difficulty is the same
for an entire difficulty period.  So, it doesn't really matter whether you
calculate from the last block or the first block.  Calculating from the first
block was safe however, because when the difficulty adjusting the exception was
introduced in testnet2, they did realize that the first block should be exempt,
because it sets the difficulty for the entire difficulty period.  So, by
recalculating the actual difficulty on basis of the first block of the previous
difficulty period, you at least kept tracking the actual difficulty, even if
there were some blocks mined with the difficulty exception at a lower
difficulty.  However, people much more aware of this exception now started CPU
mining testnet4.  And basically, every time a block was found with actual PoW
at the actual difficulty and a current timestamp, there would be immediately
six more blocks that go 20, 40, 60, 80, 100, and 120 minutes into the future.
And now, the timestamp is two hours in the future, and no minimum difficulty
exception block could be mined.  And because so many people did that, there
would be dozens of blocks at each height in parallel, and there were constant
reorgs on testnet4.  And then, of course, it also got monetized almost
immediately again.

So, new testnets will continue until we find one that is usable by developers
for a bit.  Testnet5 now is being approached as, "Let's get rid of the
difficulty exception".  Clearly it's not worth the effort right now anymore.
You will need a small ASIC or something to mine a block on testnet5.  This will
allow people, miners, to test their mining hardware, whether it's set up
correctly and so on, but it will no longer enable developers to mine a block at
home.  And I guess if it gets monetized again, we'll just roll out testnet6 in
a few years again, or maybe we're done with testnets, who knows.

**Mike Schmidt**: I maintain that the likely outcome of a testnet5 is not that
it gets monetized, but that it gets bricked by somebody spending a few thousand
dollars on cloud hashrate to ramp up difficulty and then pulling the plug on
it.

**Mark Erhardt**: Yeah, that would cause it to be in a similar situation as we
expect RDTS to be in, where the difficulty is a hundred times what the hashrate
supports and it'll take forever to reduce the difficulty again on testnet5.
So, yeah, that is a possibility that someone trolls testnet5.  That could be
maybe mitigated if some benevolent miner points a little hashrate at it until
the difficulty goes down again.  But I don't know.  Maybe signets and private
testnets are sufficient now.  But who knows?  It's just a tragedy of the
commons, basically.  People started monetizing the testnets, and now testnets
are basically unusable for developers.  Great job.

_Why was `-datacarriersize` redefined in 2022, and why was the 2023 proposal to expand it not merged?_

**Mike Schmidt**: Well, that was a good bit of testnet lore.  We have
additional lore to jump into here, "Why was -datacarriersize redefined in 2022,
and why was the 2023 proposal to expand it not merged?"  So, not only are we
revisiting a question that was asked last year, it was asked about events from
the few years prior.  And, I guess, the answer/evidence on either side comes
from even years before that.  So, how do you think about this question, Murch?

**Mark Erhardt**: So, the reason why OP_RETURN was standardized as a thing in
the first place was because people were putting data into payment outputs by
reusing the hashes in P2PKH and the hashes or public keys in P2PK and P2MS, or
I guess you could also do it with paid to scripthash.  And so, there were
several ways known of how to embed data into Bitcoin, and writing it to payment
outputs produces UTXOs that will never be spent, because clearly nobody
actually knows a key that hashes to the hashes that someone put into the
blockchain in order to store data in them.  And yeah, so the idea was blocks
were maybe a seventh full.  I think the common block size was about 140 kB or
so, so block space was abundant and cheap.  People putting data into P2PKH
outputs could have bloated the UTXO set pretty drastically if it had taken off.
So, people were like, "Okay, we don't love the data embedding, but please put
it into OP_RETURNs.  At least we know OP_RETURNs are always unspendable and we
can prune them from the UTXO set, we don't have to keep them around in the
minimum state for a full node.

Fast-forward to 2022, or something.  The two configuration options,
-datacarrier and -datacarriersize, always had been referring to outputs that
start with the OP_RETURN opcode, and then push one data push of data
afterwards.  And someone introduced a PR to Bitcoin Core to properly
communicate what output script this configuration option applies to, because it
had been applying to that for eight years.  So, documenting in your description
of configuration options what a configuration option does is just very standard
cleanup work.  However, in the same year, some people started to redefine
history and said, "Oh, -datacarrier always referred to all forms of data
carrying.  And therefore, this configuration option was always supposed to
refer to any forms of embedding data into the Bitcoin blockchain, and clearly
changing the configurations documentation to refer only to OP_RETURN is now
changing the documentation away from the intended purpose".  I think this
narrative is incredibly silly and it is reinventing history in order to give
more credence to Luke Dashjr's PR to Bitcoin Core that tried to apply the
-datacarrier configuration option also to inscriptions.

One of the first feedbacks he got was, "Why don't you introduce a new
configuration option for inscriptions, and then that might make sense?  People
can then configure inscription limits differently than -datacarrier or
OP_RETURN limits".  That was right after the feedback, "Maybe add some tests".
So, it's just, I'm sorry that Stack Exchange seems to be turning into a
fact-checking website, but if you look at the release notes of 0.10, it's quite
clear that it refers to OP_RETURN outputs.  Multiple other ways of embedding
data were known at the time when OP_RETURN was introduced.  So, it's not an
oversight that the release notes explicitly refer to OP_RETURN outputs as
-datacarrier outputs.  And if you are going to go and reinvent history eight
years later, that it always meant something else than it had been meaning for
almost a decade, that just needs to be laughed out of the room, thank you very
much.

**Mike Schmidt**: Yeah, I mean I think you went through the history, but I
think it's widely, I guess, known or regarded that, yeah, OP_RETURN was the
place where the garbage went, because there was garbage in these other places,
right?  And so, okay, put it there.  And so, I guess it would be weird to then
have -datacarrier cover these other things.  Clearly, there were other things
at the time, right, because that's the reason that things were standardized on
OP_RETURN.  And so, when the limit was then put in place, it was put in place
in an era where these things were known, I guess, would seem the most
straightforward.

**Mark Erhardt**: Yeah, so because blocks were only a seventh full with 140 kB,
of course you have the problem that you can, for minimum feerate, fill the rest
of the block with data, right?  So, putting a limit on it just was reasonable
back then so that the blocks wouldn't be filled up and the blockchain wouldn't
grow faster than monetary use would have implied.  It was also limited to a
single output at that time, because at least that added a little overhead, you
had to make a whole other transaction.  There was a very strong dominance by a
single software project for the node implementations at that time.  Everybody
ran that.  And this gentleman's agreement to not propagate OP_RETURNs that were
larger or transactions with multiple OP_RETURNs held for a very long time.  And
that is fortunate.  In the last few years, block space has been almost fully
demanded throughout.  So, limiting OP_RETURN outputs is no longer a means to
reduce the growth of the blockchain.  In fact, inscriptions using the witness
discount would add about four times more data in inscriptions for the same
blockspace.  So, people, if they were to use OP_RETURNs instead, would grow the
blockchain more slowly than what they had been doing with inscriptions.

So, maybe also in 2014, when OP_RETURN was introduced, the OP_RETURN offered a
cheaper way to embed a little bit of data than putting it into P2PKH outputs or
a multisig, because you not only tell people, "Hey, please put the garbage in
the bin right here", because that would not be a compelling instruction,
especially if you label it a garbage bin; but there's an economic incentive to
use OP_RETURN.  It became a standard output, so these transactions would
propagate fine, and it would be cheaper to put data there than to put it into
P2PKH outputs.  So, people were incentivized to use it for that purpose if they
really had to, 'had to' as in choice, but nobody was excited about that.  But
it mitigated an issue by providing an incentive to do the right thing, an
economic incentive.

Fast-forward today, we've had inscriptions on the network for a few years,
blockspace has been almost fully demanded.  Spam or data transactions currently
pay about a quarter or less in feerates on average than monetary transactions.
So, you can think of it as just buying the leftover blockspace that is
under-demanded.  Clearly, this is not an economically or as economically
motivated use case as monetary transactions right now.  So, if blockspace is
full all the time, making the OP_RETURN output a little more attractive doesn't
increase the blockchain growth because it takes more blockspace per data to put
there, and it seemed completely safe.  And for some reason, we're still
debating this very simple fact two years later.

_Are chains of 26 unconfirmed transactions prohibited by the wallet in Bitcoin Core 31.0?_

**Mike Schmidt**: "Are chains of 26 unconfirmed transactions prohibited by the
wallet in Bitcoin Core?"  This is referring to the ancestor/descendant limit,
right, Murch, and the fact that the previous architecture of the mempool, I
guess, scaled poorly with the number of ancestors or descendants, which was
improved with cluster mempools, so now there is no such ancestor/descendant
limit on Core that supports cluster mempool.  So, the question then is, can you
create a transaction in Bitcoin Core that exceeds those previous limits?

**Mark Erhardt**: So, cluster mempool changed the limits from ancestor and
descendant counts and descendant size limits and ancestor size limits to
cluster count and cluster size limit.  So, the clusters are still limited to
101 kvB (kilo-vbytes), just like the ancestor sets and descendant sets had
been, but the count increased from 25 to 64.  This limit is fully adopted by
recent versions on the node side.  It has, however, not been introduced into
the Bitcoin Core wallet yet.  So, if you're building a chain of transactions on
the Bitcoin Core wallet, for example, a eel chain, or just, I don't know,
sending around funds to yourself, then you will still bump into this 25 limit,
because the Bitcoin Core wallet is catching, "Hey, this is a very long chain,
and by the ancestor/descendant limits, this looks like it'll not go into the
mempool.  So, we're not going to create that for you now and throw an error".
You can, however, absolutely create such a chain of transactions with Bitcoin
Core, just not with the wallet.  Or actually, you could.  You can configure a
higher ancestor limit in the configuration of the wallet.  If you set the limit
to 64, you can of course continue to create long chains of transactions, even
with the Bitcoin Core wallet, per a configuration option.  But you could also
just do it by creating transactions through the node side, not the wallet.  And
then, it would work perfectly fine to send 64 transactions.

So, for example, if you have an external software that creates transactions or
a companion wallet, or something, if that had adopted a higher chain limit and
then submitted such a chain of transactions to a Bitcoin node, it would totally
work.

_Are there changes in Bitcoin Core 29.0 that affect memory usage?_

**Mike Schmidt**: "Are there changes in Bitcoin Core 29.0 that affect memory
usage?  Antoine answered this one and I'll, I guess, paraphrase here and,
Murch, you can clarify.  But it sounds like in Bitcoin Core 29.0, maybe Bitcoin
Core is a little bit greedy about grabbing potential cache space if it's
available, and then releasing that when other processes need it.  But it
doesn't necessarily mean that it's using all of that, it just wants to have it
available.  Do I have that right?

**Mark Erhardt**: Yeah, that's how I understand this.  So, I haven't looked too
deeply into this, but my understanding is that you can sort of label how you're
using memory and you can sort of label it low priority or high priority.  And
then, if other processes come in and want high priority RAM, they will just
oust other usage.  So, Bitcoin Core just allows the chainstate caching to use
more RAM on low priority, and if higher priority use of the memory comes along,
it gets freed up.  And that means that Bitcoin Core over-reports on how much
memory it's using, but it's really memory that will be freed up if other
processes come along.  There was also an issue where the compaction of the UTXO
set would take more memory in the recent version, because we changed the
flushing of the UTXO set from once per day to once per hour.  And apparently,
LevelDB's compaction would then take more memory over time.  And this is fixed
in the upcoming version, and there will be backports to fix this.  So, I think
it'll be fixed in 31.1, which we have an RC for now.

_What is Bitcoin Core's release schedule?_

**Mike Schmidt**: "What is Bitcoin Core's release schedule?"  Murch, I've seen
some chatter about this, which is quite baffling to me, because I think this
schedule's been in place for quite a while.  I know you can clarify the
details, but the six-month cadence, it does seem that maybe some of the
misconception around this, at least that I've seen online, is maybe folks have
largely not been a part of, or following, Bitcoin Core or their releases, and
now all of a sudden they see one and then they see another and it seems like
it's accelerating, whereas maybe they only saw them every few years when there
was a highly notable feature or a soft fork, or something.  And now, they're
looking at it closely and maybe they're thinking things are speeding up.  But
do you want to add any nuance to that?

**Mark Erhardt**: Yeah, it seems this classical effect where when you never
notice something before, once you notice it for the first time, you see it
everywhere.  And I think that a lot of people were just never really following
Bitcoin Core development that closely.  And now, with the filter movement and
BIP110 and so on, suddenly this is starting to become part of what people talk
about every day.  And then, they start paying attention to more things and
suddenly they see like, "Wow, these Bitcoin Core releases are coming awfully
fast now".  Well, Bitcoin Core has been releasing a major version every six
months for, I don't know, like ten years.  There was a slight change in the
cadence recently.  The definition used to be that after a release, we would
schedule the next release six months after.  And so, there would be a branch
off and a feature freeze, and so on, before that date.  But the targeted date
would be roughly six months after the previous release.  And then sometimes, if
there were more RCs than usual, the date would shift backwards.  So, over time,
the date would drift by a week or two, and we would sometimes reset it a little
earlier so we wouldn't get into the holiday season.  And now, we have a fixed
schedule where the new release is not six months after the previous release,
but it's early April and early October, which prevents the shifting by a week
or two occasionally.

So, yes.  Bitcoin Core releases a major version, the one with the new features,
every early April and every early October.  And then, if there are bug fixes or
backports or maintenance releases, they come in with the minor version bumped
and they come out as needed.  So, you will usually see the new major branch
come out and then also maintenance releases for the prior two branches or prior
three branches.  And yeah, we usually see, I don't know, a handful or so minor
releases between each major release for old and the current branch.

**Mike Schmidt**: That wraps up the Stack Exchange segment for this week.
We'll move to the Releases and release candidates and Notable code and
documentation changes with Gustavo.  And I missed something.  What's up, Murch?

**Mark Erhardt**: No, just we haven't had anything on Stack Exchange for a long
time and being someone that has contributed to that QA page for a very long
time, I'm really excited that people have been asking more questions, even if
it's a little bit fact-checky right now.  Someone still has to feed the LLMs.
So, if you have good questions or you are dissatisfied with what Claude is
telling you about Bitcoin, please know that people are still looking at Stack
Exchange and you can get expert answers on that website by asking a
well-formulated question after doing some of your own research.

**Mike Schmidt**: Gustavo, the floor is yours.

**Gustavo Flores Echaiz**: Perfect.  Thank you, Murch.  I learned a lot of
things.  That was very interesting.  So, we start with the Release and release
candidate section.  This week, we have two releases from the LDK repo plus one
from BTCPay Server.

_LDK v0.1.10_

So, first, LDK has now released version 1.1 and 2.3 So, these are both
maintenance releases.  They're quite similar.  Yes, sorry?

**Mark Erhardt**: This is 1.10 and I think that's very important.  So, the 10th
maintenance release on the 0.1 and the third maintenance release on 0.2.

_LDK v0.2.3_

**Gustavo Flores Echaiz**: Totally.  That is 1.10, thank you for specifying
that.  So, both of these are maintenance releases with a few bug fixes.  The
difference between them is that 2.3 has some additional fixes related to
features that were in the v2, such as zero-fee commitment channels, splicing,
or even the implementation of the LSP specification.  But other than that,
other than the specific features that are targeted to new features that were
part of the v2, they're quite similar in the sense that they fixed some things.
There are also API updates, such as one we covered, where when you generate a
blinded message path, it will no longer use a different node as an introduction
node.  So, there's no longer receiver privacy for BOLT12 blinded message paths.
And as we had discussed in a prior episode, this was because LND had released
onion message forwarding, but without being able to forward BOLT12 messages
from unknown third parties, which is exactly how this would work if those LND
nodes would be chosen as the introduction nodes in those blinded message paths.
So, that's one of the biggest API updates, but there are also multiple other
bug fixes.  So, if anybody's interested in details, there's quite a lot there
and they can take a look at the release notes.

_BTCPay Server 2.4.0_

The other release we have this week is from the BTCPay Server repository.  This
is a main release, so not just a maintenance one.  And it includes multiple new
features, such as the one we covered last week or two weeks ago related to a
new way to set up a multisig wallet.  So, instead of you as a user setting up
the multisig wallet fully by yourself, you can now coordinate the setup of the
multisig wallet with multiple users of the BTCPay Server.  So, each one can
upload his own key and BTCPay Server coordinates the whole thing.  Another
thing that was quite interesting is the addition of passkey authentication to
BTCPay Server.  So, passkey is becoming a standard on how to authenticate to
web applications.  So, BTCPay Server has now shipped it as part of this
release.  This is an addition of already supporting passkey for two-factor
authentication, but still requiring a password logging.  So, now this new
feature allows for fully passwordless passkey authentication.

There are other features included.  So, anybody that has interest to that, they
can take a look.  But in general, we're talking about more granular wallet
permissions, improvements to the subscription and point-of-sale features, and
like I said, passkey authentication and a better multisig wallet setup, and
multiple other things as well related to Lightning support, and the removal of
several deprecated Lightning backends known as LNBank and Lightning Charge.
Those Lightning backends are no longer supported.  And also, if you use a
Boltcards Extension or Shopify v2 plugins, you will need to upgrade to the
latest version of those plugins when using this new version.

_Bitcoin Core #35070_

So, those are the releases of the week, and now we can move forward to the
Notable code and documentation changes.  This week, also light as the one
before, but we start with Bitcoin Core #35070.  Here, this is a very specific
edge case that only occurs when you have a pruned node, a node that has pruned
a lot of its ancestor block data, and you face a deep reorg that goes back to a
block that you had pruned.  Plus, not only that, when you are reconciling --
so, excuse me, let me take a step back.  So, when you get the new block that
you receive, you will put it into this internal structure called
m_blocks_unlinked.  The block is kept there until you reconstruct all its
ancestors and you can connect it to the chain, right?  So, while you are
downloading those new blocks, while you're reconstructing, there could be a
second fork in the road.  So, in this new chain of the reorg, there are
potentially two block candidates.  So, when you process each block candidate of
this new chain, you could accidentally add duplicate entries of the same block
to the structure called blocks_unlinked.  And when adding twice the same block
to this internal structure, later on, once you have downloaded all the required
blocks to connect it to the chain, you would reconsider the same block twice
and this could potentially lead to undefined behavior.

So, the fix here is to ensure that you never duplicate an entry in the internal
structure for unlinked blocks.  And so, for example, AddUnlinkedBlock is a new
helper that is added to deduplicate entries, plus CheckBlockIndex() in is also
strengthened to ensure that duplicate entries are never present.  Yes, Murch?

**Mark Erhardt**: Sorry, I've been spacing out a little, but did you say at
what depth of reorg this happens?  You're muted.

**Gustavo Flores Echaiz**: Yeah, excuse me.  It doesn't necessarily say, from
my understanding, the depth, but it would have to be a very long reorg for your
pruned block to be unable to connect the block to the blocks you have, right?

**Mark Erhardt**: Let me jump in there then.  So, the minimum prune depth that
a Bitcoin Core node will accept is 288 blocks, so about two days of blockchain.
So, if you have a full node running with the minimal prune size, you would have
to accept experience a reorg of almost 300 blocks in order for this bug to have
an effect.  Anyone that has lower prune heights would not be affected.  Sorry,
like, keeps more data around.  Anyone that runs a full node would not be
affected.  But so, I think if we had a reorg of several hundred blocks, people
would probably stop believing in confirmations.  This could, for example,
happen, tying it back to earlier topics here, if hypothetically BIP110 did
activate at some point, and then all the hashrate switched over and the entire
Bitcoin Core lead would be reorged out.  But I guess I'm speaking for myself
here, but I don't think it would be a very interesting thing to work on if
stuff like that were happening on the Bitcoin Network.

So, generally, I think if there were reorgs on the Bitcoin mainnet in this day
and age, we've had some, I think the biggest one was in 2015 on the 0.86
release.  There was an accidental incompatibility between 0.86 and 0.85, where
the databases behaved slightly differently, that a database under the hood was
switched out, and then miners mining on the new version created blocks that
wouldn't be accepted by old nodes, and this caused a fork in the network.  I
think that was, I want to say, 36 blocks were reorged out.  But again, that was
when Bitcoin was tiny and the exchange rate was very low.  If we had something
like that in today's day and age, I believe that people would very much be
shaken in their belief in confirmations and the reliability of the Bitcoin
Network.

**Gustavo Flores Echaiz**: Right, totally.  So, yeah, this is a very
theoretical edge case, right, where hundreds of blogs get reorged.  And not
only that, then there are two potential candidates; from that new chain, two
potential candidates emerge, right?  So, when considering these two potential
candidates, that's when this bug occurs.  So, anyways, the fix is simply when
you have unlinked blocks, Bitcoin Core ensures that the same block doesn't get
duplicated in this internal structure, so it doesn't lead to undefined
behavior.

**Mark Erhardt**: Yeah, I was just jumping in here because I've seen some
reports about this topic in other venues, and people hadn't picked up on the
reorg depth being a requirement.  So, it sounded more like a scary thing in a
reorg, there might be undefined behavior.  This is in a reorg that we hopefully
will never see and shouldn't ever see.

**Gustavo Flores Echaiz**: Right, exactly.  So, the next item we covered at the
beginning of the podcast, Bitcoin Core #35182 and #34411, where the
libevent-based HTTP server is replaced by an internal implementation.

_BIPs #2198_

The next one is BIPs #2198, which is an update to BIP360.  So, Murch, I believe
you are the BIP repository editor, so you maybe want to jump in here.

**Mark Erhardt**: I am the BIP repository.  No, I'm a BIP editor.  So,
actually, this one I hadn't looked too much at.  Another BIP editor handled
this one first.  So, this modifies P2MR, or BIP360.  One of the concerns people
had with the BIP360 proposal was, we talked a little bit already about control
block earlier in this recording.  So, when you use the scriptpath in P2TR, as a
reminder, you reveal the leaf script, and then you have to prove that the leaf
script was committed to, the leaf was in the script tree.  And you always do
that by showing the internal key, which is a public key, that was tweaked by
the merkle root of the script tree.  So, you can tweak a number into a public
key that produces a new public key, the external public key, the one that you
see on the blockchain in the output script.  And that tweaked key is the
product of an internal key, which is an actual key the output script creator
picked and tweaked with the tree of the scripts in the script tree.

So, one concern was if you don't have a keypath spend, as you don't in P2MR,
you would be able to have cheaper leaf scripts.  So, specifically in P2TR, if
you have a keypath, even if you had a leaf at depth-zero, you would always have
to reveal the internal key, which adds 32 bytes, I think, 33 bytes maybe.  I
let this resolve by commenters.  Anyway, you have to reveal some extra bytes.
So, people were concerned that if P2MR were adopted, as it had been proposed,
people that don't want the keypath, but always use the scriptpath for their
schnorr-empowered leaf scripts, would switch to P2MR not for post-quantum
security, but to save the bytes that you need to reveal the inner key for a
smaller control block.  So, conduition proposed here hey, "How about we never
allow use of the depth-zero leaf in the script tree?  We make the depth-zero
leaf an OP_SUCCESS, basically".  If you use a depth-zero leaf, it is always
ANYONECANSPEND with rules to be added in the future to restrict it further as
an upgrade hook, essentially.  So, if you were to use P2MR, you would always
have to go to depth-one, which adds a bigger control block and removes one of
these economic incentives to switch to P2MR for legacy usage with schnorr
signatures instead of PQ.

The idea is all of the schemes that we have been discussing so far for
post-quantum security, the signatures and public keys are much, much bigger
than those of schnorr and ECDSA signatures.  So, presumably adding 30 bytes to
3 kB is not much of a problem, whereas the incentive of moving over to spend
script-paths, when your control block is 32 bytes or 33 bytes smaller, might be
quite significant.  So, it sort of tries to preserve the signal.  If people use
P2MR, they are using P2MR in order to be PQ safe, or I should say quantum-safe,
quantum-resistant better maybe, not post-quantum, but you know what I mean.
And so, it would make P2MR use more of a signal that people are switching to
PQ-safe outputs rather than saving money with their scriptpaths.

_LDK #4713_

**Gustavo Flores Echaiz**: Precisely.  Thank you, Murch.  Very interesting edge
case here, well, incentive consideration here.  So, a good fix for that.  The
two last items are from the LDK repository.  The first one, #4713, adds what is
called DoS hardening for Rapid Gossip Sync (RGS).  So, LDK has this function
called RGS which allows a light client, or just an LDK node, to obtain gossip
data but without going through the P2P protocol.  So, if you want to obtain the
channel announcements, or the latest state of the channel announcements,
instead of having to go through the P2P gossip network, you can obtain it from
a trusted or semi-trusted server, and you will skip verifying the signatures,
even validating the funding transactions for these channels.  So, you're
trusting the server to have already validated all that and to have processed
all the previous states, and you simply receive a snapshot of the latest date.
And this allows you to sync faster with the LN.  However, there could be
potentially a RGS server that could be malicious and send you nonsensical
information.

So, two things are done in this PR.  First one is simply updating the
documentation to warn that this server is semi-trusted and they could prevent
omitting data, and also attempt to bloat your network graph.  So, one of the
things done is the updated documentation, but the real functional change is
some values are now hardcoded inside LDK for the expected number of channels,
or the expected number of nodes as well.  And when you download the snapshot of
data from the RGS server, basically LDK will reject snapshots that are sent
with counts that are absolutely nonsensical.  And the way it's able to do that
is by comparing it with the new hardcoded values that are now shipped within
LDK.

_LDK #4684_

The next item, LDK #4684, fixes a very rare edge case, where when an LDK node
disconnects and then reconnects, and specifically an asynchronous signer is
used, LDK has to send a revoke_and_ack message to its peer to update the state.
However, if it uses an asynchronous signer, this message will basically be
blocked until it receives a response from the asynchronous signer, and it will
send a message then.  However, LDK could also be thinking that, excuse me, if
the channel monitor update hasn't finished, so LDK, before sending
revoke_and_ack, ensures that it is basically protected for recovering funds
from this channel through an onchain action, so it's monitoring the channel and
monitoring specifically how it could react in a different edge case to protect
itself.  So, this is why it's called the monitor-restored path.  So,
previously, LDK could send twice the revoke_and_ack message, first when it
receives the response from the asynchronous signer, and then when it receives
the response from a channel monitor.  So, now the fix is to ensure that LDK
would simply send revoke_and_ack once, because else it could cause the peer to
reject this duplicate secret and foreclose the channel.

So, anyways, that's the last item of this section, and that completes the
newsletter for this episode.  Thank you.

**Mike Schmidt**: Excellent.  Thank you, Gustavo.  Well, it ended up being a
longer one than I think we thought today, but thank you all for continuing to
listen.  Thank you, Gustavo, for doing the Notable code and Releases section,
Murch for co-hosting, and we want to thank our special guests.  We had Nishant
on, as well as Matthew Zipkin.  Hear you next week.

**Mark Erhardt**: Yeah, thank you very much for your time.  And I mean, if you
made it here, I guess you're welcome.  Cheers

{% include references.md %}
