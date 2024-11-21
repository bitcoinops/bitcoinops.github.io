---
title: 'Bitcoin Optech Newsletter #330'
permalink: /en/newsletters/2024/11/22/
name: 2024-11-22-newsletter
slug: 2024-11-22-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a proposed change to the LN
specification to allow pluggable channel factories, links to a report
and a new website for examining transactions on the default signet
that use proposed soft forks, describes an update to the LNHANCE
multi-part soft fork proposal, and discusses a paper about covenants
based on grinding rather than consensus changes.  Also included are our
regular sections summarizing recent changes to services, client software,
and popular Bitcoin infrastructure software.

## News

- **Pluggable channel factories:** ZmnSCPxj [posted][zmnscpxj plug] to
  Delving Bitcoin a proposal to make a small set of changes to the
  [BOLT][bolts repo] specification to allow existing LN software to
  manage [LN-Penalty][topic ln-penalty] payment channels within a
  [channel factory][topic channel factories] using a software plugin.
  The specification changes would allow the factory manager (e.g. a
  Lighting service provider, LSP) to send messages to an LN node that
  would be passed through to a local factory plugin.  Many factory
  operations would be similar to [splicing][topic splicing] operations,
  allowing the plugin to reuse a significant amount of code.  LN-Penalty
  channel operations within a factory would be similar to [zero-conf
  channels][topic zero-conf channels], so they could also reuse existing
  code.

  ZmnSCPxj's design is focused on SuperScalar-style factories (see
  [Newsletter #327][news327 superscalar]) but would probably be
  compatible with other factory styles (and possibly other multiparty
  contract protocols).  Rene Pickhardt [replied][pickhardt plug] to ask
  about additional specification changes that could allow channels
  within factories to be [announced][topic channel announcements] but
  ZmnSCPxj [said][zmnscpxj plug2] he deliberately didn't consider those
  in his design in order to allow the specification change to be
  adopted as fast as possible.

- **Signet activity report:** Anthony Towns [posted][towns signet] to
  Delving Bitcoin a summary of activity on the default [signet][topic
  signet] related to proposed soft forks available through [Bitcoin
  Inquisition][bitcoin inquisition repo].  The post looks at
  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] usage, including tests
  of [LN-Symmetry][topic eltoo] and emulation of
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify].  It then looks
  at `OP_CHECKTEMPLATEVERIFY` usage directly, including what are likely
  several different [vault][topic vaults] constructions and a few data
  carrier transactions.  Finally, the post looks at
  [OP_CAT][topic op_cat] usage, including for a proof-of-work faucet (see
  [Newsletter #306][news306 powfaucet]), a possible vault or other
  [covenant][topic covenants], and verification of a [STARK][]
  zero-knowledge proof.

  Vojtěch Strnad [replied][strnad i.o] that he was inspired by Towns's
  post to create a website that lists
  "[every transaction][inquisition.observer] made on the Bitcoin signet
  that uses one of the deployed soft forks."

- **Update to LNHANCE proposal:** Moonsettler [posted][moonsettler
  paircommit delving] to Delving Bitcoin and [also][moonsettler
  paircommit list] the Bitcoin-Dev mailing list a proposal for a new
  opcode, `OP_PAIRCOMMIT`, to be added to the LNHANCE soft fork proposal
  that includes [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]
  and [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack].  The new
  opcode allows making a hash commitment to a pair of elements; this is
  similar to what could be achieved using the proposed [OP_CAT][topic
  op_cat] concatenation opcode or streaming-SHA opcodes such as those
  [available][streaming sha] in Elements-based [sidechains][topic
  sidechains] but is deliberately limited to avoid enabling recursive
  [covenants][topic covenants].

  Moonsettler also [discussed][moonsettler other lnhance] on the mailing
  list other small potential tweaks to the LNHANCE proposal.

- **Covenants based on grinding rather than consensus changes:** Ethan
  Heilman [posted][heilman collider] to the Bitcoin-Dev mailing list the
  summary of a [paper][hklp collider] he coauthored with Victor Kolobov,
  Avihu Levy, and Andrew Poelstra.  The paper describes how
  [covenants][topic covenants] can be created easily without consensus
  changes, although spending from those covenants would require
  non-standard transactions and millions (or billions) of dollars worth
  of specialized hardware and electricity.  Heilman notes that one
  application of the work is allowing users today to easily include a
  backup taproot spending path that can be securely used if [quantum
  resistance][topic quantum resistance] is suddenly needed and elliptic
  curve signature operations on Bitcoin are disabled.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #30666][] adds the `RecalculateBestHeader()` function to
  recalculate the best header by iterating over the block index, which is
  automatically triggered when the `invalidateblock` and `reconsiderblock` RPC
  commands are used, or when valid headers in the block index are later found to
  be invalid during full validation. This fixes an issue where the value was
  incorrectly set after these events. This PR also marks headers that extend
  from an invalid block as `BLOCK_FAILED_CHILD`, preventing them from being
  considered for `m_best_header`.

- [Bitcoin Core #30239][] makes [ephemeral dust][topic ephemeral anchors]
  outputs standard, allowing zero-fee transactions with a [dust][topic
  uneconomical outputs] output to appear in the mempool, provided they are
  simultaneously spent in a transaction [package][topic package relay]. This
  change improves the usability of advanced constructs such as connector
  outputs, keyed and unkeyed ([P2A][topic ephemeral anchors]) anchors, which can
  benefit the extension of protocols such as LN, [Ark][topic ark], [timeout
  trees][topic timeout trees], [BitVM2][topic acc], and others. This update
  builds on existing features such as 1P1C relays, [TRUC][topic v3 transaction
  relay] transactions, and [sibling eviction][topic kindred rbf] (see
  [Newsletter #328][news328 ephemeral]).

- [Core Lightning #7833][] enables the [offers][topic offers] protocol by
  default, removing its previous experimental status. This follows the merging
  of its PR into the BOLTs repository (see [Newsletter #323][news323 offers]).

- [Core Lightning #7799][] introduces the `xpay` plugin to send payments by
  constructing optimal [multipath payments][topic multipath payments], using the
  `askrene` plugin (see [Newsletter #316][news316 askrene]) and the
  `injectpaymentonion` RPC command. It supports paying both [BOLT11][] and
  [BOLT12][topic offers] invoices, setting retry durations and payment
  deadlines, adding routing data through layers, and making partial payments for
  multi-party contributions on a single invoice. This plugin is simpler and more
  sophisticated than the older ‘pay’ plugin, but doesn't have all of its
  features.

- [Core Lightning #7800][] adds a new `listaddresses` RPC command that returns a
  list of all bitcoin addresses that have been generated by the CLN node. This
  PR also sets [P2TR][topic taproot] as the default script type for [anchor output][topic anchor
  outputs] spends and for unilateral-close change addresses.

- [Core Lightning #7102][] extends the `generatehsm` command to run
  non-interactively with command line options. Previously, you could only
  generate a Hardware Security Module (HSM) secret through an interactive
  process at the terminal, so this change is particularly useful for automated
  installations.

- [Core Lightning #7604][] adds the `bkpr-editdescriptionbypaymentid` and
  `bkpr-editdescriptionbyoutpoint` RPC commands to the bookkeeping plugin, which
  update or set the description on events matching the payment id or the
  outpoint respectively.

- [Core Lightning #6980][] introduces a new `splice` command that takes either a
  JSON payload or a splice script that defines complex [splicing][topic
  splicing] and related actions, and combines all of these multi-channel
  operations into a single transaction. This PR also adds the `addpsbtinput` RPC
  command that allows users to add inputs directly to a [PSBT][topic psbt], and
  adds the `stfu_channels` and `abort_channels` RPC commands that allow users to
  pause channel activity or abort multiple channels to enable [channel
  commitment upgrades][topic channel commitment upgrades], which is critical
  when performing complex splice actions.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30666,30239,7833,7799,7800,7102,7604,6980,3283" %}
[zmnscpxj plug]: https://delvingbitcoin.org/t/pluggable-channel-factories/1252/
[news327 superscalar]: /en/newsletters/2024/11/01/#timeout-tree-channel-factories
[pickhardt plug]: https://delvingbitcoin.org/t/pluggable-channel-factories/1252/2
[zmnscpxj plug2]: https://delvingbitcoin.org/t/pluggable-channel-factories/1252/3
[towns signet]: https://delvingbitcoin.org/t/ctv-apo-cat-activity-on-signet/1257
[news306 powfaucet]: /en/newsletters/2024/06/07/#op-cat-script-to-validate-proof-of-work
[stark]: https://en.wikipedia.org/wiki/Non-interactive_zero-knowledge_proof
[moonsettler paircommit delving]: https://delvingbitcoin.org/t/op-paircommit-as-a-candidate-for-addition-to-lnhance/1216
[moonsettler paircommit list]: https://mailing-list.bitcoindevs.xyz/bitcoindev/xyv6XTAFIPmbG1yvB0l2N3c9sWAt6lDTG-xjIbogOZ-lc9RfsFeJ-JPuXuXKzVea8T9TztlCvSrxZOWXKCwogCy9tqa49l3LXjF5K2cLtP4=@protonmail.com/
[streaming sha]: https://github.com/ElementsProject/elements/blob/011feab4c45d6e23985dbd68294e6aeb5a7c0237/doc/tapscript_opcodes.md#new-opcodes-for-additional-functionality
[moonsettler other lnhance]: https://mailing-list.bitcoindevs.xyz/bitcoindev/ZzZziZOy4IrTNbNG@console/
[heilman collider]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAEM=y+W2jyFoJAq9XrE9whQ7EZG4HRST01TucWHJtBhQiRTSNQ@mail.gmail.com/
[hklp collider]: https://eprint.iacr.org/2024/1802
[strnad i.o]: https://delvingbitcoin.org/t/ctv-apo-cat-activity-on-signet/1257/4
[inquisition.observer]: https://inquisition.observer/
[news323 offers]: /en/newsletters/2024/10/04/#bolts-798
[news316 askrene]: /en/newsletters/2024/08/16/#core-lightning-7517
[news328 ephemeral]: /en/newsletters/2024/11/08/#bitcoin-core-pr-review-club
