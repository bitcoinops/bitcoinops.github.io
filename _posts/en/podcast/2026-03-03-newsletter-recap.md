---
title: 'Bitcoin Optech Newsletter #394 Recap Podcast'
permalink: /en/podcast/2026/03/03/
reference: /en/newsletters/2026/02/27/
name: 2026-03-03-recap
slug: 2026-03-03-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark “Murch” Erhardt and Mike Schmidt are joined by Craig Raw and Fabian Jahr to
discuss [Newsletter #394]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2026-2-3/419224492-44100-2-244e6f6437741.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #394 Recap.
Today, we're going to be talking about a draft BIP for output script descriptor
annotations, and we also have our monthly segment covering questions and answers
from the Bitcoin Stack Exchange.  This week, Murch and I are joined by two
guests.  First, Craig.

**Craig Raw**: Hey guys.

**Mike Schmidt**: Craig, folks are probably familiar with you, you were on
recently.  But do you want to give a quick explanation of the kind of work you
do in Bitcoin?

**Craig Raw**: Yeah, sure.  So, I am responsible for building Sparrow Wallet,
which is quite well-known in the Bitcoin world.  And I've recently been doing
some silent payments work, particularly around the BIPs.  So, yeah, that's kind
of what I'm busy with these days.

**Mike Schmidt**: We're also joined by Fabian.  Fabian, what do you do?

**Fabian Jahr**: Yes, I'm a Bitcoin Core open-source developer, so mostly
focused on Bitcoin Core and supported by Brink, but I also spend my time a bit
to some more research topics around new BIPs and also exploring secp256k1 as
well now.

**Mike Schmidt**: Excellent.  Thank you both for joining us.  For those
following at home, we're going to start with the news section with Craig, and
then we'll move to Fabian's item, which is actually from the Notable code
segment.

_Draft BIP for output script descriptor annotations_

"Draft BIP for output script descriptor annotations".  Craig, you posted to the
Bitcoin-Dev mailing list about a draft BIP for output script descriptor
annotations.  It sounded like this came out of your work on your other proposal
for silent payment output script descriptors, which has BIP392, I believe.  We
had you on to talk about that in Optech Recap #387, and you had mentioned during
that discussion that there was some consternation that some folks had about
including certain types of data in the descriptors.  Maybe you can recap that
discussion a bit, and then we can get into what you've come up with as a
potential solution.

**Craig Raw**: Yeah, sure.  So, in the development of the output descriptive
format for silent payments wallets, we came across these two kind of conflicting
needs.  One is that silent payment wallets, because they are computationally
very heavy when it comes to scanning, they really need the advantage of knowing
where to start, so what block height to start on.  Without that, it can really
become impossible, for example, for a mobile wallet to ever actually recover a
wallet, because it has to start from the very beginning, which is generally
considered to be taproot activation.  So, that's the one need.  The other need
is that output descriptors generally never have something like a block height in
them, because it's considered to be extraneous information, sort of metadata
which is not absolutely required to create the output scripts.  So, we have
these two kind of conflicting reasons, one to add them, one not to.  And in the
end, the BIP for output descriptor annotations is what emerged.  So, it came out
of a discussion that I was having, as you referred to, Mike, which is really
just talking about how to manage this tension between what we put into a
descriptor and what we leave out.

**Mike Schmidt**: Awesome.  So, the idea is for this additional metadata, I
think you had a creative way of using a URL-like delimiter to sort of append
those key values to the script, right?  And then, the follow-up would be,
included in this proposal is also the first usage of that, which would be for
the birthday, right?

**Craig Raw**: That's right.  So, there's basically this annotations format.
So, what an annotation really is, is just some extra information about whatever
the thing is, so that's all that we're trying to do here.  We're trying to
provide some additional information, which can assist in the reading or the
parsing of this particular piece of information, the information being the
output script descriptor.  Now, the additional information that we can provide
here that is of use, we currently have three different keys that we can add.
According to the BIP, we can add the block height, which I mentioned, very
important for silent payments wallets, but also quite important for normal HD
wallets, because often, for example, in Bitcoin Core, in that wallet, you need
to start from a particular block height, or at least you would want to because
it makes the scanning process take much less time.  So, that's actually quite
useful across all wallets.  And then, we have this idea of the gap limit, which
is an HD wallet-only thing.  So, we have an idea of how far ahead in the chain
are we going to look for addresses that have funds in them.  We have to stop
after a certain point; what is that point at which we stop?

So, wallets have defaults but often you end up in a situation where, for
example, you might have a customer who's requested many addresses without paying
to them, and then you have a gap limit which extends out beyond that default.
And this allows us to specify a higher number than that default and put it right
there into the output descriptor so we can recover that wallet.  And I'm sure
that there'd be people out there who've had to increase the size of that gap
limit variable before in order to properly recover all the funds in their
wallet.  So, that's the second key.  And then, the third one is a silent
payments wallet one, which most people will not be aware of.  There's this thing
called labels.  It's a bit of a contentious thing because labels do increase the
scanning burden, every label that you add increases the burden that you place
onto the client wallet that's trying to recover the funds.  But at any rate, we
need some kind of a way to be able to say, "There might be funds at these
additional labels".  And this just basically sets an upper bound for that in the
same way that the gap limit sets an upper bound.

So, those are the three different keys that you can specify.  And you do that
very simply with what looks like the kind of key value pairs that you put onto a
URL.  So, it's a question mark at the end of an output descriptor, and then
key=value.  And they're quite short, because we want to keep them short for QR
codes.  So, it's just BH for block height, and gap limit GL, and then max label
ML.  So, those are the three different keys.  And that's really it, they're just
integers in the values of those.  That's the entire BIP.

**Mark Erhardt**: Maybe just very briefly, the label count is also just set by
the user of the wallet.  So, I believe you publish a different public scan key
if you have a different label, right?  So, it wouldn't be that someone else
decides to send to a higher label, but the wallet owner would publish another
label.

**Craig Raw**: Yes, that is correct.  But of course, if you wanted to recover
that wallet on some other wallet software, you would need to have some record
somewhere of how many of these labels you had created in the past.

**Mark Erhardt**: Yeah, and then maybe let me just try to jump in and explain
why this is a separate proposal.  So, I think the contention in that discussion
was the output script descriptors describe how output scripts are constructed,
the pattern of output scripts that the wallet receives funds to.  And obviously,
the information on when a wallet was started to be used or how big the gap limit
would be or how many labels there are, are not really related to the output
script pattern.  So, this is a separate piece of information that pertains more
to the meta information about the wallet.  And that, I think, was why there was
pushback on including that in the output script descriptor directly.  So, it's
this second annotation on top of the output script descriptor instead.

**Craig Raw**: Yes, I think that that's a very accurate way of saying it.  Yeah.
I think it's, you know, we're just speaking very practically.  I've experienced
a lot of people in the past who've had issues trying to recover wallets just due
to practical things like, "I haven't seen all my funds yet".  And the general
advice, in fact one of the very common things that you will get if you say that
is, "What is your gap limit?  You need to increase that".  And then, that is
usually the answer.  So, just having a way that people don't have to think about
it, don't have to go through that support process, it's just there; and so, I
think going to be quite useful.

**Mark Erhardt**: Yeah, I think all of these are very useful and important to
have.  I think maybe it would also be time to generally just work with bigger
gap limits by default.  But then, of course, that introduces the problem that if
someone were to actually go even beyond that, you'd have to increase it again to
scan.  But yeah, so being a BIP editor, I saw your draft already and it had a
very good early showing.  Have you heard any more feedback on it?   Someone told
me it's going to get a number soon, I think.  And is there any other open
questions or thoughts that you've been noodling on that one?

**Craig Raw**: No, actually, I think it's one of those ones which has just kind
of come together as a natural flow.  I'm probably going to jinx it just by
saying this, but it seems to be the least contentious proposal that I've put
forward.  So, yeah, I think anybody who's been in Bitcoin for any length of time
knows that this is a pain point and is happy to see some kind of an answer.  I
think all of the silent payment wallet devs particularly know that this is going
to be a pain point and need some kind of an answer.  So, that's where I think
it's at.  But yeah, not a lot of feedback at this point.  I think people have
seen it, it obviously was in the Optech Newsletter last week, and we'll see if
there's any feedback based on this interview now.

**Mark Erhardt**: Yeah, and maybe just to double-down on what knowing the birth
date of a wallet would mean, because I think that one is the most interesting
out of the three to dive into a little bit.  So, for a silent payments wallet,
you have to basically scan every single P2TR output that still exists in order
to recover all your funds.  And to get your full wallet history, you actually
have to scan all the P2TR outputs that were created since your wallet was
created.  So, by knowing the block height at which your wallet was created, or
at which it received funds for the first time, allows you to just only scan from
there, only scan the subset of P2TR outputs that were created since then, and
only search for the wallet history from that height, which could, given that
taproot's been out for, what, four years now, would significantly cut down the
number of P2TR outputs you have to scan.  And if you have a light wallet or a
mobile phone wallet that is doing the scanning, this will mean that you get
access to your funds way, way quicker.

**Craig Raw**: Yeah.  And I think if you just project out another four or five
years and expect those poor mobile phones to have to scan through all of that
with increasing taproot usage as well, I really think we're going to have to
avoid scanning from the start; we're going to have to scan from a later date.
So, yeah, that I think explains it well.

**Mike Schmidt**:  Craig, talk to me about this key value URL-like appending.
Is that just a simply an elegant way, since those characters were already
defined and supported, for you to get this data in with the existing descriptor,
or is there more going on there?

**Craig Raw**: Yeah, it's actually a good point.  So, in doing this output
script descriptor work, both of these BIPs, I've had cause to go back to the
original BIP380, which is the first sort of defining BIP for how these things
work.  And if you read the motivation for that BIP, it's actually around
backups, it's actually around how do people backup their wallets.  So, this is
clearly intended to be a format that is used by people, by actual users.  It's
not just a dev kind of thing.  And as a result, I think having a format that is
human-readable and not too techie, and it's not like a binary thing, it's not
JSON, I think that that's kind of the really intelligent part of it, and I think
you want to stay within that.  So, a lot of people, when they think of how to
solve this, they needed to think of all these other formats.  But actually, you
kind of look at it and you think, well, a URL and the parameters of a URL are
one of the most well-understood things.  Sure, not everyone understands them,
but most people can look at them and take a guess at what it is.  So, it kind of
makes it a really human-friendly thing, and I think that that's very important
for what is effectively a backup format.

That kind of thinking has guided all of my work in terms of this development.
It's just everyone kind of knows at the end of a URL, you've got this question
mark, and then you've got these key value pairs, which are separated by
ampersands.  And that's effectively all that that does, is it just reuses that.
And they all happily are part of the legal characters allowed by BIP380, so it
kind of already fitted in there.  And of course, we have the ability to add
further key values to this at a later date.  These are not the defined end point
of this, but we can obviously evolve this over time as new wallet types might
evolve in the future.

**Mike Schmidt**: Excellent.  That was all the questions from me.  Murch or
Fabian, anything else?   Craig, do you want to give a call to action to any
listeners, other than read the draft BIP?

**Craig Raw**: Yeah, I mean nothing other than I think what people have heard.
If you have any other thoughts, send them through.  But I do think it is a
pretty straightforward BIP.  So, yeah, hopefully we can start using it soon.

**Mike Schmidt**: Awesome.  Thanks for your work on this, Craig.  Thanks for
joining us.

**Mark Erhardt**: Yeah, thank you.

**Craig Raw**: Sure.

_Bitcoin Core #28792_

**Mike Schmidt**: Cheers.  We're going to jump to the Notable code and
documentation section of the newsletter here, because we have Fabian to talk
about Bitcoin Core #28792, which bundles embedded ASMap data directly into the
Bitcoin Core binary.  We want to talk with Fabian about, what data are we
talking about?  What is ASMap?  Do you pronounce it ASMap or A-S-Map?  Take us
from there, Fabian.

**Fabian Jahr**: Nobody knows!  It's also which letters you write, in which way,
is even contentious.  But I give up trying to streamline that.  But what matters
is the functionality, so let's focus on that.  So, ASMap, the first part maybe
that's not so clear to everyone, is the AS part.  AS stands for Autonomous
System.  And on the internet, to be precise, the clearnet that we are using
every day probably, it's the name for the entity that controls IP addresses.
So, Autonomous Systems can control any number of IP addresses.  Usually, they
are bundled in what's called a prefix.  And so, if you have an IP address in
front of you, in your head, the part that's more to the left, it's a larger part
basically, like in a normal number.  And the part that is in the back, the
smaller numbers, they are often controlled by the same entity.  But that doesn't
have to be always the case.  Autonomous Systems can control a large variety of
IPs that look very differently.  And so, that's what's in the AS map itself.  It
maps the Autonomous Systems, which also have numbers, to the Ips, and it tells
you, in a very compressed format, which Autonomous System controls which IPs.
And that's very important for us, or it can be very important for us, to use it
for basically deciding which peers we make a connection to, to ensure that we
connect to peers that have a diverse way of accessing the internet, so they
cannot intercept it or be controlled, of course, in some kind of way.

Currently, Bitcoin Core already does something to try to get a diverse set, but
they just look at the IP because that's all the information that there is right
now.  And the functionality for ASMap was already added to Bitcoin Core earlier.
However, the information of the map, that was not readily available.  So, you
needed to source this information from somewhere, upload it into Bitcoin Core,
and then this functionality was available.  But of course, it's something that
not a lot of people are doing.  It's often mentioned probably on a podcast as
well that defaults are often not changed.  And so, yeah, that's why there was a
need for adding this data into the binary directly.

**Mark Erhardt**: All right.  So, ASMap is basically a map of who controls what
parts of the internet.  And one of the ways that that is relevant to us is to
protect us against eclipse attacks or Sibyl attacks.  So, when there is someone
that spins up a ton of nodes, they are all with the same provider, the ASMap
will tell us that all of these IP addresses, even if they look different, they
are controlled by the same Autonomous System.  And therefore, we should
categorize them as potentially, or more likely to be controlled by the same
entity, right?  So, it sort of guides us to who we want to connect to, as in
peers, and diversify the peer connections that we have, to get them away from
being controlled all by the same entity, right?

**Fabian Jahr**: Yes, that's right.

**Mark Erhardt**: So, far so good.  So, I saw recently in the Bitcoin Core
meeting that a few people were talking about coordinating the ASMap readout.  Do
you want to tell us a little bit how it works that we can trust this ASMap?

**Fabian Jahr**: Yes, sure.  So, first of all, why is this something that is so
complicated that I'm going to explain now?  What we're basically doing is a map
of the internet, and the map of the internet is constantly changing.  There are
messages to the order of several hundreds to thousands in a second, or
definitely within a minute, that are flying around, that are changing who
controls which IPs.  And so, what we're really doing is just a snapshot.  And we
want to just minimize the snapshot that we're producing.  And the way that we do
it is that we do it at the same time across different computers for different
people, so that we can see that several people got a match between the maps that
are coming out of this process.  And so, we know, okay, we don't just have to
trust one person that created it, but rather we can trust that the set of people
is trusting this.  And kind of the bar that I set there roughly is similar to
any PR to Bitcoin Core, it's being reviewed by several people and only when
several people give an ACK, then it's merged.

So, I wrote a software that does this, where you basically can give a timestamp
and at the exact timestamp, it's going to start this process.  It's pulling data
from different sources and merging them in a way that is reproducible and it's
the same across all computers, independent of if the computer is slow or fast,
or whatever.  And so, this still doesn't solve all processes, all potential
problems, but there's a high likelihood that the majority of the people that run
this process, usually it is even better, we had like 80%, 90% of people also get
the same result.  And so, when you see, for example, ten people doing this
process and they are all Bitcoin Core developers that are usually trustless,
that they do a good job with writing the code that you run and reviewing the
code that you run, that eight or nine of them got the same result, then you
should be also able to trust that the data that is in the map is also something
that is not malicious.

**Mark Erhardt**: Yeah, I saw the PR.  There was a bunch of responses right
around the same time and people produced the same fingerprint.  And then, there
were a couple that got different results.  And finally, the one that the vast
majority of the responses agreed on got merged into Bitcoin Core.  So, this is
shipping with v31, but it's not on by default.

**Fabian Jahr**: Exactly, yeah.  So, the on by default, of course, is something
that would be great to do in the future, and that's a goal for the future.
However, there are still some questions about implications for this.  And also,
it's something new, there's some process outside of the code.  It's not just new
code that we're adding, but there's a whole process of doing this, what I just
described for each release, because these maps are also getting outdated.  So,
we need to do this again and again for every release.  It's fine to raise some
questions, but it's good already now that people just have basically to give an
argument and not to source some file from somewhere on the internet.  So, this
is one step in this progression and then hopefully in the future, we are sure
enough that the process works and the data is fine and that it helps us with the
network, and then we will turn it on by default.

**Mark Erhardt**: All right.  So, currently I think people run with the -asmap
flag to start using the ASMap, but do you have any data on how quickly this map
outdates or becomes less useful?  Does it deteriorate within months or is it
years or days?

**Fabian Jahr**: Seconds even!  So, like I said, every second there's
announcements that change what the routing is and then that also affects the
map.  So, technically the map is outdated at the moment when this run that I
described earlier finishes.

**Mark Erhardt**: You're not selling that right now, you're not selling it!

**Fabian Jahr**: Yes, I know.  But the thing is that the data is still good
enough largely.  So, there is some data that changes very frequently, even
there's some stuff that just basically flip-flops all the time, and it's kind of
known that it's kind of meaningless that this happens.  And then, over time,
this data outdates to, I think we saw roughly 1% or so per month if you lay it
out, and maybe like 10% per year or so.  So, this is just estimates based on the
data that we've created historically from the maps.  However, the underlying
belief of why we think it's still great to add these maps to Bitcoin Core and
even to use this with a release that is maybe like three, four months old, is
that this knowledge still is way, way better even when it's outdated for one or
two years than using just the IP, like the current default that we're doing.
It's just really not helping much at all, because just looking at the IP is just
not giving us much information in terms of preventing eclipse attacks, etc.  So,
even some outdated maps will still be very helpful.

**Mark Erhardt**: Right.  So, the bigger Autonomous Systems are pretty stable,
the Amazons, the Hetzners, and so forth, and they will remain on their IP
addresses pretty stably.  Smaller ones might switch a little more.  But
generally, this just gives you a better understanding of what to map together
and it continues to be useful.  Would you say that you're going to do a new
ASMap snapshot for every point release then too?

**Fabian Jahr**: Yeah, I mean usually with the point releases, I think they're
now a bit more away from the major releases.  It used to be that more came out,
I think, closer together, maybe it's just my memory wrong, but I felt like
initially when I made this plan, that we would just put the same map that we put
in the major release into all of the point releases that are coming around at
the same time.  But if they are drawn out, then we could also put a different
map into these.  But yeah, I think doing a point release is a good opportunity
to update the map as well.  And so, what we're really doing is we are, at least
right now, producing on a monthly basis at least one new map.  So, there's
always one recent map that is less than four weeks old that you can take from at
any point in time.  And if there's a need for it, we can always do this process
more or less simultaneously, or we could increase the frequency of this if it's
necessary.  So, yeah, anytime there's a point release needed and we want to
update it, that is potentially there.  However, there was not a big discussion
that this is now a rule that we fixed already, but I think that's what we should
do.

**Mike Schmidt**: Fabian, you may be understating the engineering effort or the
challenge that was ahead of you with putting this together.  Do I remember
correctly that you went to one of these internet networking conferences, or some
such thing, and talked to people about the feasibility of even aggregating this
data, and they said it was impossible; do I have that memory correct?

**Fabian Jahr**: Yeah, roughly that's the way it went.  I mean, I took over this
kind of, I wouldn't say responsibility, but the project had been going on for a
while.  Like I said, the feature was implemented in Bitcoin Core, but then this
data-sourcing stuff and so on was not really being worked on.  So, I kind of
started working on that in 2022.  And I also had still a lot to learn of how
this worked and how the players kind of acted and where we could get this data
in the best trust-minimized way, basically.  And so, there's not a lot of good
documentation there.  If you think Bitcoin Core documentation is not ideal, this
is way, way worse.  It's a lot of old school.  This is not 15 years old, like
Bitcoin, but it's like 30, 40 years old technology, and a lot of big
corporations that don't really care about writing anything open-source or
putting it on the internet in the open, but rather they meet in suits in
conference rooms and that's where the knowledge is exchanged.  And so, yeah, for
me, it was really a big breakthrough that there was a conference that just
happened to be around the corner from where I lived, at a point where I had
already spent a couple of months looking into this, but really feeling unsure
about the insights that I had gotten so far.

So, I went to this, it's called a RIPE conference.  RIPE is basically the
European authority on the internet across the continent.  And so, there I met a
couple of people and interviewed them about what they thought about it.  And so,
I got some good feedback from some people that were more open-minded, I guess,
on this kind of project.  But also, some people straightforward said, "No, this
is impossible".  And basically, what they meant is impossible is like what I
said, like this data changes every second.  And so, getting a snapshot across
different computers or getting an authoritative snapshot in some kind of way is
basically impossible.  But yeah, this still works out great for our purpose.
But that's kind of the reason why we have this majority rule of most people that
run this process should get a match and not everyone can have a match all the
time.

**Mark Erhardt**: So, are you going to go back and tell them what you've
achieved and show them that it was possible?

**Fabian Jahr**: Yes, I would really like to do that.  I haven't really found
the time to look at this opportunity.  I have to say, at this conference also
not everyone is a Bitcoin fan.  So, I'm not sure how it would be received if I
asked to give a talk.  But yeah, I want to try at least once in the future.

**Mike Schmidt**: Are there other parties, projects, interested in this data
set?  I don't remember if, in our discussion here you've mentioned, but there's
this cartograph tool.  Are there other people interested in the tool or the
resulting map for their own uses?  I guess it could be other crypto projects,
but I'm more curious about things even outside of that.

**Fabian Jahr**: Yeah, I haven't really done any marketing on it yet, but it's
potentially interesting for any kind of distributed network that wants to have
protection and wants to have diversity in terms of peers.  So, for example, what
Tor does is Tor has a mapping of IPs to countries.  It's called GeoIP.  And so,
it's basically the same thing, just there's a country instead of the Autonomous
System number.  And the background for them is they have a bit of a different
threat model than we have for Bitcoin.  They are more afraid of state-level
surveillance on dissidents and big walls around countries.  And so, that's why
this data makes a bit more sense for them.  But I think, for example, the ASMap
would also be helpful for them in addition to that.  Somebody talking also that
they find this interesting, this approach that we've taken, and the map that
they are using is basically coming out of a proprietary system that gives it to
them for free, for a license that allows them to use it in their context.  But
there's no reproducibility, there's no transparency how this data is really
constructed.  So, I think this approach could be possible for them as well.  And
so, yeah, maybe it's interesting for them in the future.

**Mark Erhardt**: So, how possible would it be to derive the country information
from the ASMap?  Is that readily available, is that right there?  It would need
to come from a different source.  All of that information is also available.
So, there, I would need to add some additional research in terms of what the
best source is.  But this is a bit easier to get even than the information that
we're using now.

**Mark Erhardt**: Well, it would be pretty cool if you could support Tor in that
way.

**Fabian Jahr**: Yeah, I agree.

**Mike Schmidt**: Very cool work, Fabian.  Thanks for coming on and discussing
this particular PR, but the broader initiative I think is interesting for folks
as well.  So, thanks for your time.

**Fabian Jahr**: Yeah, anytime people want to contribute to this as well, it's
not just in Bitcoin Core, but there's also this ASMap GitHub organization where
we have the related repositories, the cartograph project, it's in Python.  So,
if you're interested in that, feel free to come along, try it out and
contribute.

**Mike Schmidt**: And do you have scheduled times that come out where people,
like listeners, could see if there's like a notice that this is going to be the
next day where we all run it, whoever wants to participate in it runs it?
People may want to do that.  What's the timing of that kind of thing?

**Fabian Jahr**: Yeah, so currently we do it on the first Thursday of the month
usually.  Not sure what exactly the times, but always the same time, I think
4.00pm CET or so roughly.  And yeah, but we opened, like there's an issue on the
ASMap data repository that used to be in the ASMap org, but now it's in the
Bitcoin Core org, because that's where the data is stored, basically, that then
later goes into the Core releases.  But there, you should see several days, if
not weeks in advance, when the next run is happening.  And then, yeah, you can
take your time to configure a cartograph on your system and start it in advance.
And then, it's going to run and do its thing and then you can post your result
afterwards.

**Mike Schmidt**: Thanks again Fabian.  Cheers.

**Fabian Jahr**: Thank you.

_Is Bitcoin BIP324 v2 P2P transport distinguishable from random traffic?_

**Mike Schmidt**: We have our monthly segment on Q &A from the Bitcoin Stack
Exchange.  We picked out two this month.  First one, "Is Bitcoin BIP324 v2 P2P
transport distinguishable from random traffic?"  So, this is v2 encrypted
transport, BIP324, where communications between nodes are encrypted.  And this
person's asking whether it's distinguishable from random traffic, or if there's
things that BIP324 does to make it blend in with other types of traffic.  And
then Pieter Wuille, who helped out with BIP324, answered that BIP324 does
support traffic-shaping features.  And, Murch, correct me if I'm wrong, but is
that like the decoy packets, or is that something else?

**Mark Erhardt**: Yeah, I believe that's the case.

**Mike Schmidt**: So, you can contrive your own ability to send basically
garbage data, but an observer wouldn't know that that's not garbage data.  They
could think it's streaming encrypted video, or whatever.  You could throw off
observers with that.  But that is not supported in BIP324 implementations today,
but the hooks are there for somebody who wants to be able to decoy their traffic
even more.  Obviously, I think the data is random, but the amount of data that
you send and the timing of the data is not random, so these decoy packets would
allow you to confuse an observer.  Do I have that right, Murch?

**Mark Erhardt**: Yeah, that's right.  So, first, the handshake before you
actually start the encrypted connection would reveal that you always send a secp
point, you know, elliptic curve point.  So, that would be distinguishable from
just pure random data.  And then of course, for example, when blocks are found,
the blocks will propagate through the network.  And if you're an ISP and
watching node connections, you might see that, "Oh, this user always sends data
when a Bitcoin block was found.  So, probably, even though it's random, just by
correlating the timing, they're probably a Bitcoin node", right?

What is very interesting is because the encryption format is easy to mimic by
other parties, other parties could choose to hide their traffic as looking like
Bitcoin traffic.  And so, for example, the Tor network or encrypted chat apps,
or other applications like that, could choose to make their traffic look like
Bitcoin traffic.  And in that way, it is probably easier to get obfuscation out
of it than in the other way, because Bitcoin traffic will, by timing, always
look like Bitcoin traffic.  The Bitcoin transactions that go through the network
when there's big transactions, they will gossip through the network, when
there's blocks they will gossip through the network.  The initial handshake is
slightly recognizable.  We could stuff more data in there, but the actual
underlying Bitcoin data that flows would flow whenever that Bitcoin data flows.

Now, the interesting thing is because we use the mempools and compact block
relay to reconstruct blocks, the spike in traffic at block discovery is not as
big as it used to be ten years ago or so before compact blocks.  I'm familiar
with an anecdote of a well-known Bitcoin developer that was on a video chat with
a few colleagues and a Bitcoin block was found, and two of his colleagues' video
streams started stuttering for a moment.  And he's like, "Aha, running a Bitcoin
node".  That wouldn't happen as much anymore because the compact block
announcements are much smaller and most Bitcoin transactions should be available
in your mempool already, sent to you in the last hour or so before the block.
So, these spikes don't happen as much anymore.  But yeah, we can put more stuff
in there to make it look smoother or obfuscate that it's Bitcoin traffic
eventually.

_What if a miner just broadcasts the header and never gives the block?_

**Mike Schmidt**: Second question from the Stack Exchange, "What if a miner just
broadcasts the header and never gives the block?"  Murch, I know you jumped into
this one.  I don't know if you prefer taking this or you want me to go through
it.

**Mark Erhardt**: Yeah, I can talk a little bit about it.  So, we announce
headers first, right?  But headers don't propagate by themselves.  We only use
the block header announcement as a way of telling our peers, "Hey, we have a
block header and here is already the first 80 bytes of the block, which proves
that the PoW was done, which shows that it attaches to the previous block, and
so forth".  So, us using the block headers to announce that a new block was
found instead of the inventory message that was used before, it provides
strictly more information for just a little bit more bytes.  But the block
headers aren't forwarded without the block.  So, there is no such thing as block
headers propagating around the network without the blocks propagating around the
network.  When a block is found and a node tells its peers, "Here's a new block
header", that also indicates that the node is willing to give you the block.
And the receiving peers will immediately respond with, "Well, where's the block?
Give me the block too".  And then, only after receiving the block and processing
the block, they will forward the block header as an announcement to their peers,
unless they are in the high-bandwidth mode of compact blocks.  Even then, they
will first receive the entire block before forwarding it, but push out the whole
block without verifying it first, and only after their peers told them to do so.

So, this whole question is a little confused in that regard, because block
headers by themselves do not propagate.  But there is, of course, a thing called
spy mining, which I'm not sure how widely spread the practice is anymore,
because there was a huge hiccup in 2015, where upon activation of a soft fork,
someone mined an invalid block and then switched to mining on top of their
invalid block.  But all of their peers rejected the block as invalid because
they had actually upgraded to the soft fork already.  So, the block was invalid
per the new rules enforced by the freshly-activated soft fork.  And a bunch of
other miners started mining on top of that block template because they saw, "Oh,
miner XYZ switched over to a new block template.  They must have found a block
that they will be propagating around the network", but the block never came.
And they actually got, was it six?  No, I'd have to look it up.  I think in the
end, the chain got to some 30 blocks or so until -- no, I'm mixing that up with
the March 2013 chain split.  I think it was six blocks or so that were empty and
mined on top of an invalid block and they all lost their money on top of that,
because the chain was invalid because the first one was invalid.

**Mike Schmidt**: Well, Murch, maybe get into what is spy mining, because I saw
that that was referenced here in Pieter Wuille's response to the original
answer.  And then, I thought it would be interesting to talk about it, and I saw
that we hadn't really talked about it on Optech before.  So, what are the rough
mechanics of spy mining?

**Mark Erhardt**: Right, so spy mining is basically, you register as a miner on
other mining pools with your competitors.  And when your competitors give out
new work packages referencing a previous block header, you also switch over your
own node to mine on top of the same block header.  The big problem with that is
you only see the hash of the previous block.  So, you don't actually see the
block header.  If you saw the block header, the block header would actually show
that the proof of work had been done, because block ID is the hash of the block
header, and that has to be lower than the difficulty target, right?  So, when
you see the block header, you actually see that a ton of work had been done, and
that would make you way more confident that the block header is probably valid,
because otherwise people wouldn't have spent that amount of work.  But when you
just receive the work package, you only see the hash.  And the hash could be
made up, because only with the block header, you get the confidence that the
work was actually done.  Otherwise, you could just create a random string.

So, spy mining is this practice of reading the work packages of competing
miners; and when they give out new work packages, to guess that they probably
found a new block and the prior block hash is valid and you can mine on top of
that an empty block as well.  And people used to do that at least, I don't know
if they still do, but this is presumably where part of the empty blocks used to
come from.  And the other one being, you have received a block header and before
finishing to validate the block, you give out new work packages with an empty
block on top of the block header.  So, yeah, spy mining is basically trying to
shave off a few seconds or milliseconds by reading out the work package from
competing miners.  And it's kind of dangerous because if miners were adversarial
and wanted to make you waste mining power, hashrate, they might just issue a
work package to some of their miners that is fake, and then get the whole
competition all to switch over to their new block header, and then actually
secretly would continue mining on their old block because no new block was
found.  So, spy mining has its risks.

**Mike Schmidt**: Yeah, that makes sense.  And even in the case that you would
see the PoW, you mentioned the, what was it, BIP66 reorg, where in my
understanding, the PoW was there, but it was invalid due to some of the
violations of the protocol rules that had recently changed, because they were
running outdated software.  So, even if you had that, there could still be a
violation.

**Mark Erhardt**: In that specific case, actually, the block header itself was
invalid, because BIP66 required to increment the block version and the invalid
block had a lower block version than permitted.  So, in that case, if the block
header had been seen, the miners should have rejected the block.  So, we know
for sure that they must have been spy mining and only saw the hash rather than
the header.

**Mike Schmidt**: Releases and release candidates.  Gustavo came down ill this
morning, so Murch and I are going to do the Releases and the Notable code, based
on his write-ups for this past week.

_Bitcoin Core 28.4rc1_

First release, Bitcoin Core 28.4rc1, which is a maintenance RC and it contains
wallet migration fixes as well as the removal of an unreliable DNS seed, that
maybe you've heard about discussions.

_Rust Bitcoin 0.33.0-beta_

Second release, Rust Bitcoin 0.33.0-beta.  This is a beta release for Rust
Bitcoin.  We noted that it was a fairly large update in terms of number of
commits.  We also noted a few different things that might be interesting for
listeners.  There's a new crate for bitcoin-consensus-encoding.  They obviously
bumped the version across some of their sub-crates.  We've talked about some of
the PRs here, including the MAX_MONEY, ensuring that transactions with duplicate
inputs or outputs, sums don't exceed MAX_MONEY.  I think we covered that
recently.  And then, there's P2P network message encoding traits have been added
as well.  You can look back at some of the recent Rust Bitcoin PRs that we've
covered or you can dig into the release notes here.

_Bitcoin Core #34568_

Notable code and documentation changes.  We have a slew of Bitcoin Core PRs this
week that Murch is going to walk us through starting with Bitcoin Core 34.5.68.

**Mark Erhardt**: Yes.  So, as some of you might have noticed, we had
feature-freeze last Friday and we are getting ready to release Bitcoin Core v31
early April.  So, people are getting their projects in and now, well, we're
getting in their projects and now we're down to just bug fixes and wrapping up
the rest of the things that go into the 31 version.  Then, we will have the
branch off in, I think, a week or two and you'll get v31 next month, hopefully,
as things go.  So, Bitcoin Core #34568 makes several breaking changes to the
Mining IPC interface.  So, if you work on Stratum v2 or have been using the
experimental Stratum v2 support so far, this one might be interesting to you.
It deprecates the methods getCoinbaseRawTx(), getCoinbaseCommitment(), and
getWitnessCommitmentIndex().  We've talked about these six newsletters ago in
Newsletter #388.  And there are some new context parameters.  The underlying
reason is that this will enable the event loop to not block on these calls and
hopefully makes it even better for Stratum v2.  So, if you don't do anything
with Stratum v2 or the Mining interface, you don't have to look at this one.
But if you do, you should probably look at it.

_Bitcoin Core #34184_

The next one up is Bitcoin Core #34184.  This is also about the Mining IPC
interface.  There's an optional cooldown to the createNewBlock() method.  And
the idea here is if you're not completely caught up to the chain tip, you would
be producing outdated block templates while you're catching up.  So, the create
new block method now will wait, if you enable the option, until you're caught up
to the chain tip, because otherwise it would just produce block templates that
are building on top of old blocks, and nobody needs that.  So, this will prevent
Stratum v2 clients from getting all these templates that are outdated already at
creation.  And there is also an interrupt method that you can call if you get a
new block while a block template is being created, that you immediately switch
over to the new chain tip.  Again, if you're interested in Mining IPC or in
Stratum v2, there are a bunch of interesting ones in v31 coming out.  All of
this is, I believe, still going into v31.

_Bitcoin Core #24539_

We continue with the Bitcoin Core #24539.  This looks frigging ancient.  24000
is like probably seven years old or something.  This adds a new -txospenderindex
option.  And I think we talked about this last week already, right?  Or maybe I
read the newsletter.

**Mike Schmidt**: I think it might be the latter.

**Mark Erhardt**: Okay.  So, anyway, there's a new index in Bitcoin Core that
keeps track of which transactions spent outputs.  And that information was
previously not easily available.  You had to basically search the blockchain to
find the transaction that spent an output.  And with this index, you can get the
lookup in that direction, right?  So, from a transaction, you can always look up
what transaction created an output, because that's in the input.  We have the
outpoint of the UTXO we're spending in a transaction, that defines what UTXO
we're spending, contains the txid, so we know what transaction created it.  But
the other way is hard.  When a transaction output was created, you have no clue
which transaction later spent it.  So, this index, when you turn it on, you keep
track of that information and it is not required to have the -txindex on at the
same time, and it doesn't work with pruning.  So, if you're interested in doing
blockchain explorers and things like that, this will be super-exciting for you,
I think.  Yeah, sorry, I just learned this morning that I'm responsible for
these, so bear with me, please.

_Bitcoin Core #34329_

Bitcoin Core #34329 adds two new RPCs, and these are in context of the new
private transaction broadcast.  We talked about this one-shot broadcast method
through Tor when you turn on private broadcast.  These two new RPCs allow you to
get information on what is currently in the queue for private broadcast, and to
abort attempts of private broadcast.  So, these RPCs are called
getprivatebroadcastinfo and abortprivatebroadcast, and they allow you to get
information and manipulate or abort the attempts of privately broadcasting
transactions that are currently in the queue and being sent out via Tor to
single nodes, handshake, send a transaction, ping pong, and drop the connection.

_Bitcoin Core #32138_

ll right, we already talked about ASMap quite a little bit, so I'm skipping that
one again.  And we're getting to Bitcoin Core #32138.  This one removes an RPC
and a startup option.  And confusingly, they are called settxfee and -paytxfee.
But of course, under the hood, they refer to feerates.  So, with settxfee, you
were setting a standard feerate that you would use for every single transaction
when you send a transaction.  And we live in times where feerates are actually
dynamic.  So, making your node always use the same feerate is kind of a weird
thing, and it felt like a footgun to have a static feerate for all of your
transactions.  So, this is being removed.  The proper way or intended way how to
do this is when you send a transaction, you parse the current feerate that you
want to use.  And if you always want to use the same feerate, you can use the
same feerate in your function call.  But configuring a node to always use the
same feerate, come tide and high water, is just not really reasonable today
anymore.

The -paytxfee startup option is the same thing for the configuration.  So, you
were able to configure your node to do this, instead of calling it via the
settxfee RPC.  So, both of these were removed at the same time.  And they were
deprecated already in v30.  We talked about this in Newsletter #349.  But the
general idea is either use automatic fee estimation or set a feerate right when
you call it.

_Bitcoin Core #34512_

All right, one more.  Lots of Bitcoin Core stuff.  Bitcoin Core #34512 adds a
coinbase_tx field to the getblock RPC response.  So, here, when you get a block,
there are different verbosity levels that you can request.  And previously, if
you wanted to get information on what exactly the coinbase transaction looked
like, you had to go to verbosity 2, which meant that you would get every single
transaction in the entire block deserialized and presented in your RPC output.
Now, you might actually only want to look at the coinbase transaction.  For
example, we're currently excited that some people are starting to be compliant
with the BIP54 consensus cleanup requirements, which is to set the locktime in
the coinbase transaction to block height minus one.  And I believe in the
context of this project, someone added that with verbosity level 1 and above,
you get the whole coinbase, but not all of the other transactions.  So, if you
are looking at coinbase properties, coinbase transaction properties, not the
company -- they stole the name from us, okay -- anyway, if you are looking at
coinbase transactions, this RPC will be useful to get coinbase transaction
information without everything else.  Back to you, Mike.

_Core Lightning #8490_

**Mike Schmidt**: All right, moving on with Core Lightning #8490, which adds a
payment-fronting-node configuration option.  And this lets Core Lightning (CLN)
operators specify a node ID or multiple node IDs to use as an entry point for
incoming Lightning payments.  So, this applies to BOLT11 invoices as well as
BOLT12 offers.  Currently, the node that you provide that node ID must be one
that your CLN node has a channel with.  That may change in the future, but
that's how it's set up now.  And for BOLT11 invoices, CLN will use a route hint,
which provides a little bit of privacy.  And for BOLT12 invoices and also
offers, CLN will provide a blinded path, which provides a bit better privacy.

_Eclair #3250_

Eclair #3250 updates the OpenChannelInterceptor so that it can automatically
select a default channel_type, channel type being something like anchor channels
or simple taproot channels.  Previously, such channel creations would fail
without an explicit type.  In fact, you had to just provide the type or there
would be an error.  But now Eclair will attempt to select the channel type,
using both the local node as well as the remote node features supported.  So, it
takes both of those into account.  Right now, I believe anchor outputs are the
default and the only option, but in the future, with taproot channels and zero
feed commitments, Eclair will have this preferred list of channel types that
they think are best and that can be overridden by the node operator.

_LDK #4373_

LDK #4373 enables multiple wallets or nodes to collaboratively pay a single
invoice by each contributing a part of the payment.  So, LDK behind the scenes
is using multipath payments to achieve this, and it adds this
total_mpp_amount_msat field, which allows providing this MPP (multipart payment)
amount that could be the total, which is larger than the local node is actually
sending.  And then, the local node would contribute only a part of the payment
to, let's say, a BOLT12 invoice.  And then, the other payers can coordinate and
the receiver would then collect all these HTLCs (Hash Time Locked Contracts)
from all the contributing nodes and claim the payment once the full amount
arrives.  I thought that the motivation for this PR was interesting and worth
quoting.  So, this is from the PR description, "In some uses of LDK, we need the
ability to send HTLCs for only a portion of some larger MPP payment.  This
allows payers to make single payments which spend funds from multiple wallets,
which may be important for ecash wallets holding funds in multiple mints, or
graduated wallets which hold funds across a trusted wallet and a self-custodial
wallet".

**Mark Erhardt**: I think the interesting thing here is, if you didn't catch it,
previously we had MPPs that would originate from one node but go via multiple
routes.  So, one node would send multiple packages via different routes and once
they reached the recipient, the recipient would collect multiple of them
together to get the full payment amount.  This one has multiple nodes sending
partial payments, and so that's new.  And yeah, as Mike said, maybe multiple
mints.  Maybe those phantom nodes that we've been talking about, where you
actually have multiple receiver nodes in front of a phantom node, and if you
don't have enough funds, well, that would be shocking, but you could put stuff
together like this.

_BDK #2081_

**Mike Schmidt**: Last PR, BDK #2081, adds a created_txouts() and spent_txouts()
method to two different indexes in BDK, SpkTxOutIndex and KeychainTxOutIndex,
which are, I guess, an SPK, scriptPubKey, index, and I'm not sure what the
keychain index is.  But these indexes have those methods to let wallets see
which tracked outputs a transaction spent and which ones it created.

**Mark Erhardt**: I'm not sure if SPK stands for scriptPubKey here.

**Mike Schmidt**: Maybe, we'll see.

**Mark Erhardt**: Maybe it's secret public keychain or something.  Anyway, I
don't know.

**Mike Schmidt**: We need an AI to tell us.  I did try to poke around BDK to
see.

**Mark Erhardt**: Oh, sorry, I was thinking Lightning still, so I think I'm
completely lost in the woods here.  Probably a scriptPubKey, yeah.  It's BDK,
not LDK.

**Mike Schmidt**: All right, I'll take that as a win.

**Mark Erhardt**: Just talking before my point arrived.  Never mind.

**Mike Schmidt**: We want to thank Craig and Fabian for joining us to talk about
what they've been working on earlier.  We wish Gustavo well with his illness.
Hopefully, he's back next week.  And thank you, Murch, for co-hosting and doing
the Bitcoin Core PRs, and thank you all for listening.  Cheers.

**Mark Erhardt**: Hear you soon.

{% include references.md %} {% include linkers/issues.md v=2 issues="" %}
