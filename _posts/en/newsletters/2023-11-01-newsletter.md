---
title: 'Bitcoin Optech Newsletter #275'
permalink: /en/newsletters/2023/11/01/
name: 2023-11-01-newsletter
slug: 2023-11-01-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter follows up on several recent discussions about
proposed changes to Bitcoin's scripting language.  Also included are our
regular sections announcing new releases and describing notable changes
to popular Bitcoin infrastructure software.

## News

- **Continued discussion about scripting changes:** there were several
  replies on the Bitcoin-Dev mailing list to discussions we've
  previously covered.

    - *Covenants research:* Anthony Towns [replied][towns cov] to a
      [post][russell cov] by Rusty Russell that we mentioned [last
      week][news274 cov].  Towns compares Russell's approach to other
      approaches specifically for [covenant][topic covenants]-based
      [vaults][topic vaults] and finds it unappealing.  In a further
      [reply][russell cov2], Russell notes that there are different designs
      for vaults and that vaults are fundamentally less optimal than
      other transaction types, implying that optimization isn't
      critical for vault users.  He argued that the [BIP345][] vault
      approach is more suitable for an address format than a set of
      opcodes, which we think means that BIP345 makes more sense as a
      template (like P2WPKH) that is designed for one function than it
      does as a set of opcodes that are designed for that one function
      but which will interact in possibly unanticipated ways with the
      rest of script.

      Towns also considers the use of Russell's approach for the purpose
      of generally enabling experimentation and finds it "more
      interesting [...] but still fairly crippled."  He reminds
      readers of his previous proposal to provide a Lisp-style
      alternative to Bitcoin Script (see [Newsletter #191][news191
      lisp]) and shows how it could bring increased flexibility and
      power to perform transaction introspection during witness
      evaluation.  He provides links to his test code and notes some toy
      examples he's written.  Russell replies, "I still think there's
      much room for improvement before a replacement.  It's hard to
      compare the hobbled [S]cript we have today with an alternative,
      since most interesting cases are impossible."

      Towns and Russell also briefly discuss
      [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack], specifically
      its ability to allow authenticated data from an oracle to be
      placed directly on an evaluation stack.

    - *OP_CAT proposal:* several people replied to Ethan Heilman's
      [post][heilman cat] announcing a proposed BIP for [OP_CAT][],
      which we also [mentioned][news274 cat] last week.

      After several replies mentioned concern about whether `OP_CAT`
      would be excessively restricted by the 520-byte limit on the size
      of stack elements, Peter Todd [described][todd 520] a way to raise the
      limit in a future soft fork without using any additional
      `OP_SUCCESSx` opcodes.  The downside is that all uses of `OP_CAT`
      before an increase would require including a small number of extra
      already-available opcodes in their scripts.

      In a [post][o'beirne vault] made before Anthony Towns's similar
      reply to Russell's covenant research, James O'Beirne notes the
      significant limitations of using `OP_CAT` to implement vaults.  He
      specifically notes several features that the `OP_CAT` versions
      lack compared to BIP345-style vaults.

{% assign timestamp="0:40" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LDK 0.0.118][] is the latest release of this library for building
  LN-enabled applications.  It includes partial experimental support for
  the [offers][topic offers] protocol in addition to other new features
  and bug fixes. {% assign timestamp="14:57" %}

- [Rust Bitcoin 0.31.1][] is the latest release of this library for
  working with Bitcoin data.  See its [release notes][rb rn] for a list
  of new features and bug fixes. {% assign timestamp="17:35" %}

_Note:_ Bitcoin Core 26.0rc1, mentioned in our last newsletter, is
tagged but binaries have not been uploaded due to a change by Apple that
prevented the creation of reproducible binaries for macOS.  Bitcoin Core
developers are working on a mitigation for a second release candidate.

## Notable code and documentation changes

*Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #28685][] fixes a bug in the calculation of the hash
  of a UTXO set, mentioned in a [previous newsletter][news274 hash
  bug]. It includes a breaking change to the `gettxoutsetinfo` RPC,
  replacing the previous `hash_serialized_2` value with
  `hash_serialized_3`, containing the corrected hash. {% assign timestamp="21:24" %}

- [Bitcoin Core #28651][] allows [miniscript][topic miniscript] to more
  accurately estimate the maximum number of bytes that will need to be
  included in the witness structure in order to spend a [taproot][topic
  taproot] output.  The improved accuracy will help prevent Bitcoin
  Core's wallet from overpaying fees. {% assign timestamp="22:34" %}

- [Bitcoin Core #28565][] builds on [#27511][Bitcoin Core #27511] to add a
  `getaddrmaninfo` RPC that exposes counts of peer addresses that are either "new"
  or "tried", segmented by network (IPv4, IPv6, Tor, I2P, CJDNS). See
  [Newsletter #237][news237 pr review] and [Podcast #237][pod237 pr review] for
  the motivation behind this segmentation. {% assign timestamp="24:57" %}

- [LND #7828][] begins requiring that peers respond to its LN protocol `ping`
  messages within a reasonable amount of time or they will be
  disconnected.  This helps ensure the connections remain active
  (reducing the chance that a dead connection will stall a payment and
  trigger an unwanted channel force closure).  There are many additional
  benefits of LN pings and pongs: they may help disguise network
  traffic, making it harder for a network observer to track payments (as
  payments, pings, and pongs are all encrypted); they trigger more
  frequent rotations of encryption keys as described in [BOLT1][]; and
  LND in particular uses `pong` messages to help prevent [eclipse
  attacks][topic eclipse attacks] (see [Newsletter #164][news164 pong]). {% assign timestamp="31:01" %}

- [LDK #2660][] gives callers more flexibility over what feerates they
  can choose for onchain transactions, including settings for paying the
  absolute minimum, a low rate that may take over a day to confirm, a
  normal priority, and a high priority. {% assign timestamp="33:14" %}

- [BOLTs #1086][] specifies that nodes should reject (refund) an HTLC
  and return an `expiry_too_far` error if the instructions for creating
  a forwarded [HTLC][topic htlc] request that the local node wait more
  than 2,016 blocks before being able to claim a refund.  Lowering this
  setting reduces the worst-case loss of income to a node from any
  particular [channel jamming attack][topic channel jamming attacks] or
  long-held [hold invoice][topic hold invoices].  Raising this setting
  allows payments to be forwarded across more channels for the same
  maximum HTLC delta setting (or the same number of hops for a higher
  maximum HTLC delta setting, which can improve resistance to certain
  attacks, such as the replacement cycling attack described in [last
  week's newsletter][news274 cycling]). {% assign timestamp="35:02" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="28685,28651,28565,7828,2660,1086,27511" %}
[news164 pong]: /en/newsletters/2021/09/01/#lnd-5621
[towns cov]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022099.html
[russell cov]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022031.html
[news274 cov]: /en/newsletters/2023/10/25/#research-into-generic-covenants-with-minimal-script-language-changes
[russell cov2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022103.html
[news191 lisp]: /en/newsletters/2022/03/16/#using-chia-lisp
[heilman cat]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022049.html
[news274 cat]: /en/newsletters/2023/10/25/#proposed-bip-for-op-cat
[todd 520]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022094.html
[o'beirne vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-October/022092.html
[Bitcoin Core 26.0rc1]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[bitcoin core developer wiki]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki
[bitcoin core pr review club]: https://bitcoincore.reviews/#upcoming-meetings
[news274 cycling]: /en/newsletters/2023/10/25/#replacement-cycling-vulnerability-against-htlcs
[ldk 0.0.118]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.118
[rust bitcoin 0.31.1]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/bitcoin-0.31.0
[rb rn]: https://github.com/rust-bitcoin/rust-bitcoin/blob/master/bitcoin/CHANGELOG.md#0311---2023-10-18
[news274 hash bug]: /en/newsletters/2023/10/25/#bitcoin-utxo-set-summary-hash-replacement
[news237 pr review]: /en/newsletters/2023/02/08/#bitcoin-core-pr-review-club
[pod237 pr review]: /en/podcast/2023/02/09/#bitcoin-core-pr-review-club-transcript
