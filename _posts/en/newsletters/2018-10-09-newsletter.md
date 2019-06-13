---
title: 'Bitcoin Optech Newsletter #16: Scaling Bitcoin Special'
permalink: /en/newsletters/2018/10/09/
name: 2018-10-09-newsletter
slug: 2018-10-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter consists entirely of summaries of several notable
talks presented at the Scaling Bitcoin workshop last weekend, since
there was very little to report in our usual Action Items, News, and
Notable Code Changes sections. We hope to return to our usual format
next week.

## Workshop summary: Scaling Bitcoin V (Tokyo 2018)

The fifth Scaling Bitcoin conference was held Saturday and Sunday in
Tokyo, Japan.  In the sections below, we provide brief overviews to some
of the talks we think might be most interesting to this newsletter's
readers, but we also recommend watching the complete set of [videos][]
provided by the workshop organizers or reading the [transcripts][]
provided by Bryan Bishop.

For convenience, at the end of each summary we directly link to its
video and transcript (and paper, if available).  Talks are listed below
in the order they appeared in the workshop schedule.

**Warning:** the following summaries may contain errors due to many of
the talks describing subjects well beyond the expertise of the summary
author.

### Adjusting Bitcoin's block subsidy

*Research by Anthony (AJ) Towns*

This talk makes an intellectual inquiry into whether Bitcoin pays more
for security than it needs to---and what we could do if we decided it
does pay too much.  The speaker makes clear that he's interested in
considering the questions and providing possible answers but that he's
neither suggesting that there's a problem nor advocating for any
solution.

If the Bitcoin userbase did think it was overpaying for security, the
talk suggests options for reducing the amount of subsidy paid in the
short term as the amount of security increases---but still ensuring that
no more than 21 million bitcoins are paid overall in
subsidy---potentially allowing the subsidy to last much longer than currently expected.

Although the talk was not about a specific proposal, an example proposal
it evaluated was to reduce the subsidy by 20% every time the network's
proof of work security doubles (measured by block-creation difficulty).

*[video][vid subsidy], [transcript][tx subsidy]*

### Forward blocks: on-chain capacity increases without a hard fork

*Research by Mark Friedenbach*

One well-known method for soft forking an increase in the Bitcoin block
size is extension blocks---a data structure that's invisible to nodes
that haven't upgraded to the soft fork and so is not subject to their
historic limits on block size.  By itself, this is an undesirable method
for increasing block size because preventing old nodes from seeing the
transactions in the extension block also prevents them from being able
to enforce any other consensus rules on those transactions---such as
rules that prevent a malicious user from spending other users' bitcoins
or from creating more bitcoins than allowed by the 21 million bitcoin
subsidy schedule.

However, one doesn't need to increase block size to increase the amount
of data that can be added to the block chain per minute---it's also
possible to increase capacity by increasing the frequency of blocks
(reducing the average time between blocks).  A method for gaming
Bitcoin's difficulty adjustment algorithm---called a time-warp
attack---is well-known among experts and has been used successfully in
demonstration attacks against Bitcoin's testnet and real attacks against
altcoins.  (Note: although Bitcoin is technically vulnerable to this
attack, it'd be a slow attack that would give the userbase a significant
amount of time to respond.)  By itself, increasing block frequency is
also an undesirable method for increasing capacity because shorter block
intervals increase the effectiveness of miners with large amounts of
hashrate and so is likely to increase mining centralization.[^freq-pow-waste]

Perhaps disproving the saying that "two wrongs don't make a right," this
talk describes a novel way of combining extension blocks and the
time-warp attack to allow both upgraded nodes and old nodes to gain the
same capacity increase and see all the same transactions for validation
while simultaneously slightly reducing mining centralization risk.
Upgraded nodes would validate one or more extension blocks (called "forward blocks") that provide
additional block space with a centralization-reducing 15 minute average interval, but the upgraded nodes would
also restrict the time stamps in legacy blocks to ensure a permanent
(but limited) time warp attack increased the frequency of legacy blocks
enough to allow them to include the same transactions that previously
appeared in the forward blocks.

*[video][vid forward blocks], [transcript][tx forward blocks],
[paper][paper forward blocks]*

### Compact multi-signatures for smaller blockchains

*Research by Dan Boneh, Manu Drijvers, and Gregory Neven*

