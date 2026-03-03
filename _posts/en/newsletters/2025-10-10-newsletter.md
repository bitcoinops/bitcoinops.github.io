---
title: 'Bitcoin Optech Newsletter #375'
permalink: /en/newsletters/2025/10/10/
name: 2025-10-10-newsletter
slug: 2025-10-10-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes research into tradeoffs between usability and
security in threshold signatures, summarizes an approach to convert nested
threshold signatures into a single-layer signing group, and examines the
extent to which data could be embedded in the UTXO set under a restrictive set
of rules. Also included are our regular sections summarizing a Bitcoin Core PR
Review Club meeting, announcing new releases and release candidates, and
describing notable changes to popular Bitcoin infrastructure projects.

## News

- **Optimal Threshold Signatures**: Sindura Saraswathi [posted][sindura post]
  research, co-authored by her and Korok Ray, to Delving Bitcoin about determining the optimal threshold for a
  [multisignature][topic multisignature] scheme. In this research, the parameters of usability and
  security are explored, along with their relationship and how it affects the
  threshold that the user should select. By defining p(τ) and q(τ) and then
  combining them into a closed-form solution, they chart the gap between
  security and usability.

  Saraswathi also explores the use of degrading [threshold signatures][topic
  threshold signature] where early stages use higher thresholds, which gradually
  decline in later stages. This means that over time, the attacker gains more
  access to take the funds. She also says that using [taproot][topic taproot],
  there may be new possibilities to be unlocked with these through taptrees and
  more complex contracts, including [timelocks][topic timelocks] and multiple signatures. {% assign timestamp="1:56" %}

