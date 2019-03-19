---
title: 'Bitcoin Optech Newsletter #38'
permalink: /en/newsletters/2019/03/19/
name: 2019-03-19-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter gives an update on the planned removal of BIP61
reject messages from Bitcoin Core, links to further discussion about
SIGHASH_NOINPUT_UNSAFE, analyzes some new features in the Esplora block
chain explorer, provides information about an updated node ban list,
and links to videos of talks at the recent MIT Bitcoin Club Expo.  Also
provided are a new weekly section about adoption of bech32 sending
support and the normal list of notable changes in popular Bitcoin
infrastructure projects.

## Action items

- **Help test Bitcoin Core 0.18.0 RC2:** The second Release Candidate
  (RC) for the next major version of Bitcoin Core has been [released][0.18.0].
  Testing is still needed by organizations and experienced users who
  plan to run the new version of Bitcoin Core in production.  Use [this
  issue][Bitcoin Core #15555] for reporting feedback.

## News

- **BIP61 reject messages:** as summarized in [last week's
  newsletter][Newsletter #37], several developers complained about
  [BIP61][] reject messages being disabled by default in upcoming
  Bitcoin Core 0.18.0, especially since notice of this was only given
  shortly before that planned release.  Bitcoin Core developers
  [discussed][core dev irc] the issue and decided to re-enabled BIP61 by
  default for the 0.18.0 release but describe it as deprecated in the
  release notes.  They plan to disable it by default in 0.19.0 (expected
  around October 2019) and potentially remove it either then or at some
  later point.

- **Mailing list move:** as announced on each list, the
  [bitcoin-dev][bdev mv] and [lightning-dev][ldev mv] mailing lists will
  be moving to the [Groups.io][] discussion hosting
  service in the near future.  The lists will remain operable at their
  current addresses until the migration is complete, at which point
  subscribers should receive a notification.  If you don't want
  Groups.io to learn your subscriber information, you should unsubscribe
  from the lists immediately.  You do not need to create a groups.io
  account at this time.

- **More discussion about SIGHASH_NOINPUT_UNSAFE:** Anthony Towns
  started another [thread][noinput thread] about ensuring the proposed
  noinput sighash mode is hard to misuse in ways that could result in
  loss of funds.  Noinput can enable an alternative onchain enforcement
  layer for LN that's more suitable for channels with multiple
  participants, ultimately allowing a greater number of channels to be
  opened in the same amount of block space.  Towns describes a
  reasonably plausible worst-case scenario where failure to ensure
  noinput safety puts adoption of other valuable protocol features at
  risk.  To avoid that happening, he proposes refinements to earlier
  ideas about output tagging (see [Newsletter #34][]) and a new
  alternative that would require every transaction with a signature that
  uses noinput to also contain a signature that doesn't use noinput.
  This would prevent third-parties from executing replay attacks with
  noinput transactions, but it would mean that the most efficient use of
  taproot couldn't be used and so would result in
  moderately larger transaction sizes when noinput was being used.

- **Esplora updated:** Nadav Ivgi [announced][ivgi twitter] an update of
  this open source block chain explorer.  (See our coverage of its
  initial release in [Newsletter #25][].)  Unconfirmed transactions are
  now displayed with an estimate of how long it will take them to
  confirm given current network conditions, or an overpayment warning if
  they pay more than necessary to be confirmed quickly.  Perhaps more
  notably, the details view for both confirmed and unconfirmed
  transactions provides an analysis of the features and anti-features
  used or omitted from the transaction.  For example: use of segwit,
  address reuse, inconsistent output precision, matching an [unnecessary
  input heuristic][uih2], inconsistent input/output script types, and
  changeless transactions.

    After seeing the new changes, Ryan Havar raised concerns [on
    Reddit][havar reddit] about the possibly high rate of false positive
    privacy warnings, leading to him opening an [issue][havar github] on
    Esplora's GitHub about the problem.  Attempting to address
    these concerns, Ivgi started a [conversation][esplora convo] with
    several Bitcoin Core developers.  Privacy advocates may wish to
    review this conversation, which covered topics such as:

    - Gregory Maxwell and Pieter Wuille believe Bitcoin Core would
      occasionally match Unnecessary Input Heuristic #2 (UIH2) since
      the release of Bitcoin 0.1 in 2009, with increasing frequency in
      more recent releases, making this heuristic less useful than
      hypothesized for distinguishing between commercial services and
      end-user wallets.

    - Bitcoin Core's coin selection updates over the past two releases
      allow it to frequently produce transactions without change outputs.
      These transactions are more efficient and more privacy
      preserving than transactions with change, but Esplora currently
      displays them in red as privacy-leaking transactions because they also match the
      pattern of the user using a "max send" feature to send all their
      bitcoins from one wallet to another wallet or exchange.

    - Maxwell proposed that a useful addition to the privacy analysis would
      be identifying when a user controlled multiple UTXOs received to
      the same address but only sent a transaction spending a subset of
      those UTXOs.  This behavior makes it possible to connect later
      transactions spending those UTXOs to the earlier transaction,
      destroying privacy.

    Overall, it's great to see developers building tools that help
    people identify flaws in their software or their behavior, but it's
    also important to consider how users will interact with the tool.
    As Wuille said near the end of the conversation: "I am super happy
    that there is a decent explorer now for debugging stuff out there,
    but I'm concerned about making it sound like it's an actual
    production tool.  I know people will use explorers, and one that
    gives good information is better than one that confuses everything.
    But, really, we shouldn't encourage using [it].  If this privacy
    detection feature causes people to go look up all their transactions
    because of a gamification like feeling 'oooh let's see how my
    transaction did here?!', it's probably a net negative. [...] The
    most important thing to put on a block explorer is 'Warning: looking
    up your own addresses on a block explorer leaks your privacy to the
    site operator'."

- **Spy node ban list updated:** some IP addresses are performing
  various attacks that are likely aimed at monitoring transaction
  propagation so that they can attempt to determine which nodes
  originated which transactions.
  To help node operators refuse
  connections from those IP addresses, Gregory Maxwell maintains a
  ban list that can be imported into Bitcoin Core and compatible nodes.
  There is absolutely no need to use this centralized list---your fully
  decentralized node will attempt to connect to a diverse enough set of
  peers that it should establish at least one honest connection---but
  using this ban list may reduce the amount of traffic you waste on spy
  nodes and other bad actors.  The list comes in two formats, one for
  use on the command line with [bitcoin-cli][banlist cli] and one that
  can be pasted into the debug console of [Bitcoin Core GUI][banlist
  gui].  The blacklisted IP addresses are banned for one year and
  Bitcoin Core will remember the bans between restarts, so you only need
  to import the list once.  Note: some users have reported that the
  ban list may exceed the maximum buffer size for the GUI on some
  platforms, requiring pasting it in chunks of about 250 entries each in
  order to load the whole list.

- **MIT Bitcoin Club 2019 Expo videos available:** a series of talks
  from the exposition two weeks ago have been split into individual
  [videos][mit vids] and uploaded to YouTube.  We've heard that many of
  the talks were excellent, so consider browsing the playlist for topics
  that sound interesting to you.

## Bech32 sending support

*Week 1 of 24*

Bech32 native segwit addresses were first publicly [proposed][bech32
proposed] almost exactly two years ago, becoming the [BIP173][]
standard.  This was followed by the segwit soft fork's lock-in on 24
August 2017.  Yet, seventeen months after lock-in, some popular wallets
and services still don't support sending bitcoins to bech32 addresses.
Developers of other wallets and services are tired of waiting and want
to default to receiving payments to bech32 addresses so that they can
achieve additional fee savings and improved privacy.  Bitcoin Optech
would like to help this process along so, from now until the two-year
anniversary of segwit lock-in, each of our newsletters will include a
short section with resources to help get bech32 sending support fully
deployed.

Note, we are only directly advocating bech32 **sending** support.  This
allows the people you pay to use segwit but doesn't require you to
implement segwit yourself.  (If you want to use segwit yourself to save
fees or access its other benefits, that's great!  We just encourage you
to implement bech32 sending support first so that the people you pay can
begin taking advantage of it immediately while you upgrade the rest of
your code and infrastructure to fully support segwit.)  To that end,
this week's section focuses on showing exactly how small the differences
are between sending to a legacy address and sending to a bech32 address.

### Sending to a legacy address

For a P2PKH legacy address that you already support such as
1B6FkNg199ZbPJWG5zjEiDekrCc2P7MVyC, your base58check library will decode
that to a 20-byte commitment:

     6eafa604a503a0bb445ad1f6daa80f162b5605d6

This commitment is inserted into a scriptPubKey template:

<pre>OP_DUP OP_HASH160 OP_PUSH20 <b>6eafa604a503a0bb445ad1f6daa80f162b5605d6</b> OP_EQUALVERIFY OP_CHECKSIG</pre>

Converting the opcodes to hex, this looks like:

    76a9146eafa604a503a0bb445ad1f6daa80f162b5605d688ac

This is inserted into the scriptPubKey part of an output that also
includes the length of the script (25 bytes) and the amount being paid:

<pre>     amount                           scriptPubKey
|--------------|  |------------------------------------------------|
00e1f5050000000019<b>76a9146eafa604a503a0bb445ad1f6daa80f162b5605d688ac</b>
                |
    size: 0x19 -> 25 bytes</pre>

This output can then be added to the transaction, which is then signed
and broadcast.

### Sending to a bech32 address

For an equivalent bech32 P2WPKH address such as
bc1qd6h6vp99qwstk3z668md42q0zc44vpwkk824zh, you can use one of the
[reference libraries][bech32 ref libs] to decode the address to a pair
of values:

    0 6eafa604a503a0bb445ad1f6daa80f162b5605d6

These two values are also inserted into a scriptPubKey template.  The
first value is the witness script version byte that's used to add a
value to the stack using one of the opcodes from `OP_0` to `OP_16`.
The second is the commitment that's also pushed onto the stack:

<pre><b>OP_0</b> OP_PUSH20 <b>6eafa604a503a0bb445ad1f6daa80f162b5605d6</b></pre>

Converting the opcodes to hex, this looks like:

    00146eafa604a503a0bb445ad1f6daa80f162b5605d6

Then, just as before, this is inserted into the scriptPubKey part of an
output:

<pre>     amount                        scriptPubKey
|--------------|  |------------------------------------------|
00e1f5050000000016<b>00146eafa604a503a0bb445ad1f6daa80f162b5605d6</b>
                |
    size: 0x16 -> 22 bytes</pre>

The output is added to the transaction.  The transaction is then signed
and broadcast.

For bech32 P2WSH (the segwit equivalent of P2SH) or for future segwit
witness versions, you don't need to do anything special.  The witness
script version may be a different number, requiring you to use the
corresponding `OP_0` to `OP_16` opcode, and the commitment may be a
different length (from 2 to 40 bytes), but nothing else about the output
changes.  Because length variations are allowed, ensure your fee
estimation software considers the actual size of the scriptPubKey rather
than using a constant someone previously calculated based on P2PKH or
P2SH sizes.

What you see above is the entire change you need to make on
the backend of your software in order to enable sending to bech32
addresses.  For most platforms, it should be a very easy change.  See
[BIP173][] and the [reference implementations][bech32 ref libs] for a
set of test vectors you can use to ensure your implementation works
correctly.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].*

- [LND #2022][] allows the creation of "hold invoices".  These are standard
  LN invoices that are processed differently when payment is received.
  Instead of the receiver immediately returning the payment preimage
  in order to claim the paid funds, the receiver delays up until the maximum
  allowed by the payment timelock.  This allows the receiver to accept
  or reject the payment subsequent to knowing that the money is
  available.  For example, Alice could automatically generate hold
  invoices on her website but wait until a customer actually paid before
  searching her inventory for the requested item.  This would give her a
  chance to cancel the payment if she couldn't deliver.  Other example
  use cases are provided in the PR's main description.

- [LND #2618][] implements most of the code necessary for an initial
  version of watchtower client support that will allow an LND node to
  pair with a private watchtower and send it encrypted state backups.
  The watchtower can then monitor the block chain for attempted channel
  contract breaches and submit breach remedy (justice) transactions that
  prevent the honest party from losing funds.  See the notable code
  changes sections of our previous newsletters for coverage of the
  commits implementing the server-side watchtower changes:
  [#7][newsletter #7], [#19][newsletter #19], [#22][newsletter #22], and
  [#30][newsletter #30].

- [C-Lightning #2342][] adds a new `setchannelfee` RPC that allows the
  user to set the feerates for each of their channels individually.

{% include references.md %}
{% include linkers/issues.md issues="2022,2618,2342,15555" %}
[esplora convo]: http://www.erisian.com.au/bitcoin-core-dev/log-2019-03-08.html#l-53
[havar github]: https://github.com/Blockstream/esplora/issues/51
[mit vids]: https://www.youtube.com/user/MITBitcoinClub/videos
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[noinput thread]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016766.html
[ivgi twitter]: https://twitter.com/shesek/status/1103320174936109057
[uih2]: https://gist.github.com/AdamISZ/4551b947789d3216bacfcb7af25e029e#gistcomment-2796539
[havar reddit]: https://old.reddit.com/r/Bitcoin/comments/ay1b0e/new_update_for_blockstreaminfo_is_out_fee_privacy/ehy77cn/
[banlist cli]: https://people.xiph.org/~greg/banlist.cli.txt
[banlist gui]: https://people.xiph.org/~greg/banlist.gui.txt
[core dev irc]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2019/bitcoin-core-dev.2019-03-14-19.00.log.html#l-53
[bech32 proposed]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-March/013749.html
[bech32 ref libs]: https://github.com/sipa/bech32/tree/master/ref
[ldev mv]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-March/001915.html
[bdev mv]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016785.html
[groups.io]: https://groups.io/