This talk describes an alternative to the Schnorr
signature scheme described in the [MuSig paper][] that makes use of [pairing-based cryptography][],
specifically an adaptation of the [Boneh-Lynn-Shacham (BLS) signature
scheme][bls sigs].  Although pairing-based schemes require an additional
fundamental security assumption beyond those made by both Bitcoin's
current ECDSA scheme and proposed Schnorr scheme, the authors present
evidence that their scheme would produce smaller signatures in general,
allow non-interactive signature aggregation,
and make it possible to prove which members of the set of signers
actually worked together to create a threshold signature (i.e.  k-of-m
signers, e.g. 2-of-3 multisig).

*[video][vid bls msig], [transcript][tx bls msig], [paper
(pre-print)][paper bls msig]*

### Accumulators: a scalable drop-in replacement for merkle trees

*Research by Benedikt Bünz, Benjamin Fisch, and Dan Boneh*

In Bitcoin and other cryptocurrencies, scalable commitments to sets of
information---such as transactions or UTXOs---are normally made using
merkle trees that allow proving an element is a member of the set by
generating a proof whose size and validation cost is roughly *log2(n)*
for a set of *n* elements.

This talk describes an alternative method based on RSA accumulators that
provides potential benefits: the size of a proof is constant no
matter how many elements are members of the set, and adding or removing
elements from an accumulator can be efficiently batched (e.g. one update
per block).

*[video][vid accumulators], [transcript][tx accumulators]*

### Multiparty ECDSA for scriptless Lightning Network payment channels

*Research by Conner Fromknecht*

Routable payment channels such as those used by Lightning Network
currently use multiple opcodes from the Script language that are
enforced by Bitcoin's consensus rules.  Previous work on [scriptless
scripts][scriptless scripts transcript] by Andrew Poelstra has
[suggested][ln scriptless scripts] that some or all of the opcodes
currently used could be replaced by Schnorr public keys and signatures
that would be created privately (offchain) between the participants in
the payment channel.  Consensus rules would still require that a
spending transaction have a valid signature that referenced a known
public key, but none of the other security-related information would
appear onchain, reducing data consumption and fees, improving privacy
and fungibility, and potentially improving security.

Bitcoin doesn't currently support Schnorr signatures and no
complete design for it has been proposed (although such a proposal may
not be far off), so this talk describes proof-of-concept results from a
partial implementation of payment channel scriptless scripts that's
compatible with Bitcoin's current ECDSA keys and signatures.
Some impressive savings are achieved in the size of scripts
and witness data---savings which increase the number of channels that
can be opened or closed in a block and which reduces the amount of
transaction fee paid by users of Lightning Network payment channels.

*[video][vid scriptless ecdsa], [transcript][tx scriptless ecdsa]*

## Discussion: the evolution of bitcoin script

A two-hour discussion group focused on this topic mentioned a large
variety of proposed changes to Bitcoin's Script language---far too many
to mention here even in summary.  However, a few changes were mentioned
as theoretically possible to accomplish in 2019 if the community is
willing to adopt them:

- **Schnorr signature scheme:** an opt-in feature providing smaller
  signatures in all cases, faster validation, much smaller public key
  and signature data for cooperative multisigs, and easier compatibility
  with scriptless scripts.  See Pieter Wuille's [proposed BIP][schnorr
  pre-bip].

- **SIGHASH_NOINPUT_UNSAFE:** the ability to create spends without
  explicitly referencing which output you want to spend.  Allows
  creating more efficient payment channels using the [Eltoo protocol][]
  that also makes it easy for each channel to support up to 150
  participants.  See [BIP118][].

- **OP_CHECKSIGFROMSTACK:** makes it possible to create covenants that
  restrict what outputs a particular coin can be spent to.  For example,
  you could put a mandatory timeout of one week on spends from your cold
  wallet.  During the timeout, you could only spend the coins back
  into your cold wallet.  But if you waited for the timeout to expire,
  you could spend the coins to any arbitrary address.  This means that
  if someone stole a copy of your cold wallet's private key, you could
  use this mechanism to prevent them from spending your bitcoins by
  returning them to your cold wallet during the timeout period.  (It
  was noted that some developers are opposed to enabling the simplest form of this opcode for
  fungibility reasons, although alternative approaches may be more
  acceptable.)

