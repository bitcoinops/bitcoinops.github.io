---
title: 'Bitcoin Optech Newsletter #61'
permalink: /en/newsletters/2019/08/28/
name: 2019-08-28-newsletter
slug: 2019-08-28-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter asks for comments on the miniscript
language, publishes our final bech32 sending support section, includes popular
Q&A from the Bitcoin Stack Exchange, and describes several notable changes to
popular Bitcoin infrastructure projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Evaluate miniscript:** wallet developers are encouraged to evaluate
  this [proposed language][miniscript code] that can allow wallets to
  adapt to new script templates without requiring changes to the
  underlying wallet code for each new template.  See the *news* section
  for details.

## News

- **Miniscript request for comments:** the developers of this language
  have [requested][miniscript email] community feedback on their initial
  design.  [Miniscript][] allows software to automatically analyze a
  script, including determining what data is necessary to create a
  witness that fulfills the script and allows any bitcoins protected by
  the script to be spent.  With miniscript telling the wallet what it
  needs to do, wallet developers don't need to write new code when they
  switch from one script template to another.

  For example, a wallet developer today who wants to switch from 2-of-3
  multisig to 2-of-2 multisig with a 1-of-2 timelocked escape clause
  might have to write and test a new function for the new case.  With
  miniscript, as long as the wallet knows how to produce signatures for
  specified keys and how to resolve a timelock, miniscript can guide the
  wallet through the various possible paths in an attempt to solve the
  script.  No new spending code would be required.

  For scripts that need signatures or other data from multiple wallets,
  miniscript can guide the wallet into creating all the witness data it
  can so that the data can be bundled into a Partially Signed Bitcoin
  Transaction (PSBT).  Other wallets can create their own PSBTs, all of
  which are given to a PSBT finalizer.  If the finalizer is miniscript
  aware, it can sort the witness data from all the provided PSBTs into a
  single complete witness, making the spending transaction valid.

  This automation for the large range of scripts supported by miniscript
  allows wallets to be much more dynamic about the scripts they use,
  possibly even allowing users to specify their own scripts.  In support
  of that dynamism, miniscripts can be created using an easily-written
  policy language.  Policies are composable, allowing any valid
  sub-expression to be replaced by another valid sub-expression (within
  certain limits imposed by the Bitcoin system).  For example, imagine
  Alice has a 2-of-3 policy that involves a hot wallet, a hardware
  wallet, and a fallback cold wallet:

  ```
  thresh(2, pk(A_hot), pk(A_hard), pk(A_cold))
  ```

  Later Alice is asked to create a fidelity bond that timelocks some of
  her bitcoins for a period of 26,000 blocks.  The generic form of that
  policy is:

  ```
  and(pk(KEY), older(26000))
  ```

  Alice can simply replace `pk(KEY)` with her particular policy:

  ```
  and(thresh(2, pk(A_hot), pk(A_hard), pk(A_cold)), older(26000))
  ```

  The miniscript compiler can convert the policy into an efficient P2WSH
  script and check that it doesn't violate any of Bitcoin's consensus
  rules or Bitcoin Core's transaction relay and mining policy.  It can
  also tell Alice the various sizes related to the script so she can
  estimate her transaction fee expenses.

  If script changes are added to the Bitcoin protocol, such as
  [taproot][bip-taproot], a new version of miniscript will likely be
  created that  supports the protocol additions, making the upgrade easy
  for both wallets and users even if they use complex scripts.

  For more information, see our [miniscript topic page][miniscript], [C++
  miniscript implementation][miniscript code], [Rust
  implementation][miniscript rust], code for a [Bitcoin Core
  integration][core miniscript], and Pieter Wuille's talk about an
  earlier version of miniscript ([video][miniscript vid],
  [transcript][miniscript xs], [Optech summary][miniscript summary]).

## Bech32 sending support

*The last of 24 in a [series][bech32 series] about allowing the people
you pay to access all of segwit's benefits.*

{% include specials/bech32/24-conclusion.md %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments of time to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers made since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [What are the key differences between regtest and the proposed signet?]({{bse}}89640)
  Pieter Wuille and Andrew Chow explain that while
  regtest is good for local automated integration tests, signet is more akin to
  testnet in that it allows testing of things like peer finding, propagation,
  and transaction selection. Signet allows for more control over block
  production timing than testnet and more than one signet can exist for testing
  different scenarios.

- [Can hardware wallets actually display the amount of funds leaving your control?]({{bse}}89508)
  Andrew Chow explains that since a hardware wallet is
  not a full node, it needs to get its transaction amount information elsewhere.
  In the case of non-segwit inputs, often the amount is provided to the hardware
  signing device via the host computer or other wallet by sending the previous
  transaction to the device. In the case of segwit inputs, the amount for the
  input being signed must always be provided because it is a required part of
  the data that is signed and verified.

- [How does one prove that they sent bitcoins to an unspendable wallet?]({{bse}}89554)
  JBaczuk explains that you can prove coins
  unspendable by sending the coins to an OP_RETURN output
  or another script that always returns false, or by sending coins to an
  address derived from a contrived, non-random script hash.

- [Why is proof-of-work required in Bitcoin?]({{bse}}89972) Pieter Wuille
  explains that PoW does not create trust, but instead creates incentive for
  miners to cooperate with other miners by building on their blocks. PoW is also
  used to regulate block times (and thus protect against denial of service)
  since the difficulty adjustment makes it expensive to reliably produce blocks
  more often than every 10 minutes on average.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [LND #2203][] adds a `rejecthtlc` configuration option that will
  prevent the node from forwarding payments for other nodes but will
  still allow it to accept incoming payments and send outgoing payments.

- [LND #3256][] increases the number of inferences LND draws from
  routing failures and uses that information to adjust subsequent
  routes.  For example, nodes are now penalized in the routing
  preference database if they produce an error message that they
  shouldn't be generating given their particular role in a transaction
  (e.g. intermediate node or final node).

- [BOLTs #608][] provides a privacy update to [BOLT4][] that makes it
  harder for a routing node to identify which node is ultimately
  receiving a payment.  Previously, the final node would send a
  `final_expiry_too_soon` error if it received a payment due to expire
  too soon in the future.  Other non-final nodes would simply report
  that they didn't recognize the payment.  This made it possible to
  probe various channels to determine the recipient.  The updated BOLT
  now recommends final nodes send a generic
  `incorrect_or_unknown_payment_details` message even when they know the
  problem is a too-soon expiry.  This is the same basic privacy leak and
  solution described for the wrong-amount problem in [last
  week's newsletter][lnd3391].

## Special thanks

We thank Pieter Wuille and Sanket Kanjalkar for reviewing drafts of this
newsletter and helping us understand the full range of miniscript's
capabilities.  Any remaining errors are the fault of the newsletter
author.

{% include linkers/issues.md issues="16647,3256,608,2203" %}
[bech32 series]: /en/bech32-sending-support/
[lnd3391]: /en/newsletters/2019/08/21#lnd-3391
[miniscript code]: https://github.com/sipa/miniscript
[miniscript email]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-August/017270.html
[core miniscript]: https://github.com/sipa/miniscript/tree/master/bitcoin/script
[miniscript rust]: https://github.com/apoelstra/rust-miniscript
[miniscript vid]: https://www.youtube.com/watch?v=XM1lzN4Zfks
[miniscript xs]: http://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2019/miniscript/
[miniscript summary]: /en/newsletters/2019/02/05#miniscript
[miniscript]: /en/topics/miniscript/
