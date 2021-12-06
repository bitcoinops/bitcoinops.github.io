---
title: 'Bitcoin Optech Newsletter #178'
permalink: /en/newsletters/2021/12/08/
name: 2021-12-08-newsletter
slug: 2021-12-08-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a post about fee-bumping research and
contains our regular sections with the summary of a Bitcoin Core PR
Review Club meeting, the latest releases and release candidates for Bitcoin software,
and notable changes to popular infrastructure projects.

## News

- **Fee bumping research:** Antoine Poinsot [posted][darosior bump] to
  the Bitcoin-Dev mailing list a detailed description of several concerns
  developers need to consider when choosing how to fee-bump presigned
  transactions used in [vaults][topic vaults] and contract protocols
  such as LN.  In particular, Poinsot looked at schemes for multiparty
  protocols with more than two participants, for which the current [CPFP
  carve out][topic cpfp carve out] transaction relay policy doesn't
  work, requiring them to use [transaction replacement][topic rbf]
  mechanisms that may be vulnerable to [transaction pinning][topic
  transaction pinning].  Also included in his post is the result of
  [research][revault research] into some of the ideas described earlier.

    Ensuring that fee bumping works reliably is a requirement for the
    safety of most contract protocols, and it remains a problem without any
    comprehensive solution yet.  It is encouraging to see continuing
    research into the problem.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Treat taproot as always active][review club #23512] is a PR by Marco Falke to
make transactions spending [taproot][topic taproot] outputs standard, regardless of taproot
deployment status.

{% include functions/details-list.md
  q0="Which areas in the codebase use the status of taproot deployment? Which of
  them are policy related?"
  a0="Prior to this PR, there are 4 areas:
  [GetBlockScriptFlags()][GetBlockScriptFlags tap] (consensus),
  [AreInputsStandard()][AreInputsStandard tap] (policy),
  [getblockchaininfo()][getblockchaininfo tap] (rpc), and
  [isTaprootActive()][isTaprootActive tap] (wallet)."
  a0link="https://bitcoincore.reviews/23512#l-21"

  q1="What mempool validation function checks if a transaction spends a taproot
  input? How does this PR change the function?"
  a1="The function is [`AreInputsStandard()`][AreInputsStandard def]. The PR
  removes the last argument, `bool taproot_active`, from the signature and returns
  `true` for v1 segwit (taproot) spends regardless of taproot activation status.
  Previously, the function would return false if it found a taproot output but
  `taproot_active` was false, e.g. if the node were still in Initial Block
  Download and syncing blocks before taproot activation."
  a1link="https://bitcoincore.reviews/23512#l-40"

  q2="Are there any theoretical issues with the change? For wallet users, is
  it possible to lose money?"
  a2="With this change, the wallet allows importing taproot [descriptors][topic descriptors] at any
  time, i.e., even when taproot is not active and v1 segwit outputs can be spent
  by anyone. This means it's possible to receive bitcoin to a taproot output
  without taproot being active yet; if the chain also reorgs to a block prior to
  709,632, miners (or someone who can get a nonstandard transaction confirmed) can
  steal those UTXOs."
  a2link="https://bitcoincore.reviews/23512#l-82"

  q3="Theoretically, is it possible for a mainnet chain that has taproot
  never-active or active at a different block height to exist?"
  a3="Both are possible. If a very large reorg happened (forking off prior to
  taproot lock-in), the deployment process would be repeated. In this new chain,
  if the number of taproot-signaling blocks never met the threshold, the (still
  valid) chain would never activate taproot. If the threshold were reached after
  the min activation height but before the timeout, taproot could also activate
  at a later height."
  a3link="https://bitcoincore.reviews/23512#l-130"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BDK 0.14.0][] is the latest release of this library for wallet
  developers.  It simplifies adding an `OP_RETURN` output to a
  transaction and contains improvements for sending payments to
  [bech32m][topic bech32] addresses for [taproot][topic taproot].

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], and
[Lightning BOLTs][bolts repo].*

- [Bitcoin Core #23155][] extends the `dumptxoutset` RPC with the hash
  of the chainstate snapshot (UTXO set) along with the number of
  transactions in the entire chain up until that point.  This
  information can be published alongside the chainstate so that others
  can verify it using the `gettxoutsetinfo` RPC, allowing it to be used
  with the proposed [assumeUTXO][topic assumeutxo] node bootstrapping.

- [Bitcoin Core #22513][] rpc: Allow walletprocesspsbt to sign without finalizing FIXME:adamjonas

- [C-Lightning #4921][] updates the implementation of [onion
  messages][topic onion messages] to match the latest updates to the
  draft specifications for [route blinding][bolts #765] and [onion
  messages][bolts #759].

- [C-Lightning #4829][] adds experimental support for the proposed
  LN protocol change in [BOLTs #911][] that will allow nodes to advertise
  their DNS address rather than their IP address or Tor onion service
  address.

- [Eclair #2061][] Relay onion messages FIXME:dongcarl

- [Eclair #2073][] adds support for the optional channel type negotiation
  feature bit as specified in draft [BOLTs #906][].  This corresponds
  to LND's implementation of the same draft feature [last week][news177
  lnd6026].

- [Rust-Lightning #1163][] allows the remote party to set their channel
  reserve below the dust limit, even all the way down to zero.  In the
  worst case, this allows the local node to costlessly attempt to steal
  funds from a fully-spent channel---although such a theft attempt will
  still fail if the remote party is monitoring their channels.  By
  default, most remote nodes discourage such attempts by setting a
  reasonable channel reserve, but some Lightning Service Providers
  (LSPs) use low or zero channel reserves order to provide users with a
  better experience---allowing them to spend 100% of the funds in the
  channel.  Since only the remote node is taking any risk, there's no
  problem allowing the local node to accept such channels.

{% include references.md %}
{% include linkers/issues.md issues="23155,22513,4921,4829,2061,2073,906,1163,765,759,911,23512" %}
[bdk 0.14.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.14.0
[news177 lnd6026]: /en/newsletters/2021/12/01/#lnd-6026
[darosior bump]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-November/019614.html
[revault research]: https://github.com/revault/research
[GetBlockScriptFlags tap]: https://github.com/bitcoin/bitcoin/blob/dca9ab48b80ff3a7dbe0ae26964a58e70d570618/src/validation.cpp#L1616
[AreInputsStandard tap]: https://github.com/bitcoin-core-review-club/bitcoin/blob/15d109802ab93b0af9647858c9d8adcd8a2db84a/src/validation.cpp#L726-L729
[getblockchaininfo tap]: https://github.com/bitcoin/bitcoin/blob/dca9ab48b80ff3a7dbe0ae26964a58e70d570618/src/rpc/blockchain.cpp#L1537)
[isTaprootActive tap]: https://github.com/bitcoin-core-review-club/bitcoin/blob/15d109802ab93b0af9647858c9d8adcd8a2db84a/src/interfaces/chain.h#L292
[AreInputsStandard def]: https://github.com/bitcoin/bitcoin/blob/dca9ab48b80ff3a7dbe0ae26964a58e70d570618/src/policy/policy.h#L110