- **Fixing the time warp bug:** a set of miners controlling a majority of
  the hash rate can currently manipulate Bitcoin's difficulty adjustment
  algorithm to allow them to consistently create more than one block
  every ten minutes even without increasing overall hash rate.  There's
  at least one simple proposal to reduce the amount of manipulation
  possible without breaking older software or mining equipment.  See the
  recent [email thread][bitcoin-dev timewarp] on the Bitcoin-Dev mailing
  list.

- **Explicit fees:** currently fees in Bitcoin are implied by the difference
  between the value of the aggregated inputs and the aggregated outputs.
  However, the transaction could alternatively explicitly commit to the
  fee and allow one of the outputs to be set to the difference between
  the value of the aggregated inputs and the explicit fee plus all the
  other outputs.  This could be useful for rewarding Lightning Network
  watchtowers that send breach remedy transactions on behalf of offline
  users, or it could be useful for fee bumping group transactions.

However, one member of the discussion group suggested that
"the only people who have comfort with soft-forks are unlikely to
propose a soft-fork and produce software that would be adopted. People
are going to fight anything that adds anything, especially considering
the recent [CVE][CVE-2018-17144]. People are going to be for the next 6
months significantly more conservative. It's going to be another 6
months before people are even thinking about it. I don't think we're
going to get any new soft-forks in the next year."

*(no video), [transcript][tx script]*

## Special thanks

We thank Andrew Poelstra, Anthony Towns, Bryan Bishop, and Pieter Wuille
for providing suggestions or answering questions related to the content
of this newsletter.  Any remaining errors are entirely the fault of the
newsletter's author.

## Footnotes

[^freq-pow-waste]:
    When a miner creates a new block at the tip of the chain, he can
    begin working on the next block immediately---but every other miner
    is still working on an old block until they receive the new block,
    meaning their proof of work during that brief period of time is
    wasted (it neither increases network security nor provides the
    miners with financial compensation).  Miners with more hash rate
    produce more blocks on average, so they get the head start more
    often and less of their proof of work is wasted.

    For two perfectly fair miners half a world apart, the minimum practical network delay
    between them is about 0.2 seconds, meaning a small miner far away from most
    other miners is likely to only be productive for 599.8 of the average
    of 600.0 seconds (ten minutes) between blocks.  A 0.2/600.0 loss of
    efficiency (0.03%) is probably acceptable, but if the block frequency were
    increased, the loss of efficiency would increase also: at one block
    per minute, the loss of efficiency would be 0.33%; at one block per
    six seconds, 3.33%.

    The small miner could increase his efficiency by moving closer to
    other miners or even completely eliminate the efficiency loss by
    merging with them, but this is the mining centralization that it's
    essential to avoid in Bitcoin if we want to prevent miners from
    being able to easily censor which transactions are
    included in blocks.

{% include references.md %}

[videos]: https://tokyo2018.scalingbitcoin.org/#remote-participation
[transcripts]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/
[vid subsidy]: https://youtu.be/y8hJ0VTPE34?t=39
[tx subsidy]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/playing-with-fire-adjusting-bitcoin-block-subsidy/
[vid forward blocks]: https://youtu.be/y8hJ0VTPE34?t=3744
[tx forward blocks]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/forward-blocks/
[paper forward blocks]: http://freico.in/forward-blocks-scalingbitcoin-paper.pdf
[vid bls msig]: https://youtu.be/IMzLa9B1_3E?t=29
[tx bls msig]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/compact-multi-signatures-for-smaller-blockchains/
[paper bls msig]: https://eprint.iacr.org/2018/483.pdf
[vid accumulators]: https://youtu.be/IMzLa9B1_3E?t=3522
[tx accumulators]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/accumulators/
[vid scriptless ecdsa]: https://youtu.be/3mJURLD2XS8?t=3624
[tx scriptless ecdsa]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/scriptless-ecdsa/
[tx script]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/bitcoin-script/
[musig paper]: https://eprint.iacr.org/2018/068
[schnorr pre-bip]: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki
[pairing-based cryptography]: https://en.wikipedia.org/wiki/Pairing-based_cryptography
[bls sigs]: https://en.wikipedia.org/wiki/Boneh%E2%80%93Lynn%E2%80%93Shacham
[scriptless scripts transcript]: https://scalingbitcoin.org/transcript/stanford2017/using-the-chain-for-what-chains-are-good-for
[eltoo protocol]: https://blockstream.com/2018/04/30/eltoo-next-lightning.html
[bitcoin-dev timewarp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016316.html
[ln scriptless scripts]: https://lists.launchpad.net/mimblewimble/msg00086.html
