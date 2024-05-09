---
title: 'Bitcoin Optech Newsletter #296'
permalink: /en/newsletters/2024/04/03/
name: 2024-04-03-newsletter
slug: 2024-04-03-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes discussion about a new push for a
consensus cleanup soft fork and announces a plan to choose additional
BIP editors by the end of the week.  Also included are our regular
sections announcing new releases and describing changes to popular
Bitcoin infrastructure software.

## News

- **Revisiting consensus cleanup:** Antoine Poinsot [posted][poinsot
  cleanup] to Delving Bitcoin about revisiting Matt Corallo's [consensus
  cleanup][topic consensus cleanup] proposal from 2019 (see [Newsletter
  #36][news36 cleanup]).  He starts by attempting to quantify the worst
  case of several problems the proposal could fix, including: the
  ability to create a block that can take more than 3 minutes to verify
  on a modern laptop and 90 minutes to verify on a Raspberry Pi 4; the
  ability for miners to steal subsidy and make LN insecure using the
  [time warp attack][topic time warp] with about a month of
  preparation; the ability to trick light clients into accepting fake transactions
  ([CVE-2017-12842][topic cves]) and confuse full nodes into rejecting
  valid blocks (see [Newsletter #37][news37 trees]).

  In addition to the above concerns from Corallo's original consensus
  cleanup, Poinsot suggests addressing the remaining [duplicate
  transactions][topic duplicate transactions] problem that will begin affecting full
  nodes at block 1,983,702 (and already affects testnet nodes).

  All of the problems above have technically simple solutions that can
  be deployed in a soft fork.  The previously proposed solution for
  slow-verification blocks was slightly controversial given that it
  could in theory have made invalid some scripts people might have
  theoretically used with presigned transactions, potentially violating
  the [confiscation avoidance][topic accidental confiscation] development
  policy (see [Newsletter #37][news37 confiscation]).  We're unaware of
  any actual use of such a script, either in the 10 years Bitcoin
  existed before the original consensus cleanup proposal or the 5 years
  since, although some types of use would be impossible to detect until
  a presigned transaction was broadcast.

  To address the concern, Poinsot proposed that the updated consensus
  rules only apply to transaction outputs created after a particular
  block height.  Any outputs created earlier than that height would
  still be spendable under the old rules. {% assign timestamp="0:46" %}

- **Choosing new BIP editors:** Mark "Murch" Erhardt continued the
  [thread][erhardt bip editors] about adding new BIP editors by
  proposing everyone express "their arguments for and against any
  candidates in this thread until Friday end-of-day (April 5th).  If any
  candidates find broad support, those candidates could be added as new
  editors to the repository on the following Monday (April 8th)."

  Discussion was ongoing at the time of writing and we will do our
  best to report on the results in next week's newsletter. {% assign timestamp="27:21" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 26.1][] is a maintenance release of the network's
  predominant full node implementation.  Its [release notes][26.1 rn]
  describe several bug fixes. {% assign timestamp="37:22" %}

- [Bitcoin Core 27.0rc1][] is a release candidate for the next major
  version of the network's predominant full node implementation.
  Testers are encouraged to review the list of [suggested testing topics][bcc testing]. {% assign timestamp="39:09" %}

- [HWI 3.0.0-rc1][] is a release candidate for the next version of this
  package providing a common interface to multiple different hardware
  signing devices. {% assign timestamp="39:40" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], and [BINANAs][binana
repo]._

*Note: the commits to Bitcoin Core mentioned below apply to its master
development branch and so those changes will likely not be released
until about six months after the release of the upcoming version 27.*

- [Bitcoin Core #27307][] begins tracking the txid of transactions in
  the mempool that conflict with a transaction belonging to Bitcoin Core's
  built-in wallet.  This includes transactions in the mempool that
  conflict with an ancestor of a wallet transaction.  If a conflicting
  transaction gets confirmed, the wallet transaction cannot be included
  on that blockchain, so it's very useful to know about conflicts.
  Conflicting mempool transactions are now shown in a new
  `mempoolconflicts` field when calling `gettransaction` on the wallet
  transaction. Inputs to a mempool-conflicted transaction may be respent
  without manually abandoning the mempool-conflicted transaction and are
  counted towards the wallet's balance. {% assign timestamp="40:59" %}

- [Bitcoin Core #29242][] introduces utility functions to compare two
  [Feerate Diagrams][sdaftuar incentive compatibility] and to evaluate the
  incentive compatibility of replacing clusters with up to two transactions.
  These functions lay the groundwork for [package][topic package relay]
  [replace-by-fee][topic rbf] with clusters of up to size two including
  [Topologically Restricted Until Confirmation (TRUC) transactions][TRUC BIP
  draft] (aka [v3 transactions][topic v3 transaction relay]). {% assign timestamp="43:50" %}

- [Core Lightning #7094][] removes multiple features that were
  previously deprecated using Core Lightning's new deprecation system
  (see [Newsletter #288][news288 cln deprecation]). {% assign timestamp="52:59" %}

- [BDK #1351][] makes several changes to how BDK interprets the
  `stop_gap` parameter, which controls its [gap limit][topic gap limits]
  behavior.  One change in particular attempts to match the behavior in
  other wallets where a `stop_gap` limit of 10 will result in BDK
  continuing to generate new addresses for scanning for transactions
  until 10 consecutive addresses have been generated with no matching
  transactions found. {% assign timestamp="54:41" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27307,29242,7094,1351" %}
[bitcoin core 26.1]: https://bitcoincore.org/bin/bitcoin-core-26.1/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/27.0-Release-Candidate-Testing-Guide
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[poinsot cleanup]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710
[news36 cleanup]: /en/newsletters/2019/03/05/#cleanup-soft-fork-proposal
[news37 confiscation]: /en/newsletters/2019/03/12/#cleanup-soft-fork-proposal-discussion
[erhardt bip editors]: https://gnusha.org/pi/bitcoindev/52a0d792-d99f-4360-ba34-0b12de183fef@murch.one/
[sdaftuar incentive compatibility]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553
[TRUC BIP draft]: https://github.com/bitcoin/bips/pull/1541
[news288 cln deprecation]: /en/newsletters/2024/02/07/#core-lightning-6936
[26.1 rn]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-26.1.md
[HWI 3.0.0-rc1]: https://github.com/bitcoin-core/HWI/releases/tag/3.0.0-rc.1
[news37 trees]: /en/newsletters/2019/03/12/#bitcoin-core-vulnerability-disclosure
