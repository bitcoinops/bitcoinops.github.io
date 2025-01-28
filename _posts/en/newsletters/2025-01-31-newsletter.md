---
title: 'Bitcoin Optech Newsletter #339'
permalink: /en/newsletters/2025/01/31/
name: 2025-01-31-newsletter
slug: 2025-01-31-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a vulnerability affecting older
versions of LDK, looks at a newly disclosed aspect of a vulnerability
originally published in 2023, and summarizes renewed discussion about
compact block reconstruction statistics.  Also included are our regular
sections summarizing popular questions on the Bitcoin Stack Exchange,
announcing new releases and release candidates, and describing recent
changes to popular Bitcoin infrastructure software.

## News

- **Vulnerability in LDK claim processing:** Matt Morehouse
  [posted][morehouse ldkclaim] to Delving Bitcoin to disclose a
  vulnerability affecting LDK that he [responsibly disclosed][topic
  responsible disclosures] and which was fixed in LDK version 0.1.  When
  a channel is unilaterally closed with multiple pending [HTLCs][topic
  htlc], LDK will attempt to resolve as many HTLCs as possible in the
  same transaction to save on transaction fees.  However, if the channel
  counterparty is able to confirm any of the batched HTLCs first, that will
  _conflict_ with the batch transaction and make it invalid.  In that
  case, LDK would correctly create an updated batch transaction with the
  conflict removed.  Unfortunately, if the counterparty's transaction
  conflicts with multiple separate batches, LDK would incorrectly only
  update the first batch.  The remaining batches would not be able to
  be confirmed.

  Nodes must resolve their HTLCs before a deadline, or the counterparty
  can steal back their funds.  A [timelock][topic timelocks] prevents
  the counterparty from spending HTLCs before their individual
  deadlines.  Most older versions of LDK put those HTLCs in a separate
  batch that it was sure to confirm before the counterparty could
  confirm a conflicting transaction, ensuring that no funds could be stolen.
  For HTLCs that didn't allow funds theft, but which the counterparty
  could resolve immediately, there was a risk that the counterparty
  could cause funds to become stuck.  Morehouse writes that this can be
  fixed by "upgrading to LDK version 0.1 and replaying the sequence of
  commitment and HTLC transactions that led to the lock up."

  However, the release candidate LDK 0.1-beta changed its logic (see
  [Newsletter #335][news335 ldk3340]) and began batching all types of
  HTLCs together, which could allow an attacker to create a conflict
  with a timelocked HTLC.  If the resolution of that HTLC remained stuck
  after the timelock expired, theft was possible.  Upgrading to the
  release version of LDK 0.1 also fixes this form of the vulnerability.

  Morehouse's post provides additional details and discusses possible
  ways to prevent future vulnerabilities stemming from the same root
  cause.

- **Replacement cycling attacks with miner exploitation:** Antoine Riard
  [posted][riard minecycle] to the Bitcoin-Dev mailing list to
  disclose an additional vulnerability possible with the [replacement
  cycling][topic replacement cycling] attack he originally publicly
  disclosed in 2023 (see [Newsletter #274][news274 cycle]).  In short:

  1. Bob broadcasts a transaction paying Mallory (and possibly other
     people).

  2. Mallory [pins][topic transaction pinning] Bob's transaction.

  3. Bob doesn't realize he's been pinned and bumps the fees (using
     either [RBF][topic rbf] or [CPFP][topic cpfp]).

  4. Because Bob's original transaction was pinned, his fee bump
     doesn't propagate.  However, Mallory receives it somehow.  Steps 3
     and 4 may repeat multiple times to
     greatly increase Bob's fee.

  5. Mallory mines Bob's highest fee bump, which nobody else is trying
     to mine because it didn't propagate.  This allows Mallory to earn
     more fees than other miners.

  6. Mallory can now use replacement cycling to move her transaction pin
     to another transaction and repeat the attack (possibly with a
     different victim) without allocating additional funds, making the
     attack economically efficient.

  We don't judge the vulnerability to be a significant risk.
  Exploiting the vulnerability requires specific circumstances that
  might be rare and can result in an attacker losing money if they judge
  network conditions poorly.  If an attacker did regularly
  exploit the vulnerability, we believe their behavior would be detected
  by community members who build and use [block monitoring
  tools][miningpool.observer].

- **Updated stats on compact block reconstruction:** following up on a
  previous thread (see [Newsletter #315][news315 cb]), developer 0xB10C
  [posted][b10c cb] to Delving Bitcoin updated stats on the frequency at
  which his Bitcoin Core nodes needed to request additional transactions
  to perform [compact block][topic compact block relay]
  reconstruction.  When a node receives a compact block, it must request
  any transactions in that block that it does not already have in its
  mempool (or in its _extrapool_, which is a special reserve that aims
  to help with compact block reconstruction).  This significantly slows
  down block propagation speed and contributes to miner
  centralization.

  0xB10C found that the frequency of requests increases significantly as
  the size of the mempool grows.  Several developers discussed possible
  causes, with initial data indicating that the missing transactions
  were _orphans_---child transactions of unknown parents, which Bitcoin
  Core only stores briefly in case their parents arrive within a
  short time.  Improved tracking and requesting of the parents of orphan
  transactions, recently merged into Bitcoin Core (see [Newsletter
  #338][news338 orphan]), could help improve this situation.

  Developers also discussed other possible solutions.  Nodes
  can't reasonably keep orphan transactions for a long time because an
  attacker can create them for free---but it might be possible to persist
  a larger number of them and other evicted transactions for a longer
  time in the extrapool.  The discussion was inconclusive at the time of
  writing.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LDK v0.1.1][] is a security release of this popular library for
  building LN-enable applications.  An attacker willing to sacrifice at
  least 1% of channel funds could trick the victim into closing other
  unrelated channels, which may result in the victim unnecessarily
  spending money on transaction fees.  Matt Morehouse, who discovered
  the vulnerability, [posted][morehouse ldk-dos] about it to Delving
  Bitcoin; Optech will provide a more detailed summary in next week's
  newsletter.  The release also includes API updates and bug fixes.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #31376][] Miner: never create a template which exploits the timewarp bug

- [Bitcoin Core #31583][] rpc: add target to getmininginfo field and show next block info

- [Bitcoin Core #31590][] descriptors: Try pubkeys of both parities when retrieving the private keys for an xonly pubkey in a descriptor

- [Eclair #2982][] Add liquidity griefing protection for liquidity ads

- [BDK #1614][] feat(rpc): introduce FilterIter

- [BOLTs #1110][] Peer storage for nodes to distribute small encrypted blobs.

{% include snippets/recap-ad.md when="2025-02-04 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31376,31583,31590,2982,1614,1110" %}
[morehouse ldkclaim]: https://delvingbitcoin.org/t/disclosure-ldk-invalid-claims-liquidity-griefing/1400
[news335 ldk3340]: /en/newsletters/2025/01/03/#ldk-3340
[riard minecycle]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CALZpt+EnDUtfty3X=u2-2c5Q53Guc6aRdx0Z4D75D50ZXjsu2A@mail.gmail.com/
[miningpool.observer]: https://miningpool.observer/template-and-block
[b10c cb]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/5
[news315 cb]: /en/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[news338 orphan]: /en/newsletters/2025/01/24/#bitcoin-core-31397
[news274 cycle]: /en/newsletters/2023/10/25/#replacement-cycling-vulnerability-against-htlcs
[ldk v0.1.1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.1
[morehouse ldk-dos]: https://delvingbitcoin.org/t/disclosure-ldk-duplicate-htlc-force-close-griefing/1410
