---
title: 'Bitcoin Optech Newsletter #188'
permalink: /en/newsletters/2022/02/23/
name: 2022-02-23-newsletter
slug: 2022-02-23-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about fee bumping and
transaction fee sponsorship, describes a proposal for an updated LN
gossip wire protocol, and advertises a signet for testing
`OP_CHECKTEMPLATEVERIFY`.  Also included are our regular sections with
selected questions and answers from the Bitcoin Stack Exchange and
descriptions of notable changes to popular Bitcoin infrastructure
projects.

## News

- **Fee bumping and transaction fee sponsorship:** separate from the
  replace-by-fee discussion started a couple weeks ago (see [Newsletter
  #186][news186 rbf]), this week James O'Beirne [started][obeirne bump]
  a discussion about fee bumping.  In particular, O'Beirne is concerned
  that some of the transaction relay policy changes being proposed will
  complicate the use of fee bumping for users and wallet developers.  As
  an alternative, he seeks renewed consideration of [transaction fee
  sponsorship][topic fee sponsorship] (previously described in
  [Newsletter #116][news116 sponsorship]).

    The ideas received significant discussion on the mailing list, with
    many responses mentioning challenges to implementation of fee
    sponsorship.

- **Updated LN gossip proposal:** Rusty Russell [posted][russell gossip]
  to the Lightning-Dev mailing list a detailed proposal for a new set of
  LN gossip messages similar to his 2019 proposal described in
  [Newsletter #55][news55 gossip].  The new proposal uses
  [BIP340][]-style [schnorr signatures][topic schnorr signatures] and
  [x-only public keys][news72 xonly].  Also included are a number of
  simplifications over the existing LN gossip protocol, which is used to
  advertise the existence of public channels for routing.  The updated
  protocol is designed to maximize efficiency, especially when combined
  with an [erlay][topic erlay]-like [minisketch][topic minisketch]-based
  efficient gossip protocol.

- **CTV signet:** Jeremy Rubin [published][rubin ctv signet] parameters
  and code for a [signet][topic signet] with
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] activated.
  This simplifies public experimentation with the proposed opcode and
  makes it much easier to test compatibility between different software
  using the code.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Will a post-subsidy block with no transactions include a coinbase transaction?]({{bse}}112193)
  Pieter Wuille explains that every block must have a coinbase transaction
  and since every transaction must include at least one
  input and one output, a post-subsidy block with no block reward (no fees and
  no subsidy) will still require at least one zero-value output.

- [How can the genesis block contain arbitrary data on it if the script is invalid?]({{bse}}112439)
  Pieter Wuille lists the reasons why the genesis block's coinbase
  "Chancellor..." text push is valid. First, the [genesis block][bitcoin se 13122] is valid by
  definition. Second is that coinbase input scripts are never executed.
  Third is that, for non-taproot inputs, the requirement of a single element on the stack
  after execution is only a policy rule, not a consensus rule. Finally, that policy
  rule applies only to the final stack after an input script is executed together with the corresponding output script. Since there
  are no corresponding output scripts for the inputs of coinbase transactions, the policy does not
  apply. Wuille also notes the reason for the genesis block's unspendability is
  unrelated to this discussion and involves the original Bitcoin software [not
  adding the genesis block][bitcoin github genesis] to its internal database.

- [What is a Feeler Connection? When is it used?]({{bse}}112247)
  User vnprc explains the purpose of Bitcoin Core's [feeler
  connection][chaincode p2p] which is a temporary outbound connection separate from the
  default 8 outbound connections and 2 blocks-only outbound connections. The
  feeler connection is used to test potential new peers suggested from the
  gossip network as well as test previously unreachable peers which are candidates for eviction.

- [Are OP_RETURN transactions not stored in chainstate database?]({{bse}}112312)
  Antoine Poinsot points out that since `OP_RETURN` outputs are
  [unspendable][bitcoin github unspendable], they are not stored in the
  [chainstate directory][bitcoin docs data].

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #24307][] extends the result object of the `getwalletinfo` RPC
  with the `external_signer` field. This new field indicates whether the wallet
  is configured to use an external signer such as a hardware signing
  device.

- [C-Lightning #5010][] adds a language binding generation tool `MsgGen` and a
  Rust RPC client `cln-rpc`. `MsgGen` parses C-Lightning's JSON-RPC schemas and
  generates the Rust bindings used by `cln-rpc` to correctly call the
  C-Lightning JSON-RPC interface.

- [LDK #1199][] adds support for "phantom node payments", payments that
  can be accepted by any one of several nodes, which can be used for
  load balancing.  This requires creating LN invoices with [BOLT11][] route
  hints that suggest multiple paths all to the same non-existent
  ("phantom") node.  For each of the paths, the last hop before reaching
  the phantom node is a real node that knows the phantom node's key for
  decrypting and reconstructing [stateless invoices][topic stateless
  invoices] (see [Newsletter #181][news181 rl1177]), allowing it to
  accept the payment's [HTLC][topic htlc].

  {:.center}
  ![Phantom node route hints illustration](/img/posts/2022-02-phantom-node-payments.dot.png)

{% include references.md %}
{% include linkers/issues.md v=1 issues="24307,5010,1199," %}
[news186 rbf]: /en/newsletters/2022/02/09/#discussion-about-rbf-policy
[obeirne bump]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019879.html
[news116 sponsorship]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[russell gossip]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-February/003470.html
[news72 xonly]: /en/newsletters/2019/11/13/#x-only-pubkeys
[news55 gossip]: /en/newsletters/2019/07/17/#gossip-update-proposal
[rubin ctv signet]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019925.html
[news181 rl1177]: /en/newsletters/2022/01/05/#rust-lightning-1177
[bitcoin se 13122]: https://bitcoin.stackexchange.com/a/13123/87121
[bitcoin github genesis]: https://github.com/bitcoin/bitcoin/blob/9546a977d354b2ec6cd8455538e68fe4ba343a44/src/main.cpp#L1668
[chaincode p2p]: https://residency.chaincode.com/presentations/bitcoin/ethan_heilman_p2p.pdf#page=18
[bitcoin github unspendable]: https://github.com/bitcoin/bitcoin/blob/280a7777d3a368101d667a80ebc536e95abb2f8c/src/script/script.h#L539-L547
[bitcoin docs data]: https://github.com/bitcoin/bitcoin/blob/master/doc/files.md#data-directory-layout
