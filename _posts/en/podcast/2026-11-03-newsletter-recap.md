---
title: 'Bitcoin Optech Newsletter #429 Recap Podcast'
permalink: /en/podcast/2026/11/03/
reference: /en/newsletters/2026/10/30/
name: 2026-11-03-recap
slug: 2026-11-03-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt, Gustavo Flores Echaiz, and Mike Schmidt are joined by
Elias Rohrer, Greg Sanders, Antoine Poinsot, Oleksandr Kurbatov, and Nishant
Bansal to discuss [Newsletter #429]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-10-4/435869989-44100-2-248ad2ebb85f3.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #429 Recap.
Today, we're going to talk about three Bitcoin Core security advisories; we have
Bitcoin Core's security policy update as well, which came in handy or
potentially came in handy; Bitcoin Core 32.1 release, plus three point releases
that shipped alongside it; there's a protocol for making silent payments for
multiparty wallets; we have discussion of a responsible disclosure in Core
Lightning (CLN) from a channel announcement that triggered a crash; we have our
monthly segment on the Stack Exchange, and we have our weekly Notable code and
Release segments as well.  We have a full house today.  This week, Murch,
Gustavo, and I are joined by a few folks.  We'll have them introduce themselves
briefly.  Elias?

**Elias Rohrer**: Hi, I'm Elias, I'm with Spiral working on LDK, but also on
Project Loupe.

**Mike Schmidt**: Greg?

**Greg Sanders**: Hi, I'm Greg, I'm also at Spiral.  I work on a mixture of
things, including Bitcoin Core and other layer 2 stuff.

**Mike Schmidt**: Oleks?

**Oleksandr Kurbatov**: Hey, Oleks, Blockstream Research.  The majority of my
time, I'm working on PQ stuff, but today it's a different one.

**Mike Schmidt**: Nishant?

**Nishant Bansal**: Hey, I am Nishant and I work on fuzzing Lightning
implementations.

**Mike Schmidt**: Thank you all for taking the time to join us and talk about
your respective items.  I think it's great that we have firsthand accounts on a
lot of these things, so we appreciate it.  I'm sure the audience appreciates it.
For those listening at home, we're going to go a little bit out of order in
deference to some of our guests.  We're going to start with Project Loupe and
three Bitcoin Core advisories.  Elias, I know you were on with Gustavo a few
weeks ago for #426, and Greg, you've been on a bunch of times before, but today
we're going to talk about three Bitcoin Core security advisories that were
published, I believe it was last Wednesday.  All three were found by Project
Loupe.  There were some additional researchers as well that also found similar
or the same issues, but after you guys had found them.  Maybe a quick
explanation or reminder of what Project Loupe is, Elias?

**Elias Rohrer**: Yeah, Project Loupe is essentially an initiative we started at
Spiral in roughly March, experimenting with automated LLM-based security
scanning for open-source projects.  We really started basically continuous
scanning for the first batch of projects that we onboarded in May.  Bitcoin Core
was part of that initial batch.  Since then, we opened up the program a bit for
further registrations for projects that are interested to be scanned.  Yeah,
please do if you're interested.  Yeah, but it is an LLM-based security scanning
for Bitcoin open-source projects that we have been running for the last few
months and yeah, we produce a considerable amount of reports.  And according to
the change logs and public attributions, quite a few projects are actually
patching the vulnerabilities we found since then.

_Bitcoin Core #36665_

**Mike Schmidt**: Excellent.  Well maybe we can get into the three that are from
our Notable code segment this week.  We can start with Bitcoin Core #36665,
which is the TCP urgent data bug.  I don't know, Elias, if you want to go
through it and then Greg piggybacks, or Greg goes through it.  I don't know what
you guys have in mind.

**Elias Rohrer**: I think Greg will take us.

**Greg Sanders**: Yeah, so Elias' role is making sure the system is up in place,
making the reports, but when it comes down to triage, that's where this half
comes in.  So, the urgent packets report was one of the three where it came in,
I think, this is the one that came in last minute.  So, Antoine can speak more
to this, but there was a Bitcoin Core 32.0 release tag and releases being built
about to happen.  But shortly before that, Project Loupe spat out this last one.
I triaged it and basically, it lets an attacker easily out-of-memory (OOM) a
node if you are running on a non-Linux-based distribution.  So, that kind of
triggered this batch of issues needing to be solved kind of quickly.  And
Antoine can go more into that if he likes.

**Mike Schmidt**: Yeah, Antoine, what happened with 32.0 and 32.1 because of
this particular item?

**Antoine Poinsot**: So, we were planning to do the first round of applying the
new security policy of Bitcoin Core for issues that are easily discoverable.
And so, now that they are public, we essentially had the other OOM issue, which
was also found by Loupe.  And we had the undo file overflow.  We picked these
issues because the other OOM issue is reasonably severe, but it's not as bad as
the other one, because it's slower to exploit.  And the undo file overflow is
merely theoretical.  So, we were planning on doing a 32.1, a 31.2, a 30.4, and a
29.5, so a set of minor releases for all maintained versions of Bitcoin Core
with patches for these issues.  And that's when the new Loupe report came in.
Greg jumped on it immediately and said, "That's probably bad", forwarded it to
the security team.  We confirmed it was probably bad.  And over the weekend and
at the beginning of the following week, we worked on issuing minor releases,
including a patch for this bug, in addition to the two other bugs that we were
initially planning to release accelerated fixes for.

So, we had started planning to have accelerated releases already.  We just
decided to include the patch for this one, and also to not release the next
major version of 32.0 without the mitigation for this fix, because it would be
awkward to just send a major version to all users saying, "Hey, that's the best
version of our software, update to this new version", and then two days later,
"Actually there is critical OOM bug.  If you don't run on Linux, upgrade to this
version.  And by the way, we knew about this bug before we released the last
major version".  So, that would have been confusing signals.  If there was a
month between the two, that would probably be fine.  But given that we were
planning to do the accelerated releases within the next couple days anyways, the
maintainers, Ava and Michael, decided to just not follow through with 32.0 and
just jumped ahead to 32.1 instead.

**Mike Schmidt**: Greg, any more color on this last-minute one that you all
found for 32?  Like, you mentioned that it's operating-system specific.  Maybe
we can get into the details of the nuance between the operating systems?

**Greg Sanders**: Right.  So, the way that the system is polling for packets
being sent by the peer is different based on architecture.  So, in 2018, Patrick
Strateman changed how Linux does it, but didn't change how Windows, FreeBSD, and
so forth do it, I think from what I understand, mostly because of how those
operating systems would handle that particular method.  And so, it wasn't a full
conversion.  And then, that was unchanged until now, pretty much, where the ones
that weren't switched over back in 2018 were vulnerable to this issue.  So, I
think Antoine has some follow-up work to synchronize now that things have
changed in the interim, change that to synchronize so we have one system, one
path to think about.  That's a follow-up issue past just making sure that nodes
aren't easily crashable.

**Mike Schmidt**: Antoine, I don't remember if you mentioned it in your
discussion a minute ago, but you implemented the fixes for each of these three
that we're going over, right?

**Antoine Poinsot**: Yes.  So, we had the fixes for the slow-to-exploit memory
issue and the undo file overflow, because we had worked on it during the past
week.  And we immediately started implementing a fix as soon as Greg reported
the easy-to-exploit OOM bug on the Friday.  And we synchronized opening these
fixes in public.  Generally, for security patches, we poll, pun intended, a few
other contributors in private about the patch.  Back in the days, we would
sometimes ask somebody if they could find the issue that it fixes without
knowing about the bug in the first place.  For easily discoverable issues, we
obviously don't do that anymore.  But we try to get some assurance that it
actually patches the bug completely, because it would be a massive mistake to
just go ahead, publish a fix in an accelerated release, publish all the details,
and it doesn't patch it entirely; or worse, work on the fix, publish the fix,
make accelerated releases, but it introduces a regression in some other aspect
of the software that users depend on, and they can't upgrade to the fix.

So, now you have the details published, but the fix is not available to the
users.  So, we try to make sure that we don't introduce a regression, but still
completely patch the bug.  So, that was done during the previous week and over
the weekend.  And then, on Monday, we opened the fixes publicly because it's an
easily discoverable issue.  We didn't put too much effort in trying to cover the
patch, in trying to go around the fix to try to fix it.  Instead, we fixed it
directly to make sure that we actually fully fix it and not introduce a
regression.  But we also don't try to unnecessarily call attention to, "Hey,
this is a security fix", because at the time we opened the PR, there was still
no fixed version available to users.  And as soon as we open the PR, the race
begins of getting those PRs merged in time and then getting a release published
as soon as possible to users, which takes a long time.  There is a bunch of
processes, and then obviously, the Bitcoin Core releases are not just one person
building and signing and sending to users, which would make such process a lot
faster.  But we rely on a community of people building the software, the Guix
builds, and signing the software that is necessary to go through before the fix
is available to everybody.

For this first experiment with these three issues, we were able to release the
binaries within 48 hours for all maintained versions from the point where the
PRs were open in public.

**Mike Schmidt**: Murch, anything else?  Should we geek out a little bit more on
this one or move to the next one?

**Mark Erhardt**: Yeah, maybe just, so this is the first time this new security
policy for easily-discoverable bugs has been used.  Have you gotten any feedback
so far?  It sounds like it went pretty well.

**Antoine Poinsot**: Yeah, an interesting aspect.  So, we have this security
team inside the group of Bitcoin Core contributors, and generally we work on the
security fixes within the security team, because for embargoed vulnerability
there is something like 40 contributors on Bitcoin Core.  So, if you share a
secret to 40 persons, it's not a secret anymore.  But for these vulnerabilities,
they are easily discoverable, we are going to publicize them very soon, so we
could afford to share it with all contributors.  And I think that significantly
helped us move fast and get some more assurance that the fix is correct, because
we've got a lot more eyeballs than we generally do on security patches that are
fixed covertly.

_Bitcoin Core #36667_

**Mike Schmidt**: Maybe we can move to the next one in the interest of time.
This is Bitcoin Core #36667, the slow leak on paused peers one.  What's leaking,
Greg?

**Greg Sanders**: So, this one is how a Bitcoin Core node deals with an
essentially unresponsive peer, or a peer that's not draining what you're trying
to send in.  So, you have this queue of things you're trying to send the peer.
If they stop processing, taking that off the wire, this starts building up.  And
then, we have this logic in the node that says, "Hey, pause additional sending,
so don't send certain amounts of certain types of messages to this peer anymore
to stop backlogging".  But unfortunately, there's a few message types that were
kind of whitelisted from this.  And one of those, the most important one by far,
ends up being the inventory message, so the message that says, "Hey, I have a
new transaction in my mempool for you".  And so, these messages kept piling up
indefinitely.  And so, the average is something like eight to nine transactions
per second being queued up in this queue, which ends up having more and more
memory being used up and is never backstopped anywhere.  So, you can imagine a
case where you'd have a number of incoming peers to your node.  They
intentionally stop listening, kind of in a semi-malicious way, stop listening,
stop taking bits off the wire, and then grow this memory until your node
crashes.

So, obviously this is dependent on things that the attacker can't control, like
how many inventory messages you're sending.  And so, that kind of rate-limits it
and makes it slower, but there is a universality to it in that it doesn't depend
on which operating system you're using, unlike the other one.  So, it's on the
order of, I can't remember the number of connections, but days to weeks, kind of
thing, or your node will run out of memory.

**Mike Schmidt**: Okay, yeah, I was going to say how long does it take, but it
takes a while?

**Greg Sanders**: Yeah, it's fairly slow.  So, it'd be very unlikely to have a
network-wide effect, where every user gets hit at the same time.  Everyone has
different amounts of memory, a different amount of peers, and it's slow.  So,
that's why it wasn't rated higher than it was.

**Mike Schmidt**: There would be no notification, obviously; this would be
something you just have to notice the memory usage climbing yourself?

**Greg Sanders**: Yeah.  And any deployments that are on Kubernetes, or
whatever, it would be a crash and then, it would be back up in a second.  So,
this more affects nodes that have less provision in terms of RAM and other
infrastructure.

**Mike Schmidt**: And this one was medium severity, right?

**Greg Sanders**: Yeah, medium because of the universality; not higher,
critical, because it can't be a systemic issue, like an immediate systemic
issue.

**Antoine Poinsot**: The cost to exploit is also not from the attacker's pocket.
The attacker is leveraging normal network traffic and is able to attack all the
network at the same time.

**Greg Sanders**: And they don't even have to expend much bandwidth to do so,
right?  There's no sort of proportionality at all.

**Mike Schmidt**: Now, Antoine, the previous one, was also a medium, right?  I
think one of you used the word, 'critical', but is that because it doesn't
affect all operating systems or was that just flowery language?

**Antoine Poinsot**: Yeah, the first one was also medium severity, because it
would only affect Windows users and macOS users and BSD users.  So, out of
those, it would probably be BSD users that are actually reachable on the network
and form some very tiny part of the backbone of the network.  But the vast, vast
majority of the backbone of the network is Linux.  So, if Patrick Strateman
didn't fix that in 2019 for Linux, that would have been high for sure and
possibly critical, because it would allow anyone to just take down the entire
network immediately.

_Bitcoin Core #36669_

**Mike Schmidt**: Last one of these three, Bitcoin Core #36669.  This is the
undo-file overflow.  Maybe Greg, as you explain, you just remind everybody what
these undo files are?

**Greg Sanders**: So, these undo files allow a node to replay history backwards.
If there's a reorg, you need your node to be able to step backwards in time, in
the UTXO-set sense, to play forward again.  And the way these files are built,
there's this assumption that these files can't get too large.  They're bounded
by various factors and they can't get too large.  But it turns out that under
certain extreme conditions, that these files can get larger than what the
addressing format was using.  Yeah, the variable internally was using 32-bit
variables and it would overflow.  And so, that means you're reading and writing
into the wrong spots, and this could cause a crash, consistency issues, and in a
very theoretical sense, if everything goes right for the attacker and ten
months' worth of blocks and very good luck, there could be some inflation, but
that's very outside there.  It's primarily a crash concern and primarily
theoretical.

**Mike Schmidt**: Antoine, any color on this one?

**Antoine Poinsot**: Not really.  I guess you could sensationalize it by saying,
"Because then, you could overwrite the UTXO set", but it's only in conditions
where the Bitcoin system is useless anyways, right, or you can have a 100-block
reorg, or an attacker can time a bunch of reorgs at a specific time and then a
follow-up reorg at a very specific other time.  So, it's really theoretical.  We
had discussions about whether it should be a vulnerability at all, and also with
the previous policies.  So, should it require secrecy to fix this?  It was
discussed back in the day when the UTXO set model was implemented, actually when
Pieter Wuille introduced the chainstate database with the undo data.  It was
known that it was a limitation but it was not a priority at this time.  But
there's also the case that it wouldn't be very serious to just discuss all of
this publicly because of the potential impact.  So, that's why we settled on low
severity, but it's definitely the least interesting of the three that we just
released.

**Mike Schmidt**: Greg or Elias, anything else to say on Loupe's work into these
three?

**Greg Sanders**: Well, I can speak to the reports.  So, Loupe gives a lot of
reports, I sift through hundreds of reports.  And primarily, my job as a triager
is I ignore the severity rating it gives and just pull on threads, and try to
have a focus on security model.  In that sense, a number of these leads have
been very helpful, obviously.  So, I've been very happy with the output so far.

**Mike Schmidt**: So, Loupe alone, for example, has hundreds of Bitcoin Core, I
guess, items for you, Greg, to triage as the subject matter expert at a deeper
level.

**Greg Sanders**: Right, yeah.  So, some will be like, "Oh, these helper scripts
have an issue, like contrib tools".  I just ignore those.  And then there's some
that are API footguns that potentially could be problematic.  And there's real
bugs that aren't vulnerabilities, or, "What if the user does something very,
very stupid in their RPC?  It can take quadratic time to process", whatever.
Okay, there's those.  And then there's also, on the far end, these serious
issues, and that's what I tend to focus on, because there's already a lot of
people working on the regular bug fixes in the open.  You can just look at the
GitHub tracker for issues and PRs.  There's lots of tests, lots of bug fixes.
That is less of a good use of my time, I think, versus focusing on these tail
risk, what's out there, and fixing those appropriately with reporting to the
security team.

**Mike Schmidt**: Excellent.  Oh, sorry, go ahead.

**Elias Rohrer**: Maybe one last comment on the volume there.  So, yes, Loupe
can create a high volume of reports, and that is the feedback we got from
several projects.  And that is perceived in part to be noisy, and we're actually
working towards improving the quality of our reports and reducing essentially
the false positive rate.  But so far, we also basically intentionally erred on
the side of being conservative, and report more and leave it to the projects to
actually do triage how they would seem fit, basically, because we saw
misclassifications in both directions.  We would rather report a few more things
that the projects can filter out, maybe also with the help of LLMs, rather than
not report something that it turns out to be actually a high or critical
vulnerability in the end.

**Mike Schmidt**: Well, thank you both for joining us.  I have a couple
follow-up questions for Antoine on the policy and security stuff, but you guys
are welcome to hang on, or if you have other things to do, we understand.  We
appreciate your time.

**Greg Sanders**: Thank you.

**Mike Schmidt**: Cheers.

**Elias Rohrer**: Thanks.

_Bitcoin Core security policy update_

**Mike Schmidt**: Antoine, in some of this discussion about vulnerabilities and
bugs, where should listeners sort of think that the line is?  I think that I did
a quick look at the PRs using some heuristics that went into 32, and there's
something like 80 bug fixes that maybe went into 32 or 32.1.  And now, people
hear, 'bugs', and all this stuff going on online.  It's like everything's a bug
and a vulnerability, it gets blended.  So, how should listeners think between
those, whatever it is, 80 or whatever, I don't know if that's the right number
of bugs that are fixed in the open, versus the lowest low severity that you
might assign for a security vulnerability?

**Antoine Poinsot**: I think it's pretty simple.  When we say bug on its own,
it's that it's not something that is critical.  If it was, we would mention it.
For instance, we had a pretty critical bug with v30, with the wallet deletion,
that was not a vulnerability.  And it was taken very seriously and we took the
steps to advertise it to users.  The rest of the bug fixes are some small
malfunctions that should be fixed, but are not known to have very severe
consequences.

**Mike Schmidt**: Are you saying that wallet deletion is a bug and not a
vulnerability, and maybe that's a good one to distinguish for people?

**Antoine Poinsot**: It's not triggered by an attacker.  It's a footgun.

**Mike Schmidt**: Got it.

**Mark Erhardt**: Right.  So, bugs generally indicate any sort of way the
program can behave differently than intended; whereas vulnerabilities are often
based on a bug, but they are exploitable in a sense that someone else can do
something to you.  So, for example, with the wallet deletion bug, this was based
on the name of the file and the type of file.  And in certain combinations, it
would just behave incorrectly and fail to do the migration, I think, and then
delete the directory that was supposed to have been created, but in the case of
specific names, was actually the main wallet directory, right?  So, nobody else
can go on your computer and make a wallet on your Bitcoin Core in order to
trigger this bug because, well, if someone's on your computer, you have other
issues already, obviously.  But yeah, the difference being bugs anywhere where
the software has a flaw that causes misbehavior; and vulnerabilities are things
that attackers can exploit to either crash or penetrate foreign devices.

**Mike Schmidt**: Makes sense.  Antoine, we sort of started on your item already
and covered a good chunk of it, but I think there's this sort of tension that
you outlined in the announcement of the policy change.  And maybe you can just
comment on that.  I don't know if you commented on that earlier.  Maybe
listeners can understand how you're thinking about this tension.

**Antoine Poinsot**: I think the tension is on information asymmetry.  Let's say
the starting point is already bad.  So, you discover a vulnerability in your
software, but in the software that you publicly develop and release.  So, that's
already a bad situation.  How do you mitigate and not make it worse?  One way of
mitigating it is to make users as aware as soon as possible of the bug and
provide them a release that fixed the bug which happens to also be a
vulnerability.  That maximizes transparency and that minimizes information
asymmetry between an unsuspecting user that is not scanning the codebase daily,
and an attacker that may be scanning, with either his eyeballs or whatever
tooling he has, the codebase.  On the other end of the spectrum, you have
betting that an attacker cannot easily rediscover the vulnerability.  Patch it
in the open covertly under the guise of a mere refactoring or a new feature, and
you sneak in a patch for the vulnerability.  That's how we historically
approached fixing vulnerabilities.  And you let the patch sit for a full
development cycle, and then make it available in a release.  Then, users
progressively upgrade to the new release.  And some amount of time later, you
publish the details of the vulnerability to make users aware that there was an
issue.

I think, due to the culture around Bitcoin Core users and just the nature of
Bitcoin Core, which represents the consensus rules of your money, you don't want
to be upgrading your money every so often.  And this is reinforced by a culture
of very slow upgrades around users of Bitcoin Core.  For this reason, we
historically have been on the second end of the spectrum, the one which
maximizes the time, the embargo time, where we covertly patch everything, slowly
have users progressively upgrade because the fix is not made available in minor
releases, because it would make it obvious that it was a security fix, so it's
only available through the new major releases.  And eventually, so something
like 18 months after it was discovered, we make it public.

However, for things that are easily discoverable through LLMs or otherwise, it's
just not the right trade-off, because it means that the fix sits there, that an
attacker or any script kiddie with the right tool can rediscover it.  And a fix
is not available to users.  So, for these bugs, we opt for the other end of the
spectrum, and we now try to make a fix available as soon as possible to users
instead, even if we compromise on making a fix more conspicuous than it could
otherwise be, for instance, because it's already conspicuous, is the point.

**Mike Schmidt**: So, for things that are not easily discoverable, aka I guess
it would be like me pointing an LLM and saying, "Hey, find something here", that
would be easy.  So, for the ones that don't fall into the easily discoverable,
you still retain the existing policy; is that right?

**Antoine Poinsot**: Yes, so we retain the existing policy by default, and the
easily-discoverable flag is a carve-out of the policy.  As an example, we also
confusingly pre-announced that we are going to release three security advisories
as part of the 32.1 release announcement, and the three pre-announced advisories
are not the same as the three advisories that we directly published at the same
time in 32.1.  So, we had three vulnerabilities, one low severity and two medium
severity, that were easily discoverable.  And we have three either medium- or
high-severity security issues that were not easily discoverable, for which we're
going to publish the details about exactly a week from now.

**Mike Schmidt**: And so, those were fixed in previous versions covertly, and
they were in what then, 30, the ones that were fixed in 30?

**Antoine Poinsot**: Yes, so for the regular policy, it's to publish the details
of a vulnerability as soon as the last major version which was vulnerable to
this issue goes end of life, which means as soon as three releases with the fix
come up on top of the last vulnerability.  So, it means that the first release
that contains the fix for the first major version that contains the fix for
these bugs is v30.

**Mike Schmidt**: Makes sense.  And maybe just to spell out for the audience, if
your eyes have glazed over from this discussion, or your ears, I guess, if that
vulnerability that came in late in the 32 development cycle hadn't come in, and
instead came in today after a major release already, there would be a new point
release within days, right, something like this; is that right?  So, there could
be another one coming in, and that would be a quick version release coming in a
few days, just so folks can understand?

**Antoine Poinsot**: Yes, exactly.

**Mike Schmidt**: Because I think it was weird that it happened around 32.
Maybe people haven't fully wrapped their minds around how this could go.

**Antoine Poinsot**: Yes, exactly.  That's what we would shoot for.  Obviously,
it's not only up to me, but in all likelihood, if we have the same type of issue
that shows up today, we would do something very similar.  And it just so happens
that it happened exactly at the same time when we're releasing a major new
version.  But it's not going to happen the same every time.

**Mike Schmidt**: Anyone else have questions for Antoine on this one?  Antoine,
we can do Bitcoin Core 32.1 with you and comment on the point releases as well,
or we can do them without you.  I don't know what your schedule is like?

**Antoine Poinsot**: I can stay for five more minutes.

_Bitcoin Core 32.1, Bitcoin Core 31.2, Bitcoin Core 30.4 and Bitcoin Core 29.5_

**Mike Schmidt**: Okay.  Well, we talked about why there's no 32.0.  And so, I
guess we're on 32.1, which we've covered most of the changes in there
previously, over the last month or so, during the RCs.  I think we had a
discussion on the testing guide which went into some of the features.  I can
just go off of a few here that I have in my notes.  Mempool-based fee
estimation; PSBTv2, and that's also by default; there's watch-only wallet
exports; there's some improvements that went into faster block validation,
including some of the parallel prevout-fetching that we talked about in previous
newsletters, I don't have that handy; there's a note on indexing, I think it
went from 66 to 26, was the metric that I saw; there's the change in max
connections from 125 to 200, which sort of lays the groundwork for a potentially
more connected network in the future.  And then, we have BIP434, which is the
feature message, and I think that we actually cover that separately so we can
get into that.  Murch or Gustavo or Antoine, other headline features?  We
obviously talked about the security fixes in there as well.

**Mark Erhardt**: I think you covered it.  We had also talked quite a bit about
that in episode #427.

**Mike Schmidt**: Gustavo, anything from you?  Go ahead, Antoine.

**Antoine Poinsot**: Yeah, maybe something to quickly highlight is the new HTTP
server, as we just discussed security.  Bitcoin Core 32.1 is the first version
of Bitcoin Core that is shipping with its own implementation of an HTTP server.
And you may ask, "Why in hell would Bitcoin Core take on the maintenance of an
HTTP server?"  But the alternative, well, the status quo was using libevent,
which although it's being used by large projects, was a massive unmaintained C
codebase.  In the age of automated vulnerability scanning, it was just an issue
waiting to happen.  So, we often talk about vulnerabilities after they happen,
but there's a lot of work that goes into avoiding them in the first place, and I
think that's one such case here.

**Mike Schmidt**: Yeah, sorry, I was just trying to find.  We had Zipkin on, who
did a lot of work around that.  So, if you look in the podcast for Zipkin, you
can see the show we did with him where we talked a bit about that.  So, yeah,
that's a good one to articulate.  Okay.  Murch, what do you think?  Should we do
the rest of the point releases?  Should we let Antoine drop and then do those
later or?

**Mark Erhardt**: I think we more or less covered them already, right?  The main
point of them, well, every time we make a new major release, we usually also
backport bug fixes to the previous major releases that are still being
maintained.  So, for 32.1, the major release v29 is going to go out of
maintenance.  And so, for 29, 29.5 is probably the last release in the major
release series.  And yeah, I think other than that, it's just things we've
talked about a lot already.

**Mike Schmidt**: I think that's fair.

**Mark Erhardt**: Yeah, plus the security fixes that we just discussed in
detail.

**Mike Schmidt**: 32.1 has those security fixes.  It trims the version bits.
That's in BIP323 that we talked about before.  And it caps the private broadcast
queue to 10,000 transactions.  And then, there's this compacting of the
chainstate database regularly.  30.4 also has those same security fixes, also
has the BIP323 warning change, and then there's a DNS seed removal.  And then,
29.5 has the security fixes plus the DNS seed removal.  And then, as you
mentioned, Murch, 29 is end of life as of now-ish.  Anything else, Antoine,
before we let you go?

**Antoine Poinsot**: No.  Thank you for having me.

_Silent payments for multiparty wallets_

**Mike Schmidt**: Thanks for your time, Antoine, we appreciate it.  Cheers.
Okay, back up to the News section, "Silent payments for multiparty wallets".
Oleks, you were on with us back in #392 to talk about BLISK, I believe, and
before that we had you on talking about OP_RAND emulation.  But we're going to
talk about silent payments this go around.  You mentioned that you've been doing
a lot of post-quantum work.  So, how did you find yourself working on silent
payments?  Maybe talk about the use case for multiparty wallets and its relation
to silent payments.

**Oleksandr Kurbatov**: Yeah, actually it was a pretty funny story.  I was at a
conference in Neuchâtel last summer and there was some guy, unfortunately I
don't remember the name, who talked about silent payments.  And I have seen that
the first time and I said, "All right, so there should be some algebraic
properties behind, so do they support FROST or MuSig2 solutions?"  Actually, he
didn't know the answer, so I did my own research.  And yeah, it happens that in
the form of BIP352, it proposes that it doesn't work in this way.  So, we need a
bit to reconstruct what they propose and it will work, without any modifications
to existing interfaces, to existing DLEQ proofs, etc.  So, everything is going
to be byte-to-byte compatible, so we don't need to introduce some additional
stuff. Yeah, and I constructed that.  That's it.

**Mark Erhardt**: So, just to be clear, we're talking about FROST and MuSig on
the input side.  So, whether people that hold funds in shared ….

**Oleksandr Kurbatov**: Yeah, because usually, if you have the single scan key,
that's totally fine.  So, you are letting every party to detect all incoming
payments.  That's fine because it doesn't compromise your wallet trust model.
But actually, when you are spending from a multisignature wallet, it might be a
problem because to reconstruct an ECDH secret, in naïve form, you need to have
the scalar value on the single device, and we should avoid that.  And this
protocol allows you to calculate this ECDH point collaboratively between several
parties without reconstructing the main secret on the single device.

**Mark Erhardt**: Okay, so it's actually exactly the other way than I
understood.  I thought it was about being able to send to silent payment
addresses, or from a multisig, because also the construction gets a little
complicated because you have to derive the shared secret.  But you're talking
about receiving funds to a MuSig2-based silent payments address, and then
spending them afterwards; is that right?

**Oleksandr Kurbatov**: Yes, I mean you can receive just a payment to
multisignature wallet, to a MuSig2, for example, wallet.  But when you want to
make a silent payment from this wallet, you can apply this technique.  So, this
is only relevant for the sender.

**Mike Schmidt**: Sending from a silent-payment-received MuSig2 or FROST wallet;
is that right?

**Oleksandr Kurbatov**: Right.  Any nested construction is also supported, so
nested MuSig or BLISK or, I don't know, whatever you want.  So, all the
signatures share the single interface.  Just probably the difference is how
exactly they share the main scalar value between wallets is different from FROST
and MuSig2.  But basically, yeah, you can have a common approach, for example.

**Mike Schmidt**: Now, you mentioned that BIP352 said explicitly not to do this?

**Oleksandr Kurbatov**: It says we shouldn't do that in the form they propose.
What they propose, you can just, I don't know, take your share, multiply it by
base G, and then sum everything together.  And it doesn't work, because first of
all you need to have coefficients.  In the case of FROST, you have Lagrange
coefficients; in the case of MuSig2, you have the aggregation coefficients,
which are a bit different.  So, the sum will not result in the needed value.
And secondly, yeah, we need to have another two-nonce technique, pretty similar
to MuSig2, to make this approach secure.

**Mike Schmidt**: Now, you have a security paper, right, and that's under
review?

**Oleksandr Kurbatov**: Yeah, I have a security paper.  Also, I have proven all
theorems with SSProve.  So, everything should be fine.

**Mike Schmidt**: I have in my notes here that there still is the hardness
assumption, that that's still open.  What would it take to settle that if that
is open?

**Oleksandr Kurbatov**: Yeah, I mean there is no clear way how we can make a
reduction to AOMDL, for example.  That's the main assumption behind the MuSig2
solution.  Because additionally to what MuSig2 shares, we share three additional
ECDH points inside.  That's a scalar value multiplied to the G base and plus to
the scan key base.  That should be safe.  There is no known attack which allows
us to apply those values and recover the scalar value or make a proof for an
invalid, I don't know, discrete logarithm, etcetera.  But still, there is no
known reduction of one problem to another problem.  And probably, that's the
biggest gap.  We know there is a famous attack proposed by Cheon.  This is the
worst case we have, but still it allows you to produce up to 256 signatures
safely, which is a lot.

**Mike Schmidt**: I saw in the thread there was a user, MacGyver, who's working
on Jade and COLDCARD support for this on signet.  Did you get a chance to look
at that?  And then maybe the broader question is, what has the response been
from essentially, I guess, signing devices or wallet providers on wanting to
support something like this?

**Oleksandr Kurbatov**: I believe so, because recent incidents have shown that,
yeah, people should use multiparty wallets, because I mean your software and
hardware wallet might be compromised because of supply chain attacks or, I don't
know, any problems with randomness.  Probably, we will implement it in Jade in
some future.  But again, for example, Blockstream app doesn't support silent
payments right now.  That's also the problem.  So, if you want to solve only the
problem with multiparty security model, that's all right, there is a set of
wallets which resolve it.  But at the same time, they usually don't implement
silent payments.  Actually, yeah, we want to raise this question between, I
don't know, maybe Cake Wallet plus Electrum plus Jade, Blockstream App, etc.  I
think there is a demand.  Another question is how much time it might take to
make it implemented, because again, quantum computer is coming, etc.  That's
actually my hobby, because the majority of the time I'm working on SHRINCS, etc.
But still, I think yeah, that might be a pretty interesting feature if you want
to support both elegant technologies and just fill the gap between them.

**Mike Schmidt**: As we wrap up here, it sounds like next steps would be to get
feedback on that security paper and is there then a BIP in the works?

**Oleksandr Kurbatov**: I mean, I would like to hear your opinion on this point.
If this makes sense, I would be happy to work on that, but only if there is a
demand for the technology.  Because the security paper is ready, I just need to
publish it.  A BIP is, again, there is a common narrative that people should
stop working on pre-quantum cryptography.  I don't agree with that.  But still,
I'm only the smallest part of the Bitcoin community.  So, yeah, if there is a
demand, a BIP is the following step.

**Mike Schmidt**: Well in terms of demand, I guess that's the community of
signing devices, users and wallets.  In terms of the BIP process, we have a BIP
editor here, maybe you'll opine on that, Murch?  Do you think, if there's
seemingly demand, that this makes sense as a BIP?

**Mark Erhardt**: Well, if there is, yes, certainly.  But I think Oleks does
touch on an interesting point here, which is probably the next focus of the
broader ecosystem is to work on post-quantum things.  Silent payments still has
relatively small adoption anyway, and so adding more bells and whistles to
silent payments is probably going to be only after silent payments itself gets
more adopted.  And I don't know how many wallet implementers will focus on that
when they're probably going to work on post-quantum signatures next.

**Mike Schmidt**: Oleks, any final comments before we wrap up this item?

**Oleksandr Kurbatov**: Yeah, I just checked the statistics before our call.
Right now, daily statistics shows only 80% of addresses are single-key addresses
still.  So, we don't even have an adoption of multisignatures.  With silent
payments, we cannot track, because they are silent, but my prediction is that's
around 2% or 3%.  But still, I'm pretty open to any wallets who want to have
this functionality.

**Mark Erhardt**: Yeah, maybe an interesting thing is that silent payments
outputs are always Pay-to-Taproot (P2TR).  So, we can look a little bit at the
P2TR outputs.  And while there's a huge count of P2TR outputs, the overall
amount of money in P2TR outputs is still very low.  So, I don't know how much
silent payments use we're seeing; we're still seeing P2TR being used very
little, unfortunately.

**Mike Schmidt**: Oleks, thanks for your work on this.  Thanks for coming on and
talking about it with us.  We appreciate your time.

**Oleksandr Kurbatov**: Yeah, thanks for having me.

**Mike Schmidt**: Cheers.

**Oleksandr Kurbatov**: Bye-bye.

_CLN self-referential channel announcement DoS disclosure_

**Mike Schmidt**: Our final news item, "CLN self-referential channel
announcement DoS disclosure".  Nishant, you've been on before and you're back,
to many Lightning users' chagrin, to talk about another disclosure.  Maybe to
kick things off, what is a channel announcement; what is a self-referential
channel announcement; and how can it be used to DoS a CLN node?

**Nishant Bansal**: Okay, so a channel announcement is one of the gossip
messages in the LN.  So, channel announcement identifies a new channel based on
the short channel ID (SCID) onchain, and also it contains both the node
endpoints which has the channel.  And the channel announcement is actually used
to prove that these are the Bitcoin keys which correspond to an onchain 2-of-2
Lightning funding output, and they are node keys which are used to prove that
both node endpoints actually own these channels.  So, what Lightning node
typically does is verify the onchain output and then checks the signatures, and
then stores this channel data on disk which, for CLN, it was gossip_store, and
then tries to build the network graph from this channel in memory, and for CLN
it is gossmap.  And now, the vulnerability in CLN was CLN verifies that this is
actually a Lightning funding output onchain and the signatures are actually
valid, but CLN wasn't verifying that the two nodes which are used in the channel
announcement are, or should be, different.

So, what an attacker could do is they can create a 2-of-2 output onchain, and
then they can sign their channel with the same fresh node endpoints.  So, the
channel announcement is actually self-referential; both node endpoints are the
same, so the channel is referring to itself, so that is why it's
self-referential.  And what CLN does is CLN verifies this channel announcement,
it doesn't reject this channel announcement because of the same node IDs.  It
stores this channel data on disk and then tries to build the network graph with
it.  Added in the releases from 25.02 to 26.04, CLN added a no-duplicate
hash-table-based channel graph construction.  So, these same node endpoints are
actually added to that graph, gossipd will crash.  And since the lightningd,
which is the master daemon for CLN, considers that as fatal, lightningd will
also crash.  So, after this, if the operator tries to restart, what happens is
since this channel data exists on disk, CLN will again pull that data and try to
build the network channel graph again.  And again, the same no-duplicate
assertion will trip and again CLN will crash.  So, the attacker only needs to
actually fund the 2-of-2 output, and then just create a channel announcement and
send it.  And if the operator removes that issue from that gossip_store by hand,
then also the attacker can send the same announcement again and again crash the
node.  So, as long as that 2-of-2 output is unspent, this attack can be
triggered any number of times.

The fix was fairly straightforward.  So, BOLT7 has already a requirement on the
sender side, where they asked that node_id_1 should be less than the node_id_2
in the channel announcement.  But they didn't have the same requirement on the
receiver side.  So, first, CLN added that requirement on their node itself, and
then they created a PR on the BOLTs itself so that every other implementation
should have that, which every other implementation was already rejecting it at
that time.

**Mike Schmidt**: I was going to ask how the other node implementations were
handling it.  It sounds like they saw that it was the same and they had some
check already in there and rejected it?

**Nishant Bansal**: Yeah, so every other Lightning implementation already has
the check to reject the cases where the both node IDs in the channel
announcement are same.  But since this BOLT PR was raised, now every Lightning
implementation rejects a channel announcement where node_id_1 is not less than
node_id_2.  So, it should be less than.  So, the equal-to case is also covered
in that.  And one more extension to this issue is that since CLN wasn't
rejecting this on the receiver side, and before the 25.02 release, CLN accepted
that channel announcement and built the network graph with that, and then also
rebroadcast this message again.  So, an attacker doesn't have to actually
connect to the vulnerable node itself.  The old CLN releases could also
rebroadcast this bad message to the vulnerable nodes.  So, all the operators
should actually update, because an attacker doesn't have to be directly
connected.

**Mike Schmidt**: Yikes.  Maybe pardon my ignorance, but if it's
self-referential, you don't want the two node IDs to be the same, why not just
say, "Make sure that they're not the same"?  What is this less-than value
comparing the node IDs?  I don't understand that part.

**Nishant Bansal**: Yeah, so I think based on my understanding, the reason is
that since this channel announcement, the whole signature verification happens,
so if there is not a set of defined rules for which should be node_id_1 and
node_id_2, there could be the cases where actual valid channel announcements
could be rejected because some implementation has used node_id_2 as the one
which is less than node_id_1, which is the creator.  So, I think just to set the
rules.  But the main issue which should be fixed is the case where those two
node IDs are equal.

**Mike Schmidt**: Makes sense.  I don't remember if you said how you discovered
it.

**Nishant Bansal**: Yeah, so I discovered this when I was adding the gossip
state machine fuzz test to CLN.  So, I started adding this gossip state machine
fuzz test to all Lightning implementations.  And I started with LND, I found
some bugs, I reported it, disclosed the one which I did in June itself.  Then I
went to CLN.  CLN already had this gossip state machine fuzz test PR which was
being worked on.  But that time, the states which it had were only the normal
signature verification or the node verification cases, but it didn't have the
onchain lookup case, which only happens for channel announcement.  And after
that, only the channel announcement is considered fully validated and actually a
network graph or a node or channel graph is constructed.  So, once I added that,
the fuzzer found the self-referential case where the fuzzer panics, and this was
the bug.  And when I tried to restart the node, it keeps on crashing
continuously.  So, that is how I found the bug.

**Mike Schmidt**: I'm curious if any folks who are monitoring the LN have seen
an attempt to exploit this in the wild?

**Nishant Bansal**: So, this issue wasn't exploited at all and that is why Rusty
didn't add it.  So, the thing is, in the fix, only the case where a new channel
announcement where both node IDs equal is rejected.  But the case where some
already affected node which already has the same node ID's channel graph in
their disk, if it tries to upgrade then also it will fail, because that
rejection phase happens before that and this entry still exists on your disk.
But since this wasn't exploited, so Rusty didn't add that case, and so the
simple fix is just to reject whenever we get such an announcement.

**Mike Schmidt**: Makes sense.  Murch or Gustavo, any other questions on this
item?  All right, Murch is good.  Gustavo, you good?  Nishant, anything else
before we wrap up?

**Nishant Bansal**: Yeah, I would say keep your node software upgraded.  In the
past, or maybe the last week, there have been instances, for example in BTCPay
Server, where some operators haven't updated their node, and some security fixes
which were fixed maybe one or two months back have been exploited again.  So, I
would say keep your software upgraded, maybe reach out to your known ones and
tell them to be sure to be upgraded.

**Mike Schmidt**: Thanks for your time, Nishant.  We appreciate it.  Thanks for
joining us.

**Nishant Bansal**: Thanks everyone.

_Why does Bitcoin use both a transaction ID and a witness transaction ID?_

**Mike Schmidt**: To the Stack Exchange segment, we had three this month.  First
one, "Why does Bitcoin use both a transaction ID and a witness transaction ID?"
And this was answered by Pieter Wuille.  I feel like, Murch, we've covered
something like this before, but when Pieter answers and he provides all that
detail and he starts his answer with, "Great question", I figure that's one we
should cover for the newsletter.  So, is there new information here or maybe we
can give the answer, and then is there new information in here?

**Mark Erhardt**: I don't think so.  I think that's basically around the crux of
what segwit was about.  So, segwit, or segregated witness, one of the main goals
was to fix transaction malleability; transaction malleability in the sense that
if you changed a signature the txid would change.  And that was happening
because, of course, the input script is part of the data that contributes to the
hash that is the txid.  So, what segwit does is it pulls the signature data and
other witness items into the witness structure.  And the witness structure is
not and cannot be covered by the txid, as it wouldn't be backward compatible.
So, the txid needs to continue to be calculated from the things that every
Bitcoin node always knew about, so the input script, the output script, the
transaction header.  So, when we pulled out the signature data to the witness,
the txid became stable, regardless of whether signatures might be changed.  And
so, yeah, signatures can, for example, change because the sender just signs
again and gets a different signature, or maliciously by anyone that forwards a
legacy transaction, and they could just switch the sign of the s value to the
high s value, and then the txid would change.

So, anyway, we still have the txid because we need to be able to identify which
outputs we're spending, and to identify transactions the way they've always been
identified, and so forth.  Until recently, that was the tool that was used to
ask for transactions on the P2P network, and it is still what the merkle root
commits to, and so forth.  But of course, we don't want anyone to be able to
change the witness data of the transactions in the blocks either.  So, we
additionally have to, in some way, commit to the witness data in the
transaction.  So, there's the wtxid that covers the entire data of the
transaction, including the witness data, and this also identifies the
transaction and actually identifies it more specifically because, well, the txid
could be the same for two transactions that are the same except different in
witness data.  So, for example, if a P2TR output had first a scriptpath input
and then got replaced with a keypath input, otherwise all the same transaction,
that would cause two transactions with the same txids but different wtxids.

So, to distinguish between variants of transactions, we need the wtxid to commit
to the data in the blocks.  So, we have that extra witness commitment in the
coinbase transaction output, but also we recently changed the P2P traffic to be
based on wtxids so that if multiple variants of the same transaction were
floating around on a network, we would be able to distinguish between them
properly.

**Mike Schmidt**: Excellent.  Thanks, Murch.  If you're curious, I think I guess
you could sum up the answer from Pieter Wuille here as maybe not saying the what
so much as the design considerations around txid, wtxid, and segwit.  So, if
you're curious as to his insight in designing that, take a look at the full
answer.

**Mark Erhardt**: Right.  Sorry, I didn't actually read his answer.

_How to sign a MuSig with Bitcoin Core_

**Mike Schmidt**: You gave a great alternate answer.  You should put it on Stack
Exchange.  "How to sign a MuSig with Bitcoin Core".  This person is trying to
spend from a MuSig2 output just using Bitcoin Core.  They have the taproot
descriptor with MuSig keys from two different Bitcoin Core wallets, they
imported it into watch-only, they funded it with a faucet, they made a PSBT, and
then they ran it through all three of those wallets, and everything seemed to do
something and work.  But when running analyzepsbt, it kept saying that an
updater was needed and that the transaction never finalized.  Ava Chow, wallet
master, answers this question, going through MuSig2, that it's a two-round
signing protocol, so you actually have to process that PSBT twice.  The first
one, the wallets are adding the public nonce, and then the second one, combining
that PSBT once every nonce is present.  And so, the missing step here was
walletprocesspsbt.  If you're curious about the flow and want to run an example
yourself, maybe jump into the answer by Ava and give it a go yourself to
understand that process.

_What changed in Bitcoin P2P protocol version 70017 compared to 70016?_

Last question from the Stack Exchange, "What changed in Bitcoin P2P protocol
version 70017 compared to 70016?"  Murch, first of all, what is a Bitcoin P2P
protocol version?  I don't know if that's something that's on a lot of people's
radar.

**Mark Erhardt**: Right.  So, when two nodes connect, they perform something
that we call the version handshake, and they tell each other about what features
they support and which version of the protocol they speak.  And this protocol
version indicates which features they understand.  So, the latest added feature,
which the protocol version was bumped to 70017 for, is BIP434, which is Peer
Feature Negotiation.  This is a new mechanism by which you can negotiate
optional features.  You tell your peer that you want to use an optional feature
and which variant of an optional feature, and then there's a schema by which
both peers that talk to each other align their expectations and pick a variant
that works for both of them.  So, if one peer says, "I want to use feature A in
the third variant, and after that, second variant would also be acceptable to
me", and the other one wants to use the second variant, they might end up using
second variant together.  Yeah, anyway, the hope is now that we can negotiate
features through BIP434, we don't need to bump the protocol version as often
because we can just use the Peer Feature Negotiation BIP instead.

**Mike Schmidt**: So, is this more like permissionless feature adding to the P2P
network, that instead of having to get it to 70018 to add your thing, you can
just add it, and as long as everybody who you're talking with is speaking 70017,
you can put in, I guess, little identifiers within the feature message, and I
guess an easier way to innovate at the P2P level; is that the idea?

**Mark Erhardt**: That is in effect, yes.  Now, when people want to use optional
features, they can just do the Peer Feature Negotiation per BIP434, and peers
that don't understand a specific feature will just ignore it.  So, yes, in that
sense.

**Mike Schmidt**: Awesome.  That wraps up the Stack Exchange.  We can move to
the Releases and RCs, of which we covered several already, but a couple remain.
And we can summon Gustavo for this segment.  What's up, Gustavo?

_Eclair 0.14.6_

**Gustavo Flores Echaiz**: Yes, perfect.  Thank you, guys.  So, in addition to
the major release of Bitcoin Core 32.1 and the three other maintenance releases
of Bitcoin Core, we also have Eclair 0.14.6.  So, this is a small security
release.  Once again, users are recommended to upgrade because malicious peers
could exploit some of the fixed issues.  And we're going to go into detail of
what these fixes were, but basically there's two categories.  One is about
multiple edge cases when handling splice force-closes, and the other one is
specifically in a feature called on-the-fly funding.  When a node requests
incoming liquidity from an LSP running Eclair, that node could trick the LSP
into opening a channel for him without paying him the channel liquidity fees.
So, we're going to go more into detail in the Notable code section about those
fixes.

_LND v0.21.5-beta and v0.20.6-beta_

The next item on the Release section is LND v0.21.5 and v0.20.6.  Both are
denominated beta versions and they're both maintenance releases of LND.  Once
again, users are recommended to upgrade.  And we covered the RCs of these two
releases in the previous Newsletter #428.  But briefly, there's multiple bug
fixes found here, besides the ones we covered in #428, which we have been
covering over the past few newsletters.  Such as, for example, in v0.21.5,
there's a fix about specifically auxiliary Taproot Asset channels, where a node
didn't include the auxiliary HTLC (Hash Time Locked Contract) signatures that
are required for recovering the Taproot Assets, an LND node would simply accept
a peer not including those signatures, which would then make an LND node unable
to recover those assets during a force-close if it had to recover the HTLCs
onchain.  So, now that new validation has been added.  But there's also a major
fix we are going to cover in a bit in the release in the Notable code section
about commitment feerates.  And yeah, I also want to add there's also multiple
other fixes related to the new SQL database implementation, such as excessive
memory allocation when parsing TLV records, SQL database deadlocks, and also a
fix for faster startup cleanup on SQL-backed nodes.

We jump on to the Notable code and documentation changes.  And once again, we're
going to skip through the first three items because we covered them earlier
during the episode.  Those were the three fixes of the new major release of
Bitcoin Core that were also backported into previous maintenance releases.

_BIPs #2130_

So, we jump in with the first item after those three.  We're in the BIPs
repository at PR #2130.  So, this merges a draft for BIP139, which specifies a
Wallet Metadata Export Format, that is a specific JSON format for exporting
wallet accounts and all other types of wallet metadata that haven't been
standardized yet.  We've covered this previously in Newsletter #399, when the
author, Pythcoiner, posted on the mailing list his proposal for such a
specification.  Murch, anything you would like to add, since you're the BIP
editor?

**Mark Erhardt**: Yeah, just wanted to clarify.  So, this allows you to export
all of the data except the private key material.  So, it would allow you to
produce a watch-only wallet maybe, but it will not allow you to sign.  And the
hope would be if this gets adopted by other wallets, it might be easy to move
between wallets using this export format.  Yeah.  So, if this is something that
interests you, maybe give it a read.

_Core Lightning #9627_

**Gustavo Flores Echaiz**: Great.  Thank you, Murch.  So, now we jump in into
the Lightning section, which once again, as we've seen throughout the last
multiple weeks, there's multiple bug fixes.  First, Core Lightning #9627.  This
is a specific issue where when selecting a payment route to make a payment over
the LN and using specifically the xpay command for doing so, it could find
routes that were very long.  However, it wouldn't account for the BOLT4 rule
around the routing information limit of 1,300 bytes, which meant that it could
select a very long route and then, when constructing the onion, the payment
would simply fail because the selected path exceeded the limit.  So, the fix is
very clear.  Xpay simply has to account for that limit before selecting a
payment route, because potentially it could have selected another route that
would have been shorter and would have fit in that size.  But because it wasn't
accounting for that limit when finding the route, it was choosing a long route
that would later fail without thinking of this in advance.  So, now the fix
applies that accounting before, and it also passes the corresponding hop limit
to another function in CLN called askrene, which is also another pathfinding RPC
command.  And also, the pathfinding cost calculation adds a penalty for each hop
to favor shorter routes.

_Eclair #3417 and #3419_

The next item is one of the ones that I was mentioning in the Release section.
This combines two different PRs, #3417 and #3419.  #3419 was merged into #3417.
So, if you would have looked at the code changes from #3417, everything is
included there.  However, I'm going to cover first what was in #3417, and then
what came later with #3419.  So, here we're going to first discuss what is the
setting.  The setting is usually force-close handling when splice transactions
are unconfirmed.  And we've covered similar cases in Newsletter #427.  So, maybe
if you've listened to that episode or read that newsletter, many of these fixes
will sound familiar.  So, there's four different steps to the first PR.  The
first one is a new setting that comes in, called
require-confirmed-inputs-for-splicing.  This one is enabled by default.  And it
basically means that an Eclair node will not accept a peer adding inputs to a
splice-in transaction that have not yet confirmed on the Bitcoin blockchain.
Why?  Because I believe this is exactly the vulnerability covered in Newsletter
#427, which is that the peer could then double-spend the inputs he added into
the splice-in if those were unconfirmed.  And that would invalidate the splice
transaction and would also invalidate any commitment spending it and could lead
to issues that we saw in Newsletter #427.  So, now that setting is enabled by
default.  Also, part of that change is limiting how many inputs or outputs a
peer can add to a splice transaction.  The limit by default is ten inputs and
ten outputs.

The second change of this PR is that Eclair sometimes would fail to choose the
usable commitment when force-closing.  It could get confused in a situation
where there's an unconfirmed splice, but also the required commitment for
force-closing could change.  So, now Eclair always makes sure to check its
Bitcoin Core backend to choose the newest commitment whose funding transaction
is confirmed.  For example, if I'm trying to force-close when the splicing
transaction is unconfirmed, I could have used the commitment of the funding
transaction before the splice.  But if then the splice became confirmed, I
should use the commitment of the splice, right?  So, now Eclair has the proper
code to choose the usable commitment when force-closing, and also reconsider
that choice as conditions change.

The third part of this PR is that Eclair, when force-closing, once again, during
an unconfirmed splice, specifically for zero-fee anchor channels, Eclair would
have previously failed to consider the splice weight when making a CPFP
transaction for the commitment, and also the anchor that spent that commitment.
So, now Eclair includes the unconfirmed funding ancestors when calculating CPFP
fees to include every unconfirmed transaction.

The fourth item and final of this PR, before we move on to the other PR that is
also part of this item, is the fact that Eclair should claim outputs promptly
when the peer closes using an earlier funding state, which means that, for
example, your peer publishes a commitment for an earlier funding state.  Eclair
previously waited for the configured confirmation depth before claiming the
outputs.  So, for example, if Eclair had a setting of waiting six confirmations,
it would wait for six confirmations.  However, what if some HTLCs were
approaching a deadline at the same time?  And what if Eclair had to claim those
HTLCs at the second confirmation?  And that's the issue we used to run in.
Eclair was unnecessarily waiting for too many confirmations.  And now, the fix
is for Eclair to simply wait for one confirmation.  If it has to rush because
the HTLCs are approaching a deadline, it will claim those outputs before
reaching the full configured confirmation depth.

Then, the other item, which is also very related, the PR puts this example.
There's an unconfirmed splice, and Eclair force closes by publishing the
commitment spending that splice, the outputs of that splice.  However, what if
the splice disappears from Eclair's mempool?  Then, Eclair would have switched
to another commitment that would spend the original funding output.  Eclair now
assumes the splice has disappeared, will not confirm, so it now tries to
force-close the original funding output.  However, a miner could still confirm
the splice transaction even if it disappears from Eclair's mempool.  Previously,
Eclair would have failed to publish the commitment.  Excuse me, no, the miner
confirms both the splice and the commitment force-closing the channel based on
that splice state.  So, now Eclair will simply recognize that the miner did that
and that the new state is that the first intended commitment transaction is the
one that got confirmed.  Previously, Eclair would fail to recognize the change
that happened in between.  And that's for that Eclair item, which is the main
one in the release we covered previously.

_Eclair #3416_

And the second Eclair item, #3416, this PR is completely different.  This is
about when I, as a node, request liquidity from an Eclair LSP.  Because I want
to receive a payment over a channel that has reached its maximum liquidity, so
Eclair simply adds additional liquidity by splicing that channel or in a
completely different new channel, right?  If I, as a node that requested that
liquidity and also committed that I was going to pay the fees for that new
liquidity from the payment, if I rejected the payment, Eclair could still
complete the channel opening.  So, I basically rejected a payment that would
have paid Eclair for opening a channel, but Eclair would still proceed with
opening the channel.  The problem before is that Eclair wouldn't flag this as an
underpaid purchase.  So, I, as an attacker peer, I could have just done this
repeatedly.  I could have requested one channel after another from Eclair and
never paid for the fees required for opening that channel.

Now, the fix is for Eclair to flag that that purchase was underpaid, still allow
that channel to be open, however block the peer from making further purchases of
liquidity, specifically with the setting that they're going to pay it from
future payments, also called from_future_HTLC.  Also important to specify that
if the payment was a multipath payment and I had simply refused a part, the fact
that the other parts succeed doesn't clear the flag.  Also, there's a specific
limit called the suspicious-peer limit that applies to all peers, and flagged
peers count towards that limit, which means that if too many peers are abusing
Eclair's LSP and getting liquidity without paying the fees, Eclair can simply
disable the payment method globally for all peers.  And the flags are cleared on
restart, or an operator could intervene and also remove the flag for a specific
peer.  Or if the funding transaction that opens the channel is aborted before
publication, that also removes the flag.

_LDK #5314_

So, now we jump in into the other repository, LDK.  This one has two fixes as
well.  The first one is a privacy leak, similar or related to a change we
covered in Newsletter #426, where LDK made SCID aliases the default when opening
new unannounced channels.  Now, the privacy leak that we're covering in this
newsletter is that an attacker that is watching funding outputs in the Bitcoin
blockchain could derive a candidate SCID from an output's blockchain location;
and by deriving that SCID, and connecting to suspected channel endpoints, this
is a specific case where an attacker is suspecting that two nodes that share a
channel, he's suspecting that that channel was funded via this output that it
has already identified on the Bitcoin blockchain.  So, this is not an attacker
guessing; this is an attacker that has a specific thesis of two nodes and a
specific funding output.  So, he connects to both channel endpoints to both
nodes and sends an onion message through them back to itself.  So, the onion
message routes through both peers and it comes back to itself.  And it uses the
SCID that it derived from the funding output on the blockchain to identify the
channel between them.  And if he's able to receive the message back, it confirms
that the unannounced channel that these two peers share was funded with the
specific output from the blockchain.

So, the fix is for LDK to resolve real SCIDs for unannounced channels.  So, an
LDK node will simply refuse to route that onion message, unless SCID aliases are
used.  So, that's the first item from LDK.

_LDK #5412_

The second one is a DoS bug in the LSPS2 server for just-in-time (JIT) channels.
So, what does this mean?  When a client connects to an LSP server to request a
JIT channel, which allows it to receive, similar to on-the-fly funding, it
receives a payment on the LN without having a channel there in advance.  So, an
LSP server is constantly monitoring for requests from different clients.  A
client could make a request for a JIT channel.  And then, the client could have
made a second request using the same request ID of his first request.  The
problem is that LDK has a request limit globally for all peers.  And if I, as an
attacker, am making different requests with the same request ID, LDK was
accepting that request, was replacing the stored entry with the new request, and
was counting that towards its request limit.  So, it means that an attacker
client could have made, let's say, 1,000 requests with the same request ID, and
that would have exhausted LDK's 1,000-request limit queue, and it would have
made the LSP reject requests from other clients.

So, now the fix is once again pretty clear.  LDK simply has to reject duplicate
IDs, because clearly an attacker is trying to just duplicate requests to exhaust
the limit, without increasing the counter, but also without replacing the
original request, because that was also a separate issue.

_LND #11164_

Now, we are into LND with two items, and finally the last item will be BTCPay
Server.  So, the first is a feature, not a bug, where LND, in PR #11164,
advances the implementation, also known as gossip-v2, which would allow nodes to
announce and verify taproot channels.  As we've covered previously in the BOLTs
specification of taproot channels, but also in the implementation of taproot
channels for multiple Lightning implementations, this is a known gap that nodes
can simply not yet announce and verify taproot channels via the gossip protocol,
because the existing gossip protocol doesn't yet support taproot channels.  So,
LND is not fully done with this, of course, because the taproot gossip proposal
remains in draft mode.  Well, the PR simply hasn't been merged yet to the BOLTs
repository, but multiple steps are taken by LND to match the latest proposal.
And those steps include, for example, the signature-exchange messages now
include the funding transaction ID to distinguish funding attempts and splice
attempts, right?  You really want to be able to track which funding transaction
this signature-exchange message corresponds to, whether it's the initial funding
or for splicing.

There are also fixes, such as the changes also correct the encoding of the fee
and capacity fields and preserve optional fields containing default values.  The
main point of that is to preserve the signed bytes when messages are decoded and
re-encoded.  That's very important to avoid signature verification failures.
So, multiple fixes are made for that.  Once again, as I said, this is not yet
work that is done.  We should expect probably another round of improvements to
the taproot gossip proposal that will eventually get merged into the BOLTs
repository.  LND would eventually turn it on or complete this implementation
only after that is done.  Also, important to specify that LND is taking steps in
preparation for splicing, but LND hasn't yet completed its splicing
implementation.

_LND #11373 and #11380_

And finally, the next item on the LND repo combines two PRs, #11373 and #11380.
Both of these together enforce LND's existing minimum commitment feerate of 253
sat/kw (satoshis per kiloweight) unit consistently during channel opening and
fee updates.  The problem here was that there's another setting that was
clashing with this setting.  That other setting is called
max-commit-fee-rate-anchors.  When set at 1, it would cap the rate at 1 sat/vB
(satoshi per vbyte), which is equivalent to 250 sat/kw unit, which is just under
the minimum.  So, you could put a maximum that was under the minimum, and those
two settings would clash.  What would happen, for example, if you were opening a
channel, it would have been okay because the second setting that was set lower
was when opening a channel, it was following that setting.  But then, when
trying to sign commitment updates to carry HTLCs, it simply triggered an issue
because it couldn't sign those commitment transactions, because it was trying to
apply a fee that was lower than the minimum commitment feerate.

So, now the fix for that is simply for LND to raise locally-proposed opening
rates to the minimum, right?  It will simply not, even if it sets a lower amount
on the other setting, it will simply not follow that when signing commitments.
Also, when checking incoming and outgoing fee updates against the minimum before
recording or sending them, it also now starts doing that instead of only
rejecting them when signing commitments.  These fixes are not necessarily
backported to all channels.  For example, if a channel initiator cannot afford
the increase in the feerate, the channel will remain unable to carry HTLCs, as
it would still hit an error when trying to sign a commitment transaction because
of this previous, even if it changed the setting.  If it's unable to afford the
fee increase, it will simply remain unusable.

_BTCPay Server #7744 and #7748_

And finally, the last item is a combination of two PRs from the BTCPay Server
repo, #7744 and #7748.  These two are fixing errors when merchants authorize API
keys, very similar to what we covered in the last Newsletter #428.  And in #428
we had specifically covered a privilege escalation in the API key authorization.
This is once again very similar.  Here, the two errors are that first, if a
merchant unchecks specific optional permissions, BTCPay Server could have
ignored the fact that the merchant unchecked those permissions, and the API key
would still have been granted those permissions.  And the other bug is that an
application could have requested a permission scoped to another store, even if
the merchant had given that application only permission for a specific store.
So, now the fixes preserve the merchant's permission choices, and yeah, that's
the main story around it.  And like I said, Newsletter #428 is a precursor of
this, and both are related to API bugs around API key escalation.

**Mike Schmidt**: We continue to see a lot of fixes, unsurprisingly, some
features, but a lot of fixes.  Thanks for walking us through that, Gustavo.
Thanks also for co-hosting.  Thanks for co-hosting, Murch.  And we want to thank
our guests today, Elias, Greg, Antoine, Oleks, and Nishant for joining us
earlier, and for you all for listening.  We'll hear you next week.  Cheers.

{% include references.md %}
