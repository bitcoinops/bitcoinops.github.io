---
title: 'Bitcoin Optech Newsletter #278 Recap Podcast'
permalink: /en/podcast/2023/11/22/
reference: /en/newsletters/2023/11/22/
name: 2023-11-22-recap
slug: 2023-11-22-recap
type: podcast
layout: podcast-episode
lang: en
---
Dave Harding and Mike Schmidt are joined by Bastien Teinturier
and Robin Linus to discuss [Newsletter #278]({{page.reference}}).

{% include functions/podcast-links.md %}

{% include functions/podcast-player.md url="https://d3ctxlq1ktw2nl.cloudfront.net/staging/2023-10-22/356737974-22050-1-66ffa9f79ef3b.m4a" %}

{% include newsletter-references.md %}

## Transcription

**Mike Schmidt**: Welcome everyone to Bitcoin Optech Newsletter #278 Recap on
Twitter Spaces.  Today we're going to be discussing an offers-compatible LN
address and the potential ways that that could be achieved; we have eight
interesting updates to different projects in our Changes to client and services
software monthly segment; and we also have our weekly coverage of Releases,
release candidates and notable PRs.  Introductions, I'm Mike Schmidt, I'm a
contributor at Optech and also Executive Director at Brink, where we fund
Bitcoin open-source developers.  Murch is out again this week, which is bad
news, but the good news is we have Dave as co-host again this week.  Dave, do
you want to introduce yourself?

**Dave Harding**: I am Dave Harding, I'm co-author of the Optech Newsletter and
also co-author of the recently released Mastering Bitcoin third edition.

**Mike Schmidt**: We have a couple of great special guests here that we'll
introduce as well.  Bastien.

**Bastien Teinturier**: Hi, I'm Bastien.  I've been working on the Lightning
specification and Eclair, one of its implementations, for a while.

Robin.

**Robin Linus**: Hi, I'm Robin, I work on ZeroSync and on BitVM.

_Offers-compatible LN addresses_

**Mike Schmidt**: Thank you both for joining us.  We'll jump in and go through
the newsletter sequentially here, starting with our first and only news item
this week, which is Offers-compatible LN addresses.  Bastien, maybe for context,
it would make sense, can you explain the existing LN address standard that folks
may be familiar with; and then maybe we can get into your ideas for how a
comparable protocol that uses offers could be implemented?

**Bastien Teinturier**: Sure.  First of all, I'm very lucky that I'm the only
main news item this week, but I'll take this opportunity to spend some time on
that.  So, LN address is something that has become quite popular since -- I
don't remember exactly when it was initially proposed.  The idea is that without
LN address and with only BOLT11 like we had before, the only way to get paid is
to share an invoice with the person that is paying you, which is a QR code or a
string that is basically unreadable for humans.  And they wanted to find a way
to make it a much better UX, like I want to send money to one of my friends,
Bob; I should be able to send it to something that looks like an email address
that is Bob@something, @ some domain, and it should find a way to reach Bob.
And that is really nice from a UX point of view, but the issue is that it was
quite limited with what BOLT11 allowed.

So, the way they are currently doing that is that the wallet provider or domain
owner is hosting special files on an HTTP web server for each of their users, so
that each file contains basically a mapping to the LN identity of that user, and
lets them request an invoice on the fly for that specific user.  But the main
issue with that is that since it relies on the domain owner running an HTTP
server, the payer is going to be connecting for HTTP to that server to get
information about the receiver, to get an invoice to be able to pay the
receiver, which means that the server learns both who the payer is by their IP
address and who the recipient is, because usually the recipient is a wallet user
that is directly connected to their node.  You cannot avoid your LSP from
learning that you are a recipient if you're a mobile wallet user, but you should
make sure that they don't learn who the sender is, because otherwise they have
just too much information.  They could be compelled to filter IP addresses, they
could be compelled to track IP addresses.  So, we'd rather not have that
information in the first place and just prevent that entirely.

But the thing is, it was not easy to make it better with BOLT11, because BOLT11
only uses one-time invoices.  Another issue with that is that you are also
trusting the provider to give you an invoice that really belongs to the person
you want to pay.  But they could just swap it with an invoice that sends the
funds to themselves, and you would pay that automatically without being able to
verify that it belongs to the intended recipient, unless you do some pinning of
another ID of the recipient once and then you verify that, which is possible,
but none of the wallets currently do it today.

So, my idea, since we've been working on BOLT12 for a while now, for a very long
while, but we're nearing the end of the development cycle, so we have many
implementations that have all the bricks in place; it's going to take time to
build the entire UX and end-to-end experience, but the technical bricks are all
here, and all the issues have been solved.  So, I wanted to revisit LN address
to see if there was a way to remove those issues by leveraging BOLT12 and
potentially something different than HTTP.  So, the idea is really simple, is
that since BOLT12 lets you have what is the same thing as a static invoice,
which we call an offer, that's something that you only need to fetch once for
your recipient.  And to fetch that thing, you don't really need to go through
HTTP, you could just use DNS for that.

One of the main drawbacks of using DNS is that on the application side, maybe
it's hard to work with low-level DNS queries, but thankfully there's this thing
called DNS over HTTPS that has become quite popular in the past years, and there
are a lot of providers right now that let you actually do DNS queries but over
HTTPS, which is better for your privacy and also much better for the application
developers, because it just looks like HTTP to them; it's just a normal HTTP
query to get the DNS record.  And what's nice with that is that they're going to
get a DNS record that contains either directly the BOLT12 offer for the
recipient that they want to pay, and the DNS server that is going to answer them
is not the LSP of that user, so the LSP of that user does not learn who the
sender is; or another alternative that I suggest is that the LSPs who own a
domain store a link to their node ID in one DNS record so that you learn the
node ID from the DNS server, you learn the node ID of the LSP of the recipient,
and then you can contact that LSP to get an offer from the recipient.  And the
way you contact that LSP is using onion messages so that you don't reveal your
identity to the LSP.

So, both of these proposals I think should both be implemented because they are
both quite simple, especially on the application side, and they entirely remove
the privacy leak of the sender.  So, I think it's really useful and it's going
to be -- yeah, I think we should definitely do that.  But most of the people who
are currently managing LN address are concerned about backwards compatibility
and the messaging for users.  But what I like with this proposal is that this
can be entirely hidden from the user and an existing LN address should be able
to be migrated to that new system without the user having to change anything.
That's what I would really like to do because I think it would be confusing for
users to have to move to a different protocol that looks exactly the same but is
not the same thing, whereas it could just hide those technical details under the
implementation.  So, I hope we're going to be able to convert on that, and I'm
still waiting for more feedback on people before I turn this into a real
specification.

If there's something that's unclear, don't hesitate to ask, because I think it's
clearer with diagrams, and I've put some of the diagrams in the gist, and I'm
going to add more diagrams to make sure that the flows are easy to understand.

**Mike Schmidt**: You mentioned the sort of cross-compatibility.  How would it
work in a world where both of these potential standards are coexisting?  Would a
particular wallet just try both and see if one works and then fall back to the
second one; or how would that work?

**Bastien Teinturier**: Yeah, that's exactly how I see it.  The wallets could be
updated to first try the DNS approach that directly contains a BOLT12 offer.  If
that fails, they try the DNS approach that gives them a way to contact the LSP
over an onion message.  And if that fails, then they fall back to the existing
LN address key.  And on the LSP side, it's the same, it's really easy to
implement all three of them.  If you're able to create the DNS records to hold
the offers, you do it, and you can keep maintaining an HTTP server for the old
clients that are still using the previous LN address protocol.

So, I don't think there's anything hard here.  It's really easy to make these
backports compatible.  It's just, yeah, we just need to do it, and we just need
to basically show people how easy it is on the client side and potentially maybe
provide libraries that perform those calls to make it easy for any wallet to
implement that.  And also on the LSP side, it's really simple because it's only
creating DNS records.  It's something that you would do, depending on your cloud
service provider, or how you host your node and your domain.  So, there isn't
much that we have to provide on the library side.  The rest of it is just going
to be standard LN protocols for onion messages and BOLT12, so it's going to be
shipped in every LN implementation by default.

**Mike Schmidt**: You mentioned DNS over HTTPS, and that's something that was
new to me, and I'm personally a bit curious about who is providing those DNS
records over HTTPS; how does that work?

**Bastien Teinturier**: Right now, I think most people who provide standard DNS
resolvers, they also provide a way to fetch them over HTTPS.  So, the main
internet players all run some of those DNS over HTTPS providers.  And also,
anyone who has a DNS zone file just can do that.  So right now, we need to
choose.  I don't know exactly how we choose on the application side which DNS
providers we connect to.  That's something I haven't looked into a lot, but I've
just checked that there are a lot of them and that we can choose from a very
large list of existing providers.

**Mike Schmidt**: There was a third proposed design that you put forth.  It
sounds like you're leaning towards the DNS option, the two DNS options that you
outlined, but there was this notion of being able to provide some of the
information in an SSL certificate.  Can you talk a little bit about that and why
that is or isn't a good idea?

**Bastien Teinturier**: Yeah, exactly.  Initially, I wanted to find an
alternative that did not rely on either HTTP servers nor DNS, and that was
entirely self-contained within LN.  And my idea was to use the node
announcements.  When you are an LSP node and you want to advertise that you also
own a domain, you could just add information into your node announcement that
you propagate to the whole network to tell people, "This is my domain, this is
my certificate, and this is my certificate chain that goes all the way to this
certificate authority", so that people can know that this node ID is associated
to this domain.  But the issue with that is that it takes some space in node
announcements, and it's something that every node in the network has to store.
So, if we could avoid it, that would be better.  It's more bandwidth that is
shared across the whole network.  And also, it requires adding certificate
validation in basically every LN implementation to be able to verify those
fields, because you don't want anyone to be able to claim they own a domain, but
give you a wrong certificate, or certificate that chains to a certificate
authority that you do not trust.  And this is a lot of very annoying legacy
crypto.

Validating that thing has a lot of caveats because just on the encoding side,
the encoding of the certificate and certificate chains are not trivial.  It's
going to be pulling dependencies from all the old crypto that we'd like to avoid
if we can.  But I didn't see another way to do it entirely in LN.  So that's
why, since I was not satisfied with that option, I explored the DNS options, and
I find the DNS options much more satisfying, because even though they rely on an
external service, DNS, this is something that we know scales, and this is
something that there are many providers, way enough providers, that they
probably won't target you specifically.  And you can still query many of them to
make sure that if one of them gives you a wrong answer, then you get the right
answer from someone else.  And there's been a lot of work in the recent years
about DNA security.  So, I think this is why this is a good solution.

**Mike Schmidt**: Dave, do you have questions or comments?

**Dave Harding**: Sure.  I think just to point out for DNS over HTTP, I believe
Firefox is currently using that as the only method by default.  So, it is widely
used, it's out there for sure.  I guess another thing to point out here is this
is just for one particular use of offers.  It's just for when people want an
email style address to pay.  Offers work great without any of this
infrastructure in lots of other contexts.  So, if you have a café, or whatever,
and you want to collect payments to your LN node, you can just put a static
offers QR code on the table or on your receipt, or whatever, and people can just
pay that.  So, we only need this for one specific thing.  Offers already works
well without this infrastructure for lots of other things.

Yeah, I guess my only other comment was that I think it was great that Bastien
provided the option of SSL certificates in node announcements, but that just
seems so awful and ugly to me.  I think we kind of want to get away from
SSL-compatible cryptography if we can and stick with more pure things if we can
get away with it.  So, that's it for me.

**Bastien Teinturier**: Yeah, I fully agree with all that, and I think this is
spot on.  And in many cases, to be honest, my first reaction to LN address was,
we don't need that anymore once we have BOLT12, we can just share a QR code for
a BOLT12 invoice, and that will work in most cases.  It's just the LN address
still adds a bit of better UX for people who are more used to normal payment
apps, where you just even use your contact list on your phone, and it lets you
send messages to them and send money to them.  So, I think it brings a small UX
improvement.  But as you say, I don't think it's a crucial improvement.  Once we
have BOLT12, we can also do directly with BOLT12 offers.  So, yeah, BOLT12 is
going to be a great improvement on its own.

**Mike Schmidt**: T-bast, what are the downsides to this or concerns people have
brought up, or can you steel man the case against this, or is it just a net
positive?

**Bastien Teinturier**: I do believe it's a net positive.  I know that DNS
scares some people.  A lot of people say it's more complex, it's additional
complexity.  I don't think it is.  I think people who say that have not really
studied the proposal enough to see how simple it is from the provider side,
especially if you only support what I called option one, which is just create
once a DNS record linking to your node.  And this is trivial to me.  On the
application side, it seems trivial to me as well, because it's only a few calls
to DoH providers.  So, I'm having trouble following that argument, but I'm still
waiting.  Maybe someone can explain that in more details, and maybe they will
have a point.  But it seems to me that it is really simple to implement and
provides for the current LN address UX without some of its drawbacks.  So, I
think it's a net positive, but I'm happy to be wrong if someone explains why it
has drawbacks.

I'm waiting for feedback, especially on the mailing list if some people want to
really detail their objections to it.  But so far, I've only seen good feedback
on things that should be clearer in the spec, things that should be improved,
but there may be valid objections, and I'd be happy to discuss them.  So, don't
hesitate to reach out on the mailing list if that's the case, if you think
there's an objection to this scheme.

**Mike Schmidt**: Bastien, thank you for joining us and walking us through your
ideas here.  We do have an offers-related Eclair PR that we cover towards the
end of the newsletter.  So, if you're able to stay on, great.  If not, thank you
for your time and you're free to move on if you have to drop.

**Bastien Teinturier**: I should be able to stay on.  I still have one hour.

**Mike Schmidt**: Excellent.  Next section from the newsletter is our monthly
segment that highlights interesting updates to Bitcoin wallets, services, and
other software around Bitcoin.  We have eight this month.

_BitMask Wallet 0.6.3 released_

The first one is BitMask Wallet 0.6.3 being released.  We hadn't covered BitMask
previously, and it is a web-based and browser extension-based wallet that
supports Bitcoin and a couple different layer 2 protocols, including LN and RGB,
and it also has payjoin support.  I believe that this particular release allowed
RGB on mainnet, or at least some features of RGB on mainnet was the thrust of
this particular release.  Dave, back in my days as a web developer, maybe you
didn't want to be having large amounts of private or sensitive information in
the browser or browser extension.  That's really the only thing that comes to
mind here on this particular piece of software.  I think it's cool that they
have something that can support RGB and LN and payjoin, but I don't know, has
that changed?  Should we be having large sums of money in the browser, or is
this just more for sort of playing around?  What do you think?

**Dave Harding**: Absolutely not.  Absolutely do not put large amounts of
bitcoin or RGB assets or pull up your LN node on a browser.  Yeah, I'm from the
same old-school category as you on that, but it's great to see these
technologies integrated together and made easy for people to play around with.
Whatever your safe value is, I think it's great that we have such a variety of
options that you can use.  I have a mobile wallet on my phone.  I would
absolutely not trust that for a large amount of money, but I'm happy to trust it
for roughly the same amount of money that I carry in cash in my physical wallet.
I think that's just fine.  If somebody could steal my physical wallet, I'd get
robbed.  Somebody could steal money from my phone, I'd get robbed that way.
It's just a losable amount, I think that's just great.  You can play around with
this in a browser and use it on websites and stuff.

**Mike Schmidt**: Yeah, I think it'd be super convenient for maybe day-to-day LN
interactions to have that there.  So, very nice that BitMask integrates those
different pieces of LN technology.

_Opcode documentation website announced_

Next piece of software that we highlighted was Opcode documentation website
being announced, and we link to it in the newsletter here.  But for folks that
don't have that up, it's opcodeexplained.com, and there is an associated GitHub
where contributions are welcome.  And this particular effort provides
explanations of many of Bitcoin's opcodes.  Most of them have some sort of an
explanation, but there's actually, if you go to the website and click on the
opcode section, there's actually several that are still under construction and
looking for feedback.  Dave, I'm curious from your perspective, as someone
involved with documenting Bitcoin tech stuff over the years, what do you think
of something like this?

**Dave Harding**: I think it's great.  I clicked around a bunch earlier today
and one of the things I liked in particular was that for some of the more
important opcodes, they had examples.  And it's really, really useful for script
to see examples, especially if you're not someone who's experienced in
programming in a stack-based language.  So, it's great to click around and if
you are learning this, it's actually always a great chance to contribute, to go
there, go to this website, while you're learning Bitcoin Script, find something
that isn't well documented, figure it out yourself by reading the source code,
by googling, and then go and contribute and make it better.

_Athena Bitcoin adds Lightning support_

**Mike Schmidt**: Next software update was to Athena Bitcoin ATM providers, and
they've added LN support.  Specifically, the ATM software will be able to
receive LN payments in exchange for cash withdrawals.  And I think they have
something like 2,000 or more ATMs and I believe they're rolling this out in El
Salvador first.  And so, that's interesting to see that you could sans the KYC
process, just take your LN wallet and take out some cash.  Any thoughts, Dave?

**Dave Harding**: Just sounds pretty cool.  It's just great seeing LN integrated
into this stuff.

_Blixt v0.6.9 released_

**Mike Schmidt**: Blixt v0.6.9 released and they've added support for simple
taproot channels.  They also now default to bech32m receive addresses, and they
add additional support for zero-conf channels.  And as a reminder, I think we've
covered Blixt before, but it's a wallet that is an open-source LN wallet for
Android and it's backed by LND and Neutrino.  So, I guess it makes sense with
the LND support for simple taproot channels that they've rolled this out in
their Android wallet as well.  T-bast or Dave, any comments?  All right.

_Durabit whitepaper announced_

The next two items that we highlighted this month are both white papers and not
necessarily pieces of software, although there are some early prototypes for one
of them.  Robin, I may want your feedback on this one that wasn't one you
authored, but this Durabit whitepaper that was announced.  I'm not totally sure,
but I think it might have been announced by someone putting some text into an
ordinal or an inscription.  That whitepaper outlines a protocol for using
timelocked bitcoin transactions along with chaumian e-cash-style mints to
incentivize the seeding of large files, I think specifically for BitTorrent.
Robin, are you familiar with this proposal?  I'm kind of surprising you with it.

**Robin Linus**: Not that much; a bit.  I can contrast it to BitStream,
definitely.  I know Durabit is mostly a protocol to incentivize long-term
storage.  So, yeah, for example, for backups of your wallet or so, backing up
your scripts and stuff like that, in that use case you want to have very
reliable long-term storage, and I think Durabit aims for that.  In contrast,
BitStream does something very different.  It aims for short-term storage, and it
aims for scaling decentralized file hosting.  And a use case would be that, for
example, Edward Snowden posts on Nostr a high-resolution video, and now a
million people want to watch it, and that would be the perfect use case for
BitStream.  Like, nobody would care if in two years from now, that video is not
available anymore, which is very different than the use case that Durabit is
targeting, where it would be extremely catastrophic if in two years your files
would be gone.

_BitStream whitepaper announced_

**Mike Schmidt**: Maybe we can roll in a bit to BitStream.  So, for folks, Robin
is the author of the BitStream whitepaper, as well as the developer of an early
prototype that we linked to in the newsletter.  Robin, you mentioned a little
bit about the use case.  Do you want to get a bit into maybe a layer deeper of
how that might work?

**Robin Linus**: Sure.  BitStream is essentially an atomic swap for files or
like files for coins.  So, it is really atomic in the sense that the person who
provides the bandwidth, who sells the file, they only get the coins if they
actually serve the correct file, and the recipient only gets the correct file if
they actually pay the server.  So, this is what I mean by an atomic swap of
files against coins.  And the payment can be facilitated basically over every
way there is in Bitcoin.  We can do it with onchain transaction, like with an
onchain Hash Time Locked Contract (HTLC); we can also do it with an LN
transaction; we can do it with some e-cash transaction if they support HTLCs,
which Cashu and those services do.  And yeah, this atomic swap then enables
essentially everyone to share their access, storage and bandwidth capacities and
monetize them by serving decentralized multimedia services like Nostr, for
example.

I've already mentioned the ideal use case that you can picture would be that
Edward Snowden posts a high resolution video where he, I don't know, makes a
huge new amount of announcements about what the NSA does and stuff like that,
and then everybody is super curious and wants to watch it right now.  And this
idea of serving some large file to potentially millions of users pretty much
simultaneously is the ideal use case of the BitStream protocol.  And in general,
it's not totally new, or the idea behind it is not totally new.  There has
already been verifiable encryption, and people have already experimented with
ideas around verifiable encryption.  And verifiable encryption would essentially
allow you to do exactly what I just described, this atomic swap.

It works such that the server sends you an encrypted file, and the file is
encrypted in such a way that you can verify that if you buy the decryption key
for it, then you can decrypt the file, and the decrypted thing will actually be
exactly what you wanted.  That is what you use verifiable encryption for.  And
that works, and it is kind of practical, but it is kind of slow as well.  In
that use case of serving a file to millions of users, it would probably be too
heavyweight.  And yeah, that's why it's not really well suited for things like
web hosting, or for multimedia hosting.  And that's essentially, or this
observation is essentially the basis for the BitStream protocol, because the
BitStream protocol tries to do the same thing, which tries to solve the same
problem that verifiable encryption does, but it tries to solve it in a way more
efficient way.  And the main idea to do that is to use an optimistic protocol.

That works such that the encrypted thing will be just sent to the client, and
then the client buys the decryption key, and then they decrypt it.  And if the
file was incorrect, then they can punish the server.  So, they are not sure
before they bought the file that they get the correct file.  And there is no
guarantee that they get the correct file, but they are guaranteed that if the
server lies to them and sends them the incorrect file, then they can punish the
server.  So, the server is disincentivized to send the wrong file.  They are
incentivized to send the correct file.  And yeah, you can easily have a bond
contract which contains more money than the file costs, so there is absolutely
nothing to gain for the server in mind.  So, they are highly incentivized to
actually send the correct file.

The cool thing here is that we don't need any fancy cryptography.  We can use
very, very basic encryption, and we essentially just have to hash the file.  And
hashing the file is pretty quick in comparison to this verifiable encryption
thing.  And yeah, that leads to a system that is extremely lean and actually
enables the server to serve large files to lots of clients simultaneously.  And
yeah, the main parts, or the most complex part of it, is that bond contract,
which allows the clients to punish the server with a fraud proof.  And the fraud
proof is essentially just a merkle path, like the file is merklized, and each
leaf kind of contains a commitment to what it should be, to what the trunk
should decrypt to.  And if it doesn't decrypt to that commitment, then you can
easily prove that it doesn't commit to that commitment, and the bond contract
can check that.  And if the bond contract ever receives a valid fraud proof,
then the contract destroys the deposit of the server.

The main thing about that is to build that bond contract on Bitcoin, we would
need OP_CAT, because we have to verify merkle paths, and currently we cannot
verify merkle paths with the existing opcodes because we cannot concatenate byte
strings.  To verify a merkle path, you always have to hash together two nodes to
get the next node, and the resulting node again has to be hashed together with
another node, and that's what you need concatenation for.  That's why we need
OP_CAT to do it on Bitcoin.  However, on Liquid, for example, it is already
possible to implement the bond contract, and I have already implemented it
together with tiero, and yeah, the code is open source, you can see it on
GitHub.  And we have already done a couple of test transactions on the Liquid
testnet to see that it actually works.  And yeah, that's mostly it.

**Mike Schmidt**: So, in the example of the Snowden video, somehow there's some
identifier to that and video.  And I, as somebody who wants to watch that, can
somehow request the contents of that video and if someone tries to edit that
video and he's saying nice things about the NSA instead, I can sort of have a
proof that I didn't get the video that I requested based on some identifier.
And actually, not only do I know that, I also guess the server then loses money
for attempting to serve me something that I didn't request.  Am I getting that
right?

**Robin Linus**: Yeah, exactly.  I jumped over that too much, I guess.  In
general, in file sharing systems like BitTorrent or something, you usually use
the merkle root of the file as the file identifier.  And that's exactly the same
thing that BitStream is doing.  The merkle root of a file is its identifier,
such that Snowden, for example, he would just post a Nostr node containing that
hash, like the merkle root of his file, and then everybody who knows Snowden's
key could be certain that this is exactly the root of the file that Snowden
posted.  Then any server can trustlessly serve that file to any client, and that
client can verify that they got exactly the correct file.

**Mike Schmidt**: And this may be a level above the BitStream proposal, but how
does the discoverability work in that case?  You know, if a bunch of people want
to download the original, and they verify that it is the correct one and match
that as an identifier and they want to serve it up, if I want to do that and
serve that up for people, maybe for money, how would people even discover my
lowly little server hosting this video?

**Robin Linus**: So, there's file discoverability and there's server
discoverability.  The servers are discovered simply by watching the blockchain,
because the servers have to set up their bond contract, and they set the bond
contract up in the blockchain such that everybody can see that this is setting
up this bond contract.  And then clients just watch the blockchain, and then
they create a directory of valid servers, which is exactly the people who
created a valid bond contract.  And I guess you would have some kind of URL or
some IP or so that you would inscribe into the blockchain with your bond
contract.

**Mike Schmidt**: Okay, so then you know who the servers are, and then I guess
there would be some mechanism to scan those looking for, "Does anybody have this
particular piece of media?" based on the identifier.  Okay.  Dave, do you have
questions or comments on the Durabit whitepaper or the BitStream that Robin
outlined?

**Dave Harding**: Of course I do!  So, this probably won't be a surprise to
Robin, based on our previous discussions on Twitter, but I am kind of sceptical
about this style of bond contract.  So, the idea here is that a service provider
deposits some money into a UTXO, so it's confirmed onchain, and then if you can
prove that service provider committed fraud, you can take that money.
Practically, in a lot of these schemes, all you can do is send them the fees,
because if a miner discovers the fraud proof, they can also take the money and
the miner's just going to take the money from you.  The problem with these types
of schemes is that the person who has fraud committed against them, they still
lose their money, and there is no guarantee that the service provider will
actually have to pay for that loss of money.

In a very simple scheme, for example, the service provider could work with a
miner to execute a Finney attack.  That means they mine a block with a
transaction, spending the money back to themselves, before they commit the
fraud.  And so, there is no way for a user to use a fraud proof to enforce the
bond against the service provider.  So, I don't think it's a fatal flaw in this
protocol, especially for something that you can create arbitrarily small chunks
of the data, but it also points to me that there's probably going to be a
reputational element in a protocol like this.  It isn't a peer fair-exchange
protocol, or it won't in practice be a peer fair-exchange protocol.  It'll
probably have at least a small reputational element attached to it.  I don't
know, Robin, do you do you want to respond to any of that?

**Robin Linus**: Yeah, sure.  I would disagree here because, first of all, I
would design the contract such that you don't get your money back, you can only
burn the deposit of the server.  This prevents that attack that you said, where
essentially the server pretends to be a client and then they pretend to be a
defrauded client and then they slash the server, even though they are the server
themselves, and then they get the deposit of the server.  That's, I think, the
attack that you mentioned.  And yeah, that is mitigated simply by burning the
funds.  This way, if the server wants to slash themselves, they can just slash
their money, but they can always do that.  So, I think that is much more safe.

However, of course, it does not solve the other problem that you mentioned,
which is if a client is defrauded, then they lose their money.  That is true.
However, yeah, there can be a huge asymmetry here, because serving the files
will probably be not very expensive.  Even if it's a video or something, it will
not be a lot of money, it will be some small amount of money.  So, the deposit
can be a relatively large amount of money, it can be like 100 times more than
what you pay for the file.  And this way, there is a huge disincentive for the
server to try to defraud the client, because first of all, they will lose
anyway, they will lose their deposit because it is locked in the way that it
gets burned; and second, the deposit is just 100 times more valuable than the
money that they could steal from the client.

**Dave Harding**: That makes sense.  Yeah, that's very compelling.  And I guess
the other thing I noticed reading the paper was that there is no way to punish a
server who promises to provide you data, provides you a bunch of data that you
download, but doesn't provide the decryption key.  In that case, all that's
happened is the client has had their bandwidth wasted, and the server also
wasted their bandwidth at the same time, so it's probably not a major problem.
But that was it.  I like the proposal.  So, that's my comments on the BitStream
proposal, Mike.

**Robin Linus**: Yeah, that's true, clients control the server.  The main
concern of this design was to protect the server from clients so that clients
cannot steal bandwidth from the server.  But you're right.  Servers could, yeah,
they could waste their bandwidth to control clients, but no.

**Mike Schmidt**: Dave, did you have any commentary on the Durabit whitepaper?
We sort of just gave a high level;  I don't know if you have anything to add to
that.

**Dave Harding**: Sure, looking at that paper, I think this is a problem that
people have been trying to solve for a long time at Bitcoin.  I actually looked
up a paper that I liked from back in 2014.  The researcher, Andrew Miller, and
some other researcher posted a paper called Permacoin, that was a kind of
offered file storage as an alternative to Bitcoin's proof-of-work function.  And
that has lots of problems, I'm not pushing that, I just think that was a very
interesting paper that goes into this subject a bit more depth than this paper.
And so the challenge of this paper is, the ideas seem to be less ensuring that
the data was stored and more that it was distributed, and that's a really hard
problem to solve.

If I want to make sure that Mike is sharing copies of this podcast, how do I do
that?  How do I make sure that, you know, Robin can download a copy of this
podcast.  Mike can prove to me very easily, cryptographically, that he has a
podcast using hashes, but he can't prove to me that he gave a copy to Robin
without me knowing who Robin is in advance and having a key from Robin, Robin
having an identity.  And so you have this sort of problem.  And what the Durabit
does is it has this intermediary here.  So, there's a person who wants the data
to be shared, and then there's an entity who it pays to share that, to test
whether that file is being shared.  And I just, I think this is a really hard
problem, and I don't think this paper offers a particularly satisfactory
solution for that problem.  It just discusses the mechanics of paying.

So, that's my commentary on that, is that I think the paper could be enhanced if
it went into more detail about how to measure that the file was actually being
shared, because I think that's a really hard problem.  I don't think there's a
satisfactory solution for it.

_BitVM proof of concepts_

**Mike Schmidt**: Thanks for those insights, Dave, that's great.  The next piece
of software that we highlighted this month, there's actually two proof of
concepts that we're building on BitVM.  And BitVM is something that we've
covered previously.  I didn't write down in the newsletter, but if you do a
search for the Optech Podcast, we talk about it with Robin, who's here again.
Robin, I think you were the one that did the BLAKE3 hash function, and it sounds
like somebody else did SHA256 using the BitVM framework.  Can you maybe give a
quick overview of what is BitVM, and then we can talk about these hash functions
and what could potentially be done with these hash functions, other than just
proving that this concept works out?

**Robin Linus**: Yeah, BitVM is a way to enhance Bitcoin's scripting
capabilities.  It's also very similar to BitStream.  Actually, it's the
successor of BitStream.  I invented BitStream, and then later on I thought about
how to generalize it for general computation, and then essentially BitVM was the
result of it.  And yeah, it's also using an optimistic scheme that is also based
on fraud proofs.  And yeah, it essentially works such that there are two
parties, a prover and a verifier, and both of them, they do some computation and
they do it offchain.  And then they come to a particular result and they tell
each other the result, and if they agree, then everybody's happy and they can
settle their contracts bilaterally.  But if they disagree, then they can make
statements in a way that they are binding, such that the other party can
disprove them succinctly by just asking a couple more questions, similarly to
like how you disprove somebody who's lying.  When you know somebody is lying,
you just ask them more questions until they contradict themselves.  And
similarly to that, BitVM works.

It's piling a lot of interesting hacks on top of each other that in the end
enable, I would say, you can essentially verify any kinds of computation on
Bitcoin.  And what we are using it in particular for, the thing that my team and
I are working on, is to actually build a virtual machine that is very similar to
RISC-V, for example, and then you can run any kinds of computation on that
RISC-V machine.  You can just compile existing code to it, in particular you can
compile existing ZKP verifiers and stuff like that to it, and then you can run
any kinds of computation on that virtual machine.  And yeah, the main thing is
that this virtual machine is designed in such a way that you can easily make
statements about what the result of that machine was, and then you can use these
kinds of taproot circuits that I just talked about to disprove an incorrect
result of that machine.

In general, whenever you have huge amounts of data, then you're happy to have
merkle trees, and to verify merkle paths in Bitcoin Script, we need some kind of
way to concatenate byte strings.  And it's essentially the same problem that I
just mentioned for BitStream, it's really about verifying merkle paths.  Since
we cannot do that right now, we are building a BitVM circuit that allows us to
verify Merkle paths, because if we can verify merkle paths, we can use that as a
primitive to build that RISC-V-like VM.  And yeah, the most simple hash function
that we could find was BLAKE3, and so we implemented it in Bitcoin Script.

That took us a whole lot of interesting hacks because the primitives of BLAKE3
are essentially u32 addition, u32 rotations, and u32 XOR operations.  And
essentially none of these operations are available in Bitcoin natively.  We do
have 32-bit arithmetics, though these 32-bit arithmetics, they use that quirky
type that Bitcoin Script is using, which is not really u32, because it does
overflow, it overflows to more than 32 bits.  And it is a very quirky type that
is usually not used anywhere else in the world, except for in Bitcoin Script.
What we did essentially is that we used this quirky type and the existing
arithmetics to build on top our own data type, which we call a u32 type,
obviously, and then we implemented u32 edition, which actually overflows, and we
implemented u32 rotations, and also we implemented u32 Bitwise XOR.  To do that,
we implemented a lookup table for Bitwise XOR; there's a pretty cool hack how
you can emulate XOR with a lookup table and addition and subtraction in the end.
And yeah, this is the most efficient way that we could come up with to implement
XOR.  And yeah, this way we implemented our own u32 XOR thing.

All of these opcodes, they are themselves already quite complex.  Like all of
them, they have like 100 opcodes or up to 300 opcodes, I think, for XOR.  And it
would be kind of hard to assemble them into more high-level programs if we would
have to copy the entire 300 opcodes for every call.  So, what we did is that we
implemented a templating language on top of JavaScript, essentially, or we kind
of used JavaScript as a templating language, and used that to then define our
own opcodes.  So, we now have opcodes for u32 XOR and stuff like that, and then
behind the scenes when we compile everything, they get replaced by the native
opcodes that actually exist in Bitcoin Script.  And long story short, now we
have that high-level templating language, and that allows us to define our own
opcodes and then to compose our own opcodes.

Also, we have added a couple of syntactic sugar, for example, some mechanisms to
unroll loops.  Like, Bitcoin Script doesn't have loops, which is kind of
cumbersome, and often you want to do things a particular number of times; in
particular in BLAKE3, you have these rounds that are all the same, and you want
to repeat them a couple times.  So, we implemented into our templating language
a way to unroll loops and also to parameterize scripts.  So, we can write
scripts that have particular parameters, and then we can instantiate them with
different parameters.  And long story short, this all gives us nice high-level
primitives that allowed us to implement BLAKE3 in essentially one or two pages.
And yeah, this BLAKE3 function then, this allows us to verify merkle trees, or
merkle inclusion proofs, merkle paths.  And these merkle paths, then they allow
us to make statements about 4 GB of memory that our VM will have.  And this
allows us to have a VM that really has essentially as much memory as it will
need for any application.

**Mike Schmidt**: As this VM ecosystem starts to build itself out, do you see it
as such that once a few different primitives are in place, that folks can build
on top without having to muck around at the lower level; or, will folks that
want to build on BitVM have to be doing this kind of thing themselves in order
to implement their bespoke features?

**Robin Linus**: Absolutely.  That's the main goal of why we are building this
RISC-V-like VM.  We want to build a virtual machine that then is very similar
to, for example, the Ethereum VM or something, where you really have some nicely
designed high-level language and then you can compile all kinds of high-level
contracts down to that VM, and then you will not have to deal with Bitcoin
Script at all.  I think it's very cumbersome to deal with Bitcoin Script and to
deal with these big commitments, and with transaction logic and these taproot
trees and all that stuff, I think that's very cumbersome.  So, we should have
only one universal setup that everybody can use to then run their own programs
in the VM and only work on the high-level language, instead of these low-level
circuits.

**Mike Schmidt**: Dave, what do you think?

**Dave Harding**: It's still cool stuff.  I guess one thing to note is that with
an implementation of SHA256, one of the things you can do now is verify Bitcoin
merkle inclusion proofs.  So, you can prove that a transaction was included in a
particular block just by putting that block header on the stack and a merkle
inclusion proof on the stack, and then just running all these millions of
opcodes that have to be run to do that merkle inclusion proof.  There's been
proposals in the past for Bitcoin to add an opcode, something like
OP_MERKLEBRANCHVERIFY, the name of one of the proposals, that would allow you to
do this directly in Bitcoin script.  That's always encountered resistance, but
now you can do it.  So, you have lots of potential opportunities there for
creating contracts about things that involve Bitcoin transactions.

A very simple example would be, some people have proposed a transaction
confirmation insurance.  So, when I do a transaction, I want to know that it
will be confirmed by within 100 blocks, or my insurance provider will give me
some money.  And right now, I think if I understand everything correctly, that
would now be possible to do with the BitVM.  You just say the current block is
X, and then the insurance company that has to do a fraud proof just provides the
block headers of the next 100 blocks at most saying, "These are the next 100
blocks, and then here's a merkle tree showing the transaction was included
within those 100 blocks.  Now I don't have to pay you insurance".  So, it's
really cool that they have these functions, the BLAKE3 for doing efficient hash
and merkle trees in BitVM, and then SHA256 for actually interacting with the
history of the blockchain.

**Mike Schmidt**: Dave, that's a wild idea.  I mean, you're going to have miners
essentially ensuring that transactions will get in a certain block if you have a
certain contract with them.  I mean, that's pretty crazy.  I know there's a lot
of other things that folks are working on as well, or at least talking about on
Twitter.  Robin, what would your call to action for the audience be if they're
interested in either following along with the developments going on with BitVM,
or wanting to actively participate and build?

**Robin Linus**: Yeah, a good way is definitely to join the Telegram channel.
It's quite active and people are discussing it vividly there.  It's just
bitvm_chat.  And yeah, I guess that's just the best way to get started.  And
there are also all the people sharing their projects and their different
approaches, and I would say that's the best way to get started.

**Mike Schmidt**: Well, thanks, Robin, for joining us.  You're welcome to stay
on, but if you have things to do, you can drop.

**Robin Linus**: Thanks a lot for having me.

_Bitkit adds taproot send support_

**Mike Schmidt**: Our last piece of software this week was Bitkit, which added
support for taproot sending.  Bitkit is a mobile Bitcoin and Lightning wallet
built by the folks at Synonym.  And they also have, I believe, an LSP product
and some other open-source projects that they work on, like Holepunch, so good
to see additional taproot adoption there.  That wraps up our monthly segment on
Changes to clients and services software.  Next segment in the newsletter is
Releases and release candidates.

_LND v0.17.2-beta_

First one here is LND v0.17.2 beta.  This is a hotfix release to fix a
concurrency-related bug in the peer/server that could lead to, "A panic".  And I
had to kind of look this up, but in the Go stack, which LND builds on, "a panic"
is something that typically means something went unexpectedly wrong.  And so in
this particular bug, there are scenarios that can cause a race condition when
sending channel messages, and so this is a fix which addresses that particular
issue.  Dave you may have more to add.  Nope, thumbs up, all right.

_Bitcoin Core 26.0rc2_

Next release candidate here is Bitcoin Core 26.0rc2 which we've covered last
week.  I'll point listeners to two other podcasts that we've done recently,
where we go into detail on a couple of different topics.  In the Optech Recap
#274, Murch went into detail about what is included in this 26.0 release.  And
so, if you jump over to our podcast page, we have a transcription with him
walking through what the new features and changes are there.  And then in last
week's 277 Recap podcast, we went through the 26.0 Testing Guide with its
author, Max Edwards.  So, if you're interested in testing, sooner than later, I
know that a release candidate 3 is being worked on, so if you have a chance to
go through that Testing Guide and provide feedback, I'm sure the developers
would welcome that.  Dave, anything to add?  Oh, you knew it.  All right.

_Core Lightning 23.11rc3_

Last release, Core Lightning 23.11rc3.  Murch and I spoke a bit about some
interesting items that we found in this particular release in Optech Podcast
#276 Recap, so feel free to look back on that.  I don't have anything to add
with the v3 of this RC, but t-bast does.

**Bastien Teinturier**: Yeah, if you're running Core Lightning (CLN), I strongly
recommend you update, because this makes CLN compliant with the latest state of
the dual-funding specification.  And we noticed that our node is compliant with
the latest specified version of dual-funding, but there are a lot of CLN nodes
out there that still advertise for dual-funding feature bit, but with an earlier
version of CLN, and are first not spec-compliant, and this creates a lot of
issues when trying to open channels to them.  So, all those nodes who run that
experimental feature with an older version of CLN, I strongly recommend that you
update so that we can finally have dual-funding channels with our node.

_Core Lightning #6857_

**Mike Schmidt**: Awesome.  Thanks, t-bast.  Moving on to Notable code changes,
we have two.  First one is Core Lightning #6857, which updates the names of
several configuration options in the REST interface.  There is a
c-lightning-rest plugin for CLN that's part of the Ride-The-Lightning repository
that's been around for a while, and that plugin used configuration option names
that matched and thus conflicted with CLN's own configuration option names for
its CLNRest plugin.  So, this PR changes the names of those CLN config option
names to have a, "CLN prefix" so that this is something that was required for
applications to have enough time for migrating from the c-lightning-rest to
CLNRest plugin.  I feel like that was a mouthful.

_Eclair #2752_

Last PR, and last item from the newsletter this week, is Eclair #2752, and this
is a PR related to offers, and we have t-bast here who's hung on, and hopefully
we haven't hit our hour limit.  Hopefully you can walk us through this one,
t-bast?

**Bastien Teinturier**: Sure, so hopefully that is the latest spec change on the
offer specification.  So, in an offer, offers use something called blinded path,
which lets the recipient optionally hide their node ID from payers.  And this
means that in the offer, you have a path that starts at some node that is
identified by its node ID, then followed by potentially blinded hops.  Or maybe,
if you don't want to hide your node, you don't put any blinded hops in there.
But the first node that is identified and called the introduction node, if you
identify it using the node ID, that takes 33 bytes.  And the offer is something
that we try to make as compact as possible, because since you're going to tattoo
them on your chest, we want that to not hurt too much.

So, there was a proposal that instead of using a whole public key in here, which
uses 33 bytes, you can instead just point to a channel onchain, which means that
a channel is actually two nodes, and say which direction you are pointing to, to
identify which node in that channel is the introduction node.  So, that only
takes 9 bytes instead of 33, so it means it's 24 bytes less than you have to
tattoo on your chest, so it makes the offer more compact and better to read also
in using a phone's camera.

**Mike Schmidt**: Excellent, thanks Bastien.  Dave, did you have any follow-up
on that?

**Dave Harding**: I don't know, it feels like you're wasting 7 bits there
because you only need 8 bytes and 1 bit.  So, I'm just wondering what you're
going to put in those other 7 bits.

**Bastien Teinturier**: Future stuff!  No, it's because we've had so many issues
with byte alignment in the past that we are just so afraid of making things
non-byte-aligned anymore that we just took a whole byte for it.

**Mike Schmidt**: I don't see any requests for speaker access or comments on the
thread here, so I think we can wrap up.  Thanks to Robin for joining us and
Bastien and my co-host this week, Dave Harding.  If anybody is interested in
learning more about the Bitcoin technicals in a very well-articulated manner,
such that you've heard today, you might check out Dave's Mastering Bitcoin 3rd
Edition book that is available now.  And thank you all for listening.  Cheers.

**Bastien Teinturier**: Thank you.

{% include references.md %}