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
  realize the vision of adding full quantum resistance to Bitcoin.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

FIXME:stickies-v

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/30000#l-11FIXME"
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
  #306][news306 cln overpay]).

- [Bitcoin Core 27.1][] is a maintenance release of the predominant
  full node implementation.  It contains multiple bug fixes.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

FIXME:Gustavojfe

- [Bitcoin Core #29496][] policy: bump TX_MAX_STANDARD_VERSION to 3

- [Bitcoin Core #28307][] rpc, wallet: fix incorrect segwit redeem script size limit

- [Bitcoin Core #30047][] refactor: Model the bech32 charlimit as an Enum ; mainly just looking for a quick mention that this is being done for silent payments -harding

- [Bitcoin Core #28979][] wallet, rpc: document and update `sendall` behavior around unconfirmed inputs

- [Eclair #2854][] and [LDK #3083][] both related to [BOLTs #1163][]

- [LND #8491][] invoice_cltv_expiry

- [LDK #3080][] Optional compact blinded path creation

- [LDK #3072][] Reintroduce addresses to NodeAnnouncementInfo. ; this
  might not be notable - fell free to delete if your research indicates
  it's just something minor -harding

- [BIPs #1551][] Add BIP 353: DNS Payment Instructions

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29496,28307,30047,28979,2854,3083,1163,8491,3080,3072,1551" %}
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
