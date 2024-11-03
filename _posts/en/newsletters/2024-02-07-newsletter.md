---
title: 'Bitcoin Optech Newsletter #288'
permalink: /en/newsletters/2024/02/07/
name: 2024-02-07-newsletter
slug: 2024-02-07-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the public disclosure of a block
stalling bug in Bitcoin Core affecting LN, relays a concern about
how to securely open new zero-conf channels that are compatible with the
proposed version 3 transaction topology restrictions, describes a rule
many contract protocols must follow when allowing an external party to
contribute an input to a transaction, summarizes multiple
discussions about a proposal for new transaction replacement rules to
avoid transaction pinning, and provides a brief update on the
Bitcoin-Dev mailing list.

## News

- **Public disclosure of a block stalling bug in Bitcoin Core affecting LN:**
  Eugene Siegel [announced][siegel stall] to Delving Bitcoin a bug in
  Bitcoin Core he had [responsibly disclosed][topic responsible
  disclosures] almost three years ago.  Bitcoin Core 22 and higher
  contain fixes for the bug, but many people are still running affected
  versions and some of those users might also be running LN
  implementations or other contract protocol software that could be
  vulnerable to exploitation of the bug.  Upgrading to Bitcoin Core 22
  or higher is strongly recommended.  To the best of our knowledge, no
  one has lost funds due to the attack described below.

  An attacker finds an LN forwarding node that is associated with a
  relaying Bitcoin node running a version of Bitcoin Core earlier
  than 22.  The attacker opens many separate connections to a victim's
  Bitcoin node.  The attacker then attempts to deliver newly found
  blocks to the victim faster than any honest peers, resulting in
  the victim's node automatically assigning peers controlled by the
  attacker to all of the victim's high-bandwidth [compact block
  relay][topic compact block relay] slots.

  After the attacker obtains control over many of the victim's Bitcoin
  peer slots, it uses channels it controls on either side of the
  victim to forward payments it creates.  For example:

  ```
  Attacker Spender -> Victim Forwarder -> Attacker Receiver
  ```

  The attacker works with a miner to create a block that unilaterally
  closes the receiver side of the channel without relaying the
  transaction in an unconfirmed state (this miner assistance is only
  necessary when attacking an LN implementation that monitors the
  mempool for transactions).  That block, or another block created by
  the miner, also claims the payment by releasing the [HTLC][topic
  htlc] preimage.  Normally, the victim's Bitcoin node would see the
  block, give that block to its LN node, and the LN node would extract
  the preimage, allowing it to claim the payment amount from the
  spender side, keeping its forwarding balanced.

  However, in this case, the attacker uses this disclosed block
  stalling attack to prevent the Bitcoin Core node from learning about
  the blocks containing the preimage.  The stalling attack takes
  advantage of older versions of Bitcoin Core being willing to wait up
  to 10 minutes for a peer to deliver a block it announced before
  requesting that block from another peer.  Given an average of 10
  minutes between blocks, that means an attacker who controls _x_
  connections can delay a Bitcoin node from receiving a block for
  roughly the time it takes to produce _x_ blocks.  If the forwarding
  payment has to be claimed within 40 blocks, an attacker controlling
  50 connections can have a reasonable chance of preventing the
  Bitcoin node from seeing the block containing the preimage until the
  spending node is able to receive a refund of the payment.  If that
  happens, the attacker's spending node paid nothing and the
  attacker's receiving node received an amount extracted from the
  victim's node.

  {% assign timestamp="1:26" %}

  As Siegel reports, two changes were made to Bitcoin Core to prevent
  stalling:

  - [Bitcoin Core #22144][] randomizes the order in which peers are
    serviced in the message-handling thread.  See [Newsletter
    #154][news154 stall].

  - [Bitcoin Core #22147][] keeps at least one outbound high bandwidth
    compact block peer even if inbound peers seem to be performing
    better.  The local node selects its outbound peers, meaning
    they're less likely to be under the control of an attacker, so
    it's useful to keep at least one outbound peer for safety.

- **Securely opening zero-conf channels with v3 transactions:**
  Matt Corallo [posted][corallo 0conf] to Delving Bitcoin to discuss how
  to securely allow [zero-conf channel opening][topic zero-conf
  channels] when the proposed [v3 transaction relay policy][topic v3
  transaction relay] is being used.  Zero-conf channel opens are new
  single-funded channels where the funder gives some or all of their
  initial funds to the acceptor.  Those funds are not secure until the
  channel open transaction receives a sufficient number of
  confirmations, so there’s no risk to the acceptor spending some of
  those funds back through the funder using the standard LN protocol.
  The initial proposal for v3 transaction relay policy would only allow
  an unconfirmed v3 transaction to have, at most, a single child in the
  mempool; the expectation is that the single child will [CPFP fee
  bump][topic cpfp] its parent if necessary.

  Those v3 rules are incompatible with both parties being able to fee
  bump a zero-conf channel open: the funding transaction that creates
  the channel is the parent of a v3 transaction which closes the
  channel and the grandparent of a v3 transaction for fee bumping.
  Since the v3 rules only allow one parent and one child, there's no
  way for the funding transaction to be fee-bumped without modifying
  how it is created.  Bastien Teinturier [notes][teinturier splice]
  that [splicing][topic splicing] encounters a similar problem.

  As of this writing, the main solution proposed appears to be
  modifying funding and splicing transactions to include an extra
  output for CPFP fee bumping now, waiting for [cluster mempool][topic
  cluster mempool] to hopefully allow v3 to permit more permissive
  topologies (i.e., more than just one parent, one child), and then to
  drop the extra output in favor of using a more permissive topology. {% assign timestamp="17:08" %}

- **Requirement to verify inputs use segwit in protocols vulnerable to txid malleability:**
  Bastien Teinturier [posted][teinturier segwit] to Delving Bitcoin to
  describe an easy-to-overlook requirement for protocols where a third
  party contributes an input to a transaction whose txid must not change
  after a different user contributes a signature to the transaction.
  For example, in an LN [dual-funded channel open][topic dual funding]
  both Alice and Bob may contribute an input.  To ensure they each
  receive a refund if the other party fails to cooperate later, they
  create and sign a spend of the funding transaction, which they keep
  offchain unless they need it.  After they've both signed the refund
  transaction, they can both safely sign and broadcast the parent
  funding transaction.  Because the child refund transaction depends on
  the parent funding transaction having the expected txid, this process
  is only safe if there's no risk of txid malleability.

  Segwit prevents txid malleability---but only if all inputs to the
  transaction spend segwit outputs from previous transactions.
  For segwit v0, the only way for Alice to be sure that Bob is
  spending a segwit v0 output is for her to obtain a copy of the
  entire previous transaction that contained Bob's output.  If Alice
  doesn't perform this check, Bob can lie about spending a segwit
  output and instead spend a legacy output that allows him to mutate
  the txid, allowing him to invalidate the refund transaction and refuse
  to return any funds to Alice unless she agrees to pay him a ransom.

  For segwit v1 ([taproot][topic taproot]), each `SIGHASH_ALL` signature directly commits to
  every previous output being spent in the transaction (see
  [Newsletter #97][news97 spk]), so Alice can require Bob to disclose his
  scriptPubKey (which she could learn anyway from other information
  Bob needs to disclose to create a shared transaction).  Alice
  verifies that scriptPubKey uses segwit, either v0 or v1, and has her
  signature commit to it.  Now, if Bob lied and actually had a
  non-segwit output, the commitment made by Alice's signature wouldn't
  be valid, so the signature wouldn't be valid, the funding
  transaction wouldn't confirm, and there would be no need for a
  refund.

  This leads to two rules that protocols depending on presigned
  refunds must follow for security:

  1. If you are contributing an input, prefer to contribute an input
     that is the spend of a segwit v1
     output, obtain the previous outputs of all other spends in the
     transaction, verify they all use segwit scriptPubKeys, and commit
     to them using your signature.

  2. If you are not contributing an input or are not spending a segwit
     v1 output, obtain the complete previous transactions for all
     inputs, verify their outputs being spent in this transaction
     are all segwit outputs, and commit to those transactions using
     your signature.  You can also use this second procedure in all
     cases, but in the worst case it will consume almost 20,000 times
     as much bandwidth as the first procedure.<!-- ~4,000,000 byte
     transaction divided by ~22 byte P2WPKH scriptPubKey -->

  {% assign timestamp="27:00" %}

- **Proposal for replace by feerate to escape pinning:** Peter Todd
  [posted][todd rbfr] to the Bitcoin-Dev mailing list a proposal for a
  set of [transaction replacement][topic rbf] policies that can be used
  even when existing replace-by-fee (RBF) policies won't allow a
  transaction to be replaced.  His proposal comes in two different
  variations:

  - *Pure replace by feerate (pure RBFr):* a transaction currently in
    a mempool can be replaced by a conflicting transaction that pays a
    significantly higher feerate (e.g., the replacement pays a feerate
    2x the replacee's feerate).

  - *One-shot replace by feerate (one-shot RBFr):* a transaction
    currently in a mempool can be replaced by a conflicting
    transaction that pays a slightly higher feerate (e.g. 1.25x),
    provided the replacement's feerate is also high enough to put it
    in the top ~1,000,000 vbytes of the mempool (meaning the
    replacement would be mined if a block were produced immediately
    after it was accepted).

  Mark Erhardt described ([1][erhardt rbfr1], [2][erhardt rbfr2]) how
  the proposed policies could be abused to allow wasting an infinite
  amount of node bandwidth at minimal cost to an attacker.  Peter Todd
  updated the policies to eliminate that particular abuse, but other
  concerns were raised by Gregory Sanders and Gloria Zhao on a [Delving
  Bitcoin][sz rbfr] thread:

  - "Pre-cluster mempool, reasoning about any of this is very hard to
    do. Peter’s first iteration of the idea was broken, allowing
    unlimited free relay. He claims he’s fixed it by hot-patching the
    idea with additional RBF restrictions, but like usual, reasoning
    about current RBF rules is very difficult, and maybe impossible. I
    think energy would be better focused on getting RBF incentives
    right, before giving up the idea of free relay protection
    entirely."  ---Sanders

  - "The mempool as it exists to today doesn’t support an efficient
    way to calculate “miner score” or incentive compatibility, due to
    unbounded cluster sizes. [...] One advantage of cluster mempool is
    being able to calculate things like miner score and incentive
    compatibility across the mempool. Similarly, one advantage of v3
    is being able to do this before cluster mempool because of
    restricted topology. Before people took on the challenge of
    designing and implementing cluster mempool, I had been framing v3
    as “cluster limits” without having to implement cluster limits, as
    it’s one of the only ways to codify a cluster limit (count=2)
    using existing package limits (ancestors=2, descendants=2. Once
    you go up to 3, you can have infinite clusters again). Another
    advantage of v3 is that it helps unblock cluster mempool, which is
    in my opinion a no-brainer.  In summary, I don’t think the
    One-Shot Replace by Feerate proposal works (i.e. doesn’t have a
    free relay problem and is feasible to implement accurately)."
    ---Zhao

  The separate discussions were not reconciled as of this writing.
  Peter Todd has released an experimental [implementation][libre relay]
  of the replace by feerate rules. {% assign timestamp="35:21" %}

- **Bitcoin-Dev mailing list migration update:** as of this writing, the
  Bitcoin-Dev mailing list is no longer accepting new emails as part of
  the process of migrating it to a different list server (see [Newsleter #276][news276 ml]).  Optech will
  provide an update when the migration is complete. {% assign timestamp="51:15" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND v0.17.4-beta][] is a maintenance release of this popular LN node
  implementation.  It's release notes say, "this is a hot fix release
  that fixes multiple bugs: Channel open hanging until restart, a memory
  leak when using polling mode for `bitcoind`, sync getting lost for
  pruned nodes and the REST proxy not working when TLS certificate
  encryption is turned on." {% assign timestamp="1:00:02" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], and [BINANAs][binana
repo]._

- [Bitcoin Core #29189][] deprecates libconsensus.  Libconsensus was an
  attempt to make Bitcoin Core's consensus logic usable in other
  software.  However, the library hasn't seen any significant adoption
  and it has become a burden on maintenance of Bitcoin Core.  The plan
  is to "not migrate it to CMake and let it end with v27. Any remaining
  use-cases could be handled in the future by [libbitcoinkernel][]." {% assign timestamp="1:01:13" %}

- [Bitcoin Core #28956][] removes adjusted time from Bitcoin Core and
  warns users if their computer's clock appears to be out of sync with the
  rest of the network.  Adjusted time was an automatic adjustment made
  to a local node's time based on the time reported by its peers.  This
  could help a node with a slightly incorrect clock to learn from its
  peers, allowing it to avoid unnecessarily rejecting blocks and also
  give blocks it produced a more accurate time.  However, adjusted time
  has also led to problems in the past and does not provide meaningful
  benefits to nodes on the current network.  See [Newsletter
  #284][news284 adjtime] for previous coverage of this PR. {% assign timestamp="1:07:23" %}

- [Bitcoin Core #29347][] enables [v2 P2P transport][topic v2 p2p
  transport] by default.  New connections between two peers that both
  support the v2 protocol will use encryption. {% assign timestamp="1:10:03" %}

- [Core Lightning #6985][] adds options to `hsmtool` that allow it to
  return the private keys for the onchain wallet in a way that allows
  those keys to be imported into another wallet. {% assign timestamp="1:10:45" %}

- [Core Lightning #6904][] makes various updates to CLN's connection
  and gossip management code.  A user-visible change is the addition of
  fields that indicate when a peer last had a stable connection to the
  local node for at least a minute.  This can allow removing peers with
  unstable connections. {% assign timestamp="1:12:54" %}

- [Core Lightning #7022][] removes `lnprototest` from Core Lightning's
  testing infrastructure.  See [Newsletter #145][news145 lnproto] for
  our description of them being added. {% assign timestamp="1:14:53" %}

- [Core Lightning #6936][] adds infrastructure to assist with
  deprecating CLN features.  Features are now deprecated in code using
  functions that automatically disable those features by default based
  on the current program version.  Users can still force-enable the
  features even after their indicated deprecation version as long as the
  code still exists.  This avoids an occasional problem where a CLN
  feature would be reported as deprecated but continued functioning
  by default for a long time after it was planned for removal, possibly
  leading users to continue depending on it and making actual removal
  more difficult. {% assign timestamp="1:16:16" %}

- [LND #8345][] begins testing whether transactions are likely to relay
  before broadcasting them by calling a full node's `testmempoolaccept`
  RPC when available.  This allows the node to detect potential problems
  with the transaction before anything is sent to a third party,
  potentially speeding up the discovery of a problem and limiting the
  potential harm from a bug.  Versions of the `testmempoolaccept` RPC
  are available in Bitcoin Core, most modern software forks of Bitcoin
  Core, and the btcd full node. {% assign timestamp="1:18:02" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29189,28956,29347,6985,6904,7022,6936,7022,6936,8345,22144,22147" %}
[news154 stall]: /en/newsletters/2021/06/23/#bitcoin-core-22144
[news145 lnproto]: /en/newsletters/2021/04/21/#c-lightning-4444
[siegel stall]: https://delvingbitcoin.org/t/block-stalling-issue-in-core-prior-to-v22-0/499/
[corallo 0conf]: https://delvingbitcoin.org/t/0conf-ln-channels-and-v3-anchors/494/
[teinturier splice]: https://delvingbitcoin.org/t/0conf-ln-channels-and-v3-anchors/494/2
[teinturier segwit]: https://delvingbitcoin.org/t/malleability-issues-when-creating-shared-transactions-with-segwit-v0/497
[news97 spk]: /en/newsletters/2020/05/13/#request-for-an-additional-taproot-signature-commitment
[todd rbfr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022298.html
[erhardt rbfr1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022302.html
[erhardt rbfr2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022316.html
[sz rbfr]: https://delvingbitcoin.org/t/replace-by-fee-rate-vs-v3/488/
[libre relay]: https://github.com/petertodd/bitcoin/tree/libre-relay-v26.0
[libbitcoinkernel]: https://github.com/bitcoin/bitcoin/issues/27587
[news284 adjtime]: /en/newsletters/2024/01/10/#bitcoin-core-pr-review-club
[news276 ml]: /en/newsletters/2023/11/08/#mailing-list-hosting
[lnd v0.17.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.4-beta
