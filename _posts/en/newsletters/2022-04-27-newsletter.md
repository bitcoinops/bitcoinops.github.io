---
title: 'Bitcoin Optech Newsletter #197'
permalink: /en/newsletters/2022/04/27/
name: 2022-04-27-newsletter
slug: 2022-04-27-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes discussion about activating
`OP_CHECKTEMPLATEVERIFY` and includes our regular sections highlighting
top questions and answers on the Bitcoin Stack Exchange, new software
releases and release candidates, and recent changes to popular Bitcoin
infrastructure software.

## News

- **Discussion about activating CTV:** Jeremy Rubin [posted][rubin
  ctv-st] to the Bitcoin-Dev mailing list his plan to release software
  that will allow miners to begin signaling whether they intend to
  enforce the [BIP119][] rules for the proposed
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) opcode.
  If 90% of blocks signal positively during any of the next several
  2,016-block (two-week) retarget periods, anyone using Rubin's software
  will themselves begin enforcing CTV's rules starting around early
  November.

  Rubin described in detail multiple reasons for believing Bitcoin users
  may wish to activate CTV now, such as:

  - *Consistency:* CTV has a stable specification and implementation

  - *Popularity:* a number of people and organizations who are well
    known to the Bitcoin community support CTV

  - *Viability:* there do not appear to be any objections claiming that
    CTV violates any highly desired properties of Bitcoin

  - *Desirability:* CTV provides features users want, such as
    [covenant][topic covenants]-based [vaults][topic vaults]

  Over a dozen people replied on the mailing list, either directly to
  Rubin's email or in other threads.  We're unable to summarize all the
  noteworthy replies, but some of the comments we found particularly
  interesting included:

  - Anthony Towns [analyzed][towns ctv signet] transactions on the CTV
    [signet][topic signet].  Almost all looked like they may have been
    constructed with the same software ([Sapio][]), possibly indicating
    a lack of public exploration of CTV.  He further noted that changing
    the consensus rules to add a new feature creates risks for all
    Bitcoin users---even for people who don't plan to use the new
    feature---so it's important to provide the non-adopters with public
    evidence that the feature will be "valuable enough to others [to
    justify] the risk".  Subsequent to this post, [additional
    experimentation][fiatjaf vault] was performed on the CTV signet.

  - Matt Corallo also [argued][corallo ctv cost] that changing consensus
    creates significant costs for everyone, so we should only attempt
    soft forks when we're sure a proposal provides the maximum value
    available from a change.  In the case of covenants, Corallo wants to
    see "the most flexible and useful and hopefully private" design.  He
    [later said][corallo not clear], "from what I have seen it's not
    been clear that CTV is really a good option".

  - Russell O'Connor [noted][oconnor wizards] on #bitcoin-wizards IRC
    that one of the proposed ways of using CTV could not be communicated
    in an existing Bitcoin address format such as base58check,
    [bech32][topic bech32], or bech32m.  That method of using CTV via
    *bare script* (a script that appears directly in a scriptPubKey)
    would require wallet developers only use bare CTV with their own
    internal transactions or write special tools to communicate the
    information usually contained in an address.  Alternatively, wallets
    wanting to use CTV for some applications (such as [vaults][topic
    vaults]) could receive payments to a P2TR address which committed to
    later using bare CTV.

    O'Connor's discussion about the address limitation was
    [mentioned][towns bare] on the list by Towns.  O'Connor
    [replied][oconnor bare] with additional details and also noted that,
    if support for bare CTV wasn't part of the BIP119 specification of
    CTV, he'd advocate for a different design that would be simpler and
    more composable (easier to combine with other opcodes to produce
    useful scripts)---although, beyond that, he'd prefer the more
    general `OP_TXHASH` design (see [Newsletter #185][news185 txhash]).
    Rubin [replied][rubin bare] with several counterpoints.

  - David Harding [relayed][harding transitory] a concern that CTV might
    not receive much long-term use, either because uses for it wouldn't
    manifest or because other covenant constructions would better serve
    popular uses.  This would leave future consensus code developers
    with the perpetual burden of maintaining CTV code and analyzing its
    potential interactions with later proposed consensus changes.
    Harding suggested temporarily adding CTV to Bitcoin for five years,
    gathering data during that time about how people used it, and then
    automatically disabling it unless Bitcoin users five years from now
    decided it was worth keeping.  No respondents were in favor of this
    approach, with most of them arguing either that the costs of this
    approach were too high or the benefits too low.  It was also noted
    that anyone in the future who wanted to fully validate the blocks
    created while CTV was active would still need the CTV validation
    code, so the CTV code might need to be maintained in perpetuity even
    if the opcode was disabled after five years.

  - Antoine "Darosior" Poinsot [requested][darosior apo] activating a
    slightly modified version of [BIP118][] `SIGHASH_ANYPREVOUT`
    ([APO][topic sighash_anyprevout]) instead of CTV, or at least prior
    to CTV activation.  The modification to APO would allow it to
    emulate the capabilities of CTV, although at a higher cost for some
    applications.  Activating APO would also make it available for its
    originally envisioned use of enabling the proposed [Eltoo][topic
    eltoo] layer for LN, allowing for more efficient and arguably safer
    LN channel state updates.

  - James O'Beirne [suggested][obeirne benchmark] that his
    CTV-based [simple vault][] design could be used as a benchmark for evaluating
    different covenant designs because of its simplicity and its
    ability, in his estimation, to significantly enhance the security of
    many Bitcoin users if it was usable in production.  Darosior was the
    first to accept the challenge, [porting][darosior vault] the simple
    vault code from CTV to an implementation of `SIGHASH_ANYPREVOUT`.

  Discussion remained very active on the mailing list at the time this
  summary was being written.  Several interesting conversations about
  CTV and covenant technology also appeared on Twitter, IRC, Telegram
  chats, and elsewhere.  We encourage participants in those
  conversations to share any important insights with the Bitcoin-Dev
  mailing list.

  Subsequent to the discussions summarized above, Jeremy Rubin
  [announced][rubin path forward] that he will not be immediately
  releasing binary builds of the software for allowing activation of
  CTV.  He will instead be evaluating the feedback received and working
  with other CTV supporters to possibly propose a revised activation
  plan.  Optech will provide updates on the subject in future
  newsletters.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [How was the generator point G chosen in the secp256k1 curve?]({{bse}}113116)
  Pieter Wuille notes that while the exact rationale behind choosing constant [generator
  point G][se 29904] is not publicly known, an unusual property may hint of its construction.

- [What is the maximum, realistic P2P message payload size?]({{bse}}113059)
  0xb10c asks if there is a valid [P2P message][p2p messages] of `MAX_SIZE` (32MB). Pieter
  Wuille explains that `MAX_PROTOCOL_MESSAGE_LENGTH` ([4MB][bitcoin protocol
  4mb], increased from [2MB][Bitcoin Core #5843] as
  [part of segwit][Bitcoin Core #8149]) is what actually restricts the size of incoming messages to
  prevent denial-of-service attacks.

- [Is there evidence for lack of stale blocks?]({{bse}}113413)
  Lightlike references a historical chart of block propagation times from the
  [KIT statistics][] website and points out [compact block relay][topic compact
  block relay] ([BIP152][]), implemented initially in [#8068][Bitcoin Core
  #8068], as a contributor to decreased [stale block][se 5866] frequency over time.

  {:.center}
  ![Block Propagation Delay History chart](/img/posts/2022-04-block-propagation-delay.png)

- [Does a coinbase transaction's input field have a VOUT field?]({{bse}}113392)
  Pieter Wuille outlines the requirements for a coinbase transaction's input: the
  prevout hash must be
  `0000000000000000000000000000000000000000000000000000000000000000`, the prevout
  index must be `ffffffff`, it must have a 2-100 byte `scriptSig` length,
  and since [BIP34][] the `scriptSig` must also start with the block height.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 23.0][] is the next major version of this predominant
  full node software.  The [release notes][bcc23 rn] list multiple
  improvements, including [descriptor][topic descriptors] wallets by
  default for new wallets and descriptor wallets now easily support
  receiving to [bech32m][topic bech32] addresses using [taproot][topic
  taproot].

- [Core Lightning 0.11.0][] is a release of the next major version of
  this popular LN node software.  Among other features and bug fixes,
  the new version supports multiple active channels to the same peer and
  paying [stateless invoices][topic stateless invoices].

- [Rust-Bitcoin 0.28][] is the latest release of this Bitcoin library.
  The most significant change is adding support for taproot and
  improving related APIs, such as those for [PSBTs][topic psbt].  Other
  improvements and bug fixes are described in their [release notes][rb28
  rn].

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [LND #5157][] adds an `--addpeer` startup option which opens a peer
  connection with the provided node.

- [LND #6414][] begins advertising support for keysend [spontaneous
  payments][topic spontaneous payments] when enabled.  LND has supported
  keysend since 2019 but it was initially deployed with no way for nodes
  to advertise they supported it.  Implementations of keysend in other
  LN node software announced support in their node advertisements and
  this merged PR for LND replicates that.

{% include references.md %}
{% include linkers/issues.md v=2 issues="5157,6414,5843,8149,8068" %}
[bitcoin core 23.0]: https://bitcoincore.org/bin/bitcoin-core-23.0/
[bcc23 rn]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-23.0.md
[core lightning 0.11.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.0.1
[rust-bitcoin 0.28]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/0.28.0
[rb28 rn]: https://github.com/rust-bitcoin/rust-bitcoin/blob/master/CHANGELOG.md#028---2022-04-20-the-taproot-release
[rubin ctv-st]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020233.html
[towns ctv signet]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020234.html
[sapio]: https://learn.sapio-lang.org/
[corallo ctv cost]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020263.html
[corallo not clear]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020289.html
[oconnor wizards]: https://gnusha.org/bitcoin-wizards/2022-04-19.log
[towns bare]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020245.html
[oconnor bare]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020256.html
[rubin bare]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020260.html
[harding transitory]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020242.html
[darosior apo]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020276.html
[obeirne benchmark]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020280.html
[simple vault]: https://github.com/jamesob/simple-ctv-vault
[news185 txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[fiatjaf vault]: https://twitter.com/fiatjaf/status/1517836181240782850
[rubin path forward]: https://twitter.com/JeremyRubin/status/1518477022439247872
[darosior vault]: https://twitter.com/darosior/status/1518961471702642689
[se 29904]: https://bitcoin.stackexchange.com/questions/29904/
[p2p messages]: https://developer.bitcoin.org/reference/p2p_networking.html#data-messages
[bitcoin protocol 4mb]: https://github.com/bitcoin/bitcoin/commit/2b1f6f9ccf36f1e0a2c9d99154e1642f796d7c2b
[KIT statistics]: https://www.dsn.kastel.kit.edu/bitcoin/index.html
[se 5866]: https://bitcoin.stackexchange.com/a/5866/87121
