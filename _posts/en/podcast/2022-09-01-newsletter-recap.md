---
title: 'Bitcoin Optech Newsletter #215 Recap Podcast'
permalink: /en/podcast/2022/09/01/
reference: /en/newsletters/2022/08/31/
name: 2022-09-01-recap
slug: 2022-09-01-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by Craig Raw to discuss [Newsletter #215]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-8-28/348957421-44100-2-f5c2363577662.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Bitcoin Optech Newsletter #215 Recap.  So, we'll be walking
through this newsletter largely in the order that it was published.  And we have
as co-host today, myself, Mike Schmidt, contributor to Optech and Executive
Director at Brink.  And, Murch, do you want to introduce yourself?

**Mark Erhardt**: Hi, I'm Murch, I work at Chaincode Labs.  I've been around for
a few years and I contribute to various education initiatives, work on Bitcoin
Core, co-host New York BitDevs, and do all that stuff.

**Mike Schmidt**: And then, Craig, you want to give a quick introduction for the
audience?

**Craig Raw**: Yeah, sure.  I'm Craig, I developed Sparrow Wallet, which is a
desktop Bitcoin wallet.  Yeah, so that's what I do, been doing it for a while
now, and I would guess it's somewhat known in the space at this point.

**Mike Schmidt**: And I know that the first news and only news item here is your
proposed BIP to the mailing list, but I think maybe a little bit of further
context for folks on what you're doing with Sparrow and what is the _raison
d'etre_ for Sparrow and where does it excel where other wallet softwares may
fall flat?  Why are you working on this project; tell us a little bit more about
it?

**Craig Raw**: Sure, so as I said, it's a desktop wallet, so it runs on OSX or
Windows or Linux.  Effectively, I was working with the Electrum client some
years ago, trying to create a multisig wallet.  Now, I quite like the approach
of the Electrum client in the way that it is sort of a light client, and it kind
of connects to the server, which allows you to load any wallet without having to
go and scan the entire blockchain.  That I think is a good approach.
Unfortunately, I was really battling to create a sort of multisig wallet with a
lot of different hardware wallets.  I could do it, but it was a bit of a hacky
job, and I just felt that there needed to be a better way.  So, that's kind of
where it began, was just this idea of trying to create a better interface for
people to be able to do multisig, but it really grew from there.

I think what Sparrow does well is, it allows people to really get into the
details of their wallet and understand their transactions and what they're
doing.  Because for me, it's really around trying to make sure that you are (a)
being secure, you're not going to lose your funds, and (b) being private.  And
trying to get both of those things right requires you in the Bitcoin space to
understand what's going on.  I don't think there's any shortcuts if you really
want to get both of those right.  So, it's really a wallet software that allows
you to not only understand what's going on but also has the tools for you to be
able to, for example, transact in a private way.  So, you can use Whirlpool to
coinjoin, you can create a variety of private or privacy-focused transactions,
and throughout that entire process, you can kind of see what the wallet is doing
when it constructs those, so you get a better understanding of how to manage
things.  That's kind of what Sparrow is trying to do.

**Mark Erhardt**: That's very cool.  I have a question, actually.  So, you said
you were inspired by Electrum's thin client model.  How does Sparrow Wallet get
its data?  Does it use the compact client-side block filters?

**Craig Raw**: No, it doesn't.  It actually uses the exact same model that the
Electrum client does.  So, it basically also connects to an Electrum server,
which is I think becoming an increasingly popular approach.  BlueWallet uses it
for, example, and I think many others.  So, that's the approach that it uses.
Sparrow tries to cater towards the, I don't know if I can put it this way, but
the sort of pro end of the market where you might have many different wallets
that you want to load, many different kinds of wallets, and you don't want to
sit around waiting for every wallet to scan through the blockchain.  And
obviously having a fully indexed blockchain, which is what an Electrum server
is, allows you to do those kind of things much more easily.

**Mark Erhardt**: Thanks, cool.

_Wallet label export format_

**Mike Schmidt**: Well I think that's a good way to frame up the discussion, and
I think it leads right into a need that you have in terms of the wallet label
export format BIP that you've put together.  Maybe, to set the stage for the
audience a bit, maybe just a quick review of existing BIPs that have worked
towards wallet interoperability, like BIP32, 39, 44, and how does your proposal
improve or augment those already interoperable-type BIPs?

**Craig Raw**: Sure, so right now, everyone who's been in the Bitcoin space for
a while, almost the first thing that you encounter are these 12 or 24 seed
words.  And those represent the seed, the master key to your wallet, if you
will.  Now, those seed words are defined by a standard called BIP39, which is
effectively just taking what is a very long number and converting it into these
12 or 24 seed words.  And look, it's a standard that's not without certain
wrinkles, depending on your point of view.  But the great thing about it is that
it has been almost universally adopted by all kinds of Bitcoin layer 1 wallets.
And that really makes it great, for example, if you want to use a different
wallet, you can easily just transfer your seed words.  And because there's this
kind of universal support for it, your funds will appear in the other wallet.
So, that's really quite helpful and allows people to avoid the sort of vendor
lock-in that we might otherwise have.

Now, what happens to your seed afterwards, there's a number of other standards
that you mentioned there.  There's BIP32, which defines a sort of hierarchy or
derivation path that allows you to, depending on what kind of address you have,
apply a certain path, and then every wallet uses the same path.  And these paths
are defined by other standards like BIP44 and BIP84, depending on the kind of
address that you're trying to create.  So, these kinds of standards mean that
it's relatively easy for you to be able to move from one wallet to the other in
terms of your funds.

Where there's a gap, and this gets to the BIP that I have proposed, is that you
can't transfer the labels that you've applied in your wallet from one wallet to
the other, right?  Those are very much siloed within the wallet application that
you have.  And why is this an issue?  Wallet labels are most useful when they
indicate the source of funds.  So, say for example, you have KYC coins from one
source and non-KYC coins from the other.  Now generally, you'll want to not
construct a transaction which has both of those sources as inputs into one
transaction, because then effectively you've linked them onchain and now
effectively your no-KYC funds are effectively now KYC, for the most part.  So,
how do you avoid that?  Well, you can either use two different wallets or you
can label those UTXOs.  And that makes labels quite a valuable thing.  Right
now, you just can't.  There's no standard that we have, or at least no BIP that
we have that allows those labels to be exported from one application to the
next.  That's really what this BIP is about.  It's a very simple BIP actually.
It's just about trying to create a standard which allows people to export from
one to the other.

**Mike Schmidt**: So, you mentioned the use case, one of the use cases for
something like this being privacy-related and being able to label certain
transactions in a certain way, based on where they've come from, and inputs and
outputs I think is also in the BIP.  Are there other folks doing similar things
in this space in terms of labeling that is not privacy-related, for example,
maybe accounting or other use cases?

**Craig Raw**: Yeah, sure.  So many people obviously have a need to take the
financial information in their wallet and export it, so they can use it within
whatever accounting application that they have.  And that kind of leads me on to
the format that I've tried to use here.  So, if you'd look at the sort of
general purpose formats that we have, often people are either trying to do their
accounting in Excel or they're trying to do it in some kind of accounting
application.  And usually the common format that we can say both of those types
of applications will support is CSV.  So, that's another very important use case
here, is just to be able to take the transactions out of your wallet and say,
"Right, I want to see what the labels were.  I want to know what that
transaction was for, and I want to know what the next one was for".  So, you can
get an idea without having to go in afterwards and perhaps relabel everything,
based on the amounts, or what have you.  So, that's a good point to be able to
do that kind of accounting work as well.

**Mike Schmidt**: You touched on one of my other questions which came up in the
mailing list thread, and there was quite a bit of commentary on CSV versus JSON
or other formats.  I know the proposal had CSV as the underlying format, but
there were some folks recommending JSON, and I know you have some opinions on
that.  Maybe you could opine on why you think CSV is best, and then also maybe
try to steel man the JSON side of things as well?

**Craig Raw**: Great.  So, I'll start off with the JSON argument, right?  The
good thing about JSON is that JSON, if there's anything wrong with the
formatting of that document, the sort of syntax if you will, the entire thing
just fails, right?  That's both good and bad.  It's good in the sense from a
programmer's point of view, in that you're never going to have to worry about,
are there any formatting issues here?  The JSON parser just handles everything,
and if there's anything wrong, it just says, "I'm sorry, I can't do anything
with this".  So, as a programmer, that kind of takes the burden off you and just
says, "Well, it's not my issue".  Unfortunately, there is quite obviously a
downside to that as well, in that if we want to enable other applications to be
involved here versus just very specific applications that can write out a
certain JSON format, then we are going to effectively limit the range and the
ability of people to be able to work with the information in this export.  And
that was for me quite a big loss.

So, I understand, and when you post such a proposal to a list like the
Bitcoin-Dev list, obviously there a lot of programmers that immediately see that
there is a standard which caters better towards the programming side of things.
But I really wanted to represent the user with this BIP as well.  That's kind of
been what I've tried to do with work in Sparrow as well, just always try and
think of what the user would want.  And for me, I think it's very clear, and I
can see it from talking to users as well, that the idea of having labels in a
CSV format is a very useful thing.  You can export it to Excel, you can export
it to your accounting program, you can create your own labels and then upload
them into the wallet application.  So, you can do that sort of bulk editing
yourself outside of the wallet, which might allow you to do certain things that
you wouldn't otherwise be able to do in, for example, a spreadsheet.  So, that's
kind of the argument for CSV, is that just gives a much, much broader set of
people access and interactivity with the labels in their wallet.  And I think
that that's the kind of democratization that I was aiming for here.

Now, the natural question is, is it possible to use CSV in a way that doesn't
create a whole lot of headaches?  And this is kind of where I actually changed a
bit from its original proposal, based on the feedback that I got.  So, there is
a specification for CSV, it's known as RFC 4180, and it does specify pretty
completely how a CSV can be formatted in a way that there is no chance of
getting one that is incorrectly formatted, so long as that RFC is followed.  And
that, for me, is good enough.  Whether it's good enough for everyone remains to
be seen, right?  We're in a process now where feedback needs to come in, and
ultimately wallet devs need to opine on whether they think that that's enough.
But I still believe that the importance of allowing users access to this format
is a goal that's worth aiming for.  And I'm going to keep trying to aim for it
unless it gets to a point where nobody is prepared to build this thing.  So,
that's kind of where I'm at with that.

**Mike Schmidt**: So, if one of the pros of JSON is its structured format, this
adhering to this standard CSV format may also achieve some of that consistency,
I guess; is that right?

**Craig Raw**: I think so, yes.  I mean, we're looking at a very simple format
here.  I'm sure everyone here has used the spreadsheet before.  It's literally a
two-column spreadsheet.  So, there's not a lot of room for variation anyway.
So, we go beyond what the RFC mandates, and we mandate that the RFC must be
followed.  And then we, in addition, only have two columns.  So I mean, I know
that there are people who've had issues with CSVs, but they're certainly
limited.  In fact, I don't see any scope, if those things are followed, for CSVs
to be unparsable in some way, so that's what makes me at least optimistic that
we can still retain that wide accessibility feature.

**Mike Schmidt**: One thing that came up in the mailing list discussion was
SLIP15, at least I believe it was SLIP15, a somewhat overlapping standard that's
been developed and used in other wallet software for a while.  Do you want to
maybe compare and contrast what you're proposing with that particular solution?

**Craig Raw**: Sure.  So, that solution was designed by the Trezor team at
SatoshiLabs, and it's got a different intent.  So, the way that it works is it's
more of, if you can call it, sort of an iCloud backup, if you can see it that
way.  So, what it does is it asks the hardware wallet, or at least whatever
wallet you have, but certainly the wallet with the seed, it says, "Please can I
have a private key and I'm going to encrypt the labels with this key".  Now,
that's not so useful when you get to coordinate a software.  So, that's what
Sparrow is doing, for example, in the case of being a multisig wallet, right,
you've got a bunch of hardware wallets, or indeed just one, and what you want to
do there is keep the private keys on the hardware wallet.  There's literally no
way to get them off.

So, with SLIP15, we have a situation where the coordinator software cannot
export the labels in that format because it doesn't have access to the private
key.  And that kind of, for me, is a reason that it's not going to work as a
general export format.  I think it's quite specific to what Trezor was trying to
attempt when they built that.

**Mike Schmidt**: So, Sparrow has this coordinating across multiple hardware
signing devices potentially, and the requirement of SLIP to have the private key
in order to do this export and import process sort of makes it -- I guess it
would be very hard to reconcile that and so this is a format and a standard
that's being proposed that would allow no usage of private key required to
import and export these labels?

**Craig Raw**: That's correct, yeah.  So, if we talk a bit about there is, of
course, still a need to respect the privacy of what we're trying to deal with
here.  If we look at the information that could be in this export file, we're
looking at addresses, we're looking at transactions, and we're looking at labels
on those.  So, there's a lot of private information here.  And what this BIP
proposal also has in it is the ability to take that CSV file and optionally put
it into a zip file, and then with the zip file you have a sort of encryption
which you can apply.  Now, there are some downsides to using zips in this
format.  Zips are not only a compression utility but also an archive one, so you
can put many files in, which is not actually really what we need here.

But the great advantage to a zip file is that again, talking to the CSV, it's a
tool that almost everyone has access to.  So, the ability to encrypt things
using this almost universally accessible tool, if you think about WinZip or
7-Zip, these are very common programs.  It allows people to at least have a
default of, "I can encrypt this thing or I can decrypt this thing and not have
all of this privacy sensitive information sitting around on my hard drive in
plain text".  So, that was important for me to achieve in this sort of very
accessible way that I'm trying to write this, but do so in a way that allowed
people to maintain some degree of privacy around that kind of information.

**Mike Schmidt**: So yeah, Craig, you've sort of gone along with my line of
questioning here.  Is there anything else that you'd like to talk about
regarding this proposed BIP or how it's been received or what you plan to do
next?

**Craig Raw**: I think in terms of next steps, it's really I kind of need to
hear from other wallet devs, whether they think this standard is something worth
building on, or whether they have any kind of issues with it.  I think what I've
sort of described perhaps in an indirect way is, we have two goals here.  The
first goal and the most important goal is that we have an ability for people to
extract their labels from one wallet and add them to a second wallet.  That's, I
think, the most important goal, and that's the one thing that I'm really trying
to achieve.  The secondary goal is allowing people access to these labels in
applications outside of wallets.

So, I'm going to keep on trying for both in the hope that I can get that across
the line.  But if I have to abandon the second goal, then so be it.  I guess if
wallet devs don't like this for whatever reason, then I'm going to have to go
back and try and figure out a way to improve on it.  But that's kind of where
the process is now.  So, I'm trying to talk to users.  There's a Bitcoin Talk
thread going on right now, there's obviously the Bitcoin-Dev list as well, and
just trying to talk about it here and other podcasts.  Yeah, it's really just a
process at this point.  And I think it's worth saying that I haven't proposed a
BIP before, so it's very much a learning process for me as well.

**Mike Schmidt**: Yeah, I was going to ask that if this is your first one or
not.  Sounds like it is.  So, it seems like you've gotten some good discussion
going and it's just a matter of coalescing users and some of the other potential
software, wallet software in the space to coalesce around a final
recommendation?

**Craig Raw**: Yeah, I think that that's it.  As I said, the most important
thing is that other wallet devs build whatever format we eventually decide on
into their wallets, and then we've sort of achieved a level where people can
export and import.  That's, I think, the most important goal to achieve, yeah.

**Mike Schmidt**: Well, thanks for joining us.  You're welcome to stick around
as we go through the rest of the newsletter, especially since my co-host can't
speak.  We'll jump into the Q&A from the Stack Exchange.  So, this is a segment
of our newsletter that we do monthly, in which we comb the Bitcoin Stack
Exchange for interesting questions and answers, and then try to quickly
summarize those in the newsletter.  But the goal is to sort of somewhat surface
this information for folks to dive deeper into the actual answer on the Stack
Exchange.

_Why isn't it possible to add an OP_RETURN commitment (or some arbitrary script) inside a taproot script path with a descriptor?_

So, the first one here is, "Why isn’t it possible to add an OP_RETURN commitment
(or some arbitrary script) inside a taproot script path using a descriptor?"
And the gist of the answer here is that script descriptors are being extended to
use miniscript, but that is still something that is a work in progress, and
that's something planned for a future release.  And even when that does come
out, it will only support segwit v0, that miniscript extension, and it will be
down the road where actual support for tapscript and this notion of partial
descriptors could actually make it inside Bitcoin Core as well, and then you'd
be able to use certain descriptors to add in arbitrary scripts using a
descriptor, whether that's an OP_RETURN is a valid use case or not, just any
arbitrary script being able to be added there.

Murch, are you here?  Okay, Murch is now here.  We can move on or, Craig, if you
have any comments, feel free to chime in as well if you're familiar with
descriptors and taproot.

**Craig Raw**: Nothing on that in particular to add to what you said.

**Mike Schmidt**: Does Sparrow use descriptors?

**Craig Raw**: It does, yes.  So, with any wallet in Sparrow, you can extract it
and you can also create a wallet using any descriptor.  So, yeah, that was an
important design goal from the start.

_Why does Bitcoin Core rebroadcast transactions?_

**Mike Schmidt**: Cool.  Our second Q&A from the Stack Exchange is, "Why does
Bitcoin Core rebroadcast transactions?" and this user was looking at some of the
code and saw that there was some code around rebroadcasting transactions, and
there was some delay associated with that transaction rebroadcasting.  And so
Pieter Wuille, who's quite prolific in Bitcoin, but also quite prolific on the
Stack Exchange of all places, answered this one and pointed out that, because
there's no guarantees of transaction propagation along the network, you have
this necessity that you'll need to rebroadcast a transaction potentially.

One example of that is, let's say you broadcast your own transaction to a node,
and let's just say you're connected to one node, and that node either drops or
maliciously does not relay that transaction for whatever reason.  You think it's
been relayed, so that is like a sort of canonical, simple example of why your
transaction might not be relayed to the network, and so there's this necessity
to rebroadcast.  And I believe that the logic is after 12 hours, there's a
random interval after that in which the wallet software will rebroadcast that
transaction.  And so that's why transactions are rebroadcast.  And the reason
for the randomness is, I believe, a privacy-related sort of random generated
timeout between the initial broadcast and subsequent broadcast.

One thing that I wanted to make sure to put in this writeup is you'll see that
there's three different PR Review Club meetings that cover the general topic of
transaction rebroadcasting.  And so, I'm particularly a fan of this PR Review
Club, which is an online IRC meeting that happens once a week, and there's one
PR that's reviewed, and everybody gets some notes beforehand and then can go
through those notes and then attend the meeting, text-based meeting on IRC, that
covers that PR, and there's a series of questions and answers.  So, if you're
interested in the technicals, please consider attending one of those PR Review
Club meetings.  And there's a few links to that with regard to transaction
rebroadcast here.

**Mark Erhardt**: I actually had prepped quite a bit for this.  You've covered
already the OP_RETURN descriptive stuff, or was there something to --

**Mike Schmidt**: Yeah.  I know that you had some feedback and discussion around
that, so maybe you want to augment that with some of your discussions with the
folks at Chaincode?

**Mark Erhardt**: Yeah, I think that the asker there had a misunderstanding
between what it means to commit to data, and what it means publish the data with
the nulldata outputs.  And the idea here was that they wanted to put an
OP_RETURN output into a taptree, and that doesn't make a lot of sense to me
because if you put an OP_RETURN into an output script, it makes that output
script unspendable.  So, it can never be printed to the blockchain because you
only print the one that you will spend.  So, if it's in some leaf, why would you
put an OP_RETURN there?  And if you just want to commit to data, you could just
write random data there, or you could just tweak the public key in the first
place, and then you would still commit to what you want to commit to without
needing an OP_RETURN output.

So, anyway, I did a little more research on this and tried to chime in on that
one actually later, after we published it in our newsletter.

**Mike Schmidt**: Yeah, so I think I guess there is this differentiation of the
exact particular use case that the user was asking about in that question with
the answer, which I think the answer is informative and valid, it's just the
original use case is somewhat, I guess, infeasible or shouldn't be done in this
manner, but I think the answer still stands.

**Mark Erhardt**: Yeah.  The answer is fine, I think that just one of the
aspects of the questions, like as a frame challenge, was maybe not quite as
clear as it could have been.  Basically I'm saying if you want to write data to
the blockchain, which some people have a use case for, then you want to create a
nulldata output, and hiding it in a taproot output doesn't make as much sense to
me.

**Mike Schmidt**: Yeah, that's fair.  And then anything to add on rebroadcasting
transactions?  Why Bitcoin Core --

**Mark Erhardt**: Oh yeah.  Well, so we have propagation guarantees only for
blocks in Bitcoin.  And so obviously, in order to stay at the chain tip,
everybody needs to hear about the best chain at some point.  So, we guarantee
that blocks are propagated to every single node on the network.  Transactions do
not have a propagation guarantee.  They're relayed at best efforts.  So, if you
happen to forward to a black hole, like a light client, or somebody that just
doesn't forward transactions because they're only counting the nodes on the
network, and things like that, then you might not actually have successfully
broadcast the transaction to the network when you submit it at first.  So, if
you later realize that your transaction is not getting confirmed as you
expected, you might want to rebroadcast it and submit it again.  But that's a
huge privacy leak, because only the users that really care about transactions
have a copy and retain a copy and rebroadcast it and want to make sure that it
goes through.  So, by rebroadcasting, you basically reveal that you're either
the sender or the receiver of the transaction.

The question was basically why the delay is 12 hours and why we don't
rebroadcast more quickly, why we have to rebroadcast in the first place.  So, in
the long run, we would love to see it go to a very different model, where every
mempool actually rebroadcasts whatever they've seen, not get picked into blocks
where they should have been picked into blocks.  So, if you have any
transactions in your mempool that have a higher feerate than what's in the last
block, you should resubmit them to the network and make people aware, "Hey, I
have two zero transactions to include".  And if all mempools rebroadcast all
transactions, this privacy leak of the sender and receiver being the only ones
that care would go away.

**Mike Schmidt**: Now, what is the status of the shifting of the area of
responsibility of that from the wallet who's interested in the transaction,
whether sender or receiver, to the mempool?  I know that that's been work
underway, but are you aware of how far along that is?

**Mark Erhardt**: I think that the principal engineer working on that topic has
not updated that in a while.  And I think the last work on it was March last
year.  So, maybe at this point there would be room for somebody else to get
active on this effort.  I haven't talked to them though, so I'm not sure.  There
was some groundwork laid and the PR was closed after some time, after there was
feedback, and there were some considerations how to do it slightly differently.
But yeah, typical Bitcoin Core internal, where it's just hard work to keep
rebasing and addressing all the feedback and it can be a marathon.

_When did Bitcoin Core deprecate the mining function?_

**Mike Schmidt**: Well, let's move on to the next question from the Stack
Exchange which is, "When did Bitcoin Core deprecate the mining function?"  And
when I see these questions sometimes, I think that they're probably not
applicable for the newsletter, but then you see Pieter Wuille with his
encyclopaedic knowledge put in a somewhat entertaining and informative answer,
which is, "It hasn't"!  So, there's actually a bunch of different ways in which,
over the years, the Bitcoin Core software has provided mining functionality, and
Pieter goes through those.  I don't know if we need to go through all of those
now, but I think the funny point is that on testnet, or I guess if you're
running something locally as well, there's still this built-in function that's
still there for mining purposes.  And then Pieter also goes through a bunch of
the RPCs and different ways to interact with mining that have been activated and
then removed from the code over the years, with the bulk of the optimization
having been removed for maintenance burden purposes.

So, a lot of that has since been removed to keep the code a little bit simpler.
But there is some of that mining functionality remaining.  Murch, any comments
on here?

**Mark Erhardt**: That's pretty much it, I guess.  I mean, CPU mining became
obsolete in 2010 and it moved on to GPU mining.  So, it just doesn't make sense
to have a built-in functionality that people would waste electricity with in
Bitcoin Core, because basically the only way to energy-efficiently mine at this
point is to hook it up to ASICs in some manner, and we handle that via
getblocktemplate.

**Mike Schmidt**: Yeah, and getblocktemplate it seems is still fairly used by
mining pools and miners in the space, so that's the main bridge, I guess,
between them and the Bitcoin software.

**Mark Erhardt**: I believe so, yes.

_UTXO spendable by me or deposit to exchange after 5 years?_

The fourth question for this segment is, "UTXO spendable by me or deposit to
exchange after five years?"  This was a hypothetical question from an asker on
the Stack Exchange about, "Hey, I want to be able to spend this UTXO, but after
five years, I would like it to be deposited into an exchange", which, ignore the
exchange piece, I guess, you could generalize that more to having a transaction
that is able to be broadcast after five years.  Whether it goes to an exchange
or not is not germane to the technical answer here.

And so stickies-v provided an answer, building up the idea of what are Bitcoin
Script operators, how does taproot work with MAST, and spending conditions from
a privacy and feerate perspective; and then pointed out that due to the lack of
Script's ability to support covenants, the scenario outlined by the original
question is not possible entirely in Script.  And then another user, Vojtěch, I
believe, pointed out that while you can't do it all in Script, this hypothetical
scenario could be done by having pre-signed transactions, so that you could have
a spendable by me, and then have this pre-signed transaction that's valid after
five years be able to be stored for five years and then eventually broadcast.
If this is an inheritance-type thing, and in theory this spendable-by-me person
is deceased, there's this pre-signed transaction that after five years could be
sent to an address of that person's choosing.

**Mark Erhardt**: Yeah, or just losing access to the original wallet, right?
You might have different backups and backup strategies for those two.  For
example, in the case of an exchange, it's more of a social backup that you can,
of course, contact the exchange and via identification maybe regain access to
that account.  So, I think maybe let's get into two things here.  One is, one of
the most simple kinds of covenants is just predetermining what sort of
transaction you will want to do and then locking it to a block height.  And I
think that was described by Brian Bishop already, I want to say 2013 or so, and
essentially this is that.  You make a predetermined transaction, you can print
it out on a QR code, you can publish it in your blogpost or whatever, and make
it a public document.  And that way, you can guarantee that it will still be
around.  Since transactions are immutable and no third party can change the
outcome of the transaction, once it is published somewhere, it will be very easy
to broadcast.

The other thing, of course, is the inheritance part.  If nobody knows where to
find that data and that they need to publish it in order to get access to the
funds, you do not have any benefit from it.  So, what's really missing is sort
of a second part, some service that guarantees that it is also broadcast if the
UTXO is still available at that time.  And I think for inheritance especially,
we will get some neat new features via taproot because, for example, you can
create soon, hopefully, when we get miniscript output descriptors, hopefully in
25.0 in Bitcoin Core, you could have a wallet that you generally use as a
single-sig user with the keypath, but then as a tweak to the inner key, you
would have a taptree that, for example, has script leaves that can be spent by
your heirs.

So, you get the benefit of having single-sig with the low cost of transactions
and direct access with one device, but you have also the option of falling back
to the scriptpaths and you could, for example, put the miniscript descriptor
into your will or something and your heirs would already hold the keys, so even
your notary couldn't steal the funds, because you're not publishing the secret
that is necessary to authenticate yourself, but only the information with how to
access the funds.  And, yeah, so I don't know if I would use this for
inheritance, but it's maybe a nice fallback for a lost wallet.

_What was the bug for the Bitcoin value overflow in 2010?_

**Mike Schmidt**: Our next question here is around the value overflow bug.  And
because the high level summary of the value overflow bug is back in 2010,
someone spent a half bitcoin and the two outputs of this transaction each were
about 92 million bitcoin, which essentially created, at the time, a transaction
that spent half a bitcoin and got two outputs of 92 million, totaling 184 -- oh,
is it billion?

**Mark Erhardt**: Yeah, billion.

**Mike Schmidt**: Sorry, 184 billion bitcoin, and that was due to some of the
error checking.  It looked like the transaction spent a total of -0.1 bitcoin,
but due to the way the checks were done and creating this very large overflow
number, it allowed those bitcoin to essentially be printed.

**Mark Erhardt**: Let me jump in here.  So, this is a curious one.  There was
essentially a bug in how the values were checked.  So, when you build a
transaction, you have to check that all the values are positive, obviously, and
that the inputs are bigger than the outputs.  And there was a check for each
output that it was a positive value, but the check of whether the inputs are
greater than the outputs was implemented as a subtraction of the input sum minus
the output sum.  And whoever noticed this issue in the check exploited that by
creating an output, or rather two outputs, that were so humongously large that
while they themselves were positive numbers, when they were added up, they
overflowed, and in the integer representation of computers, when the first bit
is negative for assigned integers, it becomes a negative number.

So, those two very, very large positive numbers, when added up, become one
negative number.  And subtracting a negative number, obviously, is a plus.  So,
this allowed the creation of 2 times 92 billion bitcoin.  Obviously, that was
not quite what the network intended, and that block was later re-orged out.  But
yeah!

**Mike Schmidt**: So, there was a period of time for a few hours that we had
more than the 21 million possible bitcoins for a few hours before that fix was
in place.

**Mark Erhardt**: Indeed.  And actually, we can never have 21 million bitcoin.
That's just a myth!

**Mike Schmidt**: Well yes, asymptotically or close to 21 million bitcoins.  But
okay, yeah, that's an interesting bug and thank you for walking through some of
the details on exactly where that bug lied.  And there's more information that
we have in not only the Stack Exchange answer, but Optech has a small, little
writeup on it as well that we link to in the newsletter.

**Mark Erhardt**: Yeah, I also saw the million earlier.  I have a PR open to fix
it already!

**Mike Schmidt**: Oh, yes, in the writeup, yeah, I think we have million and
then billion elsewhere.  So, all right, I'll take a look at that PR.  Okay,
that's it for the Stack Exchange section.

_LND 0.15.1-beta_

In terms of Release and release candidates, we have this LND 0.15.1-beta, which
has been in RC and is now I think officially just a beta release.  I think we've
somewhat discussed the items here, so I'm not sure if there's anything that you
want to jump into on that release, Murch, or if we jump onto the code changes?

**Mark Erhardt**: I think we can move on.

_Bitcoin Core #23202_

**Mike Schmidt**: Okay, great.  So, jumping to some of these PRs, Bitcoin Core
#23202, there is an RPC that is psbtbumpfee, and this RPC has been changed or
augmented to be able to create PSBTs that you can transaction bump, even if you
don't own those transactions -- the inputs to the transaction don't belong to
the wallet.  So, PSBT, Partially Signed Bitcoin Transaction, and this RPC with
bump fee allowed you to increase the transaction fee of that PSBT.  But
previously the wallet had to own those inputs to the transaction, whereas now
you can have, in theory, external inputs that are used in this RPC to create the
bumped fee PSBT and that could be then signed elsewhere.

**Mark Erhardt**: Yeah, I think maybe we should give a bit more of a shoutout to
PSBT, because it's probably a little under-spoken how big of a deal it is to
have a good standard for how you can exchange data when multiple parties build
transactions together.  And I think that maybe also Craig can speak to that, but
just having this open standard that everybody has been implementing will do a
lot for us in the near future, where people just much more easily can create
transactions together, either from multiple devices or even multiple users.  And
of course the idea is that stuff like that will help break the common input
heuristic.

**Craig Raw**: Well, if I can jump in there, I mean, I completely agree.  You
know, I think the arrival of when Andrew Chow developed PSBT was very fortuitous
for when I was building Sparrow.  A lot of wallets have had to sort of reverse
engineer that were created from an era earlier.  Sparrow was really designed
around PSBTs and the idea that you can bring them in from any source sign on
whatever wallet you have.  It just gives you such a flexible kind of central
point or central format that you can then base a lot of things off, the way that
you can just sort of add to them over time.  They just contain this wonderful
tree of information that allows wallet developers to be quite flexible in the
way that they build an application around it, to eventually create a PSBT that
has everything that is required to extract a transaction.  So, it's been a
really important development, in my view.

**Mark Erhardt**: Yeah, and maybe another point that Craig reminded me of.  So,
in PSBT, there is multiple different rules defined.  There is, for example, the
updater rule, which is just the party that loads more information about the
UTXOs and adds it to the PSBT tree, the information that is handed around.  And
then that enables, of course, signers to just produce the signature that is
missing for the UTXOs that they control, without having access to the actual
blockchain data.  So, this enables much easier interaction with air-gapped
machines, hardware devices, hardware security modules, that sort of thing.  And
I guess in a way, this PR in the first place is just a clearer use of the
different rules here.

_Eclair #2275_

**Mike Schmidt**: And I guess while we're on the topic of fee bumping, the next
PR here, Eclair #2275, adds support for fee bumping as well in the context of
dual-funded LN setup transaction.  So, Murch, I don't know if you want to give a
quick overview of dual-funded LN transactions to sort of prime the explanation
of his PR, and then we can explain why fee bumping might be needed for a
dual-funded setup?

**Mark Erhardt**: Sure, I can speak a little to that.  When dual funding was
first proposed, the idea was that two users get together, build a transaction
together in order to establish a channel.  And then, well, we didn't have PSBT
then, for example, and it was just hard to coordinate the transaction creation
at that time.  So, the first simpler approach to take was that most channels got
established predominantly with the funds from one side.  And with dual-funded,
or rather with single-funded channels, one of the big challenges is that the
full liquidity of the channel is only on one side.  So, the channel owner that
provided the funds, they can send funds to other LN participants, but they
cannot receive any funds.

With dual-funded channels, one of the big advantages is that both participants
immediately have funds, so payments in both directions can be received and
forwarded.

**Mike Schmidt**: Excellent.  And this PR augments that functionality by
allowing that transaction to be fee bumped in the case that either that
transaction has not been confirmed yet, or there is some urgency on getting that
confirmed and fee bumping is required.  And I think in this PR, there is a
limitation that I believe that there's only one side of that dual funding that
can actually initiate the fee bump.  But I think it's good progress nonetheless.

**Mark Erhardt**: Yeah, I don't know, sorry.

_Eclair #2387_

**Mike Schmidt**: Another Eclair PR here is #2387 and just a fairly
straightforward one.  Eclair added support for signet.  Perhaps, Murch, I don't
know if we've covered signet, other than in passing, in our discussions in our
recaps here.  What is signet?

**Mark Erhardt**: Well, if you want to test an application, you probably want to
have a network that is as similar as possible to mainnet without actually
putting funds at risk.  And to that end, when you have a single machine, you
could use regtest, which is actually just basically a network that you bootstrap
on your own machine when you run the tests for Bitcoin Core.  So, it was never
intended as a local testing environment to do other things and connect machines
with, and it has a few limitations.  For example, it is very hard to connect
other computers to a regtest, and anybody that is connected can produce blocks
and the whole coordination mechanism doesn't really exist.

So, there is a testnet, which is essentially the same as mainnet; it's a global
network that people with hashrate can connect to and produce blocks in.  The
standardness rules are not enforced on testnet, so you can do all sorts of crazy
and weird transactions on testnet.  And it especially has a difficulty reset.
If there has not been a block for 20 minutes, the difficulty goes down to one,
and you can just produce a new block at essentially CPU hashrate with no issue.
That also leads to funny effects like when the last block in a difficulty period
is mined after more than 20 minutes, it also resets the difficulty for the next
difficulty period, and then you get block storms on testnet, where people just
mine hundreds of blocks per second for a while until difficulty goes back up.

So, testnet's become pretty large.  I think it's past the tenth halving already.
And the idea behind signet is basically to make it really easy to have a
playground that you can test in with worthless tokens that you can easily start
a new one off, a new copy just for your feature or your local computer network,
or your customers in the case of businesses trying to provide a testing
environment for their user base.  And it allows you to mine by signing blocks.
Just there's some keys that you put in and those keys are allowed to create new
blocks.  So, basically it's proof of stake, but we just use it for worthless
tokens, pretty much like any other proof-of-stake system.

**Mike Schmidt**: I hadn't heard that term before, "block storm"?

**Mark Erhardt**: I mean, if you see like thousands of blocks per minute, then
yeah, it's just sometimes a little hard to keep up with it with lower-end
machines.

**Mike Schmidt**: Yeah, I think you touched on this, but there's somewhat of a
default signet, and then you can also, as you mentioned, spin up your own signet
in which you are the one, or series of signers, that can then process those
transactions and blocks, and process those blocks as well.

**Mark Erhardt**: Exactly, yeah.  But then it's in a bona fide network from the
get-go, so other than regtest, it's made to be connected to by other parties
too.

_LDK #1652_

**Mike Schmidt**: Right.  Okay, let's move on.  LDK PR #1652.  We've had sort of
a flurry of these over the last month or so, different types of support around
onion messages.  And to review, onion messages are a way to use the LN to send
pieces of information that are not attached to an actual payment.  And in this
particular PR, there's the ability to send a reply path along with the onion
message.  So, right now when you send a message, it goes along a series of hops,
and when the recipient gets that onion message, and let's say for whatever
reason, they would like to respond along that same path, there's no information
about that path that that original message took.  And so, along with the message
itself, there's this ability to provide a reply path or certain route hints to
the recipient of that message, so that if they choose to reply for whatever the
use case is for these onion messages, there's this hint of where the message can
be sent back.

**Mark Erhardt**: Yeah, exactly.  So, when we have onion messages, each layer
only learns about the previous hop, so the recipient actually never knows who
the sender was.  And that's why we need to hint, "Hey, I sent that message, you
can reply to me here".

_HWI #627_

**Mike Schmidt**: Great.  I'm not sure we've had a recap in which HWI has been
one of the topics.  So, this is a PR to PR #627, and that is actually to the HWI
repo.  So, Optec is not just looking at Bitcoin Core or some of the LN
implementations, there's some of these other projects that we think are valuable
to have our eyes on.  And one of those is this Bitcoin Hardware Wallet Interface
(HWI) project, which is actually a repo within the Bitcoin Core organization.
And the purpose of that repository is an interface command line tool for
interacting with hardware wallets or, as we like to say, hardware signing
devices.  And it provides a way to interact with some of those hardware wallets
without having to deal with some of the specific drivers, and whatnot.

So, this particular PR adds support for P2TR keypath spends using the BitBox02
signing device.  Murch, do you want to augment any of the HWI explanation or do
you want to dive into P2TR keypath spends, or let it lie?

**Mark Erhardt**: No, I think we've talked about that P2TR stuff quite a bit
already in the past.  And I think you covered HWI just perfectly fine.

**Craig Raw**: I can actually jump in here with a little bit of background as to
what taproot support exists on hardware wallets to date, which might be
interesting.  So, Trezor supports, via HWI, taproot keypath spends.  You can go
ahead and use that as of today, so long as you have the most recent firmware and
you are using the correct derivation path, which is defined in BIP86.  Ledger
also supports taproot keypath spins.  However, it does not support the signature
hash (sighash) default value, which I think was introduced in BIP341.  So, you
actually have to use the old SIGHASH_ALL value when you -- I don't believe that
they've updated the firmware to support sighash default yet.  So, that's just
something to be aware of.  They do support, however, keypath spend so long as
you use SIGHASH_ALL.  And I haven't actually tried to do a keypath spend with my
BitBox yet.  I've only just seen this now, so I will certainly go and give that
a try and see if it's all working.

_BDK #718_

**Mike Schmidt**: Excellent.  Thanks for that color, Craig.  Next PR, BDK, so
this is another one of those non-Bitcoin, non-LN implementation projects that we
think is valuable to surface changes to.  And in this particular PR, there is a
change to immediately verify ECDSA and schnorr signatures after the wallet
creates them.  And this is actually from the BIP340 spec, and I think Bitcoin
Core has done this for a while now and it's been recommended in the spec.
Actually, it wasn't initially recommended in the spec, but there's certain types
of attacks that could occur if you're not verifying that signature after you
create it, and I will claim a bit of ignorance on exactly why, what the attack
vector is here, and maybe, Murch, you can opine on that.

**Mark Erhardt**: I wish, sorry, I don't have any color here either.

**Mike Schmidt**: Okay, all right, so the recommendation from the BIP is to
verify the signatures after you create them.  There are certain types of, I
think, nonce attacks that could potentially occur in which verifying the
signature after creating it can mitigate that attack.  There's a few different
links to previous Optech Newsletters in which you can jump in, and I think
there's some information in BIP340 to read on that as well.

_BDK #705 and #722_

The last PR for this week is actually two separate PRs but they're in the
similar vein, in which BDK is providing access to two additional services,
Electrum and Esplora, and a somewhat sort of just API wrapper for those
different services, so that if you're using BDK, you can call out to Electrum or
Esplora, which is a block explorer service, to get additional information that I
guess is not inherent to BDK itself.

**Mark Erhardt**: Yeah, I believe BDK has an option to run on compact
client-side block filters, and in that case, it wouldn't have necessarily the
whole block data.  And being able to connect to Electrum or Esplora in the
background would serve a similar function, as we heard earlier already with
Sparrow.

**Mike Schmidt**: Makes sense.  All right, well, we are just over our hour slot
here.  I want to thank Murch for joining as a co-host this week, and for Craig
for joining and telling us a little bit about Sparrow and his proposed wallet
label export BIP and how that went.  Any final comments, Murch or Craig?

**Mark Erhardt**: Thanks for joining.  It was very interesting to hear about
Sparrow Wallet.  Thank you.

**Craig Raw**: Yeah, great.  Thanks for having me on.  It was great to have the
opportunity to chat more about the wallet label export format.  If anyone has
any particular thoughts on it, please reach out to me.  I'm @craigraw,
obviously.  And, yeah, keen to hear what people think.

{% include references.md %}
