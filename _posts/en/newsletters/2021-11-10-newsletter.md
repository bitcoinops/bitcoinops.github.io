---
title: 'Bitcoin Optech Newsletter #174'
permalink: /en/newsletters/2021/11/10/
name: 2021-11-10-newsletter
slug: 2021-11-10-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a post about ways of integrating
discreet log contracts with LN channels, links to a detailed summary of
the recent LN developer conference, and describes ideas for performing
additional verification of compact block filters.  Also included are our
regular sections with the summary of a Bitcoin Core PR Review Club
meeting, our final column about preparing for taproot activation,
descriptions of new releases and release candidates, and a list of
notable changes to popular infrastructure software.

## News

- **DLCs over LN:** Thibaut Le Guilly started a [thread][leguilly
  thread] on the DLC-Dev mailing list about integrating [Discreet Log
  Contracts][topic dlc] (DLCs) with LN.  The initial post describes several
  possible constructions for including DLCs in the transactions between
  two direct LN peers, e.g. Alice and Bob who jointly operate a channel.
  The post also describes some of the challenges in creating DLCs that
  are routed across the LN network.

- **LN summit 2021 notes:** Olaoluwa Osuntokun [posted][osuntokun
  summary] an extensive summary from the recent virtual and in-person LN
  developers meeting in Zurich.  The summary includes notes about using
  [taproot][topic taproot] in LN, including [PTLCs][topic ptlc],
  [MuSig2][topic musig] for [multisignatures][topic multisignature], and
  [eltoo][topic eltoo]; moving specification discussion from IRC to
  video chats; changes to the current BOLTs specification model; onion
  messages and [offers][topic offers]; stuckless payments (see
  [Newsletter #53][news53 stuckless]); [channel jamming attacks][topic
  channel jamming attacks] and various mitigations; and [trampoline
  routing][topic trampoline payments].

- **Additional compact block filter verification:**
  The [Neutrino][] lightweight included a heuristic for detecting when a
  [compact block filter][topic compact block filters] might not include
  correct data, and this heuristic incorrectly reported an error on
  correctly-generated filters for a block on testnet containing a
  taproot transaction.  The problem has been [patched][neutrino #234]
  in the Neutrino source code and other implementations of compact block
  filters are not affected, but Olaoluwa Osuntokun started a thread on
  the [Bitcoin-Dev][bd cbf thread] and [LND-Dev][ld cbf thread] mailing
  lists about the problem---and about possible future improvements to compact
  block filters, such as:

  - *New filters:* creating additional optional filter types to allow
    lightweight clients to search for other types of data.

  - *New P2P protocol message:* adding a new P2P protocol message for
    retrieving block undo data.  Block undo data includes the previous
    outputs (and related information<!--like heights-->) for each
    input spent in a block, which can be combined with a block to
    fully verify a filter was generated from that data.  Undo data can
    itself be [verified][harding undo verification] in the case of
    discrepancies between peers.

  - *Multi-block filters:* these could further reduce the data
    lightweight clients will need to download.

  - *Committed block filters:* requiring miners commit to the filter
    for their blocks, reducing the amount of data lightweight clients
    need to download to monitor for discrepancies between the filters
    being served by different peers.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Add `ChainstateManager::ProcessTransaction`][review club #23173] is a PR by
John Newbery to add a new `ChainstateManager::ProcessTransaction()` interface
function responsible for processing transactions as candidates to the mempool
and performing mempool consistency checks. The review club discussed the
current interface for adding transactions to the mempool.

{% include functions/details-list.md
  q0="What is `cs_main`? Why is it called `cs_main`?"
  a0="`cs_main` is a mutex intended to synchronize multi-threaded access to
  validation state. In reality, it also guards non-validation data, including
  data used in P2P logic; multiple contributors wish to minimize the usage of `cs_main`.
  The variable was named when validation functionality was housed in a main.cpp
  file. The prefix, `cs`, stands for critical section."
  a0link="https://bitcoincore.reviews/23173#l-45"

  q1="Which components currently call `AcceptToMemoryPool`? Which of the ATMP
  calls are from external client code and which are from inside validation?"
  a1="Excluding calls from tests, there are four call sites:
  1. When the node starts, it [loads][atmp disk] transactions from mempool.dat and
     calls ATMP to re-validate the transactions and restore mempool contents.
     This is an internal validation call.
  2. Transactions received from peers on the P2P network are [validated and submitted
   to the mempool][atmp p2p] through ATMP. This
     call originates from a component 'external' to validation.
  3. During a reorg, any transactions that were present in the disconnected
     block(s) but not included in the new chain tip are [resubmitted][atmp reorg]
     to the mempool using ATMP. This is an internal validation call.
  4. Clients such as RPC (e.g. `sendrawtransaction`) and the wallet (e.g.
     `sendtoaddress`) submit their transactions to the node using
     [`BroadcastTransaction()`][atmp client], which calls ATMP. The
     `testmempoolaccept` RPC also calls ATMP with `test_accept` set to `true`. These
     are examples of calls from components 'external' to validation."
  a1link="https://bitcoincore.reviews/23173#l-80"

  q2="What does `CTxMemPool::check()` do? Whose responsibility is it to call
    that function?"
  a2="`CTxMemPool::check()` checks that all transactions' inputs correspond to
    available UTXOs and performs internal consistency checks over the entire mempool.
    For example, it counts the ancestors and descendants of each mempool entry
    to ensure the cached `ancestorsize`, `ancestorcount`, `descendantsize`, and
    `descendantcount` values are accurate. Currently, callers of ATMP are
    responsible for calling `check()` afterwards. However, the participants
    discussed that it should be the `ChainstateManager`'s responsibility to perform
    its own internal consistency checks."
  a2link="https://bitcoincore.reviews/23173#l-122"

  q3="What does the `bypass_limits` argument do? In which circumstances is ATMP
    called with it set to true?"
  a3="When `bypass_limits` is true, the mempool maximum size and minimum feerate
  are not enforced. For example, if the mempool is full and its dynamic mempool
  minimum feerate is 3 sat/vB, an individual transaction with a 1 sat/vB feerate may
  be accepted. ATMP is called with `bypass_limits` during a [reorg][atmp bypass
  limits]; these transactions may have low individual feerates but high descendant
  feerates. The total size of the transactions to re-add to the mempool is limited
  to `MAX_DISCONNECTED_TX_POOL_SIZE`, or 20 MB."
  a3link="https://bitcoincore.reviews/23173#l-132"
%}

## Preparing for taproot #21: thank you!

*The final entry in a weekly [series][series preparing for taproot]
about how developers and service providers can prepare for the upcoming
activation of taproot at block height {{site.trb}}.*

{% include specials/taproot/en/21-thanks.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BTCPay Server 1.3.3][] is a release <!-- along with the previous
  release one day earlier --> containing a critical security patch for
  instances on a shared server which also share their LN nodes.  Also
  included are minor features and other bug fixes.

- [Rust-Lightning 0.0.103][] is a release which adds an
  `InvoicePayer` API for retrying payments when some paths fail.

- [C-Lightning 0.10.2][] is a release that [includes][decker
  tweet] a fix for the [uneconomical outputs security issue][news170
  unec bug], a smaller database size, and an improvement in the
  effectiveness of the `pay` command.

- [LND 0.13.4-beta][] is a maintenance release that fixes the Neutrino
  bug described in the *News* section above.  The release notes say, "If
  you run Neutrino in production, we strongly recommend you update to
  this version before taproot activation to ensure your node keeps
  moving forward in the chain."

- [LND 0.14.0-beta.rc3][] is a release candidate that includes
  additional [eclipse attack][topic eclipse attacks] protection (see
  [Newsletter #164][news164 ping]), remote database support ([Newsletter
  #157][news157 db]), faster pathfinding ([Newsletter #170][news170
  path]), improvements for users of Lightning Pool ([Newsletter
  #172][news172 pool]), and reusable [AMP][topic amp] invoices
  ([Newsletter #173][news173 amp]) in addition to many other features
  and bug fixes.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], and
[Lightning BOLTs][bolts repo].*

- [Rust-Lightning #1078][] adds `channel_type` negotiation as defined in [BOLTs
  #880][] and covered in [Newsletter #165][news165 bolts-880]. This
  implementation does not currently send the proposed feature bit from [BOLTs
  #906][].  BOLTs #880 is required for [anchor channels][topic anchor
  outputs] and may also be needed to support [zero-conf
  channels][news156 zcc].

- [Rust-Lightning #1144][] adds a penalization mechanism to the route scoring
  logic. The penalty is applied to failed channels between payment retries to
  inform the pathfinding algorithm of potentially faulty channels.

- [BIPs #1215][] makes several updates to the
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] proposal in [BIP119][]:

  * Specifying that the soft fork would be deployed using a [speedy trial][news139 speedy trial]
    activation, similar to taproot activation.
  * Documenting the rationale for using non-tagged SHA256 hashes.
  * Adding more comparison between the OP_CHECKTEMPLATEVERIFY proposal and
    the [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] proposal.
  * Explaining the interactions between OP_CHECKTEMPLATEVERIFY and other
    potential future consensus changes.

{% include references.md %}
{% include linkers/issues.md issues="1078,1144,1215,880,906,23173" %}
[c-lightning 0.10.2]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.2
[decker tweet]: https://twitter.com/Snyke/status/1452260691939938312
[news170 unec bug]: /en/newsletters/2021/10/13/#ln-spend-to-fees-cve
[btcpay server 1.3.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.3.3
[rust-lightning 0.0.103]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.103
[lnd 0.14.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.0-beta.rc3
[leguilly thread]: https://mailmanlists.org/pipermail/dlc-dev/2021-November/000091.html
[osuntokun summary]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-November/003336.html
[news53 stuckless]: /en/newsletters/2019/07/03/#stuckless-payments
[neutrino]: https://github.com/lightninglabs/neutrino
[neutrino #234]: https://github.com/lightninglabs/neutrino/pull/234
[bd cbf thread]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-November/019589.html
[ld cbf thread]: https://groups.google.com/a/lightning.engineering/g/lnd/c/CE2EslTiqW4/m/CSV3mL5JBQAJ
[harding undo verification]: https://groups.google.com/a/lightning.engineering/g/lnd/c/CE2EslTiqW4/m/O0_kQF7mBQAJ
[news164 ping]: /en/newsletters/2021/09/01/#lnd-5621
[news165 bolts-880]: /en/newsletters/2021/09/08/#bolts-880
[news157 db]: /en/newsletters/2021/07/14/#lnd-5447
[news170 path]: /en/newsletters/2021/10/13/#lnd-5642
[news172 pool]: /en/newsletters/2021/10/27/#lnd-5709
[news173 amp]: /en/newsletters/2021/11/03/#lnd-5803
[news156 zcc]: /en/newsletters/2021/07/07/#zero-conf-channel-opens
[lnd 0.13.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.4-beta
[news139 speedy trial]: /en/newsletters/2021/03/10/#a-short-duration-attempt-at-miner-activation
[atmp disk]: https://github.com/bitcoin/bitcoin/blob/23ae7931be50376fa6bda692c641a3d2538556ee/src/validation.cpp#L4489-L4490
[atmp p2p]: https://github.com/bitcoin/bitcoin/blob/23ae7931be50376fa6bda692c641a3d2538556ee/src/net_processing.cpp#L3262
[atmp reorg]: https://github.com/bitcoin/bitcoin/blob/23ae7931be50376fa6bda692c641a3d2538556ee/src/validation.cpp#L352-L354
[atmp client]: https://github.com/bitcoin/bitcoin/blob/23ae7931be50376fa6bda692c641a3d2538556ee/src/node/transaction.cpp#L73-L83
[atmp bypass limits]: https://github.com/bitcoin/bitcoin/blob/f87e07c6fe321f0fb97703c82c0e4122f800589f/src/validation.cpp#L353
