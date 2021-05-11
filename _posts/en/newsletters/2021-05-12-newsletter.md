---
title: 'Bitcoin Optech Newsletter #148'
permalink: /en/newsletters/2021/05/12/
name: 2021-05-12-newsletter
slug: 2021-05-12-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a security disclosure affecting
protocols depending on a certain BIP125 opt-in replace by fee behavior
and includes our regular sections with the summary of a Bitcoin Core PR
Review Club meeting, announcements of new software releases and release
candidates, and descriptions of notable changes to popular Bitcoin
infrastructure software.

## News

- **CVE-2021-31876 discrepancy between BIP125 and Bitcoin Core implementation:**
  the [BIP125][] specification of opt-in Replace By Fee ([RBF][topic
  rbf]) says that an unconfirmed parent transaction that signals
  replaceability makes any child transactions that spend the parent's
  outputs also replaceable through inferred inheritance.  This week,
  Antoine Riard [posted][riard cve-2021-31876] to the Bitcoin-Dev
  mailing list the full disclosure of his previously privately reported
  finding that Bitcoin Core does not implement this behavior.  It is
  still possible for child transactions to be replaced if they
  explicitly signal replaceability or for them to be evicted from the
  mempool if their parent transaction is replaced.

    Riard analyzed how the inability to use inherited replaceability
    might affect various current and proposed protocols.  Only LN
    appears to be affected and only in the sense that an existing attack
    (see [Newsletter #95][news95 atomicity attack]) that uses
    [pinning][topic transaction pinning] becomes cheaper.  The ongoing
    deployment of [anchor outputs][topic anchor outputs] by
    various LN implementations will eliminate the ability to perform that
    pinning.

    As of this writing, there has not been any substantial discussion of
    the issue on the mailing list.

- **Call for Brink grant applications:**
  Bitcoin Optech encourages any engineer contributing to open source
  Bitcoin or Lightning projects to [apply for a Brink grant][brink grant
  application] before the application deadline on May 17th. Initial grants are
  one year long and allow developers to work full time on open source projects
  from anywhere in the world.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Introduce node rebroadcast module][review club
#21061] is a PR ([#21061][Bitcoin Core #21061]) by Amiti Uttarwar that continues
work on the rebroadcast project (see Newsletters [#64][rebroadcast 1],
[#96][rebroadcast 2], [#129][rebroadcast 3] and [#142][rebroadcast 4]),
previously discussed in review clubs [#16698][review club
#16698] and [#18038][review club #18038], whose goal is to make node
rebroadcast behavior for wallet transactions indistinguishable from that of
other peers' transactions.

The review club discussion focused on current transaction behavior and the
proposed changes:

{% include functions/details-list.md
  q0="Why might we want to rebroadcast a transaction?"
  a0="When our transaction didn't propagate (perhaps our node was offline) or
      appears to have been dropped by other nodes' mempools in the network."
  a0link="https://bitcoincore.reviews/21061#l-39"

  q1="Why does a node drop a transaction from its mempool?"
  a1="Apart from being included in a block, a transaction can expire after 14
      days, be squeezed out of a node's limited mempool size (default size 300
      MiB) by higher-fee transactions, be replaced via [BIP125][] opt-in
      Replace-By-Fee ([RBF][topic rbf]), be removed if a conflicting transaction
      is included in a block, or be included in a block that is later reorged
      out (in which case the node will try to re-add it while [updating the
      mempool][UpdateMempoolForReorg] to be consistent again after the reorg)."
  a1link="https://bitcoincore.reviews/21061#l-53"

  q2="What could be an issue with the current behavior of each wallet being
      responsible for rebroadcasting its own transactions?"
  a2="This can be a privacy leak that allows linking the IP address to the
      wallet address, as under the current rebroadcasting behavior, a node that
      broadcasts a transaction more than once is essentially announcing that the
      transaction is from its wallet."
  a2link="https://bitcoincore.reviews/21061#l-58"

  q3="When might a miner exclude a transaction that is in our mempool?"
  a3="When the miner deprioritized it for having a low fee, didn't see it yet,
      removed it from its mempool by RBF, censored it, or mined an empty block."

  q4="When might a miner include a transaction that is not in our mempool?"
  a4="When the miner manually prioritized the transaction (e.g. as a commercial
      service), received it before our node, or the transaction conflicted with
      another one in our mempool but not in theirs."

  q5="How would the proposal under review decide which transactions to
      rebroadcast?"
  a5="Once per new block, it proposes to rebroadcast transactions above an
      estimated feerate that are at least 30 minutes old, have been rebroadcast
      no more than 6 times and not more recently than 4 hours ago, with up to
      3/4 of the transactions that fit the block."
  a5link="https://bitcoincore.reviews/21061#l-63"

  q6="Why might we want to keep a transaction in our rebroadcast attempt tracker even after
      it has been removed from our mempool?"
  a6="After a consensus rule change, there can be non-updated nodes on the
      network rebroadcasting transactions that don't meet the new consensus
      rules.  Keeping transactions in the rebroadcast attempt tracker would avoid these
      nodes rebroadcasting them too many times (a maximum of 6 times over 90
      days) and allow the transactions to expire."
  a6link="https://bitcoincore.reviews/21061#l-178"

  q7="When would we remove a transaction from our rebroadcast attempt tracker?"
  a7="When the transaction is confirmed, [RBFed][topic rbf], or conflicts with
      another transaction included in a block."
  a7link="https://bitcoincore.reviews/21061#l-199"

  q8="How would the estimated minimum feerate for rebroadcast be calculated?
      Why not use the lowest feerate in the last mined block?"
  a8="The rebroadcast feerate floor would be estimated once a minute by
      assembling a block from the mempool to simulate inclusion in the next
      mined block.  This approach is better than using the lowest feerate of the
      last mined block because it calculates fees based on the immediate future
      in a changing environment instead of based on the past."
  a8link="https://bitcoincore.reviews/21061#l-227"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Rust-Lightning 0.0.14][] is a new release that makes Rust Lightning
  more compatible with getting data from Electrum-style servers, adds
  additional configuration options, and improves compliance with the LN
  specification, among other bug fixes and improvements.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #20867][] increases the number of keys that can be included in
  multisig [descriptors][topic descriptors] and used in the
  `addmultisigaddress` and `createmultisig` RPCs from 16 to 20. The increased
  limit can only be used in P2WSH outputs. P2SH outputs are limited to 520
  byte scripts which are only large enough to hold 15 compressed public keys.

- [Bitcoin Core GUI #125][] enables users to adjust the autoprune block space
  size from the default in the intro dialog.  It also adds an improved
  description for how the pruned storage works, clarifying that the entire
  blockchain must be downloaded and processed but will be discarded in
  the future to keep disk usage low.

- [C-Lightning #4489][] adds a `funder` plugin for configuring
  [dual-funding][topic dual funding] contribution behavior in response to
  incoming channel open requests. Users will be able to specify a general
  contribution policy (percent match, percent available funds, or fixed
  contribution), a wallet reserve amount under which no dual-funding
  contributions will happen, a maximum contribution amount for any single
  channel open request, and more.

  This PR represents the last step in enabling experimental dual-funding support between
  C-Lightning nodes. The interactive transaction construction and channel
  establishment v2 protocols arising out of this work is still being
  standardized in the open [BOLTs #851][] PR.

- [C-Lightning #4496][] adds the ability for plugins to register topics
  about which they plan to publish notifications.  Other plugins can
  subscribe to those topics to receive notifications.
  C-Lightning already had several built-in topics, but this merged PR
  allows plugin authors to create and consume notifications for any
  new topic category they'd like to use.

- [Rust Bitcoin #589][] starts the process of implementing support for [taproot][topic
  taproot] with [schnorr signatures][topic schnorr signatures].  The
  existing ECDSA support is moved to a new module but continues to be
  exported under existing names to preserve API compatibility.  A new
  `util::schnorr` module adds support for [BIP340][] schnorr key
  encodings.  Issue [#588][rust bitcoin #588] is being used to track the
  complete implementation of taproot compatibility.

{% include references.md %}
{% include linkers/issues.md issues="20867,125,4489,4496,589,588,21061,16698,18038,851" %}
[riard cve-2021-31876]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-May/018893.html
[news95 atomicity attack]: /en/newsletters/2020/04/29/#new-attack-against-ln-payment-atomicity
[rust-lightning 0.0.14]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.14
[rebroadcast 1]: /en/newsletters/2019/09/18/#bitcoin-core-rebroadcasting-logic
[rebroadcast 2]: /en/newsletters/2020/05/06/#bitcoin-core-18038
[rebroadcast 3]: /en/newsletters/2020/12/23/#transaction-origin-privacy
[rebroadcast 4]: /en/newsletters/2021/03/31/#will-nodes-with-a-larger-than-default-mempool-retransmit-transactions-that-have-been-dropped-from-smaller-mempools
[UpdateMempoolForReorg]: https://github.com/bitcoin/bitcoin/blob/e175a20769/src/validation.cpp#L357
[brink grant application]: https://brink.homerun.co/grants
