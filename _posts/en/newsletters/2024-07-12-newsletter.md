---
title: 'Bitcoin Optech Newsletter #311'
permalink: /en/newsletters/2024/07/12/
name: 2024-07-12-newsletter
slug: 2024-07-12-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes our regular sections with the summary of
a Bitcoin Core PR Review Club meeting, announcements of new releases and
release candidates, and descriptions of notable changes to popular
Bitcoin infrastructure software.

## News

*No significant news this week was found in any of our [sources][].  For
fun, you may want to check out a recent [interesting transaction][].* {% assign timestamp="1:00" %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

[Testnet4 including PoW difficulty adjustment fix][review club 29775] is
a PR by [Fabian Jahr][gh fjahr] that introduces Testnet4 as a new test
network to replace Testnet3 and simultaneously fixes the long-standing
difficulty adjustment and time warp bugs. It is the result of a
[discussion on the mailing-list][ml testnet4] and is accompanied by a
[BIP proposal][bip testnet4].

{% include functions/details-list.md
  q0="Aside from the consensus changes, what differences do you see
  between Testnet 4 and Testnet 3, particularly the chain params?"
  a0="The deployment heights of past soft forks are all set to 1, which
  means they're active from the beginning. Testnet4 also uses a
  different port (`48333`) and messagestart, and it has a new genesis
  block message."
  a0link="https://bitcoincore.reviews/29775#l-29"

  q1="How does the 20-min exception rule work in Testnet 3? How does
  this lead to the block storm bug?"
  a1="If a new block's timestamp is more than 20 minutes ahead of the
  previous block's timestamp, it is allowed to have minimum
  proof-of-work difficulty. The next block is subject to the \"real\"
  difficulty again, unless it too falls under the 20-min exception rule.
  This exception is made to enable the chain to make progress in an
  environment of highly variable hashrate. Due to a bug in the
  `GetNextWorkRequired()` implementation, the difficulty is actually
  reset (instead of temporarily lowered for just one block) when the
  last block of a difficulty period is a min-difficulty block."
  a1link="https://bitcoincore.reviews/29775#l-47"

  q2="Why was the time warp fix included in the PR? How does the time
  warp fix work?"
  a2="A [time warp][topic time warp] attack allows an attacker to
  significantly alter the block production rate, so it makes sense to
  fix this alongside the min-difficulty bug. Since it is also part of
  the [consensus cleanup soft fork][topic consensus cleanup],
  test-running the fix in Testnet4 first provides useful early feedback.
  This PR fixes the time warp bug by checking that the first block of a
  new difficulty epoch is not earlier than 2 hours before the last block
  of the previous epoch."
  a2link="https://bitcoincore.reviews/29775#l-68"

  q3="What is the message in the Genesis block in Testnet 3?"
  a3="Testnet 3, as well as all other nets (preceding Testnet 4), have
  the same well-known genesis block message: \"The Times
  03/Jan/2009 Chancellor on brink of second bailout for banks\".
  Testnet4 is the first network to have its own genesis block message,
  which includes the hash of a recent mainnet block (currently
  `000000000000000000001ebd58c244970b3aa9d783bb001011fbe8ea8e98e00e`) to
  provide strong guarantees that no pre-mining on this Testnet 4 chain
  occurred before this mainnet block was mined."
  a3link="https://bitcoincore.reviews/29775#l-17"
%}

{% assign timestamp="15:14" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 26.2][] is a maintenance version of Bitcoin Core's older
  release series.  Anyone on 26.1 or earlier who is unable or unwilling to
  upgrade to the latest release (27.1) is encouraged to upgrade to this
  maintenance release. {% assign timestamp="37:23" %}

- [LND v0.18.2-beta][] is a minor release to fix a bug affecting users
  of older versions of the btcd backend. {% assign timestamp="37:42" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Rust Bitcoin #2949][] adds a new method `is_standard_op_return()` to validate
  OP_RETURN outputs against current standardness rules, allowing
  programmers to test whether OP_RETURN data exceeds the 80-byte
  maximum size enforced by Bitcoin Core.  Programmers who aren't worried
  about exceeding the current default Bitcoin Core limit can continue to
  use Rust Bitcoin's existing `is_op_return` function. {% assign timestamp="40:04" %}

- [BDK #1487][] introduces support for custom input and output sorting functions
  by adding a `Custom` variant to the `TxOrdering` enum, to enhance flexibility
  in transaction construction. Explicit [BIP69][] support is removed because
  it may not provide the desired privacy due to its low adoption rate (see Newsletters
  [#19][news19 bip69] and [#151][news151 bip69]), but users can still create
  BIP69-compliant transactions by implementing appropriate custom sorting. {% assign timestamp="41:20" %}

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2949,1487" %}
[bitcoin core 26.2]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[sources]: /en/internal/sources/
[interesting transaction]: https://stacker.news/items/600187
[LND v0.18.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.2-beta
[news19 bip69]: /en/newsletters/2018/10/30/#bip69-discussion
[news151 bip69]: /en/newsletters/2021/06/02/#bolts-872
[gh fjahr]: https://github.com/fjahr
[review club 29775]: https://bitcoincore.reviews/29775
[ml testnet4]: https://groups.google.com/g/bitcoindev/c/9bL00vRj7OU
[bip testnet4]: https://github.com/bitcoin/bips/pull/1601
