---
title: 'Bitcoin Optech Newsletter #357'
permalink: /en/newsletters/2025/06/06/
name: 2025-06-06-newsletter
slug: 2025-06-06-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter shares an analysis about syncing full nodes
without old witnesses.  Also included are our regular sections with
descriptions of discussions about changing consensus, announcements of
new releases and release candidates, and summaries of notable changes to
popular Bitcoin infrastructure software.

## News

- **Syncing full nodes without witnesses:** Jose SK [posted][sk nowit]
  to Delving Bitcoin a summary of an [analysis][sk nowit gist] he
  performed about the security tradeoffs of allowing newly started full
  nodes with a particular configuration to avoid downloading some
  historic blockchain data.  By default, Bitcoin Core nodes use the
  `assumevalid` configuration setting that skips validation of scripts
  in blocks created more than a month or two before the release of the
  version of Bitcoin Core being run.  Although disabled by default, many
  users of Bitcoin Core also set a `prune` configuration setting that
  deletes blocks some time after validating them (how long blocks are
  kept depends on the size of the blocks and the specific setting selected
  by the user).

  SK argues that witness data, which is only used for validating
  scripts, should not be downloaded by pruned nodes for assumevalid
  blocks because they won't use it for validating scripts and will
  eventually delete it.  Skipping witness download "can cut
  bandwidth usage by over 40%," he writes.

  Ruben Somsen [argues][somsen nowit] that this changes the security
  model to some degree.  Although scripts aren't validated, the
  downloaded data is validated against the commitment from the block
  header merkle root to the coinbase transaction to the witness data.
  This ensures the data was available and uncorrupted at the time the
  node was initially synced.  If nobody routinely validates the
  existence of the data, it could conceivably be lost, as [has
  happened][ripple loss] to at least one altcoin.

  The discussion was ongoing at the time of writing.

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **Quantum computing report:** Clara Shikhelman [posted][shikelman
  quantum] to Delving Bitcoin the summary of a [report][sm report] she
  co-authored with Anthony Milton about the risks to Bitcoin users of
  fast quantum computers, an overview of several pathways to [quantum
  resistance][topic quantum resistance], and an analysis of tradeoffs
  involved in upgrading the Bitcoin protocol.  The authors find 4 to 10
  million BTC are potentially vulnerable to quantum theft, some
  mitigation now is possible, Bitcoin mining is unlikely to be
  threatened by quantum computing in the short or medium term, and
  upgrading requires widespread agreement.

- **Transaction weight limit with exception to prevent confiscation:**
  Vojtěch Strnad [posted][strnad limit] to Delving Bitcoin to propose
  the idea for a consensus change to limit the maximum weight of most
  transactions in a block.  The simple rule would only allow a transaction
  larger than 400,000 weight units (100,000 vbytes) in a block if it was
  the only transaction in that block besides the coinbase transaction.
  Strnad and others described the motivation for limiting the maximum
  transaction weight:

  - _Easier block template optimization:_ it's easier to find a
    near-optimal solution to the [knapsack problem][] the smaller the
    items are compared to the overall limit.  This is partly
    due to minimizing the amount of space left over at the end, with
    smaller items leaving less unused space.

  - _Easier relay policy:_ the policy for relaying unconfirmed
    transactions between nodes predicts what transactions will be
    mined in order to avoid wasting bandwidth.  Giant transactions make
    accurate predictions harder as even a small change in the top feerate can cause
    them to be delayed or evicted.

  - _Avoiding mining centralization:_ ensuring relaying full nodes are
    able to handle almost all transactions prevents users of special
    transactions from needing to pay [out-of-band fees][topic
    out-of-band fees], which can lead to mining centralization.

  Gregory Sanders [noted][sanders limit] it might be reasonable to
  simply soft fork a maximum weight limit without any exceptions based
  on Bitcoin Core's 12 years of consistent relay policy.  Gregory
  Maxwell [added][maxwell limit] that transactions spending only UTXOs
  created before the soft fork could be allowed an exception to prevent
  confiscation, and that a [transitory soft fork][topic transitory soft
  forks] would allow the restriction to expire if the
  community decided not to renew it.

  Additional discussion examined the needs of parties wanting
  large transactions, mainly [BitVM][topic acc] users in the near term,
  and whether alternative approaches were available to them.

- **Removing outputs from the UTXO set based on value and time:** Robin
  Linus [posted][linus dust] to Delving Bitcoin to propose a soft fork
  for removing low-value outputs from the UTXO set after some
  time.  Several variations on the idea were discussed, with the two
  main alternatives being:

  - _Destroy old uneconomic funds:_ small value outputs that had not
    been spent for a long time would become unspendable.

  - _Require old uneconomic funds to be spent with a proof of existence:_
    [utreexo][topic utreexo] or a similar system could be used to allow
    a transaction to prove that the outputs it spends are part of the
    UTXO set.  Old and [uneconomical outputs][topic uneconomical outputs] would
    need to include this proof, but newer and higher-value outputs would
    still be stored in the UTXO set.

  Either solution would effectively limit the maximum size of the UTXO
  set (assuming a minimum value and the 21 million bitcoin limit).
  Several interesting technical aspects of a design were discussed,
  including alternatives to utreexo proofs for this application that
  could be more practical.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Core Lightning 25.05rc1][] is a release candidate for the next major
  version of this popular LN node implementation.

- [LND 0.19.1-beta.rc1][] is a release candidate for a maintenance
  version of this popular LN node implementation.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #32582][] log: Additional compact block logging

- [Bitcoin Core #31375][] multiprocess: Add bitcoin wrapper executable

- [BIPs #1483][] BIP 77: Async Payjoin

{% include snippets/recap-ad.md when="2025-06-10 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32582,31375,1483" %}
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[ripple loss]: https://x.com/JoelKatz/status/1919233214750892305
[sk nowit]: https://delvingbitcoin.org/t/witnessless-sync-for-pruned-nodes/1742/
[sk nowit gist]: https://gist.github.com/JoseSK999/df0a2a014c7d9b626df1e2b19ccc7fb1
[somsen nowit]: https://gist.github.com/JoseSK999/df0a2a014c7d9b626df1e2b19ccc7fb1?permalink_comment_id=5597316#gistcomment-5597316
[shikelman quantum]: https://delvingbitcoin.org/t/bitcoin-and-quantum-computing/1730/
[sm report]: https://chaincode.com/bitcoin-post-quantum.pdf
[strnad limit]: https://delvingbitcoin.org/t/non-confiscatory-transaction-weight-limit/1732/
[knapsack problem]: https://en.wikipedia.org/wiki/Knapsack_problem
[sanders limit]: https://delvingbitcoin.org/t/non-confiscatory-transaction-weight-limit/1732/2
[maxwell limit]: https://delvingbitcoin.org/t/non-confiscatory-transaction-weight-limit/1732/4
[linus dust]: https://delvingbitcoin.org/t/dust-expiry-clean-the-utxo-set-from-spam/1707/
[lnd 0.19.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.1-beta.rc1
