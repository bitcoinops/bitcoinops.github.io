---
title: 'Bitcoin Optech Newsletter #240 Recap Podcast'
permalink: /en/podcast/2023/03/02/
name: 2023-03-02-recap
slug: 2023-03-02-recap
type: podcast
layout: podcast-episode
lang: en
---
Mark "Murch" Erhardt and Mike Schmidt discuss [Newsletter #240][news240].

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://anchor.fm/s/d9918154/podcast/play/66072343/https%3A%2F%2Fd3ctxlq1ktw2nl.cloudfront.net%2Fstaging%2F2023-2-6%2Fc7ab548d-fc59-cef8-9cad-b99e5a15ca54.mp3" %}

## News

{% include functions/podcast-note.md title="Faster seed backup checksums" url="news240 checksums" anchor="checksums" timestamp="2:31" %}

## Releases and release candidates

{% include functions/podcast-note.md title="HWI 2.2.1"
  url="news240 hwi" anchor="hwi" timestamp="10:17" %}
{% include functions/podcast-note.md title="Core Lightning 23.02rc3"
  url="news240 cln" anchor="cln" timestamp="11:38" %}
{% include functions/podcast-note.md title="lnd v0.16.0-beta.rc1"
  url="news240 lnd" anchor="lnd" timestamp="12:03" %}

## Notable code and documentation changes

{% include functions/podcast-note.md title="Bitcoin Core #25943"
  url="news240 bc25943" anchor="bc25943" timestamp="12:59" %}
{% include functions/podcast-note.md title="Bitcoin Core #26595"
  url="news240 bc26595" anchor="bc26595" timestamp="15:11" %}
{% include functions/podcast-note.md title="Bitcoin Core #27068"
  url="news240 bc27068" anchor="bc27068" timestamp="16:51" %}
{% include functions/podcast-note.md title="LDK #1988"
  url="news240 ldk1988" anchor="ldk1988" timestamp="18:37" %}
{% include functions/podcast-note.md title="LDK #1977"
  url="news240 ldk1977" anchor="ldk1977" timestamp="20:15" %}

## Transcription

**Mike Schmidt**: Welcome everybody to Bitcoin Optech Newsletter #240 Recap on
Twitter Spaces.  My name is Mike Schmidt, I'm a contributor at Optech and also
Executive Director at Brink, where we fund open-source developers.

**Mark Erhardt**: And hi, I'm Murch, I work at Chaincode Labs on Bitcoin stuff.
I just did a guest lecture here in New York at one of the colleges and today
I'm contributing to Optech again.

**Mike Schmidt**: And also, Murch is a prolific Stack Exchange contributor and
answerer, I would add that in.  We have one announcement that at least I had in
mind for this week, Murch, you may have more, but we did announce yesterday that
these Twitter Spaces, including the one we're recording now, are going to be
bundled into a podcast, so we've launched that feature on the website as of
yesterday, and that includes an RSS feed for the podcast, and that feed includes
things like show notes with timestamps, which you'll see in your podcast
catcher.

But also, if you go to the individual page on the Optech website for each
podcast, we actually have transcriptions available for the entire podcast, and
we also link within the newsletter.  So, if we're covering Newsletter #240, when
this comes out in podcast form, we'll be linking to the newsletter itself and
the newsletter will actually be able to link to the podcast, where we actually
have conversations about each of these pieces.

So, it's a good way to preserve this content that Murch and I have been
fortunate enough to be exposed to with a lot of these experts; and original
authors of the research and the software that we cover have been kind enough to
join us in these discussions and it would be a shame to leave all of that
content just in an obscure Twitter Space recording, which may get lost.  So,
we've tried to augment that content with as much additional linking and context
as possible so we can preserve these valuable discussions.

Murch, thank you for being a part of this for the last several months and
hopefully, in podcast form, this can show up in search engines and people can
read it and we can link to it and preserve these interesting discussions.  So,
thank you for being a part of that.

**Mark Erhardt**: Yeah, my pleasure.  That was also my announcement!

**Mike Schmidt**: Okay, great.  Well, we can jump into the news section for this
week.  For those following along on Twitter Spaces, I've shared some tweets that
are relevant to this week's newsletter and you can open up Newsletter #240 on
the bitcoinops.org website as well to follow along.

{:#checksums}
_Faster seed backup checksums_

We just have one news item this week, which is faster seed backup checksums, and
this references our news discussion from last week when we had Russell O'Connor
on talking about Codex32.  So, for the full context, jump back to that
newsletter and that podcast discussion with him.  So, Peter Todd replied to the
mailing list discussion about Codex32, and he proposed essentially some quicker
ways of getting quality verification without having to do as much calculation;
that's what I took away from it.  I think, Murch, maybe it would make sense to
quickly summarise what is Codex32.  Obviously, people can go back and read the
coverage from last week, but in order to frame the discussion this week, what is
Codex32 and how does it relate to these BIP32 seeds that people may be familiar
with?

**Mark Erhardt**: So, Codex32 is a proposal, or a scheme, which you can use to
make sharded backups of your keys.  And one of the interesting parts of that is
each of the shards is encoded using Bech32, the same encoding that
we use for native SegWit addresses.  The encoding has
a checksum, so it is easy to verify that the shard has been transcribed
correctly.

Basically how it works is that you have paper computers, just paper discs that
you can shift around a pin on each other, it's called volvelles, that you can
read off charts with.  That enables you, together with some paper charts that
you fill in, to completely calculate keys offline, to have multiple shards for
backing them up, to make checksums on those to ensure that you didn't make any
mistake.

So, what Peter Todd, from skimming the discussion on the mailing list, what
Peter Todd is proposing here is we could have a much easier checksum scheme to
get an initial read on whether there are some simple mistakes on your
transcription of the backups, and he basically proposed something that would
just add up the characters in the backup seed and then see whether it matches a
number out of 1,000, so basically a modulo 1,000 scheme, and he said that would
be so easy, people could just learn how to do it and it might be better having
the more complicated, but much, much stronger checksum scheme that Professor
Snead and Dr, what was it, are proposing.

**Mike Schmidt**: Forgot the other doctor who was involved there!  Okay, so it
would be easier for me, or easier for anybody using Codex32 to do some
verification, so therefore I would be more likely to do it because it would
actually be mechanically easier for me, but I would have less assurances that
the verification that I did offline would be correct.  But we're talking, what,
99.9% versus some slightly higher version of assurances; am I understanding that
correct?

**Mark Erhardt**: So, yes and no.  So, if you only make a single mistake, the
scheme would probably be sufficient to find it.  The big advantage of the Bech32
scheme is that it treats every position in the string as basically a separate
factor.  So, not only would you learn what that mistake is, but also where the
mistake probably happened.  And if you do multiple mistakes, there is no chance of
them cancelling out.  If you have a much simpler scheme where you just add up
the values of the characters, then if you have an off by one in one direction on
one character and off by one on another character, for example, you wouldn't
catch that.  Or, if you just switched the position of the characters, you would
not catch that, because the value of the sum would still be the same.

So, I think that it would maybe be a good additional thing that you very quickly
can check, but I'm not sure if it's a good replacement, especially if we're
talking about high-value cold storage backup; the extra effort might be worth it.

**Mike Schmidt**: Now, this is a personal question that I have about the shares.
I know one of the criticisms of Shamir's Secret Sharing in the past was that in
order to actually use the shares, you need to reconstitute the shares on a
single machine in order to, let's say, transact or sign something.  Does that
also apply to Codex32, Murch?

**Mark Erhardt**: I believe so, yes.  I think that is essentially a variant on
Shamir's Secret Sharing, so yes, you would reconstitute the key when you
combined the shares.  The idea is you don't have to combine to confirm that all
the parts are well-formed and properly transcribed.  And, I think if you use the
scheme to make multiple keys and have, for example, a MuSig multisig, then you
wouldn't constitute all of the secrets that you need to sign off on outputs in
one place.  So you would constitute one key, make a signature, then constitute
the other key, make a signature.  You could do this on different devices, could
do it in different locations.

**Mike Schmidt**: Okay, that makes sense.  And one more question that I have
that I'm curious about is, I know you have experience with custody and keys and
different schemes.  I've heard of this MPC, Multi-Party Computation, I believe;
are you familiar with that and how it's related to these sorts of schemes at
all, or do you want to comment on that, and if not we can move on?

**Mark Erhardt**: Multi-party computation is an approach that is essentially an
alternative to doing multisig.  It is in essence very similar to Shamir's Secret
Sharing.  At the point of signing, you need to reconstitute the secret key in
order to use it.  It is often marketed as, "There's no keys in this scheme any
more, because people just have shards and the shards are not keys", and I think
that's often a little disingenuous, because whether you shard a key or you just
have the keys directly, all of that is still sensitive, secret information, and
it feels like a bit of a hat-trick.

The problem that it is sidestepping is in other protocols, like Ethereum for
example, there is no way to do multisig natively, so using MPC, you can make
signatures but not require -- you can have secrets split up over multiple
parties, that can sign together without using native multisig, but still get the
signoff of multiple people.  The problem of course is that the device that
combines the information from the multiple shares does learn, at least
temporarily, the secret, so the idea is that is some sort of hardware device
that is trusted to only take the inputs from the users and then not be able to
export the key.

I know that Fireblocks I think is MPC-based instead of multisig-based, and
that way they could use essentially the same solutions for Bitcoin and Ethereum;
but it also scared some of the applied cryptographers that I was working with, how new
the MPC crypto was. And I may have made mistakes here, it was like three years
ago that I talked to people about this.

{:#hwi}
_HWI 2.2.1_

**Mike Schmidt**: So, we have three releases that we covered in the newsletter
yesterday.  The first one is HWI 2.2.1, which is a maintenance release.  I saw a
couple of notable things.  One is signing of some P2SH multisigs using the
Trezor hardware device; and then the second thing was pubkey serialization in
ranged descriptors and, Murch, I thought it would be useful maybe for you to use
this opportunity to describe what is a ranged descriptor.

**Mark Erhardt**: A ranged descriptor is basically just a descriptor that
describes a whole series of scriptpubkeys within one output descriptor.  So,
output descriptors in general are a construct that's basically an upgraded
version of an extended pubkey, where you define the general scheme of a
scriptpubkey and leave wildcards for the key material.  I use a
Pay-to-Public-Key-Hash construction, but the keys are from this series of
subkeys in a BIP32 graph.  So, ranged descriptor is basically just like a series
of scriptpubkeys that have the same scheme, but different pubkeys plugged in.

**Mike Schmidt**: Excellent, thank you for that overview.  So, those were the
notable things in HWI.

{:#cln}
_Core Lightning 23.02rc3_

The next notable release candidate is Core Lightning 23.02rc3, which we've had
in actually for a couple of weeks now.  And so, if you go back I think to our
Recap for #238, we had a couple of folks from Blockstream in the Core Lightning
team that came on and gave us an overview of that release candidate, so I think
you should reference that for more details.

{:#lnd}
_lnd v0.16.0-beta.rc1_

And then the last release we had is LND v0.16.0 and this is a beta release
candidate.  A couple of things that I noticed were interesting here was a few
P2P updates for LND, including a bug fix that could lead to some channel updates
being missed; and then also some changes at the P2P level for gossip updates.
They've also added the decryption for larger Onion failure messages, and we've
covered that a few times in the newsletter.  The ability to have these larger
error messages can enable better pathfinding using what we've talked with Joost,
I believe, about fat errors.  So I thought that was interesting.  There was also
something about Taproot, the ability to have watch-only addresses in the
internal wallet for Taproot pubkeys in Tapscripts.  And then, there was a bunch
of other RPC and wallet updates and bug fixes, so jump into the release notes
there, it's really comprehensive there.

{:#bc25943}
_Bitcoin Core #25943_

**Mark Erhardt**: Yeah, super.  So, #25943 basically protects users against
burning funds if they are creating an unspendable output.  So for example, if
you have an OP_RETURN, or you have an output that exceeds the maximum script
size or an invalid opcode, then the Bitcoin Core wallet software will stop you
from assigning an amount to that output, unless you specifically allow it.  So,
you will not accidentally send a lot of money to an OP_RETURN that will never be
spendable.

**Mike Schmidt**: Now, the OP_RETURN example makes sense to me on why that is
unspendable, but also a valid transaction.  Now why, if I'm using an invalid
opcode, why would that even be confirmed or be a valid transaction?

**Mark Erhardt**: That's an excellent question.  I'm not sure why we would even
consider special-casing that, because an invalid opcode would also mean that the
transaction is invalid.  So, maybe this is when people are building transactions
in Bitcoin Core that they want to send to a compatible other network, but
honestly I'm not quite sure.

**Mike Schmidt**: And, does your answer also apply to the case of an output
whose script exceeds the maximum script size as well; is that a similar answer?

**Mark Erhardt**: Yes, so I guess this is why.  When we write an output, we do
not execute the output script, right, we only lock funds to the output.  So, if
the output script includes an opcode that is permitted but will make any
execution of the output script say that it failed, then we will never be able to
spend the funds that are assigned to that output script.  Similarly, the length
of the output script, I think, would be permitted in writing the output script;
but when we execute the output script with the input script on the stack, we
check the length, I think it's 10,000 bytes.  If it's longer than 10,000 bytes,
it would fail at the script execution time, so we would be unable to move the
funds, but we would be able to assign funds to the script.

**Mike Schmidt**: Got you!  Okay, that makes sense.  Thanks, Murch.

{:#bc26595}
_Bitcoin Core #26595_

The next PR that we noted this week is Bitcoin Core #26595, and this pull
request is related to the migratewallet RPC, which enables you to migrate your
wallet from a legacy wallet to a descriptor wallet, and this RPC already exists
but there were some limitations to it.  I believe it only acted on unencrypted
wallets that you happened to already have loaded, and so the changes in this PR
allow you to provide a passphrase for an encrypted wallet, and also to name a
wallet such that it could be a wallet that you don't currently have loaded.  So
now, I think that means that all wallets, encrypted or not or loaded or not, can
now be migrated to descriptor wallets.  Murch, any thoughts on that PR?

**Mark Erhardt**: No, I think you basically wrapped it up completely.  I have an
extra thought that is related to this.  So funnily enough, the Bitcoin Core
wallet support basically always assumed that you were operating with a single
wallet file.  So, for the longest time, we even only had a backup wallet
function but not an import backup function.  And now, especially with the
migration to descriptor wallets, it's just more common that people have multiple
wallet files.  So, I think that you'll find achow, in this case, is getting
around to adding these other functions, like migrating other wallets that you
had previously and importing backups and things like that.  So, basically what
I'm saying is, if you're bumping into these sort of UX issues with the wallet,
we do have an issue tracker on GitHub; let us know what you need.

**Mike Schmidt**: Good plug.

{:#bc27068}
_Bitcoin Core #27068_

Next PR here is Bitcoin Core #27068 and this is also related to passphrases.  It
sounds like previously, if you had a passphrase and you encrypted your wallet
using a passphrase that had a special character, an ASCII null character, which
is 0x00, the passphrase would actually be truncated at the point that there was
a null character.  So, you may have thought that you put in a 20-character
passphrase but if you had an ASCII null character at spot 5, let's say, then you
would have actually those additional characters would be truncated and you would
have a much less secure passphrase that you thought, and obviously there's some usability
then when you go to decrypt that.

So, this sounds like a bug to me and it sounds like this PR fixes that bug, so
that it actually can handle that null character and it also provides some
warning messages for folks if they've run into issues with the truncation.
Murch, are you familiar with this PR, and would you classify this as a bug fix?

**Mark Erhardt**: Yes, and especially, I think, we should point out now if it's
fixed and you put in the long password that you had maybe stored in your
password manager, and now Bitcoin Core handles that password correctly, it would
of course try to decrypt the wallet with the long password while the original
password set on the wallet would have been the truncated password; so, you
wouldn't be able to decrypt it and it'll tell you now, "You need to use the
truncated password", I guess, or that's what I hope, and point out to you, "Your
password contains this special character and here's how you still can decrypt
your wallet".  Yeah, so I think you got it all.

**Mike Schmidt**: The last two pull requests that we covered in this week's
newsletter were related to the Lightning Development Kit, LDK.

{:#ldk1988}
LDK #1988

The first PR is LDK #1988 which adds some limits for peer connections and
unfunded channels to prevent denial of service attacks.  I believe that the
particular resource that was trying to be mitigated here was an out-of-memory
error.  I guess before these limits, there was no limit on data-sharing peers,
or peers which may be trying to open a channel with your node, or the number of
channels that a single peer could be trying to open but has not funded with you.

So, there's three new limits that are now added to LDK: the 250 data-sharing
peers limit; a maximum of 50 peers which may be trying to open a channel with
you; and a maximum of 4 channels that have not yet been funded by a single peer.
Murch, thoughts on these denial-of-service limits?

**Mark Erhardt**: I mean, it's just not possible to be connected to every other
participant on the Lightning Network, so having some sanity limits here makes
sense to me.  And from what it looks like, the one number that is not present is
the number of peers that you have a channel with.  You're obviously connected to
every single peer that you have a channel with, there's only limits on the
number of peers that you will accept that don't have a channel with you yet, and
especially the peers that you're not even trying to have a channel with yet.  I
think that this sums up to over 300 connections already, plus all the
connections that you have channels with.  That seems like a very generous amount
of connections into the network.

{:#ldk1977}
_LDK #1977_

**Mike Schmidt**: The last PR for this week is LDK #1977 and there's a couple of
different things in this PR.  The thing that we noted in the newsletter was
exposing the offers module publicly, but there's also some additional changes in
this PR to fuzzers related to BOLT12 as well.  So, it sounds like while there
are still some limitations, since LDK doesn't have blinded path support yet, you
can start experimenting with offers in LDK now.  Murch, any thoughts on LDK and
offers?

**Mark Erhardt**: Yeah, I've been seeing a bunch of PRs from LDK on offers.  It
looks like they're moving forward pretty quickly with getting support rolling.
And I was recently asked by someone how long it will take until offers will be
widely deployed on the Lightning Network.  So, I think work started about three
years ago.  The first experimental support was two years ago in, I think,
C-Lightning, and we have also seen now, in an announcement by LND, that was
previously focusing on other things, not working on BOLT12 yet, that they intend to have
support for blinded paths by spring this year.

So, I think that maybe by the end of the year, we'll actually have better/at
least rudimentary support for offers across the network, if I understand that
correctly.  It's of course difficult to speak about the roadmap of four
different projects that I only have peripheral insight into.

**Mike Schmidt**: Well, that wraps up the newsletter content for this week.
Thank you everybody for joining us this week and we'll see you next Thursday for
a discussion of Newsletter #241.  Thanks, Murch.

**Mark Erhardt**: Thanks, hear you soon.

{% include references.md %}
[news240]: /en/newsletters/2023/03/01/
[news240 checksums]: /en/newsletters/2023/03/01/#faster-seed-backup-checksums
[news240 hwi]: /en/newsletters/2023/03/01/#hwi-2-2-1
[news240 cln]: /en/newsletters/2023/03/01/#core-lightning-23-02rc3
[news240 lnd]: /en/newsletters/2023/03/01/#lnd-v0-16-0-beta-rc1
[news240 bc25943]: /en/newsletters/2023/03/01/#bitcoin-core-25943
[news240 bc26595]: /en/newsletters/2023/03/01/#bitcoin-core-26595
[news240 bc27068]: /en/newsletters/2023/03/01/#bitcoin-core-27068
[news240 ldk1988]: /en/newsletters/2023/03/01/#ldk-1988
[news240 ldk1977]: /en/newsletters/2023/03/01/#ldk-1977
