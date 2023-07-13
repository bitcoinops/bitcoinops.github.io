---
title: 'Bitcoin Optech Newsletter #234 Recap Podcast'
permalink: /en/podcast/2023/01/19/
reference: /en/newsletters/2023/01/18/
name: 2023-01-19-recap
slug: 2023-01-19-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt are joined by James O’Beirne to discuss [Newsletter #234]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/73032697/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-6-5%2F338126916-44100-2-3731549cebce5.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #234 Recap,
Twitter Spaces.  We'll go through introductions and then we'll jump into the
newsletter.  Mike Schmidt, contributor to Optech and Executive Director at
Brink, where we fund Bitcoin open-source developers.  Murch?

**Mark Erhardt**: Hi, I'm Murch.  I work at Chaincode Labs.  I work on many
different Bitcoin-y things, explain Bitcoin to people on Bitcoin Stack Exchange,
and help with Optech.

**Mike Schmidt**: And we have a special guest this week, James O'Beirne.  James,
you want to introduce yourself, give some background?

**James O'Beirne**: Sure, yeah.  So, thanks for having me, first off.  I've been
working on Bitcoin Core for, I guess, technically eight years now, on and off
sporadically.  Right now I'm employed by NYDIG as a full-time open-source
developer, so that's what I spend most of my day doing.  In the past I've worked
for Chaincode and I'm an old-time Optech emeritus, I guess.

**Mike Schmidt**: Yeah, were you one of the founding contributors?

**James O'Beirne**: Yeah, it was me, John, and Steve Lee.

**Mike Schmidt**: Excellent.  Yeah, it's two of my favourite people here on the
Twitter Space, Murch and James, so thanks for joining us.  Murch, any
announcements before we jump in?

**Mark Erhardt**: I got nothing.

**Mike Schmidt**: All right, well, let's jump into it.  I shared a few tweets.
If folks want to follow along, jump into the newsletter, or follow along with
those tweets to see what we're talking about.  We release a weekly newsletter on
Wednesday mornings, central time, and we'll be going through that now.

_Proposal for new vault-specific opcodes_

This is #234 and the first item on the news list is a proposal for a new
vault-specific opcodes.  James, I think it's best that you introduce your
proposal and maybe as a way to seed the idea to folks, maybe just go through
some of the background about maybe what vaults are and what the problem is that
you're trying to solve, and then we can jump into how you address that with
these opcodes.

**James O'Beirne**: Yeah, sure.  So, that's a lot to tackle, but I'll give it a
shot.  Vaults are something that people have been talking about in Bitcoin for a
long time, I think going back to, I think 2015, when Emin Gün Sirer and a few
other people wrote a paper called Covenants and Bitcoin, or something along
those lines.  But the basic idea is that if you had covenant functionality in
Bitcoin, which is basically just the ability to restrict the flow of funds, not
only on the basis of an unlocking script, but on the basis of the structure of
the transaction and future transactions potentially that it's flowing into, you
can do this thing called a vault.

The basic idea of a vault is just that you encumber coins in such a way that if
you want to spend them outside of a very predefined recovery flow, then you have
to wait some period of time.  And during this period of time, you can sweep
those coins into your predefined recovery flow.  So, the idea is that you might
have some kind of a wallet setup that facilitates relatively convenient access
to your Bitcoin.  But if a hacker gets a hold of that and starts to try and run
away with your coins, then you can have either a process or a third party
watching the chain to see if an attempted spend is going on, and then intervene
by sweeping your coins into this predetermined recovery path.

People have been talking about this for a while, and after these guys proposed a
kind of generic covenant formulation to do this in their paper, sometime later
Bryan Bishop kind of at least implemented, if not devised, a way to emulate this
behavior with pre-signed transactions.  And so the deal there is that you
generate this ephemeral key that you hope only lives for a short lifetime.  And
with that ephemeral key, you pre-sign some transactions, you send your coins
into the transactional structure that's governed by this ephemeral key, then you
delete the ephemeral key.

Obviously, there are some issues with this.  Not only do you have to hope that
you properly deleted the key, but you have to keep track of these pre-signed
transactions because if you lose those, then your Bitcoin is just gone.  So,
there's more sensitive material to keep track of.  And then, if you're
predetermining the structure of the transactions, you're locked into static
addresses and static feerates, and that makes it potentially more difficult and
perilous to actually manage the vaults.

So, when we were in the phase of considering CHECKTEMPLATEVERIFY (CTV), and
maybe we're still in that phase, I hope, I took the opportunity to do an
implementation of this style of vault, but making use of OBJECTTEMPLATEVERIFY.
And what that does is it allows you to avoid having to rely on generating these
ephemeral keys, because basically you're using an onchain mechanism to enforce
the structure of the transactions that you come up with, and that's just CTV,
where you're basically pre-generating this graph of transactions that's
possible, you're coming up with a root hash for that, and then you're locking
the coins under that hash.  And so I like that because it simplified things
operationally a little bit, you didn't have to rely on this ephemeral key.

But unfortunately, you are still pre-generating this graph of transactions, and
so that means you're locking yourself into feerates, you're pre-specifying the
withdrawal path for this vault, which means that any time you want to actually
withdraw from the vault, you have to go through this predetermined flow.  If
someone's captured the keys to that flow, then you're in trouble and you have to
fall back to the recovery path.  And it introduces some chain space waste just
by nature of having to do these extra steps.

Meanwhile, I was looking at the way that the covenants' exploration was going,
and I was a little bit dismayed by how open-ended and general a lot of the
proposals were.  It's hard for me to reason about how something like OP_CAT
would work in practice.  And I was concerned that if we got one of these general
covenant mechanisms, that the resulting script sizes using these mechanisms
would be really, really big and would result in a lot of chain space waste for
operations that might be relatively common.  So, I kind of said to myself, okay,
what if we step back and came up with this thought experiment?  What if we came
up with a mechanism that was just intended to do vaults and maybe did some
covenant-y stuff as a second-order effect?  What would that look like?  And even
if that's not a real proposal, maybe we can use that to kind of benchmark
perspective proposals against, because I really do think that vaults are a very
important use case, both for small-scale users of Bitcoin and obviously for
businesses that deal with managing a lot of Bitcoin.

So, I started to write this paper surveying both the existing approaches and
some of the outstanding covenant proposals and how they interface with vaults.
I came up with this fictional construct, OP_VAULT, which kind of just does
exactly what you'd hope it does for vaults.  And then I decided it would be
interesting to try and actually implement this.  And so, I took a week and did
an implementation, and I was surprised to find that the implementation actually
worked out and it was pretty concise and, I thought, sort of straightforward.
But it gave you all these nice features that allowed vault operation to be
pretty seamless.  So, I'll stop there and see if everybody's followed.

**Mark Erhardt**: Cool, thanks for that overview.  So, I think that's a great
way of approaching the subject, especially if you're interested in such a
specific application to argue from, "Hey, I want this application, what do I
need to get that application?" rather than to have this, as you said, open-ended
process, "Look what I can do.  We could use it for X".

So, I was reading over Harding's excellent write-up on your proposal, and I
think I would like to take a little step back and ask some very stupid
questions.  So, how many addresses are involved in your vault scheme?  Where do
the funds sit in the beginning, is it in the highly trusted path; is it in the
low trusted path, but has only one way to flow out?  Could you give us a rundown
on how do the funds move through your vault system in the happy path case, as
simple as that as well?!

**James O'Beirne**: Yeah, for sure.  So, to get to the beginning of your
question, in terms of the number of addresses in use for this vault scheme, it
really depends on what your desired operation is as an end user.  Because let me
describe sort of, yeah, the happy path flow.

So, if you want to use this feature, what you do is you send some coins to a
scriptPubKey that has the following formulation: it's going to have the OP_VAULT
opcode, and then there are three parameters associated with that opcode.  The
first one is the recovery specification, and that is basically a hash of the
scriptPubKey target for your recovery path that you're allowed to, at any time,
sweep the funds to; and then the other component of that recovery parameter is
the scriptPubKey, the optional scriptpubkey, that you have to satisfy to
actually trigger that recovery process.

So, when I first proposed a vault, I didn't actually have that scriptPubKey
guarding the recovery process, and that meant that if you used a recovery path
across multiple vaults, that if you recovered one of them, you could replay that
against all of the other like vaults.  And so, after some discussion and a
recommendation from AJ Towns, I decided to introduce the optional functionality
to guard that recovery process by another key, so that's kind of optional.  So,
that's parameter one, is the recovery stuff.

**Mark Erhardt**: Okay, so let me recap.  So, the first one is basically, at any
point in time, I can take the funds out of this first address and move them into
a safe storage?

**James O'Beirne**: Yeah, that's correct.

**Mark Erhardt**: But you do have to sign though with the first address's key in
order to engage it, otherwise other people could basically always lock up all
your funds immediately.

**James O'Beirne**: Well, so they may not actually be able to lock up your funds
immediately, even if you didn't have that key signing because again, you're
giving the hash of the target scriptPubKey.  The scriptPubKey itself is sort of
the preimage.

**Mark Erhardt**: Right.  It's a preimage, but once it has been used once -- I
mean, sorry, third party could replay and sweep all of your funds into your
vault instead of just whatever you intended to do it for the first time.

**James O'Beirne**: Yeah, exactly.  And the rationale there, the reason that I
didn't start off by guarding it with a key sign is that the odds are, if you're
using a vault and let's say that you have multiple coins deposited into this
vault, so to speak, if you're using the recovery taps for one of those coins,
odds are that something's really gone wrong with the vault itself.  And so, in
any case, you should be recovering everything there.  But I guess that may not
be the case for certain reasons, and so decided to add that optional
functionality to guard the recovery path by an additional scriptPubKey option.

**Mark Erhardt**: Cool, okay.  I think I understand the first route of the
scriptPubKey.  What's the second?

**James O'Beirne**: Right.  So, going back to creating the initial script for
this vault, you've got the recovery parameter, which we just talked about, and
then you've got the spend delay.  And that dictates how long, in terms of a
relative timelock, you have to wait between triggering an unvault and actually
finalizing that unvault to your ultimate target.  So, that's pretty
straightforward.  And then, the third parameter is the unvault scriptPubKey
hash, which like we just talked about with the recovery, that's the
specification for how you actually authorize an unvaulting process to begin.
So, packaging those three parameters up into an OP_VAULT, you have an address
that you can send multiple UTXOs to.

Now, this gets a little bit more complicated.  Potentially, if you want to
actually stagger your recovery path, you could, say, generate some keys offline
in a super-cold way and then get an xpub for those keys.  And then, you could
generate different vaults that have different recovery paths, but are governed
by the same recovery key functionally.  So anyway, you have some optionality in
terms of how many addresses that you use, but I think one user-friendly method
might be to just basically reuse the vault parameters and you can send multiple
UTXOs into the same vault.

Then, at unvault time, what happens is you can spend multiple vaulted coins into
the same compatible unvault, OP_UNVAULT, output.  And basically, coins that are
compatible are coins that have the same spend delay and the same recovery path,
and you can spend those into a shared OP_UNVAULT output.  And the idea there is
that when you're spending an OP_VAULT, the script interpreter is basically
saying, okay, I want to ensure that this OP_VAULT is being spent into a single
OP_UNVAULT output that has these compatible parameters, and ensures that you're
using the same spend delay and the same recovery path.

So, from there what happens is, with the OP_UNVAULT output, you're specifying
what I call a target hash.  And that's basically, it's almost a CTV-like hash of
the set of outputs and amounts that you're trying to unvault to.  And then that
OP_UNVAULT output sits there for whatever the relative timelock that you
specified.  And then, at any point after that, that OP_UNVAULT can be spent into
a transaction that matches that target hash.  And so, while that transaction is
pending, of course, all the coins can be swept into your recovery path.

**Mark Erhardt**: Okay, so the unvault operation is not tied to a specific
staging address afterwards, because it is the mechanism by which you can more
flexibly send the funds somewhere else.  But they incurred the delay that you
had previously specified in the OP_VAULT, and only after the delay is over, and
during the delay, basically just like a Hash Time Locked Contract (HTLC), where
the other party can take the funds if you've revealed the secret to them before,
you can take it back to your highly-trusted setup.  Whereas, after the delay,
you can only send it to a transaction that you have predefined.  Is that about
right?

**James O'Beirne**: Yeah, that's right.  Yeah, in many ways, I think the HTLC
Lightning analog is pretty useful here, because just as you described, it is
basically this contestation period where you can intervene or not intervene.
And of course, that sort of points to the use of watchtowers.

**Mark Erhardt**: So, one comment where I made the laughing emoji earlier, xpubs
are so 2020, you should really use a descriptor here.  And have you looked at
combining your proposal with miniscript, is what I was thinking there?

**James O'Beirne**: Yeah, as you can tell, I'm a geriatric old-timer, and so I'm
not up to date on the latest miniscript stuff.  So, I haven't looked at actually
how OP_VAULT would interface with miniscript, but if that's something that's
important, that's something that I'll ultimately find out about, I guess.

**Mark Erhardt**: Okay, and I have another follow-up question.  So, you said
that it is only compatible if you want to do an OP_UNVAULT, you can only unvault
the funds that are compatible.  And this is, of course, because OP_UNVAULT
repeats the same trusted spending path commitment, right?  So, when you said
that, I was first thinking, why wouldn't I be able to unvault multiple vaults in
parallel, as long as I just wait for the longest delay period among them?  But
it is only compatible with the same script because you have to repeat it in the
OP_UNVAULT; is that right?

**James O'Beirne**: Yeah, I think that's right.  And obviously, the recovery
paths have to match because if you're sweeping a single UTXO to recovery, then
you can't mix those.

**Mark Erhardt**: So, we get a funny, interesting trade-off here, where we
essentially get more flexibility about how much funds we want to unvault, but
only if we reuse addresses.  So, if we use the descriptor/xpub idea to have a
set of different vaults that are all derived from a chain of keys, we would lose
that flexibility and would only be able to unvault discrete amounts
corresponding to whatever we had staged in each separate vault.  But then we

wouldn't have address reuse, just a thought.

**James O'Beirne**: Yeah, that's right.  So, I mean it's sort of a classic
trade-off, in my mind, between privacy and efficiency.

**Mark Erhardt**: Cool.  Mike, I think we've got one question from the audience.

**Mike Schmidt**: Yeah, before we jump to that, Murch, you were sort of asking
about the flow, and I just wanted to confirm as well.  It sounds like you have
the initial output that you want to be vaulted, which then moves into an
OP_VAULT output, which then at a later time moves into an OP_UNVAULT or trigger
output, which then finally results in the final output; is that right?  If you
count the initial output and the final output, then there's four outputs along
this path; is that right, James?

**James O'Beirne**: I think that's right.  Yeah, it depends on, yeah, if you're
including the initial output that you're vaulting, then it's four total outputs.
But it's important to note that one of the strengths of this proposal, I think,
is that if let's say you're doing a daily DCA on your exchange and you want to
have it automatically deposit into your vault, with this scheme you actually can
join those disparate outputs into a single unvault, or recovery operation.
Whereas historically, those would have to be n different life cycles for n
different vaults.

**Mark Erhardt**: Okay, I'm just staring at the description again, and I think
our speaker request dropped off.  So, you said that the third parameter on the
vault, OP_VAULT, is a commitment to a less trusted spending path.  What is this
in the OP_VAULT?  I'm not sure if we've talked about this.  So, the commitment
to the highly trusted spending path is clear, that's our, lock everything down,
something has gone wrong, path, which then takes effort to get the funds out of
later, but makes them very safe.  So, does the vault have an escape valve to say
my mobile wallet for convenient access to spending money; or what is that third
part of the OP_VAULT?

**James O'Beirne**: Yeah, so that's simply the commitment to what is able to
authorize the start of the unvault process, or what I call the trigger
transaction.  So, that's basically just saying what can begin an unvault
process.

**Mark Erhardt**: Oh, this is the key that says, "Hey, put it in the lockbox",
or, "Hey, create the OP_UNVAULT", and then the waiting period, which still has
the lockbox option in parallel?

**James O'Beirne**: Yeah.

**Mark Erhardt**: I see.  Okay, cool.  What else are we missing about your
proposal?  Do you want to get into the nitty-gritty somewhere still, or what
sort of information and communication are you looking to get?  Do you want
feedback, or what should our listeners approach you with?

**James O'Beirne**: Yeah.  I guess I'd really like to hear from both individual
users and perhaps people who are doing large commercial Bitcoin operations,
because this proposal for me was very much motivated by not only my own desires
as an individual Bitcoin user, but watching the evolution of custody systems at
a few different businesses.  I think both are really critical functions to serve
well in Bitcoin.  So, yeah, I guess I'd just like feedback on whether this
interface meets the needs of users.

**Mark Erhardt**: Yeah, you can ask Rodolfo and Jameson!

**Mike Schmidt**: Yeah!  I had a question on that note.  Obviously the
proposal's out, you're seeking feedback on it.  I think you've gotten some good
feedback and we can touch on that briefly.  I'm curious, as somebody who's
proposing a new feature, a new opcode, did you work with any custodians or
exchanges or software developers before this proposal?  Obviously, you have in
different capacities and you've built up that knowledge incidentally over your
years, but did you specifically go to gather requirements or do any discovery
from the ecosystem, other than what you've already done naturally?

**James O'Beirne**: Yeah, at the risk of being brief, I don't want to divulge
too much about who's involved in that process, but yeah, there was a lot of
boots-on-the-ground gathering of requirements.

**Mike Schmidt**: Yeah, obviously at Optech, part of our mission is to liaise
information from developers to the broader ecosystem.  But one thing I'm also
curious is how that information flows the other way from businesses and users
back to developers, which is why I asked that question.  So, it's nice that you
spoke with some people beforehand.  And then to the feedback part, the proposal
received quite a bit of what I would call constructive feedback on the mailing
list.  It wasn't just necessarily "Rah-rah!" or poking holes, but you mentioned
AJ's concern about third parties freezing funds and it sounds like you adapted
the proposal to handle that.

I think another point of constructive feedback was from Greg Sanders and talking
about doing a P2TR construction; do you want to comment on that piece?

**James O'Beirne**: Yeah.  So, when I initially released the proposal, partially
just out of kind of ease of implementation, the way that it had to work was that
the OP_UNVAULT output had to be there so that the script interpreter could
verify that all the parameters were carried forward from the OP_VAULT output.
And I was sitting across from Greg while a lot of this was going on, and picking
his brain, and he's just kind of a wealth of knowledge about scripting.  And so,
his response was like, "Well, look, why don't you just put the additional
information that you need to construct expected script hash outputs, and then
you can seal the whole vault process in either P2TR or P2WSH if you want to.
And so, that was a really good suggestion and it was actually pretty easy to
implement.  So, thankfully it got implemented.

The other suggestion that came in from AJ as well was this idea of adding an
optional output during the OP_UNVAULT transaction, to facilitate an immediate
redeposit of the balance of the vault into the same vault construction that you
were pulling out of.  That just allows you to manage the remaining balance
separately from the pending unvault process.  So, all those were great pieces of
feedback.  And I think what I liked about this process was, I think, because I
came to the table with a completed, or a relatively complete draft
implementation, people could very quickly see, okay, what exactly are you doing?
What's going on here?  And it was easy then to give concrete suggestions about
how the proposal might be better.

**Mike Schmidt**: One other criticism I think that you've already addressed, and
is maybe not even part of the proposal per se was Andrew Chow commenting on
address reuse.  Do you have anything further to say on that?  I mean, it sounds
like you could reuse the address, but you could also choose to generate a new
one, so maybe the point is moot there.

**James O'Beirne**: Yeah, I think the design right now just defers that decision
to the end user.  And I'd be very curious if anybody has any ideas for how to
batch the spend of vaults that don't have compatible parameters, at least
explicitly, like maybe they hide behind the same xpub or descriptor.  But my gut
tells me that's going to be difficult, if not infeasible to do, especially with
an implementation that isn't really hairy.  So, I just think that might be kind
of a fundamental limitation of the problem space.  And again, I think the best
that I could think to do is to defer that choice to end users.

**Mike Schmidt**: Can you comment at all about the batching features of this
proposal?  It sounds like you've taken that into account and batching is
supported, but maybe you just want to comment a level deeper on that.

**James O'Beirne**: Yeah, so again, if you think about both the industrial user
and the individual user, for the industrial user there's really good reason to
want to do these vaults if you have some kind of a custody system.  But the
prospect of having a separate life cycle, where you have this say four-output
life cycle, for each UTXO that you're vaulting, the chain space implications,
they really add up quite a bit.  And if you have a situation where there's an
attacker that's compromised your unvault keys and you need to switch to
recovery, you need to be careful that you've chosen your spend delay to
facilitate enough chain space to be able to do those end life cycles to recover
your vaults, because you may get into a situation where you're slamming the
chain with all of these recovery transactions and fees go up, and so forth.

Then, you have the same problem as an individual user, although likely the
counts of UTXOs aren't as high.  But I mean, again, if you go back to the daily
DCA use case where you've got 365 vault UTXOs per year, managing those
separately would be very, very cumbersome.  And so, this ability to batch, as
I've kind of gone down the road on this design seems more and more critical to
actually sort of practically manage this stuff, because otherwise you're just
creating a tremendous number of outputs and you may have difficulty responding
to an attack in time.

**Mark Erhardt**: So, I mean I've certainly not spent enough time to think about
this, but if you put the OP_VAULT operation into a script leaf of a P2TR output,
the keypath could be a MuSig construction of the highly trusted path.  So, even
if you can then use the unvault to extract and reuse the unvault, it (a)
wouldn't be immediately visible on the chain because it's hidden in the script
tree, and (b) you could combine all of those UTXOs.  But you could have a tweak
for the keypaths to make them all look differently, and you could still batch
pay them together by using your highly trusted setup.

This is just off the top of my head, but I think that the P2TR construction
could come in extremely handy here to give you both more privacy and still the
ability to batch all the, say in your DCA case, outputs together in a clean
fashion.  Anyway, we should look more into the P2TR thing!

**James O'Beirne**: Yeah, I'm actually really thrilled you brought that up,
because that's exactly how I wrote it in the functional test cases.  So, if you
look at the functional tests that I attached with the implementation, that is
exactly the structure that I use by default.  So, you can always immediately
spend the vault outputs with your recovery path.

**Mark Erhardt**: Cool.  Yeah, anyway, let's chat about that some other time a
little more.

**James O'Beirne**: Sure.

**Mark Erhardt**: Okay, after I've thought a little more about it.  Anything
else about your OP_VAULT proposal or maybe, what do you think, Mike, is this a
good point to take a question about this, so if James has something else later,
we can let him go after?

**Mike Schmidt**: Yeah, we can open up the floor.  If anybody listening has a
question, feel free to raise your hand or request speaker access.  While you
consider your question, I'll pose one to James here.  I think, James, you had
touched upon some of the incidental non-vault-related scripting that could be
done with these opcodes, like some of the features of OP_CTV potentially.  Do
you want to comment in a somewhat quick manner about what sort of things this
could also enable besides this use case that we've walked through?

**James O'Beirne**: Sure.  So, yeah, kind of funnily enough, the target hash
that I described with the unvault process, that actually looks a lot like CTV,
and people very quickly realised, to my entertainment, that you can emulate CTV
kind of by skipping the OP_VAULT output and just sending coins directly to an
OP_UNVAULT with a zero spend delay, and then a recovery path that points to
nothing, and then coming up with basically a CTV hash for the target hash.  And,
I mean I find it funny that so many people are excited about doing this because
it's like, "Well, hey, maybe we should just look at including CTV as well".

But some of the things that you can do with this, you know, Ben Carman posted to
the mailing list talking about how you can use Lloyd's DLC efficiency schemes
that previously relied on CTV, you could basically do that same scheme with the
OP_UNVAULT use.  I'm sure there are more CTV-ish --  perhaps any use case that
applies to CTV might apply to this unvault hack, but I haven't looked closely at
it.

**Mike Schmidt**: Looks like we have some potential comments and questions.
Rodolfo, I think you were first.

**Rodolfo Novak**: Hey, sorry, I missed by the time you said my name there, I
lost the context.  So, James, we were talking on a sidebar there before.  So, my
main concern with this setup is you still have a key, right, that is your sort
of backup, ultimate nuclear key.  And that, at least in my mind, puts you back
into the same square one of having to defend that key, right?  If anything, it's
kind of worst because you have this awesome complication that prevents attackers
from doing something, but now you have a single point of failure with that key,
where they can just drain everything.  Would you nest that into another sort of
vault; or how would you handle that sort of nuclear key?

**James O'Beirne**: Yeah, so I think it's important to remember that people need
to know two pieces of information potentially to sweep into the recovery: (1)
the preimage of the scriptPubKey hash; and (2) if you choose to, obviously being
able to sign with the scriptPubKey you specify.  So, it's not like an attacker
can just trivially route you into the recovery path.  So, that's where I would
push back on this idea that it's just deferring to complexity.

**Rodolfo Novak**: Okay.

**James O'Beirne**: Then, the other thing to keep in mind is the recovery path
is almost like, I wouldn't expect that you're going to be using that, it's
almost like an insurance policy.  In some of the industrial operations I've
seen, the unvault key is not like a hot wallet just sitting on some computer.
And if I was using it, my unvault key would be like, say, an offline Coldcard.
So, it's like a measure that you would take to safeguard your keys in the first
place, it's just that this recovery path is kind of like an uncorrelated
failsafe.  So, from my perspective, it's just additive in terms of security.

**Rodolfo Novak**: So, if we sort of dumb this down, what you're describing is
you have a key and then you have another piece of information that is also
sensitive, right?  So, you have two pieces of information you're going to need
to recover as your recovery setup, right, your nuclear setup.  So, I don't know,
my stupid brain just keeps on going back, then why create the complication?
It's like, what am I gaining if I steal back at having two pieces of information
that I need to recover?

**James O'Beirne**: Yeah, please, Jameson.

**Jameson Lopp**: All right.  So, I've been thinking about this a fair amount
myself.  Obviously, if you're creating a vault construction here, yes, you are
adding complexity.  Now, I think James, his particular proposal has decreased
the complexity by potentially an order of magnitude compared to a lot of the
other proposals that have come in the past decade.

**Rodolfo Novak**: Oh, for sure.

**Jameson Lopp**: But the way that I've started to think about this is actually
in terms of proactive versus reactive security.  And as any of us who have been
developing wallets are aware, this is like Bitcoin security in general, this is
a bearer asset, there's really no flexibility when it comes to making mistakes.
The default single-sig setup, it's very easy to have single points of failure.
Basically, if you have a point of failure, it tends to be catastrophic.  And so
that's why over the years, we've gone down this path of creating more complex
constructions with things like multisignature, distributed keys, so on and so
forth, because we're basically trying to build higher walls to have stronger
proactive security and to allow a little bit of extra redundancy, allow for some
mistakes to happen.  But still, if somehow all of these measures you've put in
place fail, it tends to be catastrophic.

Now, with a vault construction like this, all of a sudden you have the ability
to react.  You can tell onchain if your setup has been compromised.  It's kind
of analogous to HTLC constructions and the sort of game theory that is being
used with the LN, where you can have watchtowers that can tell if someone's
trying to cheat you.  So, I see a potential path forward with, we'll call it
well-thought-out vault constructions, because obviously it will be possible to
create poorly-thought-out vault constructions and key setups.  But you can
essentially create a new type of game theory so that even if all of your
proactive security measures fail, you have this fallback mechanism that can
react and try to get you back into a sort of happy state.

I do believe that you would end up having essentially two different, strongly
proactive setups.  You'd have your primary vault setup and you'd have the
recovery wallet setup.  But it seems that this, as a fundamental building block
for Bitcoin security, it really enables almost like the flipside of the coin.

**James O'Beirne**: Yeah, well said.

**Mike Schmidt**: Rodolfo, do you want to respond?

**Rodolfo Novak**: Yeah, so I don't disagree with anything you guys are saying,
I think I'm just I'm still stuck on the risk of the recovery as a point of
failure versus -- the script itself, all the ops stuff, like the OP_VAULT stuff
is really amazing.  Is there essentially more thought or more ways we could do
the recovery so that the recovery is less risky in terms of its simplicity?

**James O'Beirne**: Yeah, I don't know if we can actually simplify it more than
it already is.  And actually, one thing you said previously that I didn't want
to respond to real quick, is that to maintain a recovery path, you don't have to
maintain two pieces of information, because if the xpub recovery is derivable
from the private key, then really all you need to do is have that private key on
hand to be able to operate the recovery path potentially.

But I just think if you do something really, really paranoid, like roll a bunch
of dice and generate an offline recovery key, that's not something that's at all
practical to have as a daily part of your, say, multisig arrangement.  But it
allows you to allocate that kind of security in your setup with the appropriate
granularity.  And so, I just think if you treat your recovery path in that way,
if you want to, above and beyond just being an uncorrelated mechanism of
accessing your coins into like, "I'm going to be totally tinfoil, generate this
thing with dice", that allows the crazy dice generation key type to be a part of
your setup without actually impairing your operational complexity or ability.
So, I see it as a really, really good trade-off.

I mean, I think you can definitely make the argument that one vault
configuration is not going to be as desirable as another vault configuration.
But I think something like this mechanism gives you a massive granularity of
different options to come up with, with security that's just a lot simpler and
better than we have today.

**Rodolfo Novak**: So, I could take this offline if this is beyond the scope of
this call, but you guys let me know.  But I guess the issue here is, you have
essentially this key now that's one piece of information.  It puts me back to,
again, I could just have a single-sig passphrase and achieve a very similar
level of security, because there are still the same amount of keys or the same
amount of secret exposed.  Could you make the recovery key maybe be a multi-sig?

**James O'Beirne**: Oh yeah, the recovery key can be any construction.  What's
amazing to -- oh sorry, is somebody trying to speak here?  One amazing use case
to me is the hostage use case.  So, let's say someone breaks into your house and
they're holding you hostage.  You could configure a vault in such a way that to
spend it, to unvault it normally, you have a week's worth of delay.  But then,
to sweep it to the recovery path, the recovery path might be a taptree
reconstruction, where it's only spendable by a quorum of keys after a year.  So,
basically, you're in a position where no matter what happens, the people
breaking in and holding you hostage can't access those coins no matter what you
do outside of a week.  So, I think that's just something that you can't do, for
example, without vaults.

**Rodolfo Novak**: Okay, I'm sold on that now, because the hostage situation is
kind of my jam here on how we think about this stuff!  The dark thoughts really
need to happen when you're thinking about the single points of failure, and I
think that if the recovery key is essentially non-spendable to where you'd send
it if there's a gun to your head, now you're starting to have a way to truly
prevent yourself from giving the money away, right, provably.

**James O'Beirne**: Exactly.  To be clear, this is I think one of the complexity
gotchas, and this is why I said well-thought-out construction.  You want to be
sure that your recovery setup is highly proactively strong, because I think this
is really what Rodolfo is getting at, is that if you have a very
weakly-constructed recovery wallet, then one of the dangers is of course the
coercion aspect.  But one of the other dangers is that an attacker may spend a
lot of time not targeting your vault, but actually compromising your recovery
wallet.  And once they have that compromised, they can take as long as they want
to then either start to compromise your vault, or to somehow trick you or social
engineer you into thinking that your vault is being compromised, and basically
tricking you into sending your funds into what is an already compromised
recovery wallet.  So, that's one of the dangerous situations you want to avoid.

**Mark Erhardt**: I love the discussion right now.  I have one more question
that is sort of a little in a different direction, and then I also think I want
to give everyone a chance to put in some more thoughts, quick thoughts, but we
have a couple more items on our agenda for today.  If any of you have some
urgent or bigger discussions still, maybe just raise your hand in Twitter
Spaces.  Otherwise my question is, James, you mentioned a couple of times that a
watchtower-like thing could be possible.  Now, with a watchtower, it is obvious
if somebody spends an old, rescinded state, because the secret has been shared
already.

But in your vault construction, the OP_UNVAULT would look the same between
whether you sent it or somebody else sent it.  So, how would you tell a
watchtower not to sweep the funds to your vault?  Do you have to basically, like
you call your bank when you go abroad, tell your watchtower, "Hey, I'm actually
unvaulting myself"?

**James O'Beirne**: Yeah, exactly.  So, there would be some amount of
interaction between you and the watchtower, whether that's you pre-authorizing
withdrawal, or whether that's the watchtower actually reaching out to you and
saying, "Hey, it looks like your coins are headed to this target, did you
authorize this?"

**Mark Erhardt**: Okay, so basically some callback mechanism.  All right,
Jameson, Rodolfo, thank you a lot for your thoughts.  Do you have more comments
on this right now?  Otherwise, maybe we'll get to the remaining points.

**Jameson Lopp**: I mean, my only comment is I've started thinking about this
more again recently and I've been looking through the decade-long history of
talking about covenants in general, and then more recently vaults, is that this
is, I believe, a type of Bitcoin primitive or a type of Bitcoin functionality
that is sorely missing and it's not something that should only be interesting to
institutional users, or whatever.  I think this type of construction, like I
said, gives you a whole new facet of Bitcoin security and reactivity.  And this
is something that I think every wallet developer and every self-custody user who
has a non-trivial amount of money should be really interested in seeing pushed
forward.

**Rodolfo Novak**: This is very similar to how we think about trick PINs; it's
this idea of constructing the straps and how essentially you defang your
attacker by creating all this complication and this labyrinth where they don't
understand what's going to happen next, and you de-risk yourself with provable
things.  I'd love to find a few of you guys to maybe talk for two hours about
this recording, because I think it would be great to explore this.  I personally
missed a lot of this because I don't follow the mailing list anymore, but I'd
love to explore further.  Thanks for putting this together.

**James O'Beirne**: Yeah, man, just hold a little retreat up in Canada and we
can come hang out and talk about horrible security outcomes!

**Rodolfo Novak**: We're going to do this on video.

**James O'Beirne**: Oh, okay.

**Mike Schmidt**: All right, James.  Well, thank you for joining us.  You're
welcome to stay on as we go through the rest of the newsletter, but if you have
things that you need to do, we understand if you need to drop.  It's always
great to have firsthand folks working on these proposals explain their proposal
and answer questions.  So, thank you for providing that value to us and the
listeners.

**James O'Beirne**: Thanks so much for having me on to talk about vaults.

**Mike Schmidt**: All right, moving on to the next section of the newsletter,
Changes to services and client software.  So, this is a monthly segment that we
do where we look at changes to software that isn't our core, normal software,
client software applications, software packages that use the Bitcoin or
Lightning protocols.  And some of those are exchanges, some of those are client
libraries.  And as the author of this section each month, I also welcome any
input that folks have.  You can tag the Optech Twitter handle, you can tag my
personal handle.  And if there's something that we're not covering that you
think falls in the capacity of Bitcoin Optech and our interest in Bitcoin
technology being implemented, let us know.

_Kraken announces sending to taproot addresses_

The first one for this month is Kraken announcing sending to Taproot addresses.
So, they had a blogpost here that links off to a few taproot-related resources,
and they are now supporting the ability to withdraw to a bech32m address, so
that's great.  And obviously, with an exchange, the withdrawal process is the
equivalent to send support in a normal wallet.  So, it's nice that they have
that.  Murch, I'm sure you're happy to see that.

**Mark Erhardt**: Yes, definitely.  By the way, if anybody is interested, we
maintain a list of the services and wallets that support sending to taproot
addresses already on whentaproot.org.

_Whirlpool coinjoin rust client library announced_

**Mike Schmidt**: Excellent.  The next item here is a new library for Whirlpool
coinjoin, and there's a rust client now that is compatible with Samourai's
Whirlpool protocol.  One interesting potential application of this is since it's
in rust, and something like the Bitcoin Dev Kit (BDK) is also in rust, that you
could now have the ability to add coinjoin services to your BDK-based wallet.
Murch, any comments on Whirlpool, rust Whirlpool client?

**Mark Erhardt**: No.

_Ledger supports miniscript_

**Mike Schmidt**: Next item here is Ledger supporting miniscript.  So, Ledger
has a couple of different firmwares.  There's a Bitcoin-only and there's a
general firmware, and in their latest Bitcoin-specific firmware, v2.1.0, that
firmware now supports miniscript.  They had announced this previously, and we
noted a blogpost there where they get into some of the details and limitations
of that.  But if you have a Ledger device and you're running that latest
firmware, there is some miniscript support.  So, that's great to see.

**Mark Erhardt**: Yeah, that's super-exciting, I think.  I also saw that the
author of that blogpost is here.  So, if somebody has questions, we might be
able to facilitate.

_Liana wallet released_

**Mike Schmidt**: This miniscript support in Ledger also a bit rolls into the
Liana wallet that was released.  So, the first version of Liana wallet was
announced.  There's a blogpost around that.  This is from the team that provides
similar enterprise type solutions, Revault, and they have this Liana wallet.
And the first version here is a single-signature wallet with a timelock recovery
key.  And then future iterations on this product could involve using taproot to
do this, multisig wallets, and then time-decaying multisig features.

So right now, the use case is a single signature, but if for whatever reason,
you lose access to that, whether that's an inheritance plan and you die or you
lose those initial keys, there's this timelock recovery key where a second key
becomes enabled after a certain timeout.  I think the example they gave in the
blogpost was after a year, you can use this recovery key to recover the funds.
And so there's obviously some interesting real-world use cases for that.

**Mark Erhardt**: Yeah, I thought that was really cool.  So basically, if you
use this in the long term, once taproot has miniscript support, which is
currently not the case yet, you would be able to have essentially what looks
like a single-sig key, and then a leaf in your script tree where eventually your
heirs could spend your money if your UTXO age is more than one year.  So, you
would choose the trade-off that you have to move your funds once a year, but
then if you cannot any longer move your funds, your heirs would automatically
get access to that by holding their own keys.

I think this is a very simple and effective construction on how to have a
built-in dead man's switch that transfers ownership of your coins to somebody
else after a delay, without compromising security before the delay is -- you can
share keys directly with heirs, but what if the heirs just decide to take your
money, as a simple counter example of how that might go wrong.  So anyway, this
Liana wallet is a very simple construction and enables something that a lot of
people have spent time thinking about in the past few years, like what happens
to your stash if you croak.

Yeah, anyway, I think especially when taproot gets miniscript support, this will
get nicer still because right now, the construction would explicitly tell
everybody what you're doing in your P2WSH output, and that of course reduces
your privacy.  But once you can build it with taproot, it would be very clean.

**Mike Schmidt**: And in that Liana blogpost, they also mentioned this Ledger
supporting miniscript as one of the hardware devices you can use to sign for
such a construction, so those two are somewhat related.

_Electrum 4.3.3 released_

And then, the final announcement for changes to client and service software for
this month is the Electrum 4.3.3.  I thought this was worth noting.  There's
nothing groundbreaking here, but just general improvements for Lightning, for
handling PSBTs, for working with hardware signers, and then some improvements to
their build system as well.  Murch, any comments on the Electrum release?

**Mark Erhardt**: Yeah, I was just thinking how nice it is that this standard of
PSBTs is getting out there.  So, PSBT of course is essentially a way how to
communicate about partially signed transactions, as in it makes it much easier
for multiple parties, or one party with multiple devices, to create
transactions.  And in line with other things people are thinking about, like
vaults, like inheritance, like cool tapscripts.  I think that hopefully we'll
get to a future where more people build transactions together, and basically
create multi-party transactions, coinjoins, which just will increase privacy
manifold in the long run, if we can facilitate making this easier.  And all the
tools are starting to come together to make it much easier.

_HWI 2.2.0_

**Mike Schmidt**: Moving on to the Releases section for this newsletter, there
is HWI 2.2.0, and some features that are notable from that release that happened
last week are, if you're using the BitBox02 hardware signer, you can spend using
that taproot keypath and it's also available on the display.  Another feature is
that Ledger Bitcoin app that we just mentioned previously, that 2.1.0 support is
added to HWI.  And a final notable feature I thought was the allowing Trezors,
if you have a passphrase enabled, you can work without the passphrase specified
by defaulting to an empty string passphrase.  Murch, any comments on 2.2.0 HWI?

**Mark Erhardt**: No, but cool that we get more P2TR support on hardware
wallets.

**Rodolfo Novak**: It's coming.

**Mike Schmidt**: Rodolfo, do you want to comment on why it's a good idea to
allow that empty passphrase?

**Rodolfo Novak**: Oh, yeah.  So, that was not a great thing.  So, if you
identify to an attacker that a passphrase is required, you're essentially
telling the attacker to keep on beating you.  So, having the empty passphrase
now means that the attacker doesn't know that a passphrase exists, which is one
of the best benefits of the passphrase.  So, that's my comment there.

**Mark Erhardt**: So, it basically improves the possible deniability in a
hostage situation, which multiple of our speakers today seem to be very fond of.

**Rodolfo Novak**: It's something that does happen and it will happen more as
the space grows.  But also, you can think about it as somebody who's trying to
evil-maid you or exfiltrate.  If they don't know a passphrase exists in your
existing compromised system, where you're using that wallet maybe connected,
you're also preventing that maybe non-wrench attack from being successful, or
the person seeking further.

**Mark Erhardt**: Or talking about the watchtower setup earlier, you could have
a small amount sitting in the non-passphrased standard path, and if that gets
spent, your watchtower moves all your funds to your highly secured recovery path
from your watch, because clearly your wallet has been compromised because
somebody has spent your dummy honeypot amount.

_Core Lightning #5751_

**Mike Schmidt**: We have two notable code changes this week.  The first one is
Core Lightning #5751, which deprecates support for creating new P2SH-wrapped
segwit addresses.  So, right now in Core Lightning (CLN), well, before this
change, I guess this doesn't take effect for another couple of versions, but
there was two ways.  You could have a native segwit bech32 address, so you could
have a P2SH-wrapped segwit address, and they've removed or deprecated support
for that wrapped segwit version; and they've also noted that they hope by the
time that this is deprecated, that there would be a taproot version available.
Murch, any thoughts there?

**Mark Erhardt**: Well, so this week I spent a lot of time talking to some
people, and I don't know if some people saw here, but I think that the old
output types have quite a few disadvantages, and a lot of the privacy benefits
of taproot, for example, will only unlock when a big portion of the space has
moved towards using that one output type.  Because, one of the privacy downsides
of introducing a new output type is, of course, that temporarily it further
splinters the UTXO set, which adds a fingerprint.  But then in the very long
run, since now P2TR outputs allow us to do multisig FROST constructions, to have
the hidden tree paths that only get used if they are needed, a lot more outputs
will look homogenous in the long run.

So, I will always applaud when people deprecate these old, less efficient, more
or less private output types, moving the space towards adopting these newer
types.  And I've talked about this last week a little bit at the end already
too.  We saw a pretty big spike in the P2TR outputs recently.  I think that it
might be from LND rolling out P2TR as their default address type, or maybe
there's other wallets that are doing that now too.  But I think that just in the
long run, more schemes coming out that have explicit P2TR support, or actually
build only on taproot, will move us to where so many people are using taproot
that you do not stand out as a taproot adopter any more, and that'll be a very
nice outcome.  Anyway, how did I get to this?!

**Mike Schmidt**: Deprecating --

**Mark Erhardt**: Oh, the P2SH-wrapper is especially ugly because it just
basically adds some, what is it, 34 bytes of useless junk data that you add.
So, yeah, if you can use P2WSH over P2SH-wrapped P2WSH, you should always do
that.

**Mike Schmidt**: Before we tackle this last change for this week, I wanted to
call for any questions or comments.  So, if you have a question or comment,
please raise your hand or request speaker access and we can get to that after
this last one.

_BIPs #1378_

BIPs #1378 adds the BIP324 for encrypted P2P transport protocol.  So, this is
something that has been a proposal for a while.  I think it was initially under
BIP151 and was a new proposal under BIP324, so that's officially been merged
into the BIPS repository.  Murch, do you want to give a quick overview on
encrypted transport?

**Mark Erhardt**: Yeah, sure.  So basically, this replaces how we originally
created connections between nodes and it will encrypt all the communication
between nodes that participate in this new network service.  It has a new set of
commands on how to communicate what you're asking for, which is slightly more
efficient, so we can actually make the whole communication layer between nodes
encrypted without increasing the amount of bandwidth it takes to communicate
between nodes.

What this does is it just generally increases the cost of passive observers to
find out what's going on on the Bitcoin Network.  For example, if they want to
learn what node originated a transaction, previously an ISP might be in a
position where they always see it because the node that originated a specific
transaction sits in their network.  And since Bitcoin traffic is currently
unencrypted, when it goes through the ISP, they see, "Oh, this is the first time
I see a Bitcoin transaction".  Sure, they would have to run software that logs
that specifically, but now with BIP324, you would have to actively run the
Bitcoin Core software and you would have to actively man-in-the-middle all of
the encrypted connections in order to read that sort of information.  So, it
just raises the cost of a passive observer.

Then in the long term, I think that we might also pursue add-ons to that where
we want to have an authentication scheme between nodes.  So, if you want to for
example explicitly communicate with your full node at home from your mobile
wallet as a source of truth, then you would be able to facilitate that directly
through the Bitcoin network, as in when you connect to your node, you can also
use that as an authentication that you're talking to explicitly your own node at
home.  And that in turn would allow us to build a lot of cool other stuff on top
of that.

So, this is pretty exciting.  This supersedes a really old proposal from I think
2015 by Jonas Schnelli,   so yeah, long time coming.  Looks like it's really
shaping up to get there soon.

**Mike Schmidt**: … correction.  This was mentioned --

**Mark Erhardt**: Your audio seems to stutter for me.  I don't know.  Can you
hear me normally?

**Mike Schmidt**: For one, it's only on testnet but mainnet will be coming in a
few weeks.  And second --

**Mark Erhardt**: Rodolfo, are you hearing the same stuttering, or is it just my
--

**Rodolfo**: No, I heard that too.  I thought it was my phone.

**Mark Erhardt**: Okay, I think that Mike's connection is currently suffering.
He was saying something about the implementation of BIP324, I think, but I can't
really hear what he is saying.  Yeah, let's just give him one minute to see if
he can recover.  LTP, what do you have to say?  LTP?

**LTP**: Hi, are you taking questions?

**Mark Erhardt**: Yeah, what did you want to know?

**LTP**: Thanks, I'm kind of doing the rounds a bit today.  I'm a bit fresh on
sending, so I thought while I've got all the biggest brains in the space, I'll
ask you guys.  Yeah, it's a double-packed question, really.  As I said, I'm
sending for the first time.  I've got a good setup, it's air-gapped, and I'm
using Core.  And the text comes up in red when it's a minus value.  I just
wanted to check that that's correct.  That's typical of looking at recent
transactions in red, because it's a bit alarming to see it, and I don't see any
guidance anywhere about it.

**Mark Erhardt**: Okay, on your air-gapped machine, you will obviously not see
your node learning about new transactions from the network.  So, I think you
will have some --

**LTP**: So, this is specific to Bitcoin Core interface?  And it surprisingly
also comes up on Sparrow.

{% include references.md %}
