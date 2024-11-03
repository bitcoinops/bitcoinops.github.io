---
title: 'Bitcoin Optech Newsletter #292 Recap Podcast'
permalink: /en/podcast/2024/03/07/
reference: /en/newsletters/2024/03/06/
name: 2024-03-07-recap
slug: 2024-03-07-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Dave Harding are joined by Josie Baker, Salvatore Ingala, and Fabian Jahr to discuss [Newsletter #292]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2024-2-11/b0d89497-9115-81a4-72f7-5682bf62d614.mp3" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Good morning.  This is Optech Newsletter #292 Recap and as you
can hear, Mike is not here today, and I'm filling in as the main host.  Today we
have four news items, two releases and release candidates, and four PRs to talk
about in our notable code and documentation changes.  I'm Murch, and I work at
Chaincode Labs and bring you weekly this Optech Newsletter Recap.  Today I'm
joined by Dave.

**Dave Harding**: Hi, I'm Dave Harding.  I'm co-author of the Optech Newsletter
and co-author of the third edition of Mastering Bitcoin.

**Mark Erhardt**: Josie.

**Josie Baker**: Hi, I'm Josie, I work on Bitcoin stuff.

**Mark Erhardt**: Salvatore.

**Salvatore Ingala**: Hi, I'm Salvatore and I work on the Ledger Bitcoin app and
right now, I'm working on MuSig.

**Mark Erhardt**: Fabian?

**Fabian Jahr**: Hi, I'm Fabian, I work on Bitcoin Core and some related
projects, and I'm supported by Brink.

_GitLab backup for Bitcoin Core GitHub project_

**Mark Erhardt**: Super.  So, Fabian asked that we could move forward the GitLab
backup topic because he has a limited time window.  So, I propose that for the
people that are following along with the newsletter, we actually start with the
fourth newsletter item.  And so, yeah, let me try to put it together in one
sentence, and then Fabian can maybe give a better overview.  So for a very long
time, we have been thinking about that we do not like very much how we're tied
to GitHub.  And since occasionally stuff just disappears on the internet, we
would be in a lot of trouble if our 30,000 or so issues and PRs and all the
comments written there were not available anymore.  So, for a long time, we've
already been doing backups.  We have just mirrors where people write out all the
comments and issues and PRs that are created.  Obviously, the code itself is
backed up to all the contributors that have copies of the repositories and their
own local branches.  But it looks like Fabian has spent quite some time to
investigate on how syncing with GitLab would work for the Bitcoin GitHub account
and, yeah.

So, my understanding is that you've figured out how to make this work for good,
but not live, just you can get everything synced over?

**Fabian Jahr**: Yeah, exactly.  So, I mean to just give a little additional
recap from my side, so 18 months ago, many people probably remember this, we had
the Tornado Cash incident where, aside from the other legal action that
happened, the repository just disappeared from GitHub completely.  That kind of
triggered me to look into this topic again more deeply and basically put it as
one of my high-priority projects in the last year.  And so the idea is clear.
Like as you said, we have a lot of mechanisms to back up the code, we have a lot
of mechanisms to back up the comments and reviews.  For these, there's a lot of
scripts that people can run and just save the raw data as JSON locally, and then
developer, 0xB10C, has something that also displays the data, then again nicely
in a similar format to GitHub, so you can then read the backup again in the
fashion that you're used to.

But what we're really missing so far is something where we can have the data
transferred and then continue working on it in a similar workflow that we are
used to with GitHub, in case the GitHub repository goes away.  And then, it's a
related question if we were to do this only and keep this kind of only for the
worst-case scenario, or if we want to do the switch at some point soon in the
future.

What I did is I basically reset up a self-hosted GitLab, so this is not about
GitLab.com, the comparable to GitHub.com, but you can self-host GitLab.  The
nice thing is the code is almost all open source.  They say the core code is
open source.  There are some modules that you can pay for then that you get in
addition, but all that I'm using is open source.  And so you can host that, and
if you know GitLab, it looks very similar to GitHub.  And then you have syncing
mechanisms, and they also have some additional tools that you can use.  And so,
they have one functionality that they call mirroring, which is kind of allowing
you to do this live following off another repository.  That was originally my
goal to use this, which was called being a live feature.  Unfortunately, that
doesn't work for our use case right now.  I made a writeup where I described it
a bit more, but they simply haven't built it out for this direction from
github.com to a self-hosted GitLab.  So, that means we would need to build this
ourselves and run it.

What I've done now is you can basically run a one-time syncing process
continuously with a script.  And so, that means you have an up-to-date backup
that is, on average, maybe a day old or so, because the sync takes over a day to
run completely.  And then you have all the data there and you could continue the
work on the self-hosted GitLab instance.  Yeah, and then there's quite a lot of
configuration.  That was the reason why it took so much time for me to figure
this actually out and to actually make the sync be successful for the first
time.  But yeah, that is all documented now, what you have to configure.  There
are some things that you have to turn off, some things that you have to switch
on, so that the syncing process just doesn't fail at some point after 28 hours,
or something like that.  Yeah, and so with that in theory, at least, it's
possible for us to run this.  In practice, it's possible for us to run this, and
then if GitHub.com repository would go away, we could continue working on a
self-hosted GitLab instance.

**Mark Erhardt**: Right.  Okay, so previously we only had archives and we would
be able to search for previous conversations and ideas being exchanged, but
there wasn't a way to go directly to a workable copy of the repository, where we
could jump in and continue our conversations immediately.  And that's what
you've been working on.  My understanding is that it takes 36 hours to sync the
whole repository.  So for all the active conversations, you might actually, if
they're earlier in the process, already be a day late.  But that's definitely a
lot better than nothing.  Is there any way to just get the diff and add to
things you've synced before?

**Fabian Jahr**: Unfortunately, that's not possible.  I mean, with all of this,
GitLab is open source and of course we could all build all of this, but also
GitLab is very complicated.  And so I really try to use it kind of as a user and
see if it has features for us that we can use, configurations that we can set as
a user, and then it's going to do the job for us, because engineering resources
are very scarce for Bitcoin Core.  So, I was really trying to get something that
is maintained by somebody else.  But still, I mean of course worst case, we can
look inside because it's open source.  But yeah, that is kind of the idea.  So,
with all of that, all the limitations that I'm giving that they are not, you can
do this if you want to build it.  It's possible to still do this, but then you
will also have to maintain it yourself, and that, of course, takes a lot of
time.  So, yeah, for what we have from GitLab as a user, that is a limitation.

**Mark Erhardt**: Right, but that's of course a huge improvement already over
the previous situation.  Dave, Josie, Salvatore, does one of you have comments
or questions?

**Dave Harding**: First of all, thank you very much, Fabian, for working on
this.  This is obviously very important that we have a backup that we're able to
move quickly to an alternative if we have to.  And I tried out your preview
site, and I thought it looked really good.  It was really nice, I was impressed
that it attributed everything to everybody.  It just felt like a slightly
different GitHub look.  You just go there and it looks slightly different than
what you're used to, but otherwise it's the same.  If we actually moved to that
site, I noticed all the issues and PRs were correctly attributed to an account
with the same name as the GitHub account.  So, fanquake stuff was attributed to
fanquake, and so on.  How much work would it be for people to claim those
accounts?  Because I mean, obviously you didn't copy over their GitHub
credentials.  Would you have to be sitting there and emailing everybody and
saying, "Here's your one-time password.  Log in and change it", and all that
kind of stuff?

**Fabian Jahr**: Yeah, so that's something where this actually is kind of cool
from GitLab, but also we're running into limitations, and this is really part of
why it was hard for me to figure this out.  And so, you see some comments and
PRs and issues or so being attributed to an actual account, and then you see
others that are actually attributed to the root administrator, and then you will
see a comment inside of the text of the comment, and that in the top says, for
example, user fjahr.  And the distinction between the two is because some people
have their email as public set on their GitHub account, and then a lot of other
people have it set as private.  And so, what GitLab does for the people that
have set it as public is it creates an account on the instance and then
attributes all of the comments and PRs and issues to that account.  And then if
somebody like, for example, fanquake has their email public, then you can go in
and you can basically log in.  You basically do a password reset, and then you
have the account and you have everything basically just like it was on GitHub.

But most people, myself included, have the email private.  It's for the people
that contribute actively.  It's in the commits anyway.  Then you can probably
think about setting it just public in your GitHub profile as well.  But then
this feature goes away, and then you have this inline comment in there where
it's still clear historically that you made that comment, but for example, you
will not be able to go back and just edit that comment later on.  It's not a
huge deal, but yeah, for maximum convenience, if you care about this, set your
email to public and then you will be able to just switch over and it's really
going to feel not much different to before.

**Mark Erhardt**: Super.  So, I think we've covered mostly this news item.  If
anyone else has a comment, now would be a good time.  Fabian, do you have any
calls for action or where are you going from here with this?

**Fabian Jahr**: So, I mean I made a Delving Bitcoin post that you're probably
going to link to, and from there I'm also linking to a gist that is also on
GitHub ironically, but I can also send it to you if it goes away.  So there, you
can read the instructions basically to set it up.  If somebody wants to set it
up and you get stuck anywhere, of course, contact me, I'm very happy to help you
explore this.  I'm also very happy to get feedback from somebody who looks in
this host repository, in this example repository, the instance that I have set
up, and if you see anything in there in the data that looks weird to you, that
is different than you would expect it, then also of course notify me so that I
can track down any bugs or so that are potentially in the syncing mechanism.
So, these are really things that I'm suggesting if you're interested in this.

**Mark Erhardt**: Super.  So, play around and let Fabian know if you find
anything curious.  We've got a question from the audience.  Mike, go ahead.

**Michael Tidwell**: Hey, apologies, my voice is messed up right now.  But
Fabian, are there any concerns with hosting upgrade security of GitLab?  And
then the second one is, the plain Jane, free GitLab version is pretty feature
incomplete with roles and different RBAC controls and stuff.  Is any of that of
concern?  Because I feel like you're going to end up losing a lot of
functionality that GitHub gives you, potentially.  I would be curious to hear
your thoughts on that.

**Fabian Jahr**: So, for the second question, we currently from Brink have an
enterprise testing license basically that I'm currently using.  The idea there
was, so we asked GitLab to give us that and they give it out for free in some
cases to open-source projects.  So, that's probably why I'm not really running
into these limitations if they are relevant to us.  But of course it's not for
everyone, not everyone can get this license, so maybe I'm not seeing these
limitations.  But from what I was seeing in the documentation, in terms of the
syncing features, I think what I'm actually doing now, because the mirroring is
not possible, as I said, that was originally the idea, but it wasn't possible
after all, but the syncing should be possible with the community edition as
well, the same way that I'm doing.

But with actually running it as administrators, like the maintainers do on
GitHub right now, I haven't played around that much with it.  I'm also not a
maintainer myself so I don't have a full overview of all the tools that they are
using on GitHub.  That would be probably also a good step to put on to-do lists
to explore this a bit more with one of the maintainers who can give feedback, if
they were going to switch over and they wanted to fulfill the role the same as
before, if that would require additional adjustments to their workflow.  Yeah.
Sorry, the first one I didn't fully understand.

**Michael Tidwell**: The first one, so running a GitLab server.  So, first off,
just to follow up, having the enterprise license is a big deal for free because
GitLab can get quite expensive.  We're talking $100 per developer using the
server.  If you get all that for free, that's pretty powerful.  The first
question was, and again, sorry for my voice.  The first question was, GitLab is
a constant battle, in my opinion, of making sure it's secured and upgraded,
especially when you have a lot of users using it.  Is there any concern with
who's going to actually maintain that GitLab server if and when it would be used
as a source of truth for the sync of Bitcoin's source code?

**Fabian Jahr**: Unfortunately, I haven't put that much thought into this as
well.  It was really, for now, developed as the worst-case scenario backup,
right?  Like, if GitHub just goes away, this is better than what we had before.
And yeah, this would still need to be figured out.  Right now, there's two
people that have access to the server.  Both are working at Brink or supported
by Brink.  So, yeah, that would be a conversation to be had.  That just hasn't
been a big concern for me, but definitely something also to put on the to-do
list.

**Mark Erhardt**: Okay, awesome.  Thank you for your questions.  I think we're
going to wrap up this topic then.  Fabian, thank you for joining us.  If you
need to drop, we understand.  If you want to hang out a little more, please
stick around.

_Updating BIP21 `bitcoin:` URIs_

We're moving on to the next topic, and the next news item is, Josie Baker
suggested on Delving Bitcoin a revamp of the BIP21 URIs, Universal Resource
Identifiers.  So, you've probably already seen at some point bitcoin: and then
Bitcoin address.  It's used, for example, in QR codes.  And as I understand it,
the original BIP21 suggests that the first item after bitcoin: always has to be
a P2PKH address.  Now, especially I have been vocal on this topic, but P2PKH is
not the most block space efficient method of receiving funds any more, and a lot
of people have been using the scheme basically non-spec compliant and have been
putting other Bitcoin addresses there, or have been labeling the addresses that
they give with various schemes.

So, my understanding is that Josie has taken some time to investigate how the
spec is specified versus how it's actually used in the wild, and is suggesting
how we could improve it to cater to what we're seeing the actual use to be like
and how that would be future-proof and compatible with going forward.  Josie, do
you want to take it from here?

**Josie Baker**: Yeah, sure.  Thanks for having me on to discuss it.  I think
I'll just give a little bit of background as how I got interested in this topic,
and then I want to mention briefly something about why I think it's important
when we talk about spec compliant versus non-spec compliant, and then maybe talk
through the meat of the proposal.  But this came up for Ruben Somsen and I,
because as we've been writing the silent payments bit, we thought a lot about
how do we not contribute to new address format fatigue which is, in Bitcoin, I'm
a wallet developer, I build a wallet, and then next week, somebody comes out
with a new thing, a new address, a new protocol, and then I've got to go and
I've got to update that.  But then it's not really going to work until other
wallets understand it.  So, we have this problem where as we innovate and come
up with cool new stuff, there's then this rollout and adoption phase, which is
very frustrating.

I think taproot is probably the best example of this.  There are people who
really want to use taproot and there are wallets that want to support taproot,
but it's hard from a developer standpoint to do the work of supporting something
like taproot, if you know that every single user of Gemini, Coinbase, Binance,
is not going to be able to withdraw from those exchanges to their wallet because
those exchanges don't recognize the address format.  So, this is this, I think,
known pain point that people feel a lot.  So, I think naturally when you see
someone coming along and being like, "Hey, I've got a new address format",
people kind of grit their teeth like, "Oh, no, not again!"  So, Ruben and I had
been thinking about that, and when we were designing silent payments, we're
like, "Cool, let's just try to make this as close to a taproot address as we
can".  So, we reused the bech32m encoding, came up with an HRP and identifier.

Then it was kind of brought up, "Well, if you want to use this in BIP21, you've
got to define a key for it".  And that seemed kind of weird to me that every BIP
that wants to be compatible with BIP21 has to define a key in their own BIP, so
I started to look into it a little bit.  And that led me to actually read the
text of BIP21 -- and I see there's a hand up there.  I can pause if you have a
question.

**Mark Erhardt**: Yeah, it's kind of funny because the Human Readable Parts, the
HRPs on all of the addresses actually tell you what it is already.  So, needing
to have that parameter label that tells you what the following data part is, is
kind of funny, because that's already done by the HRP itself.  Sorry, that
was...

**Josie Baker**: Yeah, I think that's a great point, and I think this is where
context is helpful.  So, I went back and I reread BIP21, and the first thing
that jumped out to me is the spec says, "The root there needs to be a P2PKH, a
legacy address".  And it says, "Bitcoin address is Base58 encoded".  And you
read that and you're like, "That's kind of weird.  Nobody does that".  And I've
seen BIP21 URIs and QR codes that even Bitcoin Core does bitcoin: the address.
So, that was already like, "Okay, well, that's kind of annoying".  And then
reading through, I think the original intent of BIP21 is, any new address format
that we came up with was going to get its own extension key using the language
of BIP21.  So, you'd have your legacy addresses, which was the only thing at the
time, then we came out with P2SH, and I think if everyone had been following the
BIP21 philosophy, they would have defined a key, you know, P2SH=…, and then that
way it's usable in BIP21.  Same with segwit, we would have defined a new key,
and so on and so forth.

What that would give us in theory is a fully backwards-compatible URI, meaning I
as a receiver can post this URI in a QR code.  One QR code, someone can scan it
and their wallet will pick the key that it understands and there's no failure on
either side.  I always get paid, the person sending always gets to pay, which is
great in theory, right?  It's an amazing user experience and that it avoids this
problem of sometimes you go to someone's page where they're posting Bitcoin
stuff, and there's like six different ways you can pay them.  And for us that
are in the ecosystem, we're like, "Okay, that's fine".  But for newcomers or
people who just kind of want a payment experience, this is a really bad
experience.  So, I think the philosophy of BIP21 is really good.

But that didn't happen in practice, right?  People just started finding new
address types and they didn't define extension keys in BIP21, and then we don't
have an extension key for P2SH, we don't have an extension key for bech32 or
bech32m.  And instead, people just started using the addresses directly.  And
this is where maybe I want to comment on what I mean by "not spec compliant".
People used it in how they took the spirit of it to be, which is totally fine,
right?  We look at something else written and we're like, "Okay, yeah, that was
written in, I think, 2012 or 2011, when legacy was the only address, so it's
reasonable that the spec says that it needs to be Base58 encoded, whatever".  We
all can figure out what the intent was.  The problem is, the more time goes on,
and the more new people come into the space, we can't really rely on this tribal
knowledge, right?  Like, if I were a developer that didn't really know anything
about Bitcoin, and I got hired by a company to build a Bitcoin wallet, and then
they said, "Hey, go, implement BIP21", I would go read that, and I would be
like, "Oh, okay, every BIP21 URI needs to have a Base58 legacy encoded address".
I would code it up that way, and then it just wouldn't work with how 90% of
people are using it.

That's a problem the more Bitcoin grows and the space becomes broader, which is
kind of what initially got me thinking, I think we just need to go back to BIP21
and rethink this a little bit, because there's a lot of, well, what I'll call
non-spec compliant or tribal usage of BIP21.  And if you're not really in the
club, you might not know about that.  So, then it really doesn't function as a
standard anymore.  People just kind of do it however they feel like it should be
done, which has worked, I think, relatively well up to this point.

**Mark Erhardt**: All right, so you've established well how the actual use and
the original writing have diverged.  And you say that actually the intent was
good, but what should we do?  We should …?

**Josie Baker**: Yeah.  And so you already kind of hinted at it.  Since BIP21,
we've learned a lot, I think, and we've come up with a lot of really good
solutions to problems that existed back then, one of them being bech32
encodings, which as you mentioned, a bech32 encoding includes an HRP, which is a
human-readable key that allows the encoded data to self-identify itself.  The
HRP says, "I am …".  In the case of segwit, it's the BC is the HRP, and then we
also have HRPs defined for test networks, etc.  And then, bech32 encoding has
the separator, which is the "1" character.  And the "1" character says, "Okay,
everything after this is the data".  And then in the case of segwit addresses,
or bech32, you have a version which indicates the segwit version, so on and so
forth.  So, you have this really clean way of encoding a piece of data, and the
data immediately tells whoever's using it, "Hey, I'm this, and here's how you
should interpret the data part based on what the HRP is".  So, it's functionally
the same as a key value pair.

So, looking at how BIP21 is used and how we might further extend it, it just
seemed natural to me.  It's like, well, if something already is using this
self-identifying scheme of having the HRP, why don't we just allow people to
include those directly in the URI, which is what I proposed in the Delving post,
or what I arrived at through some conversation.  And this is just one idea of
how to do it, but this is the one that feels the most natural to me.  So then,
you don't really have a root and then key value pairs, you just have
self-describing things with a separator.  The nice thing about this is, and this
is I guess the thing that's most attractive to me about this as a solution is,
now anybody who uses the bech32, bech32m encoding scheme, which really when I
say bech32, I really just mean bech32m, since that's like the latest and
greatest, so bech32m, let's say one of these new proposals like Ark.  It was
like, "Oh, okay, we need a new address type to signify if you pay to this,
you're going to join the Ark network", or whatever.  If they encode it as
bech32m and they choose an HRP and encode their data, they are automatically
able to be included in BIP21 URIs without developers needing to change anything,
right?  Well, more specifically, not needing to change anything about their
BIP21 parsing.  If they can parse an Ark address, it just works.

So, we get this future extensibility that's really nice.  Same with silent
payments, right?  We're encoding silent payments as a bech32m with the sp HRP.
So, if developers were to update their BIP21 implementations to just look for
HRP-encoded thing, bech32m-encoded things with HRPs, then silent payments just
works for free with a BIP21 URI.  So, this future extensibility thing is a thing
that really clicks for me of like, okay, stuff encoded with an HRP fits really
nicely with this, and then we don't run into this problem of every new address
format or every new payment protocol that comes out then needs to also go and
define a BIP21 key, or else it's not going to work.  And looking at history,
this is kind of how we got into the problem in the first place.  Segwit
addresses came out and they did not define a BIP21 key, P2SH addresses, and so
on and so forth.  And I think that that just indicates that process doesn't
scale really well, that every new BIP needs to be aware of BIP21 and define
something for it in order for it to work in this future-extensible way.

So, yeah, that's kind of the crux of the proposal, that learn from how we're
using things to kind of update the spec for BIP21 so that the spec actually is a
little bit more reflective of how it's being used, and then also allow for this
more future-extensible method of using BIP21 that doesn't require all these BIPs
out there, both existing and new, to go back and retroactively define key value
pairs.  And in the case of bech32m-encoded stuff or bech32, defining a key value
for a bech32 address seems silly because, like you mentioned earlier, Murch, the
HRP is already functioning as a key.  So, I'll stop there.  Questions?

**Mark Erhardt**: So basically, bring it forward a decade, touch it up to match
the current reality, allow for any addresses to be put there instead of tying it
to a specific type, like the legacy address.  Maybe while we're at it, we could
also say, if there's multiple things, the order in which they appear is the
order in which we prefer to be bid, for example.  And finally, I think there's
also an issue around whether Bitcoin has to be lowercase or uppercase, because
in the QR codes we can encode stuff more efficiently if it's all uppercase, but
the spec, for example, demands that it's all lowercase, I believe.  So, sort of
just a chance to update everything.  So, what do you think?  Are you going to
try to update BIP21; are you writing a new BIP that supersedes BIP21?  Does
anyone else have questions or comments on this one?

**Josie Baker**: Yeah, regarding the updating or superseding, I think it's the
big question, right, like what makes the most sense?  I think that the idea of
following a strict reading of the BIP process is we should write a new BIP that
supersedes it.  Whatever makes the most sense, right?  If it makes sense to just
write a new BIP, I think that makes sense.  I think Matt actually -- so, there
was some discussion on the Delving post, mostly just between Matt and myself.
Ruben Somsen chimed in as well.  I think Matt, TheBlueMatt, went ahead and
opened a PR to update BIP21 with his version of how he thinks it should be
updated.  So, just to, I think, summarize his version, he says we instead say
anything that falls into this white-listed set of addresses which is taproot,
segwit, P2SH, and legacy, those can go in the root and then everything else has
to go in key value parameters.  Then once the things in key value parameters
have received, like once we're sure that they're near universally supported,
then you can omit the root entirely.  So, you'd have bitcoin: key value pair,
key value pair.  So, he proposed that as a PR to update the BIP.

I disagree with that approach.  I don't think it solves the future-extensibility
problem.  I still think it creates some ambiguity of what goes in the root, and
whatnot.  So, I responded on that PR with the things that I'm proposing.  I
don't know, just kind of see where it goes.  At some point, if it just deadlocks
on no agreement on how to update BIP21, I might just open a new BIP just to see
like, "Hey, here's a new BIP that's kind of superseding BIP21 and learning from
the past", and then it's up to people; you can keep implementing BIP21 or you
can go with a new BIP.  But I think just having more clarity for wallets would
help a lot, especially with interoperability and everything.

**Mark Erhardt**: Yeah, thinking about how I would like to use BIP21 in a future
where we have silent payments would be, I would probably not even want to have a
potential address reuse, permanent address there, I would just want to post a
silent payments address.  And if I'm not allowed to do that by the new BIP,
yeah, I would suggest that we should allow any subset of the addresses.  And if
they read it and they can't use it, well maybe I don't want to receive a payment
that doesn't follow the payment instructions.  Dave?

**Josie Baker**: Yeah, I think, well, just I want to comment on that really
quickly because I think that's super-important, and that's actually where some
of why I didn't initially want to specify anything in BIP352 about BIP21 is
because if you're using silent payments, it indicates to me you're a
privacy-conscious user, right?  And if you were to add a silent payments address
in a URI with a static, reused address, there are real privacy implications.
Like, if someone pays your reused address and someone else makes a silent
payment and you spend those coins together, you're effectively linking an
address that was intended to be silent to this reused address.  So, I was like,
I don't really want to put this in BIP352 because then I'm going to have to
write this massive explainer about why you really shouldn't do this.

On the other hand, I think Matt has a good point that some people might not care
and they might just want the UX benefits of silent payments.  And in that sense,
they should be able to use it in BIP21.  And so, that kind of got me thinking of
like, all right, well, I don't want to define it in this BIP because I think
there's privacy problems, but I also don't want to stonewall anyone from using
it.  So, why don't we just update BIP21 in a way where things can just kind of
automatically be included without us requiring to go and have every single BIP
promote something about it?  So, I agree with your sentiment, and I think that's
going to be the better middle ground.  Let the users of BIP21 use what they want
to use and let the other BIPs stay focused on the thing that they're supposed to
be focused on, which in the case of silent payments, I think, is a much stronger
focus on privacy.  Go ahead, Dave, you had a question?

**Dave Harding**: Yeah, I have a few comments.  First of all, thank you for
working on this.  And also, I find it very interesting how your silent payments
work has basically brought you to every level of the protocol stack.  You're
just basically rewriting all of Bitcoin in little pieces everywhere just to make
sure everything just works really well with this silent payment.  It's just very
interesting to me how what's basically a very simple idea has just got you going
everywhere.  So, a couple of comments there is, first of all, I didn't actually
realize that BIP21 was only P2PKH addresses, I had not even thought of that.
So, you're right, we need to document that, as you call it, the tribal
knowledge.

My suggestions for what to do with regard to updating the BIPs is, I think
BIP21, and this is not what the BIP process says you should do, it just says you
should write a new BIP; but I think BIP21 should probably be updated to document
what everybody is doing right now, and then maybe a new BIP should come and
document how we want to go forward.  That's how I would kind of divide that
work.  I wouldn't think about forward compatibility in updates to a BIP21 now,
but we should definitely document how people are using it now, so we get that,
as you said, that knowledge out of tribal knowledge and into an actual
specification that people will read.  And then we can have a separate BIP that
describes how we want to go and use this in the future for silent payments, for
LN, for whatever.

The other thing I had there was, one concern I might have about throwing new
keys, or whatever you want to call it, address formats into a Bitcoin URI, is
what's an optional key there and what's a required key.  If you just throw, say,
a bech32 Ark address into there, how does the software parsing that know whether
or not that's important and it should drop the payment request if it doesn't
understand it, or that it's optional and maybe there's also a fallback address,
a silent payments address, an onchain address in there, and it should just
ignore that?  For example, in the LN Protocol, they have type numbers that they
assign to all their protocol messages.  And they have this idea that even
messages, if you receive an even message and you don't understand it, you have
to drop that request.  You have to say, "I don't understand what you're talking
about.  I'm just going to …", actually I think they closed the channel for some
of the stuff because it's clearly they're incompatible and they don't want to
get into a case where they're losing money.

With Bitcoin URIs, again we're talking about changing money and software that
parses them needs to know what's optional and what's required.  So, I just
wanted to know if you had any thoughts on that, is that something you've
considered?

**Josie Baker**: Yeah, yeah, great questions.  To your first comment about
silent payments kind of touching everything, that was certainly not my intent.
It's kind of, you start with this like really small idea and you're like, "Oh,
this would be a pretty simple project".  Next thing you know, it's everywhere.
But it is a lot of fun and it's been a good learning experience.  I think the
reason for that is the silent payments and just this whole idea is kind of core
to how Bitcoin works, right?  Like, you and I have to agree on how to
communicate how I want to receive money and how you're able to send money, and
this is kind of the core idea of Bitcoin, which is why I think when you get into
something like silent payments, it does start to touch a lot of different stuff.

To your second question, I want to say, let's talk about a simplified world
where everything is bech32m encoded, meaning it has an HRP and a data part, and
the HRP is what describes what it is, and we're allowed to redesign BIP21
however we want.  So, BIP21 had this notion already of optional versus required
parameters, and optional parameters are just what's in there by default, right?
You throw some stuff in there.  And then whoever's parsing it, the sender
actually decides what's important to them.  So, Murch earlier had mentioned some
order dependence.  BIP21 says, "No", there's a root address, which is a legacy
address, which everyone can pay, and then there's these optional key value
parameters that come after it.  And the sender actually gets to decide which one
they want to use, not the receiver.

So, in the case of, like, unified QR codes in BIP21, there's a Lightning key
that you attach on and the sender says, "If I understand Lightning, I'm going to
use Lightning".  And then everyone was like, "Oh, shouldn't they always use
Lightning?"  I was like, "Well, no, what if the Lightning payment is so large
that the onchain would actually be cheaper for the sender?"  So, then the sender
might prefer to use the onchain one.  So, the idea of BIP21, and kind of what
I'm proposing too as well, is the sender is actually the one that decides what's
important.  So, in that sense, everything is optional.

Now the receiver also has some ability to communicate how they want to be paid,
and more specifically how they don't want to be paid, in that if the receiver
doesn't post a URI with lots of options for you -- so let's use silent payments
as an example.  I'm a very privacy conscious silent payments user.  I want to
post a URI that just has a silent payments address in it and if you can't
understand silent payments, then I don't want an onchain fallback, because that
would lead to address reuse for you and me, or loss of privacy.  So, in that
sense, I'm going to post a URI and I accept that whoever tries to pay this, if
they can't pay silent payments, it's going to fail.  And the reason it would
fail for the sender is, they would try to parse that URI and they wouldn't see
anything that they recognize just by looking at the HRPs.

Another example would be, I post a silent payment address and I also include a
taproot address because I'm like, all right, maybe they don't understand silent
payments and I'd rather get paid even if it's in a non-private way, so then I
include a taproot address.  Then the sender would parse that URI, and they would
look for an HRP that they recognize.  They don't recognize the sp HRP, they do
recognize the bc HRP, they split that bc1p, they know how to pay a taproot
address, they're good to go.  This is, I think, functionally equivalent to how
it works today in BIP21, where instead of looking for an HRP, people just look
for a key.  And as soon as they find a key that they're interested in and aware
of, they just ignore everything else and they try to pay that key.  So, I think
that's kind of how they solve the ambiguity problem.  I guess the biggest
difference between where I'm leaning and the existing BIP21 is, BIP21 is pretty
opinionated.  There should always be something there that they can pay, which is
the legacy address.

**Dave Harding**: I guess I don't want to go into much detail here, I can always
post on the thread, but I guess I'm just thinking about the other query
parameters that passed.  For example, you know, if you pass an amount parameter,
might there be a case where that amount parameter would apply to legacy
addresses and bech32 addresses and silent payments, but it might not apply to
Lightning.  You know, you might be parsing a BOLT12 URI where you want the
person to get the amount from the offer rather than the amount parameter, but
you want to include the amount parameter in the thing.  That's not a great
example because --

**Josie Baker**: I think that's a perfect example.  I had the same question
reading BIP21 as written, where we do have these optional parameters like
amount, message, et cetera.  And then I think the most common pattern that you
see people using BIP21 today is called the unified QR code, where you have
Bitcoin address, then you have a Lightning "=" parameter and that Lightning "="
then specifies a BOLT11 invoice.  But the BOLT11 invoice, if I understand
correctly, also encodes an amount into the BOLT11 invoice.  So, then it's like,
well, do I prefer the BOLT11 invoice; do I prefer the amount?  And that's
currently not specified.  I think you could work around this, where BIP21
specifies two separators, the "?" separator and the "&" separator.  I think that
the intent there is, the "?" separator is the big one.  And so, I can have
A?B?C.  Then if I want to attach additional optional parameters to C, it would
be ?C&amount&message, and then the parser knows that, okay, these ones belong to
this one.  But I don't know if that's true because I feel like it's a little
underspecified currently.

**Dave Harding**: I think that's actually an RFC, or something.  It's required
that the first parameter be with a "?" and all remaining parameters be "&".  So,
it doesn't actually convey any semantics in a URI.  I think it's RFC3986.  But
yeah, so I don't think we can do it that way.  I think we'd have to use
uppercase or, I don't know if that's the right thing, but "_" or something.

**Mark Erhardt**: All right.  I feel like we're getting a little too much into
the detail of the proposal.  Let's try to wrap it up.  Josie, do you want to
make a call of action or a summary, like a sentence or two, and then we'll move
on to the next topic?

**Josie Baker**: Yeah, I mean the biggest one would be like, if this is
something you're interested in, please chime in on the Delving Bitcoin post.
I'm coming at this from the thing that interested me, but I'm sure there are
other people who also feel like there's unaddressed points that could be
addressed.  So, if we're going to do this, I'd rather get a lot more input.  And
I would say that that's the thing that would motivate me to actually keep
working on this and maybe even write a new BIP, as if there's a lot of feedback
from people, it'd be like, "Hey, by the way, we have a chance to fix a bunch of
other stuff".  So, if you're interested, feel free to comment.

**Mark Erhardt**: All right.

**Josie Baker**: Thanks everybody for the great questions.

_PSBTs for multiple concurrent MuSig2 signing sessions_

**Mark Erhardt**: Yeah, thanks for coming on.  Again, if you have time, please
stick around.  If you have to drop off to do something else, we understand.
We're moving on to the next topic.  The next topic is PSBTs for multiple
concurrent MuSig 2 signing sessions.  So, Salvatore is working with hardware
wallets and looking to make PSBT, and especially in the context of MuSig2, work
well.  And from what I understand, one of the issues he's been bumping into is
that the state of the MuSig2 signing session scales with the number of inputs on
transactions.  And of course, when you're working with a hardware device that
has a very limited amount of memory, that can become a blocker or a problem.
So, Salvatore is suggesting that we could, instead of having the amount of data
that you have to keep track of in the session, scale with the inputs, have some
sort of unified session data that you can derive the input-related data
deterministically, but pseudo randomly from.  Did I roughly understand that
right, and do you want to take it from here?

**Salvatore Ingala**: Yeah, that was a great explanation.  And yeah, as you
said, I'm thinking about and I started prototyping how to implement MuSig2
support in the Ledger Bitcoin app.  And meanwhile, there is also independent
work that achow101 is doing for standardizing descriptors and everything else
that is needed to make all these things work together.  So, it's looking great
for MuSig2 to actually start being used more widely in practice, hopefully this
year.  And, yeah, one of the issues that I discovered when I was thinking about
how to implement it on a hardware device is that, well, when you're implementing
a protocol in MuSig2, because it's a two-rounds protocol, it's not like simple
signatures like we do today.  With a schnorr or ECDSA, to do one signature, you
just ask the device to produce a signature, the device responds, that's it;
while in MuSig2, you have a two-round protocol.

So, all the cosigners first are invoked the first time to produce what is called
a nonce, which is a short for a number that should be used only once.  And after
everybody produced this number, the nonce, all these nonces are aggregated, and
then you call the signer the second time with all the nonces and now the
protocol does its magic and can continue and produce the final signature.  And
BIP327 is the specs of MuSig2 for Bitcoin, and it goes at great length into
explaining what are the pitfalls, what can go wrong, like all the ways that this
can cause security issues.  Because since you have two rounds, it means you have
to keep some state between the first round and the second round.  And this state
is a small number, it could be just 32 bytes, let's say.  But when you sign a
Bitcoin transaction, you could have an unbounded number of inputs, you could
have 200 inputs.

So, while in BIP327, a signing session is defined in the sense of a single
message, in the context of signing devices, normally you're signing a
transaction, so your session intuitively is more on the level of the PSBT of the
transaction, right?  And on embedded devices, having all this, in fact if you
read to the letter BIP327 and you implement it like without any change
whatsoever, the natural way of doing it would be to actually have all the
sessions in parallel, and for each of these sessions, for each of these inputs
basically, have to store some stuff on the device.  And so, the idea that I was
describing, which is pretty straightforward, since the state that you need for
each of these inputs is basically derived from a random number, a standard idea
in this case is to just use one random number and then derive all the other
numbers in the same session, pseudo-randomly, using a cryptographically secure
pseudo-random number generator.

The reason I thought it was good to have this audited properly is that, well,
when you're implementing cryptographic protocols, there are many ways that
things can go wrong.  And so, I thought it's very useful to have this first
audited and judged by other people who are more experts.  I already had this
discussed with Yannick Seurin, who's one of the authors of the MuSig2 paper, but
it was on previous drafts that were not written in the same level of detail.
And I thought, anyway, if it took me some time to figure out, it could be
helpful also for other people to express, to write down what I thought could be
a good solution.  And, yeah, the solution is exactly as you said, that you
basically use one random number for the PSBT level session, and then for each of
the individual MuSig2 signing sessions, you can derive the initial randomness in
a pseudo-random way so that you can continue the protocol by keeping only a
small amount of states, which is just potentially 32 bytes, for the whole
transaction rather than for each input.  And yeah, the approach received some
comments also from Jonas Nick, and Tim Ruffing, that are the other authors of
the MuSig2 Paper.  So, I'm happy that I didn't break MuSig.  And so, I look
forward to try to implement it.

**Mark Erhardt**: Yeah, thank you for going down that rabbit hole and seeking
the, well, feedback of all this community already in advance.  So, this seems to
be very specifically to hardware wallets.  Would that mean that anyone else has
to change how they use MuSig2, or is this just at the hardware wallet level, you
act differently than other people in how you contribute your nonces?

**Salvatore Ingala**: No, this is just at the level of a single signer.  Even
non-hardware wallets could do it, but for them maybe it's less relevant because
if you have a transaction with 100 inputs and you want to store some 32 bytes
for each 100 inputs, it's like 3 kB of data.  So, outside of embedded devices,
maybe it's much less pressing.  Could still be useful outside, because maybe you
want to be able to sign 100 transactions in parallel and each of them has 100
inputs.  And so, not having to think in advance about hard limits could help,
but it's definitely more relevant in the context of harder wallets, because
having to persist state in memory, it's a much bigger limitation, because even
if the secure element has some small amount of persistent memory, it's not a
lot.  So, reducing the amount of state to a small amount per transaction, it's
definitely going to make implementations in practice a lot easier.

**Mark Erhardt**: Yeah, that sounds right.  Dave, do you have other comments or
questions on this one?

**Dave Harding**: I guess my only question is, I mean again, thank you for
working on this.  It's not something I had thought of, but you're right, it's
really important.  And I do like hardware wallets.  Is there any risk that this
data would be easier to leak if someone gained physical access to a hardware
wallet?  It sounds like you may be able to store this data on the secure
element, but it also sounds like, from the post, you are moving it into the
volatile memory during actual signing operations.  So, if I start a session, and
let's say I keep my hardware wallet in a safe deposit box, and some bank
employee, while I'm in the middle of a session, but not actually physically with
the device, obviously, they grab my device.  Does this increase the risk that
somebody could extract compromising information from my hardware wallet if they
had physical access to it, even though the device had a secure enclave on it?

**Salvatore Ingala**: No, I would say no, it doesn't change anything in that
sense.  So, the level of security of this memory is the same as any other
memory, which is in the secure element.  So, extracting anything from there,
unless there are bugs in the code that allow you to extract this information
programmatically, let's say, is as hard as extracting any other secret from the
secure element.  But the distinction that I made between the volatile memory and
the persistent memory, that was more as a matter of guaranteeing that you are
never reusing unknowns, because one of the pitfalls you can have when you
implement these things is that because you're storing something at the end of
the first round, if you can be tricked into running the algorithm twice without
repeating the first round, so you complete the second round with two different
transactions, for example, two different executions, but with the same nonce,
that can lead to nonce reuse, which basically can leak the private key.

So, that was just a way of making auditability as easy as possible, because I am
only storing permanently this session in the persistent memory at the end of
round one.  And the first thing that I'm doing when I begin the second round is
I delete it from the memory.  So, this makes it a lot easier to make sure that,
well, it can never happen that you are able to run the second round twice
without generating your randomness.

**Mark Erhardt**: Oh, yeah, that's a really important idea.  If your session
randomness is tied to the PSBT and isn't specific to an output, you can of
course track on the PSBT level whether the session has ended or has to be
restarted.  So, that sounds cleaner actually at the implementation level.

**Salvatore Ingala**: Yeah, it's something that, I mean, it's not really a
change to BIP327, because this is something that I do on top to make the
implementation mostly more auditable, but I thought it was a good thing to write
down because I think it's a useful detail in implementations.

**Mark Erhardt**: Great, thank you for coming on and talking to us about your
work.  Do you have a call to action or a summary, something that you want to add
still?

**Salvatore Ingala**: No, I think we covered it.  I mean, I'm still probably a
few months away from having this in the wild, at least on testnet.  But yes,
looks like progress is happening also outside.

**Mark Erhardt**: Okay, super.  Well, thank you for joining us.  If you have
time and want to stick around, please feel free.  Otherwise, if you have other
things to get to, we understand.

**Salvatore Ingala**: Thank you, yeah, I'll stay.

_Discussion about adding more BIP editors_

**Mark Erhardt**: Yeah, we'll move on to the next news item.  So, this is the
fourth and final news item because we pulled forward the GitLab backup issue
with Fabian.  We're now talking about the Discussion to add more BIP editors.
So, we have a repository in the Bitcoin organization, which is there for
historical reasons, it's not really related to Bitcoin Core.  And in that, we
track proposals to the Bitcoin protocol or just public writeups on methods and
ideas that are useful to many different implementers or groups in the Bitcoin
ecosystem.  And we call those the Bitcoin Improvement Proposals.  Currently, we
have 135 open PRs in this repository, and the process has been frustrating for a
few developers to the end that recently, we had AJ Towns start the BINANA
repository as a parallel mechanism, where you can post an idea publicly so that
a distributed discussion of an idea can reference a single document, and
everybody knows exactly what we're talking about.

So, another approach here is now, Ava Chow posted to the Bitcoin-Dev mailing
list the suggestion that we add more editors, because the main editor that is
currently shepherding the repository has stated that he's not getting around to
doing all the work that is necessary and is to time constraints.  So, we're at a
point where there's a few people proposed, and the discussion hasn't really
progressed much since then.  So, yeah, if you are interested in that topic, you
can find it on the mailing list.  Dave, do you have more information or ideas on
where this is going?

**Dave Harding**: No, but it would be nice if we could make more progress on
BIPs, or people can just switch to BINANAs, or however you like to host your
documentation.

**Mark Erhardt**: Yeah, maybe to jump in a little more, one of the points of
frustration is, the understanding is that a BIP is owned by the authors of the
BIP because they're proposing their idea, and it becomes a public document for
everyone to talk about, but it's still sort of their writeup.  So, one thing
that is supposed to be allowed is that the authors, as they develop their idea,
especially while it's still in draft status, but potentially even after it has
been published, can add to the BIP or make minor changes, like typo corrections
or if an example was not 100% clear, add a clarifying sentence; things like that
should always be possible for the BIP owners.  And the other thing that has been
holding up processes, the BIP process states that not only should BIPs be
obviously from the sphere of Bitcoin interesting topics, but they have to be
technically sound.  And so, it takes a lot of work for the technical editors of
the BIP repository to assess, "Well, is this actually technically sound?  Is
this a well-enough described idea that it can be implemented or not?"

One of the participants in the discussion has proposed, really the documents
should have some formal requirements like, is it complete?  Does it not have any
references to outside things?  Is it well written?  Does it specify an idea that
is about Bitcoin?  And then whether or not it is technically sound should
perhaps be more the job of the readers of the BIPs rather than the BIP editor.
So, yeah, the discussion seems to be a little bit in the air right now.  The two
proposed participants are Ruben Somsen and Kanzure, that have both been around
for a long time and would probably be well capable of assessing at least whether
the documents are fully fleshed out and whether they're about Bitcoin.  There's
been also a couple self-nominations.  So, anyway, that's where I understand the
discussion to be.

_Eclair v0.10.0_

All right, we're moving on to the Releases and release candidates section.  The
first release that we have is Eclair v0.10.0, which is a new major release for
the LN Node implementation, the Eclair LN Node implementation.  So, Eclair
v0.10.0 adds the dual funding feature, it adds BOLT12 offers, and it has a fully
working splicing prototype.  So, this sounds like a pretty cool, big, new
release.  We've seen a bunch of these topics out in the wild lately.  We've had
t-bast on to talk about dual-funding before and about splicing.  Yeah, I don't
know if there's many other people that also use the Eclair node besides ACINQ,
but yeah, it sounds like a bunch of cool new features, especially if you're
using Phoenix wallet, you'll see what comes down the pipeline there.  Dave, do
you have something here?

**Dave Harding**: Not really.  I just want to echo that these are really cool
features, and I think it's just great that Eclair and their team there, they've
been really active in working on not just adding these features to their
software, but the specifications.  They've been working on, as they implement
it, going back and taking their discoveries and talking it over and tweaking the
specifications on those things.  So, the dual funding and the offers and the
splicing are all compatible with the Boltz protocols for those.  So, I think
it's just really great seeing a team not just using open-source work and
releasing open-source software, but contributing to the specifications for
those.

**Mark Erhardt**: Yeah, especially if you look at how small the ACINQ team is,
it's really impressive how on top of the spec work they are.

_Bitcoin Core 26.1rc1_

All right, we have one more RC in this section.  We have seen the RC1 for the
Bitcoin Core v26.1.  So, this is the maintenance release in the 26 branch.  So,
if you're currently running Bitcoin Core v26 and you want to not directly
upgrade to the upcoming 27 version, but want to maybe wait a little for the new
version to settle in and just want to be up to date with the latest bug fixes,
26.1 looks to come out in the next few weeks once the RC process is over.  If
you're depending on that, maybe try running it in your testnet setup and give
feedback if, for example, you've encountered some of the bugs that are being
fixed, whether it works for you.  I've looked over the release notes, and to me
it looks like there's only a bunch of small issues and bug fixes that are in
there, nothing really big that we've talked much about.

All right, we get to our Notable code and documentation changes section.  We
have four different PRs that we're going to discuss this time.  If you have any
questions or comments, please, now is a good time to search for the speaker
request button and let us know that you want to contribute to this recap.

_Bitcoin Core #29412_

So, the first one that we'll get into is Bitcoin Core #29412, and this one fixes
an interesting problem, which is dealing with mutated blocks.  So, one of the
problems that we've encountered in the past is when a node just gives you bad
data, but it is bad in specific ways that the peers that receive it think, "Oh,
generally anything announced to me with this identifier, I do not have to look
at again", because it can cause the peers to, for example, not follow the best
chain anymore or not to accept a transaction that is valid on the network,
because they first saw a garbled version of it.  In the context of blocks, for
example, someone could tamper witness data or change the witness commitment such
that it actually no longer matches the block header, but indicates, of course,
that the block is invalid.  And I think there was a bug, from what I understand,
where the node would actually process such an invalid block and then store
partial information, and therefore poison itself against the real block.

So, what this PR does is it really gets into all the ways that you can mutate a
block and change little pieces of it to turn them invalid, but make them still
propagate, and test that Bitcoin Core behaves correctly, in that it does not
process this mutated block, but discards it and stays open to receive an
alternative correct version of it.  Dave, I might not have looked as much at
this as you have.  Do you want to take it from here?

**Dave Harding**: I think you did a great job.  Yeah, this is a really
interesting class of problems that we've hit a couple times in Bitcoin Core in
the past.  Anybody really interested in this should click on the link in the
newsletter to Newsletter #37, which goes into a lot more detail about two of
these cases.  And also, we do cover briefly in Mastering Bitcoin, the 2012 bug
CVE-2012-2459.  And it's just interesting.  Basically the way the attack works,
or the problem, it's not necessarily an attack, but the problem works because
Bitcoin uses a merkle tree and there's some problems in its merkle tree designs,
it's possible to construct multiple different merkle trees that hash the same
merkle root, which is in the block header, and the hash to the block header is
how we identify blocks in Bitcoin.

So, it's possible to create what looks like two different blocks, or two
different blocks that look like they have the same ID.  And so, we just end up
looking at one of them and saying, "That's invalid", and now we don't want to
download that same block from our other potentially 124 peers.  So, we say if
that peer announces a block with the same ID, we're just going to assume it's
invalid, and so we reject it.  And if that happens, it's kind of like an eclipse
attack on your node, and an attacker can exploit that to prevent you from
learning about valid blocks.  Now, we only reject blocks while the node is still
running.  So, if you restart your node, it'll go back and double check and maybe
download those valid blocks again.

But it's a potential attack.  It could potentially be used to steal money,
especially if you're using something like Lightning where you need to be getting
the most recent blocks.  And so, this PR just very early in the process, we look
at a block and we see if it has one of these things that would make the block
invalid, but also could later cause us to cache the header, and we just stop
processing that block at that point.  We don't cache anything, we just throw
away that block and move on.  And I just think that's a really good solution to
this problem that we've hit twice.  We've hit this problem twice.  When you hit
it once, you fix that immediate bug.  Once you hit it twice, you've got to try
to figure out the root cause and stop it.  So, I'm really thankful for this PR
coming in and just making us safer.  It doesn't, as far as I know, it doesn't
fix any active vulnerability in Bitcoin Core right now, but it just means we're
less likely to have vulnerabilities in the future.

**Mark Erhardt**: Yeah, that's my understanding too.  So, also maybe this
question just popped up for me.  Why doesn't that open us up to abuse from
peers, or anything like that?  Well, if someone sends us an invalid block and we
then throw it away, we would accept that same invalid block again from another
peer.  But the original peer that sent us invalid data, we would disconnect
already because you're misbehaving, right?  Sending us invalid blocks is just a
no-no, and we don't want to talk to them anymore.  We drop them on the street
and therefore, even if we get an invalid block and we waste that bandwidth to
download the block header and the transaction ID list, maybe if it's a compact
block relay, we only do that once per peer.  So, this is naturally already
limited in the amount of DoS or abuse that it can lever on us.

Then you also have to remember, a block always has to have proof of work,
because that's the first thing we check.  We look at the header, and if the
header doesn't pass the proof-of-work requirement, we'll never request the rest
of the body of the block.  So, actually this mutated block thing cannot really
be used for DoSing much, only for, well for example, making you drop something
or stop following the best chain.

**Dave Harding**: Oh, just really quickly, all that peer can do is waste your
bandwidth.  When you process the block for this code, which runs really early
on, like you said, the proof of work happens, so it has to be a mutated valid
block.  So, that peer can get you to download a whole block and run some hashes.
Hashes are really quick computationally, a block is something we already have
the memory to process, so the peer is just basically wasting bandwidth and a few
computations.  So, dropping them, I don't think there's a DoS factor there if
you end up reprocessing that block again.  So, it's just a very quick and easy
mitigation.  Sorry.

**Mark Erhardt**: No, thanks for clarifying.  So, Mike, you have a question
here?

**Michael Tidwell**: Yeah, I think he was actually clarifying as I came up on
stage, but I might have missed it.  What was the idea with two merkle roots with
different trees with the same hash, or did I misunderstand that?

**Dave Harding**: Yeah, so Bitcoin's merkle tree design, when you have an odd
number of nodes in a merkle tree, you have to do something in any merkle tree
design.  What Bitcoin does is it hashes the node with a copy of itself.  And
what this allows you, an attacker, to do is to create a block that looks like it
has two copies of the same transaction.  Now, ever since BIP30 and BIP34, we
really haven't had duplicate transactions in Bitcoin, and the idea was we'd
never have them in the first place.  But you can make a block that looks like it
has a duplicate transaction, that transaction has the same txid.  And so, you
can create a version of a block that has only one transaction with a particular
ID, and a version of a block that has two transactions with the same txid.  The
second block is invalid, but it hashes to the same merkle root as the first
block.

There's other ways to cause problems, particularly with 64-byte transactions.  A
merkle node is the result of two 32-byte hashes.  And so, you can do weird
things with 64-byte transactions.  That's also considered in this PR.  But
basically, you can create different block contents that hash to the same merkle
root.  Again, a merkle root is included in the block header, and the hash of the
block header is how we identify blocks on the network.  Does that answer your
question?

**Michael Tidwell**: Well, okay, so I'm still a little bit confused because I'm
thinking, well, if anything in the tree changes, the merkle root should be
different.  So, if I wanted to do some homework and look this up, what phrasing
would I type in to look up what this is?  What is this called?

**Dave Harding**: What I would suggest you do is go to the newsletter on this
news item, the Bitcoin Core #29412 in the Notable code and documentation
changes.  We have a link to Newsletter #37 and in Newsletter #37, we have a link
to CVE-2012-2459.  It's a writeup on Bitcointalk by the guy who invented P2Pool,
he discovered the vulnerability.  Also, that Newsletter #37 includes a very
informative PDF written by Suhas Daftuar, who fixed one of these bugs, actually
introduced one of these bugs and also fixed one of these bugs.  That PDF goes
into a lot of detail about this.  There's an illustration in Newsletter #37.
So, I would basically just go to Newsletter #37 and look at all the information
about this that I think you could possibly ever need.

**Michael Tidwell**: Okay, thank you so much.

_Eclair #2829_

**Mark Erhardt**: All right, we're moving on to the next PR.  Eclair #2829
allows plugins to change the default behavior when encountering a request to
dual-fund a channel.  So by default, Eclair will not put any of its funds into a
channel opening, but with a plugin, for example, you could change that behavior
and then, for example, try to match the opener's amount, or I guess talking to
t-bast about being over leveraged by the other party, them putting way more
funds in than you wanted and therefore being able to tie up funds on your side,
maybe there's some interesting things that you want to do on your side for the
amount.  So anyway, with this new PR, you can override the default policy and
change how much by default your node will contribute to dual-funded channels.

**Dave Harding**: Yeah, so by default, Eclair just doesn't know what you want to
do with your money and it won't tie up your money without asking your
permission, and basically you can give your permission now by creating a plugin.
So, that's all this is.  But it's good for people who want to experiment with
dual-funding opens and who also want to start experimenting with things like
liquidity advertisements.  Eclair doesn't support liquidity advertisements
natively yet, but if you want to experiment with that, now you have the
opportunity to.

_LND #8378_

**Mark Erhardt**: Super, thank you for the color here.  We move on to LND #8378.
LND has made some improvements to its coin selection implementation.  Most
specifically, it allows you now to preset some inputs and then allows you to use
coin selection to fund the rest of the transaction.  And it also changes that
coin selection can now be set as a parameter, so you can choose what selection
strategy your node uses.  I think from a cursory look at the PR, the two choices
right now are "random selection" and "largest first selection".  But now when
you make the call to build a transaction specifically for funding a channel,
then you can (a) decide some of the UTXOs manually, and (B) decide which
strategy is used to pick the rest.  Cool.  I take it that Dave signals me to
move on.

_BIPs #1421 _

So, we're getting to the final PR and topic.  If you have any more questions or
comments for us, please, you can raise your hand now or ask for speaker access.
So, finally, we're talking about a PR to the BIPs repository.  We already
touched on the BIPs repository earlier, of course.  BIP345, OP_VAULT, the PR got
merged now.  And so, obviously, there is no activation parameters in the
description of OP_VAULT, or anything like that, but the specification of what
James O'Beirne proposes to do with the OP_VAULT opcode is now part of the merged
code in the BIP, or documentation in the BIPs repository.  Dave, do you have
more on that?

**Dave Harding**: No.  Apparently, at least one BIP got merged this week.  We
have not had a lot of BIPs merged.  So, go back to our previous news item about
needing more editors, but I'm happy to see this merged.  I think James worked on
it really hard, and it is a very novel and interesting proposal.  So, if you
were waiting to read it, now is your chance.

**Mark Erhardt**: All right.  So, we're through our newsletter this week.  Thank
you for joining us for the Optech Recap.  Thank you to our guests, Salvatore,
Fabian, and Josie, and also for Mike to jump in and ask us some additional
questions.  And a lot of thanks to Dave, who's writing most of these newsletters
all the time and has lots of things to add here in our recap.  Thank you, and
hear you next time.

{% include references.md %}
