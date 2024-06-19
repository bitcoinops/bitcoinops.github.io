---
title: 'Bitcoin Optech Newsletter #307'
permalink: /en/newsletters/2024/06/14/
name: 2024-06-14-newsletter
slug: 2024-06-14-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces a draft BIP for a quantum-safe Bitcoin
address format and includes our regular sections with the summary of a
Bitcoin Core PR Review Club, announcements of new releases and release
candidates, and descriptions of notable changes to popular Bitcoin
infrastructure projects.

## News

- **Draft BIP for quantum-safe address format:** developer Hunter Beast
  [posted][beast post] to both Delving Bitcoin and the mailing list a
  ["rough draft" BIP][quantum draft] for assigning version 3 segwit
  addresses to a [quantum-resistant][topic quantum resistance] signature
  algorithm.  The draft BIP describes the problem and links to several
  potential algorithms along with their expected onchain size.  The
  choice of algorithms and the specific implementation details are
  left for future discussion, as are additional BIPs necessary to fully
  realize the vision of adding full quantum resistance to Bitcoin. {% assign timestamp="3:36" %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

[Don't wipe indexes again when continuing a prior reindex][review club
30132] is a PR by [TheCharlatan][gh thecharlatan] that can improve
startup time when a user restarts their node before an ongoing reindex
has completed.

Bitcoin Core implements five indexes. The UTXO set and the block index
are required, whereas the transaction index, [compact block
filter][topic compact block filters] index, and coinstats index are
optional. When running with `-reindex`, all indexes are wiped and
rebuilt. This process can take quite a while, and it is not guaranteed
to finish before the node is stopped for any reason.

Because the node needs an up-to-date UTXO set and block index,
the reindexing status is persisted on disk. When a reindex is started, a
flag is [set][reindex flag set], and it will only be unset when the
reindex is finished. This way, when the node starts, it can detect that
it should continue reindexing, even if the user didn’t provide the flag
as a startup option.

When restarting (without `-reindex`) after an unfinished reindex, the
required indexes are preserved and will continue to be rebuilt.
Before [Bitcoin Core #30132][], the optional indexes would be wiped a
second time. [Bitcoin Core #30132][] can make node startup more
efficient by avoiding the wiping of the optional indexes when not
necessary.

{% assign timestamp="23:28" %}

{% include functions/details-list.md
  q0="What is the behavior change introduced by this PR?"
  a0="Behaviour is changed in three ways. First, as per the goal of this
  PR, optional indexes are no longer wiped again when the node is
  restarted before reindexing is completed. This aligns the wiping
  behavior of optional indexes with that of required indexes. Second,
  when a user requests a reindex through the GUI, this request is no
  longer ignored, reversing a subtle bug introduced in [b47bd95][gh
  b47bd95]. Third, the log line \"Initializing databases...\\n\" is
  removed."
  a0link="https://bitcoincore.reviews/30132#l-19"

  q1="What are the two ways an optional index can process new blocks?"
  a1="When an optional index is initialized, it checks if its highest
  block is the same as the current chaintip. If it is not, it will first
  process all missing blocks with a background sync, through
  `BaseIndex::StartBackgroundSync()`. When the index catches up
  with the chaintip, it will process all further blocks through the
  validation interface using `ValidationSignals::BlockConnected`."
  a1link="https://bitcoincore.reviews/30132#l-52"

  q2="How does this PR affect the logic of optional indexes processing
  new blocks?"
  a2="Before this PR, wiping the optional indexes without wiping the
  chainstate means these indexes will be considered out-of-sync. As per
  the previous question, that means they will first perform a background
  sync before switching to the validation interface. With this PR, the
  optional indexes remain in sync with the chainstate, and as such no
  background sync is required. Note: background sync only starts after
  reindex has completed, whereas processing validation events happens in
  parallel."
  a2link="https://bitcoincore.reviews/30132#l-70"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 24.05][] is a release of the next major version of
  this popular LN node implementation.  It includes improvements that
  help it better work with a pruned full node (see [Newsletter
  #300][news300 cln prune]), allows the `check` RPC to work with plugins
  (see [Newsletter #302][news302 cln check]), stability improvements
  (such as those described in Newsletters [#303][news303 cln chainlag]
  and [#304][news304 cln feemultiplier]), allows more robust delivery of
  [offer][topic offers] invoices (see [Newsletter #304][news304 cln
  offers]), and a fix for a fee overpayment issue when the
  `ignore_fee_limits` configuration option is used (see [Newsletter
  #306][news306 cln overpay]). {% assign timestamp="30:45" %}

- [Bitcoin Core 27.1][] is a maintenance release of the predominant
  full node implementation.  It contains multiple bug fixes. {% assign timestamp="32:46" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #29496][] bumps `TX_MAX_STANDARD_VERSION` to 3, which makes
  Topologically Restricted Until Confirmation ([TRUC][topic v3 transaction
  relay]) transactions standard. If a transaction’s version is 3, it will be
  treated as a TRUC transaction as defined in the [BIP431][] specification. The
  `CURRENT_VERSION` remains 2, meaning the wallet will not create TRUC
  transactions yet. {% assign timestamp="34:48" %}

- [Bitcoin Core #28307][] fixes a bug that imposed the 520-byte P2SH maximum
  script size limit on SegWit redeem scripts for both P2SH-segwit and bech32.
  This fix enables the creation of multisig [output descriptors][topic
  descriptors] involving more than 15 keys (now allowing up to the `OP_CHECKMULTISIG` consensus limit of 20), including
  signing for these scripts, along with other post-segwit redeem scripts that
  exceed the P2SH limit. {% assign timestamp="38:58" %}

- [Bitcoin Core #30047][] refactors the model of the [bech32][topic bech32] encoding scheme
  `charlimit` from a constant of 90 to an `Enum`. This change allows for easy
  support of new address types that use the bech32 encoding scheme but don't
  have the same character limit as [BIP173][] was designed for. For example, to enable
  parsing [silent payment][topic silent payments] addresses, which require up to
  118 characters. {% assign timestamp="37:04" %}

- [Bitcoin Core #28979][] updates the documentation of the `sendall` RPC
  command (see [Newsletter #194][news194 sendall]) to mention that it spends unconfirmed
  change in addition to confirmed
  outputs. If unconfirmed outputs are spent, it will compensate for any
  _fee deficit_ (see [Newsletter #269][news269 deficit]). _This item was corrected after publication._[^correction-28979] {% assign timestamp="41:23" %}

- [Eclair #2854][] and [LDK #3083][] implement [BOLTs #1163][] to remove the
  requirement of a `channel_update` on an [onion message][topic onion messages]
  delivery failure. This requirement facilitated an attack where a relayer node
  that generated the delivery failure error status could identify the sender of
  the [HTLC][topic htlc] through the `channel_update` field, compromising the
  sender’s privacy. {% assign timestamp="43:12" %}

- [LND #8491][] adds a `cltv_expiry` flag on the `lncli` RPC commands
  `addinvoice` and `addholdinvoice` to allow users to set the
  `min_final_cltv_expiry_delta` (the [CLTV expiry delta][topic cltv expiry delta] for the last hop).
  No motivation for the change is described on the pull request, but it
  could be in response to LND recently raising its default from 9 blocks
  to 18 blocks to follow the [BOLT2][] specification (see [Newsletter
  #284][news284 lnd final delta]). {% assign timestamp="44:23" %}

- [LDK #3080][] refactors `MessagerRouter`’s `create_blinded_path` command into
  two methods: one for compact [blinded path][topic rv routing] creation, and
  one for normal blinded paths. This enables optionality depending on
  the caller's context.  Compact blinded paths use short channel
  identifiers (SCIDs) that reference a funding transaction (or a channel
  alias) and are typically 8 bytes; normal blinded paths reference an LN
  node by its 33-byte public key.  Compact paths may become stale if a
  channel is closed or [spliced][topic splicing], so they're best used
  for short-term QR codes or payment links where byte space is at a
  premium.  Normal paths are preferable for long-term uses, including
  [onion message][topic onion messages]-based [offers][topic offers]
  where the use of node identifiers may allow forwarding a message to a
  peer even if the node and the peer no longer share a channel (since
  onion messages don't require channels).
  `ChannelManager` is updated to use compact blinded paths for short-lived
  [offers][topic offers] and refunds, while reply paths are refactored to use
  normal (non-compact) blinded paths. {% assign timestamp="45:41" %}

- [BIPs #1551][] adds [BIP353][] with a specification for DNS Payment Instructions,
  a protocol to encode [BIP21][] URIs in DNS TXT records, for
  human readability and to provide the ability to query such resolutions
  privately. For example, `example@example.com` could resolve to a DNS address
  such as `example.user._bitcoin-payment.example.com`, which will return a
  DNSSEC-signed TXT record containing a BIP21 URI like
  `bitcoin:bc1qexampleaddress0123456`. See [Newsletter #290][news290
  bip353] for our previous description and [last week's newsletter][news306
  dns] for the merge of a related BLIP. {% assign timestamp="47:13" %}

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}

## Footnotes

[^correction-28979]:
    Our original published description of Bitcoin Core #28979 claimed
    `sendall` spending unconfirmed change was a behavior change.  We
    thank Gustavo Flores for his original correct description (the error
    being introduced by the newsletter's editor) and Mark "Murch"
    Erhardt for reporting the error.

{% include references.md %}
{% include linkers/issues.md v=2 issues="29496,28307,30047,28979,2854,3083,1163,8491,3080,3072,1551,30132" %}
[beast post]: https://delvingbitcoin.org/t/proposing-a-p2qrh-bip-towards-a-quantum-resistant-soft-fork/956
[quantum draft]: https://github.com/cryptoquick/bips/blob/p2qrh/bip-p2qrh.mediawiki
[core lightning 24.05]: https://github.com/ElementsProject/lightning/releases/tag/v24.05
[Bitcoin Core 27.1]: https://bitcoincore.org/bin/bitcoin-core-27.1/
[news306 cln overpay]: /en/newsletters/2024/06/07/#core-lightning-7252
[news304 cln feemultiplier]: /en/newsletters/2024/05/24/#core-lightning-7063
[news304 cln offers]: /en/newsletters/2024/05/24/#core-lightning-7304
[news303 cln chainlag]: /en/newsletters/2024/05/17/#core-lightning-7190
[news302 cln check]: /en/newsletters/2024/05/15/#core-lightning-7111
[news300 cln prune]: /en/newsletters/2024/05/01/#core-lightning-7240
[review club 30132]: https://bitcoincore.reviews/30132
[gh thecharlatan]: https://github.com/TheCharlatan
[gh b47bd95]: https://github.com/bitcoin/bitcoin/commit/b47bd959207e82555f07e028cc2246943d32d4c3
[reindex flag set]: https://github.com/bitcoin/bitcoin/blob/457e1846d2bf6ef9d54b9ba1a330ba8bbff13091/src/node/blockstorage.cpp#L58
[news198 sendall]: /en/newsletters/2022/04/06/#bitcoin-core-24118
[news290 bip353]: /en/newsletters/2024/02/21/#dns-based-human-readable-bitcoin-payment-instructions
[news194 sendall]: /en/newsletters/2022/04/06/#bitcoin-core-24118
[news269 deficit]: /en/newsletters/2023/09/20/#bitcoin-core-26152
[news284 lnd final delta]: /en/newsletters/2024/01/10/#lnd-8308
[news306 dns]: /en/newsletters/2024/06/07/#blips-32
