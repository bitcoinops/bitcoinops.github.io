---
title: 'Bitcoin Optech Newsletter #105'
permalink: /en/newsletters/2020/07/08/
name: 2020-07-08-newsletter
slug: 2020-07-08-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a proposed BIP for BIP32-based path
templates and includes our regular sections with the summary of a Bitcoin
Core PR Review Club meeting, releases and release candidates, and
notable changes to popular Bitcoin infrastructure software.

## Action items

*None this week.*

## News

- **Proposed BIP for BIP32 path templates:** Dmitry Petukhov
  [posted][petukhov path templates] a proposed BIP to the Bitcoin-Dev
  mailing list, suggesting a standardized format for describing what
  [BIP32][] key derivation paths a wallet should support.  Many wallets
  today limit their users to certain paths, such as those described by
  [BIP44][] and related BIPs, refusing to allow the use of alternative
  paths or making such use difficult.  This limitation has the advantage that the
  user can just reinstall a software wallet or buy a compatible hardware
  wallet, enter their seed or seed phrase, and recover any funds using
  the wallet's default path.  But hardcoding particular paths also
  constrains wallets to only the use cases envisioned by their own developers,
  rather than allowing the wallets to be used for other purposes or protocols.
  Path templates provide a compact way for the user to describe to the
  wallet what paths they want to use.  The compactness of path templates
  makes it easy to back up the template along with the seed, helping
  prevent users from losing funds.  An additional feature of the
  proposed path templates is the ability to describe derivation limits
  (e.g. that a wallet should derive no more than 50,000 keys in a
  particular path), which can make it practical for a recovery procedure
  to scan for bitcoins received to all possible wallet keys, eliminating
  concerns about gap limits in HD wallets (see [Newsletter #52][news52
  gap]).

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Cache responses to `getaddr` to prevent topology leaks][review club #18991] is a
[PR][Bitcoin Core #18991] by Gleb Naumenko that aims to make it more difficult
for spy nodes to infer the P2P network topology using `addr` message gossiping.

The discussion began by covering the basic concepts of address gossiping, and
later focused on what privacy leaks are currently possible and what the PR
intends to change.

{% include functions/details-list.md
  q0="What is the importance of `addr` relay and specifically the `getaddr`/`addr` protocol?"
  a0="`addr` relay is used for nodes to find new potential peers on the P2P network."
  a0link="https://bitcoincore.reviews/18991.html#l-34"

  q1="Which properties of `addr` relay are important?"
  a1="Nodes need to learn about a diverse set of peers with good uptime that were online recently."
  a1link="https://bitcoincore.reviews/18991.html#l-57"

  q2="How can a spy use `addr` messages to infer network topology?"
  a2="There are potentially multiple ways to infer topology from `addr` messages, but the most-discussed method was scraping nodes' address managers (addrman) to determine how an address record is spread across the network and whether any nodes have a unique timestamp for that address record (indicating that they're probably directly connected to that address). This is the method that was used in the [Coinscope paper][]."
  a2link="https://bitcoincore.reviews/18991.html#l-129"

  q3="What could a malicious actor do if they were able to map the entire P2P topology?"
  a3="Knowing the entire P2P network topology makes it easier to carry out attacks such as network partitions or [eclipse attacks][topic eclipse attacks]."
  a3link="https://bitcoincore.reviews/18991.html#l-176"

  q4="Is it a problem if nodes cache responses to `getaddr` messages and serve records that are old?"
  a4="Opinions differ. Some people [think][naumenko churn] there isn't much churn on the P2P network, so old records are usually still valid; others [aren't sure][wuille churn]."

  q5="Does this PR prevent the unique-timestamp topology inference?"
  a5="No. This PR makes it more difficult to scrape a node's address manager (addrman) but does not change the timestamps on relayed address records. A future PR could make additional changes to address the unique-timestamp inference."
  a5link="https://bitcoincore.reviews/18991.html#l-263"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Eclair 0.4.1][] this new release adds support for
  `option_static_remotekey` (though disabled by default), which can
  simplify backups (see [Newsletter #67][news67 bolts642]).  The release also
  enables sending [multipath payments][topic multipath payments] (MPP)
  by default, uses a new MPP splitting algorithm, offers beta support
  for using the PostgreSQL database, and better manages feerate
  mismatches between your node and your peers---all changes described in
  more detail below in the *Notable Changes* section of this
  newsletter.

- [LND 0.10.2-beta.rc4][lnd 0.10.2-beta]: this
  LND maintenance release is now available.  It includes
  several bug fixes, including an important fix related to the creation
  of backups.

- [LND 0.10.3-beta.rc1][lnd 0.10.3-beta]: this release,
  separate from the 0.10.2 release, includes a package refactoring in
  addition to the bug fixes provided in 0.10.2.  For details, see a
  mailing list [post][osuntokun rcs] by LND developer Olaoluwa
  Osuntokun.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #19204][] eliminates a source of wasted bandwidth during
  Initial Block Download (IBD).  When Bitcoin Core is in IBD, it often
  doesn't have the necessary information to validate currently
  unconfirmed transactions, so it ignores relayed transaction
  announcements.  However, those announcements still consume the
  bandwidth of the receiving IBD node and its sending peers.  This PR
  uses the [BIP133][] `feefilter` P2P message to tell peers that the
  node doesn't want to receive announcements of any transactions that
  pay less than 21 million BTC in fees per 1,000 vbytes, which should
  prevent it from receiving any legitimate transaction announcements.
  When the node finishes catching up to the tip of the best block chain,
  it sends another `feefilter` message with its actual minimum relay
  feerate so that it can start to receive newly-announced transactions.

- [Bitcoin Core #19215][] creates [PSBTs][topic psbt] containing each
  previous transaction that created one of the UTXOs being spent in the
  current transaction---even for segwit v0 UTXOs.  Before this change,
  previous transactions were only included for legacy (non-segwit)
  UTXOs.  This change is a response to some hardware wallets now
  requiring or recommending access to previous transactions for segwit
  UTXOs in order to mitigate the [fee overpayment attack][].  If segwit
  v1 ([taproot][topic taproot]) is adopted, transactions spending all
  taproot inputs should not need this extra data by default.

- [C-Lightning #3775][] adds four RPC methods for [PSBT][topic psbt] lifecycle
  management backed by C-Lightning's internal wallet. The `reserveinputs` RPC
  method creates a PSBT by choosing UTXOs from the internal wallet as inputs to
  satisfy the user-specified list of outputs, marking chosen UTXOs as reserved.
  The resulting PSBT may either be supplied to the `unreserveinputs` RPC method
  to manually release the reserved UTXOs, or to the `signpsbt` RPC method to add
  signatures from the internal wallet. Finally, the `sendpsbt` RPC method will
  convert a fully signed PSBT into a ready-to-broadcast transaction and then
  broadcast it to the network. Users should note that restarting C-Lightning
  effectively un-reserves all previously reserved UTXOs, requiring a new PSBT be
  created with `reserveinputs` before `signpsbt` will accept it.

- [Eclair #1427][] and [#1439][Eclair #1439] add support to Eclair for
  effective sending of [multipath payments][topic multipath
  payments]---payments which are split into several parts, with each
  part routed using a different path.  These PRs split payments into up
  to six parts by default, initially allocating 0.00015 BTC to each part
  but increasing the value of each part by a semi-random amount until
  the full payment amount has been allocated.  Once the amounts have all
  been selected, all of the payments parts are sent.  This is not only efficient but
  also uses the opportunistic value-increasing
  function to help prevent any nodes that see a subset of the
  payments from guessing the full payment amount, improving privacy.  If
  you're interested in details, both Eclair's and C-Lightning's
  splitting algorithms were [discussed][split algos] by their authors
  this week.

- [Eclair #1249][] adds optional support for using PostgreSQL as the
  database backend instead of the default SQLite.  For details, see
  Eclair's new [PostgreSQL documentation][eclair postgresql].  See also
  the report for Optech about [using Eclair in a production
  environment][eclair production] with PostgreSQL, written by Roman
  Taranchenko---who is also the author of this PR.

- [Eclair #1473][] updates Eclair's code for handling a mismatch between
  the onchain feerate selected by a remote channel peer and the feerate
  the local node thinks is appropriate.  After this change, if the
  remote peer selects a feerate that seems to be too high, the local
  node won't close the channel unless it's more than ten times the
  rate the local node thinks is appropriate.  This is acceptable since
  the remote peer pays the fee and high fees should ensure the channel
  is quickly settled to the advantage of both peers.  However, if the
  feerate is set to less than 50% the value the local node expects, it
  will close the channel immediately to ensure any pending payments
  (HTLCs) can be settled before feerates rise further.  The PR also
  ensures channels aren't closed due to fee issues when there aren't any
  payments that need to be resolved.

- [LND #4167][] allows [spontaneous payments][topic spontaneous
  payments] made using keysend (see [Newsletter #94][news94 keysend]) to be
  inspected before they are settled or canceled---basically, this PR
  implements [hold invoices][topic hold invoices] for spontaneous
  payments.  The PR description notes a possible use for this feature:
  "a keysend payment with an embedded order comes in. The payment is
  held and an external application checks that the paid amount is
  sufficient for the ordered goods. If not, the payment is canceled
  without the need to refund anything. If the amount is sufficient, the
  payment is settled and the order processed."

- [HWI #351][] upgrades the version of the [btchip-python][] library it uses
  to interact with a Ledger hardware wallet.  This new library version
  works around a [bug][ledger bug] in the latest version of the Bitcoin
  app for Ledger devices that produced incorrect signatures for
  transactions with multiple segwit inputs.  Electrum has also updated
  its library dependency to fix the [same issue][electrum update].
  Both upgrades are part of the response to the [fee overpayment
  attack][].

{% include references.md %}
{% include linkers/issues.md issues="19204,19215,3775,1427,1249,1473,4167,351,1439,18991" %}
[lnd 0.10.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.2-beta
[lnd 0.10.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.3-beta
[eclair 0.4.1]: https://github.com/ACINQ/eclair/releases/tag/v0.4.1
[osuntokun rcs]: https://groups.google.com/a/lightning.engineering/forum/#!topic/lnd/jgd1ZC9T5n4
[eclair postgresql]: https://github.com/ACINQ/eclair/blob/b63c4aa5a4c4cb0645d66517942d12151e6b2069/docs/PostgreSQL.md
[news67 bolts642]: /en/newsletters/2019/10/09/#bolts-642
[fee overpayment attack]: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[split algos]: https://github.com/ElementsProject/lightning/pull/3773#discussion_r448796405
[news94 keysend]: /en/newsletters/2020/04/22/#c-lightning-3611
[petukhov path templates]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-July/018024.html
[news52 gap]: /en/newsletters/2019/06/26/#how-can-i-mitigate-concerns-around-the-gap-limit
[ledger bug]: https://github.com/LedgerHQ/app-bitcoin/issues/154
[electrum update]: https://github.com/spesmilo/electrum/pull/6293#issuecomment-652471789
[eclair production]: /en/suredbits-enterprise-ln/
[naumenko churn]: https://bitcoincore.reviews/18991.html#l-91
[wuille churn]: https://bitcoincore.reviews/18991.html#l-365
[btchip-python]: https://github.com/LedgerHQ/btchip-python
[coinscope paper]: https://www.cs.umd.edu/projects/coinscope/coinscope.pdf
[hwi]: https://github.com/bitcoin-core/HWI