- **Flattening certain nested threshold signatures:** ZmnSCPxj
  [posted][zmnscpxj flat] to Delving Bitcoin to describe how to avoid
  using nested [schnorr signatures][topic schnorr signatures] in some
  cases that have not been proven safe.  For example, Alice may want to
  enter a contract with a group consisting of Bob, Carol, and Dan.  Any
  transactions must be approved by Alice and at least two of Bob, Carol,
  and Dan.  In theory, this could be done with a [multisignature][topic
  multisignature] (e.g. [MuSig][topic musig]) where Alice provides one
  partial signature and a [threshold signature][topic threshold
  signature] (e.g.  FROST) is used to generate the partial signature
  from Bob, Carol, and Dan.  However, ZmnSCPxj writes that "currently,
  we have no proof that FROST-in-MuSig is safe".  Instead, ZmnSCPxj
  notes that this example can be satisfied using threshold signatures
  alone: Alice is given multiple shares--enough that she can prevent a
  quorum, but not enough that she can sign unilaterally; the other
  signers are each given one share.

  Described uses of this include multi-operator statechains, users of LN
  who want to use multiple signing devices, and ZmnSCPxj's LSP-enhanced
  [redundant overpayments][topic redundant overpayments] proposal (see
  [Newsletter #372][news372 lspover]). {% assign timestamp="14:33" %}

- **Theoretical limitations on embedding data in the UTXO set:** Adam
  "Waxwing" Gibson started a [discussion][gibson embed] on the mailing
  list about the extent to which data could be embedded in the UTXO set
  under a restrictive set of rules for Bitcoin transactions.  The main
  new rule, which Gibson describes as "appalling", would be to require
  that every [P2TR][topic taproot] output be accompanied by a signature
  proving that the output could be spent.  Gibson attempts to prove that
  there are only three ways that rule could be circumvented to allow
  arbitrary data to masquerade as a public key:

  1. Bitcoin's version of [schnorr signatures][topic schnorr signatures]
     is broken, e.g. based on a faulty assumption.  This is clearly
     currently not the case.

  2. A small amount of arbitrary data could be embedded by grinding the
     public key (that is, generating many different private keys,
     deriving the corresponding public key for each, and discarding all private
     keys whose public keys don't contain the desired arbitrary data
     encoded in a way that can be extracted.
     To include _n_ bits of arbitrary data in the UTXO set in this
     way, requires about 2<sup>n</sup> brute force operations, which is
     impractical for more than a few dozen bits (a few bytes) per
     output).

  3. Using a private key that can easily be calculated by third parties,
     a form of "leaking your private key".

  In the third case, leaking your private key could allow the output to
  be spent by a third party, removing the output from the UTXO set.
  However, several replies to the thread noted ways it might be possible
  to circumvent that in a sophisticated system like Bitcoin.  A
  [reply][towns embed] from Anthony Towns added, "once you make the
  system programmable in interesting ways, I think you
  get data embeddability pretty much immediately, and then it's just a
  matter of trading off the optimal encoding rate versus how easily
  identifiable your transactions can be.  Forcing data to be hidden at a
  cost of making it less efficient just leaves less resources available
  to other users of the system, though, which doesn't seem like a win in
  any way to me." {% assign timestamp="38:14" %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

[Compact block harness][review club 33300] is a PR by [Crypt-iQ][gh
crypt-iq] that increases the [fuzz test][fuzz readme] coverage by adding
a test harness for the [compact block relay][topic compact block relay]
logic. Fuzzing is a testing technique that provides quasi-random inputs
to code to discover bugs and unexpected behavior.

The PR also introduces a new test-only `-fuzzcopydatadir` startup option
to increase runtime performance of the test harness.

{% assign timestamp="27:12" %}

{% include functions/details-list.md
  q0="The fuzz test sends `SENDCMPCT` messages with `high_bandwidth`
  randomly set. How many high bandwidth peers are allowed and does the
  fuzz harness test this limit? More generally, why would a peer choose
  to be high or low bandwidth?"
  a0="For a high-bandwidth peer, a compact block is forwarded without
  announcement and before validation is completed. This greatly
  increases block propagation speed. To reduce the bandwidth overhead, a
  node only selects up to 3 peers to send compact blocks in
  high-bandwidth mode. This mode is not specifically tested by the
  `cmpctblock` fuzz target."
  a0link="https://bitcoincore.reviews/33300#l-66"
  q1="Look at `create_block` in the harness. How many transactions do
  the generated blocks contain, and where do they come from?
  What compact block scenarios might be missed with only a few
  transactions in a block?"
  a1="The generated blocks contain 1-3 transactions: a coinbase
  transaction (always present), optionally a transaction from the
  mempool, and optionally a non-mempool transaction. Since blocks are
  limited to few transactions, some scenarios may be missed, such as
  testing short ID collision handling which becomes more likely with
  many transactions. Review club participants suggested increasing
  transaction counts to improve coverage."
  a1link="https://bitcoincore.reviews/33300#l-132"
  q2="Commit [ed813c4][review-club ed813c4] sorts `m_dirty_blockindex` by
  block hash instead of pointer address. What non-determinism does this
  fix?  The author [notes][q1 note] this slows production code for no
  production benefit. Why can't [`EnableFuzzDeterminism()`][code
  enablefuzzdeterminism] be used here? How do you think this
  non-determinism should be best handled (if not the way the PR
  currently does)?"
  a2="The `m_dirty_blockindex` set is sorted by pointer memory
  addresses, which differ between runs, causing non-deterministic
  behavior. The fix provides a deterministic sort order by using the
  block hash instead. A runtime solution like `EnableFuzzDeterminism()`
  cannot be used because the comparator for a `std::set` is a
  compile-time property of its type and cannot be switched at runtime.
  Because this non-determinism affects the execution path, it misleads
  the fuzzer's code coverage analysis on every insertion into the set.
  The PR author suggests [the afl-fuzz whitepaper][afl fuzz] as
  recommended further reading on how coverage feedback with fuzzing
  works."
  a2link="https://bitcoincore.reviews/33300#l-147"
%}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Inquisition 29.1][] is a release of this [signet][topic signet] full
  node designed for experimenting with proposed soft forks and other major
  protocol changes. It includes the new [minimum relay fee default][topic
  default minimum transaction relay feerates] (0.1 sat/vb) introduced in Bitcoin
  Core 29.1, the larger `datacarrier` limits expected in Bitcoin Core 30.0,
  support for `OP_INTERNALKEY` (see Newsletter [#285][news285 internal] and
  [#332][news332 internal]), and new internal infrastructure for supporting new
  soft forks. {% assign timestamp="45:01" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #33453][] undeprecates the `datacarrier` and `datacarriersize`
  configuration options because many users want to continue using these options,
  the depreciation plan was unclear, and there are minimal downsides to removing
  the deprecation. See Newsletters [#352][news352 data] and [#358][news358 data]
  for additional context on this topic. {% assign timestamp="47:16" %}

- [Bitcoin Core #33504][] skips the enforcement of [TRUC][topic v3 transaction
  relay] checks during a block reorganization when confirmed transactions
  re-enter the mempool, even if they violate TRUC topological constraints.
  Previously, enforcing these checks would erroneously evict many transactions. {% assign timestamp="51:52" %}

- [Core Lightning #8563][] defers the deletion of old [HTLCs][topic htlc] until
  a node is restarted, rather than deleting them when a channel is closed and
  forgotten. This improves performance by avoiding an unnecessary pause that
  halts all other CLN processes. This PR also updates the `listhtlcs` RPC to
  exclude HTLCs from closed channels. {% assign timestamp="53:55" %}

- [Core Lightning #8523][] removes the previously deprecated and disabled
  `blinding` field from the `decode` RPC and on the `onion_message_recv` hook,
  as it has been replaced by `first_path_key`. The `experimental-quiesce` and
  `experimental-offers` options are also removed, because these features are the
  default. {% assign timestamp="56:55" %}

- [Core Lightning #8398][] adds a `cancelrecurringinvoice` RPC command to the
  experimental recurring [BOLT12][] [offers][topic offers], allowing a payer to
  signal a receiver to stop expecting further invoice requests from that series.
  Several other updates are made to align with the latest specification changes
  in [BOLTs #1240][]. {% assign timestamp="58:22" %}

- [LDK #4120][] clears the interactive-funding state when a [splice][topic
  splicing] negotiation fails before the signing phase, if a peer disconnects or
  sends `tx_abort`, allowing the splice to be retried cleanly. If a `tx_abort`
  is received after the peers have begun exchanging `tx_signatures`, LDK treats
  it as a protocol error and closes the channel. {% assign timestamp="59:47" %}

- [LND #10254][] deprecates support for [Tor][topic anonymity networks] v2 onion
  services, which will be removed in the next 0.21.0 release. The configuration
  option `tor.v2` is now hidden; users should use Tor v3 instead. {% assign timestamp="1:01:35" %}

{% include snippets/recap-ad.md when="2025-10-14 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33453,33504,8563,8523,8398,4120,10254,1240" %}
[sindura post]: https://delvingbitcoin.org/t/optimal-threshold-signatures-in-bitcoin/2023
[Bitcoin Inquisition 29.1]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v29.1-inq
[news285 internal]: /en/newsletters/2024/01/17/#new-lnhance-combination-soft-fork-proposed
[news332 internal]: /en/newsletters/2024/12/06/#bips-1534
[news352 data]: /en/newsletters/2025/05/02/#increasing-or-removing-bitcoin-core-s-op-return-size-limit
[news358 data]: /en/newsletters/2025/06/13/#bitcoin-core-32406
[review club 33300]: https://bitcoincore.reviews/33300
[gh crypt-iq]: https://github.com/crypt-iq
[fuzz readme]: https://github.com/bitcoin/bitcoin/blob/master/doc/fuzzing.md
[review-club ed813c4]: https://github.com/bitcoin-core-review-club/bitcoin/commit/ed813c48f826d083becf93c741b483774c850c86
[q1 note]: https://github.com/bitcoin/bitcoin/pull/33300#issuecomment-3308381089
[code enablefuzzdeterminism]: https://github.com/bitcoin/bitcoin/blob/acc7f2a433b131597124ba0fbbe9952c4d36a872/src/util/check.h#L34
[afl fuzz]: https://lcamtuf.coredump.cx/afl/technical_details.txt
[zmnscpxj flat]: https://delvingbitcoin.org/t/flattening-nested-2-of-2-of-a-1-of-1-and-a-k-of-n/2018
[news372 lspover]: /en/newsletters/2025/09/19/#lsp-funded-redundant-overpayments
[gibson embed]: https://gnusha.org/pi/bitcoindev/0f6c92cc-e922-4d9f-9fdf-69384dcc4086n@googlegroups.com/
[towns embed]: https://gnusha.org/pi/bitcoindev/aOXyvGaKfe7bqTXv@erisian.com.au/
