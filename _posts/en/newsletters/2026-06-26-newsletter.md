---
title: 'Bitcoin Optech Newsletter #411'
permalink: /en/newsletters/2026/06/26/
name: 2026-06-26-newsletter
slug: 2026-06-26-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes the responsible disclosure of a
denial-of-service vulnerability that affected older versions of LND. Also
included are our regular sections with selected questions and answers from the
Bitcoin Stack Exchange, announcements of new releases and release candidates,
and descriptions of notable changes to popular Bitcoin infrastructure software.

## News

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Is it a bug that `OP_IF` is part of the tapscript opcodes?]({{bse}}130785)
  Antoine Poinsot explains that while any spending policy can be expressed as
  one [taproot][topic taproot] leaf per path, that is not always the most
  efficient encoding. Depending on the number of paths and how often each is
  used, an `OP_IF` inside a single [tapscript][topic tapscript] leaf can produce
  smaller spends than splitting paths across leaves or switching to P2WSH.

- [Why would forbidding `OP_IF` in tapscript be a problem?]({{bse}}130815)
  Murch notes that because a taproot output commits to its leaf scripts as a
  hash, it is impossible to know which existing UTXOs rely on `OP_IF`, such as
  [miniscript][topic miniscript]-based degrading multisig wallets. Users with such
  setups could unwittingly lock up funds received after activation if those
  spending paths were no longer valid.

- [Does a softfork always succeed?]({{bse}}130775)
  Murch walks through a scenario where a [soft fork][topic soft fork activation]
  using mandatory signaling is supported by only a minority of hashrate,
  showing that the signaling chain falls behind on proof of work and stalls
  rather than forcing the rest of the network to adopt the new rules.

- [How to set up Bitcoin Core to mine a valid block after the BIP110 activation in August 2026?]({{bse}}130770)
  Antoine Poinsot notes that Bitcoin Core does not enforce the BIP110
  rules and has no feature to build a block template that excludes the
  transactions BIP110 treats as invalid. A node operator wanting to mine
  BIP110-compliant blocks would need to select transactions with external block
  template building software or could mine empty blocks.

- [Are BIP110 blocks on a branch with lower difficulty valid?]({{bse}}130827)
  Pieter Wuille distinguishes a chain being valid from being active. Each
  branch's difficulty adjustment depends only on its own blocks, so a potentially-slower
  BIP110 branch is still valid to nodes following the current rules, but they
  will never make it their active chain unless it accumulates more total proof
  of work than the main chain.

- [What is the story behind Bitcoin test networks?]({{bse}}130806)
  Murch and Antoine Poinsot trace the history of [testnet][topic testnet] from
  testnet1 through the proposed testnet5, including the repeated resets after
  each network was monetized and the 20-minute difficulty exception that led to
  testnet3's recurring block storms (see [Newsletter #311][news311 block storm]).

- [Why was `-datacarriersize` redefined in 2022, and why was the 2023 proposal to expand it not merged?]({{bse}}128027)
  Revisiting a question first answered last year, Murch adds a complementary
  answer documenting that the `datacarrier` and `datacarriersize` options have
  referred only to `OP_RETURN` outputs since their introduction in Bitcoin Core
  0.10.0, citing the original code and release notes.

- [Are chains of 26 unconfirmed transactions prohibited by the wallet in Bitcoin Core 31.0?]({{bse}}130777)
  Pol Espinasa clarifies that the mempool itself permits longer chains under the
  new [cluster mempool][topic cluster mempool] limits, but the Bitcoin Core
  wallet still enforces a 25-transaction limit during coin selection, so longer
  chains must be built without the wallet.

- [Are there changes in Bitcoin Core 29.0 that affect memory usage?]({{bse}}127887)
  Antoine Poinsot clarifies that the apparent increase is a reporting artifact
  rather than higher process memory use. Bitcoin Core 29.0 lets its chainstate
  database cache more data when free memory is available, and that cache is
  released when other processes need the memory.

- [What is Bitcoin Core's release schedule?]({{bse}}130817)
  Murch describes that Bitcoin Core releases major versions on a fixed
  schedule in April and October, replacing the previous practice of targeting
  six months after the prior release, where timelines might slip. Minor releases
  continue to ship bug fixes as needed.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

FIXME:Gustavojfe

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

FIXME:Gustavojfe

{% include snippets/recap-ad.md when="2026-06-30 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}

[news311 block storm]: /en/newsletters/2024/07/12/#bitcoin-core-pr-review-club
